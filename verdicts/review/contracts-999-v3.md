FAIL
OBJECT=504fcafb7f3871155cf2d7e297d3d766d0f098a5

# Вердикт reviewer — контракт 999 (CMP-MOB-002), круг 3 (последний по капу), класс КОДОВЫЙ

Объект — коммит `504fcaf` в моём клоне `/tmp/dev-harness-verify/Rev999c/mob` (из `/tmp/dev-harness-verify/Impl999/mob`), база B = `f0d8e54e`. Харнес-клон `/tmp/dev-harness-verify/Rev999c/h` на `c9f680b4d9fd2e7eec24524c172343a70d2d8aae`; `frozen/contracts/999/1^{commit}` = тот же SHA.
Находки в reslop-формате — `/tmp/dev-harness-verify/Rev999c/review.md` (`status: ready`).

Деревья:
- R = `Rev999c/mob` (`npm ci` rc=0);
- ci-sim = `Rev999c/ci-sim` (504fcaf + `.harness` = h@c9f680b4, `npm ci` rc=0);
- rr = `Rev999c/rr` (504fcaf + одноразовые RNTL-тесты в `mobile/src/rrcheck/`, `rrjest.config.js` = проектный конфиг + трансформ `standard-navigation`).

## Блокер

### Н8 — Maestro-сценарий навигации из этого PR не проходит: `/` снова PilotApp, а сценарий ждёт shell после `launchApp`

- **Нарушает:** строку приёмки «`gh pr checks PR --required` → rc0, исполнены quality/android-e2e» и обещание PR «Android/Maestro-сценарий навигации — четыре вкладки, Back, deep link».
- **Фрагмент:** `mobile/.maestro/cmp-mob-002-tabs.yaml:8-11`:
  ```
  - launchApp:
      clearState: true
  - assertVisible:
      id: shell-tab-start
  ```
- **Почему сценарий не пройдёт:**
  - Круг 3 вернул `/` пилоту 995 (`app/index.tsx` → `PilotApp`), а сценарий 999 оставлен прежним.
  - Тот же `launchApp: clearState: true` в `.maestro/start.yaml` (995) ждёт `first-run-continue`. Оба ожидания на одном экране одновременно не выполнятся.
- **Почему от этого краснеет CI:**
  - `maestro_probe.py:43-52` (pilot_995 на пине) копирует ВСЕ файлы `mobile/.maestro` в приватный cwd.
  - `ci-e2e.sh:69-70` выполняет `maestro test ... .maestro`, то есть все сценарии папки.
  - При rc≠0 `maestro_probe.py:97-102` возвращает 1.
  - Красным станет и `rehearsal-evidence.sh:42-45` (`failures≠0` в любом suite).
- **Обход** (критерий выполнен, предмет нет): на 504fcaf все локальные строки приёмки зелёные — 999 nav 238 / ui 18 / static 6 / copy 51, 14 шагов 995 на пине, jest 17/17. Но единственный нативный сценарий навигации, который поставляет PR, на собранном приложении упадёт уже на втором шаге.
- **rc-свидетельство:** эквивалент `launchApp` в RNTL — renderRouter по `/`. Файл `rr/mobile/src/rrcheck/__tests__/maestro-equiv.test.tsx`:
  ```
  ✓ 995 start.yaml: launchApp -> first-run-continue (183 ms)
  ✕ 999 cmp-mob-002-tabs.yaml: launchApp -> shell-tab-start (11 ms)
  expect(received).not.toBeNull()
  Received: null
  Tests:       1 failed, 1 passed, 2 total
  maestro-equiv jest rc=1
  ```
  Другой мерой тот же факт показывает `router.test.tsx`: `ROUTE /: tabs=-,-,-,- section= noback PILOT`. [INFERENCE: Android/Maestro не запускались, по заданию судьи.]
- **Простая форма, которая проходит:**
  - после `launchApp` добавить `openLink: complior://start`;
  - для deep link добавить `openLink: complior://schutz?returnTo=post`, затем Back.
  - Нативный разбор маршрута у объекта работает: `extractExpoPathFromURL([], 'complior://schutz?returnTo=post')` → `schutz?returnTo=post`. По этому пути renderRouter показывает `section=schutz sel=schutz back=y | afterBack section=post sel=post back=n`.
  - Это ровно то, что круг 2 предписывал в Н6 («`cmp-mob-002-tabs.yaml` открывает shell через `openLink`»). Сделано не было.

## Закрытие находок круга 2 (`.review/2026-10-19-05.md`, `verdicts/review/contracts-999-v2.md`)

| Находка | Статус | Основание (моя мера) |
|---|---|---|
| Н6 регресс 995 | **закрыта** | `app/index.tsx` = `export { PilotApp as default }`. ci-sim на H=c9f680b4: cmp_pilot_test 0, cmp_source 0, `probe.py --check-frozen` 0, runtime 0, bundle 0, schema 0, frozen_matrix 0, transport 0, admission 0, stale 0, types 0, pins 0, admission_family 0, stale_table 0; ci999 nav/ui/static/copy 0/0/0/0; `git status` вне `.harness` пуст |
| Н3 системный reduce motion при запуске | **закрыта** | `tab-shell.tsx:51-91`: пока Promise не разрешён — true, затем `.then(apply)`. Замер в rr: `SYSTEM_RM_TRUE_AT_LAUNCH fadenAtMount=absent faden=absent timing_calls=0 disabled=false,false,false,false sel=post` (вкладка, повторное нажатие выбранной вкладки, профиль, Back); `SYSTEM_RM_TRUE_DEEPLINK_BACK timing_calls=0`; `SYSTEM_RM_PENDING_FOREVER timing_calls=0`; `SYSTEM_RM_FALSE_ANIMATES faden=PRESENT tab=1 profile=1 back=1`; `SYSTEM_RM_CHANGE_EVENT timing_calls=0` |
| Н7 четыре копии разбора `returnTo` | **закрыта** | один `app/(tabs)/[section].tsx` с проверкой по `TAB_ORDER`; при правке грамматики меняется 1 файл вместо 4 |
| Н4 копия эталона | **не закрыта, переведена в совет (Н-39)** | см. «Советы», С-Н4 |
| С1 нет `/start` | закрыт | `ROUTE /start: tabs=start,vorgaenge,schutz,post section=start`; `complior://start` → `/start` → shell |
| С3 шапки неправдивы | закрыт | шапка `tab-shell.tsx:1-8` описывает асинхронное чтение, как в коде; шапка yaml больше не обещает deep link и reduced motion |
| С2, С4 | без изменений | адресованы владельцу и оркестратору |

## Своя мера против заявления Impl999r3

Подсчёт делал отдельной командой `grep -c` по сохранённому выводу, а не по сводке проб.

| Заявлено | Моя команда | Результат |
|---|---|---|
| nav 238 / ui 18 / copy 51 / static 6, rc0 | `run999.sh` → `out999-*.txt`, `grep -c ': rc=0'` / `': rc=1'` | rc=0 у всех 4; 238/0, 18/0, 51/0, 6/0 |
| матрицы 20/18/5/7 | `--matrix` → `outmx-*.txt`, `grep -c '^MUTANT'` / `'-> OK'` / `BROKEN` | rc=0 у всех 4; nav 20/20/0, ui 18/18/0, copy 5/5/0, static 7/7/0 |
| frozen-пробы 995 на пине rc0 | `run995.sh` (ci-sim, порядок шагов mobile.yml) | 14/14 rc0 (таблица выше) |
| jest 17/17 | `npx jest --ci --runInBand` | 3 набора, 17 passed, rc=0 |
| tsc/eslint rc0 | `npx tsc --noEmit`; `npx eslint . --max-warnings=0`; `node scripts/check-structure.cjs` | 0 / 0 / 0 (`structure: OK`) |
| «Н4 — переписаны 8 файлов» | `cmpmodel.py 504fcaf` (токены кода без комментариев) + `diff -w` с `model/` | **частично неверно**: 3 из 8 файлов совпадают с моделью по коду на 100%, ещё 3 отличаются переименованиями (см. С-Н4) |
| `git status` R после проб | `git -C mob status --short --untracked-files=all \| wc -l` | 0 |

## Остальные пункты гейта

1. **Область правки.** Дифф `f0d8e54..504fcaf` — 16 путей; `3721dcc..504fcaf` — 15; `6d17dac..504fcaf` — 14. Зону implementer взял из frozen-блоба `frozen/contracts/999/1^{commit}:contracts/999-cmp-mob-002-navigatsiya.md`: `mobile/src/app/ mobile/src/ui/ mobile/src/theme/ mobile/src/i18n/ mobile/src/bootstrap/tab-shell.tsx mobile/src/features/start/start-screen.tsx mobile/assets/fonts/ .github/workflows/mobile.yml mobile/.maestro/`. `git diff --name-only <A> 504fcaf -- . ':!<каждый путь зоны>'` для A=f0d8e54 и A=3721dcc даёт пустой вывод, rc=0: **путей вне зоны нет**. Read-only пути 995/991 не тронуты: `git diff --quiet f0d8e54 504fcaf -- mobile/src/bootstrap/__tests__ mobile/src/features/start/__tests__ mobile/src/bootstrap/pilot-app.tsx mobile/jest.config.js mobile/metro.config.js mobile/.maestro/start.yaml mobile/.maestro/rehearsal.yaml mobile/scripts mobile/package.json mobile/package-lock.json mobile/app.json` rc=0.
2. **Сырой вывод** снят мной: файлы `out999-*`, `outmx-*`, `out995-*`, `outci999-*` в `Rev999c/`.
3. **Проверки не переписаны под код.** `git diff --stat frozen/contracts/999/1 HEAD -- fixtures/workshop_project/nav_999 fixtures/workshop_project/pilot_995` на пине пуст, rc=0. `git diff --stat c9f680b4 origin/main -- fixtures/workshop_project/nav_999` пуст. `cmp` frozen-тестов 995 rc=0. Тестовые файлы в mob дифф не трогает.
4. **Красное.** Новых барьеров в объекте нет: PR поставляет код, пробы лежат в H. Матрицы на H rc=0, но см. С8. Против Н8 барьера в пробах 999 нет: пробы не исполняют Maestro.
5. **Атомарность.** Три коммита `implementer <implementer@dev-harness.local>`, у всех метка `999 (CMP-MOB-002)`: исходный, доработка круга 2 и доработка круга 3. Нарушения нет.
6. **Норма.** Нормативных документов в диффе нет.
7. **ПРОВОДКА.** Энфорсмент — CI Complior-mob из H-checkout, оба checkout на `c9f680b4`. Шаг 999 стоит в quality до `npm test`. Quality в симуляции зелёный, android-e2e на объекте будет красным (Н8).

## РЕАЛИЗОВАННОСТЬ §Предмет

| Пункт | Статус |
|---|---|
| Shell из 4 вкладок Start/Vorgänge/Schutz/Post в Expo Router | есть: `/start`, `/vorgaenge`, `/schutz`, `/post` → 4 `shell-tab-*` и свой раздел. Попасть в shell можно только по deep link: `/` отдан 995, по контракту так и должно быть |
| Профиль — вторичный маршрут | есть (nav 238; rr: профиль → Back → вкладка-источник) |
| Тема dark/light — проекция D2.2.5.1 | есть: static 6/6, tokens = source.json |
| Button/Notice/TextField, safe-area, keyboard | есть: ui 18/18 |
| Ключи каталога с review_status | есть: copy 51/51 |
| Deep link с возвратом к исходному разделу | есть: `complior://schutz?returnTo=post` → schutz + Back → post, Back исчезает; `complior://vorgaenge?returnTo=start` → vorgaenge → start |
| Reduced motion — системная настройка и порт; анимации по умолчанию | есть (Н3 закрыта) |
| Вход 995 сохранён, frozen-семейство 995 зелёное | есть (Н6 закрыта) |
| DM Sans + OFL, без web-bundle | есть: static 6/6 |
| Android/Maestro-сценарий навигации в PR | **сломан (Н8)** |

## Паразитная сложность (050): новые и раздутые артефакты круга 3

- **`app/(tabs)/[section].tsx`:**
  - (1) Свойство контракта — deep link в раздел с возвратом (инвариант 5).
  - (2) Состояние — URL-сегмент и `returnTo`, видны в адресе.
  - (3) Правка грамматики разделов: 1 файл против 4 раньше; число уменьшилось.
  - (4) Модуль глубокий: интерфейс — 2 параметра, работу выполняет TabShell.
  - (5) Потребители — deep link и (должен быть) Maestro.
  - **ESSENTIAL.**
- **`app/(tabs)/_layout.tsx` (`<Slot/>`):**
  - (1) Свойства не несёт.
  - (4) Мелкий модуль.
  - **ACCIDENTAL**, советом (С7): более простую форму прогоном не доказывал.
- **`readSystemReduceMotionInitial` + `useSystemReduceMotion`:**
  - (1) Остаток К1.5.
  - (2) Состояние лежит в `useState` и явно перекрывается портом.
  - (3) 1 файл.
  - (4) Начальное чтение избыточно: на устройстве всегда возвращает true.
  - (5) Потребитель — слово владельца.
  - **ESSENTIAL** по свойству, форма **ACCIDENTAL** — советом (С6).
- **Обёртки `React.memo` и переименования в `notice`/`text-field`/`start-screen`/`button`:**
  - (1) Свойства не несут.
  - (5) Потребителя нет.
  - **ACCIDENTAL**, советом (С-Н4): цель — отличаться от модели, а не новое поведение.
- **`mobile.yml`:**
  - (1) Строка «пробы 999 из H».
  - (2) Новое состояние — disposable-копия в /tmp.
  - (3) Пин живёт в 2 checkout, как и раньше.
  - (5) Потребитель — `gh pr checks`.
  - **ESSENTIAL.**
- **`.maestro/cmp-mob-002-tabs.yaml`:**
  - (1) Нативный сценарий навигации.
  - (5) Потребитель — ci-e2e через maestro_probe.
  - **ESSENTIAL** по свойству, сейчас сломан (Н8).

## Советы (не блокируют)

- **С-Н4** (бывшая Н4; по Н-39 без обхода с rc не блокирует; §Предмет поведенчески выполнен). Доля токенов кода модели, найденных в реализации без комментариев (`cmpmodel.py 504fcaf`):

  | Файл | Доля |
  |---|---|
  | `i18n/ui-copy.ts` | 218/218 = 1.00 |
  | `theme/tokens.ts` | 161/161 = 1.00 |
  | `theme/context.ts` | 75/75 = 1.00 |
  | `ui/notice.tsx` | 0.97 |
  | `ui/text-field.tsx` | 0.96 |
  | `features/start/start-screen.tsx` | 0.92 |
  | `ui/button.tsx` | 0.82 |
  | `bootstrap/tab-shell.tsx` | 0.68 |

  - `diff -w` с `model/` для первых трёх файлов: отличаются только шапки-комментарии и EOF-перевод строки.
  - Для notice, text-field и start-screen отличия — переименования (`base→box`, `field→column`, `completed→done`, `button→cta`), `React.memo(…Impl)` и сжатые объекты стилей.
  - Для двух файлов-данных (`ui-copy`, `tokens`) значения обязаны совпадать с source.json побайтово, и форма почти предопределена.
  - Заявление «переписаны 8 файлов» в полном смысле верно только для `tab-shell` и `button`.
  - Отказ по этой причине звучал в кругах 1 и 2. Это спор с судьёй-стороной → арбитр или владелец решает, считать ли форму, повторяющую эталон, нарушением фразы «Модель architect … в PR не копируется».
- **С5.** Шапка `[section].tsx:2-3` («невалидный сегмент даёт Unmatched») не соответствует коду: возвращается `null`. `/heute`, `complior://heute` и `/pilot` открывают пустой экран без Back и без Unmatched (rr: `ROUTE /heute: tabs=-,-,-,- section= noback`, без флага UNMATCHED).
- **С6.** `readSystemReduceMotionInitial` вызывает `isReduceMotionEnabled()` и выбрасывает промис. Хватит `useState(true)`. `if (!reducedMotion ? true : false)` равно `if (!reducedMotion)`.
- **С7.** Группа `(tabs)` с `_layout` из одного `<Slot/>`.
- **С8 (оркестратору).** `--matrix` проб 999 ставит мутанты на байты модели поверх R (`nav_probe.py:237-262`: `model_bytes(list(patches))` → `install_map(repo, …)`; во время прогона `git status` R показывал 8 файлов модели `M`). «Матрицы rc0 на C» — свойство проб и модели. О реализации C говорит только честный прогон.
- **С4 (круг 2, оркестратору)** — без изменений.

## Сырые команды

```
git clone /tmp/dev-harness-verify/Impl999/mob mob && git -C mob checkout 504fcafb7f3871155cf2d7e297d3d766d0f098a5
git clone ssh://git@github.com/a3ka/dev-harness.git h && git -C h checkout c9f680b4d9fd2e7eec24524c172343a70d2d8aae
git -C h rev-parse 'frozen/contracts/999/1^{commit}'            # c9f680b4d9fd2e7eec24524c172343a70d2d8aae
git -C h diff --stat frozen/contracts/999/1 HEAD -- fixtures/workshop_project/nav_999 fixtures/workshop_project/pilot_995   # пусто, rc=0
git -C mob diff --name-only f0d8e54 504fcaf -- . ':!mobile/src/app/' ':!mobile/src/ui/' ':!mobile/src/theme/' ':!mobile/src/i18n/' ':!mobile/src/bootstrap/tab-shell.tsx' ':!mobile/src/features/start/start-screen.tsx' ':!mobile/assets/fonts/' ':!.github/workflows/mobile.yml' ':!mobile/.maestro/'   # пусто, rc=0 (то же для 3721dcc)
(mob/mobile) npm ci                                              # rc=0
./run999.sh   # nav/ui/static/copy rc=0 ×4; --matrix rc=0 ×4; status 0 строк
./run995.sh   # ci-sim: 14 шагов 995 rc=0, ci999 ×4 rc=0
python3 cmpmodel.py 504fcaf ; python3 cmpmodel.py 6d17dac
(mob/mobile) npx jest --ci --runInBand → 17/17 rc=0; npx tsc --noEmit rc=0; npx eslint . --max-warnings=0 rc=0; node scripts/check-structure.cjs rc=0
(rr/mobile) npx jest --config rrjest.config.js src/rrcheck/__tests__/router.test.tsx      → 17/17 (наблюдения ROUTE/SYSTEM_RM_* выше)
(rr/mobile) npx jest --config rrjest.config.js src/rrcheck/__tests__/deeplink.test.tsx    → 5/5, rc=0
(rr/mobile) npx jest --config rrjest.config.js src/rrcheck/__tests__/maestro-equiv.test.tsx → 1 failed / 1 passed, rc=1 (Н8)
(rr/mobile) node deeplink-check.cjs   # complior://schutz?returnTo=post -> "schutz?returnTo=post"; complior://start -> "start"
```

Важная оговорка по `router.test.tsx`: renderRouter с `initialUrl: 'complior://…'` открывает `/` (PILOT), но это особенность тестового `location`. На устройстве нативный `extractExpoPathFromURL` отдаёт путь `schutz?…`, поэтому deep link проверял через `deeplink.test.tsx`.

## Что не запускалось

Android-сборка, эмулятор, Maestro (`start.yaml`, `rehearsal.yaml`, `cmp-mob-002-tabs.yaml`, frozen `pilot.yaml`), `rehearsal-evidence.sh`, `npm run doctor`, `gh pr checks`, `--matrix` проб 995. Одноразовые тесты лежат только в `Rev999c/rr`, в объект не попадали.
