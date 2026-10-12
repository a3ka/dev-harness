#!/usr/bin/env bash
# Клетка КЛЮЧА ПОРЯДКА id↔время (контракт 098, §Инварианты Б-5 — отбор
# прогона; вердикт арбитража 098-a2 «композиции и ключ порядка», Т3):
# ключ селекции — id, закреплён арбитражем (t98-mC7); started_at ответа CI
# (реальное поле GitHub check-runs, которое парсит субъект) ключом селекции
# НЕ является. Предъявление: валидная зелёная история ключа ci-a (обвязка,
# версия, head_sha=M, ПОЗДНЕЕ started_at) и НОВЕЙШИЙ ПО id зелёный одноимённый
# прогон, чужой РОВНО в поле wfsha, с started_at РАНЬШЕ старого валидного —
# инверсия порядка id↔время (jq-контроль мира фиксирует инверсию; строитель
# миров — опциональное поле :^время, без поля прежнее поведение). Писатель
# обязан судить НОВЕЙШИЙ ПО ID и отказаться «проверка не доверенной версии:
# ci-a» (rc 1) БЕЗ записи check-строки — ok-строка СТАРОГО прогона
# сертифицировала бы ПРОШЛОЕ состояние ключа. Обман (s23: селекция
# «последний по started_at» — по ВРЕМЕНИ, не по id; дословный обходчик
# M13time вердикта 098-a2) выбирает старый валидный, пишет ok и публикует
# M → клетка красна. Дверь: без строки ci-a полный перечень не публикует
# («нет обязательной проверки: ci-a»), main неизменен, published нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: ranche-po-vremeni: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world novejshij-ranshe-po-vremeni)" || exit 2
trap '_d98_cleanup "${W:-}"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
CIAPP="$(_d98_ciapp "$W/repo" "$B")"
CHUZHWF="$(printf 'run chuzhoe-opredelenie-ranshe-po-vremeni\n' | sha256sum | cut -d' ' -f1)"
[ -n "$CIAPP" ] || { printf 'КРАСНО: ranche-po-vremeni: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
[ "$CHUZHWF" != "$WFA" ] || { printf 'КРАСНО: ranche-po-vremeni: мир неконформен — чужая wfsha совпала с принятой\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# предъявление: валидная зелёная история с ПОЗДНИМ started_at (ci-a, ci-b) и
# НОВЕЙШИЙ ПО id зелёный одноимённый с чужой wfsha и РАННИМ started_at —
# порядок id↔время инвертирован (время без двоеточий: пара делится по ':')
TPOZD="20261012T120000Z"; TRAN="20261012T090000Z"
_d98_ci "$W" "$M" "ci-a:success:^$TPOZD" "ci-b:success:^$TPOZD"
_d98_ci_add "$W" "$M" "ci-a:success:@$CIAPP:~$CHUZHWF:^$TRAN"
jq -e --arg m "$M" --arg app "$CIAPP" --arg w "$WFA" --arg cw "$CHUZHWF" \
  --arg tp "$TPOZD" --arg tr "$TRAN" '
  ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last) as $n
  | ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | first) as $o
  | ([.check_runs[] | select(.name == "ci-a")] | length) == 2
    and $n.conclusion == "success" and $n.head_sha == $m and $n.app.slug == $app
    and $n.wfsha == $cw and $n.wfsha != $w and $n.started_at == $tr
    and $o.conclusion == "success" and $o.head_sha == $m and $o.app.slug == $app
    and $o.wfsha == $w and $o.started_at == $tp
    and $n.started_at < $o.started_at
    and ([.check_runs[] | select(.name == "ci-a" and .head_sha == $m
         and .app.slug == $app and .wfsha == $w and .conclusion == "success")] | length) == 1' \
  "$W/fake/checkruns/$M.json" >/dev/null \
  || { printf 'КРАСНО: ranche-po-vremeni: мир неконформен — нет инверсии id↔время или валидной зелёной истории ci-a под новейшим\n' >&2; exit 1; }

# писатель обязан судить НОВЕЙШИЙ ПО ID (не по времени): именованный отказ
# поля wfsha, check-строки ci-a НЕТ (ok старого — обход «перебор до
# подходящего» по времени)
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка не доверенной версии: ci-a'; then
  printf 'КРАСНО: ranche-po-vremeni: новейший по id с ранним started_at не опознан по версии — селекция по времени отступила к старому валидному (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: ranche-po-vremeni: новейший по id породил check-строку ci-a (строк=%s)\n' "$n" >&2; exit 1; }

# дверь: честные ci-b/verdict/policy; без строки ci-a полный перечень не
# публикует, main неизменен, published нет
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: ranche-po-vremeni: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: ranche-po-vremeni: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: ranche-po-vremeni: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: ranche-po-vremeni: дверь не отказала без строки ci-a (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: ranche-po-vremeni: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: ranche-po-vremeni: отказ записал published\n' >&2; exit 1; }
exit 0
