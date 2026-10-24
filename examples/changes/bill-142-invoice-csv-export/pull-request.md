# Add CSV export of the invoice list (BILL-142)

**Change:** `espec/changes/bill-142-invoice-csv-export/` · **Ticket:** BILL-142 · **Tech proposal:** [tech-proposal.md](tech-proposal.md) (Approved) · **Tasks:** 40/40

## Summary

Finance users who can view invoices can now export what the invoice list shows as a CSV file: one row per invoice,
fifteen fixed English columns, up to 50,000 rows, limited to the legal entities the user can see. Exports of up to
about 2,000 rows download within seconds; larger ones are prepared in the background, show their progress in a new
Exports indicator in the top bar, survive navigation and browser closes, and stay downloadable by the requester for
24 hours. Saved views export the same way and the file carries the view name. For operators there is one new table
(`invoice_export`), one new job type (`invoice-export`) on the existing PostgreSQL job queue, an "Invoice exports"
panel next to the nightly batch panel on the "Ledgerly Ops" dashboard with the same alert routing, and the feature
flag `invoice-csv-export`, off by default. Nothing changes for users who never export, for Sales users, for the
customer portal, or for `GET /api/v1/invoices`.

## Proposal versus implementation

| Item | Tech proposal | Implementation | Why it differs |
|------|---------------|----------------|----------------|
| D-1 | Exports run as an `invoice-export` job on the existing PostgreSQL job queue, priority below reminders | As proposed | |
| D-2 | Apache Commons CSV 1.11 with `CSVFormat.RFC4180`, UTF-8 with BOM; `InvoiceCsvWriter` owns columns, formats and the formula guard | As proposed | |
| D-3 | Download through an ownership check and a 302 to a 5-minute pre-signed URL on the EU bucket | As proposed | |
| `POST /api/v1/invoices/exports` | 202 with the export body; 400, 403, 404, 422, 429 with `Retry-After: 30` | As proposed, except `Retry-After: 60` | On staging a 12,400-row export takes about 40 s (Q.2, Q.6), so a client that retries after 30 s while three such exports run is declined again. 60 s matches what the message tells the user: wait for one to finish. |
| `GET /api/v1/invoices/exports/{id}` | Status body; 404 for an unknown id or another user's export | As proposed | |
| `GET /api/v1/invoices/exports` | Caller's exports of the last 48 h, newest first, up to 20 | As proposed | |
| `GET /api/v1/invoices/exports/{id}/download` | 302 to the pre-signed URL; 404, 409, 410; audit event `invoice.export.downloaded` | As proposed | |
| Job `invoice-export` | Payload `{exportId}`, 2 retries with 30 s backoff, FAILED after the last retry | As proposed | |
| Audit events | `invoice.export.created`, `invoice.export.downloaded`, `invoice.export.failed` | As proposed | |
| OpenAPI | Additive change to `ledgerly-v1.yaml`, no version bump, column set documented on the download endpoint | As proposed | |
| Table `invoice_export` | Flyway `V2026_10_21_001__create_invoice_export.sql`, 18 columns | As proposed | |
| Column `user_id` | `uuid` not null, FK `app_user`, the requester and only reader | `requester_user_id`, same type and FK | Migration review: the codebase names a user FK after its role (`saved_view.owner_user_id`), and a bare `user_id` on a multi-tenant table reads as "the user the row belongs to". The `InvoiceExport` entity, the repository queries and the three indexes follow the rename. No API field changes. |
| Indexes | `(user_id, created_at DESC)`; partial `(user_id) WHERE status IN ('QUEUED','RUNNING')`; `(status, expires_at)` | As proposed, on `requester_user_id` | Follows the column rename above. |
| Retention | File deleted and row set to EXPIRED at `expires_at`; row deleted 30 days after `created_at`; hourly clean-up | As proposed | |
| Other tables | No change to `invoice`, `saved_view` or `job_queue`; no backfill | As proposed | |
| Rollout: flag | `invoice-csv-export`, default off; off means no button and 404 on the endpoints | As proposed | |
| Rollout: order | Migration, backend, frontend; each side tolerates the other being behind | As proposed | |
| Rollout: enablement | Internal organisation on staging and production, then the three design partners, then everyone one week later if the error rate stays under 1% | As proposed | |
| Rollout: rollback | Flag off; in-flight exports finish or fail harmlessly; files expire on their own | As proposed | |
| Rollout: walkthrough | 15-minute walkthrough of the dashboard panel for finance operations before the general rollout | Held on 2026-10-24 on staging, before the design-partner step | Finance operations asked to watch the panel while the design partners generate real exports rather than learn it the week everyone gets the feature. Same content, earlier date. |
| FT-1 | Overridden: the nightly batch cannot meet the 10 s and 2 min outcomes; the monitoring need is met by the "Invoice exports" panel and shared alert routing | As proposed | |

## Behaviour delivered

Backend files are under `src/main/java/com/ledgerly/invoices/export/` and frontend files under `web/src/` unless a
full path is given.

| AC | Scenario | Where it lives | Verified by |
|----|----------|----------------|-------------|
| AC-1 | invoice-export › Export current filter › Successful export; invoice-list › List actions › Export CSV shows the current count | `web/src/features/invoices/ExportButton.tsx`, then `src/main/java/com/ledgerly/invoices/export/InvoiceExportService.java` | `InvoiceExportWorkerIT#writesExactlyTheFilteredInvoicesInListOrder`, `web/e2e/invoice-export.spec.ts`, Q.1 |
| AC-2 | invoice-export › Background export › Large export continues while the user works | `InvoiceExportWorker.java`; `features/invoices/useInvoiceExport.ts` | `InvoiceExportWorkerIT#updatesRowsWrittenEvery500Rows`, `useInvoiceExport.test.ts`, Q.2 |
| AC-3 | invoice-export › Export current filter › Saved view is exported | `InvoiceExportService.java` (`resolveSavedView`) | `InvoiceExportServiceSavedViewTest`, `invoice-export.spec.ts`, Q.3 |
| AC-4 | invoice-export › Export current filter › Filter matches no invoices | `InvoiceCsvWriter.java` | `InvoiceCsvWriterTest#writesHeaderOnlyWhenNoRows`, `ExportButton.test.tsx`, Q.4 |
| AC-5 | invoice-export › Export size limit › Filter exceeds the limit; Filter at the limit | `InvoiceExportService.java` (`assertRowLimit`) | `InvoiceExportServiceTest#rejectsAbove50000Rows`, `#acceptsExactly50000Rows`; `InvoiceExportControllerTest` (422 body), Q.5 |
| AC-6 | invoice-export › Concurrent exports › Fourth export is declined; Exports of two users stay separate | `InvoiceExportService.java` (`assertConcurrencyLimit`) and the partial index in the migration | `InvoiceExportServiceTest#declinesFourthExportInProgress`; `InvoiceExportControllerTest` (429 with `Retry-After`, list shows own exports only), Q.6 |
| AC-7 | invoice-export › Export permissions › Read-only accountant exports; User without invoice access; invoice-list › List actions › Read-only accountant sees only the actions she can use | `InvoiceExportService.java` (`invoices:read` check, `EntityAccessFilter` on count and stream); `features/invoices/ExportButton.tsx` | `InvoiceExportServiceTest#limitsRowsToAccessibleEntities`; `InvoiceExportControllerTest` (403); `InvoiceList.test.tsx`, Q.7 |
| AC-8 | invoice-export › Export file contents › Amounts stay in the invoice currency | `InvoiceCsvWriter.java` (`formatAmount`) | `InvoiceCsvWriterTest`, golden file `mixed-currencies.csv`, Q.8 |
| AC-9 | invoice-export › Export file contents › Dates and timestamps | `InvoiceCsvWriter.java` (`formatDate`, `formatTimestamp`) | `InvoiceCsvWriterTest`, golden file `lisbon-paid-at.csv`, Q.9 |
| AC-10 | invoice-export › Export file contents › Values with commas, quotes and line breaks; Values that look like formulas | `InvoiceCsvWriter.java` (`guardFormula`) | `InvoiceCsvWriterTest`, golden file `owasp-injection.csv`, Q.10 |
| AC-11 | invoice-export › Background export › User leaves the page; Export retention › Download within 24 hours; Download after 24 hours; Only the requester can download | `components/ExportsIndicator.tsx`; `InvoiceExportController.java` (download); `InvoiceExportCleanupJob.java` | `ExportsIndicator.test.tsx`, `InvoiceExportDownloadIT`, `InvoiceExportCleanupJobTest`, `invoice-export.spec.ts`, Q.11 |
| AC-12 | invoice-export › Export file contents › Columns and header row; File name | `InvoiceCsvWriter.java` (`COLUMNS`); `InvoiceExportService.java` (`fileNameFor`) | `InvoiceCsvWriterTest#writesFifteenEnglishHeadingsInOrder`, `InvoiceExportServiceSavedViewTest#namesFileAfterViewInOrganisationTimeZone`, Q.12 |
| AC-13 | invoice-export › Background export › Export fails | `InvoiceExportWorker.java` (`onFailure`) | `InvoiceExportWorkerIT#deletesObjectAndMarksFailedOnStorageError`, `ExportButton.test.tsx`, Q.13 |

## Deviations and deferred work

- **Unchecked tasks:** none. All 24 implementation tasks and the 16 QA verification tasks in `tasks.md` are checked.
- **Surfaced during implementation, resolved without changing scope:**
  - `OpenApiContractTest` failed on the download endpoint because the contract checker wants a response entry for
    every documented status and the `302` had none. Added an explicit empty `302` response with the `Location`
    header to `ledgerly-v1.yaml` within task 3.4. No behaviour change.
  - Q.14 found the More actions menu item 40 px tall on iPad in landscape. Fixed in task 4.5 (minimum 44 px in
    both orientations) and re-checked.
  - The two open engineering questions in the proposal are closed by the load test (5.3, Q.15): the streaming
    query stays on the primary (invoice list p95 362 ms under 20 concurrent exports, bar 400 ms) and the fetch size
    stays at 500 (1,000 made no measurable difference on the 50,000-row export).
- **FT-1 (use the nightly batch job):** stays overridden, as approved in the tech proposal and agreed with
  Mariana Costa. Exports run on the job queue, and finance operations see them where they already look: the
  "Invoice exports" panel sits next to the nightly batch panel on "Ledgerly Ops" (5.1), failures route to the same
  channel (5.2), and Q.16 confirmed on staging that a forced failure reaches the panel and fires the alert within a
  minute. The walkthrough has been held (see the rollout rows above).
- **Product must know:**
  - The file holds what the filter matches when the export runs, so its row count can differ from the number on
    the button if invoices change in between. Accepted in the proposal's risks and stated in the release note.
  - The filter comment line (non-blocking Question for Product) is not in the file, as the proposal assumed. The
    question stays open on BILL-142 until 2026-11-07; a yes becomes a separate change.
  - The `Retry-After` change is invisible to users. The message stays "You already have 3 exports in progress.
    Wait for one to finish and try again."

## How to review

1. `src/main/resources/openapi/ledgerly-v1.yaml`: the four endpoints, the error codes and the column set, the whole contract on one page.
2. `src/main/resources/db/migration/V2026_10_21_001__create_invoice_export.sql`: the table, the renamed column and the three indexes.
3. `src/main/java/com/ledgerly/invoices/export/InvoiceExportController.java`: thin entry point, error mapping, `Retry-After`.
4. `src/main/java/com/ledgerly/invoices/export/InvoiceExportService.java`: validation order (permission, saved view, count, concurrency), filter snapshot, audit.
5. `src/main/java/com/ledgerly/invoices/export/InvoiceExportWorker.java`: streaming read, progress every 500 rows, failure path that deletes the object first.
6. `src/main/java/com/ledgerly/invoices/export/InvoiceCsvWriter.java` with `src/test/resources/csv/*.csv`: columns, number and date formats, formula guard; the golden files are the readable contract.
7. `src/main/java/com/ledgerly/invoices/export/InvoiceExportCleanupJob.java`: retention, idempotent.
8. `web/src/features/invoices/ExportButton.tsx` and `useInvoiceExport.ts`: states and messages, polling, automatic download.
9. `web/src/components/ExportsIndicator.tsx`: top-bar list, Download and Expired states, popover focus trap.
10. Tests last: `InvoiceExportWorkerIT`, `InvoiceExportDownloadIT`, `web/e2e/invoice-export.spec.ts`; then `ops/grafana/ledgerly-ops.json` and `ops/alerts/invoice-export.yaml`.

## Verification

Automated, all green in CI on the final commit:

- `./mvnw verify`: 1,274 tests, 0 failures, 0 errors, 0 skipped. 53 new: `InvoiceExportRepositoryTest` (3),
  `JobTypeRegistryTest#registersInvoiceExportWithRetryPolicy` (1), `FeatureFlagServiceTest` (1),
  `InvoiceExportServiceTest` (9), `InvoiceExportServiceSavedViewTest` (4), `InvoiceCsvWriterTest` (12, golden files
  including the OWASP payloads), `InvoiceExportWorkerIT` (5, Testcontainers PostgreSQL, including the injected
  storage failure), `InvoiceExportCleanupJobTest` (3), `InvoiceExportControllerTest` (8), `InvoiceExportDownloadIT`
  (5), `StorageConfigTest` (2). `OpenApiContractTest` passes against the updated `ledgerly-v1.yaml`.
- `cd web && npm test`: 418 tests, 0 failures. 29 new across `flags.test.ts`, `InvoiceList.test.tsx`,
  `useInvoiceExport.test.ts`, `ExportButton.test.tsx` and `ExportsIndicator.test.tsx`, axe assertions included.
- `cd web && npm run i18n:check`: en, de, fr and pt complete, 14 new keys each.
- `cd web && npx playwright test e2e/invoice-export.spec.ts`: 3 scenarios pass on Chromium and WebKit (filtered
  export, saved view "Overdue Q3", navigate away and download from the indicator).
- `promtool test rules ops/alerts/invoice-export.test.yaml`: SUCCESS, 4 cases.
- `k6 run perf/invoice-export.js` against staging (5.3): 50,000-row export in 1 min 38 s (target 2 min); 20
  concurrent 2,000-row exports, slowest 7.2 s (target 10 s); invoice list p95 362 ms during the run (target 400 ms).
  Results attached to BILL-142.

QA verification by Daniel Okafor on staging (EU), 2026-10-23, all Pass. The full observations are on the Q lines
in `tasks.md`.

| Q | AC | Environment | Result |
|---|----|-------------|--------|
| Q.1 | AC-1 | Chrome 130, iPad Safari 18, fin.controller | 1,284 rows in list order, downloaded in 4 s, list usable |
| Q.2 | AC-2 | Chrome 130, fin.manager | 12,400 rows, preparing message at once, progress shown, ready in 41 s |
| Q.3 | AC-3 | Chrome 130, accountant.ro | 2,117 rows, `invoices-overdue-q3-2026-10-23-1017.csv` |
| Q.4 | AC-4 | Chrome 130, customer with no invoices | One-line file, headings-only message |
| Q.5 | AC-5 | Chrome 130, all entities and dates | 422 with 62,310 and the 50,000 limit, button enabled; 50,000-row filter exported |
| Q.6 | AC-6 | Two browsers, fin.manager and fin.controller | Fourth declined with "3 exports in progress"; files and lists separate |
| Q.7 | AC-7 | accountant.ro, sales | Entities A and B only; no button and 403 for sales |
| Q.8 | AC-8 | Excel 365, Google Sheets | Own currency per row, 1250.00 and 125000, no total rows, read as numbers |
| Q.9 | AC-9 | Browser in Europe/Berlin | Dates unchanged, Paid at `2026-09-30T23:30:00+01:00`, range filter matched the list |
| Q.10 | AC-10 | Excel 365 for Windows, Excel for Mac, Google Sheets, Numbers | EC-7 values in single cells, `=SUM(A1:A9)` as text, accents intact |
| Q.11 | AC-11 | Chrome 130, test expire endpoint | File waiting after tab close; 410 and Expired after expiry; 404 on another user's id |
| Q.12 | AC-12 | Interface in German | 15 English headings in order, file names in Europe/Lisbon time |
| Q.13 | AC-13 | Storage failure toggle | Failed message, Try again worked, no object in the bucket, slot freed |
| Q.14 | EC-1 to EC-9 | Chrome, Firefox, iPad Safari both orientations | One finding (40 px menu item), fixed in 4.5, re-checked |
| Q.15 | Non-functional | k6, pre-signed URL host, axe, VoiceOver, keyboard | Load targets met, host in eu-central-1, axe clean, passes recorded |
| Q.16 | Observability | Grafana "Ledgerly Ops", finance-ops channel | Forced failure on the "Invoice exports" panel and alert within a minute |

Manual checks attached to this PR: VoiceOver recording on iPad Safari (button, toasts, Exports popover), keyboard-only
pass on desktop, screenshot of the "Invoice exports" panel on staging (5.1), and `GET /api/v1/flags` on staging
showing `invoice-csv-export: true` for the internal organisation (5.5).

## Rollout

- **Flag:** `invoice-csv-export` in `FeatureFlagService`, default off (`ledgerly.flags.invoice-csv-export: false`),
  read by the frontend through `GET /api/v1/flags`. Off: no button, the endpoints return 404, the table and the
  job type sit dark. On today for the Ledgerly internal organisation on staging only (5.5).
- **Migration:** `V2026_10_21_001__create_invoice_export.sql`, additive, applied by Flyway on backend start-up
  before the new code serves traffic. Nothing in the old code reads the table, so it is safe ahead of the deploy.
- **Order:** migration, backend, frontend. An old frontend against a new backend ignores the new flag; a new
  frontend against an old backend gets no `invoice-csv-export` flag and renders nothing.
- **Configuration:** no change to storage; exports use the existing bucket and `ledgerly.storage.region:
  eu-central-1` (`StorageConfigTest` on the prod and staging profiles). New: `ops/alerts/invoice-export.yaml`
  (failure rate above 5% over 15 min, queue age above 60 s, routed to the finance-ops channel) and the "Invoice
  exports" panel in `ops/grafana/ledgerly-ops.json`. `JobTypeRegistry` gains the `invoice-export` type; the worker
  thread count is unchanged.
- **Enablement after merge:** internal organisation on production, then the three design partner organisations
  named on BILL-142, then everyone one week later if the error rate stays under 1%. The finance operations
  walkthrough is already done (2026-10-24).
- **Backward compatibility:** `GET /api/v1/invoices` unchanged; `ledgerly-v1.yaml` additive, no version bump; no
  change to `invoice`, `saved_view` or `job_queue`; no backfill.
- **Rollback:** turn the flag off. In-flight exports finish or fail harmlessly, files expire on their own and the
  clean-up job keeps running. The table can stay; if it must go, `DROP TABLE invoice_export` is the whole rollback
  of the migration, nothing else references it.

## Release note

- **Shipped:** Export CSV on the invoice list for every user who can view invoices. It exports what the list shows (up to 50,000 rows, 15 fixed columns), prepares large exports in the background with progress in the new Exports indicator, keeps each file for 24 hours for its requester, and works for saved views. Behind the flag `invoice-csv-export`, rolled out in stages starting with the internal organisation. The file holds what the filter matches when the export runs, so the row count can differ from the number on the button if invoices changed in between.
- **Capabilities:** `invoice-export` added (export current filter, file contents, size limit, background export, concurrent exports, permissions, retention); `invoice-list` modified (List actions gains Export CSV with the current count, offered from More actions on narrow screens).
- **Deferred:** nothing from the feature definition. Not included, as the tech proposal assumed: a first line in the file stating the applied filters and the export time. That question is open on BILL-142 until 2026-11-07 and a yes becomes a separate change.
