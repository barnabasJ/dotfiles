# Agent-to-Skill Migration Plan

## Overview

This plan details the migration of domain knowledge agents (elixir-expert,
lua-expert, neovim-expert, chezmoi-expert, test-expert) to Claude Code Skills,
leveraging the progressive disclosure pattern for more efficient context
management while maintaining the action-oriented agent system for orchestration
and analysis tasks.

## Strategic Goals

### Primary Objectives

1. **Reduce Context Overhead**: Use progressive disclosure to load domain
   knowledge only when needed
2. **Improve Performance**: Eliminate orchestration overhead for pure knowledge
   consultation
3. **Clearer Architecture**: Separate domain knowledge (skills) from actions
   (agents)
4. **Better Maintainability**: Centralize domain knowledge in discoverable skill
   files
5. **Enhanced UX**: Automatic skill loading based on file context

### Success Metrics

- ✅ All 5 domain knowledge agents converted to skills
- ✅ Skills automatically load when working with relevant files
- ✅ No token overhead for unused domain knowledge
- ✅ Agent system remains functional for orchestration tasks
- ✅ Documentation updated to reflect new architecture
- ✅ Codebase-explorer agent created for fast pattern discovery

## Architecture Design

### Skill vs Agent Decision Framework

**Use Skills for:**

- Pure domain knowledge (language syntax, patterns, idioms)
- Tool expertise (configuration, setup, usage patterns)
- Methodology knowledge (testing principles, architecture patterns)
- Reference material (API docs, best practices, conventions)
- Information that should be contextually available

**Use Agents for:**

- Active research (web search, documentation synthesis)
- Analysis and decision-making (architecture, code review)
- Document creation (planning, reports, specifications)
- Multi-step workflows (orchestration, coordination)
- Actions that modify or analyze system state

### Storage Strategy

**Personal Skills** (`~/.claude/skills/`):

- Language expertise (elixir, lua)
- Universal tool expertise (neovim, chezmoi)
- Methodology knowledge (testing)
- Rationale: Universal knowledge applicable across all projects

**Agent Definitions** (`agents/agent-definitions/`):

- Action-oriented agents (reviewers, planners, researchers)
- Orchestration agents (architecture, documentation)
- Rationale: Agents perform actions, not just provide knowledge

### Progressive Disclosure Structure

Each skill will use three-tier progressive disclosure:

**Tier 1: Metadata (Always Loaded)**

```yaml
---
name: skill-name
description: >
  Concise description that helps Claude decide when to activate this skill
tags: [tag1, tag2, tag3]
---
```

**Tier 2: Core Content (Loaded When Activated)**

- Main SKILL.md file with essential patterns and guidelines
- Most commonly needed information
- Links to supplementary files for deeper details

**Tier 3: Supplementary Files (Loaded As Needed)**

- reference.md: Detailed API reference and comprehensive documentation
- examples/: Code examples and usage patterns
- patterns/: Design patterns and architecture guidance

## Skill Specifications

### 1. Elixir Skill

**Location**: `~/.claude/skills/elixir/SKILL.md`

**Purpose**: Comprehensive Elixir, Phoenix, Ecto, and Ash expertise

**Metadata**:

```yaml
name: elixir
description:
  Expert guidance on Elixir, Phoenix, Ecto, Ash, and OTP patterns with
  documentation-backed best practices
tags: [elixir, phoenix, ecto, ash, otp, functional-programming]
```

**Core Content Sections**:

1. Elixir Language Fundamentals

   - Pattern matching best practices
   - Pipe operator guidelines (single vs multiple operations)
   - Process and OTP behaviors
   - Macro usage patterns

2. Phoenix Framework Patterns

   - LiveView component best practices (public wrapper functions with attrs)
   - Controller and context conventions
   - Channel patterns and real-time features

3. Ecto Database Patterns

   - Schema definitions and changesets
   - Query composition and optimization
   - Migration patterns and best practices

4. Ash Framework Specifics

   - Resource definitions and actions
   - **CRITICAL**: Use `mix ash.codegen` for migrations (not ecto.gen.migration)
   - Policy and authorization patterns

5. Testing Guidelines

   - ExUnit patterns and organization
   - **CRITICAL**: Use Mimic's `expect` (not `stub`) for mocking
   - Test setup best practices (generators for setup, single action per test)

6. Script Execution
   - **CRITICAL**: Use `mix run` for project scripts (not `elixir` command)
   - Mix task creation patterns

**Supplementary Files**:

- `reference.md`: Complete API reference from usage_rules.md
- `examples/`: Phoenix LiveView, Ash resources, Ecto queries, OTP patterns

**Migration Notes**:

- Extract content from `agents/agent-definitions/elixir-expert.md:82-446`
- Remove anti-recursion rules (not needed in skills)
- Remove tool restriction sections (skills are read-only by nature)
- Keep all critical code style guidelines and examples

### 2. Lua Skill

**Location**: `~/.claude/skills/lua/SKILL.md`

**Purpose**: Lua language patterns and Neovim plugin development

**Metadata**:

```yaml
name: lua
description:
  Expert guidance on Lua language patterns, idioms, and Neovim plugin
  development with best practices
tags: [lua, neovim, plugin-development, scripting]
```

**Core Content Sections**:

1. Lua Language Fundamentals

   - Table patterns and metatables
   - Module system and require patterns
   - Closures and functional patterns
   - Coroutines and async patterns

2. Neovim-Specific Lua

   - Vim API (`vim.api.*`) patterns
   - Plugin structure and organization
   - Keybinding and autocmd patterns
   - Configuration best practices

3. Common Patterns
   - Error handling in Lua
   - Testing approaches
   - Performance considerations

**Supplementary Files**:

- `reference.md`: Lua 5.1 reference (Neovim's version)
- `examples/`: Plugin examples, config patterns

**Migration Notes**:

- Extract content from `agents/agent-definitions/lua-expert.md`
- Focus on Neovim-specific patterns (primary use case)
- Include Lua general patterns for reference

### 3. Neovim Skill

**Location**: `~/.claude/skills/neovim/SKILL.md`

**Purpose**: Neovim configuration, plugin ecosystem, and workflow optimization

**Metadata**:

```yaml
name: neovim
description:
  Expert guidance on Neovim configuration, plugin ecosystem, lazy.nvim, LSP
  setup, and editor workflow optimization
tags: [neovim, editor, vim, lazy-nvim, lsp, plugins]
```

**Core Content Sections**:

1. Neovim Configuration Architecture

   - Init.lua structure and organization
   - lazy.nvim plugin management
   - Configuration best practices

2. Plugin Ecosystem

   - Essential plugin recommendations
   - Plugin configuration patterns
   - Plugin integration and compatibility

3. LSP Configuration

   - mason.nvim for LSP management
   - Language server setup patterns
   - LSP configuration per language

4. Workflow Optimization

   - Keybinding strategies
   - Autocmd patterns
   - Buffer and window management
   - Terminal integration

5. Common Tasks
   - Search and replace patterns
   - Navigation optimization
   - Git integration
   - AI integration (CodeCompanion, Copilot, Avante)

**Supplementary Files**:

- `reference.md`: Plugin directory with descriptions
- `examples/`: Config snippets, plugin setups
- `patterns/`: Configuration patterns by use case

**Migration Notes**:

- Extract content from `agents/agent-definitions/neovim-expert.md`
- Include this project's Neovim config as reference examples
- Document lazy.nvim patterns from actual config

### 4. Chezmoi Skill

**Location**: `~/.claude/skills/chezmoi/SKILL.md`

**Purpose**: Chezmoi dotfile management patterns and best practices

**Metadata**:

```yaml
name: chezmoi
description:
  Expert guidance on chezmoi dotfile management, templating, cross-platform
  configuration, and repository organization
tags: [chezmoi, dotfiles, configuration, templates, cross-platform]
```

**Core Content Sections**:

1. Chezmoi Fundamentals

   - File naming conventions (dot*, private*, run*onchange*)
   - Source vs target state
   - Common commands and workflows

2. Templating Patterns

   - Go template syntax in chezmoi context
   - OS-specific configurations
   - Conditional blocks for cross-platform support
   - Template variables and data

3. Secret Management

   - Bitwarden integration patterns
   - Environment variable handling
   - Private file management

4. Script Management

   - Run scripts (run*once*, run*onchange*)
   - Installation scripts organization
   - Cross-platform script patterns

5. Repository Organization
   - Directory structure best practices
   - Config file categorization
   - Documentation patterns

**Supplementary Files**:

- `reference.md`: Complete chezmoi command reference
- `examples/`: Template patterns from this repository
- `patterns/`: Common dotfile scenarios

**Migration Notes**:

- Extract content from `agents/agent-definitions/chezmoi-expert.md`
- Reference this repository's structure as examples
- Document actual patterns used in this dotfiles setup

### 5. Testing Methodology Skill

**Location**: `~/.claude/skills/testing/SKILL.md`

**Purpose**: Language-agnostic testing methodologies and best practices

**Metadata**:

```yaml
name: testing
description:
  Expert guidance on testing methodologies, TDD/BDD, test organization, coverage
  strategies, and quality assurance practices
tags: [testing, tdd, bdd, quality-assurance, test-strategy]
```

**Core Content Sections**:

1. Testing Methodologies

   - Test-Driven Development (TDD): Red-Green-Refactor cycle
   - Behavior-Driven Development (BDD): Given-When-Then pattern
   - Property-based testing concepts
   - Integration vs unit vs E2E testing

2. Test Strategy Development

   - What to test vs what not to test
   - Coverage strategies (meaningful coverage vs metrics)
   - Risk-based testing approaches
   - Test organization and structure

3. Test Quality Principles

   - Test isolation and independence
   - Test readability (AAA pattern: Arrange-Act-Assert)
   - Test maintainability (DRY in tests)
   - Avoiding flaky tests

4. Mock/Stub Strategies

   - When to mock vs when to use real dependencies
   - Avoiding over-mocking
   - Test doubles patterns

5. Framework-Agnostic Best Practices

   - Clear test naming conventions
   - Descriptive failure messages
   - Fast test execution
   - Test data management (fixtures vs factories)

6. Common Test Smells
   - Test interdependence
   - Obscure tests
   - Fragile tests
   - Slow tests

**Supplementary Files**:

- `reference.md`: Testing terminology and comprehensive patterns
- `examples/`: Test structure examples by methodology
- `patterns/`: Common testing scenarios and approaches

**Migration Notes**:

- Extract methodology content from
  `agents/agent-definitions/test-expert.md:77-435`
- Remove agent coordination sections (skills don't coordinate)
- Keep pure methodology and strategy guidance
- Note: Language-specific testing patterns stay with language skills

## New Agent Creation

### 6. Codebase Explorer Agent

**Location**: `agents/agent-definitions/codebase-explorer.md`

**Purpose**: Fast pattern discovery, code search, and codebase structure
analysis

**Agent Definition**:

```yaml
---
name: codebase-explorer
description: >
  Fast codebase exploration and pattern discovery agent. Specializes in finding
  files, searching code, discovering patterns, and analyzing codebase structure.
  READ-ONLY agent focused on rapid information gathering and reporting.
model: sonnet
tools: Read, Glob, Grep, LS, NotebookRead
color: green
---
```

**Responsibilities**:

1. **File Discovery**: Use Glob to find files matching patterns
2. **Code Search**: Use Grep to search for code patterns and keywords
3. **Structure Analysis**: Map directory structure and relationships
4. **Pattern Discovery**: Identify common patterns and conventions
5. **Quick Reads**: Read multiple files to understand context

**Why This Agent**:

- Fills gap identified in research: Need for fast codebase exploration
- Complements Explore agent (which is task-specific)
- Provides read-only, focused search capabilities
- Useful for understanding existing patterns before implementation

**Tool Restrictions**:

- READ-ONLY: Cannot modify files
- No web access: Focuses on local codebase only
- No Task tool: Doesn't coordinate other agents (avoids complexity)

**Response Format**:

```markdown
## Codebase Exploration Results

### Search Summary

[What was searched and why]

### Key Findings

1. [Most relevant finding]
2. [Second finding]
3. [Third finding]

### File Locations

- [relevant file paths with descriptions]

### Pattern Analysis

[Common patterns discovered]

### Recommendations

[Suggested next steps based on findings]
```

## Documentation Updates

### 7. agents/AGENTS.md Updates

**Changes Required**:

1. **Update "Available Specialized Agents" section** (lines 72-100):

   - Remove elixir-expert, lua-expert, neovim-expert, chezmoi-expert,
     test-expert
   - Add note: "Domain knowledge now provided via Skills (see Skills section
     below)"

2. **Add new "Skills System" section** (after line 100):

   ```markdown
   ## Skills - Domain Knowledge Repository

   **PARADIGM**: Skills provide domain knowledge that Claude Code automatically
   loads based on context. Unlike agents (which are explicitly called), skills
   are passively available when needed.

   ### Available Skills

   #### **elixir** - Elixir, Phoenix, Ecto, Ash Expertise

   - **Auto-loads when**: Working with .ex, .exs files or Elixir projects
   - **Provides**: Language patterns, framework conventions, best practices
   - **Location**: ~/.claude/skills/elixir/
   - **Supplements**: Architecture decisions, code review, implementation
     guidance

   [Similar entries for lua, neovim, chezmoi, testing skills]

   ### Skills vs Agents

   **Skills** (passive knowledge):

   - Automatically loaded based on file context
   - Provide domain knowledge, patterns, conventions
   - No explicit orchestration needed
   - Read-only reference material

   **Agents** (active tools):

   - Explicitly called for specific tasks
   - Perform research, analysis, document creation
   - Coordinate multi-step workflows
   - Can modify system state or create artifacts
   ```

3. **Update Agent Selection Matrix** (line 389):

   - Add row for codebase-explorer agent
   - Update references from domain expert agents to skills
   - Note: "Consult skills automatically, agents explicitly"

4. **Update Orchestration Patterns** (lines 302-386):
   - Replace agent consultation language with skill reference
   - Example: "consult elixir-expert" → "leverage elixir skill knowledge"
   - Maintain agent orchestration for action-oriented tasks

### 8. Global CLAUDE.md Updates

**Location**: `~/.claude/CLAUDE.md` (global instructions)

**Changes Required**:

1. **Update "Specialized Agents" section**:

   - Move elixir-expert, lua-expert, neovim-expert, chezmoi-expert, test-expert
     to new "Skills" section
   - Keep action-oriented agents in "Agents" section

2. **Add new "Skills System" section**:

   ```markdown
   ## Skills - Automatic Domain Knowledge

   Skills provide domain expertise automatically based on context. You don't
   call skills - they're available whenever you need them.

   ### Available Skills

   - **elixir**: Elixir, Phoenix, Ecto, Ash patterns and best practices
   - **lua**: Lua language and Neovim plugin development
   - **neovim**: Editor configuration, plugins, LSP, workflow optimization
   - **chezmoi**: Dotfile management, templating, cross-platform config
   - **testing**: Testing methodologies, TDD/BDD, quality assurance

   Skills load automatically - you don't need to explicitly invoke them. Just
   work with relevant files and the skill knowledge becomes available.
   ```

3. **Update orchestration guidance**:
   - Remove "consult elixir-expert for patterns"
   - Add "use available skill knowledge for domain patterns"
   - Maintain agent consultation for actions (research, analysis, review)

## Implementation Strategy

### Phase 1: Skill Creation (High Priority)

**Order of Implementation**:

1. **Elixir skill** (highest value, most content)
2. **Testing skill** (used across projects)
3. **Neovim skill** (moderate complexity)
4. **Chezmoi skill** (project-specific but valuable)
5. **Lua skill** (smallest, complements Neovim)

**For Each Skill**:

1. Create directory structure: `~/.claude/skills/{skill-name}/`
2. Write SKILL.md with YAML frontmatter and core content
3. Create supplementary files (reference.md, examples/)
4. Test skill loading by working with relevant files
5. Validate skill provides correct guidance
6. Mark skill as completed

### Phase 2: Agent Creation (Medium Priority)

**Codebase Explorer Agent**:

1. Create `agents/agent-definitions/codebase-explorer.md`
2. Define agent specification with YAML frontmatter
3. Document search and exploration patterns
4. Define response format
5. Test agent with codebase exploration tasks
6. Validate read-only behavior

### Phase 3: Documentation Updates (High Priority)

**Parallel with Skill Creation**:

1. Update `agents/AGENTS.md` incrementally as skills are created
2. Add Skills section after first skill is validated
3. Update Agent Selection Matrix
4. Update orchestration patterns
5. Update global CLAUDE.md

### Phase 4: Validation & Testing (Highest Priority)

**After Each Skill**:

1. Work with relevant files to trigger automatic loading
2. Verify skill content is accessible and accurate
3. Check progressive disclosure is working (not loading all content)
4. Validate guidance matches original agent expertise

**After All Skills**:

1. Test multi-skill scenarios (e.g., Elixir + Testing)
2. Verify no knowledge gaps from migration
3. Compare token usage (skills should be more efficient)
4. User validation: Does the new system work better?

### Phase 5: Agent Archival (Low Priority)

**After Complete Validation**:

1. Create `agents/archived/` directory
2. Move original agent files to archive:
   - `elixir-expert.md` → `agents/archived/`
   - `lua-expert.md` → `agents/archived/`
   - `neovim-expert.md` → `agents/archived/`
   - `chezmoi-expert.md` → `agents/archived/`
   - `test-expert.md` → `agents/archived/`
3. Add README.md in archived/ explaining migration
4. Update any lingering references in commands

## Risk Mitigation

### Risk 1: Skill Content Gaps

**Mitigation**:

- Systematic content transfer with checklist
- Validation after each skill creation
- Keep archived agents as reference
- Easy rollback: just reference archived agents temporarily

### Risk 2: Skills Not Loading When Expected

**Mitigation**:

- Test each skill with relevant files immediately after creation
- Refine description/tags if skills don't activate correctly
- Document activation patterns in skill metadata

### Risk 3: Loss of Nuanced Agent Behavior

**Mitigation**:

- Carefully review each agent for unique patterns
- Preserve all critical guidelines and examples
- Test edge cases that agents handled well
- User feedback loop: adjust skills based on usage

### Risk 4: Documentation Drift

**Mitigation**:

- Update documentation incrementally with each skill
- Cross-reference between AGENTS.md and CLAUDE.md
- Document skill vs agent decision framework clearly
- Review documentation after migration complete

## Success Criteria

### Technical Success

- ✅ All 5 skills created with complete content
- ✅ Skills automatically load in appropriate contexts
- ✅ No content gaps compared to original agents
- ✅ Progressive disclosure reduces token usage
- ✅ Codebase-explorer agent functional and useful
- ✅ Documentation accurate and comprehensive

### Performance Success

- ✅ Faster context loading (skills vs agent orchestration)
- ✅ Lower token usage for domain knowledge access
- ✅ No noticeable delay in skill activation
- ✅ Skills provide same quality guidance as agents

### User Experience Success

- ✅ Domain knowledge feels "always available"
- ✅ No need to remember which agent to call for knowledge
- ✅ Clearer when to use agents vs relying on skills
- ✅ More efficient workflows for common tasks

## Rollback Plan

**If migration fails or causes issues**:

1. **Immediate Rollback**:

   - Reference archived agents in AGENTS.md
   - Update command instructions to use agents
   - Skills remain in place (no harm, just unused)

2. **Partial Rollback**:

   - Keep successful skills (e.g., Elixir, Testing)
   - Rollback problematic skills to agent pattern
   - Document which pattern works for which domain

3. **Learning & Adjustment**:
   - Analyze what went wrong
   - Adjust skill structure or content
   - Retry migration with improvements

## Timeline Estimate

**Assuming focused implementation**:

- **Phase 1**: Skill Creation - 2-3 hours

  - Elixir skill: 45 min
  - Testing skill: 30 min
  - Neovim skill: 30 min
  - Chezmoi skill: 20 min
  - Lua skill: 15 min

- **Phase 2**: Agent Creation - 30 minutes

  - Codebase-explorer: 30 min

- **Phase 3**: Documentation - 45 minutes

  - AGENTS.md updates: 25 min
  - CLAUDE.md updates: 20 min

- **Phase 4**: Validation - 30 minutes

  - Per-skill testing: 15 min
  - Integration testing: 15 min

- **Phase 5**: Archival - 10 minutes

**Total: ~4-5 hours of focused work**

## Next Steps

With this plan complete, proceed to **breakdown** phase to create detailed
implementation checklist with granular steps, file references, and validation
checkpoints.
