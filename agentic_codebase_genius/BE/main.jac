import from byllm.llm { Model }
import from dotenv { load_dotenv }
import os;
include utils;


# Global model accessible to all agents
glob llm = Model(
    model_name="gemini/gemini-2.5-flash", verbose=False
);


node Repo {
    has name: str = "";
    has url: str = "";
    has local_path: str = "";
    has branch: str = "main";
}


# Container for all sessions
node Memory {}


node Session {
    has repo_name: str = "";
    has created_at: str = get_current_datetime(); # Helper from utilities
    has log: list[str] = [];

    def add_log(entry: str) {
        self.log = self.log + [entry];
    }

    def get_recent_logs -> str {
        return "\n".join(self.log[-10:]);
    }
}


with entry {
    load_dotenv();
}
