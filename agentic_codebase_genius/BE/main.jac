import from byllm.llm { Model }
import from dotenv { load_dotenv }
import os;
include utils;


glob llm = Model(model_name="gemini/gemini-2.5-flash", verbose=False);


node Repo {
    has name: str = "";
    has url: str = "";
    has local_path: str = "";
    has branch: str = "main";
}


node Memory {}


node Session {
    has repo_name: str = "";
    has created_at: str = get_current_datetime();
    has log: list[str] = [];

    def add_log(entry: str) {
        self.log = self.log + [entry];
    }

    def get_recent_logs -> str {
        return "\n".join(self.log[-10:]);
    }
}


node RepoMapper {
    has repo_path: str = "";
    has repo_name: str = "";
    has structure: dict = {};
    has readme_summary: str = "";
    has repo_info: dict = {};

    def clean_repo_path(structure: dict) -> dict by llm();
    def get_repo_structure()  -> dict {
        directory_path = self.repo_path;
        session = visitor.session;
        if not directory_path {
            session.add_log("Error: repository path is empthy.");
            return {};
        }
        # Generate deterministic structure
        structure = map_subdirectory(directory_path);
        session.add_log("Generated initial repository structure for " + self.repo_name);
        cleaned_structure = self.clean_repo_path(structure);
        session.add_log("AI cleaned repository structure for " + directory_path);
        self.structure = cleaned_structure;
        return cleaned_structure;
    }

    def check_readme_exists()  -> bool {
        session = visitor.session;
        readme_path = os.path.join(self.repo_path, "README.md");
        exists = os.path.exists(readme_path);
        session.add_log("Checked README.md existence: " + str(exists));
        return exists;
    }

    # Load Readme content
    # Get Repository Structure
     def load_readme_content()  -> str {
        session = visitor.session;
        readme_path = os.path.join(self.repo_path, "README.md");
        session.add_log(f"Loading {readme_path} content...");
        with open(readme_path, "r", encoding="utf-8") as f {
            return f.read();
        }
    }

    # Save readme summary to RepoMapper State
    # Generate deterministic structure
     # Load Readme content
     def save_readme_summary(summary: str) {
        session = visitor.session;
        self.readme_summary = summary;
        session.add_log("Saved README.md summary (" + str(len(summary)) + " chars)");
    }

    def summarize_readme()  -> str by llm(
        method="ReAct",
        tools=(
            [
                self.check_readme_exists,
                self.load_readme_content,
                self.save_readme_summary
            ]
        )
    );

    def extract_repo_info()  -> dict by llm(
        method="ReAct",
        tools=(
            [
                self.scan_file_types,
                self.detect_special_files,
                self.count_files,
                self.save_repo_info
            ]
        )
    );

    def route_and_run()  -> dict by llm(
        method="ReAct", tools=([self.get_repo_structure, self.summarize_readme])
    );

    can execute with CodebaseGenius entry {
        session = visitor.session;
        # Get repository structure
        self.get_repo_structure();
        # Extra Repository Metadata
        self.extract_repo_info();
        if self.check_readme_exists() {
            self.summarize_readme();
        } else {
            session.add_log("No README.md file found.");
        }
        # Log the completion of RepoMapper processing
        session.add_log(
            "Completed RepoMapper processing for repository: " + self.repo_name
        );
        # Report the structured results to the supervisor (CodebaseGenius)
        
        {"session_id" : jid(session) , "created_at" : visitor.session.created_at , "repo_name" : self.repo_name , "structure" : self.structure , "readme_summary" : self.readme_summary , "repo_info" : self.repo_info , };
    }
}


sem RepoMapper. summarize_readme= """
Your task is to summarize the project's README.md.
Steps:
1. Call check_readme_exists.
- If false, respond: "No README.md file found." and stop.
2. Call load_readme_content to retrieve the text.
3. Summarize each section under each subheading using the 50% rule.
4. Create a clean, concise summary of the entire README.
5. Call save_readme_summary(summary) to store it.
6. Return the final summary text.
Use only the provided tools.
""";


sem RepoMapper. extract_repo_info= """
You are RepoMapper's repository analyzer. Your goal is to extract high-level, structured metadata about the repository using the provided tools.
Steps:
1. Call `scan_file_types()` to get all tile extensions and their counts.
2. Call `detect_special_files()` to identify:
- entrypoint files
- config files
- Dockerfiles
- CI/CD files
- test files/folders
3. Call `count_files()` to get total number of files and directories.
4. Combine the outputs from the three tools to create a structured dictionary containing:
- languages used (derived from file extensions)
- dominant language
- frameworks or technologies (based on config and entrypoint files)
- project type (e.g., web app, CLI, library)
- approximate size (small, medium, large based on file counts)
- possible entrypoints
- presence of tests
- notable configuration files
5. call `save_repo_info()` to store the structured metadata in the RepoMapper node
6. Return the final structured dictionary
Use only the tools provided. Do not call any other functions or make assumptions beyond what is inferred from the tool outputs.
""";


sem RepoMapper. route_and_run= """
Given the repo_path already stored in this node, choose the correct tool.
- Use get_repo_structure first.
- If README.md exists, call summarize_readme next.
Return combined structured data as a dictionary.
""";


sem RepoMapper. clean_repo_structure= """
Step 1: Receive the deterministic repository structure as input (a nested dictionary of folders and files).

Step 2: Clean the structure according to the following rules:
    - Remove any empty folders.
    - Remove duplicate entries (if any).
    - Skip irrelevant or noisy directories such as node_modules, __pycache__, .git, .venv.
    - Normalize file and folder names where appropriate (e.g., consistent casing, remove trailing spaces).
    - Ensure nested folder structures are preserved.

Step 3: Return a new, cleaned repository structure in the same nested dictionary format.
    - Keys: folder/file names
    - Values: "file" for files or nested dictionaries for folders

Step 4: Do not hallucinate files that do not exist in the deterministic input.
Step 5: Output should be directly usable for downstream tools such as extract_repo_info() and summarize_readme().
""";


with entry {
    load_dotenv();
}
