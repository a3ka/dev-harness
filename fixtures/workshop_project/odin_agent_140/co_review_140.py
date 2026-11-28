"""Addressed 140 co-review hypotheses; fixtures, not a runtime sandbox."""
import argparse
from pathlib import Path
import tempfile

CASES = {
    'q17-object-predydushchego-verdikta': 'C→V1(C)→V2(V1);повтор-роли-не-сбрасывается',
    'q18-object-root-resolver': 'корень-не-самодекларация;неверный-якорь-отвергнут',
    'q19-pustoj-finalnyj-tip': 'пустой-последний-коммит;не-новый-OBJECT',
    'q20-pustoj-finalnyj-merge': 'пустая-merge-дельта;resolver-отказывает;D9c-допускает-tip',
    'q21-runtime-source-md': 'mode100644;source-md;runtime-из-OBJECT',
    'q22-runtime-python-md': 'mode100644;runpy-md;runtime-из-OBJECT',
    'q23-runtime-chestnyj-ekvivalent': 'инертная-правка-тела;законный-хвост-зелён',
    'q24-nepustoj-finalnyj-merge': 'merge;дельта-к-первому-родителю;новый-OBJECT-допущен',
    'q29-stancija-frozen-obychnyj-object-riskovyj': 'станционный-владелец;frozen-обычный;OBJECT-рисковый;допуск',
    'q30-stancija-frozen-riskovyj-object-obychnyj': 'станционный-владелец;frozen-рисковый;OBJECT-обычный;отказ',
    'q31-stancija-frozen-net': 'станционный-владелец;frozen-tag-нет;fail-closed',
}
BINDINGS = {
    's69-object-bez-kornja': ['q17-object-predydushchego-verdikta', 'q18-object-root-resolver'],
    's70-object-pustoj-tip': ['q19-pustoj-finalnyj-tip', 'q20-pustoj-finalnyj-merge'],
    's71-runtime-iz-tip': ['q21-runtime-source-md', 'q22-runtime-python-md'],
    's72-merge-bez-pervogo-roditelja': ['q24-nepustoj-finalnyj-merge'],
    's75-stancija-bez-frozen-ref': ['q31-stancija-frozen-net'],
}


def dobavit(K, p):
    def git(wt, *args, role='adversary'):
        r = p.run(['git', '-c', 'user.name='+role, '-c', 'user.email='+role+'@t',
                   '-c', 'commit.gpgsign=false', *args], cwd=str(wt))
        assert r.returncode == 0, r.stderr
        return r.stdout.strip()

    def verdict(wt, obj, suffix, body='', python=False):
        path = wt / ('verdicts/adversary/contracts-140-'+suffix+'.md')
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(('"""\n' if python else '')+'OBJECT='+obj+'\n'
                        +('"""\n' if python else '')+body)
        git(wt, 'add', '-A')
        git(wt, 'commit', '-qm', 'verdict')
        return git(wt, 'rev-parse', 'HEAD')

    def cell(m, door, name, baseline_runtime=False):
        risk = 'рисковый' if name == 'q30-stancija-frozen-riskovyj-object-obychnyj' else 'обычный'
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-fixture.md', 'КЛАСС РИСКА: '+risk+'\n')])
        wt = Path(wt)
        runtime = name in ('q21-runtime-source-md', 'q22-runtime-python-md',
                           'q23-runtime-chestnyj-ekvivalent')
        if runtime:
            python = name == 'q22-runtime-python-md'
            loader = ('import runpy\nrunpy.run_path("verdicts/adversary/contracts-140-runtime.md")\n'
                      if python else '. ./verdicts/adversary/contracts-140-runtime.md\n')
            (wt / 'loader').write_text(loader)
            body = 'print("OBJECT_RUNTIME")\n' if python else 'printf "OBJECT_RUNTIME\\n"\n'
            verdict(wt, p.OBJECT_DUMMY, 'runtime', body, python=python)
            # The code boundary is an ordinary non-verdict change containing the loader.
            obj = git(wt, 'rev-parse', 'HEAD')
        m.start('140', 'Arch140', wt=str(wt), branch=br)
        m.zhurnal('Arch140', sdal=True)
        if name.startswith(('q29-', 'q30-', 'q31-')):
            before = m.ledger.read_bytes()
            if name == 'q31-stancija-frozen-net':
                m.git(['tag', '-d', 'frozen/contracts/140/1'])
                want, reason = 1, 'ADVERSARIJ_DO_REVJUERA'
            else:
                opposite = 'обычный' if risk == 'рисковый' else 'рисковый'
                (wt / 'contracts/140-fixture.md').write_text('КЛАСС РИСКА: '+opposite+'\n')
                git(wt, 'commit', '-qam', 'different OBJECT risk', role='architect')
                obj = git(wt, 'rev-parse', br)
                want, reason = (1, 'ADVERSARIJ_DO_REVJUERA') if risk == 'рисковый' else (0, None)
            event = m.sobytie('judge.json', [p.item('reviewer', 'Risk140',
                                ['SUBJECT=140', 'OBJECT='+obj])])
            r = p.sudit(door, m, event)
            problems = [p.k_rc(r, want, 'frozen-станционного-владельца')]
            if want:
                problems += [p.k_prichina(r, reason, 'причина'),
                             None if m.ledger.read_bytes() == before else 'отказ изменил START/счёт']
            else:
                problems += [None if m.ledger.read_bytes().startswith(before) else 'START переписан',
                             None if len(m.ledg()) == 2 and m.ledg()[-1].get('object') == obj else 'счёт/OBJECT сдвинут']
            return problems
        m.start('140', 'Adv140', klass='sudja', rol='adversary', obj=obj, zanyat=False)
        m.zhurnal('Adv140', sdal=True)
        before = m.ledger.read_bytes()
        if name in ('q17-object-predydushchego-verdikta', 'q18-object-root-resolver'):
            v1 = verdict(wt, obj, 'first')
            verdict(wt, v1, 'second')
            requested = v1
        elif name == 'q19-pustoj-finalnyj-tip':
            verdict(wt, obj, 'first')
            git(wt, 'commit', '-q', '--allow-empty', '-m', 'empty tip')
            requested = git(wt, 'rev-parse', 'HEAD')
        elif name == 'q20-pustoj-finalnyj-merge':
            verdict(wt, obj, 'first')
            git(wt, 'branch', 'empty-side')
            git(wt, 'switch', '-q', 'empty-side')
            git(wt, 'commit', '-q', '--allow-empty', '-m', 'empty side')
            git(wt, 'switch', '-q', br)
            git(wt, 'commit', '-q', '--allow-empty', '-m', 'empty main')
            git(wt, 'merge', '-q', '--no-ff', 'empty-side', '-m', 'empty merge')
            requested = git(wt, 'rev-parse', 'HEAD')
        elif name == 'q24-nepustoj-finalnyj-merge':
            git(wt, 'switch', '-q', '-c', 'code-side')
            (wt / 'product.py').write_text('real_merge = True\n')
            git(wt, 'add', '-A')
            git(wt, 'commit', '-qm', 'side code', role='architect')
            git(wt, 'switch', '-q', br)
            git(wt, 'merge', '-q', '--no-ff', 'code-side', '-m', 'nonempty merge', role='architect')
            tip = git(wt, 'rev-parse', br)
            event = m.sobytie('judge.json', [p.item('reviewer', 'Merge140',
                                ['SUBJECT=140', 'OBJECT='+tip])])
            r = p.sudit(door, m, event)
            return [p.k_rc(r, 0, 'непустой-merge'),
                    None if m.ledger.read_bytes().startswith(before) else 'переписан START',
                    None if len(m.ledg()) == 3 and m.ledg()[-1].get('object') == tip else 'не новый OBJECT',
                    None if git(wt, 'rev-parse', br) == tip else 'сдвинута рабочая ветка']
        else:
            honest = name == 'q23-runtime-chestnyj-ekvivalent'
            body = ('print("TIP_RUNTIME")\n' if python else 'printf "TIP_RUNTIME\\n"\n') if not honest else '# unchanged runtime\n'+body
            verdict(wt, obj, 'runtime', body, python=python)
            tip = git(wt, 'rev-parse', 'HEAD')
            command = ['/usr/bin/python3', 'loader'] if python else [p.BASH, 'loader']
            # Observe that the exploit actually loads a non-executable Markdown file.
            live = p.run(command, cwd=str(wt))
            expected_tip = 'OBJECT_RUNTIME\n' if honest else 'TIP_RUNTIME\n'
            problems = [p.k_rc(live, 0, 'runtime-tip'),
                        None if live.stdout == expected_tip else 'не воспроизведена загрузка md',
                        None if git(wt, 'ls-tree', tip, '--', 'verdicts/adversary/contracts-140-runtime.md').startswith('100644 blob ') else 'не mode100644']
            if baseline_runtime:
                r = p.run([p.BASH, str(door), '--object', '--repo', str(wt), '140', br])
                return problems + [p.k_rc(r, 0, 'baseline-resolver'),
                                   None if r.stdout == obj+'\n' else 'baseline не сохранил OBJECT']
            snapshot = m.root / 'runtime-object'
            r = p.run([p.BASH, str(door), '--snapshot', '--repo', str(wt), '140', br, str(snapshot)])
            problems.append(p.k_rc(r, 0, 'runtime-snapshot'))
            if r.returncode == 0:
                expected = ['OBJECT='+obj, 'RUNTIME_WORKTREE='+str(snapshot)]
                problems.append(None if r.stdout.splitlines() == expected else 'snapshot не связан с OBJECT')
                problems.append(None if git(snapshot, 'rev-parse', 'HEAD') == obj else 'snapshot checkout не OBJECT')
                result = p.run(command, cwd=str(snapshot))
                problems += [p.k_rc(result, 0, 'runtime-object'),
                             None if result.stdout == 'OBJECT_RUNTIME\n' else 'runtime загрузил тело из tip']
                git(wt, 'worktree', 'remove', str(snapshot))
            problems += [None if git(wt, 'rev-parse', br) == tip else 'сдвинута рабочая ветка',
                         None if m.ledger.read_bytes() == before else 'snapshot переписал учёт']
            return problems
        tip = git(wt, 'rev-parse', br)
        if name == 'q18-object-root-resolver':
            r = p.run([p.BASH, str(door), '--object', '--repo', str(wt), '140', br])
        else:
            event = m.sobytie('judge.json', [p.item('adversary', 'Again140',
                                ['SUBJECT=140', 'OBJECT='+requested])])
            if name == 'q20-pustoj-finalnyj-merge':
                # 208 И-1/4: resolver прежний; только D9c принимает merge-tip.
                resolved = p.run([p.BASH, str(door), '--object', '--repo', str(wt), '140', br])
                resolver_problems = [
                    p.k_rc(resolved, 1, 'пустой-merge-resolver'),
                    p.k_prichina(resolved, 'OBJECT_RASHODITSJA', 'причина-resolver'),
                    None if m.ledger.read_bytes() == before else 'resolver изменил учёт']
            r = p.sudit(door, m, event)
        if name == 'q18-object-root-resolver':
            return [p.k_rc(r, 1, 'read-only-resolver'),
                    p.k_prichina(r, 'OBJECT_RASHODITSJA', 'не новый кандидат'),
                    None if m.ledger.read_bytes() == before else 'resolver изменил учёт']
        if name == 'q20-pustoj-finalnyj-merge':
            return resolver_problems + [
                p.k_rc(r, 0, 'D9c-merge'),
                None if not r.stderr else 'D9c ошибочно предупреждает: '+r.stderr,
                None if m.ledger.read_bytes().startswith(before) else 'переписан START',
                p.k_chislo_startov(m, 'D9c-START', 3),
                p.k_stroka(m, 'D9c-запрошенный-OBJECT', holder='Again140', object=requested),
                None if git(wt, 'rev-parse', br) == tip else 'сдвинута рабочая ветка']
        return p.k_warn(r, m, 'OBJECT_RASHODITSJA', '140') + [
                None if m.ledger.read_bytes().startswith(before) else 'переписан START',
                p.k_stroka(m, 'fallback-фактический-OBJECT', holder='Again140', object=tip),
                None if git(wt, 'rev-parse', br) == tip else 'сдвинута рабочая ветка']

    for name, axes in CASES.items():
        K[name] = dict(osi=axes, run=lambda m, d, name=name: cell(m, d, name))
        K[name]['baseline_runtime'] = lambda m, d, name=name: cell(m, d, name, True)


def mutacii(z):
    return {
        's69-object-bez-kornja': lambda t: z(t,
            '  [ "$(object_kandidata "$wt" "$n" "$base")" = "$base" ] || return 1',
            '  : # стаб: последний OBJECT не проверяется как кодовый корень'),
        's70-object-pustoj-tip': lambda t: z(t,
            '  [ -n "$paths" ] || return 1 # [D50 empty-tip]',
            '  [ -n "$paths" ] || { printf \'%s\\n\' "$tip"; return 0; }'),
        's71-runtime-iz-tip': lambda t: z(t,
            '  git -C "$REPO" -c core.hooksPath=/dev/null worktree add --quiet --detach "$EVENT" "$resolved" \\',
            '  git -C "$REPO" -c core.hooksPath=/dev/null worktree add --quiet --detach "$EVENT" "refs/heads/$HOLDER_ARG" \\'),
        's72-merge-bez-pervogo-roditelja': lambda t: z(t,
            '  paths="$(puti_kommita "$wt" "$tip")" || return 1',
            '  paths="$(git -C "$wt" diff-tree --root --no-commit-id --name-only --no-renames -r "$tip")" || return 1'),
        's75-stancija-bez-frozen-ref': lambda t: z(t,
            '  return 1\n}\nperedacha_iz_ucheta()',
            '  git -C "$REPO" rev-parse --verify "$object^{commit}"\n}\nperedacha_iz_ucheta()'),
    }


def main():
    import probe as p
    parser = argparse.ArgumentParser()
    parser.add_argument('--baseline', type=Path, required=True)
    args = parser.parse_args()
    K = p.kejsy()
    failed = 0
    for name in ('q17-object-predydushchego-verdikta', 'q18-object-root-resolver',
                 'q19-pustoj-finalnyj-tip', 'q20-pustoj-finalnyj-merge'):
        problems = p.progon(args.baseline, name, K[name]['run'])
        print('BASELINE_HYPOTHESIS', name, problems or 'NOT_REPRODUCED')
        failed += not bool(problems)
    for name in ('q21-runtime-source-md', 'q22-runtime-python-md'):
        problems = p.progon(args.baseline, name, K[name]['baseline_runtime'])
        print('BASELINE_MASKED_RUNTIME', name, problems or 'OBJECT=C; runtime=TIP_RUNTIME')
        failed += bool(problems)
    # All old legal/illegal pairs and addressed co-review cases share the real door seam.
    for name in p.object_140.CASES:
        problems = p.progon(p.MODEL, name, K[name]['run'])
        print('MODEL', name, problems or 'ok')
        failed += bool(problems)
    with tempfile.TemporaryDirectory(prefix='co-review140-') as directory:
        for mutant, inputs in p.object_140.BINDINGS.items():
            path = Path(directory) / (mutant+'.sh')
            path.write_text(p.object_140.mutacii(p._z)[mutant](p.MODEL.read_text()))
            for name in inputs:
                caught = bool(p.progon(path, name, K[name]['run']))
                print('MUTANT', mutant, name, 'caught' if caught else 'LIVE')
                failed += not caught
    print('CO_REVIEW140_COUNTS cases=%d mutants=%d bindings=%d' %
          (len(p.object_140.CASES), len(p.object_140.BINDINGS),
           sum(map(len, p.object_140.BINDINGS.values()))))
    print('CO_REVIEW140_FAILURES', failed)
    return int(bool(failed))


if __name__ == '__main__':
    raise SystemExit(main())
