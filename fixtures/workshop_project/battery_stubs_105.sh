#!/usr/bin/env bash
# battery_stubs_105.sh — СТАБ-ПАК контракта 105 (Н-39): семь мутантов честной
# модели model_105/workshop.sh (ручка M105_MUTANT), каждый несёт РОВНО ОДИН
# дефект и привязан к клетке, где этот дефект НАБЛЮДАЕМ. Матрица 7×5: мутант
# обязан быть КРАСНЫМ на своей клетке и ЗЕЛЁНЫМ на четырёх остальных
# (стаб, красный везде, — не стаб, а поломка; стаб, зелёный на своей клетке, —
# клетка не различает). Диффпроба — тот же файл БЕЗ ручки на всех пяти клетках
# (= `fixtures/_krasnye_105.sh --model`).
#
# Привязки (код модели, не проза контракта):
#   project_ext   → И-1 red_ext_ustanovki_105      (список из проекта: evil.ts, счёт ≠ N)
#   overlay_first → И-2 red_config_do_overlay_105  (оверлей раньше политики)
#   agents_user   → И-3 red_roli_v_profil_105      (роли в $HOME/.omp/agent/agents)
#   late_refuse   → И-4 red_otkaz_flagov_105       (omp --version до отказа: счётчик 1)
#   pass_through  → И-4 red_otkaz_flagov_105       (флаг прокинут: rc 0)
#   probe_silent  → И-5 red_proba_odin_kod_105     (проба без EXT:)
#   probe_js      → И-5 red_proba_odin_kod_105     (проба печатает и *.js: ≠ argv)
#
# Прогон: bash battery_stubs_105.sh [корень]; rc 0 ⟺ 7/7 пойманы ∧ 28/28
# честных входов зелёные; счёт печатается; пустая выборка — красная. Независим
# от режима раннера: субъект здесь всегда модель.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-${W105_ROOT:-$(cd "$HERE/../.." && pwd -P)}}"
MODEL="$HERE/model_105/workshop.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }

CELLS=(red_ext_ustanovki_105 red_config_do_overlay_105 red_roli_v_profil_105 red_otkaz_flagov_105 red_proba_odin_kod_105)
for c in "${CELLS[@]}"; do
  [ -f "$HERE/$c.sh" ] || { printf 'NOT_IMPLEMENTED: нет клетки %s\n' "$HERE/$c.sh" >&2; exit 2; }
done
# <мутант>:<клетка смерти>
MUTANTS=(
  project_ext:red_ext_ustanovki_105
  overlay_first:red_config_do_overlay_105
  agents_user:red_roli_v_profil_105
  late_refuse:red_otkaz_flagov_105
  pass_through:red_otkaz_flagov_105
  probe_silent:red_proba_odin_kod_105
  probe_js:red_proba_odin_kod_105
)

seen=0; caught=0; esc=""; honest_seen=0; honest_ok=0; honest_bad=""
for m in "${MUTANTS[@]}"; do
  name="${m%%:*}"; target="${m#*:}"
  seen=$((seen+1))
  for c in "${CELLS[@]}"; do
    rc=0
    W105_ROOT="$ROOT" W105_SUBJECT="$MODEL" M105_MUTANT="$name" bash "$HERE/$c.sh" >/dev/null 2>&1 || rc=$?
    if [ "$c" = "$target" ]; then
      if [ "$rc" -eq 1 ]; then caught=$((caught+1)); else esc="$esc $name(rc=$rc)"; fi
    else
      honest_seen=$((honest_seen+1))
      if [ "$rc" -eq 0 ]; then honest_ok=$((honest_ok+1)); else honest_bad="$honest_bad $name@$c(rc=$rc)"; fi
    fi
  done
done

printf '105 стаб-пак: мутантов %d, поймано на своей клетке %d, ускользнуло:%s\n' "$seen" "$caught" "${esc:- нет}"
printf '105 стаб-пак: честных входов мутантов %d, зелёных %d, красных:%s\n' "$honest_seen" "$honest_ok" "${honest_bad:- нет}"
[ "$seen" -eq 7 ] || { printf '105 стаб-пак: счёт мутантов ≠ 7 — выборка битая\n' >&2; exit 2; }
[ "$honest_seen" -eq 28 ] || { printf '105 стаб-пак: счёт честных входов ≠ 28 — выборка битая\n' >&2; exit 2; }
[ "$caught" -eq "$seen" ] || exit 1
[ "$honest_ok" -eq "$honest_seen" ] || exit 1
exit 0
