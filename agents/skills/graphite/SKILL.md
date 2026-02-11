---
name: graphite
description: Stacked PRs with Graphite CLI (gt)
---

# Graphite Stacked PRs

Manage development work as stacked pull requests using the Graphite CLI (`gt`).
Every task becomes a small, focused PR stacked on the previous one, enabling
fast review cycles and incremental merging.

## Core Philosophy

- **One task = one branch = one PR** — keep changes small and focused
- **Stack PRs** rather than creating independent branches — each PR builds on
  the last
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

## Workflow: Tasks as Stacked PRs

### Starting a New Stack

```bash
# Ensure you're on trunk and up to date
gt sync
gt checkout main

# Create your first task branch
# Make changes with your editor, then:
gt create --all --message "feat(scope): description of first task"

# Push and create the PR
gt submit
```

### Stacking the Next Task

```bash
# You're already on the first task's branch
# Make more changes, then stack on top:
gt create --all --message "feat(scope): description of next task"

# Push the entire stack
gt submit --stack
```

### Viewing Your Stack

```bash
# Compact stack view
gt log short
# or
gt ls

# Open current PR in browser
gt pr
```

### Navigating the Stack

```bash
gt up              # Move to child branch (one step up)
gt down            # Move to parent branch (one step down)
gt top             # Jump to top of stack
gt bottom          # Jump to bottom of stack
gt checkout        # Interactive branch picker
gt checkout NAME   # Jump to specific branch
```

## Modifying Work In-Stack

### Amending the Current Branch

```bash
# Stage and amend the current branch's commit
gt modify --all

# Or create a new commit on the branch
gt modify --all --commit --message "address review feedback"

# Push updates (restacks upstack branches automatically)
gt submit --stack
```

### Absorb: Auto-Route Changes to Right Commit

```bash
# Stage changes, then let Graphite figure out which commit they belong to
git add -A
gt absorb
```

### Inserting a Branch Mid-Stack

```bash
# Navigate to where you want to insert below
gt checkout parent-branch

# Create new branch — it inserts between parent and former child
gt create --all --message "fix(scope): inserted fix"

# Restack to fix the chain
gt restack
gt submit --stack
```

### Splitting a Branch

```bash
# Split current branch by commit, hunk, or file
gt split
```

### Folding a Branch Into Its Parent

```bash
# Merge current branch's changes into parent
gt fold
```

## Syncing and Rebasing

### Sync with Trunk

```bash
# Pull latest trunk, rebase all stacks, clean up merged branches
gt sync
```

Run `gt sync` frequently — it handles:

- Pulling latest changes into trunk
- Rebasing all open stacks onto new trunk
- Prompting to delete locally merged branches
- Surfacing merge conflicts for resolution

### Restack After Manual Changes

```bash
# Ensure parent chain integrity after manual git operations
gt restack
```

### Handling Conflicts

```bash
# If a restack or sync hits a conflict:
# 1. Resolve conflicts in your editor
# 2. Stage resolved files
git add .
gt continue

# Or abort the operation
gt abort
```

### Undo a Graphite Operation

```bash
gt undo
```

### Recovering from Merged Branch Blocking Submit

After a PR in the middle of a stack is merged (e.g., via GitHub squash merge),
`gt submit --stack` may fail with:

```
WARNING: PR for the following branch has already been merged but the merged
commits are not contained in the latest trunk branch main.
ERROR: Aborting non-interactive submit.
```

This happens because trunk has the squash-merged commit, but Graphite still sees
the original branch commits and cannot reconcile them automatically.

**Recovery steps:**

```bash
# 1. Pull trunk and clean up what Graphite can auto-detect
gt sync

# 2. If the merged branch still blocks submit, check your stack
gt log short

# 3. Go to the first unmerged branch above the stuck one
gt checkout <first-unmerged-branch>

# 4. Reparent it directly onto main (skipping the merged branch)
gt track --parent main

# 5. Restack to rebase all upstack branches onto the new parent chain
gt restack

# 6. Now submit works again
gt submit --stack --publish
```

**Why this works:** The merged branch's commits were squashed into a single
commit on trunk that does not match the original commits. Graphite cannot
automatically detect they are the same changes. By reparenting the first
unmerged child onto `main`, you tell Graphite to skip the stale branch and
rebase directly onto trunk, which already contains the merged work.

## Submitting and Merging

### Submit PRs

```bash
# Submit current branch only
gt submit

# Submit entire stack (recommended)
gt submit --stack

# Submit with reviewers
gt submit --stack --reviewers alice,bob

# Update PR title/body
gt submit --edit
```

### Merge

```bash
# Navigate to the top of what you want to merge
gt top
gt pr          # Opens in browser — click Merge

# Or merge from CLI
gt merge
```

After merging:

```bash
gt sync        # Cleans up merged branches, rebases remaining stack
```

## Command Quick Reference

### Core Workflow

| Command               | Alias  | Purpose                                    |
| --------------------- | ------ | ------------------------------------------ |
| `gt init`             |        | Initialize Graphite in a repo              |
| `gt create -am "msg"` | `gt c` | Create branch with all changes committed   |
| `gt modify -a`        | `gt m` | Amend current commit, auto-restack upstack |
| `gt submit`           | `gt s` | Push and create/update PR                  |
| `gt submit --stack`   |        | Push and create/update all PRs in stack    |
| `gt sync`             |        | Pull trunk, rebase stacks, clean merged    |

### Navigation

| Command                | Alias   | Purpose                   |
| ---------------------- | ------- | ------------------------- |
| `gt up [steps]`        | `gt u`  | Move to child branch      |
| `gt down [steps]`      | `gt d`  | Move to parent branch     |
| `gt top`               | `gt t`  | Jump to top of stack      |
| `gt bottom`            | `gt b`  | Jump to bottom of stack   |
| `gt checkout [branch]` | `gt co` | Interactive branch picker |
| `gt log short`         | `gt l`  | View stack tree           |

### Stack Management

| Command      | Alias   | Purpose                                  |
| ------------ | ------- | ---------------------------------------- |
| `gt restack` | `gt r`  | Fix parent chain integrity               |
| `gt absorb`  | `gt ab` | Route staged changes to correct commits  |
| `gt split`   | `gt sp` | Split branch by commit/hunk/file         |
| `gt squash`  | `gt sq` | Squash all commits into one              |
| `gt fold`    |         | Merge branch into parent                 |
| `gt move`    |         | Rebase branch onto different parent      |
| `gt reorder` |         | Reorder branches interactively           |
| `gt pop`     |         | Delete branch, keep working tree changes |

### Branch Management

| Command                | Alias    | Purpose                             |
| ---------------------- | -------- | ----------------------------------- |
| `gt delete [name]`     | `gt dl`  | Delete branch, restack children     |
| `gt rename [name]`     | `gt rn`  | Rename current branch               |
| `gt track [branch]`    | `gt tr`  | Start tracking branch with Graphite |
| `gt untrack [branch]`  | `gt utr` | Stop tracking branch                |
| `gt freeze [branch]`   |          | Prevent local modifications         |
| `gt unfreeze [branch]` |          | Re-enable modifications             |
| `gt get [branch]`      |          | Sync branches from remote           |

### PRs and Merging

| Command          | Purpose                     |
| ---------------- | --------------------------- |
| `gt pr [branch]` | Open PR in browser          |
| `gt merge`       | Merge PR stack via Graphite |
| `gt dash`        | Open Graphite dashboard     |

### Recovery

| Command       | Alias     | Purpose                          |
| ------------- | --------- | -------------------------------- |
| `gt continue` | `gt cont` | Resume after conflict resolution |
| `gt abort`    |           | Cancel in-progress rebase        |
| `gt undo`     |           | Undo last Graphite operation     |

## Agent Workflow: Executing Tasks as Stacked PRs

When given a list of tasks to implement:

1. **`gt sync`** — start from a clean, up-to-date trunk
2. **For each task**: a. Make the code changes b.
   `gt create --all --message "type(scope): description"` c. `gt submit --stack`
3. **Between tasks**: `gt sync` if trunk has advanced
4. **After review feedback**: `gt checkout branch`, fix, `gt modify -a`,
   `gt submit --stack`
5. **After merge**: `gt sync` to clean up

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
