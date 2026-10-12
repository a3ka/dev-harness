#!/usr/bin/env bash
# Каркас миров 100 (контракт 100): общие построители toy-миров клеток.
# Никаких суждений не несёт; клетки зовут построители и держат оракул в своей памяти.
#
# ЕДИНЫЙ ИСТОЧНИК состава job/ключей мира: таблица Z100_JOBS ниже (префикс, job, ключи).
# Из неё строится И ci.yml доверенной ревизии, И отпечатки def-sha256 — отдельной
# конвенции нет (грамматика из одного источника, Решение 3 контракта).
set -uo pipefail

Z100_BASE="${Z100_BASE:-/tmp/dev-harness-verify}"
Z100_MIR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# <префикс> <job> <ключ1> <ключ2>  — 12 job: ap1..ap5 (antiplacebo) + l1..l7 (ci)
Z100_JOBS='
antiplacebo ap1 check_runner_hygiene pre_critic
antiplacebo ap2 check_skills check_scope_select
antiplacebo ap3 check_staged check_zones
antiplacebo ap4 check_protected check_charter
antiplacebo ap5 verify_ci_parity check_ids
ci l1 check_charter check_document
ci l2 check_gitw_predpolet check_ci_gate
ci l3 check_zones check_ceilings
ci l4 check_protected check_hooks
ci l5 check_ids check_decisions
ci l6 check_nabludenia check_scoped_run
ci l7 check_contract_frozen check_skills
'

# z100_prefix <job> / z100_keys <job> — колонки таблицы по job.
z100_prefix() {
  awk -v j="$1" 'NF>=3 && $2==j {print $1; exit}' <<<"$Z100_JOBS"
}
z100_keys() {
  awk -v j="$1" 'NF>=3 && $2==j {$1=""; $2=""; sub(/^  */,""); print; exit}' <<<"$Z100_JOBS"
}
# z100_jobs — все job id через пробел (в порядке таблицы).
z100_jobs() { awk 'NF>=3 {print $2}' <<<"$Z100_JOBS" | tr '\n' ' ' | sed 's/ $//'; }

# z100_def_sha <job> — отпечаток определения (Решение 3): sha256 канонической
# строки «<job>\t<ключи через запятую в порядке матрицы>\n».
z100_def_sha() {
  printf '%s\t%s\n' "$1" "$(z100_keys "$1" | tr ' ' ',')" | sha256sum | cut -d' ' -f1
}

# z100_ciyl — ci.yml доверенной ревизии мира (матрицы include, формат генератора 083).
z100_ciyl() {
  printf 'name: ci\non: pull_request\njobs:\n'
  local p seen="" j
  for j in $(z100_jobs); do
    p="$(z100_prefix "$j")"
    if ! grep -Fxq "$p" <<<"$seen"; then
      seen+="$p"$'\n'
      printf '  %s:\n    runs-on: ubuntu-latest\n    strategy:\n      matrix:\n        include:\n' "$p"
    fi
    printf '          - %s: %s\n            keys: %s\n' \
      "$([ "${j#ap}" != "$j" ] && printf shard || printf lane)" "$j" "$(z100_keys "$j")"
  done
}

# z100_failsha <FAIL-строка>… — устойчивый код дефекта: sha256 сортированных
# (LC_ALL=C) FAIL-строк ключа, каждая с \n (Решение 3).
z100_failsha() {
  for l in "$@"; do printf '%s\n' "$l"; done | LC_ALL=C sort | sha256sum | cut -d' ' -f1
}

# z100_ex_json <target> <key> <object> <defect_code> <check_version> <evidence> <removal> <expires>
z100_ex_json() {
  printf '{"target":"%s","key":"%s","object":"%s","defect_code":"%s","check_version":"%s","evidence_main_sha":"%s","removal_condition":"%s","expires":"%s"}' \
    "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
}

# z100_ex_list <запись>… — файл списка из записей (пусто = строгий допуск).
z100_ex_list() {
  if [ "$#" -eq 0 ]; then printf '{"schema":"main-ci-exceptions/1","exceptions":[]}\n'; return 0; fi
  local body="" r
  for r in "$@"; do body+="${r},"; done
  printf '{"schema":"main-ci-exceptions/1","exceptions":[%s]}\n' "${body%,}"
}

# z100_mir_repo <мир> — repo+origin: main на A (несёт доверенный список
# Z100_EXCEPTIONS_JSON или пустой + ci.yml), origin/main = A; ветка wip/100/demo на B
# (автор demo; несёт Z100_CANDIDATE_EXCEPTIONS_JSON файлом дерева кандидата, если задан);
# локальный main на merge M «land: wip/100/demo» (первый родитель A, второй B,
# committer merge — orchestrator). Переменные: Z100_REPO Z100_ORIGIN Z100_A Z100_B Z100_M Z100_P (=B).
z100_mir_repo() {
  local w="$1"
  rm -rf "$w"; mkdir -p "$w/repo"
  git init -q -b main "$w/repo"
  git init -q --bare "$w/origin.git"
  git -C "$w/repo" remote add origin "$w/origin.git"
  g() { git -C "$w/repo" -c user.name=demo -c user.email=demo@dev-harness.local -c commit.gpgsign=false "$@"; }
  m() { git -C "$w/repo" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false "$@"; }
  mkdir -p "$w/repo/registry" "$w/repo/.github/workflows"
  printf '%s\n' "${Z100_EXCEPTIONS_JSON:-$(z100_ex_list)}" > "$w/repo/registry/main-ci-exceptions.json"
  z100_ciyl > "$w/repo/.github/workflows/ci.yml"
  g add registry .github
  g commit -q -m "доверенная база A: список исключений + ci.yml"
  Z100_A="$(git -C "$w/repo" rev-parse HEAD)"
  git -C "$w/repo" push -q origin main
  g checkout -q -b wip/100/demo
  if [ -n "${Z100_CANDIDATE_EXCEPTIONS_JSON:-}" ]; then
    printf '%s\n' "$Z100_CANDIDATE_EXCEPTIONS_JSON" > "$w/repo/registry/main-ci-exceptions.json"
    g add registry
    g commit -q -m "дерево кандидата несёт подменённый список"
  else
    g commit -q --allow-empty -m "работа B"
  fi
  Z100_B="$(git -C "$w/repo" rev-parse HEAD)"
  g checkout -q main
  m merge --no-ff -q -m "land: wip/100/demo

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: переходный допуск 100 (toy)" wip/100/demo
  Z100_M="$(git -C "$w/repo" rev-parse HEAD)"
  Z100_P="$Z100_B"
  Z100_REPO="$w/repo"; Z100_ORIGIN="$w/origin.git"
}

# z100_subject — путь субъекта клетки: D100_SUBJECTS_DIR (стаб-пак) → ROOT/scripts.
# Отказ (rc 1) = «предмет отсутствует».
z100_subject() {
  local root="${Z100_100_ROOT:-$(cd "$Z100_MIR_DIR/../.." && pwd)}"
  if [ -n "${D100_SUBJECTS_DIR:-}" ] && [ -f "$D100_SUBJECTS_DIR/gitw_preflight_071.sh" ]; then
    printf '%s' "$D100_SUBJECTS_DIR/gitw_preflight_071.sh"; return 0
  fi
  if [ -f "$root/scripts/gitw_preflight_071.sh" ]; then printf '%s' "$root/scripts/gitw_preflight_071.sh"; return 0; fi
  return 1
}

# z100_api_dir <мир> — корень дерева API-стаба; печатает путь.
z100_api_dir() { mkdir -p "$1/api" && printf '%s' "$1/api"; }

# z100_json_runs <файл> <id,head_sha,status,conclusion,base_sha>… — ответ /actions/runs.
# conclusion может быть «-» (несуществующее поле → null).
z100_json_runs() {
  local f="$1"; shift
  local runs="" r id hs st co bs
  for r in "$@"; do
    IFS=',' read -r id hs st co bs <<<"$r"
    if [ "$co" = "-" ]; then co="null"; else co="\"$co\""; fi
    runs+="{\"id\":${id},\"event\":\"pull_request\",\"head_sha\":\"${hs}\",\"status\":\"${st}\",\"conclusion\":${co},\"pull_requests\":[{\"base\":{\"sha\":\"${bs}\"}}]},"
  done
  printf '{"total_count":%d,"workflow_runs":[%s]}\n' "$#" "${runs%,}" > "$f"
}

# ── построитель check-runs: TSV (name TAB status TAB conclusion TAB summary) → JSON ──
# z100_cr_reset; z100_cr_add <name> <status> <conclusion> <summary: строки через ⏎>; z100_cr_flush <out>
Z100_CR=""
z100_cr_reset() { Z100_CR="$(mktemp "${TMPDIR:-/tmp}/z100cr.XXXXXX")"; : > "$Z100_CR"; }
z100_cr_add() { printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" >> "$Z100_CR"; }
z100_cr_flush() {
  jq -R -s 'split("\n") | map(select(length > 0)) | map(split("\t"))
            | {total_count: length, check_runs: map({name: .[0], status: .[1], conclusion: .[2], output: {summary: (.[3] | split("⏎") | join("\n"))}})}' \
    "$Z100_CR" > "$1"
}

# z100_green <job> — summary зелёного job: def-sha256 + все ключи PASS.
z100_green() {
  printf 'def-sha256 %s⏎' "$(z100_def_sha "$1")"
  local k
  for k in $(z100_keys "$1"); do printf '%s: PASS⏎' "$k"; done
}

# z100_subject_run <порт> — прогон субъекта в мире; печатает «rc<TAB>вывод».
# Клетки держат оракул в памяти ДО вызова (правило 8) — эта функция только исполняет.
z100_subject_run() {
  local port="$1"
  ( cd "$Z100_REPO" && GITW_PREFLIGHT_071_API="http://127.0.0.1:${port}/repos/o/r" \
      bash "$(z100_subject)" "$Z100_ORIGIN" push origin main 2>&1 )
}

# z100_api_serve <корень-api> — python3 http.server; печатает PID:PORT (убить: kill PID).
z100_api_serve() {
  local d="$1" port pid
  port="$((20000 + RANDOM % 20000))"
  ( cd "$d" && exec python3 -m http.server "$port" --bind 127.0.0.1 ) >/dev/null 2>&1 &
  pid=$!
  printf '%s:%s' "$pid" "$port"
}

# z100_wait_api <port> — ждёт готовность стаба (до 2 с), rc 1 при неготовности.
z100_wait_api() {
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    curl -fsS -m 1 "http://127.0.0.1:$1/" >/dev/null 2>&1 && return 0
    sleep 0.2
  done
  return 1
}

# z100_api_write_runs <мир> «id,head,status,concl,base»… — пишет ответ /actions/runs.
z100_api_write_runs() {
  local w="$1"; shift
  mkdir -p "$w/api/repos/o/r/actions"
  z100_json_runs "$w/api/repos/o/r/actions/runs" "$@"
}

# z100_api_write_crs <мир> — пишет ответ /commits/<p>/check-runs из Z100_CR TSV.
z100_api_write_crs() {
  mkdir -p "$1/api/repos/o/r/commits/$Z100_P"
  z100_cr_flush "$1/api/repos/o/r/commits/$Z100_P/check-runs"
}
