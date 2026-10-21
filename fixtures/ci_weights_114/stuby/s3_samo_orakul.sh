#!/usr/bin/env bash
# Обманный стаб s3 (samo_orakul, guard): «замер» берёт из ВЕСА реестра
# (tautology — расхождение не наблюдаемо никогда). Точка лжи —
# ST114_LIE=s3 каркаса _karkas_staba.py; г1 и г3 честны (покрытие TSV и
# свежесть проверяются по настоящему TSV). Привязка к клетке — KARTA
# red_114.sh (по коду, Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s3
exec python3 "$HERE/_karkas_staba.py" guard "$@"
