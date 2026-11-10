# Контракт 187 — архитектура в процессе станции

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — проверяются ворота процесса; права/роли БД, авторизация, деньги, ПД/health-данные и согласия, юридически значимые действия не меняются.
КОНТЕКСТ: docs/owner/2026-11-10-plan-i-pravila-arhitektury.md §Восстановлено из решений 2026-11-08…10, пункты 1–9, 13–15; /home/harness/consultant/spec11/ARCH-IN-WORKFLOW-SPEC.md §4–§8 (только источник проектирования, не runtime-зависимость); NABLIUDENIA.md Н-442. Предмет — В4+В5, не хранитель В6 (186).

## Существующее

- Frozen 170 уже требует `scripts/make_task.sh --arch-component` и brief из **локального** `R/architecture/`; его зелёная батарея `fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` обязана пережить cutover. `STRUCTURE.md` приходит из contextPack 095 и остаётся. После 167 локальная копия архитектуры бэкенда удаляется, поэтому источник brief в 170 несовместим с утверждённым `architecture.lock.json`: только адресный v+1 170 с разрешением владельца снимает старый источник, строку, требующую `R/architecture/`, и соответствующие старые клетки; прежний `--arch-component` и деление ролей на brief с правилами/без сохраняются. До санкции не выдавать несовместимую версию за done 187.
- 095/103/161a проводят `make_task`, project contextPack, `--repo` и различение проектного/инструментального task. 996 разрешает профильные `workflowPaths`; признак бэкенда — эффективный `repoId=Complior-back`, а не каталог `.harness` (он есть также у mob). В backend `architecture.lock.json` закрепляет точный коммит **отдельного** `CompliorOS-architecture`; чтение модели/брифа из закреплённого клона по verify-pin, без fallback на HEAD или локальную `architecture/`. `docs/ARCHITECTURE.md` убран из contextPack только backend, `STRUCTURE.md` остаётся. Изменение проектного `harness.project.json` вне зоны 187 — предпосылка интеграции, не скрытая правка backend из харнесса.
- Существующие `scripts/freeze_contract.sh`, `scripts/pre_critic.sh`, `scripts/done_contract.sh`, `scripts/check_ci_gate.sh` ведут frozen/critic/done, но не связывают строку архитектуры с зоной, rc модели, зелёным check-run `arch` и вердиктом ревьюера. 167 проекта держит движок, `bindings.json`, pin и CI; харнесс не запускает движок в done. 186 владеет `roles/architecture-steward.md` и закрытием находок; 187 проводит их подачу агентами и вызов хранителя оркестратором, не дублируя обзор.
- С16: база 163 — пять вызовов критика, 159 — четыре и FAIL адверсария, 011 — три и арбитр; будущий замер кругов отдельно. Это не критерий 187.

## Предмет, вход и порядок

Только кодовый предмет проекта `repoId=Complior-back` в профильных `workflowPaths.contracts` получает требования 187. Харнесс, mob, документальные задачи, контракты модулей в отдельном репозитории архитектуры не получают новый отказ; отсутствие локального `R/architecture/` после 167 НЕ переводит backend в legacy. Профиль читается существующим резолвером. Компоненты определяет закреплённый clone архитектуры, а не непроверенный HEAD; если pin не разрешается, отказ до заморозки, а не устаревший brief.

Оркестратор ДО задания запускает `node tooling/checks/cli.js locate --path <путь>` из закреплённой архитектуры для каждого продуктового пути зоны, называет компоненты/уровень в самостоятельной строке задания `АРХИТЕКТУРА: L1|L2|L3 <id,…>`; ID компонента `[A-Za-z0-9_][A-Za-z0-9._-]*`, список непустой, без дублей и свободной прозы. Путь без компонента → `PATH_WITHOUT_COMPONENT`; отсутствие/пустая строка → `ARCH_LINE_MISSING`. L3 останавливается до вопроса владельцу; L2 идёт через хранителя 186 до контрактной заморозки. Контракт предмета фиксирует те же компоненты, уровень, операции контрактов модулей с готовыми входом/выходом, зависимости и ресурсы; операция DRAFT без схемы не допускает код. Отдельная строка контракта `АРХИТЕКТУРА: L1 api.identity` — пример синтаксиса, не утверждение наличия api.identity в живом проекте. `make_task --arch-component` принимает ID только из этой строки; несогласие ID/brief/lock — именованный отказ, не silent fallback.

`make_task` доставляет каждому объявленному компоненту `brief --compact` из **точного** SHA `architecture.lock.json`: `--with-rules` для architect/critic/arbiter, без него для implementer/adversary/reviewer. `STRUCTURE.md` остаётся, устаревший `docs/ARCHITECTURE.md` исключается из backend contextPack. На backend задачах с чужой зоной и без объявления компонента вход задания отказывает до создания пакета. Две версии модели (local и lock) в одном задании запрещены.

`pre_critic.sh --repo R` запускает `check --base` закреплённой модели против утверждённого снимка. rc 0 — можно продолжать при прочих зелёных ногах; rc 1 — `ARCH_CHECK` отказ; rc 2/`NOT_EVALUATED` — `ARCH_NOT_EVALUATED` (не зелёный результат, причина доносится критику в вердикт/доклад). Критик шестым вопросом сверяет компоненты, операции не DRAFT и со схемами, зависимости ∈ `consumes`, писателей ∈ `writers`, уровень и матрицу клеток из `semanticInvariant`; не запускает кодовый движок.

`freeze_contract.sh` проверяет HEAD-блоб применимого backend-контракта: для каждого продуктового пути `ЗОНА implementer:` `locate --path` возвращает объявленный в `АРХИТЕКТУРА:` компонент и путь попадает в `implementationPathHint` этого компонента (граница компонента, не строковый prefix); неразмещённый или чужой путь → `ARCH_ZONE`/`PATH_WITHOUT_COMPONENT`. Готовность каждой требуемой операции — схемы входа и выхода, не DRAFT; отсутствие → `ARCH_DRAFT`. Отказ оставляет frozen tag и registry без изменений.

Implementer меняет код только внутри `implementationPathHint`, вызывает чужие модули только через объявленные `consumes`, пишет только таблицы ресурсов своего компонента, добавляет `bindings.json` с новыми привязками в том же PR и ДО push запускает `ARCHITECTURE_ROOT=<клон архитектуры> node tests/tools/run-arch.js` локально. Код не узаконивает отклонение от модели; найденное расхождение — остановка, находка, а не обход кодом или рост базы долга. Модель не узаконивает себя: её дельта отдельным коммитом с diff и причиной/уровнем до продуктовой дельты, проверку под код не подгоняют.

`done_contract.sh` на **финальном SHA** продуктового main читает успешный check-run `arch` CI проекта по этому же SHA (не запускает движок сам, не принимает зелёный с другого коммита, `NOT_EVALUATED`, отсутствие check-run или пропущенный job). В вердикте reviewer на OBJECT обязательна самостоятельная непустая строка `СВЕРКА-АРХИТЕКТУРЫ:` о размещении, зависимостях, писателях, операциях, привязках, долге и уровне правки модели. Нет любого свидетельства → `ARCH_CI`/`ARCH_REVIEW`, done-tag не создан.

## Находки и два связанных PR

Architect, critic, implementer, adversary, reviewer, arbiter и orchestrator при наблюдаемом расхождении создают файл `governance/findings/` **командой** `node tooling/checks/cli.js finding new <slug> --input <six-field.json>`: шесть полей — модуль; что увидел; что в модели; предлагаемая правка; уровень L1/L2/L3; автор/статус. Номер выдаётся под lock, вручную не нумеруют; расхождение не обходят кодом, проверку не заглушают, долг для его легализации не расширяют. Структурные ошибки входа дают отказ до записи; полномочие закрытия находки — у хранителя 186. Оркестратор вызывает хранителя после `done` **последнего предмета каждого Э-этапа** и немедленно при блокирующей находке; недельный timer 186 — страховка, занятой слот оставляет сигнал в очереди. Содержательная верность шести полей и отсутствие обхода — cognitive-only; ловцы critic/adversary/reviewer по диффу модели, кода и отчёту движка.

Один номер `COMPLIOR-<NNN>` входит в заголовки обоих PR (архитектура ↔ продукт), PR ссылаются друг на друга, `workItem` в `architecture.lock.json` совпадает; сначала модельный PR вливается в защищённый main архитектуры, потом продуктовый PR закрепляет **точный merge commit**. При смене checker/профилей/`bindings.json` базу долга пересчитывают в том же PR и лишь сужают. Автор PR в `CompliorOS-architecture` сам его не сливает: L1 — назначенный владельцем мейнтейнер (до назначения — владелец), L2/L3 — запись владельца. Пин меняют лишь вперёд; откат содержания — reviewed forward revert. Ручной CI принимает только полный SHA `arch_base_sha` коммита backend main, никогда HEAD-fallback. Норма связанного PR — в роли orchestrator; проектные CI и права main настраиваются в проектном предмете, не здесь.

ИСТОЧНИК: `путь@sha256 §раздел` модели пока нельзя честно предъявить: `sourceCanon` не включает модель, `module.js` не несёт разделов. ОСТАТОЧНЫЙ РИСК (cognitive-only): перепутана версия/поле модели при человеческой сверке; ловец — critic сверяет точный lock SHA, brief, diff и названный элемент модели, reviewer — тот же pin на OBJECT. Не выдавать ссылку на `module.js` за валидную цитату до отдельной совместимой работы sourceCanon/формата модели.

## Приёмочный критерий

- Дано: автономные toy-repo продукта и архитектуры со своими `.git`, закреплённый merge SHA, валидные schema/brief/locate; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`; тогда rc 0 для каждой независимой положительной и отрицательной клетки. Контрпример валиден только при документированной грамматике CLI и самостоятельной конформной строке/пути; при подмене значений инварианты сохраняются, честная реализация расходится со стабом на конформном входе.
- Дано: каждый стаб с кодовой привязкой к своей различающей клетке; когда тот же скрипт `--stabs`; тогда rc 0 и `STAB <name> caught @ <case>` для каждого; отсутствие клетки или стаб, проходящий её, → rc 1. При `--repo .` до реализации → rc 1 на независимых красных клетках; после реализации → rc 0.
- Дано: backend toy с пропуском строки задания, немаппленным путём, чужой frozen-зоной, DRAFT, `check --base` rc 1 и rc 2, reviewer без сверки, отсутствующий/чужой check-run `arch`; когда публичные двери `make_task`, `freeze_contract.sh`, `pre_critic.sh`, `done_contract.sh` (скрипт `--repo`) судят соответствующий вход; тогда rc 1 с отдельной причиной и ни пакета, ни тега; честные парные входы rc 0. На mob/harness та же архитектурная строка не обязательна.
- Дано: закреплённый SHA отличается от HEAD модели; когда `make_task --arch-component` строит пак; тогда получен brief закреплённого SHA, а не HEAD, `--with-rules` только для architect/critic/arbiter; `STRUCTURE.md` присутствует, `docs/ARCHITECTURE.md` отсутствует. Регресс `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` и `--repo .` → rc 0 до совместимой миграции v+1 170.
- Дано: незаведённая находка и шесть полей; когда `finding new ... --input ...`; тогда новый номер выдаёт CLI; ручная нумерация и потеря поля → rc 1. Дано: конец этапа или блокирующая находка; когда orchestrator выполняет роль; тогда хранитель вызван после done или сразу; человеческая дисциплина — cognitive-only, ловец reviewer по журналу вызовов.
- Дано: пара PR со ссылками и `workItem`, merged SHA; когда reviewer оценивает связку; тогда совпадение, порядок, maintainer approval, forward pin, пересчитанная база и полный `arch_base_sha` дают допуск; пропущенное звено → отказ. Реальный GitHub check-run/полномочие maintainer моделируются локальными immutable SHA и полномочиями; окончательный живой внешний gate проверяет reviewer на проектном PR.
- Дано: черновик 187 после всех правок; когда `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md`; тогда rc 0. После реализации, когда `bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md`; тогда rc 0. Существующие frozen-ноги и source-gate остаются на месте.

## Модель угроз

ЗАЩИЩАЕТ:
- От заморозки вне объявленных модулей и DRAFT и от ложного зелёного rc 2 модели.
- От done по зелёному чужого SHA или без свидетельства reviewer.
НЕ ЗАЩИЩАЕТ:
- От ложной модели/сознательного обхода code CI; движок и суд проекта владеют этим свойством.
- От человеческой ссылки на модель как `ИСТОЧНИК:` до совместимой поддержки sourceCanon.

ПРЕДПОСЫЛКИ:
- setting Проектный CI предоставляет check-run `arch` на точном backend SHA, закреплённый clone по `architecture.lock.json`; секреты/variables/environments не вводятся предметом 187.
- setting Проектный профиль убирает `docs/ARCHITECTURE.md` из contextPack; отдельная проектная миграция и v+1 170 согласуются до done.

## Зоны и проводка

ЗОНА architect: contracts/187-arhitektura-v-processe.md fixtures/workshop_project/architecture_process_187/
ЗОНА implementer: scripts/make_task.sh scripts/freeze_contract.sh scripts/pre_critic.sh scripts/done_contract.sh scripts/check_architecture_contract.sh scripts/check_ci_gate.sh roles/architect.md roles/critic.md roles/implementer.md roles/adversary.md roles/reviewer.md roles/arbiter.md roles/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 002 только backend brief и L1/L2/L3; прежний арбитраж сохранён.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 038 только backend-клетки и поток находок; прочая норма сохранена.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только шестой вопрос и поток находок; прежние пять сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer.md — 002 только backend-границы и поток находок; прочее сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer.md — 003 только backend-границы и поток находок; прочее сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer.md — 027 только backend-границы и поток находок; прочее сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только вызов хранителя по двум событиям, прежнее руководство сессией сохранено.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 186 потребитель события хранителя вносится 186 первым; 187 добавляет task/находки/связанные PR, не переписывая обработчик события.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 038 только backend-сверка и поток находок; прочее сохранено.
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
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 005 только backend-классы; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 008 только backend-классы; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 011 только backend-классы; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 015 только backend-классы; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 002 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 003 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 005 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 008 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 010 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 011 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 015 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 016 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 037 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 041 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 050 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 066 только backend-клетки; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 005 только шестой backend-вопрос; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 008 только шестой backend-вопрос; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 011 только шестой backend-вопрос; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 015 только шестой backend-вопрос; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 041 только шестой backend-вопрос; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 043 только шестой backend-вопрос; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 005 только backend-сверка; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 008 только backend-сверка; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 011 только backend-сверка; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 015 только backend-сверка; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 027 только backend-сверка; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 050 только backend-сверка; прочие нормы сохранены.

ПРОВОДКА:
- guard=fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh
- role=roles/architect.md «Для кодового backend-контракта выведи клетки из semanticInvariant, схем входа/выхода, второго писателя ресурса и чужого scope_id закреплённой модели; отсутствующая схема и DRAFT закрываются до заморозки.»
- role=roles/architect.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/critic.md «Шестым вопросом backend-контракта проверь компоненты и операции закреплённой модели: вход/выход существуют, не DRAFT, зависимости входят в consumes, писатели входят в writers, уровень правки модели и красные клетки соответствуют semanticInvariant.»
- role=roles/critic.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/implementer.md «На backend меняй код лишь в implementationPathHint модуля, чужие зависимости только через consumes, таблицы только ресурса владельца; bindings.json новых функций добавь в тот же PR, до push запусти ARCHITECTURE_ROOT=<клон архитектуры> node tests/tools/run-arch.js.»
- role=roles/implementer.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/adversary.md «На backend предъяви заглушки второго писателя ресурса, прямого SQL из app/api, обхода consumes, чтения без scope_id и новой формы обхода движка; если заглушка проходит, предъяви находку, не дописывай её в долг.»
- role=roles/adversary.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/reviewer.md «На backend проверь привязки bindings.json, границы модуля, consumes, writers, отсутствие роста долга, уровень отдельной правки модели; в вердикте дай самостоятельную строку СВЕРКА-АРХИТЕКТУРЫ: по финальному OBJECT и отчёту arch.»
- role=roles/reviewer.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/arbiter.md «На backend получи brief --compact --with-rules из закреплённой модели, реши инженерный спор L1/L2 о коде и модели, L3 верни владельцу одним вопросом с рекомендацией; снимок сам не утверждай.»
- role=roles/arbiter.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/orchestrator.md «В задании кодового backend-предмета укажи АРХИТЕКТУРА: L1|L2|L3 <id,…> по brief и locate закреплённой модели; L3 предъяви владельцу до раздачи, L2 сначала хранителю.»
- role=roles/orchestrator.md «После done последнего предмета каждого Э-этапа и немедленно при блокирующей архитектурной находке вызывай architecture-steward; недельный timer — только страховка; при занятом слоте оставь сигнал в очереди. После сессии обзора проверяй коммит governance/review/<дата>-<Э>.md, отсутствие — находка.»
- role=roles/orchestrator.md «При расхождении с архитектурой создай находку через node tooling/checks/cli.js finding new <slug> --input <six-field.json> в governance/findings/: модуль, что увидел, что в модели, предлагаемая правка, уровень L1/L2/L3, автор/статус; не обходи расхождение кодом и не заглушай проверку.»
- role=roles/orchestrator.md «У связанных PR модели и продукта проверь общий COMPLIOR-<NNN>, взаимные ссылки, workItem закрепления точного merge SHA, сужение долга при изменении checker/профилей/bindings.json, слияние модели не её автором, forward revert и полный arch_base_sha backend main без fallback на HEAD.»
ПРОВОДКА-ЭНФОРСМЕНТ: скрипты удерживают line/rc/pin/check-run, оценка архитектурной правды и моменты вызова хранителя — role-канал с ловцом reviewer.

## Незаполненные требования:
нет
