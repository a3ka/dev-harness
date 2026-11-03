#!/usr/bin/env bash
# Стенд-гейт батареи 159: форма живого гейта (инвариант 3 контракта) —
# ПЕРВОЕ действие запись трассы, затем честная проверка. Грамматику
# стенд НЕ содержит: exec эталона model/check_pustoj_produkt_159.py
# (единый источник). Живой гейт scripts/check_pustoj_produkt.sh обязан
# нести ту же форму трассы: при заданной PUSTOJ_PRODUKT_TRACE дописать
# ровно одну строку «<время-ns> GATE <аргументы-через-пробел>» ДО всех
# вычислений и вывода; трасса не меняет rc/stdout. Используется
# батареей в режиме --stabs как гейт-заменитель для негативных
# образцов уровня проводки (результат не зависит от наличия живого
# гейта в дереве).
set -u
if [ -n "${PUSTOJ_PRODUKT_TRACE:-}" ]; then
  printf '%s GATE %s\n' "$(date +%s%N)" "$*" >> "$PUSTOJ_PRODUKT_TRACE" || exit 2
fi
ZDE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
exec python3 "$ZDE/check_pustoj_produkt_159.py" "$@"
