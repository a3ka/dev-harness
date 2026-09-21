#!/usr/bin/env bash
# D4 — ПРОВОДКА красна при живом клапанном состоянии: guard-призрак (г1) без
# строки РАЗРЕШИЛ в причине → отказ rc 1 с ПЕРВОЙ причиной барьера в отказе.
# Провокация rc2 (контракт-призрак): прямой канон барьера — rc 2 на
# несуществующем пути (нечем проверить ≠ проверено) — и отказ писателя на
# призраке ДО шага ПРОВОДКИ (§4: незакоммиченность перехватывает призрака
# раньше, НЕ rc 0). End-to-end rc2 у писателя toy-невоспроизводим: все входы,
# где барьер говорит rc 2, отсечены шагами 1–4 писателя (git/HEAD/коммитность);
# ветка «rc2 → отказ rc1 fail-closed» — защитный закон, названный residual.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d4_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT

# Ворот а: красная ПРОВОДКА (guard-призрак), РАЗРЕШИЛА нет.
T="$WORK/t4a"; make_drepo "$T" "$GHOST_PROVODKA"
run_writer "$T" 'prizemlenie bez razreshila'
refuse 'D4a' 'done: ПРОВОДКА красна: проводка: guard-файл не существует: scripts/ghost.sh'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D4a: после отказа записаны done-теги\n' >&2; exit 1; }

# Ворот б-1: канон барьера — призрачный путь даёт rc 2 (не rc 1: нечем проверить).
T="$WORK/t4b"; make_drepo "$T" "$GREEN_PROVODKA"
rc=0; out="$(cd "$T" && bash "$PROVODKA_BARRIER" contracts/404-ghost.md 2>&1)" || rc=$?
[ "$rc" -eq 2 ] || { printf 'ОТКАЗ: D4b-1: барьер на призраке дал rc %s, ожидался 2:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf 'D4b-1: канон rc 2 на призраке жив\n' >&2

# Ворот б-2: писатель на призраке (не закоммичен) — отказ §4, НЕ rc 0.
printf '# kontrakt-prizrak\n' > "$T/contracts/002-ghost.md"
run_writer "$T" 'prizemlenie'
LAST_OUT="$(cd "$T" && bash "$SUBJ" contracts/002-ghost.md 'prizemlenie' 2>&1)"; LAST_RC=$?
refuse 'D4b-2' 'done: контракт не закоммичен на HEAD'
exit 0
