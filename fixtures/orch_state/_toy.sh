# fixtures/orch_state/_toy.sh — каркас toy-миров семьи orch_state (контракт 092
# «возобновляемое состояние задачи»). Имя НЕ red_*/case_*: сам он фикстурой не
# является. Подключают его раннер fixtures/_krasnye_092.sh (список субъектов),
# клетки red_*.sh, зелёные клетки green/case_*.sh и стаб-пак battery_stubs.sh.
# При подключении — только определения и скратч, побочных действий вне скратча нет.
#
# ЧТО ДАЁТ:
#  * O92_SUBJECTS — ЕДИНСТВЕННЫЙ список «предмет присутствует»
#    (scripts/orch_checkpoint.sh, scripts/orch_status.sh, scripts/ci_wait.sh);
#    раннер читает его отсюда, второй копии списка нет.
#  * Константы грамматики — побайтово из контракта 092 (И-2/И-3/И-4): литералы
#    строк состояния/журнала/статуса, тела ответов toy-API. Стаб-пак передаёт их
#    мини-субъектам env-ом O92L_* — единый источник, побайтово (прецедент H91L_*).
#  * МОДЕЛЬ МИРА В ПАМЯТИ (W_*): семь полей состояния + журнал событий — как
#    значения в переменных; toy-файлы пишутся ИЗ модели, оракул (ожидаемые строки
#    статуса, счёт кругов, sha256 до/после) — ТОЛЬКО из модели (правило 8:
#    ожидание — в памяти проверяющего ДО вызова субъекта; диск субъекта не
#    перечитывается как истина).
#  * Построители: o92_toy — toy-репозиторий (git init, origin,
#    refs/remotes/origin/main) + каталог состояния ВНЕ дерева (шов
#    ORCH_STATE_DIR, Р1/И-1); o92_pub_git — git-факты достижимости кандидата;
#    o92_story_dva_fajla — вердикт-файлы в двух блобах (реальные blob-sha);
#    o92_api_responses — toy-API GitHub (HTTP check-runs, счётчик и времена
#    запросов в логе — оракул в скратче проверяющего).
#  * Прогон субъекта o92_probe <mode>: rc/stdout/stderr в файлах скратча;
#    субъекты задаются env O92_SUBJ_CHECKPOINT / O92_SUBJ_STATUS / O92_SUBJ_CIWAIT
#    (умолчания — $O92_ROOT/scripts/…); стаб-пак подставляет туда мини-субъекты.
#
# ГЕРМЕТИЧНОСТЬ: git-вызовы батареи — с -C и снятыми GIT_DIR/GIT_WORK_TREE/
# GIT_CONFIG* (И-9); toy-репозитории и ожидания живут в скратче mktemp; состояние
# — всегда в переопределённом шве ORCH_STATE_DIR (каталог скратча), умолчание
# /tmp/dev-harness-verify/orch-state клетками НЕ трогается.

O92_SUBJECTS=(scripts/orch_checkpoint.sh scripts/orch_status.sh scripts/ci_wait.sh)

# o92_missing_subjects <корень> — печатает через пробел отсутствующие субъекты.
o92_missing_subjects() {
  local root="$1" s miss=''
  for s in "${O92_SUBJECTS[@]}"; do
    [ -f "$root/$s" ] || miss="$miss $s"
  done
  printf '%s' "${miss# }"
}

# ── Грамматика контракта 092 (побайтово; И-2/И-3/И-4) ───────────────────────────────────
# Именованные строки (единый источник — здесь; стаб-пак несёт их мини-субъектам env-ом):
O92L_ZAPIS='уже записано'                              # дедуп-но-op журнала (Р5)
O92L_NEIZV='удалённое состояние: неизвестно'           # недоступный GitHub (И-4)
O92L_OPUBL_PRE='уже опубликовано: '                    # отказ повторной публикации (Р5)
O92L_ZAPFAIL='запись состояния не удалась'             # отказ записи (И-1)
O92L_NEDOKAZ_PRE='публикация не доказана: '            # put published без доказательства (И-8)
O92L_GRAMM_PRE='состояние вне грамматики: '            # отказ грамматики (И-2)
O92L_KRUGOV_PRE='кругов: '                             # счёт кругов (И-3)
O92L_PREDEL='предел: арбитр'                           # три круга (И-3)
O92L_OPUBL_DA='опубликовано: да'                       # И-4а — ДВЕ отдельные строки,
O92L_OPUBL_NET='опубликовано: нет'                     #   не одна лампа (Д4)
O92L_ZAKR='закрытие: завершено'
O92L_NEZAKR='закрытие: не завершено'
O92L_NETSOST='состояние отсутствует'                     # именованный отказ orch_status при отсутствии состояния (И-4; adversary круг 1, находка 1)
O92L_CHUZH_PUBDONE='pub-done чужой задачи или кандидата'  # именованный отказ event pub-done мимо текущей task/candidate (И-8; adversary круг 1, находка 2)
# Тела ответов toy-API (GitHub check-runs; Р6):
O92_RESP_INPROG='{"total_count":1,"check_runs":[{"id":101,"name":"ci-toy","status":"in_progress","conclusion":null}]}'
O92_RESP_SUCCESS='{"total_count":1,"check_runs":[{"id":101,"name":"ci-toy","status":"completed","conclusion":"success"}]}'
O92_RESP_FAILURE='{"total_count":1,"check_runs":[{"id":101,"name":"ci-toy","status":"completed","conclusion":"failure"}]}'
# Порядок клеток семьи (единый список для раннера и стаб-пака):
O92_RED_CELLS=(red_net_off_local_survives.sh red_restart_continues_subject.sh
  red_ciwait_no_repoll.sh red_restart_no_dup_task.sh red_restart_no_dup_round.sh
  red_restart_no_dup_publish.sh red_three_fails_three_rounds.sh red_pub_vs_close.sh
  red_status_derives_not_echo.sh red_checkpoint_atomic_fail.sh
  red_checkpoint_grammar.sh red_state_outside_tree.sh
  red_rounds_count_events_not_files.sh red_ciwait_net_vs_timeout.sh
  red_pub_state_needs_proof.sh red_status_no_state_refusal.sh
  red_pub_done_mismatch_refusal.sh)
O92_CASE_CELLS=(case_checkpoint_roundtrip.sh case_status_green.sh
  case_ciwait_green.sh case_events_idempotent_green.sh)

O92_ROOT="${O92_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)}" \
  || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }

O92SCR="$(mktemp -d "${TMPDIR:-/tmp}/orchstate092.XXXXXX")" \
  || { printf 'NOT_IMPLEMENTED: нет скратча\n' >&2; exit 2; }

O92_RED=0

# ── Случайность (bash RANDOM; значения случайны на прогон — демаркация §019:
#    инвариантность к значениям при конформной грамматике) ───────────────────────────────
o92_rnd() { O92_R=$(( (RANDOM * 32768 + RANDOM) % $1 )); }
o92_pick() { local a=("$@"); o92_rnd "${#a[@]}"; O92_P="${a[$O92_R]}"; }

# o92_rnd_line — КОНФОРМНАЯ непустая строка next_step: без TAB/управляемых,
# 8–70 байт, печатные (кириллица/латиница/цифры/пунктуация). Слова не включают
# «шаг» — случайность не порождает литералы клеток («шаг А»/«шаг Б»).
o92_rnd_line() {
  local words=('состояние' 'чекпойнт' 'ветка' 'тег' 'прогон' 'красная' 'зелёная'
    'файл' 'строка' 'байт' 'отказ' 'причина' 'сессия' 'субагент' 'заморозка'
    'контракт' 'реестр' 'порог' 'архив' 'ротация' 'маркер' 'пара' 'трек'
    'источник' 'owner' 'verdict' 'wip' 'main' 'CI' 'git' 'bash' 'python3'
    'sha256' 'cmp' 'grep' 'awk' 'HEAD' 'PR' 'run' 'ожидание' 'кандидат')
  local n i w line
  o92_rnd 6; n=$((O92_R + 2))
  line=''
  for ((i = 0; i < n; i++)); do
    o92_pick "${words[@]}"; w="$O92_P"
    case $i in
      0) o92_rnd 4; case $O92_R in 0) line="- $w" ;; 1) line="$w:" ;; 2) line="**$w** —" ;; *) line="$w" ;; esac ;;
      *) line="$line $w" ;;
    esac
  done
  o92_rnd 4
  case $O92_R in
    0) line="$line." ;;
    1) line="$line;" ;;
    2) line="$line ($w)" ;;
    *) line="$line," ;;
  esac
  O92_LINE="$line"
}

# o92_rnd_task — конформный task-id: [0-9]{3} либо печатный токен (И-2).
o92_rnd_task() {
  o92_rnd 2
  if [ "$O92_R" -eq 0 ]; then
    o92_rnd 900; O92_TASK="$(printf '%03d' $((O92_R + 100)))"
  else
    O92_TASK="t-$((RANDOM % 100000))"
  fi
}

# o92_rnd_hex40 — конформный 40-hex (candidate/wait-ref).
o92_rnd_hex40() { O92_HEX="$(python3 -c 'import secrets; print(secrets.token_hex(20))')"; }

# ── Модель мира W_* (правило 8) ─────────────────────────────────────────────────────────
o92_world() {
  W_TASK='092'; W_STAGE='implement'; W_CAND='-'; W_LASTP='-'
  W_WAITING='none'; W_NEXT='-'; W_PUB='unknown'
  W_EVENTS=()
}

o92_ev() { W_EVENTS+=("$1|$2|$3"); }   # <kind> <subject> <ref> — в модель

o92_write_state() {  # <dir-состояния> — state.tsv из W_* (семь строк ключ<TAB>значение)
  local d="$1"
  {
    printf 'task\t%s\n' "$W_TASK"
    printf 'stage\t%s\n' "$W_STAGE"
    printf 'candidate\t%s\n' "$W_CAND"
    printf 'last_proven\t%s\n' "$W_LASTP"
    printf 'waiting\t%s\n' "$W_WAITING"
    printf 'next_step\t%s\n' "$W_NEXT"
    printf 'pub_state\t%s\n' "$W_PUB"
  } > "$d/state.tsv"
}

o92_write_events() {  # <dir-состояния> — events.tsv из W_EVENTS (ts детерминированы)
  local d="$1" i=0 e k s r
  : > "$d/events.tsv"
  for e in ${W_EVENTS[@]+"${W_EVENTS[@]}"}; do
    IFS='|' read -r k s r <<<"$e"
    printf '2030-01-02T03:04:%02dZ\t%s\t%s\t%s\n' "$i" "$k" "$s" "$r" >> "$d/events.tsv"
    i=$((i + 1))
  done
}

# o92_events_count <kind> <subject> [ref] — число строк журнала (из файла toy-мира).
o92_events_count() {
  if [ "$#" -ge 3 ]; then
    awk -F'\t' -v k="$1" -v s="$2" -v r="$3" '$2==k && $3==s && $4==r {n++} END{print n+0}' \
      "$O92_STATE/events.tsv"
  else
    awk -F'\t' -v k="$1" -v s="$2" '$2==k && $3==s {n++} END{print n+0}' \
      "$O92_STATE/events.tsv"
  fi
}

# o92_blob_sha <файл> — git-blob-sha содержимого (sha1 «blob <len>\0<байты>»;
# равен `git hash-object`, вычислен без репозитория — клетки 7/13 не требуют git).
o92_blob_sha() {
  python3 -c 'import hashlib,sys
d=open(sys.argv[1],"rb").read()
print(hashlib.sha1(b"blob %d\0"%len(d)+d).hexdigest())' "$1"
}

o92_sha() { sha256sum < "$1" | cut -d' ' -f1; }

# ── Toy-репозиторий (git-факты И-4а/И-9; дерево чистое — снимок клетки 12) ──────────────
o92_git() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_CONFIG -u GIT_CONFIG_GLOBAL -u GIT_CONFIG_SYSTEM \
    git -C "$O92_TOY" "$@"
}

# o92_toy <имя> — toy: repo (git init -b main, origin, коммит HANDOFF с последней
# строкой «шаг Б» — контраст производности клетки 9) + state (шов, ВНЕ дерева).
o92_toy() {
  local d="$O92SCR/$1"
  rm -rf "$d"; mkdir -p "$d/repo" "$d/state" || return 2
  O92_TOY="$d/repo"; O92_STATE="$d/state"
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_CONFIG -u GIT_CONFIG_GLOBAL -u GIT_CONFIG_SYSTEM \
    git -C "$O92_TOY" init -q -b main || return 2
  o92_git config user.name toy || return 2
  o92_git config user.email toy@example.invalid || return 2
  o92_git remote add origin https://github.com/toy/example.git || return 2
  printf '# toy HANDOFF\nшаг Б\n' > "$O92_TOY/HANDOFF.md"
  o92_git add -A || return 2
  o92_git commit -q -m 'toy init' || return 2
}

# o92_pub_git <да|нет> — git-факты публикации: «да» — O92_CAND достижим из
# refs/remotes/origin/main (предок типового origin/main); «нет» — боковой коммит
# вне origin/main. Кандидат печатается в O92_CAND.
o92_pub_git() {
  o92_git commit -q --allow-empty -m base
  local base; base="$(o92_git rev-parse HEAD)"
  if [ "$1" = 'да' ]; then
    o92_git commit -q --allow-empty -m tip
    o92_git update-ref refs/remotes/origin/main "$(o92_git rev-parse HEAD)"
    O92_CAND="$base"
  else
    o92_git checkout -q -b side
    o92_git commit -q --allow-empty -m side
    O92_CAND="$(o92_git rev-parse HEAD)"
    o92_git checkout -q main
    o92_git update-ref refs/remotes/origin/main "$(o92_git rev-parse HEAD)"
  fi
}

# o92_story_dva_fajla — вердикт-файлы: v1 в ДВУХ блобах (FAIL-1, затем дописан
# FAIL-2 — «правка файла»), v2 отдельный; три round-fail в W_EVENTS:
# v1@sha1, v1@sha2 (второй — «после рестарта»), v2@sha3. Файлов 2, событий 3.
o92_story_dva_fajla() {
  local d="$O92SCR/vf"
  rm -rf "$d"; mkdir -p "$d"
  o92_rnd_line; printf 'FAIL-1: %s\n' "$O92_LINE" > "$d/v1.md"
  local sa; sa="$(o92_blob_sha "$d/v1.md")"
  o92_rnd_line; printf 'FAIL-2: %s\n' "$O92_LINE" >> "$d/v1.md"
  local sb; sb="$(o92_blob_sha "$d/v1.md")"
  o92_rnd_line; printf 'FAIL-3: %s\n' "$O92_LINE" > "$d/v2.md"
  local sc; sc="$(o92_blob_sha "$d/v2.md")"
  o92_ev round-fail "$W_TASK" "verdicts/092-v1.md@$sa"
  o92_ev round-fail "$W_TASK" "verdicts/092-v1.md@$sb"
  o92_ev round-fail "$W_TASK" "verdicts/092-v2.md@$sc"
}

# ── Toy-API GitHub (HTTP check-runs; счётчик/времена запросов — оракул) ─────────────────
O92_API_PID=''

o92_api_start() {  # <файл-скрипт-ответов: строка-JSON на ответ, последняя повторяется>
  local resp="$1"
  O92_API_LOG="$O92SCR/api_log.$$"
  O92_API_PORT_FILE="$O92SCR/api_port.$$"
  : > "$O92_API_LOG"; : > "$O92_API_PORT_FILE"
  python3 - "$resp" "$O92_API_LOG" "$O92_API_PORT_FILE" <<'O92PY' &
import http.server, sys, time
resp, logf, portf = sys.argv[1], sys.argv[2], sys.argv[3]
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        n = sum(1 for _ in open(logf))
        with open(logf, 'a') as lg:
            lg.write('%f %s\n' % (time.time(), self.path))
        lines = open(resp).read().splitlines()
        body = (lines[n] if n < len(lines) else lines[-1]).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *a):
        pass
srv = http.server.ThreadingHTTPServer(('127.0.0.1', 0), H)
open(portf, 'w').write(str(srv.server_address[1]))
srv.serve_forever()
O92PY
  O92_API_PID=$!
  local i
  for i in $(seq 1 50); do
    [ -s "$O92_API_PORT_FILE" ] && break
    sleep 0.1
  done
  [ -s "$O92_API_PORT_FILE" ] || { printf 'NOT_IMPLEMENTED: toy-API не поднялся\n' >&2; exit 2; }
  O92_API="http://127.0.0.1:$(cat "$O92_API_PORT_FILE")"
  trap 'o92_api_stop' EXIT
}

o92_api_stop() {
  if [ -n "$O92_API_PID" ]; then kill "$O92_API_PID" 2>/dev/null; O92_API_PID=''; fi
}

o92_api_responses() {  # <тела-ответов…> — поднять toy-API на сценарии ответов
  local r f="$O92SCR/api_resp.$$"
  : > "$f"
  for r in "$@"; do printf '%s\n' "$r" >> "$f"; done
  o92_api_start "$f"
}

o92_api_count() { wc -l < "$O92_API_LOG" | tr -d ' '; }

o92_api_gap_ok() {  # <мин-интервал> — соседние запросы различаются ≥ интервал (времена из лога)
  awk -v g="$1" 'NR>1 && $1-p<g { bad=1 } { p=$1 } END { exit bad }' "$O92_API_LOG"
}

# ── Прогон субъекта (швы: ORCH_STATE_DIR/ORCH_GH_API/ORCH_REPO; cwd = toy) ───────────────
o92_probe() {  # <mode: checkpoint|status|ciwait> [аргументы субъекта…]
  local mode="$1"; shift
  local file
  case "$mode" in
    checkpoint) file=orch_checkpoint.sh ;;
    status)     file=orch_status.sh ;;
    ciwait)     file=ci_wait.sh ;;
    *) printf 'NOT_IMPLEMENTED: режим %s\n' "$mode" >&2; exit 2 ;;
  esac
  local var="O92_SUBJ_$(printf '%s' "$mode" | tr '[:lower:]' '[:upper:]')"
  local subj="${!var:-}"
  [ -n "$subj" ] || subj="$O92_ROOT/scripts/$file"
  if [ ! -f "$subj" ]; then
    printf 'красная: предмет отсутствует\n'
    printf 'КРАСНОЕ 092: нет %s (корень %s)\n' "$subj" "$O92_ROOT" >&2
    exit 1
  fi
  (
    cd "$O92_TOY" || exit 2
    export ORCH_STATE_DIR="$O92_STATE" ORCH_REPO="$O92_TOY"
    export ORCH_GH_API="${O92_API:-http://127.0.0.1:9}"
    exec bash "$subj" "$@"
  ) > "$O92SCR/out" 2> "$O92SCR/err"
  O92_RC=$?
  return "$O92_RC"
}

o92_need() {  # <mode…> — субъекты, которых касается клетка; отсутствие — именованное красное
  local m file var subj
  for m in "$@"; do
    case "$m" in
      checkpoint) file=orch_checkpoint.sh ;;
      status)     file=orch_status.sh ;;
      ciwait)     file=ci_wait.sh ;;
      *) printf 'NOT_IMPLEMENTED: режим %s\n' "$m" >&2; exit 2 ;;
    esac
    var="O92_SUBJ_$(printf '%s' "$m" | tr '[:lower:]' '[:upper:]')"
    subj="${!var:-}"
    [ -n "$subj" ] || subj="$O92_ROOT/scripts/$file"
    if [ ! -f "$subj" ]; then
      printf 'красная: предмет отсутствует\n'
      printf 'КРАСНОЕ 092: нет %s (корень %s)\n' "$subj" "$O92_ROOT" >&2
      exit 1
    fi
  done
}

# ── Предъявления клеток (вывод как у 091: «ок …» / «КРАСНО: … — …») ──────────────────────
o92_ok()  { printf 'ок %s\n' "$1"; }
o92_red() { printf 'КРАСНО: %s — %s\n' "$1" "$2" >&2; O92_RED=1; }

o92_assert_rc() {  # <код> <rc>
  [ "$O92_RC" -eq "$2" ] || { o92_red "$1" "rc=$O92_RC, ожидался $2"; return 1; }
  return 0
}
o92_assert_out() {  # <код> <литеральная строка stdout>
  grep -Fxq -- "$2" "$O92SCR/out" || { o92_red "$1" "stdout без строки: $2"; return 1; }
  return 0
}
o92_assert_noout() {  # <код> <строка, которой НЕ должно быть в stdout>
  if grep -Fxq -- "$2" "$O92SCR/out"; then
    o92_red "$1" "stdout содержит строку: $2"; return 1
  fi
  return 0
}
o92_assert_err() {  # <код> <литеральная строка stderr>
  grep -Fxq -- "$2" "$O92SCR/err" || { o92_red "$1" "stderr без строки: $2"; return 1; }
  return 0
}
o92_assert_stdout_is() {  # <код> <весь stdout ровно этой строкой>
  printf '%s\n' "$2" > "$O92SCR/exp"
  cmp -s "$O92SCR/out" "$O92SCR/exp" || { o92_red "$1" "stdout не равен ожиданию: $2"; return 1; }
  return 0
}

# o92_tree_snap <toy> — полный снимок дерева toy БЕЗ .git (индекс меняется от
# законного git status; предмет чистоты — отслеживаемое дерево, клетка 12).
o92_tree_snap() {
  (
    cd "$1" || exit 2
    find . -mindepth 1 -name .git -prune -o \( -type f -o -type d -o -type l \) -print \
      | LC_ALL=C sort | while IFS= read -r p; do
          if [ -L "$p" ]; then printf 'l %s -> %s\n' "${p#./}" "$(readlink "$p")"
          elif [ -d "$p" ]; then printf 'd %s\n' "${p#./}"
          else printf 'f %s %s\n' "$(sha256sum < "$p" | cut -d' ' -f1)" "${p#./}"
          fi
        done
  )
}

o92_porcelain() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_CONFIG -u GIT_CONFIG_GLOBAL -u GIT_CONFIG_SYSTEM \
    git -C "$O92_TOY" status --porcelain
}
