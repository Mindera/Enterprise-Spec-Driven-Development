---
agent: agent
description: "espec review · Start a DiffCompass tour of an implementation pull request or branch, primed with its change folder. Read-only; launches the tour and prints what to check first."
---

# /espec:review

You start the code review of an implemented change with DiffCompass. You change nothing. Read
[espec/AGENTS.md](../../espec/AGENTS.md) and [espec/config.yaml](../../espec/config.yaml) first and
follow the **Pull request description format** and **Reviewing the code** sections.

Input: `${input:target:Pull request number or URL, branch or change name (leave empty for the current branch). In a spec hub: code pull request URL, then the change name}`

**Spec hub.** When `repos:` in `config.yaml` lists repositories, the code lives in `repos/<name>` and
its pull request does not contain the change folder. The input is then a code pull request URL,
optionally followed by the change name. Steps 1 to 5 below say what differs.

## Steps

1. **Check the tool.** `review.tool` in `config.yaml` must be `diffcompass`. When it is `none`, say so,
   point to the manual path in **Reviewing the code** (read `pull-request.md`, then follow
   **How to review**: entry points, the core, then tests) and stop. Run `diffcompass doctor`. When the
   command is missing or the doctor fails, show its output, point to
   [DiffCompass](https://github.com/Mindera/diffcompass) for installation and stop. When
   `.diffcompass.json` is missing at the repository root, warn that the tour will not read the change
   folder and suggest copying it from the toolkit template. In a spec hub, check
   `repos/<name>/.diffcompass.json` instead and suggest copying
   `espec/templates/code-repo.diffcompass.json` into the code repository.

2. **Resolve the target.**
   - A pull request number or URL: use it.
   - A branch: look up its open pull request with `gh pr view <branch>` when the GitHub CLI is
     available. Use the pull request when there is one, otherwise the branch.
   - A change name: find the branch or pull request that touches `espec/changes/<change-name>/`, and
     ask when there is more than one.
   - Empty: the current branch, resolved as above.
   - Spec hub: match the pull request URL to a repo in `repos:` by its `url`. When none matches, ask.
     When `repos/<name>` is missing, ask the user to run `espec/bin/espec repos` and stop.
   Announce "Reviewing: pull request <number>" or "Reviewing: <branch> against <review.base>".

3. **Find the change.** List the folders under `espec/changes/` the diff touches, excluding
   `archive/`. Exactly one is expected; name it. None means the diff is not an espec change: say the
   tour will run without a change folder and continue. More than one: list them and continue.
   In a spec hub the diff never touches the change folder. Use the change name from the input;
   otherwise take the ticket key from the branch name or the pull request body and find the change
   whose `.espec.yaml` has that ticket. Ask when nothing matches.

4. **Check the description.** For the change found, read `.espec.yaml`, `tasks.md` and
   `pull-request.md` from disk on the reviewed branch. Report, without blocking the tour:
   - `.espec.yaml` is not at `implemented`, or tasks are unchecked: say how many.
   - `pull-request.md` is missing or lacks a section: name it and point to `/espec:implementation`.
   - The pull request body differs from `pull-request.md`: say so. The description is the review's map.
   - The **Security validation** section carries the alert: say how many findings sit in files the diff
     touches. Each is a change request until fixed. Skipped: say why, so the reviewer knows no
     assessment ran.
   In a spec hub, read these files from the hub checkout, count only unchecked tasks in the
   `[<name>]` groups for this repo, and compare the pull request body with this repo's block in
   `pull-request.md`. Report when the body does not link the hub change folder.

5. **Launch the tour.** In the terminal, run `diffcompass pr <number> --open` for a pull request, or
   `diffcompass --base <review.base> --open` for a branch. It keeps running while the tour is open in
   the local browser; leave it running. When you cannot run commands, print the command instead.
   In a spec hub, run it from `repos/<name>` after `git fetch`, with `--base origin/<branch>` for a
   branch. Then print a short brief to paste into the tour's Ask panel: the change name, the
   acceptance criteria and decisions that concern this repo, and the hub path of the change folder.

6. **Report.** Print:
   - The command that was run and the change folder.
   - The first pass, before the diff: read `pull-request.md` top to bottom, accept or question every
     "differs" row in **Proposal versus implementation**, and pick the three acceptance criteria in
     **Behaviour delivered** most likely to be wrong.
   - What the tour flags: code that differs from the tech proposal or the delta specs without a row,
     behaviour no acceptance criterion or scenario describes, a named test missing from the diff, any
     edit to `espec/specs/`, and the security findings of `pull-request.md` the diff does not fix.
   - "Approve in the pull request. After the merge, run `/espec:archive <change-name>`."

## Guardrails

- Read-only. Do not edit code, tests, the change folder, `.diffcompass.json` or the pull request. Fixes
  go back to the author through `/espec:implementation`.
- Do not approve, request changes or comment on the pull request. The reviewer decides, in the pull
  request.
- Do not review the diff yourself in the chat instead of the tour. When the tour cannot start, say why
  and point to the manual path.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
