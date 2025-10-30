# Skill Migration Review Fixes

## Implementation Prompt

Implement the following critical fixes from the comprehensive review:

### 1. Remove All `/skill` Invocation Syntax

**Problem**: The `/skill <name>` syntax does not exist in Claude Code. Skills
are model-invoked only - Claude automatically decides when to use them based on
context.

**Task**: Remove all references to `/skill` syntax across all command files and
replace with language that reflects auto-loading behavior.

**Files to Update**:

- `agents/commands/add-tests.md`
- `agents/commands/fix-tests.md`
- `agents/commands/execute.md`
- `agents/commands/implement.md`
- `agents/commands/feature.md`
- `agents/commands/task.md`
- `agents/commands/cleanup.md`
- `agents/commands/research.md`

**Replacement Pattern**:

```markdown
# WRONG (current):

Use `/skill elixir` for Elixir/Phoenix test patterns Use `/skill testing` for
testing methodology

# CORRECT (auto-loading language):

The elixir skill will automatically activate when working with Elixir files and
provide Phoenix/Ecto/Ash patterns The testing skill provides testing methodology
guidance when discussing test strategies
```

**Examples of What to Change**:

- "Use `/skill testing` for TDD/BDD approach" → "Reference testing methodologies
  (testing skill provides TDD/BDD guidance)"
- "Use `/skill elixir` for ExUnit patterns" → "Ask about ExUnit patterns (elixir
  skill will provide Elixir-specific testing guidance)"
- "`/skill elixir`" → "elixir skill knowledge"

**Goal**: Remove 30+ `/skill` references and replace with language that explains
skills auto-load based on context.

---

### 2. Fix YAML Frontmatter Format in All Skills

**Problem**: All 5 skills use multi-line `description:` format that may not
parse correctly. Claude Code Skills require single-line descriptions.

**Task**: Convert multi-line descriptions to single-line format in all skill
YAML frontmatter.

**Files to Update**:

- `agents/skills/elixir/SKILL.md`
- `agents/skills/lua/SKILL.md`
- `agents/skills/neovim/SKILL.md`
- `agents/skills/chezmoi/SKILL.md`
- `agents/skills/testing/SKILL.md`

**Pattern to Fix**:

```yaml
# WRONG (current multi-line):
---
name: elixir
description:
  Expert guidance on Elixir, Phoenix, Ecto, Ash, and OTP patterns with
  documentation-backed best practices and critical code style guidelines
---
# CORRECT (single-line):
---
name: elixir
description: Expert guidance on Elixir, Phoenix, Ecto, Ash, and OTP patterns with documentation-backed best practices and critical code style guidelines
---
```

**Important**: Keep only two fields in frontmatter: `name` and `description`. No
`tags` field.

---

### 3. Update Old Agent References

**Problem**: 37+ references to deleted agents (`elixir-expert`, `lua-expert`,
`neovim-expert`, `chezmoi-expert`, `test-expert`, `test-developer`) remain in
active documentation and agent definitions.

**Task**: Replace all old agent references with skill-appropriate language.

**Files to Update**:

- `agents/AGENTS.md` (10+ references)
- `agents/agent-definitions/feature-planner.md` (15+ references)
- `agents/agent-definitions/fix-planner.md` (11+ references)
- `agents/agent-definitions/task-planner.md` (5+ references)
- `agents/agent-definitions/architecture-agent.md` (6+ references)
- `agents/AGENT-SYSTEM-GUIDE.md` (3 references)

**Replacement Patterns**:

```markdown
# Agent Consultation Language (OLD):

- Consult elixir-expert for patterns
- Ask lua-expert for guidance
- Coordinate with test-expert
- Call neovim-expert for help
- Research with chezmoi-expert

# Skill Knowledge Language (NEW):

- Leverage elixir skill knowledge for patterns
- Reference lua skill for guidance
- Apply testing skill methodologies
- Use neovim skill configuration patterns
- Follow chezmoi skill conventions
```

**Special Cases**:

1. **test-developer references**: This agent doesn't exist. Replace with:
   - "Use testing skill for test methodology"
   - "Consult qa-reviewer agent for test coverage analysis" (when referring to
     active review)

2. **Hierarchical orchestration examples**: Remove skills from agent hierarchy
   diagrams (skills are passive, not part of agent orchestration trees)

3. **Agent Selection Matrix**: Update to clarify that skills provide knowledge
   automatically, agents perform actions

**Search Terms to Find**:

- `elixir-expert`
- `lua-expert`
- `neovim-expert`
- `chezmoi-expert`
- `test-expert`
- `test-developer`

---

## Implementation Approach

### Step 1: YAML Frontmatter Fix (Quick Win)

1. Fix elixir skill YAML frontmatter
2. Fix lua skill YAML frontmatter
3. Fix neovim skill YAML frontmatter
4. Fix chezmoi skill YAML frontmatter
5. Fix testing skill YAML frontmatter

**Time Estimate**: 10 minutes

---

### Step 2: Remove `/skill` Syntax (Moderate Effort)

1. Update add-tests.md command
2. Update fix-tests.md command
3. Update execute.md command
4. Update implement.md command
5. Update feature.md command
6. Update task.md command
7. Update cleanup.md command
8. Update research.md command

**Approach**: Use consistent replacement pattern for natural language that
explains auto-loading

**Time Estimate**: 30-45 minutes

---

### Step 3: Update Agent References (Systematic Cleanup)

1. Update AGENTS.md
2. Update feature-planner.md
3. Update fix-planner.md
4. Update task-planner.md
5. Update architecture-agent.md
6. Update AGENT-SYSTEM-GUIDE.md

**Approach**:

- Find/replace old agent names with skill references
- Update consultation language to knowledge reference language
- Remove skills from agent orchestration hierarchies

**Time Estimate**: 45-60 minutes

---

## Validation Checklist

After implementing fixes:

- [ ] No `/skill` syntax remains in any command file
- [ ] All 5 skills have single-line descriptions in YAML frontmatter
- [ ] No references to `elixir-expert`, `lua-expert`, `neovim-expert`,
      `chezmoi-expert`, `test-expert` remain
- [ ] All `test-developer` references resolved (replaced with appropriate
      skill/agent)
- [ ] AGENTS.md clearly explains skills auto-load, agents are called explicitly
- [ ] Agent definitions don't reference deleted agents
- [ ] Skills removed from agent orchestration hierarchy diagrams
- [ ] Documentation consistently uses "skill knowledge" language, not "consult
      expert" language

---

## Total Estimated Time: 1.5-2 hours

## Success Criteria

After these fixes:

1. Users understand skills auto-load based on context (no manual invocation)
2. YAML frontmatter is valid and Claude Code can parse it
3. No broken references to non-existent agents
4. Clear distinction between skills (passive knowledge) and agents (active
   tasks)
5. Documentation is internally consistent

---

## Notes

- Keep archived agents in `agents/archived/` for reference (already done)
- The core skill content is excellent and doesn't need changes
- Focus fixes on documentation and invocation patterns only
- These are quick, mechanical fixes - no deep architectural changes needed
