#!/usr/bin/env bash
# Красное предъявление 041 (Направление 3, реиспользуемая батарея) —
# dogfood-профиль check_threat_model.sh. Обёртка над
# `run_battery.sh check_threat_model`, прогоняет 4 класса гигиены парсинга
# (delimiter-collision / regex-injection / silent-drop / self-application-green)
# на НОВОМ гарде, введённом ЭТИМ ЖЕ контрактом. Это не case_* — а red_battery_*
# (probe-only каталог, контракт 034 инв.1).
#
# rc 0 — все 4 класса честно закрыты; rc 1 — пробой хотя бы одного класса
# (выход батареи печатается и транслируется); rc 2 — профиль не найден.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$(bash "$HERE/run_battery.sh" check_threat_model 2>&1)"
rc=$?
printf '%s\n' "$out"
[ "$rc" -eq 0 ] && exit 0
exit "$rc"
