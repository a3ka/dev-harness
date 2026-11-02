# Контракт 154 — счёт вызовов критика вместо смен класса вердикта

КЛАСС ЗАДАЧИ: КОДОВЫЙ — красная батарея, дверь спавна и повторная сверка при заморозке.
КЛАСС РИСКА: рисковый — деньги: ложный пропуск шестого платного critic-вызова расходует бюджет судейской модели; ложный отказ законной заморозки требует нового платного касания. Не авторизация и не безопасность пользовательских данных.
КОНТЕКСТ: слово владельца 2026-11-01 о пороге: максимум 5 critic-вызовов по предмету, включая accept и новые платные сессии после обрыва; после пятого без accept — остановка и слово владельца, не автоматический арбитраж. Это отдельный измеренный остаточный риск owner/plan-154 §Остаточный риск, а не переделка процедуры арбитража.

## Существующее

`contracts/013-processnye-artefakty-i-schet-krugov.md` §Б / `scripts/freeze_contract.sh` §6в считают смены первой строки verdict через git log (Н-57: это исправляло прежнее ПЕРЕсчитывание редактирований одного файла). Нынешняя единица отличается: пять последовательных FAIL + accept — шесть вызовов, но два класса. Старый §6в снимает кап при наличии арбитражного файла; этот клапан противоречит новому бюджету. `fixtures/freeze_contract/case_kap_*` и `probe_012_dva_kruga.sh` закрепляют ПРЕЖНЮЮ семантику и требуют миграции в зоне implementer, а не новой параллельной функции со старым порогом.

`contracts/140-odin-agent-na-predmet.md` / `scripts/zamok_predmeta.sh --sudit` / `.omp/extensions/spawn-guard.ts` уже образуют станционную дверь ДО `task`: атомарные мьютексы на все предметы batch, запись `START` в `<state>/zamok/uchet.jsonl` ДО разрешения, `klass=sudja`, `rol=critic|critic-sol`, `repoId`, `subjectId`, `holder`, `object`. Yield в журнале служит состоянием сессии, а не единицей счёта; RELEASE не удаляет START. Судья с повторным OBJECT отвергается, но новый OBJECT после FAIL разрешён без бюджетной сверки. `scripts/spawn_agent.sh` не перехватывает реальный вызов `task` (арбитраж 099). Условия D10, D11, D21 и атомарный batch 140 сохраняются; новой двери в расширении не создаётся.

`roles/critic.md` §Быстрый-процесс (owner/plan-154 §Остановка и §Счёт), `roles/orchestrator.md` §Бюджет и `AGENTS.md` §Арбитр определяют санкцию и позицию автора; этот guard только считает и не заменяет слово владельца. `scripts/pre_critic.sh` проверяет кандидата до суда, но не является перехватом платного вызова; `scripts/done_contract.sh` требует frozen и verdict, но не перепроверяет станционный журнал. `contracts/011`/`078` регулируют версии и origin при freeze, их tag/registry-проверки сохраняются.

`registry/plan.tsv` держит очередь 154, не число judge-сессий; `NABLIUDENIA_ARCHITECT.md` А-210 предупреждает о потерянных круговых событиях при консолидации verdict, А-933 — о повторе имени holder и выборе старого журнала, А-936 — о гонке параллельных гейтов, А-937 — о ложном basename зелёном проводки. Батарея использует уникальные holder, последовательно вызывает гейты и уникальное имя guard. `verdicts/critic/contracts-NNN-*.md` сообщает исход, а git-история verdict — историю текста и переименований, не число живых сессий: ни один из этих источников не ловит судью, оборвавшегося до файла.

## Frontier и единица учёта

Выбор — счёт START критиков из существующего станционного журнала, под тем же мьютексом в `zamok_predmeta.sh`, и повтор в `freeze_contract.sh` до тега. Альтернатива «считать файлы» пропускает обрыв и сбрасывает счёт переименованием; «считать коммиты» повторяет Н-57; «считать смены классов» — наблюдаемый дефект 154. Новое место записи не требуется: одна функция подсчёта живёт в существующем `zamok_predmeta.sh`, вызывается под предметным мьютексом из `--sudit` и в read-only режиме `--schet-kritika --sostojanie <state> --repo <repo> --subject <NNN> --phase freeze` из `freeze_contract.sh` (не второй счётчик). Новый скрипт-guard не вводится; 041 §Инварианты 1 исключает правки уже существующего гарда, его профиль 140 сохраняется. Путь к состоянию для freeze передаётся явным аргументом после ROOT (тот же `<state>/zamok`, что extension выводит из живого session-file); без пути/при недоступности журнала — `SCHET_NEIZVESTEN`, даже если вердикт accept. Одна станция — один источник истины: CI не имеет локального журнала и НЕ выдаёт себе мнимый ноль; CI запускает батарею с собственными игрушечными state, а живую заморозку выполняют на станции с настоящим `<state>`; перенос станции без полного ledger — явно именованный стоп.

История verdict и файлы — только вторичные свидетельства: существующий `accept|FAIL|ESCALATE` без единого critic START того же `(repoId,subjectId)` — `SCHET_RASHOZHDENIE`, битый/нечитаемый обязательный файл или JSONL — `SCHET_NEIZVESTEN`. Редактирование и копирование verdict НЕ увеличивают число START; отсутствие verdict у оборванной сессии НЕ уменьшает число START. Переименование, место файла, версия и SHA OBJECT не входят в ключ счёта. Если история файлов не позволяет связать verdict с конкретной сессией без идентификатора в вердикте, её количество не вычитается из START и не объявляется доказательством равенства; это явное ограничение вторичного источника, а не успешная сверка двух несопоставимых единиц. При доказанном противоречии (verdict без START) отказ, не предпочтение удобного источника.

## Инварианты

- И-1. До разрешения `critic|critic-sol` предмета NNN под атомарным замком посчитать все предшествующие START этих ролей с точным `(repoId,subjectId)`, включая оборванные/освобождённые и все OBJECT/версии. При count >= 5 отказ `KAP_VYZOVOV_KRITIKA` до записи START и до спавна; при count < 5 существующие D10/D11/D21 и batch-атомарность сохранены. Арбитраж и его первая строка не меняют условие. Другие роли не расходуют именно этот бюджет.
- И-2. Freeze независимо перечитывает тот же полный станционный учёт и до записи тега/реестра отвергает count > 5 (`KAP_VYZOVOV_KRITIKA`) и отсутствие полного учёта (`SCHET_NEIZVESTEN`). Count <= 5 сам по себе не даёт freeze: требуется прежний закоммиченный accept, остальные freeze-гейты остаются. Пять FAIL с accept шестым недопустимы и при повторной сверке; четыре FAIL + accept пятым допустимы.
- И-3. Неизвестное/битое состояние, локальный журнал без START при существующем вердикте, чтение не той станции — именованный отказ; начальное отсутствие журнала у судьи НЕ трактуется как ноль с автоматическим созданием пустого файла. Объединение журнала и verdict по имени файла/классу/OBJECT не заменяет полный счёт START.
- И-4. Результат проверки отделён от полномочия на исключение: строка санкции, файл арбитра, версия, renaming и переобъявление риска не увеличивают кап. Шестой вызов/новый бюджет/смена риска — только новое решение владельца, не решение скрипта и не режим обхода через причину тега.

## Приёмка

`W` = `bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh` из корня харнесса; игрушечные git-репозитории, честная модель вставляет бюджетную проверку в РЕАЛЬНЫЕ копии `zamok_predmeta.sh` и `freeze_contract.sh`, оставляя остальную механику. Конформный вход — корректный JSONL START с совпадающими repoId/subjectId, событие task с ролью и pin, действующий origin/toy git, verdict с первой строкой из грамматики; именованные отрицательные входы — удалённый/битый/расходящийся источник. Валидный контрпример стаба = расхождение с моделью на конформном входе независимо от значений holder/OBJECT/пути временного мира; отсутствие ledger — отдельный отрицательный вход, требующий отказа. Оракул результата фиксируется в памяти ДО вызова субъекта.

1. Дано текущее дерево; когда `W`; тогда rc 1 и именованные `RED` по пяти последовательным FAIL, смешанным исходам, арбитражу, именам, обрыву, freeze сверх капа и неизвестному журналу. Парный положительный вход: четыре FAIL + accept при пятом START → `freeze_contract.sh` rc 0 и тег; уже пять START и шестой critic → отказ до нового START.
2. Дана честная модель: когда `W --model`; тогда rc 0, `CELLS=35 GREEN=35`: границы 0..7 на спавне и freeze плюс отдельные состояния арбитража с разными первыми строками, переименования, копии, версии, смены OBJECT/holder, обрыва, расхождения и недоступного/отсутствующего/структурно-битого журнала. Парный негатив: `W` на нереализованном дереве → rc 1 с `GREEN<35`. Свойство конечного домена: `W --domain-model` → rc 0 `CELLS=136 GREEN=136`; `W --domain` до реализации → rc 1 `GREEN<136`. Для n=0 исход и переименование отсутствующего verdict не различимы; для abort без verdict переименование не является конформным; для freeze n=1 исход самого первого START заменён обязательным accept, а дополнительный исторический verdict при n>1 допустим только когда прежняя сессия его создала. Поэтому sweep перечисляет все различимые конформные пары `(n=0..7, исход FAIL|accept|обрыв, арбитраж да|нет, перенос имени да|нет)` отдельно для двери и freeze, не приравнивая несоздаваемую комбинацию к честному входу.
3. Даны восемь обманных изменений эталонного счётчика: сжатие по роли, снятие капа арбитражем, новый бюджет для имени holder, игнорирование сессий без yield, разрешение шестого при freeze, отказ с правильной причиной ПОСЛЕ создания frozen-тега, старый rc=2 вместо именованного отказа на нечитаемом ledger, пропуск расхождения ledger/verdict; когда `W --stabs`; тогда rc 0, `SVJAZI=8 CAUGHT=8 LIVE=0`. Каждый стаб прикреплён в исполнимом `probe.py` к своему отличающему входу; выживший → `STAB_SURVIVED` и rc 1. Отрицательная пара: `W --model` на тех же мирах → все зелёные, без ложной красноты.
4. Дана реализация: когда `W`, `W --domain` и `W --stabs`; тогда все rc 0 и обе матрицы; при безфлаговом W непосредственно исполняются поставленные scripts/, не отдельная копия поведения в тесте. Дано состояние после пяти FAIL и существующий арбитраж; когда настоящий `zamok_predmeta.sh --sudit` до task, тогда rc 1 `KAP_VYZOVOV_KRITIKA`, ledger без шестого START. Дано пять START и accept шестым, когда настоящий `freeze_contract.sh` с явным состоянием, тогда rc 1, frozen-тег и registry без новой записи.
5. Правило совместимости: implementer переносит прежние ожидания §6в в `fixtures/freeze_contract/` на новую единицу и предъявляет прежние freeze-ворота зелёными, не вырезая чужую фикстуру. `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` на существующем дереве → rc 1, `KLETKI 66 KRASNYH 3` ровно по прежним лимитам групп 140 (`u01`, `w20`, `w21`, frozen 140 §Приёмка п.9), а после реализации 154 не добавляет НОВЫХ красных клеток: замок D10/D11/D21/пакет неизменен; когда отдельная работа 140 меняет капы групп, её собственная батарея достигает rc 0 НЕ ценой расширения зоны 154. Существующий профиль `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` остаётся rc 0 при добавлении read-only режима того же скрипта; второго parser guard нет. Реальные живые пути судьи и freeze после реализации предъявляются оркестратору перед судом, не выводятся из toy-модели.
6. Правило ворот: `bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md`, `bash scripts/check_ceilings.sh`, `bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md`, `bash scripts/check_zones.sh .` → rc 0 последовательно. `bash scripts/check_provodka.sh . contracts/154-schet-vyzovov-kritika.md` до подключения CI → rc 1 «guard не подключён», после строки CI → rc 0.

## Зоны и порядок

ЗОНА architect: contracts/154-schet-vyzovov-kritika.md fixtures/workshop_project/schet_vyzovov_154/
ЗОНА implementer: scripts/freeze_contract.sh scripts/zamok_predmeta.sh fixtures/freeze_contract/
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 013 заменить §6в без изменения проверок исхода verdict, версий и атомарности заморозки.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 вставить кап под предметным мьютексом до START; D10/D11/D21 сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/freeze_contract/ — 013 мигрировать только старые ожидания капа на новую единицу, не отключая совместимость.
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 добавить только строку self-test `check:schet-vyzovov-154-family-selftest`, с `W`, `W --domain` и `W --stabs` после реализации.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 027 менять только §6в; doc-preflight сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 036 менять только §6в; spec-preflight сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 038 менять только §6в; consumers-gate сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 043 менять только §6в; precision-gate сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 060 менять только §6в; workflow-root сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 078 менять только §6в; origin-гейт сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 084 менять только §6в; plan-гейт сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 122 менять только §6в; предпосылки сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 992 менять только §6в; fail-closed других гейтов сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 996 менять только §6в; workflowPaths сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/freeze_contract/ — 027 мигрировать только старые кап-сценарии без отключения doc-клеток.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/freeze_contract/ — 992 мигрировать только старые кап-сценарии без отключения fail-closed клеток.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер строки self-test 154.
Порядок: architect красное и модель → critic → freeze с состоянием станции → implementer одна функция в существующем замке + два режима её вызова + миграция старых ожиданий → orchestrator CI через `gen_ci_steps.sh --write` и `--check` → adversary (деньги) → reviewer → done. Ответственный за станционный путь и данные учёта при freeze — orchestrator, не CI. Ни роли судьи, ни AGENTS.md этот контракт не редактирует.

ПРЕДПОСЫЛКИ:
- setting читаемый полный ledger станции в том же корне, который использует spawn-guard; при переносе станции переносится полный журнал либо заморозка останавливается. CI-запуск без живого ledger использует только независимые игрушечные state.
- setting bash, git, jq, python3 в PATH CI и станции; дополнительных secrets/variables/environments не нужно.

ПРОВОДКА:
- guard=fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh
ПРОВОДКА-ЭНФОРСМЕНТ: существующее ограничение денег на платные сессии судьи получает количественный guard на уже существующем spawn-хуке и freeze; новой поведенческой нормы роли нет.

## Модель угроз

ЗАЩИЩАЕТ:
- пропуск сверх капа из-за одинаковых вердиктов, renaming, арбитража, смены OBJECT или обрыва сессии;
- «пусто значит зелёный» при недоступном/битом ledger, несуществующем repoId и verdict без START;
- обход спавн-барьера при прямом freeze: независимая повторная проверка перед тегом.

НЕ ЗАЩИЩАЕТ:
- злонамеренную ручную порчу локального журнала станции и подмену его полной согласованной копией: журнал 140 не подписан; именованный отказ покрывает отсутствие/порчу, не криптографическое происхождение. Ловец — журнал платформы и сверка оркестратора;
- обход установленного task-хука через другую установку omp/сырой запуск модели: ловец — независимый журнал сессий и аудиторские замеры станции;
- несогласованность при одновременном переписывании всего ledger из внешнего процесса: атомарность внутри одного процесса замка; ловец — ревьюер и станционный аудит;
- счёт сверх пятого по прямому слову владельца: до его нового явного решения этот механизм только отказывает и не вводит автоматический override.

## Незаполненные требования:
нет
