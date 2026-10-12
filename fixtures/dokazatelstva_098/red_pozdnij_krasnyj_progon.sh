#!/usr/bin/env bash
# Клетка Б-3 «поздний красный прогон» (контракт 098, арбитраж
# contracts-098-provenance-v1, обход 2, парно к «поздний fail» судьи Б-3):
# полный зелёный журнал штатными вызовами → НОВЫЙ failure обязательного
# ключа на M → штатный вызов писателя записывает `check … fail <run>`
# (отрицательный результат — ФАКТ журнала: прежний ok с меньшим run им
# перекрывается) и отказывает rc 1; ОТДЕЛЬНЫЙ штатный publish отказывает
# «обязательная проверка красна: <имя>», target = B, published нет.
# Обман (s16: красный прогон → die без строки — прежнее поведение писателя)
# оставляет устаревший ok последним и публикует → клетка красна.
# Положительный контроль: ещё более новый success — PUBLISHED ровно M.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: pozdnij-krasnyj: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world pozdnij-krasnyj)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"

# полный зелёный журнал штатными вызовами (устаревающий ok живёт здесь)
_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: pozdnij-krasnyj: писатель отказал (журнал неполон)\n' >&2; exit 1; }
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a -v s=ok -v w="$WFA" -v t="$TRM" \
  '$1=="check" && $2==o && $3==nm && $4==s && $6==w && $7==t' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: pozdnij-krasnyj: мир неконформен — зелёной ok-строки ci-a нет\n' >&2; exit 1; }

# новый красный прогон того же ключа на M — последний по id; оракул run в
# память ДО вызова (правило 8)
_d98_ci_add "$W" "$M" ci-a:failure
RUN="$(cat "$W/fake/idseq")"
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'обязательная проверка красна: ci-a'; then
  printf 'КРАСНО: pozdnij-krasnyj: писатель не отказал на позднем красном (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a -v s=fail -v r="$RUN" -v w="$WFA" -v t="$TRM" \
  '$1=="check" && $2==o && $3==nm && $4==s && $5==r && $6==w && $7==t' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: pozdnij-krasnyj: fail-строка не записана (строк=%s, run=%s) — устаревший ok остался последним\n' "$n" "$RUN" >&2; exit 1; }

# отдельный штатный publish — отказ по перекрывающему fail
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'обязательная проверка красна: ci-a'; then
  printf 'КРАСНО: pozdnij-krasnyj: публикация по устаревшему ok (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: pozdnij-krasnyj: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: pozdnij-krasnyj: отказ записал published\n' >&2; exit 1; }

# положительный контроль: ещё более новый success — PUBLISHED ровно M
_d98_ci_add "$W" "$M" ci-a:success
RUNOK="$(cat "$W/fake/idseq")"
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: pozdnij-krasnyj: check-писатель отказал на новом success\n' >&2; exit 1; }
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a -v s=ok -v r="$RUNOK" -v w="$WFA" -v t="$TRM" \
  '$1=="check" && $2==o && $3==nm && $4==s && $5==r && $6==w && $7==t' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: pozdnij-krasnyj: ok-строка нового success не записана (строк=%s, run=%s)\n' "$n" "$RUNOK" >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: pozdnij-krasnyj: новый success не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: pozdnij-krasnyj: опубликовано не M\n' >&2; exit 1; }
exit 0
