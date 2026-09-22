#!/usr/bin/env bash
# ПРИЧИНА: проводка: строка вне грамматики: - charter=AGENTS.md §Pinned section«Delimiterless charter norm.»
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_20 — RED (delimiter, круг 6 Б3): грамматика контракта требует ОБЯЗАТЕЛЬНОГО
# пробельного разделителя между заголовком секции и открывающей `«` —
# `§<полный заголовок> «<норма>»`. Без пробела — строка вне грамматики
# (тот же класс причины, что parser-laxity, существующая фраза). Положительный
# контроль — с ровно одним пробелом → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case20_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# Положительный контроль: §Heading «Norm» (с пробелом) → rc 0
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g20: chestnyj delimiter (s probelom)'
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

# Красный: §Heading«Norm» БЕЗ пробела — вне грамматики
R="$WORK/red"; make_toy "$R" 1 0
# ВАЖНО: make_toy с with_charter=1 уже создаёт AGENTS.md с «## Воркфлоу
# майлстоуна» (есть пробел в имени заголовка). Для теста «без пробела перед
# кавычкой» — нам нужна короткая секция без внутренних пробелов (чтобы
# parser-laxity-check не сработал на чём-то ещё). Перезаписываем AGENTS.md.
printf '# Charter\n\n## Pinned section\nDelimiterless charter norm.\n' > "$R/AGENTS.md"
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Pinned section«Delimiterless charter norm.»'
commit_all "$R" 'r20: charter delimiterless §Heading«Norm»'
RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_20 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_20 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_20 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: строка вне грамматики: - charter=AGENTS.md §Pinned section«Delimiterless charter norm.»' \
    || { printf 'FAIL: case_20 red: причина не названа дословно (вся строка канала)\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_20: прямой rc 0 на зелёном, rc 1 на красном (charter delimiter обязателен)\n' >&2
  exit 0
fi
exit 0
