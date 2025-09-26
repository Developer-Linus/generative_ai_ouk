# Waste Management Agent
 import from byllm.llm { Model }


glob llm = Model(model_name="gemini/gemini-2.5-flash", verbose=False);


enum Harmfulness { LOW = "low" , MEDIUM = "medium" , HIGH = "high" }


obj WasteAnalysis {
    has harmfulness: Harmfulness;
    has disposal: str;
    has wealth_idea: str;
}


"""Analyze the waste type responsibly and fill the WasteAnalysis object.
- Always use safe, environmentally sound disposal methods.
- Do not suggest burning, dumping in rivers, or unsafe handling.
- If no wealth generation idea exists, set wealth_idea to 'Not applicable'."""
def analyze_waste(waste: str) -> WasteAnalysis by llm();


walker WasteAgent {
    has waste_type: str;

    can start with entry {
        result = analyze_waste(self.waste_type);
        print("==============================");
        print(f"Waste Type: {self.waste_type}");
        print(f"Harmfulness Level: {result.harmfulness}");
        print(f"Proper disposal: {result.disposal}");
        print(f"Wealth Idea: {result.wealth_idea}");
        print("==============================");
    }

    can process_waste with waste_node entry;
}


node waste_node {
    has name: str,
        harmfulness: str,
        disposal: str,
        wealth_idea: str;
}


# CLI entry point
 with entry:__main__ {
    while True {
        waste = input("Enter a waste type (or 'quit' to exit): ");
        if waste == "quit" {
            break;
        }
        root spawn WasteAgent(waste);
    }
}
