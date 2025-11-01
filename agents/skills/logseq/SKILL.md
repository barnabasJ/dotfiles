---
name: logseq
description: LogSeq usage
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
- 🚨 **NO BLANK LINE between properties and first content block** - this is
  critical to avoid empty blocks

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

### Pitfall 6: Empty Block at Top (CRITICAL)

```markdown
❌ WRONG (creates empty block): title:: My Page status:: active

- First content block

✅ CORRECT (no empty block): title:: My Page status:: active

- First content block
```

**Why This Matters:**

- Blank line between properties and first content creates an unwanted empty
  block
- Empty blocks clutter the outline view
- Properties should flow directly into first content block with NO blank line
- This is the most common mistake when programmatically creating pages

### Pitfall 7: Hashtags Create Pages (CRITICAL)

```markdown
❌ WRONG (creates unwanted page):

- # Issue #379: Bug Fix
- Fixed bug #123

✅ CORRECT (external link, no page):

- # [Issue #379](https://github.com/org/repo/issues/379): Bug Fix
- Fixed bug \#123 (escaped hashtag)
- Fixed [bug #123](https://github.com/org/repo/issues/123) (link)
```

**Why This Matters:**

- **Hashtags (`#tag`) and page links (`[[page]]`) are identical in LogSeq** -
  both create page references
- `#379` automatically creates a page named "379" in your graph
- `#[[issue-379]]` creates a page named "issue-379"
- This clutters your graph with unwanted pages for issue numbers, IDs, etc.
- Use external markdown links `[label](URL)` for GitHub/Jira issues
- Use backslash escape `\#379` to prevent page creation (backslash invisible in
  view)
- Use backticks `` `#379` `` to format as code (also prevents linking)

**When to use hashtags vs page links:**

- `#tag` - For intentional tags (looks like a tag visually)
- `[[Page Name]]` - For intentional page references (looks like regular text)
- `[External Link](URL)` - For external resources (GitHub, Jira, web)
- `\#escaped` - When you need hashtag symbol without creating page

**External issue reference patterns:**

```markdown
// GitHub issue [Issue #379](https://github.com/org/repo/issues/379)
[GH-379](https://github.com/org/repo/issues/379)

// Jira issue [PROJ-5544](https://company.atlassian.net/browse/PROJ-5544)

// Escaped reference (no link) Issue \#379 was fixed in commit abc123
```

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

## Creating Structured Content: Phase Blocks vs. Item Blocks

**CRITICAL PATTERN**: When creating structured documents (like breakdowns,
research findings, or implementation plans), think in **phases/sections**, not
individual items.

### The Right Approach: Phase Blocks

Create **one block per logical phase/section** with multi-line formatted
content:

```markdown
- ## Phase 1: Foundation Setup

  1. [ ] **Create base resource structure** 1.1. [ ] Define Ash resource in
         `lib/app/accounts/user.ex` 1.2. [ ] Add required attributes (email,
         name, password_hash) 1.3. [ ] Configure data layer with ash_postgres
         1.4. [ ] Run tests: `mix test` 1.5. [ ] Verify all tests pass before
         commit 📝 **Commit**:
         `feat(accounts): add user resource with authentication fields`

  2. [ ] **Configure authentication** 2.1. [ ] Add ash_authentication to mix.exs
         2.2. [ ] Set up password strategy in user resource 2.3. [ ] Create
         authentication configuration 2.4. [ ] Run tests: `mix test` 2.5. [ ]
         Verify all tests pass before commit 📝 **Commit**:
         `feat(auth): configure password authentication strategy`

- ## Phase 2: Integration Layer
  [More structured content here...]
```

**Why this works:**

- ✅ One API call per phase (efficient)
- ✅ Entire phase is atomic (all or nothing)
- ✅ Easy to update the whole phase at once
- ✅ Natural organization matches workflow structure

### The Wrong Approach: Individual Item Blocks

❌ **DON'T create separate blocks for every subtask:**

```markdown
❌ INEFFICIENT AND ERROR-PRONE:

- ## Phase 1: Foundation Setup
  - Task 1: Create base resource
    - Subtask 1.1: Define resource
    - Subtask 1.2: Add attributes
    - Subtask 1.3: Configure data layer
  - Task 2: Configure authentication
    - Subtask 2.1: Add dependency
    - Subtask 2.2: Set up strategy
```

**Why this is wrong:**

- ❌ Requires many separate API calls
- ❌ Partial failures leave incomplete structure
- ❌ Harder to maintain consistency
- ❌ More complex to update
- ❌ Violates "one thought per block" principle

### When to Use Phase Blocks

Use phase blocks with multi-line content for:

- **Workflow checklists**: Breakdown tasks with numbered steps
- **Research findings**: Sections with multiple points
- **Implementation plans**: Phases with detailed steps
- **Documentation**: Sections with related content
- **Structured procedures**: Step-by-step processes

### When to Use Separate Blocks

Use separate blocks only when:

- **Independent tracking**: Each item needs its own TODO/DONE state at top level
- **Individual reference**: Each block might be referenced elsewhere
- **Different concepts**: Blocks represent truly distinct ideas
- **Hierarchical organization**: Building a knowledge structure, not a procedure

### Examples: Workflows

**Creating Research Findings** (One block per section):

```markdown
- ## Codebase Impact Analysis

  **Files Requiring Changes:**

  - `lib/app/accounts/user.ex:45` - Add email validation
  - `lib/app/accounts/user.ex:89` - Update create action
  - `lib/app_web/router.ex:23` - Add authentication routes

  **Existing Patterns Found:**

  - Authentication: Project uses AshAuthentication 4.0.2
  - Pattern in `lib/app/accounts/user.ex:12-45` shows resource setup
  - Tests follow pattern in `test/app/accounts/user_test.exs`

- ## Third-Party Integrations
  **Stripe Payment Processing:**
  - Integration type: Subscription billing
  - Current status: Not found in codebase (NEW)
  - SDK needed: stripity_stripe
  - Docs: [Stripe Subscriptions API](...)
```

**Creating Breakdown Checklists** (One block per phase):

```markdown
- ## Phase 1: Database and Resource Setup

  1. [ ] **Create payment resource** 1.1. [ ] Create file
         `lib/app/payments/payment.ex` 1.2. [ ] Add attributes: amount,
         currency, status, stripe_id 1.3. [ ] Configure ash_postgres data layer
         1.4. [ ] Run tests: `mix test test/app/payments/payment_test.exs` 1.5.
         [ ] Verify all tests pass 📝 **Commit**:
         `feat(payments): add payment resource with Stripe fields`

  2. [ ] **Create database migration** 2.1. [ ] Generate migration:
         `mix ash_postgres.generate_migrations` 2.2. [ ] Review migration file
         for correctness 2.3. [ ] Run migration: `mix ecto.migrate` 2.4. [ ] Run
         tests: `mix test` 2.5. [ ] Verify all tests pass 📝 **Commit**:
         `feat(payments): add payment table migration`
```

### MCP API Usage for Phase Blocks

Create an entire phase in a single API call:

```elixir
# ✅ CORRECT: Create entire phase block at once
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.insertBlock",
    "args": [
      "parent-block-uuid",
      "## Phase 1: Foundation\n\n1. [ ] **Task One**\n1.1. [ ] Subtask\n1.2. [ ] Another subtask\n\n2. [ ] **Task Two**\n2.1. [ ] Subtask",
      {"sibling": false}
    ]
  }
)

# ❌ WRONG: Don't make separate calls for each subtask
# Multiple insertBlock calls for 1.1, 1.2, 2.1, etc. (inefficient!)
```

## Best Practices

1. **Think in phases/sections, not items**: When creating structured content
   (breakdowns, plans, research), create one block per phase with multi-line
   content, not separate blocks for every subtask (see "Creating Structured
   Content" section)
2. **One thought per block**: Related sentences explaining a single idea stay
   together
3. **Multi-line blocks are normal**: Don't split every sentence into separate
   blocks
4. **Consistent indentation**: Use 2 spaces per level
5. **Shallow hierarchies**: Avoid nesting beyond 3-4 levels
6. **Descriptive titles**: Make page titles searchable
7. **Liberal linking**: Use `[[page links]]` to connect concepts
8. **Properties for metadata**: Use page properties for tags, status, dates
9. **TODO for tracking**: Mark actionable items with TODO/DOING/DONE at the top
   level, not for every substep in a procedure
10. **Context matters**: Keep explanatory text together for better understanding

### When to Create Separate Blocks vs. Multi-line Content

**Use SEPARATE BLOCKS for:**

- Top-level phases or major sections
- Independent concepts that need individual references
- Different aspects of a knowledge structure
- Items that need their own TODO/DONE state

**Use MULTI-LINE CONTENT within ONE BLOCK for:**

- Numbered task checklists with substeps (1.1, 1.2, etc.)
- Related implementation steps in a procedure
- Multiple points explaining a single concept
- Sequential steps that belong to the same phase

**Example of correct approach:**

```markdown
- ## Phase 1: Setup (ONE BLOCK)

  1. [ ] First task 1.1. [ ] Subtask 1.2. [ ] Another subtask
  2. [ ] Second task 2.1. [ ] Subtask

- ## Phase 2: Implementation (SEPARATE BLOCK)
  1. [ ] Implementation task 1.1. [ ] Details
```

## Working with LogSeq MCP Server

### Overview

The LogSeq MCP server provides several tools for working with LogSeq
programmatically via the Model Context Protocol (MCP). These tools range from a
generic API wrapper to specialized convenience tools for common operations.

### Available MCP Tools

#### **1. mcp**ash-logseq**logseq_api** (Generic API - Most Flexible)

The primary tool that provides access to the complete LogSeq HTTP API. Use this
for operations not covered by specialized tools or when you need full control.

#### **2. mcp**ash-logseq**read_page** (Convenience - Reading)

Simplified tool to read a LogSeq page and render it as clean markdown. Easier
than using the generic API for page reading.

**When to use**: Reading page content for analysis, extracting information, or
displaying content.

#### **3. mcp**ash-logseq**create_page** (Convenience - Creating)

Simplified tool to create a LogSeq page from markdown content. Wrapper around
the generic API's createPage method.

**When to use**: Creating new pages with markdown content.

#### **4. mcp**ash-logseq**search_blocks** (Specialized - Searching)

Search for blocks containing specific content across the LogSeq graph with
enriched metadata.

**When to use**: Finding specific blocks, searching for content, discovering
related information.

#### **5. mcp**ash-logseq**replace_line** (Specialized - Bulk Updates)

Replace line content in LogSeq page blocks recursively. Powerful tool for bulk
content updates.

**When to use**: Updating multiple blocks with the same pattern, refactoring
content, fixing repeated issues.

### Tool Selection Guide

**Choose the right tool for your task:**

| Task                 | Recommended Tool | Alternative                             |
| -------------------- | ---------------- | --------------------------------------- |
| Read page content    | `read_page`      | `logseq_api` with `getPageBlocksTree`   |
| Create new page      | `create_page`    | `logseq_api` with `createPage`          |
| Search for content   | `search_blocks`  | `logseq_api` with `search`              |
| Bulk replace content | `replace_line`   | Manual block updates with `updateBlock` |
| Update single block  | `logseq_api`     | `updateBlock` method                    |
| Complex operations   | `logseq_api`     | Full API control                        |

### Critical Input Format Rule (for logseq_api)

**🚨 ALWAYS pass the `input` parameter as a JSON object (map), NEVER as a JSON
string.**

```elixir
✅ CORRECT:
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getPage",
    "args": ["page-name"]
  }
)

❌ WRONG (will cause Protocol.UndefinedError):
mcp__ash-logseq__logseq_api(
  input: "{\"method\": \"logseq.Editor.getPage\", \"args\": [\"page-name\"]}"
)
```

**Why this matters**: The underlying Ash framework expects the `input` to be an
enumerable map. Passing a JSON string causes a
`Protocol.UndefinedError: protocol Enumerable not implemented for type BitString`
error.

### Common MCP Operations

#### Get Current Page

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getCurrentPage",
    "args": []
  }
)
```

#### Get Page by Name

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getPage",
    "args": ["projects/my-project/feature/my-feature"]
  }
)
```

#### Get Block by UUID

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getBlock",
    "args": ["block-uuid-here"]
  }
)

# With children
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getBlock",
    "args": ["block-uuid-here", {"includeChildren": true}]
  }
)
```

#### Update Block Content

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.updateBlock",
    "args": [
      "block-uuid-here",
      "- Updated content\n  - With nesting\n  - More items"
    ]
  }
)
```

**Important for checkbox updates**: You can update checkboxes from `[ ]` to
`[x]`:

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.updateBlock",
    "args": [
      "block-uuid",
      "#### 1. [x] Task completed\n1.1. [x] Subtask 1\n1.2. [x] Subtask 2"
    ]
  }
)
```

#### Insert Block

```elixir
# Insert as child of parent block
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.insertBlock",
    "args": [
      "parent-block-uuid",
      "- New block content",
      {"sibling": false}
    ]
  }
)

# Insert as sibling after block
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.insertBlock",
    "args": [
      "sibling-block-uuid",
      "- New sibling block",
      {"sibling": true}
    ]
  }
)
```

#### Search Pages and Blocks

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.App.search",
    "args": ["search term here"]
  }
)
```

#### Get Page Block Tree

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getPageBlocksTree",
    "args": ["page-name"]
  }
)
```

**⚠️ Warning**: This can return very large responses. If you get a token limit
error, use search or getBlock instead to target specific content.

### Using Convenience Tools (Recommended for Common Operations)

The new specialized tools make common operations much simpler.

#### **Using read_page** (Simplified Page Reading)

Read a LogSeq page and get clean markdown output:

```elixir
mcp__ash-logseq__read_page(
  input: {
    "page_name": "projects/my-project/feature/my-feature"
  }
)

# With pagination for large pages
mcp__ash-logseq__read_page(
  input: {
    "page_name": "projects/my-project/research",
    "from_block": 0,
    "max_blocks": 100
  }
)
```

**Returns**: Clean markdown optimized for LLM consumption with UUIDs and
metadata stripped.

**When to use**: Reading page content for analysis, extracting information, or
when you need clean markdown without LogSeq-specific formatting.

#### **Using create_page** (Simplified Page Creation)

Create a new LogSeq page from markdown content:

```elixir
mcp__ash-logseq__create_page(
  input: {
    "page_name": "projects/my-project/feature/new-feature",
    "content": """
type:: feature
status:: planning
created:: 2025-11-01

- # New Feature Plan
- ## Overview
  - Feature description here
- ## Implementation
  - Step 1
  - Step 2
"""
  }
)
```

**Returns**: Success/failure status with page details.

**When to use**: Creating new planning pages, memory pages, or any new content.

#### **Using search_blocks** (Enhanced Search)

Search for blocks with enriched metadata:

```elixir
mcp__ash-logseq__search_blocks(
  input: {
    "query": "payment processing",
    "max_results": 50,
    "case_sensitive": false
  }
)
```

**Returns**: List of matching blocks with UUIDs, page IDs, block numbers, and
metadata.

**When to use**: Finding specific content, discovering related information, or
locating blocks to update.

#### **Using replace_line** (Bulk Content Updates)

Replace content patterns across multiple blocks:

```elixir
mcp__ash-logseq__replace_line(
  input: {
    "page_id": "projects/my-project/breakdown",
    "changes": [
      {
        "content": "[ ] Task not started",
        "replacement": "[x] Task completed"
      },
      {
        "content": "status:: planning",
        "replacement": "status:: completed"
      }
    ]
  }
)
```

**Returns**: Detailed results with successful updates, failures, and summary
statistics.

**When to use**: Updating task checkboxes, fixing repeated typos, refactoring
content patterns, or bulk status changes.

**⚠️ Warning**: This recursively updates ALL matching blocks in the page. Use
search_blocks first to preview what will be changed.

### MCP Best Practices

1. **Use convenience tools when available**: Prefer `read_page`, `create_page`,
   `search_blocks`, and `replace_line` for common operations over the generic
   API
2. **Always use JSON objects**: Never pass JSON strings to the `input` parameter
3. **Think in phases, not items**: Create one block per logical phase/section
   with multi-line content, not separate blocks for every subtask (see "Creating
   Structured Content" section above)
4. **Handle block UUIDs**: Store block UUIDs when you need to update specific
   blocks later
5. **Content formatting**: Follow all LogSeq formatting rules (bullets,
   properties, etc.)
6. **Multi-line content**: Use `\n` for line breaks and proper indentation in
   multi-line block content
7. **Response size**: Be cautious with `getPageBlocksTree` on large pages - use
   `read_page` or `search_blocks` instead
8. **Null responses**: A `null` response from `updateBlock` or `insertBlock`
   indicates success
9. **Error handling**: The MCP tools will return error details if operations
   fail
10. **Test bulk operations**: Use `search_blocks` to preview before using
    `replace_line` for bulk updates

### Example: Updating a Breakdown with Checkboxes

**New Way (Using replace_line - Recommended for bulk updates):**

```elixir
# Update all unchecked tasks in a breakdown page
mcp__ash-logseq__replace_line(
  input: {
    "page_id": "projects/my-project/feature/breakdown",
    "changes": [
      {
        "content": "[ ] **Create base resource**",
        "replacement": "[x] **Create base resource**"
      },
      {
        "content": "[ ] Run tests",
        "replacement": "[x] Run tests"
      }
    ]
  }
)
```

**Old Way (Using logseq_api - For single block updates):**

```elixir
# 1. Get the current block
block = mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getBlock",
    "args": ["block-uuid"]
  }
)

# 2. Update the content with checked boxes
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.updateBlock",
    "args": [
      "block-uuid",
      "#### 1. [x] **Task Complete**\n\n1.1. [x] Subtask 1\n1.2. [x] Subtask 2\n1.3. [ ] Subtask 3"
    ]
  }
)
```

**When to use each:**

- Use `replace_line` for bulk checkbox updates across multiple tasks
- Use `logseq_api` with `updateBlock` for precise single block updates with
  complex formatting

### Workflow-Specific Patterns: Research/Plan/Breakdown

These patterns show how to create structured workflow documents efficiently
using phase blocks.

#### Creating Research Pages

Research pages have multiple sections (impact analysis, third-party
integrations, etc.). Create each major section as a phase block:

```elixir
# Create research page with properties
page_content = """
type:: research
status:: completed
created:: 2025-10-31
project:: logseq_mcp
topic:: mcp-enhancements

- # LogSeq MCP Enhancements Research
- ## Codebase Impact Analysis
  **Files Requiring Changes:**
  - `lib/logseq_mcp/logseq/client.ex:45` - Add new API methods
  - `lib/logseq_mcp_web/router.ex:23` - Add new routes

  **Existing Patterns Found:**
  - HTTP client uses Req library configured at line 12
  - MCP resources follow Ash pattern in `lib/logseq_mcp/mcp/*`

- ## Third-Party Integrations
  **LogSeq HTTP API Extensions:**
  - New methods needed: getBlockWithStructure, validatePageFormat
  - Documentation: [LogSeq API Docs](https://plugins-doc.logseq.com)

- ## Implementation Recommendations
  - Follow existing Ash.Resource pattern for new tools
  - Add validation helpers in separate module
  - Test with existing LogSeq instance
"""

mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.createPage",
    "args": ["projects/logseq_mcp/mcp-enhancements/research", page_content]
  }
)
```

#### Creating Plan Pages

Plan pages outline implementation strategy. Use phase blocks for each major
planning section:

```elixir
# Create plan page building on research
page_content = """
type:: plan
status:: completed
created:: 2025-10-31
project:: logseq_mcp
topic:: mcp-enhancements

- # LogSeq MCP Enhancements Implementation Plan
- ## Implementation Strategy
  **Primary Approach:**
  - Extend existing Ash.Resource pattern for new MCP tools
  - Add validation module following project conventions
  - Use discovered Req patterns for HTTP client extensions

  **Architecture Decisions:**
  - New tools as separate Ash actions on existing LogseqApi resource
  - Validation as pure functions in LogseqMcp.Validation module
  - Tests follow existing pattern in test/logseq_mcp/mcp/*

- ## Implementation Phases
  **Phase 1: Validation Helpers**
  - Create validation module with format checking
  - Add property validation functions
  - Test against known-good and known-bad pages

  **Phase 2: API Extensions**
  - Add getBlockWithStructure action
  - Implement safe delete validation
  - Update HTTP client with new methods

  **Phase 3: Testing and Documentation**
  - Comprehensive test coverage
  - Update README with new capabilities
  - Document usage patterns in SKILL.md
"""

mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.createPage",
    "args": ["projects/logseq_mcp/mcp-enhancements/plan", page_content]
  }
)
```

#### Creating Breakdown Pages

Breakdown pages are detailed checklists. Each phase becomes ONE block with all
its tasks:

```elixir
# Create breakdown page with phase blocks
page_content = """
type:: breakdown
status:: in-progress
created:: 2025-10-31
project:: logseq_mcp
topic:: mcp-enhancements

- # LogSeq MCP Enhancements Task Breakdown
- ## Implementation Instructions
  **CRITICAL COMMIT WORKFLOW**: After completing each numbered task:
  1. Complete all substeps
  2. Run full test suite: `mix test`
  3. Verify ALL tests pass (zero failures)
  4. Only then commit with suggested message

- ## Phase 1: Validation Module
  1. [ ] **Create validation module**
     1.1. [ ] Create file `lib/logseq_mcp/validation.ex`
     1.2. [ ] Add validate_page_structure/1 function
     1.3. [ ] Add validate_properties/1 function
     1.4. [ ] Run tests: `mix test test/logseq_mcp/validation_test.exs`
     1.5. [ ] Verify all tests pass before commit
     📝 **Commit**: `feat(validation): add page structure validation`

  2. [ ] **Add format validators**
     2.1. [ ] Implement blank line detection
     2.2. [ ] Implement property syntax checking
     2.3. [ ] Add bullet point validation
     2.4. [ ] Run tests: `mix test`
     2.5. [ ] Verify all tests pass
     📝 **Commit**: `feat(validation): add format validation helpers`

- ## Phase 2: API Extensions
  1. [ ] **Add getBlockWithStructure action**
     1.1. [ ] Update LogseqApi resource in `lib/logseq_mcp/mcp/logseq_api.ex`
     1.2. [ ] Implement action with includeChildren and structure metadata
     1.3. [ ] Add HTTP client method in `lib/logseq_mcp/logseq/client.ex`
     1.4. [ ] Run tests: `mix test test/logseq_mcp/mcp/`
     1.5. [ ] Verify all tests pass
     📝 **Commit**: `feat(api): add block structure query with hierarchy info`
"""

mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.createPage",
    "args": ["projects/logseq_mcp/mcp-enhancements/breakdown", page_content]
  }
)
```

**Key Pattern**: Each numbered task (1, 2, 3) with its substeps (1.1, 1.2, etc.)
lives in ONE phase block. Don't create separate blocks for each subtask - it's
inefficient and error-prone.

### Debugging MCP Issues

If you encounter errors:

1. **Check input format**: Ensure you're passing a JSON object, not a string
2. **Verify block UUIDs**: Make sure the UUID exists and is valid
3. **Check content format**: Ensure content follows LogSeq formatting rules
4. **Check server logs**: Use `mcp__tidewave__get_logs` to see detailed error
   information

```elixir
# Get recent logs with error filtering
mcp__tidewave__get_logs(
  tail: 50,
  grep: "error|warning"
)
```

### 🚨 CRITICAL: Block Deletion and Parent-Child Relationships

**NEVER delete blocks without understanding their parent-child relationships!**

#### The Problem

When you delete a block, **all of its child blocks are also deleted**, even if
they appear elsewhere in search results or have their own UUIDs. This can cause
massive data loss if you're not careful.

#### What Happened

In a real incident:

1. Search returned duplicate blocks (same content, different UUIDs)
2. Attempted to delete "duplicate" blocks by UUID
3. The "duplicates" were actually the ORIGINAL blocks that had CHILDREN
4. Deleting them removed all child content (entire Phase 2, 3, 4 task details)
5. Only section headers remained - all implementation details were lost

#### The Root Cause

LogSeq search returns blocks that may be:

- **Parent blocks**: Top-level blocks with nested children underneath
- **Standalone blocks**: Individual blocks without children
- **Different versions**: Same content in different pages or locations

**Search results DO NOT show parent-child relationships!** You can't tell from a
search result alone whether a block has children.

#### Safe Deletion Protocol

**ALWAYS check for children before deleting any block:**

```elixir
# 1. Get the block with children info
block = mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getBlock",
    "args": ["block-uuid", {"includeChildren": true}]
  }
)

# 2. Check if it has children
if block["children"] != nil && length(block["children"]) > 0 do
  # ⚠️ WARNING: This block has children!
  # Deleting it will delete ALL nested content underneath
  # Verify this is what you want before proceeding
end

# 3. Only delete if you're certain
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.removeBlock",
    "args": ["block-uuid"]
  }
)
```

#### Understanding Block Hierarchies

```markdown
- ### Phase 2: Section Header (UUID: abc123)
  - #### Task 2: Subtask (UUID: def456)
    - 2.1. Detail 1
    - 2.2. Detail 2
  - #### Task 3: Another task (UUID: ghi789)
```

If you delete `abc123` (Phase 2 header), you delete:

- The Phase 2 header itself
- Task 2 (def456) AND all its details
- Task 3 (ghi789) AND all its details
- **Everything nested underneath, recursively**

#### Safe Approaches to Avoid Data Loss

**Approach 1: Update instead of delete**

```elixir
# Instead of deleting and recreating, UPDATE the existing block
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.updateBlock",
    "args": ["block-uuid", "Updated content"]
  }
)
```

**Approach 2: Check page structure first**

```elixir
# Get full page tree to understand structure
page_tree = mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.getPageBlocksTree",
    "args": ["page-name"]
  }
)

# Review the hierarchy before making changes
```

**Approach 3: Be specific with UUIDs**

```elixir
# If search returns multiple results, use the page context to identify
# which block is the correct one to modify
results = mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.search",
    "args": ["search term"]
  }
)

# Check which page each result belongs to
for result in results["blocks"] do
  page_id = result["block/page"]
  # Only act on blocks from the correct page
end
```

#### Recovery from Accidental Deletion

If you accidentally delete blocks with children:

1. **Stop immediately** - don't make more changes
2. **Recreate the structure** - use `insertBlock` to rebuild the hierarchy
3. **Verify page tree** - check that parent-child relationships are restored
4. **Update content** - restore the lost content block by block

#### Key Takeaways

1. **Search results are deceptive** - they don't show parent-child relationships
2. **Always check for children** before deleting any block
3. **Prefer updates over delete+recreate** - it's safer
4. **Understand the page structure** before making bulk changes
5. **UUIDs are unique per block** - same content in different locations means
   different blocks
6. **Deletion is recursive** - deleting a parent deletes ALL descendants
7. **There is no undo** - LogSeq MCP operations are permanent

## When Creating Pages Programmatically

Follow this checklist:

1. ✅ Start with page properties (no hyphens)
2. 🚨 **NO BLANK LINE after properties** - goes directly to first content block
3. 🚨 **Think in phases, not items** - create one block per phase/section with
   multi-line content for workflows
4. ✅ All content as bullets with `-`
5. ✅ Use 2-space indentation for nesting
6. ✅ Headings have leading `-`
7. 🚨 **Avoid hashtags for IDs/numbers** - use `\#379` or `[#379](URL)` instead
8. ✅ Code blocks within bullet points
9. ✅ Keep nesting shallow (3-4 levels max)
10. ✅ No multiple markdown headings in single block
11. ✅ One unordered list per block level
12. 🚨 **Use JSON objects for MCP input** - never pass JSON strings
13. 🚨 **Use `\n` for line breaks** in multi-line block content

### createPage API Options

The `logseq.Editor.createPage` method accepts optional parameters:

```elixir
mcp__ash-logseq__logseq_api(
  input: {
    "method": "logseq.Editor.createPage",
    "args": [
      "page-name",
      page_content,
      {"createFirstBlock": false}  # Optional: prevent auto-creation of first block
    ]
  }
)
```

**Options** (third argument, optional):

- `createFirstBlock` (boolean): Controls whether LogSeq automatically creates an
  initial empty block. Default is `true`. Set to `false` if your content already
  includes all necessary blocks.
- `format` (string): Page format - `"markdown"` or `"org"`. Default is
  `"markdown"`.
- `journal` (boolean): Mark page as journal entry. Default is `false`.
- `redirect` (boolean): Navigate to newly created page. Default is `true`.

**Note**: When providing page content with embedded properties and blocks (as
shown in all examples above), the default behavior works well. The
`createFirstBlock: false` option may be useful if you want precise control over
page structure.

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
- Think in **phases/sections**, not individual items - create one block per
  logical unit with multi-line content
- **Properties first** (no bullets), **content second** (all bullets)
- 🚨 **NO BLANK LINE between properties and content** - prevents empty blocks
- 🚨 **Hashtags create pages** - use `\#379` or `[#379](URL)` for external
  references
- 🚨 **Phase blocks for workflows** - one block per phase with all
  tasks/subtasks as multi-line content, not separate blocks per subtask
- **Simple structure** beats complex nesting
- Use multi-line content within blocks for related steps and procedures
