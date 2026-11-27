---
agent: agent
description: "espec phase 1 · AI Assisted Feature Definition: write, import or review a feature definition or a bug report (what and why, never how), read a feature's Figma frames into the UI design section in the same run, and store it as feature.md."
---

# /espec:feature-definition

You are helping define a feature in **product language**: the what and the why. You never write the how.
One command covers the definition and its design: when the feature has frames in Figma, you read them
and fill the UI design section in the same run (**The design step**, below).
Read [espec/AGENTS.md](../../espec/AGENTS.md), [espec/project.md](../../espec/project.md) and
[espec/config.yaml](../../espec/config.yaml) before you start. Follow the **Feature definition format**
and **The product boundary** sections exactly.

Input: `${input:source:Ticket key or URL, a pasted feature definition or bug report, or a one-line description of the feature or the bug}`

## Modes

Pick the mode from the input. Say which mode you are in.

- **Import.** The input is a ticket key, a ticket URL, or a pasted text that starts with
  `<!-- espec:feature-definition v1 -->` or with `# Feature:` (Jira drops the marker). Fetch the ticket
  when a tool can reach it (an Atlassian or GitHub MCP server, a fetch tool, or the GitHub CLI). When
  nothing can reach it, ask the user to paste the ticket description. Then review it (below) and store
  it. A Jira description has no marker and no header line: build them as AGENTS.md describes, from the
  ticket's key and reporter, the designer named in UI design and the readiness check.
- **Draft.** The input is a description or an idea. Interview the user, then write the definition.
- **Review.** The input names an existing `espec/changes/<change-name>/feature.md`. Check it and
  report gaps.

A bug is defined with the same command and the same three modes. The input is a bug report when it
starts at `# Bug:`, is a ticket of the tracker's bug type, or describes something broken rather than
something new. Say so and follow **Bugs**, below. Ask once when it is not clear which it is.

## Draft: the interview

Ask in short rounds, at most four questions per round. Stop asking when you can fill every section.
Skip questions whose answers are already in the input. Suggested order:

1. Why now, who has the problem, what happens if nothing changes.
2. What the user can do afterwards that they cannot do today.
3. Use cases: actor, trigger, main flow, outcome. Ask for the second and third use case explicitly.
4. Edge cases. Walk the list from AGENTS.md (empty data, limits, concurrency, permissions, offline,
   partial failure, time zones, locales, currencies, duplicates, retries, undo, error states).
   Propose edge cases yourself and ask the user to confirm or reject each one.
5. Out of scope. Propose nearby work that is probably excluded and ask.
6. Constraints and success metrics.
7. UI design. Whether the feature has screens, and the links to the Figma frames when the designs
   exist. No screens: the section is marked "not needed" with the reason.
8. Open questions and who owns each.

Write the document after the interview, not during it, so the user reviews one coherent text.

## Guarding the product boundary

Whenever the user (or the imported ticket) states a **how** as defined in AGENTS.md:

1. Quote it and say it looks like implementation detail that belongs in the tech proposal.
2. Offer a rephrasing as an outcome. Example: "use a background job" becomes "the export must not
   block the screen and must finish within 10 seconds".
3. Ask once: "Are you sure you want to force this into the feature definition?"
4. On a clear yes, record it under `## Forced technical notes` as `FT-n` with the ⚠️ marker and
   the reason the user gave. Keep every other section free of it.
5. On no, use the rephrasing.

Never silently drop a forced note and never silently keep a how elsewhere in the document.

## The design step

When the feature has design frames in Figma, read them in this run instead of handing over to a second
command.

- **When it runs.** Draft: the interview asked for the frame links. Import and Review: when the
  definition, the ticket or the input links Figma frames and the UI design section does not map them
  to `UC-n` and `EC-n` yet, ask once whether to read them now.
- **What it does.** With `feature.md` on disk, follow steps 2 to 6 of
  [espec-design-context.prompt.md](espec-design-context.prompt.md) for this change: collect the frame
  links, read each frame through the Figma MCP server, interview on how the design behaves, and write
  the UI design section plus the `EC-n` and `AC-n` the person confirms. Leave the ticket alone there:
  this command prints the final text and offers the ticket update once, under **Storing the result**.
- **When it cannot run.** No frames yet, no Figma MCP server connected, or the person says later: say
  which, and continue. The UI design section stays as the interview left it, or "not needed" with the
  reason, and the review checklist judges it as it is. `/espec:design-context <change-name>` runs
  this same step on its own once the frames exist.

## Bugs

A bug report takes the place of the feature definition. Its format, the bug readiness check and what
each later phase does differently are in **Bug fixes** in AGENTS.md. What changes here:

- **Interview.** Ask for: who is affected, how often and what it costs them; what they expected and
  what happened instead; the steps to reproduce from a known state (where, who, which data), or how
  often it happens when it cannot be reproduced at will; nearby problems this fix leaves out; what
  must be true once it is fixed, as `AC-n`. No use cases, no edge cases, no UI design, no design step.
- **Expected behaviour.** Look under `espec/specs/` for the scenario that describes the expected
  behaviour and name it in What (capability › requirement › scenario). When a spec describes the
  actual behaviour as the intended one, say that this reads as a change of behaviour, a feature, and
  ask how to continue.
- **Boundary.** A suspected cause or a proposed fix is a how: guard it as above.
- **Check.** Run the bug readiness check from AGENTS.md in place of the review checklist.
- **Store.** As below, in the bug format, with `kind: bug` in `.espec.yaml`. For Jira, print it from
  `# Bug:` down.

## Small lane

When `.espec.yaml` says `lane: small`, or the user asks for the short form for a small change, write
the short definition of **Lanes** in AGENTS.md: Why, What, Out of scope, Acceptance criteria and Open
questions. Ask only for those, skip the design step, and check only the items of the review checklist
that those sections answer. Say once when the change does not meet the small lane's conditions.

## Review checklist

Report each item as ✅ or ❌ with a one-line fix:

- `Why` explains the problem and the cost of doing nothing.
- `What` is written from the user's point of view with no solution.
- At least one `UC-n` with actor, trigger, main flow and outcome.
- `Edge cases` has at least one `EC-n`, or an explicit justification why none apply.
- `Out of scope` is an explicit list.
- Every `UC-n` and `EC-n` is covered by an `AC-n`; every `AC-n` names what it covers.
- `UI design` is filled or marked "not needed" with a reason.
- `Open questions` is either `None` or every question has an owner.
- No how outside `## Forced technical notes`.

The definition is **Ready for tech proposal** only when every item passes. Set the status line accordingly.
Run the checklist after the design step, not before: the UI design section and any new `EC-n` and
`AC-n` change the result.

## Storing the result

1. Derive `<change-name>` as described in AGENTS.md (ticket key in lower case plus a slug, or a
   verb-first slug when there is no ticket yet). If `espec/changes/<change-name>/` exists, ask whether
   to update it or create a new one.
2. Write `espec/changes/<change-name>/feature.md` with the full document, starting with the marker.
   Then run the design step when it applies, and the review checklist on the result.
3. Write `espec/changes/<change-name>/.espec.yaml` from `espec/templates/espec.yaml` with
   `status: defined` when the definition is ready, otherwise leave the status line in `feature.md` as
   `Draft` and still write the file.
4. Print the document once more in a single Markdown block so it can be pasted into the ticket. For
   Jira (`tickets.system` in config.yaml), print it from `# Feature:` down, without the marker and the
   header line: Jira drops the marker and holds the rest in fields. When the ticket system is reachable
   through a tool and the user asks, update the ticket description with the same text. Never update a
   ticket without being asked.
5. When the user is a Product Manager or a Designer (ask when it is not clear), the ticket is the
   hand-off, not the repository. Say that the change folder is their local working copy: they do not
   commit it, and they delete it once the ticket holds the final text. Engineering starts from the
   ticket with `/espec:inspect-feature-definition`.

## Guardrails

- Do not write a tech proposal, specs, tasks or application code. If asked, point to
  `/espec:tech-proposal` and stop.
- Do not invent use cases, metrics or constraints. Ask, or mark them as open questions.
- Keep the ticket and `feature.md` identical from `# Feature:` down. When they differ, show the
  difference and ask which wins.
- Do not paste `project.md` or `config.yaml` content into the document.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
