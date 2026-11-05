# Changelog

Every version of the toolkit, newest first. Each pull request adds its entry under the version it
bumps to (see [AGENTS.md](AGENTS.md)). When a version is merged to `main`, the release workflow tags it
`vX.Y.Z` and publishes this section as the release notes.

To move a project to a version, check it out in the toolkit clone and run `espec update`:

```bash
git -C ~/espec fetch --tags && git -C ~/espec checkout v1.0.15
~/espec/bin/espec update /path/to/your/repo
```

Entries marked **Action** need something done in projects that update.

## v1.0.15 (2026-11-05)

Fixes:

- `/espec:archive` step 5 no longer reports a false conflict after applying a REMOVED or RENAMED
  delta. It now checks the synced main spec against the plan from step 3 instead of re-running the
  conflict checks, where a missing REMOVED heading is the expected result. `AGENTS.md` and the
  archive guide say the same.

CI:

- `espec-validate.yml` runs on every pull request, not only those touching `espec/**`, so it can be a
  required status check. It also checks that `espec/config.yaml` parses as YAML.
- **Action:** run `espec update`, then make `espec validate` a required check on the default branch.

Spec hub (opt-in):

- `repos:` in `config.yaml` lists code repositories for a spec hub: specs in one repository, code in
  several. `espec repos [--no-pull]` (bash and PowerShell) clones them into `repos/<name>` or fetches
  and fast-forwards clean clones on the configured branch, and warns when `repos/` is not gitignored.
- `AGENTS.md` has a **Spec hub** section: `### Repo: <name>` sub-sections in the tech proposal,
  `[<name>]` task group prefixes, one code pull request per repository, review and archive rules.
- `/espec:review` accepts a code pull request URL and a change name, finds the change in the hub and
  runs the tour from `repos/<name>`. `espec/templates/code-repo.diffcompass.json` is the
  `.diffcompass.json` for the code repositories.
- New guide: [Spec hub setup](docs/guides/setup-spec-hub.md). The FAQ now presents the hub as the
  fallback when specs cannot live next to the code.
- **Action (optional):** to use a hub, copy the `repos:` block from `template/espec/config.yaml` into
  your `config.yaml`, since `update` leaves that file alone.

Commands:

- New `/espec:design-context`: reads the Figma frames linked from a feature through the Figma MCP
  server and writes the **UI design** section of `feature.md` (screens and states mapped to `UC-n`
  and `EC-n`, interactions, copy, accessibility). Asks before writing and before updating the ticket.
- **Action:** run `espec update` to get the new prompt; connect the Figma MCP server to use it.

Templates (init only, copy them by hand into existing projects):

- `.markdownlint-cli2.yaml`: markdownlint settings that skip the managed espec files.
- `.github/PULL_REQUEST_TEMPLATE/espec-spec-change.md`: for tech proposal and archive pull requests.

Docs:

- Engineering setup: an example `.github/mcp.json` (Atlassian, Figma), more Common problems rows
  (MCP policy, Figma links and limits, stale `repos/`), and how to bring new lines into the files that
  are yours after init.

## v1.0.14 (2026-11-05)

Implementation:

- `/espec:implementation` runs a security validation on mobile apps before it writes `pull-request.md`,
  with [AI Mobile Security Assessment](https://github.com/Mindera/AI-Mobile-Security-Assessment): a
  static assessment of Android, iOS and Kotlin Multiplatform code against OWASP MASVS. The tool's
  repository is private, so the step runs only when the signed-in GitHub user can read it, and is
  skipped with a note otherwise. A finding in a file the change touches becomes a task in a
  `## Security` group of `tasks.md` and is fixed before the pull request; pre-existing findings are
  reported. Findings left put "⚠️ Security findings: fix before merge" on the pull request with one row
  per finding and the report saved as `security-report.md` in the change folder. No findings: one line,
  "Security validation passed". `/espec:review` names the findings the diff does not fix, and
  `.diffcompass.json` tells the tour to flag them.
- New `security` block in `config.yaml`: `tool` (`mobile-security-assessment` or `none`), `repo` and
  `platforms` (empty means detected from the repository).
- `pull-request.md` has a **Security validation** section: passed, skipped with the reason, or the
  alert. `espec validate` does not require it, so existing changes keep validating.
- **Action:** after `espec update`, add the `security` block from
  [template/espec/config.yaml](template/espec/config.yaml) to your `espec/config.yaml` (`update` never
  touches it) and the new instruction from [template/.diffcompass.json](template/.diffcompass.json) to
  yours. Without the block the implementation step skips the validation.

## v1.0.13 (2026-11-05)

Docs:

- The README has a **Code review** section with a demo of the DiffCompass tour: `/espec:review`
  launches it primed with the change folder through `.diffcompass.json`, findings flag spec drift,
  and approval stays in the pull request. No change to the toolkit or to projects that update.

## v1.0.12 (2026-10-30)

CLI:

- `espec validate` now checks the verdict on each forced technical note, not just that it is named. Every
  `FT-n` in `feature.md` needs a row in the tech proposal's Forced technical notes review whose Verdict is
  **Accepted** or **Overridden**, and an Overridden row needs a Reason. A missing row, a missing verdict
  and an override without a reason each fail with the `FT-n` named. Same behaviour in bash and
  PowerShell, covered by both smoke tests.
- **Action:** run `espec update`, then `espec validate`. A proposal that mentions an `FT-n` outside the
  review table, or leaves its verdict or override reason empty, now fails until the row is completed.

## v1.0.11 (2026-10-30)

Formats:

- "Design" on its own now means the technical design in `tech-proposal.md`. The UI side is named UI
  design everywhere: the feature definition section **Experience and design** is now **UI design**, the
  header field **Design:** is **UI design:**, and coverage reports say "UI design item".
- The Design Notes agent and prompt are now **espec UI Design**: `product-ai/rovo/ui-design-agent.md`,
  `product-ai/m365-copilot/ui-design-agent.md` and `product-ai/prompts/ui-design.prompt.md`.
- **Action:** rename the `## Experience and design` heading to `## UI design` in the ticket template
  in Jira or GitHub and in open `feature.md` files. Rovo and M365 admins paste the new instructions
  into both agents and rename the Design Notes agent to `espec UI Design`.

## v1.0.10 (2026-10-30)

Flows:

- Implementation starts in a new chat or session. `/espec:tech-proposal` ends by telling the developer
  to open one, and `/espec:implementation` stops when the conversation already holds earlier work on
  the change (a proposal, an inspection, a design discussion) and asks for a new session, continuing
  only when the user insists. The approved files are the only input, so nothing said and not written
  down steers the code.

## v1.0.9 (2026-10-29)

Flows:

- Bug fixes have a path: `espec new <name> --kind bug` starts from a bug template (why, expected versus
  actual, steps to reproduce, acceptance criteria). The tech proposal for a bug is short, its first task
  reproduces the bug in a failing test, and it needs no delta when the main specs already describe the
  correct behaviour.
- Re-approval: changing an Approved tech proposal, during the proposal or the implementation, sets its
  status line back to In review, so the implementation gate stops until the reviewer approves again.
- Technical assessment: re-run `/espec:assess` after further discovery; the new comment supersedes the
  old one and records the move to Ready for tech proposal.
- Archive without syncing asks for a reason and records it in `.espec.yaml` as `archived_without_sync`.
- FAQ: why the specs live in the code repository, and how to run espec when they cannot.

Validator and CLI (bash and PowerShell):

- Delta base stamps. Every MODIFIED and REMOVED requirement records the version of the main spec it
  was written against, `<!-- espec:base <hash> -->`, written by the new `espec stamp <change>` command.
  `espec validate` fails when that requirement has changed in the main spec since, so two changes
  editing the same requirement can no longer overwrite each other at archive. **Action:** run
  `espec/bin/espec stamp <change>` once for every active change with MODIFIED or REMOVED requirements.
- `espec validate` checks every delta against the main spec as it is today: MODIFIED, REMOVED and
  RENAMED headings must exist, an ADDED heading must not exist with different content.
- Main specs nested more than one folder deep are validated.
- `init` and `update` copy the licence to `espec/LICENSE.md` and the toolkit version to
  `espec/.toolkit-version`; `espec version` prints it and `update` shows the version it moves from and to.
- `.espec.yaml` takes `kind: feature | bug`.

CI:

- The `espec-validate` workflow fails a pull request that changes `espec/specs/` without archiving a
  change or adding a clean-up report in the same pull request.
- The toolkit repository tags and releases every version merged to `main`, from this file.
- `check-version.py` requires a changelog entry for the version in `VERSION`.

Docs:

- The technical assessment guide and the guides index use `/espec:assess`.
- Product side: the ticket templates and the product setup guide include the assessment statuses.
- README transcript and tagline fixed; the phase table shows the assessment.
- Setup guide: CODEOWNERS for tech proposal approval and main specs, and branch protection.
- Prompt files use `agent: agent` front matter in place of the old `mode: agent`.

## v1.0.8 (2026-10-28)

- `/espec:tech-proposal` and `/espec:implementation` end with a coverage report: how much of the feature
  definition the proposal covers, and how much of the proposal the implementation delivers.

## v1.0.7 (2026-10-28)

- Every `/espec:*` command ends with a usage line showing what the run cost, when the tool reports it.

## v1.0.6 (2026-10-28)

- `/espec:review` starts a DiffCompass tour of an implementation pull request or branch, primed with
  its change folder.

## v1.0.5 (2026-10-28)

- Docs refer to "your IDE or Terminal" instead of naming specific IDEs.

## v1.0.4 (2026-10-28)

- Licence changed from GPL-3.0 to the Sustainable Use License 1.0.

## v1.0.3 (2026-10-28)

- `/espec:assess`: a read-only technical assessment of the feature definition against the code before
  the tech proposal.
- Step-by-step guides in `docs/guides/`.
- `/espec:implementation` requires an Approved tech proposal; `espec validate` checks tech proposals.
- A `cancelled` status for changes that will not ship.

## v1.0.2 (2026-10-27)

- CI fixes: no em dashes, checkout on Node 24, pinned Ubuntu runner.

## v1.0.1 (2026-10-27)

- DiffCompass as the code review tool for implementation pull requests.

## v1.0.0 (2026-10-27)

- First versioned release: the four phases, the inspect commands, the product pack, the CLI and
  validator, the worked example.
