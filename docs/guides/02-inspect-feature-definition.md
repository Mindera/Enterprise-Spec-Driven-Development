# Step 2: Inspect the feature definition

The first thing engineering does with a ticket. A read-only review that checks the definition for
missing information, hows outside the forced notes, use cases and edge cases with no acceptance
criterion, edge cases nobody thought of, and criteria that cannot be tested. It ends with a verdict
and a comment ready to paste on the ticket.

| | |
|---|---|
| Command | `/espec-inspect-feature-definition <ticket key, URL, pasted text or change name>` |
| Who | The developer or QA engineer picking up the ticket. Any reviewer. Product, with the review prompt. |
| Input | A ticket key or URL (fetched when Copilot can reach the ticket system, otherwise pasted), a pasted definition, or a change name whose `feature.md` is read from disk |
| Output | A report in the chat with a verdict: **Ready for tech proposal** or **Draft**, with blocking and advisory counts, and a comment for the ticket. Nothing is written. |
| Time | Two minutes to run, ten to read and act |
| Rules | [AGENTS.md, Inspection report formats](../../template/espec/AGENTS.md#inspection-report-formats) |

## Before you start

- The ticket status says Ready for tech proposal, or product has asked for an early look at a draft.
- You are in the repository in Copilot Chat, agent mode. The command reads `espec/AGENTS.md`.
- Nothing else. The inspection needs no change folder and creates none.

## Run it

```text
/espec-inspect-feature-definition BILL-142
```

The command says which source it used and when it fetched it. If it cannot reach the ticket, it asks
you to paste the description; paste the whole thing, marker line included.

The report has seven parts:

1. **Readiness checklist.** The nine checks, ✅ or ❌, each ❌ with a fix. Any ❌ is blocking.
2. **Product boundary.** Every how found outside Forced technical notes, quoted, with where it is
   and an outcome rephrasing. Any how is blocking. A forced note without the ⚠️ marker or without
   a reason is a finding too.
3. **Coverage.** One row per `UC-n` and `EC-n` with the `AC-n` entries that name it. A gap is
   blocking.
4. **Edge cases to consider.** Items from the standard list that apply to this feature and have no
   `EC-n`, each written out as a proposed edge case with a situation and an expected behaviour.
   Advisory, unless the missing case changes scope.
5. **Testability.** Acceptance criteria whose THEN cannot be observed or measured, with a rewrite.
6. **Findings.** Numbered, each Blocking or Advisory, with where and a suggested fix.
7. **Comment for the ticket.** The verdict, the blocking findings as questions for product, the
   advisory ones as suggestions.

Read the findings, not just the verdict. The worked example report in
[examples/inspections/feature-definition.md](../../examples/inspections/feature-definition.md) came
back Ready with five advisory findings; two of them (can an export be cancelled, what happens when
access changes mid-export) were worth a product answer before the proposal.

### Act on the verdict

| Verdict | Do |
|---|---|
| Ready, no advisories | Post the comment anyway so the ticket records that it was checked. Go to [the technical assessment](03-technical-assessment.md). |
| Ready, with advisories | Post the comment. Decide which advisories need a product answer before the proposal (anything that could change scope) and which can be folded in later. Go to the assessment. |
| Draft, blocking findings | Post the comment. Stop. The definition goes back to product; the tech proposal does not start on it. |

Posting the comment is yours to do: the command never writes to the ticket. When Copilot can reach
the ticket and you ask it to post, it asks for confirmation first.

### Do not fix it yourself

The inspection is read-only on purpose. A developer who rewrites the acceptance criteria to make
them pass has moved the product decision into the repository, where product will not see it. Send
the findings back; product fixes the description with the agent or the
[review prompt](../../product-ai/prompts/review-feature-definition.prompt.md), which runs the same
checks on their side.

### Saving the report

Ask, and the command saves the report to
`espec/changes/<change-name>/inspections/YYYY-MM-DD-inspect-feature-definition.md`. Useful when the
ticket goes back and forth more than once; otherwise the ticket comment is the record.

## What good looks like

- The verdict is Ready and you agree with each advisory being advisory.
- You could start the technical assessment without asking product a single clarifying question
  about what the feature is. Questions about feasibility are the next step's job.
- The ticket carries the inspection comment, dated.

## Hand-off

Ready: [the technical assessment](03-technical-assessment.md). Draft: back to product with the comment;
re-inspect when the description is updated. The inspection is cheap, so re-run it after every
description change rather than reading the diff yourself.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| Ready from the agent, Draft from the inspection | The agent's readiness check is its own opinion of its own text; the inspection is stricter and quotes | Trust the inspection. Send the findings back |
| The inspection proposes edge cases that do not apply | It walks a generic list | Ignore them. Do not ask product about edge cases you can rule out yourself; say so in the comment |
| "Ticket not reachable" every time | No MCP server, or not signed in | Paste the description, or set up the connection ([engineering setup, step 7](setup-engineering.md#step-7-let-copilot-reach-the-ticket-system-optional-recommended)) |
| The report is long and product stops reading | Every advisory went into the comment | Edit the comment before posting: blocking items first, the three advisories that matter, the rest as "also worth a look" |
| Product edited the ticket after the inspection | Normal | Re-run. Compare verdicts, not texts |
