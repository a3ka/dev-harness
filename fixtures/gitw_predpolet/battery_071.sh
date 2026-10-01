#!/usr/bin/env bash
# КРАСНОЕ 071 (предполёт gitw push в main — именованные отказы ДО отправки).
#
# ДО реализации честная часть красна ЕДИНСТВЕННОЙ причиной «предмет
# отсутствует» (fail-fast п0: файла scripts/gitw_preflight_071.sh нет ИЛИ
# крюк в gitw молчит), а стаб-пак (исполняется ДО честных клеток) зелён УЖЕ
# ДО реализации: десять обманных стабов умирают каждый на СВОЕЙ клетке
# именованной причиной — различимость батареи не зависит от честного кода.
#
# ПРИВЯЗКА К КОДУ (Н-39: стаб умирает там, где его дефект НАБЛЮДАМ):
#   * s1 «ЧЕТЫРЕ-НЕ-ВСЕ»  — гоняет только ceilings+ids, nabludenia и  → умирает на
#                           parity не гоняет                            п2б (nabludenia-краснота)
#   * s2 «ЧЕК-ПО-ЧЕКАУТУ» — чеки в cwd, а не в worktree               → умирает на п8
#                           отправляемого tip                          (cwd ≠ tip: жир на main не виден)
#   * s3 «ТЕГ-ПО-ИМЕНИ»   — сверяет только имя тега, не sha           → умирает на п3б (sha разошёлся)
#   * s4 «ТЕГИ-ТОЛЬКО-FROZEN» — пространство done/* не судит           → умирает на п3в (done-тег
#                                                                      отсутствует на цели)
#   * s5 «ЛЕНД-ЛЮБОЙ-ПРОГОН» — любой прогон по sha = зелёный          → умирает на п4б (conclusion=failure)
#                           (без event/conclusion-фильтра)
#   * s6 «ПУСТО-ПРОПУСК»  — ноль прогонов = «сверено, зелёно»         → умирает на п4а (прогонов нет)
#   * s7 «АПИ-МУСОР»      — упавший curl = пропуск                    → умирает на п4г (API мёртв)
#   * s8 «WORKTREE-ПОДСТРОКА» — путь содержит «dev-harness-           → умирает на п5в (путь-подстрока
#                           worktrees» = санкционирован                вне корня, ветка wip)
#   * s9 «MAIN-ТОЛЬКО-ЛИТЕРАЛ» — покрытие main узнаёт только по       → умирает на п6а
#                           токену «main» (полная форма                (refs/heads/main + мусорный worktree)
#                           refs/heads/main не покрывается)
#   * s10 «ВСЕГДА-ЗЕЛЁНЫЙ» — exit 0 без суждения (плацебо)            → умирает на п2а (ceilings-краснота)
#
# Честные клетки (каждая ≡ ровно один именованный отказ контракта 071
# §Инварианты; фразы grep -F дословно, префикс «gitw ПРЕДПОЛЁТ-ОТКАЗ: »):
#   п0   предмет существует и крюк звонит: мусорный worktree при пуше main
#        обязан дать отказ; rc 0 = «предмет отсутствует» (fail-fast);
#   п1   зелёный мир: полный harness-tree, теги синхронны, land с зелёным
#        PR, санкционированный worktree wip/<NNN>/<автор> под <hash8>/ —
#        push проходит, bare продвинулся ровно на tip, строка «gitw
#        ПРЕДПОЛЁТ: » напечатана (молчания нет);
#   п2а-п2г — красный чек: ceilings (жир 60000 байт, замер пачки:
#        FAIL на 51201+), nabludenia (ОТКРОТО без адреса, замер: FAIL Н-1),
#        ids (plans/071-{a,b}.md, замер: «номер 71 назначен рукой»),
#        ci-parity (шаг в ci.yml без npm-ключа); bare НЕ двинут;
#   п2д  мёртвая ветвь чек-раннера: npm вне PATH (symlink-ферма) →
#        «чек-раннер недоступен: npm»;
#   п3а  локальный frozen-тег не на цели → отказ с именем тега;
#   п3б  тег на цели с ДРУГИМ sha → отказ (сверка по объекту, не по имени);
#   п3в  done-тег отсутствует на цели → отказ (оба пространства);
#   п4а  land, у вершины ветки нет прогонов → «land без зелёного PR-CI»;
#   п4б  прогон conclusion=failure → тот же отказ (фильтр conclusion);
#   п4г  API-порт закрыт → «PR-CI не сверяем» (fail-closed сеть);
#   п4д  цель не github и ручки нет → «PR-CI не сверяем: цель не github»;
#   п5а  мусорный detached-worktree вне корня → «посторонний worktree: <путь>»;
#   п5б  ветка не-wip под санкционированным корнем → тот же отказ;
#   п5в  путь-ПОДСТРОКА «dev-harness-worktrees…» вне корня, ветка wip →
#        отказ по ПУТИ (буквальный префикс корня, не подстрока);
#   п6а  полная форма refs/heads/main тоже покрывается (отказ при мусоре);
#   п6б  main:refs/heads/wip/6b не покрывается: rc 0, строк ПРЕДПОЛЁТ нет;
#   п6в  refspec-глоб → «refspec не разбирается» (fail-closed);
#   п7   2 ключа из 4 в package.json → «чек-ключи не полностью»;
#   п8   cwd ≠ отправляемое дерево: жир на main, чекаут на чистой stara —
#        чеки обязаны видеть ОТПРАВЛЯЕМОЕ дерево (клетка стаба s2).
#
# Метод: toy-мир = bare-цель B1 (ручка GIT_EXCHANGE_GUARD_CANONICAL) +
# репо T с ПОЛНЫМ harness-tree (git archive HEAD — чеки зависимы: без
# scripts/next_id.sh, lib_roles.sh, config/ читаются ложной краснотой,
# живой замер пачки) + копии всех тегов репо (замороженность черновиков
# доказывается тегами — check_ceilings:19-22) + land-merge «land:
# wip/071/demo» + API-стаб (python3 http.server: green/failure/empty по
# head_sha). Судимый субъект — копия пары scripts/gitw +
# scripts/gitw_preflight_071.sh в $WORK/toyw/ (крюк резолвит предполёт от
# каталога самой обёртки — НЕ PATH).
#
# Режимы: полная батарея (этот файл) — стаб-пак затем честные клетки;
# RED071_SELFTEST=1 — только само-проверка зелёного мира (фикстура не
# дефектна: четыре чека в T зелёные; используется при разработке батареи).
#
# Коды возврата: 0 — всё зелёное; 1 — именованный ОТКАЗ (клетка/стаб
# названы); 2 — NOT_IMPLEMENTED (нет git/python3/npm-окружения).
set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
[ -d "$ROOT/scripts" ] && [ -f "$ROOT/scripts/gitw" ] || {
  printf 'ОТКАЗ: корень без scripts/gitw: %s\n' "$ROOT" >&2; exit 1; }

command -v git      >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
command -v npm      >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет npm\n' >&2; exit 2; }
command -v jq       >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
command -v curl     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет curl\n' >&2; exit 2; }

# Герметичность от окружения вызывающего (прецедент батареи 045):
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

WORK="$(mktemp -d "${TMPDIR:-/tmp}/gitw071.XXXXXX")"
mkdir -p "$WORK/api"
: > "$WORK/created_wts"
cleanup() {
  while IFS= read -r w; do [ -n "$w" ] && rm -rf "$w"; done < "$WORK/created_wts"
  [ -n "${API_PID:-}" ] && kill "$API_PID" 2>/dev/null
  rm -rf "$WORK"
}
trap cleanup EXIT

WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"
PF='gitw ПРЕДПОЛЁТ-ОТКАЗ: '
POK='gitw ПРЕДПОЛЁТ: '

die_cell() { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }
ok_cell()  { printf 'ok: %s\n' "$1"; }

ident() { local d="$1"; shift; git -C "$d" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q "$@"; }
h8()     { printf '%08x' $(( (RANDOM << 16 ^ RANDOM) & 0xffffffff )); }
tip_of() { git -C "$1" rev-parse HEAD 2>/dev/null || printf 'НЕТ'; }

# ── toy-обёртка: копия судимой пары (крюк резолвит предполёт от себя) ─────────
TOY="$WORK/toyw"
mkdir -p "$TOY/scripts"
cp "$ROOT/scripts/gitw" "$TOY/scripts/gitw" || die_cell среда "не скопировался scripts/gitw"
[ -f "$ROOT/scripts/gitw_preflight_071.sh" ] && cp "$ROOT/scripts/gitw_preflight_071.sh" "$TOY/scripts/"

# ── API-стаб: green.list / fail.list по head_sha ─────────────────────────────
APIDIR="$WORK/api"; : > "$APIDIR/green.list"; : > "$APIDIR/fail.list"
cat > "$APIDIR/srv.py" <<'PYEOF'
import json, re, sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
GP = sys.argv[1]
FP = sys.argv[2]
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        u = urlparse(self.path)
        if not re.match(r'^/repos/[^/]+/[^/]+/actions/runs$', u.path):
            self.send_response(404); self.end_headers(); return
        sha = (parse_qs(u.query).get('head_sha') or [''])[0]
        try:
            GREEN = set(x for x in open(GP).read().split() if x)
            FAIL = set(x for x in open(FP).read().split() if x)
        except OSError:
            GREEN, FAIL = set(), set()
        if sha in GREEN:
            body = {"total_count": 1, "workflow_runs": [{"id": 1, "event": "pull_request", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
        elif sha in FAIL:
            body = {"total_count": 1, "workflow_runs": [{"id": 2, "event": "pull_request", "head_sha": sha, "status": "completed", "conclusion": "failure"}]}
        else:
            body = {"total_count": 0, "workflow_runs": []}
        raw = json.dumps(body).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)
    def log_message(self, *a): pass
srv = HTTPServer(('127.0.0.1', 0), H)
open(sys.argv[3], 'w').write(str(srv.server_port))
srv.serve_forever()
PYEOF
python3 "$APIDIR/srv.py" "$APIDIR/green.list" "$APIDIR/fail.list" "$APIDIR/port" &
API_PID=$!
APORT=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$APIDIR/port" ] && APORT="$(cat "$APIDIR/port")" && break
  sleep 0.2
done
[ -n "$APORT" ] || die_cell среда "API-стаб не поднялся (порт не записан)"
APIBASE="http://127.0.0.1:$APORT/repos/a3ka/dev-harness"
curl -fsS -m 5 "$APIBASE/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  || die_cell среда "API-стаб не отвечает на пробу (пустая выборка — не проверено ничего)"
# мёртвый порт: занять и освободить
DEADPORT="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')"

# ── конформный harness-tree: git archive HEAD ────────────────────────────────
TREE="$WORK/tree"
mkdir -p "$TREE"
git -C "$ROOT" archive --format=tar HEAD | tar -xf - -C "$TREE" \
  || die_cell среда "git archive HEAD не развёрнут (дерево не построено)"

# ── построитель мира ─────────────────────────────────────────────────────────
# mk_world <имя> [без-land|с-land]: B1 bare + T (полное дерево, все теги репо
# на базовом коммите, frozen/099 + done/098, origin=B1, пуш base) + land-merge
# wip/071/demo (P → green.list) + санкционированный worktree wip/071/wtx.
mk_world() {
  local name="$1" withland="${2:-с-land}"
  local d="$WORK/$name"
  B1="$d/b1"; T="$d/t"
  git init -q --bare "$B1"
  git init -q -b main "$T"
  ( cd "$TREE" && tar -cf - . ) | tar -xf - -C "$T"
  ( cd "$T" && git add -A ) && ident "$T" -m base
  # копии ВСЕХ тегов репо на базовый коммит: замороженность черновиков и
  # реестр выдачи доказываются тегами (check_ceilings:19-22, check_ids)
  while IFS= read -r r; do
    git -C "$T" tag "${r#refs/tags/}" "$(git -C "$T" rev-parse HEAD)" 2>/dev/null || true
  done < <(git -C "$ROOT" for-each-ref --format='%(refname)' refs/tags)
  git -C "$T" tag -f frozen/contracts/099/1 >/dev/null 2>&1 || git -C "$T" tag frozen/contracts/099/1
  git -C "$T" tag done/contracts/098/1 2>/dev/null || true
  git -C "$T" remote add origin "$B1"
  git -C "$T" push -q origin main --tags || die_cell "$name" "базовый пуш в bare не прошёл"
  if [ "$withland" = "с-land" ]; then
    git -C "$T" checkout -q -b wip/071/demo
    printf 'демо-коммит ленда\n' > "$T/demo071.txt"
    git -C "$T" add demo071.txt && ident "$T" -m 'work by demo'
    git -C "$T" checkout -q main
    git -C "$T" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false merge --no-ff -q -m 'land: wip/071/demo' wip/071/demo \
      || die_cell "$name" "land-merge не построился"
    P="$(git -C "$T" rev-parse refs/heads/wip/071/demo)"
    printf '%s\n' "$P" >> "$APIDIR/green.list"
  fi
  local w="$WTROOT/$(h8)"; mkdir -p "$w"
  git -C "$T" worktree add -q -b wip/071/wtx "$w/wt" main 2>/dev/null \
    || die_cell "$name" "санкционированный worktree не построился"
  printf '%s\n' "$w" >> "$WORK/created_wts"
}

# второй land без зелёного PR: wip/071/demx, режим empty|failure|dead|nogithub
mk_second_land() {
  local mode="$1"
  git -C "$T" checkout -q -b wip/071/demx
  printf 'второй ленд\n' > "$T/demx071.txt"
  git -C "$T" add demx071.txt && ident "$T" -m 'work by demx'
  local p2; p2="$(git -C "$T" rev-parse refs/heads/wip/071/demx)"
  [ "$mode" = "failure" ] && printf '%s\n' "$p2" >> "$APIDIR/fail.list"
  git -C "$T" checkout -q main
  git -C "$T" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false merge --no-ff -q -m 'land: wip/071/demx' wip/071/demx \
    || die_cell "demx-$mode" "второй land-merge не построился"
}

# прогон судимой пары; env-ручки: APIENV = base | dead | нет
run_push() { # run_push <режим-api: api|dead|none> <аргументы push...>
  local apimode="$1"; shift
  SNAP_B1="$(git -C "$B1" rev-parse -q --verify refs/heads/main 2>/dev/null || printf НЕТ)"
  local -a envs=(GIT_EXCHANGE_GUARD_CANONICAL="$B1")
  case "$apimode" in
    api)  envs+=(GITW_PREFLIGHT_071_API="$APIBASE") ;;
    dead) envs+=(GITW_PREFLIGHT_071_API="http://127.0.0.1:$DEADPORT/repos/a3ka/dev-harness") ;;
    none) : ;;
    *) die_cell среда "неизвестный режим api: $apimode" ;;
  esac
  ( cd "$T" && env "${envs[@]}" bash "$TOY/scripts/gitw" push "$@" ) \
    >"$WORK/last.out" 2>"$WORK/last.err"
  RC=$?
}

expect_refuse() { # expect_refuse <клетка> <подстрока-причины>
  local cell="$1" sub="$2"
  [ "$RC" -eq 1 ] || die_cell "$cell" "rc=$RC (ожидался 1): $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  grep -qF -- "$sub" "$WORK/last.err" \
    || die_cell "$cell" "причина не названа (ищу «$sub»): $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
}
bare_frozen() { # bare-цель не двинулась ОТНОСИТЕЛЬНО СНИМКА run_push
  local now; now="$(git -C "$B1" rev-parse -q --verify refs/heads/main 2>/dev/null || printf НЕТ)"
  [ "$now" = "$SNAP_B1" ] || die_cell "$1" "bare-цель двинулась при отказе ($SNAP_B1 → $now)"
}

# ── само-проверка зелёного мира (фикстура не дефектна) ───────────────────────
selftest() {
  mk_world selftest
  local k rc
  for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
    ( cd "$T" && npm run --silent "$k" ) >"$WORK/st.out" 2>"$WORK/st.err"
    rc=$?
    [ "$rc" -eq 0 ] || die_cell само-проверка "toy-мир не зелёный на $k rc=$rc: $(tail -n 3 "$WORK/st.err" | tr '\n' ' ')"
  done
  ok_cell "само-проверка: зелёный мир зелёный (4/4 чека)"
}
selftest
[ "${RED071_SELFTEST:-0}" = "1" ] && { printf 'само-проверка завершена\n'; exit 0; }

# ── стаб-пак: мини-ядро предполёта с подсаженным дефектом ────────────────────
CORE="$WORK/stub_core.sh"
cat > "$CORE" <<'COREEOF'
#!/usr/bin/env bash
# стаб-ядро 071 (батарейная обманка, НЕ реализация): мини-предполёт с
# дефектом STUB_DEFECT. Интерфейс крюка: argv1=эффективная цель, далее —
# хвост argv push (refspec/флаги); cwd = репозиторий вызова.
set -uo pipefail
DEF="${STUB_DEFECT:-}"
[ "$DEF" = "s10" ] && exit 0
TGT="${1:?цель}"; shift
WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"
API="${GITW_PREFLIGHT_071_API:-}"
REASON() { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: %s\n' "$*" >&2; exit 1; }
# ── покрытие main ──────────────────────────────────────────────────────────
main_cov=0
for a in "$@"; do
  case "$a" in -*) continue ;; esac
  dst="${a#*:}"; [ "$dst" = "$a" ] && dst="$a"
  dst="${dst#refs/heads/}"
  if [ "$DEF" = "s9" ]; then [ "$a" = "main" ] && main_cov=1
  elif [ "$dst" = "main" ]; then main_cov=1; fi
done
[ "$main_cov" -eq 1 ] || exit 0
# ── (4) worktree ───────────────────────────────────────────────────────────
first=1
path=""; branch=""
flush() {
  [ -z "$path" ] && return 0
  if [ "$first" -eq 0 ]; then
    local ok=0
    if [ "$DEF" = "s8" ]; then
      case "$path" in *dev-harness-worktrees*) ok=1 ;; esac
    else
      case "$branch" in refs/heads/wip/[0-9][0-9][0-9]/*)
        case "$path" in "$WTROOT"/[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]/*) ok=1 ;; esac ;;
      esac
    fi
    [ "$ok" -eq 1 ] || REASON "посторонний worktree: $path (ветка ${branch:-detached})"
  fi
  first=0; path=""; branch=""
}
while IFS= read -r l; do
  case "$l" in
    worktree\ *) flush; path="${l#worktree }" ;;
    branch\ *)   branch="${l#branch }" ;;
    detached)    branch="detached" ;;
  esac
done < <(git worktree list --porcelain 2>/dev/null)
flush
# ── (2) теги frozen/*|done/* ───────────────────────────────────────────────
declare -A RSHA
while IFS=$'\t' read -r sha ref; do
  [ -n "$ref" ] && RSHA["${ref#refs/tags/}"]="$sha"
done < <(git ls-remote --tags "$TGT" 2>/dev/null)
while IFS=' ' read -r sha ref; do
  [ -n "$ref" ] || continue
  n="${ref#refs/tags/}"
  case "$n" in
    frozen/*) : ;;
    done/*)   [ "$DEF" = "s4" ] && continue ;;
    *) continue ;;
  esac
  r="${RSHA[$n]:-}"
  if [ "$DEF" = "s3" ]; then [ -n "$r" ] || REASON "локальный тег не на origin: $n"
  else [ "$r" = "$sha" ] || REASON "локальный тег не на origin: $n"; fi
done < <(git show-ref --tags 2>/dev/null)
# ── (3) land-merge ─────────────────────────────────────────────────────────
rmain="$(git ls-remote "$TGT" refs/heads/main 2>/dev/null | cut -f1)"
[ -n "$rmain" ] || REASON "PR-CI не сверяем: вершина main на цели не читается"
while IFS=' ' read -r h s; do
  case "$s" in "land: wip/"[0-9][0-9][0-9]/*) ;; *) continue ;; esac
  br="${s#land: }"
  p="$(git rev-parse -q --verify "$h^2" 2>/dev/null)" || REASON "land-субъект не разбирается: $s"
  [ -n "$API" ] || REASON "PR-CI не сверяем: цель не github"
  body="$(curl -fsS -m 10 "$API/actions/runs?event=pull_request&head_sha=$p" 2>/dev/null)" || {
    [ "$DEF" = "s7" ] && continue
    REASON "PR-CI не сверяем: API"
  }
  if [ "$DEF" = "s6" ]; then
    tc="$(printf '%s' "$body" | jq -r '.total_count // 0' 2>/dev/null)"; [ "$tc" -gt 0 ] || continue
  fi
  if [ "$DEF" = "s5" ]; then
    n="$(printf '%s' "$body" | jq -r '.total_count // 0' 2>/dev/null)"
  else
    n="$(printf '%s' "$body" | jq -r '[.workflow_runs[] | select(.event=="pull_request" and .conclusion=="success")] | length' 2>/dev/null)"
  fi
  [ "${n:-0}" -ge 1 ] || REASON "land без зелёного PR-CI: $br ($p)"
done < <(git log --first-parent --merges --format='%H %s' "$rmain..refs/heads/main" 2>/dev/null)
# ── (1) четыре чека на отправляемом дереве ─────────────────────────────────
command -v npm >/dev/null 2>&1 || REASON "чек-раннер недоступен: npm"
nk=0
for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
  grep -q "\"$k\"" package.json && nk=$((nk+1))
done
[ "$nk" -eq 0 ] && { printf 'gitw ПРЕДПОЛЁТ: чеки неприменимы — дерево не несёт ключей check:*\n' >&2; exit 0; }
[ "$nk" -eq 4 ] || REASON "чек-ключи не полностью: $nk из 4"
tw="$WTROOT/$(printf '%08x' $(( (RANDOM << 16 ^ RANDOM) & 0xffffffff )))"
if [ "$DEF" = "s2" ]; then
  cwd="$PWD"
else
  git worktree add -q --detach "$tw" refs/heads/main 2>/dev/null || REASON "дерево чеков не строится"
  cwd="$tw"
fi
if [ "$DEF" = "s1" ]; then
  keys=(check:ceilings check:ids)
else
  keys=(check:nabludenia check:ci-parity check:ceilings check:ids)
fi
for k in "${keys[@]}"; do
  ( cd "$cwd" && npm run --silent "$k" ) >/dev/null 2>&1 || REASON "чек красный: $k"
done
[ "$DEF" = "s2" ] || git worktree remove --force "$tw" 2>/dev/null
printf 'gitw ПРЕДПОЛЁТ: чисто\n' >&2
exit 0
COREEOF
chmod +x "$CORE"

mk_stub() { printf '#!/usr/bin/env bash\nSTUB_DEFECT=%s\nexec bash %q "$@"\n' "$1" "$CORE" > "$WORK/stubs_$1.sh"; chmod +x "$WORK/stubs_$1.sh"; }
for s in s1 s2 s3 s4 s5 s6 s7 s8 s9 s10; do mk_stub "$s"; done

run_stub() { # run_stub <стаб> <режим-api> <аргументы push...>
  local st="$1" apimode="$2"; shift 2
  local -a envs=(STUB_DEFECT="$st" GIT_EXCHANGE_GUARD_CANONICAL="$B1")
  case "$apimode" in
    api)  envs+=(GITW_PREFLIGHT_071_API="$APIBASE") ;;
    dead) envs+=(GITW_PREFLIGHT_071_API="http://127.0.0.1:$DEADPORT/repos/a3ka/dev-harness") ;;
    none) : ;;
  esac
  ( cd "$T" && env "${envs[@]}" bash "$WORK/stubs_$st.sh" "$B1" "$@" ) >"$WORK/last.out" 2>"$WORK/last.err"
  RC=$?
}

# миры нарушений для стаб-пак (те же строители, что у честных клеток)
stub_violation() { # stub_violation <класс>
  case "$1" in
    nabludenia)
      mk_world sv-nabludenia
      printf '### Н-1. `ОТКРЫТО`\nтекст без адреса\n' > "$T/NABLIUDENIA.md"
      git -C "$T" add NABLIUDENIA.md && ident "$T" -m 'nablu red' ;;
    ceilings)
      mk_world sv-ceilings
      python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
      git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat role' ;;
    cwdne-tip)
      mk_world sv-cwdne
      python3 -c "print('y'*60000)" > "$T/roles/orchestrator.md"
      git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat on main'
      git -C "$T" checkout -q -b stara HEAD~1 ;;
    teg-sha)
      mk_world sv-tegsha
      printf 'переприцел\n' > "$T/x071.txt"; git -C "$T" add x071.txt && ident "$T" -m retag
      git -C "$T" tag -f frozen/contracts/099/1 >/dev/null ;;
    done-net)
      mk_world sv-done
      git -C "$B1" tag -d done/contracts/098/1 >/dev/null 2>&1 ;;
    fail-run)
      mk_world sv-fail; mk_second_land failure ;;
    zero-run)
      mk_world sv-zero; mk_second_land empty ;;
    dead-api)
      mk_world sv-dead; mk_second_land empty ;;
    podstroka)
      mk_world sv-podstr
      mkdir -p "$WTROOT-slob"
      git -C "$T" worktree add -q -b wip/071/wtf "$WTROOT-slob/wt" main >/dev/null 2>&1 ;;
    garbage-wt)
      mk_world sv-garbage
      git -C "$T" worktree add -q --detach "$WORK/slob071" main >/dev/null 2>&1 ;;
    *) die_cell стаб "неизвестный класс мира: $1" ;;
  esac
}

# диффпроба: каждый стаб обязан ПРОЙТИ чистый мир (rc 0) — иначе стаб
# над-блокирует и различимость мертва; нарушение — обязан отказаться.
run_stub_pack() {
  local -a pairs=(
    "s1:nabludenia:чек красный: check:nabludenia"
    "s2:cwdne-tip:чек красный: check:ceilings"
    "s3:teg-sha:локальный тег не на origin: frozen/contracts/099/1"
    "s4:done-net:локальный тег не на origin: done/contracts/098/1"
    "s5:fail-run:land без зелёного PR-CI: wip/071/demx"
    "s6:zero-run:land без зелёного PR-CI: wip/071/demx"
    "s7:dead-api:PR-CI не сверяем"
    "s8:podstroka:посторонний worktree"
    "s9:garbage-wt:посторонний worktree"
    "s10:ceilings:чек красный: check:ceilings"
  )
  local pair st kind want api_mode toks
  local caught=0 diff=0
  for pair in "${pairs[@]}"; do
    IFS=: read -r st kind want _ <<<"$pair"
    api_mode=api; toks=(main)
    [ "$st" = "s9" ] && toks=(refs/heads/main)
    [ "$st" = "s7" ] && api_mode=dead
    # мир-нарушение: обманный стаб обязан ПРОЖИТЬ его (rc 0 либо отказ не той
    # причиной) — именно это и есть «пойман»: мир настоящий, дефект различим.
    # Отказался правильно — дефект мёртв, батарея красна (стаб не обманут).
    stub_violation "$kind"
    run_stub "$st" "$api_mode" "${toks[@]}"
    if [ "$RC" -eq 1 ] && grep -qF -- "$PF$want" "$WORK/last.err"; then
      die_cell "стаб-$st" "не обманут: отказался на «$want» правильно — дефект не воспроизводится"
    fi
    caught=$((caught+1))
    # диффпроба на зелёном мире (свежий mk_world): тот же стаб обязан пройти
    # чистый мир rc 0 — иначе он параноик, а не обманка (А-308).
    mk_world "sv-clean-$st"
    run_stub "$st" api main
    [ "$RC" -eq 0 ] || die_cell "стаб-$st" "над-блокировка: чистый мир rc=$RC: $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
    diff=$((diff+1))
    printf 'ok: стаб-%s прожил «%s» и проходит чистый мир\n' "$st" "$kind"
  done
  printf 'стаб-пак: %s/%s поймано, диффпроба %s/%s\n' "$caught" "${#pairs[@]}" "$diff" "${#pairs[@]}"
  [ "$caught" -eq "${#pairs[@]}" ] && [ "$diff" -eq "${#pairs[@]}" ]
}

# ── честные клетки ───────────────────────────────────────────────────────────
run_honest_cells() {
  # п0: предмет существует и крюк звонит (поведенчески, не грепом)
  mk_world p0
  git -C "$T" worktree add -q --detach "$WORK/slob0" main >/dev/null 2>&1
  run_push api origin main
  if [ "$RC" -eq 0 ]; then
    die_cell п0 "предмет отсутствует: push с мусорным worktree прошёл — нет scripts/gitw_preflight_071.sh или крюк в gitw молчит"
  fi
  expect_refuse п0 "${PF}посторонний worktree"
  bare_frozen п0
  ok_cell 'п0: предмет существует, крюк звонит'

  # п1: зелёный мир — всё чисто, push проходит, bare на tip, строка успеха
  mk_world p1
  run_push api origin main
  [ "$RC" -eq 0 ] || die_cell п1 "зелёный мир отказан: $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  grep -qF "$POK" "$WORK/last.err" || die_cell п1 "строка успеха «gitw ПРЕДПОЛЁТ: » не напечатана (молчание)"
  [ "$(git -C "$B1" rev-parse refs/heads/main)" = "$(git -C "$T" rev-parse main)" ] \
    || die_cell п1 "bare-цель не на tip отправленного main"
  ok_cell 'п1: зелёный мир — push прошёл, bare на tip'

  # п2а-п2г: красный чек каждого из четырёх ключей
  mk_world p2a
  python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat role'
  run_push api origin main
  expect_refuse п2а "${PF}чек красный: check:ceilings"
  bare_frozen п2а; ok_cell 'п2а: check:ceilings красный не уезжает'

  mk_world p2b
  printf '### Н-1. `ОТКРЫТО`\nтекст без адреса\n' > "$T/NABLIUDENIA.md"
  git -C "$T" add NABLIUDENIA.md && ident "$T" -m 'nablu red'
  run_push api origin main
  expect_refuse п2б "${PF}чек красный: check:nabludenia"
  bare_frozen п2б; ok_cell 'п2б: check:nabludenia красный не уезжает'

  mk_world p2v
  printf 'a\n' > "$T/plans/071-a.md"; printf 'b\n' > "$T/plans/071-b.md"
  git -C "$T" add plans/071-a.md plans/071-b.md && ident "$T" -m 'ids red'
  run_push api origin main
  expect_refuse п2в "${PF}чек красный: check:ids"
  bare_frozen п2в; ok_cell 'п2в: check:ids красный не уезжает'

  mk_world p2g
  printf '      - run: bash scripts/nikogda_net_071.sh\n' >> "$T/.github/workflows/ci.yml"
  git -C "$T" add .github/workflows/ci.yml && ident "$T" -m 'parity red'
  run_push api origin main
  expect_refuse п2г "${PF}чек красный: check:ci-parity"
  bare_frozen п2г; ok_cell 'п2г: check:ci-parity красный не уезжает'

  # п2д: мёртвая ветвь чек-раннера — npm вне PATH (symlink-ферма без npm)
  FARM="$WORK/farm"; mkdir -p "$FARM"
  for d in /usr/bin /bin /usr/local/bin; do
    [ -d "$d" ] || continue
    for f in "$d"/*; do
      case "${f##*/}" in npm|npx) continue ;; esac
      [ -e "$FARM/${f##*/}" ] || ln -s "$f" "$FARM/${f##*/}" 2>/dev/null || true
    done
  done
  command -v npm >/dev/null 2>&1 || die_cell п2д "ферма не нужна: npm и так отсутствует"
  PATH="$FARM" command -v npm >/dev/null 2>&1 && die_cell п2д "ферма не построена: npm в ней выжил"
  PATH="$FARM" command -v git  >/dev/null 2>&1 || die_cell п2д "ферма без git — ветвь не построена"
  mk_world p2d
  ( cd "$T" && PATH="$FARM" env GIT_EXCHANGE_GUARD_CANONICAL="$B1" GITW_PREFLIGHT_071_API="$APIBASE" \
      bash "$TOY/scripts/gitw" push origin main ) >"$WORK/last.out" 2>"$WORK/last.err"
  RC=$?
  expect_refuse п2д "${PF}чек-раннер недоступен: npm"
  bare_frozen п2д; ok_cell 'п2д: npm недоступен — отказ, не пропуск'

  # п3а: локальный frozen-тег не на цели
  mk_world p3a
  git -C "$T" tag frozen/contracts/097/1
  run_push api origin main
  expect_refuse п3а "${PF}локальный тег не на origin: frozen/contracts/097/1"
  bare_frozen п3а; ok_cell 'п3а: задержанный frozen-тег не уезжает'

  # п3б: тег на цели с ДРУГИМ sha (сверка по объекту)
  mk_world p3b
  printf 'переприцел\n' > "$T/x071.txt"; git -C "$T" add x071.txt && ident "$T" -m retag
  git -C "$T" tag -f frozen/contracts/099/1 >/dev/null
  run_push api origin main
  expect_refuse п3б "${PF}локальный тег не на origin: frozen/contracts/099/1"
  bare_frozen п3б; ok_cell 'п3б: переприцеленный тег (иной sha) не уезжает'

  # п3в: done-тег отсутствует на цели (оба пространства)
  mk_world p3v
  git -C "$B1" tag -d done/contracts/098/1 >/dev/null 2>&1
  run_push api origin main
  expect_refuse п3в "${PF}локальный тег не на origin: done/contracts/098/1"
  bare_frozen п3в; ok_cell 'п3в: done-тег не на origin не уезжает'

  # п4а: land без прогонов
  mk_world p4a; mk_second_land empty
  run_push api origin main
  expect_refuse п4а "${PF}land без зелёного PR-CI: wip/071/demx"
  bare_frozen п4а; ok_cell 'п4а: land без прогонов PR не уезжает'

  # п4б: прогон не success
  mk_world p4b; mk_second_land failure
  run_push api origin main
  expect_refuse п4б "${PF}land без зелёного PR-CI: wip/071/demx"
  bare_frozen п4б; ok_cell 'п4б: красный PR-прогон не уезжает'

  # п4г: мёртвый API — fail-closed
  mk_world p4g; mk_second_land empty
  run_push dead origin main
  expect_refuse п4г "${PF}PR-CI не сверяем"
  bare_frozen п4г; ok_cell 'п4г: мёртвый API — отказ, не пропуск'

  # п4д: цель не github, ручки нет — нечем сверять
  mk_world p4d; mk_second_land empty
  run_push none origin main
  expect_refuse п4д "${PF}PR-CI не сверяем: цель не github"
  bare_frozen п4д; ok_cell 'п4д: не-github цель без ручки — отказ'

  # п5а: мусорный detached worktree вне корня
  mk_world p5a
  git -C "$T" worktree add -q --detach "$WORK/slob5a" main >/dev/null 2>&1
  run_push api origin main
  expect_refuse п5а "${PF}посторонний worktree: "
  grep -qF -- "$WORK/slob5a" "$WORK/last.err" || die_cell п5а "путь worktree не назван"
  bare_frozen п5а; ok_cell 'п5а: мусорный worktree назван путём'

  # п5б: ветка не-wip под санкционированным корнем
  mk_world p5b
  local wb; wb="$WTROOT/$(h8)"; mkdir -p "$wb"; printf '%s\n' "$wb" >> "$WORK/created_wts"
  git -C "$T" worktree add -q -b klon-main "$wb/wtb" main >/dev/null 2>&1
  run_push api origin main
  expect_refuse п5б "${PF}посторонний worktree: "
  grep -qF 'klon-main' "$WORK/last.err" || die_cell п5б "ветка worktree не названа"
  bare_frozen п5б; ok_cell 'п5б: не-wip ветка под корнем названа'

  # п5в: путь-подстрока вне корня, ветка wip — судит ПУТЬ (буквальный префикс)
  mk_world p5v
  mkdir -p "$WTROOT-slob"
  git -C "$T" worktree add -q -b wip/071/wtf "$WTROOT-slob/wt" main >/dev/null 2>&1
  run_push api origin main
  expect_refuse п5в "${PF}посторонний worktree: "
  grep -qF -- "$WTROOT-slob/wt" "$WORK/last.err" || die_cell п5в "путь-подстрока не назван"
  bare_frozen п5в; ok_cell 'п5в: подстрока корня не санкционирует путь'

  # п6а: полная форма refs/heads/main покрывается
  mk_world p6a
  git -C "$T" worktree add -q --detach "$WORK/slob6a" main >/dev/null 2>&1
  run_push api origin refs/heads/main
  expect_refuse п6а "${PF}посторонний worktree"
  bare_frozen п6а; ok_cell 'п6а: refs/heads/main покрыт'

  # п6б: не-main refspec — предполёт не несётся, обмен прозрачен
  mk_world p6b
  run_push api origin main:refs/heads/wip/6b
  [ "$RC" -eq 0 ] || die_cell п6б "не-main пуш отказан (семантика 045 сломана): $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  grep -qF 'ПРЕДПОЛЁТ' "$WORK/last.err" && die_cell п6б "предполёт нёсся на не-main пуше"
  git -C "$B1" rev-parse -q --verify refs/heads/wip/6b >/dev/null || die_cell п6б "ветка wip/6b не дошла"
  ok_cell 'п6б: main:wip/6b — без предполёта, прозрачен'

  # п6в: refspec-глоб — fail-closed
  mk_world p6v
  run_push api origin 'refs/heads/*:refs/heads/*'
  expect_refuse п6в "${PF}refspec не разбирается"
  bare_frozen п6в; ok_cell 'п6в: refspec-глоб — именованный отказ'

  # п7: чек-ключи не полностью (2 из 4)
  mk_world p7
  ( cd "$T" && python3 - <<'PYE'
import json
p = json.load(open('package.json'))
for k in ('check:nabludenia', 'check:ci-parity'):
    p['scripts'].pop(k, None)
json.dump(p, open('package.json', 'w'), ensure_ascii=False, indent=2)
PYE
  )
  git -C "$T" add package.json && ident "$T" -m 'keys partial'
  run_push api origin main
  expect_refuse п7 "${PF}чек-ключи не полностью"
  bare_frozen п7; ok_cell 'п7: деградация чек-ключей (2 из 4) не уезжает'

  # п8: cwd ≠ отправляемое дерево — чеки видят ОТПРАВЛЯЕМОЕ дерево
  mk_world p8
  python3 -c "print('z'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat on main'
  git -C "$T" checkout -q -b stara HEAD~1
  run_push api origin main
  expect_refuse п8 "${PF}чек красный: check:ceilings"
  bare_frozen п8; ok_cell 'п8: чеки на отправляемом дереве, не на чекауте'
}

# ── порядок: само-проверка → стаб-пак → честные клетки ───────────────────────
run_stub_pack
run_honest_cells
printf 'честные клетки: 19/19 зелёные; стаб-пак 10/10 + дифф 10/10\n'
exit 0
