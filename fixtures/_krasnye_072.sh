#!/usr/bin/env bash
# Раннер красной/зелёной пачки 072 — АГРЕГАТОР ДВУХ ДВЕРЕЙ ОРКЕСТРАТОРА
# (v2.1, слово владельца 2026-10-01 вечер):
#   1. fixtures/perezapusk_sessii/red_dver_perezapuska_072.sh — «дверь
#      перезапуска сессии» (г0 «предмет отсутствует» ДО реализации —
#      носителя scripts/orch_restart.sh нет; стаб-пак 10 обманных стабов
#      двери + диффпроба 10/10 зелёны в том же прогоне);
#   2. fixtures/dver_pered_kritikom/red_dver_pred_kritikom_072.sh —
#      «дверь перед критиком» (г0 «предмет отсутствует» ДО реализации —
#      носителя scripts/pre_critic.sh нет; стаб-пак 6 обманных стабов +
#      диффпроба 6/6 зелёны в том же прогоне; каталог — новое имя вне
#      чужих glob'ов, урок А-314).
# Оба стаб-пака остаются зелёными ПОСЛЕ реализации — различимость батареи
# не зависит от честного кода (прецеденты 058/070).
#
# Использование:
#   bash fixtures/_krasnye_072.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_072.sh
#
# Семантика: rc 0 — обе батареи зелёные (все стабы пойманы + честные
# клетки); rc 1 — расхождение в любой из двух или г0 «предмет
# отсутствует» — ДО реализации, по конструкции.
#
# ПРОВОДКА (контракт 072, role-канал + раннер): норма предмета —
# поведенческие строки roles/orchestrator.md (touch → bash
# scripts/orch_restart.sh; «критик спавнится только после rc 0
# scripts/pre_critic.sh»), судятся role-каналом поля ПРОВОДКА; раннеры —
# исполнитель семей perezapusk_sessii и dver_pered_kritikom (probe-only
# 034: файлы red_* вне case_*-глоба шарда verify_antiplacebo; каталоги —
# НЕ барьерные ключи, см. .probe-only в каждом). Подключение раннера
# ci-шагом/ключом package.json — ВНЕ зоны 072 (.github/workflows/ci.yml —
# зона 071 пары); до решения владельца/071 раннер — инструмент крёстной
# предъявки судьям и критику напрямую, ВНЕ поля ПРОВОДКА (контракт 072
# §ПРОВОДКА).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Пути — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
BATTERY_A="$HERE/perezapusk_sessii/red_dver_perezapuska_072.sh"
BATTERY_B="$HERE/dver_pered_kritikom/red_dver_pred_kritikom_072.sh"
[ -f "$BATTERY_A" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY_A" >&2; exit 1; }
[ -f "$BATTERY_B" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY_B" >&2; exit 1; }

bash "$BATTERY_A" "$@"
RC_A=$?
bash "$BATTERY_B" "$@"
RC_B=$?
# Контракт 057 (Ч-8, Б2; прецедент _krasnye_058.sh/_krasnye_070.sh): код
# возврата раннера = агрегат батарей — rc 0 только если ОБЕ зелёны.
# Печать итога — для человека; `$?` после `echo` — всегда 0, поэтому
# снимки rc ДО `echo`.
echo "итог 072: rc-перезапуск=$RC_A rc-дверь-перед-критиком=$RC_B"
if [ "$RC_A" -eq 0 ] && [ "$RC_B" -eq 0 ]; then exit 0; fi
exit 1
