#!/usr/bin/env python3
# Судья ФОРМЫ батареи 148 (правка по вердикту Crit148v2, блок 3): гейт
# ТОЧНОГО ЗНАЧЕНИЯ маски профиля 393 + делегация валидатору (--sud —
# байт-копия эталона v3 model/ekran_shablon.py или живой скрипт).
"""sud_formy_148.py --sud <валидатор> --pack P --repo R --harness H

Порядок честен к существующей клетке profil-maska-36 (не ослаблять):
сперва ВИЗУАЛЬНЫЙ суд делегата (36 красен KADR_NIZHE_POROGA — живой
прообраз Q1б), затем — только на визуально зелёном — инвариант
ЗНАЧЕНИЯ: mera.chrome_verh_pt манифеста второго профиля обязан быть
48 (слово владельца 31.10, вырез камеры 393). 47/49/60 проходят
сверку визуально — значение лжёт, отказ PROFIL_MASKA_NE_48 rc 1
независимо от счёта кадров. Пин байт-копии (5fd1415e…) сверяется
probe.load_source ДО клеток — здесь не дублируется (второй источник
запрещён); тот же литерал 48 несёт produkt_sud.PROFIL_MASKA_PT."""
import argparse
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
# слово владельца 31.10 (тот же литерал — produkt_sud.PROFIL_MASKA_PT)
PROFIL_MASKA_PT = 48


def proverka_maski_profilja(pack: Path):
    """Инвариант значения маски второго профиля: manifest.mera.
    chrome_verh_pt == 48; манифест — по записи vtoroj_profil.kadry
    пачки (kadry_profil.json). Нечитаемые форма/манифест здесь не
    судятся — их раньше называет делегат."""
    imja = 'kadry_profil.json'
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        imja = forma['vtoroj_profil']['kadry']
        mera = json.loads((pack / imja).read_text(encoding='utf-8'))['mera']
    except (OSError, ValueError, KeyError):
        return None
    znach = mera.get('chrome_verh_pt')
    if znach != PROFIL_MASKA_PT:
        return ('PROFIL_MASKA_NE_48: %s: mera.chrome_verh_pt=%s, а маска '
                'системной шапки профиля 393 — %d pt (слово владельца '
                '31.10, Q1б; значение — независимо от визуальной меры)'
                % (imja, znach, PROFIL_MASKA_PT))
    return None

def proverka_paketa(pack: Path):
    """v+1 (слово владельца 2026-11-02): пин пачки — пакет
    D24-Kompakt-1.1: кадры ОСНОВНОГО манифеста (kadry.json, 390) лежат в
    docs/ux/05_Kompakt_D24/frames/ с maket_sha256 == записи
    frames/SHA256SUMS. v6 (слово владельца 22.11): записи ВТОРОГО
    профиля (393) — производные эталоны safe-area
    (proverka_etalonov_393), здесь для них допустимы пути пакета И
    производных; старый пин D 2.4 Final 2 (файлы честны) по-прежнему
    красит этот гейт (клетка paket-final2, стаб s90)."""
    sums = {}
    for line in (HERE.parent / 'nositeli/paket/SHA256SUMS').read_text(
            encoding='utf-8').splitlines():
        sha, imja = line.split(maxsplit=1)
        sums[imja.strip().lstrip('*')] = sha
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        profil = forma.get('vtoroj_profil', {}).get('kadry', 'kadry_profil.json')
    except (OSError, ValueError):
        return None
    for imja in ('kadry.json', profil):
        try:
            kadry = json.loads((pack / imja).read_text(encoding='utf-8'))['kadry']
        except (OSError, ValueError, KeyError):
            return None
        for k in kadry:
            put = k.get('maket', '')
            imja_fajla = put.rsplit('/', 1)[-1]
            v_pakete = (put.startswith('docs/ux/05_Kompakt_D24/frames/')
                        and sums.get(imja_fajla) == k.get('maket_sha256'))
            # sha производных судит ТОЛЬКО proverka_etalonov_393
            proizvodnyj = put.startswith(PUT_ETALONOV_393)
            if imja != 'kadry.json' and proizvodnyj:
                continue
            if not v_pakete:
                return ('PAKET_1_1_NE_PRIPINEN: %s: %s: пин вне пакета '
                        'D24-Kompakt-1.1 (frames/SHA256SUMS)' % (imja, k.get('id')))
    return None


def manifest_etalonov():
    """Манифест производных эталонов 393 — единый источник пинов
    (etalony_safe_area/manifest.json; байты запинены source.json)."""
    return json.loads((HERE.parent / 'etalony_safe_area' / 'manifest.json')
                      .read_text(encoding='utf-8'))


PUT_ETALONOV_393 = 'mobile/etalony-vkladki-393/'


def proverka_etalonov_393(pack: Path):
    """v6 (слово владельца 22.11): эталон экрана на 393 — ПРОИЗВОДНЫЙ
    (D24-390 + системные полосы 393, контент неизменен, маска 48):
    каждая запись манифеста профиля пинит mobile/etalony-vkladki-393/
    с sha из манифеста производных; пин кадра пакета 393 — отказ."""
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        imja = forma.get('vtoroj_profil', {}).get('kadry', 'kadry_profil.json')
        kadry = json.loads((pack / imja).read_text(encoding='utf-8'))['kadry']
    except (OSError, ValueError, KeyError):
        return None
    piny = {e['imja']: e['sha256'] for e in manifest_etalonov()['etalony']}
    for k in kadry:
        put = k.get('maket', '')
        imja_fajla = put.rsplit('/', 1)[-1]
        if (not put.startswith(PUT_ETALONOV_393)
                or piny.get(imja_fajla) != k.get('maket_sha256')):
            return ('ETALON_393_NE_PROIZVODNYJ: %s: %s: пин %s вне '
                    'манифеста производных (mobile/etalony-vkladki-393/, '
                    'слово владельца 22.11)' % (imja, k.get('id'), put))
    return None


def proverka_poroga(pack: Path):
    """v6 (слово владельца 22.11): порог сверки НЕ ослабляется — porog
    каждой записи обоих манифестов 0.600 (клетка porog-oslablen,
    стаб s101)."""
    try:
        forma = json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        imena = ['kadry.json',
                 forma.get('vtoroj_profil', {}).get('kadry', 'kadry_profil.json')]
    except (OSError, ValueError):
        return None
    for imja in imena:
        try:
            kadry = json.loads((pack / imja).read_text(encoding='utf-8'))['kadry']
        except (OSError, ValueError, KeyError):
            return None
        for k in kadry:
            try:
                if float(k.get('porog')) != 0.6:
                    return ('POROG_NE_0_600: %s: %s: porog=%s, порог сверки '
                            'ослаблен (без ослабления порога — слово '
                            'владельца 22.11)' % (imja, k.get('id'), k.get('porog')))
            except (TypeError, ValueError):
                return ('POROG_NE_0_600: %s: %s: porog=%r не число'
                        % (imja, k.get('id'), k.get('porog')))
    return None

def proverka_imen_kadrov(pack: Path):
    """v3a (Crit148k2a, Б1): имя записи кадра обязано соответствовать её
    идентификатору — пин «GA-02 dark» на файл GA-04 (валидный кадр ТОГО
    ЖЕ пакета, честный sha из SHA256SUMS) — подмена, не членство.
    Ожидание — пин оракула батареи (kadry_manifest/profil_kadry ==
    пакету 1.1, тот же источник у продукт-судьи produkt_sud)."""
    import json as _json
    src = _json.loads((HERE.parent / 'source.json').read_text(encoding='utf-8'))
    try:
        forma = _json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))
        pary = [('kadry.json', src['kadry_manifest']),
                (forma.get('vtoroj_profil', {}).get('kadry', 'kadry_profil.json'),
                 src['profil_kadry'])]
    except (OSError, ValueError):
        return None
    for imja, orakul in pary:
        try:
            kadry = _json.loads((pack / imja).read_text(encoding='utf-8'))['kadry']
        except (OSError, ValueError, KeyError):
            return None
        ozhidaemye = {k['id']: k['maket'] for k in orakul['kadry']}
        for k in kadry:
            ozhidaemoe = ozhidaemye.get(k.get('id'))
            if ozhidaemoe is None:
                return ('KADR_PODMENEN: %s: %s: записи нет в пине пакета '
                        'D24-Kompakt-1.1 (GA-02/03/04/09 × normal × '
                        'dark/light × 390×844/393×852)' % (imja, k.get('id')))
            if k.get('maket') != ozhidaemoe:
                return ('KADR_PODMENEN: %s: %s: пин %s — имя записи не '
                        'соответствует её идентификатору (пакет 1.1 пинит '
                        '%s)' % (imja, k.get('id'),
                                 Path(k.get('maket', '')).name,
                                 Path(ozhidaemoe).name))
    return None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--sud', required=True)
    ap.add_argument('--pack', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--harness', required=True)
    a = ap.parse_args()
    p = subprocess.run(
        [sys.executable, a.sud, '--pack', a.pack, '--repo', a.repo,
         '--harness', a.harness], capture_output=True, text=True)
    sys.stdout.write(p.stdout)
    sys.stderr.write(p.stderr)
    if p.returncode == 0:
        prichina = proverka_maski_profilja(Path(a.pack))
        if prichina:
            print('PRICHINA\t%s' % prichina, file=sys.stderr)
            return 1
        prichina = proverka_paketa(Path(a.pack))
        if prichina:
            print('PRICHINA\t%s' % prichina, file=sys.stderr)
            return 1
        prichina = proverka_poroga(Path(a.pack))
        if prichina:
            print('PRICHINA\t%s' % prichina, file=sys.stderr)
            return 1
        prichina = proverka_etalonov_393(Path(a.pack))
        if prichina:
            print('PRICHINA\t%s' % prichina, file=sys.stderr)
            return 1
        prichina = proverka_imen_kadrov(Path(a.pack))
        if prichina:
            print('PRICHINA\t%s' % prichina, file=sys.stderr)
            return 1
    return p.returncode


if __name__ == '__main__':
    sys.exit(main())
