---
name: lua
description:
  Expert guidance on Lua language patterns, idioms, metatables, and Neovim
  plugin development with performance optimization
---

# Lua Expertise

Comprehensive guidance on Lua programming language, focusing on idiomatic
patterns, performance optimization, and Neovim plugin development.

## Core Language Fundamentals

### Data Types

Lua has 8 basic types:

- `nil` - absence of value
- `boolean` - true/false
- `number` - all numbers (integer and float)
- `string` - immutable text
- `function` - first-class functions
- `table` - the core data structure
- `thread` - coroutines
- `userdata` - C data

### Tables - The Core Data Structure

Tables are Lua's only compound data structure, serving as arrays, dictionaries,
objects, and more:

```lua
-- Tables as arrays
local array = {1, 2, 3, 4, 5}
print(#array)  -- 5 (length operator)

-- Tables as dictionaries
local dict = {
  name = "Lua",
  version = 5.4,
  ["multi-word key"] = true,
}

-- Mixed tables
local mixed = {
  10, 20, 30,  -- array part (indices 1, 2, 3)
  x = 100,     -- hash part
  y = 200,
}
```

## Metatables and Metamethods

Metatables enable powerful customization of table behavior:

```lua
local mt = {
  -- Arithmetic
  __add = function(a, b) end,      -- a + b
  __sub = function(a, b) end,      -- a - b
  __mul = function(a, b) end,      -- a * b

  -- Table access
  __index = function(t, k) end,    -- t[k]
  __newindex = function(t, k, v) end, -- t[k] = v
  __len = function(t) end,         -- #t

  -- Callable tables
  __call = function(t, ...) end,   -- t(...)

  -- String representation
  __tostring = function(t) end,    -- tostring(t)
}
```

**Practical Patterns:**

```lua
-- Read-only tables
local function readonly(t)
  return setmetatable({}, {
    __index = t,
    __newindex = function()
      error("Attempt to modify read-only table")
    end,
  })
end

-- Default values
local function withdefault(t, default)
  return setmetatable(t, {
    __index = function(t, k)
      return rawget(t, k) or default
    end,
  })
end
```

## Functions and Closures

### Function Features

```lua
-- Multiple returns
local function divmod(a, b)
  return math.floor(a / b), a % b
end

-- Variable arguments
local function printf(fmt, ...)
  io.write(fmt:format(...))
end

-- Named arguments pattern
local function create_window(opts)
  opts = opts or {}
  local width = opts.width or 800
  local height = opts.height or 600
  local title = opts.title or "Window"
end

-- Closures and upvalues
local function counter()
  local count = 0
  return function()
    count = count + 1
    return count
  end
end
```

## Module System

**Modern module pattern:**

```lua
local M = {}

-- Private variables
local private_var = 0

-- Private functions
local function private_func()
  return private_var
end

-- Public interface
function M.public_func()
  return private_func() + 1
end

-- Module initialization
function M.init(config)
  -- setup code
end

return M
```

## Object-Oriented Patterns

**Simple class implementation:**

```lua
local function class(base)
  local c = {}
  c.__index = c

  if base then
    setmetatable(c, {
      __index = base,
      __call = function(cls, ...)
        local self = setmetatable({}, cls)
        if self.init then
          self:init(...)
        end
        return self
      end,
    })
  else
    setmetatable(c, {
      __call = function(cls, ...)
        local self = setmetatable({}, cls)
        if self.init then
          self:init(...)
        end
        return self
      end,
    })
  end

  return c
end

-- Usage
local Animal = class()
function Animal:init(name)
  self.name = name
end

local Dog = class(Animal)
function Dog:speak()
  print(self.name .. " barks")
end
```

## Performance Optimization

### LuaJIT Optimization Tips

```lua
-- Cache global access with locals
local sin = math.sin  -- faster than repeated math.sin calls

-- Avoid table creation in loops
-- Bad
for i = 1, 1000000 do
  local t = {x = i, y = i}
  process(t)
end

-- Good
local t = {}
for i = 1, 1000000 do
  t.x = i
  t.y = i
  process(t)
end

-- Use FFI for performance-critical code
local ffi = require("ffi")
ffi.cdef[[
  typedef struct { double x, y; } point_t;
]]

local point = ffi.new("point_t")
point.x = 10
point.y = 20
```

## Error Handling

**Protected calls and error patterns:**

```lua
-- Protected calls
local status, result = pcall(function()
  return risky_operation()
end)

if not status then
  print("Error:", result)
else
  print("Success:", result)
end

-- Custom error objects
local function checked_divide(a, b)
  if b == 0 then
    error({
      code = "DIVISION_BY_ZERO",
      message = "Cannot divide by zero",
      values = {a = a, b = b}
    })
  end
  return a / b
end
```

## Functional Programming Patterns

```lua
-- Map
local function map(t, f)
  local result = {}
  for i, v in ipairs(t) do
    result[i] = f(v)
  end
  return result
end

-- Filter
local function filter(t, pred)
  local result = {}
  for i, v in ipairs(t) do
    if pred(v) then
      table.insert(result, v)
    end
  end
  return result
end

-- Reduce
local function reduce(t, f, init)
  local acc = init
  for i, v in ipairs(t) do
    acc = f(acc, v)
  end
  return acc
end
```

## Neovim Lua Integration

### Vim API Usage

```lua
-- Setting options
vim.opt.number = true
vim.opt.relativenumber = true

-- Creating keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })

-- Autocommands
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Creating commands
vim.api.nvim_create_user_command("Hello", function()
  print("Hello from Lua!")
end, {})
```

## Best Practices

1. **Always use local variables** - globals are slow and pollute namespace
2. **Cache library functions** - avoid repeated global lookups
3. **Preallocate tables** when size is known
4. **Use ipairs for arrays**, pairs for hash tables
5. **Avoid creating garbage** in hot loops
6. **Profile before optimizing** - measure don't guess

## Common Patterns

### Iterator Pattern

```lua
-- Custom iterator
local function range(from, to, step)
  step = step or 1
  return function(_, current)
    current = current + step
    if current <= to then
      return current
    end
  end, nil, from - step
end

-- Usage
for i in range(1, 10, 2) do
  print(i)  -- 1, 3, 5, 7, 9
end
```

### State Machines

```lua
local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new()
  return setmetatable({
    states = {},
    current = nil,
  }, self)
end

function StateMachine:add_state(name, state)
  self.states[name] = state
end

function StateMachine:transition(state_name)
  if self.current and self.current.exit then
    self.current:exit()
  end
  self.current = self.states[state_name]
  if self.current and self.current.enter then
    self.current:enter()
  end
end
```

## Coroutines

**Producer-consumer pattern:**

```lua
local function producer()
  return coroutine.create(function()
    for i = 1, 10 do
      coroutine.yield(i * i)
    end
  end)
end

local function consumer(prod)
  while true do
    local status, value = coroutine.resume(prod)
    if not status then break end
    print(value)
  end
end
```
