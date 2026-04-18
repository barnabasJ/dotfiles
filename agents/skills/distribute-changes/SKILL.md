---
name: distribute-changes
description:
  Distribute uncommitted changes across a Graphite stack using a backup branch
user_invocable: true
---

# Distribute Changes Across a Graphite Stack

Take a batch of uncommitted changes and distribute them across existing and/or
new branches in a Graphite stack. Uses a backup branch as a safe reference
point.

## When to Use

- After a spike, E2E testing session, or prototyping where you accumulated
  changes that span multiple PRs
- When you have uncommitted changes on a stack branch that belong to different
  PRs in the stack
- When you need to split a large set of changes into focused, reviewable PRs

## Arguments

Optional: `[description]` — a short label for the backup branch (defaults to
`"changes"`).

## Workflow

### Phase 1: Create Backup Branch

First, preserve all uncommitted changes in a backup branch.

```bash
# Create backup branch and commit everything
git checkout -b backup/<description>-<date>
git add -A
git commit -m "backup: all uncommitted changes from <description>"

# Return to the original branch
git checkout <original-branch>
```

If changes are already committed on the current branch and just need splitting,
skip the backup — the current branch IS the backup.

### Phase 2: Analyze and Group Changes

List all changed files and group them by destination:

```bash
# See all files in the backup
git diff HEAD backup/<name> --name-only
```

Group each file into one of:

- **Existing PR (amend)** — file was introduced or primarily modified by an
  existing branch in the stack
- **New PR (create)** — file is new work that doesn't belong in any existing PR

**Decision rules:**

- If the change **fixes or extends** code from an existing PR → amend that PR
- If the change **reverses or replaces** work from an existing PR → new PR on
  top (don't change the existing PR's purpose)
- Cross-cutting files (config, mix.exs) → place in the PR that introduces the
  need for the change
- When in doubt → new PR on top

Present the grouping to the user for approval before proceeding.

### Phase 3: Distribute to Existing PRs (Bottom-Up)

Process existing PRs from bottom to top of the stack:

```bash
# 1. Switch to the target branch
gt checkout <branch-name>

# 2. Pull specific files from the backup
git checkout backup/<name> -- \
  path/to/file1.ex \
  path/to/file2.ex

# 3. Amend the branch
gt modify --all

# 4. If restack conflicts occur, resolve them
git add .
gt continue
```

Repeat for each existing branch that needs changes.

**Verify progress** after each branch:

```bash
git diff HEAD backup/<name> --name-only
```

### Phase 4: Create New PRs (Top of Stack)

For changes that don't belong in any existing PR:

```bash
# 1. Go to the top of the stack
gt top

# 2. Pull files for the first new PR
git checkout backup/<name> -- \
  path/to/new_file1.ex \
  path/to/new_file2.ex

# 3. Create a new stacked branch
gt create --all --message "type(scope): description"

# 4. Repeat for additional new PRs
git checkout backup/<name> -- path/to/other_files.ex
gt create --all --message "type(scope): other changes"
```

### Phase 5: Submit and Verify

```bash
# Submit the entire stack
gt submit --stack --publish --ai

# Verify no files remain undistributed
git diff HEAD backup/<name> --name-only
# Should be empty (or only show the backup commit itself)

# Confirm clean state
git status
gt log short
```

## Special Cases

### Submodule Changes

If changes include git submodules, handle them first — commit directly in the
submodule before distributing main repo changes:

```bash
cd packages/<submodule>
git add <files>
git commit -m "fix(scope): description"
cd ../..
```

### Selective Staging (No Backup Branch)

When changes are small and still unstaged, skip the backup branch and use
selective staging:

```bash
# Stage only files for this PR
git add path/to/file1.ex path/to/file2.ex
gt create -m "feat(scope): first group"

# Stage next group
git add path/to/file3.ex
gt create -m "fix(scope): second group"

gt submit --stack --publish --ai
```

## Rules

- **Always create a backup branch** for large change sets (> 10 files) — it's
  your safety net
- **Process existing PRs bottom-up** — amending a lower branch triggers restack
  of everything above it
- **Expect restack conflicts** — they're normal after amending lower branches
- **Never use `git checkout stash@{0} -- <file>`** — it brings the entire file
  from stash, leaking changes from other branches
- **Verify after each branch** — check remaining files with `git diff`
- **Present the grouping to the user** before executing — let them approve which
  files go where
