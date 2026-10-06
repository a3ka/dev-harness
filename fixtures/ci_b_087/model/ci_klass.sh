#!/usr/bin/env bash
# МОДЕЛЬ субъекта scripts/ci_klass.sh (контракт 087) — НЕ субъект. Честная модель
# для режима --model батареи (удовлетворимость клеток, урок А-100) и база обманных
# стабов стаб-пака: стаб = эта модель с ОДНИМ дефектом, включаемым M087_STAB=<имя>
# (имена и привязки к входам — в шапке fixtures/ci_b_087/red_ci_b_087.sh, Н-39).
#
# Подкоманды (cwd = корень репозитория; грамматика — контракт 087 И-1..И-5):
#   hash <rev>          → <64hex> — хеш кодового дерева (учётные пути по U(<rev>))
#   klass <old> <new>   → uchet|kod — сравнение хешей по U(<old>)
#   dokaz <rev>         → «dokaz <40hex>» rc 0 | rc 1 нет доказательства | rc 2 API
#   vorota <old> <new>  → rc 0 учётный/доказан/неприменим | rc 1 код без PR | rc 2 API
#   strip <64hex>       → удаляет учётные пути рабочего дерева, rc 0 | rc 1
#   reshenie            → kod=<H> / tyazh=run|reuse / istochnik=<sha>|-  (GITHUB_OUTPUT)
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
exec python3 - "$@" <<'PY'
import hashlib, json, os, re, subprocess, sys

STAB = os.environ.get('M087_STAB', '')
REG = 'registry/ci-steps.tsv'
ART = 'tyazhelyj-'
PROTECT = ('registry/ci-steps.tsv', 'scripts/ci_klass.sh', '.github/workflows/ci.yml')
SEG = r'[A-Za-z0-9._-]+'
RE_DIR = re.compile(r'^(?:%s/)+$' % SEG)
RE_FILE = re.compile(r'^%s(?:/%s)*$' % (SEG, SEG))
RE_GLOB = re.compile(r'^[A-Z][A-Z0-9_]{3,}\*$')
RE_H = re.compile(r'^[0-9a-f]{64}$')
RE_SHA = re.compile(r'^[0-9a-f]{40}$')


def die(msg, rc=1):
    sys.stderr.write('ОТКАЗ: %s\n' % msg)
    sys.exit(rc)


def git(*args):
    p = subprocess.run(['git'] + list(args), capture_output=True)
    return p.returncode, p.stdout


def resolve(rev):
    rc, out = git('rev-parse', '--verify', '--quiet', rev + '^{commit}')
    if rc != 0 or not out.strip():
        die('коммит не разрешается: %s' % rev)
    return out.decode().strip()


def parse_uchet(sha):
    """U(<sha>): None — реестра нет; [] — строк uchet нет; иначе [(вид, значение)]."""
    rc, raw = git('show', '%s:%s' % (sha, REG))
    if rc != 0:
        return None
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        die('реестр %s на %s не UTF-8' % (REG, sha[:12]))
    lines = text.split('\n')
    if lines and lines[-1] == '':
        lines.pop()
    pats = []
    for n, line in enumerate(lines, 1):
        first = line.split(None, 1)[0] if line.strip() else ''
        if first != 'uchet':
            continue
        f = line.split('\t')
        if len(f) != 2 or f[0] != 'uchet' or f[1] == '':
            die('реестр %s: строка %d вне грамматики uchet: %r' % (REG, n, line))
        v = f[1]
        if RE_GLOB.match(v):
            kind = 'glob'
        elif v.endswith('/') and RE_DIR.match(v):
            kind = 'dir'
        elif RE_FILE.match(v):
            kind = 'file'
        else:
            die('реестр %s: строка %d вне грамматики uchet: %r' % (REG, n, line))
        if any(s in ('.', '..') for s in v.rstrip('/*').split('/')):
            die('реестр %s: строка %d вне грамматики uchet: %r' % (REG, n, line))
        for p in PROTECT:
            if covers((kind, v), p, honest=True):
                die('реестр %s: строка %d: учётный путь %s накрывает машину классификатора %s'
                    % (REG, n, v, p))
        pats.append((kind, v))
    return pats


def covers(pat, path, honest=False):
    kind, v = pat
    if kind == 'dir':
        if STAB == 'prefix-bez-slesha' and not honest:
            return path.startswith(v.rstrip('/'))
        return path.startswith(v)
    if kind == 'file':
        if STAB == 'regex-tochka' and not honest:
            return re.fullmatch(v, path) is not None
        return path == v
    if STAB == 'glob-vglub' and not honest:
        return path.startswith(v[:-1])
    return '/' not in path and path.startswith(v[:-1])


def is_uchet(path, pats):
    return any(covers(p, path) for p in pats)


def need_pats(sha):
    pats = parse_uchet(sha)
    if not pats:
        die('на %s нет строк uchet в %s — классификатор неприменим' % (sha[:12], REG))
    return pats


def kod_hash(sha, pats):
    if STAB == 'tree-hash':
        rc, out = git('rev-parse', sha + '^{tree}')
        return hashlib.sha256(out.strip()).hexdigest()
    rc, raw = git('ls-tree', '-r', '-z', '--full-tree', sha)
    if rc != 0:
        die('дерево не читается: %s' % sha[:12])
    h = hashlib.sha256()
    for ent in raw.split(b'\0'):
        if not ent:
            continue
        meta, path = ent.split(b'\t', 1)
        if is_uchet(path.decode('utf-8', 'surrogateescape'), pats):
            continue
        if STAB == 'bez-rezhima':
            h.update(meta.split(b' ')[2] + b'\t' + path + b'\0')
        else:
            h.update(ent + b'\0')
    return h.hexdigest()


def api_base():
    b = os.environ.get('CI_KLASS_API', '')
    if b:
        return b.rstrip('/')
    gr = os.environ.get('GITHUB_REPOSITORY', '')
    if re.match(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$', gr):
        return '%s/repos/%s' % (os.environ.get('GITHUB_API_URL', 'https://api.github.com').rstrip('/'), gr)
    rc, out = git('remote', 'get-url', 'origin')
    m = re.match(r'^(?:ssh://git@github\.com/|git@github\.com:|https://github\.com/)'
                 r'([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git)?$', out.decode().strip())
    if rc == 0 and m:
        return 'https://api.github.com/repos/%s/%s' % (m.group(1), m.group(2))
    return ''


def dokaz(sha, pats, H):
    """(rc, источник|причина): 0 — найден, 1 — нет, 2 — API не ответил/не разобран."""
    base = api_base()
    if not base:
        return 2, 'репозиторий API не определён (CI_KLASS_API / GITHUB_REPOSITORY / origin github)'
    cmd = ['curl', '-fsS', '-m', '20', '-H', 'Accept: application/vnd.github+json',
           '-H', 'X-GitHub-Api-Version: 2022-11-28']
    if os.environ.get('GITHUB_TOKEN'):
        cmd += ['-H', 'Authorization: Bearer %s' % os.environ['GITHUB_TOKEN']]
    cmd.append('%s/actions/artifacts?name=%s%s&per_page=100' % (base, ART, H))
    p = subprocess.run(cmd, capture_output=True)
    if p.returncode != 0:
        return 2, 'API не ответил (curl rc %d): %s' % (p.returncode, p.stderr.decode('utf-8', 'replace').strip()[:200])
    try:
        arts = json.loads(p.stdout.decode('utf-8'))['artifacts']
        if not isinstance(arts, list):
            raise ValueError
    except Exception:
        return 2, 'ответ API не разобран: %r' % p.stdout[:120]
    if STAB == 'pervyj-tolko':
        arts = arts[:1]
    for a in arts:
        if not isinstance(a, dict):
            continue
        name = a.get('name')
        if STAB == 'imja-prefiks':
            if not (isinstance(name, str) and name.startswith(ART + H)):
                continue
        elif name != ART + H:
            continue
        if STAB != 'istjokshie' and a.get('expired') is not False:
            continue
        wr = a.get('workflow_run') if isinstance(a.get('workflow_run'), dict) else {}
        if STAB != 'fork' and (wr.get('repository_id') is None
                               or wr.get('repository_id') != wr.get('head_repository_id')):
            continue
        hs = wr.get('head_sha')
        if not isinstance(hs, str) or not RE_SHA.match(hs):
            continue
        if git('cat-file', '-e', hs + '^{commit}')[0] != 0:
            continue
        if STAB != 'imja-bez-pereschjota' and kod_hash(hs, pats) != H:
            continue
        return 0, hs
    return 1, 'для кодового хеша %s нет зелёного тяжёлого прогона (артефакт %s%s)' % (H, ART, H)


def c_hash(rev):
    sha = resolve(rev)
    print(kod_hash(sha, need_pats(sha)))


def c_klass(old, new):
    o, n = resolve(old), resolve(new)
    pats = need_pats(o)
    print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')


def c_dokaz(rev):
    sha = resolve(rev)
    pats = need_pats(sha)
    H = kod_hash(sha, pats)
    rc, why = dokaz(sha, pats, H)
    if rc == 0:
        print('dokaz %s' % why)
        return 0
    die(why, rc)


def c_vorota(old, new):
    o, n = resolve(old), resolve(new)
    if STAB == 'vorota-tolko-land':
        rc, subj = git('log', '-1', '--format=%s', n)
        if not subj.decode().startswith('land:'):
            print('прозрачно: не land')
            return 0
    pats_o = parse_uchet(o)
    if not pats_o:
        print('неприменим: на %s нет строк uchet' % o[:12])
        return 0
    if STAB == 'vorota-po-sha':
        same = (o == n)
    elif STAB == 'vorota-vsegda-api':
        rc, why = dokaz(n, need_pats(n), kod_hash(n, need_pats(n)))
        if rc == 2:
            die('код в main: доказательство не проверено: %s' % why, 2)
        same = kod_hash(o, pats_o) == kod_hash(n, pats_o)
    else:
        same = kod_hash(o, pats_o) == kod_hash(n, pats_o)
    if same:
        print('учётный: H=%s' % kod_hash(n, pats_o))
        return 0
    pn = need_pats(n)
    Hn = kod_hash(n, pn)
    rc, why = dokaz(n, pn, Hn)
    if rc == 0:
        print('код доказан: H=%s прогоном %s' % (Hn, why))
        return 0
    if rc == 2:
        die('код в main: доказательство не проверено: %s' % why, 2)
    die('код в main только через PR: %s несёт код, %s' % (n[:12], why), 1)


def c_strip(exp):
    if not RE_H.match(exp):
        die('strip: ожидается кодовый хеш 64 hex, дано %r' % exp)
    head = resolve('HEAD')
    pats = need_pats(head)
    H = kod_hash(head, pats)
    if STAB != 'strip-bez-proverki' and H != exp:
        die('кодовое дерево не совпадает: ожидался %s, HEAD даёт %s' % (exp, H))
    rc, st = git('status', '--porcelain=v1', '-z', '--untracked-files=no')
    if rc != 0 or st:
        die('рабочее дерево не равно HEAD: %r' % st[:160])
    rc, ls = git('ls-files', '-z')
    k = 0
    top = os.getcwd()
    for raw in ls.split(b'\0'):
        if not raw:
            continue
        p = raw.decode('utf-8', 'surrogateescape')
        if not is_uchet(p, pats):
            continue
        fp = os.path.join(top, p)
        if os.path.lexists(fp):
            os.unlink(fp)
            k += 1
        d = os.path.dirname(fp)
        while d != top and os.path.isdir(d) and not os.listdir(d):
            os.rmdir(d)
            d = os.path.dirname(d)
    print('strip: удалено учётных путей %d, кодовое дерево H=%s' % (k, H))


def c_reshenie():
    head = resolve('HEAD')
    pats = need_pats(head)
    H = kod_hash(head, pats)
    rc, why = dokaz(head, pats, H)
    print('kod=%s' % H)
    if rc == 0 or (rc == 2 and STAB == 'reshenie-api-reuse'):
        print('tyazh=reuse')
        print('istochnik=%s' % (why if rc == 0 else '-'))
    else:
        if rc == 2:
            sys.stderr.write('reshenie: доказательство не проверено (%s) — тяжёлый прогон\n' % why)
        print('tyazh=run')
        print('istochnik=-')


CMDS = {'hash': (c_hash, 1), 'klass': (c_klass, 2), 'dokaz': (c_dokaz, 1),
        'vorota': (c_vorota, 2), 'strip': (c_strip, 1), 'reshenie': (c_reshenie, 0)}
a = sys.argv[1:]
if not a or a[0] not in CMDS or len(a) - 1 != CMDS[a[0]][1]:
    die('использование: ci_klass.sh hash <rev> | klass <old> <new> | dokaz <rev> | '
        'vorota <old> <new> | strip <64hex> | reshenie')
sys.exit(CMDS[a[0]][0](*a[1:]) or 0)
PY
