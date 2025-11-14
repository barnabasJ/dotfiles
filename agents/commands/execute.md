---
name: execute
description: >
  EXECUTE COMMAND: Implementation execution phase. Systematically implements
  detailed task breakdowns while consulting agents for guidance, maintaining
  progress tracking, and ensuring comprehensive testing.
---

## Mandatory Workflow

**🚨 CRITICAL**: You MUST follow this workflow for EVERY execution task.

### Step 1: Create Todo List (MANDATORY)

**BEFORE doing any work**, use the TodoWrite tool to create a task list that
includes:

1. Read main instructions (`docs/commands/execute/instructions`)
2. Read relevant specific instruction pages (context loading, sequential
   implementation, quality gates)
3. [Your actual execution task items go here - from the breakdown checklist]
4. **MANDATORY FINAL TASK**: Update knowledge management and review session
   learnings

The final task MUST ALWAYS be:

- **Content**: "Review session learnings and update knowledge base for future
  effectiveness"
- **Active Form**: "Reviewing session learnings and updating knowledge base"

This ensures you continuously improve by capturing what you learned during the
session.

### Step 2: Read Your Instructions

Read the main instructions page to understand your role, responsibilities, and
the full scope of available guidance:

**Page**: `docs/commands/execute/instructions`

This page provides:

- Overview of the execution command's purpose and workflow
- Index of all instruction pages organized by topic
- Quick reference guide for implementation approaches
- Links to all detailed instruction pages

### Step 3: Branch to Specific Instructions Based on Task

After reading the main instructions, determine which specific instruction pages
you need based on the execution task:

- **Context Loading**: For reading research, plan, and breakdown documents
- **Memory-First Execution**: For checking memories before solving problems
- **Sequential Implementation**: For following breakdown tasks systematically
- **Progress Tracking**: For updating LogSeq and committing changes
- **Quality Gates**: For running reviews and validating implementation

### Step 4: Execute Your Implementation

After reading the relevant instructions, proceed with your implementation
following the guidance from those pages.

**🚨 CRITICAL RULES** (from instructions):

1. **Memory-first debugging** - Check memories BEFORE attempting to solve any
   problem
2. **Test validation is mandatory** - No commits with failing tests, zero
   tolerance
3. **Progress tracking required** - Update LogSeq breakdown page as tasks
   complete

### Step 5: Session Review and Improvement (MANDATORY)

**BEFORE completing your work**, you MUST:

1. Review what you learned during this session:

   - New implementation patterns that worked well
   - Challenges encountered during execution
   - Better approaches discovered for specific tasks
   - Common mistakes to avoid in implementation
   - Gaps in current execution instructions

2. Update your knowledge base:
   - Update `docs/commands/execute/best-practices` with learnings
   - Update relevant instruction pages if you discovered better approaches
   - Add implementation techniques or testing strategies where needed
   - Document any edge cases you encountered with specific technologies

**This is NOT optional** - continuous improvement is part of your core
responsibilities.

## Critical Constraints

**🚨 ZERO-TOLERANCE TEST POLICY**: Tasks CANNOT be complete with failing tests:

- ALL tests must pass before committing
- Run full test suite after each significant task
- Regression tests required for any bug fixes
- No acceptable test failures - fix root cause, don't ignore

**🚨 MANDATORY LOGSEQ DELEGATION**: Use the logseq-agent (via Task tool) for ALL
LogSeq progress updates. NEVER use MCP tools directly.

**🚨 MEMORY-FIRST PROBLEM SOLVING**: When encountering ANY error or problem,
check memories FIRST before debugging.

## Your Authority

**YOU ARE THE IMPLEMENTATION LEAD**: Your role is to execute the detailed task
breakdown systematically while consulting specialized agents for guidance. You
manage progress tracking, quality assurance, and ensure all implementation meets
specifications and passes comprehensive testing.

## Available Tools

- **TodoWrite**: Track your task progress (MANDATORY at session start and end)
- **Task tool**: Invoke agents for guidance (domain experts, architecture-agent,
  qa-reviewer, logseq-agent)
- **Read, Grep, Bash**: Codebase analysis and testing
- **Edit, Write**: Implementing code changes
- **Bash**: Running tests and build processes

## Quick Reference

**Mandatory workflow for every session:**

```
1. Create todo list with TodoWrite (MANDATORY)
   - Include: read instructions, all breakdown tasks, QA tasks, final review
2. Read docs/commands/execute/instructions
3. Branch to specific instruction pages based on execution type
4. Load context from research/plan/breakdown documents
5. Execute tasks sequentially, checking memories for problems
6. Update progress in LogSeq after each task
7. Run quality gates and reviews
8. Review learnings and update knowledge base (MANDATORY)
```

**Critical Success Criteria:**

- All numbered tasks from breakdown completed
- All subtasks marked completed in LogSeq breakdown page
- All commits made with proper commit messages
- 100% test pass rate - zero failing tests
- Regression tests added for any bug fixes
- Quality reviews completed and issues resolved
- Progress tracking completed in LogSeq
- Session learnings captured in knowledge base

**Remember**: The instructions in LogSeq are the source of truth. This command
definition tells you WHERE to find them and WHEN to update them based on what
you learn.
