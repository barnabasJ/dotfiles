# /implement

Execute the implementation of planned work with expert consultation.

## Orchestration Process

As the orchestrator, you will:

1. **Identify current work context**:

   - Check git branch to determine work type
   - Locate planning document in:
     - notes/features/<feature_name>.md
     - notes/fixes/<fix_name>.md
     - notes/tasks/<task_name>.md

2. **Read and analyze the plan**:

   - Understand the implementation steps
   - Identify what needs to be built
   - Determine the order of operations

3. **Consult experts for guidance**:

   - Use **architecture-agent** for code placement and module organization
   - Use **elixir-expert** for Elixir/Phoenix/Ash patterns and best practices
   - Use **research-agent** for unfamiliar libraries or frameworks
   - Use **consistency-reviewer** to ensure alignment with existing patterns

4. **Implement systematically**:
   - Execute implementation tasks based on expert guidance
   - Apply recommended patterns and approaches
   - Verify each step independently
   - Track progress through the plan

**CRITICAL**: Implementation is NOT complete without working tests:

- Every feature/fix must have comprehensive test coverage
- Tests must pass before claiming any step complete
- Consult experts for test patterns and approaches
- Never report implementation as "done" without working tests

## Example Workflow

```markdown
# As orchestrator, you would:

1. Read notes/features/user-authentication.md
2. See it needs: User model, auth endpoints, JWT tokens, tests

3. Consult architecture-agent: "Where should I place the User model and auth
   endpoints? What's the proper module structure for authentication?"

4. Consult elixir-expert: "What are the best practices for creating an Ash
   resource for User with email, password_hash, and confirmed_at fields? How
   should I handle authentication in Phoenix?"

5. Implement based on guidance: Create User resource following expert patterns

6. Verify: Run tests to ensure User resource works correctly

7. Continue with next task: Implement authentication endpoints following same
   consultation pattern
```

## Usage Examples

```bash
# On a feature branch
git checkout feature/user-authentication
/implement  # Orchestrator reads plan, consults experts, implements with guidance

# On a fix branch
git checkout fix/memory-leak
/implement  # Orchestrator analyzes fix, gets expert guidance, implements solution

# On a task branch
git checkout task/update-dependencies
/implement  # Orchestrator breaks down task, consults experts, executes systematically
```

## Key Benefits

- **Expert-driven implementation**: Every decision backed by domain expertise
- **Pattern consistency**: Implementation aligns with existing codebase
  standards
- **Quality focus**: Tests and validation built into every step
- **Systematic approach**: Controlled implementation strategy with expert
  guidance

You maintain control of the implementation strategy while leveraging expert
guidance for high-quality, consistent code.
