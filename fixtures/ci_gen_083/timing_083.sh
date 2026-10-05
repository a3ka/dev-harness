#!/usr/bin/env bash
# А3-предикат тайминга (контракт 083): «самая долгая lane-джоба семейства ci
# ≤ 360 с; отмен по таймауту в зелёном окне ветки — 0» как RC-КОМАНДА, не
# просмотр данных. Судья гоняет её на ветке предмета ДО лендинга, по окну
# ЗАКОНЧЕННЫХ прогонов ветки (до 20, gh run list --limit 20 — «зелёное окно»
# §9.2): rc 0 — порог держится по ВСЕМУ прочитанному окну, лендинг не
# блокирован таймингом; rc 1 — именованное нарушение (порог/отмена); rc 2 —
# данных нет (gh недоступен, нет законченных прогонов ветки, ЛИБО отказ
# gh run view / jq по любому прогону окна — окно прочитано НЕ полностью)
# — НЕ зелёное. Максимум и счётчик отмен считаются ТОЛЬКО по полностью
# прочитанному окну: исключить непрочитанный прогон из max — запрещено
# (арбитраж 083-krug2 П2); приёмка ждёт данных повтором команды, порог
# не обнуляется. Печать никогда не говорит PASS (rc — истина).
#
# v+1 (аргумент 3 — граничный run-id, слово владельца 2026-10-05, Вариант 2
# docs/owner/2026-10-05-a3-pr-vs-push-analiz.md): при заданном аргументе 3
# окно — завершённые прогоны ветки, созданные СТРОГО позже граничного
# (по createdAt; сама граница и всё до неё — переходные холодные, не
# судятся); в окне после границы — не менее 2 завершённых прогонов, иначе
# rc 2 «мало данных» (НЕ зелёное). Граница фиксируется ДО приёмочного
# прогона как аргумент команды — тот же статус, что порог: локальной
# интерпретации ПОСЛЕ прогона нет. Без аргумента 3 — прежнее поведение.
#
# Использование: bash fixtures/ci_gen_083/timing_083.sh <ветка> [предельная-долгота-с] [граничный-run-id]
#   <ветка>                    — ветка предмета (wip/083/...), обязательна;
#   [предельная-долгота-с]     — порог секундаами, по умолчанию 360 (§9.2);
#   [граничный-run-id]         — v+1: последний холодный прогон ветки; окно —
#                                строго позже него (createdAt), минимум 2 прогона.
set -uo pipefail
[ $# -ge 1 ] && [ -n "$1" ] || { printf 'timing_083 ОТКАЗ: назови ветку (аргумент 1)\n' >&2; exit 2; }
BR="$1"
LIMIT="${2:-360}"
BOUNDARY="${3:-}"
if [ -n "$BOUNDARY" ] && ! printf '%s' "$BOUNDARY" | grep -Eq '^[0-9]+$'; then
  printf 'timing_083 ОТКАЗ: аргумент 3 (граничный run-id) — не целое число: «%s»\n' "$BOUNDARY" >&2
  exit 2
fi
command -v gh >/dev/null 2>&1 || { printf 'timing_083 ОТКАЗ: нет gh CLI — данные живого CI недоступны\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'timing_083 ОТКАЗ: нет jq\n' >&2; exit 2; }
TIMING_TMP="$(mktemp -d "${TMPDIR:-/tmp}/timing-083.XXXXXX")" || { printf 'timing_083 ОТКАЗ: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$TIMING_TMP"' EXIT

# 1) законченные прогоны ветки (limit 20 — «зелёное окно» §9.2); пусто → rc 2.
gh run list --branch "$BR" --limit 20 --json databaseId,status,conclusion,displayTitle,createdAt \
  > "$TIMING_TMP/runs.json" 2>"$TIMING_TMP/gh.err" \
  || { printf 'timing_083 ОТКАЗ: gh run list отказал: %s\n' "$(cat "$TIMING_TMP/gh.err")" >&2; exit 2; }
done_ids="$(jq -r '[.[] | select(.status=="completed")] | .[].databaseId' "$TIMING_TMP/runs.json")"
[ -n "$done_ids" ] || { printf 'timing_083 ОТКАЗ: ни одного законченного прогона на ветке %s — тайминг не судим (НЕ зелёное)\n' "$BR" >&2; exit 2; }

# 1б) v+1: граница (аргумент 3) — окно СТРОГО позже граничного прогона по
# createdAt (id границы исключён явно; прогон с createdAt, РАВНЫМ граничному,
# не входит — «строго позже» по мандату: стартовавший в одну секунду с
# границей мог восстановить только холодный кеш); меньше 2 завершённых
# прогонов после границы — rc 2 «мало данных» (НЕ зелёное). Граница вне
# списка последних 20 разрешается живым gh run view (её createdAt), отказ —
# rc 2 с именем и stderr.
if [ -n "$BOUNDARY" ]; then
  b_created="$(jq -r --argjson b "$BOUNDARY" 'first(.[] | select(.databaseId==$b) | .createdAt) // empty' "$TIMING_TMP/runs.json")"
  if [ -z "$b_created" ]; then
    if ! gh run view "$BOUNDARY" --json createdAt > "$TIMING_TMP/b.json" 2> "$TIMING_TMP/b.err"; then
      printf 'timing_083 ОТКАЗ: граничный прогон %s вне окна ветки %s и gh run view отказал: %s\n' "$BOUNDARY" "$BR" "$(cat "$TIMING_TMP/b.err")" >&2
      exit 2
    fi
    b_created="$(jq -r '.createdAt // empty' "$TIMING_TMP/b.json" 2>"$TIMING_TMP/bjq.err")" \
      || { printf 'timing_083 ОТКАЗ: jq отказал на createdAt граничного прогона %s: %s\n' "$BOUNDARY" "$(cat "$TIMING_TMP/bjq.err")" >&2; exit 2; }
    [ -n "$b_created" ] || { printf 'timing_083 ОТКАЗ: граничный прогон %s без createdAt — граница не разрешима (НЕ зелёное)\n' "$BOUNDARY" >&2; exit 2; }
  fi
  B_EPOCH="$(date -d "$b_created" +%s)" \
    || { printf 'timing_083 ОТКАЗ: createdAt границы %s не читается датой (НЕ зелёное)\n' "$b_created" >&2; exit 2; }
  filt=""; n_after=0
  while read -r rid rcreated; do
    [ -n "$rid" ] || continue
    [ -n "$rcreated" ] || { printf 'timing_083 ОТКАЗ: прогон %s без createdAt — окно не разрешимо (НЕ зелёное)\n' "$rid" >&2; exit 2; }
    repoch="$(date -d "$rcreated" +%s)" \
      || { printf 'timing_083 ОТКАЗ: createdAt прогона %s не читается датой: %s (НЕ зелёное)\n' "$rid" "$rcreated" >&2; exit 2; }
    if [ "$rid" != "$BOUNDARY" ] && [ "$repoch" -gt "$B_EPOCH" ]; then
      filt="$filt $rid"; n_after=$((n_after+1))
    fi
  done < <(jq -r '.[] | select(.status=="completed") | "\(.databaseId) \(.createdAt)"' "$TIMING_TMP/runs.json")
  [ "$n_after" -ge 2 ] || { printf 'timing_083 ОТКАЗ: после границы %s завершённых прогонов — %s (< 2): мало данных (НЕ зелёное; приёмка ждёт прогонов повтором команды, граница не двигается)\n' "$BOUNDARY" "$n_after" >&2; exit 2; }
  done_ids="${filt# }"
fi

rc=0
max_sec=0; max_job=""
viol_timedout=0
# 2) по каждому законченному прогону: (а) отмены — отменённый прогон, чья
# самая долгая джоба семейства ci упёрлась в таймаут, считается отменой по
# таймауту; (б) длительность lane-джоб ci (без суффиксов matrix «(lane)» —
# фильтр по префиксу имени).
for id in $done_ids; do
  # окно обязано быть прочитано ЦЕЛИКОМ (арбитраж 083-krug2 П2): любой отказ
  # gh run view или jq на его ответе — немедленный rc 2 с id прогона и stderr;
  # stderr gh сохраняется в файл и печатается (2>/dev/null запрещён — отказ
  # обязан быть НАЗВАН, прецедент gh run list выше).
  if ! gh run view "$id" --json jobs,conclusion > "$TIMING_TMP/view.json" 2> "$TIMING_TMP/view.err"; then
    printf 'timing_083 ОТКАЗ: gh run view отказал на прогоне %s: %s\n' "$id" "$(cat "$TIMING_TMP/view.err")" >&2
    printf 'timing_083 ОТКАЗ: окно ветки %s прочитано НЕ полностью — максимум/отмены НЕ судимы (НЕ зелёное; приёмка ждёт данных повтором команды)\n' "$BR" >&2
    exit 2
  fi
  if ! jq -r '.jobs[] | [.name, .status, .conclusion, .startedAt, .completedAt] | @tsv' \
       "$TIMING_TMP/view.json" > "$TIMING_TMP/jobs.tsv" 2> "$TIMING_TMP/jq.err"; then
    printf 'timing_083 ОТКАЗ: jq отказал на ответе gh run view прогона %s: %s\n' "$id" "$(cat "$TIMING_TMP/jq.err")" >&2
    printf 'timing_083 ОТКАЗ: окно ветки %s прочитано НЕ полностью — максимум/отмены НЕ судимы (НЕ зелёное)\n' "$BR" >&2
    exit 2
  fi
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
  done < "$TIMING_TMP/jobs.tsv"
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
if [ "$rc" -eq 0 ]; then
  if [ -n "$BOUNDARY" ]; then
    printf 'timing_083: самая долгая lane-джоба ci = %s с ≤ %s, отмен — 0 (окно после границы %s)\n' "$max_sec" "$LIMIT" "$BOUNDARY" >&2
  else
    printf 'timing_083: самая долгая lane-джоба ci = %s с ≤ %s, отмен — 0\n' "$max_sec" "$LIMIT" >&2
  fi
fi
exit "$rc"
