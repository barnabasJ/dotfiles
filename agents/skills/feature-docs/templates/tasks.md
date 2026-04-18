# Tasks Template

**Output path**: `docs/tasks/<feature>/NN-<task-name>.md`

**Informed by**: Work Breakdown Structure (WBS) 100% rule, INVEST criteria for
user stories, SMART task definition, Definition of Ready / Definition of Done
practices, story splitting patterns.

Create one file per task, numbered sequentially.

## Template

```markdown
# Task NN: <Task Name>

<!-- Title uses verb-noun format: "Add rate limiting to POST /api/messages"
     not "Rate limiting" -->

**Phase**: <N> — <Phase Name> **Depends on**: <Task NN or "None"> **Blocks**:
<Task NN or "None"> **Size**: <S | M | L>

## Objective

<1-2 sentence description of what this task accomplishes and why it matters.>

## Out of Scope

<!-- Explicitly state what is NOT part of this task. This prevents scope
     creep more than stating what is in scope. -->

- <What this task deliberately does not address>

## Context

<Why this task exists. What problem it solves. How it fits into the larger
feature. Link to the plan phase this belongs to.>

## Detailed Steps

### 1. <Step Name>

<Description of what to do, with code examples>

### 2. <Step Name>

...

## Files to Create/Modify

- `path/to/file` — <What changes>

## Patterns to Follow

<!-- Point to specific existing files in the codebase that demonstrate
     the pattern to follow. Not abstract descriptions — real file paths. -->

- `path/to/existing/example` — <What pattern it demonstrates>

## Acceptance Criteria

<!-- Written as observable, testable outcomes. Each criterion should be
     verifiable by someone other than the author. -->

- [ ] <Given [context], when [action], then [observable result]>
- [ ] <Given [context], when [action], then [observable result]>

## Definition of Done

<!-- Standard checklist — all items must be true for the task to be complete. -->

- [ ] Code compiles with no warnings
- [ ] Tests pass (new + existing)
- [ ] Acceptance criteria verified
- [ ] No known regressions introduced

## Verification

(Exact commands to run to verify the task is complete — build, test, etc.)

## Notes

<Any gotchas, warnings, or tips for the implementer>
```

## Guidelines

### Task Decomposition

- **One task = one PR**: Each task should be small enough for a single PR (~800
  lines max). If larger, split it.
- **8/80 rule**: No task should take less than ~1 hour or more than ~2 days of
  effort. Below that, you're micro-managing. Above that, the task is not
  well-understood.
- **Decompose by deliverable, not activity**: "User authentication module"
  decomposes better than "coding, testing, deploying."
- **Vertical slices over horizontal layers**: Prefer "Add create endpoint with
  tests" over separate "backend task" + "test task." Each task should deliver
  user-visible or developer-visible value.
- **The status test**: If you cannot answer "is this done?" with a binary
  yes/no, the task is too vague.

### Splitting Large Tasks

Use these patterns when a task is too big:

| Pattern                        | Example                                                      |
| ------------------------------ | ------------------------------------------------------------ |
| **Workflow steps**             | Split CRUD into Create, Read, Update, Delete                 |
| **Happy path / sad path**      | Core flow first, error handling as a separate task           |
| **Data variations**            | Handle one input format first, then add others               |
| **Spike / implementation**     | Timebox research separately from the build                   |
| **Interface / implementation** | Define the contract as task 1; implement behind it as task 2 |

### Task Quality

- **Verb-noun titles**: "Add rate limiting to POST /api/messages" not "Rate
  limiting."
- **Numbered sequentially**: `01-`, `02-`, etc. matching implementation order.
- **Dependencies are explicit**: State which task(s) must be done first AND
  which tasks this blocks.
- **Out of scope is required**: Explicitly stating what a task does NOT cover
  prevents scope creep more effectively than defining what it does.
- **Acceptance criteria are observable**: Written as Given/When/Then or as
  testable assertions. If someone other than the author cannot verify it, it's
  too vague.

### Definition of Ready (before starting)

A task is ready to start when:

- Acceptance criteria are written and unambiguous
- Dependencies are resolved or explicitly identified
- Any required API contract or data schema is available
- The implementer understands the task (confirmed, not assumed)

### Verification

- **Steps are copy-pasteable**: Code examples should be close to the actual code
  the implementer will write.
- **Patterns reference existing code**: Point to real files in the codebase that
  demonstrate the pattern to follow.
- **Verification is concrete**: End with exact commands to run. Not "run the
  tests" but the specific test command.

### Anti-Patterns

- **Unbounded research**: "Investigate options for X" without a timebox. Always
  timebox spikes — the output is a decision or follow-up tasks.
- **Solution prescribed in ticket**: "Use library X, call method Y" removes
  autonomy and is often wrong. State the problem and constraints instead.
- **Missing acceptance criteria**: "Done" becomes a matter of opinion and PR
  review becomes scope negotiation.
- **Gold plating as separate tasks**: "Add animations" or "Polish UI" as
  discrete tasks that never get cut. Bundle polish into the original task's DoD
  or label as nice-to-have.
