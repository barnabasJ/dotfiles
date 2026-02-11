#!/usr/bin/env bash
set -euo pipefail

# Git Worktree Manager
# Generic git worktree operations — no language/framework-specific logic.
# Worktrees are created under .worktrees/ in the repo root.

WORKTREE_DIR=".worktrees"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  create <branch-name> [from-branch]  Create a new worktree for a branch
  list                                List all worktrees with branch info
  cleanup                             Remove worktrees for merged/deleted branches
  help                                Show this help message

Options:
  create:
    branch-name   Name of the branch to create/checkout
    from-branch   Base branch to create from (default: main)

Examples:
  $(basename "$0") create feature-auth
  $(basename "$0") create feature-auth develop
  $(basename "$0") list
  $(basename "$0") cleanup
EOF
}

ensure_git_repo() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: not inside a git repository" >&2
    exit 1
  fi
}

repo_root() {
  git rev-parse --show-toplevel
}

ensure_gitignore() {
  local root
  root="$(repo_root)"
  local gitignore="$root/.gitignore"

  if [ -f "$gitignore" ]; then
    if ! grep -qF "$WORKTREE_DIR/" "$gitignore"; then
      echo "" >> "$gitignore"
      echo "# Git worktrees" >> "$gitignore"
      echo "$WORKTREE_DIR/" >> "$gitignore"
      echo "Added $WORKTREE_DIR/ to .gitignore"
    fi
  else
    echo "# Git worktrees" > "$gitignore"
    echo "$WORKTREE_DIR/" >> "$gitignore"
    echo "Created .gitignore with $WORKTREE_DIR/"
  fi
}

cmd_create() {
  local branch_name="${1:?Error: branch name required}"
  local from_branch="${2:-main}"

  ensure_git_repo
  local root
  root="$(repo_root)"
  local worktree_path="$root/$WORKTREE_DIR/$branch_name"

  if [ -d "$worktree_path" ]; then
    echo "Error: worktree already exists at $worktree_path" >&2
    exit 1
  fi

  ensure_gitignore

  # Create the worktree directory
  mkdir -p "$root/$WORKTREE_DIR"

  # Check if branch already exists
  if git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null; then
    echo "Branch '$branch_name' exists, checking it out in worktree..."
    git worktree add "$worktree_path" "$branch_name"
  else
    echo "Creating new branch '$branch_name' from '$from_branch'..."
    git worktree add -b "$branch_name" "$worktree_path" "$from_branch"
  fi

  echo ""
  echo "Worktree created:"
  echo "  Path:   $worktree_path"
  echo "  Branch: $branch_name"
  echo ""
  echo "Next steps:"
  echo "  cd $worktree_path"
  echo "  # Run project-specific setup (e.g., elixir-worktree-setup.sh setup)"
}

cmd_list() {
  ensure_git_repo
  echo "Git worktrees:"
  echo ""
  git worktree list
}

cmd_cleanup() {
  ensure_git_repo
  local root
  root="$(repo_root)"
  local worktree_base="$root/$WORKTREE_DIR"

  if [ ! -d "$worktree_base" ]; then
    echo "No worktrees directory found at $worktree_base"
    return 0
  fi

  # First, prune stale worktree references
  git worktree prune

  local found=0
  for dir in "$worktree_base"/*/; do
    [ -d "$dir" ] || continue
    found=1

    local name
    name="$(basename "$dir")"
    local branch
    branch="$(git -C "$dir" branch --show-current 2>/dev/null || echo "unknown")"

    echo "Worktree: $name (branch: $branch)"
    echo "  Path: $dir"

    read -rp "  Remove this worktree? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      echo "  Removing worktree..."
      git worktree remove "$dir" --force 2>/dev/null || rm -rf "$dir"
      echo "  Removed."
    else
      echo "  Skipped."
    fi
    echo ""
  done

  if [ "$found" -eq 0 ]; then
    echo "No worktrees found in $worktree_base"
  fi

  # Final prune
  git worktree prune
}

# Main dispatch
case "${1:-help}" in
  create)
    shift
    cmd_create "$@"
    ;;
  list)
    cmd_list
    ;;
  cleanup)
    cmd_cleanup
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
