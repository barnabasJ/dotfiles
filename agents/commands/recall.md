# Recall Command

Retrieve information from persistent memory using the memory-agent to access
previously stored knowledge.

## Your Task

Use the memory-agent in RETRIEVE mode to search for and fetch relevant memories
based on the user's query.

## What to Do

1. **Understand the Query**: Analyze what the user is looking for

   - What topic or subject are they asking about?
   - What context might help narrow the search?
   - Which category of memory is most relevant?

2. **Call memory-agent**: Use Task tool with subagent_type=memory-agent

   - Provide clear instructions about what to retrieve
   - Include the user's query or search terms
   - Specify any relevant categories or filters
   - Ask for related memories if applicable

3. **Present Results**: Share what was found with the user

   - Summarize the key information retrieved
   - Include relevant dates and confidence levels
   - Mention related memories if available
   - If nothing found, let user know memory system doesn't have that info

4. **Validate if Applied**: If the memory is used, verify it still works
   - Test that solutions still apply
   - Check if technology hasn't changed
   - Confirm patterns are still current
   - Update memory if information is outdated (see Memory Correction Protocol)

## Example Usage

```
User: /recall What testing patterns do we use?

You: Let me search the memory system for testing patterns.

[Calls memory-agent to retrieve testing memories]

Found in claude/memories/technical/patterns/testing:
- Prefer integration tests over unit tests for business logic
- Use property-based testing for complex data transformations
- Keep test files co-located with source files
- Created: 2025-09-15, Last verified: 2025-10-20

Also found related memory about project-specific test setup in
claude/memories/project/[project]/testing-setup
```

## Important Notes

- The memory-agent will handle searching across LogSeq pages
- Results include confidence levels and dates for context
- If memory is applied and doesn't work, immediately update it (Memory
  Correction Protocol)
- The system may suggest related memories you didn't explicitly ask for
- "Not found" doesn't mean you never knew it - just that it wasn't stored in
  memory system
