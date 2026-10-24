---
mode: agent
description: "espec phase 1 · AI Assisted Feature Definition: write, import or review a feature definition (what and why, never how) and store it as feature.md."
---

# /espec:feature-definition

You are helping define a feature in **product language**: the what and the why. You never write the how.
Read [espec/AGENTS.md](../../espec/AGENTS.md), [espec/project.md](../../espec/project.md) and
[espec/config.yaml](../../espec/config.yaml) before you start. Follow the **Feature definition format**
and **The product boundary** sections exactly.

Input: `${input:source:Ticket key or URL, a pasted feature definition, or a one-line description of the feature}`

## Modes

Pick the mode from the input. Say which mode you are in.

- **Import.** The input is a ticket key, a ticket URL, or a pasted text that starts with
  `<!-- espec:feature-definition v1 -->`. Fetch the ticket when a tool can reach it (an Atlassian or
  GitHub MCP server, a fetch tool, or the GitHub CLI). When nothing can reach it, ask the user to paste
  the ticket description. Then review it (below) and store it.
- **Draft.** The input is a description or an idea. Interview the user, then write the definition.
- **Review.** The input names an existing `espec/changes/<change-name>/feature.md`. Check it and
  report gaps.

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
7. Open questions and who owns each.

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

## Review checklist

Report each item as ✅ or ❌ with a one-line fix:

- `Why` explains the problem and the cost of doing nothing.
- `What` is written from the user's point of view with no solution.
- At least one `UC-n` with actor, trigger, main flow and outcome.
- `Edge cases` has at least one `EC-n`, or an explicit justification why none apply.
- `Out of scope` is an explicit list.
- Every `UC-n` and `EC-n` is covered by an `AC-n`; every `AC-n` names what it covers.
- `Experience and design` is filled or marked "not needed" with a reason.
- `Open questions` is either `None` or every question has an owner.
- No how outside `## Forced technical notes`.

The definition is **Ready for tech proposal** only when every item passes. Set the status line accordingly.

## Storing the result

1. Derive `<change-name>` as described in AGENTS.md (ticket key in lower case plus a slug, or a
   verb-first slug when there is no ticket yet). If `espec/changes/<change-name>/` exists, ask whether
   to update it or create a new one.
2. Write `espec/changes/<change-name>/feature.md` with the full document, starting with the marker.
3. Write `espec/changes/<change-name>/.espec.yaml` from `espec/templates/espec.yaml` with
   `status: defined` when the definition is ready, otherwise leave the status line in `feature.md` as
   `Draft` and still write the file.
4. Print the document once more in a single Markdown block so it can be pasted into the ticket.
   When the ticket system is reachable through a tool and the user asks, update the ticket description
   with it. Never update a ticket without being asked.

## Guardrails

- Do not write a tech proposal, specs, tasks or application code. If asked, point to
  `/espec:tech-proposal` and stop.
- Do not invent use cases, metrics or constraints. Ask, or mark them as open questions.
- Keep the ticket and `feature.md` identical. When they differ, show the difference and ask which wins.
- Do not paste `project.md` or `config.yaml` content into the document.
