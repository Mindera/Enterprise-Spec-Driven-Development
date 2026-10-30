# Inspection: tech proposal · Export invoices as CSV (BILL-142)

**Change:** `espec/changes/bill-142-invoice-csv-export/` · **Proposal status:** In review · **Verdict:** Not yet (2 blocking, 5 advisory)

## Ticket versus feature.md

Identical (ticket BILL-142 fetched 2026-10-22). Compared section by section, Forced technical notes and the
resolved open question included.

## Traceability

Read from `specs/invoice-export/spec.md` (7 ADDED requirements, 23 scenarios), `specs/invoice-list/spec.md`
(1 MODIFIED requirement, 4 scenarios) and `tasks.md` (24 tasks, Q.1 to Q.16). The proposal's Traceability table
was taken as a claim and checked against those files: every scenario it names exists under that name, every task
number exists, and one covers list disagrees with it (finding 4).

| Id    | Scenario | Tasks | QA line | Gap |
|-------|----------|-------|---------|-----|
| UC-1  | invoice-export › Export current filter › Successful export; invoice-export › Background export › Small export is ready quickly; invoice-list › List actions › Export CSV shows the current count | 2.1, 2.5, 3.1, 4.1, 4.2, 4.6 | Q.1 | |
| UC-2  | invoice-export › Background export › Large export continues while the user works | 1.2, 2.5, 3.2, 4.2, 4.4 | Q.2 | |
| UC-3  | invoice-export › Export current filter › Saved view is exported | 2.2, 3.1, 4.6 | Q.3 | |
| EC-1  | invoice-export › Export current filter › Filter matches no invoices | 2.4, 4.3 | Q.4, Q.14 | |
| EC-2  | invoice-export › Export size limit › Filter exceeds the limit; invoice-export › Export size limit › Filter at the limit | 2.1, 3.1, 4.3 | Q.5, Q.14 | |
| EC-3  | invoice-export › Concurrent exports › Fourth export is declined; invoice-export › Concurrent exports › Exports of two users stay separate | 1.1, 2.1, 3.1, 3.2, 4.3 | Q.6, Q.14 | |
| EC-4  | invoice-export › Export permissions › Read-only accountant exports; invoice-export › Export permissions › User without invoice access; invoice-list › List actions › Read-only accountant sees only the actions she can use | 2.1, 3.1, 3.3, 4.1, 4.3 | Q.7, Q.14 | |
| EC-5  | invoice-export › Export file contents › Amounts stay in the invoice currency | 2.3 | Q.8, Q.14 | |
| EC-6  | invoice-export › Export file contents › Dates and timestamps | 2.3 | Q.9, Q.14 | |
| EC-7  | invoice-export › Export file contents › Values with commas, quotes and line breaks; invoice-export › Export file contents › Values that look like formulas | 2.3 | Q.10, Q.14 | |
| EC-8  | invoice-export › Background export › User leaves the page; invoice-export › Export retention › Download within 24 hours; invoice-export › Export retention › Download after 24 hours; invoice-export › Export retention › Only the requester can download | 1.1, 2.5, 2.6, 3.2, 3.3, 4.4, 4.6 | Q.11, Q.14 | The list contract never shows an expired export (finding 1) |
| EC-9  | invoice-export › Background export › Export fails | 1.2, 2.5, 4.3 | Q.13, Q.14 | |
| AC-1  | invoice-export › Export current filter › Successful export; invoice-export › Background export › Small export is ready quickly; invoice-list › List actions › Export CSV shows the current count | 2.1, 2.5, 3.1, 4.1, 4.2, 4.6 | Q.1 | Task 2.5 does not name AC-1 in its covers list (finding 4) |
| AC-2  | invoice-export › Background export › Large export continues while the user works | 1.2, 2.5, 3.2, 4.2, 4.4 | Q.2 | |
| AC-3  | invoice-export › Export current filter › Saved view is exported | 2.2, 3.1, 4.6 | Q.3 | |
| AC-4  | invoice-export › Export current filter › Filter matches no invoices | 2.4, 4.3 | Q.4 | |
| AC-5  | invoice-export › Export size limit › Filter exceeds the limit; invoice-export › Export size limit › Filter at the limit | 2.1, 3.1, 4.3 | Q.5 | |
| AC-6  | invoice-export › Concurrent exports › Fourth export is declined; invoice-export › Concurrent exports › Exports of two users stay separate | 1.1, 2.1, 3.1, 3.2, 4.3 | Q.6 | |
| AC-7  | invoice-export › Export permissions › Read-only accountant exports; invoice-export › Export permissions › User without invoice access; invoice-list › List actions › Read-only accountant sees only the actions she can use | 2.1, 3.1, 3.3, 4.1, 4.3 | Q.7 | |
| AC-8  | invoice-export › Export file contents › Amounts stay in the invoice currency | 2.3 | Q.8 | |
| AC-9  | invoice-export › Export file contents › Dates and timestamps | 2.3 | Q.9 | |
| AC-10 | invoice-export › Export file contents › Values with commas, quotes and line breaks; invoice-export › Export file contents › Values that look like formulas | 2.3 | Q.10 | The formula guard as described may change the shown value (finding 5) |
| AC-11 | invoice-export › Background export › User leaves the page; invoice-export › Export retention › Download within 24 hours; invoice-export › Export retention › Download after 24 hours; invoice-export › Export retention › Only the requester can download | 1.1, 2.5, 2.6, 3.2, 3.3, 4.4, 4.6 | Q.11 | As EC-8 (finding 1); the manual check relies on a hook no task builds (finding 3) |
| AC-12 | invoice-export › Export file contents › Columns and header row; invoice-export › Export file contents › File name | 2.2, 2.3 | Q.12 | |
| AC-13 | invoice-export › Background export › Export fails | 1.2, 2.5, 4.3 | Q.13 | The manual check relies on a hook no task builds (finding 3) |

Q.1 to Q.13 each name one acceptance criterion, in order. Beyond the product ids, the proposal also traces
Constraint: audit (invoice-export › Export current filter › Export is recorded; tasks 2.1, 3.3; no QA line,
finding 6), Constraint: data residency (5.4; Q.15), Constraint: close week performance (5.3; Q.15), the UI design
items for narrow screens and accessibility (invoice-list › List actions › Actions on narrow screens; 4.1, 4.5;
Q.14, Q.15) and FT-1 (5.1, 5.2; Q.16). All of those scenarios and tasks exist as named.

## Forced technical notes
| Note | Verdict in proposal | Finding |
|------|---------------------|---------|
| FT-1 | Overridden | None. The reason says why the nightly batch cannot meet the 10-second and 2-minute outcomes and how the need behind the note is met: the job queue's metrics already feed the "Ledgerly Ops" dashboard, task 5.1 adds an "Invoice exports" panel next to the nightly batch panel, task 5.2 routes the alert to the same channel, Rollout gives finance operations a walkthrough, Q.16 checks it. Agreed with the product owner on 2026-10-21. |

## Decisions
| Decision | Alternatives listed | Finding |
|----------|---------------------|---------|
| D-1 Run exports on the existing PostgreSQL job queue | Synchronous streaming response; extend the nightly Spring Batch job (FT-1); a new message broker (SQS or Kafka). Each says why it lost | None |
| D-2 Apache Commons CSV plus own formatting layer | Hand-rolled writer; OpenCSV; Jackson CSV. Each says why it lost | None. The reason is not a restatement: quoting correctness, the passed security review and the BOM for Excel |
| D-3 Short-lived pre-signed URL for downloads | Stream through the API; long-lived pre-signed URL in the status response. Each says why it lost | None |

## Constraints and non-functional requirements
| Constraint or metric in feature.md | Addressed in | Finding |
|------------------------------------|--------------|---------|
| Data residency (EU only) | Context (bucket in `eu-central-1`), D-3, Non-functional › Privacy, Test strategy › Data residency (`StorageConfigTest`, pre-signed URL host), task 5.4, Q.15 | None |
| Devices (iPad Safari in both orientations, desktop browsers) | Architecture (`ExportButton.tsx` moves into More actions below 900 px), Non-functional › Accessibility (44 px targets), invoice-list › List actions › Actions on narrow screens, Test strategy (manual on iPad, VoiceOver on iPad Safari), tasks 4.1, 4.5, Q.14 | None |
| Close week performance (10 s typical, 2 min largest, list as fast as today) | Non-functional › Performance (targets and means), Risks (first item), Test strategy › Load (k6), task 5.3, Q.15 | None |
| Audit (who, when, filters, rows; every download; existing retention) | Approach, APIs › Jobs and events (three audit events), invoice-export › Export current filter › Export is recorded, Context ("retention is handled centrally"), tasks 2.1, 3.3, Test strategy (integration) | Advisory (finding 6): no QA line checks the audit entries on staging |
| Retention (24 hours, then removed) | Approach (hourly clean-up), Data model (`expires_at`, EXPIRED, row deleted after 30 days), invoice-export › Export retention, task 2.6, Q.11 | Blocking (finding 1): the Expired state cannot appear in the list |
| Language (English headings, interface copy in the user's language) | Non-functional › i18n, invoice-export › Export file contents › Columns and header row, tasks 2.3, 4.3 (`npm run i18n:check`), Q.12 | None |
| Timing (Q4 2026 release train, code freeze 5 December 2026) | Nowhere. Rollout gives an order and a one-week gate but no date, and does not say whether the three enablement stages fit before the freeze or are flag changes that need no deploy | Blocking (finding 2) |
| Metric: 60% of active finance users export within 60 days | Implicitly: the audit event `invoice.export.created` carries the actor and the time, enough to count users. Not named as the measure | Advisory (finding 7) |
| Metric: support extract requests under 5 a month | Measured in the support queue, outside the product. Nothing for the proposal to build | None |
| Metric: 95% of exports up to 2,000 rows within 10 s; 99% complete without error, monthly including close week | Non-functional › Performance (p95 target), Observability (`ledgerly_job_duration_seconds`, `ledgerly_job_failures_total` tagged `invoice-export`), Rollout gate (error rate under 1%), task 5.1 | None |
| Metric: zero data-residency incidents | As Data residency above | None |
| Metric: both renewals sign in Q1 2027 | Commercial outcome outside the product; it rides on Timing above | None beyond finding 2 |

## Specs

Every AC-1 to AC-13 has at least one scenario, listed in the table above, and every AND in AC-6, AC-11 and AC-13
is covered (two users stay separate, 24-hour expiry and requester-only download, failed export no longer counts).
All 27 scenarios use `#### Scenario:` and carry a WHEN and an observable THEN; the 10-second and 2-minute
scenarios carry the number. Requirements use SHALL, have unique names under 50 characters and at least one
scenario each. `specs/invoice-export/spec.md` is a new capability and carries a `## Purpose` with ADDED
requirements only. `specs/invoice-list/spec.md` reuses the existing capability path, and its single MODIFIED
block, List actions, is the whole requirement with all four scenarios, including the two that existed before.
The spec is wider than feature.md in two places, both improvements rather than gaps: User leaves the page
includes "loses the connection" as EC-8 does, and Values that look like formulas covers +, - and @ as EC-7 does.
One spec-versus-contract mismatch: Export retention › Download after 24 hours requires the expired export to be
"shown as expired in the list of exports", while `GET /api/v1/invoices/exports` returns exports created in the
last 24 hours and `expires_at` is `created_at + 24 h` (finding 1).

## Test strategy

Every EC-n has a test at a named level: EC-1 unit, component and manual; EC-2 service, API and manual; EC-3 API
and manual with two browsers; EC-4 integration and manual; EC-5, EC-6 and EC-7 unit golden files and manual in
Excel 365 for Windows, Excel for Mac, Google Sheets and Numbers; EC-8 integration, e2e and manual; EC-9
integration, e2e and manual with an injected storage failure. The `## QA verification` group has one `Q.n` per
acceptance criterion (Q.1 to Q.13), an exploratory pass over EC-1 to EC-9 on desktop and iPad in both
orientations (Q.14), the non-functional checks (Q.15) and the observability check (Q.16). Non-functional checks
exist for close week performance (k6), data residency (`StorageConfigTest` and the URL host), accessibility
(axe, VoiceOver, keyboard) and observability (forced failure). Test data (Acme Logistics Group, 62,310 invoices,
"Overdue Q3", the four accounts) and the environment (staging, EU) are named. Every task group lands its own
tests; no task says "explore" or "decide". Two gaps: the strategy, Q.11 and Q.13 rely on a staging-only expire
endpoint and a storage failure toggle that no task builds (finding 3), and the audit constraint has an
integration test but no QA line (finding 6).

## Open questions

- Questions for Product: "None blocking." One non-blocking question is open at inspection: whether the file should
  carry a first line with the applied filters and the export time, assumed no, answer by 2026-11-07. Advisory:
  the assumption matches the spec (Columns and header row: the first row holds the headings) and a yes would be a
  separate change, as the proposal says.
- Open engineering questions: the read replica for the streaming query, and the fetch size (500 or 1,000). Both
  are decided after the load test in task 5.3 and change neither specs nor tasks. Advisory, can wait.

## Findings
| # | Severity | Finding | Where | Suggested fix |
|---|----------|---------|-------|---------------|
| 1 | Blocking | The spec requires an expired export to be "shown as expired in the list of exports" and the UI design lists an Expired state, but the list endpoint returns exports created in the last 24 hours while expiry is `created_at + 24 h`, so an export leaves the list at the moment it expires. The only test of the Expired state uses the staging expire hook, which keeps `created_at` inside the window and cannot catch this | APIs and contracts › `GET /api/v1/invoices/exports`; Data model › `expires_at`; specs/invoice-export › Export retention › Download after 24 hours; tasks 3.2, 4.4 | Return the caller's exports created in the last 48 hours (or the latest 20 whatever their age) with their status, update tasks 3.2 and 4.4 and the Exports indicator, and add a test where an export expires naturally; or, with product, drop the Expired state from the UI design and the spec |
| 2 | Blocking | The Timing constraint (Q4 2026 release train, code freeze 5 December 2026) has no home in the proposal | feature.md › Constraints › Timing; tech-proposal.md › Rollout and migration | State in Rollout that the code ships dark in the Q4 2026 train before 5 December and that the three enablement stages are flag changes needing no deploy, with target dates for internal, design partner and general enablement so the January close is met |
| 3 | Advisory | The test strategy, Q.11 and Q.13 depend on `POST /internal/test/exports/{id}/expire` and a storage failure toggle on staging; no task builds either | Test strategy (first paragraph and the Background export row); tasks.md | Add a task in group 2 or 5 that delivers both hooks under the staging profile only, verified by a test that they are absent in the prod profile |
| 4 | Advisory | Task 2.5 is listed for UC-1 and AC-1 in the proposal's Traceability table but its covers list reads "(covers AC-2, AC-11, AC-13)" | Traceability › row "UC-1, AC-1"; tasks.md › 2.5 | Add AC-1 to the covers list of 2.5, since the worker is what produces the file |
| 5 | Advisory | The formula guard "prefixes values starting with =, +, -, @, tab or carriage return with a single quote". Applied to every column it would turn a negative amount into text, against AC-8 and EC-5; and a visible leading quote would not be "exactly as stored" (AC-10) in tools that keep it on import | Non-functional requirements › Security; Architecture › `InvoiceCsvWriter`; task 2.3 | Say the guard applies to text columns only, add a negative-amount golden case to `InvoiceCsvWriterTest`, and have the manual Excel and Sheets pass confirm the guarded value shows without the added character; if a tool shows it, qualify the spec scenario |
| 6 | Advisory | The audit constraint is covered by an integration test but by no QA line, although the constraint is contractual for the renewals | Test strategy › Non-functional checks; tasks.md › QA verification | Add the audit check to Q.15 or as Q.17: one export and one download, then the events in the audit log with actor, time, filters and row count |
| 7 | Advisory | The adoption metric (60% of active finance users within 60 days) has data behind it (the `invoice.export.created` audit event carries the actor) but no section names how it will be measured | feature.md › Success metrics; tech-proposal.md › Non-functional requirements › Observability | Add one line under Observability: distinct actors of `invoice.export.created` over active finance users, read monthly from the audit log |

## Comment for the ticket

**espec inspection of the tech proposal, 2026-10-22: Not yet (2 blocking, 5 advisory).** The ticket and
feature.md are identical. Every UC, EC and AC is traced to named scenarios, tasks and a QA line, FT-1 is
overridden with its need met on the Ops dashboard, the three decisions list their alternatives, and the test
strategy covers every edge case at a named level. Two points to settle before approval:

1. **Engineering, expired exports.** The list of exports only returns exports created in the last 24 hours, and
   an export expires at exactly 24 hours, so the Expired state in the UI design and in the spec scenario Download
   after 24 hours can never be shown. Either widen the list window (48 hours, or the latest 20) or ask product to
   drop the Expired state. Which?
2. **Engineering, timing.** The feature must be in the Q4 2026 release train (code freeze 5 December 2026).
   Please add the dates to Rollout: when the dark code ships and when the three enablement stages happen.

Suggestions, not blocking: add a task for the staging expire endpoint and the storage failure toggle the QA lines
use; add AC-1 to the covers list of task 2.5; say the formula guard applies to text columns only and add a
negative-amount test; add a QA line for the audit entries; name the audit log as the source for the adoption
metric. One non-blocking question for product stays open (a filter line at the top of the file, assumed no,
answer by 2026-11-07).
