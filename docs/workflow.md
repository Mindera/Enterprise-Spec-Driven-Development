# Workflow

espec takes a feature from an idea to a living specification in four phases. Product owns phase 1.
Engineering owns phases 2 to 4. The two sides use different AI tools, so the hand-off between them
is a ticket written in a fixed format that any assistant can read and any human can review.

The formats and rules live in [template/espec/AGENTS.md](../template/espec/AGENTS.md). This page
explains how the phases connect across roles and tools. For the commands see
[commands.md](commands.md). For the formats see [conventions.md](conventions.md).

## The flow

```mermaid
flowchart TB
  subgraph Product["Product · Rovo or M365 Copilot"]
    direction TB
    PM["Product Manager<br/>Phase 1: AI Assisted Feature Definition<br/>what and why, never how"]
    DS["Designer<br/>Experience and design section"]
    PM --> DS
  end

  subgraph Ticket["Ticket · Jira or GitHub Issue"]
    direction TB
    TK["Description = feature definition<br/>Status: Ready for tech proposal"]
    TQ["Comment: Questions for Product"]
    TR["Comment: Release note"]
  end

  subgraph Eng["Engineering · GitHub Copilot"]
    direction TB
    TP["Phase 2: Tech Proposal<br/>tech-proposal.md, delta specs, tasks.md"]
    IM["Phase 3: Implementation<br/>code and tests, tasks checked off"]
    AR["Phase 4: Archive<br/>deltas folded into main specs"]
    MS[("espec/specs/<br/>the system as it is today")]
    AC["archive-clean<br/>keep / update / purge with evidence"]
    TP --> IM --> AR
    AR -->|"RENAMED, REMOVED,<br/>MODIFIED, ADDED"| MS
    MS -->|"read before writing deltas"| TP
    MS <--> AC
  end

  DS -->|"paste as description"| TK
  TK -->|"import as feature.md"| TP
  TP -.->|"blocking questions"| TQ
  TQ -.->|"answers, description updated"| PM
  AR -.->|"what shipped, what was deferred"| TR
```

Three things to notice:

- The ticket description and `feature.md` are the same text. Product edits the ticket. Engineering
  imports it. When they differ, the AI shows the diff and asks which one wins.
- Engineering never edits `espec/specs/` by hand. Main specs change only when a change is archived,
  or when archive-clean runs and the user confirms its verdicts.
- The next tech proposal starts by reading the main specs. That loop is what keeps the specs true.


## Phase 1: AI Assisted Feature Definition


### Product preparation: outside this workflow

The Product Owner and Designer develop the ticket using their usual tools, optionally supported by their own AI assistants. They establish the business **why**, desired **what**, available designs, use cases, acceptance criteria and known uncertainties.

This preparation is outside the ESpec workflow.

The PO hands the ticket to engineering when either:



- It is sufficiently specified for technical assessment.

- They cannot progress further without engineering input, for example because the desired behaviour depends on capabilities or constraints they cannot assess.


This hand-off means **ready for technical investigation**, not necessarily ready for estimation or implementation. The PO is not expected to establish technical feasibility or identify every dependency beforehand.


### Developer assessment: inside this workflow


|  |  |
| --- | --- |
| **Command** | `/espec:feature-definition` |
| **Who** | A developer leads the investigation, involving Product, Design, QA and other teams as needed. |
| **Tool** | GitHub Copilot, with access to the repository: `/espec-feature-definition`. |
| **Inputs** | The existing ticket, available designs and research, known questions, relevant code, existing specs and API contracts. |
| **Activity** | Investigate feasibility with Copilot; identify existing capabilities, alternatives, missing requirements, external dependencies and uncertainties. Seek clarification or confirmation from the appropriate people and create spikes where further investigation is necessary. |
| **Outputs** | A developer-authored assessment comment on the ticket, including findings, evidence, alternatives and trade-offs, questions, dependencies, and links to any spikes or related work. The PO updates the ticket description after scope decisions are agreed. |
| **Completion outcome** | Either **Ready for tech proposal**, or **Further discovery required**, with the outstanding questions, dependencies or spikes recorded and their next actions identified. |
| **Hand-off** | Findings return to Product/Design for clarification or scope decisions, to external teams for confirmation, or to a spike for further investigation. Once sufficiently resolved, the ticket proceeds to the tech proposal phase. |


The developer and Copilot investigate together rather than merely checking whether the ticket contains every required heading. They distinguish what the system already supports from what requires additional requests, service changes or other work. Where meaningful alternatives exist, they explain the consequences so Product can make informed scope decisions.


Code evidence does not, by itself, confirm another team’s capability or delivery commitment. Those dependencies require confirmation from the relevant owners.


The assessment comment preserves the investigation and its rationale. **The PO-maintained ticket description remains the agreed delivery scope**; alternatives and recommendations do not become requirements unless explicitly accepted.


**Proposed readiness rule:** proceed to the tech proposal when the agreed scope and available technical evidence are sufficient to develop a credible proposal. Material feasibility blockers must be resolved or removed from scope through an explicit decision; remaining non-blocking assumptions must stay visible.


## Phase 2: Tech Proposal

| | |
|---|---|
| Command | `/espec:tech-proposal` |
| Who | Developer writes. QA contributes the test strategy. Engineering Manager or Architect reviews. |
| Tool | GitHub Copilot: `/espec-tech-proposal <ticket key, URL or change name>`. |
| Inputs | The ticket (fetched through an Atlassian or GitHub MCP server, or pasted), `espec/project.md`, `espec/config.yaml`, the main specs in `espec/specs/`, and the code. |
| Outputs | `espec/changes/<change-name>/` holding `feature.md` (imported), `tech-proposal.md`, delta specs under `specs/<capability>/spec.md`, `tasks.md`, and `.espec.yaml` with `status: proposed`. |
| Exit criteria | **Approved**: the reviewer sets the status line in `tech-proposal.md` to Approved. Every `FT-n` is marked Accepted or Overridden. The traceability table covers every UC, EC and AC. No blocking Question for Product is open. `/espec:inspect-tech-proposal` returns Approve. |
| Hand-off | **Questions for Product** are pasted as a ticket comment. Product answers in the ticket and updates the description. Engineering re-imports and revises. |

The proposal is reviewed where the project says, usually a pull request that adds the change
folder. Record the place in `espec/project.md` under Ticketing. Nothing outside
`espec/changes/<change-name>/` changes in this phase.

## Phase 3: Implementation

| | |
|---|---|
| Command | `/espec:implementation` |
| Who | Developer implements. QA runs the `## QA verification` group. |
| Tool | GitHub Copilot: `/espec-implementation <change-name>`. |
| Inputs | The approved change folder, re-read from disk every time. |
| Outputs | Code and tests. `tasks.md` with a task checked off only after its verification passed. `pull-request.md`: the pull request description, readable without the code, with a proposal-versus-implementation table. `.espec.yaml` moves to `in-progress` after the first check and `implemented` after the last. |
| Exit criteria | **All tasks complete**: every checkbox in `tasks.md` is `[x]`, including the QA verification group. |
| Hand-off | The pull request, whose description is `pull-request.md`. It links to the ticket, and its Release note section becomes the ticket comment at archive. |
| Code review | The reviewer reads `pull-request.md`, then walks the diff with [DiffCompass](https://github.com/Mindera/diffcompass): `diffcompass pr <number> --open`. `.diffcompass.json` points its agent at the change folder, so the tour follows **How to review** and flags drift from the tech proposal and the delta specs. |

The AI pauses when a task is unclear, needs work the specs do not describe, or would reduce specified
behaviour. It never narrows scope silently. A design problem found here becomes a tech proposal
update, not a workaround.

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

Archive stops on any conflict before moving anything. Archive-clean never deletes without evidence
and a confirmed verdict. See [conventions.md](conventions.md#archive-merge-order-and-conflicts).

## Where things live

| Artifact | Ticket | Repository |
|---|---|---|
| Feature definition | Description. Product edits here. | `espec/changes/<change-name>/feature.md`, an identical copy |
| Design notes | **Experience and design** section of the description | Same section of `feature.md` |
| Forced technical notes | `## Forced technical notes` in the description | Same section of `feature.md`, reviewed in `tech-proposal.md` |
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
   already applied. Product writes the definition with M365 Copilot or Rovo and pastes the result
   into the body.
3. The body starts with `<!-- espec:feature-definition v1 -->`.
   [template/.github/copilot-instructions.md](../template/.github/copilot-instructions.md) tells
   GitHub Copilot that an issue with this marker is a feature definition and must not be
   implemented directly.
4. A developer runs `/espec-tech-proposal <issue URL>` in Copilot Chat, or the issue is assigned to
   the Copilot coding agent. Either way the first output is a pull request that adds
   `espec/changes/<change-name>/` with the tech proposal, delta specs and tasks. Nothing else
   changes in that PR.
5. Questions for Product go in an issue comment. The reviewer approves the tech proposal PR.
6. Implementation follows as a second pull request: a developer runs `/espec-implementation`, or
   the coding agent is assigned again now that an approved change exists in the repo.
7. Archive runs after the merge. The release note is the closing comment on the issue.

The change name uses the issue number as its key, for example `gh-142-invoice-csv-export`, and
`.espec.yaml` stores the issue URL under `ticket`.
