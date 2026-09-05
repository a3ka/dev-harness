#!/usr/bin/env bash
# Проба привязки слабых реализаций контракта 021 (Н-39: привязка стаба к входу —
# КОДОМ фикстур, не прозой контракта). Ожидания фаз СТАБИЛЬНЫ — и до, и после
# реализации 021; на живом дереве проба ничего не утверждает (его состояние —
# предмет «Красное сейчас» контракта, замер отдельными командами).
#
# Правка 2: пред-заморозочные красные меры и регресса живут в red_*-файлах ВНЕ
# case_*-глоба раннера (раннер судит стандарт-А и не может видеть красный кейс
# нереализованного предмета, не уронив CI — CI-факт cc1ac79). Фазы гоняют
# red-файлы ПРЯМЫМ запуском в подставных корнях; после реализации, вместе с
# конверсией red_* → case_* (протокол раннера), проба возвращается к
# scoped-прогонам в тех же корнях.
#
#   фаза 1 — честная форма меры (стаб из договора ветви В) в подставном корне →
#             прямой прогон red_mera rc 0: ворота проходят против честной формы
#             целиком;
#   фаза 2 — слабая «всегда 0» → red_mera rc 1: умирает на воротах
#             «последовательная пара» (дефект наблюдаем там, Н-39);
#   фаза 3 — слабая «пусто-зелёная» → red_mera rc 1: умирает на воротах
#             «недостающий done-тег»;
#   фаза 4 — слабая «теряет merge-принесённые»: однострочная sed-мутация
#             --first-parent над копией check_zones (А-79: однострочный sed,
#             применение проверяется grep'ом — молчаливая потеря текста
#             исключена) → red_regress rc 1: toy с единственным
#             merge-принесённым нарушением остаётся зелёным.
#   фаза 5 — слабая «лексикографическая» (правка 3 по арбитражу fda7bbe:
#             сравнение %ci-строк) → red_mera rc 1: умирает на воротах
#             «последовательная пара со смешанными offset» (дефект наблюдаем
#             там, Н-39).
# Слабая «хвост до HEAD» отдельной фазы не имеет: это СЕГОДНЯШНЕЕ поведение
# честного дерева, её ловит вход «чужой land-merge» red_regress (прямой прогон
# на живом дереве красен до реализации 021).
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
  cp "$ROOT/scripts/check_zones.sh"         "$1/scripts/"
  cp "$ROOT/scripts/lib_zones.sh" "$ROOT/scripts/lib_roles.sh" \
     "$ROOT/scripts/lib_registry.sh" "$ROOT/scripts/next_id.sh" "$1/scripts/"
  cp "$2" "$1/scripts/measure_parallel_windows.sh"
  cp "$ROOT"/fixtures/check_zones/*.sh "$1/fixtures/check_zones/"
}
run_red() {  # <каталог> <red-файл>
  bash "$1/fixtures/check_zones/$2" 2>&1
}

# ── фаза 1: честная форма меры ────────────────────────────────────────────────
mk_toy "$T/r1" "$HERE/stab_mera_chestnyj.sh"
out="$(run_red "$T/r1" red_mera_parallelnosti_okon.sh)" && rc=0 || rc=$?
[ "$rc" -eq 0 ] || fail "честная форма меры: red_mera rc=$rc
$out"

# ── фаза 2: слабая «всегда 0» ────────────────────────────────────────────────
mk_toy "$T/r2" "$HERE/stab_mera_vsegda_nol.sh"
out="$(run_red "$T/r2" red_mera_parallelnosti_okon.sh)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «всегда 0» не поймана: red_mera rc=0
$out"

# ── фаза 3: слабая «пусто-зелёная» ───────────────────────────────────────────
mk_toy "$T/r3" "$HERE/stab_mera_pusto_zelenyj.sh"
out="$(run_red "$T/r3" red_mera_parallelnosti_okon.sh)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «пусто-зелёная» не поймана: red_mera rc=0
$out"

# ── фаза 4: слабая «теряет merge-принесённые» (однострочный sed, А-79) ───────
mk_toy "$T/r4" "$HERE/stab_mera_chestnyj.sh"
sed -i 's/--no-merges --reverse/--no-merges --reverse --first-parent/' "$T/r4/scripts/check_zones.sh"
grep -q -- '--no-merges --reverse --first-parent' "$T/r4/scripts/check_zones.sh" \
  || fail 'sed-мутация --first-parent не применилась к копии check_zones (А-79: молчаливая потеря текста)'
out="$(run_red "$T/r4" red_regress_posledovatel_naja_istorija.sh)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «теряет merge-принесённые» не поймана: red_regress rc=0
$out"

# ── фаза 5: слабая «лексикографическая» (правка 3, арбитраж fda7bbe) ─────────
mk_toy "$T/r5" "$HERE/stab_mera_leksikograficheskij.sh"
out="$(run_red "$T/r5" red_mera_parallelnosti_okon.sh)" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "слабая «лексикографическая» не поймана: red_mera rc=0
$out"

printf 'пойманы: всегда-0, пусто-зелёная, теряет-merge-принесённые, лексикографическая; честная форма меры (моменты, %%ct) проходит\n' >&2
exit 0
