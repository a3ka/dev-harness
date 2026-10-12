#!/usr/bin/env bash
# Клетка Б-6 «журнал вне проверяемой ветки» (контракт 098, §Инварианты Б-6,
# решение 5): после записи ВСЕХ строк доказательств штатными писателями —
# B (base), C (candidate), M (merge) байт-в-байт прежние sha, все refs
# репозитория кандидата неизменны (main на base, kandidat на C, cand/<oid> на
# M); registry/candidates.tsv живёт ТОЛЬКО на принятой стороне, в деревьях
# кандидата и merge его нет. Обман (s8: prepare/дверь трогает refs кандидата)
# — клетка красна именованным отказом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: zhurnal-vne-vetvi: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world vne-vetvi)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"

# оракул в память ДО писателей (правило 8): shas и полный снапшот refs
SNAP="$(git -C "$W/repo" for-each-ref --format='%(refname) %(objectname)' \
  | LC_ALL=C sort)"
J="$W/prinyato/registry/candidates.tsv"

_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: zhurnal-vne-vetvi: писатель отказал (строки не записаны)\n' >&2; exit 1; }

# B/C/M байт-в-байт прежние
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: zhurnal-vne-vetvi: base сдвинулся записью доказательств: main=%s\n' "$(git -C "$W/repo" rev-parse main)" >&2; exit 1; }
[ "$(git -C "$W/repo" rev-parse kandidat)" = "$C" ] \
  || { printf 'КРАСНО: zhurnal-vne-vetvi: кандидат сдвинулся записью доказательств\n' >&2; exit 1; }
[ "$(git -C "$W/repo" rev-parse "refs/heads/cand/$OID")" = "$M" ] \
  || { printf 'КРАСНО: zhurnal-vne-vetvi: нецелевая ссылка сдвинулась записью доказательств\n' >&2; exit 1; }
[ "$(git -C "$W/repo" rev-parse "$M^{tree}")" = "$(_d98_tree "$W/repo" "$M")" ] \
  || { printf 'КРАСНО: zhurnal-vne-vetvi: дерево M изменилось (объект не-immutable)\n' >&2; exit 1; }
# полный снапшот refs репозитория кандидата неизменен
NOW="$(git -C "$W/repo" for-each-ref --format='%(refname) %(objectname)' | LC_ALL=C sort)"
[ "$SNAP" = "$NOW" ] \
  || { printf 'КРАСНО: zhurnal-vne-vetvi: refs репозитория кандидата изменились при записи доказательств\n%s\n%s\n' "$SNAP" "$NOW" >&2; exit 1; }

# журнал живёт на принятой стороне; в деревьях кандидата/merge его нет
[ -f "$J" ] || { printf 'КРАСНО: zhurnal-vne-vetvi: журнала нет на принятой стороне\n' >&2; exit 1; }
t="$(git -C "$W/repo" ls-tree "$M" -- registry/candidates.tsv)"
[ -z "$t" ] || { printf 'КРАСНО: zhurnal-vne-vetvi: журнал в дереве merge: %s\n' "$t" >&2; exit 1; }
t="$(git -C "$W/repo" ls-tree "$C" -- registry/candidates.tsv)"
[ -z "$t" ] || { printf 'КРАСНО: zhurnal-vne-vetvi: журнал в дереве кандидата: %s\n' "$t" >&2; exit 1; }
n="$(wc -l <"$J")"
[ "$n" -eq 4 ] || { printf 'КРАСНО: zhurnal-vne-vetvi: в журнале %s строк, ожидалось 4\n' "$n" >&2; exit 1; }
exit 0
