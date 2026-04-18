# Identifying PRs in the Current Stack

## The Problem

Listing all open PRs returns **ALL** open PRs across **every** stack in the
repo. This is NOT the same as "PRs in the current stack."

A repo can have multiple independent stacks:

```
main
├── stack-A-branch-1 → stack-A-branch-2 → stack-A-branch-3   (Stack A: 3 PRs)
├── stack-B-branch-1 → stack-B-branch-2                      (Stack B: 2 PRs)
└── stack-C-branch-1                                          (Stack C: 1 PR)
```

Listing all open PRs here returns **6 PRs**. But if you're on
`stack-A-branch-2`, your current stack only has **3 PRs**.

## Correct Approach

### Step 1: Get the current stack's branches

```bash
# Shows ONLY branches in the current stack (the linear chain)
gt log short
```

Example output:

```
02-12-feat_agent_lua_sandbox (current)
│
02-12-feat_agent_shell_exec
│
02-12-feat_agent_file_system
│
main
```

This tells you the stack has exactly **3 branches** (excluding main).

### Step 2: Map branches to PR numbers

Use the `gh-pr-info` skill to get PR numbers for each branch:

```bash
SCRIPT=~/.claude/skills/gh-pr-info/scripts/get-pr-info.sh

# Get PR number for a specific branch
$SCRIPT pr-for-branch <branch-name>

# Or list all open PRs and filter to only stack branches
$SCRIPT list-open
# Then cross-reference: only include PRs whose branch matches gt log short output
```

### Step 3: Build the branch→PR map

The result should be a map like:

```
02-12-feat_agent_lua_sandbox    → PR #25
02-12-feat_agent_shell_exec     → PR #24
02-12-feat_agent_file_system    → PR #23
```

## Common Mistakes

### Wrong: Counting all open PRs as "the stack"

All open PRs includes PRs from other stacks. If you have multiple stacks, this
count will be wrong.

### Wrong: Not running `gt log short` first

Without `gt log short`, you have no way to know which branches belong to the
current stack vs other independent stacks.

### Wrong: Using `gt ls` alone

`gt ls` shows all tracked branches, which may include branches from other
stacks. Use `gt log short` to see only the current stack's linear chain.

## Quick Reference

| Task                          | How                                       |
| ----------------------------- | ----------------------------------------- |
| See current stack branches    | `gt log short`                            |
| Get PR for current branch     | `gh-pr-info` → `pr-for-branch`            |
| Get PR for specific branch    | `gh-pr-info` → `pr-for-branch <branch>`   |
| Count PRs in current stack    | Count non-trunk lines from `gt log short` |
| Get all open PRs (all stacks) | `gh-pr-info` → `list-open`                |
