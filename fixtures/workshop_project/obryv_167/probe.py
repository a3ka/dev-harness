#!/usr/bin/env python3
"""Contract 167: independent judge interruption and PR merge checks at public CLI seams."""
import importlib.util
from pathlib import Path
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DOOR = ROOT / 'scripts/zamok_predmeta.sh'
BASELINE = ROOT / 'fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh'

spec = importlib.util.spec_from_file_location('odin_agent_140', ROOT / 'fixtures/workshop_project/odin_agent_140/probe.py')
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)

# A control model is derived from the frozen 140 reference, NOT from candidate files.
# The replacement is scoped to the public release/accounting decision.  The fixture
# refuses missing anchors rather than blessing a partially patched model.
ORIGINAL = '''subekt_suzhen_sudej_obj() {  # <NNN> <rol> <object>
  jq -se --arg r "$REPO_ID" --arg n "$1" --arg roli "$2" --arg o "$3" 'any(.[]; .t == "START" and .repoId == $r and .subjectId == $n and .klass == "sudja" and .rol == $roli and .object == $o)' "$LEDGER" >/dev/null 2>&1
}'''
REPLACEMENT = '''subekt_suzhen_sudej_obj() {  # <NNN> <rol> <object>
  # One RELEASE for this precise START, not a blanket release for this role.
  jq -se --arg r "$REPO_ID" --arg n "$1" --arg roli "$2" --arg o "$3" '
    reduce .[] as $l ({};
      if $l.repoId != $r or $l.subjectId != $n then .
      elif $l.t == "START" and $l.klass == "sudja" and $l.rol == $roli and $l.object == $o
        then .[$l.holder] = "open"
      elif $l.t == "RELEASE" and .[$l.holder] == "open" and $l.prichina == "obryv_bez_verdikta"
        then .[$l.holder] = "interrupted"
      elif $l.t == "RELEASE" and .[$l.holder] == "open" then .[$l.holder] = "judged"
      else . end
    ) | any(.[]; . != "interrupted")' "$LEDGER" >/dev/null 2>&1
}'''
RELEASE = "  case \"$(stare_holder \"$h_holder\")\" in\n    yield) prichina='yield' ;;"
# Completion is measured from actual committed verdict, not a yield tool call.
# A receipt is exact holder+OBJECT, authenticated against git commit and blob.
NEW_FUNCTION = '''verdict_sessii() {  # <NNN> <holder> <rol> <OBJECT>
  local c path blob sud fields first dir
  case "$3" in critic|critic-sol) dir=critic ;; reviewer) dir=review ;; adversary) dir=adversary ;; *) return 1 ;; esac
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    [ "$(git -C "$REPO" log -1 --format=%an "$c")" = "$3" ] || continue
    while IFS= read -r path; do
      case "$path" in verdicts/"$dir"/contracts-"$1"-v[0-9]*.md) ;; *) continue ;; esac
      blob="$(git -C "$REPO" show "$c:$path" 2>/dev/null)" || continue
      IFS= read -r first <<< "$blob"
      case "$first" in accept|FAIL) ;; *) continue ;; esac
      printf '%s\\n' "$blob" | grep -Fxq "OBJECT=$4" || continue
      sud="$(printf '%s\\n' "$blob" | grep '^СУД: ')" || continue
      fields="${sud#СУД: }"
      printf '%s\\n' "$fields" | tr ';' '\\n' | sed 's/^ *//;s/ *$//' | grep -Fxq "роль=$3" || continue
      printf '%s\\n' "$fields" | tr ';' '\\n' | sed 's/^ *//;s/ *$//' | grep -Fxq "сессия=$2" || continue
      return 0
    done < <(git -C "$REPO" diff-tree --root --no-commit-id --name-only -r "$c" -- "verdicts/$dir/")
  done < <(git -C "$REPO" log --all --format=%H -- "verdicts/$dir/")
  return 1
}
'''


def model(path):
    src = BASELINE.read_text()
    if src.count(ORIGINAL) != 1 or src.count(RELEASE) != 1:
        raise RuntimeError('MODEL_ANCHOR_MISSING')
    src = src.replace(ORIGINAL, REPLACEMENT)
    # D11 must also run after --osvobodit removed the current holder's lock.
    start = src.index('      # [D11 uzhe-suzhen]')
    end = src.index('    if [ "$klass" = \'sudja\' ]; then\n      rab=', start)
    section = src[start:end]
    assert section.endswith('    fi\n') and section.count('OBJECT_UZHE_SUZHEN') == 1
    d11 = section.removesuffix('    fi\n')
    src = src[:start] + '    fi\n' + d11 + src[end:]
    # A yielded judge without a committed verdict is an interrupted judge.
    # Inject verdict classification at the one release seam; git commit controls outcome.
    needle = "  rm -rf \"$zdir/zanyat\"\n  jq -nc --arg t RELEASE"
    assert src.count(needle) == 1, 'MODEL_RELEASE_ANCHOR_MISSING'
    src = src.replace(needle, '''  h_klass="$(jq -r '.klass' "$zdir/zanyat/holder.json")"
  if [ "$h_klass" = 'sudja' ]; then
    h_rol="$(jq -r '.rol' "$zdir/zanyat/holder.json")"
    h_obj="$(jq -r '.object' "$zdir/zanyat/holder.json")"
    if verdict_sessii "$NNN_ARG" "$h_holder" "$h_rol" "$h_obj"; then
      prichina='verdikt_zakommiten'
    else
      prichina='obryv_bez_verdikta'
    fi
  fi
''' + needle)
    assert src.count('osvobodit() {') == 1, 'MODEL_FUNCTION_ANCHOR_MISSING'
    src = src.replace('osvobodit() {', NEW_FUNCTION + '\nosvobodit() {')
    path.write_text(src)
    path.chmod(0o755)


def check(rc, expected, detail, reason=''):
    if rc.returncode != expected or (reason and reason not in rc.stderr):
        return f'{detail}: rc={rc.returncode}, stderr={rc.stderr.strip()}, stdout={rc.stdout.strip()}'
    return None


def case(door, kind):
    role = 'reviewer' if kind == 'reviewer_verdict' else 'critic'
    verdict_dir = 'review' if role == 'reviewer' else 'critic'
    with tempfile.TemporaryDirectory(prefix='obryv-167-') as tmp:
        m = old.Mir(tmp)
        nnn = '141'
        m.kontrakt(nnn)
        wt, branch, obj = m.worktree(nnn)
        m.start(nnn, 'Author167', wt=wt, branch=branch)
        m.zhurnal('Author167', sdal=True)
        m.release(nnn, 'Author167')
        m.start(nnn, 'Critic167First', klass='sudja', rol=role, obj=obj)
        m.zhurnal('Critic167First', sdal=True)
        if kind in ('verdict', 'verdict_no_receipt', 'reviewer_verdict'):
            verdict_path = f'verdicts/{verdict_dir}/contracts-141-v1.md'
            verdict = m.repo / verdict_path
            verdict.parent.mkdir(parents=True)
            verdict.write_text('FAIL\nOBJECT=' + obj + f'\nСУД: repo=dev-harness; предмет=141; роль={role}; сессия=Critic167First; модель-факт=fixture\n')
            m.git(['add', verdict_path])
            c = old.run(['git', '-c', f'user.name={role}', '-c', f'user.email={role}@dev-harness.local',
                         'commit', '-q', '-m', 'judge verdict'], cwd=str(m.repo))
            assert c.returncode == 0, c.stderr
        accounting = None
        if kind != 'verdict_no_receipt':
            released = old.osvobodit(door, m, nnn, 'Critic167First')
            accounting = check(released, 0, 'release')
            if accounting:
                return accounting
            rows = [r for r in m.ledg() if r.get('t') == 'RELEASE' and r.get('holder') == 'Critic167First']
            expected = 'verdikt_zakommiten' if kind in ('verdict', 'reviewer_verdict') else 'obryv_bez_verdikta'
            if len(rows) != 1 or rows[0].get('prichina') != expected:
                accounting = f'ACCOUNTING: RELEASE={rows!r}, expected={expected}'
        event = m.sobytie('repeat.json', [old.item(role, 'Critic167Again',
                              ['SUBJECT=141', 'OBJECT=' + obj])])
        repeat = old.sudit(door, m, event)
        if kind == 'interrupted':
            err = check(repeat, 0, 'interrupted repeat')
            if err:
                return '; '.join(x for x in (accounting, err) if x)
            starts = [r for r in m.ledg() if r.get('t') == 'START' and r.get('holder') == 'Critic167Again']
            if len(starts) != 1:
                return f'RETRY_START_MISSING {starts!r}'
            m.zhurnal('Critic167Again', sdal=True)
            third = m.sobytie('third.json', [old.item('critic', 'Critic167Third',
                                    ['SUBJECT=141', 'OBJECT=' + obj])])
            again = old.sudit(door, m, third)
            err = check(again, 1, 'second repeat', 'OBJECT_UZHE_SUZHEN')
            return '; '.join(x for x in (accounting, err) if x) or None
        err = check(repeat, 1, 'committed verdict blocks repetition', 'OBJECT_UZHE_SUZHEN')
        return '; '.join(x for x in (accounting, err) if x) or None


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else '--repo'
    with tempfile.TemporaryDirectory(prefix='model-167-') as tmp:
        control = Path(tmp) / 'zamok_predmeta.sh'
        model(control)
        if mode == '--model':
            subjects = [('interrupted', control), ('verdict', control), ('verdict_no_receipt', control), ('reviewer_verdict', control)]
        elif mode == '--stabs':
            subjects = [('interrupted', control), ('verdict', control), ('verdict_no_receipt', control), ('reviewer_verdict', control)]
        elif mode == '--repo':
            subjects = [('interrupted', DOOR), ('verdict', DOOR), ('verdict_no_receipt', DOOR), ('reviewer_verdict', DOOR)]
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
            stubs = {'ignore_all_starts': ('verdict', 'interrupted'),
                     'yield_is_verdict': ('interrupted',),
                     'always_block': ('interrupted',),
                     'no_retry_limit': ('interrupted',)}
            # Each stub must differ on its own public observable input.
            for stub, cases in stubs.items():
                for name in cases:
                    # Isolate a mutated control in a fresh ephemeral tree.
                    candidate = Path(tmp) / (stub + '.sh')
                    src = control.read_text()
                    if stub == 'ignore_all_starts':
                        src = src.replace(REPLACEMENT, REPLACEMENT.replace('any(.[]; . != "interrupted")', 'false'))
                    elif stub == 'yield_is_verdict':
                        src = src.replace("prichina='obryv_bez_verdikta'", "prichina='verdikt_zakommiten'", 1)
                    elif stub == 'always_block':
                        src = src.replace('  jq -se --arg r "$REPO_ID" --arg n "$1" --arg roli "$2" --arg o "$3"', '  return 0 # bad: unconditionally blocks\n  jq -se --arg r "$REPO_ID" --arg n "$1" --arg roli "$2" --arg o "$3"', 1)
                    else:
                        src = src.replace('any(.[]; . != "interrupted")', 'false')
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
