#!/usr/bin/env bash
# Раннер красной/зелёной пачки 083 «CI-А: генератор шагов + инкрементальность» —
# агрегатор ОДНОЙ семьи:
#   fixtures/ci_gen_083/red_ci_a_083.sh
# (probe-only 034, см. .probe-only в каталоге семьи; имя каталога — вне чужих
# glob'ов раннеров).
#
# Использование:
#   bash fixtures/_krasnye_083.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_083.sh <корень>     # альтернативный корень дерева
#     (И0/И0б пишут tmp внутрь судимого корня — прогонять на корне с правом
#     записи; check_zones требует тегов frozen/* в клоне — fetch --tags)
#
# Семантика: rc 0 — батарея зелёная (все честные клетки зелёны + стаб-пак
# пойман + позитивные контроли зелёны); rc 1 — красное (до реализации части Г
# (Г0-Г10, Г10 — этикет кеша restore/save по событию и lane) и И0/И0б/И2-И5/И-окно
# трёх чеков, (в′) И4-3/И4-4, запись кеша на CI-форме пути И4-5 всех четырёх
# чеков и сдвиг HEAD между incr_parse и incr_finish И15 красны по умыслу —
# «предмет отсутствует»). Подключение в ci —
# реализационной пачкой (контракт 083 §ПРОВОДКА; прецедент 080).
# Г11 и восемь адресных мутантов ниже защищают предикат очистки PR-события:
# реальный раннер копируется в одноразовый мир, меняется РОВНО один фрагмент.
# Зачёт — rc 1 и ТОЧНЫЙ профиль красных подклеток (Н-39), не любой отказ.
# --lane-env-only оставляет только Г11 + этот стаб-пак для адресной пробы.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATTERY="$HERE/ci_gen_083/red_ci_a_083.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }
ROOT="${1:-$(cd "$HERE/.." && pwd -P)}"
ROOT="$(cd "$ROOT" && pwd -P)" || exit 1
if [ "${2:-}" = --lane-env-only ]; then
  bash "$BATTERY" "$ROOT" --lane-env-only
else
  bash "$BATTERY" "$ROOT"
fi
battery_rc=$?
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/ci-a-083-stubs.XXXXXX")" || exit 1
trap 'rm -rf "$SCRATCH"' EXIT
caught=0; missed=0
runner=""
[ ! -f "$ROOT/scripts/run_ci_lane.sh" ] || runner="$(< "$ROOT/scripts/run_ci_lane.sh")"

lane_stub() { # <имя> <один старый фрагмент> <новый> <красные подклетки>
  local name="$1" from="$2" to="$3" expected="$4" rest world rc line
  local want="" got="" cell
  # Замена обязана иметь единственный адрес: невалидная мутация не зачёт.
  rest="${runner#*"$from"}"
  if [ "$rest" = "$runner" ] || [[ "$rest" == *"$from"* ]]; then
    printf '  FAIL Г11-стаб/%s — фрагмент мутации не единственный\n' "$name" >&2
    missed=$((missed+1))
    return
  fi
  world="$SCRATCH/$name"
  mkdir -p "$world/scripts" || exit 1
  printf '%s\n' "${runner/"$from"/"$to"}" | tee "$world/scripts/run_ci_lane.sh" >/dev/null
  for cell in $expected; do want+="  FAIL $cell"$'\n'; done
  # Даже при внешнем pull_request Г11 сама задаёт/снимает переменную.
  env GITHUB_EVENT_NAME=pull_request bash "$BATTERY" "$world" --lane-env-only |& tee "$SCRATCH/$name.log"
  rc=${PIPESTATUS[0]}
  while IFS= read -r line; do
    case "$line" in
      "  FAIL "*) got+="${line%% — *}"$'\n' ;;
    esac
  done < "$SCRATCH/$name.log"
  if [ "$rc" -eq 1 ] && [ "$got" = "$want" ]; then
    printf '  ok   Г11-стаб/%s — пойман поимённо: %s; прочие подклетки зелёны\n' "$name" "$expected" >&2
    caught=$((caught+1))
  else
    printf '  FAIL Г11-стаб/%s — rc=%s; ожидался профиль:\n%sнаблюдался:\n%s' "$name" "$rc" "$want" "$got" >&2
    missed=$((missed+1))
  fi
}

# Н-39: wrong-field различим у всех снимающих ключей, no-family — у обоих
# family, all-keys — у пяти сохраняющих; no-document и no-drill — каждый
# на своём ключе; broad-selftest — на похожем НЕ-family. doc-glob красен
# только у doc-соседа, family-literal — только у второй основы family.
predicate='    *-family-selftest|check:document|drill:contract-change)'
lane_stub wrong-field 'case "$k" in' 'case "$cmd" in' \
  'Г11-PR/probe-family-selftest Г11-PR/check:document Г11-PR/drill:contract-change Г11-PR/other-family-selftest'
lane_stub no-family "$predicate" '    check:document|drill:contract-change)' \
  'Г11-PR/probe-family-selftest Г11-PR/other-family-selftest'
lane_stub all-keys "$predicate" '    *)' \
  'Г11-PR/check:charter Г11-PR/check:contract-frozen Г11-PR/check:foo-selftest Г11-PR/drill:other Г11-PR/check:documentation'
lane_stub no-document "$predicate" '    *-family-selftest|drill:contract-change)' \
  'Г11-PR/check:document'
lane_stub no-drill "$predicate" '    *-family-selftest|check:document)' \
  'Г11-PR/drill:contract-change'
lane_stub broad-selftest "$predicate" '    *selftest|check:document|drill:contract-change)' \
  'Г11-PR/check:foo-selftest'
lane_stub doc-glob "$predicate" '    *-family-selftest|check:doc*|drill:contract-change)' \
  'Г11-PR/check:documentation'
lane_stub family-literal "$predicate" '    probe-family-selftest|check:document|drill:contract-change)' \
  'Г11-PR/other-family-selftest'
printf '083-Г11-стабы: поймано=%d пропущено=%d\n' "$caught" "$missed" >&2
[ "$battery_rc" -eq 0 ] && [ "$caught" -eq 8 ] && [ "$missed" -eq 0 ]
