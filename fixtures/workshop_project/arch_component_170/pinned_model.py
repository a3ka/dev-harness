#!/usr/bin/env python3
"""Executable acceptance model only; production stays in make_task.sh (implementer)."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

# Validate before releasing any bytes to the consumer; canonical command for the pack.
READER = '''import hashlib,os,pathlib,sys
try:
 p=pathlib.Path(sys.argv[1]).resolve(strict=True); state=pathlib.Path(sys.argv[4]).resolve(strict=True)
 forbidden=[pathlib.Path(x).resolve() for x in sys.argv[5:]]
 if not p.is_relative_to(state) or any(p.is_relative_to(x) for x in forbidden): raise ValueError("outside_state")
 if not p.is_file() or not os.access(p,os.R_OK) or not p.stat().st_mode & 292: raise ValueError("unavailable")
 b=p.read_bytes()
 if len(b)!=int(sys.argv[2]) or hashlib.sha256(b).hexdigest()!=sys.argv[3]: raise ValueError("integrity")
except (OSError,RuntimeError):
 print("ОТКАЗ: ARCH_BRIEF_PIN: unavailable",file=sys.stderr); sys.exit(1)
except ValueError as e:
 print("ОТКАЗ: ARCH_BRIEF_PIN: "+str(e),file=sys.stderr); sys.exit(1)
sys.stdout.buffer.write(b)
'''
READ_REQUIRED = 'ОБЯЗАТЕЛЬНОЕ ЧТЕНИЕ: выполни READ_COMMAND до работы; при rc != 0 остановись; прочитай stdout целиком.'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def state_directory(repo):
    common = subprocess.check_output(['git', '-C', str(repo), 'rev-parse', '--git-common-dir'], text=True).strip()
    common = (repo / common).resolve()
    state = Path(os.environ['TMPDIR']).resolve() / 'dev-harness-project-state' / digest(str(common).encode())[:16]
    roots = [repo.resolve(), common]
    worktrees = subprocess.check_output(['git', '-C', str(repo), 'worktree', 'list', '--porcelain'], text=True)
    roots += [Path(line[9:]).resolve() for line in worktrees.splitlines() if line.startswith('worktree ')]
    return state, list(dict.fromkeys(roots))


def pointer(component, path, data, state, roots):
    command = ['python3', '-c', READER, str(path), str(len(data)), digest(data), str(state), *map(str, roots)]
    return (f'COMPONENT: {component}\n{READ_REQUIRED}\nPIN: {path}\n'
            f'BYTES: {len(data)}\nSHA256: {digest(data)}\n'
            f'READ_COMMAND: {json.dumps(command, ensure_ascii=False)}\n')


def main():
    repo = Path(sys.argv[1])
    body, architecture, encoded_items = sys.stdin.buffer.read().split(b'\0', 2)
    mutant = os.environ.get('ARCH170_MODEL_MUTANT', '')
    if len(body) <= 40000 and mutant != 'small_pinned':
        sys.stdout.buffer.write(architecture)
        return 0
    state, roots = state_directory(repo)
    if any(state.resolve().is_relative_to(root) for root in roots):
        raise ValueError('outside_state')
    state.mkdir(parents=True, exist_ok=True)
    items = [(component, data.encode()) for component, data in
             (json.loads(line) for line in encoded_items.splitlines())]
    output = [f'COMPONENT: {component}\n' + data.decode() for component, data in items]
    selected = set()
    for index in sorted(range(len(items)), key=lambda i: -len(items[i][1])):
        if len(body) - len(architecture) + len(''.join(output).encode()) <= 40000 and mutant not in ('small_pinned', 'all_pinned'):
            break
        component, data = items[index]
        path = state / 'briefs' / (digest(data) + '.txt')
        output[index] = pointer(component, path, data, state, roots)
        selected.add(index)
    for index in sorted(selected):
        component, data = items[index]
        if mutant == 'slice':
            data = data[:200]
        path = state / 'briefs' / (digest(data) + '.txt')
        if mutant == 'inside_checkout':
            path = repo / '.brief-170.txt'
        if mutant == 'inside_git':
            path = repo / '.git' / 'brief-170.txt'
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists() and not path.is_symlink():
            path.write_bytes(data)
        command = ['python3', '-c', READER, str(path), str(len(data)), digest(data), str(state), *map(str, roots)]
        checked = subprocess.run(command, capture_output=True)
        if checked.returncode and mutant != 'unchecked_issue':
            sys.stderr.buffer.write(checked.stderr)
            return 1
        entry = pointer(component, path, data, state, roots)
        if mutant == 'no_instruction':
            entry = entry.replace(READ_REQUIRED + '\n', '')
        if mutant == 'wrong_component':
            entry = entry.replace('COMPONENT: ' + component, 'COMPONENT: unrelated')
        if mutant == 'wrong_bytes':
            entry = entry.replace('BYTES: ' + str(len(data)), 'BYTES: 1')
        if mutant == 'wrong_hash':
            entry = entry.replace('SHA256: ' + digest(data), 'SHA256: ' + '0' * 64)
        if mutant == 'reader_without_length':
            entry = entry.replace('len(b)!=int(sys.argv[2]) or ', '')
        if mutant == 'reader_without_hash':
            entry = entry.replace(' or hashlib.sha256(b).hexdigest()!=sys.argv[3]', '')
        if mutant == 'unchecked_read':
            command = ['cat', str(path)]
            entry = entry[:entry.index('READ_COMMAND: ')] + 'READ_COMMAND: ' + json.dumps(command) + '\n'
        output[index] = entry
    sys.stdout.write(''.join(output))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError):
        print('ОТКАЗ: ARCH_BRIEF_PIN: unavailable', file=sys.stderr)
        sys.exit(1)
    except ValueError as error:
        print('ОТКАЗ: ARCH_BRIEF_PIN: ' + str(error), file=sys.stderr)
        sys.exit(1)
