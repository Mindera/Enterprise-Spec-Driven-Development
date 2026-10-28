# Technical assessment · Export invoices as CSV (BILL-142)

**Source:** espec/changes/bill-142-invoice-csv-export/feature.md, identical to BILL-142 fetched 2026-10-21 · **Repository:** main at `c41f9e2`, read 2026-10-21 · **Outcome:** Further discovery required (1 blocking, 4 advisory)

## What exists today

Read `espec/project.md` (Java and Spring backend, React frontend, PostgreSQL, tests in `src/test/java` and
`web/src/**/*.test.tsx`), then the modules behind each acceptance criterion and constraint. Every path below was
opened; "nothing found" means a search of the backend, the frontend and the tests returned nothing.

| Id | Exists today | Missing or must change | Evidence |
|----|--------------|------------------------|----------|
| AC-1 Export the current filter | The list filter is already a serialisable value: `InvoiceFilter` (status, customer, legal entity, issue date range, currency, search) is sent as query parameters to `GET /api/v1/invoices`, which pages 50 rows at a time. The list knows the total count of the current filter. | Nothing writes CSV. No export endpoint, no toolbar action, no way to read more than one page at a time. | `src/main/java/com/ledgerly/invoices/InvoiceFilter.java`, `InvoiceController.java`, `InvoiceSpecifications.java`, `web/src/features/invoices/InvoiceList.tsx`, `useInvoiceFilters.ts` |
| AC-2 Large export in the background | A PostgreSQL-backed job queue with per-type retry policies, two worker threads per node and metrics per job type (`ledgerly_job_duration_seconds`, `ledgerly_job_failures_total`, `ledgerly_job_queue_depth`), used today for payment reminders and statement generation. The frontend already polls a job status for reminders. | No export job type, no progress counter, no Exports indicator in the top bar, no per-user list of jobs. | `src/main/java/com/ledgerly/jobs/JobQueue.java`, `JobWorker.java`, `JobTypeRegistry.java`, `web/src/features/reminders/useJobStatus.ts` |
| AC-3 Export a saved view | Saved views store an `InvoiceFilter` as JSON per user with a name; the frontend applies a view by writing its filter into the URL. | Nothing resolves a view on the server for anything but the list. The file name rule does not exist. | `src/main/java/com/ledgerly/views/SavedViewService.java`, `web/src/features/invoices/SavedViewPicker.tsx` |
| AC-4 Empty result | The paged response carries `total`, so a zero count is known before an export starts. | The headings-only file and the message. | `InvoiceController.java`, `InvoiceList.tsx` |
| AC-5 Row limit | A count of the current filter is one `InvoiceRepository.count(Specification)` away; nothing enforces a limit today. | The limit, and the message with the matched count. | `src/main/java/com/ledgerly/invoices/InvoiceRepository.java` |
| AC-6 Concurrent exports | Jobs are isolated by payload and claimed one at a time (`FOR UPDATE SKIP LOCKED`). | The `job_queue` table has no user column, so "three in progress per user" needs its own record. Per-user listing. | `JobQueue.java`, `src/main/resources/db/migration` (no `job_queue.user_id`) |
| AC-7 Permissions | `EntityAccessFilter` adds the legal-entity predicate to every invoice query. `invoices:read` is held by `FINANCE_MANAGER`, `FINANCE_CONTROLLER` and `ACCOUNTANT_READONLY` and not by `SALES`. The list already shows each toolbar action only to users with its permission. | The permission check on the new endpoints and the hidden action for Sales. | `src/main/java/com/ledgerly/security/EntityAccessFilter.java`, `Role.java`, espec/specs/invoice-list/spec.md › List actions |
| AC-8 Multiple currencies | Invoices carry their own currency code and amounts; `currency` is already a list filter. | Number formatting for the file (dot decimal, no thousands separator, no totals). | `InvoiceFilter.java`; nothing found that formats numbers for export |
| AC-9 Dates and time zones | The list's issue-date filter already follows the organisation's time zone. Timestamps are stored with offset (`timestamptz`). | Date and timestamp formatting in the file. | espec/specs/invoice-list/spec.md › List filters › Date range follows the organisation's time zone, `InvoiceSpecifications.java` |
| AC-10 Special characters | Apache Commons CSV 1.11 is a dependency, used for bank statement imports only. | A CSV writer with RFC 4180 quoting and a formula guard. See finding 4. | `BankStatementParser.java`; nothing found that writes CSV |
| AC-11 Leaving the page | Jobs run on the server and survive the browser. `BlobStore` wraps S3-compatible storage. Invoice PDFs are already served through 15-minute pre-signed URLs with an ownership check. | A per-user list of exports, 24-hour expiry, ownership check on the new download. | `JobWorker.java`, `src/main/java/com/ledgerly/storage/BlobStore.java`, `PdfDownloadController.java` |
| AC-12 Columns and file name | Nothing found. | Column mapping, English headings, file naming in the organisation's time zone. | Nothing found |
| AC-13 Failed export | The queue retries per job type and counts failures. | A failed state the user can see, removal of any partial file, the slot freed. | `JobTypeRegistry.java`, `JobWorker.java` |
| Constraint: Data residency | Production storage is configured in `eu-central-1`; pre-signed URLs point at the bucket. | Whether anything outside the EU serves those URLs is not in this repository (dependency 1). | `src/main/resources/application-prod.yaml` (`ledgerly.storage.region`), `BlobStore.java` |
| Constraint: Devices | The toolbar already collapses into a More actions menu below 900 px. Invoice PDFs already download through a redirect to a pre-signed URL. | Nothing found about iPad Safari in particular; QA verifies that a CSV saves rather than opens there. | espec/specs/invoice-list/spec.md › List actions › Actions on narrow screens, `PdfDownloadController.java` |
| Constraint: Close week performance | Queue metrics and queue depth exist. The list query pages 50 rows. | Nothing streams 50,000 rows anywhere today, and nothing observed shows the production database's headroom in close week (spike 1). | `JobWorker.java`, `InvoiceRepository.java` |
| Constraint: Audit | `AuditLog` records actor, action, subject and payload; retention is handled centrally. | New audit actions for export and download (dependency 3 for retention). | `src/main/java/com/ledgerly/audit/AuditLog.java` |
| Constraint: Retention | `BlobStore` can delete an object; nothing deletes on a schedule. | An expiry clean-up. | `BlobStore.java` |
| Constraint: Language | Interface copy goes through the existing translation check (`npm run i18n:check`) for the four product languages. | English headings in the writer, whatever the user's language. | `web/package.json` (`i18n:check`) |
| Constraint: Timing | Feature flags exist on both sides for a dark launch. | A slot in the Q4 2026 train (dependency 4). | `FeatureFlagService.java` (`ledgerly.flags.*`), `web/src/lib/flags.ts` |

## Capabilities touched

| Capability | Spec | Requirements | Touch |
|------------|------|--------------|-------|
| invoice-list | espec/specs/invoice-list/spec.md | List actions | Modified: a new toolbar action, shown by permission like the existing ones |
| invoice-list | espec/specs/invoice-list/spec.md | List filters, Saved views | Read only: the export reuses the filters, the date-range time zone rule and the stored view filter |
| invoice-export | none | | New capability |

## Dependencies outside the repository

| Dependency | Needed for | Status | Owner to ask |
|------------|------------|--------|--------------|
| 1. Pre-signed URLs on the export bucket are served from the EU only: no CDN or edge outside the EU in front of it | Constraint: Data residency, AC-11 | Unconfirmed. `application-prod.yaml` shows where objects are stored, not how they are served | Platform team (project.md › Teams and ownership) |
| 2. An "Invoice exports" panel and failure alert on the "Ledgerly Ops" Grafana dashboard, next to the nightly batch panel | FT-1's reason: finance operations watch one dashboard | Unconfirmed. `ops/grafana/ledgerly-ops.json` lives in this repository, so engineering can add the panel; whether a panel meets the need behind FT-1 is for finance operations to say | Finance operations lead |
| 3. The central audit log keeps export entries carrying the filter and the row count, and one download entry per download, at close-week volume | Constraint: Audit | Unconfirmed. `AuditLog.java` accepts any payload; retention is "handled centrally" | Owner of the audit log |
| 4. A slot in the Q4 2026 release train before the code freeze of 5 December 2026 | Constraint: Timing | Unconfirmed | Release manager |

## Alternatives for product

| Alternative | Instead of | What product gains | What product gives up |
|-------------|------------|--------------------|-----------------------|
| Override FT-1: run exports on the existing job queue, whose metrics already feed "Ledgerly Ops", and add an export panel and alert next to the nightly batch ones | FT-1 as written: "Use the existing nightly batch job" | AC-1 and AC-2 as written (10 seconds, 2 minutes), exports at any hour, EC-8 for free because jobs outlive the browser | Nothing visible, if finance operations accept a second panel on the same dashboard (dependency 2) |
| Keep FT-1: exports are queued for the 02:00 UTC batch | The 10-second and 2-minute outcomes | The exact mechanism product asked for, and no new job type to operate | AC-1, AC-2 and Constraints › Close week performance as written: an export requested at 09:00 is ready the next morning. UC-1 ("within a few seconds") and UC-2 ("within two minutes") change, and the Loading states in the design go |

## Criteria that cannot be met as written

| Id | Why not | Outcome rephrasing |
|----|---------|--------------------|
| AC-1, AC-2, Constraints › Close week performance, with FT-1 as written | `NightlyStatementJob.java` is a Spring Batch job scheduled once at 02:00 UTC. A file produced by it cannot be ready "within 10 seconds" or "within 2 minutes" of a request made during the day | Either override FT-1 (see Alternatives) and keep the outcomes, or keep FT-1 and rephrase: "the file is ready the next morning and the user is told when" |
| AC-10, second AND | "shown as the text =SUM(A1:A9)" and "exactly as stored" pull against each other for values that start with `=`: the usual guard puts a character in front of the value, and Excel shows that character when it opens a CSV directly | Advisory only: "the reference never runs as a formula; a leading character may be visible in tools that show it". QA can test the criterion as written in Excel 365 and Google Sheets; product decides only if a tool shows the character |

## Spikes

| Spike | Proves | Criteria waiting on it |
|-------|--------|------------------------|
| 1. Stream 50,000 invoices from a production-sized database on staging while a close-week load profile runs against the invoice list (k6, one day) | Whether the 2-minute outcome and "the invoice list must stay as fast as it is today" hold with one streaming read and two workers per node, and whether a read replica or a smaller fetch size is needed | AC-2 (the 2-minute line), Constraints › Close week performance. Not blocking: the proposal can carry the result as a visible assumption and run the test before rollout |

No other spike. Whether iPad Safari saves a CSV offered through a redirect to a pre-signed URL, rather than opening
it, is a QA check and not a spike: PDFs already take that path today.

## Findings

| # | Severity | Finding | Where | Suggested fix |
|---|----------|---------|-------|---------------|
| 1 | Blocking | FT-1 asks for "the existing nightly batch job"; `NightlyStatementJob.java` runs once at 02:00 UTC, so an export requested at 09:00 is ready the next day, against "within 10 seconds" (AC-1), "within 2 minutes" (AC-2) and Constraints › Close week performance. The note and the outcomes cannot both stand | Forced technical notes › FT-1; AC-1; AC-2; Constraints › Close week performance | Decision for product: keep the note and rephrase the outcomes, or accept an override with exports on the same Ops dashboard (Alternatives, dependency 2) |
| 2 | Advisory | Nothing observed shows the production database's headroom for a 50,000-row streaming read during close week; the 2-minute outcome is a target to verify, not a fact | Constraints › Close week performance; AC-2 | Spike 1, or a load test before rollout, with the proposal carrying the assumption visibly |
| 3 | Advisory | Data residency is shown for storage (`eu-central-1`), not for serving: whether pre-signed URLs resolve through anything outside the EU is the platform team's to confirm | Constraints › Data residency | Ask the platform team; the proposal names the URL host it expects and a test for it |
| 4 | Advisory | AC-10 asks for values "exactly as stored" and for a formula-looking reference "shown as the text"; the usual formula guard adds a leading character that Excel shows when it opens a CSV directly | AC-10; EC-7 | The proposal states the guard it uses and what the user sees in each tool; product decides only if a tool shows the character |
| 5 | Advisory | The Q4 2026 release train and the 5 December freeze are a dependency on the release manager; no slot is reserved and the ticket names no date for the dark launch | Constraints › Timing | Ask the release manager; the proposal's Rollout carries the dates |

## Comment for the ticket

**espec technical assessment, 2026-10-21: Further discovery required (1 blocking, 4 advisory).** Read against
main at `c41f9e2`. Most of what the feature needs exists: the list filter is already a value we can pass around,
entity access is applied to every invoice query, saved views store a filter, a job queue with retries and metrics
runs payment reminders today, invoice PDFs already download through short-lived links from an EU bucket, and the
audit log takes any action. Nothing writes CSV yet, and nothing lists a user's jobs. One decision for product
before the tech proposal:

1. **FT-1 and the 10-second outcome.** The nightly batch runs once at 02:00 UTC, so an export requested at 09:00
   would be ready the next morning. Two options: keep FT-1 and rephrase AC-1, AC-2 and the close week constraint
   to "ready the next morning", or let engineering override FT-1 and run exports on the existing job queue, with
   an "Invoice exports" panel and alert next to the nightly batch panel on the same "Ledgerly Ops" dashboard,
   which is the need behind the note. Which?

Unconfirmed, not blocking, and we are asking: the platform team (export links served from the EU only), finance
operations (a panel on the same dashboard instead of the batch), the audit log owner (export and download entries
at close-week volume), the release manager (a slot in the Q4 2026 train before the 5 December freeze). One spike
proposed: a 50,000-row streaming read on staging under close-week load, to verify the 2-minute outcome; it can
run during implementation if product accepts it as a target to verify before rollout. AC-10's "shown as the text"
may show a leading character in Excel for values that start with =; QA will test it as written and we will come
back only if a tool shows it.

Engineering can start the tech proposal as soon as FT-1 is decided.
