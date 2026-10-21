# Контракт 117 — mob: вход F03.01/F03.02 по D2.2.5.1 + НАШ нативный splash/иконка (CMP-MOB-006)

КЛАСС: КОДОВЫЙ. Предмет — слова владельца (через консультанта): (А) ~18:15
UTC «First-Run и экраны входа (F03.01/F03.02) по макету D2.2.5.1»; splash
~18:18 UTC «нативный splash (expo-splash-screen) и, ЕСЛИ НУЖНО, JS-экран
сразу после него совпадают со Splash.png» (иконка = complior-app-icon,
тёмный И светлый); ~19:28 UTC вход F03.01/F03.02 — по токенам и
компонентам D2.2.5.1 и составу UX-JSON F01/F03, PNG-макета нет. Конструкция
splash (арбитраж круга 2, РЕШЕНИЕ): нативный = ОДИН знак канона на ground
схемы; кадр Splash.png целиком несёт JS-ОВЕРЛЕЙ сразу после натива (слово
18:18 «если нужно» — нужно: замер арбитра — платформа вписывает картинку
плагина в imageWidth×imageWidth, масштаб нативного композита «на весь
кадр» = 0.46, это другой кадр, не Splash.png). JS-КАДР state-machine —
вне предмета. ПРАВИЛО (В): PNG-макет каждого кадра назван, takeScreenshot
каждого кадра в приёмке, ревьюер сверяет скриншот ↔ макет. База B =
`a3ka/Complior-mob` main `8748a7a3352c14a6caa5a75b71f869e5d3b8152c` (после 111).

КОНТЕКСТ: слова владельца через консультанта — (А) 18:15 UTC «First-Run и
экраны входа (F03.01/F03.02) по макету D2.2.5.1: полный состав и раскладка
как на PNG»; splash ~18:18 UTC (НАШ splash: иконка = complior-app-icon,
нативный splash тёмный И светлый); ПРАВИЛО (В) ~18:00 UTC (сверка с макетом);
~19:28 UTC вход по токенам/компонентам D2.2.5.1 и UX-JSON F01/F03.
КОНТЕКСТ: `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/` — растры
`screens/Splash{,-Hell}.png` (артборды 390×844), семья `logo/assets/`,
`design-system/project/` (tokens.css, components/Button, components/TextField).
КОНТЕКСТ: `docs/ux/01_UX_Source_of_Truth/Complior_F01_F03_Invitation_Entry_1_17_8_1.json`
(состав входа) и каталог `BrokerOS_UI_Copy_DE.json` (тексты по ключам).
КОНТЕКСТ: `contracts/111-cmp-mob-first-run.md` + батарея
`fixtures/workshop_project/first_run_111/` (done) — механика probe_lib и
уроки (Н-386 свойство↔выборка, литералы Н-379/Н-383, RNTL 14.1 await);
frozen-семьи 995/999/111 не переписываются.

## Источники

- Слова владельца: (А) 18:15 UTC; splash 18:18 UTC; ПРАВИЛО (В) ~18:00 UTC
  (коммит консультанта `f1e3c1c3`, РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле).
- «F03.01/F03.02 — по токенам и компонентам D2.2.5.1 и UX-JSON F01/F03, PNG-макета нет (слово владельца 2026-10-20 ~19:28 UTC)».
- Макеты splash (read-only B): `screens/Splash.png` (тёмный) и
  `screens/Splash-Hell.png` (светлый) — артборды 390×844, замер Architect117c
  пиксельным проходом (обе схемы совпадают): видимый знак x109..289
  y271..443, wordmark x157..232 y514..533, tagline «Versicherung. Erledigt.»
  x57..332 y569..595; фон #0A0A0A / #F3F2EE.
- Иконка: `logo/assets/complior-app-icon.svg` (1024, rx232, фон #0a0a0a,
  дуга stroke #f2f1ec w12, точка #d6f75a cx76 cy66 r11 во viewBox 96).
- Вход: `design-system/project/tokens.css` (.title 28/32/500, .body
  17/24/400, .label-lg 17/24/500, .body-sm 15/20/400, --size-lg 56,
  пилюля), `components/Button/README.md` (primary — одна на экран, size-lg
  56 во всю ширину, перекраска inline запрещена), `components/TextField/
  README.md` (пилюля size-lg на panel без рамки); UX-JSON F01/F03 1.17.8.1
  (DIRECT: F03.01 → F03.A01/F03.02; `routing.code_entry`); каталог
  `BrokerOS_UI_Copy_DE.json` (ключи — таблица «Состав кадров входа»).
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
- Предшественник: контракт 111 (done) — First-Run dark по D2.2.5.1.

## Таблица «кадр макета → что есть на B → что делает 117»

| Кадр (макет) | Есть на B (8748a7a335) | Делает 117 |
| --- | --- | --- |
| First-Run.png | закрыт 111 (dark, RESTYLE_GUARD_995) | НЕ трогает; первый кадр оболочки остаётся first-run (оверлей — sibling поверх дерева, НЕ кадр state-machine: Frame не расширяется) |
| Splash.png (тёмный) — знак | splash-icon.png — шаблон Expo 76×76 на #0A0A0A | нативный splash: ОДИН знак `splash-sign-dark.png` (ink #f2f1ec + точка #d6f75a), `dark.backgroundColor` #0A0A0A, imageWidth 181 (ширина знака артборда — литерал), resizeMode contain |
| Splash.png (тёмный) — кадр целиком | полного кадра нет | JS-ОВЕРЛЕЙ `splash-composite-dark.png` (кадр окна 390×844: знак+wordmark+tagline на местах артборда) поверх дерева оболочки |
| Splash-Hell.png (светлый) | светлого splash нет | корень плагина: знак `splash-sign-light.png` (ink #121211 + точка), backgroundColor #F3F2EE, композит light в оверлее; userInterfaceStyle automatic |
| Иконка (complior-app-icon.svg) | icon/adaptive/favicon — шаблон Expo (#E6F4FE) | все производные — растр канона; adaptive фон #0A0A0A |
| F03.01 «Anmelden oder Konto erstellen» | кадр 995: белый корень 48/16/16, title 22/600 #111111, ручные TextInput/Pressable | PNG-макета нет (слово ~19:28): состав по UX-JSON + каталогу на компонентах продукта `@/ui/button`, `@/ui/text-field` (DS на токенах D2.2.5.1), токены схемы |
| F03.02 «Kontakt bestätigen» | кадр 995 | то же; поле auth-code, кнопка auth-verify, три ссылки accent |
| F03.04, unavailable, welcome | поверхность 995 | ВНЕ предмета: белый корень 48/16/16 (гварды Г1–Г3) |

## Существующее

- `mobile/src/bootstrap/pilot-app.tsx` (8748a7a335): первый кадр first-run →
  FirstRunScreen 111; корень 995-кадров 48/16/16 #FFFFFF (frozen 111/1);
  demo-бейдж ниже top-инсета (111 r5). 117 меняет ТОЛЬКО корень кадров
  email/code (full-bleed ground); вход шва и первый кадр не меняются.
- `mobile/src/features/auth/auth-screen.tsx`: COPY-литералы 995 (заголовки
  каталога verbatim), testID auth-email/auth-code/auth-verify/auth-resend/
  auth-change-email/auth-no-access/auth-demo-entry, стили до-D2.2.5.1.
- `mobile/app.json`: expo-splash-screen backgroundColor #0A0A0A (111),
  image splash-icon.png (ШАБЛОН Expo), imageWidth 76; adaptiveIcon
  #E6F4FE; userInterfaceStyle "light"; ios.icon "./assets/expo.icon";
  expo-splash-screen ~57.0.10 — резолверы prebuild поддерживают вложенный
  `dark`-блок (getAndroidSplashConfig.js:7–26 объединяет rest.dark/android.dark).
- `mobile/src/theme/tokens.ts` (999, frozen): dark ground #0a0a0a/ink
  #f2f1ec/panel #1e1e1d/primary #d6f75a/on-primary #121211; light ground
  #f3f2ee/ink #121211/panel #e6e5df/primary #121211/on-primary #f3f2ee;
  accent #d6f75a. ThemeContext — пара (scheme, tokens).
- `mobile/src/ui/button.tsx` и `mobile/src/ui/text-field.tsx` (CMP-MOB-002,
  «на токенах D2.2.5.1»): Button — пилюля (радиус 999), primary =
  primary/on-primary схемы; TextField — подпись caption ink над полем-пилюлей
  на panel, ввод ink, проп `label` обязателен. Это реальные компоненты DS в
  продукте (First-Run 111 уже рендерит Button); структурная политика
  продукта держит общий UI в слое `src/ui` (`check-structure.cjs` отвергает
  иные каталоги). 117 их ПОТРЕБЛЯЕТ и не меняет.
- 111 (заморожено): рестайл кадров 995 вне first-run запрещён frozen 111/1 —
  117 СНИМАЕТ запрет ровно для F03.01/F03.02 словами владельца (А)/~19:28;
  welcome, recovery F03.04, unavailable остаются поверхностью 995.
- `mobile/.maestro/start.yaml`: assertVisible first-run-continue — сценарии
  живы (оверлей — pointerEvents none, не кадр state-machine, дерево под ним
  достижимо: замер арбитра RNTL + Maestro-семантика иерархии).

## Предмет и граница

Один результат: холодный старт показывает НАШ splash — нативный знак
канона на ground схемы (release/dev-client; Expo Go показывает иконку
приложения + JS-оверлей — свойство SDK 57, документация Expo), затем
JS-ОВЕРЛЕЙ кадра Splash.png/Splash-Hell.png по всей поверхности поверх
дерева оболочки (скрывается таймером), затем — First-Run 111; сверка
«скриншот ↔ Splash.png» — android-e2e на release APK (Expo Go не
показывает картинку плагина — не свидетель). Экраны входа F03.01/F03.02 —
полный состав по UX-JSON F01/F03 и каталогу, собранный из компонентов
Button/TextField дизайн-системы D2.2.5.1 на токенах схемы (testID и
переходы 995 сохранены).

Вне предмета: JS-КАДР splash (state-machine — оверлей НЕ расширяет
Frame, `frame` стартует с 'first-run' как на B); First-Run 111; кадры
welcome, F03.04, unavailable (поверхность 995); связка First-Run → вход →
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
   on-primary); ссылки — ЭФФЕКТИВНЫЙ цвет accent #d6f75a; модуль кадров
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
   state-machine; `pilot.test` 995 и first_run_111 на модели с оверлеем —
   14/14 и 17/19 (красны ровно К8 — см. «Миграция гварда 111»).

## Состав кадров входа (UX-JSON F01/F03 + каталог, литералы)

| Экран | Элемент (testID/роль) | Компонент продукта (DS) | Ключ каталога → текст |
| --- | --- | --- | --- |
| F03.01 | заголовок (role header) | Text .title, ink | `frame.F03.01.title` → «Anmelden oder Konto erstellen» |
| F03.01 | `auth-email` + подпись | `TextField` (`@/ui/text-field`), panel/ink | подпись `frame.F03.01.body` → «Nutzen Sie den angebotenen Anmeldeweg, um auf Ihre Versicherungen zuzugreifen.» |
| F03.01 | `auth-demo-entry` | `Button` primary (`@/ui/button`) | `ui.auth.demo_entry` → «Demo mit Beispieldaten ansehen» |
| F03.02 | заголовок (role header) | Text .title, ink | `frame.F03.02.title` → «Kontakt bestätigen» |
| F03.02 | `auth-code` + подпись | `TextField`, panel/ink, secureTextEntry | подпись `frame.F03.02.body` → «Geben Sie den zugesandten Code ein. Prüfen Sie bei Bedarf Ihre Kontaktdaten.» |
| F03.02 | `auth-verify` | `Button` primary | `action.F03.A01` → «Anmelden» |
| F03.02 | `auth-resend` | ссылка, accent | `ui.auth.code_resend` → «Code erneut senden» |
| F03.02 | `auth-change-email` | ссылка, accent | `auth.change_email` (COPY 995) → «E-Mail ändern» |
| F03.02 | `auth-no-access` | ссылка, accent | `action.F03.A02` → «Zugang wiederherstellen» |

Ключа подписи поля в каталоге нет, копия не выдумывается: обязательную
подпись `TextField` несёт body-ключ кадра — он и есть инструкция к полю
(вопрос владельцу №6). Поведенческие состояния 995 (auth-invalid,
auth-cooldown, resend-sent, demo-indicator) сохраняются как на B и в
состав рестайла не входят.

## Проверяемый шов

`mobile/app.json` (плагин: знаки splash-sign-{dark,light}.png; композиты
оверлея `mobile/assets/images/splash-composite-{dark,light}.png`;
производные иконки); `mobile/src/bootstrap/pilot-app.tsx` (корень кадров
email/code + JS-оверлей splash); `mobile/src/features/auth/auth-screen.tsx`
(EmailFrame/CodeFrame на `@/ui/button`, `@/ui/text-field`); сценарий
Maestro 117 в `mobile/.maestro/` (после freeze — implementer). Ожидания
проб — литералы source.json (сняты с read-only docs/ B ДО субъекта,
правило 8/Н-351); ни одна клетка не читает значения у субъекта; эталоны
артбордов припинены sha256 (несовпадение — rc2 ORACLE_TAMPERED).

## Закрытые перечни клеток (числа из кода проб, замерены прогонами круга 5)

Поведенческая семья (Jest/RNTL, `vkhod_probe.py` → `vkhod.test.tsx`,
22 клетки — прогон круга 5):
- В1 `AUTH_F03_01_STRUCTURE_{DARK,LIGHT}` ×2 — ВСЕ элементы F03.01 из
  таблицы состава: заголовок (.title, ink), подпись поля (body-ключ, ink),
  auth-email (пилюля ≥ 28, panel, ввод ink), auth-demo-entry (пилюля ≥ 28,
  заливка primary, подпись текстом каталога on-primary), корень ground.
- В2 `AUTH_F03_02_STRUCTURE_{DARK,LIGHT}` ×2 — ВСЕ элементы F03.02: заголовок,
  подпись поля (body-ключ, ink), auth-code (пилюля, panel, ink), auth-verify
  (пилюля, primary, подпись on-primary), три ссылки эффективным accent
  #d6f75a, корень ground.
- В3 `AUTH_FRAMES_IN_WINDOW_{DARK,LIGHT}` ×2 — ПЕРВАЯ ЛИНИЯ по
  эффективному стилю (НЕ доказательство: layout в Jest не вычисляется):
  кумулятивный translate корень→лист < окна; чужие типы трансформаций;
  поля бокса (margin*/padding*/left/top/right/bottom) ≥ окна;
  display:'none'; opacity 0 — красны. Доказательство «кадр в окне» —
  Maestro assertVisible (Б3, приёмка).
- Г1 `RESTYLE_GUARD_995_WELCOME_{DARK,LIGHT}` ×2, Г2
  `RESTYLE_GUARD_995_RECOVERY_{DARK,LIGHT}` ×2, Г3
  `RESTYLE_GUARD_995_UNAVAILABLE_{DARK,LIGHT}` ×2 — #FFFFFF и 48/16/16.
- С2-оверлей: `SPLASH_OVERLAY_MOUNTED_{DARK,LIGHT}` ×2 (testID
  splash-overlay, pointerEvents none, absoluteFill, фон ground, Image
  внутри); `SPLASH_OVERLAY_COMPOSITE_{DARK,LIGHT}` ×2 (С2-а: в поддереве
  оверлея РОВНО один Image, эффективный `source` — модуль файла
  `mobile/assets/images/splash-composite-<схема>.png`; jest-expo
  превращает любой PNG в `1`, поэтому оба файла композита подменены в
  тесте уникальными сентинелями `jest.mock(…, {virtual: true})` по пути
  от файла теста, сравнение по ссылке; `resizeMode contain`, absoluteFill,
  не скрыт); `SPLASH_OVERLAY_NO_TEXT_{DARK,LIGHT}` ×2 (в поддереве
  оверлея нет Text-узлов); `SPLASH_HIDEASYNC_ORDER_{DARK,LIGHT}` ×2
  (С2-б: commit-журнал — мок пишет prevent/hide, React.Profiler onRender
  пишет commit с наличием оверлея в контейнере `test-renderer`
  `createRoot` в момент commit; требование: первый commit несёт оверлей,
  hide ровно один и ПОСЛЕ него, prevent раньше первого commit; журнал
  модели `["commit+overlay","hide"]` после модульного prevent);
  `SPLASH_OVERLAY_TIMER_HIDE_{DARK,LIGHT}` ×2 (fake timers: до 1199 мс
  на месте, на 1200-й скрыт).

Статическая семья (`vkhod_static_probe.py`, 35 клеток — прогон круга 5):
APP_ICON_DERIVATIVES, ICON_NOT_TEMPLATE_BYTES, ICON_ADAPTIVE_BG_DARK,
ICON_PIXELS_MARK, SPLASH_BLOCKS_DARK_LIGHT (знаки, imageWidth 181,
contain), SPLASH_EFFECTIVE_DARK_LIGHT (эффективные ФОНЫ резолверами),
SPLASH_NATIVE_GENERATED_{LIGHT,DARK}_{MDPI,HDPI,XHDPI,XXHDPI,XXXHDPI}
×10 + сводная SPLASH_NATIVE_GENERATED (Б2: настоящие getAndroidSplashConfig
+ setSplashImageDrawablesAsync; dims 288×m, содержимое = знак аналитикой
splash_sign, размер знака imageWidth×m ±3), SPLASH_EFFECTIVE_IOS_{LIGHT,DARK}
×2 (содержимое по эффективному пути + эффективные imageWidth/resizeMode),
SPLASH_IOS_STORYBOARD (Б2: ключа `enableFullScreenImage_legacy` нет в
props плагина, эффективно false; настоящие getIosSplashConfig +
applySplashScreenStoryboard: рамка картинки 181×181, constraints ровно
centerX/centerY), SPLASH_COMPOSITE_ETALON_{DARK,LIGHT} ×2 (Б1: размер =
артборд 390×844, recall по ВСЕЙ маске M, precision по ВСЕМ непрозрачным
C, ≥ 0.98), SPLASH_SIGN_RASTER_{DARK,LIGHT} ×2 (растр знака аналитикой),
SPLASH_OVERLAY_CONSUMES_COMPOSITE (С2-а: require в pilot-app.tsx
относительным путём разрешается в оба файла композита, судимых
эталоном), USER_STYLE_AUTOMATIC, AUTH_FRAMES_TOKENIZED,
AUTH_DS_COMPONENTS (инвариант 6: импорт `@/ui/button`/`@/ui/text-field`
и рендер в обоих сегментах), STATIC_ORACLE_LITERALS, ICON_RASTER_WHOLE,
ADAPTIVE_FG_RASTER, ADAPTIVE_MONO_RASTER, ADAPTIVE_BG_SOLID,
FAVICON_RASTER_WHOLE, IOS_ICON_NOT_TEMPLATE.

Обманные стабы (привязка к ветвям — ТОЛЬКО по коду MUTANTS проб, Н-39;
depends измерены полным прогоном круга 5): поведенческих 20 (auth-stays-995,
auth-light-dark-ground, auth-title-995-typo, verify-button-995-black,
restyle-welcome-vkhod, restyle-recovery-vkhod, restyle-unavailable-vkhod,
restyle-recovery-light-vkhod, auth-frame-offscreen, auth-links-ground,
auth-body-missing, auth-field-hand-styled, auth-button-inline,
overlay-absent-first-commit, overlay-text-words, overlay-hideasync-skip,
overlay-hideasync-module-scope, overlay-timer-none, overlay-wrong-source,
overlay-hide-before-commit), статических 20 (icon-template-bytes,
adaptive-expo-blue, splash-image-forgery, icon-twin-three-pixels,
splash-composite-twin, splash-composite-no-words, splash-composite-shifted,
splash-composite-halfres, splash-imagewidth-76, adaptive-favicon-template,
platform-image-template-override, platform-same-basename,
platform-density-template, splash-dark-block-missing, splash-light-missing,
user-style-light-stays, auth-hex-literal, auth-buttons-inline, ios-legacy,
overlay-wrong-source); свидетели круга 3 критика: halfres-{dark,light} →
splash-composite-halfres, ios-legacy → ios-legacy, overlay-wrong-source →
overlay-wrong-source (обе семьи), overlay-hide-before-commit →
overlay-hide-before-commit; каждый красен именованной клеткой, побочная
краснота только в depends; якорь мутанта неуникален → отказ rc2;
сломанный мутантом свит → MUTANT_SUITE_BROKEN rc2 (не зелень).

## Приёмочный критерий

R — disposable копия Complior-mob на B под /tmp/dev-harness-verify с
node_modules в mobile/ (симлинк); пробы — Python 3 stdlib.

- Дано B без реализации: `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py
  --repo R` → rc1 `VKHOD_AUTH_DS_ABSENT` (кадры входа не на `@/ui`);
  `vkhod_static_probe.py --repo R` → rc1 `VKHOD_SPLASH_COMPOSITE_ABSENT`.
- Дано B с эталонной моделью (`--model`) либо честное C: обе пробы → rc0 с
  перечнем: поведенческая 22/22, статическая 35/35 (замер круга 5).
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный, каждый
  стаб красен именованной ветвью (20+20), побочная краснота только в depends.
- Дано C; `git status --short --untracked-files=all` в R после проб — 0 строк
  кроме симлинка `mobile/node_modules` (инфраструктура R, не проба).
- Дано C; `npm run lint`, `npm run typecheck` в R/mobile → rc0;
  `npx jest src/bootstrap/__tests__/pilot.test.tsx` (995, byte-frozen) → rc0,
  14/14 (оверлей — sibling поверх дерева, вход шва не меняется; замер на
  модели круга 4). Батарея `fixtures/workshop_project/first_run_111/` на C:
  RUN, ожидаемо rc1 — 17/19, красны ровно К8
  `RESTYLE_GUARD_995_F03_01_{DARK,LIGHT}` до 111 v2 (замер на модели круга 4;
  раздел «Миграция гварда 111»), зелёным НЕ заявляется.
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0;
  android-e2e (release APK: `expo prebuild` + `assembleRelease`, Maestro)
  исполняет сценарий 117 в `mobile/.maestro/`: `assertVisible` КАЖДОГО
  элемента таблицы «Состав кадров входа» (F03.01: заголовок, auth-email,
  auth-demo-entry; F03.02: заголовок, auth-code, auth-verify, auth-resend,
  auth-change-email, auth-no-access) × тема устройства — это доказательство
  Б3 «кадр в окне» (Maestro возвращает rc≠0 при невидимости); takeScreenshot
  КАЖДОГО кадра по правилу (В): splash × {тёмная, светлая} — сверка с
  Splash.png / Splash-Hell.png; F03.01 × {dark, light}, F03.02 × {dark,
  light} — сверка с компонентами/токенами D2.2.5.1 и составом таблицы
  (6 скриншотов; First-Run снимает 111-сценарий); скриншоты в артефактах
  прогона, ревьюер сверяет глазами и мерой.
- Дано авторская пачка; `bash scripts/pre_critic.sh
  contracts/117-cmp-mob-vkhod-splash.md` → rc0.

## Миграция гварда 111 (БЕЗ правок 111 в этой пачке)

Единственный конфликт с замороженным: `fixtures/workshop_project/
first_run_111/first_run.test.tsx` К8 `RESTYLE_GUARD_995_F03_01_{DARK,LIGHT}`
(строки ≈320–330: после CTA корень F03.01 обязан быть #FFFFFF 48/16/16) —
противоречит рестайлу F03.01/F03.02 словами владельца (А)/~19:28. Путь —
ответ консультанта 19:20 «(А) 111 v2 сужает гвард RESTYLE_GUARD_995»: текст
111 v2 и строка РАЗРЕШИЛ — отдельная работа (Architect111v2), не этой пачки.
До 111 v2 шаг приёмки first_run_111 — RUN, ожидаемо rc1 ровно по К8
(17/19, замер круга 4); после 111 v2 — зелёный в мигрированной форме.
Вход шва и `pilot.test.tsx` 995 миграции не требуют (оверлей — sibling
поверх дерева, не кадр state-machine; замер круга 4: 14/14).

## Зоны и исполнители

ЗОНА architect: contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Пути implementer отсчитываются от корня Complior-mob:

ЗОНА implementer: mobile/app.json mobile/assets/images/ (icon.png, splash-composite-dark.png, splash-composite-light.png, splash-sign-dark.png, splash-sign-light.png, android-icon-foreground.png, android-icon-background.png, android-icon-monochrome.png, favicon.png) mobile/src/bootstrap/pilot-app.tsx mobile/src/features/auth/auth-screen.tsx .github/workflows/mobile.yml mobile/.maestro/

ПЕРЕСЕЧЕНИЕ: `mobile/src/bootstrap/pilot-app.tsx` и
`mobile/src/features/auth/auth-screen.tsx` — общие с замороженными семьями
995/111: в pilot-app меняется только корень кадров email/code и ДОБАВЛЯЕТСЯ
JS-оверлей splash (последний ребёнок корня, НЕ кадр state-machine); первый
кадр и вход шва — как на B. `mobile/src/ui/` (компоненты CMP-MOB-002, 999),
`mobile/src/bootstrap/__tests__/` (995), `docs/`, `design/` — read-only для
117. Знаки и композиты выводятся из read-only `screens/Splash{,-Hell}.png`
(артборд не меняется). Действующие Maestro-сценарии лежат в `mobile/.maestro/`
(совет критика, подтверждён арбитражем), сценарий 117 — туда же.

РАБОТА НЕ РАЗДАЁТСЯ: implementer не спавнится до accept критика и freeze
оркестратора; предмет этой пачки — контракт + красные пробы, предъявленные
красными на B и зелёными на эталоне.

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
  primary/on-primary/panel в обеих схемах; ссылки — эффективным accent;
- от дешёвых обходов «кадр в окне» (первая линия): В3 — кумулятивный
  translate, поля бокса ≥ окна, display none, opacity 0 (стабы
  translateX-1000 и marginLeft-1000 красны, замер круга 4);
- от тихого рестайла соседних кадров: Г1–Г3 по ВСЕМ исключённым кадрам ×
  схемы;
- от зависимого оракула (Н-351): ожидания — литералы source.json/теста,
  STATIC_ORACLE_LITERALS; эталоны — sha-пин read-only docs/;
- от мёртвой матрицы: обе пробы исполняют все стабы (20+20), depends
  измерены прогоном, unexpected_red/suite_broken — rc2.

НЕ ЗАЩИЩАЕТ:
- layout в Jest не вычисляется (yoga в node_modules продукта нет — замер
  арбитра): В3 — только первая линия по эффективному стилю; окно — только
  android-e2e (Maestro assertVisible, release APK); ловец — CI android-e2e;
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
Splash-Hell.png; иконка — complior-app-icon.svg; F03.01/F03.02 — PNG нет,
слово владельца ~19:28: компоненты/токены D2.2.5.1 + таблица состава),
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
   frame.F03.02.body) — инструкцию к полю — вместо вымышленной копии.
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
