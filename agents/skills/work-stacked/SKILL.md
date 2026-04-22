---
name: work-stacked
description:
  Execute a list of tasks as a stack of PRs using Graphite (`gt`). Each task
  becomes one branch, one commit, one PR. Use when the project uses stacked
  PRs via Graphite and you have multiple tasks to ship.
---

# Work: Task Execution as Stacked PRs

Execute a list of tasks as stacked PRs using Graphite. Each task becomes one
branch, one commit, one PR — small, focused, and independently reviewable.

## Prerequisites

- Graphite CLI (`gt`) installed and configured
- Project has a `CLAUDE.md` with verification steps (e.g., `mix precommit`)
- On `main` branch with clean working tree

## Workflow

### 1. Start Fresh

```bash
git checkout main
gt sync
```

Confirm clean state — no uncommitted changes, no stale branches.

### 2. Per-Task Loop

For each task in the work plan:

#### 2a. Implement

Make the code changes for this single task. Keep it focused — one task = one PR.

#### 2b. Verify

Run the project's verification command. This is project-specific — check
`CLAUDE.md` or the `/work` command for the exact steps. Common examples:

- Elixir: `mix precommit` (compile + format + test)
- Node: `npm run lint && npm test`
- Rust: `cargo clippy && cargo test`

Fix any issues before proceeding. The PR must compile and pass tests
independently.

#### 2c. Create Branch

```bash
gt create --all --message "type(scope): description"
```

Follow conventional commits:

| Prefix         | Use                                 |
| -------------- | ----------------------------------- |
| `feat(x):`     | New feature                         |
| `fix(x):`      | Bug fix                             |
| `refactor(x):` | Restructure without behavior change |
| `test(x):`     | Add or update tests                 |
| `docs(x):`     | Documentation only                  |
| `chore(x):`    | Maintenance tasks                   |

#### 2d. Submit

```bash
gt submit --stack --publish --ai
```

The `--publish` flag creates non-draft PRs. Without it, PRs may be created as
drafts in non-interactive contexts (CI, agents).

`--stack` ensures the full stack is pushed and PR dependencies are set
correctly.

#### 2e. Next Task

Continue to the next task. The new branch stacks on top of the previous one.

### 3. After All Tasks

```bash
gt log short
```

Confirm the stack looks correct — each task is a separate branch stacked in
order.

### 4. Review Feedback

When a reviewer requests changes on a specific PR:

```bash
gt checkout branch-name
# Make fixes...
gt modify --all
gt submit --stack --publish --ai
```

`gt modify --all` amends the branch's commit and automatically restacks all
branches above it.

### 5. Cleanup

After PRs are merged:

```bash
gt sync
```

This pulls trunk, rebases remaining stacks, and deletes merged branches.

## Rules

- **One task = one branch = one PR** — keep changes under ~800 lines
- **Each PR must pass verification independently** — don't rely on later PRs to
  fix earlier ones
- **Always use `--stack --ai`** with `gt submit` to keep the full stack in sync
- **Always use `--publish`** to avoid draft mode in non-interactive contexts
- **If a task is too large**, split it into multiple stacked PRs
- **Never use raw git** for branching/pushing when Graphite manages the stack

## Splitting Large Tasks

If a single task produces > 800 lines of changes, split it:

1. Implement the first logical chunk
2. `gt create -am "feat(scope): part 1 — description"`
3. Implement the next chunk (stacks on top)
4. `gt create -am "feat(scope): part 2 — description"`
5. `gt submit --stack --publish --ai`

Each chunk should compile and pass tests on its own.

## Parallel Execution with Worktrees

When tasks are **independent** (don't touch the same files), run them in
parallel using git worktrees. Each agent gets its own worktree with an isolated
database and dev server port — no contention.

> Requires the `worktree` skill. See it for full setup/teardown details.

### When to Parallelize

- Tasks modify different areas of the codebase (e.g., "add API endpoint" +
  "update landing page styles")
- Tasks have no data dependencies between them
- You want faster throughput on a large task list

### When NOT to Parallelize

- Tasks build on each other (use sequential stacking instead)
- Tasks modify the same files or database tables
- The task list is small enough that sequential is fast enough

### Workflow

```bash
SCRIPTS=~/.local/share/chezmoi/agents/skills/worktree/scripts

# 1. Create a worktree per independent task group
$SCRIPTS/worktree-manager.sh create task-api
$SCRIPTS/elixir-worktree-setup.sh setup .worktrees/task-api task-api

$SCRIPTS/worktree-manager.sh create task-ui
$SCRIPTS/elixir-worktree-setup.sh setup .worktrees/task-ui task-ui
```

Each agent works in its own worktree:

```
# Agent 1 — in .worktrees/task-api/
cd .worktrees/task-api
# implement API changes...
mix precommit
gt create -am "feat(api): add endpoint"
gt submit --stack --publish --ai

# Agent 2 — in .worktrees/task-ui/
cd .worktrees/task-ui
# implement UI changes...
mix precommit
gt create -am "feat(web): update landing page"
gt submit --stack --publish --ai
```

### After Parallel Work

Each worktree produces its own independent PR stack. After PRs merge:

```bash
# Back in main worktree
gt sync

# Teardown worktrees
$SCRIPTS/elixir-worktree-setup.sh teardown .worktrees/task-api
$SCRIPTS/elixir-worktree-setup.sh teardown .worktrees/task-ui
$SCRIPTS/worktree-manager.sh cleanup
```

### Dispatching Agents

When orchestrating multiple agents (e.g., via Claude Code's Task tool):

1. **Partition tasks** — group independent tasks together
2. **Create worktrees** — one per task group, from the main worktree
3. **Launch agents** — each agent gets a worktree path as its working directory
4. **Each agent follows the standard per-task loop** — implement, verify,
   create, submit
5. **Collect results** — wait for all agents to complete, review their PRs
6. **Cleanup** — teardown worktrees after PRs merge
