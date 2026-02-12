---
name: review-stack
description:
  Walk a Graphite stack bottom-to-top, fixing PR review comments on each branch
---

# Review Stack: Fix PR Comments Across a Graphite Stack

Walk a Graphite PR stack from bottom to top, fetching review comments for each
PR, fixing the issues, verifying, and pushing — then moving up to the next
branch until the entire stack is addressed.

## When to Use

- PRs in a Graphite stack have review comments that need fixing
- You want to systematically address all feedback across a stack
- After a review cycle where multiple stacked PRs received comments

## Prerequisites

- Graphite CLI (`gt`) installed and configured
- GitHub CLI (`gh`) authenticated with repo access
- On a branch within the stack (any position)
- Clean working tree (no uncommitted changes)

## Workflow

### Phase 1: Reconnaissance

Before touching any code, understand the full picture.

```bash
# 1. Get the repo owner/name from git remote
gh repo view --json nameWithOwner --jq '.nameWithOwner'

# 2. View the current stack
gt log short

# 3. List all open PRs for branches in the stack
gh pr list --author @me --state open --json number,headRefName,title,reviewDecision
```

Build a map of `branch → PR number` for the entire stack.

### Phase 2: Bottom-to-Top Traversal

```bash
# Start at the bottom of the stack
gt bottom
```

Then for each branch, repeat the **Fix Cycle** below until you reach the top.

### Fix Cycle (Per Branch)

#### Step 1: Identify the PR

```bash
# Get the PR number for the current branch
gh pr list --head "$(git branch --show-current)" --json number,title --jq '.[0]'
```

#### Step 2: Fetch ALL Comments

Fetch both review comments (inline on code) and general PR comments:

```bash
# Inline review comments (on specific lines of code)
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | {id: .id, path: .path, line: .line, body: .body, created_at: .created_at, user: .user.login}'

# General PR comments (not inline)
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '.[] | {id: .id, body: .body, created_at: .created_at, user: .user.login}'

# PR reviews with body text (top-level review summaries)
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --jq '.[] | select(.body != "") | {id: .id, state: .state, body: .body, user: .user.login}'
```

**Filter out bot/automated comments** (e.g., Graphite Agent) unless the user
specifically wants them addressed. Focus on human reviewer comments.

#### Step 3: Triage Comments

For each comment, determine:

- **Actionable**: Requires a code change
- **Question**: Needs a reply, not a code change (flag to user)
- **Already Fixed**: Comment is on stale code that was already updated
- **Won't Fix**: Disagreement or out of scope (flag to user)

Present the triage to the user before making changes, summarizing:

```
PR #XX: [title] — [N] comments
  1. [actionable] path/to/file.ex:42 — "Add comment explaining <<0>>"
  2. [actionable] path/to/file.ex:101 — "Refactor to reuse helper"
  3. [question]   path/to/file.ex:55 — "Why not use Stream here?"
  4. [stale]      path/to/file.ex:76 — Already fixed in previous push
```

#### Step 4: Fix Issues

For each actionable comment:

1. Read the file at the referenced path
2. Understand the reviewer's concern
3. Make the fix
4. If uncertain about the right approach, ask the user

#### Step 5: Verify

Run the project's verification command before committing:

```bash
# Check CLAUDE.md for project-specific verification
# Common examples:
mix precommit          # Elixir/Phoenix
npm run lint && npm test  # Node.js
cargo clippy && cargo test  # Rust
```

Fix any verification failures before proceeding.

#### Step 6: Amend and Push

```bash
# Amend the current branch's commit with the fixes
gt modify --all

# Push the entire stack (restacks upstack branches automatically)
gt submit --stack --publish
```

**Always use `--stack`** — this ensures upstack branches are rebased onto your
fixes and all PRs stay in sync.

#### Step 7: Move Up

```bash
# Move to the next branch in the stack
gt up
```

If `gt up` fails (you're at the top), the traversal is complete.

### Phase 3: Summary

After processing all branches, present a summary:

```
Stack Review Complete

PR #20: feat(sandbox): hardening — 4 comments fixed
PR #21: feat(agent): file actions — 0 comments (clean)
PR #22: test(agent): add tests — 2 comments fixed, 1 question flagged
PR #23: docs(agent): update docs — 1 comment fixed

Action needed:
- PR #22: Reply to question about Stream usage on line 55
```

## Common Mistakes to Avoid

### 1. Forgetting `--stack` on Submit

**Wrong**: `gt submit` (only pushes current branch) **Right**:
`gt submit --stack --publish` (pushes entire stack, keeps it in sync)

Without `--stack`, upstack branches won't be rebased onto your fixes, causing
divergence.

### 2. Missing Comment Types

GitHub has THREE places where review feedback can appear:

- **Pull request review comments** (`/pulls/{n}/comments`) — inline on code
- **Issue comments** (`/issues/{n}/comments`) — general discussion
- **Review bodies** (`/pulls/{n}/reviews`) — top-level review summaries

Always check all three.

### 3. Not Handling Stale Comments

After pushing fixes, old review comments remain on the PR pointing at outdated
line numbers. Before fixing a comment:

1. Read the **current** file content
2. Check if the issue the comment describes still exists
3. If already fixed, mark as stale and skip

### 4. Making Fixes on the Wrong Branch

Each PR corresponds to a specific branch. Before making any changes:

```bash
# Verify you're on the right branch
git branch --show-current

# Verify this matches the PR you're fixing
gh pr list --head "$(git branch --show-current)" --json number,title
```

### 5. Not Running Verification Between Branches

Fixes on one branch can break tests for upstack branches after restacking.
Always verify after `gt modify --all` and before `gt submit`.

### 6. Editing Files That Belong to a Different PR

A comment on PR #22 might reference code that was introduced in PR #20. The fix
must be applied on PR #20's branch, not PR #22's. Check which branch introduced
the code before fixing.

```bash
# Check which branch introduced a file
gt log short  # See the stack order
git log --oneline --follow path/to/file.ex  # See which commit added/modified it
```

## Handling Edge Cases

### PR Has No Comments

Skip it — `gt up` and continue.

### Comment Requires Discussion, Not Code

Flag it to the user with the comment text and context. Don't make changes.

### Conflict During Restack

If `gt submit --stack` hits a restack conflict:

```bash
# Resolve conflicts in editor
git add .
gt continue

# Then retry
gt submit --stack --publish
```

### Branch Was Already Merged

If a branch in the middle of the stack was merged:

```bash
gt sync  # Clean up merged branches
gt log short  # Verify remaining stack
# Continue from the next unmerged branch
```

## Quick Reference

| Step                   | Command                                            |
| ---------------------- | -------------------------------------------------- |
| View stack             | `gt log short`                                     |
| Go to bottom           | `gt bottom`                                        |
| Get current branch PR  | `gh pr list --head "$(git branch --show-current)"` |
| Fetch inline comments  | `gh api repos/{o}/{r}/pulls/{n}/comments`          |
| Fetch general comments | `gh api repos/{o}/{r}/issues/{n}/comments`         |
| Fetch review summaries | `gh api repos/{o}/{r}/pulls/{n}/reviews`           |
| Amend fixes            | `gt modify --all`                                  |
| Push entire stack      | `gt submit --stack --publish`                      |
| Move up                | `gt up`                                            |
| Check for top of stack | `gt up` (fails if already at top)                  |
