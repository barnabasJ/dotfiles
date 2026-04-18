#!/usr/bin/env bash
set -euo pipefail

# GitHub PR info utility.
#
# Usage:
#   get-pr-info.sh repo                      — print owner/repo
#   get-pr-info.sh pr-for-branch [branch]    — PR number (defaults to current branch)
#   get-pr-info.sh status <pr_number>        — review decision + CI checks
#   get-pr-info.sh diff <pr_number>          — PR diff
#   get-pr-info.sh view <pr_number>          — PR details JSON
#   get-pr-info.sh list-open                 — all open PRs for current user

SUBCMD="${1:?Usage: get-pr-info.sh <subcommand> [args...]}"
shift

case "$SUBCMD" in
  repo)
    gh repo view --json nameWithOwner --jq '.nameWithOwner'
    ;;

  pr-for-branch)
    BRANCH="${1:-$(git branch --show-current)}"
    gh pr list --head "$BRANCH" --json number,title --jq '.[0].number'
    ;;

  status)
    PR_NUMBER="${1:?Usage: get-pr-info.sh status <pr_number>}"
    echo "=== Review Decision ==="
    gh pr view "$PR_NUMBER" --json reviewDecision --jq '.reviewDecision'
    echo ""
    echo "=== CI Checks ==="
    gh pr checks "$PR_NUMBER" 2>&1 || true
    ;;

  diff)
    PR_NUMBER="${1:?Usage: get-pr-info.sh diff <pr_number>}"
    gh pr diff "$PR_NUMBER"
    ;;

  view)
    PR_NUMBER="${1:?Usage: get-pr-info.sh view <pr_number>}"
    gh pr view "$PR_NUMBER" --json number,title,body,state,reviewDecision,headRefName,baseRefName,url,author,labels,mergeable,additions,deletions,changedFiles
    ;;

  list-open)
    gh pr list --author @me --state open \
      --json number,headRefName,title,reviewDecision,url \
      --jq '.[] | {number, branch: .headRefName, title, reviewDecision, url}'
    ;;

  *)
    echo "Unknown subcommand: $SUBCMD" >&2
    echo "Usage: get-pr-info.sh {repo|pr-for-branch|status|diff|view|list-open}" >&2
    exit 1
    ;;
esac
