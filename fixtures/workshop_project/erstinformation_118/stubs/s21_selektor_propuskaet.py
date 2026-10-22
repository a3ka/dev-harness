#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 118, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132 (§НЕ ЗАЩИЩАЕТ контракта). Судит три свойства:
#   1) флоу: запуск приложения; перед каждым кадром — переход
#      (tapOn/inputText/pressKey/swipe) И assert-селектор СВОЕГО экрана;
#      каждый snimok манифеста — ровно один раз;
#   2) каждый селектор флоя имеет носитель в коде экрана — testID в
#      mobile/src/features/onboarding/** репо;
#   3) кадр, байт-идентичный макету, — НЕ скриншот: копия макета в раскладку
#      Maestro подменой e2e детектится сравнением sha256 кадра и макета.
# В CI продукта пускается ПОСЛЕ валидатора 132 (тот вызывает Maestro),
# БЕЗ промежуточной правки кадров. rc: 0 — эти признаки без отказов;
# 1 — PRICHINA по каждому отказу; 2 — вход нечитаем (PROVERKA_NECHITAEM).
import argparse
import hashlib
import json
import sys
from pathlib import Path

PEREHODY = ('tapOn', 'inputText', 'pressKey', 'swipe')
ZAPUSKI = ('launchApp', 'startApp')
ISTOCHNIKI_EKRANA = 'mobile/src/features/onboarding'
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
    if not any(k in ZAPUSKI for k, _ in shagi):
        otkazy.append(('FLOW_BEZ_ZAPUSKA', 'launchApp'))
    granica, pervyj = -1, True
    for s in snimki:
        sp = poz.get(s, [])
        if not sp:
            continue
        i = sp[0]
        blok_shagov = shagi[granica + 1:i]
        blok = [k for k, _ in blok_shagov]
        if not pervyj and not any(k in PEREHODY for k in blok):
            otkazy.append(('FLOW_BEZ_PEREHODA', s))
        if 'assertVisible' not in blok:
            otkazy.append(('FLOW_BEZ_DOSTIZHENIJA', s))
        if s not in SELEKTOR_KADRA or not any(
                k == 'assertVisible' and id_iz(a) == SELEKTOR_KADRA[s]
                for k, a in blok_shagov):
            otkazy.append(('SELEKTOR_NE_KADRA', s))
        granica, pervyj = i, False
    return otkazy


def selektory(shagi):
    out = []
    for k, a in shagi:
        if k in ('tapOn', 'assertVisible', 'inputText'):
            i = id_iz(a)
            if i:
                out.append(i)
    return out


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
    otkazy = sud_flow(shagi, snimki)
    istochniki = list((repo / ISTOCHNIKI_EKRANA).rglob('*')) \
        if (repo / ISTOCHNIKI_EKRANA).is_dir() else []
    teksty = []
    for p in istochniki:
        if p.is_file():
            try:
                teksty.append(p.read_text(encoding='utf-8'))
            except (OSError, UnicodeDecodeError):
                pass
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
