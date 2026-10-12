#!/usr/bin/env bash
# Клетка Б-3(г) «отсутствующая обязательная проверка при постороннем зелёном
# workflow» (контракт 098, §Инварианты Б-3): в CI зелёный ПОСТОРОННИЙ workflow
# deploy-docs и обязательная ci-b; обязательной ci-a НЕТ. Писатель на чужой
# ключ отказывает именованно («ключ вне обязательных: deploy-docs»), ci-a
# остаётся непокрытой; publish отказывает «нет обязательной проверки: ci-a»,
# target неизменен. Обман (s12: дверь закрывает ключ любым именем) публикует →
# клетка красна. Положительный контроль: ci-a покрыта своим прогоном —
# публикация зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world otsutstvujushaja)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
# посторонний зелёный workflow вместо обязательной ci-a
_d98_ci "$W" "$M" ci-b:success deploy-docs:success
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"
printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"

_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
  || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: check-писатель отказал на покрытой ci-b\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" deploy-docs 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'ключ вне обязательных: deploy-docs'; then
  printf 'КРАСНО: otsutstvujushaja-objazatelnaja: посторонний ключ принят писателем (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(awk -F'\t' -v o="$OID" -v nm=deploy-docs '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: посторонний ключ записан строкой check\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
  || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: verdict-писатель отказал\n' >&2; exit 1; }
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
  || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: policy-писатель отказал\n' >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: otsutstvujushaja-objazatelnaja: посторонний зелёный закрыл обязательную (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: отказ записал published\n' >&2; exit 1; }

# положительный контроль: ci-a покрыта СВОИМ прогоном → публикация
_d98_ci "$W" "$M" ci-a:success
_d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a \
  || { printf 'КРАСНО: otsutstvujushaja-objazatelnaja: check-писатель отказал на ci-a\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: otsutstvujushaja-objazatelnaja: полный перечень не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
