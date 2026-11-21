"""Pinned-brief delta at the public producer and emitted consumer-command seams."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import pinned_model as canon

STDERR_CASES = ('brief_stderr_pinned', 'brief_stderr_pinned_plain',
                'brief_stderr_inline', 'brief_stderr_inline_plain')
SUCCESS_WARNING = 'npm WARN successful brief'
EXPLAINED_CASES = ('brief_pin_symlink_loop_explained', 'brief_read_symlink_loop_explained')

CASES = ('brief_pinned_over_budget', 'brief_pinned_plain', 'brief_pinned_multi',
         'brief_pin_missing', 'brief_pin_tampered', 'brief_pin_unreadable',
         'brief_pin_checkout', 'brief_pin_git', 'brief_read_missing',
         'brief_read_tampered', 'brief_read_same_size', 'brief_small_inline',
         'brief_pack_cap', 'brief_no_slice', 'brief_aggregate_budget',
         'brief_mixed_small_inline', 'brief_pinned_spaces', 'brief_pinned_external_symlink',
         'brief_read_length_pin', 'brief_read_checkout', *STDERR_CASES,
         'brief_pin_symlink_loop', 'brief_read_symlink_loop', 'brief_inline_crlf',
         *EXPLAINED_CASES)


def model_text(legacy, helper):
    # Only the acceptance model is extended; no production file is changed.
    legacy = legacy.replace('ARCH_SEC=""', 'ARCH_SEC=""; ARCH170_ITEMS=""', 1)
    text = legacy.replace('--component "$_arch_id" 2>/dev/null)"',
                          '--component "$_arch_id" 2>/dev/null; _status=$?; printf \'\\037\'; exit "$_status")"')
    text = text.replace('      [ -n "$_arch_text" ]', '      _arch_text="${_arch_text%$\'\\037\'}"\n      [ -n "$_arch_text" ]')
    collection = '''_arch_item="$(printf '%s' "$_arch_text" | python3 -c 'import json,sys; print(json.dumps([sys.argv[1], sys.stdin.read()]))' "$_arch_id")"
      ARCH170_ITEMS="${ARCH170_ITEMS}${_arch_item}
"
      ARCH_SEC="${ARCH_SEC}${_arch_text}"'''
    text = text.replace('ARCH_SEC="${ARCH_SEC}${_arch_text}\n"', collection)
    anchor = 'VK="$(pack_body | wc -c | tr -d \' \')"'
    stage = ("ARCH_SEC=\"$( { pack_body; printf '\\0%s\\0%s' \"$ARCH_SEC\" \"$ARCH170_ITEMS\"; } | "
             f'python3 "{helper}" "$REPO"; _status=$?; printf \'\\037\'; exit "$_status")" || exit 1\n'
             'ARCH_SEC="${ARCH_SEC%$\'\\037\'}"\n')
    if text.count(anchor) != 1:
        raise ValueError('pinned model budget anchor')
    return text.replace(anchor, stage + anchor)


def refusal(result, reason=''):
    lines = result.stderr.splitlines()
    prefix = ('ОТКАЗ: ARCH_BRIEF_PIN:' + (' ' + reason if reason else '')).encode()
    return (result.returncode == 1 and not result.stdout and bool(lines)
            and lines[0].startswith(prefix))


def pin_bytes(path, state, roots):
    """Unreadable or unsafe subject paths are a failed observation, never an oracle."""
    try:
        resolved = path.resolve(strict=True)
        if (not path.is_absolute() or not resolved.is_relative_to(state.resolve())
                or any(resolved.is_relative_to(root) for root in roots)
                or not resolved.is_file()):
            return None
        return resolved.read_bytes()
    except (OSError, RuntimeError):
        return None


def run_case(probe, name, subject, mutant=''):
    built, repo = probe.world(context_padding=41000 if name == 'brief_pack_cap' else 0)
    old_tmp = os.environ.get('TMPDIR')
    try:
        state_base = built / ('state with spaces' if name == 'brief_pinned_spaces' else 'state')
        state_base.mkdir()
        os.environ['TMPDIR'] = str(state_base)
        state, roots = canon.state_directory(repo)
        ids = probe.IDS if name in ('brief_pinned_multi', 'brief_aggregate_budget',
                                   'brief_mixed_small_inline', 'brief_pin_missing',
                                   'brief_pin_tampered') else probe.IDS[:1]
        inline = name in ('brief_small_inline', 'brief_stderr_inline', 'brief_stderr_inline_plain',
                          'brief_inline_crlf')
        size = 12 if inline else 19000 if name == 'brief_aggregate_budget' else 45723
        role = 'implementer' if name in ('brief_pinned_plain', 'brief_stderr_pinned_plain',
                                        'brief_stderr_inline_plain') else 'architect'
        expected = {ident: (f'# ARCH-BRIEF:{ident}\nBEGIN:{name}:{ident}\n' + 'ю' * size
                            + f'\nEND:{name}:{ident}\n\n').encode() for ident in ids}
        if inline:
            expected = {ident: data[:-1] for ident, data in expected.items()}
        if name == 'brief_mixed_small_inline':
            expected[ids[1]] = b'# ARCH-BRIEF:worker.events\nSMALL-BRIEF-STAYS-INLINE\n'
        if name == 'brief_no_slice':
            expected[ids[0]] += b'# ARCH-BRIEF:not-a-component\nUNTRUSTED-CONTENT-NOT-STRUCTURE\r\n'
        if name in ('brief_pin_symlink_loop', 'brief_read_symlink_loop', *EXPLAINED_CASES):
            header = f'# ARCH-BRIEF:{ids[0]}\n'.encode()
            expected[ids[0]] = header + b'L' * (45000 - len(header) - 1) + b'\n'
        if name == 'brief_inline_crlf':
            expected[ids[0]] = f'# ARCH-BRIEF:{ids[0]}\r\nline\r\n'.encode()
        # Capture every expected byte before the subject can touch its source or state.
        source = built / 'source'
        source.mkdir()
        for ident, data in expected.items():
            (source / (ident + '.txt')).write_bytes(data)
        first_data = expected[ids[0]]
        pin_data = expected[ids[-1]]
        pin = state / 'briefs' / (canon.digest(pin_data) + '.txt')
        if name == 'brief_pinned_external_symlink':
            pin.parent.mkdir(parents=True)
            target = pin.parent / 'honest-equivalent.txt'
            target.write_bytes(first_data)
            pin.symlink_to(target)
        if name in ('brief_pin_missing', 'brief_pin_tampered', 'brief_pin_unreadable',
                    'brief_pin_checkout', 'brief_pin_git', 'brief_pin_symlink_loop',
                    'brief_pin_symlink_loop_explained'):
            pin.parent.mkdir(parents=True)
            if name == 'brief_pin_missing':
                pin.symlink_to(built / 'absent')
            elif name in ('brief_pin_symlink_loop', 'brief_pin_symlink_loop_explained'):
                pin.symlink_to(pin)
            elif name in ('brief_pin_checkout', 'brief_pin_git'):
                target = repo / ('.git' if name == 'brief_pin_git' else 'architecture') / 'brief.txt'
                target.write_bytes(first_data)
                pin.symlink_to(target)
            else:
                pin.write_bytes(b'corrupted' if name == 'brief_pin_tampered' else pin_data)
                if name == 'brief_pin_unreadable':
                    pin.chmod(0)
        with tempfile.TemporaryDirectory(dir=probe.VERIFY, prefix='arch170-pin-bin-') as bindir:
            Path(bindir, 'npm').symlink_to(probe.HERE / 'npm_stub.py')
            env = dict(os.environ, ARCH170_PROJECT=str(repo), ARCH170_NONCE=name,
                       ARCH170_CALLS=str(built / 'calls'), ARCH170_BRIEF_DIR=str(source),
                       ARCH170_MODEL_MUTANT=mutant, PATH=bindir + os.pathsep + os.environ['PATH'])
            if name in STDERR_CASES:
                env['ARCH170_SUCCESS_STDERR'] = SUCCESS_WARNING
            envelope = ([sys.executable, str(probe.HERE / 'refusal_output.py'),
                         mutant if mutant.startswith('refusal_') else 'explain']
                        if name in EXPLAINED_CASES else [])
            result = probe.invoke(subject, repo, role, ','.join(ids), env=env,
                                  prefix=envelope if name == EXPLAINED_CASES[0] else ())
        if name.startswith('brief_pin_') and name != 'brief_pinned_over_budget':
            good = refusal(result)
            if name in ('brief_pin_symlink_loop', EXPLAINED_CASES[0]):
                good &= refusal(result, 'unavailable')
        elif name == 'brief_pack_cap':
            good = (result.returncode == 1 and not result.stdout
                    and result.stderr.startswith('ОТКАЗ: режь задачу:'.encode()) and b'> 40000' in result.stderr)
        elif inline:
            body = result.stdout.split(b'=== MANIFEST ===\n')[0]
            good = (result.returncode == 0 and first_data in body and b'PIN: ' not in body
                    and not (state / 'briefs').exists() and len(body) <= 40000)
            if name in STDERR_CASES or name == 'brief_inline_crlf':
                section = body.split(b'=== ARCHITECTURE BRIEF ===\n', 1)[-1].split(b'=== ', 1)[0]
                good &= section == first_data
        else:
            good = result.returncode == 0
            body = result.stdout.split(b'=== MANIFEST ===\n')[0]
            good &= len(body) <= 40000 and b'/40000\n' in result.stdout
            good &= b'MAP: STRUCTURE.md :: all modules\n' in body and b'RULES: COMMON-RULES.md\n' in body
            section = body.split(b'=== ARCHITECTURE BRIEF ===\n', 1)[-1].split(b'=== ', 1)[0].decode()
            blocks = section.split('COMPONENT: ')[1:]
            good &= len(blocks) == len(ids)
            for ident, block in zip(ids, blocks):
                lines = block.splitlines()
                good &= lines[0] == ident
                if name == 'brief_mixed_small_inline' and ident == ids[1]:
                    good &= block.split('\n', 1)[-1].encode() == expected[ident]
                    good &= 'PIN: ' not in block
                    continue
                good &= canon.READ_REQUIRED in lines
                fields = {}
                for line in lines[1:]:
                    key, sep, value = line.partition(': ')
                    if sep:
                        if key in fields:
                            good = False
                        fields[key] = value
                data = expected[ident]
                path = Path(fields.get('PIN', '/unavailable'))
                actual = pin_bytes(path, state, roots)
                good &= (fields.get('BYTES') == str(len(data)) and fields.get('SHA256') == canon.digest(data)
                         and actual == data)
                command = json.loads(fields.get('READ_COMMAND', '[]'))
                if not command:
                    good = False
                    continue
                read = subprocess.run(command, capture_output=True, timeout=20)
                good &= read.returncode == 0 and read.stdout == data and not read.stderr
                if name.startswith('brief_read_') and actual is not None:
                    if name == 'brief_read_missing':
                        path.unlink()
                    elif name == 'brief_read_same_size':
                        path.write_bytes(bytes([data[0] ^ 1]) + data[1:])
                    elif name == 'brief_read_length_pin':
                        if len(command) < 5:
                            good = False
                            continue
                        command[4] = str(len(data) + 1)
                    elif name == 'brief_read_checkout':
                        path.unlink()
                        target = repo / 'architecture' / 'moved-brief.txt'
                        target.write_bytes(data)
                        path.symlink_to(target)
                    elif name in ('brief_read_symlink_loop', EXPLAINED_CASES[1]):
                        path.unlink()
                        path.symlink_to(path)
                    else:
                        path.write_bytes(data[:-1])
                    checked = subprocess.run([*envelope, *command], capture_output=True, timeout=20)
                    good &= refusal(checked)
                    if name in ('brief_read_symlink_loop', EXPLAINED_CASES[1]):
                        good &= refusal(checked, 'unavailable')
        if name in STDERR_CASES:
            good &= SUCCESS_WARNING.encode() not in result.stdout
        print(f'170 {name} {"ok" if good else "KRASNO"} rc={result.returncode} '
              f'stderr={result.stderr.decode().strip()!r}', flush=True)
        return bool(good)
    finally:
        if old_tmp is None:
            os.environ.pop('TMPDIR', None)
        else:
            os.environ['TMPDIR'] = old_tmp
        shutil.rmtree(built)


def cells(probe, subject):
    return probe.run_cells(CASES, subject)


# Each mutation has its own observable input; no prose-maintained branch map.
MUTANTS = (
    ('small_pinned', 'brief_small_inline'),
    ('slice', 'brief_no_slice'),
    ('inside_checkout', 'brief_pinned_over_budget'),
    ('inside_git', 'brief_pinned_over_budget'),
    ('unchecked_issue', 'brief_pin_missing'),
    ('unchecked_issue', 'brief_pin_tampered'),
    ('unchecked_issue', 'brief_pin_unreadable'),
    ('unchecked_issue', 'brief_pin_checkout'),
    ('unchecked_issue', 'brief_pin_git'),
    ('no_instruction', 'brief_pinned_over_budget'),
    ('wrong_component', 'brief_pinned_over_budget'),
    ('wrong_bytes', 'brief_pinned_over_budget'),
    ('wrong_hash', 'brief_pinned_over_budget'),
    ('unchecked_read', 'brief_read_missing'),
    ('unchecked_read', 'brief_read_tampered'),
    ('unchecked_read', 'brief_read_same_size'),
    ('all_pinned', 'brief_mixed_small_inline'),
    ('cap_raised', 'brief_pack_cap'),
    ('brief_outside_budget', 'brief_pinned_over_budget'),
    ('reader_without_length', 'brief_read_length_pin'),
    ('reader_without_hash', 'brief_read_same_size'),
    ('unchecked_read', 'brief_read_checkout'),
    *(('stderr_merged', branch) for branch in STDERR_CASES),
    ('loop_traceback', 'brief_pin_symlink_loop'),
    ('loop_traceback', 'brief_read_symlink_loop'),
    ('crlf_normalized', 'brief_inline_crlf'),
    *((mode, branch) for mode in ('refusal_rc', 'refusal_stdout', 'refusal_no_prefix',
                                 'refusal_empty_stderr', 'refusal_traceback')
      for branch in EXPLAINED_CASES),
)

CHECKER_MUTANTS = (('exact_producer_refusal', EXPLAINED_CASES[0]),
                   ('exact_reader_refusal', EXPLAINED_CASES[1]))


def run_checker_mutant(item):
    subject, checker, name, branch = item
    spec = importlib.util.spec_from_file_location('pinned_exact_refusal', checker)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    probe = sys.modules['probe'] if 'probe' in sys.modules else sys.modules['__main__']
    # The strict checker must still accept the same refusal without explanation.
    neighbor = module.run_case(probe, branch.removesuffix('_explained'), subject)
    explained = module.run_case(probe, branch, subject)
    caught = neighbor and not explained
    print(f'170 STAB {name} {"caught" if caught else "ZHIV"} @ {branch}', flush=True)
    return caught


def stabs(probe, subject):
    honest = subject.read_text()
    helper = probe.HERE / 'pinned_model.py'
    jobs = []
    with tempfile.TemporaryDirectory(dir=subject.parent, prefix='pin-mutants-') as directory:
        for mutant, branch in MUTANTS:
            text = honest
            if mutant in ('loop_traceback', 'crlf_normalized'):
                mutated = helper.read_text()
                if mutant == 'loop_traceback':
                    mutated = probe.replace_once(mutated, 'except (OSError,RuntimeError):',
                                                 'except FileNotFoundError:')
                else:
                    mutated = probe.replace_once(mutated, 'sys.stdout.buffer.write(architecture)',
                                                 "sys.stdout.buffer.write(architecture.replace(b'\\r\\n', b'\\n'))")
                candidate = Path(directory) / (mutant + '.py')
                candidate.write_text(mutated)
                text = probe.replace_once(text, str(helper), str(candidate))
            if mutant == 'stderr_merged':
                old = '2>/dev/null; _status=$?'
                if text.count(old) != 2:
                    raise ValueError('expected both npm stream branches')
                text = text.replace(old, '2>&1; _status=$?')
            if mutant == 'cap_raised':
                text = probe.replace_once(text, '[ "$VK" -le 40000 ]', '[ "$VK" -le 400000 ]')
            if mutant == 'brief_outside_budget':
                text = probe.replace_once(text, '  [ -z "$ARCH_SEC" ] || printf \'=== ARCHITECTURE BRIEF ===\\n%s\' "$ARCH_SEC"',
                                          '  : # brief excluded from measured pack')
                text += '\n[ -z "$ARCH_SEC" ] || printf \'=== ARCHITECTURE BRIEF ===\\n%s\' "$ARCH_SEC"\n'
            jobs.append((subject, text, mutant, branch, mutant))
        misses = probe.run_mutants(jobs)
        checker = Path(directory) / 'pinned_exact_refusal.py'
        prefix_check = 'lines[0].' + 'startswith(prefix)'
        checker.write_text(probe.replace_once(
            Path(__file__).read_text(), prefix_check,
            '(lines[0] == prefix if reason else ' + prefix_check + ')'))
        checker_jobs = [(subject, checker, name, branch) for name, branch in CHECKER_MUTANTS]
        return misses + sum(not caught for caught in probe.run_parallel(run_checker_mutant, checker_jobs))
