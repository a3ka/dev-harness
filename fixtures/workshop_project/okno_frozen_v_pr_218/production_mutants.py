#!/usr/bin/env python3
"""Reproduce production mutations on an explicit candidate in disposable clones."""
import argparse
import contextlib
import io
import json
from pathlib import Path
import sys
import tempfile

import probe

OBJECT = 'ca726d350306c7cb4a1e37a1c974cc57ef7c309b'


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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', default=OBJECT)
    parser.add_argument('--adv218b-priority', action='store_true',
                        help='also reproduce the exact Adv218b mutation (original candidate)')
    parser.add_argument('--only', help='select one named mutation for isolated reproduction')
    args = parser.parse_args()
    candidate = probe.git(probe.TREE, 'rev-parse', '--verify', args.candidate + '^{commit}').decode().strip()
    print('CANDIDATE=' + candidate, flush=True)
    scratch = probe.TREE / 'tmp/scratch-arch218'
    scratch.mkdir(parents=True, exist_ok=True)
    baseline = probe.sources(probe.TREE, pinned=True)
    cases = {c.name: c for c in probe.cells()}
    report = []
    changes = [('check_charter.sh', *row) for row in mutants()]
    if args.adv218b_priority:
        changes.append(('check_contract_frozen.sh', 'anchor-over-head',
                        b'if [ "$PR_ACTIVE" -eq 1 ] && [ -z "$body" ]; then',
                        b'if [ "$PR_ACTIVE" -eq 1 ]; then',
                        'frozen-evidence-contracts-v2-head-fail'))
    if args.only:
        changes = [row for row in changes if row[1] == args.only]
        if not changes:
            raise probe.Prerequisite('EMPTY_MUTATION_SELECTION')
    for filename, name, old, new, witness in changes:
        with tempfile.TemporaryDirectory(prefix='production-mutant-' + name + '-', dir=scratch) as temporary:
            directory = Path(temporary)
            clone = directory / 'clone'
            probe.git(probe.TREE, 'clone', '-q', '--no-hardlinks', '--no-checkout', str(probe.TREE), str(clone))
            probe.git(clone, 'checkout', '-q', '--detach', candidate)
            honest = probe.sources(clone)
            control = directory / 'control'
            control.mkdir()
            if not probe.observe(cases[witness], honest, baseline, control):
                raise probe.Prerequisite('PRODUCTION_HONEST_CONTROL_RED: ' + witness)
            path = clone / 'scripts' / filename
            path.write_bytes(probe.replace(path.read_bytes(), old, new))
            altered = probe.sources(clone)
            attack = directory / 'attack'
            attack.mkdir()
            if probe.observe(cases[witness], altered, baseline, attack, mutant=True):
                raise probe.Prerequisite('PRODUCTION_MUTANT_SURVIVED: ' + name)
            # The whole battery has per-process deadlines already. Invoke its
            # same public argument dispatch without nesting a 60s CLI deadline.
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                rc = probe.main(['--repo', str(clone)])
            text = output.getvalue()
            print(text, end='', flush=True)
            if rc != 1 or witness + ' RED ' not in text:
                raise probe.Prerequisite('PRODUCTION_MUTANT_WRONG_RED: ' + name)
            row = {'mutant': name, 'witness': witness, 'candidate': candidate, 'honest_green': True,
                   'mutant_red': True, 'repo_rc': rc}
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
