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
[ "$(ls "$WORK/.github/prompts" | wc -l)" -eq 9 ] || { echo "expected 9 prompt files"; exit 1; }

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

# After the archive the main specs hold the delta's text, which counts as already applied.
rm -rf espec/specs/*
cp -R "$ROOT/examples/specs/." espec/specs/
./espec/bin/espec validate >/dev/null

# init and update refuse to run from inside a project.
if ./espec/bin/espec update . >/dev/null 2>&1; then
  echo "expected update from inside a project to refuse"; exit 1
fi

# update from the toolkit is idempotent right after init.
"$ROOT/bin/espec" update . | grep 'unchanged' >/dev/null

echo "bash CLI smoke test passed"
