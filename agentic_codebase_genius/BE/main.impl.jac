# ==========================
# main.impl.jac
 # Implements core agent logic for Codebase Genius
 # ==========================
 include agent_core;
include utils;


# =====================================================
# RepoMapper Node: Handles cloning and repository mapping
 # =====================================================
 node RepoMapper {
    has temp_dir: str = "./temp_repos";

    # -----------------------------
    # Python helper for cloning repos
     # -----------------------------
     ::py::
import os
import shutil
import subprocess
from utils import should_exclude

def py_clone_repo(repo_url, dest_dir):
    repo_name = repo_url.split("/")[-1]
    if repo_name.endswith(".git"):
        repo_name = repo_name[:-4]
    local_path = os.path.join(dest_dir, repo_name)
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
    if os.path.exists(local_path):
        shutil.rmtree(local_path)
    result = subprocess.run(["git", "clone", repo_url, local_path],
                            capture_output=True, text=True)
    if result.returncode != 0:
        return f"Error cloning repo: {result.stderr}"
    return local_path

def py_map_repository(local_path):
    repo_map = {}
    for root, dirs, files in os.walk(local_path):
        dirs[:] = [d for d in dirs if not should_exclude(d)]
        files = [f for f in files if not should_exclude(f)]
        rel_path = os.path.relpath(root, local_path)
        repo_map[rel_path] = files
    return repo_map
::py::


    def clone_repo(repo_url: str, dest_dir: str = "") -> str {
        if (dest_dir == "") {
            dest_dir = self.temp_dir;
        }
        ;
        return py_clone_repo(repo_url, dest_dir);
    }

    def map_repository(local_path: str) -> dict[str, list[str]] {
        return py_map_repository(local_path);
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

    # -----------------------------
    # Python helpers for code analysis
     # -----------------------------
     ::py::
import os
import networkx as nx
from tree_sitter import Language, Parser

def py_setup_parser(lang_lib_path):
    if not os.path.exists(lang_lib_path):
        Language.build_library(
            lang_lib_path,
            [
                "tree-sitter-python",
                "tree-sitter-javascript",
                "tree-sitter-java",
                "tree-sitter-typescript",
            ]
        )
    lang = Language(lang_lib_path, "python")
    parser = Parser()
    parser.set_language(lang)
    return parser

def py_parse_python_file(file_path):
    parser = py_setup_parser("./build/languages.so")
    with open(file_path, "r", encoding="utf-8") as f:
        code = f.read()
    tree = parser.parse(bytes(code, "utf8"))
    root_node = tree.root_node
    structure = []

    def walk(node):
        if node.type in ["function_definition", "class_definition"]:
            name_node = node.child_by_field_name("name")
            name = code[node.start_byte:name_node.end_byte] if name_node else "unknown"
            structure.append({
                "type": node.type,
                "name": name,
                "start_line": node.start_point[0] + 1,
                "end_line": node.end_point[0] + 1
            })
        for child in node.children:
            walk(child)
    walk(root_node)
    return structure

def py_build_relationship_graph(parsed_data):
    G = nx.DiGraph()
    for item in parsed_data:
        G.add_node(item["name"], type=item["type"])
    for i in range(len(parsed_data) - 1):
        G.add_edge(parsed_data[i]["name"], parsed_data[i + 1]["name"])
    return G

def py_detect_languages(files):
    lang_map = {
        ".py": "Python",
        ".jac": "Jac",
        ".js": "JavaScript",
        ".ts": "TypeScript",
        ".java": "Java",
        ".cpp": "C++",
        ".html": "HTML",
        ".css": "CSS",
    }
    detected = set()
    for folder, flist in files.items():
        for fname in flist:
            for ext, lang in lang_map.items():
                if fname.endswith(ext):
                    detected.add(lang)
    return list(detected)
::py::


    def setup_parser()  -> any {
        return py_setup_parser(self.language_lib);
    }

    def parse_python_file(file_path: str) -> list[dict[str, str | int]] {
        return py_parse_python_file(file_path);
    }

    def build_relationship_graph(parsed_data: list[dict[str, str | int]]) -> any {
        return py_build_relationship_graph(parsed_data);
    }

    def detect_languages(files: dict[str, list[str]]) -> list[str] {
        return py_detect_languages(files);
    }

    def analyze_files(repo_map: dict[str, list[str]]) -> dict[str, dict[str, any]] {
        analysis = {};
        for entry in repo_map.items() {
            folder = entry[0];
            flist = entry[1];
            for fname in flist {
                if (fname.endswith(".py")) {
                    fpath = f"{folder}/{fname}";
                    parsed = self.parse_python_file(fpath);
                    G = self.build_relationship_graph(parsed);
                    # Convert edges to plain list of tuples
                    edges = list(G.edges);
                    # note: no parentheses
                    analysis[fpath] = {"entities" : parsed , "relations" : edges };
                }
                ;
            }
            ;
        }
        ;
        return analysis;
    }

    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=(
            [self.detect_languages, self.analyze_files, self.build_relationship_graph]
        )
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
        ::py::
import os
docs_dir = os.path.dirname(self.docs_path)
if not os.path.exists(docs_dir):
    os.makedirs(docs_dir)
with open(self.docs_path, "w", encoding="utf-8") as f:
    f.write(content)
::py::

    }

    def route_and_run(utterance: str, history: str) -> str by llm(
        method="ReAct",
        tools=([self.draft_readme, self.draft_section, self.save_readme])
    );
}
