---
name: charcoal
description: Stacked PRs with Charcoal CLI (charcoal)
---

# Charcoal Stacked PRs

Manage development work as stacked pull requests using the Charcoal CLI
(`charcoal`). Charcoal is an open-source (MIT), local-only fork of Graphite for
managing stacked PRs without external services.

## Overview

- **Repository:** `github.com/danerwilliams/charcoal`
- **Install:** `brew install danerwilliams/tap/charcoal`
- **Language:** TypeScript + Node
- **Works with:** GitHub, GitHub Enterprise, GitLab (experimental)
- **No external services** — uses Git + GitHub CLI credentials locally

## Core Philosophy

- **One task = one branch = one PR** — keep changes small and focused
- **Stack PRs** rather than creating independent branches
- **Submit early, submit often** — push and create PRs as you work
- **Sync frequently** — keep your stack rebased on trunk

## Key Terminology

| Term          | Meaning                                                     |
| ------------- | ----------------------------------------------------------- |
| **Trunk**     | Main branch (`main`/`master`) — base of all stacks          |
| **Stack**     | Chain of dependent branches, each building on the one below |
| **Upstack**   | Branches above the current one (depend on current)          |
| **Downstack** | Branches below the current one (current depends on)         |
| **Restack**   | Rebase all branches to maintain proper parent chain         |

## Workflow

### Starting a New Stack

```bash
charcoal sync
charcoal checkout main

# Make changes, then:
charcoal create --all --message "feat(scope): description of first task"

# Push and create the PR
charcoal submit
```

### Stacking the Next Task

```bash
# Already on first task's branch — make more changes, then:
charcoal create --all --message "feat(scope): description of next task"

# Push the entire stack
charcoal submit --stack
```

### Viewing Your Stack

```bash
charcoal log short    # Compact stack view
charcoal ls           # Alias
charcoal pr           # Open current PR in browser
```

### Navigating the Stack

```bash
charcoal up              # Move to child branch (one step up)
charcoal down            # Move to parent branch (one step down)
charcoal top             # Jump to top of stack
charcoal bottom          # Jump to bottom of stack
charcoal checkout        # Interactive branch picker
charcoal checkout NAME   # Jump to specific branch
```

## Modifying Work In-Stack

### Amending the Current Branch

```bash
# Stage and amend — auto-restacks upstack branches
charcoal modify --all
# or: charcoal modify -a

# Create a new commit on the branch instead
charcoal modify --all --commit --message "address review feedback"

# Push updates
charcoal submit --stack
```

### Inserting a Branch Mid-Stack

```bash
charcoal checkout parent-branch
charcoal create --all --message "fix(scope): inserted fix"
charcoal restack
charcoal submit --stack
```

### Splitting a Branch

```bash
charcoal split    # Split by commit, hunk, or file
```

### Folding a Branch Into Its Parent

```bash
charcoal fold     # Merge current branch's changes into parent
```

## Syncing and Rebasing

### Sync with Trunk

```bash
charcoal sync
```

Handles: pulling trunk, rebasing stacks, cleaning up merged branches.

### Restack After Manual Changes

```bash
charcoal restack
```

### Handling Conflicts

```bash
# 1. Resolve conflicts in your editor
# 2. Stage resolved files
git add .
charcoal continue

# Or abort
charcoal abort
```

### Undo

```bash
charcoal undo
```

## Submitting and Merging

```bash
# Submit current branch only
charcoal submit

# Submit entire stack
charcoal submit --stack

# Merge from CLI
charcoal merge

# After merging
charcoal sync
```

## Command Quick Reference

### Core Workflow

| Command                     | Purpose                                    |
| --------------------------- | ------------------------------------------ |
| `charcoal create -am "msg"` | Create branch with all changes committed   |
| `charcoal modify -a`        | Amend current commit, auto-restack upstack |
| `charcoal submit`           | Push and create/update PR                  |
| `charcoal submit --stack`   | Push and create/update all PRs in stack    |
| `charcoal sync`             | Pull trunk, rebase stacks, clean merged    |

### Navigation

| Command                      | Purpose                   |
| ---------------------------- | ------------------------- |
| `charcoal up [steps]`        | Move to child branch      |
| `charcoal down [steps]`      | Move to parent branch     |
| `charcoal top`               | Jump to top of stack      |
| `charcoal bottom`            | Jump to bottom of stack   |
| `charcoal checkout [branch]` | Interactive branch picker |
| `charcoal log short`         | View stack tree           |

### Stack Management

| Command              | Purpose                                |
| -------------------- | -------------------------------------- |
| `charcoal restack`   | Fix parent chain integrity             |
| `charcoal split`     | Split branch by commit/hunk/file       |
| `charcoal fold`      | Merge branch into parent               |
| `charcoal rebase -i` | Interactive rebase preserving children |

### Branch Management

| Command                     | Purpose                             |
| --------------------------- | ----------------------------------- |
| `charcoal delete [name]`    | Delete branch, restack children     |
| `charcoal rename [name]`    | Rename current branch               |
| `charcoal track [branch]`   | Start tracking branch with Charcoal |
| `charcoal untrack [branch]` | Stop tracking branch                |

### PRs and Merging

| Command          | Purpose               |
| ---------------- | --------------------- |
| `charcoal pr`    | Open PR in browser    |
| `charcoal merge` | Merge PR via Charcoal |

### Recovery

| Command             | Purpose                          |
| ------------------- | -------------------------------- |
| `charcoal continue` | Resume after conflict resolution |
| `charcoal abort`    | Cancel in-progress rebase        |
| `charcoal undo`     | Undo last Charcoal operation     |

## Agent Workflow: Executing Tasks as Stacked PRs

1. **`charcoal sync`** — start from a clean, up-to-date trunk
2. **For each task**: a. Make the code changes b.
   `charcoal create --all --message "type(scope): description"` c.
   `charcoal submit --stack`
3. **Between tasks**: `charcoal sync` if trunk has advanced
4. **After review feedback**: `charcoal checkout branch`, fix,
   `charcoal modify -a`, `charcoal submit --stack`
5. **After merge**: `charcoal sync` to clean up

### Commit Message Convention

Follow conventional commits:

```
feat(scope): add new feature
fix(scope): fix the bug
refactor(scope): restructure without behavior change
test(scope): add or update tests
docs(scope): documentation only
chore(scope): maintenance tasks
```

### PR Size Guidelines

- Aim for **< 800 lines changed** per PR
- Each PR should be **independently reviewable**
- Each PR should **compile and pass tests** on its own
- If a task is too large, split it into multiple stacked PRs
