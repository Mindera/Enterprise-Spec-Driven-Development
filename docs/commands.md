# Commands

Five commands, one per step of the workflow, three read-only commands (a technical assessment and two
inspections), a review command that starts the DiffCompass tour, plus an optional CLI. Canonical names use a colon.
In GitHub Copilot Chat the same command is typed with a dash, because prompt file names cannot
contain `:`. Rovo and M365 Copilot have no slash commands. There the command is an agent you
@-mention or a prompt you paste.

Every command reads `espec/AGENTS.md`, `espec/project.md` and `espec/config.yaml` before it writes
anything. The rules are in [template/espec/AGENTS.md](../template/espec/AGENTS.md). This page is the
quick reference.

## Spelling per tool

| Tool | Spelling | Example |
|---|---|---|
| Documentation (canonical) | `/espec:<name>` | `/espec:tech-proposal` |
| GitHub Copilot Chat (IDE or Terminal) | `/espec-<name>` | `/espec-tech-proposal BILL-142` |
| Atlassian Rovo | An agent you @-mention in Rovo Chat or from a Jira issue. No slash commands. | `@Feature Definition define invoice CSV export` |
| Microsoft 365 Copilot | An agent from Copilot agent builder, or the prompt pasted at the start of a chat. No slash commands. | `@Feature Definition define invoice CSV export` |

Only phase 1 runs in Rovo and M365 Copilot. Phases 2 to 4 need the repository and run in GitHub Copilot.

## Summary

| Command | Phase | Who | Input | Writes |
|---|---|---|---|---|
| `/espec:feature-definition` | 1 | PM, Designer. A developer in-repo. | Idea, ticket key, URL or pasted definition | Ticket description. In-repo also `feature.md` and `.espec.yaml` |
| `/espec:tech-proposal` | 2 | Developer, QA | Ticket key, URL, change name or pasted definition | `tech-proposal.md`, `specs/`, `tasks.md`, `.espec.yaml` |
| `/espec:implementation` | 3 | Developer, QA | Change name | Code, tests, `tasks.md`, `pull-request.md`, `.espec.yaml` |
| `/espec:archive` | 4 | Developer | Change name | `espec/specs/`, the archived folder, a release note |
| `/espec:archive-clean` | 4 | Developer | Optional capability name | `cleanup.md`, then confirmed edits to `espec/specs/` |
| `/espec:inspect-feature-definition` | before 2 | Developer, QA, reviewer | Ticket key, URL, pasted definition or change name | Nothing. A report and a ticket comment in the chat |
| `/espec:assess` | before 2 | Developer, with Product, Design, QA and the owning teams | Ticket key, URL, pasted definition or change name | Nothing. A report and a ticket comment in the chat |
| `/espec:inspect-tech-proposal` | before 3 | QA, Engineering Manager, Architect | Change name | Nothing. A report and a ticket comment in the chat |
| `/espec:review` | after 3 | Reviewer | Pull request number or URL, branch or change name | Nothing. Launches the DiffCompass tour |

Every command ends with a usage line, such as `Usage: 3 premium requests (GitHub Copilot)`, so
developers see what each run cost. When the tool does not show usage to the agent, the line says so
and points to where the developer can check it. The agent never estimates the figure. See
[Usage report](../template/espec/AGENTS.md#usage-report).

`/espec:tech-proposal` and `/espec:implementation` also end with a **coverage report**, printed just
before the usage line: how much of the feature definition the proposal covers (every `UC`, `EC` and
`AC` as Covered, Partial or Missing, every constraint and forced note as Addressed or No home), and
how much of the proposal and the feature definition the implementation delivers (every `AC` as
Delivered, Partial or Not delivered, every proposal item as proposed or differing with a reason). Each
starts with a match figure, such as `12 of 13 product ids covered (92%)`. It is a self-check computed
from the files on disk, saved only on request, and never an approval: the inspection and the code
review verify the same claims. See [Coverage report](../template/espec/AGENTS.md#coverage-report)
and the worked examples in [examples/coverage/](../examples/coverage/).

## /espec:feature-definition

| | |
|---|---|
| GitHub Copilot | `/espec-feature-definition <source>` |
| Prompt file | [template/.github/prompts/espec-feature-definition.prompt.md](../template/.github/prompts/espec-feature-definition.prompt.md) |
| Product tools | [product-ai/rovo/feature-definition-agent.md](../product-ai/rovo/feature-definition-agent.md), [product-ai/m365-copilot/feature-definition-agent.md](../product-ai/m365-copilot/feature-definition-agent.md), [product-ai/prompts/feature-definition.prompt.md](../product-ai/prompts/feature-definition.prompt.md) |
| Who runs it | Product Manager. Designer for the UI design section, with the UI design agent. A developer when the work has no product owner. |
| Input | One of: a one-line idea (Draft mode), a ticket key, URL or pasted definition (Import mode), an existing `feature.md` (Review mode). The AI says which mode it picked. |
| Reads | In-repo: `espec/AGENTS.md`, `project.md`, `config.yaml`. The ticket, when a tool can reach it. |
| Writes | The feature definition, printed as one Markdown block to paste into the ticket. In-repo: `espec/changes/<change-name>/feature.md` and `.espec.yaml` with `status: defined` when the definition is ready. |
| Pauses when | Interviewing, at most four questions per round. A how is stated: it quotes it, offers an outcome rephrasing, and asks once whether to force it. The change folder already exists: asks whether to update or create new. Before updating a ticket: always asks. |
| Output | The document, the review checklist as ✅ / ❌ lines with a one-line fix each, and the status: Draft or Ready for tech proposal. |

It never writes a tech proposal, specs, tasks or code. Asked to, it points to `/espec:tech-proposal`
and stops.

## /espec:tech-proposal

| | |
|---|---|
| GitHub Copilot | `/espec-tech-proposal <source>` |
| Prompt file | [template/.github/prompts/espec-tech-proposal.prompt.md](../template/.github/prompts/espec-tech-proposal.prompt.md) |
| Who runs it | Developer. QA for the test strategy. |
| Input | A change name under `espec/changes/`, a ticket key or URL, or a pasted feature definition. A ticket or pasted text triggers the Import mode of phase 1 first. |
| Reads | `AGENTS.md`, `project.md`, `config.yaml` (the `context` and the `tech-proposal`, `specs` and `tasks` rules). `feature.md` from disk. Every main spec that covers part of the behaviour. The modules, tests and configuration the feature touches. |
| Writes | Inside `espec/changes/<change-name>/` only: `tech-proposal.md`, `specs/<capability>/spec.md` per capability, `tasks.md`, and `.espec.yaml` with `status: proposed` and the engineering and QA owners. With no behaviour change: `skip_specs: true` and no `specs/` folder. |
| Pauses when | The feature definition is not Ready for tech proposal: lists the gaps and asks whether to continue (each gap becomes a Question for Product). An ambiguity would change scope, observable behaviour, compatibility or acceptance criteria. Nothing usable was given as input. |
| Output | The list of files written, the Questions for Product ready to paste as a ticket comment, the coverage report (every `UC`, `EC` and `AC` as Covered, Partial or Missing with the match figure, every constraint and `FT-n` as Addressed or No home, a short judgement), and the line "Review the tech proposal. When approved, start a new chat or session and run `/espec:implementation <change-name>` there, so this conversation does not steer the code." |

Planning only. It never edits application code. It never leaves "explore the codebase" or "decide
the approach" as a task.

## /espec:implementation

| | |
|---|---|
| GitHub Copilot | `/espec-implementation <change-name>` |
| Prompt file | [template/.github/prompts/espec-implementation.prompt.md](../template/.github/prompts/espec-implementation.prompt.md) |
| Who runs it | Developer. QA, in verification-only mode, for the `## QA verification` group. |
| Input | A change name. Empty input auto-selects when exactly one active change exists, otherwise asks. |
| Reads | `AGENTS.md`, `project.md`, `config.yaml` (the `implementation` rules). Then from disk: `feature.md`, `tech-proposal.md`, every file under `specs/`, `tasks.md`. |
| Writes | Application code and tests. `tasks.md`: `- [ ]` becomes `- [x]` on the exact line, only after the named verification passed. `pull-request.md` at the end: a description a reviewer can read without the code, with a proposal-versus-implementation table, one row per acceptance criterion, verification, rollout and a release note. `.espec.yaml`: `in-progress` after the first check, `implemented` after the last. |
| Pauses when | The conversation already holds earlier work on the change: it asks for a new chat or session. The gate fails: `.espec.yaml` is not `proposed` or `in-progress`, `tech-proposal.md` or `tasks.md` is missing, or the status line of `tech-proposal.md` is not Approved. A blocking Question for Product is still open. A task is unclear or contradicts another. The task needs work the proposal or specs do not describe. It is tempted to narrow, defer or simplify specified behaviour. Implementation reveals a design problem. A test fails for a reason outside the task. |
| Output | Progress as `N/M tasks complete` with the next pending tasks. On completion: `pull-request.md` printed with `gh pr create --body-file espec/changes/<change-name>/pull-request.md`, tasks done this session, anything deferred with the reason, and "All tasks complete. Review, then run `/espec:archive <change-name>`." With `review.tool: diffcompass` in `config.yaml`, `/espec:review <change-name>` for the reviewer. At the end of every session, finished or stopped early, the coverage report: every `AC` as Delivered, Partial or Not delivered with its file, test and `Q.n`, every proposal item as proposed or differing with a reason, and the match figure. |

It never edits `espec/specs/`. A behaviour change found during implementation goes into the change's
delta specs as a proposed tech proposal update, which the user confirms.

## /espec:archive

| | |
|---|---|
| GitHub Copilot | `/espec-archive <change-name>` |
| Prompt file | [template/.github/prompts/espec-archive.prompt.md](../template/.github/prompts/espec-archive.prompt.md) |
| Who runs it | Developer. |
| Input | A change name. Empty input auto-selects when exactly one active change exists. |
| Reads | `AGENTS.md`. `tasks.md` (checkbox count), `.espec.yaml`, every delta under `specs/`, and the matching main specs in `espec/specs/`. |
| Writes | `espec/specs/<capability>/spec.md` for every capability the deltas touch, in the order RENAMED, REMOVED, MODIFIED, ADDED. A new main spec from `espec/templates/main-spec.md` when the capability is new. `.espec.yaml` gets `status: archived` and `archived: YYYY-MM-DD`. The folder moves to `espec/changes/archive/YYYY-MM-DD-<change-name>/`. A change that will not ship gets `status: cancelled` with the date and reason and moves without a sync. |
| Pauses when | Tasks are unchecked: asks whether to archive anyway and records the reason. The user says the change will not ship: asks for the reason and cancels it. `tech-proposal.md` or `specs/` is missing without `skip_specs`. Always, after showing the sync plan: "Sync and archive", "Archive without syncing" (asks for the reason and records it) or "Cancel". A conflict is found: stops before moving anything. Before posting the release note or transitioning the ticket: only when asked. |
| Output | An "Archive complete" block: change, archive path, specs synced or skipped, task count. A release note for the ticket: what shipped, which capabilities changed, what was deferred. |

## /espec:archive-clean

| | |
|---|---|
| GitHub Copilot | `/espec-archive-clean [capability]` |
| Prompt file | [template/.github/prompts/espec-archive-clean.prompt.md](../template/.github/prompts/espec-archive-clean.prompt.md) |
| Who runs it | Developer. The Engineering Manager or Architect confirms the verdicts. |
| Input | A capability name to limit the run, or nothing for every spec. |
| Reads | `AGENTS.md`, `config.yaml` (`archive.clean.prune_archived_changes_older_than_days`). Every main spec. The code and tests. Archived changes. Active changes and their `.espec.yaml` and traceability tables. |
| Writes | `espec/changes/archive/YYYY-MM-DD-archive-clean/cleanup.md` from `espec/templates/cleanup.md`: summary counts, one table per capability, other findings. After confirmation: the confirmed Update and Purge edits in `espec/specs/`, pruned archive folders, and an `## Applied actions` list appended to the same `cleanup.md`. |
| Pauses when | Always, after the report: "Apply all", "Apply only Keep and Update", "Apply a selection" or "Report only". |
| Output | The report in the chat, then the counts: kept, updated, purged, pruned, skipped and why. |

An audit with confirmation, not a sweep. A requirement with no evidence either way is **Update** with
a note asking for an owner, never Purge.

## /espec:inspect-feature-definition

| | |
|---|---|
| GitHub Copilot | `/espec-inspect-feature-definition <source>` |
| Prompt file | [template/.github/prompts/espec-inspect-feature-definition.prompt.md](../template/.github/prompts/espec-inspect-feature-definition.prompt.md) |
| Product tools | The same checks run from Rovo or M365 Copilot with [product-ai/prompts/review-feature-definition.prompt.md](../product-ai/prompts/review-feature-definition.prompt.md) |
| Who runs it | A developer or QA before starting the tech proposal. Any reviewer of the ticket. |
| Input | A ticket key or URL (fetched when a tool can reach it, otherwise pasted), a pasted definition, or a change name whose `feature.md` is read from disk. |
| Reads | `AGENTS.md`, the definition, and the ticket when reachable. |
| Writes | Nothing. On request, saves the report to `espec/changes/<change-name>/inspections/`. |
| Checks | The readiness checklist, hows outside the forced notes, `UC`/`EC` coverage by `AC`, absent edge cases from the standard list, acceptance criteria that cannot be observed or measured. |
| Output | The Feature definition inspection report: checklist, product boundary, coverage, edge cases to consider, testability, numbered findings marked Blocking or Advisory, the verdict (Ready for tech proposal, or Draft) and a comment to paste on the ticket. |

## /espec:assess

| | |
|---|---|
| GitHub Copilot | `/espec-assess <source>` |
| Prompt file | [template/.github/prompts/espec-assess.prompt.md](../template/.github/prompts/espec-assess.prompt.md) |
| Who runs it | A developer, after the feature definition inspection and before the tech proposal. Product, Design, QA and the owning teams answer what it raises. |
| Input | A ticket key or URL (fetched when a tool can reach it, otherwise pasted), a pasted definition, or a change name whose `feature.md` is read from disk. |
| Reads | `AGENTS.md`, `project.md`, `config.yaml`, the definition, the ticket when reachable, every main spec under `espec/specs/` the feature could touch, and the code and tests behind each acceptance criterion and constraint. |
| Writes | Nothing. On request, saves the report to `espec/changes/<change-name>/inspections/YYYY-MM-DD-assess.md`. |
| Checks | For each `AC-n` and constraint, what exists in the code and tests, with paths; which capabilities in `espec/specs/` the feature touches; dependencies outside the repository, listed as unconfirmed with an owner to ask; alternatives with their consequences for product; criteria that cannot be met as written, with an outcome rephrasing; spikes with what each proves. |
| Output | The Technical assessment report: the tables, numbered findings marked Blocking or Advisory, the outcome (Ready for tech proposal, or Further discovery required) and a comment to paste on the ticket. |

It makes no design decision: the choice and its reasons belong to the tech proposal. Code evidence
never confirms another team's commitment, and an alternative is not a requirement until product
accepts it in the ticket.

## /espec:inspect-tech-proposal

| | |
|---|---|
| GitHub Copilot | `/espec-inspect-tech-proposal <change-name>` |
| Prompt file | [template/.github/prompts/espec-inspect-tech-proposal.prompt.md](../template/.github/prompts/espec-inspect-tech-proposal.prompt.md) |
| Who runs it | QA, the Engineering Manager or the Architect before approving the proposal. The author, before asking for review. |
| Input | A change name. Empty input auto-selects when exactly one active change has a `tech-proposal.md`. |
| Reads | `AGENTS.md`, then from disk `.espec.yaml`, `feature.md`, `tech-proposal.md`, every delta under `specs/`, `tasks.md`, and the ticket when reachable. |
| Writes | Nothing. On request, saves the report to `espec/changes/<change-name>/inspections/`. |
| Checks | Ticket versus `feature.md`; every `UC`, `EC` and `AC` traced to a scenario, tasks and a `Q.n` line, verified against the files rather than the table; every `FT-n` accepted or overridden with a reason; every decision with alternatives; every constraint and metric with a home; specs complete and well formed; test strategy and QA group complete; open questions. |
| Output | The Tech proposal inspection report: the comparison, the tables, numbered findings marked Blocking or Advisory, the verdict (Approve, or Not yet) and a comment to paste on the ticket. |

All three are read-only. Fixes go through `/espec:feature-definition`, `/espec:tech-proposal` or the
ticket. Worked example reports: [examples/inspections/](../examples/inspections/).

## /espec:review

| | |
|---|---|
| GitHub Copilot | `/espec-review [target]` |
| Prompt file | [template/.github/prompts/espec-review.prompt.md](../template/.github/prompts/espec-review.prompt.md) |
| Who runs it | The reviewer of the implementation pull request. The author, to preview the tour before asking for review. |
| Input | A pull request number or URL, a branch, or a change name. Empty input uses the current branch, and its open pull request when there is one. |
| Reads | `AGENTS.md`, `config.yaml` (`review.tool`, `review.base`), `.diffcompass.json`, and for the change the diff touches: `.espec.yaml`, `tasks.md` and `pull-request.md`. |
| Writes | Nothing. Runs `diffcompass pr <number> --open` for a pull request, or `diffcompass --base <review.base> --open` for a branch. |
| Pauses when | `review.tool` is `none`: points to the manual review. `diffcompass doctor` fails: points to the install instructions. A change name matches more than one branch or pull request: asks which. |
| Output | The command it ran, the change folder, warnings (status not `implemented`, unchecked tasks, `pull-request.md` missing a section or different from the pull request body), and what to check in the first pass. |

It never approves, comments on or edits the pull request. The decision stays with the reviewer, in
the pull request.

## The espec CLI (optional)

The CLI is a bash script and a PowerShell script with the same behaviour. Nothing in the workflow
needs them. The prompts read and write the same files. Use the CLI to set a repository up and to
check formats before a review.

The scripts live in [template/espec/bin/](../template/espec/bin/), so `init` copies them into every
project at `espec/bin/`. [bin/espec](../bin/espec) and [bin/espec.ps1](../bin/espec.ps1) at the root
of this toolkit are wrappers around them.

```bash
bash bin/espec init path/to/repo        # from the toolkit checkout: macOS, Linux, Git Bash
pwsh bin/espec.ps1 init path/to/repo    # from the toolkit checkout: PowerShell
```

```bash
bash espec/bin/espec validate           # from inside a project, no toolkit needed
```

| Command | What it does | Touches |
|---|---|---|
| `espec init [dir]` | Copies `template/` into a repository and prints the next steps. Never overwrites an existing file. Copies the licence to `espec/LICENSE.md` and records the toolkit version in `espec/.toolkit-version`. | `.github/` and `espec/` in the target repo |
| `espec update [dir]` | Refreshes the managed files: the `espec-*` prompts, `espec.instructions.md`, the `espec-validate.yml` workflow, `AGENTS.md`, `templates/`, `espec/bin/`, `espec/LICENSE.md` and `espec/.toolkit-version`, and prints the version it moves from and to. Leaves `copilot-instructions.md`, `CODEOWNERS`, `project.md`, `config.yaml`, `specs/` and `changes/` alone. | Managed files only |
| `espec version [dir]` | Prints the toolkit version the project was set up or last updated with. | Nothing |
| `espec new <change-name> [--ticket KEY] [--title "Title"] [--kind feature\|bug] [dir]` | Scaffolds `espec/changes/<change-name>/` from `espec/templates/`: `feature.md` (from `bug.md` with `--kind bug`), `tech-proposal.md`, `tasks.md`, an empty `specs/` and a `.espec.yaml` with the ticket, title, kind and today's date. The name must be kebab-case. | `espec/changes/<change-name>/` |
| `espec stamp <change-name> [--rebase] [dir]` | Writes the [base stamp](conventions.md#base-stamps) under every MODIFIED and REMOVED requirement of the change's deltas. Refuses to replace a stamp whose main spec requirement has changed since, unless `--rebase` is given after the delta has been merged with the newer text. | The change's delta specs |
| `espec list [dir]` | Lists active changes with name, status and ticket from `.espec.yaml` and task progress counted from `tasks.md`, plus the number of archived changes. | Nothing |
| `espec validate [change-name] [dir]` | Checks one change, or every active change, plus the main specs: the feature definition marker, required sections and `UC`, `EC`, `AC` ids, the ⚠️ marker on forced notes, leftover placeholders, delta section names, `#### Scenario:` with four hashes, every requirement has a scenario, a Reason on every REMOVED requirement, unique requirement names, every delta still applying to the main spec as it is today (MODIFIED, REMOVED and RENAMED headings present, ADDED headings not present with other content, base stamps matching), no base stamp left in a main spec, the `- [ ] N.M` task format, the sections and status line of `tech-proposal.md` with every `UC`, `EC` and `AC` in its Traceability table and every `FT-n` in its review (Approved once implementation has started), a valid `.espec.yaml` status and kind (a bug needs Steps to reproduce and `AC` ids instead of `UC` and `EC`, and a shorter proposal), and the sections of `pull-request.md` once a change is implemented. Exits non-zero on a failure, so it can run in CI. | Nothing |

`[dir]` defaults to the current directory. `init` and `update` run from the toolkit checkout; `new`,
`list`, `validate`, `stamp` and `version` also run from `espec/bin/` inside a project. Run `validate` before you ask for
a tech proposal review. Run `update` after pulling a new espec release, then commit the result.

### Validation in CI

`init` adds `.github/workflows/espec-validate.yml` to the project. It runs `espec/bin/espec validate`
on every pull request that touches `espec/`, and on demand. On a pull request it also fails when
`espec/specs/` changes but nothing was added under `espec/changes/archive/`: main specs change only
through archive and archive-clean. Because the validator ships with the
project, the job needs no network access and no checkout of this toolkit. A draft change committed
with template placeholders fails the check, which is the point: fill the definition in, or keep the
draft on a branch until it is ready.
