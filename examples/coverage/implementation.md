## Coverage: implementation versus tech proposal and feature definition

**Change:** `espec/changes/bill-142-invoice-csv-export/` · **Tasks:** 40/40 · **Match:** 13 of 13 acceptance criteria delivered (100%), 0 partial, 0 not delivered · Proposal: 17 items as proposed, 4 differ with a reason, 0 differ without a reason or not implemented

Re-read from disk after writing `pull-request.md`: `feature.md`, `tech-proposal.md`, `specs/invoice-export/spec.md`,
`specs/invoice-list/spec.md`, `tasks.md`. Test results are from this session: `./gradlew test integrationTest`
(312 passed), `npm test` (148 passed), `npm run e2e` (4 passed), `promtool test rules` (passed). Q.1 to Q.16 were
checked by QA on staging on 2026-10-23 and re-read from `tasks.md`.

| AC | Scenario | Where it lives | Test | Q.n | Status | Gap |
|----|----------|----------------|------|-----|--------|-----|
| AC-1 | invoice-export › Export current filter › Successful export; invoice-list › List actions › Export CSV shows the current count | `web/src/features/invoices/ExportButton.tsx`; `src/main/java/com/ledgerly/invoices/export/InvoiceExportService.java` | `InvoiceExportWorkerIT#writesExactlyTheFilteredInvoicesInListOrder`, `web/e2e/invoice-export.spec.ts`, passed | Q.1 checked | Delivered | |
| AC-2 | invoice-export › Background export › Large export continues while the user works | `InvoiceExportWorker.java`; `useInvoiceExport.ts` | `InvoiceExportWorkerIT#updatesRowsWrittenEvery500Rows`, `useInvoiceExport.test.ts`, passed | Q.2 checked | Delivered | |
| AC-3 | invoice-export › Export current filter › Saved view is exported | `InvoiceExportService.java` (`resolveSavedView`) | `InvoiceExportServiceSavedViewTest`, `invoice-export.spec.ts`, passed | Q.3 checked | Delivered | |
| AC-4 | invoice-export › Export current filter › Filter matches no invoices | `InvoiceCsvWriter.java` | `InvoiceCsvWriterTest#writesHeaderOnlyWhenNoRows`, `ExportButton.test.tsx`, passed | Q.4 checked | Delivered | |
| AC-5 | invoice-export › Export size limit › Filter exceeds the limit; Filter at the limit | `InvoiceExportService.java` (`assertRowLimit`) | `InvoiceExportServiceTest#rejectsAbove50000Rows`, `#acceptsExactly50000Rows`, `InvoiceExportControllerTest`, passed | Q.5 checked | Delivered | |
| AC-6 | invoice-export › Concurrent exports › Fourth export is declined; Exports of two users stay separate | `InvoiceExportService.java` (`assertConcurrencyLimit`); partial index in `V2026_10_21_001__create_invoice_export.sql` | `InvoiceExportServiceTest#declinesFourthExportInProgress`, `InvoiceExportControllerTest`, passed | Q.6 checked | Delivered | |
| AC-7 | invoice-export › Export permissions › Read-only accountant exports; User without invoice access; invoice-list › List actions › Read-only accountant sees only the actions she can use | `InvoiceExportService.java` (`invoices:read` check); `ExportButton.tsx` | `InvoiceExportServiceTest#limitsRowsToAccessibleEntities`, `InvoiceExportControllerTest` (403), `InvoiceList.test.tsx`, passed | Q.7 checked | Delivered | |
| AC-8 | invoice-export › Export file contents › Amounts stay in the invoice currency | `InvoiceCsvWriter.java` (`formatAmount`) | `InvoiceCsvWriterTest`, golden file `mixed-currencies.csv`, passed | Q.8 checked | Delivered | |
| AC-9 | invoice-export › Export file contents › Dates and timestamps | `InvoiceCsvWriter.java` (`formatDate`, `formatTimestamp`) | `InvoiceCsvWriterTest`, golden file `lisbon-paid-at.csv`, passed | Q.9 checked | Delivered | |
| AC-10 | invoice-export › Export file contents › Values with commas, quotes and line breaks; Values that look like formulas | `InvoiceCsvWriter.java` (`guardFormula`) | `InvoiceCsvWriterTest`, golden file `owasp-injection.csv`, passed | Q.10 checked | Delivered | |
| AC-11 | invoice-export › Background export › User leaves the page; Export retention › Download within 24 hours; Download after 24 hours; Only the requester can download | `ExportsIndicator.tsx`; `InvoiceExportController.java` (download); `InvoiceExportCleanupJob.java` | `ExportsIndicator.test.tsx`, `InvoiceExportDownloadIT`, `InvoiceExportCleanupJobTest`, `invoice-export.spec.ts`, passed | Q.11 checked | Delivered | |
| AC-12 | invoice-export › Export file contents › Columns and header row; File name | `InvoiceCsvWriter.java` (`COLUMNS`); `InvoiceExportService.java` (`fileNameFor`) | `InvoiceCsvWriterTest#writesFifteenEnglishHeadingsInOrder`, `InvoiceExportServiceSavedViewTest#namesFileAfterViewInOrganisationTimeZone`, passed | Q.12 checked | Delivered | |
| AC-13 | invoice-export › Background export › Export fails | `InvoiceExportWorker.java` (`onFailure`) | `InvoiceExportWorkerIT#deletesObjectAndMarksFailedOnStorageError`, `ExportButton.test.tsx`, passed | Q.13 checked | Delivered | |

| Proposal item | Status | Note |
|---------------|--------|------|
| D-1 Exports on the existing PostgreSQL job queue | As proposed | |
| D-2 Apache Commons CSV plus `InvoiceCsvWriter` | As proposed | |
| D-3 Download through a 5-minute pre-signed URL | As proposed | |
| `POST /api/v1/invoices/exports` | Differs, reason in pull-request.md | `Retry-After: 60` instead of 30; no change to the user-facing message or the specs |
| `GET /api/v1/invoices/exports/{id}` | As proposed | |
| `GET /api/v1/invoices/exports` | As proposed | 48-hour window, as in the approved proposal |
| `GET /api/v1/invoices/exports/{id}/download` | As proposed | |
| Job `invoice-export` | As proposed | |
| Audit events | As proposed | |
| OpenAPI | As proposed | An empty `302` response entry was added for the contract checker; recorded under Deviations |
| Table `invoice_export` | As proposed | |
| Column `user_id` | Differs, reason in pull-request.md | Renamed `requester_user_id`; entity, queries and indexes follow; no API or spec change |
| Indexes | Differs, reason in pull-request.md | Follow the column rename |
| Retention | As proposed | |
| Other tables | As proposed | |
| Rollout: flag | As proposed | |
| Rollout: order | As proposed | |
| Rollout: enablement | As proposed | |
| Rollout: rollback | As proposed | |
| Rollout: walkthrough | Differs, reason in pull-request.md | Held on 2026-10-24, before the design-partner step instead of before the general rollout |
| FT-1 | As proposed (Overridden) | Panel next to the nightly batch panel (5.1), shared alert routing (5.2), confirmed by Q.16 |

**Judgement:** Every acceptance criterion is delivered by code at the path named, proved by a test that passed in
this session and confirmed by QA on staging, so the implementation does what the specs say. Four proposal items
differ (the `Retry-After` value, the column rename and its indexes, the walkthrough date); each has a reason in
`pull-request.md`, none changes observable behaviour, so the delta specs stand as approved. The one open question
on the ticket (a filter comment line in the file) was assumed answered "no", as the proposal said, and is listed
under Deviations for product to confirm.
