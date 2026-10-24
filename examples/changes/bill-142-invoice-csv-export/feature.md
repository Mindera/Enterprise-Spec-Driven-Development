<!-- espec:feature-definition v1 -->
# Feature: Export invoices as CSV

**Ticket:** BILL-142 · **Product owner:** Mariana Costa · **Design:** Tomasz Nowak · **Status:** Ready for tech proposal

## Why

Finance teams reconcile the invoices in Ledgerly against their ERP and their bank statements every month, and
almost all of them do it in a spreadsheet. Today they copy rows out of the invoice list screen by screen, or they
ask our support team for a database extract: about 35 such requests a month, each taking up to two working days,
most of them raised in close week when finance has the least time to wait. "Invoice data in a spreadsheet" was the
most requested missing feature in the Q3 2026 customer survey (41% of finance respondents), and two enterprise
renewals due in Q1 2027 (combined annual value 380k EUR) have named it as a condition. If we do nothing, support
keeps absorbing the extracts, close week gets slower for every customer, and both renewals stay at risk.

## What

A finance user filters the invoice list the way they already do (status, customer, legal entity, issue date,
currency, free-text search) and exports exactly what they see as a CSV file. The file holds one row per invoice
with the amounts, dates and references finance needs for reconciliation. Small exports arrive straight away. Large
exports are prepared while the user keeps working and can be picked up later from anywhere in the product. Saved
views can be exported the same way. Nothing changes for users who never export.

## Users and personas

- **Finance controller (Ana Ribeiro, 400 invoices a month).** Reconciles Ledgerly with the ERP once a month.
  Today she pastes screens into a spreadsheet. Afterwards she exports the month in one go.
- **Finance manager (Jonas Weber, three legal entities, 12,000 invoices a quarter).** Runs quarter close. Today
  he raises a support ticket for an extract and waits two days. Afterwards he exports the quarter himself and keeps
  working while the file is prepared.
- **Accountant with the read-only role (Léa Martin).** Prepares the weekly collections list from the "Overdue Q3"
  saved view. She cannot edit invoices and that stays the same. She can export what she is allowed to see.
- **Not affected.** Sales users have no access to the invoice list and that does not change. Customer-portal
  users are not affected.

## Use cases

### UC-1: Export the current filter
- **Actor:** Finance controller
- **Trigger:** Monthly reconciliation. The controller has filtered the invoice list to the invoices she needs.
- **Preconditions:** The user can view invoices. The invoice list shows the result of one or more filters.
- **Main flow:**
  1. Ana filters the list to Status = Sent, Overdue and Issue date = 1 July 2026 to 30 September 2026. The list
     shows 1,284 invoices.
  2. She chooses Export CSV.
  3. Within a few seconds the file downloads to her device.
  4. She opens it in Excel and matches it against the ERP.
- **Outcome:** Ana has a CSV file holding exactly the 1,284 invoices the list showed, one row each, in the order
  of the list.
- **Alternative flows:** If the export takes longer than a few seconds, Ana is told it is being prepared and can
  keep working (see UC-2).

### UC-2: Export a date range with more than 10,000 invoices
- **Actor:** Finance manager
- **Trigger:** Quarter close. The manager needs every invoice of the quarter across his three legal entities.
- **Preconditions:** The user can view invoices of all three entities. The filter matches more than 10,000 invoices.
- **Main flow:**
  1. Jonas filters by Issue date = 1 July 2026 to 30 September 2026 with no entity filter. The list shows 12,400
     invoices.
  2. He chooses Export CSV.
  3. He is told the export is being prepared and that he can keep working. Progress is visible.
  4. He opens two invoices and answers an email while he waits.
  5. Within two minutes he is told the file is ready and downloads it.
- **Outcome:** Jonas has a CSV file with 12,400 rows without having waited on a blocked screen.
- **Alternative flows:** If he leaves the invoice list or closes the browser, the export keeps going and the file
  is waiting for him when he comes back (see EC-8).

### UC-3: Export a saved view
- **Actor:** Accountant with the read-only role
- **Trigger:** The weekly collections call. The "Overdue Q3" saved view already holds the right filters.
- **Preconditions:** The saved view exists and the user can view invoices.
- **Main flow:**
  1. Léa opens the invoice list and applies the saved view "Overdue Q3".
  2. She chooses Export CSV.
  3. The file downloads.
- **Outcome:** Léa has a CSV file holding the invoices that match the saved view, named after the view so she can
  tell this week's file from last week's.
- **Alternative flows:** If she changes a filter after applying the view, the export follows the filters she now
  sees, not the view as saved.

## Edge cases

### EC-1: The filter matches no invoices
- **Situation:** The applied filters match zero invoices.
- **Expected behaviour:** The export is still possible. The file holds only the column headings and the user is
  told that no invoices matched and the file contains headings only.

### EC-2: The filter matches more than 50,000 invoices
- **Situation:** The filters match more than 50,000 invoices, for example a whole year across all entities.
- **Expected behaviour:** No file is produced. The user is told how many invoices matched, that the limit is
  50,000, and that narrowing the filters (for example by date) will let the export go ahead.

### EC-3: Several exports at the same time
- **Situation:** A user starts several exports in a row, or two users in the same organisation export at the same
  time.
- **Expected behaviour:** A user may have up to three exports in progress at once. A fourth request is declined
  with a message saying how many are still running. Exports never interfere with each other: each file holds only
  the invoices of its own request and users only ever see their own exports.

### EC-4: A read-only accountant exports
- **Situation:** A user with the Accountant (read-only) role, who can view but never edit invoices, and who sees
  only some of the organisation's legal entities, requests an export.
- **Expected behaviour:** Exporting counts as viewing. The accountant can export, and the file holds only the
  invoices of the legal entities she is allowed to see, whatever the filter says. Users with no access to invoices
  (for example the Sales role) do not see the export action and are refused if they try another way.

### EC-5: Invoices in several currencies
- **Situation:** The filter matches invoices issued in EUR, GBP and JPY.
- **Expected behaviour:** Each row carries the invoice's own currency code and its amounts in that currency.
  Nothing is converted and the file has no total rows, so that nobody adds up mixed currencies by accident.
  Amounts are written in a way every spreadsheet reads as a number.

### EC-6: Time zone of dates
- **Situation:** An invoice issued by a Lisbon entity is paid at 23:30 Lisbon time, and the user who exports is
  in Berlin.
- **Expected behaviour:** Invoice dates (issue date, due date) are the calendar dates printed on the invoice,
  never shifted by the user's time zone. Timestamps (paid at) are shown in the organisation's time zone with the
  offset included, so they match what finance sees in the product and remain unambiguous. The issue date range
  filter is interpreted the same way as in the list.

### EC-7: Commas, quotes and line breaks in customer names and references
- **Situation:** A customer is called Müller, Söhne & Co. "Nord", or a payment reference contains a line break,
  or a reference starts with = or + or - or @.
- **Expected behaviour:** The file opens in Excel and Google Sheets with every value in one cell, unchanged,
  accents intact. Values that look like spreadsheet formulas are shown as text and never run.

### EC-8: The user leaves while an export is in progress
- **Situation:** An export is being prepared and the user navigates to another screen, closes the tab, or loses
  the connection.
- **Expected behaviour:** The export continues. When it is ready, the user finds the file under their exports from
  any screen, and it stays available to them for 24 hours.

### EC-9: An export fails part way through
- **Situation:** Something goes wrong while the file is being prepared.
- **Expected behaviour:** The user is told the export failed in plain words and can try again. No partial file is
  offered. The failed export no longer counts towards the three in progress.

## Out of scope

- PDF export of invoices (single or bulk).
- Scheduled or recurring exports.
- XLSX or any format other than CSV.
- Sending the export by email or to any external destination.
- Exporting invoice line items. The file holds one row per invoice.
- Choosing or reordering columns. The column set is fixed.
- Exports from the customer portal.
- Changes to the filters themselves or to saved views.

## Acceptance criteria

### AC-1: Export the current filter (covers UC-1)
- **GIVEN** a finance controller on the invoice list with filters Status = Sent, Overdue and Issue date =
  1 July 2026 to 30 September 2026, showing 1,284 invoices
- **WHEN** she chooses Export CSV
- **THEN** within 10 seconds a CSV file downloads holding exactly those 1,284 invoices, one row each, in the
  order of the list
- **AND** the invoice list stays usable while the file is prepared

### AC-2: A large export runs in the background (covers UC-2)
- **GIVEN** a finance manager whose filters match 12,400 invoices
- **WHEN** he chooses Export CSV
- **THEN** he is told straight away that the export is being prepared and that he can keep working, and progress
  is visible
- **AND** within 2 minutes he is told the file is ready and can download it
- **AND** the invoice list and every other screen stay responsive while the export runs

### AC-3: Export a saved view (covers UC-3)
- **GIVEN** the saved view "Overdue Q3" is applied and unchanged
- **WHEN** the user chooses Export CSV
- **THEN** the file holds the invoices that match the view's filters
- **AND** the file name includes the view name

### AC-4: Empty result (covers EC-1)
- **GIVEN** the applied filters match no invoices
- **WHEN** the user chooses Export CSV
- **THEN** a file holding only the column headings is produced
- **AND** the user is told that no invoices matched and the file contains headings only

### AC-5: Row limit (covers EC-2)
- **GIVEN** the applied filters match 62,310 invoices
- **WHEN** the user chooses Export CSV
- **THEN** no file is produced
- **AND** the user is told that 62,310 invoices matched, that the limit is 50,000, and to narrow the filters
- **AND** a filter matching exactly 50,000 invoices still exports

### AC-6: Concurrent exports (covers EC-3)
- **GIVEN** a user with three exports in progress
- **WHEN** she requests a fourth
- **THEN** the fourth is declined with a message saying three are still running
- **AND** two users exporting at the same time each receive a file holding only their own request and never see
  each other's exports

### AC-7: Permissions (covers EC-4)
- **GIVEN** an Accountant (read-only) who can see two of the organisation's three legal entities
- **WHEN** she exports with no entity filter
- **THEN** the file holds only the invoices of the two entities she can see
- **AND** a user with no access to invoices does not see the Export CSV action and is refused if they request an
  export another way

### AC-8: Multiple currencies (covers EC-5)
- **GIVEN** the filter matches invoices in EUR, GBP and JPY
- **WHEN** the file is produced
- **THEN** each row shows its own currency code and the amounts in that currency, with no conversion
- **AND** amounts are plain numbers with a dot as decimal separator and no thousands separator
- **AND** the file contains no total rows

### AC-9: Dates and time zones (covers EC-6)
- **GIVEN** an invoice issued on 30 September 2026 by a Lisbon entity and paid at 23:30 Lisbon time, exported by
  a user in Berlin
- **WHEN** the file is produced
- **THEN** the issue date and due date are the calendar dates printed on the invoice, written as YYYY-MM-DD
- **AND** the paid-at timestamp is written in the organisation's time zone with its offset
  (2026-09-30T23:30:00+01:00)
- **AND** the issue date range filter selects the same invoices as the list does

### AC-10: Special characters (covers EC-7)
- **GIVEN** a customer named Müller, Söhne & Co. "Nord", a payment reference containing a line break, and a
  reference equal to =SUM(A1:A9)
- **WHEN** the file is opened in Excel and in Google Sheets
- **THEN** every value lands in a single cell exactly as stored in Ledgerly, accents intact
- **AND** the reference is shown as the text =SUM(A1:A9) and no formula runs

### AC-11: Leaving the page (covers EC-8)
- **GIVEN** an export is in progress
- **WHEN** the user navigates to another screen or closes the browser and comes back later
- **THEN** the export has continued and the file is listed under the user's exports, ready to download from any
  screen
- **AND** the file stays available to that user for 24 hours and no longer afterwards
- **AND** nobody else can download it

### AC-12: File columns and name (covers UC-1, UC-2, UC-3)
- **GIVEN** any successful export
- **WHEN** the file is opened
- **THEN** the first row holds, in this order: Invoice number, Status, Customer, Customer number, Legal entity,
  Issue date, Due date, Currency, Net amount, Tax amount, Gross amount, Paid amount, Outstanding amount, Paid at,
  Payment reference
- **AND** the headings are in English whatever the user's interface language
- **AND** the file is named invoices-YYYY-MM-DD-HHMM.csv, or invoices-[view name]-YYYY-MM-DD-HHMM.csv for a
  saved view, using the organisation's time zone

### AC-13: Failed export (covers EC-9)
- **GIVEN** an export that fails part way through
- **WHEN** the user looks at the export
- **THEN** it is marked as failed with a plain message and an option to try again
- **AND** no partial file is offered
- **AND** the failed export no longer counts towards the three in progress

## Experience and design

Design owner: Tomasz Nowak. Design file: Figma › Ledgerly › Invoices › CSV export (v3).

### Entry point and flow
- The export lives in the invoice list toolbar, next to the filters, as a secondary action labelled
  **Export CSV (1,284)**. The number is the current result count and updates whenever filters change, so the
  user always knows what they are about to export.
- There is no settings dialog. One tap exports what the list shows. Saved views need nothing extra: apply the
  view, export.
- On narrow screens (tablet in portrait) the action moves into the list's **More actions** menu with the same
  label.

### States
- **Empty (0 results).** The button reads **Export CSV (0)** and stays enabled. After the export, a message
  says: "No invoices matched your filters. The file contains column headings only."
- **Loading, short.** The button shows a spinner and reads **Preparing…** for up to 10 seconds, then the
  download starts and the button returns to normal. The list stays interactive the whole time.
- **Loading, long.** After 10 seconds, or at once when the count is above 2,000, a message appears: "We're
  preparing your export. You can keep working and we'll tell you when it's ready." An **Exports** indicator in the
  top bar shows progress (rows prepared out of total) and persists across screens.
- **Success.** A message says "Your export is ready" with a **Download** action. If the user is still on the
  invoice list, the download starts on its own. The file also appears in the Exports indicator for 24 hours.
- **Error, too many rows.** "This export has 62,310 invoices, more than the limit of 50,000. Narrow your filters,
  for example by date, and try again." The button stays enabled so the user can adjust and retry; we never
  disable a control without saying why.
- **Error, too many in progress.** "You already have 3 exports in progress. Wait for one to finish and try
  again."
- **Error, failed.** "We couldn't prepare your export. Nothing was downloaded." with a **Try again** action.
- **Expired.** An export older than 24 hours is listed as "Expired" with the hint "Export again from the invoice
  list."
- **No permission.** Users without access to invoices never see the action. If a request is refused anyway, the
  message is "You don't have permission to export invoices."

### Content and tone
- Plain, calm, no jargon. Say what happened and what to do next. Numbers are formatted in the user's locale in
  messages (1,284 or 1.284), but the file itself follows AC-8 and AC-9.
- Interface copy is available in all four product languages (English, German, French, Portuguese). Column
  headings in the file stay English (see Constraints).

### Accessibility
- The export action is reachable by keyboard and has a visible focus state. Progress and completion are announced
  to screen readers without stealing focus. Messages stay on screen until dismissed or until the user acts on
  them, never time out silently.
- Colour is never the only signal: progress, success and failure each have an icon and text.
- Touch targets are at least 44 by 44 points on tablet. Target WCAG 2.2 AA, as for the rest of the invoice list.

## Constraints

- **Data residency.** Exported files are stored and served from the EU only. This is contractual for the two
  enterprise renewals.
- **Devices.** Must work on tablet (iPad, Safari) in both orientations, as well as desktop browsers.
- **Close week performance.** During the first five working days of each month the invoice list must stay as fast
  as it is today while exports run. A typical export (up to 2,000 invoices) must be available within 10 seconds;
  the largest allowed export (50,000) within 2 minutes.
- **Audit.** Every export is recorded with who requested it, when, which filters and how many rows, and every
  download is recorded, kept for as long as the existing audit log keeps its entries.
- **Retention.** Exported files are available to the requester for 24 hours and are then removed. Finance
  compliance does not want exported customer data accumulating in the product.
- **Language.** Column headings are always in English so that country teams can share files and load them into
  the same tools. Interface copy follows the user's language.
- **Timing.** Needed before the January 2027 close. It must be in the Q4 2026 release train (code freeze
  5 December 2026).

## Success metrics

- 60% of active finance users export at least once within 60 days of release.
- Support requests for invoice extracts drop from about 35 a month to under 5 within one quarter of release.
- 95% of exports of up to 2,000 invoices are ready within 10 seconds; 99% of all exports complete without error.
  Measured monthly, including close week.
- Zero data-residency incidents related to exports.
- Both enterprise renewals that named the export as a condition sign in Q1 2027.

## Open questions

- None. (Resolved 2026-10-17: whether the Accountant (read-only) role may export. Decision: yes, within the legal
  entities the user can see. Owner: Mariana Costa.)

## Forced technical notes

> ⚠️ **Forced by product.** These notes describe *how*, which is outside the product boundary.
> Engineering reviews them in the tech proposal and may override them with a documented reason.
- **FT-1:** "Use the existing nightly batch job so finance can monitor it in the same dashboard."
  _Reason given: finance operations already watch the nightly batch dashboard every morning and do not want a
  second place to look when an export fails. The product owner understands this is a how and asked for it to be
  recorded anyway._
