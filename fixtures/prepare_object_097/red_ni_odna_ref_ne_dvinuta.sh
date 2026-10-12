#!/usr/bin/env bash
# Клетка А-8 «подготовка не двигает НИ ОДНОЙ ref» (контракт 097, §Предмет
# строка «target НЕ двигается: prepare не трогает ни одной ref» — обход
# критика v2: честная подготовка + create refs/tags/097-prepared проходила
# клетки, проверявшие только refs/heads/main). Полное пространство refs
# (имя+sha КАЖДОЙ ref: ветки, теги, remotes) снимается в память ДО вызова
# субъекта (правило 8) и сверяется байт-в-байт ПОСЛЕ УСПЕШНОГО prepare: ни
# одна ref не создана, не двинута, не удалена. Мир несёт нетривиальные
# нецелевые ref (аннотированный тег-объект, лёгкий тег, тег кандидата,
# нецелевая ветка) — чтобы «ни одной» не было вакуумной проверкой одного
# main. Успех prepare сверен ДО сравнения refs: отказавший субъект не
# бывает зелёным молча (пустая выборка refs красна).
# Обман: t97-m11 (prepare поверх честной работы создаёт нецелевую
# refs/tags/097-prepared — точный обход критика v2).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: ni-odna-ref-ne-dvinuta: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t97_world_harness a8)" || exit 2
trap '_t97_cleanup "$W"' EXIT
R="$W/repo"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"

# нетривиальное пространство refs ДО пробы: аннотированный тег (объект-тег,
# не коммит), лёгкий тег, тег кандидата, нецелевая ветка
git -C "$R" tag -a -m v0 v0-base "$BASE" 2>/dev/null     || { printf 'КРАСНО: a8: мир не строится (аннотированный тег)\n' >&2; exit 1; }
git -C "$R" tag light-base "$BASE" 2>/dev/null           || { printf 'КРАСНО: a8: мир не строится (лёгкий тег)\n' >&2; exit 1; }
git -C "$R" tag cand-tag "$CAND" 2>/dev/null             || { printf 'КРАСНО: a8: мир не строится (тег кандидата)\n' >&2; exit 1; }
git -C "$R" branch aux/non-target "$BASE" 2>/dev/null    || { printf 'КРАСНО: a8: мир не строится (нецелевая ветка)\n' >&2; exit 1; }

REFS_BEFORE="$(git -C "$R" for-each-ref --format='%(refname) %(objectname)')"
[ -n "$REFS_BEFORE" ] || { printf 'КРАСНО: a8: пустая выборка refs до пробы — сверять нечего\n' >&2; exit 1; }
HEAD_BEFORE="$(git -C "$R" rev-parse HEAD)"
[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: a8: мир не чист до пробы\n' >&2; exit 1; }

M="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND")"; rc=$?
case "$M" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a8: prepare не напечатал merge sha (rc=%s, вывод=%s)\n' "$rc" "$M" >&2; exit 1 ;; esac
[ "${#M}" -eq 40 ] || { printf 'КРАСНО: a8: prepare напечатал не 40 hex: %s\n' "$M" >&2; exit 1; }

REFS_AFTER="$(git -C "$R" for-each-ref --format='%(refname) %(objectname)')"
[ -n "$REFS_AFTER" ] || { printf 'КРАСНО: a8: пустая выборка refs после пробы — сверять нечего\n' >&2; exit 1; }
if [ "$REFS_AFTER" != "$REFS_BEFORE" ]; then
  printf 'КРАСНО: a8: prepare двинул/создал ref — пространство refs изменилось (обещание «не трогает ни одной ref»):\n' >&2
  printf 'ДО:\n%s\nПОСЛЕ:\n%s\n' "$REFS_BEFORE" "$REFS_AFTER" >&2
  exit 1
fi
[ "$(git -C "$R" rev-parse HEAD)" = "$HEAD_BEFORE" ] || {
  printf 'КРАСНО: a8: prepare двинул HEAD (было %s, стало %s)\n' "$HEAD_BEFORE" "$(git -C "$R" rev-parse HEAD)" >&2; exit 1; }
[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: a8: рабочий каталог не чист после prepare\n' >&2; exit 1; }
exit 0
