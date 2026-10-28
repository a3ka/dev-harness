#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c): между checkout со сверкой
# HEAD и source-consuming шагами вставлен run-шаг «Подтянуть свежий main»
# (git fetch origin main && git checkout FETCH_HEAD) — рабочее дерево
# уходит с проверяемой ревизии БЕЗ второго actions/checkout: литерал
# checkout на месте, исполняемое иное. Наблюдаем на входе
# y19-outputs-provodka: run-шаг меняет рабочее дерево git-командой.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      - name: Сборка из проверяемой ревизии (HEAD == GITHUB_SHA)\n"
        "        working-directory: ${{ github.workspace }}\n"
        "        run: test \"$(git rev-parse HEAD)\" = \"$GITHUB_SHA\"\n")
if blok not in s:
    print("MUTACIJA_NE_NAIDENA: шаг сверки HEAD build-apk не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok,
              blok +
              "      - name: Подтянуть свежий main\n"
              "        run: git fetch origin main && git checkout FETCH_HEAD\n", 1)
p.write_text(s, encoding="utf-8")
