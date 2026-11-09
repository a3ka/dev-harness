# Контракт 170 — бриф компонента архитектуры как вход кодового задания

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — сборка указателя на версионированный текст модуля, без изменения прав/ролей БД, авторизации, безопасности, денег, ПД/health, согласий или юридически значимых действий.
КОНТЕКСТ: слово владельца 2026-11-09 (А0-3; пакет 2.4.1 целиком в `Complior-back/architecture/`); выдача `id/CONTRACT/170` уже в дереве. Живой `node architecture/checks/cli.js brief --component api.identity` на одноразовом клоне Complior-back возвращает rc 0 и текст о модуле, SHA, расположении, портах, контрактах, требованиях и политике; `brief 170` даёт `UNSUPPORTED_OPTION`. Конкретный `api.identity` на этой версии выдаёт **414 строк**, поэтому текущий пакет для него должен получить отказ по лимиту, а не ложный успех. Брифы меньшего объёма допустимы. Номер PR владельца на импорт архитектуры не является предусловием черновика 170.

## Существующее

- Сборщик `scripts/make_task.sh` — единственная дверь пака 095: CLI `--repo R --role ROLE [--kind task|brief] [--contract NNN] [--model-trace F]`; строки карты из эффективного `contextPack.rows`, `MAP: path :: why`, манифест фрагментов и бюджет `40000`. `--kind brief` — **бриф оркестратора**, не команда архитектурного CLI `brief`; это разные интерфейсы. `scripts/spawn_agent.sh` уже потребляет манифест и не заменяется. В `scripts/make_task.sh:663–689` уже доступен текст контракта из frozen-блоба или разрешённого черновика, откуда извлекается `КЛАСС ЗАДАЧИ:`; добавление отдельного реестра класса или второго сборщика не нужно.
- Резолвер `scripts/profile_resolver.sh` (054/095) читает `harness.project.json` и объявленный слой; эффективное `repoId` служит маркером **именно** `Complior-back`, `contextPack.rows` — существующее место для карты документов. Контракт 095 закрепляет роль-фильтр/происхождение/потолок пака и optional-rows: они сохраняются. Существующий `STRUCTURE.md` в backend contextPack (`kind=map`) заменяется **только в паке с выбранным компонентом**, без правки профиля и без вычеркивания других map-строк. `harness.project.json` самого харнесса также существует, поэтому проверка «любой профиль ⇒ backend» недопустима.
- Пути `scripts/next_id.sh` / `project_paths_resolve` (103/136/996) уже дают профильные workflowPaths; 136 берёт проектную модельную трассу из `<registry>/trace.tsv`, а 169 уточняет явный `--model-trace`-путь. Эту часть и `--print-context` не меняем. Контракты 161 (внешний state/missing optional worktree), 169 (диагноз трассы), 136 (пути) имеют независимые frozen-обязательства: 170 добавляет только module brief в `--kind task`.
- Фикстура `fixtures/context_pack_095/_toy.sh` строит двухслойный проект, `fixtures/workshop_project/model_trace_169/` содержит реальный вызов CLI, модель и отдельные мутанты; семья 170 повторно использует toy-мир, добавляя маленький двойник `architecture/checks/cli.js` и профиль backend, но НЕ требует импорт пакета владельца #625/#721. В `registry/plan.tsv` старый снимок не содержит 170 (нужна отдельная owner-строка до freeze; эта пачка не правит план). `wip/170/architect` — единственная найденная ветка 170, открытых PR с 170 по `gh pr list --search 170` нет; заглушка этого контракта — единственная незавершённая раздача предмета.

## Предмет и демаркация

Публичный шов: `bash scripts/make_task.sh --repo R --role ROLE --kind task --contract NNN [--model-trace F] [--arch-component <id>]`. Ключ принимает ID компонента `[A-Za-z0-9._-]+`, без пустого значения/слеша/`..`/ведущей точки; не трактуется как номер контракта. Применим для всех задач с явным флагом, если в проекте есть `architecture/`. Кодовым предметом считается самостоятельная строка `КЛАСС ЗАДАЧИ: кодовый` (регистр значения несущественен) в фактически выбранном контракте `NNN`. Backend-проект — эффективный `repoId` ровно `Complior-back` **и** каталог `R/architecture/` существует. Только сочетание backend + `--kind task` + кодовый контракт требует `--arch-component`. Если каталога архитектуры нет и флаг не задан, поведение всех проектов (включая backend до импорта, харнесс и mob) остаётся байт-в-байт прежним; документальный контракт и другой проект без флага также не получают новый отказ. `--kind brief` сохраняет старое значение без новых требований.

При явном флаге дверь проверяет `architecture/checks/cli.js` и наличие `node`, затем исполняет **из `R/architecture/`** `node checks/cli.js brief --component <id>`; единственный канонический argv — `brief --component <id>`, не shorthand `brief <id>`. CLI stdout — исходный текст; реализация записывает его в `R/architecture/generated/briefs/<id>.md` лишь после успешного запуска и проверки непустоты и числа строк. Генерация здесь означает материализацию CLI stdout; файл не предполагается существующим ДО вызова (живой пакет 2.4.1 не создал `generated/briefs/` при выдаче stdout). Одна строка текста без финального LF считается одной строкой; ≤300 допустимо, 301 — отказ. Успех: в самостоятельной секции `=== BRIEF ===` ровно `BRIEF: architecture/generated/briefs/<id>.md :: lines=<N>` (N — число строк реально полученного текста), в MANIFEST ровно `brief<TAB>architecture/generated/briefs/<id>.md<TAB>mandatory<TAB>architecture`; тело по ссылке — полученный stdout CLI побайтово. Строка `MAP: STRUCTURE.md :: ...` и соответствующая `map<TAB>STRUCTURE.md<TAB>...` манифеста данного пака заменяются, остальные rows и role-фильтр без изменений. Бюджет пака 095 по-прежнему включает новую строку/манифест; отдельного расширения потолка нет.

Любой отказ до stdout пака: rc 1, самостоятельная первая строка stderr `ОТКАЗ: <ИМЯ>: ...`; без создания/перезаписи generated-файла при ошибке CLI, отсутствии node/cli, пустом или длинном stdout. Имена: `ARCH_COMPONENT_NET` (обязательный флаг не дан, называет `--arch-component <id>`), `ARCH_COMPONENT_ID` (неконформный id), `ARCHITECTURE_NET` (явный флаг без каталога), `CLI_NET` (`checks/cli.js` недоступен), `NODE_NET` (нет node в PATH), `BRIEF_CLI_OTKAZ` (CLI вернул не-ноль, включая неизвестный компонент или неверный argv), `BRIEF_PUSTOJ` (нулевой/пустой stdout), `BRIEF_SLISHKOM_DLINNYJ` (число строк >300), `BRIEF_NE_ZAPISAN` (результат не материализовать). Подмена результата старым generated-файлом при отказе запрещена. Имена не подменяют прежние отказы профиля/трассы/контракта на непрошедших их входах.

Конформный мир: два слоя профильной схемы 095, объявленный workflow, действующая trace TSV, выбранный контракт с `КЛАСС ЗАДАЧИ`, каталог architecture/ с исполнимым `checks/cli.js`, произвольные допустимые id и произвольные содержательные строки брифа. Валидный контрпример инвариантен к подстановке другого допустимого id, к тексту и объёму непустого CLI-результата при той же границе 300, и расходится с честной дверью на конформном входе. Повреждённые CLI/node/file — отдельные названные ветви отказа, не доказательство неправильности нормального брифа.

## Приёмка

- Дано: нынешний make_task без поддержки 170; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo`; тогда rc 1 с независимыми строками `170 required KRASNO` и `170 brief KRASNO`, при сохранении зелёных legacy/document/other_project; это красное предмета, не self-failure фикстуры.
- Дано: честная модель поверх сохранённого до-170 CLI и игрушечная архитектура; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда rc 0, поимённые ветви required/legacy/document/other_project/brief/dynamic_id/limit_300/limit_301/empty_brief/stale_on_reject/malformed_id/missing_node/missing_cli/unknown_component/no_architecture зелёны; CLI-двойник требует строго `brief --component <id>` и сам даёт `UNSUPPORTED_OPTION` на shorthand.
- Дано: обманные реализации; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs`; тогда rc 0 и каждая строка `170 STAB … caught`, ни одной `ZHIV`; в коде каждый мутант адресован собственному отличающему входу (Н-39), а не первая красная точка общей батареи.
- Дано: реализованная дверь; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` (CI-step); тогда rc 0, все независимые клетки зелёны. `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` и `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` сохраняют rc 0 (фrozen соседние обязательства не переписываются).
- До суда `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0; до done `bash scripts/check_provodka.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0. В проекте с профилем также `bash scripts/check_project_sources.sh --stage done` → rc 0. Критерий исполнения — stdout/файл CLI и причины отказов, не статический поиск скопированного текста в скрипте.

ПРЕДПОСЫЛКИ:
- setting CI харнесса содержит bash, Python 3, git, jq и node для игрушечной архитектуры; новый step использует только существующие runner-инструменты, без новых secrets, variables, environments либо настроек репозитория.
- setting оркестратор регистрирует step и замер в registry/ci-steps.tsv / registry/ci-zamery.tsv, вызывает gen_ci_steps.sh --write и --check после реализации.

## Зоны и проводка

ЗОНА architect: contracts/170-arch-component-brief-vhod-zadanija.md fixtures/workshop_project/arch_component_170/
ЗОНА implementer: scripts/make_task.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 карта/manifest/budget/task/brief, 136 project trace, 161 worktree state, 169 явный путь трассы, 996 profile paths сохраняются; новая часть только обязательность компонента и выдача брифа в `--kind task`.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только новый component-режим; старые карты, роли и манифест сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 103 только component-режим; профильные пути сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 136 только component-режим; проектный fallback трассы сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 161 только component-режим; state worktree сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 165 только component-режим; материализация вердикта сохранена.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 166 только component-режим; модельный выбор сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 169 только component-режим; явный путь трассы сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 996 только component-режим; резолвер путей сохранён.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 170; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 170; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 170; чужие строки сохранены.

ПРОВОДКА:
- guard=fixtures/workshop_project/arch_component_170/red_arch_component_170.sh
ПРОВОДКА-ЭНФОРСМЕНТ: только чистое исполнение CLI-предмета 170 в существующей двери сборщика; новая поведенческая норма для роли не вводится (038), пользовательский интерфейс уже полностью задан контрактом и проверяется публичным CLI.

## Модель угроз

ЗАЩИЩАЕТ:
- от молчаливой выдачи кодового backend-задания с общей STRUCTURE.md вместо описания выбранного компонента;
- от неверного argv архитектуры, отсутствия node/cli, неизвестного компонента, пустого/длинного брифа и выдачи старого файла за текущий;
- от принудительной миграции проектов без architecture/ и документальных задач.
НЕ ЗАЩИЩАЕТ:
- достоверность архитектурной модели и runtime-права продукта: модельная «PASS» не доказывает реализацию;
- сокращение текущего `api.identity` с 414 до 300 строк: исправление объёма — отдельное изменение архитектурного пакета владельца;
- способ выбора component id человеком/оркестратором из архитектуры; доставка выбираемого id в CLI — вход вызывающей стороны.
