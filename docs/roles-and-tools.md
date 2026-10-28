# Roles and tools

espec assumes that product and engineering have different AI tools, and designs the hand-off around
that. This page says what each role does in each phase, which tool they use, what they never do, and
how to set each tool up. The underlying rules are in
[template/espec/AGENTS.md](../template/espec/AGENTS.md).

## At a glance

| Phase | Product Manager | Designer | Developer | QA | Eng Manager / Architect |
|---|---|---|---|---|---|
| 1 Feature definition | Writes | Fills Experience and design | Runs the technical assessment | Reviews edge cases and ACs | Reads the assessment |
| 2 Tech proposal | Answers Questions for Product | Answers design questions | Writes | Writes the test strategy | Reviews and approves |
| 3 Implementation | Available for questions | Reviews built screens | Implements, checks tasks | Runs QA verification | Decides on design pauses |
| 4 Archive | Reads the release note, closes the ticket | | Runs archive and archive-clean | Confirms the note matches what was verified | Confirms clean verdicts |
| Tool | Rovo or M365 Copilot | Rovo or M365 Copilot | GitHub Copilot | GitHub Copilot | GitHub Copilot, the PR review, DiffCompass |

## Product Manager

| Phase | Does | Tool |
|---|---|---|
| 1 | Describes the problem to the feature definition agent. Answers the interview in short rounds. Confirms or rejects the proposed edge cases. Lists what is out of scope. Sets the status to Ready for tech proposal and pastes the document as the ticket description. | Rovo Agent or M365 Copilot agent from [product-ai/](../product-ai/README.md) |
| 2 | Answers the Questions for Product that engineering posts as a ticket comment. Updates the ticket description when an answer changes the definition. | The ticket. The review prompt in [product-ai/prompts/review-feature-definition.prompt.md](../product-ai/prompts/review-feature-definition.prompt.md) to check the result |
| 3 | Stays reachable. A scope question during implementation comes back as a ticket comment. | The ticket |
| 4 | Reads the release note comment. Closes the ticket. | The ticket |

Never:

- Writes how. No endpoints, tables, services, libraries or architecture. A how the PM insists on
  goes under `## Forced technical notes` as `FT-n`, where engineering reviews it.
- Edits files in the repository. The ticket is the product's copy.
- Approves the tech proposal. Product answers the questions; engineering approves the how.
- Changes scope mid-implementation without updating the ticket description. Engineering re-imports
  from the ticket, so a silent change is lost.

## Designer

| Phase | Does | Tool |
|---|---|---|
| 1 | Fills the **Experience and design** section: flows, screens, the empty / loading / error / success states, content and tone, accessibility needs, links to design files. Proposes edge cases that come from the UI (what the user sees when something fails). | The design-notes agent: [product-ai/rovo/design-notes-agent.md](../product-ai/rovo/design-notes-agent.md) or [product-ai/m365-copilot/design-notes-agent.md](../product-ai/m365-copilot/design-notes-agent.md), or the prompt in [product-ai/prompts/design-notes.prompt.md](../product-ai/prompts/design-notes.prompt.md) |
| 2 | Answers design questions from the tech proposal. | The ticket |
| 3 | Reviews the built screens against the states listed in phase 1. A `Q.n` task can name this review. | The ticket, the staging environment |
| 4 | Nothing. | |

Never:

- Specifies components, CSS, animation libraries or front-end frameworks. The design section is
  still what, not how.
- Writes outside the Experience and design section of the definition without the PM.

## Developer

| Phase | Does | Tool |
|---|---|---|
| 1 | Runs `/espec-inspect-feature-definition` on the ticket, then `/espec-assess`: what the code already does for each acceptance criterion and constraint, which specs the feature touches, dependencies on other teams (unconfirmed until their owner confirms), alternatives with their consequences for product, criteria that cannot be met as written, spikes. Pastes the assessment as a ticket comment and takes the findings to product, the owning teams or a spike. Optional: runs the feature definition in-repo when the work has no product owner, or imports a ticket, and pastes the result into a ticket so product can own it. | `/espec-inspect-feature-definition`, `/espec-assess`, `/espec-feature-definition` |
| 2 | Starts when the assessment outcome is Ready for tech proposal. Runs the tech proposal. Explores the code before writing. Writes `tech-proposal.md`, the delta specs and `tasks.md`. Pastes Questions for Product as a ticket comment. Opens the pull request that adds the change folder. | `/espec-tech-proposal`, an Atlassian or GitHub MCP server to fetch the ticket |
| 3 | Runs the implementation task by task. Lets the AI pause and decides on each pause. Keeps `tasks.md` as the progress record. Opens the pull request with `pull-request.md` as its body, so reviewers read what was built and how it differs from the proposal without opening the code first. | `/espec-implementation` |
| 4 | Runs archive after the review. Posts the release note. Runs archive-clean on the agreed rhythm and brings the report to the reviewer. | `/espec-archive`, `/espec-archive-clean`, `bin/espec validate` |

Never:

- Edits `espec/specs/` by hand. Main specs change through archive and archive-clean only. A
  behaviour change found during implementation goes into the change's delta specs.
- Implements a ticket that has no approved tech proposal. A ticket that starts with the feature
  definition marker gets a tech proposal first.
- Writes application code during the tech proposal phase.
- Treats code evidence as another team's commitment. A dependency outside the repository stays
  unconfirmed until its owner confirms it.
- Turns an alternative from the assessment into a requirement. The ticket description is the scope
  until product changes it.
- Checks a task that is partially done, or narrows a task to make it pass.
- Updates a ticket or posts a comment through a tool without being asked.

## QA

| Phase | Does | Tool |
|---|---|---|
| 1 | Reviews the definition for missing edge cases and untestable acceptance criteria. Proposes `EC-n` entries. In the repository, `/espec-inspect-feature-definition` produces the same report. | The review prompt in [product-ai/prompts/review-feature-definition.prompt.md](../product-ai/prompts/review-feature-definition.prompt.md), or `/espec-feature-definition` in Review mode |
| 2 | Writes or reviews the **Test strategy**: how each scenario is verified, at which level, with what data, in which environment. Runs `/espec-inspect-tech-proposal` and checks that the traceability table covers every AC and that the `## QA verification` group has one `Q.n` line per AC. | `/espec-tech-proposal`, the pull request review |
| 3 | Runs the `Q.n` tasks in verification-only mode. Records environment and result in the task line. Checks a task only when it passes. Reports a failing scenario as a pause, not a workaround. | `/espec-implementation <change-name>` with "verification only" |
| 4 | Confirms the release note matches what was verified and what was deferred. | The ticket |

Never:

- Edits application code or specs. A failing scenario is a finding for the developer.
- Checks a `Q.n` task that did not pass.

## Engineering Manager or Architect (reviewer)

| Phase | Does | Tool |
|---|---|---|
| 1 | Reads the ticket and the assessment comment. Flags a definition that is really several features. When the assessment outcome is Further discovery required, agrees with product which blockers are resolved and which are cut from scope before the tech proposal starts. | The ticket |
| 2 | Runs `/espec-inspect-tech-proposal`, then reviews the tech proposal: each `D-n` lists real alternatives, each `FT-n` has a verdict, the traceability table is complete, non-functional requirements and rollout are covered. Sets the status line to **Approved**. | The pull request that adds the change folder |
| 3 | Decides on pauses that change the design. A design change is a tech proposal update, reviewed again. Reviews the pull request starting from its description: the proposal-versus-implementation table says where to look. Walks the diff with `diffcompass pr <number> --open`, which follows **How to review** and flags drift from the proposal. | The pull request, [DiffCompass](#diffcompass-reviewers-developers) |
| 4 | Confirms archive-clean verdicts. Owns the requirements that have no owner. | `/espec-archive-clean` report, `cleanup.md` |

Never:

- Approves a tech proposal while a blocking Question for Product is open.
- Edits main specs by hand to "fix" them. That is an archive-clean run with evidence.

## Setting up the tools

### Atlassian Rovo (Product Managers, Designers)

1. In Rovo, create a new agent. Paste the instructions from
   [product-ai/rovo/feature-definition-agent.md](../product-ai/rovo/feature-definition-agent.md).
   Name it so it is easy to @-mention, for example "Feature Definition".
2. Create a second agent from
   [product-ai/rovo/design-notes-agent.md](../product-ai/rovo/design-notes-agent.md) for designers.
3. Optional: add knowledge sources, such as the Confluence space that holds product context and the
   glossary.
4. Optional: give the agent Jira actions (create issue, edit issue) so it can write the description
   itself. Without actions, the PM pastes the output into the ticket. Either way the agent asks
   before it touches a ticket.
5. Share the agents with the product team. Use the Jira issue type named in
   `espec/config.yaml` under `tickets.jira.feature_issue_type`. A description template is in
   [product-ai/ticket-templates/jira-feature-definition.md](../product-ai/ticket-templates/jira-feature-definition.md).

### Microsoft 365 Copilot (Product Managers, Designers)

1. Open Copilot agent builder and create an agent. Paste the instructions from
   [product-ai/m365-copilot/feature-definition-agent.md](../product-ai/m365-copilot/feature-definition-agent.md).
2. Create a second agent from
   [product-ai/m365-copilot/design-notes-agent.md](../product-ai/m365-copilot/design-notes-agent.md).
3. Optional: add a SharePoint site or document library with product context as knowledge.
4. Share the agents with the product team.
5. No agent builder available? Paste
   [product-ai/prompts/feature-definition.prompt.md](../product-ai/prompts/feature-definition.prompt.md)
   at the start of a Copilot chat, then describe the feature. The output is the same document.

The result is pasted into the ticket. For GitHub Issues, use the issue template that ships with the
repository, or the body in
[product-ai/ticket-templates/github-issue-feature-definition.md](../product-ai/ticket-templates/github-issue-feature-definition.md).

### GitHub Copilot (Developers, QA, reviewers)

1. From a checkout of this repository, run `bash bin/espec init path/to/your-repo`
   (or `pwsh bin/espec.ps1 init path/to/your-repo`). It copies `template/`, never overwrites, and
   prints the next steps. Copying `template/` by hand works too.
2. Fill in `espec/project.md` and `espec/config.yaml`: ticket system, project key or repo, stack,
   where tests live, where tech proposals are reviewed.
3. Commit. Prompt files are read from the repository, so the whole team gets the commands on their
   next pull. The `espec-validate` workflow now checks `espec/` on every pull request.
4. Restart the IDE so the prompt files under `.github/prompts/` are picked up. In Copilot Chat the
   commands then appear as `/espec-feature-definition`, `/espec-tech-proposal`,
   `/espec-implementation`, `/espec-archive` and `/espec-archive-clean`. If they do not appear,
   check that prompt files are enabled in the IDE's Copilot settings.
5. Enable an MCP server when the organisation allows it: the Atlassian MCP server for Jira, or the
   GitHub MCP server for GitHub Issues. With one of them the tech proposal fetches the ticket by key
   or URL. Without one, the developer pastes the ticket description.
6. For GitHub Issues with the Copilot coding agent: nothing more to set up.
   `.github/copilot-instructions.md` is read automatically and tells the agent to produce a tech
   proposal pull request before any implementation.

The instructions in `.github/instructions/espec.instructions.md` apply whenever Copilot edits a file
under `espec/`, with or without a command.

### DiffCompass (reviewers, developers)

[DiffCompass](https://github.com/Mindera/diffcompass) is the code review tool for implementation pull
requests: an agent-led tour of the diff in a local browser, where the reviewer asks questions and
leaves line feedback. It works with Codex, Claude Code, Gemini CLI and GitHub Copilot CLI.

1. Install it with the instructions in its README. The repository is public; the installer needs Git
   and falls back to a plain download when the GitHub CLI is not signed in. Check with
   `diffcompass doctor`.
2. `espec init` adds `.diffcompass.json` at the repository root. It tells the DiffCompass agent to
   read the change folder before explaining code, order the tour by **How to review** in
   `pull-request.md`, and flag code that differs from the tech proposal or the delta specs, behaviour
   no acceptance criterion describes, and direct edits to `espec/specs/`. Add project rules under
   `analysis.instructions`; init never overwrites the file.
3. `review.tool: diffcompass` in `espec/config.yaml`, the template default, makes
   `/espec-implementation` print the review commands when it finishes. Set it to `none` to turn
   that off.
4. Review a pull request with `diffcompass pr <number> --open`, or a branch before it has one with
   `diffcompass --base origin/main --open`. The tour helps the review; approval still happens in the
   pull request.
