# Контракт 187а — двери и скрипты архитектуры в процессе станции

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — меняются двери процесса, не права/роли БД, авторизация, деньги, ПД/health-данные и согласия или юридически значимые действия.
КОНТЕКСТ: docs/owner/2026-11-10-plan-i-pravila-arhitektury.md §Восстановлено из решений 2026-11-08…10, пункты 1–9; /home/harness/consultant/spec11/ARCH-IN-WORKFLOW-SPEC.md §4–§8 (источник проектирования, не runtime-зависимость); NABLIUDENIA.md Н-442. 187а — только механические двери. Роли и подача находок — отдельный предмет 188 «187б: роли по архитектуре».

## Существующее

- Frozen 170 уже требует `scripts/make_task.sh --arch-component` и brief из **локального** `R/architecture/`; зелёная батарея `fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` обязана пережить cutover. `STRUCTURE.md` приходит из contextPack 095 и остаётся. После 167 локальная копия архитектуры бэкенда удаляется: переход к закреплённому коммиту lock требует адресного v+1 170 с разрешением владельца. До него не выдавать несовместимый cutover 187а за done. Ранее поддержанные роли с brief с правилами/без сохраняются.
- 095/103/161a уже проводят `make_task`, project contextPack, `--repo` и разделение проектных/инструментальных задач. 996 разрешает профильные `workflowPaths`; признак backend — эффективный `repoId=Complior-back`, не наличие `.harness` (также есть у mob). В backend `architecture.lock.json` закрепляет точный коммит отдельного `CompliorOS-architecture`; читать модель из verify-pin клона, не из HEAD и не из локальной `architecture/`. `STRUCTURE.md` остаётся; `docs/ARCHITECTURE.md` исключается из backend contextPack. Миграция проектного профиля — предпосылка, не скрытая правка проекта.
- `scripts/freeze_contract.sh`, `scripts/pre_critic.sh`, `scripts/done_contract.sh` уже ведут frozen/critic/done, но не связывают область с компонентами модели, результат `check --base`, check-run `arch` на финальном SHA и строку вердикта. 167 проекта держит движок, `bindings.json`, pin и CI: харнесс не запускает движок в done. 186 ведёт хранителя. 188 отдельно проводит нормы ролей, включая автора строки задания и вызов хранителя.
- CI харнесса исполняет `registry/ci-steps.tsv` через `run_ci_lane.sh`; `gen_ci_steps.sh --check` сравнивает сгенерированные lane/shard-блоки с реестром и резолвит bash-путь, но не требует конкретную команду 187. `check_provodka.sh` проверяет существование и упоминание basename объявленного guard в registry/workflow/hook, не точные аргументы или строку приёмки. Прецеденты: 184 объявляет guard самой батареи; 182 и 185 объявляют функциональную дверь, не отдельную батарею; 186 проводит роли без guard. Замороженный 083/1 объявляет guard батареи, а registry и CI-шаги — пересечение с существующими frozen (083/1, 114 и перечисленные ниже), не новая зона architect.
- Арбитраж 1 по 170 (`verdicts/arbitration/170-granica-obeshchanij.md`, resolved, выход А) распределил ремонт шва: 187 v3 — требование двери, 170 v2 — вход задания; сильные инварианты 170 (полный 40-hex SHA — единственный источник brief; применимый lock без локального каталога не даёт пак без брифа) — ТРЕБУЕМОЕ поведение двери 187а. Действующая дверь обслуживает символьный/сокращённый pin (`cat-file -e '<pin>^{commit}'` разрешает `HEAD`, `git archive` берёт дерево головы) и применимость компонента судит только по каталогу `architecture/` (`elif [ -d … ]`).

## Позиция автора после вызова 2/2

СОГЛАСЕН с единственным блоком `verdicts/critic/contracts-187-v1.md`: прямой CI-вызов `check_architecture_contract.sh` не доказывает выполнение батареи. Guard в ПРОВОДКЕ — bash-обёртка батареи, дверь `check_architecture_contract.sh` — отдельный guard и отдельный шаг. До freeze явный rc-гейт `--wiring .` сверяет **два независимых** точных `step`-вызова в реальном `registry/ci-steps.tsv`; `gen_ci_steps.sh --check` сверяет generated workflow с registry. Ролевой поток остаётся 188.

## Позиция автора v3 (адресный v+1 от frozen/contracts/187/2)

Арбитраж 1 по 170 (выход А; слово владельца на адресный v+1 запрошено и вынесено консультантом, №36, вариант А — АРХИТЕКТУРА) назначил носителем шва этот контракт: обязательства 1–3 арбитража — инварианты двери 187а. v3 — НЕ амнистия дефекта v2 и НЕ новый предмет: замороженные обязательства «точный коммит», «не из HEAD», «отсутствие локальной `architecture/` не отменяет закреплённый brief» восстанавливаются в двери, а не переформулируются. Одно место истины на вход: 187 — требование двери (`scripts/make_task.sh`, `scripts/check_architecture_contract.sh`, implementer 187а), 170 v2 — вход задания и его батарея (`symbolic_pin`, `lock_without_dir`, `empty_lock_required`); клетки 187 совпадают с этой моделью отказа по именам `ARCH_PIN`/`ARCH_COMPONENT_NET` и не дублируют входы 170. 54 клетки/56 стабов батареи 187 сохраняются зелёными; расширение v3 — 61 клетка/63 стаба.


## Предмет, вход и порядок

Только кодовый предмет проекта `repoId=Complior-back` в профильных `workflowPaths.contracts` получает требования 187а. Харнесс, mob, документальные задачи и контракты модулей отдельного репозитория архитектуры не получают новый отказ. Отсутствие локальной `R/architecture/` после 167 НЕ переводит backend в legacy. Профиль читается существующим резолвером; компонент определяет закреплённая версия модели. Если pin не разрешается — именованный отказ до заморозки, не brief из HEAD.

`scripts/make_task.sh` для backend кодового задания требует самостоятельную строку `АРХИТЕКТУРА: L1|L2|L3 <id,…>`; ID `[A-Za-z0-9_][A-Za-z0-9._-]*`, список непустой без дублей и прозы. Пустая/отсутствующая строка — `ARCH_LINE_MISSING`; L3 — отказ до решения владельца. Для каждого продуктового пути `ЗОНА implementer:` задания вызывается `node tooling/checks/cli.js locate --path <путь>` закреплённой модели; неразмещённый путь — `PATH_WITHOUT_COMPONENT`, размещённый в ином компоненте — `ARCH_ZONE`. Сверяются ВСЕ объявленные пути и компоненты, не только первый. Кто пишет строку задания — норма 188; 187а судит её наличие и смысл на входе двери.

`make_task --arch-component` доставляет brief `--compact` из **точного** SHA `architecture.lock.json`: `--with-rules` для architect/critic/arbiter, без него для implementer/adversary/reviewer. Две версии модели (local и lock) в одном пакете не смешиваются; `STRUCTURE.md` присутствует, устаревший `docs/ARCHITECTURE.md` в backend пакете отсутствует. Отсутствие локального `architecture/` не мешает закреплённому brief.


Грамматика pin (v3, обязательство 1 арбитража 170-1): значение `.commit` `architecture.lock.json` — полный 40-hex SHA в канонической форме git (строчные `[0-9a-f]{40}`). Символьный (`HEAD`, имя ветки) и сокращённый pin НЕ принимаются: разрешимость git (`cat-file -e '<pin>^{commit}'`) не заменяет грамматику, «сначала разрешить HEAD в SHA» не является выполнением неизменного lock — после перемещения HEAD клона источником остаётся тот же полный SHA. Неконформный либо неразрешимый pin — именованный отказ `ARCH_PIN` (неконформный: «закреплённый pin не полный 40-hex SHA: <pin>»; неразрешимый: «коммит <pin> не разрешается в клоне модели»), rc 1, пустой stdout, `brief` не вызывается. Судится после строки «АРХИТЕКТУРА:» и до зон (порядок `arch187_line` → `arch187_model_prepare` → `arch187_zones`), ДО вопроса о флаге — безфлаговой вызов с неконформным pin отказывает `ARCH_PIN`, не `ARCH_COMPONENT_NET`.

Применимость требования компонента (v3, обязательство 2 арбитража 170-1): для кодового `--kind task` требование `--arch-component` применимо при локальном каталоге `architecture/` (старое требование frozen 170/1, любой проект — сохраняется, не сужается одним backend) ИЛИ при применимом lock (режим 187а: эффективный `repoId=Complior-back` и файл `architecture.lock.json`), в том числе БЕЗ локальной копии `architecture/`. Кодовый предмет без флага в применимом состоянии — отказ `ARCH_COMPONENT_NET` (rc 1, пустой stdout, пак не выдаётся), не успешный пак без брифа. Требование флага и источник pinned-brief — РАЗНЫЕ предикаты: источник по-прежнему определяется режимом 187а; документальный предмет гейта не получает. Правила ролей, список компонент через запятую (`ARCH_COMPONENT_ID` до первого вызова брифа), сохранность карты/manifest и общий бюджет 40000 — без изменений (обязательство 3).

`scripts/pre_critic.sh --repo R` через `scripts/check_architecture_contract.sh` запускает `check --base` закреплённой модели против утверждённого снимка: rc 0 продолжает при прочих зелёных ногах, rc 1 — `ARCH_CHECK`, rc 2/`NOT_EVALUATED` — `ARCH_NOT_EVALUATED`, никогда зелёный результат. Точное сообщение об отказе доступно судье; решение критика о содержательной архитектуре — норма 188.

`scripts/freeze_contract.sh` проверяет HEAD-блоб применимого backend-контракта: самостоятельная строка `АРХИТЕКТУРА:` по той же грамматике, для каждого продуктового пути `ЗОНА implementer:` — `locate --path`, компонент в списке строки и путь внутри `implementationPathHint` этого компонента (граница компонента, не строковый prefix). Неразмещённый путь — `PATH_WITHOUT_COMPONENT`, чужой — `ARCH_ZONE`. Требуемая операция имеет схемы входа/выхода и не DRAFT, иначе `ARCH_DRAFT`. Отказ не создаёт frozen-тег и не меняет реестр.

`scripts/done_contract.sh` по финальному SHA продуктового main читает успешный check-run `arch` CI проекта по ЭТОМУ SHA: чужой SHA, отсутствующий, красный, skipped или `NOT_EVALUATED` → `ARCH_CI`; движок в done не запускается. Вердикт reviewer на OBJECT содержит самостоятельную непустую строку `СВЕРКА-АРХИТЕКТУРЫ:`; без неё `ARCH_REVIEW`. Отказ не создаёт done-тег. Содержательная сверка reviewer — предмет 188, 187а проверяет только свидетельство на двери.

ИСТОЧНИК: `путь@sha256 §раздел` модели пока нельзя честно предъявить: `sourceCanon` не включает модель, `module.js` не несёт разделов. ОСТАТОЧНЫЙ РИСК (cognitive-only): человек неверно интерпретирует поле модели; ловец — critic и reviewer предмета 188 по exact pin и diff, не ложная ссылка на `module.js`.

## Приёмочный критерий

- Дано: автономные toy-repo продукта и модели со своими `.git`, конформная грамматика CLI, закреплённый коммит A модели и отличный HEAD B; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`; тогда rc 0, каждая из 61 независимых клеток сообщает свой rc и причину. Валидный контрпример сохраняет инвариантность к значениям и расходится на конформном входе. Когда тот же скрипт `--stabs`; тогда rc 0, 63 обманных стаба пойманы каждый собственной различающей клеткой; отсутствие клетки/непойманный стаб → rc 1.
- Дано: те же входы с ещё не реализованными дверями; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`; тогда rc 1 с независимыми красными клетками; после реализации rc 0. Парные корректные входы rc 0. Скрипт обращается к публичным дверям `make_task`, `freeze_contract.sh`, `pre_critic.sh`, `done_contract.sh`, не только к toy-оракулу.
- Дано: backend toy без строки задания, с пустой строкой, L3 или немаппленным путём; когда `make_task` собирает пак; тогда rc 1 (`ARCH_LINE_MISSING`/`ARCH_OWNER`/`PATH_WITHOUT_COMPONENT` соответственно), пак не создан. Для валидного задания rc 0; brief из A, не B; `--with-rules` ровно для architect/critic/arbiter; `STRUCTURE.md` есть, `docs/ARCHITECTURE.md` отсутствует. На mob и harness архитектурной строки не требуют.
- Дано: HEAD-контракт backend без строки, с чужой зоной, немаппленным путём или DRAFT; когда `freeze_contract.sh` судит его; тогда rc 1 (`ARCH_LINE_MISSING`/`ARCH_ZONE`/`PATH_WITHOUT_COMPONENT`/`ARCH_DRAFT`), frozen-тег отсутствует. Конформный контракт → rc 0.
- Дано: закреплённая модель `check --base` возвращает 1 или 2/`NOT_EVALUATED`; когда `pre_critic.sh` вызывает `check_architecture_contract.sh`; тогда rc 1 (`ARCH_CHECK` либо `ARCH_NOT_EVALUATED`); при rc 0 модели и зелёных прочих ногах дверь rc 0.
- Дано: reviewer с упоминанием `СВЕРКА-АРХИТЕКТУРЫ:` только внутри чужой строки либо отсутствующий/чужой/красный/skipped check-run `arch` на финальном SHA; когда `done_contract.sh` судит вход; тогда rc 1 (`ARCH_REVIEW` либо `ARCH_CI`), done-тег отсутствует. При самостоятельной непустой строке свидетельства и успешном check-run на точном SHA rc 0.
- Дано: frozen 170 до санкции v+1; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` и `--repo .`; тогда rc 0 на текущей версии. Cutover источника brief происходит только после согласованного v+1 170, без изменения остальных обязанностей 170.
- Дано: исправленный черновик; когда `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md`, затем `bash scripts/check_precision_gate.sh . contracts/187-arhitektura-v-processe.md`, затем `bash scripts/check_ceilings.sh .`; тогда каждый rc 0. До freeze после подключения CI orchestrator: `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring .` и `bash scripts/gen_ci_steps.sh --check` и `bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md` → каждый rc 0; точный `step` в registry исполняет `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, другой `step` отдельно вызывает `bash scripts/check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md`. Если первый step отсутствует, запускает Python вместо bash или пропускает `--repo .`, rc 1 `CI_BATTERY_187_MISSING_OR_NOT_EXACT`; если нет второго, rc 1 `CI_DIRECT_ARCH_187_MISSING`. Парный точный toy-реестр → rc 0.
- Дано (v3, грамматика pin): закреплённый коммит A и отличный HEAD B; lock `.commit` = `HEAD`, имя ветки, сокращённый sha (12 hex) либо неразрешимый полный sha; когда `make_task --arch-component api.identity` собирает пак; тогда rc 1 `ARCH_PIN` (неконформный: «закреплённый pin не полный 40-hex SHA: <pin>»; неразрешимый: «коммит <pin> не разрешается в клоне модели»), пустой stdout, `brief` не вызывается; «разрешить HEAD/ветку/префикс в SHA и принять» не выполняется. Клетки pin-symbolic-head/pin-symbolic-branch/pin-short-sha красны на текущей двери (бриф unpinned-головы B либо верный бриф без грамматики), pin-unresolvable-sha зелена до/после.
- Дано (v3, порядок шва): lock `.commit` = `HEAD`, вызов БЕЗ `--arch-component`; когда `make_task`; тогда rc 1 `ARCH_PIN`, не `ARCH_COMPONENT_NET`: pin судится до вопроса о флаге. Клетка pin-head-noflag красна на текущей двери именем отказа.
- Дано (v3, применимость): кодовый backend toy с файлом `architecture.lock.json` БЕЗ локальной `architecture/` и БЕЗ `--arch-component`; когда `make_task`; тогда rc 1 `ARCH_COMPONENT_NET`, пак не создан (клетка applicability-lock-no-dir красна на текущей двери: успешный пак без брифа rc 0). Дано: каталог `architecture/` БЕЗ lock и БЕЗ флага; тогда rc 1 `ARCH_COMPONENT_NET` — старое требование frozen 170/1 не сужено (клетка applicability-dir-no-lock зелена до/после). Стабы v3: «разрешимый pin принимается» ловится тремя грамматическими клетками своим входом каждая; «неразрешимый pin — зелёный пак» — клеткой неразрешимости; «грамматика только на флаговом пути» — безфлаговой клеткой; «применимость только по каталогу» — клеткой lock без каталога; «применимость только по lock» — клеткой каталога без lock (Н-39: каждая ветвь своим различающим входом).
- Дано (v3, голый прогон до ремонта): когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` на двери до ремонта implementer 187а; тогда rc 1 ровно с пятью красными клетками (pin-symbolic-head, pin-symbolic-branch, pin-short-sha, pin-head-noflag, applicability-lock-no-dir), прочие 56 зелёны; после ремонта rc 0, CELLS=61. Согласование с 170 v2: на собранной отремонтированной двери клетки 170 `symbolic_pin`/`lock_without_dir` зеленеют (`red_arch_component_170.sh --repo <собранный клон>` — приёмка 170, не копия здесь).
ПОТРЕБИТЕЛЬ fixtures/check_check_contract_ready/: bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh
ПОТРЕБИТЕЛЬ fixtures/drill_contract_change/: bash scripts/verify_antiplacebo.sh --scope drill_contract_change
ПОТРЕБИТЕЛЬ scripts/spawn_agent.sh: bash scripts/verify_antiplacebo.sh --scope spawn_agent
ПОТРЕБИТЕЛЬ scripts/check_spec_ready.sh: bash scripts/check_spec_ready.sh . contracts/187-arhitektura-v-processe.md
замер: `cat scripts/consumers.d/*.tsv | wc -l` = 6 census scripts/consumers.d/*.tsv

## Модель угроз

ЗАЩИЩАЕТ:
- От заморозки вне объявленных компонентов и DRAFT, от ложного зелёного rc 2 модели.
- От done по зелёному чужого SHA или без свидетельства reviewer.
- От подмены CI-батареи прямым вызовом двери защищает `--wiring` по реальным `step`-строкам registry, с независимым `gen_ci_steps.sh --check` по generated workflow.
- От брифа по символьному/сокращённому pin (двигающемуся вместе с HEAD клона модели) и от успешного пака кодового предмета без обязательного компонента при применимом lock или локальном каталоге `architecture/`.
НЕ ЗАЩИЩАЕТ:
- Вход задания 170 (свои источники, npm-граница вне режима 187а, порядок списка компонент) — зона 170 v2; совпадение имён отказов `ARCH_PIN`/`ARCH_COMPONENT_NET` — общая модель шва, не двойной канон.
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
- guard=fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh
- guard=scripts/check_architecture_contract.sh
ПРОВОДКА-ЭНФОРСМЕНТ: двери судят byte-структуру строки, путь/компонент, check-rc, pin и check-run; содержательную архитектурную оценку получают от отдельного предмета 188.

## Незаполненные требования:
нет
