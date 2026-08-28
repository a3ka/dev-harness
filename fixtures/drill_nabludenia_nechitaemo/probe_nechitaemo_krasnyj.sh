#!/usr/bin/env bash
# Проба контракта 015, механизм 1 / rc=2-ветвь (арбитраж 3, спор 3): красная ДО
# реализации (дрилла нет), зелёная ПОСЛЕ. Прямой прогон дрилла над репо МУТИРУЕТ
# дерево: дрилл вычисляет WORK по СВОЕМУ пути (dirname(dirname(реального пути))),
# и запущенный по реальному пути считает WORK=корень репо — живой NABLIUDENIA.md
# перезаписывается однострочным контролем (измерено; CI «дерево изменилось:
# ./NABLIUDENIA.md»). Потому проба строит игрушечный корень ВНЕ дерева (mktemp),
# кладёт туда дрилла и настоящего барьера рядом с ним, и прогоняет дрилла ОТТУДА:
# зелёный контроль, затем chmod 000 существующего файла и требование rc=2 + строки
# «нечем проверить: <файл>». rc=2 барьера фикстурой не выражается (раннер трактует
# любой rc=2 как NOT_IMPLEMENTED) — потому предъявление дриллом, а красное дрилла —
# подставным барьером (case_* рядом).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
D="$ROOT/scripts/drill_nabludenia_nechitaemo.sh"

if [ ! -f "$D" ]; then
  printf 'ОТКАЗ: дрилла нет — %s (реализация за implementer после заморозки)\n' "$D" >&2
  exit 1
fi

# Игрушечный корень вне дерева: WORK-вычисление дрилла останется внутри игрушки
TOY="$(mktemp -d "${TMPDIR:-/tmp}/probe-nechitaemo.XXXXXX")"
trap 'rm -rf "$TOY"' EXIT
mkdir -p "$TOY/scripts"
cp "$D" "$TOY/scripts/drill_nabludenia_nechitaemo.sh"
cp "$ROOT/scripts/check_nabludenia.sh" "$TOY/scripts/check_nabludenia.sh"

if bash "$TOY/scripts/drill_nabludenia_nechitaemo.sh" >/dev/null 2>&1; then
  printf 'ok: дрилл nabludenia-nechitaemo зелёный в изолированном корне\n'
  exit 0
fi
rc=$?
printf 'ОТКАЗ: дрилл nabludenia-nechitaemo красен (rc=%d)\n' "$rc" >&2
exit 1
