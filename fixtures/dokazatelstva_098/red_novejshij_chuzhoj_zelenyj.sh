#!/usr/bin/env bash
# Клетка Б-5/решение 2 «новейший чужой зелёный не отступает к старому валидному»
# (контракт 098, §Инварианты Б-5 — отбор прогона; блокер адверсария A-098-2,
# verdicts/adversary/contracts-098-v2.md): в ответе CI для M — ПОЛНОСТЬЮ валидная
# зелёная история ключа (ci-a run=1: доверенные обвязка и версия, head_sha=M) и
# НОВЕЙШИЙ одноимённый ЗЕЛЁНЫЙ прогон ЧУЖОГО происхождения (run=3: обвязка
# @foreign-ci ≠ ciApp; версия доверенная; head_sha=M — расходение с валидным
# РОВНО в происхождении). Отбор — ПОСЛЕДНИЙ одноимённый по id (решение 2;
# «перебор до подходящего» — обход): писатель обязан судить НОВЕЙШИЙ прогон и
# отказаться «проверка чужой обвязки: ci-a» (rc 1) БЕЗ записи check-строки —
# ok-строка СТАРОГО run=1 сертифицировала бы ПРОШЛОЕ состояние ключа, тогда
# как судится НАСТОЯЩЕЕ (арбитраж 098, симметрично «поздний красный перекрывает
# прежний ok»). Обман (s19: селекция «зелёный чужой новейший → отступить на
# последний полностью валидный» — дословный обходчик M7 адверсария) пишет
# ok run=1 и публикует M → клетка красна. Дверь: без строки ci-a полный
# перечень не публикует («нет обязательной проверки: ci-a»), main неизменен.
# Парный положительный контроль: новейший зелёный ВАЛИДЕН — ok-строка с run
# НОВОГО прогона (не старого), публикация ровно M.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world novejshij-chuzhoj)" || exit 2
trap '_d98_cleanup "${W:-}"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
CIAPP="$(_d98_ciapp "$W/repo" "$B")"
[ -n "$CIAPP" ] || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# предъявление: к валидной зелёной истории ключа (podgotovka: ci-a run=1)
# добавлен НОВЕЙШИЙ зелёный одноимённый прогон ЧУЖОЙ обвязки (run=3:
# app.slug≠ciApp, wfsha доверенная, head_sha=M — как в пробе адверсария)
_d98_ci_add "$W" "$M" "ci-a:success:@foreign-ci"
jq -e --arg app "$CIAPP" --arg w "$WFA" --arg m "$M" '
  ([.check_runs[] | select(.name == "ci-a")] | length) == 2
  and ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last
       | .conclusion == "success" and .head_sha == $m and .app.slug != $app and .wfsha == $w)
  and ([.check_runs[] | select(.name == "ci-a" and .head_sha == $m
       and .app.slug == $app and .wfsha == $w and .conclusion == "success")] | length) == 1' \
  "$W/fake/checkruns/$M.json" >/dev/null \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: мир неконформен — под новейшим чужим зелёным нет ровно одной валидной зелёной истории ci-a\n' >&2; exit 1; }

# писатель обязан судить НОВЕЙШИЙ прогон: именованный отказ происхождения,
# check-строки ci-a НЕТ (ok старого run=1 — обход «перебор до подходящего»)
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка чужой обвязки: ci-a'; then
  printf 'КРАСНО: novejshij-chuzhoj-zelenyj: новейший чужой зелёный не опознан по происхождению — селекция отступила к старому валидному (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: чужой новейший прогон породил check-строку ci-a (строк=%s)\n' "$n" >&2; exit 1; }

# дверь: честные ci-b/verdict/policy; без строки ci-a полный перечень не
# публикует, main неизменен, published нет — сквозной обход M7 пресечён
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: novejshij-chuzhoj-zelenyj: дверь не отказала без строки ci-a (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: отказ записал published\n' >&2; exit 1; }

# парный положительный контроль: НОВЕЙШИЙ зелёный валиден — ok-строка с run
# НОВОГО прогона (не старого run=1), публикация ровно M
_d98_ci_add "$W" "$M" ci-a:success
RUNNEW="$(cat "$W/fake/idseq")"
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: check-писатель отказал на новом валидном success\n' >&2; exit 1; }
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a -v s=ok -v r="$RUNNEW" -v w="$WFA" -v t="$TRM" \
  '$1=="check" && $2==o && $3==nm && $4==s && $5==r && $6==w && $7==t' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: ok-строка записана не с run нового прогона (строк=%s, run нового=%s)\n' "$n" "$RUNNEW" >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: novejshij-chuzhoj-zelenyj: новый валидный success не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: novejshij-chuzhoj-zelenyj: опубликовано не M\n' >&2; exit 1; }
exit 0
