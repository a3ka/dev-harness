#!/usr/bin/env python3
"""Single mutation-to-input registry; deterministic carriers and hash manifest."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRIPT = 'scripts/report_zashivki.sh'
CONFIG = 'config/zashivki.json'
STEPS = 'registry/ci-steps.tsv'
ZAMERY = 'registry/ci-zamery.tsv'
FILES = (SCRIPT, CONFIG, STEPS, ZAMERY)
KEY = 'report:zashivki-227'
COMMAND = 'bash scripts/report_zashivki.sh'
# name, mutated file, one exact operation, replacement, individually exercised cells
MUTATIONS = [
    ('s01-block-residue', SCRIPT, '    print(json.dumps(report, ensure_ascii=False))',
     '    print(json.dumps(report, ensure_ascii=False))\n    sys.exit(1 if matches else 0)', ('nonempty', 'above-baseline')),
    ('s02-block-empty', SCRIPT, '    print(json.dumps(report, ensure_ascii=False))',
     '    print(json.dumps(report, ensure_ascii=False))\n    sys.exit(0 if matches else 1)', ('empty',)),
    ('s03-no-count', SCRIPT, "'lines': len(matches)", "'lines': 0", ('nonempty',)),
    ('s04-files-are-lines', SCRIPT, "len({m['path'] for m in matches})", 'len(matches)', ('nonempty',)),
    ('s05-no-list', SCRIPT, "'matches': matches", "'matches': []", ('nonempty',)),
    ('s06-no-excludes', SCRIPT, "    paths += [':(exclude,literal)' + p for p in config['exclude']]", '', ('excluded-only',)),
    ('s07-fixed-pattern', SCRIPT, "config['pattern']", "r'Complior-(back|mob)|a3ka/Complior|complior-(back|mob)|\\.harness/'", ('changed-pattern',)),
    ('s08-fixed-includes', SCRIPT, "config['include']", "['scripts', '.omp/extensions', '.githooks']", ('changed-include',)),
    ('s09-fixed-excludes', SCRIPT, "config['exclude']", "['scripts/proxy']", ('changed-exclude',)),
    ('s10-untracked', SCRIPT, "'-z', '-n', '-I'", "'--untracked', '-z', '-n', '-I'", ('untracked',)),
    ('s11-binary-as-text', SCRIPT, "'-I', '-E'", "'-a', '-E'", ('binary',)),
    ('s12-unique-contents', SCRIPT, "    report = {'lines': len(matches)",
     "    matches = list({m['text']: m for m in matches}.values())\n    report = {'lines': len(matches)", ('same-content',)),
    ('s13-line-off-by-one', SCRIPT, "'line': int(number)", "'line': int(number) + 1", ('line-numbers',)),
    ('s14-text-omitted', SCRIPT, "'text': text.decode()", "'text': ''", ('line-numbers',)),
    ('s15-fixed-baseline', SCRIPT, "'baseline': config['baseline']", "'baseline': {'lines': 89, 'files': 20, 'commit': '6565542c1'}", ('changed-baseline',)),
    ('s16-last-match-lost', SCRIPT, "'matches': matches", "'matches': matches[:-1]", ('nonempty',)),
    ('s17-whole-word', SCRIPT, "'-I', '-E'", "'-I', '-w', '-E'", ('substring',)),
    ('s18-ci-noop', STEPS, COMMAND, 'bash scripts/report_zashivki.sh || true', ('ci-wiring',)),
    ('s19-ci-absent', STEPS, 'step\t' + KEY, 'step\treport:other', ('ci-wiring',)),
    ('s20-measure-absent', ZAMERY, KEY, 'report:other', ('ci-measurement',)),
    ('s21-wrong-default', CONFIG, '"scripts/proxy"', '"scripts/proxy2"', ('default-config',)),
    ('s22-index-only', SCRIPT, "'-z', '-n', '-I'", "'--cached', '-z', '-n', '-I'", ('dirty-worktree',)),
    ('s23-skip-comments', SCRIPT, "    report = {'lines': len(matches)",
     "    matches = [m for m in matches if not m['text'].lstrip().startswith('#')]\n    report = {'lines': len(matches)", ('comments',)),
    ('s24-line-threshold', SCRIPT, '    print(json.dumps(report, ensure_ascii=False))',
     "    print(json.dumps(report, ensure_ascii=False))\n    sys.exit(int(report['lines'] > config['baseline']['lines']))", ('above-baseline',)),
    ('s25-file-threshold', SCRIPT, '    print(json.dumps(report, ensure_ascii=False))',
     "    print(json.dumps(report, ensure_ascii=False))\n    sys.exit(int(report['files'] > config['baseline']['files']))", ('above-file-baseline',)),
]
EQUIVALENTS = [
    ('e01-files-equivalent', SCRIPT, "len({m['path'] for m in matches})", "len(set(m['path'] for m in matches))", ('nonempty',)),
    ('e02-json-layout', SCRIPT, 'json.dumps(report, ensure_ascii=False)', 'json.dumps(report, ensure_ascii=True, indent=2, sort_keys=True)', ('unicode-path',)),
]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def expected():
    base = {f: (HERE / 'model' / f).read_bytes() for f in FILES}
    carriers = {'model': base}
    links = []
    for name, file, old, new, cells in MUTATIONS + EQUIVALENTS:
        raw = base[file].decode()
        if raw.count(old) != 1:
            raise RuntimeError('ANCHOR_COUNT: ' + name + ': ' + str(raw.count(old)))
        modified = dict(base)
        modified[file] = raw.replace(old, new).encode()
        carriers['stabs/' + name] = modified
        links.append({'carrier': 'stabs/' + name, 'cells': list(cells),
                      'polarity': 'green' if name.startswith('e') else 'red'})
    manifest = {'files': {root + '/' + f: digest(data) for root, content in carriers.items()
                          for f, data in content.items()}, 'links': links}
    return carriers, manifest


def main():
    carriers, manifest = expected()
    for root, content in carriers.items():
        for f, data in content.items():
            path = HERE / root / f
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    (HERE / 'source.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print('STABY', len(MUTATIONS), 'EKVIVALENTY', len(EQUIVALENTS),
          'SVJAZI', sum(len(row['cells']) for row in manifest['links']))


if __name__ == '__main__':
    main()
