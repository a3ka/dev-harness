# Контракт 186 — В6: хранитель архитектуры

КЛАСС ЗАДАЧИ: смешанный — постоянная роль и норма работы (doc) плюс её маршрутизация, расписание и исполнимое красное предъявление (код).
КЛАСС РИСКА: обычный — расписание обзора архитектуры не меняет права/роли БД, авторизацию, безопасность, деньги, ПД/health-данные и согласия или юридически значимые действия продукта. L2 остаётся за владельцем.
КОНТЕКСТ: слово владельца 2026-11-10 ~17:49 UTC «1 да», `docs/owner/2026-11-10-arhitektura-v-processe.md`: постоянный субагент, тир plan (Astra, fallback @fable), находки, правки L1, обзоры срезов, схемы операций впрок (В7). Боль: находки 001–004 открыты с 2.4.2, 69 DRAFT-операций без владельца. 172 done — предшественник станционной проводки. Файл Fable-11 `ARCH-IN-WORKFLOW-SPEC.md` §8 на станции не найден (`find / -name ARCH-IN-WORKFLOW-SPEC.md -print 2>/dev/null`); точная грамматика §8 не утверждается данным контрактом: явное допущение и вопрос владельцу в конце.

## Существующее

- Бриф 170 (done): `contracts/170-arch-component-brief-vhod-zadanija.md` и `scripts/make_task.sh --arch-component` доставляют описание компонента в одно кодовое задание, не ищут регулярно находки. Архитектурные freeze/done-ворота принадлежат 187.
- Прецедентный `roles/steward.md`/`.omp/agents/steward.md` отвечает readonly по `decisions/` на тире steward/Haiku; копия не создаст находок, L1, операций В7. `roles/consultant.md` разбирает форки по вызову, `roles/architect.md` строит контракт и красные критерии по вызову. `AGENTS.md` §«Три роли»/§«Сессию ведёт РОЛЬ» требует именованную роль и явный инвентарь; §«Модели ролей» назначает `config/agent_models.json` единым источником.
- Парсер `scripts/roles.ts` читает `roles/*.md` и `config/agent_models.json`; `scripts/gen-harness.ts` производит `.omp/agents/*.md`, `.omp/config.yml` modelRoles/retry.fallbackChains и судит дрейф `--check`. Сейчас нет роли, записи `roles.architecture-steward`, routing-правила и агента. Тир `plan` уже существует: `model=@gpt-astra`, `fallback=@fable`, `autoFallback=true`; второй тир не заводить. `scripts/check_sud_model.sh --frontmatter` для этой роли непригоден: закрытый алфавит только critic/adversary/reviewer/arbiter (живой rc 2), расширение судейского барьера отдельный предмет.
- Таймер `ops/server/root/systemd/orch-ctx.timer`, станционный `ops/server/root/orch-peak` и `ops/server/install.sh` уже доставляют таймерные сообщения ведущей панели (тестовый шов `ORCH_PEAK_TEST`); `roles/orchestrator.md` потребляет сигналы станции. Таймер ctx обслуживает контекст, не арх-обзор; использовать механизм, не менять частоту ctx. `registry/plan.tsv` резервирует 186; `registry/pauzy.tsv` не помечает 186 паузой; в fixtures, ops, локальных wip и открытых PR нет реализации 186: bootstrap-черновик служит только `make_task` (Н-301).
- Источник `docs/owner/ARCHITECTURE.md` описывает архитектуру продукта, но не очередь работы станции. Проектные `Complior-back/architecture/` и `CompliorOS-architecture/governance/findings/` — источники истины, не зеркало в харнессе. Их состояние не подменяется тестовыми константами.

## Frontier: расписание и место истины

1. **Выбрано: недельный таймер станции → сообщение в панель → субагент через оркестратора.** Уже действующие `orch-peak@.service`, `orch-peak say`, `install.sh` и субагентский спавн дают один путь с обработкой занятого слота. Время по умолчанию: понедельник 09:00 UTC, `Persistent=false` (пропущенный тик не инициирует скрытый catch-up после рестарта). Оркестратор сохраняет очередь при занятом слоте и подтверждает исполнение следом в проектном журнале. Именно неотработанные 001–004 и DRAFT без владельца оправдывают регулярный обход, но не выдачу этой роли полномочий заморозки.
2. **Альтернатива — cron/systemd непосредственно запускает независимый omp-процесс:** отвергнуто на этой итерации: станция уже имеет единственную ведущую сессию и бюджет слотов; второй воркфлоу обходит `make_task`/спавн-страж и оставляет конфликт записей между продуктом и харнессом. Cron не выбран потому, что systemd-юниты уже устанавливаются, проверяются и наблюдаются `ops/server/install.sh`.
3. **Место истины — существующие проектные `architecture/` и `governance/findings/`, а не новый каталог харнесса.** Обзор фиксирует один снимок на срез, находку привязывает к проектной записи; L1 меняется адресно в архитектурном репозитории, L2 только пачкой с владельцем. Альтернатива «копировать findings и схемы в `fixtures/` харнесса» отвергнута: не закрывает отсутствие владельца у DRAFT, создаёт второй источник истины. Обязанность схем операций впрок не заменяет freeze/done-правила 187.

## Предмет, граница и исполнители

Результат 186: `architecture-steward` доступен как именованный субагент харнесса; плановое событие вызывает его через оркестратора, и роль умеет работать с находками, L1, срезами и схемами операций впрок. Architect сдаёт контракт и fixture; critic судит до freeze, implementer после freeze вводит роль/генерат/маршрут/таймер и обновляет станционную инструкцию; orchestrator подключает CI-шаг и отдельно проводит коммиты своих зон. Роль проекта не создаёт находки из воздуха, не разрешает L2 или DRAFT сама и не подменяет В4+В5 (187). `AGENTS.md` и старые уставные `roles/*.md` в этой пачке не правятся.

- Роль `roles/architecture-steward.md` имеет parser-frontmatter `role: architecture-steward`, объявленные tools и `verdict: null` (вердикт-артефакт роли не предписан; проектный результат — отдельная запись согласно проектному workflow). Самостоятельные разделы: «Находки» (источник governance/findings, доказательство и адресат), «Правки L1» (проверяемый коммит, L2 пачкой владельцу), «Обзор среза» (один снимок, расхождения), «Схемы операций впрок» (В7, контракты модулей до freeze, DRAFT не становится кодом), «Граница полномочий» (проектный state, не харнесс). Норма роли объясняет порядок и не копирует `steward`.
- Единственный источник назначения: `config/agent_models.json` `roles["architecture-steward"]="plan"` и отдельное `routing.rules[]` на плановый архитектурный обзор; существующий `tiers.plan.model="@gpt-astra"`, `fallback="@fable"` остаётся без нового тира. `npm run gen:harness` тем же коммитом производит `.omp/agents/architecture-steward.md` с отдельной строкой `model: ["@plan"]` и синхронизирует `.omp/config.yml`; `npm run gen:harness -- --check` даёт rc 0. Изолированный toy-контроль создаёт собственный `.git`, не `git worktree` общего checkout (Н-193).
- Расписание: `ops/server/root/systemd/orch-architecture.timer` еженедельно Mon 09:00 UTC вызывает `orch-peak@architecture.service`; `ops/server/install.sh` включает юнит в устанавливаемый/проверяемый перечень, action `architecture` в `ops/server/root/orch-peak` отправляет сигнал штатным `say` (НЕ слово владельца). `roles/orchestrator.md` принимает сигнал как задание именованному субагенту и сохраняет отложенный запуск при занятом слоте. `ops/server/README.md` описывает установку/период и отключение; новых секретов нет.
- Конформный контрпример: полный toy Git-репозиторий с неповреждёнными роль-парсером/генератором, реестром моделей и `ORCH_PEAK_TEST`, где вызов `architecture` проходит текущий публичный CLI; валидное расхождение инвариантно к имени temp-каталога и Git OID и наблюдается на записи маршрута, секции роли или фактическом `say`. Данные ожиданий фиксированы в памяти проверяющего до запуска субъекта: токен находится в своей секции роли/строке поля либо в отдельной строке полученного сигнала, а не где угодно в файле. Повреждённый Git, отсутствующий node и произвольное неверное имя action не являются контрпримером 186; ошибка среды не маскируется зелёным результатом.

## Приёмка

- Дано: дерево без 186-роли; когда `python3 fixtures/workshop_project/architecture_steward_186/probe.py --repo .`; тогда rc 1, каждая отсутствующая обязанность/маршрут/генерат/расписание получает собственную строку `KRASNO`, существующий `fallback @fable` остаётся зелёным. Дано: полный реализованный набор; та же команда → rc 0, все независимые строки `ok`.
- Дано: независимый честный toy-контроль с ролью, реестром, генерацией и реально вызванным станционным action; когда `python3 fixtures/workshop_project/architecture_steward_186/probe.py --model`; тогда rc 0 и все строки `ok`, включая реальное сообщение `say.log`. Дано: искажённые варианты; когда `python3 fixtures/workshop_project/architecture_steward_186/probe.py --stabs`; тогда rc 0, каждый вариант `caught @ <различающий публичный шов>`, строк `ZHIV` нет. Код fixture, а не проза, сопоставляет вариант с его различающим входом.
- Дано: завершённая реализация; когда `npm run gen:harness -- --check`; тогда rc 0 и отдельная строка `model: ["@plan"]` в frontmatter агента при `python3 fixtures/workshop_project/architecture_steward_186/probe.py --repo .` зелёная в клетке `generated`. Дано: установленный таймер и вызванный action `architecture` в `ORCH_PEAK_TEST`; та же батарея → rc 0, строка `schedule ok` только после реального сигнала; без timer/dispatch → rc 1 `schedule KRASNO`.
- До критика: `bash scripts/pre_critic.sh contracts/186-hranitel-arhitektury.md` → rc 0; перед done `bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md` → rc 0. Шаг CI с этой же батареей подключает orchestrator; зелень только `--model` не считается готовностью реализации.

## Незаполненные требования:
- Точная грамматика обязанностей Fable-11 §8 недоступна на станции; вопрос владельцу ниже. До получения источника конкретные форматы артефактов L1/В7 не заявлены.

## Зоны и проводка

ЗОНА architect: contracts/186-hranitel-arhitektury.md fixtures/workshop_project/architecture_steward_186/
ЗОНА implementer: roles/architecture-steward.md config/agent_models.json .omp/agents/architecture-steward.md .omp/config.yml ops/server/root/systemd/orch-architecture.timer ops/server/root/orch-peak ops/server/install.sh ops/server/README.md roles/orchestrator.md .omp/agents/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
Граница пересечения: карта моделей 029/998/165/166 сохраняет существующие тиры и роли; новые строки 186 добавляют только новый route. Генератор меняет только свою производную секцию `.omp/config.yml`, не task/isolation. В `roles/orchestrator.md` добавляется потребитель планового сообщения и пересобирается его зеркало; `ops/server/` оставляет stop/start/ctx и добавляет action, timer и строки установки/README. Если `check_charter.sh` требует специальной строки разрешения уставной правки роли, её дословный текст даёт владелец перед implementer-коммитом роли; architect/implementer не подписывают его за владельца. Правка AGENTS.md не требуется; если понадобится расширить уставные «Три роли», это отдельная санкция и отдельный owner-коммит. CI проводит orchestrator только своим шагом 186.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только пересборка после новой строки роли; старая норма неизменна.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 005 генератор добавляет только роль 186; прежние назначения неизменны.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 010 генератор добавляет только роль 186; прежние назначения неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только потребитель сигнала 186, прежняя ведущая роль не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только потребитель сигнала 186, прежний GC не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только потребитель сигнала 186, прежняя приёмка документов не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только потребитель сигнала 186, прежняя судейская церемония не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только потребитель сигнала 186, прежний маршрут консультанта не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только потребитель сигнала 186, прежний реестр не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только потребитель сигнала 186, прежний cwd не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только потребитель сигнала 186, прежняя ПРОВОДКА не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только потребитель сигнала 186, прежняя сложность не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только потребитель сигнала 186, прежний учёт не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только потребитель сигнала 186, прежний диапазон не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только потребитель сигнала 186, прежний PR-маршрут не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только потребитель сигнала 186, прежние исключения CI не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 186; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка 186; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 186; чужие строки неизменны.
ПРОВОДКА:
- role=roles/architecture-steward.md «По расписанию проверь проектные находки и схему операций, внеси доказанные L1-правки, собери L2 для владельца и сними один архитектурный срез; DRAFT-операции не выдавай за готовый код.»
- role=roles/orchestrator.md «По плановому сигналу станции вызови architecture-steward; при занятом слоте оставь задание в очереди и проверь след исполнения.»

## Модель угроз

ЗАЩИЩАЕТ:
- От вечного отсутствия исполнителя архитектурного обзора защищают зарегистрированная роль, плановый таймер, потребитель сообщения и наблюдаемый вызов action.
- От подмены хранителя прецедентным readonly-steward защищают раздельные обязанности в роли и назначение роли→тир с генерацией.
НЕ ЗАЩИЩАЕТ:
- От ошибочного архитектурного вывода самой модели и от правки L2 без подписи владельца на чужом проекте: роль предписывает маршрут, ревьюер сверяет проектный результат, В4+В5 (187) обеспечивает ворота.
- От сетевого отказа станции и недоставленного сообщения при недоступной панели: action отказывает, оператор сверяет journal/timer; повторность запуска и валидация результата отдельного проектного workflow не подменяются этим контрактом.

ПРЕДПОСЫЛКИ:
- setting Существующая root-установка `ops/server/install.sh` (systemd + tmux + ведущая панель) и `ORCH_PEAK_TEST` доступны; для теста необходимы bash, python3, git, node/npm; новых secrets, variables, environments и настроек GitHub не требуется.
- setting Проектный источник архитектуры доступен роли через проектный workflow; запись не совершается в хранилище харнесса.

## Открытый вопрос владельцу

Точный текст `ARCH-IN-WORKFLOW-SPEC.md` §8 не найден на станции и в доступных репозиториях: есть ли в нём обязательные имена/форматы findings, L1, архитектурного снимка и операций В7 или периодичность, отличная от принятого Mon 09:00 UTC? До предъявления источника роль опирается только на прямое слово владельца 2026-11-10 и существующие проектные каталоги, не утверждает формат, которого мы не видели. Изменение семантики §8 при появлении источника — отдельная сверка до freeze; самостоятельное домысливание запрещено.
