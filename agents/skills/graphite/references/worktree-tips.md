# Using Graphite in Git Worktree Environments

## Overview

When using multiple git worktrees (e.g., for parallel feature development),
Graphite works normally but produces extra warnings that are **benign and can be
ignored**.

## Common Warnings

### Merged Branch in Another Worktree

```
WARNING: PR #59 for branch-name is merged but cannot be cleaned up
while it is checked out in another worktree.
```

**Meaning**: `gt sync` tried to delete a merged branch, but it's checked out in
a different worktree. This is safe to ignore — the branch will be cleaned up
when you run `gt sync` in that other worktree, or when you switch branches
there.

### Remote Parent Differs

```
WARNING: Non-interactive mode: skipping branch-name as it has a new
local parent ... that differs from the remote parent main and --force
was not provided.
```

**Meaning**: A branch's parent was changed locally (e.g., by reparenting) but
the remote still shows the old parent. Usually resolves on next `gt submit`.

## Best Practices

### Each Worktree Should Be on a Different Stack

Worktrees share the same git repo, so all stacks are visible everywhere. But
each worktree should work on its own independent stack to avoid conflicts.

### Run `gt sync` in Each Worktree Periodically

Since `gt sync` can only clean up branches that aren't checked out in the
current worktree, run it in each worktree to progressively clean up merged
branches.

### Don't Panic About Warning Count

A worktree environment with 3-4 active stacks may produce 5-10 warnings during
`gt sync`. This is normal. Focus on whether your **current stack** is clean.

### Check Your Stack, Not All Branches

```bash
# Shows only YOUR current stack — ignore warnings about other stacks/worktrees
gt log short
```
