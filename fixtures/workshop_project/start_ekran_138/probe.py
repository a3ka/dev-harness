#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 138 (§ПРОВОДКА): судит пачку start-ekran
# валидатором 132 и проверкой происхождения из пачки; Н-39: стабы привязаны
# к ветвям обоих субъектов по stab_vhod source.json, не по тексту контракта.
"""Батарея 138 (start-ekran): экран Start по шаблону 132.

Предмет: экранная пачка start-ekran (ekran.json + контракт + манифест
восьми кадров + батарея) судится валидатором шаблона 132 И проверкой
происхождения кадров пачки: кадры F04.01/F04.07/F04.08/F04.13 (4 состояния
idle/composer/decision/resume) × dark/light, PNG Mobility Slice пакета 3,
ключи копии — каталог BrokerOS_UI_Copy_DE.json verbatim; приёмка —
android-e2e rc 0 со СВЕЖИМИ кадрами Maestro-раскладки по production пути
допуска 118 (First-Run → demo → Erstinformation → continue → Start),
сверка раннером 123, appId/конфиг/селекторы/состав вкладок и байтовое
неравенство кадров макетам. Честные носители кадров перекодированы без
изменения пикселей (score 1.000).

Режимы:
  (без флага)  субъект scripts/ekran_shablon.py; нет файла → rc 1 SHABLON_ABSENT
  --model      эталон 132 из дерева на входах формы; текст проверки
               из source.json на входах происхождения (второй субъект)
  --stabs      контроль обеими моделями всех входов + каждый обманный стаб
               отвергнут на КАЖДОМ входе своей записи stab_vhod source.json
  --snapshot   фактические rc/вывод двух моделей по каждому входу JSON-ом
               (инструмент замера, числа из прогона, не из головы)

Вывод: строка на вход `CASE <вход> ok|KRASNO`; --stabs добавляет строку на
связь `STAB <стаб> <вход> KRASEN`. rc: 0 — все входы зелёные (для --stabs:
контроль зелёный и все стабы пойманы); 1 — красный вход либо STAB_ZHIV;
2 — ORACLE_TAMPERED / SVERKA_123_ABSENT / нечем проверить.

Оракул — source.json (единый источник): kejsy (rc, prichiny построчно,
stdout построчно, допуск dopusk_score на числа KADR), stab_vhod (привязка
стабов к входам по коду ветвей, Н-39), nositeli (sha256 макетов продукта
и перекодированных честных кадров). Ожидания снимаются в память ДО вызова
субъекта (правило 8); диск субъекта как истина не читается.
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
MODEL = H_ROOT / 'fixtures' / 'workshop_project' / 'ekran_shablon_132' / \
    'model' / 'ekran_shablon.py'
STUBS = HERE / 'stubs'
M1 = 'docs/ux/03_Mobility_Slice1/screens'


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


# --- PNG собственными средствами проверяющего (приём батареи 123) -----------

def png_decode(blob):
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
    assert bd == 8 and ct == 6, 'ожидался RGBA'
    raw = zlib.decompress(bytes(idat))
    ch, stride = 4, w * 4
    rows, prev = [], bytearray(stride)
    i = 0
    for y in range(h):
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
    return w, h, rows


def png_encode(w, h, rows):
    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d +
                struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF))

    raw = b''.join(b'\x00' + r for r in rows)
    return (b'\x89PNG\r\n\x1a\n' +
            chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) +
            chunk(b'IDAT', zlib.compress(raw, 1)) + chunk(b'IEND', b''))


def derive_bez_elementa(blob, polosa_pt):
    """Полоса polosa_pt [x0,y0,x1,y1] pt залита фоном (мода цвета по сетке
    полосы) — свидетель ниже-порога (приём derive батарей 123/132)."""
    w, h, rows = png_decode(blob)
    x0, y0, x1, y1 = polosa_pt
    from collections import Counter
    c = Counter()
    for y in range(y0, min(y1, h), 5):
        for x in range(x0, min(x1, w), 5):
            c[rows[y][x * 4:x * 4 + 4]] += 1
    fon = c.most_common(1)[0][0]
    out = []
    for y in range(h):
        r = bytearray(rows[y])
        if y0 <= y < y1:
            for x in range(x0, min(x1, w)):
                r[x * 4:x * 4 + 4] = fon
        out.append(bytes(r))
    return png_encode(w, h, out)


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
                print('ORACLE_TAMPERED: stab_vhod %s → нет входа %s'
                      % (imja, v), file=sys.stderr)
                raise SystemExit(2)
    return src


# --- построение входа ---------------------------------------------------------

def slug(kadr_id):
    return kadr_id.split(' ')[0].lower().replace('.', '-')


def build_repo(src, tmp, pack):
    repo = tmp / 'repo'
    ms = repo / M1
    ms.mkdir(parents=True)
    for kadr in src['kadry_manifest']['kadry']:
        nm = kadr['id'].split(' ')[0]
        suf = '-Hell' if kadr['tema'] == 'light' else ''
        shutil.copyfile(HERE / ('nositeli/maket/%s%s.png' % (nm, suf)),
                        ms / (nm + suf + '.png'))
    ds = repo / 'docs/ux/03_Mobility_Slice1/ds'
    ds.mkdir(parents=True)
    (ds / 'tokens.css').write_text(src['tokens_audit'], encoding='utf-8')
    pak = repo / 'mobile/e2e-start'
    pak.mkdir(parents=True)
    (pak / 'katalog_kopii.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (pak / 'spec_api.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    ma = repo / 'mobile/.maestro'
    ma.mkdir(parents=True)
    (ma / 'start-ekran.yaml').write_text(src['flow'], encoding='utf-8')
    (ma / 'config.yaml').write_text(src['maestro_config'], encoding='utf-8')
    (repo / 'mobile/app.json').write_text(src['app_json'], encoding='utf-8')
    # stand-in android-e2e (replay) + носители записи: кадры в Maestro-раскладку
    # кладёт ИСПОЛНЕННАЯ команда priemka.e2e — стартуем с пустым kadry_dir
    (repo / 'mobile/e2e-start/e2e.sh').write_text(
        src['e2e_skript'], encoding='utf-8')
    # файл пачки в продукте + носители селекторов флоя (stand-in кода экрана)
    (repo / 'mobile/e2e-start/batareja').mkdir(parents=True)
    shutil.copyfile(pack / 'batareja/proverka_proiskhozdenija.py',
                    repo / 'mobile/e2e-start/batareja/proverka_proiskhozdenija.py')
    for dest, kljuch in (('mobile/src/features/start', 'testids_tekst'),
                          ('mobile/src/features/onboarding',
                           'testids_onboarding'),
                          ('mobile/src/features/auth', 'testids_auth'),
                          ('mobile/src/app', 'app_start_tekst')):
        d = repo / dest
        d.mkdir(parents=True)
        (d / 'testids.stand-in.tsx').write_text(src[kljuch], encoding='utf-8')
    # соседние живые пачки экранов-предшественников (манифесты чужих кадров):
    # First-Run/F03 (135) и Erstinformation (118) — ne_trogaet судится по ним
    for sosed in ('first-run', 'erstinformation'):
        d = repo / ('mobile/e2e-%s' % sosed)
        d.mkdir(parents=True)
        shutil.copyfile(HERE / ('teksty/sosed_%s_kadry.json' % sosed),
                        d / 'kadry.json')
    for kadr in src['kadry_manifest']['kadry']:
        d = repo / 'mobile/e2e-nositeli' / kadr['tema']
        d.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(
            HERE / ('nositeli/kadry/%s-%s.png' % (kadr['tema'], slug(kadr['id']))),
            d / (kadr['snimok'] + '.png'))
    (repo / 'mobile/maestro-out-start').mkdir(parents=True)
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
        json.dumps(src['kadry_manifest'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (pack / 'kontrakt.md').write_text(src['kontrakt_tekst'], encoding='utf-8')
    b = pack / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['batareja_tekst'], encoding='utf-8')
    (b / 'proverka_proiskhozdenija.py').write_text(
        src['proverka_tekst'], encoding='utf-8')
    return pack, forma


def nositel(repo, tema, snimok):
    return repo / 'mobile/e2e-nositeli' / tema / (snimok + '.png')


# --- мутации входов (код, не проза; ожидания — kejsy source.json) ------------

def mut_literal_cveta(pack, forma, repo, src):
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\n# фон присутствия: #0a0a0a\n')


def mut_kadr_nizhe_poroga(pack, forma, repo, src):
    f = nositel(repo, 'dark', 'start-ekran-f04-01')
    blob = derive_bez_elementa(f.read_bytes(), src['bez_elementa']['polosa_pt'])
    f.write_bytes(blob)


def mut_chuzhoj_kadr(pack, forma, repo, src):
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    sosed = json.loads((repo / 'mobile/e2e-erstinformation/kadry.json')
                       .read_text(encoding='utf-8'))
    chuzhoj = dict(sosed['kadry'][0])
    chuzhoj['snimok'] = 'start-ekran-f04-01'  # изоляция класса: сценарий покрывает
    m['kadry'].append(chuzhoj)
    (pack / 'kadry.json').write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')



def mut_zamenjaet_pustoj(pack, forma, repo, src):
    forma['ekran'] = 'fiktura-tot-zhe-ekran'
    forma['zamenjaet'] = None
    zapis(pack, forma)


def mut_ne_trogaet_pustoj(pack, forma, repo, src):
    forma['ne_trogaet'] = []
    zapis(pack, forma)


def mut_kontrakt_slishkom_dlinnyj(pack, forma, repo, src):
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('\nЗапас страницы за пределами одной.\n' * 20)


def mut_kontrakt_shirokij(pack, forma, repo, src):
    p = pack / 'kontrakt.md'
    with p.open('a', encoding='utf-8') as f:
        f.write('Требование_без_разрыва ' * 300 + '\n')


def mut_kadry_ustarevshie(pack, forma, repo, src):
    zap = subprocess.run(
        ['bash', str(repo / 'mobile/e2e-start/e2e.sh'), 'start-ekran'],
        cwd=str(repo), capture_output=True, text=True)
    if zap.returncode != 0:
        raise RuntimeError('replay e2e: rc=%d %s' % (zap.returncode, zap.stderr))
    zapis(pack, forma)


def mut_e2e_ne_proshla(pack, forma, repo, src):
    forma['priemka']['e2e'] = 'bash mobile/e2e-start/e2e.sh net-takogo'
    zapis(pack, forma)


def mut_zhivaja_pachta_v_repo(pack, forma, repo, src):
    """Живая пачка ТОГО ЖЕ экрана в переданном продукте (--repo): полнота
    замены по живым пачкам в --repo (мера Ж 132)."""
    d = repo / 'fixtures/workshop_project/staryj_start_001'
    d.mkdir(parents=True)
    staryj = src['repo_staryj_ekran']
    (d / 'ekran.json').write_text(
        json.dumps(staryj['ekran'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (d / 'kadry.json').write_text(
        json.dumps(staryj['kadry'], ensure_ascii=False, indent=1),
        encoding='utf-8')


def _zapusti_replay(repo):
    """Stand-in e2e кладёт кадры в Maestro-раскладку (как Maestro-прогон
    пачки); свежесть по построению — файлы создаются ЭТИМ вызовом."""
    zap = subprocess.run(
        ['bash', str(repo / 'mobile/e2e-start/e2e.sh'), 'start-ekran'],
        cwd=str(repo), capture_output=True, text=True)
    if zap.returncode != 0:
        raise RuntimeError('replay e2e: rc=%d %s' % (zap.returncode, zap.stderr))


def mut_proiskhozdenie_chistyj(pack, forma, repo, src):
    """Честный вход проверки происхождения: кадры положены прогоном e2e,
    флоу несёт путь допуска и селекторы состояний."""
    _zapusti_replay(repo)


def mut_proiskhozdenie_byte_kopija(pack, forma, repo, src):
    """Подмена e2e копированием макета: кадр байт-идентичен макету F04.01
    dark — не скриншот."""
    _zapusti_replay(repo)
    maket = repo / M1 / 'F04.01.png'
    shutil.copyfile(maket, nositel(repo, 'dark', 'start-ekran-f04-01'))
    d = repo / 'mobile/maestro-out-start/dark/20261025T120000Z/start-ekran/takeScreenshot'
    shutil.copyfile(maket, d / 'start-ekran-f04-01.png')


def mut_proiskhozdenie_flow_bez_perehoda(pack, forma, repo, src):
    """Флоу-витрина: запуск + четыре кадра подряд, без переходов и
    селекторов состояний."""
    (repo / 'mobile/.maestro/start-ekran.yaml').write_text(
        'appId: com.complior.mobile\nname: start-ekran\n---\n'
        '- launchApp\n'
        '- assertVisible: {id: start_sostojanie_idle}\n'
        '- takeScreenshot: start-ekran-f04-01\n'
        '- takeScreenshot: start-ekran-f04-07\n'
        '- takeScreenshot: start-ekran-f04-08\n'
        '- takeScreenshot: start-ekran-f04-13\n', encoding='utf-8')


def mut_proiskhozdenie_flow_appid_chuzhoj(pack, forma, repo, src):
    """Заголовок флоу адресует чужой пакет (урок 118: demo-пакет ронял
    Maestro «Package … is not installed»)."""
    p = repo / 'mobile/.maestro/start-ekran.yaml'
    tekst = p.read_text(encoding='utf-8').replace(
        'com.complior.mobile', 'com.complior.demo')
    p.write_text(tekst, encoding='utf-8')


def mut_proiskhozdenie_config_bez_iskljuchenija(pack, forma, repo, src):
    """Конфиг каталога Maestro без исключения флоу пачки: общий прогон
    каталога 995 включит экранный флоу (adv-118 B3)."""
    p = repo / 'mobile/.maestro/config.yaml'
    p.write_text('flows:\n  - "*"\n', encoding='utf-8')


def mut_proiskhozdenie_deeplink(pack, forma, repo, src):
    """Экран «поставлен» deep-ссылкой вместо production пути допуска
    (адверсарий 118 B1: прямой URL не вводит второго gate-предиката)."""
    p = repo / 'mobile/.maestro/start-ekran.yaml'
    tekst = p.read_text(encoding='utf-8').replace(
        '- launchApp\n', '- openLink: com.complior.mobile://start\n', 1)
    p.write_text(tekst, encoding='utf-8')


def mut_proiskhozdenie_selektor_bez_ekrana(pack, forma, repo, src):
    """Селектор состояния без носителя: start_sostojanie_composer исчез из
    кода экрана — композер недостижим."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    tekst = p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_composer" />\n', '')
    p.write_text(tekst, encoding='utf-8')


def mut_proiskhozdenie_selektor_ne_kadra(pack, forma, repo, src):
    """Корректный testID существует, но assert чужого состояния не доказывает
    кадр композера."""
    p = repo / 'mobile/.maestro/start-ekran.yaml'
    tekst = p.read_text(encoding='utf-8').replace(
        '- assertVisible: {id: start_sostojanie_composer}\n',
        '- assertVisible: {id: start_sostojanie_idle}\n', 1)
    p.write_text(tekst, encoding='utf-8')


def mut_proiskhozdenie_start_pustoj(pack, forma, repo, src):
    """Production рендерит после continue голый start_tabs без вкладок —
    состав Start не наблюдаем (118: пустой узел — не Start)."""
    p = repo / 'mobile/src/app/testids.stand-in.tsx'
    tekst = p.read_text(encoding='utf-8')
    for vkladka in ('start_tab_start', 'start_tab_vorgaenge',
                    'start_tab_schutz', 'start_tab_post'):
        tekst = tekst.replace('testID="%s"' % vkladka, '')
    p.write_text(tekst, encoding='utf-8')

# --- клетки круга 2 (оба блокера критика закрыты КЛАССАМИ входов) -----------

GOLOVA_FLOWA = 'appId: com.complior.mobile\nname: start-ekran\n---\n'
DOPUSK_SHAGI = (
    '- assertVisible: {id: first-run-continue}',
    '- tapOn: {id: first-run-continue}',
    '- assertVisible: {id: auth-demo-entry}',
    '- tapOn: {id: auth-demo-entry}',
    '- assertVisible: {id: erstinfo_gate_current}',
    '- tapOn: {id: erstinfo_continue_start}',
    '- assertVisible: {id: start_tabs}',
    '- assertVisible: {id: start_tab_start}',
    '- assertVisible: {id: start_tab_vorgaenge}',
    '- assertVisible: {id: start_tab_schutz}',
    '- assertVisible: {id: start_tab_post}',
)
POSLE_DOPUSKA = (
    '- assertVisible: {id: start_sostojanie_idle}',
    '- takeScreenshot: start-ekran-f04-01',
    '- tapOn: {id: start_next_variant}',
    '- assertVisible: {id: start_sostojanie_composer}',
    '- takeScreenshot: start-ekran-f04-07',
    '- tapOn: {id: start_next_variant}',
    '- assertVisible: {id: start_sostojanie_decision}',
    '- takeScreenshot: start-ekran-f04-08',
    '- tapOn: {id: start_next_variant}',
    '- assertVisible: {id: start_sostojanie_resume}',
    '- takeScreenshot: start-ekran-f04-13',
)


def _flow(repo, telo, golova=GOLOVA_FLOWA):
    """Переписать флоу пачки: шапка + строки тела как есть (мутации
    формы flow строят вход целиком, не патчат строки честного флоу)."""
    (repo / 'mobile/.maestro/start-ekran.yaml').write_text(
        golova + ''.join(x + '\n' for x in telo), encoding='utf-8')


def mut_proiskhozdenie_flow_uslovnyj_when_visible(pack, forma, repo, src):
    """ОБХОД критика круга 1 (блокер «форма flow»): 11 шагов допуска
    завёрнуты в runFlow с условием when.visible несуществующего селектора —
    Maestro пропускает ветвь целиком, а плоский парсер считал вложенные
    строки исполненными переходами."""
    _flow(repo, ['- launchApp', '- runFlow:', '    when:',
                 '      visible: critic138_never_visible', '    commands:']
          + ['      ' + x for x in DOPUSK_SHAGI] + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_uslovnyj_when_notvisible(pack, forma, repo, src):
    """Условие-отрицание (when.notVisible): ветвь допуска исполняется лишь
    когда селектора НЕТ — то же значение оси условности."""
    _flow(repo, ['- launchApp', '- runFlow:', '    when:',
                 '      notVisible: start_sostojanie_resume', '    commands:']
          + ['      ' + x for x in DOPUSK_SHAGI] + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_uslovnyj_when_platform(pack, forma, repo, src):
    """Условие не-видимости (platform; тот же класс — true/script): ветвь
    исполняется лишь на части запусков — условный шаг допуска."""
    _flow(repo, ['- launchApp', '- runFlow:', '    when:',
                 '      platform: Android', '    commands:']
          + ['      ' + x for x in DOPUSK_SHAGI] + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_uslovnyj_repeat(pack, forma, repo, src):
    """repeat: путь допуска внутри повторяемого блока — вложенные команды
    исполняются по счётчику, плоский парсер считал их топ-уровнем."""
    _flow(repo, ['- launchApp', '- repeat:', '    times: 2', '    commands:']
          + ['      ' + x for x in DOPUSK_SHAGI] + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_uslovnyj_retry(pack, forma, repo, src):
    """retry inline-картой на шаге допуска: конструкция вне замкнутого
    алфавита пачки; ловится и внутри строки, не только блоком."""
    p = repo / 'mobile/.maestro/start-ekran.yaml'
    tekst = p.read_text(encoding='utf-8').replace(
        '- tapOn: {id: first-run-continue}\n',
        '- tapOn: {id: first-run-continue, retry: {maxAttempts: 3}}\n', 1)
    p.write_text(tekst, encoding='utf-8')


def mut_proiskhozdenie_flow_uslovnyj_runflow_vlozhennyj(
        pack, forma, repo, src):
    """Вложенный БЕЗУСЛОВНЫЙ подпоток (runFlow.commands без when): команды
    отложены в отдельный флоу — исполнение не гарантировано основным
    порядком, плоский парсер считал их переходами."""
    _flow(repo, ['- launchApp', '- runFlow:', '    commands:']
          + ['      ' + x for x in DOPUSK_SHAGI] + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_uslovnyj_runflow_fajl(pack, forma, repo, src):
    """Подпоток отдельным файлом: путь допуска вынесен из флоу пачки
    ссылкой; файл подпотока существует и корректен — основной файл
    формально без допуска."""
    (repo / 'mobile/.maestro/dopusk-podpotok.yaml').write_text(
        ''.join(x + '\n' for x in DOPUSK_SHAGI), encoding='utf-8')
    _flow(repo, ['- launchApp', '- runFlow: dopusk-podpotok.yaml']
          + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_uslovnyj_onflow(pack, forma, repo, src):
    """onFlowComplete — отложенный хук: путь допуска «наблюдается» ПОСЛЕ
    кадров; семантика жизненного цикла невидима плоскому парсеру."""
    tekst = ('appId: com.complior.mobile\nname: start-ekran\n'
             'onFlowComplete:\n'
             + ''.join('  ' + x + '\n' for x in DOPUSK_SHAGI)
             + '---\n- launchApp\n'
             + ''.join(x + '\n' for x in POSLE_DOPUSKA))
    (repo / 'mobile/.maestro/start-ekran.yaml').write_text(
        tekst, encoding='utf-8')


def mut_proiskhozdenie_flow_kommentarij_imitacija(pack, forma, repo, src):
    """Имитация пути допуска комментариями: строки в файле есть, шагов
    нет — парсер обязан считать шаги, а не строки."""
    _flow(repo, ['- launchApp'] + ['# ' + x for x in DOPUSK_SHAGI]
          + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_flow_yaml_ankor(pack, forma, repo, src):
    """YAML-анкор: допуск под якорем вложенной последовательности
    («- &dopusk» и вложенные «- » шаги; алиас «- *dopusk» — тот же класс)
    — конструкции вне замкнутого алфавита, шаги не исполнены."""
    _flow(repo, ['- launchApp', '- &dopusk']
          + ['  ' + x for x in DOPUSK_SHAGI] + list(POSLE_DOPUSKA))


def mut_proiskhozdenie_selektor_chuzhoj_drevo(pack, forma, repo, src):
    """ОБХОД критика круга 1 (блокер «чей экран»): носитель селектора
    состояния удалён из СВОЕГО дерева (features/start) и положен одноимённый
    в ЧУЖОЕ (features/auth) — совпадение в чужом дереве носителем не
    является."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_composer" />\n', ''), encoding='utf-8')
    chuzhoj = repo / 'mobile/src/features/auth/testids.stand-in.tsx'
    chuzhoj.write_text(
        chuzhoj.read_text(encoding='utf-8')
        + '<View testID="start_sostojanie_composer" />\n', encoding='utf-8')


def mut_proiskhozdenie_dopusk_selektor_chuzhoj_drevo(pack, forma, repo, src):
    """Тот же класс на допуск-селекторе: first-run-continue удалён из
    дерева onboarding и положен в start — носитель пути допуска ищется в
    дереве ЕГО экрана."""
    p = repo / 'mobile/src/features/onboarding/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="first-run-continue" />\n', ''), encoding='utf-8')
    svoj = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    svoj.write_text(svoj.read_text(encoding='utf-8')
                    + '<View testID="first-run-continue" />\n',
                    encoding='utf-8')


def mut_proiskhozdenie_selektor_nositel_v_stroke(pack, forma, repo, src):
    """Носитель-строка: testID="..." внутри строкового литерала в СВОЁМ
    дереве — подделка носителя, не JSX-атрибут."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_idle" />\n',
        'const opisanie = \'testID="start_sostojanie_idle"\';\n'),
        encoding='utf-8')


def mut_proiskhozdenie_selektor_nositel_v_kommentarii(pack, forma, repo, src):
    """Носитель-комментарий: testID в хвосте строки после // — не атрибут."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_idle" />\n',
        '<View /> // testID="start_sostojanie_idle"\n'), encoding='utf-8')


def mut_proiskhozdenie_selektor_cbhok_atribut(pack, forma, repo, src):
    """Носитель не в том атрибуте: accessibilityLabel тем же именем —
    testID-носителя нет."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_idle" />\n',
        '<View accessibilityLabel="start_sostojanie_idle" />\n'),
        encoding='utf-8')


def mut_proiskhozdenie_selektor_registr(pack, forma, repo, src):
    """Регистр: testid= — атрибутом React Native не является (testID
    регистрозависим)."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_idle" />\n',
        '<View testid="start_sostojanie_idle" />\n'), encoding='utf-8')


def mut_proiskhozdenie_selektor_dinamicheskij(pack, forma, repo, src):
    """Динамическое имя testID={...}: литерального носителя нет —
    грамматика пачки требует литерал (статическая проверка)."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_idle" />\n',
        'testID={`start_sostojanie_${sostojanie}`}\n'), encoding='utf-8')


def mut_proiskhozdenie_selektor_probely(pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль грамматики носителя: честный JSX с пробелами вокруг
    '=' — носитель есть, ложный отказ недопустим."""
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="start_sostojanie_idle" />\n',
        '<View testID = "start_sostojanie_idle" />\n'), encoding='utf-8')


def mut_proiskhozdenie_selektor_v_oboih(pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль границы: носитель в СВОЁМ дереве есть — дубль в
    чужом дереве НЕ отказ 138 (чужая зона — ревью), владелец найден."""
    chuzhoj = repo / 'mobile/src/features/auth/testids.stand-in.tsx'
    chuzhoj.write_text(
        chuzhoj.read_text(encoding='utf-8')
        + '<View testID="start_sostojanie_composer" />\n', encoding='utf-8')


# --- клетки круга 3 (ось H «форма носителя × место», РЕШЕНИЕ арбитра 138
# и 138-2 «стаб-на-защиту»: каждая красная клетка H краснеет по ОДНОЙ
# защите; форма с двумя причинами — не клетка (арбитраж 138-2, B2);
# достижимость H4/H5 — остаток §НЕ ЗАЩИЩАЕТ, ловец — живой Maestro) ----

NOSITEL_SPRAVA = '<View testID="start_sostojanie_idle" />'


def _udali_idle(repo):
    p = repo / 'mobile/src/features/start/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        NOSITEL_SPRAVA + '\n', ''), encoding='utf-8')


def _nositel_v_fajle(repo, imja, tekst):
    """Своё дерево входа каждой клетке (ось H): носитель idle удалён из
    стенд-ина, один файл добавлен в mobile/src/features/start/."""
    _udali_idle(repo)
    p = repo / 'mobile/src/features/start' / imja
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(tekst, encoding='utf-8')


def mut_proiskhozdenie_nositel_kommentarij_hvost(pack, forma, repo, src):
    """H1 «//» в хвосте: атрибут в хвостовом комментарии — не код."""
    _nositel_v_fajle(repo, 'hvost.tsx',
                     'const a = 1; // ' + NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_kommentarij_stroka(pack, forma, repo, src):
    """H1 «//» своей строкой: вся строка — комментарий."""
    _nositel_v_fajle(repo, 'kommentarij-stroka.tsx',
                     '// ' + NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_kommentarij_blok(pack, forma, repo, src):
    """H1 inline «/* … */»: атрибут внутри блок-комментария той же строки."""
    _nositel_v_fajle(repo, 'kommentarij-blok.tsx',
                     'const a = /* ' + NOSITEL_SPRAVA + ' */ 1;\n')


def mut_proiskhozdenie_nositel_kommentarij_blok_mnogostrochnyj(
        pack, forma, repo, src):
    """H1 многострочный «/* … */» (свидетель критика круга 2): закоммен-
    ченный экран — не носитель; состояние переносимости НЕ судится."""
    _nositel_v_fajle(repo, 'kommentarij-blok-mnogostrochnyj.tsx',
                     '/* unreachable old screen:\n' + NOSITEL_SPRAVA
                     + '\n*/\n')


def mut_proiskhozdenie_nositel_kommentarij_jsdoc(pack, forma, repo, src):
    """H1 JSDoc: атрибут в строке « * …» открытого «/** … */» блока."""
    _nositel_v_fajle(repo, 'kommentarij-jsdoc.tsx',
                     '/**\n * ' + NOSITEL_SPRAVA + '\n */\n')


def mut_proiskhozdenie_nositel_kommentarij_jsx(pack, forma, repo, src):
    """H1 JSX-комментарий {/* … */}: узел не монтируется — не носитель."""
    _nositel_v_fajle(repo, 'kommentarij-jsx.tsx',
                     '{/* ' + NOSITEL_SPRAVA + ' */}\n')


def mut_proiskhozdenie_nositel_kommentarij_jsx_mnogostrochnyj(
        pack, forma, repo, src):
    """H1 JSX-комментарий многострочный: {/*\n…\n*/} внутри выражения."""
    _nositel_v_fajle(repo, 'kommentarij-jsx-mnogostrochnyj.tsx',
                     '{/*\n  ' + NOSITEL_SPRAVA + '\n*/}\n')


def mut_proiskhozdenie_nositel_stroka_odinarnaja(pack, forma, repo, src):
    """H2 одинарная строка, кавычка НЕ вплотную: 'x testID="…" y' —
    строковый литерал, не атрибут (точка круга 1 видела только вплотную)."""
    _nositel_v_fajle(repo, 'stroka-odinarnaja.tsx',
                     "const opisanie = 'x testID=\"start_sostojanie_idle\""
                     " y';\n")


def mut_proiskhozdenie_nositel_stroka_dvojnaja_ekranirovannaja(
        pack, forma, repo, src):
    """H2 двойная строка с экранированной кавычкой (форма 138-2 — ОДНА
    причина): лексер обязан держать строку открытой сквозь \\" до парной
    кавычки; testID внутри строки носителем не является."""
    _nositel_v_fajle(repo, 'stroka-dvojnaja-ekranirovannaja.tsx',
                     'const s = "say \\" testID=\'start_sostojanie_idle\''
                     ' x";\n')


def mut_proiskhozdenie_nositel_stroka_shablon(pack, forma, repo, src):
    """H2 шаблонный литерал многострочный: `…\ntestID="…"\n…` — не код
    до парного бэктика (состояние шаблона многострочно)."""
    _nositel_v_fajle(repo, 'stroka-shablon.tsx',
                     'const opisanie = `star:\n' + NOSITEL_SPRAVA
                     + '\n`;\n')


def mut_proiskhozdenie_nositel_stroka_prodolzhenie(pack, forma, repo, src):
    """H2 (138-2) продолжение строки: \\ непосредственно перед переводом
    строки — строка продолжается на следующей строке, носитель остаётся
    внутри строкового литерала (защита «\\+\\n — продолжение»)."""
    _nositel_v_fajle(repo, 'stroka-prodolzhenie.tsx',
                     "const x = 'prefix \\\n" + NOSITEL_SPRAVA
                     + " suffix';\n")


def mut_proiskhozdenie_nositel_stroka_shablon_ekran_backtick(
        pack, forma, repo, src):
    """H2 (138-2, блокер B1) экранированный бэктик в шаблоне: закрытие
    только на НЕэкранированном бэктике (свидетель критика кр.3; защита
    «\\-экранирование в шаблоне»)."""
    _nositel_v_fajle(repo, 'stroka-shablon-ekran-backtick.tsx',
                     'const x = `prefix \\` ' + NOSITEL_SPRAVA
                     + ' suffix`;\n')


def mut_proiskhozdenie_nositel_stroka_shablon_ekran_bekslesh(
        pack, forma, repo, src):
    """H2 (138-2) экранированный бэкслеш затем экранированный бэктик:
    обе пары поглощаются лексером, носитель внутри шаблона (та же защита
    «\\-экранирование в шаблоне», вторая различимая форма)."""
    _nositel_v_fajle(repo, 'stroka-shablon-ekran-bekslesh.tsx',
                     'const x = `a\\\\\\` ' + NOSITEL_SPRAVA + ' `;\n')


def mut_proiskhozdenie_nositel_mesto_tests(pack, forma, repo, src):
    """H3 __tests__/ (свидетель критика кр.2; форма 138-2: helper.tsx —
    имя БЕЗ меток, расширение кода; краснеет ТОЛЬКО каталогом)."""
    _nositel_v_fajle(repo, '__tests__/helper.tsx',
                     'export const f = () => ' + NOSITEL_SPRAVA + ';\n')


def mut_proiskhozdenie_nositel_mesto_mocks(pack, forma, repo, src):
    """H3 __mocks__/: мок в дереве экрана — не код экрана."""
    _nositel_v_fajle(repo, '__mocks__/f.tsx', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_snapshots(pack, forma, repo, src):
    """H3 __snapshots__/ (форма 138-2: f.tsx — расширение кода, имя без
    меток; краснеет ТОЛЬКО каталогом, не тремя причинами сразу)."""
    _nositel_v_fajle(repo, '__snapshots__/f.tsx', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_test_fajl(pack, forma, repo, src):
    """H3 f.test.tsx без каталога: суффикс .test. перед расширением."""
    _nositel_v_fajle(repo, 'f.test.tsx', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_spec_fajl(pack, forma, repo, src):
    """H3 f.spec.tsx: суффикс .spec. перед расширением."""
    _nositel_v_fajle(repo, 'f.spec.tsx', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_stories(pack, forma, repo, src):
    """H3 f.stories.tsx:storybook-истории — не код экрана."""
    _nositel_v_fajle(repo, 'f.stories.tsx', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_d_ts(pack, forma, repo, src):
    """H3 f.d.ts: описания типов — не экранной код (.ts вообще не JSX)."""
    _nositel_v_fajle(repo, 'f.d.ts', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_snap(pack, forma, repo, src):
    """H3 f.snap вне каталога снапшотов: суффикс имени — не код."""
    _nositel_v_fajle(repo, 'f.snap', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_mesto_ne_kod(pack, forma, repo, src):
    """H3 f.md с честным JSX внутри: не-код расширение — не экран."""
    _nositel_v_fajle(repo, 'f.md', NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_chestnyj_ternar(pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C: рантайм-тернар с носителем (форма продукта
    start-screen.tsx:117) — честный экран, ложный красный недопустим."""
    _nositel_v_fajle(repo, 'chestnyj-ternar.tsx',
                     'const Karta = continuable ? (' + NOSITEL_SPRAVA
                     + ') : null;\n')


def mut_proiskhozdenie_nositel_chestnyj_jsx_kommentarij_rjadom(
        pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C (start-screen.tsx:174-181): JSX-комментарий
    строкой выше честного носителя не должен съедать носитель."""
    _nositel_v_fajle(repo, 'chestnyj-jsx-kommentarij.tsx',
                     '{/* proverka testID nizhe */}\n' + NOSITEL_SPRAVA
                     + '\n')


def mut_proiskhozdenie_nositel_chestnyj_apostrof_drugaja_stroka(
        pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C: апостроф JSX-текста строкой выше носителя —
    строка обязана обрываться на переводе, носитель видим."""
    _nositel_v_fajle(repo, 'chestnyj-apostrof.tsx',
                     "<Text>l'app</Text>\n" + NOSITEL_SPRAVA + '\n')


def mut_proiskhozdenie_nositel_chestnyj_fajl_rjadom_s_testom(
        pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C: носитель в f.tsx, дубль в __tests__/f.test.tsx
    тем же testID — тест не отравляет дерево, f.tsx читается (rc 0)."""
    _udali_idle(repo)
    baze = repo / 'mobile/src/features/start'
    (baze / 'f.tsx').write_text(NOSITEL_SPRAVA + '\n', encoding='utf-8')
    d = baze / '__tests__'
    d.mkdir(parents=True, exist_ok=True)
    (d / 'f.test.tsx').write_text(NOSITEL_SPRAVA + '\n', encoding='utf-8')


def mut_proiskhozdenie_nositel_chestnyj_shablon_bekslesh(
        pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C (138-2): `a\\\\`; — шаблон ЗАКРЫТ (экраниро-
    ванный бэкслеш не прячет парный бэктик), носитель строкой ниже в
    коде; ложный красный недопустим."""
    _nositel_v_fajle(repo, 'chestnyj-shablon-bekslesh.tsx',
                     'const x = `a\\\\`;\nexport const f = () => '
                     + NOSITEL_SPRAVA + ';\n')


def mut_proiskhozdenie_nositel_chestnyj_stroka_bekslesh(
        pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C (138-2): "a\\\\"; — строка ЗАКРЫТА, носитель
    строкой ниже в коде; экранированный бэкслеш не прячет код."""
    _nositel_v_fajle(repo, 'chestnyj-stroka-bekslesh.tsx',
                     'const x = "a\\\\";\nexport const f = () => '
                     + NOSITEL_SPRAVA + ';\n')


def mut_proiskhozdenie_nositel_chestnyj_shablon_podstanovka(
        pack, forma, repo, src):
    """ЗЕЛЁНЫЙ контроль C (138-2): `n=${1}`; — ${…} НЕ закрывает шаблон,
    носитель строкой ниже в коде (подстановка рядом с носителем)."""
    _nositel_v_fajle(repo, 'chestnyj-shablon-podstanovka.tsx',
                     'const x = `n=${1}`;\nexport const f = () => '
                     + NOSITEL_SPRAVA + ';\n')


MUTACII = {
    'chestnyj-ekran': None,
    'literal-cveta': mut_literal_cveta,
    'kadr-nizhe-poroga': mut_kadr_nizhe_poroga,
    'chuzhoj-kadr': mut_chuzhoj_kadr,
    'zamenjaet-pustoj': mut_zamenjaet_pustoj,
    'ne-trogaet-pustoj': mut_ne_trogaet_pustoj,
    'kontrakt-slishkom-dlinnyj': mut_kontrakt_slishkom_dlinnyj,
    'kontrakt-shirokij': mut_kontrakt_shirokij,
    'kadry-ustarevshie': mut_kadry_ustarevshie,
    'e2e-ne-proshla': mut_e2e_ne_proshla,
    'zhivaja-pachta-v-repo': mut_zhivaja_pachta_v_repo,
    'proiskhozdenie-chistyj': mut_proiskhozdenie_chistyj,
    'proiskhozdenie-byte-kopija': mut_proiskhozdenie_byte_kopija,
    'proiskhozdenie-flow-bez-perehoda': mut_proiskhozdenie_flow_bez_perehoda,
    'proiskhozdenie-flow-appid-chuzhoj': mut_proiskhozdenie_flow_appid_chuzhoj,
    'proiskhozdenie-config-bez-iskljuchenija': mut_proiskhozdenie_config_bez_iskljuchenija,
    'proiskhozdenie-deeplink': mut_proiskhozdenie_deeplink,
    'proiskhozdenie-selektor-bez-ekrana': mut_proiskhozdenie_selektor_bez_ekrana,
    'proiskhozdenie-selektor-ne-kadra': mut_proiskhozdenie_selektor_ne_kadra,
    'proiskhozdenie-start-pustoj': mut_proiskhozdenie_start_pustoj,
    'proiskhozdenie-flow-uslovnyj-when-visible': mut_proiskhozdenie_flow_uslovnyj_when_visible,
    'proiskhozdenie-flow-uslovnyj-when-notvisible': mut_proiskhozdenie_flow_uslovnyj_when_notvisible,
    'proiskhozdenie-flow-uslovnyj-when-platform': mut_proiskhozdenie_flow_uslovnyj_when_platform,
    'proiskhozdenie-flow-uslovnyj-repeat': mut_proiskhozdenie_flow_uslovnyj_repeat,
    'proiskhozdenie-flow-uslovnyj-retry': mut_proiskhozdenie_flow_uslovnyj_retry,
    'proiskhozdenie-flow-uslovnyj-runflow-vlozhennyj': mut_proiskhozdenie_flow_uslovnyj_runflow_vlozhennyj,
    'proiskhozdenie-flow-uslovnyj-runflow-fajl': mut_proiskhozdenie_flow_uslovnyj_runflow_fajl,
    'proiskhozdenie-flow-uslovnyj-onflow': mut_proiskhozdenie_flow_uslovnyj_onflow,
    'proiskhozdenie-flow-kommentarij-imitacija': mut_proiskhozdenie_flow_kommentarij_imitacija,
    'proiskhozdenie-flow-yaml-ankor': mut_proiskhozdenie_flow_yaml_ankor,
    'proiskhozdenie-selektor-chuzhoj-drevo': mut_proiskhozdenie_selektor_chuzhoj_drevo,
    'proiskhozdenie-dopusk-selektor-chuzhoj-drevo': mut_proiskhozdenie_dopusk_selektor_chuzhoj_drevo,
    'proiskhozdenie-selektor-nositel-v-stroke': mut_proiskhozdenie_selektor_nositel_v_stroke,
    'proiskhozdenie-selektor-nositel-v-kommentarii': mut_proiskhozdenie_selektor_nositel_v_kommentarii,
    'proiskhozdenie-selektor-cbhok-atribut': mut_proiskhozdenie_selektor_cbhok_atribut,
    'proiskhozdenie-selektor-registr': mut_proiskhozdenie_selektor_registr,
    'proiskhozdenie-selektor-dinamicheskij': mut_proiskhozdenie_selektor_dinamicheskij,
    'proiskhozdenie-selektor-probely': mut_proiskhozdenie_selektor_probely,
    'proiskhozdenie-selektor-v-oboih': mut_proiskhozdenie_selektor_v_oboih,

    'proiskhozdenie-nositel-kommentarij-hvost': mut_proiskhozdenie_nositel_kommentarij_hvost,
    'proiskhozdenie-nositel-kommentarij-stroka': mut_proiskhozdenie_nositel_kommentarij_stroka,
    'proiskhozdenie-nositel-kommentarij-blok': mut_proiskhozdenie_nositel_kommentarij_blok,
    'proiskhozdenie-nositel-kommentarij-blok-mnogostrochnyj': mut_proiskhozdenie_nositel_kommentarij_blok_mnogostrochnyj,
    'proiskhozdenie-nositel-kommentarij-jsdoc': mut_proiskhozdenie_nositel_kommentarij_jsdoc,
    'proiskhozdenie-nositel-kommentarij-jsx': mut_proiskhozdenie_nositel_kommentarij_jsx,
    'proiskhozdenie-nositel-kommentarij-jsx-mnogostrochnyj': mut_proiskhozdenie_nositel_kommentarij_jsx_mnogostrochnyj,
    'proiskhozdenie-nositel-stroka-odinarnaja': mut_proiskhozdenie_nositel_stroka_odinarnaja,
    'proiskhozdenie-nositel-stroka-dvojnaja-ekranirovannaja': mut_proiskhozdenie_nositel_stroka_dvojnaja_ekranirovannaja,
    'proiskhozdenie-nositel-stroka-shablon': mut_proiskhozdenie_nositel_stroka_shablon,
    'proiskhozdenie-nositel-stroka-prodolzhenie': mut_proiskhozdenie_nositel_stroka_prodolzhenie,
    'proiskhozdenie-nositel-stroka-shablon-ekran-backtick': mut_proiskhozdenie_nositel_stroka_shablon_ekran_backtick,
    'proiskhozdenie-nositel-stroka-shablon-ekran-bekslesh': mut_proiskhozdenie_nositel_stroka_shablon_ekran_bekslesh,
    'proiskhozdenie-nositel-mesto-tests': mut_proiskhozdenie_nositel_mesto_tests,
    'proiskhozdenie-nositel-mesto-mocks': mut_proiskhozdenie_nositel_mesto_mocks,
    'proiskhozdenie-nositel-mesto-snapshots': mut_proiskhozdenie_nositel_mesto_snapshots,
    'proiskhozdenie-nositel-mesto-test-fajl': mut_proiskhozdenie_nositel_mesto_test_fajl,
    'proiskhozdenie-nositel-mesto-spec-fajl': mut_proiskhozdenie_nositel_mesto_spec_fajl,
    'proiskhozdenie-nositel-mesto-stories': mut_proiskhozdenie_nositel_mesto_stories,
    'proiskhozdenie-nositel-mesto-d-ts': mut_proiskhozdenie_nositel_mesto_d_ts,
    'proiskhozdenie-nositel-mesto-snap': mut_proiskhozdenie_nositel_mesto_snap,
    'proiskhozdenie-nositel-mesto-ne-kod': mut_proiskhozdenie_nositel_mesto_ne_kod,
    'proiskhozdenie-nositel-chestnyj-ternar': mut_proiskhozdenie_nositel_chestnyj_ternar,
    'proiskhozdenie-nositel-chestnyj-jsx-kommentarij-rjadom': mut_proiskhozdenie_nositel_chestnyj_jsx_kommentarij_rjadom,
    'proiskhozdenie-nositel-chestnyj-apostrof-drugaja-stroka': mut_proiskhozdenie_nositel_chestnyj_apostrof_drugaja_stroka,
    'proiskhozdenie-nositel-chestnyj-fajl-rjadom-s-testom': mut_proiskhozdenie_nositel_chestnyj_fajl_rjadom_s_testom,
    'proiskhozdenie-nositel-chestnyj-shablon-bekslesh': mut_proiskhozdenie_nositel_chestnyj_shablon_bekslesh,
    'proiskhozdenie-nositel-chestnyj-stroka-bekslesh': mut_proiskhozdenie_nositel_chestnyj_stroka_bekslesh,
    'proiskhozdenie-nositel-chestnyj-shablon-podstanovka': mut_proiskhozdenie_nositel_chestnyj_shablon_podstanovka,
}


# --- суд входа ---------------------------------------------------------------

def run_subject(subject, name, src):
    tmp = Path(tempfile.mkdtemp(prefix='ekran138-'))
    try:
        pack, forma = build_pack(src, tmp)
        repo = build_repo(src, tmp, pack)
        if MUTACII[name] is not None:
            MUTACII[name](pack, forma, repo, src)
        # второй субъект батареи: проверка происхождения (файл пачки)
        if src['kejsy'][name].get('subekt') == 'proverka' \
                and subject == MODEL:
            subject = tmp / 'proverka_subekt.py'
            subject.write_text(src['proverka_tekst'], encoding='utf-8')
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
        problemy.append('prichiny=%r, ожидались %r'
                        % (prichiny, sorted(exp['prichiny'])))
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
        print('SVERKA_123_ABSENT: раннер 123 не в дереве (инфраструктура)',
              file=sys.stderr)
        return 2
    if not MODEL.is_file():
        print('SVERKA_123_ABSENT: эталон 132 не в дереве (инфраструктура)',
              file=sys.stderr)
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
