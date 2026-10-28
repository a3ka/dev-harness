#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 132 (§ПРОВОДКА): судит субъект scripts/ekran_shablon.py.
"""Батарея 132 (ekran-shablon): шаблон контракта экрана mob — машиночитаемая
форма ekran.json + механизм scripts/ekran_shablon.py.

Предмет: экранная пачка (ekran.json + контракт + манифест кадров + батарея)
судится по шаблону: состав полей и алфавиты (кадры → PNG docs/ux, состояния,
ключи копии, операции API), обязательные разделы контракта и его ОБЪЁМ
(≤ 60 строк И ≤ 120 символов в строке И ≤ 4000 байт — «на одну страницу»),
ЗОНА-строки по грамматике check_zones, запрет литералов цветов/размеров
КЛАССОМ (hex + любая функция с числом; число с % или буквенной единицей
1–4 букв; sha-дайджесты маскируются) вне общего аудита токенов D2.2.5.1,
замена целиком (zamenjaet), чужие пиксели (ne_trogaet), ПОЛНОТА объявлений
против обнаруженных живых пачек ОБОИХ корней (харнесс + --repo),
ИСПОЛНЕНИЕ приёмки (priemka.e2e/sverka — фактический argv, Г3-002),
СВЕЖЕСТЬ кадров (оставшиеся кадры прежнего прогона — KADR_USTAREVSHIJ)
и сверка каждого кадра раннером 123 (мера/порог — его код и манифест).
v2 (слово владельца 2026-10-27 ~22:45 UTC): ПРОХОДИМОСТЬ НОВОГО экрана
(shablon 2): блок prokhodimost (перечень pressable deistvie|neaktivna,
цели ≥ 44pt из MIN_KASANIE_PT эталона, вне safe-area, демо отдельно) и
третья команда priemka.prokhod — проход Maestro по видимым pressable.
v2-дополнение (слово владельца 2026-10-27 ~23:45 UTC, та же v+1): блок
vtoroj_profil — профиль iphone-safe-area (норма класса PROFIL_IPHONE
эталона: ≥ 393×852, вырез 47–59pt, home-indicator 34pt), сверка ЦЕЛОГО
экрана в СОБРАННОМ пути (obolochka; пустая — голый компонент) в ОБЕ темы
вторым манифестом кадров (раннер 123, вызов валидатора), наложения
слоёв/залезания под инсеты/пустые иконки — геометрией bbox из UI-дерева.
Правка по вердикту критика 1/2 (четыре блокера): старость экрана — факт
закрытого перечня замороженных старых экранов эталона (свежий экран без
shablon не выдаёт себя за старый); команда прохода несёт цель-флоу
Maestro, ссылающийся на каждый pressable; маршрут собранного пути
наблюдаем (marshrut содержит obolochka токеном и каждый snimok профиля).
Правка по РЕШЕНИЮ АРБИТРА contracts-132-v2-arbitraz (С-1/С-2/С-3):
С-1 — старость экрана = ПОДЛИННАЯ идентичность (id + пины maket_sha256
замороженного манифеста; отображение в эталоне), база батареи снова
честный НОВЫЙ экран demo-vkhod, зелёный контроль старого — сама пачка
сестры 135 (строит её probe), новая клетка «исторический id + чужие
макеты»; С-2 — ссылки (pressable/obolochka/snimok) засчитываются только
в ИСПОЛНЯЕМОМ тексте флоу (после первого «---», без комментариев YAML;
snimok — обособленным токеном), клетки на комментарий/шапку; С-3 —
текст контракта сужен до механизма (PROKHOD_NE_MAESTRO = argv без
цели-флою; echo/cat с .yaml в argv — честный остаток НЕ ЗАЩИЩАЕТ).

Режимы:
  (без флага)  субъект scripts/ekran_shablon.py; нет файла → rc 1 SHABLON_ABSENT
  --model      субъект model/ekran_shablon.py (эталон)
  --stabs      контроль моделью всех входов + каждый обманный стаб отвергнут
               на КАЖДОМ входе своей записи stab_vhod source.json
  --matrix     синоним --stabs (грамматика 123)
  --snapshot   (инструмент замера) фактические rc/вывод модели по каждому
               входу JSON-ом — числа для source.json из прогона, не из головы

Вывод: строка на вход `CASE <вход> ok|KRASNO`; --stabs добавляет строку на
связь `STAB <стаб> <вход> KRASEN`. rc: 0 — все входы зелёные (для --stabs:
контроль зелёный и все стабы пойманы); 1 — красный вход либо STAB_ZHIV;
2 — ORACLE_TAMPERED / SVERKA_123_ABSENT / нечем проверить.

Оракул — source.json (единый источник): kejsy (rc, prichiny построчно,
stdout построчно, допуск dopusk_score на числа KADR), stab_vhod (привязка
стабов к входам по коду ветвей, Н-39), nositeli (sha256 носителей — копии
кадров/макетов батареи 123, артефакты maestro-117). Ожидания снимаются в
память ДО вызова субъекта (правило 8); диск субъекта как истина не читается.
Носители и производные кадры — байтово та же пара, что в замере 123
(chestnyj-splash: 0,783/0,782) — вторая мера чисел этой батареи.
Остаточный риск (П-3, verdicts/arbitration/contracts-132-impl-kap.md):
подмена модулей рядом с байт-копией раннера 123 (sys.path[0] — каталог
скрипта; соседний json.py может воспроизвести stdout) и вообще
воспроизведение stdout образца вызовом из repo, которым владеет судимая
сторона. Кадры судит собственный вызов образца по pack/kadry.json; команда
sverka — заявление продукта о механизме. Ловцы — продуктовый CI экрана и ревью.
"""
import argparse
import hashlib
import json
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
SUBJECT = H_ROOT / 'scripts' / 'ekran_shablon.py'
RUNNER123 = H_ROOT / 'scripts' / 'sverka_maketa.py'
MODEL = HERE / 'model' / 'ekran_shablon.py'
STUBS = HERE / 'stubs'
AW, AH = 390, 844
FIKT = 'fixtures/workshop_project/ekran_shablon_132/model/fiktura'
# Честная команда прохода (блокер 2 вердикта критика 1/2): цель-флоу
# Maestro — существующий .yaml в репо, ссылающийся на каждый pressable.
PROKHOD_CMD = 'bash mobile/prokhod.sh mobile/.maestro/prokhod-demo-vkhod.yaml'


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


# --- PNG собственными средствами проверяющего (приём батареи 123) -----------

def png_decode(blob):
    pos, idat, ihdr = 8, bytearray(), None
    while pos < len(blob):
        ln, = struct.unpack('>I', blob[pos:pos + 4])
        typ, data = blob[pos + 4:pos + 8], blob[pos + 8:pos + 8 + ln]
        if typ == b'IHDR':
            ihdr = struct.unpack('>IIBBBBB', data)
        elif typ == b'IDAT':
            idat += data
        pos += 12 + ln
    w, h, depth, color, _, _, inter = ihdr
    assert depth == 8 and color == 2 and inter == 0, 'носитель вне RGB8'
    st = w * 3
    raw = zlib.decompress(bytes(idat))
    lo = int.from_bytes(b'\x7f' * st, 'big')
    hi = int.from_bytes(b'\x80' * st, 'big')
    rows, prev = [], bytearray(st)
    for y in range(h):
        f, line = raw[y * (st + 1)], bytearray(raw[y * (st + 1) + 1:(y + 1) * (st + 1)])
        if f == 2:  # Up: побайтовое сложение по модулю 256 без переноса
            u, v = int.from_bytes(line, 'big'), int.from_bytes(prev, 'big')
            line = bytearray((((u & lo) + (v & lo)) ^ ((u ^ v) & hi)).to_bytes(st, 'big'))
        elif f != 0:
            for i in range(st):
                a = line[i - 3] if i >= 3 else 0
                b = prev[i]
                c = prev[i - 3] if i >= 3 else 0
                if f == 1:
                    line[i] = (line[i] + a) & 255
                elif f == 3:
                    line[i] = (line[i] + ((a + b) >> 1)) & 255
                else:
                    p = a + b - c
                    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                    line[i] = (line[i] + (a if pa <= pb and pa <= pc else (b if pb <= pc else c))) & 255
        rows.append(line)
        prev = line
    return w, h, rows


def png_encode(w, h, rows):
    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    raw = b''.join(b'\x00' + bytes(r) for r in rows)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 1)) + chunk(b'IEND', b''))


def derive_bez_elementa(blob, polosa_pt):
    """Полоса polosa_pt [x0,y0,x1,y1] pt залита фоном (мода цвета по сетке
    шага 8 px): элемент пропал целиком, остальное не тронуто (приём 123)."""
    w, h, rows = png_decode(blob)
    cnt = {}
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            c = bytes(rows[y][3 * x:3 * x + 3])
            cnt[c] = cnt.get(c, 0) + 1
    bg = max(sorted(cnt), key=lambda c: cnt[c])
    x0, y0, x1, y1 = polosa_pt
    px0, px1 = x0 * w // AW, -(-x1 * w // AW)
    for y in range(y0 * h // AH, min(h, -(-y1 * h // AH))):
        rows[y][3 * px0:3 * px1] = bg * (px1 - px0)
    return png_encode(w, h, rows)


# --- оракул ------------------------------------------------------------------

def load_source():
    """source.json + защита оракула: sha носителей, согласованность стабов."""
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    for rel, pin in src['nositeli'].items():
        blob = (HERE / rel).read_bytes()
        if sha256_bytes(blob) != pin['sha256']:
            print('ORACLE_TAMPERED: носитель %s' % rel, file=sys.stderr)
            raise SystemExit(2)
    fajly_stabov = sorted(p.name for p in STUBS.glob('s*.py'))
    if fajly_stabov != sorted(src['stab_vhod']):
        print('ORACLE_TAMPERED: набор stubs/ != stab_vhod', file=sys.stderr)
        raise SystemExit(2)
    for imja, vhody in src['stab_vhod'].items():
        for v in vhody:
            if v not in src['kejsy']:
                print('ORACLE_TAMPERED: stab_vhod %s → нет входа %s' % (imja, v),
                      file=sys.stderr)
                raise SystemExit(2)
    return src


# --- построение входа ---------------------------------------------------------

def build_repo(src, tmp, pack):
    repo = tmp / 'repo'
    scr = repo / 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens'
    scr.mkdir(parents=True)
    shutil.copyfile(HERE / 'nositeli/maket/Splash.png', scr / 'Splash.png')
    shutil.copyfile(HERE / 'nositeli/maket/Splash-Hell.png', scr / 'Splash-Hell.png')
    ds = repo / 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/ds'
    ds.mkdir(parents=True)
    (ds / 'tokens.css').write_text(src['tokens_audit'], encoding='utf-8')
    kat = repo / 'docs/ux/01_UX_Source_of_Truth'
    kat.mkdir(parents=True)
    (kat / 'BrokerOS_UI_Copy_DE.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1), encoding='utf-8')
    api = repo / 'api'
    api.mkdir(parents=True)
    (api / 'openapi.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1), encoding='utf-8')
    ma = repo / 'mobile/.maestro'
    ma.mkdir(parents=True)
    (ma / 'demo-vkhod.yaml').write_text(src['flow'], encoding='utf-8')
    # stand-in android-e2e (replay) + носители записи: кадры в Maestro-раскладку
    # кладёт ИСПОЛНЕННАЯ команда priemka.e2e — стартуем с пустым kadry_dir
    (repo / 'mobile/e2e.sh').write_text(src['e2e_skript'], encoding='utf-8')
    # stand-in прохода Maestro по pressable (правило проходимости, слово
    # владельца 2026-10-27): для v2-пачки priemka несёт третью команду
    # prokhod; v1-пачка файл не читает (репо, не пачка — вне суда литералов)
    (repo / 'mobile/prokhod.sh').write_text(src['prokhod_skript'],
                                            encoding='utf-8')
    for tema in ('dark', 'light'):
        d = repo / 'mobile/e2e-nositeli' / tema
        d.mkdir(parents=True)
        shutil.copyfile(
            HERE / ('nositeli/kadry/r1423-%s-vkhod-117-splash.png' % tema),
            d / (src['snimok'] + '.png'))
        # второй профиль: носители кадров собранного пути кладёт
        # v2_repo_artefakty ниже — репо продукта, не пачка
    (repo / 'mobile/maestro-out-demo').mkdir(parents=True)
    # пин механизма 123 внутри репо (как в продукте): честная priemka.sverka
    # запускает раннер из .harness123; сверка-образец и приёмка обязаны
    # дать дословно одинаковый вывод
    pin123 = repo / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pack / 'kadry.json', pin123 / 'kadry.json')
    # Артефакты v2 в репо — ВСЕГДА (С-1 арбитража 132 v2: база батареи —
    # честный НОВЫЙ экран demo-vkhod; флоу прохода/собранного пути и
    # носители кадров профиля — часть репо продукта, не пачки): v1-пачка
    # их не читает, v2-пачка без блока судится именованным отказом при
    # честной команде прохода (прежние клетки ожиданий не меняют).
    v2_repo_artefakty(src, repo)
    return repo


def zapis(pack, forma):
    (pack / 'ekran.json').write_text(
        json.dumps(forma, ensure_ascii=False, indent=1), encoding='utf-8')


def build_pack(src, tmp):
    pack = tmp / 'pack'
    pack.mkdir()
    forma = json.loads(json.dumps(src['ekran_forma']))
    zapis(pack, forma)
    (pack / 'kadry.json').write_text(
        json.dumps(src['kadry_manifest'], ensure_ascii=False, indent=1), encoding='utf-8')
    # второй манифест кадров профиля (грамматика 123; живёт в пачке —
    # первый манифест НЕ меняется, прежние ожидания дословны); путь — из
    # честной v2-формы базы (единый источник ekran_forma)
    (pack / forma['vtoroj_profil']['kadry']).write_text(
        json.dumps(src['profil_kadry'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pack / 'kontrakt.md').write_text(src['kontrakt_tekst'], encoding='utf-8')
    b = pack / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['batareja_tekst'], encoding='utf-8')
    return pack, forma

def v2_repo_artefakty(src, repo):
    """Артефакты НОВОГО экрана в репо (кладутся ПОСТОЯННО — часть репо
    продукта, не пачки; С-1 арбитража 132 v2): флоу прохода по pressable,
    флоу собранного пути с входом в оболочку, носители кадров профиля —
    из source.json (единый источник). v2-пачка без блока судится
    именованным отказом при честной команде прохода."""
    ma = repo / 'mobile/.maestro'
    (ma / 'prokhod-demo-vkhod.yaml').write_text(src['prokhod_flow'],
                                                encoding='utf-8')
    (ma / 'demo-vkhod-tabshell.yaml').write_text(src['flow_profil'],
                                                 encoding='utf-8')
    for tema in ('dark', 'light'):
        d = repo / 'mobile/e2e-nositeli' / tema
        # кадры собранного пути — байтово та же пара носителей 123 под
        # именем снимка профиля (вторая мера чисел: та же пара 0,783/0,782)
        shutil.copyfile(
            HERE / ('nositeli/kadry/r1423-%s-vkhod-117-splash.png' % tema),
            d / (src['profil_kadry']['kadry'][0]['snimok'] + '.png'))


def v2_baza(forma, src, repo):
    """Честная пачка НОВОГО экрана (shablon 2) — С-1 арбитража 132 v2:
    база батареи 132 снова честный НОВЫЙ экран demo-vkhod (оба блока,
    три команды приёмки; ekran_forma source.json — единый источник), НЕ
    исторический id с чужими макетами. Мутации v2-клеток сбрасывают
    форму к честной базе перед своей правкой; артефакты репо уже
    положены build_repo."""
    forma['ekran'] = src['ekran_forma']['ekran']
    forma['shablon'] = 2
    forma['prokhodimost'] = json.loads(
        json.dumps(src['ekran_forma']['prokhodimost']))
    forma['vtoroj_profil'] = json.loads(
        json.dumps(src['ekran_forma']['vtoroj_profil']))
    forma['priemka']['prokhod'] = src['ekran_forma']['priemka']['prokhod']


SESTRY_135 = H_ROOT / 'fixtures' / 'workshop_project' / 'first_run_ekran_135'


def _probe_sestry_135():
    """Модуль probe.py сестры 135 (прецедент в обе стороны: probe 135
    читает фикстуры 132 — здесь 132 читает строителя сестры)."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        'probe135_sestra', SESTRY_135 / 'probe.py')
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def sud_staryj_ekrana():
    """ЗЕЛЁНЫЙ контроль старого экрана (С-1 арбитража 132 v2): судится
    ПОДЛИННАЯ замороженная пачка first-run-ekran — та, что строит батарея
    135 (манифест и носители сестры; зелена потому, что её манифест и
    есть источник пинов отображения эталона), а не самодекларация id и
    не исторический id с чужими макетами."""
    p135 = _probe_sestry_135()
    return p135.run_subject(MODEL, 'chestnyj-ekran', p135.load_source())


def nositel(repo, tema, snimok):
    return repo / 'mobile/e2e-nositeli' / tema / (snimok + '.png')


# --- мутации входов (код, не проза; ожидания — kejsy source.json) ------------

def mut_literal_cveta(pack, forma, repo, src):
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\n# фон экрана хозяина: #F3F2EE\n')


def mut_literal_razmera(pack, forma, repo, src):
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nОтступ заголовка: 56px сверху.\n')


def mut_kadr_nizhe_poroga(pack, forma, repo, src):
    f = nositel(repo, 'dark', src['snimok'])
    blob = derive_bez_elementa(f.read_bytes(), src['bez_elementa']['polosa_pt'])
    f.write_bytes(blob)


def mut_kadr_otsutstvuet(pack, forma, repo, src):
    """Третий кадр манифеста есть в сценарии (строка takeScreenshot),
    но записи e2e для него нет — реплей кадра не кладёт, раннер 123
    называет его отсутствующим."""
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    tretij = json.loads(json.dumps(m['kadry'][1]))
    tretij['id'] = 'Splash dva'
    tretij['snimok'] = 'vkhod-demo-splash-dva'
    m['kadry'].append(tretij)
    (pack / 'kadry.json').write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')
    flow = repo / 'mobile/.maestro/demo-vkhod.yaml'
    flow.write_text(
        flow.read_text(encoding='utf-8')
        + '- takeScreenshot: vkhod-demo-splash-dva\n', encoding='utf-8')


def mut_chuzhoj_kadr(pack, forma, repo, src):
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    chuzhoj = json.loads(json.dumps(m['kadry'][0]))
    chuzhoj['id'] = 'Fiktura-Kadr-Chuzhoj'
    m['kadry'].append(chuzhoj)
    (pack / 'kadry.json').write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_ne_tselikom(pack, forma, repo, src):
    forma['zamenjaet'] = FIKT + '/kadry_starogo_tri.json'
    zapis(pack, forma)


def mut_kljuch_bez_kataloga(pack, forma, repo, src):
    forma['kljuchi_kopii'].append('ui.vkhod.neizvestnyj')
    zapis(pack, forma)


def mut_operacija_bez_speka(pack, forma, repo, src):
    forma['operacii_api'].append('netTakojOperacii')
    zapis(pack, forma)


def mut_scenarij_bez_snimka(pack, forma, repo, src):
    p = repo / 'mobile/.maestro/demo-vkhod.yaml'
    stroki = [l for l in p.read_text(encoding='utf-8').splitlines()
              if src['snimok'] not in l]
    p.write_text('\n'.join(stroki) + '\n', encoding='utf-8')


def mut_samodelnaja_sverka(pack, forma, repo, src):
    forma['priemka']['sverka'] = (
        'python3 scripts/moja_sverka.py --kadry mobile/maestro-out-demo --repo .')
    zapis(pack, forma)


def mut_sostojanie_nevernoe(pack, forma, repo, src):
    forma['sostojanija'] = ['start', 'tema\tdark']
    zapis(pack, forma)


def mut_zony_s_globom(pack, forma, repo, src):
    forma['zony']['implementer'].append('mobile/src/ui/*')
    zapis(pack, forma)


def mut_zony_rashodjatsja(pack, forma, repo, src):
    p = pack / 'kontrakt.md'
    tekst = p.read_text(encoding='utf-8').replace(
        'ЗОНА implementer: mobile/src/features/demo/',
        'ЗОНА implementer: mobile/src/features/demo/ mobile/src/features/chuzhaja/')
    p.write_text(tekst, encoding='utf-8')


def mut_bez_razdela(pack, forma, repo, src):
    p = pack / 'kontrakt.md'
    stroki = [l for l in p.read_text(encoding='utf-8').splitlines()
              if l.rstrip('\r') != '## Модель угроз']
    p.write_text('\n'.join(stroki) + '\n', encoding='utf-8')


def mut_paket_bez_manifesta(pack, forma, repo, src):
    (pack / 'ekran.json').unlink()


def mut_priemka_lozhnaja(pack, forma, repo, src):
    """Обход критика круга 1: e2e="true", sverka="echo sverka_maketa.py
    --manifest" — команды rc 0 без работы; кадры после e2e отсутствуют.
    Правка арбитража v2: priemka v2 несёт ТРИ команды — мутация правит
    e2e/sverka, честная prokhod остаётся (клетка изолирует СВОЮ ветвь,
    состав ключей priemka не ломает)."""
    forma['priemka']['e2e'] = 'true'
    forma['priemka']['sverka'] = 'echo sverka_maketa.py --manifest'
    zapis(pack, forma)


def mut_e2e_ne_proshla(pack, forma, repo, src):
    forma['priemka']['e2e'] = 'bash mobile/e2e.sh net-takogo'
    zapis(pack, forma)


def mut_sverka_lozhnaya(pack, forma, repo, src):
    forma['priemka']['sverka'] = 'echo sverka_maketa.py --manifest'
    zapis(pack, forma)


def mut_zamenjaet_pustoj(pack, forma, repo, src):
    """Обход критика круга 1: zamenjaet=null при живой пачке того же экрана
    (ekran присваивается словарю живой фикстуры-пачки)."""
    forma['ekran'] = 'fiktura-tot-zhe-ekran'
    forma['zamenjaet'] = None
    zapis(pack, forma)


def mut_ne_trogaet_pustoj(pack, forma, repo, src):
    """Обход критика круга 1: ne_trogaet=[] при живых чужих пачках."""
    forma['ne_trogaet'] = []
    zapis(pack, forma)


def mut_literal_cveta_funkc(pack, forma, repo, src):
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\n# фон хозяина: rgb(243, 242, 238)\n')


def mut_literal_razmera_rem(pack, forma, repo, src):
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nОтступ страницы: 3rem.\n')


def mut_kontrakt_slishkom_dlinnyj(pack, forma, repo, src):
    """Обход критика круга 1: сотни строк прозы без литералов — «одна
    страница» без меры объёма проходила."""
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nЗапас страницы за пределами одной.\n' * 20)

def mut_literal_cveta_hwb(pack, forma, repo, src):
    """Обход критика круга 2: hwb() вне перечня образцов — литералы
    судятся КЛАССОМ (любая функция цвета с числом), не списком."""
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\n# фон хозяина: hwb(30 20% 10%)\n')


def mut_literal_razmera_protsent(pack, forma, repo, src):
    """Обход критика круга 2: процентная величина — размер-литерал
    (число + % — класс единиц, не перечень)."""
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nШирина панели: 50% экрана.\n')


def mut_literal_razmera_ch(pack, forma, repo, src):
    """Обход критика круга 2: единица ch вне перечня — размер-литерал
    (любая буквенная единица 1–4 букв)."""
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nПоле ввода: отступ 3ch от края.\n')


def mut_kadry_ustarevshie(pack, forma, repo, src):
    """Обход критика круга 2: e2e исполнена ДО суда, кадры лежат в
    maestro-раскладке, priemka.e2e подменена на no-op true — приёмка
    обязана отказаться от СТАРЫХ кадров (KADR_USTAREVSHIJ)."""
    zap = subprocess.run(['bash', 'mobile/e2e.sh', 'demo-vkhod'], cwd=str(repo),
                         capture_output=True, text=True)
    if zap.returncode != 0:
        raise RuntimeError('replay e2e: rc=%d %s' % (zap.returncode, zap.stderr))
    forma['priemka']['e2e'] = 'true'
    zapis(pack, forma)


def mut_zhivaja_pachta_v_repo(pack, forma, repo, src):
    """Обход критика круга 2: живая пачка ТОГО ЖЕ экрана в переданном
    продукте (--repo) — невидима харнесс-скану; замена неполна молча."""
    d = repo / 'fixtures/workshop_project/old_screen_001'
    d.mkdir(parents=True)
    (d / 'ekran.json').write_text(json.dumps(
        src['repo_staryj_ekran']['ekran'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (d / 'kadry.json').write_text(json.dumps(
        src['repo_staryj_ekran']['kadry'], ensure_ascii=False, indent=1),
        encoding='utf-8')


def mut_kontrakt_shirokij(pack, forma, repo, src):
    """Обход критика круга 2: стену текста сворачивают в одну строку —
    объём без ширины/байт не страница (47 строк / 261138 байт)."""
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('Требование_без_разрыва ' * 300 + '\n')

def mut_literal_cveta_mnogostrochnyj(pack, forma, repo, src):
    """Арбитраж 132 А1: функциональная запись цвета, разорванная
    переносами строк, — построчный скан её не видел; класс судит весь
    текст файла, строка = начало совпадения."""
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nbackground: rgb(\n  255,\n  0,\n  0\n);\n')


def mut_literal_razmera_nuli(pack, forma, repo, src):
    """Арбитраж 132 А2: размер 16px с ведущими нулями (16 цифр) — маска
    дайджеста по одной длине стирала число; маска с требованием буквы
    a–f число из цифр не стирает."""
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\npadding: 0000000000000016px;\n')


def mut_literal_cveta_funkc_nuli(pack, forma, repo, src):
    """Арбитраж 132 А3: rgb() с валидными десятичными аргументами из
    ведущих нулей — маска по длине стирала аргументы-числа; аргумент из
    цифр — не дайджест."""
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nbackground: rgb(0000000000000255, 0000000000000000,'
                ' 0000000000000000);\n')


def mut_kollizija_zamenjaet(pack, forma, repo, src):
    """Арбитраж 132 Б1: манифест zamenjaet по ТОМУ ЖЕ относительному пути
    в репо продукта с кадром, которого нет в новой пачке, — чтение
    первого корня (харнесс) скрывало неполную замену; суд — по каждому
    файлу в каждом корне."""
    d = repo / FIKT
    d.mkdir(parents=True, exist_ok=True)
    staryj = json.loads(
        (H_ROOT / FIKT / 'kadry_starogo.json').read_text(encoding='utf-8'))
    staryj['kadry'][0]['id'] = 'Old screen only'
    (d / 'kadry_starogo.json').write_text(
        json.dumps(staryj, ensure_ascii=False, indent=1), encoding='utf-8')
    (d / 'ekran.json').write_text(
        json.dumps({'ekran': forma['ekran'], 'kadry': 'kadry_starogo.json',
                    'fiktura': False}, ensure_ascii=False), encoding='utf-8')


def mut_kollizija_ne_trogaet(pack, forma, repo, src):
    """Арбитраж 132 Б2: чужая пачка по ПУТИ ne_trogaet в репо продукта с
    кадрами судимой пачки — суд читал первый корень (харнесс) и чужих
    пикселей не видел; пересечение пусто с КАЖДЫМ найденным."""
    d = repo / FIKT / 'pachta_chuzhogo'
    d.mkdir(parents=True, exist_ok=True)
    (d / 'kadry.json').write_text(
        json.dumps(src['kadry_manifest'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (d / 'ekran.json').write_text(
        json.dumps({'ekran': 'other-screen', 'kadry': 'kadry.json',
                    'fiktura': False}, ensure_ascii=False), encoding='utf-8')

def mut_literal_razmera_maska_edinicy(pack, forma, repo, src):
    """Блокер 1 (вердикт adv 132 v1): размерный литерал «16 цифр +
    единица из букв a–f» (fa) — обособленная словоформа целиком
    hex-совместима; маска дайджеста обязана НЕ вставать на класс «число +
    буквенная единица 1–4 букв», какие бы буквы единица ни несла."""
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\npadding: 0000000000000001fa;\n')


def mut_sverka_poddelnyj_stdout(pack, forma, repo, src):
    """Блокер 2 (вердикт adv 132 v1): scripts/sverka_maketa.py.fake —
    константная реплика stdout раннера 123 (не раннер, сверку не делает);
    проходит подстроку sverka_maketa.py и исполнение с тем же stdout —
    ловится только точным требованием пути/argv раннера 123."""
    replica = [l for l in src['kejsy']['chestnyj-ekran']['stdout']
               if l.startswith('KADR\t')]
    telo = ''.join('print(%r)\n' % l for l in replica)
    (repo / 'scripts').mkdir(parents=True, exist_ok=True)
    (repo / 'scripts/sverka_maketa.py.fake').write_text(
        '# подделка: константная реплика stdout раннера 123 (не раннер)\n'
        + telo, encoding='utf-8')
    forma['priemka']['sverka'] = (
        'python3 scripts/sverka_maketa.py.fake --manifest no')
    zapis(pack, forma)

def mut_sverka_podmena_imenem(pack, forma, repo, src):
    """Блокер 1 (вердикт adv-132 круг 2): podmena/scripts/sverka_maketa.py —
    не раннер 123, печатает константные строки KADR честного прогона;
    суффикс имени /scripts/sverka_maketa.py и полный argv CLI 123 совпадают,
    stdout дословно равен сверке-образцу — проходит форму/argv/stdout,
    ловится только идентичностью файла раннеру 123 (sha256 == эталону
    --harness/scripts/sverka_maketa.py)."""
    replica = [l for l in src['kejsy']['chestnyj-ekran']['stdout']
               if l.startswith('KADR\t')]
    telo = ''.join('print(%r)\n' % l for l in replica)
    (repo / 'podmena/scripts').mkdir(parents=True, exist_ok=True)
    (repo / 'podmena/scripts/sverka_maketa.py').write_text(
        '# подмена: константная реплика stdout раннера 123 (не раннер)\n'
        + telo, encoding='utf-8')
    forma['priemka']['sverka'] = (
        'python3 podmena/scripts/sverka_maketa.py'
        ' --manifest no --kadry no --repo no')
    zapis(pack, forma)

def mut_sverka_chuzhoj_manifest(pack, forma, repo, src):
    """Вход adv-132 круг 3 дословно: копия pack/kadry.json с правкой
    _comment, тот же честный раннер и те же KADR-строки."""
    podmena = repo / 'podmena/kadry.json'
    podmena.parent.mkdir(parents=True)
    manifest = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    manifest['_comment'] = 'podmena: not the pack manifest'
    podmena.write_text(json.dumps(manifest, ensure_ascii=False, indent=1),
                       encoding='utf-8')
    forma['priemka']['sverka'] = (
        'python3 .harness123/scripts/sverka_maketa.py'
        ' --manifest podmena/kadry.json --kadry mobile/maestro-out-demo --repo .')
    zapis(pack, forma)


def mut_sverka_chuzhie_kadry(pack, forma, repo, src):
    """Арбитраж замер 2: e2e создаёт свежие кадры и копию в иной каталог;
    сверка чужих кадров отвечает тем же stdout, что сверка пачки."""
    e2e = repo / 'mobile/e2e.sh'
    with e2e.open('a', encoding='utf-8') as script:
        script.write('\nmkdir -p other-kadry\n'
                     'cp -a mobile/maestro-out-demo/. other-kadry/\n')
    forma['priemka']['sverka'] = (
        'python3 .harness123/scripts/sverka_maketa.py'
        ' --manifest .harness123/kadry.json --kadry other-kadry --repo .')
    zapis(pack, forma)


def mut_sverka_chuzhoj_repo(pack, forma, repo, src):
    """Другой realpath repo при том же доступном макете и том же stdout."""
    other = repo / 'other-repo'
    other.mkdir()
    (other / 'docs').symlink_to(repo / 'docs', target_is_directory=True)
    forma['priemka']['sverka'] = (
        'python3 .harness123/scripts/sverka_maketa.py'
        ' --manifest .harness123/kadry.json'
        ' --kadry mobile/maestro-out-demo --repo other-repo')
    zapis(pack, forma)


def mut_prokhodimost_chestnyj(pack, forma, repo, src):
    """Честный НОВЫЙ экран (shablon 2): блок проходимости полон, геометрия
    честная, демо отделено, проход Maestro исполнен — rc 0 (контроль v2)."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)


def mut_prokhodimost_otsvtstvuet(pack, forma, repo, src):
    """НОВЫЙ экран (shablon 2, priemka с третьей командой) БЕЗ блока
    проходимости: отказ с именем места и выходом (правило 7 AGENTS) —
    не молчаливое принятие старой формой. Грамматика допускает
    промежуточный состав v1+{shablon} (докстринг эталона) — мутация
    снимает ОБА блока, чтобы отказала именованная ветвь, а не глухой
    SHABLON_NEVEREN; команда прохода честная (цель-флоу существует,
    артефакты репо положены) — клетка изолирует СВОЮ ветвь. Правка
    арбитража v2: база батареи сама v2 — блоки снимаются с честной
    базы."""
    v2_baza(forma, src, repo)
    del forma['prokhodimost']
    del forma['vtoroj_profil']
    zapis(pack, forma)


def mut_pressable_bez_obrabotnika(pack, forma, repo, src):
    """(а) pressable объявлен действием, но наблюдаемое изменение не названо
    — обработчика нет (на 118: «Dokument öffnen»/«Kopie herunterladen»)."""
    v2_baza(forma, src, repo)
    del forma['prokhodimost']['pressable'][0]['izmenenie']
    zapis(pack, forma)


def mut_neaktivna_bez_kadra(pack, forma, repo, src):
    """(а) неактивная цель без ссылки на кадр: disabled-вид не показан."""
    v2_baza(forma, src, repo)
    del forma['prokhodimost']['pressable'][1]['kadry']
    zapis(pack, forma)


def mut_cel_menshe_44(pack, forma, repo, src):
    """(б) цель касания ниже нормы: на 118 «Demo: nächster Zustand» — 18pt
    у нижнего края, на iPhone не нажимается."""
    v2_baza(forma, src, repo)
    forma['prokhodimost']['demo'][0]['vysota'] = 18
    zapis(pack, forma)


def mut_cel_v_safe_zone(pack, forma, repo, src):
    """(б) цель касания в safe-area: нижний край заходит в полосу
    home-indicator (кнопка не нажимается пальцем на живом телефоне)."""
    v2_baza(forma, src, repo)
    forma['prokhodimost']['demo'][0]['y'] = 790
    zapis(pack, forma)


def mut_demo_bez_metki(pack, forma, repo, src):
    """(в) демо-переключатель в списке demo без метки demo:true —
    притворяется продуктом («Demo: nächster Zustand» на 118)."""
    v2_baza(forma, src, repo)
    forma['prokhodimost']['demo'][0]['demo'] = False
    zapis(pack, forma)


def mut_demo_v_sostave(pack, forma, repo, src):
    """(в) продуктовый pressable помечен demo:true — демо в составе
    продукта, отделение не заявлено списком."""
    v2_baza(forma, src, repo)
    forma['prokhodimost']['pressable'][0]['demo'] = True
    zapis(pack, forma)


def mut_demo_bez_otdelenija(pack, forma, repo, src):
    """(в) демо-переключатель отмечен demo:true, но визуального отделения
    (отдельный контейнер/подпись) не заявлено."""
    v2_baza(forma, src, repo)
    del forma['prokhodimost']['demo'][0]['otdelenie']
    zapis(pack, forma)


def mut_nazhatie_bez_izmenenija(pack, forma, repo, src):
    """(г) нажатие без наблюдаемого изменения: манифест честен, но проход
    Maestro не видит изменения после нажатия — rc команды отличен от 0."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    (repo / 'mobile/prokhod.sh').write_text(
        '#!/usr/bin/env bash\n# replay: нажатие cta-demo — изменения нет\n'
        'exit 1\n', encoding='utf-8')

def mut_profil_otsvtstvuet(pack, forma, repo, src):
    """НОВЫЙ экран (shablon 2) с блоком проходимости, но БЕЗ блока
    второго профиля: отказ с именем места и выходом (правило 7 AGENTS).
    Команда прохода честная — клетка изолирует СВОЮ ветвь. Правка
    арбитража v2: база батареи сама v2 — мутация снимает блок с честной
    базы."""
    v2_baza(forma, src, repo)
    del forma['vtoroj_profil']
    zapis(pack, forma)


def mut_profil_nizhe_minimuma(pack, forma, repo, src):
    """Профиль ниже класса iPhone 15/16: 390×844 — размер Android-
    эмулятора, на котором дефекты #127 невидимы (слово владельца)."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['shirina'] = 390
    forma['vtoroj_profil']['vysota'] = 844
    zapis(pack, forma)


def mut_profil_bez_insetov(pack, forma, repo, src):
    """Профиль без инсетов: vyrez 24 (один статус-бар, без выреза),
    home 0 (кнопочная навигация) — safe-area не моделируется."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['vyrez'] = 24
    forma['vtoroj_profil']['home'] = 0
    zapis(pack, forma)


def mut_nalozenie_sloev(pack, forma, repo, src):
    """Наложение слоёв: шапка TabShell «Profil bearbeiten» поверх шапки
    StartScreen — дубль заголовка с #127 (два слоя, пересечение bbox)."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['elementy'].append({
        'id': 'shapka-start-dubl', 'tip': 'shapka',
        'x': 0, 'y': 59, 'shirina': 393, 'vysota': 48})
    zapis(pack, forma)


def mut_zalezaet_pod_verhnij_inset(pack, forma, repo, src):
    """Залезание под верхний inset: wordmark под статус-баром/вырезом
    (на #127 iPhone показал wordmark в зоне выреза)."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['elementy'][2]['y'] = 30
    zapis(pack, forma)


def mut_zalezaet_pod_nizhij_inset(pack, forma, repo, src):
    """Залезание под нижний inset: нижний край иконки композера в полосе
    home-indicator (не нажимается пальцем на живом телефоне)."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['elementy'][5]['y'] = 790
    zapis(pack, forma)


def mut_pustaja_ikonka(pack, forma, repo, src):
    """Пустая иконка: контрол композера без глифа и без доступного
    имени (на #127 пустые иконки композера)."""
    v2_baza(forma, src, repo)
    del forma['vtoroj_profil']['elementy'][4]['glif']
    zapis(pack, forma)


def mut_golyj_komponent(pack, forma, repo, src):
    """Голый компонент без оболочки: сверка по маршруту без TabShell не
    принимается (оболочка собранного пути не заявлена)."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['obolochka'] = ''
    zapis(pack, forma)


def mut_odna_tema(pack, forma, repo, src):
    """Одна тема из двух: манифест профиля покрывает только dark —
    светлую тему на втором профиле не сверяют."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    m = json.loads((pack / forma['vtoroj_profil']['kadry']).read_text(
        encoding='utf-8'))
    m['kadry'] = [k for k in m['kadry'] if k['tema'] == 'dark']
    (pack / forma['vtoroj_profil']['kadry']).write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_profil_kadr_nizhe_poroga(pack, forma, repo, src):
    """Кадр профиля ниже порога: элемент стёрт из тёмного кадра
    СОБРАННОГО пути — раннер 123 обязан судить и второй набор
    (фиктивная сверка профиля невозможна; привязка стаба s38, Н-39)."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    f = repo / 'mobile/e2e-nositeli' / 'dark' / (
        src['profil_kadry']['kadry'][0]['snimok'] + '.png')
    blob = derive_bez_elementa(f.read_bytes(), src['bez_elementa']['polosa_pt'])
    f.write_bytes(blob)

def _v1_forma(forma, ekran):
    """v1-форма (17 полей, две команды приёмки) с названным id — С-1
    арбитража 132 v2: база батареи v2, мутации исторических входов
    снимают маркер и блоки с честной базы."""
    forma['ekran'] = ekran
    for k in ('shablon', 'prokhodimost', 'vtoroj_profil'):
        del forma[k]
    del forma['priemka']['prokhod']


def mut_novyj_ekran_bez_shablona(pack, forma, repo, src):
    """Блокер 1 вердикта критика 1/2 (атака new-unmarked/fresh132): свежая
    пачка с новым ekran ОПУСКАЕТ shablon/prokhodimost/vtoroj_profil и
    выдаёт себя за старый экран. С-1 арбитража 132 v2: старость —
    ПОДЛИННАЯ идентичность (id + пины макетов замороженного манифеста,
    отображение эталона), не самодекларация id; id вне отображения без
    маркера — SHABLON_OTSVTSTVUET rc 1."""
    v2_baza(forma, src, repo)
    _v1_forma(forma, 'demo-vkhod')
    zapis(pack, forma)


def mut_istoricheskij_id_chuzhie_makety(pack, forma, repo, src):
    """С-1 РЕШЕНИЯ АРБИТРА (обход (а) — повтор блокера 1 критиком 2/2 и
    самим арбитром): НОВАЯ пачка под ИСТОРИЧЕСКИМ id first-run-ekran с
    ЧУЖИМИ макетами (пины Splash/Splash-Hell батареи 123) и без блоков
    v2 — id в отображении, идентичности нет: SHABLON_OTSVTSTVUET
    называет id и чужие пины. Ровно прежняя v1-база правки 1/2 — тем и
    красна (зелёный контроль старого — клетка staryj-ekran-bez-bloka,
    подлинная пачка сестры 135)."""
    v2_baza(forma, src, repo)
    _v1_forma(forma, 'first-run-ekran')
    zapis(pack, forma)


def mut_prokhod_pustoj(pack, forma, repo, src):
    """Блокер 2 (атака empty-maestro): проход-заглушка — no-op команда
    вместо прохода Maestro по pressable; цель-флоу .yaml команда не
    несёт — PROKHOD_NE_MAESTRO rc 1 (rc оболочки не доказательство)."""
    v2_baza(forma, src, repo)
    forma['priemka']['prokhod'] = 'true'
    zapis(pack, forma)


def mut_prokhod_bez_pressable(pack, forma, repo, src):
    """Блокер 2: флоу прохода не нажимает демо-переключатель — команда
    несёт цель-флоу, но тот не ссылается на каждый pressable перечня —
    PROKHOD_BEZ_PRESSABLE rc 1."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    p = repo / 'mobile/.maestro/prokhod-demo-vkhod.yaml'
    stroki = [l for l in p.read_text(encoding='utf-8').splitlines()
              if 'demo-sostojanie' not in l]
    p.write_text('\n'.join(stroki) + '\n', encoding='utf-8')


def mut_poddelnaja_obolochka(pack, forma, repo, src):
    """Блокер 3 (атака fake-assembled-shell): непустое ЛОЖНОЕ слово
    obolochka='fake-shell' при честных PNG обоих наборов — оболочка не
    наблюдается в маршруте входа собранного пути: MARSHRUT_BEZ_OBOLOCHKI."""
    v2_baza(forma, src, repo)
    forma['vtoroj_profil']['obolochka'] = 'fake-shell'
    zapis(pack, forma)


def mut_marshrut_bez_snimka(pack, forma, repo, src):
    """Блокер 3 (атака claimed-bbox, вариант голого маршрута): флоу
    собранного пути не снимает кадр профиля — связь исполненного пути с
    каждым кадром не наблюдается: MARSHRUT_BEZ_SNIMKA rc 1."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    p = repo / 'mobile/.maestro/demo-vkhod-tabshell.yaml'
    stroki = [l for l in p.read_text(encoding='utf-8').splitlines()
              if 'takeScreenshot' not in l]
    p.write_text('\n'.join(stroki) + '\n', encoding='utf-8')

def mut_prokhod_pressable_v_kommentarii(pack, forma, repo, src):
    """С-2 РЕШЕНИЯ АРБИТРА (обход б-2 + вопрос 3: buttons-only-in-comment/
    buttons-in-header-name/buttons-inline-comment): все id pressable —
    ТОЛЬКО в не-исполняемом тексте флоу прохода (строка name: шапки ДО
    «---» и YAML-комментарий в теле); исполняемый текст — launchApp.
    Комментарий и шапка — форма, не исполнение: PROKHOD_BEZ_PRESSABLE
    на каждый id перечня (cta-demo/ssylka-pomosh/demo-sostojanie)."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    (repo / 'mobile/.maestro/prokhod-demo-vkhod.yaml').write_text(
        'appId: com.complior.demo\n'
        'name: cta-demo ssylka-pomosh demo-sostojanie\n'
        '---\n'
        '- launchApp\n'
        '# nazhat: cta-demo ssylka-pomosh demo-sostojanie\n',
        encoding='utf-8')


def mut_marshrut_obolochka_v_kommentarii(pack, forma, repo, src):
    """С-2 РЕШЕНИЯ АРБИТРА (обход в + вопрос 3: shell-only-in-comment/
    shell-in-header-name/shot-only-in-comment): оболочка tabshell и снимок
    профиля — ТОЛЬКО в не-исполняемом тексте маршрута (name: шапки,
    «# tabshell», закомментированный «# - takeScreenshot: …»);
    исполняемый текст — launchApp. MARSHRUT_BEZ_OBOLOCHKI +
    MARSHRUT_BEZ_SNIMKA vkhod-demo-tabshell."""
    v2_baza(forma, src, repo)
    zapis(pack, forma)
    (repo / 'mobile/.maestro/demo-vkhod-tabshell.yaml').write_text(
        'appId: com.complior.demo\n'
        'name: tabshell\n'
        '---\n'
        '- launchApp\n'
        '# tabshell\n'
        '# - takeScreenshot: vkhod-demo-tabshell\n',
        encoding='utf-8')

MUTACII = {
    'chestnyj-ekran': None,
    'staryj-ekran-bez-bloka': None,
    'literal-cveta': mut_literal_cveta,
    'literal-razmera': mut_literal_razmera,
    'kadr-nizhe-poroga': mut_kadr_nizhe_poroga,
    'kadr-otsutstvuet': mut_kadr_otsutstvuet,
    'chuzhoj-kadr': mut_chuzhoj_kadr,
    'ne-tselikom': mut_ne_tselikom,
    'kljuch-bez-kataloga': mut_kljuch_bez_kataloga,
    'operacija-bez-speka': mut_operacija_bez_speka,
    'scenarij-bez-snimka': mut_scenarij_bez_snimka,
    'samodelnaja-sverka': mut_samodelnaja_sverka,
    'sostojanie-nevernoe': mut_sostojanie_nevernoe,
    'zony-s-globom': mut_zony_s_globom,
    'zony-rashodjatsja': mut_zony_rashodjatsja,
    'bez-razdela': mut_bez_razdela,
    'paket-bez-manifesta': mut_paket_bez_manifesta,
    'priemka-lozhnaja': mut_priemka_lozhnaja,
    'e2e-ne-proshla': mut_e2e_ne_proshla,
    'sverka-lozhnaya': mut_sverka_lozhnaya,
    'zamenjaet-pustoj': mut_zamenjaet_pustoj,
    'ne-trogaet-pustoj': mut_ne_trogaet_pustoj,
    'literal-cveta-funkc': mut_literal_cveta_funkc,
    'literal-razmera-rem': mut_literal_razmera_rem,
    'kontrakt-slishkom-dlinnyj': mut_kontrakt_slishkom_dlinnyj,
    'literal-cveta-hwb': mut_literal_cveta_hwb,
    'literal-razmera-protsent': mut_literal_razmera_protsent,
    'literal-razmera-ch': mut_literal_razmera_ch,
    'kadry-ustarevshie': mut_kadry_ustarevshie,
    'zhivaja-pachta-v-repo': mut_zhivaja_pachta_v_repo,
    'kontrakt-shirokij': mut_kontrakt_shirokij,
    'literal-cveta-mnogostrochnyj': mut_literal_cveta_mnogostrochnyj,
    'literal-razmera-nuli': mut_literal_razmera_nuli,
    'literal-cveta-funkc-nuli': mut_literal_cveta_funkc_nuli,
    'kollizija-zamenjaet': mut_kollizija_zamenjaet,
    'kollizija-ne-trogaet': mut_kollizija_ne_trogaet,
    'literal-razmera-maska-edinicy': mut_literal_razmera_maska_edinicy,
    'sverka-poddelnyj-stdout': mut_sverka_poddelnyj_stdout,
    'sverka-podmena-imenem': mut_sverka_podmena_imenem,
    'sverka-chuzhoj-manifest': mut_sverka_chuzhoj_manifest,
    'sverka-chuzhie-kadry': mut_sverka_chuzhie_kadry,
    'sverka-chuzhoj-repo': mut_sverka_chuzhoj_repo,
    'prokhodimost-chestnyj': mut_prokhodimost_chestnyj,
    'prokhodimost-otsvtstvuet': mut_prokhodimost_otsvtstvuet,
    'pressable-bez-obrabotnika': mut_pressable_bez_obrabotnika,
    'neaktivna-bez-kadra': mut_neaktivna_bez_kadra,
    'cel-menshe-44': mut_cel_menshe_44,
    'cel-v-safe-zone': mut_cel_v_safe_zone,
    'demo-bez-metki': mut_demo_bez_metki,
    'demo-v-sostave': mut_demo_v_sostave,
    'demo-bez-otdelenija': mut_demo_bez_otdelenija,
    'nazhatie-bez-izmenenija': mut_nazhatie_bez_izmenenija,
    'profil-otsvtstvuet': mut_profil_otsvtstvuet,
    'profil-nizhe-minimuma': mut_profil_nizhe_minimuma,
    'profil-bez-insetov': mut_profil_bez_insetov,
    'nalozenie-sloev': mut_nalozenie_sloev,
    'zalezaet-pod-verhnij-inset': mut_zalezaet_pod_verhnij_inset,
    'zalezaet-pod-nizhij-inset': mut_zalezaet_pod_nizhij_inset,
    'pustaja-ikonka': mut_pustaja_ikonka,
    'golyj-komponent': mut_golyj_komponent,
    'odna-tema': mut_odna_tema,
    'profil-kadr-nizhe-poroga': mut_profil_kadr_nizhe_poroga,
    'novyj-ekran-bez-shablona': mut_novyj_ekran_bez_shablona,
    'istoricheskij-id-chuzhie-makety': mut_istoricheskij_id_chuzhie_makety,
    'prokhod-pustoj': mut_prokhod_pustoj,
    'prokhod-bez-pressable': mut_prokhod_bez_pressable,
    'prokhod-pressable-v-kommentarii': mut_prokhod_pressable_v_kommentarii,
    'poddelnaja-obolochka': mut_poddelnaja_obolochka,
    'marshrut-bez-snimka': mut_marshrut_bez_snimka,
    'marshrut-obolochka-v-kommentarii': mut_marshrut_obolochka_v_kommentarii,
}


# --- суд входа ---------------------------------------------------------------

def run_subject(subject, name, src):
    if name == 'staryj-ekran-bez-bloka':
        # ЗЕЛЁНЫЙ контроль старого экрана (С-1 арбитража 132 v2) — судится
        # ПОДЛИННАЯ замороженная пачка сестры 135, не постройка 132:
        # её манифест и есть источник пинов отображения эталона.
        return sud_staryj_ekrana()
    tmp = Path(tempfile.mkdtemp(prefix='ekran132-'))
    try:
        pack, forma = build_pack(src, tmp)
        repo = build_repo(src, tmp, pack)
        if MUTACII[name] is not None:
            MUTACII[name](pack, forma, repo, src)
        p = subprocess.run(
            [sys.executable, str(subject), '--pack', str(pack),
             '--repo', str(repo), '--harness', str(H_ROOT)],
            capture_output=True, text=True)
        return p.returncode, p.stdout, p.stderr
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def stroka_shoditsja(exp_line, act_line, dopusk):
    """Строка stdout сходна: KADR-числа — в допуске, остальное — точно."""
    e, a = exp_line.split('\t'), act_line.split('\t')
    if len(e) != len(a):
        return False
    for i, (x, y) in enumerate(zip(e, a)):
        if i == 2 and x and y:
            try:
                if abs(float(x) - float(y)) <= dopusk:
                    continue
            except ValueError:
                pass
        if x != y:
            return False
    return True


def judge(name, src, rc, out, err):
    problemy = []
    exp = src['kejsy'][name]
    prichiny = sorted(l for l in err.splitlines() if l.startswith('PRICHINA\t'))
    if rc != exp['rc']:
        problemy.append('rc=%d, ожидался %d' % (rc, exp['rc']))
    if prichiny != sorted(exp['prichiny']):
        problemy.append('prichiny=%r, ожидались %r' % (prichiny, sorted(exp['prichiny'])))
    exp_out, act_out = exp.get('stdout', []), out.splitlines()
    if len(exp_out) != len(act_out) or not all(
            stroka_shoditsja(x, y, src['dopusk_score'])
            for x, y in zip(exp_out, act_out)):
        problemy.append('stdout=%r, ожидался %r' % (act_out, exp_out))
    return problemy


def snapshot(src):
    """Фактические rc/вывод эталона по каждому входу (инструмент замера)."""
    data = {}
    for name in src['kejsy']:
        rc, out, err = run_subject(MODEL, name, src)
        data[name] = {'rc': rc, 'stdout': out.splitlines(),
                      'prichiny': [l for l in err.splitlines()
                                   if l.startswith('PRICHINA\t')]}
    print(json.dumps(data, ensure_ascii=False, indent=1))
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    ap.add_argument('--snapshot', action='store_true')
    a = ap.parse_args()
    src = load_source()
    if a.snapshot:
        return snapshot(src)
    if not RUNNER123.is_file():
        print('SVERKA_123_ABSENT: раннер 123 не в дереве (инфраструктура)', file=sys.stderr)
        return 2
    matrica = a.stabs or a.matrix
    subject = MODEL if (a.model or matrica) else SUBJECT
    if not a.model and not matrica and not SUBJECT.is_file():
        print('SHABLON_ABSENT')
        for name in src['kejsy']:
            print('CASE %s KRASNO (SHABLON_ABSENT)' % name)
        return 1
    kontrol_ok, svjazi = True, 0
    for name in src['kejsy']:
        rc, out, err = run_subject(subject, name, src)
        problemy = judge(name, src, rc, out, err)
        if problemy:
            kontrol_ok = False
            print('CASE %s KRASNO: %s' % (name, '; '.join(problemy)))
        else:
            print('CASE %s ok' % name)
    if not matrica:
        return 0 if kontrol_ok else 1
    # --stabs/--matrix: каждый обманный стаб красен на каждом своём входе
    zhivye = 0
    for stub, vhody in sorted(src['stab_vhod'].items()):
        for v in vhody:
            svjazi += 1
            rc, out, err = run_subject(STUBS / stub, v, src)
            if judge(v, src, rc, out, err):
                print('STAB %s %s KRASEN' % (stub, v))
            else:
                zhivye += 1
                print('STAB %s %s PROSHYOL' % (stub, v))
    if zhivye:
        print('STAB_ZHIV: %d' % zhivye)
        return 1
    if not kontrol_ok:
        return 1
    print('SVJAZI %d' % svjazi)
    return 0


if __name__ == '__main__':
    sys.exit(main())
