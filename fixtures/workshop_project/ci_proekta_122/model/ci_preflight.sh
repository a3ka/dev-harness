#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ локального предполёта CI — контракт 122 «CI проекта» (Г2).
# Субъект-интерфейс: ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C].
# Синтаксис YAML; рабочий каталог каждого run-шага — по старшинству GitHub Actions:
# working-directory шага > defaults.run.working-directory джобы > defaults.run.working-directory
# workflow > корень; он обязан существовать.
# (а) С --contract C ДО исполнения — сверка объявленности по ВСЕМУ тексту файла (любое поле,
# любой класс джобы, включая station): каждое упоминание токена secrets.X / vars.X обязано быть
# объявлено в ПРЕДПОСЫЛКИ: контракта (текстовое сверх-приближение, правило 7).
# (б) Шаги local-джоб исполняются в одноразовой копии в своём каталоге с окружением
# env workflow < env джобы < env шага (литералы как есть); выражения точной формы
# ${{ secrets.X }} / ${{ vars.X }} в значениях env и в тексте run — непустые заглушки.
# station-джобы перечисляются, не исполняются (их секреты сверены по (а)).
# Строки с маркером мутации вырезают мутанты stabs/ (по одной строке на маркер).
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
    text = open(wf, encoding='utf-8').read()
    doc = yaml.safe_load(text)
except Exception:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
jobs = doc.get('jobs') if isinstance(doc, dict) else None
if not isinstance(jobs, dict) or not jobs:
    print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)

def run_wd(node, inherited):
    # defaults.run.working-directory узла (workflow или джоба); нет своего — наследуемое
    dflt = node.get('defaults') if isinstance(node, dict) else None
    run = dflt.get('run') if isinstance(dflt, dict) else None
    d = run.get('working-directory') if isinstance(run, dict) else None
    return d if isinstance(d, str) else inherited

def env_of(node):
    # env узла (workflow, джоба, шаг); не отображение — пусто
    e = node.get('env') if isinstance(node, dict) else None
    return e if isinstance(e, dict) else {}

sec_re = re.compile(r'\$\{\{\s*(secrets|vars)\.([A-Z][A-Z0-9_]*)\s*\}\}')  # точная форма: подстановка
tok_re = re.compile(r'\b(secrets|vars)\.([A-Z][A-Z0-9_]*)\b')  # токен где угодно: сверка объявленности

def stub(s):
    return sec_re.sub(lambda mm: 'PREFLIGHT-STUB-' + mm.group(2), s)

def lit(v):
    # литерал значения env как есть; булево — в записи GitHub Actions
    if isinstance(v, bool):
        return 'true' if v else 'false'
    return '' if v is None else str(v)

def chain(*nodes):
    # окружение шага по старшинству GitHub Actions: env workflow < env джобы < env шага;
    # значение — литерал как есть, выражения точной формы в нём — заглушки (строка с маркером)
    out = {}
    for node in nodes:
        for k, v in env_of(node).items():
            val = lit(v)
            val = stub(val)  # МУТАЦИЯ-122:zaglushka-v-env
            out[str(k)] = val
    return out

wf_wd = '.'
wf_wd = run_wd(doc, wf_wd)  # МУТАЦИЯ-122:workflow-defaults
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

def local_runs(names):
    # текст run шагов local-джоб — исходная (узкая) область сверки объявленности
    for nm in names:
        j = jobs[nm]
        if isinstance(j, dict) and env_of(j).get('PREFLIGHT_CLASS', 'local') != 'station':
            steps = j.get('steps')
            for st in steps if isinstance(steps, list) else []:
                if isinstance(st, dict) and isinstance(st.get('run'), str):
                    yield st['run']

# (а) сверка объявленности ДО исполнения (и до разбора каталогов): строка с маркером расширяет
# область с текста run шагов local-джоб до всего текста файла (любое поле, любой класс джобы)
scope = '\n'.join(local_runs(sel))
scope = text  # МУТАЦИЯ-122:sverka-po-failu
if C:
    for kind, nm in tok_re.findall(scope):
        if nm not in declared['secret' if kind == 'secrets' else 'variable']:
            print('preflight ОТКАЗ: sekrety-ne-perechisleny: %s' % nm); sys.exit(1)
root = '/tmp/dev-harness-verify' if os.path.isdir('/tmp/dev-harness-verify') else None
tmp = tempfile.mkdtemp(prefix='ci122-pre-', dir=root)
work = os.path.join(tmp, 'repo')
shutil.copytree(R, work, ignore=shutil.ignore_patterns('.git'))
try:
    local = station = 0
    station_names = []
    for name in sel:
        j = jobs[name]
        if not isinstance(j, dict):
            print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
        cls = env_of(j).get('PREFLIGHT_CLASS', 'local')
        wd = run_wd(j, wf_wd)
        steps = j.get('steps') or []
        plan = []
        for st in steps:
            if not isinstance(st, dict):
                print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
            if 'run' not in st:
                continue
            if not isinstance(st['run'], str):
                print('preflight ОТКАЗ: yaml-nevaliden'); sys.exit(1)
            d = st['working-directory'] if isinstance(st.get('working-directory'), str) else wd
            if not os.path.isdir(os.path.join(work, d)):
                print('preflight ОТКАЗ: working-directory-otsutstvuet: %s' % d); sys.exit(1)
            plan.append((st, d))
        if cls == 'station':
            station += 1
            station_names.append(name)
            continue
        local += 1
        # (б) окружение шага — цепочка env, заглушки в env и в run; шаг исполняется с ним
        for st, d in plan:
            step_env = dict(os.environ)
            step_env.update(chain(doc, j, st))  # МУТАЦИЯ-122:env
            run = st['run']
            run = stub(run)  # МУТАЦИЯ-122:podstanovka
            r = subprocess.run(['bash', '-c', run], cwd=os.path.join(work, d), env=step_env,
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
