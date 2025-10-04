# Tests for Waste Management Agent

# These tests are designed to avoid hitting the LLM endpoint by seeding
# waste_node instances directly, then exercising walker abilities that
# operate on existing graph state. This keeps tests fast and deterministic.


test process_existing_waste_node {
    # Seed a known waste node so we can run the walker on existing data
    # Rationale: Confirms the process_waste ability runs on existing nodes
    # and does not mutate the node's fields.
    glass = root ++> waste_node(
        name="glass",
        harmfulness="low",
        disposal="Recycle via authorized centers",
        wealth_idea="Not applicable",
    );

    # Run the walker by spawning WasteAgent; it will visit the seeded node
    # and trigger process_waste via its with-entry on waste_node.
    root spawn WasteAgent("glass");

    # Verify the node exists and retains its seeded fields
    g = [root --> (`?waste_node)](?name == "glass")[0];
    assert isinstance(g, waste_node);
    assert g.harmfulness == "low";
    assert g.disposal == "Recycle via authorized centers";
    assert g.wealth_idea == "Not applicable";
}


test cache_hit_no_duplicates {
    # Seed a cached entry for the agent to find
    # Rationale: When an entry exists, the agent should reuse it (no LLM call)
    # and must NOT create a duplicate node.
    paper = root ++> waste_node(
        name="paper",
        harmfulness="medium",
        disposal="Collect separately for recycling",
        wealth_idea="Upcycle",
    );

    before = len([root --> (`?waste_node)](?name == "paper"));

    # Spawn the agent with a matching waste_type; it should hit cache
    root spawn WasteAgent("paper");

    after = len([root --> (`?waste_node)](?name == "paper"));

    assert before == 1;
    assert after == 1;
}


test repeated_queries_do_not_duplicate {
    # Rationale: Re-running the agent for the same cached waste should
    # still not create new nodes.
    root spawn WasteAgent("paper");

    count = len([root --> (`?waste_node)](?name == "paper"));
    assert count == 1;
}


test guardrails_not_applied_on_existing_cache {
    # Seed a node with text that would normally be filtered by guardrails
    # Rationale: Guardrails are applied on creation from LLM output.
    # If the node already exists (cache hit), the agent should NOT rewrite it.
    rags = root ++> waste_node(
        name="rags",
        harmfulness="low",
        disposal="burn in open air",  # intentionally unsafe phrasing for test scope
        wealth_idea="Not applicable",
    );

    # Cache hit path: should not alter the existing disposal text
    root spawn WasteAgent("rags");

    r = [root --> (`?waste_node)](?name == "rags")[0];
    assert r.disposal == "burn in open air";
}