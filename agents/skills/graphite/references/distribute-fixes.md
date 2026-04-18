# Distributing Fixes Across Stacked PRs

## The Problem

After testing, you find bugs that need to be fixed on different branches in the
stack. The fixes must land on the correct branch (the one that introduced the
code), not just the top branch.

## Approach: Targeted Edits Per Branch

The safest approach is to navigate to each branch and make surgical edits.

### Step 1: Identify which branch owns each fix

```bash
# See the full stack
gt log short

# Check which branch introduced a file or change
git log --oneline --follow path/to/file.ex
```

### Step 2: Stash any uncommitted work

```bash
# Save current uncommitted changes
git stash --include-untracked
```

### Step 3: Navigate to the target branch

```bash
gt checkout target-branch-name
```

### Step 4: Make the fix

Edit the files directly on that branch. Do NOT use
`git checkout stash@{0} -- <file>` — this brings the **entire file** from the
stash, which includes changes from higher branches that don't belong on this
branch.

### Step 5: Amend the branch

```bash
gt modify --all
```

This amends the current branch's commit and automatically restacks upstack
branches.

### Step 6: Handle restack conflicts

After `gt modify --all`, upstack branches may have conflicts because the base
changed. This is expected.

```bash
# If conflicts occur:
# 1. Resolve conflicts in editor
git add .
gt continue

# If no conflicts, move to next branch
gt checkout next-branch-name
```

### Step 7: Repeat for each branch that needs fixes

Navigate to each branch, fix, amend, resolve conflicts, move on.

### Step 8: Push the whole stack

```bash
gt submit --stack --ai
```

### Step 9: Restore any remaining stashed work

```bash
git stash pop
```

## Common Mistakes

### Wrong: Using `git checkout stash@{0} -- <file>`

```bash
# WRONG — brings the ENTIRE file from stash, including changes from other branches
git checkout stash@{0} -- lib/my_module.ex
```

This overwrites the file with the version from the top of the stack, which may
contain code that was added in higher branches. Use targeted edits instead.

### Wrong: Making all fixes on the top branch

Fixes must be applied to the branch that introduced the code. If PR #20
introduced a function and the reviewer comments on it in PR #22's review, the
fix belongs on PR #20's branch.

### Wrong: Not expecting restack conflicts

When you amend a lower branch, all upstack branches need rebasing. Conflicts are
normal — they just mean the rebase saw overlapping changes. Resolve them and
continue.

## Alternative: `gt absorb` for Simple Cases

If you have uncommitted changes that clearly belong to specific commits (e.g.,
fixing a typo in a file that was only touched in one commit):

```bash
git add -A
gt absorb
```

Graphite will automatically route each hunk to the correct commit. This works
well for small, unambiguous fixes but may not handle complex multi-file changes.
