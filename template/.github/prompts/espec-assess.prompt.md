---
agent: agent
description: "espec review · Technical assessment of a feature definition before the tech proposal: what the code already does, which specs are touched, dependencies on other teams, alternatives with their consequences, criteria that cannot be met as written, spikes. Read-only; prints a report and a ticket comment."
---

# /espec:assess

You assess a feature definition against the repository before anyone writes the tech proposal, and
report what engineering knows, what it does not, and what product must decide. You change nothing:
not the ticket, not `feature.md`, not the code. Read [espec/AGENTS.md](../../espec/AGENTS.md) first
and follow the **Feature definition format**, **The product boundary** and **Inspection report
formats** sections. Then read [espec/project.md](../../espec/project.md) and
[espec/config.yaml](../../espec/config.yaml) for the stack, the teams and the traps. Apply them; do
not paste them.

Input: `${input:source:Ticket key or URL, a pasted feature definition, or a change name under espec/changes/}`

## Steps

1. **Load the definition.** A ticket key or URL: fetch it when a tool can reach it (an Atlassian or
   GitHub MCP server, a fetch tool, the GitHub CLI); otherwise ask for the description to be pasted.
   A change name: read `espec/changes/<change-name>/feature.md` from disk, and when the ticket is also
   reachable, fetch it and note any difference under Findings. Pasted text: use it as is. Say which
   source you used, when it was fetched, and which branch or commit of the repository you read.
   When the ticket already carries an earlier assessment (a re-run after further discovery), read it
   and say in the comment for the ticket that this assessment supersedes it, and which of its blocking
   findings are now resolved and by what: an answer, a confirmation or a spike result.

2. **Read the main specs.** Read every spec under `espec/specs/` whose capability the feature could
   touch. List each one under Capabilities touched with the requirement names involved and whether
   the feature adds to, changes or only reads that capability. A capability with no spec yet is
   listed as new.

3. **Search the code for every acceptance criterion and constraint.** For each `AC-n` and each item
   under Constraints, look for the modules, endpoints, jobs, configuration and tests that already do
   part of it. Record what exists with file paths, what is missing, and what has to change. Write
   "nothing found" when nothing exists; never guess. An existing test is evidence that a behaviour is
   kept, not that a new one is met.

4. **List dependencies outside the repository.** Anything the feature needs that this repository does
   not control: another team's service, an API contract, infrastructure, a dashboard, a licence, a
   release slot, an approval. Mark each one **Unconfirmed** with the owner to ask and what they must
   confirm. Code that calls a service proves the call exists today; it does not prove the owner will
   support the new use.

5. **List alternatives with consequences for product.** Where the code offers a materially different
   way to meet a use case, or where a Forced technical note conflicts with an outcome in the
   definition, describe each option and what product would gain and give up: time, scope, behaviour
   the user sees. Do not pick one.

6. **List criteria that cannot be met as written.** An acceptance criterion or constraint that the
   repository or the platform cannot satisfy as stated gets an outcome rephrasing product can accept,
   or a note that it needs a scope decision.

7. **List spikes.** For each question a credible proposal cannot be written without answering, and
   that reading the code cannot answer, propose a spike: what it proves and which criteria wait for
   it. "Explore the codebase" is not a spike; do that now.

8. **Report.** Print the report in the Technical assessment report format. Number the findings, mark
   each Blocking or Advisory as AGENTS.md defines, set the outcome, and end with the comment for the
   ticket. When the user asks, save the report to
   `espec/changes/<change-name>/inspections/YYYY-MM-DD-assess.md`.

## Guardrails

- Read-only. Do not edit the definition, the ticket, the code or anything under `espec/`. Do not
  create a change folder. To fix the definition, point to `/espec:feature-definition` or the ticket;
  to design the solution, point to `/espec:tech-proposal`.
- No design decisions. Name what exists and what the options are. The choice and its reasons belong
  to the tech proposal as a `D-n`.
- Code evidence never confirms another team's commitment. A dependency stays Unconfirmed until its
  owner says otherwise, and the report names who to ask.
- Alternatives are not requirements. The ticket description stays the agreed scope until product
  changes it. Write alternatives so product can decide, not so engineering can proceed.
- Quote; do not paraphrase. A finding names the `AC-n`, the constraint or the `FT-n` and the words
  that triggered it, and every claim about the code cites a path.
- One outcome. Ready for tech proposal only with zero blocking findings.
- End the reply with the usage line from the **Usage report** section of AGENTS.md.
