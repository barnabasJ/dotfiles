# Worktree Skill

Git worktree management for parallel development with isolated databases and
ports.

## When to Use

- Working on multiple features simultaneously that need isolated environments
- Running `mix test` or `mix phx.server` in parallel across branches
- Avoiding database and port collisions between concurrent development sessions

## Architecture

Two scripts, one skill:

- **`worktree-manager.sh`** — Generic git worktree operations (any project type)
- **`elixir-worktree-setup.sh`** — Elixir/Phoenix config generation (database +
  port isolation)

Other project types can add their own setup scripts (e.g.,
`node-worktree-setup.sh`).

## Scripts Location

```
~/.local/share/chezmoi/agents/skills/worktree/scripts/
├── worktree-manager.sh          # Git worktree CRUD
└── elixir-worktree-setup.sh     # Elixir config + DB setup
```

## Quick Reference

### Worktree Manager Commands

```bash
SCRIPTS=~/.local/share/chezmoi/agents/skills/worktree/scripts

# Create a worktree
$SCRIPTS/worktree-manager.sh create <branch-name> [from-branch]

# List all worktrees
$SCRIPTS/worktree-manager.sh list

# Interactively remove worktrees
$SCRIPTS/worktree-manager.sh cleanup
```

### Elixir Setup Commands

```bash
# Generate local configs + create/migrate databases
$SCRIPTS/elixir-worktree-setup.sh setup [worktree-path] [worktree-name]

# Drop databases + remove local config files
$SCRIPTS/elixir-worktree-setup.sh teardown [worktree-path]

# Show current worktree's database + port
$SCRIPTS/elixir-worktree-setup.sh info [worktree-path]
```

## Full Workflow

### Create and Set Up

```bash
SCRIPTS=~/.local/share/chezmoi/agents/skills/worktree/scripts

# 1. Create worktree (from main by default)
$SCRIPTS/worktree-manager.sh create feature-auth

# 2. Set up Elixir environment (generates config, creates DB)
$SCRIPTS/elixir-worktree-setup.sh setup .worktrees/feature-auth feature-auth

# 3. Work in the worktree
cd .worktrees/feature-auth
mix phx.server  # Runs on unique port (9100-9999)
mix test         # Uses isolated test database
```

### Submit PR with Graphite

```bash
# Use --publish to avoid draft mode in non-interactive (agent) contexts
gt submit --stack --publish --ai
```

Without `--publish`, non-interactive `gt submit` creates PRs in draft mode.

### Teardown and Cleanup

```bash
# 1. Drop databases first
$SCRIPTS/elixir-worktree-setup.sh teardown .worktrees/feature-auth

# 2. Remove the worktree
$SCRIPTS/worktree-manager.sh cleanup
```

## What Gets Generated

### `config/dev.local.exs`

```elixir
import Config

config :app_name, AppName.Repo,
  database: "app_name_dev_<worktree_name>"

config :app_name, AppNameWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: <random_port>]
```

### `config/test.local.exs`

```elixir
import Config

config :app_name, AppName.Repo,
  database: "app_name_test_<worktree_name>#{System.get_env("MIX_TEST_PARTITION")}"
```

## Conventions

- **Worktree directory**: `.worktrees/<branch-name>` (gitignored)
- **Local config files**: `config/*.local.exs` (gitignored)
- **Dev port range**: 9100-9999 (avoids main dev port 9001 and test port 4002)
- **Database naming**: `<app>_{dev|test}_<worktree_name>`
- **Config loading**: Conditional `import_config` at the end of `dev.exs` /
  `test.exs` — no local files means no behavior change

## Project Requirements

For the local config override pattern to work, the project's `config/dev.exs`
and `config/test.exs` must include conditional imports at the end:

```elixir
# At the end of config/dev.exs
if File.exists?(Path.expand("dev.local.exs", __DIR__)) do
  import_config "dev.local.exs"
end
```

```elixir
# At the end of config/test.exs
if File.exists?(Path.expand("test.local.exs", __DIR__)) do
  import_config "test.local.exs"
end
```

And `.gitignore` should include:

```
config/*.local.exs
.worktrees/
```

## Adding Support for Other Project Types

Create a new setup script following the same pattern:

1. Takes a worktree path and name
2. Generates local config with unique database + port
3. Runs dependency install and database setup
4. Supports `setup`, `teardown`, and `info` commands

Example: `node-worktree-setup.sh` could generate a `.env.local` with unique
`DATABASE_URL` and `PORT`.
