# Acceptance request · BILL-142

What `/espec:implementation` printed for the ticket when the last task was checked, and what the
developer posted on BILL-142 once the flag was on for the internal organisation on staging. The
product owner tries the change there and answers on the ticket. Format:
[AGENTS.md, Product acceptance and success metrics](../template/espec/AGENTS.md#product-acceptance-and-success-metrics).

```markdown
**Acceptance request · Export invoices as CSV (BILL-142)**

Try it: staging, signed in to the internal organisation, where the flag `invoice-csv-export` is on.
Open Invoices: the Export CSV button is in the list toolbar, and under More actions on a tablet.

| Criterion | What you should see | Verified by QA |
|-----------|---------------------|----------------|
| AC-1: Export the current filter | A CSV with exactly the invoices the list shows, in the list's order, within 10 seconds for up to 2,000 | Q.1, 2026-10-23, staging |
| AC-2: A large export runs in the background | A "preparing" message at once, progress in the Exports indicator, the list still usable | Q.2, 2026-10-23, staging |
| AC-3: Export a saved view | The file holds the view's invoices and its name includes the view name | Q.3, 2026-10-23, staging |
| AC-4: Empty result | A file with column headings only, and a message saying no invoices matched | Q.4, 2026-10-23, staging |
| AC-5: Row limit | Above 50,000 invoices, a message with the count and the limit, and no export | Q.5, 2026-10-23, staging |
| AC-6: Concurrent exports | A fourth export while three run is declined with "You already have 3 exports in progress" | Q.6, 2026-10-23, staging |
| AC-7: Permissions | The file holds only the entities you may see; a user who cannot view invoices has no button | Q.7, 2026-10-23, staging |
| AC-8: Multiple currencies | Each row in its own currency, no conversion, no total rows | Q.8, 2026-10-23, staging |
| AC-9: Dates and time zones | Issue and due dates as printed on the invoice, Paid at in the organisation's time zone | Q.9, 2026-10-23, staging |
| AC-10: Special characters | Names with commas, quotes and accents land in one cell in Excel and Google Sheets | Q.10, 2026-10-23, staging |
| AC-11: Leaving the page | The file is waiting in the Exports indicator when you come back, for 24 hours | Q.11, 2026-10-23, staging |
| AC-12: File columns and name | 15 columns in the agreed order with English headings; the file name carries the date and time | Q.12, 2026-10-23, staging |
| AC-13: Failed export | A failed export says so, downloads nothing and offers Try again | Q.13, 2026-10-23, staging |

Differs from the definition: the file holds what the filter matches when the export runs, so its row
count can differ from the number on the button if invoices change in between. FT-1 (use the nightly
batch) stays overridden, as you agreed: exports show on the "Invoice exports" panel next to the
nightly batch panel.
Not in this change: a first line in the file stating the applied filters and the export time. That
question is open on this ticket until 2026-11-07; a yes becomes a separate change.

Reply "Accepted", or say which criterion is not as defined.
```

Mariana Costa replied "Accepted" on 2026-10-24, after trying AC-1, AC-3, AC-5 and AC-13 herself and
reading the rest. At archive, `.espec.yaml` gets `accepted_by: Mariana Costa`, `accepted: 2026-10-24`,
`rollout: partial` with the note "flag invoice-csv-export: internal organisation, then the three
design partners; everyone one week later if the error rate stays under 1%", and
`metrics_review_due: 2027-03-31`, the latest date among the definition's success metrics (the two
enterprise renewals due in Q1 2027). The release note lists all five metrics under "To check after
release" with their dates: 60 days after release for adoption, one quarter for the drop in support
requests, monthly for speed and error rate.
