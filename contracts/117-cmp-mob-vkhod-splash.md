# Контракт 117 — mob: НАШ splash (нативный знак + JS-оверлей, обе схемы) + иконка (CMP-MOB-006)

ВЕРСИЯ: v3 (миграция 117/3 — слово владельца 2026-10-24 ~10:15 UTC «а» по
форку n118-migraciya-117; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ — в теле изменяющего
коммита). Дельта к v2 — ТОЛЬКО раздел «Миграция 117 v3» и свод
«Закрытых перечней клеток» с деревом; всё прочее v2 действует дословно.

КЛАСС: КОДОВЫЙ. Предмет — слова владельца (через консультанта): splash
~18:18 UTC «нативный splash (expo-splash-screen) и, ЕСЛИ НУЖНО, JS-экран
сразу после него совпадают со Splash.png» (иконка = complior-app-icon,
тёмный И светлый); сужение 2026-10-21 ~13:05 и ~14:10 UTC: 117 = splash
(нативный + оверлей, обе схемы) + иконка. Конструкция splash (арбитраж
круга 2, РЕШЕНИЕ): нативный = ОДИН знак канона на ground схемы; кадр
Splash.png целиком несёт JS-ОВЕРЛЕЙ сразу после натива (слово 18:18
«если нужно» — нужно: замер арбитра — платформа вписывает картинку
плагина в imageWidth×imageWidth, масштаб нативного композита «на весь
кадр» = 0.46, это другой кадр, не Splash.png). JS-КАДР state-machine —
вне предмета. ПРАВИЛО (В): PNG-макет каждого кадра назван, takeScreenshot
каждого кадра в приёмке, ревьюер сверяет скриншот ↔ макет. База B =
`a3ka/Complior-mob` main `8748a7a3352c14a6caa5a75b71f869e5d3b8152c` (после 111).

Выведено из 117: вход F03.01/F03.02 (формы email/code, ссылки accent,
подпись поля, `auth-screen.tsx` как судимый экран) и First-Run → предмет
`first-run-ekran` (новая схема экранов, сверка кадров с PNG: эталон
F03.01/F03.02/F03.02-V01 — Complior-mob#118, `docs/ux/03_Mobility_Slice1`,
кадры A04/A05/A05e). Причина — слово владельца 2026-10-21 ~13:05 и ~14:10
UTC, `docs/owner/2026-10-21-117-suzhenie.md`: реализация входа по
токенам/UX-JSON расходится с присланным эталоном; правка контраста ссылок
F03 (вариант «А», 13:45) не делается.

КОНТЕКСТ: `docs/owner/2026-10-21-117-suzhenie.md` (слово владельца о
сужении); ПРАВИЛО (В) ~18:00 UTC (сверка с макетом).
КОНТЕКСТ: `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/` — растры
`screens/Splash{,-Hell}.png` (артборды 390×844), семья `logo/assets/`.
КОНТЕКСТ: `contracts/111-cmp-mob-first-run.md` + батарея
`fixtures/workshop_project/first_run_111/` (done) — механика probe_lib и
уроки (Н-386 свойство↔выборка, литералы Н-379/Н-383, RNTL 14.1 await);
frozen-семьи 995/999/111 не переписываются.

## Источники

- Слова владельца: splash 18:18 UTC; ПРАВИЛО (В) ~18:00 UTC (коммит
  консультанта `f1e3c1c3`, РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле); сужение 2026-10-21
  ~13:05 и ~14:10 UTC (`docs/owner/2026-10-21-117-suzhenie.md`).
- Макеты splash (read-only B): `screens/Splash.png` (тёмный) и
  `screens/Splash-Hell.png` (светлый) — артборды 390×844, замер Architect117c
  пиксельным проходом (обе схемы совпадают): видимый знак x109..289
  y271..443, wordmark x157..232 y514..533, tagline «Versicherung. Erledigt.»
  x57..332 y569..595; фон #0A0A0A / #F3F2EE.
- Иконка: `logo/assets/complior-app-icon.svg` (1024, rx232, фон #0a0a0a,
  дуга stroke #f2f1ec w12, точка #d6f75a cx76 cy66 r11 во viewBox 96).
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
| Splash-Hell.png (светлый) | светлого splash нет | корень плагина: знак `splash-sign-light.png` (ink #121211 + точка), backgroundColor #F3F2EE, композит light в оверлее; userInterfaceStyle automatic; тема ОС проводится в PilotApp (оверлей светлый при ОС light), стиль статус-бара контрастен ground схемы |
| Иконка (complior-app-icon.svg) | icon/adaptive/favicon — шаблон Expo (#E6F4FE) | все производные — растр канона; adaptive фон #0A0A0A |
| F03.01, F03.02, F03.04, unavailable, welcome | поверхность 995 | ВНЕ предмета: белый корень 48/16/16 как на B (гварды Г0–Г3); вход F03 — предмет `first-run-ekran` |

## Существующее

- `mobile/src/bootstrap/pilot-app.tsx` (8748a7a335): первый кадр first-run →
  FirstRunScreen 111; корень 995-кадров 48/16/16 #FFFFFF (frozen 111/1);
  demo-бейдж ниже top-инсета (111 r5). 117 ДОБАВЛЯЕТ JS-оверлей splash,
  провод темы ОС и StatusBar; корни кадров, вход шва и первый кадр не
  меняются.
- `mobile/src/features/auth/auth-screen.tsx`: поверхность 995 входа
  (testID auth-email/auth-code/auth-verify/auth-resend/auth-change-email/
  auth-no-access/auth-demo-entry) — 117 её не меняет (итог C ≡ B).
- `mobile/app.json`: expo-splash-screen backgroundColor #0A0A0A (111),
  image splash-icon.png (ШАБЛОН Expo), imageWidth 76; adaptiveIcon
  #E6F4FE; userInterfaceStyle "light"; ios.icon "./assets/expo.icon";
  expo-splash-screen ~57.0.10 — резолверы prebuild поддерживают вложенный
  `dark`-блок (getAndroidSplashConfig.js:7–26 объединяет rest.dark/android.dark).
- `mobile/src/theme/tokens.ts` (999, frozen): dark ground #0a0a0a/ink
  #f2f1ec; light ground #f3f2ee/ink #121211; accent #d6f75a. ThemeContext —
  пара (scheme, tokens), умолчание контекста dark.
- 111 (заморожено): рестайл кадров 995 вне first-run запрещён frozen 111/1;
  К8 батареи 111 `RESTYLE_GUARD_995_F03_01_{DARK,LIGHT}` держит корень F03.01
  #FFFFFF 48/16/16 — 117 v2 с ним согласна (миграции гварда нет).
- `mobile/.maestro/start.yaml`: assertVisible first-run-continue — сценарии
  живы (оверлей — pointerEvents none, не кадр state-machine, дерево под ним
  достижимо: замер арбитра RNTL + Maestro-семантика иерархии).
- Контракт 123 (frozen v1, реализация `scripts/sverka_maketa.py` принята
  ревьюером в `wip/123/implementer`): сверка кадра e2e с PNG-макетом —
  манифест H `fixtures/workshop_project/mob_sverka_123/kadry_117.json`
  объявляет «Splash dark»/«Splash light»: снимок `vkhod-117-splash`, тема,
  макет Splash.png/Splash-Hell.png с теми же sha256, что эталон Б1 117,
  порог 0.6. Текст шага сверки в android-e2e — предмет 123 (frozen 123
  п.5–6; написан implementer 123 на `cmp-mob-123/sverka` @10cf684,
  `mobile.yml:367–378`, не влит); 117 его не пишет, а наблюдает клетками
  SVERKA_123_* (РЕШЕНИЕ арбитра `contracts-117-v2-svjaz-123`, (б)).
  Прецедент чтения workflow продукта батареей харнесса —
  `fixtures/workshop_project/pilot_995/pins_probe.py` `check_release_mode`.

## Предмет и граница

Один результат: холодный старт показывает НАШ splash — нативный знак
канона на ground схемы (release/dev-client; Expo Go показывает иконку
приложения + JS-оверлей — свойство SDK 57, документация Expo), затем
JS-ОВЕРЛЕЙ кадра Splash.png/Splash-Hell.png по всей поверхности поверх
дерева оболочки (скрывается таймером), затем — First-Run 111; иконка
приложения и её производные — растр канона complior-app-icon. Сверка
«скриншот ↔ Splash.png» — android-e2e на release APK (Expo Go не
показывает картинку плагина — не свидетель).

Вне предмета: вход F03.01/F03.02 и First-Run (предмет `first-run-ekran`);
JS-КАДР splash (state-machine — оверлей НЕ расширяет Frame, `frame`
стартует с 'first-run' как на B); кадры welcome, F03.04, unavailable
(поверхность 995); связка First-Run → вход → Erstinformation → Start
(предмет 118); 116; копия-синька CMP-MOB-089; device evidence CMP-MOB-090;
реальный IdP/бэкенд; анимация splash; шрифтовой ассет DM Sans.

## Миграция 117 v3 (узкая санкция: демо-маршрут pilot-app для 118)

Слово владельца 2026-10-24 ~10:15 UTC «а» по форку n118-migraciya-117.
ЕДИНСТВЕННОЕ разрешённое изменение предмета v2: production
`mobile/src/bootstrap/pilot-app.tsx` ДОПУСКАЕТ маршрут
First-Run → demo → Erstinformation → Start (с вкладками) — ТОЛЬКО при
доказанном допуске: admission 'W1A' ИЗ СЕССИИ пользователя (источник
внешний по отношению к pilot-app; литерал допуска в pilot-app запрещён)
∧ gate 'current' (полный CURRENT_CONFIRMED-снимок 107: применимость
REQUIRED, точная версия документа, evidence; ВТОРОЙ gate не вводится —
источник допуска один, 107/118).

Без admission ИЛИ без current — прежний путь B: демо-вход ведёт в кадр
code (F03.02) прежней семантикой auth.begin; вход F03.01 (email) после
First-Run — без изменений; корни кадров F03.01/F03.02 остаются
поверхностью 995: #FFFFFF, отступы 48/16/16 в ОБЕИХ схемах (клетки Г0
`RESTYLE_GUARD_995_F03_{DARK,LIGHT}`).

Порядок маршрута: Start возникает ТОЛЬКО продолжением (continue) из
Erstinformation; Erstinformation — ТОЛЬКО демо-входом при допуске.
Пространство кадров pilot-app расширяется ТОЛЬКО кадрами
'erstinformation' и 'start'; стартовое значение frame — 'first-run'
как на B; JS-оверлей splash — по-прежнему НЕ кадр state-machine.

Состав экранов Erstinformation (кадры F02.03/F02.08 по макетам) и Start
(вкладки, testID приёмки 118) — предмет 118; 117 v3 судит в pilot-app
только допуск, порядок и сохранность прежнего пути. Шов клеток миграции
— порты PilotApp (onboarding: admission/gate; оси W0/W1A ×
null/stale/current — язык замороженной приёмки 118); production-источник
допуска — сессия (проба композиции с внешним источником — инвариант 5
frozen 118/1, зона implementer 118).

Охрана — клетки-дельта MIGRACIYA_* (перечень — «Закрытые перечни
клеток») и стабы migracija-admission-literal («admission обходится»),
migracija-gate-ignor, migracija-start-pryamo (порядок),
migracija-f03-put-udalen («Г0 ослаблен»: прежний путь удалён миграцией).

НЕ разрешено: ослабление приёмки 118; рестайл корня F03; изменение входа
(итог C ≡ B по `mobile/src/features/auth/` — приёмка v2); ослабление
инвариантов 1–9 v2 и их клеток; правка pilot-app ДО заморозки 117/3
(команда проверки тега — frozen 118 §Зависимость замороженного корня:
`git fetch origin --tags && git rev-parse --quiet --verify
refs/tags/frozen/contracts/117/3`). ЗОНА implementer 118 получает
`mobile/src/bootstrap/pilot-app.tsx` ПОСЛЕ замороженной 117/3; батарея
117 (обе пробы) на мигрировавшем C обязана оставаться зелёной во всех
клетках, стабы — красными на своих ветвях.

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
   каталоге нет), живёт ТОЛЬКО в растре композита.
6. Тема и статус-бар splash: на production-входе (`@/app/index`, без
   провайдера выше PilotApp) схема берётся из ОС (Appearance) — оверлей
   ОС light на ground #f3f2ee, ОС dark на #0a0a0a; явный провайдер выше
   сохраняет приоритет. Стиль статус-бара, дошедший до ОС, контрастен
   ground схемы (dark → light-content, light → dark-content) на splash и
   после снятия оверлея; StatusBar вне поддерева оверлея.
7. Кадры вне предмета — вход F03.01 (email) и F03.02 (code), welcome,
   recovery (F03.04), unavailable — поверхность 995 как на B: корень
   #FFFFFF, отступы 48/16/16 в ОБЕИХ схемах на ВСЕХ этих кадрах.
8. JS-ОВЕРЛЕЙ splash (С2, арбитраж круга 2): рендерится ПОВЕРХ дерева
   оболочки (последний ребёнок корня PilotApp), `StyleSheet.absoluteFill`,
   `pointerEvents="none"`, фон `tokens.ground` схемы, содержимое — РОВНО
   один Image, эффективный `source` которого — модуль файла
   `mobile/assets/images/splash-composite-{dark,light}.png` СВОЕЙ схемы
   (того, чьё содержимое судит 4б; require относительным путём из
   pilot-app.tsx), `resizeMode contain`, бокс Image следует боксу оверлея
   (width/height '100%' поверх absoluteFill); ВИДИМ в реальном рендере —
   оверлей и его Image проходят RNTL `toBeVisible` (узел и все предки до
   корня: display, opacity, скрытие от доступности) в обеих схемах; БЕЗ
   Text-узлов (wordmark/tagline — растр); автоскрытие таймером-литералом
   1200 мс с очисткой в cleanup; `SplashScreen.preventAutoHideAsync()` на
   модуле, `hideAsync()` — ровно один раз в effect ПОСЛЕ первого commit
   дерева с оверлеем (наблюдается commit-журналом: prevent → commit с
   оверлеем (React.Profiler) → hide; hide в render, на модуле, в первом
   commit без оверлея — красны); оверлей НЕ расширяет Frame state-machine;
   `pilot.test` 995 и first_run_111 на модели с оверлеем — 14/14 и 23/23 (замер v2).
9. Видимость кадра splash на устройстве судит СВЕРКА КАДРА e2e с макетом
   (123): снимок `vkhod-117-splash` каждой схемы объявлен в перечне сверки
   123 (манифест H из «Существующего»: id «Splash dark»/«Splash light»,
   макет и sha256 = эталон Б1 схемы, порог ≥ 0.6 — литералы source.json
   `sverka_123`) и снимается сценарием 117 шагом НЕПОСРЕДСТВЕННО после
   ожидания видимости оверлея; шаг сверки 123 в job android-e2e
   присутствует безусловно и исполняет канонический манифест пина
   `.harness123` (клетки SVERKA_123_*: литералы source.json
   `sverka_123.provodka`, сняты с frozen 123 v1 приёмка п.5–6). Невидимый
   оверлей даёт на этом снимке не Splash.png: замер 117e оракулом 123 —
   First-Run под именем splash (носители 123 r58d, r814) 0.000
   `NIZHE_POROGA` в обеих схемах против честного splash r1423 0.783/0.782 `OK`.

## Проверяемый шов

`mobile/app.json` (плагин: знаки splash-sign-{dark,light}.png; композиты
оверлея `mobile/assets/images/splash-composite-{dark,light}.png`;
производные иконки); `mobile/src/bootstrap/pilot-app.tsx` (JS-оверлей
splash, провод темы ОС, StatusBar); сценарий Maestro 117 в
`mobile/.maestro/` (после freeze — implementer); job android-e2e
`.github/workflows/mobile.yml` — только наблюдение шагов 123 (SVERKA_123_*).
Ожидания проб — литералы
source.json (сняты с read-only docs/ B ДО субъекта, правило 8/Н-351); ни
одна клетка не читает значения у субъекта; эталоны артбордов припинены
sha256 (несовпадение — rc2 ORACLE_TAMPERED).

## Закрытые перечни клеток (числа из кода проб и прогонов; v3 — прогон
на R@B 8748a7a335 с node_modules, ветка wip/117/architect-v3)

Поведенческая семья (Jest/RNTL, `vkhod_probe.py` → `vkhod.test.tsx`,
34 клетки — замер v3 `behavioral 34/34`: 26 клеток 117/2 + 4 клетки
геометрии/z-порядка кругов Adv117v2/v3 по реализации + 4 клетки
миграции v3):
- Г0 `RESTYLE_GUARD_995_F03_{DARK,LIGHT}` ×2 — корни F03.01 И F03.02
  #FFFFFF 48/16/16 (вход вне предмета, поверхность 995 как на B).
- Г1 `RESTYLE_GUARD_995_WELCOME_{DARK,LIGHT}` ×2, Г2
  `RESTYLE_GUARD_995_RECOVERY_{DARK,LIGHT}` ×2, Г3
  `RESTYLE_GUARD_995_UNAVAILABLE_{DARK,LIGHT}` ×2 — #FFFFFF и 48/16/16.
- Р1 `PROD_ENTRY_OS_THEME_{DARK,LIGHT}` ×2 — production-вход без
  провайдера, схема — мок Appearance: фон оверлея = ground схемы ОС.
- В2-2 `STATUS_BAR_STYLE_{DARK,LIGHT}` ×2 — стиль статус-бара, дошедший до
  ОС, на splash и после снятия оверлея = литерал контраста ground схемы.
- Р6 `SPLASH_OVERLAY_CONTAIN_{DARK,LIGHT}` ×2 — бокс оверлея и Image
  width/height '100%', contain.
- С2-оверлей: `SPLASH_OVERLAY_MOUNTED_{DARK,LIGHT}` ×2 (testID
  splash-overlay, pointerEvents none, absoluteFill, фон ground, Image
  внутри); `SPLASH_OVERLAY_COMPOSITE_{DARK,LIGHT}` ×2 (С2-а: в поддереве
  оверлея РОВНО один Image, эффективный `source` — модуль файла
  `mobile/assets/images/splash-composite-<схема>.png`; jest-expo
  превращает любой PNG в `1`, поэтому оба файла композита подменены в
  тесте уникальными сентинелями `jest.mock(…, {virtual: true})` по пути
  от файла теста, сравнение по ссылке; `resizeMode contain`, absoluteFill,
  не скрыт); `SPLASH_OVERLAY_VISIBLE_{DARK,LIGHT}` ×2 (инвариант 8:
  оверлей — запрос с включением скрытых узлов — и его единственный Image
  проходят RNTL `toBeVisible`, т.е. ни узел, ни предок до корня рендера
  не несёт display none / opacity 0 / скрытия от доступности);
  `SPLASH_OVERLAY_NO_TEXT_{DARK,LIGHT}` ×2 (в поддереве
  оверлея нет Text-узлов); `SPLASH_HIDEASYNC_ORDER_{DARK,LIGHT}` ×2
  (С2-б: commit-журнал — мок пишет prevent/hide, React.Profiler onRender
  пишет commit с наличием оверлея в контейнере `test-renderer`
  `createRoot` в момент commit; требование: первый commit несёт оверлей,
  hide ровно один и ПОСЛЕ него, prevent раньше первого commit);
  `SPLASH_OVERLAY_TIMER_HIDE_{DARK,LIGHT}` ×2 (fake timers: до 1199 мс
  на месте, на 1200-й скрыт).
- (Adv117v2, круг по реализации) `SPLASH_OVERLAY_GEOMETRY_{DARK,LIGHT}`
  ×2 — бокс Image оверлея без степеней свободы: absoluteFill,
  width/height '100%', ноль transform/margin*/краёв ≠ 0.
- (Adv117v3, круг по реализации) `SPLASH_OVERLAY_ZORDER_{DARK,LIGHT}`
  ×2 — оверлей ПОВЕРХ полноэкранного FirstRun: сплющенный zIndex
  оверлея выше zIndex корня FirstRun И ветка оверлея позже ветки
  FirstRun в дереве хоста.
- (117 v3, миграция) `MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT`,
  `MIGRACIYA_W1A_NULL_PREZHNIJ_PUT`, `MIGRACIYA_W1A_STALE_PREZHNIJ_PUT`
  — без admission (W0) ИЛИ без current (null/stale) демо-вход ведёт
  прежним путём B (кадр code F03.02, auth-code достижим), кадры
  Erstinformation/Start не возникают; `MIGRACIYA_W1A_CURRENT_MARSHRUT`
  — при W1A ∧ current: First-Run → F03.01 (прежний вход жив) → демо →
  Erstinformation (continue) → Start (start_tabs + четыре вкладки
  testID приёмки 118), порядок наблюдаем последовательными шагами,
  прежний код-кадр покинут. Допуск — порт onboarding (внешняя сессия),
  оси W0/W1A × null/stale/current.

Статическая семья (`vkhod_static_probe.py`, 43 клетки — замер v3
`static 43/43`: 40 клеток 117/2 + SPLASH_OVERLAY_NO_TRANSFORM,
SPLASH_OVERLAY_NO_LAYOUT_OFFSET, SPLASH_OVERLAY_ZORDER кругов
Adv117v2/v3; v3 семью не меняет):
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
эталоном), SPLASH_OVERLAY_NO_TRANSFORM, SPLASH_OVERLAY_NO_LAYOUT_OFFSET,
SPLASH_OVERLAY_ZORDER (статические сегменты JSX оверлея — геометрия и
z-порядок, Adv117v2/v3), USER_STYLE_AUTOMATIC, STATIC_ORACLE_LITERALS,
ICON_RASTER_WHOLE, ADAPTIVE_FG_RASTER, ADAPTIVE_MONO_RASTER,
ADAPTIVE_BG_SOLID, FAVICON_RASTER_WHOLE, IOS_ICON_NOT_TEMPLATE,
MAESTRO_SPLASH_FRAME_WAIT (шаг НЕПОСРЕДСТВЕННО перед takeScreenshot
splash — extendedWaitUntil visible splash-overlay, YAML-парсером),
MAESTRO_FIRST_RUN_ORDER (между снимком splash и takeScreenshot
first-run — notVisible splash-overlay: свидетельство снятия оверлея, не
приёмка экрана First-Run), SPLASH_FRAME_SVERKA_123_{DARK,LIGHT} ×2
(согласованность справочного манифеста H kadry_117.json с пинами 117:
ровно один кадр темы с макетом эталона Б1 этой темы — id, sha256, снимок
`vkhod-117-splash`, порог ∈ [0.6, 1] — литералы source.json
`sverka_123`; сценарий субъекта снимает этот снимок; потребление
манифеста судят SVERKA_123_*), SVERKA_123_STEP_UNCONDITIONAL (инвариант
9: в `jobs.android-e2e.steps` workflow субъекта ровно один шаг, чей
`run` несёт литерал `script`, без ключей `if` и `continue-on-error`),
SVERKA_123_MANIFEST_CANON (строка `run` с литералом `script` до первого
`|`, разбор shlex — ровно `python3 <script>` и пары
`--manifest`/`--kadry`/`--repo` = литералы, иных токенов нет;
`git ls-files -- mobile/maestro-out-117` субъекта пуст),
SVERKA_123_HARNESS_PIN (ровно один `uses: actions/checkout@*` с
`with.path` `.harness123`, `with.repository` `a3ka/dev-harness`,
`with.ref` ~ `\A[0-9a-f]{40}\Z`, без `if`, раньше шага сверки) —
литералы source.json `sverka_123.provodka`; YAML-парсер, отсутствие
pyyaml — rc2.

Обманные стабы (привязка к ветвям — ТОЛЬКО по коду MUTANTS проб, Н-39;
depends измерены прогонами; поведенческая матрица v3 — rc0 на R@B,
статическая v3 — rc0 на R@B, семью v3 не меняет):
поведенческих 35 — 24 из 117/2 (restyle-welcome-vkhod,
restyle-recovery-vkhod, restyle-unavailable-vkhod,
restyle-recovery-light-vkhod, overlay-absent-first-commit,
overlay-text-words, overlay-hideasync-skip, overlay-hideasync-module-scope,
overlay-timer-none, overlay-wrong-source, overlay-hide-before-commit,
prod-theme-os-ignored, prod-theme-light-hardcode, auth-restyled-ground,
auth-restyled-code-light, overlay-intrinsic-size, overlay-opacity-zero,
overlay-display-none, root-opacity-zero, overlay-zero-size,
statusbar-absent, statusbar-light-both, statusbar-dark-both,
statusbar-in-overlay) + 7 кругов Adv117v2/v3 (overlay-transform-
{translatex,translatey,scale}, overlay-margin-offset,
overlay-zindex-{minus,zero}, overlay-before-firstrun) + 4 миграции v3
(migracija-admission-literal — named MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT;
migracija-gate-ignor — named MIGRACIYA_W1A_{NULL,STALE}_PREZHNIJ_PUT;
migracija-start-pryamo — named MIGRACIYA_W1A_CURRENT_MARSHRUT;
migracija-f03-put-udalen — named все 4 MIGRACIYA_*, depends Г0–Г3 ×8:
прежний путь удалён — кадры недостижимы, гварды падают по той же
причине); статических 38 — 31 из 117/2 (icon-template-bytes,
adaptive-expo-blue, splash-image-forgery, icon-twin-three-pixels,
splash-composite-twin, splash-composite-no-words, splash-composite-shifted,
splash-composite-halfres, splash-imagewidth-76, adaptive-favicon-template,
platform-image-template-override, platform-same-basename,
platform-density-template, splash-dark-block-missing, splash-light-missing,
user-style-light-stays, ios-legacy, overlay-wrong-source,
maestro-splash-no-wait, maestro-splash-wait-commented,
maestro-splash-wait-after-shot, maestro-first-run-overlay-kept,
maestro-first-run-as-splash, maestro-splash-overlay-gone-before-shot,
maestro-splash-shot-renamed, sverka-step-absent, sverka-continue-on-error,
sverka-if-conditional, sverka-local-manifest, sverka-kadry-other,
sverka-ref-branch) + 7 Adv117v2/v3 (overlay-transform-{translatex,
translatey,scale}, overlay-margin-offset, overlay-zindex-{minus,zero},
overlay-before-firstrun); каждый красен именованной клеткой (статический
— КАЖДОЙ своей именованной), побочная краснота только в depends; якорь
мутанта неуникален → отказ rc2; сломанный мутантом свит →
MUTANT_SUITE_BROKEN rc2 (не зелень).


## Приёмочный критерий

R — disposable копия Complior-mob на B под /tmp/dev-harness-verify с
node_modules в mobile/ (симлинк); пробы — Python 3 stdlib (+ pyyaml для
клеток Maestro; отсутствие — rc2 INFRASTRUCTURE, не зелень).

- Дано B без реализации: `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py
  --repo R` → rc1, строка `VKHOD_SPLASH_OVERLAY_ABSENT` (клетка
  SPLASH_OVERLAY_MOUNTED_* красна; замер 117e: failed 18 of 26; замер v3
  на R@B: failed 23 of 34 — 22 клетки оверлея (18 прежних + GEOMETRY ×2 +
  ZORDER ×2) + MIGRACIYA_W1A_CURRENT_MARSHRUT (маршрут на B не реализован);
  зелены Г0–Г3 ×8 и MIGRACIYA_*_PREZHNIJ_PUT ×3 — прежний путь и есть
  состояние B, это не ослабление);
  `vkhod_static_probe.py --repo R` → rc1 `VKHOD_SPLASH_COMPOSITE_ABSENT`.
- Дано B с эталонной моделью (`--model`) либо честное C: обе пробы → rc0 с
  перечнем: поведенческая 34/34 (замер v3), статическая 43/43 (замер v3;
  модель workflow — `mobile.yml` `cmp-mob-123/sverka` @10cf684 дословно).
- Дано C, в котором `.github/workflows/mobile.yml` — workflow B 8748a7a335
  (шагов 123 нет); когда `vkhod_static_probe.py --repo R`; тогда rc1, красны
  ровно `SVERKA_123_STEP_UNCONDITIONAL`, `SVERKA_123_MANIFEST_CANON`,
  `SVERKA_123_HARNESS_PIN` (замер 117f).
- Дано C с обходом критика круга 2 (свидетель
  `Critic117v2b/wrong-effective-workflow.yml`: шаг 123 с
  `--manifest mobile/.maestro/compare-117.json`, где Splash light объявлен
  темой dark); когда `vkhod_static_probe.py --repo R`; тогда rc1, красна
  ровно `SVERKA_123_MANIFEST_CANON` (замер 117f).
- Дано C с невидимым оверлеем (свидетель критика: `opacity: 0` в стиле View
  `splash-overlay`, всё прочее честно); когда `vkhod_probe.py --repo R`;
  тогда rc1, красны ровно `SPLASH_OVERLAY_VISIBLE_{DARK,LIGHT}` (замер
  117e; тот же класс — стаб overlay-opacity-zero матрицы v3: red = ровно
  эти две клетки).
- Дано C со сценарием «First-Run под именем splash» (свидетель критика:
  ожидание first-run-continue и notVisible splash-overlay перед снимком
  splash); когда `vkhod_static_probe.py --repo R`; тогда rc1, строка
  `RED MAESTRO_SPLASH_FRAME_WAIT` (замер 117e).
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный, каждый
  стаб красен именованной ветвью (35+38), побочная краснота только в
  depends; любой MUTANT_GREEN/MUTANT_NAMED_MISS/MUTANT_UNEXPECTED_RED —
  rc2.
- Дано C; `git status --short --untracked-files=all` в R после проб — 0 строк
  кроме симлинка `mobile/node_modules` (инфраструктура R, не проба).
- Дано C; `git diff --exit-code --stat B C -- mobile/src/features/auth/` →
  rc0 и 0 строк (вход вне предмета: auth-screen.tsx в ЗОНЕ только для
  отката рестайла C к B); rc1 / непустой вывод — отказ ревьюера по строке
  ПЕРЕСЕЧЕНИЕ.
- Дано C; `npm run lint`, `npm run typecheck` в R/mobile → rc0;
  `npx jest src/bootstrap/__tests__/pilot.test.tsx` (995, byte-frozen) → rc0,
  14/14; батарея `fixtures/workshop_project/first_run_111/` на C → rc0,
  23/23 — замер v2 на B + модель 117; замер v3 на R@B: pilot.test 14/14
  (поставка 117 v3), first_run_111 23/23 rc0 на объединении — модель 111
  (first-run-screen v4, i18n, wordmark) + ПОЛНАЯ поставка 117 v3
  (pilot-app с миграцией, app.json, ассеты): миграционная модель прежние
  пробы 995/111 не ломает (на голом B батарея 111 красна v4b-клетками —
  строки v4 в FirstRunScreen на B отсутствуют, состояние предмета 111,
  не предмет 117).
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0;
  android-e2e (release APK: `expo prebuild` + `assembleRelease`, Maestro)
  исполняет сценарий 117 в `mobile/.maestro/`; takeScreenshot КАЖДОГО
  кадра по правилу (В): splash × {тёмная, светлая} — сверка с Splash.png /
  Splash-Hell.png; First-Run после снятия оверлея × {тёмная, светлая}
  (свидетельство снятия оверлея; макет First-Run судит first-run-ekran);
  скриншоты в артефактах прогона, ревьюер сверяет глазами и мерой. Шаг
  сверки 123 (текст — frozen 123 п.5, автор — implementer 123; PR 117
  несёт его коммит с сохранённым авторством) стоит в job android-e2e;
  клетки SVERKA_123_* зелены; его вывод в артефакте несёт строки
  `KADR<TAB>Splash dark<TAB>…<TAB>OK` и `KADR<TAB>Splash light<TAB>…<TAB>OK`;
  негатив — невидимый оверлей даёт на снимке splash окно First-Run:
  `NIZHE_POROGA<TAB>Splash dark`/`…light`, score 0.000, шаг rc1 — job
  android-e2e красен (замер 117e оракулом 123 на носителях r58d/r814
  против честного r1423 0.783/0.782).
- Дано авторская пачка; `bash scripts/pre_critic.sh
  contracts/117-cmp-mob-vkhod-splash.md` → rc0.

## Зоны и исполнители

ЗОНА architect: contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Пути implementer отсчитываются от корня Complior-mob:

ЗОНА implementer: mobile/app.json mobile/assets/images/ (icon.png, splash-composite-dark.png, splash-composite-light.png, splash-sign-dark.png, splash-sign-light.png, android-icon-foreground.png, android-icon-background.png, android-icon-monochrome.png, favicon.png) mobile/src/bootstrap/pilot-app.tsx mobile/src/features/auth/auth-screen.tsx .github/workflows/mobile.yml mobile/.maestro/

ПЕРЕСЕЧЕНИЕ: `mobile/src/bootstrap/pilot-app.tsx` — общий с замороженными
семьями 995/111: в pilot-app ДОБАВЛЯЮТСЯ JS-оверлей splash (последний
ребёнок корня, НЕ кадр state-machine), провод темы ОС (только когда выше
PilotApp нет явного провайдера) и StatusBar вне оверлея; корни кадров,
первый кадр и вход шва — как на B. 117 v3 (миграция 117/3): в pilot-app
ДОПУСКАЕТСЯ демо-маршрут First-Run → demo → Erstinformation → Start по
разделу «Миграция 117 v3» (кадры 'erstinformation'/'start', допуск
admission 'W1A' из сессии ∧ gate 'current', без допуска — прежний путь);
эта правка — ЗОНА implementer 118 (см. ПЕРЕСЕЧЕНИЕ в frozen
contracts/118-erstinformation.md) и разрешена ТОЛЬКО ПОСЛЕ тега
frozen/contracts/117/3; для implementer 117 (splash/иконка) pilot-app
по-прежнему только оверлей/тема/StatusBar, как на B.
`mobile/src/features/auth/auth-screen.tsx`
(вход, предмет first-run-ekran) остаётся в ЗОНЕ implementer ТОЛЬКО для
возврата к B: текущий C (Complior-mob#114) несёт рестайл входа, его откат —
правка этого пути; итог C ≡ B по нему (приёмка: `git diff --stat B C --
mobile/src/features/auth/` → 0 строк). Сужение ЗОНА-строки не делается:
спек-гейт 036 (В3 перенос зоны) требует СПАСЕНО-покрытия, а коммитов
implementer по продуктовому пути в репо харнесса нет (исключение
ZONE_MOVE_EXEMPT — замкнутый перечень, сейчас только 109).
`mobile/src/ui/` (компоненты CMP-MOB-002, 999), `mobile/src/theme/` (999),
`mobile/src/bootstrap/__tests__/` (995), `docs/`, `design/` — read-only для
117. Знаки и композиты выводятся из read-only `screens/Splash{,-Hell}.png`
(артборд не меняется). Действующие Maestro-сценарии лежат в
`mobile/.maestro/` (совет критика, подтверждён арбитражем), сценарий 117 —
туда же.

ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 123 шаги checkout `.harness123` и «123 сверка кадров с макетом» пишет implementer 123; 117 их не меняет, PR 117 несёт коммит 123 с сохранённым авторством (РЕШЕНИЕ арбитра contracts-117-v2-svjaz-123), правка текста шагов 123 — отказ ревьюера 117

РАБОТА НЕ РАЗДАЁТСЯ: implementer не спавнится до accept критика и freeze
оркестратора; предмет этой пачки — контракт + красные пробы, предъявленные
красными на B и зелёными на эталоне.

ПРЕДПОСЫЛКИ:
- setting v3 новых предпосылок НЕ вводит: шаги CI не меняются, secrets/variables/environments не требуются; действуют предпосылки 117/2 (android-e2e release APK: expo prebuild + assembleRelease, Maestro, H-checkout .harness123 пина 123, шаг quality с пробами 117)
- setting для implementer 118 (после frozen/contracts/117/3): проба композиции gate/admission в mobile/src/bootstrap/__tests__ исполняется существующим шагом CI без новых настроек репозитория

## Модель угроз

ЗАЩИЩАЕТ:
- от шаблонной иконки Expo: пиксельные свойства канона + sha-литералы
  шаблонов базы B + ЦЕЛОЕ изображение производных против аналитической
  растеризации канона (подложки-близнецы с точками старых проб красны);
- от подложного композита оверлея (Б1): эталон артбордов припинен sha256
  (несовпадение — rc2 ORACLE_TAMPERED), маска E «фон±40 → прозрачно»,
  размер композита = артборд 390×844 (иной масштаб при точном aspect
  красен: свидетели halfres 195×422 и lowres 39×84), recall по ВСЕЙ маске M
  (15439/15346 пикселей) И precision по ВСЕМ непрозрачным C ≥ 0.98 (стабы
  «семь пикселей», «знак без надписей», «сдвиг 9 px», «половинный масштаб»
  красны той же клеткой);
- от подмены платформенных ассетов (Б2): клетка вызывает НАСТОЯЩИЕ
  getAndroidSplashConfig + setSplashImageDrawablesAsync и судит
  СОДЕРЖИМОЕ произведённых drawable-{mdpi..xxxhdpi}/splashscreen_logo.png и
  drawable-night-* обеих тем (знак аналитикой splash_sign, dims 288×m,
  размер знака = imageWidth×m ±3); iOS — содержимое по эффективному пути +
  эффективные imageWidth/resizeMode + ВЫХОД настоящего генератора
  storyboard (рамка 181×181, centerX/centerY) при литерале отсутствия
  `enableFullScreenImage_legacy`; basename НЕ сравнивается;
- от одновариантного или недостижимого splash: блоки app.json (знаки обеих
  тем, imageWidth 181, contain) + эффективные ФОНЫ резолверами prebuild,
  USER_STYLE_AUTOMATIC; провод темы ОС на production-входе (Р1) и стиль
  статус-бара по схеме (В2-2) — светлый splash не тёмный и не с белыми
  иконками на #f3f2ee;
- от пропажи кадра Splash.png в Expo Go / после натива (С2): оверлей
  судится поведенчески — смонтирован (absoluteFill, pointerEvents none,
  ground), вписан по окну (Р6), РОВНО один Image с эффективным source =
  модуль композита СВОЕЙ схемы, тот самый файл, что судит эталон Б1 (стаб
  overlay-wrong-source красен поведенческой и статической клетками), без
  Text-узлов; commit-журнал prevent → первый commit с оверлеем → один hide,
  скрытие таймером-литералом 1200 мс;
- от невидимого кадра splash (вердикт критика 117 v2 круг 1): в рендере —
  `toBeVisible` оверлея и его Image по всей цепочке предков (стабы
  overlay-opacity-zero, overlay-display-none, root-opacity-zero красны
  SPLASH_OVERLAY_VISIBLE_*, нулевой бокс overlay-zero-size — Р6); на
  устройстве — сверка снимка `vkhod-117-splash` × тема с макетом мерой 123
  (инвариант 9: кадр объявлен в манифесте H, снимок снят сразу после
  ожидания оверлея — стабы maestro-splash-shot-renamed,
  maestro-first-run-as-splash, maestro-splash-overlay-gone-before-shot
  красны; шаг сверки стоит безусловно — клетки SVERKA_123_*);
- от шага сверки 123, который есть, но не судит (РЕШЕНИЕ арбитра (б),
  обход критика круга 2): клетки SVERKA_123_* — шаг без `if`/
  `continue-on-error` (стабы sverka-continue-on-error,
  sverka-if-conditional), канонический манифест пина и кадры из прогона
  (sverka-local-manifest — обход дословно, sverka-kadry-other), пин
  40-hex раньше шага (sverka-ref-branch); workflow без шагов 123
  (sverka-step-absent) красен всеми тремя;
- от пустого кадра в свидетельстве: сценарий Maestro судится YAML-парсером
  (ожидание оверлея непосредственно перед снимком splash, снятие оверлея
  до снимка First-Run);
- от тихого рестайла кадров вне предмета: Г0–Г3 по ВСЕМ исключённым кадрам
  (вход F03.01/F03.02, welcome, F03.04, unavailable) × обе схемы (стаб
  auth-restyled-ground — форма текущего C — красен Г0);
- от обхода допуска демо-маршрута (117 v3): клетки MIGRACIYA_* судят все
  оси W0/W1A × null/stale/current на порте onboarding (внешняя сессия);
  литерал допуска в pilot-app (стаб migracija-admission-literal),
  допуск без current (migracija-gate-ignor), Start мимо Erstinformation
  (migracija-start-pryamo) и удаление прежнего пути F03
  (migracija-f03-put-udalen — красен и гвардами Г0–Г3: кадры
  недостижимы) красны именованными клетками;
- от зависимого оракула (Н-351): ожидания — литералы source.json/теста,
  STATIC_ORACLE_LITERALS; эталоны — sha-пин read-only docs/;
- от мёртвой матрицы: обе пробы исполняют все стабы (35+38), depends
  измерены прогоном, unexpected_red/suite_broken — rc2.

НЕ ЗАЩИЩАЕТ:
- вход F03.01/F03.02 и First-Run — без механической сверки с макетом до
  предмета `first-run-ekran` (сверка кадров с PNG эталона Complior-mob#118):
  117 v2 держит только поверхность 995 (Г0, К8 111) и не судит ни состав,
  ни раскладку, ни цвета входа; расхождение входа с эталоном
  F03.01/F03.02/F03.02-V01 до first-run-ekran — принятый остаточный риск
  (слово владельца 2026-10-21); ловец — critic/reviewer first-run-ekran;
- статус-бар на кадрах поверхности 995 (белый корень) в тёмной схеме —
  стиль по схеме даёт светлые иконки на #FFFFFF (как умолчание ОС на B);
  стиль кадров входа — предмет first-run-ekran; ловец — ревьюер по
  скриншотам first-run-ekran;
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
- `toBeVisible` в рендере не видит скрытия геометрией и краской
  (transform scale 0, вынос за окно, непрозрачный сосед поверх оверлея
  выше по zIndex) — его ловит сверка снимка splash с макетом мерой 123
  в android-e2e (инвариант 9); проводка шага наблюдается клетками
  SVERKA_123_*, остаток — четыре пункта ниже;
- байты `kadry_117.json` на SHA пина `.harness123` против копии в H
  батареи 117: клетка судит форму пина (40-hex), не байты файла на ином
  SHA; гарантия — иммутабельность frozen-файла 123; ловец — ревьюер 123
  при перепине;
- связь каталога `--kadry` с `--test-output-dir` шага Maestro 117 (bash
  внутри `run`) не парсится; защита — fail-closed 123 (пустой каталог →
  `KADR_OTSUTSTVUET` rc1) и «каталог не в git»; маскировка кода возврата
  в shell после вызова (конвейер без `set -o pipefail`, `|| true`) —
  клетка судит строку вызова до первого `|`, не семантику shell; ловец —
  ревьюер по логу android-e2e (строки KADR, rc шага);
- job-уровень (`if:` на job, required checks ветки): строка
  `gh pr checks --required` → rc0 в приёмке, настройка — владельца;
- последовательность ленда: 117 done требует шага 123 в PR 117 (123 п.5
  «положительная половина судится на первом прогоне PR 117 v2»); задержка
  ленда 123 словом владельца по форку n123 задерживает 117 — сообщается
  владельцу через оркестратора;
- от точности глифов wordmark/tagline в композите (шрифт DM Sans) — эталон
  судит маску/цвет, не начертание; ловец — ревьюер по правилу (В);
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI
  evidence.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: правило (В) «Мобильный экран — сверка с макетом» (слово
владельца ~18:00) — норм-строки в roles/reviewer.md ЕЩЁ НЕТ, поэтому
role-канал с литералом невозможен и правило потребляется ЗДЕСЬ прозой как
cognitive-only: макет каждого кадра назван (splash — Splash.png/
Splash-Hell.png; иконка — complior-app-icon.svg), takeScreenshot каждого
кадра (android-e2e), ревьюер сверяет скриншот ↔ макет глазами и мерой.
Механический гейт сверки кадра splash — мера 123 (`kadry_117.json`; текст
шага android-e2e — предмет 123); 117 судит, что снимок splash × тема
объявлен в её перечне и снят сценарием, и что шаг 123 стоит безусловно с
каноническим манифестом (инвариант 9, клетки SVERKA_123_*). Остаточный
риск — четыре пункта НЕ ЗАЩИЩАЕТ после `toBeVisible` (ловец — reviewer).
Новая общая норма
харнесса не вводится. Пробы 117 исполняются в CI Complior-mob из
H-checkout по образцу 999/107/108/111 (шаг quality в mobile.yml, зона
implementer); в registry/ci-steps.tsv харнесса НЕ регистрируется (python3
stdlib, npm-ключа нет).

## Вопросы владельцу

1. СНЯТ (сужение 2026-10-21): вход F03.01/F03.02 выведен в first-run-ekran.
2. Шрифт tagline: канон — DM Sans; в мобильном рантайме системный шрифт (в
   композите splash tagline — растр артборда). Заводить ли шрифтовой
   ассет — отдельная воля (117 не вводит).
3. Анимация снятия splash: канон не описывает; 117 — нативный знак
   скрывается сразу после первого коммита с оверлеем (hideAsync), оверлей
   исчезает по таймеру 1200 мс без анимации. Нужна ли анимация (fade)?
4. `userInterfaceStyle: automatic` открывает системную тему для нативного
   выбора splash; PilotApp без провайдера выше проводит схему ОС
   (инвариант 6). Верно ли, что явный провайдер 999 выше сохраняет
   приоритет?
5. Ключ каталога для «Versicherung. Erledigt.» отсутствует (meta copy-keys
   артборда пуст); текст живёт в растре композита. Заводить ли ключ
   (копия-синька CMP-MOB-089)?
6. СНЯТ (сужение 2026-10-21): подпись поля входа — предмет first-run-ekran.
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
