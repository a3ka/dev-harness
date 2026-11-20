# Контракт 203 — дверь закреплённого брифа: зависимости, кап и причина отказа

КЛАСС ЗАДАЧИ: КОДОВЫЙ. КЛАСС РИСКА: обычный — сборка контекста; права/роли БД, авторизация, безопасность продукта, деньги, ПД/health и согласия, юридически значимые действия не меняются.
КОНТЕКСТ: NABLIUDENIA.md Н-454; слово владельца 2026-11-20 19:24 UTC через консультанта: зависимости выгрузки, кап 40000 не повышать, stderr не глушить. Задание /tmp/dev-harness-verify/task-203-architect-dver-brifa.md — источник раздачи, не зависимость прогона.
СДАЧА: fixtures/workshop_project/dver_brifa_203/SDACHA.md

## Существующее

Сверено на origin/main 1a0b859c8b609825a00e484251f4f8f59ed2b0f4.

- 187/3: scripts/check_architecture_contract.sh разворачивает exact pin через git archive, затем arch187_brief вызывает CLI из выгрузки. node_modules в archive нет; stderr brief направлен в /dev/null. Дорабатывается этот общий шов, не второй сборщик архитектуры. ARCHITECTURE_ROOT уже задаёт установленный клон; fallback .clone lock сохраняется.
- scripts/make_task.sh уже собирает COMPONENT и ARCHITECTURE BRIEF по порядку ID, выбирает --with-rules для architect/critic/arbiter, считает pack_body в байтах и отказывает при превышении 40000. В pinned-ветви теряется причина отказа. Меняются диагностика и именование архитектурного переполнения, не кап или сериализатор.
- frozen 170/1 требует ВКЛАДЫВАТЬ полный stdout брифа, не ссылку generated/briefs; 187/3 меняет источник на pin, но не разрешает удалять содержимое. Поэтому выбран полный inline-бриф либо явный отказ, НЕ внешняя ссылка и НЕ срез обязательных частей. Это не требует v+1 соседнего обещания.
- 188/2 требует для architect схемы операций, semanticInvariant, writers и isolationKeys; 192/1 требует канон вместо нового парсера формата. Полному stdout сохраняются все эти данные, placement, соседние порты, DRAFT/RETIRED, требования и role-rules; 203 не пытается по заголовкам переизобрести или сократить семантику модели.
- Пин Complior-back 6de3ff1211c9b0a67b00b46766f2f9d889cf1719: tooling/checks/cli.js brief --compact вызывает workflow.js renderCompact; собственные контракты, схемы, neighbour ports, resources/requirements, опциональные fitness rules. package.json несёт runtime dependencies acorn/ajv/ajv-formats/metaschema/yaml. Код CLI/workflow/package.json прочитан через GitHub contents на exact SHA; в приёмке сеть и реальный проект не участвуют. Измерение владельца: api.transport без rules = 91445 байт; полный inline не помещается и должен получить предусмотренный ниже именованный отказ с рекомендацией, а не успешный неполный бриф.
- fixtures/workshop_project/architecture_process_187/probe.py уже создаёт автономный продукт со своей .git, профилем и модельной трассой. Новая семья переиспользует world/put/git, запускает настоящий make_task; 187-семья остаётся неизменной. Её dependency-free модель без lock остаётся допустимой.
- registry/plan.tsv ведёт 187/188/189/192/193 в architecture; 189 даёт стандартные валидаторы, не сборку брифа; 193 даёт check_sdacha и pre_critic. Поиск wip/PR: существующая pinned-дельта 187 (PR #943, wip/187/implementer-hotfix-1113), не отдельное решение Н-454. Новый номер уже зарезервирован; старые контракты не редактируются.
- Живые frozen 140/5, 187/3, 188/2, 189/1 сверены по Git-объектам: 140 не владеет make_task/check_architecture_contract; 187 владеет обеими дверями; 188 — ролями; 189 — валидаторами. Общие CI-пути учтены ниже. Перечень пересечений выводится из замороженных деревьев; subject-клетки не зависят от сетевых refs.

## Предмет и инварианты

Готово означает один наблюдаемый результат: make_task выдаёт полный закреплённый бриф в прежнем капе либо именованно отказывает с первой причиной, никогда не выдаёт неполный успешный пак.

1. Выгрузка exact pin остаётся источником CLI и данных. Если в pin есть package-lock.json, его байты сравниваются с package-lock.json установленного клона (ARCHITECTURE_ROOT либо прежний .clone). Только при равенстве и наличии каталога node_modules разрешена ссылка на этот каталог в выгрузке. Lock сравнивается по содержимому, не имени/размеру/HEAD. Нет lock у донора, содержимое отличается, нет node_modules — rc 1 ARCH_BRIEF_DEPS с причиной и рекомендацией установить зависимости exact pin командой npm ci. Pin с runtime dependencies без package-lock.json — тот же отказ. Dependency-free дерево без lock исполняется как прежде, без заимствования node_modules. Сетевой npm ci дверь сама не запускает. До отказа brief не исполняется; cleanup удаляет только временную ссылку/выгрузку, не донор.
2. В успешном паке stdout каждого brief --compact сохранён целиком (кроме прежней нормализации завершающих LF command substitution), в порядке входных ID. --with-rules остаётся у architect/critic/arbiter, остальные роли без него. HEAD клона, локальная architecture/ и иной компонент не подменяют pin. Полнота проверяется сравнением полного текста, не наличием маркера. Модель без внешних зависимостей остаётся зелёным контролем.
3. Размер считает прежний pack_body: ≤40000 байт — прежняя выдача, >40000 в pinned-архитектурном задании — rc 1, пустой stdout, первая строка stderr ОТКАЗ: ARCH_BRIEF_BUDGET: с компонентами, фактическим размером, числом 40000 и рекомендацией «сузьте --arch-component или разделите задание». Ничего не обрезается, кап не повышается, манифест успешного пака не создаётся. Неархитектурное и legacy npm-переполнение сохраняет прежний отказ 095/170. Для api.transport на указанном pin допустим именно этот явный отказ; обещания успешной выдачи 91445 байт внутри 40000 нет.
4. При rc≠0 CLI brief — rc 1 make_task и пустой stdout. Первая строка stderr двери начинается ОТКАЗ: ARCH_BRIEF_OTKAZ:, содержит ID отказавшего компонента и первую строку stderr CLI (CR/TAB нормализуются в пробел; до 200 Unicode-символов, по соглашению существующей npm-ветви). При пустом stderr сообщаются ID и фактический rc CLI. Успешный stdout CLI перед отказом второго компонента не становится частичным паком. stderr успешного CLI не вкладывается в бриф.

Демаркация: конформный вход — прежний профиль/класс/пин 187, допустимые ID 170, Node CLI brief/locate и npm package-lock.json. Независимость от значений: смена SHA, имени каталога, содержания/длины брифа и первой причины при сохранении их роли не меняет критерий. Синтетические миры используют настоящие Git/Node, локальный модуль только в node_modules, два разных коммита и различимые ID. Ожидания снимаются в память ДО субъекта; диск субъекта после него не источник ожидания. Стабы к ветвям привязывает architect по коду, НЕ проза контракта.

## Приёмочный критерий

- Дано автономные миры; когда bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --model; тогда rc 0, честный контроль всех клеток.
- Дано автономные миры и обманки; когда bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --stabs; тогда rc 0, все объявленные адресные предъявления пойманы, ZHIVYH=0; пустой перечень или пропущенная привязка — rc 1.
- Дано поставленная дверь после реализации; когда bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --repo .; тогда rc 0. До реализации та же команда — rc 1, независимые именованные красные клетки dependencies, budget и stderr; ошибка среды — rc 2, не доказательство дефекта продукта.
- Правило: bash scripts/check_provodka.sh . contracts/203-dver-brifa-arhitektury.md → rc 0; bash scripts/check_sdacha.sh . contracts/203-dver-brifa-arhitektury.md --run → rc 0; bash scripts/pre_critic.sh --repo . contracts/203-dver-brifa-arhitektury.md → rc 0. Красный rc 1 production до реализации честно записывается в листе.
- Дано реализация и CI-проводка orchestrator; когда bash scripts/gen_ci_steps.sh --check; тогда rc 0; registry step check:dver-brifa-203-family-selftest запускает bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --repo .; замер этой команды в ci-zamery. Model/stabs остаются самостоятельными командами приёмки, не заменой production CI.
- Правило регресса: bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . → rc 0; замороженные источники, кодовый гейт, ролевые rules и локальная npm-ветвь не мигрируются этим контрактом.

## Модель угроз

ЗАЩИЩАЕТ:
- От исполнения закреплённого CLI без установленных зависимостей либо с несовпадающим lock: содержимое lock и доступность node_modules проверяются до brief.
- От успешного пака с усечёнными схемами, инвариантами, writers/isolationKeys и правилами: весь stdout сравнивается побайтово; при переполнении — явный отказ, не срез.
- От потери первой причины CLI и выдачи частичного пака при отказе второго компонента: проверяются первая строка stderr, rc и пустой stdout публичной двери.
НЕ ЗАЩИЩАЕТ:
- От повреждённого или злонамеренного node_modules при совпавшем lock: совпадение файла не доказывает npm ci; установленный clone — доверенная предпосылка, ловец verify-pin/CI проекта и reviewer.
- От семантической неполноты собственного brief модели: 188 и reviewer по exact pin; 203 сохраняет весь предоставленный stdout, а не доказывает модель.
- От необходимости сузить слишком большой компонент: явный ARCH_BRIEF_BUDGET передаёт решение оркестратору; без нового слова владельца кап не повышается и frozen 170 не заменяется ссылками.

ПРЕДПОСЫЛКИ:
- setting bash, python3, git, jq, node доступны станции и CI; новый self-test не требует сети, secrets, variables или environments.
- setting ARCHITECTURE_ROOT поставляет установленный verify-pin clone с node_modules и совпадающим package-lock.json; установка npm ci — до вызова двери, не скрытое скачивание из неё.

## Зоны и исполнители

ЗОНА architect: contracts/203-dver-brifa-arhitektury.md fixtures/workshop_project/dver_brifa_203/
ЗОНА implementer: scripts/check_architecture_contract.sh scripts/make_task.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

## Пересечения

ПЕРЕСЕЧЕНИЕ implementer: scripts/check_architecture_contract.sh — 187 только зависимости и stderr brief; pin/locate/check/freeze/done не ослабляются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только диагностика pinned brief; pack_body/manifest/кап сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 103 только диагностика pinned brief; профильные пути сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 136 только диагностика pinned brief; трасса сохранена.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 161 только диагностика pinned brief; внешнее state сохранено.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 166 только диагностика pinned brief; выбор моделей сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 168 только диагностика pinned brief; извещение проектов сохранено.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 169 только диагностика pinned brief; путь трассы сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 170 только pinned-отказы; полный inline, порядок, роли и legacy npm сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 184 только диагностика pinned brief; проектный резолвер сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 187 только зависимости, причина и бюджет brief; прочие ворота сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 996 только диагностика pinned brief; project workflowPaths сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 066 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только шаг 203; прочее неизменно.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 203; прочее неизменно.

## Проводка

ПРОВОДКА:
- guard=scripts/check_architecture_contract.sh
ПРОВОДКА-ЭНФОРСМЕНТ: чистый энфорсмент существующего шва 187; новых поведенческих норм нет. Self-test подключает orchestrator после реализации в окне freeze..done, чужие CI-строки не меняются.

## Незаполненные требования:
нет
