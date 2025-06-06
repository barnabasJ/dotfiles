# nvim-cmp → blink.cmp Migration Plan

## Overview
Migrating from nvim-cmp to blink.cmp for better performance and built-in sources.

## Current Setup Analysis

### Files to Modify
- `/lua/barnabasj/lazy/cmp.lua` - Main completion config
- `/lua/barnabasj/lazy/mason.lua` - LSP capabilities setup
- Potentially AI tool configs (avante, codecompanion)

### Current nvim-cmp Dependencies
```lua
-- Core plugins to remove:
'hrsh7th/nvim-cmp'
'hrsh7th/cmp-nvim-lsp'
'hrsh7th/cmp-path'
'hrsh7th/cmp-buffer'
'hrsh7th/cmp-cmdline'
'saadparwaiz1/cmp_luasnip'

-- Keep:
'L3MON4D3/LuaSnip' -- snippet engine (blink supports it)
```

### Current Key Mappings
- `<C-n>` / `<C-p>`: Navigate completions
- `<C-b>` / `<C-f>`: Scroll docs
- `<C-y>`: Accept completion
- `<C-Space>`: Manual trigger
- `<C-l>` / `<C-h>`: Snippet navigation

## Migration Steps

### 1. Install blink.cmp
```lua
{
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',
  version = '*',
}
```

### 2. Basic Configuration
```lua
opts = {
  keymap = { preset = 'default' },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono'
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- SQL-specific config may be needed
    cmdline = {}
  },
  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
  },
  snippets = {
    expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
    active = function(filter)
      if filter and filter.direction then
        return require('luasnip').jumpable(filter.direction)
      end
      return require('luasnip').in_snippet()
    end,
    jump = function(direction) require('luasnip').jump(direction) end,
  },
}
```

### 3. LSP Capabilities Update
```lua
-- In mason.lua, replace:
-- capabilities = require('cmp_nvim_lsp').default_capabilities()
-- With:
capabilities = require('blink.cmp').get_lsp_capabilities()
```

### 4. Special Considerations

#### SQL Completions
- Current setup uses `vim-dadbod-completion`
- May need custom source configuration for blink.cmp
- Or keep vim-dadbod-completion separate

#### AI Tool Compatibility
- Check if Avante and CodeCompanion work with blink.cmp
- May need updates to their configurations

#### Command Line Completion
- blink.cmp has built-in cmdline support
- Current nvim-cmp cmdline config may need translation

## Key Benefits of Migration

1. **Performance**: 0.5-4ms completion updates vs nvim-cmp's slower responses
2. **Built-in Sources**: No need for separate buffer, path, LSP plugins
3. **Typo Resistance**: Better fuzzy matching with SIMD-optimized frizbee
4. **Batteries Included**: Works out of box with minimal config

## Potential Issues

1. **Breaking Changes**: AI plugins that depend on nvim-cmp APIs
2. **Custom Sources**: Any custom completion sources will need porting
3. **Keybinding Changes**: May need to adjust some mappings
4. **Documentation**: Less community documentation vs mature nvim-cmp

## Testing Checklist

- [ ] LSP completions work across all languages
- [ ] Snippet expansion and navigation
- [ ] File path completions
- [ ] Buffer text completions
- [ ] Command line completions
- [ ] SQL completions (if applicable)
- [ ] AI tool integrations still work
- [ ] Performance feels snappier
- [ ] No error messages or warnings

## Rollback Plan

If issues arise:
1. Revert to nvim-cmp configuration
2. Keep backup of current cmp.lua file
3. Document any incompatibilities found

## Timeline

1. **Phase 1**: Create new blink.cmp config (test branch)
2. **Phase 2**: Update LSP integration
3. **Phase 3**: Remove old nvim-cmp plugins
4. **Phase 4**: Test all completion scenarios
5. **Phase 5**: Merge if successful, or rollback