# ==========================
# utils.jac
 # Common utilities for Codebase Genius
 # ==========================
 # ------------------------------------------------------
 # 1. General Utilities
 # ------------------------------------------------------
 # Returns the current date and time as a formatted string
 def get_current_datetime()  -> str {
    ::py::
import datetime
now = datetime.datetime.now()
return now.strftime("%Y-%m-%d %H:%M:%S")
    ::py::

}


# ------------------------------------------------------
# 2. File & Folder Utilities
 # ------------------------------------------------------
 # Reads the content of a text file safely
 def read_file(path: str) -> str {
    ::py::
import os
if not os.path.exists(path):
    return f"[File not found: {path}]"
with open(path, "r", encoding="utf-8") as f:
    return f.read()
    ::py::

}


# Writes text content into a file, creating folders if necessary
def write_file(
    path: str, content: str
) {
    ::py::
import os
dir_path = os.path.dirname(path)
if dir_path and not os.path.exists(dir_path):
    os.makedirs(dir_path)
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
    ::py::

}


# Checks whether a file or folder exists
def file_exists(path: str) -> bool {
    ::py::
import os
return os.path.exists(path)
    ::py::

}


# ------------------------------------------------------
# 3. Repository Utilities
 # ------------------------------------------------------
 # Extracts a clean repo name from a GitHub URL
 def extract_repo_name(
    repo_url: str
) -> str {
    ::py::
repo_name = repo_url.split("/")[-1]
if repo_name.endswith(".git"):
    repo_name = repo_name[:-4]
return repo_name
    ::py::

}


# Determines whether a file or folder should be excluded
def should_exclude(
    name: str
) -> bool {
    ::py::
excluded_items = [
    "__pycache__",
    ".git",
    ".github",
    ".venv",
    "env",
    "venv",
    "node_modules",
    ".idea",
    ".vscode",
    ".DS_Store",
    "dist",
    "build",
    "target",
    "tmp",
    "temp",
    ".mypy_cache",
    ".pytest_cache"
]
return name in excluded_items or name.startswith(".")
    ::py::

}


# ------------------------------------------------------
# 4. Text Summarization (LLM)
 # ------------------------------------------------------
 # Summarizes any given text into a short abstract paragraph
 def summarize_text(
    text: str
) -> str by llm();
