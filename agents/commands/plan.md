# Create Strategic Implementation Plan

**IMPORTANT**: Use the **implementation-planner** agent to transform research
findings into detailed, strategic implementation plans with clear architecture
and integration guidance.

## Command Overview

This command creates strategic implementation plans from research findings using
the **implementation-planner** agent to design comprehensive implementation
approaches within the four-phase workflow system.

## Workflow

### 1. **Implementation Planning Phase**

- **Use implementation-planner agent** to create strategic implementation plans
- The agent will:
  - Analyze research findings and expert recommendations
  - Coordinate **architecture-agent** for structural and integration planning
  - Consult appropriate **domain experts** for pattern validation
  - Coordinate **senior-engineer-reviewer** for strategic validation
  - Create comprehensive implementation plans with clear phases
  - Save planning docs in notes/[topic-name]/plan.md

### 2. **Folder Structure Integration**

The implementation-planner builds on the existing research structure:

```
notes/
├── [topic-name]/
│   ├── research.md      # Comprehensive research findings (from research phase)
│   ├── plan.md          # Strategic implementation plan
│   └── [ready for breakdown phase]
```

### 3. **Strategic Implementation Planning**

- **Research-based planning**: Transform research into actionable strategies
- **Architecture integration**: Coordinate structural and integration design
- **Risk management**: Identify risks and plan mitigation strategies
- **Phase-based approach**: Break complex implementations into logical phases

## What the Implementation-Planner Agent Provides

The **implementation-planner** agent creates strategic plans with:

### **Research Foundation Integration**

- Analysis of research findings and expert recommendations
- Strategic approach selection based on comprehensive research
- Risk assessment from research phase incorporated
- Expert consultation results integrated into planning

### **Technical Architecture Planning**

- **architecture-agent**: System integration architecture and code organization
- **Domain experts**: Pattern validation and convention compliance
- **senior-engineer-reviewer**: Strategic approach and scalability validation
- Interface design and abstraction boundary planning

### **Implementation Strategy Development**

- Multi-phase implementation approach with clear milestones
- Dependencies and coordination requirements planning
- Quality and testing strategy integration
- Success criteria and metrics definition

## Implementation Planning Scope

### **Medium Complexity Planning**

- API integrations with existing systems
- Feature additions with moderate architectural impact
- Technology integrations following established patterns
- Service implementations with standard patterns

### **High Complexity Planning**

- Multi-system integration with significant architectural changes
- Real-time features requiring new infrastructure components
- Large-scale features affecting multiple system areas
- Performance-critical implementations requiring optimization

## Four-Phase Workflow Integration

This command continues the **planning phase** of the four-phase workflow:

1. **research** - Comprehensive multi-dimensional research (completed)
2. **plan** ← _You are here_
3. **breakdown** - Detailed task decomposition (next phase)
4. **execute** - Parallel implementation execution (final phase)

## Prerequisites

### **Required Before Planning**

- Research phase completed with notes/[topic-name]/research.md
- Research findings include technical, architectural, and strategic dimensions
- Expert recommendations and risk assessment available

### **Planning Dependencies**

- Research document must exist and be comprehensive
- Topic folder structure must be established
- Research findings must include implementation guidance

## Planning Quality Standards

### **Strategic Foundation**

- Built on comprehensive research findings
- Incorporates expert recommendations and architectural guidance
- Includes risk assessment and mitigation strategies
- Defines clear success criteria and metrics

### **Implementation Readiness**

- Phases are logical and manageable
- Dependencies and prerequisites clearly identified
- Integration points and coordination requirements defined
- Quality and testing strategy integrated throughout

## Example Usage

**Medium Complexity Planning:**

```
claude plan "API integration patterns for Phoenix applications"
```

**High Complexity Planning:**

```
claude plan "real-time chat system architecture with LiveView, PubSub, and Presence"
```

## Plan Structure Overview

The **implementation-planner** agent creates plans with:

### **Core Sections**

- **Research Foundation**: Analysis and strategic decisions
- **Implementation Strategy**: Primary approach and alternatives
- **Technical Architecture**: System design and integration patterns
- **Agent Consultations**: Architecture and expert guidance received
- **Implementation Phases**: Clear phases with objectives and success criteria
- **Quality and Testing Strategy**: Comprehensive validation approaches
- **Success Criteria**: Measurable outcomes and acceptance criteria

### **Phase Organization**

- **Phase 1**: Foundation and core infrastructure
- **Phase 2**: Core functionality implementation
- **Phase 3**: Integration and advanced features
- **Phase 4**: Optimization and finalization

## Success Criteria

Planning phase is complete when:

- Strategic implementation plan created in notes/[topic-name]/plan.md
- Architecture consultations completed and documented
- Implementation phases defined with clear objectives
- Quality and testing strategy integrated
- Success criteria and metrics established
- Ready for **breakdown** phase with comprehensive strategic guidance

The **implementation-planner** agent transforms research into actionable
implementation strategies, providing the strategic foundation for detailed task
breakdown and successful execution.
