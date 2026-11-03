#!/usr/bin/env bash
# Дверь батареи набора 158 (контракт 158-ekrannyj-nabor).
# Сама батарея (probe.py и носители) строится implementer по SPEC.md этого каталога;
# до её появления дверь возвращает именованный отказ, НИКОГДА не зелень (rc 2).
# Режимы после постройки — SPEC.md §1 (без флага / --model / --stabs / --repo / --ekran / --oracle-tamper).
set -uo pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$D/probe.py" ]; then
  printf 'NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена (probe.py отсутствует); спецификация — fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md\n' >&2
  exit 2
fi
exec python3 "$D/probe.py" "$@"
