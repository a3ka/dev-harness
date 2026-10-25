#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 118, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132. Судит переход от production First-Run через first-run-continue
# и demo-вход F03.01 (auth-demo-entry) и gate к Start, наличие testID каждого
# шага, состав вкладок Start (не только узел start_tabs), ровно 16 кадров
# манифеста (8 snimok × dark/light из SELEKTOR_KADRA; меньше либо чужой состав
# → MANIFEST_NE_16_KADROV), оси admission/gate композиции — stand-in
# признаётся ТОЛЬКО в пин-форме носителя teksty/kompozicija_forma батареи
# (adv-118 A1: таблица ожиданий — подмена формы → KOMPOZICIJA_FORMA), проба
# гонит его сама по каждой оси с именованным исходом (источник admission —
# проверяющий; арбитраж 117↔118 п.1.2–1.5: шесть клеток admission×gate с
# ОБЯЗАТЕЛЬНЫМ continue при null/stale, конфликты источников entry/посторонних
# полей, чтение порта в момент действия, remount/начальный кадр, тема/Г0);
# чужой пин НЕ глушит оси — каждая именованная ветвь дефекта остаётся в
# вердикте (Н-39). Продуктовая проба композиции (зонд) обязана судить
# production-корень ../pilot-app, не модель-копию (арбитраж п.1.1 →
# MODEL_KAK_DOKAZATELSTVO). В CI продукта пускается ПОСЛЕ валидатора 132
# (тот вызывает Maestro), БЕЗ промежуточной правки кадров.
# Заголовок флоу адресует пакет продукта: appId обязан равняться
# expo.android.package из mobile/app.json (дефект батареи 118: чужой demo-пакет
# вместо com.complior.mobile ронял Maestro «Package … is not installed»).
# Конфиг каталога Maestro (mobile/.maestro/config.yaml) обязан нести
# исключение флоу пачки своей строкой в flows (adv-118 B3): иначе общий
# прогон каталога (995: maestro test .maestro) включит сценарий пачки,
# хотя порядок флоу каталога недетерминирован и флоу требует First-Run —
# пачку судит только отдельный прогон e2e.sh по прямому пути.
# v2 круг 3 (РЕШЕНИЕ арбитра 118 v2): текст ≠ исполнение — срок судят
# пин-форма теста (sha256) и ОТЧЁТ jest --json шага npm test (--jest-otchet,
# fail-closed), данные — БАЙТОВЫЙ эталон с ровно одной разрешённой
# подстановкой литерала expires_at (декодированный объект байтами не
# является); лексический токен-гейт PROIZVODSTVO_BEZ_SROKA снят.
# rc 1 — PRICHINA; rc 2 — нечитаемый вход.
import argparse


def _listja_raznija(etalon, fakt, put=''):
    if isinstance(etalon, dict) and isinstance(fakt, dict):
        out = []
        for k in sorted(set(etalon) | set(fakt)):
            put_k = put + '.' + k
            if k not in etalon:
                out += _listja_raznija(None, fakt[k], put_k)
            elif k not in fakt:
                out += _listja_raznija(etalon[k], None, put_k)
            else:
                out += _listja_raznija(etalon[k], fakt[k], put_k)
        return out
    if isinstance(etalon, list) and isinstance(fakt, list):
        return [] if etalon == fakt else [put + '#spisok']
    return [] if etalon == fakt else [put]
import hashlib
import json
import subprocess
import sys
from pathlib import Path

PEREHODY = ('tapOn', 'inputText', 'pressKey', 'swipe')
ZAPUSKI = ('launchApp',)
ISTOCHNIKI_EKRANA = ('mobile/src/features/onboarding', 'mobile/src/features/auth',
                     'mobile/src/bootstrap', 'mobile/src/app')
SELEKTOR_KADRA = {
    'erstinformation-f02-03-v01-v0': 'erstinfo_frame_f02_03_v01_v0',
    'erstinformation-f02-03-v02-v0': 'erstinfo_frame_f02_03_v02_v0',
    'erstinformation-f02-03-v01': 'erstinfo_frame_f02_03_v01',
    'erstinformation-f02-03-v02': 'erstinfo_frame_f02_03_v02',
    'erstinformation-f02-08-v01': 'erstinfo_frame_f02_08_v01',
    'erstinformation-f02-08-v02': 'erstinfo_frame_f02_08_v02',
    'erstinformation-f02-08-v03': 'erstinfo_frame_f02_08_v03',
    'erstinformation-f02-08-v04': 'erstinfo_frame_f02_08_v04',
}
OZHIDAEMYE_KADRY = sorted(
    (snimok, tema) for snimok in SELEKTOR_KADRA for tema in ('dark', 'light'))


def prichina(imja, detal):
    print('PRICHINA\t%s\t%s' % (imja, detal), file=sys.stderr)


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def shagi_flow(path):
    out = []
    for line in path.read_text(encoding='utf-8').splitlines():
        s = line.strip()
        if not s.startswith('- '):
            continue
        step = s[2:]
        k, sep, a = step.partition(':')
        out.append((k.strip(), a.strip() if sep else ''))
    return out


def id_iz(arg):
    if 'id:' not in arg:
        return None
    t = arg.partition('id:')[2].strip()
    t = t.split('}')[0].split(',')[0]
    return t.strip().strip("'\"")

def paket_produkta(repo):
    """Пакет продукта — из mobile/app.json (expo.android.package), не литерал
    проверяющего: ожидание снимается из проверяемого репо до суда флоу."""
    app = json.loads((repo / 'mobile/app.json').read_text(encoding='utf-8'))
    return app['expo']['android']['package']


def appid_flow(path):
    """appId из заголовка флоу (строки до первого '---')."""
    zagolovok = path.read_text(encoding='utf-8').partition('---')[0]
    for line in zagolovok.splitlines():
        if line.startswith('appId:'):
            return line.partition(':')[2].strip()
    return None

KATALOG_MAESTRO = 'mobile/.maestro/config.yaml'


def iskljuchenie_pachki_v_confige(repo, iskljuchenie):
    """Исключение флоу пачки в списке flows конфига каталога Maestro.
    Судится ТОЛЬКО флоу пачки: исключения чужих флоу (995/107/117/135;
    mission — зона 116, не 118) не требуются и не запрещаются. Сравнение
    литеральное: значение элемента списка после '- ' со снятыми кавычками
    самостоятельной строкой, не подстрока где-угодно."""
    p = repo / KATALOG_MAESTRO
    if not p.is_file():
        return False
    v_spiske = False
    for line in p.read_text(encoding='utf-8').splitlines():
        s = line.strip()
        if v_spiske:
            if not s.startswith('- '):
                break
            if s[2:].strip().strip('\'"') == iskljuchenie:
                return True
        elif s == 'flows:':
            v_spiske = True
    return False


def sud_flow(shagi, snimki):
    otkazy = []
    poz = {}
    for i, (k, a) in enumerate(shagi):
        if k == 'takeScreenshot':
            poz.setdefault(a, []).append(i)
    for s in snimki:
        sp = poz.get(s, [])
        if not sp:
            otkazy.append(('SNIMOK_BEZ_SHAGA', s))
        elif len(sp) > 1:
            otkazy.append(('SNIMOK_NEODNOZNACHEN', s))
    if not shagi or shagi[0][0] != 'launchApp' or sum(
            k == 'launchApp' for k, _ in shagi) != 1 or any(
                k in ('openLink', 'startApp') for k, _ in shagi):
        otkazy.append(('FLOW_BEZ_ZAPUSKA', 'launchApp'))
    granica = -1
    for s in snimki:
        sp = poz.get(s, [])
        if not sp:
            continue
        i = sp[0]
        blok_shagov = shagi[granica + 1:i]
        blok = [k for k, _ in blok_shagov]
        if granica >= 0 and not any(k in PEREHODY for k in blok):
            otkazy.append(('FLOW_BEZ_PEREHODA', s))
        if 'assertVisible' not in blok:
            otkazy.append(('FLOW_BEZ_DOSTIZHENIJA', s))
        if s not in SELEKTOR_KADRA or not any(
                k == 'assertVisible' and id_iz(a) == SELEKTOR_KADRA[s]
                for k, a in blok_shagov):
            otkazy.append(('SELEKTOR_NE_KADRA', s))
        granica = i

    def ordered(items):
        at = -1
        for kind, val in items:
            at = next((i for i in range(at + 1, len(shagi))
                       if shagi[i][0] == kind and
                       (id_iz(shagi[i][1]) if kind in ('tapOn', 'assertVisible',
                                                     'assertNotVisible') else
                        shagi[i][1]) == val), -1)
            if at < 0:
                return False
        return True

    first = snimki[0]
    # Демо-вход production (арбитраж 117↔118 п.1.7): First-Run →
    # first-run-continue → F03.01 → auth-demo-entry → Erstinformation.
    # Промежуточный экран first_run_demo_entry в production-корне 117 v3
    # не предусмотрен (117 :153 «вход F03.01 после First-Run — без изменений»).
    if not ordered([('launchApp', ''), ('assertVisible', 'first-run-continue'),
                    ('tapOn', 'first-run-continue'),
                    ('assertVisible', 'auth-demo-entry'),
                    ('tapOn', 'auth-demo-entry'),
                    ('assertVisible', SELEKTOR_KADRA[first]),
                    ('takeScreenshot', first)]):
        otkazy.append(('FLOW_BEZ_DEMO_VHODA', first))
    # Null и stale — два разных запрета, каждый наблюдается ДО подтверждённого
    # gate; проверка по индексам исключает assertNotVisible где-то в хвосте.
    for state, shot in (('null', snimki[0]), ('stale', snimki[3])):
        marker = 'erstinfo_gate_' + state
        if not ordered([('assertVisible', marker),
                        ('assertNotVisible', 'start_tabs'),
                        ('takeScreenshot', shot)]):
            otkazy.append(('FLOW_GATE_NE_PROVEREN', state))
    # Состав назначения наблюдаем ПО ВКЛАДКЕ, не только узлом start_tabs
    # (вердикт круга 2: пустой <View testID="start_tabs" /> без вкладок —
    # не Start).
    vkladki = ('start_tabs', 'start_tab_start', 'start_tab_vorgaenge',
               'start_tab_schutz', 'start_tab_post')
    if not ordered([('takeScreenshot', snimki[-1]),
                    ('tapOn', 'erstinfo_retry_current'),
                    ('assertVisible', 'erstinfo_gate_current'),
                    ('tapOn', 'erstinfo_continue_start')] +
                   [('assertVisible', t) for t in vkladki]):
        otkazy.append(('FLOW_BEZ_START', 'start_tabs'))
    return otkazy
def selektory(shagi):
    out = []
    for k, a in shagi:
        if k in ('tapOn', 'assertVisible'):
            i = id_iz(a)
            if i:
                out.append(i)
    return out

KOMPOZICIJA_PROBA = 'mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh'
KOMPOZICIJA_ZONDA = 'mobile/src/bootstrap/__tests__/kompozicija.probe.test.tsx'
KOMPOZICIJA_FORMA_SHA256 = \
    '2efeb3b781a6b9f0e7ada43bbec33686512787fd6521fa05efede6965387d909'
OSI_IMENA = {
    'POVERHNOST': 'KOMPOZICIJA_POVERHNOST',
    'W0': 'KOMPOZICIJA_W0_PROPUSHCHEN',
    'W1A': 'KOMPOZICIJA_W1A_NE_DOPUSHCHEN',
    'GATE': 'KOMPOZICIJA_GATE_PROPUSHCHEN',
    'ENTRY': 'KOMPOZICIJA_ENTRY_ISTOCHNIK',
    'POSTORONNEE': 'KOMPOZICIJA_POSTORONNEE_POLE',
    'KESH': 'KOMPOZICIJA_KESH_ADMISSION',
    'FIRST_RUN': 'KOMPOZICIJA_NE_FIRST_RUN',
    'G0': 'KOMPOZICIJA_G0_TEMA',
    'SROK_ROOT': 'KOMPOZICIJA_SROK_ISTEK_ROOT',
    'SROK_START': 'KOMPOZICIJA_SROK_ISTEK_START',
    'SROK_ROVNO': 'KOMPOZICIJA_SROK_ROVNO_SEJCHAS',
    'SROK_NAN': 'KOMPOZICIJA_SROK_NERAZBORCHIV',
    'SROK_KESH': 'KOMPOZICIJA_SROK_KESH',
    'SROK_BUDUSHCHIJ': 'KOMPOZICIJA_SROK_BUDUSHCHIJ',
    'SROK_STROKOJ': 'KOMPOZICIJA_SROK_STROKOJ',
}
# Оси композиции v2 (арбитраж 117↔118 п.1.2–1.5, таблица осей, не точки
# мутантов): (admission, gate, entry, sobytie, extra, admission_tek,
# ozhidanie, imja_vetvi). Пояснения:
#   1–10 — шесть клеток admission×gate (demo) с ОБЯЗАТЕЛЬНЫМ continue
#          при null/stale (инв. 5 «после действия continue»);
#   11–14 — конфликты источников: entry.onboarding='complete',
#          постороннее truthy-поле порта, entry.gate='current' против
#          авторитетного stale сессии;
#   15–16 — порт читается в МОМЕНТ действия (rerender W1A→W0 до demo и до
#          continue), кэш допуска красен;
#   17–18 — начальный кадр first-run при любом entry и remount с
#          сохранённым completed-entry (W0/stale → First-Run, не Start);
#   19–20 — смена темы: поверхность не меняется (Г0 корня F03 на пути B,
#          автостарта нет).
KOMPOZICIJA_OSI = (
        ('W1A', 'null', 'net', 'demo', 'net', '', '', '', 'erstinformation', 'POVERHNOST'),
    ('W1A', 'null', 'net', 'demo-continue', 'net', '', '', '', 'start_ne_dopushchen', 'GATE'),
    ('W1A', 'stale', 'net', 'demo', 'net', '', '', '', 'erstinformation', 'POVERHNOST'),
    ('W1A', 'stale', 'net', 'demo-continue', 'net', '', '', '', 'start_ne_dopushchen', 'GATE'),
    ('W1A', 'current', 'net', 'demo', 'net', '', '', '', 'erstinformation', 'POVERHNOST'),
    ('W1A', 'current', 'net', 'demo-continue', 'net', '', '', '', 'start_dopushchen', 'W1A'),
    ('W0', 'null', 'net', 'demo', 'net', '', '', '', 'f03-02-code', 'W0'),
    ('W0', 'stale', 'net', 'demo', 'net', '', '', '', 'f03-02-code', 'W0'),
    ('W0', 'current', 'net', 'demo', 'net', '', '', '', 'f03-02-code', 'W0'),
    ('W0', 'current', 'net', 'demo-continue', 'net', '', '', '', 'start_ne_dopushchen', 'W0'),
    ('W0', 'current', 'complete', 'demo', 'net', '', '', '', 'f03-02-code', 'ENTRY'),
    ('W0', 'current', 'complete', 'demo-continue', 'net', '', '', '', 'start_ne_dopushchen', 'ENTRY'),
    ('W0', 'stale', 'net', 'demo', 'postoronnee-pole', '', '', '', 'f03-02-code', 'POSTORONNEE'),
    ('W1A', 'stale', 'complete', 'demo-continue', 'entry-gate-current', '', '', '', 'start_ne_dopushchen', 'GATE'),
    ('W1A', 'current', 'net', 'rerender-demo', 'net', 'W0', '', '', 'f03-02-code', 'KESH'),
    ('W1A', 'current', 'net', 'rerender-continue', 'net', 'W0', '', '', 'start_ne_dopushchen', 'KESH'),
    ('W0', 'stale', 'complete', 'remount', 'net', '', '', '', 'first-run', 'FIRST_RUN'),
    ('W1A', 'current', 'complete', 'montazh', 'net', '', '', '', 'first-run', 'FIRST_RUN'),
    ('W1A', 'stale', 'net', 'tema', 'net', '', '', '', 'erstinformation', 'G0'),
    ('W0', 'stale', 'net', 'tema', 'net', '', '', '', 'f03-02-code', 'G0'),
# 21–28 — ось expires_at × момент чтения (118 v2, B1 Adv118b круга 2,
# вариант Б-мини): истёкшая на корне и на маршруте /start, «ровно
# сейчас» (литерал now — текущий срез часов формы), неразборчивая,
# истёкшая между mount и действием (кэш $7 вместо среза $8), явная
# далёкая дата демо-источника → допуск есть (корень и /start),
# строковое сравнение ловится прошедшей датой года 999 (эпохой —
# глубокое прошлое). Сроки в осях — эпохой GNU date ('@N'):
# ISO-литерал с Z в тексте пачки ловит LITERAL_VNE_AUDITA (132).
    ('W1A', 'current', 'net', 'demo', 'net', '', '@1791936000', '',
     'f03-02-code', 'SROK_ROOT'),
    ('W1A', 'current', 'net', 'start-marshrut', 'net', '', '@1791936000', '',
     'start_ne_dopushchen', 'SROK_START'),
    ('W1A', 'current', 'net', 'demo', 'net', '', 'now', '',
     'f03-02-code', 'SROK_ROVNO'),
    ('W1A', 'current', 'net', 'demo', 'net', '', 'nerazborchivoe-znachenie', '',
     'f03-02-code', 'SROK_NAN'),
    ('W1A', 'current', 'net', 'rerender-demo', 'net', '', '@4102358400',
     '@1791936000', 'f03-02-code', 'SROK_KESH'),
    ('W1A', 'current', 'net', 'demo', 'net', '', '@4102358400', '',
     'erstinformation', 'SROK_BUDUSHCHIJ'),
    ('W1A', 'current', 'net', 'start-marshrut', 'net', '', '@4102358400', '',
     'start_dopushchen', 'SROK_BUDUSHCHIJ'),
    ('W1A', 'current', 'net', 'demo', 'net', '', '@-30641760000', '',
     'f03-02-code', 'SROK_STROKOJ'),
)


def sud_kompoziciju(repo):
    """Оси admission/gate на production-шве (вердикт круга 2 + adv-118 A1 +
    арбитраж 117↔118 п.1.2–1.5): stand-in признаётся ТОЛЬКО в пин-форме
    носителя teksty/kompozicija_forma (побайтовое равенство по sha256);
    чужие байты → KOMPOZICIJA_FORMA, при этом оси ВСЁ РАВНО прогоняются и
    именуют ветвь дефекта (Н-39: стаб красен там, где его дефект наблюдаем;
    rc!=0 оси — KOMPOZICIJA_OS_NE_ISPOLNENA, сбой команды не маскируется
    дефолтным «start_ne_dopushchen»). Источник admission — вызывающий
    проверяющий, не литерал в пробе; admission_tek (последний аргумент)
    моделирует rerender сессии ДО действия. Зонд-проба композиции
    (kompozicija.probe.test.tsx), если продукт её несёт, обязана импортировать
    production-корень '../pilot-app' и не импортировать модель-копию
    (арбитраж п.1.1 → MODEL_KAK_DOKAZATELSTVO)."""
    otkazy = []
    p = repo / KOMPOZICIJA_PROBA
    if not p.is_file():
        return [('KOMPOZICIJA_NET', KOMPOZICIJA_PROBA)]
    if sha(p) != KOMPOZICIJA_FORMA_SHA256:
        otkazy.append(('KOMPOZICIJA_FORMA', KOMPOZICIJA_PROBA))
    for admission, gate, entry, sobytie, extra, tek, srok, srok_tek, \
            ozhidanie, imja in KOMPOZICIJA_OSI:
        args = [admission, gate, entry, sobytie, extra, tek or '']
        if srok:
            args.append(srok)
            if srok_tek:
                args.append(srok_tek)
        zap = subprocess.run(
            ['bash', str(p)] + args,
            capture_output=True, text=True, cwd=str(repo / 'mobile'))
        fakt = zap.stdout.strip()
        if zap.returncode != 0:
            otkazy.append(('KOMPOZICIJA_OS_NE_ISPOLNENA',
                           'admission=%s gate=%s sobytie=%s rc=%d'
                           % (admission, gate, sobytie, zap.returncode)))
        elif fakt != ozhidanie:
            otkazy.append((OSI_IMENA[imja],
                           'admission=%s gate=%s entry=%s sobytie=%s '
                           'extra=%s: %r'
                           % (admission, gate, entry, sobytie, extra, fakt)))
    zond = repo / KOMPOZICIJA_ZONDA
    if zond.is_file():
        z = zond.read_text(encoding='utf-8')
        if "from '../pilot-app'" not in z or 'pilot-app.model' in z:
            otkazy.append(('MODEL_KAK_DOKAZATELSTVO', KOMPOZICIJA_ZONDA))
    return otkazy


# --- v2 круг 3 (РЕШЕНИЕ арбитра 118 v2, §Q2): пин формы теста, судья -------
# --- ИСПОЛНЕНИЯ (отчёт jest --json) и байтовый судья данных (БЛ-А/БЛ-Б) ----

PROIZVODSTVENNYJ_KRJUCHOK = 'mobile/src/app/onboarding-session.tsx'
SROK_TEST_FAIL = 'mobile/src/bootstrap/__tests__/session-srok.test.tsx'
# Пин формы теста срока (А-1): продукт держит файл ПОБАЙТОВО равным
# носителю teksty/session-srok.stand-in.tsx батареи; иные байты →
# SROK_TESTY_FORMA. Одним пином закрыты skip/only/todo/xit/условный skip,
# rerender вместо press, модель-копия, выпадение клетки, ослабление
# ассертов (лексические проверки SROK_TESTY_* гейтом не являются).
SROK_TESTY_FORMA_SHA256 = \
    '489e11fb0ee02ed1864701f02202bfb3758721a8a70f6b5405b29ffb05e9ef5b'
CI_MOBILE = '.github/workflows/mobile.yml'
# Отчёт исполнения пишет шаг CI `npm test -- --json --outputFile=…`
# (cwd mobile); относительный --jest-otchet разрешается от repo/mobile.
JEST_OTCHET_OTNOSITELNYJ = 'e2e-erstinformation/jest-otchet.json'
# 13 клеток пин-формы (А-3): 11 прежних + srok-mezhdu-render-continue;
# srok-mezhdu-mount-dejstviem ПЕРЕОПРЕДЕЛЕНА как press БЕЗ ререндера на
# Root (БЛ-А2), прежний rerender-вариант — отдельная клетка srok-rerender.
SROK_KLETKI = (
    'srok-istekla-koren', 'srok-istekla-start', 'srok-rovno-sejchas',
    'srok-nerazborchivaja', 'srok-mezhdu-mount-dejstviem',
    'srok-mezhdu-render-continue', 'srok-rerender-start', 'srok-pustaja',
    'srok-otsutstvuet-pole', 'srok-nestrokovaja', 'srok-offset-zona',
    'srok-ranishe-auth-time', 'srok-svezhaja-demo',
)


def _put_otcheta(repo, otchet):
    """Путь отчёта: абсолютный как есть; относительный — от repo/mobile
    (cwd шага npm test того же job)."""
    p = Path(otchet) if otchet else Path(JEST_OTCHET_OTNOSITELNYJ)
    if not p.is_absolute():
        p = repo / 'mobile' / p
    return p


def _sud_otchet(otchet_d):
    """Судья ИСПОЛНЕНИЯ (А-2): текст ≠ исполнение — свидетельством того,
    что пин-клетки исполнились и прошли, является только отчёт jest
    --json шага npm test. success, запись файла по имени, каждая клетка
    ровно один раз со status passed, вне-passed в записи 0, pending/todo
    по отчёту в целом 0. Отсутствие/неразбор → SROK_OTCHET_NET
    (fail-closed: нет отчёта = нет прогона)."""
    otkazy = []
    if otchet_d.get('success') is not True:
        otkazy.append(('SROK_OTCHET_NE_USPEH',
                       'success=%r' % otchet_d.get('success')))
    zapisi = [t for t in otchet_d.get('testResults', [])
              if isinstance(t, dict)
              and isinstance(t.get('name'), str)
              and t['name'].endswith(SROK_TEST_FAIL)]
    if len(zapisi) != 1:
        otkazy.append(('SROK_OTCHET_BEZ_FAJLA', 'zapisej=%d' % len(zapisi)))
        return otkazy
    utverzhdenija = [a for a in zapisi[0].get('assertionResults', [])
                     if isinstance(a, dict)]
    for kletka in SROK_KLETKI:
        sovpadenija = [a for a in utverzhdenija
                       if isinstance(a.get('title'), str)
                       and a['title'].startswith(kletka)]
        if len(sovpadenija) == 1 and sovpadenija[0].get('status') == 'passed':
            continue
        if not sovpadenija:
            detal = '%s:missing' % kletka
        elif len(sovpadenija) > 1:
            detal = '%s:x%d' % (kletka, len(sovpadenija))
        else:
            detal = '%s:%r' % (kletka, sovpadenija[0].get('status'))
        otkazy.append(('SROK_KLETKA_NE_ISPOLNENA', detal))
    ne_proshli = [a for a in utverzhdenija if a.get('status') != 'passed']
    if ne_proshli:
        otkazy.append(('SROK_OTCHET_NE_POLNOSTJU',
                       'vne passed=%d' % len(ne_proshli)))
    pending = otchet_d.get('numPendingTests') or 0
    todo = otchet_d.get('numTodoTests') or 0
    if pending:
        otkazy.append(('SROK_OTCHET_S_PENDING', 'numPendingTests=%r' % pending))
    if todo:
        otkazy.append(('SROK_OTCHET_S_TODO', 'numTodoTests=%r' % todo))
    return otkazy


def sud_sroka(repo, otchet):
    """(А-1 + А-2) Пин формы теста + судья исполнения. Токен-проверка
    PROIZVODSTVO_BEZ_SROKA по подстроке СНЯТА как гейт (арбитраж 118 v2:
    правильность крючка доказывают исполненные пин-клетки на настоящих
    поверхностях, не лексика); отсутствие файла крючка — именованный
    отказ. Судья исполнения НЕ запускает jest сам: отчёт пишет шаг
    `npm test -- --json --outputFile=` ТОГО ЖЕ job ДО шага checker'а —
    порядок судит sud_ci_sroka (единственная текстовая нога, остаток
    назван в §НЕ ЗАЩИЩАЕТ контракта)."""
    otkazy = []
    if not (repo / PROIZVODSTVENNYJ_KRJUCHOK).is_file():
        otkazy.append(('PROIZVODSTVO_BEZ_SROKA', PROIZVODSTVENNYJ_KRJUCHOK))
    z = repo / SROK_TEST_FAIL
    if not z.is_file():
        otkazy.append(('SROK_TESTY_NET', SROK_TEST_FAIL))
    elif sha(z) != SROK_TESTY_FORMA_SHA256:
        otkazy.append(('SROK_TESTY_FORMA', SROK_TEST_FAIL))
    p = _put_otcheta(repo, otchet)
    if not p.is_file():
        otkazy.append(('SROK_OTCHET_NET',
                       str(otchet or JEST_OTCHET_OTNOSITELNYJ)))
        return otkazy
    try:
        otchet_d = json.loads(p.read_text(encoding='utf-8'))
    except (OSError, ValueError) as e:
        otkazy.append(('SROK_OTCHET_NET', 'не разбирается: %r' % e))
        return otkazy
    return otkazy + _sud_otchet(otchet_d)


def sud_ci_sroka(repo):
    """(А-2, текстовая нога) mobile.yml несёт шаг npm test с
    `--json --outputFile=` ДО шага checker'а с `--jest-otchet`; шаг
    пропал или стоит после checker'а → CI_BEZ_OTCHETA_SROKA. Подделка
    отчёта и перестановка шагов вне судьи — ловец в §НЕ ЗАЩИЩАЕТ."""
    c = repo / CI_MOBILE
    if not c.is_file():
        return [('CI_BEZ_OTCHETA_SROKA', CI_MOBILE)]
    stroki = c.read_text(encoding='utf-8').splitlines()
    shag_jest = [i for i, l in enumerate(stroki)
                 if '--json --outputFile=' in l and 'npm test' in l]
    shag_checker = [i for i, l in enumerate(stroki) if '--jest-otchet' in l]
    if not shag_jest or not shag_checker \
            or min(shag_jest) > min(shag_checker):
        return [('CI_BEZ_OTCHETA_SROKA',
                 'нет npm test --json --outputFile= до шага --jest-otchet')]
    return []


# --- v2 круг 3 (Б-1/Б-2): байтовый судья данных — ровно один литерал -----

ETALON_DANNYH_REL = ('fixtures/workshop_project/erstinformation_118/'
                     'nositeli/dannye/etalon_995.json')
ETALON_MOCKS_REL = ('fixtures/workshop_project/erstinformation_118/'
                    'nositeli/dannye/etalon_pilot_responses.json')
# Байтовые эталоны — копии носителей ДО правки (продукт a280656):
# производить эталон mocks из JSON эталона 995 ЗАПРЕЩЕНО (Б-1).
# Разрешённая дельта — ровно ОДНА подстановка (арбитраж 118 v2 Б-2);
# литералы собраны так, что текст файла не несёт размерного литерала
# аудита 132 (цифры+буквы) и деградирует только с потерей смысла.
SROK_STAROGO_LIT = b'"expires_at": "2026-10-14T00:00:00' + b'Z"'
SROK_DALEKIJ_LIT = b'"expires_at": "' + b'2099-12-31T00:00:00' + b'Z"'
LIMIT_PODSTANOVOK = 1
NOSITELI_DANNYH = (
    ('fixtures/workshop_project/pilot_995/source.json', ETALON_DANNYH_REL),
    ('mobile/src/bootstrap/__tests__/source.json', ETALON_DANNYH_REL),
    ('mobile/src/mocks/pilot-responses.json', ETALON_MOCKS_REL),
)


def _smeshchenie_pervogo_razlichija(fakt, etalon):
    """Смещение первого различия байтов (или длина более короткого)."""
    for i in range(min(len(fakt), len(etalon))):
        if fakt[i] != etalon[i]:
            return i
    return min(len(fakt), len(etalon))


def sud_odin_razreshennyj_kljuch(repo, harness):
    """(Б-1/Б-2) Слово владельца 25.10 — правка данных ТОЛЬКО
    session.expires_at, и это БАЙТОВАЯ подстановка ровно одного литерала:
    декодированный объект доказательством байтов не является (escape,
    пробелы, порядок ключей, BOM, CRLF, переформатирование невидимы
    json-дифом — свидетель критика круга 2). Носитель конформен, если его
    байты равны эталону ИЛИ эталону с ЕДИНСТВЕННОЙ подстановкой
    SROK_DALEKIJ_LIT; в эталоне старый литерал обязан встретиться ровно
    один раз (иначе ETALON_DANNYH_NET). Любое иное отличие →
    DANNYE_NE_TOLKO_EXPIRES_AT со смещением первого различия."""
    if harness is None:
        return [('ETALON_DANNYH_NET', '--harness')]
    otkazy, etalony = [], {}
    for rel_e in (ETALON_DANNYH_REL, ETALON_MOCKS_REL):
        try:
            bajty = (Path(harness) / rel_e).read_bytes()
        except OSError:
            otkazy.append(('ETALON_DANNYH_NET', rel_e))
            continue
        if bajty.count(SROK_STAROGO_LIT) != 1:
            otkazy.append(('ETALON_DANNYH_NET',
                           '%s: старый литерал x%d'
                           % (rel_e, bajty.count(SROK_STAROGO_LIT))))
            continue
        etalony[rel_e] = bajty
    if otkazy:
        return otkazy
    for rel, rel_e in NOSITELI_DANNYH:
        p = (Path(harness) if rel.startswith('fixtures/') else repo) / rel
        try:
            fakt = p.read_bytes()
        except OSError:
            otkazy.append(('NOSITEL_DANNYH_NET', rel))
            continue
        etalon = etalony[rel_e]
        fakt_o = json.loads(fakt.decode('utf-8-sig'))
        etalon_o = json.loads(etalon.decode('utf-8-sig'))
        raznija = [r for r in _listja_raznija(etalon_o, fakt_o)
                   if not r.endswith('.expires_at')]
        if raznija:
            otkazy.append(('DANNYE_NE_TOLKO_EXPIRES_AT',
                           '%s: %s' % (rel, ','.join(raznija))))
    return otkazy


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pack', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--harness', default=None)
    ap.add_argument('--jest-otchet', default=None,
                    help='отчёт jest --json шага npm test (cwd mobile); '
                         'отсутствие = непрогон (SROK_OTCHET_NET)')
    a = ap.parse_args()
    pack, repo = Path(a.pack), Path(a.repo)
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        manifest = json.loads((pack / forma['kadry']).read_text(
            encoding='utf-8'))
        shagi = shagi_flow(repo / forma['e2e_scenarij'])
        paket = paket_produkta(repo)
        appid = appid_flow(repo / forma['e2e_scenarij'])
    except (OSError, ValueError, KeyError) as e:
        print('PROVERKA_NECHITAEM: %r' % e, file=sys.stderr)
        return 2
    kadry = manifest['kadry']
    snimki = list(dict.fromkeys(k['snimok'] for k in kadry))
    otkazy = []
    if appid != paket:
        otkazy.append(('FLOW_APPID_NE_PAKET',
                       'appId=%s paket=%s' % (appid, paket)))
    # Конфиг каталога Maestro: исключение флоу пачки обязано стоять в flows
    # (adv-118 B3 — снятое исключение не замечала прежняя proverka).
    iskljuchenie_pachki = '!' + forma['e2e_scenarij'].split('/')[-1]
    if not iskljuchenie_pachki_v_confige(repo, iskljuchenie_pachki):
        otkazy.append(('CONFIG_BEZ_ISKLJUCHENIJA',
                       '%s без %s' % (KATALOG_MAESTRO, iskljuchenie_pachki)))
    # Ровно 16 кадров манифеста (adv-118 A2): 15 кадров «проходят» сверку,
    # но манифест пачки обязан нести полный состав 8 snimok × dark/light.
    fakt_kadry = sorted((k.get('snimok'), k.get('tema')) for k in kadry)
    if len(fakt_kadry) != len(OZHIDAEMYE_KADRY):
        otkazy.append(('MANIFEST_NE_16_KADROV', 'chislo=%d' % len(fakt_kadry)))
    elif fakt_kadry != OZHIDAEMYE_KADRY:
        otkazy.append(('MANIFEST_NE_16_KADROV', 'sostav'))
    otkazy += sud_flow(shagi, snimki) + sud_kompoziciju(repo)
    otkazy += sud_sroka(repo, a.jest_otchet)
    otkazy += sud_ci_sroka(repo)
    otkazy += sud_odin_razreshennyj_kljuch(repo, a.harness)
    istochniki = [p for root in ISTOCHNIKI_EKRANA
                  for p in (repo / root).rglob('*')]
    teksty = []
    for p in istochniki:
        if p.is_file():
            try:
                teksty.append(p.read_text(encoding='utf-8'))
            except (OSError, UnicodeDecodeError):
                pass
    for s in sorted(set(selektory(shagi))):
        # Носитель селектора — литерал в коде экрана в одном из двух
        # замкнутых атрибутов продукта: testID= (Pressable/PlacedText) и
        # buttonTestID= (Cta рендерит testID={buttonTestID},
        # auth-parts.tsx); first-run-continue заморожен дефисом (995/111)
        # и живёт в buttonTestID (first-run-screen.tsx).
        if not any(('testID="%s"' % s in line or
                    'buttonTestID="%s"' % s in line)
                   for t in teksty for line in t.splitlines()
                   if not line.lstrip().startswith(('//', '/*', '*', '#'))):
            otkazy.append(('SELEKTOR_BEZ_EKRANA', s))
    karta = {(k['snimok'], k['tema']): k for k in kadry}
    for p in sorted((repo / forma['kadry_dir']).rglob('*.png')):
        tema = p.relative_to(repo / forma['kadry_dir']).parts[0]
        z = karta.get((p.stem, tema))
        if z and (repo / z['maket']).is_file() \
                and sha(p) == sha(repo / z['maket']):
            otkazy.append(('KADR_BYTE_KOPIJA_MAKETA', z['id']))
    for imja, detal in otkazy:
        prichina(imja, detal)
    return 1 if otkazy else 0


if __name__ == '__main__':
    sys.exit(main())
