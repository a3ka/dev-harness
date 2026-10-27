#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 141 (§ПРОВОДКА): судит ПОСТАВЛЯЕМЫЙ артефакт —
# .github/workflows/mobile.yml репозитория продукта (шаги 135/118/995 со
# своим эмулятором) — каноном скрипта (тела run: построчно равны модели,
# комментарии/формат свободны; замыкание по построению, прецедент 139 v3)
# и ПОВЕДЕНЧЕСКИ: тело каждого шага исполняется в чистом окружении с
# подложными adb/emulator/avdmanager/python3 (сценарий задаёт rc валидатора,
# сигнатуры в maestro-out, состояние adb, хвост emulator-лога; PATH замкнут).
# Оракул — source.json в памяти ДО вызова субъекта (правило 8); модель и
# носители — sha256. Н-39: обманные стабы — мутации модели КОДОМ
# (STAB_MUTACII), привязки — stab_vhod source.json; рассинхрон множеств —
# rc 2 ORACLE_TAMPERED.
"""Батарея 141 (obryv-adb-diagnostika): диагностика ВНЕ эха + ровно один
повтор по сигнатуре обрыва adb-транспорта в шагах 135/118/995 mobile.yml.

Режимы:
  (без флага)  --repo R отсутствует и MOB_REPO не задан → rc 1 SUBJECT_ABSENT
                 с перечнем всех кейсов (зелень без субъекта невозможна);
  (без флага)  --repo R / MOB_REPO → судится живой R/.github/workflows/
                 mobile.yml (тела шагов 135/118/995 против модели);
  --model      субъект = model/mobile.yml (контроль входов);
  --stabs      контроль + матрица обманных стабов (SVJAZI N);
  --matrix     синоним --stabs (для арбитража).
Коды возврата: 0 — зелено; 1 — красный кейс либо стаб прошёл (STAB_ZHIV)
либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверять (нет python3-модуля
yaml, ORACLE_TAMPERED, дрейф модели/мутаций).
"""
import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml  # pyyaml 6.0.1 — та же версия, что пин шага 117 в mobile.yml

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model' / 'mobile.yml'
NOSITELI = HERE / 'nositeli'
SUBJECT_REL = '.github/workflows/mobile.yml'
BASH = '/usr/bin/bash' if Path('/usr/bin/bash').is_file() else 'bash'
MODEL_PIN_KEY = 'model/mobile.yml'

# ── подложные команды replay (замкнутый алфавит; всё иное — 127) ────────────

ADB_SH = r'''#!/usr/bin/env bash
# Подложный adb батареи 141: замкнутый алфавит подкоманд шагов 135/118/995;
# состояние транспорта задаёт сценарий (SCENARIJ_*). Всё иное — 127.
z="${SCENARIJ_ZAPISI:?}"
if [ "${1:-}" = "devices" ]; then
  printf 'ADB_DEVICES\n' >>"$z"
  echo 'List of devices attached'
  printf '%s\n' "$SCENARIJ_ADB_DEVICES"
  exit 0
fi
if [ "${1:-}" = "start-server" ]; then exit 0; fi
case "$*" in
  *"emu kill"*) exit 0 ;;
  *"wait-for-device"*) exit 0 ;;
  *"getprop sys.boot_completed"*)
    if [ "$SCENARIJ_BOOT" = "ne-zagruzilsja" ]; then exit 0; fi
    echo 1; exit 0 ;;
  *"get-state"*)
    if [ "$SCENARIJ_BOOT" = "stabil-net" ]; then echo offline; exit 0; fi
    echo device; exit 0 ;;
  *"pm path android"*)
    if [ "$SCENARIJ_BOOT" = "stabil-net" ]; then exit 1; fi
    exit 0 ;;
  *"settings put global"*) exit 0 ;;
  *"install -r"*) exit 0 ;;
esac
echo "ADB_VNE_ALFAVITA: $*" >&2
exit 127
'''

EMULATOR_SH = r'''#!/usr/bin/env bash
# Подложный emulator батареи 141: пишет сценарный хвост emulator-$AVD.log
# (гипотеза (г)/(е) диагностики: port already in use, краш qemu) и метку
# запуска в журнал; сам qemu не поднимается.
z="${SCENARIJ_ZAPISI:?}"
avd=""
prev=""
for a in "$@"; do
  if [ "$prev" = "-avd" ]; then avd="$a"; fi
  prev="$a"
done
printf 'EMULATOR %s\n' "$avd" >>"$z"
if [ -n "$SCENARIJ_EMULATOR_LOG" ]; then
  printf '%s' "$SCENARIJ_EMULATOR_LOG" | tr '\037' '\n'
fi
exit 0
'''

PKILL_SH = '#!/usr/bin/env bash\n# Подложный pkill батареи 141: ничего не убивает.\nexit 0\n'
SLEEP_SH = '#!/usr/bin/env bash\n# Подложный sleep батареи 141: мгновенный (replay не ждёт эмулятор).\nexit 0\n'

AVDMANAGER_SH = r'''#!/usr/bin/env bash
# Подложный avdmanager батареи 141: create — создаёт $ANDROID_AVD_HOME/<n>.avd
# /config.ini (под sed -i шага), delete — успех; всё иное — 127.
if [ "${1:-}" = "create" ] && [ "${2:-}" = "avd" ]; then
  imja=""
  prev=""
  for a in "$@"; do
    if [ "$prev" = "-n" ]; then imja="$a"; fi
    prev="$a"
  done
  cat >/dev/null
  mkdir -p "${ANDROID_AVD_HOME:?}/${imja:?}.avd"
  printf 'hw.ramSize=4096\nhw.device.name=pixel_7\n' \
    >"${ANDROID_AVD_HOME:?}/${imja:?}.avd/config.ini"
  exit 0
fi
if [ "${1:-}" = "delete" ]; then exit 0; fi
echo "AVDMANAGER_VNE_ALFAVITA: $*" >&2
exit 127
'''

PYTHON3_SH = r'''#!/usr/bin/env python3
# Подложный python3 батареи 141: замкнутый алфавит вызовов шагов —
# ekran_shablon.py (валидатор 132 у 135/118: rc по счётчику сценария,
# сигнатуры пишутся в maestro-out), maestro_probe.py (995: тот же лексикой),
# proverka_proiskhozdenija.py (rc 0), -m pip (rc 0). Всё иное — 127.
import os
import sys

z = os.environ['SCENARIJ_ZAPISI']
kat = os.environ['SCENARIJ_KATALOG']
a = sys.argv[1:]


def zap(line):
    with open(z, 'a', encoding='utf-8') as f:
        f.write(line + '\n')


def schet(imja):
    p = os.path.join(kat, imja)
    try:
        return int(open(p).read().strip() or '0')
    except OSError:
        return 0


def rc_iz_scenarija(n):
    rcs = [int(x) for x in os.environ.get('SCENARIJ_PRIEMKA_RC', '0').split(',') if x != '']
    return rcs[n - 1] if n - 1 < len(rcs) else 0


def posadi_signatury(katalog):
    sig = os.environ.get('SCENARIJ_SIGNATURY', '')
    pustoj = os.environ.get('SCENARIJ_PUSTOJ_FAJL', '') == 'da'
    if not sig and not pustoj:
        return
    d = os.path.join(os.getcwd(), katalog, 'scenarij')
    os.makedirs(d, exist_ok=True)
    telo = sig.replace('\x1f', '\n') + '\n' if sig else ''
    with open(os.path.join(d, 'maestro.log'), 'w', encoding='utf-8') as f:
        f.write(telo)


def begi(shag, schetchik, katalog):
    n = schet(schetchik) + 1
    with open(os.path.join(kat, schetchik), 'w', encoding='utf-8') as f:
        f.write(str(n))
    rc = rc_iz_scenarija(n)
    posadi_signatury(katalog)
    zap('%s rc=%d' % (shag, rc))
    sys.exit(rc)


tgt = a[0] if a else ''
if tgt == '-m' and len(a) > 1 and a[1] == 'pip':
    sys.exit(0)
if tgt.endswith('ekran_shablon.py'):
    shag = os.environ.get('SCENARIJ_SHAG', '135')
    katalog = {'135': 'mobile/maestro-out-first-run',
               '118': 'mobile/maestro-out-erstinformation'}[shag]
    begi('PRIEMKA ' + shag, 'priemka_' + shag, katalog)
if tgt.endswith('maestro_probe.py'):
    begi('PROBA995', 'proba995', 'mobile/maestro-out')
if tgt.endswith('proverka_proiskhozdenija.py'):
    sys.exit(0)
zap('PYTHON_VNE_ALFAVITA ' + chr(31).join(a))
sys.exit(127)
'''

# PATH replay: только этот каталог; утилиты — симлинки на системные, adb/
# emulator/pkill/sleep/python3 — шимы; printf/echo/trap/test — builtins bash.
UTILITY_ALFAVIT = ('bash', 'sed', 'grep', 'tr', 'tail', 'cp', 'cmp',
                   'mkdir', 'rm', 'seq', 'cat')

# Ось ОКРУЖЕНИЕ (прецедент 139 v3): каждый replay-вход исполняется и в
# CHISTYJ, и в ACTIONS — свидетель env-инвариантности модели; замыканием
# класса остаётся канон скрипта (тела равны модели построчно).
OKRUZHENIE_ACTIONS = {
    'GITHUB_ACTIONS': 'true',
    'CI': 'true',
    'GITHUB_RUN_ATTEMPT': '1',
    'GITHUB_RUN_NUMBER': '4242',
    'GITHUB_WORKFLOW': 'mobile',
    'GITHUB_JOB': 'e2e-first-run',
    'GITHUB_EVENT_NAME': 'push',
    'GITHUB_SHA': '1410beef1410beef1410beef1410beef1410beef',
    'GITHUB_REF': 'refs/heads/main',
    'GITHUB_ACTOR': 'battery-141',
    'GITHUB_API_URL': 'https://api.github.com',
    'GITHUB_SERVER_URL': 'https://github.com',
    'GITHUB_TOKEN': 'test-token-141',
    'RUNNER_OS': 'Linux',
    'RUNNER_ARCH': 'X64',
    'RUNNER_NAME': 'selfhosted-141',
    'ACTIONS_RUNTIME_TOKEN': 'test-token-141',
}

RUN_ID = '401407'
RUN_ATTEMPT = '1'

VYRAZHENIE_RE = re.compile(r'\$\{\{[^}]*\}\}')
PODSTANOVKA = {
    '${{ github.workspace }}': None,  # заполняется на sandbox (абс. путь)
    '${{ github.run_id }}': RUN_ID,
    '${{ github.run_attempt }}': RUN_ATTEMPT,
}


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


# --- оракул ------------------------------------------------------------------

def oshibka_orakula(msg):
    print('ORACLE_TAMPERED: %s' % msg, file=sys.stderr)
    return 2


def load_source():
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    if src.get('kontrakt') != '141-obryv-adb-diagnostika':
        raise RuntimeError('kontrakt != 141')
    if set(src['stab_vhod']) != set(STAB_MUTACII):
        raise RuntimeError('stab_vhod != STAB_MUTACII')
    return src


# --- тела шагов и канон скрипта ----------------------------------------------

def job_shaga(doc, src, nomer):
    """v2 (контракт 143): задача-носитель шага — ТАБЛИЦА job_imja (135 →
    e2e-first-run, 118 → e2e-erstinformation, 995 → e2e-pilot), не один
    монолитный android-e2e; None, если задачи нет."""
    imja = src['job_imja'][nomer]
    jobs = doc.get('jobs') if isinstance(doc, dict) else None
    return jobs.get(imja) if isinstance(jobs, dict) else None


def shagi_doc(doc, src, nomer):
    job = job_shaga(doc, src, nomer)
    return job.get('steps') if isinstance(job, dict) else None


def telo_shaga(doc, src, nomer):
    """Тело run: шага с именем-префиксом src['shagi'][nomer] В СВОЕЙ задаче
    (v2, 143); None, если задачи/шага нет (SHAG_<N>_NET)."""
    imja = src['shagi'][nomer]
    shagi = shagi_doc(doc, src, nomer)
    if not shagi:
        return None
    for s in shagi:
        nm = s.get('name', '')
        if isinstance(nm, str) and nm.startswith(imja):
            run = s.get('run')
            if isinstance(run, str):
                return run.rstrip('\n')
    return None


def normalize(telo):
    """Канон 139 v3: strip каждой строки, пустые и #-комментарии выброшены."""
    return [l.strip() for l in telo.split('\n')
            if l.strip() and not l.strip().startswith('#')]


def kanon_rashozhdenie(subj, model):
    a, b = normalize(subj), normalize(model)
    for i in range(min(len(a), len(b))):
        if a[i] != b[i]:
            return i + 1, a[i], b[i]
    if len(a) != len(b):
        i = min(len(a), len(b)) + 1
        sa = a[i - 1] if i - 1 < len(a) else '<конец>'
        sb = b[i - 1] if i - 1 < len(b) else '<конец>'
        return i, sa, sb
    return None


# --- управляющие свойства шага и job (исправительный проход по вердикту
# Critic141 FAIL вызов 1/2: обманное `if: ${{ false }}` на шаге 135 при
# байт-в-байт модельном run: давало rc 0 35/35 ok — канон и replay судили
# только тело шага, а не сам исполняемый шаг) -------------------------------

def _najti_shag_doc(doc, src, nomer):
    imja = src['shagi'][nomer]
    shagi = shagi_doc(doc, src, nomer)
    if not shagi:
        return None
    for s in shagi:
        nm = s.get('name', '')
        if isinstance(nm, str) and nm.startswith(imja):
            return s
    return None


def upravlenie_shaga(subj_doc, src, nomer, model_doc):
    """Исполняемость шага: замкнутый алфавит ключей = как в модели
    (живой замер модели: name, run, working-directory у всех трёх);
    лишний ключ (if / continue-on-error / shell / env / timeout-minutes /
    uses / with / id — любой вне алфавита), отсутствие ключа модели либо
    неравное значение не-run ключа (working-directory) — именованный
    отказ: шаг либо не исполняется, либо гасит красный итог."""
    subj = _najti_shag_doc(subj_doc, src, nomer)
    if subj is None:
        return ('KRASNO', 'SHAG_%s_NET' % nomer)
    model = _najti_shag_doc(model_doc, src, nomer)
    if model is None:
        return ('KRASNO', 'ORACLE_TAMPERED: в модели нет шага %s' % nomer)
    lishnie = sorted(set(subj) - set(model))
    if lishnie:
        return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: shag %s: лишние ключи: %s'
                % (nomer, ', '.join(lishnie)))
    netu = sorted(set(model) - set(subj))
    if netu:
        return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: shag %s: нет ключей: %s'
                % (nomer, ', '.join(netu)))
    for k in sorted(set(model) - {'run', 'name'}):
        if subj.get(k) != model.get(k):
            return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: shag %s: %s = %r (в модели %r)'
                    % (nomer, k, subj.get(k), model.get(k)))
    return ('ok', None)


# Зелёные ключи задачи-носителя (решение арбитража 141, J1): по построению
# не меняют ни достижимость шагов, ни красноту итога — имя/права/выходы;
# concurrency даёт только отмену, не зелень. Алфавит модели измеряется
# живым замером model_doc (как у шага), зелёные — константа.
JOB_ZELENYE_KLYUCHI = ('name', 'permissions', 'outputs', 'concurrency')

# v2 (143, И-3): каноническая форма условия выбора работника — единый
# источник для модели, клетки и стабов уровня job.
JOB_IF_KANON = "needs.select-screens.outputs['%s'] == 'true'"
# v2-испр. 1 (блокер вердикта критика 141 v2, вызов 1/2 «needs-ребро»):
# канонический if выбора ссылается на контекст needs.<работа>.outputs —
# контекст выбора платформа даёт ТОЛЬКО через ребро needs той же задачи;
# имя работы канона выводится из JOB_IF_KANON (единый источник, второй
# константы нет).
JOB_IF_REBRO = JOB_IF_KANON.split('.')[1]


def upravlenie_job(subj_doc, src, model_doc):
    """J1–J3 (арбитраж 141, Q1 вариант (а)); v2 (143): судятся ТРИ
    задачи-носителя шагов — job_imja таблица (e2e-first-run /
    e2e-erstinformation / e2e-pilot), не один монолит android-e2e.
    J1: замкнутый алфавит КЛЮЧЕЙ каждой задачи = как в её модели, значения
    не разбираются — перечень значений открытого языка выражений GitHub
    Actions не замыкается (дефект 141b: whitelisted-различители значений
    пропускали `continue-on-error: ${{ true }}`), КРОМЕ job-if: v2 (143
    И-3) у работника — ровно каноническое условие выбора
    needs.select-screens.outputs['<job>'] == 'true' (как в модели), любое
    иное значение — именованный отказ; J2: needs существуют + транзитивная
    цепь без `if`; J3: timeout-minutes — целое >= 1 после YAML-разбора;
    runs-on не судится (несуществующая метка — вечная очередь, не зелень);
    steps судятся инвариантами шага."""
    jobs = subj_doc.get('jobs') if isinstance(subj_doc, dict) else None
    for nomer in ('135', '118', '995'):
        imja = src['job_imja'][nomer]
        job = jobs.get(imja) if isinstance(jobs, dict) else None
        if not isinstance(job, dict):
            return ('KRASNO', 'JOB_NET: %s' % imja)
        model_job = (model_doc.get('jobs') or {}).get(imja)
        if not isinstance(model_job, dict):
            return ('KRASNO', 'ORACLE_TAMPERED: в модели нет job %s' % imja)
        lishnie = sorted(set(job) - set(model_job) - set(JOB_ZELENYE_KLYUCHI))
        if lishnie:
            return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: job %s: лишние ключи: %s'
                    % (imja, ', '.join(lishnie)))
        if 'if' in model_job and job.get('if') != JOB_IF_KANON % imja:
            return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: job %s: if=%r '
                    '(канон 143: %r)' % (imja, job.get('if'),
                                         JOB_IF_KANON % imja))
        nz = job.get('needs')
        if 'if' in model_job:
            # v2-испр. 1 (needs-ребро, блокер вердикта критика 141 v2 1/2):
            # канонический if выбора ссылается на needs.<JOB_IF_REBRO>.
            # outputs — контекст выбора платформа даёт ТОЛЬКО через ребро
            # needs той же задачи: без него работа не выбирается по
            # селектору (шаги не исполняются), а J2 существования работ
            # needs остаётся зелёной (обход: needs: [build-apk] при
            # байт-в-байт if и телах). Отказ fail-closed: needs — только
            # список строк, семантика вхождения строки не разбирается
            # (ловушка 'select-screens, build-apk' — одно имя работы).
            if not isinstance(nz, list):
                return ('KRASNO', 'REBRO_NEEDS: job %s: needs=%r не список '
                        '(канонический if ссылается на needs.%s.outputs — '
                        'контекст выбора даёт только ребро needs; канон 143 '
                        'И-3 (модель): needs=%r)'
                        % (imja, nz, JOB_IF_REBRO, model_job.get('needs')))
            if JOB_IF_REBRO not in nz:
                return ('KRASNO', 'REBRO_NEEDS: job %s: нет ребра %s в '
                        'needs=%r (канонический if ссылается на '
                        'needs.%s.outputs — без ребра работа не выбирается '
                        'по селектору, шаги не исполняются; канон 143 И-3 '
                        '(модель): needs=%r)'
                        % (imja, JOB_IF_REBRO, nz, JOB_IF_REBRO,
                           model_job.get('needs')))
        spisok = [nz] if isinstance(nz, str) else (nz if isinstance(nz, list) else [])
        for n in spisok:
            if not isinstance(jobs.get(n), dict):
                return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: job %s: needs на '
                        'несуществующую работу %r' % (imja, n))
        ochered, vidennye = list(spisok), set()
        while ochered:
            n = ochered.pop()
            if n in vidennye:
                continue
            vidennye.add(n)
            upstream = jobs.get(n) if isinstance(jobs.get(n), dict) else {}
            if 'if' in upstream:
                return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: job %s: upstream %s '
                        'несёт if=%r' % (imja, n, upstream['if']))
            u = upstream.get('needs')
            ochered += [u] if isinstance(u, str) else (u if isinstance(u, list) else [])
        tm = job.get('timeout-minutes', 1)
        if not (isinstance(tm, int) and not isinstance(tm, bool) and tm >= 1):
            return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: job %s: '
                    'timeout-minutes=%r' % (imja, tm))
    return ('ok', None)


def upravlenie_workflow(subj_doc, model_doc):
    """W1–W2 (арбитраж 141): workflow-оболочка — defaults равен модели как
    ДАННЫЕ после YAML-разбора ({run: {working-directory: mobile}}, shell
    нет), top-level env отсутствует, как в модели; прочие top-level ключи
    (name, on, permissions, concurrency) не судятся — см. §НЕ ЗАЩИЩАЕТ."""
    if subj_doc.get('defaults') != model_doc.get('defaults'):
        return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: workflow: defaults=%r '
                '(в модели %r)' % (subj_doc.get('defaults'),
                                   model_doc.get('defaults')))
    if 'env' in subj_doc:
        env = subj_doc['env']
        spisok = sorted(env) if isinstance(env, dict) else [repr(env)]
        return ('KRASNO', 'UPRAVLYAYUSHCHIJ_KLYUCH: workflow: env вне '
                'модели: %s' % spisok)
    return ('ok', None)


def postavit_derevo(model_doc, src):
    """Зелёный контроль законных правок job (арбитраж 141, мутанты №24–27;
    v2 — на КАЖДОЙ из трёх задач-носителей): дерево = модель + name,
    permissions, timeout-minutes 50, runs-on с лишней меткой — ключи
    зелёные/несудимые, достижимость шагов и красный итог не затрагивают;
    всё кодом, без файла-носителя."""
    doc = copy.deepcopy(model_doc)
    for nomer in ('135', '118', '995'):
        job = doc['jobs'][src['job_imja'][nomer]]
        job['name'] = 'E2E ekran %s' % nomer
        job['permissions'] = {'contents': 'read'}
        job['timeout-minutes'] = 50
        job['runs-on'] = list(job['runs-on']) + ['v2']
    return doc


# --- replay: sandbox с подложными adb/emulator/avdmanager/python3 -----------

def zapisat_izv_shim(put, tekst, ispolnimyj=True):
    put.write_text(tekst, encoding='utf-8')
    if ispolnimyj:
        put.chmod(0o755)


def postavit_sandbox(scena, shag, katalog_sandbox):
    """Собирает sandbox: bindir (шимы + симлинки), android-home/avd-home,
    workspace с пинами cmp/cp, счётчики сценария. Возвращает env replay."""
    bin_ = katalog_sandbox / 'bindir'
    bin_.mkdir(parents=True)
    # shebang шима python3 — АБСОЛЮТНЫЙ интерпретатор батареи: env-поиск по
    # замкнутому PATH нашёл бы сам шим и ушёл в рекурсию (прецедент 139).
    python3_shim = '#!%s\n%s' % (sys.executable, PYTHON3_SH.split('\n', 1)[1])
    for imja, tekst in (('adb', ADB_SH), ('emulator', EMULATOR_SH),
                        ('pkill', PKILL_SH), ('sleep', SLEEP_SH),
                        ('python3', python3_shim)):
        zapisat_izv_shim(bin_ / imja, tekst)
    for u in UTILITY_ALFAVIT:
        cel = Path('/usr/bin') / u
        if not cel.exists():
            raise RuntimeError('утилита PATH replay отсутствует: %s' % u)
        (bin_ / u).symlink_to(cel)
    android_home = katalog_sandbox / 'android-home'
    avdm = android_home / 'cmdline-tools' / 'latest' / 'bin' / 'avdmanager'
    avdm.parent.mkdir(parents=True)
    zapisat_izv_shim(avdm, AVDMANAGER_SH)
    avd_home = katalog_sandbox / 'avd-home'
    avd_home.mkdir()
    ws = katalog_sandbox / 'workspace'
    for otn in ('mobile/e2e-first-run/batareja/proverka_proiskhozdenija.py',
                '.harness135/fixtures/workshop_project/first_run_ekran_135/teksty/proverka_text.py',
                'mobile/e2e-erstinformation/batareja/proverka_proiskhozdenija.py',
                '.harness118/fixtures/workshop_project/erstinformation_118/teksty/proverka_text.py',
                '.harness118/scripts/sverka_maketa.py',
                'mobile/e2e-erstinformation/kadry.json',
                'e2e-erstinformation/jest-otchet.json'):
        p = ws / otn
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text('pin-141\n', encoding='utf-8')
    (ws / '.harness123' / 'scripts').mkdir(parents=True)
    schet_dir = katalog_sandbox / 'scenarij'
    schet_dir.mkdir()
    z = schet_dir / 'zapisi'
    z.write_text('', encoding='utf-8')

    log = ''
    em = scena.get('emulator_log') or {}
    if em:
        stroki = ['emulator: boot line %d' % i for i in range(1, em['strok'] + 1)]
        stroki[em['pozicija'] - 1] = em['oshibka']
        log = '\x1f'.join(stroki)

    env = {
        'PATH': str(bin_),
        'HOME': str(katalog_sandbox),
        'ANDROID_HOME': str(android_home),
        'ANDROID_AVD_HOME': str(avd_home),
        'GITHUB_RUN_ID': RUN_ID,
        'GITHUB_RUN_ATTEMPT': RUN_ATTEMPT,
        'SCENARIJ_ZAPISI': str(z),
        'SCENARIJ_KATALOG': str(schet_dir),
        'SCENARIJ_SHAG': shag,
        'SCENARIJ_PRIEMKA_RC': scena.get('priemka_rc', '0'),
        'SCENARIJ_SIGNATURY': '\x1f'.join(scena.get('signatury') or []),
        'SCENARIJ_BOOT': scena.get('boot', 'ok'),
        'SCENARIJ_ADB_DEVICES': scena.get('adb_devices', ''),
        'SCENARIJ_EMULATOR_LOG': log,
        'SCENARIJ_PUSTOJ_FAJL': 'da' if scena.get('pustoj_fajl') else '',
    }
    return ws, env


def podstavit_vyrazhenija(telo, ws):
    vyh = telo
    for k, v in PODSTANOVKA.items():
        vyh = vyh.replace(k, v if v is not None else str(ws))
    return vyh


def ispolnit_replay(telo, shag, scena, okr, koren):
    with tempfile.TemporaryDirectory(dir=str(koren)) as tmp:
        katalog_sandbox = Path(tmp)
        ws, env = postavit_sandbox(scena, shag, katalog_sandbox)
        telo2 = podstavit_vyrazhenija(telo, ws)
        if '${{' in telo2:
            return None, 'VYRAZHENIE_VNE_ALFAVITA: непереведённое ${{ }} в теле'
        env2 = dict(env)
        if okr == 'ACTIONS':
            env2.update(OKRUZHENIE_ACTIONS)
        skript = katalog_sandbox / 'telo.sh'
        skript.write_text(telo2, encoding='utf-8')
        try:
            r = subprocess.run([BASH, str(skript)], cwd=str(ws), env=env2,
                               capture_output=True, text=True, timeout=90)
        except subprocess.TimeoutExpired:
            return None, 'TIMEOUT replay'
        zapisi = (katalog_sandbox / 'scenarij' / 'zapisi').read_text(
            encoding='utf-8').splitlines()
        return {'rc': r.returncode, 'stdout': r.stdout, 'stderr': r.stderr,
                'zapisi': zapisi}, None


# --- суд кейса ---------------------------------------------------------------

def sravnit_replay(fakt, ozh):
    if fakt is None:
        return 'replay не исполнился'
    if fakt['rc'] != ozh.get('rc', 0):
        return 'rc=%d (ожидался %d)' % (fakt['rc'], ozh.get('rc', 0))
    if fakt['zapisi'] != ozh.get('zapisi', []):
        return 'записи: %s (ожидались %s)' % (fakt['zapisi'], ozh.get('zapisi', []))
    vyvod = fakt['stdout'] + '\n' + fakt['stderr']
    for m in ozh.get('vyvod', []):
        if m not in vyvod:
            return 'нет маркера вывода: %r' % m
    for m in ozh.get('neto', []):
        if m in vyvod:
            return 'лишний маркер вывода: %r' % m
    return None


def sud_kejs(imja, kejs, src, subj_doc, model_doc, model_tela, koren):
    tip = kejs['tip']
    ozh = kejs['ozhidanie']
    if tip == 'replay':
        telo = telo_shaga(subj_doc, src, kejs['shag'])
        if telo is None:
            return ('KRASNO', 'SHAG_%s_NET' % kejs['shag'])
        prichiny = []
        for okr in ('CHISTYJ', 'ACTIONS'):
            fakt, osh = ispolnit_replay(telo, kejs['shag'], kejs['scena'], okr, koren)
            if osh:
                return ('KRASNO', osh)
            p = sravnit_replay(fakt, ozh)
            if p:
                prichiny.append('%s: %s' % (okr, p))
        if prichiny:
            return ('KRASNO', prichiny[0])
        return ('ok', None)
    if tip == 'struktura':
        podtip = kejs['podtip']
        if podtip == 'upravlenie-job':
            return upravlenie_job(subj_doc, src, model_doc)
        if podtip == 'upravlenie-workflow':
            return upravlenie_workflow(subj_doc, model_doc)
        nomer = kejs['shag']
        if podtip == 'upravlenie-shag':
            return upravlenie_shaga(subj_doc, src, nomer, model_doc)
        telo = telo_shaga(subj_doc, src, nomer)
        if telo is None:
            return ('KRASNO', 'SHAG_%s_NET' % nomer)
        if podtip == 'kanon':
            r = kanon_rashozhdenie(telo, model_tela[nomer])
            if r:
                return ('KRASNO', 'SKRIPT_RASHOZHDENIE: shag %s: строка %d: %r ≠ %r'
                        % (nomer, r[0], r[1], r[2]))
            return ('ok', None)
        if podtip == 'pereformat':
            stroki = model_tela[nomer].split('\n')
            sdelannyj = '\n'.join([stroki[0], '    # контроль 141: формат свободен', ''] + stroki[1:])
            r = kanon_rashozhdenie(sdelannyj, model_tela[nomer])
            if r:
                return ('KRASNO', 'PEREFORMAT_KRASNEN: строка %d' % r[0])
            return ('ok', None)
        if podtip == 'signatura':
            kanon = src['signatury_regex']
            n = telo.count(kanon)
            if n != src['signatur_vstrech'][nomer]:
                return ('KRASNO', 'PODMENA_SIGNATURY: вхождений канона %d, ожидалось %d'
                        % (n, src['signatur_vstrech'][nomer]))
            ostavshijsja = telo.replace(kanon, '')
            for s in src['signatury_ostatok_zapret']:
                if s in ostavshijsja:
                    return ('KRASNO', 'PODMENA_SIGNATURY: обрывок сигнатуры вне канона: %r' % s)
            return ('ok', None)
        if podtip == 'vyrazhenija':
            telo995 = telo_shaga(subj_doc, src, '995')
            if telo995 is None:
                return ('KRASNO', 'SHAG_995_NET')
            for v in VYRAZHENIE_RE.findall(telo995):
                if v not in src['alfavit_vyrazhenij']:
                    return ('KRASNO', 'VYRAZHENIE_VNE_ALFAVITA: %s' % v)
            return ('ok', None)
    if tip == 'derevo':
        podtip = kejs['podtip']
        if podtip == 'bez-141':
            tekst = (NOSITELI / 'mobile-bez-141.yml').read_text(encoding='utf-8')
            doc = yaml.safe_load(tekst)
            telo = telo_shaga(doc, src, '135')
            if telo is None:
                return ('KRASNO', 'SHAG_135_NET')
            r = kanon_rashozhdenie(telo, model_tela['135'])
            if r:
                return ('KRASNO', 'SKRIPT_RASHOZHDENIE: shag 135: строка %d: %r ≠ %r'
                        % (r[0], r[1], r[2]))
            return ('KRASNO', 'OZHIDALOS_KRASNO: носитель без правки 141 прошёл канон')
        if podtip == 'chuzhoj-shag':
            doc = copy.deepcopy(model_doc)
            # v2 (143): шаг 123 живёт в своей задаче e2e-splash — правка
            # чужого шага чужой задачи батарею не краснит
            for s in doc['jobs']['e2e-splash']['steps']:
                if isinstance(s.get('name'), str) and s['name'].startswith('123 сверка кадров'):
                    s['run'] = s['run'] + '\n          echo kontrol 141'
                    break
            else:
                return ('KRASNO', 'ORACLE_TAMPERED: шаг 123 не найден в модели')
            for n in ('135', '118', '995'):
                telo = telo_shaga(doc, src, n)
                if telo is None or kanon_rashozhdenie(telo, model_tela[n]):
                    return ('KRASNO', 'CHUZHOJ_SHAG_SUDITSJA: %s' % n)
            return ('ok', None)
        if podtip == 'zakonnaja-pravka':
            # все клетки батареи (кроме самой себя — иначе рекурсия) обязаны
            # быть зелеными на дереве с законными правками job: J1–J3/W1–W2
            # не краснят зелёные/несудимые ключи, тела шагов не тронуты
            doc = postavit_derevo(model_doc, src)
            src_vnutr = dict(src)
            src_vnutr['kejsy'] = {k: v for k, v in src['kejsy'].items()
                                  if k != imja}
            rc, _ = progona(None, src_vnutr, model_doc, model_tela, koren,
                            pechatat=False, subj_doc_gotovyj=doc)
            if rc != 0:
                return ('KRASNO', 'ZAKONNAJA_PRAVKA_KRASNEN: законная '
                        'правка job краснит батарею')
            return ('ok', None)
        if podtip == 'shag-net':
            doc = copy.deepcopy(model_doc)
            imja = src['shagi']['135']
            doc['jobs'][src['job_imja']['135']]['steps'] = [
                s for s in shagi_doc(doc, src, '135')
                if not (isinstance(s.get('name'), str) and s['name'].startswith(imja))]
            if telo_shaga(doc, src, '135') is not None:
                return ('KRASNO', 'OZHIDALOS_SHAG_NET: шаг 135 всё ещё находится')
            return ('KRASNO', 'SHAG_135_NET')
        if podtip == 'rebro-net':
            # v2-испр. 1 (needs-ребро): у ОДНОГО носителя (параметр shag)
            # из needs удалено ТОЛЬКО ребро select-screens — if и тела
            # неизменны; обход критика 141 v2 1/2 обязан краснеть у
            # КАЖДОГО носителя порознь (ранний возврат по 135 не маскирует).
            doc = copy.deepcopy(model_doc)
            imja_joba = src['job_imja'][kejs['shag']]
            doc['jobs'][imja_joba]['needs'] = [
                n for n in doc['jobs'][imja_joba]['needs']
                if n != JOB_IF_REBRO]
            ishod, prichina = upravlenie_job(doc, src, model_doc)
            if ishod != 'KRASNO' or not (prichina or '').startswith('REBRO_NEEDS'):
                return ('KRASNO', 'OZHIDALOS_REBRO_KRASNO: %s/%s'
                        % (ishod, prichina))
            return ('KRASNO', prichina)
        if podtip == 'rebro-ne-spisok':
            # v2-испр. 1: needs строкой/выражением вместо списка — обе
            # формы-ловушки: вхождение имени 'select-screens' есть (поиск
            # подстроки прошёл бы), GH видит одно имя работы — отказ
            # fail-closed на КАЖДОЙ форме (не первая красная точка).
            doc = copy.deepcopy(model_doc)
            imja_joba = src['job_imja']['135']
            for lovnushka in ('select-screens, build-apk',
                              "${{ fromJSON('[\"select-screens\",\"build-apk\"]') }}"):
                doc['jobs'][imja_joba]['needs'] = lovnushka
                ishod, prichina = upravlenie_job(doc, src, model_doc)
                if ishod != 'KRASNO' or not (prichina or '').startswith('REBRO_NEEDS'):
                    return ('KRASNO', 'OZHIDALOS_REBRO_KRASNO (%r): %s/%s'
                            % (lovnushka, ishod, prichina))
            return ('KRASNO', 'REBRO_NEEDS: job %s: needs строкой/выражением '
                    'вместо списка — отказ fail-closed (канон 143 И-3 '
                    '(модель): needs=%r)'
                    % (imja_joba, model_doc['jobs'][imja_joba]['needs']))
        if podtip == 'rebro-pusto':
            # v2-испр. 1: if выбора сохранён, needs пуст — пустой список и
            # отсутствие ключа; контекст выбора невозможен; обе формы
            # проверяются порознь.
            imja_joba = src['job_imja']['135']
            for pusto, metka in (([], '[]'), (None, 'нет ключа')):
                doc = copy.deepcopy(model_doc)
                if pusto is None:
                    del doc['jobs'][imja_joba]['needs']
                else:
                    doc['jobs'][imja_joba]['needs'] = pusto
                ishod, prichina = upravlenie_job(doc, src, model_doc)
                if ishod != 'KRASNO' or not (prichina or '').startswith('REBRO_NEEDS'):
                    return ('KRASNO', 'OZHIDALOS_REBRO_KRASNO (needs=%s): '
                            '%s/%s' % (metka, ishod, prichina))
            return ('KRASNO', 'REBRO_NEEDS: job %s: needs пуст при '
                    'каноническом if выбора — контекст выбора невозможен '
                    '(канон 143 И-3 (модель): needs=%r)'
                    % (imja_joba, model_doc['jobs'][imja_joba]['needs']))
    return ('KRASNO', 'неизвестный tip')


# --- обманные стабы (Н-39: мутации КОДОМ, привязки — stab_vhod) --------------

def _zameni(t, staryj, novyj, vhozhdenie=1):
    chasti = t.split(staryj)
    if len(chasti) <= vhozhdenie:
        raise RuntimeError('цель мутации не найдена (вхождений %d, нужно %d): %r'
                           % (len(chasti) - 1, vhozhdenie, staryj[:60]))
    return staryj.join(chasti[:vhozhdenie]) + novyj + staryj.join(chasti[vhozhdenie:])


def _zameni_edinstvennoe(t, staryj, novyj):
    """Замена ровно одного вхождения (арбитраж 141: мутации — вставки/
    замены с единственным вхождением цели; размноженная цель — отказ)."""
    if t.count(staryj) != 1:
        raise RuntimeError('цель замены не единственна (вхождений %d): %r'
                           % (t.count(staryj), staryj[:60]))
    return t.replace(staryj, novyj)


def _najti_blok_texta(lines, imja):
    n = len(lines)
    i_shag = None
    for i in range(n):
        if lines[i].startswith('      - name: ') and lines[i][14:].startswith(imja):
            i_shag = i
            break
    if i_shag is None:
        raise RuntimeError('шаг мутации не найден: %s' % imja)
    i_run = None
    for i in range(i_shag + 1, n):
        if lines[i] == '        run: |':
            i_run = i
            break
        if lines[i].startswith('      - name: '):
            raise RuntimeError('run: | не найден у шага %s' % imja)
    if i_run is None:
        raise RuntimeError('run: | не найден у шага %s' % imja)
    i_konec = i_run + 1
    while i_konec < n and (lines[i_konec].startswith('          ') or lines[i_konec] == ''):
        i_konec += 1
    return i_run, i_konec


def mutiruj_shag(t, imja, fn):
    lines = t.split('\n')
    i_run, i_konec = _najti_blok_texta(lines, imja)
    telo = '\n'.join(l[10:] if l.startswith(' ' * 10) else l
                     for l in lines[i_run + 1:i_konec])
    telo2 = fn(telo.rstrip('\n'))
    novye = ['        run: |'] + ['          ' + s for s in telo2.split('\n')]
    lines[i_run:i_konec] = novye
    return '\n'.join(lines)


def _klyuchi_shaga(t, imja, stroki):
    """Вставка строк-ключей шага (отступ 8) сразу после `- name:` целевого
    шага — мутация УПРАВЛЯЮЩИХ свойств (исправительный проход Critic141):
    модель минус защита «замкнутый алфавит ключей шага»."""
    lines = t.split('\n')
    for i, l in enumerate(lines):
        if l.startswith('      - name: ') and l[14:].startswith(imja):
            lines[i + 1:i + 1] = stroki
            return '\n'.join(lines)
    raise RuntimeError('шаг вставки управляющего ключа не найден: %s' % imja)


def _klyuchi_raboty(t, imja, stroki):
    """Вставка строк-ключей работы (отступ 4) сразу после заголовка
    `  <imja>:` — мутация управляющих свойств уровня job (арбитраж 141:
    сам android-e2e и upstream-работы цепи needs)."""
    zagolovok = '  %s:' % imja
    lines = t.split('\n')
    for i, l in enumerate(lines):
        if l == zagolovok:
            lines[i + 1:i + 1] = stroki
            return '\n'.join(lines)
    raise RuntimeError('работа %s не найдена для вставки ключа' % imja)


def _klyuchi_joba(t, stroki):
    """Вставка строк-ключей job (отступ 4) сразу после заголовка работы —
    v2 (143): мутация job-различителей задачи-носителя шага 135
    (e2e-first-run), не монолита android-e2e."""
    return _klyuchi_raboty(t, 'e2e-first-run', stroki)


def _v_rabote(t, imja, staryj, novyj):
    """Замена внутри блока ОДНОЙ работы (v2): `timeout-minutes: 40` в
    разделённом DAG не уникален в файле (он у всех работников) — цель
    мутации ограничивается блоком задачи-носителя."""
    lines = t.split('\n')
    nachalo = None
    for i, l in enumerate(lines):
        if l == '  %s:' % imja:
            nachalo = i + 1
            break
    if nachalo is None:
        raise RuntimeError('работа %s не найдена' % imja)
    konec = len(lines)
    for i in range(nachalo, len(lines)):
        if lines[i].startswith('  ') and not lines[i].startswith('   '):
            konec = i
            break
    blok = '\n'.join(lines[nachalo:konec])
    if blok.count(staryj) != 1:
        raise RuntimeError('цель в блоке %s не единственна (вхождений %d): %r'
                           % (imja, blok.count(staryj), staryj[:40]))
    lines[nachalo:konec] = blok.replace(staryj, novyj).split('\n')
    return '\n'.join(lines)


def _klyuchi_workflow(t, stroki, jakor, posle=False):
    """Вставка строк top-level workflow (арбитраж 141: W1/W2) — перед
    строкой-якорем либо после неё; якорь обязан встретиться буквально."""
    lines = t.split('\n')
    for i, l in enumerate(lines):
        if l == jakor:
            mesto = i + 1 if posle else i
            lines[mesto:mesto] = stroki
            return '\n'.join(lines)
    raise RuntimeError('якорь вставки workflow не найден: %s' % jakor)


KANON_MUT = None  # резолвится при загрузке source.json


def _kanon():
    return KANON_MUT


def m_bez_signaturnogo_filtra_135(b):
    return _zameni(b, "grep -rqE '" + _kanon() + "'", "grep -rqE '.*'")


def m_signatura_suzhena_135(b):
    return _zameni(b, _kanon(), 'device offline', 2)


def m_signatura_rasshirena_135(b):
    return _zameni(b, _kanon(), _kanon() + '|INSTALL_FAILED', 2)


def m_dva_povtora_135(b):
    return _zameni(b, '[ "$rc" -eq 0 ] || exit "$rc"',
                   'if [ "$rc" -ne 0 ]; then boot135; set +e; run_priemka135; rc=$?; set -e; fi\n'
                   '[ "$rc" -eq 0 ] || exit "$rc"')


def m_bez_diag_135(b):
    return _zameni(b, 'if [ "$rc" -ne 0 ]; then\n  diag135\n', 'if [ "$rc" -ne 0 ]; then\n')


def m_diag_zaglushen_135(b):
    return _zameni(b, 'echo "ДИАГНОСТИКА 135: adb devices" >&2',
                   'echo "ДИАГНОСТИКА 135: adb devices" >/dev/null')


def m_adb_glotnuto_135(b):
    return _zameni(b, 'adb devices >&2 || true', 'adb devices >/dev/null 2>&1 || true')


def m_tail_korotkij_135(b):
    return _zameni(b, 'tail -n 40 "emulator-$AVD.log" >&2', 'tail -n 5 "emulator-$AVD.log" >&2')


def m_emulator_log_uterjan_135(b):
    return _zameni(b, '>"emulator-$AVD.log" 2>&1 &', '>/dev/null 2>&1 &')


def m_povtor_bez_perezapuska_135(b):
    return _zameni(b, 'if ! boot135; then diag135; exit 1; fi', ':', 2)


def m_bez_itoga_stabil_135(b):
    return _zameni(b, 'if [ "$ok" -lt 3 ]; then', 'if false; then')


def m_boot_bez_diag_135(b):
    return _zameni(b, 'if ! boot135; then diag135; exit 1; fi',
                   'if ! boot135; then exit 1; fi')


def m_podmena_signatury_diag_135(b):
    return _zameni(b, _kanon(), 'device offline|DeviceServerDiedException', 1)


def m_kanon_stroka_135(b):
    return _zameni(b, '[ "$ok" -ge 3 ] && break', '[ "$ok" -ge 4 ] && break')


def m_bez_povtora_118(b):
    return _zameni(b, "if grep -rqE '" + _kanon() + "'", "if false && grep -rqE '" + _kanon() + "'")


def m_dva_povtora_118(b):
    return _zameni(b, '[ "$rc" -eq 0 ] || exit "$rc"',
                   'if [ "$rc" -ne 0 ]; then boot118; set +e; run_priemka118; rc=$?; set -e; fi\n'
                   '[ "$rc" -eq 0 ] || exit "$rc"')


def m_bez_diag_118(b):
    return _zameni(b, 'if [ "$rc" -ne 0 ]; then\n  diag118\n', 'if [ "$rc" -ne 0 ]; then\n')


def m_bez_itoga_stabil_118(b):
    return _zameni(b, 'if [ "$ok" -lt 3 ]; then', 'if false; then')


def m_podmena_signatury_diag_118(b):
    return _zameni(b, _kanon(), 'device offline|adb: device not found', 1)


def m_kanon_stroka_118(b):
    return _zameni(b, '[ "$ok" -ge 3 ] && break', '[ "$ok" -ge 4 ] && break')


def m_995_bez_diag(b):
    return _zameni(b, 'if [ "$rc" -ne 0 ]; then', 'if false; then')


def m_995_shagovoj_povtor(b):
    return _zameni(b, '[ "$rc" -eq 0 ] || exit "$rc"',
                   'if [ "$rc" -ne 0 ] && grep -rq "device offline" mobile/maestro-out; then\n'
                   '  set +e\n'
                   '  python3 .harness/fixtures/workshop_project/pilot_995/maestro_probe.py --repo . --out mobile/maestro-out\n'
                   '  rc=$?\n'
                   '  set -e\n'
                   'fi\n'
                   '[ "$rc" -eq 0 ] || exit "$rc"')


def m_995_adb_glotnuto(b):
    return _zameni(b, 'adb devices >&2 || true', 'adb devices >/dev/null 2>&1 || true')


def m_podmena_signatury_diag_995(b):
    return _zameni(b, _kanon(), 'device offline|DeviceServerDiedException', 1)


def m_kanon_stroka_995(b):
    return _zameni(b, '--code-file /tmp/impl995-pilot-private-${{ github.run_id }}-${{ github.run_attempt }}/code',
                   '--code-file /tmp/impl995-pilot-private-${{ github.run_attempt }}-${{ github.run_id }}/code')


def m_vyrazhenie_vne_alfavita(b):
    return _zameni(b, '--repo ${{ github.workspace }}', '--repo ${{ secrets.PILOT_DEMO_CODE }}')


def m_upr_if_false_135(b):
    # свидетель критика 1/2 дословно: if: ${{ false }} на шаге 135,
    # run: байт-в-байт моделью — шаг никогда не исполняется.
    return _klyuchi_shaga(b, '135 first-run-ekran',
                          ['        if: ${{ false }}'])


def m_upr_timeout_0_135(b):
    return _klyuchi_shaga(b, '135 first-run-ekran',
                          ['        timeout-minutes: 0'])


def m_upr_env_path_135(b):
    return _klyuchi_shaga(b, '135 first-run-ekran',
                          ['        env:', '          PATH: /nonexistent-141'])


def m_upr_uses_135(b):
    # шаг-run не может получить uses (исполнение подменяется действием)
    return _klyuchi_shaga(b, '135 first-run-ekran',
                          ['        uses: actions/checkout@v4'])


def m_upr_if_literal_118(b):
    return _klyuchi_shaga(b, '118 erstinformation', ['        if: false'])


def m_upr_shell_118(b):
    # шаблон оболочки, глотающий код возврата тела
    return _klyuchi_shaga(b, '118 erstinformation',
                          ["        shell: 'bash {0} || true'"])


def m_upr_if_always_995(b):
    return _klyuchi_shaga(b, 'Maestro runner для CMP-MOB-001',
                          ['        if: always() && false'])


def m_upr_continue_995(b):
    return _klyuchi_shaga(b, 'Maestro runner для CMP-MOB-001',
                          ['        continue-on-error: true'])


def m_upr_job_if_false(b):
    # v2 (143): у работника уже есть канонический if выбора — мутация
    # подменяет его значение ложным литералом (вставка продублировала бы
    # ключ; канон строки — JOB_IF_KANON)
    return _zameni_edinstvennoe(b, '    if: ' + JOB_IF_KANON % 'e2e-first-run',
                                '    if: false')


def m_upr_job_continue(b):
    return _klyuchi_joba(b, ['    continue-on-error: true'])


def m_upr_job_env_path(b):
    return _klyuchi_joba(b, ['    env:', '      PATH: /nonexistent-141'])


def m_upr_job_continue_vyrazhenie(b):
    # свидетель критика 2/2 дословно (мутант №1 арбитража): выражение в
    # continue-on-error — зелёное для whitelisted-различителей значений
    # 141b, красное алфавитом ключей J1.
    return _klyuchi_joba(b, ['    continue-on-error: ${{ true }}'])


def m_upr_job_matrix_continue(b):
    # мутант №3: документированная форма GH (strategy.matrix) + выражение
    return _klyuchi_joba(b, ['    strategy:', '      matrix:', '        exp: [true]',
                             '    continue-on-error: ${{ matrix.exp }}'])


def m_upr_job_if_dinam(b):
    # мутант №7: динамическое if — ложь вне статического семейства 141b;
    # v2: подмена канонического if выбора работника динамическим выражением
    return _zameni_edinstvennoe(b, '    if: ' + JOB_IF_KANON % 'e2e-first-run',
                                "    if: ${{ github.event_name == 'never' }}")


def m_upr_job_defaults_shell(b):
    # мутант №11: job-defaults с подменяющим исполнение shell
    return _klyuchi_joba(b, ['    defaults:', '      run:', "        shell: 'true {0}'"])


def m_upr_job_env_bash_env(b):
    # мутант №14: инъекция в bash до тела (BASH_ENV: exit(){ :; })
    return _klyuchi_joba(b, ['    env:', '      BASH_ENV: /tmp/x.sh'])


def m_upr_job_timeout_vyrazhenie(b):
    # мутант №19: выражение вместо целого — тип не судился в 141b; v2:
    # цель ограничена блоком задачи-носителя (в разделённом DAG
    # timeout-minutes: 40 не уникален в файле)
    return _v_rabote(b, 'e2e-first-run', 'timeout-minutes: 40',
                     'timeout-minutes: ${{ 0 }}')


def m_upr_quality_if_false(b):
    # мутант №22: upstream quality с if — android-e2e пропускается needs
    return _klyuchi_raboty(b, 'quality', ['    if: ${{ false }}'])


def m_upr_job_rebro_135_net(b):
    # v2-испр. 1 (блокер вердикта критика 141 v2 1/2): ребро select-screens
    # удалено из needs носителя 135 — if и тела байт-в-байт, работа не
    # выбирается по селектору. Цель ограничена блоком задачи (строка needs
    # в файле не уникальна — она у всех работников 143).
    return _v_rabote(b, 'e2e-first-run',
                     'needs: [select-screens, build-apk]',
                     'needs: [build-apk]')


def m_upr_job_rebro_118_net(b):
    # то же у носителя 118: проверка доходит до КАЖДОГО из трёх носителей —
    # возврат по первому отказу (135) не маскирует остальные.
    return _v_rabote(b, 'e2e-erstinformation',
                     'needs: [select-screens, build-apk]',
                     'needs: [build-apk]')


def m_upr_job_rebro_995_net(b):
    # то же у носителя 995 (e2e-pilot).
    return _v_rabote(b, 'e2e-pilot',
                     'needs: [select-screens, build-apk]',
                     'needs: [build-apk]')


def m_upr_job_rebro_ne_spisok(b):
    # needs строкой-ловушкой вместо списка: вхождение имени 'select-screens'
    # есть (поиск подстроки прошёл бы), GH видит одно имя работы — отказ
    # fail-closed, не семантика вхождения.
    return _v_rabote(b, 'e2e-first-run',
                     'needs: [select-screens, build-apk]',
                     'needs: select-screens, build-apk')


def m_upr_job_rebro_pusto(b):
    # if выбора сохранён, needs пуст — контекст выбора невозможен.
    return _v_rabote(b, 'e2e-first-run',
                     'needs: [select-screens, build-apk]',
                     'needs: []')


def m_upr_workflow_defaults_shell(b):
    # мутант №13: top-level defaults.run.shell подменяет исполнение тел
    return _klyuchi_workflow(b, ["    shell: 'cat {0}'"],
                             '    working-directory: mobile', posle=True)


def m_upr_workflow_env_bash_env(b):
    # мутант №17: top-level env вне модели — тот же класс уровнем выше
    return _klyuchi_workflow(b, ['env:', '  BASH_ENV: /tmp/x.sh'], 'defaults:')


def sdelat_stab(imja, model_tekst, kanon):
    global KANON_MUT
    KANON_MUT = kanon
    try:
        if imja == 's-shag-pereimenovan-135':
            return _zameni(model_tekst, '- name: 135 first-run-ekran', '- name: 135 first-run')
        UPRAV_MUTACII = {
            's-upr-if-false-135': m_upr_if_false_135,
            's-upr-timeout-0-135': m_upr_timeout_0_135,
            's-upr-env-path-135': m_upr_env_path_135,
            's-upr-uses-135': m_upr_uses_135,
            's-upr-if-literal-118': m_upr_if_literal_118,
            's-upr-shell-118': m_upr_shell_118,
            's-upr-if-always-995': m_upr_if_always_995,
            's-upr-continue-995': m_upr_continue_995,
            's-upr-job-if-false': m_upr_job_if_false,
            's-upr-job-continue': m_upr_job_continue,
            's-upr-job-env-path': m_upr_job_env_path,
            's-upr-job-continue-vyrazhenie': m_upr_job_continue_vyrazhenie,
            's-upr-job-matrix-continue': m_upr_job_matrix_continue,
            's-upr-job-if-dinam': m_upr_job_if_dinam,
            's-upr-job-defaults-shell': m_upr_job_defaults_shell,
            's-upr-job-env-bash-env': m_upr_job_env_bash_env,
            's-upr-job-timeout-vyrazhenie': m_upr_job_timeout_vyrazhenie,
            's-upr-job-rebro-135-net': m_upr_job_rebro_135_net,
            's-upr-job-rebro-118-net': m_upr_job_rebro_118_net,
            's-upr-job-rebro-995-net': m_upr_job_rebro_995_net,
            's-upr-job-rebro-ne-spisok': m_upr_job_rebro_ne_spisok,
            's-upr-job-rebro-pusto': m_upr_job_rebro_pusto,
            's-upr-quality-if-false': m_upr_quality_if_false,
            's-upr-workflow-defaults-shell': m_upr_workflow_defaults_shell,
            's-upr-workflow-env-bash-env': m_upr_workflow_env_bash_env,
        }
        if imja in UPRAV_MUTACII:
            return UPRAV_MUTACII[imja](model_tekst)
        SHAGI_MUT = {
            '135 first-run-ekran': (
                's-bez-signaturnogo-filtra-135', 's-signatura-suzhena-135',
                's-signatura-rasshirena-135', 's-dva-povtora-135', 's-bez-diag-135',
                's-diag-zaglushen-135', 's-adb-glotnuto-135', 's-tail-korotkij-135',
                's-emulator-log-uterjan-135', 's-povtor-bez-perezapuska-135',
                's-bez-itoga-stabil-135', 's-boot-bez-diag-135',
                's-podmena-signatury-diag-135', 's-kanon-stroka-135'),
            '118 erstinformation': (
                's-bez-povtora-118', 's-dva-povtora-118', 's-bez-diag-118',
                's-bez-itoga-stabil-118', 's-podmena-signatury-diag-118',
                's-kanon-stroka-118'),
            'Maestro runner для CMP-MOB-001': (
                's-995-bez-diag', 's-995-shagovoj-povtor', 's-995-adb-glotnuto',
                's-podmena-signatury-diag-995', 's-kanon-stroka-995',
                's-vyrazhenie-vne-alfavita'),
        }
        FUNKCII = {
            's-bez-signaturnogo-filtra-135': m_bez_signaturnogo_filtra_135,
            's-signatura-suzhena-135': m_signatura_suzhena_135,
            's-signatura-rasshirena-135': m_signatura_rasshirena_135,
            's-dva-povtora-135': m_dva_povtora_135,
            's-bez-diag-135': m_bez_diag_135,
            's-diag-zaglushen-135': m_diag_zaglushen_135,
            's-adb-glotnuto-135': m_adb_glotnuto_135,
            's-tail-korotkij-135': m_tail_korotkij_135,
            's-emulator-log-uterjan-135': m_emulator_log_uterjan_135,
            's-povtor-bez-perezapuska-135': m_povtor_bez_perezapuska_135,
            's-bez-itoga-stabil-135': m_bez_itoga_stabil_135,
            's-boot-bez-diag-135': m_boot_bez_diag_135,
            's-podmena-signatury-diag-135': m_podmena_signatury_diag_135,
            's-kanon-stroka-135': m_kanon_stroka_135,
            's-bez-povtora-118': m_bez_povtora_118,
            's-dva-povtora-118': m_dva_povtora_118,
            's-bez-diag-118': m_bez_diag_118,
            's-bez-itoga-stabil-118': m_bez_itoga_stabil_118,
            's-podmena-signatury-diag-118': m_podmena_signatury_diag_118,
            's-kanon-stroka-118': m_kanon_stroka_118,
            's-995-bez-diag': m_995_bez_diag,
            's-995-shagovoj-povtor': m_995_shagovoj_povtor,
            's-995-adb-glotnuto': m_995_adb_glotnuto,
            's-podmena-signatury-diag-995': m_podmena_signatury_diag_995,
            's-kanon-stroka-995': m_kanon_stroka_995,
            's-vyrazhenie-vne-alfavita': m_vyrazhenie_vne_alfavita,
        }
        for imja_shaga, imena in SHAGI_MUT.items():
            if imja in imena:
                return mutiruj_shag(model_tekst, imja_shaga, FUNKCII[imja])
        raise RuntimeError('неизвестный стаб: %s' % imja)
    except (RuntimeError, ValueError) as e:
        print('ORACLE_TAMPERED: стаб %s: %s' % (imja, e), file=sys.stderr)
        return None


STAB_MUTACII = {
    's-bez-signaturnogo-filtra-135': m_bez_signaturnogo_filtra_135,
    's-signatura-suzhena-135': m_signatura_suzhena_135,
    's-signatura-rasshirena-135': m_signatura_rasshirena_135,
    's-dva-povtora-135': m_dva_povtora_135,
    's-bez-diag-135': m_bez_diag_135,
    's-diag-zaglushen-135': m_diag_zaglushen_135,
    's-adb-glotnuto-135': m_adb_glotnuto_135,
    's-tail-korotkij-135': m_tail_korotkij_135,
    's-emulator-log-uterjan-135': m_emulator_log_uterjan_135,
    's-povtor-bez-perezapuska-135': m_povtor_bez_perezapuska_135,
    's-bez-itoga-stabil-135': m_bez_itoga_stabil_135,
    's-boot-bez-diag-135': m_boot_bez_diag_135,
    's-podmena-signatury-diag-135': m_podmena_signatury_diag_135,
    's-kanon-stroka-135': m_kanon_stroka_135,
    's-bez-povtora-118': m_bez_povtora_118,
    's-dva-povtora-118': m_dva_povtora_118,
    's-bez-diag-118': m_bez_diag_118,
    's-bez-itoga-stabil-118': m_bez_itoga_stabil_118,
    's-podmena-signatury-diag-118': m_podmena_signatury_diag_118,
    's-kanon-stroka-118': m_kanon_stroka_118,
    's-995-bez-diag': m_995_bez_diag,
    's-995-shagovoj-povtor': m_995_shagovoj_povtor,
    's-995-adb-glotnuto': m_995_adb_glotnuto,
    's-podmena-signatury-diag-995': m_podmena_signatury_diag_995,
    's-kanon-stroka-995': m_kanon_stroka_995,
    's-vyrazhenie-vne-alfavita': m_vyrazhenie_vne_alfavita,
    's-upr-if-false-135': m_upr_if_false_135,
    's-upr-timeout-0-135': m_upr_timeout_0_135,
    's-upr-env-path-135': m_upr_env_path_135,
    's-upr-uses-135': m_upr_uses_135,
    's-upr-if-literal-118': m_upr_if_literal_118,
    's-upr-shell-118': m_upr_shell_118,
    's-upr-if-always-995': m_upr_if_always_995,
    's-upr-continue-995': m_upr_continue_995,
    's-upr-job-if-false': m_upr_job_if_false,
    's-upr-job-continue': m_upr_job_continue,
    's-upr-job-env-path': m_upr_job_env_path,
    's-upr-job-continue-vyrazhenie': m_upr_job_continue_vyrazhenie,
    's-upr-job-matrix-continue': m_upr_job_matrix_continue,
    's-upr-job-if-dinam': m_upr_job_if_dinam,
    's-upr-job-defaults-shell': m_upr_job_defaults_shell,
    's-upr-job-env-bash-env': m_upr_job_env_bash_env,
    's-upr-job-timeout-vyrazhenie': m_upr_job_timeout_vyrazhenie,
    's-upr-job-rebro-135-net': m_upr_job_rebro_135_net,
    's-upr-job-rebro-118-net': m_upr_job_rebro_118_net,
    's-upr-job-rebro-995-net': m_upr_job_rebro_995_net,
    's-upr-job-rebro-ne-spisok': m_upr_job_rebro_ne_spisok,
    's-upr-job-rebro-pusto': m_upr_job_rebro_pusto,
    's-upr-quality-if-false': m_upr_quality_if_false,
    's-upr-workflow-defaults-shell': m_upr_workflow_defaults_shell,
    's-upr-workflow-env-bash-env': m_upr_workflow_env_bash_env,
    's-shag-pereimenovan-135': lambda b: b,  # текстовая мутация имени шага
}


# --- прогон ------------------------------------------------------------------

def zagruzit_model(src):
    model_bajty = MODEL.read_bytes()
    if sha256_bytes(model_bajty) != src['nositeli'][MODEL_PIN_KEY]:
        raise RuntimeError('пин model/mobile.yml не сходится')
    tekst = model_bajty.decode('utf-8')
    doc = yaml.safe_load(tekst)
    tela = {n: telo_shaga(doc, src, n) for n in ('135', '118', '995')}
    if any(t is None for t in tela.values()):
        raise RuntimeError('в модели нет одного из шагов 135/118/995')
    return tekst, doc, tela


def progona(subject_tekst, src, model_doc, model_tela, koren, pechatat=True,
            subj_doc_gotovyj=None):
    if subj_doc_gotovyj is not None:
        subj_doc = subj_doc_gotovyj
    else:
        try:
            subj_doc = yaml.safe_load(subject_tekst)
        except yaml.YAMLError as e:
            print('MOBILE_YML_NERAZBORIM: %s' % e, file=sys.stderr)
            return 1, {}
    itogi = {}
    krasnye = 0
    for imja, kejs in src['kejsy'].items():
        ishod, prichina = sud_kejs(imja, kejs, src, subj_doc, model_doc,
                                   model_tela, koren)
        ozh_krasno = kejs.get('ozhidanie', {}).get('krasno')
        if ozh_krasno:
            if ishod == 'KRASNO' and prichina and prichina.startswith(ozh_krasno):
                itogi[imja] = ('ok', prichina)
            else:
                itogi[imja] = ('KRASNO', 'ожидался отказ %r, получено %s/%s'
                               % (ozh_krasno, ishod, prichina))
        else:
            itogi[imja] = (ishod, prichina)
        if itogi[imja][0] == 'KRASNO':
            krasnye += 1
        if pechatat:
            if itogi[imja][0] == 'ok':
                print('CASE %s ok' % imja)
            else:
                print('CASE %s KRASNO (%s)' % (imja, itogi[imja][1]))
    return (0 if krasnye == 0 else 1), itogi


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    ap.add_argument('--repo')
    args, _ = ap.parse_known_args()

    try:
        src = load_source()
        if set(src['kejsy']) != set(list(src['kejsy'])):
            raise RuntimeError('дубли кейсов')
        for k, svjazi in src['stab_vhod'].items():
            for v in svjazi:
                if v not in src['kejsy']:
                    raise RuntimeError('стаб %s связан с неизвестным входом %s' % (k, v))
        nositel = NOSITELI / 'mobile-bez-141.yml'
        if sha256_bytes(nositel.read_bytes()) != src['nositeli']['mobile-bez-141.yml']:
            raise RuntimeError('пин носителя mobile-bez-141.yml не сходится')
        model_tekst, model_doc, model_tela = zagruzit_model(src)
    except (RuntimeError, OSError, KeyError) as e:
        return oshibka_orakula(str(e))

    koren = Path(tempfile.mkdtemp(prefix='baterija141-'))

    subj_tekst = None
    rezhim_subjekta = None
    if args.model:
        subj_tekst = model_tekst
        rezhim_subjekta = 'model'
    elif args.stabs or args.matrix:
        rezhim_subjekta = 'stabs'
    else:
        repo = args.repo or os.environ.get('MOB_REPO')
        if repo:
            put = Path(repo) / SUBJECT_REL
            if not put.is_file():
                print('SUBJECT_ABSENT: %s не найден; входы ниже красные' % put, file=sys.stderr)
            else:
                subj_tekst = put.read_text(encoding='utf-8')
                rezhim_subjekta = 'repo'
        else:
            rezhim_subjekta = 'net'

    if rezhim_subjekta == 'stabs':
        rc_kontrol, itogi = progona(model_tekst, src, model_doc, model_tela, koren)
        if rc_kontrol != 0:
            print('ORACLE_TAMPERED: контроль модели не зелёный', file=sys.stderr)
            return 2
        svjazi_itog = 0
        zhivye = 0
        for imja_staba in sorted(src['stab_vhod']):
            mutirovannyj = sdelat_stab(imja_staba, model_tekst, src['signatury_regex'])
            if mutirovannyj is None:
                return 2
            try:
                stab_doc = yaml.safe_load(mutirovannyj)
            except yaml.YAMLError as e:
                print('ORACLE_TAMPERED: стаб %s даёт неразборный yaml: %s' % (imja_staba, e),
                      file=sys.stderr)
                return 2
            for vhod in src['stab_vhod'][imja_staba]:
                ishod, prichina = sud_kejs(vhod, src['kejsy'][vhod], src, stab_doc,
                                           model_doc, model_tela, koren)
                kejs = src['kejsy'][vhod]
                ozh_krasno = kejs.get('ozhidanie', {}).get('krasno')
                pojman = (ishod == 'KRASNO') if not ozh_krasno else (
                    ishod == 'KRASNO' and prichina and prichina.startswith(ozh_krasno))
                if pojman:
                    print('STAB %s %s KRASEN' % (imja_staba, vhod))
                    svjazi_itog += 1
                else:
                    print('STAB %s %s ZHIV (%s/%s)' % (imja_staba, vhod, ishod, prichina))
                    zhivye += 1
        print('SVJAZI %d' % svjazi_itog)
        print('zhivykh %d' % zhivye)
        return 0 if zhivye == 0 else 1

    if subj_tekst is None:
        prichina = 'SUBJECT_ABSENT'
        if rezhim_subjekta == 'repo' or (not args.model and (args.repo or os.environ.get('MOB_REPO'))):
            prichina = 'MOBILE_YML_OTSUTSTVUET'
        print('SUBJECT_ABSENT: нет субъекта %s; зелень без субъекта невозможна' % SUBJECT_REL,
              file=sys.stderr)
        for imja in src['kejsy']:
            print('CASE %s KRASNO (%s)' % (imja, prichina))
        return 1

    rc, _ = progona(subj_tekst, src, model_doc, model_tela, koren)
    return rc


if __name__ == '__main__':
    sys.exit(main())
