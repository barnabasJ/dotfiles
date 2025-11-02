---
name: testing
description: Software testing
---

# Testing Expertise

Language-agnostic testing methodologies, strategies, and best practices for
building reliable, maintainable test suites.

## Testing Methodologies

### Test-Driven Development (TDD)

**Red-Green-Refactor Cycle:**

1. **Red**: Write a failing test that describes desired behavior
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve code while keeping tests passing
4. **Repeat**: Continue with next behavior

### Behavior-Driven Development (BDD)

**Given-When-Then Pattern:**

- **Given**: Setup - establish the initial context
- **When**: Action - perform the behavior being tested
- **Then**: Assertion - verify the expected outcome

## Test Strategy Development

### What to Test

- **Core functionality**: Primary features and business logic
- **Edge cases**: Boundary conditions and unusual inputs
- **Error paths**: Failure scenarios and error handling
- **Boundary conditions**: Min/max values, empty inputs, null handling

### What Not to Test

- **Private implementation details**: Test public interfaces
- **External dependencies**: Mock or stub external services
- **Framework code**: Trust well-tested frameworks
- **Trivial code**: Getters/setters without logic

### Coverage Strategies

- **Meaningful coverage**: Test behavior, not just lines of code
- **Risk-based testing**: More tests for high-risk, critical functionality
- **Diminishing returns**: 100% coverage is not always the goal
- **Coverage metrics**: Use as guidance, not targets

## Test Organization

### Test Structure Principles

**AAA Pattern (Arrange-Act-Assert):**

```
test "feature works correctly" do
  # Arrange - Set up test data and preconditions
  user = create_test_user()

  # Act - Execute the behavior being tested
  result = perform_action(user)

  # Assert - Verify expected outcomes
  assert result == expected_value
end
```

### Test Naming

Clear, descriptive test names that explain:

- What is being tested
- Under what conditions
- What the expected outcome is

Examples:

- `test_user_creation_with_valid_data_succeeds`
- `test_authentication_with_invalid_password_fails`
- `test_empty_cart_checkout_returns_error`

### File Organization

- **Mirror source structure**: Tests should parallel production code structure
- **Separate by type**: Unit, integration, and E2E tests in different
  directories
- **Group related tests**: Use describe/context blocks for related scenarios

## Test Quality Principles

### Test Isolation and Independence

- Each test should run in isolation
- Tests should not depend on other tests
- Tests should not share mutable state
- Order of test execution should not matter

### Test Readability

- One assertion per test when practical
- Clear test names that describe behavior
- Minimal test setup (use helpers/fixtures)
- Self-documenting test code

### Test Maintainability

- **DRY principle in tests**: Extract common setup to helpers
- **But prefer clarity**: Some duplication is okay for readability
- **Update tests with code**: Keep tests in sync with production code
- **Remove obsolete tests**: Delete tests for removed features

### Fast Test Execution

- Unit tests should be very fast (< 100ms each)
- Integration tests should be reasonably fast (< 1s when possible)
- Use test parallelization when available
- Mock expensive operations (database, network, file I/O)

## Mock/Stub Strategies

### When to Mock

- External services (APIs, databases, file systems)
- Slow operations that would make tests slow
- Non-deterministic behavior (random, time, network)
- Hard-to-reproduce scenarios (errors, edge cases)

### When Not to Mock

- Simple logic that's fast to execute
- Code you own and control
- When mocking makes test more complex than the code
- When you're testing integration between components

### Avoiding Over-Mocking

- Mock at boundaries, not internal details
- Test real integrations when feasible
- Use real objects for simple dependencies
- Verify mocks don't drift from real implementations

## Common Test Smells

### Test Interdependence

**Problem**: Tests that depend on execution order or shared state **Solution**:
Ensure complete test isolation with proper setup/teardown

### Obscure Tests

**Problem**: Tests that are hard to understand **Solution**: Clear names, good
structure, minimal setup

### Slow Tests

**Problem**: Tests that take too long to run **Solution**: Mock expensive
operations, optimize test data

### Fragile Tests

**Problem**: Tests that break on unrelated changes **Solution**: Test behavior
not implementation, avoid over-specification

### Flaky Tests

**Problem**: Tests that sometimes pass and sometimes fail **Solution**: Avoid
timing dependencies, ensure deterministic setup

## Test Data Management

### Fixtures

- Pre-defined test data loaded from files
- Good for consistent, reusable test scenarios
- Can become stale and hard to maintain

### Factories/Builders

- Programmatically generate test data
- Flexible and maintainable
- Can specify only relevant attributes
- **Preferred for most cases**

### Inline Data

- Data defined directly in test
- Good for simple, one-off scenarios
- Makes test self-contained

## Testing Best Practices

### General Principles

1. **Keep tests simple**: Tests should be easier to understand than production
   code
2. **Test one thing**: Each test should verify one specific behavior
3. **Make failures obvious**: Clear assertions with good error messages
4. **Maintain tests**: Refactor tests as you refactor code
5. **Run tests frequently**: Fast feedback loop is essential

### Error Messages

- Use descriptive assertion messages
- Include actual and expected values
- Provide context about what was being tested
- Help diagnose failures quickly

### Test Performance

- **Fast unit tests**: Run entire suite in seconds
- **Optimize setup**: Share expensive setup when safe
- **Parallel execution**: Run independent tests concurrently
- **Skip slow tests**: Mark and run separately in CI

## Coverage Guidelines

### Meaningful Coverage Metrics

- **Line coverage**: Percentage of code lines executed
- **Branch coverage**: Percentage of code branches taken
- **Function coverage**: Percentage of functions called
- **Useful metric**: Tests actually exercise different scenarios

### Coverage Goals

- Aim for high coverage on critical paths
- Accept lower coverage on trivial code
- Use coverage to find untested areas
- Don't game the metrics with meaningless tests

## Test Types

### Unit Tests

- Test individual functions/methods in isolation
- Fast, focused, numerous
- Mock dependencies
- Verify logic correctness

### Integration Tests

- Test component interactions
- May use real dependencies (database, etc.)
- Verify components work together
- Slower than unit tests

### End-to-End Tests

- Test complete user flows
- Use real system (or close simulation)
- Verify system behavior from user perspective
- Slowest, most comprehensive

### Property-Based Testing

- Generate random inputs within constraints
- Verify invariants hold across inputs
- Find edge cases you didn't think of
- Complement example-based tests

## Testing Anti-Patterns

- **Testing implementation details**: Test behavior, not internals
- **One giant test**: Break into focused, smaller tests
- **Testing everything**: Focus on valuable tests
- **Ignoring test failures**: Fix or remove failing tests
- **Copying production bugs**: Tests should prevent bugs, not preserve them
