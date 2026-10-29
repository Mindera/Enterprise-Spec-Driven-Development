# Contributing to the espec toolkit

Instructions for anyone changing this repository: humans and AI assistants alike. This file is the
single source of truth. It is plain Markdown and does not depend on any particular AI tool:
GitHub Copilot, Claude, Codex, Cursor, Gemini, Rovo, M365 Copilot or any other assistant must follow
it. Tool-specific files ([`CLAUDE.md`](CLAUDE.md), [`GEMINI.md`](GEMINI.md),
[`.github/copilot-instructions.md`](.github/copilot-instructions.md)) only point here; never put
rules in them.

This file is about the toolkit itself. The conventions a target repository follows live in
[`template/espec/AGENTS.md`](template/espec/AGENTS.md), which `espec init` copies.

## Versioning

The toolkit version is the single line in [`VERSION`](VERSION), written `X.Y.Z` and shown as
`vX.Y.Z`.

**Every change bumps Z.** Any change to what the toolkit generates or how it generates it (templates,
prompts, product agents, ticket templates, the CLI, the validator, docs or examples) must, in the
same commit or pull request:

1. Increase Z by one in `VERSION` (`1.0.0` → `1.0.1`). X and Y change only when a maintainer asks
   for it; when they do, Z resets to `0`.
2. Update the version badge and the "current version" line in [`README.md`](README.md) to the same
   `vX.Y.Z`.
3. Add a `## vX.Y.Z (YYYY-MM-DD)` entry at the top of [`CHANGELOG.md`](CHANGELOG.md) saying what changed
   for the people who run the toolkit. Mark anything a project must do after `espec update` with
   **Action**.

Bump once per pull request, not once per commit. CI enforces all three rules
(`scripts/ci/check-version.py`): the README must match `VERSION`, the changelog must have an entry for
it, and a pull request that changes any file must raise `VERSION` above the base branch. Changes reach
`main` only through pull requests; the check cannot see a direct push.

When a new version reaches `main`, the release workflow (`.github/workflows/release.yml`) tags it
`vX.Y.Z` and publishes its changelog entry as the release notes. Projects pin these tags.

## House rules

- No em dashes anywhere. Use a comma, a colon or parentheses.
- Relative Markdown links must resolve.
- Keep the README simple and the prompts shorter than the documents they produce.
- Run the checks before opening a pull request:

```bash
python3 scripts/ci/check-docs.py
python3 scripts/ci/check-version.py origin/main
bash scripts/ci/smoke-bash.sh
pwsh scripts/ci/smoke-pwsh.ps1
```

- The bash and PowerShell CLIs behave the same. A change to one is made to the other in the same pull
  request, and both smoke tests cover it.

## License

Sustainable Use License 1.0, see [`LICENSE.md`](LICENSE.md). Contributions are accepted under the
same license.
