# Neovim Warnings Fix Plan

## Issues to Fix

### 1. GitHub Copilot LSP Issue
- **Error**: `Client GitHub Copilot quit with exit code 126 and signal 0`
- **Log location**: `/Users/joba/.local/state/nvim/lsp.log`
- **Likely cause**: Configuration or installation issue with Copilot

### 2. Avante.nvim Configuration Deprecation Warnings
Multiple deprecated configuration options that need migration:

- `vendors.ollama` → `providers.ollama`
- `claude.temperature` → `providers.claude.extra_request_body.temperature`
- `claude.max_tokens` → `providers.claude.extra_request_body.max_tokens`
- `claude` → `providers.claude`

**Migration guide**: https://github.com/yetone/avante.nvim/wiki/Provider-configuration-migration-guide

## Implementation Steps
1. ✅ Create planning document
2. ✅ Check out new branch for warning fixes
3. ✅ Fix GitHub Copilot LSP configuration issue (Node.js version resolved)
4. ✅ Update avante.nvim configuration to new provider format
5. ✅ Test all configurations work without warnings
6. ⏳ Commit the warning fixes

## Files Updated
- ✅ `private_dot_config/nvim/lua/barnabasj/lazy/avante.lua` - Migrated to new provider configuration format
- ✅ `.chezmoidata/packages.yml` - Updated Node.js version to resolve LSP warnings

## Root Cause Analysis
1. **Avante.nvim warnings**: Plugin deprecated old configuration format (`vendors.*` and `claude.*` moved to `providers.*`)
2. **Node.js LSP error**: Version mismatch between asdf global and package list caused LSP clients to fail with exit code 126

## Solutions Applied
1. **Provider migration**: Updated avante configuration to use `providers.claude.extra_request_body.*` format
2. **Node.js version sync**: Updated package list to match installed Node.js version

## Expected Outcome
- ✅ Clean Neovim startup without warnings
- ✅ Updated configurations following current best practices  
- ✅ Maintained functionality for all affected plugins
- ✅ LSP clients working correctly with proper Node.js version