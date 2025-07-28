# Agents Folder System Implementation Plan

## Problem Statement

Create a centralized agents folder that's ignored by chezmoi, where we organize all agent-related files (workflow guidance, command files). Use chezmoi's symlinking feature to link files from the agents folder to their target locations.

## Solution Overview

Create an `agents/` folder structure that consolidates the current `dot_claude/` contents with a more agent-agnostic naming scheme. First, we need to preserve all existing commands from `~/.claude/commands/` that aren't currently tracked in the repository.

## Current State Analysis

### Commands Audit
**In `~/.claude/commands/` (live):**
- address_feedback.md, checkpoint.md, cleanup.md, commit.md, continue.md, feature.md, final-pass.md, fix.md, pr.md, reflect.md, step.md, task.md, update-docs.md (13 files)

**In repo `dot_claude/commands/`:**
- checkpoint.md, create_feature.md, create_fix.md (3 files)

**Missing from repo:**
- address_feedback.md, cleanup.md, commit.md, continue.md, feature.md, final-pass.md, fix.md, pr.md, reflect.md, step.md, task.md, update-docs.md (10 files)

### Current vs Target State

**Current State:**
- Root `CLAUDE.md` - project instructions (stays in place, already ignored)
- `dot_claude/CLAUDE.md` - workflow guidance → `~/.claude/CLAUDE.md`
- `dot_claude/commands/` - only 3 command files (incomplete)
- `~/.claude/commands/` - 13 command files (complete, but untracked)

**Target State:**
- Root `CLAUDE.md` - unchanged (project instructions)
- `agents/AGENTS.md` - agent-agnostic workflow guidance (ignored by chezmoi)
- `agents/commands/` - ALL 13+ command files (ignored by chezmoi)
- `symlink_CLAUDE.md.tmpl` in `dot_claude/` → points to `agents/AGENTS.md`
- `symlink_commands.tmpl` in `dot_claude/` → points to `agents/commands/`

## Technical Details

### Directory Structure
```
agents/                          # New, ignored by chezmoi
├── AGENTS.md                   # Renamed from dot_claude/CLAUDE.md
└── commands/                   # All commands from ~/.claude/commands/
    ├── address_feedback.md     # ← Copy from live
    ├── checkpoint.md           # ← Already in repo
    ├── cleanup.md              # ← Copy from live
    ├── commit.md               # ← Copy from live
    ├── continue.md             # ← Copy from live
    ├── create_feature.md       # ← Already in repo
    ├── create_fix.md           # ← Already in repo
    ├── feature.md              # ← Copy from live
    ├── final-pass.md           # ← Copy from live
    ├── fix.md                  # ← Copy from live
    ├── pr.md                   # ← Copy from live
    ├── reflect.md              # ← Copy from live
    ├── step.md                 # ← Copy from live
    ├── task.md                 # ← Copy from live
    └── update-docs.md          # ← Copy from live

dot_claude/                     # Existing, managed by chezmoi
├── symlink_CLAUDE.md.tmpl      # Updated to point to agents/AGENTS.md
└── symlink_commands.tmpl       # New, points to agents/commands/
```

### Symlink Templates
- `dot_claude/symlink_CLAUDE.md.tmpl`: `{{ .chezmoi.sourceDir }}/agents/AGENTS.md`
- `dot_claude/symlink_commands.tmpl`: `{{ .chezmoi.sourceDir }}/agents/commands`

## Implementation Plan

### Step 1: Preserve Existing Commands
- [ ] Create new feature branch `feat/agents-folder-system`
- [ ] Copy all missing commands from `~/.claude/commands/` to `dot_claude/commands/`
- [ ] Verify all 13 commands are now tracked in repository
- [ ] Commit this preservation step

### Step 2: Setup Infrastructure
- [ ] Create `agents/` directory
- [ ] Add `agents/` to `.chezmoiignore`

### Step 3: Migrate Files
- [ ] Move `dot_claude/CLAUDE.md` → `agents/AGENTS.md`
- [ ] Move all `dot_claude/commands/` → `agents/commands/`
- [ ] Update `dot_claude/symlink_CLAUDE.md.tmpl` to point to `agents/AGENTS.md`
- [ ] Create `dot_claude/symlink_commands.tmpl` for commands directory

### Step 4: Validation & Testing
- [ ] Run `chezmoi diff` to verify changes
- [ ] Apply changes and test symlinks work
- [ ] Verify all 13+ commands are accessible in `~/.claude/commands/`
- [ ] Test that agents can modify files without chezmoi conflicts

### Step 5: Documentation & Cleanup
- [ ] Update this plan with final status
- [ ] Commit changes with conventional commit message

## Success Criteria

- ✅ All existing commands preserved and tracked in repository
- ✅ Agent files organized under `agents/` directory with generic naming
- ✅ Symlinks correctly point from `~/.claude/` to agent files
- ✅ All 13+ commands accessible through symlinked directory
- ✅ AI assistants can modify files without chezmoi conflicts

## Notes

- **Critical**: Must preserve all existing commands before symlinking
- Pattern follows successful `lazy-lock.json` symlink implementation
- Root `CLAUDE.md` stays unchanged (project instructions, already ignored)

## Current Status
Planning complete, ready to begin with command preservation step.