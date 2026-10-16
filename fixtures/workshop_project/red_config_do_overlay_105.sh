#!/usr/bin/env bash
# red_config_do_overlay_105.sh — клетка И-2 контракта 105: argv живого запуска
# несёт `--config <установка>/.omp/config.yml` (политика: always-ask, deny-
# паттерны 025, modelRoles, isolation 067), и при пользовательском `--models`
# эта пара стоит РАНЬШЕ пары оверлея (у omp поздний --config перекрывает
# ранний: оверлей владельца поверх политики, не наоборот). Без `--models` —
# ровно один --config, и это политика.
#
# Оверлей toy несёт СЛУЧАЙНЫЙ литеральный id модели — второй --config обязан
# быть файлом с этим id (инвариантность к значениям).
# Оба запуска исполняются в независимых мирах N=2..5 и N=0.
# rc 0 — зелёная; rc 1 — красная («105 И-2 КРАСНО: …»); rc 2 — мир сломан.
# ДО реализации на живом workshop — красная: --config политики в argv нет.

cell() {
  local n_cfg first second
  # (а) с оверлеем: политика, затем оверлей
  run_live k2 --models "$TOY_OVERLAY"
  [ "$RC" -eq 0 ] || { pokazat k2; krasno "живой запуск с --models упал rc=$RC"; return; }
  [ "$(launch_n k2)" -eq 1 ] || { krasno "стаб-omp запущен $(launch_n k2) раз, ожидался ровно 1"; return; }
  n_cfg="$(argv_count k2 --config)"
  [ "$n_cfg" -eq 2 ] || { krasno "--config в argv $n_cfg раз, ожидалось 2 (политика установки + оверлей --models)"; return; }
  first="$(argv_vals k2 --config | sed -n 1p)"
  [ "$first" = "$EXPECT_CFG" ] || { krasno "первый --config = «$first», ожидалась политика установки $EXPECT_CFG (оверлей обязан идти ПОСЛЕ)"; return; }
  second="$(argv_vals k2 --config | sed -n 2p)"
  [ -f "$second" ] || { krasno "второй --config не файл: «$second»"; return; }
  grep -qF -- "$TOY_MODEL" "$second" || { krasno "второй --config ($second) не несёт id оверлея пользователя $TOY_MODEL"; return; }
  # (б) без оверлея: ровно одна пара --config — политика
  run_live k2b
  [ "$RC" -eq 0 ] || { pokazat k2b; krasno "живой запуск без --models упал rc=$RC"; return; }
  n_cfg="$(argv_count k2b --config)"
  [ "$n_cfg" -eq 1 ] || { krasno "без --models --config в argv $n_cfg раз, ожидался ровно 1 (политика установки)"; return; }
  first="$(argv_vals k2b --config | sed -n 1p)"
  [ "$first" = "$EXPECT_CFG" ] || { krasno "без --models --config = «$first», ожидалась политика $EXPECT_CFG"; return; }
  return 0
}
rc=0
for scenario in nonempty empty; do
  (
    CELL="И-2"
    # shellcheck source=_mir_105.sh
    . "$(dirname "${BASH_SOURCE[0]}")/_mir_105.sh"
    if [ "$scenario" = empty ]; then
      rm -- "${EXPECT_EXT[@]}" || die_pack "не удалось опустошить установку"
      EXPECT_EXT=()
      EXT_N=0
    fi
    cell
    case_rc=$?
    printf '105 И-2: установка несёт %s расширений; клетка %s\n' "$EXT_N" "$([ $case_rc -eq 0 ] && printf 'зелёная' || printf 'красная')"
    exit "$case_rc"
  )
  case_rc=$?
  [ "$case_rc" -le "$rc" ] || rc=$case_rc
done
exit "$rc"
