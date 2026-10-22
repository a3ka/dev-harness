#!/usr/bin/env python3
# ЭТАЛОН 132: эталон поведения батареи fixtures/workshop_project/ekran_shablon_132/
# probe.py; та же грамматика вывода, что у субъекта scripts/ekran_shablon.py.
"""Шаблон контракта экрана mob (132): машиночитаемая форма ekran.json + проверки.

Форма (все ключи обязательны, замкнутый состав — 17 полей):
  ekran          id экрана, [a-z0-9][a-z0-9-]{0,63} — ОДИН экран на контракт
  kadry          путь в пачке: манифест кадров грамматики 123 (kadry_117.json)
  sostojanija    непустой список [a-z0-9-]+, без повторов
  kljuchi_kopii  непустой список [A-Za-z0-9_.-]+; каждый есть в каталоге копии
  operacii_api   список [A-Za-z0-9_.-]+ (может быть пуст); каждый operationId
                 есть в API-спецификации
  katalog_kopii  путь в репо продукта: каталог копии (JSON)
  spec_api       путь в репо продукта: API-спецификация (JSON, operationId)
  audit_tokenov  путь в репо продукта: общий аудит токенов D2.2.5.1 —
                 ЕДИНСТВЕННОЕ место, где допустимы литералы цветов/размеров
  e2e_scenarij   путь в репо продукта: сценарий android-e2e; содержит каждый
                 snimok манифеста кадров
  kadry_dir      путь в репо продукта: каталог кадров Maestro-раскладки
  kontrakt       путь в пачке: контракт экрана «на одну страницу» (воля
                 владельца) — ТРИ меры объёма: ≤ 60 строк, ≤ 120 символов
                 в строке, ≤ 4000 байт файла (NE_ODNA_STRANICA); несёт
                 обязательные разделы
                 (Воля владельца, Существующее, Инварианты, Приёмочный
                 критерий, Зоны и исполнители, ПРОВОДКА, Модель угроз) и
                 ЗОНА-строки, равные zony формы
  batareja       непустой список путей в пачке: файлы батареи экрана
  priemka        {"e2e": командная строка android-e2e, "sverka": командная
                 строка сверки}. ОБЕ ИСПОЛНЯЮТСЯ фактическим argv (cwd = репо
                 продукта, БЕЗ shell; алфавит поля без кавычек/;|&$() —
                 пробел единственный разделитель, прецедент Г3-002):
                 e2e — rc 0, и кадры СВЕЖИ: каждый файл под kadry_dir
                 создан ЭТИМ запуском (mtime не старше старта команды И
                 байты отличаются от дозапускового состояния) — иначе
                 KADR_USTAREVSHIJ; команда без кадров даёт
                 KADR_OTSUTSTVUET, не зелень;
                 sverka — rc 0 И stdout дословно равен выводу раннера 123 по
                 манифесту пачки (сверка-образец); строка обязана нести
                 токены sverka_maketa.py и --manifest
  zony           {"architect": [...], "implementer": [...]} — грамматика
                 check_zones: относительные пути без *?[ , без .., без
                 ведущего /; каталог с завершающей /
  zamenjaet      null | путь в харнессе ИЛИ репо продукта: манифест кадров
                 ЗАМЕНЯЕМОГО контракта того же экрана; кадры нового —
                 надмножество (замена целиком)
  ne_trogaet     список путей в харнессе ИЛИ репо продукта: живые манифесты
                 ЧУЖИХ экранов; пересечение id кадров пусто (чужих пикселей
                 не морозит)
  fiktura        bool; СУДИМАЯ пачка обязана быть false (фикция не судится);
                 false у живой пачки делает её видимой обнаружению (ниже)

Живые пачки (грамматика ОБНАРУЖЕНИЯ, отдельно от полной формы): файл
ekran.json под fixtures/workshop_project/** В ОБОИХ корнях — харнесса И
переданного репо продукта (--repo; обход круга 2: живая пачка в продукте
невидима харнесс-скану) — с полями ekran ([a-z0-9][a-z0-9-]{0,63}), kadry
(относительный путь) и fiktura != true. Судимая пачка исключает из
обнаружения себя (сравнение путей в каждом корне). Полнота объявлений
против обнаруженных живых пачек: живая пачка ТОГО ЖЕ ekran — её манифест
обязан быть назван в zamenjaet (ZAMENJAET_NE_POLON); живая пачка ЧУЖОГО
ekran — её манифест обязан стоять в ne_trogaet (NE_TROGAET_NE_POLON).
Замена целиком: заменяющий контракт экрана удаляет пачку предшественника
своей зоной — живость определяется наличием ekran.json.

Проверки (порядок «дешёвые раньше дорогих»: при любом отказе формы/полей
дешёвых проверок дорогое не зовётся):
  алфавит/грамматика формы и путей, существование файлов, разделы и ОБЪЁМ
  (≤ 60 строк) контракта, равенство ЗОНА-строк контракта форме, запрет
  литералов, ключи копии, операции API, покрытие сценария, токены команды
  сверки, замена целиком, чужие кадры, полнота объявлений — затем ИСПОЛНЕНИЕ
  priemka.e2e (argv, rc 0), СВЕЖЕСТЬ оставшихся кадров (ревизия kadry_dir
  до команды: пути+sha256; после — mtime моложе старта и байты иные —
  оставшиеся кадры прежнего прогона не засчитываются, KADR_USTAREVSHIJ),
  сверка-образец раннером 123 по манифесту пачки (каждый кадр не ниже
  порога), затем ИСПОЛНЕНИЕ priemka.sverka (argv, rc 0 + дословное
  совпадение вывода со сверкой-образцом).

Литералы (ЗАПРЕЩЕНЫ во всех текстовых файлах пачки; судятся КЛАССОМ, не
перечнем образцов — обход круга 2: hwb()/проценты/ch): цвета — hex
#[0-9a-fA-F]{3,8} И ЛЮБАЯ функциональная запись «идентификатор(…число…)»
(все CSS-функции цвета и функциональные нотации размеров: rgb/hsl/hwb/
lab/oklch/color/calc/min/…); размеры — число с % ИЛИ любой буквенной
единицей 1–4 букв (px/rem/ch/vmin/…). Hex-дайджесты (16+ hex подряд:
sha-пины манифеста) маскируются до сверки — пин не литерал.

CLI: ekran_shablon.py --pack DIR --repo DIR --harness DIR
Вывод: stdout — строки раннера 123 (KADR...) дословно, затем при успехе
  SHABLON<TAB><ekran><TAB>OK
stderr — строка на отказ PRICHINA<TAB>имя<TAB>подробности.
rc: 0 — форма верна, приёмка исполнена, все кадры не ниже порога;
1 — LITERAL_VNE_AUDITA / KLJUCH_BEZ_KATALOGA / OPERACIJA_BEZ_SPEKA /
SCENARIJ_BEZ_SNIMKA / SAMODELNAYA_SVERKA / E2E_NE_PROSHLA / NE_TSELIKOM /
CHUZHIE_KADRY / ZAMENJAET_NE_POLON / NE_TROGAET_NE_POLON / ZONY_RASHODJATSJA /
RAZDEL_OTSVTSTVUET / NE_ODNA_STRANICA / KADR_NIZHE_POROGA /
KADR_OTSUTSTVUET / KADR_USTAREVSHIJ / KADR_NEODNOZNACHEN / KADR_NECHITAEM /
MAKET_PODMENEN;
2 — SHABLON_NEVEREN (грамматика формы, нет файла, манифест кадров вне
грамматики 123, fiktura у судимой) / SVERKA_123_ABSENT (нет раннера 123 —
инфраструктура).
"""
import hashlib
import json
import re
import subprocess
import sys
import time
from pathlib import Path

FORMA_KEYS = {'ekran', 'kadry', 'sostojanija', 'kljuchi_kopii', 'operacii_api',
              'katalog_kopii', 'spec_api', 'audit_tokenov', 'e2e_scenarij',
              'kadry_dir', 'kontrakt', 'batareja', 'priemka', 'zony',
              'zamenjaet', 'ne_trogaet', 'fiktura'}
RAZDELY = ['Воля владельца', 'Существующее', 'Инварианты',
           'Приёмочный критерий', 'Зоны и исполнители', 'ПРОВОДКА',
           'Модель угроз']
RE_EKRAN = re.compile(r'\A[a-z0-9][a-z0-9-]{0,63}\Z')
RE_SLOVO = re.compile(r'\A[a-z0-9-]+\Z')
RE_KLJUCH = re.compile(r'\A[A-Za-z0-9_.-]+\Z')
RE_PUT = re.compile(r'\A[A-Za-z0-9_./-]+\Z')
RE_PRIEMKA = re.compile(r'\A[A-Za-z0-9 ./_-]+\Z')
RE_ZONA_STROKA = re.compile(r'^ЗОНА (architect|implementer): (.+)$')
RE_CVET = re.compile(r'#[0-9a-fA-F]{3,8}\b'
                     r'|\b[a-zA-Z][a-zA-Z0-9-]*\([^()]*[0-9][^()]*\)')
RE_RAZMER = re.compile(r'\b[0-9]+(?:\.[0-9]+)?(?:%|[a-zA-Z]{1,4}\b)')
RE_HEX_ZHIST = re.compile(r'[0-9a-fA-F]{16,}')
MAX_STRANICA = 60
MAX_SHIRINA = 120
MAX_BAJT = 4000
RC2 = {'SHABLON_NEVEREN', 'SVERKA_123_ABSENT'}
# отказ раннера 123 -> имя отказа шаблона (по грамматике вывода 123)
RUNNER_MAP = {'NIZHE_POROGA': 'KADR_NIZHE_POROGA',
              'KADR_OTSUTSTVUET': 'KADR_OTSUTSTVUET',
              'KADR_NEODNOZNACHEN': 'KADR_NEODNOZNACHEN',
              'KADR_NECHITAEM': 'KADR_NECHITAEM',
              'MAKET_PODMENEN': 'MAKET_PODMENEN',
              'MANIFEST_NEVEREN': 'SHABLON_NEVEREN',
              'PUSTAYA_SVERKA': 'SHABLON_NEVEREN'}


def path_ok(p):
    return (isinstance(p, str) and bool(p) and bool(RE_PUT.match(p))
            and not p.startswith('/') and '..' not in p.split('/'))


def otkaz(name, detail):
    return 'PRICHINA\t%s\t%s' % (name, detail)


def _spisok(f, pole, re_, pustoj=False):
    """Списковое поле: список, алфавит, без повторов."""
    v = f.get(pole)
    if not isinstance(v, list):
        return [otkaz('SHABLON_NEVEREN', pole)]
    if not v and not pustoj:
        return [otkaz('SHABLON_NEVEREN', pole)]
    if len(set(v)) != len(v):
        return [otkaz('SHABLON_NEVEREN', pole + ': повторы')]
    for x in v:
        if not isinstance(x, str) or not re_.match(x):
            return [otkaz('SHABLON_NEVEREN', '%s: %r' % (pole, x))]
    return []


def check_alfavit(f):
    """Грамматика формы: состав ключей, алфавиты, замкнутость (041)."""
    if not isinstance(f, dict):
        return [otkaz('SHABLON_NEVEREN', 'forma не объект')]
    if set(f) != FORMA_KEYS:
        return [otkaz('SHABLON_NEVEREN',
                      'состав ключей != шаблон: %s' % sorted(set(f) ^ FORMA_KEYS))]
    bad = []
    if not isinstance(f['ekran'], str) or not RE_EKRAN.match(f['ekran']):
        bad.append(otkaz('SHABLON_NEVEREN', 'ekran'))
    fk = f['fiktura']
    if not isinstance(fk, bool):
        bad.append(otkaz('SHABLON_NEVEREN', 'fiktura'))
    elif fk:
        bad.append(otkaz('SHABLON_NEVEREN', 'fiktura: судимая пачка — не фикция'))
    bad += _spisok(f, 'sostojanija', RE_SLOVO)
    bad += _spisok(f, 'kljuchi_kopii', RE_KLJUCH)
    bad += _spisok(f, 'operacii_api', RE_KLJUCH, pustoj=True)
    for pole in ('kadry', 'katalog_kopii', 'spec_api', 'audit_tokenov',
                 'e2e_scenarij', 'kadry_dir', 'kontrakt'):
        if not path_ok(f[pole]):
            bad.append(otkaz('SHABLON_NEVEREN', pole))
    bat = f['batareja']
    if not isinstance(bat, list) or not bat:
        bad.append(otkaz('SHABLON_NEVEREN', 'batareja'))
    else:
        for x in bat:
            if not path_ok(x):
                bad.append(otkaz('SHABLON_NEVEREN', 'batareja: %r' % x))
                break
    pr = f['priemka']
    if (not isinstance(pr, dict) or set(pr) != {'e2e', 'sverka'}
            or not isinstance(pr['e2e'], str) or not RE_PRIEMKA.match(pr['e2e'])
            or not isinstance(pr['sverka'], str)
            or not RE_PRIEMKA.match(pr['sverka'])):
        bad.append(otkaz('SHABLON_NEVEREN', 'priemka'))
    z = f['zony']
    if not isinstance(z, dict) or set(z) != {'architect', 'implementer'}:
        bad.append(otkaz('SHABLON_NEVEREN', 'zony'))
    else:
        for imja in ('architect', 'implementer'):
            sp = z[imja]
            if not isinstance(sp, list) or not sp:
                bad.append(otkaz('SHABLON_NEVEREN', 'zony.' + imja))
                continue
            for x in sp:
                if not path_ok(x):
                    bad.append(otkaz('SHABLON_NEVEREN', 'zony.%s: %r' % (imja, x)))
                    break
    if not (f['zamenjaet'] is None or path_ok(f['zamenjaet'])):
        bad.append(otkaz('SHABLON_NEVEREN', 'zamenjaet'))
    nt = f['ne_trogaet']
    if not isinstance(nt, list):
        bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet'))
    else:
        for x in nt:
            if not path_ok(x):
                bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet: %r' % x))
                break
    return bad


def read_json(p: Path):
    return json.loads(p.read_text(encoding='utf-8'))


def load_kadry(path: Path):
    """Манифест кадров: структура грамматики 123 (значения судит раннер 123)."""
    try:
        m = read_json(path)
    except (OSError, ValueError):
        return None, [otkaz('SHABLON_NEVEREN', 'kadry не читается')]
    if not isinstance(m, dict) or not isinstance(m.get('kadry'), list) or not m['kadry']:
        return None, [otkaz('SHABLON_NEVEREN', 'kadry: не список кадров')]
    ids, snimki = [], []
    for e in m['kadry']:
        if not isinstance(e, dict) or not isinstance(e.get('id'), str):
            return None, [otkaz('SHABLON_NEVEREN', 'kadry: запись без id')]
        ids.append(e['id'])
        snimki.append(e.get('snimok'))
    if len(set(ids)) != len(ids):
        return None, [otkaz('SHABLON_NEVEREN', 'kadry: повторы id')]
    return {'ids': ids, 'snimki': snimki}, []


def check_fajly(f, pack: Path, repo: Path, harness: Path):
    bad = []
    if not (pack / f['kadry']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['kadry']))
    if not (pack / f['kontrakt']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['kontrakt']))
    for x in f['batareja']:
        if not (pack / x).is_file():
            bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + x))
            break
    for pole in ('katalog_kopii', 'spec_api', 'audit_tokenov', 'e2e_scenarij'):
        if not (repo / f[pole]).is_file():
            bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f[pole]))
    if not (repo / f['kadry_dir']).is_dir():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет каталога: ' + f['kadry_dir']))
    if f['zamenjaet'] is not None and not any(
            (r / f['zamenjaet']).is_file() for r in (harness, repo)):
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['zamenjaet']))
    for x in f['ne_trogaet']:
        if not any((r / x).is_file() for r in (harness, repo)):
            bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + x))
            break
    return bad


def check_razdely(tekst: str):
    bad = []
    for r in RAZDELY:
        s = '## ' + r
        if not any(line.rstrip('\r') == s for line in tekst.splitlines()):
            bad.append(otkaz('RAZDEL_OTSVTSTVUET', r))
    return bad


def check_objem(tekst: str):
    """Воля владельца «контракт экрана на одну страницу» — ТРИ меры:
    строки (переводы), ширина (сворачивание строк), байты (объём текста);
    обход круга 2: 47 строк / 261138 байт одной строкой."""
    stroki = tekst.splitlines()
    bad = []
    if len(stroki) > MAX_STRANICA:
        bad.append(otkaz('NE_ODNA_STRANICA',
                         'строк: %d (норма ≤ %d)' % (len(stroki), MAX_STRANICA)))
    shirina = max((len(s) for s in stroki), default=0)
    if shirina > MAX_SHIRINA:
        bad.append(otkaz('NE_ODNA_STRANICA',
                         'ширина: %d (норма ≤ %d)' % (shirina, MAX_SHIRINA)))
    bajt = len(tekst.encode('utf-8'))
    if bajt > MAX_BAJT:
        bad.append(otkaz('NE_ODNA_STRANICA',
                         'байт: %d (норма ≤ %d)' % (bajt, MAX_BAJT)))
    return bad


def check_zony_stroki(tekst: str, f):
    """ЗОНА-строки контракта = zony формы (множества, грамматика check_zones)."""
    bad, najdeno = [], {'architect': set(), 'implementer': set()}
    for line in tekst.splitlines():
        m = RE_ZONA_STROKA.match(line.rstrip('\r'))
        if m:
            for p in m.group(2).split():
                najdeno[m.group(1)].add(p)
    for imja in ('architect', 'implementer'):
        if najdeno[imja] != set(f['zony'][imja]):
            bad.append(otkaz('ZONY_RASHODJATSJA', imja))
    return bad


def check_literal(pack: Path):
    """Литералы цветов/размеров запрещены во всей пачке (аудит — в репо):
    судятся КЛАССОМ (hex + функция с числом; число + %/буквенная единица),
    sha-дайджесты 16+ hex маскируются — пин манифеста не литерал."""
    bad = []
    for p in sorted(pack.rglob('*')):
        if not p.is_file():
            continue
        try:
            tekst = p.read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            continue  # бинарный носитель
        for i, line in enumerate(tekst.splitlines(), 1):
            zaslon = RE_HEX_ZHIST.sub(' ', line)
            if RE_CVET.search(zaslon) or RE_RAZMER.search(zaslon):
                bad.append(otkaz('LITERAL_VNE_AUDITA',
                                 '%s:%d' % (p.relative_to(pack), i)))
                break
    return bad


def _operacii_json(obj, akk):
    """operationId собираются рекурсивно по всей спецификации."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == 'operationId' and isinstance(v, str):
                akk.add(v)
            _operacii_json(v, akk)
    elif isinstance(obj, list):
        for v in obj:
            _operacii_json(v, akk)


def check_kljuchi(f, repo: Path):
    try:
        kat = read_json(repo / f['katalog_kopii'])
    except (OSError, ValueError):
        return [otkaz('SHABLON_NEVEREN', 'katalog_kopii не читается')]
    if not isinstance(kat, dict):
        return [otkaz('SHABLON_NEVEREN', 'katalog_kopii не объект')]
    akk = set(kat)  # ключи каталога копии — верхний уровень (как D2.2.5.1)
    return [otkaz('KLJUCH_BEZ_KATALOGA', k) for k in f['kljuchi_kopii']
            if k not in akk]


def check_operacii(f, repo: Path):
    try:
        sp = read_json(repo / f['spec_api'])
    except (OSError, ValueError):
        return [otkaz('SHABLON_NEVEREN', 'spec_api не читается')]
    akk = set()
    _operacii_json(sp, akk)
    return [otkaz('OPERACIJA_BEZ_SPEKA', o) for o in f['operacii_api']
            if o not in akk]


def check_scenarij(f, repo: Path, kadry):
    try:
        stroki = (repo / f['e2e_scenarij']).read_text(
            encoding='utf-8').splitlines()
    except OSError:
        return [otkaz('SHABLON_NEVEREN', 'e2e_scenarij не читается')]
    bad = []
    for s in kadry['snimki']:
        if not isinstance(s, str) or not any(s in line for line in stroki):
            bad.append(otkaz('SCENARIJ_BEZ_SNIMKA', str(s)))
    return bad


def razbit_argv(cmd):
    """Алфавит priemka без кавычек/;|&$() — пробел единственный разделитель;
    исполнение — фактический argv без shell (прецедент Г3-002)."""
    return cmd.split(' ')


def check_priemka(f):
    sv = razbit_argv(f['priemka']['sverka'])
    if not any('sverka_maketa.py' in t for t in sv) or '--manifest' not in sv:
        return [otkaz('SAMODELNAYA_SVERKA',
                      'команда сверки не запускает механизм 123')]
    return []


def _nahodi_manifest(harness: Path, repo: Path, rel):
    """Манифест объявлен путём в харнессе ИЛИ репо продукта (живая пачка
    может стоять в любом корне); нет нигде/не манифест — None."""
    for root in (harness, repo):
        p = root / rel
        if not p.is_file():
            continue
        try:
            m = read_json(p)
        except (OSError, ValueError):
            return None
        if not isinstance(m, dict) or not isinstance(m.get('kadry'), list):
            return None
        return [e.get('id') for e in m['kadry'] if isinstance(e, dict)]
    return None


def check_tselikom(f, harness: Path, repo: Path, kadry):
    if f['zamenjaet'] is None:
        return []
    starye = _nahodi_manifest(harness, repo, f['zamenjaet'])
    if starye is None:
        return [otkaz('SHABLON_NEVEREN', 'zamenjaet: не манифест кадров')]
    return [otkaz('NE_TSELIKOM', i) for i in starye if i not in kadry['ids']]


def check_chuzhie(f, harness: Path, repo: Path, kadry):
    bad = []
    for rel in f['ne_trogaet']:
        chuzhie = _nahodi_manifest(harness, repo, rel)
        if chuzhie is None:
            bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet: не манифест'))
            continue
        for i in chuzhie:
            if i in kadry['ids']:
                bad.append(otkaz('CHUZHIE_KADRY', i))
    return bad


def _zhivye_v_korne(root: Path, pack: Path):
    """Живые пачки одного корня: ekran.json под fixtures/workshop_project/**
    с ekran/kadry и fiktura != true; судимая исключает себя (resolved)."""
    vne = []
    base = root / 'fixtures' / 'workshop_project'
    if not base.is_dir():
        return vne
    sobstvennyj = (pack / 'ekran.json').resolve()
    for p in sorted(base.rglob('ekran.json')):
        try:
            q = read_json(p)
        except (OSError, ValueError):
            continue
        if not isinstance(q, dict) or q.get('fiktura') is True:
            continue
        e, k = q.get('ekran'), q.get('kadry')
        if (not isinstance(e, str) or not RE_EKRAN.match(e)
                or not path_ok(k)):
            continue
        if p.resolve() == sobstvennyj:
            continue
        vne.append((e, p.parent.relative_to(root).joinpath(k).as_posix()))
    return vne


def zhivye_pachty(harness: Path, repo: Path, pack: Path):
    """Живые пачки В ОБОИХ корнях — харнессе И переданном репо продукта
    (обход круга 2: пачка в --repo невидима харнесс-скану); один и тот же
    относительный путь в двух корнях — одна запись."""
    vidno = {}
    for root in (harness, repo):
        for para in _zhivye_v_korne(root, pack):
            vidno[para] = None
    return sorted(vidno)


def check_polnota(f, harness: Path, repo: Path, pack: Path):
    """Полнота объявлений против ОБНАРУЖЕННЫХ живых пачек ОБЕИХ корней
    (мера против пустых zamenjaet/ne_trogaet): перечисление экранов —
    не самодекларация."""
    bad = []
    for ekran_q, kadry_q in zhivye_pachty(harness, repo, pack):
        if ekran_q == f['ekran']:
            if f['zamenjaet'] != kadry_q:
                bad.append(otkaz('ZAMENJAET_NE_POLON', kadry_q))
        elif kadry_q not in f['ne_trogaet']:
            bad.append(otkaz('NE_TROGAET_NE_POLON', kadry_q))
    return bad


def run_sverka(f, pack: Path, repo: Path, harness: Path):
    """Дорогая проверка — раннер 123 по коду (мера/порог манифеста кадров).

    Возвращает (rc_раннера, stdout_раннера, [отказы шаблона]).
    """
    runner = harness / 'scripts' / 'sverka_maketa.py'
    if not runner.is_file():
        return 2, '', [otkaz('SVERKA_123_ABSENT', str(runner))]
    p = subprocess.run(
        [sys.executable, str(runner), '--manifest', str(pack / f['kadry']),
         '--kadry', str(repo / f['kadry_dir']), '--repo', str(repo)],
        capture_output=True, text=True)
    bad = []
    for line in p.stderr.splitlines():
        chasti = line.split('\t')
        imja = RUNNER_MAP.get(chasti[0] if chasti else '')
        if imja:
            bad.append(otkaz(imja, '\t'.join(chasti[1:])))
    if p.returncode == 2 and not bad:
        bad.append(otkaz('SHABLON_NEVEREN', 'раннер 123: манифест кадров'))
    return p.returncode, p.stdout, bad


def _sha256_fajla(p: Path):
    h = hashlib.sha256()
    with p.open('rb') as fh:
        for chunk in iter(lambda: fh.read(1 << 16), b''):
            h.update(chunk)
    return h.hexdigest()


def svezhost_kadrov(kd: Path, start_ns: int, rester: dict):
    """Свежесть кадров (обход круга 2: e2e один раз, потом priemka.e2e=true
    оценивает СТАРЫЕ кадры): КАЖДЫЙ файл под kadry_dir обязан быть создан
    ЭТИМ запуском — mtime моложе старта команды И байты отличны от
    дозапусковой ревизии; иначе KADR_USTAREVSHIJ (fail-closed)."""
    bad = []
    for p in sorted(kd.rglob('*')):
        if not p.is_file():
            continue
        rel = p.relative_to(kd).as_posix()
        if p.stat().st_mtime_ns < start_ns or rester.get(rel) == _sha256_fajla(p):
            bad.append(otkaz('KADR_USTAREVSHIJ', rel))
    return bad


def run_priemka_e2e(f, repo: Path):
    """Исполнение приёмки e2e: фактический argv, cwd = репо, без shell.
    До команды — ревизия kadry_dir (пути+sha256) и метка старта; после
    rc 0 — СВЕЖЕСТЬ оставшихся кадров (команда без кадров даёт
    KADR_OTSUTSTVUET на сверке, не зелень; оставшиеся — KADR_USTAREVSHIJ)."""
    kd = repo / f['kadry_dir']
    rester = {}
    if kd.is_dir():
        rester = {p.relative_to(kd).as_posix(): _sha256_fajla(p)
                  for p in sorted(kd.rglob('*')) if p.is_file()}
    start_ns = time.time_ns()
    try:
        p = subprocess.run(razbit_argv(f['priemka']['e2e']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [otkaz('E2E_NE_PROSHLA', repr(e)[:120])]
    if p.returncode != 0:
        return [otkaz('E2E_NE_PROSHLA', 'rc=%d' % p.returncode)]
    return svezhost_kadrov(kd, start_ns, rester)


def run_priemka_sverka(f, repo: Path, obrazec_stdout: str):
    """Исполнение приёмки сверки: argv без shell; rc 0 И stdout дословно
    равен сверке-образцу раннера 123 (фиктивные echo/true не воспроизводят
    вывод механизма)."""
    try:
        p = subprocess.run(razbit_argv(f['priemka']['sverka']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [otkaz('SAMODELNAYA_SVERKA', 'не исполняется: %r' % e)]
    if p.returncode != 0 or p.stdout.splitlines() != obrazec_stdout.splitlines():
        return [otkaz('SAMODELNAYA_SVERKA',
                      'вывод не воспроизводит механизм 123')]
    return []


def main(argv=None):
    args = sys.argv[1:] if argv is None else argv
    if (len(args) != 6 or args[0] != '--pack' or args[2] != '--repo'
            or args[4] != '--harness'):
        print('CLI: ekran_shablon.py --pack DIR --repo DIR --harness DIR',
              file=sys.stderr)
        return 2
    pack = Path(args[1]).resolve()
    repo = Path(args[3]).resolve()
    harness = Path(args[5]).resolve()
    try:
        f = read_json(pack / 'ekran.json')
    except (OSError, ValueError):
        print(otkaz('SHABLON_NEVEREN', 'ekran.json'), file=sys.stderr)
        return 2
    otkazy = check_alfavit(f)
    kadry = None
    if not any(o.split('\t')[1] in RC2 for o in otkazy):
        kadry, kerr = load_kadry(pack / f['kadry'])
        otkazy += kerr
        otkazy += check_fajly(f, pack, repo, harness)
    stdout_run = ''
    if not any(o.split('\t')[1] in RC2 for o in otkazy):
        tekst = (pack / f['kontrakt']).read_text(encoding='utf-8')
        otkazy += check_razdely(tekst)
        otkazy += check_objem(tekst)
        otkazy += check_zony_stroki(tekst, f)
        otkazy += check_literal(pack)
        otkazy += check_kljuchi(f, repo)
        otkazy += check_operacii(f, repo)
        if kadry:
            otkazy += check_scenarij(f, repo, kadry)
        otkazy += check_priemka(f)
        if kadry:
            otkazy += check_tselikom(f, harness, repo, kadry)
            otkazy += check_chuzhie(f, harness, repo, kadry)
        otkazy += check_polnota(f, harness, repo, pack)
        if not otkazy:
            otkazy += run_priemka_e2e(f, repo)
        if not otkazy:
            _, stdout_run, bad = run_sverka(f, pack, repo, harness)
            otkazy += bad
            if stdout_run:
                sys.stdout.write(stdout_run if stdout_run.endswith('\n')
                                 else stdout_run + '\n')
        if not otkazy:
            otkazy += run_priemka_sverka(f, repo, stdout_run)
    for o in otkazy:
        print(o, file=sys.stderr)
    if otkazy:
        return 2 if any(o.split('\t')[1] in RC2 for o in otkazy) else 1
    print('SHABLON\t%s\tOK' % f['ekran'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
