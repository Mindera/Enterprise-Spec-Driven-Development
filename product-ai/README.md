# Product AI pack

Everything Product Managers and Designers need to run **Phase 1 · AI Assisted Feature Definition**
with the tools they have: Atlassian Rovo or Microsoft 365 Copilot. Nothing here goes into a code
repository. It lives wherever your product team keeps its working material (Confluence, SharePoint,
a shared drive).

| Folder | What is in it | Who uses it |
|--------|---------------|-------------|
| `rovo/` | Two Rovo Agent definitions: Feature Definition and Design Notes. Name, description, starters and the full instructions to paste. | Rovo admins, then PMs and Designers |
| `m365-copilot/` | The same two agents for Microsoft 365 Copilot agent builder. | M365 admins, then PMs and Designers |
| `prompts/` | Copy-paste prompts for any chat when creating an agent is not possible: define a feature, add design notes, review a definition. | PMs, Designers, reviewers |
| `ticket-templates/` | The feature definition as a Jira description template and as a GitHub issue template, plus the ticket workflow. | PMs, Jira and GitHub admins |

## The one rule

A feature definition says **what** and **why**. It never says **how**. The agents enforce this: when
you state a solution they ask you to rephrase it as an outcome, and if you insist they record it as a
⚠️ forced technical note that engineering reviews in the tech proposal.

## Setup in five minutes

1. Pick your tool: `rovo/` or `m365-copilot/`.
2. Create the Feature Definition agent from the file. Paste the Instructions block as is.
3. Create the Design Notes agent the same way.
4. Share both agents with the product and design teams.
5. Add the ticket template to Jira or GitHub so every feature starts with the same structure.

## Using it

1. Open the agent and say "Define a new feature with me". Answer the questions. Insist on edge cases.
2. When the readiness check is all ✅, paste the result into the ticket and set the status line to
   **Ready for tech proposal**.
3. Ask a Designer to run the Design Notes agent on the ticket and paste the experience section back.
4. A developer assesses the ticket against the code with `/espec:assess` and posts the result as a
   ticket comment: what exists today, what depends on other teams, alternatives with their
   consequences, anything that cannot be met as written. Decide on what it raises; the ticket
   description stays the agreed scope until you change it.
5. Engineering picks the ticket up with `/espec:tech-proposal`. Their questions come back as a ticket
   comment. Answer them in the ticket; they re-import the definition.

---

<sub>GitHub Copilot is a trademark of GitHub, Inc. and Microsoft Corporation. Microsoft 365 Copilot is a trademark of Microsoft Corporation. Rovo is a trademark of Atlassian Pty Ltd. Enterprise Spec Driven Development is an independent project and is not affiliated with, sponsored by, or endorsed by GitHub, Microsoft or Atlassian.</sub>
