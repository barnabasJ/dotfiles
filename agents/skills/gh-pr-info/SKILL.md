---
name: gh-pr-info
description: Look up PR metadata, status, CI checks, and diffs
---

# GitHub PR Info

Query PR metadata, review status, CI checks, diffs, and branch-to-PR mappings
using the GitHub CLI.

## When to Use

- Finding the PR number for a branch
- Checking review/approval status
- Viewing PR diffs or details
- Listing open PRs with their review state
- Getting the repo owner/name from git remote

## Usage

```bash
SCRIPT=~/.claude/skills/gh-pr-info/scripts/get-pr-info.sh

# Get owner/repo from git remote
$SCRIPT repo

# Get PR number for current branch
$SCRIPT pr-for-branch

# Get PR number for a specific branch
$SCRIPT pr-for-branch my-feature-branch

# Review decision + CI check status
$SCRIPT status <pr_number>

# PR diff
$SCRIPT diff <pr_number>

# PR details (title, body, state, reviewDecision, etc.)
$SCRIPT view <pr_number>

# All open PRs for current user with review status
$SCRIPT list-open
```

## Subcommands

| Subcommand               | Description                                    |
| ------------------------ | ---------------------------------------------- |
| `repo`                   | Print `owner/repo` from git remote             |
| `pr-for-branch [branch]` | PR number for branch (defaults to current)     |
| `status <number>`        | Review decision + CI check results             |
| `diff <number>`          | Full PR diff                                   |
| `view <number>`          | PR details as JSON                             |
| `list-open`              | All open PRs by current user with review state |

## Review Decision Values

The `reviewDecision` field from GitHub can be:

- `APPROVED` — All required reviewers approved
- `CHANGES_REQUESTED` — At least one reviewer requested changes
- `REVIEW_REQUIRED` — Waiting for required reviews
- `""` (empty) — No required reviewers configured
