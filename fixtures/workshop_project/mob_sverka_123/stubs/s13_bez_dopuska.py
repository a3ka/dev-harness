"""Стаб: попиксельное равенство без допуска — доля пикселей чернил макета, чей
пиксель кадра (ближайший сосед) совпадает цветом ТОЧНО."""
from _model import m, run


def score(frame, mock, maski, mera):
    fw, fh, fn, frows = frame
    mw, mh, mn, mrows = mock
    bg = m.background(*mock, mera['fon_shag'])
    hit = tot = 0
    for y in range(mh):
        mr, fr = mrows[y], frows[y * fh // mh]
        for x in range(mw):
            p = tuple(mr[x * mn:x * mn + 3])
            if max(abs(p[c] - bg[c]) for c in range(3)) > mera['chernila_T']:
                tot += 1
                fx = x * fw // mw
                hit += tuple(fr[fx * fn:fx * fn + 3]) == p
    return (hit / tot if tot else 1.0), 'G'


m.score_frame = score
run()
