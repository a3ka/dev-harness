"""Adv219 K-08: misclassify simultaneous registry and accounting changes."""

BEFORE = "    print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')"
AFTER = """    changed = git('diff', '--name-only', o, n)[1].decode().splitlines()
    if REG in changed and 'registry/pauzy.tsv' in changed:
        print('uchet')
    else:
        print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')"""
