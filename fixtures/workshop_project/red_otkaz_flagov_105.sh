#!/usr/bin/env bash
# red_otkaz_flagov_105.sh — клетка И-4 контракта 105: флаг хвоста, снимающий
# политику расширений установки (`--no-extensions`, `--extension <x>`,
# `--extension=<x>`, `-e <x>`, `--hook <x>`, `--hook=<x>`), — именованный отказ rc 1 той же
# формы, что `--approval-mode` (workshop:484): первая строка stderr начинается
# «ОТКАЗ: флаг <токен>», и omp НЕ вызывается ни разу (ни `--version`, ни exec:
# счётчик стаба пуст — отказ стоит на разборе argv, до любого вызова).
# Парный позитив: посторонний флаг хвоста (`--toy-flag-<случайное>`) НЕ
# отвергается — прокидывается omp как есть (отказ именной, не одеяло на все
# незнакомые флаги).
# Все семь входов повторяются в независимых мирах N=2..5 и N=0.
#
# rc 0 — зелёная; rc 1 — красная («105 И-4 КРАСНО: …»); rc 2 — мир сломан.
# ДО реализации на живом workshop — красная: `-*) break` (workshop:485)
# прокидывает все шесть форм в omp, rc 0.

otkaz() { # $1=имя прогона $2=токен флага [$3=значение]
  local n="$1" tok="$2"; shift 2
  run_live "$n" "$tok" "$@"
  [ "$RC" -eq 1 ] || { krasno "«$tok»: rc=$RC, ожидался 1 (именованный отказ)"; return; }
  awk -v p="ОТКАЗ: флаг $tok " 'index($0,p)==1 {f=1} END {exit f?0:1}' "$WORK/$n.err" \
    || { pokazat "$n"; krasno "«$tok»: stderr не несёт строки, начинающейся «ОТКАЗ: флаг $tok »"; return; }
  [ "$(calls_n "$n")" -eq 0 ] || { krasno "«$tok»: omp вызван $(calls_n "$n") раз ДО отказа — отказ обязан стоять до любого вызова omp"; return; }
  return 0
}
cell() {
  local toy="--toy-flag-$(rnd 6)"
  otkaz k4a --no-extensions || return
  otkaz k4b --extension "$INSTALL/x.ts" || return
  otkaz k4c "--extension=$INSTALL/x.ts" || return
  otkaz k4d -e "$INSTALL/x.ts" || return
  otkaz k4e --hook "$INSTALL/x.ts" || return
  otkaz k4f "--hook=$INSTALL/x.ts" || return
  # парный позитив: посторонний флаг хвоста доходит до omp
  run_live k4z "$toy"
  [ "$RC" -eq 0 ] || { pokazat k4z; krasno "посторонний флаг «$toy» отвергнут rc=$RC — отказ обязан быть именным, не одеялом"; return; }
  [ "$(argv_count k4z "$toy")" -eq 1 ] || { krasno "посторонний флаг «$toy» не дошёл до argv omp"; return; }
  return 0
}
rc=0
for scenario in nonempty empty; do
  (
    CELL="И-4"
    # shellcheck source=_mir_105.sh
    . "$(dirname "${BASH_SOURCE[0]}")/_mir_105.sh"
    if [ "$scenario" = empty ]; then
      rm -- "${EXPECT_EXT[@]}" || die_pack "не удалось опустошить установку"
      EXPECT_EXT=()
      EXT_N=0
    fi
    cell
    case_rc=$?
    printf '105 И-4: установка несёт %s расширений; шесть форм запретного флага + один посторонний; клетка %s\n' "$EXT_N" "$([ $case_rc -eq 0 ] && printf 'зелёная' || printf 'красная')"
    exit "$case_rc"
  )
  case_rc=$?
  [ "$case_rc" -le "$rc" ] || rc=$case_rc
done
exit "$rc"
