#!/usr/bin/env python3
"""Contract 167: independent judge interruption and PR merge checks at public CLI seams."""
import importlib.util
from pathlib import Path
import shutil
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DOOR = ROOT / 'scripts/zamok_predmeta.sh'
BASELINE = ROOT / 'fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh'

spec = importlib.util.spec_from_file_location('odin_agent_140', ROOT / 'fixtures/workshop_project/odin_agent_140/probe.py')
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)

# The control is the current 140 reference, including the 167 release
# classification and refs synchronization. krugov_suda closes the holder's
# latest open START; only obryv_bez_verdikta excludes it from the count.
# Refuse missing or ambiguous anchors instead of blessing a partial model.
ANCHORS = (
    ('krugov_suda RELEASE (контракт 167)',
     '        elif $l.t == "RELEASE" then\n'
     '          ([ to_entries[] | select(.value.h == $l.holder and .value.s == "open") ]\n'
     '           | last | .key) as $i\n'
     '          | if $i == null then .\n'
     '            else .[$i].s = (if $l.prichina == "obryv_bez_verdikta" then "obryv" else "sud" end)\n'
     '            end\n'),
    ('verdict_sessii (контракт 167)',
     'verdict_sessii() {  # <NNN> <holder> <rol> <OBJECT>\n'),
    ('шов освобождения судьи verdikt_zakommiten/obryv_bez_verdikta',
     "      prichina='verdikt_zakommiten'\n    else\n      prichina='obryv_bez_verdikta'\n"),
    ('синхронизация судейских refs до классификации',
     'if ! git -C "$REPO" ls-remote --heads origin >/dev/null 2>&1; then\n'),
)



def model(path):
    src = BASELINE.read_text()
    for name, anchor in ANCHORS:
        if src.count(anchor) != 1:
            raise RuntimeError('MODEL_ANCHOR_MISSING: ' + name)
    path.write_text(src)
    path.chmod(0o755)


def check(rc, expected, detail, reason=''):
    if rc.returncode != expected or (reason and reason not in rc.stderr):
        return f'{detail}: rc={rc.returncode}, stderr={rc.stderr.strip()}, stdout={rc.stdout.strip()}'
    return None


def case(door, kind):
    role = 'reviewer' if kind == 'reviewer_verdict' else 'critic'
    verdict_dir = 'review' if role == 'reviewer' else 'critic'
    bad_verdict = kind.startswith('verdict_wrong_')
    with tempfile.TemporaryDirectory(prefix='obryv-167-') as tmp:
        m = old.Mir(tmp)
        bare = Path(tmp) / 'remote' / 'dev-harness.git'
        bare.parent.mkdir()
        created = old.run(['git', 'init', '-q', '--bare', str(bare)])
        assert created.returncode == 0, created.stderr
        m.git(['remote', 'set-url', 'origin', 'file://' + str(bare)])
        nnn = '141'
        m.kontrakt(nnn)
        # v+1 140 (класс из ДЕРЕВА OBJECT): контракт — и в ДЕРЕВЕ кандидата
        # до снятия sha; суд класса читает его, не main-реестр.
        wt, branch, obj = m.worktree(
            nnn, kontrakty=[('fajl', nnn + '-stub.md', '# К\nКЛАСС РИСКА: обычный\n')])
        m.start(nnn, 'Author167', wt=wt, branch=branch)
        m.zhurnal('Author167', sdal=True)
        m.release(nnn, 'Author167')
        m.start(nnn, 'Critic167First', klass='sudja', rol=role, obj=obj)
        m.zhurnal('Critic167First', sdal=True)
        if kind in ('verdict', 'reviewer_verdict') or bad_verdict:
            verdict_path = (f'verdicts/{verdict_dir}/other.md' if kind == 'verdict_wrong_path'
                            else f'verdicts/{verdict_dir}/contracts-141-v1.md')
            verdict = m.repo / verdict_path
            verdict.parent.mkdir(parents=True)
            verdict_object = 'f' * 40 if kind == 'verdict_wrong_object' else obj
            verdict_session = 'Critic167Other' if kind == 'verdict_wrong_session' else 'Critic167First'
            verdict.write_text('FAIL\nOBJECT=' + verdict_object +
                               f'\nСУД: repo=dev-harness; предмет=141; роль={role}; сессия={verdict_session}; модель-факт=fixture\n')
            m.git(['add', verdict_path])
            author = 'Critic167First' if kind == 'verdict_wrong_author' else role
            c = old.run(['git', '-c', f'user.name={author}', '-c', f'user.email={author}@dev-harness.local',
                         'commit', '-q', '-m', 'judge verdict'], cwd=str(m.repo))
            assert c.returncode == 0, c.stderr
        if kind == 'remote_unavailable':
            shutil.rmtree(bare)
            released = old.osvobodit(door, m, nnn, 'Critic167First')
            if released.returncode != 2 or 'NOT_IMPLEMENTED: judge refs недоступны' not in released.stderr:
                return f'REMOTE_NOT_CLOSED rc={released.returncode} stderr={released.stderr.strip()}'
            if any(r.get('t') == 'RELEASE' and r.get('holder') == 'Critic167First' for r in m.ledg()):
                return 'REMOTE_WROTE_FALSE_RELEASE'
            return None
        released = old.osvobodit(door, m, nnn, 'Critic167First')
        accounting = check(released, 0, 'release')
        if accounting:
            return accounting
        rows = [r for r in m.ledg() if r.get('t') == 'RELEASE' and r.get('holder') == 'Critic167First']
        expected = 'verdikt_zakommiten' if kind in ('verdict', 'reviewer_verdict') else 'obryv_bez_verdikta'
        if len(rows) != 1 or rows[0].get('prichina') != expected:
            accounting = f'ACCOUNTING: RELEASE={rows!r}, expected={expected}'
        # A2 removed the repetition refusal, not RELEASE classification.
        if kind in ('verdict', 'reviewer_verdict'):
            return accounting
        event = m.sobytie('repeat.json', [old.item(role, 'Critic167Again',
                              ['SUBJECT=141', 'OBJECT=' + obj])])
        repeat = old.sudit(door, m, event)
        if kind == 'interrupted' or bad_verdict:
            err = check(repeat, 0, 'interrupted repeat')
            if err:
                return '; '.join(x for x in (accounting, err) if x)
            if kind == 'interrupted':
                starts = [r for r in m.ledg() if r.get('t') == 'START' and r.get('holder') == 'Critic167Again']
                if len(starts) != 1:
                    return f'RETRY_START_MISSING {starts!r}'
            return accounting
        return accounting


JUDGE_CASES = ('interrupted', 'verdict', 'reviewer_verdict',
               'remote_unavailable', 'verdict_wrong_author', 'verdict_wrong_path',
               'verdict_wrong_object', 'verdict_wrong_session')


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else '--repo'
    with tempfile.TemporaryDirectory(prefix='model-167-') as tmp:
        control = Path(tmp) / 'zamok_predmeta.sh'
        model(control)
        if mode == '--model':
            subjects = [(name, control) for name in JUDGE_CASES]
        elif mode == '--stabs':
            subjects = [(name, control) for name in JUDGE_CASES]
        elif mode == '--repo':
            subjects = [(name, DOOR) for name in JUDGE_CASES]
        else:
            print('usage: probe.py [--repo|--model|--stabs]', file=sys.stderr)
            return 2
        failures = []
        for name, subject in subjects:
            error = case(subject, name)
            print(f'CASE {name} {"KRASNO " + error if error else "ok"}')
            if error:
                failures.append(name)
        if mode == '--stabs':
            stubs = {'yield_is_verdict': ('interrupted',),
                     'always_block': ('interrupted',),
                     'skip_remote_check': ('remote_unavailable',),
                     'no_author_check': ('verdict_wrong_author',),
                     'broader_path': ('verdict_wrong_path',),
                     'no_object_check': ('verdict_wrong_object',),
                     'no_session_check': ('verdict_wrong_session',)}
            # Each stub must differ on its own public observable input.
            for stub, cases in stubs.items():
                for name in cases:
                    # Isolate a mutated control in a fresh ephemeral tree.
                    candidate = Path(tmp) / (stub + '.sh')
                    src = control.read_text()
                    if stub == 'yield_is_verdict':
                        src = src.replace("prichina='obryv_bez_verdikta'", "prichina='verdikt_zakommiten'", 1)
                    elif stub == 'always_block':
                        anchor = 'subekt_suzhen_sudej_obj() {  # <NNN> <rol> <object>\n'
                        src = src.replace(anchor, anchor + '  otp OBJECT_UZHE_SUZHEN "bad: unconditionally blocks"\n', 1)
                    elif stub == 'skip_remote_check':
                        src = src.replace('    if ! git -C "$REPO" ls-remote --heads origin >/dev/null 2>&1; then\n'
                                          '      rmdir "$zdir/mutex" 2>/dev/null\n'
                                          '      skip "judge refs недоступны"\n'
                                          '    fi\n', '')
                        src = src.replace('    if ! git -C "$REPO" fetch -q --prune origin \'+refs/heads/*:refs/remotes/origin/*\' >/dev/null 2>&1; then\n'
                                          '      rmdir "$zdir/mutex" 2>/dev/null\n'
                                          '      skip "judge refs не синхронизированы"\n'
                                          '    fi\n', '')
                    elif stub == 'no_author_check':
                        src = src.replace('    [ "$(git -C "$REPO" log -1 --format=%an "$c")" = "$3" ] || continue\n', '')
                    elif stub == 'broader_path':
                        src = src.replace('verdicts/"$dir"/contracts-"$1"-v[0-9]*.md', 'verdicts/"$dir"/*.md')
                    elif stub == 'no_object_check':
                        src = src.replace('      printf \'%s\\n\' "$blob" | grep -Fxq "OBJECT=$4" || continue\n', '')
                    elif stub == 'no_session_check':
                        src = src.replace('      printf \'%s\\n\' "$fields" | tr \';\' \'\\n\' | sed \'s/^ *//;s/ *$//\' | grep -Fxq "сессия=$2" || continue\n', '')
                    if src == control.read_text():
                        raise RuntimeError(f'STAB_NOT_MUTATED {stub}')
                    candidate.write_text(src)
                    candidate.chmod(0o755)
                    err = case(candidate, name)
                    # A mutation is caught only when its assigned case actually fails.
                    if err is None:
                        print(f'STAB_ZHIV {stub} {name}')
                        failures.append(f'{stub}:{name}')
                    else:
                        print(f'STAB {stub} {name} caught: {err}')
        print(f'CHECKED {len(subjects)} CASES; FAILURES {len(failures)}')
        return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
