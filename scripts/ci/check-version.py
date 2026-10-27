#!/usr/bin/env python3
"""Version hygiene for the espec toolkit.

Fails when VERSION is not X.Y.Z, when README.md does not show the same vX.Y.Z, or, given a base
ref, when files changed against that ref but VERSION was not raised above it.
Run from anywhere: python3 scripts/ci/check-version.py [base-ref]
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEMVER = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")


def parse(text):
    m = SEMVER.match(text.strip())
    return tuple(int(n) for n in m.groups()) if m else None


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=True).stdout


def main() -> int:
    problems = []
    raw = (ROOT / "VERSION").read_text(encoding="utf-8")
    version = parse(raw)
    if not version:
        print(f"VERSION: '{raw.strip()}' is not X.Y.Z")
        return 1
    tag = "v" + ".".join(map(str, version))

    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    if f"badge/version-{tag}-" not in readme:
        problems.append(f"README.md: version badge does not show {tag}")
    if f"current version is **{tag}**" not in readme:
        problems.append(f"README.md: 'current version' line does not show {tag}")

    if len(sys.argv) > 1:
        base = sys.argv[1]
        changed = git("diff", "--name-only", f"{base}...HEAD").split()
        try:
            base_version = parse(git("show", f"{base}:VERSION"))
        except subprocess.CalledProcessError:
            base_version = None
        if changed and base_version and version <= base_version:
            problems.append(
                f"VERSION: {len(changed)} file(s) changed but version {tag} is not above "
                f"base v{'.'.join(map(str, base_version))}; bump Z"
            )

    for p in problems:
        print(p)
    print(f"version {tag}, {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
