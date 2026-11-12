FAIL
OBJECT=08c3267c7bb260f604f30300248712eb72ffd910
КЛАСС=кодовый; риск=обычный (подтверждён: экран UI на пилот-моке; прав/ролей, авторизации, сети, денег, ПД нет — повышать не основание)
СУД: repo=Complior-mob (PR a3ka/Complior-mob#169, ветка wip/147/implementer-rebuild); предмет=147 (gespraech-vhod-menu); фаза=реализация; роль=reviewer; вызов=1/1 (повторный полный по новому OBJECT после FAIL impl-v1); модель-план=anthropic/claude-opus-5-5; сессия=Rev147v2 (c907157c); модель-факт=anthropic/claude-opus-5-5; предыдущий=verdicts/review/contracts-147-impl-v1.md

# Вердикт reviewer — 147 gespraech-vhod-menu, реализация v2

Контракт: `frozen/contracts/147/4` → `4c9f1722b28a810263c7705063d3b0489d37e830` (тега в origin харнесса нет; блоб и `fixtures/workshop_project/gespraech_vhod_147/` взяты из основного чекаута только чтением: `git fetch /home/harness/dev-harness 4c9f1722…` → одноразовый worktree `h147f4`). Критик accept: `verdicts/critic/contracts-147-v4.md`.
Находки reslop: `.review/2026-11-12-01.md` (`status: ready`; в клоне `/tmp/dev-harness-verify/Rev147v1/repo`, в коммит не входит — по заданию).
Клоны: продукт `/tmp/dev-harness-verify/Rev147v1/mob` (`git rev-parse HEAD` = OBJECT), харнесс `/tmp/dev-harness-verify/Rev147v1/repo`. Мутанты и пробы — только в одноразовом worktree `mobmut` (после каждого `git checkout -- .`, 0 грязных путей); чистый main продукта — worktree `mobmain` @ `cbb254fe8`.

**Итог.** По коду всё, что исполнимо без эмулятора, зелёное: зона чистая, overlay побайтово равен голове `08c525d58`, jest 220/220, критерий 2 — 60/60, typecheck/tsc/eslint rc 0, 995 rc 0, пины `red_maket_147.py` rc 0, мои мутанты Б-4 красны. FAIL только по одной причине: **нечем сверить**. Живых кадров эмулятора GA-15/GA-16 для этого кода нет нигде. CI PR #169 их не снимет по построению. Без кадров мобильный экран не принимается (слово владельца 2026-10-20). Повтор — scoped: только сверка 8 кадров с макетом и `red_maket_147.py --screens`.

## БЛОКИРУЕТ

| ID | Обязательство | Наблюдение (своя мера) | Класс | Кто закрывает |
|---|---|---|---|---|
| Р147-Б1 «нечем сверить» | roles/reviewer.md §«Мобильный экран — сверка с макетом» (слово владельца 2026-10-20): «без скриншотов кадров вердикт по мобильному экрану — FAIL "нечем сверить"». Контракт 147/4: критерий 3 (кадры сохранены `takeScreenshot` и совпадают с PNG-макетами по составу, раскладке, шрифту, цвету; `red_maket_147.py --screens <R>/mobile/maestro-out-gespraech` → rc 0). И-10: «Начертание судится кадрами против макета». НЕ ЗАЩИЩАЕТ: «недоступность фона касанию и динамику проверяет ревьюер на живых кадрах/AVD». Порядок: «живые кадры 8/8 против макета + пробы SPEC §7». | (1) Run CI `43163960107` содержит только jobs `select-screens` и `quality` (оба queued). (2) В `mobile/ci-screens.json` записи gespraech нет: критерий 4 запрещает её до ленда лёгкого режима валидатора. (3) `.maestro/config.yaml` исключает `gespraech-*.yaml` из общего прогона. Поэтому кадров GA-15/GA-16 CI этого PR не даст ни при каком исходе. (4) `find /tmp/dev-harness-verify -maxdepth 6 -name 'gespraech-ga-15*.png' -newermt 2026-11-11` → 0 файлов. Последние живые кадры — Impl147i от 2026-11-04 (OBJECT impl-v1). Это код до Б-4: в них Roboto, чёрная «Sprechen» и плоский фон. (5) `red_maket_147.py` без `--screens` → rc 2 «--screens required». Задание implementer v4 говорит: «кадры эмулятора снимет CI». Это расходится с (1)–(3). | недостающее доказательство (предпосылка), не дефект кода | orchestrator: маршрут к кадрам — живой `e2e.sh` на AVD профилей 390/393 (у станции их нет — §Существующее 147/4) либо ленд лёгкого режима валидатора и работник CI по лекалу 143/2. Затем reviewer — scoped-повтор: 8 кадров + `--screens` |

Других блоков нет.

## Прежние находки impl-v1 (перепроверены все пять)

| ID | Было | Сейчас (своя мера) | Статус |
|---|---|---|---|
| Б-1 | чужие тела `mobile.yml` | `git diff origin/main HEAD --stat -- .github/workflows/mobile.yml mobile/ci-screens.json` — пусто | закрыт |
| Б-2 | сброс состояния касания Mitte | `mitte-button.tsx:124` сбрасывает `'net'` по завершении жеста. Тест «активация доступности после голоса открывает меню» зелёный ×2 профиля | закрыт |
| Б-3 | иконки пилюль / карточка Vorgang | `pill-icon.tsx` переписан (новых зависимостей нет: `package.json` и lock не тронуты). Визуально не подтверждено — нет кадров (Р147-Б1) | код изменён; сверка — в Р147-Б1 |
| Б-4 | подложка / палитра / шрифт | Код: `filter: [{ blur: 14 }]` на живом содержимом, `pointerEvents="none"`; пилюля `tokens.accent`; `useFonts` + `return null` в `app/_layout.tsx`; `fontFamily: 'DM Sans'`; `fonts.ts` удалён, висячих импортов нет (`git grep "from .*fonts"` → rc 1). Пины: rc 0. Мутанты красны (§3) | код закрыт; пиксели — Р147-Б1 |
| Б-5 | проба композиции вне зоны | `gespraech-ekran.test.tsx` — строка `ЗОНА implementer` 147/4. Команда критерия 2 → rc 0, 60 тестов | закрыт |

## 1. Область правки

```
$ git diff origin/main...HEAD --stat     # merge-base = cbb254fe8786805aecb9190a53ebe21acbc06952 = origin/main
34 files changed, 4348 insertions(+), 50 deletions(-)
```

Все 34 пути лежат под семью зонными строками implementer 147/4:
- `features/conversation/` — 23 пути;
- `.maestro/` — 4;
- `e2e-gespraech-vhod/` — 3;
- `mocks/gespraech-proba.ts`, `bootstrap/tab-shell.tsx`, `bootstrap/__tests__/gespraech-ekran.test.tsx`, `app/_layout.tsx` — по одному.

```
$ git diff --stat 08c525d588a35a7277a601210d0b44cfe9692e6a HEAD -- <34 пути>                         → пусто (rc 0)
$ git diff --name-only 08c525d5… HEAD -- mobile/src/features/conversation mobile/.maestro mobile/e2e-gespraech-vhod \
    mobile/src/mocks mobile/src/bootstrap/tab-shell.tsx mobile/src/bootstrap/__tests__/gespraech-ekran.test.tsx mobile/src/app/_layout.tsx → пусто
$ git diff origin/main HEAD --stat -- .github/workflows/mobile.yml mobile/ci-screens.json mobile/package.json mobile/package-lock.json mobile/src/theme → пусто
```

Overlay побайтово равен голове `Impl147v4` `08c525d58`. Каталоги зоны совпадают целиком: лишних и потерянных файлов нет. Файлы темы 148/999 и зависимости не тронуты.
Атомарность: OBJECT — один коммит `08c3267` (автор `implementer`, тема «147 gespraech-vhod-menu: пересборка…») поверх `cbb254fe8`.

## 2. Сырой вывод (своя мера, клон `mob` @ OBJECT, `cwd=mobile/`)

| Команда | rc | Вывод |
|---|---|---|
| `npm ci --no-audit --no-fund` | 0 | added 1114 packages |
| `npm test -- --ci` | 0 | `Test Suites: 22 passed, 22 total` · `Tests: 220 passed, 220 total` |
| `npx jest --ci --verbose src/features/conversation src/bootstrap/__tests__/gespraech-ekran.test.tsx` (критерий 2) | 0 | `Test Suites: 6 passed` · `Tests: 60 passed, 60 total`. По сьютам: dvizhenie 7, vhod-tokeny 3, garnitura 3, fon 3, vhod 20 (10×2 профиля), ekran 24 (12×2) |
| `npm run typecheck` | 0 | `tsc --noEmit -p src/lib/faden/tsconfig.json` |
| `npx tsc --noEmit` | 0 | — |
| `npx eslint --max-warnings=0 src` | 0 | — |
| `python3 <H>/fixtures/workshop_project/pilot_995/bundle_probe.py --repo <mob>` | 0 | `995 bundle/actual/http: rc=0 maps=1 sources=51` · `…/mock: rc=0 maps=1 sources=53` |
| `red_maket_147.py --reference <mob>/docs/ux/05_Kompakt_D24/frames --product <mob> --check font` (worktree 147/4) | 0 | `DM_SANS_ZAGRUZHEN_PRIMENEN frames=0` |
| то же `--model` | 0 | 8 кадров `: all` + `DM_SANS_ZAGRUZHEN_PRIMENEN frames=8` |
| то же `--stubs` | 0 | `flat_scrim: PODLOZHKA_NE_RAZMYTA` · `black_sprechen_light: SPRECHEN_NE_LAIM` · `stale_image: PODLOZHKA_ZASTYLA` · `font_in_comment: DM_SANS_NE_ZAGRUZHEN` · `font_not_applied: DM_SANS_NE_PRIMENEN` |
| то же без `--screens` | 2 | `--screens required except in --model/--stubs` — кадров нет (Р147-Б1) |
| `bash <H>/fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo <mob> --ekran 147` | 2 | `ПРИЧИНА KARTA_EKRANA_NET: нет toy-корня пачки (NABOR_158_TOY_ROOT)`. Это именованный rc 2 критерия 1 до готовности 158, не зелень |
| `node scripts/check-structure.cjs` | 1 | на main 17 предсуществующих строк. На OBJECT те же 17 плюс 3 строки `e2e-gespraech-vhod/{e2e.sh,kadry.json,kadry_profil.json}` (известное (г); путь пачки задан критерием 3) |

999-пробы: `python3 <H>/fixtures/workshop_project/nav_999/<проба>.py --repo <R>`, OBJECT против чистого main.

| Проба | OBJECT | main `cbb254fe8` |
|---|---|---|
| `ui_probe` | rc 1. 17/18 клеток rc 0; красная ровно одна: `999 ui/SHELL_CONTAINER_PROFILE: rc=1` | rc 0, 18/18 |
| `nav_probe` | rc 0 | rc 0 |
| `copy_probe` | rc 0 | rc 0 |
| `shell_static_probe` | rc 0 (`FONTS_PRESENT` sha256 совпал, `LITERAL_PALETTE` без hex) | rc 0 |

Уточнение к известному (а). На чистом main клетка **зелёная**, красной её делает 147. Формулировка «до/после правки 147 красная клетка та же» верна только относительно головы 147 (`08c525d5`): коммит OBJECT пишет то же. Других ухудшений нет. Причина — противоречие замороженных контрактов:
- `nav_999/ui.test.tsx:112-123` требует `shell-profile-entry` после входа в профиль;
- `karta.json` 147/4 объявляет `profil.vhod=shell-profile-entry`, а цель — `sostojanja: ['start']`.

Решение — за владельцем, реализации не вменяется.

## 3. Красное предъявлено (своя мера: мутанты в `mobmut`)

Прогон: критерий 2 плюс `red_maket_147.py --check font`.

| Мутант | Обязательство | jest критерия 2 | `--check font` |
|---|---|---|---|
| `tokens.ts` light `accent` → `#121211` (подмена значения токена в копии) | И-6 | rc 1, 2 failed / 58 | rc 0 (не его ось) |
| пилюля `tokens.primary` вместо `accent` | И-6 / Б-4.2 | rc 1, 3 failed | rc 0 |
| `filter` снят с подложки | И-5 / Б-4.1 | rc 1, 3 failed | rc 0 |
| `pointerEvents="auto"` на подложке | И-5 | rc 1, 3 failed | rc 0 |
| подложка GA-16 = GA-15 (`pokrytayaSekciya = section`) | И-5 (застывшая подложка) | rc 1, 2 failed | rc 0 |
| `useFonts` снят из `_layout.tsx` | И-10 | rc 0 (60/60) | **rc 1 `DM_SANS_NE_ZAGRUZHEN`** |
| снято удержание кадра (`return null` до готовности) | И-10 (удержание) | **rc 0 (60/60)** | **rc 0** — пина нет (С-1) |
| `fontFamily` снят с названия пилюли | И-10 (применение) | rc 1, 3 failed | rc 0 |

Каждая ось Б-4 краснеет хотя бы одним барьером. Исключение — удержание первого кадра. Реализация его исполняет (`_layout.tsx:20-22`), но красного пина у него нет (С-1).

Проверка реальной композиции. Одноразовый тест в `mobmut`: `StartDestination` (TabShell + слот `StartSections`), нажатие `gespraech-mitte`. Вывод:

```
START_SECTIONS_V_MENU 1
START_LINKS 4 all_under_pointerEvents_none true
START_CELI_V_MENU []
FON_A11Y_SKRYT []
```

- Живой Start смонтирован под размытием, жест не принимает.
- Целей карты из состояния start в меню нет.
- Подложка не скрыта от службы доступности (С-2).

## 4. Проверки не подогнаны под код

- Пачка не менялась с OBJECT impl-v1: `git -C Impl147v4/mob diff --stat 74671ab3c 08c525d58 -- mobile/e2e-gespraech-vhod mobile/.maestro mobile/src/mocks/gespraech-proba.ts` пуст. Это `kadry.json`, `kadry_profil.json`, `e2e.sh`, флоу и инструмент пробы.
- Карта кадров:
  - 4 записи на профиль, порог 0.6;
  - `chrome_verh_pt` 36 / 48;
  - `maket_sha256` совпадают с `frames/SHA256SUMS`;
  - имена — записи пакета.
- Удалённые строки тестов `74671ab3c..08c525d58`:
  - смена хелпера `renderEkran` (теперь со схемой);
  - тип `Array<…>` → `T[]` (закрытие Б-1);
  - строка комментария.

  Ни одно ожидание не ослаблено.
- `git grep -nE '(it|test|describe)\.(skip|only|todo)|x(it|describe|test)\(|f(it|describe)\('` по `features/conversation` и пробе композиции → rc 1, совпадений нет.

## 5. Сверка с макетом (слово владельца 2026-10-20)

Эталоны: `<mob>/docs/ux/05_Kompakt_D24/frames/`, sha == SHA256SUMS (§4). Я открыл как изображения:
- `GA-15_menu_light_390x844.png`: размытый Start под светлым scrim, лаймовая «Sprechen» с тёмным кругом, DM Sans;
- `GA-16_menu_dark_390x844.png`: размытый раздел Vorgänge с карточками, карточка ждущего дела с «Ansehen».

| Кадр | Макет | Кадр продукта | Расхождение | Класс |
|---|---|---|---|---|
| GA-15 light 390 | `frames/GA-15_menu_light_390x844.png` | нет (CI не снимает, локальных нет) | не сверено | Р147-Б1 |
| GA-15 dark 390 | `frames/GA-15_menu_dark_390x844.png` | нет | не сверено | Р147-Б1 |
| GA-16 light 390 | `frames/GA-16_menu_light_390x844.png` | нет | не сверено | Р147-Б1 |
| GA-16 dark 390 | `frames/GA-16_menu_dark_390x844.png` | нет | не сверено | Р147-Б1 |
| GA-15 light 393 | `frames/GA-15_menu_light_393x852.png` | нет | не сверено | Р147-Б1 |
| GA-15 dark 393 | `frames/GA-15_menu_dark_393x852.png` | нет | не сверено | Р147-Б1 |
| GA-16 light 393 | `frames/GA-16_menu_light_393x852.png` | нет | не сверено | Р147-Б1 |
| GA-16 dark 393 | `frames/GA-16_menu_dark_393x852.png` | нет | не сверено | Р147-Б1 |

Кадры CI не получены. Ожидание по заданию: run `43163960107` наблюдался с 05:55Z, опрос ≤ 5 мин, предел 60 мин. Итог — в §6. Риски для будущей сверки — [INFERENCE], не находки:
- (Н-5) подложка GA-16: раздел Vorgänge оболочки несёт только заголовок (`tab-shell.tsx`, `fonMenu`), в макете под размытием — карточки дел;
- (Н-6) переменный `DMSans-Variable.ttf` под одним семейством с `fontWeight: '600'` на Android: начертание жирных строк не доказано без кадра.

## 6. CI PR #169

```
$ gh pr checks 169 --repo a3ka/Complior-mob          (rc 8)
quality         pending  …/runs/43163960107/job/131001356866
select-screens  pending  …/runs/43163960107/job/131001356584
$ gh run list --repo a3ka/Complior-mob --status queued
queued … 162 Ф-4 …  43116196851  (с 03:43Z)
queued … 148 …      43161917403  (с 05:31Z)
queued … 147 …      43163960107  (с 05:49Z)
runners: station-complior online busy=true · station-complior-2 offline
```

Красных или зелёных job'ов на момент вердикта нет: всё в очереди за 162 и 148, онлайн один раннер. Эмуляторных jobs для 147 в run нет по построению (известное (в), критерий 4).

## Советы (не блок)

| ID | Кто | Суть |
|---|---|---|
| С-1 | architect (пины 147) | У обязательства И-10 «удержание первого кадра» нет красного барьера. Мутант без `return null` зелёный на jest 60/60 и на `--check font` rc 0. Реализация удерживает. Ловец — пин `useFonts` → ранний возврат до готовности либо кадр (Roboto в первом кадре) |
| С-2 | implementer | Подложка меню видна службе доступности. На реальной композиции `StartDestination` в `gespraech-menu-fon` 4 `Pressable` `start_tab_*` (role `link`) под `pointerEvents="none"`, но без `importantForAccessibility="no-hide-descendants"` / `accessibilityElementsHidden`. TalkBack сможет фокусировать размытые ссылки за модальным меню. Это CODING-STANDARDS §11. Проба композиции рендерит `TabShell` без слота `startScreen` и этого не видит |
| С-3 | implementer | CODING-STANDARDS §5. Новый сквозной относительный импорт `'../features/conversation'` (`tab-shell.tsx:36`; ЦЕЛЬ стандарта — «меняются при правке файла») и `require('../../assets/fonts/DMSans-Variable.ttf')` (`_layout.tsx:18`) вместо `@/…` / `@/assets/*` |
| С-4 | implementer | Флаг `dekorativny` в `TabBar` (`tab-shell.tsx`) дублирует разметку надписи вкладки в двух ветвях. Проще: один `Text`, ветвится только обёртка (`View` или `Pressable`). Строки приёмки прошли бы так же. ACCIDENTAL без блока |
| С-5 (из impl-v1 С-2/С-4) | implementer / 148 | `kompakt-tokens.ts` (+69 строк) остаётся вторым набором размерных токенов рядом с `theme/`. `mocks/gespraech-proba.ts` — измерительный инструмент в runtime-слое моков. Без изменений с impl-v1 |

## Наблюдения

- Н-1 — известное (а), см. §2: клетка `ui/SHELL_CONTAINER_PROFILE` введена 147 относительно чистого main. Это противоречие 999 ↔ 147/158, решение за владельцем.
- Н-2 — известное (б):
  - `KARTA_147` в `mocks/gespraech-proba.ts` хранит ключ `sostojania`, `karta.json` пачки — `sostojanja`;
  - постусловия `perehod`/`vyzov` — зона 158/architect.
- Н-3 — известное (в): CI красен или не судит экран до ленда лёгкого режима валидатора. Запись в `ci-screens.json`/`mobile.yml` верно отсутствует.
- Н-4 — известное (г): `check-structure` +3 строки пачки 147, того же класса, что предсуществующие `e2e-*`.
- Н-5, Н-6 — риски будущей сверки (§5).
- Н-7 — конфликт ленда `tab-shell.tsx` с 148 (PR #168) назван в сообщении коммита OBJECT. Порядок 147 → 148 → 149 заморожен.

## ПРОВОДКА (контракт 038)

- `guard=fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh` есть в origin/main харнесса и исполнен на OBJECT: rc 2 `KARTA_EKRANA_NET`, именованное «не готово». Это барьер набора 158 для `--ekran 147`, не произвольный скрипт.
- ПРОВОДКА-ЭНФОРСМЕНТ обоснован: поведенческой нормы роли нет. Принимается.

## Паразитная сложность (контракт 050) — артефакты дельты impl-v1 → OBJECT

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель | Вывод |
|---|---|---|---|---|---|---|
| `components/menu-backdrop.tsx` | И-5 (живая размытая подложка, без жеста) | нет; радиус из токена | 2 (`menu-backdrop` + `kompakt-tokens`) | интерфейс 1 prop, работа — фильтр и изоляция жеста | пробы fon/ekran, пин `--stubs` | ESSENTIAL |
| `zadimka.ts` | И-6 (scrim = цвет темы на прозрачности пакета, без литерала) | нет | 2 | 1 функция | `gespraech-fon.test.tsx` | ESSENTIAL |
| `app/_layout.tsx` (+17) | И-10 (регистрация и удержание) | `shriftGotov`/`oshibka` — явно, в возврате | 1 | без нового интерфейса | пин `--check font` | ESSENTIAL (удержание без красного пина — С-1) |
| `tab-shell.tsx`: `fonMenu`, `dekorativny`, `profileVisible` | И-5 (подложка перекрытого раздела), И-1/И-5 (профиль-вход только в start) | `pokrytayaSekciya` выводится из `rezhim` — явно | 1 | у `TabBar` +2 prop | проба композиции | `fonMenu`/`profileVisible` — ESSENTIAL; дубль ветвей `dekorativny` — ACCIDENTAL без блока (С-4) |
| `kompakt-tokens.ts` (+69) | И-6/И-7 (раскладка меню, радиус, прозрачность из пакета) | константы | растёт вместе с `theme/` 148 | мелкий модуль констант | компоненты, пробы | ESSENTIAL до ленда 148, далее С-5 |
| `__tests__/gespraech-fon.test.tsx`, `gespraech-garnitura.test.tsx`, +114 в `gespraech-ekran.test.tsx` | критерий 2 (И-5/И-6/И-10 на слайсе и композиции) | моки явны | — | — | строка критерия 2 | ESSENTIAL; мутанты §3 красны |

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта не объявляет `docs/ARCHITECTURE.md`. `docs/CODING-STANDARDS.md` существует (действует с 2026-11-04) и сверен по затронутым разделам.

СВЕРКА-СТАНДАРТОВ:
- CODING-STANDARDS §2 (слои, импорты) — соответствует: `eslint --max-warnings=0 src` rc 0, `features/conversation` не импортирует `bootstrap`/`app`.
- CODING-STANDARDS §5 (алиасы `@/…` через слои) — расхождение: `mobile/src/bootstrap/tab-shell.tsx:36`, `mobile/src/app/_layout.tsx:18` — относительные пути через слои (С-3).
- CODING-STANDARDS §6 (компоненты, `XProps readonly`, слоты) — соответствует: `MenuBackdropProps` readonly, подложка — композицией слотом `fon`.
- CODING-STANDARDS §10 (токены) — соответствует: hex только в `kompakt-tokens.ts`/`theme/tokens.ts`. Пилюля читает `tokens.accent`; `999 static/LITERAL_PALETTE` rc 0.
- CODING-STANDARDS §11 (доступность) — расхождение: `mobile/src/features/conversation/components/menu-backdrop.tsx:20-24` — подложка не скрыта от службы доступности (С-2).
- CODING-STANDARDS §13 (тесты, Maestro) — соответствует: тесты колоцированы, красный вход предъявлен (§3); `gespraech-vhod.yaml`: `assertVisible` перед `tapOn`, `takeScreenshot` на GA-01/15/16.
- STRUCTURE.md (место файлов) — соответствует, кроме известного (г).

## Что нужно для accept (scoped-повтор)

1. Восемь живых кадров `maestro-out-gespraech` с этого OBJECT или с его побайтового переноса: GA-15/GA-16 × light/dark × 390/393.
2. `red_maket_147.py --reference … --product <R> --screens <R>/mobile/maestro-out-gespraech` → rc 0.
3. Обе команды раннера 123 (`kadry.json`, `kadry_profil.json`): 8 оценок ≥ 0.600.
4. Глазная сверка каждого кадра с макетом: подложка, лаймовая «Sprechen», DM Sans, иконки и карточка (Б-3).

Код и прочие оси повтора не требуют, если OBJECT не меняется.
