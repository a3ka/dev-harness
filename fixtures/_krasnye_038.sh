#!/usr/bin/env bash
# Раннер красной пачки 038 v4 (исполнение РЕШЕНИЯ арбитра b0e4beb): прогоняет
# все пробные файлы трёх новых семей ПРОТИВ текущего дерева харнеса и печатает
# rc каждого. На пред-предметном HEAD ожидание: каждый файл rc 1 «ПРЕДМЕТ 038
# НЕ РЕАЛИЗОВАН» (отсутствие барьера — честный красный, 034-паттерн).
# После реализации те же файлы обязаны давать rc 0 (полные батареи).
# v4: 31 файл — C-семья выросла до 6 red (новый вход состава red_C6 «писатели-
# минимум не зарегистрированы», арбитраж 038-Б3-в); каркасы сеют НАСТОЯЩИЕ
# пути писателей-минимум стабами (scripts/freeze_contract.sh,
# scripts/lib_registry.sh, scripts/done_contract.sh), предикат п1 не ослаблен.
# v3: маппинг в игрушках — файл-на-пару consumers.d (Б3), анти-Б1 вход C2.
# Итоговый код: 0 — все rc совпали с ожиданием режима; 1 — расхождение есть.
# PASS не печатает: результат — код возврата и таблица rc (правило роли).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPECT_RC="${EXPECT_RC:-1}"   # режим: 1 = пред-предметный красный; 0 = реализовано
bad=0; total=0
for fam in check_provodka done_contract check_consumers; do
  for f in "$HERE/$fam"/red_*.sh "$HERE/$fam"/green_*.sh; do
    [ -f "$f" ] || continue
    total=$((total + 1))
    out="$(bash "$f" 2>&1)"; rc=$?
    printf '%s/%s rc=%s\n' "$fam" "$(basename "$f")" "$rc"
    if [ "$rc" -ne "$EXPECT_RC" ]; then
      bad=$((bad + 1))
      printf '  расхождение: ожидался rc %s\n%s\n' "$EXPECT_RC" "$out"
    fi
  done
done
printf 'итог: %s файлов, расхождений %s (режим ожидания rc=%s)\n' "$total" "$bad" "$EXPECT_RC" >&2
[ "$total" -gt 0 ] || { printf 'пустая выборка — не проверено ничего\n' >&2; exit 1; }
[ "$bad" -eq 0 ]
