# Copilot instructions

This repository uses **espec** for spec-driven development. Specifications live under `espec/`.
Read `espec/AGENTS.md` for the conventions and `espec/project.md` for project context.

## Workflow

1. **Feature definition** (what and why) arrives as a ticket and is stored in
   `espec/changes/<change-name>/feature.md`.
2. **Tech proposal** (how) is written by engineering: `tech-proposal.md`, delta specs, `tasks.md`.
3. **Implementation** follows the tasks and checks them off as they are verified.
4. **Archive** folds the deltas into `espec/specs/` and moves the change to `espec/changes/archive/`.

Commands in Copilot Chat: `/espec-ai-assisted-feature-definition`, `/espec-tech-proposal`,
`/espec-implementation`, `/espec-archive`, `/espec-archive-clean`.

## Rules that always apply

- An issue or ticket whose body starts with `<!-- espec:feature-definition v1 -->` is a feature
  definition. Do not implement it directly. Produce a tech proposal first, as a pull request that adds
  `espec/changes/<change-name>/`, and wait for approval.
- Do not change behaviour that is not described in an approved change under `espec/changes/`.
  When a request needs a behaviour change, say so and point to `/espec-tech-proposal`.
- Never edit `espec/specs/` directly. Main specs change only through archive and archive-clean.
- Never reduce the scope of a task silently. Surface it and ask.
- Scenarios in specs use `#### Scenario:` with four hashes and GIVEN / WHEN / THEN / AND bullets.
