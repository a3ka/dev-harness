# Каркас подставного дерева для фикстур `verify_antiplacebo`.
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
# Общий он потому, что фикстуры ломают ОДНО подставное дерево каждая по-своему, и полтора
# десятка копий каркаса разошлись бы молча — это уже дважды случалось на соседнем проекте.
#
# `fake_root <каталог>` собирает МИНИМАЛЬНОЕ дерево, на котором барьер обязан быть ЗЕЛЁНЫМ:
# один классифицированный барьер-игрушка и одна честная фикстура к нему — с положительным
# контролем, потому что теперь его требует и сам барьер. Зелёная основа нужна для того,
# чтобы красное каждой фикстуры доказывало ИМЕННО внесённую поломку, а не то, что подставное
# дерево негодно вообще.
#
# `set_toy <каталог> <вариант>` подменяет тело игрушки. Варианты отвечают находкам
# адверсария: каждая его заглушка обманывала проверку СВОИМ способом, и вариант — это способ,
# а не оттенок.

fake_root() {
  local r="$1"
  mkdir -p "$r/scripts" "$r/fixtures/verify_toy" "$r/tmp"
  set_toy "$r" slomano

  # Фикстура игрушки: сначала ЗЕЛЁНЫЙ прогон на целом дереве, потом порча и красное.
  cat > "$r/fixtures/verify_toy/case_slomano.sh" <<'CASE'
# ПРИЧИНА: игрушка сломана
set -euo pipefail
mkdir -p "$WORK/scripts"
BARRIER_ROOT="$WORK" "$BARRIER"
touch "$WORK/.slomano"
BARRIER_ROOT="$WORK" "$BARRIER"
CASE
}

set_toy() {
  local r="$1" kind="$2"
  mkdir -p "$r/scripts"
  {
    printf '#!/usr/bin/env bash\n'
    printf '# Барьер-игрушка (вариант %s): красен, если в корне лежит файл `.slomano`.\n' "$kind"
    printf '# Коды возврата: 0 — цело, 1 — сломано, 2 — нечем проверить.\n'
    printf 'set -euo pipefail\n'
    printf 'here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"\n'
    case "$kind" in
      slomano)
        printf 'if [ -e "$here/.slomano" ]; then printf "ОТКАЗ: игрушка сломана\\n" >&2; exit 1; fi\n'
        printf 'printf "  ok   игрушка цела\\n" >&2\n'
        ;;
      kod127)
        # Неудача ЗАПУСКА, а не отказ по предмету: так адверсарий выдал код 127 за красное.
        printf 'if [ -e "$here/.slomano" ]; then komanda-kotoroj-net; fi\n'
        printf 'printf "  ok   игрушка цела\\n" >&2\n'
        ;;
      vsegda)
        # Причина печатается ВСЕГДА, в том числе на зелёном прогоне: тогда она не называет
        # ни отказ, ни предмет.
        printf 'printf "игрушка сломана\\n" >&2\n'
        printf 'if [ -e "$here/.slomano" ]; then exit 1; fi\n'
        ;;
      kod2)
        # Настоящее нарушение, заслонённое нехваткой инструмента.
        printf 'if [ -e "$here/.slomano" ]; then printf "NOT_IMPLEMENTED: игрушке нечем проверять\\n" >&2; exit 2; fi\n'
        printf 'printf "  ok   игрушка цела\\n" >&2\n'
        ;;
      *) printf 'printf "неизвестный вариант игрушки\\n" >&2; exit 2\n' ;;
    esac
  } > "$r/scripts/verify_toy.sh"
  chmod +x "$r/scripts/verify_toy.sh"
}
