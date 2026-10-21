"""Стаб: сверка только пропорций кадра и цвета фона (состав не судится)."""
from _model import m, run


def score(frame, mock, maski, mera):
    fa, ma = frame[0] / frame[1], mock[0] / mock[1]
    fb = m.background(*frame, mera['fon_shag'])
    mb = m.background(*mock, mera['fon_shag'])
    same_bg = max(abs(x - y) for x, y in zip(fb, mb)) <= mera['chernila_T']
    return (1.0 if abs(fa - ma) / ma <= 0.05 and same_bg else 0.0), 'G'


m.score_frame = score
run()
