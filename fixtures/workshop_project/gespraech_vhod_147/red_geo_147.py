#!/usr/bin/env python3
"""147 v+6: только геометрия T28/29/30/31/33, не запуск продукта.
Коды возврата: 0 — клетки/адресные стабы зелены; 1 — расхождение;
2 — источник/рантайм отсутствует или оракул повреждён.
CLI: --model | --stabs | --repo R | --spec P (явный spec-субъект).
Оракул Kompakt и исходный frozen-spec снимаются в память ДО субъекта.
Привязки Final2-стабов к наблюдаемым ветвям — STABS, не проза контракта.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
IDS = ('GA-T28', 'GA-T29', 'GA-T30', 'GA-T31', 'GA-T33')
STABS = {
    'geo-final2-t28': 'GA-T28',
    'geo-final2-t29': 'GA-T29',
    'geo-final2-t30': 'GA-T30',
    'geo-final2-t31': 'GA-T31',
    'geo-final2-t33': 'GA-T33',
}
BASE_PATH = 'fixtures/workshop_project/gespraech_vhod_147/nositeli/d24/spec.json'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def oracle():
    pins = json.loads((HERE / 'piny.json').read_text())['dvizhenie']
    raw = {}
    for name, expected in pins['sha256'].items():
        raw[name] = (HERE / name).read_bytes()
        if digest(raw[name]) != expected:
            raise ValueError('ORACLE_TAMPERED ' + name)
    geometry = json.loads(raw['nositeli/kompakt11/geometrija-147.json'])
    if tuple(geometry['scenes']) != IDS:
        raise ValueError('ORACLE_TAMPERED переходы')
    delta = raw['nositeli/kompakt11/motion-delta.md']
    if digest(delta) != geometry['source']['delta_sha256']:
        raise ValueError('ORACLE_TAMPERED delta')
    old = subprocess.run(['git', 'show', 'frozen/contracts/147/4:' + BASE_PATH],
                         cwd=ROOT, capture_output=True, check=True).stdout
    if digest(old) != pins['base_spec_sha256']:
        raise ValueError('ORACLE_TAMPERED frozen-spec')
    return geometry, json.loads(old), pins


def nongeometry(spec):
    """Снимается только разрешённая геометрия; времена/позы/чужие сцены целы."""
    result = copy.deepcopy(spec)
    for scene in result['scenes']:
        if scene['id'] not in IDS:
            continue
        if scene['id'] in ('GA-T28', 'GA-T29'):
            scene.pop('notes', None)
        for track in scene['tracks']:
            if track.get('property') in ('left', 'top', 'w', 'h'):
                # Символические from/to НЕ снимаются: чужой rect красен.
                track.pop('resolved', None)
        a = scene.get('adaptive')
        if not a:
            continue
        for key in ('rule', 'top', 'caps'):
            a.pop(key, None)
        for row in a.get('timeline', []) + [a.get('end', {})]:
            for key in ('P', 'P_from', 'P_to', 'S', 'S_from', 'S_to', 'cap', 'x', 'y'):
                row.pop(key, None)
    return result


def run(spec, out):
    argv = ['node', str(HERE / 'model/dvizhenie-runner.mjs'),
            '--machine', str(HERE / 'model/menu-machine.ts'),
            '--geometry', str(HERE / 'nositeli/kompakt11/geometrija-147.json'),
            '--spec', str(spec), '--json', '--outputFile', str(out)]
    proc = subprocess.run(argv, capture_output=True, text=True, timeout=120)
    if proc.returncode not in (0, 1):
        raise ValueError('RUNNER_NE_ZAPUSCHEN ' + proc.stderr)
    report = json.loads(out.read_text())
    tests = [test for suite in report['testResults']
             for test in suite['assertionResults']]
    geometry = {test['title'].split(' — ', 1)[0].removeprefix('geometry-'):
                test for test in tests if test['title'].startswith('geometry-')}
    timing = [test for test in tests if not test['title'].startswith('geometry-')]
    if set(geometry) != set(IDS) or not timing:
        raise ValueError('RUNNER_NE_POLON')
    return geometry, timing


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path)
    group.add_argument('--spec', type=Path)
    args = parser.parse_args()
    expected, old, pins = oracle()
    if args.repo:
        for name in ('motion-delta.md', 'geometrija-147.json'):
            path = args.repo / 'docs/ux/05_Kompakt_D24/motion' / name
            if not path.is_file():
                raise ValueError('ISTOCHNIK_OTSVTSTVUET ' + str(path))
            if digest(path.read_bytes()) != pins['sha256']['nositeli/kompakt11/' + name]:
                print('ISTOCHNIK_NE_SOVPADAET', str(path))
                return 1
    subject = (args.repo / expected['spec_path'] if args.repo else
               args.spec if args.spec else HERE / 'nositeli/d24/spec.json')
    if not subject.is_file():
        raise ValueError('ISTOCHNIK_OTSVTSTVUET ' + str(subject))
    actual = json.loads(subject.read_bytes())
    with tempfile.TemporaryDirectory(prefix='geo147-') as tmp:
        tmp = Path(tmp)
        geo, timing = run(subject.resolve(), tmp / 'report.json')
        red = 0
        for tid in IDS:
            ok = geo[tid]['status'] == 'passed'
            red += not ok
            print('CASE geometry-' + tid, 'ok' if ok else 'KRASNO',
                  '; '.join(geo[tid].get('failureMessages', [])))
        timing_ok = all(test['status'] == 'passed' for test in timing)
        unchanged = nongeometry(actual) == nongeometry(old)
        red += not timing_ok
        red += not unchanged
        print('CASE timing-curves-reduced', 'ok' if timing_ok else 'KRASNO',
              'rules=' + str(len(timing)))
        print('CASE inherited-obligations', 'ok' if unchanged else 'KRASNO',
              'scenes=' + str(len(old['scenes'])) + ' tokens/poses/frames unchanged')
        # Честная эквивалентная запись: другой порядок JSON-ключей/пробелы.
        equivalent = tmp / 'equivalent.json'
        equivalent.write_text(json.dumps(actual, sort_keys=True, indent=2))
        eq_geo, eq_timing = run(equivalent, tmp / 'equivalent-report.json')
        equivalent_ok = (all(test['status'] == geo[tid]['status']
                             for tid, test in eq_geo.items()) and
                         [t['status'] for t in eq_timing] ==
                         [t['status'] for t in timing])
        red += not equivalent_ok
        print('CASE equivalent-json', 'ok' if equivalent_ok else 'KRASNO')
        caught = 0
        if args.stabs:
            if red:
                raise ValueError('KONTROL_NE_ZELEN')
            originals = {s['id']: s for s in old['scenes']}
            for name, tid in STABS.items():
                deceptive = copy.deepcopy(actual)
                # РОВНО одна Final2-сцена; тайминги у неё те же по наследованию.
                for i, scene in enumerate(deceptive['scenes']):
                    if scene['id'] == tid:
                        deceptive['scenes'][i] = copy.deepcopy(originals[tid])
                path = tmp / (name + '.json')
                path.write_text(json.dumps(deceptive))
                g, t = run(path, tmp / (name + '-report.json'))
                failed = {key for key, test in g.items() if test['status'] != 'passed'}
                own_reason = ('GEOMETRIJA_NE_KOMPAKT ' + tid in
                              ' '.join(g[tid]['failureMessages']))
                if (failed != {tid} or not own_reason
                        or not all(test['status'] == 'passed' for test in t)
                        or nongeometry(deceptive) != nongeometry(old)):
                    print('STAB', name, 'ZHIV_OR_WRONG_REASON', sorted(failed))
                    return 1
                caught += 1
                print('STAB', name, 'KRASEN geometry-' + tid,
                      'timing-curves-reduced ok')
        print('клеток 8, зелёных %d, красных %d; стабов %d, поймано %d'
              % (8 - red, red, len(STABS) if args.stabs else 0, caught))
        return 1 if red else 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED:', error, file=sys.stderr)
        sys.exit(2)
