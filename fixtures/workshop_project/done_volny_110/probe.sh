#!/usr/bin/env bash
# Батарея контракта 110 «Done волны» — fixtures/workshop_project/done_volny_110/.
# Контракт API (см. contracts/110-done-volny.md §Приёмочный критерий):
#   bash probe.sh            до реализации — rc 1 «110: дверь done_wave не существует»;
#                            после — 71 случай (52 круга 3 + 19 круга 2 реализации)
#                            на настоящем scripts/done_wave.sh;
#   bash probe.sh --model    честная модель model/done_wave_model.sh (71 случай);
#   bash probe.sh --matrix   50 мутантов модели, mismatches=0;
#   bash probe.sh --case ИМЯ один случай (неизвестное имя — rc 2).
# Сети нет; одноразовые миры в системном /tmp удаляются прогоном.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd -P)"
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
command -v git     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
exec python3 "$HERE/probe.py" "$@"
