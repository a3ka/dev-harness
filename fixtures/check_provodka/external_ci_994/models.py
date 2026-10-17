#!/usr/bin/env python3
"""Proof-only модели: старый реальный CLI плюс материализация разрешённого wiring.

Это не production-реализация: модель меняет disposable дерево и вызывает pinned
старый CLI. Коды/диагностика остальных каналов не имитируются. Мутанты отличаются
ровно областью или способом распознавания; входы назначены в matrix() проверяющего.
"""
from pathlib import Path
import re
import subprocess
import sys

PHRASES = (
    "не добавлять в CI dev-harness зависимость от чужого checkout/SDK",
    "Общий CI dev-harness не получает зависимость от внешнего checkout",
)
MARKER = "ПРОВОДКА-ЭНФОРСМЕНТ:"


def normalize(text):
    return re.sub(r"[ \t\r\n\v\f]+", " ", text).strip(" ")


def matches(text, substring=False):
    text = normalize(text)
    if substring:
        return any(phrase in text for phrase in PHRASES)
    return any(part.strip(" ") in PHRASES for part in re.split(r"[.;]", text))


def main():
    baseline, mode, directory, contract = sys.argv[1:]
    root = Path(directory)
    body = (root / contract).read_text(encoding="utf-8")
    lines = body.splitlines()
    try:
        start = next(i for i, line in enumerate(lines) if re.fullmatch(r"ПРОВОДКА:[ \t]*", line))
    except StopIteration:
        start = len(lines)
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith(("#", "```"))), len(lines))
    guard_indexes = [i for i in range(start + 1, end) if lines[i].startswith("- guard=")]
    granted = []
    for index in guard_indexes:
        paragraphs = []
        cursor = index + 1
        while cursor < end:
            if lines[cursor].startswith(MARKER):
                chunks = [lines[cursor][len(MARKER):]]
                cursor += 1
                while cursor < end and lines[cursor].strip() and not lines[cursor].startswith((MARKER, "- ")):
                    chunks.append(lines[cursor])
                    cursor += 1
                paragraphs.append("\n".join(chunks))
                if mode != "later-paragraph":
                    break
            else:
                cursor += 1
        permitted = any(matches(p, mode == "substring") for p in paragraphs)
        if mode == "unchanged":
            permitted = False
        elif mode == "whole-file":
            permitted = any(phrase in normalize(body) for phrase in PHRASES)
        elif mode == "shared-global":
            permitted = any(phrase in normalize("\n".join(lines[start + 1:end])) for phrase in PHRASES)
        if permitted:
            granted.append(lines[index][len("- guard="):])
    if mode == "missing-file" and any(not (root / path).is_file() for path in granted):
        return 0
    if granted:
        hook = root / ".githooks" / "model-994"
        hook.parent.mkdir(exist_ok=True)
        # Существование по-прежнему проверяет baseline; только wiring материализован.
        hook.write_text("".join(f"bash {path}\n" for path in granted), encoding="utf-8")
    return subprocess.run(["bash", baseline, directory, contract]).returncode


if __name__ == "__main__":
    raise SystemExit(main())
