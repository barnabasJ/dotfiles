# Four-Phase AI Workflow System - Implementation Research

## Current System Analysis

### Agent System Architecture

The current system uses a well-organized agent ecosystem with clear separation
of responsibilities:

**Location**: `/agents/agent-definitions/` - Contains 23 specialized agents
organized by function:

#### Current Planning Agents

- `feature-planner.md` - Complex feature planning with research integration
- `fix-planner.md` - Systematic bug fix planning with root cause analysis
- `task-planner.md` - Lightweight task planning with smart escalation

#### Implementation Agents

- `implementation-agent.md` - Plan execution specialist
- `test-developer.md` - Systematic test development methodology
- `test-fixer.md` - Test failure resolution specialist

#### Review Agents (6 specialized reviewers)

- `factual-reviewer.md` - Implementation vs planning verification
- `qa-reviewer.md` - Testing & quality assurance
- `senior-engineer-reviewer.md` - Strategic technical review
- `security-reviewer.md` - Security vulnerability analysis
- `consistency-reviewer.md` - Codebase consistency checking
- `redundancy-reviewer.md` - Duplication detection & consolidation

#### Domain Expert Agents

- `elixir-expert.md`, `elixir-reviewer.md` - Elixir ecosystem
- `research-agent.md` - Technical research specialist
- `architecture-agent.md` - Project structure & integration
- `documentation-expert.md`, `documentation-reviewer.md` - Documentation
  specialists
- `neovim-expert.md`, `lua-expert.md`, `chezmoi-expert.md`, `logseq-expert.md` -
  Tool-specific experts

### Current Command System Architecture

**Location**: `/agents/commands/` - Contains 17 workflow commands

#### Current Planning Commands

- `feature.md` - Delegates to `feature-planner` agent
- `fix.md` - Delegates to `fix-planner` agent
- `task.md` - Delegates to `task-planner` agent

#### Implementation Commands

- `implement.md` - Plan execution using `implementation-agent`
- `add-tests.md` - Uses `test-developer` for systematic test creation
- `fix-tests.md` - Uses `test-fixer` for test failure resolution

#### Review Commands

- `review.md` - **Runs ALL review agents in parallel** (critical pattern)

#### Workflow Commands

- `commit.md`, `pr.md` - Git workflow integration
- `document.md`, `update-docs.md` - Documentation workflows
- `continue.md`, `step.md`, `checkpoint.md` - Execution control

### Current Notes Organization

**Location**: `/notes/` - Current folder structure:

```
notes/
├── features/          # Feature planning docs (2 items)
├── four-phase-workflow-system/  # This research project
│   └── research.md
└── [various planning docs]
```

**Missing folders for current system**:

- `fixes/` - No dedicated fix planning folder
- `tasks/` - No dedicated task planning folder

### Current Orchestration Architecture

**Primary orchestration**: Global `CLAUDE.md` in user's `.claude/` directory
defines:

1. **Agent Orchestration Paradigm**: Orchestrator pattern with specialized
   agents
2. **Sequential Orchestration**: Agent chains for dependent work
3. **Parallel Orchestration**: **CRITICAL** - All review agents run in parallel
4. **Agent Selection Matrix**: Mapping work types to agent workflows
5. **Mandatory Review Phase**: All implementation followed by parallel reviews

**Project-specific**: Local `CLAUDE.md` contains repository-specific guidance
(Chezmoi dotfiles)

## Gap Analysis for Four-Phase Workflow

### Missing Agents for Four-Phase System

Based on research document requirements, we need 4 new agents:

1. **research-orchestrator** - Coordinates multiple research agents
2. **implementation-planner** - Creates strategic plans from research
3. **breakdown-agent** - Breaks plans into parallel, testable tasks
4. **execution-coordinator** - Manages parallel implementation

### Missing Commands for Four-Phase System

Research identified 4 new commands needed:

1. **research [topic]** - Initiates research phase
2. **plan [topic]** - Creates plan from research
3. **breakdown [topic]** - Creates task breakdown
4. **execute [topic]** - Implements the breakdown

### Missing Folder Structure

Four-phase system requires:

```
notes/
├── [topic-name]/
│   ├── research.md      # Research findings
│   ├── plan.md          # Strategic plan
│   └── breakdowns.md    # Execution tasks
```

## Required Changes Analysis

### 1. Agent Definitions Changes

#### New Agent Files Needed

- `/agents/agent-definitions/research-orchestrator.md`
- `/agents/agent-definitions/implementation-planner.md`
- `/agents/agent-definitions/breakdown-agent.md`
- `/agents/agent-definitions/execution-coordinator.md`

#### Existing Agent Modifications

**Likely minimal changes needed** - existing agents remain functional and
complementary

### 2. Command System Changes

#### New Command Files Needed

- `/agents/commands/research.md`
- `/agents/commands/plan.md`
- `/agents/commands/breakdown.md`
- `/agents/commands/execute.md`

#### Existing Command Modifications

**Backward compatibility maintained** - existing commands (`feature.md`,
`fix.md`, `task.md`) can coexist with four-phase workflow

### 3. Orchestration System Changes

#### Global CLAUDE.md Updates

**Location**: User's `.claude/CLAUDE.md` needs new sections:

1. **Four-Phase Workflow Orchestration Patterns**

   - Research phase coordination
   - Plan creation workflows
   - Breakdown optimization patterns
   - Execution coordination approaches

2. **Agent Selection Matrix Updates**

   - When to use four-phase vs existing workflows
   - Agent routing for topic-based work
   - Integration with existing agent patterns

3. **Folder Structure Conventions**
   - Topic-based organization patterns
   - Phase document templates
   - Naming conventions for four-phase work

#### Project CLAUDE.md Updates

**Minimal changes needed** - project-specific file focuses on repository details
(Chezmoi), not workflow patterns

### 4. Folder Structure Changes

#### New Folder Requirements

Dynamic topic-based folders like:

```
notes/
├── add-user-authentication/
│   ├── research.md
│   ├── plan.md
│   └── breakdowns.md
├── fix-memory-leak/
│   ├── research.md
│   ├── plan.md
│   └── breakdowns.md
```

#### Existing Folder Integration

Current `features/` and `fixes/` folders can coexist with topic-based
organization

### 5. Integration Points Analysis

#### Critical Integration Requirements

1. **Agent Tool Compatibility**

   - New agents need same tool access as existing agents
   - Tool permissions:
     `Task, Read, Write, TodoWrite, Grep, Glob, LS, NotebookRead`
   - Research agents need `WebSearch, WebFetch` tools

2. **Orchestration Pattern Integration**

   - Four-phase workflow must integrate with existing parallel review pattern
   - **CRITICAL**: Maintain "all review agents in parallel" for comprehensive
     analysis
   - Sequential four-phase workflow followed by parallel review validation

3. **Command Integration Points**

   - New commands must work with existing git workflow patterns
   - Branch naming conventions for four-phase work
   - Integration with existing `review.md`, `commit.md`, `pr.md` commands

4. **Agent Consultation Patterns**
   - Four-phase agents must properly consult domain experts (elixir-expert,
     etc.)
   - Research orchestrator must coordinate with research-agent
   - Implementation planner must integrate with architecture-agent
   - Execution coordinator must work with implementation-agent

## Risk Assessment

### Low Risk Areas

- **Additive Approach**: Four-phase system adds to existing without breaking
- **Backward Compatibility**: Existing agents and commands remain functional
- **Incremental Testing**: Can test phase by phase before full implementation
- **Tool Consistency**: New agents use same tools as existing system

### Medium Risk Areas

- **Orchestration Complexity**: New workflow patterns increase coordination
  complexity
- **User Learning Curve**: Additional commands and concepts to learn
- **Documentation Maintenance**: More agents and commands to document and
  maintain

### Mitigation Strategies

1. **Comprehensive Documentation**: Clear guidance on when to use each workflow
2. **Progressive Rollout**: Implement and test one phase at a time
3. **Integration Testing**: Verify four-phase workflow integrates with review
   patterns
4. **User Training**: Clear examples and decision trees for workflow selection

## Implementation Priority Analysis

### Phase 1: Core Four-Phase Agents (High Priority)

1. `research-orchestrator.md` - **CRITICAL** - Coordinates research phase
2. `implementation-planner.md` - **CRITICAL** - Creates strategic plans
3. `breakdown-agent.md` - **CRITICAL** - Task decomposition specialist
4. `execution-coordinator.md` - **CRITICAL** - Parallel execution management

### Phase 2: Four-Phase Commands (High Priority)

1. `research.md` - Initiates research phase
2. `plan.md` - Creates implementation plans
3. `breakdown.md` - Generates task breakdowns
4. `execute.md` - Coordinates implementation

### Phase 3: Orchestration Integration (Medium Priority)

1. Update global `CLAUDE.md` with four-phase patterns
2. Add agent selection guidance for four-phase vs existing workflows
3. Document topic-based folder organization patterns
4. Create workflow decision trees

### Phase 4: Documentation and Testing (Medium Priority)

1. Update `AGENTS.md` with new four-phase agents
2. Create comprehensive workflow examples
3. Test integration with existing review patterns
4. Validate backward compatibility

## Key Implementation Decisions Needed

### 1. Agent Specialization Boundaries

- How much overlap between four-phase agents and existing planners?
- Should existing planners be modified or remain separate?
- How to handle escalation from simple to four-phase workflows?

### 2. Orchestration Integration Strategy

- How to integrate four-phase workflow with mandatory parallel reviews?
- Should four-phase execution automatically trigger review agents?
- How to coordinate topic-based work with existing git workflow patterns?

### 3. Tool and Permission Architecture

- Do four-phase agents need additional tools beyond existing set?
- How to handle research agent coordination and web access?
- Should execution coordinator have broader tool access for parallel work?

### 4. User Experience Design

- How to make four-phase vs existing workflow selection intuitive?
- Should there be automatic escalation from simple to four-phase workflows?
- How to maintain simplicity while adding powerful four-phase capabilities?

## Success Metrics

### Functional Requirements

- All four phases produce expected artifacts (research.md, plan.md,
  breakdowns.md, implementation)
- Parallel execution works as designed within execution phase
- TDD/BDD workflow enforced through breakdown phase
- Sub-agents keep main context clean through delegation

### Integration Requirements

- Four-phase workflow integrates seamlessly with existing review pattern
- Backward compatibility with existing agents and commands maintained
- Topic-based organization coexists with existing folder structures
- Agent consultation patterns work across workflow types

### Quality Requirements

- Documents are well-structured, reusable, and follow established patterns
- Workflow selection is intuitive and well-documented
- Performance better than current mixed approach for complex work
- Maintains all benefits of existing agent ecosystem

## Next Steps

1. **Create Core Agents**: Start with the four critical agents for each phase
2. **Build Command Interface**: Implement the four workflow commands
3. **Test Integration**: Verify compatibility with existing systems
4. **Update Orchestration**: Integrate patterns into global CLAUDE.md
5. **Document and Train**: Create comprehensive guidance and examples

This research provides the foundation for implementing the four-phase workflow
system while preserving all existing functionality and maintaining the robust
agent orchestration architecture already in place.
