---
description: "espec design context · Read the Figma frames linked from a feature and write the UI design section of feature.md from them, so the tech proposal works from the real design. Runs .github/prompts/espec-design-context.prompt.md (for GitHub Copilot CLI and Claude Code)."
argument-hint: "<Change name, ticket key, or one or more Figma frame URLs>"
disable-model-invocation: true
---

# /espec-design-context

GitHub Copilot CLI does not load prompt files, so this command runs the repository's prompt file
instead of copying it. The prompt file is the single source of the command.

This command is already loaded: do not call a `skill` tool for it. Read and follow the prompt file
directly.

1. Read `.github/prompts/espec-design-context.prompt.md` from the repository root and follow it exactly as written.
   Its links are relative to `.github/prompts/`, so `../../espec/AGENTS.md` means `espec/AGENTS.md`.
   If the file is missing, say so and stop: run `espec update` from the toolkit to restore it.
2. The prompt's input is `source`. Its value is everything typed after `/espec-design-context`, exactly as typed.
3. If nothing was typed, ask for `source` with the hint from the prompt's `Input:` line before you
   start its steps, as the IDE does.
4. When the prompt names another command, written `/espec:<name>` or `/espec-<name>`, its file is
   `.github/prompts/espec-<name>.prompt.md` and the user types it as `/espec-<name>`.
