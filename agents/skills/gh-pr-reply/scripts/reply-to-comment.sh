#!/usr/bin/env bash
set -euo pipefail

# Reply to an inline review comment on a GitHub PR.
#
# Usage:
#   reply-to-comment.sh <owner/repo> <pr_number> <comment_id> <body>

REPO="${1:?Usage: reply-to-comment.sh <owner/repo> <pr_number> <comment_id> <body>}"
PR_NUMBER="${2:?Usage: reply-to-comment.sh <owner/repo> <pr_number> <comment_id> <body>}"
COMMENT_ID="${3:?Usage: reply-to-comment.sh <owner/repo> <pr_number> <comment_id> <body>}"
BODY="${4:?Usage: reply-to-comment.sh <owner/repo> <pr_number> <comment_id> <body>}"

gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments/${COMMENT_ID}/replies" \
  --method POST \
  --field body="$BODY"
