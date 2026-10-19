FAIL
OBJECT=440a65791f2d956134a24b4f62d6884497e383ff

# Критик 109, круг 1

Судим закоммиченные contracts/109-cmp-bck-004-stend-evidence.md и батарею на указанном OBJECT, не будущую реализацию. Набор полный: предмет, команды приёмки, исполнители и зоны присутствуют. Контракт/роль критика не менялись. Complior-back клонирован успешно, B=9d960a0543eb36696b1d767bf208416e774f0a32 сверён checkout и gh api; issue #5 прочитан через gh.

## Граница доказательства

Измерено: заведомо дефектное дерево marker-tree получает control_green=true, оба facts.green=true и 22/22 REJECTED_EXACT; полная батарея, --matrix и все 22 --case возвращают 0. Наблюдаемое выполнение экспортированного harness не меняется от семи отвергнутых мутаций. Реальный document-worker выходит наружу и получает HTTP 200 при зелёном COMPOSE_EGRESS_OPEN.

НЕ утверждаю, что marker-tree прошёл строки 4–5 целиком: это контрмодель офлайн-оракула, не готовый стенд C; полный compose/migration/native integration run этой модели не проводился. Ниже отдельно обозначен [INFERENCE] — перенос дефекта в дерево с честно работающими остальными частями. Отсутствие в строках 4–5 соответствующего наблюдения позволяет сохранить их результаты; ссылка «это поймает adversary» не добавляет исполняемого критерия. Для дефектов, которые строка 5 уже прямо требует проверить (перезапись при повторе, sentinel-токен/email, DB-down), одна зелёная маркерная модель НЕ считается обходом всего контракта.

## Блокирующие находки — один пакет

### Б1. Egress проверяется у неиспользуемой сети

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:48 — критерий #2 issue сопоставлен COMPOSE_EGRESS_OPEN и строкам 4–5, но ни одна живая строка не требует запрещённого исходящего запроса из document-worker/sandbox.
ОБХОД: объявить неиспользуемую сеть с internal: true, а document-worker оставить на default. Батарея зелёная; запрещённый egress работает.
Обход: локальный маркер internal: true принимается за свойство исполняемого сервиса.
Конкретное дерево: marker-tree/backend/compose.dev.yml содержит networks.unused_guard.internal=true; document-worker без networks попадает в default. Compose config отбрасывает unused_guard; docker compose run document-worker wget получает HTTP/1.1 200 OK от example.com, rc0. [INFERENCE] В полноценном C та же замена привязки сети не меняет миграции/ledger, TCP/SQL isolation, DB-down, append-only и scrubber, названные в строках 4–5; все названные клетки остаются успешными, а критерий #2 issue не выполнен.
Простейшая форма фикса: отдельная rc-проверка запрещённого egress из реально запущенного сервиса; оракул должен проверять назначенные ему сети, а не наличие internal в файле. Красная проба — именно реально открытый маршрут, не замена неиспользуемого флага.

### Б2. Drill evidence заменяется мёртвыми словами

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:48 — критерий #5 issue закрыт только DRILL_MEASUREMENTS_ABSENT; строки 4–5 drill не наблюдают.
ОБХОД: backend/scripts/drill.js = `const drill = {rpo: 15, rto: 240, state: 'NOT_RUN'};`, файл нигде не вызывается и ничего не пишет. Получаем 22/22 REJECTED_EXACT, но evidence не содержит ни результата отсутствующего drill, ни реальных измерений при наличии входа.
Обход: литералы drill/rpo/rto/not_run выдаются за сохранение измерений и честный NOT_RUN.
Конкретное дерево: указанный файл существует в marker-tree, функции записи/чтения результатов CMP-BCK-089 отсутствуют. [INFERENCE] В C с честными остальными частями замена только drill collector этим файлом сохраняет строки 4–5, поскольку они не читают результат drill; предмет строки 36 остаётся не сделан.
Простейшая форма фикса: rc-команда на границе collector→evidence с двумя входами: отсутствие результата → сохранённый NOT_RUN, наличие результата → точные DB/object/key hashes, время и фактические RPO/RTO отдельно от целевых констант. Ожидаемые значения задать независимо литералами; проводить backup/drill вместо CMP-BCK-089 не требуется.

### Б3. Нет исполняемой проверки связи осей и hash manifest

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:47 — строка проверяет TCP, SQL role/context isolation, credentials, DB-down, повтор и sentinel, но не требует сверить один сохранённый кортеж с тем же HTTP/SQL взаимодействием, provider-call count и hash артефактов. Строка 48 приписывает ей покрытие критерия #1 issue.
ОБХОД: выполнить настоящий TCP и role/context isolation, честно писать append-only scrubbed evidence и NOT_RUN при недоступной БД, но записывать sql_before/sql_after из другого запроса, provider_calls=0 всегда и input_hashes='sha256' вместо хешей; RECORD_AXES и остальные литералы оставить в недостижимом коде. Все явно перечисленные проверки строки 5 могут выполниться, полный предмет строки 33 — нет.
Обход: список названий осей и наличие слов подменяют произведение наблюдаемых значений.
Конкретное дерево: в marker-tree экспорт record возвращает только {mode:'RUNTIME',http_response:{status:200}}, а все маркеры находятся вне пути выполнения; полная батарея rc0/22 REJECTED_EXACT. Семь мутаций, включая SQL/role/provider/hash/tuple, не меняют результат реального node-вызова record. [INFERENCE] Для обхода всех живых клеток этот декой добавляется к описанному выше честному транспортному/изоляционному слою; повреждается только корреляция/содержимое evidence, которое строки 4–5 не сравнивают. Измеренный офлайн-результат не выдаётся за запуск такого полного C.
Простейшая форма фикса: rc-проба читает фактический sink одного реально выполненного взаимодействия, проверяет корреляцию request/response и SQL before/after, роль, независимо известное число provider calls и SHA-256 известных входных bytes. Нужны различимые значения/два взаимодействия, чтобы чужой snapshot и константа не проходили. Ожидания — литералы, не вычисление из субъекта. Н-39: привязку дефектных стабов к наблюдаемым ветвям делает архитектор кодом, не таблицей обещаний в контракте.

### Б4. Объявленная ПРОВОДКА не подключена

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:73 — противоречие AGENTS.md §Воркфлоу майлстоуна: каждый guard-канал должен существовать и быть подключён; грамматика/механизм 038. Это нормативное исключение: отдельный обход для блокирования не требуется.
Обход: объявление guard выдаётся за проводку, хотя hook/workflow его не вызывает.
Конкретное дерево: OBJECT. `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic109/h contracts/109-cmp-bck-004-stend-evidence.md` → rc1: `проводка: guard не подключён: fixtures/workshop_project/stend_109/probe.py не вызывается в .githooks/ или .github/workflows/`.
Простейшая форма фикса: объявить и обеспечить законную проверяемую проводку в поддерживаемый потребитель; внешняя зависимость не требует притворяться, что подключение уже есть. Исполнителя и путь потребителя включить в границы поставки. Приёмка судами сама по себе механизм 038 не удовлетворяет.

## Советы, не дополнительные блокеры

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:46 — count=13 не соответствует составу закреплённой базы: gh api и checkout показывают db/014_api_reads_migration_ledger.sql; существующий health.test.js ожидает schema_version=14. Уточнить полный целевой ledger и запуск migrator. Это несовместимость/риск ложного красного, не названный обход, поэтому не отдельный блокер.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:35 — ROOT_SERVER_PRESENT проверяет только два is_file. Замена обоих historical файлов на `export {};` сохраняет полную батарею rc0. Но server/ вне зоны implementer, поэтому зональный/ревью-гейт может это остановить: не выдаю дефект одной батареи за доказанный обход всего процесса. Для старого evidence полезна проверка против B, а не только повтор двух новых прогонов.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:44 — ожидаемые имена причин в CASES действительно литеральны и не читаются из вывода субъекта. Проблема не в вычислении expected из actual, а в наблюдаемости: семь отвергнутых мутаций на модели не меняют экспортированное поведение. Не требовать определённых названий внутренних переменных вместо свойств внешнего результата.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:59 — precision gate rc0; строки ЗОНА/ПЕРЕСЕЧЕНИЕ разбираются. Внешний корень Complior-back назван прозой, но этот запуск гейта идёт по реестру dev-harness; не следует считать его доказательством реального enforcement авторства во внешнем репозитории. Новые пути проводки из Б4 надо включить явно.

## Карта семи критериев issue #5

1. TCP↔SQL той же команды/роли и hash manifest: присутствует карта, неполное наблюдаемое доказательство — Б3.
2. API без DDL/gateway-send, запрещённый egress: credentials/isolation названы строкой 5; egress обходится — Б1. Отдельный доказанный обход API-полномочий в этом круге не предъявлен.
3. Остановленная БД → FAIL/NOT_RUN, не fixture success: явно требуется строкой 5; статического NOT_RUN недостаточно, но самостоятельного обхода всей строки не доказано.
4. Append-only и scrubber: строка 5 прямо требует повтор и отсутствие sentinel-токена/email; мёртвые wx/scrub в модели — обход только офлайн-части, не самостоятельный блокер.
5. Drill measurements отдельно от целей / отсутствие → NOT_RUN: Б2. Откладывание самого drill законно, отсутствие записи NOT_RUN — нет.
6. Чистый compose, migration-before-API, ledger/repeat/damage: живая строка 4 явно есть; pin B расходится с числом 13 — совет выше.
7. Native PG18/TCP, role/context isolation и API credentials: живая строка 5 явно есть. Полная реализация ещё не предъявлена, её успех не утверждается.

sourceCanon контрактом не объявлен; полнота проверена против непосредственно полученных семи критериев issue и названных источников B. Docker доступен, поэтому отговорка «нет docker» не использована. Полный native runtime не прогонялся; NOT_RUN здесь — граница доказательства критика, не зелёная приёмка C.

## Сырые команды и результаты

Рабочий каталог команд harness: /tmp/dev-harness-verify/Critic109/h.

- `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic109/h && git -C /tmp/dev-harness-verify/Critic109/h checkout origin/wip/109/architect` → rc0, HEAD 440a6579.
- `git clone ssh://git@github.com/a3ka/Complior-back.git /tmp/dev-harness-verify/Critic109/back` → rc0; `git checkout 9d960a0543eb36696b1d767bf208416e774f0a32` в back → rc0.
- `gh api repos/a3ka/Complior-back/commits/9d960a0543eb36696b1d767bf208416e774f0a32 --jq '{sha:.sha,message:.commit.message}'` → rc0, тот же SHA, merge PR #149.
- `gh issue view 5 --repo a3ka/Complior-back --json body --jq .body` → rc0, семь критериев прочитаны.
- `gh api 'repos/a3ka/Complior-back/contents/db?ref=9d960a0543eb36696b1d767bf208416e774f0a32' --jq '.[].name'` → rc0, 001…014.
- `npm --prefix backend ci` в back → rc0 (предупреждение EBADENGINE: ожидается Node24.22.0, фактически v26.5.1).
- `python3 fixtures/workshop_project/stend_109/probe.py` → rc2: `the following arguments are required: --repo`.
- `python3 fixtures/workshop_project/stend_109/probe.py --repo /tmp/dev-harness-verify/Critic109/back --out /tmp/dev-harness-verify/Critic109/base` → rc1; ровно COMPOSE_MISSING, DRILL_MEASUREMENTS_ABSENT, HARNESS_INTEGRATION_TEST_MISSING, HARNESS_MISSING; 1 REJECTED_EXACT / 21 BLOCKED; оба факта true, повреждение и пропуск manifest rc1.
- Та же команда с `--matrix` вместо `--out …` → rc0, 22 строки depends; с `--case nonexistent` → rc2, `109 UNMEASURABLE: EMPTY_SELECTION`.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic109/h contracts/109-cmp-bck-004-stend-evidence.md` → rc0, `OK`.
- `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic109/h contracts/109-cmp-bck-004-stend-evidence.md` → rc0, секция валидна, 7/5 буллетов.
- `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic109/h contracts/109-cmp-bck-004-stend-evidence.md` → rc1, сырой отказ приведён в Б4.
- `python3 /tmp/dev-harness-verify/Critic109/observe_bypasses.py` → rc0: marker-full=0, marker-matrix=0, все case-*=0, nonexistent=2; OBSERVABLE_UNCHANGED для семи мутаций; historical-erased=0; EGRESS_CONFIG default.internal=false. Первые черновые запуски воспроизводителя имели AssertionError/SyntaxError/KeyError; это ошибки подготовки модели, не результаты контракта. Итоговый указанный запуск успешен.
- `docker info` → rc0, Server Version 28.3.3.
- `docker compose -p critic109proof -f /tmp/dev-harness-verify/Critic109/marker-tree/backend/compose.dev.yml run --rm --no-deps document-worker wget -S --spider -T 10 http://example.com` → rc0, `HTTP/1.1 200 OK`, `remote file exists`.
- `docker compose -p critic109proof -f /tmp/dev-harness-verify/Critic109/marker-tree/backend/compose.dev.yml down` → rc0, сеть critic109proof_default удалена.

Артефакты: base/raw.json, marker-report/raw.json, historical-report/raw.json, marker-full.log, marker-matrix.log, case-*.log, compose-config.json, summary.json, observe_bypasses.py и marker-tree/ — в /tmp/dev-harness-verify/Critic109/. Они сохраняются как доказательства круга, не входят в поставку продукта. Полные project-wide suites не запускались.
