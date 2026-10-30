---
agent: agent
description: "espec phase 2 · Tech Proposal: turn a feature definition into the how (architecture, APIs, data, decisions), delta specs and an implementation task list."
---

# /espec:tech-proposal

You are writing the **how** for a feature that product has already defined. You produce planning
artifacts only: `tech-proposal.md`, delta specs under `specs/`, and `tasks.md`. You do not edit
application code in this phase.

Read [espec/AGENTS.md](../../espec/AGENTS.md), [espec/project.md](../../espec/project.md) and
[espec/config.yaml](../../espec/config.yaml) first. Apply the `context` and the `tech-proposal`,
`specs` and `tasks` rules from `config.yaml`. Do not paste them into the artifacts.

Input: `${input:source:Change name, ticket key or URL, or a pasted feature definition}`

## Steps

1. **Resolve the change.**
   - A change name that exists under `espec/changes/` → use it. Announce "Using change: <name>".
   - A ticket key, URL or pasted definition → run the Import mode of
     `/espec:feature-definition` first (fetch or ask for the text, review it, store
     `feature.md` and `.espec.yaml`), then continue.
   - A bug report (a ticket that describes broken behaviour rather than a feature) → create the
     change with `espec/bin/espec new <name> --kind bug` (or `espec.ps1`), fill `feature.md` from the
     report in the bug format of AGENTS.md, and continue. **Bug fixes** in AGENTS.md says what is
     different from here on.
   - Nothing usable → ask for one of the above and stop.

   When `tech-proposal.md` already exists and its status line reads **Approved**, this run revises an
   approved proposal: set the status line to **In review** before changing anything, and say so in
   the report. The reviewer approves again; implementation stops until they do.

2. **Check readiness.** Re-read `feature.md` from disk. Run the review checklist from the feature
   definition prompt. When the definition is not Ready for tech proposal, list the gaps and ask whether
   to continue anyway. When continuing, every gap becomes a line under **Questions for Product**.

3. **Explore the code before writing.** Read `project.md`, then the modules, tests, configuration and
   documentation that the feature touches. Record what you observed with file paths; distinguish
   observed facts from assumptions. Check `espec/specs/` for capabilities that already cover part of
   the behaviour and reuse their exact names and paths.

4. **Write `tech-proposal.md`** from `espec/templates/tech-proposal.md`, following the Tech proposal
   format in AGENTS.md. In particular:
   - Every `D-n` decision lists alternatives and why they lost.
   - Review every `FT-n` from `feature.md` as Accepted or Overridden with a reason. Omit the section
     when there are none.
   - The traceability table covers every `UC-n`, `EC-n` and `AC-n`. Anything that cannot be traced
     becomes a Question for Product.
   - The test strategy is written for QA: how each scenario is verified, at which level, with what data.
   - Questions for Product are written so they can be pasted as a ticket comment.

5. **Write the delta specs.** One file per capability at `specs/<capability>/spec.md`, from
   `espec/templates/spec.md`, following the Delta spec format. New capability → include `## Purpose`.
   Existing capability → copy the whole requirement block from `espec/specs/<capability>/spec.md`
   before editing it under `## MODIFIED Requirements`. Every acceptance criterion maps to at least one
   scenario, and every scenario uses `#### Scenario:` with four hashes. When the change has no
   observable behaviour change, set `skip_specs: true` in `.espec.yaml`, create no `specs/` folder and
   say so.
   Then record the base of every MODIFIED and REMOVED requirement: run
   `espec/bin/espec stamp <change-name>` (`espec\bin\espec.ps1 stamp <change-name>` on Windows). It
   writes `<!-- espec:base <hash> -->` under each heading. When you cannot run commands, tell the
   developer to run it before the proposal pull request; `espec validate` fails without it. When stamp
   reports that a requirement changed in the main spec, re-read it, merge the new text into the delta,
   and run `stamp <change-name> --rebase`.

6. **Write `tasks.md`** from `espec/templates/tasks.md`, following the Tasks format. Each task states
   its verification. Each group lands its own tests. Tasks cite the `AC-n` and `EC-n` they satisfy.
   The `## QA verification` group has one line per acceptance criterion plus the non-functional checks
   from the test strategy.

7. **Update `.espec.yaml`**: `status: proposed`, engineering owner, and a `qa` owner when known.

8. **Assess coverage.** Re-read `feature.md`, `tech-proposal.md`, every file under `specs/` and
   `tasks.md` from disk. For every `UC-n`, `EC-n` and `AC-n`, find the scenario, the tasks and the
   `Q.n` line under the names you used; for every constraint, success metric, design item and `FT-n`,
   find where the proposal addresses it. Close the gaps you can now: write the missing scenario, task
   or `Q.n` line, give a homeless constraint a home. What you cannot close becomes a Question for
   Product. Then print the report in the **Tech proposal coverage** format of AGENTS.md.

9. **Report.** List the files written, the open Questions for Product (ready to paste), and stop with:
   "Review the tech proposal. When approved, start a new chat or session and run
   `/espec:implementation <change-name>` there, so this conversation does not steer the code."

## Guardrails

- Planning only. Do not create or modify files outside `espec/changes/<change-name>/` in this phase.
- Ask before writing when an ambiguity would change scope, observable behaviour, compatibility or
  acceptance criteria. Record minor assumptions in the proposal.
- Never leave "explore the codebase" or "decide the approach" as tasks. Do that now.
- Do not restate the why. Link to `feature.md`.
- Read existing main specs in full before writing a delta against them. Never write or edit a base
  stamp by hand; `espec stamp` computes it.
- Compute the coverage report from the files, not from what you meant to write. A Partial you cannot
  close now stays a Partial; the inspection and the reviewer check the same claims.
- End the reply with the usage line from the **Usage report** section of AGENTS.md.
