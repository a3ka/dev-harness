#!/usr/bin/env python3
"""Батарея 123 (mob-sverka-maketa): мера похожести кадра e2e против PNG-макета.

Субъект — scripts/sverka_maketa.py харнесса (CLI --manifest M --kadry DIR
--repo R; вывод и коды — докстринг model/sverka_maketa.py). Батарея строит
каждый вход во временном каталоге раскладкой Maestro
(<kadry>/<тема>/<ts>/<flow>/takeScreenshot/<снимок>.png), репозиторий R —
копии макетов maket/ по пути maket_prefix, и судит ОДИН прогон субъекта на
вход: rc, множество отказов stderr ПОСТРОЧНО (PRICHINA<TAB>id — точное
равенство множеств; строка stderr вне грамматики — отказ), строки KADR
stdout (вердикт согласован с score/porog; score в допуске числа модели;
hudshij — имя пропавшего элемента, где kejsy его называет).
Оракул — source.json, загруженный В ПАМЯТЬ до вызова субъекта; манифесты H —
source.json manifesty (117: Splash dark/light; first-run-ekran: First-Run
dark/light), каждый вход судится одним из них; носители сверяются по sha256,
кадры с одним макетом несут одинаковые elementy, id кадров манифестов не
пересекаются, и на КАЖДЫЙ (макет, элемент) манифестов есть вход-свидетель его
пропажи (несовпадение — rc 2 ORACLE_TAMPERED).
Клетка ispolnenie=vne-prefiksa (класс «тесто-осведомлённый субъект», Adv123b)
строит вход vhod в каталоге со случайным именем под $TMPDIR (не sverka123-*),
исполняет субъект с cwd в нём, в чистом окружении (env -i, PATH=/usr/bin:/bin,
-B вместо PYTHONDONTWRITEBYTECODE) и судит тем же оракулом, что вход vhod.

Режимы: без флагов — субъект <H>/scripts/sverka_maketa.py (нет файла —
rc 1 SVERKA_ABSENT); --subject P; --model (эталон model/); --matrix —
контроль (модель зелена на всех входах) + каждый обманный стаб stubs/
КРАСЕН на КАЖДОМ своём входе stab_vhod, отдельным прогоном (стаб, прошедший
вход — rc 1 STAB_ZHIV). Выход — код возврата; перечень case построчно.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
H_ROOT = HERE.parents[2]
AW, AH = 390, 844
LINE_RE = re.compile(r'^([A-Z_]+)\t([^\t]+)(\t[^\t]*)?$')
KADR_RE = re.compile(r'^KADR\t([^\t]+)\t([0-9]+\.[0-9]{3})\t([0-9]+\.[0-9]{3})\t([^\t]+)\t(OK|NIZHE_POROGA)$')


class Tampered(Exception):
    pass


def load_source():
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    for rel, meta in src['nositeli'].items():
        p = HERE / rel
        if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest() != meta['sha256']:
            raise Tampered(rel)
    man = {}
    for nm, rel in src['manifesty'].items():  # 117 (Splash) и first-run-ekran (First-Run), оба из H
        man[nm] = json.loads((H_ROOT / rel).read_text(encoding='utf-8'))
        if man[nm].get('mera') != src['mera']:
            raise Tampered(f'{nm}: mera != source.json mera')
    vse = [k for nm in man for k in man[nm]['kadry']]
    if len({k['id'] for k in vse}) != len(vse):
        raise Tampered('id кадров манифестов пересекаются')
    pins = {Path(k).name: v['sha256'] for k, v in src['nositeli'].items() if k.startswith('maket/')}
    po_maketu = {}
    for k in vse:
        if pins.get(Path(k['maket']).name) != k['maket_sha256']:
            raise Tampered(f'pin {k["id"]}')
        if po_maketu.setdefault(k['maket'], k['elementy']) != k['elementy']:
            raise Tampered(f'elementy {k["id"]} != кадра с тем же макетом')
    for name, c in src['kejsy'].items():  # клетка вне префикса наследует оракул своего входа
        if 'ispolnenie' in c:
            base = src['kejsy'].get(c.get('vhod'))
            if c['ispolnenie'] != 'vne-prefiksa' or set(c) != {'vhod', 'ispolnenie'} or not base or 'ispolnenie' in base:
                raise Tampered(f'kejsy {name}: {c}')
            c.update({k: v for k, v in base.items() if k in ('rc', 'otkazy', 'hudshij')})
            if c['vhod'] in src['ozhidaemye_score']:
                src['ozhidaemye_score'][name] = src['ozhidaemye_score'][c['vhod']]
    # Полнота свидетелей: на КАЖДЫЙ (макет, элемент) манифеста — вход, где пропажа
    # ровно этого элемента даёт NIZHE_POROGA с hudshij = имя элемента.
    maket_of = {k['id']: k['maket'] for k in vse}
    want = {(mk, e['imja']) for mk, el in po_maketu.items() for e in el}
    got = {(maket_of[kid], el) for c in src['kejsy'].values() for kid, el in c.get('hudshij', {}).items()
           if c['otkazy'] == [f'NIZHE_POROGA\t{kid}']}
    if want != got:
        raise Tampered(f'свидетели пропажи: нет {sorted(want - got)}, лишние {sorted(got - want)}')
    for st, cs in src['stab_vhod'].items():
        if not cs or not set(cs) <= set(src['kejsy']):
            raise Tampered(f'stab_vhod {st}: {cs}')
    return src, man


# --- PNG собственными средствами проверяющего (не из субъекта) -------------

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
        if f == 2:  # Up: побайтовое сложение по модулю 256 без переноса между байтами
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


_DERIVED = {}


def derived(fn, *args):
    """Производный вход строится один раз на процесс батареи (детерминирован)."""
    key = (fn.__name__,) + tuple(hashlib.sha256(x).hexdigest() if isinstance(x, bytes) else x for x in args)
    if key not in _DERIVED:
        _DERIVED[key] = fn(*args)
    return _DERIVED[key]


def png_encode(w, h, rows):
    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    raw = b''.join(b'\x00' + bytes(r) for r in rows)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 1)) + chunk(b'IEND', b''))


# --- производные входы (детерминированы, строятся в памяти) ----------------

def derive_wordmark_1_01(blob):
    """Wordmark Splash light перекрашен в #f2f1ec на #f3f2ee (контраст 1,01:1)."""
    w, h, rows = png_decode(blob)
    x0, x1 = 144 * w // AW, 246 * w // AW
    y0, y1 = 498 * h // AH, 546 * h // AH
    for y in range(y0, y1):
        r = rows[y]
        for x in range(x0, x1):
            if max(abs(r[3 * x] - 243), abs(r[3 * x + 1] - 242), abs(r[3 * x + 2] - 238)) > 40:
                r[3 * x:3 * x + 3] = b'\xf2\xf1\xec'
    return png_encode(w, h, rows)


def derive_chrome_shum(blob):
    """Chrome залит белым: полоса статус-бара (верх 36 pt), жестовая полоса (низ
    20 pt) и плашка Demo в своей маске (4..52 x 46..72 pt) — маски обязаны держать."""
    w, h, rows = png_decode(blob)
    top, bot = 36 * h // AH, -(-(AH - 20) * h // AH)
    for y in list(range(0, top)) + list(range(bot, h)):
        rows[y] = bytearray(b'\xff' * (3 * w))
    x0, x1 = 4 * w // AW, 52 * w // AW
    for y in range(46 * h // AH, 72 * h // AH):
        rows[y][3 * x0:3 * x1] = b'\xff' * (3 * (x1 - x0))
    return png_encode(w, h, rows)


def derive_sdvig_i_ton(blob, d=3, ton=4):
    """Сдвиг кадра на d px вправо и вниз и тон +ton на канал (субпиксельный шум
    раскладки и цветопередачи эмулятора)."""
    w, h, rows = png_decode(blob)
    tab = bytes(min(255, v + ton) for v in range(256))
    rows = [r.translate(tab) for r in rows]
    bg = bytes(rows[h // 2][0:3])
    blank = bytearray(bg * w)
    out = [bytearray(blank) for _ in range(d)] + [bytearray(bg * d) + r[:3 * (w - d)] for r in rows[:h - d]]
    return png_encode(w, h, out)


def derive_maket_kak_kadr(mblob, invert, w=1080, h=2400):
    """Макет, растянутый в кадр устройства (ближайший сосед); invert — light-полярность."""
    mw, mh, mrows = png_decode(mblob)
    xi = [x * mw // w for x in range(w)]
    tab = bytes(255 - v for v in range(256))
    cache = {}
    out = []
    for y in range(h):
        sy = y * mh // h
        if sy not in cache:
            src = mrows[sy]
            row = bytearray(b''.join(bytes(src[3 * i:3 * i + 3]) for i in xi))
            cache[sy] = row.translate(tab) if invert else row
        out.append(cache[sy])
    return png_encode(w, h, out)


def derive_bez_elementa(blob, polosa_pt):
    """Полоса polosa_pt [x0,y0,x1,y1] pt залита фоном (мода цвета по сетке шага 8 px):
    элемент пропал целиком, остальное изображение не тронуто."""
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


# --- входы ------------------------------------------------------------------

def build_case(name, src, man, tmp):
    nos = {k: (HERE / k).read_bytes() for k in src['nositeli']}
    splash, firstrun = man['117'], man['first-run-ekran']  # настоящие манифесты H, без фильтра
    frames = {}
    sd, sl = nos['kadry/r1423-dark-vkhod-117-splash.png'], nos['kadry/r1423-light-vkhod-117-splash.png']
    fr = nos['maket/First-Run.png']
    manifest, mock_override = splash, {}
    if name == 'chestnyj-splash':
        frames = {('dark', 'vkhod-117-splash'): [sd], ('light', 'vkhod-117-splash'): [sl]}
    elif name in ('first-run-814', 'first-run-58d'):
        tag = 'r814' if name.endswith('814') else 'r58d'
        manifest = firstrun
        frames = {('dark', 'vkhod-117-first-run'): [nos[f'kadry/{tag}-dark-vkhod-117-first-run.png']],
                  ('light', 'vkhod-117-first-run'): [nos[f'kadry/{tag}-light-vkhod-117-first-run.png']]}
    elif name == 'pustoj-katalog':
        pass
    elif name == 'propusk-kadra':
        frames = {('dark', 'vkhod-117-splash'): [sd]}
    elif name == 'obrezannyj-kadr':  # кадр Splash dark обрезан вдвое: отказ кадра, light судится
        frames = {('dark', 'vkhod-117-splash'): [sd[:len(sd) // 2]], ('light', 'vkhod-117-splash'): [sl]}
    elif name == 'dubl-kadra':
        frames = {('dark', 'vkhod-117-splash'): [sd, sd], ('light', 'vkhod-117-splash'): [sl]}
    elif name == 'podmena-maketa':
        frames = {('dark', 'vkhod-117-splash'): [sd], ('light', 'vkhod-117-splash'): [sl]}
        mock_override = {'Splash.png': sd}
    elif name in ('maska-ves-kadr', 'porog-nol-v-manifeste', 'id-s-tabom', 'id-s-lf', 'snimok-glob', 'imja-s-tabom'):
        kk = json.loads(json.dumps(splash['kadry']))
        if name == 'maska-ves-kadr':
            kk[0]['maski_pt'] = [[0, 0, AW, AH]]
        elif name == 'porog-nol-v-manifeste':
            kk[0]['porog'] = 0
        elif name == 'id-s-tabom':  # байт-разделитель вывода внутри поля
            kk[0]['id'] = 'Splash\tdark'
        elif name == 'id-s-lf':  # хвостовой перевод строки — якорь терминатора
            kk[0]['id'] = 'Splash dark\n'
        elif name == 'imja-s-tabom':  # разделитель в имени худшего элемента (поле hudshij)
            kk[0]['elementy'][2]['imja'] = 'tagline\tx'
        else:  # метасимвол glob вместо имени снимка
            kk[0]['snimok'] = '*'
        manifest = dict(splash, kadry=kk)
        frames = {('dark', 'vkhod-117-splash'): [sd], ('light', 'vkhod-117-splash'): [sl]}
    elif name == 'wordmark-1-01':
        frames = {('dark', 'vkhod-117-splash'): [sd], ('light', 'vkhod-117-splash'): [derived(derive_wordmark_1_01, sl)]}
    elif name == 'chrome-shum':
        frames = {('dark', 'vkhod-117-splash'): [derived(derive_chrome_shum, sd)], ('light', 'vkhod-117-splash'): [sl]}
    elif name == 'chrome-shum-first-run':
        manifest = firstrun
        frames = {('dark', 'vkhod-117-first-run'): [derived(derive_chrome_shum, derived(derive_maket_kak_kadr, fr, False))],
                  ('light', 'vkhod-117-first-run'): [derived(derive_maket_kak_kadr, fr, True)]}
    elif name == 'sdvig-i-ton':
        frames = {('dark', 'vkhod-117-splash'): [derived(derive_sdvig_i_ton, sd)],
                  ('light', 'vkhod-117-splash'): [derived(derive_sdvig_i_ton, sl)]}
    elif name in ('maket-kak-kadr', 'element-ne-objavlen'):
        manifest = firstrun
        frames = {('dark', 'vkhod-117-first-run'): [derived(derive_maket_kak_kadr, fr, False)],
                  ('light', 'vkhod-117-first-run'): [derived(derive_maket_kak_kadr, fr, True)]}
        if name == 'element-ne-objavlen':  # макет несёт футер, манифест его не объявил
            kk = json.loads(json.dumps(firstrun['kadry']))
            k = next(k for k in kk if k['id'] == 'First-Run dark')
            k['elementy'] = [e for e in k['elementy'] if e['imja'] != 'futer']
            manifest = dict(firstrun, kadry=kk)
    elif name in src['svideteli']:  # пропажа ровно одного элемента в одном кадре своего манифеста
        sv = src['svideteli'][name]
        manifest = next(mf for mf in (splash, firstrun) if any(k['id'] == sv['kadr'] for k in mf['kadry']))
        if manifest is splash:
            frames = {('dark', 'vkhod-117-splash'): [sd], ('light', 'vkhod-117-splash'): [sl]}
        else:
            frames = {('dark', 'vkhod-117-first-run'): [derived(derive_maket_kak_kadr, fr, False)],
                      ('light', 'vkhod-117-first-run'): [derived(derive_maket_kak_kadr, fr, True)]}
        k = next(k for k in manifest['kadry'] if k['id'] == sv['kadr'])
        base = derived(derive_bez_elementa, nos[sv['osnova']], tuple(sv['polosa_pt']))
        if sv['osnova'].startswith('maket/'):
            base = derived(derive_maket_kak_kadr, base, k['tema'] == 'light')
        frames[(k['tema'], k['snimok'])] = [base]
    else:
        raise KeyError(name)
    kdir = tmp / 'kadry'
    kdir.mkdir()
    for (tema, snimok), blobs in frames.items():
        for n, blob in enumerate(blobs):
            d = kdir / tema / f'2026-10-21_00000{n}' / src['flow_dir'] / 'takeScreenshot'
            d.mkdir(parents=True, exist_ok=True)
            (d / f'{snimok}.png').write_bytes(blob)
    mdir = tmp / 'repo' / src['maket_prefix']
    mdir.mkdir(parents=True)
    for base in ('Splash.png', 'Splash-Hell.png', 'First-Run.png'):
        (mdir / base).write_bytes(mock_override.get(base, nos[f'maket/{base}']))
    mpath = tmp / 'manifest.json'
    mpath.write_text(json.dumps(manifest, ensure_ascii=False), encoding='utf-8')
    return mpath, kdir, tmp / 'repo', manifest


def judge(name, src, manifest, rc, out, err):
    exp = src['kejsy'][name]
    if rc != exp['rc']:
        return f'rc={rc} ожидался {exp["rc"]}'
    got = set()
    for ln in err.splitlines():
        m = LINE_RE.match(ln)
        if not m:
            return f'stderr вне грамматики: {ln[:80]!r}'
        got.add(f'{m.group(1)}\t{m.group(2)}')
    want = set(exp['otkazy'])
    if got != want:
        return f'отказы {sorted(got)} ожидались {sorted(want)}'
    for ln in out.splitlines():
        if not KADR_RE.match(ln):
            return f'stdout вне грамматики: {ln[:80]!r}'
    if exp['rc'] == 2:
        return None
    refused = {x.split('\t')[1] for x in want if not x.startswith('NIZHE_POROGA\t')}
    low = {x.split('\t')[1] for x in want if x.startswith('NIZHE_POROGA\t')}
    kadr = {}
    for ln in out.splitlines():
        m = KADR_RE.match(ln)
        if m:
            if m.group(1) in kadr:
                return f'KADR дважды: {m.group(1)}'
            kadr[m.group(1)] = (float(m.group(2)), float(m.group(3)), m.group(5))
            hud = exp.get('hudshij', {}).get(m.group(1))
            if hud is not None and m.group(4) != hud:  # пропавший элемент назван по имени
                return f'{m.group(1)}: hudshij {m.group(4)!r} ожидался {hud!r}'
    for k in manifest['kadry']:
        i = k['id']
        if i in refused:
            continue
        if i not in kadr:
            return f'нет строки KADR для {i}'
        score, porog, verdict = kadr[i]
        if abs(porog - float(k['porog'])) > 1e-9:
            return f'{i}: porog {porog} != манифест {k["porog"]}'
        if (verdict == 'OK') != (score >= porog) or (verdict != 'OK') != (i in low):
            return f'{i}: вердикт {verdict} при score={score} porog={porog}'
        expv = src['ozhidaemye_score'].get(name, {}).get(i)
        if expv is not None and abs(score - expv) > src['dopusk_score']:
            return f'{i}: score={score} вне допуска модели {expv}±{src["dopusk_score"]}'
    return None


def run_case(subject, name, src, man):
    exp = src['kejsy'][name]
    vne = exp.get('ispolnenie') == 'vne-prefiksa'
    with tempfile.TemporaryDirectory(prefix=None if vne else 'sverka123-') as t:
        if vne and 'sverka123-' in t:
            return f'каталог вне префикса несёт префикс батареи: {t}'
        mpath, kdir, repo, manifest = build_case(exp.get('vhod', name), src, man, Path(t))
        if vne:  # случайное имя под $TMPDIR, cwd в нём, env -i + минимальный PATH
            flags, cwd, env, subj = ['-B'], t, {'PATH': '/usr/bin:/bin'}, Path(subject).resolve()
        else:
            flags, cwd, env, subj = [], None, dict(os.environ, PYTHONDONTWRITEBYTECODE='1'), subject
        try:
            p = subprocess.run([sys.executable, *flags, str(subj), '--manifest', str(mpath), '--kadry', str(kdir),
                                '--repo', str(repo)], capture_output=True, text=True, timeout=120, env=env, cwd=cwd)
        except subprocess.TimeoutExpired:
            return 'TIMEOUT 120 с'
        return judge(name, src, manifest, p.returncode, p.stdout, p.stderr)


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group()
    g.add_argument('--subject')
    g.add_argument('--model', action='store_true')
    g.add_argument('--matrix', action='store_true')
    a = ap.parse_args()
    try:
        src, man = load_source()
    except (Tampered, OSError, ValueError, KeyError) as e:
        print(f'ORACLE_TAMPERED: {e}', file=sys.stderr)
        return 2
    cases = list(src['kejsy'])
    model = HERE / 'model' / 'sverka_maketa.py'
    if a.matrix:
        bad = 0
        for c in cases:
            why = run_case(model, c, src, man)
            print(f'CONTROL {c} {"ok" if why is None else "FAIL " + why}')
            bad += why is not None
        if bad:
            print(f'MATRIX_CONTROL_RED: {bad}', file=sys.stderr)
            return 1
        stubs = sorted((HERE / 'stubs').glob('s[0-9][0-9]_*.py'))
        if not stubs or {s.stem for s in stubs} != set(src['stab_vhod']):
            print(f'NOT_IMPLEMENTED: набор стабов {len(stubs)} != stab_vhod {len(src["stab_vhod"])}', file=sys.stderr)
            return 2
        alive = 0
        for s in stubs:
            for c in src['stab_vhod'][s.stem]:  # каждый вход красен СВОИМ прогоном
                why = run_case(s, c, src, man)
                print(f'STAB {s.stem} {c} {"KRASEN " + why if why else "ZHIV"}')
                alive += why is None
        if alive:
            print(f'STAB_ZHIV: {alive}', file=sys.stderr)
            return 1
        return 0
    subject = Path(a.subject) if a.subject else (model if a.model else H_ROOT / src['subject_rel'])
    if not subject.is_file():
        print(f'SVERKA_ABSENT: {subject}', file=sys.stderr)
        return 1
    bad = 0
    for c in cases:
        why = run_case(subject, c, src, man)
        print(f'CASE {c} {"ok" if why is None else "FAIL " + why}')
        bad += why is not None
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
