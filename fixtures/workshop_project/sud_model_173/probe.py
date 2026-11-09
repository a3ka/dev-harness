#!/usr/bin/env python3
"""173: independent public-door checks and single-defect copies of the pinned 104 subject."""
import json
from pathlib import Path
import secrets
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PIN = 'frozen/contracts/104/2:scripts/check_sud_model.sh'
OBJECT = 'a' * 40
SESSION = 'Sud173_A'

# The honest candidate is constructed ONLY from the pinned subject, never from
# the working tree. Substitutions fail closed if 104/2 does not match this shape.
COMPARISONS = (
    ('if [ "$model" != "$expected" ]; then', 'if ! same_model "$model" "$expected"; then'),
    ('if [ "$m" != "$expected" ]; then', 'if ! same_model "$m" "$expected"; then'),
    ('if [ -z "$fbexpected" ] || [ "$m" != "$fbexpected" ]; then',
     'if [ -z "$fbexpected" ] || ! same_model "$m" "$fbexpected"; then'),
)
HELPER = '''same_model() {
  [ "$1" = "$2" ] && return 0
  case "$1" in
    */*) case "$2" in */*) return 1 ;; *) [ "${1#*/}" = "$2" ] ;; esac ;;
    *) case "$2" in */*) [ "$1" = "${2#*/}" ] ;; *) return 1 ;; esac ;;
  esac
}

'''


def pinned_candidate():
    got = subprocess.run(['git', '-C', str(ROOT), 'show', PIN], text=True,
                         capture_output=True, check=True).stdout
    for original, replacement in COMPARISONS:
        if got.count(original) != 1:
            raise RuntimeError('pinned 104/2 comparison not unique: ' + original)
        got = got.replace(original, replacement, 1)
    if got.count('case "$mode" in') != 1:
        raise RuntimeError('pinned 104/2 mode dispatch not unique')
    return got.replace('case "$mode" in', HELPER + 'case "$mode" in', 1)


class World:
    def __init__(self, base):
        self.base = base
        self.script = base / 'subject.sh'
        self.root = base / 'toy'
        (self.root / 'config').mkdir(parents=True)
        self.models = {'opus': 'anthropic/claude-opus-5-5',
                       'sol': 'openai-codex/gpt-6-sol', 'glm': 'zai/glm-5.3'}
        self.config = {'roles': {'reviewer': 'audit', 'critic': 'apex'},
                       'tiers': {'audit': {'model': '@opus', 'fallback': '@sol'},
                                 'apex': {'model': '@glm', 'fallback': None}},
                       'models': self.models}
        self.save_config()

    def save_config(self):
        (self.root / 'config/agent_models.json').write_text(json.dumps(self.config), encoding='utf-8')

    def case(self, label, role, model, flag=None, success=True, dynamic=False):
        original = self.models['opus']
        if dynamic:
            # A conformant, unguessable provider/model pair changes on every run.
            self.models['opus'] = 'anthropic/claude-opus-' + secrets.token_hex(6)
            self.save_config()
            model = self.models['opus'].split('/', 1)[1]
        tier = self.config['roles'][role]
        expected = self.models['opus' if role == 'reviewer' else 'glm']
        if flag is None:
            argv = ['bash', str(self.script), '--spawn', role, model,
                    '--root', str(self.root)]
            if success:
                want_err = ''
                want_out = f'СУДЬЯ СВОЕЙ МОДЕЛИ: {role} тир {tier} модель {model}\n'
            else:
                want_err = f'ОТКАЗ: модель не тира роли: {role} тир {tier} спавн {model}\n'
                want_out = ''
        else:
            trace = self.base / 'trace.tsv'
            trace.write_text(f'{role}\t{model}\t{flag}\t{SESSION}\t{OBJECT}\n', encoding='utf-8')
            argv = ['bash', str(self.script), '--verdict', role, '--trace', str(trace),
                    '--object', OBJECT, '--session', SESSION, '--root', str(self.root)]
            if success:
                want_err = ''
                want_out = f'СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт {role} материализуется\n'
            elif flag == 'allowed':
                want_err = (f'ОТКАЗ: вердикт не материализуется: судья {role} '
                            f'на модели {model}, тир {tier} (Н-270)\n')
                want_out = ''
            else:
                want_err = f'ОТКАЗ: фолбэк вне списка тира: {role} на {model}, тир {tier} (Н-270)\n'
                want_out = ''
        # The oracle above lives in memory before invoking the subject. Disk is
        # input only: never read back its config/trace as an expected value.
        got = subprocess.run(argv, text=True, capture_output=True, check=False)
        if dynamic:
            self.models['opus'] = original
            self.save_config()
        want_rc = 0 if success else 1
        if (got.returncode, got.stdout, got.stderr) != (want_rc, want_out, want_err):
            print(f'173 {label} KRASNO: rc={got.returncode} stdout={got.stdout!r} '
                  f'stderr={got.stderr!r}; expected rc={want_rc} stdout={want_out!r} '
                  f'stderr={want_err!r}')
            return False
        print(f'173 {label} ZELENO')
        return True


# name -> role, model, bind flag, success, random provider/model pair.
CASES = {
    'spawn_bare_opus': ('reviewer', 'claude-opus-5-5', None, True, False),
    'spawn_bare_glm': ('critic', 'glm-5.3', None, True, False),
    'verdict_bare_primary': ('reviewer', 'claude-opus-5-5', 'allowed', True, False),
    'verdict_bare_fallback': ('reviewer', 'gpt-6-sol', 'denied', True, False),
    'verdict_bare_glm': ('critic', 'glm-5.3', 'allowed', True, False),
    'dynamic_bare_opus': ('reviewer', None, None, True, True),
    'spawn_prefixed': ('reviewer', 'anthropic/claude-opus-5-5', None, True, False),
    'verdict_prefixed': ('reviewer', 'anthropic/claude-opus-5-5', 'allowed', True, False),
    'fallback_prefixed': ('reviewer', 'openai-codex/gpt-6-sol', 'denied', True, False),
    'spawn_wrong_version': ('reviewer', 'claude-opus-5-6', None, False, False),
    'spawn_foreign_provider': ('reviewer', 'evil/claude-opus-5-5', None, False, False),
    'verdict_wrong_version': ('reviewer', 'claude-opus-5-6', 'allowed', False, False),
    'verdict_foreign_provider': ('reviewer', 'evil/claude-opus-5-5', 'allowed', False, False),
    'fallback_wrong_version': ('reviewer', 'gpt-6-terra', 'denied', False, False),
    'fallback_foreign_provider': ('reviewer', 'evil/gpt-6-sol', 'denied', False, False),
}

# Mutation site -> observed public input. A POST-only failure is never claimed
# on a spawn input: each mutant must differ on precisely its named branch.
STABS = {
    'spawn_exact': (COMPARISONS[0][1], COMPARISONS[0][0], 'spawn_bare_opus'),
    'primary_exact': (COMPARISONS[1][1], COMPARISONS[1][0], 'verdict_bare_primary'),
    'fallback_exact': (COMPARISONS[2][1], COMPARISONS[2][0], 'verdict_bare_fallback'),
    'spawn_any_provider': (COMPARISONS[0][1], 'if ! [ "${model#*/}" = "${expected#*/}" ]; then',
                           'spawn_foreign_provider'),
    'primary_any_provider': (COMPARISONS[1][1], 'if ! [ "${m#*/}" = "${expected#*/}" ]; then',
                             'verdict_foreign_provider'),
    'fallback_any_provider': (COMPARISONS[2][1],
                              'if [ -z "$fbexpected" ] || ! [ "${m#*/}" = "${fbexpected#*/}" ]; then',
                              'fallback_foreign_provider'),
}


def main(mode):
    errors = 0
    with tempfile.TemporaryDirectory(prefix='sud-model-173-') as scratch:
        world = World(Path(scratch))
        if mode == '--repo':
            world.script = ROOT / 'scripts/check_sud_model.sh'
            for label, args in CASES.items():
                errors += not world.case(label, *args)
        else:
            honest = pinned_candidate()
            if mode == '--model':
                world.script.write_text(honest, encoding='utf-8')
                for label, args in CASES.items():
                    errors += not world.case(label, *args)
            else:
                for name, (site, defect, label) in STABS.items():
                    if honest.count(site) != 1:
                        raise RuntimeError('mutation site not unique: ' + name)
                    args = CASES[label]
                    world.script.write_text(honest, encoding='utf-8')
                    # Control must pass on THIS input before infecting the copy.
                    if not world.case('control_' + name, *args):
                        errors += 1
                        continue
                    world.script.write_text(honest.replace(site, defect, 1), encoding='utf-8')
                    if world.case('mutant_' + name, *args):
                        print('STAB ' + name + ' ZHIV: ' + label)
                        errors += 1
                    else:
                        print('STAB ' + name + ' caught: ' + label)
    return 1 if errors else 0


if __name__ == '__main__':
    if len(sys.argv) != 2 or sys.argv[1] not in ('--repo', '--model', '--stabs'):
        sys.exit('usage: probe.py --repo|--model|--stabs')
    try:
        sys.exit(main(sys.argv[1]))
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print('NOT_IMPLEMENTED: fixture prerequisite: ' + str(exc), file=sys.stderr)
        sys.exit(2)
