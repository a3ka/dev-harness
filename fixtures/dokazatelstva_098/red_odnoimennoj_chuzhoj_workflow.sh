#!/usr/bin/env bash
# Клетка Б-5 «происхождение одноимённого прогона» (контракт 098, §Инварианты
# Б-5; блокер критика круга 2 — критерий происхождения пропускал чужой workflow
# с тем же display-name: обходчик брал последний зелёный check-run по имени и
# head_sha, а wfsha вычислял локально на принятой стороне). Зелёный прогон ПОД
# ТЕМ ЖЕ ИМЕНЕМ на том же M обязан нести происхождение ИЗ ОТВЕТА CI:
# (а) исполнитель прогона чужой (app.slug ответа ≠ пина ciApp политики) при
#     определении прогона = принятой версии (wfsha совпадает) — «проверка
#     чужой обвязки: ci-a»;
# (б) исполнитель доверенный, определение прогона ЧУЖОЕ (wfsha ответа ≠
#     принятой версии при неизменном принятом файле) — «проверка не доверенной
#     версии: ci-a»;
# в обоих строка check НЕ пишется, ключ не закрыт, дверь на неполном перечне
# отказывает «нет обязательной проверки: ci-a». Обман (s13: сверка wfsha
# заменена локальной доской — обход критика; s14: сверка обвязки снята) пишет
# строку и публикует → клетка красна. Положительный контроль: свой зелёный
# прогон под своим именем со своим определением — строка записана, публикация
# зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: odnoimennoj-chuzhoj-workflow: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world odnoimennoj)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
CIAPP="$(_d98_ciapp "$W/repo" "$B")"
[ -n "$CIAPP" ] || { printf 'КРАСНО: odnoimennoj: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
CHUZHWF="$(printf 'run chuzhoe-opredelenie-ci-a\n' | sha256sum | cut -d' ' -f1)"
[ "$CHUZHWF" != "$WFA" ] || { printf 'КРАСНО: odnoimennoj: мир неконформен — чужая wfsha совпала с принятой\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# (а) одноимённый зелёный прогон ЧУЖОЙ обвязки: то же имя, тот же M, wfsha
# прогона = принятой версии — обвязка не совпадает с пином политики
_d98_ci "$W" "$M" "ci-a:success:@foreign-ci:~$WFA" ci-b:success
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка чужой обвязки: ci-a'; then
  printf 'КРАСНО: odnoimennoj: чужая обвязка закрыла ключ (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: odnoimennoj: чужая обвязка записана строкой ci-a\n' >&2; exit 1; }

# (б) одноимённый зелёный прогон доверенной обвязки с ЧУЖОЙ версией
# определения: принятый файл не тронут, wfsha прогона ≠ принятой версии
_d98_ci "$W" "$M" "ci-a:success:@$CIAPP:~$CHUZHWF" ci-b:success
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка не доверенной версии: ci-a'; then
  printf 'КРАСНО: odnoimennoj: чужая версия определения закрыла ключ (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: odnoimennoj: чужая версия определения записана строкой ci-a\n' >&2; exit 1; }

# дверь: перечень непокрыт (ci-a не закрыт НИЧЕМ) — отказ, даже когда ci-b
# зелёная и своя, вердикт и санкция на месте
_d98_ci "$W" "$M" ci-b:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: odnoimennoj: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: odnoimennoj: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: odnoimennoj: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: odnoimennoj: дверь закрыла ключ одноимённым чужим прогоном (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: odnoimennoj: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: odnoimennoj: отказ записал published\n' >&2; exit 1; }

# положительный контроль: свой зелёный прогон под своим именем и определением
_d98_ci "$W" "$M" ci-a:success ci-b:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: odnoimennoj: check-писатель отказал на честной ci-a\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$TRM" \
  || { printf 'КРАСНО: odnoimennoj: строка ci-a неверна (run/wfsha/дерево)\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: odnoimennoj: честный перечень не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
