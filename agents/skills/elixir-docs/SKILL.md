---
name: elixir-docs
description: Elixir documentation search and lookup
---

# Elixir Documentation Search

Systematic approach to finding Elixir documentation and answers. Follow this
hierarchy from most authoritative to least.

## Search Hierarchy

**Always follow this order - stop when you find the answer:**

1. **Local deps folder** - Source code and docs in `deps/`
2. **Tidewave MCP** - If available, use for live documentation
3. **mix usage_rules** - Project-specific documentation
4. **HexDocs websearch** - Official package documentation
5. **Elixir Forum / DeepWiki** - Community knowledge
6. **General websearch** - Last resort

## 1. Local Deps Folder (First Choice)

**The most authoritative source - actual source code the project uses:**

```bash
# Find the module in deps
deps/<package_name>/lib/

# Examples:
deps/phoenix/lib/phoenix/controller.ex
deps/ecto/lib/ecto/query.ex
deps/ash/lib/ash/resource.ex
```

### Search Strategies

**Find a module:**

```elixir
# Module Phoenix.Controller is at:
deps/phoenix/lib/phoenix/controller.ex

# Module Ash.Resource is at:
deps/ash/lib/ash/resource.ex
```

**Search for a function:**

```bash
# Use Grep tool to find function definitions
# Pattern: def function_name or defp function_name
Grep pattern="def create_changeset" path="deps/ecto"
```

**Read module documentation:**

```bash
# Look for @moduledoc in the source file
# Look for @doc before function definitions
```

**Check typespecs:**

```bash
# Search for @spec definitions
Grep pattern="@spec function_name" path="deps/package"
```

### Common Package Locations

| Package          | Location                                        |
| ---------------- | ----------------------------------------------- |
| Phoenix          | `deps/phoenix/lib/phoenix/`                     |
| Phoenix LiveView | `deps/phoenix_live_view/lib/phoenix_live_view/` |
| Ecto             | `deps/ecto/lib/ecto/`                           |
| Ash              | `deps/ash/lib/ash/`                             |
| Plug             | `deps/plug/lib/plug/`                           |

## 2. Tidewave MCP (If Available)

**Check if Tidewave MCP tools are available in the current session.**

Tidewave provides live documentation lookup directly from the running
application:

- Function documentation
- Module documentation
- Typespec information
- Source code navigation

Use Tidewave tools when available as they provide context-aware documentation.

## 3. mix usage_rules (Project Documentation)

**Check for project-specific documentation rules:**

```bash
mix usage_rules doc search <topic>
```

This searches project-configured documentation sources which may include:

- Custom documentation
- Project-specific guides
- API documentation

**Note:** This command may not be available in all projects. Check if it exists
first.

## 4. HexDocs WebSearch

**Use WebSearch with hexdocs.pm, including version from mix.exs:**

### Get Package Versions First

```elixir
# Read mix.exs to find exact versions
# Look in deps function for version constraints

defp deps do
  [
    {:phoenix, "~> 1.7.10"},
    {:ecto, "~> 3.11"},
    {:ash, "~> 3.0"}
  ]
end
```

### Search HexDocs

```
# WebSearch with version-specific queries
WebSearch query="Phoenix.Controller render site:hexdocs.pm/phoenix/1.7"
WebSearch query="Ecto.Query join site:hexdocs.pm/ecto/3.11"
WebSearch query="Ash.Resource actions site:hexdocs.pm/ash/3.0"
```

### Direct HexDocs URLs

```
# Pattern: https://hexdocs.pm/{package}/{version}/{Module}.html

https://hexdocs.pm/phoenix/1.7.10/Phoenix.Controller.html
https://hexdocs.pm/ecto/3.11.0/Ecto.Query.html
https://hexdocs.pm/ash/3.0.0/Ash.Resource.html
```

**Use WebFetch to retrieve specific documentation pages.**

## 5. Elixir Forum & DeepWiki

### Elixir Forum

**Great for:**

- How-to questions
- Best practices
- Troubleshooting specific errors
- Community patterns

```
WebSearch query="<topic> site:elixirforum.com"
```

### DeepWiki MCP (If Available)

**Check if DeepWiki MCP tools are available.**

Use for repository-level documentation:

```
# For Elixir packages on GitHub
mcp__deepwiki__ask_question repoName="phoenixframework/phoenix" question="..."
mcp__deepwiki__ask_question repoName="ash-project/ash" question="..."
```

**Common repositories:**

| Package  | Repo                               |
| -------- | ---------------------------------- |
| Elixir   | elixir-lang/elixir                 |
| Phoenix  | phoenixframework/phoenix           |
| Ecto     | elixir-ecto/ecto                   |
| Ash      | ash-project/ash                    |
| LiveView | phoenixframework/phoenix_live_view |

## 6. General WebSearch (Last Resort)

**Only use when other sources fail:**

```
WebSearch query="Elixir <topic> <specific question>"
```

**Include year for recent information:**

```
WebSearch query="Elixir Phoenix 1.7 <topic> 2024"
```

## Quick Reference

### Finding Documentation for a Function

1. `Grep pattern="def function_name" path="deps/package"`
2. Read the file, look for `@doc` above the function
3. Check `@spec` for type information
4. If unclear, search HexDocs for examples

### Finding How to Use a Module

1. `Read deps/package/lib/package/module.ex`
2. Look at `@moduledoc` at the top
3. Look at public functions (`def`, not `defp`)
4. Check tests in `deps/package/test/` for usage examples

### Finding Configuration Options

1. Check `deps/package/lib/package/application.ex`
2. Search for `Application.get_env` calls
3. Check HexDocs configuration section
4. Look at the package's README in `deps/package/README.md`

## Tips

- **Always check deps first** - It's the exact version your project uses
- **Tests are documentation** - `deps/package/test/` shows real usage
- **README files** - `deps/package/README.md` often has quick start guides
- **CHANGELOG** - `deps/package/CHANGELOG.md` explains version differences
- **Version matters** - HexDocs has version-specific docs, use the right one
