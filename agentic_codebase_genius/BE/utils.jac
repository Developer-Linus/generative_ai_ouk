def map_subdirectory(directory_path: str) -> dict {
    sub_structure = {};
    for entry in os.listdir(directory_path) {
        full_path = os.path.join(directory_path, entry);

        # Skip unwanted directories
        if entry in ["node_modules", "__pycache__", ".git", ".venv"] {
            continue;
        }

        if os.path.isdir(full_path) {
            sub_structure[entry] = map_subdirectory(full_path);  # recurse
        } else {
            sub_structure[entry] = "file";
        }
    }
    return sub_structure;
}
    
    
    
    
    
    


    def scan_file_types () -> dict {
        file_types = {};
        def _walk(struct: dict){
            for name, value in struct.items(){
                if value == "file"{
                    ext = os.path.splitext(name)[1];
                    if ext in file_types {
                        file_types[ext] +=1;
                    } else {
                        file_types[ext] = 1;
                    }
                } else {
                    _walk(value); # Recurse into subfolders
                }
            }
        }
        _walk(self.structure);
        return file_types;
    }
    def detect_special_files() -> dict {
    special_files = {
        "entrypoints": [],
        "config_files": [],
        "docker": False,
        "ci_files": [],
        "tests": False
    };

    def _walk(struct: dict, path: str="") {
        for name, value in struct.items() {
            full_path = os.path.join(path, name);
            if value == "file" {
                # Entrypoints
                if name in ["main.py", "app.py", "index.js"]:
                    special_files["entrypoints"].append(full_path);

                # Dockerfile
                if name.lower() == "dockerfile":
                    special_files["docker"] = True;

                # CI/CD files
                if name in [".github", ".gitlab-ci.yml", "circleci.yml"]:
                    special_files["ci_files"].append(full_path);

                # Config files
                if name in ["package.json", "pyproject.toml", "requirements.txt"]:
                    special_files["config_files"].append(full_path);

                # Tests
                if "test" in name.lower():
                    special_files["tests"] = True;

            else {
                _walk(value, full_path);  # recurse
            }
        }
    }
    _walk(self.structure);
    return special_files;
}
def count_files() -> dict {
    counts = {"files": 0, "directories": 0};

    def _walk(struct: dict) {
        for name, value in struct.items() {
            if value == "file" {
                counts["files"] += 1;
            } else {
                counts["directories"] += 1;
                _walk(value);
            }
        }
    }
    _walk(self.structure);
    return counts;
}
def save_repo_info(info: dict) {
    self.repo_info = info;
    session = visitor.session;
    session.add_log("Saved repository info (" + str(info) + ")");
}
