# Контракт 182 — актуальный срез «где мы по плану» после перезапуска

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — вывод состояния плана и брифинга; права, авторизация, деньги, ПД/health-данные и юридически значимые действия не меняются.
КОНТЕКСТ: `NABLIUDENIA.md` Н-439 (полная запись) и Н-440 — после трёх перезагрузок исчез /tmp, HANDOFF отставал от origin/main, бриф отказал на 154 без §Предмет, владельцу доложили устаревшие «ЖДЁТ УТРА» вместо ROADMAP. Слово владельца 10.11.2026 ~13:28 UTC: «сделай так, чтобы такое больше не повторилось». Н-47 запрещает оправдывать предмет без боли; Н-52 требует сырого свидетельства, не самодельной интерпретации оркестратора.
КОНТЕКСТ: `contracts/095-*` и `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` — действующая грамматика брифа (активный без предмета сейчас fatal); контракт 154 без заголовка §Предмет — конформный вход именно нового поведения. §Старт `roles/orchestrator.md` п.0 запускает brief до доклада.

## Существующее

- `registry/plan.tsv` — закоммиченные id/пара/этап/зависимость/источник/трек; `ROADMAP.md` §11 `<!-- BEGIN GENERATED PLAN -->` — производный порядок из того же TSV; `registry/pauzy.tsv` — санкционированные паузы. `registry/contracts.tsv` закрепляет выданные номера; теги `frozen/contracts/N/v`, `done/contracts/N/v` дают вехи. Строка 182 в plan.tsv — ЖДЁТ: консультант (owner-коммит); architect её не пишет. У плановых безномерных вех нет id-тега и записи contracts.tsv. Расхождение TSV и ROADMAP — отказ, не догадка по HANDOFF.
- `scripts/make_task.sh:779–815` строит GOAL из рабочего `plan.tsv`, WORK из контрактов, HEALTH из рабочего дерева; на активном 154 без `## Предмет` выполняет `die` в :801–802 (замороженный 095 И-12 требовал этот отказ). Меняется именно brief-ветвь и её старое ожидание в `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh`; task-режим, профиль проекта, manifest и остальные WORK-строки не теряются. Приёмка 095 семьи после миграции обязательна, несовместимость с frozen 095 открыто обозначена и не маскируется как совместимость: разрешение на новую семантику — предмет 182, до freeze критик проверяет приоритет обязательств.
- `ops/server/user/orch-tablo` читает origin/main и теги, но зависит от живых журналов, gh и временного окна, показывает СТОИТ/ЖДЁТ CI, не связывает строку с волной ROADMAP и не исполняется бриф-дверью; подмена им среза не закрывает Н-439. `scripts/orch_restart.sh` проверяет чистый HEAD==origin/main и HANDOFF-чекпойнт перед плановым рестартом, но не лечит аварийную перезагрузку с исчезнувшим /tmp. `scripts/orch_status.sh` и `scripts/orch_checkpoint.sh` в дереве не найдены — не плодить вторую службу; использовать существующий brief-вход.
- `roles/orchestrator.md` п.0 читает brief первым и затем HANDOFF; новое поле в том же паке делает происхождение среза видимым до чтения старой прозы. HANDOFF остаётся историей решений, не оракулом текущих статусов. `fixtures/context_pack_095/` содержит toy-мир реального профиля, переиспользуется в модели 182. Живые `git branch -a` и `gh pr list -R a3ka/dev-harness --state open` показывают wip-ветки 143/158/175 и открытые PR #701/#697, но ни ветка, ни PR не являются закоммиченным источником на origin/main; срез не выдаёт их за исполненный шаг.

## Frontier и решение

1. **Выбрано: срез из published origin/main внутри штатного brief.** Новый `scripts/orch_plan_slice.sh --repo R` возвращает доказуемый SHA `origin/main`, строки по каждому id плана в порядке plan.tsv, волну/этап из совпадающего ROADMAP, состояние из опубликованных тегов и пауз и ограниченный следующий шаг. `make_task --kind brief` добавляет этот вывод как отдельную секцию до успешной выдачи пака, а на недостающий §Предмет пишет маркер WORK вместо смерти. Цена: отдельный переход для прежнего 095 И-12 и проверка происхождения remote-тегов; именно так закрыты три наблюдаемых отказа Н-439 за один стартап, без нового демона.
2. Альтернатива: дописывать очередной HANDOFF-чекпойнт и считать первую секцию актуальной. Отвергнуто: после 11:18 незалендившийся PR #692 и очищенный /tmp воспроизвели ложный чекпойнт; без механизма происхождения потеря снова выйдет владельцу.
3. Альтернатива: запускать только orch-tablo/gh после рестарта. Отвергнуто: окно логов и открытый PR не задают этап ROADMAP, а неисправная brief-дверь всё ещё умирает от 154; дополнительные сетевые источники превращают отсутствие ответа gh в ложный статус.

## Предмет и инварианты

Один результат: стартовый brief достоверно показывает «где мы по плану» из опубликованного `origin/main` до доклада владельцу, без старых ожиданий HANDOFF и без падения на 154; обычный task-пак сохраняет свою прежнюю семантику.

1. Вход `scripts/orch_plan_slice.sh --repo <абсолютный R>`; stdout сначала самостоятельная строка `PLAN_SNAPSHOT: origin/main=<полный SHA>`, далее по одной `PLAN: <id> | ROADMAP=<пара>/<этап> | STATUS=<...> | NEXT=<...>` на каждую строку плана, в порядке plan.tsv. Все источники таблицы и паузы читаются через `git show <снятый sha>:<путь>`, не из рабочего дерева или HANDOFF. Поля id/пара/этап/трек/зависит должны совпасть с одноимённой строкой generated-блока ROADMAP; для числового id требуется запись registry/contracts.tsv на том же SHA. Отсутствие обязательного источника/расхождение — rc 1 `PLAN_SOURCE_UNAVAILABLE`/`PLAN_ROADMAP_RASHOZHDENIE`, ни одной вводящей в заблуждение строки stdout.
2. Статус приоритетом done > ПАУЗА > frozen > черновик: опубликованный remote `done/contracts/<id>/<v>` → NEXT=закрыто; строка паузы из origin/main → NEXT=буквально условие возврата; remote frozen → NEXT=сверить PR/вердикт, затем done; иначе NEXT=контракт → critic → freeze. Тег, существующий только локально или указывающий вне истории origin/main, не подтверждает статус. Следующий шаг описывает границу известного, а не выдаёт неподтверждённую реализацию/PR за done. Для двух последних статусов следующая проверка конкретна и не зависит от старого /tmp. Пауза не превращается в разрешение на возврат сама собой.
3. Строка «ЖДЁТ …» из HANDOFF не становится строкой среза. Единственный маркер ожидания, допустимый в выдаче, — санкционированная ПАУЗА с полным источником из pauzy.tsv; старый HANDOFF читается после нового среза как архив состояния, а в отчёте владельцу утверждения «ЖДЁТ …» допускаются лишь при живой подтверждающей ссылке; неустановленное состояние сообщается как неизвестное, не как подтверждённый ход. `roles/orchestrator.md` обновляется role-каналом именно на порядок briefing → текущий срез → HANDOFF; это потребитель, не новая дверь.
4. Бриф при плановом контракте без `## Предмет` не прекращается: отдельная WORK-строка `WORK: <id> :: БЕЗ_ПРЕДМЕТА (есть в plan.tsv)` плюс другие WORK/GOAL/HEALTH/новая PLAN_SNAPSHOT в паке, rc 0. Сохранить прежнюю обработку суффикс-заголовка и legacy вне плана; отказ источника плана — rc 1 до печати пака, не ложный зелёный. `--kind task` остаётся без изменений. В brief импортируется ровно stdout общего CLI среза, не вторая реализация разбора.
5. Конформный вход: git-репозиторий с `origin/main`, опубликованным remote, корректными шестипольными plan/ROADMAP, реестром выдачи и пауз; remote-теги разрешаются к предку `origin/main`; brief-world имеет действующий профиль и model-trace по 095. Контрпример валиден при независимой замене номеров, текстов этапа/условия и путей, если структура источников сохраняется; расхождение на конформном входе, а не неподключённый remote или битый профиль. Оракул — снятый в память SHA и независимые ожидаемые строки до запуска субъекта; точное совпадение самостоятельных строк/секции, не substring в чужой секции. Структурные ошибки — именованный отказ, не зелёный пустой срез.

## Приёмочный критерий

- Дано: рабочий R с устаревшим HANDOFF, грязными локальными планом/ROADMAP, локальным невыпущенным done-тегом и опубликованными frozen/done-тегами; когда `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --model`; тогда rc 0, именованные зелёные строки с published SHA, этапом, paused/frozen/done и NEXT, без ЖДЁТ УТРА. Парное отрицательное: тот же R с субъектом без 182, `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .` → rc 1 с именованными RED; после реализации → rc 0 с тем же структурным выводом. Без аргументов — тот же --repo .
- Дано: toy профиль 095, активный 154 без Предмета и выданная трасса; когда тот же `--model` / `--repo .`; тогда rc 0 и точная строка WORK-маркера; до реализации `--repo .` → rc 1 RED brief-marker. Парное отрицательное: 095 с прежним die → ненулевой brief и RED, даже если остальные WORK-строки есть.
- Дано: закоммиченный plan.tsv расходится с generated-блоком ROADMAP на origin/main; когда тот же `--model` / `--repo .`; тогда rc 1 `PLAN_ROADMAP_RASHOZHDENIE`, stdout пуст. Дано: профиль 095 без удалённого origin; когда тот же brief-вызов; тогда rc 1 `PLAN_SOURCE_UNAVAILABLE`, stdout пуст (частичного брифа нет); положительные пары с опубликованным согласованным планом входят в предыдущие строки.
- Дано: независимые обманные варианты модели; когда `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --stabs`; тогда rc 0, `STABS=5 CAUGHT=5`, ни одного ZHIV; связи каждый ↔ его наблюдаемая клетка заданы в коде проб, не договором. `--model` на тех же мирах остаётся rc 0.
- Дано: готовый предмет; когда `bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` с мигрированным ожиданием 095 и `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .`; тогда rc 0; `bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md` до суда → rc 0. На живом origin/main запуск CLI/brief после реализации обязателен для проверки фактического среза; toy-проба не утверждает статус реального PR.

## Модель угроз

ЗАЩИЩАЕТ:
- От тихого повторного использования старого HANDOFF и исчезнувшего /tmp: точный origin/main SHA и отказ расхождения источников не превращают локальный draft в published.
- От локально поставленного done-тега, ложной волны и падения brief на одном неполном активном контракте: модель и отдельные обманные прогоны проверяют эффект на публичных CLI.

НЕ ЗАЩИЩАЕТ:
- От задержки получения нового origin/main из сети до запуска: срез сообщает SHA локального remote-tracking ref, запуск fetch до brief — обязанность существующего процесса синхронизации. Не выдаёт текущее состояние несмёрженного PR за published.
- От намеренно ложной записи owner-плана на origin/main: разделение полномочий owner для plan/pauzy и проверки публикации остаётся действующим.

## Зоны и проводка

ЗОНА architect: contracts/182-plan-posle-perezapuska.md fixtures/workshop_project/plan_restart_182/
ЗОНА implementer: scripts/orch_plan_slice.sh scripts/make_task.sh fixtures/context_pack_095/red_orch_brief_karta_legacy.sh roles/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только brief-ветвь активного контракта без Предмета и секция статуса; task/manifest/arch-component прежние.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/context_pack_095/red_orch_brief_karta_legacy.sh — 095 заменить ровно ожидание active-fatal на active-marker; прочие 095 клетки сохранить.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 только порядок применения нового среза после пункта 0, остальные обязанности неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только новый шаг батареи 182, чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка self-test батареи 182, чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только briefing-срез 182, чужие нормы роли неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 182, чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 182, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 182, чужие замеры неизменны.
ПРЕДПОСЫЛКИ:
- setting Доступ git к опубликованному origin (remote refs/tags) и bash/python3 на станции уже нужны для рабочего брифа; новых secrets/variables/environments не требуется.
- setting CI харнесса запускает Python 3, Bash, git и fixture без внешних сетевых зависимостей: remote игрушечного мира локальный bare; CI-шаг ведёт orchestrator через `gen_ci_steps.sh --write`/`--check`.

ПРОВОДКА:
- guard=scripts/orch_plan_slice.sh
ПРОВОДКА-ЭНФОРСМЕНТ: scripts/orch_plan_slice.sh доказывает опубликованное происхождение и формат; роль несёт отдельно порядок применения среза, устав не меняется.
- role=roles/orchestrator.md «Перед докладом владельцу сверяй PLAN_SNAPSHOT брифа с origin/main; строки ЖДЁТ из HANDOFF без живого подтверждения не сообщай как актуальные.»

## Незаполненные требования:
нет
