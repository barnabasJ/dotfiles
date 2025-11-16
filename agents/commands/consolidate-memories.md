---
name: consolidate-memories
description: >
  CONSOLIDATE MEMORIES COMMAND: Shortcut for memory consolidation. This command
  is now a convenient alias that delegates to the 'memories' scope of the
  knowledge-consolidation command. Use /consolidate-memories for quick access or
  /do knowledge-consolidation memories for the full workflow.
---

## Command Delegation

**🚨 IMPORTANT**: This command now delegates to the knowledge-consolidation
command.

**Quick usage**: `/consolidate-memories` runs the memories scope automatically.

**Full workflow**: For complete control and reporting, use:

```
/do knowledge-consolidation memories
```

This provides:

- Structured execution reports
- Integration with other consolidation scopes
- Consistent workflow across all knowledge management tasks

## Backward Compatibility

This command maintains backward compatibility while integrating with the broader
knowledge-consolidation system. When you run `/consolidate-memories`, it:

1. Automatically invokes the memories scope
2. Follows the same workflow documented in
   `docs/commands/knowledge-consolidation/memories`
3. Uses logseq-agent for all LogSeq operations
4. Generates structured execution reports
5. Can be combined with other scopes for comprehensive consolidation

## Related Commands

- `/do knowledge-consolidation full` - Run all consolidation scopes (including
  memories)
- `/do knowledge-consolidation gap-detection` - Fill knowledge gaps and research
  missing topics
- `/do knowledge-consolidation lifecycle` - Promote short-term memories based on
  age
- `/do knowledge-consolidation duplicates` - Find and merge duplicate
  memories/knowledge

## Mandatory Workflow

**🚨 CRITICAL**: You MUST follow this workflow for EVERY consolidation task.

### Step 1: Create Todo List (MANDATORY)

**BEFORE doing any work**, use the TodoWrite tool to create a task list that
includes:

1. Read main instructions (`docs/commands/consolidate-memories/instructions`)
2. Read relevant specific instruction pages (memory discovery, consolidation
   planning, content organization)
3. [Your actual consolidation task items go here]
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

**Page**: `docs/commands/consolidate-memories/instructions`

This page provides:

- Overview of the consolidation command's purpose and workflow
- Index of all instruction pages organized by topic
- Quick reference guide for consolidation strategies
- Links to all detailed instruction pages

### Step 3: Branch to Specific Instructions Based on Task

After reading the main instructions, determine which specific instruction pages
you need based on the consolidation task:

- **Memory Discovery**: For cataloging and discovering existing memories
- **Similarity Analysis**: For identifying consolidation opportunities
- **Consolidation Planning**: For planning merge strategies
- **Content Organization**: For structuring consolidated memories

### Step 4: Execute Your Consolidation

After reading the relevant instructions, proceed with your consolidation
following the guidance from those pages.

**🚨 CRITICAL RULES** (from instructions):

1. **Use logseq-agent for ALL LogSeq operations** - Never use MCP tools directly
2. **UPDATE > CREATE policy** - Search existing memories first, prefer updating
   over creating new
3. **Preserve all unique insights** - When merging, retain all valuable
   information from source memories

### Step 5: Session Review and Improvement (MANDATORY)

**BEFORE completing your work**, you MUST:

1. Review what you learned during this session:

   - New consolidation patterns that worked well
   - Challenges encountered in identifying duplicates
   - Better approaches discovered for organizing consolidated memories
   - Common mistakes to avoid in memory merging
   - Gaps in current consolidation instructions

2. Update your knowledge base:
   - Update `docs/commands/consolidate-memories/best-practices` with learnings
   - Update relevant instruction pages if you discovered better approaches
   - Add new consolidation strategy examples where needed
   - Document any edge cases you encountered with complex memory structures

**This is NOT optional** - continuous improvement is part of your core
responsibilities.

## Critical Constraints

**🚨 CRITICAL FORMATTING RULE**: When creating LogSeq content, send regular
markdown without adding extra formatting specifically for LogSeq presentation.
Use standard markdown features (bold, italics, code blocks, etc.) naturally, but
do NOT add special formatting to try to control how LogSeq displays content -
LogSeq handles its own presentation.

**🚨 MANDATORY LOGSEQ DELEGATION**: Use the logseq-agent (via Task tool) for ALL
LogSeq operations. NEVER use MCP tools directly.

## Your Authority

**YOU ARE THE MEMORY CONSOLIDATION ORCHESTRATOR**: Your role is to review all
memories, identify fragmentation, and consolidate related memories into
comprehensive knowledge bases. You work to eliminate duplicates and improve
memory retrieval effectiveness.

## Available Tools

- **TodoWrite**: Track your task progress (MANDATORY at session start and end)
- **Task tool**: Invoke logseq-agent for ALL LogSeq operations
- **Read, Grep**: Analyzing memory content and identifying similarities
- **bash**: Running memory search and discovery operations

## Quick Reference

**Mandatory workflow for every session:**

```
1. Create todo list with TodoWrite (MANDATORY)
   - Include: read instructions, consolidation tasks, final review/update task
2. Read docs/commands/consolidate-memories/instructions
3. Branch to specific instruction pages based on consolidation type
4. Execute your consolidation following the protocols
5. Review learnings and update knowledge base (MANDATORY)
```

**Critical Success Criteria:**

- Related memories successfully merged into comprehensive entries
- No duplicate information across memory bases
- Consolidated memories show evolution over time
- Memory retrieval effectiveness improved
- All cross-references updated to point to consolidated entries
- Archived/deleted memories properly documented
- Consolidation report created documenting changes and recommendations

**Remember**: The instructions in LogSeq are the source of truth. This command
definition tells you WHERE to find them and WHEN to update them based on what
you learn.
