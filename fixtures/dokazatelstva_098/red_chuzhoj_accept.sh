#!/usr/bin/env bash
# Клетка Б-3(а) «чужой accept» (контракт 098, §Инварианты Б-3): судья принял
# объект A (verdict-писатель записал accept для oid A), публикация готовится по
# объекту B (кандидат сдвинулся, пере-prepare, полный журнал для B) — дверь
# отказывает «accept не этого объекта: T-1», target неизменен, строк published
# нет. Положительный контроль: accept ровно объекта B (событием судьи, более
# новый seq) — публикация зелёная. Стабы s1/s6 (потеря привязки/исхода) ловятся
# клетками red_polnyj_zhurnal_shtatno / red_pozdnij_fail; здесь честная дверь
# обязана различать объекты.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: chuzhoj-accept: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world chuzhoj)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C1 M1 OID1 <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
printf 'accept\n' >"$W/verdikt-A.md"

# судья принял объект A
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M1" --verdict-row T-1 "$OID1" "$W/verdikt-A.md" \
  || { printf 'КРАСНО: chuzhoj-accept: verdict-писатель отказал для объекта A\n' >&2; exit 1; }

# кандидат сдвинулся — объект B той же задачи
C2="$(_d98_cand_commit "$W/repo" file.txt 'cand2')" || exit 2
pc2="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B2 C2b M2 OID2 <<<"$pc2"
[ "$B2" = "$B" ] && [ "$C2b" = "$C2" ] || { printf 'КРАСНО: chuzhoj-accept: мир неконформен — base/кандидат ушли\n' >&2; exit 1; }
PVB="$(_d98_pv "$W/repo" "$B")"; PVC2="$(_d98_pv "$W/repo" "$C2")"
printf 'accept\n' >"$W/sankcia-B.md"
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M2" --check-row "$OID2" ci-a \
  || { printf 'КРАСНО: chuzhoj-accept: check-писатель отказал для объекта B\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M2" --check-row "$OID2" ci-b \
  || { printf 'КРАСНО: chuzhoj-accept: check-писатель отказал для объекта B\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M2" --policy-row "$OID2" "$PVB" "$PVC2" "$W/sankcia-B.md" \
  || { printf 'КРАСНО: chuzhoj-accept: policy-писатель отказал для объекта B\n' >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C2" --merge "$M2" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'accept не этого объекта: T-1'; then
  printf 'КРАСНО: chuzhoj-accept: чужой accept принят (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: chuzhoj-accept: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: chuzhoj-accept: отказ записал published\n' >&2; exit 1; }

# положительный контроль: accept ровно объекта B событием судьи → публикация
printf 'accept\n' >"$W/verdikt-B.md"
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M2" --verdict-row T-1 "$OID2" "$W/verdikt-B.md" \
  || { printf 'КРАСНО: chuzhoj-accept: verdict-писатель отказал для объекта B\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C2" --merge "$M2" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M2"; then
  printf 'КРАСНО: chuzhoj-accept: свой accept не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
