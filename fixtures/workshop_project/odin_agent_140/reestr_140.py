"""Ш-2: registry is profile data; public seam is --sudit plus START/warn."""
import json
from pathlib import Path

BINDINGS = {
    's87-reestr-literal-proekta': ['r01-reestr-profil-obychnyj'],
    's88-pauza-ignoriruet-profil': ['r04-pauza-profil-svoj'],
    's89-reestr-tolko-stancija': ['r01-reestr-profil-obychnyj'],
}


def dobavit(K, p):
    def register(name, axes, fn):
        K[name] = dict(osi=axes, run=fn)

    def world(m, registry, risk='обычный', pause=None):
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-frozen.md', 'КЛАСС РИСКА: '+risk+'\n')])
        if registry is not None:
            paths = dict(contracts='contracts', verdicts='.profile/verdicts',
                         fixtures='.profile/fixtures', registry=registry)
            for rel in paths.values():
                (m.repo / rel).mkdir(parents=True, exist_ok=True)
            profile = dict(schemaVersion=1, repoId=p.REPO_ID, language='bash',
                           projectLayer=dict(version='1', profilePath='.profile/project.json'),
                           workflowPaths=paths)
            (m.repo / 'harness.project.json').write_text(json.dumps(profile)+'\n')
            (m.repo / '.profile/project.json').write_text(json.dumps(dict(
                schemaVersion=1, version='1', projectId='toy140', workspaceId='toy', defaults={}))+'\n')
            (m.repo / registry / 'contracts.tsv').write_bytes(
                (m.repo / 'registry/contracts.tsv').read_bytes())
            (m.repo / 'registry/contracts.tsv').unlink()
        target = m.repo / (registry or 'registry')
        (target / 'pauzy.tsv').write_text(
            '' if pause is None else pause+'\t2026-11-21\tвладелец\tпозже\n')
        m.git(['add', '-A'])
        result = m.git(['commit', '-qm', 'profile registry world'])
        assert result.returncode == 0, result.stderr
        # Fixture validity: neither alternate directory contains registry data.
        for other in ('registry', '.harness/registry'):
            if other != (registry or 'registry'):
                assert not (m.repo / other / 'contracts.tsv').exists()
                assert not (m.repo / other / 'pauzy.tsv').exists()
        m.start('140', 'Author140', wt=wt, branch=br)
        m.zhurnal('Author140', sdal=True)
        return obj

    def judge(m, door, registry, risk='обычный', pause=None):
        obj = world(m, registry, risk, pause)
        event = m.sobytie('registry-judge.json', [p.item('reviewer', 'RegistryJudge',
                           ['SUBJECT=140', 'OBJECT='+obj])])
        before = p.snimok_fajlov(m.sost)
        result = p.sudit(door, m, event)
        reason = 'PAUZA_VLADELTSA' if pause == '140' else (
            'ADVERSARIJ_DO_REVJUERA' if risk == 'рисковый' else None)
        problems = [p.k_rc(result, 1 if reason else 0, 'суд-реестра')]
        if reason:
            problems += [p.k_prichina(result, reason, 'причина'),
                         None if p.snimok_fajlov(m.sost) == before else 'отказ изменил состояние']
        else:
            problems += [p.k_stroka(m, 'START-судьи', holder='RegistryJudge',
                                   subjectId='140', object=obj, klass='sudja')]
        # A2 defaults unknown risk to risky: rc alone cannot prove pin was read.
        problems += [None if 'KLASS_RISKA_NET' not in result.stderr else 'frozen из профиля не прочитан']
        return problems

    for name, registry, risk in (
        ('r01-reestr-profil-obychnyj', '.x/reg', 'обычный'),
        ('r02-reestr-profil-riskovyj', '.x/reg', 'рисковый'),
        ('r03-reestr-bez-profilja', None, 'обычный'),
    ):
        register(name, 'registry='+str(registry)+';frozen='+risk+';reviewer',
                 lambda m,d,r=registry,k=risk: judge(m,d,r,k))
    for name, registry, pause in (
        ('r04-pauza-profil-svoj', '.x/reg', '140'),
        ('r05-pauza-profil-chuzhoj', '.x/reg', '141'),
        ('r06-pauza-shtatnyj-svoj', '.harness/registry', '140'),
        ('r07-pauza-shtatnyj-chuzhoj', '.harness/registry', '141'),
        ('r08-pauza-bez-profilja-svoj', None, '140'),
        ('r09-pauza-bez-profilja-chuzhoj', None, '141'),
    ):
        register(name, 'registry='+str(registry)+';пауза='+pause+';reviewer',
                 lambda m,d,r=registry,n=pause: judge(m,d,r,pause=n))

def statika(p, door):
    # Exact approved Ш-2 criterion; legal .harness/contracts also makes it red.
    # Kept separate from semantic --model: scope decision is reported, not hidden.
    import subprocess
    source = Path(door).read_text()
    result = subprocess.run([p.BASH, '-c',
        "! grep -v -E '^\\s*#' | grep -q -E '\\.harness/|registry/(contracts|pauzy)\\.tsv'"],
        input=source, capture_output=True, text=True, env=p.GIT_ENV)
    return [p.k_rc(result, 0, 'Ш-2-без-литералов')]


def grammar(p, door):
    if not Path(door).is_file():
        print('CASE r10-sh2-bez-literalov KRASNO: SUBJECT_ABSENT')
        return 1
    problems = [problem for problem in statika(p, door) if problem]
    print('CASE r10-sh2-bez-literalov '+('KRASNO: '+'; '.join(problems) if problems else 'ok'))
    return int(bool(problems))

def mutacii(z):
    def fixed(t, directory):
        start = t.index('reestr_put() {')
        end = t.index('\n}\n', start)+3
        return z(t, t[start:end], 'reestr_put() {\n  printf \'%s/%s/%s\' "$1" \''+
                 directory+'\' "$2"\n}\n')
    return {
        's87-reestr-literal-proekta': lambda t: fixed(t, '.harness/registry'),
        's88-pauza-ignoriruet-profil': lambda t: z(t,
            '  f="$(reestr_put "$REPO" pauzy.tsv)" || return 1',
            '  f="$REPO/registry/pauzy.tsv"'),
        's89-reestr-tolko-stancija': lambda t: fixed(t, 'registry'),
    }
