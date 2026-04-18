# Changelog Template

**Output path**: `docs/changelog/<feature>.md` or `CHANGELOG.md` (project root)

**Informed by**: keepachangelog.com standard, Semantic Versioning, Appcues
changelog vs release notes distinction, LaunchNotes best practices.

A changelog is a structured record of notable changes for each release. It
serves two audiences: developers (what changed technically) and users (what's
new for them).

## Template

```markdown
# <Feature Name> Changelog

All notable changes to this feature are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- <New feature or capability>

### Changed

- <Change to existing functionality>

### Deprecated

- <Feature that will be removed in a future release>

### Removed

- <Feature that was removed>

### Fixed

- <Bug fix>

### Security

- <Vulnerability fix or security improvement>

## [X.Y.Z] — YYYY-MM-DD

### Added

- <Description of new feature> ([#PR](link))

### Changed

- <Description of change> ([#PR](link))

### Fixed

- <Description of fix> ([#PR](link))

---

[Unreleased]: <compare link to HEAD>
[X.Y.Z]: <compare link to previous version>
```

## Categories

Use exactly these categories (from keepachangelog.com):

| Category       | What goes here                                    |
| -------------- | ------------------------------------------------- |
| **Added**      | New features, capabilities, endpoints             |
| **Changed**    | Changes to existing functionality (not bug fixes) |
| **Deprecated** | Features marked for future removal                |
| **Removed**    | Features that were removed                        |
| **Fixed**      | Bug fixes                                         |
| **Security**   | Vulnerability fixes, security improvements        |

Only include categories that have entries. Don't show empty categories.

## Guidelines

### Format

- **Newest first**: Most recent release at the top.
- **[Unreleased] section**: Always present. Accumulates changes as they land.
  Becomes the next release's entry when you ship.
- **Date format**: ISO 8601 (YYYY-MM-DD). Unambiguous across locales.
- **Link PRs/commits**: Every entry should link to the PR or commit that
  introduced the change. This enables traceability.
- **One entry per change**: Don't bundle multiple changes into one entry.

### Content

- **Human-readable**: Write for humans, not machines. Not "Refactored
  AuthService to use Strategy pattern" but "Login now supports multiple
  authentication providers (SAML, OIDC, magic link)."
- **User impact first**: Lead with what changed for the user, not what changed
  in the code. "Search results now load 3x faster" not "Added Redis caching
  layer to SearchService."
- **Migration notes inline**: If a change requires user action, note it directly
  in the entry: "**Migration required**: Run `mix ecto.migrate` after updating."
- **Don't include**: Internal refactors with no user-visible impact, dependency
  bumps (unless they fix something user-facing), formatting/style changes.

### Changelog vs Release Notes

|              | Changelog                   | Release Notes               |
| ------------ | --------------------------- | --------------------------- |
| **Audience** | Developers, technical users | End users, stakeholders     |
| **Tone**     | Technical, precise          | Friendly, benefit-focused   |
| **Scope**    | Every notable change        | Highlights and key features |
| **Format**   | Structured categories       | Narrative with visuals      |

A changelog is the source of truth. Release notes are curated highlights from
the changelog, written for a non-technical audience.

### Anti-Patterns

- **Git log as changelog**: `git log --oneline` is not a changelog. It's noisy,
  unstructured, and includes irrelevant commits.
- **Empty unreleased section**: If there's no [Unreleased] section, changes
  accumulate undocumented until release day, leading to rushed, incomplete
  entries.
- **Bundling changes**: "Various improvements and bug fixes" tells the reader
  nothing. One entry per change.
- **Internal-only language**: "Refactored X" means nothing to users. Translate
  to impact.
