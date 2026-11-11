# Контракт 189 — Л4: стандартные валидаторы и канон

КЛАСС ЗАДАЧИ: кодовый — скрипты-валидаторы + канон-инструмент + установка с пином.
КЛАСС РИСКА: обычный — инструмент проверки; права/роли БД, авторизация, деньги, ПД/согласия и юридически значимые действия не меняются.
КОНТЕКСТ: слово владельца 2026-11-11 ~13:05 UTC через консультанта (Fable 16, принято п.1,2,3,5,6; «Л4 — стандартные валидаторы и канон» = номер 189, минт механизмом); основание — замер `DIAGNOSIS.md` §3.2 (`actionlint` 1.7.12 ловит 2 из 9 мутаций workflow, «канон + сравнение» — 9 из 9) и `ARCH-INTEGRATION.md` §3.3; `ADOPTION.md` §2 «Л4» (зона, критерий, «Не входит: шаги в CI проектов»), §5 «А» (дисциплина).

## Существующее

- Замер живёт таблицей в `/home/harness/consultant/fable16/out16/DIAGNOSIS.md:194-219`; каталог прототипов `out16/run/al/` (`run_matrix.sh`, `canon_job.js`), на который ссылаются Д/А, в дереве ОТСУТСТВУЕТ (проверено `ls`/`find` 2026-11-11). Матрица 9 мутаций + 2 честные записи восстановлена из таблицы Д§3.2 данными батареи: `fixtures/workshop_project/standartnye_validatory_189/matrix/` (11 входов; SHA действий — из работающего `ci.yml` проекта, Д§3.2:217-219). Усечённый пин `actionlint 1.7.12 sha256 8aca8db9…a3d8` (А§3.3) реализатор заполняет полным sha256 реального артефакта при установке.
- Станция: `python3 3.12.3`, `pyyaml 6.0.1` (системный dist-packages), `jsonschema 4.26.0` (user-site, зависит от HOME) — проверено импортом 2026-11-11; `actionlint`/`shellcheck` на станции НЕТ (проверено `command -v`). В CI-раннерах (ubuntu-24.04) подтверждён python3-pyyaml (зелёные шаги семей 122/143), jsonschema НЕ подтверждён — поэтому CI-шаг семьи объявлен в режиме `--stabs` (прецедент `check:ci-e2e-restart-995-family-selftest`: семейство с requirements.txt, в CI — только стаб-батарея).
- `scripts/ci_preflight.sh:82` — действующий прецедент pyyaml в станционных скриптах. `fixtures/workshop_project/ci_proekta_122/` — шаблон семьи `model/` + `stabs/` + данные; `roles_architecture_188/red_…sh` — шаблон CLI `--repo/--model/--stabs`; `models_actual_174` — честная модель для батареи.
- `ops/server/README.md` — единый источник станции; `ops/server/install.sh user|root|verify` ставит/сверяет обвязку побайтово (контракты 074/080/085). 189 расширяет тот же приём на СКАЧИВАЕМЫЕ бинари: репо держит не файл, а пин (версия + sha256) в `ops/server/validators.tsv`.
- `registry/ci-steps.tsv` — единственный источник шагов джобы `ci` (контракт 083): строка шага семьи и замер — orchestrator (контракт 038 «Проводка CI — оркестратором»).
- `package.json` харнесса зависимостей не имеет (умышленно): 189 не заводит npm/pip-зависимостей репо; движок json — уже установленный системный/пользовательский `jsonschema` (А§3.3 предлагал ajv из node_modules проектов — отвергнуто: требует чекаута чужого проекта и не разрешается на чистом клоне).
- Потребители: следующий предмет бэкенда с каноническим job (174-ряд `runtime-r0`), любая семья, которой нужен `bash -n`+shellcheck или JSON Schema. Шаги в CI ПРОЕКТОВ — вне предмета (ADOPTION §2 Л4 «Не входит»).

## Предмет

Один измеримый результат: три стандартных валидатора и канон-инструмент доступны с ДВУХ сторон — (а) любому предмету станции одной командой с пин-дисциплиной, (б) батарее 189, красной до реализации и зелёной после.

Инварианты (грамматика и наблюдаемые rc; реализация — implementer):

1. `scripts/validate_std.sh workflow <файл>` — rc пин-проверенного `actionlint` (пробрасывается); `scripts/validate_std.sh bash <файл>` — сначала `bash -n` (rc пробрасывается, при ≠0 stderr несёт `SYNTAX: bash -n`), затем пин-проверенный `shellcheck` (rc пробрасывается); `scripts/validate_std.sh json <схема> <документ>` — `python3 scripts/validate_std_json.py` с движком `jsonschema` (Draft 2020-12): валиден rc 0, первое нарушение rc 1 со stderr `JSON_INVALID:<указатель>`, неразбор rc 2 `JSON_UNPARSEABLE`. Вывод валидатора НИКОГДА не разбирается на «успех»: валидатор, печатающий успех с rc 1, даёт rc 1.
2. Пин-дисциплина бинарей: пины — `${VALIDATE_STD_PINS:-<каталог скрипта>/../ops/server/validators.tsv}`; строка `<инструмент><TAB>версия<TAB>sha256hex|->` (замкнутый алфавит; `-` — пакет python, закреплённый версией). Резолв бинаря: шов `VALIDATE_STD_ACTIONLINT`/`VALIDATE_STD_SHELLCHECK` → `$HOME/.local/state/dev-harness/validators/<инструмент>/<версия>/<инструмент>` → `command -v`. Найденный бинарь обязан иметь sha256 == пину: расхождение → rc 2 `VALIDATOR_PIN: <инструмент>` с фактическим sha; бинаря нет/строки пина нет → rc 2 `VALIDATOR_MISSING: <инструмент>`. Эти ветви НИКОГДА не дают 0 и не «пропускают» проверку.
3. Движок json: версия `jsonschema` (importlib.metadata) обязана равняться пину: расхождение → rc 2 `ENGINE_VERSION: jsonschema <факт> ≠ пин <пин>`; недоступен → rc 2 `ENGINE_MISSING: jsonschema`. Шов `VALIDATE_STD_PYTHON` (по умолчанию `python3`) — интерпретатор субъекта. Неизвестный режим/аргументы → rc 2 `NOT_IMPLEMENTED:` с использованием.
4. `scripts/check_canon_fragment.py <workflow> <job-id> <канон>` — разбор YAML (pyyaml) и структурное равенство job против фрагмента-канона (отображение job): эквивалентные YAML-записи (порядок ключей, кавычки, block/flow-списки) равны. rc 0 — равенство; rc 1 — stderr `CANON_DIFF: <путь>: <причина>` с путём первого отличия (обход детерминирован: узлы канона в порядке объявления, затем лишние ключи субъекта в его порядке; списки по индексам, разница длин — первый индекс за общей частью; синтаксис пути `steps[2].env.BASE`); rc 2 — именованные `CANON_ABSENT` / `CANON_UNPARSEABLE` / `CANON_JOB_MISSING` / `CANON_FRAGMENT` (канон не отображение) / `CANON_ENV` (нет pyyaml).
5. Установка: `ops/server/validators.tsv` — единый источник станции; `bash ops/server/install.sh validators` скачивает и ставит бинари в `$HOME/.local/state/dev-harness/validators/<инструмент>/<версия>/<инструмент>`, сверяя sha256 с пином ДО запуска: несоответствие → именованный отказ ≠ 0, установка не производится; `bash ops/server/install.sh verify` дополнительно сверяет пины ↔ установленное; `ops/server/README.md` получает раздел инвентаря валидаторов. `actionlint` ставится официальным архивом версии 1.7.12 (полный sha256 — из скачанного артефакта); `shellcheck` — официальным архивом с пином версии и sha256 (версию выбирает implementer по факту установки). Установка на станции — живой шаг реализации (проверка на настоящей станции, не на слове).

## Frontier

(а) Обёртка с пин-дисциплиной + канон-инструмент + установка в `ops/server/` — ВЫБРАНО; (б) голые вызовы `actionlint`/`shellcheck` из каждого предмета без пинов — отвергнуто: замер Д§3.2 показал 2/9 (нужен канон), а отсутствующий/подменённый бинарь обязан быть именованным отказом, не молчаливым пропуском или чужим поведением; (в) ajv из node_modules проектов — отвергнуто (Существующее). Канон-инструмент — pyyaml (есть на станции и раннерах), не самописный разбор и не текстовые подстроки (это отдельные клетки батареи: эквивалентная запись зелёна, подстрочный «канон» даёт на ней ложный отказ).

## Модель угроз

ЗАЩИЩАЕТ:
- От подмены или дрейфа внешнего бинаря: любой резолв (шов/дом установки/PATH) сверяется sha256 с пином репо; расхождение — rc 2 с именем инструмента и фактическим sha, никогда 0.
- От молчаливого пропуска проверки при отсутствующем инструменте или среде: rc 2 с именем (`VALIDATOR_MISSING`/`ENGINE_MISSING`/`CANON_ENV`), никогда skip-к-зелёному; батарея в чистом клоне без зависимостей отказывает rc 2 именованно, а не пустыми клетками.
- От ложного успеха по тексту вывода валидатора: rc пробрасывается буквально, stdout/stderr не парсятся; печатающий успех с rc 1 валидатор даёт красный rc 1.
- От подмены приёмки «канон» текстовыми сравнениями: приёмка — структурное равенство после разбора YAML, эквивалентные записи зелёны, любая из 9 мутаций матрицы Д§3.2 красна своим путём первого отличия.
- От расхождения репо ↔ станция: пины в едином файле `ops/server/validators.tsv`, установщик сверяет sha256 до запуска, клетка z01 живой батареи сверяет установленное с пином на станции.
НЕ ЗАЩИЩАЕТ:
- От полноты самого `actionlint` (состав меток runner, существование SHA, порядок шагов, формат digest — замер 2/9): это закрывает канон предмета-потребителя, не валидатор; клетка v04 закрепляет границу (скалярный runs-on — rc 0 обёртки, rc 1 канона).
- От качества схемы предмета-потребителя: схема — данные вызывающего; «схема-пустышка» различима клеткой на нарушающем документе, но сам факт выбора схемы — предмет потребителя.
- От враждебного контроля всего каталога установки или самого скрипта субъектом: граница — бинарь обязан совпасть с пином репо; полный захват станции — вне инструмента.
- От версии инструментов между пинами и от поведения `actionlint` вне измеренного контракта rc на входах матрицы (двойник батареи воспроизводит ровно измеренное).

## Приёмочный критерий

- Правило: `bash fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh --model` → rc 0, последняя строка `ИТОГ 189: rc=0 KLETKI=43 ZELENYE=43 KRASNYE=0` (честная модель проходит все клетки).
- Дано: дерево до implementer (сегодняшний main); когда `bash fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh` (голый вызов = суд реального субъекта в `scripts/`); тогда rc 1, все клетки красны именем отсутствующего субъекта (`KLETKI=43 ZELENYE=0`), ни одной зелёной от молчания. Отрицательная пара к следующей строке.
- Дано: дерево после implementer; когда та же команда; тогда rc 0, `KLETKI=43 ZELENYE=43` — на станции с установленными валидаторами клетка z01 сверяет их sha с пинами; без установки z01 зелёна строкой `LIVE_PREDPOSYLKA` в выводе (наблюденный отказ, не пропуск).
- Правило: `bash fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh --stabs` → rc 0, `OBMANOK=11 POIMANY=11 ZHIVYH=0`; пары «дефектная реализация — различающий вход» заданы данными `stabs.tsv` (имя файла, заменяемый файл субъекта, клетка), не прозой этого контракта. Шесть оболочечных дефектов: успех по тексту вывода (v07), пропуск отсутствующего инструмента (v06), запуск без сверки sha (v05), режим bash без `bash -n` (v09), дом-резолв удалён — только шов (v18), пин только для шва — подмена в PATH проходит (v21); три движковых: схема-пустышка `{}` (v13), движок без сверки версии (v16), схема не читается — валидность по одному полю `mode` (v23); два канонных: подстрока вместо разбора (k02), отличие без пути (k03).
- Правило (матрица Д§3.2, каждая — отдельной командой клетки): для 11 канон-входов `matrix/` `python3 scripts/check_canon_fragment.py <вход> runtime-r0 matrix/canon.yml` → две честные записи rc 0 (вторая — эквивалентная запись с иным порядком ключей, кавычками и flow-списком); девять мутаций rc 1 с путями: `runs-on`, `runs-on`, `steps[0].uses`, `steps[4]`, `steps[2].if`, `container.image`, `steps[0].uses`, `steps[2].env.BASE`, `steps[2].working-directory`; грамматика rc 2: `broken.yml` → `CANON_UNPARSEABLE`, чужой job-id → `CANON_JOB_MISSING`, отсутствующие файлы → `CANON_ABSENT`, канон-список → `CANON_FRAGMENT`, среда без pyyaml → `CANON_ENV`.
- Правило (обёртка): `validate_std.sh workflow|bash|json` — rc-контракт инвариантов 1-3; в частности: подменённый бинарь → rc 2 `VALIDATOR_PIN: actionlint` (никогда 0), отсутствующий → rc 2 `VALIDATOR_MISSING: actionlint`, лгущий бинарь (успех в тексте, rc 1) → rc 1, `bash` на сломанном синтаксисе → rc 2 `SYNTAX: bash -n` (замер `bash -n`), json на нарушающем документе → rc 1 `JSON_INVALID:`, на неразборчивом → rc 2 `JSON_UNPARSEABLE`, движок не той версии → rc 2 `ENGINE_VERSION: jsonschema`, неизвестный режим → rc 2 `NOT_IMPLEMENTED`.
- Правило (резолв и пин БЕЗ швов бинарей — среда клетки без `VALIDATE_STD_ACTIONLINT/SHELLCHECK/PYTHON`, дом установки подставлен батареей в `HOME`): пин-совпадающий бинарь в доме → rc инструмента, т.е. установленный бинарь ЗАПУСКАЕТСЯ (honest.yml → 0); подмена в доме → rc 2 `VALIDATOR_PIN: actionlint`; бинарь только в PATH с иным sha → rc 2 `VALIDATOR_PIN: actionlint`; строки пина нет → rc 2 `VALIDATOR_MISSING: actionlint`; бинаря нигде нет → rc 2 `VALIDATOR_MISSING: actionlint`. Каждая ветвь резолва и каждое именованное состояние пина имеет клетку (v18–v22); пин-файл мира батареи (`VALIDATE_STD_PINS`) — конфигурация мира, не шов резолва: без него клетка «пин-совпадающий бинарь в доме» неисполнима в голом прогоне после implementer (пины репо ≠ двойник) и ломает строку «голый прогон после implementer зелёный».
- Правило (json по ПЕРЕДАННОЙ схеме — каждая обещанная ограничилка различима своей клеткой): вторая пара «схема/документ» (`shema2.json`: required, типы, `additionalProperties:false`; `dokument_para2.json`: `mode` валиден, лишнее поле, `ves` не числом) → rc 1 `JSON_INVALID:/` c именем лишнего поля; третья пара — изолированные нарушения: только required (`dokument_tolko_required.json`) → rc 1 `JSON_INVALID:` `'ves' is a required property`; только тип (`dokument_tolko_tip.json`) → rc 1 `JSON_INVALID:/ves` `is not of type` (v23–v25).
- Правило (установка): `bash ops/server/install.sh validators` с артефактом, чей sha256 ≠ пину → именованный отказ ≠ 0 и ничего не установлено; с честным артефактом → бинари в `$HOME/.local/state/dev-harness/validators/<инструмент>/<версия>/`, `install.sh verify` зелёный; `ops/server/README.md` несёт раздел валидаторов. Живая установка на станции — шаг реализации, её принимает ревьюер (класс риска обычный).
- Дано: среда без pyyaml/jsonschema (python3 без site-packages в PATH); когда любая судящая команда батареи; тогда rc 2, stderr `LIVE_PREDPOSYLKA: нет модуля …` — именованный отказ, не ложные клетки и не зелёное молчание.

ПРЕДПОСЫЛКИ:
- setting станция и CI-раннеры предоставляют bash и python3; канон-клетки батареи — python3-pyyaml (подтверждён в CI семей 122/143)
- setting шаг CI 189 не требует secrets/variables/environments репозитория и ничего не скачивает; скачивание артефактов валидаторов — только на станции (implementer)

## Незаполненные требования:
нет

## Зоны и проводка
ЗОНА architect: contracts/189-standartnye-validatory-i-kanon.md fixtures/workshop_project/standartnye_validatory_189/
ЗОНА implementer: scripts/validate_std.sh scripts/validate_std_json.py scripts/check_canon_fragment.py ops/server/validators.tsv ops/server/install.sh ops/server/README.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 159 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 166 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 167 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 169 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 170 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 172 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 173 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 174 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 175 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 182 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 185 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 186 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только сгенерированный шаг 189; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 159 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 166 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 167 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 169 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 170 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 172 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 173 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 174 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 175 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 182 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 185 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 186 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка шага 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 159 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 166 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 167 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 169 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 170 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 172 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 173 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 174 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 175 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 182 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 185 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 186 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер 189; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/install.sh — 074 только новый режим `validators`; существующие режимы и снимки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/install.sh — 081 только новый режим `validators`; существующие режимы и снимки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/install.sh — 090 только новый режим `validators`; существующие режимы и снимки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/install.sh — 093 только новый режим `validators`; существующие режимы и снимки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/install.sh — 186 только новый режим `validators`; существующие режимы и снимки неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 074 только новый раздел «Валидаторы»; существующие разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 081 только новый раздел «Валидаторы»; существующие разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 085 только новый раздел «Валидаторы»; существующие разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 093 только новый раздел «Валидаторы»; существующие разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 175 только новый раздел «Валидаторы»; существующие разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 186 только новый раздел «Валидаторы»; существующие разделы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 997 только новый раздел «Валидаторы»; существующие разделы неизменны.
CI-проводку собственного шага и его замер orchestrator коммитит после freeze: `gen_ci_steps.sh --write`, `--check` rc 0; строка `step check:standartnye-validatory-189-family-selftest <вес> bash fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh --stabs` (режим `--stabs` не требует pyyaml/jsonschema на раннере — Существующее); полная батарея (`--repo .`) — станционная приёмка реализации.

ПРОВОДКА:
- guard=fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh
ПРОВОДКА-ЭНФОРСМЕНТ: чистый энфорсмент — гвард-скрипт батареи красен (rc 1) на любом дереве без валидаторов и зелён после; поведенческой нормы новой нет: дисциплина «формат судят каноном/генерацией из единого источника» уже вложена в задания оркестратором (ADOPTION §5 «А»), повторять её ролью не нужно.
