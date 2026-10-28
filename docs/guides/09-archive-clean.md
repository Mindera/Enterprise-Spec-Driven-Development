# Step 9: Archive clean

An audit of `espec/specs/` with confirmation. For every requirement it gathers evidence (the code and
tests that implement it, the archived changes that added or last touched it, anything that
contradicts it), proposes Keep, Update or Purge, writes a report, and applies only what a human
confirms. The goal is a `espec/specs/` folder that describes only what the system does today.

| | |
|---|---|
| Command | `/espec-archive-clean [capability]` |
| Who | A developer runs it. The Engineering Manager or Architect confirms the verdicts and owns requirements that have no owner. |
| Input | Nothing, for every spec, or a capability name to limit the run |
| Output | `espec/changes/archive/YYYY-MM-DD-archive-clean/cleanup.md`: summary counts, one table per capability, other findings. After confirmation: the confirmed edits to `espec/specs/`, pruned archive folders, and an `## Applied actions` list appended to the report. |
| Time | Thirty minutes per capability to read and confirm. The run itself depends on the size of the specs and the code. |
| Rules | [AGENTS.md, Archive clean rules](../../template/espec/AGENTS.md#archive-clean-rules-especarchive-clean) and [conventions.md, Archive clean verdicts](../conventions.md#archive-clean-verdicts) |

## When to run it

Not per feature. Pick a rhythm and write it in `espec/project.md`:

- **Per release** or **monthly**, over every capability, when the specs are small.
- **Before a tech proposal** on a capability nobody has touched for a while, limited to that
  capability. A proposal written against a stale spec traces to requirements the code no longer has.
- **After a large removal** (a module deleted, a product line sunset), to catch the requirements the
  removal's delta did not list.
- **As a baseline** when adopting espec on an existing codebase; see
  [the FAQ on migration](../faq.md#how-do-we-migrate-an-existing-codebase) for the change-based
  way to do it so that main specs still only change through archive.

## Before you start

- `main`, pulled, on a fresh branch. The report and the applied edits go in one pull request.
- No archive in flight for the capabilities you will clean. Archive first; clean after.
- You know who confirms. The report is cheap; the confirmation is the work.

## Run it

```text
/espec-archive-clean payment-reminders
```

### The report

It inventories every requirement and scenario, then gathers evidence per requirement: code that
implements the behaviour (names, routes, messages, flags, error texts, UI copy), the tests that
exercise it, the archived change that added or last modified it, archived or active changes whose
deltas contradict or supersede it, duplicates across capabilities, deprecation markers whose date has
passed. Active changes count: a requirement about to be removed by an active change is **Keep** for
now, with a note.

Each requirement gets one verdict with its evidence:

| Verdict | When | On confirmation |
|---|---|---|
| **Keep** | Code and tests implement it, nothing contradicts it | Nothing |
| **Update** | Still true in part. The report gives the corrected requirement text in full, scenarios included | The block is replaced in place |
| **Purge** | No code, no tests, superseded, duplicated, or deprecated past its sunset | The block is removed. The last requirement in a capability deletes its folder |

Two guardrails apply on every run: a requirement with no evidence either way is **Update** with a
note asking for an owner, never Purge; and a requirement that an active change still references in
its traceability table is never purged.

It also flags capabilities whose Purpose is a placeholder, duplicate requirement names, requirements
without scenarios, and archived change folders older than
`archive.clean.prune_archived_changes_older_than_days` when that setting is above zero.

The report is written to `espec/changes/archive/YYYY-MM-DD-archive-clean/cleanup.md` and shown in
the chat. Then it stops.

### Confirm

Read the report with the person who confirms. For each Update, read the corrected text against the
evidence. For each Purge, open the evidence: the deleted file in the archived change, the test that
no longer exists. The worked example
[cleanup.md](../../examples/archive-clean/cleanup.md) shows a Keep, an Update with the corrected
text, a Purge with the archived change that deleted the code, and the applied actions.

Answer: "Apply all", "Apply only Keep and Update", "Apply a selection" or "Report only". A selection
names the requirements. "Report only" is a valid outcome; the report is still committed as the record.

### Apply

Only what was confirmed, one capability at a time: Update replaces the block, Purge removes it, Prune
deletes the listed archive folders. Untouched lines stay exactly as they were. After each capability
it re-checks that every remaining requirement has a scenario and that names are unique. Then it
appends `## Applied actions` to the same `cleanup.md`, one line per action with the file touched, and
reports counts: kept, updated, purged, pruned, skipped and why.

### Commit

```bash
espec/bin/espec validate
git add espec
git commit -m "Archive clean: payment-reminders"
```

The pull request carries the report and the spec edits together. The reviewer is the person who
confirmed; the review is a check that the diff matches the applied actions list.

## What good looks like

- Every verdict has evidence a reviewer can open: a path, a test name, an archived change folder.
- No Purge rests on "could not find it". Absence of evidence is Update with an owner question.
- The corrected text under Update describes what the code does, not what someone wishes it did.
- `## Applied actions` matches the diff line for line.
- The specs read true afterwards: a new developer could use `espec/specs/` to learn the system.

## Scheduling the report

The report can run on a schedule, for example monthly as a pull request opened by the Copilot coding
agent, limited to one capability per run so it stays reviewable. The confirmation cannot be
scheduled. A human reads the report and says what to apply.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| Purge verdicts with "no code found" and nothing else | The search was shallow | Reject. Ask it to search for the messages, routes and flags named in the scenarios, and to cite what it looked at |
| The report covers forty requirements and nobody reads it | Scope too wide | Re-run per capability. One capability, one pull request |
| An Update rewrites the requirement's meaning | It fixed what it would have preferred | Reject that row. Update corrects what the evidence shows is wrong, nothing more |
| A requirement is flagged Update "needs owner" every run | Nobody owns it | The reviewer names an owner in `espec/project.md` under Teams and ownership, or decides to purge with that as the evidence |
| The clean touched an active change's requirement | It should not have | Revert that edit. Active traceability references protect a requirement; check `.espec.yaml` and the proposals' tables |
