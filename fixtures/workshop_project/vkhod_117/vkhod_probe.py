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
судят допуск демо-маршрута First-Run → demo → Erstinformation → Start в
pilot-app — ТОЛЬКО при admission 'W1A' из сессии ∧ gate 'current'; без
допуска — прежний путь B (F03, Г0). Допуск приходит портом onboarding
(внешняя сессия), не литералом.

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
        # безусловен — красна КАЖДАЯ строка таблицы × обе темы (52).
        + _tabl_rows(_TABL_ROWS),
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
         'MIGRACIYA_G0_F03_ONBOARDING_LIGHT']
        # правка FAIL v3 круг 2 (таблица входов): код-кадр судится в
        # светлой теме на КАЖДОЙ строке недопуска (Г0 после демо-входа).
        + _tabl_rows(_TABL_NEDOPUSK, temy=('LIGHT',)),
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
    # ---- 117 v3 (миграция 117/3): обманные стабы допуска маршрута ----
    # «admission обходится»: pilot-app несёт литерал допуска W1A (порт
    # сессии проигнорирован) — W0×current уходит в Erstinformation.
    'migracija-admission-literal': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = 'W1A';")],
        ['MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT',
         # правка FAIL v3 (замер матрицы): литерал допуска наблюдаем и на
         # входе ОТСУТСТВУЮЩЕГО admission (тот же дефект, новый вход).
         'MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов): литерал допускает любой
        # вход с gate='current' — строки CHAST/OTSUT/CURRENT и POLNYJ с
        # admission {W0, NULL, NEIZVESTNOE} × CURRENT (замер матрицы).
        + _tabl_rows([('CHASTICHNYJ', 'OTSUT', 'CURRENT'), ('POLNYJ', 'W0', 'CURRENT'),
                      ('POLNYJ', 'NULL', 'CURRENT'), ('POLNYJ', 'NEIZVESTNOE', 'CURRENT')]),
        # Побочная краснота (замер матрицы): недопущенные Г0-клетки
        # ONBOARDING красны — демо-вход уводится в Erstinformation,
        # код-кадр не возникает.
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT'],
    ),
    # «current не проверяется»: допуск по одному admission — W1A×null и
    # W1A×stale уходят в Erstinformation, Start приоткрыт.
    'migracija-gate-ignor': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A') {")],
        ['MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_PREZHNIJ_PUT',
         # правка FAIL v3 (замер матрицы): тот же дефект на новых входах —
         # отсутствующий gate и stale в светлой теме.
         'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов): admission без gate —
        # строки W1A с gate {OTSUT, STALE, NULL, NEIZVESTNOE} (замер).
        + _tabl_rows([('CHASTICHNYJ', 'W1A', 'OTSUT'), ('POLNYJ', 'W1A', 'STALE'),
                      ('POLNYJ', 'W1A', 'NULL'), ('POLNYJ', 'W1A', 'NEIZVESTNOE')]),
        [],
    ),
    # «порядок маршрута сломан»: демо-вход сразу в Start, минуя
    # Erstinformation (continue-шаг отсутствует).
    'migracija-start-pryamo': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      setFrame('erstinformation');\n      return;",
          "      setFrame('start');\n      return;")],
        ['MIGRACIYA_W1A_CURRENT_MARSHRUT',
         # правка FAIL v3 (замер матрицы): порядок сломан и в светлой
         # теме — маршрутная клетка светлого входа красна той же
         # причиной (Start раньше Erstinformation).
         'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
        # правка FAIL v3 круг 2 (таблица входов): обе строки допуска
        # таблицы (POLNYJ/W1A/CURRENT × темы) требуют Erstinformation
        # ДО Start (замер матрицы).
        + _tabl_rows(_TABL_DOPUSK),
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
        # Побочная краснота (замер матрицы v3): прежний путь удалён — кадры
        # email/code/welcome/recovery/unavailable недостижимы, гварды Г0–Г3
        # падают по той же причине (depends, не named).
        ['RESTYLE_GUARD_995_F03_DARK', 'RESTYLE_GUARD_995_F03_LIGHT',
         'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT',
         # правка FAIL v3 (замер матрицы): прежний путь удалён — ВСЕ
         # новые миграционные клетки падают по той же причине
         # (first-run-continue ведёт в Erstinformation, auth-email
         # недостижим).
         'MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT',
         'MIGRACIYA_W0_STALE_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT',
         'MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT',
         'MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT',
         'MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT']
        # правка FAIL v3 круг 2 (таблица входов): прежний путь удалён —
        # ВСЕ 52 клетки таблицы красны той же причиной (auth-email
        # недостижим после First-Run) — depends, не named.
        + _tabl_rows(_TABL_ROWS),
    ),
    # ---- 117 v3 правка по FAIL критика v3: мутанты допуска и Г0 ----
    # (критик v3, обход «умолчание admission») литерал W1A вместо W0:
    # сессия {gate:'current'} без admission уходит в Erstinformation —
    # наблюдаем на входе ОТСУТСТВУЮЩЕГО admission.
    'migracija-admission-default': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = onboarding?.admission ?? 'W1A';")],
        ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов): `?? 'W1A'` заменяет и
        # undefined, и null — строки OTSUT/CURRENT и NULL/CURRENT (замер).
        + _tabl_rows([('CHASTICHNYJ', 'OTSUT', 'CURRENT'), ('POLNYJ', 'NULL', 'CURRENT')]),
        [],
    ),
    # (критик v3, обход «умолчание gate») литерал current вместо null:
    # сессия {admission:'W1A'} без gate допущена — наблюдаем на входе
    # ОТСУТСТВУЮЩЕГО gate.
    'migracija-gate-default': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingGate = onboarding?.gate ?? 'null';",
          "  const onboardingGate = onboarding?.gate ?? 'current';")],
        ['MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов): `?? 'current'` заменяет
        # и отсутствующий, и null gate — строки W1A/{OTSUT,NULL} (замер).
        + _tabl_rows([('CHASTICHNYJ', 'W1A', 'OTSUT'), ('POLNYJ', 'W1A', 'NULL')]),
        [],
    ),
    # (критик v3, обход «W0×stale») полностью заданные поля, но сочетание
    # W0×stale тоже допущено — наблюдаем на входе W0×stale.
    'migracija-w0-stale-dopushchen': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if ((onboardingAdmission === 'W1A' && onboardingGate === 'current')"
          " || (onboardingAdmission === 'W0' && onboardingGate === 'stale')) {")],
        ['MIGRACIYA_W0_STALE_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов, замер матрицы): `?? 'W0'`
        # заменяет и null admission, умолчание gate='null' не current —
        # W0×stale наблюдаем на строках {POLNYJ/W0/STALE,
        # CHASTICHNYJ/OTSUT/STALE, POLNYJ/NULL/STALE} × обе темы.
        + _tabl_rows([('POLNYJ', 'W0', 'STALE'), ('CHASTICHNYJ', 'OTSUT', 'STALE'),
                      ('POLNYJ', 'NULL', 'STALE')]),
        [],
    ),
    # (критик v3, обход «светлая тема») светлая схема сама себе допуск:
    # любой недопущенный onboarding в light уходит в Erstinformation —
    # наблюдаем на светлых недопущенных входах; побочно (замер матрицы)
    # красна Г0-клетка ONBOARDING_LIGHT: демо уходит мимо код-кадра.
    'migracija-svetlui-obhod': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if ((onboardingAdmission === 'W1A' && onboardingGate === 'current')"
          " || (onboarding && scheme === 'light')) {")],
        ['MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT',
         'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов): светлая тема допускает
        # ЛЮБОЙ truthy порт — все truthy-строки недопуска таблицы в
        # светлой теме (NEPODKLYUCHEN не truthy; строка допуска честна).
        + _tabl_rows([r for r in _TABL_NEDOPUSK if r[0] != 'NEPODKLYUCHEN'],
                     temy=('LIGHT',)),
        ['MIGRACIYA_G0_F03_ONBOARDING_LIGHT'],
    ),
    # (критик v3, блокер 2) подключённый onboarding рестайлит корень F03:
    # чёрный фон и нулевые отступы вместо #FFFFFF/48/16/16 — наблюдаем
    # Г0-клетками ONBOARDING_{DARK,LIGHT}; побочно (замер матрицы) красны
    # Г0-клетки DOPUSK_{DARK,LIGHT}: рестейл при любом truthy порте.
    'migracija-onboarding-restyles-f03': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding ? { backgroundColor: '#000000',"
          " paddingTop: 0, paddingHorizontal: 0, paddingBottom: 0 } : null]\n")],
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT']
        # правка FAIL v3 круг 2 (таблица входов): рестайл при любом truthy
        # порте — ВСЕ truthy-строки таблицы × обе темы (50; замер).
        + _tabl_rows(_TABL_TRUTHY),
        ['MIGRACIYA_G0_F03_DOPUSK_DARK', 'MIGRACIYA_G0_F03_DOPUSK_LIGHT'],
    ),
    # (свой 1) маршрут допуска открыт только в тёмной теме — наблюдаем
    # на светлом входе W1A×current (маршрутная клетка светлой темы).
    'migracija-marshrut-tolko-temnyi': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current'"
          " && scheme === 'dark') {")],
        ['MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
        # правка FAIL v3 круг 2 (таблица входов): строка допуска таблицы
        # в светлой теме (POLNYJ/W1A/CURRENT/LIGHT) красна (замер).
        + _tabl('POLNYJ', 'W1A', 'CURRENT', temy=('LIGHT',)),
        [],
    ),
    # (свой 2) stale принят как current — наблюдаем на обоих stale-входах
    # (тёмная клетка 117/2 + светлая клетка правки).
    'migracija-stale-kak-current': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && (onboardingGate === 'current'"
          " || onboardingGate === 'stale')) {")],
        ['MIGRACIYA_W1A_STALE_PREZHNIJ_PUT', 'MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        # правка FAIL v3 круг 2 (таблица входов): строки POLNYJ/W1A/STALE
        # × обе темы (замер матрицы).
        + _tabl('POLNYJ', 'W1A', 'STALE'),
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
        # правка FAIL v3 круг 2 (таблица входов): строки допуска таблицы
        # × обе темы — Г0 на кадре email до демо-входа (замер).
        + _tabl_rows(_TABL_DOPUSK),
        [],
    ),
    # ---- 117 v3 правка по FAIL критика КРУГ 2: пять мутантов критика
    # (attack.py кругов 1–2; три были ЗЕЛЁНЫ на прежней батарее —
    # new-light-gate-default, new-empty-session-demo,
    # new-g0-denied-admission) + пять собственных. Все привязки —
    # клетки таблицы входов на входах, где дефект НАБЛЮДАЕМ (Н-39). ----
    # (критик круг 2, блокер 1) умолчание отсутствующего gate — current
    # только в светлой теме: {admission:'W1A'} без gate допущено в light.
    'migracija-light-gate-default': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingGate = onboarding?.gate ?? 'null';",
          "  const onboardingGate = onboarding?.gate ?? (scheme === 'light' ? 'current' : 'null');")],
        _tabl_rows([('CHASTICHNYJ', 'W1A', 'OTSUT'), ('POLNYJ', 'W1A', 'NULL')],
                   temy=('LIGHT',)),
        [],
    ),
    # (критик круг 2) stale равен current в светлой теме.
    'migracija-light-stale-current': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && (onboardingGate === 'current'"
          " || (scheme === 'light' && onboardingGate === 'stale'))) {")],
        ['MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT']
        + _tabl('POLNYJ', 'W1A', 'STALE', temy=('LIGHT',)),
        [],
    ),
    # (критик круг 2, блокер 1) ПУСТОЙ подключённый порт {} — сам себе
    # допуск: истина порта ≠ допуску, absence-полей недостаточно.
    'migracija-pustaya-sessiya-demo': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if ((onboardingAdmission === 'W1A' && onboardingGate === 'current')"
          " || (onboarding && onboarding.admission === undefined"
          " && onboarding.gate === undefined)) {")],
        _tabl('PUSTOJ', 'OTSUT', 'OTSUT'),
        [],
    ),
    # (критик круг 2, блокер 2) корень F03 рестайлится при подключённом
    # порте с ОТКЛОНЁННЫМ gate (не только admission): #000000/0 вместо
    # #FFFFFF/48 — все truthy-строки с gate ≠ current, обе темы.
    'migracija-g0-nedopusk-restail': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding && onboardingGate !== 'current'"
          " ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0,"
          " paddingBottom: 0 } : null]\n")],
        _tabl_rows([r for r in _TABL_TRUTHY if r[2] != 'CURRENT']),
        [],
    ),
    # (критик круг 2) Start мимо Erstinformation в светлой теме.
    'migracija-light-start-do-continue': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      setFrame('erstinformation');\n      return;",
          "      setFrame(scheme === 'light' ? 'start' : 'erstinformation');\n      return;")],
        ['MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT']
        + _tabl('POLNYJ', 'W1A', 'CURRENT', temy=('LIGHT',)),
        [],
    ),
    # (свой 4) null gate принят как current — строки POLNYJ/W1A/NULL.
    'migracija-null-kak-current': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "    if (onboardingAdmission === 'W1A' && onboardingGate === 'current') {",
          "    if (onboardingAdmission === 'W1A' && (onboardingGate === 'current'"
          " || onboardingGate === 'null')) {")],
        ['MIGRACIYA_W1A_NULL_PREZHNIJ_PUT', 'MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT']
        # правка круга 2 (замер матрицы): литерал 'null' — и УМОЛЧАНИЕ
        # отсутствующего gate: красны POLNYJ/W1A/NULL ×2 и строка
        # CHASTICHNYJ/W1A/OTSUT ×2 (gate-умолчание = 'null').
        + _tabl('POLNYJ', 'W1A', 'NULL') + _tabl('CHASTICHNYJ', 'W1A', 'OTSUT'),
        [],
    ),
    # (свой 5) `||` в условии допуска: admission ИЛИ gate открывают
    # маршрут порознь — 8 строк таблицы (обе темы).
    'migracija-or-uslovie': (
        [('mobile/src/bootstrap/pilot-app.tsx',
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
                      ('POLNYJ', 'NULL', 'CURRENT'), ('POLNYJ', 'NEIZVESTNOE', 'CURRENT')]),
        ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT'],
    ),
    # (свой 6) сам ПОРТ — источник допуска: truthy порт без admission
    # даёт W1A (CHAST/OTSUT/CURRENT и POLNYJ/NULL/CURRENT).
    'migracija-port-est-dopusk': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const onboardingAdmission = onboarding?.admission ?? 'W0';",
          "  const onboardingAdmission = onboarding"
          " ? (onboarding.admission ?? 'W1A') : 'W0';")],
        ['MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT']
        + _tabl_rows([('CHASTICHNYJ', 'OTSUT', 'CURRENT'), ('POLNYJ', 'NULL', 'CURRENT')]),
        [],
    ),
    # (свой 7) Г0-рестайл при недопуске ПО ADMISSION (зеркало
    # g0-nedopusk-restail по другой оси): все truthy-строки с
    # admission ≠ W1A, обе темы (40 клеток).
    'migracija-g0-restail-nedopusk-admission': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '          : styles.root\n',
          "          : [styles.root, onboarding && onboardingAdmission !== 'W1A'"
          " ? { backgroundColor: '#000000', paddingTop: 0, paddingHorizontal: 0,"
          " paddingBottom: 0 } : null]\n")],
        _tabl_rows([r for r in _TABL_TRUTHY if r[1] != 'W1A'])
        + ['MIGRACIYA_G0_F03_ONBOARDING_DARK', 'MIGRACIYA_G0_F03_ONBOARDING_LIGHT'],
        [],
    ),
    # (свой 8) Start мимо Erstinformation в ТЁМНОЙ теме (зеркало
    # light-start-do-continue) — порядок маршрута в обеих темах.
    'migracija-temnyi-start-do-continue': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "      setFrame('erstinformation');\n      return;",
          "      setFrame(scheme === 'dark' ? 'start' : 'erstinformation');\n      return;")],
        ['MIGRACIYA_W1A_CURRENT_MARSHRUT']
        + _tabl('POLNYJ', 'W1A', 'CURRENT', temy=('DARK',)),
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
