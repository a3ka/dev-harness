#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ локального предполёта CI — контракт 122 «CI проекта» (Г2).
# Субъект-интерфейс: ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C].
# Синтаксис YAML; working-directory обязан существовать; шаги local-джоб исполняются
# в одноразовой копии (секреты/variables — заглушки); station-джобы перечисляются, не исполняются.
# С --contract: каждый использованный secrets.*/vars.* обязан быть объявлен в ПРЕДПОСЫЛКИ: контракта.
set -u
R=; WF=.github/workflows/ci.yml; JOB=; C=
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) R=$2; shift ;;
    --workflow) WF=$2; shift ;;
    --job) JOB=$2; shift ;;
    --contract) C=$2; shift ;;
    *) printf 'preflight ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
if [ -z "$R" ]; then
  printf 'preflight ОТКАЗ: usage: ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C]\n' >&2
  exit 2
fi
export PYTHONDONTWRITEBYTECODE=1
python3 - "$R" "$WF" "$JOB" "$C" <<'PY'
import os, re, shutil, subprocess, sys, tempfile
R, WF, JOB, C = sys.argv[1:5]
try:
    import yaml
except Exception:
    print('preflight ОТКАЗ: python-yaml-nedostupen'); sys.exit(2)
wf = os.path.join(R, WF)
if not os.path.isfile(wf):
    print('preflight ОТКАЗ: workflow-otsutstvuet'); sys.exit(1)
try:
    doc = yaml.safe_load(open(wf))
except Exception:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
jobs = doc.get('jobs') if isinstance(doc, dict) else None
if not isinstance(jobs, dict) or not jobs:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
if JOB:
    if JOB not in jobs:
        print('preflight ОТКАЗ: job-ne-najden: %s' % JOB); sys.exit(1)
    sel = [JOB]
else:
    sel = list(jobs)
declared = {'secret': set(), 'variable': set()}
if C:
    field, f = [], False
    for ln in open(C, encoding='utf-8').read().splitlines():
        if ln.startswith('ПРЕДПОСЫЛКИ:'):
            f = True; continue
        if f:
            if not ln.strip():
                break
            field.append(ln)
    for ln in field:
        mm = re.match(r'^- (secret|variable) ([A-Za-z0-9_]+)$', ln)
        if mm:
            declared[mm.group(1)].add(mm.group(2))
sec_re = re.compile(r'\$\{\{\s*(secrets|vars)\.([A-Z][A-Z0-9_]*)\s*\}\}')
root = '/tmp/dev-harness-verify' if os.path.isdir('/tmp/dev-harness-verify') else None
tmp = tempfile.mkdtemp(prefix='ci122-pre-', dir=root)
work = os.path.join(tmp, 'repo')
shutil.copytree(R, work, ignore=shutil.ignore_patterns('.git'))
try:
    env = dict(os.environ)
    local = station = 0
    station_names = []
    for name in sel:
        j = jobs[name]
        cls = (j.get('env') or {}).get('PREFLIGHT_CLASS', 'local')
        wd = ((j.get('defaults') or {}).get('run') or {}).get('working-directory', '.')
        steps = j.get('steps') or []
        for st in steps:
            if not isinstance(st, dict):
                print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
            d = st.get('working-directory', wd) if isinstance(st.get('working-directory'), str) else wd
            if not os.path.isdir(os.path.join(work, d)):
                print('preflight ОТКАЗ: working-directory-otsutstvuet: %s' % d); sys.exit(1)
        if cls == 'station':
            station += 1
            station_names.append(name)
            continue
        local += 1
        for st in steps:
            if 'run' not in st:
                continue
            run = st['run']
            for kind, nm in sec_re.findall(run):
                env[nm] = 'PREFLIGHT-STUB-' + nm
                want = 'secret' if kind == 'secrets' else 'variable'
                if C and nm not in declared[want]:
                    print('preflight ОТКАЗ: sekrety-ne-perechisleny: %s' % nm); sys.exit(1)
            d = st.get('working-directory', wd) if isinstance(st.get('working-directory'), str) else wd
            r = subprocess.run(['bash', '-c', run], cwd=os.path.join(work, d), env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            if r.returncode != 0:
                key = st.get('name') if isinstance(st.get('name'), str) else 'step'
                print('preflight ОТКАЗ: shag-upal: %s/%s' % (name, key)); sys.exit(1)
    for n in station_names:
        print('STATION-JOB: %s' % n)
    print('CIPREFLIGHT_OK jobs=%d station=%d' % (local, station))
    sys.exit(0)
finally:
    shutil.rmtree(tmp, ignore_errors=True)
PY
