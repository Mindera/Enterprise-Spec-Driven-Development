---
agent: agent
description: "espec phase 4 · Archive clean: find outdated, duplicated or orphaned specs, propose keep / update / purge with evidence, and apply what the user confirms."
---

# /espec:archive-clean

You keep `espec/specs/` honest: after a run it describes only what the system does today.
Read [espec/AGENTS.md](../../espec/AGENTS.md) and [espec/config.yaml](../../espec/config.yaml) first
and follow the **Archive clean rules** section exactly. This is an audit with confirmation, not a sweep.

Input: `${input:scope:Capability name to limit the run, or leave empty for all specs}`

## Steps

1. **Inventory.** List every capability under `espec/specs/` (or the one given) and every
   `### Requirement:` with its scenarios. Count them.

2. **Gather evidence per requirement.** Search for:
   - Code that implements the behaviour (names, routes, messages, flags, error texts, UI copy) and
     tests that exercise it. Cite paths.
   - Archived changes under `espec/changes/archive/` that added or last modified it, and archived or
     active changes whose deltas contradict or supersede it.
   - Duplicates: the same requirement name in another capability, or two requirements with the same
     scenarios in different words.
   - Deprecation markers in the requirement text ("deprecated", "sunset", "until", "legacy") whose
     date has passed.
   Also check `.espec.yaml` files of active changes: a requirement about to be removed by an active
   change is **Keep** for now, with a note. Code behind a flag that is off is still code: Keep. A
   requirement whose archived change says `rollout: reverted` and whose code is gone is a Purge, with
   that change as the evidence.

3. **Classify** every requirement as **Keep**, **Update** (give the corrected requirement text in full,
   scenarios included) or **Purge**, each with its evidence. Flag separately:
   - Capabilities whose `## Purpose` is missing or still a placeholder.
   - Requirements without a scenario.
   - Archived change folders older than `archive.clean.prune_archived_changes_older_than_days` when
     that setting is greater than zero. List them for pruning; keep their spec effects.
   - Archived changes whose `.espec.yaml` has a `metrics_review_due` of today or earlier and no
     `metrics_reviewed`. List each with its ticket, the product owner and the items under Success
     metrics in its `feature.md`. Never list one of these for pruning.
   - Archived changes whose `rollout` is `pending`, `partial` or `withdrawn`. List each with its
     `rollout_note` and its date, oldest first. Never list one of these for pruning either.

4. **Write the report** to `espec/changes/archive/YYYY-MM-DD-archive-clean/cleanup.md` from
   `espec/templates/cleanup.md`, with the summary counts, one table per capability, and the other
   findings. Show it in the chat. Stop here and ask the user to confirm, per capability or in full:
   "Apply all", "Apply only Keep and Update", "Apply a selection", or "Report only".

5. **Apply** only what was confirmed, one capability at a time:
   - Update: replace the requirement block in place with the proposed text.
   - Purge: remove the requirement block. When a capability has no requirement left, delete its folder.
   - Prune: delete the listed archived change folders.
   - Metrics: for each change the user gives an outcome for, set `metrics_reviewed: YYYY-MM-DD` and
     `metrics_outcome` (met, partly met, not met or not measured, with the numbers read) in its
     archived `.espec.yaml`, and print a comment for the ticket: each metric, the number, the
     outcome, and for a metric that was not met the question of what follows. Without an answer,
     change nothing: the change is listed again on the next run.
   - Rollout: for each change the user says where it stands now, set `rollout` and `rollout_note` in
     its archived `.espec.yaml`. A change that was turned off for good, or one reverted while later
     changes built on it, needs a change of its own: say so and point to **Rolling back** in
     AGENTS.md. Never edit `espec/specs/` to undo a change.
   Keep every untouched line exactly as it was. Re-check after each capability that every remaining
   requirement still has a scenario and that names are unique.

6. **Append** an `## Applied actions` list to the same `cleanup.md`: one line per action with the
   file touched. Report counts: kept, updated, purged, pruned, and anything skipped and why.

## Guardrails

- A requirement with no evidence either way is **Update** with a note asking for an owner, never Purge.
- Never purge a requirement that an active change still references in its traceability table.
- Never rewrite a requirement's meaning under Update; fix what the evidence shows is wrong.
- Never touch `espec/changes/<active-change>/` folders.
- The report is the audit trail. Do not apply anything that is not in it.
- Never invent a metric's number or outcome, or where a change is live. Only the people who know can
  say. Recording those answers is the only edit this command makes to an archived change.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
