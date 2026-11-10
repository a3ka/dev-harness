# Контракт 182 — актуальный срез «где мы по плану» после перезапуска

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — вывод состояния плана; права, авторизация, деньги, ПД/health-данные и юридически значимые действия не меняются.
КОНТЕКСТ: `NABLIUDENIA.md` Н-439 (полная запись) и Н-440 — после трёх перезагрузок исчез /tmp, HANDOFF отставал от origin/main, владельцу доложили устаревшие «ЖДЁТ УТРА» вместо ROADMAP. Слово владельца 10.11.2026 ~13:28 UTC: «сделай так, чтобы такое больше не повторилось». Н-47 запрещает оправдывать предмет без боли; Н-52 требует сырого свидетельства.
КОНТЕКСТ: `contracts/095-*` и `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` — действующее frozen-обязательство brief: активный контракт без `## Предмет` даёт rc 1 и дословный отказ. Контракт 154 демонстрирует этот отказ; здесь он сохраняется.

## Существующее

- `registry/plan.tsv` — закоммиченные id/пара/этап/зависимость/источник/трек; `ROADMAP.md` §11 `<!-- BEGIN GENERATED PLAN -->` — производный порядок из того же TSV; `registry/pauzy.tsv` — санкционированные паузы. `registry/contracts.tsv` закрепляет выданные номера; теги `frozen/contracts/N/v`, `done/contracts/N/v` дают вехи. Строка 182 в plan.tsv — ЖДЁТ: консультант (owner-коммит); architect её не пишет. У плановых безномерных вех нет id-тега и записи contracts.tsv. Расхождение TSV и ROADMAP — отказ, не догадка по HANDOFF.
- `scripts/make_task.sh:779–815` строит GOAL из рабочего plan.tsv, WORK из контрактов, HEALTH из рабочего дерева; на активном 154 без `## Предмет` отказывает по frozen 095 И-12. `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` требует rc 1, дословный отказ и пустой stdout. Этот контракт не меняет brief, task, манифест или старую клетку 095.
- `ops/server/user/orch-tablo` читает origin/main и теги, но зависит от живых журналов, gh и временного окна, показывает СТОИТ/ЖДЁТ CI, не связывает строку с волной ROADMAP; подмена им среза не закрывает Н-439. `scripts/orch_restart.sh` проверяет чистый HEAD==origin/main и HANDOFF-чекпойнт перед плановым рестартом, но не лечит аварийную перезагрузку с исчезнувшим /tmp. `scripts/orch_status.sh` и `scripts/orch_checkpoint.sh` в дереве не найдены — новый срез живёт в отдельном CLI без изменения frozen-дверей.
- `roles/orchestrator.md` п.0 вызывает brief и останавливается при его отказе, п.1 читает HANDOFF. Новая role-норма предписывает после успешного brief и до отчёта владельцу самостоятельно вызывать срез из опубликованного дерева; если brief отказывает на 154, его нельзя имитировать или обходить. HANDOFF остаётся историей решений, не оракулом текущих статусов. Открытые wip-ветки и PR не являются закоммиченным источником на origin/main.

## Frontier и решение

1. **Выбрано: независимый CLI-срез из published origin/main + role-потребитель.** Новый `scripts/orch_plan_slice.sh --repo R` возвращает доказуемый SHA `origin/main`, строки по каждому id плана в порядке plan.tsv, волну/этап из совпадающего ROADMAP, состояние из опубликованных тегов и пауз и ограниченный следующий шаг. Роль вызывает CLI после успешного штатного brief и до доверия HANDOFF. Новая команда не переписывает frozen 095; при его отказе стартап по-прежнему останавливается до отдельной санкционированной миграции.
2. Альтернатива: дописывать очередной HANDOFF-чекпойнт и считать первую секцию актуальной. Отвергнуто: после 11:18 незалендившийся PR #692 и очищенный /tmp воспроизвели ложный чекпойнт; без механизма происхождения потеря снова выйдет владельцу.
3. Альтернатива: запускать только orch-tablo/gh после рестарта. Отвергнуто: окно логов и открытый PR не задают этап ROADMAP; дополнительные сетевые источники превращают отсутствие ответа gh в ложный статус.

## ВНЕ ОБЪЁМА 182

Часть Н-439(2) «бреф-дверь не умирает от одного контракта» — отдельный будущий предмет «095 v+1: строка-маркер вместо отказа». Он требует v+1 frozen 095 и прямого разрешения владельца по правилу 11/ШАГ 8 `AGENTS.md` с новой приёмкой 095. В 182 ни brief-код, ни клетка `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh`, ни frozen 095 не изменяются; остановка стартапа на 154 остаётся известным ограничением до этого отдельного решения. Поведение frozen 095 не пересматривается этим контрактом.

## Предмет и инварианты

Один результат: независимый CLI показывает «где мы по плану» из опубликованного `origin/main` до доклада владельцу; роль применяет его после успешного штатного брифа, без старых ожиданий HANDOFF.

1. Вход `scripts/orch_plan_slice.sh --repo <абсолютный R>`; stdout сначала самостоятельная строка `PLAN_SNAPSHOT: origin/main=<полный SHA>`, далее по одной `PLAN: <id> | ROADMAP=<пара>/<этап> | STATUS=<...> | NEXT=<...>` на каждую строку плана, в порядке plan.tsv. Все источники таблицы и паузы читаются через `git show <снятый sha>:<путь>`, не из рабочего дерева или HANDOFF. Поля id/пара/этап/трек/зависит должны совпасть с одноимённой строкой generated-блока ROADMAP; для числового id требуется запись registry/contracts.tsv на том же SHA. Отсутствие обязательного источника/расхождение — rc 1 `PLAN_SOURCE_UNAVAILABLE`/`PLAN_ROADMAP_RASHOZHDENIE`, ни одной вводящей в заблуждение строки stdout.
2. Статус приоритетом done > ПАУЗА > frozen > черновик: опубликованный remote `done/contracts/<id>/<v>` → NEXT=закрыто; строка паузы из origin/main → NEXT=буквально условие возврата; remote frozen → NEXT=сверить PR/вердикт, затем done; иначе NEXT=контракт → critic → freeze. Тег, существующий только локально или указывающий вне истории origin/main, не подтверждает статус. Следующий шаг описывает границу известного, а не выдаёт неподтверждённую реализацию/PR за done. Для двух последних статусов следующая проверка конкретна и не зависит от старого /tmp. Пауза не превращается в разрешение на возврат сама собой.
3. Строка «ЖДЁТ …» из HANDOFF не становится строкой среза. Единственный маркер ожидания, допустимый в выдаче, — санкционированная ПАУЗА с полным источником из pauzy.tsv; старый HANDOFF читается после нового среза как архив состояния, а в отчёте владельцу утверждения «ЖДЁТ …» допускаются лишь при живой подтверждающей ссылке; неустановленное состояние сообщается как неизвестное. `roles/orchestrator.md` обновляется role-каналом: успешный brief → CLI-срез → HANDOFF, с сохранением остановки при отказе brief.
4. Конформный вход CLI: git-репозиторий с `origin/main`, опубликованным remote, корректными шестипольными plan/ROADMAP, реестром выдачи и пауз; remote-теги разрешаются к предку `origin/main`. Контрпример валиден при независимой замене номеров, текстов этапа/условия и путей, если структура источников сохраняется; расхождение на конформном входе, а не неподключённый remote. Оракул — снятый в память SHA и независимые ожидаемые строки до запуска субъекта; точное совпадение самостоятельных строк, не substring. Структурные ошибки — именованный отказ, не зелёный пустой срез.

## Приёмочный критерий

- Дано: рабочий R с устаревшим HANDOFF, грязными локальными планом/ROADMAP, локальным невыпущенным done-тегом и опубликованными frozen/done-тегами; когда `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --model`; тогда rc 0, именованные зелёные строки с published SHA, этапом, paused/frozen/done и NEXT, без ЖДЁТ УТРА. Парное отрицательное: тот же R с субъектом без 182, `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .` → rc 1 с именованными RED; после реализации → rc 0 с тем же структурным выводом. Без аргументов — тот же --repo .
- Дано: закоммиченный plan.tsv расходится с generated-блоком ROADMAP на origin/main; когда тот же `--model` / `--repo .` запускает CLI на этом мире; тогда CLI rc 1 `PLAN_ROADMAP_RASHOZHDENIE`, stdout пуст, батарея rc 0 после реализации; положительная пара с опубликованным согласованным планом входит в предыдущую строку.
- Дано: независимые обманные варианты модели; когда `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --stabs`; тогда rc 0, `STABS=4 CAUGHT=4`, ни одного ZHIV; связи каждый ↔ его наблюдаемая клетка заданы в коде проб, не договором. `--model` на тех же мирах остаётся rc 0.
- Дано: готовый предмет; когда `bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` без изменения frozen 095 и `bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .`; тогда rc 0; `bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md` до суда → rc 0. На живом origin/main запуск CLI после реализации обязателен для проверки фактического среза; toy-проба не утверждает статус реального PR.

## Модель угроз

ЗАЩИЩАЕТ:
- От тихого повторного использования старого HANDOFF и исчезнувшего /tmp: точный origin/main SHA и отказ расхождения источников не превращают локальный draft в published.
- От локально поставленного done-тега и ложной волны: модель и отдельные обманные прогоны проверяют эффект на публичном CLI.

НЕ ЗАЩИЩАЕТ:
- От задержки получения нового origin/main из сети до запуска: срез сообщает SHA локального remote-tracking ref, запуск fetch до CLI — обязанность существующего процесса синхронизации. Не выдаёт текущее состояние несмёрженного PR за published; при отказе frozen 095 бриф-дверь по-прежнему не даёт продолжить старт.
- От намеренно ложной записи owner-плана на origin/main: разделение полномочий owner для plan/pauzy и проверки публикации остаётся действующим.

## Зоны и проводка

ЗОНА architect: contracts/182-plan-posle-perezapuska.md fixtures/workshop_project/plan_restart_182/
ЗОНА implementer: scripts/orch_plan_slice.sh roles/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 только вставка вызова независимого CLI после успешного пункта 0, запрет имитации/обхода брифа сохраняется.
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
- role=roles/orchestrator.md «После успешного штатного brief до чтения HANDOFF запусти orch_plan_slice.sh --repo <root>, сверяй PLAN_SNAPSHOT с origin/main; при отказе brief не обходи дверь; строки ЖДЁТ из HANDOFF без живого подтверждения не сообщай как актуальные.»

## Незаполненные требования:
нет
