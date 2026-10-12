#!/usr/bin/env bash
# Каркас миров 100 (контракт 100, круг 2 — блокеры Б1-Б7): общие построители
# toy-миров клеток. Никаких суждений не несёт; клетки зовут построители и
# держат оракул в своей памяти.
#
# ЕДИНЫЙ ИСТОЧНИК состава job/ключей мира: таблица Z100_JOBS ниже (префикс,
# job, ключи). Из неё строится И ci.yml доверенной ревизии, И registry/ci-steps.tsv,
# И package.json, И отпечатки def-sha256 — отдельной конвенции нет (грамматика
# из одного источника, Решение 3 контракта). Ключи несут РЕАЛЬНУЮ грамматику
# ci.yml `[a-z0-9][a-z0-9:_-]*` (совет 1 круга 1: `check:charter`,
# `check:gitw-predpolet-family-selftest` — с `:` и `-`).
set -uo pipefail

Z100_BASE="${Z100_BASE:-/tmp/dev-harness-verify}"
Z100_MIR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# <префикс> <job> <ключ1> <ключ2>  — 12 job: ap1..ap5 (antiplacebo) + l1..l7 (ci)
Z100_JOBS='
antiplacebo ap1 check:runner-hygiene check:numbers
antiplacebo ap2 check:skills check:scope-select
antiplacebo ap3 check:staged check:zones
antiplacebo ap4 check:protected check:charter
antiplacebo ap5 verify:ci-parity check:versions
ci l1 check:charter check:document
ci l2 check:gitw-predpolet-family-selftest check:ci-gate
ci l3 check:zones check:limits
ci l4 check:protected check:hooks
ci l5 check:numbers check:decisions
ci l6 check:observations check:scoped-run
ci l7 check:contract-frozen check:skills
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
# строки «<job>TAB<ключи через запятую в порядке матрицы>NL».
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

# z100_cisteps — registry/ci-steps.tsv мира (единый источник шагов, 083).
z100_cisteps() {
  local j
  printf 'job\tkeys\tcommand\n'
  for j in $(z100_jobs); do
    printf '%s\t%s\tnpm run %s\n' "$j" "$(z100_keys "$j")" "$(z100_keys "$j" | cut -d' ' -f1)"
  done
}

# z100_pkgjson — package.json мира (разрешение npm-ключей, слой определений).
z100_pkgjson() {
  local j k body=""
  for j in $(z100_jobs); do
    for k in $(z100_keys "$j"); do
      body+="    \"$k\": \"bash ci_lanes/$j.sh\","$'\n'
    done
  done
  printf '{"name":"toy-mir-100","scripts":{\n%s}}\n' "${body%??}"
}

# z100_failsha <FAIL-строка>… — устойчивый код дефекта: sha256 сортированных
# (LC_ALL=C) FAIL-строк ключа, каждая с NL (Решение 3).
z100_failsha() {
  for l in "$@"; do printf '%s\n' "$l"; done | LC_ALL=C sort | sha256sum | cut -d' ' -f1
}

# z100_ex_json <target> <key> <object> <defect_code> <check_version> <evidence> <removal> <expires>
z100_ex_json() {
  printf '{"target":"%s","key":"%s","object":"%s","defect_code":"%s","check_version":"%s","evidence_main_sha":"%s","removal_condition":"%s","expires":"%s"}' \
    "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
}

# z100_ex_list <запись>… — файл списка из записей (пусто = строгий допуск).
# ЕДИНСТВЕННАЯ конформная форма входа Решения 2 — контейнер schema/exceptions
# (Б7 круга 1: голая запись — НЕ конформный вход, а отказ схемы).
z100_ex_list() {
  if [ "$#" -eq 0 ]; then printf '{"schema":"main-ci-exceptions/1","exceptions":[]}\n'; return 0; fi
  local body="" r
  for r in "$@"; do body+="${r},"; done
  printf '{"schema":"main-ci-exceptions/1","exceptions":[%s]}\n' "${body%,}"
}

# z100_mir_repo <мир> — repo+origin: main на A (несёт доверенный список
# Z100_EXCEPTIONS_JSON или пустой + ci.yml + ci-steps.tsv + package.json; при
# Z100_NO_EXCEPTIONS_FILE=1 файла списка НЕТ — достоверное отсутствие, совет 3
# круга 1), origin/main = A; ветка wip/100/demo на B (автор demo; несёт
# Z100_CANDIDATE_EXCEPTIONS_JSON файлом дерева кандидата, если задан; несёт
# Z100_CANDIDATE_CI_FILE/Z100_CANDIDATE_CI_CONTENT — правку слоя определений
# CI кандидата, если заданы); локальный main на merge M «land: wip/100/demo»
# (первый родитель A, второй B, committer merge — orchestrator).
# Переменные: Z100_REPO Z100_ORIGIN Z100_A Z100_B Z100_M Z100_P (=B).
z100_mir_repo() {
  local w="$1" dirty=0
  rm -rf "$w"; mkdir -p "$w/repo"
  git init -q -b main "$w/repo"
  git init -q --bare "$w/origin.git"
  git -C "$w/repo" remote add origin "$w/origin.git"
  g() { git -C "$w/repo" -c user.name=demo -c user.email=demo@dev-harness.local -c commit.gpgsign=false "$@"; }
  m() { git -C "$w/repo" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false "$@"; }
  mkdir -p "$w/repo/registry" "$w/repo/.github/workflows"
  if [ "${Z100_NO_EXCEPTIONS_FILE:-0}" != "1" ]; then
    printf '%s\n' "${Z100_EXCEPTIONS_JSON:-$(z100_ex_list)}" >"$w/repo/registry/main-ci-exceptions.json"
  fi
  z100_ciyl >"$w/repo/.github/workflows/ci.yml"
  z100_cisteps >"$w/repo/registry/ci-steps.tsv"
  z100_pkgjson >"$w/repo/package.json"
  g add registry .github package.json
  g commit -q -m "доверенная база A: список исключений + ci.yml + ci-steps.tsv + package.json"
  Z100_A="$(git -C "$w/repo" rev-parse HEAD)"
  git -C "$w/repo" push -q origin main
  g checkout -q -b wip/100/demo
  if [ -n "${Z100_CANDIDATE_EXCEPTIONS_JSON:-}" ]; then
    printf '%s\n' "$Z100_CANDIDATE_EXCEPTIONS_JSON" >"$w/repo/registry/main-ci-exceptions.json"
    dirty=1
  fi
  if [ -n "${Z100_CANDIDATE_CI_FILE:-}" ]; then
    mkdir -p "$(dirname "$w/repo/$Z100_CANDIDATE_CI_FILE")"
    printf '%s\n' "${Z100_CANDIDATE_CI_CONTENT:?}" >"$w/repo/$Z100_CANDIDATE_CI_FILE"
    dirty=1
  fi
  if [ "$dirty" -eq 1 ]; then
    g add -A registry package.json .github
    g commit -q -m "дерево кандидата несёт правку доверенных файлов"
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

# z100_gitw — путь ДВЕРИ gitw: D100_SUBJECTS_DIR/gitw (стаб-пак с копией
# настоящей двери) → ROOT/scripts/gitw. Дверь всегда настоящая (байт-в-байт
# копия допустима); стаб-пак подменяет только предполёт-соседа по каталогу.
z100_gitw() {
  local root="${Z100_100_ROOT:-$(cd "$Z100_MIR_DIR/../.." && pwd)}"
  if [ -n "${D100_SUBJECTS_DIR:-}" ] && [ -f "$D100_SUBJECTS_DIR/gitw" ]; then
    printf '%s' "$D100_SUBJECTS_DIR/gitw"; return 0
  fi
  printf '%s' "$root/scripts/gitw"
}

# z100_api_dir <мир> — корень дерева API-стаба; печатает путь.
z100_api_dir() { mkdir -p "$1/api" && printf '%s' "$1/api"; }

# z100_json_runs <файл> <id,head_sha,status,conclusion,base_sha,check_suite_id>… —
# ответ /actions/runs (Б3 круга 1: runs несут check_suite id для связки
# check-runs с выбранным запуском). conclusion может быть «-» (null).
z100_json_runs() {
  local f="$1"; shift
  local runs="" r id hs st co bs cs
  for r in "$@"; do
    IFS=',' read -r id hs st co bs cs <<<"$r"
    if [ "$co" = "-" ]; then co="null"; else co="\"$co\""; fi
    runs+="{\"id\":${id},\"event\":\"pull_request\",\"head_sha\":\"${hs}\",\"status\":\"${st}\",\"conclusion\":${co},\"check_suite\":{\"id\":${cs}},\"pull_requests\":[{\"base\":{\"sha\":\"${bs}\"}}]},"
  done
  printf '{"total_count":%d,"workflow_runs":[%s]}\n' "$#" "${runs%,}" >"$f"
}

# построитель check-runs: TSV (idx TAB name TAB status TAB conclusion TAB
# suite TAB summary TAB annpaths) → JSON + failure-аннотации (Б1 круга 1:
# идентичность дефекта — структурированный путь аннотации, не только текст
# FAIL-строки; Б3: строки несут check_suite id). annpaths — пути failure-
# аннотаций через запятую, по одному на FAIL-строку summary по порядку;
# «-» = аннотаций нет. idx — сквозной номер строки (id check-run).
# z100_cr_reset [деф-suitе]; z100_cr_add <name> <status> <conclusion>
#   <summary: строки через ⏎> [suite] [annpaths]; z100_cr_flush <out>
Z100_CR=""
Z100_CR_N="0"
Z100_SUITE_DEF="2"
z100_cr_reset() { Z100_CR="$(mktemp "${TMPDIR:-/tmp}/z100cr.XXXXXX")"; : >"$Z100_CR"; Z100_CR_N="0"; Z100_SUITE_DEF="${1:-2}"; }
z100_cr_add() {
  local suite="${5:-$Z100_SUITE_DEF}" ann="${6:--}"
  Z100_CR_N=$((Z100_CR_N + 1))
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$Z100_CR_N" "$1" "$2" "$3" "$suite" "$4" "$ann" >>"$Z100_CR"
}
z100_cr_flush() {
  local apiroot idx nm st co suite summary ann
  apiroot="$(dirname "$(dirname "$(dirname "$1")")")"
  jq -R -s 'split("\n") | map(select(length > 0)) | map(split("\t"))
            | {total_count: length, check_runs: map({id: (.[0]|tonumber), name: .[1], status: .[2], conclusion: .[3], check_suite: {id: (.[4]|tonumber)}, output: {summary: (.[5] | split("⏎") | join("\n"))}})}' \
    "$Z100_CR" >"$1"
  # аннотации: для каждой строки с annpaths — failure-аннотации по одной на
  # FAIL-строку summary (по порядку), path по порядку из annpaths; id
  # check-run = idx (тот же id, что в JSON выше).
  while IFS=$'\t' read -r idx nm st co suite summary ann; do
    [ "$ann" != "-" ] || continue
    mkdir -p "$apiroot/check-runs/$idx"
    paste -d'\t' <(printf '%s' "$summary" | sed 's/⏎/\n/g' | grep -a ': FAIL: ') <(printf '%s' "$ann" | tr ',' '\n') \
      | jq -R -s 'split("\n") | map(select(length > 0)) | map(split("\t"))
                  | map({path: .[1], annotation_level: "failure", message: .[0]})' \
      >"$apiroot/check-runs/$idx/annotations"
  done <"$Z100_CR"
}

# z100_green <job> — summary зелёного job: def-sha256 + все ключи PASS.
z100_green() {
  printf 'def-sha256 %s⏎' "$(z100_def_sha "$1")"
  local k
  for k in $(z100_keys "$1"); do printf '%s: PASS⏎' "$k"; done
}

# z100_subject_run <порт> — прогон субъекта клетки (напрямую, изолированно от
# двери); печатает «rc TAB вывод». Клетки держат оракул в памяти ДО вызова
# (правило 8) — эта функция только исполняет.
z100_subject_run() {
  local port="$1"
  ( cd "$Z100_REPO" && GITW_PREFLIGHT_071_API="http://127.0.0.1:${port}/repos/o/r" \
      bash "$(z100_subject)" "$Z100_ORIGIN" push origin main 2>&1 )
}

# z100_gitw_run <порт> — прогон ЧЕРЕЗ настоящую дверь gitw (Б6б круга 1:
# репетиция с фактической публикацией/отказом и судимым target). Канон обмена
# переопределяется ручкой обёртки GIT_EXCHANGE_GUARD_CANONICAL (scripts/gitw:41)
# на toy-origin; ручка API — та же дословная GITW_PREFLIGHT_071_API.
z100_gitw_run() {
  local port="$1"
  ( cd "$Z100_REPO" \
      && GIT_EXCHANGE_GUARD_CANONICAL="$Z100_ORIGIN" \
         GITW_PREFLIGHT_071_API="http://127.0.0.1:${port}/repos/o/r" \
      bash "$(z100_gitw)" push origin main 2>&1 )
}

# z100_api_serve <корень-api> — python3 http.server (вывод подавлен внутри
# python через os.devnull); печатает PID:PORT (убить: kill PID).
z100_api_serve() {
  local d="$1" port pid
  port="$((20000 + RANDOM % 20000))"
  ( exec python3 -c '
import http.server, os, sys
sys.stdout = open(os.devnull, "w"); sys.stderr = sys.stdout
api, port = sys.argv[1], int(sys.argv[2])
srv = http.server.ThreadingHTTPServer(("127.0.0.1", port),
       lambda *a, **k: http.server.SimpleHTTPRequestHandler(*a, directory=api, **k))
srv.serve_forever()
' "$d" "$port" ) >>"$Z100_BASE/.z100_srv.log" 2>&1 &
  pid=$!
  printf '%s:%s' "$pid" "$port"
}

# z100_api_serve_shifting <корень-api> <repo> <refsrc> — сервер, который при
# ПЕРВОМ запросе к check-runs сдвигает origin/main на <refsrc> (Б6 круга 1:
# движение базы ВО ВРЕМЯ проверки, между первым сравнением и допуском).
# refsrc — имя ветки-источника (НЕ полный sha: git парсит «40hex:refs/…» как
# scp-подобный host:path и отказывает — замер живой пробой).
z100_api_serve_shifting() {
  local d="$1" repo="$2" refsrc="${3:-wip/100/demo}" port pid
  port="$((20000 + RANDOM % 20000))"
  ( exec python3 -c '
import http.server, os, subprocess, sys
sys.stdout = open(os.devnull, "w"); sys.stderr = sys.stdout
api, repo, refsrc, port = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
moved = [False]
class Shifting(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if not moved[0] and "/check-runs" in self.path:
            subprocess.run(["git", "-C", repo, "push", "-q", "origin", refsrc + ":refs/heads/main"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            moved[0] = True
        return super().do_GET()
srv = http.server.ThreadingHTTPServer(("127.0.0.1", port),
       lambda *a, **k: Shifting(*a, directory=api, **k))
srv.serve_forever()
' "$d" "$repo" "$refsrc" "$port" ) >>"$Z100_BASE/.z100_srv.log" 2>&1 &
  pid=$!
  printf '%s:%s' "$pid" "$port"
}

# z100_wait_api <port> — ждёт готовность стаба (до 2 с), rc 1 при неготовности.
z100_wait_api() {
  local i junk
  for i in 1 2 3 4 5 6 7 8 9 10; do
    junk="$(curl -fsS -m 1 "http://127.0.0.1:$1/" 2>&1)" && return 0
    sleep 0.2
  done
  return 1
}

# z100_api_write_runs <мир> «id,head,status,concl,base,suite»… — пишет ответ /actions/runs.
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
