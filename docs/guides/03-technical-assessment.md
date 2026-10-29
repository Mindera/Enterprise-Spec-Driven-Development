# Step 3: Technical assessment

Between a definition that is complete and a tech proposal that designs the solution sits a question
the inspection does not answer: **can we build this, with what we have, and what do we not know
yet?** A developer runs `/espec:assess` in the repository, checks what it found, posts the assessment
comment on the ticket, and the team aligns on scope in refinement before anyone writes a proposal.

| | |
|---|---|
| Command | `/espec-assess <ticket key, URL or change name>` in Copilot Chat, agent mode. Read-only: it prints a report and a comment for the ticket. |
| Who | A developer leads. Product, Design, QA and other teams join as needed. The team closes it in refinement. |
| Input | The ticket (Ready for tech proposal, or as far as product could take it), designs and research, the main specs, the code |
| Output | An assessment comment on the ticket. The ticket description updated by product after scope decisions. An outcome: **Ready for tech proposal** or **Further discovery required**. |
| Time | Minutes for the command, one to four hours checking its evidence and talking to owners, a thirty-minute refinement |
| Rules | [AGENTS.md, Technical assessment report](../../template/espec/AGENTS.md#technical-assessment-report) |

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

```text
/espec-assess BILL-142
```

It fetches the ticket when Copilot can reach it (otherwise it asks you to paste the description),
reads `espec/AGENTS.md`, `espec/project.md` and the main specs, then searches the code. The report
has a fixed shape; see the [worked example](../../examples/inspections/assess.md):

| Section | What it holds |
|---|---|
| What exists today | One row per `AC-n` and per constraint: what the code already does, what is missing, with file paths. "Nothing found" is a valid answer |
| Capabilities touched | The main specs and requirements the feature adds to, changes or only reads |
| Dependencies outside the repository | Services, contracts, infrastructure, approvals this repository does not control, each **Unconfirmed** with the owner to ask |
| Alternatives for product | Materially different ways to meet a use case, with what product gains and gives up. No choice is made |
| Criteria that cannot be met as written | Each with an outcome rephrasing product can accept, or the scope decision it needs |
| Spikes | Only questions that reading the code cannot answer, with the criteria waiting on them |
| Findings and outcome | Numbered, Blocking or Advisory. **Ready for tech proposal** only with zero blocking findings; otherwise **Further discovery required** |
| Comment for the ticket | Ready to paste |

Ask it to save the report with "save it" when you want it in the change folder later
(`espec/changes/<change-name>/inspections/YYYY-MM-DD-assess.md`).

### Check the evidence

The command is a starting point, not a verdict. Before you post anything:

- Open the paths it cites for the "exists today" claims you will rely on. An existing test is
  evidence that a behaviour is kept, not that a new one is met.
- Code evidence tells you what this repository does; it does not confirm another team's capability or
  delivery commitment. Talk to every owner it lists, or leave the dependency Unconfirmed.
- Where you know more than the code shows (a migration in flight, a contract being renegotiated), add
  it to the comment as your own finding.

The assessment decides nothing. The moment you are choosing a queue or sketching a table, stop: that
is the tech proposal, and it is written against the agreed scope, which you do not have yet.

### Post the comment

Paste the **Comment for the ticket** as a comment from you. Alternatives and recommendations are
information for product; they do not become requirements unless product accepts them and updates the
description. Move the ticket to **In technical assessment** while the outcome is open (see
[Product setup](setup-product.md) for the statuses).

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

### Further discovery required

The ticket moves to **Further discovery required** with every blocking item owned and dated: a
question for product, a confirmation from another team, a spike. When they land:

1. Product updates the ticket description for any scope decision.
2. Re-run `/espec-inspect-feature-definition` if the description changed.
3. Re-run `/espec-assess`. It reads the earlier assessment comment, says which blocking findings are
   now resolved and by what, and its new comment supersedes the old one. Post it.
4. When the new outcome is Ready for tech proposal, move the ticket to that status.

The comment thread is the record of how the feature got from "not yet" to "ready".

## Hand-off

Ready: [the tech proposal](04-tech-proposal.md), which imports the updated description. Further
discovery: the loop above, until the outcome is Ready.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The assessment reads like a tech proposal | The investigation turned into design | Cut everything that chooses a solution. Keep what exists, what is unknown, what product must decide |
| "The code already does X" turns out to be wrong | Copilot assumed | Ask for the path and the test, open them. Record assumptions as assumptions |
| `/espec-` does not list `assess` | The repository was initialised with a toolkit older than v1.0.3 | Run `espec update` from the toolkit ([Updating later](setup-engineering.md#updating-later)) |
| A dependency on another team is marked confirmed from the code | Code evidence is not a commitment | Confirm with the owner, in writing, and link it |
| Refinement re-litigates the why | The assessment was shared without the inspected definition | Send both. The why is settled in the definition; refinement decides scope |
| Everything is a spike | Fear of committing | A spike proves one thing in a bounded time. If you cannot name what it proves, it is not a spike |
