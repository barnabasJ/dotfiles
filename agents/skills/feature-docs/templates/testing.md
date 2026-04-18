# Testing Doc Template

**Output path**: `docs/testing/<feature>.md`

**Informed by**: IEEE 829 (adapted for modern practice), testing trophy/pyramid
models, risk-based testing, BDD specification patterns, shift-left testing
philosophy, FMEA risk scoring.

## Template

````markdown
# <Feature Name> — Test Strategy

**Status**: Draft **Created**: YYYY-MM-DD **Last Updated**: YYYY-MM-DD

## Overview

<Brief description of what this test strategy covers. 1-2 sentences.>

**Related Documents**:

- [PRD](../design/<feature>-prd.md)
- [Implementation Plan](../plans/<feature>-plan.md)

## Testing Model

<!-- Explicitly state which model you follow and why — don't assume
     "testing pyramid" is universal. Define what each layer means
     in THIS project's context. -->

| Layer       | Definition (in this project)         | Scope                            | Status  |
| ----------- | ------------------------------------ | -------------------------------- | ------- |
| Unit        | <What counts as a unit test here>    | Individual modules and functions | Planned |
| Integration | <What counts as an integration test> | Cross-module interactions        | Planned |
| E2E         | <What counts as an E2E test>         | User journey scenarios           | Planned |

**Model rationale**: <Why this allocation — e.g., "Integration-heavy because
this is a data pipeline with few UI interactions">

## Risk-Based Coverage

<!-- Prioritize testing effort by risk. Not all code deserves the same rigor.
     High-risk areas get all three layers. Low-risk areas get baseline only. -->

| Component / Area | Likelihood of Defect | Business Impact | Test Layers              | Notes                |
| ---------------- | -------------------- | --------------- | ------------------------ | -------------------- |
| <Component>      | High                 | High            | Unit + Integration + E2E | <Why high risk>      |
| <Component>      | Low                  | Medium          | Unit only                | <Why lower priority> |

## Acceptance Criteria Mapping

<!-- Every PRD acceptance criterion should map to at least one test.
     This is the traceability matrix. -->

| PRD Acceptance Criterion | Test Type   | Test Location | Status  |
| ------------------------ | ----------- | ------------- | ------- |
| <AC from PRD>            | Unit        | `test/<path>` | Planned |
| <AC from PRD>            | Integration | `test/<path>` | Planned |

## Unit Tests

### <Module/Resource Name>

**File**: `test/<path>/<module>_test.<ext>`

#### Test Cases

- [ ] **<test name>**: <What it verifies>
- [ ] **<test name>**: <What it verifies>

**Example**:

```
describe "<function_name>" do
  test "<what it tests>" do
    # Given: <precondition>
    # When: <action>
    # Then: <observable result>
  end
end
```

### <Module/Resource Name>

...

## Integration Tests

### <Interaction Being Tested>

**File**: `test/<path>/<integration>_test.<ext>`

**What it covers**: <Which modules interact and what behavior is verified>

#### Test Cases

- [ ] **<test name>**: <What it verifies>
- [ ] **<test name>**: <What it verifies>

**Setup Requirements**:

- <Database fixtures, configs, or preconditions>

**Mocking boundaries**: <What is mocked (external services only) and what is NOT
mocked (internal modules, database)>

## Edge Cases and Error Scenarios

<!-- Explicitly enumerate. These are where bugs hide.
     Include boundary conditions, invalid inputs, and concurrency. -->

### <Edge Case>

- **Input**: <What triggers it>
- **Expected behavior**: <What should happen>
- **Test**: <Which test covers it>
- **Risk**: <Why this edge case matters>

## What We're NOT Testing (and why)

<!-- Explicit deprioritization is more valuable than listing what you do test.
     If a layer is intentionally skipped, explain why. -->

- <Area/scenario>: <Why it's deprioritized — e.g., "Low risk, stable code, no
  recent changes">

## Quality Gates

<!-- Concrete thresholds at each stage. -->

| Gate        | Criteria                  | Threshold                   |
| ----------- | ------------------------- | --------------------------- |
| Pre-merge   | Tests pass, diff coverage | >= 80% on changed lines     |
| Pre-deploy  | Integration suite green   | Zero critical/high failures |
| Post-deploy | Error rate, latency       | Below baseline + margin     |

## Exploratory Testing

<!-- For high-risk features, scripted tests aren't enough.
     Define exploration charters with timeboxes. -->

### Charter: <Area to explore>

> **Explore** <target area> **with** <techniques/data> **to discover** <what
> you're looking for>.

**Timebox**: <Duration, typically 60-90 minutes>

## Manual Verification Checklist

For scenarios that are difficult to automate:

- [ ] <Manual check — what to verify and how>
- [ ] <Manual check>

## Test Data and Fixtures

| Fixture   | Purpose         | Created By       | Cleanup               |
| --------- | --------------- | ---------------- | --------------------- |
| <fixture> | <What it's for> | <Setup function> | <How it's cleaned up> |

## Running Tests

```bash
# Run all tests for this feature
<test command for feature path>

# Run specific test file
<test command for specific file>

# Run with coverage
<coverage command>
```

---

**Last Updated**: YYYY-MM-DD
````

## Guidelines

### Strategy vs. Plan

This document is a **test strategy** — it defines what to test, why, and at what
priority level. It is NOT a test execution log or a list of every test case.
Keep it decision-focused and short (3-5 pages). Link to living artifacts (test
suites, CI dashboards) instead of duplicating.

### Risk-Based Prioritization

- **Not all code deserves the same rigor**: Use the risk table to allocate
  effort. High-risk areas get all test layers. Low-risk areas get baseline
  coverage only.
- **Document what you're NOT testing**: Explicit deprioritization is more
  valuable than listing what you test. It shows you thought about coverage
  allocation.

### Testing Model

- **Define your terms**: "Unit test" and "integration test" are notoriously
  ambiguous. State what each layer means in this project's context.
- **State the model and rationale**: Don't assume testing pyramid is universal.
  Integration-heavy architectures may need a testing trophy or diamond shape.
- **Mock at boundaries, not between internal modules**: Over-mocking creates
  tests that verify mocks, not systems.

### Test Case Quality

- **Given/When/Then structure**: Even informal test descriptions benefit from
  this pattern. It forces clarity on preconditions, actions, and assertions.
- **One behavior per test**: Multiple assertions testing different behaviors
  signal a test that should be split.
- **Test behavior, not implementation**: Tests coupled to internal structure
  break on refactoring without catching bugs.

### Traceability

- **Every PRD acceptance criterion maps to a test**: Use the acceptance criteria
  mapping table to ensure nothing is missed.
- **Edge cases are enumerated**: These are where bugs hide. Include boundary
  conditions, invalid inputs, error paths, and concurrency scenarios.

### Quality Gates

- **Concrete thresholds**: Not "adequate coverage" but ">= 80% diff coverage on
  changed lines."
- **Measure diff coverage, not total**: This focuses effort where change risk
  lives and avoids gaming.
- **Post-deploy gates**: Define canary metrics and rollback criteria.

### Anti-Patterns

- **Uniform coverage everywhere**: Wastes effort on low-risk code. Use
  risk-based allocation.
- **Over-mocking**: Mock external services and system boundaries. Not internal
  module interactions.
- **Flaky test tolerance**: Flaky tests that are retried instead of fixed erode
  trust. Quarantine and fix with a deadline.
- **Snapshot test overuse**: Large snapshot tests get blindly updated, providing
  no real regression protection.
- **Testing without assertions**: Tests that execute code but don't assert
  outcomes appear as coverage without verifying anything.
