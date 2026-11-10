---
agent: agent
description: "espec design context · Read the Figma frames linked from a feature and write the UI design section of feature.md from them, so the tech proposal works from the real design."
---

# /espec:design-context

You turn the design files linked from a feature into the **UI design** section of its `feature.md`:
screens, states, interactions, copy and accessibility, each tied to the use cases and edge cases it
shows. You write only that section and, when asked, the same section on the ticket. You never write
code and never touch the other sections, the tech proposal, specs or tasks.

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
   - No change folder yet: stop and tell the user to import the ticket with
     `/espec:feature-definition <KEY>` first. The section maps frames to the `UC-n` and `EC-n` ids
     of `feature.md`, so it cannot be written before them.
   Announce "Using change: <name>". Read `feature.md` from disk.

2. **Collect the frame links.** From the current **UI design** section, the ticket description,
   its remote links and comments, and the input. Keep links to Figma design files that carry a
   `node-id`. A link without `node-id` is a gap: ask the designer for a frame link.

3. **Read each frame.** Start with `get_metadata` to find the screens and their states. Call
   `get_design_context` per screen, not per page, to stay within the server's limits. Use
   `get_screenshot` when the structure is ambiguous.

4. **Draft the section.** Keep what the designer already wrote unless a frame contradicts it; then
   show both and ask. Use this shape:

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

5. **Write and sync.** Show the new section as a diff against the current one and ask before
   writing. Then write it into `feature.md`, leaving every other section as it was. The ticket and
   `feature.md` must stay identical: offer to update the UI design section of the ticket description
   and, only on yes, update it. On no, say the two now differ and print the section to paste.

6. **Report.** List the screens and states captured, the gaps, and a comment ready to paste on the
   ticket with the questions for Design. Ask before posting anything. Suggest the next step:
   `/espec:assess <change-name>` or `/espec:tech-proposal <change-name>`.

## Guardrails

- Write only the **UI design** and **Open questions** sections of `feature.md`. Never change ids,
  use cases, edge cases or acceptance criteria; when the design shows behaviour the definition does
  not describe, list it as a question for Product instead.
- Never post to or edit the ticket without a yes.
- End the reply with the usage line from the **Usage report** section of AGENTS.md, when
  `usage.report` in config.yaml asks for it.
