---
description: "espec review · Start a DiffCompass tour of an implementation pull request or branch, primed with its change folder. Read-only; launches the tour and prints what to check first. Runs .github/prompts/espec-review.prompt.md (for GitHub Copilot CLI and Claude Code)."
argument-hint: "<Pull request number or URL, branch or change name (leave empty for the current branch). In a spec hub: code pull request URL, then the change name>"
disable-model-invocation: true
---

# /espec-review

GitHub Copilot CLI does not load prompt files, so this command runs the repository's prompt file
instead of copying it. The prompt file is the single source of the command.

This command is already loaded: do not call a `skill` tool for it. Read and follow the prompt file
directly.

1. Read `.github/prompts/espec-review.prompt.md` from the repository root and follow it exactly as written.
   Its links are relative to `.github/prompts/`, so `../../espec/AGENTS.md` means `espec/AGENTS.md`.
   If the file is missing, say so and stop: run `espec update` from the toolkit to restore it.
2. The prompt's input is `target`. Its value is everything typed after `/espec-review`, exactly as typed.
3. If nothing was typed, `target` is empty, which the prompt allows: apply its own rule for an
   empty input.
4. When the prompt names another command, written `/espec:<name>` or `/espec-<name>`, its file is
   `.github/prompts/espec-<name>.prompt.md` and the user types it as `/espec-<name>`.
