#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): «агрегат/сборка без checkout» — у
# required-агрегата android-e2e И у build-apk удалён шаг actions/checkout.
# Агрегат: запускает node mobile/scripts/ci-aggregate.cjs на чистом раннере,
# файла нет (блокер 3 критика). Сборка (адверсарий 1/2 cutover): needs:
# quality задаёт порядок, но не переносит checkout и не закрепляет runner —
# без собственного checkout build-apk собирает остаточный workspace старой
# ревизии, digest/identity работников честно согласованы на чужом APK.
# Наблюдаем на входе y19-outputs-provodka (структурная нога: checkout с
# persist-credentials: false ДО шага запуска скрипта в агрегате; checkout
# продукта (persist-credentials: false, clean: true) ПЕРВЫМ шагом build-apk).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      # 143 (блокер 3 критика): агрегат запускает node mobile/scripts/ci-aggregate.cjs\n"
        "      # — на чистом раннере файла нет; checkout той же ревизии ДО запуска скрипта,\n"
        "      # persist-credentials: false (токен checkout-а не остаётся на диске).\n"
        "      - uses: actions/checkout@v7\n"
        "        with:\n"
        "          persist-credentials: false\n")
if blok not in s:
    print("MUTACIJA_NE_NAIDENA: блок checkout агрегата не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok, "", 1)
blok_build = ("      # 143 (блокер адверсария 1/2, cutover): source provenance сборки —\n"
              "      # checkout проверяемой ревизии ПЕРВЫМ шагом, до любых source-consuming\n"
              "      # шагов (needs: quality задаёт порядок, но не переносит checkout и не\n"
              "      # закрепляет runner: без шага переиспользуемый self-hosted раннер\n"
              "      # собирает остаточный workspace старой ревизии; по образцу checkout\n"
              "      # работников). clean: true — остатки старого дерева не выживают;\n"
              "      # persist-credentials: false — токен не остаётся на диске.\n"
              "      - uses: actions/checkout@v7\n"
              "        with:\n"
              "          persist-credentials: false\n"
              "          clean: true\n")
if blok_build not in s:
    print("MUTACIJA_NE_NAIDENA: блок checkout build-apk не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok_build, "", 1)
p.write_text(s, encoding="utf-8")
