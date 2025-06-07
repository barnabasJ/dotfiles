# Split Number Navigation Implementation Plan

## Problem Statement
Need a keybind that displays numbered overlays on each split and allows jumping to specific splits by pressing the corresponding number key. This will improve navigation efficiency when working with multiple splits.

## Solution Overview
Create a floating window overlay system that shows numbers on each split, then capture number keypresses to jump to the corresponding split. Use Neovim's floating window API for the overlays.

## Implementation Plan

### Step 1: Core Function Development
- [x] Create function to get all visible windows and their positions
- [x] Implement floating window creation for number overlays
- [x] Add logic to position overlays in the center of each split
- [x] Test basic overlay display functionality

### Step 2: Input Handling
- [x] Implement number key capture using vim.fn.getchar()
- [x] Add logic to map numbers to window IDs
- [x] Create jump-to-window functionality
- [x] Handle escape/cancel scenarios

### Step 3: Keybinding Integration
- [x] Add keybinding to trigger split number display
- [x] Choose appropriate key (<leader>wn for window navigation)
- [x] Update which-key description
- [x] Test keybinding doesn't conflict with existing ones

### Step 4: Polish and Error Handling
- [x] Add proper cleanup of floating windows
- [x] Handle edge cases (single window, invalid numbers)
- [x] Ensure overlays are visible on all colorschemes
- [x] Test with different split layouts

## Technical Details
- **Plugin Structure**: Create as proper Neovim plugin in `lua/barnabasj/lazy/split-navigator.lua`
- **Main Module**: `lua/split-navigator/init.lua`
- **Testing Framework**: Use plenary.nvim for testing
- **Integration**: Add to `lua/barnabasj/remap.lua` for keybinding
- **Dependencies**: 
  - plenary.nvim (for testing)
  - Built-in Neovim APIs
- **API calls**:
  - `vim.api.nvim_list_wins()` - Get all windows
  - `vim.api.nvim_open_win()` - Create floating overlays
  - `vim.fn.getchar()` - Capture number input
  - `vim.api.nvim_set_current_win()` - Jump to window

### Plugin Structure
```
lua/
├── barnabasj/
│   └── lazy/
│       └── split-navigator.lua  (plugin config)
└── split-navigator/
    ├── init.lua                 (main module)
    ├── config.lua              (configuration)
    └── utils.lua               (helper functions)
tests/
└── split-navigator/
    ├── init_spec.lua           (main tests)
    └── utils_spec.lua          (utility tests)
```

## Success Criteria
- Pressing keybind shows numbered overlays on each split
- Numbers are clearly visible and centered in each split
- Pressing a number immediately jumps to that split
- Pressing escape or invalid key cancels the operation
- Works with any number of splits (2-9 realistically)

## Notes
- Consider using contrasting colors for overlay visibility
- May want timeout for auto-cancel after a few seconds
- Could extend to include tab navigation in future
- Should handle splits in different tab pages appropriately