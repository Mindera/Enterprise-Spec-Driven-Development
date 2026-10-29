---
agent: agent
description: "espec review · Inspect a feature definition: check a ticket or feature.md for missing information, hows, coverage gaps and untestable criteria. Read-only; prints a report and a ticket comment."
---

# /espec:inspect-feature-definition

You review a feature definition and report what is missing. You change nothing: not the ticket, not
`feature.md`, not any other file. Read [espec/AGENTS.md](../../espec/AGENTS.md) first and follow the
**Feature definition format**, **The product boundary** and **Inspection report formats** sections.

Input: `${input:source:Ticket key or URL, a pasted feature definition, or a change name under espec/changes/}`

## Steps

1. **Load the definition.** A ticket key or URL: fetch it when a tool can reach it (an Atlassian or
   GitHub MCP server, a fetch tool, the GitHub CLI); otherwise ask for the description to be pasted.
   A change name: read `espec/changes/<change-name>/feature.md` from disk, and when the ticket is also
   reachable, fetch it and note any difference under Findings. Pasted text: use it as is. Say which
   source you used and when it was fetched.

2. **Run the readiness checklist** from AGENTS.md, one row per check, ✅ or ❌ with a one-line fix.

3. **Scan the product boundary.** Quote every how found outside `## Forced technical notes`, say where
   it is, and give an outcome rephrasing. Check that every `FT-n` carries the ⚠️ marker and a reason.

4. **Check coverage.** For every `UC-n` and `EC-n`, list the `AC-n` entries that name it. A use case
   or edge case with no acceptance criterion is a gap. An `AC-n` that names nothing is a gap.

5. **Propose missing edge cases.** Walk the standard list (empty data, limits, two people at once,
   permissions and roles, offline or slow connection, partial failure, time zones, locales,
   currencies, duplicates, retries, undo, what the user sees when something fails). For each item that
   applies to this feature and has no `EC-n`, write the proposed edge case with a situation and an
   expected behaviour. Do not propose items that do not apply.

6. **Check testability.** Flag every acceptance criterion whose THEN cannot be observed or measured,
   and give a rewrite.

7. **Report.** Print the report in the Feature definition inspection format. Number the findings,
   mark each Blocking or Advisory as AGENTS.md defines, set the verdict, and end with the comment for
   the ticket. When the user asks, save the report to
   `espec/changes/<change-name>/inspections/YYYY-MM-DD-inspect-feature-definition.md`.

## Guardrails

- Read-only. Do not fix the definition, do not update the ticket, do not create a change folder.
  To fix it, point to `/espec:feature-definition` (Review mode) or to the product pack.
- Quote; do not paraphrase. A finding names the section and the words that triggered it.
- Do not invent product facts. A missing use case is a question for product, not a guess.
- One verdict. Ready for tech proposal only with zero blocking findings.
- End the reply with the usage line from the **Usage report** section of AGENTS.md.
