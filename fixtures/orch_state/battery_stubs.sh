#!/usr/bin/env bash
# Стаб-пак 092 (Н-39: привязка стабов к входам — ЗДЕСЬ, в коде, не в прозе контракта).
#
# Каждый обманный стаб — мини-субъект, подставляемый клетками (env O92_SUBJ_CHECKPOINT /
# O92_SUBJ_STATUS / O92_SUBJ_CIWAIT) вместо scripts/orch_{checkpoint,status}.sh и
# scripts/ci_wait.sh, и прогоняется на входе, где его дефект наблюдаем: клетка обязана
# быть красной (rc 1 клетки, «КРАСНО: …»). Мини-субъекты — ОДНО python-тело в трёх
# режимах (O92_MODE); заплатка стаба правит ОБЩЕЕ тело → все три режима согласованы
# (пишет и читает одно и то же — дефект ровно одной ветви, ложной красноты на соседних
# клетках нет).
# Диффпроба: честное тело зелёно на ВСЕХ 21 клетках (17 красных + 4 зелёных case,
# единый прогон rc 0) — иначе клетки ловят не дефект, а себя. rc 2 — нечем проверить.
# Литералы грамматики приходят env-ом O92L_* из _toy.sh (единый источник).
#
# PAK (стаб → клетка; дефект по коду ветви субъекта):
#   S1  → red_net_off_local_survives    ветвь «сеть недоступна» orch_status: вместо
#          строки «удалённое состояние: неизвестно» rc 2 «нет сети», локальные поля
#          не печатает (rc и отсутствие полей)
#   S2  → red_net_off_local_survives    orch_status при отказе сети печатает поля rc 0,
#          но строки «удалённое состояние: неизвестно» НЕТ (молчание)
#   S3  → red_pub_vs_close              различение pub/close: всегда одна строка
#          «статус: в работе» вместо ДВУХ («опубликовано: …»/«закрытие: …»)
#   S4  → red_status_derives_not_echo   ветвь --next: последняя строка живого
#          HANDOFF.md вместо next_step состояния («шаг Б» против «шаг А»)
#   S5  → red_ciwait_no_repoll          ветвь повтора ci_wait: один запрос,
#          in_progress → немедленный rc 3 (поллинг отдан модели)
#   S6  → red_restart_no_dup_task       task-init без дедупа: append всегда
#   S7  → red_restart_no_dup_round      event: append без сравнения тройки
#          (kind, subject, ref) — 4 круга вместо 2
#   S8  → red_restart_no_dup_publish    pub-start при существующем pub-done того же
#          ключа не отказывает и пишет вторую запись
#   S9  → red_three_fails_three_rounds +
#          red_rounds_count_events_not_files
#                                         счёт кругов = uniq-ПУТЯМ вердикт-файлов
#          (path@sha → path), не событиям: 2 файла против 3 кругов
#   S10 → red_three_fails_three_rounds   счёт round-fail по уникальному subject без
#          ref: три FAIL одного предмета → «кругов: 1»
#   S11 → red_three_fails_three_rounds   счёт в памяти процесса, журнал при старте не
#          читается → «кругов: 0». Контракт называет для S11 также клетку 2 — в паке
#          различимость ДОКАЗАНА на клетке 7: клетка 2 не проходит через ветвь счёта
#          (её данные не содержат требования кругов), а стаб, теряющий в памяти
#          СОСТОЯНИЕ, красил бы и клетку 1 — ложная краснота, запрещённая преамбулой
#          §(3) («честен на остальных входах»); запись — NABLIUDENIA_ARCHITECT (А-32)
#   S12 → red_checkpoint_atomic_fail     запись напрямую в state.tsv без tmp+rename:
#          на read-only каталоге обрезает/повреждает прежний файл (sha256 до/после)
#   S13 → red_checkpoint_grammar         неизвестные ключи и значения вне алфавита
#          принимаются молча (нет rc 1 «состояние вне грамматики»)
#   S14 → red_state_outside_tree         ветвь записи зеркалит состояние в
#          <root>/orch-state.tsv (внутри стерегомого дерева; state-dir пишется как
#          честно — дефект ровно «мутирует дерево», наблюдаем на porcelain клетки 12)
#   S15 → red_ciwait_net_vs_timeout     ci_wait, ветвь «транспорт недоступен»:
#          обработчик ошибки сети выходит с rc 3 (как при таймауте) вместо rc 2
#          «нечем проверить» — два терминальных исхода неразличимы; различим на
#          входе-а клетки (refused-эндпоинт при щедрых попытках); вход-б честен
#   S16 → red_checkpoint_atomic_fail     составные операции (init = state +
#          task-init; pub-done = событие + state) без атомарности ЦЕЛОЕ (тело
#          6ca209c: init — state до журнала, pub-done — журнал до state, без
#          предподготовки): отказ второго шага оставляет полузапись — sha
#          ДО≠ПОСЛЕ на входах б/в клетки (вход-а затрагивает только put)
#   S17 → red_pub_state_needs_proof      put pub_state published судит только
#          алфавит И-2, без доказательства (журнал pub-done либо достижимость
#          кандидата из origin/main): rc 0 на входе-а вместо rc 1
#   S18 → red_pub_done_mismatch_refusal  event pub-done без сверки subject/candidate
#          с текущим состоянием (тело 33caf2ef как есть): pub_state=published
#          присваивается БЕЗУСЛОВНО на любом pub-done — чужая задача и/или кандидат
#          повышают pub_state ТЕКУЩЕЙ задачи (нарушение И-8, adversary круг 1, находка 2)
#
# Использование: bash battery_stubs.sh <корень>. Итог: «стаб-пак 092: N/18 поймано,
# диффпроба M/21»; rc 0 ⟺ N = 18 ∧ M = 21.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
# shellcheck disable=SC1091
. "$HERE/_toy.sh"

# ── честное python-тело мини-субъекта (грамматика И-2/И-3/И-4/И-5, литералы env-ом) ─────
cat > "$O92SCR/body_chestnoj.py" <<'O92PY'
import json, os, re, subprocess, sys, time

MODE = os.environ['O92_MODE']
STATE_DIR = os.environ.get('ORCH_STATE_DIR', '/tmp/dev-harness-verify/orch-state')
GH_API = os.environ.get('ORCH_GH_API', 'https://api.github.com')
REPO = os.environ.get('ORCH_REPO', os.getcwd())

KEYS = ('task', 'stage', 'candidate', 'last_proven', 'waiting', 'next_step', 'pub_state')
STAGES = ('draft', 'spec', 'frozen', 'implement', 'judge', 'publish', 'close', 'done')
PUBS = ('unknown', 'nothing', 'pushed', 'merged', 'published', 'close_incomplete')
KINDS = ('task-init', 'stage', 'round-fail', 'round-accept', 'pub-start', 'pub-done', 'wait-start', 'wait-done')
TOKENRE = r'[^\t\x00-\x1f\x7f]+'

STATE = os.path.join(STATE_DIR, 'state.tsv')
EVENTS = os.path.join(STATE_DIR, 'events.tsv')

L = os.environ

def out(s):
    sys.stdout.write(s + '\n')

def err(s):
    sys.stderr.write(s + '\n')

def gr(k, v):
    if k == 'stage':
        return v in STAGES
    if k == 'pub_state':
        return v in PUBS
    if k == 'waiting':
        return v in ('none', 'owner', 'external') \
            or re.fullmatch(r'ci:[0-9a-f]{40}', v) is not None \
            or re.fullmatch(r'judge:[0-9]{3}', v) is not None
    if k == 'task':
        return re.fullmatch(r'[0-9]{3}', v) is not None \
            or (0 < len(v) <= 64 and re.fullmatch(TOKENRE, v) is not None)
    if k == 'candidate':
        return v == '-' or re.fullmatch(r'[0-9a-f]{40}', v) is not None
    if k == 'last_proven':
        return v == '-' or re.fullmatch(r'[a-z-]+@[0-9]+', v) is not None
    if k == 'next_step':
        return 0 < len(v.encode('utf-8')) <= 200 and re.fullmatch(TOKENRE, v) is not None
    return False

class GrammarError(Exception):
    def __init__(self, key):
        self.key = key

def die_gramm(k):
    err(L['O92L_GRAMM_PRE'] + k)
    sys.exit(1)

def read_state():
    try:
        data = open(STATE, 'rb').read()
    except FileNotFoundError:
        return None
    m = {}
    for raw in data.split(b'\n'):
        if not raw:
            continue
        line = raw.decode('utf-8', 'surrogateescape')
        if '\t' not in line:
            die_gramm('state')
        k, v = line.split('\t', 1)
        if k not in KEYS or k in m:
            die_gramm(k)
        if not gr(k, v):
            die_gramm(k)
        m[k] = v
    for k in KEYS:
        if k not in m:
            die_gramm(k)
    return m

def state_bytes(m):
    return ''.join(k + '\t' + m[k] + '\n' for k in KEYS).encode('utf-8')

def write_state(m):
    data = state_bytes(m)
    tmp = os.path.join(STATE_DIR, '.state.tsv.tmp')
    with open(tmp, 'wb') as f:
        f.write(data)
    os.replace(tmp, STATE)

def read_events():
    try:
        data = open(EVENTS, 'rb').read()
    except FileNotFoundError:
        return []
    out_l = []
    for raw in data.split(b'\n'):
        if not raw:
            continue
        parts = raw.decode('utf-8', 'surrogateescape').split('\t')
        if len(parts) == 4:
            out_l.append(parts)
    return out_l

def append_event(kind, subject, ref):
    ts = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    with open(EVENTS, 'ab') as f:
        f.write((ts + '\t' + kind + '\t' + subject + '\t' + ref + '\n').encode('utf-8'))

def composite_write(m, kind, subject, ref):
    data = state_bytes(m)
    line = (time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()) + '\t' + kind + '\t'
            + subject + '\t' + ref + '\n').encode('utf-8')
    tmp = os.path.join(STATE_DIR, '.state.tsv.tmp')
    try:
        with open(tmp, 'wb') as f:
            f.write(data)
        fh = open(EVENTS, 'ab')
    except OSError:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        zapfail()
    fh.write(line)
    os.replace(tmp, STATE)
    fh.close()

def triple_exists(kind, subject, ref):
    for e in read_events():
        if e[1] == kind and e[2] == subject and e[3] == ref:
            return True
    return False

def ref_ok(kind, ref):
    if kind.startswith('round-'):
        return re.fullmatch(r'[^\t\x00-\x1f\x7f]+@[0-9a-f]{40}', ref) is not None
    if kind.startswith('pub-'):
        return re.fullmatch(r'[0-9a-f]{40}@[^\t\x00-\x1f\x7f]+', ref) is not None
    if kind.startswith('wait-'):
        return re.fullmatch(r'[0-9a-f]{40}', ref) is not None
    return re.fullmatch(r'[^\t\x00-\x1f\x7f]{0,200}', ref) is not None

def guard(k, v):
    if not gr(k, v):
        raise GrammarError(k)

def zapfail():
    err(L['O92L_ZAPFAIL'])
    sys.exit(1)

def defaults(task):
    return {'task': task, 'stage': 'draft', 'candidate': '-', 'last_proven': '-',
            'waiting': 'none', 'next_step': '-', 'pub_state': 'unknown'}

def cmd_put(k, v):
    m = read_state()
    if m is None:
        m = defaults('-')
    try:
        guard(k, v)
    except GrammarError:
        die_gramm(k)
    if k == 'pub_state' and v == 'published' and not pub_proven(m):
        err(L['O92L_NEDOKAZ_PRE'] + m['candidate'])
        sys.exit(1)
    m[k] = v
    try:
        write_state(m)
    except OSError:
        zapfail()

def cmd_get(k):
    m = read_state()
    if m is None:
        err(L['O92L_NETSOST'])
        sys.exit(1)
    out(m[k])

def cmd_event(kind, subject, ref):
    if kind not in KINDS or not ref_ok(kind, ref):
        err('событие вне грамматики')
        sys.exit(1)
    if triple_exists(kind, subject, ref):
        out(L['O92L_ZAPIS'])
        return
    if kind == 'pub-start':
        for e in read_events():
            if e[1] == 'pub-done' and e[3] == ref:
                err(L['O92L_OPUBL_PRE'] + ref.split('@', 1)[0])
                sys.exit(1)
    if kind == 'pub-done':
        m = read_state()
        if m is not None:
            if subject != m['task'] or ref.split('@', 1)[0] != m['candidate']:
                err(L['O92L_CHUZH_PUBDONE'])
                sys.exit(1)
            m['pub_state'] = 'published'
            composite_write(m, kind, subject, ref)
            return
    try:
        append_event(kind, subject, ref)
    except OSError:
        zapfail()

def cmd_init(task, ref):
    try:
        guard('task', task)
    except GrammarError:
        die_gramm('task')
    if triple_exists('task-init', task, ref):
        out(L['O92L_ZAPIS'])
        return
    m = read_state()
    if m is None:
        m = defaults(task)
    else:
        m['task'] = task
    composite_write(m, 'task-init', task, ref)

def gitenv():
    return {k: v for k, v in os.environ.items()
            if k != 'GIT_DIR' and k != 'GIT_WORK_TREE' and not k.startswith('GIT_CONFIG')}

def git(args):
    return subprocess.run(['git', '-C', REPO] + args, capture_output=True, env=gitenv()).returncode

def published(m):
    cand = m['candidate']
    if cand == '-':
        return False
    return git(['merge-base', '--is-ancestor', cand, 'refs/remotes/origin/main']) == 0

def pub_proven(m):
    for e in read_events():
        if e[1] == 'pub-done' and e[2] == m['task'] \
                and e[3].split('@', 1)[0] == m['candidate']:
            return True
    return published(m)

def slug():
    p = subprocess.run(['git', '-C', REPO, 'remote', 'get-url', 'origin'],
                       capture_output=True, env=gitenv())
    if p.returncode != 0:
        return None
    url = p.stdout.decode('utf-8', 'surrogateescape').strip()
    mm = re.search(r'(?:ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/\s]+?)/(.+?)(?:\.git)?$', url)
    if mm is None:
        return None
    return mm.group(1) + '/' + mm.group(2)

def api_get(path):
    import urllib.request
    req = urllib.request.Request(GH_API + path, headers={'Accept': 'application/vnd.github+json'})
    tok = os.environ.get('GITHUB_TOKEN', '')
    if tok:
        req.add_header('Authorization', 'Bearer ' + tok)
    with urllib.request.urlopen(req, timeout=6) as r:
        return r.read().decode('utf-8', 'surrogateescape')

def remote_probe(m):
    cand = m['candidate']
    if cand == '-':
        return None
    s = slug()
    body = None
    if s is not None:
        try:
            body = api_get('/repos/' + s + '/commits/' + cand + '/check-runs?per_page=100')
        except Exception:
            body = None
    if body is None:
        print(L['O92L_NEIZV'])
        return None
    runs = json.loads(body)
    rrs = runs.get('check_runs') or []
    bad = [r for r in rrs if (r.get('conclusion') or '') != 'success']
    if not bad:
        return 'CI: ' + str(runs.get('total_count', len(rrs))) + ' проверок, все success'
    r0 = bad[0]
    return 'CI: ' + str(r0.get('name', '?')) + ' → ' + str(r0.get('conclusion') or r0.get('status', '?'))

def cmd_status(next_only):
    m = read_state()
    if m is None:
        err(L['O92L_NETSOST'])
        sys.exit(1)
    if next_only:
        sys.stdout.write(m['next_step'] + '\n')
        return
    rem = remote_probe(m)
    for k in KEYS:
        out(k + ': ' + m[k])
    refs = {e[3] for e in read_events() if e[1] == 'round-fail' and e[2] == m['task']}
    out(L['O92L_KRUGOV_PRE'] + str(len(refs)))
    if len(refs) >= 3:
        out(L['O92L_PREDEL'])
    pub = published(m)
    out(L['O92L_OPUBL_DA'] if pub else L['O92L_OPUBL_NET'])
    out(L['O92L_ZAKR'] if m['pub_state'] == 'published' else L['O92L_NEZAKR'])
    if rem is not None:
        out(rem)

def cmd_ciwait(sha_arg, timeout, interval, attempts):
    if sha_arg is None or re.fullmatch(r'[0-9a-f]{40}', sha_arg) is None:
        err('нечем проверить: sha')
        sys.exit(2)
    sha = sha_arg
    s = slug()
    if s is None:
        err('нечем проверить: нет origin')
        sys.exit(2)
    st = read_state()
    task = st['task'] if st is not None else '-'
    try:
        append_event('wait-start', task, sha)
    except OSError:
        pass
    t0 = time.time()
    n = 0
    rc = 3
    msg = 'таймаут ожидания CI'
    path = '/repos/' + s + '/commits/' + sha + '/check-runs?per_page=100'
    while True:
        n += 1
        try:
            body = api_get(path)
        except Exception:
            msg = 'check-runs не получены: сеть'
            rc = 2
            break
        runs = json.loads(body)
        rrs = runs.get('check_runs') or []
        if runs.get('total_count', 0) == 0 and not rrs:
            msg = 'прогонов CI нет'
            break
        bad = [r for r in rrs if (r.get('conclusion') or '') != 'success']
        if not bad:
            rc = 0
            msg = None
            break
        r0 = bad[0]
        if r0.get('status') != 'completed':
            if n >= attempts or (timeout is not None and time.time() - t0 >= timeout):
                rc = 3
                msg = 'CI ещё идёт: таймаут'
                break
            time.sleep(interval)
            continue
        rc = 1
        msg = 'CI КРАСНЫЙ — check-run «' + str(r0.get('name', '?')) + '» → ' + str(r0.get('conclusion', '?'))
        break
    try:
        append_event('wait-done', task, sha)
    except OSError:
        pass
    if msg is not None:
        err(msg)
    sys.exit(rc)

def main():
    a = sys.argv[1:]
    if MODE == 'checkpoint':
        if len(a) == 3 and a[0] == 'put':
            cmd_put(a[1], a[2])
        elif len(a) == 2 and a[0] == 'get':
            cmd_get(a[1])
        elif len(a) == 4 and a[0] == 'event':
            cmd_event(a[1], a[2], a[3])
        elif len(a) == 3 and a[0] == 'init':
            cmd_init(a[1], a[2])
        else:
            err('NOT_IMPLEMENTED: аргументы checkpoint')
            sys.exit(2)
    elif MODE == 'status':
        if not a:
            cmd_status(False)
        elif a == ['--next']:
            cmd_status(True)
        else:
            err('NOT_IMPLEMENTED: аргументы status')
            sys.exit(2)
    elif MODE == 'ciwait':
        sha = None
        timeout = None
        interval = 5.0
        attempts = 30
        i = 0
        while i < len(a):
            if a[i] == '--sha' and i + 1 < len(a):
                sha = a[i + 1]
                i += 2
            elif a[i] == '--timeout' and i + 1 < len(a):
                timeout = float(a[i + 1])
                i += 2
            elif a[i] == '--interval' and i + 1 < len(a):
                interval = float(a[i + 1])
                i += 2
            elif a[i] == '--attempts' and i + 1 < len(a):
                attempts = int(a[i + 1])
                i += 2
            else:
                err('NOT_IMPLEMENTED: аргументы ci_wait')
                sys.exit(2)
        cmd_ciwait(sha, timeout, interval, attempts)
    else:
        err('NOT_IMPLEMENTED: режим')
        sys.exit(2)

main()
O92PY

# ── заплатки стабов: (якорь → замена), якорь ровно один в честном теле ──────────────────
cat > "$O92SCR/gen_stab_092.py" <<'GENPY'
import sys

PATCHES = {
    'S1': (
        "print(L['O92L_NEIZV'])",
        "err('нет сети'); sys.exit(2)",
    ),
    'S2': (
        "print(L['O92L_NEIZV'])",
        "pass",
    ),
    'S3': (
        "out(L['O92L_OPUBL_DA'] if pub else L['O92L_OPUBL_NET'])",
        "out('статус: в работе')",
    ),
    'S4': (
        "sys.stdout.write(m['next_step'] + '\\n')",
        "sys.stdout.write(open(os.path.join(REPO, 'HANDOFF.md'), 'rb').read().splitlines()[-1]"
        ".decode('utf-8', 'surrogateescape') + '\\n')",
    ),
    'S5': (
        "time.sleep(interval)",
        "sys.exit(3)",
    ),
    'S6': (
        "if triple_exists('task-init', task, ref):",
        "if False:",
    ),
    'S7': (
        "if triple_exists(kind, subject, ref):",
        "if False:",
    ),
    'S8': (
        "if e[1] == 'pub-done' and e[3] == ref:",
        "if False:",
    ),
    'S9': (
        "refs = {e[3] for e in read_events() if e[1] == 'round-fail' and e[2] == m['task']}",
        "refs = {e[3].split('@', 1)[0] for e in read_events()"
        " if e[1] == 'round-fail' and e[2] == m['task']}",
    ),
    'S10': (
        "refs = {e[3] for e in read_events() if e[1] == 'round-fail' and e[2] == m['task']}",
        "refs = {e[2] for e in read_events() if e[1] == 'round-fail' and e[2] == m['task']}",
    ),
    'S11': (
        "refs = {e[3] for e in read_events() if e[1] == 'round-fail' and e[2] == m['task']}",
        "refs = set()",
    ),
    'S12': (
        "    tmp = os.path.join(STATE_DIR, '.state.tsv.tmp')\n"
        "    with open(tmp, 'wb') as f:\n"
        "        f.write(data)\n"
        "    os.replace(tmp, STATE)",
        "    with open(STATE, 'wb') as f:\n"
        "        f.write(data)",
    ),
    'S13': (
        "    if not gr(k, v):\n"
        "        raise GrammarError(k)",
        "    if False:\n"
        "        raise GrammarError(k)",
    ),
    'S14': (
        "def write_state(m):\n"
        "    data = state_bytes(m)",
        "def write_state(m):\n"
        "    data = state_bytes(m)\n"
        "    with open(os.path.join(REPO, 'orch-state.tsv'), 'wb') as o92m:\n"
        "        o92m.write(data)",
    ),
    'S15': (
        "            msg = 'check-runs не получены: сеть'\n"
        "            rc = 2",
        "            msg = 'check-runs не получены: сеть'\n"
        "            rc = 3",
    ),
    'S16': (
        "def composite_write(m, kind, subject, ref):\n"
        "    data = state_bytes(m)\n"
        "    line = (time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()) + '\\t' + kind + '\\t'\n"
        "            + subject + '\\t' + ref + '\\n').encode('utf-8')\n"
        "    tmp = os.path.join(STATE_DIR, '.state.tsv.tmp')\n"
        "    try:\n"
        "        with open(tmp, 'wb') as f:\n"
        "            f.write(data)\n"
        "        fh = open(EVENTS, 'ab')\n"
        "    except OSError:\n"
        "        try:\n"
        "            os.unlink(tmp)\n"
        "        except OSError:\n"
        "            pass\n"
        "        zapfail()\n"
        "    fh.write(line)\n"
        "    os.replace(tmp, STATE)\n"
        "    fh.close()",
        "def composite_write(m, kind, subject, ref):\n"
        "    try:\n"
        "        if kind == 'pub-done':\n"
        "            append_event(kind, subject, ref)\n"
        "            write_state(m)\n"
        "        else:\n"
        "            write_state(m)\n"
        "            append_event(kind, subject, ref)\n"
        "    except OSError:\n"
        "        zapfail()",
    ),
    'S17': (
        "    if k == 'pub_state' and v == 'published' and not pub_proven(m):\n"
        "        err(L['O92L_NEDOKAZ_PRE'] + m['candidate'])\n"
        "        sys.exit(1)",
        "    if False:\n"
        "        pass",
    ),
    'S18': (
        "            if subject != m['task'] or ref.split('@', 1)[0] != m['candidate']:\n"
        "                err(L['O92L_CHUZH_PUBDONE'])\n"
        "                sys.exit(1)\n",
        "            if False:\n"
        "                pass\n",
    ),
}

src, name, dst = sys.argv[1], sys.argv[2], sys.argv[3]
old, new = PATCHES[name]
text = open(src, encoding='utf-8').read()
n = text.count(old)
if n != 1:
    sys.stderr.write('якорь %s встречен %d раз\n' % (name, n))
    sys.exit(3)
open(dst, 'w', encoding='utf-8').write(text.replace(old, new, 1))
GENPY

# o92_gen_wrap <mode> <body> <dest> — bash-обёртка: режим + литералы + тело.
o92_gen_wrap() {
  {
    printf '#!/usr/bin/env bash\nset -uo pipefail\n'
    printf 'export O92_MODE=%q\n' "$1"
    printf 'export O92_BODY=%q\n' "$2"
    printf 'export O92L_ZAPIS=%q O92L_NEIZV=%q O92L_OPUBL_PRE=%q O92L_ZAPFAIL=%q\n' \
      "$O92L_ZAPIS" "$O92L_NEIZV" "$O92L_OPUBL_PRE" "$O92L_ZAPFAIL"
    printf 'export O92L_GRAMM_PRE=%q O92L_KRUGOV_PRE=%q O92L_PREDEL=%q O92L_NEDOKAZ_PRE=%q\n' \
      "$O92L_GRAMM_PRE" "$O92L_KRUGOV_PRE" "$O92L_PREDEL" "$O92L_NEDOKAZ_PRE"
    printf 'export O92L_OPUBL_DA=%q O92L_OPUBL_NET=%q O92L_ZAKR=%q O92L_NEZAKR=%q\n' \
      "$O92L_OPUBL_DA" "$O92L_OPUBL_NET" "$O92L_ZAKR" "$O92L_NEZAKR"
    printf 'export O92L_NETSOST=%q O92L_CHUZH_PUBDONE=%q\n' "$O92L_NETSOST" "$O92L_CHUZH_PUBDONE"
    printf 'exec python3 "$O92_BODY" "$@"\n'
  } > "$3"
}

# ── диффпроба: честное тело зелёно на ВСЕХ клетках (17 red + 4 case) ────────────────────
CHEST="$O92SCR/chestnoj"
mkdir -p "$CHEST" || { printf 'NOT_IMPLEMENTED: нет каталога честных обёрток\n' >&2; exit 2; }
for m in checkpoint status ciwait; do
  o92_gen_wrap "$m" "$O92SCR/body_chestnoj.py" "$CHEST/$m.sh"
done
export O92_SUBJ_CHECKPOINT="$CHEST/checkpoint.sh"
export O92_SUBJ_STATUS="$CHEST/status.sh"
export O92_SUBJ_CIWAIT="$CHEST/ciwait.sh"

VSEGO=0
for c in "${O92_RED_CELLS[@]}" "${O92_CASE_CELLS[@]}"; do
  VSEGO=$((VSEGO + 1))
  if [ "${c#case_}" != "$c" ]; then
    cell="$HERE/green/$c"
  else
    cell="$HERE/$c"
  fi
  bash "$cell" "$O92_ROOT" > "$O92SCR/dp_out" 2> "$O92SCR/dp_err"
  if [ $? -ne 0 ]; then
    printf 'NOT_IMPLEMENTED: честный мини-субъект не зелён на %s — клетки противоречивы:\n' "$c" >&2
    cat "$O92SCR/dp_out" "$O92SCR/dp_err" >&2
    exit 2
  fi
done
DIF=$VSEGO
printf 'диффпроба: честный мини-субъект зелён на всех %s клетках семьи (rc=0)\n' "$VSEGO"

# ── стабы: каждый красен на СВОЕЙ клетке (S9 — на обеих названных) ──────────────────────
PAK=('S1 red_net_off_local_survives.sh'
     'S2 red_net_off_local_survives.sh'
     'S3 red_pub_vs_close.sh'
     'S4 red_status_derives_not_echo.sh'
     'S5 red_ciwait_no_repoll.sh'
     'S6 red_restart_no_dup_task.sh'
     'S7 red_restart_no_dup_round.sh'
     'S8 red_restart_no_dup_publish.sh'
     'S9 red_three_fails_three_rounds.sh,red_rounds_count_events_not_files.sh'
     'S10 red_three_fails_three_rounds.sh'
     'S11 red_three_fails_three_rounds.sh'
     'S12 red_checkpoint_atomic_fail.sh'
     'S13 red_checkpoint_grammar.sh'
     'S14 red_state_outside_tree.sh'
     'S15 red_ciwait_net_vs_timeout.sh'
     'S16 red_checkpoint_atomic_fail.sh'
     'S17 red_pub_state_needs_proof.sh'
     'S18 red_pub_done_mismatch_refusal.sh')
POJM=0
for para in "${PAK[@]}"; do
  stab="${para%% *}"
  klets="${para#* }"
  mkdir -p "$O92SCR/stab_$stab" || { printf 'NOT_IMPLEMENTED: нет каталога стаба %s\n' "$stab" >&2; exit 2; }
  python3 "$O92SCR/gen_stab_092.py" "$O92SCR/body_chestnoj.py" "$stab" "$O92SCR/body_$stab.py" || {
    printf 'NOT_IMPLEMENTED: заплатка %s не легла\n' "$stab" >&2; exit 2; }
  for m in checkpoint status ciwait; do
    o92_gen_wrap "$m" "$O92SCR/body_$stab.py" "$O92SCR/stab_$stab/$m.sh"
  done
  export O92_SUBJ_CHECKPOINT="$O92SCR/stab_$stab/checkpoint.sh"
  export O92_SUBJ_STATUS="$O92SCR/stab_$stab/status.sh"
  export O92_SUBJ_CIWAIT="$O92SCR/stab_$stab/ciwait.sh"
  vse_krasnye=1
  IFS=',' read -r -a kletki <<<"$klets"
  for klet in "${kletki[@]}"; do
    bash "$HERE/$klet" "$O92_ROOT" > "$O92SCR/stab_out" 2> "$O92SCR/stab_err"
    rc=$?
    if [ "$rc" -eq 1 ] && grep -q "КРАСНО: ${klet%.sh}" "$O92SCR/stab_out" "$O92SCR/stab_err"; then
      continue
    fi
    vse_krasnye=0
    printf '%s → %s: МИМО (rc=%s) — вывод клетки:\n' "$stab" "$klet" "$rc" >&2
    cat "$O92SCR/stab_out" "$O92SCR/stab_err" >&2
  done
  if [ "$vse_krasnye" -eq 1 ]; then
    POJM=$((POJM + 1))
    printf '%s → %s: поймано\n' "$stab" "$klets"
  fi
done

printf 'стаб-пак 092: %s/18 поймано, диффпроба %s/%s\n' "$POJM" "$DIF" "$VSEGO"
[ "$POJM" -eq 18 ] && [ "$DIF" -eq "$VSEGO" ]
