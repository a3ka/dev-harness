#!/usr/bin/env python3
"""231: highest frozen source blobs and exact zone intersections, using 224's canon."""
import importlib.util
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('context224', HERE.parent / 'svezhest_verdikta_done_224/context.py')
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
OWN = [('architect', 'contracts/231-sovmestimost-doski-224.md'),
       ('architect', 'contracts/224-svezhest-verdikta-done.md'),
       ('architect', 'contracts/201-done-dver-soderzhatelnaja-sverka.md'),
       ('architect', 'fixtures/workshop_project/svezhest_verdikta_done_224/probe.py'),
       ('architect', 'config/done_forms.json'),
       ('architect', 'config/done_forms.schema.json'),
       ('implementer', 'config/done_forms.json'),
       ('implementer', 'config/done_forms.schema.json'),
       ('architect', 'fixtures/workshop_project/done_round_compat_231/'),
       ('implementer', 'scripts/done_contract.sh'),
       ('orchestrator', 'registry/ci-steps.tsv'),
       ('orchestrator', 'registry/ci-zamery.tsv'),
       ('orchestrator', '.github/workflows/ci.yml')]


def declarations():
    import re
    tags = {}
    for ref in prior.git('for-each-ref', '--format=%(refname:short)', 'refs/tags/frozen/contracts/').splitlines():
        match = re.fullmatch(r'frozen/contracts/([0-9]{3})/([0-9]+)', ref)
        if match:
            n, v = match.groups()
            if n not in tags or int(v) > tags[n][0]:
                tags[n] = int(v), ref
    found = set()
    for n, (_, tag) in sorted(tags.items()):
        paths = [p for p in prior.git('ls-tree', '-r', '--name-only', tag, '--', 'contracts/').splitlines()
                 if re.fullmatch('contracts/' + n + r'-[^/]+\.md', p)]
        if len(paths) != 1:
            raise RuntimeError('FROZEN_PATH ' + tag)
        text = prior.git('show', tag + '^{commit}:' + paths[0])
        matched = set()
        for line in text.splitlines():
            match = re.fullmatch(r'ЗОНА ([^:]+): (.+)', line)
            if not match:
                continue
            author, old_paths = match.groups()
            for old in old_paths.split():
                for own_author, own in OWN:
                    if old == own or (old.endswith('/') and own.startswith(old)) or (own.endswith('/') and old.startswith(own)):
                        if author != own_author or own == 'scripts/done_contract.sh':
                            reason = 'только свои CI-шаг и замер 231; чужие строки сохраняются'
                            if own_author == 'architect':
                                reason = 'только переход R-0162: 231, адресные v+1 224/201 и две клетки 224'
                            if own_author == 'implementer':
                                reason = 'только совместимость входов done из конфига; F/CID/OBJECT и остальные двери сохраняются'
                            found.add(f'ПЕРЕСЕЧЕНИЕ {own_author}: {own} — {n} {reason}')
                            matched.add(line)
        if matched:
            print('ИСТОЧНИК', tag, prior.git('rev-parse', tag + '^{commit}'), paths[0])
            print('\n'.join(sorted(matched)))
    if not found:
        raise RuntimeError('EMPTY_OVERLAPS')
    return sorted(found)


if __name__ == '__main__':
    rows = declarations()
    print('ДЕКЛАРАЦИИ', len(rows))
    print('\n'.join(rows))
