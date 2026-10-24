# Archive clean report · 2026-10-24

**Scope:** espec/specs/ (4 capabilities, 17 requirements) · **Run by:** Priya Raghavan

## Summary

| Verdict | Count |
|---------|-------|
| Keep    | 14 |
| Update  | 2 |
| Purge   | 1 |

## Findings

### invoice-export

| Requirement | Verdict | Evidence | Proposed action |
|-------------|---------|----------|-----------------|
| Export current filter | Keep | `src/main/java/com/ledgerly/invoices/export/InvoiceExportService.java`, `InvoiceExportWorkerIT`, `web/e2e/invoice-export.spec.ts`; added by archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Export file contents | Keep | `InvoiceCsvWriter.java`, `InvoiceCsvWriterTest` golden files; archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Export size limit | Keep | `InvoiceExportService.create` (limit 50,000), `InvoiceExportServiceTest#refusesAboveRowLimit`; archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Background export | Keep | `InvoiceExportWorker.java`, `JobTypeRegistry` entry `invoice-export`, `useInvoiceExport.ts`; archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Concurrent exports | Keep | Partial index in `V2026_10_21_001__create_invoice_export.sql`, `InvoiceExportControllerTest#returns429OnFourthExport`; archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Export permissions | Keep | `EntityAccessFilter` applied in `InvoiceExportWorker`, `InvoiceExportControllerTest#forbidsSalesRole`; archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Export retention | Keep | `InvoiceExportCleanupJob.java`, `InvoiceExportDownloadIT#returns410AfterExpiry`; archived change `2026-10-24-bill-142-invoice-csv-export` | None |

### invoice-list

| Requirement | Verdict | Evidence | Proposed action |
|-------------|---------|----------|-----------------|
| List filters | Keep | `InvoiceSpecifications.java`, `useInvoiceFilters.ts`, `InvoiceList.test.tsx`; last modified by archived change `2026-05-14-bill-088-invoice-list-currency-filter` | None |
| List actions | Keep | `InvoiceList.tsx` toolbar, `ExportButton.tsx`, `InvoiceList.test.tsx`; last modified by archived change `2026-10-24-bill-142-invoice-csv-export` | None |
| Saved views | Keep | `SavedViewService.java`, `SavedViewPicker.tsx`, `SavedViewServiceTest`; added by archived change `2026-03-02-bill-061-saved-views` | None |

### payment-reminders

| Requirement | Verdict | Evidence | Proposed action |
|-------------|---------|----------|-----------------|
| Reminder schedule | Keep | `ReminderScheduler.java`, `ReminderSchedulerTest`; last modified by archived change `2026-09-12-bill-118-reminder-cadence` | None |
| Reminder content | Keep | `ReminderMailer.java`, templates under `src/main/resources/templates/reminders/`, `ReminderMailerTest` | None |
| Reminder opt-out | Update | Behaviour implemented in `ReminderOptOutService.java` and covered by `ReminderOptOutTest`, but the requirement has no scenario. Scenario below is derived from `ReminderOptOutTest#stopsRemindersForOptedOutCustomer` and `#resumesAfterOptOutIsLifted` | Replace the requirement block with the corrected text below |
| Legacy SMS reminders | Purge | Requirement text says "deprecated, sunset 2026-06-30". `SmsReminderSender.java` and `SmsReminderSenderTest` were deleted by archived change `2026-07-02-bill-103-remove-sms-reminders`; no route, flag or template mentions SMS; no active change references it | Remove the requirement block |

Corrected text for **Reminder opt-out**:

```markdown
### Requirement: Reminder opt-out
The system SHALL stop sending payment reminders to a customer that has been marked as opted out, and SHALL
resume them when the opt-out is lifted.

#### Scenario: Opted-out customer receives no reminders
- **GIVEN** a customer is marked as opted out of reminders
- **WHEN** one of its invoices reaches a reminder date
- **THEN** no reminder is sent
- **AND** the skipped reminder is recorded on the invoice timeline

#### Scenario: Reminders resume after the opt-out is lifted
- **GIVEN** a customer's opt-out is lifted
- **WHEN** one of its invoices next reaches a reminder date
- **THEN** the reminder is sent as scheduled
```

### customer-statements

| Requirement | Verdict | Evidence | Proposed action |
|-------------|---------|----------|-----------------|
| Statement generation | Keep | `NightlyStatementJob.java`, `StatementGeneratorTest`; added by archived change `2025-11-20-bill-034-customer-statements` | None |
| Statement delivery | Update | Requirement text says statements are emailed "with the PDF and a CSV attached". `StatementMailer.java` attaches only the PDF; the CSV attachment was dropped by archived change `2026-06-03-bill-097-drop-csv-statements`, whose delta removed the "Statement CSV attachment" requirement but did not modify this one. `StatementMailerTest#attachesPdfOnly` confirms | Replace the requirement block with the corrected text below |
| Statement period | Keep | `StatementPeriod.java`, `StatementPeriodTest`; added by archived change `2025-11-20-bill-034-customer-statements` | None |

Corrected text for **Statement delivery**:

```markdown
### Requirement: Statement delivery
The system SHALL email each generated statement to the customer's statement contacts with the statement PDF
attached.

#### Scenario: Statement is emailed with the PDF attached
- **GIVEN** a statement has been generated for a customer with two statement contacts
- **WHEN** delivery runs
- **THEN** each contact receives one email with the statement PDF attached
- **AND** the delivery is recorded on the customer timeline

#### Scenario: Customer without statement contacts
- **GIVEN** a statement has been generated for a customer with no statement contacts
- **WHEN** delivery runs
- **THEN** no email is sent
- **AND** the statement is flagged as undelivered on the customer timeline
```

## Other findings

- Capabilities with a TBD purpose: none.
- Duplicate requirement names: none.
- Requirements without scenarios: payment-reminders › Reminder opt-out (handled as Update above).
- Archived changes eligible for pruning: none. `archive.clean.prune_archived_changes_older_than_days` is 0.

## Applied actions

Confirmed by Priya Raghavan on 2026-10-24: "Apply all".

- Update: replaced `### Requirement: Reminder opt-out` in `espec/specs/payment-reminders/spec.md` with the corrected text (two scenarios added).
- Purge: removed `### Requirement: Legacy SMS reminders` from `espec/specs/payment-reminders/spec.md`.
- Update: replaced `### Requirement: Statement delivery` in `espec/specs/customer-statements/spec.md` with the corrected text.
- Keep: 14 requirements left unchanged across `espec/specs/invoice-export/spec.md`, `espec/specs/invoice-list/spec.md`, `espec/specs/payment-reminders/spec.md` and `espec/specs/customer-statements/spec.md`.
- Prune: nothing to prune.
- Post-check: 16 requirements remain, every one has at least one scenario, requirement names are unique within each capability. Skipped: nothing.
