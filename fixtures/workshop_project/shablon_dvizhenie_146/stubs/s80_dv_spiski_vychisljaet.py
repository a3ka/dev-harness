"""Стаб s80 (Crit146c, матрица dv): недекларированные списки блока
dvizhenie молча ВЫЧИСЛЯЮТСЯ из пиннованных источников (ekrany — GA-якоря
кадров, perehody — ∩-правило манифеста, sceny_znaka — пересечение с
поз-оракулом, etalony — синтез валидных hex-пинов по files спеки) —
«субъект, не требующий деклараций». Клетки
matrica-dv-{ekrany,perehody,sceny_znaka,etalony}-udalen ловят; на
честном входе декларации уже есть — вычислять нечего."""
import copy
import json

from _model import m, run

_staryj = m.check_dvizhenie


def _vychisljaet(f, repo, kadry):
    f = copy.deepcopy(f)
    dv = f.get('dvizhenie')
    if isinstance(dv, dict) and {'manifest', 'spec', 'pozvonok'} <= set(dv):
        try:
            man = json.loads((repo / dv['manifest']).read_text(
                encoding='utf-8'))
            spc = json.loads((repo / dv['spec']).read_text(
                encoding='utf-8'))
            poz = json.loads((repo / dv['pozvonok']).read_text(
                encoding='utf-8'))
        except (OSError, ValueError):
            return _staryj(f, repo, kadry)
        if 'ekrany' not in dv:
            dv['ekrany'] = m.d24_ekrany(kadry)
        if 'perehody' not in dv:
            ek = set(dv['ekrany'])
            dv['perehody'] = sorted(
                x['id'] for x in man['motion'] if set(x['frames']) & ek)
        if 'sceny_znaka' not in dv:
            dv['sceny_znaka'] = sorted(
                set(dv['perehody']) & set(poz['scenes']))
        if 'etalony' not in dv:
            sceny = {s['id']: s for s in spc['scenes']}
            et = {}
            for pid in dv['perehody']:
                sc = sceny.get(pid, {})
                fajly = sc.get('files', {})
                et[pid] = {
                    'video': {t: '0' * 64
                              for t in fajly.get('video', {})},
                    'keyframes': {
                        t: ['0' * 64] * len(sp)
                        for t, sp in fajly.get('keyframes', {}).items()}}
            dv['etalony'] = et
    return _staryj(f, repo, kadry)


m.check_dvizhenie = _vychisljaet
run()
