FAIL
OBJECT=3721dcca7913f0a59cdd555441d6d70a05a39411

# Вердикт reviewer — контракт 999 (CMP-MOB-002), круг 1, класс КОДОВЫЙ

Объект: a3ka/Complior-mob, ветка wip/999/implementer, коммит `3721dcca7913f0a59cdd555441d6d70a05a39411`
(база main `f0d8e54e`). Контракт: `frozen/contracts/999/1` = `c9f680b4d9fd2e7eec24524c172343a70d2d8aae`.
Пробы — из своего клона dev-harness (HEAD `d3e47d05`), R = `/tmp/dev-harness-verify/Rev999/mob` (свой клон, `npm ci`).
Находки в reslop-формате: `/tmp/dev-harness-verify/Rev999/.review-999.md`.

## Сырые замеры (своя мера)

| Команда (на R = 3721dcca) | rc | Результат |
|---|---|---|
| `nav_probe.py --repo R` | 0 | 238 строк `rc=0` |
| `ui_probe.py --repo R` | **1** | 10 `rc=0`, **8 `rc=1`**: все `BUTTON_*` |
| `shell_static_probe.py --repo R` | 0 | 6/6 |
| `copy_probe.py --repo R` | 0 | 51/51 |
| `nav_probe.py --matrix` | 0 | 20 мутантов, у каждого named RED, unexpected_red=none |
| `ui_probe.py --matrix` | **1** | честный прогон красный (8 BUTTON_*), 18 мутантов named RED |
| `shell_static_probe.py --matrix` | 0 | 7 мутантов |
| `copy_probe.py --matrix` | 0 | 5 мутантов |
| `git status --short --untracked-files=all` в R после проб | — | 0 строк |
| `npx tsc --noEmit` (отдельно, без параллельной матрицы) | 0 | — |
| `npx jest --ci --runInBand` | 0 | 3 набора, 17/17 (pilot, rehearsal, start-screen) |
| `node scripts/check-structure.cjs` | 0 | `structure: OK` |
| `npx eslint . --max-warnings=0` | 0 | — |
| `git diff --stat frozen/contracts/999/1 HEAD -- fixtures/workshop_project/nav_999` (dev-harness) | 0 | пусто — пробы и фикстуры не переписаны |
| CI-шаг 999 на H-пине из mobile.yml (`03d0b80c`), `python3 .harness/fixtures/workshop_project/nav_999/nav_probe.py --repo .` | **2** | `can't open file ... nav_999/nav_probe.py` |
| renderRouter(`mobile/src/app`), временный тест в отдельном клоне | — | `/` → testID `demo-indicator`, `first-run-continue` (PilotApp), вкладок shell 0; `/vorgaenge` → `expo-router-unmatched`; `complior://vorgaenge` → PilotApp |

Слова реализатора «ui 18/18» и «матрица ui 18 named RED, честный прогон зелёный» на объекте не подтвердились:
ui rc=1. Прочие заявленные числа (nav 238, static 6, copy 51, матрицы 20/18/7/5, jest 17, tsc 0, structure OK)
моя мера подтвердила.

## Находки

### Н1 — БЛОКЕР (заявлено ≠ сделано; инвариант 3): Button без роли, ui_probe красный на объекте
`mobile/src/ui/button.tsx:21` — из Pressable убрана `accessibilityRole="button"` (у эталона она есть).
`ui_probe.py --repo R` → rc1, красные все 8 клеток `BUTTON_<SCHEME>_<VARIANT>[_DISABLED]` (ассерт
`expect(btn.props.accessibilityRole).toBe('button')`). Я вернул строку в отдельном клоне — все 8 клеток стали
`rc=0`, значит причина именно в этом. Отчёт реализатора с «ui 18/18» вывода с этого коммита не содержит.

### Н2 — БЛОКЕР (§Предмет, инварианты 1 и 5, «Проверяемый шов»): shell в приложение не подключён, deep link не работает
- `mobile/src/app/_layout.tsx` не тронут (голый `Stack`), `app/index.tsx` реэкспортирует `PilotApp`;
  `app/(tabs)/_layout.tsx` рендерит `<TabShell />` без портов, без `Slot`, и отдельного маршрута для вкладки нет.
  Обе страницы `app/index.tsx` и `app/(tabs)/index.tsx` отвечают на `/`. Expo Router выбирает `app/index.tsx`.
- Проверил renderRouter по настоящему каталогу `app/`. На `/` открывается PilotApp и ни одной `shell-tab-*`.
  На `/vorgaenge` — «Unmatched Route». На `complior://vorgaenge` — PilotApp. URL-параметры
  (`useLocalSearchParams`, `Linking`) в `mobile/src` нигде не читаются, хотя комментарий в `(tabs)/_layout.tsx`
  говорит, что порты «задаются deep-link-параметрами через Expo Router». Это неправда.
- Отсюда `mobile/.maestro/cmp-mob-002-nav.yaml` (`launchApp` → `assertVisible id: shell-tab-start`) на сборке
  упадёт на первом шаге, если его вообще запустить: в CI он не подключён.
- **Обход:** именно это дерево. nav/copy/static зелёные, потому что монтируют `TabShell` напрямую. Пользователь
  приложения вкладок не видит, deep link приводит в unmatched. Барьер стоит на шве, предмета в приложении нет.

### Н3 — БЛОКЕР (принятый остаток К1.5, слово владельца ~11:10 UTC, записано в «Незаполненные требования» frozen-контракта): анимаций нет, системный reducedMotion не читается
- В `mobile/src` нет ни одного вхождения `Animated` / `react-native-reanimated` / `LayoutAnimation` / `AccessibilityInfo` /
  `isReduceMotionEnabled` / `useReducedMotion` (grep по дереву, совпадений 0). `shell-faden` — неподвижный `View`
  высотой 3 px. Это не «анимация переходов по умолчанию».
- `reducedMotion` — только проп со значением по умолчанию `false`, и приложение его не передаёт
  (`(tabs)/_layout.tsx`: `<TabShell />`). Поэтому «при системной настройке reducedMotion анимаций нет НИГДЕ»
  ни к чему не подключено: системную настройку никто не читает.
- Вкладки остаются нажимаемыми и при выбранной вкладке: у `Pressable` нет `disabled`. Это выполнено.
- **Обход:** текущее дерево. Все MOTION_* зелёные, потому что проверяют только отсутствие `shell-faden`
  при переданном пропе. При этом анимации нет ни при какой настройке, а сама настройка ОС ни к чему не подключена.

### Н4 — БЛОКЕР (контракт: «Модель architect … в PR не копируется»; «Реализация не передаёт файлы модели в PR»): реализация — копия эталона
`cmp` против `fixtures/workshop_project/nav_999/model/`: побайтово совпадают 7 файлов —
`bootstrap/tab-shell.tsx`, `features/start/start-screen.tsx`, `i18n/ui-copy.ts`, `theme/context.ts`,
`theme/tokens.ts`, `ui/notice.tsx`, `ui/text-field.tsx`. Восьмой, `ui/button.tsx`, отличается одной удалённой
строкой (см. Н1). В PR остались шапки «Эталон architect: honest-модель для красных тестов, в PR не копируется»
(`tab-shell.tsx:6`) и «Файл — часть честного эталона architect, не копируется в PR» (`tokens.ts:3`).
- **Обход:** зелёные nav/copy/static на C показывают только, что эталон проходит свои же пробы. Это уже
  измерено архитектором, о реализации это ничего не говорит. Независимая реализация не предъявлена.

### Н5 — БЛОКЕР (§Пины и порядок поставки; приёмка «gh pr checks … rc0, включая пробы 999 из H»): CI-шаг 999 на чужом пине H
`mobile.yml:85-95` запускает `.harness/fixtures/workshop_project/nav_999/*.py`, но `.harness` вычекан на
`ref: 03d0b80c98f54b9f305f52fa6f599264a44427d6` (пин 995, строки 36 и 127). `git ls-tree 03d0b80c fixtures/workshop_project/`
каталога `nav_999` не содержит. Комментарий в шаге пишет «закреплён за frozen/contracts/999/1 (c9f680b4d)»,
но отдельного H-checkout на `c9f680b4d` нет. Повторил шаг на этом пине: rc=2,
`can't open file …/nav_999/nav_probe.py`. Значит, quality-джоба на PR красная, и пробы 999 в CI не исполняются ни разу.
- **Обход:** локальные зелёные пробы. Энфорсмент ПРОВОДКИ (CI Complior-mob) по факту отсутствует.

### С1 — совет: тема в приложении всегда тёмная
Нигде не вызываются `useColorScheme`/`Appearance`, у `colorScheme` по умолчанию `'dark'`. Светлая тема есть
только как порт. Шов контракт выполняет. Подключение к системе — та же доработка, что в Н2/Н3.

### С2 — совет: Maestro-сценарий обещает больше, чем проверяет
В `name:` заявлены «deep link с возвратом, reduced motion». Шагов deep link и reduced motion в файле нет:
есть вкладки, профиль и Back. Сценарий не подключён к android-e2e. По контракту это допустимо
(отложенная приёмка NOT_RUN), но название вводит в заблуждение.

### С3 — совет: `mobile.yml` потерял завершающий перевод строки (`\ No newline at end of file`)
Шаги 995 и android-e2e не ослаблены: в диффе только добавленный шаг 999 и пропавший EOF-перевод строки.

### С4 — совет: `app/(tabs)/index.tsx` дублирует `(tabs)/_layout.tsx`
Обе страницы рендерят `TabShell`. Layout без `Slot` index не показывает, так что второй файл мёртвый.

## Остальные пункты проверки

1. **Область правки.** Все 14 файлов `f0d8e54e..3721dcca` лежат в ЗОНЕ implementer из frozen-блоба
   (`mobile/src/app/`, `ui/`, `theme/`, `i18n/`, `bootstrap/tab-shell.tsx`, `features/start/start-screen.tsx`,
   `assets/fonts/`, `.github/workflows/mobile.yml`, `.maestro/`). Pilot-семейство 995, тесты 991/995,
   metro/jest config не тронуты. Нарушений нет.
2. **Сырой вывод.** Для nav/static/copy/jest/tsc он совпал с заявленным. Для ui заявлено то, чего нет (Н1).
3. **Проверки не переписаны.** `fixtures/workshop_project/nav_999` на HEAD dev-harness совпадает с `frozen/contracts/999/1`
   (diff пуст). Тесты 991/995 в mob не менялись.
4. **Красное.** Матрицы nav/static/copy показывают named RED у каждого мутанта. Мутанты ui тоже красные,
   но честный прогон ui красный (Н1).
5. **Атомарность.** Один коммит `999 (CMP-MOB-002) implementer: …`, автор `implementer <implementer@dev-harness.local>`.
6. **Норма.** Нормативных документов в диффе нет.
7. **Доступность прежнего кода.** jest 17/17, start-screen 991 и rehearsal зелёные, structure/eslint/tsc rc0.
   frozen-пробы 995 на C — см. раздел «Что не запускалось».
8. **ПРОВОДКА.** Энфорсмент записан как CI Complior-mob, и этот канал по факту сломан (Н5).
   Поведенческой нормы 029-класса контракт не вводит: это потребление существующей нормы оркестратора, обоснование честное.

## Паразитная сложность (050)

- `bootstrap/tab-shell.tsx`: (1) инварианты 1, 3, 5 и шов; (2) состояние section/returnTo/route явное, в пропах-портах;
  (3) один файл; (4) интерфейс из 5 необязательных портов против работы всего shell — модуль глубокий;
  (5) потребитель — nav/ui/copy-пробы. ESSENTIAL. Но это копия эталона (Н4).
- `app/(tabs)/_layout.tsx` + `app/(tabs)/index.tsx`: (1) монтирование shell в Expo Router; (2) состояния нет;
  (3) два файла на одно свойство, и оба не достигают цели (Н2); (5) потребитель — только Maestro, и тот не запускается.
  ACCIDENTAL в части дубля (С4). Отказ по существу — Н2.
- `theme/tokens.ts`, `theme/context.ts`: инвариант 2; состояние — контекст, явное; потребитель — static/ui. ESSENTIAL.
- `i18n/ui-copy.ts`: инвариант 4; состояния нет; потребитель — copy. ESSENTIAL.
- `ui/button.tsx`, `ui/notice.tsx`, `ui/text-field.tsx`: инвариант 3; состояния нет; потребитель — ui. ESSENTIAL.
- `assets/fonts/*`: инвариант 6; потребитель — static. ESSENTIAL.
- CI-шаг 999 в `mobile.yml`: строка приёмки CI. Состояние — disposable-копия в /tmp, явное. Нужный ему H-пин не введён (Н5).
- `.maestro/cmp-mob-002-nav.yaml`: строка поставки. Потребителя в CI нет (С2).

## Что не запускалось

Android-сборка, эмулятор, Maestro (`cmp-mob-002-nav.yaml`, `start.yaml`), полный GitHub CI, `expo-doctor`,
`gh pr checks`. Из frozen-проб 995 на C (H=`03d0b80c`, дерево `/tmp/dev-harness-verify/Rev999/ci-sim`) запущены 7, все rc=0: runtime_probe, bundle_probe, frozen_matrix, stale_probe, types_probe, pins_probe, stale_table_probe. НЕ запускались: probe.py --check-frozen, schema_probe, transport_probe, admission_probe, admission_family_probe.
