#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 135 (§ПРОВОДКА): судит пачку экрана first-run-ekran
# валидатором 132 (субъект scripts/ekran_shablon.py; эталон — замороженная
# батарея 132). Н-39: привязки стабов — stab_vhod source.json по коду ветвей.
"""Батарея 135 (first-run-ekran): экран First-Run + вход F03 по шаблону 132.

Предмет: экранная пачка first-run-ekran (ekran.json + контракт + манифест
восьми кадров + батарея) судится валидатором шаблона 132: кадры First-Run
(наследие кадрового манифеста батареи 123 — замена целиком) и вход F03
(F03.01/F03.02/F03.02-V01, PNG пакета Mobility Slice, доски A04/A05/A05e),
ключи копии — каталог BrokerOS_UI_Copy_DE.json verbatim, приёмка —
android-e2e rc 0 со СВЕЖИМИ кадрами Maestro-раскладки и сверка раннером 123
(мера/порог — его код и манифест пачки).

Режимы:
  (без флага)  субъект scripts/ekran_shablon.py; нет файла → rc 1 SHABLON_ABSENT
  --model      субъект model/ekran_shablon.py (эталон 132, читается не копируется)
  --stabs      контроль моделью всех входов + каждый обманный стаб отвергнут
               на КАЖДОМ входе своей записи stab_vhod source.json
  --snapshot   (инструмент замера) фактические rc/вывод эталона по каждому
               входу JSON-ом — числа для source.json из прогона, не из головы

Вывод: строка на вход `CASE <вход> ok|KRASNO`; --stabs добавляет строку на
связь `STAB <стаб> <вход> KRASEN`. rc: 0 — все входы зелёные (для --stabs:
контроль зелёный и все стабы пойманы); 1 — красный вход либо STAB_ZHIV;
2 — ORACLE_TAMPERED / SVERKA_123_ABSENT / нечем проверить.

Оракул — source.json (единый источник): kejsy (rc, prichiny построчно,
stdout построчно, допуск dopusk_score на числа KADR), stab_vhod (привязка
стабов к входам по коду ветвей, Н-39), nositeli (sha256 носителей — копии
реальных PNG-макетов продукта). Ожидания снимаются в память ДО вызова
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
FIKT = 'fixtures/workshop_project/ekran_shablon_132/model/fiktura'
D2 = 'docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens'
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
    scr = repo / D2
    scr.mkdir(parents=True)
    shutil.copyfile(HERE / 'nositeli/maket/First-Run.png', scr / 'First-Run.png')
    ms = repo / M1
    ms.mkdir(parents=True)
    for nm in ('F03.01', 'F03.02', 'F03.02-V01'):
        shutil.copyfile(HERE / ('nositeli/maket/' + nm + '.png'), ms / (nm + '.png'))
        shutil.copyfile(HERE / ('nositeli/maket/' + nm + '-Hell.png'),
                        ms / (nm + '-Hell.png'))
    ds = repo / 'docs/ux/03_Mobility_Slice1/ds'
    ds.mkdir(parents=True)
    (ds / 'tokens.css').write_text(src['tokens_audit'], encoding='utf-8')
    pak = repo / 'mobile/e2e-first-run'
    pak.mkdir(parents=True)
    (pak / 'katalog_kopii.json').write_text(
        json.dumps(src['katalog'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (pak / 'spec_api.json').write_text(
        json.dumps(src['spec'], ensure_ascii=False, indent=1), encoding='utf-8')
    ma = repo / 'mobile/.maestro'
    ma.mkdir(parents=True)
    (ma / 'first-run-ekran.yaml').write_text(src['flow'], encoding='utf-8')
    # stand-in android-e2e (replay) + носители записи: кадры в Maestro-раскладку
    # кладёт ИСПОЛНЕННАЯ команда priemka.e2e — стартуем с пустым kadry_dir
    (repo / 'mobile/e2e-first-run/e2e.sh').write_text(
        src['e2e_skript'], encoding='utf-8')
    for kadr in src['kadry_manifest']['kadry']:
        d = repo / 'mobile/e2e-nositeli' / kadr['tema']
        d.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(
            HERE / ('nositeli/kadry/%s-%s.png' % (kadr['tema'], slug(kadr['id']))),
            d / (kadr['snimok'] + '.png'))
    (repo / 'mobile/maestro-out-first-run').mkdir(parents=True)
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
    return pack, forma


def nositel(repo, tema, snimok):
    return repo / 'mobile/e2e-nositeli' / tema / (snimok + '.png')


# --- мутации входов (код, не проза; ожидания — kejsy source.json) ------------

def mut_literal_cveta(pack, forma, repo, src):
    p = pack / 'batareja/red_ekrana.sh'
    with p.open('a', encoding='utf-8') as f:
        f.write('\n# фон экрана хозяина: #F3F2EE\n')


def mut_kadr_nizhe_poroga(pack, forma, repo, src):
    f = nositel(repo, 'dark', 'first-run-ekran-f03-01')
    blob = derive_bez_elementa(f.read_bytes(), src['bez_elementa']['polosa_pt'])
    f.write_bytes(blob)


def mut_chuzhoj_kadr(pack, forma, repo, src):
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    chuzhoj = json.loads(json.dumps(m['kadry'][0]))
    chuzhoj['id'] = 'Fiktura-Kadr-Chuzhoj'
    m['kadry'].append(chuzhoj)
    (pack / 'kadry.json').write_text(
        json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')


def mut_ne_tselikom(pack, forma, repo, src):
    m = json.loads((pack / 'kadry.json').read_text(encoding='utf-8'))
    m['kadry'] = [k for k in m['kadry'] if k['id'] != 'First-Run light']
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
        ['bash', 'mobile/e2e-first-run/e2e.sh', 'first-run-ekran'],
        cwd=str(repo), capture_output=True, text=True)
    if zap.returncode != 0:
        raise RuntimeError('replay e2e: rc=%d %s' % (zap.returncode, zap.stderr))
    forma['priemka']['e2e'] = 'true'
    zapis(pack, forma)


def mut_e2e_ne_proshla(pack, forma, repo, src):
    forma['priemka']['e2e'] = 'bash mobile/e2e-first-run/e2e.sh net-takogo'
    zapis(pack, forma)


def mut_zhivaja_pachta_v_repo(pack, forma, repo, src):
    """Живая пачка ТОГО ЖЕ экрана в переданном продукте (--repo): полнота
    замены по живым пачкам --repo (мера 132) — замена неполна молча."""
    d = repo / 'fixtures/workshop_project/old_first_run_001'
    d.mkdir(parents=True)
    (d / 'ekran.json').write_text(json.dumps(
        src['repo_staryj_ekran']['ekran'], ensure_ascii=False, indent=1),
        encoding='utf-8')
    (d / 'kadry.json').write_text(json.dumps(
        src['repo_staryj_ekran']['kadry'], ensure_ascii=False, indent=1),
        encoding='utf-8')


MUTACII = {
    'chestnyj-ekran': None,
    'literal-cveta': mut_literal_cveta,
    'kadr-nizhe-poroga': mut_kadr_nizhe_poroga,
    'chuzhoj-kadr': mut_chuzhoj_kadr,
    'ne-tselikom': mut_ne_tselikom,
    'zamenjaet-pustoj': mut_zamenjaet_pustoj,
    'ne-trogaet-pustoj': mut_ne_trogaet_pustoj,
    'kontrakt-slishkom-dlinnyj': mut_kontrakt_slishkom_dlinnyj,
    'kontrakt-shirokij': mut_kontrakt_shirokij,
    'kadry-ustarevshie': mut_kadry_ustarevshie,
    'e2e-ne-proshla': mut_e2e_ne_proshla,
    'zhivaja-pachta-v-repo': mut_zhivaja_pachta_v_repo,
}


# --- суд входа ---------------------------------------------------------------

def run_subject(subject, name, src):
    tmp = Path(tempfile.mkdtemp(prefix='ekran135-'))
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
