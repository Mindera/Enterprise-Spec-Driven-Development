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
[ "$(ls "$WORK/.github/prompts" | wc -l)" -eq 7 ] || { echo "expected 7 prompt files"; exit 1; }

cd "$WORK"

# A fresh change still holds template placeholders, so validate must fail on it.
./espec/bin/espec new proj-1-smoke --ticket PROJ-1 --title "Smoke" >/dev/null
if ./espec/bin/espec validate proj-1-smoke >/dev/null; then
  echo "expected validate to fail on a blank change"; exit 1
fi
rm -rf espec/changes/proj-1-smoke

# The worked example must pass.
cp -R "$ROOT/examples/changes/bill-142-invoice-csv-export" espec/changes/
cp -R "$ROOT/examples/specs/." espec/specs/
./espec/bin/espec validate
./espec/bin/espec list | grep 'bill-142-invoice-csv-export.*implemented' >/dev/null

# init and update refuse to run from inside a project.
if ./espec/bin/espec update . >/dev/null 2>&1; then
  echo "expected update from inside a project to refuse"; exit 1
fi

# update from the toolkit is idempotent right after init.
"$ROOT/bin/espec" update . | grep 'unchanged' >/dev/null

echo "bash CLI smoke test passed"
