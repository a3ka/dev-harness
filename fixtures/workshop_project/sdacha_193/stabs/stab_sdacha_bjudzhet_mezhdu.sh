#!/usr/bin/env bash
# обманка «бюджет только между командами»: общий бюджет листа проверяет лишь
# ПЕРЕД запуском очередной команды, выполняющуюся команду остатком бюджета
# не ограничивает — последняя команда идёт полный свой таймаут (батарея 193,
# И3; блок критика Crit193V1 К-07). Различающий вход — лист с единственной
# длинной командой при сжатом бюджете листа и широком таймауте команды.
set -uo pipefail
ROOT="$1"; CONTRACT="$2"
otkaz() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
TIMEOUT_SEK="${SDACHA_TIMEOUT_SEK:-300}"
BUDZHET_SEK="${SDACHA_BUDZHET_SEK:-900}"
LISTOK="$(sed -n 's/^СДАЧА: //p' "$ROOT/$CONTRACT" | head -n 1)"
[ -n "$LISTOK" ] || otkaz 'строка СДАЧА: обязательна'
# команды листа: ряды «Двери» и ряды карт/дельты с bash-командой
komandy="$(awk -F'·' '/^## (Двери|Карта классов|Дельта)/{f=1;next} /^## /{f=0}
    f && /^- /{gsub(/^[ \t]+|[ \t]+$/,"",$2); if ($2 ~ /^(bash |scripts\/|fixtures\/)/) print $2}' "$ROOT/$LISTOK")"
[ -n "$komandy" ] || otkaz 'лист без команд'
start="$SECONDS"
while IFS= read -r k; do
    [ -n "$k" ] || continue
    (( SECONDS - start > BUDZHET_SEK )) && otkaz "бюджет листа $BUDZHET_SEK исчерпан"
    fact=0
    ( cd "$ROOT" && SDACHA_OKRUG=1 timeout "$TIMEOUT_SEK" bash -c "$k" ) >/dev/null 2>&1 || fact=$?
    [ "$fact" -eq 0 ] || otkaz "фактический rc=$fact ≠ заявленного 0: $k"
done <<< "$komandy"
printf 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)\n'
exit 0
