# Контракт 187 — архитектура в процессе станции

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — проверяются ворота процесса; права/роли БД, авторизация, деньги, ПД/health-данные и согласия, юридически значимые действия не меняются.
КОНТЕКСТ: docs/owner/2026-11-10-arhitektura-v-processe.md §Слово владельца (17:49), §Измеренная боль; NABLIUDENIA.md Н-442; решение владельца 09.11 (§7 Fable-11). Предмет — В4+В5, не хранитель В6 (186).

## Существующее

- 170 (done): `scripts/make_task.sh --arch-component` уже кладёт compact brief из `npm --prefix R/architecture run brief -- --compact --component ID` в задания; правила добавляются для architect/critic/arbiter. Признак архитектурного task у 170 — каталог `architecture/` и `КЛАСС ЗАДАЧИ: кодовый`; один только `harness.project.json` не доказывает архитектуру. Существующая батарея `fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` остаётся зелёной. 095 доставляет contextPack/`STRUCTURE.md`, профиль и `pre_critic --repo`; 088 ведёт текущий HANDOFF, не архитектурный источник.
- 996: `scripts/profile_resolver.sh` и `scripts/next_id.sh` уже разрешают `workflowPaths` проекта. В живом `/home/harness/projects/Complior-back/harness.project.json` repoId=`Complior-back`, contracts=`.harness/contracts`, architecture/package.json содержит `check`/`brief`; у `/home/harness/projects/Complior-mob/harness.project.json` repoId=`Complior-mob`, workflowPaths тоже `.harness/*`, но архитектуры бэкенда нет. Сам харнесс repoId=`dev-harness`, contracts=`contracts`. Поэтому применять 187 по совпадению пути `.harness/` или по наличию одного `harness.project.json` нельзя. `registry/plan.tsv` перечисляет этапы, не назначает модули; архитектурным оракулом не является.
- Freeze-дверь `scripts/freeze_contract.sh` после HEAD/вердикта вызывает spec/consumers/precision/doc-проверки до тега; дверь `scripts/pre_critic.sh` использует инструменты харнесса и корень проекта с `--repo`; done-дверь `scripts/done_contract.sh` после HEAD/reviewer вызывает sourceCanon/provodka/consumers до тега. Ноги проверки архитектуры и обязательных двух строк там нет. `scripts/check_spec_ready.sh`/`scripts/check_provodka.sh` проверяют готовность критерия/проводки, но не модули брифа. Роли architect/critic/reviewer/adversary содержат общий суд, не проектную архитектурную сверку. `ops/server/README.md` — обвязка станции, не модель проекта. В доступных локальных wip/PR не найден принятой реализации ворот 187; при интеграции повторить сверку с опубликованным origin.
- Конфликт сохранности: 170 прямо требует сохранить `STRUCTURE.md` в contextPack; решение владельца 09.11 требует заменить её брифом. Удаление row/снятие зелёной клетки 170 требует отдельно санкционированной v+1 170; 187 не меняет `make_task.sh`, `STRUCTURE.md`, профиль и зелёное обязательство 170. Также 996 гарантирует отсутствие изменений в установке во время проектной сессии: исполняемый gate берётся из установки, проектная архитектура только читается.

## Frontier — выбор по измеренной боли

1. **Выбрано: строгие ворота только для кодового Complior-back.** Н-442: кодовые 170/171 достигли критика без архитектурного контроля; warning или отложенный gate не задержит следующую заморозку. Невозможность прочесть brief/check, сомнительная операция и непризнанная зона дают именованный отказ до создания тега, а не ложное зелёное. Цена: незавершённые схемы бэкенда действительно задерживают новый кодовый контракт до L1/решения владельца.
2. **Альтернатива: предупреждать до массового внедрения на бэкенде.** Позволила бы завершать уже начатые 170/171, но сохраняет ровно измеренный класс отказа Н-442; предупреждение не является доказательством шестого вопроса. Отвергнуто. Для старых уже frozen контрактов ретро-обязательность и судьба существующих версий — отдельное решение владельца, не тихое переутверждение.

## Предмет и граница

Бэкенд-контракт 187 применим только при одновременно истинных условиях: явный проектный корень R (`--repo R` в pre_critic, третий аргумент freeze/done), эффективный профиль с `repoId=Complior-back`, `workflowPaths.contracts` внутри R, выбранный контракт под этим путём, отдельная строка `КЛАСС ЗАДАЧИ: кодовый` и каталог R/architecture. Профиль читать существующим резолвером, а не grep случайного файла; битый профиль отказывает существующим гейтом. `repoId=Complior-mob`, `repoId=dev-harness`, документальный контракт и проект без architecture не получают требования строки 187. Кодовый backend с отсутствующей architecture — именованный отказ, не молчаливый legacy. Цель: только кодовые контракты предметов, не контракты модулей архитектуры. Архитектуру R читать из проекта; не писать её в дереве харнесса или в toy-фикстуре.

Самостоятельная строка `АРХИТЕКТУРА: <непустой список ID компонентов> / <непустой список ID операций с контрактами модулей> / L1|L2|L3` указывает существующие компоненты, операции и уровень изменения. Разбор полей строго по разделителям ` / `, ID из допустимого алфавита 170 `[A-Za-z0-9_][A-Za-z0-9._-]*`, списки через запятую без пустых записей, повторов, `..`, произвольной прозы и слов-пустышек; операция разрешается в контракте модуля выбранного брифа, имеет обе схемы и не DRAFT. Конформный пример: `АРХИТЕКТУРА: api.identity / identity.lookup / L1` при существующих у `api.identity` контракте и готовой операции `identity.lookup`; сам ID — пример грамматики, а не заявление, что такая операция уже есть в продукте. Незнакомый уровень/модуль/операция и пустая строка отказывают с именованной причиной. Любое объявление модуля на stdout npm проверяется по полю `Element:`, пути — по `Product location:` каждого соответствующего компактного брифа, не по поиску подстроки в чужой секции. Хинт определяет место размещения кода, не runtime-доказательство. Служебные области `.harness/` и `architecture/` не выдают permission на продуктовый код. Конформный контрпример: проектный профиль и успешный `brief`/`check`, архитектурные component/contract/operation/status/путь из их документированной формы, валидный кодовый контракт; замена ID/значений на другие валидные не меняет инвариант. Оракул ID, хинтов и статусов снимается в память checker ДО запуска gate, не перечитывается из проверяемого диска.

`freeze_contract.sh` на применимом контракте берёт закоммиченный HEAD-блоб и для каждого `ЗОНА implementer:` проверяет каждый путь продукта: путь лежит в union Product location хинтов только объявленных компонентов (граница каталога, `api/auth/` не покрывает `api/auth2/`), чужой продуктовый путь отказывает. При отсутствии зоны кода пустая декларация не выдаёт право. При отсутствии готовой схемы операции или DRAFT — rc 1, без frozen-тега и записи registry. `pre_critic.sh --repo R` запускает `npm --prefix R/architecture run check -- --base <базовый снимок>` (аргументы baseline — документированный интерфейс версии проекта, не само-сравнение кандидата) до допуска критика; rc 1/2 и пустой результат закрывают дверь, stderr не становится успешным оракулом. Бриф, операция и статус берутся на том же HEAD, который freeze собирается тегировать; изменённый между проверками HEAD приводит к повторной сверке, а не к кешированному green. `done_contract.sh` на применимом контракте требует самостоятельной непустой строки `СВЕРКА-АРХИТЕКТУРЫ: <вывод reviewer о модулях, операциях, привязках и долге>` в committed reviewer verdict для этого HEAD, до тега done; строка в контракте, примере или ином файле не заменяет verdict. За пределами применимости прежние rc/ветви/теги сохраняются.

Роли читают brief 170: architect строит красные клетки по схемам/инвариантам выбранных контрактов модулей и записывает АРХИТЕКТУРА; critic шестым вопросом сверяет соответствие предмета контрактам модулей, не-DRAFT и объявленные зависимости; adversary пробует чужую таблицу/прямой SQL/обход архитектурного движка и сообщает находку без расширения 187 до двигателя 167; reviewer сверяет финальный diff, привязки, долг и архитектуру, записывает `СВЕРКА-АРХИТЕКТУРЫ:` в вердикт. Когнитивная оценка правильности клетки остаётся суду; статический gate не доказывает корректное runtime-поведение. Код по DRAFT, несуществующей схеме или чужому внутреннему интерфейсу не утверждать. L2 меняется пачкой с одним снимком на срез; саму модель и снимок 187 не модифицирует (186/167).

## Приёмочный критерий

- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model` → rc 0, положительные и отрицательные клетки честного контроля.
- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs` → rc 0, девять различимых обманных вариантов пойманы.
- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` → красная: RED missing


- Дано: одноразовый backend toy со своим `.git`, валидными готовыми операциями и совпадающими модулями/путями, честный контроль; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`; тогда rc 0, все положительные и парные негативные клетки зелёны; по одному контрпримеру на отсутствие/пустышку строки, чужую зону, DRAFT, пропущенный check, проигнорированный rc check, отсутствие строки в reviewer verdict, ошибочное применение к harness/mob. Для каждой отрицательной клетки честный gate возвращает rc 1 с именованной причиной и не создаёт тег; на некодовых harness/mob прежний rc сохраняется.
- Дано: текущий код до реализации; когда та же команда `--repo .` либо без аргумента; тогда rc 1, отдельные красные ветви, не отказ от окружения. После реализации тот же вызов → rc 0. Дано: каждый отдельный обманный вариант; когда та же команда `--stabs`; тогда rc 0, строка `STAB <name> caught @ <case>` для каждого, ни одного `ZHIV`; связь с различающей ветвью объявлена в коде батареи.
- Дано: backend toy с отдельной строкой `АРХИТЕКТУРА:` и компонентом из brief; когда реальный `freeze_contract.sh <профильный контракт> <причина> R` при согласованной зоне и accept; тогда rc 0, новый frozen-тег. Дано: такой же мир с чужой зоной или DRAFT; та же команда → rc 1 с `ARCH_ZONE`/`ARCH_DRAFT`, frozen-тега и registry-дельты нет. Дано: backend toy и `pre_critic.sh --repo R <профильный контракт>`; когда check rc 7; тогда rc 1 `ARCH_CHECK`, а check rc 0 возвращает допуск при прочих зелёных ногах. Дано: финальный reviewer verdict без сверки; когда `done_contract.sh <профильный контракт> <причина> R`; тогда rc 1 `ARCH_REVIEW` без done-тега, с committed непустой строкой → rc 0.
- Дано: чистая реализация; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`, `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo .`, `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md`; тогда все rc 0. До реализации 170 уже зелёный, 187 --repo красен.

## Модель угроз

ЗАЩИЩАЕТ:
- От заморозки нового кодового backend-контракта без доказанной области модуля и готовой операции; от признания ошибочного/неисполненного `check` зелёным.
- От тега done без свидетельства архитектурной сверки в reviewer verdict и от распространения backend-обязанности на mob/harness.
НЕ ЗАЩИЩАЕТ:
- От ложной модели архитектуры, недобросовестной формулировки ревьюера, поведения кода и динамических обходов AST; отдельные двигатели CI 167 и суды отвечают за это.
- От изменения архитектуры после заморозки: вопрос закрепления версии архитектуры относительно HEAD бэкенда требует отдельного решения по 167; проверка не выдумывает пин.

ПРЕДПОСЫЛКИ:
- setting Проект предоставляет npm/node и локальную архитектуру с документированными `brief`/`check`, конформные `harness.project.json` и `workflowPaths`; установка предоставляет свои скрипты. Новые secrets/variables/environments не требуются.
- setting Оркестратор добавляет только шаг батареи 187 и замер через `gen_ci_steps.sh --write`, `--check` rc 0; проектный CI/секреты не меняются этим контрактом.

## Зоны и проводка

ЗОНА architect: contracts/187-arhitektura-v-processe.md fixtures/workshop_project/architecture_process_187/
ЗОНА implementer: scripts/freeze_contract.sh scripts/pre_critic.sh scripts/done_contract.sh scripts/check_architecture_contract.sh roles/architect.md roles/critic.md roles/reviewer.md roles/adversary.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 038 только новая backend-нога до тега; сверка consumers и исходные вердикты не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 043 только новая backend-нога до тега; precision сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 996 только новая backend-нога до тега; профильные пути и registry сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 072 только новая backend-нога; остальные существующие ноги не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 095 только новая backend-нога; contextPack не меняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 103 только новая backend-нога; --repo сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 038 только backend reviewer-сверка до тега; ПРОВОДКА сохранена.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 996 только backend reviewer-сверка до тега; project sourceCanon сохранён.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 038 только предметный backend-абзац; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только шестой backend-вопрос; прежние пять сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 038 только backend-сверка; прочие нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 166 только backend-класс архитектурных заглушек; прочие нормы сохранены.
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
- role=roles/architect.md
- role=roles/critic.md
- role=roles/reviewer.md
- role=roles/adversary.md
ПРОВОДКА-ЭНФОРСМЕНТ: скрипты закрывают только механические поля и rc; качественное соответствие операций/модулей проверяется поведенческими нормами судей.

## Незаполненные требования:
нет
