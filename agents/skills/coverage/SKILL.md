---
name: coverage
description: Code coverage analysis
---

# Code Coverage Analysis

Comprehensive guidance for analyzing code coverage and identifying untested code
paths.

## Running Coverage Tests

### Elixir/Mix Projects

```bash
# Run tests with coverage
mix test --cover

# Run tests for specific files with coverage
mix test test/path/to/test.exs --cover

# Filter coverage results for specific modules
mix test --cover 2>&1 | grep -E "YourModule"
```

### Other Languages

- **Python**: `pytest --cov=module_name`
- **JavaScript**: `npm test -- --coverage`
- **Ruby**: Use `simplecov` gem

## Analyzing Coverage Results

### Step 1: Get Coverage Summary

After running tests with `--cover`, look for the coverage table in output:

```bash
mix test --cover 2>&1 | grep -E "Ash.Actions.(Create|Update|Destroy).Bulk"
```

### Step 2: Extract Uncovered Lines from HTML Reports

Mix coverage generates HTML reports in the `cover/` directory. Use this script
to extract uncovered lines:

```python
# Save as: analyze_coverage.py
import re
import sys
from pathlib import Path

def extract_uncovered_lines(html_path):
    """Extract line numbers marked as 'miss' (uncovered) from HTML coverage report."""
    content = Path(html_path).read_text()

    # Find lines with class="miss" - these are uncovered
    # Pattern: <tr class="miss">...<td class="line" id="L123">...
    matches = re.findall(r'<tr class="miss">\s*<td class="line" id="L(\d+)"', content)
    return sorted([int(m) for m in matches])

def group_consecutive(nums):
    """Group consecutive line numbers into ranges."""
    if not nums:
        return []
    ranges = []
    start = nums[0]
    end = nums[0]
    for n in nums[1:]:
        if n == end + 1:
            end = n
        else:
            ranges.append((start, end))
            start = n
            end = n
    ranges.append((start, end))
    return ranges

def analyze_coverage(html_path, source_path=None):
    """Analyze coverage for a module and optionally show source context."""
    print(f"\n{'='*70}")
    print(f"Coverage Analysis: {html_path}")
    print(f"{'='*70}")

    uncovered = extract_uncovered_lines(html_path)
    total_uncovered = len(uncovered)

    if not uncovered:
        print("All lines covered!")
        return

    print(f"\nTotal uncovered lines: {total_uncovered}")
    print(f"\nUncovered line ranges:")

    for start, end in group_consecutive(uncovered):
        if start == end:
            print(f"  Line {start}")
        else:
            print(f"  Lines {start}-{end}")

    # Show source context if provided
    if source_path and Path(source_path).exists():
        print(f"\n{'='*70}")
        print("Uncovered Code Context:")
        print(f"{'='*70}")

        lines = Path(source_path).read_lines()
        uncovered_set = set(uncovered)

        for start, end in group_consecutive(uncovered)[:20]:  # First 20 ranges
            print(f"\n### Lines {start}-{end}:")
            # Show context (2 lines before and after)
            ctx_start = max(0, start - 3)
            ctx_end = min(len(lines), end + 2)

            for i in range(ctx_start, ctx_end):
                marker = ">>>" if (i+1) in uncovered_set else "   "
                print(f"  {marker} {i+1:4}: {lines[i].rstrip()[:70]}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python analyze_coverage.py <html_coverage_file> [source_file]")
        sys.exit(1)

    html_path = sys.argv[1]
    source_path = sys.argv[2] if len(sys.argv) > 2 else None
    analyze_coverage(html_path, source_path)
```

### Step 3: Quick Coverage Check (Inline)

For quick analysis without saving a script file, use this bash one-liner:

```bash
# Extract uncovered line numbers from HTML coverage file
grep 'class="miss"' -A1 cover/Elixir.YourModule.html | \
  grep -oE 'id="L[0-9]+"' | \
  sed 's/id="L//' | sed 's/"$//'
```

### Step 4: Show Uncovered Code with Context

```bash
# Get uncovered lines and show them with context from source
UNCOVERED=$(grep 'class="miss"' -A1 cover/Elixir.YourModule.html | \
  grep -oE 'id="L[0-9]+"' | sed 's/id="L//' | sed 's/"$//' | tr '\n' ',')

echo "Uncovered lines: $UNCOVERED"

# For each uncovered line, show context
for line in $(echo $UNCOVERED | tr ',' ' '); do
  echo "=== Line $line ==="
  sed -n "$((line-2)),$((line+2))p" lib/your/module.ex | cat -n
done
```

## Common Uncovered Code Patterns

### 1. Error/Validation Paths

```elixir
# Often uncovered - invalid argument handling
if !valid?(input) do
  raise ArgumentError, "Invalid input"
end
```

**Fix**: Add tests for invalid inputs

### 2. Transaction Boundaries

```elixir
# Notification handling in transactions
if notify? do
  notifications = Process.get(:ash_notifications, [])
  Ash.Notifier.notify(notifications)
end
```

**Fix**: Test with `notify?: true` and `transaction: :all`

### 3. Parallel Processing

```elixir
# Concurrent batch processing often untested
if max_concurrency > 1 do
  Task.async_stream(...)
end
```

**Fix**: Test with `max_concurrency: 2` or higher

### 4. Fallback Paths

```elixir
# Manual action fallbacks
if function_exported?(mod, :bulk_create, 3) do
  mod.bulk_create(...)
else
  # This branch often uncovered
  mod.create(...)
end
```

**Fix**: Create test resource with non-bulk manual action

### 5. after_transaction Hooks

```elixir
# Error-to-success conversion
case Ash.Changeset.run_after_transactions({:error, error}, changeset) do
  {:ok, result} ->
    # Hook converted error to success - often uncovered
    ...
end
```

**Fix**: Test with after_transaction hook that recovers from errors

## Interpreting Coverage Metrics

| Coverage % | Status     | Action Needed                            |
| ---------- | ---------- | ---------------------------------------- |
| 90-100%    | Excellent  | Maintain current coverage                |
| 80-89%     | Good       | Add tests for critical uncovered paths   |
| 70-79%     | Acceptable | Prioritize error handling and edge cases |
| < 70%      | Needs Work | Systematic test addition required        |

## Quick Reference Commands

```bash
# Run coverage and save report
mix test --cover

# Count uncovered lines in a module
grep -c 'class="miss"' cover/Elixir.Module.Name.html

# List all modules by coverage (lowest first)
mix test --cover 2>&1 | grep -E "^\|" | sort -t'|' -k2 -n | head -20

# Open HTML coverage report in browser
open cover/Elixir.Module.Name.html  # macOS
xdg-open cover/Elixir.Module.Name.html  # Linux
```

## Full Analysis Script

For comprehensive analysis across multiple files:

```python
#!/usr/bin/env python3
"""
Comprehensive code coverage analyzer.
Usage: python coverage_analyzer.py [module_pattern]
Example: python coverage_analyzer.py "Bulk"
"""

import re
import sys
from pathlib import Path

def extract_uncovered_lines(html_path):
    content = Path(html_path).read_text()
    matches = re.findall(r'<tr class="miss">\s*<td class="line" id="L(\d+)"', content)
    return sorted([int(m) for m in matches])

def group_consecutive(nums):
    if not nums:
        return []
    ranges = []
    start = end = nums[0]
    for n in nums[1:]:
        if n == end + 1:
            end = n
        else:
            ranges.append((start, end))
            start = end = n
    ranges.append((start, end))
    return ranges

def get_source_path(html_name):
    """Convert HTML coverage filename to source path."""
    # Elixir.Ash.Actions.Create.Bulk.html -> lib/ash/actions/create/bulk.ex
    module = html_name.replace('.html', '').replace('Elixir.', '')
    path = module.lower().replace('.', '/') + '.ex'
    return f"lib/{path}"

def analyze_all(pattern=None):
    cover_dir = Path('cover')
    if not cover_dir.exists():
        print("No cover/ directory found. Run `mix test --cover` first.")
        return

    html_files = sorted(cover_dir.glob('Elixir.*.html'))

    if pattern:
        html_files = [f for f in html_files if pattern in f.name]

    results = []
    for html_file in html_files:
        uncovered = extract_uncovered_lines(html_file)
        if uncovered:
            results.append((html_file.name, len(uncovered), uncovered))

    # Sort by number of uncovered lines (descending)
    results.sort(key=lambda x: x[1], reverse=True)

    print(f"\n{'='*70}")
    print("UNCOVERED CODE SUMMARY")
    print(f"{'='*70}\n")

    for name, count, lines in results[:20]:
        source = get_source_path(name)
        print(f"\n## {name.replace('.html', '')} ({count} uncovered lines)")
        print(f"   Source: {source}")

        ranges = group_consecutive(lines)
        for start, end in ranges[:10]:
            if start == end:
                print(f"   - Line {start}")
            else:
                print(f"   - Lines {start}-{end}")

        if len(ranges) > 10:
            print(f"   ... and {len(ranges) - 10} more ranges")

    print(f"\n{'='*70}")
    print(f"Total files with uncovered code: {len(results)}")
    print(f"Total uncovered lines: {sum(r[1] for r in results)}")

if __name__ == "__main__":
    pattern = sys.argv[1] if len(sys.argv) > 1 else None
    analyze_all(pattern)
```

## Skill Activation

This skill is automatically activated when:

- User asks about code coverage
- User runs `mix test --cover`
- User asks about uncovered lines or test gaps
- Coverage-related files are being analyzed (e.g., `cover/*.html`)
