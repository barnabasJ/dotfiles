-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true
-- Make nvim indent automatically
vim.opt.smartindent = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
-- 	vim.opt.clipboard = "unnamedplus"
-- end)

-- Set the tab size to 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.wrap = false

-- Todo check if this is necessary
-- maybe this is faster if enough ram
-- is available
vim.opt.swapfile = false
vim.opt.backup = false

-- Save undo history
vim.opt.undofile = true
-- TODO check where the files are stored by default
-- vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"

-- Keep signcolumn on by default
-- not sure what this does
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.isfname:append("@-@")

vim.opt.colorcolumn = "120"

vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99

-- allow a bit of space between the last line and the bottom of the screen
vim.o.scrolloff = 8 -- For 8 lines of context
