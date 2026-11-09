#!/usr/bin/env python3
"""174: public CLI, frozen-source honest control, and per-branch impostors."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
VERIFY = Path('/tmp/dev-harness-verify')
GOOD = 'Alpha_174'
OTHER = 'Beta-174'
BAD = 'Arbiter079Б1'
MODEL_GOOD = 'openai-codex/gpt-6-sol'
MODEL_OTHER = 'anthropic/claude-sonnet-5-5'
BAD_ERROR = f'NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: {BAD}'
MISSING_ERROR = 'NOT_IMPLEMENTED: сессия не найдена: Missing174'


def replace_one(source, old, new):
    n = source.count(old)
    if n != 1:
        raise ValueError(f'mutation anchor occurs {n} times: {old[:90]!r}')
    return source.replace(old, new)


def fixture(zone):
    # Explicit mtime makes ordering deterministic. Session oracle lives in memory.
    rows = ((GOOD, MODEL_GOOD, 1700000000), (OTHER, MODEL_OTHER, 1700000100),
            (BAD, 'zai/glm-5.3', 1700000200))
    for name, model, timestamp in rows:
        f = zone / (name + '.jsonl')
        f.write_text('{"agent":"architect","type":"model_change","model":"' + model
                     + '","resolvedModelIsFallback":false}\n')
        if name == GOOD:
            with f.open('a') as stream:
                stream.write('{"agent":"architect","type":"model_change","model":"'
                             + MODEL_GOOD + '","resolvedModelIsFallback":true}\n')
        os.utime(f, (timestamp, timestamp))
    return {f.name: f.read_bytes() for f in zone.iterdir()}


def call(subject, zone, *args):
    env = dict(os.environ, HARNESS_SESSION_HOME=str(zone))
    return subprocess.run(['bash', str(subject), *args], env=env, text=True,
                          capture_output=True, timeout=20)


def verdict(name, got, rc, stdout=None, stderr=''):
    ok = got.returncode == rc and got.stderr == stderr and (stdout is None or got.stdout == stdout)
    print(f"174 {name} {'ok' if ok else 'KRASNO'} rc={got.returncode} stdout={got.stdout!r} stderr={got.stderr!r}")
    return ok


def cells(subject, zone, oracle):
    good3 = (f'architect\t{MODEL_GOOD}\tallowed\n'
             f'architect\t{MODEL_GOOD}\tdenied\n')
    other3 = f'architect\t{MODEL_OTHER}\tallowed\n'
    good5 = (f'architect\t{MODEL_GOOD}\tallowed\t{GOOD}\t-\n'
             f'architect\t{MODEL_GOOD}\tdenied\t{GOOD}\t-\n')
    rows = {}
    rows['legacy_tsv'] = verdict('legacy_tsv', call(subject, zone, '--tsv'), 0,
                                 'architect\tzai/glm-5.3\tallowed\n' + other3 + good3)
    rows['legacy_bind_invalid'] = verdict('legacy_bind_invalid', call(subject, zone, '--tsv', '--bind'),
                                          2, '', BAD_ERROR + '\n')
    rows['selected_tsv'] = verdict('selected_tsv', call(subject, zone, '--tsv', '--session', GOOD), 0, good3)
    rows['selected_bind'] = verdict('selected_bind', call(subject, zone, '--tsv', '--bind', '--session', GOOD),
                                    0, good5)
    rows['selected_bind_alias'] = verdict('selected_bind_alias', call(subject, zone, '--bind', '--session', GOOD),
                                          0, good5)
    rows['selected_human'] = human('selected_human', call(subject, zone, '--session', GOOD))
    rows['selected_human_all'] = human('selected_human_all', call(subject, zone, '--all', '--session', GOOD), all_mode=True)
    rows['exact_id'] = verdict('exact_id', call(subject, zone, '--tsv', '--session', 'Alpha'),
                               2, '', 'NOT_IMPLEMENTED: сессия не найдена: Alpha\n')
    rows['missing_id'] = verdict('missing_id', call(subject, zone, '--tsv', '--session', 'Missing174'),
                                 2, '', MISSING_ERROR + '\n')
    rows['invalid_id'] = verdict('invalid_id', call(subject, zone, '--tsv', '--session', BAD),
                                 2, '', BAD_ERROR + '\n')
    rows['missing_argument'] = verdict('missing_argument', call(subject, zone, '--session'), 2,
                                       '', 'NOT_IMPLEMENTED: --session требует ID\n')
    rows['oracle'] = all((zone / name).is_file() and (zone / name).read_bytes() == data
                         for name, data in oracle.items())
    print(f"174 oracle {'ok' if rows['oracle'] else 'KRASNO'}")
    return rows


def human(label, result, all_mode=False):
    lines = result.stdout.splitlines()
    ok = (result.returncode == 1 and result.stderr == '' and
          'сессий показано: 1 · гейт по ПОСЛЕДНЕЙ: РАСХОЖДЕНИЕ' in lines and
          len([line for line in lines if 'делегировано ' in line]) == 1 and
          MODEL_GOOD in result.stdout and MODEL_OTHER not in result.stdout and
          ('знаки: ok совпало' in result.stdout) == all_mode)
    print(f"174 {label} {'ok' if ok else 'KRASNO'} rc={result.returncode} stdout={result.stdout!r} stderr={result.stderr!r}")
    return ok


# Honest model starts with the pinned pre-174 baseline, even after implementer
# commits. All changes use unique code anchors, never a mock echo.
SOURCE = subprocess.run(['git', '-C', str(ROOT), 'show',
                         'c3ccbcc8fc49cc4dabb24406237dd29e1ecf5adc:scripts/models_actual.sh'],
                        capture_output=True, check=True, text=True).stdout
PARSE = '''    --session) [ "$#" -ge 2 ] && [ -n "$2" ] || { printf 'NOT_IMPLEMENTED: --session требует ID\\n' >&2; exit 2; }
               SESSION_ID="$2"; shift ;;'''
VALIDATE = '''if [ -n "$SESSION_ID" ]; then
  case "$SESSION_ID" in *[!A-Za-z0-9._-]*)
    printf 'NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: %s\\n' "$SESSION_ID" >&2; exit 2 ;;
  esac
fi
'''
FILTER_TSV = '''  if [ -n "$SESSION_ID" ]; then
    _filtered=()
    for _f in "${_tsv_traces[@]}"; do
      [ "$(basename "$_f" .jsonl)" = "$SESSION_ID" ] && _filtered+=("$_f")
    done
    _tsv_traces=("${_filtered[@]}")
    [ "${#_tsv_traces[@]}" -gt 0 ] || { printf 'NOT_IMPLEMENTED: сессия не найдена: %s\\n' "$SESSION_ID" >&2; exit 2; }
  fi
'''
FILTER_HUMAN = '''if [ -n "$SESSION_ID" ]; then
  _filtered=()
  for _f in "${traces[@]}"; do
    [ "$(basename "$_f" .jsonl)" = "$SESSION_ID" ] && _filtered+=("$_f")
  done
  traces=("${_filtered[@]}")
  [ "${#traces[@]}" -gt 0 ] || { printf 'NOT_IMPLEMENTED: сессия не найдена: %s\\n' "$SESSION_ID" >&2; exit 2; }
fi
'''


def honest_source():
    src = replace_one(SOURCE, 'BIND=0\nwhile [ "$#" -gt 0 ]; do',
                      'BIND=0\nSESSION_ID=""\nwhile [ "$#" -gt 0 ]; do')
    src = replace_one(src, '    --bind) TSV=1; BIND=1 ;;',
                      '    --bind) TSV=1; BIND=1 ;;\n' + PARSE)
    src = replace_one(src, '  shift\ndone\n\n# `--tsv`', '  shift\ndone\n\n' + VALIDATE + '\n# `--tsv`')
    src = replace_one(src, '  [ "${#_tsv_traces[@]}" -gt 0 ] ||', FILTER_TSV + '  [ "${#_tsv_traces[@]}" -gt 0 ] ||')
    src = replace_one(src, '[ "${#traces[@]}" -gt 0 ] ||', FILTER_HUMAN + '[ "${#traces[@]}" -gt 0 ] ||')
    return src


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--repo', action='store_true')
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    VERIFY.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='models-actual-174-', dir=VERIFY) as tmp:
        world = Path(tmp)
        zone = world / 'zone'
        zone.mkdir()
        oracle = fixture(zone)
        scripts = world / 'scripts'
        scripts.mkdir()
        (world / '.omp').symlink_to(ROOT / '.omp', target_is_directory=True)
        subject = ROOT / 'scripts/models_actual.sh'
        if args.repo:
            return 0 if all(cells(subject, zone, oracle).values()) else 1
        model = scripts / 'honest.sh'
        model.write_text(honest_source())
        control = cells(model, zone, oracle)
        if not all(control.values()):
            print('174 CONTROL_INVALID', file=sys.stderr)
            return 2
        if args.model:
            return 0
        mutations = [
            ('ignore_tsv_filter', FILTER_TSV, '', 'selected_tsv'),
            ('filter_after_bind', FILTER_TSV, '', 'selected_bind'),
            ('ignore_human_filter', FILTER_HUMAN, '', 'selected_human'),
            ('substring_selection', '[ "$(basename "$_f" .jsonl)" = "$SESSION_ID" ]',
             '[[ "$(basename "$_f" .jsonl)" == *"$SESSION_ID"* ]]', 'exact_id'),
            ('no_missing_diagnosis', 'сессия не найдена: %s',
             'трейсов в зоне нет: %s', 'missing_id'),
            ('allow_invalid_argument', VALIDATE, '', 'invalid_id'),
            ('legacy_skip_bad', 'if [ "$BIND" = "1" ]; then\n      _session=',
             'if [ "$BIND" = "1" ]; then\n      case "$(basename "$f" .jsonl)" in *[!A-Za-z0-9._-]*) continue;; esac\n      _session=', 'legacy_bind_invalid'),
        ]
        failed = False
        for name, old, new, branch in mutations:
            # Two identical filter comparisons/diagnoses exist in the honest source;
            # mutate the appropriate one explicitly, preserving the other branch.
            if name in ('substring_selection', 'no_missing_diagnosis'):
                source = model.read_text()
                start = source.index('  if [ -n "$SESSION_ID" ]; then\n    _filtered=()')
                stop = source.index('  [ "${#_tsv_traces[@]}" -gt 0 ] || { printf \'NOT_IMPLEMENTED: трейсов', start)
                fragment = source[start:stop]
                if fragment.count(old) != 1:
                    raise ValueError(f'{name} not unique in TSV branch')
                text = source[:start] + fragment.replace(old, new) + source[stop:]
            else:
                text = replace_one(model.read_text(), old, new)
            imposter = scripts / (name + '.sh')
            imposter.write_text(text)
            result = cells(imposter, zone, oracle)
            caught = not result[branch]
            print(f"174 STAB {name} {'caught' if caught else 'ZHIV'} @ {branch}")
            failed |= not caught
        return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
