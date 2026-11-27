<!-- espec:feature-definition v1 -->
# Bug: Exported yen amounts carry two decimals

**Ticket:** BILL-171 · **Reported by:** Sofia Almeida · **Status:** Ready for tech proposal

## Why

Customers who invoice in Japanese yen cannot load the invoice export into their ERP: the import rejects the
amount columns, so the finance team retypes them by hand. Three customers reported it in the two weeks since the
export shipped (support tickets SUP-2291, SUP-2304 and SUP-2317). All three invoice in JPY and together they
export about 40 files a month. Until it is fixed, support sends a corrected file on request, about 20 minutes
each, in the same close week the export was built to relieve.

## What

**Expected.** In the export file, an amount in a currency that has no decimals shows none: a JPY invoice of
125,000 yen shows `125000` in Net amount, Tax amount, Gross amount, Paid amount and Outstanding amount. This is
what the main spec says: invoice-export › Export file contents › Amounts stay in the invoice currency.

**Actual.** The same amounts show two decimals: `125000.00`. Amounts in EUR and GBP are correct.

The invoice list on screen and the PDF invoice show yen amounts correctly. Only the export file is affected.

## Steps to reproduce

1. On staging, release 2026.11.2, sign in as a finance controller of the test organisation Kaito Trading, whose
   invoices are issued in JPY.
2. Open the invoice list and filter to Currency = JPY. The list shows 212 invoices.
3. Request an export and download the file when it is ready.
4. Open the file in a text editor, not a spreadsheet, and read the Gross amount of the first row.

It happens every time, on every row, in all five amount columns.

## Out of scope

- Files exported before the fix. They are not regenerated; support keeps sending corrected files on request.
- Converting amounts between currencies, and total rows. Neither exists and neither is asked for.
- The decimal separator and the absence of a thousands separator, which are correct today.

## Acceptance criteria

### AC-1: Yen amounts have no decimals
- **GIVEN** the filter matches a JPY invoice with a gross amount of 125,000 yen
- **WHEN** the export file is produced
- **THEN** the five amount columns of that row hold whole numbers with no decimal separator, `125000` for the
  gross amount

### AC-2: Currencies with decimals stay as they are
- **GIVEN** the filter matches invoices in EUR and GBP
- **WHEN** the export file is produced
- **THEN** their amounts show two decimals, `1250.00`, exactly as before the fix

## Open questions

- Do the other currencies without decimals behave the same way? Only JPY was reported and checked. Owner:
  Daniel Okafor (QA), to answer before the tech proposal is approved.
