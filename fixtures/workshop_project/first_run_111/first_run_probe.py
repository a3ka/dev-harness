#!/usr/bin/env python3
"""Поведенческая проба 111 (CMP-MOB-005): First-Run по D2.2.5.1.

Исполняет настоящий Jest/RNTL на disposable R и разбирает отчёт поимённо.
Без --model: до-предметное дерево — именованный отказ rc1 FIRST_RUN_SEAM_ABSENT.
С --model: эталон architect ставится по путям поставки, rc0 с перечнем
(включая пару К7 DEMO_BADGE_INSET: отступ Demo-бейджа отслеживает
литеральный top-инсет мока SafeAreaInsetsContext — R1, ревью круга 2;
и пары К8 RESTYLE_GUARD_995 v2 (сужение: слово владельца 2026-10-20
~18:00/18:18 UTC, консультант 19:20, форк n117-krug1-maket-i-111 (А)):
гвард держит кадры 995 КРОМЕ F03.01/F03.02 (email/code — их рестайл по
предмету 117, вход по D2.2.5.1); на защищаемых кадрах (welcome) корень
несёт литералы 995 #FFFFFF и 48/16/16; К8 F03_01 — НЕ-ожидание рестайла:
шов CTA→F03.01 в обеих схемах, стиль корня не сверяется; и пары К9
RESTYLE_GUARD_995_RECOVERY/UNAVAILABLE v2b — собственное наблюдение
поверхности unavailable/recovery (F03.04) по публичным портам PilotApp
(критик 111, круг 1, Б1): рестайл этих кадров красен, welcome-наблюдения
К8′ его не покрывают).
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
        # К8/К8′/К9 ходят в кадры 995 через CTA: сломанная навигация рвёт и
        # наблюдение рестайл-стража — зависимые красные (замер круга 4;
        # К9 — замер v2b).
        ['CTA_TEXT_EQUALS_FRAME_TITLE',
         'RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT',
         'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
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
        ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT'],
        # К7 (замер матрицей круга 3): бейджа нет на First-Run — inset-клетка
        # красна «Unable to find» вместе со структурой.
        ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT'],
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
         'CTA_TEXT_EQUALS_FRAME_TITLE',
         # К8/К8′/К9 ищут CTA по testID: переименование рвёт навигацию
         # (замер круга 4; К9 — замер v2b).
         'RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT',
         'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
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
        ['CTA_OPENS_F03_01_LIGHT'],
        # В светлой схеме CTA не навигирует — К8/К8′/К9 LIGHT не достигают
        # кадров 995 (замер круга 4; К9 — замер v2b).
        ['RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_LIGHT', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
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
    # B5: некаталожная немецкая строка на поверхности (обход «саблайна без
    # ключа каталога»; v4: «Versicherung. Erledigt.» вошла в каталог —
    # носитель обхода заменён на строку вне перечня) — видно, но вне
    # закрытого перечня копии; при двух строках макета v4 на экране
    # (модель) посторонняя строка по-прежнему красна — прежняя презентация.
    'extra-unreviewed-copy': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Button\n',
          '      <Text>Mehr erfahren</Text>\n      <Button\n')],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    # v4 «разрешено всё»: обманка «после v4 каталог открыт — сойдёт любая
    # строка, хоть сокращённая форма саблайна» (цитата прежнего исключения
    # контракта). Побайтово замкнутый перечень красит её в обеих схемах;
    # зеленела бы только allow-all/нечёткая сверка (префикс/нормализация).
    'copy-all-allowed': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Button\n',
          '      <Text>Ein Brief, ein Schaden…</Text>\n      <Button\n')],
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
    # B5r2: некаталожная строка на поверхности только в светлой схеме —
    # красна LIGHT-клеткой пары К5. v4: дословный саблайн критика вошёл в
    # каталог — носитель обхода заменён на байтовую near-miss футера
    # («Versicherung. Erledigt» без финальной точки): проходит только
    # allow-all/нормализующая сверка, побайтовый перечень красит.
    'light-extra-copy': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'const { tokens } = useTheme();',
          'const { tokens, scheme } = useTheme();'),
         ('mobile/src/features/auth/first-run-screen.tsx',
          '      <Button\n',
          "      {scheme === 'light' ? <Text>Versicherung. Erledigt</Text> : null}\n      <Button\n")],
        ['FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    # v4b (критик 111 v4 круг 1): замкнутость без наличия — ложное зелёное
    # (на копии продукта 135 сняты оба рендерящих узла — rc0 honest 23/23).
    # Удаление узла подзаголовка/футера модели (по одному и оба) красно
    # парой К5; прочие клетки эти узлы не наблюдают (CTA/wordmark/root
    # нетронуты). depends — замер полным прогоном.
    'subheadline-node-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Text style={[styles.maketLine, { color: tokens.ink }]} testID="first-run-subheadline">\n'
          '        {FIRST_RUN_SUBHEADLINE}\n'
          '      </Text>\n',
          '')],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    'footer-node-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Text style={[styles.maketFooter, { color: tokens.ink }]} testID="first-run-footer">\n'
          '        {FIRST_RUN_FOOTER}\n'
          '      </Text>\n',
          '')],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    'copy-nodes-both-absent': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          '      <Text style={[styles.maketLine, { color: tokens.ink }]} testID="first-run-subheadline">\n'
          '        {FIRST_RUN_SUBHEADLINE}\n'
          '      </Text>\n',
          ''),
         ('mobile/src/features/auth/first-run-screen.tsx',
          '      <Text style={[styles.maketFooter, { color: tokens.ink }]} testID="first-run-footer">\n'
          '        {FIRST_RUN_FOOTER}\n'
          '      </Text>\n',
          '')],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    # v4c (критик 111 v4 круг 2) → v4d (арбитраж 95f3b2c3,
    # verdicts/arbitration/contracts-111-vidimost-teksta.md): «наличие» без
    # не-скрытости закрытым перечнем — ложное зелёное (строки скрыты
    # display:none/opacity:0 в зоне implementer — honest rc0 23/23 у
    # замкнутости v4b). К5 судит ПРИСУТСТВИЕ строки полным текстом +
    # отсутствие скрытия ЗАКРЫТЫМ перечнем {display:'none', opacity 0,
    # нулевые литеральные width/height} на узле/предке (как у RNTL
    # toBeVisible) — видимость НА ЭКРАНЕ К5 не судит: её судит гейт
    # 135/123 (сверка 123 по mobile/e2e-first-run/kadry.json, элементы
    # podzagolovok/futer, порог 0,600). Скрытие узла подзаголовка/футера
    # (по одному, оба; opacity:0 — носитель того же дефекта) красно парой
    # К5: collectText v4c вырезает скрытые поддеревья. depends — замер.
    'subheadline-display-none': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'style={[styles.maketLine, { color: tokens.ink }]}',
          "style={[styles.maketLine, { color: tokens.ink, display: 'none' }]}")],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    'footer-display-none': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'style={[styles.maketFooter, { color: tokens.ink }]}',
          "style={[styles.maketFooter, { color: tokens.ink, display: 'none' }]}")],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    'copy-display-none-both': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'style={[styles.maketLine, { color: tokens.ink }]}',
          "style={[styles.maketLine, { color: tokens.ink, display: 'none' }]}"),
         ('mobile/src/features/auth/first-run-screen.tsx',
          'style={[styles.maketFooter, { color: tokens.ink }]}',
          "style={[styles.maketFooter, { color: tokens.ink, display: 'none' }]}")],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
    ),
    'subheadline-opacity-zero': (
        [('mobile/src/features/auth/first-run-screen.tsx',
          'style={[styles.maketLine, { color: tokens.ink }]}',
          'style={[styles.maketLine, { color: tokens.ink, opacity: 0 }]}')],
        ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT'], [],
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
    # Отступки вокруг SafeAreaView на first-run (A2): рамка из отступов
    # смещает канон-сетку First-Run — красна парой К6. Якорь — rootFirstRun
    # (круг 4: root вернул литералы 995, отступки теперь только тут).
    'wrapper-root-padding': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'rootFirstRun: {\n    flex: 1,\n  },',
          'rootFirstRun: {\n    flex: 1,\n    paddingTop: 48,\n    paddingHorizontal: 16,\n    paddingBottom: 16,\n  },')],
        ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT'], [],
    ),
    # R1 (ревью 111, круг 2): бейдж вынут из safe-отступа — дословная форма
    # продукта круга 2 (бейдж [0,0][137,64] целиком в статус-баре, круг 2
    # проходил 13/13+15/15); красна парой К7.
    'badge-outside-safearea': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          '        <View style={{ paddingTop: insets.top }}>\n'
          '          <View style={styles.demoBadge} testID="demo-indicator">\n'
          '            <Text style={styles.demoBadgeText}>Demo</Text>\n'
          '          </View>\n'
          '        </View>\n',
          '        <View style={styles.demoBadge} testID="demo-indicator">\n'
          '          <Text style={styles.demoBadgeText}>Demo</Text>\n'
          '        </View>\n')],
        ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT'], [],
    ),
    # top=0: обёртка жива, но верхний инсет не применяется — бейдж прижат
    # к верху под статус-баром; красна парой К7.
    'badge-inset-top-zero': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'style={{ paddingTop: insets.top }}',
          'style={{ paddingTop: 0 }}')],
        ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT'], [],
    ),
    # хардкод измеренного значения: проходит рендер с инсетом 47, красен на
    # втором рендере клетки (инсет 59) — отслеживание убивает литерал.
    'badge-hardcoded-inset': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'style={{ paddingTop: insets.top }}',
          'style={{ paddingTop: 47 }}')],
        ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT'], [],
    ),
    # К8 v2 (сужение гварда, 111 v2): merged-root красит F03.01+, welcome и
    # first-run в ground схемы (дословно форма продукта круга 3). Рестайл
    # F03.01/F03.02 легален (предмет 117) — К8 F03_01 зелёна; красна пара
    # К8′ (welcome уходит с поверхности 995), зависит К6 (отступки root
    # являются и на first-run) и К9 (unavailable/recovery — замер v2b).
    # Замер v2 полным прогоном.
    'restyle-995-ground': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "        frame === 'first-run'\n"
          "          ? [styles.rootFirstRun, { backgroundColor: tokens.ground }]\n"
          "          : styles.root",
          "        [styles.root, { backgroundColor: tokens.ground }]")],
        ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT'],
        ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT',
         'RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
    ),
    # Welcome-only рестайл (ground только на welcome): красна ТОЛЬКО пара
    # К8′ — К8 (F03.01) и К6 (first-run) зелёны.
    'restyle-welcome-ground': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "frame === 'first-run'\n",
          "frame === 'first-run' || frame === 'welcome'\n")],
        ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT'], [],
    ),
    # Root без отступков (форма круга 3): фон белый, отступов нет — F03.01
    # легален (117, замер v2), красна пара К8′ (welcome без отступов 995),
    # К6 зелёна; зависит К9 (отступки — поверхность и unavailable/recovery,
    # замер v2b).
    'restyle-995-no-padding': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "root: {\n    flex: 1,\n    paddingTop: 48,\n    paddingHorizontal: 16,\n"
          "    paddingBottom: 16,\n    backgroundColor: '#FFFFFF',\n  },",
          "root: {\n    flex: 1,\n    backgroundColor: '#FFFFFF',\n  },")],
        ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT'],
        ['RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
    ),
    # Отступки ≠ 48/16/16 (сдвиг верхнего литерала) — F03.01 легален (117,
    # замер v2), красна пара К8′ (welcome); зависит К9 (замер v2b).
    'restyle-995-padding-shifted': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          'paddingTop: 48,', 'paddingTop: 40,')],
        ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT'],
        ['RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT',
         'RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'],
    ),
    # v2b (критик круга 1, Б1): сужение гварда не снимает защиту
    # unavailable/recovery — рестайл ровно одного из кадров красен его
    # собственной парой К9 (email/code легальны — предмет 117; welcome и
    # first-run нетронуты — К6/К8/К8′ зелёны). Обход критика
    # «frame !== 'welcome'» = объединение этих двух стабов + легальный
    # рестайл email/code: краснота только на К9.
    'restyle-unavailable': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "frame === 'first-run'\n",
          "frame === 'first-run' || frame === 'unavailable'\n")],
        ['RESTYLE_GUARD_995_UNAVAILABLE_DARK', 'RESTYLE_GUARD_995_UNAVAILABLE_LIGHT'], [],
    ),
    'restyle-recovery': (
        [('mobile/src/bootstrap/pilot-app.tsx',
          "frame === 'first-run'\n",
          "frame === 'first-run' || frame === 'recovery'\n")],
        ['RESTYLE_GUARD_995_RECOVERY_DARK', 'RESTYLE_GUARD_995_RECOVERY_LIGHT'], [],
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
