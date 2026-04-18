# Graphite CLI (`gt`) vs GitHub CLI (`gh`) Boundaries

## `gt` — Stack Management Only

The Graphite CLI manages **branches, stacks, and PR submission**. It does NOT
interact with PR comments, reviews, or CI status.

### What `gt` Can Do

| Task                 | Command                         |
| -------------------- | ------------------------------- |
| Create a branch      | `gt create --all --message "…"` |
| Amend current branch | `gt modify --all`               |
| Push PRs             | `gt submit --stack --ai`        |
| Sync with trunk      | `gt sync`                       |
| Navigate stack       | `gt up`, `gt down`, `gt top`    |
| View stack topology  | `gt log short`                  |
| Rebase stack         | `gt restack`                    |
| Merge PRs            | `gt merge`                      |

### What `gt` CANNOT Do

- Fetch PR review comments
- Check PR review/approval status
- Read CI check results
- Post comments or replies on PRs
- View PR diffs (use `git diff` or `gh pr diff`)

## `gh` — GitHub API Access (via Skills)

For all GitHub API operations, use the dedicated skills:

- **`gh-pr-info`** — PR metadata, status, CI checks, diffs, branch→PR mapping
- **`gh-pr-comments`** — Fetch all three PR comment types
- **`gh-pr-reply`** — Post replies to review comments

## When to Use Which

| I want to…                | Use              | Skill / Command                   |
| ------------------------- | ---------------- | --------------------------------- |
| Create a branch/PR        | `gt`             | `gt create --all --message "…"`   |
| Push my stack             | `gt`             | `gt submit --stack --ai`          |
| See my stack structure    | `gt`             | `gt log short`                    |
| Read review comments      | `gh-pr-comments` | `fetch-pr-comments.sh`            |
| Check if PRs are approved | `gh-pr-info`     | `get-pr-info.sh status <number>`  |
| Reply to a review comment | `gh-pr-reply`    | `reply-to-comment.sh`             |
| See CI check status       | `gh-pr-info`     | `get-pr-info.sh status <number>`  |
| Navigate between branches | `gt`             | `gt up`, `gt down`, `gt checkout` |
| Sync with trunk           | `gt`             | `gt sync`                         |
| Get PR number for branch  | `gh-pr-info`     | `get-pr-info.sh pr-for-branch`    |
| Get repo owner/name       | `gh-pr-info`     | `get-pr-info.sh repo`             |
| View PR diff              | `gh-pr-info`     | `get-pr-info.sh diff <number>`    |
| View PR details           | `gh-pr-info`     | `get-pr-info.sh view <number>`    |
