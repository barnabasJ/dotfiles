# Systematic Test Failure Resolution Guide

This command provides a proven methodology for systematically diagnosing and
fixing failing tests while maintaining test suite integrity and code quality.

## Core Principles

1. **One Test at a Time**: Focus on a single failing test to avoid context
   switching and ensure thorough analysis
2. **Root Cause Analysis**: Fix underlying issues, not just symptoms or test
   assertions
   1. Create sub agent to check usage-rules and docs for the libraries we are
      going to use while fixing the test
3. **Systematic Isolation**: Use `@tag :focus` to isolate development and
   prevent noise from other failures
4. **Verify Before Moving**: Ensure each fix is complete before proceeding to
   the next test
5. **Maintain Test Quality**: Keep tests meaningful and accurate representations
   of expected behavior

## Methodology

### Phase 1: Test Failure Assessment & Prioritization

#### 1.1 Comprehensive Test Analysis

```bash
# Run full test suite to get complete failure overview
mix test

# Generate test report with detailed failure information
mix test --formatter ExUnit.CLIFormatter --seed 0 --max-failures 10

# Identify patterns in failures
mix test 2>&1 | grep -E "(Error|Failed|Exception)" | sort | uniq -c
```

**Document Test Failures:**

- Count and categorize failure types
- Identify if failures are related or independent
- Note any cascading failures (one test breaking others)
- Check for flaky tests (intermittent failures)

#### 1.2 Failure Prioritization Strategy

**Priority Framework:**

1. **Critical Infrastructure**: Test setup, generators, shared utilities
2. **Blocking Failures**: Tests that prevent others from running
3. **Core Functionality**: Main workflow and business logic tests
4. **Integration Tests**: End-to-end and external service tests
5. **Edge Cases**: Boundary conditions and error scenarios

**Example Prioritization:**

```bash
# High Priority - Setup/Infrastructure failures
mix test test/support/ test/test_helper.exs

# Medium Priority - Core functionality
mix test test/steward/core/

# Lower Priority - Edge cases and integrations
mix test test/steward/discord/edge_cases_test.exs
```

#### 1.3 Choose Starting Point

**Selection Criteria:**

- Start with the simplest, most isolated failure
- Choose tests with clear, actionable error messages
- Avoid tests with complex dependencies initially
- Focus on tests that don't require extensive setup

### Phase 2: Focused Test Resolution

#### 2.1 Isolate Target Test

```elixir
# Add focus tag to target test
@tag :focus
test "specific failing scenario" do
  # existing test implementation
end
```

```bash
# Run only the focused test
mix test --only focus

# Get detailed output for analysis
mix test --only focus --trace
```

#### 2.2 Systematic Failure Analysis

**Error Analysis Framework:**

1. **Read the Complete Error Message**

   ```bash
   # Capture full error output
   mix test --only focus 2>&1 | tee test_failure.log
   ```

2. **Identify Error Categories**
   - **Compilation Errors**: Missing modules, syntax issues
   - **Setup Failures**: Test data generation, database issues
   - **Logic Errors**: Incorrect assertions, wrong expected values
   - **Integration Failures**: External service mocking, API changes
   - **Concurrency Issues**: Race conditions, timing problems

3. **Trace the Failure Path**
   - Start from the error line and work backwards
   - Identify the last successful operation
   - Check data state at failure point
   - Verify assumptions about test setup

#### 2.3 Root Cause Investigation

**Investigation Patterns:**

```elixir
# Pattern 1: Test Data Issues
test "failing test example" do
  # Add debugging to understand data state
  user = generate(user_generator())
  IO.inspect(user, label: "Generated User")

  guild = generate(guild_generator())
  IO.inspect(guild, label: "Generated Guild")

  # Continue with test...
end
```

```elixir
# Pattern 2: Mock Issues
test "external service integration" do
  # Verify mock setup
  expect(ExternalService, :call, fn params ->
    IO.inspect(params, label: "Mock Called With")
    {:ok, "expected_response"}
  end)

  # Test implementation...
end
```

```elixir
# Pattern 3: State Validation Issues
test "state machine transitions" do
  resource = generate(resource_generator(state: :initial))

  # Verify initial state
  assert resource.state == :initial

  # Test transition
  updated =
    resource
    |> Ash.Changeset.for_update(:process)
    |> Ash.update!(authorize?: false)

  # Debug intermediate state
  IO.inspect(updated, label: "After Update")

  assert updated.state == :processed
end
```

### Phase 3: Implementation & Verification

#### 3.1 Fix Implementation Strategies

**Common Fix Patterns:**

```elixir
# Fix 1: Update Test Data Generators
def user_generator(opts \\ []) do
  seed_generator(
    %User{
      # Fix: Add required field that was missing
      discord_id: sequence(:discord_id, &(100_000 + &1)),
      name: sequence(:name, &"User #{&1}"),
      # Add any other required fields
    },
    overrides: opts
  )
end
```

```elixir
# Fix 2: Correct Mock Expectations
test "external API integration" do
  # Fix: Match exact function signature
  expect(Nostrum.Api.Message, :create, fn channel_id, %{content: content} ->
    {:ok, %{id: 12345, content: content}}
  end)

  # Test continues...
end
```

```elixir
# Fix 3: Update Assertions to Match New Behavior
test "processes data correctly" do
  result = MyModule.process_data(input)

  # Fix: Update assertion to match current implementation
  assert result.status == :completed  # Was :finished
  assert result.processed_at != nil
end
```

```elixir
# Fix 4: Fix Code Logic Issues
def process_user_data(user_data) do
  # Fix: Add nil check that was missing
  case user_data do
    nil -> {:error, "User data cannot be nil"}
    %{id: nil} -> {:error, "User ID is required"}
    valid_data ->
      # Process valid data
      {:ok, transform_data(valid_data)}
  end
end
```

#### 3.2 Verification Process

```bash
# Step 1: Verify focused test passes
mix test --only focus

# Step 2: Check for regressions in related tests
mix test test/path/to/related_test.exs

# Step 3: Run broader test suite to catch cascading issues
mix test --seed 0 --max-failures 5
```

#### 3.3 Code Quality Checks

```bash
# Ensure code formatting is correct
mix format

# Check for linting issues
mix credo

# Verify type specifications if using Dialyzer
mix dialyzer
```

### Phase 4: Iteration & Final Verification

#### 4.1 Remove Focus and Continue

```elixir
# Remove focus tag from fixed test
# @tag :focus  # Remove this line
test "specific failing scenario" do
  # test implementation
end
```

```bash
# Run full test suite to identify next failure
mix test

# Repeat process for next failing test
```

#### 4.2 Progress Tracking

**Track Resolution Progress:**

```bash
# Get current failure count
FAILURES=$(mix test 2>&1 | grep -o '[0-9]* failures' | grep -o '[0-9]*')
echo "Current failures: $FAILURES"

# Compare with previous runs
echo "Previous failures: $PREVIOUS_FAILURES"
echo "Progress: $(($PREVIOUS_FAILURES - $FAILURES)) tests fixed"
```

#### 4.3 Final Quality Verification

```bash
# Ensure all tests pass
mix test --seed 0

# Run with different seeds to catch flaky tests
mix test --seed 1
mix test --seed 42

# Verify test coverage remains adequate
mix test --cover
```

## Common Failure Patterns & Solutions

### Pattern 1: Generator/Test Data Issues

```elixir
# Problem: Missing required fields in generators
# Error: ** (Ash.Error.Invalid) [field: value is required]

# Solution: Update generator with all required fields
def resource_generator(opts \\ []) do
  seed_generator(
    %Resource{
      required_field: sequence(:required, &"value_#{&1}"),
      # Add any missing required fields
      created_at: DateTime.utc_now(),
      status: :active
    },
    overrides: opts
  )
end
```

### Pattern 2: Mock Signature Mismatches

```elixir
# Problem: Mock doesn't match actual function signature
# Error: ** (FunctionClauseError) no function clause matching

# Solution: Check actual function and fix mock
expect(External.Api, :call, fn
  %{required_param: value} when is_binary(value) ->
    {:ok, "response"}
  _invalid_params ->
    {:error, "Invalid parameters"}
end)
```

### Pattern 3: State Machine Issues

```elixir
# Problem: Invalid state transitions
# Error: ** (Ash.Error.Invalid) [state: cannot transition from initial to completed]

# Solution: Follow proper transition sequence
test "state transitions correctly" do
  resource = generate(resource_generator(state: :initial))

  # Fix: Use proper transition sequence
  processing_resource =
    resource
    |> Ash.Changeset.for_update(:start_processing)
    |> Ash.update!(authorize?: false)

  completed_resource =
    processing_resource
    |> Ash.Changeset.for_update(:complete_processing)
    |> Ash.update!(authorize?: false)

  assert completed_resource.state == :completed
end
```

### Pattern 4: Authorization Issues

```elixir
# Problem: Authorization failures in tests
# Error: ** (Ash.Error.Forbidden)

# Solution: Use proper actor or bypass authorization
test "system operation" do
  # Fix: Add authorize?: false for test operations
  result =
    resource
    |> Ash.Changeset.for_update(:system_update)
    |> Ash.update!(authorize?: false)  # Add this

  assert result.updated_at != nil
end
```

## Testing Tools & Techniques

### Debug Output Management

```elixir
# Add temporary debugging that's easy to find and remove
test "debugging example" do
  # DEBUG: Remove before commit
  IO.inspect(test_data, label: "DEBUG Test Data")

  result = perform_operation(test_data)

  # DEBUG: Remove before commit
  IO.inspect(result, label: "DEBUG Result")

  assert result.status == :success
end
```

### Focused Test Running

```bash
# Run specific test file
mix test test/specific_test.exs

# Run specific test by line number
mix test test/specific_test.exs:42

# Run tests matching pattern
mix test --only tag:integration

# Run with trace for detailed output
mix test --only focus --trace
```

### Error Analysis Tools

```bash
# Capture test output for analysis
mix test --only focus 2>&1 | tee debug.log

# Search for specific error patterns
rg "Error|Exception|Failed" debug.log

# Check for dependency issues
mix deps.get
mix deps.compile
```

## Success Criteria

### Resolution Quality Metrics

- ✅ **Target Test Passes**: The focused test consistently passes
- ✅ **No Regressions**: Existing passing tests remain green
- ✅ **Proper Fix**: Root cause addressed, not just assertions changed
- ✅ **Code Quality**: Fix maintains or improves code quality
- ✅ **Test Validity**: Test still accurately represents expected behavior

### Process Quality Metrics

- ✅ **Systematic Approach**: Following the focus → fix → verify cycle
- ✅ **Complete Analysis**: Understanding failure before implementing fix
- ✅ **Incremental Progress**: One test fixed at a time
- ✅ **Documentation**: Changes explained and justified
- ✅ **Clean State**: No debug code or focus tags left behind

### Final Verification Metrics

- ✅ **100% Pass Rate**: All tests in the suite pass
- ✅ **Stable Results**: Tests pass consistently across multiple runs
- ✅ **No Focus Tags**: All `@tag :focus` removed from codebase
- ✅ **Clean Output**: No debug statements or temporary code
- ✅ **Maintained Coverage**: Test coverage remains adequate

## Example Resolution Workflow

```bash
# 1. Assess current test state
mix test | grep -E "failures|errors"

# 2. Pick first failure and focus it
# Edit test file to add @tag :focus

# 3. Isolate and analyze
mix test --only focus --trace

# 4. Investigate root cause
# Add debugging, check mocks, verify test data

# 5. Implement fix
# Fix code or update test as appropriate

# 6. Verify fix works
mix test --only focus

# 7. Check for regressions
mix test test/path/to/related_tests.exs

# 8. Remove focus tag and continue
# Edit test file to remove @tag :focus

# 9. Move to next failure
mix test

# 10. Repeat until complete
# Continue until mix test shows 0 failures

# 11. Final verification
mix test --seed 0
mix test --seed 42
```

This methodology ensures systematic, thorough resolution of test failures while
maintaining code quality and test suite integrity. The key is patience,
systematic analysis, and fixing one test at a time until the entire suite is
green.
