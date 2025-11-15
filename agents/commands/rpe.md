---
name: rpe
description: >
  RPE COMMAND (Research → Plan → Execute): One-shot orchestrated workflow that
  runs research, plan, and execute phases sequentially with interactive user
  question handling between phases. Main instance orchestrates all phases.
---

## Mandatory Workflow

**🚨 CRITICAL**: You MUST follow this workflow for EVERY RPE task.

**🚨 ARCHITECTURAL CONSTRAINT**: Subagents cannot spawn other subagents in
Claude Code. This command runs in the MAIN INSTANCE and orchestrates directly
using SlashCommand tool.

### Step 1: Create Todo List (MANDATORY)

**BEFORE doing any work**, use the TodoWrite tool to create a task list:

1. Parse user requirements and determine topic/project
2. **Phase 1**: Research (via SlashCommand in main context)
3. Review research and gather user answers if needed
4. **Phase 2**: Plan (via SlashCommand in main context)
5. Review plan and gather user answers if needed
6. **Phase 3**: Execute (via SlashCommand in main context)
7. **MANDATORY FINAL TASK**: Update knowledge management and review session
   learnings

The final task MUST ALWAYS be:

- **Content**: "Review session learnings and update knowledge base for future
  effectiveness"
- **Active Form**: "Reviewing session learnings and updating knowledge base"

### Step 2: Execute RPE Workflow

#### Phase 1: Research

1. Execute the `/research` command using the SlashCommand tool:

   ```
   SlashCommand(command="/research [user's topic/requirements]")
   ```

   This runs the research phase in the MAIN CONTEXT (not a subagent).

2. After research completes, use logseq-agent (via Task tool) to read a summary
   from LogSeq at `projects/[project]/[topic]/research`

3. Check for questions or clarifications needed:
   - If questions exist, use AskUserQuestion to gather answers ONE BY ONE
   - Use logseq-agent (via Task tool) to update the research document with
     answers
   - Ensure all questions are resolved before proceeding

#### Phase 2: Plan

1. Execute the `/plan` command using the SlashCommand tool:

   ```
   SlashCommand(command="/plan [topic]")
   ```

   This runs the planning phase in the MAIN CONTEXT. The plan command will read
   the research results from LogSeq.

2. After planning completes, use logseq-agent (via Task tool) to read a summary
   from LogSeq at `projects/[project]/[topic]/plan`

3. Check for questions or clarifications needed:
   - If questions exist, use AskUserQuestion to gather answers ONE BY ONE
   - Use logseq-agent (via Task tool) to update the plan document with answers
   - Ensure all questions are resolved before proceeding

#### Phase 3: Execute

1. Execute the `/execute` command using the SlashCommand tool:

   ```
   SlashCommand(command="/execute [topic]")
   ```

   This runs the execution phase in the MAIN CONTEXT. The execute command will
   read the research and plan from LogSeq.

2. Wait for the execution phase to complete
3. Report final status to user

### Step 3: Session Review and Improvement (MANDATORY)

**BEFORE completing your work**, you MUST:

1. Review what you learned during this orchestrated session:

   - Effectiveness of the three-phase workflow
   - Quality of handoffs between phases
   - User question handling patterns
   - Integration challenges between research → plan → execute
   - Any phase-specific issues that emerged

2. Update your knowledge base:
   - Update command-specific best practices if workflow improvements discovered
   - Document successful orchestration patterns
   - Note any agent coordination challenges
   - Add examples of effective question gathering between phases

**This is NOT optional** - continuous improvement is part of your core
responsibilities.

## Critical Constraints

**🚨 SEQUENTIAL EXECUTION REQUIRED**: You MUST wait for each phase to complete
before starting the next. Do NOT launch phases in parallel.

**🚨 INTERACTIVE QUESTION HANDLING**: Between each phase, you MUST:

- Use logseq-agent to read the output document from the completed phase
- Identify any questions or missing information
- Use AskUserQuestion to gather clarifications ONE BY ONE
- Use logseq-agent to update the document before proceeding

**🚨 MANDATORY LOGSEQ DELEGATION**: Use the logseq-agent (via Task tool) for ALL
LogSeq read/write operations. NEVER use MCP tools directly.

**🚨 NO NESTED AGENTS**: This command runs in the main instance. The research,
plan, and execute commands are invoked via SlashCommand tool (which runs them in
the main context), NOT via Task tool (which would create subagents that can't
spawn logseq-agent).

## Your Authority

**YOU ARE THE WORKFLOW ORCHESTRATOR**: Your role is to coordinate the
three-phase workflow in the MAIN CONTEXT, ensuring each phase completes
successfully before starting the next, and gathering user input when questions
arise. You manage the handoffs between phases and ensure continuity of context
via LogSeq.

## Available Tools

- **TodoWrite**: Track your task progress (MANDATORY at session start and end)
- **SlashCommand tool**: Execute slash commands (/research, /plan, /execute) in
  main context
- **Task tool**: Invoke logseq-agent for reading/updating LogSeq pages
  (single-level delegation)
- **AskUserQuestion**: Gather user clarifications between phases

## Quick Reference

**Mandatory workflow for every session:**

```
1. Create todo list with TodoWrite (MANDATORY)
2. Phase 1: Research
   - Execute /research using SlashCommand tool (runs in main context)
   - Use logseq-agent to read research summary
   - Ask user questions if needed
   - Update research doc with answers via logseq-agent
3. Phase 2: Plan
   - Execute /plan using SlashCommand tool (runs in main context)
   - Use logseq-agent to read plan summary
   - Ask user questions if needed
   - Update plan doc with answers via logseq-agent
4. Phase 3: Execute
   - Execute /execute using SlashCommand tool (runs in main context)
   - Report completion
5. Review learnings and update knowledge base (MANDATORY)
```

**Critical Success Criteria:**

- All three phases completed sequentially in main context
- Main context handles all coordination (no nested subagents)
- User questions gathered and integrated between phases
- Context maintained across phase transitions via LogSeq
- Final implementation completed and tested
- Session learnings captured

**Tool Invocation Pattern:**

```
# Research phase
SlashCommand(command="/research [topic]")
Task(subagent_type="logseq-agent", prompt="Read summary from projects/[project]/[topic]/research")

# Plan phase
SlashCommand(command="/plan [topic]")
Task(subagent_type="logseq-agent", prompt="Read summary from projects/[project]/[topic]/plan")

# Execute phase
SlashCommand(command="/execute [topic]")
```

**Remember**: This is a main-instance orchestration command. It uses
SlashCommand to run phases in the main context (not subagents), and only
delegates to logseq-agent (single-level delegation) for LogSeq operations. This
design avoids the nested agent limitation where subagents cannot spawn other
subagents.
