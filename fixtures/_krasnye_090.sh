#!/usr/bin/env bash
# Раннер красной/зелёной пачки 090 «fix-085: orch-peak HOME unbound (Н-217) + install.sh
# safe.directory (Н-216) + герметичность тест-инфраструктуры (П3/Н-219)» — агрегатор семьи
# fixtures/fix_090_orch_peak_home/.
#
# Использование:
#   bash fixtures/_krasnye_090.sh              # вся семья против $ROOT (умолчание — ..)
#   bash fixtures/_krasnye_090.sh <корень>
#
# Семантика (контракт 090 §Приёмочный критерий): субъект — ops/server/root/orch-peak,
# ops/server/install.sh, scripts/lib_session.sh под КОРНЕМ. rc 0 ⟺ каждая клетка семьи
# rc 0 (ВСЕ шесть функциональных клеток + герметичность); rc 1 — есть красная клетка;
# rc 2 — нечем проверить (нет субъекта/семьи).
#
# На ДОimplementer-дереве (субъект без П1/П2/П3) клетки 1-4 КРАСНЫ ожидаемо (сам предмет
# ещё не реализован) — это НЕ повод гасить CI зелёным: guard подключается в CI ТОЛЬКО
# ПОСЛЕ реализации (та же дисциплина, что 059/060/070 — преждевременно вшитый шаг держал
# бы CI красным до реализации, прецедент 072:484-490, повторено 074 §ПРОВОДКА-ЭНФОРСМЕНТ).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$ROOT/fixtures/fix_090_orch_peak_home"
[ -f "$FAM/lib.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса семьи: %s/lib.sh\n' "$FAM" >&2; exit 2; }
[ -f "$ROOT/ops/server/root/orch-peak" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s/ops/server/root/orch-peak\n' "$ROOT" >&2; exit 2; }

itog=0
progon() {  # <файл семьи>
  local f="$1" rc
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  ORCH090_SUBJECT="$ROOT" bash "$FAM/$f"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}

progon red_no_home_ctx.sh
progon red_ctx_deep_no_home.sh
progon red_ctx_deep_uhome_default.sh
progon red_install_local_config.sh
progon battery_stubs.sh
progon red_hermetic_no_real_sessions.sh

printf 'ИТОГ 090: rc=%s\n' "$itog"
exit "$itog"
