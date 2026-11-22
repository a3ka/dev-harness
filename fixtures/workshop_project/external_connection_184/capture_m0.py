#!/usr/bin/env python3
"""Record the authorized M-0 base once; never regenerate its oracle on a candidate."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '716ca297c4bde6597c5522786695f1aea678b825'


def main():
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    if revision != BASE:
        raise SystemExit('capture requires the exact authorized base')
    target = HERE / 'm0_baseline.json'
    if target.exists():
        raise SystemExit('baseline already recorded; refusing replacement')
    scratch = ROOT / '.scratch-m0a'
    scratch.mkdir(exist_ok=True)
    os.environ['TMPDIR'] = str(scratch)
    tempfile.tempdir = str(scratch)
    profiles = {}
    for label, source in (('back', Path('/home/harness/projects/Complior-back')),
                          ('mob', Path('/home/harness/projects/Complior-mob')),
                          ('station', ROOT)):
        profile = (source / 'harness.project.json').read_bytes()
        data = json.loads(profile)
        layer_path = data['projectLayer']['profilePath']
        layer = (source / layer_path).read_bytes()
        with tempfile.TemporaryDirectory(prefix='m0-capture-') as tmp:
            repo = Path(tmp)
            (repo / 'harness.project.json').write_bytes(profile)
            (repo / layer_path).parent.mkdir(parents=True, exist_ok=True)
            (repo / layer_path).write_bytes(layer)
            workflow = repo / data['ci']['workflow']
            workflow.parent.mkdir(parents=True, exist_ok=True)
            workflow.touch()
            result = subprocess.run(['bash', str(ROOT / 'scripts/profile_resolver.sh'), '--repo', str(repo)],
                                    cwd=ROOT, env=dict(os.environ, HARNESS_PROJECT_LAYER_ROOT=str(repo)),
                                    capture_output=True, text=True)
        print(f'BASE_PROFILE {label} rc={result.returncode} stderr={result.stderr!r}', flush=True)
        if result.returncode != 0:
            raise SystemExit('baseline profile is not green')
        profiles[label] = dict(profile=profile.decode(), layer=layer.decode(), stdout=result.stdout,
                               profile_sha256=hashlib.sha256(profile).hexdigest(),
                               layer_sha256=hashlib.sha256(layer).hexdigest())
    target.write_text(json.dumps(dict(base=BASE, profiles=profiles), ensure_ascii=False, indent=2) + '\n')
    wrapper = str(HERE / 'red_external_connection_184.sh')
    commands = [['bash', wrapper, *args] for args in
                ([], ['--model'], ['--stabs'], ['--repo', '/home/harness/projects/Complior-back'],
                 ['--repo', '/home/harness/projects/Complior-mob'])]
    commands += [['python3', str(HERE / 'probe.py'), mode] for mode in ('--model', '--stabs')]
    commands += [['bash', 'scripts/verify_antiplacebo.sh', '--scope', 'profile_resolver']]
    measurements = []
    for command in commands:
        result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        entry = dict(command=command, rc=result.returncode, stdout=result.stdout, stderr=result.stderr)
        measurements.append(entry)
        print('BASE_COMMAND ' + json.dumps(entry, ensure_ascii=False), flush=True)
    (HERE / 'm0_before.json').write_text(json.dumps(measurements, ensure_ascii=False, indent=2) + '\n')


if __name__ == '__main__':
    main()
