import sys;
import dotenv;
include utils;


# -------------------------
# Core memory & session
 # -------------------------
 node Memory {}


node Session {
    has history: list = [];
    has created_at: str = get_current_datetime();
    has context: dict[str, any] = {};

    # append a new text entry to the session history
    def add_history(entry: str) {
        self.history = self.history + [entry];
    }

    # return the last N history items as a single string
    def get_history -> str {
        return "\n".join(self.history[-30:]);
    }

    # store arbitrary key/value info in session context
    def set_context(key: str, value: any) {
        self.context[key] = value;
    }

    # get a context value by key (returns empty string if missing)
    def get_context(key: str) -> any {
        return self.context.get(key, "");
    }
}


# -------------------------
# Base agent toolbox
 # -------------------------
 node Toolbox {
    # abstract execution route for each agent
    def route_and_run(utterance: str, history: str) -> str abs;
    # generic execution interface for walkers
    can execute with agent entry {
        session = visitor.session;
        response = self.route_and_run(visitor.utterance, session.get_history());
        session.add_history("user: " + visitor.utterance + "\nai: " + response);
        report {"session_id" : jid(visitor.session) , "response" : response } ;
    }

    # helper to call internal tool functions
    def call_tool_with_args(
        args: list[str, ...]
    ) -> str | int | float | dict[str, any] | list[any] {
        python:
            # tool_fn is defined in Python
            result = tool_fn(*args);
        return result;
    }
}


# -------------------------
 # Routing enum: for node discovery
 # -------------------------
 enum RoutingNodes { REPO_MAPPER = "RepoMapper" , CODE_ANALYZER = "CodeAnalyzer" , DOC_GENIE = "DocGenie" }


# -------------------------
# Abstract agent node skeletons
 # -------------------------
 node RepoMapper(Toolbox) {
    def clone_repo(repo_url: str, dest_dir: str) -> str abs;
    def map_repository(local_path: str) -> dict[str, list[str]] abs;
    def summarize_readme(readme_text: str) -> str abs;
    def route_and_run(utterance: str, history: str) -> str abs;
}


node CodeAnalyzer(Toolbox) {
    def detect_languages(files: dict[str, list[str]]) -> list[str] abs;
    def analyze_files(repo_map: dict[str, list[str]]) -> dict[str, dict[str, any]] abs;
    def query_ccg(query: str) -> dict abs;
    def route_and_run(utterance: str, history: str) -> str abs;
}


node DocGenie(Toolbox) {
    def draft_readme(spec: dict, artifacts: dict) -> str abs;
    def draft_section(title: str, content: str) -> str abs;
    def route_and_run(utterance: str, history: str) -> str abs;
}


# -------------------------
# Generic agent walker for orchestration
 # -------------------------
 walker agent {
    has session: Session;
    has utterance: str = "";
    has session_id: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }

    # dynamic node loader by name
    def get_node_class(class_name: str) {
        main_mod = sys.modules.get("__main__");
        if main_mod and hasattr(main_mod, class_name) {
            return getattr(main_mod, class_name, None);
        }
        for (mod_name, mod) in sys.modules.items() {
            if mod and hasattr(mod, class_name) {
                return getattr(mod, class_name);
            }
        }
        return None;
    }

    # routing logic (to be implemented in main.jac via LLM)
    def route_to_node(utterance: str, history: str) -> RoutingNodes abs;
    # main agent entry point
    can execute with `root entry {
        # ensure memory and session exist
        memory_list = [root-->( ` ? Memory ) ];
        if not memory_list {
            memory_list = root ++> Memory();
        }
        memory = memory_list[0];
        if not self.session_id {
            session_list = memory ++> Session();
            self.session = session_list[0];
        } else {
            self.session = & (self.session_id);
        }
        # use LLM (from main.jac) to pick correct node
        routed_node = self.route_to_node(self.utterance, self.session.get_history());
        node_cls = self.get_node_class(routed_node.value);
        if not node_cls {
            report {"error" : "Failed to get node class: " + routed_node.value } ;
            disengage;
        }
        node_inst = node_cls();
        attached_nodes = [root-->( ` ? node_cls ) ];
        if not attached_nodes {
            attached = root ++> node_inst;
            visit attached;
        } else {
            visit attached_nodes[0];
        }
    }
}


# -------------------------
# Admin walker to view sessions
 # -------------------------
 walker get_all_sessions {
    obj __specs__ {
        static has auth: bool = False;
    }

    can get_all_sessions with `root entry {
        memory_list = [here-->( ` ? Memory ) ];
        if not memory_list {
            report "No sessions found." ;
            disengage;
        }
        memory = memory_list[0];
        session_list = [memory-->( ` ? Session ) ];
        report [
            {"id" : jid(session) , "created_at" : session.created_at }
            for session in session_list
        ] ;
    }
}


# -------------------------
# Load environment variables
 # -------------------------
 with entry {
    dotenv.load_dotenv();
}
