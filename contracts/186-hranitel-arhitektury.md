# Контракт 186 — В6: хранитель архитектуры

КЛАСС ЗАДАЧИ: смешанный — постоянная роль, маршрутизация модели и событий, красная батарея.
КЛАСС РИСКА: обычный — хранитель не утверждает снимок, не меняет код и не судит предметы; защищённые архитектурные решения остаются у владельца.
КОНТЕКСТ: Fable-11 `ARCH-IN-WORKFLOW-SPEC.md` §1–§8 (принято владельцем 2026-11-09), слово владельца 2026-11-10 ~19:45 UTC «переписать эту роль» и «перевести его на Сол модель». Измеренная боль §0/§8: 69 DRAFT-операций, незакрытые находки, нет постоянного принимающего; один обзор после каждого Э-этапа и срочный обзор при блокирующей находке, а не календарная отчётность. Расхождение §8.1/§7 (Astra/plan/@fable) разрешено позднейшим прямым словом владельца: Sol/@gpt-sol, fallback @gpt-astra, отдельный тир, не менять `plan` арбитра.

## Существующее

- Бриф 170 (`contracts/170-arch-component-brief-vhod-zadanija.md`, `scripts/make_task.sh --arch-component`) даёт описание компонента; 187 отвечает за входы всех ролей, шестой вопрос critic и `СВЕРКА-АРХИТЕКТУРЫ:` reviewer, а также за двери В4/В5. 186 не вводит нормы остальных ролей и не заставляет freeze/done ждать хранителя.
- Прецедент `roles/steward.md` отвечает readonly; `roles/architect.md` пишет клетку и L1 своего предмета. `scripts/roles.ts`, `scripts/gen-harness.ts`, `config/agent_models.json` (`models.gpt-sol=openai-codex/gpt-6-sol`, `models.gpt-astra=openai-codex/gpt-6-astra`, `tiers.plan`, `roles`, `routing.rules`) дают единый источник роли/модели и производные `.omp/agents/`, `.omp/config.yml`. Судейский `check_sud_model.sh --frontmatter` охватывает только судей и не расширяется для хранителя.
- Станционный `ops/server/root/orch-peak`, systemd timer, `ops/server/install.sh`, `ORCH_PEAK_TEST` уже доставляют сигнал в ведущую панель; timer допустим только как страховка пропущенных событий. Проектная истина — `CompliorOS-architecture/governance/findings/` и `governance/review/` (поправка README к спецификации: НЕ `architecture/findings/` или `architecture/reviews/`, фигурирующие в тексте §8); модель — в `Complior-back/architecture/`, в харнессе нет зеркала данных продукта. Существующий `ROADMAP.md` задаёт порядок этапов, приоритет реестра из модели определяется проектным ROADMAP.

## Предмет и последовательность

Хранитель `architecture-steward` — именованный постоянный субагент, вызванный оркестратором после `done` ПОСЛЕДНЕГО предмета КАЖДОГО Э-этапа и немедленно при блокирующей архитектурной находке. Повторяющийся timer станции только страховочный: сообщение не выдаёт себя за слово владельца и не становится первичным триггером. Оркестратор сохраняет ожидающий вызов при занятом слоте. Конкретные строки оркестратора/агентов, которые вызывают хранителя и подают findings, — предмет 187; 186 обеспечивает принимающую роль и событийный интерфейс станции. Ни один freeze/done не ждёт подписи хранителя.

1. **Непрерывный приём.** Любая роль или человек может внести файл в `CompliorOS-architecture/governance/findings/`; грамматика шести полей §8.3: `Компонент/ресурс`, `Наблюдение` с доказательством, `Ожидание модели`, `Предлагаемый уровень`, `Автор`, `Статус`. Предварительный уровень проверяется `check --base`, окончательный не выбирается именем автора. Хранитель разбирает находки при обзоре; статусы: `принята L1` / `принята L2` / `принята L3` / `отклонена: <причина>` / `вопрос владельцу`. `python3 scripts/findings_status.py <корень-CompliorOS-architecture> <git-ref-предыдущего-среза>` читает через `git ls-tree` файлы, уже существовавшие на предыдущем срезе: для незакрытого файла без статуса печатает `ПРОСРОЧЕНО: governance/findings/<имя>` (строку включить в обзор) и rc 1; новый файл не объявляет просроченным. Роль не выдаёт rc 1 за успешную проверку среза.
2. **Обзор среза.** Один коммит обзора в `CompliorOS-architecture/governance/review/` на каждый срез: diff модели, `arch:conform` на main, закрытые/отклонённые находки, L2-пачка на снимок, актуальный DRAFT-реестр; при нуле находок — одна строка, но не отсутствие обзора. Срочный блокирующий сигнал не ждёт `done`/понедельника. Сверка Word/3.17/4.1 с моделью при архитектурном слове владельца записывается в DECISIONS.md и дельту.
3. **Реестр.** Из `check --base` → `contractReadiness.unresolved` строится реестр DRAFT-операций и отсутствующих контрактов; хранитель расставляет каждому компоненту/операции приоритет согласно проектному ROADMAP: какой предмет закрывает, какой Э-этап требует, срок `до контракта X`. Генерируемые данные не переписываются вручную; устаревший реестр против `check` красный в проектном CI. В7 схемы операций впрок — L1 до контракта, которому они необходимы; DRAFT не выдают за готовую схему.
4. **Маршрут решений.** L1 правит хранитель вне предмета либо architect внутри своего PR: адресная дельта модели `arch(L1)`, `check --base` PASS, `--strict-new-ops`, шестой вопрос critic, затем слияние. L2 хранитель собирает пачкой к концу среза: `arch/l2-<Э>`, `diff`, вердикт critic, одна страница предложения снимка владельцу; только владелец утверждает снимок и digest. L3 — один вопрос в одном файле с рекомендацией владельцу; его решение и снимок публикует владелец. Спор по инженерному L1/L2 — арбитр, по воле/L3 — владелец. Critic не заменяется хранителем; объявленное «всегда другая модель» из §8.4 сверяется по фактической модели автора и critic согласно текущему реестру, при совпадении — остановка и маршрут независимого судьи, не тихое одобрение.
5. **Выход в код.** Если находка требует кода или долг предмета, хранитель передаёт её проектному оркестратору как предмет/B-DEBT с доказательством и приоритетом; код и вердикты за хранителем не закреплены. Артефакты идут в проектный workflow (`governance/findings/`, `governance/review/`), не в `fixtures/` и не в `architecture/` как каталог находок. Хранитель не правит L2/L3 под видом L1.
6. **Маршрут модели.** `config/agent_models.json`: новый `tiers.steward-arch.model="@gpt-sol"`, `fallback="@gpt-astra"`, `roles["architecture-steward"]="steward-arch"`; `routing.rules` привязывает приём и обзор архитектуры к этой роли. `npm run gen:harness` генерирует `.omp/agents/architecture-steward.md` (`model: ["@steward-arch"]`) и `.omp/config.yml`; `npm run gen:harness -- --check` rc 0. `tiers.plan` и назначения остальных ролей неизменны; Sol хранителя не разрешает ему судить свои дельты.

Конформная проба: независимый Git toy с настоящими parser/generator и station action, неизменным `ORCH_PEAK_TEST`, шестипольными findings и парой срезов. Расхождение — только на конформном входе и инвариантно к temp-пути/OID; кандидату не навязывается внутренний текст программ, но публичные поля, секции роли и фактический сигнал должны различать событие от календарной страховки. Ожидания снимаются в память до запуска субъекта, после — сверяются по структуре поля/строки; ошибка окружения не считается красной находкой.

## Приёмка

- Дано: реализация с событием done последнего предмета Э-этапа и отдельно блокирующей находкой; когда `python3 fixtures/workshop_project/architecture_steward_186/probe.py --repo .`; тогда rc 0 по независимым клеткам `done`, `blocker` с живым сигналом `ORCH_PEAK_TEST`. Дано: только timer без этих сигналов; `--stabs` → rc 0, стабы `calendar_only` пойманы конкретной клеткой; при занятом слоте сообщение остаётся в очереди.
- Дано: конформные шестипольные файлы от роли и человека, незакрытый файл между двумя срезами; когда та же батарея `--repo .`; тогда `intake` и `status_cli` rc 0 только при том, что статусная проверка печатает имя просроченного файла с rc 1, а после установки статуса даёт rc 0 без просрочки; свежий незакрытый файл не выдаётся за просроченный. Дано: принимаются только люди / просрочка пропущена; `--stabs` → rc 0, `humans_only` пойман `intake`, `silent_overdue` пойман `status_cli`.
- Дано: находки L1/L2/L3, исправление требует кода; когда `--repo .`; тогда `l1`, `l2`, `l3`, `code_debt` rc 0: PR+critic+слияние, пачка+critic+снимок владельца, отдельный файл с рекомендацией, B-DEBT к оркестратору и отсутствие кода/вердикта хранителя. Дано: L3 без рекомендации или хранитель пишет код/судит; `--stabs` → rc 0, `l3_no_recommendation` пойман `l3`, `writes_code_or_judges` пойман `code_debt`.
- Дано: unresolved операции и ROADMAP; когда `--repo .`; тогда `register` rc 0, строки содержат предмет, приоритет и срок `до контракта X`; `--stabs` → rc 0, `no_roadmap_priority` пойман `register`. Дано: роль назначена Sol/fallback Astra, route согласован и генерация актуальна; `--repo .` → rc 0 по `routing`, `tier`, `fallback`, `generated`; `--stabs` ловит `plan_astra`, `wrong_fallback`, `no_role_map`, `stale_generated` каждым своим входом.
- Дано: честный независимый toy; `python3 fixtures/workshop_project/architecture_steward_186/probe.py --model` → rc 0 по каждой клетке. Дано: каждый именованный стаб; `python3 fixtures/workshop_project/architecture_steward_186/probe.py --stabs` → rc 0, каждый `caught @ <свой case>`, ни одного `ZHIV`. До суда последовательно `bash scripts/pre_critic.sh contracts/186-hranitel-arhitektury.md` → rc 0; до done `bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md` → rc 0. Orchestrator подключает в CI `--model`, `--stabs`, `--repo .`.

## Зоны и проводка

ЗОНА architect: contracts/186-hranitel-arhitektury.md fixtures/workshop_project/architecture_steward_186/
ЗОНА implementer: roles/architecture-steward.md config/agent_models.json .omp/agents/architecture-steward.md .omp/config.yml scripts/findings_status.py ops/server/root/systemd/orch-architecture.timer ops/server/root/orch-peak ops/server/install.sh ops/server/README.md roles/orchestrator.md .omp/agents/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
Граница пересечения: 029/998/165/166 сохраняют назначения существующих ролей; новый tier+route только хранителю. Пересборка `.omp/config.yml` сохраняет task/isolation; station оставляет существующие actions/install; роль orchestrator меняет только событийный сигнал, смежные нормы 187 не переносятся сюда. Специальную санкцию на уставную правку роли даёт только владелец; architect не пишет `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`.
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
- role=roles/architecture-steward.md «Принимай находки непрерывно; обзор после done каждого Э-этапа и немедленно при блокирующей находке. L1 — PR и critic; L2 — пачка и снимок владельца; L3 — один файл с рекомендацией владельцу. Код и суд предмета передавай оркестратору; находки и обзор веди в governance/findings/ и governance/review/.»
- role=roles/orchestrator.md «После done последнего предмета Э-этапа или при блокирующей архитектурной находке вызови architecture-steward; недельный сигнал только страховка. Передай кодовый долг предметом/B-DEBT, не требуй подписи хранителя для freeze/done.»

## Модель угроз

ЗАЩИЩАЕТ:
- От календарной подмены событийного обзора: отдельные пробы done/blocker и живой сигнал; от просроченных находок — статусная проверка и отчёт.
- От подмены Sol моделью планового арбитра, пропуска DRAFT и самосуда: независимые клетки route/tier, register, L1/L2/L3 и граница полномочий.
НЕ ЗАЩИЩАЕТ:
- От семантической ошибки самой модели в реальном проекте: суд critic, архитектурный reviewer и акт владельца остаются отдельными; текстовая проба нормы не доказывает реальный коммит в чужой проект.
- От недоступности станции/проекта: сигнал может отказать, оператор сверяет журнал; контракт 187 подаёт находки и вызывает роль из других ролей.

ПРЕДПОСЫЛКИ:
- setting Нужны bash, python3, git, node/npm и `ORCH_PEAK_TEST` станции; новых CI secrets/variables/environments не требуется. Проектный workflow и каталоги CompliorOS-architecture доступны роли, но проектные файлы не записываются в харнесс.
