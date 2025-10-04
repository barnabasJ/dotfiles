# /fix-tests

Systematic test failure diagnosis and resolution.

## Orchestration Process

As the orchestrator, you will:

1. **Identify failing tests**:

   - Run test suite to find failures
   - Categorize failure types
   - Prioritize what to fix first

2. **Analyze failure patterns**:

   - Determine root causes
   - Identify fix approach
   - Assess dependencies between failures

3. **Consult experts for guidance**:

   - Use **elixir-expert** for Elixir/Phoenix test patterns and debugging
     approaches
   - Use **research-agent** for unfamiliar frameworks or error patterns
   - Use **qa-reviewer** for test quality and coverage assessment
   - Use **consistency-reviewer** to ensure fixes align with existing patterns

4. **Implement fixes systematically**:
   - Apply fixes based on expert guidance
   - Verify each fix independently
   - Run comprehensive regression tests
   - Track progress through resolution

## Debugging Methodology

### **Language-Agnostic Systematic Approach**

- Proven systematic approach for any programming language and testing framework
- Focus-driven debugging (one test at a time)
- Root cause analysis rather than symptom fixes

### **Expert Consultation Integration**

- **Language-Specific Experts**: Consult the appropriate language expert
  (elixir-expert, lua-expert, neovim-expert, etc.) for framework-specific
  debugging patterns
- **Research Support**: Use **research-agent** when encountering unfamiliar
  frameworks or error patterns
- **Pattern Consistency**: Use **consistency-reviewer** to ensure fixes align
  with existing patterns

### **Quality Assurance**

- Systematic failure prioritization (infrastructure → core → integration → edge
  cases)
- Complete regression testing after each fix
- Expert validation of fix quality and approach

## Resolution Workflow

### Phase 1: Failure Assessment & Expert Consultation

- Run comprehensive test failure analysis
- Consult appropriate language experts for debugging guidance
- Prioritize failures using proven framework

### Phase 2: Focused Test Resolution

- Isolate target test using focus mechanisms
- Apply systematic failure analysis with expert guidance
- Investigate root causes rather than symptoms

### Phase 3: Implementation & Verification

- Implement fixes based on expert consultation
- Verify fixes don't introduce regressions
- Apply language-specific quality checks

### Phase 4: Progress Tracking & Quality Assurance

- Remove focus tags and continue with next failure
- Track resolution progress and patterns
- Final quality verification with expert agents

## Success Criteria

Ensure that fixes meet these standards:

- ✅ **Root Cause Resolution**: Fixes address underlying issues, not just
  symptoms
- ✅ **Language-Appropriate Fixes**: Uses correct patterns and conventions for
  your specific language/framework
- ✅ **No Regressions**: Comprehensive testing prevents new issues
- ✅ **Pattern Consistency**: Fixes align with existing codebase patterns
- ✅ **Expert-Validated Approach**: Guidance from the appropriate language
  expert (elixir-expert, lua-expert, neovim-expert, etc.)

## Example Workflow

```markdown
# As orchestrator, you would:

1. Run tests and find 5 authentication tests failing
2. Analyze: All failing with "JWT token invalid" errors

3. Consult elixir-expert: "5 authentication tests are failing with JWT token
   errors. What are common causes and debugging approaches for JWT test failures
   in Phoenix?"

4. Apply expert guidance: Expert recommends checking test.exs config and mock
   setup. Investigation reveals missing JWT_SECRET in test.exs config.

5. Implement fix: Add JWT_SECRET to test.exs and update mocks based on expert
   patterns

6. Verify: Run full test suite to ensure no regressions

7. Complete: ✅ Fixed 5 tests. Root cause: Missing JWT_SECRET in test.exs
   config.
```

## Usage Examples

```bash
/fix-tests
# Orchestrator identifies failures, consults experts, and implements fixes

# For specific test failures
"Fix the failing user validation tests"
# Orchestrator analyzes validation test failures and coordinates fixes with expert guidance

# For systematic resolution
"Fix all test failures one by one"
# Orchestrator prioritizes and systematically fixes issues with expert consultation
```

## Key Benefits

- **Expert debugging**: Proactive consultation with language experts
- **Systematic approach**: Controlled fixing priority and strategy
- **Quality control**: Each fix verified before proceeding
- **Pattern consistency**: Fixes align with existing codebase standards

You maintain control of the resolution strategy while leveraging expert guidance
for high-quality, consistent fixes.
