---
agent: agent
description: "espec phase 4 · Archive: fold a finished change's delta specs into the main specs and move the change to the archive."
---

# /espec:archive

You archive a finished change: its delta specs become part of `espec/specs/`, and the change folder
moves under `espec/changes/archive/`. Read [espec/AGENTS.md](../../espec/AGENTS.md) first and follow
the **Archive rules** section exactly.

Input: `${input:change:Change name (leave empty to pick from the active changes)}`

## Steps

1. **Select the change.** Use the name given, infer from the conversation, auto-select when exactly
   one active change exists, otherwise ask. Announce "Using change: <name>".

2. **Check completion.**
   - Count checkboxes in `tasks.md`. Only `[x]` or `[X]` counts as done.
   - Unchecked tasks: list them and ask whether to archive anyway. On yes, record the reason in the
     release note and in `.espec.yaml` under `archived_with_open_tasks: <reason>`.
   - Missing `tech-proposal.md` or (without `skip_specs: true`) missing `specs/`: warn and ask.
   - Missing `pull-request.md`: warn; the release note is then written from scratch in step 7. An
     urgent change (`lane: urgent`) has none: write the release note from the proposal, and name the
     merged pull request.
   - When a tool can reach the ticket, compare its description with `feature.md` from `# Feature:`
     down. A difference is a pause: show it and ask. What the ticket asks for beyond `feature.md` was
     not built: name it in the release note as not part of this change, which needs a change of its
     own. A stale ticket: offer to update its description from `feature.md`, on yes only. The ticket
     is never closed on a description that differs from what shipped without someone having seen it.
   - **Acceptance.** Look for the acceptance of the result, as **Product acceptance and success
     metrics** in AGENTS.md defines it: an answer on the ticket from the accepter (the product owner
     in `feature.md`, the reporter of a bug, the person in `declared_by` of an urgent change) when a
     tool can read the ticket's comments, otherwise ask who accepted and when. Found: set
     `accepted_by` and `accepted` in `.espec.yaml`. Not found: say so, print the acceptance request
     and ask whether to wait or to archive anyway. Archiving anyway records the reason as
     `archived_without_acceptance` and in the release note.
   - **Success metrics.** For each item under Success metrics in `feature.md`: the number, the date
     it can first be read and who reads it. Ask for a date the definition does not give. Set
     `metrics_review_due` in `.espec.yaml` to the latest of them. No metrics: set nothing.
   - The user says the change will not ship, or `.espec.yaml` already says `status: cancelled`: ask
     for the reason, set `status: cancelled`, `cancelled: YYYY-MM-DD` and `cancelled_reason: <reason>`,
     skip steps 3 to 5, move the folder as in step 6, and write the ticket note in step 7 as what was
     cancelled and why. The deltas of a cancelled change are never applied.

3. **Plan the spec sync.** For every `specs/<capability>/spec.md` in the change:
   - Locate `espec/specs/<capability>/spec.md`.
   - List what will happen: requirements renamed, removed, modified, added; a new main spec created
     from `## Purpose` plus ADDED requirements when none exists.
   - Detect conflicts as defined in AGENTS.md (MODIFIED or REMOVED heading missing in the main spec,
     MODIFIED or REMOVED against a capability with no main spec, ADDED heading already present with
     different content, a base stamp that no longer matches the main spec). Run
     `espec/bin/espec validate <change-name>` when you can run commands; it reports all of them. A
     conflict stops the archive. Nothing has moved yet, so the user can fix the delta and run again.
     For a stamp conflict, another change has edited the requirement since this delta was written:
     show both versions, merge the newer main spec text into the delta with the user, then run
     `espec/bin/espec stamp <change-name> --rebase`.
   - Show the combined plan and ask: "Sync and archive", "Archive without syncing", or "Cancel".
     "Archive without syncing" is for deltas already applied another way. Ask for the reason and
     record it in `.espec.yaml` as `archived_without_sync: <reason>` and in the release note.

4. **Apply the sync** (only after "Sync and archive"), one capability at a time, in the order
   RENAMED → REMOVED → MODIFIED → ADDED. Match headings by exact text after trimming whitespace.
   Keep everything the delta does not mention exactly as it was, including the existing `## Purpose`.
   Never copy a `<!-- espec:base ... -->` stamp line into a main spec; it belongs to the delta.
   A new main spec starts from `espec/templates/main-spec.md`, takes the delta's Purpose verbatim, and
   gets a `## Requirements` section holding the ADDED requirements.

5. **Verify** each touched main spec: no delta headings remain (`## ADDED Requirements`,
   `## MODIFIED Requirements`, `## REMOVED Requirements`, `## RENAMED Requirements`), every
   requirement has at least one `#### Scenario:`, requirement names are unique, no base stamp line
   remains. Then compare each main spec with the plan from step 3: removed requirements and the old
   names of renamed ones are absent; added, modified and new renamed requirements are present with
   the delta's text. Do not re-run the step 3 conflict checks on the synced spec: a REMOVED heading
   that is now missing is the expected result, not a conflict. Any mismatch with the plan: report and
   stop before moving.

6. **Move the change.** Target is `espec/changes/archive/YYYY-MM-DD-<change-name>/` using today's
   date, unless the name already starts with a date. Refuse to overwrite an existing folder. Set
   `status: archived` and `archived: YYYY-MM-DD` in `.espec.yaml` before moving. A cancelled change
   keeps `status: cancelled` and gets no `archived` date.

7. **Release note.** Start from the `## Release note` section of `pull-request.md` when the file
   exists, and update it for anything that changed since. Otherwise write a short note for the
   ticket: what shipped, which capabilities changed (added, modified, removed requirements by name),
   what was deferred and why. Add who accepted the result and when, or that it was archived without
   acceptance and why, and, when the change has success metrics, a "To check after release" list:
   each metric, its date and who reads it. When a tool can reach
   the ticket and the user asks, post it as a comment and transition the ticket. Never do so unasked.

## Output on success

```markdown
## Archive complete

**Change:** <change-name>
**Archived to:** espec/changes/archive/<YYYY-MM-DD-change-name>/
**Specs:** ✓ synced (<capabilities>) | no delta specs | sync skipped: <reason> | not applied (cancelled)
**Tasks:** 12/12 complete | archived with 2 open tasks: <reason>
**Accepted:** <name>, <YYYY-MM-DD> | archived without acceptance: <reason>
**Metrics review due:** <YYYY-MM-DD> | no success metrics
```

## Guardrails

- Never archive while a spec sync is half applied. Verify, then move.
- Never delete a requirement the delta does not list under REMOVED or RENAMED.
- Never invent a current version for a MODIFIED requirement that has no main spec.
- Keep `.espec.yaml` with the folder; it is the audit record.
- Never record an acceptance nobody gave. A merged pull request is not an acceptance.
- A cancelled change keeps every file; nothing in it is deleted and nothing from it reaches
  `espec/specs/`.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
