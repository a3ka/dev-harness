# Контракт 187а — двери и скрипты архитектуры в процессе станции

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — меняются двери процесса, не права/роли БД, авторизация, деньги, ПД/health-данные и согласия или юридически значимые действия.
КОНТЕКСТ: docs/owner/2026-11-10-plan-i-pravila-arhitektury.md §Восстановлено из решений 2026-11-08…10, пункты 1–9; /home/harness/consultant/spec11/ARCH-IN-WORKFLOW-SPEC.md §4–§8 (источник проектирования, не runtime-зависимость); NABLIUDENIA.md Н-442. 187а — только механические двери. Роли и подача находок — отдельный предмет 188 «187б: роли по архитектуре».

## Существующее

- Frozen 170 уже требует `scripts/make_task.sh --arch-component` и brief из **локального** `R/architecture/`; зелёная батарея `fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` обязана пережить cutover. `STRUCTURE.md` приходит из contextPack 095 и остаётся. После 167 локальная копия архитектуры бэкенда удаляется: переход к закреплённому коммиту lock требует адресного v+1 170 с разрешением владельца. До него не выдавать несовместимый cutover 187а за done. Ранее поддержанные роли с brief с правилами/без сохраняются.
- 095/103/161a уже проводят `make_task`, project contextPack, `--repo` и разделение проектных/инструментальных задач. 996 разрешает профильные `workflowPaths`; признак backend — эффективный `repoId=Complior-back`, не наличие `.harness` (также есть у mob). В backend `architecture.lock.json` закрепляет точный коммит отдельного `CompliorOS-architecture`; читать модель из verify-pin клона, не из HEAD и не из локальной `architecture/`. `STRUCTURE.md` остаётся; `docs/ARCHITECTURE.md` исключается из backend contextPack. Миграция проектного профиля — предпосылка, не скрытая правка проекта.
- `scripts/freeze_contract.sh`, `scripts/pre_critic.sh`, `scripts/done_contract.sh` уже ведут frozen/critic/done, но не связывают область с компонентами модели, результат `check --base`, check-run `arch` на финальном SHA и строку вердикта. 167 проекта держит движок, `bindings.json`, pin и CI: харнесс не запускает движок в done. 186 ведёт хранителя. 188 отдельно проводит нормы ролей, включая автора строки задания и вызов хранителя.

## Предмет, вход и порядок

Только кодовый предмет проекта `repoId=Complior-back` в профильных `workflowPaths.contracts` получает требования 187а. Харнесс, mob, документальные задачи и контракты модулей отдельного репозитория архитектуры не получают новый отказ. Отсутствие локальной `R/architecture/` после 167 НЕ переводит backend в legacy. Профиль читается существующим резолвером; компонент определяет закреплённая версия модели. Если pin не разрешается — именованный отказ до заморозки, не brief из HEAD.

`scripts/make_task.sh` для backend кодового задания требует самостоятельную строку `АРХИТЕКТУРА: L1|L2|L3 <id,…>`; ID `[A-Za-z0-9_][A-Za-z0-9._-]*`, список непустой без дублей и прозы. Пустая/отсутствующая строка — `ARCH_LINE_MISSING`; L3 — отказ до решения владельца. Для каждого продуктового пути `ЗОНА implementer:` задания вызывается `node tooling/checks/cli.js locate --path <путь>` закреплённой модели; неразмещённый путь — `PATH_WITHOUT_COMPONENT`, размещённый в ином компоненте — `ARCH_ZONE`. Сверяются ВСЕ объявленные пути и компоненты, не только первый. Кто пишет строку задания — норма 188; 187а судит её наличие и смысл на входе двери.

`make_task --arch-component` доставляет brief `--compact` из **точного** SHA `architecture.lock.json`: `--with-rules` для architect/critic/arbiter, без него для implementer/adversary/reviewer. Две версии модели (local и lock) в одном пакете не смешиваются; `STRUCTURE.md` присутствует, устаревший `docs/ARCHITECTURE.md` в backend пакете отсутствует. Отсутствие локального `architecture/` не мешает закреплённому brief.

`scripts/pre_critic.sh --repo R` через `scripts/check_architecture_contract.sh` запускает `check --base` закреплённой модели против утверждённого снимка: rc 0 продолжает при прочих зелёных ногах, rc 1 — `ARCH_CHECK`, rc 2/`NOT_EVALUATED` — `ARCH_NOT_EVALUATED`, никогда зелёный результат. Точное сообщение об отказе доступно судье; решение критика о содержательной архитектуре — норма 188.

`scripts/freeze_contract.sh` проверяет HEAD-блоб применимого backend-контракта: самостоятельная строка `АРХИТЕКТУРА:` по той же грамматике, для каждого продуктового пути `ЗОНА implementer:` — `locate --path`, компонент в списке строки и путь внутри `implementationPathHint` этого компонента (граница компонента, не строковый prefix). Неразмещённый путь — `PATH_WITHOUT_COMPONENT`, чужой — `ARCH_ZONE`. Требуемая операция имеет схемы входа/выхода и не DRAFT, иначе `ARCH_DRAFT`. Отказ не создаёт frozen-тег и не меняет реестр.

`scripts/done_contract.sh` по финальному SHA продуктового main читает успешный check-run `arch` CI проекта по ЭТОМУ SHA: чужой SHA, отсутствующий, красный, skipped или `NOT_EVALUATED` → `ARCH_CI`; движок в done не запускается. Вердикт reviewer на OBJECT содержит самостоятельную непустую строку `СВЕРКА-АРХИТЕКТУРЫ:`; без неё `ARCH_REVIEW`. Отказ не создаёт done-тег. Содержательная сверка reviewer — предмет 188, 187а проверяет только свидетельство на двери.

ИСТОЧНИК: `путь@sha256 §раздел` модели пока нельзя честно предъявить: `sourceCanon` не включает модель, `module.js` не несёт разделов. ОСТАТОЧНЫЙ РИСК (cognitive-only): человек неверно интерпретирует поле модели; ловец — critic и reviewer предмета 188 по exact pin и diff, не ложная ссылка на `module.js`.

## Приёмочный критерий

- Дано: автономные toy-repo продукта и модели со своими `.git`, конформная грамматика CLI, закреплённый коммит A модели и отличный HEAD B; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`; тогда rc 0, каждая из 25 независимых клеток сообщает свой rc и причину. Валидный контрпример сохраняет инвариантность к значениям и расходится на конформном входе. Когда тот же скрипт `--stabs`; тогда rc 0, 23 обманных стаба пойманы каждый собственной различающей клеткой; отсутствие клетки/непойманный стаб → rc 1.
- Дано: те же входы с ещё не реализованными дверями; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`; тогда rc 1 с независимыми красными клетками; после реализации rc 0. Парные корректные входы rc 0. Скрипт обращается к публичным дверям `make_task`, `freeze_contract.sh`, `pre_critic.sh`, `done_contract.sh`, не только к toy-оракулу.
- Дано: backend toy без строки задания, с пустой строкой, L3 или немаппленным путём; когда `make_task` собирает пак; тогда rc 1 (`ARCH_LINE_MISSING`/`ARCH_OWNER`/`PATH_WITHOUT_COMPONENT` соответственно), пак не создан. Для валидного задания rc 0; brief из A, не B; `--with-rules` ровно для architect/critic/arbiter; `STRUCTURE.md` есть, `docs/ARCHITECTURE.md` отсутствует. На mob и harness архитектурной строки не требуют.
- Дано: HEAD-контракт backend без строки, с чужой зоной, немаппленным путём или DRAFT; когда `freeze_contract.sh` судит его; тогда rc 1 (`ARCH_LINE_MISSING`/`ARCH_ZONE`/`PATH_WITHOUT_COMPONENT`/`ARCH_DRAFT`), frozen-тег отсутствует. Конформный контракт → rc 0.
- Дано: закреплённая модель `check --base` возвращает 1 или 2/`NOT_EVALUATED`; когда `pre_critic.sh` вызывает `check_architecture_contract.sh`; тогда rc 1 (`ARCH_CHECK` либо `ARCH_NOT_EVALUATED`); при rc 0 модели и зелёных прочих ногах дверь rc 0.
- Дано: reviewer с упоминанием `СВЕРКА-АРХИТЕКТУРЫ:` только внутри чужой строки либо отсутствующий/чужой/красный/skipped check-run `arch` на финальном SHA; когда `done_contract.sh` судит вход; тогда rc 1 (`ARCH_REVIEW` либо `ARCH_CI`), done-тег отсутствует. При самостоятельной непустой строке свидетельства и успешном check-run на точном SHA rc 0.
- Дано: frozen 170 до санкции v+1; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` и `--repo .`; тогда rc 0 на текущей версии. Cutover источника brief происходит только после согласованного v+1 170, без изменения остальных обязанностей 170.
- Дано: исправленный черновик; когда `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md`, затем `bash scripts/check_precision_gate.sh . contracts/187-arhitektura-v-processe.md`, затем `bash scripts/check_ceilings.sh .`; тогда каждый rc 0. После реализации `bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md` → rc 0; CI вызывает батарею 187 через `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, а `scripts/check_architecture_contract.sh` подключает прямым вызовом `bash scripts/check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md`.

## Модель угроз

ЗАЩИЩАЕТ:
- От заморозки вне объявленных компонентов и DRAFT, от ложного зелёного rc 2 модели.
- От done по зелёному чужого SHA или без свидетельства reviewer.
НЕ ЗАЩИЩАЕТ:
- От ложной модели/сознательного обхода project CI; движок и суд проекта владеют этим свойством.
- От человеческой ссылки на модель как `ИСТОЧНИК:` до совместимой поддержки sourceCanon.

ПРЕДПОСЫЛКИ:
- setting Проектный CI предоставляет check-run `arch` на точном backend SHA и закреплённый clone из `architecture.lock.json`; секреты/variables/environments не вводятся предметом 187а.
- setting Проектный профиль исключает `docs/ARCHITECTURE.md` из backend contextPack; отдельная проектная миграция и v+1 170 согласуются до done.

## Зоны и проводка

ЗОНА architect: contracts/187-arhitektura-v-processe.md fixtures/workshop_project/architecture_process_187/
ЗОНА implementer: scripts/make_task.sh scripts/freeze_contract.sh scripts/pre_critic.sh scripts/done_contract.sh scripts/check_architecture_contract.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новый шаг 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ architect: contracts/187-arhitektura-v-processe.md — 993 только собственный новый контракт 187; чужой текст не меняется.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/architecture_process_187/ — 054 только новая семья 187; чужие fixture не меняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/architecture_process_187/ — 055 только новая семья 187; чужие fixture не меняются.

ПРОВОДКА:
- guard=scripts/check_architecture_contract.sh
ПРОВОДКА-ЭНФОРСМЕНТ: двери судят byte-структуру строки, путь/компонент, check-rc, pin и check-run; содержательную архитектурную оценку получают от отдельного предмета 188.

## Незаполненные требования:
нет
