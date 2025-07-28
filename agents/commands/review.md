You are conducting a pull request review comparing the current branch against
main. You should take into account the current planning document and compare the
implementation with the planning document to see if the plan was correctly
implemented or if the implementation differs from the planning doc. Please
perform a thorough code review examining the following areas and ultrathink
about it. Create parallel sub-agents and analyse the changes from the following
perspectives: factual, qa engineer, senior engineer, security expert,
consistency reviewer, redundancy checker:

## Code Quality & Standards

- Does the code follow established patterns and conventions already present in
  the codebase?
- Are naming conventions consistent (variables, functions, classes, files)?
- Is the code properly formatted and easy to read?
- Are there any code smells or anti-patterns?
- Does the code avoid unnecessary complexity?

## Testing

- Are all new features and bug fixes covered by tests?
- Do the tests actually test the intended functionality (not just coverage)?
- Are edge cases and error scenarios tested?
- Do all existing tests still pass?
- Is the test coverage adequate for the changes made?

## Functionality & Logic

- Does the code do what the planning document claims?
- How does the implementation compare to what was planned?
- Are there deviations from the planning document, and if so, are they
  justified?
- Are there any obvious bugs or logic errors?
- Are error cases handled appropriately?
- Is input validation sufficient?
- Are there any potential performance issues?

## Security & Best Practices

- Are there any security vulnerabilities (SQL injection, XSS, exposed secrets,
  etc.)?
- Is sensitive data handled appropriately?
- Are dependencies up to date and free from known vulnerabilities?
- Does the code follow the principle of least privilege?

## Architecture & Design

- Does the change fit well with the existing architecture?
- Is the code properly modularized and reusable?
- Are concerns properly separated?
- Are there any unnecessary dependencies introduced?
- Would this change make future modifications harder?

## Documentation & Maintainability

- Are complex logic sections commented appropriately?
- Is the code self-documenting where possible?
- Are API changes documented?
- Would another developer understand this code in 6 months?
- Are there any TODOs that should be addressed?

## Additional Checks

- Are there any console.logs or debug statements that should be removed?
- Are all files necessary (no accidentally committed files)?
- Does the PR size make sense (not too large to review effectively)?
- Are database migrations handled correctly (if applicable)?
- Are configuration changes documented?

Please provide specific feedback with file names and line numbers where
applicable. Categorize findings as:

- 🚨 Blockers (must fix before merge)
- ⚠️ Concerns (should address or explain)
- 💡 Suggestions (nice to have improvements)
- ✅ Good practices noticed (positive reinforcement)

Focus on actionable feedback rather than nitpicks, unless the nitpicks affect
code consistency with the rest of the codebase.
