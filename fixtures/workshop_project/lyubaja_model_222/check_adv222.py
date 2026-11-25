#!/usr/bin/env python3
"""Addressed Adv222 evidence, including mutations independent of stub anchors."""
import json
import sys
sys.dont_write_bytecode = True

from probe import HERE, ROOT, battery


def check(name, mutation, selected, model):
    bad = battery(ROOT, model=model, mutation=mutation, selected=selected)
    observed_rc = int(bool(bad))
    print(f'{name}: rc={observed_rc} red={",".join(bad)}', flush=True)
    return observed_rc == 1 and set(bad) == set(selected)


def main():
    mutations = json.loads((HERE / 'source.json').read_text())
    okay = True
    for mutation in mutations[-2:]:
        okay &= check(mutation['name'], mutation, mutation['cases'], True)
    # Different edit locations from st34/st35, against the current production,
    # not the reference model or a textual inspection of the candidate.
    okay &= check('independent-empty-is-absent', {
        'name': 'independent-empty-is-absent',
        'file': 'scripts/check_sud_model.sh',
        'old': 'if [ "$assigned_given" -eq 1 ]; then',
        'new': 'if [ "$assigned_given" -eq 1 ] && [ -n "$assigned" ]; then',
    }, ['verdict-assigned-empty', 'verdict-assigned-empty-before-root'], False)
    okay &= check('independent-denied-per-call-continue', {
        'name': 'independent-denied-per-call-continue',
        'file': 'scripts/check_sud_model.sh',
        'old': '        denied)\n',
        'new': '        denied)\n          if [ -n "$assigned" ]; then continue; fi\n',
    }, ['verdict-denied-per-call-wrong-fallback'], False)
    return int(not okay)


if __name__ == '__main__':
    sys.exit(main())
