#!/usr/bin/env bash
# Клетка И-5 «зоны из frozen-блоба для исполнительских стадий» (контракт 095,
# состав п.4). Заморозка расходится с черновиком (ЗОНА implementer в теге —
# toy-FROZEN.sh, в рабочем дереве — toy-DRAFT.sh): implementer-пак несёт
# ЗОНА-строку ПОБАЙТОВО из тега (оракул снят в память ДО вызова, правило 8).
# Обман (s5: зоны из черновика) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: zony-iz-frozen-blobs: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i5)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
TAG="$(_t95_freeze "$R" 'scripts/toy-FROZEN.sh')"

# оракул ДО вызова субъекта: ЗОНА-строка замороженного блоба — в память
WANT="$(git -C "$R" show "$TAG:contracts/777-toy.md" | grep '^ЗОНА implementer')"
# черновик расходится с заморозкой (не коммитим — рабочий черновик)
sed -i 's@^ЗОНА implementer: .*@ЗОНА implementer: scripts/toy-DRAFT.sh@' "$R/contracts/777-toy.md"
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed

out="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i5: пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq "$WANT" || { printf 'КРАСНО: i5: ЗОНА-строка не из frozen-блоба (ждали дословно: %s)\n' "$WANT" >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq 'toy-DRAFT.sh'; then
  printf 'КРАСНО: i5: в пак попала ЗОНА-строка черновика вместо заморозки\n' >&2; exit 1
fi
exit 0
