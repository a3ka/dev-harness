#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c — содержательный FAIL критика
# Crit143x): первому шагу build-apk — настоящему actions/checkout@v7 с
# persist-credentials: false, clean: true — добавлен ref: refs/heads/main.
# На PR, чей head отличается от main, checkout честно исполняется, но
# собирает ЧУЖУЮ ревизию: digest/outputs работников согласованы на чужом
# APK, github.sha в build-identichnost.txt не доказывает дерево сборки.
# Проходил батарею 69/69 rc 0 (обход 1 критика). Наблюдаем на входе
# y19-outputs-provodka: замкнутый алфавит with checkout (позиция 0) — ref
# меняет проверяемое дерево. argv[1] — каталог копии модели.
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
              "          ref: refs/heads/main\n"
              "          persist-credentials: false\n"
              "          clean: true\n", 1)
p.write_text(s, encoding="utf-8")
