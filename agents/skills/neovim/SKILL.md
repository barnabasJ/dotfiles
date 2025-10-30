---
name: neovim
description:
  Expert guidance on Neovim configuration, plugin management, lazy.nvim, LSP
  setup, and editor workflow optimization
---

# Neovim Expertise

Comprehensive guidance on Neovim configuration, plugin ecosystem, and workflow
optimization.

## Configuration Architecture

### Directory Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/             # Core configuration
│   │   ├── options.lua     # vim.opt settings
│   │   ├── keymaps.lua     # Key mappings
│   │   ├── autocmds.lua    # Autocommands
│   │   └── lazy.lua        # Plugin manager setup
│   ├── plugins/            # Plugin specifications
│   └── utils/              # Utility functions
├── after/                  # After-directory scripts
│   └── ftplugin/          # Filetype-specific settings
└── snippets/              # Custom snippets
```

### Modular Configuration

```lua
-- init.lua
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

-- config/options.lua
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
```

## Plugin Management with lazy.nvim

### Bootstrap and Setup

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "plugins.lsp" },
  },
  defaults = { lazy = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml",
        "tutor", "zipPlugin",
      },
    },
  },
})
```

### Plugin Specification Pattern

```lua
return {
  "plugin/name",
  event = { "BufReadPre", "BufNewFile" },  -- Lazy load on these events
  dependencies = { "required/plugin" },
  opts = {
    -- Plugin options
  },
  config = function()
    -- Custom setup
  end,
}
```

## LSP Configuration

### LSP Setup Pattern

```lua
-- plugins/lsp/init.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "tsserver" },
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
    end,
  },
}
```

## Treesitter Integration

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "lua", "vim", "vimdoc", "query",
      "javascript", "typescript", "rust",
    },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = "<C-s>",
        node_decremental = "<C-backspace>",
      },
    },
  },
}
```

## Performance Optimization

### Startup Optimization

```lua
-- Defer shada loading
vim.opt.shadafile = "NONE"
vim.api.nvim_create_autocmd("CmdlineEnter", {
  once = true,
  callback = function()
    vim.opt.shadafile = ""
    vim.cmd.rshada({ bang = true })
  end,
})

-- Lazy load providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
```

### Lazy Loading Strategies

```lua
-- Load after startup
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.commands")
    require("config.abbreviations")
  end,
})
```

## Common Patterns

### Filetype-Specific Settings

```lua
-- after/ftplugin/python.lua
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

-- Python-specific keymaps
vim.keymap.set("n", "<leader>r", ":!python %<CR>", { buffer = true })
```

### Custom Commands

```lua
vim.api.nvim_create_user_command("Config", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit config" })

vim.api.nvim_create_user_command("Plugins", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/plugins/init.lua")
end, { desc = "Edit plugins" })
```

### Floating Windows

```lua
local function create_float()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    col = math.floor(vim.o.columns * 0.1),
    row = math.floor(vim.o.lines * 0.1),
    border = "rounded",
    style = "minimal",
  })
  return buf, win
end
```

### Custom Operators

```lua
-- Custom operator for surrounding
vim.keymap.set("n", "s", function()
  vim.o.operatorfunc = "v:lua.require'utils'.surround_operator"
  return "g@"
end, { expr = true })
```

## Best Practices

### Configuration Organization

- Separate concerns (options, keymaps, plugins)
- Use lazy loading for better startup time
- Prefer Lua over Vimscript for new configs
- Document complex configurations

### Plugin Selection

- Choose actively maintained plugins
- Prefer plugins with lazy loading support
- Avoid plugin overlap/conflicts
- Regular plugin updates and cleanup

### Performance

- Profile startup with `:Lazy profile`
- Lazy load language-specific plugins
- Minimize synchronous operations
- Use built-in features when possible

## Common Keybinding Patterns

```lua
-- Leader key patterns
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Common keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
```

## Autocommands

```lua
-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})
```

## Error Prevention

**Common Issues:**

1. **Startup Errors**: Use `pcall()` for optional features
2. **Plugin Conflicts**: Check for keybinding overlaps
3. **Performance**: Profile with `:Lazy profile`
4. **Compatibility**: Check Neovim version requirements
