---
name: feature-docs
description:
  Generate feature documentation — PRDs, RFCs, ADRs, plans, technical docs,
  tasks, guides, testing docs, runbooks, and changelogs — individually or as a
  progressive pipeline covering a feature's full lifecycle
---

# Feature Documentation Generator

Create feature documentation following structured, research-backed templates.
Covers the full feature lifecycle from "why are we building this" through "how
do we operate it in production."

## Usage

Argument format: `<doc-type> <feature-name> [description]`

| Type        | What it creates                            | Template                   |
| ----------- | ------------------------------------------ | -------------------------- |
| `prd`       | Product Requirements Document              | `templates/prd.md`         |
| `rfc`       | Request for Comments (design proposal)     | `templates/rfc.md`         |
| `adr`       | Architecture Decision Record               | `templates/adr.md`         |
| `plan`      | Implementation plan with phases            | `templates/plan.md`        |
| `technical` | Technical deep-dive document               | `templates/technical.md`   |
| `tasks`     | Task breakdown files                       | `templates/tasks.md`       |
| `guide`     | End-user guide (task-oriented)             | `templates/guide.md`       |
| `testing`   | Test strategy                              | `templates/testing.md`     |
| `runbook`   | Operational runbook for production         | `templates/runbook.md`     |
| `changelog` | Structured change log                      | `templates/changelog.md`   |
| `all`       | Full pipeline (all of the above, in order) | All templates sequentially |

**To generate a doc**: Read the template file listed above, then follow its
template and guidelines to produce the document.

All templates share diagram conventions defined in `diagrams.md` — read it when
creating any doc that includes diagrams.

## Examples

- `/feature-docs prd user-auth Add user authentication with magic links`
- `/feature-docs rfc caching-strategy Propose a caching approach`
- `/feature-docs adr caching-strategy` (after RFC is accepted)
- `/feature-docs plan user-auth` (after PRD exists)
- `/feature-docs tasks user-auth` (after plan exists)
- `/feature-docs technical coding-agent Deep dive on the coding agent`
- `/feature-docs guide chat-interface How to use the chat interface`
- `/feature-docs testing agent-teams Test plan for agent teams feature`
- `/feature-docs runbook chat-service Operational runbook for chat`
- `/feature-docs changelog user-auth Document what shipped`
- `/feature-docs all notifications Push notification system`

## Before Writing

1. **Gather context**: Ask the user about the feature if the description is
   vague. Understand the problem, goals, constraints, and scope.
2. **Research the codebase**: Read relevant existing code, resources, and docs
   to understand how the feature integrates with the existing architecture.
3. **Check existing docs**: Look for any related PRDs, ADRs, or design docs that
   this feature builds on.

## Progressive Pipeline (`all`)

When running `all`, execute each stage sequentially. After each stage, briefly
summarize what was created and confirm before proceeding to the next:

1. **PRD** — Define requirements, goals, non-goals, user stories
2. **RFC** — Propose and debate the technical approach (skip for simple features
   with obvious solutions)
3. **ADR** — Record key architectural decisions from the RFC (skip if no
   significant architectural choices)
4. **Plan** — Design implementation approach, phases, dependencies, risks
5. **Technical** — Deep-dive on architecture internals, behavior, and data flows
6. **Tasks** — Break plan phases into individual executable task files
7. **Guide** — User-facing guide explaining how to use the feature
8. **Testing** — Test strategy covering unit, integration, and manual test plans
9. **Runbook** — How to operate, monitor, and troubleshoot in production
10. **Changelog** — Record what shipped for this feature

Each stage builds on the previous:

- The **RFC** references the PRD for requirements
- **ADRs** capture decisions from the RFC
- The **Plan** references the PRD, RFC, and ADRs
- **Tasks** break the plan into executable work
- The **Guide** and **Testing** doc reference the PRD for acceptance criteria
- The **Runbook** references the technical deep-dive for architecture
- The **Changelog** summarizes what the tasks delivered

## After Writing

1. **Cross-reference**: Link related docs to each other (PRD ↔ RFC ↔ Plan ↔
   Tasks)
2. **Verify diagrams**: Confirm mermaid code blocks use valid syntax
3. **Summary**: Tell the user what was created, with file paths
