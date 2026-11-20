"""140: verdict-only descendants preserve the original code OBJECT, not just its tree."""
import argparse
from pathlib import Path
import tempfile
import co_review_140

CASES = {
    'q01-verdikt-ne-sdvigaet-object': 'adversary→reviewer;исходный-OBJECT;START-пара-сохранены',
    'q02-tip-verdikta-ne-novyj-object': 'tip-вердикта-не-обнуляет-суд',
    'q03-smeshannyj-kommit': 'код-внутри-вердиктного-хвоста;отказ',
    'q04-kod-izmenen-i-vozvrashchen': 'нетто-дерево-прежнее;каждый-коммит-проверяется',
    'q05-chuzhoj-predmet': 'вердикт-другого-предмета-не-прозрачен',
    'q06-chuzhoj-avtor': 'judge-канал;author-и-committer',
    'q07-dva-object': 'дублированный-OBJECT-не-принимается',
    'q08-symlink': 'вердикт-только-обычный-blob',
    'q09-merge': 'merge-не-вердиктный-линейный-хвост',
    'q10-povtor-roli': 'тот-же-OBJECT;счёт-не-сбрасывается',
    'q11-object-tolko-chitaet': 'общий-resolver;ветка-и-учёт-неизменны',
    'q12-ne-predok': 'OBJECT-не-предок;отказ',
    'q13-novyj-kod': 'новая-реальная-правка;новый-OBJECT-разрешён',
    'q14-chuzhoj-object-v-seredine': 'каждый-вердикт-связан-с-тем-же-OBJECT',
    'q15-ispolnimyj-verdikt': 'mode-100755-не-прозрачен',
    'q16-pustoj-kommit': 'пустой-коммит-в-хвосте-не-сдача',
    'q25-verdikt-i-review': 'проверенный-reviewer;verdict+.review;OBJECT-сохранён',
    'q26-review-i-postoronnij-put': 'verdict+.review+product;новый-OBJECT',
    'q27-review-symlink': '.review-только-mode100644;отказ-без-START',
    'q28-review-bez-verdikta': '.review-only;канонический-OBJECT-родителя;допуск',
}
BINDINGS = {
    's62-object-tolko-tip': ['q01-verdikt-ne-sdvigaet-object', 'q11-object-tolko-chitaet'],
    's63-object-tolko-poslednij': ['q04-kod-izmenen-i-vozvrashchen'],
    's64-verdikt-bez-puti': ['q03-smeshannyj-kommit'],
    's65-verdikt-bez-avtora': ['q06-chuzhoj-avtor'],
    's66-verdikt-bez-binding': ['q14-chuzhoj-object-v-seredine'],
    's67-verdikt-bez-mode': ['q15-ispolnimyj-verdikt'],
    's68-verdikt-pustoj': ['q16-pustoj-kommit'],
    's73-review-ne-prozrachen': ['q25-verdikt-i-review'],
    's74-review-only-novyj-koren': ['q28-review-bez-verdikta'],
}
CASES.update(co_review_140.CASES)
BINDINGS.update(co_review_140.BINDINGS)


def dobavit(K, p):
    def git(wt, *args, role='adversary'):
        r = p.run(['git', '-c', 'user.name='+role, '-c', 'user.email='+role+'@t',
                   '-c', 'commit.gpgsign=false', *args], cwd=str(wt))
        assert r.returncode == 0, r.stderr
        return r.stdout.strip()

    def world(m):
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-fixture.md', 'КЛАСС РИСКА: рисковый\n')])
        wt = Path(wt)
        m.start('140', 'Arch140', wt=str(wt), branch=br)
        m.zhurnal('Arch140', sdal=True)
        m.start('140', 'Adv140', klass='sudja', rol='adversary', obj=obj, zanyat=False)
        m.zhurnal('Adv140', sdal=True)
        return wt, br, obj

    def verdict(wt, obj, role='adversary', subject='140', suffix='impl-v1',
                duplicate=False, executable=False, symlink=False, mixed=False,
                review=False, review_symlink=False):
        channel = 'review' if role == 'reviewer' else 'adversary'
        path = wt / ('verdicts/%s/contracts-%s-%s.md' % (channel, subject, suffix))
        path.parent.mkdir(parents=True, exist_ok=True)
        body = 'accept\nOBJECT='+obj+'\n\n# Arbitrary judgement body\n'
        if duplicate:
            body += 'OBJECT='+obj+'\n'
        if symlink:
            path.symlink_to('untrusted')
        else:
            path.write_text(body)
            if executable:
                path.chmod(0o755)
        if review:
            note = wt / '.review/2026-11-19-140.md'
            note.parent.mkdir(exist_ok=True)
            if review_symlink:
                note.symlink_to('untrusted')
            else:
                note.write_text('---\nobject: '+obj+'\n---\n# Findings\n')
        if mixed:
            # All other fields look honest; the path whitelist alone must refuse this.
            (wt / 'verdicts/adversary/product.py').write_text('OBJECT='+obj+'\n')
        git(wt, 'add', '-A')
        return git(wt, 'commit', '-q', '-m', 'judge artifact', role=role)

    def judge(m, door, obj, role='reviewer'):
        event = m.sobytie('judge.json', [p.item(role, 'Next140',
                           ['SUBJECT=140', 'OBJECT='+obj])])
        before = m.ledger.read_bytes()
        branch = m.ledg()[0]['branch']
        wt = m.ledg()[0]['worktree']
        tip = git(wt, 'rev-parse', branch)
        r = p.sudit(door, m, event)
        problems = []
        if git(wt, 'rev-parse', branch) != tip:
            problems.append('суд сдвинул рабочую ветку')
        if r.returncode == 0:
            rows = m.ledg()
            # The original worker pair stays in its original, byte-preserved START.
            # A judge's own START keeps the frozen '-' worktree/branch convention.
            if (not m.ledger.read_bytes().startswith(before) or len(rows) != 3
                    or rows[-1].get('object') != obj):
                problems.append('исходный START/OBJECT/счёт изменены')
        elif m.ledger.read_bytes() != before:
            problems.append('отказ переписал учёт')
        return r, problems

    def cell(m, door, name):
        wt, br, obj = world(m)
        want, reason = 1, 'OBJECT_RASHODITSJA'
        requested = obj
        role = 'reviewer'
        if name == 'q03-smeshannyj-kommit':
            verdict(wt, obj, suffix='mixed', mixed=True)
        elif name == 'q04-kod-izmenen-i-vozvrashchen':
            path = wt / 'contracts/140-fixture.md'
            original = path.read_bytes()
            path.write_text('КЛАСС РИСКА: обычный\n')
            git(wt, 'commit', '-qam', 'different code')
            path.write_bytes(original)
            git(wt, 'commit', '-qam', 'reverted code')
        elif name == 'q05-chuzhoj-predmet':
            verdict(wt, obj, subject='141')
        elif name == 'q06-chuzhoj-avtor':
            verdict(wt, obj, role='implementer')
        elif name == 'q07-dva-object':
            verdict(wt, obj, duplicate=True)
        elif name == 'q08-symlink':
            verdict(wt, obj, symlink=True)
        elif name == 'q09-merge':
            git(wt, 'branch', 'side', obj)
            git(wt, 'switch', '-q', 'side')
            verdict(wt, obj, suffix='side')
            git(wt, 'switch', '-q', br)
            verdict(wt, obj, suffix='main')
            git(wt, 'merge', '-q', '--no-ff', 'side', '-m', 'merged verdicts')
        elif name == 'q12-ne-predok':
            requested = p.OBJECT_DUMMY
        elif name == 'q14-chuzhoj-object-v-seredine':
            verdict(wt, p.OBJECT_DUMMY, suffix='foreign')
        elif name == 'q15-ispolnimyj-verdikt':
            verdict(wt, obj, suffix='exec', executable=True)
        elif name == 'q16-pustoj-kommit':
            git(wt, 'commit', '-q', '--allow-empty', '-m', 'empty')
        elif name in ('q25-verdikt-i-review', 'q26-review-i-postoronnij-put',
                      'q27-review-symlink', 'q28-review-bez-verdikta'):
            verdict(wt, obj, role='reviewer', suffix='review', review=True,
                    review_symlink=(name == 'q27-review-symlink'))
            if name == 'q26-review-i-postoronnij-put':
                (wt / 'product.txt').write_text('not a verdict artifact\n')
                git(wt, 'add', '-A')
                git(wt, 'commit', '-qm', 'new product', role='architect')
                requested = git(wt, 'rev-parse', br)
                want = 0
            elif name == 'q28-review-bez-verdikta':
                (wt / '.review/2026-11-19-140.md').write_text('# standalone findings\n')
                git(wt, 'commit', '-qam', 'standalone review', role='reviewer')
                want = 0
            elif name == 'q25-verdikt-i-review':
                want = 0
        if name not in ('q05-chuzhoj-predmet', 'q06-chuzhoj-avtor',
                        'q07-dva-object', 'q08-symlink',
                        'q25-verdikt-i-review', 'q26-review-i-postoronnij-put',
                        'q27-review-symlink', 'q28-review-bez-verdikta'):
            verdict(wt, obj, suffix='last')
        if name == 'q01-verdikt-ne-sdvigaet-object':
            # A second honest judge commit with a different body, same independent OBJECT.
            verdict(wt, obj, role='reviewer', suffix='second')
            want = 0
        elif name == 'q02-tip-verdikta-ne-novyj-object':
            requested = git(wt, 'rev-parse', br)
        elif name == 'q10-povtor-roli':
            role, reason = 'adversary', 'OBJECT_UZHE_SUZHEN'
        elif name == 'q11-object-tolko-chitaet':
            before = p.snimok_fajlov(m.sost)
            tip = git(wt, 'rev-parse', br)
            r = p.run([p.BASH, str(door), '--object', '--repo', str(wt), '140', br])
            return [p.k_rc(r, 0, 'resolver'),
                    None if r.stdout == obj+'\n' else 'resolver выдал не исходный OBJECT',
                    None if before == p.snimok_fajlov(m.sost) else 'resolver записал состояние',
                    None if tip == git(wt, 'rev-parse', br) else 'resolver сдвинул ветку']
        elif name == 'q13-novyj-kod':
            (wt / 'product.py').write_text('real_work = True\n')
            git(wt, 'add', '-A')
            git(wt, 'commit', '-q', '-m', 'new code', role='architect')
            requested = git(wt, 'rev-parse', br)
            want = 0
        r, problems = judge(m, door, requested, role)
        problems.append(p.k_rc(r, want, 'D9'))
        if want:
            problems.append(p.k_prichina(r, reason, 'причина'))
        return problems

    for name, axes in CASES.items():
        K[name] = dict(osi=axes, run=lambda m, d, name=name: cell(m, d, name))
    co_review_140.dobavit(K, p)


def mutacii(z):
    return {
        's62-object-tolko-tip': lambda t: z(t,
            '  # Непредметный/смешанный коммит — новая кодовая граница, не вердиктный хвост.',
            '  printf \'%s\\n\' "$tip"; return 0 # стаб: только tip'),
        's63-object-tolko-poslednij': lambda t: z(t,
            '  entries="$(git -C "$wt" rev-list "$base..$tip")" || return 1',
            '  entries="$tip" # стаб: нет истории'),
        's64-verdikt-bez-puti': lambda t: z(t,
            '      [[ "$p" =~ ^verdicts/(critic|adversary|review)/contracts-$n(-[A-Za-z0-9._-]+)?\\.md$ \\\n        || "$p" =~ ^\\.review/[A-Za-z0-9._-]+\\.md$ ]] || return 1',
            '      : # стаб: любой путь'),
        's65-verdikt-bez-avtora': lambda t: z(t,
            '      [ "$(git -C "$wt" show -s --format=%an "$c")" = "$role" ] \\\n        && [ "$(git -C "$wt" show -s --format=%cn "$c")" = "$role" ] || return 1',
            '      : # стаб: автор не проверяется'),
        's66-verdikt-bez-binding': lambda t: z(t,
            '      [ "$value" = "OBJECT=$base" ] || return 1',
            '      : # стаб: OBJECT чужого вердикта'),
        's67-verdikt-bez-mode': lambda t: z(t,
            '      [[ "$(git -C "$wt" ls-tree "$c" -- "$p")" == "100644 blob "* ]] || return 1',
            '      : # стаб: исполнимый вердикт'),
        's68-verdikt-pustoj': lambda t: z(t,
            '    [ -n "$paths" ] || return 1',
            '    [ -n "$paths" ] || continue # стаб: пустой коммит прозрачен'),
        's73-review-ne-prozrachen': lambda t: z(t,
            '      || "$p" =~ ^\\.review/[A-Za-z0-9._-]+\\.md$ ]] \\',
            '      ]] \\'),
        's74-review-only-novyj-koren': lambda t: z(t,
            '    base="$(object_kandidata "$wt" "$n" "$tip^1")" || return 1',
            '    printf \'%s\\n\' "$tip"; return 0 # стаб: .review-only новый корень'),
        **co_review_140.mutacii(z),
    }


def prepare(p, before=False):
    """Real pre_judge; only its pre-existing detector seam is controlled (172/185)."""
    import shutil
    failed = 0
    with tempfile.TemporaryDirectory(prefix='object140-prepare-') as directory:
        m = p.Mir(directory)
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-fixture.md', 'КЛАСС РИСКА: обычный\n')])
        path = Path(wt) / 'verdicts/adversary/contracts-140-impl-v1.md'
        path.parent.mkdir(parents=True)
        path.write_text('accept\nOBJECT='+obj+'\n')
        def git(*args):
            result = p.run(['git', '-c', 'user.name=adversary', '-c',
                            'user.email=a@t', *args], cwd=wt)
            assert result.returncode == 0, result.stderr
            return result.stdout.strip()
        git('add', '-A')
        git('commit', '-qm', 'verdict only')
        tip = git('rev-parse', br)
        git('update-ref', 'refs/remotes/origin/'+br, tip)
        install = Path(directory) / 'installation/scripts'
        install.mkdir(parents=True)
        for name in ('pre_judge.sh', 'zamok_predmeta.sh'):
            shutil.copyfile(p.REEPOR / 'scripts' / name, install / name)
        (install / 'check_no_leak.sh').write_text(
            '#!/bin/sh\n[ ! -e "$2/leak.flag" ]\n')
        command = [p.BASH, str(install / 'pre_judge.sh'), 'prepare', '--repo', wt,
                   '--branch', br, '--sostojanie', str(m.sost), '--timeout', '0.05']
        for state, want, marker in (
                ('published', 0, 'OBJECT='+(tip if before else obj)),
                ('leak', 1, 'ОТКАЗ: CHECK_NO_LEAK_KRASEN'),
                ('unpublished', 1, 'ОТКАЗ: VETKA_NE_OPUBLIKOVANA')):
            if state == 'leak':
                (Path(wt) / 'leak.flag').touch()
            elif state == 'unpublished':
                git('update-ref', '-d', 'refs/remotes/origin/'+br)
            r = p.run(command)
            lines = (r.stdout+'\n'+r.stderr).splitlines()
            ok = r.returncode == want and marker in lines
            print('PREPARE_BEFORE' if before else 'PREPARE', state, 'ok' if ok else
                  'BAD rc=%s stdout=%r stderr=%r' % (r.returncode, r.stdout, r.stderr))
            failed += not ok
            failed += git('rev-parse', br) != tip
            failed += m.ledger.read_bytes() != b''
    return int(bool(failed))


def main():
    import probe as p
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--check', action='store_true')
    modes.add_argument('--prepare', action='store_true')
    args = parser.parse_args()
    if args.prepare:
        return prepare(p)
    K = p.kejsy()
    failed = 0
    bindings = dict(BINDINGS)
    bindings.update({key: [name for name in inputs if name.startswith('q')]
                     for key, inputs in p.produkt_140.BINDINGS.items()
                     if any(name.startswith('q') for name in inputs)})
    for name in CASES:
        problems = p.progon(p.MODEL, name, K[name]['run'])
        print('MODEL', name, problems or 'ok')
        failed += bool(problems)
    # Mutants live only in this isolated fixture world, never in production.
    with tempfile.TemporaryDirectory(prefix='object140-') as directory:
        base = p.MODEL.read_text()
        for mutant, inputs in bindings.items():
            path = Path(directory) / (mutant+'.sh')
            path.write_text(p.STAB_MUTACII[mutant](base))
            syntax = p.run([p.BASH, '-n', str(path)])
            if syntax.returncode:
                print('INVALID_MUTANT', mutant, syntax.stderr)
                failed += 1
                continue
            for name in inputs:
                caught = bool(p.progon(path, name, K[name]['run']))
                print('MUTANT', mutant, name, 'caught' if caught else 'LIVE')
                failed += not caught
    # The implementation is intentionally not installed by the architect.
    for name in ('q01-verdikt-ne-sdvigaet-object', 'q02-tip-verdikta-ne-novyj-object'):
        problems = p.progon(p.SUBJEKT_DVERI, name, K[name]['run'])
        print('PRODUCTION_BEFORE', name, problems or 'UNEXPECTED_GREEN')
        failed += not bool(problems)
    failed += prepare(p, before=True)
    print('OBJECT140_COUNTS cases=%d mutants=%d bindings=%d all_cases=%d' %
          (len(CASES), len(bindings), sum(map(len, bindings.values())), len(K)))
    print('OBJECT140_FAILURES', failed)
    return int(bool(failed))


if __name__ == '__main__':
    raise SystemExit(main())
