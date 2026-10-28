# Engineering setup

How to put espec into a code repository so that every developer, QA engineer and reviewer gets the
Copilot commands, the formats and the validation, with nothing installed on their machines.

| | |
|---|---|
| Who | One developer with write access to the repository. Thirty minutes, once. |
| Needs | GitHub Copilot with Copilot Chat and agent mode. A `bash` shell (macOS, Linux, Git Bash) or PowerShell. Python is not needed. |
| Result | `espec/` and `.github/` in the repository. `/espec-` commands in Copilot Chat for the whole team. `espec validate` on every pull request that touches `espec/`. |

## What you get

| Path | What it is | Who maintains it |
|---|---|---|
| `espec/AGENTS.md` | The conventions every prompt reads first | The toolkit. `espec update` overwrites it. |
| `espec/project.md` | Your product, stack, teams and traps | You. Never overwritten. |
| `espec/config.yaml` | Ticket system, review tool, rules per phase | You. Never overwritten. |
| `espec/specs/` | The system as it is today, one folder per capability | The archive step only |
| `espec/changes/` | Work in flight, one folder per change | The commands |
| `espec/templates/` | Blank files the commands start from | The toolkit |
| `espec/bin/` | The validator and helpers, no toolkit needed | The toolkit |
| `.github/prompts/espec-*.prompt.md` | The seven Copilot commands | The toolkit |
| `.github/instructions/espec.instructions.md` | Format rules applied whenever Copilot edits `espec/**` | The toolkit |
| `.github/copilot-instructions.md` | Repository-wide rules, including for the Copilot coding agent | You, after init. Never overwritten. |
| `.github/workflows/espec-validate.yml` | CI: validation on pull requests that touch `espec/` | The toolkit |
| `.github/ISSUE_TEMPLATE/feature-definition.md` | New issue skeleton for GitHub Issues projects | You |
| `.diffcompass.json` | Code review tour settings for DiffCompass | You, after init |

## Step 1: clone the toolkit and run init

```bash
git clone https://github.com/Mindera/Enterprise-Spec-Driven-Development.git ~/espec
```

```bash
~/espec/bin/espec init /path/to/your/repo
```

On Windows:

```powershell
~\espec\bin\espec.ps1 init C:\path\to\your\repo
```

`init` copies [template/](../../template/) into the repository and never overwrites a file that
exists. It prints what it created and what it skipped. Run it from a branch, not from `main`.

## Step 2: fill in project.md

[`espec/project.md`](../../template/espec/project.md) is read by every command before it writes
anything. Keep it factual and short. The sections that change the quality of tech proposals most:

- **Stack and conventions: Tests.** Where tests live, how to run them, what counts as enough. The
  implementation step checks tasks only after running the verification they name, so it must know
  the commands.
- **Ticketing.** Jira Story or GitHub Issue, and where tech proposals are reviewed. Write the
  pull request rhythm you chose (see [the guides index](README.md#pull-requests-along-the-way)).
- **Things engineers always get wrong here.** Legacy corners, naming oddities, modules that look
  reusable and are not. Every line here saves a Question for Product or a wrong decision later.

Ask Copilot to draft it: "Read the repository and draft `espec/project.md` following its section
headings. Cite paths." Then correct it. A wrong `project.md` is worse than an empty one.

## Step 3: fill in config.yaml

[`espec/config.yaml`](../../template/espec/config.yaml):

| Key | Set it to |
|---|---|
| `tickets.system` | `jira` or `github` |
| `tickets.jira.*` | Base URL, project key, the issue type that carries feature definitions |
| `tickets.github.*` | `owner/repo` and the label the issue template applies |
| `review.tool` | `diffcompass`, the default, once the team has [DiffCompass](https://github.com/Mindera/diffcompass) installed; the implementation step then prints the review commands. `none` until then, or to turn that off. |
| `review.base` | The branch DiffCompass compares against before a pull request exists, usually `origin/main` |
| `archive.clean.prune_archived_changes_older_than_days` | `0` to keep every archived change. A number of days to have old archive folders listed for pruning. |
| `context` | Two sentences on the product, the stack, how to run tests. The prompts apply it; they do not paste it. |
| `rules.*` | One line each. The place for house rules: API versioning policy, mandatory security review for changes touching authentication, test coverage per group. |

## Step 4: commit and open a pull request

```bash
git checkout -b espec/init
git add espec .github .diffcompass.json
git commit -m "Add espec"
```

The pull request touches `espec/`, so `espec-validate` runs. With no changes and no main specs yet it
reports "Main specs: none yet" and passes. Merge it. Prompt files are read from the repository, so
everyone gets the commands on their next pull.

## Step 5: check the commands in Copilot Chat

1. Pull `main` and restart the IDE.
2. Open Copilot Chat, switch to **Agent** mode, and type `/espec-`. The seven commands appear:
   `/espec-feature-definition`, `/espec-tech-proposal`, `/espec-implementation`, `/espec-archive`,
   `/espec-archive-clean`, `/espec-inspect-feature-definition`, `/espec-inspect-tech-proposal`.
3. If they do not appear, check that prompt files are enabled in your IDE's or Terminal's Copilot
   settings and that `.github/prompts/` is in the prompt file locations. The Copilot documentation
   for your IDE or Terminal covers prompt file support; the prompt files are plain Markdown and can be
   pasted into the chat when they cannot be loaded.
4. Run `/espec-inspect-feature-definition` on the worked example to see a command end to end: paste
   the contents of
   [examples/changes/bill-142-invoice-csv-export/feature.md](../../examples/changes/bill-142-invoice-csv-export/feature.md).

The prompts run in agent mode because they read files, search the code and, during implementation,
run tests. In ask mode they can only talk.

## Step 6: let Copilot reach the ticket system (optional, recommended)

Without a connection, every command that takes a ticket key asks you to paste the description. With
one, `/espec-tech-proposal BILL-142` fetches it, and the inspect commands compare the live ticket with
`feature.md`.

- **Jira:** the Atlassian Remote MCP Server, enabled by an Atlassian admin and added to the MCP
  configuration of your IDE or Terminal. Each developer signs in once.
- **GitHub Issues:** the GitHub MCP server, or the `gh` CLI signed in on the machine. The prompts
  accept either.

Commit the MCP configuration file only if your organisation allows it; the server URL is not a secret, the
sign-in is per user. Check the current server URLs in the Atlassian and GitHub documentation; they
change more often than this toolkit.

## Step 7: the Copilot coding agent (GitHub Issues projects)

When issues are assigned to the Copilot coding agent, it reads
[`.github/copilot-instructions.md`](../../template/.github/copilot-instructions.md). The rule there
is: an issue whose body starts with `<!-- espec:feature-definition v1 -->` gets a tech proposal pull
request first, never an implementation. The coding agent does not load prompt files, so the same file
tells it to open and follow `.github/prompts/espec-tech-proposal.prompt.md` for such issues and
`.github/prompts/espec-implementation.prompt.md` once a change is approved. The file is yours after
init and `update` never touches it, so a repository initialised with an older toolkit adds those lines
by hand.

## Step 8: DiffCompass (optional)

[DiffCompass](https://github.com/Mindera/diffcompass) gives reviewers a guided tour of the diff.
Install it per the README, check with `diffcompass doctor`, and keep `review.tool: diffcompass`.
[`.diffcompass.json`](../../template/.diffcompass.json) already tells its agent to read the change
folder first and to flag drift from the tech proposal. Add project rules under
`analysis.instructions`. Without DiffCompass, set `review.tool: none` and follow
[the code review guide](07-code-review.md) by hand.

## Step 9: tell product

Send the product and design leads to [the product setup guide](setup-product.md). Their agents and
your repository share one format; neither side needs the other's tool.

## Updating later

New toolkit releases change the prompts, `AGENTS.md`, the templates and the validator. From a fresh
checkout of the toolkit:

```bash
git -C ~/espec pull
~/espec/bin/espec update /path/to/your/repo
```

`update` refreshes the managed files only and reports each one as created, updated or unchanged. It
never touches `copilot-instructions.md`, `project.md`, `config.yaml`, `specs/` or `changes/`. Commit
the result as its own pull request so the team can see which prompts changed. The toolkit version is
the single line in its [`VERSION`](../../VERSION) file; note it in the commit message.

Customisations do not go into `AGENTS.md` or the prompt files, because `update` overwrites them. They
go into `config.yaml` (rules and context), `project.md`, and `copilot-instructions.md`.

## Rolling it out to a team

1. Pilot with one change and one developer who has read [the guides](README.md). Pick a feature that
   is real but not urgent.
2. Walk the team through the worked example in [examples/](../../examples/README.md) in one session:
   the feature definition, the tech proposal, the inspection reports, the pull request description.
3. Make `/espec-inspect-feature-definition` the first thing a developer runs on any ticket. It costs
   a minute and sets the expectation on both sides.
4. Name who approves tech proposals and who confirms archive-clean verdicts. Put it in `project.md`.
5. Keep `project.md` alive. Every "the AI did not know that X" is a line for the traps section.

## Verify the setup

```bash
espec/bin/espec validate
```

- Prints "Main specs: none yet" (or your specs) and `0 failures`.
- `/espec-` shows seven commands in Copilot Chat in agent mode.
- The `espec-validate` workflow ran on the init pull request.
- `espec/project.md` has no placeholder text left and the Tests line names a command that works.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| `init and update run from the toolkit checkout` | You ran `espec/bin/espec init` from inside a project | Run `~/espec/bin/espec init <dir>` from the toolkit clone |
| `/espec-` shows nothing | Prompt files disabled, wrong location, or the IDE was not restarted | Enable prompt files, confirm `.github/prompts/` exists on the branch, restart |
| A command only talks and never edits a file | Ask mode | Switch Copilot Chat to Agent mode |
| `espec validate` fails on a fresh change | Template placeholders are still in `feature.md` | Expected. Fill the definition in, or keep the draft on a branch |
| The coding agent implemented an issue directly | `copilot-instructions.md` was replaced, or the issue body lacks the marker | Restore the rule; use the issue template so the marker is the first line |
| `update` reports every file as updated right after `init` | Line endings changed on checkout (Windows) | Add `* text=auto eol=lf` for `espec/**` and `.github/prompts/**` in `.gitattributes` |
