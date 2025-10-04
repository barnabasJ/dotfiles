# /add-tests

Systematic test development with expert consultation.

## Orchestration Process

As the orchestrator, you will:

1. **Analyze testing needs**:

   - Identify what code needs test coverage
   - Determine test scope (unit, integration, e2e)
   - Assess existing test patterns

2. **Plan test strategy**:

   - Decide what tests to create
   - Identify testing priorities
   - Determine coverage requirements

3. **Consult experts for guidance**:

   - Use **elixir-expert** for Elixir/Phoenix test patterns (ExUnit, Ash,
     Phoenix)
   - Use **research-agent** for unfamiliar testing frameworks or approaches
   - Use **consistency-reviewer** to check existing test patterns
   - Use **qa-reviewer** for coverage strategy and test quality

4. **Implement tests systematically**:
   - Apply test patterns based on expert guidance
   - Develop incrementally (one test at a time)
   - Verify tests pass and provide proper coverage
   - Track progress through implementation

## Testing Methodology

### **Language-Agnostic Systematic Approach**

- Proven systematic approach for any programming language
- Incremental development with focus-driven testing
- Comprehensive coverage planning (success paths, errors, edge cases)

### **Expert Consultation Integration**

- **For Elixir Projects**: Consult **elixir-expert** for ExUnit, Ash, and
  Phoenix patterns
- **For Other Languages**: Use **research-agent** for framework-specific
  guidance
- **Pattern Consistency**: Always check existing test patterns with
  **consistency-reviewer**

### **Quality Assurance**

- External boundary mocking strategies
- Test data generation following established patterns
- Integration testing approaches
- Coverage verification and quality metrics

## Development Workflow

### Phase 1: Analysis & Expert Consultation

- Analyze project context and testing framework
- Consult appropriate language experts for guidance
- Check existing test patterns for consistency

### Phase 2: Test Architecture Planning

- Map coverage requirements (success, error, edge cases)
- Design test data strategy using established patterns
- Plan mock strategy for external dependencies

### Phase 3: Incremental Implementation

- Start with core success paths
- Use focus-driven development (one test at a time)
- Build comprehensive coverage systematically

### Phase 4: Verification & Quality Assurance

- Verify all tests pass
- Confirm coverage meets requirements
- Review with qa-reviewer for quality standards
- Document any testing patterns or decisions

## Success Criteria

Ensure that tests meet these standards:

- ✅ **Comprehensive Coverage**: Success paths, error cases, and edge cases
  covered
- ✅ **Language-Appropriate Patterns**: Uses correct testing patterns for the
  language/framework
- ✅ **Pattern Consistency**: Tests align with existing test structure and style
- ✅ **Expert-Validated Approach**: Guidance from appropriate language expert
  (elixir-expert, etc.)
- ✅ **All Tests Pass**: Complete test suite runs successfully

## Example Workflow

```markdown
# As orchestrator, you would:

1. Analyze: Need tests for User authentication module (login, logout, session)

2. Consult elixir-expert: "What are the best practices for testing Phoenix
   authentication? How should I structure tests for login/logout/session
   management?"

3. Apply expert guidance: Expert recommends ConnCase for controller tests, use
   setup blocks for auth state, test both success and failure paths

4. Implement tests incrementally:

   - Start with login success path
   - Add login failure cases
   - Add logout tests
   - Add session validation tests

5. Verify: Run full test suite, check coverage meets requirements

6. Complete: ✅ Created 12 authentication tests with full coverage. All tests
   pass.
```

## Usage Examples

```bash
/add-tests
# Orchestrator identifies coverage gaps, consults experts, and implements tests

# For specific functionality
"Add tests for the user registration feature"
# Orchestrator analyzes registration code, gets expert patterns, implements tests

# For comprehensive coverage
"Add complete test coverage for the Payment module"
# Orchestrator plans coverage strategy, consults experts, implements all test cases
```

## Key Benefits

- **Expert-driven patterns**: Tests follow language-specific best practices
- **Systematic approach**: Controlled test development strategy
- **Quality focus**: Tests verified before proceeding
- **Pattern consistency**: Tests align with existing codebase standards

You maintain control of the testing strategy while leveraging expert guidance
for high-quality, consistent test coverage.
