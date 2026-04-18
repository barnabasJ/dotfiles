#!/usr/bin/env bash
set -euo pipefail

# Fetch all three types of PR comments from GitHub.
#
# Usage:
#   fetch-pr-comments.sh <owner/repo> <pr_number> [--include-bots]
#
# Output: JSON object with review_comments, discussion_comments, review_summaries

REPO="${1:?Usage: fetch-pr-comments.sh <owner/repo> <pr_number> [--include-bots]}"
PR_NUMBER="${2:?Usage: fetch-pr-comments.sh <owner/repo> <pr_number> [--include-bots]}"
INCLUDE_BOTS="${3:-}"

BOT_FILTER='.user.login | test("\\[bot\\]") | not'
if [[ "$INCLUDE_BOTS" == "--include-bots" ]]; then
  BOT_FILTER='true'
fi

TMPDIR_COMMENTS=$(mktemp -d)
trap 'rm -rf "$TMPDIR_COMMENTS"' EXIT

# Fetch all three comment types in parallel using temp files
gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" --paginate \
  --jq "[.[] | select(${BOT_FILTER}) | {id: .id, path: .path, line: .line, original_line: .original_line, diff_hunk: .diff_hunk, body: .body, created_at: .created_at, updated_at: .updated_at, user: .user.login, in_reply_to_id: .in_reply_to_id}]" \
  > "$TMPDIR_COMMENTS/review.json" &

gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" --paginate \
  --jq "[.[] | select(${BOT_FILTER}) | {id: .id, body: .body, created_at: .created_at, updated_at: .updated_at, user: .user.login}]" \
  > "$TMPDIR_COMMENTS/discussion.json" &

gh api "repos/${REPO}/pulls/${PR_NUMBER}/reviews" --paginate \
  --jq "[.[] | select(.body != \"\") | select(${BOT_FILTER}) | {id: .id, state: .state, body: .body, user: .user.login, submitted_at: .submitted_at}]" \
  > "$TMPDIR_COMMENTS/reviews.json" &

wait

# Combine into a single JSON object
jq -n \
  --slurpfile review_comments "$TMPDIR_COMMENTS/review.json" \
  --slurpfile discussion_comments "$TMPDIR_COMMENTS/discussion.json" \
  --slurpfile review_summaries "$TMPDIR_COMMENTS/reviews.json" \
  '{review_comments: ($review_comments | add // []), discussion_comments: ($discussion_comments | add // []), review_summaries: ($review_summaries | add // [])}'
