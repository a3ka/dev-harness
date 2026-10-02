#!/usr/bin/env bash
# КРАСНОЕ 071 (предполёт gitw push в main — именованные отказы ДО отправки).
#
# ДО реализации честная часть красна ЕДИНСТВЕННОЙ причиной «предмет
# отсутствует» (fail-fast п0: файла scripts/gitw_preflight_071.sh нет ИЛИ
# стаб-пак (исполняется ДО честных клеток) зелён УЖЕ
# ДО реализации: семнадцать обманных стабов умирает каждый на СВОЕЙ клетке
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
#   * s11 «НЕСУДИМО-ПРОЗРАЧНО» — отказ «несудимая конфигурация»            → умирает на
#                           не строится: нет refspec/HEAD без dst  п6г (push без refspec,
#                           при чужой ветке — прозрачный обмен)    matching + красный main)
#   * s12 «ЯДРО-ПО-МАЙН»   — чеки и диапазон всегда по               → умирает на
#                           refs/heads/main, src refspec           п9а (красный candidate
#                           игнорируется                           при зелёном main: cand:main)
#   * s13 «ЛЮБОЙ-SUCCESS»  — conclusion=success без фильтра          → умирает на
#                           event=pull_request                     п4е (зелёный push-прогон)
#   * s14 «HVOST-PUST-PROPUST» — пустой хвост refspec при ветке main:  → умирает на
#                           молчаливый пропуск (корень Р-1 071-r1:    п7г (push origin
#                           красный main уезжает молча)                без refspec, main)
#   * s15 «HVOST-PUST-NESUDIM» — пустой хвост на main: огульное       → умирает на
#                           «несудимая» вместо покрытия (блокнит      п7д (push без
#                           легитимную форму не той причиной)          remote, main)
#   * s16 «ZAGOLOVOK-ODNIM-ARGV» — Authorization: Bearer уезжает в curl  → умирает на
#                           ОДНИМ словом (живой укус №1: curl молча       п8а (мок-заголовок:
#                           роняет заголовок, GitHub — 400)              валидный Bearer — 200,
#                                                                      кривой — 400)
#   * s17 «NE-ZNAET-SSH-GITHUB» — грамматика цели без формы              → умирает на
#                           ssh://github.com/<o>/<r>.git (живой укус     п8б (ssh-цель: честный
#                           №2: «цель не github»)                         парсит и зовёт мок)
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
#   п4е  зелёный success чужого event (push) → «land без зелёного
#        PR-CI» (success ≠ success именно pull_request — слово владельца п.3);
#   п5а  мусорный detached-worktree вне корня → «посторонний worktree: <путь>»;
#   п5б  ветка не-wip под санкционированным корнем → тот же отказ;
#   п5в  путь-ПОДСТРОКА «dev-harness-worktrees…» вне корня, ветка wip →
#        отказ по ПУТИ (буквальный префикс корня, не подстрока);
#   п6а  полная форма refs/heads/main тоже покрывается (отказ при мусоре);
#   п6б  main:refs/heads/wip/6b не покрывается: rc 0, строк ПРЕДПОЛЁТ нет;
#   п6г  push БЕЗ refspec при текущей ветке ≠ main (мир push.default=
#        matching с красным main впереди) → «несудимая конфигурация
#        refspec» fail-closed ДО отправки — прозрачный обмен двинул бы
#        получателя (критик к1 Б4);
#   п6д  HEAD без явного dst при текущей ветке ≠ main → тот же отказ;
#   п6в  refspec-глоб → «refspec не разбирается» (fail-closed);
#   п7   2 ключа из 4 в package.json → «чек-ключи не полностью»;
#   п7а-п7в — 1/3/0 из 4 ключей в ОТПРАВЛЯЕМОМ src, cwd (main) полный —
#        независимый вход для каждой неполноты (адверсарий 071-r1 Б1);
#        п7в (0 ключей) судит именованный пропуск при расхождении cwd/src
#        (адверсарий 071-r1 Б2); п7б (3 ключа) — клетка, которую ловит
#        мутант предиката nk==0→nk==3 (мутант пропускает 3-ключевой src
#        вместо отказа «не полностью»);
#   п7г-п7д — push без refspec при текущей ветке main (А7б третья пара,
#        Р-2 ревьюера 071-r1): красный ceilings на main + upstream
#        main→origin/main; `push origin` без refspec (п7г) и голый
#        `gitw push` по upstream (п7д) → «чек красный: check:ceilings»,
#        цель не двинута (клетки стабов s14/s15);
#   п8   cwd ≠ отправляемое дерево: жир на main, чекаут на чистой stara —
#        чеки обязаны видеть ОТПРАВЛЯЕМОЕ дерево (клетка стаба s2);
#   п9а-п9в — src ≠ main: чеки по ОТПРАВЛЯЕМОМУ src — красный candidate
#        при зелёном синхронном main (cand:main → отказ ceilings, цель не
#        двинута), HEAD:main при ветке candidate (src = HEAD), зелёная
#        пара: candidate:main проходит и ставит цель на tip candidate
#        (критик к1 Б5);
#   п8а-п8б — боевой API-шов (живые укусы 2026-10-02): п8а — заголовок
#        Authorization: Bearer <токен> ДОХОДИТ до мока побайтово валидным
#        (кривой/одним-argv → 400 → отказ «PR-CI не сверяем»); п8б — цель
#        ssh://github.com/<o>/<r>.git парсится: owner/repo спрашиваются у
#        API по /repos/o/r/actions/runs (корневой мок, шов-КОРЕНЬ) —
#        зелёный PR-CI читается, пуш проходит на приземлённый bare;
#
# Метод: toy-мир = bare-цель B1 (ручка GIT_EXCHANGE_GUARD_CANONICAL) +
# репо T с ПОЛНЫМ harness-tree (git archive HEAD — чеки зависимы: без
# scripts/next_id.sh, lib_roles.sh, config/ читаются ложной краснотой,
# живой замер пачки) + копии всех тегов репо (замороженность черновиков
# доказывается тегами — check_ceilings:19-22) + land-merge «land:
# wip/071/demo» + API-стаб (python3 http.server: green/failure/empty по
# head_sha) + мок-заголовок (судит Authorization: Bearer побайтово:
# 200/400) + корневой мок цели (отвечает только /repos/o/r — судит
# парсер) + фейковый ssh (приземляет ssh://github.com/o/r.git на bare
# мира). Судимый субъект — копия пары scripts/gitw +
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
# чистка посторонних worktree-путей по журналу created_wts: на выходе (trap)
# и МЕЖДУ фазами (sweep_wts) — путь, созданный фазой, не переживает её конец
sweep_wts() {
  while IFS= read -r w; do [ -n "$w" ] && rm -rf "$w"; done < "$WORK/created_wts"
  : > "$WORK/created_wts"
}
cleanup() {
  sweep_wts
  [ -n "${API_PID:-}" ] && kill "$API_PID" 2>/dev/null
  [ -n "${HDR_PID:-}" ] && kill "$HDR_PID" 2>/dev/null
  [ -n "${ROOT_PID:-}" ] && kill "$ROOT_PID" 2>/dev/null
  rm -rf "$WORK"
}
trap cleanup EXIT

WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"
PF='gitw ПРЕДПОЛЁТ-ОТКАЗ: '
POK='gitw ПРЕДПОЛЁТ: '

die_cell() { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }
ok_cell()  { printf 'ok: %s\n' "$1"; OKN=$(( ${OKN:-0} + 1 )); }

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
PP = sys.argv[3]
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        u = urlparse(self.path)
        if not re.match(r'^/repos/[^/]+/[^/]+/actions/runs$', u.path):
            self.send_response(404); self.end_headers(); return
        sha = (parse_qs(u.query).get('head_sha') or [''])[0]
        try:
            GREEN = set(x for x in open(GP).read().split() if x)
            FAIL = set(x for x in open(FP).read().split() if x)
            PUSH = set(x for x in open(PP).read().split() if x)
        except OSError:
            GREEN, FAIL, PUSH = set(), set(), set()
        if sha in GREEN:
            body = {"total_count": 1, "workflow_runs": [{"id": 1, "event": "pull_request", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
        elif sha in PUSH:
            body = {"total_count": 1, "workflow_runs": [{"id": 3, "event": "push", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
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
open(sys.argv[4], 'w').write(str(srv.server_port))
srv.serve_forever()
PYEOF
: > "$APIDIR/push.list"
python3 "$APIDIR/srv.py" "$APIDIR/green.list" "$APIDIR/fail.list" "$APIDIR/push.list" "$APIDIR/port" &
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

# ── мок-заголовок (живой укус №1): судит Authorization побайтово ─────────────
# Валидный «Authorization: Bearer <токен>» → 200 + тело по общим спискам
# green/fail/push; кривой или отсутствующий → 400 (GitHub живьём отвечал
# 400 на кривой заголовок). Отрицательные пробы обязательны: мок, не
# различающий заголовок, — не барьер (слепая выборка — красное).
TOY071TOKEN='toy071-bearer-token'
printf '%s\n' "$TOY071TOKEN" > "$APIDIR/token"
cat > "$APIDIR/hdrsrv.py" <<'PYEOF'
import json, re, sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
GP, FP, PP, TP = sys.argv[1:5]
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        u = urlparse(self.path)
        if not re.match(r'^/repos/[^/]+/[^/]+/actions/runs$', u.path):
            self.send_response(404); self.end_headers(); return
        try:
            want = 'Bearer ' + open(TP).read().strip()
        except OSError:
            self.send_response(500); self.end_headers(); return
        if self.headers.get('Authorization') != want:
            self.send_response(400); self.end_headers(); return
        sha = (parse_qs(u.query).get('head_sha') or [''])[0]
        try:
            GREEN = set(x for x in open(GP).read().split() if x)
            FAIL = set(x for x in open(FP).read().split() if x)
            PUSH = set(x for x in open(PP).read().split() if x)
        except OSError:
            GREEN, FAIL, PUSH = set(), set(), set()
        if sha in GREEN:
            body = {"total_count": 1, "workflow_runs": [{"id": 1, "event": "pull_request", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
        elif sha in PUSH:
            body = {"total_count": 1, "workflow_runs": [{"id": 3, "event": "push", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
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
open(sys.argv[5], 'w').write(str(srv.server_port))
srv.serve_forever()
PYEOF
python3 "$APIDIR/hdrsrv.py" "$APIDIR/green.list" "$APIDIR/fail.list" "$APIDIR/push.list" "$APIDIR/token" "$APIDIR/hdrport" &
HDR_PID=$!
HDRPORT=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$APIDIR/hdrport" ] && HDRPORT="$(cat "$APIDIR/hdrport")" && break
  sleep 0.2
done
[ -n "$HDRPORT" ] || die_cell среда "мок-заголовок не поднялся (порт не записан)"
HDRBASE="http://127.0.0.1:$HDRPORT/repos/a3ka/dev-harness"
curl -fsS -m 5 -H "Authorization: Bearer $TOY071TOKEN" "$HDRBASE/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  || die_cell среда "мок-заголовок не отвечает на валидный Bearer (пустая выборка — не проверено ничего)"
curl -fsS -m 5 -H "Authorization: Bearer NEVER071" "$HDRBASE/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  && die_cell среда "мок-заголовок отвечает 200 кривому Bearer — не различает заголовок"
curl -fsS -m 5 "$HDRBASE/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  && die_cell среда "мок-заголовок отвечает 200 без Authorization — не различает заголовок"

# ── корневой мок цели (живой укус №2): отвечает ТОЛЬКО /repos/o/r ────────────
# Шов-КОРЕНЬ без /repos: честная реализация обязана взять owner/repo из
# ЦЕЛИ (ssh://github.com/o/r.git) и построить /repos/o/r/actions/runs;
# чужой путь (захардкоженное имя, непарс, голый /actions/runs) — 404.
cat > "$APIDIR/rootsrv.py" <<'PYEOF'
import json, sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
GP, FP, PP = sys.argv[1:4]
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        u = urlparse(self.path)
        if u.path != '/repos/o/r/actions/runs':
            self.send_response(404); self.end_headers(); return
        sha = (parse_qs(u.query).get('head_sha') or [''])[0]
        try:
            GREEN = set(x for x in open(GP).read().split() if x)
            FAIL = set(x for x in open(FP).read().split() if x)
            PUSH = set(x for x in open(PP).read().split() if x)
        except OSError:
            GREEN, FAIL, PUSH = set(), set(), set()
        if sha in GREEN:
            body = {"total_count": 1, "workflow_runs": [{"id": 1, "event": "pull_request", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
        elif sha in PUSH:
            body = {"total_count": 1, "workflow_runs": [{"id": 3, "event": "push", "head_sha": sha, "status": "completed", "conclusion": "success"}]}
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
open(sys.argv[4], 'w').write(str(srv.server_port))
srv.serve_forever()
PYEOF
python3 "$APIDIR/rootsrv.py" "$APIDIR/green.list" "$APIDIR/fail.list" "$APIDIR/push.list" "$APIDIR/rootport" &
ROOT_PID=$!
ROOTPORT=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$APIDIR/rootport" ] && ROOTPORT="$(cat "$APIDIR/rootport")" && break
  sleep 0.2
done
[ -n "$ROOTPORT" ] || die_cell среда "корневой мок не поднялся (порт не записан)"
ROOT2="http://127.0.0.1:$ROOTPORT"
curl -fsS -m 5 "$ROOT2/repos/o/r/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  || die_cell среда "корневой мок не отвечает на /repos/o/r (пустая выборка — не проверено ничего)"
curl -fsS -m 5 "$ROOT2/repos/a3ka/dev-harness/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  && die_cell среда "корневой мок отвечает чужому owner/repo — не судит парсер цели"
curl -fsS -m 5 "$ROOT2/actions/runs?head_sha=proba" >/dev/null 2>&1 \
  && die_cell среда "корневой мок отвечает пути без /repos — не судит композицию цели"

# ── фейковый ssh: приземление ssh://github.com/o/r.git на локальный bare ─────
# URL-строка живёт побайтово (origin/канон/ls-remote/push идут через
# ssh-транспорт); место назначения — локальный bare мира (FAKE_BARE из env).
GHURL='ssh://github.com/o/r.git'
cat > "$WORK/fakessh" <<'SSHEOF'
#!/usr/bin/env bash
case "$*" in
  *upload-pack*)   exec git upload-pack "$FAKE_BARE" ;;
  *receive-pack*)  exec git receive-pack "$FAKE_BARE" ;;
  *) printf 'fakessh: неизвестная команда: %s\n' "$*" >&2; exit 1 ;;
esac
SSHEOF
chmod +x "$WORK/fakessh"
FAKEPROBE="$WORK/fakeprobe"; FAKEBARE="$WORK/fakeprobe.git"
git init -q -b main "$FAKEPROBE"; git init -q --bare "$FAKEBARE"
( cd "$FAKEPROBE" && git -c user.name=t -c user.email=t@t.local commit -q --allow-empty -m probe )
FAKE_BARE="$FAKEBARE" GIT_SSH="$WORK/fakessh" git -C "$FAKEPROBE" ls-remote "$GHURL" HEAD >/dev/null 2>&1 \
  || die_cell среда "фейковый ssh не приземляет ls-remote (upload-pack) на локальный bare"
FAKE_BARE="$FAKEBARE" GIT_SSH="$WORK/fakessh" git -C "$FAKEPROBE" push -q "$GHURL" main >/dev/null 2>&1 \
  || die_cell среда "фейковый ssh не приземляет push (receive-pack) на локальный bare"

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
  [ "$mode" = "pushok" ] && printf '%s\n' "$p2" >> "$APIDIR/push.list"
  git -C "$T" checkout -q main
  git -C "$T" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false merge --no-ff -q -m 'land: wip/071/demx' wip/071/demx \
    || die_cell "demx-$mode" "второй land-merge не построился"
}

# кандидат-ветка с модифицируемым package.json, построенная СТОРОННИМ
# worktree — $T остаётся НА MAIN (cwd push'а не переключается). Различие
# ключей судится по ОТПРАВЛЯЕМОМУ src, не по cwd (адверсарий 071-r1 Б2):
# checkout -b в $T (как у п9а/п9б) сделал бы cwd == src и не наблюдал бы
# чтение не того дерева. mk_keycand создаёт ветку + временный worktree
# (CANDW), caller правит package.json там и зовёт cand_commit.
mk_keycand() { # mk_keycand <branch> → CANDW=<worktree-путь>
  local br="$1"
  git -C "$T" branch -q "$br" main
  local cw="$WTROOT/$(h8)"; mkdir -p "$cw"
  git -C "$T" worktree add -q "$cw/w" "$br" \
    || die_cell "$br" "кандидат-worktree не строится"
  printf '%s\n' "$cw" >> "$WORK/created_wts"
  CANDW="$cw/w"
}
cand_commit() { # cand_commit <branch> <msg>: коммитит CANDW, снимает worktree
  git -C "$CANDW" add -A && ident "$CANDW" -m "$2"
  git -C "$T" worktree remove --force "$CANDW" 2>/dev/null
}

# мир ssh-цели (живой укус №2): mk_world + перенос origin на
# ssh://github.com/<owner>/<repo>.git — форма БЕЗ user-части. Транспорт
# приземляется фейковым ssh ($WORK/fakessh + FAKE_BARE=$B1, режим gh):
# bare уже наполнен базовым пушем mk_world, земля ленда зелёная в общих
# списках; URL-строка остаётся побайтовой (origin/канон/ls-remote/push).
mk_world_ssh() { # mk_world_ssh <имя>: B1/T выставлены, origin = GHURL
  mk_world "$1"
  git -C "$T" remote set-url origin "$GHURL"
}

# прогон судимой пары; env-ручки: APIENV = api|dead|none|hdr|gh
run_push() { # run_push <режим-api: api|dead|none|hdr|gh> <аргументы push...>
  local apimode="$1"; shift
  SNAP_B1="$(git -C "$B1" rev-parse -q --verify refs/heads/main 2>/dev/null || printf НЕТ)"
  local -a envs=(GIT_EXCHANGE_GUARD_CANONICAL="$B1")
  case "$apimode" in
    api)  envs+=(GITW_PREFLIGHT_071_API="$APIBASE") ;;
    dead) envs+=(GITW_PREFLIGHT_071_API="http://127.0.0.1:$DEADPORT/repos/a3ka/dev-harness") ;;
    hdr)  envs+=(GITW_PREFLIGHT_071_API="$HDRBASE" GITHUB_TOKEN="$TOY071TOKEN") ;;
    gh)   envs=(GIT_EXCHANGE_GUARD_CANONICAL="$GHURL" GITW_PREFLIGHT_071_API="$ROOT2"
              GIT_SSH="$WORK/fakessh" FAKE_BARE="$B1") ;;
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
ghparse() { # owner/repo из github-URL (грамматика живого укуса №2 включена)
  local r; r="$(printf '%s' "$1" | sed -nE 's#^(ssh://(git@)?github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(\.git)?$#\3/\4#p' | head -1)"
  printf '%s' "${r%.git}"
}
# ── покрытие main ──────────────────────────────────────────────────────────
curbr="$(git symbolic-ref -q HEAD 2>/dev/null || true)"
main_cov=0; unjudge=0; saw_ref=0; send_src=""
for a in "$@"; do
  case "$a" in -*) continue ;; esac
  saw_ref=1
  case "$a" in *\**) REASON "refspec не разбирается: $a" ;; esac
  if [ "$DEF" = "s9" ]; then
    if [ "$a" = "main" ]; then main_cov=1; send_src="$a"; fi
    continue
  fi
  src="${a%%:*}"; dst="${a#*:}"
  if [ "$dst" != "$a" ]; then
    dst="${dst#refs/heads/}"
    if [ "$dst" = "main" ]; then main_cov=1; send_src="$src"; fi
  else
    case "$src" in
      main|refs/heads/main) main_cov=1; send_src="$src" ;;
      HEAD)
        if [ "$curbr" = "refs/heads/main" ]; then main_cov=1; send_src=HEAD; else unjudge=1; fi ;;
      *) : ;;
    esac
  fi
done
if [ "$saw_ref" -eq 0 ]; then
  # Н-39 (Р-1/Р-2 071-r1): пустой хвост refspec при ветке main — покрытие
  # строится из текущей ветки; стабы: s14 — молчаливый пропуск пустого
  # хвоста (корень Р-1: красный main уезжает молча), s15 — огульное
  # «несудимая» на main вместо покрытия (не той причиной, легитимная
  # форма блокнута).
  if [ "$DEF" = "s14" ]; then exit 0; fi
  if [ "$DEF" = "s15" ]; then unjudge=1
  elif [ "$curbr" = "refs/heads/main" ]; then main_cov=1; send_src=HEAD
  else unjudge=1; fi
fi
if [ "$unjudge" -eq 1 ] && [ "$DEF" != "s11" ]; then
  REASON "несудимая конфигурация refspec: явного dst нет при текущей ветке ${curbr:-detached}"
fi
[ "$main_cov" -eq 1 ] || exit 0
[ -n "$send_src" ] || REASON "refspec не разбирается: удаление main"
[ "$DEF" = "s12" ] && send_src=refs/heads/main
send_tip="$(git rev-parse -q --verify "$send_src" 2>/dev/null)" || REASON "отправляемый src не разрешается: $send_src"
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
  # цель API: полный base (совместимость) либо КОРЕНЬ + owner/repo из ЦЕЛИ
  # (живой укус №2: форма ssh://github.com/<o>/<r>.git без user-части).
  # s17 — грамматика r2 БЕЗ этой формы: ssh-цель → «цель не github».
  case "$API" in
    */repos/*) : ;;
    *)
      gr=""
      for u in "$TGT" "$(git remote get-url "$TGT" 2>/dev/null || true)"; do
        case "$u" in
          ssh://github.com/*)
            [ "$DEF" = "s17" ] && continue
            gr="$(ghparse "$u")"; break ;;
          ssh://git@github.com/*|git@github.com:*|https://github.com/*)
            gr="$(ghparse "$u")"; break ;;
        esac
      done
      [ -n "$gr" ] || REASON "PR-CI не сверяем: цель не github"
      API="$API/repos/$gr"
      ;;
  esac
  # заголовок авторизации: честная форма — ДВУМЯ argv; s16 — ОДНИМ argv
  # (конструкция живого укуса №1: curl молча роняет заголовок, мок — 400)
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    authargs=(-H "Authorization: Bearer $GITHUB_TOKEN")
    [ "$DEF" = "s16" ] && authargs=("${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"}")
  else
    authargs=()
  fi
  body="$(curl -fsS -m 10 ${authargs[@]+"${authargs[@]}"} "$API/actions/runs?event=pull_request&head_sha=$p" 2>/dev/null)" || {
    [ "$DEF" = "s7" ] && continue
    REASON "PR-CI не сверяем: API"
  }
  if [ "$DEF" = "s6" ]; then
    tc="$(printf '%s' "$body" | jq -r '.total_count // 0' 2>/dev/null)"; [ "$tc" -gt 0 ] || continue
  fi
  if [ "$DEF" = "s13" ]; then
    n="$(printf '%s' "$body" | jq -r '[.workflow_runs[] | select(.conclusion=="success")] | length' 2>/dev/null)"
  elif [ "$DEF" = "s5" ]; then
    n="$(printf '%s' "$body" | jq -r '.total_count // 0' 2>/dev/null)"
  else
    n="$(printf '%s' "$body" | jq -r '[.workflow_runs[] | select(.event=="pull_request" and .conclusion=="success")] | length' 2>/dev/null)"
  fi
  [ "${n:-0}" -ge 1 ] || REASON "land без зелёного PR-CI: $br ($p)"
done < <(git log --first-parent --merges --format='%H %s' "$rmain..$send_tip" 2>/dev/null)
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
  git worktree add -q --detach "$tw" "$send_src" 2>/dev/null || REASON "дерево чеков не строится"
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
for s in s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17; do mk_stub "$s"; done

run_stub() { # run_stub <стаб> <режим-api: api|dead|none|hdr|gh> <аргументы push...>
  local st="$1" apimode="$2"; shift 2
  local -a envs=(STUB_DEFECT="$st" GIT_EXCHANGE_GUARD_CANONICAL="$B1")
  local tgt="$B1"
  case "$apimode" in
    api)  envs+=(GITW_PREFLIGHT_071_API="$APIBASE") ;;
    dead) envs+=(GITW_PREFLIGHT_071_API="http://127.0.0.1:$DEADPORT/repos/a3ka/dev-harness") ;;
    hdr)  envs+=(GITW_PREFLIGHT_071_API="$HDRBASE" GITHUB_TOKEN="$TOY071TOKEN") ;;
    gh)   tgt="$GHURL"
          envs+=(GITW_PREFLIGHT_071_API="$ROOT2" GIT_SSH="$WORK/fakessh" FAKE_BARE="$B1") ;;
    none) : ;;
    *) die_cell среда "неизвестный режим api: $apimode" ;;
  esac
  ( cd "$T" && env "${envs[@]}" bash "$WORK/stubs_$st.sh" "$tgt" "$@" ) >"$WORK/last.out" 2>"$WORK/last.err"
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
      printf '%s\n' "$WTROOT-slob" >> "$WORK/created_wts"
      git -C "$T" worktree add -q -b wip/071/wtf "$WTROOT-slob/wt" main >/dev/null 2>&1 ;;
    garbage-wt)
      mk_world sv-garbage
      git -C "$T" worktree add -q --detach "$WORK/slob071" main >/dev/null 2>&1 ;;
    nesudimyj)
      mk_world sv-nesud
      python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
      git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat main'
      git -C "$T" checkout -q wip/071/demo ;;
    bezrefspec)
      mk_world sv-bezref
      python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
      git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat main bez refspec' ;;
    bezrefspec2)
      mk_world sv-bezref2
      python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
      git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat main bez refspec' ;;
    src-ne-main)
      mk_world sv-srcne
      git -C "$T" checkout -q -b wip/071/cand
      python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
      git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat cand'
      git -C "$T" checkout -q main ;;
    pushok)
      mk_world sv-pushok; mk_second_land pushok ;;
    hdr-token)
      mk_world sv-hdr ;;
    ssh-root)
      mk_world_ssh sv-ssh ;;
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
    "s11:nesudimyj:несудимая конфигурация refspec"
    "s12:src-ne-main:чек красный: check:ceilings"
    "s13:pushok:land без зелёного PR-CI: wip/071/demx"
    "s14:bezrefspec:чек красный: check:ceilings"
    "s15:bezrefspec2:чек красный: check:ceilings"
    "s16:hdr-token:УСПЕХ"
    "s17:ssh-root:УСПЕХ"
  )
  local pair st kind want api_mode toks
  local caught=0 diff=0
  for pair in "${pairs[@]}"; do
    IFS=: read -r st kind want _ <<<"$pair"
    api_mode=api; toks=(main)
    [ "$st" = "s9" ] && toks=(refs/heads/main)
    [ "$st" = "s7" ] && api_mode=dead
    [ "$st" = "s11" ] && toks=()
    [ "$st" = "s12" ] && toks=(wip/071/cand:main)
    [ "$st" = "s14" ] && toks=()
    [ "$st" = "s15" ] && toks=()
    [ "$st" = "s16" ] && api_mode=hdr
    [ "$st" = "s17" ] && api_mode=gh
    # мир-нарушение: обманный стаб обязан ПРОЖИТЬ его (rc 0 либо отказ не той
    # причиной) — именно это и есть «пойман»: мир настоящий, дефект различим.
    # Отказался правильно — дефект мёртв, батарея красна (стаб не обманут).
    stub_violation "$kind"
    run_stub "$st" "$api_mode" "${toks[@]}"
    if [ "$want" = УСПЕХ ]; then
      # мир зелёный для честной реализации (живые укусы 2026-10-02):
      # стаб, ПРОШЕДШИЙ его как честная (rc 0), — дефект не наблюдаем,
      # обманка мертва; расходится (отказ/иной исход) — дефект различим.
      [ "$RC" -eq 0 ] && die_cell "стаб-$st" "не обманут: прошёл «$kind» как честная реализация — дефект не воспроизводится"
    elif [ "$RC" -eq 1 ] && grep -qF -- "$PF$want" "$WORK/last.err"; then
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
  SNAP_B1="$(git -C "$B1" rev-parse -q --verify refs/heads/main 2>/dev/null || printf НЕТ)"
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

  # п4е: зелёный success ЧУЖОГО event (push) — не санкция (слово владельца п.3)
  mk_world p4e; mk_second_land pushok
  run_push api origin main
  expect_refuse п4е "${PF}land без зелёного PR-CI: wip/071/demx"
  bare_frozen п4е; ok_cell 'п4е: success event=push не санкционирует land'

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
  printf '%s\n' "$WTROOT-slob" >> "$WORK/created_wts"
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

  # п6г: push БЕЗ refspec при текущей ветке ≠ main — несудимая конфигурация
  # (мир push.default=matching: прозрачная реализация отправила бы красный main)
  mk_world p6g
  python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat main'
  git -C "$T" config push.default matching
  git -C "$T" checkout -q wip/071/demo
  run_push api origin
  expect_refuse п6г "${PF}несудимая конфигурация refspec"
  bare_frozen п6г; ok_cell 'п6г: push без refspec вне main — fail-closed отказ'

  # п6д: HEAD без явного dst при текущей ветке ≠ main — тот же отказ
  run_push api origin HEAD
  expect_refuse п6д "${PF}несудимая конфигурация refspec"
  bare_frozen п6д; ok_cell 'п6д: HEAD без dst вне main — fail-closed отказ'

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

  # п7а: 1 из 4 ключей в ОТПРАВЛЯЕМОМ src, cwd (main) несёт полные 4 —
  # классификация по cwd (адверсарий 071-r1 Б2) дала бы «4 из 4» и
  # пропустила бы отказ; honest-реализация обязана отказать по src.
  mk_world p7a
  mk_keycand wip/071/cand7a
  ( cd "$CANDW" && python3 - <<'PYE'
import json
p = json.load(open('package.json'))
for k in ('check:nabludenia', 'check:ci-parity', 'check:ids'):
    p['scripts'].pop(k, None)
json.dump(p, open('package.json', 'w'), ensure_ascii=False, indent=2)
PYE
  )
  cand_commit wip/071/cand7a 'cand keys 1 of 4'
  run_push api origin wip/071/cand7a:main
  expect_refuse п7а "${PF}чек-ключи не полностью: 1 из 4"
  bare_frozen п7а; ok_cell 'п7а: src 1-из-4 ключей (cwd main полный) — отказ по отправляемому дереву'

  # п7б: 3 из 4 ключей в src, cwd (main) полный — тот же класс расхождения,
  # ровно клетка, которую ловит мутант предиката nk==0→nk==3 (вердикт Б1).
  mk_world p7b
  mk_keycand wip/071/cand7b
  ( cd "$CANDW" && python3 - <<'PYE'
import json
p = json.load(open('package.json'))
p['scripts'].pop('check:ids', None)
json.dump(p, open('package.json', 'w'), ensure_ascii=False, indent=2)
PYE
  )
  cand_commit wip/071/cand7b 'cand keys 3 of 4'
  run_push api origin wip/071/cand7b:main
  expect_refuse п7б "${PF}чек-ключи не полностью: 3 из 4"
  bare_frozen п7б; ok_cell 'п7б: src 3-из-4 ключей (cwd main полный) — отказ по отправляемому дереву'

  # п7в: 0 из 4 ключей в src (package.json отсутствует), cwd (main) полный —
  # именованный ПРОПУСК по src, обмен продолжается, цель на tip кандидата.
  mk_world p7c
  mk_keycand wip/071/cand7c
  git -C "$CANDW" rm -q package.json
  cand_commit wip/071/cand7c 'cand keys 0 of 4 (no package.json)'
  run_push api origin wip/071/cand7c:main
  [ "$RC" -eq 0 ] \
    || die_cell п7в "0 ключей в src не пропущен: rc=$RC $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  grep -qF "${POK}чеки неприменимы" "$WORK/last.err" \
    || die_cell п7в "именованный пропуск не напечатан: $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  [ "$(git -C "$B1" rev-parse refs/heads/main)" = "$(git -C "$T" rev-parse wip/071/cand7c)" ] \
    || die_cell п7в "цель не на tip кандидата (0 ключей обязан пропустить и продвинуть)"
  ok_cell 'п7в: src 0-из-4 ключей (cwd main полный) — именованный пропуск, цель продвинута'

  # п7г: push origin БЕЗ refspec при текущей ветке main — предполёт несётся
  # (А7б третья пара, Р-1/Р-2 ревьюера 071-r1: парсер предполёта молчал —
  # красный main уезжал). Мир как п2а (красный ceilings на main), upstream
  # main→origin/main — обмен формы «push origin» доходит до exec.
  mk_world p7g
  python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat main bez refspec'
  git -C "$T" branch --set-upstream-to=origin/main main
  run_push api origin
  expect_refuse п7г "${PF}чек красный: check:ceilings"
  bare_frozen п7г; ok_cell 'п7г: push origin без refspec (main, красный чек) — предполёт несётся'

  # п7д: push БЕЗ remote и refspec при текущей ветке main — тот же отказ
  # (голый `gitw push` по upstream; клетка стаба s15: «несудимая» вместо
  # «чек красный» не засчитывается)
  mk_world p7d
  python3 -c "print('x'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat main bez remote'
  git -C "$T" branch --set-upstream-to=origin/main main
  run_push api
  expect_refuse п7д "${PF}чек красный: check:ceilings"
  bare_frozen п7д; ok_cell 'п7д: push без remote (main, красный чек) — тот же отказ'

  # п8: cwd ≠ отправляемое дерево — чеки видят ОТПРАВЛЯЕМОЕ дерево
  mk_world p8
  python3 -c "print('z'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat on main'
  git -C "$T" checkout -q -b stara HEAD~1
  run_push api origin main
  expect_refuse п8 "${PF}чек красный: check:ceilings"
  bare_frozen п8; ok_cell 'п8: чеки на отправляемом дереве, не на чекауте'

  # п9а: src ≠ main — чеки обязаны идти по ОТПРАВЛЯЕМОМУ src (критик к1 Б5)
  mk_world p9a
  git -C "$T" checkout -q -b wip/071/cand
  python3 -c "print('z'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat cand'
  git -C "$T" checkout -q main
  run_push api origin wip/071/cand:main
  expect_refuse п9а "${PF}чек красный: check:ceilings"
  bare_frozen п9а; ok_cell 'п9а: чеки по отправляемому src (cand:main), не по main'

  # п9б: HEAD:main при текущей ветке candidate — src = HEAD
  mk_world p9b
  git -C "$T" checkout -q -b wip/071/cand
  python3 -c "print('z'*60000)" > "$T/roles/orchestrator.md"
  git -C "$T" add roles/orchestrator.md && ident "$T" -m 'fat cand'
  run_push api origin HEAD:main
  expect_refuse п9б "${PF}чек красный: check:ceilings"
  bare_frozen п9б; ok_cell 'п9б: HEAD:main — чеки на HEAD (candidate), не на main'

  # п9в: зелёная пара — candidate:main с зелёным деревом проходит, цель на tip
  mk_world p9v
  git -C "$T" checkout -q -b wip/071/cand
  printf 'кандидат зелёный\n' > "$T/cand071.txt"
  git -C "$T" add cand071.txt && ident "$T" -m 'green cand'
  git -C "$T" checkout -q main
  run_push api origin wip/071/cand:main
  [ "$RC" -eq 0 ] || die_cell п9в "зелёный candidate:main отказан: $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  [ "$(git -C "$B1" rev-parse refs/heads/main)" = "$(git -C "$T" rev-parse refs/heads/wip/071/cand)" ] \
    || die_cell п9в "цель не на tip candidate"
  ok_cell 'п9в: зелёный candidate:main проходит, цель на tip candidate'

  # п8а: боевой API-шов — заголовок авторизации (живой укус 2026-10-02 №1:
  # конструкция «-H Authorization: Bearer …» ОДНИМ argv молча роняла
  # заголовок — GitHub отвечал 400; батарея r2 не ловила: её шов смотрел
  # на закрытый порт, отказ «по плану» совпал с отказом «по дефекту»).
  # Мок судит заголовок побайтово: валидный Bearer → 200 + зелёный PR-CI,
  # кривой/отсутствующий → 400. Честный предполёт ДОХОДИТ до мока с
  # валидным заголовком, получает 200 — пуш планируется и проходит.
  mk_world p8a
  run_push hdr origin main
  [ "$RC" -eq 0 ] || die_cell п8а "зелёный мир с мок-заголовком отказан: $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  grep -qF "$POK" "$WORK/last.err" || die_cell п8а "строка успеха «gitw ПРЕДПОЛЁТ: » не напечатана (молчание)"
  [ "$(git -C "$B1" rev-parse refs/heads/main)" = "$(git -C "$T" rev-parse main)" ] \
    || die_cell п8а "bare-цель не на tip отправленного main"
  ok_cell 'п8а: валидный заголовок Bearer доходит до API — пуш планируется'

  # п8б: парсер цели ssh://github.com/<owner>/<repo>.git (живой укус №2:
  # origin без user-части не разбирался → «цель не github», зелёный PR-CI
  # не спрашивался). Мир: origin переписан на ssh://github.com/o/r.git
  # (транспорт приземлён фейковым ssh на локальный bare — URL-строка
  # побайтово живая), шов — КОРЕНЬ мока: честный парсит owner/repo из
  # ЦЕЛИ и зовёт API по /repos/o/r/actions/runs; мок отвечает ТОЛЬКО
  # этому пути — захардкоженное чужое имя не проходит.
  mk_world_ssh p8b
  run_push gh origin main
  [ "$RC" -eq 0 ] || die_cell п8б "ssh-цель ssh://github.com/o/r.git отказана: $(tail -n 3 "$WORK/last.err" | tr '\n' ' ')"
  grep -qF "$POK" "$WORK/last.err" || die_cell п8б "строка успеха «gitw ПРЕДПОЛЁТ: » не напечатана (молчание)"
  [ "$(git -C "$B1" rev-parse refs/heads/main)" = "$(git -C "$T" rev-parse main)" ] \
    || die_cell п8б "bare-цель не на tip отправленного main (ssh-приземление не довело)"
  ok_cell 'п8б: ssh://github.com/o/r.git парсится — owner/repo спрашиваются у API'
}

# ── порядок: само-проверка → стаб-пак → честные клетки ───────────────────────
OKN=0
run_stub_pack
# межфазная чистка: миры стаб-пака мертвы, но их посторонние worktree-пути
# (журнал created_wts; у стаба podstroka — фиксированный $WTROOT-slob,
# строковая подстрока корня) переживают свой мир. Без чистки клетка п5в
# строит worktree на том же пути поверх остатка: worktree add молчит
# «каталог непуст» под >/dev/null, постороннего worktree в её мире нет —
# клетка непроходима честной реализацией (Impl071r, блокер-2).
sweep_wts
run_honest_cells
CELLS=$((OKN - 1))
printf 'честные клетки: %s/%s зелёные; стаб-пак 17/17 + дифф 17/17\n' "$CELLS" "$CELLS"
exit 0
