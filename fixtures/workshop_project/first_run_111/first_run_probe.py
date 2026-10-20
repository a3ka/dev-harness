#!/usr/bin/env python3
"""Поведенческая проба 111 (CMP-MOB-005): First-Run по D2.2.5.1.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево — именованный отказ rc1 FIRST_RUN_SEAM_ABSENT.
С --model: эталон architect ставится по путям поставки, rc0 с перечнем.
--matrix: каждый обманный стаб даёт красноту на объявленных ветвях
(named ∪ depends); краснота вне объявления — дефект матрицы rc2.
Выход — только код возврата; список case печатается построчно.
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    FAMILY_PREFIX, HERE, SCREEN_PATH, TEST_INSTALL,
    installed, jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'FIRST_RUN_SEAM_ABSENT'

# Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends).
# depends измерены полным прогоном до записи (см. §Фактический замер контракта).
MUTANTS = {
    'cta-label-weiter': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          "label={uiCopyDe['ui.first_run.enter_f03'].text}",
          "label={'Weiter'}")],
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'],
        ['CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_COPY_CLOSED_DARK',
         'FIRST_RUN_COPY_CLOSED_LIGHT'],
    ),
    'promise-invented': (
        [('mobile/src/i18n/ui-copy.ts',
          "'ui.first_run.promise': { text: 'Sie sagen, was passiert ist. Complior kümmert sich um den Rest.',",
          "'ui.first_run.promise': { text: 'Sie sagen, was passiert ist.',")],
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'],
    ),
    'onenter-not-wired': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'onPress={onEnter}', 'onPress={() => {}}')],
        ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT'],
        ['CTA_TEXT_EQUALS_FRAME_TITLE'],
    ),
    'ground-default-blue': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'backgroundColor: tokens.ground', "backgroundColor: '#208AEF'")],
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'], [],
    ),
    'demo-badge-scope': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "{frame !== 'welcome' ? (",
          "{frame !== 'welcome' && frame !== 'first-run' ? (")],
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'], [],
    ),
    'wordmark-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Image\n'
          '        accessibilityLabel="complior"\n'
          '        accessibilityRole="image"\n'
          "        source={require('../../../assets/images/wordmark-dark.png')}\n"
          '        style={styles.wordmark}\n'
          '        testID="first-run-wordmark"\n'
          '      />\n',
          '')],
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'],
        ['WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT'],
    ),
    'cta-testid-renamed': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'testID="first-run-continue"', 'testID="first-run-enter"')],
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'],
        ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT',
         'CTA_TEXT_EQUALS_FRAME_TITLE'],
    ),
    # B1 (критик 111, круг 1): CTA навигирует только в dark — светлая схема
    # остаётся на First-Run без перехода; красна именованной LIGHT-клеткой.
    'light-cta-noop': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'const { tokens } = useTheme();',
          'const { tokens, scheme } = useTheme();'),
         ('mobile/src/features/auth/first-run-screen.tsx',
          'onPress={onEnter}',
          "onPress={scheme === 'dark' ? onEnter : () => {}}")],
        ['CTA_OPENS_F03_01_LIGHT'], [],
    ),
    # B2: edges={[]} — импорт/цвет живы, но нативная защита краёв снята.
    'safearea-edges-empty': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          "      testID={testID ?? 'first-run-safe-area'}",
          "      edges={[]}\n      testID={testID ?? 'first-run-safe-area'}")],
        ['SAFEAREA_EDGES_ACTIVE_DARK', 'SAFEAREA_EDGES_ACTIVE_LIGHT'], [],
    ),
    # B3: Image.source подменён соседним ассетом при живых label/role/testID.
    'wordmark-wrong-source': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          "require('../../../assets/images/wordmark-dark.png')",
          "require('../../../assets/images/splash-icon.png')")],
        ['WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT'], [],
    ),
    # B5: некаталожная немецкая строка на поверхности (саблайн эталона без
    # ключа каталога) — видно, но вне закрытого перечня копии.
    'extra-unreviewed-copy': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Button\n',
          '      <Text>Versicherung. Erledigt.</Text>\n      <Button\n')],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    # B2r2 (критик 111, круг 2): боковые края сняты ТОЛЬКО в светлой схеме —
    # dark-двойник стаба green на парной DARK-клетке; красна LIGHT-клеткой
    # пары К3. Мутации — дословно из evidence критика круга 2.
    'light-edges-top-bottom': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'const { tokens } = useTheme();',
          'const { tokens, scheme } = useTheme();'),
         ('mobile/src/features/auth/first-run-screen.tsx',
          '<SafeAreaView\n',
          "<SafeAreaView\n      edges={scheme === 'light' ? ['top', 'bottom'] : undefined}\n")],
        ['SAFEAREA_EDGES_ACTIVE_LIGHT'], [],
    ),
    # B3r2: Image.source подменён соседним ассетом только в светлой схеме
    # (label/role/testID живы) — красна LIGHT-клеткой пары К4.
    'light-wrong-source': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'const { tokens } = useTheme();',
          'const { tokens, scheme } = useTheme();'),
         ('mobile/src/features/auth/first-run-screen.tsx',
          "source={require('../../../assets/images/wordmark-dark.png')}",
          "source={scheme === 'light' ? require('../../../assets/images/splash-icon.png') : require('../../../assets/images/wordmark-dark.png')}")],
        ['WORDMARK_SOURCE_BOUND_LIGHT'], [],
    ),
    # B5r2: некаталожный саблайн эталона на поверхности только в светлой
    # схеме — красна LIGHT-клеткой пары К5.
    'light-extra-copy': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'const { tokens } = useTheme();',
          'const { tokens, scheme } = useTheme();'),
         ('mobile/src/features/auth/first-run-screen.tsx',
          '      <Button\n',
          "      {scheme === 'light' ? <Text>Versicherung. Erledigt.</Text> : null}\n      <Button\n")],
        ['FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    # A2 (суд 111, круг 1): внешний корень PilotApp красится белым вокруг
    # First-Run — белая рамка вокруг тёмного ground + Demo-бейдж на белой
    # полосе; красна именованной клеткой пары К6 в ОБЕИХ схемах.
    'wrapper-root-white': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'backgroundColor: tokens.ground',
          "backgroundColor: '#FFFFFF'")],
        ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT'], [],
    ),
    # Обход адверсария (repro судьи круг 1): не-ground цвет внешнего корня
    # (#ff00ff) проходил все прежние клетки — теперь красен парой К6.
    'wrapper-root-magenta': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'backgroundColor: tokens.ground',
          "backgroundColor: '#ff00ff'")],
        ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT'], [],
    ),
    # Отступки корня 48/16/16 вокруг SafeAreaView: рамка из отступов
    # смещает канон-сетку First-Run (A2) — красна парой К6.
    'wrapper-root-padding': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'root: {\n    flex: 1,\n  },',
          'root: {\n    flex: 1,\n    paddingTop: 48,\n    paddingHorizontal: 16,\n    paddingBottom: 16,\n  },')],
        ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT'], [],
    ),
}


def case_name(title: str) -> str:
    return title[len(FAMILY_PREFIX):] if title.startswith(FAMILY_PREFIX) else title


def run_suite(repo: Path, blobs=None):
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        print('INFRASTRUCTURE: jest не установлен в R/mobile')
        return None
    files = {repo / TEST_INSTALL: (HERE / 'first_run.test.tsx').read_bytes()}
    if blobs:
        for rel, blob in blobs.items():
            files[repo / rel] = blob
    with installed(files):
        cases, proc = run_jest(mobile, repo / TEST_INSTALL)
    if not cases and proc.returncode != 0:
        return {}
    return cases


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        return matrix(repo)

    blobs = model_bytes() if args.model else None
    if not args.model and not (repo / SCREEN_PATH).exists():
        print(NAMED_RED)
        return 1
    cases = run_suite(repo, blobs)
    if cases is None:
        return 2
    if cases == {}:
        if not args.model:
            print(NAMED_RED)
            return 1
        print('INFRASTRUCTURE: jest suite не исполнился на модели')
        return 2
    if not args.model and all(s == 'failed' for s in cases.values()):
        print(NAMED_RED)
        return 1
    failed = sorted(c for c, s in cases.items() if s != 'passed')
    for title in sorted(case_name(c) for c, s in cases.items() if s == 'passed'):
        print('case', title)
    if failed:
        for c in failed:
            print('RED', case_name(c))
        return 1
    print(f'honest {len(cases)}/{len(cases)}')
    return 0


def matrix(repo: Path):
    src = model_bytes()
    honest = run_suite(repo, src)
    if honest is None or any(s != 'passed' for s in honest.values()):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN')
        return 2
    ok = True
    for name, (mutations, named, depends) in MUTANTS.items():
        try:
            blobs = model_bytes(mutations)
        except RuntimeError as err:
            print('MUTANT_ANCHOR_BROKEN', name, err)
            ok = False
            continue
        cases = run_suite(repo, blobs)
        if cases is None:
            print('MUTANT_INFRASTRUCTURE', name)
            ok = False
            continue
        red = {case_name(c) for c, s in cases.items() if s != 'passed'}
        expected = set(named) | set(depends)
        if not red:
            print('MUTANT_GREEN', name)
            ok = False
        elif not (set(named) & red):
            print('MUTANT_NAMED_MISS', name, sorted(red))
            ok = False
        elif not red <= expected:
            print('MUTANT_UNEXPECTED_RED', name, sorted(red - expected))
            ok = False
        else:
            print('mutant', name, 'red=', sorted(red))
    return 0 if ok else 2


if __name__ == '__main__':
    sys.exit(main())
