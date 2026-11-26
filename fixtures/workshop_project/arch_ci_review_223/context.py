#!/usr/bin/env python3
"""223: highest frozen blobs and literal overlap declarations, no repository edits."""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OWN = [('architect', 'contracts/223-arch-ci-review.md'),
       ('architect', 'fixtures/workshop_project/arch_ci_review_223/'),
       ('implementer', 'scripts/done_contract.sh'),
       ('orchestrator', 'registry/ci-steps.tsv'),
       ('orchestrator', 'registry/ci-zamery.tsv'),
       ('orchestrator', '.github/workflows/ci.yml')]


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True,
                          capture_output=True, text=True).stdout.strip()


def census():
    tags = {}
    for ref in git('for-each-ref', '--format=%(refname:short)', 'refs/tags/frozen/contracts/').splitlines():
        match = re.fullmatch(r'frozen/contracts/([0-9]{3})/([0-9]+)', ref)
        if match:
            n, v = match.groups()
            if n not in tags or int(v) > tags[n][0]:
                tags[n] = int(v), ref
    declarations, sources = set(), []
    for n, (_, tag) in sorted(tags.items()):
        files = [p for p in git('ls-tree', '-r', '--name-only', tag, '--', 'contracts/').splitlines()
                 if re.fullmatch('contracts/' + n + r'-[^/]+\.md', p)]
        if len(files) != 1:
            raise RuntimeError('AMBIGUOUS_FROZEN ' + tag)
        text = git('show', tag + '^{commit}:' + files[0])
        matched = set()
        for line in text.splitlines():
            match = re.fullmatch(r'ЗОНА ([^:]+): (.+)', line)
            if not match:
                continue
            author, paths = match.groups()
            for old in paths.split():
                for own_author, own in OWN:
                    overlap = old == own or (old.endswith('/') and own.startswith(old)) or (own.endswith('/') and old.startswith(own))
                    if overlap and (author != own_author or own == 'scripts/done_contract.sh'):
                        reason = 'только CI 223, чужие шаги без изменений'
                        if own_author == 'architect':
                            reason = 'новая семья 223'
                        if own_author == 'implementer':
                            reason = 'только пути SHA*, остальные гейты сохранены'
                        declarations.add(f'ПЕРЕСЕЧЕНИЕ {own_author}: {own} — {n} {reason}')
                        matched.add(line)
        if matched:
            sources.append((tag, git('rev-parse', tag + '^{commit}'), files[0], sorted(matched)))
    if not declarations:
        raise RuntimeError('EMPTY_CENSUS')
    return sorted(declarations), sources


def main():
    declarations, sources = census()
    for tag, sha, path, lines in sources:
        print('ИСТОЧНИК', tag, sha, path)
        print('\n'.join(lines))
    print('ДЕКЛАРАЦИИ', len(declarations))
    print('\n'.join(declarations))
    contract = ROOT / 'contracts/223-arch-ci-review.md'
    text = contract.read_text()
    if sys.argv[1:] == ['--write']:
        start = text.index('## Пересечения\n') + len('## Пересечения\n')
        end = text.index('## Предпосылки\n', start)
        text = text[:start] + '\n' + '\n'.join(declarations) + '\n\n' + text[end:]
        contract.write_text(text)
    if any(line not in text.splitlines() for line in declarations):
        raise RuntimeError('CONTRACT_OVERLAPS_INCOMPLETE')


if __name__ == '__main__':
    main()
