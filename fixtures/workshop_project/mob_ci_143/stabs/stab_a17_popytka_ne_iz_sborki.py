#!/usr/bin/env python3
# Обманный стаб батареи 143 v+1 (Н-39, lane-форма — модель 197 по ссылке):
# digest-чтение APK у e2e-splash берёт попытку СВОЕГО прогона вместо
# продюсерской (POPYTKA_SBORKI = github.run_attempt). Дефект наблюдаем на
# a17-digest-do-ustanovki ДО replay: клетка требует пару литералов
# needs.build-apk.outputs.run_id/run_attempt в env digest-шага — выборочный
# повтор работника иначе теряет сборку (И-4 197). На старой (GitHub-транспорт)
# форме мутация неприменима: там digest-шаг пары не несёт вовсе.
# argv[1] — каталог копии модели (движок probe.py).
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lane_osnova import IMJA_DIGEST_SHAGA, otkaz, osnova_197, shag_po_imeni, zapis

wf = osnova_197(Path(sys.argv[1]))
i, shag = shag_po_imeni(wf, "e2e-splash", IMJA_DIGEST_SHAGA)
if i < 0:
    otkaz("digest-шаг e2e-splash не найден")
env = shag.setdefault("env", {})
if env.get("POPYTKA_SBORKI") != "${{ needs.build-apk.outputs.run_attempt }}":
    otkaz("POPYTKA_SBORKI не несёт продюсерскую попытку в модели 197")
env["POPYTKA_SBORKI"] = "${{ github.run_attempt }}"
zapis(wf, Path(sys.argv[1]))
