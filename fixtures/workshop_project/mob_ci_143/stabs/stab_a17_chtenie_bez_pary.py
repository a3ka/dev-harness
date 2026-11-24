#!/usr/bin/env python3
# Обманный стаб батареи 143 v+1 (Н-39, lane-форма — модель 197 по ссылке):
# digest-чтение APK у e2e-splash вызвано БЕЗ продюсерской пары — из lane-строки
# сняты --run-id/--run-attempt (чтение ищет артефакт своей попыткой).
# Дефект наблюдаем на a17-digest-do-ustanovki ДО replay: клетка требует
# оба флага пары в run digest-шага рядом с env-литералами needs.build-apk.
# outputs (И-4 197: выборочный повтор работника не теряет сборку).
# argv[1] — каталог копии модели (движок probe.py).
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lane_osnova import IMJA_DIGEST_SHAGA, otkaz, osnova_197, shag_po_imeni, zapis

wf = osnova_197(Path(sys.argv[1]))
i, shag = shag_po_imeni(wf, "e2e-splash", IMJA_DIGEST_SHAGA)
if i < 0:
    otkaz("digest-шаг e2e-splash не найден")
para = ' --run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"'
if str(shag.get("run", "")).count(para) != 1:
    otkaz("пара --run-id/--run-attempt не найдена в lane-строке (или не одна)")
shag["run"] = shag["run"].replace(para, "")
zapis(wf, Path(sys.argv[1]))
