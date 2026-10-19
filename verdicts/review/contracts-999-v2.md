FAIL
OBJECT=6d17dac3774aecebb973dfc7dfcc768b26b4a86d

# Вердикт reviewer — контракт 999 (CMP-MOB-002), круг 2, класс КОДОВЫЙ

Объект: a3ka/Complior-mob, ветка wip/999/implementer, коммит `6d17dac3`; база B = `f0d8e54e`. Контракт `frozen/contracts/999/1` = `c9f680b4d9fd2e7eec24524c172343a70d2d8aae`.
Пробы запускались только из моего клона харнеса `/tmp/dev-harness-verify/Rev999b/h` (на пине `c9f680b4`). Использовались деревья:
- R = `/tmp/dev-harness-verify/Rev999b/mob` (свой клон, `npm ci` rc=0);
- симуляция CI = `.../Rev999b/ci-sim` (C + `.harness` с пина);
- базовая линия = `.../Rev999b/ci-base` (B + тот же `.harness`);
- одноразовые тесты renderRouter и motion = `.../Rev999b/rr`.
Находки в reslop-формате: `/tmp/dev-harness-verify/Rev999b/.review-999.md`.

## Сырые замеры (своя мера; подсчёт — отдельной командой `grep -c ': rc=[01]'` по выводу)

| Команда | rc | Результат |
|---|---|---|
| `nav_probe.py --repo R` | 0 | 238 строк rc=0, rc=1 нет |
| `ui_probe.py --repo R` | 0 | 18/18 |
| `shell_static_probe.py --repo R` | 0 | 6/6 |
| `copy_probe.py --repo R` | 0 | 51/51 |
| `nav_probe.py --matrix` | 0 | 20 строк `MUTANT`, у всех `-> OK`, `unexpected_red=none` |
| `ui_probe.py --matrix` | 0 | 18 мутантов, у всех OK |
| `shell_static_probe.py --matrix` | 0 | 7 мутантов, у всех OK |
| `copy_probe.py --matrix` | 0 | 5 мутантов, у всех OK |
| `git status --short --untracked-files=all` в R после всех проб | — | 0 строк |
| `npx jest --ci --runInBand` (R) | 0 | 3 набора, 17/17 |
| `node scripts/check-structure.cjs` | 0 | `structure: OK` |
| `npx eslint . --max-warnings=0` | 0 | — |
| `npx tsc --noEmit` (после матриц, не параллельно с ними) | 0 | — |
| `git diff --stat frozen/contracts/999/1 origin/main -- fixtures/workshop_project/nav_999` (dev-harness) | 0 | пусто; пин = frozen-тег, значит пробы не переписаны |
| **Симуляция CI quality на H=`c9f680b4`** (шаги mobile.yml 42-98 по порядку, ci-sim): | | |
| cmp pilot.test.tsx / source.json | 0 / 0 | — |
| `probe.py --check-frozen` | 0 | — |
| runtime_probe | **1** | `SHIPPED_INVALID`, `SHIPPED_VALID`, `DEFAULT_VALID`, `HTTP_UNAVAILABLE`, `UNKNOWN_MODE`, `RUNTIME_RESPONSES` красные |
| bundle_probe | 0 | — |
| schema_probe | **1** | `RUNTIME_RESPONSES_MISMATCH` |
| frozen_matrix | 0 | — |
| transport_probe | 0 | — |
| admission_probe | **1** | `ADMISSION_*` красные: `standard-navigation ... Cannot use import statement` при `require('../../app/index')` |
| stale_probe / types_probe / pins_probe / stale_table_probe | 0 / 0 / 0 / 0 | — |
| admission_family_probe | **1** | `family_size=860 static=0 dynamic=1` |
| 999: nav / ui / static / copy на ci-sim | 0 / 0 / 0 / 0 | 238 / 18 / 6 / 51 |
| **Атрибуция**: те же 4 пробы на B `f0d8e54e`, H тот же | 0 / 0 / 0 / 0 | runtime, schema, admission, admission_family |
| C, но `app/index.tsx` взят с B: admission_probe / runtime_probe | 0 / 0 | красноту вызывает правка `app/index.tsx` |
| renderRouter по `src/app` (rr, временный jest-конфиг: проектный + трансформ `standard-navigation`) | — | `/`, `/vorgaenge`, `/schutz`, `/post` → 4 `shell-tab-*` и свой раздел; `/vorgaenge?returnTo=start`, `/schutz?returnTo=post`, `/?returnTo=post`, `complior://schutz?returnTo=post` → Back есть, после Back выбран раздел возврата, Back исчезает; `/start` → **Unmatched**; `/pilot` → PilotApp (`first-run-continue`) |
| Motion-замер (rr): системная настройка `isReduceMotionEnabled` → Promise(true) | **1** (тест красный) | `faden=PRESENT timing_calls=4` |
| Motion: событие `reduceMotionChanged(true)` | 0 | `faden=absent timing_calls=0` |
| Motion: по умолчанию / порт `reducedMotion` | 0 | по умолчанию `Animated.timing` вызывается по 1 разу на вкладку, профиль и Back; с портом — 0 вызовов, faden нет, у вкладок `disabled` нет, нажатие выбранной вкладки и Back работают, `onCommand` 0 |

Заявления реализатора своей мерой:
- **подтверждены:** nav 238, ui 18, static 6, copy 51; матрицы 20/18/7/5; jest 17/17; tsc и eslint rc=0; пин `c9f680b4` содержит и `nav_999`, и `pilot_995`.
- **неверно:** «8 файлов реализации отличаются от model/» — см. Н4.
- **проверено мной, реализатор не запускал:** 995-пробы на пине и renderRouter. В обоих найдены дефекты (Н6, С1).

## Закрытие находок круга 1 (проверено по коду)

| Находка | Статус | Основание |
|---|---|---|
| Н1 Button без роли | **закрыта** | `ui/button.tsx:32` `accessibilityRole="button"`; ui 18/18, матрица ui rc=0 |
| Н2 shell недостижим | **закрыта по форме, но сделано ценой регресса** | маршруты и deep link работают (renderRouter выше). При этом `/` отнят у PilotApp, отсюда Н6. Требование круга 1 «`/` показывает shell» противоречит frozen-контракту («`app/index.tsx` 995 не ломается», инвариант 6). Эту часть критерия Н2 снимаю как ошибку круга 1: контракт выше вердикта |
| Н3 анимации и системный reduce motion | **не закрыта** | анимация по умолчанию есть, порт и событие изменения работают, вкладки не disabled. Значение системной настройки при запуске не читается (Н3 ниже) |
| Н4 копия эталона | **не закрыта** | Н4 ниже |
| Н5 CI-пин | **закрыта** | H-checkout `c9f680b4` в quality и android-e2e; шаг 999 в симуляции даёт rc=0. Шаги 995 на этом пине красные из-за Н6, а не из-за пина |
| Совет С1 тема | закрыт | `Appearance.getColorScheme` + `addChangeListener` (`tab-shell.tsx:76-90`) |
| Совет С2 Maestro | частично | `name:` исправлен; шапка-комментарий всё ещё обещает deep link и reduced motion (С3) |
| Совет С3 EOF mobile.yml | закрыт | последний байт `0a` |
| Совет С4 дубль index | закрыт | `(tabs)/index.tsx` удалён. Появилось новое дублирование — Н7 |

## Находки

### Н6 — БЛОКЕР (регресс; инвариант 6; «Проверяемый шов»: «`app/index.tsx` 995 не ломается»; приёмка CI)
`mobile/src/app/index.tsx` теперь рендерит `TabShell`, PilotApp перенесён на `app/pilot.tsx` (`/pilot`). Frozen-пробы 995 `runtime.test.tsx`, `admission.test.tsx` и `admission_family.test.tsx` делают `require('../../app/index').default` и ждут `first-run-continue`. Сейчас они падают уже на импорте `expo-router` → `standard-navigation` (ESM, проектный jest-конфиг 995 его не трансформирует). Даже после трансформа PilotApp на `/` отсутствует (renderRouter `/` → вкладки).

Итог: в quality-джобе 4 шага 995 из 12 красные, `gh pr checks` красный. Атрибуция доказана: на B rc=0, на C с `index.tsx` от B rc=0.

Тот же `/` открывают `launchApp` в `.maestro/start.yaml`, `.maestro/rehearsal.yaml` и frozen `pilot.yaml` (через `maestro_probe.py`), и все три ждут `first-run-continue`. Поэтому android-e2e и rehearsal-evidence тоже упадут. [INFERENCE: Android не запускался; разрешение `/` в shell подтверждено renderRouter.]

- **Обход:** заявление «PilotApp сохранён на `/pilot`, тесты 991/995 импортируют его напрямую». Это верно только для `pilot.test.tsx`, `stale*.test.tsx` и тестов 991. Остальное frozen-семейство 995 и Maestro входят через `app/index`.

### Н3 — БЛОКЕР (не закрыта; остаток К1.5, слово владельца: «при системной настройке reducedMotion анимаций нет НИГДЕ»)
`tab-shell.tsx:50-58` — `readSystemReducedMotion()` сравнивает `typeof` результата `AccessibilityInfo.isReduceMotionEnabled()` с `'boolean'`. В RN 0.8x эта функция возвращает `Promise<boolean>` (`node_modules/react-native/Libraries/Components/AccessibilityInfo/AccessibilityInfo.js:188`), поэтому ветка не выполняется никогда и начальное значение всегда `false`. Подписка `reduceMotionChanged` реагирует только на изменение настройки во время работы приложения.

Замер: если настройка включена до запуска (мок промиса → true), `shell-faden` отрисован, и `Animated.timing` вызван 4 раза — при монтировании, нажатии вкладки, входе в профиль и Back (включая возврат из profile).

- **Обход:** все пробы MOTION_* зелёные, потому что задают порт `reducedMotion` явно, а он перекрывает системное чтение. Комментарий в шапке файла выдаёт неработающее чтение за реактивное.

### Н4 — БЛОКЕР (не закрыта; «Модель architect … в PR не копируется»)
Сравнение кода без строк-комментариев (`difflib`, `/tmp/dev-harness-verify/Rev999b/cmpmodel.py`):

| Файл | Совпадает с моделью |
|---|---|
| start-screen | 58/58 |
| ui-copy | 28/28 |
| theme/context | 13/13 |
| theme/tokens | 35/35 |
| notice | 31/31 |
| button | 38 из 39 строк модели |
| text-field | 38 из 39 строк модели |
| tab-shell | 141 из 161 строки модели |

Отличия в button и text-field — только перенос сигнатуры на несколько строк. Примеры `diff` для notice и tokens: меняются только шапки-комментарии («Эталон 999…» → «Реализация CMP-MOB-002…») и пропадает EOF-перевод строки.

- **Обход:** «8 файлов реализации отличаются от model/» — верно побайтово, но по существу это копия эталона с переписанными комментариями. Зелёные пробы по-прежнему показывают только то, что эталон проходит свои пробы. Значения токенов и тексты каталога обязаны совпадать с source.json; код вокруг них — нет.

### Н7 — БЛОКЕР по норме 050, ACCIDENTAL
- **Фрагмент:** `app/index.tsx:11-16`, `app/(tabs)/vorgaenge.tsx:9-14`, `schutz.tsx:7-12`, `post.tsx:7-12` — один и тот же разбор `returnTo` в 4 копиях. `app/(tabs)/_layout.tsx` состоит из одного `<Slot/>`: группа ничего не добавляет.
- **Отсутствующее свойство:** ни одна строка контракта не требует отдельного файла на каждый раздел.
- **Более простая форма, проходящая те же строки:** один динамический маршрут `app/[section].tsx` с проверкой по `TAB_ORDER` или один экспортируемый хелпер разбора. При следующей правке грамматики разделов сейчас меняются 4 файла, в простой форме — 1.

### Советы
- **С1:** маршрута для раздела Start нет — `/start` и `complior://start` → Unmatched, хотя у трёх других разделов маршруты есть. После Н6 он понадобится.
- **С2:** анимация перехода — это 3-пиксельная полоса `shell-faden` с opacity 0.25→1 за 180 мс; содержимое раздела меняется мгновенно. Достаточно ли этого как «анимации переходов» владельца — судят владелец и адверсарий (принятый остаток К1.5).
- **С3:** шапки-комментарии говорят неправду — `tab-shell.tsx:10-16` о реактивном чтении системной настройки; `cmp-mob-002-tabs.yaml:5-9` о deep link и reduced motion, которых в сценарии нет.
- **С4 (оркестратору):** пин шагов 995 сдвинут с `03d0b80c` на `c9f680b4`, хотя контракт требовал оставить шаги 995 «дословно». `pilot_995` на `c9f680b4` побайтово равен `done/contracts/995/1`; от `03d0b80c` его отличают только `stale_table.test.tsx` и `stale_table_probe.py` (+`RESET_CHALLENGE_CALLS`). stale_table на C даёт rc=0. По существу это выравнивание на принятый 995, не ослабление.

## Остальные пункты проверки

1. **Область правки.** Дифф `f0d8e54e..6d17dac3` — 19 путей, все в ЗОНЕ implementer: `.github/workflows/mobile.yml`, `mobile/.maestro/cmp-mob-002-tabs.yaml`, `mobile/assets/fonts/*` (2), `mobile/src/app/*` (7), `bootstrap/tab-shell.tsx`, `features/start/start-screen.tsx`, `i18n/ui-copy.ts`, `theme/*` (2), `ui/*` (3). Pilot-семейство 995 (`pilot-app.tsx`, `bootstrap/__tests__`, `jest.config.js`, `metro.config.js`), `start.yaml`/`rehearsal.yaml` и тесты 991 не тронуты: `git diff --quiet` rc=0. Нарушений зоны нет. Но правка внутри зоны (`app/index.tsx`) ломает read-only семейство 995 — это Н6.
2. **Сырой вывод.** Своя мера совпала с заявленными числами. Расхождение со словами реализатора — Н4.
3. **Проверки не переписаны.** `nav_999` на `origin/main` (`f4fe820d`) совпадает с frozen-тегом (diff пуст). Тесты 991/995 в mob не менялись.
4. **Красное.** Матрицы всех четырёх проб rc=0: у каждого мутанта named RED, вне `depends` краснота не найдена. Барьеров против Н3 и Н6 у проб 999 нет. Н3 — не дефект проб: остаток К1.5 контракт отдал на суд по коду.
5. **Атомарность.** Два коммита, оба от `implementer <implementer@dev-harness.local>` с меткой `999 (CMP-MOB-002)`: исходный и коммит доработки круга 2. Нарушения нет.
6. **Норма.** Нормативных документов в диффе нет.
7. **ПРОВОДКА.** Энфорсмент — CI Complior-mob. Канал существует, и шаг 999 на верном пине. Но на объекте этот канал красный из-за Н6.

## РЕАЛИЗОВАННОСТЬ §Предмет — по пунктам

| Пункт предмета | Статус |
|---|---|
| Shell с 4 вкладками Start/Vorgänge/Schutz/Post в Expo Router | есть (renderRouter), но ценой входа 995 (Н6); `/start` нет (С1) |
| Профиль — вторичный маршрут | есть: `profile-surface`, Back, после возврата вкладка-источник (nav 238, Maestro-сценарий) |
| Тема dark/light как проекция D2.2.5.1 | есть: static TOKENS_MATCH 8 имён, системная тема через Appearance. Код — копия модели (Н4) |
| Button / Notice / TextField, safe-area и keyboard | есть: ui 18/18 — копия модели (Н4). В приложении примитивы не используются: по контракту допустимо |
| Ключи каталога с review_status | есть: copy 51/51 — копия модели (Н4) |
| Deep link с возвратом к исходному | есть через `?returnTo=` (renderRouter); `complior://start` → Unmatched (С1) |
| Reduced motion | только через порт и событие изменения; значение при запуске не читается (Н3) |
| Анимации по умолчанию (слово владельца) | есть, минимальные (С2) |
| Вход 995 сохраняется, frozen-семейство 995 зелёное на C | **нет** (Н6) |
| DM Sans + OFL, без web-bundle | есть: static 6/6 |

## Паразитная сложность (050) — новые и раздутые артефакты круга 2

- **`app/index.tsx`** (shell на `/`): (1) свойство — достижимость shell; контракт же требует, чтобы `index` оставался 995. (2) Состояние — URL-параметр, явное. (3) Правится вместе с 3 соседними маршрутами. (4) Интерфейс маленький. (5) Потребитель — Maestro tabs. Ломает 995 — Н6.
- **`app/pilot.tsx`**: (1) сохранение входа 995. (2) Состояния нет. (3) 1 файл. (5) Ни приёмка, ни CI его не потребляют (frozen-пробы и Maestro 995 входят через `/`). Существует только из-за Н6.
- **`app/(tabs)/_layout.tsx` + `vorgaenge.tsx`/`schutz.tsx`/`post.tsx`**: (1) deep link в раздел. (2) `returnTo` — явный параметр. (3) 4 файла на одно свойство, при правке грамматики меняются все 4. (4) Мелкие модули. (5) Потребитель — deep link. ACCIDENTAL — Н7.
- **Системные хуки в `tab-shell.tsx` (`useSystemReducedMotion`, `useSystemColorScheme`)**: (1) остаток К1.5 и тема по системе. (2) Состояние в `useState`: системное значение явно перекрывается портом. (3) 1 файл. (4) Глубокие. (5) Потребитель — слово владельца. ESSENTIAL, но с дефектом (Н3).
- **Анимация `Animated.timing` в `tab-shell.tsx`**: (1) анимации по умолчанию — слово владельца. (2) Состояние — `fadeAnim`, ключ `route|section|returnTo`, явный. (3) 1 файл. (5) Потребитель — владелец/адверсарий. ESSENTIAL.
- **`mobile.yml`, единый H-checkout `c9f680b4`**: (1) приёмка CI «пробы 999 из H». (2) Новое состояние — disposable-копия в /tmp, явное. (3) Число мест правки пина не выросло: 2 checkout, как и раньше. (5) Потребитель — `gh pr checks`. ESSENTIAL; см. С4.
- **`.maestro/cmp-mob-002-tabs.yaml`**: (1) поставка Maestro-сценария навигации. (5) Подхватывается `ci-e2e.sh` (`maestro test ... .maestro`) — потребитель есть. ESSENTIAL; шапка — С3.

## Что не запускалось

- Android-сборка, эмулятор, Maestro (`start.yaml`, `rehearsal.yaml`, `cmp-mob-002-tabs.yaml`, frozen `pilot.yaml` / `maestro_probe.py`), `rehearsal-evidence.sh`.
- `npm run doctor` (expo-doctor), полный GitHub CI, `gh pr checks`.
- `--matrix` frozen-проб 995.
- Witness адверсария e9f02413: клона `/tmp/dev-harness-verify/Adv999/clone` нет на диске.
- Одноразовые тесты лежат только в `/tmp/dev-harness-verify/Rev999b/rr`, в объект не попадали.
