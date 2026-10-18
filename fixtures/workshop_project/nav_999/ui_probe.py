#!/usr/bin/env python3
"""UI-примитивы и контейнеры 999 (CMP-MOB-002) на токенах D2.2.5.1.

Круг 3, решение арбитража 999 (К2/К3/К4.3): клетки порождаются декартовым
произведением закрытых перечней из source.json — Button {primary,
secondary} × {disabled false,true} × {dark,light} (8 клеток, BUTTON_DISABLED_STATE
растворён в них), Notice × {dark,light}, TextField {secure false,true} ×
{dark,light} (4 клетки, включая цвет/заливку самого TextInput). В каждой
клетке наблюдаются ВСЕ заявленные свойства. Контейнеры — композиция
3.1–3.3 (SHELL_CONTAINER_*: ближайший композит над хостом, контент внутри
обоих хостов, хосты шва внутри safe-area); акцент-гейт — обход всех
host-Text/TextInput (ACCENT_NOT_TEXT_*), не ручной список.
"""
import argparse
from pathlib import Path
import shutil
import sys
import tempfile

from probe_lib import HERE, installed, jest_ready, load_source, model_bytes, run_jest

FAMILY = 'ui'


def _schemes():
    return list(load_source()['modes']['colorScheme'])


def case_list():
    cases = []
    for scheme in _schemes():
        for variant in ('primary', 'secondary'):
            cases.append(f'BUTTON_{scheme.upper()}_{variant.upper()}')
            cases.append(f'BUTTON_{scheme.upper()}_{variant.upper()}_DISABLED')
    for scheme in _schemes():
        cases.append(f'NOTICE_{scheme.upper()}')
    for scheme in _schemes():
        for secure in (1, 0):
            cases.append(f'TEXTFIELD_{scheme.upper()}_SECURE_{secure}')
    cases += ['SHELL_CONTAINER_COMPOSITION', 'SHELL_CONTAINER_PROFILE',
              'ACCENT_NOT_TEXT_ON_LIGHT', 'ACCENT_NOT_TEXT_IN_DARK']
    return cases


CASES = case_list()

BUTTON = 'mobile/src/ui/button.tsx'
NOTICE = 'mobile/src/ui/notice.tsx'
TEXTFIELD = 'mobile/src/ui/text-field.tsx'
SHELL = 'mobile/src/bootstrap/tab-shell.tsx'

# Стаб↔ветвь (Н-39): named — клетка, где дефект стаба наблюдаем; depends —
# прочие клетки того же перечня, краснота которых объявлена (измерено).

def _cells(pred, skip_named):
    """depends-генератор по грамматике: клетки CASES, удовлетворяющие pred."""
    return tuple(cell for cell in CASES if pred(cell) and cell != skip_named)

MUTANTS = [
    ('button-no-role', 'BUTTON_DARK_PRIMARY', ((BUTTON, 'accessibilityRole="button"\n', ''),),
     tuple(c for c in CASES if c.startswith('BUTTON_') and c != 'BUTTON_DARK_PRIMARY')),
    ('button-accent-text', 'BUTTON_DARK_PRIMARY',
     ((BUTTON, "const labelColor = variant === 'primary' ? tokens['on-primary'] : tokens.ink;", 'const labelColor = tokens.accent;'),),
     tuple(c for c in CASES if c.startswith('BUTTON_') and c != 'BUTTON_DARK_PRIMARY')),
    ('button-variant-gaps', 'BUTTON_DARK_SECONDARY',
     ((BUTTON, 'onPress={onPress}', "onPress={((tokens.ground === '#0a0a0a') === (variant === 'primary')) ? onPress : undefined}"),),
     ('BUTTON_LIGHT_PRIMARY',)),
    ('notice-plain', 'NOTICE_DARK', ((NOTICE, 'accessibilityRole="alert"\n', ''),), ('NOTICE_LIGHT',)),
    ('notice-dark-role-missing', 'NOTICE_DARK',
     ((NOTICE, 'accessibilityRole="alert"', "accessibilityRole={tokens.ground === '#0a0a0a' ? undefined : 'alert'}"),), ()),
    ('textfield-no-label', 'TEXTFIELD_DARK_SECURE_1',
     ((TEXTFIELD, '<Text style={[styles.label, { color: tokens.ink }]}>{label}</Text>\n', ''),),
     ('TEXTFIELD_DARK_SECURE_0', 'TEXTFIELD_LIGHT_SECURE_1', 'TEXTFIELD_LIGHT_SECURE_0')),
    ('textfield-dark-secure', 'TEXTFIELD_DARK_SECURE_1',
     ((TEXTFIELD, 'secureTextEntry={secureTextEntry}', "secureTextEntry={tokens.ground === '#0a0a0a' ? false : secureTextEntry}"),), ()),
    ('no-keyboard-container', 'SHELL_CONTAINER_COMPOSITION', ((SHELL, 'testID="shell-keyboard-container"\n', ''),),
     ('SHELL_CONTAINER_PROFILE',)),
    ('safe-area-is-view', 'SHELL_CONTAINER_COMPOSITION',
     ((SHELL, "import { SafeAreaView } from 'react-native-safe-area-context';", 'const SafeAreaView = View;'),),
     ('SHELL_CONTAINER_PROFILE',)),
    ('keyboard-is-view', 'SHELL_CONTAINER_COMPOSITION',
     ((SHELL, "const openProfile = () => setRoute('profile');", 'const KeyboardAvoidingView = View;\n  const openProfile = () => setRoute(\'profile\');'),),
     ('SHELL_CONTAINER_PROFILE',)),
    ('lime-text-light', 'ACCENT_NOT_TEXT_ON_LIGHT',
     ((SHELL, "{ color: section === id ? tokens['on-card'] : tokens.ink }", '{ color: tokens.accent }'),),
     ('ACCENT_NOT_TEXT_IN_DARK',)),
    ('secondary-disabled-ignored', 'BUTTON_DARK_SECONDARY_DISABLED',
     (('mobile/src/ui/button.tsx', 'accessibilityState={{ disabled }}', "accessibilityState={{ disabled: disabled && variant === 'primary' }}"),
     ('mobile/src/ui/button.tsx', 'disabled={disabled}', "disabled={disabled && variant === 'primary'}"),),
     _cells(lambda c: c == 'BUTTON_LIGHT_SECONDARY_DISABLED', 'BUTTON_DARK_SECONDARY_DISABLED')),
    ('input-accent-text', 'TEXTFIELD_DARK_SECURE_1',
     (('mobile/src/ui/text-field.tsx', 'backgroundColor: tokens.panel, color: tokens.ink', 'backgroundColor: tokens.panel, color: tokens.accent'),),
     _cells(lambda c: c in ('TEXTFIELD_DARK_SECURE_0', 'TEXTFIELD_LIGHT_SECURE_1', 'TEXTFIELD_LIGHT_SECURE_0'), 'TEXTFIELD_DARK_SECURE_1')),
    ('textfield-always-secure', 'TEXTFIELD_DARK_SECURE_0',
     (('mobile/src/ui/text-field.tsx', 'secureTextEntry={secureTextEntry}', 'secureTextEntry={true}'),),
     _cells(lambda c: c == 'TEXTFIELD_LIGHT_SECURE_0', 'TEXTFIELD_DARK_SECURE_0')),
    ('containers-detached', 'SHELL_CONTAINER_COMPOSITION',
     (('mobile/src/bootstrap/tab-shell.tsx', '<SafeAreaView style=', '<View><SafeAreaView><View /></SafeAreaView><KeyboardAvoidingView><View /></KeyboardAvoidingView><View style='),
     ('mobile/src/bootstrap/tab-shell.tsx', '</SafeAreaView>\n    </ThemeContext.Provider>', '</View></View>\n    </ThemeContext.Provider>'),
     ('mobile/src/bootstrap/tab-shell.tsx', '<KeyboardAvoidingView\n', '<View\n'),
     ('mobile/src/bootstrap/tab-shell.tsx', '\n        </KeyboardAvoidingView>', '\n        </View>'),),
     _cells(lambda c: c == 'SHELL_CONTAINER_PROFILE', 'SHELL_CONTAINER_COMPOSITION')),
    ('tabbar-outside-safe-area', 'SHELL_CONTAINER_COMPOSITION',
     (('mobile/src/bootstrap/tab-shell.tsx', '</SafeAreaView>\n    </ThemeContext.Provider>', '</SafeAreaView>\n      {route === \'tabs\' ? <View accessibilityRole="tablist" style={[styles.tabbar, { backgroundColor: tokens.panel }]}>{TAB_ORDER.map((id) => (<Pressable accessibilityRole="tab" accessibilityState={{ selected: section === id }} key={id} onPress={() => setSection(id)} style={styles.tab} testID={`shell-tab-${id}`}><Text style={[styles.tabLabel, { color: section === id ? tokens[\'on-card\'] : tokens.ink }, section === id && styles.tabLabelSelected]}>{uiCopyDe[TAB_LABEL_KEYS[id]].text}</Text></Pressable>))}</View> : null}\n    </ThemeContext.Provider>'),
     ('mobile/src/bootstrap/tab-shell.tsx', '        {route === \'tabs\' ? (\n          <View accessibilityRole="tablist"', '        {false ? (\n          <View accessibilityRole="tablist"'),),
     ()),
    ('profile-not-in-keyboard-container', 'SHELL_CONTAINER_PROFILE',
     (('mobile/src/bootstrap/tab-shell.tsx', '          {route === \'profile\' ? (\n            <View style={styles.section} testID="profile-surface">', '          {false ? (\n            <View style={styles.section} testID="profile-surface">'),
     ('mobile/src/bootstrap/tab-shell.tsx', '        </KeyboardAvoidingView>\n', '        </KeyboardAvoidingView>\n        {route === \'profile\' ? (<View style={styles.section} testID="profile-surface"><Text accessibilityRole="header" style={[styles.title, { color: tokens.ink }]}>{uiCopyDe[\'action.F12.A01\'].text}</Text></View>) : null}\n'),),
     ()),
    ('nonstart-accent-title', 'ACCENT_NOT_TEXT_ON_LIGHT',
     (('mobile/src/bootstrap/tab-shell.tsx', 'style={[styles.title, { color: tokens.ink }]} testID={`section-title-${section}`}', "style={[styles.title, { color: section === 'start' ? tokens.ink : tokens.accent }]} testID={`section-title-${section}`}"),),
     _cells(lambda c: c == 'ACCENT_NOT_TEXT_IN_DARK', 'ACCENT_NOT_TEXT_ON_LIGHT')),
]


def check_repo(repo: Path):
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        raise RuntimeError('JEST_ABSENT: node_modules не установлен (npm ci)')
    return mobile


def run(repo: Path, case=None, model=False):
    mobile = check_repo(repo)
    blobs = model_bytes() if model else None
    workspace = Path(tempfile.mkdtemp(prefix='__ui999_', dir=mobile / 'src'))
    results = {}
    try:
        files = {workspace / 'ui.test.tsx': (HERE / 'ui.test.tsx').read_bytes(),
                 workspace / 'source.json': (HERE / 'source.json').read_bytes(),
                 workspace / 'surface_sweep.ts': (HERE / 'surface_sweep.ts').read_bytes()}
        if blobs:
            files.update({repo / t: b for t, b in blobs.items()})
        with installed(files):
            pattern = f'^999 {FAMILY} {case}$' if case else None
            got, proc = run_jest(mobile, workspace / 'ui.test.tsx', pattern)
            wanted = [case] if case else CASES
            missing = [name for name in wanted if name not in got]
            if missing:
                raise RuntimeError('ASSERTION_SET_MISSING:' + ','.join(missing) + ':' + proc.stderr[-800:])
            results = {title: status for title, status in got.items() if title in wanted}
            for name, status in sorted(results.items()):
                print(f'999 ui/{name}: {"rc=0" if status == "passed" else "rc=1"}', flush=True)
    finally:
        shutil.rmtree(workspace)
    return (0 if all(s == 'passed' for s in results.values()) else 1), results


def matrix(repo: Path):
    ok = True
    print('MATRIX honest:', flush=True)
    rc, _ = run(repo)
    ok &= rc == 0
    for name, case, patches, depends in MUTANTS:
        blobs = model_bytes(list(patches))
        mobile = check_repo(repo)
        workspace = Path(tempfile.mkdtemp(prefix='__ui999m_', dir=mobile / 'src'))
        try:
            files = {workspace / 'ui.test.tsx': (HERE / 'ui.test.tsx').read_bytes(),
                     workspace / 'source.json': (HERE / 'source.json').read_bytes(),
                     workspace / 'surface_sweep.ts': (HERE / 'surface_sweep.ts').read_bytes()}
            files.update({repo / t: b for t, b in blobs.items()})
            with installed(files):
                got, proc = run_jest(mobile, workspace / 'ui.test.tsx')
            named = case
            if named not in got:
                raise RuntimeError('MUTANT_CASE_MISSING:' + named)
            unexpected_red = [t for t, s in got.items() if s == 'failed' and t not in depends and t != named]
            depends_missed = [t for t in depends if got.get(t) != 'failed']
            verdict = got[named] == 'failed' and not unexpected_red and not depends_missed
            ok &= verdict
            print(f'MUTANT {name}: named={case} {"RED" if got[named] == "failed" else "GREEN"}'
                  f' depends_red={[t for t in depends if got.get(t) == "failed"] or "none"}'
                  f' unexpected_red={unexpected_red or "none"} -> {"OK" if verdict else "BROKEN"}', flush=True)
        finally:
            shutil.rmtree(workspace)
    return 0 if ok else 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', action='store_true')
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not (repo / 'mobile/src/ui/button.tsx').exists() and not args.model:
        print('999 UI_PRIMITIVES_ABSENT')
        return 1
    if args.matrix:
        return matrix(repo)
    rc, _ = run(repo, args.case, model=args.model)
    return rc


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError) as error:
        print('999 INFRASTRUCTURE:', error, file=sys.stderr)
        sys.exit(2)
