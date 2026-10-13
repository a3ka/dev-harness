#!/usr/bin/env bash
# Клетка red_ci_proiskhozhdenie — инвариант И-12 контракта 100 (круг 3, Б2
# по арбитражу verdicts/arbitration/contracts-100-b1b2-v1.md): происхождение
# CI-кода — принятая ревизия: слой определений И исполняемые корни scripts/
# и fixtures/ (изменение/удаление/переименование/смена типа существующего
# пути — нарушение; ДОБАВЛЕНИЕ новых путей разрешено). Под-входы (каждый —
# отчёты с ПРАВИЛЬНЫМ def-sha256, честные строки, находка ровно подписанная,
# аннотации — разрешённые path/message):
# (а) кандидат изменил package.json (слой определений) → отказ;
# (б) слой определений и список побайтно прежние, кандидат заменил ТЕЛО
#     файла, который вызывает команда ключа (проверяльщик под scripts/),
#     на printf разрешённых терминальных строк → отказ с этим путём;
# (в) кандидат удалил существующий файл под fixtures/ → тот же отказ;
# (г) ПОЗИТИВ: кандидат только ДОБАВИЛ новый файл под fixtures/
#     (существующие не тронуты) → строка допуска.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check:skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

PROVERKA='#!/usr/bin/env bash
# toy-проверяльщик ключей (тело — предмет закрепления корней, И-12б)
set -uo pipefail
printf "check:skills: PASS\n"
printf "check:scope-select: PASS\n"
'
PROVERKA_PODMENA='#!/usr/bin/env bash
# подменённое тело: printf разрешённых терминальных строк (проверка не исполняется)
printf "check:skills: FAIL: нет положительного контроля\n"
printf "check:scope-select: PASS\n"
'
TOY_KLETKA='#!/usr/bin/env bash
# toy-клетка корня fixtures/ (существующий путь, И-12в/г)
exit 0
'

itog=0
sub() {  # <вариант a|b|v|g> <ожидаемая-фраза|-> <позитив?>
  local variant="$1" want="$2" positive="${3:-0}"
  local W="$Z100_BASE/main-ci-100-cipro-$variant-$$-${RANDOM}" API_PID="" out rc TD="" CD=""
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W" "${TD:-}" "${CD:-}"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  local ex_ap2
  ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
  # доверенные исполняемые корни мира + команда ключа на проверяльщик под scripts/
  TD="$(mktemp -d "$Z100_BASE/.z100cipro.XXXXXX")"
  mkdir -p "$TD/scripts" "$TD/fixtures"
  printf '%s\n' "$PROVERKA" >"$TD/scripts/toy_checker.sh"
  printf '%s\n' "$TOY_KLETKA" >"$TD/fixtures/toy_red_kletka.sh"
  case "$variant" in
    a) Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
       Z100_CANDIDATE_CI_FILE="package.json" \
       Z100_CANDIDATE_CI_CONTENT="$(z100_pkgjson | sed 's/toy-mir-100/toy-mir-100-podmena/')" \
         z100_mir_repo "$W" ;;
    b) CD="$(mktemp -d "$Z100_BASE/.z100cand.XXXXXX")"
       mkdir -p "$CD/scripts"
       printf '%s\n' "$PROVERKA_PODMENA" >"$CD/scripts/toy_checker.sh"
       Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
       Z100_TRUSTED_SRC_DIR="$TD" Z100_PKG_CMD="scripts/toy_checker.sh" \
       Z100_CANDIDATE_SRC_DIR="$CD" \
         z100_mir_repo "$W" ;;
    v) Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
       Z100_TRUSTED_SRC_DIR="$TD" Z100_PKG_CMD="scripts/toy_checker.sh" \
       Z100_CANDIDATE_RM="fixtures/toy_red_kletka.sh" \
         z100_mir_repo "$W" ;;
    g) CD="$(mktemp -d "$Z100_BASE/.z100cand.XXXXXX")"
       mkdir -p "$CD/fixtures"
       printf '#!/usr/bin/env bash\n# новый файл кандидата: ДОБАВЛЕНИЕ под корнем разрешено\nexit 0\n' >"$CD/fixtures/novaya_kletka_9999.sh"
       Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
       Z100_TRUSTED_SRC_DIR="$TD" Z100_PKG_CMD="scripts/toy_checker.sh" \
       Z100_CANDIDATE_SRC_DIR="$CD" \
         z100_mir_repo "$W" ;;
  esac
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
             "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/check_skills/ ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_ci_proiskhozhdenie/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_ci_proiskhozhdenie/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  out="$(z100_subject_run "$PORT")"; rc=$?
  local ok=0
  if [ "$positive" = "1" ]; then
    [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo' \
      && printf '%s' "$out" | grep -Fq 'jobs 12/12 исполнено, находки 1/1' && ok=1
  else
    [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" \
      && ! printf '%s' "$out" | grep -Fq 'PR-CI допуск' && ok=1
  fi
  if [ "$ok" -eq 1 ]; then
    printf 'ЗЕЛЕНО: red_ci_proiskhozhdenie/%s\n' "$variant"
  else
    printf 'КРАСНО: red_ci_proiskhozhdenie/%s: предмет отсутствует: ожидались rc %s и «%s»%s; факт rc=%s, вывод: %s\n' \
      "$variant" "$([ "$positive" = "1" ] && printf 0 || printf 1)" "$want" \
      "$([ "$positive" = "1" ] && printf '' || printf ' без строки допуска')" \
      "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub a 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: package.json'
sub b 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: scripts/toy_checker.sh'
sub v 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: fixtures/toy_red_kletka.sh'
sub g 'строка допуска (добавление под корнем разрешено)' 1
exit "$itog"
