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
    for tema in ('dark', 'light'):
        d = repo / 'mobile/e2e-nositeli' / tema
        d.mkdir(parents=True)
        shutil.copyfile(
            HERE / ('nositeli/kadry/r1423-%s-vkhod-117-splash.png' % tema),
            d / (src['snimok'] + '.png'))
    (repo / 'mobile/maestro-out-demo').mkdir(parents=True)
    # пин механизма 123 внутри репо (как в продукте): честная priemka.sverka
    # запускает раннер из .harness123; сверка-образец и приёмка обязаны
    # дать дословно одинаковый вывод
    pin123 = repo / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pack / 'kadry.json', pin123 / 'kadry.json')
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
    (pack / 'kontrakt.md').write_text(src['kontrakt_tekst'], encoding='utf-8')
    b = pack / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['batareja_tekst'], encoding='utf-8')
    return pack, forma


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
    --manifest" — команды rc 0 без работы; кадры после e2e отсутствуют."""
    forma['priemka'] = {'e2e': 'true',
                        'sverka': 'echo sverka_maketa.py --manifest'}
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
MUTACII = {
    'chestnyj-ekran': None,
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
}


# --- суд входа ---------------------------------------------------------------

def run_subject(subject, name, src):
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
