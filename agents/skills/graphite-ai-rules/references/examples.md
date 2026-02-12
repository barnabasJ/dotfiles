# Graphite AI Review Rule Examples

Complete, copy-ready examples organized by category.

## Security Rules

### Never Expose Detailed Error Messages

**Rule:** Never expose detailed error messages that reveal stack traces or
internal system details. Return generic error messages in production while
logging details internally for debugging.

**Bad example:**

```js
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.stack });
});
```

**Good example:**

```js
app.use((err, req, res, next) => {
  logger.error(err);
  res.status(500).json({ error: "Internal Server Error" });
});
```

**Reasoning:** Revealing stack traces leaks implementation details that
attackers can exploit to find vulnerabilities.

---

### Validate All External Input

**Rule:** Always validate and sanitize data from external sources (user input,
API responses, webhook payloads) before using it in queries, file operations, or
template rendering.

**Bad example:**

```python
@app.route("/search")
def search():
    query = request.args.get("q")
    results = db.execute(f"SELECT * FROM items WHERE name = '{query}'")
    return jsonify(results)
```

**Good example:**

```python
@app.route("/search")
def search():
    query = request.args.get("q", "")
    results = db.execute("SELECT * FROM items WHERE name = :q", {"q": query})
    return jsonify(results)
```

**Reasoning:** Unvalidated input enables SQL injection, XSS, and path traversal
attacks.

---

### Never Commit Secrets

**Rule:** Never hardcode API keys, tokens, passwords, or connection strings in
source code. Use environment variables or a secrets manager.

**Bad example:**

```python
STRIPE_KEY = "sk_live_abc123def456"
client = stripe.Client(api_key=STRIPE_KEY)
```

**Good example:**

```python
import os
client = stripe.Client(api_key=os.environ["STRIPE_KEY"])
```

**Reasoning:** Hardcoded secrets in source code are exposed to anyone with
repository access and persist in git history even after deletion.

## Database Rules

### Use `text` Instead of `varchar(n)` in PostgreSQL

**Rule:** When adding new string columns to PostgreSQL, use `text` type instead
of `varchar(n)` unless there is a specific business requirement for a length
constraint.

**Bad example:**

```ts
@Column({ type: 'varchar', length: 255 })
description: string;
```

**Good example:**

```ts
@Column({ type: 'text' })
description: string;
```

**Reasoning:** PostgreSQL handles `text` and `varchar` identically for
performance, but `text` avoids arbitrary length limits that cause issues as data
grows.

---

### Never Drop Required Fields Directly

**Rule:** Never drop a required column in a single migration. First make the
column nullable and stop writing to it, then drop it in a subsequent release
once no code references it.

**Bad example:**

```sql
ALTER TABLE users DROP COLUMN email;
```

**Good example:**

```sql
-- Migration 1: Make nullable, stop writing
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;

-- Migration 2 (next release): Drop column
ALTER TABLE users DROP COLUMN email;
```

**Reasoning:** Dropping a required column in one step causes errors for any
running code that still references it during deployment.

## Naming & Style Rules

### Use Descriptive Boolean Variable Names

**Rule:** Boolean variables and function names must read as true/false
assertions. Prefix with `is`, `has`, `can`, `should`, or `was`.

**Bad example:**

```ts
const admin = user.role === "admin";
const visible = element.style.display !== "none";
```

**Good example:**

```ts
const isAdmin = user.role === "admin";
const isVisible = element.style.display !== "none";
```

**Reasoning:** Ambiguous boolean names cause confusion — `admin` could be a user
object, a string, or a boolean. Prefixed names make the type and intent
immediately clear.

## Framework-Specific Rules

### React: Avoid Inline Object/Array Literals in JSX Props

**Rule:** Never pass inline object or array literals as props to React
components. Extract them to constants or useMemo to prevent unnecessary
re-renders.

**Bad example:**

```tsx
function App() {
  return <Chart options={{ animate: true, legend: false }} data={[1, 2, 3]} />;
}
```

**Good example:**

```tsx
const CHART_OPTIONS = { animate: true, legend: false };
const DEFAULT_DATA = [1, 2, 3];

function App() {
  return <Chart options={CHART_OPTIONS} data={DEFAULT_DATA} />;
}
```

**Reasoning:** Inline literals create new object references on every render,
causing child components to re-render unnecessarily even when values haven't
changed.

---

### Elixir/Ash: Always Define Return Types on Actions

**Rule:** Every Ash resource action must specify explicit return types in its
code interface definition. Do not rely on implicit return types.

**Bad example:**

```elixir
define :get_user, args: [:id]
```

**Good example:**

```elixir
define :get_user, args: [:id], result: :single
```

**Reasoning:** Explicit return types make the API contract clear to callers and
enable better compile-time checks.

## Exclusion Examples

### Good Exclusions (Targeted)

```
Do not comment on missing `return` keywords in Kotlin single-expression
functions. This is valid Kotlin syntax.
```

```
Do not flag unused variables in test files matching `*_test.go`. Test helpers
often define variables for future assertions.
```

```
Do not suggest replacing `any` types in files under `src/generated/`. These
are auto-generated from GraphQL schemas.
```

### Bad Exclusions (Too Broad)

```
Don't suggest performance improvements.
```

Why bad: Misses real performance bugs. Narrow to: "Do not suggest performance
optimizations for scripts in `/scripts` — these are one-time utility scripts."

```
Don't comment on naming.
```

Why bad: Naming matters. Narrow to: "Do not enforce camelCase naming in
`/legacy` directory. This codebase predates our style guide."

## Template: Blank Rule

Copy and fill in:

````markdown
### Rule: [One-line prescriptive statement]

**Rule:** [1-2 sentences with specific guidance and scope]

**Bad example:**

````lang
[Code showing the violation]
`` `

**Good example:**
```lang
[Code showing the correct approach]
`` `

**Reasoning:**
[Why this matters — 1-2 sentences]
````
````
