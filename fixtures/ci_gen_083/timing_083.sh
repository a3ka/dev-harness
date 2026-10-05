#!/usr/bin/env bash
# А3-предикат тайминга (контракт 083): «самая долгая lane-джоба семейства ci
# ≤ 360 с; отмен по таймауту в зелёном окне ветки — 0» как RC-КОМАНДА, не
# просмотр данных. Судья гоняет её на ветке предмета (первый ЗАКОНЧЕННЫЙ
# прогон перестроенной джобы ci), ДО лендинга: rc 0 — порог держится,
# лендинг не блокирован таймингом; rc 1 — именованное нарушение; rc 2 —
# данных нет (gh недоступен / нет законченных прогонов ветки) — НЕ зелёное.
# Печать никогда не говорит PASS (rc — истина).
#
# Использование: bash fixtures/ci_gen_083/timing_083.sh <ветка> [предельная-долгота-с]
#   <ветка>                    — ветка предмета (wip/083/...), обязательна;
#   [предельная-долгота-с]     — порог секундаами, по умолчанию 360 (§9.2).
set -uo pipefail
[ $# -ge 1 ] && [ -n "$1" ] || { printf 'timing_083 ОТКАЗ: назови ветку (аргумент 1)\n' >&2; exit 2; }
BR="$1"
LIMIT="${2:-360}"
command -v gh >/dev/null 2>&1 || { printf 'timing_083 ОТКАЗ: нет gh CLI — данные живого CI недоступны\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'timing_083 ОТКАЗ: нет jq\n' >&2; exit 2; }
TIMING_TMP="$(mktemp -d "${TMPDIR:-/tmp}/timing-083.XXXXXX")" || { printf 'timing_083 ОТКАЗ: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$TIMING_TMP"' EXIT

# 1) законченные прогоны ветки (limit 20 — «зелёное окно» §9.2); пусто → rc 2.
gh run list --branch "$BR" --limit 20 --json databaseId,status,conclusion,displayTitle \
  > "$TIMING_TMP/runs.json" 2>"$TIMING_TMP/gh.err" \
  || { printf 'timing_083 ОТКАЗ: gh run list отказал: %s\n' "$(cat "$TIMING_TMP/gh.err")" >&2; exit 2; }
done_ids="$(jq -r '[.[] | select(.status=="completed")] | .[].databaseId' "$TIMING_TMP/runs.json")"
[ -n "$done_ids" ] || { printf 'timing_083 ОТКАЗ: ни одного законченного прогона на ветке %s — тайминг не судим (НЕ зелёное)\n' "$BR" >&2; exit 2; }

rc=0
max_sec=0; max_job=""
viol_timedout=0
# 2) по каждому законченному прогону: (а) отмены — отменённый прогон, чья
# самая долгая джоба семейства ci упёрлась в таймаут, считается отменой по
# таймауту; (б) длительность lane-джоб ci (без суффиксов matrix «(lane)» —
# фильтр по префиксу имени).
for id in $done_ids; do
  gh run view "$id" --json jobs,conclusion > "$TIMING_TMP/view.json" 2>/dev/null || continue
  while IFS=$'\t' read -r jname jstatus jconc t0 t1; do
    [ -n "$jname" ] || continue
    case "$jname" in
      ci*)
        sec=$(( $(date -d "$t1" +%s) - $(date -d "$t0" +%s) ))
        if [ "$sec" -gt "$max_sec" ]; then max_sec="$sec"; max_job="$jname"; fi
        if [ "$jstatus" = "completed" ] && [ "$jconc" = "cancelled" ]; then
          viol_timedout=$((viol_timedout+1))
          printf 'timing_083 НАРУШЕНИЕ: отмена джобы ci в прогоне %s: %s\n' "$id" "$jname" >&2
        fi
        ;;
    esac
  done < <(jq -r '.jobs[] | [.name, .status, .conclusion, .startedAt, .completedAt] | @tsv' "$TIMING_TMP/view.json")
done
[ "$max_sec" -gt 0 ] || { printf 'timing_083 ОТКАЗ: среди законченных прогонов ветки %s нет джоб семейства ci — тайминг не судим (НЕ зелёное)\n' "$BR" >&2; exit 2; }
if [ "$max_sec" -gt "$LIMIT" ]; then
  printf 'timing_083 НАРУШЕНИЕ: самая долгая lane-джоба ci = %s с (> %s): %s\n' "$max_sec" "$LIMIT" "$max_job" >&2
  rc=1
fi
if [ "$viol_timedout" -ne 0 ]; then
  printf 'timing_083 НАРУШЕНИЕ: отмен джоб ci в зелёном окне ветки — %s (ожидалось 0)\n' "$viol_timedout" >&2
  rc=1
fi
[ "$rc" -eq 0 ] && printf 'timing_083: самая долгая lane-джоба ci = %s с ≤ %s, отмен — 0\n' "$max_sec" "$LIMIT" >&2
exit "$rc"
