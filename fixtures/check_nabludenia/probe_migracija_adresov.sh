#!/usr/bin/env bash
# Проба контракта 015, развилка 1а (блокер 2 круга 1): миграционная сверка НАЗНАЧЕНИЯ —
# команда с кодом возврата. Красная ДО миграции (живые ОТКРЫТО-маркеры без «адрес:»
# либо адрес без якоря цели), зелёная ПОСЛЕ миграционной пачки в коммите введения.
# Запускается из корня дерева. Мера — как у барьера (инварианты 1-3): заголовок
# ^### (Н|А)-NN. + ПОСЛЕДНЯЯ бэктик-группа той же строки; тело записи не судится.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"

# Якоря цели — закрытый список инварианта 3 контракта 015 (точный regex несёт строка
# ГРАММАТИКА барьера; здесь — достаточная мера сверки: каждый адрес обязан назвать цель).
anchor='контракт|contracts/|очеред|ROADMAP|правил|историческ|cognitive-only|закрыто|0[0-9][0-9]'

rc=0
for f in NABLIUDENIA.md NABLIUDENIA_ARCHITECT.md; do
  p="$ROOT/$f"
  if [ ! -f "$p" ]; then
    printf 'ОТКАЗ: %s отсутствует\n' "$f" >&2
    exit 1
  fi
  while IFS= read -r line; do
    id="$(printf '%s' "$line" | sed -E -n 's/^### ((Н|А)-[0-9]+)\..*/\1/p')"
    marker="$(printf '%s' "$line" | { grep -o '`[^`]*`' || true; } | tail -1 | tr -d '`')"
    case "$marker" in
      ОТКРЫТО*) ;;
      *) continue ;;
    esac
    if ! printf '%s' "$marker" | grep -q 'адрес:'; then
      printf 'ОТКАЗ: %s %s: открыта без адреса\n' "$f" "$id" >&2
      rc=1
      continue
    fi
    tail_a="$(printf '%s' "$marker" | sed 's/.*адрес://')"
    if ! printf '%s' "$tail_a" | grep -Eq "$anchor"; then
      printf 'ОТКАЗ: %s %s: адрес не называет цель («%s»)\n' "$f" "$id" "$tail_a" >&2
      rc=1
    fi
  done < <(grep -E '^### (Н|А)-[0-9]+\.' "$p")
done
if [ "$rc" -eq 0 ]; then
  printf 'ok: все ОТКРЫТО-маркеры обоих файлов несут адрес с якорем цели\n'
fi
exit "$rc"
