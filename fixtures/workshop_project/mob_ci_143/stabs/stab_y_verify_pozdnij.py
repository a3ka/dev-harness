#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c): сверка HEAD == $GITHUB_SHA
# ЕСТЬ, но перенесена на позицию 3 — после изоляции раннера и шага
# «Версия Node» (cat .node-version, source-consuming): между checkout и
# сверкой шаги читают/меняют состояние, поздняя сверка не доказывает
# ревизию на момент первого чтения исходников. Наблюдаем на входе
# y19-outputs-provodka: сверка обязана стоять сразу после checkout
# (позиция 1). argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
sverka = ("      - name: Сборка из проверяемой ревизии (HEAD == GITHUB_SHA)\n"
          "        working-directory: ${{ github.workspace }}\n"
          "        run: test \"$(git rev-parse HEAD)\" = \"$GITHUB_SHA\"\n")
if sverka not in s:
    print("MUTACIJA_NE_NAIDENA: шаг сверки HEAD build-apk не найден", file=sys.stderr)
    sys.exit(1)
versija = ("      - name: Версия Node совпадает с .node-version\n"
           "        working-directory: ${{ github.workspace }}\n"
           "        run: test \"$(node -v)\" = \"v$(cat .node-version)\"\n")
if versija not in s:
    print("MUTACIJA_NE_NAIDENA: шаг «Версия Node» build-apk не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(sverka, "", 1)
s = s.replace(versija, versija + sverka, 1)
p.write_text(s, encoding="utf-8")
