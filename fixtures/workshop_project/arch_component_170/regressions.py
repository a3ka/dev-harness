#!/usr/bin/env python3
"""Run unchanged 095/169 assertions with fixture scratch confined to this checkout.

Their historical /tmp constant ignores TMPDIR. Only scratch locations are relocated;
production scripts, git-pinned models, argv and assertions remain unchanged.
"""
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]


def main():
    scratch = ROOT / '.scratch-170'
    scratch.mkdir(exist_ok=True)
    os.environ['TMPDIR'] = str(scratch)
    with tempfile.TemporaryDirectory(dir=scratch, prefix='regressions-') as name:
        temporary = Path(name)
        toy = temporary / '_toy.sh'
        toy.write_text((ROOT / 'fixtures/context_pack_095/_toy.sh').read_text().replace(
            '/tmp/dev-harness-verify', str(temporary)))
        script = temporary / 'red_pravila_proekta_ne_harsa.sh'
        script.write_bytes((ROOT / 'fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh').read_bytes())
        env = dict(os.environ, CP095_ROOT=str(ROOT), CP095_SUBJECT=str(ROOT / 'scripts/make_task.sh'))
        result = subprocess.run(['bash', str(script)], env=env)
        print(f'095 red_pravila_proekta_ne_harsa rc={result.returncode} (scratch relocated only)', flush=True)
        if result.returncode:
            return result.returncode
        path = ROOT / 'fixtures/workshop_project/model_trace_169/probe.py'
        spec = importlib.util.spec_from_file_location('regression_169', path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        module.VERIFY = temporary
        module.TOY = toy
        sys.argv = [str(path), '--model']
        rc = module.main()
        print(f'169 red_model_trace_169 --model rc={rc} (scratch relocated only)', flush=True)
        return rc


if __name__ == '__main__':
    sys.exit(main())
