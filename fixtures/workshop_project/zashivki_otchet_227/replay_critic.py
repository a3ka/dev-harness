#!/usr/bin/env -S python3 -B
"""Replay Crit227's exact three-line deletion in a disposable local clone."""
from pathlib import Path
import shutil
import sys
import tempfile

import build
import probe


def main():
    parent = probe.ROOT / 'tmp' / 'scratch-arch227b'
    parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='critic-replay-', dir=parent) as tmp:
        root = Path(tmp) / 'repo'
        probe.required(['git', 'clone', '--shared', '--quiet', str(probe.ROOT), str(root)], probe.ROOT)
        family = root / build.HERE.relative_to(probe.ROOT)
        shutil.copytree(build.HERE, family, dirs_exist_ok=True)
        for file in build.FILES:
            probe.put(root, file, (family / 'model' / file).read_bytes())
        script = root / build.SCRIPT
        text = script.read_text()
        original = probe.required(['git', 'show', 'b2244d635:' +
                                   str((build.HERE / 'model' / build.SCRIPT).relative_to(probe.ROOT))], root)
        removed = ''.join(original.stdout.decode().splitlines(keepends=True)[18:21])
        if removed != build.GREP_CHECK or text.count(removed) != 1:
            raise probe.Unavailable('CRITIC_MUTATION_ANCHOR')
        script.write_text(text.replace(removed, '', 1))
        probe.required(['bash', 'scripts/gen_ci_steps.sh', '--write'], root)
        result = probe.run(['bash', str(family / 'red_zashivki_otchet_227.sh'), '--repo', str(root)], root)
        print('CRITIC_EXACT_DELETE_19_21 --repo rc', result.returncode, flush=True)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        lines = result.stdout.decode().splitlines()
        red = [line for line in lines if ' RED ' in line]
        valid = (result.returncode == 1 and len(red) == 1 and
                 red[0].startswith('git-failure RED MEASUREMENT_ERROR_RC rc=0,') and
                 'MEASUREMENT_ERROR_REPORT' in red[0] and
                 lines[-1] == f'KLETKI {len(probe.NAMES)} KRASNYH 1')
        return 0 if valid else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (probe.Unavailable, OSError, ValueError) as error:
        print('NOT_IMPLEMENTED: VERIFIER_UNAVAILABLE:', error, file=sys.stderr)
        sys.exit(2)
