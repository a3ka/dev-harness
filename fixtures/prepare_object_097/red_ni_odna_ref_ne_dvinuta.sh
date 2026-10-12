#!/usr/bin/env bash
# Клетка А-8 «подготовка не трогает ни одной ref — определение и два
# наблюдателя» (контракт 097, арбитраж contracts-097-refs-v1 п.5а): refs =
# всё, что перечисляет for-each-ref, плюс HEAD; состояние ref = тройка (имя,
# objectname, цель symref). «Не трогает» = за вызов prepare НИ ОДНОЙ
# транзакции над refs (хук reference-transaction мира с калибровкой, наблюд
# (1)) И снимок refs+symref+HEAD до == после байт-в-байт (наблюдатель (2));
# rc 0 успеха сверен ЯВНО (замер 6 арбитража); merge sha напечатан; пустая
# выборка refs красна. Мир несёт нетривиальные нецелевые ref: аннотированный
# тег-объект, лёгкий тег с OID ветки, тег кандидата, нецелевая ветка.
# Какая порча ловится этой клеткой — привязка в battery_stubs.sh (Н-39).
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
# не коммит), лёгкий тег с OID ветки, тег кандидата, нецелевая ветка
git -C "$R" tag -a -m v0 v0-base "$BASE" 2>/dev/null     || { printf 'КРАСНО: a8: мир не строится (аннотированный тег)\n' >&2; exit 1; }
git -C "$R" tag light-base "$BASE" 2>/dev/null           || { printf 'КРАСНО: a8: мир не строится (лёгкий тег)\n' >&2; exit 1; }
git -C "$R" tag cand-tag "$CAND" 2>/dev/null             || { printf 'КРАСНО: a8: мир не строится (тег кандидата)\n' >&2; exit 1; }
git -C "$R" branch aux/non-target "$BASE" 2>/dev/null    || { printf 'КРАСНО: a8: мир не строится (нецелевая ветка)\n' >&2; exit 1; }

[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: a8: мир не чист до пробы\n' >&2; exit 1; }

_t97_refs_arm "$R" || exit 2
refs_before="$(_t97_refs_snap "$R")" || exit 2

M="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND")"; rc=$?
[ "$rc" -eq 0 ] || { printf 'КРАСНО: a8: prepare не дал rc 0 (rc=%s, вывод=%s)\n' "$rc" "$M" >&2; exit 1; }
case "$M" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a8: prepare не напечатал merge sha (rc=%s, вывод=%s)\n' "$rc" "$M" >&2; exit 1 ;; esac
[ "${#M}" -eq 40 ] || { printf 'КРАСНО: a8: prepare напечатал не 40 hex: %s\n' "$M" >&2; exit 1; }

_t97_refs_check "$R" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: a8: рабочий каталог не чист после prepare\n' >&2; exit 1; }
exit 0
