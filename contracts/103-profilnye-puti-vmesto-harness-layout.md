# Контракт 103 — профильные пути вместо harness-layout (consumers читают workflowPaths.*; исполняемый стандарт проекта v1 §1)

КОНТЕКСТ: docs/owner/2026-10-14-standart-proekta-v1.md §1 (таблица «Обязательные условия», «Точный профиль», команды приёмки Э1) и §4 (строка make_task/pre_critic/spawn: «harness-layout … мешает проектному .harness/»), нарезка Э1 `history://ArchitectE1E1mNarezka` (carving-пункт «П-101»), scripts/profile_resolver.sh, scripts/make_task.sh, scripts/pre_critic.sh, scripts/spawn_agent.sh, fixtures/context_pack_095/

Номер 103 минтован dual-control (тег `id/CONTRACT/103` на origin). Второй раунд (вердикт критика contracts-103-v1).

## Существующее

- **`scripts/profile_resolver.sh` (054/055/057/059/095, живой код).** УЖЕ резольвирует `workflowPaths.{contracts,verdicts,registry,fixtures}` двумя слоями (SCHEMA_LEVELS: repo:workflowPaths:*:required, project:defaults:workflowPaths:*:required; MERGED `.workflowPaths.<k>.{value,origin}`). По Границе-1 контракта 059 (строки 656–660) workflowPaths.* с деревом НЕ сверяется — «целевая раскладка, ещё не существующая». Поиск: `grep -n workflowPaths scripts/profile_resolver.sh`. Исход: источник значений ЕСТЬ, потребителей у него НЕТ — ни один consumer не читает `.workflowPaths` из MERGED. Владелец: 054. Причина расширения, не создания: второй резолвер запрещён (Astra 1.2, 095 Frontier).
- **`scripts/make_task.sh` (095, живой код).** Три чтения harness-layout: (д) черновик — строка 208 `ls contracts/${N}-*.md`; (з) заморозка — строка 202 `ls-tree "$TAG" "contracts/"` + `grep "^contracts/${N}-…"`; (б) бриф — строки 276–288: `registry/plan.tsv` (GOAL) и `ls "$REPO"/contracts/*.md` (WORK). Профиль УЖЕ потребляется через profile_resolver (строка 108, MERGED), т.е. значение `.workflowPaths` в руках — его нужно ПРИМЕНИТЬ во всех трёх чтениях. Владелец: 095.
- **`scripts/pre_critic.sh` (072/095, живой код).** CLI — только `<отн-путь-контракта>` от ROOT = место скрипта (строки 46–61); нога (г) формы вооружена только при `registry/contracts.tsv` в ROOT (А-384). На проектном репо дверь критика не работает по построению. Владелец: 072.
- **`scripts/spawn_agent.sh` (016/023/095, живой код).** Dual-control (строки 203–213) читает `${origin_main_sha}:registry/contracts.tsv` — путь реестра зашит; фраза отказа 3б (строка 255) несёт тот же путь. Владелец: 023.
- **`scripts/freeze_contract.sh` (живой код).** Строки 104–115: принимает ТОЛЬКО корневые `plans/NNN-*.md` | `contracts/NNN-*.md`, пишет в корневой `registry/contracts.tsv`. На профильной раскладке `bash scripts/freeze_contract.sh tasks/h/777-toy.md …` → rc 1 «замораживается только plans/NNN-*.md либо contracts/NNN-*.md» (замер критика, круг 1). Производитель реестра — отдельный предмет (§НЕ предмет); здесь только потребители.
- **`workshop` (054/055, живой код).** Harness-layout НЕ читает: `grep -nE 'contracts/|registry/|verdicts/|fixtures/' workshop` даёт только комментарии; probe зовёт profile_resolver и судит projectId (строки 716–738). Менять нечего — вне предмета (§НЕ предмет).
- **`fixtures/context_pack_095/` (16 клеток, `_toy.sh`, `model/dover.sh`, `battery_stubs.sh`).** Паттерн семьи: toy-мир по РЕАЛЬНЫМ путям профиля, честные модели как носители грамматики, стабы sed-по-маркеру, раннер с замером клеток. Семья 103 РАСШИРЯЕТ паттерн (свой `_toy.sh` с нестандартной раскладкой), не второй генератор миров: toy 095 несёт стандартную раскладку (`_toy.sh:58,86,123,183` — корневые contracts/registry) и не меняется; различие раскладок доказывают только клетки 103.
- **`docs/owner/2026-10-14-standart-proekta-v1.md` §1.** Таблица условий допуска с колонкой «Как владелец принимает» — команды на прозе; исполняемого скрипта НЕТ. `registry/harness-project.json` — пример данных, не схема (там же).
- **Измеренные грабли.** Н-39 (стабы в прозе), Н-85/А-122 (миры только в /tmp/dev-harness-verify), Н-56 (identity), А-384 (нога по наличию файла в ROOT — та же болезнь harness-layout), 059 Граница-1 (сверка workflowPaths отложена «до потребителя» — потребитель здесь).

## Предмет

Три consumer'а харнеса — `make_task.sh` (все три чтения: черновик, заморозка, бриф), `pre_critic.sh`, `spawn_agent.sh` — берут расположение contracts/registry из эффективного `workflowPaths.*` профиля проекта (profile_resolver — единственный источник), а не из зашитых `contracts/`, `registry/plan.tsv`, `registry/contracts.tsv`, `ls-tree "$TAG" "contracts/"`. Плюс новый `scripts/check_project_standard.sh` — исполняемая форма офлайн-проверяемых условий стандарта v1 §1.

Выход: на репозитории проекта с раскладкой `.harness/*` (или любой иной, объявленной профилем) `make_task`/`pre_critic`/`spawn_agent` читают черновик, замороженный блоб, план брифа и манифест dual-control из профильных каталогов, не трогая корень; каталоги харнеса в корне проекта для ЧТЕНИЯ не нужны. Производство этих артефактов на профильной раскладке (заморозка, запись реестра) — вне предмета: И-3 получает тег и строку реестра от toy, не от `freeze_contract.sh`.

## НЕ предмет

- **Заморозка и запись реестра на профильной раскладке** (`freeze_contract.sh` → корневой `registry/contracts.tsv`; `mint_line`): отдельный carving-пункт нарезки Э1 (вопрос оркестратору на номер). Здесь — только чтение; на харнесе как проекте `workflowPaths.registry=registry` (harness.project.json) — производитель и потребитель совпадают, регрессии нет.
- **`workshop`**: harness-layout не читает (замер в §Существующее) — дельты нет, зона не объявляется.
- Алфавит `language` (`javascript`) — отдельный carving-пункт; эталон 103 объявляет `typescript`.
- Онлайн-условия стандарта (защита main/rulesets, `gh pr checks`, `npm ci`/длительности, живой запуск/health, секрет-сканер) — П-103/П-104 и Э7; `check_project_standard.sh` судит только офлайн-условия из списка в модели.
- Изоляция state/home по `repoId` (workshop:738–763) — отдельный пункт нарезки.
- Сверка workflowPaths с деревом ВНУТРИ profile_resolver (снятие Границы-1 059) — не здесь: гард стоит у потребителей; resolver не трогается (зона не объявлена).
- Семантика frozen-тегов (`frozen/contracts/<N>/*` — имя тега, не путь) не меняется: меняется только `ls-tree` ПУТЬ контракта внутри блоба.
- Манифест пака `<repo>/.omp/context/<N>.tsv` (095) — не workflowPath, не трогается.

## Frontier

- **Где стоит гард «путь вне репо» (И-5).** (а) В resolver — снимает Границу-1 059 и трогает чужую зону; отвергнуто для этого раунда. (б) **Выбрано:** у потребителя, ОДНОЙ функцией внутри make_task.sh (канонизация `readlink -f` от `pwd -P` репо, префикс-сравнение, абсолют → отказ) и той же проверкой в check_project_standard.sh; фраза единая: `ОТКАЗ: workflowPaths вне репо: <ключ>=<значение>` / `ОТКАЗ: стандарт: workflowPaths: вне репо: <ключ>=<значение>`.
- **Заморозка в блобе (И-1в/И-1г).** (а) Искать контракт в блобе по обоим путям (профильный, потом корневой) — отвергнуто: корень как фолбэк и есть harness-layout, приманка в корне тега выиграла бы при пустом профильном каталоге. (б) **Выбрано:** `ls-tree "$TAG" "<contracts>/"` только по профильному пути; пусто → `ОТКАЗ: заморозка без контракта: <тег>` дословно 095.
- **CLI pre_critic на проекте (И-2).** (а) Переменная окружения ROOT — отвергнуто (невидимый вход, cwd-зависимость в другой одежде). (б) **Выбрано:** флаг `--repo <R>`; путь контракта — от R; без флага — поведение 072 дословно (харнес сам себе проект). Ноги (а)/(б) (npm-гейты) зовутся с `R` вместо `.`; нога (г) вооружается наличием `<workflowPaths.registry>/contracts.tsv` в R, не `registry/contracts.tsv` (А-384 закрывается тем же движением).
- **Реестр dual-control (И-3).** **Выбрано:** путь манифеста = `<workflowPaths.registry>/contracts.tsv` по эффективному профилю `--root`; грамматика строки 023 и membership-сверка 2а/2б/2в не меняются; фраза 3б несёт фактический путь.
- **Стандарт (И-4).** (а) Один `true`/`false` → отвергнуто (владелец не видит, ЧТО нарушено). (б) **Выбрано:** каждое условие — своя строка `ОТКАЗ: стандарт: <имя>: <деталь>` в stderr, скрипт не останавливается на первом (И-4в ловит `exit` после первой строки), rc 1 при ≥1, rc 2 — нечем проверить (нет репо/jq); имена условий — закрытый список в шапке `fixtures/project_paths_103/model/check_project_standard.sh` (единый источник, продукт несёт побайтово). Слой проекта: `--layer-root` > `HARNESS_PROJECT_LAYER_ROOT` > R. Предикаты (11, дословно шапка модели):
  - `git-main` — `refs/heads/main` есть локально;
  - `git-origin` — `git remote get-url origin` rc 0;
  - `profil` — `harness.project.json` есть; ключи `schemaVersion`(=1), `repoId`, `language`, `projectLayer` непусты; `projectLayer.profilePath` существует под слоем; эффективно (репо, иначе defaults слоя) все 4 ключа workflowPaths;
  - `workflowPaths` — каждый из 4 путей канонизируется ВНУТРЬ репо (та же функция, что И-5) и есть каталог;
  - `lockfile` — в корне есть хотя бы один из `package-lock.json` | `yarn.lock` | `pnpm-lock.yaml` | `Cargo.lock`;
  - `komandy-true` — ни одна из эффективных `commands.{test,lint,typecheck,build}` не равна `true`;
  - `agents-md` — `AGENTS.md` непуст;
  - `kontekst-karta` — эффективный `contextPack.rows` несёт kind=map И kind=rules, их `path` существуют в дереве;
  - `env-example` — `.env.example` есть;
  - `env-ignore` — `git check-ignore -q .env` rc 0 И `.env` не в индексе;
  - `harness-pin` — `config/harness_pin.json` с непустым `.version`.

## Решения

1. `make_task.sh`: пути контрактов/реестра — из MERGED `.workflowPaths.{contracts,registry}.value` (далее `<contracts>`, `<registry>`); черновик `ls <contracts>/${N}-*.md`; заморозка `ls-tree "$TAG" "<contracts>/"` + `grep "^<contracts>/${N}-[^/]+\.md$"`; бриф GOAL из `<registry>/plan.tsv`, WORK из `ls <contracts>/*.md`; манифест-файл пака остаётся `<repo>/.omp/context/<N>.tsv` (095). Гард И-5 до любого чтения.
2. `pre_critic.sh --repo <R> <путь-от-R>`; без `--repo` — 072 дословно.
3. `spawn_agent.sh`: манифест dual-control по `<workflowPaths.registry>/contracts.tsv` проекта `--root`.
4. `scripts/check_project_standard.sh --repo <R> [--layer-root <L>]` — грамматика, приоритет слоя и список условий = модель `fixtures/project_paths_103/model/check_project_standard.sh` (предикаты — Frontier И-4).
5. CI-строка батареи (`registry/ci-steps.tsv`) — перегенерацией ПОСЛЕ landing (прецедент 095).

## Инварианты

Toy (`_toy.sh`): `workflowPaths.contracts=tasks/h`, `workflowPaths.registry=tasks/reg`; маркеры — самостоятельные строки внутри §Существующее/§Предмет/plan.tsv, различные побайтово между профильным источником и корневой приманкой.

- И-1а (черновик): дано контракт 777 только в tasks/h, корневого contracts/ нет; когда `bash scripts/make_task.sh --repo R --kind task --role architect --contract 777 --model-trace T`; тогда rc 0 и stdout несёт маркер §Существующее профильного контракта самостоятельной строкой (`grep -Fx`). Клетка `red_kontrakt_iz_profilnogo_puti.sh`.
- И-1б (черновик, негатив): дано контракт 777 в корневом contracts/, tasks/h пуст; когда та же команда; тогда rc 1 и «ОТКАЗ: черновик контракта не найден: 777», маркера корневого контракта в выводе нет. Клетка `red_koren_harnesa_ne_istochnik.sh`.
- И-1в (заморозка): дано тег `frozen/contracts/777/1`, в дереве тега `tasks/h/777-toy.md` (маркер F) И приманка `contracts/777-toy.md` (маркер K); рабочее дерево `tasks/h/777-toy.md` несёт маркер D ≠ F; когда `make_task … --role implementer --contract 777`; тогда rc 0, stdout несёт F самостоятельной строкой, ни K, ни D в выводе нет (`! grep -F`). Клетка `red_frozen_iz_profilnogo_puti.sh`.
- И-1г (заморозка, негатив): дано тег `frozen/contracts/777/1`, в дереве тега ТОЛЬКО `contracts/777-toy.md` (маркер K), tasks/h в теге пуст; когда та же команда; тогда rc 1 и «ОТКАЗ: заморозка без контракта: frozen/contracts/777/1», K в выводе нет. Клетка `red_frozen_koren_ne_istochnik.sh`.
- И-1д (бриф): дано `tasks/reg/plan.tsv` (строка-маркер G) и `tasks/h/777-toy.md` с §Предмет P; приманки: корневой `registry/plan.tsv` (маркер G′) и `contracts/778-decoy.md` с §Предмет P′; когда `make_task --repo R --kind brief --role orchestrator --model-trace T`; тогда rc 0, stdout несёт G и `WORK: 777 :: P` самостоятельными строками, ни G′, ни `WORK: 778` в выводе нет. Клетка `red_brief_iz_profilnogo_puti.sh`.
- И-2: дано проектный репо и `pre_critic.sh --repo R tasks/h/777-toy.md`; когда вызов из cwd=R, cwd=R/tasks, cwd=/tmp/dev-harness-verify/…; тогда полный контракт — rc 0 из всех трёх; контракт без `КОНТЕКСТ:` — rc 1 из всех трёх с побайтово равной первой строкой stderr (слово «форма»). Клетка `red_pre_critic_cwd.sh`.
- И-3: дано origin с аннотированным `id/CONTRACT/777`, `tasks/reg/contracts.tsv` на origin/main с верной строкой (toy пишет строку по грамматике 023 сам — freeze вне предмета), корневого registry/ нет, манифест пака есть; когда `spawn_agent.sh --author implementer --nnn 777 --root R`; тогда rc 0 и `BRANCH=wip/777/implementer`, без фразы «registry/contracts.tsv отсутствует». Негатив: корневой registry/contracts.tsv с верной строкой, профильный — с чужим sha → rc 1 «не выдан авторитетом». Клетка `red_spawn_reestr_proekta.sh`.
- И-4а: дано эталон `_t103_complior`; когда `HARNESS_PROJECT_LAYER_ROOT=R bash scripts/check_project_standard.sh --repo R`; тогда rc 0 и ни одной строки «ОТКАЗ: стандарт:». Клетка `red_standart_etalon.sh`.
- И-4б: дано 11 миров из эталона, в каждом нарушено ровно одно условие; когда та же команда; тогда в каждом rc 1 и ровно одна строка «ОТКАЗ: стандарт:», и она — «ОТКАЗ: стандарт: <имя>:» этого условия. Клетка `red_standart_narushenija.sh`.
- И-4в (полный набор): дано мир из эталона с ТРЕМЯ одновременными нарушениями `komandy-true`, `env-example`, `harness-pin`; когда та же команда; тогда rc 1, строк «ОТКАЗ: стандарт:» ровно 3 (`grep -c`), и каждая из трёх «ОТКАЗ: стандарт: <имя>:» присутствует (`grep -F` по каждому имени; порядок не судится). Клетка `red_standart_polnyj_nabor.sh`.
- И-5: дано `workflowPaths.contracts` = `../vne/h` | абсолют | симлинк `tasks/h`→наружу (сосед несёт контракт 777); когда make_task (И-1а-команда) и check_project_standard; тогда оба rc 1: «ОТКАЗ: workflowPaths вне репо: contracts=…» / «ОТКАЗ: стандарт: workflowPaths: вне репо: contracts=…», байтов контракта соседа нет. Клетка `red_puti_vne_repo.sh`.

## Модель угроз

Границы названы по свойству, не перечислением входов.

ЗАЩИЩАЕТ:
- чтение артефактов проекта из harness-layout при объявленной иной раскладке — черновик, блоб заморозки, план/карта брифа, манифест dual-control (И-1а–И-1д, И-3);
- зависимость вердикта двери критика от cwd/корня харнеса (И-2);
- побег workflowPaths за корень репо (`..`, абсолют, симлинк) у потребителя (И-5);
- «стандарт выполнен» одним зелёным/первой красной точкой — каждое нарушенное условие именуется, ни одно не скрыто за предыдущим (И-4а/И-4б/И-4в).

НЕ ЗАЩИЩАЕТ:
- производство артефактов на профильной раскладке (заморозка, запись реестра) — вне предмета;
- онлайн-условия стандарта (GitHub-защита, CI-результаты, длительности, живой запуск) — П-103/П-104/Э7;
- содержательную силу AGENTS.md/карты (наличие и непустота, не качество);
- подделку профиля ДОВЕРЕННОЙ стороной (профиль — вход канала оркестратора; граница 094);
- сверку workflowPaths с деревом внутри resolver (Граница-1 059 остаётся; потребитель судит сам).

## Приёмка

Носитель — клетки `fixtures/project_paths_103/red_*.sh` (11), раннер `fixtures/_krasnye_103.sh`, стаб-пак `fixtures/project_paths_103/battery_stubs.sh` (14 стабов на 10 маркерах), честные модели `fixtures/project_paths_103/model/{kontrakt_po_profilju,pre_critic_proekta,dver_reestra,check_project_standard}.sh`, каркас `_toy.sh` (toy с раскладкой tasks/*; эталон Complior с .harness/*). Миры — только `/tmp/dev-harness-verify/project-paths-103-**`, вычистка за собой; оракулы в памяти до вызова; сверки `grep -Fx`/`grep -F` по именованным фразам; каждая клетка красна своим предъявлением.

1. Дано: дерево ДО реализации; когда: `bash fixtures/_krasnye_103.sh`; тогда: rc 1, вывод несёт «красная: предмет отсутствует», все 11 клеток rc 1 (И-1а «черновик не найден», И-1б «принят», И-1в «байты приманки K», И-1г «принят», И-1д «G′ в GOAL», И-2 «NOT_IMPLEMENTED: --repo», И-3 «ищет корневой registry/contracts.tsv», И-4а/И-4б/И-4в/И-5 «предмет отсутствует: scripts/check_project_standard.sh»), стаб-пак rc 0.
2. Дано: честные модели; когда: `bash fixtures/_krasnye_103.sh --model`; тогда: rc 0 — 11 клеток зелены, 14 стабов пойманы (анти-тавтология; привязка стаб→клетка — в battery_stubs.sh, Н-39).
3. Дано: дерево ПОСЛЕ реализации; когда: `bash fixtures/_krasnye_103.sh`; тогда: rc 0.
4. Правило: регрессия соседей; команды: `bash fixtures/_krasnye_095.sh` → rc 0; `bash fixtures/_krasnye_072.sh` → rc 0; `bash scripts/pre_critic.sh contracts/103-profilnye-puti-vmesto-harness-layout.md` → rc 0 (харнес как проект без `--repo`).
5. Правило: команды приёмки стандарта §1 на харнесе как проекте; команда: `HARNESS_PROJECT_LAYER_ROOT=. bash scripts/check_project_standard.sh --repo .` → rc 0 либо rc 1 с каждой красной строкой из списка 11 (харнес не обязан быть эталоном; «ОТКАЗ: стандарт:» с именем вне списка — дефект; rc 2 — дефект).
6. Правило: ноль зашитых путей вне комментариев; команда: `grep -nE '"contracts/|ls contracts/|registry/plan\.tsv|registry/contracts\.tsv|ls-tree "\$TAG" "contracts/"' scripts/make_task.sh scripts/pre_critic.sh scripts/spawn_agent.sh | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#'` → rc 1 (пусто); остаток cognitive-only — путь в хвостовом комментарии кода или в собранной из переменных строке (ловец — И-1а–И-1д/И-3 поведением и ревьюер по diff).

- `bash fixtures/_krasnye_103.sh` → красная: предмет отсутствует

замер: `ls fixtures/project_paths_103/red_*.sh | wc -l` = 11 census fixtures/project_paths_103/red_*.sh

## Зоны (check_zones)

ЗОНА architect: contracts/103-profilnye-puti-vmesto-harness-layout.md fixtures/project_paths_103/ fixtures/_krasnye_103.sh NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: scripts/make_task.sh scripts/pre_critic.sh scripts/spawn_agent.sh scripts/check_project_standard.sh registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 дельта 103: пути контрактов/плана из MERGED workflowPaths в трёх чтениях (черновик, заморозка, бриф) + гард И-5; грамматика пака/отказов 095 не ослабляется, батарея 095 остаётся зелёной
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 072 дельта 103: флаг --repo; без флага ноги (а)-(в) 072 дословно
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 094 дельта 103: только флаг --repo, семантика 094 не трогается
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 095 дельта 103: нога (г) вооружается профильным реестром, не registry/contracts.tsv корня
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 016 дельта 103: только путь манифеста dual-control, identity/атомарность 016 не трогаются
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 019 дельта 103: только путь манифеста dual-control, семантика 019 не трогается
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 023 дельта 103: путь манифеста dual-control из workflowPaths.registry; грамматика строки и membership 2а-2в не ослабляются
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 086 дельта 103: только путь манифеста dual-control, семантика 086 не трогается
ПЕРЕСЕЧЕНИЕ implementer: scripts/spawn_agent.sh — 095 дельта 103: нога манифеста пака не трогается
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
- До контракта заморозки на профильной раскладке проект с `workflowPaths.contracts≠contracts` может ЧИТАТЬ заморозки, но не ПРОИЗВОДИТЬ их штатной командой; владелец видит это отказом `freeze_contract.sh` (грамматика строк 104–115), не молчанием.

## Незаполненные требования:

нет

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/_krasnye_103.sh

ПРОВОДКА-ЭНФОРСМЕНТ: предмет — чистый энфорсмент (пути из профиля, гард побега, именованные условия стандарта) дверями make_task/pre_critic/spawn_agent/check_project_standard и их батареей; поведенческих норм роли не вводится. Guard в CI — ТОЛЬКО ПОСЛЕ landing (прецедент 074/093/094/095).

## Замечания по применимости норм

- 041: новые парсеры чужого ввода не вводятся (профиль — jq по действующей схеме 054; список условий — замкнутый алфавит имён); Модель угроз — метки `ЗАЩИЩАЕТ:`/`НЕ ЗАЩИЩАЕТ:` дословно.
- 050 (грамматика приёмки): каждая строка — сценарий с rc либо правило с командой; негативы — И-1б, И-1г, И-3-негатив, И-4б/И-4в, И-5.
- 050 (вертикальный срез): норма → клетки → реализация трёх потребителей + новый скрипт → CI-строка → суд одной пачкой.
- Н-39: привязка 14 стабов — в коде battery_stubs.sh, не здесь.
