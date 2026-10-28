# Step-by-step guides

One guide per step of the espec workflow, plus two setup guides. Each guide says who runs the step,
what must be true before it starts, how to set the tools up once, how to run the step, what good looks
like at the end, and what to do when it goes wrong.

The reference pages stay where they are: [workflow.md](../workflow.md) for the flow,
[commands.md](../commands.md) for every command's inputs and outputs,
[conventions.md](../conventions.md) for the formats and [roles-and-tools.md](../roles-and-tools.md)
for the role matrix. The guides are the walkthroughs. When a guide and
[template/espec/AGENTS.md](../../template/espec/AGENTS.md) disagree, `AGENTS.md` wins.

## Setup, once per organisation

| Guide | Who | Result |
|---|---|---|
| [Engineering setup](setup-engineering.md) | A developer with write access to the repository | `espec/` and `.github/` in the repository, the Copilot commands available to the team, validation in CI |
| [Product setup](setup-product.md) | A Rovo or Microsoft 365 Copilot admin, then the product team | The two agents shared with product and design, the ticket template in Jira or GitHub |

## Steps, once per feature

| # | Guide | Command | Who runs it | Ends with |
|---|---|---|---|---|
| 1 | [Feature definition](01-feature-definition.md) | `/espec:feature-definition`, an agent in Rovo or M365 Copilot | Product Manager, then Designer | A ticket whose description is marked Ready for tech proposal |
| 2 | [Inspect the feature definition](02-inspect-feature-definition.md) | `/espec:inspect-feature-definition` | Developer or QA | A verdict and a comment on the ticket |
| 3 | [Technical assessment](03-technical-assessment.md) | Copilot Chat in the repository; no dedicated command yet | Developer, then the team in refinement | An assessment comment on the ticket and an agreed scope |
| 4 | [Tech proposal](04-tech-proposal.md) | `/espec:tech-proposal` | Developer, QA for the test strategy | `tech-proposal.md`, delta specs and `tasks.md` in a pull request |
| 5 | [Inspect the tech proposal](05-inspect-tech-proposal.md) | `/espec:inspect-tech-proposal` | QA, Engineering Manager or Architect | Approve, and the proposal's status line set to Approved |
| 6 | [Implementation](06-implementation.md) | `/espec:implementation` | Developer, QA for the verification group | Code and tests, every task checked, `pull-request.md` |
| 7 | [Code review](07-code-review.md) | `/espec:review`, then the pull request | Reviewer | Pull request approved and merged |
| 8 | [Archive](08-archive.md) | `/espec:archive` | Developer | Main specs updated, change archived, release note on the ticket |
| 9 | [Archive clean](09-archive-clean.md) | `/espec:archive-clean` | Developer, a reviewer confirms | `cleanup.md` and the confirmed edits to the main specs |

Steps 2, 3 and 5 are reviews. They are short and read-only, and skipping them is how definitions with
gaps reach implementation. Step 9 runs on a rhythm, not per feature.

## How the steps hand over

Product reads and writes the ticket. Engineering reads and writes the repository. The feature
definition is the one text that lives in both. The hand-offs are:

1. Product pastes the definition into the ticket description (step 1).
2. Engineering reads the ticket, comments on it (steps 2 and 3) and imports it into
   `espec/changes/<change-name>/feature.md` (step 4).
3. Questions for Product go back as a ticket comment; product answers and updates the description
   (step 4). Engineering re-imports.
4. The implementation pull request carries `pull-request.md` as its body (steps 6 and 7).
5. The release note goes back as the closing ticket comment (step 8).

## Pull requests along the way

The toolkit does not prescribe a branching model. The rhythm that works in practice is three
pull requests per change, each small enough to review in one sitting:

| Pull request | Contains | Reviewed by | Gate |
|---|---|---|---|
| Proposal | `espec/changes/<change-name>/` only: `feature.md`, `tech-proposal.md`, `specs/`, `tasks.md`, `.espec.yaml` | QA, Engineering Manager or Architect | Step 5 says Approve; status line set to Approved |
| Implementation | Code and tests, `tasks.md` checked off, `pull-request.md`, `.espec.yaml` at `implemented` | Reviewer with DiffCompass | Step 7 |
| Archive | `espec/specs/` updated, the change folder moved under `changes/archive/` | Anyone on the team | `espec/bin/espec validate` green |

A team that prefers two pull requests folds the archive into the implementation pull request after
the review, as its last commit. Record the choice in `espec/project.md` under Ticketing.
