# A Developer's Story

Maya leaned back in her chair, staring at the bright laptop screen. The room was quiet except for the soft hum of her computer. A cup of cold coffee sat beside her, untouched for hours.

She had just finished building her project — lines of code stretched across dozens of files: `main.py`, `utils.py`, and `config.jac`. The code worked perfectly, but now came the hard part — writing the README file.

She opened a blank document and started typing. Then she stopped.
Deleted. Typed again. Stopped once more.

Nothing sounded right. The words were dry and confusing. She wanted her project to make sense to others, but every sentence felt wrong. The clock kept ticking. Her head began to ache.

Then she remembered a new tool she had heard about from a friend — **Codebase Genius**. With a deep breath, she copied her GitHub link, pasted it into the tool, and clicked **Generate Docs**.

A few seconds later, her screen filled with clear, well-written Markdown. It had everything — a project overview, usage guide, clean diagrams, and even short explanations of her functions.

Maya smiled. The stress she had felt all day slowly faded.
For the first time, her code spoke for itself.
Codebase Genius had turned her long hours of silence and struggle into something that anyone could understand.

---
# System Requirements
Excellent 👍 Here’s the **next section** that follows naturally after your backstory — the **Functional and Non-Functional Requirements** for **Codebase Genius**.

---

## **System Requirements**

### **1. Functional Requirements**

These describe what **Codebase Genius** must do — its features and core functions.

#### **1.1 Input and Initialization**

* The system must accept a **public GitHub repository URL** from the user.
* It must **validate** that the URL is reachable and that the repository can be cloned.
* If the repository is private or invalid, the system must return a clear error message.

#### **1.2 Repository Mapping**

* The system must clone the repository to a temporary folder.
* It must build a **file-tree structure**, ignoring unnecessary directories such as `.git`, `__pycache__`, or `node_modules`.
* It must locate and summarize the `README.md` or similar entry file to help guide later analysis.

#### **1.3 Code Analysis**

* The system must identify the **programming language(s)** used in the repository, prioritizing **Python** and **Jac**.
* It must use a parser (e.g., **Tree-sitter**) to analyze source files and extract:

  * Functions, classes, and modules.
  * Relationships between them (calls, inheritance, dependencies).
* It must construct a **Code Context Graph (CCG)** to represent these relationships.
* The CCG must be queryable, allowing other agents to ask questions like “Which functions call `train_model`?”

#### **1.4 Documentation Generation**

* The system must generate **Markdown documentation** based on the analysis.
* The documentation must include:

  * **Project overview** (from README summary and analysis).
  * **Installation and setup instructions.**
  * **Usage examples.**
  * **API reference** (functions, classes, and relationships).
  * **Diagrams** to illustrate structure and dependencies.
* The generated file must be saved locally (e.g., `./outputs/<repo_name>/docs.md`).

#### **1.5 Multi-Agent Collaboration**

* The system must include at least these agents:

  * **Code Genius (Supervisor):** Manages workflow, decides which files to analyze first, and coordinates agents.
  * **Repo Mapper:** Clones and maps the repository, summarizes the README.
  * **Code Analyzer:** Parses code and builds the Code Context Graph.
  * **DocGenie:** Generates the final Markdown documentation.
* Agents must communicate through shared state or message passing.

#### **1.6 API Exposure**

* The system must provide an **HTTP API** that:

  * Accepts a GitHub repository URL.
  * Triggers the analysis and documentation generation process.
  * Returns the generated documentation or a download link.

#### **1.7 Error Handling**

* The system must gracefully handle errors such as:

  * Invalid repository URL.
  * Network or parsing failures.
  * Unsupported programming languages.
* It must return clear and human-friendly error messages.

---

### **2. Non-Functional Requirements**

These describe the **qualities** of the system rather than its features.

#### **2.1 Performance**

* The system should analyze and document medium-sized repositories (up to 200 files) in **under 3 minutes** on average.
* It should prioritize **high-impact files first** (like `main.py` or `app.jac`) to produce early results quickly.

#### **2.2 Scalability**

* The architecture must support adding new agents easily (for example, a Diagram Generator or Code Reviewer).
* The analysis pipeline should handle multiple requests concurrently.

#### **2.3 Maintainability**

* The system should use a **modular agent-based design**, where each agent can be updated or replaced independently.
* Code should follow clear documentation and naming standards.

#### **2.4 Reliability**

* All agents should include fallback logic to continue processing if another agent fails.
* Temporary repositories must be cleaned up after use to prevent clutter or storage issues.

#### **2.5 Usability**

* The API interface must be simple: a single endpoint to submit a repository URL.
* The output documentation must be easy to read, clearly structured, and suitable for direct publishing on GitHub.

#### **2.6 Extensibility**

* The system should support other programming languages in the future (e.g., JavaScript, Go, Java) by adding new parsers.
* The documentation generator must be flexible enough to integrate diagrams, graphs, and other visualization tools.

#### **2.7 Security**

* The system must sanitize all input URLs to prevent malicious injections.
* It must not store or leak user repository data beyond what is needed for processing.
* If credentials are ever required (for private repos in the future), they must be securely handled through environment variables.

---


Perfect — let’s now write a **clear and professional “System Architecture and Design” section** for your project report.
It will align **exactly** with your assignment (Sections 4.1 & 4.2) and fit your **multi-agent documentation generator for code repositories** (optimized for Python and Jac, generalizable to others).

---

## **4. System Architecture and Design**

### **4.1 System Overview**

Developers often struggle to create accurate and complete README files. Manual documentation is time-consuming, prone to human error, and usually outdated as code evolves.
This system provides an **automated documentation generator** that uses a **multi-agent architecture** to analyze a code repository and produce clean, structured Markdown documentation.
The agents collaborate under a **supervising AI agent (Code Genius)** that coordinates specialized agents for repository mapping, code analysis, and documentation generation.

---

### **4.2 Architectural Goals**

* **Automation:** Minimize manual documentation work.
* **Accuracy:** Generate up-to-date technical details directly from code.
* **Scalability:** Handle small scripts or large multi-module repositories.
* **Extensibility:** Support Python and Jac primarily but generalize to other languages via parsers like Tree-sitter.
* **Collaboration:** Use a multi-agent workflow that mimics how a human documentation team operates.

---

### **4.3 System Architecture**

#### **4.3.1 High-Level Architecture**

The architecture follows a **multi-agent pipeline** model inspired by *byLLM*.
Each agent performs a specific stage of the workflow and communicates via shared state and message passing in Jac.

```text
                ┌────────────────────────────┐
                │      User / API Client     │
                │ (Submit GitHub Repository) │
                └──────────────┬─────────────┘
                               │
                               ▼
                     ┌──────────────────┐
                     │  Code Genius     │
                     │  (Supervisor)    │
                     └──────┬───────────┘
                            │
      ┌─────────────────────┼──────────────────────┐
      ▼                     ▼                      ▼
┌──────────────┐     ┌───────────────┐      ┌────────────────┐
│ Repo Mapper  │     │ Code Analyzer │      │   DocGenie     │
│  (Mapping)   │     │ (Analysis)    │      │ (Doc Synthesis)│
└──────────────┘     └───────────────┘      └────────────────┘
      │                     │                      │
      ▼                     ▼                      ▼
   File Tree &         Code Context Graph       Markdown Docs
   README Summary        (CCG Model)           ./outputs/docs.md
```

---

### **4.4 Agent Descriptions**

#### **1. Code Genius (Supervisor)**

* **Role:** Central controller that orchestrates the workflow.
* **Responsibilities:**

  * Accepts GitHub URL and validates repository accessibility.
  * Delegates cloning and mapping tasks to the **Repo Mapper**.
  * Plans and prioritizes analysis of high-impact files (e.g., `main.py`, `app.jac`).
  * Iteratively triggers the **Code Analyzer** to parse modules.
  * Aggregates partial analyses and calls **DocGenie** to generate final documentation.
* **Inputs:** Repository URL.
* **Outputs:** Final Markdown documentation file.
* **Jac Node/Walker:** `CodeGenius`.

---

#### **2. Repo Mapper**

* **Role:** Creates a structural and semantic map of the repository.
* **Responsibilities:**

  * Clone the GitHub repository into a temporary workspace.
  * Generate a **file-tree representation** excluding irrelevant folders (`.git`, `node_modules`, `__pycache__`).
  * Identify **entry-point files** such as `main.py`, `app.jac`, or `index.js`.
  * Summarize the **README.md** (if present) using both pattern extraction and an LLM summarizer.
* **Outputs:**

  * File tree JSON
  * README summary (text snippet)
* **Jac Node/Walker:** `RepoMapper`.

---

#### **3. Code Analyzer**

* **Role:** Performs in-depth static and semantic code analysis.
* **Responsibilities:**

  * Detect programming languages in the repo.
  * Parse code using **Tree-sitter** (or Python `ast` for Python files).
  * Construct a **Code Context Graph (CCG)** that captures:

    * Function definitions and calls
    * Class inheritance and composition
    * Module imports and dependencies
  * Provide **query APIs** for the Supervisor and DocGenie, e.g.:

    * `who_calls(function_name)`
    * `get_class_hierarchy(class_name)`
* **Outputs:**

  * Serialized CCG object or graph structure.
* **Jac Node/Walker:** `CodeAnalyzer`.

---

#### **4. DocGenie**

* **Role:** Synthesizes final human-readable documentation from structured data.
* **Responsibilities:**

  * Receive file tree, CCG, and summary data.
  * Generate Markdown sections:

    1. **Overview** — summary of repository purpose.
    2. **Installation** — environment setup from detected dependencies.
    3. **Usage** — examples from entry points.
    4. **API Reference** — derived from parsed functions and classes.
  * Render diagrams (import graphs, class hierarchies) as **SVG** using Graphviz.
  * Save output to `./outputs/<repo_name>/docs.md`.
* **Jac Node/Walker:** `DocGenie`.

---

### **4.5 Data Flow and Inter-Agent Communication**

1. **Input Stage**

   * User submits a GitHub URL through a web or CLI interface.
   * `Code Genius` validates the URL and creates a job ID.

2. **Repository Mapping**

   * `Repo Mapper` clones the repository and returns a structured `repo_map` object:

     ```json
     {
       "repo_name": "sample_project",
       "files": [...],
       "folders": [...],
       "entry_points": ["main.py"],
       "readme_summary": "A Flask app for user management"
     }
     ```

3. **Planning**

   * `Code Genius` analyzes the file tree and README summary.
   * It identifies high-impact modules to analyze first.

4. **Code Analysis**

   * `Code Analyzer` parses source files and builds a `CCG`:

     ```json
     {
       "nodes": ["train_model", "load_data", "Model"],
       "edges": [
         {"from": "load_data", "to": "train_model", "type": "calls"}
       ]
     }
     ```

5. **Documentation Generation**

   * `DocGenie` converts structured outputs into a clean Markdown file and diagrams.
   * Supervisor saves the result and returns a downloadable link.

---

### **4.6 Technology Stack**

| Layer           | Technology         | Purpose                                               |
| --------------- | ------------------ | ----------------------------------------------------- |
| Language        | Jac                | Agent orchestration and logic                         |
| Backend Runtime | Python             | Parsing, repository operations                        |
| Parser          | Tree-sitter, `ast` | Language-agnostic syntax parsing                      |
| LLM Integration | byLLM / OpenAI     | Summarization and explanation                         |
| Visualization   | Graphviz / Mermaid | Graph diagrams for documentation                      |
| API Layer       | Jac HTTP server    | Serve endpoints (`/generate`, `/status`, `/download`) |
| Storage         | Local filesystem   | Temporary cloned repos and generated docs             |

---

### **4.7 Non-Functional Requirements**

| Category            | Requirement                                                               |
| ------------------- | ------------------------------------------------------------------------- |
| **Performance**     | Should process a medium-sized repository (<500 files) in under 2 minutes. |
| **Scalability**     | Should support multiple concurrent documentation requests.                |
| **Extensibility**   | Adding support for new languages requires only new parser modules.        |
| **Reliability**     | Recover gracefully from parsing errors; continue partial documentation.   |
| **Security**        | Restrict cloning to public repositories; sanitize file paths.             |
| **Usability**       | Output must be human-readable, logically structured Markdown.             |
| **Maintainability** | Modular agent design allows independent upgrades.                         |

---

### **4.8 Design Patterns Used**

* **Multi-Agent Collaboration Pattern:** Agents act as semi-autonomous specialists under one supervisor.
* **Pipeline Pattern:** Sequential processing from mapping → analysis → generation.
* **Message Passing / Shared State:** Agents communicate through Jac’s graph memory and direct calls.
* **Modular Abstraction:** Each agent can be tested or extended independently.

---

### **4.9 Output Example**

Final output stored at:

```
./outputs/sample_repo/docs.md
```

**Sample snippet:**

````markdown
# Sample Project

## Overview
A Flask-based web application for managing users and authentication.

## Installation
```bash
pip install -r requirements.txt
````

## Usage

```bash
python main.py
```


---