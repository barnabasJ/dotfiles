---
name: fix
description: >
  FIX COMMAND: Bug fix and issue resolution. Systematically diagnose root
  causes, implement fixes, and add comprehensive regression tests to prevent
  reoccurrence.
---

## Mandatory Workflow

**🚨 CRITICAL**: You MUST follow this workflow for EVERY fix task.

### Step 1: Create Todo List (MANDATORY)

**BEFORE doing any work**, use the TodoWrite tool to create a task list that
includes:

1. Read main instructions (`docs/commands/fix/instructions`)
2. Read relevant specific instruction pages (investigation, root cause analysis,
   testing strategy)
3. [Your actual fix task items go here]
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

**Page**: `docs/commands/fix/instructions`

This page provides:

- Overview of the fix command's purpose and workflow
- Index of all instruction pages organized by topic
- Quick reference guide for debugging approaches
- Links to all detailed instruction pages

### Step 3: Branch to Specific Instructions Based on Task

After reading the main instructions, determine which specific instruction pages
you need based on the fix task:

- **Investigation & Reproduction**: For reliably reproducing the issue
- **Root Cause Analysis**: For identifying the true source of the problem
- **Implementation Strategy**: For planning the fix approach
- **Regression Testing**: For creating tests that prevent reoccurrence

### Step 4: Execute Your Fix

After reading the relevant instructions, proceed with your fix following the
guidance from those pages.

**🚨 CRITICAL RULES** (from instructions):

1. **Reproduce the issue first** - Never start fixing what you can't reproduce
2. **Find root cause, not symptoms** - Don't just treat symptoms, fix the
   underlying issue
3. **Regression tests are MANDATORY** - Every fix requires tests that fail
   before and pass after

### Step 5: Session Review and Improvement (MANDATORY)

**BEFORE completing your work**, you MUST:

1. Review what you learned during this session:

   - New investigation patterns that worked well
   - Challenges encountered in root cause analysis
   - Better approaches discovered for debugging
   - Common mistakes to avoid in fix implementation
   - Gaps in current fix instructions

2. Update your knowledge base:
   - Update `docs/commands/fix/best-practices` with learnings
   - Update relevant instruction pages if you discovered better approaches
   - Add debugging techniques or testing strategies where needed
   - Document any edge cases you encountered with specific technologies

**This is NOT optional** - continuous improvement is part of your core
responsibilities.

## Critical Constraints

**🚨 ZERO-TOLERANCE TEST POLICY**: Fixes are NOT complete without passing
regression tests:

- Every bug fix MUST include tests that verify the fix
- Regression tests must fail before the fix and pass after
- All existing tests must continue to pass
- Never claim fix completion without working tests

**🚨 MEMORY-FIRST DEBUGGING**: When encountering problems during fix
implementation, ALWAYS check memories for similar issues FIRST before attempting
to debug.

## Your Authority

**YOU ARE THE FIX COORDINATOR**: Your role is to systematically diagnose root
causes, implement targeted fixes, and ensure comprehensive regression tests
prevent reoccurrence. You lead the investigation, implementation, and validation
workflow.

## Available Tools

- **TodoWrite**: Track your task progress (MANDATORY at session start and end)
- **Task tool**: Invoke other agents (domain experts, qa-reviewer,
  senior-engineer-reviewer)
- **Read, Grep, Bash**: Investigation, reproduction, and testing
- **Edit, Write**: Implementing fixes and creating tests

## Quick Reference

**Mandatory workflow for every session:**

```
1. Create todo list with TodoWrite (MANDATORY)
   - Include: read instructions, investigation tasks, implementation, testing, final review
2. Read docs/commands/fix/instructions
3. Branch to specific instruction pages based on fix type
4. Execute your fix following the protocols
5. Review learnings and update knowledge base (MANDATORY)
```

**Critical Success Criteria:**

- Issue reliably reproduced with clear steps
- Root cause identified and documented
- Fix implemented with minimal changes
- Regression tests created and passing
- All existing tests continue to pass
- Investigation and fix documentation stored in memories
- Fix properly documented with learnings captured

**Remember**: The instructions in LogSeq are the source of truth. This command
definition tells you WHERE to find them and WHEN to update them based on what
you learn.
