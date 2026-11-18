#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ локального предполёта CI — контракт 122 «CI проекта» (Г2), v+1 + дельта-205.
# Субъект-интерфейс: ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C].
# Синтаксис YAML; рабочий каталог каждого run-шага — по старшинству GitHub Actions:
# working-directory шага > defaults.run.working-directory джобы > defaults.run.working-directory
# workflow > корень; он обязан существовать В РЕПО: путь судится в одноразовой копии по realpath,
# '..', абсолютный путь и симлинк наружу копии — working-directory-vne-kopii (v+1: побег ЧЕРЕЗ
# выражение github.workspace) либо working-directory-otsutstvuet (буквальный путь; R не мутируется).
# (а) С --contract C ДО исполнения — сверка объявленности по ВСЕМУ тексту файла (любое поле,
#     любой класс джобы, включая station): каждое упоминание токена secrets.X / vars.X обязано быть
#     объявлено в ПРЕДПОСЫЛКИ: контракта (текстовое сверх-приближение, правило 7).
# (б) v+1 ВЫЧИСЛЯЕМЫЙ АЛФАВИТ ВЫРАЖЕНИЙ (замкнутый): точные формы ${{ secrets.X }} / ${{ vars.X }} —
#     непустые заглушки; точная форма ${{ github.workspace }} — ТОЛЬКО корень внутренней
#     одноразовой копии (working-directory шага и умолчаний, текст run, значения env цепочки
#     workflow < джоба < шаг). ВСЯКОЕ иное выражение ${{ … }} на исполнительной поверхности
#     run-шага (working-directory, run, значения env цепочки) — отказ vyrazhenie-ne-podderzhano
#     ДО исполнения шага: не молчаливый успех и не bash-падение. uses:-шаги не исполняются,
#     их with: не судятся; if: не вычисляется (шаги исполняются безусловно).
# (дельта-205) У station-джоб (литерал job.env.PREFLIGHT_CLASS: station) текст run и значения
#     env этим отказом НЕ судятся — локально не исполняются; class читается ДО отказа
#     выражений. uses/if — как выше.
# station-джобы перечисляются, не исполняются (их секреты сверены по (а); их working-directory
#     разбирается теми же правилами — дельта-205 сохранена). Строки с маркером мутации
#     вырезают мутанты stabs/ (по одной строке на маркер; ровно один маркер каждого вида).
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
ws_re = re.compile(r'\$\{\{\s*github\.workspace\s*\}\}')  # v+1: точная форма, корень копии
def pervoe_vyrazhenie(s):
    # v+1 (К-09, Crit122V5): первое выражение ${{ … }} — СКАНЕРОМ, не regexp [^}]*:
    # скобка } внутри строкового аргумента функции (format('}', …)) не рвёт поиск,
    # терминатор }} — только ВНЕ кавычек ('…'/"…"); нет терминатора — нет выражения
    b = s.find('${{')
    if b < 0:
        return None
    j, q, n = b + 3, None, len(s)
    while j < n:
        ch = s[j]
        if q is None and (ch == '"' or ch == "'"):
            q = ch
        else:
            novyj = q  # по умолчанию состояние кавычки не меняется
            novyj = None if q == ch else q  # МУТАЦИЯ-122:kavychki-vyrazhenija — закрытие кавычки тем же символом
            q = novyj
        if q is None and ch == '}' and s.startswith('}}', j):
            return s[b:j + 2]
        j += 1
    return None

work = None  # корень одноразовой копии (заполняется до первого использования)

def ws(s):
    # v+1: github.workspace отображается ТОЛЬКО на корень внутренней копии
    if work is None or not ws_re.search(s):
        return s
    s = ws_re.sub(lambda mm: work, s)  # МУТАЦИЯ-122:workspace-podstanovka
    return s

def podstanovka(s):
    # вычисляемый алфавит целиком: workspace + заглушки secrets/vars
    return sec_re.sub(lambda mm: 'PREFLIGHT-STUB-' + mm.group(2), ws(s))

def otkaz_vyrazhenija(s):
    # v+1: остаточное выражение (вне алфавита) на исполнительной поверхности — именованный
    # отказ ДО исполнения шага; не молчаливый успех и не bash-падение
    ost = pervoe_vyrazhenie(podstanovka(s))
    if ost is None:
        return
    print('preflight ОТКАЗ: vyrazhenie-ne-podderzhano: %s' % ost); sys.exit(1)  # МУТАЦИЯ-122:otkaz-vyrazhenij

def stub(s):
    return podstanovka(s)

def lit(v):
    # литерал значения env как есть; булево — в записи GitHub Actions
    if isinstance(v, bool):
        return 'true' if v else 'false'
    return '' if v is None else str(v)

def chain(*nodes):
    # окружение шага по старшинству GitHub Actions: env workflow < env джобы < env шага;
    # значение — литерал как есть, выражения вычисляемого алфавита в нём — подставлены
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

def polya(node, iskl):
    # строки документа (ключи и значения), кроме поддеревьев полей iskl, — сверка обходом полей
    if isinstance(node, dict):
        for k, v in node.items():
            if k in iskl:
                continue
            yield str(k)
            yield from polya(v, iskl)
    elif isinstance(node, list):
        for v in node:
            yield from polya(v, iskl)
    elif node is not None:
        yield str(node)

# (а) сверка объявленности ДО исполнения (и до разбора каталогов): строка с маркером расширяет
# область с текста run шагов local-джоб до всего текста файла (любое поле, любой класс джобы);
# две строки с маркерами возвращают в область поля if и with (без любой из них сверка идёт
# обходом полей документа, минуя вырезанное поле)
iskl = {'if', 'with'}
iskl.discard('if')  # МУТАЦИЯ-122:sverka-if
iskl.discard('with')  # МУТАЦИЯ-122:sverka-with
scope = '\n'.join(local_runs(sel))
scope = text  # МУТАЦИЯ-122:sverka-po-failu
if iskl:
    scope = '\n'.join(polya(doc, iskl))
if C:
    for kind, nm in tok_re.findall(scope):
        if nm not in declared['secret' if kind == 'secrets' else 'variable']:
            print('preflight ОТКАЗ: sekrety-ne-perechisleny: %s' % nm); sys.exit(1)
# дельта-205 (слово владельца 2026-11-18 ~18:58 UTC, через консультанта 205): у джоб class
# station (литерал job.env.PREFLIGHT_CLASS, принятая классификация 122) текст run и значения
# env локально НЕ исполняются — отказ (г) на них не направлен; class читается ДО отказа
# выражений. Сохранены: сверка (а) по всему файлу, YAML, разбор working-directory
# с realpath-границей копии, перечисление STATION-JOB, все отказы local.
ne_suditsya_run_env = set()
ne_suditsya_run_env.add('station')  # МУТАЦИЯ-122:stantsiya-propusk
root = '/tmp/dev-harness-verify' if os.path.isdir('/tmp/dev-harness-verify') else None
tmp = tempfile.mkdtemp(prefix='ci122-pre-', dir=root)
work = os.path.join(tmp, 'repo')
shutil.copytree(R, work, ignore=shutil.ignore_patterns('.git'), symlinks=True)
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
            # v+1 (б): исполнительная поверхность шага судится ДО исполнения: остаточное
            # выражение вне вычисляемого алфавита — отказ; working-directory — у ВСЕХ джоб
            # (дельта-205 сохранена), текст run и значения env цепочки — только у local
            # (дельта-205: station локально не исполняется)
            otkaz_vyrazhenija(d)
            if cls not in ne_suditsya_run_env:
                otkaz_vyrazhenija(st['run'])
                for node in (doc, j, st):
                    for k, v in env_of(node).items():
                        otkaz_vyrazhenija(lit(v))
            cherez_ws = bool(ws_re.search(d))
            d0 = d  # v+1 (К-10, Crit122V5): ИСХОДНОЕ значение поля — своё либо унаследованное
            # с любого уровня (шаг/джоба/workflow) — ДО подстановки; отказ о побеге несёт его
            d = ws(d)
            # судится от копии, а не от исходного R, и судится вообще; побег ЧЕРЕЗ отображённое
            # выражение github.workspace (..-хвост, симлинк, иной абсолютный результат) —
            # vne-kopii с литералом ИСХОДНОГО поля, буквальный путь — прежние правила (otsutstvuet)
            kor = R
            kor = work  # МУТАЦИЯ-122:wd-ot-kopii
            p, k = os.path.realpath(os.path.join(kor, d)), os.path.realpath(kor)
            vnutri = True
            vnutri = p == k or p.startswith(k + os.sep)  # МУТАЦИЯ-122:wd-v-kopii
            if not vnutri and cherez_ws: print('preflight ОТКАЗ: working-directory-vne-kopii: %s' % d0); sys.exit(1)  # МУТАЦИЯ-122:granica-workspace
            if not vnutri or not os.path.isdir(os.path.join(work, d)):
                print('preflight ОТКАЗ: working-directory-otsutstvuet: %s' % d); sys.exit(1)
            plan.append((st, d))
        if cls == 'station':
            station += 1
            station_names.append(name)
            continue
        local += 1
        # (б) окружение шага — цепочка env, подстановки в env и в run; шаг исполняется с ним
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
