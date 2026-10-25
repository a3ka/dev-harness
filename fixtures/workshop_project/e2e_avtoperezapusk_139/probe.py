#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 139 (§ПРОВОДКА): судит workflow авто-повтора
# android-e2e (файл .github/workflows/mobile-e2e-retry.yml репо продукта)
# статически (YAML: триггер/права/раннер/if/один rerun --failed/секреты/
# закрытый алфавит выражений/канон сигнатур) и ПОВЕДЕНЧЕСКИ: скрипт шага
# исполняется в чистом окружении с подложным gh, ответы которого задаёт
# сценарий кейса (событие workflow_run + jobs API + лог job-а); оракул —
# source.json в памяти ДО вызова субъекта (правило 8), носители — sha256.
# Н-39: обманные стабы — мутации модели КОДОМ (STAB_MUTACII), привязки —
# stab_vhod source.json; рассинхрон множеств — rc 2 ORACLE_TAMPERED.
"""Батарея 139 (e2e-avtoperezapusk): авто-повтор флейка android-e2e внутри CI.

Режимы:
  (без флага)  --repo R отсутствует и MOB_REPO не задан → rc 1 SUBJECT_ABSENT
                с перечнем всех кейсов (зелень без субъекта невозможна);
  (без флага)  --repo R / MOB_REPO → судится живой R/.github/workflows/
                mobile-e2e-retry.yml (+ пин байтов R/.github/workflows/mobile.yml);
  --model      субъект = model/mobile-e2e-retry.yml (контроль входов);
  --stabs      контроль + матрица обманных стабов (SVJAZI N);
  --matrix     синоним --stabs (для арбитража).

Коды возврата: 0 — зелено; 1 — красный кейс либо стаб прошёл (STAB_ZHIV)
либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверять (нет python3-модуля
yaml, ORACLE_TAMPERED, дрейф модели/мутаций).
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml  # pyyaml 6.0.1 — та же версия, что пин 117 в mobile.yml

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model' / 'mobile-e2e-retry.yml'
NOSITELI = HERE / 'nositeli'
SUBJECT_REL = '.github/workflows/mobile-e2e-retry.yml'
MOBILE_YML_REL = '.github/workflows/mobile.yml'
BASH = '/usr/bin/bash' if Path('/usr/bin/bash').is_file() else 'bash'

SHIM_PY = """#!/usr/bin/env python3
# Подложный gh батареи 139: закрытый алфавит команд (см. probe.py), все
# вызовы пишутся в $SCENARIJ_ZAPISI; чужая команда — VNE_ALFAVITA rc 127.
import json
import os
import re
import sys

z = os.environ['SCENARIJ_ZAPISI']
a = sys.argv[1:]


def zap(line):
    with open(z, 'a', encoding='utf-8') as f:
        f.write(line + '\\n')


if len(a) >= 2 and a[0] == 'api':
    path = a[1]
    flt = None
    if '--jq' in a:
        flt = a[a.index('--jq') + 1]
    m = re.match(r'^repos/[^/]+/[^/]+/actions/runs/(\\d+)/jobs$', path)
    if m:
        zap('API_JOBS ' + m.group(1))
        alf = json.loads(os.environ['SCENARIJ_ALFAVIT_ZHK'])
        allowed = alf.values() if isinstance(alf, dict) else alf
        if flt not in allowed:
            sys.stderr.write('FILTER_VNE_ALFAVITA: %r\\n' % flt)
            sys.exit(3)
        data = json.loads(open(
            os.environ['SCENARIJ_JOBS_FAJL'], encoding='utf-8').read())
        for j in data.get('jobs', []):
            if j.get('name') == 'android-e2e' \
                    and j.get('conclusion') == 'failure':
                print(j['id'])
        sys.exit(0)
    m = re.match(r'^repos/[^/]+/[^/]+/actions/jobs/(\\d+)/logs$', path)
    if m:
        zap('API_LOGS ' + m.group(1))
        with open(os.environ['SCENARIJ_LOG'], 'rb') as f:
            sys.stdout.buffer.write(f.read())
        sys.exit(0)
if a[:2] == ['run', 'rerun']:
    if len(a) == 4 and a[2] == '--failed':
        zap('RERUN --failed ' + a[3])
        sys.exit(0)
    if len(a) == 3:
        zap('RERUN ' + a[2])
        sys.exit(0)
zap('VNE_ALFAVITA ' + chr(31).join(a))
sys.exit(127)
"""

VYRAZHENIE_RE = re.compile(r'\$\{\{\s*([^}]+?)\s*\}\}')


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


# --- оракул ------------------------------------------------------------------

def oshibka_orakula(msg):
    print('ORACLE_TAMPERED: %s' % msg, file=sys.stderr)
    return 2


def load_source():
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    for imja, pin in src['nositeli'].items():
        p = NOSITELI / imja
        if not p.is_file():
            return oshibka_orakula('носитель отсутствует: %s' % imja), None
        if sha256_bytes(p.read_bytes()) != pin:
            return oshibka_orakula('sha256 носителя %s' % imja), None
    if not MODEL.is_file():
        return oshibka_orakula('модель отсутствует'), None
    model_tekst = MODEL.read_text(encoding='utf-8')
    if src['signatury_regex'] not in model_tekst:
        return oshibka_orakula('канон сигнатур не в модели'), None
    if set(src['stab_vhod']) != set(STAB_MUTACII):
        return oshibka_orakula('stab_vhod != STAB_MUTACII'), None
    for stab, vhody in src['stab_vhod'].items():
        for v in vhody:
            if v not in src['kejsy']:
                return oshibka_orakula('стаб %s ведёт в несуществующий кейс %s'
                                       % (stab, v)), None
    return 0, src


# --- мутации стабов (Н-39: код, не проза; каждая замена ровно один раз) ------

def _zameni(t, star, novo):
    if t.count(star) != 1:
        raise RuntimeError('мутирование не нашло ровно одно вхождение: %r'
                           % star[:60])
    return t.replace(star, novo)


def m_bez_attempt_guard(t):
    t = _zameni(t, "github.event.workflow_run.conclusion == 'failure' &&\n"
                   "      github.event.workflow_run.run_attempt == 1",
                "github.event.workflow_run.conclusion == 'failure'")
    t = _zameni(t, '          if [ "$ATTEMPT" != "1" ]; then\n'
                   '            echo "SKIP: run_attempt=${ATTEMPT} — повтор уже был"\n'
                   '            exit 0\n'
                   '          fi\n', '')
    return t


def m_bez_signaturnogo_filtra(t):
    """Убирает вырезку эха и фильтр сигнатур: безусловный rerun при любом
    провале android-e2e (стаб оси E «сигнатура сбоя»)."""
    return _zameni_sig(t)


def _zameni_sig(t):
    nach = t.index('          if grep -qE ')
    kon = t.index('"$LOG_F"; then', nach) + len('"$LOG_F"; then')
    return t[:nach] + '          if true; then' + t[kon:]


def m_bez_eho_zaschity(t):
    return _zameni(
        t,
        'printf \'%s\\n\' "$LOG" | sed -e '
        '\'/##\\[group\\]Run /,/##\\[endgroup\\]/d\' > "$LOG_F"',
        'printf \'%s\\n\' "$LOG" > "$LOG_F"')


def m_polnyj_rerun(t):
    return _zameni(t, 'gh run rerun --failed "$RUN_ID"',
                   'gh run rerun "$RUN_ID"')


def m_bez_jobs_filtra(t):
    return _zameni(
        t,
        "--jq '.jobs[] | select(.name == \"android-e2e\" and .conclusion == \"failure\") | .id'",
        "--jq '.jobs[] | select(.conclusion == \"failure\") | .id'")


def m_bez_conclusion_guard(t):
    t = _zameni(t, "github.event.workflow_run.name == 'mobile' &&\n"
                   "      github.event.workflow_run.conclusion == 'failure' &&",
                "github.event.workflow_run.name == 'mobile' &&")
    t = _zameni(t, '          if [ "$CONCLUSION" != "failure" ]; then\n'
                   '            echo "SKIP: conclusion=${CONCLUSION}"\n'
                   '            exit 0\n'
                   '          fi\n', '')
    return t


def m_shirokie_prava(t):
    return _zameni(t, 'permissions:\n  actions: write\n  contents: read',
                   'permissions:\n  actions: write\n  contents: write\n'
                   '  pull-requests: write')


def m_runner_ubuntu(t):
    return _zameni(t, 'runs-on: [self-hosted, linux, x64, complior]',
                   'runs-on: ubuntu-latest')


def m_chuzhoj_trigger(t):
    return _zameni(t, 'workflows: [mobile]', 'workflows: [mobile-cloud-e2e]')


def m_if_bez_uslovij(t):
    return _zameni(
        t,
        "    if: >-\n"
        "      github.event.workflow_run.name == 'mobile' &&\n"
        "      github.event.workflow_run.conclusion == 'failure' &&\n"
        "      github.event.workflow_run.run_attempt == 1",
        '    if: true')


def m_dva_rerun(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"\n'
                      '            exit 0',
                   '            gh run rerun --failed "$RUN_ID"\n'
                   '            gh run rerun --failed "$RUN_ID"\n'
                   '            exit 0')


def m_sekret_v_tekste(t):
    return _zameni(t, 'GH_TOKEN: ${{ github.token }}',
                   'GH_TOKEN: ${{ secrets.GH_PAT }}')


def m_vyrazhenie_vne_alfavita(t):
    return _zameni(t, '          RUN_ID: ${{ github.event.workflow_run.id }}',
                   '          RUN_ID: ${{ github.event.workflow_run.id }}\n'
                   '          HEAD_REPO: '
                   '${{ github.event.workflow_run.head_repository.full_name }}')


def m_molchashij_skip(t):
    for star in ('            echo "SKIP: conclusion=${CONCLUSION}"',
                 '            echo "SKIP: run_attempt=${ATTEMPT} — повтор уже был"',
                 '            echo "SKIP: упавший android-e2e не найден"',
                 '          echo "SKIP: инфраструктурной сигнатуры в логе '
                 'android-e2e нет — чистый провал проверки"'):
        t = _zameni(t, star, '          true')
    return t


def m_signatury_suzheny(t, src_signatury):
    return _zameni(t, src_signatury,
                   'device offline|DeviceServerDiedException')


# --- стабы блокера 1 (исполняемые ветви вне наблюдаемого шага) и
# --- стабы блокера 2 (pipefail + ранний выход потребителя пайпа) --------------

def m_dop_shag_run(t):
    return t + '\n      - name: Vtoroj avtopovtor\n' \
               '        run: gh run rerun --failed "$RUN_ID"\n'


def m_dop_shag_uses(t):
    return t + '\n      - uses: actions/checkout@v4\n'


def m_dop_job_ubuntu(t):
    return t + ('\n  unguarded:\n    runs-on: ubuntu-latest\n'
                '    steps:\n      - run: gh run rerun --failed "$RUN_ID"\n')


def m_dop_job_selfhosted(t):
    return t + ('\n  unguarded:\n'
                '    runs-on: [self-hosted, linux, x64, complior]\n'
                '    steps:\n      - run: gh run rerun --failed "$RUN_ID"\n')


def m_dopolnitelnyj_trigger(t):
    return _zameni(t, '    workflows: [mobile]\n    types: [completed]\n',
                   '    workflows: [mobile]\n    types: [completed]\n'
                   '  workflow_dispatch: {}\n')


def m_jakor_merge(t):
    t = _zameni(t, 'jobs:\n  retry:',
                '_skryt: &skrytyj_shag\n  name: Dop\n'
                '  run: gh run rerun --failed "$RUN_ID"\njobs:\n  retry:')
    return t + '\n      - <<: *skrytyj_shag\n'


def m_defaults_run_shell(t):
    return _zameni(t, 'permissions:\n  actions: write\n  contents: read\n',
                   'permissions:\n  actions: write\n  contents: read\n'
                   'defaults:\n  run:\n    shell: python\n')


def m_svertyvanie_dva_rerun(t):
    i = t.index('        run: |\n')
    return t[:i] + ('        run: >-\n'
                    '          gh run rerun --failed "$RUN_ID"\n'
                    '          gh run rerun --failed "$RUN_ID"\n')


def m_env_podmena(t):
    t = _zameni(t, '          RUN_ID: ${{ github.event.workflow_run.id }}',
                '          RUN_ID: ${{ github.event.workflow_run.id }}\n'
                '          RERUN_CMD: gh run rerun --failed "$RUN_ID"')
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"',
                   '            "$RERUN_CMD"')


def m_skrytyj_bash_c(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"',
                   '            bash -c \'gh run rerun --failed "$RUN_ID"\'')


def m_skrytyj_eval(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"',
                   '            eval \'gh run rerun --failed "$RUN_ID"\'')


def m_skrytyj_xargs(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"',
                   '            printf \'%s\\n\' "$RUN_ID" | '
                   'xargs gh run rerun --failed')


def m_skrytyj_podstanovka(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"',
                   '            RC="$(gh run rerun --failed "$RUN_ID")"')


def m_setevoj_curl(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"',
                   '            curl -sS -X POST -H "Authorization: Bearer '
                   '${GH_TOKEN}" "https://api.github.com/repos/'
                   '${GITHUB_REPOSITORY}/actions/runs/${RUN_ID}/rerun"')


def m_cikl_for(t):
    return _zameni(t, '            gh run rerun --failed "$RUN_ID"\n'
                      '            exit 0',
                   '            for i in 1; do gh run rerun --failed '
                   '"$RUN_ID"; done\n            exit 0')


def m_rannij_grep_q(t):
    t = _zameni(t, "if grep -qE '",
                "if printf '%s\\n' \"$LOG\" | sed -e "
                "'/##\\[group\\]Run /,/##\\[endgroup\\]/d' | grep -qE '")
    return _zameni(t, " \"$LOG_F\"; then", "; then")


def m_rannij_head(t):
    return _zameni(t, "| sed -n '1p' | tr -d '[:space:]'",
                   "| head -n 1 | tr -d '[:space:]'")


STAB_MUTACII = {
    's-bez-attempt-guard': m_bez_attempt_guard,
    's-bez-signaturnogo-filtra': m_bez_signaturnogo_filtra,
    's-bez-eho-zaschity': m_bez_eho_zaschity,
    's-polnyj-rerun': m_polnyj_rerun,
    's-bez-jobs-filtra': m_bez_jobs_filtra,
    's-bez-conclusion-guard': m_bez_conclusion_guard,
    's-shirokie-prava': m_shirokie_prava,
    's-runner-ubuntu': m_runner_ubuntu,
    's-chuzhoj-trigger': m_chuzhoj_trigger,
    's-if-bez-uslovij': m_if_bez_uslovij,
    's-dva-rerun': m_dva_rerun,
    's-sekret-v-tekste': m_sekret_v_tekste,
    's-vyrazhenie-vne-alfavita': m_vyrazhenie_vne_alfavita,
    's-molchashij-skip': m_molchashij_skip,
    's-signatury-suzheny': None,  # резолвится в apply (нужен src)
    's-dop-shag-run': m_dop_shag_run,
    's-dop-shag-uses': m_dop_shag_uses,
    's-dop-job-ubuntu': m_dop_job_ubuntu,
    's-dop-job-selfhosted': m_dop_job_selfhosted,
    's-dopolnitelnyj-trigger': m_dopolnitelnyj_trigger,
    's-jakor-merge': m_jakor_merge,
    's-defaults-run-shell': m_defaults_run_shell,
    's-svertyvanie-dva-rerun': m_svertyvanie_dva_rerun,
    's-env-podmena': m_env_podmena,
    's-skrytyj-bash-c': m_skrytyj_bash_c,
    's-skrytyj-eval': m_skrytyj_eval,
    's-skrytyj-xargs': m_skrytyj_xargs,
    's-skrytyj-podstanovka': m_skrytyj_podstanovka,
    's-setevoj-curl': m_setevoj_curl,
    's-cikl-for': m_cikl_for,
    's-rannij-grep-q': m_rannij_grep_q,
    's-rannij-head': m_rannij_head,
}


def sdelat_stab(imja, model_tekst, src):
    fn = STAB_MUTACII[imja]
    try:
        if imja == 's-signatury-suzheny':
            return m_signatury_suzheny(model_tekst, src['signatury_regex'])
        return fn(model_tekst)
    except (RuntimeError, ValueError) as e:
        print('ORACLE_TAMPERED: стаб %s: %s' % (imja, e), file=sys.stderr)
        return None


# --- структурные оси ---------------------------------------------------------

def yaml_dok(t):
    return yaml.safe_load(t)


def _on(doc):
    return doc.get('on', doc.get(True))


# --- замкнутая структура (критик 139, круг 1, блокер 1) ----------------------

VERH_URAVNJA = {'name', 'on', 'permissions', 'jobs'}
JOB_KLJUCHI = {'if', 'runs-on', 'timeout-minutes', 'steps'}
SHAG_KLJUCHI = {'name', 'env', 'run'}
TRIGGERY = {'workflow_run'}


def os_zamknutost(doc, src, syr_tekst):
    """Ровно один job retry с ровно одним исполняемым шагом run; ключи
    jobs/шагов/верха вне алфавита, доп. триггеры (workflow_dispatch/schedule/
    push/pull_request*), defaults, YAML-расширения (якоря/алиасы/merge-ключи/
    теги) — именованный отказ. Любой доп. job/шаг/скриптовый путь, способный
    повторить прогон, отвергается СТАТИКОЙ ещё до replay."""
    prob = []
    verh = set()
    for k in (doc or {}):
        verh.add('on' if k is True else str(k))
    lishnie = sorted(verh - VERH_URAVNJA)
    if lishnie:
        prob.append('ZAMKNUTOST: ключи верхнего уровня вне алфавита: %s'
                    % ', '.join(lishnie))
    on = _on(doc)
    if isinstance(on, dict):
        dop_trig = sorted(str(t) for t in on if t != 'workflow_run')
        if dop_trig:
            prob.append('ZAMKNUTOST: триггеры вне алфавита: %s'
                        % ', '.join(dop_trig))
    jobs = doc.get('jobs') or {}
    if not isinstance(jobs, dict) or set(jobs) != {'retry'}:
        imena = sorted(jobs) if isinstance(jobs, dict) else repr(jobs)
        prob.append('ZAMKNUTOST: jobs %s, а не ровно один retry' % (imena,))
    else:
        job = jobs['retry'] or {}
        lishn_job = sorted(str(k) for k in job if k not in JOB_KLJUCHI)
        if lishn_job:
            prob.append('ZAMKNUTOST: ключи job вне алфавита: %s'
                        % ', '.join(lishn_job))
        tm = job.get('timeout-minutes')
        if tm is not None and (isinstance(tm, bool)
                               or not isinstance(tm, int) or tm > 10):
            prob.append('ZAMKNUTOST: timeout-minutes %r вне 1..10' % (tm,))
        shagi = job.get('steps')
        if not isinstance(shagi, list) or len(shagi) != 1:
            prob.append('ZAMKNUTOST: шагов %s, а не ровно один'
                        % (len(shagi) if isinstance(shagi, list) else 'нет',))
        else:
            shag = shagi[0] or {}
            lishn_shag = sorted(str(k) for k in shag
                                if k not in SHAG_KLJUCHI)
            if lishn_shag:
                prob.append('ZAMKNUTOST: ключи шага вне алфавита (uses и пр.): %s'
                            % ', '.join(lishn_shag))
            if 'run' not in shag:
                prob.append('ZAMKNUTOST: у единственного шага нет run:')
    rasshrenija = []
    for tok in yaml.scan(syr_tekst):
        imja_toka = type(tok).__name__
        if imja_toka == 'AnchorToken':
            rasshrenija.append('якорь &%s' % tok.value)
        elif imja_toka == 'AliasToken':
            rasshrenija.append('алиас *%s' % tok.value)
        elif imja_toka == 'TagToken':
            rasshrenija.append('тег %r' % (tok.value,))
    if re.search(r'(?m)^\s*<<\s*:', syr_tekst):
        rasshrenija.append('merge-ключ <<:')
    if rasshrenija:
        prob.append('ZAMKNUTOST: YAML-расширения запрещены: %s'
                    % '; '.join(rasshrenija))
    return prob

def os_trigger(doc, src):
    on = _on(doc)
    if not isinstance(on, dict):
        return ['TRIGGER_RASHOZHDENIE: нет карты on']
    wr = on.get('workflow_run')
    if wr != {'workflows': ['mobile'], 'types': ['completed']}:
        return ['TRIGGER_RASHOZHDENIE: %r' % (wr,)]
    return []


def os_prava(doc, src):
    if doc.get('permissions') != src['prava']:
        return ['PRAVA_RASHOZHDENIE: %r' % (doc.get('permissions'),)]
    for j in (doc.get('jobs') or {}).values():
        if 'permissions' in j:
            return ['PRAVA_RASHOZHDENIE: permissions на уровне job']
    return []


def os_runner(doc, src):
    try:
        ro = doc['jobs']['retry']['runs-on']
    except (KeyError, TypeError):
        return ['RUNNER_RASHOZHDENIE: нет job retry / runs-on']
    if ro != src['runner']:
        return ['RUNNER_RASHOZHDENIE: %r' % (ro,)]
    return []


def os_if(doc, src):
    try:
        usl = doc['jobs']['retry']['if']
    except (KeyError, TypeError):
        return ['IF_RASHOZHDENIE: нет if у retry']
    if not isinstance(usl, str):
        return ['IF_RASHOZHDENIE: if не строка']
    prob = []
    for chast in src['alfavit_if']:
        if chast not in usl:
            prob.append("IF_RASHOZHDENIE: нет условия %r" % chast)
    return prob


def os_rerun(doc, src, syr_tekst):
    """Канон вызова повтора (критик 139, круг 1, блокер 1): литерал
    'gh run rerun' — ровно один в теле единственного шага И ровно один в
    файле целиком (второй шаг, env-подмена, свёртка >- не укрывают);
    слово 'rerun' — ровно один раз в файле (api-путь /rerun, env-значение,
    комментарий вне канона); вызов дословно gh run rerun --failed "$RUN_ID";
    циклы и скрытые пути (оболочка -c/eval/xargs/подстановка/curl|wget) —
    именованный отказ."""
    prob = []
    try:
        skript = doc['jobs']['retry']['steps'][0]['run']
    except (KeyError, TypeError, IndexError):
        return ['RERUN_RASHOZHDENIE: нет шага/скрипта']
    n_telo = skript.count('gh run rerun')
    if n_telo != 1:
        prob.append('RERUN_RASHOZHDENIE: вызовов gh run rerun в теле шага '
                    '%d, а не 1' % n_telo)
    else:
        stroka = [l for l in skript.splitlines() if 'gh run rerun' in l][0]
        if 'gh run rerun --failed "$RUN_ID"' not in stroka:
            prob.append('RERUN_RASHOZHDENIE: вызов не дословно '
                        'gh run rerun --failed "$RUN_ID"')
    n_fail = syr_tekst.count('gh run rerun')
    if n_fail != 1:
        prob.append('RERUN_RASHOZHDENIE: литералов gh run rerun в файле '
                    '%d, а не 1' % n_fail)
    n_liter = syr_tekst.count('rerun')
    if n_liter != 1:
        prob.append('RERUN_RASHOZHDENIE: вхождений rerun в файле %d, а не 1 '
                    '(env-подмена/api-путь/комментарий вне канона)' % n_liter)
    bez_sig = '\n'.join(l for l in skript.splitlines()
                        if src['signatury_regex'] not in l)
    if re.search(r'\b(while|until|for)\b', bez_sig):
        prob.append('RERUN_RASHOZHDENIE: цикл в скрипте повтора')
    if re.search(r'\b(?:bash|sh|dash|zsh|ksh)\s+-c\b', skript) \
            or re.search(r'\beval\b', skript) \
            or re.search(r'\bxargs\b', skript):
        prob.append('SKRITYJ_VYZOV: оболочка -c/eval/xargs в скрипте')
    if re.search(r'\$\(\s*gh run rerun', skript):
        prob.append('SKRITYJ_VYZOV: rerun в подстановке $()')
    if re.search(r'\b(?:curl|wget)\b', skript):
        prob.append('SETEVOJ_VYZOV: curl/wget в скрипте')
    return prob


def os_sekrety(doc, src, syr_tekst):
    prob = []
    if '${{ secrets' in syr_tekst or 'secrets.' in syr_tekst:
        prob.append('SEKRET_V_TEKSTE: обращение к secrets')
    if re.search(r'gh[pousr]_[A-Za-z0-9]{16,}', syr_tekst):
        prob.append('SEKRET_V_TEKSTE: литеральный токен')
    return prob


def os_vyrazhenija(doc, src, syr_tekst):
    prob = []
    for v in VYRAZHENIE_RE.findall(syr_tekst):
        if v not in src['alfavit_vyrazhenij']:
            prob.append('VYRAZHENIE_VNE_ALFAVITA: ${{ %s }}' % v)
    return prob


def os_signatury(doc, src, syr_tekst):
    if src['signatury_regex'] not in syr_tekst:
        return ['SIGNATURY_RASHOZHDENIE: канон сигнатур не найден дословно']
    return []


OSI_STRUKTURY = {
    'trigger': os_trigger,
    'prava': os_prava,
    'runner': os_runner,
    'if': os_if,
}

# оси, которым нужен сырой текст субъекта (канон литералов, алфавиты,
# замкнутость) — судятся по syr_tekst, свёртка |/>/-> не укрывает:
OSI_SYROGO_TEKSTA = {
    'rerun': os_rerun,
    'sekrety': os_sekrety,
    'vyrazhenija': os_vyrazhenija,
    'signatury': os_signatury,
    'zamknutost': os_zamknutost,
}


# --- поведение: replay скрипта шага с подложным gh ----------------------------

def _render_env(shag_env, sobytye, src):
    """Закрытый алфавит: значение env — ровно одно выражение из алфавита."""
    karta = {
        'github.token': 'test-token-139',
        'github.event.workflow_run.id': str(sobytye['run_id']),
        'github.event.workflow_run.name': str(sobytye.get('name', 'mobile')),
        'github.event.workflow_run.conclusion': str(sobytye['conclusion']),
        'github.event.workflow_run.run_attempt': str(sobytye['attempt']),
    }
    out = {}
    for k, v in (shag_env or {}).items():
        m = re.fullmatch(r'\$\{\{\s*([^}]+?)\s*\}\}', str(v))
        if not m or m.group(1) not in karta:
            return None, k
        out[k] = karta[m.group(1)]
    return out, None


def _sobrat_log(kejs):
    """Классы размера/формы лога (критик 139, круг 1, блокер 2): длинные
    логи и байтовые формы генерируются ВО ВРЕМЯ прогона, в репо не хранятся.
    Возвращает (tekst, None) либо (None, bajty)."""
    lg = kejs.get('log_generator')
    if not lg:
        return None, None
    if 'bajty' in lg:
        return None, bytes(lg['bajty'])
    koncy = '\r\n' if lg.get('crlf') else '\n'
    pred = list(lg.get('predstroki') or [])
    if 'odna_stroka' in lg:
        o = lg['odna_stroka']
        linii = pred + [o['prefiks']
                        + 'a' * max(0, o['dlina'] - len(o['prefiks']))]
    else:
        strok = lg['strok']
        linii = pred + [lg['zapolnitel']] * strok
        if strok and lg.get('signatura'):
            pol = lg.get('polozenie', 'seredina')
            if pol == 'nachalo':
                linii[len(pred)] = lg['signatura']
            elif pol == 'konec':
                linii[-1] = lg['signatura']
            else:
                linii[len(pred) + strok // 2] = lg['signatura']
    tekst = koncy.join(linii)
    if not lg.get('bez_konechnogo_perevoda'):
        tekst += koncy
    return tekst, None


def _sobrat_jobs(kejs):
    """Множественные failed-job записи (класс раннего выхода head): список
    jobs генерируется во время прогона."""
    jg = kejs.get('jobs_generator')
    if not jg:
        return kejs['jobs']
    return {'jobs': [
        {'id': jg['pervyj_id'] if i == 0 else jg['pervyj_id'] + i,
         'name': 'android-e2e', 'conclusion': 'failure'}
        for i in range(jg['kolichestvo'])]}


def replay(tekst_subiekta, kejs, src):
    """Исполняет скрипт шага в чистом окружении с подложным gh.

    Возвращает (rc, stdout-строки, vyzovy-строки, nechitaem: bool).
    """
    try:
        doc = yaml_dok(tekst_subiekta)
        shag = doc['jobs']['retry']['steps'][0]
        skript = shag['run']
    except Exception:
        return 2, [], [], True
    env_shaga, plohoe = _render_env(shag.get('env'), kejs['sobytye'], src)
    if env_shaga is None:
        return 2, [], [], False
    tmp = Path(tempfile.mkdtemp(prefix='e2e139-'))
    try:
        bindir = tmp / 'bin'
        bindir.mkdir()
        (bindir / 'gh').write_text(SHIM_PY, encoding='utf-8')
        (bindir / 'gh').chmod(0o755)
        log_f = tmp / 'log.txt'
        log_tekst = kejs.get('log')
        if log_tekst is None and kejs.get('log_nositel'):
            log_tekst = (NOSITELI / kejs['log_nositel']).read_text(
                encoding='utf-8')
        gen_tekst, gen_bajty = _sobrat_log(kejs)
        if gen_bajty is not None:
            log_f.write_bytes(gen_bajty)
        else:
            if gen_tekst is not None:
                log_tekst = gen_tekst
            log_f.write_text(log_tekst, encoding='utf-8')
        zap = tmp / 'zapisi.tsv'
        zap.write_text('', encoding='utf-8')
        jobs_f = tmp / 'jobs.json'
        jobs_f.write_text(json.dumps(_sobrat_jobs(kejs)), encoding='utf-8')
        env = {
            'PATH': '%s:/usr/bin:/bin' % bindir,
            'LC_ALL': 'C.UTF-8',
            'HOME': str(tmp),
            'GH_TOKEN': 'test-token-139',
            'GITHUB_REPOSITORY': src['repo_scenariev'],
            'SCENARIJ_ZAPISI': str(zap),
            'SCENARIJ_JOBS_FAJL': str(jobs_f),
            'SCENARIJ_LOG': str(log_f),
            'SCENARIJ_ALFAVIT_ZHK': json.dumps(
                list(src['alfavit_zhk'].values())),
        }
        env.update(env_shaga)
        p = subprocess.run([BASH, '-c', skript], env=env, cwd=str(tmp),
                           capture_output=True, text=True, timeout=60)
        vyzovy = [l for l in zap.read_text(encoding='utf-8').splitlines()
                  if l]
        return p.returncode, p.stdout.splitlines(), vyzovy, False
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --- суд кейса ---------------------------------------------------------------

def pin_mobile_yml(derevo):
    p = derevo / MOBILE_YML_REL
    return sha256_bytes(p.read_bytes())


def sudit(tekst_subiekta, imja, src, tmp_root):
    """Суд кейса: фактические problemy против ozhidanie.problemy.

    ok ⇔ sorted(фактические) == sorted(ожидаемые); для честного субъекта на
    зелёных входах ожидание пусто, на красных входах (derevo) — именованная
    причина; пусто при ожидании непустом → NELOVLENO (барьер проспал).
    """
    kejs = src['kejsy'][imja]
    ozh = kejs['ozhidanie']
    problemy = []
    if kejs['tip'] == 'struktura':
        try:
            doc = yaml_dok(tekst_subiekta)
        except Exception:
            return ['YML_NECHITAEM']
        os_ = kejs['os']
        if os_ in OSI_SYROGO_TEKSTA:
            problemy = OSI_SYROGO_TEKSTA[os_](doc, src, tekst_subiekta)
        else:
            problemy = OSI_STRUKTURY[os_](doc, src)
    else:
        # replay / derevo: пин байтов mobile.yml на дереве кейса
        derevo = tmp_root / ('derevo_' + imja)
        postavit_derevo(derevo, src, mutacija=(kejs['tip'] == 'derevo'))
        if pin_mobile_yml(derevo) != src['nositeli']['mobile.yml']:
            problemy.append('MOBILE_YML_IZMENEN')
        if kejs['tip'] == 'replay':
            rc, out, vyzovy, nechitaem = replay(tekst_subiekta, kejs, src)
            if nechitaem:
                problemy.append('YML_NECHITAEM')
            else:
                if rc != ozh['rc']:
                    problemy.append('RC_RASHOZHDENIE: %d, ожидался %d'
                                    % (rc, ozh['rc']))
                if out != ozh['stdout']:
                    problemy.append('STDOUT_RASHOZHDENIE: %r, ожидался %r'
                                    % (out, ozh['stdout']))
                if vyzovy != ozh['vyzovy']:
                    problemy.append('VYZOVY_RASHOZHDENIE: %r, ожидались %r'
                                    % (vyzovy, ozh['vyzovy']))
    ozhidajut = sorted(ozh.get('problemy', []))
    if sorted(problemy) == ozhidajut:
        return []
    if not problemy:
        return ['NELOVLENO: %s' % imja]
    return problemy


def postavit_derevo(derevo, src, mutacija=False):
    """Дерево-модель продукта: байтовая копия mobile.yml (+мутация кейса)."""
    if not derevo.exists():
        (derevo / '.github' / 'workflows').mkdir(parents=True)
        bajty = (NOSITELI / 'mobile.yml').read_bytes()
        if mutacija:
            bajty = bajty + '\n# местная правка вне канона 139\n'.encode('utf-8')
        (derevo / MOBILE_YML_REL).write_bytes(bajty)


# --- движок ------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    ap.add_argument('--repo', default=os.environ.get('MOB_REPO'))
    a = ap.parse_args()
    try:
        rc_zagr, src = load_source()
    except json.JSONDecodeError as e:
        return oshibka_orakula('source.json: %s' % e)
    if rc_zagr:
        return rc_zagr
    matrica = a.stabs or a.matrix
    if a.model or matrica:
        tekst_subiekta = MODEL.read_text(encoding='utf-8')
    else:
        if not a.repo:
            print('SUBJECT_ABSENT: нет --repo/MOB_REPO с корнем продукта')
            for imja in src['kejsy']:
                print('CASE %s KRASNO (SUBJECT_ABSENT)' % imja)
            return 1
        subj = Path(a.repo) / SUBJECT_REL
        if not subj.is_file():
            print('SUBJECT_ABSENT: %s' % subj)
            for imja in src['kejsy']:
                print('CASE %s KRASNO (SUBJECT_ABSENT)' % imja)
            return 1
        tekst_subiekta = subj.read_text(encoding='utf-8')
        zhivoj = Path(a.repo) / MOBILE_YML_REL
        if sha256_bytes(zhivoj.read_bytes()) != src['nositeli']['mobile.yml']:
            print('MOBILE_YML_IZMENEN: байты %s не равны пину канона'
                  % zhivoj, file=sys.stderr)
            return 1
    tmp_root = Path(tempfile.mkdtemp(prefix='e2e139-root-'))
    try:
        kontrol_ok = True
        for imja in src['kejsy']:
            problemy = sudit(tekst_subiekta, imja, src, tmp_root)
            if problemy:
                kontrol_ok = False
                print('CASE %s KRASNO: %s' % (imja, '; '.join(problemy)))
            else:
                print('CASE %s ok' % imja)
        if not matrica:
            return 0 if kontrol_ok else 1
        # --stabs: каждый обманный стаб красен на каждом своём входе
        model_tekst = MODEL.read_text(encoding='utf-8')
        zhivye, svjazi = 0, 0
        for stab, vhody in sorted(src['stab_vhod'].items()):
            tekst_staba = sdelat_stab(stab, model_tekst, src)
            if tekst_staba is None:
                return 2
            for v in vhody:
                svjazi += 1
                problemy = sudit(tekst_staba, v, src, tmp_root)
                if problemy:
                    print('STAB %s %s KRASEN (%s)'
                          % (stab, v, problemy[0]))
                else:
                    zhivye += 1
                    print('STAB %s %s PROSHYOL' % (stab, v))
        if zhivye:
            print('STAB_ZHIV: %d' % zhivye)
            return 1
        if not kontrol_ok:
            return 1
        print('SVJAZI %d' % svjazi)
        return 0
    finally:
        shutil.rmtree(tmp_root, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
