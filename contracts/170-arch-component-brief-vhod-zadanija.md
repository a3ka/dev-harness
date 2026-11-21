# Контракт 170 — бриф компонента архитектуры в contextPack кодового задания

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — сборка проектного контекста, без изменения полномочий продукта.
ПРОДУКТ: станция
КОНТЕКСТ: решение владельца 2026-11-09, А0-3. Архитектурные freeze/done-гейты относятся к отдельному предмету после 172; в 170 их нет.

## Существующее

- Сборщик `scripts/make_task.sh` собирает `--kind task` через эффективные `contextPack.rows` профиля 095, роль-фильтр, `=== MAP ===` / `=== RULES ===`, manifest и потолок 40000 байт. Выбранный контракт (черновик architect/critic либо frozen для других ролей) уже доступен в `CBYTES` после строк 663–689; отдельной базы классов задач не нужно. `--kind brief` означает оркестраторский бриф и не является архитектурным CLI. `scripts/spawn_agent.sh` потребляет полученный пак без нового шва.
- Toy-мир `fixtures/context_pack_095/_toy.sh` создаёт проект с двумя слоями профиля, контрактом и трассой; `fixtures/workshop_project/arch_component_170/` — прежняя батарея, которую эта редакция заменяет по изменённому решению владельца. `STRUCTURE.md` и строки общих правил — существующие строки `contextPack.rows`, их не заменяют брифом. `harness.project.json` есть и у самого харнесса, поэтому наличие профиля само по себе не доказывает наличие архитектуры.
- В проекте Complior-back после #738 скрипт `architecture/package.json` → `brief: node checks/cli.js brief` принимает `--compact --component` и `--with-rules`; `architecture/README.md` демонстрирует `api.identity`, тест `architecture/checks/test/workflow-v242.test.js` — `worker.events`. Компактный brief дополняет, а не подменяет правила и STRUCTURE.md (README «Architecture-aware development workflow»).
- Для внешнего state уже есть `_project_state_prepare`, `_state_path_canonical`, `_state_base_is_safe` в `scripts/make_task.sh`: `${TMPDIR:-/tmp}/dev-harness-project-state/<ключ общего .git>/`, канонизация итогового пути и запрет всех checkout проекта и общего `.git`; `context/` — манифест 161. Профильные workflowPaths разрешаются существующим `scripts/profile_resolver.sh`; workflowPaths.state не является разрешением писать pinned brief в checkout. Новый brief использует тот же project state и тот же ключ, а не новый корень состояния.

## Предмет и демаркация

Публичный вход: `bash scripts/make_task.sh --repo R --role ROLE --kind task --contract NNN [--arch-component id[,id…]]` (остальные существующие опции сохраняются). Кодовый предмет — отдельная строка `КЛАСС ЗАДАЧИ: кодовый` в фактически выбранном контракте; каталог `R/architecture/` — признак применимости, независимо от repoId. Сочетание `--kind task`, кодового контракта и этого каталога без флага отказывает rc 1 с самостоятельной первой строкой stderr `ОТКАЗ: ARCH_COMPONENT_NET:` и подсказкой `--arch-component`. Без `architecture/` и без флага прежняя выдача сохраняется; документальный предмет и `--kind brief` без флага не получают нового отказа.

Один флаг принимает непустой список ID через запятую в данном порядке; каждый ID — один компонент `[A-Za-z0-9_][A-Za-z0-9._-]*`, без пустой записи, slash или `..`. Неконформный список отказывает `ОТКАЗ: ARCH_COMPONENT_ID:` до запуска npm. При флаге без architecture/ отказывает `ОТКАЗ: ARCHITECTURE_NET:`. Для каждого ID вызывается **проектная команда** `npm --prefix "$R/architecture" run brief -- --compact --with-rules --component "$id"` для architect/critic/arbiter, `npm --prefix "$R/architecture" run brief -- --compact --component "$id"` для implementer/adversary/reviewer. Отказ npm для любого ID даёт именованный rc 1 без выдачи частичного пака. Полный stdout каждого запуска относится именно к своему ID и роли; порядок компонент соответствует порядку входных ID. Пока полный пак вмещается в потолок 40000, брифы остаются inline. Если полный бриф не помещается в общий пак, сохраняются все его байты (включая UTF-8 и завершающие переводы строк) вне любого checkout проекта и его общего `.git`, в `briefs/<sha256>.txt` существующего внешнего project state. Вместо него в пак входит обязательное чтение с component ID, exact pin (абсолютный путь этого файла), длиной в байтах, sha256 и исполняемой проверкой перед чтением; срезы и увеличение потолка запрещены. При нескольких компонентах из inline переводятся в pin сначала наибольшие брифы (при равенстве — входной порядок), только пока полный пак превышает потолок; остальные остаются inline, порядок выдачи не меняется. Пак и manifest по-прежнему несут `MAP: STRUCTURE.md :: …` / `map<TAB>STRUCTURE.md<TAB>…`, остальные профильные rows и `RULES: …` / `rules<TAB>…`, если они выдавались этой роли ранее. Бюджет 095 включает inline-текст и весь текст указателей, а не обходится отдельным лимитом.

Конформный контрпример — проект с валидным профилем/трассой/выбранным контрактом, каталогом architecture и проектной командой, выдающей различимые брифы для двух допустимых ID; замена ID на другой допустимый и замена содержания брифа не меняют критерий. Оракул содержания снимается в память до вызова проверяемой двери; существующий файл проекта/вывод субъекта не является оракулом. Fixture npm принимает только документированный argv и позволяет различить роль-зависимые rules, порядок двух компонент и сохранность общих контекстных rows. Каждую мутацию судит собственный различающий вход (Н-39).

### Pinned brief — адресный v+1

Меняются только обязательства frozen 170/1:17 и :29 по разрешению владельца 2026-11-20 21:47. Это доставка уже выбранного брифа, не смена источника модели 187: pin файла брифа не подменяет exact commit architecture.lock.json. Рабочий случай — `api.transport` предмета backend 189, 91445 байт; синтетические клетки меняют размер, содержимое и component ID, а не критерий.

Блок каждой pinned-компоненты в `=== ARCHITECTURE BRIEF ===` несёт самостоятельные строки `COMPONENT: <id>`, `PIN: <абсолютный путь>`, `BYTES: <десятичная длина>`, `SHA256: <64 lowercase hex>`, `READ_COMMAND: <JSON-массив argv>` и точную инструкцию из `pinned_model.py:READ_REQUIRED`. READ_COMMAND проверяет доступность, принадлежность каноническому project state, размещение вне checkout/.git, длину и sha256, затем выдаёт полный файл в stdout. JSON-строка сохраняет пути с пробелами без shell-интерполяции; канон команды — `pinned_model.py:READER` и `pointer`, генерация из одного источника, не второй парсер формата.

До успешной выдачи пака сборщик записывает полный файл и выполняет ту же проверку: файл существует, обычный и читаемый, итоговый путь после разрешения symlink безопасен, длина и sha256 соответствуют исходному полному stdout в памяти. Уже существующий pin не перезаписывается и не «чинится» молча: недоступный pin (включая dangling symlink), unreadable, содержимое другой длины или sha256, ссылка внутрь checkout/.git — rc 1, пустой stdout, первая строка stderr `ОТКАЗ: ARCH_BRIEF_PIN: <причина>`. Никакая часть пака до этой двери не выдаётся. Имена причин по свойству: `unavailable`, `integrity`, `outside_state`; системное пояснение допустимо после префикса. Невмещающийся остаток пака и после замены брифов сохраняет прежний отказ `режь задачу: … > 40000`.

Потребитель до работы исполняет READ_COMMAND из выданного пака, останавливается при ненулевом rc и читает stdout целиком при rc 0. Эта команда проверяется живьём после удаления файла, усечения и подмены с сохранением длины: rc 1, пустой stdout и первая строка `ОТКАЗ: ARCH_BRIEF_PIN:`. При корректном pin её stdout побайтно равен полному ожидаемому брифу. Фактическое следование агента инструкции — cognitive-only, ловец: reviewer задания; проверяемый механизм — отказ команды до выдачи любых байтов, а не обещание принудительного управления агентом.

Красное «до реализации v+1» ниже относится к новым клеткам pinned brief на базе 1a0ddc095a9f4d93b21626c6906abd337d3ac1c3; уже реализованные клетки 170/1 остаются зелёными до и после v+1.

## Приёмка

- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo` → красная: 170 brief_pinned_over_budget KRASNO

До реализации v+1 та же команда возвращает rc 1 с отдельными красными клетками `brief_pinned_over_budget`, `brief_pinned_plain`, `brief_pinned_multi`, `brief_pin_missing`, `brief_pin_tampered`, `brief_pin_unreadable`, `brief_pin_checkout`, `brief_pin_git`, `brief_read_missing`, `brief_read_tampered`, `brief_read_same_size`, `brief_no_slice`, `brief_aggregate_budget`, `brief_mixed_small_inline`, `brief_pinned_spaces`, `brief_pinned_external_symlink`, `brief_read_length_pin`, `brief_read_checkout` (обязательства — `DELTA.md`). Клетки 170/1, включая `required`, role-клетки, `multi_component`, `legacy`, `document`, `brief_kind` и `brief_over_budget` с небрифовым контекстом за потолком, зелёные до и после v+1; `brief_small_inline` и `brief_pack_cap` также зелёные.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` → rc 0: честный контроль всех клеток, включая architect/critic/arbiter с rules, implementer/adversary/reviewer без rules, две разные компоненты в одном порядке, STRUCTURE.md и общие правила в паках и manifest; без архитектуры флаг не обязателен.
- Дано: кодовый контракт без `architecture/`, флаг `--arch-component api.identity`; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда: rc 0, отдельная клетка `architecture_missing ok` удостоверяет rc 1 субъекта, пустой stdout и первую строку stderr `ОТКАЗ: ARCHITECTURE_NET:`.
- Дано: два допустимых ID и npm, который на втором выдаёт непустой stdout и rc 17; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда: rc 0, отдельная клетка `brief_failure ok` удостоверяет rc 1 субъекта, пустой stdout (в том числе без первого брифа) и первую строку stderr `ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events`.
- Дано: полный бриф за пределами общего потолка либо сумма брифов не помещается в пак; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда: rc 0, клетки `brief_pinned_over_budget`, `brief_pinned_plain`, `brief_pinned_multi`, `brief_aggregate_budget`, `brief_no_slice` удостоверяют rc 0 субъекта, пак не более 40000, обязательное чтение и точные component/pin/длину/sha256, полный файл вне checkout/.git, полный stdout команды чтения. `brief_pin_missing`, `brief_pin_tampered`, `brief_pin_unreadable`, `brief_pin_checkout`, `brief_pin_git` удостоверяют rc 1 субъекта без частичной выдачи с первой строкой `ОТКАЗ: ARCH_BRIEF_PIN:`. `brief_read_missing`, `brief_read_tampered`, `brief_read_same_size` удостоверяют отказ чтения до работы. `brief_small_inline` удостоверяет прежний inline без pin. `brief_over_budget` и `brief_pack_cap` сохраняют rc 1, пустой stdout и `ОТКАЗ: режь задачу: … > 40000`, когда небрифовая часть сама превышает потолок; весь указатель учитывается в `pack_body`.
- Дано: смешанный большой/малый бриф, путь state с пробелами либо честная ссылка внутри внешнего state; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда: rc 0, клетки `brief_mixed_small_inline`, `brief_pinned_spaces`, `brief_pinned_external_symlink` зелёные. Дано: после выдачи metadata длины изменена при неизменном файле либо pin перенаправлен внутрь checkout; та же команда → rc 0, клетки `brief_read_length_pin`, `brief_read_checkout` удостоверяют отказ команды потребителя rc 1 с пустым stdout и `ОТКАЗ: ARCH_BRIEF_PIN:`.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` → rc 0: каждая строка `170 STAB <name> caught @ <свой различающий вход>`, без `ZHIV`; мутанты и точные ветви задаются кодом батареи, а не прозой контракта.
- После реализации v+1 `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` → rc 0, каждый case зелён. `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` и `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` сохраняют rc 0.

До критика: `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0; до done: `bash scripts/check_provodka.sh . contracts/170-arch-component-brief-vhod-zadanija.md` и `bash scripts/check_project_sources.sh --repo . --contract contracts/170-arch-component-brief-vhod-zadanija.md --stage done` → rc 0.
СДАЧА: fixtures/workshop_project/arch_component_170/SDACHA.md

ПРЕДПОСЫЛКИ:
- setting CI харнесса предоставляет bash, Python 3, git, jq и npm/node; новые secrets, variables, environments и настройки репозитория не нужны.
- setting orchestrator подключает step батареи в registry/ci-steps.tsv, registry/ci-zamery.tsv и .github/workflows/ci.yml после реализации; эта пачка не изменяет CI.

## Незаполненные требования:
нет

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
