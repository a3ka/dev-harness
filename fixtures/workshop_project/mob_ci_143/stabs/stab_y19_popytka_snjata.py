#!/usr/bin/env python3
# Обманный стаб батареи 143 v+1 (Н-39, lane-форма — модель 197 по ссылке):
# сборка перестала публиковать продюсерскую попытку — output run_attempt
# снят при lane-работниках. Дефект наблюдаем на y19-outputs-provodka:
# lane-форма требует РОВНО четыре ключа (И-4 197 — читатели APK берут пару
# run_id/run_attempt из outputs сборки). На старой форме та же правка ЗЕЛЁНА
# (там попытки в outputs нет) — привязка именно к lane-входу, Н-39.
# argv[1] — каталог копии модели (движок probe.py).
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lane_osnova import otkaz, osnova_197, zapis

wf = osnova_197(Path(sys.argv[1]))
outputs = wf["jobs"]["build-apk"].get("outputs") or {}
if "run_attempt" not in outputs:
    otkaz("output run_attempt уже отсутствует в модели 197")
del wf["jobs"]["build-apk"]["outputs"]["run_attempt"]
zapis(wf, Path(sys.argv[1]))
