#!/usr/bin/env bash
# Smoke test for the bash CLI: init, new, validate, list, update, and the worked example.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

bash -n "$ROOT/template/espec/bin/espec"

"$ROOT/bin/espec" init "$WORK" >/dev/null
test -x "$WORK/espec/bin/espec"
test -f "$WORK/.github/workflows/espec-validate.yml"
python3 -m json.tool "$WORK/.diffcompass.json" >/dev/null
python3 -m json.tool "$WORK/espec/templates/code-repo.diffcompass.json" >/dev/null
[ "$(ls "$WORK/.github/prompts" | wc -l)" -eq 10 ] || { echo "expected 10 prompt files"; exit 1; }
# Every prompt file has a command wrapper for GitHub Copilot CLI and Claude Code.
for p in "$WORK"/.github/prompts/espec-*.prompt.md; do
  n=$(basename "$p" .prompt.md)
  grep -q "^disable-model-invocation: true$" "$WORK/.claude/commands/$n.md" \
    || { echo "expected .claude/commands/$n.md with disable-model-invocation"; exit 1; }
done
[ "$(ls "$WORK/.claude/commands" | wc -l)" -eq 10 ] || { echo "expected 10 command wrappers"; exit 1; }

cd "$WORK"

# A fresh change still holds template placeholders, so validate must fail on it.
./espec/bin/espec new proj-1-smoke --ticket PROJ-1 --title "Smoke" >/dev/null
if ./espec/bin/espec validate proj-1-smoke >/dev/null; then
  echo "expected validate to fail on a blank change"; exit 1
fi
rm -rf espec/changes/proj-1-smoke

# init records the toolkit version and licence in the project.
cmp -s "$ROOT/VERSION" espec/.toolkit-version || { echo "init did not record the toolkit version"; exit 1; }
cmp -s "$ROOT/LICENSE.md" espec/LICENSE.md || { echo "init did not copy the licence"; exit 1; }
./espec/bin/espec version | grep "v$(cat "$ROOT/VERSION")" >/dev/null

# A bug change starts from the bug template.
./espec/bin/espec new proj-2-bug --kind bug >/dev/null
grep -q '^# Bug:' espec/changes/proj-2-bug/feature.md
grep -q '^kind: bug' espec/changes/proj-2-bug/.espec.yaml
rm -rf espec/changes/proj-2-bug

# The worked bug report validates as a bug: steps to reproduce, no use cases or edge cases.
cp -R "$ROOT/examples/changes/bill-171-fix-jpy-amounts-in-export" espec/changes/
./espec/bin/espec validate bill-171-fix-jpy-amounts-in-export >/dev/null
# The same report is not a valid feature definition: without kind: bug, validate asks for use cases.
sed 's/^kind: bug$/kind: feature/' espec/changes/bill-171-fix-jpy-amounts-in-export/.espec.yaml > espec.yaml.new
mv espec.yaml.new espec/changes/bill-171-fix-jpy-amounts-in-export/.espec.yaml
if ./espec/bin/espec validate bill-171-fix-jpy-amounts-in-export >/dev/null; then
  echo "expected validate to ask a feature for use cases and edge cases"; exit 1
fi
# In the small lane the same text is a valid short definition: Why, What, Out of scope, Acceptance criteria.
echo "lane: small" >> espec/changes/bill-171-fix-jpy-amounts-in-export/.espec.yaml
./espec/bin/espec validate bill-171-fix-jpy-amounts-in-export >/dev/null
rm -rf espec/changes/bill-171-fix-jpy-amounts-in-export

# The small lane starts from the short definition template.
./espec/bin/espec new proj-3-small --lane small >/dev/null
grep -q '^lane: small' espec/changes/proj-3-small/.espec.yaml
if grep -q '^## Use cases' espec/changes/proj-3-small/feature.md; then
  echo "expected the short definition in the small lane"; exit 1
fi
rm -rf espec/changes/proj-3-small

# The urgent lane names who declared it, holds only .espec.yaml until the paper is written,
# and fails validation once the paper is overdue.
if ./espec/bin/espec new proj-4-urgent --lane urgent >/dev/null 2>&1; then
  echo "expected --lane urgent to need --declared-by"; exit 1
fi
./espec/bin/espec new proj-4-urgent --kind bug --lane urgent --declared-by "Priya Raghavan" >/dev/null
[ "$(ls -A espec/changes/proj-4-urgent)" = .espec.yaml ] || { echo "expected only .espec.yaml in an urgent change"; exit 1; }
grep -Eq '^catch_up_by: [0-9]{4}-[0-9]{2}-[0-9]{2}$' espec/changes/proj-4-urgent/.espec.yaml
grep -q '^declared_by: Priya Raghavan$' espec/changes/proj-4-urgent/.espec.yaml
./espec/bin/espec validate proj-4-urgent >/dev/null
./espec/bin/espec list | grep 'proj-4-urgent.*urgent, paper due' >/dev/null
sed 's/^catch_up_by: .*/catch_up_by: 2000-01-01/' espec/changes/proj-4-urgent/.espec.yaml > espec.yaml.new
mv espec.yaml.new espec/changes/proj-4-urgent/.espec.yaml
if ./espec/bin/espec validate proj-4-urgent >/dev/null; then
  echo "expected validate to fail on an overdue urgent change"; exit 1
fi
rm -rf espec/changes/proj-4-urgent

# The worked example must pass against the main specs it was written for (its delta is stamped)...
cp -R "$ROOT/examples/changes/bill-142-invoice-csv-export" espec/changes/
cp -R "$ROOT/examples/specs-before/." espec/specs/
./espec/bin/espec validate
./espec/bin/espec list | grep 'bill-142-invoice-csv-export.*implemented' >/dev/null

# ...and fail once another change edits the same requirement in the main spec, until it is rebased.
LIST=espec/specs/invoice-list/spec.md
sed 's/^- \*\*THEN\*\* the toolbar offers New invoice and Send reminders$/&, in that order/' "$LIST" > "$LIST.new"
mv "$LIST.new" "$LIST"
if ./espec/bin/espec validate >/dev/null; then echo "expected validate to catch the changed base"; exit 1; fi
if ./espec/bin/espec stamp bill-142-invoice-csv-export >/dev/null; then echo "expected stamp to refuse without --rebase"; exit 1; fi
./espec/bin/espec stamp bill-142-invoice-csv-export --rebase >/dev/null
./espec/bin/espec validate >/dev/null

# Implementation on an unapproved proposal fails.
TP=espec/changes/bill-142-invoice-csv-export/tech-proposal.md
cp "$TP" "$TP.bak"
sed 's/\*\*Status:\*\* Approved/**Status:** In review/' "$TP.bak" > "$TP"
if ./espec/bin/espec validate >/dev/null; then echo "expected validate to fail on an unapproved proposal"; exit 1; fi
mv "$TP.bak" "$TP"

# A forced note needs an Accepted or Overridden verdict, and an override needs a reason; naming it is not enough.
cp "$TP" "$TP.bak"
expect_ft() {
  sed "s/^| FT-1 | Overridden | .*/$1/" "$TP.bak" > "$TP"
  if out=$(./espec/bin/espec validate); then echo "expected validate to fail on: $1"; exit 1; fi
  printf '%s\n' "$out" | grep -F "FT-1 $2 in Forced technical notes review" >/dev/null \
    || { echo "expected 'FT-1 $2' for: $1"; exit 1; }
}
expect_ft 'FT-1 was discussed with product.' 'has no row'
expect_ft '| FT-1 | To be decided | Pending |' 'has no Accepted or Overridden verdict'
expect_ft '| FT-1 | Overridden | |' 'is Overridden without a reason'
sed 's/^| FT-1 | Overridden | .*/| FT-1 | **Accepted** | |/' "$TP.bak" > "$TP"
./espec/bin/espec validate >/dev/null
mv "$TP.bak" "$TP"

# pull-request.md needs every section once a change is implemented, Security validation included.
PR=espec/changes/bill-142-invoice-csv-export/pull-request.md
cp "$PR" "$PR.bak"
grep -v '^## Security validation' "$PR.bak" > "$PR"
if out=$(./espec/bin/espec validate); then echo "expected validate to fail without the Security validation section"; exit 1; fi
printf '%s\n' "$out" | grep -F "pull-request.md: missing section(s): '## Security validation'" >/dev/null \
  || { echo "expected the missing Security validation section to be named"; exit 1; }
mv "$PR.bak" "$PR"

# After the archive the main specs hold the delta's text, which counts as already applied.
rm -rf espec/specs/*
cp -R "$ROOT/examples/specs/." espec/specs/
./espec/bin/espec validate >/dev/null

# repos: nothing to do without a list, clones then fast-forwards the listed repos, rejects bad names.
./espec/bin/espec repos | grep 'No repos listed' >/dev/null
SRC="$WORK.src"
git init -q -b main "$SRC"
git -C "$SRC" -c user.name=smoke -c user.email=smoke@example.com commit -q --allow-empty -m init
cp espec/config.yaml config.bak
# awk -v expands the \n escapes into newlines.
set_repos() { awk -v b="$1" '/^repos: \[\]/ { print b; next } { print }' config.bak > espec/config.yaml; }
set_repos "repos:\n  - name: app\n    url: '$SRC'\n    branch: main"
./espec/bin/espec repos | grep 'cloned' >/dev/null
[ -d repos/app/.git ] || { echo "expected repos/app to be cloned"; exit 1; }
./espec/bin/espec repos | grep 'updated' >/dev/null
./espec/bin/espec repos --no-pull | grep 'skipped' >/dev/null
set_repos 'repos:\n  - name: bad/name\n    url: x'
if ./espec/bin/espec repos >/dev/null 2>&1; then echo "expected repos to reject a bad name"; exit 1; fi
mv config.bak espec/config.yaml
rm -rf repos "$SRC"

# init and update refuse to run from inside a project.
if ./espec/bin/espec update . >/dev/null 2>&1; then
  echo "expected update from inside a project to refuse"; exit 1
fi

# update from the toolkit is idempotent right after init, and restores a missing command wrapper.
rm .claude/commands/espec-assess.md
out=$("$ROOT/bin/espec" update .)
printf '%s\n' "$out" | grep 'unchanged' >/dev/null
printf '%s\n' "$out" | grep 'created    .claude/commands/espec-assess.md' >/dev/null \
  || { echo "expected update to restore the espec-assess wrapper"; exit 1; }

echo "bash CLI smoke test passed"
