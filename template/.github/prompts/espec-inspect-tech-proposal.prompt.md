---
mode: agent
description: "espec review · Inspect a tech proposal against its ticket: traceability, forced notes, decisions, constraints, specs, test strategy and open questions. Read-only; prints a report and a ticket comment."
---

# /espec:inspect-tech-proposal

You review a tech proposal against the feature definition it implements and report every gap. You
change nothing. Read [espec/AGENTS.md](../../espec/AGENTS.md) first and follow the **Tech proposal
format**, **Delta spec format**, **Tasks format** and **Inspection report formats** sections.

Input: `${input:change:Change name under espec/changes/ (leave empty to pick from the active changes)}`

## Steps

1. **Select the change.** Use the name given, infer it from the conversation, auto-select when exactly
   one active change has a `tech-proposal.md`, otherwise ask. Announce "Inspecting change: <name>".
   Read from disk: `.espec.yaml`, `feature.md`, `tech-proposal.md`, every file under `specs/`,
   `tasks.md`.

2. **Compare the ticket with `feature.md`.** When a tool can reach the ticket named in `.espec.yaml`,
   fetch it and compare section by section. Report "Identical", or each difference. A difference is
   blocking until someone says which version wins. When the ticket is not reachable, say so and take
   `feature.md` as is.

3. **Trace every product id.** For each `UC-n`, `EC-n` and `AC-n` in `feature.md`: the scenario in
   `specs/` that specifies it, the tasks that build it, and the `Q.n` line that verifies it. Use the
   proposal's Traceability table as a claim and verify it against the actual spec and task files. A
   missing scenario, task or QA line is a gap. An id missing from the Traceability table is a gap.

4. **Check the forced technical notes.** Every `FT-n` in `feature.md` has a row in the proposal's
   review with Accepted or Overridden and a reason. An overridden note must say how the need behind it
   is met.

5. **Check the decisions.** Every `D-n` lists alternatives and why they lost. A decision that restates
   the choice as its reason is a finding.

6. **Check constraints and metrics.** Every item under Constraints and Success metrics in `feature.md`
   is addressed somewhere in the proposal: non-functional requirements, rollout, test strategy or
   architecture. One with no home is blocking.

7. **Check the specs.** Every acceptance criterion maps to at least one scenario. Scenarios use
   `#### Scenario:` and are testable. MODIFIED blocks are whole. Existing capability paths under
   `espec/specs/` are reused rather than duplicated. New capabilities carry a `## Purpose`. A change
   with `skip_specs: true` has no `specs/` folder and no behaviour change in its proposal.

8. **Check the test strategy and tasks.** Every `EC-n` has a test at a named level. The
   `## QA verification` group has one `Q.n` per `AC-n`. Non-functional checks exist for the constraints.
   Each task group lands its own tests. No task says "explore" or "decide".

9. **Check open questions.** A blocking Question for Product that is still open is blocking. An
   engineering question that would change specs or tasks is blocking; one that can wait is advisory.

10. **Report.** Print the report in the Tech proposal inspection format: the tables, the numbered
    findings with Blocking or Advisory, the verdict, and the comment for the ticket. When the user asks,
    save it to `espec/changes/<change-name>/inspections/YYYY-MM-DD-inspect-tech-proposal.md`.

## Guardrails

- Read-only. Do not edit the proposal, specs, tasks, `feature.md`, the ticket or code. To fix a gap,
  point to `/espec:tech-proposal` for the change, or to the ticket for product questions.
- Verify claims against files. The Traceability table is evidence only when the scenarios and tasks it
  names exist with those names.
- Do not re-decide the design. A decision you would have made differently is advisory at most, unless
  it breaks a constraint from `feature.md`.
- One verdict. Approve only with zero blocking findings.
- End the reply with the usage line from the **Usage report** section of AGENTS.md.
