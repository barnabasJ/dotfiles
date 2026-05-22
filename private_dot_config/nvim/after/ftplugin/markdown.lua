-- Set the tab size to 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Fold by heading. Treesitter's markdown parser ships fold queries that
-- collapse each `#`/`##`/... section. Built-in mappings:
--   za toggle fold under cursor
--   zM close all  /  zR open all
--   zo open  /  zc close
-- foldlevel=99 starts with every fold open — buffer looks unchanged on
-- first open, but you can :set foldlevel=1 to collapse everything to
-- top-level headings.
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldenable = true
vim.opt_local.foldlevel = 99
