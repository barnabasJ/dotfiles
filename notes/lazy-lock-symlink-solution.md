# Lazy-lock.json Symlink Solution

## Problem
The `lazy-lock.json` file in Neovim is frequently updated by lazy.nvim when packages are installed, updated, or removed. This creates conflicts with chezmoi because:
1. The file is managed by chezmoi but changed externally by Neovim
2. `chezmoi diff` always shows changes  
3. Manual intervention is required to sync changes
4. No automatic handling of external modifications

## Solution: Chezmoi External Modification Pattern
Use chezmoi's recommended approach for handling files modified by external programs.

### Implementation Steps (Updated)
1. ✅ Create planning document
2. ✅ Research chezmoi symlink syntax and best practices
3. ✅ Copy lazy-lock.json to chezmoi source directory (nvim config)
4. ✅ Add local_lazy-lock.json to .chezmoiignore
5. ✅ Rename file to local_lazy-lock.json to avoid conflicts
6. ✅ Create symlink from nvim config to source directory
7. ✅ Test the solution with chezmoi apply
8. ✅ Update documentation

### Technical Details (Final Implementation)
- **Source file location**: `private_dot_config/nvim/local_lazy-lock.json` (tracked in git)
- **Symlink location**: `~/.config/nvim/lazy-lock.json` (points to source)
- **Symlink file**: `private_dot_config/nvim/symlink_lazy-lock.json.tmpl`
- **Template content**: `{{ .chezmoi.sourceDir }}/private_dot_config/nvim/local_lazy-lock.json`
- **Ignore file**: `.chezmoiignore` contains `private_dot_config/nvim/local_lazy-lock.json`

### Benefits
- ✅ Neovim can freely update the lock file
- ✅ No conflicts with chezmoi
- ✅ Clean `chezmoi diff` output
- ✅ Automatic handling of external changes
- ✅ Lock file properly tracked in git with other nvim config
- ✅ Organized alongside other nvim files using `local_` prefix

### Final Solution
The implemented solution uses chezmoi's symlink functionality with the `local_` prefix pattern:
1. Neovim writes to `~/.config/nvim/lazy-lock.json` (symlink)
2. Changes are stored in `local_lazy-lock.json` in the nvim config source directory  
3. File is ignored by chezmoi but tracked in git
4. No naming conflicts due to `local_` prefix

This approach solves the original problem of handling externally modified files by allowing Neovim to update the lock file directly in the source directory while keeping it organized with other nvim configuration files.

### Implementation Lessons
During implementation, we encountered the "inconsistent state" error when having both a regular file and symlink template targeting the same location. This was resolved by using the `local_` prefix pattern to avoid conflicts in the source directory structure.