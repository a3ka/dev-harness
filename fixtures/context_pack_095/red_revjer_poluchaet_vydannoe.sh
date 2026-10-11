#!/usr/bin/env bash
# Клетка И-7 «reviewer получает фактически выданное задание» + «автор и судья
# независимы по фактическому прогону» (контракт 095, Выход п.5, круг 2).
# Независимость доказывается СОПОСТАВЛЕНИЕМ фактических свидетельств трассы —
# моделей автора и судьи, не фактом передачи задания (ADR-005: судья — чужого
# СЕМЕЙСТВА; то же семейство → отказ). (а) reviewer без --task-file — именованный
# отказ; (б) судья того же семейства, что автор (glm-4.7 vs glm-5.3) — отказ
# «судья на модели автора: glm»; (в) судья без свидетеля автора — отказ; (г)
# TASK-секция: sha256 и байты задания, снятые в память ДО вызова (правило 8),
# побайтовая сверка с ожиданием И трипвайр неизменности файла после вызова.
# Обманы (s7: пересборка текста; s17: проверка семейств снята) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: revjer-poluchaet-vydannoe: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i7)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null

# честная трасса: автор implementer (glm), судья reviewer (qwen — чужое семейство)
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed
_t95_trace "$W/trace.tsv" reviewer qwen-3.5 allowed

# (а) без выданного задания — отказ
out0="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc0=$?
if [ "$rc0" -ne 1 ] || ! printf '%s\n' "$out0" | grep -Fq 'ОТКАЗ: нет выданного задания: 777'; then
  printf 'КРАСНО: i7: reviewer без задания не отказан именем (rc=%s, вывод: %s)\n' "$rc0" "$out0" >&2; exit 1
fi

# (б) Б2: судья того же СЕМЕЙСТВА, что автор — независимости нет (ADR-005)
printf 'implementer\tglm-4.7\tallowed\nreviewer\tglm-5.3\tallowed\n' >"$W/trace-same.tsv"
out1="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --task-file "$W/task.md" --model-trace "$W/trace-same.tsv" 2>&1)"; rc1=$?
if [ "$rc1" -ne 1 ] || ! printf '%s\n' "$out1" | grep -Fq 'ОТКАЗ: судья на модели автора: glm'; then
  printf 'КРАСНО: i7: судья на модели автора не отказан именем (rc=%s, вывод: %s)\n' "$rc1" "$out1" >&2; exit 1
fi

# (в) судья есть, свидетеля автора в трассе нет — отказ именем автора
printf 'reviewer\tqwen-3.5\tallowed\n' >"$W/trace-noauthor.tsv"
out2="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --task-file "$W/task.md" --model-trace "$W/trace-noauthor.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 1 ] || ! printf '%s\n' "$out2" | grep -Fq 'ОТКАЗ: свидетельство не той роли: implementer'; then
  printf 'КРАСНО: i7: трасса без автора не отказана именем (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi

# (г) Б4: оракул ДО вызова — sha256 И байты задания в память проверяющего
WANT_SHA="$(sha256sum < "$W/task.md" | cut -d' ' -f1)"
WANT_BYTES="$(cat "$W/task.md")"
out="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --task-file "$W/task.md" --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i7: reviewer-пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq "TASK: sha256=$WANT_SHA" || { printf 'КРАСНО: i7: sha256 выданного задания разошёлся (ждали %s)\n' "$WANT_SHA" >&2; exit 1; }
body="$(printf '%s\n' "$out" | sed -n '/^=== TASK ===$/,/^=== MANIFEST ===$/{//!p}' | tail -n +2)"
[ "$body" = "$WANT_BYTES" ] || { printf 'КРАСНО: i7: текст задания в паке не побайтов равен выданному (оракул в памяти ДО вызова)\n' >&2; exit 1; }
# трипвайр: субъект не переписал выданное задание на своей территории
NOW_SHA="$(sha256sum < "$W/task.md" | cut -d' ' -f1)"
[ "$NOW_SHA" = "$WANT_SHA" ] || { printf 'КРАСНО: i7: субъект переписал файл выданного задания (подмена при передаче судье)\n' >&2; exit 1; }
exit 0
