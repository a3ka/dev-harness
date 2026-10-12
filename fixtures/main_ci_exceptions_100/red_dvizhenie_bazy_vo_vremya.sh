#!/usr/bin/env bash
# Клетка red_dvizhenie_bazy_vo_vremya — инвариант И-16 контракта 100 (круг 2,
# Б6а): движение базы МЕЖДУ первой сверкой и допуском (отдельно от И-8в —
# статического расхождения на старте). Мир: run R2 отказавший с РАЗРЕШЁННОЙ
# находкой, base.sha == rmain == A на старте; API-стаб сдвигает origin/main на
# B при первом запросе check-runs (после выбора запуска и первой сверки).
# Честный гейт перечитывает rmain перед строкой допуска → «движение базы».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-dvizh-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

AP2PH='check:skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" z100_mir_repo "$W"

z100_cr_reset
# старый успешный запуск (suite 11) — чтобы СТАРЫЙ предикат и стабы без
# перечитывания базы допускали вход; строки suite 11 первыми
for j in $(z100_jobs); do
  z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" 11
done
# судимый запуск R2 (suite 12, больший id): ровно разрешённая находка
for j in $(z100_jobs); do
  case "$j" in
    ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
           "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 12 fixtures/check_skills/ ;;
    *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" 12 ;;
  esac
done
z100_api_write_runs "$W" "1,$Z100_P,completed,success,$Z100_A,11" \
                       "2,$Z100_P,completed,failure,$Z100_A,12"
z100_api_write_crs "$W"
# сдвигающий сервер: при первом запросе check-runs двигает origin/main A→B
sv="$(z100_api_serve_shifting "$W/api" "$Z100_REPO")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_dvizhenie_bazy_vo_vremya: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_dvizhenie_bazy_vo_vremya: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: движение базы: запуск не актуален'

out="$(z100_subject_run "$PORT")"; rc=$?
moved="$(git ls-remote "$W/origin.git" refs/heads/main | cut -f1)"
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" \
   && ! printf '%s' "$out" | grep -Fq 'PR-CI допуск'; then
  printf 'ЗЕЛЕНО: red_dvizhenie_bazy_vo_vremya (origin после прогона: %s)\n' "${moved:0:8}"
  exit 0
fi
printf 'КРАСНО: red_dvizhenie_bazy_vo_vremya: предмет отсутствует: ожидался отказ rc 1 с фразой «%s» без строки допуска; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
