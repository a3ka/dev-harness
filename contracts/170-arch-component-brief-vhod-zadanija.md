# Контракт 170 v2 — бриф компонента из закреплённой архитектуры в contextPack

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — сборка контекста задания, без изменения прав/ролей БД, авторизации, денег, ПД/health-данных и согласий или юридически значимых действий.
КОНТЕКСТ: решение владельца 2026-11-10 ~20:44 UTC «д да» через консультанта; frozen/contracts/170/1; контракт 187а «двери и скрипты» (`frozen/contracts/187/1`) меняет источник архитектуры; слово владельца 2026-11-17: «170 v2 сохраняем в существующем предмете и доводим после технического завершения дверей 187а/188… Разрешаю один дополнительный узкий вызов critic №7 только после предъявленного закрытия блока dd5c16535f — соответствия текста и миров 170 реальной двери 187а, без нового полного поиска». Cutover 187а уже влит в main и принят ревьюером; этот текст описывает РЕАЛЬНУЮ принятую дверь. Эта пачка не правит `scripts/` (зона implementer): предмет — контракт и красная батарея, приведённые к реальной двери.

## Позиция автора — что меняется относительно 170/1 и по вердикту вызова 6

Относительно 170/1 меняется источник брифа в режиме 187а: точный commit из `architecture.lock.json` продукта вместо локального `R/architecture/`. `--arch-component`, роль-зависимое `--with-rules`, строка `STRUCTURE.md` с её manifest-row и общий бюджет 40000 сохраняются; локальная копия в режиме 187а не источник и не имеет права побеждать pin.

По вердикту `verdicts/critic/contracts-170-v2.md` (вызов 6, блок `dd5c16535f`): СОГЛАСЕН — обещание «после cutover `--all` → rc 0» было опровергнуто живым прогоном на реальной двери (31/34 красных). Закрыто приведением ТЕКСТА и МИРОВ к реальной двери (приоритет по слову владельца — дверь принята и лежит в зоне 187): применимость требования флага — по локальному каталогу `R/architecture/`; имена pin-отказов — `ARCH_PIN`; граница брифа — `node tooling/checks/cli.js` внутри закреплённого дерева (вне режима 187а — прежний `npm --prefix`); грамматика pin — ревизия без ограничения 40-hex; строка `АРХИТЕКТУРА:` — со списком, разрезаемым по запятым. Два остатка, не закрываемых в зонах 170, вынесены в «НЕ ЗАЩИЩАЕТ» с именованным владельцем правки: применимость требования флага по lock-файлу без каталога (дверь выдаёт пак без брифа — клетка `lock_without_dir` фиксирует реальное поведение) и запрет символьного pin (дверь обслуживает `commit:"HEAD"` из HEAD клона — клетка `symbolic_pin` фиксирует реальное поведение). Владелец обеих возможных правок — implementer, зоны `scripts/make_task.sh` / `scripts/check_architecture_contract.sh`, предмет 187а.

## Существующее

- Реальная дверь на main: `scripts/make_task.sh` (архитектурная секция: признак режима `arch187_scope` — эффективный repoId `Complior-back` И файл `architecture.lock.json`; в режиме бриф — `arch187_brief` = `node tooling/checks/cli.js brief --compact [--with-rules] --component <id>` из развёрнутого закреплённого дерева, правила — только architect/critic/arbiter; вне режима — `npm --prefix <R>/architecture run brief -- --compact [--with-rules] --component <id>`; отсутствие флага при кодовом предмете и каталоге `R/architecture/` — `ARCH_COMPONENT_NET`; грамматика списка — `ARCH_COMPONENT_ID` до первого вызова брифа; перед каждым брифом строка `COMPONENT: <id>`, секция `=== ARCHITECTURE BRIEF ===` в паке) и `scripts/check_architecture_contract.sh` (библиотека: `arch187_pin`/`arch187_model_prepare` — pin равен значению `.commit`, отказы имени `ARCH_PIN: …`, разрешение `git cat-file -e '<pin>^{commit}'` без проверки 40-hex; `arch187_line`/`arch187_component_set` — строка `АРХИТЕКТУРА:` уровня L1|L2|L3 со списком id через запятую, сравнение наборов после разрезания по запятым; `arch187_locate` — размещение пути по статусному JSON ответа модели; кодовый предмет в режиме судится строкой/зонами/pin до вопроса о флаге).
- Toy-батарея `fixtures/workshop_project/arch_component_170/probe.py` судит публичный CLI на toy-проекте из `fixtures/context_pack_095/_toy.sh`, со своей трассой, профилем, отдельным `.git` модели, npm-границей (легаси-ветка вне режима 187а) и CLI-границей закреплённой модели (режим 187а); backend-миры выполняют предусловия 187а, клетки приведены к реальному поведению двери.
- 187а-батарея `fixtures/workshop_project/architecture_process_187/workflow_probe.py` подаёт модель тем же `ARCHITECTURE_ROOT`; 188 называет так же клон архитектуры. 095 сохраняет `=== MAP ===`, `=== RULES ===`, manifest и бюджет; 996 разрешает effective profile; одно наличие `harness.project.json` само по себе не означает архитектуру.

## Предмет и демаркация

Публичный вход: `ARCHITECTURE_ROOT=<клон архитектуры> bash scripts/make_task.sh --repo R --role ROLE --kind task --contract NNN [--task-file F] [--arch-component id[,id…]]`; `ARCHITECTURE_ROOT` — git-репозиторий модели с коммитом lock. Требование флага (реальная дверь): для `--kind task`, кодового выбранного контракта (грамматика класса одна на все двери — `arch187_code_subject`: документная строка или инлайн-форма 180, значение «кодовый|КОДОВЫЙ» до разделителя, регистр двумя явными формами без `-i`) и ЛОКАЛЬНОГО каталога `R/architecture/` (проект любой: профиль есть и у самого харнесса) отсутствие `--arch-component` даёт rc 1, пустой stdout, первую строку stderr `ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)`. Наличие и содержимое `architecture.lock.json`, repoId и `--kind brief` это требование не включают; кодовый backend в режиме 187а без каталога получает пак без брифа — клетка `lock_without_dir` фиксирует это реальное поведение, остаток в «НЕ ЗАЩИЩАЕТ».

Один флаг принимает непустой список ID по запятым в данном порядке; ID `[A-Za-z0-9_][A-Za-z0-9._-]*`, без пустой записи, slash или `..`. Неконформный список отказывает `ОТКАЗ: ARCH_COMPONENT_ID:` до любого вызова брифа (npm/node), с пустым stdout. Источник брифа при флаге: режим 187а (repoId=Complior-back И файл `architecture.lock.json`, пусть даже пустой) — закреплённая модель; вне режима — локальный `R/architecture/`, а его отсутствие — `ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/ в проекте: <путь>`.

Разрешение pin в режиме 187а (значение `.commit` lock; форма lock — `{"commit":"<ревизия>","workItem":"COMPLIOR-<NNN>"}`): файл пуст или значения нет — первая строка stderr `ОТКАЗ: ARCH_PIN: в architecture.lock.json нет закреплённого коммита`; ревизия, не разрешающаяся в коммит клона (`git -C <корень> cat-file -e '<pin>^{commit}'`), — `ОТКАЗ: ARCH_PIN: коммит <pin> не разрешается в клоне модели: <корень>`; `ARCHITECTURE_ROOT` не задан — `ОТКАЗ: ARCH_PIN: закреплённый клон модели не задан (ARCHITECTURE_ROOT)`; не-каталог — `ОТКАЗ: ARCH_PIN: клон модели не найден: <путь>`. Во всех случаях stdout пуст и бриф не вызывается. Грамматика pin — любая ревизия git без ограничения 40-hex: `commit:"HEAD"` дверь РАЗРЕШАЕТ и обслуживает бриф из HEAD клона (клетка `symbolic_pin`: rc 0, бриф `REVISION:WRONG-HEAD-170`); запрет символьных и сокращённых ревизий — остаток в «НЕ ЗАЩИЩАЕТ». Подстановки HEAD при чтении lock нет: разворачивается ровно значение lock; рабочее дерево клона и локальная копия SHA не заменяют (клетки `empty_lock`, `invalid_pin`, `local_wrong`).

Для каждого ID в порядке списка: в режиме 187а — `node tooling/checks/cli.js brief --compact --component <id>` (для architect/critic/arbiter — с `--with-rules` до `--component`) ВНУТРИ развёрнутого закреплённого дерева; вне режима — `npm --prefix <R>/architecture run brief -- --compact [--with-rules] --component <id>`. Отказ брифа — rc 1, пустой stdout, первая строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id отказавшего>` (режим 187а — «(закреплённая модель не отдала бриф)»; npm — «(npm rc=N): <первая строка stderr проекта>»); пустой бриф — `ОТКАЗ: ARCH_BRIEF_OTKAZ: пустой бриф компонента: <id>`. Брифы идут в пак в порядке входных ID; пак и manifest по-прежнему несут `MAP: STRUCTURE.md :: …` / `map<TAB>STRUCTURE.md<TAB>…`, общие профильные rows и бюджет 095 без отдельного лимита (`режь задачу: … > 40000`).

Шов с 187а. Строка `АРХИТЕКТУРА:`, зоны `locate` и разрешение pin — обязанности 187а; 170 v2 их не переопределяет и не связывает ID флага с ID строки. Для кодового предмета в режиме 187а дверь судит строку/зоны/pin ДО вопроса о флаге: клетка `empty_lock_required` (пустой lock без флага) удостоверяет `ARCH_PIN`, а не `ARCH_COMPONENT_NET`. Backend-миры батареи конформны 187а на реальной двери: кодовый контракт несёт `АРХИТЕКТУРА: L1 api.identity,worker.events` со всеми ID флага (список строки разрезается по запятым — `arch187_component_set`), путь зоны `scripts/toy.sh` закреплённая модель размещает в `api.identity`, reviewer получает тот же текст через `--task-file`.

Конформный контрпример — проект с валидными профилем, трассой, контрактом, выполненными предусловиями 187а, lock на коммит A отдельного git-репозитория модели и отличным HEAD B; бриф A для допустимых ID отличается от брифа B и от устаревшей локальной копии. Вход, нарушающий предусловия frozen 187а, контрпримером 170 не служит. Подмена ID/содержимого при сохранении документированного CLI не меняет инвариант: ожидаемые маркеры снимаются в память проверяющего до вызова субъекта, совпадают только самостоятельные строки своих разделов и manifest, не подстрока из другой секции. Пустой lock, lock без `commit` и несуществующая ревизия — конформные отрицательные входы; символьный pin — не отрицательный вход, а фиксируемое реальное поведение двери. Стабы и их различающие входы задаются кодом батареи, не перечнем контракта (Н-39).

## Приёмка

- Правило (честный контроль): `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` → rc 0 и 35 клеток `ok`: бриф закреплённого коммита, две компоненты в порядке ID (`multi_component`), три роли с rules (`architect_rules`, `critic_rules`, `arbiter_rules`), три роли без них (`implementer_plain`, `adversary_plain`, `reviewer_plain`), `STRUCTURE.md` и общие rows/manifest; без локальной копии бриф доставлен (`architect_rules`), локальная копия не источник (`local_wrong`).
- Правило (требование флага): тот же `--model` → rc 0: клетки `required` (lock и каталог), `architecture_missing_required` (без lock, с каталогом), `wrong_project` (не-backend, с каталогом) и `class_dot`, `class_parens`, `class_semicolon`, `class_risk_tail`, `class_upper_c` (LC_ALL=C) удостоверяют rc 1 `ARCH_COMPONENT_NET`; клетка `lock_without_dir` (кодовый backend, lock, без каталога, без флага) — rc 0, пак без брифа: реальная применимость двери.
- Правило (pin и источник): тот же `--model` → rc 0: `empty_lock`, `lock_without_commit`, `empty_lock_required` — `ОТКАЗ: ARCH_PIN: в architecture.lock.json нет закреплённого коммита`; `invalid_pin` — `ОТКАЗ: ARCH_PIN: коммит`; `model_root_unset` — `ОТКАЗ: ARCH_PIN: закреплённый клон модели не задан`; `architecture_missing` (флаг вне режима, без каталога) — `ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/`; все перечисленные — rc 1, пустой stdout, ноль вызовов брифа; `symbolic_pin` — rc 0 и бриф `REVISION:WRONG-HEAD-170` (реальная грамматика pin); `local_without_lock` (флаг вне режима, устаревшая локальная копия) — rc 1, первая строка начинается с `ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (npm rc=`; `document`, `legacy`, `brief_kind` — rc 0 без брифа.
- Правило (список и бриф): тот же `--model` → rc 0: `malformed_id`, `second_malformed_id` — `ARCH_COMPONENT_ID` и ноль вызовов брифа; `brief_failure`, `implementer_brief_failure`, `adversary_brief_failure`, `reviewer_brief_failure` — первая строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events`, пустой stdout; `brief_over_budget` — `режь задачу: … > 40000`.
- Сценарий (реальная дверь — закрытие блока `dd5c16535f`): дано: одноразовая копия main (`git clone --no-hardlinks` из основного чекаута, только чтение) с дельтой 170 — контракт и фикстуры поверх, без коммита; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo <копия>`; тогда: rc 0 — 35 клеток `ok` на реальной двери 187а. Той же батареей `--all` после вливания фикстур в main — rc 0 (шаг CI исполняет её без аргумента); достижимость контрольной формы удостоверяет `--model`.
- Правило (стабы): `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` → rc 0, 22 строки `170 STAB <name> caught @ <свой различающий вход>`, ни одного `ZHIV`.
- Правило (регрессии): прежние contractPack-обязательства 095/169 не регрессируют; `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` и `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` → rc 0.

До критика последовательно: `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md`, `bash scripts/check_precision_gate.sh . contracts/170-arch-component-brief-vhod-zadanija.md`, `bash scripts/check_ceilings.sh .`, `bash scripts/check_threat_model.sh . contracts/170-arch-component-brief-vhod-zadanija.md` → каждый rc 0. До done: `bash scripts/check_provodka.sh . contracts/170-arch-component-brief-vhod-zadanija.md` и `bash scripts/check_project_sources.sh --repo . --contract contracts/170-arch-component-brief-vhod-zadanija.md --stage done` → rc 0.

ПРЕДПОСЫЛКИ:
- setting CI харнесса предоставляет bash, Python 3, git, jq, node и npm; новые secrets, variables, environments и настройки репозитория не нужны.
- setting вызывающая сторона make_task (станция по 187а/188, проектный CI) экспортирует ARCHITECTURE_ROOT — git-репозиторий модели с коммитом lock; без него дверь отказывает `ARCH_PIN` (клетка `model_root_unset`).
- setting шаг CI check:arch-component-170-family-selftest в registry/ci-steps.tsv уже исполняет red_arch_component_170.sh без аргумента (то есть `--all`) на main, где дверь 187а влита; фикстуры v2 вливаются поверх — после вливания шаг зелёный (сценарий «реальная дверь» выше); эта пачка CI не изменяет.

СДАЧА: fixtures/workshop_project/arch_component_170/sdacha_170_v2.md

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
- от молчаливой выдачи кодового предмета с локальным каталогом `architecture/` без выбранного компонента — при любом проекте, с lock или без (клетки `required`, `architecture_missing_required`, `wrong_project`, `class_*`);
- от подмены закреплённого pin модельным HEAD при чтении lock: пустой lock, lock без `commit` и неразрешимая ревизия отказывают `ARCH_PIN` до любого вызова брифа (клетки `empty_lock`, `lock_without_commit`, `empty_lock_required`, `invalid_pin`; подстановки HEAD при пустом lock и применимость свидетеля pin по «валидному SHA» закрыты кодом батареи в `--stabs`); от устаревшей локальной копии в режиме 187а (`local_wrong`: pin побеждает); от первого ID вместо всего списка, неверных параметров `--compact`/`--with-rules`, утечки правил непривилегированным ролям и вывода брифа за общий бюджет 40000; от потери `STRUCTURE.md` и общих правил.
НЕ ЗАЩИЩАЕТ:
- достоверность закреплённой модели архитектуры, права и исполнение продукта;
- freeze/done-гейты, строку `АРХИТЕКТУРА:` и проверку зоны/операции: они принадлежат 187а и проектному 167;
- применимость требования флага по lock-файлу: дверь требует флаг только при ЛОКАЛЬНОМ каталоге `architecture/`; кодовый backend с lock без каталога получает пак без брифа (клетка `lock_without_dir` фиксирует реальное поведение; смена поведения двери красит батарею). Владелец возможной правки — implementer, зона `scripts/make_task.sh`, предмет 187а;
- форму pin 40-hex: символьные и сокращённые ревизии (например `commit:"HEAD"`) дверь разрешает и обслуживает из соответствующего коммита клона (клетка `symbolic_pin` фиксирует реальное поведение). Владелец возможной правки — implementer, зона `scripts/check_architecture_contract.sh`, предмет 187а;
- от кэша извлечённого дерева без ключа SHA между вызовами: в каждом мире батареи один lock; остаточный риск, ловец — reviewer 187а по диффу `scripts/make_task.sh`;
- выбор подходящего человеку component ID: он остаётся входом вызывающей стороны.
