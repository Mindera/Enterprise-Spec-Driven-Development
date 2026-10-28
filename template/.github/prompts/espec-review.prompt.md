---
mode: agent
description: "espec review · Start a DiffCompass tour of an implementation pull request or branch, primed with its change folder. Read-only; launches the tour and prints what to check first."
---

# /espec:review

You start the code review of an implemented change with DiffCompass. You change nothing. Read
[espec/AGENTS.md](../../espec/AGENTS.md) and [espec/config.yaml](../../espec/config.yaml) first and
follow the **Pull request description format** and **Reviewing the code** sections.

Input: `${input:target:Pull request number or URL, branch or change name (leave empty for the current branch)}`

## Steps

1. **Check the tool.** `review.tool` in `config.yaml` must be `diffcompass`. When it is `none`, say so,
   point to the manual path in **Reviewing the code** (read `pull-request.md`, then follow
   **How to review**: entry points, the core, then tests) and stop. Run `diffcompass doctor`. When the
   command is missing or the doctor fails, show its output, point to
   [DiffCompass](https://github.com/Mindera/diffcompass) for installation and stop. When
   `.diffcompass.json` is missing at the repository root, warn that the tour will not read the change
   folder and suggest copying it from the toolkit template.

2. **Resolve the target.**
   - A pull request number or URL: use it.
   - A branch: look up its open pull request with `gh pr view <branch>` when the GitHub CLI is
     available. Use the pull request when there is one, otherwise the branch.
   - A change name: find the branch or pull request that touches `espec/changes/<change-name>/`, and
     ask when there is more than one.
   - Empty: the current branch, resolved as above.
   Announce "Reviewing: pull request <number>" or "Reviewing: <branch> against <review.base>".

3. **Find the change.** List the folders under `espec/changes/` the diff touches, excluding
   `archive/`. Exactly one is expected; name it. None means the diff is not an espec change: say the
   tour will run without a change folder and continue. More than one: list them and continue.

4. **Check the description.** For the change found, read `.espec.yaml`, `tasks.md` and
   `pull-request.md` from disk on the reviewed branch. Report, without blocking the tour:
   - `.espec.yaml` is not at `implemented`, or tasks are unchecked: say how many.
   - `pull-request.md` is missing or lacks a section: name it and point to `/espec:implementation`.
   - The pull request body differs from `pull-request.md`: say so. The description is the review's map.

5. **Launch the tour.** In the terminal, run `diffcompass pr <number> --open` for a pull request, or
   `diffcompass --base <review.base> --open` for a branch. It keeps running while the tour is open in
   the local browser; leave it running. When you cannot run commands, print the command instead.

6. **Report.** Print:
   - The command that was run and the change folder.
   - The first pass, before the diff: read `pull-request.md` top to bottom, accept or question every
     "differs" row in **Proposal versus implementation**, and pick the three acceptance criteria in
     **Behaviour delivered** most likely to be wrong.
   - What the tour flags: code that differs from the tech proposal or the delta specs without a row,
     behaviour no acceptance criterion or scenario describes, a named test missing from the diff, and
     any edit to `espec/specs/`.
   - "Approve in the pull request. After the merge, run `/espec:archive <change-name>`."

## Guardrails

- Read-only. Do not edit code, tests, the change folder, `.diffcompass.json` or the pull request. Fixes
  go back to the author through `/espec:implementation`.
- Do not approve, request changes or comment on the pull request. The reviewer decides, in the pull
  request.
- Do not review the diff yourself in the chat instead of the tour. When the tour cannot start, say why
  and point to the manual path.
- End the reply with the usage line from the **Usage report** section of AGENTS.md.
