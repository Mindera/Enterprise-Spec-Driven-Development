# Product setup

How to give Product Managers and Designers the espec Feature Definition and Design Notes agents in
the tool they already have, Atlassian Rovo or Microsoft 365 Copilot, and the ticket template that
engineering's tools recognise. Nothing here touches a code repository.

| | |
|---|---|
| Who | A Rovo or M365 Copilot admin to create and share the agents (fifteen minutes). A Jira or GitHub admin for the ticket template (ten minutes). Then every PM and Designer. |
| Needs | Rovo with agent creation enabled, or Microsoft 365 Copilot with agent builder. A Jira project or a GitHub repository for tickets. |
| Result | Two shared agents, a ticket template, and a product team that can produce a definition engineering accepts without a rewrite. |

Everything to paste lives in [product-ai/](../../product-ai/README.md).

## Step 1: pick the tool

| You have | Use | Notes |
|---|---|---|
| Atlassian Rovo | [rovo/](../../product-ai/rovo/feature-definition-agent.md) | The agent can read and, when asked, write the Jira description through Jira actions |
| Microsoft 365 Copilot | [m365-copilot/](../../product-ai/m365-copilot/feature-definition-agent.md) | The agent writes the document; the PM pastes it into the ticket. The Instructions field takes 8,000 characters; the text fits |
| Neither, or no permission to create agents | [prompts/](../../product-ai/prompts/feature-definition.prompt.md) | Paste the prompt at the start of any chat. Same output, no setup |

## Step 2: create the Feature Definition agent

In Rovo: Rovo, then Agents, then Create agent. In M365 Copilot: Copilot, then Create agent, then
Configure. In both:

1. **Name:** `espec Feature Definition`. Short, so it is easy to @-mention.
2. **Description:** copy it from the agent file.
3. **Instructions:** paste the whole `Instructions` block from the agent file, unchanged. Do not
   summarise it: the readiness check and the product boundary rules are the point.
4. **Conversation starters:** the four in the agent file.
5. **Knowledge (optional):** the Confluence space or SharePoint site with product strategy, personas
   and the glossary. This is what makes the agent use your words.
6. **Actions (Rovo, optional):** Jira "Create work item" and "Update work item description". The
   agent uses them only when asked, and asks before every write.
7. **Capabilities (M365):** none. Leave code interpreter and image generation off.
8. **Share** with the product and design groups.

## Step 3: create the Design Notes agent

Same steps with [rovo/design-notes-agent.md](../../product-ai/rovo/design-notes-agent.md) or
[m365-copilot/design-notes-agent.md](../../product-ai/m365-copilot/design-notes-agent.md). Name it
`espec Design Notes`. Knowledge: design principles, content guidelines, accessibility standards.
Share with the design group.

## Step 4: add the ticket template

**Jira.** Save
[ticket-templates/jira-feature-definition.md](../../product-ai/ticket-templates/jira-feature-definition.md)
as the description template of the issue type that carries features (set the same type in the
repository's `espec/config.yaml` under `tickets.jira.feature_issue_type`). Add the workflow statuses
from that file, or map them onto the statuses you have:

| Status | Who moves it | Meaning |
|---|---|---|
| Draft | Product | Definition in progress |
| Ready for tech proposal | Product | The readiness check passed; engineering can investigate |
| In technical assessment | Engineering | A developer is assessing the ticket against the code with `/espec:assess` |
| Further discovery required | Engineering | The assessment raised blocking items: a product decision, a confirmation from another team, a spike. Each is in the assessment comment with an owner. Product answers and updates the description; engineering re-assesses |
| Assessed, ready for tech proposal | Engineering | The assessment outcome is Ready for tech proposal and the description holds the agreed scope |
| Tech proposal in review | Engineering | The proposal pull request exists; Questions for Product may be in a comment |
| In progress | Engineering | Implementation started |
| Done | Engineering | Archived; the release note is the last comment |

**GitHub Issues.** Nothing to do: the repository initialised by engineering carries
`.github/ISSUE_TEMPLATE/feature-definition.md`, so "New issue, Feature definition" opens the skeleton
with the `feature-definition` label applied.

Keep the first line of the template, `<!-- espec:feature-definition v1 -->`. It is how engineering's
tools recognise a feature definition. Jira shows it as plain text, which is fine. Check once that it
survives a paste into your Jira editor and comes back when the description is fetched.

## Step 5: run one definition together

Book thirty minutes with the PMs and Designers and define a real, small feature with the agent on
screen. Three things to show:

- **The interview.** The agent asks in rounds of at most four questions and insists on a second and
  third use case and on edge cases. Answer with specifics (numbers, names, dates). Vague answers
  produce vague definitions.
- **The product boundary.** Say a how on purpose ("use the nightly batch job") and watch the agent
  quote it, offer an outcome instead, and ask once whether to force it. Show what a forced technical
  note looks like and explain that engineering must answer it in the tech proposal.
- **The readiness check.** Nine lines, each ✅ or ❌ with a fix. The definition is Ready for tech
  proposal only when every line passes.

Then show the hand-off: paste into the ticket, set the status, and what engineering sends back:
a comment from `/espec:inspect-feature-definition`, then the technical assessment from
`/espec:assess` (what exists, dependencies on other teams, alternatives for product to decide), and
later Questions for Product. "Further discovery required" is not a rejection: it is a list of
decisions and confirmations, each with an owner, after which engineering assesses again.

## Step 6: give reviewers the review prompt

Anyone can check a ticket before engineering sees it with
[prompts/review-feature-definition.prompt.md](../../product-ai/prompts/review-feature-definition.prompt.md).
It runs the same checks as engineering's inspect command, so both sides reach the same verdict. QA
and product leads use it most.

## Verify the setup

- A PM can open the agent, say "Define a new feature with me", and reach a definition with all nine
  readiness lines ✅ in one sitting.
- A Designer can paste that definition into the Design Notes agent and get an Experience and design
  section plus new `EC-n` and `AC-n` entries numbered after the existing ones.
- The pasted ticket starts with the marker line.
- Engineering runs `/espec-inspect-feature-definition` on that ticket and gets zero blocking findings.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The agent writes the document after the first answer | Instructions were shortened or paraphrased | Paste the Instructions block unchanged |
| The agent accepts "use service X" without comment | Same | Same. The product boundary rules are in the block |
| M365 agent builder rejects the instructions | Over 8,000 characters after edits | Use the file as is; it fits |
| Jira strips the marker line or renders it oddly | Editor conversion on paste | Paste as plain text, or add the marker line by hand as the first line. Confirm once that a fetch returns it |
| Engineering's inspect finds hows the agent missed | The readiness check is the agent's own opinion | Run the review prompt before handing over; trust the inspect verdict |
| Ids restart at 1 after the Designer's pass | The Designer pasted an old version | Always paste the current ticket description; the agent numbers after the highest existing id |
