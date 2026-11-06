#!/usr/bin/env python3
"""164 reviewer-route regression using the existing 140 world and the real lock door."""
import importlib.util
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DOOR = ROOT / 'scripts' / 'zamok_predmeta.sh'
WORLD = ROOT / 'fixtures' / 'workshop_project' / 'odin_agent_140' / 'probe.py'
spec = importlib.util.spec_from_file_location('existing_140_world', WORLD)
existing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(existing)


def case(name, declaration, judgment, expected_rc, reason):
    with tempfile.TemporaryDirectory(prefix='risk164-lock-' + name + '-') as temp:
        mir = existing.Mir(temp)
        mir.git(['tag', '-a', 'id/CONTRACT/164', '-m', 'issued'])
        mir.kontrakt('164', declaration)
        candidate = mir.git(['rev-parse', 'HEAD']).stdout.strip()
        verdict = mir.repo / 'verdicts' / 'critic' / 'contracts-164-v1.md'
        verdict.parent.mkdir(parents=True, exist_ok=True)
        verdict.write_text('accept\nOBJECT=' + candidate + '\n'
                           + (('СУД-КЛАССА-РИСКА: ' + judgment + '\n') if judgment else ''),
                           encoding='utf-8')
        mir.git(['add', '-A'])
        mir.git(['commit', '-qm', 'judge'])
        mir.git(['tag', '-a', 'frozen/contracts/164/1', '-m', 'frozen'])
        wt, branch, sha = mir.worktree('164')
        mir.start('164', 'Avtor164', wt=wt, branch=branch)
        mir.zhurnal('Avtor164', sdal=True)
        event = mir.sobytie('e.json', [existing.item('reviewer', 'Rev164',
                               ['SUBJECT=164', 'OBJECT=' + sha])])
        before = len(mir.ledg())
        actual = existing.sudit(DOOR, mir, event)
        after = len(mir.ledg())
        valid = (actual.returncode == expected_rc and
                 (not reason or reason in actual.stderr) and
                 ((after == before) if expected_rc else (after == before + 1)))
        print(f'{name}: rc={actual.returncode}, expected={expected_rc}, '
              f'ledger={before}->{after}, reason={reason or "allow"}, '
              f'actual={actual.stderr.strip()}')
        return valid


def main():
    cells = (
        ('ordinary-accepted', 'обычный', 'обычный', 0, ''),
        ('risky-blocked', 'рисковый', 'рисковый', 1, 'ADVERSARIJ_DO_REVJUERA'),
        ('downgraded', 'обычный', 'рисковый', 1, 'RISK_CLASS_MISMATCH'),
        ('no-judgment', 'обычный', None, 1, 'JUDGMENT_MISSING'),
    )
    failures = [name for name, declared, judged, rc, why in cells
                if not case(name, declared, judged, rc, why)]
    if failures:
        print('REVIEWER_BYPASS: ' + ', '.join(failures))
        return 1
    print('reviewer route: 4/4')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
