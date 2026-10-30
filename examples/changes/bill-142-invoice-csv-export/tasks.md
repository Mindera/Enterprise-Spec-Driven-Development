# Tasks

## 1. Data model, job type and feature flag

- [x] 1.1 Add Flyway migration `V2026_10_21_001__create_invoice_export.sql` creating `invoice_export` with its three indexes, plus the `InvoiceExport` entity and `InvoiceExportRepository` (covers AC-6, AC-11) and verify `InvoiceExportRepositoryTest` passes on Testcontainers PostgreSQL
- [x] 1.2 Register the `invoice-export` job type in `JobTypeRegistry` with payload `{exportId}`, priority below reminders, 2 retries with 30 s backoff (covers AC-2, AC-13) and verify `JobTypeRegistryTest#registersInvoiceExportWithRetryPolicy`
- [x] 1.3 Add feature flag `invoice-csv-export` to `FeatureFlagService` and `GET /api/v1/flags`, default off (rollout) and verify `FeatureFlagServiceTest` and `web/src/lib/flags.test.ts`

## 2. Export service and CSV writer

- [x] 2.1 Implement `InvoiceExportService.create`: `invoices:read` check, entity-scoped count, 50,000 row limit, three exports per user in progress, insert the row, enqueue the job, write `invoice.export.created` to the audit log (covers AC-1, AC-5, AC-6, AC-7) and verify `InvoiceExportServiceTest`
- [x] 2.2 Resolve `savedViewId` to the view's stored filter, snapshot the view name and derive `invoices-<view>-YYYY-MM-DD-HHMM.csv` in the organisation's time zone (covers AC-3, AC-12) and verify `InvoiceExportServiceSavedViewTest`
- [x] 2.3 Implement `InvoiceCsvWriter`: fixed 15 columns with English headings, UTF-8 with BOM, RFC 4180 quoting, formula guard, amounts in the invoice currency with its minor units, dates as YYYY-MM-DD and timestamps in the organisation's zone with offset (covers AC-8, AC-9, AC-10, AC-12) and verify `InvoiceCsvWriterTest` golden files including the OWASP injection payloads
- [x] 2.4 Write a header-only file when the filter matches no invoices (covers AC-4) and verify `InvoiceCsvWriterTest#writesHeaderOnlyWhenNoRows`
- [x] 2.5 Implement `InvoiceExportWorker`: claim the job, stream invoices through `InvoiceSpecifications` and `EntityAccessFilter` with fetch size 500, write to `BlobStore` at `exports/{organisationId}/{exportId}.csv`, update `rows_written` every 500 rows, mark READY, on failure delete the object and mark FAILED with `invoice.export.failed` (covers AC-2, AC-11, AC-13) and verify `InvoiceExportWorkerIT` including the injected storage failure case
- [x] 2.6 Implement `InvoiceExportCleanupJob`: hourly, delete files past `expires_at`, mark rows EXPIRED, delete rows older than 30 days, idempotent (covers AC-11) and verify `InvoiceExportCleanupJobTest`

## 3. API

- [x] 3.1 Add `POST /api/v1/invoices/exports` returning 202 with the export body and mapping 400, 403, 404, 422 and 429 with `Retry-After` (covers AC-1, AC-3, AC-5, AC-6, AC-7) and verify `InvoiceExportControllerTest`
- [x] 3.2 Add `GET /api/v1/invoices/exports/{id}` and `GET /api/v1/invoices/exports` (requester's exports of the last 48 h, newest first, max 20), 404 for another user's export (covers AC-2, AC-6, AC-11) and verify `InvoiceExportControllerTest`
- [x] 3.3 Add `GET /api/v1/invoices/exports/{id}/download`: ownership check, 302 to a 5-minute pre-signed URL with `Content-Disposition`, 409 while not ready or failed, 410 after expiry, `invoice.export.downloaded` audit event (covers AC-7, AC-11) and verify `InvoiceExportDownloadIT`
- [x] 3.4 Document the four endpoints, error codes and the CSV column set in `src/main/resources/openapi/ledgerly-v1.yaml` and verify `OpenApiContractTest`

## 4. Frontend

- [x] 4.1 Add `ExportButton.tsx` to the `InvoiceList.tsx` toolbar with the label `Export CSV (n)` bound to the list total, rendered only with the flag and `invoices:read`, moved into More actions below 900 px (covers AC-1, AC-7) and verify `InvoiceList.test.tsx`
- [x] 4.2 Add `useInvoiceExport.ts`: create, poll every 2 s backing off to 5 s, start the download automatically when READY and the user is still on the list, show the preparing message after 10 s or at once above 2,000 rows (covers AC-1, AC-2) and verify `useInvoiceExport.test.ts`
- [x] 4.3 Add the messages and states from the UI design section: empty result, row limit with count, concurrency limit, no permission, failed with Try again, expired, in en, de, fr and pt (covers AC-4, AC-5, AC-6, AC-7, AC-13) and verify `ExportButton.test.tsx` and the locale completeness check `npm run i18n:check`
- [x] 4.4 Add `ExportsIndicator.tsx` to the top bar: exports of the last 48 h with progress, Download and Expired states, kept across navigation (covers AC-2, AC-11) and verify `ExportsIndicator.test.tsx`
- [x] 4.5 Accessibility: live-region announcements for preparing, ready and failed, focus kept in place, popover focus trap and Escape, 44 px targets on tablet (UI design section) and verify axe assertions in the tests above plus a VoiceOver pass on iPad Safari recorded in the PR
- [x] 4.6 Add Playwright `web/e2e/invoice-export.spec.ts`: export a filtered list, export the saved view "Overdue Q3", navigate away during an export and download it from the indicator (covers AC-1, AC-3, AC-11) and verify the e2e suite passes in CI

## 5. Observability, performance and rollout

- [x] 5.1 Tag `ledgerly_job_*` metrics with `type="invoice-export"`, add `ledgerly_invoice_export_rows_total`, and add an "Invoice exports" panel next to the nightly batch panel in `ops/grafana/ledgerly-ops.json` (FT-1 override) and verify the panel renders on staging with a screenshot in the PR
- [x] 5.2 Add the alert rule for failure rate above 5% over 15 min and queue age above 60 s to `ops/alerts/invoice-export.yaml`, routed to the same channel as the nightly batch alert (non-functional) and verify `promtool test rules ops/alerts/invoice-export.test.yaml`
- [x] 5.3 Run the k6 load test `perf/invoice-export.js` on staging: one 50,000-row export under 2 min and 20 concurrent 2,000-row exports each under 10 s while the invoice list p95 stays under 400 ms (constraints) and verify the results are attached to BILL-142
- [x] 5.4 Add `StorageConfigTest` asserting the export bucket region is `eu-central-1` for the prod and staging profiles (constraint: data residency) and verify the test passes in CI
- [x] 5.5 Enable `invoice-csv-export` for the internal organisation on staging and draft the release note for BILL-142 (rollout) and verify the flag reads true in `GET /api/v1/flags` on staging

## QA verification

- [x] Q.1 Verify AC-1 Export the current filter on staging. 2026-10-23, Chrome 130 and iPad Safari 18, fin.controller: 1,284 rows, order matched the list, downloaded in 4 s, list stayed usable. Pass.
- [x] Q.2 Verify AC-2 A large export runs in the background on staging. 2026-10-23, fin.manager, 12,400 rows: preparing message at once, progress visible, ready in 41 s, list and customer pages responsive. Pass.
- [x] Q.3 Verify AC-3 Export a saved view on staging. 2026-10-23, accountant.ro, "Overdue Q3": 2,117 rows matched the view, file named invoices-overdue-q3-2026-10-23-1017.csv. Pass.
- [x] Q.4 Verify AC-4 Empty result on staging. 2026-10-23, customer with no invoices: one-line file, message "No invoices matched your filters. The file contains column headings only." Pass.
- [x] Q.5 Verify AC-5 Row limit on staging. 2026-10-23, all entities, all dates: 422, message with 62,310 and the 50,000 limit, button still enabled; seeded 50,000-row filter exported. Pass.
- [x] Q.6 Verify AC-6 Concurrent exports on staging. 2026-10-23, three 12,400-row exports then a fourth: declined with "You already have 3 exports in progress"; fin.manager and fin.controller exporting at the same time got separate files, neither listed the other's export. Pass.
- [x] Q.7 Verify AC-7 Permissions on staging. 2026-10-23, accountant.ro with no entity filter: file held entities A and B only; sales: no button, API returned 403. Pass.
- [x] Q.8 Verify AC-8 Multiple currencies on staging. 2026-10-23, EUR, GBP and JPY rows: own currency code per row, 1250.00 and 125000 formats, no total rows, opened as numbers in Excel 365 and Google Sheets. Pass.
- [x] Q.9 Verify AC-9 Dates and time zones on staging. 2026-10-23, browser set to Europe/Berlin: issue and due dates unchanged, Paid at 2026-09-30T23:30:00+01:00, date range filter matched the list. Pass.
- [x] Q.10 Verify AC-10 Special characters on staging. 2026-10-23, Excel 365 for Windows, Excel for Mac, Google Sheets, Numbers: Müller, Söhne & Co. "Nord" and the line-break reference in single cells, =SUM(A1:A9) shown as text, accents intact. Pass.
- [x] Q.11 Verify AC-11 Leaving the page on staging. 2026-10-23: navigated away and closed the tab mid-export, file waiting in the Exports indicator on return; after the test expire endpoint the download returned 410 and the indicator showed Expired; fin.controller got 404 on fin.manager's export id. Pass.
- [x] Q.12 Verify AC-12 File columns and name on staging. 2026-10-23: 15 headings in the specified order, English headings with the interface in German, file names invoices-2026-10-23-1009.csv and invoices-overdue-q3-2026-10-23-1017.csv in Europe/Lisbon time. Pass.
- [x] Q.13 Verify AC-13 Failed export on staging. 2026-10-23, storage failure toggle on: export marked failed with "We couldn't prepare your export. Nothing was downloaded.", Try again worked after the toggle was removed, no file in the bucket, a new export was accepted while the failed one was still listed. Pass.
- [x] Q.14 Exploratory pass over edge cases EC-1 to EC-9 on staging, desktop Chrome and Firefox, iPad Safari in both orientations. 2026-10-23: one finding, the More actions menu item was 40 px tall in landscape, fixed in task 4.5 and re-checked. Pass.
- [x] Q.15 Non-functional checks from the test strategy. 2026-10-23: load test 50,000 rows in 1 min 38 s, 20 concurrent 2,000-row exports max 7.2 s, list p95 362 ms; pre-signed URL host in eu-central-1; axe clean; VoiceOver and keyboard-only passes recorded in the PR. Pass.
- [x] Q.16 Observability check on staging. 2026-10-23: one forced failure appeared on the "Invoice exports" panel next to the nightly batch panel within a minute and the alert fired to the finance-ops channel. Pass.
