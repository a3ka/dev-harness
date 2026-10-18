#!/usr/bin/env python3
"""Навигационные пробы 999 (CMP-MOB-002): таблица переходов shell.

Клетки таблицы порождаются ПЕРЕБОРОМ по закрытому перечню вкладок
source.json (tabs_order): initialSection — по клетке на вкладку, deep link —
декартово произведение initial × return (включая диагональ), возврат из
профиля — по клетке на вкладку. Перечень клеток не выводится из списка
известных обходов (Н-324/Н-325).
"""
import argparse
from pathlib import Path
import shutil
import sys
import tempfile

from probe_lib import HERE, installed, jest_ready, load_source, model_bytes, run_jest

FAMILY = 'nav'
_STATIC = ['TABS_ORDER', 'TAB_LABELS_IA', 'PROFILE_SECONDARY_NOT_TAB', 'TAB_SWITCH_SELECTS_SECTION',
           'TAB_SWITCH_NO_COMMAND', 'REDUCED_MOTION_ACTIONS', 'SECTION_CONTENT_COPY', 'DEEPLINK_NO_RETURN']


def case_list():
    tabs = load_source()['tabs_order']
    cases = list(_STATIC)
    cases += [f'INITIAL_{tab.upper()}' for tab in tabs]
    cases += [f'DEEPLINK_RETURN_{a.upper()}_TO_{b.upper()}' for a in tabs for b in tabs]
    cases += [f'PROFILE_RETURN_{tab.upper()}' for tab in tabs]
    return cases


CASES = case_list()

TOKENS = 'mobile/src/theme/tokens.ts'
COPY = 'mobile/src/i18n/ui-copy.ts'
SHELL = 'mobile/src/bootstrap/tab-shell.tsx'
LABELS_BLOCK = """export const TAB_LABEL_KEYS: Readonly<Record<string, string>> = {
  start: 'ia115.nav.START',
  vorgaenge: 'ia117.nav.VORGAENGE',
  schutz: 'ia115.nav.SCHUTZ',
  post: 'ia115.nav.POST',
};"""
LABELS_MUTANT = """export const TAB_LABEL_KEYS: Readonly<Record<string, string>> = {
  start: 'frame.F04.01.title',
  vorgaenge: 'frame.F08.01.title',
  schutz: 'frame.F19.01.title',
  post: 'frame.F16.01.title',
};"""
TABLIST_CLOSE = """            ))}
          </View>"""
FIFTH_TAB = """            ))}
            <Pressable accessibilityRole="tab" onPress={() => setSection('start')} style={styles.tab} testID="shell-tab-profile">
              <Text style={styles.tabLabel}>{uiCopyDe['action.F12.A01'].text}</Text>
            </Pressable>
          </View>"""



def _deep_cells(skip_named):
    tabs = load_source()['tabs_order']
    return tuple(cell for cell in (f'DEEPLINK_RETURN_{a.upper()}_TO_{b.upper()}' for a in tabs for b in tabs)
                 if cell != skip_named)


# Стаб↔ветвь (Н-39): каждый стаб различим на своём входе; depends — клетки,
# чей собственный вход затрагивает ту же ветвь (законная зависимость
# таблицы переходов, объявлена явно); краснота ВНЕ named ∪ depends — дефект
# матрицы. Depends измерены прогоном полной матрицы, не выведены из прозы.
MUTANTS = [
    ('tab-order-shuffled', 'TABS_ORDER', (TOKENS, "['start', 'vorgaenge', 'schutz', 'post']", "['post', 'schutz', 'vorgaenge', 'start']"), ()),
    ('frame-title-labels', 'TAB_LABELS_IA', (COPY, LABELS_BLOCK, LABELS_MUTANT), ()),
    ('profile-as-fifth-tab', 'PROFILE_SECONDARY_NOT_TAB', (SHELL, TABLIST_CLOSE, FIFTH_TAB), ()),
    ('switch-stuck-selection', 'TAB_SWITCH_SELECTS_SECTION', (SHELL, 'onPress={() => setSection(id)}', "onPress={() => setSection('start')}"),
     ('REDUCED_MOTION_ACTIONS', 'SECTION_CONTENT_COPY', 'PROFILE_RETURN_VORGAENGE', 'PROFILE_RETURN_SCHUTZ', 'PROFILE_RETURN_POST')),
    ('tab-emit-command', 'TAB_SWITCH_NO_COMMAND', (SHELL, 'onPress={() => setSection(id)}', "onPress={() => { setSection(id); onCommand?.({ kind: 'mission.create' }); }}"), ()),
    ('deeplink-no-return', 'DEEPLINK_RETURN_SCHUTZ_TO_POST', (SHELL, 'useState<ShellSection | null>(returnSection)', 'useState<ShellSection | null>(null)'),
     _deep_cells('DEEPLINK_RETURN_SCHUTZ_TO_POST')),
    ('motion-removes-actions', 'REDUCED_MOTION_ACTIONS', (SHELL, 'style={styles.tab}', 'disabled={reducedMotion}\n                style={styles.tab}'), ()),
    ('section-copy-literal', 'SECTION_CONTENT_COPY', (SHELL, '{uiCopyDe[SECTION_TITLE_KEYS[section]].text}', "{'Vorgänge'}"), ()),
    # Обходы круга 1 критика, закрытые обобщёнными клетками перечня.
    ('start-never-selected', 'INITIAL_START', (SHELL, 'selected: section === id', "selected: id !== 'start' && section === id"),
     ('TAB_SWITCH_SELECTS_SECTION', 'DEEPLINK_RETURN_START_TO_VORGAENGE', 'DEEPLINK_RETURN_START_TO_SCHUTZ', 'DEEPLINK_RETURN_START_TO_POST', 'DEEPLINK_RETURN_START_TO_START', 'PROFILE_RETURN_START',
      'DEEPLINK_RETURN_VORGAENGE_TO_START', 'DEEPLINK_RETURN_SCHUTZ_TO_START', 'DEEPLINK_RETURN_POST_TO_START')),
    ('profile-loses-origin', 'PROFILE_RETURN_VORGAENGE', (SHELL, "const leaveProfile = () => setRoute('tabs');", "const leaveProfile = () => { setSection('start'); setRoute('tabs'); };"),
     ('PROFILE_RETURN_SCHUTZ', 'PROFILE_RETURN_POST')),
    ('initial-post-broken', 'INITIAL_POST', (SHELL, 'useState<ShellSection>(initialSection)', "useState<ShellSection>(initialSection === 'post' ? 'start' : initialSection)"),
     ('DEEPLINK_RETURN_POST_TO_START', 'DEEPLINK_RETURN_POST_TO_VORGAENGE', 'DEEPLINK_RETURN_POST_TO_SCHUTZ', 'DEEPLINK_RETURN_POST_TO_POST', 'DEEPLINK_NO_RETURN')),
    ('return-only-schutz', 'DEEPLINK_RETURN_START_TO_POST', (SHELL, 'useState<ShellSection | null>(returnSection)', "useState<ShellSection | null>(initialSection === 'schutz' ? returnSection : null)"),
     tuple(cell for cell in _deep_cells('DEEPLINK_RETURN_START_TO_POST') if not cell.startswith('DEEPLINK_RETURN_SCHUTZ'))),
]


def check_repo(repo: Path):
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        raise RuntimeError('JEST_ABSENT: node_modules не установлен (npm ci)')
    return mobile


def install_map(repo: Path, blobs):
    return {repo / target: blob for target, blob in blobs.items()}

def run(repo: Path, case=None, model=False):
    mobile = check_repo(repo)
    test_bytes = (HERE / 'nav.test.tsx').read_bytes()
    blobs = model_bytes() if model else None
    workspace = Path(tempfile.mkdtemp(prefix='__nav999_', dir=mobile / 'src'))
    results = {}
    try:
        files = {workspace / 'nav.test.tsx': test_bytes,
                 workspace / 'source.json': (HERE / 'source.json').read_bytes()}
        if blobs:
            files.update(install_map(repo, blobs))
        with installed(files):
            pattern = f'^999 {FAMILY} {case}$' if case else None
            got, proc = run_jest(mobile, workspace / 'nav.test.tsx', pattern)
            wanted = [case] if case else CASES
            missing = [name for name in wanted if name not in got]
            if missing:
                raise RuntimeError('ASSERTION_SET_MISSING:' + ','.join(missing) + ':' + proc.stderr[-800:])
            results = {title: status for title, status in got.items() if title in wanted}
            for name, status in sorted(results.items()):
                print(f'999 nav/{name}: {"rc=0" if status == "passed" else "rc=1"}', flush=True)
    finally:
        shutil.rmtree(workspace)
    return (0 if all(s == 'passed' for s in results.values()) else 1), results


def matrix(repo: Path):
    ok = True
    print('MATRIX honest: ', flush=True)
    rc, results = run(repo)
    ok &= rc == 0
    for name, case, mutation, depends in MUTANTS:
        blobs = model_bytes([mutation])
        mobile = check_repo(repo)
        test_bytes = (HERE / 'nav.test.tsx').read_bytes()
        workspace = Path(tempfile.mkdtemp(prefix='__nav999m_', dir=mobile / 'src'))
        try:
            files = {workspace / 'nav.test.tsx': test_bytes,
                     workspace / 'source.json': (HERE / 'source.json').read_bytes()}
            files.update(install_map(repo, blobs))
            with installed(files):
                got, proc = run_jest(mobile, workspace / 'nav.test.tsx')
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
    if not (repo / 'mobile/src/bootstrap/tab-shell.tsx').exists() and not args.model:
        print('999 NAV_SHELL_ABSENT')
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
