# Jira · Feature definition description template

Paste this into the description of the Story (or the issue type set in `espec/config.yaml`) when
you start a feature by hand. The espec Feature Definition agent produces the same structure. Keep the
first line: it is how engineering's tools recognise a feature definition.

Tip: Jira admins can save this as a description template for the issue type so every new Story
starts from it.

```markdown
<!-- espec:feature-definition v1 -->
# Feature: <title>

**Ticket:** <this issue> · **Product owner:** <name> · **Design:** <name or none> · **Status:** Draft

## Why

## What

## Users and personas

## Use cases
### UC-1: <name>
- **Actor:**
- **Trigger:**
- **Preconditions:**
- **Main flow:**
  1.
- **Outcome:**

## Edge cases
### EC-1: <name>
- **Situation:**
- **Expected behaviour:**

## Out of scope
-

## Acceptance criteria
### AC-1: <name> (covers UC-1)
- **GIVEN**
- **WHEN**
- **THEN**

## Experience and design

## Constraints

## Success metrics
-

## Open questions
- None
```

## Workflow in Jira

| Status | Meaning | Who moves it |
|--------|---------|--------------|
| Draft | Definition in progress | Product |
| Ready for tech proposal | Readiness check passed; engineering can investigate | Product |
| In technical assessment | A developer is assessing the ticket against the code (`/espec:assess`) | Engineering |
| Further discovery required | The assessment comment lists decisions, confirmations or spikes, each with an owner. Product answers and updates the description; engineering re-assesses | Engineering |
| Assessed, ready for tech proposal | The assessment outcome is Ready and the description holds the agreed scope | Engineering |
| Tech proposal in review | Engineering posted the tech proposal pull request and any Questions for Product as a comment | Engineering |
| In progress | Implementation started | Engineering |
| Done | Archived; release note posted as a comment | Engineering |

The feature definition and `espec/changes/<change-name>/feature.md` in the repository stay identical.
When product edits the ticket after engineering imported it, say so in a comment so the change can be
re-imported.
