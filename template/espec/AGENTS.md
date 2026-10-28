# espec conventions

This folder holds the product and technical specifications of this repository, in plain Markdown.
Read this file before creating, editing, archiving or cleaning anything under `espec/`.

## The idea

Product defines **what** and **why**. Engineering defines **how**. Code follows the specs.
Finished changes are folded into a living set of specs that describes the system as it is today.

Different roles use different AI tools, so the hand-off between them is a **ticket** (Jira or GitHub Issue)
written in a fixed format that any AI assistant can read and any human can review.

## Phases and commands

| # | Phase | Command | Who | Tool | Produces |
|---|-------|---------|-----|------|----------|
| 1 | AI Assisted Feature Definition | `/espec:feature-definition` | Product Managers, Designers | Rovo, M365 Copilot (or GitHub Copilot in-repo) | A ticket holding `feature.md` |
| 2 | Tech Proposal | `/espec:tech-proposal` | Developers, QA | GitHub Copilot | `tech-proposal.md`, `specs/`, `tasks.md` |
| 3 | Implementation | `/espec:implementation` | Developers, QA | GitHub Copilot | Code and tests, tasks checked off, `pull-request.md` |
| 4 | Archive | `/espec:archive`, `/espec:archive-clean` | Developers | GitHub Copilot | Main specs updated, change archived |

Two read-only review commands sit between the phases. They write nothing: they print a report and a
comment for the ticket.

| Command | Checks | Who | When |
|---------|--------|-----|------|
| `/espec:inspect-feature-definition` | A ticket, a pasted definition or `feature.md` against the feature definition rules | Developers, QA, reviewers. Product runs the same checks through the review prompt in the product pack | Before a tech proposal starts |
| `/espec:inspect-tech-proposal` | `tech-proposal.md`, `specs/` and `tasks.md` against `feature.md` and the live ticket | QA, Engineering Managers, Architects | Before a tech proposal is approved |

GitHub Copilot prompt files cannot contain `:` in their name, so in Copilot Chat the commands are typed
with a dash: `/espec-feature-definition`, `/espec-tech-proposal`, `/espec-implementation`,
`/espec-archive`, `/espec-archive-clean`, `/espec-inspect-feature-definition`,
`/espec-inspect-tech-proposal`. The colon form is the canonical name used in documentation.

## Directory layout

```
espec/
├── AGENTS.md                     # This file: conventions for humans and AI
├── project.md                    # Project context: stack, conventions, ticketing, teams
├── config.yaml                   # Ticket system, rules, archive settings
├── specs/                        # The system as it is today (one folder per capability)
│   └── <capability>/
│       └── spec.md
├── changes/                      # Work in flight (one folder per change)
│   ├── <change-name>/
│   │   ├── .espec.yaml           # Ticket link, status, owners
│   │   ├── feature.md            # Phase 1: what and why (imported from the ticket)
│   │   ├── tech-proposal.md      # Phase 2: how
│   │   ├── specs/                # Phase 2: deltas against espec/specs/
│   │   │   └── <capability>/
│   │   │       └── spec.md
│   │   ├── tasks.md              # Phase 2 output, tracked in Phase 3
│   │   └── pull-request.md       # Phase 3: PR description, proposal versus implementation
│   └── archive/                  # Finished changes and clean-up logs
│       ├── YYYY-MM-DD-<change-name>/
│       └── YYYY-MM-DD-archive-clean/
│           └── cleanup.md
├── templates/                    # Blank files the commands start from
└── bin/                          # espec validate, new, list (copied by init, refreshed by update)
```

`<capability>` is a kebab-case name for a durable system behaviour (`invoice-export`, `user-auth`),
never the name of a change (`add-login-endpoint`). Nested paths are allowed (`billing/invoice-export`)
when the project already organises specs that way.

`<change-name>` is kebab-case, verb-first, and describes the change (`add-invoice-csv-export`).
When a ticket exists, the change name is the ticket key in lower case followed by a short slug
(`proj-123-invoice-csv-export`).

## The product boundary

A **feature definition** describes the problem, the people affected, the behaviour they need and the
boundaries of the work. It never prescribes the solution.

Treat the following as **how** and keep it out of a feature definition: APIs, endpoints, databases,
tables, schemas, queues, caches, cron jobs, microservices, libraries, frameworks, programming languages,
cloud services, infrastructure, architecture, design patterns, component names, CSS, file formats chosen
for internal reasons, performance mechanisms (as opposed to performance outcomes), and any sentence that
starts with "implement", "build it with", "store it in", "call the", or "use the".

Product may still state **outcomes** that constrain engineering: "the export must be available within
10 seconds", "data must stay in the EU", "must work on the mobile app". Those belong in the feature
definition under constraints.

When an author insists on a **how**, the AI:

1. Says it looks like implementation detail and explains why it belongs in the tech proposal.
2. Offers to rephrase it as an outcome.
3. Asks once: "Are you sure you want to force this into the feature definition?"
4. On a clear yes, records it under `## Forced technical notes` with an `FT-n` id, the author's reason,
   and the ⚠️ marker, and keeps every other section free of it.

The tech proposal must review every `FT-n` and mark it **Accepted** or **Overridden** with a reason.

## Feature definition format (`feature.md`)

The same text lives in the ticket description and in `changes/<change-name>/feature.md`. It begins with
an HTML comment marker so tools and prompts can recognise it:

```markdown
<!-- espec:feature-definition v1 -->
# Feature: <title>

**Ticket:** PROJ-123 · **Product owner:** <name> · **Design:** <name or none> · **Status:** Draft | Ready for tech proposal

## Why
<!-- The problem or opportunity, who has it, what happens if we do nothing. 3 to 6 sentences. -->

## What
<!-- The change in plain words, from the user's point of view. No solution. -->

## Users and personas
<!-- Who is affected, and how their day changes. -->

## Use cases
### UC-1: <name>
- **Actor:** <who>
- **Trigger:** <what starts it>
- **Preconditions:** <what must be true>
- **Main flow:**
  1. <step>
  2. <step>
- **Outcome:** <what is true at the end>
- **Alternative flows:** <optional>

## Edge cases
### EC-1: <name>
- **Situation:** <the unusual condition>
- **Expected behaviour:** <what the user sees or gets>

## Out of scope
<!-- Explicit list. "Nothing" is not an answer; state at least what nearby work is excluded. -->

## Acceptance criteria
### AC-1: <name> (covers UC-1)
- **GIVEN** <state>
- **WHEN** <action>
- **THEN** <observable result>

## Experience and design
<!-- Filled by Design: flows, screens and states (empty, loading, error, success), content and tone,
     accessibility needs, links to design files. Still what, not how. -->

## Constraints
<!-- Business, legal, compliance, brand, timing, markets, devices. Outcomes, not mechanisms. -->

## Success metrics
<!-- How we will know it worked. Numbers and time frames where possible. -->

## Open questions
<!-- Each with an owner. Empty is a valid state and must be stated as "None". -->

## Forced technical notes
<!-- Only present when product insisted on a how. Otherwise omit this section entirely. -->
> ⚠️ **Forced by product.** These notes describe *how*, which is outside the product boundary.
> Engineering reviews them in the tech proposal and may override them with a documented reason.
- **FT-1:** <the note>. _Reason given: <why product insisted>_
```

Rules:

- Use `UC-n`, `EC-n`, `AC-n`, `FT-n` ids. They are referenced by the tech proposal, specs and tasks.
- Every use case and every edge case must be covered by at least one acceptance criterion.
- Edge cases are mandatory. Think about: empty data, maximum sizes, concurrency, permissions, offline,
  partial failure, time zones, locales, currencies, duplicates, retries, undo, and what the user sees
  when something goes wrong. If none apply, write why.
- Out of scope is mandatory and explicit.
- The definition is **Ready for tech proposal** when Why, What, at least one UC, edge cases, out of scope
  and acceptance criteria are present, every UC and EC maps to an AC, and open questions are either
  answered or explicitly accepted as deferred by product.

## Tech proposal format (`tech-proposal.md`)

```markdown
# Tech Proposal: <title>

**Feature:** [feature.md](feature.md) · **Ticket:** PROJ-123 · **Author:** <name> · **Status:** Draft | In review | Approved

## Context
<!-- Current state of the code that this change touches. Observed, with file references. Not the why. -->

## Approach
<!-- The chosen solution in one or two paragraphs. -->

## Architecture
<!-- Components, responsibilities, data flow. A Mermaid diagram is welcome. -->

## APIs and contracts
<!-- Endpoints, events, messages, payloads, errors, versioning. -->

## Data model and migrations
<!-- Entities, fields, indexes, migrations, backfills, data retention. -->

## Technology decisions
### D-1: <decision>
- **Choice:** <what>
- **Why:** <reason>
- **Alternatives considered:** <what else and why not>

## Forced technical notes review
<!-- One row per FT-n in feature.md. Omit the section when there are none. -->
| Note | Verdict | Reason |
|------|---------|--------|
| FT-1 | Accepted / Overridden | <why> |

## Traceability
<!-- Every UC, EC and AC must appear. Gaps are findings, not omissions. -->
| Product id | Spec requirement / scenario | Tasks |
|------------|-----------------------------|-------|
| UC-1, AC-1 | invoice-export › Export current filter › Successful export | 2.1, 2.2, 4.1 |

## Non-functional requirements
<!-- Security, privacy, performance targets, observability, accessibility, i18n, resilience. -->

## Rollout and migration
<!-- Feature flags, backward compatibility, deployment order, rollback, data migration steps. -->

## Test strategy
<!-- For QA: how each scenario is verified, test levels, test data, environments, non-functional tests. -->

## Risks and trade-offs
- [<risk>] → <mitigation>

## Questions for Product
<!-- Anything that blocks or changes scope. Written so it can be pasted as a ticket comment. -->

## Open engineering questions
<!-- Unknowns that can safely be answered during implementation without changing specs or tasks. -->
```

Rules:

- Ground the Context section in the real code. Read before writing. Cite paths.
- Decisions list alternatives. "We always do it this way" is an alternative, not a reason.
- The traceability table is complete: every `UC-n`, `EC-n` and `AC-n` from `feature.md` appears.
  When something cannot be traced, say so in **Questions for Product**.
- Questions for Product go back to the ticket. The tech proposal is not approved while a blocking
  question is open.

## Spec format (main specs in `espec/specs/`)

```markdown
# <Capability name> Specification

## Purpose
<!-- One or two sentences: what this capability is for. -->

## Requirements

### Requirement: <name>
The system SHALL <behaviour>.

#### Scenario: <name>
- **GIVEN** <optional initial state>
- **WHEN** <condition or action>
- **THEN** <observable outcome>
- **AND** <additional outcome>
```

Rules:

- Requirements use `### Requirement:` headings and SHALL or MUST. Avoid should and may.
- Scenarios use exactly four `#` characters: `#### Scenario:`. Three hashes or bullets are not parsed.
- Every requirement has at least one scenario. Scenarios are testable.
- Requirement names are unique within a spec and under 50 characters. They are the identifiers that
  deltas and the archive step match on.
- Specs describe observable behaviour, inputs, outputs, errors and constraints. Class names, libraries,
  endpoints chosen for internal reasons and execution details belong in the tech proposal.
- Keep a requirement's description (text between the heading and its first scenario) short. One
  behaviour per requirement; put examples and edge cases in scenarios.

## Delta spec format (in `changes/<change-name>/specs/`)

A delta states only what changes in a capability. It is applied to the main spec at archive time.

```markdown
# <capability> Delta Specification

## Purpose
<!-- New capabilities only. Delete this section when the main spec already exists. -->

## ADDED Requirements
### Requirement: <name>
...full requirement with scenarios...

## MODIFIED Requirements
### Requirement: <existing name>
...the FULL updated requirement, every scenario included, not a diff...

## REMOVED Requirements
### Requirement: <existing name>
**Reason:** <why>
**Migration:** <what replaces it, if anything>

## RENAMED Requirements
- FROM: `### Requirement: <old name>`
- TO: `### Requirement: <new name>`
```

Rules:

- Use one delta file per capability: `specs/<capability>/spec.md`. Use the exact existing path for a
  capability that already has a main spec.
- MODIFIED must carry the whole requirement block. Partial content loses detail at archive time.
  If you only add new concerns to an existing capability, use ADDED instead.
- REMOVED needs a reason and a migration note.
- A change with no behaviour change (pure refactor, tooling, docs) sets `skip_specs: true` in
  `.espec.yaml` and has no `specs/` folder. Do not invent a requirement to fill the folder.

## Tasks format (`tasks.md`)

```markdown
# Tasks

## 1. <Group>
- [ ] 1.1 <task> and verify <how>
- [ ] 1.2 <task> and verify <how>

## 2. <Group>
- [ ] 2.1 <task> (covers AC-1, AC-2) and verify <test name or command>
```

Rules:

- Every tracked task is a checkbox: `- [ ] N.M description`. A box holding `x` or `X` is done.
  Any other marker is not done. A line without a checkbox is not tracked.
- Each task says how it is verified: a test, a command, an observable behaviour or a delivered artifact.
- Each group lands its own tests and documentation. Never collect all testing into a final group.
- Tasks reference the product ids they satisfy (`AC-n`, `EC-n`) so QA can trace them.
- A final `## QA verification` group lists the scenario checks QA performs, one per acceptance
  criterion, plus exploratory and non-functional checks from the test strategy.
- Order by dependency. Keep tasks small enough to finish in one session.

## Pull request description format (`pull-request.md`)

Written at the end of implementation. A reviewer or a product manager must be able to understand the
change from this file alone, without opening the code, and must see exactly where the implementation
differs from the tech proposal.

```markdown
# <PR title: verb-first, ending with the ticket key in parentheses>

**Change:** `espec/changes/<change-name>/` · **Ticket:** PROJ-123 · **Tech proposal:** [tech-proposal.md](tech-proposal.md) (Approved) · **Tasks:** 14/14

## Summary
<!-- 3 to 6 sentences: what users can do now, what changed for operators, what did not change. -->

## Proposal versus implementation
| Item | Tech proposal | Implementation | Why it differs |
|------|---------------|----------------|----------------|
| D-1 Async export job | Job queue with 3 retries | As proposed | |
| POST /api/v1/invoices/exports | Returns 202 with job id | Returns 202 with job id and a status URL | Avoids a second round trip; agreed in review |

## Behaviour delivered
| AC | Scenario | Where it lives | Verified by |
|----|----------|----------------|-------------|
| AC-1 | invoice-export › Export current filter › Successful export | src/.../ExportController.java | ExportControllerTest, Q.1 |

## Deviations and deferred work
## How to review
## Verification
## Rollout
## Release note
```

Rules:

- **Proposal versus implementation** has one row per decision (`D-n`), endpoint, data model element,
  rollout step and forced note (`FT-n`) in the tech proposal. "As proposed" when identical. Every
  difference states why. A difference that changes observable behaviour also updates the delta specs.
- **Behaviour delivered** has one row per acceptance criterion. "Where it lives" is a file path, the
  entry point a reviewer opens first. "Verified by" names a test and the `Q.n` task.
- **Deviations and deferred work** lists unchecked tasks with reasons and scope surfaced during
  implementation. "None" is a valid value and must be written.
- **Rollout** describes what was implemented, not what was proposed.
- Never write "see code" or "self-explanatory". Every claim points to a file, a test or a result.
- The `## Release note` section is reused by `/espec:archive` as the ticket comment.
- When a change ships in several pull requests, keep one `##` block per pull request in the same
  file, newest first, each with the sections above.

### Reviewing the code

When `review.tool` in `config.yaml` is `diffcompass`, the reviewer walks the diff with
[DiffCompass](https://github.com/Mindera/diffcompass): `diffcompass pr <number> --open` for a pull
request, `diffcompass --base <review.base> --open` for a branch. `.diffcompass.json` at the repository
root tells its agent to read the change folder first, follow **How to review**, and flag code that
differs from the tech proposal or the delta specs without a row in **Proposal versus implementation**.
The tour helps the reviewer; it does not replace approval in the pull request.

## Inspection report formats

Inspect commands print a report in the chat and never edit anything. On request they save it to
`espec/changes/<change-name>/inspections/YYYY-MM-DD-<command>.md`. A finding is **Blocking** when it
would change scope or observable behaviour, leaves a product id without a scenario, task or test, or
leaves a question open that product must answer. Everything else is **Advisory**.

### Feature definition inspection

```markdown
# Inspection: feature definition · <title> (<ticket>)

**Source:** <ticket key, fetched YYYY-MM-DD | pasted text | espec/changes/<change-name>/feature.md> · **Verdict:** Ready for tech proposal | Draft (<n> blocking, <m> advisory)

## Readiness checklist
| Check | Result | Fix |
|-------|--------|-----|
| Why explains the problem and the cost of doing nothing | ✅ | |
| What is from the user's point of view, with no solution | ✅ | |
| At least one UC-n with actor, trigger, main flow and outcome | ✅ | |
| At least one EC-n, or a stated reason why none apply | ✅ | |
| Out of scope is an explicit list | ✅ | |
| Every UC-n and EC-n is covered by an AC-n, and every AC-n says what it covers | ✅ | |
| Experience and design is filled, or marked "not needed" with a reason | ✅ | |
| Open questions is "None" or every question has an owner | ✅ | |
| No how outside Forced technical notes | ✅ | |

## Product boundary
<!-- Every how found outside Forced technical notes: the quote, where it is, an outcome rephrasing. "None" when clean. -->

## Coverage
| Id | Covered by | Gap |
|----|------------|-----|
| UC-1 | AC-1, AC-2 | |

## Edge cases to consider
<!-- Standard-list items that apply and are absent, each as a proposed EC-n. "None" when complete. -->

## Testability
<!-- Acceptance criteria whose THEN is not observable or measurable, each with a rewrite. "None" when clean. -->

## Findings
| # | Severity | Finding | Where | Suggested fix |
|---|----------|---------|-------|---------------|

## Comment for the ticket
<!-- Pasteable: the verdict, blocking findings as questions for product, advisory ones as suggestions. -->
```

The verdict is **Ready for tech proposal** only with zero blocking findings. A ❌ in the checklist and
a how outside the forced notes are always blocking.

### Tech proposal inspection

```markdown
# Inspection: tech proposal · <title> (<ticket>)

**Change:** `espec/changes/<change-name>/` · **Proposal status:** Draft | In review | Approved · **Verdict:** Approve | Not yet (<n> blocking, <m> advisory)

## Ticket versus feature.md
<!-- "Identical (ticket fetched YYYY-MM-DD)", "Ticket not reachable, feature.md taken as is", or the differences section by section. An unresolved difference is blocking. -->

## Traceability
| Id | Scenario | Tasks | QA line | Gap |
|----|----------|-------|---------|-----|
| UC-1 | invoice-export › Export current filter › Successful export | 2.1, 2.2 | Q.1 | |

## Forced technical notes
| Note | Verdict in proposal | Finding |
|------|---------------------|---------|

## Decisions
| Decision | Alternatives listed | Finding |
|----------|---------------------|---------|

## Constraints and non-functional requirements
| Constraint or metric in feature.md | Addressed in | Finding |
|------------------------------------|--------------|---------|

## Specs
<!-- Every AC has a scenario; scenarios use four hashes and are testable; MODIFIED blocks are whole; existing capability paths are reused; new capabilities carry a Purpose. -->

## Test strategy
<!-- Every EC has a test at a named level; one Q.n per AC; non-functional checks present; test data and environments named. -->

## Open questions
<!-- Blocking questions for product still open; engineering questions that would change specs or tasks. -->

## Findings
| # | Severity | Finding | Where | Suggested fix |
|---|----------|---------|-------|---------------|

## Comment for the ticket
<!-- Pasteable: the verdict and the blocking findings as questions for product or engineering. -->
```

The verdict is **Approve** only with zero blocking findings. An untraced `UC-n`, `EC-n` or `AC-n`, an
`FT-n` without a verdict, an acceptance criterion without a scenario, an unresolved ticket difference,
an open blocking Question for Product and a constraint with no home are always blocking.

## Change lifecycle (`.espec.yaml`)

```yaml
ticket: PROJ-123                 # Jira key or GitHub issue URL
title: Export invoices as CSV
status: defined                  # defined | proposed | in-progress | implemented | archived | cancelled
created: 2026-10-24
owners:
  product: <name>
  engineering: <name>
  qa: <name>
skip_specs: false                # true only when no observable behaviour changes
archived: 2026-11-02             # set by /espec:archive
archived_with_open_tasks: ""     # set by /espec:archive when the user chose to archive early, with the reason
cancelled: 2026-11-02            # set by /espec:archive when the change will not ship
cancelled_reason: ""             # why, set together with cancelled
```

- `defined`: `feature.md` exists and is marked Ready for tech proposal.
- `proposed`: `tech-proposal.md`, `specs/` (or `skip_specs`) and `tasks.md` exist. Approval is the
  **Status: Approved** line in `tech-proposal.md`, set by the reviewer. Implementation does not start
  without it, and `espec validate` fails a change that is `in-progress` on an unapproved proposal.
- `in-progress`: at least one task is checked.
- `implemented`: every task is checked and `pull-request.md` exists.
- `archived`: folder moved under `changes/archive/`.
- `cancelled`: the change will not ship. The folder is moved under `changes/archive/` without applying
  its deltas, with `cancelled` and `cancelled_reason` set. A cancelled change is a record, never
  evidence of behaviour.

## Archive rules (`/espec:archive`)

1. Refuse to archive with unchecked tasks unless the user confirms and the reason is recorded.
2. For each delta file, locate the main spec at `espec/specs/<capability>/spec.md`. Apply in this order:
   RENAMED, REMOVED, MODIFIED, ADDED. Match requirements by exact heading text, whitespace trimmed.
3. A new capability is created from the delta's `## Purpose` and its ADDED requirements. A delta that
   only MODIFIES or REMOVES requirements of a capability that has no main spec is a conflict: stop.
4. A MODIFIED or REMOVED heading that does not exist in the main spec is a conflict: stop and report.
   An ADDED heading that already exists with identical content is already synced; with different
   content it is a conflict.
5. After applying, the main spec must contain no delta section headings (`## ADDED Requirements`
   and friends) and every requirement must still have at least one scenario.
6. Move `changes/<change-name>/` to `changes/archive/YYYY-MM-DD-<change-name>/` and set
   `status: archived`. Never overwrite an existing archive folder.
7. Produce a short release note for the ticket: what shipped, which specs changed, what was deferred.
8. A change that will not ship is cancelled instead of archived: set `status: cancelled`, `cancelled`
   and `cancelled_reason` in `.espec.yaml`, skip the spec sync, move the folder as in rule 6, and
   write a note for the ticket saying what was cancelled and why. Its deltas are never applied.

## Archive clean rules (`/espec:archive-clean`)

The goal is a `espec/specs/` folder that describes only what the system does today.

1. Inventory every requirement in `espec/specs/`.
2. For each requirement, gather evidence: code and tests that implement it, archived changes that
   added or last modified it, and archived changes or open changes that contradict it. A change under
   `archive/` with `status: cancelled` never counts: its deltas were not applied.
3. Classify each requirement as **Keep** (evidence found, still true), **Update** (still true in part;
   propose the corrected text), or **Purge** (no code, no tests, superseded, duplicated, or marked
   deprecated past its sunset). Record the evidence next to the verdict.
4. Also flag: capabilities with a `TBD` purpose, duplicate requirement names across capabilities,
   requirements without scenarios, and archived change folders older than
   `archive.clean.prune_archived_changes_older_than_days` when that setting is greater than zero.
5. Write the report to `changes/archive/YYYY-MM-DD-archive-clean/cleanup.md` and show it.
6. Apply nothing until the user confirms. Apply only the confirmed verdicts, one capability at a time.
   Purging the last requirement of a capability deletes its folder.
7. Append the applied actions to the same `cleanup.md`. The report is the audit trail.

## Guardrails for AI assistants

- Phase 1 writes product language only. Push back on how. Record forced hows under `FT-n`.
- Phase 2 writes planning artifacts only. Never edit application code during a tech proposal.
- Phase 3 implements what the specs and tasks say. When a task needs more than the spec describes,
  or you are tempted to narrow, defer or simplify specified behaviour, stop and surface it. Never
  silently reduce scope. Only check a task when its behaviour is fully implemented and verified.
- Phase 4 never deletes a spec without evidence and confirmation.
- Inspect commands are read-only. They never edit the ticket, `feature.md`, the proposal, specs, tasks
  or code, and they save a report only when asked.
- Always read `project.md` and `config.yaml` for project context and rules before writing. Apply them;
  do not paste them into artifacts.
- Re-read artifacts from disk before building on them. Humans edit them between steps.
- When a ticket system is reachable (an MCP server, a browser tool, or a pasted body), prefer the ticket
  as the source of truth for `feature.md`. Keep the ticket and `feature.md` identical; when they differ,
  show the diff and ask which one wins.
