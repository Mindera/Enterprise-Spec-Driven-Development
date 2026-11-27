# Workflow

espec takes a feature from an idea to a living specification in four phases. Product owns phase 1.
Engineering owns phases 2 to 4. The two sides may use different AI tools, so the hand-off between
them is a ticket written in a fixed format that any assistant can read and any human can review.

Product starts in one of two ways. Without GitHub Copilot, Product Managers and Designers use the
agents in Rovo or M365 Copilot. With GitHub Copilot, they run `/espec:feature-definition`, one command
for the definition and its UI design, in a local copy of the repository and commit nothing. Both
streams end with the definition on the ticket and join at the readiness check, which a developer runs.
From there the flow is the same.

The formats and rules live in [template/espec/AGENTS.md](../template/espec/AGENTS.md). This page
explains how the phases connect across roles and tools. For the commands see
[commands.md](commands.md). For the formats see [conventions.md](conventions.md). For a walkthrough of
each step, with setup and common problems, see [guides/README.md](guides/README.md).

## The flow

```mermaid
flowchart TB
  subgraph Product["Product · two ways to start"]
  subgraph ProductA["Without GitHub Copilot · Rovo or M365"]
    direction TB
    PMA["Product Manager<br/>@espec Feature Definition<br/>what and why, never how"]
    DSA["Designer<br/>@espec UI Design, from the Figma frames"]
    PMA --> DSA
  end

  subgraph ProductB["With GitHub Copilot · nothing committed"]
    direction TB
    PMB["Product Manager and Designer<br/>/espec:feature-definition<br/>what and why, never how,<br/>then the Figma frames and a design interview"]
  end
  end

  subgraph Ticket["Ticket · Jira or GitHub Issue"]
    direction TB
    TK["Description = feature definition<br/>Status: Ready for tech proposal"]
    TA["Comment: Technical assessment"]
    TQ["Comment: Questions for Product"]
    TR["Comment: Release note"]
  end

  subgraph Eng["Engineering · GitHub Copilot"]
    direction TB
    RC["Readiness check: /espec:inspect-feature-definition<br/>both streams join here"]
    AS["Phase 1, developer assessment: /espec:assess<br/>what exists, dependencies, alternatives, spikes"]
    TP["Phase 2: Tech Proposal<br/>tech-proposal.md, delta specs, tasks.md"]
    IM["Phase 3: Implementation<br/>code and tests, tasks checked off"]
    AR["Phase 4: Archive<br/>deltas folded into main specs"]
    MS[("espec/specs/<br/>the system as it is today")]
    AC["archive-clean<br/>keep / update / purge with evidence"]
    RC --> AS --> TP --> IM --> AR
    AR -->|"RENAMED, REMOVED,<br/>MODIFIED, ADDED"| MS
    MS -->|"read before writing deltas"| TP
    MS <--> AC
  end

  DSA -->|"paste as description"| TK
  PMB -->|"write or paste the description"| TK
  TK -->|"check, then assess against the code"| RC
  AS -.->|"Ready, or Further discovery required"| TA
  TA -.->|"scope decisions, confirmations"| Product
  TK -->|"import as feature.md"| TP
  TP -.->|"blocking questions"| TQ
  TQ -.->|"answers, description updated"| Product
  AR -.->|"what shipped, what was deferred"| TR
```

Three things to notice:

- The ticket description and `feature.md` are the same text. Product edits the ticket. Engineering
  imports it. When they differ, the AI shows the diff and asks which one wins. The comparison runs at
  the tech proposal, its inspection, the start of every implementation run, the code review and the
  archive, so a ticket edited after approval is seen before it is built on or closed.
- Engineering never edits `espec/specs/` by hand. Main specs change only when a change is archived,
  or when archive-clean runs and the user confirms its verdicts.
- The next tech proposal starts by reading the main specs. That loop is what keeps the specs true.

## Phase 1: AI Assisted Feature Definition

Product owns this phase. It has two steps: product writes the feature definition, then a developer
checks and assesses it against the repository before the tech proposal starts.

### Product writes the feature definition

| | |
|---|---|
| Command | `/espec:feature-definition` |
| Who | The Product Manager writes. The Designer fills the UI design section from the Figma frames. QA reviews edge cases and acceptance criteria. |
| Tool | Without GitHub Copilot: Rovo or M365 Copilot, with the agents in [product-ai/](../product-ai/README.md). With GitHub Copilot: `/espec-feature-definition` in a local copy of the repository, one command for the definition and its UI design (see below). A developer who starts a feature uses the same command. |
| Inputs | The idea, the research, the available UI designs, the business why, known uncertainties. |
| Outputs | The ticket description in the feature definition format, with the readiness checklist all ✅ and the status line set to Ready for tech proposal. In GitHub Copilot, also a local `espec/changes/<change-name>/feature.md` that Product does not commit. |
| Exit criteria | **Ready for tech proposal** on the ticket: Why, What, at least one UC, edge cases, out of scope and acceptance criteria are present, every UC and EC maps to an AC, open questions are answered or accepted as deferred, and no how sits outside the forced notes. `/espec:inspect-feature-definition` returns Ready for tech proposal. |
| Hand-off | The ticket. Product hands it to engineering when it is sufficiently specified for technical assessment, or when they cannot progress further without engineering input, for example because the desired behaviour depends on capabilities or constraints they cannot assess. |

#### Two ways to start

| | Without GitHub Copilot | With GitHub Copilot |
|---|---|---|
| Define | `@espec Feature Definition` agent in Rovo or M365 Copilot | `/espec-feature-definition` (Draft, or Import from the ticket) in a local copy of the repository |
| Design | `@espec UI Design` agent, from the Figma frames | The same command, in the same run: it reads the Figma frames, then interviews Product or Design on how the design behaves and which use cases and edge cases each screen serves. `/espec-design-context <change-name>` runs that step alone when the frames arrive later |
| Ticket | Pasted, or written by the Rovo agent through Jira actions | Written through the Atlassian or GitHub MCP server on a yes, or pasted |
| Repository | Untouched | Untouched: the change folder is a local working copy, deleted once the ticket holds the final text |
| Join | A developer runs `/espec-inspect-feature-definition` on the ticket, then `/espec-assess` | The same |

The streams join at the readiness check because both hand over the same thing: the ticket. Engineering
imports from the ticket in either case, so nothing downstream depends on which tool Product used.

This hand-off means **ready for technical investigation**, not necessarily ready for estimation or
implementation. The Product Owner is not expected to establish technical feasibility or identify every
dependency beforehand. That is what the assessment is for.

### Developer assessment: `/espec:assess`

| | |
|---|---|
| Command | `/espec:assess` |
| Who | A developer leads the investigation, involving Product, Design, QA and other teams as needed. |
| Tool | GitHub Copilot, with access to the repository: `/espec-assess <ticket key, URL or change name>`. |
| Inputs | The ticket, available UI designs and research, known questions, the code and its tests, the main specs in `espec/specs/`, API contracts, `espec/project.md` and `espec/config.yaml`. |
| Activity | Investigate feasibility with Copilot: what the code already does for each acceptance criterion and constraint, with file paths; which capabilities in `espec/specs/` the feature touches; dependencies outside the repository, listed as unconfirmed with an owner to ask; alternatives with their consequences for product; criteria that cannot be met as written, with an outcome rephrasing; spikes where reading the code cannot answer a question. Seek clarification or confirmation from the appropriate people. |
| Outputs | The Technical assessment report, printed in the chat and pasted as a developer-authored comment on the ticket: findings, evidence, alternatives and trade-offs, questions, dependencies, and links to any spikes or related work. On request, saved to `espec/changes/<change-name>/inspections/YYYY-MM-DD-assess.md`. The PO updates the ticket description after scope decisions are agreed. |
| Completion outcome | Either **Ready for tech proposal**, or **Further discovery required**, with the outstanding questions, dependencies or spikes recorded and their next actions identified. |
| Hand-off | Findings return to Product/Design for clarification or scope decisions, to external teams for confirmation, or to a spike for further investigation. Once sufficiently resolved, the ticket proceeds to the tech proposal phase. |

The developer and Copilot investigate together rather than merely checking whether the ticket contains
every required heading (that check is `/espec:inspect-feature-definition`). They distinguish what the
system already supports from what requires additional requests, service changes or other work. Where
meaningful alternatives exist, they explain the consequences so Product can make informed scope
decisions.

Code evidence does not, by itself, confirm another team's capability or delivery commitment. Those
dependencies require confirmation from the relevant owners.

The assessment comment preserves the investigation and its rationale. **The PO-maintained ticket
description remains the agreed delivery scope**; alternatives and recommendations do not become
requirements unless explicitly accepted.

**Readiness rule:** proceed to the tech proposal when the agreed scope and available technical
evidence are sufficient to develop a credible proposal. Material feasibility blockers must be resolved
or removed from scope through an explicit decision; remaining non-blocking assumptions must stay
visible. After further discovery, the developer re-runs `/espec:assess`; the new comment supersedes
the old one and says which blocking findings were resolved and how.

## Phase 2: Tech Proposal

| | |
|---|---|
| Command | `/espec:tech-proposal` |
| Who | Developer writes. QA contributes the test strategy. Engineering Manager or Architect reviews. |
| Tool | GitHub Copilot: `/espec-tech-proposal <ticket key, URL or change name>`. |
| Inputs | The ticket (fetched through an Atlassian or GitHub MCP server, or pasted), the technical assessment (its saved report, or the comment on the ticket), `espec/project.md`, `espec/config.yaml`, the main specs in `espec/specs/`, and the code. |
| Outputs | `espec/changes/<change-name>/` holding `feature.md` (imported), `tech-proposal.md`, delta specs under `specs/<capability>/spec.md`, `tasks.md`, the assessment it builds on under `inspections/`, and `.espec.yaml` with `status: proposed`. In the chat, a coverage report: how much of the feature definition the proposal covers, id by id. |
| Exit criteria | **Approved**: the reviewer sets the status line in `tech-proposal.md` to Approved. Every `FT-n` is marked Accepted or Overridden. The traceability table covers every UC, EC and AC. Every blocking finding of the technical assessment is resolved and every dependency it listed has a home in the proposal. No blocking Question for Product is open. Every MODIFIED and REMOVED requirement carries a base stamp (`espec stamp`). `/espec:inspect-tech-proposal` returns Approve. |
| Hand-off | **Questions for Product** are pasted as a ticket comment. Product answers in the ticket and updates the description. Engineering re-imports and revises. |

The proposal is reviewed where the project says, usually a pull request that adds the change
folder. Record the place in `espec/project.md` under Ticketing, and name the approvers in CODEOWNERS
so the Approved line cannot reach `main` without them. Nothing outside
`espec/changes/<change-name>/` changes in this phase.

Approval covers the proposal as approved. A later change to a decision, the scope or observable
behaviour, in this phase or the next, sets the status line back to **In review** and the reviewer
approves again.

A bug runs through the same phases with less paper: see [Bugs](#bugs).

## Phase 3: Implementation

| | |
|---|---|
| Command | `/espec:implementation` |
| Who | Developer implements. QA runs the `## QA verification` group. |
| Tool | GitHub Copilot: `/espec-implementation <change-name>`. |
| Inputs | The approved change folder, re-read from disk every time, in a new chat or session so the proposal conversation does not steer the code. The ticket, compared with `feature.md` before any task starts. |
| Outputs | Code and tests. `tasks.md` with a task checked off only after its verification passed. `pull-request.md`: the pull request description, readable without the code, with a proposal-versus-implementation table. `.espec.yaml` moves to `in-progress` after the first check and `implemented` after the last. In the chat, a coverage report: how much of the proposal and the feature definition the code delivers, criterion by criterion. |
| Security | On a mobile app, before the pull request description: [AI Mobile Security Assessment](https://github.com/Mindera/AI-Mobile-Security-Assessment) against OWASP MASVS, run only when the signed-in GitHub user can read its private repository. Findings in files the change touches are fixed as `S.n` tasks; the rest go on the pull request with `security-report.md`, under "⚠️ Security findings: pre-existing, not from this change", or under "⚠️ Security findings: fix before merge" while a finding remains in a touched file. No findings: "Security validation passed". No access: skipped, and the pull request says so. |
| Exit criteria | **All tasks complete**: every checkbox in `tasks.md` is `[x]`, including the QA verification group. |
| Hand-off | The pull request, whose description is `pull-request.md`. It links to the ticket, and its Release note section becomes the ticket comment at archive. |
| Code review | The reviewer reads `pull-request.md`, then runs `/espec:review <number>` to walk the diff with [DiffCompass](https://github.com/Mindera/diffcompass). `.diffcompass.json` points its agent at the change folder, so the tour follows **How to review** and flags drift from the tech proposal and the delta specs. |

Every run starts by comparing the ticket with `feature.md`, when a tool can reach it. A difference
stops the run: scope that product changed after approval goes back through the tech proposal, and a
stale ticket is corrected, before any more code is written.

The AI pauses when a task is unclear, needs work the specs do not describe, or would reduce specified
behaviour. It never narrows scope silently. A design problem found here becomes a tech proposal
update, not a workaround: the proposal goes back to In review and implementation waits for the new
approval.

## Phase 4: Archive

| | |
|---|---|
| Commands | `/espec:archive` and `/espec:archive-clean` |
| Who | Developer. |
| Tool | GitHub Copilot: `/espec-archive <change-name>` and `/espec-archive-clean [capability]`. |
| Inputs | An implemented change. For clean: every main spec, the archive, the code and the tests. |
| Outputs | Archive: main specs updated from the deltas, the change folder moved to `espec/changes/archive/YYYY-MM-DD-<change-name>/`, a release note. Clean: `cleanup.md` with keep / update / purge verdicts and evidence, applied only on confirmation. |
| Exit criteria | **Archived**: `.espec.yaml` says `archived`, no delta headings remain in the main specs, every requirement still has a scenario. |
| Hand-off | The release note is pasted as a ticket comment: what shipped, which specs changed, what was deferred. The ticket is closed. |

Archive runs after the implementation pull request is merged, either as its own short pull request
or as the last commit of the implementation pull request (see
[the guides](guides/README.md#pull-requests-along-the-way)). Archive stops on any conflict before
moving anything, including a base stamp that shows another change edited the same requirement first.
Before the release note, archive compares the ticket with `feature.md` once more, so a ticket is not
closed on a description that differs from what shipped. Archive-clean never deletes without evidence
and a confirmed verdict. In CI, a pull request that
changes `espec/specs/` without archiving a change fails. See
[conventions.md](conventions.md#archive-merge-order-and-conflicts).

## Bugs

A bug is code that does not do what was intended. It runs through the same four phases with less
paper. Behaviour that was never intended is a feature, however small, and takes a feature definition.

| Step | What is different for a bug |
|---|---|
| Phase 1 | Whoever found it writes a **bug report** in place of the feature definition: who is affected and how often, expected versus actual behaviour, steps to reproduce, out of scope, acceptance criteria. No use cases, no edge cases, no UI design. The same tools write it: the Feature Definition agent in Rovo or M365 Copilot, or `/espec:feature-definition` in GitHub Copilot. A suspected cause or a proposed fix is a how and stays out. |
| Inspection | `/espec:inspect-feature-definition` runs the bug readiness check and compares the expected behaviour with the main specs. When a spec describes the current behaviour as the intended one, the report asks for a feature, and that is blocking. |
| Assessment | None. The tech proposal finds the root cause. |
| Phase 2 | A shorter proposal: Context with the root cause, Approach, Traceability, Test strategy, Questions for Product. No delta when the main specs already describe the correct behaviour (`skip_specs: true`). |
| Phase 3 | The first task writes a test that reproduces the bug and fails before the fix. |
| Phase 4 | Unchanged. The archive is the record of why the behaviour changed. |

Format and rules: [Bug fixes](../template/espec/AGENTS.md#bug-fixes). Ticket templates:
[Jira](../product-ai/ticket-templates/jira-bug-report.md) and
[GitHub Issues](../product-ai/ticket-templates/github-issue-bug-report.md). A worked report:
[examples/changes/bill-171-fix-jpy-amounts-in-export/feature.md](../examples/changes/bill-171-fix-jpy-amounts-in-export/feature.md).

## Lanes

The four phases are the standard lane. Two shorter lanes exist for changes that should not wait for
them. Each is declared as `lane:` in `.espec.yaml`, and neither removes the review of the code, the
tests or the record in the specs.

| Lane | For | What it changes |
|---|---|---|
| Small | A change one reviewer can judge whole in one sitting: one capability, no new API, data model or screen, nothing needed from another team | A short definition and a short proposal. One pull request carries the change folder and the code, and the reviewer approves both by setting the proposal's status line to Approved |
| Urgent | Production is broken or at risk now, declared by a named person | The fix ships first, reviewed, with an `.espec.yaml` that says who declared it and when the paper is due. The record of what shipped is written within a week. `espec validate` fails once the date has passed |

A pull request that changes no behaviour (a refactor, a dependency update, tooling, tests) needs no
change: its description says `espec: no behaviour change` and why. CI warns about a pull request that
changes code with neither a change nor that line, and can be set to fail it.

Step by step: [Small and urgent changes](guides/lanes.md). Rules:
[Lanes](../template/espec/AGENTS.md#lanes).

## Where things live

| Artifact | Ticket | Repository |
|---|---|---|
| Feature definition | Description. Product edits here. | `espec/changes/<change-name>/feature.md`, an identical copy from `# Feature:` down, plus the marker and header line on Jira |
| UI design | **UI design** section of the description | Same section of `feature.md` |
| Forced technical notes | `## Forced technical notes` in the description | Same section of `feature.md`, reviewed in `tech-proposal.md` |
| Technical assessment | Comment from engineering, with the outcome | Printed by `/espec:assess`. Filed by the tech proposal as `espec/changes/<change-name>/inspections/YYYY-MM-DD-assess.md`, or saved there on request |
| Questions for Product | Comment from engineering | `## Questions for Product` in `tech-proposal.md` |
| Answers from product | Comment, then the description is updated | `feature.md` updated to match |
| Tech proposal | Optional link to the pull request | `tech-proposal.md` |
| Delta specs | Not in the ticket | `espec/changes/<change-name>/specs/<capability>/spec.md` |
| Tasks and progress | Not in the ticket | `tasks.md`, and `status` in `.espec.yaml` |
| Pull request description | Link to the pull request | `pull-request.md`, also used as the pull request body |
| Status | The team's ticket workflow (To do, Ready, In progress, Done) | `status` in `.espec.yaml` |
| Release note | Comment from engineering | Printed by archive. The archived folder is the record. |
| Main specs | Not in the ticket | `espec/specs/<capability>/spec.md` |
| Clean-up audit trail | Not in the ticket | `espec/changes/archive/YYYY-MM-DD-archive-clean/cleanup.md` |

Rule of thumb: product reads and writes the ticket, engineering reads and writes the repo, and the
feature definition is the one text that lives in both.

## When the ticket system is GitHub Issues

The phases do not change. The hand-off does.

1. Set `tickets.system: github` in `espec/config.yaml`, with the repo and the label.
2. The issue template at
   [template/.github/ISSUE_TEMPLATE/feature-definition.md](../template/.github/ISSUE_TEMPLATE/feature-definition.md)
   opens a new issue with the feature definition skeleton and the `feature-definition` label
   already applied. Product writes the definition with M365 Copilot, Rovo or GitHub Copilot and
   pastes the result into the body, or lets GitHub Copilot write it on a yes. A second template,
   [bug-report.md](../template/.github/ISSUE_TEMPLATE/bug-report.md), opens a bug report with the
   `bug` label.
3. The body starts with `<!-- espec:feature-definition v1 -->`.
   [template/.github/copilot-instructions.md](../template/.github/copilot-instructions.md) tells
   GitHub Copilot that an issue with this marker is a feature definition and must not be
   implemented directly.
4. A developer runs `/espec-inspect-feature-definition <issue URL>`, then
   `/espec-assess <issue URL>` in Copilot Chat, and posts the assessment as an issue comment. Product decides on what it raises; the issue body stays the agreed scope.
5. When the outcome is Ready for tech proposal, a developer runs `/espec-tech-proposal <issue URL>`
   in Copilot Chat, or the issue is assigned to the Copilot coding agent. Either way the first output
   is a pull request that adds `espec/changes/<change-name>/` with the tech proposal, delta specs and
   tasks. Nothing else changes in that PR.
6. Questions for Product go in an issue comment. The reviewer approves the tech proposal PR.
7. Implementation follows as a second pull request: a developer runs `/espec-implementation`, or
   the coding agent is assigned again now that an approved change exists in the repo.
8. Archive runs after the merge. The release note is the closing comment on the issue.

The change name uses the issue number as its key, for example `gh-142-invoice-csv-export`, and
`.espec.yaml` stores the issue URL under `ticket`.
