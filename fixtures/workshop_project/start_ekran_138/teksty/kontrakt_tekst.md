# Пачка start-ekran (контракт 138): экран Start по шаблону 132

## Воля владельца

- 2026-10-24 docs/owner/2026-10-22-ochered-ispolneniya.md §Mob п.3: Start сразу
после Erstinformation (118); кадры F04.01/F04.07/F04.08/F04.13 обе темы,
пакет 3 дизайнера (D-06: тёмный Start = F04.01); CMP-MOB-004/011.
- 2026-10-21 ekrany-bystree §Решение п.1–2: один экран — один контракт,
сверка кадров с PNG; порог/мера — 123; форма — 132.

## Существующее

- 118 (frozen 118/1): production путь допуска `/` → First-Run → demo →
Erstinformation → continue при current gate → Start (start_tabs + 4 вкладки
testID). 138 ПОТРЕБЛЯЕТ путь и gate, НЕ переопределяет: прямой `/start` без
допуска ведёт назад — реализация и пробы 118.
- 108 (frozen 108/1): mobile/src/features/start/, start-screen, слот TabShell;
миссии/аватар — listMissions порта @pilot/runtime.
- 135: первый экран по шаблону 132 — образец пачки; 123: раннер сверки.

## Инварианты

1. Форма — 17 полей 132 дословно; zamenjaet=null (живого манифеста Start нет),
ne_trogaet — живые пачки чужих экранов обоих корней.
2. 8 кадров: 4 состояния (idle/composer/decision/resume) × dark/light; порог
0.6; элементы — полосы чернил грамматикой раннера 123, покрытие check_pokrytie.
3. Копия — verbatim из каталога (frame.F04.*, action.F04.*, ia115.*,
ui.mission.*, resume.*, home.voice, ui.start.no_action_scoped); литералы —
только аудит токенов.
4. Флоу: appId из mobile/app.json (com.complior.mobile); запуск production
пуска (launchApp, без openLink); перед каждым кадром переход и assertVisible
СВОЕГО селектора; исключение из общего прогона каталога config.yaml.
5. Кадр байт-идентичный макету — не скриншот (KADR_BYTE_KOPIJA_MAKETA).

## Приёмочный критерий

- Валидатор 132: rc 0, 8 строк KADR … 1.000 … OK + SHABLON start-ekran OK.
- Происхождение (batareja/proverka_proiskhozdenija.py): rc 0 — путь допуска,
селекторы с носителями, appId, config, состав манифеста, не-копии макетов.
- Продукт: mobile.yml пускает Maestro обе темы, сверку и проверку с пином H.

## Зоны и исполнители

ЗОНА architect: contracts/138-start-ekran.md fixtures/workshop_project/start_ekran_138/
ЗОНА implementer: mobile/src/features/start/ mobile/.maestro/ mobile/e2e-start/ .github/workflows/mobile.yml

## ПРОВОДКА

guard=fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh —
красная батарея экрана (SHABLON_ABSENT без субъекта; --stabs до ленда).

## Модель угроз

ЗАЩИЩАЕТ: подмену данных (пины sha256), зелень без субъекта, слабого судью
(стабы по ветвям), replay макета, расползание экрана, чужие пиксели.
НЕ ЗАЩИЩАЕТ: семантику эмулятора (риск 132), V03/V04 варианты (копия
PROPOSED — вне каталога), качество макета (ревью).
