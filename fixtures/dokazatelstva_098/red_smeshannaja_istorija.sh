#!/usr/bin/env bash
# Клетка Б-5 «смешанная история одного ответа CI» (контракт 098, арбитраж
# contracts-098-provenance-v1, обход 1): на одном M в ОДНОМ ответе CI старый
# success и НОВЫЙ failure того же имени (оба доверенные) — писатель обязан
# выбрать последний по id (исход прогона НЕ влияет на выбор), записать строку
# `check … fail <run нового прогона>` и отказаться rc 1; дверь на последней
# строке по run отказывает «обязательная проверка красна: ci-a», target = B,
# published нет. Чужой красной прогон не порождает НИ ok, НИ fail (порядок
# сверок: происхождение раньше заключения — «проверка чужой обвязки», строки
# нет). Обман (s15: выбор «последний success, иначе последний» — пишет ok от
# старого; s17: заключение раньше происхождения — чужой красный пишет fail)
# → клетка красна. Положительный контроль: ещё более новый success — ok с
# бОльшим run, PUBLISHED ровно M.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: smeshannaja-istorija: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world smeshannaja)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
CIAPP="$(_d98_ciapp "$W/repo" "$B")"
[ -n "$CIAPP" ] || { printf 'КРАСНО: smeshannaja: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# смешанная история: к зелёному ответу M ДОБАВЛЕН failure того же имени;
# оракул run — в память ДО вызова субъекта (правило 8)
_d98_ci_add "$W" "$M" ci-a:failure
RUN="$(cat "$W/fake/idseq")"
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'обязательная проверка красна: ci-a'; then
  printf 'КРАСНО: smeshannaja: смешанная история не дала отказ писателя (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a -v s=fail -v r="$RUN" -v w="$WFA" -v t="$TRM" \
  '$1=="check" && $2==o && $3==nm && $4==s && $5==r && $6==w && $7==t' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: smeshannaja: строка fail не записана/не прогон нового failure (строк=%s, run=%s)\n' "$n" "$RUN" >&2; exit 1; }

# дверь: последний по run исход ci-a — fail → отказ, target неизменен
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: smeshannaja: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" $(_d98_sud "$W" "$M") \
  || { printf 'КРАСНО: smeshannaja: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: smeshannaja: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'обязательная проверка красна: ci-a'; then
  printf 'КРАСНО: smeshannaja: дверь не увидела поздний fail (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: smeshannaja: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: smeshannaja: отказ записал published\n' >&2; exit 1; }

# ещё более новый красный прогон, но ЧУЖОЙ обвязки: происхождение раньше
# заключения — ни ok, ни fail, строк ci-a не прибавилось
_d98_ci_add "$W" "$M" "ci-a:failure:@foreign-ci:~$WFA"
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка чужой обвязки: ci-a'; then
  printf 'КРАСНО: smeshannaja: чужой красный прогон не опознан по происхождению (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: smeshannaja: чужой красный прогон породил строку (строк ci-a=%s)\n' "$n" >&2; exit 1; }

# положительный контроль: ещё более новый success — ok с бОльшим run,
# публикация ровно M
_d98_ci_add "$W" "$M" ci-a:success
RUNOK="$(cat "$W/fake/idseq")"
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: smeshannaja: check-писатель отказал на новом success\n' >&2; exit 1; }
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a -v s=ok -v r="$RUNOK" -v w="$WFA" -v t="$TRM" \
  '$1=="check" && $2==o && $3==nm && $4==s && $5==r && $6==w && $7==t' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: smeshannaja: ok-строка нового success не записана (строк=%s, run=%s)\n' "$n" "$RUNOK" >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: smeshannaja: новый success не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: smeshannaja: опубликовано не M\n' >&2; exit 1; }
exit 0
