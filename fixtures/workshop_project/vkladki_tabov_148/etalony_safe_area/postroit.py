#!/usr/bin/env python3
# Производные эталоны safe-area профиля 393 (слово владельца 22.11
# ~10:53, п.(6)«Д» + А-964): эталон экрана на 393 = кадр D24-390 +
# системные полосы 393 (контент неизменен), маска chrome_verh_pt 48.
"""Детерминированное построение производных эталонов 393 из кадров
D24-390 пакета D24-Kompakt-1.1.

Геометрия — из ЕДИНОГО источника оракула батареи (../source.json):
  vyrez/home   — ekran_forma_prod.vtoroj_profil (59/34, профиль
                 iphone-safe-area; те же числа — PROFILE_393 продукта);
  nav.height   — nositeli/tokeny-1-1.json (ветка $value пакета 1.1);
  polosa_390   — kadry_manifest.mera.chrome_verh_pt (36 — полоса
                 системной шапки кадров 390 пакета).

Операции над кадром-основой 390x844 (контент НЕпересэмплирован —
«контент неизменен», все строки основы ложатся 1:1):
  1) канва 393x852, сплошная заливка фоном (пиксель (0,0) основы);
  2) контент: строки 36..745 основы -> строки 59..768 канвы (полотно
     под вырезом 59; видимая часть до лейсте на 769);
  3) лейсте: строки 795..843 основы (nav.height 49 у нижнего края)
     -> строки 769..817 канвы (над домашней полосой 34);
  4) столбцы 390..392 — заливка фоном (окно 393 шире артборда 390).
Строки 0..58 (вырез) и 818..851 (домашняя полоса) — системные полосы:
в сверке они закрыты масками chrome_verh_pt 48 / chrome_niz_pt 20,
порог сравнения НЕ меняется (0.600, поле porog каждой записи).

PNG-кодек — produkt_sud.py батареи (единый источник, без копии).

CLI:
  (без аргументов)  построить 8 эталонов + manifest.json рядом;
                     байты воспроизводимы: повторный запуск на тех же
                     входах и той же версии инструментов даёт те же
                     sha256 (проверяется прогоном --proverit)
  --proverit         перестроить в одноразовый каталог и сверить
                     sha256 с manifest.json; rc 0 — детерминировано,
                     rc 1 — ETALON_DERIVACIJA_NE_VOSPROIZVODIMA (имя),
                     rc 2 — предпосылки (нет источника/оракула).
"""
import importlib.util
import json
import re
import shutil
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
BATAREJA = HERE.parent

_spec = importlib.util.spec_from_file_location(
    'produkt_sud_148_etalony', BATAREJA / 'produkt_sud.py')
_ps = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_ps)
png_dekodirovat = _ps._png_dekodirovat
png_kodirovat = _ps._png_kodirovat_rgba
sha256_fajla = _ps.sha256_fajla


def konstanty(src):
    """Числа построения — только из source.json (второй источник
    запрещён): ValueError с именем, если ветви нет."""
    vp = src['ekran_forma_prod']['vtoroj_profil']
    vyrez, home = int(vp['vyrez']), int(vp['home'])
    tokeny = json.loads((BATAREJA / 'nositeli' / 'tokeny-1-1.json')
                        .read_text(encoding='utf-8'))
    m = re.match(r'\A(\d+)px\Z', str(tokeny['nav']['height']['$value']))
    if m is None:
        raise ValueError('nav.height.$value не Npx')
    nav_h = int(m.group(1))

    polosa_390 = int(src['kadry_manifest']['mera']['chrome_verh_pt'])
    return {'vyrez': vyrez, 'domashnjaja_polosa': home,
            'nav_height': nav_h, 'polosa_390': polosa_390}


def postavit(osnova_blob, k):
    """Кадр-основа 390x844 -> производный эталон 393x852 (1:1 строки)."""
    w, h, ch, rows = png_dekodirovat(osnova_blob)
    if (w, h) != (390, 844):
        raise ValueError('основа %dx%d != 390x844' % (w, h))
    fon = bytes(rows[0][0:4]) if ch == 4 else bytes(rows[0][0:3]) + b'\xff'
    W, H = 393, 852
    leiste_verh = H - k['domashnjaja_polosa'] - k['nav_height']  # 769
    kontent_dna = leiste_verh - 1                                # 768
    kontent_span = kontent_dna - k['vyrez'] + 1                  # 710
    kanva = [bytearray(fon * W) for _ in range(H)]

    def vlozhit(src_y0, kanva_y0, span):
        for i in range(span):
            stroka, cel = rows[src_y0 + i], kanva[kanva_y0 + i]
            for x in range(w):
                if ch == 4:
                    cel[x * 4:x * 4 + 4] = stroka[x * 4:x * 4 + 4]
                else:
                    cel[x * 4:x * 4 + 3] = stroka[x * 3:x * 3 + 3]

    vlozhit(k['polosa_390'], k['vyrez'], kontent_span)
    vlozhit(h - k['nav_height'], leiste_verh, k['nav_height'])
    return png_kodirovat(W, H, 4, [bytes(r) for r in kanva])


def osnovy(src):
    """[(id, imja_osnovy_390, sha_пина)] из kadry_manifest (390) —
    каждый пин сверяется с piny.nositeli ДО построения (правило 8)."""
    pary = []
    for z in src['kadry_manifest']['kadry']:
        imja = Path(z['maket']).name
        pin = src['piny']['nositeli']['nositeli/maket/' + imja]
        if sha256_fajla(BATAREJA / 'nositeli' / 'maket' / imja) != pin:
            raise ValueError('nositeli/maket/%s != пину оракула' % imja)
        if z['maket_sha256'] != pin:
            raise ValueError('kadry_manifest: %s != пину оракула' % imja)
        pary.append((z['id'], imja, pin))
    return pary


def postroit_v(kuda: Path):
    """Строит эталоны+manifest в kuda; возвращает manifest-данные."""
    src = json.loads((BATAREJA / 'source.json').read_text(encoding='utf-8'))
    k = konstanty(src)
    zapisi, etalony = [], []
    for id_zapisi, imja, pin in osnovy(src):
        blob = (BATAREJA / 'nositeli' / 'maket' / imja).read_bytes()
        proizvodnyj = postavit(blob, k)
        imja_393 = imja.replace('_390x844.png', '_393x852.png')
        (kuda / imja_393).write_bytes(proizvodnyj)
        etalony.append({'id': id_zapisi + ' 393', 'imja': imja_393,
                        'sha256': sha256_fajla(kuda / imja_393)})
        zapisi.append({'id': id_zapisi, 'osnova': 'nositeli/maket/' + imja,
                       'osnova_sha256': pin})
    import platform
    import zlib
    manifest = {
        '_comment': 'производные эталоны safe-area 393 (148 v6): D24-390 '
                    '+ системные полосы 393, контент неизменен; '
                    'построено postroit.py, руками не правится',
        'konstanty': k,
        'operacii': [
            'канва 393x852, заливка фоном основы (пиксель (0,0))',
            'контент основы строки %d..%d -> канва %d..%d (1:1)'
            % (k['polosa_390'], k['polosa_390'] + 709,
               k['vyrez'], k['vyrez'] + 709),
            'лейсте основы строки 795..843 -> канва %d..%d (1:1)'
            % (852 - k['domashnjaja_polosa'] - k['nav_height'],
               852 - k['domashnjaja_polosa'] - 1),
            'столбцы 390..392 — заливка фоном',
        ],
        'instrumenty': {'python': platform.python_version(),
                        'zlib': zlib.ZLIB_RUNTIME_VERSION},
        'mera': {'chrome_verh_pt': 48, 'chrome_niz_pt': 20},
        'porog': 0.6,
        'istochniki': zapisi,
        'etalony': etalony,
    }
    (kuda / 'manifest.json').write_text(
        json.dumps(manifest, ensure_ascii=False, indent=1) + '\n',
        encoding='utf-8')
    return manifest


def proverit():
    """Детерминированность: перестройка в одноразовый каталог даёт те же
    байты (sha256), что лежат рядом (manifest.json + PNG)."""
    zapisi = json.loads((HERE / 'manifest.json').read_text(encoding='utf-8'))
    vrem = Path(tempfile.mkdtemp(prefix='vkladki148-etalony-'))
    try:
        postroit_v(vrem)
        if sha256_fajla(vrem / 'manifest.json') != sha256_fajla(
                HERE / 'manifest.json'):
            return ['ETALON_DERIVACIJA_NE_VOSPROIZVODIMA: manifest.json '
                    '(версии инструментов?)']
        for e in zapisi['etalony']:
            if sha256_fajla(vrem / e['imja']) != sha256_fajla(HERE / e['imja']):
                return ['ETALON_DERIVACIJA_NE_VOSPROIZVODIMA: %s' % e['imja']]
        return []
    finally:
        shutil.rmtree(vrem, ignore_errors=True)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--proverit':
        otkazy = proverit()
        for o in otkazy:
            print(o, file=sys.stderr)
        return 1 if otkazy else 0
    if len(sys.argv) > 1:
        print('использование: postroit.py [--proverit]', file=sys.stderr)
        return 2
    try:
        postroit_v(HERE)
    except (ValueError, KeyError, OSError) as e:
        print('ETALON_ISTOCHNIK_NEVEREN: %s' % e, file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
