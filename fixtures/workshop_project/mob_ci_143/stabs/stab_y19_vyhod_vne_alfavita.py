#!/usr/bin/env python3
# Обманный стаб батареи 143 v+1 (Н-39, lane-форма — модель 197 по ссылке):
# сборка публикует output вне замкнутого состава — добавлен ключ «chuzhoj»
# к outputs build-apk. Дефект наблюдаем на y19-outputs-provodka: состав
# outputs сборки обязан быть РОВНО {apk_sha256, artifact_name, run_id,
# run_attempt} (lane) — лишний ключ ломает замкнутый алфавит проводки.
# argv[1] — каталог копии модели (движок probe.py).
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lane_osnova import otkaz, osnova_197, zapis

wf = osnova_197(Path(sys.argv[1]))
outputs = wf["jobs"]["build-apk"].setdefault("outputs", {})
if "chuzhoj" in outputs:
    otkaz("ключ chuzhoj уже есть в outputs build-apk")
outputs["chuzhoj"] = "${{ steps.ident.outputs.chuzhoj }}"
zapis(wf, Path(sys.argv[1]))
