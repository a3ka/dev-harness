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
    return p.returncode


if __name__ == '__main__':
    sys.exit(main())
