#!/usr/bin/env bash
# ЛОКАЛЬНЫЙ ПРЕДПОЛЁТ CI проекта — контракт 122 «CI проекта» (Г2), v+1 + дельта-205.
#
#   bash scripts/ci_preflight.sh --repo R [--workflow F] [--job J] [--contract C]
#
# Судит ЛЮБОЙ workflow-файл (и сгенерированный .github/workflows/ci.yml, и рукописный
# mobile.yml): YAML валиден (yaml-nevaliden).
#   (а) сверка объявленности ДО исполнения: при --contract C каждое упоминание
#       secrets.X / vars.X (X ∈ [A-Z][A-Z0-9_]*) во ВСЕМ тексте файла — любое поле
#       (run, env workflow/джобы/шага, with, if), любая джоба, включая station —
#       обязано быть объявлено в поле `ПРЕДПОСЫЛКИ:` контракта, иначе
#       sekrety-ne-perechisleny: X. Это текстовое сверх-приближение: выражения
#       GitHub Actions вне этого алфавита здесь НЕ вычисляются.
#   (б) рабочий каталог каждого run-шага — по старшинству GitHub Actions:
#       working-directory шага > defaults.run.working-directory джобы >
#       defaults.run.working-directory workflow > корень R; каталог ОБЯЗАН лежать
#       в репозитории: путь канонизируется (realpath) и проверяется «под
#       одноразовой копией», иначе working-directory-otsutstvuet — абсолютный путь
#       и `..` не исполняются (иначе шаг исполнился бы в самом R и мутировал его).
#       v+1: побег из копии ЧЕРЕЗ отображённое выражение ${{ github.workspace }}
#       (например `..`-хвост или симлинк наружу) — отдельная причина
#       working-directory-vne-kopii с ИСХОДНЫМ значением поля (до подстановки).
#   (в) ВЫЧИСЛЯЕМЫЙ АЛФАВИТ ВЫРАЖЕНИЙ (v+1, замкнутый): точные формы
#       ${{ secrets.X }} / ${{ vars.X }} — непустые заглушки; точная форма
#       ${{ github.workspace }} — ТОЛЬКО корень внутренней одноразовой копии
#       (working-directory шага и умолчаний workflow/джобы, текст run, значения env
#       цепочки). ВСЯКОЕ иное выражение ${{ … }} на исполнительной поверхности
#       run-шага (working-directory, run, значения env цепочки) — отказ
#       vyrazhenie-ne-podderzhano ДО исполнения шага: не молчаливый успех и не
#       bash-падение. Границы выражения вычисляет СКАНЕР: терминатор `}}` ищется
#       вне кавычек, поэтому скобка `}` внутри строкового аргумента функции
#       (format('}', …)) выражение не рвёт. uses:-шаги не исполняются, их `with:`
#       выражением не судятся; `if:` не вычисляется.
#       ДЕЛЬТА-205: у джоб class station (литерал job.env.PREFLIGHT_CLASS: station)
#       текст run и значения env вычисляемым алфавитом НЕ судятся — локально они
#       не исполняются; класс читается ДО отказа выражений. Сохранены для station:
#       сверка (а) по всему файлу, YAML, разбор working-directory с realpath-границей
#       копии и перечисление STATION-JOB.
# Джобы PREFLIGHT_CLASS: local (умолчание для рукописных) исполняются в одноразовой
# копии R (R не мутируется): каждый run-шаг — `bash -c` В ЭТОМ каталоге с окружением
# env workflow < env джобы < env шага (литералы как есть; выражения вычисляемого
# алфавита подставлены). Джобы station (эмулятор/облако) не исполняются,
# перечисляются строкой `STATION-JOB: <key>`; их секреты сверены по (а). Честный
# конец — `CIPREFLIGHT_OK jobs=<n> station=<m>` rc 0.
#
# Коды возврата: 0 — предполёт зелёный; 1 — именованный отказ из алфавита 122
# (`preflight ОТКАЗ: <причина>[: детали]` на stderr); 2 — ошибка вызова и средовая
# ветвь python-yaml-nedostupen. Отказ с rc 0 — дефект: правило 2 контракта 122
# (PASS только кодом возврата).
set -u

R=""
WF=".github/workflows/ci.yml"
JOB=""
C=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)      R=${2-}; shift ;;
    --workflow)  WF=${2-}; shift ;;
    --job)       JOB=${2-}; shift ;;
    --contract)  C=${2-}; shift ;;
    -h|--help)
      printf 'usage: ci_preflight.sh --repo <R> [--workflow <F>] [--job <J>] [--contract <C>]\n'
      exit 0 ;;
    *) printf 'preflight ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
[ -n "$R" ] || {
  printf 'preflight ОТКАЗ: usage: ci_preflight.sh --repo <R> [--workflow <F>] [--job <J>] [--contract <C>]\n' >&2
  exit 2
}

export PYTHONDONTWRITEBYTECODE=1
exec python3 - "$R" "$WF" "$JOB" "$C" <<'PY'
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT, WF, JOB, CONTRACT = sys.argv[1:5]
STUB_PREFIX = 'PREFLIGHT-STUB-'
# Точная форма выражения — единственное место подстановки; токен вида secrets.X
# встречается в любом поле файла и судится по объявленности.
EXPR_RE = re.compile(r'\$\{\{\s*(secrets|vars)\.([A-Z][A-Z0-9_]*)\s*\}\}')
TOKEN_RE = re.compile(r'\b(secrets|vars)\.([A-Z][A-Z0-9_]*)\b')
DECLARED_RE = re.compile(r'^- (secret|variable) ([A-Z][A-Z0-9_]*)$')
# v+1: точная форма ${{ github.workspace }} — единственное отображение на корень
# внутренней одноразовой копии (не на путь исходного R: шаг исполняется в копии).
WS_RE = re.compile(r'\$\{\{\s*github\.workspace\s*\}\}')
# Корень копии для подстановки workspace; до создания копии подстановки нет.
COPY_ROOT = None


def refuse(reason, detail=None, rc=1):
    sys.stderr.write('preflight ОТКАЗ: %s\n'
                     % (reason if detail is None else '%s: %s' % (reason, detail)))
    sys.exit(rc)


try:
    import yaml
except Exception:
    refuse('python-yaml-nedostupen', rc=2)


def node_dict(value):
    return value if isinstance(value, dict) else {}


def env_of(node):
    """env узла (workflow, джоба, шаг); не отображение — пусто."""
    return node_dict(node.get('env')) if isinstance(node, dict) else {}


def default_workdir(node, inherited):
    """defaults.run.working-directory узла; нет своего — наследуемое (старшинство)."""
    run = node_dict(node_dict(node).get('defaults')).get('run')
    value = node_dict(run).get('working-directory')
    return value if isinstance(value, str) and value else inherited


def first_expression(text):
    """Первое выражение ${{ … }} — СКАНЕРОМ, не regexp [^}]*: терминатор `}}`
    ищется ВНЕ кавычек, поэтому `}` внутри строкового аргумента функции
    (format('}', …)) выражение не рвёт; терминатора нет — выражения нет."""
    begin = text.find('${{')
    if begin < 0:
        return None
    index, quote, length = begin + 3, None, len(text)
    while index < length:
        char = text[index]
        if quote is None and (char == '"' or char == "'"):
            quote = char
        elif quote is not None and quote == char:
            quote = None
        elif quote is None and char == '}' and text.startswith('}}', index):
            return text[begin:index + 2]
        index += 1
    return None


def substitute(text):
    """Вычисляемый алфавит целиком: ${{ github.workspace }} — корень копии,
    ${{ secrets.X }}/${{ vars.X }} — непустые заглушки."""
    if COPY_ROOT is not None:
        text = WS_RE.sub(lambda m: COPY_ROOT, text)
    return EXPR_RE.sub(lambda m: STUB_PREFIX + m.group(2), text)


def refuse_expression(text):
    """Остаточное выражение вне вычисляемого алфавита на исполнительной
    поверхности — именованный отказ ДО исполнения шага (v+1): не молчаливый
    успех (значение ушло шагу литералом) и не bash-падение (bad substitution)."""
    rest = first_expression(substitute(text))
    if rest is not None:
        refuse('vyrazhenie-ne-podderzhano', rest)


def literal(value):
    """Значение env как есть; булево — в записи GitHub Actions."""
    if isinstance(value, bool):
        return 'true' if value else 'false'
    return '' if value is None else str(value)


def step_env(doc, job, step):
    """Окружение шага по старшинству: env workflow < env джобы < env шага."""
    chain = dict(os.environ)
    for node in (doc, job, step):
        for key, value in env_of(node).items():
            chain[str(key)] = substitute(literal(value))
    return chain


def declared_names(path):
    """Поле `ПРЕДПОСЫЛКИ:` контракта (маркер в первой колонке, тело до пустой строки).

    Имя secret/variable — [A-Z][A-Z0-9_]*, ровно алфавит гейта check_predposylki.sh
    и ровно алфавит ссылок TOKEN_RE: одна грамматика в трёх местах, а не две
    (правка поля не должна расходиться между гейтом и предполётом).
    """
    if not path or not os.path.isfile(path):
        sys.stderr.write('preflight ОТКАЗ: контракт не найден: %s\n' % path)
        sys.exit(2)
    names = {'secret': set(), 'variable': set()}
    inside = False
    with open(path, encoding='utf-8') as f:
        for line in f.read().splitlines():
            if line.startswith('ПРЕДПОСЫЛКИ:'):
                inside = True
                continue
            if not inside:
                continue
            if not line.strip():
                break
            match = DECLARED_RE.match(line)
            if match:
                names[match.group(1)].add(match.group(2))
    return names


workflow = os.path.join(ROOT, WF)
if not os.path.isfile(workflow):
    refuse('workflow-otsutstvuet', WF)
try:
    with open(workflow, encoding='utf-8') as f:
        text = f.read()
    doc = yaml.safe_load(text)
except Exception as e:
    refuse('yaml-nevaliden', str(e).replace('\n', ' ')[:200])
jobs = doc.get('jobs') if isinstance(doc, dict) else None
if not isinstance(jobs, dict) or not jobs:
    refuse('yaml-nevaliden', 'нет непустого отображения jobs')

if JOB:
    if JOB not in jobs:
        # Не домен проекта, а ошибка вызова: джобы с таким ключом в файле нет.
        sys.stderr.write('preflight ОТКАЗ: несуществующая джоба: %s\n' % JOB)
        sys.exit(2)
    selected = [JOB]
else:
    selected = list(jobs)

if CONTRACT:
    # (а) сверка объявленности ДО исполнения и до разбора каталогов — по всему
    # тексту файла, любой класс джобы (правило 7: сверх-приближение).
    declared = declared_names(CONTRACT)
    for kind, name in TOKEN_RE.findall(text):
        if name not in declared['secret' if kind == 'secrets' else 'variable']:
            refuse('sekrety-ne-perechisleny', name)

workdir_workflow = default_workdir(doc, '.')
parent = '/tmp/dev-harness-verify' if os.path.isdir('/tmp/dev-harness-verify') else None
scratch = tempfile.mkdtemp(prefix='ci122-preflight-', dir=parent)
copy = os.path.join(scratch, 'repo')
copy_real = os.path.realpath(copy)


def resolve_workdir(step_wd):
    """Каталог шага В одноразовой копии R: realpath + проверка «лежит под копией».

    os.path.join на абсолютном step_wd отбрасывает префикс копии (шаг исполнился бы
    в самом R и мутировал его), а `..` выводил за её корень. Канонизируем и
    спрашиваем: каталог существует и лежит под копией — иначе именованный отказ.
    v+1: побег из копии ЧЕРЕЗ отображённое выражение github.workspace — своя
    причина (working-directory-vne-kopii), буквальный путь наружу — прежняя
    (working-directory-otsutstvuet). Возвращает (каталог, причина).
    """
    resolved = os.path.realpath(os.path.join(copy, substitute(step_wd)))
    inside = resolved == copy_real or resolved.startswith(copy_real + os.sep)
    if not inside:
        if WS_RE.search(step_wd):
            return None, 'working-directory-vne-kopii'
        return None, 'working-directory-otsutstvuet'
    if not os.path.isdir(resolved):
        return None, 'working-directory-otsutstvuet'
    return resolved, None


try:
    # symlinks=True: симлинки переносятся симлинками (как делает checkout на GitHub),
    # и битый симлинк в R не роняет копирование трассировкой shutil.Error.
    shutil.copytree(ROOT, copy, ignore=shutil.ignore_patterns('.git'), symlinks=True)
    COPY_ROOT = copy
    local_count = 0
    station_names = []
    for name in selected:
        job = jobs[name]
        if not isinstance(job, dict):
            refuse('yaml-nevaliden', 'джоба %s — не отображение' % name)
        job_class = literal(env_of(job).get('PREFLIGHT_CLASS', 'local'))
        job_workdir = default_workdir(job, workdir_workflow)
        steps = job.get('steps') or []
        if not isinstance(steps, list):
            refuse('yaml-nevaliden', 'джоба %s: steps — не список' % name)
        runnable = []
        for step in steps:
            if not isinstance(step, dict):
                refuse('yaml-nevaliden', 'джоба %s: шаг — не отображение' % name)
            if 'run' not in step:
                continue          # uses:-шаги локально не исполняются
            if not isinstance(step['run'], str):
                refuse('yaml-nevaliden', 'джоба %s: run — не строка' % name)
            step_wd = step['working-directory'] \
                if isinstance(step.get('working-directory'), str) else job_workdir
            # v+1: исполнительная поверхность шага судится ДО исполнения —
            # остаточное выражение вне вычисляемого алфавита отказывает.
            # working-directory — у ВСЕХ джоб (дельта-205 сохраняет разбор
            # каталога), текст run и значения env цепочки — только у local
            # (станция локально не исполняется; класс прочитан ДО отказа).
            refuse_expression(step_wd)
            if job_class != 'station':
                refuse_expression(step['run'])
                for node in (doc, job, step):
                    for value in env_of(node).values():
                        refuse_expression(literal(value))
            step_dir, reason = resolve_workdir(step_wd)
            if reason is not None:
                # Отказ несёт ИСХОДНОЕ значение поля (до подстановки
                # github.workspace): иначе побег читается как путь копии.
                refuse(reason, step_wd)
            runnable.append((step, step_dir))
        if job_class == 'station':
            station_names.append(name)
            continue
        local_count += 1
        for step, step_dir in runnable:
            proc = subprocess.run(['bash', '-c', substitute(step['run'])],
                                  cwd=step_dir,
                                  env=step_env(doc, job, step),
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            if proc.returncode != 0:
                key = step.get('name') if isinstance(step.get('name'), str) else 'step'
                # Хвост вывода шага — в отказ: именованная причина говорит ГДЕ,
                # а причина падения видна в том, что шаг напечатал (боль 995: CI
                # сначала отвечает «command not found», и это видно здесь).
                tail = proc.stdout.decode('utf-8', 'replace').strip()[-400:]
                tail = ' '.join(tail.split())
                refuse('shag-upal', '%s/%s (rc=%d)%s'
                       % (name, key, proc.returncode, ': ' + tail if tail else ''))
    for name in station_names:
        sys.stdout.write('STATION-JOB: %s\n' % name)
    sys.stdout.write('CIPREFLIGHT_OK jobs=%d station=%d\n'
                     % (local_count, len(station_names)))
finally:
    shutil.rmtree(scratch, ignore_errors=True)
sys.exit(0)
PY
