#!/usr/bin/env python3
# НЕЗАВИСИМЫЙ ОРАКУЛ содержания производных эталонов 393 (К-11, критик
# v6; вариант Б — слово владельца 22.11 ~14:35): судит ПО ПИКСЕЛЯМ
# основ 390, что производный эталон сохраняет СОДЕРЖАНИЕ (все непустые
# строки 1:1, в порядке; ровно 85 удалённых строк — все пустые; блоки
# не слиты; лейсте на месте; маска 48 / порог 0.600 неизменны).
"""Другой код, чем построитель postroit.py (К-11): свой PNG-кодек —
кодек движка батареи probe.py (у построителя — produkt_sud.py), своя
мера пустоты, своя геометрия, своя свёртка последовательностей;
построитель не импортируется и не перестраивается — судится ВЫХОД
как файл против свойств ОСНОВЫ. Основа и константы — оракульная
сторона (../source.json + ../nositeli/maket, пины проверяет
probe.load_source ДО клеток); koren — только проверяемые артефакты
(8 PNG + manifest.json [+ postroit.py]).

Свойства (вариант Б, по пикселям):
  (i)   последовательность непустых строк основы == последовательности
        непустых строк зоны полотна эталона (строка за строкой, байты
        первых 390 столбцов, порядок сохранён; утеря/чужая/дубликат/
        сдвиг порядка — именованные детали);
  (ii)  зона полотна ровно 710 строк при сохранении всех непустых —
        ровно 85 строк отсутствует и все они пустые (следствие
        геометрии 795−710 и (i));
  (iii) якоря (source.json.jakorja_soderzhanija): строки основы
        GA-03 19–35 (логотип/профиль) и 759–771 (заголовок
        «Dokumente») присутствуют; якорь обязан быть непустым в самой
        основе (иначе якорь недействителен);
  (iv)  разделители: между соседними непустыми блоками основы с
        пустым промежутком в эталоне остаётся >= 1 пустая строка
        (блоки не слиты);
  (v)   лейсте: строки 769..817 эталона == строки 795..843 основы 1:1;
  (vi)  системные полосы (0..58, 818..851) и столбцы 390..392 — фон;
  (vii) часовой значений: manifest.json mera.chrome_verh_pt == 48,
        mera.chrome_niz_pt == 20, porog == 0.600, konstanty == оракулу
        (порог/маска производных не ослаблены и не сдвинуты).

CLI: [--koren DIR] (по умолчанию — свой каталог, дерево батареи).
rc 0 — зелено; rc 1 — красные причины (PRICHINA-строки в stderr);
rc 2 — предпосылки (нет основы/эталона/манифеста, битый PNG).
stdout: 'ETALON\\t<id> 393\\tOK|KRASNO' на кадр + 'ZNACHENIJA\\tOK|KRASNO'.
"""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BATAREJA = HERE.parent

_spec = importlib.util.spec_from_file_location('probe148_orakul',
                                               BATAREJA / 'probe.py')
_pb = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_pb)
png_dekodirovat = _pb._png_dekodirovat


def _konstanty(src):
    """Геометрия оракула — своя свёртка source.json (не построителя)."""
    vp = src['ekran_forma_prod']['vtoroj_profil']
    tokeny = json.loads((BATAREJA / 'nositeli' / 'tokeny-1-1.json')
                        .read_text(encoding='utf-8'))
    nav = int(str(tokeny['nav']['height']['$value']).rstrip('px'))
    return {'vyrez': int(vp['vyrez']), 'home': int(vp['home']),
            'nav': nav, 'W': int(vp['shirina']), 'H': int(vp['vysota']),
            'polosa_390': int(src['kadry_manifest']['mera']['chrome_verh_pt'])}


def _rgba(rows, w, h, ch):
    if ch == 4:
        return [bytes(r) for r in rows]
    return [b''.join(bytes(r[x:x + 3]) + b'\xff' for x in range(0, w * 3, 3))
            for r in rows]


def proverka_razmera(razmer, k):
    """(vi-предпосылка): кадр обязан быть 393x852."""
    if razmer != (k['W'], k['H']):
        return ('ETALON_393_RAZMER: %dx%d != %dx%d'
                % (razmer[0], razmer[1], k['W'], k['H']))
    return None


def proverka_soderzhanija(osnova_rgba, w, h, etal_rgba, k, id_zapisi):
    """(i)+(ii): непустая последовательность основы присутствует в зоне
    полотна эталона строка-за-строкой, в порядке, без потерь/чужих/
    дублей. Возвращает список PRICHINA-строк."""
    fon = osnova_rgba[0][0:4]
    fon_w = fon * w
    leiste_verh = k['H'] - k['home'] - k['nav']
    polotno = h - k['nav']
    zona = leiste_verh - k['vyrez']
    b_stroki, b_ys = [], []
    for y in range(polotno):
        if osnova_rgba[y][:w * 4] != fon_w:
            b_stroki.append(osnova_rgba[y][:w * 4])
            b_ys.append(y)
    e_stroki, e_ys = [], []
    for y in range(k['vyrez'], k['vyrez'] + zona):
        if etal_rgba[y][:w * 4] != fon_w:
            e_stroki.append(etal_rgba[y][:w * 4])
            e_ys.append(y)
    problemy = []
    if len(e_stroki) != len(b_stroki):
        n = min(len(b_stroki), len(e_stroki))
        pervoe = None
        for j in range(n):
            if b_stroki[j] != e_stroki[j]:
                pervoe = j
                break
        problemy.append(
            'ETALON_393_SODERZHANIE_UTRACHENO: %s: непустых строк %d, '
            'в основе %d (зона полотна %d строк, основа %d; первое '
            'расхождение №%s: строка основы y=%s)'
            % (id_zapisi, len(e_stroki), len(b_stroki), zona, polotno,
               pervoe if pervoe is not None else 'за пределами',
               b_ys[pervoe] if pervoe is not None else '—'))
        return problemy
    for j in range(len(b_stroki)):
        if b_stroki[j] != e_stroki[j]:
            if (j + 1 < len(b_stroki) and e_stroki[j] == b_stroki[j + 1]
                    and e_stroki[j + 1] == b_stroki[j]):
                vid = ('порядок сдвинут (№%d: строки основы y=%d и y=%d '
                       'поменялись местами)' % (j, b_ys[j], b_ys[j + 1]))
            elif b_stroki[j] not in e_stroki:
                vid = 'утеряна строка основы №%d (y=%d)' % (j, b_ys[j])
            else:
                vid = ('чужая строка на месте №%d (строка основы y=%d '
                       'продублирована либо смещена)' % (j, b_ys[j]))
            problemy.append(
                'ETALON_393_SODERZHANIE_UTRACHENO: %s: %s' % (id_zapisi, vid))
            break
    return problemy


def proverka_jakorej(osnova_rgba, w, etal_rgba, k, id_zapisi, tema, jakorja):
    """(iii): непустые строки якорных диапазонов основы присутствуют в
    зоне полотна эталона (подпоследовательность, по порядку)."""
    fon = osnova_rgba[0][0:4]
    fon_w = fon * w
    leiste_verh = k['H'] - k['home'] - k['nav']
    zona = leiste_verh - k['vyrez']
    e_stroki = [etal_rgba[y][:w * 4] for y in range(k['vyrez'],
                                                    k['vyrez'] + zona)]
    problemy = []
    for jak in jakorja:
        if jak['kadr'] not in id_zapisi or tema not in jak['temy']:
            continue
        a, b = jak['diapazon']
        nuzhnye = [(y, osnova_rgba[y][:w * 4]) for y in range(a, b + 1)
                   if osnova_rgba[y][:w * 4] != fon_w]
        if not nuzhno_jakorju(nuzhnye, jak, id_zapisi, problemy):
            continue
        poz = 0
        for (y, stroka) in nuzhnye:
            najdeno = False
            while poz < len(e_stroki):
                poz += 1
                if e_stroki[poz - 1] == stroka:
                    najdeno = True
                    break
            if not najdeno:
                problemy.append(
                    'ETALON_393_JAKOR_UTRACHEN: %s: %s — строки основы '
                    'y=%d..%d не найдены в эталоне по порядку (первая '
                    'пропавшая y=%d)' % (id_zapisi, jak['imja'], a, b, y))
                break
    return problemy


def nuzhno_jakorju(nuzhnye, jak, id_zapisi, problemy):
    """Действительность якоря: в самом диапазоне основы есть непустые
    строки (иначе якорь недействителен — stale против основы)."""
    if not nuzhnye:
        problemy.append(
            'ETALON_393_JAKOR_NEDEJSTVITELEN: %s: %s — диапазон %d..%d '
            'пуст в самой основе (якорь устарел)'
            % (id_zapisi, jak['imja'], jak['diapazon'][0], jak['diapazon'][1]))
        return False
    return True


def proverka_razdelenija(osnova_rgba, w, h, etal_rgba, k, id_zapisi):
    """(iv): между соседними непустыми блоками основы с пустым
    промежутком в эталоне остаётся >= 1 пустая строка (не слиты)."""
    fon = osnova_rgba[0][0:4]
    fon_w = fon * w
    leiste_verh = k['H'] - k['home'] - k['nav']
    polotno = h - k['nav']
    zona = leiste_verh - k['vyrez']
    b_ys = [y for y in range(polotno) if osnova_rgba[y][:w * 4] != fon_w]
    e_ys = [y for y in range(k['vyrez'], k['vyrez'] + zona)
            if etal_rgba[y][:w * 4] != fon_w]
    if len(b_ys) != len(e_ys):
        return []   # состав уже красен proverka_soderzhanija
    for j in range(len(b_ys) - 1):
        if b_ys[j + 1] - b_ys[j] > 1 and e_ys[j + 1] - e_ys[j] == 1:
            return ['ETALON_393_BLOKI_SLITY: %s: блоки основы y=%d и y=%d '
                    '(пустых между ними %d) в эталоне слиплись (y=%d и y=%d)'
                    % (id_zapisi, b_ys[j], b_ys[j + 1],
                       b_ys[j + 1] - b_ys[j] - 1, e_ys[j], e_ys[j + 1])]
    return []


def proverka_leiste(osnova_rgba, w, h, etal_rgba, k, id_zapisi):
    """(v): лейсте основы 795..843 лежит в эталоне 769..817 байт-в-байт."""
    leiste_verh = k['H'] - k['home'] - k['nav']
    for i in range(k['nav']):
        b = osnova_rgba[h - k['nav'] + i][:w * 4]
        e = etal_rgba[leiste_verh + i][:w * 4]
        if b != e:
            return ['ETALON_393_LEISTE: %s: строка лейсте №%d (основа y=%d, '
                    'эталон y=%d) отличается — геометрия кадра сдвинута'
                    % (id_zapisi, i, h - k['nav'] + i, leiste_verh + i)]
    return []


def proverka_polsy_kraja(etal_rgba, fon, w, k, id_zapisi):
    """(vi): вырез/домашняя полоса — фон; столбцы 390..392 — фон."""
    fon_W = fon * k['W']
    problemy = []
    for y in list(range(k['vyrez'])) + list(range(k['H'] - k['home'],
                                                  k['H'])):
        if etal_rgba[y] != fon_W:
            problemy.append('ETALON_393_SISTEMNYE_POLSY: %s: строка y=%d '
                            'системной полосы несёт не-фон' % (id_zapisi, y))
            break
    for y in range(k['vyrez'], k['H'] - k['home']):
        if etal_rgba[y][w * 4:] != fon * (k['W'] - w):
            problemy.append('ETALON_393_KRAJ_NE_FON: %s: строка y=%d несёт '
                            'не-фон в столбцах %d..%d'
                            % (id_zapisi, y, w, k['W'] - 1))
            break
    return problemy


def proverka_znachenij(manifest, k):
    """(vii) часовой значений: маска 48 / низ 20 / порог 0.600 /
    константы построения — против оракула (source.json)."""
    problemy = []
    mera = manifest.get('mera', {})
    if mera.get('chrome_verh_pt') != 48:
        problemy.append('ETALON_393_MASKA_NE_48: manifest mera'
                        '.chrome_verh_pt=%r != 48 (слово владельца: маска '
                        '48 без изменений)' % mera.get('chrome_verh_pt'))
    if mera.get('chrome_niz_pt') != 20:
        problemy.append('ETALON_393_NIZ_NE_20: manifest mera.chrome_niz_pt='
                        '%r != 20' % mera.get('chrome_niz_pt'))
    if manifest.get('porog') != 0.6:
        problemy.append('ETALON_393_POROG_NE_0_600: manifest porog=%r != '
                        '0.600 (слово владельца: порог без изменений)'
                        % manifest.get('porog'))
    ozhidaemye = {'vyrez': k['vyrez'], 'domashnjaja_polosa': k['home'],
                  'nav_height': k['nav'], 'polosa_390': k['polosa_390']}
    faktn = manifest.get('konstanty', {})
    for kljuch, znach in sorted(ozhidaemye.items()):
        if faktn.get(kljuch) != znach:
            problemy.append('ETALON_393_MANIFEST_KONSTANTY: manifest '
                            'konstanty.%s=%r != %r (source.json)'
                            % (kljuch, faktn.get(kljuch), znach))
    return problemy


def _kadr_tema(id_zapisi):
    return 'dark' if id_zapisi.endswith('dark') else 'light'


def sudit(koren: Path):
    """Прогон всех проверок; возвращает (prichiny, stroki_stdout)."""
    src = json.loads((BATAREJA / 'source.json').read_text(encoding='utf-8'))
    k = _konstanty(src)
    jakorja = src.get('jakorja_soderzhanija', [])
    prichiny, stroki = [], []
    for z in src['kadry_manifest']['kadry']:
        id393 = z['id'] + ' 393'
        imja = Path(z['maket']).name
        imja393 = imja.replace('_390x844.png', '_393x852.png')
        put_osnovy = BATAREJA / 'nositeli' / 'maket' / imja
        put_393 = koren / imja393
        try:
            ow, oh, och, orows = png_dekodirovat(put_osnovy.read_bytes())
            ew, eh, ech, erows = png_dekodirovat(put_393.read_bytes())
        except OSError:
            print('ETALON_393_ISTOCHNIK: нет файла %s' % put_393,
                  file=sys.stderr)
            return None
        osnova = _rgba(orows, ow, oh, och)
        etal = _rgba(erows, ew, eh, ech)
        kadra = []
        r = proverka_razmera((ew, eh), k)
        if r:
            kadra.append(r)
        elif (ow, oh) != (390, 844):
            kadra.append('ETALON_393_ISTOCHNIK: основа %s %dx%d != 390x844'
                         % (imja, ow, oh))
        else:
            kadra += proverka_soderzhanija(osnova, ow, oh, etal, k, id393)
            kadra += proverka_jakorej(osnova, ow, etal, k, id393,
                                      _kadr_tema(z['id']), jakorja)
            kadra += proverka_razdelenija(osnova, ow, oh, etal, k, id393)
            kadra += proverka_leiste(osnova, ow, oh, etal, k, id393)
            kadra += proverka_polsy_kraja(etal, osnova[0][0:4], ow, k, id393)
        stroki.append('ETALON\t%s\t%s' % (id393, 'KRASNO' if kadra else 'OK'))
        prichiny += kadra
    try:
        manifest = json.loads((koren / 'manifest.json').read_text(
            encoding='utf-8'))
    except OSError:
        print('ETALON_393_ISTOCHNIK: нет manifest.json в %s' % koren,
              file=sys.stderr)
        return None
    z = proverka_znachenij(manifest, k)
    stroki.append('ZNACHENIJA\t%s' % ('KRASNO' if z else 'OK'))
    return prichiny + z, stroki


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('--koren', default=str(HERE))
    a, _ = ap.parse_known_args(sys.argv[1:])
    itog = sudit(Path(a.koren).resolve())
    if itog is None:
        return 2
    prichiny, stroki = itog
    for s in stroki:
        print(s)
    for p in prichiny:
        print('PRICHINA\t%s' % p, file=sys.stderr)
    return 1 if prichiny else 0


if __name__ == '__main__':
    sys.exit(main())
