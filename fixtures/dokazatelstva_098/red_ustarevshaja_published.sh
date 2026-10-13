#!/usr/bin/env bash
# Клетка И-9 «устаревшая строка published не есть публикация» (контракт 098,
# И-9 идемпотентность; адверсарий круга implementer A-098-2: батарея испытывала
# повтор только ПОСЛЕ собственного успешного publish, и мутант со снятой
# сверкой refs/heads/<target> == M в ветви «уже опубликовано» проходил всю
# батарею). Полный журнал штатными писателями, ЗАТЕМ до вызова двери в журнал
# ложится конформная строка published этого object_id/M, тогда как target всё
# ещё на B. Дверь обязана отказать «публикация расползлась: ref != merge»:
# rc 1, target остаётся B, НИКАКОГО «УЖЕ ОПУБЛИКОВАНО», журнал не дописан.
# Обман (s19: сверка ref снята) объявляет «УЖЕ ОПУБЛИКОВАНО» с target на B →
# клетка красна. Положительный контроль: та же строка, target уже на M —
# ровно «УЖЕ ОПУБЛИКОВАНО object=<oid> merge=<M>», rc 0, без второй строки.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: ustarevshaja-published: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world ustarpub)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
[ "$B" != "$M" ] || { printf 'КРАСНО: ustarevshaja-published: мир неконформен — B совпал с M\n' >&2; exit 1; }
_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: ustarevshaja-published: писатель отказал (журнал неполон)\n' >&2; exit 1; }
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: ustarevshaja-published: записи доказательства сдвинули main до publish\n' >&2; exit 1; }

# конформная строка published (грамматика субъекта: published\t<oid>\t<merge>\t<seq>,
# seq = seq применимого verdict + 1 — как пишет сама дверь), target всё ещё B
vseq="$(awk -F'\t' -v o="$OID" '$1=="verdict" && $3==o {print $5}' "$J" | sort -n | tail -1)"
case "$vseq" in ''|*[!0-9]*) printf 'КРАСНО: ustarevshaja-published: seq verdict-строки не разобран: %s\n' "$vseq" >&2; exit 1 ;; esac
printf 'published\t%s\t%s\t%s\n' "$OID" "$M" "$((vseq + 1))" >>"$J"
sum0="$(sha256sum "$J" | cut -d' ' -f1)"

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'публикация расползлась: ref != merge'; then
  printf 'КРАСНО: ustarevshaja-published: устаревшая строка published принята за публикацию (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s' "$out" | grep -Fq 'УЖЕ ОПУБЛИКОВАНО' \
  && { printf 'КРАСНО: ustarevshaja-published: ложное «УЖЕ ОПУБЛИКОВАНО» при target на B\n' >&2; exit 1; }
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: ustarevshaja-published: отказ сдвинул main: %s\n' "$(git -C "$W/repo" rev-parse main)" >&2; exit 1; }
[ "$(sha256sum "$J" | cut -d' ' -f1)" = "$sum0" ] \
  || { printf 'КРАСНО: ustarevshaja-published: отказ дописал журнал\n' >&2; exit 1; }

# положительный контроль: та же строка published, target УЖЕ на M —
# честная идемпотентность, второй строки нет, ветка не двигается
git -C "$W/repo" update-ref refs/heads/main "$M" "$B" \
  || { printf 'КРАСНО: ustarevshaja-published: мир не строится — main на M\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || [ "$out" != "УЖЕ ОПУБЛИКОВАНО object=$OID merge=$M" ]; then
  printf 'КРАСНО: ustarevshaja-published: честный повтор при target на M не идемпотентен (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
  || { printf 'КРАСНО: ustarevshaja-published: повтор сдвинул целевую ветку\n' >&2; exit 1; }
[ "$(sha256sum "$J" | cut -d' ' -f1)" = "$sum0" ] \
  || { printf 'КРАСНО: ustarevshaja-published: повтор дописал вторую строку published\n' >&2; exit 1; }
exit 0
