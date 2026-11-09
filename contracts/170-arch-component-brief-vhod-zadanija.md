# Контракт 170 — бриф компонента архитектуры в contextPack кодового задания

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — сборка проектного контекста, без изменения полномочий продукта.
КОНТЕКСТ: решение владельца 2026-11-09, А0-3. Архитектурные freeze/done-гейты относятся к отдельному предмету после 172; в 170 их нет.

## Существующее

- Сборщик `scripts/make_task.sh` собирает `--kind task` через эффективные `contextPack.rows` профиля 095, роль-фильтр, `=== MAP ===` / `=== RULES ===`, manifest и потолок 40000 байт. Выбранный контракт (черновик architect/critic либо frozen для других ролей) уже доступен в `CBYTES` после строк 663–689; отдельной базы классов задач не нужно. `--kind brief` означает оркестраторский бриф и не является архитектурным CLI. `scripts/spawn_agent.sh` потребляет полученный пак без нового шва.
- Toy-мир `fixtures/context_pack_095/_toy.sh` создаёт проект с двумя слоями профиля, контрактом и трассой; `fixtures/workshop_project/arch_component_170/` — прежняя батарея, которую эта редакция заменяет по изменённому решению владельца. `STRUCTURE.md` и строки общих правил — существующие строки `contextPack.rows`, их не заменяют брифом. `harness.project.json` есть и у самого харнесса, поэтому наличие профиля само по себе не доказывает наличие архитектуры.
- В проекте Complior-back после #738 скрипт `architecture/package.json` → `brief: node checks/cli.js brief` принимает `--compact --component` и `--with-rules`; `architecture/README.md` демонстрирует `api.identity`, тест `architecture/checks/test/workflow-v242.test.js` — `worker.events`. Компактный brief дополняет, а не подменяет правила и STRUCTURE.md (README «Architecture-aware development workflow»).

## Предмет и демаркация

Публичный вход: `bash scripts/make_task.sh --repo R --role ROLE --kind task --contract NNN [--arch-component id[,id…]]` (остальные существующие опции сохраняются). Кодовый предмет — отдельная строка `КЛАСС ЗАДАЧИ: кодовый` в фактически выбранном контракте; каталог `R/architecture/` — признак применимости, независимо от repoId. Сочетание `--kind task`, кодового контракта и этого каталога без флага отказывает rc 1 с самостоятельной первой строкой stderr `ОТКАЗ: ARCH_COMPONENT_NET:` и подсказкой `--arch-component`. Без `architecture/` и без флага прежняя выдача сохраняется; документальный предмет и `--kind brief` без флага не получают нового отказа.

Один флаг принимает непустой список ID через запятую в данном порядке; каждый ID — один компонент `[A-Za-z0-9_][A-Za-z0-9._-]*`, без пустой записи, slash или `..`. Неконформный список отказывает `ОТКАЗ: ARCH_COMPONENT_ID:` до запуска npm. При флаге без architecture/ отказывает `ОТКАЗ: ARCHITECTURE_NET:`. Для каждого ID вызывается **проектная команда** `npm --prefix "$R/architecture" run brief -- --compact --with-rules --component "$id"` для architect/critic/arbiter, `npm --prefix "$R/architecture" run brief -- --compact --component "$id"` для implementer/adversary/reviewer. Отказ npm для любого ID даёт именованный rc 1 без выдачи частичного пака. Вывод каждого запуска попадает в contextPack именно для своего ID и роли, а не в ссылку на файл generated/briefs; его порядок соответствует порядку входных ID. Пак и manifest по-прежнему несут `MAP: STRUCTURE.md :: …` / `map<TAB>STRUCTURE.md<TAB>…`, остальные профильные rows и `RULES: …` / `rules<TAB>…`, если они выдавались этой роли ранее. Бюджет 095 включает новый текст, а не обходится отдельным лимитом.

Конформный контрпример — проект с валидным профилем/трассой/выбранным контрактом, каталогом architecture и проектной командой, выдающей различимые брифы для двух допустимых ID; замена ID на другой допустимый и замена содержания брифа не меняют критерий. Оракул содержания снимается в память до вызова проверяемой двери; существующий файл проекта/вывод субъекта не является оракулом. Fixture npm принимает только документированный argv и позволяет различить роль-зависимые rules, порядок двух компонент и сохранность общих контекстных rows. Каждую мутацию судит собственный различающий вход (Н-39).

## Приёмка

- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo` → красная: 170 required KRASNO

До реализации та же команда возвращает rc 1 с отдельными красными клетками `required`, `architect_rules`, `implementer_plain`, `multi_component`; `legacy` (без архитектуры), `document` и `brief_kind` не краснеют.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` → rc 0: честный контроль всех клеток, включая architect/critic/arbiter с rules, implementer/adversary/reviewer без rules, две разные компоненты в одном порядке, STRUCTURE.md и общие правила в паках и manifest; без архитектуры флаг не обязателен.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` → rc 0: каждая строка `170 STAB <name> caught @ <свой различающий вход>`, без `ZHIV`; мутанты и точные ветви задаются кодом батареи, а не прозой контракта.
- После реализации `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` → красная: 170 required KRASNO (до реализации); после реализации rc 0, каждый case зелён. `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` и `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` сохраняют rc 0.

До критика: `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0; до done: `bash scripts/check_provodka.sh . contracts/170-arch-component-brief-vhod-zadanija.md` и `bash scripts/check_project_sources.sh --repo . --contract contracts/170-arch-component-brief-vhod-zadanija.md --stage done` → rc 0.

ПРЕДПОСЫЛКИ:
- setting CI харнесса предоставляет bash, Python 3, git, jq и npm/node; новые secrets, variables, environments и настройки репозитория не нужны.
- setting orchestrator подключает step батареи в registry/ci-steps.tsv, registry/ci-zamery.tsv и .github/workflows/ci.yml после реализации; эта пачка не изменяет CI.

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
- от молчаливой выдачи кодового задания проекта с архитектурой без описания выбранного компонента;
- от подмены набора компонент первым ID или неправильными параметрами `--compact` / `--with-rules`, от потери STRUCTURE.md и общих правил.
НЕ ЗАЩИЩАЕТ:
- достоверность самой модели архитектуры, права и исполнение продукта;
- архитектурные freeze/done-гейты: они выделены владельцем в отдельный предмет после 172;
- выбор подходящего человеку component ID: он остаётся входом вызывающей стороны.
