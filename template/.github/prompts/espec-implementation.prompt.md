---
agent: agent
description: "espec phase 3 · Implementation: implement the tasks of an approved change, following its tech proposal and specs, check tasks off as they are verified, and write a pull request description that reads without the code."
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

2. **Check the gate.** `.espec.yaml` must say `proposed` or `in-progress`, `tech-proposal.md` and
   `tasks.md` must exist, and the status line of `tech-proposal.md` must read **Approved**. A change
   that only has `feature.md` is not ready: point to `/espec:tech-proposal` and stop. A proposal whose
   status line is Draft or In review is not ready either: say so, point to
   `/espec:inspect-tech-proposal` and the reviewer named in `project.md`, and stop. A blocking
   **Question for Product** that is still open in `tech-proposal.md` is a pause: show it and ask
   whether product has answered it.

3. **Start from a new session.** Implementation runs in a new chat or session, so the conversation
   that wrote or discussed the proposal does not steer the code: the files are the only input. When
   this conversation already holds earlier work on the change (a tech proposal, an inspection, a
   discussion of the design), say so and stop with: "Start a new chat or session and run
   `/espec:implementation <change-name>` there." Continue in this session only when the user
   explicitly insists, and say that earlier context may bias the result.

4. **Read the context from disk**: `feature.md`, `tech-proposal.md`, every file under `specs/`, and
   `tasks.md`.

5. **Show progress**: `N/M tasks complete`, the next pending tasks, and the group they belong to.

6. **Implement, task by task, until done or blocked.** For each pending task:
   - Say which task you are working on.
   - Make the smallest change that satisfies the task and the scenarios it cites. For a bug
     (`kind: bug` in `.espec.yaml`), the first task writes a test that reproduces the bug and fails;
     run it and see it fail before you change any code.
   - Run the verification the task names (test, command, observable behaviour).
   - Only then change `- [ ]` to `- [x]` on that exact line. When the line no longer matches the
     task, re-read `tasks.md` and find it again.
   - Set `status: in-progress` in `.espec.yaml` after the first checked task.

7. **Pause and ask** when:
   - A task is unclear, or two tasks contradict each other.
   - The task needs work the tech proposal or specs do not describe.
   - You are tempted to narrow, defer, simplify or accept an exception to specified behaviour.
   - Implementation reveals a design problem. Propose the artifact change; do not improvise around it.
     When the user accepts a change to the tech proposal, the delta specs or the tasks that alters a
     decision, scope or observable behaviour, set the status line of `tech-proposal.md` to
     **In review**, make the change, and stop: the reviewer approves again before implementation
     continues. A wording fix or a new task that changes none of those does not need re-approval.
   - A test fails for a reason outside the task.
   Surface the issue, give options, and wait.

8. **QA verification group.** Treat `Q.n` tasks like any other: run the scenario, record what you
   observed in the task line (environment, result), and check it only when it passes. When the user is
   QA or asks for verification only, skip to this group and do not touch application code.

9. **Validate security (mobile apps, optional).** When every task is checked, or before a pull
   request is written early, and `security.tool` in `config.yaml` is `mobile-security-assessment`,
   follow the **Security validation** section of AGENTS.md. With `none`, skip the step.
   - **Access first.** Run `gh repo view <security.repo>`. When the GitHub CLI is missing, not signed
     in, or the command fails, the user has no access to the private tool: say "Security validation
     skipped: no access to <security.repo>", attach nothing, and go to step 10. Never ask for
     credentials or another account.
   - **Platforms.** Use `security.platforms`; when empty, detect them from the tree (`build.gradle*`
     or `AndroidManifest.xml`: android, `*.xcodeproj` or `Package.swift`: ios, `commonMain`: kmp) and
     say what you detected. No mobile platform: "Security validation skipped: not a mobile app".
   - **Run it.** Clone or update the tool outside the project, read its `AGENTS.md` and follow its
     **Running an assessment for a user** section: a virtualenv, `msa doctor`, the provider you run
     on, one `msa assess` call with `--path <repository> --platform <platform>` per platform and
     `--out` in a temporary folder outside the repository. When `msa doctor` names missing tools, pause:
     list them and ask whether to install them or skip. A skipped run is recorded as skipped, with the
     reason, never as passed.
   - **Fix what the change caused.** Compare every `File:LINE` in the deduction ledger of `report.md`
     with `git diff --name-only <review.base>...HEAD`. A finding whose evidence is in a file the change
     touches belongs to this change: add a task to a `## Security` group in `tasks.md` (`S.1`, `S.2`),
     fix it, run the assessment again and check the task only when the finding is gone. A finding in a
     file the change did not touch is pre-existing: do not fix it here (step 7), report it.
   - **Record the outcome** in the **Security validation** section of `pull-request.md` (step 10).
     Findings remain, pre-existing or declined by the user: copy `report.md` to
     `espec/changes/<change-name>/security-report.md`, write the alert line
     "⚠️ Security findings: fix before merge", the scorecard, one row per finding (row, weakness,
     `File:LINE`, standard, in this change or pre-existing) and a link to `security-report.md`. No
     findings: write "Security validation passed: <platforms>, <tool> <rubric version>, <date>" and
     attach nothing. Skipped: "Security validation skipped: <reason>".
   - The assessment is static. Never probe the app's backend or any host the report names, and never
     copy a secret value into the report, the tasks or the chat: the tool cites where a secret is.

10. **Write the pull request description.** When every task is checked, or when the user stops early
   and asks for a pull request anyway, write `pull-request.md` from
   `espec/templates/pull-request.md`, following the Pull request description format in AGENTS.md.
   Re-read `tech-proposal.md` from disk and compare it with what you actually built: every decision,
   endpoint, data model element, rollout step and forced note gets a row, "As proposed" or the
   difference with its reason. One row per acceptance criterion under Behaviour delivered, each with
   the file a reviewer opens first and the test and `Q.n` task that verify it. A reader must be able to
   understand the change without opening the code. Print the file, and the command to use it:
   `gh pr create --body-file espec/changes/<change-name>/pull-request.md`.

11. **Assess coverage.** Re-read `feature.md`, `tech-proposal.md`, every file under `specs/`,
   `tasks.md` and `pull-request.md` from disk. For every `AC-n`: the file, the test and whether it
   passed in this session, the `Q.n` line and whether it is checked. For every item in Proposal versus
   implementation: as proposed, differs with a reason, or differs without one. Close the gaps you can:
   a difference without a row gets its row, a test that did not run runs now. Print the report in the
   **Implementation coverage** format of AGENTS.md. Print it also when the user stops early, with the
   open tasks counted as not delivered.

12. **On completion**, set `status: implemented` in `.espec.yaml` and report: tasks completed this
   session, overall progress, anything deferred with the reason, the security validation outcome
   (passed, skipped with the reason, or the number of findings and the alert), and
   "All tasks complete. Review, then run `/espec:archive <change-name>`."
   When `review.tool` in `config.yaml` is `diffcompass`, add the review command for the reviewer:
   `/espec:review <change-name>`, which runs `diffcompass pr <number> --open` once the pull request
   exists and `diffcompass --base <review.base> --open` before. Do not launch the tour yourself unless
   the user asks for a walkthrough.

## Guardrails

- Follow the tech proposal. When you disagree with it, say so and ask; do not quietly do it differently.
- Never silently reduce scope. Never check a task that is partially done.
- Keep changes scoped to the task. Refactors outside the task are a new task, proposed to the user.
- Keep `tasks.md` as the single progress record. Update it immediately after each task.
- Compute the coverage report from the files and the test runs of this session, not from memory. An
  acceptance criterion whose test did not run is Partial, whatever the code looks like.
- `pull-request.md` never says "see code" or "self-explanatory". Every row names a file, a test or a
  result. The **Security validation** section is never empty: passed, skipped with the reason, or the
  alert with the findings. "Passed" is written only after the tool ran on every platform. A difference
  from the tech proposal that changes observable behaviour also updates the change's delta specs,
  which you propose and the user confirms.
- Do not edit `espec/specs/` in this phase. Behaviour changes go in the change's delta specs, and
  that is a tech proposal update, which you propose and the user confirms. After editing a MODIFIED
  or REMOVED requirement, run `espec/bin/espec stamp <change-name>`.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
