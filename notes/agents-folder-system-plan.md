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

### Step 1: Preserve Existing Commands ✅
- [x] Create new feature branch `feat/agents-folder-system`
- [x] Copy all missing commands from `~/.claude/commands/` to `dot_claude/commands/`
- [x] Verify all 15 commands are now tracked in repository
- [x] Commit this preservation step (a011552)

### Step 2: Setup Infrastructure ✅
- [x] Create `agents/` directory
- [x] Add `agents/` to `.chezmoiignore`

### Step 3: Migrate Files ✅
- [x] Move `dot_claude/CLAUDE.md` → `agents/AGENTS.md`
- [x] Move all `dot_claude/commands/` → `agents/commands/`
- [x] Update `dot_claude/symlink_CLAUDE.md.tmpl` to point to `agents/AGENTS.md`
- [x] Create `dot_claude/symlink_commands.tmpl` for commands directory

### Step 4: Validation & Testing ✅
- [x] Run `chezmoi diff` to verify changes
- [x] Apply changes and test symlinks work
- [x] Verify all 15+ commands are accessible in `~/.claude/commands/`
- [x] Test that agents can modify files without chezmoi conflicts

### Step 5: Documentation & Cleanup ✅
- [x] Update this plan with final status
- [x] Commit changes with conventional commit messages (10f3ae0, adb55da, d5823c6)

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

## Current Status - IMPLEMENTATION COMPLETED ✅

**Feature Successfully Implemented and Tested:**
- All 17 command files now tracked and accessible via symlinks
- Agents folder system fully functional with proper chezmoi ignore configuration
- External agents can modify files without version control conflicts
- Clean git history with logical commit progression

**Final Structure:**
```
agents/                    # Ignored by chezmoi
├── AGENTS.md             # Agent-agnostic workflow guidance
└── commands/             # 17 command files including new additions
    ├── address_feedback.md, checkpoint.md, cleanup.md, commit.md
    ├── continue.md, create_feature.md, create_fix.md, feature.md
    ├── final-pass.md, fix.md, fix-tests.md, pr.md, reflect.md
    ├── review.md, step.md, task.md, update-docs.md

dot_claude/               # Managed by chezmoi
├── symlink_CLAUDE.md.tmpl    → agents/AGENTS.md
└── symlink_commands.tmpl     → agents/commands/
```

**Implementation ready for merge to main branch.**