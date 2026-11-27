# Jira · Bug report description template

Paste this into the description of a Bug (or the issue type your project uses for defects) when you
report a bug by hand. The espec Feature Definition agent produces the same structure when you describe
something broken.

The description starts at `# Bug:`. There is no marker line and no header line, for the same reason
as a feature definition: Jira drops HTML comments and already holds the key, the reporter and the
status in fields. Engineering's tools recognise a bug report by that first line, so keep it and the
`##` headings as they are. The import adds the marker and builds the header line in `feature.md`.

Tip: Jira admins can save this as a description template for the Bug issue type.

```markdown
# Bug: <title>

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
[feature definition template](jira-feature-definition.md).

## Workflow in Jira

| Status | Meaning | Who moves it |
|--------|---------|--------------|
| Draft | Report in progress | The reporter |
| Ready for tech proposal | The bug readiness check passed; engineering can pick it up | The reporter, or whoever triages |
| Tech proposal in review | Engineering posted the tech proposal pull request, with the root cause, and any Questions for Product as a comment | Engineering |
| In progress | Implementation started; the first task reproduces the bug in a failing test | Engineering |
| Done | Archived; release note posted as a comment | Engineering |

A bug skips the technical assessment and its three statuses. The report and
`espec/changes/<change-name>/feature.md` in the repository stay identical from `# Bug:` down. When
someone edits the ticket after engineering imported it, say so in a comment so the change can be
re-imported.
