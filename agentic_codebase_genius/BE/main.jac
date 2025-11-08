# ===============================
# main.jac — Entry point for Codebase Genius
 # ===============================
 # 1️⃣ Import the required modules
 import from byllm.llm { Model }
# For using LLM-powered functions (byllm)
import os;
# For reading environment variables
include agent_core;
# Import our core agent framework
import from utils { get_current_datetime }
import from dotenv { load_dotenv }
# Helper for timestamps
# 2️⃣ Initialize the LLM model globally
 # You can switch to "gpt-4o-mini" or any supported model for cost or speed.
 glob llm = Model(
    model_name="gemini/gemini-2.5-flash", verbose=False
);


# 3️⃣ Extend the RoutingNodes enum from agentic_core
 # These names will be used by the router (LLM) to decide which agent to call.
 enum RoutingNodes { REPO_MAPPER = "RepoMapper" , CODE_ANALYZER = "CodeAnalyzer" , DOC_GENIE = "DocGenie" }


# ===============================
# RepoMapper Node
 # ===============================
 node RepoMapper(Toolbox) {
    def clone_repo(repo_url: str, dest_dir: str) -> str by llm();
    def map_repository(local_path: str) -> dict[str, list[str]] by llm();
    def summarize_readme(readme_text: str) -> str by llm();
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.clone_repo, self.map_repository, self.summarize_readme])
    );
}


node CodeAnalyzer(Toolbox) {
    def detect_languages(files: dict[str, list[str]]) -> list[str] by llm();
    def analyze_files(files: dict[str, list[str]]) -> dict[str, dict[str, any]] by llm(
        method="ReAct", tools=([self.detect_languages])
    );

    def query_ccg(query: str) -> dict by llm();
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.detect_languages, self.analyze_files, self.query_ccg])
    );
}


node DocGenie(Toolbox) {
    def draft_readme(spec: dict, artifacts: dict) -> str by llm();
    def draft_section(title: str, content: str) -> str by llm();
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct", tools=([self.draft_readme, self.draft_section])
    );
}


walker CodebaseGenius(agent) {
    def route_to_node(utterance: str, history: str) -> RoutingNodes by llm();
}


walker get_all_artifacts {
    obj __specs__ {
        static has auth: bool = False;
    }

    can get_all_artifacts with `root entry {
        report "Use `CodebaseGenius` to start a workflow." ;
    }
}


with entry {
    print("🔧 Codebase Genius initialized. Loading environment...");
    load_dotenv();
    # Prompt user for a GitHub repo URL to test
    print(
        "Please enter a GitHub repository URL to test:"
    );
    repo_url = input();
    # Create a RepoMapper node instance
    repo_mapper = RepoMapper();
    # Clone the repo
    local_path = repo_mapper.clone_repo(repo_url, "");
    # Map the repository files
    repo_map = repo_mapper.map_repository(local_path);
    # Display the results
     # 🧩 Function: clone_repo
     # Uses a tool (implemented in main.impl.jac later) to clone a GitHub repository.
     # 🗂️ Function: map_repository
     # Builds a clean file tree, excluding unwanted folders/files (like __pycache__).
     report {"Cloned path" : local_path , "Repository map" : repo_map } ;
}
