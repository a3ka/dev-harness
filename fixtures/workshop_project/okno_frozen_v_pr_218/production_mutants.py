#!/usr/bin/env python3
"""Reproduce Adv218's three production mutations in disposable local clones."""
import json
from pathlib import Path
import sys
import tempfile

import probe

OBJECT = '682fb9881c94cf674b107d99238102b0313eb18d'


def mutants():
    yield ('verdict-v1-only',
           b'verdicts/critic/contracts-*-v*.md|verdicts/critic/plans-*-v*.md)',
           b'verdicts/critic/contracts-*-v1.md|verdicts/critic/plans-*-v1.md)',
           'frozen-verdict-contracts-v2-fail')
    old = b'    while IFS= read -r -d \'\' p; do PR_MD["$c:$p"]=1; done < "$row"\n'
    new = old + b'''    if [ -n "${PR_MD[$c:AGENTS.md]+set}" ] && [ -n "${PR_MD[$c:ROADMAP.md]+set}" ]; then
      unset 'PR_MD[$c:ROADMAP.md]'
    fi
'''
    yield 'hide-roadmap', old, new, 'charter-two-documents-agents'
    # The adversary removed both existing DELTA_UNREADABLE refusal branches.
    old = '''      rm -f "$row"; pr_refuse DELTA_UNREADABLE
    fi
    while IFS= read -r -d '' p; do
      PR_PATHS["$p"]=1; PR_CHANGE["$c:$p"]=1
    done < "$row"
    # M/D — те же пути, что устава: добавление нового контракта свободно.
    if ! g diff-tree --root -r "$merge_mode" --no-commit-id --no-renames --diff-filter=MD --name-only -z "$c" > "$row"; then
      rm -f "$row"; pr_refuse DELTA_UNREADABLE
'''.encode()
    yield ('delta-errors-clean', old,
           old.replace(b'rm -f "$row"; pr_refuse DELTA_UNREADABLE', b':'),
           'charter-git-fault-diff-all')


def main():
    scratch = probe.TREE / 'tmp/scratch-arch218'
    scratch.mkdir(parents=True, exist_ok=True)
    baseline = probe.sources(probe.TREE, pinned=True)
    cases = {c.name: c for c in probe.cells()}
    report = []
    for name, old, new, witness in mutants():
        with tempfile.TemporaryDirectory(prefix='production-mutant-' + name + '-', dir=scratch) as temporary:
            directory = Path(temporary)
            clone = directory / 'clone'
            probe.git(probe.TREE, 'clone', '-q', '--shared', '--no-checkout', str(probe.TREE), str(clone))
            probe.git(clone, 'checkout', '-q', '--detach', OBJECT)
            honest = probe.sources(clone)
            control = directory / 'control'
            control.mkdir()
            if not probe.observe(cases[witness], honest, baseline, control):
                raise probe.Prerequisite('PRODUCTION_HONEST_CONTROL_RED: ' + witness)
            path = clone / 'scripts/check_charter.sh'
            path.write_bytes(probe.replace(path.read_bytes(), old, new))
            altered = probe.sources(clone)
            attack = directory / 'attack'
            attack.mkdir()
            if probe.observe(cases[witness], altered, baseline, attack, mutant=True):
                raise probe.Prerequisite('PRODUCTION_MUTANT_SURVIVED: ' + name)
            # Exercise the public --repo door on the actual mutant clone too.
            result = probe.command(['python3', probe.HERE / 'probe.py', '--repo', clone], probe.TREE)
            sys.stdout.buffer.write(result[1])
            sys.stderr.buffer.write(result[2])
            sys.stdout.flush()
            if result[0] != 1 or (witness + ' RED ').encode() not in result[1]:
                raise probe.Prerequisite('PRODUCTION_MUTANT_WRONG_RED: ' + name)
            row = {'mutant': name, 'witness': witness, 'honest_green': True,
                   'mutant_red': True, 'repo_rc': result[0]}
            report.append(row)
            print('PRODUCTION_MUTANT ' + json.dumps(row, sort_keys=True), flush=True)
    print('PRODUCTION_MUTANTS=' + str(len(report)))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, probe.Prerequisite) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        sys.exit(2)
