---
name: graphite-ai-rules
description:
  This skill should be used when the user asks to "create a Graphite AI review
  rule", "add a custom review rule", "write Graphite review rules", "configure
  AI review exclusions", or mentions Graphite AI review customization, custom
  prompts, or review rule best practices.
---

# Graphite AI Review Rules

Create and manage custom rules for Graphite's AI code review system. Rules teach
the Graphite Agent team-specific standards to enforce during PR reviews.

## Two Rule Types

### 1. Custom Prompts (Preferred)

Written directly in the Graphite UI. Best for most teams.

- Each rule addresses **one specific concern**
- Fast to iterate and test
- No file processing overhead
- Centrally managed across repositories

### 2. File-Based Rules

Reference existing documentation via glob patterns. Use sparingly — only when
docs are maintained externally and change frequently.

```
docs/coding-standards.md
CONTRIBUTING.md
docs/architecture/*.md
.github/rules/*.md
```

**Limitations**: Large files truncated, too many files degrade quality, globs
are case-sensitive.

## Rule Structure

Every custom rule follows: **Rule -> Bad example -> Good example -> Reasoning**

````markdown
### Rule: [Concise prescriptive statement]

**Rule:** [1-2 sentences expanding the rule with specific guidance]

**Bad example:**

````lang
[code showing the violation]
`` `

**Good example:**
```lang
[code showing the correct approach]
`` `

**Reasoning:**
[Why this matters — security, maintainability, performance, etc.]
````
````

Provide 2-3 clear, contrasting examples per rule.

## Writing Effective Rules

### What Works Well

- **Language-specific conventions**: naming, imports, error handling patterns
- **Security guidelines**: auth checks, input validation, secret handling
- **Framework-specific patterns**: React hooks, API design, ORM usage

### Required Qualities

1. **Focused** — one concern per rule
2. **Prescriptive** — tell engineers exactly what to do
3. **Specific** — narrow scope, clear boundaries
4. **Exemplified** — show bad vs good with real code

### Anti-Patterns to Avoid

| Anti-Pattern              | Example                             | Fix                                                |
| ------------------------- | ----------------------------------- | -------------------------------------------------- |
| Unnecessary context       | "You are a staff-level engineer..." | Remove — the agent doesn't need persona prompts    |
| Overly broad              | "Write good code"                   | Narrow to one specific practice                    |
| Non-prescriptive verbs    | "Flag" or "comment on" issues       | Use "reject", "require", "replace with"            |
| Praise/filler             | "Great job reviewing!"              | Remove entirely                                    |
| Mixing rules + exclusions | "Don't comment on utility classes"  | Move to exclusions section instead                 |
| Vague scope               | "Don't make breaking changes"       | Specify exactly what constitutes a breaking change |

## Exclusions vs Rules

- **Rules**: Define what the agent **should enforce** (positive guidance)
- **Exclusions**: Define what the agent **should ignore** (noise reduction)

Never put exclusion language inside a custom rule. Use the dedicated exclusions
section.

### Writing Exclusions

Be as targeted as possible. Overly broad exclusions suppress valid comments.

**Good**: "Do not comment on missing `return` keywords in Kotlin
single-expression functions. This is valid Kotlin syntax."

**Bad**: "Don't suggest performance improvements." (too broad — misses real
issues)

## Workflow

1. Open the AI reviews dashboard
2. Navigate to **Rules & exclusions** tab
3. Click **Add** next to Custom rules
4. Select a template or write a custom prompt
5. Save configuration
6. Monitor metrics — refine or remove low-acceptance rules

## Measuring Effectiveness

Track these metrics per rule:

- **Acceptance rate** — percentage of flagged issues that led to code changes
- **Issues found / PRs reviewed** — reach and frequency
- **Upvote/downvote rates** — direct team feedback

Remove or rewrite rules with consistently low acceptance. Use high-performing
rules as templates for new ones.

## Reference

For complete examples across security, database, naming, and framework
categories, see `references/examples.md`.
