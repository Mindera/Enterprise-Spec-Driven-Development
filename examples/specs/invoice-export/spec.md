# Invoice Export Specification

## Purpose

Invoice export lets a user who can view invoices take the invoices that match the current invoice list filters
out of Ledgerly as a CSV file, for reconciliation and reporting in other tools.

## Requirements

### Requirement: Export current filter
The system SHALL produce a CSV file holding exactly the invoices that match the filters applied to the invoice
list when the export is requested, limited to the invoices the requester is allowed to see.

#### Scenario: Successful export
- **GIVEN** a finance controller has the invoice list filtered to Status = Sent, Overdue and Issue date =
  2026-07-01 to 2026-09-30, showing 1,284 invoices
- **WHEN** she requests an export
- **THEN** a CSV file is produced with one row per invoice, 1,284 rows, in the order of the list
- **AND** no invoice outside the filter appears in the file

#### Scenario: Saved view is exported
- **GIVEN** the saved view "Overdue Q3" is applied and its filters are unchanged
- **WHEN** the user requests an export
- **THEN** the file holds the invoices that match the view's stored filters
- **AND** the file name includes the view name

#### Scenario: Filter matches no invoices
- **GIVEN** the applied filters match no invoices
- **WHEN** the user requests an export
- **THEN** a file holding only the header row is produced
- **AND** the user is told that no invoices matched and that the file contains column headings only

#### Scenario: Export is recorded
- **WHEN** an export is requested
- **THEN** the audit log holds an entry with the requester, the time, the filters used and the number of rows
- **AND** every download of the file adds an audit entry with the requester and the time

### Requirement: Export file contents
The system SHALL write a header row followed by one row per invoice, using a fixed set of columns with English
headings, so that the file opens in common spreadsheet tools without loss.

#### Scenario: Columns and header row
- **WHEN** a file is produced
- **THEN** the first row holds, in this order: Invoice number, Status, Customer, Customer number, Legal entity,
  Issue date, Due date, Currency, Net amount, Tax amount, Gross amount, Paid amount, Outstanding amount, Paid at,
  Payment reference
- **AND** the headings are in English whatever the user's interface language
- **AND** accented characters appear intact when the file is opened in Excel and in Google Sheets

#### Scenario: Amounts stay in the invoice currency
- **GIVEN** the filter matches invoices issued in EUR, GBP and JPY
- **WHEN** the file is produced
- **THEN** each row shows the invoice's own currency code and its amounts in that currency, with no conversion
- **AND** amounts use a dot as decimal separator, no thousands separator, and the number of decimals of the
  currency (1250.00 for EUR, 125000 for JPY)
- **AND** the file contains no total rows

#### Scenario: Dates and timestamps
- **GIVEN** an invoice issued on 2026-09-30 by a Lisbon legal entity and paid at 23:30 Lisbon time, exported by a
  user whose browser is set to Berlin time
- **WHEN** the file is produced
- **THEN** Issue date and Due date are the calendar dates printed on the invoice, written as YYYY-MM-DD
- **AND** Paid at is written in the organisation's time zone with its offset, 2026-09-30T23:30:00+01:00
- **AND** the issue date range filter selects the same invoices as the invoice list does

#### Scenario: Values with commas, quotes and line breaks
- **GIVEN** a customer named Müller, Söhne & Co. "Nord" and a payment reference that contains a line break
- **WHEN** the file is opened in Excel or in Google Sheets
- **THEN** each value lands in a single cell exactly as stored in Ledgerly

#### Scenario: Values that look like formulas
- **GIVEN** a payment reference equal to =SUM(A1:A9) or a customer name starting with +, - or @
- **WHEN** the file is opened in a spreadsheet tool
- **THEN** the value is shown as text
- **AND** no formula runs

#### Scenario: File name
- **GIVEN** the organisation's time zone is Europe/Lisbon
- **WHEN** an export of the current filters is produced at 14:32 on 2026-10-20
- **THEN** the file is named invoices-2026-10-20-1432.csv
- **AND** an export of the saved view "Overdue Q3" produced at the same time is named
  invoices-overdue-q3-2026-10-20-1432.csv

### Requirement: Export size limit
The system SHALL refuse an export whose filters match more than 50,000 invoices and SHALL tell the user how many
matched and how to proceed.

#### Scenario: Filter exceeds the limit
- **GIVEN** the applied filters match 62,310 invoices
- **WHEN** the user requests an export
- **THEN** no file is produced
- **AND** the user is told that 62,310 invoices matched, that the limit is 50,000, and to narrow the filters, for
  example by date

#### Scenario: Filter at the limit
- **GIVEN** the applied filters match exactly 50,000 invoices
- **WHEN** the user requests an export
- **THEN** the export proceeds

### Requirement: Background export
The system SHALL prepare every export without blocking the invoice list and SHALL continue a requested export
after the user leaves the page.

#### Scenario: Small export is ready quickly
- **GIVEN** the applied filters match at most 2,000 invoices
- **WHEN** the user requests an export and stays on the invoice list
- **THEN** the file is ready within 10 seconds
- **AND** the download starts without further action
- **AND** the invoice list stays usable in the meantime

#### Scenario: Large export continues while the user works
- **GIVEN** the applied filters match 12,400 invoices
- **WHEN** the user requests an export
- **THEN** the user is told at once that the export is being prepared and that they can keep working
- **AND** progress is visible as rows prepared out of the total
- **AND** within 2 minutes the user is told the file is ready and is offered the download
- **AND** the invoice list and every other screen stay responsive while the export runs

#### Scenario: User leaves the page
- **GIVEN** an export is in progress
- **WHEN** the user navigates to another screen, closes the browser or loses the connection, and comes back
- **THEN** the export has continued
- **AND** the file is listed under the user's exports and can be downloaded from any screen

#### Scenario: Export fails
- **GIVEN** an export fails part way through
- **WHEN** the user looks at the export
- **THEN** it is marked as failed with a plain-language message and an option to try again
- **AND** no partial file is offered
- **AND** the failed export no longer counts towards the exports in progress

### Requirement: Concurrent exports
The system SHALL allow each user up to three exports in progress at the same time and SHALL keep every export
independent of all others.

#### Scenario: Fourth export is declined
- **GIVEN** a user has three exports in progress
- **WHEN** she requests a fourth
- **THEN** the fourth is declined with a message saying that three are still running
- **AND** the three running exports are unaffected

#### Scenario: Exports of two users stay separate
- **GIVEN** two users of the same organisation request exports with different filters at the same time
- **WHEN** both exports are ready
- **THEN** each file holds only the invoices of its own request
- **AND** neither user sees the other's export in their list of exports

### Requirement: Export permissions
The system SHALL allow every user who can view invoices to export them, limited to the invoices that user can
see, and SHALL refuse the export to everyone else.

#### Scenario: Read-only accountant exports
- **GIVEN** a user with the Accountant (read-only) role who can see two of the organisation's three legal
  entities
- **WHEN** she requests an export with no legal entity filter
- **THEN** the file holds only the invoices of the two legal entities she can see

#### Scenario: User without invoice access
- **GIVEN** a user with the Sales role, who cannot view invoices
- **WHEN** the invoice list would be shown or an export is requested by any other means
- **THEN** no export action is offered
- **AND** the request is refused with the message that the user has no permission to export invoices
- **AND** no file is produced

### Requirement: Export retention
The system SHALL keep a finished export available to the user who requested it for 24 hours and SHALL remove the
file afterwards.

#### Scenario: Download within 24 hours
- **GIVEN** an export finished 20 hours ago
- **WHEN** the requester downloads it from the list of exports
- **THEN** the file is delivered unchanged

#### Scenario: Download after 24 hours
- **GIVEN** an export finished 25 hours ago
- **WHEN** the requester tries to download it
- **THEN** the download is refused with a message that the export has expired and can be requested again
- **AND** the export is shown as expired in the list of exports

#### Scenario: Only the requester can download
- **GIVEN** an export requested by one user
- **WHEN** another signed-in user tries to open it by its link
- **THEN** the request is refused as if the export did not exist
