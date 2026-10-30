# Conventions

This page explains the espec formats with short examples. The source of truth is
[template/espec/AGENTS.md](../template/espec/AGENTS.md), which every prompt reads before it writes.
When this page and `AGENTS.md` disagree, `AGENTS.md` wins.

Blank files for each format live in `template/espec/templates/`. A complete worked example lives in
[examples/changes/bill-142-invoice-csv-export/](../examples/changes/bill-142-invoice-csv-export/).

## Design vocabulary

On its own, "design" means the technical design: architecture, decisions and contracts, written in
`tech-proposal.md`. What people see and do (flows, screens and states, copy, accessibility) is the
**UI design** section of `feature.md`, filled by the Designer. A change folder has no `design.md` or
`ui-design.md`.

## Product boundary and forced technical notes

A feature definition says **what** and **why**. It never says **how**. APIs, databases, queues,
libraries, frameworks, cloud services, architecture, component names, CSS and performance mechanisms
are all how. So is any sentence that starts with "implement", "build it with", "store it in", "call
the" or "use the".

Outcomes are allowed. They constrain engineering without choosing the solution:

| Not allowed in a feature definition | Allowed |
|---|---|
| Run the export as a background job | The export must not block the screen and must finish within 10 seconds |
| Store exports in S3 in eu-west-1 | Export files must stay in the EU |
| Add a `format` column to `invoices` | The user's last chosen format is remembered |

When product insists on a how, the AI asks once, then records it under `## Forced technical notes`
with an `FT-n` id, the reason, and the ⚠️ marker. Every other section stays clean.

```markdown
## Forced technical notes
> ⚠️ **Forced by product.** These notes describe *how*, which is outside the product boundary.
> Engineering reviews them in the tech proposal and may override them with a documented reason.
- **FT-1:** Deliver the file by email rather than as a download. _Reason given: the finance
  team's audit tool only ingests email attachments._
```

The tech proposal must answer every `FT-n`:

```markdown
## Forced technical notes review
| Note | Verdict | Reason |
|------|---------|--------|
| FT-1 | Accepted | The audit tool constraint is real. Email delivery is added as D-3. |
```

Nothing forced is lost. Nothing forced is hidden among the product requirements.

## Feature definition ids

| Id | Section | Meaning |
|---|---|---|
| `UC-n` | Use cases | Actor, trigger, preconditions, main flow, outcome |
| `EC-n` | Edge cases | An unusual situation and the expected behaviour. Mandatory. |
| `AC-n` | Acceptance criteria | GIVEN / WHEN / THEN. Each one names what it covers: `### AC-1: <name> (covers UC-1, EC-2)` |
| `FT-n` | Forced technical notes | A how that product forced in. Only present when needed. |

Rules: every `UC-n` and every `EC-n` is covered by at least one `AC-n`. Out of scope is an explicit
list. Open questions each have an owner, or the section says `None`. The document begins with
`<!-- espec:feature-definition v1 -->` so tickets and prompts can recognise it.

The definition is **Ready for tech proposal** when Why, What, at least one UC, edge cases, out of
scope and acceptance criteria are present, every UC and EC maps to an AC, and open questions are
answered or explicitly deferred by product.

## Tech proposal traceability

The tech proposal has its own ids and two tables that tie it back to the feature definition.

| Id | Meaning |
|---|---|
| `D-n` | A technology decision with a choice, a reason, and the alternatives considered. "We always do it this way" is an alternative, not a reason. |
| `FT-n` review | One row per forced note: Accepted or Overridden, with a reason. |

The traceability table is complete or it is not done. Every `UC-n`, `EC-n` and `AC-n` appears.
A product id that cannot be traced becomes a Question for Product.

```markdown
## Traceability
| Product id | Spec requirement / scenario | Tasks |
|------------|-----------------------------|-------|
| UC-1, AC-1 | invoice-export › Export current filter › Successful export | 2.1, 2.2, Q.1 |
| EC-1, AC-3 | invoice-export › Export limit › Too many rows | 2.3, Q.3 |
| EC-2       | (not traced) see Questions for Product, Q1 | |
```

Read it in either direction: from an acceptance criterion to the scenario that specifies it and the
tasks that build and verify it, or from a task back to why it exists. QA uses it to confirm that every
AC has a `Q.n` task.

## Main spec

One folder per capability under `espec/specs/`, one `spec.md` per folder. A capability is a durable
system behaviour (`invoice-export`, `user-auth`), never a change name. Nested paths are fine when the
project already organises specs that way (`billing/invoice-export`).

```markdown
# Invoice Export Specification

## Purpose
Lets finance users take invoice data out of the product in files other tools can open.

## Requirements

### Requirement: Export current filter
The system SHALL export the invoices that match the current list filter.

#### Scenario: Successful export
- **GIVEN** a filtered invoice list with at least one row
- **WHEN** the user chooses Export
- **THEN** a file holding exactly the filtered rows is produced
```

Rules:

- `### Requirement:` headings with SHALL or MUST. Names are unique within a spec and under 50
  characters. The name is the identifier that deltas and archive match on.
- `#### Scenario:` with exactly four `#`. Three hashes or bullets are not parsed.
- Every requirement has at least one scenario. Scenarios are testable.
- One behaviour per requirement, a short description, examples and edge cases in scenarios.
- Observable behaviour, inputs, outputs, errors and constraints. No class names, no endpoints chosen
  for internal reasons. Those belong in the tech proposal.

## Delta spec operations

A delta lives at `espec/changes/<change-name>/specs/<capability>/spec.md` and states only what
changes in that capability. It uses the exact path of the main spec it targets. It has four
operations, each a `## ... Requirements` section.

| Operation | Carries | Note |
|---|---|---|
| `## ADDED Requirements` | Full new requirements with scenarios | Use ADDED when you only add concerns to an existing capability |
| `## MODIFIED Requirements` | The **whole** updated requirement, every scenario included | Not a diff. Partial content loses detail at archive time |
| `## REMOVED Requirements` | The heading, a `**Reason:**` and a `**Migration:**` | |
| `## RENAMED Requirements` | `- FROM:` and `- TO:` heading lines | Body unchanged. Combine with MODIFIED under the new name when the body changes too |

A new capability keeps the `## Purpose` section. An existing capability deletes it.

### Base stamps

A MODIFIED requirement is a copy of the main spec, edited. If another change edits the same
requirement and is archived first, archiving this delta would silently overwrite that edit. So every
MODIFIED and REMOVED requirement records the version it was written against, right under its heading:

```markdown
### Requirement: Export limit
<!-- espec:base 3f9c1a07be42 -->
The system SHALL refuse an export of more than 50,000 invoices.
```

The hash covers the main spec requirement block (heading to the next heading, trailing blanks
ignored). Nobody writes it by hand:

| Command | Does |
|---|---|
| `espec/bin/espec stamp <change-name>` | Writes the stamp under every MODIFIED and REMOVED requirement that has none. The tech proposal runs it after writing the deltas. |
| `espec/bin/espec validate` | Fails when a stamp is missing, or when the main spec requirement no longer matches it. Runs in CI on every pull request that touches `espec/`. |
| `espec/bin/espec stamp <change-name> --rebase` | After you have merged the newer main spec text into the delta, records the new version. Without `--rebase`, stamp refuses to overwrite a stamp that no longer matches. |

A MODIFIED requirement under a name that a RENAMED entry introduces is stamped against the old name.
Archive never copies a stamp into a main spec, and `espec validate` fails a main spec that holds one.

### Worked example

The main spec `espec/specs/invoice-export/spec.md` holds four requirements: **Export current
filter**, **Export limit** (10,000 rows), **Export button** and **XML export**. The change
`bill-142-invoice-csv-export` writes this delta:

```markdown
# invoice-export Delta Specification

## ADDED Requirements

### Requirement: CSV column set
The system SHALL write CSV exports with the columns invoice number, customer, issue date,
due date, total and status, in that order.

#### Scenario: Header row
- **WHEN** a CSV export is produced
- **THEN** the first row holds the six column names in order

#### Scenario: Locale-safe numbers
- **GIVEN** a user whose locale uses a comma as decimal separator
- **WHEN** a CSV export is produced
- **THEN** totals are written with a dot and no thousands separator

## MODIFIED Requirements

### Requirement: Export limit
<!-- espec:base 3f9c1a07be42 -->
The system SHALL refuse an export of more than 50,000 invoices.

#### Scenario: Too many rows
- **WHEN** the filter matches more than 50,000 invoices
- **THEN** the export is refused with a message that names the limit

#### Scenario: At the limit
- **WHEN** the filter matches exactly 50,000 invoices
- **THEN** the export proceeds

## REMOVED Requirements

### Requirement: XML export
<!-- espec:base 8d21e0c4f5a9 -->
**Reason:** No customer has used XML since 2024. Product confirmed the removal in BILL-142.
**Migration:** CSV covers every known use. Saved XML presets open as CSV on first use.

## RENAMED Requirements
- FROM: `### Requirement: Export button`
- TO: `### Requirement: Export entry point`
```

After archive the main spec holds, in this order: **Export current filter** (untouched),
**Export limit** (the new text with two scenarios), **Export entry point** (the old Export button
body under its new name) and **CSV column set** (new). **XML export** is gone. The `## Purpose` is
unchanged. No `## ADDED Requirements` or other delta heading remains.

A change that needs no main spec change sets `skip_specs: true` in `.espec.yaml` and has no `specs/`
folder: a refactor, tooling or docs change, or a bug fix that restores behaviour the main specs already
describe (see [Bug fixes](../template/espec/AGENTS.md#bug-fixes)). Do not invent a requirement to fill it.

## Tasks and checkbox rules

```markdown
# Tasks

## 1. Data access
- [x] 1.1 Add a repository query for the filtered invoice set and verify `InvoiceQueryTest`
- [ ] 1.2 Enforce the 50,000 row limit (covers EC-1, AC-3) and verify `ExportLimitTest`

## 2. CSV writer
- [ ] 2.1 Write the six-column CSV (covers AC-1, AC-2) and verify `CsvWriterTest`

## QA verification
- [ ] Q.1 Verify AC-1 Successful export on staging
- [ ] Q.2 Exploratory pass over EC-1 to EC-4
```

| Rule | Detail |
|---|---|
| Format | `- [ ] N.M description`. Any line without a checkbox is not tracked. |
| Done | `[x]` or `[X]`. Any other marker (`[-]`, `[~]`, `[ ]`) is not done. |
| Verification | Every task says how it is verified: a test, a command, an observable behaviour or a delivered artifact. |
| Tests per group | Each group lands its own tests and documentation. Never one final "testing" group. |
| Traceability | Tasks cite the `AC-n` and `EC-n` they satisfy. |
| QA group | A final `## QA verification` group with `Q.n` tasks: one per acceptance criterion, plus exploratory and non-functional checks from the test strategy. |
| Size and order | Ordered by dependency. Small enough to finish in one session. |

The implementation phase checks a box only after the named verification passed, and only on the
exact line. A partially done task stays unchecked. `tasks.md` is the single progress record.

## Pull request description

Implementation ends by writing `pull-request.md` in the change folder. It is the pull request body,
and it must read without the code: a summary for product and reviewers, a **proposal versus
implementation** table with one row per decision, endpoint, data model element, rollout step and
forced note ("As proposed" or the difference and why), one row per acceptance criterion with the file
to open first and the test that proves it, deviations and deferred work, a review order, verification
results, the rollout as implemented, and a release note that archive reuses as the ticket comment.
The format is in `AGENTS.md`; a filled-in example is in
[examples/changes/bill-142-invoice-csv-export/pull-request.md](../examples/changes/bill-142-invoice-csv-export/pull-request.md).

## Inspection reports

Three read-only commands review the artifacts without changing them. Each prints a report in the
chat, ends with one verdict, and closes with a comment ready to paste on the ticket. On request the
report is saved under `espec/changes/<change-name>/inspections/`.

| Command | Reviews | Sections | Verdict |
|---|---|---|---|
| `/espec:inspect-feature-definition` | A ticket, a pasted definition or `feature.md` | Readiness checklist, Product boundary, Coverage, Edge cases to consider, Testability, Findings, Comment for the ticket | **Ready for tech proposal** or **Draft** |
| `/espec:assess` | The feature definition against the code, the tests and the main specs | What exists today, Capabilities touched, Dependencies outside the repository, Alternatives for product, Criteria that cannot be met as written, Spikes, Findings, Comment for the ticket | **Ready for tech proposal** or **Further discovery required** |
| `/espec:inspect-tech-proposal` | `tech-proposal.md`, `specs/` and `tasks.md` against `feature.md` and the live ticket | Ticket versus feature.md, Traceability, Forced technical notes, Decisions, Constraints and non-functional requirements, Specs, Test strategy, Open questions, Findings, Comment for the ticket | **Approve** or **Not yet** |

Every finding is numbered and marked **Blocking** or **Advisory**. A finding is blocking when it would
change scope or observable behaviour, leaves a product id without a scenario, task or test, or leaves a
question open that product must answer. Everything else is advisory. The verdict is Ready or Approve
only with zero blocking findings; the counts appear next to it, as in `Not yet (2 blocking, 5 advisory)`.

Some findings are always blocking: a ❌ in the readiness checklist, a how outside the forced notes, an
untraced `UC-n`, `EC-n` or `AC-n`, an `FT-n` without a verdict, an acceptance criterion without a
scenario, an unresolved difference between the ticket and `feature.md`, an open blocking Question for
Product, and a constraint with no home in the proposal. In the assessment, a criterion that cannot be
met as written with no agreed rephrasing, a forced note that conflicts with an outcome in the
definition, and a spike a credible proposal cannot be written without are always blocking; an
unconfirmed dependency is blocking only when scope depends on the answer.

The tech proposal inspection treats the proposal's own Traceability table as a claim and verifies it
against the scenario headings in `specs/` and the task numbers in `tasks.md`. The assessment cites a
file path for every claim about the code, makes no design decision, and never takes code evidence as
another team's commitment. The exact formats are in `AGENTS.md`; filled-in reports over the worked
example, including a **Further discovery required** with one blocking finding and a **Not yet** with
two, are in [examples/inspections/](../examples/inspections/).

## Coverage reports

The two generating commands of phases 2 and 3 end with a self-check of their own output, printed in
the chat before the usage line and saved only on request under
`espec/changes/<change-name>/inspections/`.

| Command | Compares | Per row | Match figure |
|---|---|---|---|
| `/espec:tech-proposal` | `tech-proposal.md`, `specs/` and `tasks.md` against `feature.md` | Every `UC-n`, `EC-n` and `AC-n`: Covered, Partial or Missing, with the scenario, tasks and `Q.n` found on disk. Every constraint, success metric, UI design item and `FT-n`: Addressed or No home | `<n> of <m> product ids covered (<p>%)` |
| `/espec:implementation` | The code, the tests, `tasks.md` and `pull-request.md` against `tech-proposal.md`, `specs/` and `feature.md` | Every `AC-n`: Delivered, Partial or Not delivered, with the file, the test and whether it passed this session, and the `Q.n` and whether it is checked. Every proposal item: As proposed, Differs with a reason, or Differs without one | `<n> of <m> acceptance criteria delivered (<p>%)` |

The report counts what the files show, not what the command meant to write. Before printing, the
command closes the gaps it can (a missing scenario, task or `Q.n`, a constraint with no home, a
difference without a row in `pull-request.md`) and lists what remains with the reason: a Question for
Product, an unchecked task, a test that did not run. The figure never reads 100% while one of those is
open. The report is a claim: `/espec:inspect-tech-proposal` and the code review verify it. Formats
are in `AGENTS.md`; filled-in reports over the worked example are in
[examples/coverage/](../examples/coverage/).

## Change naming

| Situation | Pattern | Example |
|---|---|---|
| Ticket exists (Jira) | Ticket key in lower case, then a short slug | `bill-142-invoice-csv-export` |
| Ticket exists (GitHub Issue) | `gh-<number>`, then a short slug | `gh-142-invoice-csv-export` |
| No ticket yet | Kebab-case, verb-first, describes the change | `add-invoice-csv-export` |
| Archived | Date prefix added by archive | `2026-10-24-bill-142-invoice-csv-export` |

Capabilities are named for what the system does, not for the change that introduced it:
`invoice-export`, never `add-invoice-csv-export`.

## .espec.yaml statuses

```yaml
ticket: BILL-142                 # Jira key or GitHub issue URL
title: Export invoices as CSV
kind: feature                    # feature | bug
status: proposed                 # defined | proposed | in-progress | implemented | archived | cancelled
created: 2026-10-24
owners:
  product: <name>
  engineering: <name>
  qa: <name>
skip_specs: false                # true only when the main specs need no change
```

| Status | Set by | Meaning |
|---|---|---|
| `defined` | Phase 1 | `feature.md` exists and is Ready for tech proposal |
| `proposed` | Phase 2 | `tech-proposal.md`, `specs/` (or `skip_specs: true`) and `tasks.md` exist. Approval is the **Status: Approved** line in `tech-proposal.md`, which implementation checks. A later change to a decision, scope or behaviour sets it back to In review |
| `in-progress` | Phase 3 | At least one task is checked |
| `implemented` | Phase 3 | Every task is checked |
| `archived` | Phase 4 | Folder moved under `changes/archive/`. Archive also adds `archived: YYYY-MM-DD`, `archived_with_open_tasks: <reason>` when the user chose to archive early, and `archived_without_sync: <reason>` when the deltas were not applied |
| `cancelled` | Phase 4 | The change will not ship. Archive moves the folder under `changes/archive/` without applying its deltas and records `cancelled: YYYY-MM-DD` and `cancelled_reason`. Never evidence for archive-clean |

The file stays with the folder. It is the audit record of the change.

## Archive merge order and conflicts

Archive applies each delta to its main spec in a fixed order, so that one delta can rename a
requirement and then modify it under the new name:

1. RENAMED
2. REMOVED
3. MODIFIED
4. ADDED

Requirements are matched by exact heading text, whitespace trimmed. Nothing is guessed. The archive
step shows a plan, and stops on the first conflict before it moves anything:

| Situation | Result |
|---|---|
| MODIFIED or REMOVED heading not found in the main spec | Conflict. Stop. |
| MODIFIED or REMOVED base stamp no longer matches the main spec | Conflict. Stop. Merge the newer text into the delta, then `espec stamp <change-name> --rebase` |
| Delta only MODIFIES or REMOVES, and the capability has no main spec | Conflict. Stop. |
| ADDED heading already present with identical content | Already synced. Skip it. |
| ADDED heading already present with different content | Conflict. Stop. |
| Delta has `## Purpose` and ADDED requirements, and no main spec exists | New main spec created from `templates/main-spec.md` |

`espec validate` reports every one of these conflicts on each pull request, long before archive.

After applying, every touched main spec is verified: no delta headings or base stamps remain, every requirement has
a scenario, names are unique, and a second pass finds nothing left to apply. Only then does the
folder move to `espec/changes/archive/YYYY-MM-DD-<change-name>/`. An existing archive folder is
never overwritten.

A conflict is not a failure. Fix the delta, run archive again.

## Archive clean verdicts

Archive-clean inventories every requirement, gathers evidence, and proposes one verdict each. It
writes the report first and applies nothing until the user confirms.

| Verdict | When | Action on confirmation |
|---|---|---|
| **Keep** | Code and tests implement it, and nothing contradicts it | None |
| **Update** | Still true in part. The report gives the corrected requirement text in full, scenarios included | Replace the requirement block in place |
| **Purge** | No code, no tests, superseded, duplicated, or marked deprecated past its sunset | Remove the requirement block. The last requirement in a capability deletes the folder |

Evidence sits next to every verdict: file paths, test names, archived change folders. Two guardrails
apply: a requirement with no evidence either way is **Update** with a note asking for an owner,
never Purge, and a requirement that an active change still references in its traceability table is
never purged.

The report also flags capabilities with a placeholder purpose, duplicate requirement names across
capabilities, requirements without scenarios, and archived change folders older than
`archive.clean.prune_archived_changes_older_than_days` when that setting is above zero.

Applied actions are appended to the same `cleanup.md`. See
[examples/archive-clean/cleanup.md](../examples/archive-clean/cleanup.md) for a filled-in report.
