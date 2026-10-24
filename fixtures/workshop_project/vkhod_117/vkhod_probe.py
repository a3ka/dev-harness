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
117 v3 (миграция 117/3, слово владельца 2026-10-24): клетки MIGRACIYA_*
судят демо-маршрут First-Run → demo → Erstinformation → Start в
pilot-app по семантике frozen 118/1 (арбитраж нарезки 117↔118): admission
решает ПОВЕРХНОСТЬ (W1A → Erstinformation при ЛЮБОМ gate), gate — ПЕРЕХОД
(continue → Start только при W1A ∧ current; при null/stale continue не
переводит). Не-W1A — прежний путь B (F03, Г0). Допуск приходит портом
onboarding (внешняя сессия), не литералом.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево — rc1 и именованная причина
VKHOD_SPLASH_OVERLAY_ABSENT (клетка SPLASH_OVERLAY_MOUNTED_* красна).
С --model: эталон architect ставится по путям поставки, rc0 с перечнем
(число клеток — из прогона).
--matrix: каждый обманный стаб красен на объявленных ветвях
(named ∪ depends); краснота вне объявления — дефект матрицы rc2.
Правка по FAIL критика v3 круг 1: клетки непокрытых входов допуска
(отсутствующий admission/gate — поля OPTIONAL, W0×stale, светлая тема)
и Г0 на экземплярах с подключённым onboarding (недопуск/допуск, обе
темы); стабы-обходы критика + собственные.
Правка по FAIL критика v3 КРУГ 2 (класс, не точки): ТАБЛИЦА ВХОДОВ —
все выразимые входы порта onboarding (форма порта × admission × gate ×
тема, 26 строк × 2 = 52 клетки MIGRACIYA_TABLICA_*, имена производны
от строки, ожидание выводится из строки: допуск ⇔ W1A ∧ current;
недопуск — прежний путь B и Г0 #FFFFFF 48/16/16 в обеих темах);
стабы: все 10 мутантов критика кругов 1–2 (включая зелёные в круге 2
new-light-gate-default, new-empty-session-demo, new-g0-denied-admission)
и собственные — каждый красен на объявленных ветвях.
Правка по РЕШЕНИЮ арбитража нарезки 117↔118 (после 3 FAIL критика):
семантика frozen 118/1 (admission решает поверхность, gate — переход
continue → Start), клетки (а)–(д) — ось entry × решающие пары,
постороннее поле порта, начальный кадр/remount, Г0 после смены схемы,
порядок Start при смене темы на Erstinformation, rerender W1A→W0;
семь мутантов критика r3 — именованные стабы матрицы.
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    FAMILY_PREFIX, HERE, TEST_INSTALL,
    installed, jest_ready, model_bytes, run_jest,
)

# ТАБЛИЦА ВХОДОВ допуска (правка по FAIL критика v3 круг 2): зеркало
# VHOD_TABLICA теста — все ВЫРАЗИМЫЕ строки порта onboarding (форма ×
# admission × gate). Оси: admission ∈ {W0, W1A, отсутствует(OTSUT), null,
# неизвестное(NEIZVESTNOE)}; gate ∈ {current, stale, отсутствует, null,
# неизвестное}. Форма связывает выразимость: «не подключён» и «пустой {}»
# дают только OTSUT/OTSUT; частичный — ровно одно поле; полный — оба.
_TABL_ROWS = (
    [('NEPODKLYUCHEN', 'OTSUT', 'OTSUT'), ('PUSTOJ', 'OTSUT', 'OTSUT')]
    + [('CHASTICHNYJ', a, 'OTSUT') for a in ('W0', 'W1A', 'NULL', 'NEIZVESTNOE')]
    + [('CHASTICHNYJ', 'OTSUT', g) for g in ('CURRENT', 'STALE', 'NULL', 'NEIZVESTNOE')]
    + [('POLNYJ', a, g) for a in ('W0', 'W1A', 'NULL', 'NEIZVESTNOE')
       for g in ('CURRENT', 'STALE', 'NULL', 'NEIZVESTNOE')]
)
# строки с truthy портом (все, кроме «не подключён») и с ожиданием недопуска
_TABL_TRUTHY = [r for r in _TABL_ROWS if r[0] != 'NEPODKLYUCHEN']
_TABL_NEDOPUSK = [r for r in _TABL_ROWS if not (r[1] == 'W1A' and r[2] == 'CURRENT')]

# Зеркала семей круга 3 (арбитраж нарезки 117↔118, клетки (а)–(д)).
_ENTRY_AXIS = ('COMPLETE', 'UNKNOWN', 'INCOMPLETE', 'OTSUT')
_ENTRY_PAIRS = ('W0_STALE', 'W0_CURRENT', 'W1A_STALE', 'W1A_CURRENT', 'NEPODKLYUCHEN')


def _entry(axis=_ENTRY_AXIS, pairs=_ENTRY_PAIRS, temy=('DARK', 'LIGHT')):
    """Клетки оси entry (а): MIGRACIYA_ENTRY_<entry>_<пара>_<тема>."""
    return [f'MIGRACIYA_ENTRY_{a}_{p}_{t}' for a in axis for p in pairs for t in temy]


def _nachalnyj(axis=_ENTRY_AXIS, pairs=_ENTRY_PAIRS, temy=('DARK', 'LIGHT')):
    """Клетки начального кадра (б): MIGRACIYA_NACHALNYJ_KADR_<e>_<п>_<t>."""
    return [f'MIGRACIYA_NACHALNYJ_KADR_{a}_{p}_{t}' for a in axis for p in pairs for t in temy]


_AUTH_POLE = ['MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_W0_STALE_DARK',
              'MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_W0_STALE_LIGHT']
_REMOUNT = ['MIGRACIYA_REMOUNT_ENTRY_COMPLETE_W0_STALE']
_G0_SMENA = ['MIGRACIYA_G0_SMENA_TEMY_DARK_TO_LIGHT', 'MIGRACIYA_G0_SMENA_TEMY_LIGHT_TO_DARK']
_PORYADOK = ['MIGRACIYA_PORYADOK_SMENA_TEMY_DARK_TO_LIGHT',
             'MIGRACIYA_PORYADOK_SMENA_TEMY_LIGHT_TO_DARK']
_RERENDER = ['MIGRACIYA_RERENDER_W1A_W0_DARK', 'MIGRACIYA_RERENDER_W1A_W0_LIGHT']

# строки таблицы: W1A (поверхность Erstinformation) и её не-current срез;
# truthy-недопуск (включая строки допуска к Start, закрытого по gate).
_TABL_W1A = [r for r in _TABL_ROWS if r[1] == 'W1A']
_TABL_W1A_NE_CURRENT = [r for r in _TABL_W1A if r[2] != 'CURRENT']
_TABL_NE_W1A = [r for r in _TABL_ROWS if r[1] != 'W1A']
_TABL_TRUTHY_NEDOPUSK = [r for r in _TABL_TRUTHY if r[1] != 'W1A' or r[2] != 'CURRENT']
_TABL_DOPUSK = [('POLNYJ', 'W1A', 'CURRENT')]


def _tabl(form, adm, gate, temy=('DARK', 'LIGHT')):
    """Имя клетки таблицы входов — производное от строки (как в тесте)."""
    return [f'MIGRACIYA_TABLICA_{form}_{adm}_{gate}_{t}' for t in temy]


def _tabl_rows(rows, temy=('DARK', 'LIGHT')):
    return [name for row in rows for name in _tabl(*row, temy=temy)]

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
        ['RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT',
         # правка FAIL v3 (замер матрицы): тот же рестайл наблюдаем и на
         # экземплярах с подключённым onboarding — недопуск и допуск.
         'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT',
         'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT']
        # правка FAIL v3 круг 2 (таблица входов): рестайл email/code
        # безусловен — красна КАЖДАЯ строка таблицы × обе темы (52);
        # круг 3 (замер): Г0 до/после смены схемы судит те же корни.
        + _tabl_rows(_TABL_ROWS)
        + _G0_SMENA,
        [],
    ),
    # (117 v2) только кадр code (F03.02) в светлой схеме: судятся ОБА кадра
    # входа × обе схемы, не выборка (email и тёмная схема не тронуты).
    'auth-restyled-code-light': (
        [('mobile/src/bootstrap/pilot-app.tsx', ROOT_ANCHOR,
          "        frame === 'first-run' || (frame === 'code' && tokens.ground === '#f3f2ee')\n"
          '          ? [styles.rootFirstRun')],
        ['RESTYLE_GUARD_995_F03_LIGHT',
         # правка FAIL v3 (замер матрицы): код-кадр светлой схемы судится
         # и при подключённом onboarding (недопуск, светлая тема).
         'MIGRACIYA_G0_F03_ONBOARDING_LIGHT',
         # круг 3 (замер): Г0-смена dark→light судит код-кадр в светлой.
         'MIGRACIYA_G0_SMENA_TEMY_DARK_TO_LIGHT']
        # правка круга 2 + круг 3 (замер): код-кадр достижим только на
        # не-W1A строках (21 светлая строка недопуска с admission ≠ W1A).
        + _tabl_rows([r for r in _TABL_NEDOPUSK if r[1] != 'W1A'], temy=('LIGHT',)),
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
    # ---- 117 v3 (миграция 117/3; арбитраж нарезки 117↔118): стабы
    # допуска маршрута. Семантика модели: admission решает ПОВЕРХНОСТЬ
    # (демо → Erstinformation при любом gate), gate — ПЕРЕХОД (continue →
    # Start только W1A ∧ current). Обходы admission ловятся КАДРОМ
    # (Erstinformation у недопущенного), обходы gate — START'ом на
    # Erstinformation-клетках (арбитраж: «там ловится Start, а не кадр»). ----
    # «admission обходится»: pilot-app несёт литерал допуска W1A (порт
    # сессии проигнорирован) — Erstinformation на КАЖДОМ входе с
    # admission ≠ W1A (включая отсутствие порта, пустой и null).
    'migracija-admission-literal': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = 'W1A';")],
        ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT',
         'MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT',
         'MIGRACIYA_W0_STALE_PREZHNIJ_PUT',
         'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT']
        + _tabl_rows(_TABL_NE_W1A)
        + _entry(pairs=('W0_STALE', 'W0_CURRENT', 'NEPODKLYUCHEN'))
        + _AUTH_POLE + _G0_SMENA + _RERENDER,
        # Побочная краснота (замер матрицы): недопущенные Г0-клетки
        # ONBOARDING красны — демо-вход уводится в Erstinformation,
        # код-кадр не возникает; кадры 995 (Г0–Г3) недостижимы демо-входом.
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT',
         'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT',
         'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
    ),
    # «gate не проверяется в переходе»: continue → Start при любом gate у
    # W1A — Start ловится на Erstinformation-клетках не-current входов.
    'migracija-gate-ignor': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A') {")],
        ['MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl_rows(_TABL_W1A_NE_CURRENT)
        + _entry(pairs=('W1A_STALE',)),
        [],
    ),
    # «порядок маршрута сломан»: демо-вход сразу в Start, минуя
    # Erstinformation (continue-шаг отсутствует) — на ВСЕХ W1A-входах.
    'migracija-start-pryamo': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      setFrame('erstinformation');\n      return;",
          "      setFrame('start');\n      return;")],
        ['MIGRACIYA_W1A_CURRENT_MARSHRUT', 'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
        + _tabl_rows(_TABL_W1A)
        + ['MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT',
           'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT',
           'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _entry(pairs=('W1A_STALE', 'W1A_CURRENT'))
        + _PORYADOK,
        [],
    ),
    # «Г0 ослаблен» формой миграции: прежний путь F03 выброшен —
    # first-run-continue ведёт сразу в Erstinformation, кадры входа
    # (auth-email/auth-code, белый корень 48/16/16) недостижимы.
    'migracija-f03-put-udalen': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const handleFirstRunContinue = useCallback(() => {\n    setFrame('email');\n  }, []);",
          "  const handleFirstRunContinue = useCallback(() => {\n    setFrame('erstinformation');\n  }, []);")],
        ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_CURRENT_MARSHRUT'],
        # Побочная краснота (замер матрицы): прежний путь удалён — кадры
        # email/code/welcome/recovery/unavailable недостижимы, гварды Г0–Г3
        # падают по той же причине (depends, не named).
        ['RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT',
         'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT',
         'MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT',
         'MIGRACIYA_W0_STALE_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT',
         'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT',
         'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT',
         'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT']
        # Круг 2 + круг 3 (замер матрицы): прежний путь удалён — ВСЕ 52
        # клетки таблицы, все entry-клетки оси, постороннее поле, Г0 и
        # порядок после смены схемы, rerender красны той же причиной
        # (auth-email недостижим после First-Run) — depends, не named;
        # клетки начального кадра/remount наблюдают First-Run и зелены.
        + _tabl_rows(_TABL_ROWS)
        + _entry() + _AUTH_POLE + _G0_SMENA + _PORYADOK + _RERENDER,
    ),
    # ---- 117 v3 правка по FAIL критика v3: мутанты допуска и Г0 ----
    # (критик v3, обход «умолчание admission») литерал W1A вместо W0:
    # admission-undefined/null входы уходят в Erstinformation —
    # наблюдаем на входах ОТСУТСТВУЮЩЕГО/NULL admission (осевые строки
    # таблицы + entry-клетки пары без порта).
    'migracija-admission-default': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = onboarding?.admission ?? 'W1A';")],
        ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT']
        + _tabl_rows([r for r in _TABL_ROWS if r[1] in ('OTSUT', 'NULL')])
        + _entry(pairs=('NEPODKLYUCHEN',)),
        # Побочная краснота (замер матрицы): сессия без admission
        # (умолчание W1A) уводит демо в Erstinformation — кадры 995
        # (Г0–Г3) и Г0 ONBOARDING недостижимы демо-входом.
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT',
         'RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT',
         'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
    ),
    # (критик v3, обход «умолчание gate») литерал current вместо null:
    # continue из Erstinformation открывает Start на W1A-входах без
    # gate/null — наблюдаем на входе ОТСУТСТВУЮЩЕГО gate.
    'migracija-gate-default': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingGate = onboarding?.gate ?? 'null';",
          "  const onboardingGate = onboarding?.gate ?? 'current';")],
        ['MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
        + _tabl_rows([('CHASTICHNYJ', 'W1A', 'OTSUT'), ('POLNYJ', 'W1A', 'NULL')]),
        [],
    ),
    # (критик v3, обход «W0×stale») сочетание W0×stale допущено в
    # ПОВЕРХНОСТЬ (Erstinformation у недопущенного) — строки с
    # admission-нормализованным W0 × stale.
    'migracija-w0-stale-dopushchen': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A') {",
          "    if (onboardingAdmission === 'W1A'\n"
          "        || (onboardingAdmission === 'W0' && onboardingGate === 'stale')) {")],
        ['MIGRACIYA_W0_STALE_PREZHNIJ_PUT']
        + _tabl_rows([('POLNYJ', 'W0', 'STALE'), ('CHASTICHNYJ', 'OTSUT', 'STALE'),
                      ('POLNYJ', 'NULL', 'STALE')])
        # круг 3 (замер матрицы): тот же вход W0×stale несут entry-клетки
        # пары, постороннее поле и Г0-смена — Erstinformation у недопущенного.
        + _entry(pairs=('W0_STALE',)) + _AUTH_POLE + _G0_SMENA,
        [],
    ),
    # (критик v3, обход «светлая тема») светлая схема сама себе допуск —
    # и поверхность, и переход: любой truthy недопущенный порт в light
    # уходит в Erstinformation, при current открывается Start.
    'migracija-svetlui-obhod': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A') {",
          "    if (onboardingAdmission === 'W1A' || (onboarding && scheme === 'light')) {"),
         ('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if ((onboardingAdmission === 'W1A' || (onboarding && scheme === 'light'))\n"
          "      && onboardingGate === 'current') {")],
        ['MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT',
         'MIGRACIYA_RERENDER_W1A_W0_LIGHT',
         'MIGRACIYA_G0_SMENA_TEMY_LIGHT_TO_DARK',
         _AUTH_POLE[1]]
        + _tabl_rows([r for r in _TABL_TRUTHY_NEDOPUSK if r[1] != 'W1A'], temy=('LIGHT',))
        # круг 3 (замер): light-входы W0-пар оси entry — тот же класс
        # (truthy недопущенный порт в light).
        + _entry(pairs=('W0_STALE', 'W0_CURRENT'), temy=('LIGHT',)),
        # Побочно (замер матрицы): Г0-клетка ONBOARDING_LIGHT красна —
        # демо уводится мимо код-кадра.
        ['MIGRACIYA_G0_F03_ONBOARDING_LIGHT'],
    ),
    # (критик v3, блокер 2) подключённый onboarding рестайлит корень F03:
    # чёрный фон и нулевые отступы вместо #FFFFFF/48/16/16 — наблюдаем
    # Г0-клетками ONBOARDING_{DARK,LIGHT} и строками таблицы; круг 3 —
    # и Г0 до/после смены схемы (вход W0/stale — truthy порт).
    'migracija-onboarding-restyles-f03': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding ? { backgroundColor: '#000000',"
          " paddingTop: 0, paddingHorizontal: 0, paddingBottom: 0 } : null]\n")],
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT']
        + _tabl_rows(_TABL_TRUTHY)
        + _G0_SMENA,
        ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT'],
    ),
    # (свой 1) маршрут допуска открыт только в тёмной теме — светлая
    # лишается И поверхности (W1A-light уходит в путь B).
    'migracija-marshrut-tolko-temnyi': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A') {",
          "    if (onboardingAdmission === 'W1A' && scheme === 'dark') {")],
        ['MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl_rows(_TABL_W1A, temy=('LIGHT',))
        + _entry(pairs=('W1A_STALE', 'W1A_CURRENT'), temy=('LIGHT',))
        + ['MIGRACIYA_PORYADOK_SMENA_TEMY_LIGHT_TO_DARK'],
        [],
    ),
    # (свой 2) stale принят как current в ПЕРЕХОДЕ — Start при W1A×stale.
    'migracija-stale-kak-current': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && (onboardingGate === 'current'"
          " || onboardingGate === 'stale')) {")],
        ['MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl('POLNYJ', 'W1A', 'STALE')
        + _entry(pairs=('W1A_STALE',)),
        [],
    ),
    # (свой 3) рестайл корня F03 ТОЛЬКО при допуске — наблюдаем
    # Г0-клетками DOPUSK_{DARK,LIGHT} на кадре email при W1A ∧ current.
    'migracija-restyle-pri-dopuske': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboardingAdmission === 'W1A'"
          " && onboardingGate === 'current' ? { backgroundColor: '#000000',"
          " paddingTop: 0, paddingHorizontal: 0, paddingBottom: 0 } : null]\n")],
        ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT']
        + _tabl_rows(_TABL_DOPUSK),
        [],
    ),
    # ---- 117 v3 правка по FAIL критика КРУГ 2: пять мутантов критика
    # (attack.py кругов 1–2) + пять собственных; круг 3 — привязки
    # перечитаны замером под семантику frozen 118/1 (Н-39). ----
    # (критик круг 2, блокер 1) умолчание отсутствующего gate — current
    # только в светлой теме: continue открывает Start в light.
    'migracija-light-gate-default': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingGate = onboarding?.gate ?? 'null';",
          "  const onboardingGate = onboarding?.gate ?? (scheme === 'light' ? 'current' : 'null');")],
        _tabl_rows([('CHASTICHNYJ', 'W1A', 'OTSUT'), ('POLNYJ', 'W1A', 'NULL')],
                   temy=('LIGHT',)),
        [],
    ),
    # (критик круг 2) stale равен current в светлой теме (переход).
    'migracija-light-stale-current': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && (onboardingGate === 'current'"
          " || (scheme === 'light' && onboardingGate === 'stale'))) {")],
        ['MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl('POLNYJ', 'W1A', 'STALE', temy=('LIGHT',))
        + _entry(pairs=('W1A_STALE',), temy=('LIGHT',)),
        [],
    ),
    # (критик круг 2, блокер 1) ПУСТОЙ подключённый порт {} — сам себе
    # допуск: истина порта ≠ допуску, absence-полей недостаточно.
    'migracija-pustaya-sessiya-demo': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A') {",
          "    if (onboardingAdmission === 'W1A'\n"
          "        || (onboarding && onboarding.admission === undefined\n"
          "            && onboarding.gate === undefined)) {")],
        _tabl('PUSTOJ', 'OTSUT', 'OTSUT'),
        [],
    ),
    # (критик круг 2, блокер 2) корень F03 рестайлится при подключённом
    # порте с ОТКЛОНЁННЫМ gate: все truthy-строки с gate ≠ current
    # (20 строк × 2 темы = 40 клеток), обе темы + Г0 после смены схемы.
    'migracija-g0-nedopusk-restail': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding && onboardingGate !== 'current'"
          " ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0,"
          " paddingBottom: 0 } : null]\n")],
        _tabl_rows([r for r in _TABL_TRUTHY if r[2] != 'CURRENT'])
        + _G0_SMENA,
        [],
    ),
    # (критик круг 2) Start мимо Erstinformation в светлой теме.
    'migracija-light-start-do-continue': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      setFrame('erstinformation');\n      return;",
          "      setFrame(scheme === 'light' ? 'start' : 'erstinformation');\n      return;")],
        ['MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT',
         # круг 3 (замер): светлая W1A×stale-клетка — demo в light уходит
         # в Start мимо Erstinformation.
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl_rows(_TABL_W1A, temy=('LIGHT',))
        + _entry(pairs=('W1A_STALE', 'W1A_CURRENT'), temy=('LIGHT',))
        + ['MIGRACIYA_PORYADOK_SMENA_TEMY_LIGHT_TO_DARK'],
        [],
    ),
    # (свой 4) null gate принят как current в ПЕРЕХОДЕ — строки
    # POLNYJ/W1A/NULL и умолчание отсутствующего (CHASTICHNYJ/W1A/OTSUT).
    'migracija-null-kak-current': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && (onboardingGate === 'current'"
          " || onboardingGate === 'null')) {")],
        ['MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
        + _tabl('POLNYJ', 'W1A', 'NULL') + _tabl('CHASTICHNYJ', 'W1A', 'OTSUT'),
        [],
    ),
    # (свой 5) `||` в ОБОИХ предикатах: admission ИЛИ gate открывают
    # маршрут порознь — кадр (не-W1A × current) и Start (W1A × не-current).
    'migracija-or-uslovie': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A') {",
          "    if (onboardingAdmission === 'W1A' || onboardingGate === 'current') {"),
         ('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' || onboardingGate === 'current') {")],
        ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT',
         'MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl_rows([('CHASTICHNYJ', 'W1A', 'OTSUT'), ('CHASTICHNYJ', 'OTSUT', 'CURRENT'),
                      ('POLNYJ', 'W0', 'CURRENT'), ('POLNYJ', 'W1A', 'STALE'),
                      ('POLNYJ', 'W1A', 'NULL'), ('POLNYJ', 'W1A', 'NEIZVESTNOE'),
                      ('POLNYJ', 'NULL', 'CURRENT'), ('POLNYJ', 'NEIZVESTNOE', 'CURRENT')])
        + _entry(pairs=('W0_CURRENT', 'W1A_STALE'))
        + _RERENDER,
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT'],
    ),
    # (свой 6) сам ПОРТ — источник допуска: truthy порт без admission
    # даёт W1A — строки admission {OTSUT, NULL} truthy-форм.
    'migracija-port-est-dopusk': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = onboarding\n"
          "      ? (onboarding.admission ?? 'W1A')\n"
          "      : 'W0';")],
        ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT']
        + _tabl_rows([r for r in _TABL_TRUTHY if r[1] in ('OTSUT', 'NULL')]),
        [],
    ),
    # (свой 7) Г0-рестайл при недопуске ПО ADMISSION (зеркало
    # g0-nedopusk-restail по другой оси): все truthy-строки с
    # admission ≠ W1A (20 строк × 2 темы = 40 клеток) обе темы.
    'migracija-g0-restail-nedopusk-admission': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding && onboardingAdmission !== 'W1A'"
          " ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0,"
          " paddingBottom: 0 } : null]\n")],
        _tabl_rows([r for r in _TABL_TRUTHY if r[1] != 'W1A'])
        + ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT']
        + _G0_SMENA,
        [],
    ),
    # (свой 8) Start мимо Erstinformation в ТЁМНОЙ теме (зеркало
    # light-start-do-continue) — порядок маршрута в обеих темах.
    'migracija-temnyi-start-do-continue': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      setFrame('erstinformation');\n      return;",
          "      setFrame(scheme === 'dark' ? 'start' : 'erstinformation');\n      return;")],
        ['MIGRACIYA_W1A_CURRENT_MARSHRUT',
         # круг 3 (замер): тёмные W1A×не-current клетки — demo в dark
         # уходит в Start мимо Erstinformation.
         'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_NULL_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
        + _tabl_rows(_TABL_W1A, temy=('DARK',))
        + _entry(pairs=('W1A_STALE', 'W1A_CURRENT'), temy=('DARK',))
        + ['MIGRACIYA_PORYADOK_SMENA_TEMY_DARK_TO_LIGHT'],
        [],
    ),
    # ---- 117 v3 круг 3 (арбитраж нарезки 117↔118): семь мутантов
    # критика r3 — именованные стабы на клетках (а)–(д); мутации
    # перенесены с драйвера критика (Critic117v3c/new_attack.py) по
    # смыслу на новую семантику модели. ----
    # (r3-extra-authenticated) постороннее truthy-поле порта
    # authenticated=true заменяет пару admission/gate — наблюдаем на
    # входе W0/stale с посторонним полем (поверхность у недопущенного).
    'migracija-postoronnee-pole-authenticated': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A') {",
          "    if (onboardingAdmission === 'W1A'\n"
          "        || (onboarding as { authenticated?: boolean } | undefined)"
          "?.authenticated === true) {")],
        _AUTH_POLE,
        [],
    ),
    # (r3-gate-from-entry) gate читается из entry.gate РАНЬШЕ сессии —
    # наблюдаем на entry-клетках W1A×stale (entry.gate='current' у
    # каждого входа оси не открывает Start, маркер остаётся сессионным).
    'migracija-gate-iz-entry': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingGate = onboarding?.gate ?? 'null';",
          "  const onboardingGate = (entry as { gate?: 'null' | 'stale' | 'current' }"
          " | undefined)?.gate\n"
          "    ?? onboarding?.gate ?? 'null';")],
        _entry(pairs=('W1A_STALE',)),
        [],
    ),
    # (r3-admission-literal-completed) литерал W1A при completed-entry —
    # entry-клетки complete на не-W1A парах (включая порт не подключён).
    'migracija-literal-completed': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = entry?.onboarding === 'complete'\n"
          "    ? 'W1A' : onboarding?.admission ?? 'W0';")],
        _entry(('COMPLETE',), ('W0_STALE', 'W0_CURRENT', 'NEPODKLYUCHEN')),
        [],
    ),
    # (r3-cached-admission) admission кэшируется useMemo — порт не
    # читается в момент действия: rerender W1A→W0 до демо.
    'migracija-kesh-dopuska': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = useMemo(() => onboarding?.admission ?? 'W0', []);")],
        _RERENDER,
        [],
    ),
    # (r3-restart-completed-start) начальный кадр Start при сохранённом
    # entry.onboarding='complete' — первый рендер и remount.
    'migracija-restart-start': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const [frame, setFrame] = useState<Frame>('first-run');",
          "  const [frame, setFrame] = useState<Frame>(entry?.onboarding === 'complete'"
          " ? 'start' : 'first-run');")],
        _nachalnyj(('COMPLETE',)) + _REMOUNT
        # круг 3 (замер): entry-клетки оси с COMPLETE тоже ждут
        # first-run на первом рендере — стартовый Start красен и там.
        + _entry(('COMPLETE',)),
        [],
    ),
    # (r3-g0-theme-change) рестайл корня после смены схемы при
    # подключённом порте — Г0 F03.01/F03.02 до и после смены, обе стороны.
    'migracija-g0-smena-temy': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const [frame, setFrame] = useState<Frame>('first-run');",
          "  const initialScheme = useRef(scheme);\n"
          "  const [frame, setFrame] = useState<Frame>('first-run');"),
         ('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding && initialScheme.current !== scheme\n"
          "            ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0,"
          " paddingBottom: 0 }\n"
          "            : null]\n")],
        _G0_SMENA,
        [],
    ),
    # (r3-order-theme-autostart) смена схемы на Erstinformation сама
    # переводит в Start без continue — порядок на живом экземпляре.
    'migracija-start-ot-smeny-temy': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const [frame, setFrame] = useState<Frame>('first-run');",
          "  const initialScheme = useRef(scheme);\n"
          "  const [frame, setFrame] = useState<Frame>('first-run');"),
         ('mobile/src/bootstrap/pilot-app.tsx',
          "  const [splashVisible, setSplashVisible] = useState(true);",
          "  const [splashVisible, setSplashVisible] = useState(true);\n"
          "  useEffect(() => {\n"
          "    if (frame === 'erstinformation' && initialScheme.current !== scheme) {\n"
          "      setFrame('start');\n"
          "    }\n"
          "  }, [frame, scheme]);")],
        _PORYADOK,
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
    # --only: срез матрицы (длинный замер исполняют слайсами в переднем
    # плане; объединение срезов покрывает все стабы MUTANTS — приёмка).
    ap.add_argument('--only', default=None,
                    help='имена стабов через запятую (срез --matrix)')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()

    if args.matrix:
        only = [n.strip() for n in args.only.split(',') if n.strip()] if args.only else None
        return matrix(repo, only)


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


def matrix(repo: Path, only=None):
    honest = run_suite(repo, model_bytes())
    if honest is None:
        return 2
    if not honest or any(status != 'passed' for status in honest.values()):
        print('MUTATION_MATRIX_HONEST_NOT_GREEN', {case_name(k): v for k, v in honest.items()})
        return 2
    print('honest green', len(honest))
    if only is not None:
        unknown = [n for n in only if n not in MUTANTS]
        if unknown:
            print('MATRIX_ONLY_UNKNOWN', unknown)
            return 2
        print('matrix slice', len(only), 'of', len(MUTANTS))
    ok = True
    for name, (mutations, named, depends) in MUTANTS.items():
        if only is not None and name not in only:
            continue
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
