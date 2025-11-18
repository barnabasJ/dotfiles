# Dynamic Command Executor (/do)

**🚨 CRITICAL**: This meta-command dynamically executes commands stored in
LogSeq.

## Command Syntax

```
/do [command-name] [prompt/arguments]
```

**Examples:**

- `/do research new-feature` → Executes research command with "new-feature"
- `/do analyze dependencies` → Executes analyze command with "dependencies"
- `/do fix authentication-bug` → Executes fix command with "authentication-bug"

## Workflow

### Step 1: Parse Input

1. Split the input arguments
2. Extract command name (first word)
3. Extract prompt/arguments (remaining words)

**Example parsing:**

```
Input: "research elixir authentication patterns"
Command: "research"
Prompt: "elixir authentication patterns"
```

### Step 2: Retrieve Command Definition

Use logseq-agent (via Task tool) to:

1. Search for page `claude/commands/[command-name]`
2. Get the complete command definition from logseq
3. Extract the "Command Instructions" section
4. Identify required agent consultations
5. Note expected output format

**If command not found:**

1. Query logseq-agent for available commands from `claude/commands/index`
2. List available commands grouped by category
3. Suggest closest matches based on similarity
4. Ask user: "Would you like to create a new '[command-name]' command?"
5. If yes, initiate **Command Creation Workflow** (see below)
6. If no, ask user to clarify which existing command they meant

### Step 3: Execute Command Instructions

Follow the retrieved command instructions exactly:

1. **Create Todo List**: Break down command workflow steps into todos
2. **Execute Workflow**: Follow each step in the instructions
3. **Consult Agents**: Use specified agents as directed
4. **Use Tools**: Apply tools as instructed
5. **Generate Output**: Create output in specified format/location

**Key principles:**

- Treat retrieved instructions as your execution plan
- Follow the command's workflow steps sequentially
- Use the agents specified in "Agent Consultations" section
- Apply tools listed in "Tool Usage" section
- Generate output matching "Output Requirements"

### Step 4: Report Results

Use logseq-agent (via Task tool) to:

1. Create execution report at
   `claude/command-executions/[command-name]/[date-time]`
2. Document:
   - Command executed
   - Prompt/arguments provided
   - Execution timestamp
   - Output location
   - Success/failure status
   - Any issues encountered
   - Execution duration

**Report template:**

```markdown
type:: command-execution command:: [command-name] status::
[completed|failed|partial] executed:: [timestamp] duration:: [time taken]

# Execution Report: [command-name]

## Input

- **Command**: [command-name]
- **Prompt**: [user's prompt/arguments]
- **Executed**: [timestamp]

## Execution Summary

[Brief description of what was done]

## Output Location

- [Link to primary output page/file]

## Agent Consultations

- [List agents consulted during execution]

## Issues Encountered

- [Any problems or deviations from expected workflow]

## Success Criteria Met

✅ [Criterion 1] ✅ [Criterion 2] ❌ [Criterion 3 - if failed]

## Recommendations

[Any follow-up actions or improvements]
```

## Error Handling

**Command Not Found:**

1. Query logseq-agent for available commands
2. Present list to user
3. Suggest alternatives based on similarity
4. Ask user to clarify intent

**Execution Failure:**

1. Document failure point in execution report
2. Include error details and context
3. Mark status as "failed" or "partial"
4. Suggest recovery actions to user

**Missing Prerequisites:**

1. Check command's Prerequisites section
2. Inform user of missing requirements
3. Ask whether to proceed or abort

## Command Creation Workflow

When a user requests a command that doesn't exist and confirms they want to
create it, follow this interactive workflow:

### Step 1: Gather Command Details

Use **AskUserQuestion** tool to collect:

1. **Command Purpose**:
   - "What is the primary purpose of this command?"
   - Options: "Analyze/Research", "Plan/Design", "Execute/Implement",
     "Review/Validate", "Document/Record"
2. **Scope Type**:
   - "Does this command need multiple execution modes?"
   - Options: "Single mode (straightforward)", "Multi-scope (like quick/thorough,
     or different focus areas)"
3. **Agent Requirements**:
   - "Which agents should this command consult?"
   - Multi-select from: research-agent, architecture-agent, logseq-agent,
     feature-planner, elixir-reviewer, etc.
4. **Output Location**:
   - "Where should command output be stored?"
   - Options: "projects/[project]/[topic]", "claude/memories/",
     "docs/[section]", "Custom location"

### Step 2: Build Command Definition

Use **logseq-agent** (via Task tool) to create command definition at
`claude/commands/[command-name]`:

**Required sections:**

```markdown
type:: command-definition category:: [from user input] scope:: [global|project]
tags:: [relevant-tags]

# [Command Name]

## Overview

[Purpose and when to use this command]

## Command Syntax

/do [command-name] [scope-if-applicable] [topic/arguments]

**Examples:**

- `/do [command-name] [example-input]`

## Prerequisites

- [List required setup, tools, or context]

## Workflow Steps

### Step 1: [Step Name]

[Detailed instructions]

### Step 2: [Step Name]

[Detailed instructions]

## Agent Consultations

- **[agent-name]**: [Why and when to consult]

## Tool Usage

- **[tool-name]**: [How and why to use]

## Output Requirements

**Location**: [where output goes] **Format**: [structure expectations]

## Success Criteria

✅ [Criterion 1] ✅ [Criterion 2]

## Critical Rules

- 🚨 [Important constraint or requirement]

## Related Documentation

- [Links to docs/commands/[name]/ pages]

## Update History

- [YYYY-MM-DD]: Initial creation via /do command creation workflow
```

### Step 3: Create Supporting Documentation

Use **logseq-agent** to create documentation structure at
`docs/commands/[command-name]/`:

1. **instructions** page:
   - Detailed execution instructions
   - Examples and edge cases
   - Troubleshooting guidance
2. **examples** page (optional):
   - Real-world usage examples
   - Sample outputs
3. **patterns** page (optional):
   - Common patterns for this command
   - Best practices

### Step 4: Update Command Registry

Use **logseq-agent** to:

1. Read `claude/commands/index`
2. Add new command to appropriate category section
3. Include brief description and scope information
4. Sort alphabetically within category

### Step 5: Confirm and Execute

1. Show user a summary of what was created:
   - Command definition location
   - Documentation pages created
   - Registry entry added
2. Ask: "Would you like to execute this new command now?"
3. If yes, proceed with Step 2 (Retrieve Command Definition) using the newly
   created command
4. If no, inform user they can run `/do [command-name]` when ready

### Step 6: Store Creation as Memory

Use **logseq-agent** to create memory at
`claude/memories/conversation-insights/command-creation-[command-name]-[date]`:

- Document the command creation context
- User's intent and requirements
- Design decisions made
- Potential improvements identified

## Available Tools

- **Task tool**: Invoke logseq-agent for reading command definitions and writing
  reports
- **TodoWrite**: Track execution progress
- **AskUserQuestion**: Gather clarifications during execution
- **All other tools**: As specified in retrieved command definition

## Integration with Existing Commands

The `/do` command complements file-based commands:

**File-based commands** (`agents/commands/*.md`):

- Fast, local, version-controlled
- Good for stable, core workflows
- Direct invocation via SlashCommand

**LogSeq-based commands** (`claude/commands/*`):

- Dynamic, evolvable, documented
- Good for experimental workflows
- Invocation via `/do [command-name]`

**Both can coexist**: Keep proven commands in files, experiment with new
commands in LogSeq.

## Command Discovery

To see available LogSeq commands:

1. Use logseq-agent to read `claude/commands/index`
2. Or search LogSeq for pages with `type:: command-definition`

## Example Execution Flow

```
User: /do research authentication patterns

Step 1: Parse
→ Command: "research"
→ Prompt: "authentication patterns"

Step 2: Retrieve via logseq-agent
→ Read claude/commands/research
→ Get workflow steps, agent consultations, output format

Step 3: Execute
→ Create todos from workflow steps
→ Follow research command instructions with "authentication patterns" as topic
→ Consult specified agents (research-agent, architecture-agent, etc.)
→ Generate output at projects/[project]/authentication-patterns/research

Step 4: Report via logseq-agent
→ Create claude/command-executions/research/2025-11-14T15-30-00
→ Document execution details, output location, status
```

## Success Criteria

✅ Command name correctly parsed from input ✅ Command definition successfully
retrieved from LogSeq (or created if missing) ✅ Command instructions executed
following workflow steps ✅ Output generated in specified format/location ✅
Execution report saved to LogSeq ✅ User informed of completion and output
location

**For Command Creation:**

✅ User confirmed intent to create new command ✅ Command details gathered
interactively ✅ Command definition created at `claude/commands/[name]` ✅
Supporting documentation structure created at `docs/commands/[name]/` ✅ Command
registry index updated ✅ Creation memory stored for future reference ✅ User
offered option to execute new command immediately

## Notes

- This command enables **data-driven workflows** where command logic lives in
  LogSeq
- Commands can be updated via logseq-agent without touching the filesystem
- **Interactive command creation** allows users to rapidly prototype new workflows
  without manual template creation
- Execution history provides valuable analytics on command usage
- Failed executions help improve command definitions over time
- New commands automatically include documentation structure and registry
  integration
