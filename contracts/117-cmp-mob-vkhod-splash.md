# Контракт 117 — mob: First-Run и вход F03.01/F03.02 по D2.2.5.1 + НАШ нативный splash/иконка (CMP-MOB-006)

КЛАСС: КОДОВЫЙ. Предмет — слова владельца (через консультанта): (А) ~18:15
UTC «First-Run и экраны входа (F03.01/F03.02) по макету D2.2.5.1: полный
состав и раскладка как на PNG» — First-Run судится по First-Run.png
(артборд 390×844, тёмный; исходник артборда First-Run.html; светлая
схема — те же элементы на токенах light); splash ~18:18 UTC «нативный
splash (expo-splash-screen) и, ЕСЛИ НУЖНО, JS-экран сразу после него
совпадают со Splash.png» (иконка = complior-app-icon, тёмный И светлый);
~19:28 UTC вход F03.01/F03.02 — по токенам и компонентам D2.2.5.1 и
составу UX-JSON F01/F03, PNG-макета входа нет. Конструкция splash
(арбитраж круга 2, РЕШЕНИЕ): нативный = ОДИН знак канона на ground схемы;
кадр Splash.png целиком несёт JS-ОВЕРЛЕЙ сразу после натива (слово 18:18
«если нужно» — нужно: замер арбитра — платформа вписывает картинку плагина
в imageWidth×imageWidth, масштаб нативного композита «на весь кадр» =
0.46, это другой кадр, не Splash.png). JS-КАДР state-machine — вне
предмета. ПРАВИЛО (В): PNG-макет каждого кадра назван, takeScreenshot
каждого кадра в приёмке, ревьюер сверяет скриншот ↔ макет. База B =
`a3ka/Complior-mob` main `8748a7a3352c14a6caa5a75b71f869e5d3b8152c` (после 111).

КОНТЕКСТ: слова владельца через консультанта — (А) 18:15 UTC «First-Run и
экраны входа (F03.01/F03.02) по макету D2.2.5.1: полный состав и раскладка
как на PNG»; splash ~18:18 UTC (НАШ splash: иконка = complior-app-icon,
нативный splash тёмный И светлый); ПРАВИЛО (В) ~18:00 UTC (сверка с макетом);
~19:28 UTC вход по токенам/компонентам D2.2.5.1 и UX-JSON F01/F03; ответ
консультанта 09:20 UTC 2026-10-21 по форку `n117-v2-first-run` — вариант (А).
КОНТЕКСТ: `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/` — растры
`screens/Splash{,-Hell}.png`, `screens/First-Run.png` (артборды 390×844),
`screens/html/First-Run.html`, семья `logo/assets/`, `design-system/project/`
(tokens.css, tokens.json, README.md, components/Button, components/TextField).
КОНТЕКСТ: `docs/ux/01_UX_Source_of_Truth/Complior_F01_F03_Invitation_Entry_1_17_8_1.json`
(состав входа) и каталог `BrokerOS_UI_Copy_DE.json` (тексты по ключам).
КОНТЕКСТ: `contracts/111-cmp-mob-first-run.md` + батарея
`fixtures/workshop_project/first_run_111/` (done) — механика probe_lib и
уроки (Н-386 свойство↔выборка, литералы Н-379/Н-383, RNTL 14.1 await);
frozen-семьи 995/999/111 этой пачкой не переписываются — пересечение
названо в разделе «ПЕРЕСЕЧЕНИЕ с 111/995/999».

## Источники

- Слова владельца: (А) 18:15 UTC; splash 18:18 UTC; ПРАВИЛО (В) ~18:00 UTC
  (коммит консультанта `f1e3c1c3`, РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле); ответ
  консультанта 09:20 UTC 2026-10-21 по форку `n117-v2-first-run` — (А).
- «F03.01/F03.02 — по токенам и компонентам D2.2.5.1 и UX-JSON F01/F03, PNG-макета нет (слово владельца 2026-10-20 ~19:28 UTC)».
- Макеты splash (read-only B): `screens/Splash.png` (тёмный) и
  `screens/Splash-Hell.png` (светлый) — артборды 390×844, замер Architect117c
  пиксельным проходом (обе схемы совпадают): видимый знак x109..289
  y271..443, wordmark x157..232 y514..533, tagline «Versicherung. Erledigt.»
  x57..332 y569..595; фон #0A0A0A / #F3F2EE.
- Макет First-Run (read-only B): `screens/First-Run.png` (sha256
  `0411d0a370c2427de5abcb8caa43f2eb00b4eee0657d77c8f08dbbf52df66a94`,
  390×844, ground #0a0a0a) и его исходник `screens/html/First-Run.html`
  (sha256 `7543f598313b1fb83de5aeed6a5732e00cafd3a5433a1cab1c83f72cb8dc756c`;
  meta copy-keys: `ui.first_run.enter_f03, ui.first_run.promise`; раскладка
  `p-astage is-stage-1` из `components/bundle.css:213–221`). Замер полос
  пикселями (PIL, |RGB−ground| > 40): wordmark x165..224 y33..49 (ink, по
  центру); знак x110..289 y123..295 (ink + точка #d6f75a) — ТОТ ЖЕ растр,
  что знак Splash.png со сдвигом y−148 (доля несовпадения 0.00021);
  заголовок 3 строки y369..453 (ink, по центру); подзаголовок 3 строки
  y484..538 (#a6a69f = ink-muted, по центру); CTA x16..373 y738..793
  (358×56 = 390−2·16 × size-lg, #d6f75a); футер «Versicherung. Erledigt.»
  x125..264 y813..825 (ink-muted, по центру). Литералы — source.json
  `first_run_117`.
- Иконка: `logo/assets/complior-app-icon.svg` (1024, rx232, фон #0a0a0a,
  дуга stroke #f2f1ec w12, точка #d6f75a cx76 cy66 r11 во viewBox 96).
- Вход и First-Run: `design-system/project/tokens.css` (.title 28/32/500,
  .body 17/24/400, .label-lg 17/24/500, .body-sm 15/20/400, .caption
  13/18/500, --size-lg 56, пилюля; `--ink-muted` dark #a6a69f / light
  #5f5e58 — строки 6/49; `--accent-text` dark #d6f75a / light #3f6d0f —
  строки 26/69, = tokens.json), `design-system/project/README.md:395` («Лайм
  accent … Как текст — только accent-text на ground и panel (в светлой теме
  это тёмно-зелёный)»), `components/Button/README.md` (primary — одна на
  экран, size-lg 56 во всю ширину; потребитель передаёт size и block,
  перекраска inline запрещена), `components/TextField/README.md` (пилюля
  size-lg на panel без рамки); UX-JSON F01/F03 1.17.8.1 (DIRECT: F03.01 →
  F03.A01/F03.02; `routing.code_entry`); каталог `BrokerOS_UI_Copy_DE.json`
  (ключи — таблица «Состав кадров входа»); `copy/PROPOSED-COPY.md:72`
  (`brand.tagline` «Versicherung. Erledigt.» — brand asset, не копия
  каталога).
- Арбитраж круга 2 (РЕШЕНИЕ, `verdicts/arbitration/contracts-117-splash-vhod-krug2.md`
  в main): закрытый перечень — Б1 эталон целой поверхностью, Б2 судить
  ВЫХОД настоящего генератора (basename НЕ сравнивается), Б3 доказательство
  Maestro + В3 первая линия, С1 назвать среды, С2 конструкция «нативный
  знак + JS-оверлей». Свидетели: native.cjs (композит imageWidth 390 →
  знак ≈84×81 на холсте 288 — масштаб 0.46, «целиком нативный кадр» не
  воспроизводит Splash.png), документация Expo SDK 57 (Expo Go показывает
  иконку приложения; splash тестировать на release-сборке), прогон
  оверлея на B: pilot.test 995 14/14, first_run_111 19/19, дерево под
  оверлеем достижимо (RNTL).
- Находки суда реализации круга 2: `.review/2026-10-21-04.md` В2-3 (ссылки
  light 1,08:1), В2-4 (First-Run ≠ First-Run.png), В2-5 (клеток First-Run
  нет), В2-6 (подпись поля — есть, стиль — форк `n117-r5-r7`).
- Предшественник: контракт 111 (done) — First-Run dark по D2.2.5.1
  (состав: wordmark, promise, CTA; копия закрыта двумя ключами каталога).

## Таблица «кадр макета → что есть на B → что делает 117»

| Кадр (макет) | Есть на B (8748a7a335) / на C 58d60b8 | Делает 117 |
| --- | --- | --- |
| First-Run.png (тёмный; светлый — токены light) | 111: wordmark-dark.png у левого края (x=0), promise, CTA `Button` по контенту ≈45 dp сразу под заголовком; знака, подзаголовка, футера нет; Demo-бейдж в потоке над кадром (двойной top-инсет); light — wordmark #f2f1ec на #f3f2ee (1,01:1) | ВХОДИТ в предмет: состав и раскладка First-Run.png — таблица «Состав First-Run», инвариант 9 (dark × light) |
| Splash.png (тёмный) — знак | splash-icon.png — шаблон Expo 76×76 на #0A0A0A | нативный splash: ОДИН знак `splash-sign-dark.png` (ink #f2f1ec + точка #d6f75a), `dark.backgroundColor` #0A0A0A, imageWidth 181 (ширина знака артборда — литерал), resizeMode contain |
| Splash.png (тёмный) — кадр целиком | полного кадра нет | JS-ОВЕРЛЕЙ `splash-composite-dark.png` (кадр окна 390×844: знак+wordmark+tagline на местах артборда) поверх дерева оболочки |
| Splash-Hell.png (светлый) | светлого splash нет | корень плагина: знак `splash-sign-light.png` (ink #121211 + точка), backgroundColor #F3F2EE, композит light в оверлее; userInterfaceStyle automatic |
| Иконка (complior-app-icon.svg) | icon/adaptive/favicon — шаблон Expo (#E6F4FE) | все производные — растр канона; adaptive фон #0A0A0A |
| F03.01 «Anmelden oder Konto erstellen» | кадр 995: белый корень 48/16/16, title 22/600 #111111, ручные TextInput/Pressable | PNG-макета нет (слово ~19:28): состав по UX-JSON + каталогу на компонентах продукта `@/ui/button`, `@/ui/text-field` (DS на токенах D2.2.5.1), токены схемы |
| F03.02 «Kontakt bestätigen» | кадр 995; на C ссылки лаймом accent в обеих схемах (light 1,08:1) | то же; поле auth-code, кнопка auth-verify, три ссылки цветом accent-text схемы (dark #d6f75a, light #3f6d0f — 5,5:1) |
| F03.04, unavailable, welcome | поверхность 995 | ВНЕ предмета: белый корень 48/16/16 (гварды Г1–Г3) |

## Существующее

- `mobile/src/bootstrap/pilot-app.tsx` (8748a7a335; на C 58d60b8 — корень
  кадров email/code full-bleed ground + JS-оверлей splash + StatusBar по
  схеме): первый кадр first-run → `FirstRunScreen`; корень 995-кадров
  48/16/16 #FFFFFF (frozen 111/1); Demo-бейдж — обёртка `paddingTop:
  insets.top` В ПОТОКЕ корня перед First-Run (111 r5) — сдвигает кадр вниз
  на инсет+бейдж поверх собственного инсета SafeAreaView.
- `mobile/src/features/auth/first-run-screen.tsx` (111; путь в продукте —
  `features/auth/`, каталога `features/first-run/` нет): `SafeAreaView`
  (testID first-run-safe-area, ground) → Image wordmark-dark.png (h22,
  marginTop 20, без центрирования и перекраски) → Text promise (.title,
  ink) → `Button` (testID first-run-continue). Палитра — токены, hex нет.
- `mobile/src/features/auth/auth-screen.tsx`: EmailFrame/CodeFrame на
  `@/ui/button`, `@/ui/text-field` (117/1); ссылки код-кадра `tokens.accent`.
- `mobile/app.json`: expo-splash-screen backgroundColor #0A0A0A (111),
  image splash-icon.png (ШАБЛОН Expo), imageWidth 76; adaptiveIcon
  #E6F4FE; userInterfaceStyle "light"; ios.icon "./assets/expo.icon";
  expo-splash-screen ~57.0.10 — резолверы prebuild поддерживают вложенный
  `dark`-блок (getAndroidSplashConfig.js:7–26 объединяет rest.dark/android.dark).
- `mobile/assets/images/splash-sign-{dark,light}.png` (117/1, 181×173):
  знак артборда схемы — судится SPLASH_SIGN_RASTER аналитикой канона; знак
  First-Run.png — тот же растр (замер: сдвиг y−148, несовпадение 0.00021),
  новый ассет знака не нужен. `wordmark-dark.png` (111, sha пинит 111
  WORDMARK_ASSET_IDENTITY) — одноцветный ink #f2f1ec: светлая схема
  получает ink схемы перекраской `tintColor`, новый ассет не нужен.
- `mobile/src/theme/tokens.ts` (999, frozen): dark ground #0a0a0a/ink
  #f2f1ec/panel #1e1e1d/primary #d6f75a/on-primary #121211; light ground
  #f3f2ee/ink #121211/panel #e6e5df/primary #121211/on-primary #f3f2ee;
  accent #d6f75a в ОБЕИХ; `accent-text` и `ink-muted` НЕТ (в tokens.json
  D2.2.5.1 есть). ThemeContext — пара (scheme, tokens).
- `mobile/src/ui/button.tsx` и `mobile/src/ui/text-field.tsx` (CMP-MOB-002,
  999): Button — пилюля (радиус 999), primary = primary/on-primary схемы,
  обёртка `alignSelf: 'flex-start'`, пропов size/block НЕТ — во всю ширину
  и высотой size-lg 56 Button не встаёт ни у какого родителя (замер
  ревьюера Р7: 45,0 dp по контенту); TextField — подпись caption ink над
  полем-пилюлей на panel, ввод ink, проп `label` обязателен. Структурная
  политика продукта держит общий UI в `src/ui` (`check-structure.cjs`).
- 111 (заморожено): К5 `FIRST_RUN_COPY_CLOSED` — видимая копия First-Run ⊆
  {Demo, promise, CTA}; К4 `WORDMARK_SOURCE_BOUND` — source wordmark-dark.png
  в обеих схемах; К6 `FIRST_RUN_GROUND_FULL_SURFACE`; К7 `DEMO_BADGE_INSET`;
  статическая `SCREEN_NO_HEX_LITERALS`; рестайл кадров 995 вне
  first-run/F03.01/F03.02 запрещён (111 v2/v3 сузили гвард).
- `mobile/.maestro/start.yaml`: assertVisible first-run-continue — сценарии
  живы (оверлей — pointerEvents none, не кадр state-machine, дерево под ним
  достижимо: замер арбитра RNTL + Maestro-семантика иерархии).

## Предмет и граница

Один результат: холодный старт показывает НАШ splash — нативный знак
канона на ground схемы (release/dev-client; Expo Go показывает иконку
приложения + JS-оверлей — свойство SDK 57, документация Expo), затем
JS-ОВЕРЛЕЙ кадра Splash.png/Splash-Hell.png по всей поверхности поверх
дерева оболочки (скрывается таймером), затем — First-Run в составе и
раскладке First-Run.png (dark; light — те же элементы на токенах light);
сверка «скриншот ↔ Splash.png / First-Run.png» — android-e2e на release
APK (Expo Go не показывает картинку плагина — не свидетель). Экраны входа
F03.01/F03.02 — полный состав по UX-JSON F01/F03 и каталогу, собранный из
компонентов Button/TextField дизайн-системы D2.2.5.1 на токенах схемы
(ссылки — accent-text схемы; testID и переходы 995 сохранены).

Вне предмета: JS-КАДР splash (state-machine — оверлей НЕ расширяет
Frame, `frame` стартует с 'first-run' как на B); кадры welcome, F03.04,
unavailable (поверхность 995); AgentPresence в First-Run (знак — статичный
растр канона, Brand README «Static brand mark»; анимация Dynamic Faden —
вне); стиль подписи поля F03.01/F03.02 по README TextField и Button во всю
ширину на F03 (форк `n117-r5-r7`); связка First-Run → вход →
Erstinformation → Start (предмет 118); 116; копия-синька CMP-MOB-089;
device evidence CMP-MOB-090; реальный IdP/бэкенд; анимация splash;
шрифтовой ассет DM Sans.

## Инварианты

1. `mobile/app.json`: `expo.icon` — растр канона complior-app-icon;
   android.adaptiveIcon.{foreground,background,monochrome}Image и
   web.favicon — производные того же исходника; adaptiveIcon.backgroundColor
   `#0A0A0A`; файлы не совпадают побайтово с шаблонами Expo (sha базы B в
   source.json) и несут геометрию канона ЦЕЛЫМ изображением (инвариант 3);
   ios.icon не указывает на шаблонный каталог Expo.
2. Плагин expo-splash-screen: нативный splash = ОДИН знак канона на
   ground схемы — корень светлый (`backgroundColor` `#F3F2EE`, `image`
   splash-sign-light.png), вложенный `dark` тёмный (`#0A0A0A`,
   splash-sign-dark.png), `imageWidth` 181 — ширина знака артборда
   x109..289 (ЛИТЕРАЛ source.json), `resizeMode` "contain",
   `userInterfaceStyle: "automatic"`. Фоны = ground токенов схемы (999).
   ЭФФЕКТИВНАЯ конфигурация (резолверы getAndroidSplashConfig/
   getIosSplashConfig из node_modules продукта) даёт эти фоны; платформенные
   ассеты судятся ПРОИЗВЕДЁННЫМИ файлами (инвариант 4а) — basename НЕ
   сравнивается.
3. Растры иконки — канон ЦЕЛЫМ изображением: аналитическая растеризация
   SVG-литералов source.json, согласие классов ≥ 0.97, покрытие класса
   0.7–1.35, альфа-bbox ±3 px; точечные пробы — дешёвая первая линия.
4. Splash судится ЭТАЛОНОМ и ВЫХОДОМ генератора (арбитраж круга 2):
   а) произведённые платформой ассеты: настоящие `getAndroidSplashConfig`
      + `setSplashImageDrawablesAsync` (node_modules продукта) пишут
      drawable-{mdpi..xxxhdpi}/splashscreen_logo.png и drawable-night-*/…
      (холст 288×множитель): dims = 288×m, содержимое = знак канона
      (аналитическая растеризация splash_sign source.json — геометрия
      знака АРТБОРДА, не mark-96: замер круга 4 — зазор кольца −29..+36°,
      согласие 0.9872), размер знака = imageWidth×m ±3 по обеим осям;
      iOS — содержимое файла по ЭФФЕКТИВНОМУ пути (light/dark) тем же
      критерием + эффективные imageWidth/resizeMode; ключа
      `enableFullScreenImage_legacy` НЕТ в props плагина (корень, ios,
      dark, ios.dark — литерал отсутствия), эффективное значение false, и
      ВЫХОД настоящих `getIosSplashConfig` + `applySplashScreenStoryboard`
      (шаблон `getTemplateAsync`) даёт рамку картинки 181×181 с
      constraints ровно centerX/centerY (legacy-режим — 414×736 и краевые
      top/leading/trailing/bottom — красен); любой override (шаблон,
      композит, другой путь, density-ключ, imageWidth, legacy) меняет
      произведённый выход и красен;
   б) композит JS-оверлея (кадр окна) = ЭТАЛОН артборда ЦЕЛОЙ
      поверхностью: Splash.png/Splash-Hell.png припинены sha256 в
      source.json (несовпадение — rc2 ORACLE_TAMPERED); РАЗМЕР композита =
      размер артборда 390×844 (литерал; иной масштаб при точном aspect —
      195×422, 39×84 — теряет маску и красен именованной причиной); маска
      E: |RGB−фон| ≤40 → прозрачно; recall — по ВСЕМ пикселям M (тёмный
      15439, светлый 15346) ≥ 0.98, precision — по ВСЕМ непрозрачным
      пикселям C ≥ 0.98, цвет ≤40; выборки нет; стабы «семь пикселей»/
      «знак без надписей»/«сдвиг 9 px»/«половинный масштаб» красны той же
      клеткой; полосы artboard_117 — дешёвая первая линия, НЕ критерий.
5. Текст tagline — слово владельца 18:18 (эталон Splash.png; ключа в
   каталоге нет), живёт ТОЛЬКО в растре композита; копия входа — ключи
   каталога verbatim (таблица ниже).
6. Кадры F03.01/F03.02: состав — РОВНО таблица «Состав кадров входа»
   (каждый элемент × dark/light); заголовок .title 28/32/500 ink схемы;
   поле — компонент продукта `TextField` из `@/ui/text-field` (пилюля:
   радиус ≥ 28 = половина --size-lg 56; фон panel схемы, ввод ink; подпись
   — body-ключ кадра цветом ink); основная кнопка — `Button` из
   `@/ui/button` (variant primary: пилюля, заливка primary схемы, подпись
   on-primary); ссылки — ЭФФЕКТИВНЫЙ цвет accent-text схемы (dark #d6f75a,
   light #3f6d0f; контраст к ground ≥ 4.5), в модуле — `tokens['accent-text']`
   (лайм `accent` как текст запрещён, D2.2.5.1 README:395); модуль кадров
   импортирует оба компонента, оба сегмента (EmailFrame/CodeFrame) их
   рендерят — ручные TextInput/Pressable со «теми же hex» красны; ни одного
   hex в сегментах (палитра — useTheme); корень кадров full-bleed ground
   схемы; кадр целиком внутри окна 390×844 (доказательство — Maestro
   assertVisible на release APK, Б3; в Jest — только первая линия В3);
   testID и переходы 995 сохранены.
7. Кадры welcome/recovery(F03.04)/unavailable — поверхность 995: корень
   #FFFFFF, отступы 48/16/16 в ОБЕИХ схемах на ВСЕХ исключённых кадрах.
8. JS-ОВЕРЛЕЙ splash (С2, арбитраж круга 2): рендерится ПОВЕРХ дерева
   оболочки (последний ребёнок корня PilotApp), `StyleSheet.absoluteFill`,
   `pointerEvents="none"`, фон `tokens.ground` схемы, содержимое — РОВНО
   один Image, эффективный `source` которого — модуль файла
   `mobile/assets/images/splash-composite-{dark,light}.png` СВОЕЙ схемы
   (того, чьё содержимое судит 4б; require относительным путём из
   pilot-app.tsx), `resizeMode contain`, absoluteFill, не скрыт; БЕЗ
   Text-узлов (wordmark/tagline — растр); автоскрытие таймером-литералом
   1200 мс с очисткой в cleanup; `SplashScreen.preventAutoHideAsync()` на
   модуле, `hideAsync()` — ровно один раз в effect ПОСЛЕ первого commit
   дерева с оверлеем (наблюдается commit-журналом: prevent → commit с
   оверлеем (React.Profiler) → hide; hide в render, на модуле, в первом
   commit без оверлея — красны); оверлей НЕ расширяет Frame
   state-machine; `pilot.test` 995 на модели с оверлеем — 14/14;
   батареи соседей — раздел «ПЕРЕСЕЧЕНИЕ с 111/995/999».
9. First-Run (× dark/light) — состав и раскладка First-Run.png/First-Run.html
   (p-astage is-stage-1), конструкцией по эффективному стилю:
   а) First-Run — первый В ПОТОКЕ host-ребёнок корня PilotApp (всё перед
      ним, в т.ч. Demo-бейдж, — `position: 'absolute'`; бейдж сохраняет
      paddingTop = insets.top, 111 К7); верхний блок артборда —
      paddingTop 20, minHeight 60, justifyContent center;
   б) wordmark (testID first-run-wordmark, source wordmark-dark.png 111) —
      первый Image/Text First-Run, по центру по горизонтали (alignSelf
      center либо alignItems center родителя), высота 22, ЭФФЕКТИВНЫЙ ink
      = `tintColor` = ink схемы (контраст к ground ≥ 4.5; без перекраски
      light #f2f1ec на #f3f2ee 1,01:1 — красно);
   в) знак канона (testID first-run-sign) — РОВНО один Image First-Run с
      source = модуль `mobile/assets/images/splash-sign-<схема>.png` СВОЕЙ
      схемы (тот файл, что судит SPLASH_SIGN_RASTER), 181×173, по центру,
      между wordmark и promise в порядке документа;
   г) заголовок `ui.first_run.promise` (.title, ink, по центру — как 111);
   д) подзаголовок — литерал First-Run.html (source.json
      `first_run_117.subline`, ключа каталога нет — вопрос №9): РОВНО один
      Text, .body-sm 15/20, textAlign center, ink-muted схемы (dark
      #a6a69f, light #5f5e58; контраст ≥ 4.5), после promise, до CTA;
   е) CTA `ui.first_run.enter_f03` — `Button` primary (testID
      first-run-continue): пилюля, primary/on-primary, высота size-lg 56,
      ВО ВСЮ ШИРИНУ — цепь host-узлов First-Run→пилюля не сужается
      (alignSelf не flex-start/center/flex-end/baseline; при таком
      alignItems родителя — alignSelf stretch; width/maxWidth не заданы),
      сумма горизонтальных padding предков и margin цепи = 16 с каждой
      стороны; ВНИЗУ — корень First-Run flex 1, блок CTA — его последний
      host-ребёнок, свободное место перед ним (flex/flexGrow брата,
      marginTop auto или justifyContent flex-end/space-between корня);
   ж) футер `brand.tagline` «Versicherung. Erledigt.»: РОВНО один Text,
      .caption 13/18/500, по центру, ink-muted схемы (контраст ≥ 4.5),
      ПОСЛЕ CTA в порядке документа;
   з) палитра First-Run — только токены схемы: модуль экрана (без
      комментариев) без hex, читает tokens.ground, tokens.ink,
      tokens['ink-muted']; `tokens.ts` получает АДДИТИВНО `accent-text` и
      `ink-muted` обеих схем значениями tokens.json; `Button` получает
      АДДИТИВНО пропы `size` ('md' | 'lg', lg — высота 56) и `block`
      (обёртка stretch) — без пропов прежнее поведение 999;
   и) Demo-бейдж (testID demo-indicator; на PNG его нет, 995 требует
      индикатор — форк (А): «подложка Demo видима») на кадрах D2.2.5.1
      (first-run, F03.01, F03.02) — чип DS: подложка panel схемы, текст
      ink схемы (контраст к подложке ≥ 4.5); на кадрах 995 — прежний вид.
   Пиксели кадра (y полос, центр по x) в Jest не вычисляются — это
   android-e2e-скриншот ↔ First-Run.png (полосы — source.json
   `first_run_117.bands_px`), правило (В).

## Состав кадров входа (UX-JSON F01/F03 + каталог, литералы)

| Экран | Элемент (testID/роль) | Компонент продукта (DS) | Ключ каталога → текст |
| --- | --- | --- | --- |
| F03.01 | заголовок (role header) | Text .title, ink | `frame.F03.01.title` → «Anmelden oder Konto erstellen» |
| F03.01 | `auth-email` + подпись | `TextField` (`@/ui/text-field`), panel/ink | подпись `frame.F03.01.body` → «Nutzen Sie den angebotenen Anmeldeweg, um auf Ihre Versicherungen zuzugreifen.» |
| F03.01 | `auth-demo-entry` | `Button` primary (`@/ui/button`) | `ui.auth.demo_entry` → «Demo mit Beispieldaten ansehen» |
| F03.02 | заголовок (role header) | Text .title, ink | `frame.F03.02.title` → «Kontakt bestätigen» |
| F03.02 | `auth-code` + подпись | `TextField`, panel/ink, secureTextEntry | подпись `frame.F03.02.body` → «Geben Sie den zugesandten Code ein. Prüfen Sie bei Bedarf Ihre Kontaktdaten.» |
| F03.02 | `auth-verify` | `Button` primary | `action.F03.A01` → «Anmelden» |
| F03.02 | `auth-resend` | ссылка, accent-text схемы | `ui.auth.code_resend` → «Code erneut senden» |
| F03.02 | `auth-change-email` | ссылка, accent-text схемы | `auth.change_email` (COPY 995) → «E-Mail ändern» |
| F03.02 | `auth-no-access` | ссылка, accent-text схемы | `action.F03.A02` → «Zugang wiederherstellen» |

Ключа подписи поля в каталоге нет, копия не выдумывается: обязательную
подпись `TextField` несёт body-ключ кадра — он и есть инструкция к полю
(вопрос владельцу №6). Поведенческие состояния 995 (auth-invalid,
auth-cooldown, resend-sent, demo-indicator) сохраняются как на B и в
состав рестайла не входят.

### Состав First-Run (First-Run.png / First-Run.html)

| Элемент (testID) | Компонент / ассет | Текст / ключ | Стиль (dark / light) |
| --- | --- | --- | --- |
| wordmark (`first-run-wordmark`) | Image wordmark-dark.png, h22, по центру | — (label «complior») | tintColor ink #f2f1ec / #121211 |
| знак (`first-run-sign`) | Image splash-sign-<схема>.png 181×173, по центру | — | растр канона схемы |
| заголовок (`first-run-promise`) | Text .title 28/32/500, по центру | `ui.first_run.promise` | ink |
| подзаголовок | Text .body-sm 15/20, по центру | литерал First-Run.html (без ключа, №9) | ink-muted #a6a69f / #5f5e58 |
| CTA (`first-run-continue`) | `Button` primary size lg block, поля 16, внизу | `ui.first_run.enter_f03` | primary / on-primary |
| футер | Text .caption 13/18/500, по центру, под CTA | `brand.tagline` «Versicherung. Erledigt.» | ink-muted |

## Проверяемый шов

`mobile/app.json` (плагин: знаки splash-sign-{dark,light}.png; композиты
оверлея `mobile/assets/images/splash-composite-{dark,light}.png`;
производные иконки); `mobile/src/bootstrap/pilot-app.tsx` (корень кадров
email/code, JS-оверлей splash, Demo-бейдж вне потока на first-run и
чип DS panel/ink на кадрах D2.2.5.1);
`mobile/src/features/auth/auth-screen.tsx` (EmailFrame/CodeFrame на
`@/ui/button`, `@/ui/text-field`; ссылки accent-text);
`mobile/src/features/auth/first-run-screen.tsx` (First-Run по
First-Run.png); `mobile/src/theme/tokens.ts` (АДДИТИВНО accent-text,
ink-muted); `mobile/src/ui/button.tsx` (АДДИТИВНО size, block); сценарий
Maestro 117 в `mobile/.maestro/` (после freeze — implementer). Ожидания
проб — литералы source.json (сняты с read-only docs/ B ДО субъекта,
правило 8/Н-351); ни одна клетка не читает значения у субъекта; эталоны
артбордов припинены sha256 (несовпадение — rc2 ORACLE_TAMPERED).

## Закрытые перечни клеток (числа — из прогонов v2 на клоне C 58d60b8)

Поведенческая семья (Jest/RNTL, `vkhod_probe.py` → `vkhod.test.tsx`,
44 клетки = 22 группы × {DARK, LIGHT}):
- В1 `AUTH_F03_01_STRUCTURE_{DARK,LIGHT}` — ВСЕ элементы F03.01 из
  таблицы состава: заголовок (.title, ink), подпись поля (body-ключ, ink),
  auth-email (пилюля ≥ 28, panel, ввод ink), auth-demo-entry (пилюля ≥ 28,
  заливка primary, подпись текстом каталога on-primary), корень ground.
- В2 `AUTH_F03_02_STRUCTURE_{DARK,LIGHT}` — ВСЕ элементы F03.02: заголовок,
  подпись поля (body-ключ, ink), auth-code (пилюля, panel, ink), auth-verify
  (пилюля, primary, подпись on-primary), три ссылки ЭФФЕКТИВНЫМ цветом
  accent-text схемы (dark #d6f75a, light #3f6d0f) с контрастом к ground
  ≥ 4.5, корень ground.
- FR `FIRST_RUN_TOP_{DARK,LIGHT}` (инв. 9а), `FIRST_RUN_WORDMARK_{DARK,LIGHT}`
  (9б), `FIRST_RUN_SIGN_{DARK,LIGHT}` (9в), `FIRST_RUN_SUBLINE_{DARK,LIGHT}`
  (9д), `FIRST_RUN_CTA_BOTTOM_{DARK,LIGHT}` (9е), `FIRST_RUN_TAGLINE_{DARK,LIGHT}`
  (9ж) — конструкция раскладки First-Run.html по эффективному стилю цепи
  host-узлов (toJSON) и порядку документа; знак и wordmark — сентинели
  модулей файлов (`jest.mock(…, {virtual: true})`, как композиты С2-а);
  `DEMO_BADGE_CHIP_{DARK,LIGHT}` (9и) — бейдж на first-run, F03.01, F03.02.
- В3 `AUTH_FRAMES_IN_WINDOW_{DARK,LIGHT}` — ПЕРВАЯ ЛИНИЯ по
  эффективному стилю (НЕ доказательство: layout в Jest не вычисляется):
  кумулятивный translate корень→лист < окна; чужие типы трансформаций;
  поля бокса (margin*/padding*/left/top/right/bottom) ≥ окна;
  display:'none'; opacity 0 — красны. Доказательство «кадр в окне» —
  Maestro assertVisible (Б3, приёмка).
- Г1 `RESTYLE_GUARD_995_WELCOME_{DARK,LIGHT}`, Г2
  `RESTYLE_GUARD_995_RECOVERY_{DARK,LIGHT}`, Г3
  `RESTYLE_GUARD_995_UNAVAILABLE_{DARK,LIGHT}` — #FFFFFF и 48/16/16.
- Р1 `PROD_ENTRY_OS_THEME_{DARK,LIGHT}`, Р4 `AUTH_FRAMES_SAFE_AREA_{DARK,LIGHT}`,
  В2-2 `STATUS_BAR_STYLE_{DARK,LIGHT}`.
- С2-оверлей: `SPLASH_OVERLAY_MOUNTED_{DARK,LIGHT}`,
  `SPLASH_OVERLAY_COMPOSITE_{DARK,LIGHT}`, `SPLASH_OVERLAY_CONTAIN_{DARK,LIGHT}`,
  `SPLASH_OVERLAY_NO_TEXT_{DARK,LIGHT}`, `SPLASH_HIDEASYNC_ORDER_{DARK,LIGHT}`,
  `SPLASH_OVERLAY_TIMER_HIDE_{DARK,LIGHT}` (содержание — как в 117/1:
  absoluteFill, pointerEvents none, ground; РОВНО один Image с модулем
  композита своей схемы; без Text; commit-журнал prevent → первый commit с
  оверлеем → один hide; скрытие 1200 мс).

Статическая семья (`vkhod_static_probe.py`, 38 клеток):
APP_ICON_DERIVATIVES, ICON_NOT_TEMPLATE_BYTES, ICON_ADAPTIVE_BG_DARK,
ICON_PIXELS_MARK, SPLASH_BLOCKS_DARK_LIGHT, SPLASH_EFFECTIVE_DARK_LIGHT,
SPLASH_NATIVE_GENERATED_{LIGHT,DARK}_{MDPI,HDPI,XHDPI,XXHDPI,XXXHDPI} ×10 +
сводная SPLASH_NATIVE_GENERATED, SPLASH_EFFECTIVE_IOS_{LIGHT,DARK},
SPLASH_IOS_STORYBOARD, SPLASH_COMPOSITE_ETALON_{DARK,LIGHT},
SPLASH_SIGN_RASTER_{DARK,LIGHT}, SPLASH_OVERLAY_CONSUMES_COMPOSITE,
USER_STYLE_AUTOMATIC, AUTH_FRAMES_TOKENIZED (сегменты входа без hex,
ссылки `tokens['accent-text']`, `tokens.accent }` в CodeFrame — красно),
AUTH_DS_COMPONENTS, FIRST_RUN_TOKENIZED (инв. 9з), STATIC_ORACLE_LITERALS
(+ литералы v2: accent-text/ink-muted light, подзаголовок, футер),
ICON_RASTER_WHOLE, ADAPTIVE_FG_RASTER, ADAPTIVE_MONO_RASTER,
ADAPTIVE_BG_SOLID, FAVICON_RASTER_WHOLE, IOS_ICON_NOT_TEMPLATE,
MAESTRO_SPLASH_FRAME_WAIT, MAESTRO_FIRST_RUN_ORDER (порядок шагов сценария:
до кадра First-Run — оверлей снят и `assertVisible` обещания, CTA, v2 —
id first-run-wordmark и first-run-sign, текста подзаголовка и футера).

Обманные стабы — привязка к ветвям ТОЛЬКО в коде проб (`MUTANTS`
`vkhod_probe.py` — 47, `vkhod_static_probe.py` — 28; Н-39: каждый стаб
красен на входе, где его дефект наблюдаем; depends измерены полным
прогоном матрицы); якорь мутанта неуникален → отказ rc2; сломанный
мутантом свит → MUTANT_SUITE_BROKEN rc2 (не зелень); краснота вне
named ∪ depends — MUTANT_UNEXPECTED_RED rc2.

## Приёмочный критерий

R — disposable копия Complior-mob под /tmp/dev-harness-verify с
node_modules в mobile/ (симлинк); пробы — Python 3 stdlib.

- Дано C = `58d60b8` (форма кадров sheet3 pin4); `python3
  fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo R` → rc1,
  `failed 15 of 44`: RED ровно `FIRST_RUN_{TOP,WORDMARK,SIGN,SUBLINE,
  CTA_BOTTOM,TAGLINE}_{DARK,LIGHT}` (12), `DEMO_BADGE_CHIP_{DARK,LIGHT}` и
  `AUTH_F03_02_STRUCTURE_LIGHT`.
- Дано C = `58d60b8`; `vkhod_static_probe.py --repo R` → rc1, `failed 3 of
  38`: RED `AUTH_FRAMES_TOKENIZED`, `FIRST_RUN_TOKENIZED`,
  `MAESTRO_FIRST_RUN_ORDER`.
- Дано B без реализации: `vkhod_probe.py --repo R` → rc1
  `VKHOD_AUTH_DS_ABSENT`; `vkhod_static_probe.py --repo R` → rc1
  `VKHOD_SPLASH_COMPOSITE_ABSENT`.
- Дано B или C с эталонной моделью (`--model`) либо честное C v2: обе пробы
  → rc0: `behavioral 44/44`, `static 38/38`.
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный, каждый
  стаб красен именованной ветвью (47 + 28), побочная краснота только в depends.
- Дано C; `git status --short --untracked-files=all` в R после проб — 0 строк
  кроме симлинка `mobile/node_modules` (инфраструктура R, не проба).
- Дано C v2; `npm run lint`, `npm run typecheck` в R/mobile → rc0;
  `npx jest src/bootstrap/__tests__/pilot.test.tsx` (995, byte-frozen) → rc0,
  14/14; батарея 999 (`fixtures/workshop_project/nav_999/{ui_probe,
  shell_static_probe,nav_probe,copy_probe}.py --repo R`) → rc0 каждая
  (аддитивные токены/пропы; замер на модели v2). Батарея
  `fixtures/workshop_project/first_run_111/` на C v2: RUN, ожидаемо rc1 до
  миграции 111 — красна ровно К5 `FIRST_RUN_COPY_CLOSED_{DARK,LIGHT}`
  (поведенческая; замер на модели v2), статическая — rc0; зелёной в
  немигрированной форме НЕ заявляется (раздел «ПЕРЕСЕЧЕНИЕ»).
- Дано C v2 в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0;
  android-e2e (release APK: `expo prebuild` + `assembleRelease`, Maestro)
  исполняет сценарий 117 в `mobile/.maestro/`: First-Run — `assertVisible`
  first-run-wordmark, first-run-sign, текста promise, подзаголовка, CTA и
  футера; F03.01/F03.02 — `assertVisible` КАЖДОГО элемента таблицы «Состав
  кадров входа» × тема устройства (Б3 «кадр в окне»); takeScreenshot
  КАЖДОГО кадра по правилу (В): splash × {тёмная, светлая} — сверка с
  Splash.png / Splash-Hell.png; First-Run × {dark, light} — сверка с
  First-Run.png (полосы source.json `first_run_117.bands_px`; light — те же
  полосы на токенах light); F03.01 × {dark, light}, F03.02 × {dark, light}
  — сверка с компонентами/токенами D2.2.5.1 и составом таблицы (8
  скриншотов); скриншоты в артефактах прогона, ревьюер сверяет глазами и
  мерой.
- Дано авторская пачка; `bash scripts/pre_critic.sh
  contracts/117-cmp-mob-vkhod-splash.md` → rc0.

## ПЕРЕСЕЧЕНИЕ с 111/995/999 (БЕЗ правок 111/999 в этой пачке)

Замер — батареи соседей на C 58d60b8 + эталон 117 v2 (все файлы модели
как рабочее дерево):
- 111 К5 `FIRST_RUN_COPY_CLOSED_{DARK,LIGHT}` (`first_run_111/
  first_run.test.tsx`: видимая копия ⊆ {Demo, promise, CTA}) — КРАСНЫ
  честным First-Run по PNG (подзаголовок и футер). Миграция: перечень К5 +=
  {литерал подзаголовка First-Run.html, brand.tagline «Versicherung.
  Erledigt.»} — 111 v4, зона architect 111
  (`fixtures/workshop_project/first_run_111/`), строка РАЗРЕШИЛ к тексту
  111; до неё шаг приёмки first_run_111 — RUN, ожидаемо rc1 ровно по К5.
- 111 остальные клетки (К1 STRUCTURE, К3 SAFEAREA_EDGES_ACTIVE, К4
  WORDMARK_SOURCE_BOUND — source остаётся wordmark-dark.png, перекраска
  tintColor; К6 GROUND_FULL_SURFACE; К7 DEMO_BADGE_INSET — paddingTop =
  insets.top у вынесенной из потока обёртки; К8/К9 RESTYLE_GUARD_995) и
  статическая 111 (SCREEN_NO_HEX_LITERALS — hex нет и в комментариях) —
  зелёные, миграции не требуют.
- 995: `pilot.test.tsx` 14/14 (byte-frozen) — без миграции.
- 999: `tokens.ts` (+ `accent-text`, `ink-muted` обеих схем значениями
  tokens.json) и `ui/button.tsx` (+ пропы `size`, `block`; без пропов —
  прежние стиль и поведение) — АДДИТИВНО; батарея nav_999 (ui, shell
  static, nav, copy) — rc0 на модели v2, миграции не требует. Правка
  файлов frozen-семьи 999 — расширение зоны implementer 117 этим текстом
  (вопрос №10).

## Зоны и исполнители

ЗОНА architect: contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Пути implementer отсчитываются от корня Complior-mob:

ЗОНА implementer: mobile/app.json mobile/assets/images/ (icon.png, splash-composite-dark.png, splash-composite-light.png, splash-sign-dark.png, splash-sign-light.png, android-icon-foreground.png, android-icon-background.png, android-icon-monochrome.png, favicon.png) mobile/src/bootstrap/pilot-app.tsx mobile/src/features/auth/auth-screen.tsx mobile/src/features/auth/first-run-screen.tsx mobile/src/theme/tokens.ts mobile/src/ui/button.tsx .github/workflows/mobile.yml mobile/.maestro/

ПЕРЕСЕЧЕНИЕ: `mobile/src/bootstrap/pilot-app.tsx`,
`mobile/src/features/auth/auth-screen.tsx` и
`mobile/src/features/auth/first-run-screen.tsx` — общие с замороженными
семьями 995/111: в pilot-app меняются корень кадров email/code, JS-оверлей
splash (последний ребёнок корня, НЕ кадр state-machine) и обёртка
Demo-бейджа на first-run (вне потока, paddingTop = insets.top) и вид
бейджа на кадрах D2.2.5.1 (чип DS panel/ink; на кадрах 995 — прежний); первый
кадр и вход шва — как на B; first-run-screen — состав и раскладка
First-Run.png (111 К5 мигрирует 111 v4 — раздел «ПЕРЕСЕЧЕНИЕ с
111/995/999»). `mobile/src/theme/tokens.ts` и `mobile/src/ui/button.tsx`
— общие с 999: ТОЛЬКО аддитивные ключи `accent-text`, `ink-muted` и пропы
`size`, `block`; прочие значения и поведение — байт в байт как на B.
`mobile/src/ui/text-field.tsx`, прочие `mobile/src/ui/`,
`mobile/src/bootstrap/__tests__/` (995), `docs/`, `design/` — read-only
для 117. Знаки, композиты и wordmark новых ассетов не требуют: знак
First-Run — `splash-sign-<схема>.png`, wordmark — `wordmark-dark.png` с
tintColor. Действующие Maestro-сценарии лежат в `mobile/.maestro/`
(совет критика, подтверждён арбитражем), сценарий 117 — туда же.

РАБОТА НЕ РАЗДАЁТСЯ: implementer не спавнится до accept критика и freeze
оркестратора; предмет этой пачки — контракт + красные пробы, предъявленные
красными на C 58d60b8 и зелёными на эталоне.

## Модель угроз

ЗАЩИЩАЕТ:
- от шаблонной иконки Expo: пиксельные свойства канона + sha-литералы
  шаблонов базы B + ЦЕЛОЕ изображение производных против аналитической
  растеризации канона (подложки-близнецы с точками старых проб красны);
- от подложного композита оверлея (Б1): эталон артбордов припинен sha256
  (несовпадение — rc2 ORACLE_TAMPERED), маска E «фон±40 → прозрачно»,
  размер композита = артборд 390×844 (иной масштаб при точном aspect
  красен: свидетели круга 3 halfres 195×422 и lowres 39×84 — замер круга
  5), recall по ВСЕЙ маске M (15439/15346 пикселей) И precision по ВСЕМ
  непрозрачным C ≥ 0.98 (стабы «семь пикселей», «знак без надписей»,
  «сдвиг 9 px», «половинный масштаб» красны той же клеткой; честная
  модель recall 1.0 / precision 1.0, m_total 15439/15346 — замер круга 5);
- от подмены платформенных ассетов (Б2): клетка вызывает НАСТОЯЩИЕ
  getAndroidSplashConfig + setSplashImageDrawablesAsync и судит
  СОДЕРЖИМОЕ произведённых drawable-{mdpi..xxxhdpi}/splashscreen_logo.png и
  drawable-night-* обеих тем (знак аналитикой splash_sign, dims 288×m,
  размер знака = imageWidth×m ±3); iOS — содержимое по эффективному пути +
  эффективные imageWidth/resizeMode + ВЫХОД настоящего генератора
  storyboard (рамка 181×181, centerX/centerY) при литерале отсутствия
  `enableFullScreenImage_legacy`; basename НЕ сравнивается (стабы
  same-basename / density-template / template-override / imageWidth-76 /
  ios-legacy красны выходом генератора, замер круга 5);
- от одновариантного или недостижимого splash: блоки app.json (знаки обеих
  тем, imageWidth 181, contain) + эффективные ФОНЫ резолверами prebuild,
  USER_STYLE_AUTOMATIC;
- от пропажи кадра Splash.png в Expo Go / после натива (С2): оверлей
  судится поведенчески — смонтирован (absoluteFill, pointerEvents none,
  ground), РОВНО один Image с эффективным source = модуль композита СВОЕЙ
  схемы, тот самый файл, что судит эталон Б1 (стаб overlay-wrong-source
  красен поведенческой и статической клетками), без Text-узлов;
  commit-журнал prevent → первый commit с оверлеем → один hide (стаб
  hide-в-render красен: журнал `["hide","commit+overlay"]`), скрытие
  таймером-литералом 1200 мс;
- от неполного состава входа: В1/В2 судят КАЖДЫЙ элемент таблицы состава ×
  обе схемы (body выброшен — красно); состав = таблица (UX-JSON маршруты +
  поверхность 995 + каталог);
- от ручных стилей с теми же hex вместо компонентов DS: эффективные
  свойства компонентов (пилюля, primary/on-primary, panel/ink, подпись
  поля) в В1/В2 + AUTH_DS_COMPONENTS (импорт `@/ui/button`/`@/ui/text-field`
  и рендер в обоих сегментах; ручные TextInput/Pressable красны);
- от второй палитры входа: AUTH_FRAMES_TOKENIZED + наблюдение ground/ink/
  primary/on-primary/panel в обеих схемах; ссылки — эффективным
  accent-text схемы;
- от дешёвых обходов «кадр в окне» (первая линия): В3 — кумулятивный
  translate, поля бокса ≥ окна, display none, opacity 0 (стабы
  translateX-1000 и marginLeft-1000 красны, замер круга 4);
- от First-Run не по PNG (В2-4/В2-5): FIRST_RUN_{TOP,WORDMARK,SIGN,
  SUBLINE,CTA_BOTTOM,TAGLINE} × схемы судят каждый элемент First-Run.png
  (присутствие РОВНО раз, порядок документа, типографика, токен цвета,
  контраст ≥ 4.5) и конструкцию раскладки артборда (кадр — первый в
  потоке, верхний блок 20/60, центр wordmark/знака, CTA 56 во всю ширину с
  полями 16 внизу: цепь не сужается, свободное место перед блоком CTA);
  знак — модуль файла, который судит SPLASH_SIGN_RASTER (знак тёмной схемы
  в светлой — красно); wordmark — эффективный ink tintColor/растра (light
  без перекраски 1,01:1 — красно); Demo-бейдж — чип DS panel/ink на кадрах
  D2.2.5.1; форма C 58d60b8 красна 14 клетками First-Run/бейджа;
- от нечитаемых ссылок F03.02 (В2-3): эффективный accent-text схемы +
  контраст ≥ 4.5 (лайм в light 1,08:1 — красно LIGHT-клеткой), статически
  `tokens['accent-text']` в CodeFrame;
- от тихого рестайла соседних кадров: Г1–Г3 по ВСЕМ исключённым кадрам ×
  схемы;
- от зависимого оракула (Н-351): ожидания — литералы source.json/теста,
  STATIC_ORACLE_LITERALS; эталоны — sha-пин read-only docs/;
- от мёртвой матрицы: обе пробы исполняют все стабы (47+28), depends
  измерены прогоном, unexpected_red/suite_broken — rc2.

НЕ ЗАЩИЩАЕТ:
- layout в Jest не вычисляется (yoga в node_modules продукта нет — замер
  арбитра): В3 — только первая линия по эффективному стилю; окно — только
  android-e2e (Maestro assertVisible, release APK); ловец — CI android-e2e;
- пиксели First-Run (y полос, центр по x, ширина CTA в dp на устройстве)
  в Jest не вычисляются: FR-клетки судят КОНСТРУКЦИЮ раскладки артборда, а
  не её результат; обход «конструкция верна, рендер иной» (например, шрифт
  иной метрики сдвигает полосы) ловит ревьюер по скриншотам android-e2e
  против First-Run.png и полос `first_run_117.bands_px` (правило В) —
  остаточный риск, механического пиксельного гейта кадра First-Run нет;
- светлой схемы First-Run.png нет: light выводится токенами (ground/ink/
  ink-muted/primary/on-primary/accent-text) — визуал light против
  намерения дизайна сверяет ревьюер (вопрос №12);
- от пиксельной точности нативного splash на устройстве (рендер ОС,
  круговая маска Android 12+, масштаб при иных окнах) — app.json литералы
  + произведённые drawable; ловец — ревьюер по скриншотам android-e2e
  (правило В);
- от скачка знака натив→оверлей (центр экрана → место артборда, ≈65 px) и
  мигания в момент смены — свойство платформы, cognitive-only (арбитраж,
  «К владельцу» №7): принятый остаточный риск, ловец — ревьюер по записи
  android-e2e; в Expo Go нативный знак не виден вовсе (С1, №8);
- commit-журнал судит порядок жизненного цикла React (commit → effect),
  а не момент отрисовки пикселей на устройстве: кадр между снятием
  нативного знака и первым показом оверлея на телефоне не измеряется;
  ловец — ревьюер по записи android-e2e (пустой кадр);
- от точности глифов wordmark/tagline в композите (шрифт DM Sans) — эталон
  судит маску/цвет, не начертание; ловец — ревьюер по правилу (В);
- от расхождения визуала входа с README компонентов DS вне измеряемых
  свойств (высота size-lg 56, шкала label-lg, отступы колонки — компоненты
  продукта CMP-MOB-002 их не несут, 117 их не меняет) — PNG-макета входа нет
  (слово ~19:28); ловец — ревьюер по скриншотам против components/Button,
  components/TextField и tokens.css;
- от реальной аутентификации (IdP) — поверхность 995/бэкенд, вне предмета;
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI
  evidence.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: правило (В) «Мобильный экран — сверка с макетом» (слово
владельца ~18:00) — норм-строки в roles/reviewer.md ЕЩЁ НЕТ, поэтому
role-канал с литералом невозможен и правило потребляется ЗДЕСЬ прозой как
cognitive-only: макет каждого кадра назван (splash — Splash.png/
Splash-Hell.png; First-Run — First-Run.png; иконка — complior-app-icon.svg;
F03.01/F03.02 — PNG нет, слово владельца ~19:28: компоненты/токены
D2.2.5.1 + таблица состава),
takeScreenshot каждого кадра (android-e2e), ревьюер сверяет скриншот ↔
макет глазами и мерой. Остаточный риск: механического гейта сверки нет —
незаснятый кадр или расхождение ловит только ревьюер на C (ловец — reviewer).
Новая общая норма харнесса не вводится. Пробы 117 исполняются в CI
Complior-mob из H-checkout по образцу 999/107/108/111 (шаг quality в
mobile.yml, зона implementer); в registry/ci-steps.tsv харнесса НЕ
регистрируется (python3 stdlib, npm-ключа нет).

## Вопросы владельцу

1. ЗАКРЫТ (слово владельца 2026-10-20 ~19:28 UTC): «F03.01/F03.02 — по
   токенам и компонентам D2.2.5.1 и UX-JSON F01/F03, PNG-макета нет».
   Исполнено таблицей «Состав кадров входа» и инвариантом 6.
2. Шрифт tagline/заголовков: канон — DM Sans; в мобильном рантайме системный
   шрифт (в композите splash tagline — растр артборда). Заводить ли шрифтовой
   ассет — отдельная воля (117 не вводит).
3. Анимация снятия splash: канон не описывает; 117 — нативный знак
   скрывается сразу после первого коммита с оверлеем (hideAsync), оверлей
   исчезает по таймеру 1200 мс без анимации. Нужна ли анимация (fade)?
4. `userInterfaceStyle: automatic` открывает системную тему для нативного
   выбора splash; JS-кадры остаются на ThemeContext (999). Верно ли, что
   тема приложения остаётся за контекстом 999?
5. Ключ каталога для «Versicherung. Erledigt.» отсутствует (meta copy-keys
   артборда пуст); текст живёт в растре композита. Заводить ли ключ
   (копия-синька CMP-MOB-089)?
6. Подпись поля входа: `TextField` продукта требует подпись, ключа подписи
   поля в каталоге нет; 117 ставит body-ключ кадра (frame.F03.01.body /
   frame.F03.02.body) — инструкцию к полю — вместо вымышленной копии
   (замер ревьюера В2-6: подпись F03.02 есть, низ ≈197 dp, поле ≈204 dp).
   Стиль подписи по README TextField (caption ink-muted с отступом пилюли
   20) требует `src/ui/text-field.tsx` (999) — форк `n117-r5-r7`.
   Рекомендуемый ответ: оставить так; иначе — ключ подписи поля в каталоге
   (копия-синька CMP-MOB-089) и отдельный body.
7. Скачок знака натив→оверлей (арбитраж круга 2, «К владельцу»):
   платформа центрирует нативный знак (центр экрана), оверлей кладёт знак
   на место артборда (центр y≈357 при окне 844) — расхождение ≈65 px в
   момент смены. Принять как свойство платформы? Рекомендация арбитра
   (действует по умолчанию до слова владельца): принять — альтернатива
   (сместить знак оверлея к центру) нарушает Splash.png.
8. Expo Go (пилотный стенд) показывает иконку приложения + JS-оверлей;
   нативный знак виден только в release/dev-client (свойство SDK 57,
   документация Expo). Принять? Рекомендация арбитра (действует по
   умолчанию): принять, свидетель — android-e2e release APK.
9. Подзаголовок First-Run «Ein Brief, ein Schaden, ein neues Auto – sagen
   Sie es. …» есть на First-Run.png/First-Run.html, но ключа каталога у
   него нет (meta copy-keys артборда — только promise и enter_f03;
   111 К5 закрыл копию двумя ключами). 117 v2 рендерит литерал артборда
   (source.json `first_run_117.subline`). Рекомендация: принять литерал
   артборда (слово (А) «полный состав как на PNG»), ключ — копия-синька
   CMP-MOB-089; иначе подзаголовок снимается из состава строкой владельца.
10. Зона implementer 117 v2 включает файлы frozen-семьи 999
   (`src/theme/tokens.ts`, `src/ui/button.tsx`) — только аддитивно:
   accent-text/ink-muted (без них ссылки light и подзаголовок/футер не
   выражаются токенами) и пропы size/block (без них CTA «во всю ширину,
   56» недостижим: обёртка Button `alignSelf: 'flex-start'`). Рекомендация:
   принять аддитивное расширение (батарея 999 зелёная на модели v2);
   иначе — предмет 999 v2 раньше 117, и CTA First-Run остаётся по контенту.
11. Demo-бейдж: на PNG его нет; 995 требует индикатор демо-режима; форк (А)
   — «подложка Demo видима». 117 v2: бейдж на First-Run вне потока (кадр не
   сдвигается), на кадрах D2.2.5.1 — чип DS (panel/ink схемы; на C подложка
   #F2F2F2 на #f3f2ee 1,0:1), на кадрах 995 — прежний вид. Рекомендация:
   принять; иначе — убрать бейдж с First-Run строкой владельца (995).
12. Светлого артборда First-Run нет: light First-Run — те же элементы на
   токенах light (ground #f3f2ee, ink #121211, ink-muted #5f5e58, CTA
   primary #121211 / on-primary #f3f2ee, знак splash-sign-light).
   Рекомендация: принять вывод токенами (как F03.01/F03.02).
