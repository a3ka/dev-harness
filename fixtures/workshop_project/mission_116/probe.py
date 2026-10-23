#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 116 (§ПРОВОДКА): судит пачку mission валидатором
# 132, проверкой происхождения и статической пробой поведения/рендера
# (третий субъект, teksty/statika_text.py + честная модель экрана
# teksty/ekran.stand-in.tsx); Н-39: стабы привязаны к ветвям всех
# субъектов по stab_vhod source.json, не по тексту контракта.
"""Батарея 116 (mission): экран беседы F05 по шаблону 132.

Предмет: пачка Mission (форма 132, контракт, манифест 7 кадров F05 с PNG,
структурное описание 4 кадров без PNG) судится валидатором 132 и проверкой
происхождения (вход из Start, жест черновика/вложения, селекторы, byte-копия,
кадры без PNG: копия из каталога, токен из tokens.css, testID в потоке).
PNG продукта re-encode для честного stand-in: score 1.000, байты отличны.
Stand-in не доказывает реальный эмулятор.

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
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
SUBJECT = H_ROOT / 'scripts' / 'ekran_shablon.py'
RUNNER123 = H_ROOT / 'scripts' / 'sverka_maketa.py'
MODEL = H_ROOT / 'fixtures' / 'workshop_project' / 'ekran_shablon_132' / \
    'model' / 'ekran_shablon.py'
STUBS = HERE / 'stubs'


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
    assert bd == 8 and ct in (2, 6), 'ожидался RGB/RGBA'
    nch = 3 if ct == 2 else 4
    ch, stride = nch, w * nch
    raw = zlib.decompress(bytes(idat))
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
    return w, h, nch, rows


def png_encode(w, h, nch, rows):
    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d +
                struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF))

    if nch == 3:
        rows = [b''.join(r[x * 3:x * 3 + 3] + b'\xff' for x in range(w))
                for r in rows]
    raw = b''.join(b'\x00' + r for r in rows)
    return (b'\x89PNG\r\n\x1a\n' +
            chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) +
            chunk(b'IDAT', zlib.compress(raw, 1)) + chunk(b'IEND', b''))


def derive_bez_elementa(blob, polosa_pt):
    """Полоса polosa_pt [x0,y0,x1,y1] pt залита фоном (мода цвета по сетке
    полосы) — свидетель ниже-порога (приём derive батарей 123/132)."""
    w, h, nch, rows = png_decode(blob)
    x0, y0, x1, y1 = polosa_pt
    c = Counter()
    for y in range(y0, min(y1, h), 5):
        for x in range(x0, min(x1, w), 5):
            c[rows[y][x * nch:x * nch + 3] + b'\xff'] += 1
    fon = c.most_common(1)[0][0]
    out = []
    for y in range(h):
        r = bytearray(rows[y])
        if y0 <= y < y1:
            for x in range(x0, min(x1, w)):
                r[x * nch:x * nch + nch] = fon[:nch]
        out.append(bytes(r))
    return png_encode(w, h, nch, out)


# --- оракул ------------------------------------------------------------------

def load_source():
    """source.json + защита оракула: sha носителей, согласованность стабов."""
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    for rel, pin in src['nositeli'].items():
        blob = (HERE / rel).read_bytes()
        if sha256_bytes(blob) != pin['sha256']:
            print('ORACLE_TAMPERED: носитель %s' % rel, file=sys.stderr)
            raise SystemExit(2)
    carriers = {
        'teksty/proverka_text.py': 'proverka_tekst',
        'teksty/flow.yaml': 'flow',
        'teksty/testids.stand-in.tsx': 'testids_tekst',
        'teksty/app_start.stand-in.tsx': 'app_start_tekst',
        'teksty/e2e_text.sh': 'e2e_skript',
        'teksty/batareja_text.sh': 'batareja_tekst',
        'teksty/tokens_audit.css': 'tokens_audit',
        'teksty/sostojanija_bez_png.json': 'sostojanija_bez_png',
        'teksty/ekran.stand-in.tsx': 'ekran_tekst',
        'teksty/statika_text.py': 'statika_tekst',
        'teksty/povedenie.test.stand-in.tsx': 'povedenie_proba',
        'teksty/mobile-ci.stand-in.yml': 'mobile_ci_tekst',
    }
    for rel, key in carriers.items():
        if (HERE / rel).read_bytes() != src[key].encode('utf-8'):
            print('ORACLE_TAMPERED: carrier %s' % rel, file=sys.stderr)
            raise SystemExit(2)
    pin_proby = hashlib.sha256(src['povedenie_proba'].encode('utf-8')).hexdigest()
    if pin_proby != src['povedenie_proba_sha256']:
        print('ORACLE_TAMPERED: sha пробы поведения != пин source.json',
              file=sys.stderr)
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
    for k in src['kadry_manifest']['kadry']:
        filename = Path(k['maket']).name
        d = repo / Path(k['maket']).parent
        d.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(HERE / ('nositeli/maket/' + filename), d / filename)
    ds = repo / 'docs/ux/03_Mobility_Slice1/ds'
    ds.mkdir(parents=True)
    (ds / 'tokens.css').write_text(src['tokens_audit'], encoding='utf-8')
    pak = repo / 'mobile/e2e-mission'
    pak.mkdir(parents=True)
    (pak / 'katalog_kopii.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (pak / 'spec_api.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    ma = repo / 'mobile/.maestro'
    ma.mkdir(parents=True)
    (ma / 'mission.yaml').write_text(src['flow'], encoding='utf-8')
    # stand-in android-e2e (replay) + носители записи: кадры в Maestro-раскладку
    # кладёт ИСПОЛНЕННАЯ команда priemka.e2e — стартуем с пустым kadry_dir
    (repo / 'mobile/e2e-mission/e2e.sh').write_text(
        src['e2e_skript'], encoding='utf-8')
    # файл пачки в продукте + носители селекторов флоя (stand-in кода экрана)
    (repo / 'mobile/e2e-mission/batareja').mkdir(parents=True)
    shutil.copyfile(pack / 'batareja/proverka_proiskhozdenija.py',
                    repo / 'mobile/e2e-mission/batareja/proverka_proiskhozdenija.py')
    fc = repo / 'mobile/src/features/conversation'
    fc.mkdir(parents=True)
    # честная модель экрана беседы: субъект статической пробы 116
    (fc / 'conversation-screen.tsx').write_text(
        src['ekran_tekst'], encoding='utf-8')
    (fc / 'testids.stand-in.tsx').write_text(
        src['testids_tekst'], encoding='utf-8')
    app = repo / 'mobile/src/app'
    app.mkdir(parents=True)
    # вход в Mission — из вкладки Start (состав вкладок, не голый маркер)
    (app / 'testids.stand-in.tsx').write_text(
        src['app_start_tekst'], encoding='utf-8')
    for kadr in src['kadry_manifest']['kadry']:
        d = repo / 'mobile/e2e-nositeli' / kadr['tema']
        d.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(
            HERE / ('nositeli/kadry/%s-%s.png' % (kadr['tema'], slug(kadr['id']))),
            d / (kadr['snimok'] + '.png'))
    (repo / 'mobile/maestro-out-mission').mkdir(parents=True)
    # пин механизма 123 внутри репо (как в продукте): честная priemka.sverka
    # запускает раннер из .harness123; сверка-образец и приёмка обязаны
    # дать дословно одинаковый вывод
    pin123 = repo / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pack / 'kadry.json', pin123 / 'kadry.json')
    # исполняемая семья поведения/рендера (0259fb00 а/б): текст пробы —
    # в продукте по пути из критерия, байт-идентичен пину source.json
    proba = repo / 'mobile/src/features/conversation/__tests__'
    proba.mkdir(parents=True)
    (proba / 'mission-116.test.tsx').write_text(
        src['povedenie_proba'], encoding='utf-8')
    ci = repo / '.github/workflows'
    ci.mkdir(parents=True)
    (ci / 'mobile.yml').write_text(src['mobile_ci_tekst'], encoding='utf-8')
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
    (pack / 'sostojanija_bez_png.json').write_text(
        src['sostojanija_bez_png'], encoding='utf-8')
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
        f.write('\n# цвет поверхности: #F3F2EE\n')


def mut_kadr_nizhe_poroga(pack, forma, repo, src):
    k = src['kadry_manifest']['kadry'][5]
    f = nositel(repo, k['tema'], k['snimok'])
    blob = derive_bez_elementa(f.read_bytes(), src['bez_elementa']['polosa_pt'])
    f.write_bytes(blob)


def mut_kadr_composer_skryt(pack, forma, repo, src):
    """Composer (CTA беседы) исчезает при почти неизменном глобальном score."""
    k = src['kadry_manifest']['kadry'][5]
    f = nositel(repo, k['tema'], k['snimok'])
    f.write_bytes(derive_bez_elementa(f.read_bytes(), [0, 640, 390, 740]))


def mut_chuzhoj_kadr(pack, forma, repo, src):
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    chuzhoj = json.loads(json.dumps(m['kadry'][0]))
    chuzhoj['id'] = 'Fiktura-Kadr-Chuzhoj'
    m['kadry'].append(chuzhoj)
    (pack / 'kadry.json').write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')
def polosa_pikseli(blob, polosa_pt):
    """pt-полоса [x0,y0,x1,y1] сетки 390x844 → пиксели носителя кадра
    (высокие макеты F05.06/V03 mapperом 123 сжимаются в 844 pt)."""
    w, h, _nch, _rows = png_decode(blob)
    x0, y0, x1, y1 = polosa_pt
    return [x0 * w // 390, y0 * h // 844, x1 * w // 390, y1 * h // 844]


def mut_kadr_nizhe_poroga(pack, forma, repo, src):
    k = src['kadry_manifest']['kadry'][5]
    f = nositel(repo, k['tema'], k['snimok'])
    blob = f.read_bytes()
    f.write_bytes(derive_bez_elementa(
        blob, polosa_pikseli(blob, src['bez_elementa']['polosa_pt'])))


def mut_kadr_composer_skryt(pack, forma, repo, src):
    """Composer (CTA беседы) исчезает при почти неизменном глобальном score."""
    k = src['kadry_manifest']['kadry'][5]
    f = nositel(repo, k['tema'], k['snimok'])
    blob = f.read_bytes()
    f.write_bytes(derive_bez_elementa(
        blob, polosa_pikseli(blob, [0, 690, 390, 800])))


def _staryj_pachta(repo, src):
    d = repo / 'fixtures/workshop_project/old_mission_001'
    d.mkdir(parents=True)
    (d / 'ekran.json').write_text(
        json.dumps(src['repo_staryj_ekran']['ekran'], ensure_ascii=False,
                   indent=1), encoding='utf-8')
    (d / 'kadry.json').write_text(
        json.dumps(src['repo_staryj_ekran']['kadry'], ensure_ascii=False,
                   indent=1), encoding='utf-8')

def mut_ne_tselikom(pack, forma, repo, src):
    _staryj_pachta(repo, src)
    forma['zamenjaet'] = 'fixtures/workshop_project/old_mission_001/kadry.json'
    zapis(pack, forma)
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    m['kadry'] = [k for k in m['kadry'] if not k['id'].startswith('F05.03')]
    (pack / 'kadry.json').write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_zamenjaet_pustoj(pack, forma, repo, src):
    _staryj_pachta(repo, src)
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
        ['bash', 'mobile/e2e-mission/e2e.sh', 'mission'],
        cwd=str(repo), capture_output=True, text=True)
    if zap.returncode != 0:
        raise RuntimeError('replay e2e: rc=%d %s' % (zap.returncode, zap.stderr))
    forma['priemka']['e2e'] = 'true'
    zapis(pack, forma)


def mut_e2e_ne_proshla(pack, forma, repo, src):
    forma['priemka']['e2e'] = 'bash mobile/e2e-mission/e2e.sh net-takogo'
    zapis(pack, forma)


def mut_zhivaja_pachta_v_repo(pack, forma, repo, src):
    """Живая пачка ТОГО ЖЕ экрана в переданном продукте (--repo): полнота
    замены по живым пачкам --repo (мера 132) — замена неполна молча."""
    _staryj_pachta(repo, src)


def _zapusti_replay(repo):
    """Stand-in e2e кладёт кадры в Maestro-раскладку (как Maestro-прогон
    CI продукта кладёт настоящие кадры до проверки происхождения)."""
    zap = subprocess.run(
        ['bash', 'mobile/e2e-mission/e2e.sh', 'mission'],
        cwd=str(repo), capture_output=True, text=True)
    if zap.returncode != 0:
        raise RuntimeError('replay e2e: rc=%d %s' % (zap.returncode, zap.stderr))


def mut_proiskhozdenie_chistyj(pack, forma, repo, src):
    """Честный вход проверки происхождения: кадры положены прогоном e2e,
    байты кадров отличны от макетов (носители перекодированы), флоу несёт
    запуск/вход из Start/переходы/assert-селекторы, жесты черновика и
    вложения, кадры без PNG описаны структурно."""
    _zapusti_replay(repo)


def mut_proiskhozdenie_byte_kopija(pack, forma, repo, src):
    """Подмена e2e: F05.01 побайтово копирует макет."""
    k = src['kadry_manifest']['kadry'][0]
    n = nositel(repo, k['tema'], k['snimok'])
    n.write_bytes((repo / k['maket']).read_bytes())
    _zapusti_replay(repo)


def mut_proiskhozdenie_flow_bez_perehoda(pack, forma, repo, src):
    """Флоу с именами кадров, но без переходов и селекторов экрана."""
    _zapusti_replay(repo)
    (repo / 'mobile/.maestro/mission.yaml').write_text(
        'appId: com.complior.demo\n---\n- launchApp\n' +
        ''.join('- takeScreenshot: ' + k['snimok'] + '\n'
                for k in src['kadry_manifest']['kadry']))


def mut_proiskhozdenie_selektor_bez_ekrana(pack, forma, repo, src):
    """Удалить носители testID композера (жест черновика): stand-in и экран."""
    p = repo / 'mobile/src/features/conversation/testids.stand-in.tsx'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '<View testID="mission_composer_input" />\n', ''), encoding='utf-8')
    _perepishi_ekran(repo, '        testID="mission_composer_input"\n', '')


def mut_proiskhozdenie_selektor_ne_kadra(pack, forma, repo, src):
    """assertVisible селектора другого кадра не доказывает этот кадр."""
    _zapusti_replay(repo)
    p = repo / 'mobile/.maestro/mission.yaml'
    old = '- assertVisible: {id: mission_frame_f05_05}\n'
    assert p.read_text(encoding='utf-8').count(old) == 1
    p.write_text(p.read_text(encoding='utf-8').replace(
        old, '- assertVisible: {id: mission_frame_f05_01}\n'), encoding='utf-8')


def mut_proiskhozdenie_bez_start_vhoda(pack, forma, repo, src):
    """Самостоятельный deep-link экран при оборванном входе из Start."""
    _zapusti_replay(repo)
    p = repo / 'mobile/.maestro/mission.yaml'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '- tapOn: {id: start_tab_start}\n',
        '- openLink: complior://mission\n'), encoding='utf-8')


def mut_proiskhozdenie_bez_draft_gesta(pack, forma, repo, src):
    """Флоу без ввода текста: ось черновика не наблюдается."""
    _zapusti_replay(repo)
    p = repo / 'mobile/.maestro/mission.yaml'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '- inputText: {id: mission_composer_input, '
        "text: 'Ich habe ein Auto gekauft.'}\n", ''), encoding='utf-8')


def mut_proiskhozdenie_bez_vlozhenija(pack, forma, repo, src):
    """Флоу без жеста вложения: меню/чип не наблюдается."""
    _zapusti_replay(repo)
    p = repo / 'mobile/.maestro/mission.yaml'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '- tapOn: {id: mission_attach}\n', ''), encoding='utf-8')


def _perepishi_bezpng(pack, src, **pravka):
    opis = json.loads(src['sostojanija_bez_png'])
    k0 = opis['kadry_bez_png'][0]
    for kljuch, znach in pravka.items():
        k0[kljuch] = znach
    (pack / 'sostojanija_bez_png.json').write_text(
        json.dumps(opis, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_bezpng_kopija_vne_kataloga(pack, forma, repo, src):
    """Кадр без PNG с выдуманной копией (нет в каталоге)."""
    _zapusti_replay(repo)
    _perepishi_bezpng(pack, src, kljuchi_kopii=['frame.F05.99.title'])


def mut_bezpng_token_vne_audita(pack, forma, repo, src):
    """Состояние composer с цветом вне tokens.css (вторая палитра)."""
    _zapusti_replay(repo)
    _perepishi_bezpng(pack, src, tokeny=['--ne-iz-audita'])


def mut_bezpng_bez_testid_v_potoke(pack, forma, repo, src):
    """testID состояния объявлен, но в потоке не наблюдается."""
    _zapusti_replay(repo)
    p = repo / 'mobile/.maestro/mission.yaml'
    p.write_text(p.read_text(encoding='utf-8').replace(
        '- assertVisible: {id: mission_queued_offline}\n', ''),
        encoding='utf-8')


def _ekran(repo):
    return repo / 'mobile/src/features/conversation/conversation-screen.tsx'


def _perepishi_ekran(repo, staro, novo, scet=1):
    p = _ekran(repo)
    t = p.read_text(encoding='utf-8')
    if staro not in t:
        raise RuntimeError('якорь экрана не найден: %r' % staro[:60])
    p.write_text(t.replace(staro, novo, scet), encoding='utf-8')


def mut_povedenie_chistyj(pack, forma, repo, src):
    """Честный вход статической пробы: модель экрана без правок."""


def mut_povedenie_draft_termjaetsja(pack, forma, repo, src):
    """Черновик сбрасывается на пути вложения (ось issue #9 потеряна)."""
    _perepishi_ekran(repo, "setSendState('attachment_pending');",
                     "setSendState('attachment_pending');\n    setDraft('');")


def mut_povedenie_draft_vechen(pack, forma, repo, src):
    """Черновик не снимается после принятой отправки."""
    _perepishi_ekran(repo, "if (status === 'accepted') {\n      setDraft('');",
                     "if (status === 'accepted') {\n      setSendState('sent');")


def mut_povedenie_draft_bez_hranilishcha(pack, forma, repo, src):
    """Черновик не переживает контролируемый ремоунт (нет хранилища)."""
    _perepishi_ekran(repo, 'const [draft, setDraftState] = useState(draftStore);',
                     "const [draft, setDraftState] = useState('');")


def mut_povedenie_intent_slitan(pack, forma, repo, src):
    """Новая тема отправляется сообщением, отдельного intent нет."""
    _perepishi_ekran(repo,
                     'const intent = await api.createIntent(topic);\n'
                     "    setDraft('');\n"
                     '    await api.postMessage({ intentId: intent.id });',
                     "setDraft('');\n    await api.postMessage({ text: topic });")


def mut_povedenie_dublient(pack, forma, repo, src):
    """Повтор already_accepted создаёт дубль сообщения."""
    _perepishi_ekran(repo, "setSendState('already_accepted');",
                     "setSendState('already_accepted');\n"
                     '      setMessages((m) => [...m, { text: draft }]);')


def mut_povedenie_interrupted_zavershen(pack, forma, repo, src):
    """Прерывание завершает миссию (interrupted == completed)."""
    _perepishi_ekran(repo,
                     "<Text>{copy['frame.F05.05.body'].text}</Text>\n"
                     '        </View>',
                     "<Text>{copy['frame.F05.05.body'].text}</Text>\n"
                     '        <Pressable onPress={() => api.completeMission(missionId)} />\n'
                     '        </View>')


def mut_povedenie_revoked_pokazan(pack, forma, repo, src):
    """Отозванный источник показывается (фильтр снят)."""
    _perepishi_ekran(repo, 'sources.filter((d) => d.revoked !== true)', 'sources')


def mut_bezpng_render_pustoj(pack, forma, repo, src):
    """Кадр без PNG — пустой контейнер с testID вместо рендера состояния."""
    _perepishi_ekran(repo,
                     '<View testID="mission_queued_offline" '
                     'className="warm on-warm panel">\n'
                     "          <Text>{copy['state.G06.title'].text}</Text>\n"
                     '          <Pressable testID="mission_offline_retry" '
                     'onPress={onSend}>\n'
                     "            <Text>{copy['global.retry'].text}</Text>\n"
                     '          </Pressable>\n'
                     '        </View>',
                     '<View testID="mission_queued_offline" />')


def mut_bezpng_render_stroka(pack, forma, repo, src):
    """Строка состояния переизобретена (не ссылка на каталог)."""
    _perepishi_ekran(repo, "<Text>{copy['frame.F05.05.title'].text}</Text>",
                     "<Text>{'Antwort unterbrochen'}</Text>")


def mut_bezpng_render_literal(pack, forma, repo, src):
    """Цветовой литерал вне tokens.css в состоянии без PNG."""
    _perepishi_ekran(repo, 'className="calm on-calm panel">',
                     'className="calm on-calm panel" '
                     "style={{ color: '#FF0000' }}>")


def mut_bezpng_chip_stroka(pack, forma, repo, src):
    """Суффикс чипа «wird gelesen» переизобретён (не байт-равен D2.2.5.1)."""
    _perepishi_ekran(repo, "const CHIP_LESET_SUFFIX = ' · wird gelesen';",
                     "const CHIP_LESET_SUFFIX = ' · wird gelesen.';")

PROBA_PROD = Path('mobile/src/features/conversation/__tests__/'
                  'mission-116.test.tsx')
CI_PROD = Path('.github/workflows/mobile.yml')


def _perekopi_fajl(repo, rel, tekst):
    p = repo / rel
    p.write_text(tekst, encoding='utf-8')


def mut_povedenie_proba_otsutstvuet(pack, forma, repo, src):
    """Проба поведения в продукте отсутствует (0259fb00 б)."""
    (repo / PROBA_PROD).unlink()


def mut_povedenie_proba_podmenena(pack, forma, repo, src):
    """Файл пробы есть, но отличается от пина: удалена клетка K18."""
    t = src['povedenie_proba']
    kletka = t[t.index("it('116 mission RENDER_V03_CHIP_LESET"):]
    _perekopi_fajl(repo, PROBA_PROD, t[:-len(kletka)])


def mut_ci_shag_otsutstvuet(pack, forma, repo, src):
    """mobile.yml без шага исполняемой семьи (0259fb00 в)."""
    bez_shaga = '\n'.join(
        l for l in src['mobile_ci_tekst'].splitlines()
        if 'mission-116.test.tsx' not in l
        and '116 mission behaviour render' not in l) + '\n'
    _perekopi_fajl(repo, CI_PROD, bez_shaga)


def mut_ci_shag_ne_gejtit(pack, forma, repo, src):
    """Шаг семьи объявлен, но не гейтит (continue-on-error)."""
    s_gejtom = src['mobile_ci_tekst'].replace(
        '      - name: 116 mission behaviour render\n',
        '      - name: 116 mission behaviour render\n'
        '        continue-on-error: true\n')
    assert s_gejtom != src['mobile_ci_tekst']
    _perekopi_fajl(repo, CI_PROD, s_gejtom)


CI_RUN_STROKA = ('        run: npx jest src/features/conversation/'
                 '__tests__/mission-116.test.tsx')


def mut_ci_coe_posle_run(pack, forma, repo, src):
    """Критик круг 3: continue-on-error ПОСЛЕ run — легальная
    перестановка полей шага; старая проба читала текст только до
    строки маркера и считала шаг гейтовым."""
    s = src['mobile_ci_tekst'].replace(
        CI_RUN_STROKA, CI_RUN_STROKA + '\n        continue-on-error: true')
    assert s != src['mobile_ci_tekst']
    _perekopi_fajl(repo, CI_PROD, s)


def mut_ci_if_false_posle_run(pack, forma, repo, src):
    """Критик круг 3: if: false ПОСЛЕ run — шаг объявлен, но не
    исполняется; для маркер-сканирования шаг «существует»."""
    s = src['mobile_ci_tekst'].replace(
        CI_RUN_STROKA, CI_RUN_STROKA + '\n        if: false')
    assert s != src['mobile_ci_tekst']
    _perekopi_fajl(repo, CI_PROD, s)


def mut_ci_echo_podmena(pack, forma, repo, src):
    """Критик круг 3: имя семьи осталось в shell-комментарии echo —
    вызова npx jest нет, шаг «упоминает» файл, не запуская его."""
    s = src['mobile_ci_tekst'].replace(
        CI_RUN_STROKA, '        run: echo skipped # ' + CI_RUN_STROKA.strip())
    assert s != src['mobile_ci_tekst']
    _perekopi_fajl(repo, CI_PROD, s)


def mut_ci_run_kommentarij(pack, forma, repo, src):
    """Свой (грамматика YAML): многострочный run: |-блок, вызов семьи
    закомментирован — подмена команды комментарием внутри блока."""
    s = src['mobile_ci_tekst'].replace(
        CI_RUN_STROKA,
        '        run: |\n'
        '          # ' + CI_RUN_STROKA.strip() + '\n'
        '          echo workaround')
    assert s != src['mobile_ci_tekst']
    _perekopi_fajl(repo, CI_PROD, s)

def mut_ci_shag_vne_required_job(pack, forma, repo, src):
    """Сценарий переназначен runtime-строке (r9, 675465e2): пинованный
    блок шага в job вне required checks СТАТИЧЕСКИ ЗЕЛЁНЫЙ (membership
    из статики удалён) — вход-свидетель разделения статик/runtime;
    продуктовая приёмка красна (нужного шага нет в required job) —
    это судит runtime-строка критерия (:38) при ленде, не статика.
    Статический стаб s48 удалён: после удаления membership он
    тождествен честному субъекту."""
    shag = ('      - name: 116 mission behaviour render\n'
            '        run: npx jest src/features/conversation/'
            '__tests__/mission-116.test.tsx\n')
    assert shag in src['mobile_ci_tekst']
    vne = src['mobile_ci_tekst'].replace(shag, '') + (
        '  ne-required-job:\n'
        '    runs-on: ubuntu-latest\n'
        '    steps:\n'
        '      - uses: actions/checkout@v4\n' + shag)
    _perekopi_fajl(repo, CI_PROD, vne)


def mut_ci_job_inline_kommentarij(pack, forma, repo, src):
    """Свидетель критика d564854b (1): YAML-комментарий после ключа
    job; блок шага байт-равен пину, job android-e2e — вход ЗЕЛЁНЫЙ."""
    assert src['mobile_ci_tekst'].count('  android-e2e:\n') == 1
    s = src['mobile_ci_tekst'].replace(
        '  android-e2e:\n', '  android-e2e: # required Android job\n')
    _perekopi_fajl(repo, CI_PROD, s)


def mut_ci_job_kavychki(pack, forma, repo, src):
    """Свидетель критика d564854b (2): ключ job в кавычках."""
    assert src['mobile_ci_tekst'].count('  android-e2e:\n') == 1
    s = src['mobile_ci_tekst'].replace(
        '  android-e2e:\n', '  "android-e2e":\n')
    _perekopi_fajl(repo, CI_PROD, s)


def mut_ci_job_otstup_chetyre(pack, forma, repo, src):
    """Свидетель критика d564854b (3): поддерево jobs с отступом 4 —
    блок шага равен пину после .strip(), job android-e2e."""
    assert src['mobile_ci_tekst'].count('jobs:\n') == 1
    golova, hvost = src['mobile_ci_tekst'].split('jobs:\n')
    s = golova + 'jobs:\n' + ''.join(
        '  ' + l + '\n' for l in hvost.splitlines())
    _perekopi_fajl(repo, CI_PROD, s)

def _ci_steps_indentless_tekst(src):
    """steps: на уровне '-' (indentless sequence, YAML-равен честному
    по построению — свидетели критика d564854b/арбитра 675465e2)."""
    tekst = src['mobile_ci_tekst']
    assert tekst.count('    steps:\n') == 1
    pre, steps = tekst.split('    steps:\n')
    return pre + '    steps:\n' + ''.join(
        l[2:] + '\n' for l in steps.splitlines())


def mut_ci_steps_indentless(pack, forma, repo, src):
    """Свидетель критика (indentless_steps): steps: на уровне '-',
    блок шага байт-равен пину — вход ЗЕЛЁНЫЙ (r9, 675465e2: membership
    из статики удалён, ложный VNE_REQUIRED_JOB невозможен)."""
    _perekopi_fajl(repo, CI_PROD, _ci_steps_indentless_tekst(src))


def mut_ci_steps_indentless_kavychka_kommentarij(pack, forma, repo, src):
    """Свидетель критика (indentless_single_quote_comment): indentless
    steps + ключ job в одинарных кавычках с YAML-комментарием —
    вход ЗЕЛЁНЫЙ (статика формы ключа job не судит)."""
    s = _ci_steps_indentless_tekst(src)
    assert s.count('  android-e2e:') == 1
    s = s.replace('  android-e2e:', "  'android-e2e': # required job")
    _perekopi_fajl(repo, CI_PROD, s)


def mut_ci_steps_indentless_otstup_chetyre(pack, forma, repo, src):
    """Свидетель критика (indentless_four_space_job): indentless steps +
    поддерево jobs с отступом 4 — вход ЗЕЛЁНЫЙ (отступ статикой не
    судится, блок равен пину после .strip())."""
    s = _ci_steps_indentless_tekst(src)
    assert s.count('jobs:\n') == 1
    golova, hvost = s.split('jobs:\n')
    s = golova + 'jobs:\n' + ''.join('  ' + l + '\n' for l in hvost.splitlines())
    _perekopi_fajl(repo, CI_PROD, s)


MUTACII = {
    'chestnyj-ekran': None,
    'literal-cveta': mut_literal_cveta,
    'kadr-nizhe-poroga': mut_kadr_nizhe_poroga,
    'kadr-composer-skryt': mut_kadr_composer_skryt,
    'chuzhoj-kadr': mut_chuzhoj_kadr,
    'ne-tselikom': mut_ne_tselikom,
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
    'proiskhozdenie-selektor-bez-ekrana': mut_proiskhozdenie_selektor_bez_ekrana,
    'proiskhozdenie-selektor-ne-kadra': mut_proiskhozdenie_selektor_ne_kadra,
    'proiskhozdenie-bez-start-vhoda': mut_proiskhozdenie_bez_start_vhoda,
    'proiskhozdenie-bez-draft-gesta': mut_proiskhozdenie_bez_draft_gesta,
    'proiskhozdenie-bez-vlozhenija': mut_proiskhozdenie_bez_vlozhenija,
    'bezpng-kopija-vne-kataloga': mut_bezpng_kopija_vne_kataloga,
    'bezpng-token-vne-audita': mut_bezpng_token_vne_audita,
    'bezpng-bez-testid-v-potoke': mut_bezpng_bez_testid_v_potoke,
    'povedenie-chistyj': mut_povedenie_chistyj,
    'povedenie-draft-termjaetsja': mut_povedenie_draft_termjaetsja,
    'povedenie-draft-vechen': mut_povedenie_draft_vechen,
    'povedenie-draft-bez-hranilishcha': mut_povedenie_draft_bez_hranilishcha,
    'povedenie-intent-slitan': mut_povedenie_intent_slitan,
    'povedenie-dublient': mut_povedenie_dublient,
    'povedenie-interrupted-zavershen': mut_povedenie_interrupted_zavershen,
    'povedenie-revoked-pokazan': mut_povedenie_revoked_pokazan,
    'bezpng-render-pustoj': mut_bezpng_render_pustoj,
    'bezpng-render-stroka': mut_bezpng_render_stroka,
    'bezpng-render-literal': mut_bezpng_render_literal,
    'bezpng-chip-stroka': mut_bezpng_chip_stroka,
    'povedenie-proba-otsutstvuet': mut_povedenie_proba_otsutstvuet,
    'povedenie-proba-podmenena': mut_povedenie_proba_podmenena,
    'ci-shag-otsutstvuet': mut_ci_shag_otsutstvuet,
    'ci-shag-ne-gejtit': mut_ci_shag_ne_gejtit,
    'ci-coe-posle-run': mut_ci_coe_posle_run,
    'ci-if-false-posle-run': mut_ci_if_false_posle_run,
    'ci-echo-podmena': mut_ci_echo_podmena,
    'ci-run-kommentarij': mut_ci_run_kommentarij,
    'ci-shag-vne-required-job': mut_ci_shag_vne_required_job,
    'ci-job-inline-kommentarij': mut_ci_job_inline_kommentarij,
    'ci-job-kavychki': mut_ci_job_kavychki,
    'ci-job-otstup-chetyre': mut_ci_job_otstup_chetyre,
    'ci-steps-indentless': mut_ci_steps_indentless,
    'ci-steps-indentless-kavychka-kommentarij':
        mut_ci_steps_indentless_kavychka_kommentarij,
    'ci-steps-indentless-otstup-chetyre':
        mut_ci_steps_indentless_otstup_chetyre,
}


# --- суд входа ---------------------------------------------------------------

def run_subject(subject, name, src):
    tmp = Path(tempfile.mkdtemp(prefix='ekran116-'))
    try:
        pack, forma = build_pack(src, tmp)
        repo = build_repo(src, tmp, pack)
        if MUTACII[name] is not None:
            MUTACII[name](pack, forma, repo, src)
        # второй/третий субъект батареи: происхождение (файл пачки) и
        # статическая проба поведения/рендера (код экрана)
        if src['kejsy'][name].get('subekt') == 'proverka' \
                and subject == MODEL:
            subject = tmp / 'proverka_subekt.py'
            subject.write_text(src['proverka_tekst'], encoding='utf-8')
        if src['kejsy'][name].get('subekt') == 'statika' \
                and subject == MODEL:
            subject = tmp / 'statika_subekt.py'
            subject.write_text(src['statika_tekst'], encoding='utf-8')
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
    kadr_linii = []
    for name in src['kejsy']:
        rc, out, err = run_subject(subject, name, src)
        problemy = judge(name, src, rc, out, err)
        if problemy:
            kontrol_ok = False
            print('CASE %s KRASNO: %s' % (name, '; '.join(problemy)))
        else:
            print('CASE %s ok' % name)
        if a.model and not problemy:
            # честные KADR-строки наружу (сверка с source.json, замер)
            kadr_linii += [l for l in out.splitlines()
                           if l.startswith('KADR\t') and name == 'chestnyj-ekran']
    if a.model:
        for l in kadr_linii:
            print(l)
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
