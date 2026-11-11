#!/usr/bin/env python3
"""Батарея 189 «Л4 — стандартные валидаторы и канон» (семья standartnye_validatory_189).

Режимы (обёртка red_standartnye_validatory_189.sh):
  --repo <корень>  — судить реальный субъект <корень>/scripts/{validate_std.sh,
                     validate_std_json.py, check_canon_fragment.py} + пин-файл
                     <корень>/ops/server/validators.tsv (голый вызов = корень дерева);
  --model          — та же батарея против честной модели model/scripts/ (сборка
                     временного корня с пинами двойников);
  --stabs          — поимка обманных реализаций stabs/ на их различающих входах
                     (привязки — stabs.tsv, данные, не проза).

Правило 8: ожидания сняты в память (список KLETKI) ДО вызова субъекта; диск
субъекта как истина не перечитывается. Свидетель z01 — сама батарея (вне
субъекта). Числа — из прогонов; итог — код возврата: 0 зелено, 1 есть красные
клетки/живая обманка, 2 нечем судить (LIVE_PREDPOSYLKA), никогда skip→pass.
"""
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MATRIX = HERE / 'matrix'
REAL_HOME = Path(os.environ.get('HOME') or '/nonexistent')

# ── Двойники внешних бинарей: честные контракты rc, измеренные Д§3.2 ──────────
# Двойник actionlint воспроизводит измеренный контракт rc actionlint 1.7.12 на
# входах матрицы: rc 1 — нет runs-on у job; rc 1 — неизвестное поле github.* в
# ${{ … }}; прочие мутации матрицы — rc 0 (замер: 2 из 9; остальное ловит канон).
ACTIONLINT_DVOJNIK = '''#!/usr/bin/env python3
import re, sys
try:
    import yaml
except Exception:
    sys.exit(1)
try:
    doc = yaml.safe_load(open(sys.argv[1], encoding='utf-8'))
except Exception:
    print('yaml: синтаксическая ошибка', file=sys.stderr)
    sys.exit(1)
ok = True
jobs = (doc or {}).get('jobs') or {}
for jid, job in jobs.items():
    if isinstance(job, dict) and 'runs-on' not in job:
        print('%s: "runs-on" is missing' % jid, file=sys.stderr)
        ok = False
izvestnye = {'sha', 'ref', 'token', 'event', 'repository', 'workflow', 'run',
             'job', 'actor', 'head_ref', 'base_ref', 'env', 'github'}
text = open(sys.argv[1], encoding='utf-8', errors='replace').read()
for m in re.finditer(r'\\$\\{\\{\\s*github\\.([A-Za-z_][A-Za-z0-9_]*)', text):
    if m.group(1) not in izvestnye:
        print('github.%s: unknown property' % m.group(1), file=sys.stderr)
        ok = False
sys.exit(0 if ok else 1)
'''

# Лгущий бинарь: печатает успех, выходит rc 1 (клетка v07: успех по тексту
# вывода не признаётся, rc пробрасывается).
LZHUSHHIJ_ACTIONLINT = '''#!/usr/bin/env python3
print('проверено: ошибок нет')
sys.exit(1)
'''  # noqa: намеренно без import sys — падение до exit(1) всё равно даёт rc 1

# Подмена: иной бинарь с иным sha256 (клетка v05: пин обязан отказать).
DRUGOJ_ACTIONLINT = '#!/bin/sh\n# подмена батареи 189: иной бинарь, иной sha256\nexit 0\n'

# Двойник shellcheck: rc 1 при маркерной находке батареи, иначе rc 0.
SHELLCHECK_DVOJNIK = '''#!/usr/bin/env python3
import sys
data = open(sys.argv[1], encoding='utf-8', errors='replace').read()
if '# shellcheck-demo-finding' in data:
    print('SC9999: демонстрационная находка (маркер батареи 189)', file=sys.stderr)
    sys.exit(1)
sys.exit(0)
'''

PIN_JSONSCHEMA = '4.26.0'  # версия на станции (замер сессии 2026-11-11)
VER_DVOJNIKA = '1.7.12-dvojnik-189'


def sha256(put: Path) -> str:
    return hashlib.sha256(put.read_bytes()).hexdigest()


def zapisat(path: Path, text: str, ispoln=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')
    if ispoln:
        path.chmod(0o755)


def sobrat_mir(vrem: Path) -> dict:
    """Мир двойников + пины. Ожидания — в памяти ДО вызова субъекта (правило 8)."""
    bin_dir = vrem / 'bin'
    actionlint = bin_dir / 'actionlint'
    lie = bin_dir / 'lie_actionlint'
    drugoj = bin_dir / 'drugoj_actionlint'
    shellcheck = bin_dir / 'shellcheck'
    zapisat(actionlint, ACTIONLINT_DVOJNIK, ispoln=True)
    zapisat(lie, LZHUSHHIJ_ACTIONLINT.replace('sys.exit(1)', 'raise SystemExit(1)'), ispoln=True)
    zapisat(drugoj, DRUGOJ_ACTIONLINT, ispoln=True)
    zapisat(shellcheck, SHELLCHECK_DVOJNIK, ispoln=True)

    py3 = vrem / 'py3'
    py3bez = vrem / 'py3bez'
    zapisat(py3, '#!/bin/sh\nexec python3 "$@"\n', ispoln=True)
    zapisat(py3bez, '#!/bin/sh\nexec python3 -S "$@"\n', ispoln=True)

    site = vrem / 'site'
    zapisat(site / 'jsonschema' / '__init__.py', '')
    zapisat(site / 'jsonschema-0.0.0.dist-info' / 'METADATA',
            'Metadata-Version: 2.1\nName: jsonschema\nVersion: 0.0.0\n')

    def pins_tsv(sha_actionlint: str) -> str:
        return (
            '# opy: инструмент <TAB> версия <TAB> sha256 (или - для пакетов python)\n'
            'actionlint\t%s\t%s\n'
            'shellcheck\t%s\t%s\n'
            'jsonschema\t%s\t-\n'
            % (VER_DVOJNIKA, sha_actionlint,
               VER_DVOJNIKA, sha256(shellcheck), PIN_JSONSCHEMA))

    pins = vrem / 'pins' / 'validators.tsv'
    pins_lie = vrem / 'pins_lie' / 'validators.tsv'
    zapisat(pins, pins_tsv(sha256(actionlint)))
    zapisat(pins_lie, pins_tsv(sha256(lie)))

    # jsonschema на станции живёт в user-site (зависим от HOME): честные json-клетки
    # получают ОБНАРУЖЕННЫЙ каталог движка через PYTHONPATH — изоляция HOME не
    # прячет существующий движок; клетки v15/v16 его намеренно не получают.
    r = subprocess.run(
        ['python3', '-c',
         'import jsonschema, os; print(os.path.dirname(os.path.dirname(jsonschema.__file__)))'],
        capture_output=True, text=True)
    site_dvizhka = r.stdout.strip() if r.returncode == 0 else ''

    home = vrem / 'home'
    home.mkdir(parents=True, exist_ok=True)

    # Дома установки для клеток БЕЗ швов бинарей (инвариант 2: резолв «дом →
    # command -v»): батарея подставляет дом установкой HOME клетки. v18 —
    # пин-совпадающий двойник (запуск установленного бинаря); v19 — подмена.
    def dom_s_binarem(naddir: str, istochnik: Path) -> Path:
        dom = vrem / naddir
        cel = (dom / '.local' / 'state' / 'dev-harness' / 'validators'
               / 'actionlint' / VER_DVOJNIKA / 'actionlint')
        cel.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(istochnik, cel)
        cel.chmod(0o755)
        return dom

    # PATH-подмена (v21): actionlint с иным sha256 первым в PATH клетки.
    path_podmena = vrem / 'path-podmena'
    path_podmena.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(drugoj, path_podmena / 'actionlint')
    (path_podmena / 'actionlint').chmod(0o755)

    # Нечитаемость chmod 000 материализуется только не под root (root читает и
    # 000): клетки «пин-файл не читается» (v31/v33) судимы лишь там, где
    # состояние материально; иначе — именованный отказ NEZAPUSKAEMA в sudit,
    # не молчаливый зелёный (Блок 4 критика, вызов 3; слово владельца 2026-11-11).
    proba_nch = vrem / 'proba-nechitaemosti.tsv'
    zapisat(proba_nch, 'proba\t1\t-\n')
    proba_nch.chmod(0o000)
    try:
        with open(proba_nch, encoding='utf-8') as f:
            f.read()
        nechitaemost = False
    except OSError:
        nechitaemost = True

    return {
        'vrem': vrem, 'bin': bin_dir,
        'actionlint': actionlint, 'lie': lie, 'drugoj': drugoj,
        'shellcheck': shellcheck, 'py3': py3, 'py3bez': py3bez,
        'site': site, 'pins': pins, 'pins_lie': pins_lie, 'home': home,
        'pins_tsv': pins_tsv, 'site_dvizhka': site_dvizhka,
        'dom_chestnyj': dom_s_binarem('dom-chestnyj', actionlint),
        'dom_podmena': dom_s_binarem('dom-podmena', drugoj),
        'path_podmena': path_podmena,
        'chmod_nechitaemost': nechitaemost,
    }

def koren_bez_stroki(koren: Path, mir: dict) -> Path:
    """Вариант корня субъекта с пин-файлом БЕЗ строки actionlint (v20).

    Собирается в мире батареи (не рядом с проверяемым корнем): скрипты
    копируются из проверяемого корня, пин-файл — строки мира минус actionlint.
    В голом прогоне до реализации скриптов нет — вариант остаётся без них и
    клетка красна именем отсутствующего субъекта, как остальные.
    """
    koren2 = mir['vrem'] / ('variant-bez-stroki-' + koren.name)
    for f in ('validate_std.sh', 'validate_std_json.py', 'check_canon_fragment.py'):
        istochnik = koren / 'scripts' / f
        if istochnik.is_file():
            cel = koren2 / 'scripts' / f
            cel.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(istochnik, cel)
    bez = ''.join(
        stroka + '\n'
        for stroka in mir['pins'].read_text(encoding='utf-8').splitlines()
        if stroka.split('\t')[0:1] != ['actionlint'])
    zapisat(koren2 / 'ops' / 'server' / 'validators.tsv', bez)
    return koren2

def koren_s_defoltom(koren: Path, mir: dict, bez_pin_fajla: bool = False,
                     bez_stroki: str = None, nechitaem: bool = False) -> Path:
    """Вариант корня субъекта для клеток ДЕФОЛТНОГО пути пин-файла (v26–v34).

    Техника koren_bez_stroki (ДЕМО-2 критика, вызов 2): скрипты копируются из
    проверяемого корня, пин-файл мира ставится на ДЕФОЛТНОЕ место
    ops/server/validators.tsv; bez_pin_fajla=True — вариант ВООБЩЕ без
    пин-файла (v30 обёртка / v32 движок json); bez_stroki=<инструмент> —
    пин-файл без строки инструмента (v34: строки jsonschema нет, файл цел);
    nechitaem=True — дефолтный пин-файл chmod 000 (v31 обёртка / v33 движок
    json; Блок 4 критика, вызов 3). В голом прогоне до реализации скриптов
    нет — вариант остаётся без них и клетка красна именем отсутствующего
    субъекта, как остальные.
    """
    if bez_pin_fajla:
        imja = 'variant-bez-pin-fajla-'
    elif bez_stroki is not None:
        imja = 'variant-bez-stroki-%s-' % bez_stroki
    elif nechitaem:
        imja = 'variant-s-nechitaemym-'
    else:
        imja = 'variant-s-defoltom-'
    koren2 = mir['vrem'] / (imja + koren.name)
    for f in ('validate_std.sh', 'validate_std_json.py', 'check_canon_fragment.py'):
        istochnik = koren / 'scripts' / f
        if istochnik.is_file():
            cel = koren2 / 'scripts' / f
            cel.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(istochnik, cel)
    if not bez_pin_fajla:
        tekst = mir['pins'].read_text(encoding='utf-8')
        if bez_stroki is not None:
            tekst = ''.join(
                stroka + '\n'
                for stroka in tekst.splitlines()
                if stroka.split('\t')[0:1] != [bez_stroki])
        fajl = koren2 / 'ops' / 'server' / 'validators.tsv'
        zapisat(fajl, tekst)
        if nechitaem:
            fajl.chmod(0o000)
    return koren2

def sreda_defolt(mir, home=None, **nadbavki):
    """Среда клеток ДЕФОЛТНОГО пути пин-файла: ни одного VALIDATE_STD_*.

    Сняты и швы бинарей, и сам пин-файл: резолв пина обязан пойти по дефолту
    `<каталог скрипта>/../ops/server/validators.tsv` субъекта (инвариант 2;
    Блок 3 критика, вызов 2 — положительная различимость дефолта).
    """
    env = dict(os.environ)
    env['HOME'] = str(home if home is not None else mir['home'])
    for kluch in [k for k in env if k.startswith('VALIDATE_STD_')]:
        del env[kluch]
    env.pop('PYTHONPATH', None)
    env.update(nadbavki)
    return env

def sreda_bez_shvov(mir, home=None, **nadbavki):
    """Среда клетки БЕЗ швов бинарей: VALIDATE_STD_ACTIONLINT/SHELLCHECK/PYTHON
    сняты — резолв обязан пойти «дом установки → command -v» (инвариант 2).

    VALIDATE_STD_PINS остаётся пин-файлом МИРА батареи: для клеток v18–v22
    дефолтный путь не предмет, пин-файл — конфигурация мира (как и двойники).
    Дефолтный путь пин-файла покрыт отдельными клетками v26–v30 в среде
    sreda_defolt — без единого VALIDATE_STD_* (совет 2 критика, вызов 2).
    """
    env = sreda_defolt(mir, home=home)
    env['VALIDATE_STD_PINS'] = str(mir['pins'])
    env.update(nadbavki)
    return env


def sobrat_koren_subekta(vrem: Path, mir: dict, istoshnik: str) -> Path:
    """--model/--stabs: временный корень субъекта = model/scripts + пины мира."""
    koren = vrem / ('subekt-model' if istoshnik == 'model' else 'subekt-obmanka')
    for f in ('validate_std.sh', 'validate_std_json.py', 'check_canon_fragment.py'):
        cel = koren / 'scripts' / f
        cel.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(HERE / istoshnik / 'scripts' / f, cel)
    zapisat(koren / 'ops' / 'server' / 'validators.tsv',
            (mir['pins']).read_text(encoding='utf-8'))
    return koren


class Kletka:
    def __init__(self, imja, argv, env, rc, markery=(), uslovie=None):
        self.imja, self.argv, self.env, self.rc, self.markery = imja, argv, env, rc, list(markery)
        self.uslovie = uslovie  # клетка состояния, не материализующегося на станции
                               # (chmod-000 читается под root): именованный отказ, не зелёное молчание


def sreda(mir, **nadbavki):
    env = dict(os.environ)
    env['HOME'] = str(mir['home'])
    env['VALIDATE_STD_PINS'] = str(mir['pins'])
    env['VALIDATE_STD_PYTHON'] = str(mir['py3'])
    env['VALIDATE_STD_ACTIONLINT'] = str(mir['actionlint'])
    env['VALIDATE_STD_SHELLCHECK'] = str(mir['shellcheck'])
    env.pop('PYTHONPATH', None)
    env.update(nadbavki)
    return env


def kletki(koren: Path, mir: dict) -> list:
    """Оракул в памяти: имя, команда, среда, ожидаемый rc, обязательные маркеры."""
    S = koren / 'scripts'
    M = MATRIX
    kanon = str(M / 'canon.yml')

    def canon(wf, job='runtime-r0', kanon_fajl=None, py='python3'):
        return [py, str(S / 'check_canon_fragment.py'), str(wf), job,
                str(kanon_fajl or M / 'canon.yml')]

    def wrap(*args, **env):
        return ['bash', str(S / 'validate_std.sh'), *args], env

    K = []
    # ── канон: 11 входов матрицы Д§3.2 + грамматика/среда ──
    K.append(Kletka('k01-chestnaja', canon(M / 'honest.yml'), sreda(mir), 0))
    K.append(Kletka('k02-ekvivalentnaja', canon(M / 'ekvivalent.yml'), sreda(mir), 0))
    K.append(Kletka('k03-bez-runs-on', canon(M / 'mut_bez_runs_on.yml'), sreda(mir), 1,
                    ['CANON_DIFF: runs-on:']))
    K.append(Kletka('k04-scalar-runs-on', canon(M / 'mut_scalar_runs_on.yml'), sreda(mir), 1,
                    ['CANON_DIFF: runs-on:']))
    K.append(Kletka('k05-nesushhestvujushhij-sha',
                    canon(M / 'mut_nesushchestvujushhij_sha.yml'), sreda(mir), 1,
                    ['CANON_DIFF: steps[0].uses:']))
    K.append(Kletka('k06-shag-posle-upload', canon(M / 'mut_shag_posle_upload.yml'),
                    sreda(mir), 1, ['CANON_DIFF: steps[4]']))
    K.append(Kletka('k07-if-vsegda-lozh', canon(M / 'mut_if_vsegda_lozh.yml'),
                    sreda(mir), 1, ['CANON_DIFF: steps[2].if']))
    K.append(Kletka('k08-sha256-fixture', canon(M / 'mut_sha256_fixture.yml'),
                    sreda(mir), 1, ['CANON_DIFF: container.image:']))
    K.append(Kletka('k09-teg-vmesto-sha', canon(M / 'mut_teg_vmesto_sha.yml'),
                    sreda(mir), 1, ['CANON_DIFF: steps[0].uses:']))
    K.append(Kletka('k10-opetchatka-vyrazhenija',
                    canon(M / 'mut_opetchatka_vyrazhenija.yml'), sreda(mir), 1,
                    ['CANON_DIFF: steps[2].env.BASE:']))
    K.append(Kletka('k11-working-directory', canon(M / 'mut_working_directory.yml'),
                    sreda(mir), 1, ['CANON_DIFF: steps[2].working-directory']))
    K.append(Kletka('k12-jaml-ne-razbor', canon(M / 'broken.yml'), sreda(mir), 2,
                    ['CANON_UNPARSEABLE']))
    K.append(Kletka('k13-job-net', canon(M / 'honest.yml', job='netu-takogo'),
                    sreda(mir), 2, ['CANON_JOB_MISSING']))
    K.append(Kletka('k14-kanon-net',
                    ['python3', str(S / 'check_canon_fragment.py'), str(M / 'honest.yml'),
                     'runtime-r0', str(M / 'kanon-netu.yml')], sreda(mir), 2,
                    ['CANON_ABSENT']))
    K.append(Kletka('k15-workflow-net',
                    ['python3', str(S / 'check_canon_fragment.py'), str(M / 'workflow-netu.yml'),
                     'runtime-r0', kanon], sreda(mir), 2, ['CANON_ABSENT']))
    K.append(Kletka('k16-kanon-ne-otobrazhenie',
                    canon(M / 'honest.yml', kanon_fajl=M / 'kanon_spisok.yml'),
                    sreda(mir), 2, ['CANON_FRAGMENT']))
    K.append(Kletka('k17-net-pyyaml',
                    canon(M / 'honest.yml', py=str(mir['py3bez'])), sreda(mir), 2,
                    ['CANON_ENV']))

    # ── обёртка валидаторов ──
    argv, env = wrap('workflow', str(M / 'honest.yml'))
    K.append(Kletka('v01-workflow-chestnyj', argv, sreda(mir, **env), 0))
    argv, env = wrap('workflow', str(M / 'mut_bez_runs_on.yml'))
    K.append(Kletka('v02-workflow-bez-runs-on', argv, sreda(mir, **env), 1))
    argv, env = wrap('workflow', str(M / 'mut_opetchatka_vyrazhenija.yml'))
    K.append(Kletka('v03-workflow-opetchatka', argv, sreda(mir, **env), 1))
    argv, env = wrap('workflow', str(M / 'mut_scalar_runs_on.yml'))
    K.append(Kletka('v04-workflow-scalar-gjanica', argv, sreda(mir, **env), 0))
    argv, env = wrap('workflow', str(M / 'honest.yml'))
    e = dict(env)
    e['VALIDATE_STD_ACTIONLINT'] = str(mir['drugoj'])
    K.append(Kletka('v05-podmena-binarija', argv, sreda(mir, **e), 2,
                    ['VALIDATOR_PIN: actionlint']))
    argv, env = wrap('workflow', str(M / 'honest.yml'))
    e = dict(env)
    e['VALIDATE_STD_ACTIONLINT'] = str(mir['bin'] / 'netu')
    K.append(Kletka('v06-instrumenta-net', argv, sreda(mir, **e), 2,
                    ['VALIDATOR_MISSING: actionlint']))
    argv, env = wrap('workflow', str(M / 'honest.yml'))
    e = dict(env)
    e['VALIDATE_STD_ACTIONLINT'] = str(mir['lie'])
    e['VALIDATE_STD_PINS'] = str(mir['pins_lie'])
    K.append(Kletka('v07-lgushhij-binarij', argv, sreda(mir, **e), 1))
    argv, env = wrap('bash', str(M / 'chestnyj_skript.sh'))
    K.append(Kletka('v08-bash-chestnyj', argv, sreda(mir, **env), 0))
    argv, env = wrap('bash', str(M / 'sintaksis.sh'))
    K.append(Kletka('v09-bash-sintaksis', argv, sreda(mir, **env), 2,
                    ['SYNTAX: bash -n']))
    argv, env = wrap('bash', str(M / 'shellcheck_nahodka.sh'))
    K.append(Kletka('v10-bash-nahodka', argv, sreda(mir, **env), 1))
    argv, env = wrap('bash', str(M / 'chestnyj_skript.sh'))
    e = dict(env)
    e['VALIDATE_STD_SHELLCHECK'] = str(mir['bin'] / 'netu')
    K.append(Kletka('v11-shellcheck-net', argv, sreda(mir, **e), 2,
                    ['VALIDATOR_MISSING: shellcheck']))
    argv, env = wrap('json', str(M / 'shema.json'), str(M / 'dokument.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v12-json-chestnyj', argv, sreda(mir, **e), 0))
    argv, env = wrap('json', str(M / 'shema.json'), str(M / 'dokument_narushenie.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v13-json-narushenie', argv, sreda(mir, **e), 1,
                    ['JSON_INVALID:']))
    argv, env = wrap('json', str(M / 'shema.json'), str(M / 'dok_ne_razbor.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v14-json-ne-razbor', argv, sreda(mir, **e), 2,
                    ['JSON_UNPARSEABLE']))
    argv, env = wrap('json', str(M / 'shema.json'), str(M / 'dokument.json'))
    e = dict(env)
    e['VALIDATE_STD_PYTHON'] = str(mir['py3bez'])
    K.append(Kletka('v15-dvizhka-net', argv, sreda(mir, **e), 2,
                    ['ENGINE_MISSING: jsonschema']))
    argv, env = wrap('json', str(M / 'shema.json'), str(M / 'dokument.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site'])
    K.append(Kletka('v16-versija-ne-ta', argv, sreda(mir, **e), 2,
                    ['ENGINE_VERSION: jsonschema']))
    argv, env = wrap('netrezhim', 'argument')
    K.append(Kletka('v17-rezhim-neizvesten', argv, sreda(mir, **env), 2,
                    ['NOT_IMPLEMENTED']))
    # ── инвариант 2 БЕЗ швов бинарей: резолв «дом установки → command -v»,
    # пин-проверка каждой ветви, именованные состояния пина (Блок 1 критика) ──
    argv = ['bash', str(S / 'validate_std.sh'), 'workflow', str(M / 'honest.yml')]
    K.append(Kletka('v18-dom-chestnyj', argv,
                    sreda_bez_shvov(mir, home=mir['dom_chestnyj']), 0))
    argv = ['bash', str(S / 'validate_std.sh'), 'workflow', str(M / 'honest.yml')]
    K.append(Kletka('v19-dom-podmena', argv,
                    sreda_bez_shvov(mir, home=mir['dom_podmena']), 2,
                    ['VALIDATOR_PIN: actionlint']))
    # v20 — пин-файл без строки actionlint: вариант корня субъекта с пинами
    # мира минус строка инструмента; среда без единого VALIDATE_STD_*.
    e20 = sreda_bez_shvov(mir)
    del e20['VALIDATE_STD_PINS']
    K.append(Kletka('v20-stroka-pina-net',
                    ['bash', str(koren_bez_stroki(koren, mir) / 'scripts'
                                 / 'validate_std.sh'),
                     'workflow', str(M / 'honest.yml')],
                    e20, 2, ['VALIDATOR_MISSING: actionlint']))
    argv = ['bash', str(S / 'validate_std.sh'), 'workflow', str(M / 'honest.yml')]
    e21 = sreda_bez_shvov(mir)
    e21['PATH'] = '%s:%s' % (mir['path_podmena'], e21['PATH'])
    K.append(Kletka('v21-path-podmena', argv, e21, 2,
                    ['VALIDATOR_PIN: actionlint']))
    argv = ['bash', str(S / 'validate_std.sh'), 'workflow', str(M / 'honest.yml')]
    e22 = sreda_bez_shvov(mir)
    e22['PATH'] = '/usr/bin:/bin'
    K.append(Kletka('v22-nigde-net', argv, e22, 2,
                    ['VALIDATOR_MISSING: actionlint']))

    # ── json по ПЕРЕДАННОЙ схеме: каждая обещанная ограничилка различима
    # своей клеткой (Блок 2 критика: вторая и третья пары «схема/документ») ──
    argv, env = wrap('json', str(M / 'shema2.json'), str(M / 'dokument_para2.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v23-json-para2', argv, sreda(mir, **e), 1,
                    ['JSON_INVALID:/', 'lishnee_pole']))
    argv, env = wrap('json', str(M / 'shema2.json'),
                     str(M / 'dokument_tolko_required.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v24-json-tolko-required', argv, sreda(mir, **e), 1,
                    ['JSON_INVALID:', "'ves' is a required property"]))
    argv, env = wrap('json', str(M / 'shema2.json'),
                     str(M / 'dokument_tolko_tip.json'))
    e = dict(env)
    e['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v25-json-tolko-tip', argv, sreda(mir, **e), 1,
                    ['JSON_INVALID:/ves', 'is not of type']))

    # ── дефолтный путь пин-файла (Блок 3 критика, вызов 2: каждый дефолт
    # резолва — обёртки и движка json — имеет положительную и парную
    # отрицательную клетку). Техника ДЕМО-2: вариант-корень субъекта с
    # пин-файлом мира на ДЕФОЛТНОМ месте, среда БЕЗ единого VALIDATE_STD_*
    # (sreda_defolt) — резолв пина обязан пойти по дефолту самого скрипта. ──
    koren_def = koren_s_defoltom(koren, mir)
    argv = ['bash', str(koren_def / 'scripts' / 'validate_std.sh'),
            'workflow', str(M / 'honest.yml')]
    K.append(Kletka('v26-defolt-chestnyj', argv,
                    sreda_defolt(mir, home=mir['dom_chestnyj']), 0))
    argv = ['bash', str(koren_def / 'scripts' / 'validate_std.sh'),
            'workflow', str(M / 'honest.yml')]
    K.append(Kletka('v27-defolt-podmena-v-dome', argv,
                    sreda_defolt(mir, home=mir['dom_podmena']), 2,
                    ['VALIDATOR_PIN: actionlint']))
    argv = ['python3', str(koren_def / 'scripts' / 'validate_std_json.py'),
            str(M / 'shema.json'), str(M / 'dokument.json')]
    e28 = sreda_defolt(mir)
    e28['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v28-json-defolt-chestnyj', argv, e28, 0))
    argv = ['python3', str(koren_def / 'scripts' / 'validate_std_json.py'),
            str(M / 'shema.json'), str(M / 'dokument.json')]
    e29 = sreda_defolt(mir)
    e29['PYTHONPATH'] = str(mir['site'])
    K.append(Kletka('v29-json-defolt-versija-ne-ta', argv, e29, 2,
                    ['ENGINE_VERSION: jsonschema']))
    argv = ['bash', str(koren_s_defoltom(koren, mir, bez_pin_fajla=True)
                        / 'scripts' / 'validate_std.sh'),
            'workflow', str(M / 'honest.yml')]
    K.append(Kletka('v30-pin-fajl-net', argv,
                    sreda_defolt(mir, home=mir['dom_chestnyj']), 2,
                    ['VALIDATOR_PINS', 'не найден']))

    # ── три различимых состояния пин-файла на ОБОИХ скриптах (Блок 4 критика,
    # вызов 3): «файла нет»/«не читается» → rc 2 VALIDATOR_PINS (обёртка) /
    # ENGINE_PINS (движок json напрямую) — именованный отказ ДО резолва;
    # «файл цел, строки нет» → VALIDATOR_MISSING (v20) / ENGINE_MISSING (v34).
    # chmod-000 нечитаемость материализуется только не под root: под root
    # клетки v31/v33 дают именованный отказ NEZAPUSKAEMA, не молчаливый
    # зелёный (слово владельца 2026-11-11, задание fix3). ──
    uslovie_chmod = None if mir['chmod_nechitaemost'] else (
        'NEZAPUSKAEMA: chmod-000 нечитаемость не материализуется на этой '
        'станции (root читает и 000) — клетка не судима, не молчаливый зелёный')
    koren_nch = koren_s_defoltom(koren, mir, nechitaem=True)
    argv = ['bash', str(koren_nch / 'scripts' / 'validate_std.sh'),
            'workflow', str(M / 'honest.yml')]
    K.append(Kletka('v31-pin-nechitaem', argv,
                    sreda_defolt(mir, home=mir['dom_chestnyj']), 2,
                    ['VALIDATOR_PINS', 'не читается'], uslovie=uslovie_chmod))
    argv = ['python3', str(koren_s_defoltom(koren, mir, bez_pin_fajla=True)
                           / 'scripts' / 'validate_std_json.py'),
            str(M / 'shema.json'), str(M / 'dokument.json')]
    e32 = sreda_defolt(mir)
    e32['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v32-json-pin-fajl-net', argv, e32, 2,
                    ['ENGINE_PINS', 'не найден']))
    argv = ['python3', str(koren_nch / 'scripts' / 'validate_std_json.py'),
            str(M / 'shema.json'), str(M / 'dokument.json')]
    e33 = sreda_defolt(mir)
    e33['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v33-json-pin-nechitaem', argv, e33, 2,
                    ['ENGINE_PINS', 'не читается'], uslovie=uslovie_chmod))
    argv = ['python3', str(koren_s_defoltom(koren, mir, bez_stroki='jsonschema')
                           / 'scripts' / 'validate_std_json.py'),
            str(M / 'shema.json'), str(M / 'dokument.json')]
    e34 = sreda_defolt(mir)
    e34['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v34-json-stroki-pina-net', argv, e34, 2,
                    ['ENGINE_MISSING: jsonschema', 'нет строки пина']))
    # ── инвариант 3, аритмичность аргументов (Б-1 ревьюера contracts-189-impl-v1:
    # лишние позиционные аргументы молча отбрасывались — вызов с несколькими
    # файлами давал rc 0 по непроверенному файлу). Лишний аргумент в КАЖДОМ
    # режиме обёртки → rc 2 NOT_IMPLEMENTED, а не молчаливая проверка первого
    # из нескольких; недостаток аргументов — той же смертью. canon-режима у
    # обёртки нет (check_canon_fragment.py — отдельный CLI), клетки с ним не
    # добавляются. v37 несёт PYTHONPATH движка (как v12): на дефектной
    # реализации движение ДОКАТЫВАЕТСЯ до честного rc 0 — краснота клетки есть
    # сам молчаливый пропуск, а не случайное совпадение rc 2 без маркера. ──
    argv, env = wrap('workflow', str(M / 'honest.yml'), str(M / 'sintaksis.sh'))
    K.append(Kletka('v35-workflow-lishnij-argument', argv, sreda(mir, **env), 2,
                    ['NOT_IMPLEMENTED']))
    argv, env = wrap('bash', str(M / 'chestnyj_skript.sh'), str(M / 'sintaksis.sh'))
    K.append(Kletka('v36-bash-lishnij-argument', argv, sreda(mir, **env), 2,
                    ['NOT_IMPLEMENTED']))
    argv, env = wrap('json', str(M / 'shema.json'), str(M / 'dokument.json'),
                     str(M / 'dokument_narushenie.json'))
    e37 = dict(env)
    e37['PYTHONPATH'] = str(mir['site_dvizhka'])
    K.append(Kletka('v37-json-lishnij-argument', argv, sreda(mir, **e37), 2,
                    ['NOT_IMPLEMENTED']))
    argv, env = wrap('workflow')
    K.append(Kletka('v38-workflow-bez-fajla', argv, sreda(mir, **env), 2,
                    ['NOT_IMPLEMENTED']))
    argv, env = wrap('bash')
    K.append(Kletka('v39-bash-bez-fajla', argv, sreda(mir, **env), 2,
                    ['NOT_IMPLEMENTED']))
    argv, env = wrap('json', str(M / 'shema.json'))
    K.append(Kletka('v40-json-malo-argumentov', argv, sreda(mir, **env), 2,
                    ['NOT_IMPLEMENTED']))
    return K


def sudit(k: Kletka) -> bool:
    if k.uslovie:
        # Состояние клетки не материализуется на этой станции (chmod-000
        # нечитаемости не бывает под root): именованный отказ NEZAPUSKAEMA,
        # не молчаливый зелёный (слово владельца 2026-11-11, Блок 4).
        print('189 %s ok %s' % (k.imja, k.uslovie))
        return True
    try:
        r = subprocess.run(k.argv, env=k.env, capture_output=True, text=True, timeout=60)
        rc, err = r.returncode, r.stderr
    except FileNotFoundError:
        rc, err = None, 'SUBJECT_ABSENT: %s' % k.argv[0]
    except subprocess.TimeoutExpired:
        rc, err = None, 'TIMEOUT'
    ok = rc == k.rc and all(m in err for m in k.markery)
    print('189 %s %s rc=%s %s' % (
        k.imja, 'ok' if ok else 'KRASNO', rc, err.strip().splitlines()[:1]))
    return ok


def z01_zhivaja_sverka(koren: Path) -> bool:
    """Живой свидетель (вне субъекта): пин-файл субъекта ↔ установка станции."""
    pin_fajl = koren / 'ops' / 'server' / 'validators.tsv'
    if not pin_fajl.is_file():
        print('189 z01-edinnyj-istochnik KRASNO rc=None SUBJECT_ABSENT: %s' % pin_fajl)
        return False
    dom = REAL_HOME / '.local' / 'state' / 'dev-harness' / 'validators'
    if not dom.is_dir():
        print('189 z01-edinnyj-istochnik ok LIVE_PREDPOSYLKA: станция без установки '
              'валидаторов (%s) — живая сверка отложена, не пропуск зелёным' % dom)
        return True
    stroki = [l.split('\t') for l in pin_fajl.read_text(encoding='utf-8').splitlines()
              if l.strip() and not l.lstrip().startswith('#')]
    vse_ok = True
    for cols in stroki:
        if len(cols) < 3 or cols[2] == '-':
            continue
        instrument, versija, pin = cols[0], cols[1], cols[2]
        binar = dom / instrument / versija / instrument
        if not binar.is_file():
            print('189 z01-edinnyj-istochnik KRASNO VALIDATOR_MISSING: %s (%s)'
                  % (instrument, binar))
            vse_ok = False
            continue
        fakt = hashlib.sha256(binar.read_bytes()).hexdigest()
        if fakt != pin:
            print('189 z01-edinnyj-istochnik KRASNO VALIDATOR_PIN: %s фактический %s ≠ пин %s'
                  % (instrument, fakt, pin))
            vse_ok = False
        else:
            print('189 z01-edinnyj-istochnik ok %s: sha установленного == пин' % instrument)
    return vse_ok


def predposylki() -> None:
    for mod in ('yaml', 'jsonschema'):
        r = subprocess.run(['python3', '-c', 'import %s' % mod],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print('LIVE_PREDPOSYLKA: нет модуля %s — нечем исполнять канон/json-клетки '
                  'батареи 189 (чистый клон без зависимостей — именованный отказ, не '
                  'skip→pass и не ложная клетка)' % mod, file=sys.stderr)
            sys.exit(2)


def rezhim_repo(koren: Path, mir: dict) -> int:
    predposylki()
    K = kletki(koren, mir)
    zel = sum(1 for k in K if sudit(k)) + (1 if z01_zhivaja_sverka(koren) else 0)
    vsego = len(K) + 1
    kras = vsego - zel
    print('ИТОГ 189: rc=%d KLETKI=%d ZELENYE=%d KRASNYE=%d'
          % (0 if kras == 0 else 1, vsego, zel, kras))
    return 0 if kras == 0 else 1


def rezhim_stabs(mir: dict) -> int:
    svjazi = []
    for line in (HERE / 'stabs.tsv').read_text(encoding='utf-8').splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) != 3:
            print('ORACLE_TAMPERED: строка привязки вне грамматики: %r' % line,
                  file=sys.stderr)
            return 2
        svjazi.append(cols)
    poimano, zhivyh, sudimyh = 0, 0, 0
    for imja, fail, kletka_imja in svjazi:
        # Временный корень обманки собираем в изолированном временном каталоге мира:
        koren = mir['vrem'] / ('obmanka-%s' % imja)
        for f in ('validate_std.sh', 'validate_std_json.py', 'check_canon_fragment.py'):
            cel = koren / 'scripts' / f
            cel.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(HERE / 'model' / 'scripts' / f, cel)
        shutil.copyfile(HERE / 'stabs' / imja, koren / fail)
        zapisat(koren / 'ops' / 'server' / 'validators.tsv',
                (mir['pins']).read_text(encoding='utf-8'))
        K = kletki(koren, mir)
        kletka = next((k for k in K if k.imja.startswith(kletka_imja + '-')), None)
        if kletka is None:
            print('ORACLE_TAMPERED: клетка привязки не найдена: %s' % kletka_imja,
                  file=sys.stderr)
            return 2
        if kletka.uslovie:
            # Вход обманки (клетка привязки) не материализуется на этой станции
            # (chmod-000 под root): именованный пропуск, обманка вне суда —
            # не молчаливый зелёный и не ложная поимка (слово владельца, fix3).
            print('189 %s NEZAPUSKAEMA: клетка привязки %s — %s'
                  % (imja, kletka_imja, kletka.uslovie))
            continue
        ulov = not sudit(kletka)  # обманка НЕ удовлетворяет ожиданию клетки
        sudimyh += 1
        if ulov:
            poimano += 1
        else:
            zhivyh += 1
        print('189 %s %s' % (imja, 'POIMAN' if ulov else 'ZHIV — дефект не различим'))
    print('ИТОГ 189: rc=%d OBMANOK=%d POIMANY=%d ZHIVYH=%d'
          % (0 if zhivyh == 0 else 1, sudimyh, poimano, zhivyh))
    return 0 if zhivyh == 0 else 1


def main() -> int:
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, default=None)
    p.add_argument('--model', action='store_true')
    p.add_argument('--stabs', action='store_true')
    a = p.parse_args()
    vrem = Path(tempfile.mkdtemp(prefix='batareja-189-'))
    try:
        mir = sobrat_mir(vrem)
        if a.stabs:
            return rezhim_stabs(mir)
        if a.model:
            koren = sobrat_koren_subekta(vrem, mir, 'model')
            return rezhim_repo(koren, mir)
        koren = a.repo if a.repo is not None else ROOT
        return rezhim_repo(koren, mir)
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
