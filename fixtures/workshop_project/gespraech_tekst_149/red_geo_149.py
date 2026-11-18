#!/usr/bin/env python3
"""149: measured Kompakt geometry; archival cycle-2 battery is not modified."""
import argparse
import copy
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
GEOMETRY = 'nositeli/kompakt11/geometrija-149.json'
PRODUCT_SPEC = 'docs/ux/05_Kompakt_D24/motion/motion-spec-gespraech-kompakt-149.json'
PRODUCT_FORM = 'mobile/e2e-gespraech-tekst/ekran.json'
PROPERTIES = ('left', 'top', 'w', 'h')
THEMES = ('dark', 'light')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def scenes(spec):
    values = spec['scenes']
    result = {item['id']: item for item in values}
    if len(result) != len(values):
        raise ValueError('duplicate scene')
    return result


def track(scene, element, prop):
    matches = [item for item in scene['tracks']
               if item['element'] == element and item['property'] == prop]
    if len(matches) != 1:
        raise ValueError('track is not unique: ' + element + '/' + prop)
    return matches[0]


def oracle():
    # Both trusted snapshots are read and sealed BEFORE any subject is opened.
    pins = json.loads((HERE / 'piny.json').read_text())['dvizhenie']
    data = (HERE / GEOMETRY).read_bytes()
    if pins['geometrija'] != GEOMETRY or sha(data) != pins['sha256']:
        raise RuntimeError('ORACLE_TAMPERED geometry')
    geometry = json.loads(data)
    base_data = (HERE / geometry['source']['base']).read_bytes()
    if sha(base_data) != geometry['source']['base_sha256']:
        raise RuntimeError('ORACLE_TAMPERED Final2')
    if pins['spec_produkta'] != PRODUCT_SPEC:
        raise RuntimeError('ORACLE_TAMPERED product path')
    return geometry, json.loads(base_data)


def metadata(geometry):
    return {'source_delta_sha256': geometry['source']['delta_sha256'],
            'field': geometry['field'], 'adaptive_min': geometry['adaptive_min']}


def model(geometry, base):
    result = copy.deepcopy(base)
    indexed = scenes(result)
    for name, target in geometry['scenes'].items():
        scene = indexed[name]
        if 'rects' in target:
            for i, prop in enumerate(PROPERTIES):
                item = track(scene, '#morph', prop)
                for theme in THEMES:
                    item['resolved'][theme] = {
                        end: target['rects'][end][i] for end in ('from', 'to')}
        if 'nav' in target:
            item = track(scene, '#a-text [data-m=nav]', 'ty')
            item['from'], item['to'] = target['nav']
        if 'adaptive' in target:
            scene['adaptive'].update(copy.deepcopy(target['adaptive']))
            scene['adaptive']['rule'] = scene['adaptive']['rule'].replace('96', '80')
    result['kompakt149'] = copy.deepcopy(metadata(geometry))
    return result


def non_geometry(scene, target):
    """A closed path mask, not a blacklist of timing spellings."""
    result = copy.deepcopy(scene)
    if 'rects' in target:
        for prop in PROPERTIES:
            track(result, '#morph', prop).pop('resolved')
    if 'nav' in target:
        item = track(result, '#a-text [data-m=nav]', 'ty')
        item.pop('from')
        item.pop('to')
    if 'adaptive' in target:
        for key in ('caps', 'top', 'rule'):
            result['adaptive'].pop(key)
    return result


def judge(subject, geometry, base):
    try:
        actual, archived = scenes(subject), scenes(base)
        for name, target in geometry['scenes'].items():
            item = actual[name]
            suffix = name.removeprefix('GA-').replace('-', '_')
            if 'rects' in target:
                for theme in THEMES:
                    for end in ('from', 'to'):
                        rect = [track(item, '#morph', prop)['resolved'][theme][end]
                                for prop in PROPERTIES]
                        if rect != target['rects'][end]:
                            return 'PRJAMOUGOLNIK_' + suffix
            if 'nav' in target:
                nav = track(item, '#a-text [data-m=nav]', 'ty')
                if [nav['from'], nav['to']] != target['nav']:
                    return 'NAV_' + suffix
            if 'adaptive' in target:
                if item['adaptive']['caps'] != target['adaptive']['caps']:
                    return 'CAP_' + suffix
                if item['adaptive']['top'] != target['adaptive']['top']:
                    return 'SHAPKA_' + suffix
                rule = archived[name]['adaptive']['rule'].replace('96', '80')
                if item['adaptive']['rule'] != rule:
                    return 'MINIMUM_' + suffix
            if non_geometry(item, target) != non_geometry(archived[name], target):
                return 'SOHRANENIE_' + suffix
        for name in geometry['preserved']:
            if actual[name] != archived[name]:
                return 'SOHRANENIE_' + name.removeprefix('GA-')
        if subject.get('kompakt149') != metadata(geometry):
            return 'PARAMETRY_POLJA_I_ISTOCHNIK'
    except (KeyError, TypeError, ValueError, IndexError):
        return 'STRUKTURA_SPEC'
    return None


def stabs(geometry, base):
    honest = model(geometry, base)
    if judge(honest, geometry, base) is not None:
        raise RuntimeError('HONEST_CONTROL_RED')
    # JSON order, whitespace and integer/float spelling are not geometry.
    equivalent = json.loads(json.dumps(honest, sort_keys=True))
    for scene in equivalent['scenes']:
        for item in scene['tracks']:
            if 'resolved' in item and item['element'] == '#morph':
                for values in item['resolved'].values():
                    for end, value in values.items():
                        if isinstance(value, (int, float)):
                            values[end] = float(value)
    if judge(equivalent, geometry, base) is not None:
        raise RuntimeError('EQUIVALENT_CONTROL_RED')
    cases = []

    def add(label, reason, mutate):
        candidate = copy.deepcopy(honest)
        mutate(candidate)
        cases.append((label, reason, candidate))

    # N-39: every defect is bound HERE to its observable input and exact branch.
    for name, target in geometry['scenes'].items():
        suffix = name.removeprefix('GA-').replace('-', '_')
        if 'rects' in target:
            def final2(candidate, name=name):
                for prop in PROPERTIES:
                    track(scenes(candidate)[name], '#morph', prop)['resolved'] = copy.deepcopy(
                        track(scenes(base)[name], '#morph', prop)['resolved'])
            add(name + '/Final2-rects', 'PRJAMOUGOLNIK_' + suffix, final2)

            def heights_only(candidate, name=name):
                for prop in ('left', 'top', 'w'):
                    track(scenes(candidate)[name], '#morph', prop)['resolved'] = copy.deepcopy(
                        track(scenes(base)[name], '#morph', prop)['resolved'])
            add(name + '/height-only-not-final-rect', 'PRJAMOUGOLNIK_' + suffix, heights_only)

            def light_only(candidate, name=name):
                item = track(scenes(candidate)[name], '#morph', 'h')
                item['resolved']['light']['to'] += 1
            add(name + '/light-only', 'PRJAMOUGOLNIK_' + suffix, light_only)
        if 'nav' in target:
            def nav_final2(candidate, name=name):
                item = track(scenes(candidate)[name], '#a-text [data-m=nav]', 'ty')
                old = track(scenes(base)[name], '#a-text [data-m=nav]', 'ty')
                item['from'], item['to'] = old['from'], old['to']
            add(name + '/Final2-nav', 'NAV_' + suffix, nav_final2)
        if 'adaptive' in target:
            for index in range(len(target['adaptive']['caps'])):
                def cap_final2(candidate, name=name, index=index):
                    scenes(candidate)[name]['adaptive']['caps'][index][1] = (
                        scenes(base)[name]['adaptive']['caps'][index][1])
                add(name + '/Final2-cap-' + str(index), 'CAP_' + suffix, cap_final2)

            def top_final2(candidate, name=name):
                scenes(candidate)[name]['adaptive']['top'] = scenes(base)[name]['adaptive']['top']
            add(name + '/Final2-header', 'SHAPKA_' + suffix, top_final2)

            def minimum_final2(candidate, name=name):
                scenes(candidate)[name]['adaptive']['rule'] = scenes(base)[name]['adaptive']['rule']
            add(name + '/Final2-minimum', 'MINIMUM_' + suffix, minimum_final2)
        for key in ('duration', 'curve', 'reduced_duration_ms'):
            def changed_timing(candidate, name=name, key=key):
                item = scenes(candidate)[name]['tracks'][0]
                if key == 'duration':
                    item[key]['ms'] += 1
                elif key == 'curve':
                    item[key]['token'] = 'linear'
                else:
                    item[key] += 1
            add(name + '/changed-' + key, 'SOHRANENIE_' + suffix, changed_timing)
    for name in geometry['preserved']:
        def moved_control(candidate, name=name):
            scenes(candidate)[name]['tracks'][0]['duration']['ms'] += 1
        add(name + '/changed-control', 'SOHRANENIE_' + name.removeprefix('GA-'), moved_control)
    for key in geometry['field']:
        def old_field(candidate, key=key):
            candidate['kompakt149']['field'][key] += 1
        add('field/' + key, 'PARAMETRY_POLJA_I_ISTOCHNIK', old_field)
    for key in ('source_delta_sha256', 'adaptive_min'):
        def wrong_source(candidate, key=key):
            candidate['kompakt149'][key] = None
        add('metadata/' + key, 'PARAMETRY_POLJA_I_ISTOCHNIK', wrong_source)
    failures = 0
    for label, expected, candidate in cases:
        observed = judge(candidate, geometry, base)
        print('STAB', label, 'PRICHINA', observed, 'EXPECTED', expected)
        failures += observed != expected
    print('STABY', len(cases) - failures, '/', len(cases), 'HONEST_CONTROLS', 2)
    return 1 if failures or not cases else 0


def read_subject(path):
    try:
        return json.loads(path.read_bytes()), None
    except (OSError, ValueError):
        return None, 'SPEC_NET_ILI_NE_JSON'


def repository(root, geometry):
    path = root / PRODUCT_SPEC
    subject, failure = read_subject(path)
    if failure:
        return None, failure
    try:
        form = json.loads((root / PRODUCT_FORM).read_bytes())['dvizhenie']
        if form['spec'] != PRODUCT_SPEC or form['spec_sha256'] != sha(path.read_bytes()):
            return None, 'PIN_SPEC'
        delta = root / geometry['source']['delta']
        if sha(delta.read_bytes()) != geometry['source']['delta_sha256']:
            return None, 'ISTOCHNIK_NE_KOMPAKT_11'
    except (OSError, ValueError, KeyError, TypeError):
        return None, 'PIN_SPEC'
    return subject, None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--spec', type=Path)
    mode.add_argument('--repo', type=Path)
    mode.add_argument('--emit-spec', type=Path)
    args = parser.parse_args()
    try:
        geometry, base = oracle()
        if args.stabs:
            return stabs(geometry, base)
        if args.emit_spec:
            args.emit_spec.parent.mkdir(parents=True, exist_ok=True)
            args.emit_spec.write_text(json.dumps(model(geometry, base), ensure_ascii=False, indent=2) + '\n')
            return 0
        if args.model:
            subject, failure = model(geometry, base), None
        elif args.spec:
            subject, failure = read_subject(args.spec)
        else:
            subject, failure = repository(args.repo, geometry)
        failure = failure or judge(subject, geometry, base)
        if failure:
            print('PRICHINA', failure)
            return 1
        print('GEOMETRIJA_KOMPAKT_11')
        return 0
    except (OSError, ValueError, KeyError, TypeError, RuntimeError) as exc:
        print('NOT_IMPLEMENTED', str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
