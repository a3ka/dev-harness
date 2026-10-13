#!/usr/bin/env bash
# Клетка Б-5 «прогон чужого коммита под именем M» (контракт 098, решение 2/Б-5;
# адверсарий круга implementer A-098-1: батарея не предъявляла ответ CI, где
# доверенный зелёный прогон с верными name/app.slug/wfsha стоит на ЧУЖОМ
# коммите — мутант со снятой сверкой head_sha == M проходил всю батарею).
# Ответ CI, запрашиваемый для M, несёт ci-a: success, исполнитель = пин ciApp,
# wfsha = принятая версия, но head_sha = B (base, НЕ M); ci-b честна на M.
# Писатель check обязан отказать «прогон не того коммита: ci-a», строка check
# ci-a НЕ пишется; дверь на неполном перечне — «нет обязательной проверки:
# ci-a», target остаётся B, строк published нет. Обман (s18: сверка head_sha
# снята) пишет строку ci-a как для M → клетка красна. Положительный контроль:
# тот же прогон с head_sha = M — строка записана, публикация зелёная ровно M.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: chuzhoj-head-sha: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world chuzhojhead)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
CIAPP="$(_d98_ciapp "$W/repo" "$B")"
[ -n "$CIAPP" ] || { printf 'КРАСНО: chuzhoj-head-sha: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
[ "$B" != "$M" ] || { printf 'КРАСНО: chuzhoj-head-sha: мир неконформен — B совпал с M\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# ответ для M: ci-a — доверенный зелёный прогон, исполненный на B (head_sha=B);
# ci-b — честная на M. Демаркация: единственное расхождение прогона ci-a с
# честным — head_sha (имя, исполнитель, wfsha сверены с оракулами ДО вызова).
_d98_ci_chuzhoj_head "$W" "$M" "$B" ci-a:success
_d98_ci_add "$W" "$M" ci-b:success
fa="$(jq -r '.check_runs[] | select(.name == "ci-a") | [.head_sha, .app.slug, .wfsha, .conclusion] | join(" ")' "$W/fake/checkruns/$M.json")"
[ "$fa" = "$B $CIAPP $WFA success" ] \
  || { printf 'КРАСНО: chuzhoj-head-sha: мир неконформен — прогон ci-a не «только head_sha чужой»: %s\n' "$fa" >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'прогон не того коммита: ci-a'; then
  printf 'КРАСНО: chuzhoj-head-sha: прогон чужого коммита закрыл ключ ci-a (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: chuzhoj-head-sha: прогон чужого коммита записан строкой ci-a\n' >&2; exit 1; }

# дверь: ci-a не закрыт НИЧЕМ — отказ при честной ci-b, вердикте и санкции
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: chuzhoj-head-sha: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: chuzhoj-head-sha: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: chuzhoj-head-sha: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: chuzhoj-head-sha: дверь опубликовала без ключа ci-a (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: chuzhoj-head-sha: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: chuzhoj-head-sha: отказ записал published\n' >&2; exit 1; }

# положительный контроль: тот же доверенный прогон ci-a, но head_sha = M
_d98_ci "$W" "$M" ci-a:success ci-b:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: chuzhoj-head-sha: check-писатель отказал на честной ci-a (head_sha = M)\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$TRM" \
  || { printf 'КРАСНО: chuzhoj-head-sha: строка ci-a неверна (run/wfsha/дерево)\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: chuzhoj-head-sha: честный перечень не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: chuzhoj-head-sha: публикация не на ЛИТЕРАЛЬНОМ M\n' >&2; exit 1; }
exit 0
