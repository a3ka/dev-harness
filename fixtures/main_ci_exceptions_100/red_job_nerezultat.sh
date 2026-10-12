#!/usr/bin/env bash
# Клетка red_job_nerezultat — инвариант И-6 контракта 100: отсутствующий job,
# skipped/neutral/cancelled/timed_out/in_progress, неразобранный результат и
# мёртвый API — каждый под-вход своим предъявлением (именованной причиной).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

itog=0
sub() {  # <вариант> <ожидаемая-фраза>
  local variant="$1" want="$2"
  local W="$Z100_BASE/main-ci-100-nerez-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  z100_mir_repo "$W"
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    if [ "$j" = "l4" ] && [ "$variant" != "absent" ]; then
      case "$variant" in
        skipped)     z100_cr_add "ci (l4)" completed skipped   "$(z100_green l4)" ;;
        neutral)     z100_cr_add "ci (l4)" completed neutral   "$(z100_green l4)" ;;
        cancelled)   z100_cr_add "ci (l4)" completed cancelled "$(z100_green l4)" ;;
        timed_out)   z100_cr_add "ci (l4)" completed timed_out "$(z100_green l4)" ;;
        in_progress) z100_cr_add "ci (l4)" in_progress null    "$(z100_green l4)" ;;
        weird)       z100_cr_add "ci (l4)" completed stale     "$(z100_green l4)" ;;
        *) ;;
      esac
    else
      [ "$j" = "l4" ] && [ "$variant" = "absent" ] && continue
      z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")"
    fi
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A"
  z100_api_write_crs "$W"
  local PORT=1
  if [ "$variant" != "deadapi" ]; then
    local sv
    sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
    z100_wait_api "$PORT" || { printf 'КРАСНО: red_job_nerezultat/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  fi
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_job_nerezultat/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_job_nerezultat/%s\n' "$variant"
  else
    printf 'КРАСНО: red_job_nerezultat/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub absent     'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 отсутствует'
sub skipped    'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 skipped'
sub neutral    'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 neutral'
sub cancelled  'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 cancelled'
sub timed_out  'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 timed_out'
sub in_progress 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 in_progress'
sub weird      'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 неразобранный результат: stale'
sub deadapi    'PR-CI не сверяем: API'
exit "$itog"
