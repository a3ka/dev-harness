#!/usr/bin/env bash
# red_proba_odin_kod_105.sh — клетка И-5 контракта 105: `--probe` печатает
# политику строками stdout `EXT: <путь>` (≥1), `CONFIG: <путь>` (ровно 1),
# `AGENTS: <путь>` (ровно 1) БЕЗ единого вызова omp (счётчик стаба пуст —
# ни `--version`, ни exec), и эти строки СОВПАДАЮТ с живым режимом на том же
# HOME: множество EXT: = множество значений `-e` argv; CONFIG: = первое
# значение `--config` argv; AGENTS: пробы = AGENTS: живого режима. Один код
# пробы и exec — наблюдаемый как конгруэнтность (А-918: проба, не
# доказывающая exec, — дефект).
#
# rc 0 — зелёная; rc 1 — красная («105 И-5 КРАСНО: …»); rc 2 — мир сломан.
# ДО реализации на живом workshop — красная: проба не печатает EXT:.
CELL="И-5"
# shellcheck source=_mir_105.sh
. "$(dirname "${BASH_SOURCE[0]}")/_mir_105.sh"

cell() {
  local ext_p cfg_p ag_p ext_l cfg_l ag_l
  export RUN_HOME="$WORK/home-k5"   # один HOME на пробу и живой режим
  run_probe k5p
  [ "$RC" -eq 0 ] || { pokazat k5p; krasno "проба упала rc=$RC"; return; }
  [ "$(calls_n k5p)" -eq 0 ] || { krasno "проба вызвала omp $(calls_n k5p) раз — проба печатает политику без запуска omp"; return; }
  ext_p="$(out_vals k5p EXT | sorted)"
  [ -n "$ext_p" ] || { krasno "проба не печатает ни одной строки EXT:"; return; }
  [ "$(out_vals k5p CONFIG | wc -l)" -eq 1 ] || { krasno "строк CONFIG: в пробе $(out_vals k5p CONFIG | wc -l), ожидалась ровно 1"; return; }
  [ "$(out_vals k5p AGENTS | wc -l)" -eq 1 ] || { krasno "строк AGENTS: в пробе $(out_vals k5p AGENTS | wc -l), ожидалась ровно 1"; return; }
  cfg_p="$(out_vals k5p CONFIG)"; ag_p="$(out_vals k5p AGENTS)"
  run_live k5l
  [ "$RC" -eq 0 ] || { pokazat k5l; krasno "живой запуск упал rc=$RC"; return; }
  [ "$(launch_n k5l)" -eq 1 ] || { krasno "стаб-omp запущен $(launch_n k5l) раз, ожидался ровно 1"; return; }
  ext_l="$(argv_vals k5l -e | sorted)"
  [ "$ext_p" = "$ext_l" ] || { krasno "строки EXT: пробы ≠ значения -e живого argv (два вычисления списка вместо одного)"; return; }
  cfg_l="$(argv_vals k5l --config | sed -n 1p)"
  [ "$cfg_p" = "$cfg_l" ] || { krasno "CONFIG: пробы «$cfg_p» ≠ первый --config живого argv «$cfg_l»"; return; }
  ag_l="$(out_vals k5l AGENTS)"
  [ "$ag_p" = "$ag_l" ] || { krasno "AGENTS: пробы «$ag_p» ≠ AGENTS: живого режима «$ag_l»"; return; }
  return 0
}
cell
rc=$?
printf '105 И-5: клетка %s\n' "$([ $rc -eq 0 ] && printf 'зелёная' || printf 'красная')"
exit $rc
