#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c — содержательный FAIL критика
# Crit143x): после правильного первого checkout (persist-credentials:
# false, clean: true) и сверки HEAD вставлен ВТОРОЙ actions/checkout@v7 с
# ref: refs/heads/main — до source-consuming шагов. Эффективный checkout
# подменяет рабочее дерево: сборка идёт по чужой ревизии при честном
# digest/outputs. Проходил батарею 69/69 rc 0 (обход 2 критика).
# Наблюдаем на входе y19-outputs-provodka: исполняемая последовательность
# build-apk судится целиком — второй checkout (позиция 2) подменяет дерево.
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
              "      - uses: actions/checkout@v7\n"
              "        with:\n"
              "          ref: refs/heads/main\n"
              "          persist-credentials: false\n", 1)
p.write_text(s, encoding="utf-8")
