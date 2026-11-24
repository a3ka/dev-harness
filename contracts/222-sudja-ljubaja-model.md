# Контракт 222 — любая модель любой роли: конфиг назначает, механизм сверяет факт

КЛАСС ЗАДАЧИ: кодовый — существующие двери, их потребители и несовместимые старые ожидания.
КЛАСС РИСКА: рисковый — безопасность: ложный допуск модели-факта материализует неподтверждённое судейское доказательство.
КОНТЕКСТ: Н-458, переданная затравка consultant/draft-222-sudja-ljubaja-model.md; слова владельца 24.11.2026 ~18:53 UTC «все варианты должны работать и мы сами это решаем» и ~18:56 UTC «не только судья, а все агенты должны работать на моделях, которые мы сами решаем и вписываем в конфиг файл». Прежнее ограничение «основная или запасная своего тира» заменяется этим предметом, не новым флагом политики.
КОНТЕКСТ: наблюдение Н-458 передано заданием: per-call запасная имеет allowed, но check_sud_model требует основную; остановка судей около четырёх часов. В базе этой копии 8b52fade7975034d7cabece67e46c16a7d1abe3b записи Н-458 ещё нет; отсутствие записи не выдаётся за отсутствие измеренной боли.
КОНТЕКСТ: обещание — произвольный назначенный конфигом selector не запрещается из-за роли, тира, семейства, провайдера или совпадения с автором. Наблюдение — rc настоящих CLI, блок настоящего обработчика tool_call, точные байты verdict-журнала и трассы, фактический argv exec лаунчера, результат настоящего генератора. Frozen 104/2 и 099/1 меняются только в модельном запрете; 028/3, 129/2, 140/5, 166/2, 186/2 сохраняют независимые свойства, перечисленные ниже.
СДАЧА: fixtures/workshop_project/lyubaja_model_222/SDACHA.md

## Предмет

Единственный источник назначения — config/agent_models.json и его производные. Любая вписанная модель применима к любой роли. Сохраняется check_sud_model.sh как общая дверь существующих потребителей; снимается сравнение модели СПАВНА с основной моделью тира. После запуска остаётся сравнение модели-ФАКТА с назначением: обычным из конфига либо явно переданным при данном вызове. Модель не является идентичностью автора или подписи: равенство моделей само по себе не запрещает ни судью, ни пару consultant/arbiter, ни свидетельство класса форка.

Без явного назначения при вызове фактом нельзя задним числом заменить ожидание. Для per-call вводится аргумент `--assigned-model <selector>` у `check_sud_model.sh --verdict` и хвостом после тройки `--sud` у `judge_gate.sh --verdict-row`. Его значение — тот же selector из фактического запроса task, до запуска выбранный из конфига; оркестратор переносит назначение из запроса, НЕ из полученной трассы. Без аргумента ожидание — назначение роли из конфига. Аргумент не создаёт второй список моделей: resolver проверяет присутствие selector в models либо в разрешённых через resolveModelRef значениях tiers.model/fallback. Необъявленный selector — именованный отказ; отдельного modelPolicy/free/allowlist нет.

Трассы --tsv (три поля) и --tsv --bind (пять) не расширяются. allowed означает прямое назначение, включая явную per-call запасную; denied означает фактический автофолбэк и по-прежнему сверяется с объявленным fallback. autoFallback и механизм переключения по квоте не меняются. По каждой строке роли проверяются модель, session и OBJECT; вторая неверная строка не скрывается первой верной. Совпадение модели автора с назначенной моделью судьи допускается; запрет судить собственную работу остаётся запретом идентичности, не семейства.

Алфавит agent и явный agent остаются: это сверка типа исполнителя, не запрет модели. Скрытый task-дефолт теряет роль, а не только модель. Frontmatter↔roles→tier остаётся сверкой производной с источником. overlay сохраняет проверку images: yes для инструментов, реально требующих изображений, и тира vision: это способность исполнить задачу, а не выбор марки/провайдера. Метрики расхода и необходимая аутентификация провайдера не отменяются.

## Существующее

Сверено по базе 8b52fade7975034d7cabece67e46c16a7d1abe3b; номера строк относятся к этой базе, не к будущей реализации. Полный список ниже — классификация мест, а не поручение переписать каждое из них.

| Место | Что делает сейчас; судьба |
|---|---|
| scripts/check_sud_model.sh:93–145,190–205,209–224 | Алфавит судей, буквальное сравнение с bare/full эквивалентностью 173, единый resolver 198; СВЕРКА остаётся. Запрет спавна на модели вне основного тира СНИМАЕТСЯ. Алфавит selector принимает существующие в реестре :effort и @route, не только -._/. |
| scripts/check_sud_model.sh:232–247,261–337 | Frontmatter, пятиколоночная трасса, session/OBJECT и каждая строка — СВЕРКА остаётся. allowed≠основная перестаёт быть запретом, когда назначена per-call модель; факт≠назначение остаётся отказом. denied проверяет настоящий объявленный fallback, не произвольную модель. |
| scripts/judge_gate.sh:53–59,105–126 | Требует --sud и вызывает дверь ДО append. СВЕРКА остаётся; переносит новый явный аргумент назначения, не вычисляет его из факта. Старые формы без override сохраняются. |
| scripts/models_actual.sh:119–122,138–182,194–205 | Производит фактические строки и allowed/denied по model_change, сохраняет привязку. ОСТАЁТСЯ; фиксированная SESSION_ROLE=architect в старом человекочитаемом отчёте — известная старая мера 011, не модельный запрет спавна и не предмет её починки. |
| .omp/extensions/session-trace.ts:28–55 | Свидетельство только после live API == model_change; пишет модель-факт orchestrator. ОСТАЁТСЯ как СВЕРКА, назначение за факт не выдаёт. |
| .omp/extensions/spawn-guard.ts:104–145,239–263 | Установочный конфиг, замкнутый алфавит ролей, task запрещён, batch/flat, fail-closed; модели вообще не сравнивает. ОСТАЁТСЯ: роль — не модель. |
| scripts/zamok_predmeta.sh:146–150,1100–1190,1260–1430 | Поля события, роли, SUBJECT/OBJECT/пин, D52/D9, изоляция/сдача/порядок. Предиката модели/тира в этой двери НЕТ; ОСТАЁТСЯ без изменений. |
| .omp/extensions/fallback-route.ts:22–25,76–86,115–132 | autoFallback и целевой selector из конфига; иной провайдер требуется только при обходе исчерпания аккаунта. ОСТАЁТСЯ: это маршрут восстановления 129 при квоте, не запрет назначить роль той же модели/провайдеру. Переписывать автофолбэк omp здесь непригодно. |
| scripts/spawn_agent.sh:327–358,568–582 | Подготовка ветки/worktree и манифест, не реальный task-spawn судьи; своего модельного запрета НЕТ. ОСТАЁТСЯ; переносить модельную дверь сюда непригодно (арбитраж 099). |
| scripts/make_task.sh:358–377 | Строка трассы физической роли, allowed/denied и обязательный авторский след; семейный запрет уже снят 166. ОСТАЁТСЯ как СВЕРКА; новый whitelist моделей здесь не нужен. |
| scripts/roles.ts:215–229,270–365,386–399 | Единые readAgentModels/resolveModelRef/resolveRoleModel, routing, алиасы и именованные отказы. ОСТАЁТСЯ; разрешение явно назначенного selector использует эти примитивы, не второй разбор roles→tiers→models. Вырожденный agentModels без конфига обслуживает частичные fixture-деревья, не разрешает реальный спавн без конфига. |
| scripts/gen-harness.ts:62–78,305–335; package.json gen:harness | Генерирует agents, modelRoles и fallbackChains; --check судит дрейф, не бренд модели. ОСТАЁТСЯ; ручной пин вместо производной СНИМАЕТСЯ там, где обнаружен. |
| scripts/gen_ci_steps.sh, gen_ci_workflow.sh, gen_plan.sh, gen_project_workflow.sh | Поиск model/модель/routing/tiers/fallback — совпадений НЕТ; собственного ограничителя модели нет. Непригодны к правке ради Н-458. |
| workshop:218–230,615–624,688–715,1375 | Назначение orchestrator/consultant, разворачивание семейства оверлея, явный --model в exec. ОСТАЁТСЯ как проводник производных; второй список моделей не нужен. |
| scripts/overlay.sh:81–104,106–145,167–175 | --check производных и images: yes; учёт ключевого провайдера/прокси. ОСТАЁТСЯ как сверка способности и учёта, не запрет по имени модели. |
| scripts/merge_architecture_pr.sh:105–134,257–280 | 186 уже читает назначение critic из конфига и строго сравнивает полное модель-факт; СВЕРКА остаётся, GLM-константы нет. Этот GitHub-путь не начинает произвольный per-call суд: его назначение — реестр; новые обходы этой границы не вводятся. |
| scripts/check_fork_route.sh:190–199,290–320,394–416; scripts/verify_consultant.sh:120–132 | Равенство МОДЕЛЬ с АВТОР и между consultant/arbiter ошибочно используется как идентичность — СНИМАЕТСЯ. Обязательные МОДЕЛЬ/АВТОР, роли подписей, подтверждение и маршруты остаются. verify_consultant проверяет наличие модели, а не её бренд — не правится. |
| scripts/check_*model* | По фактическому списку имён есть check_sud_model.sh и check_threat_model.sh; последняя проверяет МОДЕЛЬ УГРОЗ документа, не модель агента. check_agent_models.sh в дереве отсутствует, создавать аналог не нужно. |
| config/agent_models.json:3–107,108–174; config/models-*.yml | models/tiers/roles — источник назначений; routing — выбор РОЛИ по работе, autoFallback — согласованный маршрут переключения. ОСТАЮТСЯ; менять сами назначения и исторические why в этой реализации не требуется. |
| AGENTS.md:43–59,81–94 | УЖЕ конфиг — единственный источник, совпадение модели/семейства/провайдера не отказ. ОСТАЁТСЯ без правки; images-проверка — способность. Старый отчёт models:actual назван старой мерой, не новым правилом. |
| roles/critic.md:36,194–206; roles/critic-sol.md:160–172 | Упоминания штатного Sol и запрет общего advisor — второй нормативный пин, СНИМАЕТСЯ. Остаются ссылка на конфиг, модель-факт, запрет самосуда и бюджет. Модель не идентификатор консультанта/арбитра. |
| roles/arbiter.md:53–64; roles/consultant.md:140–158,223–226 | Фиксированная Fable/GLM и запрет по равенству моделей СНИМАЮТСЯ; роли/след/несовмещение одним актором остаются. |
| roles/orchestrator.md:97–99,136–146,187–189,436 | Источник назначения, фактическая трасса и L1-сверка сохраняются; добавляется перенос per-call назначения из запроса. Не сравнивает семейство автора. |
| roles/reviewer.md:89–91; roles/adversary.md:60–62; roles/critic-sol.md:20–22; roles/architecture-steward.md:124 | Уже ссылаются на назначение и не запрещают совпадение — ОСТАЮТСЯ. |
| roles/architect.md:315–318; roles/implementer.md, implementer-glm.md:133; roles/implementer-vision.md; roles/steward.md | Поиск не нашёл запрета selector; «дорогая модель» — описание роли, не исполнимый список. Упоминания архитектурной модели не относятся к LLM. Не правятся ради модели. |
| fixtures/zashchita_main_104/red_sud_model_dver_spavna.sh; red_sud_model_materializatsija.sh:16–40; battery_stubs.sh:119–207 | Старые отрицания чужого тира и таблицы стабильных моделей меняются только в снятом запрете; привязка session/OBJECT, отсутствие --sud и все строки сохраняются. Frozen-блоб 104 не переписывается. |
| fixtures/workshop_project/fallback_subagent_129/battery.py:15–20,45–46,65–100 | Параметризует роли и модели реестром; контроль квоты/фолбэка 129 остаётся, не фиксирует разрешённую модель судьи. |
| fixtures/workshop_project/model_choice_166/probe.py:17–20,64–70 | Пин frozen/095/1 — источник исторического честного кандидата для снятия семейного отказа. Не оперативный запрет назначения; сохраняется регресс 166. |
| fixtures/workshop_project/architecture_steward_186/; contracts/186-hranitel-arhitektury.md:71 | Живое назначение critic вместо GLM-константы; сохраняются строгая сверка факта и неизменность чужих назначений самим 186. Ввод 222 не возвращает пин GLM. |
| fixtures/models_actual/case_model_razoshlas.sh:31–33; fixtures/workshop_project/odin_agent_140/probe.py:68–72,94–95 | 028 проверяет расхождение с объявлением, 140 пинит носители sha256/source.json и судит замок, не модели. Пины не менять. Семья 099 — историческая предшественница 104, не новый производственный whitelist. |
| fixtures/workshop_project/sud_model_173/probe.py:12,17–22,76–99 | Пин frozen/104/2 и ожидаемые строки старой двери. Перенести только несовместимые ожидания запрета спавна; full/bare эквивалентность и запрет другого полного провайдера в СВЕРКЕ ФАКТА сохраняются. |
| fixtures/check_fork_route/red_zapret_dvojnoj_roli.sh, red_marshrut_b_volja_batch.sh, red_schet_peredatochnyh.sh, _forks.sh | Модельные прокси двойной подписи/автора обновляются вместе с дверью; остальная грамматика, счёт и маршруты не ослабляются. |

Сверка frozen-блобов воспроизводима: `python3 fixtures/workshop_project/lyubaja_model_222/catalog.py --frozen` — читает именно `git show frozen/contracts/<N>/<vmax>^{commit}:<файл>`, а не текущую копию контракта. 104/2: Решения 2–5 и алфавит сохраняются, модельный запрет заменён; 099/1: заменён только Н-270-предикат модели; 129/2: автофолбэк и граница квот сохраняются; 166/2: свобода модели и авторский след сохраняются; 186/2: строгая сверка назначенного критика и L1-правила сохраняются; 028/3: зона/HOME и грамматики трассы сохраняются; 140/5: замок/пин/OBJECT/изолированность/порядок не меняются. 029/051: снимается прокси равенства моделей, не разделение ролей и не грамматика ответа. Старые frozen-тексты и теги не правятся.

## Frontier

А — ВЫБРАН: снять модельный запрет в существующей двери, сохранить трассу и потребителя, передавать явное назначение при вызове. Закрывает per-call запасную из Н-458 без смены основной модели тира; след уже несут 028/104/166/173/198. Добавленный аргумент — данные одного назначения, не переключатель политики.

Б — удалить check_sud_model, перенести сравнение в models_actual/judge_gate — отклонено: producer факта и потребитель вердикта получают ещё и общую валидацию, мигрируют frontmatter/spawn-потребители, хотя болит один запрет. Потеря общего шва не закрывает дополнительной измеренной боли.

В — modelPolicy: free / дополнительный whitelist / разрешение семейства по роли — отклонено: второй источник решения воспроизводит тот же четырёхчасовой простой на следующей модели.

## Инварианты и граница входов

И1. Любая модель реестра — для любой роли: основная, запасная per-call, модель другого тира/семейства и модель автора. `--spawn` проверяет объявленность, но не равенство основной. Все эти положительные входы дают rc 0; без agent, вне алфавита роли и без конфига — отказ. Команда семейства `--repo .`, после реализации rc 0.

И2. Факт сверяется с назначением, НЕ с брендом. Обычный факт≠назначение, per-call факт≠переданное назначение, чужие session/OBJECT, отсутствие трассы и вторая неверная строка — отказ до append; честные следы дают ровно одну verdict-строку. Команда семейства `--repo .`, после реализации rc 0; реестр обманных вариантов исполняется режимом `--stabs`, rc 0.

И3. Единый источник: поменять только значение одной записи models в изолированном мире и вызвать реальный gen-harness → каждый tier, каждый generated agent, resolver каждой роли и явный --model orchestrator/consultant в exec следуют записи; generator --check rc 0. Старый fixed-selector даёт расхождение. Команда семейства `--model --case single-config-line`, rc 0; launcher-клетки входят в полный режим.

И4. Сохраняются пятиколоночная привязка и три поля --tsv, обязательная модель-факт в вердикте/ответе, обязательные agent и алфавит из УСТАНОВКИ. Равенство моделей не доказывает равенство акторов; запреты самосуда и совмещения одним актором остаются существующими нормами ролей, без нового механизма идентичности в 222. Команда семейства `--repo .`, после реализации rc 0.

Конформные входы — действующие CLI, task-события batch/flat и JSON-конфиг roles/tiers/models с разрешимыми алиасами. Selector — непустой ASCII `[A-Za-z0-9._/@:-]+`, без TAB/LF/пробела; effort и route являются частью selector, а не сравниваются по подстроке. Роль-судья — critic/adversary/reviewer/arbiter; остальные роли — ключи roles установленного конфига. session — `[A-Za-z0-9._-]+`; OBJECT — 40 lowercase hex; трасса — пять TAB-полей с allowed|denied и OBJECT либо `-`. Аргументы и поля сравниваются буквально, кроме уже принятой 173 эквивалентности одного bare/full имени. Терминатор OBJECT — конец самостоятельной строки. Конфиг разбирает настоящий JSON parser и существующий roles.ts; нового парсера формата здесь нет. Валидный контрпример: расхождение на конформном входе, инвариантное к произвольной подстановке значений, не только к строкам этой батареи.

## Зоны

ЗОНА architect: contracts/222-sudja-ljubaja-model.md fixtures/workshop_project/lyubaja_model_222/
ЗОНА implementer: scripts/check_sud_model.sh scripts/judge_gate.sh scripts/roles.ts scripts/check_fork_route.sh fixtures/zashchita_main_104/ fixtures/workshop_project/sud_model_173/ fixtures/check_fork_route/ roles/critic.md roles/critic-sol.md roles/arbiter.md roles/consultant.md roles/orchestrator.md .omp/agents/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

Пересечения с уставными документами: roles/critic.md, roles/critic-sol.md, roles/arbiter.md, roles/consultant.md, roles/orchestrator.md — только снятие вторых модельных пинов и перенос явного назначения; правка исключительно с адресной строкой РАЗРЕШИЛ-ВЛАДЕЛЕЦ в коммите по полученному слову владельца. В этой architect-пачке роли, AGENTS.md и производные НЕ меняются. AGENTS.md уже выражает источник и свободу выбора и не нуждается в переписывании. Номер/строка registry/plan.tsv не зона этой пачки.
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 002 только разрешение назначения 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 002 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 002 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 003 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 005 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic-sol.md — 005 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 005 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/consultant.md — 005 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 005 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 005 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 008 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic-sol.md — 008 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 008 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/consultant.md — 008 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 008 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 010 только разрешение назначения.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 010 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 011 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic-sol.md — 011 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 011 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/consultant.md — 011 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 011 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 011 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 015 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic-sol.md — 015 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 015 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/consultant.md — 015 только модельные пины.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 015 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 016 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только перенос явного назначения; HOME неизменен.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/check_fork_route/ — 029 только модельные прокси, маршруты и поля сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только модельные пины.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 041 только модельные пины; алфавиты сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 043 только модельные пины.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 050 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/lyubaja_model_222/ — 054 новая семья, существующие семьи не меняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/lyubaja_model_222/ — 055 новая семья, существующие семьи не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 061 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 068 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 069 только перегенерация изменённых ролей.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только перенос явного назначения.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 222.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/zashchita_main_104/ — 104 только снятые модельные запреты, привязка и отсутствие --sud сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/sud_model_173/ — 105 только ожидания модели, грамматика не ослабляется.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 222.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/sud_model_173/ — 173 только несовместимые ожидания; bare/full и полный провайдер остаются.
ПЕРЕСЕЧЕНИЕ architect: contracts/222-sudja-ljubaja-model.md — 993 только новый контракт 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 222.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 222.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 099 только снятие модельного запрета, остальные отказы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 104 назначение при вызове вместо запрета тира, session/OBJECT сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/judge_gate.sh — 104 только перенос назначения; отказ до append сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 166 только устранение второго модельного пина.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 186 только перенос назначения, L1 и роли автора/сливающего не меняются.

## Проводка

ПРОВОДКА:
- guard=fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh
- role=roles/orchestrator.md «Явное per-call назначение модели для сверки вердикта переноси из запроса task до запуска, не из полученной трассы; источник допустимых selector — config/agent_models.json. Совпадение модели с автором не причина отказа.»

ПРОВОДКА-ЭНФОРСМЕНТ: существующая дверь сохраняется; guard потребляется приёмкой и шагом check:lyubaja-model-222-family-selftest. До реализации CI вызывает --stabs, после ленда оркестратор переключает на --repo .; gen_ci_steps.sh --write и --check материализуют только свою строку. Новые секреты/variables/environments не нужны.

## Приёмочный критерий

1. Дано: дерево ДО реализации; когда `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --repo .`; тогда rc 1, именованные KRASNO по каждому несовместимому входу, а не один отказ на всё семейство. После реализации та же команда — rc 0, KRASNYH 0; список всех клеток задаёт код пробы.
2. Дано: честный reference; когда `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model`; тогда rc 0, KRASNYH 0. Это контроль достижимости, не требование побайтно переносить reference в production.
3. Дано: реестр обманных изменений; когда `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --stabs`; тогда rc 0, ZHIVYH 0; каждая запись предъявлена каждому своему входу. Негодный якорь/синтаксис — rc 2, не доказательство красноты.
4. Правило: bash проверяются bash -n и pinned shellcheck через validate_std, TypeScript — native node --check, Python — ast; команда `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --sintaksis` — rc 0. Нет зависимостей/источника/таймаут — rc 2 NOT_IMPLEMENTED, не product-failure.
5. Правило: реестр непуст, имена уникальны, адреса входов существуют; `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --catalog` — rc 0. Числа берутся из вывода, их нет в критерии как второго списка.
6. Правило: `bash scripts/pre_critic.sh contracts/222-sudja-ljubaja-model.md` и `bash scripts/check_sdacha.sh . contracts/222-sudja-ljubaja-model.md --run` — rc 0. До owner-ленда строки плана допустим только её дословный именованный отказ; plan.tsv не чинится этой пачкой.
7. Дано: реализация; когда пересобраны производные и выполнен `npm run gen:harness -- --check`; тогда rc 0. Для 104/173 и fork_route обновлены только противоречащие Н-458 ожидания, а привязка, bare/full-сверка, fail-closed и свидетельство автора остаются. Проводка выполнена отдельным коммитом orchestrator; суд рисковой реализации — adversary, затем reviewer на одном OBJECT.

## Модель угроз

ЗАЩИЩАЕТ:
- От второго списка допустимых моделей по роли/тиру/семейству/провайдеру и от запрета одинаковых моделей независимых акторов: предметные положительные входы и единый конфиг, без modelPolicy-флага.
- От подмены назначения фактом, чужой сессии/OBJECT, отсутствия свидетельства и пропуска второй строки: буквальные сверки существующей двери, отказ до verdict-append и контроль полных байтов журнала.
- От тихого дефолта типа агента, отсутствия/поломки установленного конфига и устаревшего generated назначения: настоящий хук, resolver и generator, не их двойники.

НЕ ЗАЩИЩАЕТ:
- От компрометации установки, доверенного запроса назначения или JSONL вне дерева; это граница доверия 028/104. Текстовый --assigned-model не аутентифицирует сам себя: источник запроса и trace сверяет оркестратор по существующему протоколу, а не проверяемый агент. Ловцы — суд и trace-протокол, не новая система подписи.
- От недоступной модели, реальной квоты, неизвестных upstream-возможностей или изменения omp wire API: батарея не делает платных модельных запросов. Реальный workshop доведён до exec, внешний omp в argv-клетках — только регистратор argv по существующему стенду 209; реальный tool_call-handler вызван на шве 104 без предметной двери 140. Ловец живого runtime — станционный pre-land прогон 129 и проверка фактической трассы первого запуска оркестратором.
- От самосуда одного актора, выдающего себя за разные роли, и от ложного суждения модели: запрет самосуда остаётся в ролях (cognitive-only), модельный fingerprint не удостоверение личности. Ловцы — независимый reviewer, доверенная история сессий и автора, прежние зоны/OBJECT/бюджеты; новый identity-механизм не вводится.
- От произвольной вредоносной программы, редактирующей проверку/оракул, либо от доказательства всех возможных selector конечной батареей: ожидания в памяти, проверяется описанная конформная область и адресные мутации. Остаток ловят critic/adversary, не обещание универсальной верификации кода.

## Предпосылки

ПРЕДПОСЫЛКИ:
- setting bash, Python3, node с native TypeScript, git, jq и pinned shellcheck доступны; новые CI secrets/variables/environments/settings не вводятся. CI-реестр и workflow меняет orchestrator только для своей батареи.
- setting Адресные разрешения владельца на перечисленные role-файлы должны сопровождать реализационные коммиты; эта пачка их не выдумывает. Уставной AGENTS.md не правится.

## Незаполненные требования:
- Перед изменением защищённых ролей оркестратор получает/передаёт адресные строки разрешения владельца; приведённые слова о выборе модели не подделываются под выданную строку коммита.
- Строка плана 222 поступает owner-PR, не из architect-зоны; предпосылка не заменяется обходом ворот.
