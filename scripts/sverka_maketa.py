#!/usr/bin/env python3
"""Модель меры 123 (mob-sverka-maketa): сверка кадров e2e с PNG-макетом.

Эталон поведения для батареи probe.py (--model); реализация предмета —
scripts/sverka_maketa.py харнесса (ЗОНА implementer), тот же CLI и вывод.

Мера кадра (параметры — source.json "mera", единый источник; элементы и
маски — манифест H, поле кадра):
  1. PNG декодируется чистым stdlib (zlib+struct): 8 бит, тип 2/6, без
     interlace; иначе KADR_NECHITAEM (кадр) / MANIFEST_NEVEREN (макет).
  2. Фон изображения — мода цвета по выборке пикселей (x, y), x и y кратны
     fon_shag (ничья — меньший кортеж RGB). Чернила — пиксель, у которого
     max|канал-фон| > chernila_T (полярность-инвариантно: light-кадр
     сверяется с тёмным макетом по раскладке, контраст 1,01:1 чернилами НЕ
     считается).
  3. Сетка артборда 390x844 pt ячейкой kletka_pt: 390//6 = 65 столбцов,
     844//6 = 140 строк; остаток 844-840 = 4 pt снизу вне сетки (и под
     маской низа). Граница ячейки в пикселях изображения w x h:
     xs[j] = round(j*kletka_pt*w/390), ys[i] = round(i*kletka_pt*h/844),
     round — Python (половина к чётному); ячейка = доля пикселей чернил в
     [xs[j], xs[j+1]) x [ys[i], ys[i+1]). Кадр 1080x2400 и макет 390x844 —
     в те же ячейки.
  4. Маски: строка ячеек i снята, если i*6 < chrome_verh_pt или
     (i+1)*6 > 844 - chrome_niz_pt; ячейка снята, если пересекает
     прямоугольник maski_pt [x0,y0,x1,y1] положительной площадью (строгие
     неравенства x0 < (j+1)*6, x1 > j*6, то же по y). Снятая ячейка — 0 в
     обоих полях и вне суда.
  5. Размытие ящиком (2r+1)^2, r = razmytie_r: сумма по соседям внутри сетки
     (снятые — 0), делитель всегда (2r+1)^2. Dice = 2*sum(min)/(sum a +
     sum b) по перечню ячеек; знаменатель 0 — 1,0.
  6. Элементы макета — поле кадра "elementy" манифеста H: имя и bbox_pt
     [x0,y0,x1,y1]. Ячейки элемента — ячейки, пересекающие bbox (правило
     п. 4), расширенные на margin ячеек и ограниченные немаскированными;
     слияния элементов нет — каждый судится своим Dice. Покрытие: каждая
     немаскированная ячейка макета с долей чернил > region_porog обязана
     лежать в ячейках (без margin) хотя бы одного элемента, иначе
     MANIFEST_NEVEREN (rc 2) — необъявленный элемент макета не судится
     молча одним G.
  7. score = min(G, элементы), G — Dice по всем немаскированным ячейкам;
     hudshij — имя первого минимального ('G', затем элементы в порядке
     манифеста). Пропажа элемента обнуляет его Dice (0 чернил кадра в его
     ячейках), крупный соседний элемент её не компенсирует.
  8. Немаскированных ячеек < min_dolja_suda поля — PUSTAYA_SVERKA (rc 2).

CLI: sverka_maketa.py --manifest M --kadry DIR --repo R
Вывод: stdout — строка на объявленный кадр
  KADR<TAB>id<TAB>score<TAB>porog<TAB>hudshij<TAB>OK|NIZHE_POROGA
stderr — строка на отказ: PRICHINA<TAB>id[<TAB>подробности]; NIZHE_POROGA
называет худший элемент (hudshij=имя).
rc: 0 — все кадры есть и score >= porog; 1 — NIZHE_POROGA / KADR_OTSUTSTVUET /
KADR_NEODNOZNACHEN / KADR_NECHITAEM / MAKET_PODMENEN; 2 — MANIFEST_NEVEREN /
PUSTAYA_SVERKA.
"""
import argparse
import collections
import glob
import hashlib
import json
import os
import re
import struct
import sys
import zlib

AW, AH = 390, 844
# Якорь терминатора — \A…\Z: «$» пропускает хвостовой \n (урок 121, круг 3).
ID_RE = re.compile(r'\A[A-Za-z0-9._-]+( [A-Za-z0-9._-]+)*\Z')
SHOT_RE = re.compile(r'\A[A-Za-z0-9._-]+\Z')
# Имя элемента — строчный алфавит: 'G' (всё поле) вне его, коллизии нет.
ELEM_RE = re.compile(r'\A[a-z0-9-]+\Z')
THEME_RE = re.compile(r'\A(dark|light)\Z')
SHA_RE = re.compile(r'\A[0-9a-f]{64}\Z')


class Refusal(Exception):
    def __init__(self, reason, ident, detail=''):
        super().__init__(reason)
        self.reason, self.ident, self.detail = reason, ident, detail


def decode_png(blob):
    """PNG -> (w, h, nch, rows: list[bytes]); ValueError — неподдержанный/битый."""
    if blob[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('signature')
    pos, idat, ihdr = 8, bytearray(), None
    while pos + 8 <= len(blob):
        ln, = struct.unpack('>I', blob[pos:pos + 4])
        typ = blob[pos + 4:pos + 8]
        data = blob[pos + 8:pos + 8 + ln]
        crc, = struct.unpack('>I', blob[pos + 8 + ln:pos + 12 + ln])
        if zlib.crc32(typ + data) & 0xffffffff != crc:
            raise ValueError('crc')
        if typ == b'IHDR':
            ihdr = struct.unpack('>IIBBBBB', data)
        elif typ == b'IDAT':
            idat += data
        elif typ == b'IEND':
            break
        pos += 12 + ln
    if ihdr is None:
        raise ValueError('ihdr')
    w, h, depth, color, _, _, inter = ihdr
    if depth != 8 or color not in (2, 6) or inter != 0:
        raise ValueError('mode')
    nch = 3 if color == 2 else 4
    stride = w * nch
    raw = zlib.decompress(bytes(idat))
    if len(raw) != h * (stride + 1):
        raise ValueError('len')
    rows, prev = [], bytes(stride)
    lo = int.from_bytes(b'\x7f' * stride, 'big')
    hi = int.from_bytes(b'\x80' * stride, 'big')
    for y in range(h):
        f = raw[y * (stride + 1)]
        line = raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)]
        if f == 0:
            cur = bytes(line)
        elif f == 2:
            a, b = int.from_bytes(line, 'big'), int.from_bytes(prev, 'big')
            cur = ((((a & lo) + (b & lo)) ^ ((a ^ b) & hi))).to_bytes(stride, 'big')
        elif f in (1, 3, 4):
            out = bytearray(line)
            for i in range(stride):
                left = out[i - nch] if i >= nch else 0
                up = prev[i]
                if f == 1:
                    out[i] = (out[i] + left) & 255
                elif f == 3:
                    out[i] = (out[i] + ((left + up) >> 1)) & 255
                else:
                    ul = prev[i - nch] if i >= nch else 0
                    p = left + up - ul
                    pa, pb, pc = abs(p - left), abs(p - up), abs(p - ul)
                    pr = left if pa <= pb and pa <= pc else (up if pb <= pc else ul)
                    out[i] = (out[i] + pr) & 255
            cur = bytes(out)
        else:
            raise ValueError('filter')
        rows.append(cur)
        prev = cur
    return w, h, nch, rows


def background(w, h, nch, rows, step):
    c = collections.Counter()
    for y in range(0, h, step):
        r = rows[y]
        for x in range(0, w, step):
            c[tuple(r[x * nch:x * nch + 3])] += 1
    best = max(c.values())
    return min(k for k, v in c.items() if v == best)


def ink_grid(img, mera):
    w, h, nch, rows = img
    T, cell = mera['chernila_T'], mera['kletka_pt']
    bg = background(w, h, nch, rows, mera['fon_shag'])
    tabs = [bytes(1 if abs(v - bg[c]) > T else 0 for v in range(256)) for c in range(3)]
    gw, gh = AW // cell, AH // cell
    xs = [round(j * cell * w / AW) for j in range(gw + 1)]
    ys = [round(i * cell * h / AH) for i in range(gh + 1)]
    grid = []
    for i in range(gh):
        cnt = [0] * gw
        for y in range(ys[i], ys[i + 1]):
            r = rows[y]
            ch = [r[c::nch].translate(tabs[c]) for c in range(3)]
            ink = (int.from_bytes(ch[0], 'big') | int.from_bytes(ch[1], 'big')
                   | int.from_bytes(ch[2], 'big')).to_bytes(w, 'big')
            for j in range(gw):
                cnt[j] += ink.count(1, xs[j], xs[j + 1])
        grid.append([cnt[j] / max(1, (xs[j + 1] - xs[j]) * (ys[i + 1] - ys[i])) for j in range(gw)])
    return grid


def court_mask(mera, maski_pt):
    cell = mera['kletka_pt']
    gw, gh = AW // cell, AH // cell
    m = [[True] * gw for _ in range(gh)]
    for i in range(gh):
        y0, y1 = i * cell, (i + 1) * cell
        if y0 < mera['chrome_verh_pt'] or y1 > AH - mera['chrome_niz_pt']:
            m[i] = [False] * gw
            continue
        for j in range(gw):
            x0, x1 = j * cell, (j + 1) * cell
            for (a, b, c, d) in maski_pt:
                if x0 < c and x1 > a and y0 < d and y1 > b:
                    m[i][j] = False
    return m


def blur(g, m, r):
    gh, gw = len(g), len(g[0])
    out = [[0.0] * gw for _ in range(gh)]
    k = (2 * r + 1) ** 2
    for i in range(gh):
        for j in range(gw):
            s = 0.0
            for di in range(-r, r + 1):
                for dj in range(-r, r + 1):
                    ii, jj = i + di, j + dj
                    if 0 <= ii < gh and 0 <= jj < gw and m[ii][jj]:
                        s += g[ii][jj]
            out[i][j] = s / k
    return out


def dice(a, b, cells):
    num = den = 0.0
    for (i, j) in cells:
        num += min(a[i][j], b[i][j])
        den += a[i][j] + b[i][j]
    return 2 * num / den if den else 1.0


def element_cells(box, m, mera, marg):
    """Немаскированные ячейки, пересекающие bbox [x0,y0,x1,y1] pt положительной
    площадью (правило масок), прямоугольник расширен на marg ячеек."""
    cell = mera['kletka_pt']
    gh, gw = len(m), len(m[0])
    x0, y0, x1, y1 = box
    rows = [i for i in range(gh) if i * cell < y1 and (i + 1) * cell > y0]
    cols = [j for j in range(gw) if j * cell < x1 and (j + 1) * cell > x0]
    if not rows or not cols:
        return []
    return [(i, j) for i in range(max(0, rows[0] - marg), min(gh, rows[-1] + marg + 1))
            for j in range(max(0, cols[0] - marg), min(gw, cols[-1] + marg + 1)) if m[i][j]]


def check_pokrytie(mg, m, k, mera):
    """Каждая немаскированная ячейка макета с чернилами > region_porog лежит в
    ячейках (без margin) хотя бы одного объявленного элемента."""
    covered = set()
    for e in k['elementy']:
        covered.update(element_cells(e['bbox_pt'], m, mera, 0))
    cell = mera['kletka_pt']
    for i, row in enumerate(mg):
        for j, v in enumerate(row):
            if m[i][j] and v > mera['region_porog'] and (i, j) not in covered:
                raise Refusal('MANIFEST_NEVEREN', '', f'pokrytie x={j * cell} y={i * cell}')


def element_scores(fb, mb, m, k, mera):
    """Dice каждого элемента по своим ячейкам — без слияния с соседями."""
    return [(e['imja'], dice(fb, mb, element_cells(e['bbox_pt'], m, mera, mera['margin'])))
            for e in k['elementy']]


def score_frame(frame_img, mock_img, k, mera):
    m = court_mask(mera, k.get('maski_pt', []))
    gh, gw = len(m), len(m[0])
    cells = [(i, j) for i in range(gh) for j in range(gw) if m[i][j]]
    if len(cells) < mera['min_dolja_suda'] * gh * gw:
        raise Refusal('PUSTAYA_SVERKA', '', f'cells={len(cells)}')
    fg, mg = ink_grid(frame_img, mera), ink_grid(mock_img, mera)
    check_pokrytie(mg, m, k, mera)
    r = mera['razmytie_r']
    fb, mb = blur(fg, m, r), blur(mg, m, r)
    scores = [('G', dice(fb, mb, cells))] + element_scores(fb, mb, m, k, mera)
    worst = min(scores, key=lambda t: t[1])
    return worst[1], worst[0]


def load_manifest(path):
    try:
        man = json.load(open(path, encoding='utf-8'))
        mera, kadry = man['mera'], man['kadry']
        assert isinstance(kadry, list) and kadry
        ids = set()
        for k in kadry:
            assert ID_RE.match(k['id']) and k['id'] not in ids
            ids.add(k['id'])
            assert THEME_RE.match(k['tema']) and SHOT_RE.match(k['snimok'])
            assert SHA_RE.match(k['maket_sha256']) and not os.path.isabs(k['maket'])
            assert '..' not in k['maket'].split('/')
            assert 0 < float(k['porog']) <= 1
            for q in k.get('maski_pt', []):
                assert len(q) == 4 and q[0] < q[2] and q[1] < q[3]
            assert isinstance(k['elementy'], list) and k['elementy']
            names = set()
            for e in k['elementy']:
                assert ELEM_RE.match(e['imja']) and e['imja'] not in names
                names.add(e['imja'])
                q = e['bbox_pt']
                assert len(q) == 4 and q[0] < q[2] and q[1] < q[3]
        return mera, kadry
    except Exception as e:  # noqa: BLE001 — любой дефект манифеста именован
        raise Refusal('MANIFEST_NEVEREN', '', type(e).__name__)


def find_frame(kadry_dir, k):
    pat = os.path.join(glob.escape(kadry_dir), k['tema'], '*', '*', 'takeScreenshot', k['snimok'] + '.png')
    hits = sorted(glob.glob(pat))
    if not hits:
        raise Refusal('KADR_OTSUTSTVUET', k['id'])
    if len(hits) > 1:
        raise Refusal('KADR_NEODNOZNACHEN', k['id'], str(len(hits)))
    return hits[0]


def report(reason, ident, detail=''):
    print(f'{reason}\t{ident}\t{detail}', file=sys.stderr)


def check_pin(mblob, k):
    if hashlib.sha256(mblob).hexdigest() != k['maket_sha256']:
        raise Refusal('MAKET_PODMENEN', k['id'], 'sha256')


def process_frame(a, k, mera):
    """Суд одного объявленного кадра: 0 — OK, 1 — NIZHE_POROGA; Refusal — отказ."""
    try:
        mblob = open(os.path.join(a.repo, k['maket']), 'rb').read()
    except OSError:
        raise Refusal('MAKET_PODMENEN', k['id'], 'absent')
    check_pin(mblob, k)
    mock = decode_png(mblob)
    fblob = open(find_frame(a.kadry, k), 'rb').read()
    try:
        frame = decode_png(fblob)
    except (ValueError, zlib.error) as e:
        raise Refusal('KADR_NECHITAEM', k['id'], str(e))
    score, worst = score_frame(frame, mock, k, mera)
    porog = float(k['porog'])
    verdict = 'OK' if score >= porog else 'NIZHE_POROGA'
    print(f'KADR\t{k["id"]}\t{score:.3f}\t{porog:.3f}\t{worst}\t{verdict}')
    if verdict == 'OK':
        return 0
    report('NIZHE_POROGA', k['id'], f'score={score:.3f} porog={porog:.3f} hudshij={worst}')
    return 1


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument('--manifest', required=True)
    ap.add_argument('--kadry', required=True)
    ap.add_argument('--repo', required=True)
    a = ap.parse_args(argv)
    try:
        mera, kadry = load_manifest(a.manifest)
    except Refusal as r:
        report(r.reason, '-', r.detail)
        return 2
    rc = 0
    for k in kadry:
        try:
            rc = max(rc, process_frame(a, k, mera))
        except Refusal as r:
            report(r.reason, r.ident or k['id'], r.detail)
            rc = max(rc, 2 if r.reason in ('PUSTAYA_SVERKA', 'MANIFEST_NEVEREN') else 1)
    return rc


if __name__ == '__main__':
    sys.exit(main())
