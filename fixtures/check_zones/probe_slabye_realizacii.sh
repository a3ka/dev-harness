#!/usr/bin/env bash
# Проба привязки слабых реализаций контракта 021 (Н-39: привязка стаба к входу —
# КОДОМ фикстур, не прозой контракта). Ожидания фаз СТАБИЛЬНЫ — и до, и после
# реализации 021; на живом дереве проба ничего не утверждает (его состояние —
# предмет «Красное сейчас» контракта, замер отдельными командами).
#
#   фаза 1 — честная форма меры (стаб из договора ветви В) в подставном корне →
#             scoped case_mera rc 0: случай проводит ворота и протокол раннера
#             против договорённой честной формы целиком;
#   фаза 2 — слабая «всегда 0» → scoped case_mera rc 1: умирает на воротах
#             «последовательная пара» (дефект наблюдаем там, Н-39);
#   фаза 3 — слабая «пусто-зелёная» → scoped case_mera rc 1: умирает на воротах
#             «недостающий done-тег»;
#   фаза 4 — слабая «теряет merge-принесённые»: однострочная sed-мутация
#             --first-parent над копией check_zones (А-79: однострочный sed,
#             применение проверяется grep'ом — молчаливая потеря текста
#             исключена) → scoped case_regress rc 1: toy с единственным
#             merge-принесённым нарушением остаётся зелёным.
# Слабая «хвост до HEAD» отдельной фазы не имеет: это СЕГОДНЯШНЕЕ поведение
# честного дерева, её ловит вход «чужой land-merge» case_regress (на нём
# scoped-прогон красен до реализации 021).
#
# Коды возврата: 0 — честная форма проходит, все слабые пойманы; 1 — именованный отказ
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d /tmp/probe021-slabye.XXXXXX)"
trap 'rm -rf "$T"' EXIT
fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

mk_toy() {  # <каталог> <файл-меры>
  mkdir -p "$1/scripts" "$1/fixtures/check_zones"
  cp "$ROOT/scripts/verify_antiplacebo.sh" "$1/scripts/"
  cp "$ROOT/scripts/scope_select.sh"        "$1/scripts/"
  cp "$ROOT/scripts/check_zones.sh"         "$1/scripts/"
  cp "$ROOT/scripts/lib_zones.sh" "$ROOT/scripts/lib_roles.sh" \
     "$ROOT/scripts/lib_registry.sh" "$ROOT/scripts/next_id.sh" "$1/scripts/"
  cp "$2" "$1/scripts/measure_parallel_windows.sh"
  cp "$ROOT"/fixtures/check_zones/*.sh "$1/fixtures/check_zones/"
}
run_scoped() {  # <каталог> <case>
  bash "$1/scripts/verify_antiplacebo.sh" "$1" --scope "check_zones/$2" 2>&1
}

# ── фаза 1: честная форма меры ────────────────────────────────────────────────
mk_toy "$T/r1" "$HERE/stab_mera_chestnyj.sh"
out="$(run_scoped "$T/r1" case_mera_parallelnosti_okon)" && rc=0 || rc=$?
[ "$rc" -eq 0 ] || fail "честная форма меры: scoped rc=$rc
$out"

# ── фаза 2: слабая «всегда 0» ────────────────────────────────────────────────
mk_toy "$T/r2" "$HERE/stab_mera_vsegda_nol.sh"
out="$(run_scoped "$T/r2" case_mera_parallelnosti_okon)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «всегда 0» не поймана: scoped rc=0
$out"

# ── фаза 3: слабая «пусто-зелёная» ───────────────────────────────────────────
mk_toy "$T/r3" "$HERE/stab_mera_pusto_zelenyj.sh"
out="$(run_scoped "$T/r3" case_mera_parallelnosti_okon)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «пусто-зелёная» не поймана: scoped rc=0
$out"

# ── фаза 4: слабая «теряет merge-принесённые» (однострочный sed, А-79) ───────
mk_toy "$T/r4" "$HERE/stab_mera_chestnyj.sh"
sed -i 's/--no-merges --reverse/--no-merges --reverse --first-parent/' "$T/r4/scripts/check_zones.sh"
grep -q -- '--no-merges --reverse --first-parent' "$T/r4/scripts/check_zones.sh" \
  || fail 'sed-мутация --first-parent не применилась к копии check_zones (А-79: молчаливая потеря текста)'
out="$(run_scoped "$T/r4" case_regress_posledovatel_naja_istorija)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «теряет merge-принесённые» не поймана: scoped rc=0
$out"

printf 'пойманы: всегда-0, пусто-зелёная, теряет-merge-принесённые; честная форма меры проходит\n' >&2
exit 0
