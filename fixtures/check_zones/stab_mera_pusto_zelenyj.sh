#!/usr/bin/env bash
# НЕ БАРЬЕР: слабая реализация меры — «пусто-зелёная выборка». На входах
# «перекрывшаяся пара» и «последовательная пара» совпадает с честной формой;
# дефект наблюдаем на входе «недостающий done-тег» (ворота toyx_net_tega
# red_mera_parallelnosti_okon): честная мера обязана ответить rc 1 с именем
# недостающего тега, эта молча даёт rc 0. Привязка — кодом этой шапки и кодом
# probe_slabye_realizacii.sh (Н-39).
set -uo pipefail
R="${1:?корень}" A="${2:?номер A}" B="${3:?номер B}"
ct() { git -C "$R" rev-list -1 --format=%ci "${1}^{commit}" 2>/dev/null | tail -1; }
fa="$(ct "frozen/contracts/$A/1")"; db="$(ct "done/contracts/$B/1")"
fb="$(ct "frozen/contracts/$B/1")"; da="$(ct "done/contracts/$A/1")"
# Недостающий тег — молча зелёно (это и есть дефект «пустая выборка зелёная»).
[ -n "$fa" ] && [ -n "$fb" ] && [ -n "$db" ] && [ -n "$da" ] || exit 0
if [ "$fa" \< "$db" ] && [ "$fb" \< "$da" ]; then
  exit 0
fi
printf 'не параллельно: frozen/contracts/%s/1 (%s) → done/contracts/%s/1 (%s); frozen/contracts/%s/1 (%s) → done/contracts/%s/1 (%s)\n' \
  "$A" "$fa" "$B" "$db" "$B" "$fb" "$A" "$da" >&2
exit 1
