# Пачка start-ekran (контракт 138): экран Start по шаблону 132

## Воля владельца

- Слово 2026-10-24 (ochered-ispolzovaniya §Mob п.3): Start после Erstinformation
(118); кадры F04.01/07/08/13 обе темы, пакет 3 (D-06: тёмный = F04.01).
- Слово 2026-10-21 (ekrany-bystree §Решение): один экран — один контракт,
сверка кадров с PNG; порог/мера — 123; форма — 132.

## Существующее

- 118 (frozen 118/1): путь допуска `/` → First-Run → demo → Erstinformation →
continue current → Start (start_tabs + 4 вкладки); прямой `/start` — 118.
- 108 (frozen 108/1): mobile/src/features/start/, слот TabShell; миссии —
listMissions порта @pilot/runtime.
- 135: первый экран по шаблону 132 — образец пачки; 123: раннер сверки.

## Инварианты

1. Форма — 17 полей 132 дословно; zamenjaet=null, ne_trogaet — живые пачки чужих
экранов обоих корней.
2. 8 кадров: 4 состояния × dark/light; порог 0.6; полосы чернил 123, check_pokrytie.
3. Копия — verbatim из каталога (frame.F04.*, action.F04.*, ia115.*,
ui.mission.*, resume.*, home.voice, ui.start.no_action_scoped); литералы —
аудит токенов.
4. Флоу: appId из mobile/app.json; запуск production (launchApp, без
openLink); перед каждым кадром переход и assertVisible СВОЕГО селектора;
исключение из прогона каталога config.yaml.
5. Форма флоу — замкнутый алфавит топ-уровневых команд (launchApp, tapOn,
assertVisible, inputText, pressKey, swipe, takeScreenshot); условные либо
вложенные конструкции (when/repeat/retry/runFlow/скрипты/анкоры) —
FLOW_USLOVNYJ_SHAG: шаг, который может НЕ выполниться, не исполнен.
6. Носитель селектора — литеральный testID="имя" вне комментария и
литерала, в дереве-владельце: состояния — features/start/**,
First-Run и Erstinformation — onboarding/**, demo-вход — auth/**, вкладки —
src/app/**; совпадение в чужом дереве носителем не является.
7. Кадр байт-идентичный макету — не скриншот (KADR_BYTE_KOPIJA_MAKETA).

## Приёмочный критерий

- Валидатор 132: rc 0, 8 строк KADR … 1.000 … OK + SHABLON start-ekran OK.
- Происхождение (proverka_proiskhozdenija.py): rc 0 — путь допуска,
селекторы-носители, appId, config, 8 кадров, не-копии макетов.
- Продукт: mobile.yml — Maestro обе темы, сверка и проверка с пином H.

## Зоны и исполнители

ЗОНА architect: contracts/138-start-ekran.md fixtures/workshop_project/start_ekran_138/
ЗОНА implementer: mobile/src/features/start/ mobile/.maestro/ mobile/e2e-start/ .github/workflows/mobile.yml

## ПРОВОДКА

guard=fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh —
красная батарея экрана (SHABLON_ABSENT без субъекта; --stabs до ленда).

## Модель угроз

ЗАЩИЩАЕТ: подмену данных (пины), зелень без субъекта, слабого судью (стабы), replay
макета, чужие пиксели, условную имитацию допуска, селектор чужого экрана.
НЕ ЗАЩИЩАЕТ: семантику эмулятора (132), V03/V04 (PROPOSED), качество макета.
