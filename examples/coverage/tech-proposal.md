## Coverage: tech proposal versus feature definition

**Change:** `espec/changes/bill-142-invoice-csv-export/` · **Match:** 13 of 13 product ids covered (100%), 0 partial, 0 missing · Constraints, metrics, UI design and forced notes: 16 of 18 addressed

Re-read from disk after writing: `feature.md` (3 UC, 9 EC, 13 AC, 7 constraints, 5 success metrics, 1 FT),
`specs/invoice-export/spec.md` (7 ADDED requirements, 23 scenarios), `specs/invoice-list/spec.md` (1 MODIFIED
requirement, 4 scenarios), `tasks.md` (24 tasks, Q.1 to Q.16). Every scenario and task named below exists under
that name.

| Id | Scenario | Tasks | QA line | Status | Gap |
|----|----------|-------|---------|--------|-----|
| UC-1, AC-1 | invoice-export › Export current filter › Successful export; invoice-export › Background export › Small export is ready quickly; invoice-list › List actions › Export CSV shows the current count | 2.1, 2.5, 3.1, 4.1, 4.2, 4.6 | Q.1 | Covered | |
| UC-2, AC-2 | invoice-export › Background export › Large export continues while the user works | 1.2, 2.5, 3.2, 4.2, 4.4 | Q.2 | Covered | |
| UC-3, AC-3 | invoice-export › Export current filter › Saved view is exported | 2.2, 3.1, 4.6 | Q.3 | Covered | |
| EC-1, AC-4 | invoice-export › Export current filter › Filter matches no invoices | 2.4, 4.3 | Q.4 | Covered | |
| EC-2, AC-5 | invoice-export › Export size limit › Filter exceeds the limit; Filter at the limit | 2.1, 3.1, 4.3 | Q.5 | Covered | |
| EC-3, AC-6 | invoice-export › Concurrent exports › Fourth export is declined; Exports of two users stay separate | 1.1, 2.1, 3.1, 3.2, 4.3 | Q.6 | Covered | |
| EC-4, AC-7 | invoice-export › Export permissions › Read-only accountant exports; User without invoice access; invoice-list › List actions › Read-only accountant sees only the actions she can use | 2.1, 3.1, 3.3, 4.1, 4.3 | Q.7 | Covered | |
| EC-5, AC-8 | invoice-export › Export file contents › Amounts stay in the invoice currency | 2.3 | Q.8 | Covered | |
| EC-6, AC-9 | invoice-export › Export file contents › Dates and timestamps | 2.3 | Q.9 | Covered | |
| EC-7, AC-10 | invoice-export › Export file contents › Values with commas, quotes and line breaks; Values that look like formulas | 2.3 | Q.10 | Covered | |
| EC-8, AC-11 | invoice-export › Background export › User leaves the page; invoice-export › Export retention › Download within 24 hours; Download after 24 hours; Only the requester can download | 1.1, 2.5, 2.6, 3.2, 3.3, 4.4, 4.6 | Q.11 | Covered | |
| UC-1, UC-2, UC-3, AC-12 | invoice-export › Export file contents › Columns and header row; File name | 2.2, 2.3 | Q.12 | Covered | |
| EC-9, AC-13 | invoice-export › Background export › Export fails | 1.2, 2.5, 4.3 | Q.13 | Covered | |

| Constraint, metric, UI design item or FT-n | Addressed in | Status |
|-----------------------------------------|--------------|--------|
| Constraint: data residency | Non-functional requirements (EU bucket, pre-signed URL host); task 5.4 `StorageConfigTest` | Addressed |
| Constraint: devices (iPad Safari, both orientations) | Architecture (frontend states); tasks 4.1, 4.5; Q.14 | Addressed |
| Constraint: close week performance | Non-functional requirements (10 s for 2,000 rows, 2 min for 50,000, list p95 under 400 ms); Test strategy load test; task 5.3; Q.15 | Addressed |
| Constraint: audit | Traceability row "Constraint: audit"; invoice-export › Export current filter › Export is recorded; tasks 2.1, 3.3 | Addressed |
| Constraint: retention | invoice-export › Export retention (3 scenarios); task 2.6 | Addressed |
| Constraint: language (English headings) | invoice-export › Export file contents › Columns and header row; task 2.3; Q.12 | Addressed |
| Constraint: timing (Q4 2026 train, code freeze 5 December) | Rollout and migration › Timing: the design-partner step lands before 21 November so the general step clears the freeze | Addressed |
| Metric: 60% of finance users export within 60 days | Non-functional requirements › Observability: `ledgerly_invoice_export_rows_total` per organisation; task 5.1 panel | Addressed |
| Metric: support requests for extracts drop to under 5 a month | Not measurable from the repository. Named in Rollout as a product follow-up on the ticket after one quarter | No home |
| Metric: 95% of exports up to 2,000 rows ready in 10 s, 99% complete without error | Non-functional requirements (targets); task 5.2 alert at 5% failure rate; task 5.3 load test | Addressed |
| Metric: zero data-residency incidents | Same evidence as the data residency constraint | Addressed |
| Metric: both enterprise renewals sign in Q1 2027 | Out of the proposal's reach; depends on the timing constraint above | No home |
| UI design: states (empty, preparing, ready, failed, expired, limit, no permission) | invoice-export scenarios for each state; task 4.3 messages in four locales; Q.4 to Q.7, Q.13 | Addressed |
| UI design: actions on narrow screens | invoice-list › List actions › Actions on narrow screens; tasks 4.1, 4.5 | Addressed |
| UI design: accessibility (live regions, focus, 44 px targets) | Non-functional requirements › Accessibility; task 4.5; Q.15 | Addressed |
| UI design: exports indicator kept across navigation | invoice-export › Background export › User leaves the page; task 4.4 | Addressed |
| UI design: copy and tone of the messages | task 4.3 takes the strings from the UI design section verbatim | Addressed |
| FT-1: use the nightly batch job | Forced technical notes review: Overridden; the monitoring need is met by the Ops dashboard panel and shared alert routing; tasks 5.1, 5.2 | Addressed |

**Judgement:** Every use case, edge case and acceptance criterion has a scenario whose THEN states the result the
criterion asks for, a task that builds it and a QA line that checks it, so the proposal follows the definition
rather than interpreting it. Two success metrics (support requests, renewals) are business outcomes the code
cannot measure; they are named in Rollout as a product follow-up and are the two gaps above, both advisory. The
Timing bullet under Rollout and the 48-hour list window are the two fixes the inspection asked for; a reviewer
should check that the dates in Timing match the release calendar. `FT-1` is overridden with a reason product has
already agreed to on the ticket.
