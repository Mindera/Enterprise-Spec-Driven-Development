# Step 1: Feature definition

Product writes the **what** and the **why** of a feature with an AI agent that refuses to write the
**how**. The result is a ticket description in a fixed format that engineering imports unchanged.

| | |
|---|---|
| Command | `/espec:feature-definition`. In Rovo or M365 Copilot, the `espec Feature Definition` agent. In GitHub Copilot, `/espec-feature-definition`, one command for the definition and its UI design. |
| Who | The Product Manager. Then the Designer for the UI design section. A developer when the work has no product owner. |
| Two ways to start | Without GitHub Copilot, the agents in Rovo or M365 Copilot. With GitHub Copilot, one command in a local copy of the repository, never committed ([below](#in-github-copilot)). Both end on the ticket and join at [the inspection](02-inspect-feature-definition.md). |
| Input | An idea, a problem, a draft, or an existing ticket |
| Output | The feature definition, pasted as the ticket description, status line **Ready for tech proposal** |
| Time | Thirty to ninety minutes for a feature of normal size, in one or two sittings |
| Rules | [AGENTS.md, Feature definition format](../../template/espec/AGENTS.md#feature-definition-format-featuremd) and [The product boundary](../../template/espec/AGENTS.md#the-product-boundary) |

## Before you start

- You can say who has the problem, what it costs them today, and what changes if it is solved.
  If you cannot, the interview will stall at the first question. Talk to the users first.
- The ticket exists, or you know which project it will go in. The ticket key goes into the
  definition.
- The agent is set up and shared ([product setup](setup-product.md)), or you have GitHub Copilot and
  a local copy of the repository with the Figma and ticket MCP servers connected
  ([setup](../roles-and-tools.md#github-copilot-product-managers-designers)).
- You have thirty minutes without interruptions. The agent asks in rounds and the answers build on
  each other.

## Run it

### The interview

Open the agent and say "Define a new feature with me", then describe the feature in one or two
sentences. The agent interviews you in rounds of at most four questions, in this order:

1. Why now, who has the problem, what happens if nothing changes.
2. What the user can do afterwards that they cannot do today.
3. Use cases: actor, trigger, main flow, outcome. It asks for a second and a third.
4. Edge cases. It proposes from a checklist (empty data, limits, two people at once, permissions,
   offline, partial failure, time zones, locales, currencies, duplicates, retries, undo, what the
   user sees when something fails) and asks you to confirm or reject each one.
5. Out of scope. It proposes nearby work that is probably excluded and asks.
6. Constraints and success metrics.
7. Open questions, each with an owner.

Answer with specifics: real numbers, real role names, real dates, the actual wording of the
customer request. "Finance wants exports" becomes a weak definition. "35 support requests a month
for database extracts, each taking two days, most of them in close week" becomes a strong one. The
worked example [feature.md](../../examples/changes/bill-142-invoice-csv-export/feature.md) shows the
level of detail that lets engineering start without a meeting.

### When you state a how

Sooner or later you will say "use the nightly batch job" or "add a column to the invoices table".
The agent quotes it, says it looks like implementation detail, and offers an outcome instead: "the
export must be ready within 10 seconds". Take the outcome whenever you can. Engineering reads
outcomes as constraints and has the freedom to meet them well.

When you have a real reason to insist (a contract, an operational constraint, a dependency nobody
else knows about), say yes when the agent asks "Are you sure you want to force this?". It is recorded
under **Forced technical notes** as `FT-n` with the ⚠️ marker and your reason, and nowhere else.
Engineering must accept or override every `FT-n` in the tech proposal, with a reason. Nothing forced
is lost; nothing forced leaks into the requirements.

### The document and the readiness check

When every section can be filled, the agent writes the whole document at once, then prints the
readiness check: nine lines, each ✅ or ❌ with a one-line fix. Fix the ❌ lines with the agent until
all nine pass. The status line then reads **Ready for tech proposal**. If you stop earlier, it reads
**Draft**, and that is an honest state: engineering can still inspect a draft, it just will not start
a proposal on it.

Read the document yourself before you paste it. The agent's check tests the form. You test the
truth: are those the real use cases, is the out-of-scope list what you mean, would you sign the
acceptance criteria?

### Paste into the ticket

Paste the document as the ticket description. In a GitHub issue it starts with the marker line. In
Jira the agent prints it from `# Feature:` down, because Jira drops the marker and holds the key, the
reporter and the status in fields. Set the ticket status to match the readiness check. With Rovo and Jira actions enabled you can ask the agent to write the
description; it asks before every write.

### The Designer's pass

The Designer opens the `espec UI Design` agent, pastes the current ticket description, and answers
its questions about flows, screens and states, content, accessibility and devices. The agent returns
the **UI design** section and proposes new `EC-n` and `AC-n` entries numbered after the
highest existing ones. The Designer pastes the section into the ticket and adds the new entries to
their sections. The PM re-reads the acceptance criteria: a new state is a new thing to test.

### In GitHub Copilot

A Product Manager or Designer with GitHub Copilot runs the same steps as one command, in a local copy
of the repository:

```text
/espec-feature-definition BILL-142
```

1. It runs the same interview (Draft mode), or imports the ticket when it already has a draft (Import
   mode), and writes `espec/changes/<change-name>/feature.md` locally. The interview also asks for the
   links to the Figma frames.
2. In the same run it reads the Figma frames, then interviews you, the PM or the Designer, on what the
   frames cannot show: what each action does, what the user sees when something is empty, slow or
   fails, and which use case or edge case each screen serves. It writes the **UI design** section and
   proposes new `EC-n` and `AC-n` entries for behaviour the design shows but the definition lacks. The
   PM confirms or rejects each one. Then it runs the readiness check on the whole document.
3. Let Copilot write the ticket description when it asks (an Atlassian or GitHub MCP server must be
   connected), or paste the printed text yourself.
4. Delete the local change folder. Do not commit it: the ticket is the hand-off, and engineering
   imports from it exactly as it does from the Rovo or M365 stream.

When the frames are not ready yet, or no Figma MCP server is connected, the command says so and
finishes the definition without them. Run the design step alone once the frames exist, before the
ticket goes to engineering:

```text
/espec-design-context bill-142-invoice-csv-export
```

### A developer starting in the repository

A developer with an idea and no product owner yet runs, in Copilot Chat:

```text
/espec-feature-definition add-invoice-csv-export
```

Draft mode runs the same interview. The result is stored at
`espec/changes/<change-name>/feature.md` with a `.espec.yaml`. Paste it into a ticket so product can
own it. A definition nobody from product has read is still a draft, whatever the status line says.

The same command with a ticket key or URL runs Import mode: it fetches the ticket (or asks for a
paste), reviews it and stores it. The tech proposal step does this on its own, so developers rarely
need Import mode directly.

### Reporting a bug

Something broken is not a feature. Whoever found it (QA, support, a developer, you) says "Report a
bug with me" to the same agent, or runs `/espec-feature-definition` with a description of what is
broken. The interview is shorter: who is affected and how often, what you expected and what happened
instead, the steps to reproduce from a known state, what this fix leaves out, and what must be true
once it is fixed. There are no use cases, no edge cases and no Designer's pass.

Two things to hold on to. A suspected cause or a proposed fix is a how: leave it out, engineering
finds the root cause in the tech proposal. And expected behaviour the product never had is a feature,
however small: define it as one. In GitHub Copilot the command looks for the main spec scenario that
describes the expected behaviour and names it in the report.

The result goes on the ticket like a feature definition, with its own seven-line readiness check. A
bug skips the technical assessment: after [the inspection](02-inspect-feature-definition.md) it goes
straight to [the tech proposal](04-tech-proposal.md). Format and rules:
[AGENTS.md, Bug fixes](../../template/espec/AGENTS.md#bug-fixes). A worked report:
[examples/changes/bill-171-fix-jpy-amounts-in-export/feature.md](../../examples/changes/bill-171-fix-jpy-amounts-in-export/feature.md).

## What good looks like

- All nine readiness lines pass, and you agree with them.
- Every use case has a named actor and a concrete trigger, not "the user" and "when needed".
- Edge cases came from the checklist and from the Designer's states. Each one has an acceptance
  criterion.
- Out of scope is a list a stakeholder could argue with. "Nothing" is not an answer.
- Constraints are outcomes with numbers and dates (within 10 seconds, EU only, before the December
  freeze).
- Open questions is "None", or every question has a name next to it.
- No how outside Forced technical notes, and every forced note has the reason you gave.
- A QA engineer could write the test plan from the acceptance criteria alone.

## Hand-off

The ticket description is the source of truth from here on, whichever tool product used. Both
streams join here: engineering runs [the inspection](02-inspect-feature-definition.md), then
[the technical assessment](03-technical-assessment.md), and imports the description into the
repository. When engineering's Questions for Product arrive as a
comment, answer in the ticket and **update the description**, then say so in a comment. Engineering
re-imports from the description. A change that only lives in a comment is lost.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| The agent writes the document too early | You gave it a long draft; it skipped the interview | Ask it to review the draft against the readiness check and to ask what is missing |
| Every edge case proposed gets a yes | Confirming is easier than thinking | For each one, say what the user should see. If you cannot, it is a question for product, not an edge case |
| The definition describes the solution | Hows slipped in before the agent could catch them | Run the [review prompt](../../product-ai/prompts/review-feature-definition.prompt.md); it quotes every how and offers rephrasings |
| Acceptance criteria repeat the use cases | No measurable THEN | Add the number, the state or the message the user sees. "Within 10 seconds", "the file name includes the view name" |
| Engineering comes back with fifteen questions | The why was clear, the what was thin | Add the use cases engineering asked about, re-run the readiness check, update the description |
| The feature is really three features | One definition cannot hold them | Split. One ticket, one definition, one change folder |
