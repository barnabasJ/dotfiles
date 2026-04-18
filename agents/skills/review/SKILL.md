---
name: review
description:
  Review changed code from multiple expert perspectives (senior engineer, QA,
  architect, security, style). Finds issues, reports findings, and optionally
  fixes them.
---

# Review: Multi-Perspective Code Review

Review the current branch's changes from multiple expert perspectives. Each
perspective focuses on a different aspect of code quality, surfacing issues that
a single-pass review would miss.

## Scope

By default, reviews `git diff main..HEAD`. Accepts an optional argument to
narrow scope:

- `/review` — review all changes on the current branch vs main
- `/review path/to/file.ex` — review a specific file
- `/review --staged` — review only staged changes

## Review Perspectives

Run each perspective sequentially. For each one, read the diff (or relevant
files) and report findings.

### 1. Senior Engineer

Focus: correctness, edge cases, error handling, naming, readability.

- Are there logic bugs or off-by-one errors?
- Are error cases handled? What happens on nil/empty/unexpected input?
- Are names clear and consistent with the codebase?
- Is the code unnecessarily complex? Could it be simpler?
- Are there race conditions or concurrency issues?

### 2. Architect

Focus: design, separation of concerns, API boundaries, extensibility.

- Does this change belong in the right module/layer?
- Are abstractions at the right level? Too much? Too little?
- Does it follow the project's established patterns (check CLAUDE.md)?
- Are there circular dependencies or tight coupling introduced?
- Will this be easy to change later, or does it paint us into a corner?

### 3. QA Engineer

Focus: testability, test coverage, edge cases, regression risk.

- Are the new/changed code paths tested?
- Are edge cases covered (empty lists, nil values, boundary conditions)?
- Could existing tests break silently from these changes?
- Are test assertions precise (not `>=`, not `or`-based)?
- Are there integration points that need integration tests?

### 4. Security Specialist

Focus: injection, authorization, data exposure, path traversal.

- Any user input flowing into shell commands, SQL, or file paths unsanitized?
- Path validation using proper boundary checks (not just `starts_with?`)?
- Secrets or credentials exposed in logs, error messages, or responses?
- Authorization checks in place for new endpoints/actions?
- Any new dependencies with known vulnerabilities?

### 5. Docs Compliance

Focus: does the implementation match project documentation?

- Read relevant docs from `docs/design/` (PRDs, ADRs) and `docs/tasks/` for the
  feature being changed. Use `/feature-docs` conventions if available.
- Does the code implement what the docs describe? Flag any divergence.
- Are new features/changes reflected in existing docs, or do docs need updating?
- Are `@moduledoc` and `@doc` consistent with what the code actually does?
- If a doc says "X works by doing Y", does the code actually do Y?

### 6. Library & Framework Best Practices

Focus: correct usage of dependencies and frameworks.

- Check official docs (use `deepwiki` MCP or `elixir-docs` skill) for any
  library APIs used in the diff. Are they used correctly?
- Are there deprecated APIs being used when newer alternatives exist?
- Does Ash resource design follow Ash conventions (section order, action types,
  policy patterns)?
- Does Phoenix/LiveView code follow documented patterns (streams, assigns,
  handle_info)?
- Are OTP patterns correct (GenServer, supervision, process lifecycle)?
- Flag any "cargo cult" usage where an API is used incorrectly but happens to
  work.

### 7. Code Style & Consistency

Focus: project conventions, formatting, specs, documentation.

- Does it follow CLAUDE.md conventions (specs, `@impl`, naming)?
- Are public functions specced with named parameters?
- Is the style consistent with surrounding code?
- Any dead code, unused imports, or leftover debug statements?
- Are comments present where logic is non-obvious?

## Output Format

Present findings grouped by perspective with severity:

```
## Senior Engineer
- [critical] `foo/bar.ex:42` — nil not handled in `process/1`, will crash on empty input
- [suggestion] `foo/bar.ex:78` — rename `do_thing` to `apply_transform` for clarity

## Architect
- [warning] `baz/qux.ex:15` — this creates a circular dep between Chat and Agent domains
- [ok] Layer boundaries look clean

## QA Engineer
- [critical] `foo/bar.ex:42` — no test for nil input case
- [suggestion] Add property test for the transform function

## Security
- [ok] No security issues found

## Style & Consistency
- [warning] `foo/bar.ex:30` — missing @spec on public function
- [suggestion] `foo/bar.ex:55` — add comment explaining the binary pattern match
```

Severities:

- **critical** — must fix before merge (bugs, security, missing tests for new
  code)
- **warning** — should fix (style violations, missing specs, architectural
  concerns)
- **suggestion** — nice to have (naming improvements, extra tests, comments)
- **ok** — nothing found from this perspective

## After Review

After presenting all findings:

1. Summarize: `N critical, N warnings, N suggestions`
2. Ask the user: "Want me to fix the critical and warning issues?"
3. If yes, fix them, then run `/simplify` on the changed files
4. Re-verify with
   `mix compile --warnings-as-errors && mix format --check-formatted`
