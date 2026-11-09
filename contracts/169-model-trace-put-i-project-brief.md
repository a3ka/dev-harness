# Контракт 169 — путь трассы модели и проектный бриф

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — уточняется диагноз ошибочного аргумента и подсказка запуска, не меняются права, авторизация, деньги, ПД/health либо юридически значимые действия.
КОНТЕКСТ: слово владельца 2026-11-08: перед продолжением 158 отделить строку модели от пути `--model-trace`, оставить старый диагноз лишь при полном отсутствии трассы, использовать проектный fallback и показать оба способа в шаге 0 оркестратора. `id/CONTRACT/169` и строка `registry/contracts.tsv` уже выданы на origin/main; настоящий черновик — вместо ожидаемого до начала работы отказа двери «черновик контракта не найден: 169».

## Существующее

- `scripts/make_task.sh:119–134,249–275` уже разбирает `--model-trace`, получает эффективный `<registry>` через `project_paths_resolve` из `scripts/next_id.sh`, берёт `<registry>/trace.tsv` только без явного аргумента и парсит роль/модель/allowed|denied; общий тест отсутствия файла в :268 сейчас сводит два разных входа к `ОТКАЗ: нет свидетельства модели: orchestrator`. Именно этот общий диагноз меняется; поиск роли и грамматика строк остаются.
- `scripts/connect_project.sh:255–260` уже сеет `trace.tsv` из конфигурации установки, но это отдельная дверь и не переносит путь из модели при вызове `make_task`. `contracts/095-profil-i-vhod-agenta-contextpack.md` и `fixtures/context_pack_095/red_svidetelstvo_modeli.sh` закрепили прежний отказ без свидетеля; `contracts/136-dovodka-sessij-proektov.md` и `scripts/make_task.sh:256–267` добавили проектный fallback. Новый диагноз уточняет 095 только для **заданного не-файла**; отсутствие любого источника сохраняет 095 дословно, 136 разрешение пути не переписывается.
- `roles/orchestrator.md:19` в шаге 0 предлагает `--model-trace <trace>` без сообщения, что это путь и что проектный реестр допускает отсутствие аргумента. `npm run gen:harness` создаёт `.omp/agents/orchestrator.md` из этой роли; редактировать только источник и регенерировать выход после реализации.
- `registry/plan.tsv` не объявляет самостоятельную реализацию этого уточнения; 169 стоит перед продолжением 158. Поиск по `contracts/`, `scripts/`, `fixtures/`, `registry/plan.tsv` и веткам `wip/169/*`, списку PR на момент черновика не показал другого незавершённого решения 169. Уже существующая модель `fixtures/context_pack_095/_toy.sh` создаёт двухслойный проектный профиль; в этой пачке она используется с настоящим `ci.yml`, чтобы ранний резолвер 136 видел объявленный workflow. PR для 169 пока нет.

## Предмет и граница

`make_task.sh` различает **явный** `--model-trace` и незаданный. Явный аргумент, не указывающий на обычный файл (включая строку `openai-codex/gpt-5.6-terra`), получает rc 1 со stderr, состоящим ровно из строки `ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv`; stdout пуст, подложенный `<registry>/trace.tsv` не маскирует неверный явный аргумент. В проектном корне без аргумента существующий `<registry>/trace.tsv` остаётся источником трассы, `--kind brief --role orchestrator` выдаёт rc 0 и TRACE-строку из него. Если трассы нет ни по явному аргументу (он отсутствует), ни по проектному fallback, остаётся `ОТКАЗ: нет свидетельства модели: orchestrator` rc 1. В шаге 0 `roles/orchestrator.md` указаны `--model-trace <путь к TSV>` и проектный fallback `<registry>/trace.tsv`; генерируемый `.omp/agents/orchestrator.md` синхронизируется генератором.

Не менять выбор модели, allowed|denied и TSV-грамматику 095, механизм разрешения `<registry>` 103/136/996, `connect_project.sh`, `models_actual.sh`, реестр моделей, правила judge, старые frozen-контракты, чужие клетки. Публичный шов — CLI `bash scripts/make_task.sh --repo R --role orchestrator --kind brief [--model-trace F]` и шаг 0 роли. Конформны существующий двухслойный профиль проекта с объявленным `ci.yml`, TSV-строка `orchestrator<TAB>openai-codex/gpt-6-sol<TAB>allowed`, отсутствующий путь, отсутствие обоих источников; значения моделей не распознаются по префиксу. Валидный контрпример — инвариантен к конкретной модели/имени файла и расходится на таком конформном входе, не на битом профиле.

## Приёмочный критерий

- Дано: текущий код с конформным проектным профилем и `<registry>/trace.tsv`; когда `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --repo`; тогда rc 1 и самостоятельные `explicit_model_string KRASNO`, `explicit_missing_path KRASNO`, `orchestrator_step_0 KRASNO`; проектный контроль `project_no_arg ok` и отсутствие источника `no_trace_anywhere ok` не могут заменить их красноту.
- `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --repo` → красная: 169 explicit_model_string KRASNO
- Дано: честный контроль (та же CLI-дверь с узким исправленным диагнозом и действующей ранней 136-раздачей пути); когда `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model`; тогда rc 0, все четыре независимых CLI-входа и шаг 0 зелёные. Дано: порчи ответов и предиката fallback; когда `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --stabs`; тогда rc 0 с `STAB ... caught` для каждого различающего входа, нет `STAB ... ZHIV`; адреса мутант→вход закреплены **только кодом** `probe.py` (Н-39), не текстом контракта.
- Дано: реализованная дверь и роль. Когда `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh` (CI-шаг), тогда rc 0: модельная строка с явным `--model-trace` → rc 1 **точный stderr**, непустой проектный `<registry>/trace.tsv` + brief без флага → rc 0 и самостоятельная TRACE-строка, оба источника отсутствуют → старый rc 1 и старый stderr; `roles/orchestrator.md` шаг 0 содержит форму пути и fallback. Отдельные старые контроли `bash fixtures/context_pack_095/red_svidetelstvo_modeli.sh` и `bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model` сохраняют rc 0 без переписывания их фикстур.
- До суда: `bash scripts/pre_critic.sh --repo . contracts/169-model-trace-put-i-project-brief.md` → rc 0. Перед done: `bash scripts/check_provodka.sh . contracts/169-model-trace-put-i-project-brief.md` → rc 0; в проекте с `harness.project.json` также `bash scripts/check_project_sources.sh --stage done` → rc 0.

## Зоны и проводка

ЗОНА architect: contracts/169-model-trace-put-i-project-brief.md fixtures/workshop_project/model_trace_169/
ЗОНА implementer: scripts/make_task.sh roles/orchestrator.md .omp/agents/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только диагноз для явного не-файла; отсутствие свидетеля и грамматика TSV прежние.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 103 профильные пути 103 без изменений.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 136 проектный fallback 136 без изменений.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 161 внешнее состояние проекта без изменений.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 165 материализация вердикта без изменений.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 166 выбор модели без изменений.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 996 резолвер пути без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только шаг 0, топология ролей без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 072 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 074 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 094 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 099 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 140 только шаг 0, чужие нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 012 только шаг 0, изоляция прогонов без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 только шаг 0, прочий контекстный пак без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 104 только шаг 0, судейские назначения без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 124 только шаг 0, push продукта без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 166 только шаг 0, модельный выбор без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 167 только шаг 0, судейское восстановление без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 998 только шаг 0, назначения моделей без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 002 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 003 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 005 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 010 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 166 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 167 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 998 только генерация изменённого шага 0.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 169; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 169; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 169; чужие строки не меняются.
После ленда оркестратор записывает собственную строку `step` 169 в `registry/ci-steps.tsv`, её замер в `registry/ci-zamery.tsv` и генерирует `.github/workflows/ci.yml`; команда строки — `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh`. До подключения CI guard-канала done невозможен.
ПРЕДПОСЫЛКИ:
- setting Существующий CI харнесса предоставляет Python 3, git, bash и jq для toy-проекта 095; шаг 169 исполняет красную семью без новых secrets, variables, environments либо настроек репозитория. Оркестратор регистрирует CI-строку и замер через `gen_ci_steps.sh --write`, затем `--check` rc 0.

ПРОВОДКА:
- role=roles/orchestrator.md «0. `bash scripts/make_task.sh --repo <root> --role orchestrator --kind brief --model-trace <путь к TSV>` (095 Р1+12; 169): в проектном корне при наличии `<registry>/trace.tsv` аргумент можно опустить; отказ — стоп, не имитация брефа. Пак: MAP/RULES/BUDGET, ЦЕЛЬ/plan.tsv/РАБОТА/РЕШЕНИЯ/ЗДОРОВЬЕ.»
- guard=scripts/make_task.sh

## Модель угроз

ЗАЩИЩАЕТ:
- Строка модели не принимается за путь к TSV; явный ошибочный аргумент не скрывается проектным fallback.
- При реальной трассе проектный бриф использует существующий TSV, отсутствие трассы продолжает отказывать прежним диагнозом.
НЕ ЗАЩИЩАЕТ:
- Происхождение/аутентичность самой трассы и конфигурации установки: границы 104/136, здесь только ошибка явного аргумента.

## Незаполненные требования:
нет
