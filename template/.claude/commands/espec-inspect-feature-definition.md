---
description: "espec review · Inspect a feature definition: check a ticket or feature.md for missing information, hows, coverage gaps and untestable criteria. Read-only; prints a report and a ticket comment. Runs .github/prompts/espec-inspect-feature-definition.prompt.md (for GitHub Copilot CLI and Claude Code)."
argument-hint: "<Ticket key or URL, a pasted feature definition, or a change name under espec/changes/>"
disable-model-invocation: true
---

# /espec-inspect-feature-definition

GitHub Copilot CLI does not load prompt files, so this command runs the repository's prompt file
instead of copying it. The prompt file is the single source of the command.

This command is already loaded: do not call a `skill` tool for it. Read and follow the prompt file
directly.

1. Read `.github/prompts/espec-inspect-feature-definition.prompt.md` from the repository root and follow it exactly as written.
   Its links are relative to `.github/prompts/`, so `../../espec/AGENTS.md` means `espec/AGENTS.md`.
   If the file is missing, say so and stop: run `espec update` from the toolkit to restore it.
2. The prompt's input is `source`. Its value is everything typed after `/espec-inspect-feature-definition`, exactly as typed.
3. If nothing was typed, ask for `source` with the hint from the prompt's `Input:` line before you
   start its steps, as the IDE does.
4. When the prompt names another command, written `/espec:<name>` or `/espec-<name>`, its file is
   `.github/prompts/espec-<name>.prompt.md` and the user types it as `/espec-<name>`.
