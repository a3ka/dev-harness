#!/usr/bin/env python3
"""Public check_sud_model CLI: bound-trace model identity and deceptive implementations."""
import argparse
import json
import secrets
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
BASE = "frozen/contracts/104/2:scripts/check_sud_model.sh"
FUNCTION = '''# Same identifier with or without its provider; two explicit providers must agree.
model_equivalent() {
  local a="$1" b="$2"
  if [[ "$a" == */* && "$b" == */* ]]; then
    [ "$a" = "$b" ]
  elif [[ "$a" == */* ]]; then
    [ "${a#*/}" = "$b" ]
  elif [[ "$b" == */* ]]; then
    [ "$a" = "${b#*/}" ]
  else
    [ "$a" = "$b" ]
  fi
}
'''


def replace_once(source, before, after):
    count = source.count(before)
    if count != 1:
        raise ValueError(f"mutation anchor count {count}: {before[:75]!r}")
    return source.replace(before, after)


def honest_source(base):
    source = replace_once(base, 'mode=""\nrole=""', FUNCTION + '\nmode=""\nrole=""')
    for old, new in (('[ "$model" != "$expected" ]', '! model_equivalent "$model" "$expected"'),
                     ('[ "$m" != "$expected" ]', '! model_equivalent "$m" "$expected"'),
                     ('[ "$m" != "$fbexpected" ]', '! model_equivalent "$m" "$fbexpected"')):
        source = replace_once(source, old, new)
    return source


def run(subject, cfg, trace, mode, role, model=None):
    args = ['bash', str(subject), mode, role]
    if mode == '--spawn':
        args.append(model)
    else:
        args += ['--trace', str(trace), '--object', 'a' * 40, '--session', 'Judge173']
    args += ['--root', str(cfg)]
    return subprocess.run(args, capture_output=True, text=True, timeout=10)


def check(subject, cfg, trace, label, mode, role, model, trace_model, flag, expect_rc, reason):
    if mode == '--verdict':
        trace.write_text(f'{role}\t{trace_model}\t{flag}\tJudge173\t{"a" * 40}\n')
    proc = run(subject, cfg, trace, mode, role, model)
    ok = (proc.returncode == expect_rc and
          ((proc.stderr == '' and proc.stdout.splitlines() == [reason]) if expect_rc == 0
           else (proc.stdout == '' and proc.stderr.splitlines() == [reason])))
    print(f'173 {label} {"ok" if ok else "KRASNO"} rc={proc.returncode} stderr={proc.stderr.strip()!r}', flush=True)
    return ok


def cases(subject, cfg, trace):
    # Independent literal oracle, held before invoking the subject; the subject never owns these bytes.
    good_spawn_opus = 'СУДЬЯ СВОЕЙ МОДЕЛИ: reviewer тир audit модель claude-opus-5-5'
    good_spawn_full = 'СУДЬЯ СВОЕЙ МОДЕЛИ: reviewer тир audit модель anthropic/claude-opus-5-5'
    good_spawn_glm = 'СУДЬЯ СВОЕЙ МОДЕЛИ: critic тир apex-sol модель glm-5.3'
    good_verdict_reviewer = 'СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется'
    good_verdict_critic = 'СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется'
    fail_spawn = 'ОТКАЗ: модель не тира роли: reviewer тир audit спавн claude-opus-5-4'
    fail_primary = 'ОТКАЗ: вердикт не материализуется: судья reviewer на модели evil/claude-opus-5-5, тир audit (Н-270)'
    fail_suffix = 'ОТКАЗ: вердикт не материализуется: судья reviewer на модели claude-opus-5-5-extra, тир audit (Н-270)'
    fail_fallback = 'ОТКАЗ: фолбэк вне списка тира: reviewer на alien/gpt-6-sol, тир audit (Н-270)'
    tests = [
        ('spawn_bare_opus', '--spawn', 'reviewer', 'claude-opus-5-5', None, None, 0, good_spawn_opus),
        ('spawn_full_primary', '--spawn', 'reviewer', 'anthropic/claude-opus-5-5', None, None, 0, good_spawn_full),
        ('spawn_bare_glm', '--spawn', 'critic', 'glm-5.3', None, None, 0, good_spawn_glm),
        ('spawn_wrong_version', '--spawn', 'reviewer', 'claude-opus-5-4', None, None, 1, fail_spawn),
        ('verdict_bare_primary', '--verdict', 'reviewer', None, 'claude-opus-5-5', 'allowed', 0, good_verdict_reviewer),
        ('verdict_full_primary', '--verdict', 'reviewer', None, 'anthropic/claude-opus-5-5', 'allowed', 0, good_verdict_reviewer),
        ('verdict_bare_fallback', '--verdict', 'reviewer', None, 'gpt-6-sol', 'denied', 0, good_verdict_reviewer),
        ('verdict_bare_glm', '--verdict', 'critic', None, 'glm-5.3', 'allowed', 0, good_verdict_critic),
        ('verdict_foreign_provider', '--verdict', 'reviewer', None, 'evil/claude-opus-5-5', 'allowed', 1, fail_primary),
        ('verdict_suffix_extra', '--verdict', 'reviewer', None, 'claude-opus-5-5-extra', 'allowed', 1, fail_suffix),
        ('fallback_foreign_provider', '--verdict', 'reviewer', None, 'alien/gpt-6-sol', 'denied', 1, fail_fallback),
    ]
    results = {label: check(subject, cfg, trace, label, mode, role, model, tr_model, flag, rc, reason)
               for label, mode, role, model, tr_model, flag, rc, reason in tests}
    # The second conforming identity changes every run. Keep expected bytes in memory
    # before the subject call; neither model name nor oracle comes from the subject's disk.
    config_file = cfg / 'config/agent_models.json'
    original = config_file.read_text()
    random_bare = 'claude-opus-5-5-r' + secrets.token_hex(6)
    changed = json.loads(original)
    changed['models']['opus'] = 'anthropic/' + random_bare
    config_file.write_text(json.dumps(changed))
    try:
        results['dynamic_bare_opus'] = check(
            subject, cfg, trace, 'dynamic_bare_opus', '--spawn', 'reviewer',
            random_bare, None, None, 0,
            'СУДЬЯ СВОЕЙ МОДЕЛИ: reviewer тир audit модель ' + random_bare)
    finally:
        config_file.write_text(original)
    return results


def main():
    arg = argparse.ArgumentParser()
    modes = arg.add_mutually_exclusive_group(required=True)
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    options = arg.parse_args()
    base = subprocess.run(['git', '-C', str(ROOT), 'show', BASE], check=True,
                          capture_output=True, text=True).stdout
    honest = honest_source(base)
    with tempfile.TemporaryDirectory(prefix='sud-model-173-') as tmp:
        world = Path(tmp)
        cfg = world / 'repo'
        (cfg / 'config').mkdir(parents=True)
        # Registry structure is reused, with fixed roles/tiers/models so future routing changes
        # cannot silently change the oracle. No fixture writes the checkout or its model registry.
        registry = json.loads((ROOT / 'config/agent_models.json').read_text())
        registry['roles'] = {'reviewer': 'audit', 'critic': 'apex-sol'}
        registry['tiers'] = {'audit': {'model': '@opus', 'fallback': '@gpt-sol'},
                             'apex-sol': {'model': '@glm', 'fallback': '@gpt-terra'}}
        registry['models'] = {'opus': 'anthropic/claude-opus-5-5', 'gpt-sol': 'openai-codex/gpt-6-sol',
                              'glm': 'zai/glm-5.3', 'gpt-terra': 'openai-codex/gpt-5.6-terra'}
        (cfg / 'config/agent_models.json').write_text(json.dumps(registry))
        trace = world / 'bound.tsv'
        subject = world / 'honest.sh'
        subject.write_text(honest)
        if options.repo:
            repo_subject = options.repo.resolve() / 'scripts/check_sud_model.sh'
            if not repo_subject.is_file():
                print('173 SUBJECT_ABSENT', file=sys.stderr)
                return 2
            return 0 if all(cases(repo_subject, cfg, trace).values()) else 1
        control = cases(subject, cfg, trace)
        if not all(control.values()):
            print('173 CONTROL_INVALID', file=sys.stderr)
            return 2
        if options.model:
            return 0
        impostors = [
            ('literal_only', replace_once(honest, FUNCTION, 'model_equivalent() { [ "$1" = "$2" ]; }\n'), 'spawn_bare_opus'),
            ('strip_any_provider', replace_once(honest, '  if [[ "$a" == */* && "$b" == */* ]]; then\n    [ "$a" = "$b" ]', '  if [[ "$a" == */* && "$b" == */* ]]; then\n    [ "${a#*/}" = "${b#*/}" ]'), 'verdict_foreign_provider'),
            ('accept_suffix', replace_once(honest, '    [ "$a" = "${b#*/}" ]', '    [[ "$a" == "${b#*/}"* ]]'), 'verdict_suffix_extra'),
            ('spawn_raw', replace_once(honest, 'if ! model_equivalent "$model" "$expected"; then', 'if [ "$model" != "$expected" ]; then'), 'spawn_bare_glm'),
            ('verdict_raw', replace_once(honest, 'if ! model_equivalent "$m" "$expected"; then', 'if [ "$m" != "$expected" ]; then'), 'verdict_bare_primary'),
            ('fallback_raw', replace_once(honest, '! model_equivalent "$m" "$fbexpected"', '[ "$m" != "$fbexpected" ]'), 'verdict_bare_fallback'),
            ('opus_only', replace_once(honest, '    [ "$a" = "${b#*/}" ]', '    [ "$a" = "claude-opus-5-5" ] || [ "$a" = "$b" ]'), 'dynamic_bare_opus'),
        ]
        failures = 0
        for name, source, witness in impostors:
            subject.write_text(source)
            observed = cases(subject, cfg, trace)[witness]
            print(f'173 STAB {name} {"ZHIV" if observed else "caught"} @ {witness}', flush=True)
            failures += observed
        return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
