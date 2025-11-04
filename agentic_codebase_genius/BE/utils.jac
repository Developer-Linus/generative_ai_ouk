import os;
import re;
import datetime;
import byllm;

# get current time
def get_current_datetime() -> str {
    return datetime.datetime.now().isoformat();
}

# exclude unwanted folders/files
def should_exclude(path: str) -> bool {
    exclude_patterns = [
        "__pycache__", ".git", ".venv", "node_modules",
        ".idea", ".vscode", ".DS_Store", "dist", "build"
    ];
    for pat in exclude_patterns {
        if pat in path {
            return True;
        }
    }
    return False;
}

# build a clean repo file tree
def build_file_tree(root_dir: str) -> dict {
    tree = {};
    for (root, dirs, files) in os.walk(root_dir) {
        dirs[:] = [d for d in dirs if not should_exclude(os.path.join(root, d))];
        rel_root = os.path.relpath(root, root_dir);
        file_list = [f for f in files if not should_exclude(f)];
        tree[rel_root] = file_list;
    }
    return tree;
}

"""You are a technical documentation assistant.
    Summarize the following README in concise, natural English (2–3 sentences)
    describing the repository's purpose, technologies, and functionality.
    README text:
    {readme_text}"""
def summarize_readme(readme_text: str) -> str by llm();

# clean text helper
def clean_text(text: str) -> str {
    text = re.sub(r"\s+", " ", text);
    return text.strip();
}
