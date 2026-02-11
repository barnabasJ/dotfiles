---
name: elixir-troubleshooting
description: Elixir troubleshooting, debugging, and problem investigation
---

# Elixir Troubleshooting Expertise

Comprehensive guidance on troubleshooting Elixir applications, debugging issues,
tracing problems, and investigating unexpected behavior.

## Scratch Test File - The Primary Debugging Tool

**ALWAYS use a scratch test file for debugging - NEVER use `iex`, `mix run`, or
create new files:**

```elixir
# ✅ CORRECT - Use test/scratch_test.exs for all debugging
mix test test/scratch_test.exs

# ❌ INCORRECT approaches
iex -S mix              # Hard to iterate on multi-line code
mix run scratch.exs     # Use test framework instead
```

### Scratch Test File Setup

1. **Create `test/scratch_test.exs`** (if it doesn't exist)
2. **Add to `.gitignore`**:
   ```
   # Scratch test file
   test/scratch_test.exs
   ```
3. **Use for all debugging**:

   ```elixir
   # test/scratch_test.exs
   defmodule ScratchTest do
     use ExUnit.Case

     test "debug something" do
       alias MyApp.SomeModule

       # Your debugging code here
       result = SomeModule.function_to_debug(args)

       # Use dbg() for detailed inspection
       dbg(result)

       # Or IO.inspect with labels
       IO.inspect(result, label: "Result")
     end
   end
   ```

4. **Run with**: `mix test test/scratch_test.exs`

### Benefits of Scratch Test Approach

- **Single file to manage**: Always know where debug code lives
- **Git-ignored**: Never accidentally commit debug code
- **Easy iteration**: Edit and re-run without file management
- **Database sandbox**: Automatic rollback between tests
- **Full application context**: All modules and dependencies available
- **No cleanup needed**: Just overwrite for next debug session

**🚨 CRITICAL: This is the ONLY way to run debug/test code**

## Debugging Tools

### dbg() - The Modern Debugger (Elixir 1.14+)

**Prefer `dbg()` over `IO.inspect()` for debugging:**

```elixir
# ✅ PREFERRED - dbg() shows the expression AND result
value
|> transform()
|> dbg()  # Shows: transform(value) #=> result

# Also works inline
dbg(some_function(arg1, arg2))

# With pipes - shows each step
list
|> Enum.map(&String.upcase/1)
|> dbg()
|> Enum.filter(&String.starts_with?(&1, "A"))
|> dbg()
```

**dbg() advantages:**

- Shows the expression being evaluated, not just the result
- Works with pipes to show transformation steps
- Better formatted output
- Can be configured with custom backends

### IO.inspect/2 - Labeled Inspection

```elixir
# Always use labels for clarity
IO.inspect(value, label: "user data")

# Useful options
IO.inspect(value,
  label: "debug",
  limit: :infinity,      # Show all items in lists
  printable_limit: :infinity,  # Full strings
  pretty: true,          # Multi-line formatting
  syntax_colors: []      # Disable colors if needed
)

# In pipelines (returns the value unchanged)
data
|> IO.inspect(label: "before transform")
|> transform()
|> IO.inspect(label: "after transform")
```

### Bypassing the Inspect Protocol with `structs: false`

**Use `structs: false` to see the raw map underneath a struct:**

Custom `Inspect` implementations can hide fields or format data in ways that
obscure what's actually there. This is especially problematic when debugging.

```elixir
# Default - uses Inspect protocol (may hide data)
IO.inspect(user)
# => #User<email: "test@example.com", ...>

# ✅ BETTER FOR DEBUGGING - shows raw map structure
IO.inspect(user, structs: false)
# => %{__struct__: MyApp.User, email: "test@example.com", password_hash: "...", ...}

# Also works with dbg()
dbg(user, structs: false)
```

**When to use `structs: false`:**

- Struct shows `#SomeStruct<...>` with hidden fields
- You suspect the Inspect implementation is hiding data
- Debugging authentication/sensitive data structs
- Custom Inspect is causing infinite loops or errors
- You need to see the `__struct__` key and all fields

**Full debugging inspection options:**

```elixir
IO.inspect(value,
  structs: false,        # Show raw map, bypass Inspect protocol
  limit: :infinity,      # Show all items in collections
  printable_limit: :infinity,  # Full strings, no truncation
  pretty: true,          # Multi-line formatted output
  width: 120             # Wider lines before wrapping
)
```

### IEx.pry - Interactive Debugging

**Use pry for interactive debugging sessions:**

```elixir
# In your code
require IEx

def problematic_function(arg) do
  # Set breakpoint
  IEx.pry()

  # Code continues after pry...
  process(arg)
end
```

**Run with**: `iex -S mix test test/scratch_test.exs`

**In pry session:**

- `continue` or `c` - Continue execution
- `respawn` - Restart the shell
- Access all local variables directly
- Call functions to inspect state

### Process.info - Process Inspection

```elixir
# Get info about a process
Process.info(pid)

# Specific info
Process.info(pid, :message_queue_len)
Process.info(pid, :memory)
Process.info(pid, :current_stacktrace)

# All registered processes
Process.registered()
```

## Tracing and Observability

### :dbg Module (Erlang Tracing)

```elixir
# Trace all calls to a function
:dbg.tracer()
:dbg.p(:all, :c)
:dbg.tp(MyModule, :function_name, :x)

# Stop tracing
:dbg.stop()
```

### :recon - Production-Safe Tracing

```elixir
# Add to deps: {:recon, "~> 2.5"}

# Trace function calls (production-safe with limits)
:recon_trace.calls({MyModule, :function, :_}, 10)

# Process info
:recon.proc_count(:memory, 10)  # Top 10 by memory
:recon.proc_count(:message_queue_len, 10)  # Top 10 by mailbox size
```

### Observer - GUI Debugging

```elixir
# Start observer (requires wx)
:observer.start()

# Tabs available:
# - System: Overview of VM stats
# - Load Charts: CPU, memory, IO
# - Applications: Supervision trees
# - Processes: All processes with sorting
# - Table Viewer: ETS tables
# - Trace Overview: Function tracing
```

## Common Debugging Scenarios

### Debugging GenServers

```elixir
# In scratch test
test "debug genserver state" do
  # Get the pid
  pid = GenServer.whereis(MyServer)

  # Inspect state
  state = :sys.get_state(pid)
  dbg(state)

  # Get status (includes state + more)
  status = :sys.get_status(pid)
  dbg(status)

  # Trace calls to the GenServer
  :sys.trace(pid, true)
  # ... make calls ...
  :sys.trace(pid, false)
end
```

### Debugging LiveView

```elixir
# In the LiveView module, add temporary debug assigns
def handle_event("submit", params, socket) do
  dbg(params)
  dbg(socket.assigns)

  # ... rest of handler
end

# In template, inspect assigns
<%= inspect(@some_assign, pretty: true) %>
```

### Debugging Ecto Queries

```elixir
# Log the SQL being generated
query = from(u in User, where: u.active == true)
IO.inspect(Ecto.Adapters.SQL.to_sql(:all, Repo, query))

# Enable Ecto debug logging in config
config :my_app, MyApp.Repo, log: :debug

# In scratch test
test "debug query" do
  import Ecto.Query

  query =
    from u in User,
      where: u.email == ^email,
      preload: [:posts]

  # See the SQL
  {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  IO.puts("SQL: #{sql}")
  IO.inspect(params, label: "Params")

  # Execute and inspect
  result = Repo.all(query)
  dbg(result)
end
```

### Debugging Ash Resources

```elixir
test "debug ash action" do
  # Enable Ash debug logging
  Ash.Tracer.set_tracer(Ash.Tracer.Simple)

  # Run the action
  result = MyResource
    |> Ash.Changeset.for_create(:create, %{name: "test"})
    |> MyApi.create()

  case result do
    {:ok, record} ->
      dbg(record)
    {:error, error} ->
      # Ash errors have detailed info
      dbg(error)
      dbg(Ash.Error.to_error_class(error))
  end
end
```

## Reading Error Messages

### Common Error Patterns

**UndefinedFunctionError:**

```
** (UndefinedFunctionError) function MyModule.foo/1 is undefined or private
```

- Check module is compiled and loaded
- Check function arity (number of args)
- Check if function is `defp` (private)

**FunctionClauseError:**

```
** (FunctionClauseError) no function clause matching in MyModule.foo/1
```

- Pattern match failed
- Check the actual value vs expected patterns
- Add a catch-all clause for debugging

**KeyError:**

```
** (KeyError) key :foo not found in: %{bar: 1}
```

- Using `map.foo` syntax on map without that key
- Use `Map.get(map, :foo)` or `map[:foo]` for safe access

**Protocol.UndefinedError:**

```
** (Protocol.UndefinedError) protocol Enumerable not implemented for...
```

- Trying to enumerate something that isn't enumerable
- Check the actual type of your data

### Stack Trace Reading

```
** (RuntimeError) something went wrong
    (my_app 0.1.0) lib/my_app/module.ex:42: MyApp.Module.function/2
    (my_app 0.1.0) lib/my_app/other.ex:15: MyApp.Other.caller/1
    (phoenix 1.7.0) lib/phoenix/endpoint.ex:...
```

- Read top-to-bottom: first line is where error occurred
- `(app version)` shows which dependency
- `file:line` is clickable in most terminals
- Focus on YOUR code first (my_app), then framework code

## Performance Debugging

### Timing Code

```elixir
# Simple timing
{time_microseconds, result} = :timer.tc(fn ->
  expensive_operation()
end)
IO.puts("Took #{time_microseconds / 1000}ms")

# In scratch test
test "performance check" do
  {time, result} = :timer.tc(fn ->
    MyModule.slow_function()
  end)

  IO.puts("Execution time: #{time / 1000}ms")
  assert time < 1_000_000  # Less than 1 second
end
```

### Memory Profiling

```elixir
# Process memory
Process.info(self(), :memory)

# Word size (for calculating memory)
:erlang.system_info(:wordsize)

# Garbage collection
:erlang.garbage_collect(pid)
```

## Debugging Tips

1. **Start with the scratch test file** - Always reproduce the issue there first
2. **Use dbg() liberally** - It's easy to add and remove
3. **Check the data, not the code** - Most bugs are unexpected data
4. **Read error messages carefully** - Elixir errors are descriptive
5. **Check types** - Use `dbg()` or `IO.inspect()` to verify types
6. **Simplify** - Reduce the problem to smallest reproducing case
7. **Check the docs** - `h Module.function` in IEx shows docs
8. **Search HexDocs** - Most libraries have good documentation
