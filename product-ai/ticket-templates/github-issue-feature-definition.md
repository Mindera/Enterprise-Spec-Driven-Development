# GitHub Issues · Feature definition template

Repositories initialised with espec carry `.github/ISSUE_TEMPLATE/feature-definition.md`, so
"New issue → Feature definition" gives you this structure with the `feature-definition` label.
Paste the output of the espec Feature Definition agent over it, keeping the first line.

```markdown
<!-- espec:feature-definition v1 -->
# Feature: <title>

**Ticket:** this issue · **Product owner:** <name> · **Design:** <name or none> · **Status:** Draft

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

## Workflow in GitHub

- Product opens the issue from the template and sets the status line to **Ready for tech proposal**
  when the readiness check passes.
- Engineering runs `/espec-assess <issue URL>` and posts the technical assessment as an issue
  comment. When its outcome is **Further discovery required**, product decides on what it raises and
  updates the issue body, and engineering re-assesses. Labels such as `further-discovery` make the
  state visible on the board.
- When the outcome is **Ready for tech proposal**, engineering runs `/espec-tech-proposal <issue URL>` in GitHub Copilot, which imports the issue body
  as `feature.md` and opens a pull request with the tech proposal. Questions for Product go back as
  an issue comment.
- When the repository uses the Copilot coding agent, assigning the issue to Copilot produces the tech
  proposal pull request first, not an implementation, because `.github/copilot-instructions.md` says so.
- On archive, engineering posts the release note as a comment and closes the issue.
