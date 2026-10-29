# Step 8: Archive

The finished change is folded into the main specs: its delta specs are applied to `espec/specs/` in
a fixed order, the change folder moves under `espec/changes/archive/` with a date prefix, and a
release note goes to the ticket. After this step `espec/specs/` describes the system as it is today,
and the next tech proposal reads it.

| | |
|---|---|
| Command | `/espec-archive <change-name>` |
| Who | The developer who implemented the change, after the pull request is merged |
| Input | A change at `implemented` with every task checked and `pull-request.md` present |
| Output | `espec/specs/<capability>/spec.md` updated for every capability the deltas touch. The folder at `espec/changes/archive/YYYY-MM-DD-<change-name>/` with `.espec.yaml` at `archived`. A release note. |
| Time | Ten minutes, plus a short pull request |
| Rules | [AGENTS.md, Archive rules](../../template/espec/AGENTS.md#archive-rules-especarchive) and [conventions.md, Archive merge order and conflicts](../conventions.md#archive-merge-order-and-conflicts) |

## Before you start

- The implementation pull request is merged. Archiving before the merge puts spec changes on `main`
  that the code does not back yet.
- You are on `main`, pulled, on a fresh branch:

```bash
git checkout main && git pull
git checkout -b espec/bill-142-archive
```

- `espec/bin/espec validate <change-name>` passes.

## Run it

```text
/espec-archive bill-142-invoice-csv-export
```

### Completion check

It counts the checkboxes in `tasks.md`. With unchecked tasks it lists them and asks whether to
archive anyway; a yes records the reason in the release note and in `.espec.yaml` under
`archived_with_open_tasks`. Archiving early is allowed and visible, never silent. A missing
`tech-proposal.md`, or missing `specs/` without `skip_specs: true`, is a warning and a question.

When the change will not ship, say so here. The command asks for the reason, records
`status: cancelled` with the date and reason, skips the sync, moves the folder and writes a ticket
note saying what was cancelled and why. The deltas of a cancelled change are never applied, and the
folder stays as the record of why the work stopped.

### The sync plan

For every `specs/<capability>/spec.md` in the change it locates the main spec and lists what will
happen: requirements renamed, removed, modified, added, or a new main spec created from the delta's
Purpose and ADDED requirements. It also lists conflicts:

| Situation | Result |
|---|---|
| A MODIFIED or REMOVED heading is not in the main spec | Conflict. Stop. |
| A MODIFIED or REMOVED base stamp no longer matches the main spec | Conflict. Stop. Another change edited the requirement after this delta was written |
| The delta only MODIFIES or REMOVES, and the capability has no main spec | Conflict. Stop. |
| An ADDED heading is already present with identical content | Already synced. Skip it. |
| An ADDED heading is already present with different content | Conflict. Stop. |

A conflict stops the archive before anything moves. Nothing is half applied. Fix the delta (usually
a heading that drifted by a word, or a capability that was renamed by another change since the
proposal) and run again. For a stamp conflict, merge the main spec's newer text into the delta so
neither change's edit is lost, run `espec/bin/espec stamp <change-name> --rebase`, and have the
reviewer read the merged requirement. `espec validate` reports all of these in CI as soon as the
other change is archived, so they rarely first appear here.

**Read the plan.** It is the last moment to catch a delta that would overwrite a requirement with a
partial block. Then answer: "Sync and archive", "Archive without syncing" (for a change whose specs
were already applied another way; it asks why and records the reason as `archived_without_sync` in
`.espec.yaml` and in the release note) or "Cancel".

### Apply, verify, move

The deltas are applied one capability at a time in the order RENAMED, REMOVED, MODIFIED, ADDED,
matching headings by exact text. Everything the delta does not mention stays as it was, Purpose
included. Base stamp lines stay in the archived delta; they never reach a main spec. Each touched
main spec is then verified: no delta headings remain, every requirement has a
scenario, names are unique, and a second pass finds nothing left to apply. Only then does the folder
move to `espec/changes/archive/YYYY-MM-DD-<change-name>/`, with `status: archived` and the date in
`.espec.yaml`. An existing archive folder is never overwritten.

### The release note

It starts from the `## Release note` section of `pull-request.md` and updates it for anything that
changed since: what shipped, which capabilities changed (added, modified, removed requirements by
name), what was deferred and why. Paste it as the closing comment on the ticket and move the ticket
to Done. When Copilot can reach the ticket and you ask, it posts the comment and transitions the
ticket; it never does so unasked.

### Commit

```bash
espec/bin/espec validate
git add espec
git commit -m "Archive bill-142-invoice-csv-export"
```

Open a short pull request. The reviewer reads the diff of `espec/specs/`: it should read like the
delta did, nothing more. Merge.

## What good looks like

- The "Archive complete" block names the archive path, the capabilities synced and the task count.
- `git diff main -- espec/specs/` shows exactly the delta's requirements, in place, and no delta
  headings.
- The archived folder still holds everything: `feature.md`, the proposal, the deltas, `tasks.md` with
  QA's recorded results, `pull-request.md`, any saved inspection reports, and `.espec.yaml` as the
  audit record.
- The ticket's last comment is the release note, and its status is Done.

See the main specs after archive in [examples/specs/](../../examples/README.md).

## Hand-off

Nothing per feature. The next tech proposal that touches these capabilities reads the updated main
specs. On a rhythm, [archive clean](09-archive-clean.md).

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| Conflict: MODIFIED heading not found | Another change renamed or removed the requirement since the proposal, or the heading differs by a character | Open the main spec, fix the heading in the delta (or add a RENAMED entry), run again |
| Conflict: ADDED heading exists with different content | Two changes added the same requirement with different wording | Decide which text is right; make the delta MODIFIED with the full block, or drop it |
| The main spec lost scenarios after the sync | A MODIFIED block was partial | Revert the archive commit. Fix the delta to carry the whole requirement. Archive again |
| Two changes touch the same capability | Normal | Archive in merge order. The second archive reads the main spec as the first left it. When both edited the same requirement, the second change's base stamp no longer matches: merge, then `stamp --rebase` |
| CI: "espec/specs/ changed, but no change was archived in this pull request" | A main spec was edited by hand | Revert the edit. Put the change in a delta and archive it, or run archive-clean for corrections |
| A bad archive reached `main` | Wrong delta, or the wrong change | Revert the archive commit (it holds both the spec edits and the folder move), fix the delta, archive again |
| The folder already exists under archive with today's date | A previous run moved it | Nothing to do, unless the sync did not happen: check the main spec, then move on |
| Archive ran before the implementation merged | Order mistake | Revert the archive commit on `main`; run again after the merge |
| The change will not ship | Scope dropped or superseded | Run `/espec-archive` and say so: it cancels the change with the reason and touches no spec. Do not delete the folder |
