# Step 5: Inspect the tech proposal

A read-only review of the proposal against the ticket it implements. It takes the proposal's
traceability table as a claim and verifies it against the actual scenario headings in `specs/` and
the task numbers in `tasks.md`, checks every forced note has a verdict, every decision has
alternatives, every constraint has a home, the test strategy covers every edge case, and no blocking
question is open. It ends with a verdict and a comment for the ticket.

| | |
|---|---|
| Command | `/espec-inspect-tech-proposal <change-name>` |
| Who | The author first, before asking for review. Then QA and the Engineering Manager or Architect who approves. |
| Input | A change name. Empty input auto-selects when exactly one active change has a `tech-proposal.md`. |
| Output | A report in the chat with a verdict: **Approve** or **Not yet**, with counts, and a comment for the ticket. Nothing is written. |
| Time | Three minutes to run, twenty to read. The human review of the design is separate and longer. |
| Rules | [AGENTS.md, Inspection report formats](../../template/espec/AGENTS.md#inspection-report-formats) |

## Before you start

- You are on the proposal branch (or have the pull request checked out). The command reads
  `.espec.yaml`, `feature.md`, `tech-proposal.md`, every file under `specs/` and `tasks.md` from disk.
- `espec/bin/espec validate <change-name>` passes. The inspection checks meaning; the validator
  checks form. Run the cheap one first.
- The coverage report that `/espec-tech-proposal` printed is the author's claim. This inspection
  checks the same ids against the files without trusting it.

## Run it

```text
/espec-inspect-tech-proposal bill-142-invoice-csv-export
```

The report has nine parts:

1. **Ticket versus feature.md.** When Copilot can reach the ticket it fetches it and compares
   section by section. A difference is blocking until someone says which version wins. When the
   ticket is not reachable it says so and takes `feature.md` as is; the reviewer then compares by
   eye once.
2. **Traceability.** One row per `UC-n`, `EC-n` and `AC-n`: the scenarios in `specs/` that specify
   it, the tasks that build it, the `Q.n` line that verifies it, and the gap if any. Every name is
   checked against the files. A scenario named in the table that does not exist under that name is
   a gap.
3. **Forced technical notes.** Each `FT-n` with its verdict and whether the reason holds.
4. **Decisions.** Each `D-n` with whether real alternatives are listed.
5. **Constraints and non-functional requirements.** Every constraint and success metric from
   `feature.md` with where the proposal addresses it. One with no home is blocking.
6. **Specs.** Every acceptance criterion has a scenario; four-hash scenarios; `MODIFIED` blocks are
   whole; existing capability paths reused; new capabilities carry a Purpose.
7. **Test strategy.** Every edge case has a test at a named level; one `Q.n` per `AC-n`;
   non-functional checks exist; test data and environments are named.
8. **Open questions.** A blocking Question for Product still open is blocking.
9. **Findings and the comment for the ticket.**

The worked example report in
[examples/inspections/tech-proposal.md](../../examples/inspections/tech-proposal.md) came back
**Not yet** with two blocking findings that a human reviewer would likely have missed: the list of
exports only showed 24 hours, so the Expired state in the UI design could never appear, and the
December code freeze from the Constraints had no home in Rollout. Both were fixed in the proposal
that is in the example folder, which is why its status line says Approved.

### The review flow

1. **Author** runs it, fixes every blocking finding and the advisories worth fixing, re-runs until
   Approve, and asks for review.
2. **QA** runs it and reads the Traceability and Test strategy parts. QA owns the question "could I
   verify every acceptance criterion from this?" and the `## QA verification` group.
3. **Reviewer** runs it, then reviews what the command cannot: whether the decisions are right for
   this codebase, whether the non-functional requirements are the right ones, whether the rollout is
   safe. A decision the reviewer would have made differently is advisory unless it breaks a
   constraint from `feature.md`. The reviewer posts the comment on the ticket.
4. **Approve** means two things: the status line in `tech-proposal.md` is set to **Approved** and the
   pull request is approved. Conditions: zero blocking findings, every `FT-n` has a verdict, the
   traceability table is complete, QA accepted the test strategy, no blocking Question for Product
   is open. Product does not approve the how; product answers the questions.
5. **Merge.** `.espec.yaml` stays at `proposed`; that status now means approved, because the file is
   on `main` with the Approved status line. With CODEOWNERS and code owner review turned on
   ([engineering setup, step 5](setup-engineering.md#step-5-protect-approval-and-the-main-specs)),
   the line cannot reach `main` without the named approvers.

Approval covers the proposal as approved. When a decision, the scope or observable behaviour changes
later, in this pull request or during implementation, the status line goes back to **In review**,
the implementation command stops, and the reviewer approves the new version. Wording fixes and
checked tasks need no re-approval.

### Saving the report

On request the report is saved to
`espec/changes/<change-name>/inspections/YYYY-MM-DD-inspect-tech-proposal.md`. Worth doing for the
run that produced Approve, so the archive carries the evidence.

## What good looks like

- Approve with zero blocking, and the advisories left open are named in the pull request with a
  reason.
- Ticket and `feature.md` identical, confirmed by a fetch or by a reviewer's eye.
- Every row of Traceability resolves to real headings and real task numbers.
- QA has signed off the test strategy and the `Q.n` lines in writing (a pull request approval).
- The reviewer has written at least one sentence about a decision, not only about the format.

## Hand-off

Merge the proposal pull request. Then [implementation](06-implementation.md) starts from `main`,
in a new chat or session, with `/espec-implementation <change-name>`. The implementation gate checks
`.espec.yaml`, the presence of `tech-proposal.md` and `tasks.md`, and that the proposal's status line reads Approved; it stops on
Draft or In review. `espec validate` also fails a change that is in progress on an unapproved proposal.
Set the line when you approve, or implementation will not start.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| Traceability claims a scenario that the inspection cannot find | The table was written from memory; the spec heading differs by a word | Make the names identical. The archive step matches headings by exact text |
| "Ticket not reachable" and the reviewer skips the comparison | No connection | Compare once by eye, section by section, and say so in the pull request |
| The reviewer re-designs the proposal in the review | Taste, not constraints | Advisory unless it breaks a constraint or a forced note. Record the alternative under the decision and move on |
| The report finds a constraint with no home, the author says "it is obvious" | Obvious to the author | Write the line. Rollout, non-functional or test strategy; one sentence is enough |
| Approve, but a product question is open and marked non-blocking | Judgement call | Fine when a yes would be a separate change, as in the worked example. Say the date by which it must be answered |
| The proposal was approved, then product changed the ticket | Scope change | Re-import, re-run the inspection, re-approve. The proposal pull request can be reopened or a follow-up opened |
