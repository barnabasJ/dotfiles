# Four-Phase AI Workflow System - Research

## Current System Analysis

### Existing Workflow Structure

- **feature** command → uses feature-planner agent
- **fix** command → uses fix-planner agent
- **task** command → uses task-planner agent
- All three create planning documents but mix planning with some execution
  concerns

### Current Agent Ecosystem

- **Planning Agents**: feature-planner, fix-planner, task-planner
- **Implementation**: implementation-agent, test-developer, test-fixer
- **Review Agents**: qa-reviewer, security-reviewer, consistency-reviewer, etc.
- **Domain Experts**: elixir-expert, research-agent, architecture-agent, etc.

### Current Document Structure

- Planning docs in: `notes/features/`, `notes/fixes/`, `notes/tasks/`
- Mixed planning and execution details in single documents

## Problem Analysis

### Issues with Current System

1. **Mixed Phases**: Planning documents include execution details
2. **Limited Parallelization**: No systematic way to identify parallel work
3. **Type-Specific**: Different workflows for features vs fixes vs tasks
4. **Research Mixed In**: Research happens within planning, cluttering context

### User Requirements

1. **Research Phase**: Dedicated investigation phase using sub-agents
2. **Planning Phase**: Strategic planning based on research
3. **Breakdown Phase**: Break plans into actionable, parallelizable tasks with
   TDD/BDD
4. **Execution Phase**: Pure implementation of broken-down tasks
5. **Generic Workflow**: Works for any type of development work
6. **Clean Context**: Sub-agents keep main context focused

## Proposed Solution Architecture

### Four-Phase Workflow

1. **Research** → `notes/[topic]/research.md`
2. **Plan** → `notes/[topic]/plan.md`
3. **Breakdown** → `notes/[topic]/breakdowns.md`
4. **Execute** → Actual implementation (no document, just code)

### New Agents Required

1. **research-orchestrator**: Coordinates multiple research agents
2. **implementation-planner**: Creates strategic plans from research
3. **breakdown-agent**: Breaks plans into parallel, testable tasks
4. **execution-coordinator**: Manages parallel implementation

### New Commands Required

1. **research [topic]**: Initiates research phase
2. **plan [topic]**: Creates plan from research
3. **breakdown [topic]**: Creates task breakdown
4. **execute [topic]**: Implements the breakdown

## Folder Structure Design

```
notes/
├── add-user-authentication/
│   ├── research.md      # Research findings
│   ├── plan.md          # Strategic plan
│   └── breakdowns.md    # Execution tasks
├── fix-memory-leak/
│   ├── research.md
│   ├── plan.md
│   └── breakdowns.md
└── refactor-api-client/
    ├── research.md
    ├── plan.md
    └── breakdowns.md
```

## Benefits Analysis

### Advantages Over Current System

1. **Clear Separation**: Each phase has single responsibility
2. **Maximum Parallelization**: Breakdown phase optimizes for parallel execution
3. **Reusable Artifacts**: Each document can be referenced later
4. **Generic**: Same workflow for features, fixes, refactoring, etc.
5. **Context Efficiency**: Research done by sub-agents
6. **TDD/BDD Enforced**: Tests specified before implementation

### Compatibility with Existing System

- Existing agents remain unchanged
- Current planning agents can coexist
- Existing commands can remain for backward compatibility
- Same notes folder structure, just organized differently

## Implementation Priorities

### Phase 1: Core Agents

1. research-orchestrator
2. implementation-planner
3. breakdown-agent
4. execution-coordinator

### Phase 2: Workflow Commands

1. research command
2. plan command
3. breakdown command
4. execute command

### Phase 3: Integration

1. Update AGENTS.md
2. Update CLAUDE.md orchestration guidance
3. Test with sample workflows

## Risk Assessment

### Low Risk

- Additive approach - doesn't break existing system
- Existing agents and commands remain functional
- Can be tested incrementally

### Considerations

- Need to ensure new workflow is intuitive
- Documentation must clearly explain when to use each phase
- May need iteration based on usage patterns

## Success Criteria

### Functional Requirements

- Each phase produces expected artifacts
- Parallel execution works as designed
- TDD/BDD workflow is enforced
- Sub-agents keep main context clean

### Quality Requirements

- Documents are well-structured and reusable
- Workflow is intuitive and efficient
- Performance better than current mixed approach
- Maintains existing agent ecosystem benefits
