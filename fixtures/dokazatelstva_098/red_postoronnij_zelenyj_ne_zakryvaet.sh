#!/usr/bin/env bash
# Клетка Б-5 «структурное сопоставление» (контракт 098, §Инварианты Б-5,
# гашение Р4-3в): посторонний зелёный джоб «ci-a-postoronnij» (имя СОДЕРЖИТ
# ключ как подстрока) не закрывает НИ ОДИН обязательный ключ: check-писатель на
# ci-a отказывает «нет обязательной проверки: ci-a» и строки не пишет; дверь на
# непокрытом перечне отказывает той же фразой. Н-204: красный прогон под своим
# именем — «обязательная проверка красна: ci-a», не молчание. Обман (s4:
# подстрока display-имени — источник истины) пишет строку и публикует → клетка
# красна. Положительный контроль: свой зелёный прогон под ЛИТЕРАЛЬНЫМ именем —
# строка записана, публикация зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: postoronnij-zelenyj: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world postoronnij)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
TRM="$(_d98_tree "$W/repo" "$M")"; WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"

# подстрочная ловушка: зелёный джоб «ci-a-postoronnij», обязательного ci-a НЕТ
_d98_ci "$W" "$M" ci-a-postoronnij:success ci-b:success
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: postoronnij-zelenyj: подстрочное имя закрыло ключ (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: postoronnij-zelenyj: подстрочный прогон записан строкой ci-a\n' >&2; exit 1; }

# Н-204: красный прогон под своим именем — не молчание
_d98_ci "$W" "$M" ci-a:failure ci-b:success
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'обязательная проверка красна: ci-a'; then
  printf 'КРАСНО: postoronnij-zelenyj: красный прогон под своим именем замолчан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# дверь: перечень непокрыт (ci-a нет) — отказ, даже когда ci-b зелёная и своя
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: postoronnij-zelenyj: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: postoronnij-zelenyj: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: postoronnij-zelenyj: policy-писатель отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: postoronnij-zelenyj: дверь закрыла ключ посторонним именем (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: postoronnij-zelenyj: отказ сдвинул main\n' >&2; exit 1; }

# положительный контроль: свой зелёный прогон под литеральным именем
_d98_ci "$W" "$M" ci-a:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: postoronnij-zelenyj: check-писатель отказал на честной ci-a\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$TRM" \
  || { printf 'КРАСНО: postoronnij-zelenyj: строка ci-a неверна (дерево/wfsha/run)\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: postoronnij-zelenyj: честный перечень не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
