# Inspection: feature definition · Export invoices as CSV (BILL-142)

**Source:** espec/changes/bill-142-invoice-csv-export/feature.md, identical to BILL-142 fetched 2026-10-21 · **Verdict:** Ready for tech proposal (0 blocking, 5 advisory)

## Readiness checklist
| Check                                                                         | Result | Fix |
|-------------------------------------------------------------------------------|--------|-----|
| Why explains the problem and the cost of doing nothing                        | ✅     |     |
| What is from the user's point of view, with no solution                       | ✅     |     |
| At least one UC-n with actor, trigger, main flow and outcome                  | ✅     |     |
| At least one EC-n, or a stated reason why none apply                          | ✅     |     |
| Out of scope is an explicit list                                              | ✅     |     |
| Every UC-n and EC-n is covered by an AC-n, and every AC-n says what it covers | ✅     |     |
| UI design is filled, or marked "not needed" with a reason         | ✅     |     |
| Open questions is "None" or every question has an owner                       | ✅     |     |
| No how outside Forced technical notes                                         | ✅     |     |

Evidence: Why closes with "If we do nothing, support keeps absorbing the extracts, close week gets slower for every
customer, and both renewals stay at risk." UC-1 to UC-3 each carry actor, trigger, preconditions, main flow,
outcome and alternative flows. EC-1 to EC-9 are present. Out of scope lists eight items. UI design
names the owner, the Figma file, the entry point, nine states, content and tone, and accessibility. Open questions
is "None", with the one resolved question dated 2026-10-17 and owned by Mariana Costa. FT-1 carries the ⚠️ marker
and the reason given.

## Product boundary

None. Two places were read twice and are fine. "ask our support team for a database extract" (Why) describes
today's workaround, not the solution. "CSV" (What, Out of scope) is the file the user asked for, not a format chosen
for internal reasons. Constraints state outcomes only: "stored and served from the EU only", "available within
10 seconds", "recorded with who requested it, when, which filters and how many rows". The only how in the document,
"Use the existing nightly batch job so finance can monitor it in the same dashboard", is inside Forced technical
notes as FT-1 with the marker and the reason.

## Coverage
| Id   | Covered by  | Gap                                                                         |
|------|-------------|-----------------------------------------------------------------------------|
| UC-1 | AC-1, AC-12 |                                                                             |
| UC-2 | AC-2, AC-12 |                                                                             |
| UC-3 | AC-3, AC-12 |                                                                             |
| EC-1 | AC-4        |                                                                             |
| EC-2 | AC-5        |                                                                             |
| EC-3 | AC-6        |                                                                             |
| EC-4 | AC-7        |                                                                             |
| EC-5 | AC-8        |                                                                             |
| EC-6 | AC-9        |                                                                             |
| EC-7 | AC-10       |                                                                             |
| EC-8 | AC-11       | AC-11 names EC-8 but its WHEN leaves out "loses the connection" (finding 4) |
| EC-9 | AC-13       |                                                                             |

Every AC-1 to AC-13 names at least one id in its heading. No use case or edge case is without an acceptance
criterion.

## Edge cases to consider

Walked the standard list. Covered: empty data (EC-1), limits (EC-2, EC-3), two people at once (EC-3), permissions
and roles (EC-4), offline or slow connection (EC-8), partial failure (EC-9), time zones (EC-6), locales (AC-8,
AC-12, Content and tone), currencies (EC-5), duplicates (one row per invoice in UC-1 and AC-1, several exports in
a row in EC-3), retries (EC-9, AC-13), what the user sees when something fails (EC-9 and the States list). Three
items apply and are absent.

### EC-10 (proposed): Cancelling an export in progress
- **Situation:** A user starts a 12,400-row export with the wrong filters, notices at once, and already has three
  exports in progress. Nothing says whether an export can be cancelled; the only hint is the copy "Wait for one to
  finish and try again."
- **Expected behaviour:** As written, no cancellation: the user waits for a slot. Product to confirm, or to add
  cancellation as new scope: a cancelled export frees its slot and offers no file.

### EC-11 (proposed): Access changes between request and download
- **Situation:** An administrator removes a legal entity from a user's access, or deactivates the user, after an
  export was requested and before it is ready, or before it is downloaded within the 24 hours. EC-4 fixes access
  at the moment of the request only.
- **Expected behaviour:** The file holds only the invoices the user may see at the moment the file is prepared, and
  a user who has lost access to invoices cannot download a file that is still listed. Product to confirm.

### EC-12 (proposed): Language of the Status values in the file
- **Situation:** A user whose interface language is German exports. AC-12 fixes the headings to English; nothing
  says whether the Status column holds "Sent" or "Gesendet".
- **Expected behaviour:** Status values are written in English, like the headings, so that country teams can share
  and load the same files (Constraints, Language). Product to confirm.

## Testability

- **AC-2**, third AND: "the invoice list and every other screen stay responsive while the export runs".
  "Responsive" carries no measure in the criterion. Rewrite: "the invoice list and every other screen load and
  filter as fast as they do today (Constraints, Close week performance)". AC-1, second line, "the invoice list
  stays usable while the file is prepared", takes the same rewrite. Advisory only: the Constraint already supplies
  the measure, so QA can test both today.

## Findings
| # | Severity | Finding | Where | Suggested fix |
|---|----------|---------|-------|---------------|
| 1 | Advisory | No edge case says whether an export in progress can be cancelled; the three-slot limit in EC-3 is what makes it matter | Edge cases; UI design › States › "Error, too many in progress" | Add EC-10 as proposed and cover it in AC-6 or a new AC |
| 2 | Advisory | EC-4 fixes access at the moment of the request; nothing says what happens when access changes while the export runs or during the 24-hour window | Edge cases › EC-4; AC-7; AC-11 | Add EC-11 as proposed and extend AC-7 |
| 3 | Advisory | The language of the Status column values is not stated; the headings constraint gives the reason to fix it | AC-12; Constraints › Language | Add "Status values are in English" to the THEN of AC-12, or EC-12 as proposed |
| 4 | Advisory | AC-11 WHEN reads "navigates to another screen or closes the browser"; EC-8 also lists "loses the connection", so QA working from the AC would not test it | Acceptance criteria › AC-11 | Add "or loses the connection" to the WHEN of AC-11 |
| 5 | Advisory | "stays usable" (AC-1) and "stay responsive" (AC-2) carry no measure in the criterion | Acceptance criteria › AC-1, AC-2 | Point both at the measure in Constraints › Close week performance, as rewritten under Testability |

## Comment for the ticket

**espec inspection of the feature definition, 2026-10-21: Ready for tech proposal.** No blocking findings. Why,
What, three use cases, nine edge cases, out of scope and thirteen acceptance criteria are present; every UC and EC
maps to an AC; no implementation detail outside the forced note FT-1. Five suggestions, none of which needs to
hold the tech proposal:

1. Say whether an export in progress can be cancelled (proposed EC-10). If not, one line saying so is enough.
2. Say what happens when a user's entity access is reduced, or the user is deactivated, while an export is running
   or still downloadable (proposed EC-11).
3. State that the Status column values are in English like the headings (AC-12).
4. Add "or loses the connection" to the WHEN of AC-11 so it matches EC-8.
5. Give "stays usable" in AC-1 and "stay responsive" in AC-2 the measure already in Constraints › Close week
   performance.

Engineering can start the tech proposal now. Answers to 1 and 2 can arrive as a ticket comment and be folded into
feature.md before the proposal is approved.
