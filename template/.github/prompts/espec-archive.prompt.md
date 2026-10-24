---
mode: agent
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

3. **Plan the spec sync.** For every `specs/<capability>/spec.md` in the change:
   - Locate `espec/specs/<capability>/spec.md`.
   - List what will happen: requirements renamed, removed, modified, added; a new main spec created
     from `## Purpose` plus ADDED requirements when none exists.
   - Detect conflicts as defined in AGENTS.md (MODIFIED or REMOVED heading missing in the main spec,
     MODIFIED or REMOVED against a capability with no main spec, ADDED heading already present with
     different content). A conflict stops the archive. Nothing has moved yet, so the user can fix
     the delta and run again.
   - Show the combined plan and ask: "Sync and archive", "Archive without syncing", or "Cancel".

4. **Apply the sync** (only after "Sync and archive"), one capability at a time, in the order
   RENAMED → REMOVED → MODIFIED → ADDED. Match headings by exact text after trimming whitespace.
   Keep everything the delta does not mention exactly as it was, including the existing `## Purpose`.
   A new main spec starts from `espec/templates/main-spec.md`, takes the delta's Purpose verbatim, and
   gets a `## Requirements` section holding the ADDED requirements.

5. **Verify** each touched main spec: no delta headings remain (`## ADDED Requirements`,
   `## MODIFIED Requirements`, `## REMOVED Requirements`, `## RENAMED Requirements`), every
   requirement has at least one `#### Scenario:`, requirement names are unique. Then re-run the plan
   from step 3 and confirm there is nothing left to apply. Any mismatch: report and stop before moving.

6. **Move the change.** Target is `espec/changes/archive/YYYY-MM-DD-<change-name>/` using today's
   date, unless the name already starts with a date. Refuse to overwrite an existing folder. Set
   `status: archived` and `archived: YYYY-MM-DD` in `.espec.yaml` before moving.

7. **Release note.** Print a short note for the ticket: what shipped, which capabilities changed
   (added, modified, removed requirements by name), what was deferred and why. When a tool can reach
   the ticket and the user asks, post it as a comment and transition the ticket. Never do so unasked.

## Output on success

```markdown
## Archive complete

**Change:** <change-name>
**Archived to:** espec/changes/archive/<YYYY-MM-DD-change-name>/
**Specs:** ✓ synced (<capabilities>) | no delta specs | sync skipped
**Tasks:** 12/12 complete | archived with 2 open tasks: <reason>
```

## Guardrails

- Never archive while a spec sync is half applied. Verify, then move.
- Never delete a requirement the delta does not list under REMOVED or RENAMED.
- Never invent a current version for a MODIFIED requirement that has no main spec.
- Keep `.espec.yaml` with the folder; it is the audit record.
