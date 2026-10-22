#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 118, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132. Судит переход от production First-Run через demo и gate к
# Start, наличие testID каждого шага, состав вкладок Start (не только узел
# start_tabs), ось admission композиции pilot-app на полном current-снимке
# (W0 не допускается, W1A допускается; источник — проверяющий) и побайтовую
# копию макета. В CI продукта пускается ПОСЛЕ валидатора 132 (тот вызывает
# Maestro), БЕЗ промежуточной правки кадров. rc 1 — PRICHINA; rc 2 — нечитаемый вход.
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
    if not ordered([('launchApp', ''), ('assertVisible', 'first_run_demo_entry'),
                    ('tapOn', 'first_run_demo_entry'),
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
KOMPOZICIJA_OSI = (('W0', 'current', 'start_ne_dopushchen'),
                   ('W1A', 'current', 'start_dopushchen'))


def sud_kompoziciju(repo):
    """Ось admission на production-шве (вердикт круга 2): проба композиции
    pilot-app обязана подавать экрану 107 ФАКТИЧЕСКИЙ admission пользователя;
    W0 при полном current-снимке НЕ допускается к Start, W1A — допускается.
    Источник admission — вызывающий проверяющий, не литерал в пробе."""
    otkazy = []
    p = repo / KOMPOZICIJA_PROBA
    if not p.is_file():
        return [('KOMPOZICIJA_NET', KOMPOZICIJA_PROBA)]
    for admission, gate, ozhidanie in KOMPOZICIJA_OSI:
        zap = subprocess.run(
            ['bash', str(p), admission, gate],
            capture_output=True, text=True, cwd=str(repo))
        fakt = zap.stdout.strip()
        if zap.returncode != 0 or fakt != ozhidanie:
            imja = ('KOMPOZICIJA_W0_PROPUSHCHEN' if admission == 'W0'
                    else 'KOMPOZICIJA_W1A_NE_DOPUSHCHEN')
            otkazy.append((imja, 'admission=%s gate=%s: %r rc=%d'
                           % (admission, gate, fakt, zap.returncode)))
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
    otkazy = sud_flow(shagi, snimki) + sud_kompoziciju(repo)
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
