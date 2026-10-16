#!/usr/bin/env bash
# red_ext_ustanovki_105.sh — клетка И-1 контракта 105: живой запуск режима
# проекта передаёт omp РОВНО N флагов `-e <абс. путь>` — по одному на каждый
# `$HERE/.omp/extensions/*.ts` УСТАНОВКИ. Два независимых мира: N = 2..5
# и обязательно N = 0; оракул в памяти до вызова субъекта. Ни одного пути
# из ПРОЕКТА (негатив: у toy-репо есть собственный .omp/extensions/evil.ts).
#
# Субъект: W105_SUBJECT (умолчание <корень>/workshop; `--model` раннера —
# model_105/workshop.sh). rc 0 — зелёная; rc 1 — красная (stderr несёт
# «105 И-1 КРАСНО: <причина>»); rc 2 — мир сломан.
# ДО реализации на живом workshop — красная: в argv нет ни одного `-e`.

cell() {
  local n_e got
  run_live k1
  [ "$RC" -eq 0 ] || { pokazat k1; krasno "живой запуск упал rc=$RC (ожидался exec omp, rc 0)"; return; }
  [ "$(launch_n k1)" -eq 1 ] || { krasno "стаб-omp запущен $(launch_n k1) раз, ожидался ровно 1"; return; }
  n_e="$(argv_count k1 -e)"
  [ "$n_e" -eq "$EXT_N" ] || { krasno "флагов -e в argv $n_e, ожидалось $EXT_N (по числу $INSTALL/.omp/extensions/*.ts установки)"; return; }
  got="$(argv_vals k1 -e | sorted)"
  [ "$got" = "$(expect_ext_sorted)" ] || { krasno "множество значений -e ≠ $INSTALL/.omp/extensions/*.ts установки"; return; }
  ! grep -qF -- "$EVIL" "$WORK/k1.argv" || { krasno "в argv расширение ПРОЕКТА: $EVIL"; return; }
  ! grep -qxF -- '--no-extensions' "$WORK/k1.argv" || { krasno "в argv --no-extensions — политика установки снята"; return; }
  return 0
}
rc=0
for scenario in nonempty empty; do
  (
    CELL="И-1"
    # Новый мир и HOME для каждого сценария; отказ одного не отменяет другой.
    # shellcheck source=_mir_105.sh
    . "$(dirname "${BASH_SOURCE[0]}")/_mir_105.sh"
    if [ "$scenario" = empty ]; then
      rm -- "${EXPECT_EXT[@]}" || die_pack "не удалось опустошить установку"
      EXPECT_EXT=()
      EXT_N=0
    fi
    cell
    case_rc=$?
    printf '105 И-1: установка несёт %s расширений; клетка %s\n' "$EXT_N" "$([ $case_rc -eq 0 ] && printf 'зелёная' || printf 'красная')"
    exit "$case_rc"
  )
  case_rc=$?
  [ "$case_rc" -le "$rc" ] || rc=$case_rc
done
exit "$rc"
