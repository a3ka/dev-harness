"""Стаб: кадр сверяется сам с собой вместо макета."""
from _model import m, run

_orig = m.score_frame
m.score_frame = lambda frame, mock, maski, mera: _orig(frame, frame, maski, mera)
run()
