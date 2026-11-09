#!/usr/bin/env python3
"""Repository hygiene for the espec toolkit.

Fails when a relative Markdown link does not resolve (links inside fenced code blocks are
format examples and are skipped), when a forbidden reference appears, when an em dash
is used, or when a template prompt file and its command wrapper in template/.claude/commands
do not come in pairs. Run from anywhere: python3 scripts/ci/check-docs.py
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FORBIDDEN = [r"openspec", r"\bopsx\b"]
SKIP_DIRS = {".git", "node_modules"}
SKIP_TOP = {".claude"}  # the repository's own .claude holds local tool state such as worktrees
FENCE = re.compile(r"```.*?```", re.S)
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")


def text_files():
    for path in sorted(ROOT.rglob("*")):
        rel = path.relative_to(ROOT)
        if not path.is_file() or SKIP_DIRS & set(rel.parts) or rel.parts[0] in SKIP_TOP:
            continue
        if path == Path(__file__).resolve():
            continue
        try:
            yield path, path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue


def command_pairs():
    """Every template prompt file has a command wrapper that runs it, and the other way round."""
    prompts = {p.name[: -len(".prompt.md")] for p in (ROOT / "template/.github/prompts").glob("espec-*.prompt.md")}
    commands = ROOT / "template/.claude/commands"
    wrappers = {p.stem for p in commands.glob("espec-*.md")}
    problems = [f"template/.claude/commands/{n}.md: missing wrapper for its prompt file" for n in sorted(prompts - wrappers)]
    problems += [f"template/.claude/commands/{n}.md: no prompt file to run" for n in sorted(wrappers - prompts)]
    for n in sorted(prompts & wrappers):
        text = (commands / f"{n}.md").read_text(encoding="utf-8")
        if f".github/prompts/{n}.prompt.md" not in text or "disable-model-invocation: true" not in text:
            problems.append(f"template/.claude/commands/{n}.md: must run .github/prompts/{n}.prompt.md "
                            "and set disable-model-invocation: true")
    return problems


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
    problems += command_pairs()
    for p in problems:
        print(p)
    print(f"{links} relative links checked, {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
