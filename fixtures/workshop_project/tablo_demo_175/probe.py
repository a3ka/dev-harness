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
    'demo_branch': [('a3ka/Complior-mob', 901, 'demo/investor-d24', 'Temporary presentation', 'SUCCESS', False)],
    'demo_title': [('a3ka/Complior-mob', 902, 'wip/902/implementer', 'DEMO ONLY: presentation', 'SUCCESS', False)],
    'do_not_merge': [('a3ka/Complior-mob', 903, 'wip/903/implementer', 'Показ инвестору — НЕ МЕРЖИТЬ', 'SUCCESS', False)],
    'real_green': [('a3ka/Complior-mob', 904, 'wip/904/implementer', 'Screen work ready', 'SUCCESS', True)],
    'real_red': [('a3ka/Complior-mob', 905, 'wip/905/implementer', 'Screen work blocked', 'FAILURE', True)],
    'not_demo_word': [('a3ka/Complior-mob', 906, 'wip/906/implementer', 'DEMOGRAPHIC metrics', 'SUCCESS', True)],
    'harness_demo': [('a3ka/dev-harness', 907, 'demo/station-talk', 'Presentation', 'SUCCESS', False)],
    'harness_real': [('a3ka/dev-harness', 908, 'owner/train-main', 'Real station task', 'SUCCESS', True)],
    'upper_branch': [('a3ka/Complior-mob', 909, 'DeMo/investor', 'Presentation', 'SUCCESS', False)],
    'lower_title': [('a3ka/Complior-mob', 910, 'wip/910/implementer', 'demo presentation', 'SUCCESS', False)],
    'harness_title': [('a3ka/dev-harness', 911, 'owner/title-only', 'DEMO presentation', 'SUCCESS', False)],
    'harness_marker': [('a3ka/dev-harness', 912, 'owner/marker-only', 'Не Мержить этот PR', 'SUCCESS', False)],
    'harness_red': [('a3ka/dev-harness', 913, 'owner/red-build', 'Real red build', 'FAILURE', True)],
    'combined_demo': [('a3ka/Complior-mob', 914, 'demo/combined', 'DEMO — НЕ МЕРЖИТЬ', 'FAILURE', False)],
    'multirow': [
        ('a3ka/dev-harness', 915, 'demo/pr-before-real', 'DEMO — НЕ МЕРЖИТЬ', 'FAILURE', False),
        ('a3ka/dev-harness', 916, 'owner/next-pr', 'Real green build', 'SUCCESS', True),
        ('a3ka/Complior-mob', 917, 'demo/preview', 'Presentation', 'FAILURE', False),
        ('a3ka/Complior-mob', 918, 'wip/918/implementer', 'Real red build', 'FAILURE', True),
    ],
}


def run_case(source, name):
    entries = CASES[name]
    timestamp = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(minutes=2)).isoformat()
    rows = {
        repo: [{'number': number, 'headRefName': branch, 'title': title,
                'updatedAt': timestamp, 'statusCheckRollup': [{'conclusion': status}]}
               for target, number, branch, title, status, _visible in entries if target == repo]
        for repo in ('a3ka/dev-harness', 'a3ka/Complior-mob')
    }
    calls = []

    def fake_run(argv, **kwargs):
        calls.append(tuple(argv))
        if tuple(argv[:3]) == ('gh', 'pr', 'list'):
            target = argv[argv.index('-R') + 1]
            fields = argv[argv.index('--json') + 1].split(',')
            output = json.dumps([{k: v for k, v in row.items() if k in fields} for row in rows.get(target, [])])
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
    # The checker derives its expected PR rows and total from its own in-memory
    # case, never from the candidate's output or a file the candidate can edit.
    lines = stdout.getvalue().splitlines()
    pr_lines = [line for line in lines if re.match(r'^  СТОИТ \d+ мин PR ', line)]
    expected = [(repo.split('/')[1], number, branch, status, visible)
                for repo, number, branch, _title, status, visible in entries]
    observations = []
    for repo, number, branch, status, visible in expected:
        matching = [line for line in pr_lines if re.fullmatch(
            rf'  СТОИТ \d+ мин PR {re.escape(repo)}#{number} \({re.escape(branch)}\): '
            rf'CI {"красный" if status == "FAILURE" else "зелёный"}, по нему никто не работает', line)]
        observations.append(len(matching) == (1 if visible else 0))
    count = sum(visible for _repo, _number, _branch, _status, visible in expected)
    summary = f'итог: стоит без хода — {2 + count}'
    summary += '  → сделай следующий шаг по каждой строке СТОИТ до wait'
    query = [call for call in calls if call[:3] == ('gh', 'pr', 'list')]
    valid = (code == 0 and not stderr.getvalue() and len(query) == 2
             and lines[-1:] == [summary] and len(pr_lines) == count
             and 'НЕ МЕРЖИТЬ' not in stdout.getvalue())
    ok = valid and all(observations)
    print(f'175 {name} {"ok" if ok else "KRASNO"} rows={len(pr_lines)} expected={count} rc={code}')
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
        ('case_sensitive_branch', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", "p['headRefName'].startswith('demo/')"), 'upper_branch'),
        ('case_sensitive_title', replace_once(source, "re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", "re.search(r'\\bDEMO\\b', title)"), 'lower_title'),
        ('title_mob_only', replace_once(source, "re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", "(repo == 'a3ka/Complior-mob' and re.search(r'\\bDEMO\\b', title, re.IGNORECASE))"), 'harness_title'),
        ('marker_mob_only', replace_once(source, "'НЕ МЕРЖИТЬ' in title.upper()", "(repo == 'a3ka/Complior-mob' and 'НЕ МЕРЖИТЬ' in title.upper())"), 'harness_marker'),
        ('exclude_harness_red', replace_once(source, "if state in ('зелёный', 'красный') and not busy:", "if state in ('зелёный', 'красный') and not busy and not (repo == 'dev-harness' and state == 'красный'):"), 'harness_red'),
        ('combined_one_only', replace_once(source,
            "if (p['headRefName'].casefold().startswith('demo/')\n"
            "                or re.search(r'\\bDEMO\\b', title, re.IGNORECASE)\n"
            "                or 'НЕ МЕРЖИТЬ' in title.upper()):",
            "if sum((p['headRefName'].casefold().startswith('demo/'),\n"
            "                bool(re.search(r'\\bDEMO\\b', title, re.IGNORECASE)),\n"
            "                'НЕ МЕРЖИТЬ' in title.upper())) == 1:"), 'combined_demo'),
        ('break_filter', replace_once(source, "            continue\n        st = [c.get",
                                      "            break\n        st = [c.get"), 'multirow'),
    ]
    failed = False
    for label, mutated, target in mutants:
        caught = not run_case(mutated, target)
        print(f'175 STAB {label} {"caught" if caught else "ZHIV"} @ {target}')
        failed |= not caught
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
