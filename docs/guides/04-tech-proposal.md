# Step 4: Tech proposal

Engineering writes the **how**: architecture, APIs, data model, decisions with the alternatives that
lost, a review of every forced technical note, a traceability table from every product id to a spec
scenario and a task, a test strategy for QA, and the questions that go back to product. The output
is planning artifacts only: `tech-proposal.md`, delta specs and `tasks.md`.

| | |
|---|---|
| Command | `/espec-tech-proposal <ticket key, URL, change name or pasted definition>` |
| Who | A developer writes. QA writes or reviews the test strategy. The Engineering Manager or Architect reviews. |
| Input | The ticket, `espec/project.md`, `espec/config.yaml`, the main specs under `espec/specs/`, the code |
| Output | `espec/changes/<change-name>/` with `feature.md` (imported), `tech-proposal.md`, `specs/<capability>/spec.md` per capability touched, `tasks.md`, `.espec.yaml` at `status: proposed` |
| Time | Half a day to two days, depending on the feature. Most of it is reading the output and pushing back. |
| Rules | [AGENTS.md, Tech proposal format](../../template/espec/AGENTS.md#tech-proposal-format-tech-proposalmd), [Delta spec format](../../template/espec/AGENTS.md#delta-spec-format-in-changeschange-namespecs), [Tasks format](../../template/espec/AGENTS.md#tasks-format-tasksmd) |

## Before you start

- The ticket is Ready for tech proposal and [the inspection](02-inspect-feature-definition.md)
  found no blocking issue. The command re-runs the readiness checklist and will ask whether to
  continue on a definition with gaps; "yes" turns every gap into a Question for Product, which is
  honest but slower than fixing the definition first.
- [The technical assessment](03-technical-assessment.md) is on the ticket and scope decisions are in
  the description.
- You are on a branch. The proposal is reviewed as a pull request that adds the change folder and
  nothing else.

```bash
git checkout -b espec/bill-142-proposal
```

## Run it

```text
/espec-tech-proposal BILL-142
```

With a ticket key or URL, the command first runs the Import mode of the feature definition: fetches
the ticket (or asks for a paste), reviews it, writes `feature.md` and `.espec.yaml`, and derives the
change name (`bill-142-invoice-csv-export`). With a change name that already exists, it updates the
proposal in place.

It then works through nine steps and announces each. Where to pay attention:

1. **Resolve and check readiness.** It prints the checklist again. If something is ❌, decide now
   whether to continue.
2. **Explore the code.** It reads `project.md`, then the modules, tests and configuration the
   feature touches, and the main specs that already cover part of the behaviour. The **Context**
   section it writes must cite paths and separate observed facts from assumptions. Open three of
   the cited paths. If one is wrong, say so and have it re-explore before it designs on top.
3. **Write `tech-proposal.md`.** Read it in this order:
   - **Technology decisions.** Every `D-n` lists alternatives and why they lost. "We always do it
     this way" is an alternative, not a reason. Push: "what would make option B the right one?"
   - **Forced technical notes review.** One row per `FT-n`, Accepted or Overridden with a reason.
     An override must say how the need behind the note is still met, as the worked example does for
     the nightly batch job.
   - **Traceability.** Every `UC-n`, `EC-n` and `AC-n` appears. Anything untraced is a Question for
     Product. Constraints get rows too.
   - **Test strategy.** Written for QA: how each scenario is verified, at which level, with what data,
     in which environment. Hand this section to QA now, not at review.
   - **Questions for Product.** Pasteable as a ticket comment. Mark each blocking or not.
4. **Write the delta specs.** One file per capability under `specs/<capability>/spec.md`. New
   capability: `## Purpose` plus `ADDED` requirements. Existing capability: the exact path of the
   main spec, and `MODIFIED` blocks that carry the **whole** requirement, every scenario included.
   Check that capability names match `espec/specs/` and describe durable behaviour
   (`invoice-export`), not the change (`add-csv-export`). A change with no observable behaviour
   change gets `skip_specs: true` and no `specs/` folder.
5. **Write `tasks.md`.** Groups ordered by dependency, each landing its own tests. Every task says
   how it is verified and cites the `AC-n` and `EC-n` it satisfies. The final `## QA verification`
   group has one `Q.n` per acceptance criterion plus the non-functional checks. No task says
   "explore" or "decide": that work happens now.
6. **Update `.espec.yaml`** to `proposed` with the engineering and QA owners.
7. **Assess coverage.** It re-reads what it wrote and prints a coverage report: one row per `UC-n`,
   `EC-n` and `AC-n` with the scenario, tasks and `Q.n` it found on disk and a status of Covered,
   Partial or Missing; one row per constraint, metric, design item and forced note with where the
   proposal addresses it; a match figure such as `13 of 13 product ids covered (100%)`; and a short
   judgement. Read the Partial and Missing rows first. A gap it could close, it closed before
   printing; what is left is a Question for Product or a decision for you.
8. **Report.** Files written, Questions for Product ready to paste, and the next command.

Iterate by talking to it: "D-2 restates the choice as its reason; give the real trade-off",
"task 2.5 produces the file, so it covers AC-1 too". Re-running the command with the change name
re-reads everything from disk, so you can edit files by hand between runs.

### Validate

```bash
espec/bin/espec validate bill-142-invoice-csv-export
```

Catches the mechanical problems before a reviewer does: three-hash scenarios, placeholders left in,
a `MODIFIED` requirement with no scenario, a task line without a checkbox.

### Questions for Product

Paste them as a ticket comment. A blocking question pauses the proposal's approval, not its writing.
When product answers, they update the description; you re-run the command with the change name and
it shows the difference between the ticket and `feature.md` and asks which wins.

### Open the pull request

Title: the ticket key and "tech proposal". Body: the Approach paragraph, the list of capabilities
touched, the open questions, and a link to `tech-proposal.md`. Reviewers: the person who approves
proposals (named in `project.md`) and QA. The pull request touches `espec/`, so validation runs.

## What good looks like

- Context cites real paths and says what was assumed. A reviewer can open each path and nod.
- Each decision could be argued the other way, and the proposal says why it was not.
- Every forced note has a verdict and a reason that product would recognise as fair.
- The traceability table has no gaps and no row the specs and tasks do not back up. Read it from
  both ends: from `AC-7` to its scenarios and tasks, and from task 3.3 back to why it exists.
- QA has read the test strategy and could start writing the test plan.
- `tasks.md` could be handed to a developer who has not read the chat.
- Nothing outside `espec/changes/<change-name>/` changed. No application code.
- The coverage report says Covered on every row, or says exactly why not. A row it marks Covered
  names a scenario and a task you can open.

See the worked example
[tech-proposal.md](../../examples/changes/bill-142-invoice-csv-export/tech-proposal.md) and
[tasks.md](../../examples/changes/bill-142-invoice-csv-export/tasks.md).

## Hand-off

[The tech proposal inspection](05-inspect-tech-proposal.md), run by the author first and then by
the reviewer. Approval is the reviewer setting the status line in `tech-proposal.md` to
**Approved** and approving the pull request. Merge it. Implementation starts from `main`.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The AI started writing application code | It drifted out of the planning rule | Stop it. Discard the code. The prompt forbids it; remind it and continue |
| Context cites files that do not exist | Hallucinated exploration | "Open each path you cited and correct the Context section." Verify three yourself |
| A `MODIFIED` block carries only the changed scenario | Partial content | Have it copy the whole requirement from the main spec first, then edit. Archive would lose the other scenarios |
| Capability names do not match `espec/specs/` | It invented a new folder for an existing behaviour | Point it at the existing path. One behaviour, one capability |
| The proposal is twice as long as the definition | It restated the why | "Do not restate the why. Link to feature.md." Cut |
| Tasks are too big to finish in a session | Groups instead of tasks | Split until each has one verification |
| The QA group has fewer `Q.n` lines than acceptance criteria | Skipped | One `Q.n` per `AC-n`, in order, then exploratory and non-functional lines |
| `validate` fails on `feature.md` placeholders | The import kept a template line | Fix `feature.md` to match the ticket exactly |
| The coverage report says 100% but the inspection finds gaps | The self-check trusted its own table instead of the files | "Re-read specs/ and tasks.md from disk and recompute the coverage report." The inspection wins |
