#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 148 (§ПРОВОДКА): два субъекта — живой
# scripts/ekran_shablon.py (форма модельной пачки v3) и продукт-судья
# produkt_sud.py (дерево продукта/референса по предмету vkladki-tabov).
"""Батарея 148 (vkladki-tabov): нижнее меню/таб-бар D 2.4 — GA-02/03/04/09,
16 кадров (оба профиля × обе темы), Mitte со знаком 145 (tier tab 28 px),
бейдж «Ihre Rückmeldung nötig», контент вкладок, скролл под лейсте (GA-09);
переходов нет (∩-правило манифеста D 2.4).

Субъекты (Н-39: стабы привязаны к ветвям ОБОИХ субъектов по stab_vhod
source.json, не по прозе контракта):
  A (форма) scripts/ekran_shablon.py — живой валидатор харнесса судит
    модельную пачку (nositeli: 16 реальных макетов GA + подмножества
    источников D 2.4); эталон — model/ekran_shablon.py (байт-копия
    модели батареи 146, v3: frozen 132/2 + ветка dvizhenie; пин в
    produkt_sud.ETALON_146_PIN).
  B (продукт) produkt_sud.py --repo R — маркеры шва/Mitte/контента/
    копии/макетов/флоу + полный суд пачки эталоном v3 в синтетическом
    репо из файлов R и носителей; эталон — собранная референсная
    раскладка model/produktnaja-raskladka + пачка ekran_forma_prod.

Режимы (обёртка передаёт аргументом; ожидания — kejsy source.json):
  (без флага)  красный прогон: субъект A — живой скрипт (до реализации
             v3 живым остаётся v2 → клетки формы красны SHABLON_NEVEREN
             «shablon» — честная краснота отсутствия функциональности,
             как у батареи 146); субъект B — дерево ХАРНЕССА (продукта
             в нём нет → PACHKA_ABSENT и др.); rc 1
  --model      эталон A на модельной пачке + эталон B (референс) — rc 0
  --stabs      контроль + матрица обманных стабов (SVJAZI N, живых 0)
  --repo R     (с без флага/--model) субъект B — живой продукт R:
             до реализации красен (PACHKA_ABSENT …), после — зелён
  --snapshot   фактические rc/вывод эталонов по каждому входу (замер)

Коды возврата: 0 — зелено; 1 — красный вход / стаб жив; 2 — нечем
проверять (нет python3, ORACLE_TAMPERED, рассинхрон стабов,
SVERKA_123_ABSENT)."""
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
SUBJECT_A = H_ROOT / 'scripts' / 'ekran_shablon.py'
MODEL_A = HERE / 'model' / 'ekran_shablon.py'
RUNNER123 = H_ROOT / 'scripts' / 'sverka_maketa.py'
STUBS = HERE / 'stubs'
NOS_MAKET = HERE / 'nositeli/maket'
NOS_D24 = HERE / 'nositeli/d24'
NOS_D24_REAL = HERE / 'nositeli/d24-real'
NOS_TOKENS = HERE / 'nositeli/tokens.css'
RASKLADKA = HERE / 'model' / 'produktnaja-raskladka'
PRODUKT_SUD = HERE / 'produkt_sud.py'

E2E_CMD = 'bash mobile/e2e-vkladki/e2e.sh vkladki'
SVERKA_CMD = ('python3 .harness123/scripts/sverka_maketa.py'
              ' --manifest .harness123/kadry.json'
              ' --kadry mobile/maestro-out-vkladki --repo .')
PROKHOD_CMD = 'bash mobile/e2e-vkladki/prokhod.sh mobile/.maestro/prokhod-vkladki.yaml'
DVIZHENIE_CMD = 'bash mobile/e2e-vkladki/dvizhenie.sh vkladki'


def sha256_fajla(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def load_source():
    """source.json + защита оракула: пины носителей/раскладки, согласованность
    стабов (файлы stubs/ == ключи stab_vhod) — ДО клеток (правило 8)."""
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    imejutsa = sorted(p.name for p in STUBS.glob('*.py') if p.name[0] != '_')
    if imejutsa != sorted(src['stab_vhod']):
        print('ORACLE_TAMPERED: stubs/ != stab_vhod (%s)' % imejutsa,
              file=sys.stderr)
        raise SystemExit(2)
    for gruppa, koren in (('nositeli', HERE), ('etalon_raskladka', HERE)):
        for rel, pin in src['piny'][gruppa].items():
            p = koren / rel
            if not p.is_file() or sha256_fajla(p) != pin:
                print('ORACLE_TAMPERED: %s %s' % (gruppa, rel), file=sys.stderr)
                raise SystemExit(2)
    if sha256_fajla(MODEL_A) != 'ab26d789e7813d403adb160b06131f460ca8082d7d2cc3485673abcaf39b679e':
        print('ORACLE_TAMPERED: пин эталона v3 (model/ekran_shablon.py)',
              file=sys.stderr)
        raise SystemExit(2)
    return src


# --- построение входа формы (синтетическое репо + пачка) -------------------

def zapis(pack: Path, forma):
    (pack / 'ekran.json').write_text(
        json.dumps(forma, ensure_ascii=False, indent=1), encoding='utf-8')


def postavit_makety(repo: Path, kadry_spiski):
    for man in kadry_spiski:
        profil = '390x844' if man is kadry_spiski[0] else '393x852'
        for k in man['kadry']:
            kuda = repo / k['maket']
            if not kuda.parent.exists():
                kuda.parent.mkdir(parents=True)
            shutil.copyfile(NOS_MAKET / ('%s-%s.png' % (profil, Path(k['maket']).stem)),
                            kuda)


def postavit_istochniki(repo: Path, d24):
    for pole, imja in (('manifest', 'manifest.json'), ('spec', 'spec.json'),
                       ('pozvonok', 'poses.json')):
        put = repo / d24[pole]
        put.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(NOS_D24 / imja, put)


def postavit_standiny(repo: Path, src, kljuch_e2e='e2e'):
    pachka = repo / 'mobile/e2e-vkladki'
    pomm = repo / 'mobile/e2e-standin-vkladki'
    pomm.mkdir(parents=True, exist_ok=True)
    (pachka / 'e2e.sh').write_text(src['standiny'][kljuch_e2e], encoding='utf-8')
    (pomm / 'e2e-stand-in.py').write_text(
        src['standiny']['e2e_py'], encoding='utf-8')
    (pomm / 'e2e-ustarevshij.py').write_text(
        src['standiny']['e2e_ustarevshij_py'], encoding='utf-8')
    (pomm / 'e2e-nizhe-poroga.py').write_text(
        src['standiny']['e2e_nizhe_poroga_py'], encoding='utf-8')
    (pomm / 'stand_in_png.py').write_text(src['standiny']['png'], encoding='utf-8')
    (pachka / 'dvizhenie.sh').write_text(src['standiny']['dvizhenie'], encoding='utf-8')
    (pomm / 'dvizhenie-stand-in.py').write_text(
        src['standiny']['dvizhenie_py'], encoding='utf-8')
    (pachka / 'prokhod.sh').write_text(src['standiny']['prokhod'], encoding='utf-8')


def build_forma_repo(src, tmp):
    """Синтетическое репо + модельная пачка (честная база формы)."""
    repo = tmp / 'repo'
    pachka = repo / 'mobile/e2e-vkladki'
    pachka.mkdir(parents=True)
    forma = json.loads(json.dumps(src['ekran_forma']))
    zapis(pachka, forma)
    (pachka / 'kadry.json').write_text(
        json.dumps(src['kadry_manifest'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pachka / forma['vtoroj_profil']['kadry']).write_text(
        json.dumps(src['profil_kadry'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pachka / 'kontrakt.md').write_text(src['kontrakt_tekst'], encoding='utf-8')
    (pachka / 'katalog_kopii.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pachka / 'spec_api.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1), encoding='utf-8')
    b = pachka / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['batareja_tekst'], encoding='utf-8')
    # флоу из эталонной раскладки (те же байты, что пин пинирует)
    for f in ('vkladki.yaml', 'vkladki-tabshell-393.yaml', 'prokhod-vkladki.yaml'):
        kuda = repo / 'mobile/.maestro' / f
        kuda.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(RASKLADKA / 'mobile/.maestro' / f, kuda)
    postavit_makety(repo, (src['kadry_manifest'], src['profil_kadry']))
    postavit_istochniki(repo, forma['dvizhenie'])
    put = repo / forma['audit_tokenov']
    put.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(NOS_TOKENS, put)
    postavit_standiny(repo, src)
    (repo / 'mobile/maestro-out-vkladki').mkdir(parents=True)
    pin123 = repo / '.harness123'
    (pin123 / 'scripts').mkdir(parents=True)
    shutil.copyfile(RUNNER123, pin123 / 'scripts/sverka_maketa.py')
    shutil.copyfile(pachka / 'kadry.json', pin123 / 'kadry.json')
    return repo, pachka, forma




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


# --- мутации входов формы (код, не проза) ----------------------------------

def _forma(pack):
    return json.loads((pack / 'ekran.json').read_text(encoding='utf-8'))


def mut_shablon_otsvtstvuet(pack, repo, src):
    f = _forma(pack)
    del f['shablon']
    zapis(pack, f)


def mut_shablon_2_s_ga(pack, repo, src):
    f = _forma(pack)
    f['shablon'] = 2
    del f['dvizhenie']
    zapis(pack, f)


def mut_priemka_bez_prokhoda(pack, repo, src):
    f = _forma(pack)
    del f['priemka']['prokhod']
    zapis(pack, f)


def mut_prokhodimost_otsvtstvuet(pack, repo, src):
    f = _forma(pack)
    del f['prokhodimost']
    zapis(pack, f)


def mut_vtoroj_profil_otsvtstvuet(pack, repo, src):
    f = _forma(pack)
    del f['vtoroj_profil']
    zapis(pack, f)


def mut_maket_podmenen(pack, repo, src):
    # подмена байтов макета GA-03 в репо (пин в пачке не меняется)
    put = repo / 'docs/ux/04_Gespraech_D24/pack/screens/390x844/GA-03.png'
    blob = bytearray(put.read_bytes())
    blob[-8:] = b'\x00\x00\x00\x00' + blob[-8:-4]
    put.write_bytes(bytes(blob))


def mut_kadr_nizhe_poroga(pack, repo, src):
    # стенд-ин кладёт кадр GA-03 с залитой фоном полосой Mitte (мода
    # цвета сетки полосы) — свидетель ниже порога; замена стенд-ина,
    # не правка готового дерева: кадры кладёт ИСПОЛНЁННАЯ команда e2e
    postavit_standiny(repo, src, 'e2e_nizhe_poroga')


def mut_kadr_ustarevshij(pack, repo, src):
    # кадры положены ДО запуска (время сборки репо), команда e2e молчит:
    # байты равны дозапусковой ревизии — KADR_USTAREVSHIJ
    postavit_standiny(repo, src, 'e2e_molchit')
    import json as _json
    for imja in ('kadry.json', 'kadry_profil.json'):
        man = _json.loads((pack / imja).read_text(encoding='utf-8'))
        for k in man['kadry']:
            blob = (repo / k['maket']).read_bytes()
            d = repo / 'mobile/maestro-out-vkladki' / k['tema'] / 'aa' / 'bb' / 'takeScreenshot'
            d.mkdir(parents=True, exist_ok=True)
            (d / (k['snimok'] + '.png')).write_bytes(blob)


def mut_e2e_ne_proshla(pack, repo, src):
    postavit_standiny(repo, src, 'e2e_padaet')


def mut_chuzhoj_kadr(pack, repo, src):
    f = _forma(pack)
    f['kadry'] = 'kadry_chuzhie.json'
    zapis(pack, f)
    chuzhie = json.loads(json.dumps(src['kadry_manifest']))
    chuzhie['kadry'][0]['id'] = 'Fiktura-Kadr-Tot-Zhe'  # id живой пачки 132
    (pack / 'kadry_chuzhie.json').write_text(
        json.dumps(chuzhie, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_stroka_bez_izmenenija(pack, repo, src):
    f = _forma(pack)
    del f['prokhodimost']['pressable'][5]['izmenenie']
    zapis(pack, f)


def mut_kasanie_menshe_normy(pack, repo, src):
    f = _forma(pack)
    f['prokhodimost']['pressable'][2]['vysota'] = 36
    zapis(pack, f)


def mut_kasanie_v_safe_zone(pack, repo, src):
    f = _forma(pack)
    f['prokhodimost']['pressable'][2]['y'] = 40
    zapis(pack, f)


def mut_demo_v_sostave(pack, repo, src):
    f = _forma(pack)
    f['prokhodimost']['pressable'][0]['demo'] = True
    zapis(pack, f)


def mut_demo_bez_otdelenija(pack, repo, src):
    f = _forma(pack)
    f['prokhodimost']['demo'] = [{
        'id': 'demo-sostojanie', 'sostojanie': 'deistvie',
        'izmenenie': 'sostojanie.demo-toggl', 'shirina': 48, 'vysota': 48,
        'x': 17, 'y': 752, 'demo': True}]
    zapis(pack, f)
    # токен демо-цели — в флоу прохода (одна причина клетки: отделение)
    put = repo / 'mobile/.maestro/prokhod-vkladki.yaml'
    put.write_text(
        put.read_text(encoding='utf-8') + '- tapOn: { id: demo-sostojanie }\n',
        encoding='utf-8')


def mut_povtor_id(pack, repo, src):
    f = _forma(pack)
    f['prokhodimost']['pressable'][1]['id'] = f['prokhodimost']['pressable'][0]['id']
    zapis(pack, f)


def mut_profil_nizhe_minimuma(pack, repo, src):
    f = _forma(pack)
    f['vtoroj_profil']['shirina'] = 320
    f['vtoroj_profil']['vysota'] = 640
    zapis(pack, f)


def mut_profil_bez_insetov(pack, repo, src):
    f = _forma(pack)
    f['vtoroj_profil']['vyrez'] = 0
    zapis(pack, f)


def mut_odna_tema(pack, repo, src):
    profil = json.loads((pack / 'kadry_profil.json').read_text(encoding='utf-8'))
    profil['kadry'] = [k for k in profil['kadry'] if k['tema'] == 'dark']
    (pack / 'kadry_profil.json').write_text(
        json.dumps(profil, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_marshrut_bez_obolochki(pack, repo, src):
    put = repo / 'mobile/.maestro/vkladki-tabshell-393.yaml'
    put.write_text(
        put.read_text(encoding='utf-8').replace('- label: tabshell\n', ''),
        encoding='utf-8')


def mut_marshrut_bez_snimka(pack, repo, src):
    put = repo / 'mobile/.maestro/vkladki-tabshell-393.yaml'
    put.write_text(
        put.read_text(encoding='utf-8').replace(
            '- takeScreenshot: vkladki-post-393\n', ''),
        encoding='utf-8')


def mut_prokhod_ne_maestro(pack, repo, src):
    f = _forma(pack)
    f['priemka']['prokhod'] = 'true'
    zapis(pack, f)


def mut_prokhod_bez_pressable(pack, repo, src):
    put = repo / 'mobile/.maestro/prokhod-vkladki.yaml'
    put.write_text(
        put.read_text(encoding='utf-8').replace('- tapOn: { id: gespraech-mitte }\n', ''),
        encoding='utf-8')


def mut_prokhod_ne_proshla(pack, repo, src):
    (repo / 'mobile/e2e-vkladki/prokhod.sh').write_text(
        src['standiny']['prokhod_padaet'], encoding='utf-8')


def mut_literal_cveta(pack, repo, src):
    (pack / 'kontrakt.md').write_text(
        src['kontrakt_tekst'] + '\n<!-- акцент #0a0a0a -->\n', encoding='utf-8')


def mut_kljuch_bez_kataloga(pack, repo, src):
    f = _forma(pack)
    f['kljuchi_kopii'].append('ui.net.kljucha')
    zapis(pack, f)


def mut_scenarij_bez_snimka(pack, repo, src):
    put = repo / 'mobile/.maestro/vkladki.yaml'
    put.write_text(
        put.read_text(encoding='utf-8').replace(
            '- takeScreenshot: vkladki-post\n', ''),
        encoding='utf-8')


def mut_zony_rashodjatsja(pack, repo, src):
    (pack / 'kontrakt.md').write_text(
        src['kontrakt_tekst'].replace(
            'ЗОНА implementer: mobile/src/bootstrap/', 'ЗОНА implementer: mobile/src/api/'),
        encoding='utf-8')


def mut_perehod_lishnij(pack, repo, src):
    f = _forma(pack)
    f['dvizhenie']['perehody'] = ['GA-T28']
    zapis(pack, f)


def mut_istochnik_ne_sovpadaet(pack, repo, src):
    f = _forma(pack)
    f['dvizhenie']['spec_sha256'] = '0' * 64
    zapis(pack, f)


def mut_istochnik_otsutstvuet(pack, repo, src):
    f = _forma(pack)
    f['dvizhenie']['manifest'] = (
        'docs/ux/04_Gespraech_D24/pack/net-takogo-manifesta.json')
    zapis(pack, f)


MUTACII_FORMY = {
    'chestnyj-vkladki': None,
    'shablon-otsvtstvuet': mut_shablon_otsvtstvuet,
    'shablon-2-s-ga-kadrami': mut_shablon_2_s_ga,
    'priemka-bez-prokhoda': mut_priemka_bez_prokhoda,
    'prokhodimost-otsvtstvuet': mut_prokhodimost_otsvtstvuet,
    'vtoroj-profil-otsvtstvuet': mut_vtoroj_profil_otsvtstvuet,
    'maket-podmenen': mut_maket_podmenen,
    'kadr-nizhe-poroga': mut_kadr_nizhe_poroga,
    'kadr-ustarevshij': mut_kadr_ustarevshij,
    'e2e-ne-proshla': mut_e2e_ne_proshla,
    'chuzhoj-kadr': mut_chuzhoj_kadr,
    'stroka-bez-izmenenija': mut_stroka_bez_izmenenija,
    'kasanie-menshe-normy': mut_kasanie_menshe_normy,
    'kasanie-v-safe-zone': mut_kasanie_v_safe_zone,
    'demo-v-sostave': mut_demo_v_sostave,
    'demo-bez-otdelenija': mut_demo_bez_otdelenija,
    'povtor-id': mut_povtor_id,
    'profil-nizhe-minimuma': mut_profil_nizhe_minimuma,
    'profil-bez-insetov': mut_profil_bez_insetov,
    'odna-tema': mut_odna_tema,
    'marshrut-bez-obolochki': mut_marshrut_bez_obolochki,
    'marshrut-bez-snimka': mut_marshrut_bez_snimka,
    'prokhod-ne-maestro': mut_prokhod_ne_maestro,
    'prokhod-bez-pressable': mut_prokhod_bez_pressable,
    'prokhod-ne-proshla': mut_prokhod_ne_proshla,
    'literal-cveta': mut_literal_cveta,
    'kljuch-bez-kataloga': mut_kljuch_bez_kataloga,
    'scenarij-bez-snimka': mut_scenarij_bez_snimka,
    'zony-rashodjatsja': mut_zony_rashodjatsja,
    'perehod-lishnij': mut_perehod_lishnij,
    'istochnik-ne-sovpadaet': mut_istochnik_ne_sovpadaet,
    'istochnik-otsutstvuet': mut_istochnik_otsutstvuet,
}


# --- входы продукта (референсная раскладка + мутации кодом) ----------------

def sobrat_referens(src, tmp):
    """Референсное репо: раскладка + пачка (ekran_forma_prod + манифесты)."""
    repo = tmp / 'referens'
    shutil.copytree(RASKLADKA, repo)
    pachka = repo / 'mobile/e2e-vkladki'
    pachka.mkdir(parents=True)
    zapis(pachka, src['ekran_forma_prod'])
    (pachka / 'kadry.json').write_text(
        json.dumps(src['kadry_manifest'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pachka / 'kadry_profil.json').write_text(
        json.dumps(src['profil_kadry'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pachka / 'kontrakt.md').write_text(src['kontrakt_tekst'], encoding='utf-8')
    (pachka / 'katalog_kopii.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1), encoding='utf-8')
    (pachka / 'spec_api.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1), encoding='utf-8')
    b = pachka / 'batareja'
    b.mkdir()
    (b / 'red_ekrana.sh').write_text(src['batareja_tekst'], encoding='utf-8')
    return repo


def mut_pr_shov_net(repo, src):
    put = repo / 'mobile/src/bootstrap/tab-shell.tsx'
    tekst = put.read_text(encoding='utf-8')
    tekst = tekst.replace(
        '  readonly sectionScreens?: Readonly<Partial<Record<ShellSection, React.ReactNode>>>;\n',
        '').replace('  readonly mitte?: React.ReactNode;\n', '')
    put.write_text(tekst, encoding='utf-8')


def mut_pr_mitte_tab(repo, src):
    put = repo / 'mobile/src/bootstrap/gespraech-mitte.tsx'
    put.write_text(
        put.read_text(encoding='utf-8').replace(
            'accessibilityRole="button"', 'accessibilityRole="tab"'),
        encoding='utf-8')


def mut_pr_pachka_net(repo, src):
    shutil.rmtree(repo / 'mobile/e2e-vkladki')


def mut_pr_makety_piny(repo, src):
    pachka = repo / 'mobile/e2e-vkladki'
    man = json.loads((pachka / 'kadry.json').read_text(encoding='utf-8'))
    man['kadry'][0]['maket_sha256'] = '0' * 64
    (pachka / 'kadry.json').write_text(
        json.dumps(man, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_pr_kopii_net(repo, src):
    put = repo / 'mobile/src/i18n/ui-copy.ts'
    tekst = put.read_text(encoding='utf-8')
    for k in ('ui.vorgaenge.group.working', 'ui.vorgaenge.group.needs_you'):
        tekst = tekst.replace("  '%s': " % k, "  'udaljono.%s': " % k)
    put.write_text(tekst, encoding='utf-8')


def mut_pr_scenarij_net(repo, src):
    put = repo / 'mobile/.maestro/vkladki.yaml'
    put.write_text(
        put.read_text(encoding='utf-8').replace(
            '- takeScreenshot: vkladki-post\n', ''),
        encoding='utf-8')


def mut_pr_kontent_net(repo, src):
    (repo / 'mobile/src/features/post/components/PostEingang.tsx').unlink()


MUTACII_PRODUKTA = {
    'pr-chestnaja': None,
    'pr-shov-net': mut_pr_shov_net,
    'pr-mitte-tab': mut_pr_mitte_tab,
    'pr-pachka-net': mut_pr_pachka_net,
    'pr-makety-piny': mut_pr_makety_piny,
    'pr-kopii-net': mut_pr_kopii_net,
    'pr-scenarij-net': mut_pr_scenarij_net,
    'pr-kontent-net': mut_pr_kontent_net,
}


# --- суд входов -------------------------------------------------------------

def run_forma(subject, name, src):
    tmp = Path(tempfile.mkdtemp(prefix='vkladki148-f-'))
    try:
        repo, pachka, forma = build_forma_repo(src, tmp)
        if MUTACII_FORMY[name] is not None:
            MUTACII_FORMY[name](pachka, repo, src)
        p = subprocess.run(
            [sys.executable, str(subject), '--pack', str(pachka),
             '--repo', str(repo), '--harness', str(H_ROOT)],
            capture_output=True, text=True)
        return p.returncode, p.stdout, p.stderr
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def run_produkt(subject, name, src, repo_koren=None):
    """Суд продукта: subject — produkt_sud.py (или стаб); вход — собранный
    референс (+мутация) либо живой продукт repo_koren (только честный вход)."""
    tmp = Path(tempfile.mkdtemp(prefix='vkladki148-p-'))
    try:
        if repo_koren is not None:
            repo = Path(repo_koren).resolve()
        else:
            repo = sobrat_referens(src, tmp)
            if MUTACII_PRODUKTA[name] is not None:
                MUTACII_PRODUKTA[name](repo, src)
        p = subprocess.run(
            [sys.executable, str(subject), '--repo', str(repo)],
            capture_output=True, text=True, cwd=HERE)
        return p.returncode, p.stdout, p.stderr
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def stroka_shoditsja(exp_line, act_line, dopusk):
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


def vhody(src):
    return list(MUTACII_FORMY) + list(MUTACII_PRODUKTA)


def snapshot(src):
    data = {}
    for name in MUTACII_FORMY:
        rc, out, err = run_forma(MODEL_A, name, src)
        data[name] = {'rc': rc, 'stdout': out.splitlines(),
                      'prichiny': [l for l in err.splitlines()
                                   if l.startswith('PRICHINA\t')]}
    for name in MUTACII_PRODUKTA:
        rc, out, err = run_produkt(PRODUKT_SUD, name, src)
        data[name] = {'rc': rc, 'stdout': out.splitlines(),
                      'prichiny': [l for l in err.splitlines()
                                   if l.startswith('PRICHINA\t')]}
    print(json.dumps(data, ensure_ascii=False, indent=1))
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--snapshot', action='store_true')
    ap.add_argument('--repo', metavar='R')
    a = ap.parse_args()
    src = load_source()
    if a.snapshot:
        return snapshot(src)
    if not RUNNER123.is_file():
        print('SVERKA_123_ABSENT: раннер 123 не в дереве (инфраструктура)',
              file=sys.stderr)
        return 2
    matrica = a.stabs
    subject_a = MODEL_A if (a.model or matrica) else SUBJECT_A
    zelenyh, krasnyh = 0, 0
    for name in vhody(src):
        if name in MUTACII_FORMY:
            rc, out, err = run_forma(subject_a, name, src)
        else:
            # Субъект B: --model/--stabs — эталонная раскладка (мутанты
            # красны, честная зелена); --repo R — живой продукт (только
            # честный вход pr-chestnaja: краснота продукта видна в нём);
            # без флага и без --repo — дерево ХАРНЕССА как продукт-корень:
            # пачки/шва в нём нет → PACHKA_ABSENT (краснота до реализации).
            if a.repo:
                if name != 'pr-chestnaja':
                    continue
                rc, out, err = run_produkt(PRODUKT_SUD, name, src, a.repo)
            elif a.model or matrica:
                rc, out, err = run_produkt(PRODUKT_SUD, name, src)
            else:
                rc, out, err = run_produkt(PRODUKT_SUD, name, src, H_ROOT)
        problemy = judge(name, src, rc, out, err)
        if problemy:
            krasnyh += 1
            print('CASE %s KRASNO: %s' % (name, '; '.join(problemy)))
        else:
            zelenyh += 1
            print('CASE %s ok' % name)
    print('клеток %d, зелёных %d, красных %d'
          % (zelenyh + krasnyh, zelenyh, krasnyh))
    if not matrica:
        return 0 if krasnyh == 0 else 1
    # матрица стабов: каждый стаб на каждом входе своей записи stab_vhod
    zhivye, svjazi = 0, 0
    for stub, vh in sorted(src['stab_vhod'].items()):
        for v in vh:
            svjazi += 1
            if v in MUTACII_FORMY:
                rc, out, err = run_forma(STUBS / stub, v, src)
            else:
                rc, out, err = run_produkt(STUBS / stub, v, src)
            if judge(v, src, rc, out, err):
                print('STAB %s %s KRASEN' % (stub, v))
            else:
                zhivye += 1
                print('STAB %s %s PROSHYOL' % (stub, v))
    if zhivye:
        print('STAB_ZHIV: %d' % zhivye)
        return 1
    print('SVJAZI %d' % svjazi)
    return 0 if krasnyh == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
