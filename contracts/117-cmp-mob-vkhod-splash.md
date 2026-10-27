# Контракт 117 — mob: НАШ splash (нативный знак + JS-оверлей, обе схемы) + иконка (CMP-MOB-006)

ВЕРСИЯ: v3 (миграция 117/3 — слово владельца 2026-10-24 ~10:15 UTC «а» по
форку n118-migraciya-117; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ — в теле изменяющего
коммита). Дельта к v2 — ТОЛЬКО раздел «Миграция 117 v3», свод
«Закрытых перечней клеток» с деревом, числа этих семей в приёмке и пула
MIGRACIYA в «Модели угроз»; всё прочее v2 действует дословно.
Правка по FAIL критика v3 (два блокера-обхода: непокрытые входы без
admission/current + светлая тема; Г0 при подключённом onboarding) — в
тех же разделах, добавлением клеток/стабов; семантика прежних клеток и
мутаций прежних стабов неизменна (расширены только перечни их
наблюдаемых ветвей — замером матрицы, список в «Закрытых перечнях»).
Правка по FAIL критика v3 КРУГ 2 (два блокера, корень один: батарея
покрывала выборку входов допуска/Г0, а не всё пространство порта —
зелёные обходы new-light-gate-default, new-empty-session-demo,
new-g0-denied-admission): ТАБЛИЦА ВХОДОВ допуска — все выразимые
входы порта onboarding параметризованной батареей MIGRACIYA_TABLICA_*
(источник счёта клеток — таблица, имена производны от строки) + все
10 мутантов критика кругов 1–2 + собственные стабы; прежние клетки
117/2 и правки круга 1 сохранены поимённо (removed=[]).
Консолидация v3 по РЕШЕНИЮ арбитража нарезки 117↔118 (после 3 FAIL
критика): семантика демо-маршрута приведена к frozen 118/1 инв. 4–5
(admission решает ПОВЕРХНОСТЬ после демо, gate — ПЕРЕХОД continue →
Start; ожидания строк W1A×не-current переписаны с «code» на
«Erstinformation без Start»), добавлены клетки (а)–(д) и семь
r3-мутантов критика именованными стабами, раздел «Граница
модель/production»; прежние клетки и стаби не удаляются (removed=[]),
три FAIL и r3-свидетели не стираются.
ВЕРСИЯ: v4 (стабилизация кадра Splash — класс B; слово владельца
2026-10-27 ~00:05 UTC, вариант (а): отдельный малый предмет, параллельно
995, НЕ присоединять к 995; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ — в теле изменяющего
инварианты 10–12, блок клеток/стабов v4 в «Закрытых перечнях», пункты
приёмки v4 и дополнения «Модели угроз»; всё прочее v3 действует дословно.
Правка по FAIL критика v4 круг 1 (ОДИН блокер: клетки MAESTRO_HOLD_COLD_
START и реплей REPLAY_SPLASH_WHILE_OVERLAY считали холодный старт СУММОЙ
команд — честную цепочку портили (1) второй launchApp{clearState} МЕЖДУ
stopApp и openLink → статика зелёная и (2) перестановка stopApp →
launchApp{clearState} → openLink → статика И поведение зелёные): холодный
старт теперь судится СОСТОЯНИЕМ «приложение запущено» по
последовательности команд (launchApp/runFlow/openLink — запускают,
stopApp — останавливает; openLink литерала — холодный старт ТОЛЬКО если
непосредственно перед ним приложение остановлено и этот stopApp стоит
ПОСЛЕ launchApp{clearState}, между ними запуска нет); клетки порядка
MAESTRO_HOLD_PORJADOK_* ПОРОЖДАЮТСЯ раннером (2 перестановки, 3 вставки,
2 удаления, оба обхода критика, честная цепочка; ожидания — литералы до
субъекта), стабы splash-hold-relaunch-pered-link и
splash-hold-porjadok-stop-launch добавлены; поведенческая семья (Jest)
порядок команд сценария НЕ судит — граница объявлена в «НЕ ЗАЩИЩАЕТ».
Правка по РЕШЕНИЮ арбитража 117 v4 (после FAIL критика 2/2: критик ПРАВ
— ложная красная: клетка брала ПЕРВОЕ ожидание visible во всём YAML, а
требуется ПОСЛЕ hold-openLink): ожидание судится ПЕРВЫМ ПОСЛЕ openLink,
добавочные НЕ запускающие шаги (снимок/notVisible/assertVisible/ожидание
visible) до stopApp решения НЕ меняют, запускающие — красны как прежде;
клетка VSTAVKA_WAIT_DO_STOPA (цепочка критика круга 2 — зелёна), счёт
семьи ×9 → ×10, статика 64 → 65.
Правка по FAIL критика v4 КРУГ 3 (contracts-117-v4-krug3, ОДИН блокер —
новая ложная зелёная в классе порядка, внутри границы арбитража :213–218):
запускающий шаг между hold-ссылкой и ожиданием — runFlow: start.yaml или
скалярный «- launchApp» — оставлял статическую батарею зелёной 65/65
(интервальный предикат после выбора ожидания видел только launchApp-словарь,
запуск через runFlow и скалярную форму не замечал; до ссылки
_cold_start_state runFlow уже знал). Признак запуска теперь ЕДИНЫ —
классификатор _is_launching (launchApp ЛЮБОЙ формы — словарь и скалярная
строка; runFlow — ЛЮБОЙ, консервативно: живой mobile/.maestro/start.yaml:4–7
запускает приложение с clearState, разрешение вложенного flow требует
чтения других файлов, которого у статической пробы нет — fail-closed;
openLink — любой; stopApp — не запускающий, отдельная ветвь состояния),
ДО ссылки и НА ИНТЕРВАЛЕ зовёт одну функцию; повторное открытие САМОГО
литерала на интервале запускающим НЕ считается (его судит
SPLASH_HOLD_LINK_ROUTE_MOUNT по числу ссылок канала — ровно одна).
Семья порядка ×10 → ×15 (+4 красных КЛАССА запускающего шага на
интервале: VSTAVKA_RUNFLOW_MEZHDU, VSTAVKA_LAUNCH_SKALJAR_MEZHDU,
VSTAVKA_LAUNCH_SLOVAR_MEZHDU, VSTAVKA_DRUGOJ_SSYLKI_MEZHDU; +зелёный
контроль не запускающего шага VSTAVKA_SNIMOK_MEZHDU), статика 65 → 70,
стаб splash-hold-runflow-posle-link (один на класс — та же ветвь
_is_launching; скалярная форма связана клеткой
VSTAVKA_LAUNCH_SKALJAR_MEZHDU).
Порог сверки 0.6 и кадр Splash обеих тем — НЕ тронуты (ограничение
владельца). ПЕРЕСМОТР v4 по живой пробе run 40434807469 (правило владельца
2026-10-26: один прогон в настоящем CI до критика): канал (В) env-удержания
e2e-сборки, принятый в сдаче 784bd32c, ОТКЛОНЁН живьём (регрессия шага
118), принят канал (Г) — удержание взводится ТОЛЬКО стартовым deep link
сценария 117; байты .github/workflows/mobile.yml продукта НЕ меняются,
пин 139/2 (f45c6823…) остаётся верным, перепин 139 не нужен, ПЕРЕСЕЧЕНИЕ
по env-ключу снято. ПЕРЕСМОТР (Г)→(Г′) по живой пробе run 40497913252 /
job 122172034122 (ветка cmp-mob-117/proba-v4g @ 6f10e2fc481d, голова #124
c617f6fb + два патча (Г)): host-ссылка complior://e2e-splash-hold живьём
ПРОВАЛЕНА — expo-router разбирает её как ПУТЬ /e2e-splash-hold, маршрут
ловит динамический (tabs)/[section].tsx и рендерит null для сегмента вне
TAB_ORDER ⇒ PilotApp не монтируется, hideAsync не вызван, нативный splash
залип на 15 с — флоу 117 красен (`Assertion is false: id: splash-overlay
is visible`), остальные 6 флоу SUCCESS. Принят канал (Г′): ссылка ведёт на
СУЩЕСТВУЮЩИЙ маршрут — КОРЕНЬ «/» (index.tsx монтирует PilotApp
безусловно), маркер удержания — в query: литерал complior:///?e2e=splash-hold.
Заменённый материал (Г) (НЕ заморожен, замена законна — сдача 2bdd4106):
клетки SPLASH_HOLD_LINK_CHANNEL/NO_ENV (литерал), MAESTRO_HOLD_COLD_START/
ALONE (литерал), REPLAY_ORACLE_CONSISTENT/REPLAY_SPLASH_WHILE_OVERLAY
(грамматика/реплей), SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT} и
SPLASH_OVERLAY_HOLD_NE_INOJ_URL_{DARK,LIGHT} (литерал в тесте); стабы
splash-hold-link-otsutstvuet/oslablen/sverh-timeout-a/env-vmesto-link/
vse-ssylki/start-launchapp/start-ne-holodnyj (якорь литерала),
splash-hold-link-invertirovan/po-umolchaniju-8000/vse-ssylki/taymer-bez-
clear (литерал в модели). Прежние замены против (В) сохраняют смысл:
клетки SPLASH_HOLD_E2E_ENV, SPLASH_OVERLAY_HOLD_E2E_{DARK,LIGHT}; стабы
splash-hold-env-otsutstvuet, splash-hold-env-oslablen,
splash-hold-env-v-pilote-ignoriruetsja; depends-расширения трёх
overlay-стабов (HOLD_E2E ×2 → HOLD_LINK ×2 + HOLD_NE_INOJ_URL ×2).
Отступления от байт-неизменности материала 117/3 — ТОЛЬКО объявленные в
«Стабах v4»: якорная строка трёх стабов overlay-hideasync-* следует за
байтом честной модели ('const timer' → 'let timer'; именованные ветви и
семантика мутаций не тронуты) и depends-расширения замером матрицы v4:
шесть maestro-стабов +REPLAY_SPLASH_WHILE_OVERLAY (прецедент правки v3
круга 1; no-wait, wait-commented и first-run-as-splash дополнительно
+MAESTRO_HOLD_COLD_START — цепочка канала (Г) рвётся без шага visible) и
три overlay-стаба +HOLD_LINK/HOLD_NE_INOJ_URL ×2.
КЛАСС РИСКА: обычный (UI-тайминг e2e-снимка; права/роли, авторизация,
деньги, ПД, юрдействия не затронуты).

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
- Маршруты deep link (v4 (Г′), живой провал пробы (Г) run 40497913252 —
  см. frontier): приложение на expo-router ~57.0.28 (`main:
  expo-router/entry`); извлечение пути — fork extractPathFromURL
  (node_modules продукта): путь = host + pathname, query в путь не входит
  (complior://start → /start — зелёные живые cmp-mob-002/004/108;
  complior://e2e-splash-hold → /e2e-splash-hold — провал (Г)). Дерево
  `mobile/src/app/` @ c617f6fb: `_layout.tsx` (Stack), `index.tsx` —
  PilotApp БЕЗУСЛОВНО (вход v3), `onboarding-session.tsx`,
  `start-destination.tsx`, `(tabs)/[section].tsx` — динамический
  одно-сегментный маршрут (сегмент ∈ TAB_ORDER {start, vorgaenge, schutz,
  post}: PilotApp только при недопуске admission ≠ W1A, при W1A — TabShell
  без оверлея; сегмент вне TAB_ORDER — `return null` :62–65,100 — пустой
  экран без hideAsync); `+not-found.tsx` ОТСУТСТВУЕТ. Единственный
  маршрут, гарантирующий монтирование PilotApp при любом состоянии сессии,
  — корень «/»; факты припинены source.json replay_117.route_facts.

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

Слово владельца 2026-10-24 ~10:15 UTC «а» по форку n118-migraciya-117;
семантика моментов допуска — по РЕШЕНИЮ арбитража нарезки 117↔118
(frozen 118/1 инв. 4–5, :15–16, :22–23; второй gate не вводится).
ЕДИНСТВЕННОЕ разрешённое изменение предмета v2: production
`mobile/src/bootstrap/pilot-app.tsx` ДОПУСКАЕТ маршрут
First-Run → demo → Erstinformation → Start (с вкладками), где
**admission решает ПОВЕРХНОСТЬ после демо, gate — ПЕРЕХОД**:

- admission 'W1A' ИЗ СЕССИИ пользователя (источник внешний по
  отношению к pilot-app; литерал допуска в pilot-app запрещён) → после
  демо-входа кадр 'erstinformation' при ЛЮБОМ gate (null/stale/current/
  отсутствует/неизвестный): пользователь ВИДИТ Erstinformation с
  маркером состояния gate (`erstinfo_gate_<gate>`; замёрженный кадр —
  состав 118), Start закрыт;
- gate 'current' (полный CURRENT_CONFIRMED-снимок 107: применимость
  REQUIRED, точная версия документа, evidence; предикат 107/118) решает
  ПЕРЕХОД: continue → 'start' ТОЛЬКО при W1A ∧ current; при
  null/stale/отсутствии/неизвестном нажатие continue НЕ даёт перехода
  (Start отсутствует и до, и после нажатия — инв. 5 frozen 118 «после
  действия continue»);
- не-W1A admission (W0/отсутствует/null/неизвестное) — прежний путь B:
  демо-вход ведёт в кадр code (F03.02) прежней семантикой auth.begin
  (достижимость F03.02 через демо сохраняется — замер арбитража: иной
  путь к code отсутствует; поверхность для W0 после дема frozen 118 не
  фиксирует, путь B — рекомендация арбитража, вопрос владельцу открыт);
  вход F03.01 (email) после First-Run — без изменений; корни кадров
  F03.01/F03.02 остаются поверхностью 995: #FFFFFF, отступы 48/16/16 в
  ОБЕИХ схемах (клетки Г0 `RESTYLE_GUARD_995_F03_{DARK,LIGHT}`).

Порядок маршрута: Start возникает ТОЛЬКО продолжением (continue) из
Erstinformation; Erstinformation — ТОЛЬКО демо-входом при admission
'W1A'; начальное значение frame — 'first-run' при ЛЮБОМ entry и любом
порте (сохранённый entry-стейт не создаёт Start). Пространство кадров
pilot-app расширяется ТОЛЬКО кадрами 'erstinformation' и 'start';
JS-оверлей splash — по-прежнему НЕ кадр state-machine.

Состав экранов Erstinformation (кадры F02.03/F02.08 по макетам) и Start
(вкладки, testID приёмки 118) — предмет 118; 117 v3 судит в pilot-app
только допуск, порядок и сохранность прежнего пути. Шов клеток миграции
— порты PilotApp (onboarding: admission/gate — ОБА поля OPTIONAL:
«отсутствует» — законный вход оси, не вне-алфавитная атака (FAIL
критика v3, блокер 1)); production-источник допуска — сессия
(проба композиции с внешним источником — инвариант 5 frozen 118/1,
зона implementer 118).

### Граница модель/production (РЕШЕНИЕ арбитража, п.1)

Батарея 117 пинит на МОДЕЛИ (fixtures/workshop_project/vkhod_117/model,
пробы обеих семей): чтение допуска ТОЛЬКО из `onboarding.admission`/
`onboarding.gate` (клетки (а): ось entry × решающие пары, постороннее
поле порта), начальный кадр 'first-run' при любом entry/порте и remount
(б), Г0 F03.01/F03.02 после смены схемы в живом экземпляре в обе
стороны на недопуске (в), отсутствие Start при смене темы на
Erstinformation без continue (г), чтение порта в момент действия —
rerender W1A→W0 до демо (д). Production-источник сессии, подключение
`/`, Maestro от настоящего корня, состав/пиксели F02/Start, настоящий
gate 107 и production-мутанты — приёмка 118 на настоящем корне
(инварианты 4–5 frozen 118/1 :22–23, команда bootstrap-пробы :32, зона
`mobile/src/bootstrap/__tests__/` у implementer 118): заморозка 117/3
НЕ заявляет эти сценарии зелёными на production — модель — доказательство
свойств композиции, а не production-проверка.

ТАБЛИЦА ВХОДОВ допуска (правка по FAIL критика v3 КРУГ 2 — инвариант,
источник счёта клеток): батарея судит ВСЕ выразимые входы порта
onboarding — ЕДИНАЯ таблица (vkhod.test.tsx, VHOD_TABLICA; зеркало
_TABL_ROWS в vkhod_probe.py для привязок стабов) параметризованно:
admission ∈ {W0, W1A, отсутствует, null, неизвестное значение('W2')} ×
gate ∈ {current, stale, отсутствует, null, неизвестное('future')} ×
тема {dark, light} × форма порта {не подключён (проп undefined),
пустой подключённый {}, частичный (ровно одно поле), полный (оба
поля)}. Форма связывает выразимость: невыразимые сочетания (поле
заданной формы без порта) таблицей не порождаются — таблица полна по
ВЫРАЗИМЫМ строкам: 1 (не подключён) + 1 (пустой) + 4+4 (частичный) +
16 (полный) = 26 строк × 2 темы = 52 клетки MIGRACIYA_TABLICA_<ФОРМА>_
<ADMISSION>_<GATE>_<ТЕМА>, имена производны от строки, счёт — из
таблицы кодом (сверка прогона и разбора, приёмка). Ожидание КАЖДОЙ
клетки выводится из её строки (консолидация по арбитражу): admission
'W1A' → Erstinformation с маркером gate (тема — не ось поверхности),
переход continue → Start ТОЛЬКО в строке POLNYJ/W1A/CURRENT, во всех
прочих W1A-строках (gate ≠ current: 4 строки × 2 темы = 8 клеток
таблицы + 4 именованные клетки W1A_{NULL,STALE,GATE_OTSUT,
STALE_SVETLAYA}) continue НЕ переводит, Start отсутствует; admission ≠
'W1A' (21 строка) — прежний путь B (демо-вход → кадр code),
Erstinformation/Start закрыты; Г0 (#FFFFFF, 48/16/16) наблюдается на
кадре email во всех строках и на кадре code в строках не-W1A — в обеих
темах, в т.ч. на экземпляре с ПОДКЛЮЧЁННЫМ портом при gate ≠ current
(блокер 2 круга 2). Переписывание ожиданий строк W1A×не-current с
«code» на «Erstinformation без Start» — нормативная корректировка к
frozen 118/1 (арбитраж, п.2): не ослабление — клетки остаются красными
на обходах migracija-gate-ignor, -stale-kak-current, -null-kak-current
(ловится Start, а не кадр).

КЛЕТКИ (а)–(д) (консолидация по арбитражу, п.1; шов — те же порты
PilotApp, вход entry — production-поле pilot-app.tsx :57):
- (а) ось `entry.onboarding` ∈ {'complete','unknown','incomplete',
  ∅} × решающие пары порта {W0/stale, W0/current, W1A/stale,
  W1A/current, порт не подключён} × 2 темы = 40 клеток
  MIGRACIYA_ENTRY_<ENTRY>_<ПАРА>_<ТЕМА> — ожидание клетки НЕ меняется
  относительно её пары (entry и его поле gate — не источник допуска);
  плюс клетка постороннего truthy-поля порта authenticated:true на
  W0/stale × 2 темы = 2 клетки MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_;
- (б) начальный кадр 'first-run' при ЛЮБОМ entry × любом порте пар —
  первый рендер без Start и без Erstinformation: 4 × 5 × 2 = 40 клеток
  MIGRACIYA_NACHALNYJ_KADR_<ENTRY>_<ПАРА>_<ТЕМА> + одна remount-клетка
  MIGRACIYA_REMOUNT_ENTRY_COMPLETE_W0_STALE (второе монтирование с
  сохранённым completed-entry — то же наблюдение);
- (в) Г0 F03.01/F03.02 после смены схемы в живом экземпляре (rerender
  провайдера темы) в ОБЕ стороны — dark→light и light→dark — на
  недопуске с ПОДКЛЮЧЁННЫМ портом: 2 клетки
  MIGRACIYA_G0_SMENA_TEMY_{DARK_TO_LIGHT,LIGHT_TO_DARK} (Г0 судится до
  смены, после смены на email и после демо на code);
- (г) смена схемы на Erstinformation БЕЗ нажатия continue → Start
  отсутствует (затем continue → Start — положительный контроль
  порядка): 2 клетки MIGRACIYA_PORYADOK_SMENA_TEMY_*;
- (д) порт читается в МОМЕНТ действия: rerender W1A→W0 до демо →
  недопуск, путь B: 2 клетки MIGRACIYA_RERENDER_W1A_W0_{DARK,LIGHT}.

Г0 при миграции (FAIL критика v3, блокер 2; круг 2 — класс): корни
F03.01/F03.02 наблюдаются на экземплярах с ПОДКЛЮЧЁННЫМ портом
onboarding при ЛЮБОМ недопуске (в т.ч. отклонённый/отсутствующий/null
gate — обход критика круга 2 new-g0-denied-admission рестайлил корень
именно при gate ≠ current) И при допуске, обе темы: подключение порта
и сам допуск НЕ рестайлят корень (литералы 995 #FFFFFF, 48/16/16);
поверхность кадров Erstinformation/Start — предмет 118, этими клетками
не судится.

Охрана — клетки-дельта MIGRACIYA_* + таблица MIGRACIYA_TABLICA_*
(перечень — «Закрытые перечни клеток») и стабы migracija-admission-
literal («admission обходится»), migracija-gate-ignor,
migracija-start-pryamo (порядок), migracija-f03-put-udalen («Г0
ослаблен»: прежний путь удалён миграцией) + стабы правки по FAIL
критика v3 круг 1: обходы критика migracija-admission-default,
migracija-gate-default, migracija-w0-stale-dopushchen,
migracija-svetlui-obhod, migracija-onboarding-restyles-f03; круг 2 —
ВСЕ мутанты критика (attack.py кругов 1–2): три зелёных обхода круга 2
migracija-light-gate-default (умолчание gate=current только в light),
migracija-pustaya-sessiya-demo (пустой подключённый порт {} — сам себе
допуск), migracija-g0-nedopusk-restail (рестайл корня при truthy порте
с gate ≠ current) + migracija-light-stale-current,
migracija-light-start-do-continue; собственные круга 1
migracija-marshrut-tolko-temnyi, migracija-stale-kak-current,
migracija-restyle-pri-dopuske и круга 2 migracija-null-kak-current,
migracija-or-uslovie (`||` в условии допуска),
migracija-port-est-dopusk (truthy порт без admission — W1A),
migracija-g0-restail-nedopusk-admission (Г0-рестайл при admission ≠
W1A), migracija-temnyi-start-do-continue (порядок маршрута в тёмной);
круг 3 (арбитраж нарезки) — семь r3-мутантов критика именованными
стабами на клетках (а)–(д): migracija-postoronnee-pole-authenticated
(постороннее truthy-поле порта), migracija-gate-iz-entry (gate из
entry.gate раньше сессии), migracija-literal-completed (литерал W1A при
completed-entry), migracija-kesh-dopuska (кэш admission — порт не
читается в момент действия), migracija-restart-start (начальный кадр
Start при completed-entry), migracija-g0-smena-temy (рестайл корня
после смены схемы), migracija-start-ot-smeny-temy (смена схемы сама
переводит в Start) — мутации перенесены с драйвера критика
(Critic117v3c/new_attack.py) по смыслу (привязка к ветвям — в
«Закрытых перечнях клеток», по коду MUTANTS пробы; привязки кругов
1–2 перечитаны замером под семантику frozen 118/1).

НЕ разрешено: ослабление приёмки 118; рестайл корня F03; изменение входа
(итог C ≡ B по `mobile/src/features/auth/` — приёмка v2); ослабление
инвариантов 1–9 v2 и их клеток; правка pilot-app ДО заморозки 117/3
(команда проверки тега — frozen 118 §Зависимость замороженного корня:
`git fetch origin --tags && git rev-parse --quiet --verify
refs/tags/frozen/contracts/117/3`). ЗОНА implementer 118 получает
`mobile/src/bootstrap/pilot-app.tsx` ПОСЛЕ замороженной 117/3; батарея
117 (обе пробы) на мигрировавшем C обязана оставаться зелёной во всех
клетках, стабы — красными на своих ветвях.


## Стабилизация кадра Splash 117 v4 (класс B: кадр после ухода оверлея)

Боль (измерено, живые прогоны job android-e2e workflow mobile за 24–26.10):
шаг 123 «сверка кадров с макетом» исполнен в 25 прогонах, красен на Splash
в 2 (8%): run 40086602775 (job 120865595589, 24.10 12:06) и run 40420737331
(job 121915134291, 26.10 23:45, PR #128) — оба раза
`KADR Splash dark 0.000 0.600 tagline NIZHE_POROGA` при зелёном
`Splash light 0.782 OK`; оба раза красна ПЕРВАЯ тема после загрузки
эмулятора. Повтор по сигнатуре 141 класс B НЕ ловит (провал сверки не
повторяется). Кадр dark класса B (sha256 2a5e31d6…) — First-Run под именем
splash; байты с кадром vkhod-117-first-run (fb59a3e3…) НЕ равны — содержимое
одно, снимки разные (статус-бар); свидетели припинены в source.json
replay_117.live.svideteli. Механизм (maestro.log run 40420737331):
удовлетворённый опрос видимости + задержка команды снимка (цикл опроса
730/701 мс, снимок 669 мс) ПЕРЕКРЫВАЮТ окно SPLASH_OVERLAY_MS=1200 —
кадр берётся после размонтирования оверлея. Закон реплея (грамматика —
живой формат Maestro: первый успешный опрос видимости не позже M+poll,
кадр — в конце команды снимка): кадр в окне оверлея при ЛЮБОЙ фазе опроса
⇔ HOLD > poll + shot. Зелёный run 40316137237: 615+678=1293 — на грани
окна 1200 (лотерея фазы опроса).

Frontier (варианты слова владельца 2026-10-27; выбор — (Г); вариант (В)
был принят в сдаче 784bd32c и ОТКЛОНЁН живой пробой):
- (А) порядок/тайминг сценария — ОТКАЗАН: снимок сразу после launchApp без
  ожидания ловит ДО-оверлейный кадр (нативный знак без tagline — сверка
  ниже порога той же клеткой), а между «ожидание удовлетворено» и «кадр
  взят» лежит неограниченная задержкой раннера дыра: перестановка шагов не
  даёт HOLD > poll + shot, снимок остаётся лотереей фазы опроса;
- (Б) рантайм-хук в продукте (флаг/файл/launch-аргумент: оверлей не
  размонтируется до подтверждения снимка) — ОТКАЗАН: требует нативного
  канала в release-сборку (intent-extra → native module) или файла в
  приватном хранилище; тест-хук вне шва сборки меняет прод-код;
- (В) env-удержание e2e-СБОРКИ — ОТКЛОНЁН ЖИВОЙ ПРОБОЙ run 40434807469 /
  job 121966561101 (одноразовая ветка cmp-mob-117/proba-v4 @ acba06b9cac8,
  патчи (В) 0001–0002 на голове #124 c617f6fb): сама цель достигнута —
  Splash dark 0.783 / light 0.782 OK, 995 native rc0, кадры 135 OK; НО
  шаг 118 красен детерминированно (после шагового повтора):
  `KADR F02.03-V01-V0 dark 0.000 0.600 wordmark NIZHE_POROGA` и light
  0.000 — на кадре splash-оверлей (свидетель
  erstinformation-f02-03-v01-v0.png dark/light, sha256 припинены в
  source.json replay_117.live.svideteli). Механизм: один e2e-APK на ВСЕ
  шаги CI ⇒ env-удержание глобально: оверлей 8000 мс закрывает первый
  кадр ЛЮБОГО сценария после холодного старта (замер commands.json 118
  пробы: конец launchApp → конец первого V0-кадра 7450 мс < 8000);
  остальные кадры 118, снятые после ухода оверлея, зелёные (V02-V0
  0.845/0.783);
- (Д) снимок ПЕРВЫМ после launchApp (до опроса) — ОТКЛОНЁН замером той же
  пробы (commands.json 117 dark/light): оверлей виден на кадре только
  через 1154–1854 мс ПОСЛЕ возврата launchApp (dark: launchApp 816 →
  ожидание 1854 → снимок 420; light: 1005 → 1542 → 277): «первый» кадр
  берётся ДО монтирования JS-оверлея — нативный знак без tagline, сверка
  ниже порога (та же причина, что у (А));
- (Г) ОТКЛОНЁН ЖИВОЙ ПРОБОЙ run 40497913252 / job 122172034122 (ветка
  cmp-mob-117/proba-v4g @ 6f10e2fc481d = голова #124 c617f6fb + патчи (Г)
  produktnye-izmenenija2, mobile.yml не менялся, раннер station-complior):
  механизм (тот же, что принял (Г′) ниже — launchApp{clearState} → stopApp
  → openLink → ожидание), но ссылка — host-форма complior://e2e-splash-hold.
  Живой результат: `995 native rc=1 testcases=7 failed=1` — упал ИМЕННО
  флоу 117 (`Assertion is false: id: splash-overlay is visible` после
  extendedWaitUntil visible splash-overlay timeout 15000); остальные 6 флоу
  (108, 995, first-run-ekran, 991, 995 start, 999) SUCCESS; шаги 123/135/118
  не исполнялись. Причина (код продукта + артефакты, файл:строка):
  expo-router ~57.0.28 (fork extractPathFromURL, node_modules продукта:
  путь = host + pathname, query в путь не входит) разбирает
  complior://e2e-splash-hold как ПУТЬ /e2e-splash-hold; одно-сегментный
  путь ловит динамический маршрут mobile/src/app/(tabs)/[section].tsx:
  pick('e2e-splash-hold') = null (сегмент вне TAB_ORDER start/vorgaenge/
  schutz/post, [section].tsx:62–65) ⇒ `if (!start) return null;`
  ([section].tsx:100) — маршрут рендерит ПУСТОТУ; файла +not-found в
  src/app НЕТ. Итог: index.tsx (PilotApp) НЕ монтируется ⇒
  SplashScreen.hideAsync() из effect PilotApp не вызван ⇒ нативный splash
  (expo-splash-screen, LAUNCH_SINGLE_TASK) висит НЕОГРАНИЧЕННО. Живые
  свидетели (припинены sha256 в source.json replay_117.live.svideteli,
  клетка REPLAY_LIVE_PROBA_G): maestro.log — launchApp 11:54:17.877 →
  stopApp .927 → openLink .972 → assert RUNNING 11:54:19.598 → FAILED
  11:54:34.814; logcat — `START {act=VIEW dat=complior://e2e-splash-hold/…
  cmp=com.complior.mobile/.MainActivity} with LAUNCH_SINGLE_TASK` (суффикс
  /… — платформенное сокращение Intent-лога; Maestro открывала литерал
  без слэша — maestro.log) и `ReactNativeJS: Running "main"` +0.6 с (JS
  запущен, ошибок ReactNativeJS нет); screen-hierarchy шага провала — в
  дереве приложения НЕТ узлов содержимого (единственный com.complior
  resource-id — системный каркас action_bar_root, splash-overlay
  отсутствует); кадр шага — НАТИВНЫЙ splash (только знак, светлая схема,
  без wordmark/tagline JS-оверлея).
- (Г′) ПРИНЯТ: тот же канал, но ссылка ведёт на СУЩЕСТВУЮЩИЙ маршрут —
  КОРЕНЬ «/», маркер удержания — в query: ЛИТЕРАЛ
  complior:///?e2e=splash-hold. Разбор (грамматика expo-router, тот же
  источник: host ПУСТ + pathname «/» + query e2e=splash-hold ⇒ путь
  «/»): mobile/src/app/index.tsx рендерит PilotApp БЕЗУСЛОВНО — при любом
  состоянии сессии (единственный такой маршрут: (tabs)/[section] рендерит
  PilotApp только на недопуске для сегмента из TAB_ORDER). Доставка
  байт-точна: Android Linking.getInitialURL() возвращает строку данных
  интента как есть (StringUri хранит оригинал; сокращение — только в
  логе), URL-сериализация литерала стабильна (замер: new URL href-roundtrip
  байт-в-байт, «/» не добавляется и не снимается; обе корневые формы
  complior://?… и complior:///?… дают ОДИН путь — неоднозначность формы
  на маршрут не влияет); живой канал host-формы подтверждён зелёными
  cmp-mob-002/004/108 (complior://start). pilot-app при ТОЧНОМ равенстве
  стартового URL литералу продлевает окно: clearTimeout(таймер 1200) →
  setTimeout(SPLASH_HOLD_E2E_MS 8000 ≥ hold_min 3500 = poll.max 1000 +
  shot.max 2400 + 100; запас 2.3× против замеренных 1370 мс). Прод-таймер
  1200 ставится СРАЗУ, без ожидания промиса: поведение любого старта с
  иным URL байт-идентично v3. Каналы живые (Maestro 2.11.0, пин в
  mobile.yml): launchApp{clearState} — 5 флоу продукта, stopApp —
  rehearsal.yaml, openLink complior://… — cmp-mob-002/004 (зелёные
  прогоны). Критерии допустимости (дополнение оркестратора 2026-10-27):
  (1) порог 0.6 и кадр Splash обеих тем не ослаблены/не удалены; (2)
  прочие сценарии/кадры НЕ меняются — единственный вход удержания литерал,
  который по ВСЕМУ mobile/.maestro открывает только сценарий 117 (клетка
  MAESTRO_HOLD_ALONE), чужие живые ссылки (complior://start) и старты без
  URL литералу не равны (клетки SPLASH_OVERLAY_HOLD_NE_INOJ_URL_*), ссылка
  несуществующего маршрута удержания не взводит и не монтирует (клетки
  SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_*, SPLASH_HOLD_LINK_ROUTE_MOUNT);
  посторонний кадр закрыт ⇔ удержание на ОБЩЕМ входе ∧ зазор < HOLD
  (клетка REPLAY_HOLD_SCENARIO_ONLY, живой свидетель — commands.json 118
  пробы, зазор 7450 мс); (3) один APK на все шаги допустим — вне литерала
  поведение байт-идентично прод (прод-таймер 1200 немедленно, клетки
  SPLASH_OVERLAY_TIMER_HIDE_*); (4) mobile.yml НЕ меняется — пин 139/2
  (f45c6823…) остаётся верным, ПЕРЕСЕЧЕНИЕ по env-ключу снято.

ЗОНА implementer: mobile/src/bootstrap/pilot-app.tsx mobile/.maestro/vkhod-117-splash-vhod.yaml
— v4-добавление к зоне 117/3 (обе строки — ОДНА ЗОНА-строка, совет
критика v4 круг 1: прежде вторая строка без префикса «ЗОНА» механически
не объявлялась; автор тот же implementer, НЕ новый токен):
в pilot-app — блок Linking-удержания (литерал + чтение стартового URL +
апгрейд таймера с очисткой; корни кадров, первый кадр и вход шва не
тронуты — пересечение с 111 описано выше); в сценарий — два шага ПЕРЕД
ожиданием оверлея (stopApp и openLink литерала, первое изменение сценария
с v3, прочие шаги байт-в-байт v3); .github/workflows/mobile.yml НЕ
трогается. Пин батареи .harness117 при freeze 117/4 перепинится на
замороженный SHA (прецедент 2026-10-21): замороженное дерево содержит
scripts/sverka_maketa.py, который вызывает клетка
SVERKA_123_CATCHES_CLASS_B (отсутствие — rc2 INFRASTRUCTURE, не зелень).

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
   `pilot.test` 995 и first_run_111 на модели с оверлеем — 14/14 и 23/23
   (замер v2; замер консолидации по арбитражу — те же 14/14 и 23/23).
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
10. Кадр `vkhod-117-splash` снимается, ПОКА splash-оверлей на экране (v4,
   класс B, канал (Г′)): сценарий 117 запускает ХОЛОДНЫЙ старт по
   ЛИТЕРАЛЬНОМУ deep link complior:///?e2e=splash-hold — КОРЕНЬ «/» +
   маркер в query (launchApp{clearState} → stopApp → openLink литерала →
   ожидание visible splash-overlay → снимок). Холодный старт — СОСТОЯНИЕ
   команд, НЕ их сумма (правка по FAIL критика v4 круг 1; признак запуска
   ЕДИНЫ до ссылки и на интервале — правка круга 3, классификатор
   _is_launching): запускают launchApp ЛЮБОЙ формы (словарь и скалярная
   строка), runFlow (любой — консервативно: живой start.yaml запускает
   приложение с clearState, разрешение вложенного flow вне статической
   пробы), openLink (любой); останавливает stopApp; openLink литерала —
   холодный старт ТОЛЬКО если
   непосредственно перед ним приложение остановлено (последняя
   запускающая/останавливающая команда = stopApp) и этот stopApp стоит
   ПОСЛЕ launchApp{clearState}, а между последним stopApp и openLink
   приложение не запускается снова; МЕЖДУ openLink литерала и первым
   ожиданием visible оверлея ЗАПУСКАЮЩЕГО шага НЕТ (launchApp любой
   формы, runFlow, иная ссылка ≠ литерала — арбитраж :213–218; правила
   круга 3; повторное открытие самого литерала судит
   SPLASH_HOLD_LINK_ROUTE_MOUNT по числу ссылок канала); клетки
   MAESTRO_HOLD_COLD_START (по
   yaml субъекта) и порождаемая раннером семья MAESTRO_HOLD_PORJADOK_*
   (2 перестановки, вставки до stopApp и на интервале, 2 удаления из
   набора живых команд {launchApp словарём и скаляром, stopApp, openLink,
   runFlow, extendedWaitUntil, takeScreenshot},
   оба обхода критика, честная цепочка и зелёные контроли арбитража —
   ожидания литералами ДО
   субъекта) судят порядок, реплей взводит окно удержания ТОЛЬКО
   холодным стартом (сумма команд окно не взводит); pilot-app на МОМЕНТ
   монтирования читает стартовый URL (Linking.getInitialURL) и при ТОЧНОМ
   равенстве литералу продлевает окно: таймер-литерал 1200 (инвариант 8,
   ставится немедленно) снимается clearTimeout'ом, ставится
   SPLASH_HOLD_E2E_MS 8000 (≥ hold_min 3500 из source.json replay_117 =
   poll.max 1000 + shot.max 2400 + 100), с очисткой в cleanup; старты с
   ЛЮБЫМ иным URL (включая живые complior://start и ссылку несуществующего
   маршрута complior://e2e-splash-hold) и без URL оставляют прод-таймер
   1200 — инвариант 8 действует дословно, старт с литералом — объявленное
   исключение v4 (удержание 8000, судят клетки SPLASH_OVERLAY_HOLD_LINK_*).
   Реплей подложного устройства судит ВСЕ точки сетки задержек (poll × shot
   из source.json replay_117): кадр в окне оверлея при любой фазе опроса;
   hold накрыт таймаутом notVisible кадра first-run; кадр после ухода
   оверлея краснеет сверкой 123 на живом свидетеле класса B (припинен
   sha256).
11. Удержание оверлея НЕ меняет НИКАКОЙ другой сценарий/кадр продукта
   (v4): проверяемые кадры — все прочие флоу CI (118 Erstinformation,
   включая F02.03-V01-V0 первый кадр после старта, 135 First-Run, 108,
   995, 991, 999); свидетель — живой артефакт пробы 40434807469 как
   носитель: пины sha256 кадра erstinformation-f02-03-v01-v0.png dark
   (d5975e864012ca4e201305a6b70d856c4dd2a68a4e35c15323e3e18e9f77c961) и
   light (6629b5d19295397e47f6d1952e179714a1cd6b4c0487278160ddbc062eb6823f)
   и commands.json шага 118 (замеренный зазор: конец launchApp → конец
   первого V0-кадра 7450 мс). Закон: посторонний кадр закрыт оверлеем ⇔
   удержание взведено на ОБЩЕМ входе (env сборки) ∧ зазор < HOLD; честная
   модель (Г′) на запуске без литерала удержание НЕ взводит — прочие кадры
   118 той же пробы зелёные (V02-V0 0.845/0.783). Судят клетки
   REPLAY_HOLD_SCENARIO_ONLY (живой носитель + env-взвод субъекта),
   MAESTRO_HOLD_ALONE (литерал открывает только сценарий 117 по ВСЕМУ
   mobile/.maestro) и SPLASH_OVERLAY_HOLD_NE_INOJ_URL_{DARK,LIGHT} (чужая
   живая ссылка не взводит); стаб-контрпример канала (В) —
   splash-hold-env-vmesto-link.

12. Канал удержания ведёт на СУЩЕСТВУЮЩИЙ маршрут; JS-дерево PilotApp
   монтируется; hideAsync вызывается — иначе нативный splash залипает (v4
   (Г′), живой провал пробы (Г) run 40497913252: host-ссылка
   complior://e2e-splash-hold → путь /e2e-splash-hold → динамический
   (tabs)/[section].tsx рендерит null ([section].tsx:62–65,100) → PilotApp
   не монтирован → hideAsync не вызван → нативный splash 15 с, флоу 117
   красен). Грамматика канала (source.json replay_117.hold_link_grammar):
   scheme complior + ПУСТОЙ host + путь «/» + маркер в query
   (e2e=splash-hold); извлечение пути — по грамматике expo-router ~57.0.28
   (путь = host + pathname до «?», fork extractPathFromURL node_modules
   продукта); корень «/» — единственный маршрут, монтирующий PilotApp
   (index.tsx) БЕЗУСЛОВНО, при любом состоянии сессии (route_facts
   source.json; файл +not-found в src/app отсутствует). Судят клетки
   SPLASH_HOLD_LINK_ROUTE_MOUNT (сценарий открывает РОВНО литерал оракула,
   expo-путь ПУСТ; host-форма = несуществующий маршрут), REPLAY_SPLASH_
   WHILE_OVERLAY (реплей: нерамочный старт — оверлей НЕ монтируется,
   исход NO_PILOT на всей сетке; судьбу старта решает ПОСЛЕДНЯЯ
   complior-ссылка сценария, старт без ссылки — лаунчерный, корень),
   SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_{DARK,LIGHT} (URL несуществующего
   маршрута удержания НЕ взводит — прод-таймер 1200) и REPLAY_LIVE_
   PROBA_G (живые свидетели провала (Г): кадр нативного splash +
   hierarchy json без узлов содержимого + logcat-фрагмент «START VIEW
   dat=… + Running "main"», sha256 припинены; носитель
   субъект-независим); стаб-контрпример — splash-hold-link-na-marshrut
   (host-форма в обеих копиях литерала — дефект пробы (Г) дословно).

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
185 клеток — замер консолидации по арбитражу нарезки `behavioral
185/185`: 26 клеток 117/2 + 4 клетки геометрии/z-порядка кругов
Adv117v2/v3 по реализации + 4 клетки миграции v3 + 10 клеток правки по
FAIL критика v3 круг 1 + 52 клетки ТАБЛИЦЫ ВХОДОВ круга 2 + 89 клеток
круга 3 (а)–(д): 40 оси entry + 2 постороннего поля + 40 начального
кадра + 1 remount + 2 Г0-смены темы + 2 порядка + 2 rerender; прежние
96 поимённо сохранены — мера разбора исходника: removed=[], added=89;
ожидания клеток W1A×не-current (4 именованные + 8 табличных)
переписаны с «code» на «Erstinformation без Start» — нормативная
корректировка к frozen 118/1 по арбитражу, не ослабление):
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
- (117 v3, миграция) `MIGRACIYA_W0_CURRENT_PREZHNIJ_PUT` — не-W1A:
  демо-вход ведёт прежним путём B (кадр code F03.02, auth-code
  достижим), кадры Erstinformation/Start не возникают;
  `MIGRACIYA_W1A_NULL_PREZHNIJ_PUT`, `MIGRACIYA_W1A_STALE_PREZHNIJ_PUT`
  — W1A × не-current (консолидация по арбитражу): демо-вход ведёт в
  Erstinformation с маркером gate, Start закрыт до и после нажатия
  continue (переход не происходит), кадр code не возникает;
  `MIGRACIYA_W1A_CURRENT_MARSHRUT` — при W1A ∧ current: First-Run →
  F03.01 (прежний вход жив) → демо → Erstinformation (continue) →
  Start (start_tabs + четыре вкладки testID приёмки 118), порядок
  наблюдаем последовательными шагами, прежний код-кадр покинут.
  Допуск — порт onboarding (внешняя сессия), оси W0/W1A ×
  null/stale/current.
- (правка по FAIL критика v3) непокрытые входы допуска:
  `MIGRACIYA_ADMISSION_OTSUT_CURRENT_PREZHNIJ_PUT` (сессия
  {gate:'current'} без admission) — отсутствие OPTIONAL-поля НЕ
  поверхность: прежний путь B;
  `MIGRACIYA_W1A_GATE_OTSUT_PREZHNIJ_PUT`
  ({admission:'W1A'} без gate) — Erstinformation с маркером 'null',
  Start закрыт, continue не переводит;
  `MIGRACIYA_W0_STALE_PREZHNIJ_PUT` (сочетание W0×stale) — прежний
  путь, Erstinformation/Start закрыты;
  `MIGRACIYA_W1A_STALE_SVETLAYA_PREZHNIJ_PUT` — Erstinformation без
  Start в светлой теме (недопуск к Start не зависит от схемы;
  поверхность решает admission);
  `MIGRACIYA_W0_NULL_SVETLAYA_PREZHNIJ_PUT` (светлая тема — не
  поверхность) — прежний путь, Erstinformation/Start закрыты;
  `MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT` — W1A ∧ current открывает
  маршрут и в светлой теме (тема — не ось допуска);
  `MIGRACIYA_G0_F03_ONBOARDING_{DARK,LIGHT}` ×2 — Г0 на экземпляре с
  ПОДКЛЮЧЁННЫМ onboarding (недопуск): корни F03.01 И F03.02 #FFFFFF
  48/16/16; `MIGRACIYA_G0_F03_DOPUSK_{DARK,LIGHT}` ×2 — Г0 при допуске:
  кадр email (продолжение из First-Run) остаётся поверхностью 995.

- (правка по FAIL критика v3 КРУГ 2) ТАБЛИЦА ВХОДОВ —
  `MIGRACIYA_TABLICA_<ФОРМА>_<ADMISSION>_<GATE>_<ТЕМА>` ×52: все
  выразимые строки порта onboarding (26 строк × 2 темы; счёт — из
  таблицы кодом, сверка прогона/разбора — приёмка): формы
  NEPODKLYUCHEN (проп undefined) и PUSTOJ (подключённый `{}`; обход
  критика круга 2 new-empty-session-demo — истина порта ≠ допуску) ×
  OTSUT/OTSUT; CHASTICHNYJ — ровно одно поле: admission
  {W0, W1A, NULL, NEIZVESTNOE('W2')} × OTSUT и gate {CURRENT, STALE,
  NULL, NEIZVESTNOE('future')} × OTSUT (8 строк); POLNYJ — оба поля,
  4×4=16 строк. Каждая клетка судит СВОЮ строку (консолидация по
  арбитражу): admission 'W1A' → Erstinformation с маркером gate и Г0
  кадра email; переход continue → Start ТОЛЬКО POLNYJ/W1A/CURRENT, в
  прочих W1A-строках (4 строки: CHASTICHNYJ/W1A/OTSUT и POLNYJ/W1A/
  {STALE,NULL,NEIZVESTNOE}) continue НЕ переводит, Start отсутствует,
  кадр code не возникает; admission ≠ 'W1A' (21 строка) — прежний
  путь B (демо-вход → код-кадр), Erstinformation/Start закрыты. Г0
  (#FFFFFF 48/16/16) — кадр email во всех строках, кадр code в
  не-W1A строках, в своей теме — недопуск наблюдаем на любом входе
  таблицы, рестайл отклонённого gate (обход критика круга 2
  new-g0-denied-admission) — строками с gate ≠ current в обеих темах.

- (круг 3, арбитраж нарезки) КЛЕТКИ (а)–(д) — перечень и счёт в
  разделе «Миграция 117 v3» (40 MIGRACIYA_ENTRY_* + 2
  MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED_* + 40
  MIGRACIYA_NACHALNYJ_KADR_* + 1 MIGRACIYA_REMOUNT_ENTRY_COMPLETE_
  W0_STALE + 2 MIGRACIYA_G0_SMENA_TEMY_* + 2
  MIGRACIYA_PORYADOK_SMENA_TEMY_* + 2 MIGRACIYA_RERENDER_W1A_W0_* =
  89): вход entry (в т.ч. поле onboarding 'complete' и постороннее
  поле gate='current' у каждого входа оси) и постороннее поле порта
  НЕ создают допуск/поверхность; начальный кадр — first-run при любом
  entry/порте и при remount; Г0 живёт после смены схемы в живом
  экземпляре (обе стороны, подключённый порт, недопуск); смена темы
  на Erstinformation не даёт Start без continue; порт читается в
  момент действия (rerender W1A→W0 до демо — недопуск).

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

Семья 117 v4 (класс B, канал (Г′); замер — прогон на R@B с node_modules,
ветка wip/117/architect-v4; пересмотры по живым пробам run 40434807469 и
40497913252; правки по FAIL критика v4 кругов 1 и 3): статическая +27 = 70
(43 v3 байт-неизменны +
REPLAY_ORACLE_CONSISTENT — канон source.json replay_117: hold_min =
poll.max + shot.max + 100, hold_e2e ≥ hold_min, hold_default =
overlay_117.hide_after_ms, hold_link начинается complior:// и НЕ входит в
other_live_links, (Г′) литерал соответствует грамматике канала
hold_link_grammar (scheme + ПУСТОЙ host + путь «/» + маркер в query) и
извлекается как ПУСТОЙ путь; MAESTRO_HOLD_COLD_START — сценарий запускает
холодный старт каналом ПО СОСТОЯНИЮ команд (правка FAIL круг 1: прежде —
суммой «есть где-то clearState и где-то stopApp», оба обхода критика
проходили): состояние «приложение запущено» отслеживается по
последовательности (запускают — ЕДИНЫЙ классификатор _is_launching
(правка круга 3, единый источник до ссылки и на интервале): launchApp
любой формы — словарь и скалярная строка, runFlow — любой консервативно,
openLink — любой; stopApp — останавливает; до первой команды fail-closed
«запущено»), openLink(литерал) — холодный старт ТОЛЬКО если
непосредственно перед ним приложение остановлено (последняя
запускающая/останавливающая команда = stopApp), этот stopApp стоит ПОСЛЕ
launchApp{clearState} и между ними нет запуска; ожидание visible
splash-overlay — ПЕРВОЕ ПОСЛЕ openLink, между ними НЕТ ЗАПУСКАЮЩЕГО шага
(правка круга 3: launchApp любой формы, runFlow, иная ссылка ≠ литерала;
повторный openLink литерала судит SPLASH_HOLD_LINK_ROUTE_MOUNT по числу
ссылок канала); плюс
ПОРОЖДАЕМАЯ раннером семья порядка MAESTRO_HOLD_PORJADOK_* ×15
(CHESTNAJA — честная цепочка зелёна; RELAUNCH_PERED_LINK и
STOP_PERED_LAUNCHOM — оба обхода критика; PERESTANOVKA_LINK_RANSHE_STOPA,
PERESTANOVKA_WAIT_RANSHE_LINKA — 2 перестановки; VSTAVKA_ZAPUSK_BEZ_CLEAR,
VSTAVKA_DRUGOJ_SSYLKI, VSTAVKA_WAIT_DO_STOPA — 3 вставки до ссылки
(последняя — цепочка критика круга 2: добавочное НЕ запускающее ожидание
visible до stopApp, ЗЕЛЕНА по арбитражу 117 v4 — ожидание судится ПЕРВЫМ
ПОСЛЕ openLink); VSTAVKA_RUNFLOW_MEZHDU, VSTAVKA_LAUNCH_SKALJAR_MEZHDU,
VSTAVKA_LAUNCH_SLOVAR_MEZHDU, VSTAVKA_DRUGOJ_SSYLKI_MEZHDU — 4 красных
КЛАССА запускающего шага МЕЖДУ hold-ссылкой и ожиданием (правка круга 3
по вердикту krug3: живые формы — runFlow start.yaml, скалярный
«- launchApp» (mobile/.maestro/erstinformation.yaml:4), launchApp-словарь,
иная живая ссылка complior://start; прежний интервальный предикат видел
только launchApp-словарь — ложная зелень static 65/65 rc0) и
VSTAVKA_SNIMOK_MEZHDU — зелёный контроль НЕ запускающего шага в том же
интервале (арбитраж путь (А); класс покрывает зелёность
assertVisible/notVisible/снимка между ссылкой и ожиданием);
UDALENIE_STOPA, UDALENIE_LAUNCHA — 2
удаления; входы синтетические из набора живых команд {launchApp словарём
и скаляром, stopApp, openLink, runFlow, extendedWaitUntil, takeScreenshot},
субъект не читается,
ожидания — литералы до субъекта — клетки судят саму проверку порядка);
MAESTRO_HOLD_ALONE — openLink с
литералом по ВСЕМУ mobile/.maestro встречается ровно в сценарии 117;
SPLASH_HOLD_LINK_CHANNEL — pilot-app несёт канал: Linking.getInitialURL() +
точное равенство литералу + апгрейд таймера clearTimeout/setTimeout;
SPLASH_HOLD_NO_ENV — канал (В) отсутствует и в pilot-app, и в workflow
(имя env не встречается; неразборчивое значение — fail-closed);
SPLASH_HOLD_LINK_ROUTE_MOUNT — (Г′) класс входов ссылки: сценарий открывает
РОВНО литерал оракула, и его expo-router путь (host+pathname до «?»,
грамматика fork extractPathFromURL ~57.0.28 из node_modules продукта) ПУСТ
— корень «/», единственный маршрут, монтирующий PilotApp безусловно
(route_facts source.json; host-форма — путь /<host>, динамический
(tabs)/[section] рендерит null для сегмента вне TAB_ORDER, [section].tsx:
62–65,100); REPLAY_SPLASH_WHILE_OVERLAY — реплей ВСЕЙ сетки poll {250,500,
700,1000} × shot {0,200,400,600,670,800,1000,1200,1400,1600,2000,2400} мс
с эффективным HOLD субъекта (env взведён → судится env, fail-closed; иначе
канал ∧ холодный старт сценария ПО СОСТОЯНИЮ команд — сумма команд окно НЕ
взводит, оба обхода критика дают CLASS_B; иначе прод-литерал) и монтированием
дерева (судьбу старта решает ПОСЛЕДНЯЯ complior-ссылка сценария: её expo-
путь непуст ⇒ PilotApp не монтируется, исход NO_PILOT на всей сетке —
живой факт пробы (Г); корневая ссылка и старт без ссылки — монтируется):
каждая точка даёт кадр в окне оверлея; снимок без ожидания (UNBOUND),
после notVisible (CLASS_B), отсутствующий (NO_SHOT) или нерамочный старт
(NO_PILOT) красны именованными исходами; REPLAY_HOLD_FITS_WAIT_TIMEOUT —
hold накрыт таймаутом notVisible кадра first-run по каждому poll сетки;
REPLAY_LIVE_CARRIER — живой носитель: продуктовый сценарий @ ba5ebbc927 и
commands.json класса B припинены sha256, реплей видит класс B на живой
проводке (замеренная пара poll 700 + shot 670 ≥ 1200), шаги живого
сценария отображаются в команды живого commands.json (грамматика реплея —
не придуманный диалект); REPLAY_HOLD_SCENARIO_ONLY — удержание ТОЛЬКО в
сценарии 117: живой commands.json шага 118 пробы 40434807469 (sha256,
замеренный зазор V0 7450 мс — оракул): без openLink, env-взвод субъекта на
ОБЩЕМ входе при зазоре < HOLD красен (дефект пробы (В): 0.000 обе темы),
честная (Г′) зелена; REPLAY_LIVE_PROBA_G — (Г′) живые свидетели провала
пробы (Г) run 40497913252/job 122172034122 (носитель субъект-независим):
кадр нативного splash, hierarchy json шага провала (единственный
com.complior resource-id — системный каркас action_bar_root,
splash-overlay отсутствует — PilotApp не монтирован) и logcat-фрагмент
(START VIEW dat=complior://e2e-splash-hold… + cmp=…MainActivity +
LAUNCH_SINGLE_TASK + Running "main" — ссылка доставлена, JS запущен),
sha256 припинены; SVERKA_123_CATCHES_CLASS_B — НАСТОЯЩАЯ sverka_maketa.py
на живых кадрах: класс B (run 40420737331, dark) → rc1 NIZHE_POROGA 0.000
худший tagline, светлей контроль OK 0.782; зелёный кадр (run 40316137237,
dark) → rc0 0.783/0.782 — ожидания в source.json replay_117.live.
sverka_{bad,ok}, сняты прогоном ДО правки субъекта). Замена против сдачи
784bd32c (материал (В), не заморожен): SPLASH_HOLD_E2E_ENV удалена
(env-канал отклонён живой пробой), вместо неё SPLASH_HOLD_LINK_CHANNEL +
SPLASH_HOLD_NO_ENV; добавлены MAESTRO_HOLD_COLD_START, MAESTRO_HOLD_ALONE,
REPLAY_HOLD_SCENARIO_ONLY; против сдачи 2bdd4106 (материал (Г), не
заморожен): добавлены SPLASH_HOLD_LINK_ROUTE_MOUNT + REPLAY_LIVE_PROBA_G,
REPLAY_ORACLE_CONSISTENT/REPLAY_SPLASH_WHILE_OVERLAY расширены
(грамматика/NO_PILOT), литерал hold_link сменён на корневой. Правка по FAIL
критика v4 круг 1: предикат MAESTRO_HOLD_COLD_START заменён суммарный →
состояние (имя клетки прежнее, замена объявлена), добавлена порождаемая
семья MAESTRO_HOLD_PORJADOK_* ×9 → ×10 (арбитраж 117 v4 круг 2: ожидание
судится ПЕРВЫМ ПОСЛЕ openLink, +VSTAVKA_WAIT_DO_STOPA) → ×15 (правка
круга 3 по вердикту krug3: ЕДИНЫЙ классификатор _is_launching до ссылки и
на интервале — запуск через runFlow/скалярный launchApp/словарный
launchApp/иную ссылку между hold-ссылкой и ожиданием КРАСНЕТ (прежде —
ложная зелень static 65/65 rc0), +4 красных класса интервала
+VSTAVKA_SNIMOK_MEZHDU зелёный контроль; статика 65 → 70, статические
стабы 51 → 52). Клетка (б)
SVERKA_123_CATCHES_CLASS_B байт-неизменна (функция не тронута).
Поведенческая +6 = 191 (185 v3 байт-неизменны +
SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT}: старт с литералом — оверлей на
месте после 1200 мс и скрыт на 8000-й; SPLASH_OVERLAY_HOLD_NE_INOJ_URL_
{DARK,LIGHT}: живая чужая ссылка complior://start — скрытие ровно на
1200-й; SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_{DARK,LIGHT}: URL несуществующего
маршрута complior://e2e-splash-hold (дефект пробы (Г)) — скрытие ровно на
1200-й, удержание НЕ взводит; прод-литерал не сдвинут — TIMER_HIDE зелены
без ссылки). Замена против 784bd32c: SPLASH_OVERLAY_HOLD_E2E_{DARK,LIGHT}
→ HOLD_LINK + HOLD_NE_INOJ_URL; против 2bdd4106: + HOLD_NE_NEMARSHRUT ×2.
Свидетели live/ (12 файлов, sha256 — source.json replay_117.live.svideteli):
кадры класса B/OK прогонов 40420737331/40316137237, продуктовый сценарий @
ba5ebbc9279bcde0b5a3c168bdc98eef24969a4c, commands.json класса B, а от
пробы 40434807469 — commands.json 117 (dark), commands.json 118 (dark) и
кадры erstinformation-f02-03-v01-v0.png dark/light, и от пробы 40497913252
(провал (Г)) — proba117g-kadr-native-splash.png,
proba117g-hierarchy-step006.json, proba117g-logcat-fragment.txt; подмена
свидетеля/пина — rc2 ORACLE_TAMPERED (полный обход всех пинов — перед
клеткой (б)).

Стабы v4 (привязка к ветвям по коду MUTANTS, Н-39): статические +14 = 52
(38 v3 байт-неизменны + splash-hold-link-otsutstvuet — блок удержания
удалён из pilot-app: SPLASH_HOLD_LINK_CHANNEL + REPLAY_SPLASH_WHILE_OVERLAY
(окно = прод-литерал 1200, сетка красна CLASS_B); splash-hold-link-oslablen
— SPLASH_HOLD_E2E_MS 2000 < hold_min 3500: REPLAY_SPLASH_WHILE_OVERLAY;
splash-hold-sverh-timeout-a — 13000: REPLAY_HOLD_FITS_WAIT_TIMEOUT;
splash-hold-env-vmesto-link — канал (В) вместо (Г′) (env в pilot-app +
строка env шага сборки в workflow): SPLASH_HOLD_LINK_CHANNEL +
SPLASH_HOLD_NO_ENV + REPLAY_HOLD_SCENARIO_ONLY — красная клетка на дефект
живой пробы (удержание ВНЕ сценария 117 закрывает кадр 118 V0, зазор
7450 мс < 8000); splash-hold-link-na-marshrut — (Г′) дефект живой пробы
(Г) run 40497913252 дословно: host-форма complior://e2e-splash-hold в ОБЕИХ
копиях литерала (сценарий и pilot-app) — несуществующий маршрут: named
SPLASH_HOLD_LINK_ROUTE_MOUNT + REPLAY_SPLASH_WHILE_OVERLAY (реплей видит
NO_PILOT: PilotApp не монтируется, оверлей не появляется), depends
SPLASH_HOLD_LINK_CHANNEL + MAESTRO_HOLD_COLD_START + MAESTRO_HOLD_ALONE
(замер матрицы: канонический литерал исчез из субъекта — те же клетки
красны, как живой флоу 117 красен целиком); splash-hold-vse-ssylki —
префикс complior:// вместо ТОЧНОГО литерала (живые complior://start
взводят): SPLASH_HOLD_LINK_CHANNEL, depends REPLAY_SPLASH_WHILE_OVERLAY
(замер матрицы: канал текстово не точен — эффективное окно судится
fail-closed прод-литералом); splash-hold-start-launchapp — stopApp/openLink
удалены из сценария (старт не по литералу, окно = прод-литерал):
MAESTRO_HOLD_COLD_START + REPLAY_SPLASH_WHILE_OVERLAY, depends
MAESTRO_HOLD_ALONE + SPLASH_HOLD_LINK_ROUTE_MOUNT (замер матрицы: литерала
нет нигде — носителей и ссылки канала пусто); splash-hold-start-ne-
holodnyj — launchApp ПОСЛЕ openLink (старт не холодный): MAESTRO_HOLD_
COLD_START, depends REPLAY_SPLASH_WHILE_OVERLAY; (правка FAIL критика
v4 круг 1, оба обхода блокера дословно) splash-hold-relaunch-pered-link —
второй launchApp{clearState} МЕЖДУ stopApp и openLink (приложение
работает до открытия ссылки — стартовый URL не читается при монтировании):
MAESTRO_HOLD_COLD_START, depends REPLAY_SPLASH_WHILE_OVERLAY (замер
матрицы: старт не холодный — окно судится прод-литералом 1200, сетка
красна CLASS_B); splash-hold-porjadok-stop-launch — перестановка stopApp →
launchApp{clearState} → openLink (к ссылке приложение запущено, стоп не
после очистки; прежде статика 55/55 И поведение 191/191 зелёные):
MAESTRO_HOLD_COLD_START, depends REPLAY_SPLASH_WHILE_OVERLAY (тот же
замер); (правка FAIL критика v4 круг 3) splash-hold-runflow-posle-link —
запуск через runFlow МЕЖДУ openLink литерала и ожиданием (живой
mobile/.maestro/start.yaml:4–7 запускает приложение с clearState —
повторный старт не читает стартовый URL при монтировании; старый
интервальный предикат «только launchApp-словарь» этот вход не замечал —
статика была ЛОЖНО зелёной rc0, вердикт krug3): MAESTRO_HOLD_COLD_START,
depends REPLAY_SPLASH_WHILE_OVERLAY (старт не холодный — окно судится
прод-литералом 1200, сетка красна CLASS_B); ОДИН стаб на КЛАСС запуска
на интервале — все формы идут через ту же ветвь _is_launching
(синтетически судят клетки VSTAVKA_RUNFLOW_MEZHDU /
VSTAVKA_LAUNCH_SKALJAR_MEZHDU / VSTAVKA_LAUNCH_SLOVAR_MEZHDU /
VSTAVKA_DRUGOJ_SSYLKI_MEZHDU, по Н-39 отдельных стабов на мутации формы
не плодим); splash-replay-snimok-
posle-uhoda — снимок после notVisible: REPLAY_SPLASH_WHILE_OVERLAY +
MAESTRO_SPLASH_FRAME_WAIT; splash-kadr-udalen — снимок удалён:
REPLAY_SPLASH_WHILE_OVERLAY + MAESTRO_SPLASH_FRAME_WAIT +
SPLASH_FRAME_SVERKA_123_{DARK,LIGHT}, depends MAESTRO_FIRST_RUN_ORDER;
splash-porog-oslablen — сверка подключена к подложному манифесту:
SVERKA_123_MANIFEST_CANON — порог живёт в манифесте H пина .harness123,
ослабление в субъекте возможно только проводкой, и оно красно) и
поведенческие +4 = 64 (60 v3 байт-неизменны + splash-hold-link-invertirovan
— условие инвертировано (удержание на ВСЕХ URL, кроме литерала):
SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT} + SPLASH_OVERLAY_HOLD_NE_INOJ_URL_
{DARK,LIGHT}, depends SPLASH_OVERLAY_TIMER_HIDE ×2 + STATUS_BAR_STYLE ×2
(замер матрицы: старт БЕЗ URL тоже удержан — прод-таймер не срабатывает);
splash-hold-po-umolchaniju-8000 — прод-литерал сдвинут хуком
(SPLASH_OVERLAY_MS 8000): SPLASH_OVERLAY_TIMER_HIDE_{DARK,LIGHT}, depends
STATUS_BAR_STYLE_{DARK,LIGHT} + SPLASH_OVERLAY_HOLD_NE_INOJ_URL ×2 (при
8000 и чужой старт удерживает); splash-hold-vse-ssylki — префикс вместо
литерала: SPLASH_OVERLAY_HOLD_NE_INOJ_URL_{DARK,LIGHT}; замена
undefined-safe — (initialUrl || ''): иначе «undefined.startsWith» —
TypeError валит посторонние клетки (замер матрицы); splash-hold-
taymer-bez-clear — апгрейд не снимает прод-таймер (оба живы, скрытие на
1200-й): SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT}; depends-расширения
поведенческих стабов под новые клетки NEMARSHRUT — замером матрицы).
Замена против 784bd32c (материал (В), не заморожен): стабы
splash-hold-env-otsutstvuet, splash-hold-env-oslablen (статические) и
splash-hold-env-v-pilote-ignoriruetsja (поведенческий) удалены — их дефекты
существовали только у канала (В); depends стаба
splash-hold-po-umolchaniju-8000 переименован с HOLD_E2E ×2 на
HOLD_NE_INOJ_URL ×2. Против сдачи 2bdd4106 (материал (Г), не заморожен):
добавлен splash-hold-link-na-marshrut; якоря литерала
splash-hold-start-launchapp/start-ne-holodnyj следуют за корневым
литералом модели. Отступления от байт-неизменности материала 117/3,
объявленные и минимальные: (1) якорная строка трёх стабов
overlay-hideasync-skip / overlay-hideasync-module-scope /
overlay-hide-before-commit следует за байтом честной модели ('    const
timer' → '    let timer' — модель (Г′) переприсваивает таймер при
апгрейде), именованные ветви и семантика мутаций не тронуты; (2) перечни
наблюдаемых ветвей расширены замером матрицы: шесть maestro-стабов
(no-wait, wait-commented, wait-after-shot, first-run-as-splash,
overlay-gone-before-shot — исход UNBOUND/CLASS_B; shot-renamed — NO_SHOT;
все + REPLAY_SPLASH_WHILE_OVERLAY в depends — прецедент правки v3 круга 1;
no-wait, wait-commented и first-run-as-splash дополнительно + MAESTRO_HOLD_
COLD_START — замер матрицы: без шага visible splash-overlay цепочка канала
рвётся) и три overlay-стаба (overlay-absent-first-commit — оверлей не
смонтирован на старте; overlay-timer-none — таймер 120000, оверлей не
скрыт к 8000; overlay-display-none — display:none: все три делают окно
удержания ненаблюдаемым → + SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT} +
SPLASH_OVERLAY_HOLD_NE_INOJ_URL_{DARK,LIGHT} в depends; в сдаче 784bd32c
там стояли HOLD_E2E ×2 — замена материала (В); замер матрицы (Г′): те же
три стаба дополнительно + SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_{DARK,LIGHT}
в depends — окно удержания ненаблюдаемо и на клетке несуществующего
маршрута).

Обманные стабы (привязка к ветвям — ТОЛЬКО по коду MUTANTS проб, Н-39;
depends измерены прогонами; поведенческая матрица консолидации по
арбитражу — rc0 на R@B, 60 стабов, все красны именованными ветвями;
прежние замеры 35/43/53 стабов кругов v3/1/2 сохранены — removed=[];
статическая матрица — rc0 на R@B, семью правка не меняет):
поведенческих 60 — 24 из 117/2 + 7 кругов Adv117v2/v3 (списки те же,
побайтово) + 4 миграции v3 + 8 правки круга 1 + 5+5 круга 2 (имена
те же) + 7 круга 3 (r3-мутанты критика). Привязки миграционных
стабов перечитаны замером под семантику frozen 118/1 (обходы
admission ловятся КАДРОМ — Erstinformation у недопущенного, обходы
gate — START'ом на Erstinformation-клетках; арбитраж: «там ловится
Start, а не кадр»):
- migracija-admission-literal — named клетки недопуска по admission
  (W0_CURRENT, ADMISSION_OTSUT_CURRENT, W0_STALE, W0_NULL_SVETLAYA) +
  все 21 строка admission ≠ W1A ×2 + entry-клетки не-W1A пар (24) +
  постороннее поле ×2 + Г0-смена ×2 + rerender ×2; depends Г0
  ONBOARDING ×2 и Г0–Г3 ×8 (замер: демо уводится в Erstinformation —
  код-кадр и кадры 995 недостижимы демо-входом);
- migracija-gate-ignor (переход без gate) — named 4 клетки
  W1A×не-current + 4 строки таблицы W1A×не-current ×2 + entry-клетки
  W1A_STALE ×8;
- migracija-start-pryamo — named обе MARSHRUT + все 5 строк W1A ×2 +
  4 клетки W1A×не-current + entry W1A-пары ×16 + порядок ×2;
- migracija-f03-put-udalen — named 4 миграционные клетки; depends
  Г0–Г3 ×8, 10 клеток круга 1, Г0 ONBOARDING/DOPUSK ×4, ВСЕ 52 клетки
  таблицы, ВСЕ 40 entry + 2 постороннего поля + Г0-смена ×2 + порядок
  ×2 + rerender ×2 (auth-email недостижим; клетки начального
  кадра/remount зелены — First-Run наблюдаем и при мутанте);
- migracija-admission-default — named ADMISSION_OTSUT_CURRENT + все
  11 строк admission {OTSUT, NULL} ×2 + entry-клетки пары без порта;
- migracija-gate-default — named W1A_GATE_OTSUT + строки
  {CHASTICHNYJ/W1A/OTSUT, POLNYJ/W1A/NULL} ×2 (Start при умолчании);
- migracija-w0-stale-dopushchen (поверхность) — named W0_STALE +
  строки {POLNYJ/W0/STALE, CHASTICHNYJ/OTSUT/STALE, POLNYJ/NULL/STALE}
  ×2 + entry-клетки пары W0_STALE ×8 + постороннее поле ×2 + Г0-смена
  ×2 (замер: тот же вход W0×stale несут и новые клетки круга 3);
- migracija-svetlui-obhod (поверхность и переход в light) — named
  W0_NULL_SVETLAYA + RERENDER_W1A_W0_LIGHT + Г0-смена LIGHT_TO_DARK +
  постороннее поле LIGHT + 20 truthy-строк недопуска с admission ≠ W1A
  в LIGHT + entry W0-пары в LIGHT ×8 (замер: тот же класс — truthy
  недопущенный порт в light; W1A-строки честны поверхностью, Start по
  gate); depends Г0 ONBOARDING_LIGHT;
- migracija-onboarding-restyles-f03 — named Г0 ONBOARDING ×2 + все 25
  truthy-строк ×2 (50) + Г0-смена ×2; depends Г0 DOPUSK ×2;
- migracija-marshrut-tolko-temnyi — named SVETLAYA_MARSHRUT +
  W1A_STALE_SVETLAYA + все 5 строк W1A в LIGHT + entry W1A-пары в
  LIGHT ×8 + порядок LIGHT_TO_DARK (светлая лишается поверхности);
- migracija-stale-kak-current (переход) — named W1A_STALE +
  W1A_STALE_SVETLAYA + POLNYJ/W1A/STALE ×2 + entry W1A_STALE ×8;
- migracija-restyle-pri-dopuske — named Г0 DOPUSK ×2 + строки допуска
  POLNYJ/W1A/CURRENT ×2;
- migracija-light-gate-default — named строки
  {CHASTICHNYJ/W1A/OTSUT, POLNYJ/W1A/NULL} × LIGHT (блокер 1 круга 2);
- migracija-pustaya-sessiya-demo — named строки PUSTOJ ×2 (блокер 1
  круга 2: пустой подключённый порт);
- migracija-g0-nedopusk-restail — named 20 truthy-строк с gate ≠
  current × 2 темы = 40 клеток (блокер 2 круга 2: рестайл
  отклонённого gate) + Г0-смена ×2;
- migracija-light-stale-current — named W1A_STALE_SVETLAYA + строка
  POLNYJ/W1A/STALE/LIGHT + entry W1A_STALE в LIGHT ×4;
- migracija-light-start-do-continue — named SVETLAYA_MARSHRUT +
  W1A_STALE_SVETLAYA + все 5 строк W1A в LIGHT + entry W1A-пары в
  LIGHT ×8 + порядок LIGHT_TO_DARK;
- migracija-null-kak-current — named W1A_NULL + W1A_GATE_OTSUT +
  POLNYJ/W1A/NULL ×2 + CHASTICHNYJ/W1A/OTSUT ×2;
- migracija-or-uslovie (`||` в ОБОИХ предикатах) — named 6 клеток
  недопуска + 8 строк таблицы ×2 + entry пары {W0_CURRENT, W1A_STALE}
  ×16 + rerender ×2; depends Г0 ONBOARDING ×2;
- migracija-port-est-dopusk — named ADMISSION_OTSUT_CURRENT + все 10
  truthy-строк admission {OTSUT, NULL} ×2 (включая CHASTICHNYJ/NULL/
  OTSUT — новая поверхность при null-admission);
- migracija-g0-restail-nedopusk-admission — named 20 truthy-строк с
  admission ≠ W1A × 2 темы = 40 клеток + Г0 ONBOARDING ×2 + Г0-смена
  ×2;
- migracija-temnyi-start-do-continue — named MARSHRUT + тёмные клетки
  W1A_{STALE,NULL,GATE_OTSUT} + все 5 строк W1A в DARK + entry
  W1A-пары в DARK ×8 + порядок DARK_TO_LIGHT;
- круг 3 (r3-мутанты критика, мутации перенесены с драйвера
  Critic117v3c/new_attack.py по смыслу): migracija-postoronnee-pole-
  authenticated — named постороннее поле ×2; migracija-gate-iz-entry
  — named entry-клетки W1A_STALE ×8 (entry.gate='current' у каждого
  входа оси не открывает Start); migracija-literal-completed — named
  entry-клетки COMPLETE × {W0_STALE, W0_CURRENT, NEPODKLYUCHEN} ×2;
  migracija-kesh-dopuska — named rerender ×2; migracija-restart-start
  — named начальный кадр COMPLETE × 5 пар ×2 + remount + entry-клетки
  COMPLETE ×10 (замер: ось (а) ждёт first-run на первом рендере);
  migracija-g0-smena-temy — named Г0-смена ×2;
  migracija-start-ot-smeny-temy — named порядок ×2;
статических 38 — 31 из 117/2 (icon-template-bytes,
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
  на R@B: failed 23 of 34 — сохранён; замер правки по FAIL v3 круга 1
  на R@B: failed 24 of 44 — сохранён; замер правки по FAIL v3 КРУГ 2
  на R@B: failed 26 of 96 — 22 клетки оверлея (18 прежних + GEOMETRY
  ×2 + ZORDER ×2) + MIGRACIYA_W1A_CURRENT_MARSHRUT,
  MIGRACIYA_W1A_CURRENT_SVETLAYA_MARSHRUT и 2 маршрут-строки таблицы
  MIGRACIYA_TABLICA_POLNYJ_W1A_CURRENT_{DARK,LIGHT} (маршрут на B не
  реализован); замер консолидации по арбитражу на R@B: failed 56 of
  185 — те же 26 плюс 30 клеток, требующих Erstinformation: 4
  переписанные именованные W1A×не-current, 8 переписанных строк
  таблицы W1A×не-current, 16 entry-клеток W1A-пар и 2 клетки порядка
  после смены темы; зелены Г0–Г3 ×8, клетки не-W1A прежнего пути,
  Г0-клетки ONBOARDING/DOPUSK ×4, начальный кадр/remount, Г0-смена,
  rerender, постороннее поле и все прочие клетки таблицы — прежний
  путь, белый корень и First-Run на старте и есть состояние B, это не
  ослабление);
  `vkhod_static_probe.py --repo R` → rc1 `VKHOD_SPLASH_COMPOSITE_ABSENT`.
- Дано B с эталонной моделью (`--model`) либо честное C: обе пробы → rc0 с
  перечнем: поведенческая 185/185 (замер консолидации по арбитражу:
  96 прежних + 89 клеток круга 3 (а)–(д)), статическая
  43/43 (замер v3 — семья правкой не менялась; модель workflow —
  `mobile.yml` `cmp-mob-123/sverka` @10cf684 дословно); счёт таблицы —
  кодом из самой таблицы (26 строк × 2 темы = 52) и сходится с прогоном
  (185 = 96 + 89; 96 = 44 + 52) и разбором исходника (замеры кругов
  2–3).
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
  стаб красен именованной ветвью (поведенческих 60 — 24 из 117/2 + 7
  Adv + 4 миграции + 8 круга 1 + 10 круга 2 + 7 круга 3 r3; статических
  38), побочная краснота только в depends; любой
  MUTANT_GREEN/MUTANT_NAMED_MISS/MUTANT_UNEXPECTED_RED — rc2. Длинный
  замер допустим срезами `--matrix --only <имена>` — объединение срезов
  обязано покрыть все стабы MUTANTS (счёт срезов — из вывода пробы).
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
  не предмет 117); замер консолидации по арбитражу (круг 3) на R@B:
  pilot.test 14/14 rc0, first_run_111 honest 23/23 rc0 — семантика
  admission/gate прежние пробы не ломает.
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
- (v4) Дано R@B без реализации: обе пробы `--repo R` → rc1 прежними
  именованными причинами (VKHOD_SPLASH_COMPOSITE_ABSENT /
  VKHOD_SPLASH_OVERLAY_ABSENT, failed 62 of 191 — 56 прежних замера v3 +
  6 HOLD-клеток v4 (HOLD_LINK/HOLD_NE_INOJ_URL/HOLD_NE_NEMARSHRUT ×2):
  на до-предметном дереве красны ВСЕ клетки оверлея, включая NE_INOJ_URL
  и NE_NEMARSHRUT — оверлея нет вовсе).
- (v4) Дано модель v4 (Г′) на R@B: `vkhod_static_probe.py --model` → rc0
  `static 70/70` (55 прежних + 15 порождаемых порядка
  MAESTRO_HOLD_PORJADOK_*); `vkhod_probe.py --model` → rc0 `behavioral
  191/191` (тройной прогон — детерминизм).
- (v4) Дано живой продукт @ c617f6fb236d11574df75fb09ae41870bf8c29d6 (PR
  #124; 117 v3 реализован, v4 нет): статическая проба `--repo` → rc1,
  красны РОВНО пять новых клеток — MAESTRO_HOLD_COLD_START (нет
  stopApp/openLink), MAESTRO_HOLD_ALONE (литерала нет нигде),
  SPLASH_HOLD_LINK_CHANNEL (канала в pilot-app нет),
  SPLASH_HOLD_LINK_ROUTE_MOUNT (ссылки канала нет — нечему вести на
  корень) и REPLAY_SPLASH_WHILE_OVERLAY (окно = прод-литерал 1200, сетка
  даёт CLASS_B), прежние статические зелены (в т.ч. SPLASH_HOLD_NO_ENV,
  REPLAY_HOLD_SCENARIO_ONLY и REPLAY_LIVE_PROBA_G — канала (В) на
  продукте нет, свидетели (Г) субъект-независимы), клетки порядка
  MAESTRO_HOLD_PORJADOK_* зелены (входы синтетические, субъект не
  читается — замер после правки круга 1); поведенческая → rc1
  failed 36 of 191: две новые SPLASH_OVERLAY_HOLD_LINK_{DARK,LIGHT} плюс
  34 клетки ГРАНИЦЫ модель/production (семьи W1A/ТАБЛИЦА/ENTRY/порядок —
  маркеры Erstinformation модели; frozen 117/3 «Граница
  модель/production»: эти клетки судят модель, production-корень —
  приёмка 118; на живом продукте красны и ДО v4 — замер);
  SPLASH_OVERLAY_HOLD_NE_INOJ_URL_{DARK,LIGHT} и
  SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_{DARK,LIGHT} зелены — их краснота
  наблюдает дефект «канал слишком широк», а не отсутствие канала.
  Дано продукт + продуктовые патчи v4 (produktnye-izmenenija3/0001–0002
  к c617f6fb, одноразовая ветка пробы): статическая 70/70 rc0 — батарея
  гаснет ровно с реализацией.
- (v4, правка FAIL круг 1) Дано модель v4 с ОБХОДОМ 1 критика (второй
  launchApp{clearState} МЕЖДУ stopApp и openLink — мутация сценария
  дословно по вердикту, она же стаб splash-hold-relaunch-pered-link);
  когда `vkhod_static_probe.py --repo R`; тогда rc1, красны РОВНО
  MAESTRO_HOLD_COLD_START (приложение запущено непосредственно перед
  openLink) и REPLAY_SPLASH_WHILE_OVERLAY (окно = прод-литерал 1200,
  CLASS_B) — прежде статика была зелёной 55/55.
- (v4, правка FAIL круг 1) Дано модель v4 с ОБХОДОМ 2 критика
  (перестановка stopApp → launchApp{clearState} → openLink — стаб
  splash-hold-porjadok-stop-launch); когда статическая проба; тогда rc1,
  красны РОВНО MAESTRO_HOLD_COLD_START (к ссылке приложение запущено,
  стоп не после очистки) и REPLAY_SPLASH_WHILE_OVERLAY; поведенческая
  проба на этом же дереве остаётся rc0 191/191 — объявленная ГРАНИЦА
  (см. «НЕ ЗАЩИЩАЕТ»): Jest судит pilot-app, порядок команд Maestro-
  сценария судят статика (MAESTRO_HOLD_COLD_START + MAESTRO_HOLD_
  PORJADOK_* ×15, оба обхода красны) и реплей (взвод окна ТОЛЬКО
  холодным стартом); живой свидетель честной цепочки — commands.json 117
  пробы (Г′) run 40511584004 (launchApp clearState → stopApp → openLink;
  живой артефакт CI, не припинен в live/ — сверка по логу run).
- (v4, правка по РЕШЕНИЮ арбитража круга 2) Дано модель v4 (Г′) с цепочкой
  критика круга 2 (добавочный extendedWaitUntil visible splash-overlay
  МЕЖДУ launchApp{clearState} и stopApp — мутация вердикта 2/2 дословно);
  когда `vkhod_static_probe.py --repo R`; тогда rc0 70/70 — ожидание
  судится ПЕРВЫМ ПОСЛЕ openLink, все условия холодного старта выполнены
  (клетка MAESTRO_HOLD_PORJADOK_VSTAVKA_WAIT_DO_STOPA: expected True);
  Дано та же цепочка с добавочным ЗАПУСКАЮЩИМ шагом (launchApp между
  openLink и ожиданием, запуск между stopApp и openLink); тогда rc1,
  красны РОВНО MAESTRO_HOLD_COLD_START и REPLAY_SPLASH_WHILE_OVERLAY —
  граница арбитража (запускающие шаги красны как прежде).
- (v4, правка FAIL круга 3, contracts-117-v4-krug3) Дано модель v4 (Г′)
  с ЗАПУСКАЮЩИМ шагом МЕЖДУ hold-ссылкой и первым ожиданием — по КЛАССАМ
  живых форм (входы вердикта krug3 дословно: `- runFlow: start.yaml` |
  скалярный `- launchApp` | launchApp-словарь | иная живая ссылка
  `complior://start`); когда `vkhod_static_probe.py --repo R`; тогда
  rc1: у форм runFlow/скалярного/словарного launchApp красны РОВНО
  MAESTRO_HOLD_COLD_START (запускающий шаг на интервале — повторный
  старт не читает стартовый URL при монтировании) и
  REPLAY_SPLASH_WHILE_OVERLAY (окно = прод-литерал 1200, CLASS_B); у
  иной ссылки ДОПОЛНИТЕЛЬНО SPLASH_HOLD_LINK_ROUTE_MOUNT (вторая ссылка
  канала) и REPLAY видит NO_PILOT — прежде статика на ПЕРВЫХ ДВУХ формах
  была зелёной 65/65 rc0 (ложная зелень krug3: интервальный предикат
  видел только launchApp-словарь); порождаемые клетки
  MAESTRO_HOLD_PORJADOK_VSTAVKA_{RUNFLOW,LAUNCH_SKALJAR,LAUNCH_SLOVAR,
  DRUGOJ_SSYLKI}_MEZHDU красны на своих синтетических входах ДО субъекта;
  Дано добавочный НЕ запускающий шаг в том же интервале (снимок |
  assertVisible | notVisible-ожидание — контроль критика krug3); тогда
  rc0 70/70 (клетка MAESTRO_HOLD_PORJADOK_VSTAVKA_SNIMOK_MEZHDU:
  expected True — арбитраж путь (А)); честная цепочка и контроли
  visible-до-stop зелёны (замер attack117i: 13/13 ожиданий).
- (v4, совет критика круг 1) Дано C в PR 117; когда `git diff --exit-code
  c617f6fb236d11574df75fb09ae41870bf8c29d6 <head-PR> --
  .github/workflows/mobile.yml`; тогда rc0 (запрет ПЕРЕСЕЧЕНИЯ проверяем
  механически; живая проба (Г′) на run 40511584004 его уже исполняла).
- (v4) Дано модель v4; обе пробы `--matrix` → rc0: каждый стаб красен
  именованными ветвями, побочная краснота только в depends (статических
  52 — 38 v3 + 14 v4, поведенческих 64 — 60 v3 + 4 v4; замер матрицы v4
  расширил depends — см. «Стабы v4»: no-wait/wait-commented/
  first-run-as-splash +MAESTRO_HOLD_COLD_START, start-launchapp
  +MAESTRO_HOLD_ALONE +SPLASH_HOLD_LINK_ROUTE_MOUNT, link-na-marshrut
  +LINK_CHANNEL/COLD_START/HOLD_ALONE, vse-ssylki (стат.)
  +REPLAY_SPLASH_WHILE_OVERLAY, link-invertirovan +TIMER_HIDE/STATUS_BAR,
  vse-ssylki (повед.) — замена undefined-safe; расширения под
  NEMARSHRUT — замером матрицы; relaunch-pered-link и
  porjadok-stop-launch — depends REPLAY_SPLASH_WHILE_OVERLAY замером
  матрицы после правки круга 1); любых MUTANT_GREEN / MUTANT_NAMED_MISS /
  MUTANT_UNEXPECTED_RED — rc2.
- (v4) Порча свидетеля live/ или пина sha256 в source.json
  replay_117.live.svideteli → rc2 ORACLE_TAMPERED (не зелень).

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
- от обхода допуска демо-маршрута (117 v3 + правки по FAIL v3 кругов
  1–2 + консолидация по арбитражу): ТАБЛИЦА ВХОДОВ MIGRACIYA_TABLICA_*
  ×52 судит ВСЕ выразимые входы порта onboarding (внешняя сессия):
  admission ∈ {W0, W1A, отсутствует, null, неизвестное('W2')} × gate ∈
  {current, stale, отсутствует, null, неизвестное('future')} × тема
  {dark, light} × форма порта {не подключён, пустой `{}`, частичный,
  полный} — 26 строк × 2 темы, счёт из таблицы кодом; ПОВЕРХНОСТЬ
  Erstinformation открывает ТОЛЬКО admission 'W1A' в обеих темах,
  ПЕРЕХОД continue → Start — ТОЛЬКО W1A ∧ current (при null/stale
  continue не переводит); литерал допуска в pilot-app
  (migracija-admission-literal, обходы критика
  migracija-admission-default, migracija-gate-default,
  migracija-w0-stale-dopushchen, migracija-svetlui-obhod), допуск без
  current (migracija-gate-ignor, migracija-stale-kak-current,
  migracija-null-kak-current), `||` в условии (migracija-or-uslovie),
  ПУСТОЙ подключённый порт `{}` (migracija-pustaya-sessiya-demo —
  блокер 1 круга 2: истина порта ≠ допуску), умолчание gate только в
  светлой (migracija-light-gate-default — блокер 1 круга 2),
  неизвестные значения осей (строки NEIZVESTNOE таблицы), truthy порт
  без admission (migracija-port-est-dopusk), светлая тема как допуск
  (migracija-svetlui-obhod), маршрут только в тёмной
  (migracija-marshrut-tolko-temnyi), Start мимо Erstinformation
  (migracija-start-pryamo, migracija-light-start-do-continue,
  migracija-temnyi-start-do-continue) и удаление прежнего пути F03
  (migracija-f03-put-udalen — красен и гвардами Г0–Г3 и всеми 52
  клетками таблицы: кадры недостижимы) красны именованными клетками
  на входах, где дефект наблюдаем (Н-39);
- от подмены источника допуска соседними полями и состояниями (круг 3,
  арбитраж нарезки — семь r3-обходов критика): ось entry × решающие
  пары MIGRACIYA_ENTRY_* ×40 — entry (в т.ч. 'complete' и постороннее
  поле gate) не источник допуска (migracija-literal-completed,
  migracija-gate-iz-entry); постороннее truthy-поле порта
  authenticated не заменяет пару admission/gate
  (MIGRACIYA_POSTORONNEE_POLE_AUTHENTICATED ×2 —
  migracija-postoronnee-pole-authenticated); начальный кадр first-run
  при любом entry/порте и remount (MIGRACIYA_NACHALNYJ_KADR ×40 +
  REMOUNT — migracija-restart-start: сохранённый completed-entry не
  создаёт Start); порт читается в МОМЕНТ действия — rerender W1A→W0
  до демо есть недопуск (MIGRACIYA_RERENDER ×2 —
  migracija-kesh-dopuska: кэш admission не открывает маршрут);
  порядок Start при смене темы на Erstinformation
  (MIGRACIYA_PORYADOK_SMENA_TEMY ×2 — migracija-start-ot-smeny-temy);
  Г0 после смены схемы — см. следующий буллет (migracija-g0-smena-temy);
  production-источник сессии, подключение `/` и настоящий gate 107 —
  приёмка 118 (раздел «Граница модель/production»), заморозка 117/3
  их зелёность на production не заявляет;
- от рестайла корня F03 подключённым onboarding (правка по FAIL v3,
  блокер 2; круг 2 — класс; круг 3 — смена схемы): клетки Г0
  MIGRACIYA_G0_F03_ONBOARDING/DOPUSK ×4 и каждая недопуск-строка
  таблицы (Г0 на кадрах email, в не-W1A строках и на код-кадре, обе
  темы) судят корень #FFFFFF 48/16/16 на экземплярах с ПОДКЛЮЧЁННЫМ
  портом при ЛЮБОМ недопуске — в т.ч. с отклонённым/отсутствующим/
  null/неизвестным gate (стабы migracija-g0-nedopusk-restail — обход
  критика круга 2: рестайл при gate ≠ current, — и migracija-g0-
  restail-nedopusk-admission — та же ось по admission), при допуске
  (migracija-restyle-pri-dopuske) и при любом truthy порте
  (migracija-onboarding-restyles-f03 — красен всеми 50 truthy-строками
  таблицы) — и ПОСЛЕ СМЕНЫ СХЕМЫ в живом экземпляре, обе стороны
  dark→light / light→dark (MIGRACIYA_G0_SMENA_TEMY ×2, круг 3:
  migracija-g0-smena-temy — рестайл корня после смены темы, обход
  r3-g0-theme-change); прежние гварды Г0 и рестайл-стабы не сняты;
- от зависимого оракула (Н-351): ожидания — литералы source.json/теста,
  STATIC_ORACLE_LITERALS; эталоны — sha-пин read-only docs/;
- от мёртвой матрицы: обе пробы исполняют все стабы (60+38), depends
  измерены прогоном, unexpected_red/suite_broken — rc2.
- (v4) от кадра Splash после ухода оверлея (класс B): реплей тайминга по
  живому формату Maestro судит ВСЮ сетку задержек раннера (poll 250–1000 ×
  shot 0–2400 мс) — кадр в окне оверлея при любой фазе опроса только если
  HOLD > poll + shot; проводка канала (Г′) (литерал корень+query +
  Linking.getInitialURL + апгрейд таймера) и согласованность с таймаутом
  notVisible — отдельными клетками; дефект «канал (В) вернулся» ловится
  SPLASH_HOLD_NO_ENV + REPLAY_HOLD_SCENARIO_ONLY (живой носитель 118),
  дефект «прод-литерал сдвинут» — SPLASH_OVERLAY_TIMER_HIDE_*; живой
  носитель (сценарий @ ba5ebbc927 + commands.json класса B, sha256) держит
  грамматику реплея на живом формате, SVERKA_123_CATCHES_CLASS_B —
  настоящую сверку на живых байтах (класс B → NIZHE_POROGA rc1, зелёный
  контроль → rc0);
- (v4) от удержания, меняющего посторонние сценарии (инвариант 11):
  REPLAY_HOLD_SCENARIO_ONLY на живом commands.json 118 пробы 40434807469
  (зазор 7450 мс, sha256) — env-взвод на ОБЩЕМ входе красен (дефект пробы:
  0.000 обе темы), честная (Г′) без литерала зелена (прочие кадры 118 той
  же пробы 0.845/0.783); MAESTRO_HOLD_ALONE — литерал только в сценарии
  117 по всему mobile/.maestro; SPLASH_OVERLAY_HOLD_NE_INOJ_URL_* — чужая
  живая ссылка (complior://start, cmp-mob-002/004) не взводит удержание;
- (v4 (Г′)) от ссылки канала, ведущей на несуществующий маршрут (живой
  провал пробы (Г) run 40497913252: нативный splash залип, флоу 117 красен
  — инвариант 12): SPLASH_HOLD_LINK_ROUTE_MOUNT судит класс входа ссылки
  (сценарий открывает РОВНО литерал оракула, expo-путь ПУСТ — корень
  «/», единственный маршрут с безусловным монтированием PilotApp; грамматика
  извлечения — expo-router ~57.0.28 node_modules продукта), реплей даёт
  NO_PILOT на всей сетке (PilotApp не монтируется, оверлей не появляется),
  SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_* — URL несуществующего маршрута
  удержания не взводит (прод-таймер 1200), REPLAY_LIVE_PROBA_G держит
  живые факты провала (пустое дерево, доставка ссылки, запуск JS);
  стаб-контрпример splash-hold-link-na-marshrut — дефект пробы (Г) дословно
  (host-форма в обеих копиях литерала);
- (v4, правка FAIL круг 1) от «холодного старта суммой команд»: состояние
  «приложение запущено» отслеживается по последовательности команд
  (launchApp/runFlow/openLink — запускают, stopApp — останавливает),
  openLink литерала — холодный старт ТОЛЬКО при остановленном приложении
  и stopApp ПОСЛЕ launchApp{clearState}; оба обхода критика (второй
  launchApp между stopApp и openLink; перестановка stopApp →
  launchApp → openLink) красны клеткой MAESTRO_HOLD_COLD_START и
  порождаемой семьёй MAESTRO_HOLD_PORJADOK_* ×15 (2 перестановки, вставки
  до ссылки и на интервале (круг 3: 4 красных класса запускающего шага
  между ссылкой и ожиданием — runFlow/скалярный launchApp/словарный
  launchApp/иная ссылка), 2 удаления, честная цепочка, цепочка критика
  круга 2 и контроль не запускающего шага на интервале (добавочное НЕ
  запускающее ожидание/снимок — арбитраж 117 v4)
  зелёны — ожидания литералами до
  субъекта), реплей взводит окно ТОЛЬКО холодным стартом (стабы
  splash-hold-relaunch-pered-link / splash-hold-porjadok-stop-launch —
  красны ровно MAESTRO_HOLD_COLD_START + REPLAY_SPLASH_WHILE_OVERLAY,
  замер матрицы после правки).

НЕ ЗАЩИЩАЕТ:
- production-источник сессии (связь «сессия → порт onboarding» и её
  обновление), подключение production `/` (bootstrap/pilot-app), Maestro
  от настоящего корня, состав/пиксели F02.03/F02.08/Start и настоящий
  gate 107 — батарея 117 судит модель, не production-корень (арбитраж
  нарезки, «Граница модель/production»); ловец — приёмка 118 на
  настоящем корне (инварианты 4–5 frozen 118/1, bootstrap-проба :32,
  зона implementer 118);
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
- (v4) реплей судит ЗАКОН окна (poll+shot против HOLD) на сетке из
  source.json, а не конкретный раннер: задержки вне сетки (shot > 2400 мс
  при деградации станции, poll > 1000 мс) не проверяются — hold 8000 даёт
  запас 2.3× против замеренного максимума 1370 мс; ловец — живой прогон
  android-e2e (шаг 117/123; сверка 123 остаётся безусловным барьером,
  клетки SVERKA_123_*);
- (v4) литерал удержания компилируется в ПРОД-бандл: пользователь, открыв
  complior:///?e2e=splash-hold вручную (ссылка нигде в продукте не
  публикуется), получит 8-с удержание оверлея — прод-видимое поведение,
  гейдж «литералом-паролем»; батарея судит недостижение литерала чужими
  сценариями (инвариант 11), а не невозможность ручного ввода; ловец —
  ревьюер 117 (допустимость литерала в прод-коде) и живая серия ≥5
  прогонов; e2e-APK вне литерала байт-идентичен прод по поведению оверлея
  (прод-таймер 1200 немедленно, клетки SPLASH_OVERLAY_TIMER_HIDE_*);
  длительность e2e-прогона 117 растёт на ~7 с × тема (hold до снимка
  first-run) — таймаут шага 117 остаётся барьером.
- (v4, правка FAIL круг 1) поведенческая проба (Jest/RNTL) порядок команд
  Maestro-сценария НЕ судит — она судит pilot-app, а не yaml: на обходе 2
  критика (перестановка stopApp/launchApp) поведение остаётся 191/191
  (замер критика attack117_behavior.py); порядок судят статика
  (MAESTRO_HOLD_COLD_START по состоянию + MAESTRO_HOLD_PORJADOK_* ×15,
  оба обхода красны) и реплей (окно взводится ТОЛЬКО холодным стартом);
  живой свидетель честной цепочки — commands.json 117 пробы (Г′) run
  40511584004 (живой артефакт CI, не припинен в live/ — сверка по логу
  run); ловец на живом рантайме — серия android-e2e (шаг 117);
- (v4, СОВЕТ критика круг 1, не блокер) статическая проба НЕ судит
  очистку прод-таймера при апгрейде (атака removed-clear-timeout
  статически зелена): этот дефект судит поведенческая семья — стаб
  splash-hold-taymer-bez-clear красит SPLASH_OVERLAY_HOLD_LINK_{
  DARK,LIGHT} (оба живых таймера — скрытие на 1200-й, замер матрицы);
  остатка нет, канал закрыт другой семьёй той же батареи.

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
