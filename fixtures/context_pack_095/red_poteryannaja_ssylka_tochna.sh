#!/usr/bin/env bash
# Клетка И-3 «потерянная обязательная ссылка даёт точную причину, а не
# молчаливое усечение» (контракт 095, Выход п.3). (а) mandatory-источник
# удалён → rc 1 «источник недоступен: <путь>», stdout БЕЗ пака; (б) исчезнувший
# optional → пак строится (усечение optional легально и не молчит в манифесте:
# строки фрагмента в паке нет). Обман (s3: проверка снята — пак строится по
# усечённой карте) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: poteryannaja-ssylka-tochna: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i3)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# (а) mandatory удалён — именованный отказ, частичного пака нет
rm "$R/DEVELOPMENT.md"
out="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: источник недоступен: DEVELOPMENT.md'; then
  printf 'КРАСНО: i3: потеря mandatory не названа именем (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq '=== make_task'; then
  printf 'КРАСНО: i3: отказ выдал частичный пак (молчаливое усечение)\n' >&2; exit 1
fi

# (б) optional отсутствует (в базовом мире его нет) — пак строится
printf '# Правила кодинга toy\nПиши скучно.\n' >"$R/DEVELOPMENT.md"
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 0 ]; then
  printf 'КРАСНО: i3: optional-пропуск не легален (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
if printf '%s\n' "$out2" | grep -Fq 'HARNESS-LEGACY.md'; then
  printf 'КРАСНО: i3: исчезнувший optional попал в пак\n' >&2; exit 1
fi
exit 0
