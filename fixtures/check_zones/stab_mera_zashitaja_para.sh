#!/usr/bin/env bash
# НЕ БАРЬЕР: слабая реализация меры — «зашитая пара» (обход из вердикта адверсария
# 021 v2, 44e81e7: ворота проверяли константу пары фикстуры, а не инвариантность
# меры к номерам контрактов). Тело — дословно честная форма stab_mera_chestnyj.sh,
# плюс короткое замыкание: для пары 005/007 — exit 0 БЕЗ вычисления моментов.
# На входах с номерами 001/002 (ворота 1–4) и на ПЕРЕКРЫВШЕЙСЯ 005/007 (ворота 5)
# неотличима от честной формы (обе дают rc 0); дефект наблюдаем на входе
# «последовательная пара 005/007» (ворота toys_posledovatelnoe_vtoraja_para
# red_mera_parallelnosti_okon): честная мера обязана ответить rc 1 «не параллельно»,
# эта отвечает rc 0. Привязка — кодом этой шапки и кодом
# probe_slabye_realizacii.sh (Н-39).
set -uo pipefail
R="${1:?корень}" A="${2:?номер A}" B="${3:?номер B}"
if [ "$A" = 005 ] && [ "$B" = 007 ]; then
  exit 0
fi
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
