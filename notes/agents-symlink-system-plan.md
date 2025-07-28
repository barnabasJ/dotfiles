# Agents Symlink System Implementation Plan

## Problem Statement

Apply the same organizational pattern we used for commands to agents themselves. Currently, agent definition files (like `elixir-code-reviewer.md`) exist in `~/.claude/agents/` but aren't tracked in the repository. We need to organize them using the same symlink approach as commands.

## Solution Overview

Create a symlink system for agent definition files that mirrors the commands approach. Move agent files from `~/.claude/agents/` to the repository's `agents/` folder and symlink the directory back, allowing version control while maintaining external editability.

## Current vs Target State

### Current State
- `~/.claude/agents/elixir-code-reviewer.md` - agent definition (untracked)
- `agents/` directory in repository (only contains AGENTS.md and commands/)
- No symlink for agents directory

### Target State  
- `agents/agent-definitions/` - agent definition files in repository (ignored by chezmoi)
- `symlink_agents.tmpl` in `dot_claude/` → points to `agents/agent-definitions/`
- All agent files tracked and version controlled
- External tools can modify agents without chezmoi conflicts

## Technical Details

### Directory Structure
```
agents/                          # Ignored by chezmoi
├── AGENTS.md                   # Agent workflow guidance (existing)
├── commands/                   # Command files (existing)
│   ├── create_feature.md, etc.
└── agent-definitions/          # NEW: Agent definition files
    └── elixir-code-reviewer.md

dot_claude/                     # Managed by chezmoi
├── symlink_CLAUDE.md.tmpl      # → agents/AGENTS.md (existing)
├── symlink_commands.tmpl       # → agents/commands/ (existing)  
└── symlink_agents.tmpl         # NEW: → agents/agent-definitions/
```

### Symlink Template
- `dot_claude/symlink_agents.tmpl`: `{{ .chezmoi.sourceDir }}/agents/agent-definitions`

### Agent File Format
Agent files are markdown with YAML frontmatter:
```yaml
---
name: elixir-code-reviewer
description: Use this agent when reviewing Elixir code...
tools: Task, Bash, Glob, Grep, LS, ExitPlanMode, Read...
color: purple
---
Content...
```

## Benefits

✅ **Consistent organization**: Agents follow same pattern as commands  
✅ **Version control**: Agent definitions tracked in git  
✅ **External compatibility**: Claude Code can modify agents without conflicts  
✅ **Centralized management**: All agent-related files in one place  
✅ **Scalable**: Easy to add new agent definitions

## Implementation Plan

### Step 1: Infrastructure Setup
- [ ] Create new feature branch `feat/agents-symlink-system`
- [ ] Create `agents/agent-definitions/` directory structure
- [ ] Ensure `agents/` is already ignored by chezmoi (already done)

### Step 2: Agent Migration
- [ ] Copy existing agents from `~/.claude/agents/` to `agents/agent-definitions/`
- [ ] Verify agent file format and content preserved
- [ ] Document discovered agent files

### Step 3: Symlink Configuration
- [ ] Create `dot_claude/symlink_agents.tmpl` pointing to agent definitions
- [ ] Update target path to be `~/.claude/agents/`

### Step 4: Testing & Validation
- [ ] Test symlink functionality with `chezmoi diff`
- [ ] Verify Claude Code can find and use agents 
- [ ] Test agent modification doesn't break chezmoi
- [ ] Confirm version control integration works

### Step 5: Documentation
- [ ] Update planning document with final status
- [ ] Commit changes with conventional commits
- [ ] Document agent addition process

## Success Criteria

- ✅ All agent definition files tracked in repository
- ✅ Symlink correctly points from `~/.claude/agents/` to agent definitions  
- ✅ Claude Code can find and load agents normally
- ✅ External agents can modify definitions without chezmoi conflicts
- ✅ Pattern matches commands implementation exactly

## Notes

- Follows exact same pattern as commands symlink system
- Agent files use YAML frontmatter + markdown format
- Directory name `agent-definitions` avoids confusion with `agents/` root folder
- Future: Could add agent templates or scaffolding tools

## Current Status
Planning complete, ready to begin implementation.