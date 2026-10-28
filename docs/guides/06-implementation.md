# Step 6: Implementation

The code is written from the approved tech proposal and the delta specs, one task at a time, with
each task checked off only after its named verification passed. It ends with a pull request
description a reviewer can read without opening the code: what was built, where it differs from the
proposal and why, and how it was verified.

| | |
|---|---|
| Command | `/espec-implementation <change-name>` |
| Who | A developer. QA, in verification-only mode, for the `## QA verification` group. |
| Input | An approved change folder on `main`, re-read from disk on every run |
| Output | Application code and tests. `tasks.md` with tasks checked. `pull-request.md`. `.espec.yaml` at `in-progress`, then `implemented`. |
| Time | The feature's size. The prompt pauses often on purpose; budget time for the pauses. |
| Rules | [AGENTS.md, Pull request description format](../../template/espec/AGENTS.md#pull-request-description-format-pull-requestmd) and [Guardrails for AI assistants](../../template/espec/AGENTS.md#guardrails-for-ai-assistants) |

## Before you start

- The proposal pull request is merged and the status line in `tech-proposal.md` reads **Approved**.
  The command stops on Draft or In review and points to the reviewer.
- No blocking Question for Product is open. The command stops on one and asks whether product has
  answered.
- `main` is green and you are on a fresh branch from it.

```bash
git checkout main && git pull
git checkout -b espec/bill-142-implementation
```

- You know how to run the tests the tasks name. The command runs them; you read the results.

## Run it

```text
/espec-implementation bill-142-invoice-csv-export
```

### The gate and the plan

The command checks `.espec.yaml` (`proposed` or `in-progress`) and that `tech-proposal.md` and
`tasks.md` exist, reads `feature.md`, the proposal, every delta spec and `tasks.md` from disk, and
prints progress: `N/M tasks complete`, the next pending tasks and their group. It does not rely on
anything it remembers from earlier in the conversation, so you can stop and restart at any time, in
any session, and it picks up from `tasks.md`.

### One task at a time

For each pending task it says which task it is on, makes the smallest change that satisfies the task
and the scenarios it cites, runs the verification the task names, and only then changes `- [ ]` to
`- [x]` on that exact line. After the first checked task it sets `status: in-progress`.

Work with it in groups. Let it finish a group, read the diff, run the group's tests yourself, commit:

```bash
git commit -am "BILL-142: group 2, export service and CSV writer (tasks 2.1 to 2.6)"
```

Small commits per group keep the review tractable and give you a place to go back to when a later
group goes wrong.

### The pauses

The command stops and asks, with options, when:

- a task is unclear or two tasks contradict each other;
- the task needs work the proposal or specs do not describe;
- it is tempted to narrow, defer or simplify specified behaviour;
- implementation reveals a design problem;
- a test fails for a reason outside the task.

Answer the pause, do not route around it. The two answers that keep the artifacts true:

| The pause says | Answer |
|---|---|
| "This needs X, which the proposal does not describe" | Decide. If X is small and changes no observable behaviour, "add it as a new task N.M in this group". If it changes behaviour, "propose the delta spec change", review the proposed text, and tell the reviewer in the pull request. The main specs are never edited here. |
| "The design does not work because Y" | Stop coding. The fix is a tech proposal update: the decision changes, the proposal is re-reviewed (a short follow-up on the proposal pull request is enough), then implementation continues. Improvising around a design problem is how specs and code drift. |

### QA verification

When every implementation group is checked, QA runs the same command and says "verification only".
The command skips to the `Q.n` tasks, touches no application code, runs each scenario, records the
environment and the observed result on the task line, and checks the task only when it passes. A
failing scenario is a finding for the developer, surfaced as a pause, never a workaround. The worked
example [tasks.md](../../examples/changes/bill-142-invoice-csv-export/tasks.md) shows what the
recorded lines look like.

### The pull request description

When every task is checked (or when you stop early and ask for one anyway), the command re-reads
`tech-proposal.md` from disk, compares it with what was built, and writes `pull-request.md`:

- **Summary** a product manager can read.
- **Proposal versus implementation:** one row per decision, endpoint, data model element, rollout
  step and forced note. "As proposed", or the difference and why. Read every "differs" row; each one
  is a conversation with the reviewer that has already happened.
- **Behaviour delivered:** one row per acceptance criterion with the file a reviewer opens first and
  the test and `Q.n` that verify it.
- **Deviations and deferred work**, **How to review**, **Verification**, **Rollout** as implemented,
  and a **Release note** that archive reuses.

Then it sets `status: implemented`, prints the file, and prints the command to use it:

```bash
gh pr create --body-file espec/changes/bill-142-invoice-csv-export/pull-request.md
```

With `review.tool: diffcompass`, it also prints `/espec:review <change-name>` for the reviewer, which starts the DiffCompass tour. Run
`espec/bin/espec validate` before you open the pull request; it checks that `pull-request.md` has
every section once the status is `implemented`.

## What good looks like

- Every task checked, and each check happened after its verification ran, not before.
- The diff contains only what the tasks describe. Refactors outside a task were proposed as new tasks
  or left for another change.
- `espec/specs/` is untouched. Behaviour changes found on the way are in the change's delta specs,
  with a note in Deviations.
- `pull-request.md` has no "see code" and no "self-explanatory". A reviewer could decide where to
  look first from the Behaviour delivered table alone.
- The Verification section names commands and results, and the QA table names environments.

See the worked example
[pull-request.md](../../examples/changes/bill-142-invoice-csv-export/pull-request.md).

## Hand-off

Open the pull request with `pull-request.md` as its body and go to [code review](07-code-review.md).

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| A task is checked but the test it names does not exist | The AI checked early | Uncheck it, say "run the verification named in task N.M before checking it". Audit the group |
| The AI keeps "simplifying" an acceptance criterion | Scope pressure | Say no. The criterion is product's; a change to it is a Question for Product on the ticket |
| Long session, quality drops | Context drift | Stop. Commit. Start a new chat and run the command again; it re-reads from disk |
| Two developers on one change | Both editing `tasks.md` | Split by group, each on their own branch, merge `tasks.md` by hand. One task is one owner |
| Tests fail for a reason outside the task | Flaky suite or an unrelated break | The pause is right. Fix the cause as its own commit, or record it in Deviations |
| `pull-request.md` was edited by hand and drifted from the code | Manual edits after more commits | Re-run the command and ask for the pull request description again; it recompares with the proposal |
| The change shipped in two pull requests | Normal for big features | Keep one `##` block per pull request in `pull-request.md`, newest first |
