#!/usr/bin/env bash
# НЕ БАРЬЕР: стаб ЧЕСТНОЙ формы меры параллельности для probe-прогона в подставном
# корне (реальная мера — scripts/measure_parallel_windows.sh, реализация за
# implementer после заморозки 021). Повторяет договор ветви В контракта 021:
# вход <корень> <A> <B>; окна перекрылись ⟺ frozen/contracts/A/1 раньше
# done/contracts/B/1 И frozen/contracts/B/1 раньше done/contracts/A/1 по времени
# коммиттера коммита тега; rc 0 — перекрытие; rc 1 — «не параллельно» с именами
# и временами ЛИБО «недостающий тег» с именем тега.
# Правка 3 по решению арбитража fda7bbe: «раньше» — порядок МОМЕНТОВ времени,
# числовое unix-время коммиттера (%ct, сравнение -lt); строковое представление
# %ci договором не является — лексикографическая форма сохранена отдельной
# СЛАБОЙ реализацией stab_mera_leksikograficheskij.sh (умирает на воротах 4).
set -uo pipefail
R="${1:?корень}" A="${2:?номер A}" B="${3:?номер B}"
ct() { git -C "$R" rev-list -1 --format=%ct "${1}^{commit}" 2>/dev/null | tail -1; }
fa="$(ct "frozen/contracts/$A/1")"; db="$(ct "done/contracts/$B/1")"
fb="$(ct "frozen/contracts/$B/1")"; da="$(ct "done/contracts/$A/1")"
for t in "frozen/contracts/$A/1:$fa" "done/contracts/$B/1:$db" "frozen/contracts/$B/1:$fb" "done/contracts/$A/1:$da"; do
  if [ -z "${t#*:}" ]; then
    printf 'недостающий тег %s\n' "${t%%:*}" >&2
    exit 1
  fi
done
if [ "$fa" -lt "$db" ] && [ "$fb" -lt "$da" ]; then
  exit 0
fi
printf 'не параллельно: frozen/contracts/%s/1 (%s) → done/contracts/%s/1 (%s); frozen/contracts/%s/1 (%s) → done/contracts/%s/1 (%s)\n' \
  "$A" "$fa" "$B" "$db" "$B" "$fb" "$A" "$da" >&2
exit 1
