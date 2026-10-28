# Step 7: Code review

The implementation pull request is reviewed in two passes: first the description, which says what
was built and where it differs from the proposal, then the diff, in the order the description gives,
with DiffCompass flagging code that drifts from the proposal or the delta specs. Approval still
happens in the pull request.

| | |
|---|---|
| Tool | The pull request, whose body is `pull-request.md`. [DiffCompass](https://github.com/Mindera/diffcompass) for the diff: `diffcompass pr <number> --open`. |
| Who | The reviewer named for the repository, usually the Engineering Manager or Architect. A second developer for large changes. |
| Input | The pull request with `pull-request.md` as its body, CI green including `espec-validate`, every task checked |
| Output | Approval, or change requests. A merged change at `implemented`. |
| Time | Proportional to the Behaviour delivered table, not to the line count |
| Rules | [AGENTS.md, Reviewing the code](../../template/espec/AGENTS.md#reviewing-the-code) |

## Before you start

- CI is green, including `espec-validate`, which fails when `pull-request.md` is missing a section.
- The pull request body is `pull-request.md`, not a hand-written summary. If it is not, ask the
  author to regenerate it: the description is the review's map.
- With DiffCompass: it is installed (`diffcompass doctor`) and `.diffcompass.json` is at the
  repository root. Without it: `review.tool: none` in `config.yaml`, and the manual path below.

## Run it

### First pass: the description, without the code

Read `pull-request.md` top to bottom. Ten minutes. What to decide on each section:

| Section | Decide |
|---|---|
| Summary | Does it match the ticket's What? Would product recognise it? |
| Proposal versus implementation | Every "differs" row has a reason. Is the reason one you accept? A difference that changes observable behaviour must come with a delta spec change in the same pull request; check `espec/changes/<name>/specs/` in the diff. A row that says "As proposed" for something the diff changes is the finding you are looking for. |
| Behaviour delivered | One row per acceptance criterion. Each names a file and a test. Pick the three criteria most likely to be wrong and keep them for the second pass. |
| Deviations and deferred work | Unchecked tasks have reasons. "None" is written, not implied. Anything product must know is here, and it will reach them through the release note. |
| Verification | Commands and results. QA lines have environments. Numbers where the constraints had numbers. |
| Rollout | As implemented. Flag default, migration order, rollback. |

If the first pass finds a gap, request changes now. Do not read code to compensate for a description
that does not say what was built.

### Second pass: the diff, in the order given

With DiffCompass:

```bash
diffcompass pr 1234 --open
```

The tour opens in a local browser. `.diffcompass.json` tells its agent to read the change folder
before explaining code, to order the tour by **How to review**, and to flag: code that differs from
the tech proposal or the delta specs without a row in Proposal versus implementation, behaviour no
acceptance criterion or scenario describes, acceptance criteria whose named test is missing from the
diff, and any edit to `espec/specs/`. Ask it questions as you go ("where is the row limit enforced?",
"which test covers the formula guard?") and leave line feedback, which lands on the pull request.

Without DiffCompass, follow **How to review** by hand: entry points, then the core, then tests. For
each of the three acceptance criteria you kept, open the file the table names and the test it names.
Then grep the diff for `espec/specs/`: any hit is a change request.

### Decide

| Finding | Action |
|---|---|
| Behaviour not described by any acceptance criterion or scenario | Request changes. Either it is scope (a Question for Product and a delta spec), or it comes out |
| Code differs from the proposal with no row in the table | Request changes: add the row with the reason, and the delta spec change if behaviour changed |
| A test named in Behaviour delivered is missing or does not test the criterion | Request changes |
| `espec/specs/` edited | Request changes. Main specs change at archive only |
| A task checked without its verification | Request changes. Uncheck, verify, re-check |
| Design you would have done differently, within the approved proposal | Comment, approve. The proposal was the place for that review |

Approve in the pull request. Merge. The change is at `implemented` on `main`.

## What good looks like

- You could say what the change does to someone who has not seen the code, after the first pass.
- Every "differs" row was a conscious yes.
- The three acceptance criteria you spot-checked each had a real test that would fail without the
  code.
- The review comments are about behaviour and decisions, not about things the description should
  have told you.

## Hand-off

[Archive](08-archive.md), run by the developer after the merge.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The pull request is too big to review in one sitting | Several groups in one pull request | Review group by group using the commits, or ask for the change to ship in two pull requests with one `##` block each in `pull-request.md` |
| DiffCompass flags "drift" that the table explains | It did not read the change folder | Check `.diffcompass.json` is at the root and names the change folder instruction; ask the agent to re-read `pull-request.md` |
| Reviewers skip the description and start in the diff | Habit | Make the first pass a checklist item in the pull request template. The description is the shortest path to the risky code |
| `pull-request.md` is stale against the last commits | Edited by hand, or commits after it was written | Author re-runs `/espec-implementation` and asks for the description again |
| QA lines say Pass with no environment or date | QA edited by hand | Ask for the environment and date on each `Q.n` line; the archive carries them as evidence |
| DiffCompass will not install or start | Not on PATH, or the GitHub CLI not signed in for `diffcompass update` | Run `diffcompass doctor` and follow it; the installer falls back to a plain download. Until then set `review.tool: none` and use the manual path |
