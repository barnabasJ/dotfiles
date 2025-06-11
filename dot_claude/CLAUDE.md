# Development Workflow

## Git Workflow

- Always check out a new branch when starting to work on a new feature
- Use conventional commits
- Make small commits while working, so we can better analyze changes and revert
  if necessary
- Do not reference claude in the commit messages

## Planning Documents

- Always create a planning document before starting any non-trivial
  implementation
- Always check the existing codebase, API documentation, and webhook structures
  before creating a plan. Don't assume - verify the actual data structures and
  patterns used.
- Save planning docs in the notes folder in the project (unless otherwise
  specified)
- Always keep the planning document up to date with the current state of
  implementation
- Mark tasks as completed as you progress
- Update technical details if implementation differs from plan

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

### Example: Simple Feature

```markdown
# Add Git Aliases Implementation Plan

## Problem Statement

Missing commonly used git aliases in shell configuration

## Solution Overview

Add git aliases to dot_aliases.tmpl file

## Implementation Plan

- [ ] Define aliases needed (gs, gaa, gcm, gp)
- [ ] Add git aliases to dot_aliases.tmpl
- [ ] Run `chezmoi apply` and test each alias works
- [ ] Verify aliases don't conflict with existing commands

## Technical Details

- **File**: `dot_aliases.tmpl`
- **Aliases**: gs, gaa, gcm, gp, etc.

## Success Criteria

- All aliases functional in both bash and zsh
- No conflicts with existing system commands
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
