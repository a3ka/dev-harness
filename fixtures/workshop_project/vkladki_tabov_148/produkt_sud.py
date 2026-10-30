#!/usr/bin/env python3
# Продукт-судья батареи 148 (§ПРОВОДКА): судит дерево R (референсная
# раскладка модели или живой продукт --repo) по предмету vkladki-tabov.
"""produkt_sud.py --repo R: статические маркеры шва/Mitte/контента/копии
+ полный суд пачки валидатором-ЭТАЛОНОМ v3 (132/2 + ветка dvizhenie
батареи 146) в синтетическом репо из файлов R + ИСПОЛНЯЕМЫЙ суд
(блок 1 Crit148): живой jest-зонд produkt/vkladki-zond-148.test.tsx на
РЕАЛЬНЫХ компонентах R в изолированной копии mobile + матрица трёх
мутаций (tabs/badge/skroll) — контроль зелен, мутанты убиты.

Отказы — именованные (правило 7), по одному на клетку (каскады срезаны
порядком суда: дешёвые маркеры раньше дорогого валидатора, jest —
последним):
  PACHKA_ABSENT / SHOV_NET / MITTE_NET / MITTE_V_TAB / KONTENT_NET /
  KOPII_NET / MAKET_PIN_NEVEREN (в т.ч. отсутствие файла по пути,
  блок 2) / SCENARIJ_BEZ_SNIMKA / PROKHOD_BEZ_PRESSABLE +
  ISPOLNIMYJ_KONTROL_KRASEN / ISPOLNIMYJ_MUTANT_ZHIV /
  ISPOLNIMYJ_MUTANT_NE_UBIT / ISPOLNIMYJ_INFRA (блок 1) +
  причины валидатора (PRICHINA-строки эталона).
rc: 0 — зелено; 1 — именованный отказ; 2 — нечем судить (нет эталона
146 / нет носителей / ORACLE_TAMPERED / LIVE_PREDPOSYLKA /
LIVE_MUTACIJA_NEPRIMENIMA)."""
import argparse
import hashlib
import importlib.util
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
RUNNER123 = H_ROOT / 'scripts' / 'sverka_maketa.py'
NOS_MAKET = HERE / 'nositeli/maket'
NOS_D24 = HERE / 'nositeli/d24'
NOS_TOKENS = HERE / 'nositeli/tokens.css'
NOS_D24_REAL = HERE / 'nositeli/d24-real'

ETALON_146 = HERE / 'model' / 'ekran_shablon.py'
ETALON_146_PIN = '5fd1415e40b257e5e7b97c7bf9bc8fe31e94dcea9e05c4c3ac44d68802db453b'
ZOND = HERE / 'produkt' / 'vkladki-zond-148.test.tsx'
ZOND_IMJA = 'vkladki-zond-148.test.tsx'
ZOND_KUDA = 'src/bootstrap/__tests__'

# Матрица исполняемых мутаций — дословные атаки Crit148 (блок 1): якорь
# обязан встречаться в файле копии РОВНО один раз, иначе именованная
# неприменимость (rc 2), никогда тихий пропуск.
MUTACII_ISPOLNIMYE = [
    ('tabs', 'mobile/src/bootstrap/tab-shell.tsx',
     "section !== 'start' && sectionScreens?.[section] ? (",
     "section === 'start' && sectionScreens?.[section] ? ("),
    ('badge', 'mobile/src/app/(tabs)/[section].tsx',
     "mitteIzMarshruta === 'needs'",
     "mitteIzMarshruta === 'never-needs'"),
    ('skroll', 'mobile/src/bootstrap/tab-shell.tsx',
     "tabbarOverlay: { bottom: 0, left: 0, position: 'absolute', right: 0 },",
     "tabbarOverlay: { bottom: 0, left: 0, position: 'relative', right: 0 },"),
]

SHOV_MARKERY = [
    'readonly sectionScreens?: Readonly<Partial<Record<ShellSection, React.ReactNode>>>;',
    'readonly mitte?: React.ReactNode;',
]
MITTE_MARKERY = [
    "import { FadenSign } from '../lib/faden/FadenSign';",
    'size="tab"',
    'testID="gespraech-mitte"',
    "working: 'ui.vorgaenge.group.working'",
    "needs_action: 'ui.vorgaenge.group.needs_you'",
    "uiCopyDe['proposed.gespraech.tab.a11y']",
]
KOPII_KLJUCHI = [
    'proposed.gespraech.tab',
    'proposed.gespraech.tab.a11y',
    'ui.vorgaenge.group.working',
    'ui.vorgaenge.group.needs_you',
    'ui.vorgaenge.group.waiting',
    'ui.vorgaenge.subtitle',
    'ui.mission.all_done',
    'ui.post.filter.all',
    'ui.post.filter.received',
    'ui.post.filter.sent',
    'ui.post.send_to_complior',
]
KONTENT_FAJLY = [
    'mobile/src/features/missions/components/VorgaengeListe.tsx',
    'mobile/src/features/protection/components/SchutzUebersicht.tsx',
    'mobile/src/features/post/components/PostEingang.tsx',
]
SNIMKI_OSNOVNOJ = ['vkladki-vorgaenge', 'vkladki-schutz', 'vkladki-post',
                   'vkladki-vorgaenge-skroll']
SNIMKI_PROFILJA = [s + '-393' for s in SNIMKI_OSNOVNOJ]
OBOLOCHKA = 'tabshell'


def sha256_fajla(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def put_maketa(repo: Path, rel: str):
    """Макет — файл по КАНОНИЧЕСКОМУ пути в R (блок 2 Crit148): носитель
    батареи НЕ подменяет путь; отсутствие файла == MAKET_PIN_NEVEREN."""
    put = repo / rel
    return put if put.is_file() else None



def _png_dekodirovat(blob):
    """IHDR/IDAT-разбор + распаковка фильтров; ct 2 (RGB) и 6 (RGBA),
    bd 8. Возвращает (w, h, ch, rows[bytes])."""
    import struct
    import zlib
    pos, idat, ihdr = 8, bytearray(), None
    while pos < len(blob):
        ln, typ = struct.unpack('>I4s', blob[pos:pos + 8])
        body = blob[pos + 8:pos + 8 + ln]
        if typ == b'IHDR':
            ihdr = body
        elif typ == b'IDAT':
            idat += body
        pos += 12 + ln
    w, h, bd, ct = struct.unpack('>IIBB', ihdr[:10])
    assert bd == 8 and ct in (2, 6), 'ожидался RGB/RGBA'
    ch = 3 if ct == 2 else 4
    raw = zlib.decompress(bytes(idat))
    stride = w * ch
    rows, prev = [], bytearray(stride)
    i = 0
    for _y in range(h):
        f = raw[i]
        i += 1
        line = bytearray(raw[i:i + stride])
        i += stride
        if f == 1:
            for x in range(ch, stride):
                line[x] = (line[x] + line[x - ch]) & 0xFF
        elif f == 2:
            for x in range(stride):
                line[x] = (line[x] + prev[x]) & 0xFF
        elif f == 3:
            for x in range(stride):
                a = line[x - ch] if x >= ch else 0
                line[x] = (line[x] + ((a + prev[x]) >> 1)) & 0xFF
        elif f == 4:
            for x in range(stride):
                a = line[x - ch] if x >= ch else 0
                b = prev[x]
                c = prev[x - ch] if x >= ch else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 0xFF
        prev = line
        rows.append(bytes(line))
    return w, h, ch, rows


def _png_kodirovat_rgba(w, h, ch, rows):
    """Кодирование в RGBA (ct 6): RGB-строки расширяются альфой 255."""
    import struct
    import zlib

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d
                + struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF))
    if ch == 3:
        rows = [b''.join(bytes(r[x:x + 3]) + b'\\xff' for x in range(0, len(r), 3))
                for r in rows]
    raw2 = b''.join(b'\\x00' + r for r in rows)
    return (b'\\x89PNG\\r\\n\\x1a\\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw2, 1)) + chunk(b'IEND', b''))


def png_perekodirovat(blob):
    """Честный кадр stand-in: пиксели те же, байты иные (приём 118/132)."""
    w, h, ch, rows = _png_dekodirovat(blob)
    return _png_kodirovat_rgba(w, h, ch, rows)


def staticheskie_proverki(repo: Path, src):
    otkazy = []
    pachka = repo / 'mobile/e2e-vkladki'
    if not (pachka / 'ekran.json').is_file():
        return ['PACHKA_ABSENT: нет mobile/e2e-vkladki/ekran.json']
    shov = repo / 'mobile/src/bootstrap/tab-shell.tsx'
    if not shov.is_file():
        otkazy.append('SHOV_NET: нет mobile/src/bootstrap/tab-shell.tsx')
    else:
        tekst = shov.read_text(encoding='utf-8')
        net = [m for m in SHOV_MARKERY if m not in tekst]
        if net:
            otkazy.append('SHOV_NET: нет маркеров слота: %s' % net)
    mitte = repo / 'mobile/src/bootstrap/gespraech-mitte.tsx'
    if not mitte.is_file():
        otkazy.append('MITTE_NET: нет mobile/src/bootstrap/gespraech-mitte.tsx')
    else:
        tekst = mitte.read_text(encoding='utf-8')
        net = [m for m in MITTE_MARKERY if m not in tekst]
        if net:
            otkazy.append('MITTE_NET: нет маркеров Mitte: %s' % net)
        if 'accessibilityRole="tab"' in tekst:
            otkazy.append('MITTE_V_TAB: Mitte несёт accessibilityRole="tab" '
                          '(замороженная грамматика 999 — role=tab ровно четыре)')
    net_fajly = [f for f in KONTENT_FAJLY if not (repo / f).is_file()]
    if net_fajly:
        otkazy.append('KONTENT_NET: %s' % net_fajly)
    kopii = repo / 'mobile/src/i18n/ui-copy.ts'
    if not kopii.is_file():
        otkazy.append('KOPII_NET: нет mobile/src/i18n/ui-copy.ts')
    else:
        tekst = kopii.read_text(encoding='utf-8')
        net = [k for k in KOPII_KLJUCHI if ("'%s'" % k) not in tekst]
        if net:
            otkazy.append('KOPII_NET: нет ключей: %s' % net)
    # манифесты кадров: 8+8, макеты — файлы по каноническим путям R с
    # пинами байтов (блок 2 Crit148: путь обязателен, подмены носителем нет)
    for imja_manifesta in ('kadry.json', 'kadry_profil.json'):
        try:
            man = json.loads((pachka / imja_manifesta).read_text(encoding='utf-8'))
        except (OSError, ValueError):
            otkazy.append('MAKET_PIN_NEVEREN: %s не читается' % imja_manifesta)
            continue
        kadry = man.get('kadry', [])
        if len(kadry) != 8:
            otkazy.append('MAKET_PIN_NEVEREN: %s кадров %d != 8' % (imja_manifesta, len(kadry)))
            continue
        for k in kadry:
            put = put_maketa(repo, k['maket'])
            if put is None or sha256_fajla(put) != k['maket_sha256']:
                otkazy.append('MAKET_PIN_NEVEREN: %s: %s (путь %s)'
                              % (imja_manifesta, k['id'], k['maket']))
                break
    # флоу: снимки обоих профилей + pressable
    osn = repo / 'mobile/.maestro/vkladki.yaml'
    if not osn.is_file():
        otkazy.append('SCENARIJ_BEZ_SNIMKA: нет mobile/.maestro/vkladki.yaml')
    else:
        tekst = osn.read_text(encoding='utf-8')
        for s in SNIMKI_OSNOVNOJ:
            if s not in tekst:
                otkazy.append('SCENARIJ_BEZ_SNIMKA: vkladki.yaml без %s' % s)
                break
    prof = repo / 'mobile/.maestro/vkladki-tabshell-393.yaml'
    if not prof.is_file():
        otkazy.append('SCENARIJ_BEZ_SNIMKA: нет vkladki-tabshell-393.yaml')
    else:
        tekst = prof.read_text(encoding='utf-8')
        for s in SNIMKI_PROFILJA:
            if s not in tekst:
                otkazy.append('SCENARIJ_BEZ_SNIMKA: 393 без %s' % s)
                break
        # токен оболочки — обособленным словом в исполняемой строке
        if not any(OBOLOCHKA in l.split('#', 1)[0].replace(':', ' ').split()
                   for l in tekst.splitlines()):
            otkazy.append('SCENARIJ_BEZ_SNIMKA: 393 без токена оболочки %s' % OBOLOCHKA)
    prokh = repo / 'mobile/.maestro/prokhod-vkladki.yaml'
    if not prokh.is_file():
        otkazy.append('PROKHOD_BEZ_PRESSABLE: нет prokhod-vkladki.yaml')
    else:
        tekst = prokh.read_text(encoding='utf-8')
        ispolnimye = [l.split('#', 1)[0] for l in tekst.splitlines()]
        net_id = [p['id'] for p in src['ekran_forma']['prokhodimost']['pressable']
                  if not any(p['id'] in l for l in ispolnimye)]
        if net_id:
            otkazy.append('PROKHOD_BEZ_PRESSABLE: %s' % net_id[:3])
    return otkazy


def sobrat_repo(repo: Path, tmp: Path, src):
    """Синтетическое репо для эталона: пачка R + макеты R/носителей +
    пиннованные источники + stand-in команды приёмки + пин 123."""
    sint = tmp / 'repo'
    pachka = sint / 'mobile/e2e-vkladki'
    pachka.mkdir(parents=True)
    for f in repo.joinpath('mobile/e2e-vkladki').iterdir():
        if f.is_file():
            shutil.copyfile(f, pachka / f.name)
    batareja = pachka / 'batareja'
    batareja.mkdir(exist_ok=True)
    for f in repo.joinpath('mobile/e2e-vkladki/batareja').iterdir():
        shutil.copyfile(f, batareja / f.name)
    # макеты по каноническим путям R (существование гарантировано
    # строгой проверкой put_maketa в staticheskie_proverki — блок 2)
    for imja in ('kadry.json', 'kadry_profil.json'):
        man = json.loads((pachka / imja).read_text(encoding='utf-8'))
        for k in man['kadry']:
            kuda = sint / k['maket']
            if not kuda.parent.exists():
                kuda.parent.mkdir(parents=True)
            shutil.copyfile(repo / k['maket'], kuda)
    # источники движения (пиннованные реальные байты)
    for pole, imja in (('manifest', 'manifest.json'), ('spec', 'spec.json'),
                       ('pozvonok', 'poses.json')):
        put = sint / src['ekran_forma']['dvizhenie'][pole]
        if not put.parent.exists():
            put.parent.mkdir(parents=True)
        shutil.copyfile(NOS_D24_REAL / imja, put)
    # манифесты ne_trogaet из R (продуктовые пачки 118/135): суд по
    # КАЖДОМУ НАЙДЕННОМУ манифесту каждого корня (132 §zamenjaet) — в
    # корне сборки остаются только разрешимые пути (файл есть в R либо в
    # корне харнесса); недостающие корневые пути отбрасываются ДО суда
    # (эталон требует существования каждого объявленного пути).
    forma = json.loads((pachka / 'ekran.json').read_text(encoding='utf-8'))
    for rel in forma.get('ne_trogaet', []):
        isto = repo / rel
        if isto.is_file():
            kuda = sint / rel
            if not kuda.parent.exists():
                kuda.parent.mkdir(parents=True)
            shutil.copyfile(isto, kuda)
    forma['ne_trogaet'] = [
        rel for rel in forma.get('ne_trogaet', [])
        if (sint / rel).is_file() or (H_ROOT / rel).is_file()]
    (pachka / 'ekran.json').write_text(
        json.dumps(forma, ensure_ascii=False, indent=1), encoding='utf-8')
    # аудит токенов (копия продукта, пин в source.json)
    put = sint / src['ekran_forma']['audit_tokenov']
    put.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(NOS_TOKENS, put)
    # флоу из R
    for f in ('vkladki.yaml', 'vkladki-tabshell-393.yaml', 'prokhod-vkladki.yaml'):
        isto = repo / 'mobile/.maestro' / f
        if isto.is_file():
            kuda = sint / 'mobile/.maestro' / f
            kuda.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(isto, kuda)
    # stand-in команды приёмки: обёртки в пачке, помощники ВНЕ пачки
    # (аудит литералов пачки судит каждый текстовый файл пачки)
    pomm = sint / 'mobile/e2e-standin-vkladki'
    pomm.mkdir(parents=True, exist_ok=True)
    (sint / 'mobile/e2e-vkladki/e2e.sh').write_text(
        src['standiny']['e2e'], encoding='utf-8')
    (sint / 'mobile/e2e-vkladki/prokhod.sh').write_text(
        src['standiny']['prokhod'], encoding='utf-8')
    (sint / 'mobile/e2e-vkladki/dvizhenie.sh').write_text(
        src['standiny']['dvizhenie'], encoding='utf-8')
    for imja, kljuch in (('e2e-stand-in.py', 'e2e_py'),
                         ('e2e-ustarevshij.py', 'e2e_ustarevshij_py'),
                         ('e2e-nizhe-poroga.py', 'e2e_nizhe_poroga_py'),
                         ('stand_in_png.py', 'png'),
                         ('dvizhenie-stand-in.py', 'dvizhenie_py')):
        (pomm / imja).write_text(src['standiny'][kljuch], encoding='utf-8')
    (sint / 'mobile/maestro-out-vkladki').mkdir(parents=True)
    # пин механизма 123 (как в продукте)
    pin123 = sint / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pachka / 'kadry.json', pin123 / 'kadry.json')
    return sint


def sud_pachki(repo: Path, src):
    """Полный суд пачки эталоном v3 в синтетическом репо (дорогой,
    последним). Возвращает (rc, stdout, stderr, prichiny)."""
    if not ETALON_146.is_file():
        return None
    if sha256_fajla(ETALON_146) != ETALON_146_PIN:
        return 'TAMPERED'
    tmp = Path(tempfile.mkdtemp(prefix='vkladki148-pr-'))
    try:
        sint = sobrat_repo(repo, tmp, src)
        p = subprocess.run(
            [sys.executable, str(ETALON_146), '--pack',
             str(sint / 'mobile/e2e-vkladki'), '--repo', str(sint),
             '--harness', str(H_ROOT)],
            capture_output=True, text=True)
        return p.returncode, p.stdout, p.stderr
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

def ispolnimyj_sud(repo: Path, src):
    """Исполняемый суд (блок 1 Crit148, класс «литерал на месте,
    исполняемое иное»): живой jest-зонд на РЕАЛЬНЫХ компонентах R в
    изолированной копии mobile (node_modules — симлинк установки R,
    прецедент zhivoj_komponent 145) + матрица трёх мутаций: контроль
    исходного кода зелен, каждый мутант убит ПРЕДМЕТНЫМ ассертом зонда.
    Возвращает (rc, prichiny).

    Дерево без mobile/package.json — не jest-среда (синтетические входы
    батареи): именованный пропуск в stderr, не зелень продукта. Дерево
    С package.json, но без установки — именованная предпосылка rc 2,
    НИКОГДА skip->pass (прецедент proba_live_put 145)."""
    mob = repo / 'mobile'
    if not (mob / 'package.json').is_file():
        print('ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда',
              file=sys.stderr)
        return 0, []
    if not ZOND.is_file() or sha256_fajla(ZOND) != src['piny']['produkt']['produkt/%s' % ZOND_IMJA]:
        return 2, ['ORACLE_TAMPERED: пин зонда не совпал']
    predposylki = []
    konfig = None
    for imja in ('jest.config.js', 'jest.config.json'):
        if (mob / imja).is_file():
            konfig = imja
            break
    if konfig is None:
        predposylki.append('нет mobile/jest.config.{js,json}')
    nm = mob / 'node_modules'
    for paket in ('jest-expo', '@testing-library/react-native'):
        if not (nm / paket / 'package.json').is_file():
            predposylki.append('не установлен пакет %s' % paket)
    if not (nm / '.bin' / 'jest').exists():
        predposylki.append('нет node_modules/.bin/jest')
    for rel in ('src/bootstrap/tab-shell.tsx', 'src/bootstrap/gespraech-mitte.tsx',
                'src/app/(tabs)/[section].tsx'):
        if not (mob / rel).is_file():
            predposylki.append('нет компонента %s' % rel)
    if predposylki:
        return 2, ['LIVE_PREDPOSYLKA: %s' % '; '.join(predposylki)]
    vrem = Path(tempfile.mkdtemp(prefix='vkladki148-live-'))
    try:
        kopija = vrem / 'mobile'
        shutil.copytree(mob, kopija, ignore=shutil.ignore_patterns('node_modules'))
        os.symlink(nm.resolve(), kopija / 'node_modules')
        zond = kopija / ZOND_KUDA / ZOND_IMJA
        zond.parent.mkdir(parents=True, exist_ok=True)
        zond.write_text(ZOND.read_text(encoding='utf-8'), encoding='utf-8')

        def zapustit():
            try:
                p = subprocess.run(
                    [str(kopija / 'node_modules' / '.bin' / 'jest'),
                     '--config', konfig, '--rootDir', '.',
                     '--ci', '--runInBand', '--json', 'vkladki-zond-148'],
                    cwd=kopija, capture_output=True, text=True, timeout=1200)
            except subprocess.TimeoutExpired:
                return None, 'ТАЙМАУТ jest (1200 с)'
            tek = (p.stdout or '').strip()
            try:
                return json.loads(tek), None
            except json.JSONDecodeError:
                a, b = tek.find('{'), tek.rfind('}')
                if a < 0 or b <= a:
                    return None, 'jest без JSON-итога rc=%d: %s' % (
                        p.returncode, (p.stderr or tek)[:200])
                try:
                    return json.loads(tek[a:b + 1]), None
                except json.JSONDecodeError:
                    return None, 'jest JSON не разобран rc=%d' % p.returncode

        def klassifikirovat(svod):
            """(упавших ассертов, не исполнившихся сьютов) — падение
            загрузки/трансформации НЕ засчитывается убитым мутантом."""
            assery, sjuity = 0, 0
            for sjuit in svod.get('testResults', []):
                utv = sjuit.get('assertionResults') or []
                if not utv:
                    sjuity += 1
                    continue
                for a in utv:
                    if a.get('status') == 'failed':
                        assery += 1
            return assery, sjuity

        ishodnye = {}
        for _imja, rel, _ankora, _zamena in MUTACII_ISPOLNIMYE:
            put = kopija / Path(rel).relative_to('mobile')
            ishodnye[rel] = put.read_text(encoding='utf-8')

        svod, oshibka = zapustit()
        if svod is None:
            return 1, ['ISPOLNIMYJ_INFRA: контроль: %s' % oshibka]
        assery, _sjuity = klassifikirovat(svod)
        zelen = bool(svod.get('success')) and int(svod.get('numPassedTests', 0)) > 0
        print('ISPOLNIMYJ kontrol %s — suites=%s tests=%s' % (
            'ZELEN' if zelen else 'KRASEN', svod.get('numTotalTestSuites'),
            svod.get('numTotalTests')), file=sys.stderr)
        if not zelen:
            return 1, ['ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных '
                       'компонентах R (упавших ассертов %d)' % assery]
        zhivye, neubit = [], []
        for imja, rel, ankora, zamena in MUTACII_ISPOLNIMYE:
            put = kopija / Path(rel).relative_to('mobile')
            tekst = ishodnye[rel]
            if tekst.count(ankora) != 1:
                return 2, ['LIVE_MUTACIJA_NEPRIMENIMA: %s: якорь не '
                           'уникален в %s' % (imja, rel)]
            put.write_text(tekst.replace(ankora, zamena, 1), encoding='utf-8')
            svod, oshibka = zapustit()
            if svod is None:
                neubit.append('%s(infra: %s)' % (imja, oshibka))
                print('ISPOLNIMYJ mutant %s INFRA — %s' % (imja, oshibka),
                      file=sys.stderr)
                continue
            assery, sjuity = klassifikirovat(svod)
            if assery > 0:
                print('ISPOLNIMYJ mutant %s UBIT — упавших ассертов %d'
                      % (imja, assery), file=sys.stderr)
            elif sjuity > 0:
                neubit.append('%s(сьют не исполнился)' % imja)
                print('ISPOLNIMYJ mutant %s NE_UBIT — сьют(ы) не исполнились'
                      % imja, file=sys.stderr)
            else:
                zhivye.append(imja)
                print('ISPOLNIMYJ mutant %s ZHIV — зонд зелён под мутантом'
                      % imja, file=sys.stderr)
            put.write_text(tekst, encoding='utf-8')
        prichiny = []
        if zhivye:
            prichiny.append('ISPOLNIMYJ_MUTANT_ZHIV: %s' % ', '.join(zhivye))
        if neubit:
            prichiny.append('ISPOLNIMYJ_MUTANT_NE_UBIT: %s' % ', '.join(neubit))
        return (1 if prichiny else 0), prichiny
    finally:
        shutil.rmtree(vrem, ignore_errors=True)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    a = ap.parse_args()
    repo = Path(a.repo).resolve()
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    otkazy = staticheskie_proverki(repo, src)
    if otkazy:
        for o in otkazy:
            print('PRICHINA\t%s' % o)
        return 1
    itog = sud_pachki(repo, src)
    if itog is None:
        print('PRICHINA\tETALON_146_ABSENT: нет эталона v3 (model/ekran_shablon.py)')
        return 2
    if itog == 'TAMPERED':
        print('PRICHINA\tORACLE_TAMPERED: пин эталона v3 не совпал')
        return 2
    rc, out, err = itog
    sys.stdout.write(out)
    for l in err.splitlines():
        if l.startswith('PRICHINA'):
            print(l)
    if rc != 0:
        return rc
    rc2, prichiny2 = ispolnimyj_sud(repo, src)
    for p in prichiny2:
        print('PRICHINA\t%s' % p)
    return rc2


if __name__ == '__main__':
    sys.exit(main())
