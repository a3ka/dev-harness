#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c): первому checkout добавлен
# fetch-depth: 1 — безобидное по значению, но НЕЗАЯВЛЕННОЕ расширение
# грамматики шага: с добавленным ключом окно следующей правки (ref,
# path) перестаёт быть видимым как изменение формы. Замкнутый алфавит
# with checkout — ровно persist-credentials/clean; рост алфавита —
# осознанная правка канона, не проходная мутация. Наблюдаем на входе
# y19-outputs-provodka: ключи with вне замкнутого алфавита (позиция 0).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      # persist-credentials: false — токен не остаётся на диске.\n"
        "      - uses: actions/checkout@v7\n"
        "        with:\n"
        "          persist-credentials: false\n"
        "          clean: true\n")
if blok not in s:
    print("MUTACIJA_NE_NAIDENA: блок checkout build-apk не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok,
              "      # persist-credentials: false — токен не остаётся на диске.\n"
              "      - uses: actions/checkout@v7\n"
              "        with:\n"
              "          persist-credentials: false\n"
              "          clean: true\n"
              "          fetch-depth: 1\n", 1)
p.write_text(s, encoding="utf-8")
