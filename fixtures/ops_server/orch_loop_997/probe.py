#!/usr/bin/env python3
"""997 runtime probe. rc 0 matches, 1 behavioral mismatch, 2 unusable input.
Every subject runs in a fresh repository, with fake systemd and a real toy process.
No real systemd-run, omp, station PID or restart pathname is used.
"""
import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
CASES = ('marker_removed', 'removed_crash', 'scope_refused', 'second_refused', 'duplicate', 'bounded', 'clean_exit')
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
    }
    if name != 'honest':
        old, new = changes[name]
        if text.count(old) != 1:
            raise ValueError(f'model anchor {name}: {text.count(old)}')
        text = text.replace(old, new)
    return text


def run_case(text, case, identity='same'):
    # Expected values exist only in the checker, before any subject is invoked.
    expected_starts = dict(marker_removed=2, removed_crash=2, scope_refused=0,
                           second_refused=1, duplicate=1, bounded=3, clean_exit=1)[case]
    expected_rc = dict(marker_removed=0, removed_crash=0, scope_refused=1,
                       second_refused=1, duplicate=0, bounded=3, clean_exit=0)[case]
    with tempfile.TemporaryDirectory(prefix='orch997-') as directory:
        root = Path(directory)
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
        (root / 'events').touch()
        env = dict(PATH=f'{bin_dir}:/usr/bin:/bin', HOME=str(home), LANG='C.UTF-8',
                   ORCH_REPO=str(repo), ORCH_ENV=str(root / 'no-config'), ORCH_SELF_UPDATE='0',
                   ORCH_MARK=str(root / 'restart'), ORCH_STOP=str(root / 'stop'),
                   ORCH_LOG=str(root / 'loop.log'), ORCH_LOOP_AGENT_CMD=str(bin_dir / 'omp'),
                   ORCH_WORKSHOP=str(bin_dir / 'omp'), ORCH_AGENT_HOME=str(home),
                   ORCH_GRACE='0', ORCH_MIN_LIFE='3600', ORCH_EARLY_WAIT='0', ORCH_EARLY_MAX='3',
                   ORCH_MEM_MAX='64M', TOY_ROOT=str(root), TOY_CASE=case)
        if identity == 'other':
            env['ORCH_AGENT_USER'] = 'toy-agent'
        processes = []
        output_files = []
        def launch():
            output = tempfile.TemporaryFile()
            output_files.append(output)
            proc = subprocess.Popen([str(subject)], cwd=repo, env=env, stdin=subprocess.DEVNULL,
                                    stdout=output, stderr=subprocess.STDOUT, start_new_session=True)
            processes.append(proc)
            return proc
        def events():
            return [json.loads(line) for line in (root / 'events').read_text().splitlines()]
        errors = []
        second_rc = None
        try:
            first = launch()
            if case == 'duplicate':
                deadline = time.monotonic() + 8
                while not (root / 'ready').exists() and first.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.01)
                if not (root / 'ready').exists():
                    errors.append('SETUP_NO_AGENT')
                else:
                    second = launch()
                    # The duplicate must refuse while the first is still alive,
                    # not merely serialize into a second agent after it exits.
                    try:
                        second_rc = second.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        second_rc = 'still-running'
                    if first.poll() is not None:
                        errors.append('FIRST_INTERRUPTED')
                    (root / 'release').touch()
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
            count_error = 'BOUND' if case == 'bounded' else ('DUPLICATE' if case == 'duplicate' else 'RESTART_COUNT')
            if len(starts) != expected_starts:
                errors.append(count_error)
            if first.returncode != expected_rc:
                errors.append('REFUSAL' if case.endswith('refused') else 'EXIT_STATUS')
            # Full message payload after the existing timestamp/session prefix,
            # not a substring in an arbitrary part of the log.
            payloads = []
            for line in output.splitlines():
                if line[:4].isdigit() and ' ' in line:
                    line = line.split(' ', 1)[1]
                if line.startswith('сессия #') and ': ' in line:
                    line = line.split(': ', 1)[1]
                payloads.append(line)
            if case in ('scope_refused', 'second_refused'):
                if payloads.count(REFUSAL) != 1 or len(calls) != expected_starts + 1:
                    errors.append('REFUSAL')
            elif REFUSAL in payloads or LEGACY_FALSE in payloads:
                errors.append('TRUTHFUL_SCOPE')
            if starts and case != 'duplicate' and payloads.count(CONFIRMED) != expected_starts:
                errors.append('TRUTHFUL_SCOPE')
            if case == 'duplicate' and (second_rc != 1 or payloads.count(DUPLICATE) != 1):
                errors.append('DUPLICATE')
            if case == 'bounded' and len(calls) != 3:
                errors.append('BOUND')
            if case != 'scope_refused':
                if output.splitlines().count('TOY_STDOUT') != len(starts) or output.splitlines().count('TOY_STDERR') != len(starts):
                    errors.append('STDIO')
            live = set()
            for event in observed:
                if event['kind'] == 'agent_start':
                    if live and case != 'duplicate':
                        errors.append('SESSION_OVERLAP')
                    live.add(event['pid'])
                elif event['kind'] == 'agent_end':
                    live.discard(event['pid'])
            if case not in ('scope_refused', 'clean_exit') and not any(e['kind'] == 'receipt_deleted' for e in observed):
                # scope_refused has no session, so deletion is inapplicable.
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
        for case in CASES:
            result = run_case(model('honest'), case)
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
            for case in ('marker_removed', 'scope_refused'):
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
