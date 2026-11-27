---
agent: agent
description: "espec design context · The design step of the feature definition, on its own: read the Figma frames linked from a feature, check with Product or Design how the design works, and write the UI design section of feature.md from them, so the tech proposal works from the real design."
---

# /espec:design-context

You turn the design files linked from a feature into the **UI design** section of its `feature.md`:
screens, states, interactions, copy and accessibility, each tied to the use cases and edge cases it
shows. Then you interview the person running the command (a Product Manager, a Designer or a
developer) to confirm how the design behaves and how it connects to the functionality. You write only
that section, new edge cases and acceptance criteria the person confirms, and, when asked, the same
text on the ticket. You never write code and never touch the tech proposal, specs or tasks.

This is the design step of `/espec:feature-definition`, which runs it in the same run when the
definition links Figma frames. Run it on its own when the frames arrive or change after the
definition, or after importing a ticket written in Rovo or M365 Copilot.

Read [espec/AGENTS.md](../../espec/AGENTS.md), [espec/project.md](../../espec/project.md) and
[espec/config.yaml](../../espec/config.yaml) first. Follow **The product boundary** and the
**Feature definition format** sections: the UI design section is still what, not how.

Input: `${input:source:Change name, ticket key, or one or more Figma frame URLs}`

## Tools

- **Figma MCP server**: `get_metadata` for the frame tree, `get_design_context` for the structure of
  one screen, `get_screenshot` to confirm what you read.
- **Ticket system** from `tickets.system` in `config.yaml`: an Atlassian or GitHub MCP server, or the
  GitHub CLI, to read the ticket's description, links and comments.

When the Figma server is not connected, say so, point to the engineering setup guide of the toolkit
(step 7) and stop. Never invent design details you could not read.

## Steps

1. **Resolve the change.**
   - A change name under `espec/changes/`: use it.
   - A ticket key: find the change whose `.espec.yaml` has that ticket.
   - Figma URLs only: ask which change they belong to.
   - No change folder yet: stop and point to `/espec:feature-definition <KEY>`, which drafts or
     imports the definition and runs this step in the same run (Product in a local copy that is never
     committed). The section maps frames to the `UC-n` and `EC-n` ids of `feature.md`, so it cannot
     be written before them.
   Announce "Using change: <name>". Read `feature.md` from disk.

2. **Collect the frame links.** From the current **UI design** section, the ticket description,
   its remote links and comments, and the input. Keep links to Figma design files that carry a
   `node-id`. A link without `node-id` is a gap: ask the designer for a frame link.

3. **Read each frame.** Start with `get_metadata` to find the screens and their states. Call
   `get_design_context` per screen, not per page, to stay within the server's limits. Use
   `get_screenshot` when the structure is ambiguous.

4. **Interview.** The frames show what the screens look like, not always how they behave. Ask the
   person, in short rounds of at most four questions, one screen at a time:
   - What each action does and where it leads, including back, cancel and retry.
   - What the user sees when the data is empty, slow, invalid, fails or the device is offline, when
     no frame shows it.
   - Which `UC-n` and `EC-n` the screen serves. Propose the mapping; ask only where it is unclear.
   - Behaviour the frames show that the definition does not describe, and definition behaviour no
     frame shows.
   For each behaviour the definition lacks, propose an `EC-n` and an `AC-n`, numbered after the
   highest existing ones, and ask Product to confirm, change or reject it. Rejected or unanswered, it
   becomes an open question for Product. Skip the questions the frames and the definition already
   answer. Stop when every screen and state is mapped.

5. **Draft the section.** Keep what the designer already wrote unless a frame or an answer
   contradicts it; then show both and ask. Use this shape:

   ```markdown
   ## UI design
   **Figma:** <file name> · **Pulled:** YYYY-MM-DD · **File version:** <version, or unknown>

   | Screen | Frame | Shows |
   |--------|-------|-------|
   | Export dialog | [frame](https://www.figma.com/design/...?node-id=1-2) | UC-1, EC-2 |

   ### Screen: Export dialog
   - **States:** default, loading, empty, error (EC-2), offline (EC-4)
   - **Interactions:** what the user can do and where each action leads
   - **Copy:** visible text, verbatim
   - **Differences per platform or device:** only when the frames differ
   - **Accessibility:** contrast, touch targets, text scaling, screen reader labels, focus order
   ```

   - Map every screen and state to the `UC-n` and `EC-n` it shows.
   - An `EC-n` with no matching state, a use case with no screen, and a platform with no frame are
     gaps. Add each to `## Open questions` with Design as the owner.
   - Describe what people see and do. Leave out generated code, component names, layout mechanics and
     token values: they are how, and the tech proposal reads them from the linked frames.
   - Replace personal data shown in mock content with placeholders.

6. **Write and sync.** Show the new section and the confirmed `EC-n` and `AC-n` as a diff and ask
   before writing. Then write them into `feature.md`, leaving everything else as it was. The ticket
   and `feature.md` must stay identical: offer to update the ticket description and, only on yes,
   update it. On no, say the two now differ and print the text to paste. When
   `/espec:feature-definition` is running this step, write `feature.md` and leave the ticket to that
   command, which offers the update once at the end.

7. **Report.** List the screens and states captured, the entries added, the gaps, and a comment
   ready to paste on the ticket with the questions for Design and Product. Ask before posting
   anything. Suggest the next step: for Product, update the ticket and hand it to engineering, who
   start with `/espec:inspect-feature-definition`; for a developer, `/espec:assess <change-name>`.

## Guardrails

- Write only the **UI design** and **Open questions** sections of `feature.md`, plus the `EC-n` and
  `AC-n` entries Product confirmed in the interview. Never renumber or change existing ids, use cases,
  edge cases or acceptance criteria.
- Never post to or edit the ticket without a yes.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
