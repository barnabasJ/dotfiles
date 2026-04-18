---
name: gh-pr-reply
description: Post replies to PR review comments
---

# GitHub PR Reply

Post replies to inline review comments on a GitHub pull request.

## When to Use

- Responding to a reviewer's inline code comment
- Explaining a fix you made in response to feedback
- Asking a clarifying question on a review comment

## Usage

```bash
~/.claude/skills/gh-pr-reply/scripts/reply-to-comment.sh <owner/repo> <pr_number> <comment_id> <body>
```

### Parameters

| Parameter    | Description                                            |
| ------------ | ------------------------------------------------------ |
| `owner/repo` | Repository in `owner/name` format                      |
| `pr_number`  | The pull request number                                |
| `comment_id` | The review comment ID to reply to (from comment fetch) |
| `body`       | The reply text                                         |

### Example

```bash
~/.claude/skills/gh-pr-reply/scripts/reply-to-comment.sh acme/app 42 123456789 "Fixed — extracted to a helper as suggested."
```

## Finding the Comment ID

Use the `gh-pr-comments` skill to fetch comments. Each inline review comment
includes an `id` field. Use that ID when replying.

## Notes

- This creates a **reply** in the review comment thread, not a new top-level
  comment
- The reply is posted as the authenticated `gh` user
- For general PR discussion (not replying to a specific inline comment), use
  `gh pr comment <number> --body "..."` directly
