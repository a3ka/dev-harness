#!/usr/bin/env bash
# Клетка red_istochnik_doveriya — инвариант И-17 контракта 100 (круг 2, Б7 +
# совет 3): источник доверия — принятая ревизия; схема fail-closed; различение
# «путь достоверно отсутствует» и «принятую ревизию не удалось прочитать».
# Под-входы:
# (а) доверенный файл — ГОЛАЯ запись без контейнера schema/exceptions →
#     «список не разбирается: схема» (незаявленная форма не принимается);
# (б) доверенный файл — битый JSON → «список не разбирается: схема»;
# (в) файл в принятой ревизии ОТСУТСТВУЕТ (ls-tree пуст, объекты читаются) ≡
#     пустой список → строгий допуск: rc 0 + строка допуска 0/0 (позитив);
# (г) путь в дереве есть, но объект не читается (блоб вырван) →
#     «список не читается» — НЕ пустой список молча (нет `git show || empty`).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check:skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

itog=0
sub() {  # <вариант> <список-raw|-> <ожидаемая-фраза|позитив-маркер> <позитив?>
  local variant="$1" raw="$2" want="$3" positive="${4:-0}"
  local W="$Z100_BASE/main-ci-100-istochnik-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  if [ "$variant" = "net-faila" ]; then
    Z100_NO_EXCEPTIONS_FILE=1 z100_mir_repo "$W"
  else
    printf '%s\n' "$raw" >"/tmp/dev-harness-verify/.z100_istochnik_raw"
    Z100_EXCEPTIONS_JSON="$(cat "/tmp/dev-harness-verify/.z100_istochnik_raw")" z100_mir_repo "$W"
  fi
  if [ "$variant" = "blob-vyrvan" ]; then
    # путь в дереве A есть, но блоб-объект удалён из локального хранилища
    bl="$(git -C "$W/repo" rev-parse "$Z100_A:registry/main-ci-exceptions.json")"
    rm -f "$W/repo/.git/objects/${bl:0:2}/${bl:2}"
  fi
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
             "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/check_skills/ ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  if [ "$positive" = "1" ]; then
    # позитив: всё зелёное, запуск успешен
    z100_cr_reset
    for j in $(z100_jobs); do
      z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")"
    done
    z100_api_write_runs "$W" "2,$Z100_P,completed,success,$Z100_A,2"
  else
    z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
  fi
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_istochnik/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_istochnik/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  out="$(z100_subject_run "$PORT")"; rc=$?
  local ok=0
  if [ "$positive" = "1" ]; then
    [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo' \
      && printf '%s' "$out" | grep -Fq 'jobs 12/12 исполнено, находки 0/0' && ok=1
  else
    [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" && ok=1
  fi
  if [ "$ok" -eq 1 ]; then
    printf 'ЗЕЛЕНО: red_istochnik/%s\n' "$variant"
  else
    printf 'КРАСНО: red_istochnik/%s: предмет отсутствует: ожидались rc %s и «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$([ "$positive" = "1" ] && printf 0 || printf 1)" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"

sub golog-zapis "$ex_ap2" 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не разбирается: схема'
sub bityi-json '{"oops' 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не разбирается: схема'
sub net-faila - 'строка допуска (пустой список ≡ строгий допуск)' 1
sub blob-vyrvan "$(z100_ex_list "$ex_ap2")" 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не читается'
exit "$itog"
