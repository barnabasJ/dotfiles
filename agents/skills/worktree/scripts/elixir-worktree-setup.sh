#!/usr/bin/env bash
set -euo pipefail

# Elixir/Phoenix Worktree Setup
# Generates local config overrides (dev.local.exs / test.local.exs) with
# unique database names and ports for isolated worktree development.

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  setup [worktree-path] [worktree-name]  Generate local configs and set up database
  teardown [worktree-path]               Drop databases before worktree removal
  info [worktree-path]                   Show current worktree's database + port config

Options:
  worktree-path  Path to the worktree (default: current directory)
  worktree-name  Name for database/port derivation (default: directory basename)

Examples:
  $(basename "$0") setup
  $(basename "$0") setup .worktrees/feature-auth feature-auth
  $(basename "$0") teardown .worktrees/feature-auth
  $(basename "$0") info
EOF
}

detect_app_name() {
  local dir="$1"
  # Extract app name from mix.exs. Use perl for cross-platform regex —
  # macOS BSD grep does not support -P (Perl-compatible regex).
  if [ -f "$dir/mix.exs" ]; then
    perl -ne 'print "$1\n" if /app:\s*:(\w+)/' "$dir/mix.exs" | head -1
  else
    echo "unknown"
  fi
}

detect_repo_module() {
  local dir="$1"
  local app_name
  app_name="$(detect_app_name "$dir")"

  # Convert snake_case app name to CamelCase.Repo
  # e.g., logseq_mcp -> LogseqMcp.Repo
  # Use perl for case conversion — BSD sed does not support \U (GNU extension).
  local camel
  camel="$(echo "$app_name" | perl -pe 's/(?:^|_)([a-z])/\U$1/g')"
  echo "${camel}.Repo"
}

detect_endpoint_module() {
  local dir="$1"
  local app_name
  app_name="$(detect_app_name "$dir")"

  # Use perl for case conversion — BSD sed does not support \U (GNU extension).
  local camel
  camel="$(echo "$app_name" | perl -pe 's/(?:^|_)([a-z])/\U$1/g')"
  echo "${camel}Web.Endpoint"
}

random_port() {
  # Random port in range 9100-9999
  echo $(( RANDOM % 900 + 9100 ))
}

# Parse an existing dev.local.exs to recover its port, so re-runs preserve
# the port a session has already committed to memory, `.claude/launch.json`,
# and the tidewave MCP registration. Empty output ⇒ caller picks a new port.
parse_port_from_dev_config() {
  local config_file="$1"
  [ -f "$config_file" ] || return 0
  perl -ne 'print "$1\n" if /port:\s*(\d+)/' "$config_file" | head -1
}

# Atomic file write: stream stdin into $1 via a sibling temp file, then
# rename. Rename-on-same-filesystem is one syscall on POSIX, so concurrent
# writers end with exactly one winner instead of interleaved content.
atomic_write() {
  local target="$1"
  local tmp
  tmp="$(mktemp "${target}.XXXXXX")"
  if ! cat > "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$target"
}

sanitize_name() {
  # Convert worktree name to a safe database suffix
  # Replace non-alphanumeric chars with underscores, lowercase
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//;s/_$//'
}

link_path_deps() {
  local worktree_path="$1"
  local mix_file="$worktree_path/mix.exs"

  if [ ! -f "$mix_file" ]; then
    return 0
  fi

  # Find the repo root (the main worktree, not the linked worktree)
  local repo_root
  repo_root="$(git -C "$worktree_path" rev-parse --show-toplevel 2>/dev/null || true)"

  # For linked worktrees, git rev-parse returns the worktree path itself.
  # We need the main repo root to resolve relative path deps correctly.
  # Read the commondir to find the real repo root.
  local git_common
  git_common="$(git -C "$worktree_path" rev-parse --git-common-dir 2>/dev/null || true)"
  if [ -n "$git_common" ] && [ "$git_common" != ".git" ]; then
    # git_common is like /path/to/repo/.git — parent is the repo root
    repo_root="$(cd "$worktree_path" && cd "$git_common" && cd .. && pwd)"
  fi

  if [ -z "$repo_root" ]; then
    return 0
  fi

  # Extract path deps from mix.exs (matches: path: "../something"). Use perl
  # for cross-platform regex — macOS BSD grep does not support -P.
  local path_deps
  path_deps="$(perl -ne 'print "$1\n" while /path:\s*"([^"]+)"/g' "$mix_file" || true)"

  if [ -z "$path_deps" ]; then
    return 0
  fi

  echo "Linking path dependencies..."
  while IFS= read -r rel_path; do
    # Resolve the path relative to the repo root (where it was intended to resolve)
    local abs_dep
    abs_dep="$(cd "$repo_root" && cd "$rel_path" 2>/dev/null && pwd || true)"

    if [ -z "$abs_dep" ] || [ ! -d "$abs_dep" ]; then
      echo "  Warning: path dep '$rel_path' not found at repo root, skipping"
      continue
    fi

    # Check if it already resolves correctly from the worktree
    local worktree_resolved
    worktree_resolved="$(cd "$worktree_path" && cd "$rel_path" 2>/dev/null && pwd || true)"

    if [ "$worktree_resolved" = "$abs_dep" ]; then
      continue  # Already resolves correctly
    fi

    # Create the parent directory and symlink
    local link_target="$worktree_path/$rel_path"
    local link_parent
    link_parent="$(dirname "$link_target")"
    mkdir -p "$link_parent"

    if [ -e "$link_target" ]; then
      echo "  Skipping $rel_path (already exists)"
    else
      ln -s "$abs_dep" "$link_target"
      echo "  Linked $rel_path -> $abs_dep"
    fi
  done <<< "$path_deps"
}

cmd_setup() {
  local worktree_path="${1:-.}"
  worktree_path="$(cd "$worktree_path" && pwd)"

  local worktree_name="${2:-$(basename "$worktree_path")}"
  local safe_name
  safe_name="$(sanitize_name "$worktree_name")"

  # Concurrency guard: mkdir is atomic on POSIX. A SessionStart hook and a
  # manual `setup` invocation could otherwise race and stomp each other's
  # partial config writes. If someone else holds the lock, exit cleanly —
  # the winning run produces the same output we would have.
  local lock_dir="$worktree_path/.claude/.worktree-setup.lock"
  mkdir -p "$(dirname "$lock_dir")"
  if ! mkdir "$lock_dir" 2>/dev/null; then
    echo "Another worktree setup is already running for $worktree_path; skipping." >&2
    return 0
  fi
  # Expand $lock_dir now so the trap body doesn't need the local in scope
  # after cmd_setup returns (set -u would otherwise reject it).
  trap "rmdir '$lock_dir' 2>/dev/null || true" EXIT

  local app_name
  app_name="$(detect_app_name "$worktree_path")"
  local repo_module
  repo_module="$(detect_repo_module "$worktree_path")"
  local endpoint_module
  endpoint_module="$(detect_endpoint_module "$worktree_path")"

  # Preserve an existing port across re-runs: Claude sessions, MCP
  # registrations, and browser tabs have already pinned to it, and a fresh
  # random port would invalidate all of them.
  local port
  port="$(parse_port_from_dev_config "$worktree_path/config/dev.local.exs")"
  [ -z "$port" ] && port="$(random_port)"

  local dev_db="${app_name}_dev_${safe_name}"
  local test_db="${app_name}_test_${safe_name}"

  echo "Elixir Worktree Setup"
  echo "  App:       $app_name"
  echo "  Worktree:  $worktree_name ($safe_name)"
  echo "  Dev DB:    $dev_db"
  echo "  Test DB:   $test_db"
  echo "  Dev Port:  $port"
  echo ""

  # Generate config/dev.local.exs via temp-file-and-rename so concurrent
  # writers can't interleave output.
  local dev_config="$worktree_path/config/dev.local.exs"
  atomic_write "$dev_config" <<ELIXIR
import Config

# Auto-generated by elixir-worktree-setup.sh
# Worktree: $worktree_name

config :$app_name, $repo_module,
  database: "$dev_db"

config :$app_name, $endpoint_module,
  http: [ip: {127, 0, 0, 1}, port: $port]
ELIXIR
  echo "Created $dev_config"

  # Generate config/test.local.exs. A single unquoted heredoc is safe even
  # with Elixir's `#{...}` interpolation — bash only expands `$`, and the
  # payload has no `$` inside the `#{...}`. atomic_write prevents a
  # concurrent writer from interleaving.
  local test_config="$worktree_path/config/test.local.exs"
  atomic_write "$test_config" <<ELIXIR
import Config

# Auto-generated by elixir-worktree-setup.sh
# Worktree: $worktree_name

config :$app_name, $repo_module,
  database: "${test_db}#{System.get_env("MIX_TEST_PARTITION")}"
ELIXIR
  echo "Created $test_config"

  # Symlink path deps that use relative paths (e.g., path: "../ash_jobs")
  # Worktrees nested under .worktrees/ break relative path deps since
  # "../ash_jobs" resolves relative to the worktree, not the repo root.
  link_path_deps "$worktree_path"

  # Symlink gitignored env override files from the main repo
  local repo_root
  repo_root="$(git -C "$worktree_path" rev-parse --git-common-dir 2>/dev/null || true)"
  if [ -n "$repo_root" ] && [ "$repo_root" != ".git" ]; then
    repo_root="$(cd "$worktree_path" && cd "$repo_root" && cd .. && pwd)"
  else
    repo_root="$worktree_path"
  fi

  if [ "$repo_root" != "$worktree_path" ] && [ -d "$repo_root/envs" ]; then
    for override in "$repo_root"/envs/.*.overrides.env; do
      [ -f "$override" ] || continue
      local basename
      basename="$(basename "$override")"
      local target="$worktree_path/envs/$basename"
      if [ ! -e "$target" ]; then
        ln -s "$override" "$target"
        echo "Symlinked envs/$basename from main repo"
      fi
    done
  fi

  # Generate .claude/worktree.md for Claude context
  local claude_dir="$worktree_path/.claude"
  mkdir -p "$claude_dir"
  cat > "$claude_dir/worktree.md" <<WORKTREE_MD
# Worktree Context

This is an isolated git worktree, NOT the main repository.

- **Worktree name**: $worktree_name
- **Dev server port**: $port (NOT 9001)
- **Dev database**: $dev_db
- **Test database**: $test_db
- **Main repo**: $repo_root

When using Chrome DevTools or browser tools, navigate to \`http://localhost:$port\` (not 9001).
When referencing tidewave MCP, it runs on port $port.
WORKTREE_MD
  echo "Created $claude_dir/worktree.md"

  # Rewrite .claude/launch.json port so Claude Preview points at the
  # worktree's dev server instead of the main repo's (default 5555).
  local launch_json="$worktree_path/.claude/launch.json"
  if [ -f "$launch_json" ] && command -v jq >/dev/null 2>&1; then
    local tmp
    tmp="$(mktemp)"
    if jq --argjson port "$port" '(.configurations[] | select(has("port")) | .port) = $port' \
        "$launch_json" > "$tmp"; then
      mv "$tmp" "$launch_json"
      echo "Updated $launch_json (port $port)"
      # Mark assume-unchanged so the worktree-specific port doesn't show as dirty
      git -C "$worktree_path" update-index --assume-unchanged .claude/launch.json 2>/dev/null || true
    else
      rm -f "$tmp"
      echo "  Warning: could not update $launch_json — edit manually"
    fi
  fi

  # Register tidewave MCP server for this worktree's port. `claude mcp add`
  # refuses to overwrite an existing entry, so remove first (ignore failure if
  # absent) then add.
  if command -v claude >/dev/null 2>&1; then
    echo ""
    echo "Registering tidewave MCP server (port $port)..."
    # Unset CLAUDECODE to avoid env var guard when called from within a Claude session
    (
      cd "$worktree_path"
      unset CLAUDECODE
      claude mcp remove --scope project tidewave >/dev/null 2>&1 || true
      claude mcp add --transport http --scope project tidewave "http://localhost:${port}/tidewave/mcp"
    ) || \
      echo "  Warning: could not register tidewave MCP — register manually with: claude mcp remove --scope project tidewave; claude mcp add --transport http --scope project tidewave http://localhost:${port}/tidewave/mcp"
    # Mark .mcp.json as assume-unchanged so the worktree-specific port doesn't show as dirty
    git -C "$worktree_path" update-index --assume-unchanged .mcp.json 2>/dev/null || true
  fi

  # Initialize git submodules (worktrees don't auto-checkout submodules)
  if [ -f "$worktree_path/.gitmodules" ]; then
    echo ""
    echo "Initializing git submodules..."
    (cd "$worktree_path" && git submodule update --init --recursive)
  fi

  # Run deps.get + database setup
  echo ""
  echo "Running database setup..."
  (cd "$worktree_path" && mix deps.get && mix ecto.create && mix ecto.migrate)

  echo ""
  echo "Setup complete!"
  echo "  Dev server: cd $worktree_path && mix phx.server  (port $port)"
  echo "  Tests:      cd $worktree_path && mix test"
}

cmd_teardown() {
  local worktree_path="${1:-.}"
  worktree_path="$(cd "$worktree_path" && pwd)"

  if [ ! -f "$worktree_path/config/dev.local.exs" ] && [ ! -f "$worktree_path/config/test.local.exs" ]; then
    echo "No local config files found — nothing to tear down."
    return 0
  fi

  echo "Dropping databases for worktree at $worktree_path..."
  (cd "$worktree_path" && MIX_ENV=dev mix ecto.drop 2>/dev/null || true)
  (cd "$worktree_path" && MIX_ENV=test mix ecto.drop 2>/dev/null || true)

  # Remove local config files and worktree context
  rm -f "$worktree_path/config/dev.local.exs"
  rm -f "$worktree_path/config/test.local.exs"
  rm -f "$worktree_path/.claude/worktree.md"

  echo "Teardown complete. Local config files removed."
}

cmd_info() {
  local worktree_path="${1:-.}"
  worktree_path="$(cd "$worktree_path" && pwd)"

  echo "Worktree: $(basename "$worktree_path")"
  echo "Path:     $worktree_path"
  echo ""

  if [ -f "$worktree_path/config/dev.local.exs" ]; then
    echo "--- config/dev.local.exs ---"
    cat "$worktree_path/config/dev.local.exs"
    echo ""
  else
    echo "No dev.local.exs found (using default config)"
  fi

  if [ -f "$worktree_path/config/test.local.exs" ]; then
    echo "--- config/test.local.exs ---"
    cat "$worktree_path/config/test.local.exs"
    echo ""
  else
    echo "No test.local.exs found (using default config)"
  fi
}

# Main dispatch
case "${1:-help}" in
  setup)
    shift
    cmd_setup "$@"
    ;;
  teardown)
    shift
    cmd_teardown "$@"
    ;;
  info)
    shift
    cmd_info "$@"
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage
    exit 1
    ;;
esac
