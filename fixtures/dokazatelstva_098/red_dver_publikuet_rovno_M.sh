#!/usr/bin/env bash
# Клетка Б-2 «дверь публикует ровно M (репетиция)» (контракт 098, решение 6):
# изолированная копия (весь мир — /tmp/dev-harness-verify/dokazatelstva-098-**,
# credential публикации не задействованы), полный журнал штатными писателями →
# publish --candidate-ref → rc 0 «PUBLISHED», целевая ветка КОПИИ на
# ЛИТЕРАЛЬНОМ sha подготовленного merge; повтор — «УЖЕ ОПУБЛИКОВАНО» без
# второго движения. Обман (s9: дверь ставит целевую ветку на CAND) — клетка
# красна именованным отказом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: dver-publikuet-M: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world repeticija)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: dver-publikuet-M: писатель отказал (журнал неполон)\n' >&2; exit 1; }

[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: dver-publikuet-M: записи доказательства сдвинули main до publish\n' >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: dver-publikuet-M: publish не зелёный (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: dver-publikuet-M: целевая ветка не на ЛИТЕРАЛЬНОМ M: %s\n' "$(git -C "$W/repo" rev-parse main)" >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "УЖЕ ОПУБЛИКОВАНО object=$OID merge=$M"; then
  printf 'КРАСНО: dver-publikuet-M: повтор не идемпотентен (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: dver-publikuet-M: повтор сдвинул целевую ветку\n' >&2; exit 1; }
exit 0
