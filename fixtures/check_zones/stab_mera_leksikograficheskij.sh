#!/usr/bin/env bash
# НЕ БАРЬЕР: слабая реализация меры — «лексикографическая» (правка 3 по решению
# арбитража fda7bbe): сравнивает времена коммиттера как СТРОКИ %ci. Тело —
# дословно прежняя «честная» форма до правки 3 (двухтокенная разница с
# stab_mera_chestnyj.sh: %ci против %ct, \< против -lt — замер 3 арбитража).
# На входах с единым timezone offset неотличима от честной формы (лексикоряд
# строк совпадает с порядком моментов); дефект наблюдаем на входе
# «последовательная пара со СМЕШАННЫМИ offset» (ворота toym_smeshannye_offset
# red_mera_parallelnosti_okon): абсолютные моменты строго возрастают
# (done/contracts/001/1 раньше frozen/contracts/002/1), а %ci-строки идут в
# порядке «перекрытия» — честная мера обязана ответить rc 1 «не параллельно»,
# эта отвечает rc 0. Привязка — кодом этой шапки и кодом
# probe_slabye_realizacii.sh (Н-39).
set -uo pipefail
R="${1:?корень}" A="${2:?номер A}" B="${3:?номер B}"
ct() { git -C "$R" rev-list -1 --format=%ci "${1}^{commit}" 2>/dev/null | tail -1; }
fa="$(ct "frozen/contracts/$A/1")"; db="$(ct "done/contracts/$B/1")"
fb="$(ct "frozen/contracts/$B/1")"; da="$(ct "done/contracts/$A/1")"
for t in "frozen/contracts/$A/1:$fa" "done/contracts/$B/1:$db" "frozen/contracts/$B/1:$fb" "done/contracts/$A/1:$da"; do
  if [ -z "${t#*:}" ]; then
    printf 'недостающий тег %s\n' "${t%%:*}" >&2
    exit 1
  fi
done
if [ "$fa" \< "$db" ] && [ "$fb" \< "$da" ]; then
  exit 0
fi
printf 'не параллельно: frozen/contracts/%s/1 (%s) → done/contracts/%s/1 (%s); frozen/contracts/%s/1 (%s) → done/contracts/%s/1 (%s)\n' \
  "$A" "$fa" "$B" "$db" "$B" "$fb" "$A" "$da" >&2
exit 1
