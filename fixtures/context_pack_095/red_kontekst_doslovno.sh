#!/usr/bin/env bash
# Клетка И-13 «дословная доставка КОНТЕКСТ: и §Существующее» (контракт 095,
# состав п.7, круг 2; закрытие Б3 вердикта критика круга 1). CONTEXT-секция
# пака несёт строки `КОНТЕКСТ:` и секцию `## Существующее` контракта
# ПОБАЙТОВО из источника-пака (заморозка). Оракул — байты из frozen-блоба,
# снятые в память ДО вызова субъекта (правило 8); сверка — побайтовое
# равенство тела секции, не наличие заголовка. Обман (s13: извлечение
# подменено литеральной заглушкой) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: kontekst-doslovno: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i13)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
TAG="$(_t95_freeze "$R" 'scripts/toy.sh')"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# оракул ДО вызова: КОНТЕКСТ-строки и §Существующее из ЗАМОРОЗКИ — в память
KB="$(git -C "$R" show "$TAG:contracts/777-toy.md" | grep '^КОНТЕКСТ:')"
SB="$(git -C "$R" show "$TAG:contracts/777-toy.md" | awk '/^## Существующее$/{f=1;print;next} /^## /{f=0} f{print}')"
[ -n "$KB" ] || { printf 'КРАСНО: i13: заморозка без КОНТЕКСТ-строк — мир сломан\n' >&2; exit 2; }
[ -n "$SB" ] || { printf 'КРАСНО: i13: заморозка без §Существующее — мир сломан\n' >&2; exit 2; }
WANT="$(printf '%s\n%s' "$KB" "$SB")"
# черновик расходится с заморозкой: подмена в рабочем дереве НЕ должна попасть в пак
printf 'КОНТЕКСТ: ПОДМЕНА ЧЕРНОВИКА\n' >>"$R/contracts/777-toy.md"
printf '%s\n' '- подмена черновика: Существующее не доставлено' >>"$R/contracts/777-toy.md"

printf '' >"$W/trace-implementer.tsv"
_t95_trace "$W/trace-implementer.tsv" implementer glm-4.7 allowed
out="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace-implementer.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i13: пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
GOT="$(printf '%s\n' "$out" | awk '/^=== CONTEXT ===$/{f=1;next} /^=== ZONES ===$/{f=0} f{print}')"
if [ "$GOT" != "$WANT" ]; then
  printf 'КРАСНО: i13: CONTEXT-секция не побайтово из источника-пака.\n--- ждали:\n%s\n--- получили:\n%s\n' "$WANT" "$GOT" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'ПОДМЕНА ЧЕРНОВИКА'; then
  printf 'КРАСНО: i13: в пак попал черновик вместо заморозки\n' >&2; exit 1
fi
exit 0
