#!/usr/bin/env python3
# Производные эталоны safe-area профиля 393 (слово владельца 22.11
# ~10:53 п.(6)«Д» + А-964; вариант Б — слово владельца 22.11 ~14:35):
# эталон экрана на 393 = кадр D24-390 с поэкранным удалением ровно
# udalit=85 измеренных пустых строк полотна + системные полосы 393
# (весь НЕпустой контент основы переносится 1:1, в том же порядке),
# маска chrome_verh_pt 48, порог 0.600.
"""Детерминированное построение производных эталонов 393 (вариант Б)
из кадров D24-390 пакета D24-Kompakt-1.1.

Геометрия — из ЕДИНОГО источника оракула батареи (../source.json):
  vyrez/home     — ekran_forma_prod.vtoroj_profil (59/34);
  shirina/vysota — рамка профиля 393x852;
  nav.height     — nositeli/tokeny-1-1.json ($value пакета 1.1);
  polosa_390     — kadry_manifest.mera.chrome_verh_pt (36 — маска
                   сверки 390; НЕ граница удаления содержимого: вывод
                   v6, закрытый вариантом Б).

Арифметика варианта Б: полотно основы — строки 0..(844-49-1), 795
строк; зона полотна в кадре 393 — 852-59-34-49 = 710 строк;
udalit = 795-710 = 85 — РОВНО 85 строк НА КАЖДЫЙ кадр, удаляются
ТОЛЬКО измеренные пустые строки полотна (все пиксели строки равны
фоновому пикселю (0,0) ОСНОВЫ); каждая НЕпустая строка основы
присутствует в эталоне 1:1 и в том же порядке.

Правило выбора 85 строк (вычислимо ТОЛЬКО из основы и констант, без
подгонки под выход; тот же текст — SPEC §3б и manifest.pravilo_udalenija):
  1) строка полотна пустая <=> все её пиксели равны фону (0,0) основы;
  2) пустые строки группируются в прогоны; прогоны упорядочиваются по
     убыванию длины (при равенстве — меньший y);
  3) прогоны обходятся в этом порядке, из каждого забираются строки
     СВЕРХУ ВНИЗ, пока бюджет udalit не исчерпан;
  4) внутренний прогон (соседние строки сверху и снизу непустые)
     оставляет >= 1 строку (взято не более L-1) — соседние
     содержательные блоки не сливаются; краевые прогоны (упираются
     в y=0 или в низ полотна) ограничения не несут.
«Ровно 85 и все пустые» наблюдаемо как: зона полотна кадра ровно 710
строк + все непустые строки основы в ней (судит независимый оракул
etalony_safe_area/orakul_soderzhanija.py — другой код, не построитель).

Операции над кадром-основой 390x844:
  1) канва 393x852, сплошная заливка фоном (пиксель (0,0) основы);
  2) полотно (795 строк минус 85 выбранных пустых) -> строки 59..768
     канвы (710 строк, порядок сохранён);
  3) лейсте основы строки 795..843 (nav.height 49) -> строки 769..817
     канвы 1:1 (над домашней полосой 34);
  4) столбцы 390..392 — заливка фоном (окно 393 шире артборда 390).
Строки канвы 0..58 (вырез 59) и 818..851 (домашняя полоса 34) —
системные полосы: в сверке закрыты масками chrome_verh_pt 48 /
chrome_niz_pt 20, порог сравнения НЕ меняется (0.600, поле porog
каждой записи).

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
    W, H = int(vp['shirina']), int(vp['vysota'])
    tokeny = json.loads((BATAREJA / 'nositeli' / 'tokeny-1-1.json')
                        .read_text(encoding='utf-8'))
    m = re.match(r'\A(\d+)px\Z', str(tokeny['nav']['height']['$value']))
    if m is None:
        raise ValueError('nav.height.$value не Npx')
    nav_h = int(m.group(1))

    polosa_390 = int(src['kadry_manifest']['mera']['chrome_verh_pt'])
    return {'vyrez': vyrez, 'domashnjaja_polosa': home,
            'nav_height': nav_h, 'polosa_390': polosa_390,
            'shirina': W, 'vysota': H}


def _rgba(rows, w, h, ch):
    """Строки основы в RGBA (ct 6); RGB-строки расширяются альфой."""
    if ch == 4:
        return [bytes(r) for r in rows]
    return [b''.join(bytes(r[x:x + 3]) + b'\xff' for x in range(0, w * 3, 3))
            for r in rows]


def pustota(rows_rgba, w, fon, dlina):
    """Пустая строка <=> все w пикселей равны фону основы (мера
    варианта Б: пиксели основы, не выход построителя)."""
    fon_stroka = fon * w
    return [rows_rgba[y][:w * 4] == fon_stroka for y in range(dlina)]


def pravilo_udalenija(pust, dlina, budget):
    """Выбор ровно budget пустых строк полотна (правило Б, см. шапку).
    Возвращает [(y0, n)] — диапазоны взятых строк; ValueError, если
    пустых строк с учётом ограничений не хватает."""
    progony, y0 = [], None
    for y in range(dlina + 1):
        if y < dlina and pust[y]:
            if y0 is None:
                y0 = y
        elif y0 is not None:
            progony.append((y0, y - y0))
            y0 = None
    porjadok = sorted(progony, key=lambda p: (-p[1], p[0]))
    vybrano, ostalos = [], budget
    for (s, l) in porjadok:
        if ostalos <= 0:
            break
        vnutrennij = s > 0 and s + l < dlina
        kap = l - 1 if vnutrennij else l
        vzjat = min(ostalos, kap)
        if vzjat > 0:
            vybrano.append((s, vzjat))
            ostalos -= vzjat
    if ostalos != 0:
        raise ValueError('пустых строк полотна меньше %d (не хватает %d)'
                         % (budget, ostalos))
    return vybrano


def postavit(osnova_blob, k):
    """Кадр-основа 390x844 -> производный эталон 393x852 (вариант Б:
    85 пустых строк полотна удалено, непустой контент 1:1 в порядке).
    Возвращает (png_bytes, [(y0, n)], chislo_pustyh_v_polotne)."""
    w, h, ch, rows = png_dekodirovat(osnova_blob)
    if (w, h) != (390, 844):
        raise ValueError('основа %dx%d != 390x844' % (w, h))
    rgba = _rgba(rows, w, h, ch)
    fon = rgba[0][0:4]
    W, H = k['shirina'], k['vysota']
    leiste_verh = H - k['domashnjaja_polosa'] - k['nav_height']   # 769
    polotno = h - k['nav_height']                                 # 795
    zona = leiste_verh - k['vyrez']                               # 710
    budget = polotno - zona                                       # 85
    if budget < 0:
        raise ValueError('геометрия не вмещает полотно (зона %d)' % zona)
    pust = pustota(rgba, w, fon, polotno)
    vybrano = pravilo_udalenija(pust, polotno, budget)
    udalenija = set()
    for (s, n) in vybrano:
        udalenija.update(range(s, s + n))
    polotno_stroki = [rgba[y] for y in range(polotno) if y not in udalenija]
    if len(polotno_stroki) != zona:
        raise ValueError('полотно %d != зоне %d' % (len(polotno_stroki), zona))
    kanva = [bytearray(fon * W) for _ in range(H)]
    for i, stroka in enumerate(polotno_stroki):
        kanva[k['vyrez'] + i][:w * 4] = stroka
    for i in range(k['nav_height']):
        kanva[leiste_verh + i][:w * 4] = rgba[h - k['nav_height'] + i]
    return (png_kodirovat(W, H, 4, [bytes(r) for r in kanva]),
            vybrano, sum(pust))


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


def _diapazony(vybrano):
    """[(y0, n)] -> [[y0, y1], …] (включительно) для манифеста."""
    return [[s, s + n - 1] for (s, n) in vybrano]


def postroit_v(kuda: Path):
    """Строит эталоны+manifest в kuda; возвращает manifest-данные."""
    src = json.loads((BATAREJA / 'source.json').read_text(encoding='utf-8'))
    k = konstanty(src)
    zapisi, etalony = [], []
    W, H = k['shirina'], k['vysota']
    leiste_verh = H - k['domashnjaja_polosa'] - k['nav_height']
    polotno = 844 - k['nav_height']
    zona = leiste_verh - k['vyrez']
    budget = polotno - zona
    for id_zapisi, imja, pin in osnovy(src):
        blob = (BATAREJA / 'nositeli' / 'maket' / imja).read_bytes()
        proizvodnyj, vybrano, pustyh = postavit(blob, k)
        imja_393 = imja.replace('_390x844.png', '_393x852.png')
        (kuda / imja_393).write_bytes(proizvodnyj)
        etalony.append({
            'id': id_zapisi + ' 393', 'imja': imja_393,
            'sha256': sha256_fajla(kuda / imja_393),
            'udalennye_diapazony': _diapazony(vybrano),
            'udaleno_strok': sum(n for (_, n) in vybrano),
            'pustyh_v_polotne': pustyh,
            'ne_pustyh_v_polotne': polotno - pustyh})
        zapisi.append({'id': id_zapisi, 'osnova': 'nositeli/maket/' + imja,
                       'osnova_sha256': pin})
    import platform
    import zlib
    manifest = {
        '_comment': 'производные эталоны safe-area 393 (148 v6, вариант Б '
                    '— слово владельца 22.11 ~14:35): D24-390 с поэкранным '
                    'удалением 85 измеренных пустых строк полотна + системные '
                    'полосы 393, непустой контент 1:1; построено postroit.py, '
                    'руками не правится',
        'konstanty': k,
        'pravilo_udalenija': {
            'mera': 'строка полотна пустая <=> все её пиксели равны '
                    'фоновому пикселю (0,0) основы (поэкранная мера)',
            'porjadok': 'пустые прогоны полотна по убыванию длины (равенство '
                        '— меньший y), из прогона сверху вниз, бюджет '
                        '%d на кадр' % budget,
            'ogranichenie': 'внутренний прогон (обе соседние строки непустые) '
                            'оставляет >= 1 строку; краевые прогоны (y=0 / низ '
                            'полотна) — без ограничения',
            'bjudzet': budget,
            'arifmetika': 'полотно %d (844 − nav %d) − зона %d (%d − vyrez %d '
                          '− home %d − nav %d)'
                          % (polotno, k['nav_height'], zona, H, k['vyrez'],
                             k['domashnjaja_polosa'], k['nav_height']),
        },
        'operacii': [
            'канва %dx%d, заливка фоном основы (пиксель (0,0))' % (W, H),
            'полотно основы строки 0..%d минус %d пустых (правило '
            'pravilo_udalenija) -> канва %d..%d (1:1, порядок сохранён)'
            % (polotno - 1, budget, k['vyrez'], k['vyrez'] + zona - 1),
            'лейсте основы строки %d..%d -> канва %d..%d (1:1)'
            % (844 - k['nav_height'], 843, leiste_verh,
               H - k['domashnjaja_polosa'] - 1),
            'столбцы 390..392 — заливка фоном',
            'строки 0..%d (вырез) и %d..%d (домашняя полоса) — фон, '
            'закрыты масками сверки' % (k['vyrez'] - 1,
                                        H - k['domashnjaja_polosa'], H - 1),
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
