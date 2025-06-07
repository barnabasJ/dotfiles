-- Minimal init for testing
vim.opt.rtp:prepend(vim.fn.getcwd())

-- Add the lua directory to package.path so we can require our modules
local lua_path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua"
package.path = lua_path .. ";" .. package.path