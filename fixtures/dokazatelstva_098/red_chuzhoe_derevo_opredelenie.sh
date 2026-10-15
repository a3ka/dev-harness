#!/usr/bin/env bash
# Клетка Б-3(д) «чужое дерево/определение» (контракт 098, §Инварианты Б-3,
# решение 2): (а) check-писатель вызван с ЧУЖИМ коммитом (CAND вместо M) —
# строка check записана под object_id объекта M с деревом CAND → дверь обязана
# отказать «проверка не того дерева: ci-a»; (б) определение на принятой стороне
# изменено (рабочее дерево, не base), прогон ИСПОЛНИЛ изменённые байты (поле
# wfsha ответа CI = изменённой версии) — для писателя вход конформен (прогон
# соответствует его принятой стороне), строка несёт wfsha изменённой версии →
# дверь обязана отказать «проверка не доверенной версии: ci-b» (судит по base,
# не по локальной доске писателя). Обман (s10/s11: сверки сняты) публикует →
# клетка красна. Положительные контроли: честные строки с БОЛЕЕ НОВЫМИ
# прогонами тех же имён закрывают перечень → публикация зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: chuzhoe-derevo-opredelenie: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world chuzhoe-derevo)" || exit 2
trap '_d98_cleanup "${W:-}"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRB="$(_d98_tree "$W/repo" "$B")"; TRM="$(_d98_tree "$W/repo" "$M")"
[ "$TRB" != "$TRM" ] || { printf 'КРАСНО: chuzhoe-derevo: мир неконформен — деревья B и M совпадают\n' >&2; exit 1; }
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

# (а) приписывание прогона другого дерева: зелёный ci-a на коммите BASE
_d98_ci "$W" "$B" ci-a:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$B" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: chuzhoe-derevo: check-писатель отказал на чужом дереве (вход легален — дверь судит)\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-a ok "$(_d98_wfsha "$W/prinyato" HEAD ci-a)" "$TRB" \
  || { printf 'КРАСНО: chuzhoe-derevo: строка ci-a несёт не дерево аргумента\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: chuzhoe-derevo: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" $(_d98_sud "$W" "$M") \
  || { printf 'КРАСНО: chuzhoe-derevo: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: chuzhoe-derevo: policy-писатель отказал\n' >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка не того дерева: ci-a'; then
  printf 'КРАСНО: chuzhoe-derevo: чужое дерево закрыло обязательную (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: chuzhoe-derevo: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: chuzhoe-derevo: отказ записал published\n' >&2; exit 1; }

# положительный контроль (а): честный ci-a на M с более новым прогоном
_d98_ci "$W" "$M" ci-a:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: chuzhoe-derevo: check-писатель отказал на честной ci-a\n' >&2; exit 1; }

# (б) чужое определение: файл на принятой стороне изменён (не base), прогон
# ИСПОЛНИЛ изменённые байты — wfsha ответа CI = изменённой версии: писатель
# сверяет прогон со СВОЕЙ принятой стороной (совпадает — строка записана),
# дверь судит по base и обязана отказать.
printf ' # izmeneno\n' | tee -a "$W/prinyato/harness/checks/ci-b.cmd" >/dev/null
WFB="$(_d98_wfsha "$W/repo" "$B" ci-b)"
WFB2="$(sha256sum <"$W/prinyato/harness/checks/ci-b.cmd" | cut -d' ' -f1)"
[ "$WFB2" != "$WFB" ] || { printf 'КРАСНО: chuzhoe-opredelenie: мир неконформен — wfsha не разошлись\n' >&2; exit 1; }
_d98_ci "$W" "$M" "ci-b:success:~$WFB2"
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: chuzhoe-opredelenie: check-писатель отказал на прогоне изменённого определения (вход легален — дверь судит)\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-b ok "$WFB2" "$TRM" \
  || { printf 'КРАСНО: chuzhoe-opredelenie: строка ci-b несёт не wfsha прогона\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка не доверенной версии: ci-b'; then
  printf 'КРАСНО: chuzhoe-opredelenie: чужая версия определения закрыла обязательную (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: chuzhoe-opredelenie: отказ сдвинул main\n' >&2; exit 1; }

# положительный контроль (б): доверенная версия восстановлена, более новый прогон
git -C "$W/prinyato" checkout -q -- harness/checks/ci-b.cmd
_d98_ci "$W" "$M" ci-b:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: chuzhoe-opredelenie: check-писатель отказал на доверенной ci-b\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: chuzhoe-opredelenie: честный перечень не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
