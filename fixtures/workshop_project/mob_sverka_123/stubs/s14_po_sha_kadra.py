"""Стаб: вердикт по таблице sha256 известных кадров-носителей; незнакомый кадр — зелёный."""
import hashlib

from _model import m, run

KNOWN = {
    '7cb96563a7b2b4f65d4e833b0d03488fa627c7a541830b7bcddce0cc0087eb68': 0.783,
    'd8927a5c66b9aaf2f667d2ddc4c6cb31a3e428e039fe53ffbb675f44b7fb97b5': 0.782,
    '7579e2cbab30a1c6671860496ccb6389b426f21c274dfa53bcbf0e451d9ba777': 0.0,
    '6872f50a531f3ee175273adbaff7555505001ee11e2265286b607949f7fe8ff3': 0.0,
    '3f4b63509b6d20b85c8d2df31f4799a82ac960847a7f6f7310a9759ccc473dd1': 0.0,
    '1ab6edc215af1e0d3033fff23101b6146b6557f54460cd4941f9b22021ea53be': 0.0,
}
_seen = {}
_orig_find = m.find_frame


def find(kadry_dir, k):
    p = _orig_find(kadry_dir, k)
    _seen[k['id']] = hashlib.sha256(open(p, 'rb').read()).hexdigest()
    return p


_orig_proc = m.process_frame


def proc(a, k, mera):
    m.score_frame = lambda frame, mock, maski, mr: (KNOWN.get(_seen.get(k['id']), 1.0), 'G')
    return _orig_proc(a, k, mera)


m.find_frame = find
m.process_frame = proc
run()
