"""Стаб: при двух кадрах с одним именем берётся первый (неоднозначность не отказ)."""
import glob
import os

from _model import m, run


def find(kadry_dir, k):
    pat = os.path.join(glob.escape(kadry_dir), k['tema'], '*', '*', 'takeScreenshot', k['snimok'] + '.png')
    hits = sorted(glob.glob(pat))
    if not hits:
        raise m.Refusal('KADR_OTSUTSTVUET', k['id'])
    return hits[0]


m.find_frame = find
run()
