#!/usr/bin/env bash
# Клетка А-7 «identity и санкции подготовки» (контракт 097: 016 + 065 И-10 в
# объёме подготовки): merge-коммит prepare — автор и коммиттер
# orchestrator <orchestrator@dev-harness.local> (identity 016, проверяемо
# моделью); строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ:/ALLOW-ARTIFACT-DELETE: диапазона
# base..candidate перенесены в сообщение merge ДОСЛОВНО, точные повторы
# дедуплицированы (065 И-10 — семантика субъекта 097 СВЕРХ грамматики модели
# dover.sh: проба санкций исполняется ТОЛЬКО в real-режиме, в модельном
# пропускается с этой пометкой). Обман — t97-m9 (автор не orchestrator),
# t97-m10 (коммиттер не orchestrator).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: identity-i-sankcii-podgotovki: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }
MODE="$(_t97_mode)"

W="$(_t97_world_project a7)" || exit 2
trap '_t97_cleanup "$W"' EXIT
R="$W/repo"
BASE="$(git -C "$R" rev-parse main)"
MAIN_BEFORE="$(git -C "$R" rev-parse refs/heads/main)"

# диапазон base..candidate с дословными санкциями; РАЗРЕШИЛ-строка — точный повтор
git -C "$R" checkout -q cand
printf 'sanction-one\n' >>"$R/file.txt"
git -C "$R" add -A
git -C "$R" commit -qm 'c1
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: допуск 097-пробы выдан владельцем 2026-10-12
ALLOW-ARTIFACT-DELETE: tmp/prepare-object-097'
printf 'sanction-two\n' >>"$R/file.txt"
git -C "$R" add -A
git -C "$R" commit -qm 'c2
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: допуск 097-пробы выдан владельцем 2026-10-12'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"

M="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND")"; rc=$?
case "$M" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a7: prepare не напечатал merge sha (rc=%s, вывод=%s)\n' "$rc" "$M" >&2; exit 1 ;; esac
[ "${#M}" -eq 40 ] || { printf 'КРАСНО: a7: prepare напечатал не 40 hex: %s\n' "$M" >&2; exit 1; }

idc="$(git -C "$R" show -s --format='%an
%ae
%cn
%ce' "$M")"
[ "$idc" = "orchestrator
orchestrator@dev-harness.local
orchestrator
orchestrator@dev-harness.local" ] || {
  printf 'КРАСНО: a7: identity merge нарушен (016): %s\n' "$idc" >&2; exit 1; }

[ "$(git -C "$R" rev-parse refs/heads/main)" = "$MAIN_BEFORE" ] || { printf 'КРАСНО: a7: prepare двинул main\n' >&2; exit 1; }

# перенос санкций — только реальный субъект (семантика 097 сверх модели)
if [ "$MODE" = real ]; then
  msg="$(git -C "$R" show -s --format=%B "$M")"
  printf '%s\n' "$msg" | grep -Fxq 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: допуск 097-пробы выдан владельцем 2026-10-12' \
    || { printf 'КРАСНО: a7: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ диапазона не перенесена в merge дословно\n' >&2; exit 1; }
  [ "$(printf '%s\n' "$msg" | grep -Fxc 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: допуск 097-пробы выдан владельцем 2026-10-12')" -eq 1 ] \
    || { printf 'КРАСНО: a7: дедуп точных повторов РАЗРЕШИЛ-строки нарушен\n' >&2; exit 1; }
  printf '%s\n' "$msg" | grep -Fxq 'ALLOW-ARTIFACT-DELETE: tmp/prepare-object-097' \
    || { printf 'КРАСНО: a7: строка ALLOW-ARTIFACT-DELETE диапазона не перенесена в merge дословно\n' >&2; exit 1; }
fi
exit 0
