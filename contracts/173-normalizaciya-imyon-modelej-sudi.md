# Контракт 173 — нормализация имени модели судьи

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — меняется только сравнение идентификаторов моделей с уже назначенным тиром; роли, права, авторизация, деньги, ПД/health и юридически значимые действия не меняются.
КОНТЕКСТ: фаза 1 пункт 1 из слова владельца 2026-11-09 (`docs/owner/2026-11-09-arhitektura-i-poryadok-stancii.md`, строка 23); номер и строка `registry/plan.tsv` уже в main. Обещание — один фактический ID модели не отклоняется только из-за отсутствующего префикса провайдера. Наблюдение — `check_sud_model.sh --spawn` и `--verdict` возвращают rc 0 для `claude-opus-5-5` при назначении `anthropic/claude-opus-5-5`; иной полный провайдер или иная версия остаются отказом. Frozen 104/2 закрепил роль/тир, привязку сессии/объекта, грамматику пяти полей и разрешённый fallback; 166/2 закрепил отсутствие сравнения модели судьи с моделью автора. Эти обязательства сохраняются.

## Существующее

- Дверь `scripts/check_sud_model.sh` (строки 152–198) уже получает модель из единственного `config/agent_models.json` через roles→tiers→models; строки 200–219 сверяют спавн и 243–333 сверяют каждую пятиколоночную строку bind-трассы, отдельно primary `allowed` и объявленный `denied` fallback. Сегодня три сравнения `!=` отказывают на bare ID при prefixed назначении, хотя обе формы называют одну модель. Роль/объект/сессия и валидаторы алфавита остаются существующими.
- Производитель `scripts/models_actual.sh` (строки 101–112) уже создаёт bind-трассу, но строки 109–110 возвращают `NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]` rc 2 на реальном имени `Arbiter079Б1` (сообщено владельцем, HANDOFF.md §ГДЕ МЫ 09.11 ~08:00; источник кода подтверждён). Это самостоятельный дефект производителя, не модельное сравнение; не расширять здесь алфавит/CLI `--session`, не обходить отказ фильтрацией, не править tabló DEMO.
- Семья `contracts/104-uzkij-doverennyj-gejt-sudi.md`, `fixtures/zashchita_main_104/red_sud_model_dver_spavna.sh` и `red_sud_model_materializatsija.sh` уже судит назначенный тир, fallback, привязку, каждую строку и ошибочную грамматику. Их не переписывать/не дублировать целиком: семья 173 добавляет только пары форм имён на том же CLI. `contracts/166-snyatie-ogranichitelya-modelej.md` не нормализует имена, а отменяет проверку отличия модели автора; не использовать для сравнения ID.
- План `registry/plan.tsv` (строка 101) несёт слот 173; поиск в `contracts/`, `scripts/`, `fixtures/`, локальных `wip/*` и открытых PR (`gh pr list --search check_sud_model` → `[]`) не обнаружил другого незавершённого решения для этой нормализации. Существующие генераторы/оверлеи моделей не нуждаются в правке: в данной двери ожидание уже разрешено из реестра.

## Предмет и граница

На публичных ногах `bash scripts/check_sud_model.sh --spawn <роль> <факт> --root <корень>` и `--verdict <роль> --trace <tsv> --object <40-hex> --session <id> --root <корень>` модель с префиксом провайдера и та же модель без префикса эквивалентны: `anthropic/claude-opus-5-5` ≡ `claude-opus-5-5`, `zai/glm-5.3` ≡ `glm-5.3`, `openai-codex/gpt-6-sol` ≡ `gpt-6-sol`. Сравнить на каждой из трёх существующих точек — спавн, allowed primary, denied fallback — с ожидаемой моделью соответствующего тира. Если ОБЕ строки имеют префикс, они равны только побайтно: `evil/claude-opus-5-5` ≠ `anthropic/claude-opus-5-5`; если обе bare — побайтово. Сравнение — литеральное, ни regex, ни glob из значения модели. Удаление префикса для сравнения не меняет выводимые фактические ID, источник назначений, чужие отказы и порядок привязки.

Конформны непустые ASCII-ID модели из алфавита 104 (`[A-Za-z0-9._/-]`), пятиколоночная bind-строка с ASCII session-id и 40-hex object; в наблюдаемой семье модель реестра — `provider/model`, факт — `model` либо `provider/model`. Валидный контрпример для свойства — инвариантный к конкретным именам/версиям и расходящийся на такой конформной паре; никакая сломанная сессия, неверная грамматика трассы или рассинхрон версии не служит контрпримером. Идентичность сессии и объекта продолжает проверять 104; `models_actual.sh`, `judge_gate.sh`, `roles/*`, `config/*`, проект/CI табло и следующее фазовое изделие вне зоны реализации.

## Приёмка

- Дано дерево до реализации с полным назначением reviewer `anthropic/claude-opus-5-5`, fallback `openai-codex/gpt-6-sol` и critic `zai/glm-5.3`; когда `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo`; тогда rc 1 и самостоятельные `spawn_bare_opus KRASNO`, `spawn_bare_glm KRASNO`, `verdict_bare_primary KRASNO`, `verdict_bare_fallback KRASNO`, `verdict_bare_glm KRASNO`, `dynamic_bare_opus KRASNO` (временная конформная пара со значением, выбранным при каждом прогоне); отрицательные клетки не заменяют их красноту.
- `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo` → красная: 173 spawn_bare_opus KRASNO
- Дано честная временная реализация на pinned `frozen/contracts/104/2:scripts/check_sud_model.sh`; когда `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --model`; тогда rc 0, все позитивные bare-клетки зелёны, неверная версия и чужой prefixed провайдер получают rc 1 с существующей причиной; этот контроль независим от последующего кода рабочего дерева. Дано порчи честной реализации; когда `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --stabs`; тогда rc 0, каждый `STAB … caught`, ни одного `ZHIV`; адрес стаб→вход задаёт только код `probe.py` (Н-39).
- Дано реализация в зоне implementer; когда `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo` и `bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh` (CI); тогда обе rc 0: для bare primary/denied fallback и prefixed primary наблюдается существующий положительный `СУДЬЯ СВОЕЙ МОДЕЛИ`, для иной версии/полного чужого провайдера — rc 1 с прежней точной причиной, stdout пуст. Привязка и грамматика 104: `bash fixtures/zashchita_main_104/red_sud_model_dver_spavna.sh` и `bash fixtures/zashchita_main_104/red_sud_model_materializatsija.sh` → rc 0.
- Дано черновик; когда `bash scripts/pre_critic.sh --repo . contracts/173-normalizaciya-imyon-modelej-sudi.md`; тогда rc 0. Перед done `bash scripts/check_provodka.sh . contracts/173-normalizaciya-imyon-modelej-sudi.md` → rc 0; CI проводка скрипта подключается оркестратором после ленда, `bash scripts/gen_ci_steps.sh --check` → rc 0.

## Модель угроз

ЗАЩИЩАЕТ:
- Ложный отказ при фактически одной назначенной модели, когда bind-трасса/спавн несёт bare ID без provider; пустой провайдер у факта не отменяет обязательную привязку и проверку fallback.
- Ложное принятие другого явно указанного provider, версии или суффикса как будто это назначенная модель.

НЕ ЗАЩИЩАЕТ:
- Bind-трассу с именем сессии вне алфавита производителя; её rc 2 — отдельный предмет фазы 1. Альтернативную маршрутизацию и модельные названия вне алфавита 104.

## Зоны и проводка

ЗОНА architect: contracts/173-normalizaciya-imyon-modelej-sudi.md fixtures/workshop_project/sud_model_173/
ЗОНА implementer: scripts/check_sud_model.sh
ЗОНА critic: verdicts/critic/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 104 только три сравнения модели; привязка и алфавиты 104 без изменений.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 173.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 173.

ПРЕДПОСЫЛКИ:
- setting Действующий CI харнесса предоставляет bash, Python 3, git и jq; CI-шаг запускает fixtures/workshop_project/sud_model_173/red_sud_model_173.sh без новых secrets, variables, environments или настроек репозитория.

ПРОВОДКА:
- guard=fixtures/workshop_project/sud_model_173/red_sud_model_173.sh
ПРОВОДКА-ЭНФОРСМЕНТ: скрипт двери уже существует; новая обязанность есть уточнение сравнения модели внутри scripts/check_sud_model.sh, не поведенческая норма роли; батарея fixtures/workshop_project/sud_model_173/red_sud_model_173.sh подключается отдельным CI-шагом после ленда.

## Незаполненные требования:
нет
