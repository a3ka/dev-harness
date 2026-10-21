#!/usr/bin/env python3
"""Поведенческая проба 117 круг 5 (CMP-MOB-006): вход F03.01/F03.02 —
состав по UX-JSON F01/F03 + каталогу, компоненты продукта на токенах
D2.2.5.1 (@/ui/button, @/ui/text-field), рестайл-гварды 995; JS-ОВЕРЛЕЙ
splash (арбитраж круга 2, С2): смонтирован, Image оверлея = модуль
композита своей схемы (С2-а), без Text-узлов, commit-журнал prevent →
первый commit с оверлеем → hide (С2-б), автоскрытие таймером-литералом.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево — именованный отказ rc1
VKHOD_AUTH_DS_ABSENT (кадры входа не собраны из @/ui/button,
@/ui/text-field — до-предметная поверхность 995).
С --model: эталон architect ставится по путям поставки, rc0 с перечнем
(число клеток — из прогона; круг 5: 12 прежних + 10 оверлея; круг 6 —
Р1 PROD_ENTRY_OS_THEME (production-вход @/app/index без Provider, схема
ОС моком Appearance), Р4 AUTH_FRAMES_SAFE_AREA, Р6 SPLASH_OVERLAY_CONTAIN;
круг 7 — В2-2 STATUS_BAR_STYLE (эффективный стиль статус-бара, дошедший
до ОС, контрастен ground схемы); 117 v2 — First-Run по First-Run.png:
FIRST_RUN_{TOP,WORDMARK,SIGN,SUBLINE,CTA_BOTTOM,TAGLINE} (конструкция
раскладки артборда по эффективному стилю цепи host-узлов и порядку
документа) и ссылки F03.02 цветом accent-text схемы в
AUTH_F03_02_STRUCTURE; каждая × 2 схемы).
--matrix: каждый обманный стаб красен на объявленных ветвях
(named ∪ depends); краснота вне объявления — дефект матрицы rc2.
Выход — только код возврата; список case построчно (красные — RED).
"""
import argparse
from pathlib import Path
import sys

from probe_lib import (
    FAMILY_PREFIX, HERE, TEST_INSTALL,
    installed, jest_ready, model_bytes, run_jest,
)

NAMED_RED = 'VKHOD_AUTH_DS_ABSENT'

# Привязка стаб↔ветвь живёт только здесь (Н-39): name → (mutations, named, depends).
MUTANTS = {
    # (е) экраны входа остаются поверхностью 995 (белый корень 48/16/16).
    'auth-stays-995': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const isD22Frame = frame === 'first-run' || frame === 'email' || frame === 'code';",
          "  const isD22Frame = frame === 'first-run';")],
        ['AUTH_F03_01_STRUCTURE_DARK', 'AUTH_F03_01_STRUCTURE_LIGHT',
         'AUTH_F03_02_STRUCTURE_DARK', 'AUTH_F03_02_STRUCTURE_LIGHT'],
        ['AUTH_FRAMES_SAFE_AREA_DARK', 'AUTH_FRAMES_SAFE_AREA_LIGHT',
         'PROD_ENTRY_OS_THEME_DARK', 'PROD_ENTRY_OS_THEME_LIGHT'],
    ),
    # (е) вход в светлой схеме на тёмном ground (тема не проводится).
    'auth-light-dark-ground': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'backgroundColor: tokens.ground,\n'
          "              paddingTop: frame === 'first-run' ? 0 : insets.top,",
          "backgroundColor: scheme === 'light' ? '#0a0a0a' : tokens.ground,\n"
          "              paddingTop: frame === 'first-run' ? 0 : insets.top,")],
        ['AUTH_F03_01_STRUCTURE_LIGHT', 'AUTH_F03_02_STRUCTURE_LIGHT'],
        ['PROD_ENTRY_OS_THEME_LIGHT'],
    ),
    # (е) заголовки входа типографикой 995 (22/600), не .title D2.2.5.1.
    'auth-title-995-typo': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "const D22_TITLE = {\n  fontSize: 28,\n  fontWeight: '500',\n  lineHeight: 32,\n} as const;",
          "const D22_TITLE = {\n  fontSize: 22,\n  fontWeight: '600',\n  lineHeight: 26,\n} as const;")],
        ['AUTH_F03_01_STRUCTURE_DARK', 'AUTH_F03_01_STRUCTURE_LIGHT',
         'AUTH_F03_02_STRUCTURE_DARK', 'AUTH_F03_02_STRUCTURE_LIGHT'],
        [],
    ),
    # (е) основная кнопка F03.02 возвращена к 995: чёрная inline-пилюля
    # (#111111/#FFFFFF) вместо компонента Button на primary схемы.
    'verify-button-995-black': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "      <Button\n"
          "        testID=\"auth-verify\"\n"
          "        variant=\"primary\"\n"
          "        label={COPY['action.F03.A01']}\n"
          "        onPress={onVerify}\n"
          "      />",
          "      <Pressable testID=\"auth-verify\" accessibilityRole=\"button\" onPress={onVerify}>\n"
          "        <Text style={{ backgroundColor: '#111111', color: '#FFFFFF' }}>{COPY['action.F03.A01']}</Text>\n"
          "      </Pressable>")],
        ['AUTH_F03_02_STRUCTURE_DARK', 'AUTH_F03_02_STRUCTURE_LIGHT'],
        [],
    ),
    # рестайл-гварды 995: welcome тоже перекрашен в ground.
    'restyle-welcome-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const isD22Frame = frame === 'first-run' || frame === 'email' || frame === 'code';",
          "  const isD22Frame =\n    frame === 'first-run' || frame === 'email' || frame === 'code'\n    || frame === 'welcome';")],
        ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT'],
        [],
    ),
    # рестайл-гвард 995: recovery (F03.04) тоже перекрашен — владелец не называл.
    'restyle-recovery-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const isD22Frame = frame === 'first-run' || frame === 'email' || frame === 'code';",
          "  const isD22Frame =\n    frame === 'first-run' || frame === 'email' || frame === 'code'\n    || frame === 'recovery';")],
        ['RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT'],
        [],
    ),
    # (Б4, круг 2) обход критика: isD22Frame добавляет unavailable —
    # чужой кадр получает full-bleed ground.
    'restyle-unavailable-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const isD22Frame = frame === 'first-run' || frame === 'email' || frame === 'code';",
          "  const isD22Frame =\n    frame === 'first-run' || frame === 'email' || frame === 'code'\n    || frame === 'unavailable';")],
        ['RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
        [],
    ),
    # (Б4, круг 2) обход критика: isD22Frame добавляет recovery в светлой
    # схеме (тёмная — наблюдаемый сосед — не тронута).
    'restyle-recovery-light-vkhod': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "  const isD22Frame = frame === 'first-run' || frame === 'email' || frame === 'code';",
          "  const isD22Frame =\n    frame === 'first-run' || frame === 'email' || frame === 'code'\n    || (frame === 'recovery' && tokens.ground === '#f3f2ee');")],
        ['RESTYLE_GUARD_995_RECOVERY_LIGHT'],
        [],
    ),
    # (Б3, круг 2) обход критика: кадры входа вынесены за окно
    # (translateX 1000 на корнях EmailFrame/CodeFrame).
    'auth-frame-offscreen': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "function EmailFrame({ email, onEmailChange, onDemoEntry }: EmailFrameProps) {\n"
          "  const { tokens } = useTheme();\n"
          "  return (\n"
          "    <View>",
          "function EmailFrame({ email, onEmailChange, onDemoEntry }: EmailFrameProps) {\n"
          "  const { tokens } = useTheme();\n"
          "  return (\n"
          "    <View style={{ transform: [{ translateX: 1000 }] }}>"),
         ('mobile/src/features/auth/auth-screen.tsx',
          "  const showCooldown = waitSeconds !== undefined;\n"
          "  return (\n"
          "    <View>",
          "  const showCooldown = waitSeconds !== undefined;\n"
          "  return (\n"
          "    <View style={{ transform: [{ translateX: 1000 }] }}>")],
        ['AUTH_FRAMES_IN_WINDOW_DARK', 'AUTH_FRAMES_IN_WINDOW_LIGHT'],
        [],
    ),
    # (Б3, круг 2) обход критика: ссылки цветом фона (ground вместо accent),
    # имя токена оставлено в комментарии.
    'auth-links-ground': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "      <Pressable testID=\"auth-resend\" accessibilityRole=\"button\" onPress={onResend}>\n"
          "        <Text style={[styles.linkText, { color: tokens['accent-text'] }]}>",
          "      <Pressable testID=\"auth-resend\" accessibilityRole=\"button\" onPress={onResend}>\n"
          "        <Text style={[styles.linkText, { color: tokens.ground }]}>")],
        ['AUTH_F03_02_STRUCTURE_DARK', 'AUTH_F03_02_STRUCTURE_LIGHT'],
        [],
    ),
    # (круг 3, слово владельца ~19:28) состав по UX-JSON: body-ключи кадров
    # (подписи полей) выброшены — состав не полный (ВСЕ элементы, не выборка).
    'auth-body-missing': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "        label={COPY['frame.F03.01.body']}",
          '        label=""'),
         ('mobile/src/features/auth/auth-screen.tsx',
          "        label={COPY['frame.F03.02.body']}",
          '        label=""')],
        ['AUTH_F03_01_STRUCTURE_DARK', 'AUTH_F03_01_STRUCTURE_LIGHT',
         'AUTH_F03_02_STRUCTURE_DARK', 'AUTH_F03_02_STRUCTURE_LIGHT'],
        [],
    ),
    # (круг 3, слово владельца ~19:28) поле F03.01 — ручной TextInput с
    # квадратными углами на тех же токенах вместо компонента TextField.
    'auth-field-hand-styled': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "import { Pressable, StyleSheet, Text, View } from 'react-native';",
          "import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';"),
         ('mobile/src/features/auth/auth-screen.tsx',
          "      <TextField\n"
          "        testID={EMAIL_TEST_ID}\n"
          "        label={COPY['frame.F03.01.body']}\n"
          "        value={email}\n"
          "        onChangeText={onEmailChange}\n"
          "      />",
          "      <TextInput\n"
          "        testID={EMAIL_TEST_ID}\n"
          "        value={email}\n"
          "        onChangeText={onEmailChange}\n"
          "        style={{ borderRadius: 4, backgroundColor: tokens.panel, color: tokens.ink }}\n"
          "      />")],
        ['AUTH_F03_01_STRUCTURE_DARK', 'AUTH_F03_01_STRUCTURE_LIGHT'],
        [],
    ),
    # (круг 3, слово владельца ~19:28) ручные стили с теми же hex вместо
    # реального компонента DS: CTA F03.01 — inline Pressable/Text (того же
    # цвета), компонент Button не используется.
    'auth-button-inline': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "      <Button\n"
          "        testID=\"auth-demo-entry\"\n"
          "        variant=\"primary\"\n"
          "        label={COPY['ui.auth.demo_entry']}\n"
          "        onPress={onDemoEntry}\n"
          "      />",
          "      <Pressable testID=\"auth-demo-entry\" accessibilityRole=\"button\" onPress={onDemoEntry}>\n"
          "        <Text style={{ backgroundColor: '#d6f75a', color: '#121211' }}>{COPY['ui.auth.demo_entry']}</Text>\n"
          "      </Pressable>")],
        ['AUTH_F03_01_STRUCTURE_DARK', 'AUTH_F03_01_STRUCTURE_LIGHT'],
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
         'PROD_ENTRY_OS_THEME_DARK', 'PROD_ENTRY_OS_THEME_LIGHT'],
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
        ['AUTH_F03_01_STRUCTURE_DARK', 'AUTH_F03_02_STRUCTURE_DARK',
         'SPLASH_OVERLAY_COMPOSITE_DARK', 'SPLASH_OVERLAY_MOUNTED_DARK',
         'STATUS_BAR_STYLE_DARK',
         # 117 v2: палитра light в тёмной клетке First-Run (знак, wordmark,
         # подзаголовок, CTA, футер) — измерено матрицей v2.
         'FIRST_RUN_CTA_BOTTOM_DARK', 'FIRST_RUN_SIGN_DARK', 'FIRST_RUN_SUBLINE_DARK',
         'FIRST_RUN_TAGLINE_DARK', 'FIRST_RUN_WORDMARK_DARK'],
    ),
    # (Р4, круг 6, Rev117) safe-area снята: контент в статус-баре,
    # колонка прижата к краю (форма текущего C).
    'auth-frames-no-inset': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "              paddingTop: frame === 'first-run' ? 0 : insets.top,\n"
          "              paddingHorizontal: frame === 'first-run' ? 0 : 16,",
          '              paddingTop: 0,\n              paddingHorizontal: 0,')],
        ['AUTH_FRAMES_SAFE_AREA_DARK', 'AUTH_FRAMES_SAFE_AREA_LIGHT'],
        [],
    ),
    # (Р4) хардкод инссета 47 (не отслеживает insets.top; клетка даёт 59).
    'auth-frames-inset-hardcode': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "              paddingTop: frame === 'first-run' ? 0 : insets.top,",
          "              paddingTop: frame === 'first-run' ? 0 : 47,")],
        ['AUTH_FRAMES_SAFE_AREA_DARK', 'AUTH_FRAMES_SAFE_AREA_LIGHT'],
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
    # ---- 117 v2: First-Run по First-Run.png; ссылки F03.02 accent-text ----
    # (FR-1) Demo-бейдж в потоке корня на first-run (форма C 58d60b8):
    # кадр First-Run сдвинут вниз на инсет+бейдж (wordmark y≈165 dp на C).
    'first-run-badge-in-flow': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "? { left: 0, paddingTop: insets.top, position: 'absolute', top: 0, zIndex: 1 }",
          '? { paddingTop: insets.top }')],
        ['FIRST_RUN_TOP_DARK', 'FIRST_RUN_TOP_LIGHT'],
        [],
    ),
    # (FR-1) верхний блок с отступом поверхности 995 (48), не артборда (20).
    'first-run-top-pad-48': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '    minHeight: 60,\n    paddingHorizontal: 16,\n    paddingTop: 20,\n',
          '    minHeight: 60,\n    paddingHorizontal: 16,\n    paddingTop: 48,\n')],
        ['FIRST_RUN_TOP_DARK', 'FIRST_RUN_TOP_LIGHT'],
        [],
    ),
    # (FR-2) wordmark прижат к левому краю (форма C: x=0).
    'first-run-wordmark-left': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          "  top: {\n    alignItems: 'center',\n", '  top: {\n')],
        ['FIRST_RUN_WORDMARK_DARK', 'FIRST_RUN_WORDMARK_LIGHT'],
        [],
    ),
    # (FR-2) wordmark без перекраски: растр wordmark-dark.png (#f2f1ec) — в
    # dark честен, в light на #f3f2ee 1,01:1 (форма C). Наблюдаем ТОЛЬКО light.
    'first-run-wordmark-untinted': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'style={[styles.wordmark, { tintColor: tokens.ink }]}', 'style={styles.wordmark}')],
        ['FIRST_RUN_WORDMARK_LIGHT'],
        [],
    ),
    # (FR-3) знака нет (форма C).
    'first-run-sign-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <View style={styles.presence}>\n'
          '        <Image\n'
          '          accessibilityElementsHidden\n'
          '          importantForAccessibility="no"\n'
          '          source={SIGN[scheme]}\n'
          '          style={styles.sign}\n'
          '          testID="first-run-sign"\n'
          '        />\n'
          '      </View>\n', '')],
        ['FIRST_RUN_SIGN_DARK', 'FIRST_RUN_SIGN_LIGHT'],
        [],
    ),
    # (FR-3) знак тёмной схемы в обеих (ink #f2f1ec на светлом ground) —
    # наблюдаем ТОЛЬКО light.
    'first-run-sign-dark-only': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'source={SIGN[scheme]}', 'source={SIGN.dark}')],
        ['FIRST_RUN_SIGN_LIGHT'],
        [],
    ),
    # (FR-3) знак иконочного размера (56) вместо знака артборда 181×173.
    'first-run-sign-small': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'sign: { height: 173, width: 181 }', 'sign: { height: 54, width: 56 }')],
        ['FIRST_RUN_SIGN_DARK', 'FIRST_RUN_SIGN_LIGHT'],
        [],
    ),
    # (FR-4) подзаголовка нет (форма C).
    'first-run-subline-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '        <Text style={[styles.subline, { color: tokens[\'ink-muted\'] }]} testID="first-run-subline">\n'
          '          {FIRST_RUN_SUBLINE}\n'
          '        </Text>\n', '')],
        ['FIRST_RUN_SUBLINE_DARK', 'FIRST_RUN_SUBLINE_LIGHT'],
        [],
    ),
    # (FR-4) подзаголовок цветом заголовка (ink), не ink-muted.
    'first-run-subline-ink': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          "styles.subline, { color: tokens['ink-muted'] }", 'styles.subline, { color: tokens.ink }')],
        ['FIRST_RUN_SUBLINE_DARK', 'FIRST_RUN_SUBLINE_LIGHT'],
        [],
    ),
    # (FR-4) ink-muted тёмной схемы hex-литералом в обеих — наблюдаем light
    # (статическая FIRST_RUN_TOKENIZED судит hex своей семьёй).
    'first-run-subline-dark-hex': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          "styles.subline, { color: tokens['ink-muted'] }", "styles.subline, { color: '#a6a69f' }")],
        ['FIRST_RUN_SUBLINE_LIGHT'],
        [],
    ),
    # (FR-5) CTA по контенту (Button без block — форма C).
    'first-run-cta-content-width': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '        <Button\n          block\n', '        <Button\n')],
        ['FIRST_RUN_CTA_BOTTOM_DARK', 'FIRST_RUN_CTA_BOTTOM_LIGHT'],
        [],
    ),
    # (FR-5) CTA вплотную под заголовком: свободное место не перед блоком
    # действий (форма C).
    'first-run-cta-under-title': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '  work: {\n    flex: 1,\n', '  work: {\n')],
        ['FIRST_RUN_CTA_BOTTOM_DARK', 'FIRST_RUN_CTA_BOTTOM_LIGHT'],
        [],
    ),
    # (FR-5) CTA высоты md (≈45 dp на C), не size-lg 56.
    'first-run-cta-md': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '          size="lg"\n', '')],
        ['FIRST_RUN_CTA_BOTTOM_DARK', 'FIRST_RUN_CTA_BOTTOM_LIGHT'],
        [],
    ),
    # (FR-6) футера нет (форма C).
    'first-run-tagline-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '        <Text style={[styles.tagline, { color: tokens[\'ink-muted\'] }]} testID="first-run-tagline">\n'
          '          {BRAND_TAGLINE}\n'
          '        </Text>\n', '')],
        ['FIRST_RUN_TAGLINE_DARK', 'FIRST_RUN_TAGLINE_LIGHT'],
        [],
    ),
    # (FR-6) футер над CTA.
    'first-run-tagline-above-cta': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <View style={styles.actions}>\n'
          '        <Button\n',
          '      <View style={styles.actions}>\n'
          '        <Text style={[styles.tagline, { color: tokens[\'ink-muted\'] }]}>{BRAND_TAGLINE}</Text>\n'
          '        <Button\n'),
         ('mobile/src/features/auth/first-run-screen.tsx',
          '        <Text style={[styles.tagline, { color: tokens[\'ink-muted\'] }]} testID="first-run-tagline">\n'
          '          {BRAND_TAGLINE}\n'
          '        </Text>\n', '')],
        ['FIRST_RUN_TAGLINE_DARK', 'FIRST_RUN_TAGLINE_LIGHT'],
        [],
    ),
    # (инв. 6 v2, В2-3) ссылки F03.02 лаймом accent в обеих схемах (форма C):
    # в dark accent == accent-text — наблюдаем ТОЛЬКО light (1,08:1).
    'links-accent-both': (
        [('mobile/src/features/auth/auth-screen.tsx',
          "{ color: tokens['accent-text'] }]}>{COPY['ui.auth.code_resend']}",
          "{ color: tokens.accent }]}>{COPY['ui.auth.code_resend']}"),
         ('mobile/src/features/auth/auth-screen.tsx',
          "{ color: tokens['accent-text'] }]}>{COPY['auth.change_email']}",
          "{ color: tokens.accent }]}>{COPY['auth.change_email']}"),
         ('mobile/src/features/auth/auth-screen.tsx',
          "{ color: tokens['accent-text'] }]}>{COPY['action.F03.A02']}",
          "{ color: tokens.accent }]}>{COPY['action.F03.A02']}")],
        ['AUTH_F03_02_STRUCTURE_LIGHT'],
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

    auth = repo / 'mobile/src/features/auth/auth-screen.tsx'
    if not args.model and "from '@/ui/text-field'" not in auth.read_text(encoding='utf-8'):
        print(NAMED_RED)
        return 1

    blobs = model_bytes() if args.model else None
    cases = run_suite(repo, blobs)
    if cases is None:
        return 2
    if not cases:
        print('NO_TEST_RESULTS')
        return 2
    failed = [name for name, status in cases.items() if status != 'passed']
    for name, status in cases.items():
        print('case' if status == 'passed' else 'RED', case_name(name))
    if failed:
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
