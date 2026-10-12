#!/usr/bin/env bash
# Каркас миров 099 (контракт 099): общие построители toy-миров клеток.
# Никаких суждений не несёт; клетки зовут построители и держат оракул в своей памяти.
set -uo pipefail

Z99_BASE="${Z99_BASE:-/tmp/dev-harness-verify}"

# z99_reg_default — реестр перехода по умолчанию (контракт 099, Решение 2):
# 13 имён СОСТАВЛЯЮЩИХ (шаг-гранулярность; агрегата l7 нет — только l7a/l7b),
# все «-» = обязаны быть зелёными. Клетки с исключением передают свой реестр
# через Z99_BASE_DEFECTS (совет критика круга 1: построитель обязан ЧИТАТЬ
# переменную, а не всегда писать пустой файл).
z99_reg_default() {
  local n
  for n in l1 l2 l3 l4 l5 l6 l7a l7b ap1 ap2 ap3 ap4 ap5; do printf '%s\t-\n' "$n"; done
}

# z99_mir_repo <мир> [with_pr] — repo+origin; main на A (несёт доверенный реестр
# перехода config/transition_defects_099.tsv — Z99_BASE_DEFECTS или 13 имён
# по умолчанию — и проверочную поверхность .github/workflows/ci.yml +
# package.json); ветка wip/099/demo на B (автор demo, работа B).
# with_pr=1: интеграционная ветка pr/099/demo на merge M «land: wip/099/demo»
# (первый родитель A, второй B; committer merge — orchestrator, грамматика 016) +
# worktree wt на wip/099/demo (режим without_pr для клетки land_agent).
# Переменные: Z99_REPO Z99_ORIGIN Z99_A Z99_B Z99_M (M — только with_pr=1).
z99_mir_repo() {
  local w="$1" with_pr="${2:-0}"
  rm -rf "$w"; mkdir -p "$w/repo"
  git init -q -b main "$w/repo"
  git init -q --bare "$w/origin.git"
  git -C "$w/repo" remote add origin "$w/origin.git"
  g() { git -C "$w/repo" -c user.name=demo -c user.email=demo@dev-harness.local -c commit.gpgsign=false "$@"; }
  m() { git -C "$w/repo" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false "$@"; }
  g commit -q --allow-empty -m "база A"
  mkdir -p "$w/repo/config" "$w/repo/.github/workflows"
  printf '%s\n' "${Z99_BASE_DEFECTS:-$(z99_reg_default)}" > "$w/repo/config/transition_defects_099.tsv"
  printf 'name: ci\non: pull_request\njobs:\n  checks:\n    steps:\n      - run: git checkout ${{ github.event.pull_request.base.sha }} -- scripts fixtures package.json config\n      - run: bash fixtures/_krasnye_toy.sh\n' > "$w/repo/.github/workflows/ci.yml"
  printf '{"scripts":{"test":"bash fixtures/_krasnye_toy.sh"}}\n' > "$w/repo/package.json"
  # Исполняемое проверкой замыкание в ДОВЕРЕННОМ коммите A (= M^1): workflow
  # материализует его из первого родителя ДО запуска проверок (граница
  # арбитража 099 по З-5); toy-проверка l7a честно красна известным дефектом.
  mkdir -p "$w/repo/scripts" "$w/repo/fixtures"
  printf '#!/usr/bin/env bash\n# toy-проверка l7a (контракт 099, вход и клетки perechen): честный код — исполняется из M^1\nprintf "REAL CHECK EXECUTED: %%s\\n" "check_protected: конфликт 263/266 (известный дефект main)"\nexit 1\n' > "$w/repo/scripts/check_toy.sh"
  printf '#!/usr/bin/env bash\nDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"\nexec bash "$DIR/scripts/check_toy.sh"\n' > "$w/repo/fixtures/_krasnye_toy.sh"
  g add config/transition_defects_099.tsv .github package.json scripts fixtures
  g commit -q -m "доверенный реестр перехода + проверочная поверхность"
  Z99_A="$(git -C "$w/repo" rev-parse HEAD)"
  g checkout -q -b wip/099/demo
  g commit -q --allow-empty -m "работа B"
  Z99_B="$(git -C "$w/repo" rev-parse HEAD)"
  if [ "$with_pr" = "1" ]; then
    g checkout -q main
    m merge --no-ff -q -m "land: wip/099/demo

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: переходный маршрут 099 (toy)" wip/099/demo
    Z99_M="$(git -C "$w/repo" rev-parse HEAD)"
    git -C "$w/repo" branch -m main pr/099/demo
    git -C "$w/repo" branch main "$Z99_A"
  else
    git -C "$w/repo" checkout -q main
    git -C "$w/repo" worktree add -q "$w/wt" wip/099/demo
  fi
  git -C "$w/repo" push -q origin main
  git -C "$w/repo" fetch -q origin
  Z99_REPO="$w/repo"; Z99_ORIGIN="$w/origin.git"
}

# z99_subject <имя-файла> — путь субъекта клетки: D99_SUBJECTS_DIR (стаб-пак) → ROOT/scripts.
# Отказ (rc 1) = «предмет отсутствует». ROOT — Z99_099_ROOT или дерево семьи.
z99_subject() {
  local n="$1" root="${Z99_099_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  if [ -n "${D99_SUBJECTS_DIR:-}" ] && [ -f "$D99_SUBJECTS_DIR/$n" ]; then
    printf '%s' "$D99_SUBJECTS_DIR/$n"; return 0
  fi
  if [ -f "$root/scripts/$n" ]; then printf '%s' "$root/scripts/$n"; return 0; fi
  return 1
}

# z99_api_dir <мир> — корень дерева API-стаба; печатает путь.
z99_api_dir() { mkdir -p "$1/api" && printf '%s' "$1/api"; }

# z99_json_checkruns <файл> <имя:conclusion[:summary]>… — ответ check-runs API.
# conclusion: success|failure|skipped; summary — строка отказа (для failure), \n НЕ несёт.
z99_json_checkruns() {
  local f="$1"; shift
  local runs="" n=0 c name rest concl summ
  for c in "$@"; do
    n=$((n+1)); name="${c%%:*}"; rest="${c#*:}"; concl="${rest%%:*}"
    if [ "$rest" = "$concl" ]; then summ=""; else summ="${rest#*:}"; fi
    runs="${runs}{\"name\":\"${name}\",\"status\":\"completed\",\"conclusion\":\"${concl}\",\"output\":{\"summary\":\"${summ}\"},\"details_url\":\"\"},"
  done
  printf '{"total_count":%d,"check_runs":[%s]}\n' "$n" "${runs%,}" > "$f"
}

# z99_json_checkruns_empty <файл> — прогонов нет вообще.
z99_json_checkruns_empty() { printf '{"total_count":0,"check_runs":[]}\n' > "$1"; }

# z99_json_pr <файл> <номер> <head-sha> <merge-sha> — ответ /pulls/N.
z99_json_pr() { printf '{"number":%s,"head":{"sha":"%s"},"merge_commit_sha":"%s","mergeable":true,"base":{"ref":"main"}}\n' "$2" "$3" "$4" > "$1"; }

# z99_api_serve <корень-api> — python3 http.server; печатает PID:PORT (убить: kill PID).
z99_api_serve() {
  local d="$1" port pid
  port="$((20000 + RANDOM % 20000))"
  ( cd "$d" && exec python3 -m http.server "$port" --bind 127.0.0.1 ) >/dev/null 2>&1 &
  pid=$!
  printf '%s:%s' "$pid" "$port"
}

# z99_wait_api <port> — ждёт готовность стаба (до 2 с), rc 1 при неготовности.
z99_wait_api() {
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    curl -fsS -m 1 "http://127.0.0.1:$1/" >/dev/null 2>&1 && return 0
    sleep 0.2
  done
  return 1
}
