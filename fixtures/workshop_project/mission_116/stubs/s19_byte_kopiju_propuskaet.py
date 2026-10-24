# Стаб s19_byte_kopiju_propuskaet: ветвь KADR_BYTE_KOPIJA_MAKETA не судится (мутация ровно одной ветви проверки происхождения, Н-39).
#!/usr/bin/env python3
# Проверка доступных свидетельств происхождения (контракт 116, файл пачки).
# НЕ аттестует процесс эмулятора: перекодированный replay остаётся риском
# шаблона 132. Судит: вход в Mission из Start (вкладка, не deep link),
# переход перед каждым кадром, свой селектор кадра перед каждым
# takeScreenshot, жест черновика (tapOn композера -> inputText ДО
# вложения/отправки; комментарий во флоу — НЕ свидетельство жеста),
# жест вложения (меню + чип), фазу V03 (pending-подпись наблюдается на
# pending-вложении; негативная проверка подписи — только ПОСЛЕ
# наблюдаемого успешного завершения upload, контейнер V03 сохранён),
# побайтовую копию макета и СТРУКТУРНУЮ пробу четырёх кадров без PNG
# (F05.07, V01, V02, V04 — слово владельца 17:40: по компонентам и
# токенам D2.2.5.1, сверка с макетом после пакета дизайнера): копия
# только из каталога, токен только из tokens.css, testID объявлен.
# 116 v3 (REPORT-116 §3 шаг 1): runFlow раскрывается — состояния без
# PNG достигаются СВОИМИ независимыми сценариями (собственный запуск,
# вход из Start, видимое ожидание), линейный хвост исключающих
# состояний в корневом флоу красен.
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
CHIP_LESET = 'mission_chip_wird_gelesen'
UPLOAD_PREFIKS = 'attachment-complete-'
KONTENER_V03 = 'mission_frame_f05_v03'
GLUBINA_RUNFLOW = 5


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


def cel_runflow(shag):
    """Файл дочернего сценария из шага runFlow (формы `runFlow: x.yaml`
    и `runFlow: {file: x.yaml}`); не-runFlow шаг — None."""
    if not shag.startswith('runFlow'):
        return None
    cel = shag.partition(':')
    if cel[1] != ':':
        return None
    t = cel[2].strip().strip("'\"")
    if t.startswith('{'):
        t = t.strip('{}').partition('file:')[2].strip().strip("'\"")
    return t.split('}')[0].strip().strip("'\"")


def raskroj_runflow(path, glubina=0):
    """Шаги флоу с раскрытыми runFlow (Maestro исполняет детей этим же
    прогоном); отказ — на отсутствующий файл и цикл, fail-closed."""
    shagi, otkazy = [], []
    for shag in shagi_flow(path):
        cel = cel_runflow(shag)
        if cel is None:
            shagi.append(shag)
            continue
        if glubina >= GLUBINA_RUNFLOW:
            otkazy.append(('RUNFLOW_CIKL', str(path.name)))
            continue
        rebyonok = path.parent / cel
        if not rebyonok.is_file():
            otkazy.append(('RUNFLOW_BEZ_FAJLA', cel))
            continue
        d_shagi, d_otkazy = raskroj_runflow(rebyonok, glubina + 1)
        shagi += d_shagi
        otkazy += d_otkazy
    return shagi, otkazy


def id_iz(arg):
    if 'id:' not in arg:
        return None
    t = arg.partition('id:')[2].strip()
    t = t.split('}')[0].split(',')[0]
    return t.strip().strip("'\"")


def sud_potok(shagi, snimki, shagi_kornja):
    """Запуск и вход из Start судятся по КОРНЕВОМУ флоу (основной путь
    входит сам, а не за счёт дочерних сценариев); кадры — по потоку."""
    otkazy = []
    zapuski = [s for s in shagi_kornja
               if s.split(':')[0].strip() in ZAPUSKI]
    if not zapuski:
        otkazy.append(('FLOW_BEZ_ZAPUSKA', 'launchApp'))
    if not any('assertVisible' in s and id_iz(s) == VHOD_STARTA
               for s in shagi_kornja):
        otkazy.append(('FLOW_BEZ_START_VHODA', VHOD_STARTA))
    elif not any(s.startswith('tapOn') and id_iz(s) == VHOD_STARTA
                 for s in shagi_kornja):
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
    """Ось черновика и вложения (урок 111: свойство по жесту, не по
    точке; S1 Rev116c: комментарий флоу — НЕ свидетельство). Жест
    черновика = tapOn композера + ПОСЛЕДУЮЩИЙ inputText (Maestro
    печатает в сфокусированное поле, селектор id внутри inputText не
    принимается). Судится по корневому флоу (основной путь)."""
    otkazy = []
    tap = [i for i, s in enumerate(shagi)
           if s.startswith('tapOn') and id_iz(s) == DRAFT_GEST]
    vvod = [i for i, s in enumerate(shagi)
            if s.split(':')[0].strip() == 'inputText']
    attach = [i for i, s in enumerate(shagi)
              if s.startswith('tapOn') and id_iz(s) == VLOZHENIE_MENJU]
    chip = [i for i, s in enumerate(shagi)
            if 'assertVisible' in s and id_iz(s) == VLOZHENIE_CHIP]
    if not tap or not vvod or not any(t < v for t in tap for v in vvod):
        otkazy.append(('FLOW_BEZ_CHERNOVIKA', DRAFT_GEST))
    if not attach:
        otkazy.append(('FLOW_BEZ_VLOZHENIJA', VLOZHENIE_MENJU))
    elif not any(t < v < min(attach) for t in tap for v in vvod):
        otkazy.append(('FLOW_CHERNOVIK_POSLE_VLOZHENIJA', DRAFT_GEST))
    if not chip:
        otkazy.append(('FLOW_BEZ_VLOZHENIJA', VLOZHENIE_CHIP))
    return otkazy


def sud_chip_upload(shagi):
    """Фаза V03 (REPORT-116 §1.2/§3 шаг 1 п.3): pending-подпись
    наблюдается как pending ДО загрузки; негативная проверка подписи —
    только ПОСЛЕ наблюдаемого жеста завершения upload (onComplete), при
    сохранившемся контейнере вложения V03 (подпись исчезает, контейнер
    остаётся)."""
    otkazy = []
    upload = [i for i, s in enumerate(shagi)
              if s.startswith('tapOn') and (id_iz(s) or '').startswith(
                  UPLOAD_PREFIKS)]
    chip_do = [i for i, s in enumerate(shagi)
               if 'assertVisible' in s and id_iz(s) == CHIP_LESET]
    chip_neg = [i for i, s in enumerate(shagi)
                if 'assertNotVisible' in s and id_iz(s) == CHIP_LESET]
    kontener = [i for i, s in enumerate(shagi)
                if 'assertVisible' in s and id_iz(s) == KONTENER_V03]
    if not chip_do:
        otkazy.append(('FLOW_BEZ_CHIP_PENDING', CHIP_LESET))
    if not upload:
        otkazy.append(('FLOW_BEZ_UPLOAD_PEREHODA', UPLOAD_PREFIKS + '*'))
    else:
        if chip_neg and min(chip_neg) < min(upload):
            otkazy.append(('FLOW_CHIP_NEG_DO_UPLOADA', CHIP_LESET))
        if chip_neg and not any(k > min(upload) for k in kontener):
            otkazy.append(('FLOW_BEZ_V03_POSLE_UPLOADA', KONTENER_V03))
    if chip_do and upload and max(chip_do) > min(upload):
        otkazy.append(('FLOW_CHIP_POSLE_UPLOADA', CHIP_LESET))
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
                        r'testID="([A-Za-z0-9_-]+)"',
                        f.read_text(encoding='utf-8', errors='replace'))}
    for s in shagi:
        i = id_iz(s)
        if i and i not in est:
            otkazy.append(('SELEKTOR_BEZ_EKRANA', i))
    return otkazy


def sud_byte_kopii(repo, manifest):
    otkazy = []
    for k in manifest['kadry']:
        snimok = repo / 'mobile/e2e-nositeli' / k['tema'] / (k['snimok'] + '.png')
        if snimok.is_file() and sha(snimok) == k['maket_sha256']:
            pass  # ветвь удалена (стаб)
    return otkazy


def sud_bezpng(pack, repo, shagi_kornja, shagi):
    """Кадры без PNG: структурная проба вместо сверки с макетом; 116 v3 —
    каждое состояние достигается СВОИМ независимым сценарием (runFlow),
    линейный хвост в корне красен."""
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
            continue
        if any('assertVisible' in s and id_iz(s) == testid
               for s in shagi_kornja):
            otkazy.append(('BEZPNG_V_KORNE', testid))
        if not any('assertVisible' in s and id_iz(s) == testid
                   for s in shagi):
            otkazy.append(('BEZPNG_BEZ_TESTID_V_POTOKE', testid))
        scenarij = kadr.get('scenarij')
        if not scenarij:
            otkazy.append(('BEZPNG_BEZ_SCENARIJA', kadr.get('id')))
            continue
        f = repo / 'mobile/.maestro' / scenarij
        if not f.is_file():
            otkazy.append(('RUNFLOW_BEZ_FAJLA', scenarij))
            continue
        shagi_sc = shagi_flow(f)
        if not any(s.split(':')[0].strip() in ZAPUSKI for s in shagi_sc):
            otkazy.append(('RUNFLOW_SCENARIJ_BEZ_ZAPUSKA', scenarij))
        if not any('assertVisible' in s and id_iz(s) == VHOD_STARTA
                   for s in shagi_sc):
            otkazy.append(('RUNFLOW_SCENARIJ_BEZ_START_VHODA', scenarij))
        elif not any(s.startswith('tapOn') and id_iz(s) == VHOD_STARTA
                     for s in shagi_sc):
            otkazy.append(('RUNFLOW_SCENARIJ_BEZ_START_VHODA',
                           'tapOn ' + VHOD_STARTA))
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
    shagi_kornja = shagi_flow(flow)
    shagi, otkazy = raskroj_runflow(flow)
    manifest = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    snimki = [(k['snimok'],
               'mission_frame_' + k['snimok'].replace('mission-', '')
               .replace('-', '_')) for k in manifest['kadry']]
    otkazy += sud_potok(shagi, snimki, shagi_kornja)
    otkazy += sud_gesty(shagi_kornja)
    otkazy += sud_chip_upload(shagi_kornja)
    otkazy += sud_selektory(repo, shagi)
    otkazy += sud_byte_kopii(repo, manifest)
    otkazy += sud_bezpng(pack, repo, shagi_kornja, shagi)
    for imja, detal in otkazy:
        prichina(imja, detal)
    return 1 if otkazy else 0


if __name__ == '__main__':
    sys.exit(main())
