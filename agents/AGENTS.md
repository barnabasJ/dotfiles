# Agent-First Development Workflow

## Specialized Agents - Use Them Heavily!

**CRITICAL**: This system includes specialized agents that you should use extensively. Do not attempt to work without consulting the appropriate specialized agents first.

### Available Specialized Agents

#### **elixir-expert** - MANDATORY for All Elixir Work
- **When to use**: ALWAYS when working with Elixir, Phoenix, Ecto, Ash, or any Elixir libraries
- **Purpose**: Consults usage_rules.md and provides documentation-backed guidance
- **Never**: Attempt Elixir work without consulting this agent first
- **Tools**: `mix usage_rules.docs`, `mix usage_rules.search_docs`

#### **research-agent** - MANDATORY for Technical Research  
- **When to use**: ALWAYS when researching documentation, APIs, libraries, frameworks, or technical information
- **Purpose**: Conducts comprehensive web research with authoritative sources
- **Never**: Make assumptions about unfamiliar technologies - research them first
- **Specializes in**: Official docs, API research, technology comparisons, usage patterns

#### **elixir-reviewer** - MANDATORY After Elixir Changes
- **When to use**: ALWAYS after making changes to Elixir code, Ash applications, Phoenix applications, or Ecto schemas
- **Purpose**: Runs comprehensive code quality checks, security analysis, and validation tools
- **Never**: Commit Elixir changes without running this agent first
- **Tools**: mix format, credo, dialyzer, sobelow, deps.audit, test coverage, security scanning

### Agent Usage Principles

1. **Agent-First Approach**: Always identify which specialized agent(s) to use before starting work
2. **Multiple Agent Consultation**: Complex tasks may require multiple agents (e.g., research-agent + elixir-expert)
3. **Trust Agent Expertise**: Follow agent recommendations rather than making assumptions
4. **Iterative Consultation**: Re-consult agents as work progresses and new questions arise
5. **Complete Elixir Workflow**: elixir-expert (before & during) → implement → elixir-reviewer (after)

# Development Workflow

## Git Workflow

- Always check out a new branch when starting to work on a new feature
- Use conventional commits
- Make small commits while working, so we can better analyze changes and revert
  if necessary
- Do not reference claude in the commit messages

## Planning Documents with Agent Integration

- **Always create a planning document** before starting any non-trivial implementation
- **Consult specialized agents first**: Use research-agent for unfamiliar technologies, elixir-expert for Elixir work
- **Agent-informed planning**: Base your plan on agent research rather than assumptions
- **Document agent consultations**: Include which agents were consulted and their recommendations
- **Save planning docs** in the notes folder in the project (unless otherwise specified)
- **Keep plans updated** with current implementation state and new agent insights
- **Mark tasks as completed** as you progress
- **Update technical details** when implementation differs from plan based on agent guidance

### Planning Document Structure

#### 1. Problem Statement

- Clear description of the issue or need
- Why this matters / impact

#### 2. Solution Overview

- High-level approach
- Key design decisions

#### 3. Implementation Plan

For simple features: single checklist with integrated testing For complex
features: break into logical steps, each with its own testing

##### Step Format (for complex features)

- [ ] Define expected behavior/test criteria
- [ ] Implement the feature
- [ ] Verify it works as expected

#### 4. Technical Details

- File locations and naming conventions
- Configuration specifics
- Dependencies or prerequisites

#### 5. Success Criteria

- Overall verification that the feature works
- Expected behavior after all changes

#### 6. Notes/Considerations (optional)

- Edge cases
- Future improvements
- Related issues

### Example: Agent-Informed Planning

```markdown
# Phoenix LiveView Chat Implementation Plan

## Agent Consultations Performed
- **elixir-expert**: Researched Phoenix LiveView patterns, PubSub usage, and authentication
- **research-agent**: Found official Phoenix LiveView documentation and examples

## Problem Statement

Need to implement real-time chat functionality using Phoenix LiveView

## Solution Overview (Based on Agent Research)

Implement LiveView-based chat following Phoenix best practices:
- LiveView for real-time UI updates
- PubSub for message broadcasting  
- Presence for user tracking
- Database persistence with Ecto

## Implementation Plan

### Step 1: Agent-Guided Setup
- [ ] Consult elixir-expert for LiveView project structure
- [ ] Research-agent: Find latest LiveView authentication patterns
- [ ] Follow agent recommendations for dependencies

### Step 2: Implementation
- [ ] Create chat LiveView following elixir-expert patterns
- [ ] Implement PubSub messaging per agent guidance
- [ ] Add user presence tracking
- [ ] Test real-time functionality

## Technical Details (From Agent Research)

- **LiveView Module**: `MyAppWeb.ChatLive`
- **PubSub Topic**: `"chat:lobby"`
- **Database**: Messages schema with user associations
- **Authentication**: LiveView mount/3 with user session

## Success Criteria

- Real-time messaging works across multiple clients
- User presence accurately tracked
- Messages persist to database
- Follows Phoenix/LiveView best practices per agent guidance
```

### Example: Complex Feature

```markdown
# Neovim AI Integration Implementation Plan

## Problem Statement

Need to integrate multiple AI tools (CodeCompanion, Copilot, Avante) into Neovim
configuration with proper keybindings, lazy loading, and API key management

## Solution Overview

Configure AI plugins with non-conflicting keybindings, proper lazy loading for
performance, and secure API key handling through environment variables

## Implementation Plan

### Step 1: Core Plugin Installation

- [ ] Add CodeCompanion, Copilot, and Avante to lazy plugin specs
- [ ] Configure basic plugin options and dependencies
- [ ] Start Neovim and verify all plugins install without errors
- [ ] Check `:checkhealth` for each plugin

### Step 2: API Key Configuration

- [ ] Set up ANTHROPIC_API_KEY for CodeCompanion
- [ ] Configure GitHub Copilot authentication
- [ ] Add OPENAI_API_KEY for Avante if needed
- [ ] Test each plugin authenticates successfully
- [ ] Ensure no API keys are hardcoded in configs

### Step 3: Keybinding Setup

- [ ] Define leader-based keybindings for each plugin
- [ ] Add <leader>cc for CodeCompanion chat
- [ ] Configure <leader>cp for Copilot suggestions
- [ ] Set up <leader>av for Avante commands
- [ ] Test all keybindings work without conflicts
- [ ] Update which-key descriptions

### Step 4: Performance Optimization

- [ ] Configure lazy loading with appropriate events/commands
- [ ] Set CodeCompanion to load on first use
- [ ] Configure Copilot to load on InsertEnter
- [ ] Measure startup time stays under 100ms
- [ ] Verify plugins load when expected

### Step 5: Integration Testing

- [ ] Test CodeCompanion chat and inline completions
- [ ] Verify Copilot suggestions appear in insert mode
- [ ] Check Avante features work as expected
- [ ] Ensure no conflicts between AI suggestions
- [ ] Test in different file types (lua, python, js)

## Technical Details

- **Config files**:
  - `lua/barnabasj/lazy/codecompanion.lua`
  - `lua/barnabasj/lazy/copilot.lua`
  - `lua/barnabasj/lazy/avante.lua`
- **Dependencies**:
  - curl for API calls
  - Node.js for Copilot
- **Environment variables**:
  - `ANTHROPIC_API_KEY`
  - `OPENAI_API_KEY`

## Success Criteria

- All three AI tools accessible via keybindings
- No performance impact on startup
- Smooth integration without conflicts
- API keys securely managed
- Works across different project types

## Notes

- Consider adding toggle commands for each AI tool
- May need to adjust inline completion priorities
- Future: Add custom prompts for CodeCompanion
```

## Progress Tracking and Documentation

### Planning Document Maintenance

- **Update the plan frequently** as you complete tasks and discover new
  requirements
- **Mark completed tasks clearly** with ✅ and add detailed status summaries
- **Include current status section** with "what works", "what's next", and "how
  to run"
- **Document discovered limitations** immediately when found, plan next steps

### Status Communication

- **Be explicit about what's working vs. what's planned**
- **Provide clear instructions for testing current functionality**
- **Explain technical debt and mock implementations**
- **Update status after each major milestone**

## Critical Success Factors

1. **Plan thoroughly upfront** - saves time and prevents architectural issues
2. **Update documentation as you go** - don't leave it until the end
3. **Use the tools you create** - if you make a Makefile, use it consistently
4. **Test frequently** - both automated tests and manual UX testing
5. **Track progress visibly** - todos and planning docs show momentum and help
   prioritize
6. **Be critical and explain reasoning** - don't just agree with user requests,
   think through decisions

## Communication Patterns

### Be Critical and Analytical

- **Question decisions** rather than just implementing requests
- **Explain reasoning** behind technical choices
- **Point out potential issues** before they become problems
- **Suggest alternatives** when you see better approaches

### User Feedback Integration

- **Listen to user observations** about workflow issues (e.g., "why create
  Makefile if not using it?")
- **Learn from mistakes** and update processes accordingly
- **Ask clarifying questions** about requirements and priorities
- **Validate understanding** by explaining back what you're going to do
