# Контракт 174 — выбор сессии в models_actual

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — выбор записей отчёта о модели, без прав/авторизации, денежных, медицинских и юридически значимых операций.
КОНТЕКСТ: приоритет владельца «Phase 1.3: add `--session` to models_actual»; текущая `models_actual.sh --tsv --bind` на живой зоне отказывает rc 2 на `Arbiter079Б1` (HANDOFF.md §ГДЕ МЫ, 09.11), хотя интересующая сессия может иметь допустимый ID. Номер 174 зарезервирован; предмет только фильтр, не нормализация `check_sud_model` и не табло DEMO.

## Существующее

- `scripts/models_actual.sh:62–74` уже разбирает `--all`, `--tsv`, `--bind`; `:83–134` выдаёт TSV по JSONL зоны, `:107–115` проверяет алфавит basename каждого посещённого JSONL в режиме `--bind`, `:137–183` выдаёт человекочитаемый отчёт и проверяет только последнюю показанную сессию. Источник зоны — `HARNESS_SESSION_HOME` либо формула 028; сортировка по mtime от нового к старому. `--tsv` даёт три поля, `--bind` — пять; фильтра по ID нет.
- Замороженные 095/104 фиксируют TSV-префикс и привязку к basename JSONL; `scripts/check_sud_model.sh --verdict` потребляет пятиколоночную трассу, его диагностика и алфавит здесь не меняются. `fixtures/context_pack_095/` и `fixtures/zashchita_main_104/` уже проверяют смежный поток; новая семья изолирует только отбор источников. `contracts/169-model-trace-put-i-project-brief.md` и `fixtures/workshop_project/model_trace_169/` показывают прецедент независимых `--repo`, `--model`, `--stabs` и `.probe-only`.
- В дереве и в поиске открытых PR для `174` нет другого варианта реализации (`gh pr list --state open --search 174` → `[]`); ветка `wip/174/architect` — текущая. HANDOFF Н-436 отмечает проблему определения роли ведущей сессии; это отдельный предмет, не следствие выбора файла.

## Предмет, frontier и граница

**Выбор:** `bash scripts/models_actual.sh --session <id>` ограничивает входные JSONL **до разбора событий, проверки `--bind` и отчёта** файлами, basename которых без `.jsonl` буквально равен `<id>`; вложенная сессия под каталогом родителя использует тот же basename-примитив. Вход `<id>` — непустая самостоятельная строка в алфавите `[A-Za-z0-9._-]` (как у `--bind` 104), без glob/regex/частичного совпадения и без извлечения из содержания. Неверный/пропущенный аргумент — rc 2 и именованный `NOT_IMPLEMENTED`; отсутствие JSONL с выбранным ID — rc 2 `NOT_IMPLEMENTED: сессия не найдена: <id>` (никакого молчаливого перехода к последней). Конформный вход: читаемые JSONL `model_change` той же текущей грамматики, ID из этого алфавита, явно заданный `HARNESS_SESSION_HOME` как существующий каталог; валидный контрпример инвариантен к модели и basename, но расходится на таком входе.

С `--session` оба человеческих режима (обычный и `--all`) показывают только выбранный файл и прежний итог/гейт по последней показанной; `--tsv` сохраняет три поля, `--tsv --bind`/`--bind` — пять, значения и порядок `model_change` внутри выбранного файла неизменны. При нескольких одноимённых JSONL сохраняется прежний порядок всех совпавших файлов. Без `--session` CLI, mtime-порядок, поля, коды/диагнозы остаются прежними: в частности `--tsv --bind` при чужом basename `Arbiter079Б1` всё ещё rc 2 `NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: Arbiter079Б1`; при выборе другого допустимого ID чужой файл пропускается **до** этого отказа. `check_sud_model.sh`, `make_task.sh`, генератор ролей и табло не меняются. Frontier «нормализовать имена всех JSONL» отвергнут: это меняет identity-трассу 104 и маскирует отказ без фильтра. Frontier «фильтровать строки после построения трассы» отвергнут: до фильтра уже срабатывает чужой invalid-ID и невозможно устранить измеренную боль.

## Приёмочный критерий

- Дано: текущий субъект, зона с новым `Alpha_174`, старым `Beta-174` и чужим `Arbiter079Б1`; когда `bash fixtures/workshop_project/models_actual_174/red_session_174.sh --repo`; тогда rc 1, десять независимых клеток выбора человеческого/TSV/TSV-bind отчётов, точного ID в TSV и человеческом отчёте и отсутствующего ID красны своими результатами, а четыре контроля (включая `legacy_bind_invalid`: rc 2 с нынешним диагнозом; `legacy_human_last`: без флага показывает ровно последнюю из трёх сессий, модели остальных отсутствуют) зелёны. Никакая зелёная клетка не заменяет красную.
- Дано: честный контроль на том же базовом скрипте и зоне; когда `bash fixtures/workshop_project/models_actual_174/red_session_174.sh --model`; тогда rc 0, четырнадцать клеток зелёны. Когда `bash fixtures/workshop_project/models_actual_174/red_session_174.sh --stabs`, тогда rc 0, девять обманных стабов пойманы каждый своей отличающей клеткой; адреса стаб→вход живут только в коде пробы, не в тексте контракта.
- Дано: реализация фильтра в `scripts/models_actual.sh`; когда `bash fixtures/workshop_project/models_actual_174/red_session_174.sh` (команда CI), тогда rc 0: точное отбирание, прежний формат и порядок строк, отсутствие тихого fallback и прежний отказ и показ ровно последней сессии в человеческом отчёте без флага. Когда `bash scripts/check_ceilings.sh` и `bash scripts/pre_critic.sh --repo . contracts/174-models-actual-session.md`, тогда оба rc 0. Перед done: `bash scripts/check_provodka.sh . contracts/174-models-actual-session.md` rc 0; проектный source-гейт — по `harness.project.json`.

## Зоны и проводка

ЗОНА architect: contracts/174-models-actual-session.md fixtures/workshop_project/models_actual_174/
ЗОНА implementer: scripts/models_actual.sh
ЗОНА critic: verdicts/critic/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 028 только новый отбор JSONL, источник зоны и обычный отчёт без флага неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 095 только новый отбор до TSV, трёхполевая грамматика/свидетельство модели прежние.
ПЕРЕСЕЧЕНИЕ implementer: scripts/models_actual.sh — 104 только новый отбор до `--bind`, пять полей/ID выбранного файла прежние; без фильтра прежний invalid-ID rc 2.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только генерируемый шаг 174; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 174; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 174; чужие строки неизменны.
После ленда оркестратор добавляет собственную строку `step` 174 в `registry/ci-steps.tsv`, замер в `registry/ci-zamery.tsv` и генерирует `.github/workflows/ci.yml` через `gen_ci_steps.sh --write`/`--check`; команда CI — `bash fixtures/workshop_project/models_actual_174/red_session_174.sh`.
ПРЕДПОСЫЛКИ:
- setting Существующий CI харнесса предоставляет bash, Python 3 и jq; шаг 174 не требует новых secrets, variables, environments или настроек репозитория.

ПРОВОДКА:
- guard=fixtures/workshop_project/models_actual_174/red_session_174.sh
ПРОВОДКА-ЭНФОРСМЕНТ: Новый флаг — CLI-фильтр для уже существующего трейс-источника, новая поведенческая норма ролям не вводится; барьер CI исполняет самостоятельные клетки отбора и прежнего отказа без флага, подключается отдельной строкой шага 174.

## Модель угроз

ЗАЩИЩАЕТ:
- Чужая сессия с ID вне алфавита не мешает привязке явно выбранной допустимой сессии, а неотфильтрованный режим остаётся fail-closed.
- Выбор ID не воспринимает glob/regex/подстроки и не делает fallback на другой файл при отсутствии совпадения.
НЕ ЗАЩИЩАЕТ:
- Аутентичность JSONL и правильность определения роли ведущей сессии; это отдельные входы 104 и Н-436.

## Незаполненные требования:
нет
