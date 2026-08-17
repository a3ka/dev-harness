# Каркас подставного дерева для фикстур `verify_antiplacebo`.
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
# Общий он потому, что восемь фикстур ломают ОДНО подставное дерево каждая по-своему, и
# восемь копий каркаса разошлись бы молча — это уже дважды случалось на соседнем проекте.
#
# `fake_root <каталог>` собирает МИНИМАЛЬНОЕ дерево, на котором барьер обязан быть ЗЕЛЁНЫМ:
# один классифицированный барьер-игрушка и одна честная фикстура к нему. Зелёная основа
# нужна для того, чтобы красное каждой фикстуры доказывало ИМЕННО внесённую поломку, а не
# то, что подставное дерево негодно вообще.

fake_root() {
  local r="$1"
  mkdir -p "$r/scripts" "$r/fixtures/verify_toy" "$r/tmp"

  cat > "$r/scripts/verify_toy.sh" <<'TOY'
#!/usr/bin/env bash
# Барьер-игрушка: красен, если в корне лежит файл `.slomano`.
# Коды возврата: 0 — цело, 1 — сломано, 2 — нечем проверить.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -e "$here/.slomano" ]; then
  printf 'ОТКАЗ: игрушка сломана\n' >&2
  exit 1
fi
printf '  ok   игрушка цела\n' >&2
TOY
  chmod +x "$r/scripts/verify_toy.sh"

  cat > "$r/fixtures/verify_toy/case_slomano.sh" <<'CASE'
# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"
CASE
}
