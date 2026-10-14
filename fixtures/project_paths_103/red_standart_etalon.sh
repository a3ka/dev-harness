#!/usr/bin/env bash
# Клетка И-4а «эталон стандарта зелен» (контракт 103). Complior-подобный
# toy (origin+main, профиль двух слоёв по .harness/*, lockfile, честные
# команды, AGENTS.md, карта map+rules, .env.example, .env игнорируется, пин
# харнеса) → check_project_standard.sh --repo R: rc 0 и stderr БЕЗ строк
# «ОТКАЗ: стандарт:». Обман (ложный отказ на эталоне) → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_standard)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: standart-etalon: предмет отсутствует: scripts/check_project_standard.sh\n' >&2; exit 1; }
W="$(_t103_complior i4a)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$R" bash "$SUBJ" --repo "$R" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i4а: эталон не прошёл стандарт (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: стандарт:'; then
  printf 'КРАСНО: i4а: rc 0 при строках отказа: %s\n' "$out" >&2; exit 1
fi
exit 0
