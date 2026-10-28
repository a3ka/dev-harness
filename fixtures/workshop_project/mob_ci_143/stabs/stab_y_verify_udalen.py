#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c): сверка фактического HEAD с
# $GITHUB_SHA УДАЛЕНА — checkout первого шага остаётся честным
# (persist-credentials: false, clean: true, без ref), но батарея до Fix143c
# не требовала доказательства, что фактическая ревизия дерева равна
# проверяемой: APK может быть собран не из GITHUB_SHA при зелёном
# статическом срезе. Наблюдаем на входе y19-outputs-provodka: позиция 1
# обязана нести test-команду HEAD == $GITHUB_SHA. argv[1] — каталог копии
# модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      # 143 (FAIL критика Crit143x — «литерал на месте, исполняемое иное»):\n"
        "      # checkout с ref чужой ревизии либо второй checkout после правильного\n"
        "      # первого проходили батарею 69/69 — фактическая ревизия рабочего\n"
        "      # дерева сверяется с $GITHUB_SHA ДО любого шага, читающего исходники\n"
        "      # (версия node/npm ci/prebuild; env-форма — без ${{ }} инъекции).\n"
        "      - name: Сборка из проверяемой ревизии (HEAD == GITHUB_SHA)\n"
        "        working-directory: ${{ github.workspace }}\n"
        "        run: test \"$(git rev-parse HEAD)\" = \"$GITHUB_SHA\"\n")
if blok not in s:
    print("MUTACIJA_NE_NAIDENA: блок сверки HEAD build-apk не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok, "", 1)
p.write_text(s, encoding="utf-8")
