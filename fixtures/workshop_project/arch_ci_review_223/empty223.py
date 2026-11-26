#!/usr/bin/env python3
"""К-08: literal critic mutation on the reachable empty commit-tree merge."""
import sys
import probe


def main():
    _, saved = probe.carriers()
    honest = saved['model/done_contract.sh']
    # Exact a/b from verdicts/critic/contracts-223-v1.md, applied in memory.
    a = b'[ "$_a187_npaths" -eq 0 ] || [ "$_a187_only" -ne 1 ]'
    b = b'[ "$_a187_only" -ne 1 ]'
    if honest.count(a) != 1:
        raise RuntimeError('CRITIC_MUTATION_ANCHOR')
    mutant = honest.replace(a, b, 1)
    if mutant != saved['stabs/s09-critic-empty-predicate/done_contract.sh']:
        raise RuntimeError('CRITIC_MUTATION_NOT_LITERAL')
    # Same public CLI scenario as empty223.py in the verdict: p1 tree,
    # two parents, success only on p1, expected refusal/query HEAD/no tag.
    case = ('review-merge', 'empty-first', '.review/empty.md', 1, 'head', 'success')
    for label, carrier, expected in (('honest-empty', honest, 0),
                                      ('mutant-empty', mutant, 1)):
        print('ATTACK', label, flush=True)
        red = probe.suite(carrier, [case], label, probe.REPO)
        print('RED', red, flush=True)
        if red != expected:
            raise RuntimeError('EMPTY_CRITIC_REPRODUCTION ' + label)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, probe.subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED: EMPTY223: ' + str(error), file=sys.stderr)
        sys.exit(2)
