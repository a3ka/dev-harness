#!/usr/bin/env python3
"""Rev206 delta: reuse real probe/sweep without repeating their full doors."""
import argparse
import sys

import probe
import sweep


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('case', choices=('block1', 'block2', 'stale'))
    args = parser.parse_args()
    if args.case != 'stale':
        name = ('quoted-read-stderr-is-write' if args.case == 'block1'
                else 'verdict-logical-before-physical')
        mutations = [m for m in probe.MUTATIONS if m[0] == name]
        if len(mutations) != 1:
            raise RuntimeError('DELTA_MUTATION_NOT_UNIQUE')
        probe.MUTATIONS = mutations
        sys.argv = [sys.argv[0], '--stabs']
        return probe.main()

    # The ordinary doors still run every mutant and the complete canon.
    # Here the same real killed mutant demonstrates the stale-entry refusal;
    # no judge, outcome, classifier or return value is replaced.
    mutants = [m for m in sweep.build_mutants() if m[0] == 'ca72ade2ebeb']
    if len(mutants) != 1:
        raise RuntimeError('DELTA_SWEEP_MUTATION_NOT_UNIQUE')
    sweep.build_mutants = lambda: mutants
    sweep.EQUIVALENTS = {}
    honest = sweep.run(check=True)
    if honest != 0:
        return honest
    _, path, anchor, op, _ = mutants[0]
    sweep.EQUIVALENTS[(path, anchor, op)] = 'injected stale entry'
    stale = sweep.run(check=True)
    print(f'DELTA_STALE honest_rc={honest} stale_rc={stale}')
    return 0 if stale == 1 else 1


if __name__ == '__main__':
    sys.exit(main())
