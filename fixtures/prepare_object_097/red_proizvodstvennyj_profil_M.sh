#!/usr/bin/env bash
# Клетка А-3 «производственный профиль готовит M, target не двинут» (контракт
# 097, §Предмет): prepare на профиле харнеса (носитель — реестр на base) →
# rc 0 (сверен ЯВНО ДО приёма stdout — вердикт адверсария v3 А-1/А-2),
# напечатан merge sha; родители merge = base+cand; refs/heads/main
# байт-в-байт не тронут; строк журнала не добавлено (registry/candidates.tsv
# не создан); рабочий каталог чист.
# Обман: t97-m3 (merge sha не печатается), t97-m4 (родитель кандидата
# потерян), t97-m5 (prepare двигает target), t97-m22 (rc успешного prepare
# подменён на 1 при корректном stdout).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: proizvodstvennyj-profil-M: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t97_world_harness a3)" || exit 2
trap '_t97_cleanup "$W"' EXIT
R="$W/repo"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
MAIN_BEFORE="$(git -C "$R" rev-parse refs/heads/main)"
[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: a3: мир не чист до пробы\n' >&2; exit 1; }

_t97_refs_arm "$R" || exit 2
refs_before="$(_t97_refs_snap "$R")" || exit 2
M="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND")"; rc=$?
_t97_refs_check "$R" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
[ "$rc" -eq 0 ] || { printf 'КРАСНО: a3: успешный prepare вернул rc=%s — rc-подмена подготовки (стаб m22; вывод=%s)\n' "$rc" "$M" >&2; exit 1; }
case "$M" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a3: prepare не напечатал merge sha (rc=%s, вывод=%s)\n' "$rc" "$M" >&2; exit 1 ;; esac
[ "${#M}" -eq 40 ] || { printf 'КРАСНО: a3: prepare напечатал не 40 hex: %s\n' "$M" >&2; exit 1; }

pp="$(git -C "$R" show -s --format=%P "$M")"
[ "$pp" = "$BASE $CAND" ] || { printf 'КРАСНО: a3: merge не этого объекта: родители %s\n' "$pp" >&2; exit 1; }

[ "$(git -C "$R" rev-parse refs/heads/main)" = "$MAIN_BEFORE" ] || {
  printf 'КРАСНО: a3: prepare двинул target (было %s, стало %s)\n' "$MAIN_BEFORE" "$(git -C "$R" rev-parse refs/heads/main)" >&2; exit 1; }

[ ! -e "$R/registry/candidates.tsv" ] || { printf 'КРАСНО: a3: подготовка добавила строки журнала (registry/candidates.tsv создан)\n' >&2; exit 1; }

[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: a3: рабочий каталог не чист после prepare\n' >&2; exit 1; }
exit 0
