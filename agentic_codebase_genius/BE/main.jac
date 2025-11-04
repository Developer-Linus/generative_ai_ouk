# ===============================
# main.jac — Entry point for Codebase Genius
# ===============================

# 1️⃣ Import the required modules
import from byllm.llm { Model }  # For using LLM-powered functions (byllm)
import os;                       # For reading environment variables
include agentic_core;            # Import our core agent framework
import from utils { get_current_datetime }  # Helper for timestamps

# 2️⃣ Initialize the LLM model globally
# You can switch to "gpt-4o-mini" or any supported model for cost or speed.
glob llm = Model(model_name="gpt-4o", verbose=False);

# 3️⃣ Extend the RoutingNodes enum from agentic_core
# These names will be used by the router (LLM) to decide which agent to call.
enum RoutingNodes {
    REPO_MAPPER = "RepoMapper",
    CODE_ANALYZER = "CodeAnalyzer",
    DOC_GENIE = "DocGenie"
}

# ===============================
# RepoMapper Node
# ===============================
node RepoMapper(Toolbox) {
    # 🧩 Function: clone_repo
    # Uses a tool (implemented in main.impl.jac later) to clone a GitHub repository.
    def clone_repo(repo_url: str, dest_dir: str) -> str by llm(
        method="ReAct",
        tools=([self.call_tool])
    );

    # 🗂️ Function: map_repository
    # Builds a clean file tree, excluding unwanted folders/files (like __pycache__).
    def map_repository(local_path: str) -> dict by llm(
        method="ReAct",
        tools=([self.call_tool])
    );

    # 📘 Function: summarize_readme
    # Summarizes the README.md using the byllm model.
    def summarize_readme(readme_text: str) -> str by llm();

    # 🔁 Function: route_and_run
    # This is the node’s main entry logic — decides which function to call.
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.clone_repo, self.map_repository, self.summarize_readme])
    );
}

# ===============================
# CodeAnalyzer Node
# ===============================
node CodeAnalyzer(Toolbox) {
    # 🧠 Detect languages from file extensions
    def detect_languages(files: dict) -> list[str] by llm();

    # 🔍 Analyze code files — can be extended to detect functions, classes, etc.
    def analyze_files(files: dict) -> dict by llm(
        method="ReAct",
        tools=([self.detect_languages])
    );

    # ❓ Query the Code Context Graph (e.g., “what calls this function?”)
    def query_ccg(query: str) -> dict by llm();

    # 🔁 Main route logic for this node
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.detect_languages, self.analyze_files, self.query_ccg])
    );
}

# ===============================
# DocGenie Node
# ===============================
node DocGenie(Toolbox) {
    # 🪄 Draft an entire README.md document from specs and analysis artifacts.
    def draft_readme(spec: dict, artifacts: dict) -> str by llm();

    # 🧩 Draft a single markdown section (like “Installation” or “Usage”)
    def draft_section(title: str, content: str) -> str by llm();

    # 🔁 Routing and execution logic for this node
    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.draft_readme, self.draft_section])
    );
}

# ===============================
# Supervisor Walker (Main Orchestrator)
# ===============================
walker CodebaseGenius(agent) {
    # The LLM decides which agent node (RepoMapper, CodeAnalyzer, or DocGenie)
    # should handle the user’s command, based on utterance and past context.
    def route_to_node(utterance: str, history: str) -> RoutingNodes by llm();

    # Example utterance:
    #   "Analyze this repo_url=https://github.com/user/project"
    #   "Generate README for the mapped repo"
}

# ===============================
# Admin Walker
# ===============================
walker get_all_artifacts {
    obj __specs__ {
        static has auth: bool = False;
    }

    can get_all_artifacts with `root entry {
        report "Use `CodebaseGenius` to start a workflow.";
    }
}

# ===============================
# Environment Setup on Load
# ===============================
with entry {
    # Load environment variables (e.g., API keys for GitHub or OpenAI)
    print("🔧 Codebase Genius initialized. Loading environment...");
    load_dotenv();
}
