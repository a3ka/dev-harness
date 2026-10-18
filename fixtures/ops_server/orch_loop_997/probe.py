#!/usr/bin/env python3
"""997 runtime probe. rc 0 matches, 1 behavioral mismatch, 2 unusable input.
Every subject runs in a fresh repository, with fake systemd and a real toy process.
No real systemd-run, omp, station PID or restart pathname is used.
"""
import argparse
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
CASES = ('marker_removed', 'removed_crash', 'removed_crash_1', 'removed_crash_137',
         'scope_refused', 'scope_refused_137', 'second_refused',
         'duplicate', 'duplicate_mark', 'duplicate_log', 'lock_held',
         'lock_before_update', 'bounded', 'clean_exit')
DUP_CASES = ('duplicate', 'duplicate_mark', 'duplicate_log')
HELD_CASES = ('lock_held', 'lock_before_update')
REFUSED_CASES = ('scope_refused', 'scope_refused_137', 'second_refused')
REFUSAL = 'запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)'
LEGACY_FALSE = 'ресурсный предел не создан — запуск без потолка запрещён (И-5, контракт 093)'
CONFIRMED = 'scope подтверждён (канал запуска); файловая метка не используется'
DUPLICATE = 'ОТКАЗ: orch-loop уже запущен'
# Associations are executable, not claims in the contract. All defects are
# observable on their assigned input; the same input must accept the model.
MUTANTS = {
    'named_receipt': ('marker_removed', 'RESTART_COUNT'),
    'fallback': ('scope_refused', 'UNSCOPED'),
    'no_lock': ('duplicate', 'DUPLICATE'),
    'reset_bound': ('bounded', 'BOUND'),
    'false_diagnosis': ('removed_crash', 'TRUTHFUL_SCOPE'),
    'stale_receipt': ('second_refused', 'REFUSAL'),
    'rc_witness': ('removed_crash_1', 'TRUTHFUL_SCOPE'),
    'rc_137_witness': ('removed_crash_137', 'TRUTHFUL_SCOPE'),
    'renamed_file': ('marker_removed', 'RESTART_COUNT'),
    'home_file': ('removed_crash', 'RESTART_COUNT'),
    'directory_receipt': ('marker_removed', 'RESTART_COUNT'),
    'fifo_receipt': ('marker_removed', 'RESTART_COUNT'),
    'mark_lock': ('duplicate_mark', 'DUPLICATE'),
    'log_lock': ('duplicate_log', 'DUPLICATE'),
    'wrong_home_lock': ('lock_held', 'LOCK_PATH'),
    'late_lock': ('lock_held', 'LOCK_STATE'),
    'late_update_lock': ('lock_before_update', 'LOCK_STATE'),
    'stdout_witness': ('scope_refused', 'REFUSAL'),
}

def model(name):
    text = (HERE / 'model.sh').read_text()
    changes = {
        'named_receipt': ('if [ "$receipt" != SCOPED ]; then', 'if [ ! -e "$ORCH_MARK.scoped" ]; then'),
        'fallback': ('    exit 1\n  fi', '    "$ORCH_LOOP_AGENT_CMD" --yolo -- fallback\n    exit 1\n  fi'),
        'no_lock': ("flock -n 9 || { log 'ОТКАЗ: orch-loop уже запущен'; exit 1; }", ':'),
        'reset_bound': ('n=$((n+1)); start=$SECONDS', 'n=$((n+1)); start=$SECONDS; early=0'),
        'false_diagnosis': (CONFIRMED, REFUSAL),
        'stale_receipt': ('if [ "$receipt" != SCOPED ]; then', 'if [ "$receipt" != SCOPED ] && [ "$n" -eq 1 ]; then'),
        'rc_witness': ('if [ "$receipt" != SCOPED ]; then', 'if [ "$rc" -eq 1 ]; then'),
        'rc_137_witness': ('if [ "$receipt" != SCOPED ]; then', 'if [ "$rc" -eq 137 ]; then'),
        'renamed_file': ('if [ "$receipt" != SCOPED ]; then', 'if [ ! -e "$ORCH_MARK.ran" ]; then'),
        'home_file': ('if [ "$receipt" != SCOPED ]; then', 'if [ ! -e "$HOME/.receipt" ]; then'),
        'directory_receipt': ('if [ "$receipt" != SCOPED ]; then', 'if [ ! -d "$HOME/.receipt-dir" ]; then'),
        'fifo_receipt': ('if [ "$receipt" != SCOPED ]; then', 'if [ ! -p "$HOME/.receipt-fifo" ]; then'),
        'mark_lock': ('exec 9>"$HOME/.local/state/dev-harness/orch-loop.lock"', 'exec 9>"$ORCH_MARK.lock"'),
        'log_lock': ('exec 9>"$HOME/.local/state/dev-harness/orch-loop.lock"', 'exec 9>"$ORCH_LOG.lock"'),
        'wrong_home_lock': ('exec 9>"$HOME/.local/state/dev-harness/orch-loop.lock"', 'exec 9>"$HOME/.local/state/dev-harness/other.lock"'),
        'late_lock': ('mkdir -p "$HOME/.local/state/dev-harness"', 'rm -f "$ORCH_MARK" "$ORCH_MARK.go"\nmkdir -p "$HOME/.local/state/dev-harness"'),
        'late_update_lock': ('mkdir -p "$HOME/.local/state/dev-harness"', 'if [ "${ORCH_SELF_UPDATE:-0}" = 1 ]; then bash "$ORCH_REPO/ops/server/install.sh" user; fi\nmkdir -p "$HOME/.local/state/dev-harness"'),
        'stdout_witness': ('  systemd-run --user', '  receipt_output="$(systemd-run --user'),
    }
    if name != 'honest':
        old, new = changes[name]
        if text.count(old) != 1:
            raise ValueError(f'model anchor {name}: {text.count(old)}')
        text = text.replace(old, new)
        if name in ('named_receipt', 'renamed_file', 'home_file'):
            path = {'named_receipt': '$ORCH_MARK.scoped', 'renamed_file': '$ORCH_MARK.ran',
                    'home_file': '$HOME/.receipt'}[name]
            text = text.replace('  systemd-run --user', f'  touch "{path}"\n  systemd-run --user')
        if name in ('directory_receipt', 'fifo_receipt'):
            create = 'mkdir "$HOME/.receipt-dir"' if name == 'directory_receipt' else 'mkfifo "$HOME/.receipt-fifo"'
            text = text.replace('  systemd-run --user', f'  {create}\n  systemd-run --user')
        if name == 'stdout_witness':
            text = text.replace('  rc=$?', '  )"; rc=$?\n  printf \'%s\\n\' "$receipt_output"')
            text = text.replace('  exec 7<&-', '  receipt="$receipt_output"\n  exec 7<&-')
    return text


def run_case(text, case, identity='same'):
    # Expected values exist only in the checker, before any subject is invoked.
    expected_starts = (0 if case in HELD_CASES or case.startswith('scope_refused') else
                       1 if case in DUP_CASES or case in ('second_refused', 'clean_exit') else
                       3 if case == 'bounded' else 2)
    expected_rc = 1 if case in REFUSED_CASES + HELD_CASES else 3 if case == 'bounded' else 0
    with tempfile.TemporaryDirectory(prefix='orch997-') as directory:
        root = Path(directory)
        control = root / 'control'
        control.mkdir()
        repo = root / 'repo'
        repo.mkdir()
        subprocess.run(['git', '-C', str(repo), 'init', '-q'], check=True,
                       env={'PATH': '/usr/bin:/bin', 'HOME': str(root)})
        bin_dir = root / 'bin'
        bin_dir.mkdir()
        for name in ('systemd-run', 'systemctl', 'sudo', 'omp'):
            target = bin_dir / name
            target.write_bytes((HERE / 'backend.py').read_bytes())
            target.chmod(0o755)
        subject = repo / 'orch-loop'
        subject.write_text(text)
        subject.chmod(0o755)
        home = root / 'home'
        home.mkdir()
        (control / 'events').touch()
        state = root / 'volatile-state'
        state.mkdir()
        env = dict(PATH=f'{bin_dir}:/usr/bin:/bin', HOME=str(home), LANG='C.UTF-8',
                   ORCH_REPO=str(repo), ORCH_ENV=str(root / 'no-config'), ORCH_SELF_UPDATE='0',
                   ORCH_MARK=str(state / 'restart'), ORCH_STOP=str(root / 'stop'),
                   ORCH_LOG=str(root / 'loop.log'), ORCH_LOOP_AGENT_CMD=str(bin_dir / 'omp'),
                   ORCH_WORKSHOP=str(bin_dir / 'omp'), ORCH_AGENT_HOME=str(home),
                   ORCH_GRACE='0', ORCH_MIN_LIFE='3600', ORCH_EARLY_WAIT='0', ORCH_EARLY_MAX='3',
                   ORCH_MEM_MAX='64M', TOY_ROOT=str(root), TOY_CASE=case)
        if identity == 'other':
            env['ORCH_AGENT_USER'] = 'toy-agent'
        lock = home / '.local/state/dev-harness/orch-loop.lock'
        lock.parent.mkdir(parents=True)
        held_lock = None
        saved_state = {}
        if case in HELD_CASES:
            for suffix in ('', '.go', '.pgid'):
                path = Path(env['ORCH_MARK'] + suffix)
                saved_state[path] = ('owned restart ' + suffix).encode()
                path.write_bytes(saved_state[path])
            held_lock = lock.open('a')
            fcntl.flock(held_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if case == 'lock_before_update':
            # A real self-update branch, but ONLY a private installer. Any call
            # is an observable state mutation before singleton refusal.
            installer = repo / 'ops/server/install.sh'
            installer.parent.mkdir(parents=True)
            installer.write_text('#!/bin/bash\nprintf "UPDATE\\n" >>"$TOY_ROOT/control/install-calls"\nexit 1\n')
            candidate = installer.parent / 'user/orch-loop'
            candidate.parent.mkdir()
            candidate.write_text('#!/bin/bash\nexit 0\n')
            env['ORCH_SELF_UPDATE'] = '1'
        env['TOY_BASELINE'] = json.dumps([str(p) for p in root.rglob('*')])
        processes = []
        output_files = []
        def launch(overrides=None):
            output = tempfile.TemporaryFile()
            output_files.append(output)
            proc = subprocess.Popen([str(subject)], cwd=repo, env=env | (overrides or {}), stdin=subprocess.DEVNULL,
                                    stdout=output, stderr=subprocess.STDOUT, start_new_session=True)
            processes.append(proc)
            return proc
        def events():
            return [json.loads(line) for line in (control / 'events').read_text().splitlines()]
        errors = []
        second_rc = None
        try:
            first = launch()
            if case in DUP_CASES:
                deadline = time.monotonic() + 8
                while not (control / 'ready').exists() and first.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.01)
                if not (control / 'ready').exists():
                    errors.append('SETUP_NO_AGENT')
                else:
                    overrides = {}
                    if case in ('duplicate', 'duplicate_mark'):
                        overrides['ORCH_MARK'] = str(state / 'different-restart')
                    if case in ('duplicate', 'duplicate_log'):
                        overrides['ORCH_LOG'] = str(root / 'different.log')
                    second = launch(overrides)
                    # The duplicate must refuse while the first is still alive,
                    # not merely serialize into a second agent after it exits.
                    try:
                        second_rc = second.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        second_rc = 'still-running'
                    if first.poll() is not None:
                        errors.append('FIRST_INTERRUPTED')
                    (control / 'release').touch()
            try:
                first.wait(timeout=18)
            except subprocess.TimeoutExpired:
                errors.append('TIMEOUT')
            for proc in processes[1:]:
                try:
                    proc.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    errors.append('TIMEOUT')
            observed = events()
            if case in HELD_CASES:
                if any(not p.exists() or p.read_bytes() != value for p, value in saved_state.items()):
                    errors.append('LOCK_STATE')
                if (control / 'install-calls').exists():
                    errors.append('LOCK_STATE')
            output = ''
            for stream in output_files:
                stream.seek(0)
                output += stream.read().decode(errors='replace')
            starts = [e for e in observed if e['kind'] == 'agent_start']
            calls = [e for e in observed if e['kind'] == 'scope_call']
            if any(e['kind'].startswith('bad_') or e['kind'] == 'unexpected_tool' for e in observed):
                errors.append('INVALID_TOOL_CALL')
            if any(not e['scoped'] for e in starts):
                errors.append('UNSCOPED')
            count_error = 'BOUND' if case == 'bounded' else ('DUPLICATE' if case in DUP_CASES else 'RESTART_COUNT')
            if len(starts) != expected_starts:
                errors.append(count_error)
            if first.returncode != expected_rc:
                errors.append('REFUSAL' if case in REFUSED_CASES else 'EXIT_STATUS')
            # Full message payload after the existing timestamp/session prefix,
            # not a substring in an arbitrary part of the log.
            payloads = []
            for line in output.splitlines():
                if line[:4].isdigit() and ' ' in line:
                    line = line.split(' ', 1)[1]
                if line.startswith('сессия #') and ': ' in line:
                    line = line.split(': ', 1)[1]
                payloads.append(line)
            if case in REFUSED_CASES:
                if payloads.count(REFUSAL) != 1 or len(calls) != expected_starts + 1:
                    errors.append('REFUSAL')
            elif REFUSAL in payloads or LEGACY_FALSE in payloads:
                errors.append('TRUTHFUL_SCOPE')
            if starts and case not in DUP_CASES and payloads.count(CONFIRMED) != expected_starts:
                errors.append('TRUTHFUL_SCOPE')
            if case in DUP_CASES and (second_rc != 1 or payloads.count(DUPLICATE) != 1):
                errors.append('DUPLICATE')
            if case in HELD_CASES and (first.returncode != 1 or payloads.count(DUPLICATE) != 1 or starts or calls):
                errors.append('LOCK_PATH')
            if case == 'bounded' and len(calls) != 3:
                errors.append('BOUND')
            if not case.startswith('scope_refused'):
                if output.splitlines().count('TOY_STDOUT') != len(starts) or output.splitlines().count('TOY_STDERR') != len(starts):
                    errors.append('STDIO')
            live = set()
            for event in observed:
                if event['kind'] == 'agent_start':
                    if live and case not in DUP_CASES:
                        errors.append('SESSION_OVERLAP')
                    live.add(event['pid'])
                elif event['kind'] == 'agent_end':
                    live.discard(event['pid'])
            if case not in DUP_CASES + HELD_CASES + ('scope_refused', 'scope_refused_137', 'clean_exit'):
                deletions = [e for e in observed if e['kind'] == 'receipt_deleted']
                if not deletions or not all(e['canaries_removed'] for e in deletions):
                    errors.append('SETUP_NO_DELETION')
            result = dict(case=case, identity=identity, rc=first.returncode, second_rc=second_rc,
                          starts=len(starts), scope_calls=len(calls), errors=sorted(set(errors)))
            if errors:
                result['output'] = output
            return result
        finally:
            # Only private session groups and recorded toy PIDs. The other-uid
            # path uses setsid, so also clean those descendants explicitly.
            for proc in processes:
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            for event in events():
                if event['kind'] != 'agent_start':
                    continue
                try:
                    environ = Path(f"/proc/{event['pid']}/environ").read_bytes()
                    if ('TOY_ROOT=' + str(root)).encode() + b'\0' in environ:
                        os.kill(event['pid'], signal.SIGKILL)
                except (FileNotFoundError, ProcessLookupError):
                    pass
            for proc in processes:
                proc.wait()
            for stream in output_files:
                stream.close()
            if held_lock is not None:
                held_lock.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--cases', action='store_true')
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--subject', type=Path, default=HERE.parents[2] / 'ops/server/user/orch-loop')
    args = parser.parse_args()
    failures = 0
    count = 0
    if args.matrix:
        for identity in ('same', 'other'):
            for case in CASES:
                result = run_case(model('honest'), case, identity)
                count += 1
                failures += bool(result['errors'])
                print('HONEST ' + json.dumps(result, ensure_ascii=False), flush=True)
        for name, (case, reason) in MUTANTS.items():
            result = run_case(model(name), case)
            valid = reason in result['errors'] and not any(e.startswith('SETUP_') or e in ('TIMEOUT', 'INVALID_TOOL_CALL') for e in result['errors'])
            count += 1
            failures += not valid
            print(f'MUTANT {name} caught={int(valid)} ' + json.dumps(result, ensure_ascii=False), flush=True)
    else:
        text = args.subject.read_text()
        selected = (args.case,) if args.case else CASES
        for case in selected:
            result = run_case(text, case)
            count += 1
            failures += bool(result['errors'])
            print('SUBJECT ' + json.dumps(result, ensure_ascii=False), flush=True)
        if not args.case:
            for case in CASES:
                result = run_case(text, case, 'other')
                count += 1
                failures += bool(result['errors'])
                print('SUBJECT ' + json.dumps(result, ensure_ascii=False), flush=True)
    print(f'997 observed={count} mismatches={failures}')
    return int(failures != 0) if count else 2

if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f'NOT_IMPLEMENTED: {error}')
        raise SystemExit(2)
