#!/usr/bin/env python3
"""214 live highest frozen blobs; emit/check every overlap declaration."""
import argparse
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTRACT = ROOT / 'contracts/214-vybor-vladelca-risk-repo.md'
OWN = [('architect', 'contracts/214-vybor-vladelca-risk-repo.md'),
       ('architect', 'fixtures/workshop_project/doverennyj_vladelec_214/'),
       ('implementer', 'scripts/zamok_predmeta.sh'),
       ('implementer', 'fixtures/workshop_project/d52_bootstrap_sudej_211/'),
       ('orchestrator', 'registry/ci-steps.tsv'),
       ('orchestrator', 'registry/ci-zamery.tsv'),
       ('orchestrator', '.github/workflows/ci.yml')]


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True, text=True, check=True).stdout.strip()


def declarations():
    tags = {}
    for ref in git('for-each-ref', '--format=%(refname:short)', 'refs/tags/frozen/contracts/').splitlines():
        match = re.fullmatch(r'frozen/contracts/([0-9]{3})/([0-9]+)', ref)
        if match:
            n, v = match.groups()
            if n not in tags or int(v) > tags[n][0]:
                tags[n] = int(v), ref
    result = set()
    for n, (_, tag) in sorted(tags.items()):
        files = [p for p in git('ls-tree', '-r', '--name-only', tag, '--', 'contracts/').splitlines() if re.fullmatch('contracts/' + n + r'-[^/]+\.md', p)]
        if len(files) != 1:
            raise RuntimeError('AMBIGUOUS_FROZEN ' + tag)
        text = git('show', tag + '^{commit}:' + files[0])
        matched = []
        for line in text.splitlines():
            match = re.fullmatch(r'ЗОНА ([^:]+): (.+)', line)
            if not match:
                continue
            author, paths = match.groups()
            for old in paths.split():
                for own_author, own in OWN:
                    overlap = old == own or (old.endswith('/') and own.startswith(old)) or (own.endswith('/') and old.startswith(own))
                    if overlap and (author != own_author or own == 'scripts/zamok_predmeta.sh'):
                        reason = 'только свой шаг/замер 214; чужие строки сохранены'
                        if own_author == 'architect':
                            reason = 'только контракт/семья 214; чужие семьи сохранены'
                        if own_author == 'implementer':
                            reason = 'только доверенный владелец и закоммиченный источник риска; остальные двери сохранены'
                        result.add(f'ПЕРЕСЕЧЕНИЕ {own_author}: {own} — {n} {reason}')
                        matched.append(line)
        if matched:
            print('ИСТОЧНИК', tag, git('rev-parse', tag + '^{commit}'), files[0])
            print('\n'.join(sorted(set(matched))))
    if not result:
        raise RuntimeError('EMPTY_OVERLAP_CENSUS')
    return sorted(result)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--emit', action='store_true')
    args = ap.parse_args()
    rows = declarations()
    print('ДЕКЛАРАЦИИ', len(rows))
    print('\n'.join(rows))
    if not args.emit:
        declared = [line for line in CONTRACT.read_text().splitlines() if line.startswith('ПЕРЕСЕЧЕНИЕ ')]
        if declared != rows:
            raise RuntimeError('OVERLAP_DECLARATIONS_DRIFT')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
