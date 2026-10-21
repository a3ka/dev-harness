FAIL
Реализация 117 (OBJECT 74c4c58612388df11eed492863341bbfee87c6b1, Complior-mob PR#114, круг 2) закрыла все
находки круга 1, которые были на implementer (Р1, Р2, Р3, Р4, Р6). Splash dark и light теперь совпадают со
Splash.png и Splash-Hell.png в пределах ±3 px. Правило (В) кадры всё равно не проходят. Блокирует implementer:
**В2-1**, в светлой схеме иконки статус-бара белые на `#f3f2ee` (1,12:1), стиль статус-бара по схеме не выставлен.
Блокирует architect: **В2-3**, ссылки F03.02 light лаймом 1,08:1. Это велит инв. 6 117/1 вопреки D2.2.5.1
`accent-text` `#3f6d0f`. Ещё **В2-4**: First-Run не по First-Run.png, а 117/1 вывел First-Run из предмета вопреки
слову (А) 18:15. Батарея r6 (28+37) пп. 4, 2 и 1 не держит: **В2-2**, **В2-5**. По п.2 она даже пинит дефект.
Пункт 3 консультанта: подпись поля ЕСТЬ, это `label` TextField = body-ключ, по вопросу №6. Расхождение с README
TextField (отступ подписи, плейсхолдер) лежит в read-only `src/ui` и вместе с Р7 уходит форком.
Находки и чекбоксы: `/tmp/dev-harness-verify/Rev117r2/review.md` (status: ready).

Изображения вижу: открыл напрямую sheet2.png, mock.png и 8 полноразмерных кадров артефакта.
Сырьё: run 39560100954 (headSha = OBJECT, event pull_request, quality и android-e2e success, report-dark/light:
1 testcase SUCCESS), артефакт `maestro-117-cd6ecd87…-39560100954-1`, скачан `gh run download`. cd6ecd87 —
merge-sha. Стенд 1080×2400, 1 dp = 2,625 px, statusBars `[0..136]` px. Макеты:
`/tmp/dev-harness-verify/Impl117/mob/docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/{Splash,Splash-Hell,First-Run}.png`
(и `mock.png` консультанта). Кадры: `/tmp/dev-harness-verify/Rev117r2/f/<тема>-<кадр>.png` (копия артефакта).

## Покадровая сверка (правило (В)), координаты — моя мера

| Кадр | Скриншот | Макет | Что на кадре (видел сам) | Расхождения | Итог |
| --- | --- | --- | --- | --- | --- |
| dark / splash | `f/dark-splash.png` | Splash.png | Оверлей: знак ink + лаймовая точка, «complior», «Versicherung. Erledigt.» на `#0a0a0a`, статус-бар белый | Знак `[303..803]×[780..1261]` px при ожидании contain `[302..800]×[782..1258]`. Wordmark dp `165.3..245.7 × 554..575`, ожидалось `165.6..244.7 × 554..574`. Tagline `59.8..351.2 × 611..640`, ожидалось `60.1..350.2 × 612..640`. Ground точный. Расхождений нет | **PASS** |
| light / splash | `f/light-splash.png` | Splash-Hell.png | Тот же оверлей, знак `#121211`, ground `#f3f2ee` | Геометрия попиксельно как в dark (те же bbox). Иконки статус-бара `#ffffff` на `#f3f2ee`, 1,12:1, не читаются (`[60..250]×[40..100]` px) | **FAIL** (В2-1) |
| dark / first-run | `f/dark-first-run.png` | First-Run.png | Бейдж Demo в x=0, «complior» мелко слева, promise по центру, лаймовая CTA по контенту слева сразу под текстом | Wordmark dp `x0..60 y165..180`, в макете по центру сверху. Знака C нет. Подзаголовка нет. CTA dp `x0..261 y310..355`, в макете внизу во всю ширину ≈16..374. Футера нет. Двойной top-инсет (wordmark на 165 dp). Заголовок `x35.8..374.9` центрован и НЕ обрезан, утверждение консультанта не подтверждено | **FAIL** (В2-4, architect) |
| light / first-run | `f/light-first-run.png` | First-Run.png (light-варианта макета нет) | Promise чёрный, CTA чёрная пилюля, wordmark не виден | Всё, что в dark. Wordmark отрисован (1709 px `#f2f1ec`), но на `#f3f2ee` даёт 1,01:1, его не видно. Подложка Demo `#F2F2F2` 1,0:1. Статус-бар белый 1,12:1 | **FAIL** (В2-4, В2-1) |
| dark / f03-01 | `f/dark-f03-01.png` | нет PNG: токены/компоненты D2.2.5.1 + состав | Demo, «Anmelden oder Konto erstellen» 2 строки, подпись-body, поле panel, лаймовая кнопка «Demo mit Beispieldaten ansehen» | Safe-area и поля 16 dp на месте. Заголовок с 93 dp, шаг строк ≈32 (.title 28/32). Поле `x16..395` (≈42 dp). Кнопка 45 dp по контенту (Р7, форк). Подпись без отступа пилюли (В2-6, форк). Состав 4/4 | **PASS с форком** (Р7, В2-6) |
| light / f03-01 | `f/light-f03-01.png` | то же | Те же элементы: ground `#f3f2ee`, ink, panel `(230,229,223)`, кнопка `#121211` с on-primary | Цвета схемы верные. Статус-бар белый 1,12:1. Р7 и В2-6 как в dark | **FAIL** (В2-1) |
| dark / f03-02 | `f/dark-f03-02.png` | то же | «Kontakt bestätigen», подпись, поле, «Anmelden» лайм, 3 ссылки лаймом | Ссылки `#d6f75a`, 16,3:1. Кнопка `x16..128.4`, 45 dp (Р7). Состав 7/7 | **PASS с форком** (Р7, В2-6) |
| light / f03-02 | `f/light-f03-02.png` | то же | Те же, кнопка чёрная, ссылки лаймом почти невидимы | Ссылки `#d6f75a` на `#f3f2ee`, 1,08:1 (`[43..448]×[703..903]` px), а D2.2.5.1 `accent-text` light `#3f6d0f` даёт 5,5:1. Статус-бар белый | **FAIL** (В2-3 architect, В2-1) |

## Пункты консультанта 1–4 → класс и кто чинит

1. First-Run против PNG: **блокирует, architect**. Контракт 117/1 «First-Run.png — закрыт 111 — НЕ трогает»
   противоречит слову (А) 18:15. 111/1 сознательно исключил саблайны и AgentPresence. `first-run-screen.tsx` и
   wordmark лежат вне ЗОНЫ implementer 117, нулевые поля задаёт 111 К6. «Заголовок обрезан» не подтверждён: он
   центрован, поля 35,8/36,5 dp. Добавляю от себя невидимый wordmark в light. (В2-4, В2-5)
2. Контраст ссылок light: **блокирует, architect** (инв. 6 и клетка В2 пинят accent `#d6f75a`, а D2.2.5.1 требует
   `accent-text`). Затем implementer. (В2-3)
3. Поле без подписи: подпись **есть** (label = body-ключ, вопрос №6). Отступ подписи и плейсхолдер — README
   TextField против read-only `src/ui`, **форк** вместе с Р7. Implementer не виноват. (В2-6)
4. Статус-бар light: **блокирует, implementer** (чинится в pilot-app.tsx). Architect добавляет клетку. (В2-1, В2-2)

## (б) Батарея Architect117r6 (fc96e6dab) против пп. 1–4

Своей мерой на C: behavioral **28/28** rc0, static **37/37** rc0 (подсчёт строк `case`). Новые клетки:
PROD_ENTRY_OS_THEME ×2, AUTH_FRAMES_SAFE_AREA ×2, SPLASH_OVERLAY_CONTAIN ×2, MAESTRO_SPLASH_FRAME_WAIT,
MAESTRO_FIRST_RUN_ORDER. Пп. 1–4 r6 **не держит**. По `StatusBar`, `accent-text`, контрасту, подзаголовку и
футеру First-Run, CTA во всю ширину и плейсхолдеру в `vkhod.test.tsx`, `vkhod_probe.py`, `vkhod_static_probe.py`,
`source.json` нет ни одного совпадения. По п.2 клетка В2 LIGHT требует `#d6f75a` (`vkhod.test.tsx:97`) и покраснеет на
верном цвете. Недостающие клетки (architect добавит, ослаблять нельзя):
- `STATUS_BAR_STYLE_{DARK,LIGHT}`: стиль статус-бара PilotApp контрастен ground схемы. Стабы «StatusBar нет» и
  «light в обеих схемах» дают красный результат.
- Пара В2 по `accent-text` схемы (dark `#d6f75a`, light `#3f6d0f`) вместо `accent`. Стаб «ссылки accent в light»
  даёт красный результат.
- После редакции области (В2-4): клетки First-Run по PNG — знак, подзаголовок и футер (если владелец разрешит копию
  без ключей), CTA последним элементом во всю ширину, wordmark своей схемы (light-вариант).
- Подпись поля: клетка уже есть (В1/В2 судят label = body). Плейсхолдер — только после решения по `src/ui`/каталогу.

## (в) Реализация против замороженного 117/1

- Область правки: `814e95ed..OBJECT` — 2 файла (`mobile/.maestro/vkhod-117-splash-vhod.yaml`,
  `mobile/src/bootstrap/pilot-app.tsx`). `8748a7a3..OBJECT` — 14 файлов, все в ЗОНЕ implementer. **PASS**.
- Frozen-батарея (CI-пин 8d2a7fcf) на C: behavioral 22/22 rc0, static 35/35 rc0.
- r6 на C: behavioral 28/28 rc0, static 37/37 rc0. Behavioral `--matrix` rc0: honest green 28 и 26 мутантов,
  каждый даёт красный результат (новые `prod-theme-os-ignored`, `prod-theme-light-hardcode`,
  `auth-frames-no-inset`, `auth-frames-inset-hardcode`, `overlay-intrinsic-size` — своими клетками).
  Static `--matrix` r6: rc0, 25 мутантов, каждый даёт красный результат. Среди них Р8-свидетели `icon-template-bytes` и `adaptive-favicon-template` (теперь красны: шаблоны из `base_b/` H) и 5 новых `maestro-*` своими клетками MAESTRO_*. R после прогона чист.
- `npx jest src/bootstrap/__tests__/pilot.test.tsx` → 14/14 rc0. `npm run typecheck` → rc0. `npm run lint` → rc0.
- `git status --short --untracked-files=all` после последовательных проб: только `?? mobile/node_modules`.
  Оговорка: один промежуточный lint rc1 из-за `mobile/__117_splash_effective__.js` вызвала моя гонка (запустил
  две static-пробы параллельно на одном R). После удаления файла и последовательного прогона R чист, lint rc0. Это
  не дефект батареи.
- e2e на устройстве (по кадрам): 8/8 кадров сняты, порядок верный. Кадры см. таблицу.

## (г) Обход «зелёное при не по макету» (Adversary)

На C зелёные и батарея (22+35 и 28+37), и android-e2e, хотя экран не по макету:
(а) белые иконки статус-бара на светлом ground: клетки нет, Maestro цвет не судит;
(б) невидимые лаймовые ссылки в light: батарея этого ТРЕБУЕТ, assertVisible проходит по иерархии;
(в) невидимый wordmark First-Run в light: 111 К4 судит `Image.source`, а не контраст;
(г) First-Run без знака, подзаголовка и футера, CTA не внизу: вне предмета 117, Maestro проверяет только promise и CTA;
(д) кнопка 45 dp по контенту, поле 42 dp (Р7): размеры не судятся.

## Паразитная сложность (050), артефакты диффа круга 2

- **Тема ОС в PilotApp** (state `osScheme` + подписка Appearance + распознавание «провайдера нет» по тождеству
  `tokens === themeTokens.dark` + `ThemeContext.Provider`). (1) Свойство: 117/1 «тёмный И светлый»,
  `userInterfaceStyle automatic`, инв. 6 «токены схемы» (Р1). (2) Состояние `osScheme` явное, а сентинел тождества
  неявный: явный провайдер со значением по умолчанию неотличим от его отсутствия. (3) Логика Appearance
  дублирует `tab-shell.tsx`, теперь меняются 2 файла вместо 1. (4) Интерфейс PilotApp не вырос. (5) Потребитель —
  r6 PROD_ENTRY_OS_THEME. Более простая форма (провайдер в `src/app/index.tsx` или общий хук в `src/theme`) лежит вне
  ЗОНЫ, поэтому **ESSENTIAL**, совет С-1.
- **Ожидания в Maestro** (`extendedWaitUntil visible/notVisible splash-overlay`, `assertNotVisible`). (1) Приёмка:
  takeScreenshot каждого кадра (В), Р2/Р3. (2) Явное: rc сценария. (3) 1 файл. (4) —. (5) Шаг CI android-e2e, r6
  MAESTRO_*. **ESSENTIAL**.
- **Инлайн-корень кадров D2.2** (`paddingTop: insets.top`, `paddingHorizontal: 16` для email/code). (1) Инв. 6
  «кадр в окне» + Р4. (2) Явное, из insets. (3) 1 файл. (4) —. (5) r6 AUTH_FRAMES_SAFE_AREA. **ESSENTIAL**.

## Семь пунктов роли

1. Область правки: PASS (см. (в)).
2. Сырой вывод: PASS. Все прогоны мои, rc выше. Кадры скачаны и измерены сам.
3. Проверка не переписана под реализацию: implementer менял только сценарий (зона). Сценарий теперь КРАСНЕЕТ без
   оверлея, это усиление. Батарея r6 — коммит `architect`. PASS.
4. Красное предъявлено: r6 behavioral-матрица 26/26 мутантов красны, static-матрица 25/25 мутантов красны. PASS.
5. Атомарность: 2 коммита круга 2, оба «117 (CMP-MOB-006, круг 2)», одна задача. PASS.
6. Норма не тронута: дифф только продуктовый. PASS.
7. Счётные утверждения: «28 behavioral + 37 static» подтверждены подсчётом строк `case` (28, 37). Frozen — 22 и 35.
   Утверждение консультанта «заголовок обрезан» моей мерой не подтверждено. «Поле без подписи» не подтверждено:
   подпись есть.

## Блокирующие находки → кто чинит

- **В2-1** implementer (`pilot-app.tsx`): стиль статус-бара по схеме. Кадры light × 4.
- **В2-2** architect: клетки `STATUS_BAR_STYLE_{DARK,LIGHT}`.
- **В2-3** architect: инв. 6 и клетка В2 → `accent-text` схемы, решение по `tokens.ts`. Затем implementer. Кадр light/f03-02.
- **В2-4** architect: область 117/1 (или 111 v4) против слова (А) — First-Run по PNG, light-wordmark. Кадры first-run × 2.
- **В2-5** architect: клетки First-Run после В2-4.
- Не блокируют (форк владельцу): Р5, Р7, В2-6. Совет С-1.
