#!/usr/bin/env python3
"""Rev187B5: observable scratch lifetime across real process-group signals.

The public library is called through $(...), as in make_task. No predicate
requires a particular filename, allocation site, or cleanup implementation.
"""
import os
from pathlib import Path
import signal
import subprocess
import time

from brief_stderr import BODY, FIRST, PREFIX

# Each signal cell covers a borrowed model and a caller-owned model directory.
CASES = (
    ('brief-signal-group-term', signal.SIGTERM, True),
    ('brief-signal-group-int', signal.SIGINT, True),
    ('brief-signal-parent-term', signal.SIGTERM, False),
    ('brief-cleanup-neighbor', None, False),
)
STABS = {
    'brief-signal-S1-normal-only-term': ('brief-signal-group-term', 'normal-only'),
    'brief-signal-S1-normal-only-int': ('brief-signal-group-int', 'normal-only'),
    'brief-signal-S2-no-int': ('brief-signal-group-int', 'no-int'),
    'brief-signal-S4-remove-neighbor': ('brief-cleanup-neighbor', 'remove-neighbor'),
}
NEIGHBOR = b'foreign-file-must-survive\n'
# The CLI's marker follows its stderr write, before its bounded asynchronous wait.
# It is not the cleanup oracle: the oracle is the two directories after exit.
CLI = '''import fs from 'node:fs';
if (process.argv[2] !== 'brief') process.exit(43);
fs.writeSync(2, process.env.PROBE_FIRST + '\\nsecond-line\\n');
fs.writeFileSync(process.env.PROBE_READY, 'ready');
setTimeout(() => { fs.writeSync(1, process.env.PROBE_BODY); process.exit(0); },
           Number(process.env.PROBE_DELAY));
'''
CALL = '''ARCH187_LIB=1
source "$1" || exit 2
ARCH187_MODEL_DIR="$2"
if [ "$3" = managed ]; then ARCH187_MODEL_TMP="$2"; else unset ARCH187_MODEL_TMP; fi
trap 'arch187_cleanup' EXIT
if [ -n "$4" ]; then source "$4" || exit 2; fi
rc=0
out="$(arch187_brief api.identity 0)" || rc=$?
printf '%s' "$out"
exit "$rc"
'''
# Honest executable control and deceptive subjects use real bash/node/tempfiles.
# Only --model/--stabs source this override; --repo imports the actual library.
CONTROL = '''arch187_brief() (
  local errf out rc=0
  errf="$(mktemp)" || exit 2
  trap 'rm -f "$errf"' EXIT
  trap 'exit 143' TERM
  trap 'exit 130' INT
  out="$(cd "$ARCH187_MODEL_DIR" && node tooling/checks/cli.js brief --compact --component "$1" 2>"$errf")" || rc=$?
  if [ "$rc" -ne 0 ] || [ -z "$out" ]; then
    local first
    first="$(while IFS= read -r line; do [ -z "$line" ] || { printf '%s' "$line"; break; }; done < "$errf")"
    printf 'ARCH_BRIEF_STDERR: %s\\n' "${first:-(stderr модели пуст)}" >&2
    exit 1
  fi
  printf '%s\\n' "$out"
)
'''


def override(mutant):
    if mutant == 'normal-only':
        return CONTROL.replace("  trap 'rm -f \"$errf\"' EXIT\n", '').replace(
            "  trap 'exit 143' TERM\n", '').replace("  trap 'exit 130' INT\n", '').replace(
            "  printf '%s\\n' \"$out\"", "  rm -f \"$errf\"\n  printf '%s\\n' \"$out\"")
    if mutant == 'no-int':
        return CONTROL.replace("  trap 'exit 130' INT", "  trap 'trap - EXIT; exit 130' INT")
    if mutant == 'remove-neighbor':
        return CONTROL.replace("rm -f \"$errf\"", 'rm -f "$TMPDIR"/tmp.*')
    return CONTROL


def run_one(base, tools, case, managed, control=False, mutant=''):
    label, sig, group = case
    directory = base / (label + '-' + ('managed' if managed else 'borrowed') + '-' + (mutant or 'honest'))
    directory.mkdir()
    scratch = directory / 'tmp'
    scratch.mkdir()
    # Keep the borrowed tree outside both monitored cleanup locations.
    model = (scratch if managed else directory) / 'model'
    (model / 'tooling/checks').mkdir(parents=True)
    (model / 'tooling/checks/cli.js').write_text(CLI)
    (model / 'package.json').write_text('{"type":"module"}\n')
    neighbor = scratch / 'tmp.neighbor-187'
    neighbor.write_bytes(NEIGHBOR)
    marker = directory / 'model-ready'
    env = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
    env.update(TMPDIR=str(scratch), PROBE_READY=str(marker), PROBE_FIRST=FIRST.decode(),
               PROBE_BODY=BODY.decode(), PROBE_DELAY='1500' if sig else '0')
    subject = directory / 'control.sh'
    if control:
        subject.write_text(override(mutant))
    command = ['bash', '-c', CALL, 'signal-b5',
               str(tools / 'scripts/check_architecture_contract.sh'), str(model),
               'managed' if managed else 'borrowed', str(subject) if control else '']
    process = subprocess.Popen(command, cwd=directory, env=env, start_new_session=True,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    ready = False
    try:
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            if marker.exists():
                ready = True
                break
            if process.poll() is not None:
                break
            time.sleep(0.01)
        if ready and sig:
            if group:
                os.killpg(process.pid, sig)
            else:
                process.send_signal(sig)
        stdout, stderr = process.communicate(timeout=8)
    finally:
        # Bounded failure cleanup is not counted as success: observations below
        # follow the subject's natural termination, never this emergency SIGKILL.
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
            process.communicate()
    remaining = sorted(str(p.relative_to(scratch)) for p in scratch.rglob('*')
                       if p != neighbor)
    neighbor_ok = neighbor.is_file() and neighbor.read_bytes() == NEIGHBOR
    # A borrowed model is not owned by the door; a managed tree is.
    ok = ready and neighbor_ok and not remaining and (process.returncode != 0 if sig else process.returncode == 0)
    detail = (f'mode={"managed" if managed else "borrowed"} ready={ready} '
              f'caller_rc={process.returncode} leftover={remaining!r} '
              f'neighbor={neighbor_ok} stdout={stdout!r} stderr={stderr!r}')
    return ok, detail


def run_cases(base, tools, model_mode, stabs_mode):
    failures = []
    for case in CASES:
        label = case[0]
        results = [run_one(base, tools, case, managed, model_mode or stabs_mode)
                   for managed in (False, True)]
        ok = all(result[0] for result in results)
        print(f'{"GREEN" if ok else "RED"} {label}: ' + ' | '.join(r[1] for r in results))
        if not ok:
            failures.append(label)
        if stabs_mode:
            for name, (branch, mutant) in STABS.items():
                if branch != label:
                    continue
                # The borrowed-model variant exposes the defect without the
                # caller-owned model cleanup accidentally repairing the stub.
                survived, detail = run_one(base, tools, case, False, True, mutant)
                print(f'STAB {name} {"ZHIV" if survived else "caught"} @ {label}: {detail}')
                if survived:
                    failures.append(name)
    return failures


def main():
    import argparse
    import tempfile
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--control', action='store_true')
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='signal-187-') as temporary:
        failed = run_cases(Path(temporary), args.repo.resolve(), args.control, False)
    return int(bool(failed))


if __name__ == '__main__':
    raise SystemExit(main())
