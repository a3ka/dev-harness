#!/usr/bin/env python3
# ЭТАЛОН 132: эталон поведения батареи fixtures/workshop_project/ekran_shablon_132/
# probe.py; та же грамматика вывода, что у субъекта scripts/ekran_shablon.py.
"""Шаблон контракта экрана mob (132): машиночитаемая форма ekran.json + проверки.

Форма (все ключи обязательны, замкнутый состав):
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
  kontrakt       путь в пачке: контракт экрана; несёт обязательные разделы
                 (Воля владельца, Существующее, Инварианты, Приёмочный
                 критерий, Зоны и исполнители, ПРОВОДКА, Модель угроз) и
                 ЗОНА-строки, равные zony формы
  batareja       непустой список путей в пачке: файлы батареи экрана
  priemka        {"e2e": строка rc-команды android-e2e, "sverka": строка
                 rc-команды сверки; обязана запускать sverka_maketa.py с
                 --manifest — самодельная сверка запрещена}
  zony           {"architect": [...], "implementer": [...]} — грамматика
                 check_zones: относительные пути без *?[ , без .., без
                 ведущего /; каталог с завершающей /
  zamenjaet      null | путь в харнессе: манифест кадров ЗАМЕНЯЕМОГО контракта
                 того же экрана; кадры нового — надмножество (замена целиком)
  ne_trogaet     список путей в харнессе: живые манифесты ЧУЖИХ экранов;
                 пересечение id кадров пусто (чужих пикселей не морозит)

Проверки (дорогая — сверка раннером 123 — стоит после дешёвых; при любом
отказе до сверки раннер не зовётся):
  алфавит/грамматика формы и путей, существование файлов, разделы контракта,
  равенство ЗОНА-строк контракта форме, запрет литералов
  (#[0-9a-fA-F]{3,8} и [0-9]+(px|pt|sp|dp)) во всех текстовых файлах пачки,
  ключи копии, операции API, покрытие сценария, строка сверки priemka,
  замена целиком, чужие кадры, сверка каждого кадра раннером 123.

CLI: ekran_shablon.py --pack DIR --repo DIR --harness DIR
Вывод: stdout — строки раннера 123 (KADR...) дословно, затем при успехе
  SHABLON<TAB><ekran><TAB>OK
stderr — строка на отказ PRICHINA<TAB>имя<TAB>подробности.
rc: 0 — форма верна и все кадры не ниже порога; 1 — LITERAL_VNE_AUDITA /
KLJUCH_BEZ_KATALOGA / OPERACIJA_BEZ_SPEKA / SCENARIJ_BEZ_SNIMKA /
SAMODELNAYA_SVERKA / NE_TSELIKOM / CHUZHIE_KADRY / ZONY_RASHODJATSJA /
RAZDEL_OTSVTSTVUET / KADR_NIZHE_POROGA / KADR_OTSUTSTVUET /
KADR_NEODNOZNACHEN / KADR_NECHITAEM / MAKET_PODMENEN; 2 — SHABLON_NEVEREN
(грамматика формы, нет файла, манифест кадров вне грамматики 123) /
SVERKA_123_ABSENT (нет раннера 123 — инфраструктура).
"""
import json
import re
import subprocess
import sys
from pathlib import Path

FORMA_KEYS = {'ekran', 'kadry', 'sostojanija', 'kljuchi_kopii', 'operacii_api',
              'katalog_kopii', 'spec_api', 'audit_tokenov', 'e2e_scenarij',
              'kadry_dir', 'kontrakt', 'batareja', 'priemka', 'zony',
              'zamenjaet', 'ne_trogaet'}
RAZDELY = ['Воля владельца', 'Существующее', 'Инварианты',
           'Приёмочный критерий', 'Зоны и исполнители', 'ПРОВОДКА',
           'Модель угроз']
RE_EKRAN = re.compile(r'\A[a-z0-9][a-z0-9-]{0,63}\Z')
RE_SLOVO = re.compile(r'\A[a-z0-9-]+\Z')
RE_KLJUCH = re.compile(r'\A[A-Za-z0-9_.-]+\Z')
RE_PUT = re.compile(r'\A[A-Za-z0-9_./-]+\Z')
RE_PRIEMKA = re.compile(r'\A[A-Za-z0-9 ./_-]+\Z')
RE_ZONA_STROKA = re.compile(r'^ЗОНА (architect|implementer): (.+)$')
RE_CVET = re.compile(r'#[0-9a-fA-F]{3,8}\b')
RE_RAZMER = re.compile(r'\b[0-9]+(?:\.[0-9]+)?(?:px|pt|sp|dp)\b')
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
    if f['zamenjaet'] is not None and not (harness / f['zamenjaet']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['zamenjaet']))
    for x in f['ne_trogaet']:
        if not (harness / x).is_file():
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
    """Литералы цветов/размеров запрещены во всей пачке (аудит — в репо)."""
    bad = []
    for p in sorted(pack.rglob('*')):
        if not p.is_file():
            continue
        try:
            tekst = p.read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            continue  # бинарный носитель
        for i, line in enumerate(tekst.splitlines(), 1):
            if RE_CVET.search(line) or RE_RAZMER.search(line):
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


def check_priemka(f):
    sv = f['priemka']['sverka']
    if 'sverka_maketa.py' not in sv or '--manifest' not in sv:
        return [otkaz('SAMODELNAYA_SVERKA',
                      'команда сверки не запускает механизм 123')]
    return []


def _ids_kadry(harness: Path, rel):
    try:
        m = read_json(harness / rel)
    except (OSError, ValueError):
        return None
    if not isinstance(m, dict) or not isinstance(m.get('kadry'), list):
        return None
    return [e.get('id') for e in m['kadry'] if isinstance(e, dict)]


def check_tselikom(f, harness: Path, kadry):
    if f['zamenjaet'] is None:
        return []
    starye = _ids_kadry(harness, f['zamenjaet'])
    if starye is None:
        return [otkaz('SHABLON_NEVEREN', 'zamenjaet: не манифест кадров')]
    return [otkaz('NE_TSELIKOM', i) for i in starye if i not in kadry['ids']]


def check_chuzhie(f, harness: Path, kadry):
    bad = []
    for rel in f['ne_trogaet']:
        chuzhie = _ids_kadry(harness, rel)
        if chuzhie is None:
            bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet: не манифест'))
            continue
        for i in chuzhie:
            if i in kadry['ids']:
                bad.append(otkaz('CHUZHIE_KADRY', i))
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
    if not any(o.split('\t')[1] in RC2 for o in otkazy):
        otkazy += check_razdely((pack / f['kontrakt']).read_text(encoding='utf-8'))
        otkazy += check_zony_stroki(
            (pack / f['kontrakt']).read_text(encoding='utf-8'), f)
        otkazy += check_literal(pack)
        otkazy += check_kljuchi(f, repo)
        otkazy += check_operacii(f, repo)
        if kadry:
            otkazy += check_scenarij(f, repo, kadry)
        otkazy += check_priemka(f)
        if kadry:
            otkazy += check_tselikom(f, harness, kadry)
            otkazy += check_chuzhie(f, harness, kadry)
        if not otkazy:
            _, stdout_run, bad = run_sverka(f, pack, repo, harness)
            otkazy += bad
            if stdout_run:
                sys.stdout.write(stdout_run if stdout_run.endswith('\n')
                                 else stdout_run + '\n')
    for o in otkazy:
        print(o, file=sys.stderr)
    if otkazy:
        return 2 if any(o.split('\t')[1] in RC2 for o in otkazy) else 1
    print('SHABLON\t%s\tOK' % f['ekran'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
