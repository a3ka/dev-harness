#!/usr/bin/env bash
# Клетка red_pr_dopusk_sudit_merge_resultat — инвариант З-4 контракта 099:
# судится ИНТЕГРИРУЕМЫЙ РЕЗУЛЬТАТ (merge-объект), не head PR; сообщение и identity
# финального merge входят в допуск. Три входа:
#   (а) head зелёный, у merge-объекта результата нет → «нет результата»;
#   (б) merge без land:-маркера → «объект слияния без land:-маркера»;
#   (в) committer merge — агент, не доверенный компонент → «identity финального merge».
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m2).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-merge-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT

if ! SUBJ="$(z99_subject pr_dopusk.sh)"; then
  printf 'КРАСНО: red_pr_dopusk_sudit_merge_resultat: предмет отсутствует: scripts/pr_dopusk.sh\n' >&2
  exit 1
fi

ALLGREEN="l1:success l2:success l3:success l4:success l5:success l6:success l7a:success l7b:success ap1:success ap2:success ap3:success ap4:success ap5:success"

zapustit() { # <merge-sha> <head-sha> <файл-checkruns-merge> <файл-checkruns-head>
  API="$(z99_api_dir "$W")"
  mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$2"
  z99_json_pr "$API/repos/o/r/pulls/7" 7 "$2" "$1"
  if [ -n "$3" ]; then
    mkdir -p "$API/repos/o/r/commits/$1"
    if [ "$3" = "EMPTY" ]; then z99_json_checkruns_empty "$API/repos/o/r/commits/$1/check-runs"
    else z99_json_checkruns "$API/repos/o/r/commits/$1/check-runs" $ALLGREEN; fi
  fi
  if [ -n "$4" ]; then
    z99_json_checkruns "$API/repos/o/r/commits/$2/check-runs" $ALLGREEN
  fi
  if [ -z "${API_PID:-}" ]; then
    sv="$(z99_api_serve "$API")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
    z99_wait_api "$PORT" || { printf 'КРАСНО: red_pr_dopusk_sudit_merge_resultat: стаб API не поднялся\n' >&2; exit 2; }
  fi
}

ozhidat_otkaz() { # <rc> <out> <фраза> <вход>
  if [ "$1" -eq 1 ] && printf '%s' "$2" | grep -Fq "$3"; then return 0; fi
  printf 'КРАСНО: red_pr_dopusk_sudit_merge_resultat: вход %s: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
    "$4" "$3" "$1" "$(printf '%s' "$2" | head -c 300)" >&2
  exit 1
}

# ── (а) head зелёный, у merge-объекта прогонов нет ──
z99_mir_repo "$W" 1
M="$Z99_M"; B="$Z99_B"
zapustit "$M" "$B" "EMPTY" "HEAD"
out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
ozhidat_otkaz "$rc" "$out" 'нет результата' 'а'

# ── (б) merge без land:-маркера (committer — доверенный orchestrator) ──
rm -rf "$W/api"
git -C "$Z99_REPO" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
  commit -q --amend -m "слияние без маркера (toy)"
M2="$(git -C "$Z99_REPO" rev-parse HEAD)"
zapustit "$M2" "$B" "GREEN" ""
out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
ozhidat_otkaz "$rc" "$out" 'объект слияния без land:-маркера' 'б'

# ── (в) committer merge — агент implementer, маркер на месте ──
rm -rf "$W/api"
git -C "$Z99_REPO" -c user.name=implementer -c user.email=implementer@dev-harness.local \
  commit -q --amend -m "land: wip/099/demo"
M3="$(git -C "$Z99_REPO" rev-parse HEAD)"
zapustit "$M3" "$B" "GREEN" ""
out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
ozhidat_otkaz "$rc" "$out" 'identity финального merge не доверенного компонента' 'в'

printf 'ЗЕЛЕНО: red_pr_dopusk_sudit_merge_resultat\n'
exit 0
