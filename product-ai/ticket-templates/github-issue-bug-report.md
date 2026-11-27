# GitHub Issues · Bug report template

Repositories initialised with espec carry `.github/ISSUE_TEMPLATE/bug-report.md`, so
"New issue → Bug report" gives you this structure with the `bug` label. Paste the output of the
espec Feature Definition agent over it, keeping the first line.

```markdown
<!-- espec:feature-definition v1 -->
# Bug: <title>

**Ticket:** this issue · **Reported by:** <name> · **Status:** Draft

## Why

## What

## Steps to reproduce
1.

## Out of scope
-

## Acceptance criteria
### AC-1: <the bug no longer happens>
- **GIVEN**
- **WHEN**
- **THEN**

## Open questions
- None
```

What goes where:

- **Why**: who is affected, how often, and what it costs them.
- **What**: what you expected and what happened instead, as the user sees it. No cause and no fix: a
  suspected cause is a how, and engineering finds the root cause in the tech proposal.
- **Steps to reproduce**: numbered, from a known state: where (environment, version, device), who
  (role, account), which data. When it does not happen every time, say how often.
- **Acceptance criteria**: what must be true once it is fixed. No use cases and no edge cases.

A report that asks for behaviour the product never had is a feature, not a bug: use the
[feature definition template](github-issue-feature-definition.md).

## Workflow in GitHub

- Whoever found the bug opens the issue from the template and sets the status line to **Ready for
  tech proposal** when the bug readiness check passes.
- Engineering runs `/espec-tech-proposal <issue URL>` in GitHub Copilot, which imports the issue body
  as `feature.md` with `kind: bug` and opens a pull request with the tech proposal: the root cause,
  the fix, and a first task that reproduces the bug in a failing test. A bug skips the technical
  assessment. Questions for Product go back as an issue comment.
- On archive, engineering posts the release note as a comment and closes the issue.
