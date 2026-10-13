#!/usr/bin/env bash
# Клетка red_repeticija_gitw — инвариант И-18 контракта 100 (круг 3, Б6б):
# репетиция ЧЕРЕЗ НАСТОЯЩУЮ ДВЕРЬ gitw (не прямой вызов предполёта) — с
# фактической публикацией разрешённого пакета, отказом запрещённого и
# ТОЧНЫМ сравнением target до/после каждого прогона. Канон обмена
# переопределяется штатной ручкой обёртки GIT_EXCHANGE_GUARD_CANONICAL
# (scripts/gitw:41), ручка API — дословная GITW_PREFLIGHT_071_API. Под-входы:
# П1 (публикация разрешена): две подписанные находки, третья запись без
#     находки → rc 0, строка допуска, origin/main УПАЛ на M;
# П2 (публикация запрещена): новая находка вне списка → rc 1 с фразой,
#     origin/main НЕ двинут (оракул: target до == после; слабый оракул
#     «after ≠ M» пропускал мутанта круга 2, публиковавшего постороннюю
#     ветку в target ДО печати отказа — живой обход Б6);
# П3 (движение базы во время проверки): сдвигающий API-стаб двигает
#     origin/main при первом запросе check-runs → rc 1 «движение базы»,
#     target = точное состояние после ЕДИНСТВЕННОГО санкционированного
#     движения стенда (голова кандидата B), не просто «≠ M».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check:skills: FAIL: нет положительного контроля'
L4PH='check:protected: FAIL: конфликт 263/266 (известный дефект main)'
L7PH='check:contract-frozen: FAIL: 097 изменён без новой заморозки'
AP2NEW='check:skills: FAIL: нет положительного контроля (новый случай case_9999)'
EV='1111222233334444555566667777888899990000'

itog=0
scenario() {  # <имя> <findings: razreshennye|novaya> <сервер: plain|shifting> <ожидаемая-фраза|-> <позитив?>
  local name="$1" findings="$2" server="$3" want="$4" positive="${5:-0}"
  local W="$Z100_BASE/main-ci-100-repet-$name-$$-${RANDOM}" API_PID="" out rc before after sv PORT
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  local ex_ap2 ex_l4 ex_l7
  ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
  ex_l4="$(z100_ex_json l4 'check:protected' forks/263-266-check-protected-content-changed-rename.md "$(z100_failsha "$L4PH")" "$(z100_def_sha l4)" "$EV" 'форк 263/266 закрыт владельцем' 2030-01-01)"
  ex_l7="$(z100_ex_json l7 'check:contract-frozen' contracts/097-vozobnovlyaemoe-sostoyanie-zadachi.md "$(z100_failsha "$L7PH")" "$(z100_def_sha l7)" "$EV" 'land 097 прошёл' 2030-01-01)"
  Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_l4" "$ex_l7")" z100_mir_repo "$W"
  z100_cr_reset
  local j ap2sum
  if [ "$findings" = "novaya" ]; then ap2sum="def-sha256 $(z100_def_sha ap2)⏎$AP2NEW⏎check:scope-select: PASS"
  else ap2sum="def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS"; fi
  if [ "$server" = "shifting" ]; then
    # старый успешный запуск (suite 11) — green-оболочка для старого предиката
    for j in $(z100_jobs); do
      z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" 11
    done
  fi
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure "$ap2sum" 12 fixtures/check_skills/ ;;
      l4)  [ "$findings" = "razreshennye" ] \
             && z100_cr_add "ci (l4)" completed failure \
                    "def-sha256 $(z100_def_sha l4)⏎$L4PH⏎check:hooks: PASS" 12 forks/263-266-check-protected-content-changed-rename.md \
             || z100_cr_add "ci (l4)" completed success "$(z100_green l4)" 12 ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" 12 ;;
    esac
  done
  if [ "$server" = "shifting" ]; then
    z100_api_write_runs "$W" "1,$Z100_P,completed,success,$Z100_A,11" \
                           "2,$Z100_P,completed,failure,$Z100_A,12"
  else
    z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,12"
  fi
  z100_api_write_crs "$W"
  if [ "$server" = "shifting" ]; then
    sv="$(z100_api_serve_shifting "$W/api" "$Z100_REPO")"
  else
    sv="$(z100_api_serve "$W/api")"
  fi
  API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_repeticija/%s: стаб API не поднялся\n' "$name" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_repeticija/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$name" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  before="$(git ls-remote "$W/origin.git" refs/heads/main | cut -f1)"
  out="$(z100_gitw_run "$PORT")"; rc=$?
  after="$(git ls-remote "$W/origin.git" refs/heads/main | cut -f1)"
  local ok=0
  if [ "$positive" = "1" ]; then
    [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo' \
      && [ "$before" = "$Z100_A" ] && [ "$after" = "$Z100_M" ] && ok=1
  elif [ "$server" = "shifting" ]; then
    # П3: точное ожидаемое состояние после ЕДИНСТВЕННОГО санкционированного
    # движения стенда (сдвиг стаба A→B); публикация не произошла
    [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Fq "$want" \
      && [ "$before" = "$Z100_A" ] && [ "$after" = "$Z100_B" ] && ok=1
  else
    # П2: target НЕ ДВИНУТ (до == после) — мутант, публикующий постороннюю
    # ветку до отказа, менял target и проходил оракул «after ≠ M» (Б6)
    [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -Fq "$want" \
      && [ "$before" = "$Z100_A" ] && [ "$after" = "$before" ] && ok=1
  fi
  if [ "$ok" -eq 1 ]; then
    printf 'ЗЕЛЕНО: red_repeticija/%s (target %s→%s)\n' "$name" "${before:0:8}" "${after:0:8}"
  else
    printf 'КРАСНО: red_repeticija/%s: предмет отсутствует: ожидались rc %s, фраза «%s», target %s; факт rc=%s, target=%s, вывод: %s\n' \
      "$name" "$([ "$positive" = "1" ] && printf 0 || printf '≠0')" "$want" \
      "$([ "$positive" = "1" ] && printf 'A→M' || { [ "$server" = "shifting" ] && printf 'A→B (сдвиг стенда)' || printf 'не двинут (A==A)'; })" \
      "$rc" "${after:0:8}" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

scenario p1-razreshena    razreshennye plain    -                                                              1
scenario p2-zapreshena    novaya       plain    'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check:skills'
scenario p3-baza-dvinulas razreshennye shifting 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: движение базы: запуск не актуален'
exit "$itog"
