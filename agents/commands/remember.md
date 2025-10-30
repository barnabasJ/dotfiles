# Remember Command

Store information in persistent memory using the memory-agent for retrieval in
future sessions.

## Your Task

Use the memory-agent in STORE mode to save the information provided by the user.

## What to Do

1. **Understand the Information**: Analyze what the user wants to remember

   - Is it a user preference or work pattern?
   - Is it project-specific knowledge or a decision?
   - Is it a technical pattern or solution?
   - Is it context about people, domain, or organization?
   - Is it a conversation insight or key learning?

2. **Determine Category**: Classify the memory appropriately

   - `claude/memories/user/` - Preferences, work patterns, communication style
   - `claude/memories/project/[project-name]/` - Project-specific knowledge
   - `claude/memories/technical/` - Reusable patterns, decisions, solutions
   - `claude/memories/context/` - People, domain knowledge, organizational info
   - `claude/memories/conversation/` - Key insights, important questions, themes
   - `claude/memories/hard-won-knowledge/` - Problems that required effort (if
     applicable)

3. **Call memory-agent**: Use Task tool with subagent_type=memory-agent

   - Provide clear instructions about what to store
   - Include any relevant context about when/why this is important
   - Specify the category if clear from the information
   - Let the agent determine optimal storage structure

4. **Confirm to User**: Report back what was stored
   - Brief summary of what was remembered
   - Where it was stored in the memory system
   - How it can be retrieved in the future

## Example Usage

```
User: /remember I prefer using feature-planner for complex features and task-planner for simple changes

You: I'll store that preference in your memory system.

[Calls memory-agent to store user preference]

Stored in claude/memories/user/preferences/planning-workflow:
- Preference for feature-planner on complex features
- Preference for task-planner on simple changes

This preference will be applied in future planning sessions.
```

## Important Notes

- The memory-agent will handle the LogSeq page creation and formatting
- Trust the agent to choose appropriate memory structure and metadata
- Focus on capturing the essential information and context
- The memory system is designed to improve over time with each addition
