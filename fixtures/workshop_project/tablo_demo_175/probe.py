#!/usr/bin/env python3
"""175: run the actual board CLI program against in-memory GitHub/Git responses."""
import argparse
import contextlib
import datetime as dt
import io
import json
from pathlib import Path
import re
import subprocess
import sys
from unittest.mock import patch

from model import honest, replace_once

BOARD = 'ops/server/user/orch-tablo'
ROOT = Path(__file__).resolve().parents[3]

# Each input is conformant to gh pr list --json's real public response.
# The oracle is retained in checker memory before invoking the subject.
CASES = {
    'demo_branch': ('a3ka/Complior-mob', 901, 'demo/investor-d24', 'Temporary presentation', 'SUCCESS', False),
    'demo_title': ('a3ka/Complior-mob', 902, 'wip/902/implementer', 'DEMO ONLY: presentation', 'SUCCESS', False),
    'do_not_merge': ('a3ka/Complior-mob', 903, 'wip/903/implementer', 'Показ инвестору — НЕ МЕРЖИТЬ', 'SUCCESS', False),
    'real_green': ('a3ka/Complior-mob', 904, 'wip/904/implementer', 'Screen work ready', 'SUCCESS', True),
    'real_red': ('a3ka/Complior-mob', 905, 'wip/905/implementer', 'Screen work blocked', 'FAILURE', True),
    'not_demo_word': ('a3ka/Complior-mob', 906, 'wip/906/implementer', 'DEMOGRAPHIC metrics', 'SUCCESS', True),
    'harness_demo': ('a3ka/dev-harness', 907, 'demo/station-talk', 'Presentation', 'SUCCESS', False),
    'harness_real': ('a3ka/dev-harness', 908, 'owner/train-main', 'Real station task', 'SUCCESS', True),
}


def run_case(source, name):
    repo_name, number, branch, title, status, expected_visible = CASES[name]
    timestamp = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(minutes=2)).isoformat()
    row = {'number': number, 'headRefName': branch, 'title': title,
           'updatedAt': timestamp, 'statusCheckRollup': [{'conclusion': status}]}
    calls = []

    def fake_run(argv, **kwargs):
        calls.append(tuple(argv))
        if tuple(argv[:3]) == ('gh', 'pr', 'list'):
            target = argv[argv.index('-R') + 1]
            fields = argv[argv.index('--json') + 1].split(',')
            output = json.dumps([{k: v for k, v in row.items() if k in fields}] if target == repo_name else [])
        elif argv[0] == 'git':
            output = ''
        else:
            raise AssertionError(f'unexpected dependency: {argv!r}')
        return subprocess.CompletedProcess(argv, 0, stdout=output, stderr='')

    stdout = io.StringIO()
    stderr = io.StringIO()
    code = 0
    try:
        with patch('glob.glob', side_effect=lambda pattern: ['synthetic-root'] if pattern.endswith('--home-harness-dev-harness--') else []), \
             patch('subprocess.run', side_effect=fake_run), \
             patch.object(sys, 'argv', [BOARD, '20']), \
             contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            exec(compile(source, BOARD, 'exec'), {'__name__': '__main__', '__file__': str(ROOT / BOARD)})
    except SystemExit as exc:
        code = exc.code if isinstance(exc.code, int) else 1
    except Exception as exc:
        code = 2
        stderr.write(f'{type(exc).__name__}: {exc}')
    # Independent exact row and counter oracle; the board may not hide a PR
    # line while still counting it as unfinished work.
    lines = stdout.getvalue().splitlines()
    rows = [line for line in lines if re.fullmatch(
        rf'  СТОИТ \d+ мин PR (?:Complior-mob|dev-harness)#{number} \([^\n]*\): CI (?:зелёный|красный), по нему никто не работает', line)]
    present = len(rows) == 1
    summary = f'итог: стоит без хода — {2 + int(expected_visible)}'
    summary += '  → сделай следующий шаг по каждой строке СТОИТ до wait'
    query = [call for call in calls if call[:3] == ('gh', 'pr', 'list')]
    valid = (code == 0 and not stderr.getvalue() and len(query) == 2
             and lines[-1:] == [summary] and 'НЕ МЕРЖИТЬ' not in stdout.getvalue())
    ok = valid and present == expected_visible
    print(f'175 {name} {"ok" if ok else "KRASNO"} visible={present} expected={expected_visible} rc={code}')
    return ok


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    if args.repo:
        candidate = args.repo.resolve() / BOARD
        if not candidate.is_file():
            print('175 SUBJECT_ABSENT', file=sys.stderr)
            return 2
        source = candidate.read_text()
        checks = [run_case(source, key) for key in CASES]
        return 0 if all(checks) else 1
    source = honest()
    checks = [run_case(source, key) for key in CASES]
    if not all(checks):
        print('175 CONTROL_INVALID', file=sys.stderr)
        return 2
    if args.model:
        return 0
    # Stubs are addressable code mutations. Each is judged by its own input,
    # never by the first red in a combined run (N-39).
    mutants = [
        ('branch_only', replace_once(source, "or re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", 'or False'), 'demo_title'),
        ('title_only', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", 'False'), 'demo_branch'),
        ('marker_ignored', replace_once(source, "or 'НЕ МЕРЖИТЬ' in title.upper()", 'or False'), 'do_not_merge'),
        ('exclude_every_mob_pr', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", "repo == 'a3ka/Complior-mob'"), 'real_green'),
        ('exclude_red_ci', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", "(p['headRefName'].casefold().startswith('demo/') or any(c.get('conclusion') == 'FAILURE' for c in p.get('statusCheckRollup') or []))"), 'real_red'),
        ('word_substring', replace_once(source, "re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", "'DEMO' in title.upper()"), 'not_demo_word'),
    ]
    failed = False
    for label, mutated, target in mutants:
        caught = not run_case(mutated, target)
        print(f'175 STAB {label} {"caught" if caught else "ZHIV"} @ {target}')
        failed |= not caught
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
