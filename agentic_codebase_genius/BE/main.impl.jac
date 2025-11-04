# ==========================
# main.impl.jac
# Implements core agent logic for Codebase Genius
# ==========================

import os;
import shutil;
import subprocess;
import from byllm.llm { Model }
include agentic_core;
include utils;

# Initialize the global LLM (using gpt-4o as base model)
glob llm = Model(model_name="gpt-4o", verbose=False);

# ------------------------------------------------------
# RepoMapper Node Implementation
# ------------------------------------------------------
node RepoMapper {
    has temp_dir: str = "./temp_repos";  # where repos are cloned locally

    # clone_repo: clones a GitHub repo into ./temp_repos/<repo_name>
    def clone_repo(repo_url: str, dest_dir: str = self.temp_dir) -> str {
        # Extract repo name from URL (last part after '/')
        repo_name = repo_url.split("/")[-1];
        if repo_name.endswith(".git") {
            repo_name = repo_name[:-4];
        }

        # Full local path
        local_path = dest_dir + "/" + repo_name;

        # Ensure the temp_repos directory exists
        if not os.path.exists(dest_dir) {
            os.makedirs(dest_dir);
        }

        # If folder already exists, remove it to avoid conflicts
        if os.path.exists(local_path):
            shutil.rmtree(local_path);

        # Clone the repo using git
        result = subprocess.run(["git", "clone", repo_url, local_path],
                                capture_output=True, text=True);

        if result.returncode != 0:
            return f"Error cloning repo: {result.stderr}";

        # Return the local path for later use
        return local_path;
    }

    # map_repository: builds a clean file tree (no noise)
    def map_repository(local_path: str) -> dict {
        repo_map = {};

        for root, dirs, files in os.walk(local_path):
            # Remove excluded folders in-place
            dirs[:] = [d for d in dirs if not should_exclude(d)];
            files = [f for f in files if not should_exclude(f)];

            # Build relative path structure
            rel_path = os.path.relpath(root, local_path);
            repo_map[rel_path] = files;

        return repo_map;
    }

    # summarize_readme: finds README and summarizes it using llm
    def summarize_readme(readme_text: str) -> str by llm();

    # route_and_run: decides what to do based on utterance
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.clone_repo, self.map_repository, self.summarize_readme])
    );
}


# ------------------------------------------------------
# CodeAnalyzer Node Implementation
# ------------------------------------------------------
node CodeAnalyzer {
    # detect_languages: guesses programming languages based on file extensions
    def detect_languages(files: dict) -> list[str] {
        extensions = set();
        lang_map = {
            ".py": "Python",
            ".jac": "Jac",
            ".js": "JavaScript",
            ".ts": "TypeScript",
            ".java": "Java",
            ".cpp": "C++",
            ".html": "HTML",
            ".css": "CSS",
        };

        for folder, flist in files.items():
            for fname in flist:
                for ext, lang in lang_map.items():
                    if fname.endswith(ext):
                        extensions.add(lang);

        return list(extensions);
    }

    # analyze_files: placeholder for deeper static analysis
    def analyze_files(files: dict) -> dict {
        # In future, this can include parsing ASTs, class/function extraction, etc.
        return {
            "summary": "Basic code structure extracted.",
            "language_stats": self.detect_languages(files)
        };
    }

    # query_ccg: simulates a graph query (placeholder)
    def query_ccg(query: str) -> dict {
        return {
            "query": query,
            "result": "Graph query simulated successfully."
        };
    }

    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.detect_languages, self.analyze_files, self.query_ccg])
    );
}


# ------------------------------------------------------
# DocGenie Node Implementation
# ------------------------------------------------------
node DocGenie {
    has docs_path: str = "./docs/readme.md";

    # draft_readme: creates a complete README.md using artifacts and llm
    def draft_readme(spec: dict, artifacts: dict) -> str by llm();

    # draft_section: creates one markdown section
    def draft_section(title: str, content: str) -> str by llm();

    # Helper: Save generated README to docs/readme.md
    def save_readme(content: str) {
        docs_dir = os.path.dirname(self.docs_path);
        if not os.path.exists(docs_dir):
            os.makedirs(docs_dir);

        with open(self.docs_path, "w") as f:
            f.write(content);
    }

    # route_and_run: orchestrates doc generation and saving
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.draft_readme, self.draft_section, self.save_readme])
    );
}
