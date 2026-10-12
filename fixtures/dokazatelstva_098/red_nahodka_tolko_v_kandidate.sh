#!/usr/bin/env bash
# Клетка Б-3(в) «находка только в кандидате» (контракт 098, §Инварианты Б-3):
# в ДЕРЕВЕ кандидата (и только в нём — base чист) лежит открытая находка
# .review/nahodka.md со строкой «status: ready»; полный журнал штатными
# писателями; publish отказывает «открытая находка в кандидате: <путь>»,
# target неизменен. Положительный контроль: находка закрыта в кандидате
# (status: closed, новый объект) — публикация зелёная.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: nahodka-v-kandidate: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world nahodka)" || exit 2
trap '_d98_cleanup "${W:-}"' EXIT
# находка ДО подготовки: попадает в дерево кандидата (и merge), base чист
C0="$(_d98_cand_commit "$W/repo" .review/nahodka.md 'status: ready')" || exit 2
git -C "$W/repo" show "$C0:.review/nahodka.md" | grep -Fxq 'status: ready' \
  || { printf 'КРАСНО: nahodka-v-kandidate: мир неконформен — находки нет в кандидате\n' >&2; exit 1; }
git -C "$W/repo" cat-file -e "$(git -C "$W/repo" rev-parse main):.review/nahodka.md" 2>/dev/null \
  && { printf 'КРАСНО: nahodka-v-kandidate: мир неконформен — находка есть в base\n' >&2; exit 1; }

pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: nahodka-v-kandidate: писатель отказал (журнал неполон)\n' >&2; exit 1; }

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'открытая находка в кандидате: .review/nahodka.md'; then
  printf 'КРАСНО: nahodka-v-kandidate: открытая находка не остановила публикацию (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: nahodka-v-kandidate: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: nahodka-v-kandidate: отказ записал published\n' >&2; exit 1; }

# положительный контроль: находка закрыта в кандидате — новый объект, публикация
C2="$(_d98_cand_rewrite "$W/repo" .review/nahodka.md 'status: closed')" || exit 2
pc2="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B2 C2b M2 OID2 <<<"$pc2"
[ "$B2" = "$B" ] && [ "$C2b" = "$C2" ] || { printf 'КРАСНО: nahodka-v-kandidate: мир неконформен — кандидат ушёл мимо\n' >&2; exit 1; }
_d98_dokazatelstva "$W" T-1 "$B" "$C2" "$M2" "$OID2" \
  || { printf 'КРАСНО: nahodka-v-kandidate: писатель отказал (второй объект)\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C2" --merge "$M2" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M2"; then
  printf 'КРАСНО: nahodka-v-kandidate: закрытая находка не публикуется (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
