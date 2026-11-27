# Product AI pack

Everything Product Managers and Designers need to run **Phase 1 · AI Assisted Feature Definition**
with the tools they have: Atlassian Rovo or Microsoft 365 Copilot. Nothing here goes into a code
repository. It lives wherever your product team keeps its working material (Confluence, SharePoint,
a shared drive).

Product Managers and Designers who have GitHub Copilot do not need this pack: they run
`/espec-feature-definition` in a local copy of the repository, one command for the definition and its
UI design, commit nothing, and write the result to the ticket. See
[GitHub Copilot for Product Managers and Designers](../docs/roles-and-tools.md#github-copilot-product-managers-designers).
Both ways end on the same ticket. The ticket templates here apply to both.

| Folder | What is in it | Who uses it |
|--------|---------------|-------------|
| `rovo/` | Two Rovo Agent definitions: Feature Definition, which also writes bug reports, and UI Design. Name, description, starters and the full instructions to paste. | Rovo admins, then PMs and Designers |
| `m365-copilot/` | The same two agents for Microsoft 365 Copilot agent builder. | M365 admins, then PMs and Designers |
| `prompts/` | Copy-paste prompts for any chat when creating an agent is not possible: define a feature or report a bug, add the UI design, review a definition or a bug report. | PMs, Designers, reviewers |
| `ticket-templates/` | The feature definition and the bug report, each as a Jira description template and as a GitHub issue template, plus the ticket workflow. | PMs, Jira and GitHub admins |

## The one rule

A feature definition says **what** and **why**. It never says **how**. The agents enforce this: when
you state a solution they ask you to rephrase it as an outcome, and if you insist they record it as a
⚠️ forced technical note that engineering reviews in the tech proposal.

## Setup in five minutes

1. Pick your tool: `rovo/` or `m365-copilot/`.
2. Create the Feature Definition agent from the file. Paste the Instructions block as is.
3. Create the UI Design agent the same way.
4. Share both agents with the product and design teams.
5. Add the ticket templates to Jira or GitHub so every feature and every bug starts with the same
   structure.

## Using it

1. Open the agent and say "Define a new feature with me". Answer the questions. Insist on edge cases.
2. When the readiness check is all ✅, paste the result into the ticket and set the status line to
   **Ready for tech proposal**.
3. Ask a Designer to run the UI Design agent on the ticket and paste the UI design section back.
4. A developer assesses the ticket against the code with `/espec:assess` and posts the result as a
   ticket comment: what exists today, what depends on other teams, alternatives with their
   consequences, anything that cannot be met as written. Decide on what it raises; the ticket
   description stays the agreed scope until you change it.
   When the outcome is **Further discovery required**, answer what is yours, update the description,
   and engineering re-assesses; the new comment says what was resolved.
5. Once the assessment outcome is **Ready for tech proposal**, engineering picks the ticket up with
   `/espec:tech-proposal`. Their questions come back as a ticket comment. Answer them in the ticket;
   they re-import the definition.
6. When the work is built and verified, engineering posts an **acceptance request** on the ticket:
   where to try it and, criterion by criterion, what you should see. Try it and reply "Accepted", or
   say which criterion is not as defined. This is a look at the working result, not a second test
   pass. Something you now want that the definition does not say is new scope: update the
   description and engineering picks it up as a proposal update or a ticket of its own.
7. The release note that closes the ticket lists your success metrics under "To check after release",
   each with its date. On that date engineering asks for the numbers. Give them: met, not met or not
   measured. A metric that was not met is your call: nothing, a new ticket, or a rollback.

## Bugs

A bug is something that does not do what was intended. Whoever found it (QA, support, a developer, a
Product Manager) opens the Feature Definition agent and says "Report a bug with me". It asks who is
affected and how often, what was expected and what happened instead, and the steps to reproduce, then
prints a bug report with its own, shorter readiness check. Paste it into the ticket and set the status
to **Ready for tech proposal**.

A bug has no UI design pass and no technical assessment: engineering picks the ticket up with
`/espec:tech-proposal`, finds the root cause, and starts the fix with a test that reproduces the bug.
A suspected cause or a proposed fix is a how and stays out of the report. Asking for behaviour the
product never had is a feature: define it as one.

---

<sub>GitHub Copilot is a trademark of GitHub, Inc. and Microsoft Corporation. Microsoft 365 Copilot is a trademark of Microsoft Corporation. Rovo is a trademark of Atlassian Pty Ltd. Enterprise Spec Driven Development is an independent project and is not affiliated with, sponsored by, or endorsed by GitHub, Microsoft or Atlassian.</sub>
