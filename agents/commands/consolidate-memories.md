# Memory Consolidation Command

**CRITICAL**: You are the memory consolidation orchestrator. Your role is to
review all memories, identify fragmentation, and consolidate related memories
into comprehensive knowledge bases.

## Purpose

Over time, memories can become fragmented with multiple small entries on similar
topics. This command systematically reviews and consolidates memories to:

- Merge related memories into comprehensive entries
- Eliminate duplicate information
- Organize information hierarchically
- Improve memory retrieval effectiveness

## Your Role

You coordinate the memory consolidation process, working with memory-agent to:

1. Discover all existing memories
2. Identify consolidation opportunities
3. Merge related memories
4. Update memory links and references

## Consolidation Process

### **Phase 1: Memory Discovery**

1. **Search all memory categories**:

   ```
   Use the ash-logseq MCP server's search_pages tool to find all memory pages:
   Tool: mcp__ash-logseq__search_pages
   - Query: "claude/memories/"
   - This will return all pages in the memory namespace
   ```

2. **Catalog memories**:
   - List all memory pages found
   - Note creation and update dates
   - Identify topic keywords for each

### **Phase 2: Similarity Analysis**

**Group memories by similarity:**

1. **Same Technology/Tool**:

   - Multiple memories about same framework → CONSOLIDATE
   - Example: "Phoenix LiveView debugging" + "LiveView WebSocket errors" → Merge

2. **Same Problem Domain**:

   - Multiple memories about similar problems → CONSOLIDATE
   - Example: "Authentication with Ash" + "AshAuthentication setup" → Merge

3. **Same Project**:

   - Multiple memories about same project → CONSIDER CONSOLIDATION
   - May keep separate if topics are distinct

4. **Related Concepts**:
   - Memories on related but distinct topics → LINK, don't merge
   - Example: "Elixir testing" + "Elixir deployment" → Keep separate, add links

### **Phase 3: Consolidation Planning**

For each consolidation opportunity:

**Create consolidation plan:**

```markdown
## Consolidation Plan: [Topic]

### Memories to Merge:

1. claude/memories/[category]/[memory-1]

   - Created: YYYY-MM-DD
   - Key content: [summary]

2. claude/memories/[category]/[memory-2]

   - Created: YYYY-MM-DD
   - Key content: [summary]

3. claude/memories/[category]/[memory-3]
   - Created: YYYY-MM-DD
   - Key content: [summary]

### Target Memory:

- Name: claude/memories/[category]/[consolidated-name]
- Approach: Update oldest/most comprehensive memory

### Content Organization:

- ## Context: [Combined context from all memories]
- ## Current Best Practices: [Most recent/proven approaches]
- ## Historical Evolution: [Dated entries showing how understanding evolved]
- ## Common Pitfalls: [Issues encountered across all memories]
- ## Related Topics: [Links to related but distinct memories]

### Memories to Archive/Delete:

- [memory-2] → Content merged into [memory-1]
- [memory-3] → Content merged into [memory-1]
```

### **Phase 4: Execute Consolidation**

For each consolidation plan:

1. **Read all related memories**:

   ```
   Use the ash-logseq MCP server's read_page tool for each memory to merge:
   Tool: mcp__ash-logseq__read_page
   ```

2. **Create consolidated content**:

   - Combine all relevant information
   - Organize chronologically or by topic
   - Remove redundancies
   - Preserve unique insights from each

3. **Update target memory**:

   ```
   Use ash-logseq MCP tools to update the primary memory:
   - For complete page rewrites: mcp__ash-logseq__replace_page (PREFERRED for large consolidations)
   - For bulk pattern updates: mcp__ash-logseq__replace_line
   - For precise single-block updates: mcp__ash-logseq__logseq_api with updateBlock method
   ```

   **When to use each tool**:

   - **`replace_page`** (Most efficient for consolidation):

     - Use when merging multiple memories into one comprehensive page
     - Use when restructuring entire page content
     - Safely wraps old content during replacement (zero data loss)
     - REQUIRES `confirm: true` for safety
     - Use `dry_run: true` first to preview changes
     - Optional: `keep_backup: true` to preserve old content for manual review
     - Example workflow:

       ```
       # Step 1: Preview changes
       Tool: mcp__ash-logseq__replace_page
       Parameters:
         page_name: "claude/memories/technical/consolidated-topic"
         content: "[complete new markdown content]"
         confirm: true
         dry_run: true

       # Step 2: Execute replacement
       Tool: mcp__ash-logseq__replace_page
       Parameters:
         page_name: "claude/memories/technical/consolidated-topic"
         content: "[complete new markdown content]"
         confirm: true
         dry_run: false
       ```

   - **`replace_line`**: Use only for specific line-by-line pattern replacements
     across blocks
   - **`logseq_api`**: Use only for precise single-block updates with known
     block IDs

4. **Update memory properties**:

   ```
   updated:: YYYY-MM-DD
   consolidated-from:: [[memory-2]], [[memory-3]]
   confidence:: [adjusted based on combined information]
   ```

5. **Archive or delete merged memories**:

   - Add "Status: Consolidated into [[target-memory]]" to merged memories
   - OR delete if content is fully merged:
     - Tool: mcp**ash-logseq**delete_page
     - Use `dry_run: true` FIRST to validate
     - Then use `confirm: true` for permanent deletion

6. **Update cross-references**:
   - Find memories linking to merged memories
   - Update links to point to consolidated memory

### **Phase 5: Report Results**

**Consolidation Report:**

```markdown
# Memory Consolidation Report

## Date: YYYY-MM-DD

## Memories Reviewed: [count]

## Consolidations Performed: [count]

### Consolidation Details:

#### 1. [Topic Area]

- **Target Memory**: claude/memories/[category]/[name]
- **Merged From**: [memory-2], [memory-3]
- **Benefits**: [what improved]

#### 2. [Topic Area]

- **Target Memory**: claude/memories/[category]/[name]
- **Merged From**: [memory-4], [memory-5]
- **Benefits**: [what improved]

## Recommendations:

### Memories Needing Attention:

- [memory-name]: [reason - outdated/incomplete/etc.]

### Suggested New Categories:

- [category]: [rationale]

## Next Consolidation:

Recommend running consolidation again in [timeframe] or after [trigger]
```

## Consolidation Strategies

### **Tool Selection for Consolidation**

**Use `replace_page` when:**

- ✅ Merging 2+ memories into single comprehensive page
- ✅ Completely restructuring memory organization
- ✅ Large-scale content changes (>50% of page)
- ✅ Need zero-data-loss safety with backup wrapper

**Use `replace_line` when:**

- ✅ Making consistent pattern replacements across multiple blocks
- ✅ Updating specific repeated content (dates, statuses, links)
- ✅ Small targeted changes without full page rewrite

**Use `logseq_api` when:**

- ✅ Updating single specific block with known ID
- ✅ Precise surgical changes to individual items

**For consolidation workflow, `replace_page` is PREFERRED** because:

- More efficient than line-by-line updates
- Safer with built-in backup mechanism
- Better for restructuring content
- Cleaner for large-scale merges

### **When to Consolidate**

**✅ ALWAYS consolidate:**

- Multiple memories on exact same technology/tool
- Different solutions to same specific problem
- Incremental learnings about same topic
- Fragmented information that should be together

**⚠️ CONSIDER consolidating:**

- Related but distinct topics (maybe just add links)
- Same project but different features (evaluate case-by-case)
- Old memories with newer, better solutions (update old one)

**❌ NEVER consolidate:**

- Truly different topics that happen to use same technology
- User preferences vs technical patterns
- Project-specific vs general knowledge

### **Content Organization in Consolidated Memories**

Use this structure for consolidated memories:

```markdown
type:: memory category:: [category] created:: YYYY-MM-DD (earliest date)
updated:: YYYY-MM-DD (consolidation date) consolidated-from:: [[memory-2]],
[[memory-3]] confidence:: high

- # [Comprehensive Topic Title]

- ## Overview

  - [What this memory covers]
  - [Why this topic matters]

- ## Current Best Practices

  - [Most recent/proven approach]
  - [When to use this approach]
  - [Key considerations]

- ## Historical Evolution

  - **YYYY-MM-DD**: [First approach/understanding]
    - What we learned: [lessons]
  - **YYYY-MM-DD**: [Second approach/improvement]
    - What changed: [evolution]
  - **YYYY-MM-DD**: [Current approach]
    - Why this is best: [rationale]

- ## Common Pitfalls & Solutions

  - **Pitfall**: [common mistake]
    - **Solution**: [how to avoid/fix]
    - **Source**: [which memory this came from]

- ## Implementation Examples

  - [Concrete examples from various contexts]
  - [Code snippets if applicable]

- ## Related Topics

  - [[related-memory-1]] - [relationship]
  - [[related-memory-2]] - [relationship]

- ## Consolidation History
  - **YYYY-MM-DD**: Created from merging:
    - [[original-memory-1]]
    - [[original-memory-2]]
    - [[original-memory-3]]
```

## Success Criteria

Consolidation is successful when:

- ✅ Related memories are merged into comprehensive entries
- ✅ No duplicate information across memories
- ✅ Consolidated memories show evolution over time
- ✅ Memory retrieval is more effective
- ✅ Knowledge bases are comprehensive, not fragmented
- ✅ All cross-references are updated
- ✅ Archived/deleted memories are properly documented

## Usage

```bash
# Run memory consolidation
/consolidate-memories

# Or with user guidance:
claude "Please consolidate memories on [topic area]"
```

## When to Run Consolidation

**Recommended triggers:**

- After completing a large project (consolidate project learnings)
- Quarterly maintenance (consolidate accumulated memories)
- When search retrieval becomes difficult (fragmentation indicator)
- After accumulating 50+ memories (preventive maintenance)
- When noticing duplicate information (reactive fix)

## Integration with Memory-Agent

This command heavily relies on memory-agent:

- Uses memory-agent RETRIEVE mode to find memories
- Uses memory-agent STORE mode to update consolidated memories
- Follows UPDATE > CREATE policy principles
- Maintains memory-agent's format standards
