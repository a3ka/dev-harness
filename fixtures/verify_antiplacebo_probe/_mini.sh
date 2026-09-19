# Мини-дерево раннера для предъявлений probe-only класса (контракт 034).
#
# Имя НЕ case_*.sh и НЕ red_*.sh: сам он предъявлением не считается и раннером
# не исполняется (прецедент семейства — fixtures/check_zones/_repo.sh).
#
# `mk_mini <каталог>` собирает подставное дерево для РАННЕРА ЖИВОГО РЕПО
# (запуск: bash "$REPO/scripts/verify_antiplacebo.sh" <каталог> [--mode…]):
#   scripts/toy_barrier.sh  — барьер-игрушка (шапка «Коды возврата: 0 — …, 1 — …»),
#                             судит порчу в каталоге запуска;
#   scripts/scope_select.sh — побайтовая копия живого селектора;
#   fixtures/toy_barrier/case_porcha.sh — case по протоколу раннера: зелёный
#                             контроль, обманное состояние (файл porcha), красный
#                             повтор именованной причиной;
#   fixtures/probe_subject/ — probe-only каталог: red_probe.sh (прямое
#                             предъявление субъекта вне scripts/) + маркер
#                             .probe-only (контракт 034).
# Герметичность: глобальный git-конфиг отключён, каталоги под $WORK вызывающего.
mk_mini() {  # <каталог>
  local m="$1"
  mkdir -p "$m/scripts" "$m/fixtures/toy_barrier" "$m/fixtures/probe_subject"
  cp "$REPO/scripts/scope_select.sh" "$m/scripts/scope_select.sh"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' '# Барьер-игрушка мини-дерева: судит порчу (файл porcha) в каталоге запуска.'
    printf '%s\n' '# Коды возврата: 0 — порчи нет, 1 — порча найдена'
    printf '%s\n' 'if [ -e porcha ]; then'
    printf '%s\n' '  printf '\''порча найдена\n'\'' >&2'
    printf '%s\n' '  exit 1'
    printf '%s\n' 'fi'
    printf '%s\n' 'exit 0'
  } > "$m/scripts/toy_barrier.sh"
  {
    printf '%s\n' '# ПРИЧИНА: порча найдена'
    printf '%s\n' '# Зелёный контроль — чистый $WORK; обманное состояние — файл porcha;'
    printf '%s\n' '# повторный вызов обязан краснеть именованной причиной (протокол раннера).'
    printf '%s\n' 'set -euo pipefail'
    printf '%s\n' 'cd "$WORK"'
    printf '%s\n' '"$BARRIER"'
    printf '%s\n' ': > porcha'
    printf '%s\n' '"$BARRIER"'
  } > "$m/fixtures/toy_barrier/case_porcha.sh"
  {
    printf '%s\n' '# Прямое предъявление субъекта вне scripts/ (probe-only каталог, 034).'
    printf '%s\n' '# Раннером не исполняется: имя вне case_*-глоба; для раннера каталог'
    printf '%s\n' '# существует лишь как единица сверки §2 с маркером .probe-only.'
    printf '%s\n' 'exit 0'
  } > "$m/fixtures/probe_subject/red_probe.sh"
  {
    printf '%s\n' 'probe-only каталог мини-дерева (034): субъект — вне scripts/, барьерного'
    printf '%s\n' 'ключа нет; red_probe.sh — прямое предъявление, раннером не исполняется.'
  } > "$m/fixtures/probe_subject/.probe-only"
}
