#!/usr/bin/env bash
# Клетка Б-5/решение 2 «прогон не того коммита» (контракт 098, §Инварианты
# Б-5 — происхождение одноимённого прогона; блокер адверсария A-098-1,
# verdicts/adversary/contracts-098-v1.md): в ответе CI для M одноимённый
# ЗЕЛЁНЫЙ прогон доверенной обвязки с доверенной версией определения несёт
# head_sha ДРУГОГО существующего коммита (B ≠ M) — писатель обязан
# отказаться «прогон не того коммита: ci-a» (rc 1) и НЕ записать строку
# check: журнал утверждал бы дерево M^{tree}, а предъявленный прогон
# исполнил дерево B — «правильный ответ не на тот вопрос» ломает Б-5.
# Обман (s18: разбор head_sha подменён аргументом M — дословный обход
# адверсария) принимает B-прогон за доказательство M → клетка красна.
# Парный положительный контроль: тот же прогон с head_sha == M — строка
# записана, полный перечень публикует (позитив не сломан).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: progon-ne-togo-kommita: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world progon-ne-togo)" || exit 2
trap '_d98_cleanup "${W:-}"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/prinyato" HEAD ci-a)"
CIAPP="$(_d98_ciapp "$W/repo" "$B")"
[ -n "$CIAPP" ] || { printf 'КРАСНО: progon-ne-togo-kommita: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
[ "$B" != "$M" ] || { printf 'КРАСНО: progon-ne-togo-kommita: мир неконформен — B совпал с M\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# предъявление: зелёный одноимённый доверенный ci-a НА КОММИТЕ B (существует
# в repo), файл ответа CI для B обслуживает запрос по URL M — расходение с M
# ТОЛЬКО в поле head_sha, остальные поля конформны (иначе клетка краснела бы
# чужой ветвью и не доказывала своё свойство)
_d98_ci "$W" "$B" ci-a:success
cp "$W/fake/checkruns/$B.json" "$W/fake/checkruns/$M.json"
jq -e --arg app "$CIAPP" --arg w "$WFA" --arg b "$B" --arg m "$M" '
  .total_count==1 and (.check_runs[0] | .name=="ci-a" and .conclusion=="success"
    and .app.slug==$app and .wfsha==$w and .head_sha==$b and .head_sha!=$m)' \
  "$W/fake/checkruns/$M.json" >/dev/null \
  || { printf 'КРАСНО: progon-ne-togo-kommita: мир неконформен — предъявление расходится с M только head_sha\n' >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'прогон не того коммита: ci-a'; then
  printf 'КРАСНО: progon-ne-togo-kommita: прогон чужого коммита принят как доказательство M (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: progon-ne-togo-kommita: прогон чужого коммита записан строкой ci-a\n' >&2; exit 1; }

# парный положительный контроль: тот же зелёный прогон на head_sha == M —
# строка записана, полный перечень публикует
_d98_ci "$W" "$M" ci-a:success ci-b:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: progon-ne-togo-kommita: check-писатель отказал на честной ci-a\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$TRM" \
  || { printf 'КРАСНО: progon-ne-togo-kommita: строка ci-a неверна (run/wfsha/дерево)\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: progon-ne-togo-kommita: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: progon-ne-togo-kommita: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: progon-ne-togo-kommita: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: progon-ne-togo-kommita: честный перечень не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
