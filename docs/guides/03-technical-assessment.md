# Step 3: Technical assessment

Between a definition that is complete and a tech proposal that designs the solution sits a question
the inspection does not answer: **can we build this, with what we have, and what do we not know
yet?** A developer investigates with Copilot in the repository, posts an assessment comment on the
ticket, and the team aligns on scope in refinement before anyone writes a proposal.

| | |
|---|---|
| Command | None yet. Copilot Chat in agent mode, in the repository, with `espec/AGENTS.md`, `espec/project.md`, `espec/specs/` and the ticket as context. |
| Who | A developer leads. Product, Design, QA and other teams join as needed. The team closes it in refinement. |
| Input | The ticket (Ready for tech proposal, or as far as product could take it), designs and research, the main specs, the code |
| Output | An assessment comment on the ticket. The ticket description updated by product after scope decisions. An outcome: **Ready for tech proposal** or **Further discovery required**. |
| Time | One to four hours of investigation, a thirty-minute refinement |

This step is where product and engineering meet. Product is not expected to have established
feasibility or found every dependency. Engineering is not expected to design yet. The hand-off to
this step means **ready for technical investigation**, not ready for estimation or implementation.

## Before you start

- [The inspection](02-inspect-feature-definition.md) ran and its comment is on the ticket. A Draft
  verdict is fine here when product is stuck and needs engineering input to go further; say so in
  the assessment.
- `espec/project.md` is honest, especially the traps section. The assessment leans on it.
- You have read the main specs for the capabilities the feature touches (`espec/specs/`). They say
  what the system does today in product language; the code says how.

## Run it

### Investigate with Copilot

Open Copilot Chat in agent mode and give it the context in one message: the ticket text (or key,
when it can fetch it), and a request to read `espec/AGENTS.md`, `espec/project.md` and the specs
under `espec/specs/` first. Then ask the questions the tech proposal will need answered. The ones
that pay off most:

- Which of the acceptance criteria does the system already satisfy, in part or in full? Cite the
  code and tests.
- Which capabilities in `espec/specs/` does this feature touch? Which requirements would change?
- What does the feature depend on that is outside this repository: another team's service, a
  vendor, a data source, a permission model? For each, what do we know and what must be confirmed?
- Where are there two or more credible ways to meet an acceptance criterion with materially
  different cost or risk? What would each mean for the user?
- Which acceptance criteria or constraints cannot be met as written, or only at a cost product
  should know about?
- What would a spike have to prove before a proposal could be written with confidence?

Keep Copilot on evidence: ask for file paths, test names, configuration keys. Distinguish what it
observed from what it assumed. Code evidence tells you what this repository does; it does not
confirm another team's capability or delivery commitment. Those need a conversation with the owners.

Do not let the session drift into a design. The moment you are choosing a queue or sketching a
table, stop: that is the tech proposal, and it is written against the agreed scope, which you do not
have yet.

### Write the assessment comment

Post one comment on the ticket. A format that has worked:

```markdown
## Technical assessment (YYYY-MM-DD, <name>)

**Outcome:** Ready for tech proposal | Further discovery required

### What exists today
- <acceptance criterion or capability>: <what the system does, with evidence: paths, tests, spec requirement>

### Dependencies to confirm
- <team or system>: <what we need from them>. Owner: <name>. Status: unconfirmed | confirmed on <date>

### Alternatives with consequences for product
- <AC-n or constraint>: Option A <what the user gets, cost, risk>. Option B <...>. Recommendation and why.

### Cannot be met as written
- <AC-n or constraint>: <why>. Proposed change to the definition: <outcome wording>.

### Questions for product
- <question>. Needed before: proposal | implementation.

### Spikes
- <what it proves>, <how long>, <who>. Link when created.
```

Keep it to one screen. Alternatives and recommendations are information for product; they do not
become requirements unless product accepts them and updates the description.

### Refinement

Thirty minutes with the team. The developer walks through the assessment. Product makes the scope
decisions the alternatives call for. Dependencies get an owner. Spikes get created. QA raises what
would be hard to test. The outcome is recorded in the comment thread and the PO updates the ticket
description to match: the description remains the agreed delivery scope, and the assessment comment
remains the record of why.

### Readiness rule

Go to the tech proposal when the agreed scope and the available technical evidence are enough to
write a credible proposal. Material feasibility blockers are resolved, or removed from scope by an
explicit product decision recorded on the ticket. Remaining assumptions are written down where the
proposal will pick them up. Anything else is **Further discovery required**, with each open item
owned and dated.

## What good looks like

- The assessment cites evidence for every "exists today" claim and names an owner for every
  dependency.
- Product made at least one explicit decision because of it, or you can say why none was needed.
- The ticket description changed if scope changed. If only a comment changed, nothing changed.
- The developer who writes the proposal (often the same person) can start without a meeting.

## Hand-off

Ready: [the tech proposal](04-tech-proposal.md), which imports the updated description. Further
discovery: the spikes and confirmations run, the comment is updated when they land, and the
inspection re-runs if the description changed.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The assessment reads like a tech proposal | The investigation turned into design | Cut everything that chooses a solution. Keep what exists, what is unknown, what product must decide |
| "The code already does X" turns out to be wrong | Copilot assumed | Ask for the path and the test, open them. Record assumptions as assumptions |
| A dependency on another team is marked confirmed from the code | Code evidence is not a commitment | Confirm with the owner, in writing, and link it |
| Refinement re-litigates the why | The assessment was shared without the inspected definition | Send both. The why is settled in the definition; refinement decides scope |
| Everything is a spike | Fear of committing | A spike proves one thing in a bounded time. If you cannot name what it proves, it is not a spike |
