# Стаб s21_selektor_propuskaet: ветвь SELEKTOR_BEZ_EKRANA не судится (мутация ровно одной ветви проверки происхождения, Н-39).
#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 116, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132. Судит: вход в Mission из Start (вкладка, не deep link),
# переход перед каждым кадром, свой селектор кадра перед каждым
# takeScreenshot, жест черновика (ввод текста до вложения/отправки),
# жест вложения (меню + чип), побайтовую копию макета и СТРУКТУРНУЮ пробу
# четырёх кадров без PNG (F05.07, V01, V02, V04 — слово владельца 17:40:
# по компонентам и токенам D2.2.5.1, сверка с макетом после пакета
# дизайнера): копия только из каталога, токен только из tokens.css,
# testID объявлен и есть assertVisible в потоке.
# rc 1 — PRICHINA; rc 2 — нечитаемый вход.
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

PEREHODY = ('tapOn', 'inputText', 'pressKey', 'swipe')
ZAPUSKI = ('launchApp',)
ISTOCHNIKI_EKRANA = ('mobile/src/features/conversation', 'mobile/src/app')
VHOD_STARTA = 'start_tab_start'
DRAFT_GEST = 'mission_composer_input'
VLOZHENIE_MENJU = 'mission_attach'
VLOZHENIE_CHIP = 'mission_frame_f05_v03'


def prichina(imja, detal):
    print('PRICHINA\t%s\t%s' % (imja, detal), file=sys.stderr)


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def shagi_flow(path):
    out = []
    for line in path.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if line.startswith('- '):
            shag = line[2:]
            out.append(shag)
    return out


def id_iz(arg):
    if 'id:' not in arg:
        return None
    t = arg.partition('id:')[2].strip()
    t = t.split('}')[0].split(',')[0]
    return t.strip().strip("'\"")


def sud_potok(shagi, snimki):
    otkazy = []
    zapuski = [s for s in shagi if s.split(':')[0].strip() in ZAPUSKI]
    if not zapuski:
        otkazy.append(('FLOW_BEZ_ZAPUSKA', 'launchApp'))
    if not any('assertVisible' in s and id_iz(s) == VHOD_STARTA for s in shagi):
        otkazy.append(('FLOW_BEZ_START_VHODA', VHOD_STARTA))
    elif not any(s.startswith('tapOn') and id_iz(s) == VHOD_STARTA
                 for s in shagi):
        otkazy.append(('FLOW_BEZ_START_VHODA', 'tapOn ' + VHOD_STARTA))
    perehody = [s for s in shagi if s.split(':')[0].strip() in PEREHODY]
    if not perehody:
        otkazy.append(('FLOW_BEZ_PEREHODA', 'tapOn/inputText'))
    for snimok, selektor in snimki:
        est_assert = any('assertVisible' in s and id_iz(s) == selektor
                         for s in shagi)
        if not est_assert:
            otkazy.append(('FLOW_BEZ_DOSTIZHENIJA', snimok))
        idx = [i for i, s in enumerate(shagi)
               if s.startswith('takeScreenshot') and snimok in s]
        if not idx:
            otkazy.append(('SELEKTOR_NE_KADRA', snimok))
            continue
        i = idx[0]
        do = [s for s in shagi[:i] if s.split(':')[0].strip() in PEREHODY
              or s.split(':')[0].strip() in ZAPUSKI]
        if not do:
            otkazy.append(('FLOW_BEZ_DEMO_VHODA', snimok))
    return otkazy


def sud_gesty(shagi):
    """Ось черновика и вложения (урок 111: свойство по жесту, не по точке)."""
    otkazy = []
    vvod = [i for i, s in enumerate(shagi)
            if s.startswith('inputText') and DRAFT_GEST in s]
    if not vvod:
        otkazy.append(('FLOW_BEZ_CHERNOVIKA', DRAFT_GEST))
    attach = [i for i, s in enumerate(shagi)
              if s.startswith('tapOn') and id_iz(s) == VLOZHENIE_MENJU]
    if not attach:
        otkazy.append(('FLOW_BEZ_VLOZHENIJA', VLOZHENIE_MENJU))
    elif not vvod or min(attach) < min(vvod):
        otkazy.append(('FLOW_CHERNOVIK_POSLE_VLOZHENIJA', DRAFT_GEST))
    chip = [i for i, s in enumerate(shagi)
            if 'assertVisible' in s and id_iz(s) == VLOZHENIE_CHIP]
    if not chip:
        otkazy.append(('FLOW_BEZ_VLOZHENIJA', VLOZHENIE_CHIP))
    return otkazy


def sud_selektory(repo, shagi):
    otkazy = []
    est = set()
    for koren in ISTOCHNIKI_EKRANA:
        d = repo / koren
        if d.is_dir():
            for f in d.rglob('*'):
                if f.is_file():
                    est |= {t for t in re.findall(
                        r'testID="([a-z0-9_]+)"',
                        f.read_text(encoding='utf-8', errors='replace'))}
    for s in shagi:
        i = id_iz(s)
        if i and i not in est:
    return otkazy


def sud_byte_kopii(repo, manifest):
    otkazy = []
    for k in manifest['kadry']:
        snimok = repo / 'mobile/e2e-nositeli' / k['tema'] / (k['snimok'] + '.png')
        if snimok.is_file() and sha(snimok) == k['maket_sha256']:
            otkazy.append(('KADR_BYTE_KOPIJA_MAKETA', k['id']))
    return otkazy


def sud_bezpng(pack, repo, shagi):
    """Кадры без PNG: структурная проба вместо сверки с макетом."""
    otkazy = []
    p = pack / 'sostojanija_bez_png.json'
    if not p.is_file():
        return [('BEZPNG_BEZ_OPISANIJA', 'sostojanija_bez_png.json')]
    try:
        opis = json.loads(p.read_text(encoding='utf-8'))
    except ValueError:
        return [('BEZPNG_BEZ_OPISANIJA', 'sostojanija_bez_png.json')]
    katalog = json.loads((repo / 'mobile/e2e-mission/katalog_kopii.json'
                          ).read_text(encoding='utf-8'))
    tokens = (repo / 'docs/ux/03_Mobility_Slice1/ds'
              / 'tokens.css').read_text(encoding='utf-8')
    imena_tokenov = set(re.findall(r'(--[a-z0-9-]+)\s*:', tokens))
    for kadr in opis.get('kadry_bez_png', []):
        for kljuch in kadr.get('kljuchi_kopii', []):
            if kljuch not in katalog:
                otkazy.append(('BEZPNG_KOPIJA_VNE_KATALOGA',
                               '%s %s' % (kadr.get('id'), kljuch)))
        for token in kadr.get('tokeny', []):
            if token not in imena_tokenov:
                otkazy.append(('BEZPNG_TOKEN_VNE_AUDITA',
                               '%s %s' % (kadr.get('id'), token)))
        testid = kadr.get('testid')
        if not testid:
            otkazy.append(('BEZPNG_BEZ_TESTID', kadr.get('id')))
        elif not any('assertVisible' in s and id_iz(s) == testid
                     for s in shagi):
            otkazy.append(('BEZPNG_BEZ_TESTID_V_POTOKE', testid))
    return otkazy


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pack', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--harness', default=None)
    a = ap.parse_args()
    pack, repo = Path(a.pack), Path(a.repo)
    flow = repo / 'mobile/.maestro/mission.yaml'
    if not flow.is_file():
        print('PRICHINA\tNECHITAEMYJ_VHOD\tmobile/.maestro/mission.yaml',
              file=sys.stderr)
        return 2
    shagi = shagi_flow(flow)
    manifest = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    snimki = [(k['snimok'],
               'mission_frame_' + k['snimok'].replace('mission-', '')
               .replace('-', '_')) for k in manifest['kadry']]
    otkazy = []
    otkazy += sud_potok(shagi, snimki)
    otkazy += sud_gesty(shagi)
    otkazy += sud_selektory(repo, shagi)
    otkazy += sud_byte_kopii(repo, manifest)
    otkazy += sud_bezpng(pack, repo, shagi)
    for imja, detal in otkazy:
        prichina(imja, detal)
    return 1 if otkazy else 0


if __name__ == '__main__':
    sys.exit(main())
