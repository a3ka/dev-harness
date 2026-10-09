#!/usr/bin/env bash
# Клетка И-7 «reviewer получает фактически выданное задание» / «автор и судья
# независимы по фактическому прогону» (контракт 095, Выход п.5). (а) reviewer
# без --task-file — именованный отказ; (б) TASK-секция несёт sha256 байтов
# задания, вычисленный проверяющим ДО вызова (правило 8), и текст ПОБАЙТОВО
# равен файлу. Обман (s7: текст пересобирается по контракту) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: revjer-poluchaet-vydannoe: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i7)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" reviewer glm-4.7 allowed

# (а) без выданного задания — отказ
out0="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc0=$?
if [ "$rc0" -ne 1 ] || ! printf '%s\n' "$out0" | grep -Fq 'ОТКАЗ: нет выданного задания: 777'; then
  printf 'КРАСНО: i7: reviewer без задания не отказан именем (rc=%s, вывод: %s)\n' "$rc0" "$out0" >&2; exit 1
fi

# (б) оракул ДО вызова: sha256 байтов файла задания — в память
WANT_SHA="$(sha256sum < "$W/task.md" | cut -d' ' -f1)"
out="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --task-file "$W/task.md" --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i7: reviewer-пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq "TASK: sha256=$WANT_SHA" || { printf 'КРАСНО: i7: sha256 выданного задания разошёлся (ждали %s)\n' "$WANT_SHA" >&2; exit 1; }
body="$(printf '%s\n' "$out" | sed -n '/^=== TASK ===$/,/^=== MANIFEST ===$/{//!p}' | tail -n +2)"
[ "$body" = "$(cat "$W/task.md")" ] || { printf 'КРАСНО: i7: текст задания в паке не побайтов равен выданному\n' >&2; exit 1; }
exit 0
