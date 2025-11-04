import from dotenv { load_dotenv }
import sys;
include utils;

# -------------------------
# Core memory & session
# -------------------------
node Memory {}

node Session {
    has history: list = [];
    has created_at: str = get_current_datetime();
    has context: dict = {};

    # append a new text entry to the session history
    def add_history(entry: str) {
        self.history = self.history + [entry];
    }

    # return the last N history items as a single string
    def get_history -> str {
        return "\n".join(self.history[-30:]);
    }

    # store arbitrary key/value info in session context
    def set_context(key: str, value: str) {
        self.context[key] = value;
    }

    # get a context value by key (returns empty string if missing)
    def get_context(key: str) -> str {
        return self.context.get(key, "");
    }
}

# -------------------------
# Toolbox base node
# -------------------------
node Toolbox {
    # base abstract method: all Toolbox-derived agents must implement routing/execution
    def route_and_run(utterance: str, history: str) -> str abs;

    # standard execute wrapper used by walkers/visitors to run an agent
    can execute with agent entry {
        session = visitor.session;
        response = self.route_and_run(visitor.utterance, session.get_history());
        session.add_history(
            "user: " + visitor.utterance + "\nai: " + response
        );
        report {
            "session_id": jid(visitor.session),
            "response": response
        };
    }

    # small helper for agents to call other internal tool functions
    def call_tool(tool_fn, *args) -> any {
        return tool_fn(*args);
    }
}

# -------------------------
# Routing enum: all agent names used for routing
# -------------------------
enum RoutingNodes {
    SUPERVISOR = "Supervisor",
    REPO_MAPPER = "RepoMapper",
    CODE_ANALYZER = "CodeAnalyzer",
    DOC_GENIE = "DocGenie"
}

# -------------------------
# Agent node skeletons
# -------------------------
# RepoMapper is responsible for cloning and building a clean file-tree.
# Concrete implementations (clone, map) will go into main.impl.jac.
node RepoMapper(Toolbox) {
    # clone a public github repo to a local temporary path and return local path
    def clone_repo(repo_url: str, dest_dir: str) -> str abs;

    # build a cleaned file tree (dict) from a local path: excludes noise files/folders
    def map_repository(local_path: str) -> dict abs;

    # optional: summarize README or top-level doc to guide analysis
    def summarize_readme(readme_text: str) -> str abs;

    # route_and_run left abstract; implementation will decide when to clone vs map vs summary
    def route_and_run(utterance: str, history: str) -> str abs;
}

# CodeAnalyzer performs language detection and builds a Code Context Graph (CCG).
node CodeAnalyzer(Toolbox) {
    # detect languages present in file map (returns list like ["python", "jac"])
    def detect_languages(files: dict) -> list[str] abs;

    # parse files using the appropriate analyzer (language adapters) and return artifacts
    def analyze_files(files: dict) -> dict abs;

    # query API on the CCG (e.g., who_calls, get_class_hierarchy). Keep generic.
    def query_ccg(query: str) -> dict abs;

    def route_and_run(utterance: str, history: str) -> str abs;
}

# DocGenie synthesizes human-friendly Markdown docs from artifacts.
node DocGenie(Toolbox) {
    # draft a full README.md given spec & artifacts
    def draft_readme(spec: dict, artifacts: dict) -> str abs;

    # draft a single markdown section (title + content)
    def draft_section(title: str, content: str) -> str abs;

    def route_and_run(utterance: str, history: str) -> str abs;
}

# -------------------------
# Supervisor walker (Code Genius)
# -------------------------
walker Supervisor {
    has utterance: str = "";
    has session_id: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }

    # helper to find node class objects by name (searches loaded modules)
    def get_node_class(class_name: str) {
        main_mod = sys.modules.get("__main__");
        if main_mod and hasattr(main_mod, class_name) {
            return getattr(main_mod, class_name);
        }

        for (mod_name, mod) in sys.modules.items() {
            if mod and hasattr(mod, class_name) {
                return getattr(mod, class_name);
            }
        }
        return None;
    }

    # bootstrap or retrieve the session object from Memory
    def _boot_session() {
        memory_list = [root --> (`?Memory)];
        if not memory_list {
            memory_list = root ++> Memory();
        }
        memory = memory_list[0];

        if not self.session_id {
            session_list = memory ++> Session();
            self.session = session_list[0];
        } else {
            self.session = &(self.session_id);
        }
    }

    # main high-level workflow runner:
    # expects utterance like: "start_workflow repo_url=<url>"
    can run_workflow with `root entry {
        self._boot_session();
        self.session.add_history("Supervisor: received command: " + self.utterance);

        # extract repo_url from a simple "repo_url=" token (parsing is purposely minimal here)
        repo_url = "";
        if "repo_url=" in self.utterance {
            parts = self.utterance.split("repo_url=");
            if len(parts) > 1 {
                repo_url = parts[1].split()[0];
            }
        }

        # if missing, report error
        if repo_url == "" {
            report { "status": "error", "message": "No repo_url provided in utterance." };
            disengage;
        }

        # Step 1: Repo mapping
        repo_cls = self.get_node_class(RoutingNodes.REPO_MAPPER.value);
        repo_inst = repo_cls();
        visit [-->(`?repo_cls)] else {
            attached = here ++> repo_inst;
            visit attached;
        } with agent { utterance: "clone_repo repo_url=" + repo_url, session_id: jid(self.session) };

        # Step 2: request mapping (map_repository uses should_exclude defined in utils.jac)
        visit [-->(`?repo_cls)] with agent { utterance: "map_repository", session_id: jid(self.session) };

        # Step 3: Code analysis
        analyzer_cls = self.get_node_class(RoutingNodes.CODE_ANALYZER.value);
        analyzer_inst = analyzer_cls();
        visit [-->(`?analyzer_cls)] else {
            attached = here ++> analyzer_inst;
            visit attached;
        } with agent { utterance: "analyze_files from_session", session_id: jid(self.session) };

        # Step 4: Documentation generation
        doc_cls = self.get_node_class(RoutingNodes.DOC_GENIE.value);
        doc_inst = doc_cls();
        visit [-->(`?doc_cls)] else {
            attached = here ++> doc_inst;
            visit attached;
        } with agent { utterance: "draft_readme from_session", session_id: jid(self.session) };

        # finalize
        self.session.add_history("Supervisor: workflow finished for " + repo_url);
        report {
            "status": "completed",
            "session": jid(self.session),
            "message": "Workflow finished. Check session context for artifacts."
        };
    }
}

# admin helper walker to show all sessions
walker get_all_sessions {
    obj __specs__ {
        static has auth: bool = False;
    }
    can get_all_sessions with `root entry {
        memory_list = [here --> (`?Memory)];
        if not memory_list {
            report "No sessions found.";
            disengage;
        }
        memory = memory_list[0];
        session_list = [memory --> (`?Session)];
        report [ {
            "id": jid(session),
            "created_at": session.created_at
        } for session in session_list ];
    }
}

# On load, ensure environment variables (like LLM keys) are loaded
with entry {
    load_dotenv();
}
