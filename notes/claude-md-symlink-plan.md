# CLAUDE.md Symlink Implementation Plan

## Objective
Create a symlink for the CLAUDE.md file in dot_claude directory, similar to the lazy-lock.json implementation.

## Background
We previously implemented a symlink solution for lazy-lock.json in the nvim configuration. We want to apply the same pattern for CLAUDE.md in the dot_claude directory.

## Implementation Steps

- [x] Create a new git branch for this feature (`feat/claude-md-symlink`)
- [x] Analyze the current CLAUDE.md file structure and location
- [x] Rename `CLAUDE.md` to `local_CLAUDE.md` using `mv` command
- [x] Create a symlink template file (`symlink_CLAUDE.md.tmpl`)
- [x] Update template content to point to `local_CLAUDE.md`
- [x] Add `dot_claude/local_CLAUDE.md` to `.chezmoiignore`
- [x] Test the symlink configuration with `chezmoi diff`
- [ ] Commit changes with conventional commit message
- [x] Update this plan with final implementation details

## Technical Details

### Current Structure
- Source file: `/home/joba/.local/share/chezmoi/dot_claude/local_CLAUDE.md` (renamed from CLAUDE.md)
- Target location: `~/.claude/CLAUDE.md` (will be a symlink)

### Symlink Template
- Template file: `symlink_CLAUDE.md.tmpl`
- Content: `{{ .chezmoi.sourceDir }}/dot_claude/local_CLAUDE.md`

### Implementation Pattern (Following lazy-lock.json approach)
1. Renamed `CLAUDE.md` to `local_CLAUDE.md` to avoid naming conflicts
2. Created symlink template pointing to the local file
3. Added `dot_claude/local_CLAUDE.md` to `.chezmoiignore`
4. This allows Claude Code to modify the file directly while keeping it in version control

### Testing
- Run `chezmoi diff` to preview changes
- Run `chezmoi apply` to create the symlink
- Verify symlink points to correct location with `ls -la ~/.claude/`
- Ensure file content is accessible through symlink

## Implementation Results
- Claude Code can now edit `~/.claude/CLAUDE.md` (the symlink)
- Changes are written to `local_CLAUDE.md` in the source directory
- File is tracked in git but ignored by chezmoi
- No more conflicts between chezmoi and external modifications

## Notes
- Following the exact same pattern as lazy-lock.json implementation
- Using the `local_` prefix convention to indicate externally modified files
- The symlink allows seamless editing while maintaining version control