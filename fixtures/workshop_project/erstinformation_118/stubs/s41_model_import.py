#!/usr/bin/env python3
# СТАБ s41_model_import (обманный проверяющий, отличие от честной пробы v2 —
# снята ветвь MODEL_KAK_DOKAZATELSTVO (зонд композиции не судится)).
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
# rc 1 — PRICHINA; rc 2 — нечитаемый вход.
import argparse
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
    if not ordered([('launchApp', ''), ('assertVisible', 'first_run_continue'),
                    ('tapOn', 'first_run_continue'),
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
    '3f8ef6189257e05d4a59e49d5eaeb42b9d6d6fbba9fc8f1184ab8d82e87f0be2'
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
    ('W1A', 'null', 'net', 'demo', 'net', '', 'erstinformation', 'POVERHNOST'),
    ('W1A', 'null', 'net', 'demo-continue', 'net', '',
     'start_ne_dopushchen', 'GATE'),
    ('W1A', 'stale', 'net', 'demo', 'net', '', 'erstinformation', 'POVERHNOST'),
    ('W1A', 'stale', 'net', 'demo-continue', 'net', '',
     'start_ne_dopushchen', 'GATE'),
    ('W1A', 'current', 'net', 'demo', 'net', '',
     'erstinformation', 'POVERHNOST'),
    ('W1A', 'current', 'net', 'demo-continue', 'net', '',
     'start_dopushchen', 'W1A'),
    ('W0', 'null', 'net', 'demo', 'net', '', 'f03-02-code', 'W0'),
    ('W0', 'stale', 'net', 'demo', 'net', '', 'f03-02-code', 'W0'),
    ('W0', 'current', 'net', 'demo', 'net', '', 'f03-02-code', 'W0'),
    ('W0', 'current', 'net', 'demo-continue', 'net', '',
     'start_ne_dopushchen', 'W0'),
    ('W0', 'current', 'complete', 'demo', 'net', '',
     'f03-02-code', 'ENTRY'),
    ('W0', 'current', 'complete', 'demo-continue', 'net', '',
     'start_ne_dopushchen', 'ENTRY'),
    ('W0', 'stale', 'net', 'demo', 'postoronnee-pole', '',
     'f03-02-code', 'POSTORONNEE'),
    ('W1A', 'stale', 'complete', 'demo-continue', 'entry-gate-current', '',
     'start_ne_dopushchen', 'GATE'),
    ('W1A', 'current', 'net', 'rerender-demo', 'net', 'W0',
     'f03-02-code', 'KESH'),
    ('W1A', 'current', 'net', 'rerender-continue', 'net', 'W0',
     'start_ne_dopushchen', 'KESH'),
    ('W0', 'stale', 'complete', 'remount', 'net', '', 'first-run', 'FIRST_RUN'),
    ('W1A', 'current', 'complete', 'montazh', 'net', '',
     'first-run', 'FIRST_RUN'),
    ('W1A', 'stale', 'net', 'tema', 'net', '', 'erstinformation', 'G0'),
    ('W0', 'stale', 'net', 'tema', 'net', '', 'f03-02-code', 'G0'),
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
    for admission, gate, entry, sobytie, extra, tek, ozhidanie, imja in \
            KOMPOZICIJA_OSI:
        args = [admission, gate, entry, sobytie, extra] + ([tek] if tek else [])
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
    return otkazy


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pack', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--harness', default=None)
    a = ap.parse_args()
    pack, repo = Path(a.pack), Path(a.repo)
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        manifest = json.loads((pack / forma['kadry']).read_text(
            encoding='utf-8'))
        shagi = shagi_flow(repo / forma['e2e_scenarij'])
    except (OSError, ValueError, KeyError) as e:
        print('PROVERKA_NECHITAEM: %r' % e, file=sys.stderr)
        return 2
    kadry = manifest['kadry']
    snimki = list(dict.fromkeys(k['snimok'] for k in kadry))
    otkazy = []
    # Ровно 16 кадров манифеста (adv-118 A2): 15 кадров «проходят» сверку,
    # но манифест пачки обязан нести полный состав 8 snimok × dark/light.
    fakt_kadry = sorted((k.get('snimok'), k.get('tema')) for k in kadry)
    if len(fakt_kadry) != len(OZHIDAEMYE_KADRY):
        otkazy.append(('MANIFEST_NE_16_KADROV', 'chislo=%d' % len(fakt_kadry)))
    elif fakt_kadry != OZHIDAEMYE_KADRY:
        otkazy.append(('MANIFEST_NE_16_KADROV', 'sostav'))
    otkazy += sud_flow(shagi, snimki) + sud_kompoziciju(repo)
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
        if not any('testID="%s"' % s in line
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
