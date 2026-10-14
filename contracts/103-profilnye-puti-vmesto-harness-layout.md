# Контракт 103 — профильные пути вместо harness-layout (consumers читают workflowPaths.*; исполняемый стандарт проекта v1 §1)

КОНТЕКСТ: docs/owner/2026-10-14-standart-proekta-v1.md §1 (таблица «Обязательные условия», «Точный профиль», команды приёмки Э1) и §4 (строка make_task/pre_critic/spawn: «harness-layout … мешает проектному .harness/»), нарезка Э1 `history://ArchitectE1E1mNarezka` (carving-пункт «П-101»), scripts/profile_resolver.sh, scripts/make_task.sh, scripts/pre_critic.sh, scripts/spawn_agent.sh, workshop, fixtures/context_pack_095/

Номер 103 минтован dual-control (тег `id/CONTRACT/103` на origin). Первый раунд.

## Существующее

- **`scripts/profile_resolver.sh` (054/055/057/059/095, живой код).** УЖЕ резольвирует `workflowPaths.{contracts,verdicts,registry,fixtures}` двумя слоями (SCHEMA_LEVELS: repo:workflowPaths:*:required, project:defaults:workflowPaths:*:required; MERGED `.workflowPaths.<k>.{value,origin}`). По Границе-1 контракта 059 (строки 656–660) workflowPaths.* с деревом НЕ сверяется — «целевая раскладка, ещё не существующая». Поиск: `grep -n workflowPaths scripts/profile_resolver.sh`. Исход: источник значений ЕСТЬ, потребителей у него НЕТ — ни один consumer не читает `.workflowPaths` из MERGED. Владелец: 054. Причина расширения, не создания: второй резолвер запрещён (Astra 1.2, 095 Frontier).
- **`scripts/make_task.sh` (095, живой код).** Строки 199–210: контракт ищется `ls contracts/${N}-*.md` и `ls-tree "$TAG" "contracts/"`; 276–288: `registry/plan.tsv`, `contracts/*.md` — harness-layout зашит. Профиль УЖЕ потребляется через profile_resolver (строка 108, MERGED), т.е. значение `.workflowPaths` в руках — его нужно ПРИМЕНИТЬ. Владелец: 095.
- **`scripts/pre_critic.sh` (072/095, живой код).** CLI — только `<отн-путь-контракта>` от ROOT = место скрипта (строки 46–61); нога (г) формы вооружена только при `registry/contracts.tsv` в ROOT (А-384). На проектном репо дверь критика не работает по построению. Владелец: 072.
- **`scripts/spawn_agent.sh` (016/023/095, живой код).** Dual-control (строки 203–213) читает `${origin_main_sha}:registry/contracts.tsv` — путь реестра зашит; фраза отказа 3б (строка 255) несёт тот же путь. Владелец: 023.
- **`workshop` (054/055, живой код).** Launcher проекта — probe профиля; harness-layout там в пробе путей. Владелец: 054.
- **`fixtures/context_pack_095/` (16 клеток, `_toy.sh`, `model/dover.sh`, `battery_stubs.sh`).** Паттерн семьи: toy-мир по РЕАЛЬНЫМ путям профиля, честные модели как носители грамматики, стабы sed-по-маркеру, раннер с замером клеток. Семья 103 РАСШИРЯЕТ паттерн (свой `_toy.sh` с нестандартной раскладкой), не второй генератор миров: toy 095 несёт стандартную раскладку и не меняется.
- **`docs/owner/2026-10-14-standart-proekta-v1.md` §1.** Таблица условий допуска с колонкой «Как владелец принимает» — команды на прозе; исполняемого скрипта НЕТ. `registry/harness-project.json` — пример данных, не схема (там же).
- **Измеренные грабли.** Н-39 (стабы в прозе), Н-85/А-122 (миры только в /tmp/dev-harness-verify), Н-56 (identity), А-384 (нога по наличию файла в ROOT — та же болезнь harness-layout), 059 Граница-1 (сверка workflowPaths отложена «до потребителя» — потребитель здесь).

## Предмет

Четыре consumer'а харнеса — `make_task.sh`, `pre_critic.sh`, `spawn_agent.sh`, `workshop` — берут расположение contracts/verdicts/registry/fixtures из эффективного `workflowPaths.*` профиля проекта (profile_resolver — единственный источник), а не из зашитых `contracts/`, `registry/plan.tsv`, `registry/contracts.tsv`, `frozen/contracts/...`-листинга корня. Плюс новый `scripts/check_project_standard.sh` — исполняемая форма офлайн-проверяемых условий стандарта v1 §1.

Выход (слово стандарта §1, команды приёмки Э1): реальный запуск `make_task`/`pre_critic`/`spawn_agent` на репозитории проекта с раскладкой `.harness/*` (или любой иной) проходит через preflight/freeze/spawn без каталогов харнеса в корне проекта.

## НЕ предмет

- Алфавит `language` (`javascript`) — отдельный carving-пункт; эталон 103 объявляет `typescript`.
- Онлайн-условия стандарта (защита main/rulesets, `gh pr checks`, `npm ci`/длительности, живой запуск/health, секрет-сканер) — П-103/П-104 и Э7; `check_project_standard.sh` судит только офлайн-условия из списка в модели.
- Изоляция state/home по `repoId` (workshop:738–763) — отдельный пункт нарезки.
- Сверка workflowPaths с деревом ВНУТРИ profile_resolver (снятие Границы-1 059) — не здесь: гард стоит у потребителей; resolver не трогается (зона не объявлена).
- Семантика frozen-тегов (`frozen/contracts/<N>/*` — имя тега, не путь) не меняется: меняется только `ls-tree` ПУТЬ контракта внутри блоба.

## Frontier

- **Где стоит гард «путь вне репо» (И-5).** (а) В resolver — снимает Границу-1 059 и трогает чужую зону; отвергнуто для этого раунда. (б) **Выбрано:** у потребителя, ОДНОЙ функцией внутри make_task.sh (канонизация `readlink -f` от `pwd -P` репо, префикс-сравнение, абсолют → отказ) и той же проверкой в check_project_standard.sh; фраза единая: `ОТКАЗ: workflowPaths вне репо: <ключ>=<значение>` / `ОТКАЗ: стандарт: workflowPaths: вне репо: <ключ>=<значение>`.
- **CLI pre_critic на проекте (И-2).** (а) Переменная окружения ROOT — отвергнуто (невидимый вход, cwd-зависимость в другой одежде). (б) **Выбрано:** флаг `--repo <R>`; путь контракта — от R; без флага — поведение 072 дословно (харнес сам себе проект). Ноги (а)/(б) (npm-гейты) зовутся с `R` вместо `.`; нога (г) вооружается наличием `<workflowPaths.registry>/contracts.tsv` в R, не `registry/contracts.tsv` (А-384 закрывается тем же движением).
- **Реестр dual-control (И-3).** **Выбрано:** путь манифеста = `<workflowPaths.registry>/contracts.tsv` по эффективному профилю `--root`; грамматика строки 023 и membership-сверка 2а/2б/2в не меняются; фраза 3б несёт фактический путь.
- **Стандарт (И-4).** (а) Один `true`/`false` → отвергнуто (владелец не видит, ЧТО нарушено). (б) **Выбрано:** каждое условие — своя строка `ОТКАЗ: стандарт: <имя>: <деталь>`, скрипт не останавливается на первом, rc 1 при ≥1; имена условий — закрытый список в шапке `fixtures/project_paths_103/model/check_project_standard.sh` (единый источник, продукт несёт побайтово): git-main, git-origin, profil, workflowPaths, lockfile, komandy-true, agents-md, kontekst-karta, env-example, env-ignore, harness-pin (11).

## Решения

1. `make_task.sh`: пути контрактов/реестра/плана — из MERGED `.workflowPaths.{contracts,registry}.value`; `ls-tree "$TAG" "<contracts>/"`, `ls <contracts>/${N}-*.md`, `<registry>/plan.tsv`; манифест-файл пака остаётся `<repo>/.omp/context/<N>.tsv` (095, не workflowPath). Гард И-5 до любого чтения.
2. `pre_critic.sh --repo <R> <путь-от-R>`; без `--repo` — 072 дословно.
3. `spawn_agent.sh`: манифест dual-control по `<workflowPaths.registry>/contracts.tsv` проекта `--root`.
4. `workshop`: probe путей — по workflowPaths, не по корню.
5. `scripts/check_project_standard.sh --repo <R> [--layer-root <L>]` — грамматика и список условий = модель `fixtures/project_paths_103/model/check_project_standard.sh`.
6. CI-строка батареи (`registry/ci-steps.tsv`) — перегенерацией ПОСЛЕ landing (прецедент 095).

## Инварианты

- И-1а: дано toy-репо `workflowPaths.contracts=tasks/h`, контракт 777 только в tasks/h, корневого contracts/ нет; когда `bash scripts/make_task.sh --repo R --kind task --role architect --contract 777 --model-trace T`; тогда rc 0 и stdout несёт строку §Существующее контракта самостоятельной строкой (`grep -Fx`). Клетка `red_kontrakt_iz_profilnogo_puti.sh`.
- И-1б: дано тот же репо, контракт 777 в корневом contracts/, tasks/h пуст; когда та же команда; тогда rc 1 и «ОТКАЗ: черновик контракта не найден: 777», байтов контракта в выводе нет. Клетка `red_koren_harnesa_ne_istochnik.sh`.
- И-2: дано проектный репо и `pre_critic.sh --repo R tasks/h/777-toy.md`; когда вызов из cwd=R, cwd=R/tasks, cwd=/tmp/dev-harness-verify/…; тогда полный контракт — rc 0 из всех трёх; контракт без `КОНТЕКСТ:` — rc 1 из всех трёх с побайтово равной первой строкой stderr (слово «форма»). Клетка `red_pre_critic_cwd.sh`.
- И-3: дано origin с аннотированным `id/CONTRACT/777`, `tasks/reg/contracts.tsv` на origin/main с верной строкой, корневого registry/ нет, манифест пака есть; когда `spawn_agent.sh --author implementer --nnn 777 --root R`; тогда rc 0 и `BRANCH=wip/777/implementer`, без фразы «registry/contracts.tsv отсутствует». Негатив: корневой registry/contracts.tsv с верной строкой, профильный — с чужим sha → rc 1 «не выдан авторитетом». Клетка `red_spawn_reestr_proekta.sh`.
- И-4а: дано эталон `_t103_complior`; когда `HARNESS_PROJECT_LAYER_ROOT=R bash scripts/check_project_standard.sh --repo R`; тогда rc 0 и ни одной строки «ОТКАЗ: стандарт:». Клетка `red_standart_etalon.sh`.
- И-4б: дано 11 миров из эталона, в каждом нарушено ровно одно условие; когда та же команда; тогда в каждом rc 1 и строка «ОТКАЗ: стандарт: <имя>:» ровно этого условия. Клетка `red_standart_narushenija.sh`.
- И-5: дано `workflowPaths.contracts` = `../vne/h` | абсолют | симлинк `tasks/h`→наружу (сосед несёт контракт 777); когда make_task (И-1а-команда) и check_project_standard; тогда оба rc 1: «ОТКАЗ: workflowPaths вне репо: contracts=…» / «ОТКАЗ: стандарт: workflowPaths: вне репо: contracts=…», байтов контракта соседа нет. Клетка `red_puti_vne_repo.sh`.

## Модель угроз

ЗАЩИЩАЕТ (по свойству):
- чтение артефактов проекта из harness-layout при объявленной иной раскладке (И-1а/И-1б, И-3);
- зависимость вердикта двери критика от cwd/корня харнеса (И-2);
- побег workflowPaths за корень репо (`..`, абсолют, симлинк) у потребителя (И-5);
- «стандарт выполнен» одним зелёным/первой красной точкой — каждое условие именуется (И-4а/И-4б).

НЕ ЗАЩИЩАЕТ:
- онлайн-условия стандарта (GitHub-защита, CI-результаты, длительности, живой запуск) — П-103/П-104/Э7;
- содержательную силу AGENTS.md/карты (наличие и непустота, не качество);
- подделку профиля ДОВЕРЕННОЙ стороной (профиль — вход канала оркестратора; граница 094);
- сверку workflowPaths с деревом внутри resolver (Граница-1 059 остаётся; потребитель судит сам).

## Приёмка

Носитель — клетки `fixtures/project_paths_103/red_*.sh` (7), раннер `fixtures/_krasnye_103.sh`, стаб-пак `fixtures/project_paths_103/battery_stubs.sh` (9 стабов на 8 маркерах), честные модели `fixtures/project_paths_103/model/{kontrakt_po_profilju,pre_critic_proekta,dver_reestra,check_project_standard}.sh`, каркас `_toy.sh` (toy с раскладкой tasks/*; эталон Complior с .harness/*). Миры — только `/tmp/dev-harness-verify/project-paths-103-**`, вычистка за собой; оракулы в памяти до вызова; сверки `grep -Fx`/`grep -F` по именованным фразам; каждая клетка красна своим предъявлением.

1. Дано: дерево ДО реализации; когда: `bash fixtures/_krasnye_103.sh`; тогда: rc 1, вывод несёт «красная: предмет отсутствует», все 7 клеток rc 1 (И-1а «черновик не найден», И-1б «принят», И-2 «NOT_IMPLEMENTED: --repo», И-3 «ищет корневой registry/contracts.tsv», И-4а/И-4б/И-5 «предмет отсутствует: scripts/check_project_standard.sh»), стаб-пак rc 0.
2. Дано: честные модели; когда: `bash fixtures/_krasnye_103.sh --model`; тогда: rc 0 — 7 клеток зелены, 9 стабов пойманы (анти-тавтология).
3. Дано: дерево ПОСЛЕ реализации; когда: `bash fixtures/_krasnye_103.sh`; тогда: rc 0.
4. Правило: регрессия соседей; команды: `bash fixtures/_krasnye_095.sh` → rc 0; `bash fixtures/_krasnye_072.sh` → rc 0; `bash fixtures/_krasnye_054.sh` → rc 0; `bash scripts/pre_critic.sh contracts/103-profilnye-puti-vmesto-harness-layout.md` → rc 0 (харнес как проект без `--repo`).
5. Правило: команды приёмки стандарта §1 на харнесе как проекте; команда: `HARNESS_PROJECT_LAYER_ROOT=. bash scripts/check_project_standard.sh --repo .` → rc 0 либо каждая красная строка именована из списка 11 (харнес не обязан быть эталоном; «ОТКАЗ: стандарт:» без имени — дефект).
6. Правило: ноль зашитых путей; команда: `grep -nE '"contracts/|registry/plan\.tsv|registry/contracts\.tsv|ls-tree "\$TAG" "contracts/"' scripts/make_task.sh scripts/pre_critic.sh scripts/spawn_agent.sh` → rc 1 (пусто), кроме строк-комментариев с префиксом `#` (cognitive-only остаток: комментарии; ловец — ревьюер по diff).

- `bash fixtures/_krasnye_103.sh` → красная: предмет отсутствует

замер: `ls fixtures/project_paths_103/red_*.sh | wc -l` = 7 census fixtures/project_paths_103/red_*.sh

## Зоны (check_zones)

ЗОНА architect: contracts/103-profilnye-puti-vmesto-harness-layout.md fixtures/project_paths_103/ fixtures/_krasnye_103.sh NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: scripts/make_task.sh scripts/pre_critic.sh scripts/spawn_agent.sh workshop scripts/check_project_standard.sh registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 дельта 103: пути контрактов/плана из MERGED workflowPaths + гард И-5; грамматика пака/отказов 095 не ослабляется, батарея 095 остаётся зелёной
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 072 дельта 103: флаг --repo; без флага ноги (а)-(в) 072 дословно
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 094 дельта 103: только флаг --repo, семантика 094 не трогается
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 095 дельта 103: нога (г) вооружается профильным реестром, не registry/contracts.tsv корня
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 016 дельта 103: только путь манифеста dual-control, identity/атомарность 016 не трогаются
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 019 дельта 103: только путь манифеста dual-control, семантика 019 не трогается
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 023 дельта 103: путь манифеста dual-control из workflowPaths.registry; грамматика строки и membership 2а-2в не ослабляются
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 086 дельта 103: только путь манифеста dual-control, семантика 086 не трогается
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 095 дельта 103: нога манифеста пака не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 002 дельта 103: только probe путей по workflowPaths, семантика 002 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 005 дельта 103: только probe путей по workflowPaths, семантика 005 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 010 дельта 103: только probe путей по workflowPaths, топология 010 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 028 дельта 103: только probe путей по workflowPaths, норма HOME 028 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 030 дельта 103: только probe путей по workflowPaths, инвентарь спавна 030 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 054 дельта 103: probe путей по workflowPaths; двухслойный профиль 054 не ослабляется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 055 дельта 103: только probe путей по workflowPaths, протокол владения 055 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 058 дельта 103: только probe путей по workflowPaths, семантика 058 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 060 дельта 103: только probe путей по workflowPaths, дверь минта 060 не трогается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 070 дельта 103: только probe путей по workflowPaths, токен-ветвь 070 не трогается
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 083 дельта 103: строка батареи 103 перегенерацией gen_ci_steps.sh --write ПОСЛЕ landing
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 084 дельта 103: та же перегенерация строк
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 087 дельта 103: та же перегенерация строк, новых шард-ключей нет
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 090 дельта 103: та же перегенерация строк
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 092 дельта 103: та же перегенерация строк
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 093 дельта 103: та же перегенерация строк
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 094 дельта 103: та же перегенерация строк
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 095 дельта 103: та же перегенерация строк
ПЕРЕСЕЧЕНИЕ architect: NABLIUDENIA_ARCHITECT.md — 015 дельта 103: записи А-NN пачки

## Остаточный риск

- Нога (а)/(б) pre_critic на проектном репо гоняет npm-гейты харнеса против чужого контракта; на toy-контракте полной формы они обязаны быть зелены — если precision/spec-гейт отвергнет toy, это дефект toy (правится в зоне architect), не ослабление гейта.
- Скрипт стандарта — офлайн-подмножество §1; «rc 0» не есть допуск проекта (онлайн-условия — владелец руками до П-103/П-104).
- Гард И-5 живёт у потребителя, resolver не сверяет — второй потребитель без гарда (gen_ci_workflow.sh, `<workflowPaths.fixtures>/<имя>.sh`) остаётся открыт до своего контракта.

## Незаполненные требования:

нет

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/_krasnye_103.sh

ПРОВОДКА-ЭНФОРСМЕНТ: предмет — чистый энфорсмент (пути из профиля, гард побега, именованные условия стандарта) дверями make_task/pre_critic/spawn_agent/check_project_standard и их батареей; поведенческих норм роли не вводится. Guard в CI — ТОЛЬКО ПОСЛЕ landing (прецедент 074/093/094/095).

## Замечания по применимости норм

- 041: новые парсеры чужого ввода не вводятся (профиль — jq по действующей схеме 054; список условий — замкнутый алфавит имён); Модель угроз — по свойству.
- 050 (грамматика приёмки): каждая строка — сценарий с rc либо правило с командой; негативы — И-1б, И-3-негатив, И-4б, И-5.
- 050 (вертикальный срез): норма → клетки → реализация четырёх потребителей + новый скрипт → CI-строка → суд одной пачкой.
- Н-39: привязка 9 стабов — в коде battery_stubs.sh, не здесь.
