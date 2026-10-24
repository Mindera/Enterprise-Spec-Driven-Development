---
mode: agent
description: "espec phase 3 · Implementation: implement the tasks of an approved change, following its tech proposal and specs, checking tasks off as they are verified."
---

# /espec:implementation

You implement an approved change, task by task, following its tech proposal and delta specs.
Read [espec/AGENTS.md](../../espec/AGENTS.md), [espec/project.md](../../espec/project.md) and
[espec/config.yaml](../../espec/config.yaml) first. Apply the `implementation` rules from `config.yaml`.

Input: `${input:change:Change name (leave empty to pick from the active changes)}`

## Steps

1. **Select the change.** Use the name given. Otherwise infer it from the conversation, auto-select
   when exactly one folder under `espec/changes/` (excluding `archive/`) is not archived, and ask when
   it is ambiguous. Announce "Using change: <name>" and how to override.

2. **Check the gate.** `.espec.yaml` must say `proposed` or `in-progress`, and `tech-proposal.md`
   and `tasks.md` must exist. A change that only has `feature.md` is not ready: point to
   `/espec:tech-proposal` and stop. A blocking **Question for Product** that is still open in
   `tech-proposal.md` is a pause: show it and ask whether product has answered it.

3. **Read the context from disk**: `feature.md`, `tech-proposal.md`, every file under `specs/`, and
   `tasks.md`. Do not rely on what you remember from earlier in the conversation.

4. **Show progress**: `N/M tasks complete`, the next pending tasks, and the group they belong to.

5. **Implement, task by task, until done or blocked.** For each pending task:
   - Say which task you are working on.
   - Make the smallest change that satisfies the task and the scenarios it cites.
   - Run the verification the task names (test, command, observable behaviour).
   - Only then change `- [ ]` to `- [x]` on that exact line. When the line no longer matches the
     task, re-read `tasks.md` and find it again.
   - Set `status: in-progress` in `.espec.yaml` after the first checked task.

6. **Pause and ask** when:
   - A task is unclear, or two tasks contradict each other.
   - The task needs work the tech proposal or specs do not describe.
   - You are tempted to narrow, defer, simplify or accept an exception to specified behaviour.
   - Implementation reveals a design problem. Propose the artifact change; do not improvise around it.
   - A test fails for a reason outside the task.
   Surface the issue, give options, and wait.

7. **QA verification group.** Treat `Q.n` tasks like any other: run the scenario, record what you
   observed in the task line (environment, result), and check it only when it passes. When the user is
   QA or asks for verification only, skip to this group and do not touch application code.

8. **On completion**, set `status: implemented` in `.espec.yaml` and report: tasks completed this
   session, overall progress, anything deferred with the reason, and
   "All tasks complete. Review, then run `/espec:archive <change-name>`."

## Guardrails

- Follow the tech proposal. When you disagree with it, say so and ask; do not quietly do it differently.
- Never silently reduce scope. Never check a task that is partially done.
- Keep changes scoped to the task. Refactors outside the task are a new task, proposed to the user.
- Keep `tasks.md` as the single progress record. Update it immediately after each task.
- Do not edit `espec/specs/` in this phase. Behaviour changes go in the change's delta specs, and
  that is a tech proposal update, which you propose and the user confirms.
