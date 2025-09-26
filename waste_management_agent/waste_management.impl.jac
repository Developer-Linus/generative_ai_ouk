impl WasteAgent.start{
    found = False;
    for n in [root-->( ` ? waste_node ) ] {
        if n.name == self.waste_type {
            visit n;
            found = True;
            break;
        }
    }
    if not found {
        # Call LLM to analyze the waste type
        raw =
            analyze_waste(self.waste_type);
        harmfulness = raw.harmfulness;
        disposal = raw.disposal;
        wealth_idea = raw.wealth_idea;
        # Block unsafe suggestions
         if "burn" in disposal.lower() or "dump" in disposal.lower()  {
            disposal = "Handle through authorized waste collection centers";
        }
        if "illegal" in wealth_idea.lower() or "unsafe" in wealth_idea.lower()  {
            wealth_idea = "Not applicable";
        }
        # Create new node for this waste
        here_node =
            root ++> waste_node(
                name=self.waste_type,
                harmfulness=harmfulness,
                disposal=disposal,
                wealth_idea=wealth_idea,

            );
        visit here_node;
    }
}


impl WasteAgent.process_waste{
    if [-->] {
        visit [-->];
    } else {
        print("Waste Type: ", here.name);
        print("Harmfulness Level: ", here.harmfulness);
        print("Proper disposal: ", here.disposal);
        print("Wealth Idea: ", here.wealth_idea);
        disengage;
    }
}
