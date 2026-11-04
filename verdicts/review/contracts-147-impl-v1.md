FAIL
# Вердикт reviewer — 147 gespraech-vhod-menu, реализация (SUBJECT=147, OBJECT=74671ab3c98c22f115cef042e62debe97cdbe5c4)

OBJECT=74671ab3c98c22f115cef042e62debe97cdbe5c4

СУД: repo=Complior-mob (одноразовый клон `/tmp/dev-harness-verify/Impl147h/mob`, ветка `wip/147/implementer`; OBJECT зеркалирован в `.git` харнесса: `git -C /home/harness/dev-harness cat-file -t OBJECT` = commit); предмет=147; фаза=реализация (контракт `frozen/contracts/147/2` → 28e2696f9, карта/пины `fixtures/workshop_project/gespraech_vhod_147/`, karta.json == блоб заморозки); роль=reviewer; трек=лёгкий, класс риска обычный; сессия=Rev147 (01a1a7fb-1b58-7367-a1bc-088197f6fe4d); модель-план=Opus, vision обязателен; модель-факт=anthropic/claude-opus-5-5; вызов=1. Цепочка: d5c9f74 (PR #146) → 877960cf0 (Impl147h) → 74671ab3c (Impl147i). База диффа — merge-base `6240f63` с `origin/main`.

Независимость: implementer — MiniMax (TRACE пакета), судья — семейство Anthropic. Вердикт привязан к OBJECT и не наследуется rebase-кандидатом на 148.

Копия суда: `git clone --shared` → `/tmp/dev-harness-verify/Rev147/mob`, checkout OBJECT, `node_modules` — hardlink-копия. Мутанты и пробы вносились только в эту копию и откатывались (`git status` пуст на OBJECT). Клон исполнителя не тронут: `status` — 0 строк, HEAD = OBJECT. Эмуляторы не поднимались.

Находки: `.review/2026-11-04-47.md` (`status: ready`; копия — `/tmp/dev-harness-verify/Rev147/review-files/.review/2026-11-04-47.md`).

## БЛОКИРУЕТ

Ниже — сводка. Полная форма находок (обязательство, класс, достижимое состояние, наблюдение, закрывающее свойство) — в файле находок.

| ID | Обязательство | Класс причины | Кто закрывает |
|---|---|---|---|
| Б-1 | ПЕРЕСЕЧЕНИЕ mobile.yml «147 добавляет ТОЛЬКО свой работник … чужие тела не меняются»; SPEC §5; критерий 4 | область правки: в job `quality` добавлен шаг «Вынос канона 147», в `needs` двух агрегатов — след `e2e-pilot ]`; отчёты утверждают обратное | implementer (доказано: однострочная правка канон-теста даёт eslint rc 0) |
| Б-2 | И-4 (onPress Mitte → меню во всех состояниях) | дефект продукта: состояние касания `'resheno'` не сбрасывается; активация доступности после голоса не открывает меню | implementer |
| Б-3 | слово владельца 2026-10-20 (сверка с макетом) | иконки пилюль невидимы (тёмная тема) или заменены заглушками; текст карточки ждущего Vorgang обрезан, нет статус-точки | implementer |
| Б-4 | слово владельца 2026-10-20 | фон без размытой подложки (связан с И-5); «Sprechen» чёрная в light (палитра темы 148); гарнитура Roboto вместо DM Sans (шрифт в продукте не подключён) | владелец (строка-оговорка), 148, подключение шрифта |
| Б-5 | ЗОНА implementer контракта 147/2 | выход за зону: `mobile/src/bootstrap/__tests__/gespraech-ekran.test.tsx`. Критерий 2 своей командой (слайс) недостижим: eslint-граница запрещает слайсу импортировать оболочку — дефект контракта | architect (ЗОНА-строка, команда критерия 2) + заморозка |

## 1. Область правки

`git diff --name-only 6240f63 74671ab3c` — 30 путей. Своя мера: фильтр по семи ЗОНА-строкам implementer.

- Вне зоны — ровно один путь: `mobile/src/bootstrap/__tests__/gespraech-ekran.test.tsx` (Б-5).
- `mobile/ci-screens.json`: `git diff --quiet` → rc 0, не тронут (И-10 / критерий 4 соблюдены).
- `.github/workflows/mobile.yml`: `--numstat` → `20 2`. Работника нет, но изменены тело `quality` и `needs` двух агрегатов (Б-1).
- `tab-shell.tsx` (в зоне): правка шире «строк слота» (С-3).
- `mobile/.maestro/config.yaml`: строки исключения флоу, по прецеденту 138 — допустимо.
- Нормативные файлы продукта (`AGENTS.md`, `STRUCTURE.md`, `structure-policy.json`, `eslint.config.js`, `src/theme`, `src/i18n`): `git diff --stat` пуст.

Атомарность: два коммита OBJECT-цепочки (877960c, 74671ab), каждый — одна задача со ссылкой «147», автор `implementer`.

## 2. Сырой вывод (своя мера, копия Rev147 @OBJECT)

| Команда (`cwd` = `mobile/`, если не указано иное) | rc | Вывод |
|---|---|---|
| `npx jest --ci src/features/conversation` (и через `reslop t --`) | 0 | 3 сьюта, **28** тестов |
| `npx jest --ci src/bootstrap/__tests__/gespraech-ekran.test.tsx --verbose` | 0 | 1 сьют, **16** тестов |
| `npx jest --ci --verbose src/features/conversation src/bootstrap/__tests__/gespraech-ekran.test.tsx` | 0 | **44** = 28 + 16 |
| `npx jest --ci --runInBand` (весь продукт) | 0 | **19** сьютов, **193** теста |
| `npm run typecheck` | 0 | tsc канона знака |
| `npx tsc --noEmit` | 0 | — |
| `npx eslint . --max-warnings=0` | **1** | `gespraech-dvizhenie.test.ts:42:11 warning … @typescript-eslint/array-type` — 1 проблема; на этом держится шаг-вынос Б-1 |
| `npm run lint` (= `check-structure.cjs && eslint`) | **1** | 25 строк «file outside allowed location/type»: `.harness/*` 5 · `e2e-erstinformation/*` 8 · `e2e-first-run/*` 8 · `bootstrap/__tests__/kompozicija.stand-in.sh` 1 · `e2e-gespraech-vhod/*` 3 |
| пробный merge `origin/main` в копию + `node scripts/check-structure.cjs` | 1 | `.harness/*` исчезли (возраст ветки — ожидаемо). Остались 17 предсуществующих (не 16, С-7) и 3 файла пачки 147 (по контракту) |
| `node mobile/scripts/select-ci-screens.cjs --mode inventar --repo .` (`cwd` = корень) | **1** | `VYBOR_OTKAZ: PACHKA_BEZ_REGISTRACII: mobile/e2e-gespraech-vhod/` (С-1) |
| `bash <H>/fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo <копия> --ekran 147` | **2** | `NOT_IMPLEMENTED: батарея ekrannyj_nabor_158 не построена` — именованный rc 2 критерия 1, не зелень (ожидаемо) |
| `python3 <H>/scripts/sverka_maketa.py --manifest kadry.json --kadry Impl147i/maestro-out-gespraech --repo <sv-repo>` | 0 | GA-15 d/l 0.839/0.846 · GA-16 d/l 0.670/0.859 (порог 0.600) |
| то же, `kadry_profil.json` | 0 | GA-15 d/l 0.831/0.835 · GA-16 d/l 0.668/0.856 |
| `sha256sum -c SHA256SUMS` (эталонные кадры, ctxroot-mob) | 0 | 12/12 OK (GA-01/15/16) |

Числа отчётов (44 / 193 / 8 оценок сверки) своей мерой подтверждаются. Своя мера для `sverka_maketa` — та же программа, но свой вызов и своя раскладка `--repo`. Независимая мера кадров — глаз, раздел «Сверка с макетом».

## 3. Проверка не переписана под реализацию

- Impl147i (`877960c..OBJECT`) в тестах только добавил две пробы: `gespraech-vhod.test.tsx` +18, `gespraech-ekran.test.tsx` +16/−1 (импорт `act`). Пороги, зоны и карта не ослаблены.
- Инструмент `gespraech-proba.ts` консервативен. `poli()` считает `padding`/`paddingHorizontal` один раз, а не дважды — это занижение зоны, ложная зелень от него невозможна. Без явного бокса, min и padding зона равна 0, то есть красная.
- `KARTA_147` == frozen `karta.json`: своя мера — `git show 28e2696f9:…/karta.json | python3` — 13 целей, 13 обязательных; состояния и постусловия совпадают построчно.

Исправление Impl147i (`mitte-button.tsx`):
- одно решение на касание;
- снятие таймера при размонтировании;
- одни часы для длительности;
- порог `press-long` — токен темы, не тронут.

Дифф соответствует описанию. Корень Б-2 этим исправлением не закрыт: дефект старше.

## 4. Красное предъявлено (своя мера)

| Мутант (копия Rev147) | Прогон | Результат |
|---|---|---|
| `mitte-button.tsx@877960c` (до правки Impl147i) | `jest gespraech-vhod.test.tsx gespraech-ekran.test.tsx` + проба Б-2 | rc 1; красные «поздний таймер удержания не перебивает решение отпускания» ×2 профиля, «короткое касание: меню остаётся открытым после порога удержания» ×2, проба Б-2 |
| M1: `wartender = host.wartenderVorgang` («Ansehen» в обычном меню, класс 11) | `jest src/features/conversation + gespraech-ekran` | rc 1; 4 красных «обычное меню не выдаёт цели ждущего дела…» (слайс и композиция × 2 профиля) |
| M2: «×» `height/minHeight/width` = 36 | то же | rc 1; 4 красных «зона касания хозяина не меньше нормы пакета» |
| проба Б-2 на OBJECT | `zzrev-a11y.test.tsx` | rc 1; `gespraech-menu` → null после голоса (контроль на свежем рендере ✓) |
| простая форма Б-1: `Array<{…}>` → `{…}[]` | `eslint . --max-warnings=0`; `jest src/features/conversation`; `tsc --noEmit` | rc 0; 28/28; rc 0 |

## 5. Сверка с макетом (слово владельца 2026-10-20; изображения просмотрены)

Эталоны: `E=/tmp/dev-harness-verify/ctxroot-mob/docs/ux/05_Kompakt_D24/frames/`, sha == SHA256SUMS == `piny.json`.
Кадры: `L=/tmp/dev-harness-verify/Impl147i/maestro-out-gespraech/`.
Пары «эталон | кадр» и увеличения: `/tmp/dev-harness-verify/Rev147/crops/`.

Числа сверки 123 проходят порог, но кадры визуально расходятся с эталоном по цвету, наполнению и обрезке. Масштаб раскладки совпадает: пилюли 320 × 52 pt, x 35–355, верх «Sprechen» ≈ 514 pt против 516 в эталоне; «×» и знак — на своих местах. Статус-бар Android и полоса жестов лежат внутри масок 36/48 и 20 — оговорено И-8.

| Кадр | Эталон | Живой кадр | Расхождения |
|---|---|---|---|
| GA-15 dark 390 | `E/GA-15_menu_dark_390x844.png` | `L/dark/2026-11-04_213153/gespraech-vhod/takeScreenshot/gespraech-ga-15.png` | (а) фон сплошной чёрный, без размытого Start под scrim (Б-4.1); (б) иконки Schreiben/Foto/Brief невидимы — белое на светлом круге (Б-3.1; `crops/ga15d390-pills.png`); (в) Roboto bold вместо DM Sans, надписи крупнее (Б-4.3) |
| GA-15 light 390 | `E/GA-15_menu_light_390x844.png` | `L/light/2026-11-04_213224/gespraech-vhod/takeScreenshot/gespraech-ga-15.png` | (а) фон без подложки; (б) «Sprechen» чёрная с белым кругом вместо лаймовой (Б-4.2); (в) иконки — заглушки-блоки, не контурные иконки (Б-3.1); (г) гарнитура |
| GA-15 dark 393 | `E/GA-15_menu_dark_393x852.png` | `L/dark/2026-11-04_213327/gespraech-vhod-393/takeScreenshot/gespraech-ga-15-393.png` | как dark 390: подложка, невидимые иконки, гарнитура (`crops/p-ga15-d393.png`) |
| GA-15 light 393 | `E/GA-15_menu_light_393x852.png` | `L/light/2026-11-04_213357/gespraech-vhod-393/takeScreenshot/gespraech-ga-15-393.png` | как light 390: подложка, чёрная «Sprechen», иконки-заглушки, гарнитура |
| GA-16 dark 390 | `E/GA-16_menu_dark_390x844.png` | `L/dark/2026-11-04_213153/gespraech-vhod/takeScreenshot/gespraech-ga-16.png` | (а) карточка Vorgang: строка группы срезана сверху, заголовок в 2 строки, «freigeben» срезан снизу, нет статус-точки, кегль заголовка больше (Б-3.2; `crops/ga16d390-card.png`); (б) подложка (в эталоне — размытый раздел Vorgänge); (в) невидимые иконки; (г) вопрос «Wie möchten Sie weitermachen?» жирнее и крупнее; (д) гарнитура |
| GA-16 light 390 | `E/GA-16_menu_light_390x844.png` | `L/light/2026-11-04_213224/gespraech-vhod/takeScreenshot/gespraech-ga-16.png` | (а) карточка: перелив текста за кромки, нет точки (`crops/ga16l390-card.png`); (б) чёрная «Sprechen»; (в) иконки-заглушки; (г) подложка; (д) гарнитура |
| GA-16 dark 393 | `E/GA-16_menu_dark_393x852.png` | `L/dark/2026-11-04_213327/gespraech-vhod-393/takeScreenshot/gespraech-ga-16-393.png` | как dark 390: обрезанная карточка без точки, невидимые иконки, подложка, гарнитура |
| GA-16 light 393 | `E/GA-16_menu_light_393x852.png` | `L/light/2026-11-04_213357/gespraech-vhod-393/takeScreenshot/gespraech-ga-16-393.png` | как light 390 (`crops/p-ga16-l393.png`) |
| GA-01 dark 390 (без сверки, слово владельца 2026-10-31) | `E/GA-01_normal_dark_390x844.png` | `L/dark/2026-11-04_213153/gespraech-vhod/takeScreenshot/gespraech-ga-01.png` | содержимое Start — прежнее (Start D 2.4 — отдельный предмет, оговорено). Таб-бар: «Vorgäng\|e» перенос; «Start» (выбрана) почти невидима; Mitte — голый знак без пилюли и подписи «Gespräch» (С-3, С-10) |
| GA-01 light 390 | `E/GA-01_normal_light_390x844.png` | `L/light/2026-11-04_213224/gespraech-vhod/takeScreenshot/gespraech-ga-01.png` | то же; «Start» видима (`crops/p-ga01-l390.png`) |
| GA-01 dark 393 | `E/GA-01_normal_dark_393x852.png` | `L/dark/2026-11-04_213327/gespraech-vhod-393/takeScreenshot/gespraech-ga-01-393.png` | то же (`crops/p-ga01-d393.png`) |
| GA-01 light 393 | `E/GA-01_normal_light_393x852.png` | `L/light/2026-11-04_213357/gespraech-vhod-393/takeScreenshot/gespraech-ga-01-393.png` | то же (`crops/p-ga01-l393.png`) |

Доказательство корневой причины.
- `frames/f002.png`: меню (светлая тема, вход анимации).
- `frames/f010.png`: голос поверх Start — последовательность подтверждена.
- `rec.mp4` с таблицей отчёта не совпадает: кадров меню в нём нет, видны start → голос (С-6).

Механизм доказан независимо: пробы Impl147i красны на коде до правки (§4).

## 6. Граница ленда и предпосылки

- CI-проводка экрана не добавлена: в `ci-screens.json` дифф пуст, работника `e2e-gespraech-vhod` в `mobile.yml` нет. Посторонний шаг в `quality` — Б-1.
- Push: удалённой ветки-трекера `wip/147*` в клоне исполнителя нет. `ls-remote` отказан (rc 128, «Repository not found»). Продуктовый чекаут `/home/harness/projects/Complior-mob` OBJECT не знает. [INFERENCE] push не выполнялся.
- Ленд невозможен и после принятия: `quality` красен на инвентаризации пачки без записи карты (С-1), а это противоречие критериев 3 и 4 — к architect/оркестратору.
- Расхождения `pachka/*.yaml` (Impl147h §2.1, Impl147i §6) закрыты флоу продукта. Правка пачки цикла 2 для приёмки 147 не нужна (С-9, совет).

## ПРОВОДКА (контракт 038)

- `guard=fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh` существует в харнессе (HEAD 046dff183). На этой копии он честно красен: rc 2 `NOT_IMPLEMENTED`. Это барьер набора 158, предназначенный для `--ekran 147`, а не произвольный скрипт.
- ПРОВОДКА-ЭНФОРСМЕНТ обоснован: поведенческой нормы роли нет, предмет — экран продукта. Принимается.

## Паразитная сложность (контракт 050)

Ответы на пять вопросов по каждому артефакту диффа:

- `kompakt-tokens.ts`:
  1. И-6 (токены 1.1);
  2. константы, состояние явно;
  3. после 148 одно свойство живёт в двух файлах (`kompakt-tokens` + `theme/nav-tokens`) — число выросло;
  4. мелкий модуль констант;
  5. потребители — компоненты и `tab-shell`; повторяет проекцию 148.

  ESSENTIAL до ленда 148, далее ACCIDENTAL (С-2).
- `mocks/gespraech-proba.ts`:
  1. И-1…И-3 для критерия 2;
  2. без состояния;
  3. `karta.json` + `KARTA_147` меняются вместе — двое против одного;
  4. умеренная глубина;
  5. потребители — два тест-файла; повторяет общий хелпер 158, которого ещё нет.

  ESSENTIAL до 158, место — С-4.
- `bootstrap/__tests__/gespraech-ekran.test.tsx`:
  1. И-1 по всей карте;
  2. нет;
  3. —;
  4. —;
  5. в строке приёмки (критерий 2) не исполняется.

  ESSENTIAL по свойству, вне зоны — Б-5.
- `gespraech-vhod-tokeny.test.tsx`:
  1. И-6, подмена меняет поведение;
  2. мок модулей, явно;
  3. 1;
  4. глубокий;
  5. критерий 2.

  ESSENTIAL.
- `vorgaenge-row.tsx`:
  1. И-1, вход `menu_vorgang`;
  2. нет;
  3. 1;
  4. —;
  5. карта + Maestro.

  ESSENTIAL.
- `mitte-button.tsx`, четыре ref-состояния (`nachalo`, `nachaloChasov`, `pokolenie`, `sostoyanie`):
  1. И-7, одно решение;
  2. неявно — только побочным эффектом, в выводе не видно;
  3. 1;
  4. интерфейс прежний;
  5. пробы Impl147i.

  `pokolenie` — ACCIDENTAL (простая форма: `clearTimeout` в `onPressIn` проходит те же пробы; С-5, совет). Терминальное `'resheno'` — дефект Б-2.
- Шаг `mobile.yml` «Вынос канона 147»:
  1. нет свойства лёгкого контракта: пина в `piny.json` нет;
  2. перенос файла из дерева, только побочным эффектом;
  3. 2 файла;
  4. —;
  5. потребитель — lint, но тот же lint проходит однострочной правкой.

  ACCIDENTAL с фрагментом, отсутствующим свойством и более простой формой — блокирует (Б-1).
- `e2e.sh`, `kadry.json`, `kadry_profil.json`:
  1. И-8/И-9 (критерий 3);
  2. env-параметры названы явно в шапке;
  3. —;
  4. —;
  5. критерий 3, CI после валидатора.

  ESSENTIAL.
- Флоу `.maestro/gespraech-*`: И-8/И-9 и правило «экран со сценарием Maestro» AGENTS.md. ESSENTIAL.
- `pill-icon.tsx`: свойство — иконки GA-15/16. Реализация заглушками даёт расхождение с макетом (Б-3).
- `copy.ts`: свойство — надписи из `copy-de` 1.1. Шапка устарела (С-8).

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта не объявляет `docs/ARCHITECTURE.md` / `docs/CODING-STANDARDS.md`. Объявлены `STRUCTURE.md` + `mobile/structure-policy.json` и приоритет источников (§«Источники истины»).

СВЕРКА-СТАНДАРТОВ:
- STRUCTURE.md §«Куда класть код» п.6 (mocks = синтетический runtime) — расхождение: `mobile/src/mocks/gespraech-proba.ts:1-13`, измерительный инструмент тестов в runtime-слое моков (С-4).
- STRUCTURE.md §направления импортов (стр. 153-160) — соответствует: eslint-границы зелёные; единственное замечание eslint — `array-type` в канон-тесте (Б-1).
- STRUCTURE.md §Design/theme (стр. 180-181) — расхождение:
  - `mobile/src/features/conversation/kompakt-tokens.ts:1-115` — собственный размерный ряд экрана (С-2);
  - `menu-overlay.tsx` — стили текста без DM Sans (Б-4.3; подключения шрифта нет во всём продукте).
- STRUCTURE.md §тесты (стр. 190) — соответствует: сьют слайса колоцирован в `features/conversation/__tests__/`, проба композиции — у слоя `bootstrap` (зона — Б-5).
- AGENTS.md §«Источники истины» п.3 (Kompakt 1.1 реализуется нативно; `tokens.ts` — производная, не второй канон) — расхождение:
  - `kompakt-tokens.ts` — второй канон токенов (С-2);
  - `menu-overlay.tsx:295-304` и `pill-icon.tsx` — иконки не по эталону (Б-3);
  - `menu-overlay.tsx:197-240` — карточка Vorgang не по эталону (Б-3).
- AGENTS.md §«Как работаем» (экран — со сценарием Maestro и скриншотом) — соответствует: 3 флоу, 12 PNG.
