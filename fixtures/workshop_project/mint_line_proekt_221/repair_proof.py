#!/usr/bin/env python3
"""Independent mutations and honest equivalent forms for the six-hole repair."""
import sys
from probe221 import REPO, check_carriers, suite


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('MUTATION_ANCHOR_NOT_UNIQUE ' + repr(old))
    return text.replace(old, new)


def main():
    source, saved = check_carriers()
    baseline = saved['model/station.sh']
    production = (REPO / 'scripts/mint_line.sh').read_text()
    # Distinct anchors and operations from every addressed Adv221 stub.
    mutants = (
        ('own-update-ref', 'p15-local-refs-success',
         "printf 'MINTED nnn=%s sha=%s commit=%s\\n'",
         'git -C "$ROOT" update-ref -d "refs/tags/id/CONTRACT/$NNN"\n'
         "printf 'MINTED nnn=%s sha=%s commit=%s\\n'"),
        ('own-remove-alias', 'p23-other-config',
         '  unset _mint_key _mint_rc',
         '  unset _mint_key _mint_rc\n  git -C "$ROOT" config --local --remove-section alias'),
    )
    red = 0
    for name, case, old, new in mutants:
        control = suite(production.encode(), baseline, [case], name + '-honest')
        observed = suite(replace_once(production, old, new).encode(), baseline, [case], name)
        print('OWN', name, 'CONTROL_RED', control, 'MUTANT_RED', observed)
        red += control != 0 or observed != 1
    # Adjacent honest forms: move the disposable hook to each location that the
    # residue stubs use, but RETAIN cleanup. Broad snapshots must not reject them.
    for name in ('git', 'tmp', 'hooks', 'info', 'home'):
        stub = next(saved[rel].decode() for rel in source['nositeli']
                    if rel.endswith('/mint_line.sh') and ('residue-' + name + '/') in rel)
        honest = replace_once(stub, '    :\n  fi\n  return "$_rc"',
                              '    rm -rf -- "$_mint_hook_work" >/dev/null 2>&1 || true\n  fi\n  return "$_rc"')
        red += suite(honest.encode(), baseline,
                     ['p13-hook-cleanup-success', 'p14-hook-cleanup-refusal'],
                     'equivalent-cleanup-' + name)
    print('REPAIR_PROOF KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    sys.exit(main())
