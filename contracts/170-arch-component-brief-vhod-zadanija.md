# Контракт 170 v2 — бриф компонента из закреплённой архитектуры в contextPack

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — сборка контекста задания, без изменения прав/ролей БД, авторизации, денег, ПД/health-данных и согласий или юридически значимых действий.
КОНТЕКСТ: решение владельца 2026-11-10 ~20:44 UTC «д да» через консультанта; frozen/contracts/170/1; контракт 187а «двери и скрипты» (`frozen/contracts/187/1`) меняет источник архитектуры; v2 170 предшествует done 187а.

## Позиция автора — что меняется относительно 170/1

Меняется только источник брифа: точный commit из `architecture.lock.json` продукта вместо локального `R/architecture/`. Строка `STRUCTURE.md` и её manifest-row остаются рядом с брифом; правила в brief остаются только у architect/critic/arbiter. `--arch-component` и роль-зависимое включение `--with-rules` сохраняются. Локальная копия не нужна и не имеет права побеждать pin. Разрешение владельца относится только к этой несовместимой с frozen 170/1 замене; 187а реализует cutover `scripts/make_task.sh`, а не эта architect-пачка.

## Позиция автора по вердикту `verdicts/critic/contracts-170-v2.md` (FAIL, вызов 2/2)

- Б-1 СОГЛАСЕН: мир батареи не выполнял предусловия frozen 187а. Теперь кодовый backend-контракт мира несёт `АРХИТЕКТУРА: L1 api.identity,worker.events`, reviewer получает тот же текст через `--task-file`, закреплённое дерево модели отвечает на `node tooling/checks/cli.js locate --path`. Честный control исполняет правило строки и `locate` 187а на том же входе и зелёный на всех клетках: дверь, выполняющая оба контракта, существует.
- Б-2 СОГЛАСЕН: клетки `empty_lock`, `lock_without_commit`, `empty_lock_required`; мутанты подстановки HEAD при пустом lock и применимости по «валидному SHA» пойманы.
- С-1, С-2 СОГЛАСЕН: `ARCHITECTURE_ROOT` — в публичном входе, ПРЕДПОСЫЛКАХ и клетке `model_root_unset`; порядок приземления батареи относительно шага CI — в ПРЕДПОСЫЛКАХ.
- С-3, С-4, С-10, С-11 СОГЛАСЕН: форма npm, хвосты `ARCHITECTURE_NET`, ID отказа brief и шов с 187а названы в предмете.
- С-5 СОГЛАСЕН: стаб отката без lock — настоящий откат к локальной копии, отличный от стаба «требует локальную копию».
- С-6 СОГЛАСЕН: commit lock — ровно 40 строчных hex; клетка `symbolic_pin`.
- С-7 СПОР: кэш без ключа требует вставленной ветки пропуска извлечения, а клетка «lock A → A′» — новый двухвызовный сценарий вне блоков; остаточный риск записан в модели угроз с ловцом.
- С-8, С-9 СОГЛАСЕН: ПЕРЕСЕЧЕНИЕ по `scripts/make_task.sh` пересчитаны по максимальным frozen-тегам; 187а указан тегом.

## Существующее

- Сборщик `scripts/make_task.sh` (170/1) уже доставляет бриф по ID и роли через project npm, добавляет его в `pack_body`, сохраняет `STRUCTURE.md` из `contextPack.rows`, общий manifest и потолок 40000. Сейчас применимость определяет каталог `R/architecture`, а brief исполняется из него; этот локальный источник после перехода 167 отсутствует.
- Toy-батарея `fixtures/workshop_project/arch_component_170/probe.py` судит публичный CLI на toy-проекте из `fixtures/context_pack_095/_toy.sh`, со своей трассой, профилем, отдельным `.git` модели и npm-границей. В v2 те же клетки и собственные различающие входы мутантов проверяют pin, а backend-миры выполняют предусловия 187а.
- 187а (`contracts/187-arhitektura-v-processe.md`, `frozen/contracts/187/1`) задаёт для backend закреплённый SHA отдельного `CompliorOS-architecture`, отсутствие локальной копии, brief `--compact` с `--with-rules` по ролям, сохранность `STRUCTURE.md`, строку `АРХИТЕКТУРА: L1|L2|L3 <id,…>` (`ARCH_LINE_MISSING`, L3 — `ARCH_OWNER`), `locate --path` путей `ЗОНА implementer:` (`PATH_WITHOUT_COMPONENT`/`ARCH_ZONE`) и двери freeze/pre_critic/done. Его батарея `fixtures/workshop_project/architecture_process_187/workflow_probe.py` подаёт модель тем же `ARCHITECTURE_ROOT`; 188 называет так же клон архитектуры. 095 сохраняет `=== MAP ===`, `=== RULES ===`, manifest, 996 разрешает effective profile; одно наличие `harness.project.json` само по себе не означает архитектуру.

## Предмет и демаркация

Публичный вход: `ARCHITECTURE_ROOT=<клон архитектуры> bash scripts/make_task.sh --repo R --role ROLE --kind task --contract NNN [--task-file F] [--arch-component id[,id…]]`; `ARCHITECTURE_ROOT` — git-репозиторий `CompliorOS-architecture` (verify-pin клон) с коммитом lock. Для кодового выбранного контракта backend `repoId=Complior-back` и для любого проекта с файлом `architecture.lock.json`, в том числе пустым, отсутствие флага даёт rc 1, пустой stdout, первую самостоятельную строку stderr `ОТКАЗ: ARCH_COMPONENT_NET:` с подсказкой `--arch-component`; это судится до чтения содержимого lock. Для некодового контракта, `--kind brief` и других проектов без lock прежний путь сохраняется. Наличие/отсутствие локального `R/architecture/` не решает применимость.

Один флаг принимает непустой список ID по запятым в данном порядке; ID `[A-Za-z0-9_][A-Za-z0-9._-]*`, без пустой записи, slash или `..`. Неконформный список отказывает `ОТКАЗ: ARCH_COMPONENT_ID:` до любого вызова brief. Разрешение pin при флаге: нет файла lock, файл пуст или в нём нет значения `commit` — первая строка stderr начинается с `ОТКАЗ: ARCHITECTURE_NET: нет закреплённого коммита`; `commit` не из ровно 40 строчных hex либо не коммит `ARCHITECTURE_ROOT` — с `ОТКАЗ: ARCHITECTURE_NET: lock не указывает на коммит архитектуры`; `ARCHITECTURE_ROOT` не задан или не каталог — с `ОТКАЗ: ARCHITECTURE_NET:`. Во всех трёх случаях stdout пуст и brief не вызывается. Форма lock — `{"commit":"<полный SHA>","workItem":"COMPLIOR-<NNN>"}` (187а); HEAD модели, её рабочее дерево и локальная копия продукта SHA не заменяют. Для каждого ID вызывается `npm --prefix <дерево закреплённого коммита> run brief -- --compact --component "$id"` — форма 170/1, меняется только дерево `--prefix` (было `R/architecture`); для architect/critic/arbiter `--with-rules` стоит до `--component`, для implementer/adversary/reviewer его нет. Отказ brief — первая строка stderr `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id отказавшего>` (в клетке `brief_failure` — `worker.events`), пустой stdout без частичного пака; брифы в contextPack идут в порядке входных ID. Пак и manifest по-прежнему несут `MAP: STRUCTURE.md :: …` / `map<TAB>STRUCTURE.md<TAB>…`, общие профильные rows и бюджет 095 без отдельного лимита.

Шов с 187а. Строка `АРХИТЕКТУРА:` задания и `locate` путей `ЗОНА implementer:` — обязанности 187а; 170 v2 их не переопределяет и не связывает ID флага с ID строки. Имя отказа неразрешимого pin в `make_task` — `ARCHITECTURE_NET` с хвостами выше: 187а требует «именованный отказ», но имени не даёт. Отсутствие флага судится раньше разрешения pin (клетка `architecture_missing_required`). Порядок остальных отказов 170 относительно отказов 187а батарея 170 не судит, потому что её backend-миры конформны 187а: кодовый контракт несёт `АРХИТЕКТУРА: L1 api.identity,worker.events` со всеми ID флага, путь зоны `scripts/toy.sh` закреплённая модель размещает в `api.identity`, reviewer получает тот же текст через `--task-file`.

Конформный контрпример — проект с валидными профилем, трассой, контрактом, выполненными предусловиями 187а, lock на коммит A отдельного git-репозитория модели и отличным HEAD B; бриф A для допустимых ID отличается от брифа B и от устаревшей локальной копии. Вход, нарушающий предусловия frozen 187а, контрпримером 170 не служит. Подмена ID/содержимого при сохранении документированного CLI не меняет инвариант: ожидаемые маркеры снимаются в память проверяющего до вызова субъекта, совпадают только самостоятельные строки своих разделов и manifest, не подстрока из другой секции. Пустой lock, lock без `commit`, символьная ссылка вместо SHA и несуществующий commit — конформные отрицательные входы, не повод пропустить проверку. Стабы и их различающие входы задаются кодом батареи, не перечнем контракта (Н-39).

## Приёмка

- Дано: честный control 170 v2 с правилом строки и `locate` 187а, lock на A, HEAD B и разные локальные данные; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда rc 0 и 34 клетки `ok`: brief A, две компоненты в порядке ID, три роли с rules, три роли без них, `STRUCTURE.md` и общие rows/manifest. Без локальной копии brief всё равно доставлен.
- Дано: кодовый backend без флага при отсутствующем либо присутствующем lock, или проект не-backend с пустым lock без флага; когда тот же `--model`; тогда клетки `required`, `architecture_missing_required`, `empty_lock_required` удостоверяют rc 1 субъекта `ARCH_COMPONENT_NET`. Дано: флаг и lock отсутствует, пуст, без `commit`, равен `{"commit":"HEAD"}` или `'0'*40`, либо `ARCHITECTURE_ROOT` не задан; тогда `architecture_missing`, `local_without_lock`, `empty_lock`, `lock_without_commit`, `symbolic_pin`, `invalid_pin`, `model_root_unset` удостоверяют rc 1 `ARCHITECTURE_NET` с хвостом из предмета (у `model_root_unset` хвост не судится), пустой stdout и ноль вызовов npm. Дано: некодовый предмет либо проект не-backend без lock; тогда `document`, `legacy`, `brief_kind` — rc 0 субъекта без нового отказа.
- Дано: два ID, brief второго возвращает rc 17, либо список с невалидным вторым ID, либо brief превышает 40000; когда тот же `--model`; тогда rc 0: `brief_failure` удостоверяет первую строку `ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events` и пустой stdout, `second_malformed_id` — `ARCH_COMPONENT_ID` и ноль вызовов npm, `brief_over_budget` — отказ `режь задачу: … > 40000`.
- Дано: текущий `scripts/make_task.sh` на main (локальный источник); когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo`; тогда rc 1: 30 клеток красны, зелёны `legacy`, `document`, `brief_kind`, `model_root_unset`. После cutover make_task по 187а и этому тексту та же команда и `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --all` → rc 0; достижимость удостоверяет `--model`: честный control выполняет оба контракта на тех же 34 входах.
- Дано: честный control и мутанты из батареи; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs`; тогда rc 0, 22 строки `170 STAB <name> caught @ <свой различающий вход>`, ни одного `ZHIV`.
- Правило: прежние contractPack-обязательства 095/169 не регрессируют; `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` и `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` → rc 0.

До критика последовательно: `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md`, `bash scripts/check_precision_gate.sh . contracts/170-arch-component-brief-vhod-zadanija.md`, `bash scripts/check_ceilings.sh .`, `bash scripts/check_threat_model.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → каждый rc 0. До done: `bash scripts/check_provodka.sh . contracts/170-arch-component-brief-vhod-zadanija.md` и `bash scripts/check_project_sources.sh --repo . --contract contracts/170-arch-component-brief-vhod-zadanija.md --stage done` → rc 0.

ПРЕДПОСЫЛКИ:
- setting CI харнесса предоставляет bash, Python 3, git, jq и npm/node; новые secrets, variables, environments и настройки репозитория не нужны.
- setting вызывающая сторона make_task (станция по 187а/188, проектный CI) экспортирует ARCHITECTURE_ROOT — git-репозиторий модели с коммитом lock; поставщика на станции пока нет (git grep ARCHITECTURE_ROOT -- scripts roles ops .omp config на main пуст), без него дверь отказывает ARCHITECTURE_NET (клетка model_root_unset).
- setting шаг CI check:arch-component-170-family-selftest в registry/ci-steps.tsv уже исполняет red_arch_component_170.sh без аргумента, то есть --all; фикстуры v2 вливаются в main одним PR с cutover scripts/make_task.sh по 187а, до него --all красный по построению; эта пачка CI не изменяет.

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
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 187 только источник component brief (lock commit вместо локальной копии) и сохранение STRUCTURE.md; строку АРХИТЕКТУРА и locate зон реализует 187а, зона 170 v2 здесь — контракт и красная батарея, не правка скрипта.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только новый component-режим; старые карты, роли и манифест сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 103 только component-режим; профильные пути сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 136 только component-режим; проектный fallback трассы сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 161 только component-режим; state worktree сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 166 только component-режим; модельный выбор сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 168 только component-режим `--kind task`; секция NOTICES `--kind brief` сохранена.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 169 только component-режим; явный путь трассы сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 184 только component-режим; положение и резолвер профиля сохранены.
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
ПРОВОДКА-ЭНФОРСМЕНТ: только чистое исполнение CLI-предмета 170 в существующей двери сборщика; новая поведенческая норма для роли не вводится (038); вход — argv и ARCHITECTURE_ROOT, оба названы в предмете и проверяются публичным CLI.

## Модель угроз

ЗАЩИЩАЕТ:
- от молчаливой выдачи кодового backend-задания без выбранного компонента при отсутствии локальной `architecture/`, отсутствующем или пустом lock;
- от подмены закреплённого SHA модельным HEAD (в том числе при пустом lock, lock без `commit` или символьной ссылке), устаревшей локальной копией, первым ID вместо всего списка или неверными параметрами `--compact` / `--with-rules`; от потери `STRUCTURE.md` и общих правил.
НЕ ЗАЩИЩАЕТ:
- достоверность закреплённой модели архитектуры, права и исполнение продукта;
- freeze/done-гейты, строку `АРХИТЕКТУРА:` и проверку зоны/операции: они принадлежат 187а и проектному 167;
- от кэша извлечённого дерева без ключа SHA между вызовами: в каждом мире батареи один lock; остаточный риск, ловец — reviewer 187а по диффу `scripts/make_task.sh`;
- выбор подходящего человеку component ID: он остаётся входом вызывающей стороны.
