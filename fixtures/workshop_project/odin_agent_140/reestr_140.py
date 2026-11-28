"""Ш-2: registry is profile data; public seam is --sudit plus START/warn."""
import json
import os
from pathlib import Path

BINDINGS = {
    's87-reestr-literal-proekta': ['r04-pauza-profil-svoj'],
    's88-pauza-ignoriruet-profil': ['r04-pauza-profil-svoj'],
    's89-reestr-tolko-stancija': ['r04-pauza-profil-svoj'],
    's90-noauthor-rannyj-continue': ['r11-noauthor-reviewer'],
    's91-profile-error-bez-pauzy': ['r14-profile-broken-pauza'],
    's92-override-polnaja-grammatika': ['r16-override-dubl-extra', 'r17-override-dubl-object'],
    's93-kontrakty-literal': ['r18-kontrakty-profil-obychnyj', 'r19-kontrakty-profil-riskovyj'],
    's96-profil-f-flag': ['k03b01-profil-dangl-symlink',
                          'k03b02-profil-cikl-symlink',
                          'k03b03-profil-katalog',
                          'k03b04-profil-symlink-na-katalog'],
    's97-profil-ljubaja-nechitajemost': ['r15-profile-broken-bez-pauzy',
                                       'k03b01-profil-dangl-symlink',
                                       'k03b02-profil-cikl-symlink',
                                       'k03b03-profil-katalog',
                                       'k03b04-profil-symlink-na-katalog'],
    's98-profil-otkaz-i-bez-profilja': ['r03-reestr-bez-profilja',
                                      'r08-pauza-bez-profilja-svoj'],
}


def dobavit(K, p):
    def register(name, axes, fn):
        K[name] = dict(osi=axes, run=fn)

    def world(m, registry, risk='обычный', pause=None, contracts='contracts'):
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-frozen.md', 'КЛАСС РИСКА: '+risk+'\n')])
        if contracts != 'contracts':
            # The frozen owner, not the payload checkout, supplies the risk.
            # Re-pin an independent Git tree carrying only the declared path.
            target = m.repo / contracts
            target.mkdir(parents=True)
            (target / '140-frozen.md').write_text('КЛАСС РИСКА: '+risk+'\n')
            m.git(['add', '-A'])
            result = m.git(['commit', '-qm', 'nondefault frozen contracts'])
            assert result.returncode == 0, result.stderr
            frozen = m.git(['rev-parse', 'HEAD']).stdout.strip()
            tag = 'frozen/contracts/140/2'
            result = m.git(['tag', '-a', tag, '-m', 'nondefault frozen', frozen])
            assert result.returncode == 0, result.stderr
            pin = m.git(['rev-parse', tag]).stdout.strip()
            (m.repo / 'registry/contracts.tsv').write_text('140 → '+pin+'\n')
            assert m.git(['cat-file', '-e', frozen+':'+contracts+'/140-frozen.md']).returncode == 0
            assert m.git(['cat-file', '-e', frozen+':contracts/140-frozen.md']).returncode != 0
        if registry is not None:
            paths = dict(contracts=contracts, verdicts='.profile/verdicts',
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

    def judge(m, door, registry, risk='обычный', pause=None, contracts='contracts'):
        obj = world(m, registry, risk, pause, contracts)
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

    def noauthor(m, door, role):
        event = m.sobytie('noauthor.json', [p.item(role, 'NoauthorJudge',
                           ['SUBJECT=140', 'OBJECT='+p.OBJECT_DUMMY])])
        before = p.snimok_fajlov(m.sost)
        result = p.sudit(door, m, event)
        if role == 'reviewer':
            return [p.k_rc(result, 1, 'reviewer-без-автора'),
                    p.k_prichina(result, 'ADVERSARIJ_DO_REVJUERA', 'порядок'),
                    None if p.snimok_fajlov(m.sost) == before else 'отказ изменил состояние']
        return p.k_warn(result, m, 'RABOCHEGO_NET', '140') + [
            p.k_stroka(m, 'START-без-автора', holder='NoauthorJudge',
                       subjectId='140', object=p.OBJECT_DUMMY, rol=role)]

    for number, role in ((11, 'reviewer'), (12, 'adversary'), (13, 'critic')):
        register('r%02d-noauthor-%s' % (number, role),
                 'автора=нет;риск=неизвестен;роль='+role,
                 lambda m,d,r=role: noauthor(m,d,r))

    def broken_profile(m, door, paused):
        if paused:
            m.pauza('140')
        wt, br, _ = m.worktree('140')
        (m.repo / 'harness.project.json').write_text('{broken')
        event = m.sobytie('broken-profile.json', [p.item('architect', 'BrokenProfile',
            ['SUBJECT=140', 'WORKTREE='+wt, 'BRANCH='+br], isolated=True)])
        before = p.snimok_fajlov(m.sost)
        result = p.sudit(door, m, event)
        # A broken profile cannot establish where the pause registry lives,
        # even when the default registry contains no pause for this subject.
        reasons = ('PROFIL_NEDOSTUPEN', 'PAUZA_VLADELTSA')
        return [p.k_rc(result, 1, 'битый-профиль'),
                None if any(p.k_prichina(result, reason, 'профиль') is None
                            for reason in reasons) else 'нет отказа профиля/паузы',
                None if p.snimok_fajlov(m.sost) == before else 'отказ изменил состояние']

    register('r14-profile-broken-pauza', 'профиль=битый;пауза=140;нет-записей',
             lambda m,d: broken_profile(m,d,True))
    register('r15-profile-broken-bez-pauzy', 'профиль=битый;пауза=неопределима;нет-записей',
             lambda m,d: broken_profile(m,d,False))

    def duplicate_override(m, door, suffix):
        m.pauza('140')
        wt, br, _ = m.worktree('140')
        line = 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 140 PAUZA_VLADELTSA'
        event = m.sobytie('duplicate-override.json', [p.item('architect', 'DuplicateOverride',
            ['SUBJECT=140', 'WORKTREE='+wt, 'BRANCH='+br, line, line+suffix], isolated=True)])
        before = p.snimok_fajlov(m.sost)
        result = p.sudit(door, m, event)
        return [p.k_rc(result, 1, 'некорректный-дубль'),
                None if any(line.startswith('ОТКАЗ: ') for line in result.stderr.splitlines())
                else 'нет именованного отказа дублирующей санкции',
                None if p.snimok_fajlov(m.sost) == before else 'дубль израсходовал override/изменил состояние']

    register('r16-override-dubl-extra', 'санкция=корректная+лишнее-поле;нет-override',
             lambda m,d: duplicate_override(m,d,' extra'))
    register('r17-override-dubl-object', 'санкция=корректная+некорректный-OBJECT;нет-override',
             lambda m,d: duplicate_override(m,d,' '+('g'*40)))
    for number, risk, contracts in (
        (18, 'обычный', '.x/contracts'), (19, 'рисковый', '.other/contracts'),
    ):
        register('r%02d-kontrakty-profil-%s' % (number, 'obychnyj' if number == 18 else 'riskovyj'),
                 'registry=.x/reg;contracts='+contracts+';frozen='+risk,
                 lambda m,d,r=risk,c=contracts: judge(m,d,'.x/reg',r,contracts=c))

    def profile_entry(m, door, form, paused=True):
        # К-03б: pause data stays in the profile registry; the fallback is empty.
        wt, br, _ = m.worktree('140')
        paths = dict(contracts='contracts', verdicts='.profile/verdicts',
                     fixtures='.profile/fixtures', registry='.x/reg')
        for rel in paths.values():
            (m.repo / rel).mkdir(parents=True, exist_ok=True)
        (m.repo / '.profile/project.json').write_text(json.dumps(dict(
            schemaVersion=1, version='1', projectId='toy140', workspaceId='toy',
            defaults={}))+'\n')
        target = m.repo / '.profile/profile.json'
        target.write_text(json.dumps(dict(
            schemaVersion=1, repoId=p.REPO_ID, language='bash',
            projectLayer=dict(version='1', profilePath='.profile/project.json'),
            workflowPaths=paths))+'\n')
        entry = m.repo / 'harness.project.json'
        entry.symlink_to('.profile/profile.json')
        (m.repo / '.x/reg/pauzy.tsv').write_text(
            '140\t2026-11-21\towner\tpause\n' if paused else '')
        assert not (m.repo / 'registry/pauzy.tsv').exists()
        if form == 'dangl':
            target.unlink()
            assert entry.is_symlink() and not entry.exists()
        elif form == 'cikl':
            entry.unlink()
            entry.symlink_to('harness.project.json')
            assert entry.readlink() == Path('harness.project.json')
        elif form == 'katalog':
            entry.unlink()
            entry.mkdir()
            assert entry.is_dir() and not entry.is_symlink()
        elif form == 'symlink-na-katalog':
            entry.unlink()
            entry.symlink_to('.profile')
            assert entry.is_symlink() and entry.is_dir()
        elif form == 'bez-prav':
            target.chmod(0o000)
            # Effective OS rights, not mode bits: privileged processes may read 000.
            if os.access(entry, os.R_OK, effective_ids=True):
                print('SKIP k03b05-profil-bez-prav: chmod 000 не запрещает чтение '
                      'текущему uid=%d' % os.geteuid())
                return []
        else:
            assert form == 'valid' and entry.is_file() and entry.is_symlink()
        event = m.sobytie('profile-entry.json', [p.item(
            'architect', 'ProfileEntry140',
            ['SUBJECT=140', 'WORKTREE='+wt, 'BRANCH='+br], isolated=True)])
        before = p.snimok_fajlov(m.sost)
        result = p.sudit(door, m, event)
        if form == 'valid' and not paused:
            return [p.k_rc(result, 0, 'валидный-симлинк-без-паузы'),
                    None if 'PUSCHEM ProfileEntry140 dev-harness/140 (rabochij/architect)'
                    in result.stdout.splitlines() else 'нет собственной строки PUSCHEM',
                    p.k_chislo_startov(m, 'учёт', 1),
                    p.k_stroka(m, 'START-валидного-симлинка', subjectId='140',
                               holder='ProfileEntry140', isolated=True)]
        reason = 'PAUZA_VLADELTSA' if form == 'valid' else 'PROFIL_NEDOSTUPEN'
        return [p.k_rc(result, 1, 'профиль='+form),
                None if any(line.startswith('ОТКАЗ: '+reason+':')
                            for line in result.stderr.splitlines())
                else 'нет самостоятельной строки отказа '+reason,
                p.k_net_startov(m, 'отказ-без-START/override'),
                None if p.snimok_fajlov(m.sost) == before else 'отказ изменил состояние']

    # Separate prefix keeps the established --domain r01–r19 gate at 19/0.
    for name, form, paused in (
        ('k03b01-profil-dangl-symlink', 'dangl', True),
        ('k03b02-profil-cikl-symlink', 'cikl', True),
        ('k03b03-profil-katalog', 'katalog', True),
        ('k03b04-profil-symlink-na-katalog', 'symlink-na-katalog', True),
        ('k03b05-profil-bez-prav', 'bez-prav', True),
        ('k03b06-profil-valid-symlink-pauza', 'valid', True),
        ('k03b07-profil-valid-symlink-bez-pauzy', 'valid', False),
    ):
        register(name, 'К-03б;профиль='+form+';пауза='+str(paused),
                 lambda m,d,f=form,pa=paused: profile_entry(m,d,f,pa))

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

def replace_function(t, name, body, z):
    marker = name+'() {'
    if t.count(marker) != 1:
        raise RuntimeError('мутирование не нашло ровно одну функцию: '+name)
    start = t.index(marker)
    end = t.find('\n}\n', start)
    if end < 0:
        raise RuntimeError('мутирование не нашло конец функции: '+name)
    return z(t, t[start:end+3], body)


def fixed_contracts(t, z):
    return replace_function(t, 'kontrakt_kat',
                            "kontrakt_kat() { printf 'contracts'; }\n", z)


def mutacii(z):
    def fixed(t, directory):
        start = t.index('reestr_put() {')
        end = t.index('\n}\n', start)+3
        return z(t, t[start:end], 'reestr_put() {\n  printf \'%s/%s/%s\' "$1" \''+
                 directory+'\' "$2"\n}\n')
    def pause_source(t, source):
        return replace_function(t, 'na_pauze', '''na_pauze() {
  local f l
'''+source+'''
  [ -r "$f" ] || return 1
  while IFS= read -r l; do
    case "$l" in '#'*|'') continue ;; esac
    [ "${l%%$'\\t'*}" = "$1" ] && return 0
  done < "$f"
  return 1
}
''', z)
    def profile_file_test(t):
        # S-dangl: OBJECT's regular-file test mistakes an unreadable entry for absence.
        return replace_function(t, 'reestr_put', '''reestr_put() {
  local repo="$1" name="$2" paths
  if [ ! -f "$repo/harness.project.json" ]; then
    printf '%s/registry/%s' "$repo" "$name"
    return 0
  fi
  paths="$(profile_paths "$repo")" || return 1
  printf '%s\\n' "$paths" | jq -er --arg name "$name" '.registry + "/" + $name'
}
''', z)

    def profile_any_fallback(t):
        # S-any: resolution errors, like an absent profile, use the old registry.
        return replace_function(t, 'reestr_put', '''reestr_put() {
  local repo="$1" name="$2" paths
  if paths="$(profile_paths "$repo")"; then
    printf '%s\\n' "$paths" | jq -er --arg name "$name" '.registry + "/" + $name' && return 0
  fi
  printf '%s/registry/%s' "$repo" "$name"
}
''', z)

    def profile_absent_refusal(t):
        # S-all: a false refusal when the profile path is wholly absent.
        return replace_function(t, 'reestr_put', '''reestr_put() {
  local repo="$1" name="$2" paths
  [ -e "$repo/harness.project.json" ] || [ -L "$repo/harness.project.json" ] || return 1
  [ -f "$repo/harness.project.json" ] || return 1
  paths="$(profile_paths "$repo")" || return 1
  printf '%s\\n' "$paths" | jq -er --arg name "$name" '.registry + "/" + $name'
}
''', z)

    return {
        's87-reestr-literal-proekta': lambda t: fixed(t, '.harness/registry'),
        's88-pauza-ignoriruet-profil': lambda t: pause_source(t, '  f="$REPO/registry/pauzy.tsv"'),
        's89-reestr-tolko-stancija': lambda t: fixed(t, 'registry'),
        's90-noauthor-rannyj-continue': lambda t: z(t,
            '''        obj_fakt="$obj"
        fakt_zapis "$idx" "$obj_fakt"
''',
            '''        obj_fakt="$obj"
        fakt_zapis "$idx" "$obj_fakt"
        continue # стаб: пропуск порядка судей без автора
'''),
        's91-profile-error-bez-pauzy': lambda t: pause_source(t,
            '  f="$(reestr_put "$REPO" pauzy.tsv)" || return 1'),
        's92-override-polnaja-grammatika': lambda t: z(t,
            '''  c="$(kolvo_strok "$t" '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК:')"
''', '''  c="$(kolvo_strok "$t" "$ZAMOK_STROKA_RE")"
'''),
        's93-kontrakty-literal': lambda t: fixed_contracts(t, z),
        's96-profil-f-flag': profile_file_test,
        's97-profil-ljubaja-nechitajemost': profile_any_fallback,
        's98-profil-otkaz-i-bez-profilja': profile_absent_refusal,
    }


if __name__ == '__main__':
    import tempfile
    import probe as p

    raw_sudit = p.sudit

    def observed(door, mir, event):
        result = raw_sudit(door, mir, event)
        print('RAW rc=%d stdout=%r stderr=%r ledger=%r' %
              (result.returncode, result.stdout, result.stderr, mir.ledg()))
        return result

    p.sudit = observed
    cases = p.kejsy()
    selected = sorted(k for k in cases if k.startswith(
        tuple('r%02d-' % n for n in range(11, 20))+('k03b',)))
    for name in selected:
        print('BASE '+name)
        problems = p.progon(p.SUBJEKT_DVERI, name, cases[name]['run'])
        print('CELL_RC=%d errors=%r' % (bool(problems), problems))
    with tempfile.TemporaryDirectory(prefix='odin140-a2-repro-') as tmp:
        root = Path(tmp)
        for name in ('next_id.sh', 'profile_resolver.sh'):
            (root / name).symlink_to(p.REEPOR / 'scripts' / name)
        mutant = root / 'contract_literal.sh'
        mutant.write_text(fixed_contracts(p.SUBJEKT_DVERI.read_text(), p._z))
        for name in selected:
            if name.startswith(('r18-', 'r19-')):
                print('MUTANT_K05 '+name)
                problems = p.progon(mutant, name, cases[name]['run'])
                print('CELL_RC=%d errors=%r' % (bool(problems), problems))
