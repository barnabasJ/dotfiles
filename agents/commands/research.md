# Initiate Comprehensive Research Phase

**IMPORTANT**: Use the **research-orchestrator** agent to coordinate
comprehensive research across multiple domains and sources for complex topics.

## Command Overview

This command initiates the research phase of the four-phase workflow system,
using the **research-orchestrator** agent to coordinate comprehensive
multi-dimensional research for complex topics requiring thorough investigation.

## Workflow

### 1. **Research Orchestration Phase**

- **Use research-orchestrator agent** to coordinate comprehensive research
- The agent will:
  - Coordinate **research-agent** for technical documentation and APIs
  - Engage appropriate **domain experts** (elixir-expert, lua-expert, etc.)
  - Coordinate **architecture-agent** for structural considerations
  - Coordinate **senior-engineer-reviewer** for strategic assessment
  - Synthesize findings into comprehensive research documentation
  - Create topic-based folder structure in notes/[topic-name]/

### 2. **Folder Structure Creation**

The research-orchestrator will create a topic-based folder structure:

```
notes/
├── [topic-name]/
│   ├── research.md      # Comprehensive research findings
│   └── [ready for planning phase]
```

### 3. **Research Integration and Synthesis**

- **Multi-source coordination**: Research agent + domain experts + architecture
  analysis
- **Comprehensive coverage**: Technical, architectural, domain-specific, and
  strategic dimensions
- **Strategic recommendations**: Actionable guidance for implementation planning
- **Risk assessment**: Identification of challenges and mitigation strategies

## What the Research-Orchestrator Agent Provides

The **research-orchestrator** agent creates comprehensive research with:

### **Multi-Agent Research Coordination**

- **research-agent**: Technical documentation, APIs, frameworks, integration
  patterns
- **Domain experts**: Patterns, conventions, best practices for specific
  technologies
- **architecture-agent**: System integration, structural considerations, impact
  analysis
- **senior-engineer-reviewer**: Strategic assessment, scalability, long-term
  implications

### **Research Synthesis**

- Comprehensive findings integration across all research dimensions
- Strategic recommendations based on multi-source analysis
- Risk identification and mitigation strategies
- Implementation readiness assessment and guidance

### **Quality Research Standards**

- Authoritative sources and official documentation prioritized
- Multi-source validation and cross-referencing
- Currency checking and information relevance
- Practical, actionable guidance over theoretical concepts

## Research Scope Examples

### **Simple Research Topics**

- API integration patterns for specific frameworks
- Configuration management approaches
- Tool integration and setup procedures
- Technology comparison and selection

### **Complex Research Topics**

- Multi-technology integration architectures
- Real-time system design and implementation
- Large-scale feature development strategies
- System migration and modernization approaches

## Four-Phase Workflow Integration

This command initiates the **research phase** of the four-phase workflow:

1. **research** ← _You are here_
2. **plan** - Strategic implementation planning (next phase)
3. **breakdown** - Detailed task decomposition (follows planning)
4. **execute** - Parallel implementation execution (final phase)

## When to Use Research vs Existing Commands

### **Use research command for:**

- Complex topics requiring multi-dimensional analysis
- Unfamiliar technologies or integration patterns
- Topics requiring strategic assessment and architectural consideration
- Work that benefits from comprehensive expert consultation

### **Use existing commands for:**

- **feature** - Direct feature development with existing knowledge
- **fix** - Bug fixes and problem resolution
- **task** - Simple, well-understood work items

## Example Usage

**Simple Research:**

```
claude research "API integration patterns for Phoenix applications"
```

**Complex Research:**

```
claude research "real-time chat system architecture with LiveView, PubSub, and Presence"
```

The **research-orchestrator** agent handles the complexity of multi-agent
coordination and research synthesis, providing comprehensive foundation
knowledge for successful implementation planning and execution.

## Success Criteria

Research phase is complete when:

- Comprehensive research document created in notes/[topic-name]/research.md
- All relevant dimensions researched (technical, architectural, domain,
  strategic)
- Strategic recommendations and implementation guidance provided
- Risk assessment and mitigation strategies identified
- Ready for **plan** phase with solid foundation knowledge
