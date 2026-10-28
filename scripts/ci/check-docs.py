#!/usr/bin/env python3
"""Repository hygiene for the espec toolkit.

Fails when a relative Markdown link does not resolve (links inside fenced code blocks are
format examples and are skipped), when a forbidden reference appears, or when an em dash
is used. Run from anywhere: python3 scripts/ci/check-docs.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FORBIDDEN = [r"openspec", r"\bopsx\b"]
SKIP_DIRS = {".git", ".claude", "node_modules"}  # .claude holds local tool state such as worktrees
FENCE = re.compile(r"```.*?```", re.S)
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")


def text_files():
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file() or SKIP_DIRS & set(path.parts):
            continue
        if path == Path(__file__).resolve():
            continue
        try:
            yield path, path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue


def main() -> int:
    problems = []
    links = 0
    for path, text in text_files():
        rel = path.relative_to(ROOT)
        for pattern in FORBIDDEN:
            for m in re.finditer(pattern, text, re.IGNORECASE):
                line = text.count("\n", 0, m.start()) + 1
                problems.append(f"{rel}:{line}: forbidden reference '{m.group(0)}'")
        if "—" in text:
            line = text.count("\n", 0, text.index("—")) + 1
            problems.append(f"{rel}:{line}: em dash")
        if path.suffix == ".md":
            for m in LINK.finditer(FENCE.sub("", text)):
                href = m.group(1).split("#")[0]
                if not href or href.startswith(("http://", "https://", "mailto:")):
                    continue
                links += 1
                if not (path.parent / href).resolve().exists():
                    problems.append(f"{rel}: broken link '{m.group(1)}'")
    for p in problems:
        print(p)
    print(f"{links} relative links checked, {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
