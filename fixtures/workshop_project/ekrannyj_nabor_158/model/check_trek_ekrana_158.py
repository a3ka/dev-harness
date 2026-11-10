#!/usr/bin/env python3
"""Эталон гейта ТРЕК набора ekrannyj_nabor_158 (контракт 158, И-6).

ЕДИНЫЙ источник грамматики ТРЕК: этот файл. Скрипт
scripts/check_trek_ekrana.sh — носитель той же грамматики (не второй
источник): он вызывает этот эталон, поэтому расхождение «эталон ↔ скрипт»
невозможно по построению.

CLI: check_trek_ekrana_158.py <корень> [<контракт>]
  <корень>    — корень дерева, где лежит каталог contracts/;
  [<контракт>] — контракт: путь ОТ <корня> (например
                 contracts/190-ekran-obychnyj.md) либо абсолютный путь.
                 Без контракта — судятся ВСЕ контракты contracts/.

Грамматика (SPEC.md §6A):
  * маркер экранности — литерал `ekrannyj_nabor_158` В РАЗДЕЛЕ ПРИЁМКИ
    контракта: раздел = от строки `^## Приёмочн` до следующей строки
    `^#{1,2} `; маркер вне раздела (КОНТЕКСТ/«Существующее»/зоны) членства
    НЕ создаёт;
  * строка `ТРЕК: ЛЁГКИЙ|ПОЛНЫЙ` — 0..1; отсутствие = ЛЁГКИЙ; две и
    больше → TREK_DUBL; иное значение → TREK_NE_PO_GRAMMATIKE;
  * строка `ТРЕК-ПЕРЕКЛЮЧЕНИЕ: ГГГГ-ММ-ДД (architect|implementer|
    orchestrator|owner) (ЛЁГКИЙ|ПОЛНЫЙ)→(ЛЁГКИЙ|ПОЛНЫЙ) — <причина>` —
    0..1; >1, битый формат (дата/автор/причина) или стрелка без смены
    текущего значения → TREK_NE_PO_GRAMMATIKE;
  * КЛАСС РИСКА: объявление класса риска — маркер в начале строки либо сразу
    за границей фразы (`.`/`!`/`?`/`;`; между границей и маркером допустимы
    пробелы и закрывающие скобки): компактная шапка
    «КЛАСС ЗАДАЧИ: … . КЛАСС РИСКА: рисковый (деньги)» объявляет тот же
    класс риска, что отдельная строка; упоминание маркера в прозе
    («экран класса риска (КЛАСС РИСКА: рисковый)») объявлением НЕ является;
    значение класса — от маркера до разделителя значения («—», «;», «.», …):
    класс рисковый, если значение содержит «рисковый»; риска ∧ трек ≠ ПОЛНЫЙ
    ∧ нет строки `^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` с basename контракта и подстрокой
    «трек» → EKRAN_RISKA_LEGKIJ;
  * контракт без маркера в приёмке → rc 0 МОЛЧА (не экран набора).

Коды возврата: 0 — экран набора с треком (или не экран); 1 — именованный
отказ; 2 — нечем проверить (файла нет).
"""
import os
import re
import sys

TREK_LEGKIJ = 'ЛЁГКИЙ'
TREK_POLNYJ = 'ПОЛНЫЙ'
ZNAHENIYA = (TREK_LEGKIJ, TREK_POLNYJ)

MARKER = 'ekrannyj_nabor_158'
RAZDEL_PRYEMKI = re.compile(r'^##\s*Приёмочн')
KONEC_RAZDELA = re.compile(r'^#{1,2}\s')
STROKA_TREKA = re.compile(r'^ТРЕК:\s*(.*)$')
STROKA_PEREKL = re.compile(
    r'^ТРЕК-ПЕРЕКЛЮЧЕНИЕ:\s*(\d{4})-(\d{2})-(\d{2})\s+'
    r'\((architect|implementer|orchestrator|owner)\)\s+'
    r'(ЛЁГКИЙ|ПОЛНЫЙ)→(ЛЁГКИЙ|ПОЛНЫЙ)\s+—\s+(.+)$')
STROKA_RAZRESHENIYA = re.compile(r'^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:')

AVTORY = ('architect', 'implementer', 'orchestrator', 'owner')

# Объявление класса риска: маркер, границы фразы, разделитель значения.
MARKER_RISKA = 'КЛАСС РИСКА:'
GRANICY_FRAZY = '.!?;'
ZAKRYVAYUSHIE = ')]}»'
KONEC_ZNACHENIYA = '—;.!?'
DEKORACIYA = re.compile(r'^(?:[-*+>]\s+|#+\s*|\d+[.)]\s+)+')


def _blok_priemki(stroki):
    """Текст раздела приёмки (пустая строка — раздела нет)."""
    nachalo = None
    for i, s in enumerate(stroki):
        if RAZDEL_PRYEMKI.match(s):
            nachalo = i + 1
            break
    if nachalo is None:
        return ''
    konets = len(stroki)
    for j in range(nachalo, len(stroki)):
        if KONEC_RAZDELA.match(stroki[j]):
            konets = j
            break
    return '\n'.join(stroki[nachalo:konets])


def _granica_frazy(s, i):
    """True, если позиция i начинает объявление (начало строки/граница фразы)."""
    j = i - 1
    while j >= 0 and s[j].isspace():
        j -= 1
    if j < 0:
        return True
    while j >= 0 and s[j] in ZAKRYVAYUSHIE:
        j -= 1
    return j >= 0 and s[j] in GRANICY_FRAZY


def _klass_riska(stroka):
    """Значение объявления класса риска в строке; None — объявления нет.

    Объявление — маркер `КЛАСС РИСКА:` в начале строки либо сразу за границей
    фразы (`.`/`!`/`?`/`;` + пробел): компактная шапка «КЛАСС ЗАДАЧИ: … .
    КЛАСС РИСКА: рисковый (деньги)» объявляет тот же класс риска, что и
    отдельная строка. Упоминание маркера в прозе («экран класса риска
    (КЛАСС РИСКА: рисковый)», «строка `КЛАСС РИСКА:`») объявлением НЕ является.
    Значение класса — от маркера до разделителя значения («—», «;», «.», «!»,
    «?»): основание риска в значении класса не значит («КЛАСС РИСКА: обычный
    — … рисковый там» — класс обычный).
    """
    s = DEKORACIYA.sub('', stroka.strip())
    nachalo = 0
    while True:
        i = s.find(MARKER_RISKA, nachalo)
        if i < 0:
            return None
        if _granica_frazy(s, i):
            znachenie = s[i + len(MARKER_RISKA):]
            for j, ch in enumerate(znachenie):
                if ch in KONEC_ZNACHENIYA:
                    znachenie = znachenie[:j]
                    break
            return znachenie
        nachalo = i + 1


def _blok_teksta(stroki):
    """Разбор контракта: маркер, трек, переключение, риск, разрешение."""
    vozvrashchay = {
        'marker': False,
        'trek': None,
        'stroyki_treka': [],
        'pereklyucheniya': [],
        'risk': False,
        'razresheniya': [],
    }
    vozvrashchay['marker'] = MARKER in _blok_priemki(stroki)
    for s in stroki:
        m = STROKA_TREKA.match(s.strip())
        if m:
            vozvrashchay['stroyki_treka'].append(m.group(1).strip())
        m = STROKA_PEREKL.match(s.strip())
        if m:
            vozvrashchay['pereklyucheniya'].append(m)
        elif s.strip().startswith('ТРЕК-ПЕРЕКЛЮЧЕНИЕ:'):
            # строка переключения есть, но формат битый — разбираем позже
            vozvrashchay['pereklyucheniya'].append(None)
        znachenie_riska = _klass_riska(s)
        if znachenie_riska is not None:
            if 'рисковый' in znachenie_riska.lower():
                vozvrashchay['risk'] = True
        if STROKA_RAZRESHENIYA.match(s.strip()):
            vozvrashchay['razresheniya'].append(s)
    if len(vozvrashchay['stroyki_treka']) == 1:
        znachenie = vozvrashchay['stroyki_treka'][0]
        vozvrashchay['trek'] = znachenie if znachenie in ZNAHENIYA else None
    return vozvrashchay


def _realnaya_data(g, m, d):
    try:
        god, mesyats, den = int(g), int(m), int(d)
    except ValueError:
        return False
    if not 1 <= mesyats <= 12:
        return False
    dni = [31, 29 if (god % 4 == 0 and (god % 100 != 0 or god % 400 == 0))
           else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return 1 <= den <= dni[mesyats - 1]


def sudi_tekst(stroki, imya_kontrakta=''):
    """Вердикт по тексту контракта.

    Возвращает (rc, prichina|None, trek|None, chlen|bool):
      rc 0 — экран набора (трек разобран) либо не экран (молча);
      rc 1 — именованный отказ; rc 2 — нечем проверить.
    """
    razbor = _blok_teksta(stroki)
    if not razbor['marker']:
        # не экран набора: риск-правило не применяется, трек не судится
        return 0, None, None, False
    stroyki = razbor['stroyki_treka']
    if len(stroyki) > 1:
        return 1, 'TREK_DUBL', None, True
    trek = razbor['trek']
    if len(stroyki) == 1 and trek is None:
        return 1, 'TREK_NE_PO_GRAMMATIKE', None, True
    if trek is None:
        trek = TREK_LEGKIJ
    pereklyucheniya = razbor['pereklyucheniya']
    if len(pereklyucheniya) > 1:
        return 1, 'TREK_NE_PO_GRAMMATIKE', None, True
    if pereklyucheniya:
        m = pereklyucheniya[0]
        if m is None:
            return 1, 'TREK_NE_PO_GRAMMATIKE', None, True
        god, mesyats, den, avtor, iz, v, _prichina = m.groups()
        if avtor not in AVTORY or not _realnaya_data(god, mesyats, den):
            return 1, 'TREK_NE_PO_GRAMMATIKE', None, True
        if iz not in ZNAHENIYA or v not in ZNAHENIYA or not m.group(7).strip():
            return 1, 'TREK_NE_PO_GRAMMATIKE', None, True
        if v == trek:
            # стрелка не меняет текущего значения
            return 1, 'TREK_NE_PO_GRAMMATIKE', None, True
    if razbor['risk'] and trek != TREK_POLNYJ:
        bazis = os.path.basename(imya_kontrakta) if imya_kontrakta else ''
        razresheno = False
        for s in razbor['razresheniya']:
            niz = s.lower()
            if bazis and bazis in s and 'трек' in niz:
                razresheno = True
        if not razresheno:
            return 1, 'EKRAN_RISKA_LEGKIJ', None, True
    return 0, None, trek, True


def sudi_kontrakt(path):
    """Вердикт по файлу контракта: (rc, prichina|None, trek|None, chlen)."""
    try:
        with open(path, encoding='utf-8') as fh:
            stroki = fh.read().splitlines()
    except OSError:
        return 2, 'NOT_IMPLEMENTED', None, False
    return sudi_tekst(stroki, os.path.basename(path))


def _vyvesti(chlen, trek):
    if chlen:
        if trek == TREK_POLNYJ:
            print('ТРЕК ПОЛНЫЙ')
        else:
            print('ТРЕК ЛЁГКИЙ (по умолчанию)')
    # не экран набора — молча (rc 0)


def main(argv):
    if len(argv) < 1:
        sys.stderr.write('NOT_IMPLEMENTED: нужен <корень> [<контракт>]\n')
        return 2
    koren = argv[0]
    if len(argv) == 1:
        katalog = os.path.join(koren, 'contracts')
        if not os.path.isdir(katalog):
            sys.stderr.write('NOT_IMPLEMENTED: нет каталога contracts: %s\n'
                             % katalog)
            return 2
        khudshey = 0
        for imya in sorted(os.listdir(katalog)):
            if not imya.endswith('.md'):
                continue
            rc, prichina, trek, chlen = sudi_kontrakt(
                os.path.join(katalog, imya))
            if rc == 1:
                sys.stderr.write('ОТКАЗ: %s: %s\n' % (imya, prichina))
                khudshey = 1
            elif rc == 2:
                sys.stderr.write('NOT_IMPLEMENTED: %s\n' % imya)
                khudshey = 2
            else:
                _vyvesti(chlen, trek)
        return khudshey
    put = argv[1]
    if not os.path.isabs(put):
        put = os.path.join(koren, put)
    rc, prichina, trek, chlen = sudi_kontrakt(put)
    if rc == 1:
        sys.stderr.write('ОТКАЗ: %s\n' % prichina)
        return 1
    if rc == 2:
        sys.stderr.write('NOT_IMPLEMENTED: контракт не читается: %s\n' % put)
        return 2
    _vyvesti(chlen, trek)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
