# Systematic Test Development Guide

This command provides a proven methodology for developing comprehensive test
coverage using iterative, systematic approaches that achieve 100% test success
rates.

## Core Principles

1. **Incremental Development**: Build test coverage one test at a time, ensuring
   each passes before moving to the next
2. **Comprehensive Coverage**: Cover both success paths and failure scenarios
   systematically
3. **Realistic Scenarios**: Test conditions that mirror production environments
   and real-world edge cases
4. **Maintainable Patterns**: Use consistent structures and generators for
   long-term maintainability
5. **Quality Over Quantity**: Focus on meaningful tests rather than maximizing
   test count

## Methodology

### Phase 1: Test Planning & Architecture

#### 1.1 Map Coverage Requirements

**Identify Core Workflows:**

- **Success Paths**: Main workflow phases and state transitions
- **Failure Scenarios**: Error handlers and edge cases
- **Integration Flows**: End-to-end workflows
- **State Management**: All state transitions and validation rules

**Document Test Structure:**

```elixir
# Organize tests by logical groupings
describe "success workflows" do
  test "handles main success path with proper state transitions"
  test "processes variations with expected outputs"
end

describe "error handling" do
  test "handles external service failures gracefully"
  test "recovers from validation errors appropriately"
end

describe "edge cases" do
  test "handles boundary conditions correctly"
  test "manages concurrent operations safely"
end

describe "integration workflows" do
  test "completes end-to-end process successfully"
end
```

#### 1.2 Design Test Data Strategy

**Generator-Based Approach:**

```elixir
# Create reusable generators for consistent test data
def resource_generator(opts \\ []) do
  seed_generator(
    %Resource{
      field1: sequence(:field1, &"value_#{&1}"),
      field2: sequence(:field2, &(1000 + &1)),
      # ... other fields
    },
    overrides: opts
  )
end

# Usage pattern
resource = generate(resource_generator(field1: "custom_value"))
```

#### 1.3 Plan Mock Strategy

**External Boundary Mocking:**

- Mock external APIs and services
- Mock third-party integrations
- Avoid mocking internal business logic
- Use global setup in test_helper.exs for consistent mocking

### Phase 2: Iterative Test Implementation

#### 2.1 Start with Core Success Path

```bash
# Begin with the main happy path
@tag :focus
test "main success workflow completes correctly" do
  # Implement core success scenario
  # Verify expected state transitions
  # Check data transformations
end

# Run focused test until green
mix test --only focus
```

#### 2.2 Systematic Test Development

**Development Cycle:**

1. **Write One Test**: Focus on a single scenario
2. **Use @tag :focus**: Isolate current development
3. **Implement Until Green**: Build code to pass the test
4. **Remove Focus Tag**: Integrate with existing tests
5. **Verify All Pass**: Ensure no regressions
6. **Add Next Test**: Continue with next scenario

```elixir
# Example development pattern
@tag :focus
test "handles user input validation correctly" do
  # Setup test conditions
  # Execute the action
  # Assert expected outcomes
end
```

#### 2.3 Build Comprehensive Coverage

**Coverage Expansion Strategy:**

- **Success Variations**: Different valid input scenarios
- **Error Conditions**: Each possible failure mode
- **Edge Cases**: Boundary conditions and unusual inputs
- **Integration Tests**: Complete workflow verification

### Phase 3: Quality Assurance & Verification

#### 3.1 Test Quality Checklist

**Implementation Quality:**

- ✅ All tests have actual implementations (no stubs or placeholders)
- ✅ External dependencies properly mocked
- ✅ Test data generated consistently using generators
- ✅ Both success and failure paths covered
- ✅ State transitions verified in each test
- ✅ Error scenarios reflect realistic conditions

**Mock Quality:**

- ✅ Only external boundaries mocked
- ✅ Internal business logic tested directly
- ✅ Mock expectations match real API signatures
- ✅ Error responses mirror actual service failures

#### 3.2 Coverage Verification

```bash
# Verify no placeholder tests remain
rg "validates.*setup" test/
rg "without.*implementation" test/

# Check test coverage
mix test --cover

# Verify error handling coverage
rg "error.*handler" test/
```

#### 3.3 Integration Testing

**End-to-End Verification:**

```elixir
test "complete workflow integration" do
  # Start from initial state
  # Execute full workflow
  # Verify final state and side effects
  # Check all intermediate state transitions
end
```

### Phase 4: Maintenance & Documentation

#### 4.1 Test Organization

**File Structure:**

- Group related tests in logical modules
- Separate unit tests from integration tests
- Use descriptive test and describe block names
- Follow project naming conventions

**Example Organization:**

```
test/
├── steward/
│   ├── discord/
│   │   ├── message_move/workflow_test.exs
│   │   ├── image_generation/workflow_test.exs
│   │   └── consumer/events_test.exs
│   └── chat/
│       └── conversation/workflow_test.exs
```

#### 4.2 Documentation Patterns

```elixir
defmodule MyApp.WorkflowTest do
  @moduledoc """
  Comprehensive test suite for [Feature] workflow.

  Covers success paths, error handling, and edge cases for the complete
  workflow including state transitions and external integrations.
  """
  use MyApp.DataCase, async: false

  describe "main success workflow" do
    @describedoc "Tests the primary happy path scenarios"
    # tests here
  end

  describe "error handling" do
    @describedoc "Tests error conditions and recovery mechanisms"
    # tests here
  end
end
```

## Common Patterns & Solutions

### Pattern 1: State Machine Testing

```elixir
# Test state transitions systematically
test "transitions through all expected states" do
  initial_resource = generate(resource_generator(state: :initial))

  # Test each transition
  updated_resource =
    initial_resource
    |> Ash.Changeset.for_update(:start_processing)
    |> Ash.update!(authorize?: false)

  assert updated_resource.state == :processing

  final_resource =
    updated_resource
    |> Ash.Changeset.for_update(:complete_processing)
    |> Ash.update!(authorize?: false)

  assert final_resource.state == :completed
end
```

### Pattern 2: Error Serialization Testing

```elixir
# Test complex error handling
test "serializes complex errors for database storage" do
  error_data = %SomeStruct{
    field: "value",
    nested: %{data: "complex"}
  }

  result =
    resource
    |> Ash.Changeset.for_update(:handle_error, %{error: error_data})
    |> Ash.update!(authorize?: false)

  # Verify error was serialized properly
  assert result.error_details["type"] == "SomeStruct"
  assert result.error_details["serialized_at"] != nil
end
```

### Pattern 3: External API Integration Testing

```elixir
# Mock external services realistically
test "handles external API failures gracefully" do
  expect(ExternalApi.Service, :call, fn _params ->
    {:error, %{status: 503, message: "Service Unavailable"}}
  end)

  result =
    resource
    |> Ash.Changeset.for_update(:process_with_external_api)
    |> Ash.update!(authorize?: false)

  assert result.state == :failed
  assert result.error_details["external_service_error"] == "Service Unavailable"
end
```

### Pattern 4: Concurrent Operation Testing

```elixir
# Test concurrent access scenarios
test "handles concurrent operations safely" do
  resource = generate(resource_generator())

  tasks = for _ <- 1..10 do
    Task.async(fn ->
      resource
      |> Ash.Changeset.for_update(:concurrent_operation)
      |> Ash.update!(authorize?: false)
    end)
  end

  results = Task.await_many(tasks)

  # Verify all operations completed successfully
  assert Enum.all?(results, &(&1.state == :completed))
end
```

## Testing Tools & Techniques

### Mock Management

```elixir
# Global mock setup (test_helper.exs)
Mimic.copy(Nostrum.Api.Message)
Mimic.copy(ExternalService.Client)
Mimic.copy(ThirdPartyApi.Adapter)

# Test-specific expectations
test "specific scenario" do
  expect(ExternalService.Client, :fetch, fn id ->
    {:ok, %{id: id, data: "mock_response"}}
  end)

  # test implementation
end
```

### Data Generation

```elixir
# Consistent test data with overrides
def comprehensive_generator(opts \\ []) do
  seed_generator(%{
    required_field: sequence(:required, &"value_#{&1}"),
    optional_field: "default_value",
    numeric_field: sequence(:numeric, &(1000 + &1)),
    timestamp_field: DateTime.utc_now()
  }, overrides: opts)
end
```

### Focus-Driven Development

```bash
# Develop one test at a time
@tag :focus
test "current development target" do
  # implementation
end

# Run focused test
mix test --only focus

# Remove focus when test passes
mix test # Run all tests to verify no regressions
```

## Success Criteria

### Implementation Quality Metrics

- ✅ **100% Test Pass Rate**: All tests consistently pass
- ✅ **No Placeholder Tests**: All tests have full implementations
- ✅ **Comprehensive Coverage**: Success paths, error paths, and edge cases
  covered
- ✅ **Realistic Scenarios**: Test conditions mirror production environments
- ✅ **Maintainable Structure**: Clear organization and reusable patterns

### Technical Quality Metrics

- ✅ **External Mocking Only**: No internal business logic mocked
- ✅ **Generator-Based Data**: Consistent test data creation
- ✅ **State Transition Verification**: All state changes properly tested
- ✅ **Error Handling Coverage**: All failure modes have corresponding tests
- ✅ **Integration Testing**: End-to-end workflows verified

### Process Quality Metrics

- ✅ **Incremental Development**: Tests built one at a time
- ✅ **Focus-Driven Approach**: @tag :focus used for development
- ✅ **Systematic Coverage**: Methodical approach to test creation
- ✅ **Quality Verification**: Regular checks for test quality
- ✅ **Documentation**: Clear test organization and descriptions

## Example Implementation Workflow

```bash
# 1. Plan test coverage
# Map workflows, identify scenarios, design test structure

# 2. Setup test file
touch test/steward/feature/workflow_test.exs

# 3. Start with core success path
@tag :focus
test "main success workflow" do
  # implement
end

# 4. Develop incrementally
mix test --only focus
# Build implementation until test passes

# 5. Add next test
# Remove focus from previous test
@tag :focus
test "next scenario" do
  # implement
end

# 6. Continue systematic development
# Repeat until comprehensive coverage achieved

# 7. Final verification
mix test test/steward/feature/workflow_test.exs
# Should achieve 100% pass rate

# 8. Quality check
rg "tag.*focus" test/  # Should find no remaining focus tags
rg "@tag.*skip" test/  # Should find no skipped tests
```

This methodology transforms test development from an ad-hoc process into a
systematic approach that consistently delivers comprehensive, maintainable test
coverage for complex systems.
