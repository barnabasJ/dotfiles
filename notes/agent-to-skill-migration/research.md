# Agent-to-Skill Migration Research

## Project Dependencies Discovered

### Current Architecture

- **Agent System**: Custom agent orchestration in `agents/` directory
  - Agent definitions: `agents/agent-definitions/`
  - Commands: `agents/commands/`
  - Documentation: `agents/AGENTS.md`, `agents/AGENT-SYSTEM-GUIDE.md`

### Claude Code Skills System

- **Documentation**: https://docs.claude.com/en/docs/claude-code/skills
- **Available**: Claude Code (all plans), requires Code Execution Tool beta
- **Storage Locations**:
  - Personal: `~/.claude/skills/`
  - Project: `.claude/skills/`

## Files Requiring Changes

### Skills to Create (Domain Knowledge Conversion)

#### 1. Elixir Skill

- **Source**: `agents/agent-definitions/elixir-expert.md:1`
- **Target**: `~/.claude/skills/elixir/SKILL.md`
- **Type**: Language expertise skill
- 📖
  [Claude Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
- 📖
  [Progressive Disclosure Pattern](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

#### 2. Lua Skill

- **Source**: `agents/agent-definitions/lua-expert.md:1`
- **Target**: `~/.claude/skills/lua/SKILL.md`
- **Type**: Language expertise skill

#### 3. Neovim Skill

- **Source**: `agents/agent-definitions/neovim-expert.md:1`
- **Target**: `~/.claude/skills/neovim/SKILL.md`
- **Type**: Tool expertise skill

#### 4. Chezmoi Skill

- **Source**: `agents/agent-definitions/chezmoi-expert.md:1`
- **Target**: `~/.claude/skills/chezmoi/SKILL.md`
- **Type**: Tool expertise skill

#### 5. Testing Methodology Skill

- **Source**: `agents/agent-definitions/test-expert.md:1`
- **Target**: `~/.claude/skills/testing/SKILL.md`
- **Type**: Methodology expertise skill

### New Agent to Create

#### 6. Codebase Explorer Agent

- **Target**: `agents/agent-definitions/codebase-explorer.md`
- **Purpose**: Fast pattern discovery and code search
- **Tools**: Read, Glob, Grep, LS (read-only)

### Documentation to Update

#### 7. Agent Orchestration System

- **File**: `agents/AGENTS.md:1-551`
- **Changes**: Update references from agents to skills for domain knowledge
- **Pattern**: Replace agent consultation with skill availability

#### 8. Global Instructions

- **File**: `~/.claude/CLAUDE.md` (if exists)
- **Changes**: Document skill vs agent decision framework

## Existing Patterns Found

### Current Agent Architecture Patterns

**Domain Knowledge Agents (READ-ONLY):**

- Pattern: Pure knowledge repositories
- Examples found in:
  - `agents/agent-definitions/elixir-expert.md:36-86` - READ-ONLY role
    explicitly defined
  - `agents/agent-definitions/lua-expert.md:30-35` - Guidance-only pattern
  - `agents/agent-definitions/neovim-expert.md:28-33` - Consultation pattern

**Common Agent Structure:**

```yaml
---
name: agent-name
description: >
  Detailed description of agent purpose and when to use
model: opus|sonnet
tools: Read, Grep, Glob, LS, NotebookRead, Task, WebSearch, WebFetch
color: color-name
---
```

**Anti-Recursion Rules:**

- Found in all agents: Lines 18-28
- Prevents infinite loops
- Won't be needed in skills (auto-loaded, not called)

### Skills System Patterns

**Three-Tier Progressive Disclosure:**

1. **Metadata** (always loaded):

   - Name and description in YAML frontmatter
   - Claude uses to decide when to activate

2. **Core Content** (loaded when activated):

   - Main SKILL.md file
   - Primary guidance and patterns

3. **Supplementary Files** (loaded as needed):
   - reference.md, examples/, etc.
   - Detailed documentation and code samples

**Skill File Structure:**

```
skill-name/
├── SKILL.md          # Required: Core skill content with YAML frontmatter
├── reference.md      # Optional: Detailed reference
├── examples/         # Optional: Code examples
└── patterns/         # Optional: Pattern library
```

## Integration Points

### Skills Integration

- **Automatic Loading**: Claude scans available skills and loads based on
  description match
- **No Explicit Calls**: Skills don't need to be called - context is available
- **Efficient Context**: Progressive disclosure reduces token usage

### Agent Integration

- **research-agent**: Will continue to perform web research for skills
- **architecture-agent**: Will reference skill knowledge without explicit calls
- **Review agents**: Can benefit from skill knowledge automatically
- **Planning agents**: Will have domain knowledge available via skills

### Storage Strategy

- **Personal skills** (`~/.claude/skills/`): Domain knowledge skills (language
  experts)
- **Project skills** (`.claude/skills/`): Project-specific patterns (future use)
- **Agents remain**: `agents/agent-definitions/` for action-oriented agents

## Test Impact & Patterns

### No Direct Test Impact

- Skills are read-only knowledge
- No executable code to test
- Validation is through usage

### Validation Strategy

1. **Automatic Loading Test**: Verify skills load when working with relevant
   files
2. **Content Accessibility**: Ensure progressive disclosure works correctly
3. **Knowledge Quality**: Skills provide correct and useful information
4. **Performance**: Skills load efficiently without context bloat

## Configuration & Environment

### Skills Configuration

- **Location**: Skills stored in `~/.claude/skills/`
- **No config changes needed**: Skills work out of the box
- **Optional**: Can configure skill preferences in Claude Code settings

### Agent Configuration Updates

- **AGENTS.md**: Update orchestration documentation
- **CLAUDE.md**: Document when to use skills vs agents
- **Commands**: Update command descriptions to reference skills

## Required New Dependencies/Patterns

### No New Dependencies Required

- Skills are built into Claude Code
- No additional tools or libraries needed
- Works with existing Claude Code installation

### New Decision Framework Needed

**Use Skills When:**

- Pure domain knowledge (language syntax, patterns, idioms)
- Tool expertise (configuration, setup, usage)
- Methodology knowledge (testing, architecture patterns)
- Reference material (API docs, best practices)
- Information that should be available contextually

**Use Agents When:**

- Active research tasks (web search, synthesis)
- Analysis and decision-making (architecture, review)
- Document creation (planning, reports)
- Multi-step workflows (coordination, orchestration)
- Actions that modify system state

## Risk Assessment

### Low Risk - High Benefit Migration

**Benefits:**

- **Context Efficiency**: Progressive disclosure reduces token usage
- **Automatic Loading**: No orchestration overhead for knowledge
- **Clearer Architecture**: Knowledge vs actions separation
- **Performance**: Faster access to domain knowledge
- **Maintainability**: Easier to update and expand knowledge base

**Risks & Mitigations:**

- **Learning Curve**: ✅ Clear documentation and examples
- **Migration Effort**: ✅ Systematic conversion process
- **Compatibility**: ✅ Backward compatible (keep agents until migration
  complete)
- **Knowledge Loss**: ✅ Careful conversion preserves all content

### Breaking Changes: None

- Agents remain functional during migration
- Can migrate incrementally
- Skills don't replace agents completely - complementary systems

### Performance Implications

- **Faster**: Skills load more efficiently than agent orchestration
- **Less Token Usage**: Progressive disclosure vs full agent context
- **Better UX**: Knowledge available without explicit consultation

### Security Touchpoints

- **Skills are read-only**: No security concerns with knowledge repositories
- **No system access**: Skills don't execute code or modify files
- **Same trust model**: Skills from trusted sources (user-created)

### Migration Complexity: Low-Medium

- **Straightforward conversion**: Agent markdown → Skill markdown
- **Incremental migration**: One skill at a time
- **Validation**: Test each skill as it's created
- **Rollback**: Keep original agents until validation complete

## Third-Party Integrations & External Services

### No External Dependencies

- Skills are native Claude Code feature
- No API keys or external services required
- No third-party tools needed

### Internal Integration: Seamless

- Skills integrate with existing Claude Code tools
- Works with current agent system
- Compatible with command system

## Unclear Areas Requiring Clarification

### Storage Location Decision

**Question**: Should domain knowledge skills be in `~/.claude/skills/`
(personal) or `.claude/skills/` (project)?

**Options:**

1. **Personal** (`~/.claude/skills/`):

   - ✅ Available across all projects
   - ✅ Language knowledge is universal
   - ❌ Not version-controlled with dotfiles

2. **Project** (`.claude/skills/`):
   - ✅ Version-controlled with chezmoi
   - ✅ Can sync across machines
   - ❌ Need to duplicate for each project

**Recommendation**: Personal storage for language/tool skills, as they're
universal knowledge. Project storage can be used for project-specific patterns
in the future.

### Supplementary File Organization

**Question**: How deeply should we organize supplementary files?

**Options:**

1. **Flat structure**: `elixir/SKILL.md`, `elixir/reference.md`
2. **Organized structure**: `elixir/SKILL.md`, `elixir/patterns/`,
   `elixir/examples/`

**Recommendation**: Start flat, organize deeper as content grows.

### Agent Removal Timeline

**Question**: When should we remove original agent files?

**Recommendation**: Keep agents until all skills are validated and working
correctly. Then archive agents to `agents/archived/` for reference.

## Documentation References

### Claude Code Skills

- 📖
  [Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills) -
  Official skills guide
- 📖
  [Progressive Disclosure Technical Deep-Dive](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) -
  Architecture details
- 📖 [Skills Announcement](https://www.anthropic.com/news/skills) - Feature
  overview

### Current Agent System

- 📖 `agents/AGENTS.md` - Current orchestration system
- 📖 `agents/AGENT-SYSTEM-GUIDE.md` - Agent development guide
- 📖 `agents/HOOKS-GUIDE.md` - Hook integration patterns

## Success Criteria

This research phase is complete when:

- ✅ Skills system fully understood
- ✅ All domain knowledge agents identified
- ✅ Skill conversion strategy defined
- ✅ File structure planned
- ✅ Migration risks assessed
- ✅ Documentation requirements identified
- ✅ New agent requirements defined (codebase-explorer)
- ✅ Ready for **plan** phase with clear implementation path

## Next Phase: Planning

With this research complete, the **plan** phase will:

1. Define detailed skill structures for each conversion
2. Create skill templates with progressive disclosure
3. Plan supplementary file organization
4. Design codebase-explorer agent specification
5. Plan documentation updates
6. Define validation and testing approach
