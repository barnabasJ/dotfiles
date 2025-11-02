# Implementation Execution

**CRITICAL**: You are now executing the implementation. Work through the
detailed task breakdown systematically, consulting agents for guidance and
expertise as needed.

## Your Role as Implementation Lead

You are responsible for implementing the detailed task breakdown while
consulting specialized agents for guidance. Your primary responsibility is to
follow the checklist methodically while ensuring quality through expert
consultation.

## Core Approach

### **🚨 MANDATORY: Memory-First Execution**

**CRITICAL RULE**: Check memories BEFORE attempting to solve ANY problem you
encounter during execution.

**When to check memories (MANDATORY triggers):**

- ❌ **Hit an error or failure** → STOP → Search memories FIRST
- ❌ **Encounter unfamiliar API/syntax** → STOP → Search memories FIRST
- ❌ **Face configuration issue** → STOP → Search memories FIRST
- ❌ **Test failures** → STOP → Search memories FIRST
- ❌ **Build/deployment errors** → STOP → Search memories FIRST
- ❌ **Performance problems** → STOP → Search memories FIRST

**Memory search strategy for problems:**

1. Query memory-agent with the error message or problem description
2. Search hard-won-knowledge category first
3. Check technical patterns for the specific technology
4. Look for project-specific solutions

**After solving difficult problems (MANDATORY):**

- ✅ IMMEDIATELY store the solution in memories
- ✅ Document what didn't work and why
- ✅ Capture the working solution
- ✅ Note how to recognize the problem faster next time

**Simple Execution Model:**

1. **FIRST: Check memories** for similar implementation work and known
   challenges
2. Read the breakdown checklist from LogSeq page
   `projects/[project]/[topic]/breakdown`
3. Work through each numbered task sequentially
4. Consult relevant agents for guidance on specific tasks
5. Complete each subtask following the specifications
6. **Mark subtasks as completed in breakdown page** (change `[ ]` to `[x]`)
7. **Mark the main task as completed in breakdown page** (change `1. [ ]` to
   `1. [x]`)
8. Commit changes as specified in the breakdown (includes both code and
   progress)
9. Continue to next task

### **Determining Project Name**

Use the git repository name as the project identifier:

```bash
basename $(git rev-parse --show-toplevel)
```

### **Updating Progress in LogSeq**

Use ash-logseq MCP server tools to update the breakdown page with completed
tasks:

```elixir
# 1. Get page blocks to find the breakdown content
# Using logseq_api tool from ash-logseq MCP server
page_blocks = mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getPageBlocksTree",
    "args": ["projects/[project]/[topic]/breakdown"]
  }
)

# 2. Find the specific block UUID for the task you completed
# (from the page_blocks response)

# 3. Update the block content with checked checkbox: [ ] → [x]
# Using logseq_api tool from ash-logseq MCP server
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.updateBlock",
    "args": [
      "block-uuid-here",
      "#### 1. [x] Task name\n1.1. [x] Subtask 1\n1.2. [x] Subtask 2"
    ]
  }
)
```

**Note**: See `/home/joba/.claude/skills/logseq/SKILL.md` for comprehensive MCP
tool documentation and detailed block update patterns.

## Primary Responsibilities

### **Task Execution**

- Follow the detailed breakdown checklist systematically
- Implement each task according to specifications
- Use file references and documentation links provided
- **Update breakdown page progress in real-time** by marking completed items in
  LogSeq
- Make commits as specified after completing each numbered task

### **Agent Consultation**

- Consult appropriate agents for guidance on specific tasks:
  - Ask about implementation patterns (elixir skill provides Elixir/Phoenix
    implementation patterns)
  - **architecture-agent** for code placement and structure decisions
  - **domain experts** for testing requirements and TDD/BDD guidance
  - **domain experts** as needed for specialized knowledge

### **Quality Assurance**

- Follow testing requirements specified in each task
- Ensure code follows established patterns and conventions
- Run all review agents after significant milestones for quality validation

## Execution Process

### **Step 1: Load Context and Breakdown**

**Full Context Review:**

- Read LogSeq page `projects/[project]/[topic]/research` for codebase impact
  analysis and existing patterns
- Read LogSeq page `projects/[project]/[topic]/plan` for strategic
  implementation approach
- Read LogSeq page `projects/[project]/[topic]/breakdown` for detailed task
  checklist

**Why review all phases:**

- **Research** provides file locations, existing patterns, and documentation
  links
- **Plan** explains the strategic approach and architectural decisions
- **Breakdown** gives step-by-step tasks with specific file references

- Understand the full scope and task structure
- Identify any dependencies or prerequisites

### **Step 2: Sequential Implementation**

- Start with task 1 and work through sequentially
- For each task:
  1. Read the task specifications and subtasks
  2. Consult relevant agents if guidance is needed
  3. Implement the required changes following the specifications
  4. **Mark each subtask as completed** in breakdown page (change `1.1. [ ]` to
     `1.1. [x]`) using LogSeq update_page
  5. Complete all subtasks for the numbered item
  6. **Mark the main task as completed** in breakdown page (change `1. [ ]` to
     `1. [x]`) using LogSeq update_page
  7. Commit with the suggested commit message (includes both code and progress)

### **Step 3: Quality Gates**

- After completing significant milestones (multiple related tasks)
- Run relevant review agents to validate implementation quality
- Address any issues identified before continuing

## Agent Consultation Patterns

**When to consult agents:**

- Ask about code patterns (elixir skill provides guidance when implementing
  Elixir/Phoenix/Ash code)
- **architecture-agent**: When unsure about file placement or module
  organization
- **domain experts**: When implementing tests or following TDD/BDD requirements
- **domain experts**: For specialized knowledge areas

**How to consult:**

- Ask specific questions about implementation approaches
- Request pattern guidance for the current codebase
- Validate architectural decisions
- Get testing strategy guidance

## Four-Phase Workflow Integration

This is the **execution phase** of the four-phase workflow:

1. **research** - Comprehensive research (completed)
2. **plan** - Strategic implementation planning (completed)
3. **breakdown** - Detailed task breakdown (completed)
4. **execute** ← _You are here_

## Prerequisites

### **Required Before Execution**

- LogSeq page `projects/[project]/[topic]/breakdown` must exist with detailed
  task checklist
- Previous phases (research, plan) completed for context
- Understanding of the implementation requirements

## Success Criteria

Execution phase is complete when:

- All tasks in the breakdown checklist are completed
- All specified commits have been made
- Code follows established patterns and passes quality checks
- Implementation meets the original requirements
- All review agents validate the final implementation

## Example Execution Flow

```
1. Read LogSeq pages for full context:
   - projects/my-project/my-feature/research (patterns, file locations)
   - projects/my-project/my-feature/plan (strategic approach)
   - projects/my-project/my-feature/breakdown (task checklist)
2. Start with Task 1: "Add User Authentication Resource"
   - Ask about Ash resource patterns (elixir skill provides Ash resource
     guidance)
   - Implement subtask 1.1, mark as [x] in breakdown page
   - Implement subtask 1.2, mark as [x] in breakdown page
   - Implement subtask 1.3, mark as [x] in breakdown page
   - Mark Task 1 as [x] completed in breakdown page
   - Commit: "feat(auth): add user authentication resource" (includes code + progress)
3. Continue with Task 2: "Configure OAuth Integration"
   - Follow file references and documentation links
   - Implement subtask 2.1, mark as [x] in breakdown page
   - Implement subtask 2.2, mark as [x] in breakdown page
   - Implement subtask 2.3, mark as [x] in breakdown page
   - Mark Task 2 as [x] completed in breakdown page
   - Commit: "feat(oauth): configure OAuth provider integration" (includes code + progress)
4. After completing 3-4 related tasks, run review agents for validation
5. Continue until all tasks completed
```

The **execute** command transforms detailed planning into working implementation
by following the breakdown systematically while leveraging agent expertise for
guidance and quality assurance.
