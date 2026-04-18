# Diagram Conventions

Shared conventions for all feature documentation diagrams.

## When to Use Each Diagram Type

| Diagram Type      | Use For                                        | Example                      |
| ----------------- | ---------------------------------------------- | ---------------------------- |
| `flowchart`       | Component relationships, architecture overview | Module dependency graph      |
| `sequenceDiagram` | Multi-actor interactions, API request flows    | Web → Domain → DB round-trip |
| `stateDiagram-v2` | Resource lifecycle, state machines             | Job states, sync workflows   |
| `erDiagram`       | Database tables and relationships              | Resource data model          |
| `classDiagram`    | Module interfaces and dependencies             | Interface implementations    |

## Style Conventions

- **Use actual names**: Node labels use real module/resource names
- **Label arrows**: Arrow labels show the action or event name
- **Direction**: Top-down (`TD`) for hierarchies, left-right (`LR`) for flows
- **One concept per diagram**: Split complex systems into multiple focused
  diagrams rather than one sprawling diagram
- **Subgraphs for domains**: Group related modules in `subgraph` blocks
- **Prefer Mermaid**: Use Mermaid for all diagrams

## Minimum Diagram Requirements by Doc Type

| Doc Type    | Required Diagrams                                                      |
| ----------- | ---------------------------------------------------------------------- |
| `prd`       | System context diagram (flowchart)                                     |
| `adr`       | Architecture diagram when decision changes architecture (flowchart)    |
| `plan`      | Architecture diagram (flowchart) + data flow diagram (sequenceDiagram) |
| `technical` | At least one; state diagram if stateful; ER diagram if data model      |
| `guide`     | At least one: screenshot or user-flow diagram (sequenceDiagram)        |
| `testing`   | None required                                                          |
| `tasks`     | None required                                                          |
