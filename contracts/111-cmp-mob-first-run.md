# Контракт 111 — mob: First-Run по D2.2.5.1 (Complior-mob #109)

ВЕРСИЯ: v3 (2026-10-21; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ — в изменяющем коммите; форк
`forks/n111-v3-splash-static.md`, ОТВЕЧЕНО).
Единственное изменение v3 — миграция статических клеток splash под продукт 117 (слово
владельца 2026-10-20 ~18:15/18:18 UTC: splash/иконка заменяются по D2.2.5.1): клетка
`SPLASH_GROUND_DARK` → `SPLASH_GROUND_SCHEME` — значения splash больше не пинятся 111,
сверка с ЕДИНЫМ источником 117 (`fixtures/workshop_project/vkhod_117/source.json`,
`appjson_literals`: светлый корень #F3F2EE + тёмный блок #0A0A0A, знаки
splash-sign-{light,dark}.png, imageWidth 181, resizeMode contain); клетка
SPLASH_EFFECTIVE_GROUND_BOTH судит ОБЕ схемы на ОБЕИХ платформах. НЕ-ослабление:
`SPLASH_DEFAULT_BLUE_GONE`
и смысл мутантов B3/B4 сохранены, добавлен стаб splash-dark-stays-blue (тихий синий
тёмного блока). v2 (заморожен `frozen/contracts/111/2`): сужение гварда RESTYLE_GUARD_995 —
кадры F03.01/F03.02 (email/code) рестайлятся по предмету 117 (вход по D2.2.5.1 — токены
и компоненты + UX-JSON F01/F03, PNG нет — слово владельца ~19:28); ВСЕ остальные кадры
995 (welcome/unavailable/recovery и прочие) по-прежнему НЕ рестайлятся. Основание v2:
слово владельца 2026-10-20 ~18:00/18:18 UTC (экраны входа — по макету D2.2.5.1); ответ
консультанта 19:20 UTC — форк `forks/n117-krug1-maket-i-111.md`, развилка 1, вариант (А).
v1 (заморожен `frozen/contracts/111/1`, закрыт `done/contracts/111/1`):
`git show frozen/contracts/111/1^{commit}:contracts/111-cmp-mob-first-run.md`.

КЛАСС: КОДОВЫЙ. Предмет — issue `a3ka/Complior-mob#109`: полный экран First-Run по эталону
D2.2.5.1 (wordmark, promise, CTA «Anmelden oder Konto erstellen», ui.first_run.enter_f03) +
нативный Splash; plan.tsv строка 111 (пара 3, зависит от 999 — залендён). База B =
`a3ka/Complior-mob` main `76ac10fac668a1036371c4b392061ce9b3277ebc` (merge PR#111 = 999);
108 (PR#112) НЕ входит в B и предмет от него не зависит.

КОНТЕКСТ: GitHub `a3ka/Complior-mob#109` — источник работ; перед раздачей читать полное тело
(`gh issue view 109 --repo a3ka/Complior-mob --json body --jq .body`).
КОНТЕКСТ: `contracts/999-cmp-mob-002-navigatsiya.md`, `contracts/107-cmp-mob-003-erstinformation.md`,
`contracts/108-cmp-mob-004-start.md` — дисциплина H/B/C/T, disposable R, пробы с --matrix, пины H
в mobile.yml; frozen-семейства 995/999 не переписываются.
КОНТЕКСТ: `verdicts/critic/contracts-107-*.md`, `verdicts/critic/contracts-108-*.md` — измеренные
боли Н-351 (тавтологичный оракул) закрыты с первой редакции: все ожидания — литералы блока
EXPECT, продукт не служит источником ожиданий; привязка стаб↔ветвь — по коду проб (Н-39).
КОНТЕКСТ: `fixtures/workshop_project/first_run_111/source.json` — оракул: копия ключей каталога
и токенов D2.2.5.1, снятая с read-only docs/ дерева B ДО запуска субъекта; пробы несут те же
значения литералами.

## Нарезка предмета (frontier)

1. **Один контракт = весь предмет** (экран First-Run по D2.2.5.1 + нативный splash + Demo-бейдж
   + safe-area; один PR) — **выбран**. Боль: First-Run — стартовая поверхность приложения
   (первый кадр каждого запуска); splash и экран наблюдаются одним жестом холодного старта,
   расщепление даёт слой без обратной связи (вертикальный слайс 050).
2. Два контракта (splash+app.json / экран) — отвергнут: splash-правка без экрана не имеет
   поведенческой поверхности (один литерал в app.json — предмет без одного измеримого
   результата сверх статической клетки), экран без splash остаётся с белым обрамлением запуска.
3. First-Run с AgentPresence (как в First-Run.html) — отвергнут: AgentPresence — компонент 108
   (PR#112 не смержен, в B отсутствует); предмет 111 не зависит от 108. Issue называет ровно
   wordmark/promise/CTA; presence на First-Run — будущий срез после ленда 108.

## Существующее

Сверено на read-only снимке Complior-mob `76ac10fa…` (clean, `git rev-parse HEAD`).

- `mobile/src/bootstrap/pilot-app.tsx`: кадр `first-run` = одна кнопка «Weiter»
  (FIRST_RUN_BUTTON_COPY, testID `first-run-continue`, onPress → setFrame('email')); root
  `paddingTop: 48` + `backgroundColor: '#FFFFFF'` литералами — до-D2.2.5.1 поверхность 995.
  Предмет заменяет first-run-кадр; остальные кадры (email/code/unavailable/recovery/welcome)
  — поверхность 995 в B. v2: кадры F03.01/F03.02 (email/code) рестайлятся по предмету 117
  (гвард RESTYLE_GUARD_995 их более не держит); кадры 995 кроме них
  (unavailable/recovery/welcome) по-прежнему не рестайлятся.
- `mobile/src/bootstrap/__tests__/pilot.test.tsx` (+source.json) — frozen-семья 995: пишет
  `click('first-run-continue')` и после нажатия ждёт `frame.F03.01.title` = «Anmelden oder
  Konto erstellen»; CI сравнивает файлы с H побайтово (`cmp`). Интерфейс testID + переход
  сохраняются предметом, пробы 995 не переписываются.
- Каталог `docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json`: РОВНО ДВА ключа First-Run —
  `ui.first_run.promise` «Sie sagen, was passiert ist. Complior kümmert sich um den Rest.» и
  `ui.first_run.enter_f03` «Anmelden oder Konto erstellen» (оба review_status
  `UX_EDITORIAL_REVIEWED; NATIVE_RELEASE_SIGNOFF_REQUIRED`); `frame.F03.01.title` — тот же текст
  «Anmelden oder Konto erstellen» байт-в-байт (review_status `EDITORIAL_DRAFT_REVIEW_REQUIRED`).
  Саблайны First-Run.html («Ein Brief, ein Schaden…», «Versicherung. Erledigt.») БЕЗ ключей
  каталога — в продукт не вводятся (STRUCTURE.md §6: новая формулировка требует review).
- Эталон `docs/ux/02_.../screens/html/First-Run.html` (+First-Run.png): dark-тема, wordmark
  (22px, alt «complior», ds/wordmark-dark.svg), заголовок = promise, CTA (Button lg block) =
  ui.first_run.enter_f03 → F03.01 (F03.A01); ux-frames F03.01, F03.A01, RV01.
- Токены D2.2.5.1 (`ds/tokens.css`): dark ground `#0a0a0a`, light ground `#f3f2ee`, ink
  `#f2f1ec`/`#121211`. Нативная проекция — `mobile/src/theme/tokens.ts` (999, frozen);
  `useTheme` из `theme/context.ts`; прецеденты SafeAreaView — tab-shell.tsx, start-screen.tsx.
- `mobile/app.json`: expo-splash-screen backgroundColor `#208AEF` (дефолт B), image
  `./assets/images/splash-icon.png`, imageWidth 76 — предмет меняет фон на ground D2.2.5.1.
- `fixtures/workshop_project/vkhod_117/` (заморожен `frozen/contracts/117/1`, в main):
  батарея 117 — единый источник splash-значений продукта (source.json → блок
  `appjson_literals`, снят с read-only docs ДО субъекта, правило 8); v3 сверяет клетки
  111 с ним по ссылке (`first_run_111/source.json` → `unified_source_117`), не дублируя
  литералы.
- `mobile/src/i18n/ui-copy.ts`: 10 ключей 999 (verbatim-подмножество каталога); предмет
  добавляет 2 ключа First-Run verbatim. Wordmark-ассета в `mobile/assets/images/` нет —
  реализация растеризует из семьи `docs/ux/02_.../logo/` (wordmark-dark.svg).
- `mobile/.maestro/{start,rehearsal}.yaml`: assertVisible `first-run-continue` на «/» —
  сценарии переживают замену экрана без правок (testID сохранён); rehearsal после нажатия ждёт
  «Anmelden oder Konto erstellen» (заголовок F03.01) — сохраняется.
- STRUCTURE.md §5: видимая метка Demo — часть mock composition, состояние передаётся UI через
  props/context; §6: `ui/` на theme, экран не определяет свою палитру; F03 — владелец
  `features/auth/`.

## Предмет и граница

Один результат: холодный старт приложения показывает нативный splash на ground D2.2.5.1
(#0A0A0A) и полный экран First-Run вместо кнопки «Weiter»: wordmark (accessible «complior»),
promise (ui.first_run.promise), CTA «Anmelden oder Konto erstellen» (ui.first_run.enter_f03,
testID `first-run-continue` сохранён), Demo-бейдж, safe-area настоящим компонентом; нажатие CTA
открывает F03.01 (email-кадр 995) с прежней семантикой.

Вне предмета: AgentPresence/адаптивная сцена на First-Run (после ленда 108); кадры 995 кроме
F03.01/F03.02 — unavailable/recovery/welcome (поверхность 995, не рестайлятся); рестайл
F03.01/F03.02 (email/code) — предмет 117, вход по D2.2.5.1 (v2); саблайны First-Run.html
без ключей каталога;
copy signoff CMP-MOB-089; device evidence CMP-MOB-090; реальный IdP/бэкенд; смена
userInterfaceStyle/тёмная тема остальных кадров; wordmark в SVG-runtime (растровый ассет).

## Инварианты

1. `mobile/src/features/auth/first-run-screen.tsx` — экран First-Run: props-only порты
   `onEnter` (+опциональный testID), без знания навигации/транспорта; палитра ТОЛЬКО через
   `useTheme` (литеральных hex-цветов в файле нет); safe-area — настоящий
   `react-native-safe-area-context` с ДЕЙСТВУЮЩЕЙ защитой краёв: все четыре края (edges не
   передан — библиотечный полный набор — либо полный набор явно); канон D2.2.5.1 усечённого
   набора краёв для First-Run не объявляет, `edges={[]}`/пустой/усечённый набор или отсутствие
   компонента — дефект.
2. testID `first-run-continue` остаётся на CTA (замороженная семья 995 и Maestro
   start/rehearsal ждут его на «/» и не переписываются); нажатие → переход в F03.01
   (email-кадр) с заголовком frame.F03.01.title и полем auth-email — семантика 995 сохранена
   В ОБЕИХ схемах темы (переход — не dark-эксклюзив); бренд-элементы (wordmark/promise/CTA)
   исчезают без остатка.
3. Текст CTA = `ui.first_run.enter_f03` = «Anmelden oder Konto erstellen» байт-в-байт
   (equality_facts каталога: тот же текст, что frame.F03.01.title); promise =
   `ui.first_run.promise` байт-в-байт; ВЕСЬ видимый текст экрана ⊆ замкнутый перечень
   {«Demo», ui.first_run.promise, ui.first_run.enter_f03} — новых немецких формулировок на
   поверхности нет (саблайны First-Run.html — в т.ч. «Versicherung. Erledigt.»), review_status
   переносится verbatim.
4. `mobile/src/i18n/ui-copy.ts` расширяется ровно двумя ключами First-Run (verbatim-подмножество
   каталога; +2 к 10 ключам 999); структура записи сохранена.
5. `mobile/app.json` (v3): блок expo-splash-screen = литералы единого источника 117
   (`vkhod_117/source.json` → `appjson_literals`): корень (свет) backgroundColor `#F3F2EE`,
   image `splash-sign-light.png`, imageWidth 181, resizeMode contain; блок dark
   backgroundColor `#0A0A0A` (ground D2.2.5.1, dark; байт-равен themeTokens.dark.ground),
   image `splash-sign-dark.png`. ЭФФЕКТИВНАЯ нативная конфигурация — та, что выбирают
   резолверы expo-splash-screen в prebuild, — даёт фон `#F3F2EE` (свет) И `#0A0A0A` (тьма)
   на android И на ios: платформенные переопределения splash.backgroundColor не допускаются
   (корневое значение при живом `android.backgroundColor`-переопределении истиной не
   считается); дефолт-B `#208AEF` из app.json отсутствует (инвариант 111, миграцией не
   ослабляется).
6. Wordmark — растровый ассет `mobile/assets/images/wordmark-dark.png`, растеризованный из
   семьи logo/ D2.2.5.1 (wordmark-dark.svg), accessibilityLabel «complior»,
   accessibilityRole image; высота по эталону 22; Image.source ЭКРАНА указывает на этот
   ассет — файл рядом с экраном, берущим другой source, wordmark'ом не засчитывается.
7. Demo-бейдж (`demo-indicator`, текст «Demo») виден на First-Run — метка mock composition по
   STRUCTURE.md §5; состояние не дублируется второй меткой.
8. Экран работает в обеих схемах темы (dark/light): контейнер на tokens.ground, promise на
   tokens.ink соответствующей схемы (провайдер — существующий ThemeContext).

## Проверяемый шов

`mobile/src/features/auth/first-run-screen.tsx` экспортирует `FirstRunScreen({ onEnter,
testID? })`; PilotApp рендерит его для кадра first-run (`<FirstRunScreen onEnter={
handleFirstRunContinue} />`), legacy FIRST_RUN_BUTTON_COPY/«Weiter» и его стили удалены.
Ожидания проб — литералы source.json в самих пробах, снятые в память ДО запуска субъекта
(правило 8, Н-351): ни одна клетка не сверяется значением, прочитанным у субъекта; вход
(провайдер темы) — themeTokens 999, ожидание — токены-литералы оракула.

## Закрытые перечни клеток (числа из кода проб)

Поведенческая семья (Jest/RNTL, `first_run_probe.py` → `first_run.test.tsx`, 11 клеток):
- К1 `FIRST_RUN_STRUCTURE_{DARK,LIGHT}` ×2 — произведение scheme(2) на первом рендере «/»; в
  каждой клетке наблюдаются ВСЕ элементы: wordmark (testID + accessibilityLabel «complior» +
  role image), promise (точный текст + ink схемы), CTA (testID 995 + role button + точный
  label), Demo-бейдж (testID + текст), контейнер safe-area на ground схемы (стиль наблюдаем).
- К2 `CTA_OPENS_F03_01_{DARK,LIGHT}` ×2 — нажатие CTA в КАЖДОЙ схеме темы: заголовок F03.01 +
  auth-email видны, promise/wordmark/CTA исчезли (семантика 995 сохранена, правило П);
  навигация только в одной из схем красна клеткой другой схемы.
- К2′ `CTA_TEXT_EQUALS_FRAME_TITLE` ×1 — наблюдаемый label CTA байт-равен литералу и
  наблюдаемому заголовку F03.01 после нажатия (заголовок ищется РОЛЬЮ header — на застрявшем
  First-Run сам CTA тот же текст и кадром не засчитывается).
- К3 `SAFEAREA_EDGES_ACTIVE_{DARK,LIGHT}` ×2 — произведение scheme(2): действующая
  safe-area наблюдается на нативном шве библиотеки в ОБЕИХ схемах: edges-мап контейнера =
  все четыре края active; `edges={[]}`/усечённый набор/отсутствие компонента красят
  (живой импорт и цвет сами по себе не засчитываются).
- К4 `WORDMARK_SOURCE_BOUND_{DARK,LIGHT}` ×2 — произведение scheme(2): Image.source
  наблюдаемого wordmark указывает на ассет wordmark-dark.png (литерал имени в ожидании)
  в ОБЕИХ схемах; подмена source на соседний ассет при живых label/role/testID красит.
- К5 `FIRST_RUN_COPY_CLOSED_{DARK,LIGHT}` ×2 — произведение scheme(2): каждый текстовый
  лист host-дерева первого кадра ⊆ литеральный перечень {«Demo», promise, CTA} в ОБЕИХ
  схемах; некаталожная немецкая строка на поверхности (в т.ч. саблайн эталона без ключа
  каталога) красит.

Статическая семья (`first_run_static_probe.py`, 16 клеток; v3 — клетки splash мигрированы
под 117): `SPLASH_GROUND_SCHEME` (v3: блок splash = литералы `appjson_literals` единого
источника 117 — светлый корень + тёмный блок, знаки, imageWidth, resizeMode),
`SPLASH_DEFAULT_BLUE_GONE` (дефолт-B `#208AEF` отсутствует в app.json),
`SPLASH_EFFECTIVE_GROUND_BOTH` (эффективные android/ios фоны В ОБЕИХ схемах — настоящими
резолверами expo-splash-screen из node_modules продукта на disposable R; отказ
резолвера — rc2 INFRASTRUCTURE, не зелень), `COPY_KEY_ui_first_run_promise`,
`COPY_KEY_ui_first_run_enter_f03`, `SCREEN_SEAM_FIRST_RUN`, `SCREEN_NO_HEX_LITERALS`,
`SCREEN_SAFEAREA_COMPONENT`, `SCREEN_THEME_TOKENS`, `CTA_TESTID_BOUND`,
`PILOT_WIRED_FIRST_RUN`, `LEGACY_WEITER_GONE`, `WORDMARK_ASSET` (PNG-магия),
`WORDMARK_ASSET_DECODES`, `WORDMARK_ASSET_IDENTITY` (A1/A1r2 судов 111),
`STATIC_ORACLE_LITERALS` (проба несёт все литералы оракула и не импортирует
'@/i18n/ui-copy').

Обманные стабы (привязка к ветвям — ТОЛЬКО по коду `MUTANTS` обеих проб, Н-39; depends измерены
полным прогоном): поведенческих 26 (cta-label-weiter, promise-invented, onenter-not-wired,
ground-default-blue, demo-badge-scope, wordmark-absent, cta-testid-renamed, light-cta-noop,
safearea-edges-empty, wordmark-wrong-source, extra-unreviewed-copy, light-edges-top-bottom,
light-wrong-source, light-extra-copy, wrapper-root-white, wrapper-root-magenta,
wrapper-root-padding, badge-outside-safearea, badge-inset-top-zero, badge-hardcoded-inset,
restyle-welcome-ground, restyle-995-ground, restyle-995-no-padding,
restyle-995-padding-shifted, restyle-unavailable, restyle-recovery), статических 16
(splash-stays-default-blue, splash-dark-stays-blue, android-splash-blue,
copy-promise-invented, copy-enter-missing, screen-hex-literal, pilot-unwired,
wordmark-missing, wordmark-1x1-png, wordmark-broken-stub-82, wordmark-solid-rectangle,
wordmark-opaque-one-transparent, wordmark-recolored-ink, wordmark-recompressed,
cta-testid-unbound, screen-plain-view);
каждый красен именованной клеткой, побочная краснота только в depends; `--matrix` —
самопроверка набора, не приёмка. Пять стабов круга-1 критика (light-cta-noop,
safearea-edges-empty, wordmark-wrong-source, android-splash-blue, extra-unreviewed-copy)
воспроизводят обходы B1–B5 и закрыты именованными клетками К2×2/К3/К4/SPLASH_EFFECTIVE/К5.
Три стаба круга-2 (light-edges-top-bottom, light-wrong-source, light-extra-copy — мутации
критика дословно, ограничены светлой схемой) воспроизводят обходы B2r2/B3r2/B5r2 и закрыты
именованными LIGHT-клетками пар К3/К4/К5.

## Приёмочный критерий

R — disposable копия Complior-mob под /tmp/dev-harness-verify с `npm ci` в `mobile/`; пробы —
Python 3 stdlib. Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/first_run_111/first_run_probe.py
  --repo R` → rc1 `FIRST_RUN_SEAM_ABSENT`; `first_run_static_probe.py --repo R` → rc1
  `FIRST_RUN_SEAM_ABSENT` (именованный отказ на до-предметном дереве).
- Дано B с эталонной моделью (`--model`); либо честное C — обе пробы → rc0 с построчным
  перечнем: поведенческая 23/23, статическая 16/16.
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный, каждый стаб красен своей
  именованной ветвью, побочная краснота только в depends (26+16 стабов); якорь мутанта неуникален
  → отказ rc2.
- Дано C; `git status --short --untracked-files=all` в R после проб — 0 строк (пробы
  восстанавливают дерево).
- Дано C; `npm run lint`, `npm run typecheck`, `npm test` в R/mobile зелёные; frozen-прогоны
  995/999 в mobile.yml проходят на новой поставке БЕЗ правок проб (pilot.test.tsx и source.json
  побайтово неизменны — их трогать нельзя, это зона 995).
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0, включая quality с
  шагами 111 из H (обе пробы на disposable R) и android-e2e (Maestro start/rehearsal живы на
  новом First-Run: assertVisible first-run-continue, после нажатия — «Anmelden oder Konto
  erstellen»).
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo <worktree-ветки>
  contracts/111-cmp-mob-first-run.md` (worktree H-пина ветки wip/111/architect) → rc0.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/111/1^{commit}` в полный SHA H и
append-only записывает его с B в issue #109 ДО раздачи implementer. mobile.yml получает шаг
quality по образцу 999/107/108: H-checkout, обе пробы 111 на disposable R (Python 3 stdlib) до
npm test/lint/typecheck/doctor; frozen-шаги 995/999 сохраняются дословно. Maestro-сценарии не
меняются (testID сохранён); новый скриншот First-Run — в артефакты android-e2e.

## Зоны и исполнители

ЗОНА architect: contracts/111-cmp-mob-first-run.md fixtures/workshop_project/first_run_111/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Пути implementer отсчитываются от корня Complior-mob:

ЗОНА implementer: mobile/src/features/auth/first-run-screen.tsx mobile/src/bootstrap/pilot-app.tsx mobile/src/i18n/ui-copy.ts mobile/app.json mobile/assets/images/wordmark-dark.png .github/workflows/mobile.yml

ПЕРЕСЕЧЕНИЕ: `mobile/src/bootstrap/pilot-app.tsx` и `mobile/src/i18n/ui-copy.ts` — общие с
замороженными семьями 995/999 (пробы этих семей НЕ переписываются и обязаны оставаться
зелёными на поставке 111; pilot.test.tsx/source.json побайтово заморожены cmp-шагом CI).
`mobile/src/bootstrap/__tests__/` (995), `mobile/src/features/start/`, `mobile/src/ui/`,
`mobile/src/mocks/`, `api/generated/`, `docs/`, `design/` — read-only для 111.

fixtures/workshop_project/first_run_111/ — новый подкаталог architect-зоны; коллизий с живыми
заморозками нет, чужие файлы не меняются.

РАБОТА НЕ РАЗДАЁТСЯ: реализация (implementer) не спавнится до accept критика и freeze
оркестратора; предмет этой пачки — контракт + красные пробы, предъявленные красными на B.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: пробы исполняют настоящий Jest/RNTL на disposable R и разбирают
  JSON-отчёт поимённо; пустой отчёт — именованный отказ/INFRASTRUCTURE, не зелёное;
- от подмены CTA-интерфейса 995: testID first-run-continue наблюдается в каждой структурной
  клетке, в обеих клетках перехода и статической семьёй; переименование ловят стабы обеих
  семей;
- от слома семантики 995: клетки CTA_OPENS_F03_01_{DARK,LIGHT} проверяют полный вектор после
  нажатия в КАЖДОЙ схеме (заголовок F03.01 + auth-email + исчезновение бренд-элементов);
  заголовок ищется РОЛЬЮ — CTA-текст кадром не засчитывается; навигация-только-в-dark
  (обход B1) красна LIGHT-клеткой;
- от inventions копии: ключи каталога verbatim (текст+review_status) статической семьёй;
  promise/CTA наблюдаются точным текстом на поверхности; замкнутый состав видимой копии
  держат FIRST_RUN_COPY_CLOSED ×2 — в обеих схемах (вся поверхность ⊆ {Demo, promise, CTA})
  и сам перечень i18n (+2 ровно) — некаталожный саблайн (обходы B5/B5r2 —
  scheme-независимый и light-ограниченный) красит;
- от второй палитры: SCREEN_NO_HEX_LITERALS (ни одного hex-литерала в экране) + наблюдение
  ground/ink обеих схем поведенческими клетками;
- от тихого дефолт-B И платформенно-переопределённого splash: литералы схемы из единого
  источника 117 (SPLASH_GROUND_SCHEME — светлый корень + тёмный блок) и страж дефолт-B
  (SPLASH_DEFAULT_BLUE_GONE) плюс эффективная нативная конфигурация ОБЕИХ платформ В ОБЕИХ
  схемах настоящими резолверами expo-splash-screen на disposable R
  (SPLASH_EFFECTIVE_GROUND_BOTH: android И ios, свет #F3F2EE И тьма #0A0A0A; обход B4 —
  android.backgroundColor синим при верных корневых значениях — красит);
- от потери Demo-метки: структурные клетки (бейдж на First-Run);
- от мёртвой safe-area: SCREEN_SAFEAREA_COMPONENT (настоящий импорт компонента, не
  упоминание в комментарии) + SAFEAREA_EDGES_ACTIVE ×2 — в обеих схемах на нативном шве
  библиотеки все четыре края active; edges=[]/усечённый набор при живых импорте/цвете
  (обходы B2/B2r2) красит;
- от wordmark-декорации: WORDMARK_ASSET (файл-ассет) + WORDMARK_SOURCE_BOUND ×2 (обе
  схемы) — Image.source экрана связан с ассетом (литерал имени); подмена source на
  соседний ассет (обходы B3/B3r2) красит;
- от зависимого оракула (Н-351): все ожидания — литералы блока EXPECT теста (копия source.json,
  снятого с read-only docs ДО субъекта); STATIC_ORACLE_LITERALS держит регресс «импорт копии
  субъекта»; вход-провайдер (themeTokens) не служит ожиданием;
- от мёртвой матрицы: обе пробы исполняют все колонки на каждом стабе (14+9), depends измерены
  прогоном, unexpected_red — дефект rc2.

НЕ ЗАЩИЩАЕТ:
- от визуальной точности wordmark (растеризация из logo/, типографика, пропорции) —
  cognitive-only, ловец reviewer на C по First-Run.png; проба проверяет наличие/доступность
  ассета, не его пиксели;
- от пиксельной сверки нативного splash на устройстве — app.json-литерал и prebuild;
  визуальная сверка — android-e2e артефакты/reviewer;
- от реальной аутентификации (IdP) — поверхность 995/бэкенд, вне предмета;
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI evidence.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: потребляется действующая норма закрытия роли. Новая общая норма не
вводится; локальная приёмка — оркестратором/судьями и CI Complior-mob. Пробы 111 исполняются
в CI Complior-mob из H-checkout; подключение — шаг quality в .github/workflows/mobile.yml
(зона implementer) по образцу 999/107/108; в registry/ci-steps.tsv харнесса НЕ регистрируется
(python3 stdlib, npm-ключа нет).

## Отложенная продуктовая приёмка

- Maestro android-e2e: скриншот полного First-Run (wordmark+promise+CTA) в артефактах прогона
  start.yaml — сверка с First-Run.png на ревью C (NOT_RUN до C).
- Copy signoff CMP-MOB-089 (ui.first_run.*: NATIVE_RELEASE_SIGNOFF_REQUIRED) и device evidence
  CMP-MOB-090 — владелец.

## Вопросы владельцу

1. Splash-фото/иконка: фон меняется на ground #0A0A0A при неизменном splash-icon.png (76).
   ЗАКРЫТО словом владельца 2026-10-20 ~18:15/18:18 UTC: splash/иконка заменены предметом
   117 (нативный splash dark+light, знаки splash-sign-*, иконка complior-app-icon);
   v3 мигрирует статические клетки под эти значения.
2. AgentPresence на First-Run (как в First-Run.html) — осознанно вне предмета до ленда 108;
   подтвердить границу или потребовать сцену после 108 отдельным срезом.

## Фактический замер авторской пачки

Снимок B=`76ac10fac668a1036371c4b392061ce9b3277ebc` (clean, сверен `git rev-parse HEAD`);
disposable-дерево `/tmp/dev-harness-verify/Architect111/R` (node_modules от npm ci-дерева 108);
прогоны круга 3 — на `cp -a`-копии `/tmp/dev-harness-verify/Architect111/r3`, R не тронута.
Замер 2026-10-20, круг 3 (перечень П-1…П-5 арбитража
`verdicts/arbitration/contracts-111-dark-light-perechen-v1.md`: К3/К4/К5 произведением
scheme(2), стабы критика круга 2).

- B без модели: `first_run_probe.py --repo r3` → rc1 `FIRST_RUN_SEAM_ABSENT`;
  `first_run_static_probe.py --repo r3` → rc1 `FIRST_RUN_SEAM_ABSENT`.
- B с эталонной моделью (`--model`): поведенческая rc0 honest 11/11; статическая rc0 14/14.
- Матрицы: `first_run_probe.py --matrix` → rc0 (14 стабов, defects 0, unexpected_red=none);
  `first_run_static_probe.py --matrix` → rc0 (9 стабов, defects 0).
- Зависимости стабов измерены полным прогоном; перечень пар — в коде `MUTANTS` проб (Н-39),
  проза пар не несёт. Стабы-обходы круга-1 (light-cta-noop, safearea-edges-empty,
  wordmark-wrong-source, android-splash-blue, extra-unreviewed-copy) красны каждый своей
  именованной клеткой без побочной красноты (схемонезависимые стабы — обеими клетками пар);
  стабы круга-2 (light-edges-top-bottom, light-wrong-source, light-extra-copy — мутации
  критика дословно, light-ограниченные) красны каждый ровно своей именованной LIGHT-клеткой
  пар К3/К4/К5.
- После прогонов `git status --short --untracked-files=all` в R и r3 — 0 строк (деревья
  восстановлены).

## Замер v2 (сужение К8, 2026-10-20; v2b — К9 unavailable/recovery)

R — disposable-клон `a3ka/Complior-mob` @ `8748a7a335` (main, поставка 111 заленджена;
`git rev-parse HEAD` сверен), `mobile/node_modules` — симлинк (инфраструктура R). Мир
модели 117 — `fixtures/workshop_project/vkhod_117/model/` @ `wip/117/architect`
`9dc3c8c4d`, установленная по путям поставки поверх R. Все числа — из прогонов.

- База 8748a7a335, без `--model`: `first_run_probe.py --repo R` → rc0 honest 23/23
  (обратная совместимость: база не рестайляет; v2b добавляет пары К9 — 19→23 клетки).
- Мир модели 117 ДО v2 (батарея круга 3, 19 клеток): 17/19, красны ровно К8
  `RESTYLE_GUARD_995_F03_01_{DARK,LIGHT}` (замер v2; воспроизведён критиком круга 1
  прогоном на `b765c0f68~2`); ПОСЛЕ v2 (К8 F03_01 — НЕ-ожидание рестайла, 19 клеток)
  → rc0 19/19; v2b (23 клетки) → rc0 23/23: рестайл F03.01/F03.02 легален,
  unavailable/recovery моделью 117 не тронуты.
- Модель 111 (`--model`): поведенческая rc0 honest 23/23; статическая rc0 16/16.
- К9 красное предъявление (Б1 критика круга 1): в честной модели 111 замена
  единственного предиката стиля корня `frame === 'first-run'` → `frame !== 'welcome'`
  в `mobile/src/bootstrap/pilot-app.tsx` (first-run/welcome/F03.01-шов живы, прежние
  19 клеток зелёны) → rc1, красны РОВНО `RESTYLE_GUARD_995_{RECOVERY,UNAVAILABLE}_{
  DARK,LIGHT}`: собственное наблюдение каждого защищаемого кадра, невыводимое из
  welcome (К8′).
- Матрицы: `first_run_probe.py --matrix` → rc0 (26 стабов: каждый красен именованной
  ветвью, побочная краснота только в depends; стабы, рестайлящие чужой кадр —
  restyle-welcome-ground, restyle-995-ground, restyle-995-no-padding,
  restyle-995-padding-shifted — красны парой К8′ `RESTYLE_GUARD_995_WELCOME`,
  причём restyle-995-* — и парами К9 как depends; новые стабы круга-1-Б1
  restyle-unavailable/restyle-recovery красны каждый ровно своей парой К9);
  `first_run_static_probe.py --matrix` → rc0 (15 стабов).
- После прогонов `git status --short --untracked-files=all` в R — 0 строк кроме
  симлинка `mobile/node_modules` (инфраструктура R, не проба).

## Замер v3 (миграция splash-клеток под 117, 2026-10-21)

Продукт 117 — клон `/tmp/dev-harness-verify/Impl117/mob`, ветка `cmp-mob-117/vkhod`, HEAD
`0d1a09b08b5294e0578f9887541662b5f4bbbd08` (сверен `git rev-parse HEAD`); база B —
одноразовый клон `8748a7a3352c14a6caa5a75b71f869e5d3b8152c` (поставка 111) в
`/tmp/dev-harness-verify/Architect111v3/baseB`, `mobile/node_modules` — симлинк
(инфраструктура R). Модель 111 `model/app.json` — байты продукта 117 (`cmp` равен).
Все числа — из прогонов.

- Продукт 117: `first_run_static_probe.py` → rc0 static 16/16; `first_run_probe.py` →
  rc0 honest 23/23; батарея 117 без изменений (git status чист) → `vkhod_static_probe.py`
  rc0 static 35/35.
- Матрица статики `--matrix` (на продукте 117) → rc0: 16 стабов; splash-stays-default-blue
  (B3: корень → #208AEF) красен SPLASH_GROUND_SCHEME (+depends SPLASH_DEFAULT_BLUE_GONE,
  SPLASH_EFFECTIVE_GROUND_BOTH), splash-dark-stays-blue (v3: тёмный блок → #208AEF) — те же
  клетки, android-splash-blue (B4: android.backgroundColor #208aef при верных корне/dark) —
  ровно SPLASH_EFFECTIVE_GROUND_BOTH; unexpected_red нет.
- База 8748a7a335 (splash 111: корень #0A0A0A, splash-icon 76, без dark-блока): статика
  rc1, красны РОВНО SPLASH_GROUND_SCHEME и SPLASH_EFFECTIVE_GROUND_BOTH — миграционная
  норма v3 (база несёт заменённые 117 значения; слово владельца 2026-10-20 ~18:15/18:18);
  поведение rc0 23/23; краснота базы не расширилась за пределы двух мигрированных клеток.
  Эквивалентность «не-ослабления» доказана матрицей (B3/B4 красны теми же клетками, что в
  v2) и зелёным прогоном на честном продукте 117.
