#!/usr/bin/env bash
# Клетка И-1 «реальный запуск в репозитории проекта получает его правила,
# а не контекст харнеса» (контракт 095, Выход п.1). Toy-проект с картой:
# RULES-секция несёт ТОЛЬКО правила проекта (DEVELOPMENT.md); харнесовские
# документы (AGENTS.md, CODING-STANDARDS.md) в паке отсутствуют дословно.
# Половина (б): карта отсутствует — именованный отказ, не пустой пак.
# Обман (s1: харнесовские правила вклеиваются всегда) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pravila-proekta-ne-harsa: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i1)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

out="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i1: честный пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq 'RULES: DEVELOPMENT.md' || { printf 'КРАСНО: i1: правила проекта не в паке\n' >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq 'AGENTS.md'; then
  printf 'КРАСНО: i1: в пак проекта попал харнесовский AGENTS.md\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'CODING-STANDARDS.md'; then
  printf 'КРАСНО: i1: в пак проекта попал харнесовский CODING-STANDARDS.md\n' >&2; exit 1
fi

# (б) карта отсутствует — точная причина, не пустая выдача
rm "$R/harness/context-map"
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 1 ] || ! printf '%s\n' "$out2" | grep -Fq 'ОТКАЗ: нет карты контекста: harness/context-map'; then
  printf 'КРАСНО: i1: потеря карты не названа именем (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
[ -z "$(printf '%s\n' "$out2" | grep -v 'ОТКАЗ:')" ] || { printf 'КРАСНО: i1: отказ выдал частичный пак\n' >&2; exit 1; }
exit 0
