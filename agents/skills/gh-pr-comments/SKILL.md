---
name: gh-pr-comments
description: Fetch all comment types from a GitHub PR
---

# GitHub PR Comments

Fetch inline review comments, general discussion comments, and review summaries
from a GitHub pull request.

## When to Use

- Reading feedback on a PR before fixing issues
- Triaging review comments (actionable vs questions vs stale)
- Getting a complete picture of all PR feedback

## GitHub's Three Comment Types

GitHub stores PR feedback in **three separate API endpoints**. You must check
all three to get complete feedback.

| Type             | Endpoint               | What it contains                       |
| ---------------- | ---------------------- | -------------------------------------- |
| Review comments  | `/pulls/{n}/comments`  | Inline comments on specific code lines |
| Discussion       | `/issues/{n}/comments` | General PR discussion (not on code)    |
| Review summaries | `/pulls/{n}/reviews`   | Top-level review body (approve/reject) |

**Common mistake**: Only checking `/pulls/{n}/comments` and missing general
discussion or review summaries.

## Usage

```bash
# Fetch all comments for a PR (filters bots by default)
~/.claude/skills/gh-pr-comments/scripts/fetch-pr-comments.sh <owner/repo> <pr_number>

# Include bot comments
~/.claude/skills/gh-pr-comments/scripts/fetch-pr-comments.sh <owner/repo> <pr_number> --include-bots
```

### Output

Returns JSON with three arrays: `review_comments`, `discussion_comments`, and
`review_summaries`. Each entry includes the commenter, body, and relevant
metadata (path/line for inline comments, state for reviews).

## Filtering Bot Comments

By default, comments from known bots are excluded:

- `graphite-app[bot]`
- `github-actions[bot]`
- Any login containing `[bot]`

Use `--include-bots` to see all comments.

## Handling Stale Comments

After pushing fixes, old inline comments remain pointing at outdated line
numbers. Before acting on an inline comment:

1. Read the **current** file content at the referenced path
2. Check if the issue described still exists
3. If already fixed, mark as stale and skip
