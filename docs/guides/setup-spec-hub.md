# Spec hub setup

How to run espec when the code of one product lives in several repositories that cannot hold its
specs: a **spec hub** repository keeps `espec/`, and the code repositories are cloned beside it under
`repos/`. It is opt-in. The default, and our recommendation, is `espec/` next to the code
([FAQ](../faq.md#can-the-specs-live-in-a-separate-repository-from-the-code)).

| | |
|---|---|
| Who | One developer with write access to a new or existing spec repository, and read access to every code repository. An hour, once. |
| Needs | Everything in the [engineering setup](setup-engineering.md), plus `git` on the machine of everyone who runs the commands. |
| Result | A hub with `espec/`, the code repositories cloned under `repos/`, the commands reading code across them, one change folder per ticket for all repositories. |

## When to use it, and when not

Use a hub when one feature regularly needs code in several repositories (a shared library and the
apps that consume it, a backend and its clients), product wants one feature definition and one
approval per ticket, and the repositories cannot be merged or each hold the specs.

Do not use a hub when:

- One repository owns the behaviour: put `espec/` there.
- The repositories ship independently and features rarely span them: run espec in each
  ([FAQ](../faq.md#one-feature-several-repositories)).
- The team relies on the Copilot coding agent or on a reviewer that runs inside one repository:
  neither can see the hub and `repos/` together.

## Step 1: init the hub

Follow steps 1 to 6 of the [engineering setup](setup-engineering.md) in the spec repository. Then add
`repos/` to its `.gitignore`, so code never lands in the hub:

```gitignore
/repos/
```

## Step 2: list the code repositories

Add them to `repos:` in [`espec/config.yaml`](../../template/espec/config.yaml). `name` is the folder
under `repos/` and the prefix in tasks and tech proposals; `url` is anything `git clone` accepts;
`branch` is optional and defaults to the remote's default branch.

```yaml
repos:
  - name: shared-lib
    url: https://github.com/acme/shared-lib.git
    branch: main
  - name: web-app
    url: https://github.com/acme/web-app.git
```

Then clone them:

```bash
espec/bin/espec repos
```

Run it again whenever the code may have moved on. It fetches every clone and fast-forwards those that
are clean and on the configured branch; one with local changes or on another branch is only fetched,
and the command says why. `--no-pull` leaves existing clones alone.

## Step 3: add house rules

The conventions in the **Spec hub** section of `espec/AGENTS.md` apply as soon as `repos:` is not
empty: `### Repo: <name>` sub-sections in the tech proposal, `[<name>]` prefixes on task groups, one
code pull request per repository. Add what is specific to your repositories under `rules:` in
`config.yaml`, for example:

```yaml
rules:
  tech-proposal:
    - Order the Repo sub-sections shared-lib first. A shared-lib change states the version the apps move to.
  tasks:
    - "[shared-lib] groups come first, because both apps consume the release."
```

Describe each repository in `project.md`: what it owns, its stack, how to run its tests.

## Step 4: set up each code repository

- Copy `espec/templates/code-repo.diffcompass.json` from the hub to `.diffcompass.json` at the root
  of every code repository, so the review tour knows the specs live elsewhere.
- Every code pull request description links the hub change folder
  (`<hub URL>/tree/main/espec/changes/<change-name>`). The implementation step writes that block in
  `pull-request.md`.

## How the commands differ

| Command | In a spec hub |
|---|---|
| `/espec:assess`, `/espec:tech-proposal` | Read the code under `repos/<name>` and cite those paths. The proposal gets one `### Repo: <name>` sub-section per repository in Context, Approach, Architecture and Test strategy. |
| `/espec:implementation` | Works in `repos/<name>` on a branch named after the ticket key, one pull request per repository. Checks off `tasks.md` and writes `pull-request.md` in the hub. |
| `/espec:review` | Takes the code pull request URL and the change name, reads the change from the hub and runs the tour from `repos/<name>`. |
| `/espec:archive` | Runs after every code pull request of the change is merged. |

## Limitations

- The Copilot coding agent and pull request reviewers that run inside one repository cannot see the
  hub or `repos/`. Run the espec commands locally from the hub.
- Each step that changes both specs and code means two pull requests, one in the hub and one in a
  code repository, kept in step by hand.
- `espec validate` checks the formats, not the hub conventions: it does not check `[<name>]` task
  prefixes or `### Repo:` sub-sections.
- Search tools skip gitignored folders, so a search from the hub root may miss `repos/`. Search with
  an explicit `repos/<name>/` path.
