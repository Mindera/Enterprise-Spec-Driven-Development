---
applyTo: "espec/**"
---

# Editing files under espec/

- Follow the formats in `espec/AGENTS.md`: feature definition, tech proposal, delta spec, main spec,
  tasks and `.espec.yaml`.
- `feature.md` holds product language only. A how goes under `## Forced technical notes` as `FT-n`
  with the ⚠️ marker, and nowhere else.
- Requirements: `### Requirement: <name>`, SHALL or MUST, unique names under 50 characters.
- Scenarios: `#### Scenario: <name>` with exactly four `#`, then `- **GIVEN**` (optional),
  `- **WHEN**`, `- **THEN**`, `- **AND**` bullets. Every requirement has at least one scenario.
- Delta files use `## ADDED Requirements`, `## MODIFIED Requirements` (full requirement, not a diff),
  `## REMOVED Requirements` (with Reason and Migration) and `## RENAMED Requirements` (FROM / TO).
- MODIFIED and REMOVED requirements carry `<!-- espec:base <hash> -->` under the heading. Never write
  or edit it by hand: run `espec/bin/espec stamp <change-name>`. Never copy it into `espec/specs/`.
- Tasks: `- [ ] N.M description and verify <how>`. Only `[x]` means done.
- Never edit `espec/specs/` by hand during a change; edit the change's delta instead.
- Keep `project.md` and `config.yaml` content out of the artifacts; apply it, do not paste it.
