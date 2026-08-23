# Контракт 007 — быстрый+надёжный CI-гейт v2

Номер выдан механизмом: `next_id.sh CONTRACT` → 007, тег `id/CONTRACT/007`. Предмет — решение
владельца (2026-08-23): закрыть измеренную цену Н-41/Н-45 — CI гонит ПОЛНЫЙ анти-плацебо (15–20
мин) на КАЖДЫЙ push, включая доки/вердикты (0 барьеров), плюс `check_metering` флейкует зелёный
контроль под контеншеном раннера. Разведка `agent://GateScout` дала факты: доминанта времени —
`check:antiplacebo`; 9 из 14 барьеров читают ДАННЫЕ (вне модели `scope_select`) и БЫСТРЫЕ; корень
флейка — глобальный `free_port`-скан (60 портов/прогон, без per-fixture изоляции).

Два НЕЗАВИСИМЫХ среза, оба одобрены владельцем «по рекомендации»:

## Срез 1 — Scoped CI-гейт (зона implementer)

`ci.yml` гонит анти-плацебо через `verify_antiplacebo --changed ${{ github.event.before }}`.
Двухъярусно, ИНАЧЕ ложный зелёный на барьерах-данных:
- **Ярус A — всегда:** барьеры, чей вход — репо-данные вне модели `scope_select` (грамматика
  «читает данные»). Они БЫСТРЫЕ; гоняются на КАЖДОМ прогоне независимо от диффа.
- **Ярус B — scoped:** медленные КОД-барьеры (`check_metering`, `check_scope_select`,
  `check_scoped_run`) — только когда задет их код-под-тестом.
- **Fail-safe:** нерезолвимый/пустой base (первый push, force-push, `000…0`) → ПОЛНЫЙ прогон.
- **Код возврата:** `--changed` с резолвимым base и пустой выборкой яруса B → exit **0**
  (доки не краснят CI); `MODE`/маркер на stderr различает scoped от needs-full. Полный прогон
  (fail-safe) сохраняет прежний код по результату.

## Срез 2 — De-flake `check_metering` (зона architect)

`check_metering` берёт порты БЕЗ глобального скана: OS-назначаемый эфемерный порт (bind `:0`,
прокси РЕПОРТИТ назначенный порт) — атомарно, без TOCTOU. Устраняет коллизии 60 портов под
контеншеном (Н-45). Healthz остаётся, но старт не зависит от угадывания свободного порта.

## Зоны

ЗОНА implementer: scripts/verify_antiplacebo.sh scripts/scope_select.sh .github/workflows/ci.yml package.json config/ci_parity_exceptions.txt
ЗОНА architect: scripts/check_metering.sh fixtures/check_metering/ scripts/check_scoped_run.sh fixtures/check_scoped_run/ scripts/proxy/ config/metering.json NABLIUDENIA.md HANDOFF.md contracts/007-scoped-ci-i-deflake-metering.md

Связность по «предмет ↔ проверка»: implementer владеет ПРЕДМЕТОМ среза 1 (проводка `--changed`,
коды возврата). Архитектор владеет ПРОВЕРКОЙ обоих срезов И предметом среза 2 (`check_metering`
и его прокси — его зона по 005): барьеры приёмки `check_scoped_run.sh` (поведение scoped-CI) и
`check_metering.sh` (изоляция портов), их фикстуры — красными ДО круга критика.

## Приёмочный критерий — КРАСНЫЕ ТЕСТЫ (предъявлены красными ДО критика)

**Срез 1 — новые ветви `check_scoped_run.sh` (тир-2, гоняют игрушечный `verify_antiplacebo`;
переиспользуют `build_toy`/`run_va`/`has`):**
- (ц/ц2/ц3) FAIL-SAFE — нерезолвимый base ВО ВСЕХ формах → ПОЛНЫЙ прогон, exit **0**: (ц) сорок
  нулей, (ц2) ПУСТОЙ base, (ц3) нерезолвимый НЕНУЛЕВОЙ SHA. Три формы, не спецкейс нулей.
  Красное против текущего exit 2.
- (ч/ч2) DOC-ONLY — резолвимый base, 0 задетых → exit **0**, барьеры НЕ гонялись: (ч) правка
  `README.md`, (ч2) правка НЕ-README пути (`notes.txt`). Две формы, не спецкейс README.
  Красное против текущего exit 2.
- (ci) ПРОВОДКА — `.github/workflows/ci.yml` гонит анти-плацебо scoped: строка шага несёт
  `--changed ${{ github.event.before }}`. Красное против текущего `npm run check:antiplacebo`
  без `--changed`. Строка `github.event.before` у `check:no-rewrite` НЕ считается — регэксп
  привязан к строке с `antiplacebo`.
- (маркер) ц/ц2/ц3 ждут `MODE: full` в выводе, ч/ч2 — `MODE: none`: потребитель обязан ПЕЧАТАТЬ
  различение (пин ниже), не только вернуть верный код.

НЕ дублируем: barrier-код → выбран ровно он — держит существующая ветвь (л). Ярус A
(барьеры-данных всегда) — ОТДЕЛЬНЫЕ шаги `ci.yml`; сужается только шаг 5 `check:antiplacebo`,
сохранность держит `check:ci-parity`, не новый барьер.

**Срез 2 — режим `--port0` в `check_metering.sh` (миграция НОРМАЛЬНОГО пути, ДЕТЕРМИНИСТИЧНО):**
- (p0.gen) `gen_config` эмитит `"port": 0` (OS-эфемерный), а не free_port-скан.
- (p0.up) ШТАТНЫЙ `proxy_up` на `port:0` поднимает прокси, читает репортный порт из
  `<data_dir>/.actual_port`, переписывает `cfg.port` на фактический, healthz на нём 200.
- (p0.conc) ДВА конкурентных `port:0` прокси → РАЗНЫЕ OS-эфемерные порты, оба healthz (фикс-
  константа дала бы коллизию — доказывает OS-назначение, не самовыбор).
- (p0.src) БЕЛОЩИКОВО: `metering_proxy.ts` выводит `.actual_port` из `server.address()` (OS-порт),
  без собственного порто-скана. Чёрный ящик не отличает `listen(0)` от самовыбора (арбитраж
  krasnye-proby-granica-primera п.3) — греп исходника, конвенция к1/к2. Обфускация → адверсарию.
  Все четыре красны против текущего (gen_config сканит; proxy_up healthz-поллит порт 0 → die;
  прокси не пишет `.actual_port` и не зовёт `server.address()`). Миграция НЕ ломает default 15 ветвей.

**Регресс (существующее, зелёным):** `check_metering` а-я=0; `check_scope_select` а-щ=0;
`verify_antiplacebo` full=0; `check:ci-parity`=0; полный CI на чистом ubuntu зелёный.

## Приёмка-проводка (npm/CI — раздаётся ПАРАЛЛЕЛЬНО кругам критика, Н-38)

- `npm run check:scoped-run` (ветви ц/ц2/ц3/ч/ч2/ci) → 0.
- `npm run check:metering --port0` (p0.gen/p0.up/p0.conc) → 0; `npm run check:metering` (default 15) → 0.
- `npm run check:ci-parity` → 0 (каждая `run:`-команда CI имеет пункт приёмки).
- Полный CI-прогон на чистом чекауте зелёный (гейт 4б, `check_ci_gate`).

Статуса задач нет: контракт замораживается побайтово, ход работ — в `HANDOFF.md`.

## Пины протокола (закрывают незаполненные требования круга 1 критика):
- Различение живёт в ПОТРЕБИТЕЛЕ `verify_antiplacebo`, НЕ в `scope_select`: последний остаётся с
  `MODE: needs-full` (ФРОЗЕННЫЙ `check_scope_select` 006 не трогаем). Получив needs-full,
  `verify_antiplacebo` САМ проверяет резолвимость base: нерезолвимый/пустой → печатает `MODE: full`,
  полный прогон, exit 0; резолвимый с 0 задетых → печатает `MODE: none`, exit 0, 0 прогонов.
  Маркер наблюдаем (ц/ц2/ц3 ждут `MODE: full`, ч/ч2 — `MODE: none`). Предмет среза 1 (implementer).
- Репорт порта прокси при bind `:0`: файл `<data_dir>/.actual_port` (десятичный порт);
  `proxy_up` ждёт его и переписывает `cfg.port`. Предмет среза 2 (architect).
- Ярус B (сужаемые код-барьеры) = `check_metering`, `check_scope_select`, `check_scoped_run`
  (их вход — код-под-тестом в модели `scope_select`). Ярус A (всегда) = прочие шаги `ci.yml`
  (`check:ids`/`ceilings`/`decisions`/`charter`/`contract-frozen`/`zones`/`skills`/`approval`/
  `gen`/`metering:selftest`/`no-rewrite`/`protected`/дриллы): их вход — репо-данные вне модели.
