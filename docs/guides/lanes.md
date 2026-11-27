# Small and urgent changes

Not every change deserves four phases and two approvals, and a production incident cannot wait for
them. espec has two shorter lanes for those. Both are declared in `.espec.yaml`, both leave a record,
and neither removes the review of the code, the tests or the specs.

| | Standard | Small | Urgent |
|---|---|---|---|
| For | Everything else | A change one reviewer can judge whole in one sitting | Production is broken or at risk now |
| Who decides | Nobody: it is the default | The author proposes, the reviewer accepts by approving | A named person accountable for production |
| Definition | Full feature definition, or a bug report | Short: Why, What, Out of scope, Acceptance criteria | Written after the fix |
| Inspection and assessment | Yes | On request | No |
| Proposal | Full | Short: five sections | Short, as a record of what shipped |
| Pull requests | Proposal, then code, then archive | One for the change folder and the code, then archive | The fix, then the record, then archive |
| Approval | The proposal, then the code | Both at once | The fix before merge, the record after |

Rules: [AGENTS.md, Lanes](../../template/espec/AGENTS.md#lanes). A pull request that changes no
behaviour at all (a refactor, a dependency update, tooling, tests, documentation) needs none of this:
see [No behaviour change](#no-behaviour-change).

## The small lane

### Does it qualify?

All four must hold:

- One capability, and no new screen or flow.
- No new or changed API, contract, data model or migration.
- Nothing needed from another team.
- One reviewer can judge the definition, the plan and the code together in one sitting.

A changed label, a new default, a raised limit, a clearer validation message, a different sort order:
small. A new filter, a new role, a new email: not small, however little code it takes. When in doubt
it is not small.

### Run it

1. Start the change:

   ```bash
   espec/bin/espec new bill-176-rename-export-button --lane small --ticket BILL-176
   ```

   `feature.md` starts from the short template. Fill it from the ticket, or run
   `/espec-feature-definition bill-176-rename-export-button`. A change that already exists moves to
   the small lane with `lane: small` in its `.espec.yaml`.
2. `/espec-tech-proposal bill-176-rename-export-button` checks the four conditions, then writes the
   short proposal, the delta when the main specs describe the behaviour, and the tasks. It leaves the
   status line at In review.
3. In a new chat, in the same branch, `/espec-implementation bill-176-rename-export-button`. It starts
   on In review because the lane is small.
4. Open one pull request with the change folder and the code. `espec validate` fails in CI with
   "status line must be Approved". That is the gate, not a fault.
5. The reviewer reads `feature.md`, `tech-proposal.md` and the code, and approves by setting the
   status line to **Approved**. A suggested change on that line is enough. CI turns green. Merge.
6. `/espec-archive` as usual.

### When it stops being small

The reviewer, or the author, sets `lane: standard`. `espec validate` then asks for the full forms, and
the proposal gets its own review before more code is written. Moving up is normal, not a failure.

## The urgent lane

### Is it an emergency?

Production is broken or at risk now: an incident, a vulnerability being exploited, data being lost or
corrupted, a legal deadline that cannot move. A release date that is close is not an emergency. One
named person accountable for production says it is: the incident lead, the on-call lead, the
engineering manager.

### Fix first

1. Record the debt, in the fix branch:

   ```bash
   espec/bin/espec new bill-180-fix-export-timeout --kind bug --lane urgent --declared-by "Priya Raghavan" --ticket INC-204
   ```

   It writes `.espec.yaml` and nothing else, with `catch_up_by` one week ahead.
2. Fix it. Open the pull request with `?template=espec-urgent-fix.md` on the compare URL: who
   declared it, what is broken, what the fix changes, how to roll back.
3. Someone other than the author reviews it before merge. A test that reproduces the problem goes in
   with the fix when there is time for one. Otherwise it is the first task of the catch-up.

### Paper after

1. Before `catch_up_by`, run `/espec-tech-proposal bill-180-fix-export-timeout`. It reads the merged
   pull request and writes the record: the bug report, the root cause, what was changed, the delta if
   the fix changed specified behaviour, and the tasks, with what is still owed left open.
2. A reviewer approves the record. Finish the open tasks, or move them to a change of their own.
3. `/espec-archive`. No `pull-request.md` is needed: the fix already merged.

### The deadline

`espec list` shows every urgent change with its date. `espec validate` passes until that date and
fails after it, on every pull request, until the paper is written. When a week is not enough, move
`catch_up_by` in a pull request and say why in its description: the extension is then reviewed like
anything else.

## No behaviour change

A refactor, a dependency update, a build or CI change, tests, documentation: no change folder and no
lane. Say so in the pull request description, on a line of its own:

```text
espec: no behaviour change (upgrade the HTTP client to 5.4.1)
```

The reviewer confirms it by approving. When the reviewer finds that behaviour does change, the pull
request needs a change. A refactor big enough that its plan deserves review can still take a change
with `skip_specs: true`.

## The CI check

The validate workflow looks at every pull request that changes code. One that touches no folder under
`espec/changes/` and has no `espec: no behaviour change` line gets a warning. Files under `espec/`,
`.github/` and `.claude/`, and Markdown files, do not count as code. Set the level in
`espec/config.yaml`:

```yaml
lanes:
  untracked_changes: warn       # warn | require | off
```

Start with `warn`. Move to `require` once the team writes the line without thinking: the check then
fails until the pull request has a change or the line. Editing the description re-runs the check.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| Everything becomes small | The lane is the easy path | The reviewer checks the four conditions before reading the code. `/espec-inspect-tech-proposal` reports a condition that does not hold as blocking |
| Everything becomes urgent | A date is close | Urgent needs a named person and a production problem. A close date is a planning problem |
| Urgent changes pile up past their date | Nobody owns the catch-up | The person in `declared_by` owns it. `espec validate` fails for everyone until it is done, which is the point |
| CI fails on a small-lane pull request before review | The status line reads In review | Expected. The reviewer sets it to Approved |
| The check warns on a pull request that only updates a dependency | No declaration line | Add `espec: no behaviour change (reason)` to the description |
| The urgent fix was reverted | The incident ended another way | Run `/espec-archive` and cancel the change with the reason. A cancelled change needs no paper |
