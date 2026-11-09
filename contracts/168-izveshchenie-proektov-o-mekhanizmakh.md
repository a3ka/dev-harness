# Контракт 168 — извещение проектов об изменении общих механизмов

КЛАСС ЗАДАЧИ: кодовый. КЛАСС РИСКА: обычный — изменяется информационная раздача и учёт перед лендом/done, а не доступ, деньги, здоровье или юридически значимое действие.
КОНТЕКСТ: после изменений общих дверей 161/166/167 backend HANDOFF 931 их не назвал; при последующей работе было около 13 отказов дверей. Ручное обновление HANDOFF не является каналом передачи новых правил проекту. Единственный результат 168: проектный бриф перечисляет непринятые изменения используемых проектом механизмов, а выпуск изменения такого механизма без записи не проходит land/done.

## Существующее

- `scripts/make_task.sh --repo <проект> --role orchestrator --kind brief` уже формирует TRACE/MAP/RULES/REUSE и GOAL/WORK/DECISIONS/HEALTH из профиля; `project_paths_resolve` из `scripts/next_id.sh` и `profile_resolver.sh` являются источником проектных путей/идентичности. Новая секция брифа идёт в этот публичный CLI, не в отдельную команду владельцу. `scripts/make_task.sh` уже вызывается из project worktree и project main по 161, не нужно возвращать временный draft в main.
- `scripts/land_agent.sh` и `scripts/land_project.sh` являются действующими писателями merge-коммита; `scripts/done_contract.sh` — единственный писатель done-тега; `scripts/check_merge_gate.sh` уже проверяет вердикт и находки проектного PR. Проверка записи обязана работать ДО эффекта каждого соответствующего писателя; проверка только из CI, только из роли или только из `make_task` не закроет выпуск без записи.
- `registry/contracts.tsv` выдаёт номера контрактов и sha тега — это реестр идентичности контрактов, не журнал изменения механизма. `registry/ci-steps.tsv` — команды CI, не журнал проектного уведомления. `contracts/161-…`, `166-…`, `167-…` и их реальные скрипты задают исторические изменения, но автоматического реестра изменения/проектного ack пока нет. Фикстура 161 создаёт конформный проект с отдельным main/worktree и profilePaths; батарея 168 использует этот же генератор мира.
- Frozen 095/103/161 не меняют грамматику своих старых секций брифа; frozen 016/038/063/996 требуют сохранения авторства/проверок при land, done, профильного пути в проекте и нулевого изменения ветки/тега при отказе. PR с предметом 168 среди проверенных `gh pr list --state all --search 'notification OR извещение OR 168'` не обнаружен (GitHub PR #168 — исторический поезд 115, не контракт 168).

## Предмет и граница

1. Источник станции — отслеживаемый append-only `registry/mechanism-changes.tsv`: заголовок `record_id<TAB>date<TAB>contract<TAB>affected_scripts<TAB>change<TAB>correct_invocation`; отдельные самостоятельные TSV-строки с непустыми шестью полями, уникальным возрастающим целым `record_id`, датой ISO `YYYY-MM-DD`, номером контракта, списком путей `scripts/*.sh` через запятую (без пустых элементов), текстом сути изменения и корректной командой/последовательностью вызова. Поля не содержат TAB/CR/LF; данные с пробелами/точкой с запятой остаются в ячейке. Нельзя переписать старую запись, сдвинув курсор проекта; новые изменения того же контракта требуют нового record_id. Проект декларирует фактически используемые общие скрипты в `<workflowPaths.registry>/mechanisms.tsv` (заголовок `script`, затем по одному пути); последний прочитанный/признанный проектом record_id в `<workflowPaths.registry>/mechanism-notices.ack` (одно десятичное целое, 0 — ничего). Отсутствующий или повреждённый usage/ack при наличии проектного профиля — именованный отказ, а не пустой набор/ack на максимуме; только действительный проектный профиль определяет projectId и каталог ack. Ack меняется проектом отдельным коммитом после прочтения, чтение брифа его не обновляет.
На станции `registry/project-mechanisms.tsv` содержит пары `projectId<TAB>script` зарегистрированных проектов, перенесённые из их project manifests; станционный land/done судит этот индекс, так как не может обнаружить произвольные чужие checkout по файловой системе. Бриф незарегистрированного toy-проекта использует собственный profileId/usage и не требует его публикации в станции; у зарегистрированного проекта несогласие с индексом при синхронизации даёт `MECHANISM_USAGE_DRIFT`. Пустой/отсутствующий станционный индекс — `NOT_IMPLEMENTED`, не зелёный исход. Изменение состава зарегистрированного проекта фиксируется отдельным коммитом вместе с индексом станции, не ретроспективной догадкой по логам.
Грамматика полей закрыта: `record_id` и ack — `0|[1-9][0-9]*` (у записи id не ноль), `contract` — `[0-9]{3}`, `projectId` — `[A-Za-z0-9_-]+`, `script` — `scripts/[A-Za-z0-9_./-]+[.]sh` без сегментов `.`/`..`, дата — календарно валидная ISO `YYYY-MM-DD`; `change`/`correct_invocation` — непустой UTF-8 без TAB/CR/LF. Ячейки TSV разделены только TAB; поле script-list разделено запятой, которой нет в алфавите script. Парсер отказывает на неполной/лишней колонке, дубле ключа и обрыве строки без завершающего LF; литеральное сравнение двух недоверенных значений `projectId`, script и contract не строит regex/glob. Структурный якорь NOTICE — строка между двумя точными заголовками секции, не совпадение подстроки в остальных полях брифа.
2. Сеять три отдельные записи 161/166/167 с действительной датой изменения и правильным вызовом по источнику memo m1033 и соответствующим контрактам; `fixtures/workshop_project/izveshchenie_168/seed.tsv` — независимое предъявление полей и различимости приёмки, не запись production-реестра. Наличие строки 161 не закрывает изменение 166 общего `make_task.sh`; каждое изменение имеет свой идентификатор. Бриф проектного корня печатает `=== NOTICES ===` и полный `NOTICE<TAB>…` только для записей с id строго больше проектного ack и пересечением `affected_scripts ∩ mechanisms.tsv`; порядок из реестра, секция заканчивается `=== END NOTICES ===`. Другой проект с иным usage/ack видит свой набор. Пакет не выдаётся частично, если журнал/usage/ack невалидны; отсутствие новых строк даёт пустую ограниченную секцию. Исходные GOAL/WORK/MAP/TRACE и размерный бюджет остаются действующими.
3. Единый библиотечный разбор журнала — функция `project_mechanism_notices` существующего `scripts/next_id.sh` (уже общий для `make_task`/`done_contract`, остальные писатели подключают этот же источник). `land_agent.sh` станции, `done_contract.sh` и `land_project.sh` проекта вызывают его ДО первого изменения Git; кандидата получают из реального Git-диапазона, не из строки задания. Для каждого изменённого `scripts/*.sh`, который проект объявил используемым, требуется строка с тем же именем script И с номером изменяемого контракта; совпадение только с исторической строкой другого контракта недостаточно. Отсутствие записи: rc 1 `MECHANISM_NOTICE_MISSING:<путь>`, HEAD/тег/индекс/дерево целевого репо остаются неизменными. При done судится диапазон от последнего frozen-тега предмета до HEAD, не весь старый HEAD. Неиспользуемые пути и дельта без script не требуют записи. Станция для скриптов из проекта определяется расположением установленного слоя, не произвольным аргументом задания; недоступная станция rc 2 `NOT_IMPLEMENTED`, не тихое разрешение.

Граница: ни ретроспективной правки HANDOFF 931, ни изменения механики 161/166/167, ни auto-ack, ни пересборки чужих PR, ни новых модельных ограничений. Неиспользуемый проектом механизм не должен вызывать уведомление. Если индекс usage не соответствует реальному использованию через произвольный shell-код проекта, это отдельный предмет аудита — здесь список проектом объявленных общих скриптов является конформным источником.

## Модель угроз

ЗАЩИЩАЕТ:
- От потери изменений общего скрипта после забытого HANDOFF: секция брифа выдаёт каждую непринятую запись полностью, а два писателя станции и проектный land отказывают перед побочным эффектом при незаписанном изменении используемого скрипта.
- От подмены чужим проектом и от ложного ack: профильный путь/идентичность из общего resolver, структурные отдельные строки и числовая последовательность, ожидания фикстуры сняты в память до вызова субъекта.

НЕ ЗАЩИЩАЕТ:
- От не объявленных самим проектом shell-вызовов общего механизма; это не конформный usage-манифест, нужен отдельный аудит потребителей.
- От прочтения сообщения человеком и фактического изменения рабочего процесса: ack утверждает чтение, не доказывает понимание.

## Приёмочный критерий

`W=python3 fixtures/workshop_project/izveshchenie_168/probe.py`. Конформны два проектных корня с валидными профилями и разными списками используемых script-путей, автономный Git origin, валидные usage/ack и реестр с шестью полями. Валидный контрпример — инвариантен к именам проектов, датам и значениям текста и различается на конформной структуре. Токен NOTICE сверяется полной строкой внутри своей секции; ожидания поднимаются из заранее прочитанного seed в память, не перечитываются с диска проверяемого после вызова.

- Дано: проект использует make_task+spawn_agent и ack=0; когда `W --repo` вызывает настоящий `make_task --kind brief`; тогда до реализации rc 1 `BRIEF_NOTICES_MISSING`, после rc 0, самостоятельные полные строки 161 и 166 внутри NOTICES, без 167. Дано: ack=1 и та же команда; тогда остаётся только 166; проект использует только zamok_predmeta — только 167; ack=3 — пустая секция, не произвольный текст вне секции. Негативная пара: ack=`invalid`; тот же вход после реализации rc 1 `NOTICE_ACK_INVALID`, stdout пуст, нет частичного брифа.
- Дано: изменён script, используемый проектом, а соответствующей записи по номеру контракта нет в журнале; когда `W --repo` запускает публичные `land_project.sh`, `land_agent.sh` и `done_contract.sh` на отдельных ветвях; тогда до реализации rc 1 `LAND_WRITER_NOT_GATED`, `STATION_LAND_WRITER_NOT_GATED`, `DONE_WRITER_NOT_GATED` по своим клеткам, после реализации каждый публичный писатель rc 1 `MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh`, ни SHA HEAD, ни done-теги/индекс не меняются. Парные положительные входы с записью и с неиспользуемым скриптом rc 0 при удовлетворённых существующих гейтах. Не засчитывать rc 1 другой двери.
- Дано: модель честных переходов и валидный seed; когда `W --model`; тогда rc 0 при зелёных точных строках для брифа и обоих типах отказа. Когда `W --stabs`; тогда rc 0 при отдельных различимых ошибочных реализациях, проверяемых кодом probe.py; контракт не предписывает соответствие имён обманок входам.
- Правило: `bash scripts/pre_critic.sh --repo . contracts/168-izveshchenie-proektov-o-mekhanizmakh.md` после завершения архитектурной пачки rc 0; перед done `bash scripts/check_provodka.sh . contracts/168-izveshchenie-proektov-o-mekhanizmakh.md` rc 0. CI-строка гейта запускает `bash fixtures/workshop_project/izveshchenie_168/red_izveshchenie_168.sh` (внутри три независимые команды, до реализации красна только repo) и фиксируется orchestrator после ленда реализации.

## Порядок и зоны

Реестр и семантика диапазона candidate → чтение из брифа → гейт перед land/done → доказательство публичного входа на конформном проекте → подключение CI → суд. Одну запись добавлять только вместе с изменением скрипта, прежде чем проект узнает об изменении через brief; изменение без записи — named refusal, не авто-исправление.

ЗОНА architect: contracts/168-izveshchenie-proektov-o-mekhanizmakh.md fixtures/workshop_project/izveshchenie_168/
ЗОНА implementer: registry/mechanism-changes.tsv registry/project-mechanisms.tsv scripts/next_id.sh scripts/make_task.sh scripts/land_agent.sh scripts/land_project.sh scripts/done_contract.sh
ЗОНА critic: verdicts/critic/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только секция NOTICES проектного brief; старые пакеты и TRACE/MAP неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/land_agent.sh — 016 только ранний отказ до merge, авторство неизменно.
ПЕРЕСЕЧЕНИЕ implementer: scripts/land_project.sh — 063 только ранний отказ до merge, гейт ревьюера неизменен.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 038 только ранний отказ до тега, прежние гейты неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 168, чужие CI-шаги сохраняются.
ПЕРЕСЕЧЕНИЕ architect: contracts/168-izveshchenie-proektov-o-mekhanizmakh.md — 993 только контракт 168, прежние контрактные зоны сохраняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/izveshchenie_168/ — 054 только фикстура 168, существующие проекты не затронуты.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/izveshchenie_168/ — 055 только фикстура 168, существующие проекты не затронуты.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только шаг 168.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер шага 168.
ПЕРЕСЕЧЕНИЕ implementer: scripts/land_agent.sh — 065 только предmerge-проверка 168, перенос санкций 065 не меняется.

ПРЕДПОСЫЛКИ:
- setting Текущий CI харнесса имеет Python 3, git, jq и bash для scoped шага 168; новых secrets, variables, environments и GitHub settings не требуется.

ПРОВОДКА:
- guard=fixtures/workshop_project/izveshchenie_168/red_izveshchenie_168.sh
ПРОВОДКА-ЭНФОРСМЕНТ: проверка полного NOTICE и отсутствия побочных эффектов при выпуске общего скрипта — механический guard; новую поведенческую норму в роли не вводит.

## Незаполненные требования:
нет
