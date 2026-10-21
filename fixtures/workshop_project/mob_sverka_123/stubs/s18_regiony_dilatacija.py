"""Стаб: мера v1 (круг 1) — регионы-компоненты чернил макета после дилатации 2
ячейки вместо объявленных элементов: подзаголовок сливается с заголовком,
футер — с CTA, крупная часть компенсирует пропажу малой (обход Critic123)."""
from _model import m, run

D = 2


def regions(mb, mask, mg, mera):
    gh, gw = len(mg), len(mg[0])
    occ = [[mask[i][j] and mg[i][j] > mera['region_porog'] for j in range(gw)] for i in range(gh)]
    dil = [[any(occ[ii][jj] for ii in range(max(0, i - D), min(gh, i + D + 1))
                for jj in range(max(0, j - D), min(gw, j + D + 1))) for j in range(gw)] for i in range(gh)]
    seen, out = set(), []
    for i in range(gh):
        for j in range(gw):
            if dil[i][j] and (i, j) not in seen:
                st, comp = [(i, j)], []
                seen.add((i, j))
                while st:
                    y, x = st.pop()
                    comp.append((y, x))
                    for yy, xx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                        if 0 <= yy < gh and 0 <= xx < gw and dil[yy][xx] and (yy, xx) not in seen:
                            seen.add((yy, xx))
                            st.append((yy, xx))
                ys, xs = [c[0] for c in comp], [c[1] for c in comp]
                out.append((min(ys), max(ys) + 1, min(xs), max(xs) + 1))
    return out


_orig_ink = m.ink_grid
_last = {}


def ink(img, mera):
    g = _orig_ink(img, mera)
    _last['mg'] = g  # второй вызов score_frame — макет
    return g


def scores(fb, mb, mask, k, mera):
    cell, marg = mera['kletka_pt'], mera['margin']
    gh, gw = len(mask), len(mask[0])
    out = []
    for (a, b, c, d) in regions(mb, mask, _last['mg'], mera):
        sub = [(i, j) for i in range(max(0, a - marg), min(gh, b + marg))
               for j in range(max(0, c - marg), min(gw, d + marg)) if mask[i][j]]
        out.append((f'{a * cell}-{b * cell}:{c * cell}-{d * cell}', m.dice(fb, mb, sub)))
    return out


m.ink_grid = ink
m.element_scores = scores
run()
