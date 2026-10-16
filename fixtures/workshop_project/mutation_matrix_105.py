#!/usr/bin/env python3
"""105 variant A: full guard against ten N-scoped mutants and two regressions.

Run: python3 fixtures/workshop_project/mutation_matrix_105.py --logs /tmp/105-logs
The checked-in honest model is never changed. Each run uses the unchanged full
runner and fixture family in a private directory, replacing only its model copy.
Every mutant must fail its own invariant, not merely break the stub battery.
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

FAMILY = Path(__file__).resolve().parent
ROOT = FAMILY.parent.parent
CELLS = {
    1: "red_ext_ustanovki_105.sh",
    2: "red_config_do_overlay_105.sh",
    3: "red_roli_v_profil_105.sh",
    4: "red_otkaz_flagov_105.sh",
    5: "red_proba_odin_kod_105.sh",
}


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError(f"mutation anchor must occur once: {old!r}")
    return text.replace(old, new, 1)


def mutations(model):
    # Count real installation files independently, before argument parsing (I-4).
    census = '''MATRIX_N=0
for matrix_f in "$HERE"/.omp/extensions/*.ts; do
  [ ! -f "$matrix_f" ] || MATRIX_N=$((MATRIX_N+1))
done
'''
    for invariant in CELLS:
        for boundary, operator in (("N>0", "-gt"), ("N=0", "-eq")):
            text = replace_once(model, 'PROFILE="dev"', census + 'PROFILE="dev"')
            condition = f'[ "$MATRIX_N" {operator} 0 ]'
            if invariant == 1:
                # Contaminate exec and banner equally: I-5 must remain honest.
                text = replace_once(text, 'EXT_ARGS=()',
                    f'{condition} && EXT_LIST+=("$PROJECT/.omp/extensions/evil.ts")\nEXT_ARGS=()')
            elif invariant == 2:
                # Reverse policy/overlay precedence only when an overlay exists.
                text = replace_once(text, 'if [ "$MUT" = overlay_first ]; then',
                    f'if [ "$MUT" = overlay_first ] || {{ {condition} && [ -n "$MODELS" ]; }}; then')
            elif invariant == 3:
                text = replace_once(text, '  cp "$r" "$AGENTS/$(basename "$r")"',
                    f'  if {condition}; then\n'
                    '    touch "$AGENTS/$(basename "$r")"\n'
                    '  else\n    cp "$r" "$AGENTS/$(basename "$r")"\n  fi')
            elif invariant == 4:
                # One forbidden form, not the first: all six must be exercised.
                text = replace_once(text, '      case "$MUT" in',
                    f'      if {condition} && [ "$1" = --hook ]; then break; fi\n'
                    '      case "$MUT" in')
            else:
                # Probe-only project extension: detects empty-project regression too.
                text = replace_once(text, 'print_policy() {',
                    'print_policy() {\n'
                    f'  if {condition} && [ "$PROBE" = 1 ]; then\n'
                    '    printf \'EXT: %s\\n\' "$PROJECT/.omp/extensions/evil.ts"\n  fi')
            yield f"I-{invariant}_{boundary}", invariant, text
    yield "old_empty_glob", 1, replace_once(model, '  [ -f "$f" ] || continue\n', '')
    yield "old_probe_glob", 5, replace_once(model, '  else\n    for f in "${EXT_LIST[@]}";',
        '  elif [ "$PROBE" = 1 ]; then\n'
        '    for f in "$EXT_SRC"/*.ts; do printf \'EXT: %s\\n\' "$f"; done\n'
        '  else\n    for f in "${EXT_LIST[@]}";')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--logs', type=Path, required=True)
    args = parser.parse_args()
    args.logs.mkdir(parents=True, exist_ok=True)
    model = (FAMILY / 'model_105/workshop.sh').read_text()
    cases = [('honest', None, model), *mutations(model)]
    assert len(cases) == 13
    failures = 0
    env = dict(os.environ)
    for key in ('M105_MUTANT', 'W105_SUBJECT', 'W105_ROOT', 'RUN_HOME'):
        env.pop(key, None)
    with tempfile.TemporaryDirectory(prefix='matrix105.') as directory:
        fixtures = Path(directory) / 'fixtures'
        family = fixtures / 'workshop_project'
        family.mkdir(parents=True)
        shutil.copyfile(ROOT / 'fixtures/_krasnye_105.sh', fixtures / '_krasnye_105.sh')
        for source in FAMILY.iterdir():
            if source.name != 'model_105':
                (family / source.name).symlink_to(source)
        (family / 'model_105').mkdir()
        for name, invariant, subject in cases:
            (family / 'model_105/workshop.sh').write_text(subject)
            result = subprocess.run(
                ['bash', str(fixtures / '_krasnye_105.sh'), '--model', str(ROOT)],
                env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                timeout=180,
            )
            (args.logs / f'{name}.log').write_text(result.stdout)
            wanted = 0 if invariant is None else 1
            target = invariant is None or f'— {CELLS[invariant]}: rc=1' in result.stdout
            control = invariant is not None or (
                'мутантов 7, поймано на своей клетке 7, ускользнуло: нет' in result.stdout
                and 'честных входов мутантов 28, зелёных 28, красных: нет' in result.stdout
            )
            ok = result.returncode == wanted and target and control
            failures += not ok
            print(f'{name}\trc={result.returncode}\texpected={wanted}\ttarget={target}', flush=True)
        print(f'105 matrix: subjects={len(cases)}, mutants={len(cases)-1}, failures={failures}')
    return 1 if failures else 0


if __name__ == '__main__':
    raise SystemExit(main())
