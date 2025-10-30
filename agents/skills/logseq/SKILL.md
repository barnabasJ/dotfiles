---
name: logseq
description:
  Create and format content for LogSeq's outliner-based system. Use when
  creating LogSeq pages, formatting content for LogSeq, or working with LogSeq's
  block-based structure.
---

# LogSeq Formatting Skill

## Overview

LogSeq is an **outliner-first** tool, not a traditional document editor.
Everything must be structured as nested bullet points (blocks). This skill
provides the knowledge to create properly formatted LogSeq pages.

## Critical Rules

### 1. Block-Based Structure

- **Every content line** must start with a hyphen (`-`)
- **Exception**: Page properties at the top (no hyphens)
- Each line is a separate block
- Nesting uses indentation (2 spaces per level)

### 2. Page Properties

Place at the **very top** of the page with **NO leading hyphens**:

```markdown
title:: Page Title description:: Brief description tags:: tag1, tag2, tag3
status:: active priority:: high created:: [[2025-10-30]]

- First content block starts here
```

**Property syntax**:

- Format: `key:: value`
- Double colon (`::`) required
- Single space after `::`
- NO spaces before key
- NO leading hyphens for page properties

### 3. Content Blocks

All content must use bullets:

```markdown
- First level block
  - Second level (2 spaces indent)
    - Third level (4 spaces indent)
- Another first level block
```

### 4. Headings in LogSeq

Headings need leading hyphens:

```markdown
❌ WRONG:

# Heading

✅ CORRECT:

- # Heading
  - ## Sub-heading
    - ### Sub-sub-heading
```

### 5. Code Blocks

Code blocks must be within a block:

````markdown
- Code example:
  ```python
  def hello():
      print("Hello")
  ```
- More content
````

### 6. TODO Items

```markdown
- TODO Task description
  - Subtask details
- DOING Active task
- DONE Completed task
```

## Common Pitfalls to Avoid

### Pitfall 1: Missing Leading Hyphens

```markdown
❌ WRONG: This is a paragraph

✅ CORRECT:

- This is a paragraph
```

### Pitfall 2: Page Properties with Bullets

```markdown
❌ WRONG:

- title:: My Page
- description:: Description

✅ CORRECT: title:: My Page description:: Description

- First content block
```

### Pitfall 3: Traditional Markdown Structure

```markdown
❌ WRONG:

# Heading

Paragraph 1.

Paragraph 2.

✅ CORRECT:

- # Heading
- Paragraph 1.
- Paragraph 2.
```

### Pitfall 4: Multiple Headings or Lists in One Block

```markdown
❌ WRONG (causes LogSeq errors):

- # Section 1
  ## Subsection
  - Point 1
  - Point 2

✅ CORRECT:

- # Section 1
  - ## Subsection
  - Point 1
  - Point 2
```

### Pitfall 5: Deep Nesting Issues

- Keep nesting to 3-4 levels maximum
- Excessive nesting causes export problems
- Use page links `[[Page Name]]` instead of deep hierarchies

## Template for Issue/Bug Tracking

```markdown
title:: Issue [number] [short-name] status:: planning type:: bug-fix priority::
medium github:: [url] created:: [[YYYY-MM-DD]]

- **Problem**: Brief problem statement with context. Explain what's happening
  and why it's an issue. Include any user impact or confusion caused by the bug.
- **Current Behavior**: Description of what happens now, including the specific
  error message or symptom. Mention where in the code this occurs and any
  relevant call stack information.
  - Error message: "Exact error text here"
  - Source location: `path/to/file.ex` line X
  - Call path if relevant
- **Expected Behavior**: Clear description of what should happen instead.
  Include any suggestions from users or the issue reporter about better error
  messages or behavior.
- **Investigation Questions**
  - Why does X happen when we expect Y?
  - What other similar patterns exist in the codebase?
  - Are there related issues or previous discussions?
- **Files to Examine**
  - `path/to/file.ex` (lines X-Y) - Main logic
  - `path/to/error.ex` (line Z) - Error generation
  - `test/relevant_test.exs` - Related tests
- **Implementation Tasks**
  - TODO Fix the core issue (specific description)
  - TODO Update error messages to be clear and helpful
  - TODO Add test coverage for this scenario
  - TODO Verify all existing tests still pass
- **Success Criteria**
  - Error message accurately reflects the operation
  - Behavior matches expected outcome
  - All tests pass including new coverage
- **Notes**: Any important context, related discussions, or considerations that
  don't fit elsewhere.
```

## Template for Feature Planning

```markdown
title:: Feature [feature-name] status:: planning type:: feature priority:: high
created:: [[YYYY-MM-DD]]

- **Overview**: What this feature does
- **Motivation**: Why we need it
  - User pain point addressed
  - Business value
- **Requirements**
  - TODO Functional requirement 1
  - TODO Functional requirement 2
- **Technical approach**
  - Architecture decision 1
    - Reasoning behind decision
  - Architecture decision 2
- **Implementation tasks**
  - TODO Task 1
    - Subtask details
  - TODO Task 2
- **Testing strategy**
  - Unit test requirements
  - Integration test requirements
- **Success criteria**
  - Measurable outcomes
```

## Block References and Links

### Page Links

```markdown
- See [[Related Page]] for details
- Reference [[Another Topic]]
```

### Block IDs (for references)

```markdown
- Important concept id:: 60ab7486-8119-4c9a-888c-1e6213fd28e0
- Reference it: ((60ab7486-8119-4c9a-888c-1e6213fd28e0))
```

## Inline Properties

```markdown
- [[title::Book Title]] by [[author::Author Name]]
- Reading [[book::The Pragmatic Programmer]] [[status::in-progress]]
```

## Block Granularity: One Thought, Not One Sentence

**Critical Principle**: Blocks should represent **atomic ideas or logical
units**, not individual sentences.

### When to Use Multi-line Blocks

Related sentences that explain a single concept should stay together:

```markdown
- **Problem**: When using manage_relationship with type remove on a non-existent
  relationship member, the error message incorrectly states "changes would
  create a new related record". This is misleading because we're trying to
  REMOVE a relationship, not CREATE one.
```

**NOT** over-fragmented like this:

```markdown
❌ AVOID:

- Problem is with manage_relationship
- It uses type remove
- On non-existent relationship member
- Error message is wrong
- Says "changes would create a new related record"
- This is misleading
- We are trying to REMOVE
- Not CREATE
```

### When to Use Separate Blocks

Create separate blocks for:

- **Distinct, independent ideas** that can be referenced separately
- **Action items** that need individual tracking
- **List items** where each deserves its own reference point
- **Different aspects** of a topic in a hierarchical structure

### Good Block Organization Example

```markdown
- **Current Behavior**: The error originates from
  `lib/ash/error/changes/invalid_relationship.ex:4` and goes through the call
  stack: `Ash.Actions.ManagedRelationships.do_handle_create/8` then
  `handle_input/10`. The function naming suggests it's going through "create"
  logic even though we're doing a "remove" operation.
  - Error message: "Invalid value provided for organization_members: changes
    would create a new related record"
  - Source file: `lib/ash/error/changes/invalid_relationship.ex` line 4
  - Call path: `do_handle_create/8` (line 1227) → `handle_input/10` (line 845)
```

### Poor Block Organization Example

```markdown
❌ TOO FRAGMENTED:

- Current Behavior
  - Error originates from file
  - lib/ash/error/changes/invalid_relationship.ex
  - Line 4
  - Goes through call stack
  - First Ash.Actions.ManagedRelationships.do_handle_create/8
  - Then handle_input/10
  - Function naming suggests create logic
  - Even though we are doing remove
```

## Best Practices

1. **One thought per block**: Related sentences explaining a single idea stay
   together
2. **Multi-line blocks are normal**: Don't split every sentence into separate
   blocks
3. **Consistent indentation**: Use 2 spaces per level
4. **Shallow hierarchies**: Avoid nesting beyond 3-4 levels
5. **Descriptive titles**: Make page titles searchable
6. **Liberal linking**: Use `[[page links]]` to connect concepts
7. **Properties for metadata**: Use page properties for tags, status, dates
8. **TODO for tracking**: Mark actionable items with TODO/DOING/DONE
9. **Context matters**: Keep explanatory text together for better understanding

## When Creating Pages Programmatically

Follow this checklist:

1. ✅ Start with page properties (no hyphens)
2. ✅ Add blank line after properties
3. ✅ All content as bullets with `-`
4. ✅ Use 2-space indentation for nesting
5. ✅ Headings have leading `-`
6. ✅ Code blocks within bullet points
7. ✅ Keep nesting shallow (3-4 levels max)
8. ✅ No multiple markdown headings in single block
9. ✅ One unordered list per block level

## Complete Working Example

````markdown
title:: Example Page Structure status:: active tags:: example, template
created:: [[2025-10-30]]

- # Main Topic
- This is a description of the main topic
- ## Key Concepts
  - **Concept 1**: Description here
    - Supporting detail
    - Another detail
  - **Concept 2**: Description here
- ## Implementation
  - Code example:
    ```elixir
    def example do
      :ok
    end
    ```
  - Explanation follows
- ## Tasks
  - TODO First task
    - Subtask detail
  - DOING Active task
  - DONE Completed task
- ## References
  - See [[Related Topic]]
  - External link: [Documentation](https://example.com)
````

## Remember

- LogSeq is an **outliner**, not a document editor
- Think in **blocks** (bullet points), not paragraphs
- **Properties first** (no bullets), **content second** (all bullets)
- **Simple structure** beats complex nesting
- When in doubt, use more blocks with less nesting
