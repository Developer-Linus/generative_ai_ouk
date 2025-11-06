# ==========================
# main.impl.jac
# Implements core agent logic for Codebase Genius
# ==========================

import os;
import shutil;
import subprocess;
import from byllm.llm { Model }
import networkx as nx;
import tree_sitter;
import from tree_sitter {Language, Parser}
include agentic_core;
include utils;

# Initialize global LLM model
glob llm = Model(model_name="gpt-4o", verbose=False);

# =====================================================
# RepoMapper Node: Handles cloning and repository mapping
# =====================================================
node RepoMapper {
    has temp_dir: str = "./temp_repos";

    def clone_repo(repo_url: str, dest_dir: str = self.temp_dir) -> str {
        repo_name = repo_url.split("/")[-1];
        if repo_name.endswith(".git"):
            repo_name = repo_name[:-4];

        local_path = dest_dir + "/" + repo_name;

        if not os.path.exists(dest_dir):
            os.makedirs(dest_dir);

        if os.path.exists(local_path):
            shutil.rmtree(local_path);

        result = subprocess.run(["git", "clone", repo_url, local_path],
                                capture_output=True, text=True);

        if result.returncode != 0:
            return f"Error cloning repo: {result.stderr}";

        return local_path;
    }

    def map_repository(local_path: str) -> dict {
        repo_map = {};
        for root, dirs, files in os.walk(local_path):
            dirs[:] = [d for d in dirs if not should_exclude(d)];
            files = [f for f in files if not should_exclude(f)];
            rel_path = os.path.relpath(root, local_path);
            repo_map[rel_path] = files;
        return repo_map;
    }

    def summarize_readme(readme_text: str) -> str by llm();

    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.clone_repo, self.map_repository, self.summarize_readme])
    );
}

# =====================================================
# CodeAnalyzer Node: Parses and builds code relationships
# =====================================================
node CodeAnalyzer {
    has language_lib: str = "./build/languages.so";

    # Build and initialize parser (one-time)
    def setup_parser() -> Parser {
        if not os.path.exists(self.language_lib):
            # Dynamically build tree-sitter language library (supports Python, JS, etc.)
            Language.build_library(
                self.language_lib,
                [
                    "tree-sitter-python",
                    "tree-sitter-javascript",
                    "tree-sitter-java",
                    "tree-sitter-typescript",
                ]
            );
        lang = Language(self.language_lib, "python");
        parser = Parser();
        parser.set_language(lang);
        return parser;
    }

    # Extract structure using tree-sitter
    def parse_python_file(file_path: str) -> dict {
        parser = self.setup_parser();
        with open(file_path, "r", encoding="utf-8") as f:
            code = f.read();

        tree = parser.parse(bytes(code, "utf8"));
        root_node = tree.root_node;

        # Walk tree to extract functions/classes
        structure = [];
        cursor = root_node.walk();

        def walk(node):
            if node.type in ["function_definition", "class_definition"]:
                structure.append({
                    "type": node.type,
                    "name": code[node.start_byte:node.child_by_field_name("name").end_byte]
                            if node.child_by_field_name("name") else "unknown",
                    "start_line": node.start_point[0] + 1,
                    "end_line": node.end_point[0] + 1
                });
            for i in range(len(node.children)):
                walk(node.children[i]);

        walk(root_node);
        return structure;
    }

    # Build a relationship graph using NetworkX
    def build_relationship_graph(parsed_data: dict) -> nx.Graph {
        G = nx.DiGraph();
        for item in parsed_data:
            G.add_node(item["name"], type=item["type"]);
        # Example: simplistic relationships
        for i in range(len(parsed_data) - 1):
            G.add_edge(parsed_data[i]["name"], parsed_data[i + 1]["name"]);
        return G;
    }

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

    def analyze_files(repo_map: dict) -> dict {
        analysis = {};
        for folder, flist in repo_map.items():
            for fname in flist:
                if fname.endswith(".py"):
                    fpath = os.path.join(folder, fname);
                    parsed = self.parse_python_file(fpath);
                    G = self.build_relationship_graph(parsed);
                    analysis[fpath] = {
                        "entities": parsed,
                        "relations": list(G.edges())
                    };
        return analysis;
    }

    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.detect_languages, self.analyze_files, self.build_relationship_graph])
    );
}

# =====================================================
# DocGenie Node: Generates structured README.md files
# =====================================================
node DocGenie {
    has docs_path: str = "./docs/readme.md";

    def draft_readme(spec: dict, artifacts: dict) -> str by llm();
    def draft_section(title: str, content: str) -> str by llm();

    def save_readme(content: str) {
        docs_dir = os.path.dirname(self.docs_path);
        if not os.path.exists(docs_dir):
            os.makedirs(docs_dir);
        with open(self.docs_path, "w") as f:
            f.write(content);
    }

    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.draft_readme, self.draft_section, self.save_readme])
    );
}
