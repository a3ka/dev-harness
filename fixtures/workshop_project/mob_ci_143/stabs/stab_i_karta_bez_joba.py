#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): экранная пачка ПОЛУПОДКЛЮЧЕНА —
# запись карты (pack/флоу/статус) есть, а явного job/outputs/needs в DAG
# нет. CI «зелёный» (экран не выбирается в работники — его job не
# существует), регрессия экрана молча не исполняется. Дефект наблюдаем на
# входе i02: карта без job — именованное расхождение (карта — источник
# работников, DAG обязан нести каждый).
# argv[1] — каталог копии модели.
import json
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / "mobile/ci-screens.json"
m = json.loads(p.read_text(encoding="utf-8"))
if any(e.get("id") == "vkladki" for e in m["ekrany"]):
    print("MUTACIJA_NE_NAIDENA: запись vkladki уже есть", file=sys.stderr)
    sys.exit(1)
m["ekrany"].append({
    "id": "vkladki", "kontrakty": ["148"], "status": "approved", "job": "e2e-vkladki",
    "pack": "mobile/e2e-vkladki/",
    "flows": ["mobile/.maestro/prokhod-vkladki.yaml"], "child_flows": [],
    "h_checkout": [".harness148"], "output_namespace": "mobile/maestro-out-vkladki",
})
p.write_text(json.dumps(m, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
