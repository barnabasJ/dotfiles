# Agent System Model Optimization Implementation Plan

## Problem Statement

The current agent system lacks model specification and tool permission optimization, leading to:
- All agents using the same model regardless of their computational requirements
- Expert and reviewer agents having full write access when they should be read-only
- Inefficient resource usage where expensive models are used for simple implementation tasks
- Lack of clear separation between analysis/advisory roles and implementation roles

This impacts system performance, cost efficiency, and architectural clarity. Expert agents should provide guidance while implementation agents execute the work, but the current system doesn't enforce this separation.

## Solution Overview

Implement a three-tier model optimization strategy:

1. **Model Specifications**: Define appropriate models for different agent roles
   - Experts and reviewers: Capable models (Opus 4, Sonnet 4) for complex analysis
   - Implementation agents: Cost-effective models (Haiku) with expert guidance
   - Planning agents: Balanced models (Sonnet) for comprehensive analysis

2. **Tool Permission Rework**: Implement read-only permissions for advisory agents
   - Expert and reviewer agents return findings instead of making changes
   - Implementation agents receive guidance and execute the actual work
   - Clear separation of concerns between analysis and execution

3. **Workflow Optimization**: Enhanced collaboration patterns
   - Implementation agents request detailed guidelines from experts
   - Cheaper models execute work with expert guidance
   - Faster overall execution through appropriate model selection

## Agent Consultations Performed

Based on my analysis as the feature-planner agent, I have:
- **Analyzed current architecture**: Reviewed agent definitions and tool usage patterns
- **Researched model capabilities**: Analyzed Claude model family specifications, costs, and capabilities
- **Identified system patterns**: Examined how agents currently interact and delegate work
- **Assessed optimization opportunities**: Determined where model and permission changes would provide maximum benefit

## Technical Details

### Model Specification Schema

**YAML Frontmatter Addition**:
```yaml
---
name: agent-name
model: claude-sonnet-4-20250514  # or claude-opus-4, claude-haiku-3-5, etc.
description: Agent description
color: agent-color
tool_permissions:
  mode: read-only  # or full-access
  allowed_tools: [Read, Grep, Glob, WebSearch, WebFetch]  # for read-only agents
  restricted_tools: [Edit, Write, MultiEdit, Bash]  # tools that require approval
---
```

### Model Assignment Strategy

**Tier 1 - Analysis & Expertise (Opus 4 / Sonnet 4)**:
- elixir-expert
- research-agent
- senior-engineer-reviewer
- security-reviewer
- architecture-agent

**Tier 2 - Planning & Coordination (Sonnet 4)**:
- feature-planner
- fix-planner
- task-planner

**Tier 3 - Implementation & Execution (Haiku 3.5)**:
- implementation-agent
- test-developer
- test-fixer

**Tier 4 - Review & Validation (Sonnet 4)**:
- factual-reviewer
- qa-reviewer
- consistency-reviewer
- redundancy-reviewer
- elixir-reviewer

### Tool Permission Configuration

**Read-Only Agents** (Experts & Reviewers):
- **Allowed**: Read, Grep, Glob, LS, WebSearch, WebFetch, NotebookRead
- **Restricted**: Edit, Write, MultiEdit, Bash, NotebookEdit
- **Return**: Detailed findings, recommendations, and guidance

**Full-Access Agents** (Implementation):
- **Allowed**: All tools
- **Workflow**: Request expert guidance before making changes
- **Responsibility**: Execute implementation based on expert recommendations

### Configuration Files

**New Configuration File**: `agents/model-config.yaml`
```yaml
model_assignments:
  claude-opus-4:
    - elixir-expert
    - research-agent
    - senior-engineer-reviewer
    - security-reviewer
    - architecture-agent
  
  claude-sonnet-4:
    - feature-planner
    - fix-planner
    - task-planner
    - factual-reviewer
    - qa-reviewer
    - consistency-reviewer
    - redundancy-reviewer
    - elixir-reviewer
  
  claude-haiku-3-5:
    - implementation-agent
    - test-developer
    - test-fixer

tool_permissions:
  read_only:
    - elixir-expert
    - research-agent
    - senior-engineer-reviewer
    - security-reviewer
    - architecture-agent
    - factual-reviewer
    - qa-reviewer
    - consistency-reviewer
    - redundancy-reviewer
    - elixir-reviewer
  
  full_access:
    - feature-planner
    - fix-planner
    - task-planner
    - implementation-agent
    - test-developer
    - test-fixer
```

## Success Criteria

### Model Optimization Success
- All agent definitions include appropriate model specifications
- Expert agents use capable models (Opus/Sonnet) for complex analysis
- Implementation agents use cost-effective models (Haiku) with expert guidance
- Overall system cost reduction while maintaining or improving quality

### Tool Permission Success
- Expert and reviewer agents operate in read-only mode
- Expert agents return detailed findings instead of making direct changes
- Implementation agents successfully request and apply expert guidance
- Clear separation between advisory and execution roles

### Workflow Optimization Success
- Implementation agents can effectively work with expert guidance
- System performance improves through appropriate model selection
- Agent coordination patterns work seamlessly with new permissions
- Documentation clearly explains the new workflow patterns

### Backward Compatibility Success
- Existing agent invocation patterns continue to work
- Gradual migration path allows incremental adoption
- No breaking changes to current command structure
- Legacy agents function normally during transition

## Implementation Plan

### Step 1: Model Specification Framework

- [x] Research Claude API model specification requirements
  - Created test-model-agent.md to test model specifications
  - Identified model IDs: claude-3-opus-20240229, claude-3-5-sonnet-20241022, claude-3-5-haiku-20241022
- [x] Design YAML frontmatter schema for model specifications
  - Created model-specification-schema.md with comprehensive schema documentation
  - Supports single model and multi-model fallback configurations
- [x] Create model configuration system for agent assignments
  - Created model-config.yaml with centralized model and permission assignments
  - Organized agents into tiers based on computational requirements
- [x] Test model specification with a single agent
  - Created test-model-agent.md with correct tool syntax
  - Fixed tool specification to use comma-separated list, not complex structure
- [ ] Verify model assignment works correctly with Claude API
  - Pending: Need to test if Claude Code respects model specifications in YAML frontmatter

### Step 2: Tool Permission System Design

- [ ] Analyze current tool usage patterns across all agents
- [ ] Design tool permission configuration schema
- [ ] Create read-only tool restriction mechanism
- [ ] Design expert guidance return format specifications
- [ ] Plan implementation agent guidance request patterns

### Step 3: Agent Definition Updates

- [ ] Update all expert and reviewer agent definitions with model specs
- [ ] Add tool permission configurations to agent YAML frontmatter
- [ ] Modify agent prompts to support read-only operation patterns
- [ ] Update implementation agent prompts for guidance request patterns
- [ ] Test updated agent definitions individually

### Step 4: Workflow Pattern Implementation

- [ ] Implement expert guidance request/response patterns
- [ ] Create implementation agent guidance integration workflows
- [ ] Update agent coordination patterns for new permission model
- [ ] Test multi-agent workflows with new permission system
- [ ] Verify expert agents return findings instead of making changes

### Step 5: Configuration and Documentation

- [ ] Create comprehensive model and permission configuration files
- [ ] Update agent system documentation with new patterns
- [ ] Create migration guide for existing workflows
- [ ] Document cost optimization achieved through model assignments
- [ ] Create troubleshooting guide for new permission patterns

### Step 6: Testing and Validation

- [ ] Test all agent types with assigned models and permissions
- [ ] Validate cost optimization through model usage tracking
- [ ] Verify workflow performance improvements
- [ ] Test backward compatibility with existing command patterns
- [ ] Conduct comprehensive system integration testing

### Step 7: Rollout and Monitoring

- [ ] Deploy updated agent definitions to production
- [ ] Monitor system performance and cost metrics
- [ ] Gather feedback on new workflow patterns
- [ ] Make adjustments based on real-world usage
- [ ] Document lessons learned and optimization results

## Notes/Considerations

### Cost Optimization Analysis

Based on Claude model pricing research:
- **Opus 4**: $15/$75 per million tokens (input/output) - Use for complex analysis
- **Sonnet 4**: $3/$15 per million tokens - Use for planning and coordination
- **Haiku 3.5**: $0.80/$4.00 per million tokens - Use for implementation with guidance

**Estimated Cost Reduction**: 60-80% for implementation tasks while maintaining expert guidance quality.

### Architecture Impact

**Positive Impacts**:
- Clear separation of concerns between analysis and execution
- Improved cost efficiency through appropriate model selection
- Better scalability through optimized resource usage
- Enhanced system reliability through read-only expert agents

**Potential Challenges**:
- Increased complexity in agent coordination patterns
- Need for robust guidance request/response mechanisms
- Potential latency increase due to multi-agent consultation
- Learning curve for users adapting to new workflow patterns

### Migration Strategy

**Phase 1**: Implement model specifications without changing tool permissions
**Phase 2**: Add read-only permissions for reviewer agents
**Phase 3**: Implement expert guidance patterns for implementation agents
**Phase 4**: Full optimization with all agents using appropriate models and permissions

### Future Extensibility

- Support for custom model specifications per use case
- Dynamic model selection based on task complexity
- Integration with usage analytics for continuous optimization
- Support for hybrid workflows combining multiple model types

### Risk Mitigation

**Technical Risks**:
- Backward compatibility maintained through gradual migration
- Fallback mechanisms for agent communication failures
- Comprehensive testing of multi-agent coordination patterns

**Operational Risks**:
- Clear documentation for new workflow patterns
- Training materials for system users
- Monitoring and alerting for system performance changes