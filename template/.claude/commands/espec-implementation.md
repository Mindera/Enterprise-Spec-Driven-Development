---
description: "espec phase 3 · Implementation: implement the tasks of an approved change, following its tech proposal and specs, check tasks off as they are verified, and write a pull request description that reads without the code. Runs .github/prompts/espec-implementation.prompt.md (for GitHub Copilot CLI and Claude Code)."
argument-hint: "<Change name (leave empty to pick from the active changes)>"
disable-model-invocation: true
---

# /espec-implementation

GitHub Copilot CLI does not load prompt files, so this command runs the repository's prompt file
instead of copying it. The prompt file is the single source of the command.

This command is already loaded: do not call a `skill` tool for it. Read and follow the prompt file
directly.

1. Read `.github/prompts/espec-implementation.prompt.md` from the repository root and follow it exactly as written.
   Its links are relative to `.github/prompts/`, so `../../espec/AGENTS.md` means `espec/AGENTS.md`.
   If the file is missing, say so and stop: run `espec update` from the toolkit to restore it.
2. The prompt's input is `change`. Its value is everything typed after `/espec-implementation`, exactly as typed.
3. If nothing was typed, `change` is empty, which the prompt allows: apply its own rule for an
   empty input.
4. When the prompt names another command, written `/espec:<name>` or `/espec-<name>`, its file is
   `.github/prompts/espec-<name>.prompt.md` and the user types it as `/espec-<name>`.
