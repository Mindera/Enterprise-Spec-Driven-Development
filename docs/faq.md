# FAQ

Short answers. The rules behind them are in
[template/espec/AGENTS.md](../template/espec/AGENTS.md).

## Why can't Product Managers just use GitHub Copilot?

In most large enterprises GitHub Copilot is licensed per developer seat and tied to membership of the
GitHub organisation. Product Managers and Designers get Microsoft 365 Copilot or Atlassian Rovo with
the licences they already have, and they work in Jira, Confluence and Teams, not in repositories.
espec accepts that boundary instead of fighting it. Phase 1 runs where product already works. The
ticket is the bridge. A PM who does have Copilot and repository access can run phase 1 in-repo; the
format is the same.

## What if the PM insists on a technical solution?

The AI says the sentence looks like a how, offers to rephrase it as an outcome, and asks once whether
to force it. On a clear yes, it is recorded under `## Forced technical notes` as `FT-n` with the ⚠️
marker and the reason. Every other section stays clean. The tech proposal must mark each `FT-n`
Accepted or Overridden with a reason. Nothing is lost, nothing is hidden, and engineering keeps the
last word on how. See [conventions.md](conventions.md#product-boundary-and-forced-technical-notes).

## Can a developer start a feature?

Yes. Run `/espec-feature-definition` in the repository with a one-line idea. The same
interview and the same format apply, and the result is stored in
`espec/changes/<change-name>/feature.md`. Paste it into a ticket so product can review and own it.
A definition nobody from product has read is still a draft.

## What if there is no ticket yet?

Use a verb-first change name such as `add-invoice-csv-export`. When the ticket exists, put its key or
URL in `.espec.yaml` under `ticket` and rename the folder to the key-based name before the tech
proposal goes to review. The AI never creates or updates a ticket without being asked.

## What about pure refactors, tooling and docs changes?

Set `skip_specs: true` in `.espec.yaml` and create no `specs/` folder. A tech proposal and tasks are
still useful when you want the plan reviewed. Archive moves the folder without touching the main
specs. Do not invent a requirement to fill a folder. If the refactor does change observable
behaviour, it is not a pure refactor: write the delta.

## What about bug fixes?

Same phases, less paper. Start the change with `espec/bin/espec new <name> --kind bug`: `feature.md`
comes from the bug template (who is affected, expected versus actual behaviour, steps to reproduce,
acceptance criteria) and the tech proposal needs only Context with the root cause, Approach,
Traceability, Test strategy and Questions for Product. The first task reproduces the bug in a failing
test. When the main specs already describe the correct behaviour, set `skip_specs: true` and name that
scenario in the Traceability table; the code was wrong, not the spec. When they do not, the intended
behaviour was never written down: write the delta like any change. See
[Bug fixes](../template/espec/AGENTS.md#bug-fixes).

## Two changes edit the same requirement at the same time?

Both deltas copy the requirement as it was when each proposal was written, so the second archive
would overwrite the first one's edit. The base stamp prevents that: `espec stamp` records under each
MODIFIED and REMOVED heading which version of the main spec the delta was written against, and
`espec validate` fails the second change's pull request as soon as the first is archived. Merge the
newer text into the delta, run `espec/bin/espec stamp <change-name> --rebase`, and have the reviewer
look at the merged requirement. See [Base stamps](conventions.md#base-stamps).

## The design changed during implementation. Is the old approval still valid?

No. When a decision, the scope or observable behaviour changes, the tech proposal goes back to
**Status: In review**, the implementation command stops, and the reviewer approves again. A short
follow-up pull request on the proposal is enough. Wording fixes and checked tasks need no
re-approval.

## What if a change is abandoned?

Run `/espec-archive <change-name>` and say it will not ship. It asks for the reason, sets
`status: cancelled` with the date and reason in `.espec.yaml`, moves the folder under
`espec/changes/archive/` without applying its delta specs, and writes a note for the ticket. The folder
stays as a record. A cancelled change never counts as evidence in archive-clean, and it no longer
protects requirements through its traceability table. Deleting the folder instead loses the record of
why the work stopped.

## One feature, several repositories?

One change per repository, same ticket key, same `feature.md` in each. Each repository writes its own
tech proposal, delta specs and tasks for its part. Questions for Product from every repository go to
the same ticket. Each change is archived on its own, and each release note names the repository.
The ticket is closed when the last one ships.

## Can the specs live in a separate repository from the code?

Not as the toolkit is built, and we recommend against it. Every phase after the definition assumes
`espec/` sits next to the code it describes: the tech proposal reads the code to write Context, the
implementation edits code and checks tasks in the same commit, the review tour reads the change folder
from the pull request diff, and archive-clean looks for evidence in the code and tests beside the
specs. Splitting them means two pull requests per step that must stay in step by hand, and a spec
repository that can claim behaviour no code in it proves.

When the code really is spread over many repositories, run espec in each one that owns behaviour, as
in the previous answer, and keep any cross-repository view (a capability map, an architecture page)
as documentation that links to each repository's `espec/specs/`. Decide this before the rollout:
moving specs into code repositories later means rebuilding their history.

## Who approves the tech proposal?

The reviewer the team names, usually the Engineering Manager or Architect, in the pull request that
adds the change folder (or wherever `espec/project.md` says tech proposals are reviewed). Approval
means setting the status line in `tech-proposal.md` to Approved. Conditions: no blocking Question for
Product is open, every `FT-n` has a verdict, the traceability table is complete, and QA has accepted
the test strategy. Product does not approve the how. Product answers the questions.

The status line is text anyone can type. Make it binding in the repository: name the approvers in
`CODEOWNERS` for `espec/changes/**/tech-proposal.md` and turn on "Require review from Code Owners" for
the default branch, so the line cannot reach `main` without their review. See
[Engineering setup](guides/setup-engineering.md#step-5-protect-approval-and-the-main-specs).

## How does QA use this?

QA has a seat in every phase. In phase 1, QA reviews edge cases and acceptance criteria. In phase 2,
QA writes or reviews the test strategy and checks that the `## QA verification` group has one `Q.n`
task per acceptance criterion. In phase 3, QA runs `/espec-implementation <change-name>` and says
"verification only": the AI skips to the `Q.n` tasks, touches no application code, records the
environment and result on each task line, and checks a task only when it passes. The traceability
table is QA's map from acceptance criterion to scenario to task.

## Can we run archive-clean on a schedule?

The report, yes. Applying it, no. Archive-clean writes `cleanup.md` with verdicts and evidence, then
stops and waits for confirmation. A monthly or per-release run that produces the report, for example
as a pull request opened by the Copilot coding agent, is a good habit. A human reads it and confirms
what to apply. Limit a run to one capability to keep it reviewable. Set
`archive.clean.prune_archived_changes_older_than_days` above zero to have old archive folders listed
for pruning too.

## What if a scenario has three hashes?

It is not parsed. `### Scenario:` looks like a requirement heading to the tools, and the real
requirement above it appears to have no scenario, which fails validation and blocks archive. Use
`#### Scenario:` with exactly four `#`. `espec/bin/espec validate` catches this, in CI too, and so does the review
step of the tech proposal.

## Does this need a CLI?

No. The scripts in `bin/` are optional helpers for `init`, `update`, `new`, `list` and `validate`.
The prompts read and write the same files, and a repository set up by copying `template/` by hand
behaves the same. Use the CLI when you want a one-command setup, a quick status across changes, or a
format check in CI.

## How do we migrate an existing codebase?

Do not try to spec everything at once. Pick the capability the next feature will touch and write its
baseline using the same evidence approach archive-clean uses: every requirement cites the code and
tests that prove it. Do it as a change so the rule "never edit `espec/specs/` by hand" still holds:

1. Create a change named `baseline-<capability>` with `espec/bin/espec new` or by hand.
2. Ask Copilot to draft `specs/<capability>/spec.md` as a delta with a `## Purpose` and ADDED
   requirements, from the code and tests. Review every requirement against the evidence.
3. Put one task per scenario in `tasks.md`: "verify the code does this today". Check them as you
   confirm.
4. Archive. The main spec now exists, and the next real change writes MODIFIED and ADDED against it.

Repeat capability by capability. A capability with no main spec yet is created by the first tech
proposal that touches it, so the baseline can also grow as features arrive.

## Jira or GitHub Issues?

Either. Set `tickets.system` in `espec/config.yaml`. Jira pairs well with Rovo, which can write the
description through Jira actions. GitHub Issues pairs well with M365 Copilot plus the issue template
and label, and with the Copilot coding agent, which reads `.github/copilot-instructions.md` and opens
a tech proposal pull request first. Pick whatever product already uses. The format of the feature
definition and everything from phase 2 onward is identical. See
[workflow.md](workflow.md#when-the-ticket-system-is-github-issues).

## What happens when the ticket and feature.md differ?

The AI shows the difference and asks which one wins. Usually the ticket wins, because product edits
there. The losing copy is overwritten so the two are identical again. Never let them drift silently:
a tech proposal written against a stale `feature.md` traces to acceptance criteria that no longer
exist.
