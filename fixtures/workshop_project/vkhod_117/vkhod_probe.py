#!/usr/bin/env python3
"""Поведенческая проба 117 v2 (CMP-MOB-006, сужение до splash + иконка,
слово владельца 2026-10-21): JS-ОВЕРЛЕЙ splash (арбитраж круга 2, С2) —
смонтирован, ВИДИМ реальным рендером (toBeVisible: оверлей, Image и
цепочка предков), БЕЗ степеней свободы геометрии (transform любой,
margin*, края ≠ 0 — SPLASH_OVERLAY_GEOMETRY_{DARK,LIGHT}, Adv117v2),
z-ПОРЯДОК ПОВЕРХ дерева (zIndex >= 1 над FirstRun + порядок sibling —
SPLASH_OVERLAY_ZORDER_{DARK,LIGHT}, Adv117v3),
Image оверлея = модуль композита своей схемы (С2-а),
вписан по окну (Р6), без Text-узлов, commit-журнал prevent → первый commit с
оверлеем → hide (С2-б), автоскрытие таймером-литералом; тема ОС на
production-входе (Р1); стиль статус-бара по схеме на splash (В2-2);
рестайл-гварды 995 — вход F03.01/F03.02 (выведен в first-run-ekran),
welcome, F03.04, unavailable остаются поверхностью 995.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево — rc1 и именованная причина
VKHOD_SPLASH_OVERLAY_ABSENT (клетка SPLASH_OVERLAY_MOUNTED_* красна).
С --model: эталон architect ставится по путям поставки, rc0 с перечнем
(число клеток — из прогона).
--matrix: каждый обманный стаб красен на объявленных ветвях
(named ∪ depends); краснота вне объявления — дефект матрицы rc2.
Выход — только код возврата; список case построчно.
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    FAMILY_PREFIX, HERE, TEST_INSTALL,
    installed, jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'VKHOD_SPLASH_OVERLAY_ABSENT'

# Якорь корня кадров модели (форма B: full-bleed ground только на first-run).
ROOT_ANCHOR = "        frame === 'first-run'\n          ? [styles.rootFirstRun"

# Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends).
MUTANTS = {
    # рестайл-гварды 995: welcome тоже перекрашен в ground.
    'restyle-welcome-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || frame === 'welcome'\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT'],
        [],
    ),
    # рестайл-гвард 995: recovery (F03.04) тоже перекрашен — владелец не называл.
    'restyle-recovery-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || frame === 'recovery'\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT'],
        [],
    ),
    # (Б4, круг 2) обход критика: unavailable получает full-bleed ground.
    'restyle-unavailable-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || frame === 'unavailable'\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
        [],
    ),
    # (Б4, круг 2) обход критика: recovery только в светлой схеме (тёмная —
    # наблюдаемый сосед — не тронута).
    'restyle-recovery-light-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || (frame === 'recovery' && tokens.ground === '#f3f2ee')\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_RECOVERY_LIGHT'],
        [],
    ),
    # (С2, арбитраж круга 2) оверлея нет при первом коммите: нативный splash
    # скрыт, кадр Splash.png не показан.
    'overlay-absent-first-commit': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'const [splashVisible, setSplashVisible] = useState(true);',
          'const [splashVisible, setSplashVisible] = useState(false);')],
        ['SPLASH_OVERLAY_MOUNTED_DARK', 'SPLASH_OVERLAY_MOUNTED_LIGHT'],
         ['SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT',
          'SPLASH_OVERLAY_NO_TEXT_DARK', 'SPLASH_OVERLAY_NO_TEXT_LIGHT',
          'SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT',
          'SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_COMPOSITE_LIGHT',
          'SPLASH_OVERLAY_CONTAIN_DARK', 'SPLASH_OVERLAY_CONTAIN_LIGHT',
         'SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT',
         'SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT',
          'PROD_ENTRY_OS_THEME_DARK', 'PROD_ENTRY_OS_THEME_LIGHT',
          'SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT'],
    ),
    # (С2) wordmark/tagline оверлея — Text-узлы (не растр композита).
    'overlay-text-words': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          <Image\n'
          '            source={\n'
          "              scheme === 'dark'\n",
          '          <Text>Versicherung. Erledigt.</Text>\n'
          '          <Image\n'
          '            source={\n'
          "              scheme === 'dark'\n")],
        ['SPLASH_OVERLAY_NO_TEXT_DARK', 'SPLASH_OVERLAY_NO_TEXT_LIGHT'],
        [],
    ),
    # (С2) hideAsync не вызван: нативный splash не снимается оверлеем.
    'overlay-hideasync-skip': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '    void SplashScreen.hideAsync();\n    const timer', '    const timer')],
        ['SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT'],
        [],
    ),
    # (С2) hideAsync на модуле ДО preventAutoHideAsync: порядок мок-вызовов
    # нарушен (скрытие до первого JS-кадра — пустое окно на устройстве).
    'overlay-hideasync-module-scope': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'void SplashScreen.preventAutoHideAsync();',
          'void SplashScreen.hideAsync();\nvoid SplashScreen.preventAutoHideAsync();'),
         ('mobile/src/bootstrap/pilot-app.tsx',
          '    void SplashScreen.hideAsync();\n    const timer', '    const timer')],
        ['SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT'],
        [],
    ),
    # (С2) таймер не срабатывает (120000 мс): оверлей не скрывается.
    'overlay-timer-none': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'const SPLASH_OVERLAY_MS = 1200;', 'const SPLASH_OVERLAY_MS = 120000;')],
        ['SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT'],
        # В2-2: клетка стиля статус-бара ждёт снятия оверлея (3×1200 мс).
        ['STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT'],
    ),
    # (С2-а, круг критика 3) свидетель overlay-wrong-source: Image оверлея
    # показывает icon.png вместо композитов (честные композиты на диске) —
    # эффективный source Image не модуль композита схемы.
    'overlay-wrong-source': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "require('../../assets/images/splash-composite-dark.png')",
          "require('../../assets/images/icon.png')"),
         ('mobile/src/bootstrap/pilot-app.tsx',
          "require('../../assets/images/splash-composite-light.png')",
          "require('../../assets/images/icon.png')")],
        ['SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_COMPOSITE_LIGHT'],
        [],
    ),
    # (С2-б, круг критика 3) свидетель overlay-hide-before-commit: hideAsync
    # перенесён из effect в ленивый инициализатор useState — вызывается в
    # render ДО первого commit (журнал prevent → hide → commit).
    'overlay-hide-before-commit': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'const [splashVisible, setSplashVisible] = useState(true);',
          'const [splashVisible, setSplashVisible] = useState(() => {\n'
          '    void SplashScreen.hideAsync();\n'
          '    return true;\n'
          '  });'),
         ('mobile/src/bootstrap/pilot-app.tsx',
          '    void SplashScreen.hideAsync();\n    const timer', '    const timer')],
        ['SPLASH_HIDEASYNC_ORDER_DARK', 'SPLASH_HIDEASYNC_ORDER_LIGHT'],
        [],
    ),

    # production-входе всегда тёмный (форма текущего C — useTheme по
    # умолчанию dark, вход без провайдера).
    'prod-theme-os-ignored': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const [osScheme, setOsScheme] = useState<'dark' | 'light'>(() =>\n"
          "    Appearance.getColorScheme() === 'light' ? 'light' : 'dark');",
          "  const [osScheme, setOsScheme] = useState<'dark' | 'light'>(() => 'dark');")],
        ['PROD_ENTRY_OS_THEME_LIGHT'],
        # В2-2: схема PilotApp dark при ОС light — стиль статус-бара light.
        ['STATUS_BAR_STYLE_LIGHT'],
    ),
    # (Р1) тест-обход: хардкод схемы light вместо чтения ОС. Внешний
    # dark-провайдер проб неотличим от умолчания контекста — хардкод
    # ломает и тёмные клетки с палитрой (измерено матрицей круга 6).
    'prod-theme-light-hardcode': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const [osScheme, setOsScheme] = useState<'dark' | 'light'>(() =>\n"
          "    Appearance.getColorScheme() === 'light' ? 'light' : 'dark');",
          "  const [osScheme, setOsScheme] = useState<'dark' | 'light'>(() => 'light');")],
        ['PROD_ENTRY_OS_THEME_DARK'],
        ['SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_MOUNTED_DARK',
         'STATUS_BAR_STYLE_DARK'],
    ),
    # (117 v2) вход в форме текущего C: корень F03.01/F03.02 перекрашен в
    # full-bleed ground — вход выведен в first-run-ekran, обязан остаться
    # поверхностью 995.
    'auth-restyled-ground': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || frame === 'email' || frame === 'code'\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT'],
        [],
    ),
    # (117 v2) только кадр code (F03.02) в светлой схеме: судятся ОБА кадра
    # входа × обе схемы, не выборка (email и тёмная схема не тронуты).
    'auth-restyled-code-light': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || (frame === 'code' && tokens.ground === '#f3f2ee')\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_F03_LIGHT'],
        [],
    ),
    # (Р6, круг 6, Rev117) композит оверлея собственным размером: бокс
    # Image не привязан к окну (форма текущего C — масштаб 2.63, прижим
    # к углу, сдвиг теглайна 28 px).
    'overlay-intrinsic-size': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
          '            style={StyleSheet.absoluteFill}')],
        ['SPLASH_OVERLAY_CONTAIN_DARK', 'SPLASH_OVERLAY_CONTAIN_LIGHT'],
        [],
    ),
    # (вердикт критика 117 v2 круг 1, свидетель invisible-overlay.tsx)
    # `opacity: 0` в стиле View оверлея рядом с zIndex: весь кадр
    # прозрачен, стиль Image честен.
    'overlay-opacity-zero': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '            zIndex: 1000,\n',
          '            zIndex: 1000,\n            opacity: 0,\n')],
        ['SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT'],
        [],
    ),
    # (родственный) display 'none' на View оверлея: узел скрыт и от
    # доступности — запросы без скрытых узлов его не находят (depends —
    # клетки, ищущие оверлей по testID; замер матрицы 117e).
    'overlay-display-none': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '            zIndex: 1000,\n',
          "            zIndex: 1000,\n            display: 'none',\n")],
        ['SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT'],
        ['PROD_ENTRY_OS_THEME_DARK', 'PROD_ENTRY_OS_THEME_LIGHT',
         'SPLASH_OVERLAY_MOUNTED_DARK', 'SPLASH_OVERLAY_MOUNTED_LIGHT',
         'SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT'],
    ),
    # (родственный, предок) `opacity: 0` на корне PilotApp кадра first-run:
    # стили оверлея и Image честны, кадр скрыт предком.
    'root-opacity-zero': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '? [styles.rootFirstRun, { backgroundColor: tokens.ground }]',
          '? [styles.rootFirstRun, { backgroundColor: tokens.ground, opacity: 0 }]')],
        ['SPLASH_OVERLAY_VISIBLE_DARK', 'SPLASH_OVERLAY_VISIBLE_LIGHT'],
        [],
    ),
    # (родственный) нулевой бокс оверлея: width/height 0 вместо 100%.
    'overlay-zero-size': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "            width: '100%',\n            height: '100%',\n",
          '            width: 0,\n            height: 0,\n')],
        ['SPLASH_OVERLAY_CONTAIN_DARK', 'SPLASH_OVERLAY_CONTAIN_LIGHT'],
        [],
    ),
    # (Adv117v2, круг по реализации) ГЕОМЕТРИЯ оверлея: transform в
    # третьем элементе массива стилей Image — композит и require
    # каноничны, но кадр сдвинут/смасштабирован; прежние клетки transform
    # не судили. Красна геометрической клеткой обеих схем.
    'overlay-transform-translatex': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' },\n"
          "                    { transform: [{ translateX: 19 }] }]}")],
        ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT'],
        [],
    ),
    'overlay-transform-translatey': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' },\n"
          "                    { transform: [{ translateY: 19 }] }]}")],
        ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT'],
        [],
    ),
    'overlay-transform-scale': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' },\n"
          "                    { transform: [{ scale: 0.9 }] }]}")],
        ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT'],
        [],
    ),
    # (Adv117v2) margin-смещение того же Image: сдвиг layout сверх
    # канона (absoluteFill + width/height 100%).
    'overlay-margin-offset': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%' }]}",
          "            style={[StyleSheet.absoluteFill, { width: '100%', height: '100%',"
          " marginLeft: 50 }]}")],
        ['SPLASH_OVERLAY_GEOMETRY_DARK', 'SPLASH_OVERLAY_GEOMETRY_LIGHT'],
        [],
    ),
    # (Adv117v3, круг по реализации) Z-ПОРЯДОК: сплеш ПОД полноэкранным
    # FirstRun — RNTL toBeVisible не видит перекрытия соседом, прежняя
    # батарея зелена при zIndex: -1 (находка Adv117v3). Оверлей смонтирован
    # и каноничен по source/геометрии, но пользователь видит First-Run.
    'overlay-zindex-minus': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '            zIndex: 1000,\n', '            zIndex: -1,\n')],
        ['SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT'],
        [],
    ),
    # (Adv117v3) нулевой zIndex: наравне с деревом — порядок решают узлы,
    # канон требует уровня НАД FirstRun.
    'overlay-zindex-zero': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '            zIndex: 1000,\n', '            zIndex: 0,\n')],
        ['SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT'],
        [],
    ),
    # (Adv117v3) оверлей ПЕРЕД FirstRun в порядке sibling БЕЗ zIndex:
    # и уровень, и порядок узлов нарушены (полноэкранный FirstRun
    # рисуется поверх сплеша при зелёном toBeVisible).
    'overlay-before-firstrun': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '            zIndex: 1000,\n', ''),
         ('mobile/src/bootstrap/pilot-app.tsx',
          "      {frame === 'first-run' ? (\n"
          '        <FirstRunScreen onEnter={handleFirstRunContinue} />\n'
          '      ) : null}\n', ''),
         ('mobile/src/bootstrap/pilot-app.tsx',
          '      ) : null}\n'
          '    </View>\n'
          '    </ThemeContext.Provider>\n'
          '  );\n}',
          '      ) : null}\n'
          "      {frame === 'first-run' ? (\n"
          '        <FirstRunScreen onEnter={handleFirstRunContinue} />\n'
          '      ) : null}\n'
          '    </View>\n'
          '    </ThemeContext.Provider>\n'
          '  );\n}')],
        ['SPLASH_OVERLAY_ZORDER_DARK', 'SPLASH_OVERLAY_ZORDER_LIGHT'],
        [],
    ),
    # (В2-2, круг 7, Rev117r2) StatusBar отсутствует (форма C 74c4c586):
    # приложение стиль не отрисовало. Дефект на устройстве — LIGHT (белые
    # иконки на #f3f2ee; в dark умолчание ОС случайно светлое); DARK
    # красна тоже — стиля, отрисованного PilotApp, нет.
    'statusbar-absent': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "import { StatusBar } from 'expo-status-bar';\n", ''),
         ('mobile/src/bootstrap/pilot-app.tsx',
          "      <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />\n", '')],
        ['STATUS_BAR_STYLE_LIGHT'],
        ['STATUS_BAR_STYLE_DARK'],
    ),
    # (В2-2) style=light в обеих схемах: светлые иконки на светлом ground.
    'statusbar-light-both': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "<StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />",
          '<StatusBar style="light" />')],
        ['STATUS_BAR_STYLE_LIGHT'],
        [],
    ),
    # (В2-2) style=dark в обеих схемах: тёмные иконки на тёмном ground.
    'statusbar-dark-both': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "<StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />",
          '<StatusBar style="dark" />')],
        ['STATUS_BAR_STYLE_DARK'],
        [],
    ),
    # (В2-2) свидетель «вне поддерева оверлея»: StatusBar внутри оверлея —
    # стиль верен на splash и снимается вместе с оверлеем (таймер 1200).
    'statusbar-in-overlay': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />\n", ''),
         ('mobile/src/bootstrap/pilot-app.tsx',
          '          <Image\n            source={\n',
          "          <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />\n"
          '          <Image\n            source={\n')],
        ['STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT'],
        [],
    ),
}


def case_name(title: str) -> str:
    return title[len(FAMILY_PREFIX):] if title.startswith(FAMILY_PREFIX) else title


def run_suite(repo: Path, blobs=None):
    mobile = repo / 'mobile'
    if not jest_ready(mobile):
        print('INFRASTRUCTURE: jest не установлен в R/mobile')
        return None
    files = {repo / TEST_INSTALL: (HERE / 'vkhod.test.tsx').read_bytes()}
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
    cases = run_suite(repo, blobs)
    if cases is None:
        return 2
    if not cases:
        print('NO_TEST_RESULTS')
        return 2
    failed = [name for name, status in cases.items() if status != 'passed']
    for name in cases:
        print('case', case_name(name))
    if failed:
        # Именованная причина до-предметного дерева — по наблюдению клетки
        # (оверлей кадра Splash.png не смонтирован), не по тексту исходника.
        if any(case_name(name).startswith('SPLASH_OVERLAY_MOUNTED_') for name in failed):
            print(NAMED_RED)
        print('failed', len(failed), 'of', len(cases))
        return 1
    print(f'behavioral {len(cases)}/{len(cases)}')
    return 0


def matrix(repo: Path):
    honest = run_suite(repo, model_bytes())
    if honest is None:
        return 2
    if not honest or any(status != 'passed' for status in honest.values()):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN', {case_name(k): v for k, v in honest.items()})
        return 2
    print('honest green', len(honest))
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
            return 2
        if not cases:
            print('MUTANT_SUITE_BROKEN', name)
            ok = False
            continue
        red = {case_name(k) for k, v in cases.items() if v != 'passed'}
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
