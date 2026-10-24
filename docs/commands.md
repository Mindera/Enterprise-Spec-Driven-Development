# Commands

Five commands, one per step of the workflow, plus an optional CLI. Canonical names use a colon.
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
| GitHub Copilot Chat (VS Code, JetBrains, Visual Studio) | `/espec-<name>` | `/espec-tech-proposal BILL-142` |
| Atlassian Rovo | An agent you @-mention in Rovo Chat or from a Jira issue. No slash commands. | `@Feature Definition define invoice CSV export` |
| Microsoft 365 Copilot | An agent from Copilot agent builder, or the prompt pasted at the start of a chat. No slash commands. | `@Feature Definition define invoice CSV export` |

Only phase 1 runs in Rovo and M365 Copilot. Phases 2 to 4 need the repository and run in GitHub Copilot.

## Summary

| Command | Phase | Who | Input | Writes |
|---|---|---|---|---|
| `/espec:feature-definition` | 1 | PM, Designer. A developer in-repo. | Idea, ticket key, URL or pasted definition | Ticket description. In-repo also `feature.md` and `.espec.yaml` |
| `/espec:tech-proposal` | 2 | Developer, QA | Ticket key, URL, change name or pasted definition | `tech-proposal.md`, `specs/`, `tasks.md`, `.espec.yaml` |
| `/espec:implementation` | 3 | Developer, QA | Change name | Code, tests, `tasks.md`, `.espec.yaml` |
| `/espec:archive` | 4 | Developer | Change name | `espec/specs/`, the archived folder, a release note |
| `/espec:archive-clean` | 4 | Developer | Optional capability name | `cleanup.md`, then confirmed edits to `espec/specs/` |

## /espec:feature-definition

| | |
|---|---|
| GitHub Copilot | `/espec-feature-definition <source>` |
| Prompt file | [template/.github/prompts/espec-feature-definition.prompt.md](../template/.github/prompts/espec-feature-definition.prompt.md) |
| Product tools | [product-ai/rovo/feature-definition-agent.md](../product-ai/rovo/feature-definition-agent.md), [product-ai/m365-copilot/feature-definition-agent.md](../product-ai/m365-copilot/feature-definition-agent.md), [product-ai/prompts/feature-definition.prompt.md](../product-ai/prompts/feature-definition.prompt.md) |
| Who runs it | Product Manager. Designer for the Experience and design section, with the design-notes agent. A developer when the work has no product owner. |
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
| Output | The list of files written, the Questions for Product ready to paste as a ticket comment, and the line "Review the tech proposal. When approved, run `/espec:implementation <change-name>`." |

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
| Writes | Application code and tests. `tasks.md`: `- [ ]` becomes `- [x]` on the exact line, only after the named verification passed. `.espec.yaml`: `in-progress` after the first check, `implemented` after the last. |
| Pauses when | The gate fails: `.espec.yaml` is not `proposed` or `in-progress`, or `tech-proposal.md` or `tasks.md` is missing. A blocking Question for Product is still open. A task is unclear or contradicts another. The task needs work the proposal or specs do not describe. It is tempted to narrow, defer or simplify specified behaviour. Implementation reveals a design problem. A test fails for a reason outside the task. |
| Output | Progress as `N/M tasks complete` with the next pending tasks. On completion: tasks done this session, anything deferred with the reason, and "All tasks complete. Review, then run `/espec:archive <change-name>`." |

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
| Writes | `espec/specs/<capability>/spec.md` for every capability the deltas touch, in the order RENAMED, REMOVED, MODIFIED, ADDED. A new main spec from `espec/templates/main-spec.md` when the capability is new. `.espec.yaml` gets `status: archived` and `archived: YYYY-MM-DD`. The folder moves to `espec/changes/archive/YYYY-MM-DD-<change-name>/`. |
| Pauses when | Tasks are unchecked: asks whether to archive anyway and records the reason. `tech-proposal.md` or `specs/` is missing without `skip_specs`. Always, after showing the sync plan: "Sync and archive", "Archive without syncing" or "Cancel". A conflict is found: stops before moving anything. Before posting the release note or transitioning the ticket: only when asked. |
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
| `espec init [dir]` | Copies `template/` into a repository and prints the next steps. Never overwrites an existing file. | `.github/` and `espec/` in the target repo |
| `espec update [dir]` | Refreshes the managed files: the `espec-*` prompts, `espec.instructions.md`, the `espec-validate.yml` workflow, `AGENTS.md`, `templates/` and `espec/bin/`. Leaves `copilot-instructions.md`, `project.md`, `config.yaml`, `specs/` and `changes/` alone. | Managed files only |
| `espec new <change-name> [--ticket KEY] [--title "Title"] [dir]` | Scaffolds `espec/changes/<change-name>/` from `espec/templates/`: `feature.md`, `tech-proposal.md`, `tasks.md`, an empty `specs/` and a `.espec.yaml` with the ticket, title and today's date. The name must be kebab-case. | `espec/changes/<change-name>/` |
| `espec list [dir]` | Lists active changes with name, status and ticket from `.espec.yaml` and task progress counted from `tasks.md`, plus the number of archived changes. | Nothing |
| `espec validate [change-name] [dir]` | Checks one change, or every active change, plus the main specs: the feature definition marker, required sections and `UC`, `EC`, `AC` ids, the ⚠️ marker on forced notes, leftover placeholders, delta section names, `#### Scenario:` with four hashes, every requirement has a scenario, a Reason on every REMOVED requirement, unique requirement names, the `- [ ] N.M` task format, and a valid `.espec.yaml` status. Exits non-zero on a failure, so it can run in CI. | Nothing |

`[dir]` defaults to the current directory. `init` and `update` run from the toolkit checkout; `new`,
`list` and `validate` also run from `espec/bin/` inside a project. Run `validate` before you ask for
a tech proposal review. Run `update` after pulling a new espec release, then commit the result.

### Validation in CI

`init` adds `.github/workflows/espec-validate.yml` to the project. It runs `espec/bin/espec validate`
on every pull request that touches `espec/`, and on demand. Because the validator ships with the
project, the job needs no network access and no checkout of this toolkit. A draft change committed
with template placeholders fails the check, which is the point: fill the definition in, or keep the
draft on a branch until it is ready.
