# Контракт 112 — подключение Complior-back и Complior-mob к режиму проекта (996)

КОНТЕКСТ: docs/owner/2026-10-20-podkljuchenie-proekta.md — слово владельца ~10:18 UTC: предмет и приёмка-прогон 996
КОНТЕКСТ: docs/owner/2026-10-17-resheniya-2030.md — §1–2 топология/режим проекта, §3 канон бэкенда (фактические пути — по дереву)
КОНТЕКСТ: docs/owner/2026-10-17-resheniya-2330.md — канон только для бэкенда, обязанности ролей
КОНТЕКСТ: contracts/996-rezhim-proekta-polnyj-cikl.md — режим проекта (done): gitw-канон, sourceCanon, ноутбучная приёмка
Источник: `docs/owner/2026-10-20-podkljuchenie-proekta.md` (слово владельца 2026-10-20 ~10:18 UTC); plan.tsv строка 112 (пара 4, зависит от 996 — done); ROADMAP этап 3.
Источник v2: `docs/owner/2026-10-20-uskorenie-i-standarty.md` §«Стандарты бэкенда» (слово владельца 2026-10-20 ~13:45 UTC, через консультанта); форк `forks/n112-profil-back-standarty.md` ОТВЕЧЕНО: да (А) 14:05.

ВЕРСИЯ v2 (микро, до реализации; тег `frozen/contracts/112/1` текста v1 не тронут): (1) оба стандарта бэкенда `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` подняты в каноне с priority 1 до priority 0 — перечень 26 источников = 18 priority 0 + 8 priority 1 (пересчёт из кода оракула; в рекомендации форка «26 → 28 = 18+10» двойной счёт: оба файла УЖЕ входили в 26 v1 по 2030 §3, а канон с дублем путей неудовлетворим — замер-канарейка в п.8 Существующего); (2) НОВАЯ клетка D20: профиль back без обоих стандартов → rc 1, причина `kanon-nepolnyj`; (3) профиль back несёт `contextPack` со строками обоих файлов (`mandatory: true`, роли architect/implementer/reviewer/adversary) — ДАННЫМИ профиля по действующей схеме 095 (расширения схемы нет); профиль mob — БЕЗ них. Отказ контракту без этих файлов в «## Источники» — НЕ в 112 (предмет 115).

## Существующее (сверено живьём, дерево — истина)

1. **profile_resolver.sh (054/103/996)** — единственный источник грамматики профиля. Замеры этой сессии на живом вызове (`bash scripts/profile_resolver.sh --repo <мир>`):
   - алфавит `language` = `{rust, typescript, bash}` (строки 546–548) — **javascript отсутствует**: честный профиль Complior-back (Node/JS) сегодня не резолвится. Это разрыв P1, закрывает implementer (одно arm-дополнение), грамматика и schema_levels не меняются;
   - резолвер ОТВЕРГАЕТ: пустое строковое значение команды («значение вне алфавита: commands.test: пусто»), отсутствующий файл `ci.workflow`, отсутствующий файл слоя проекта (`HARNESS_PROJECT_LAYER_ROOT`, умолчание слоя в `check_project_standard.sh:48`);
   - резолвер НЕ проверяет (замерено): существование каталогов `workflowPaths.*` и `state`, существование файлов `sourceCanon.sources[].path`, доступность `sourceCanon.gate`;
   - резолвер ПРОПУСКАЕТ отсутствующий ключ `commands.<имя>` (del(.commands.typecheck) → rc0 резолвера) — пустоту эффективной команды обязана ловить проверка подключения.
2. **gitw (045+996)** — канон обмена: `GIT_EXCHANGE_GUARD_CANONICAL` > эффективный `.git.value.canonicalRemote` > legacy-константа; сравнение целых строк БУКВАЛЬНОЕ. Форма канона = литеральный URL обмена: для Complior-* это HTTPS (`ssh` push с станции не работает — «Repository not found», слово оркестратора 2026-10-20). Дверь не ослабляется и не расширяется: меняется только значение в профиле проекта.
3. **check_project_standard.sh (103)** — исполняемая форма стандарта v1 §1 (lockfile/env/pin и пр.) — НЕ предмет 112 и НЕ препятствие подключению: 112-проверка судит подключение к режиму проекта, а не стандарт v1 целиком.
4. **Продуктовые репозитории (клоны `/tmp/dev-harness-verify/Impl109/back` @ `cmp-bck-004/stend`, `/tmp/dev-harness-verify/Impl108/mob`; свежий main — `git show origin/main:...`)**:
   - Complior-back: CI `.github/workflows/ci.yml` = 7 lanes + required, все команды через `tools/run_backend_ci.py` (`--lane`, `--local`); `backend/package.json` scripts: test, lint, smoke:image, …; `backend/scripts/gen-contracts.js` есть; origin клона `https://github.com/a3ka/Complior-back.git`; `.harness/` НЕТ; `tools/check_source_trace.py` НЕТ (гейт сверки вводит первый бэкенд-контракт — bootstrap-форк 996); канон-файлы 2030 §3 фактическими путями (новая структура 2026-10-20 — форк n112-v2-kanon-26 ОТВЕЧЕНО (А), слово консультанта 14:20/14:35): `docs/Complior_Backend_Architecture_v3_14_RU.md`, `docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml`, `migrations/001…014` (в §3 названы 001–013, в дереве 14 миграций — дереву верим), `AGENTS.md`, `STRUCTURE.md`, `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md`, `docs/DATABASE.md`, `docs/RUNBOOK.md`, `docs/backend/PORT-PLAN.md`, `docs/backend/DONOR-INVENTORY.md`, `docs/backend/AUTH-AND-DB-DECISIONS.md`, `structure-policy.json` (в корне);
   - Complior-mob: CI `.github/workflows/mobile.yml` (job quality, `defaults.run.working-directory: mobile`): `npm test`, `npm run lint`, `npm run typecheck`, `npm run doctor`; `mobile/package.json` scripts: start, android, test, lint, typecheck, doctor, check — **build НЕТ** (форк Ф-2); `.harness/` на origin/main НЕТ (H-чекаут в CI создаётся шагами, не коммитом).
5. **996 (done)**: `workshop <проект>`, `project_workflow.sh`, `reserve_project_contract`, `mint_line --root`, `check_project_sources.sh` (gate на pre_critic/done), `--print-context`-шов. Приёмка владельца на ноутбуке (996 §«Приёмка владельца на ноутбуке») — основа приёмки (в) здесь.
6. **Канон источников**: решение 2330 — канон «включается только для нашего бэкенда»; для mob канона НЕ объявлено (форк Ф-1).
8. **Основания v2 (сверено живьём 2026-10-20)**: (а) оба стандарта существуют на origin/main Complior-back — `gh api repos/a3ka/Complior-back/contents/docs/ARCHITECTURE.md` → sha `70b6109f8c7f7fb4811c938a14c220fde232cfca`, `.../docs/CODING-STANDARDS.md` → sha `ed4aebed7c905844d7281072d154d7e3575c059d`; (б) 2030 §3 перечисляет оба файла среди «документов бэкенда» — в v1 они входили в 26 (priority 1); повышение до priority 0 меняет РАЗБИВКУ 16+10 → 18+8, не число путей; (в) канарейка дублей: канон «28 = 18 p0 + 10 p1» (оба файла и в p0, и в p1) на ПОЛНОМ честном мире (каждый файл объявлен один раз) → rc 1 `kanon-prioritet` на обоих стандартах («0, обязан 1») — структура двойного счёта принципиально неудовлетворима, профили с дублем путей не рассматриваются; (г) резолвер ПРИНИМАЕТ `contextPack` с полями строк `kind/path/roles/mandatory/why` по схеме 095 (замер: живые фикстуры `fixtures/profile_resolver/case_context_pack_yunit_sliyanie.sh`, алфавит `kind ∈ {map,rules,reuse}`; расшифровка в «Профили»).
7. **CI-семья харнесса (083/087/996-E, сверено живьём)**: `registry/ci-steps.tsv` — ЕДИНСТВЕННЫЙ источник шагов джобы ci (`step <key> <weight> <command>`, замкнутый алфавит), `package.json` — npm-ключ батареи, `.github/workflows/ci.yml` — ПРОИЗВОДНАЯ (`bash scripts/gen_ci_steps.sh --write`, сверка `--check`), паритет — `bash scripts/verify_ci_parity.sh` → rc0. Живой образец подключения семьи: 996-E и 110 (`step check:done-volny-110-family-selftest … npm run check:done-volny-110-family-selftest`, npm-ключ → `bash fixtures/workshop_project/done_volny_110/probe.sh`, вес 8 по замеру `time`). Проводка следует ЗА реализацией (996: «E ждёт сборку A–D»), иначе в CI красный шаг.

## Предмет и граница

Один наблюдаемый результат: **команда харнесса структурно проверяет подключение каждого из двух репозиториев проекта к режиму 996 одним прогоном по клону (`scripts/check_project_connection.sh --repo <клон>` → rc 0), а красная батарея этого требования предъявлена и держится в CI-семье харнесса.**

Части:
- (а) профили проекта в Complior-back и Complior-mob (файлы ниже) — доставляются PR-ом В РЕПОЗИТОРИЙ ПРОЕКТА, не в харнесс;
- (б) боль Н-168/Н-379 (ниже) — обоснование этапа 3 ROADMAP: отдельные сессии `./workshop <проект>` вместо одной общей;
- (в) приёмка: код-часть — батарея `fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh` (красная на базе, зелёная на модели) + реализация `scripts/check_project_connection.sh`; живая часть — прогон §«Приёмка владельца на ноутбуке» 996 первым бэкенд-контрактом — NOT_RUN в этом контракте, исполняется после реализации;
- (г) форма канонического remote — HTTPS-литерал (см. Существующее п.2), дверь gitw не меняется.

НЕ входит в 112: `tools/check_source_trace.py` и карта источников бэкенда (первый бэкенд-контракт, 2030 §3); отказ контракту без `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` в «## Источники» — предмет 115 (слово владельца 13:45; расширение sourceCanon-гейта 996, отдельный механизм); `ci-proekta` (следующий номер плана); изменение ролей/AGENTS.md; ослабление gitw/детектора; стандарт v1 §1 целиком (103); код backend/mobile; расширение схемы contextPack (данные — по действующей 095).

## Боль (измеренная)

- **Н-168** (NABLIUDENIA.md, ОТКРЫТО): один активный поток при доступных двух; ~15–20 мин простоя на переход, ~1 час за ночь. 112 — структурная половина того же класса: пока сессия одна, потоки трёх проектов сериализуются в одном контексте.
- **Новая боль (предложение текста — в докладе architect, в NABLIUDENIA.md заносит оркестратор)**: единая сессия держит все потоки и рестартится по порогу контекста. Числа: (1) рестарты сессии — 7 за окно 23:20–07:20 UTC 2026-10-19/20 (чекпойнт-коммиты HANDOFF 22:06, 01:11, 02:01, 02:30, 02:45, 04:20, 07:20; всего 13 чекпойнтов за 20:28–09:36; `git log --since=2026-10-19T20:00 --until=2026-10-20T10:30 -- HANDOFF.md`); (2) простой трёх потоков ~95 мин 07:55–09:30 UTC 2026-10-20 (источник: слово оркестратора + HANDOFF §ГДЕ МЫ 08:00 (коммит 07:53) «харнесс-слот: простой» → mint_line 112 в 09:36); (3) хвост боли на момент пачки: `python3 ops/server/user/orch-tablo` 10:09 UTC — «СТОИТ ПОТОК бэкенд: ни один предмет не в работе — 14 мин».

## Конструкция

### Профили проекта (литералы команд — из CI, живое чтение; носитель литералов — батарея, контракт не дублирует байты)

Complior-back `harness.project.json` (корень): `repoId=Complior-back`, `language=javascript` (требует P1), `projectLayer={version:1, profilePath:".harness/project-layer.json"}`, `workflowPaths` → `.harness/{contracts,verdicts,registry,fixtures}`, `state=".harness"`, `git.canonicalRemote="https://github.com/a3ka/Complior-back.git"`, `ci.workflow=".github/workflows/ci.yml"`, `sourceCanon` с приоритетами (v2): priority 0 — `docs/Complior_Backend_Architecture_v3_14_RU.md`, `docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml`, `migrations/001_core.sql … migrations/014_api_reads_migration_ledger.sql`, `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md` (оба стандарта подняты с priority 1 словом владельца 2026-10-20 ~13:45 — бэкенд пишется строго по структуре и стилю этих файлов); priority 1 — `AGENTS.md`, `STRUCTURE.md`, `docs/DATABASE.md`, `docs/RUNBOOK.md`, `docs/backend/PORT-PLAN.md`, `docs/backend/DONOR-INVENTORY.md`, `docs/backend/AUTH-AND-DB-DECISIONS.md`, `structure-policy.json` (в корне); `gate=["python3","tools/check_source_trace.py"]` (файл приходит первым бэкенд-контрактом; на структурную проверку подключения его отсутствие НЕ влияет — доступность гейта судит `check_project_sources.sh` на дверях 996). Перечень канона — ЛИТЕРАЛЬНЫЙ и ПОЛНЫЙ по 2030 §3: 26 источников (v2: 18 priority 0 + 8 priority 1), фактические пути сверены живьём по origin/main (новая структура — v2b, форк n112-v2-kanon-26 ОТВЕЧЕНО (А), слово консультанта 14:20/14:35): db/→migrations/ — 14, архитектурный документ и OpenAPI-контракт — в docs/, structure-policy.json — в корень, 17 путей меняют путь, состав/приоритеты неизменны; в §3 названы 001–013 — дереву верим: 14 миграций; существование обоих стандартов на origin — gh api, shas в Существующем п.8). Носитель перечня — оракул `fixtures/workshop_project/podklyuchenie_112/kanon_back_2030.sh`: сверяет доставленный профиль множеством путей И приоритетами, замкнутый алфавит `kanon-otsutstvuet/kanon-nepolnyj/kanon-lishnij/kanon-prioritet`; структурная проверка подключения полноту НЕ судит (generic).

`contextPack` профиля back (v2, слово владельца 13:45 п.2; грамматика — действующая схема 095, расширения нет): две строки — `{kind:"map", path:"docs/ARCHITECTURE.md", roles:"architect,implementer,reviewer,adversary", mandatory:true}` и `{kind:"rules", path:"docs/CODING-STANDARDS.md", roles:"architect,implementer,reviewer,adversary", mandatory:true}` (+ поле `why` — произвольная строка причины). Носитель литералов — мир `make_world back` батареи; контракт байты строк не дублирует. Профиль Complior-mob — БЕЗ contextPack-строк стандартов и БЕЗ этих источников (слово владельца: «подключить ТОЛЬКО для работы с бэкендом (не mob)»).

Команды профиля — каждая реальная команда их CI (источник — `tools/run_backend_ci.py` LANES и `.github/workflows/ci.yml`):

| ключ | литерал | происхождение (CI) |
|---|---|---|
| test | `npm --prefix backend test` | lane backend, шаг «npm test: unit, contract, logging, structure» |
| lint | `npm --prefix backend run lint` | lane backend, «lint: eslint + prettier» |
| typecheck | `node backend/scripts/gen-contracts.js --check` | lane backend, «производный контракт = корневой OpenAPI» (TS в репо нет — ближайшая реальная проверка типов контрактов; Ф-3) |
| build | `npm --prefix backend run smoke:image` | lane image, «docker build, non-root, liveness/readiness» |

Complior-mob `harness.project.json` (корень): `repoId=Complior-mob`, `language=typescript`, тот же `projectLayer`/`workflowPaths`/`state`, `git.canonicalRemote="https://github.com/a3ka/Complior-mob.git"`, `ci.workflow=".github/workflows/mobile.yml"`, БЕЗ `sourceCanon`: канон mob НЕ объявлен — 2330 «только для нашего бэкенда»; слово владельца 2026-10-20 («канон источников в каждом репозитории») расходится с 2330 — это форк Ф-1 К ВЛАДЕЛЬЦУ (см. NOT_RUN), здесь NOT_RUN и не изобретается. Команды (CI `mobile.yml` job quality, working-directory mobile):

| ключ | литерал | происхождение (CI) |
|---|---|---|
| test | `npm --prefix mobile test` | mobile.yml `- run: npm test` |
| lint | `npm --prefix mobile run lint` | mobile.yml `- run: npm run lint` |
| typecheck | `npm --prefix mobile run typecheck` | mobile.yml `- run: npm run typecheck` |
| build | `npm --prefix mobile run build` | скрипта build в mobile/package.json НЕТ — PR добавляет `"build": "expo export --platform web"` (Ф-2, продуктовое решение владельца) |

Слой проекта `.harness/project-layer.json` (оба репо): `{schemaVersion:1, version:"1", projectId:"<repoId>", workspaceId:"<repoId>"}` — identity-минимум, defaults-слой отсутствует (schema: project:defaults optional).

PR в каждый репозиторий проекта (доставляет implementer-зона проекта; **merge продуктового PR — владелец**): `harness.project.json`, `.harness/project-layer.json`, каталоги-скелет `.harness/{contracts,verdicts,registry,fixtures}/` (+ пустой `registry/plan.tsv` при необходимости первого контракта), для mob — строка build в `mobile/package.json`. Файлы внутри Complior-back/Complior-mob — НЕ зона харнесса.

### Проверка подключения — scripts/check_project_connection.sh (зона implementer)

CLI: `--repo <R>`; rc 0 — подключение структурно цело, 1 — ≥1 именованный отказ, 2 — нечем/неправильный вызов. Единый источник грамматики — действующий `profile_resolver.sh` (второго парсера профиля НЕТ, норма 996); проверка читает его эффективный вывод и по умолчанию экспортирует `HARNESS_PROJECT_LAYER_ROOT=$R` (образец — `check_project_standard.sh:48`). Алфавит причин — единственный, батарея несёт его побайтово:

- `profil` — резолвер отказал (грамматика, слой, `ci.workflow`-файл, пустое значение команды);
- `workflowPaths` — каждый из 4 путей и `state` (умолчание `.harness`): не абсолютный, канонизируется ВНУТРЬ репо (без `..`-побега, без симлинк-звена наружу — `cd && pwd -P` + префикс-проверка, образец `check_project_standard.sh:76–83`), существует как каталог; проверка `state` — самостоятельная ветвь того же алфавита: отказ `state` вне репо обязан звучать при СОХРАННЫХ слое и workflow-каталогах (инвариант; не выводится из их наличия) И при СУЩЕСТВУЮЩЕЙ внешней цели побега: все три названные формы (`..`, симлинк-звено, абсолютный путь) предъявлены клетками D14/D16/D17 — отказ определяется каноническим положением, не отсутствием цели (арбитраж 112, П-1…П-3);
- `kanon-remote` — эффективный `git.canonicalRemote` БУКВАЛЬНО равен `git remote get-url origin` клона;
- `komandy` — каждая из 4 команд: непустая, не `true`, и реальна в дереве: семейство `npm [--prefix D] run <s>|test` → скрипт `s` есть в `D/package.json`; семейство `node|python3 <файл>` → файл есть в дереве; прочие формы — отказ (закрытый набор семейств);
- `source-canon` — каждый `sources[].path` существует в дереве (относительный, не абсолютный); грамматика юнита — резолвер. Полнота перечня — НЕ эта ветвь: существование объявленных ≠ доставленный канон; полноту и приоритеты судит отдельный литеральный оракул `kanon_back_2030.sh` (2030 §3, см. Профили и приёмку п.5), проверка подключения остаётся generic (знаний Complior не несёт);

### P1 — алфавит language (зона implementer)

`scripts/profile_resolver.sh` строки 546–548: case-алфавит дополняется `javascript`. Ничего больше в резолвере не меняется; регрессия — `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → rc 0 и `bash fixtures/_krasnye_054.sh` → rc 0 после правки.

## Клетки (носитель — `fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh`; счёт из кода: 23 = 3 модели + 20 обманок; соответствие входа и ветви отказа держится кодом диспетчеризации батареи — Н-39; здесь — инварианты и литеральные rc/причины)

| клетка | мир/мутация | ожидание |
|---|---|---|
| M1-back-model | честный профиль back (`language=javascript`) | rc 0 (на базе красна дважды: нет проверки + алфавит P1) |
| M2-mob-model | честный профиль mob | rc 0 |
| K1-kanon-polnyj | мир back с ПОЛНЫМ перечнем 2030 §3 (26 источников; v2 — оба стандарта priority 0, 18+8) против оракула kanon_back_2030.sh | rc 0 (перечень совпал множеством путей и приоритетами) |
| D1-pustaja-komanda | `commands.test=""` | rc 1, `profil` (пустое значение ловит резолвер) |
| D2-komanda-true | `commands.lint="true"` | rc 1, `komandy` |
| D3-skripta-net | `npm --prefix backend run net-takoj-skript` | rc 1, `komandy` (скрипта нет в package.json — «команда не из CI») |
| D4-chuzoj-remote | canonicalRemote = URL Complior-mob при origin Complior-back | rc 1, `kanon-remote` |
| D5-put-vne-repo | `workflowPaths.verdicts` = `../<внешний каталог>`, внешняя цель СУЩЕСТВУЕТ (арбитраж 112 П-1) | rc 1, `workflowPaths` |
| D6-symlink-pobeg | `.harness/contracts` → симлинк наружу | rc 1, `workflowPaths` |
| D7-net-workflow | `ci.workflow=".github/workflows/net-takogo.yml"` | rc 1, `profil` (файл — резолвер) |
| D8-net-sostojanija | `.harness/` удалён целиком | rc 1, `profil` (файл слоя жил в state) |
| D9-prioritet-bool | `sourceCanon.sources[0].priority=true` | rc 1, `profil` (грамматика — резолвер) |
| D10-istochnik-net | `sources[1].path="docs/NET-TAKOGO.md"` | rc 1, `source-canon` |
| D13-net-kataloga-kontr | удалён только `.harness/contracts` | rc 1, `workflowPaths` |
| D14-state-vne-repo | `workflowPaths.state` = `../<внешний каталог>` — внешняя цель СУЩЕСТВУЕТ (П-1), слой и workflow-каталоги сохраны | rc 1, `workflowPaths` (state — независимая проверка: отказ по каноническому положению, не по отсутствию цели) |
| D16-state-symlink-zveno | симлинк-ЗВЕНО в середине пути: `lnk` → внешний каталог, `workflowPaths.state="lnk/state"`, внешняя цель существует (П-2) | rc 1, `workflowPaths` (форма «без симлинк-звена наружу») |
| D17-state-absoljutnyj | `workflowPaths.state` = абсолютный путь к СУЩЕСТВУЮЩЕМУ внешнему каталогу (П-3) | rc 1, `workflowPaths` (форма «не абсолютный»; абсолютный внутрь репо отдельной клеткой не предъявляется — отвергается как форма) |
| D11-mob-bez-typecheck | del `.commands.typecheck` | rc 1, `komandy` (резолвер пустой ключ пропускает — замер) |
| D12-mob-ssh-remote | canonicalRemote ssh:// при HTTPS origin | rc 1, `kanon-remote` |
| D15-kanon-nepolnyj | в sourceCanon оставлены только Architecture + AGENTS (контрмодель критика Б3) | rc 1, `kanon-nepolnyj` (оракул kanon-2030) |
| D18-kanon-lishnij | полный перечень 2030 §3 + объявлен `docs/UNAPPROVED.md` (priority 0) | rc 1, `kanon-lishnij` (оракул kanon-2030; ветвь — множество путей, одного priority достаточно — П-4) |
| D19-kanon-prioritet | подмена приоритетов в полном перечне: `docs/Complior_Backend_Architecture_v3_14_RU.md` → 1, `AGENTS.md` → 0 (П-5) | rc 1, `kanon-prioritet` (оракул kanon-2030; подмена, не выход из грамматики — D9 остаётся клеткой резолвера) |
| D20-standarty-kanon-nepolnyj | профиль back БЕЗ обоих стандартов: `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` не объявлены, прочие 24 источника доставлены (v2, слово владельца 13:45) | rc 1, `kanon-nepolnyj` (оракул kanon-2030; красна и против мира, где файлы ЕСТЬ в дереве, но не объявлены в каноне) |

Обманные миры подключения back несут `language=typescript`, чтобы отказ обманки определялся её собственной мутацией, а не останавливался на `profil` алфавита до закрытия P1 (M1 остаётся javascript — клетка живого разрыва). Полный прогон батареи несёт три анти-плацебо: неизвестная клетка → rc 2; state-слепая контрмодель (модель-эталон минус блок проверки state, вырезается по sentinels STATE-112-BEG/END с восстановлением TOOLS-якоря) обязана вернуть rc 0 на входах D14 и D16 (внешние цели обманок существуют) → расхождение на каждом; клетки канона двунаправленно ловят оракул-заглушку: K1 — «всё красно», D15/D18/D19/D20 — «всё зелено». Модель-эталон `model_check_connection.sh` — эталон шва, не продукт.

## Приёмочный критерий (команды, rc)

1. `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh` → сегодня rc 1: 19 клеток красных `НЕТ_ПРОВЕРКИ` (продукт не реализован) + 5 зелёных клеток оракула (K1, D15, D18, D19, D20 — оракул лежит в батарее; замер v2: «ИТОГ 112: клеток 23, зелёных 5, красных 18, rc=1»); после реализации implementer → rc 0 («ИТОГ 112: клеток 23, зелёных 23, красных 0»).
2. `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh --model` → сегодня rc 1, ровно ОДНА красная (M1, причина — алфавит language, живой разрыв P1); после P1 → rc 0 (23/23). Замер v2: 22 зелёных + 1 красная (M1, `значение вне алфавита: language: javascript`); contextPack в мире M1 резолвером принят (замер v2 — зелёные D-клетки против модели гоняют резолвер до конца).
3. `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh --cell net-takoj-kletki` → rc 2 (анти-плацебо диспетчеризации; замер этой сессии: rc 2).
4. Красное предъявление проверки state против state-слепой контрмодели (правило 3) — входит в полный прогон п.1 автоматически; вручную: `sed -e '/STATE-112-BEG/,/STATE-112-END/d' -e 's|^TOOLS=.*|TOOLS=<корень харнесса>|' fixtures/workshop_project/podklyuchenie_112/model_check_connection.sh > /tmp/stab-112.sh && PODKLJUCHENIE_112_CHECKER=/tmp/stab-112.sh bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh --cell D14-state-vne-repo` → rc 1: контрмодель возвращает rc 0 на входе D14 (слой и каталоги сохранны, внешняя цель существует), клетка обязана дать расхождение; то же на D16-state-symlink-zveno. Замер круга 3 (арбитраж): ФАКТ rc=0 у контрмодели на D14 и D16 → расхождение поймано полным прогоном.
5. Оракул полноты канона (2030 §3): клетка D15 (в sourceCanon оставлены только Architecture + AGENTS) → rc 1, причина `kanon-nepolnyj`; клетка K1 (полный перечень 26 источников; v2 — 18 priority 0 + 8 priority 1) → rc 0; клетка D18 (полный перечень + `docs/UNAPPROVED.md` priority 0) → rc 1, причина `kanon-lishnij`; клетка D19 (Architecture → 1, AGENTS → 0) → rc 1, причина `kanon-prioritet`; клетка D20 (полный перечень минус оба стандарта) → rc 1, причина `kanon-nepolnyj` (v2). После merge продуктового PR (владелец): `bash fixtures/workshop_project/podklyuchenie_112/kanon_back_2030.sh --repo <клон Complior-back>` → rc 0 (живой прогон; до merge — NOT_RUN). Оракул на witness-canon критика (`/tmp/dev-harness-verify/Critic112r2/witness-canon/`) остаётся rc 1 с `kanon-lishnij` (замер v2: `kanon-lishnij: docs/UNAPPROVED.md` + `kanon-prioritet` на обоих стандартах — witness несёт их в priority 1 старины v1; инвариант «лишний источник пойман» сохранён).
6. CI-проводка батареи (implementer, после реализации): `jq -e '.scripts."check:podkljuchenie-112-family-selftest" == "bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh"' package.json` → rc 0; `awk -F'\t' '$1=="step" && $2=="check:podkljuchenie-112-family-selftest" && $4=="bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh"{f=1} END{exit !f}' registry/ci-steps.tsv` → rc 0; `bash scripts/gen_ci_steps.sh --write && bash scripts/gen_ci_steps.sh --check` → rc 0; `bash scripts/verify_ci_parity.sh` → rc 0. Красное предъявление «батарея не подключена» — сегодня (замер этой сессии): jq-проверка rc 1, awk-проверка rc 1 (ключа/строки нет); после проводки те же команды обязаны быть rc 0.
7. После P1: `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver` → rc 0; `bash fixtures/_krasnye_054.sh` → rc 0.
8. После merge продуктовых PR (владелец): `bash scripts/check_project_connection.sh --repo <клон Complior-back>` и `--repo <клон Complior-mob>` → rc 0 каждый (живой прогон на станции; до merge — NOT_RUN).
9. `bash scripts/pre_critic.sh --repo . contracts/112-podklyuchenie-proekta.md` → rc 0 до критика.

## NOT_RUN (граница этого контракта)

- Живой цикл приёмки 996 (§«Приёмка владельца на ноутбуке»): reserve_project_contract → mint_line → architect → критик → freeze → implementer → CI проекта на SHA → адверсарий → ревьюер → done-тег В РЕПОЗИТОРИИ ПРОЕКТА — исполняется на станции/ноутбуке ПОСЛЕ реализации 112 и merge продуктовых PR; здесь зафиксирован как следующий шаг, не как зелёный.
- `tools/check_source_trace.py` (гейт сверки) — первый бэкенд-контракт; его отсутствие НЕ краснит структурную проверку подключения (доступность гейта — `check_project_sources.sh` на дверях 996).
- Push продуктовых веток и merge PR — консультант/владелец (ssh с станции к Complior-back не работает).
- Канон для Complior-mob: решение 2330 — канон «только для нашего бэкенда»; слово владельца 2026-10-20 называет «канон источников в каждом репозитории» — расхождение Решено форком Ф-1 К ВЛАДЕЛЬЦУ (продуктовое решение, не инженерное): оракул kanon_back_2030.sh для mob NOT_RUN, профиль mob доставляется без sourceCanon, расширение перечня на mob — только по прямому слову владельца отдельным предметом.
- Владельческая приёмка подключения (docs/owner/2026-10-20-podkljuchenie-proekta.md: первый backend-контракт полным циклом 996 до done-тега в репозитории проекта) остаётся ОТКРЫТЫМ этапом владельца: done кодовой части 112 НЕ является выполнением полного подключения; перенос/закрытие этого этапа — не инженерная санкция.

## Зоны и раздача

ЗОНА architect: contracts/112-podklyuchenie-proekta.md fixtures/workshop_project/podklyuchenie_112/
ЗОНА implementer: scripts/check_project_connection.sh scripts/profile_resolver.sh registry/ci-steps.tsv package.json .github/workflows/ci.yml
Зоны судей не заявляются (прецедент 996/110): вердикты критика/адверсария/ревьюера кладутся ролями в verdicts/critic/, verdicts/adversary/, verdicts/review/ (роль-канон 011/996); чтение предмета сессией судьи write-зоны не требует.

Правка implementer в `scripts/profile_resolver.sh` — ТОЛЬКО алфавит `language` (строки 546–548, +`javascript`); прочие правки резолвера — вне зоны. CI-проводка батареи — implementer, ЗА реализацией (образец 996-E: иначе в CI красный шаг): npm-ключ `check:podkljuchenie-112-family-selftest` = `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh` в package.json, step-строка того же ключа в registry/ci-steps.tsv (команда `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh`, вес 7 — перемер v2 `time` полного прогона: 1.7 с, 23 клетки (v1 круг 3 по арбитражу: 6.9 с, 22 клетки)), затем `bash scripts/gen_ci_steps.sh --write` (ci.yml — производная) и сверки приёмки п.6. Продуктовые PR (профили, `.harness/`, build-скрипт mob в Complior-back/Complior-mob) — НЕ зона харнесса: это отдельная проектная раздача режима 996; bootstrap — первый PR скелета (профиль+слой+каталоги) собирает консультант проектной сессии по литералам этого контракта (push продуктовых веток — консультант: ssh с станции к Complior-back не работает, HTTPS; **merge продуктового PR — владелец**); последующие контракты проекта — полным циклом 996 в реестре проекта (`mint_line --root`), не харнесс-раздачей.

ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/podklyuchenie_112/ — 996 новая подсемья workshop_project, прежние фикстуры не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_project_connection.sh — 112 новый файл, не пересекается с 996-пакетами
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 054 только arm-дополнение алфавита language (строки 546–548), грамматика/schema_levels не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 996 только arm-дополнение алфавита language, регрессии после правки: parsing_hygiene_battery/run_battery.sh profile_resolver и _krasnye_054.sh, обе rc 0
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 083 добавить только step-строку check:podkljuchenie-112-family-selftest; lanes/шарды/прочие step-строки не меняются
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 996 добавить только step-строку батареи 112; прежние step-строки сохраняются
ПЕРЕСЕЧЕНИЕ implementer: package.json — 011 добавить только ключ check:podkljuchenie-112-family-selftest; прежние команды сохраняются
ПЕРЕСЕЧЕНИЕ implementer: package.json — 015 добавить только ключ check:podkljuchenie-112-family-selftest; прежние команды сохраняются
ПЕРЕСЕЧЕНИЕ implementer: package.json — 996 добавить только ключ check:podkljuchenie-112-family-selftest; прежние команды сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 011 производная регенерация gen_ci_steps.sh --write после записи реестра; прежние шаги сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 015 производная регенерация после записи реестра; прежние шаги сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 994 производная регенерация после записи реестра; прежние шаги сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 997 производная регенерация после записи реестра; прежние шаги сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 998 производная регенерация после записи реестра; шаг 998 сохраняется
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 996 производная регенерация после записи реестра; прежние шаги сохраняются

## ПРОВОДКА

ПРОВОДКА-ЭНФОРСМЕНТ: `scripts/check_project_connection.sh` — гард для чужого ввода (профили внешних репозиториев): замкнутый алфавит причин (5 имён выше), литеральные untrusted-untrusted сравнения (kanon-remote — равенство целых строк, норма-класс 037), единственный источник грамматики — действующий резолвер (второго парсера нет), self-application — батарея `red_podkljuchenie_112.sh --model` (прогон против модели-эталона, зелёная после P1). Поведенческих норм для ролей 112 не вводит (канон/изоляция ролей — 996, заморожено).
ПРОВОДКА-ЭНФОРСМЕНТ: `fixtures/workshop_project/podklyuchenie_112/kanon_back_2030.sh` — гард doc-config результата (доставленный профиль — чужой ввод): замкнутый алфавит причин (`kanon-otsutstvuet/kanon-nepolnyj/kanon-lishnij/kanon-prioritet`), литеральное сравнение множеств путей и приоритетов с перечнем 2030 §3 (единственный носитель перечня — этот оракул, дублей нет), self-application — клетки K1/D15/D18/D19/D20 полной батареи (прогон).

## Модель угроз

ЗАЩИЩАЕТ:
- от профиля, объявляющего чужой origin (канон ≠ фактический remote клона);
- от пустых/маскированных (`true`) и нереальных команд (скрипта нет в package.json, файла нет в дереве);
- от путей workflow-каталогов и state, выводящих наружу репо (`..`, симлинк-звено);
- от канона источников с несуществующими файлами;
- от доставки неполного или разбавленного backend-канона: оракул `kanon_back_2030.sh` сверяет множество путей и приоритеты литерально против перечня 2030 §3 (26 источников; v2 — оба стандарта priority 0); ветвь `kanon-lishnij` предъявлена красной (D18), приоритеты — D19, отсутствие обоих стандартов — D20 (v2).
- от профиля вне грамматики резолвера (включая отсутствие файла слоя и ci.workflow).

НЕ ЗАЩИЩАЕТ:
- от злонамеренного владельца репо: профиль и origin задаёт сам клон — это проверка согласованности конфигурации, не доказательство идентичности репозитория;
- от недоступности гейта канона и его дефектов — двери 996 (`check_project_sources.sh`), отдельный предмет;
- от семантической верности перевода источников в карту — роли (architect/критик/адверсарий/ревьюер), 2330;
- от дрейфа профиля после merge — следующая проверка перечитывает дерево.

## Демаркация

Конформный мир: git-репозиторий с origin, `harness.project.json` + файл слоя по грамматике резолвера, workflow-каталоги и state внутри, команды семейств npm/node/python3. Конформный профиль back несёт полный перечень канона 2030 §3 (26 источников; v2 — оба стандарта priority 0: 18+8) и contextPack-строки обоих стандартов (mandatory, роли architect/implementer/reviewer/adversary), mob — без sourceCanon и без contextPack-строк стандартов (Ф-1). Временные корни миров меняются; валидный контрпример — расхождение на входе объявленной грамматики, инвариантное к именам. Ожидания клеток — литералы в батарее (Н-351), не вычисляются кодом продукта.
