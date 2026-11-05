#!/usr/bin/env python3
"""Самоописание батареи ekrannyj_nabor_158 (контракт 158, И-5).

Выводит JSON-счётчики батареи ОДНОЙ строкой:
  {"kletok": N, "stabov": N, "svjazej": N, "nositelej": N, "piny": N,
   "roditel": "<sha256>"}

Меры (две, независимые):
  1) эта — по файлам батареи: клетки — реестр runner'а, стабы и их привязки —
     каталог stubs/ и source.json.stab_vhod, носители и пины — каталоги
     nositeli/, model/, zond/ и source.json.piny;
  2) вторая — python-счёт по source.json (её считает клетка e01).

Счётчики и хэши — ВЫВОДОМ скрипта; в тексте контракта 158 чисел батареи
нет (И-5).
"""
import hashlib
import json
import os
import re

ZDE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def sha_fajla(put):
    h = hashlib.sha256()
    with open(put, 'rb') as fh:
        for kus in iter(lambda: fh.read(65536), b''):
            h.update(kus)
    return h.hexdigest()


def schit_kletok():
    """Клетки — реестр runner'а (probe.py: KLETKI)."""
    with open(os.path.join(ZDE, 'probe.py'), encoding='utf-8') as fh:
        tekst = fh.read()
    blok = re.search(r'^KLETKI = \[(.*?)^\]', tekst, re.S | re.M)
    if blok is None:
        return 0
    return len(re.findall(r"'[A-Za-z0-9]+-[A-Za-z0-9-]+'", blok.group(1)))


def schit_nositelej():
    """Носители батареи — файлы каталогов nositeli/, zond/, model/."""
    schet = 0
    for katalog in ('nositeli', 'zond', 'model'):
        koren = os.path.join(ZDE, katalog)
        for dirpath, dirnames, imena in os.walk(koren):
            dirnames[:] = [d for d in dirnames if d != '__pycache__']
            for imya_f in imena:
                if imya_f.endswith('.pyc'):
                    continue
                schet += 1
    return schet


def main():
    with open(os.path.join(ZDE, 'source.json'), encoding='utf-8') as fh:
        orakul = json.load(fh)
    staby = sorted(f for f in os.listdir(os.path.join(ZDE, 'stubs'))
                   if f.endswith('.py'))
    piny = orakul.get('piny', {})
    vse_piny = {}
    for gruppa in ('nositeli', 'etalony', 'zond'):
        for otn, sha in sorted(piny.get(gruppa, {}).items()):
            vse_piny['%s/%s' % (gruppa, otn)] = sha
    itog = {
        'kletok': schit_kletok(),
        'stabov': len(staby),
        'svjazej': sum(len(v) for v in orakul.get('stab_vhod', {}).values()),
        'nositelej': schit_nositelej(),
        'piny': len(vse_piny),
        'roditel': sha_fajla(os.path.join(ZDE, 'probe.py')),
    }
    print(json.dumps(itog, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
