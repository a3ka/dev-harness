#!/usr/bin/env bash
# Клетка red_samovnesenie_spiska — инвариант И-14 контракта 100 (круг 3, Б4):
# защищённый переход списка и CI-кода охватывает ФАКТИЧЕСКИ ПУБЛИКУЕМОЕ дерево
# M (land-мерж), не только CI-родитель p. Под-входы:
# (а) кандидат расширяет СВОЙ список дормантной записью (сам ею не пользуется:
#     находки ровно подписанные, CI честен относительно действующего списка) →
#     «список не из доверенной ревизии» без строки допуска;
# (б) p несёт доверенный список побайтно, расширенный список внесён ТОЛЬКО в
#     дерево land-мержа M (живой обход круга 2: публикация M через настоящую
#     дверь при p↔rmain идентичных, запись l4/object=new-forbidden-object) →
#     тот же отказ без строки допуска;
# (в) p чист, тело проверяльщика под scripts/ заменено ТОЛЬКО в дереве M →
#     «CI-код не из доверенной ревизии: scripts/toy_checker.sh» без допуска.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check:skills: FAIL: нет положительного контроля'
L4PH='check:protected: FAIL: конфликт 263/266 (известный дефект main)'
L7DORM='check:contract-frozen: FAIL: 097 изменён без новой заморозки'
L4NEW='check:protected: FAIL: конфликт 263/266 (новый запрещённый объект)'
EV='1111222233334444555566667777888899990000'

PROVERKA='#!/usr/bin/env bash
# toy-проверяльщик ключей (тело — предмет защищённого перехода, И-14в)
set -uo pipefail
printf "check:skills: PASS\n"
printf "check:scope-select: PASS\n"
'
PROVERKA_PODMENA='#!/usr/bin/env bash
# подменённое тело в дереве M: printf разрешённых терминальных строк
printf "check:skills: FAIL: нет положительного контроля\n"
printf "check:scope-select: PASS\n"
'

itog=0
sub() {  # <вариант a|b|v> <ожидаемая-фраза>
  local variant="$1" want="$2"
  local W="$Z100_BASE/main-ci-100-samovnes-$variant-$$-${RANDOM}" API_PID="" out rc TD=""
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W" "${TD:-}"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  local ex_ap2 ex_l4 ex_dorm ex_new
  ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
  ex_l4="$(z100_ex_json l4 'check:protected' forks/263-266-check-protected-content-changed-rename.md "$(z100_failsha "$L4PH")" "$(z100_def_sha l4)" "$EV" 'форк 263/266 закрыт владельцем' 2030-01-01)"
  ex_dorm="$(z100_ex_json l7 'check:contract-frozen' contracts/097-vozobnovlyaemoe-sostoyanie-zadachi.md "$(z100_failsha "$L7DORM")" "$(z100_def_sha l7)" "$EV" 'дормантная запись кандидата' 2030-01-01)"
  ex_new="$(z100_ex_json l4 'check:protected' new-forbidden-object "$(z100_failsha "$L4NEW")" "$(z100_def_sha l4)" "$EV" 'внесено только в дерево M' 2030-01-01)"
  case "$variant" in
    a) # принятая ревизия — узкий список; дерево кандидата — расширенный (дормант)
       Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
       Z100_CANDIDATE_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_dorm")" \
         z100_mir_repo "$W" ;;
    b) # p несёт доверенный список побайтно; расширенный — ТОЛЬКО в дереве M
       Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_l4")" \
       Z100_MERGE_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_l4" "$ex_new")" \
         z100_mir_repo "$W" ;;
    v) # p чист; тело проверяльщика заменено ТОЛЬКО в дереве M
       TD="$(mktemp -d "$Z100_BASE/.z100samovnes.XXXXXX")"
       mkdir -p "$TD/scripts"
       printf '%s\n' "$PROVERKA" >"$TD/scripts/toy_checker.sh"
       Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
       Z100_TRUSTED_SRC_DIR="$TD" Z100_PKG_CMD="scripts/toy_checker.sh" \
       Z100_MERGE_FILE="scripts/toy_checker.sh" Z100_MERGE_CONTENT="$PROVERKA_PODMENA" \
         z100_mir_repo "$W" ;;
  esac
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
             "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/check_skills/ ;;
      l4)  [ "$variant" = "b" ] \
             && z100_cr_add "ci (l4)" completed failure \
                    "def-sha256 $(z100_def_sha l4)⏎$L4PH⏎check:hooks: PASS" 2 forks/263-266-check-protected-content-changed-rename.md \
             || z100_cr_add "ci (l4)" completed success "$(z100_green l4)" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_samovnesenie/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_samovnesenie/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  # Оракул в памяти ДО вызова (правило 8)
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" \
     && ! printf '%s' "$out" | grep -Fq 'PR-CI допуск'; then
    printf 'ЗЕЛЕНО: red_samovnesenie/%s\n' "$variant"
  else
    printf 'КРАСНО: red_samovnesenie/%s: предмет отсутствует: ожидались rc 1 и фраза «%s» без строки допуска; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub a 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не из доверенной ревизии: registry/main-ci-exceptions.json'
sub b 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не из доверенной ревизии: registry/main-ci-exceptions.json'
sub v 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: scripts/toy_checker.sh'
exit "$itog"
