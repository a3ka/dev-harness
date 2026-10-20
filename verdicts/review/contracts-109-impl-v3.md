FAIL
OBJECT=8aca71aac5509abb0b1d825d3c808115a2648e88

Суд реализации 109 (CMP-BCK-004), круг 3. Reviewer: Rev109r3. Находки в формате reslop лежат в `review.md`
рядом (status: ready). Блокер один — Б-LINT: регресс required-lane `backend`, обход наблюдаем. Б2′ круга 2 ЗАКРЫТ.
Советы: С-ЯКОРЬ, С-LANE, С11, С-ROW5, С6″, С12′, С1/С7/С9/С10. С5′ переоткрыт (входит в С-ЯКОРЬ).
Контракт: frozen/contracts/109/1 → b91be196514191953d9c8dba19326021ecb0ba32. Батарея: wip/109/architect @ d8e3fc19f.
Копии лежат под /tmp/dev-harness-verify/Rev109r3/:
- back — cp -a клона Impl109;
- cC — чистый git clone back;
- hw/hf/h2 — git archive d8e3fc19f / frozen / 4fe53c495;
- hclean — clone H на frozen-теге;
- mut1/mut2/cl55 — мутанты и рефакторинг.

## Неизменность замороженного (ПРИЁМКА-СУДЬИ v2)

    git -C H rev-parse frozen/contracts/109/1^{commit} → b91be196…; wip/109/architect → d8e3fc19f (= заявленный)
    git -C H diff --stat frozen…^{commit} d8e3fc19f -- contracts/109-cmp-bck-004-stend-evidence.md → пусто, rc 0
    git -C H diff --stat frozen…^{commit} HEAD     -- contracts/109-cmp-bck-004-stend-evidence.md → пусто, rc 0
    git -C H diff 4fe53c495 d8e3fc19f -- …/stend_109/probe.py → +758/−31, других файлов 109 нет. Удалённые строки:
      badstr (одним блоком) → разбит на поштучные at_never/at_ok/at_noniso/rpo_*/rto_* (строже);
      ledger count → сравнение содержимого строк ledger (строже); DRILL_HONEST_VALIDATION переякорён под код C.
    Критерий не ослаблен. Счёт моей мерой (count.py — ast по литералу CASES): hw 50, hf 29.

## Область правки

    python3 zone.py back   (ЗОНА implementer — регуляркой из frozen-блоба, дословно)
      9d960a05..HEAD paths 9 → outside_zone []
      d1cece28..HEAD paths 5: FILES.sha256, backend/scripts/drill-measure.js, backend/tests/helpers/harness.js,
                              backend/tests/integration/harness.test.js, tools/run_backend_ci.py → outside_zone []
      git diff --quiet 9d960a05 HEAD -- backend/server health.test.js integration/migrations helpers/pg18.js infra db server
                                        evidence tests/run_sql_3_9_native.py backend/package-lock.json → rc_untouched 0
      removed lines pkg/ci: только замена строки test:integration (добавлена запятая) и старой строки needs (+stend109). Чужие шаги не тронуты.
    Коммиты 68cee4a / 75802a2 / 8aca71a: автор implementer@dev-harness.local, во всех ссылка на 109.
    Атомарность: одна задача — цепочка своих коммитов. OK.

## Сырые прогоны

Батарея (строки 2–3):

    PY hw/…/probe.py --repo back --out out-wip   → rc_wip=0; control_green true; 13 фактов True; cases 50: 50 REJECTED_EXACT
      моя мера (count.py по raw.json): verdict Counter {REJECTED_EXACT: 50}, depends==[target] 50, facts {'True': 13}
      ASYNC_TUPLE_GUARD: «прибытий 1; PRESET в файле 2; MARKER 1; runtime_role ['stend109_hc']»
      LANE_HYGIENE_GUARD: «чистый checkout: lane rc=0 | грязный: lane rc=1»; STEND_UP_GUARD: up rc=0, ledger 14, повтор неизменен
    PY hf/…/probe.py --repo back                → rc_hf_back=0; 29/29 REJECTED_EXACT, depends==[target] 29, 5 фактов True

Б2′: мутанты «пустой предмет» (mutant.py, правка только harness.js):

    mut1 = форма круга 2 (Rev109r2/mutant.py на 8aca71a): dbBefore/dbAfter/httpResponse — константы
    mut2 = честная форма: read-only отказ сохранён, вместо pg.connect — константа NOT_RUN «ECONNREFUSED», вместо TCP — константа 200
    PY hw --repo mut1 → rc_hw_mut1=1; control_green False; ASYNC_TUPLE_GUARD False «прибытий 0; PRESET 0 …»,
                        ASYNC_PII_GUARD False «тело ответа потеряно; Set-Cookie-массив не сохранён»
    PY hw --repo mut2 → rc_hw_mut2=1; то же + STEND_UP_GUARD False (up rc=1 — в это время шли параллельные стенды
                        чужих судей, harness к compose отношения не имеет [INFERENCE: конкуренция docker])
    PY hf --repo mut2 → rc_hf_mut2=0; 29/29, control_green True   ← frozen-батарея (её исполняет CI) пустой предмет не ловит (С11)

Строка 5 (row5.sh, одноразовый PG18 rev109r3pg 127.0.0.1:55443; готовность — psql select 1):

    npm --prefix back/backend ci                → rc_npm_ci=0
    test:integration C #1 / #2                  → rc 0 / rc 0; tests 31, pass 31, fail 0 (оба)
    evidence/ до = после                        → fda57b7ddb323284 = fda57b7ddb323284
    test:integration mut1                       → rc 1; 30/31 (✖ «не-SELECT отвергается ДО подключения»: причина не read-only)
    test:integration mut2                       → rc 0; 31/31   ← строка 5 сама пустой предмет не ловит (С-ROW5)
    БД остановлена: test:integration C          → rc 1; tests 32, pass 12, fail 20

Строка 4: `backend/compose.dev.yml`, `role-bootstrap.js`, `package.json`, `ci.yml` с d1cece28 не менялись
(`git diff --quiet d1cece28 HEAD -- …` → rc 0). Замер строки 4 из круга 2 (Rev109r2/verdict.md) остаётся в силе.
Живой подъём на C повторён фактом STEND_UP_GUARD в out-wip: up rc=0, ledger 14, роль hc_synthetic_only
не superuser, повтор rc=0, содержимое ledger неизменно.

Регресс лейнов и агрегата:

    cC: python3 tools/verify_handoff.py         → PASS_STATIC, all_manifest_files_and_hashes PASS, rc_verify_handoff=0
    cC: COMPLIOR_STEND109_H_CHECKOUT=hclean run_backend_ci.py --local → rc_local=1. Красные строки:
      [backend] FAIL версия Node (станция v26.5.1; в круге 2 то же на B — окружение)
      [backend] FAIL rc=1 lint: eslint + prettier                    ← РЕГРЕСС (Б-LINT)
      [package] FAIL validate_invitation_target «No module named 'pypdf'» (окружение, как в круге 2)
      [historical] FAIL ×2 — в cC не было server/node_modules; после `npm --prefix server ci`: --lane historical → PASS ×2, rc_hist=0
      всё остальное PASS, в т.ч. [postgres] test:integration, [image] smoke:image, [package] generate_derived/verify_handoff,
      [stend109] PASS rc=0 (frozen-батарея 29/29)
    lint.sh (cC, checkout по коммитам): 9d960a05 rc=0 (0) | d1cece28 rc=0 (0) | 68cee4a rc=1 (4) | 75802a2 rc=1 (3) | 8aca71a rc=1 (3)
      8aca71a: harness.js:116:7 и :123:7 prefer-const; harness.test.js:30:7 no-unused-vars 'crypto'
    ci.yml:33 job backend → `run_backend_ci.py --lane backend` (шаг lint), backend ∈ required.needs
    --aggregate (Rev109r2/needs-*.json): all success → rc 0; без stend109 → rc 1 «нет обязательных lanes: stend109»;
      stend109 failure → rc 1

Lane-гигиена (lane.sh, H — клоны на frozen-теге, probe.py := STUB sys.exit(0)):

    грязное дерево (" M probe.py")              → lane_dirty_rc=1 «рабочее дерево не чистое»
    assume-unchanged + подмена (porcelain [])   → lane_assume_unchanged_rc=0, STUB в журнале 1
    skip-worktree + подмена (porcelain [])      → lane_skip_worktree_rc=0, STUB в журнале 1
    commit подмены + tag -f frozen/contracts/109/1 → lane_retag_rc=0, STUB в журнале 1

Привязка батареи к форме кода (clean55.py → cl55 = C с единым appendExclusive и без мёртвого фолбэка; cases55.sh):

    --case harness_async_no_scrub → rc 0 BLOCKED_BY_RED_CONTROL «вход мутации отсутствует (база красна)», base_fired []
    --case harness_sink_decoy     → rc 0 REJECTED_EXACT
    --case harness_mode_collapse  → rc 1 NOT_REJECTED (мутация no-op: якорь отсутствует; NOOP не распознан для fact-целей, probe.py:2439/2451)

Гонка snapshotContext (race.sh, PG18 rev109r3race):

    {"A_before":"SELECT 'A' AS before_A","A_after":"SELECT 'B' AS after_B","A_after_rows":[{"after_b":"B"}], …}; rc_race=0

drill (iso.js): isValidIso8601 → "never" false, "ok" false, "1" true, "2026" true, "October 20, 2026" true,
"Tue Oct 20 2026" true, "10/20/2026 3:00 PM" true; sha256Bytes({x:{a:1}}) === sha256Bytes({x:{b:2}}) → true.

## Блокер

**Б-LINT.** Вводит его 68cee4a, в 8aca71a он остаётся. `npm --prefix backend run -s lint` rc 1 (3 ошибки в файлах диффа).
На B и на круге 2 (d1cece28) — rc 0. Шаг lint входит в required job `backend`. ПЕРЕСЕЧЕНИЕ контракта: «109 …
не ослабляет агрегат required».
ОБХОД (наблюдаемое состояние): дерево C = 8aca71a. Строки 1–5 зелёные (батарея wip rc 0 50/50/13, frozen 29/29,
test:integration 31/31 ×2), а required CI продукта на C красный, поставку слить нельзя. Правка механическая:
`const out` ×2 в harness.js и удалить `const crypto = require('node:crypto')` в harness.test.js. Подтверждение —
`npm --prefix backend run -s lint` rc 0.

## Семь пунктов роли

1. Область правки: 5 путей круга 3 (9 за всю поставку), все в зоне. backend/server, чужие тесты и pg18.js не тронуты. OK.
2. Сырой вывод: все прогоны выше исполнены мной. Доклад implementer не использован.
3. Проверки не переписаны под код: контракт = тегу. Батарея менялась только в зоне architect и только строже.
   Обратное направление (а): код подогнан под якоря мутантов. Смысл кода ухудшился: С5′ переоткрыт,
   добавлены мёртвый фолбэк и глобальный нереентерабельный контекст (гонка измерена). Батарея привязана к байтам:
   более чистая форма того же поведения у неё красная. Ложного зелёного я не нашёл: живые факты ловят оба
   мутанта «без I/O». Поэтому это совет (С-ЯКОРЬ).
4. Красное: mut1/mut2 → wip-батарея rc 1 фактами ASYNC_TUPLE/ASYNC_PII; грязный H → lane rc 1; БД остановлена →
   test:integration rc 1; B не перемерялся (батарея в части B не менялась, строка 1 — круг 2).
5. Атомарность: 3 коммита круга 3, один предмет, ссылка на 109 в каждом. OK.
6. Нормы не тронуты: нормативных файлов в диффе нет. OK.
7. Заявленное и сделанное: «50 клеток, 13 фактов» — подтверждено моим счётом (ast по CASES + raw.json).
   Не подтверждены три заявления:
   - коммит 8aca71a «дублирующая hash-object-сверка убрана» вместе с комментарием в коде «HEAD==тег + чистое дерево ⇒ файл = блоб» —
     опровергнуто: assume-unchanged/skip-worktree → rc 0 (С-LANE);
   - комментарий drill «round-trip … совпадает с оригиналом» — вакуумен (С6″);
   - lint в коммитах не упомянут, но required-lane красный.

## Вопросы оркестратора

(а) Подгонка под якоря ухудшила предмет. Измерено: С5′ снова раздвоен в 8aca71a; мёртвый `|| 'RUNTIME'`;
    глобальный `snapshotContext` даёт перекрёстный снимок при параллельных вызовах. Батарея привязана к форме:
    дерево cl55 с той же семантикой даёт NOT_REJECTED/BLOCKED. Плюс дефект батареи: NOOP не распознаётся для
    fact-целей (rc 1 вместо rc 2 по строке 3). Ложного зелёного нет, обход не назван — совет architect.
(б) Удаление hash-object-сверки открыло assume-unchanged и skip-worktree (rc 0, STUB исполнен). От перетега
    (`tag -f`) удалённая сверка тоже не защищала: тег берётся из самого checkout. A2/С3 круга 2 (грязное дерево)
    закрыт. Новые обходы требуют намеренной манипуляции индексом/тегом на станции оператора. В CI checkout
    создаёт сам job, без правки ci.yml эти состояния недостижимы. Контракт от злонамеренного кода с тем же uid
    не защищает, поэтому это совет. Форма, закрывающая все три: пин `b91be196…` литералом + hash-object
    против блоба этого коммита.

## ПРОВОДКА (038)

guard `fixtures/workshop_project/stend_109/probe.py`. Lane `stend109` исполняет эту батарею из H на теге
(в --local: PASS rc 0, 29/29). Job `stend109` стоит в `required.needs`. Канал подключён и является барьером
этого предмета. Ограничение С11: CI держит frozen-батарею, а её пустой предмет (mut2) проходит.

## Паразитная сложность (050): пять ответов на новые/раздутые артефакты круга 3

- harness.js `captureSql`+`snapshotContext`+`snapshotStatement`+`readOnlySql`: (1) §Предмет «SQL-снимки до/после», Б2′.
  (2) Модульный глобал `snapshotContext` — скрытое состояние, в аргументах его не видно. Гонка измерена.
  (3) 1 файл. (4) Интерфейс сужен ради якоря (`captureSql(label)`), работа спрятана в глобал, модуль от этого мельче.
  (5) ASYNC_TUPLE_GUARD, строка 5. ESSENTIAL по свойству. Глобал — ACCIDENTAL: фрагмент `snapshotContext`,
  недостающее свойство — реентерабельность, проще — `captureSql(label, statement)`, та же строка приёмки проходит
  на уровне фактов, но мутант-якорь `ASYNC_SNAP_BEFORE` станет no-op. Поэтому совет.
- harness.js `scrubStructural`/`redact*`/`SENSITIVE_KEYS`: (1) инвариант 4, F4′. (2) Нет. (3) 1. (4) Глубокий модуль:
  один вход `scrubRecord`. (5) ASYNC_PII_GUARD, HARNESS_PII_GUARD, тесты. ESSENTIAL.
- harness.js `appendExclusive` + `writeEvidence` (две функции записи): (1) инвариант 4. (2) Нет. (3) 2 места — дифф 8aca71a
  число увеличил (в 75802a2 было 1). (4) —. (5) HARNESS_NO_SCRUBBER, mut_harness_async_no_scrub. ACCIDENTAL (С5′):
  фрагмент `writeEvidence` (дубль openSync 'wx'), свойство не прибавляется, проще — единый `appendExclusive`.
  Строки приёмки по поведению та же форма проходит, но батарея на ней даёт BLOCKED (С-ЯКОРЬ). Совет.
- drill-measure.js `isValidIso8601`, ветка statSync в `sha256Bytes`: (1) инвариант 6 (С6′/F2′). (2) Чтение файла по
  пути из входа — явно в контракте входа. (3) 1. (4) Норм. (5) DRILL_INPUT_GUARD. ESSENTIAL. Вакуумный round-trip — С6″.
- run_backend_ci.py: проверка `status --porcelain`: (1) ПРОВОДКА-ЭНФОРСМЕНТ/A2. (2) Нет. (3) 1. (5) LANE_HYGIENE_GUARD.
  ESSENTIAL, недостаточна (С-LANE).
- harness.test.js `withEnv` + 3 async-теста: (1) строка 5. (2) env восстанавливается. (3) 1. (5) test:integration.
  ESSENTIAL. Мёртвый `require('node:crypto')` — это и есть Б-LINT.

## Что нужно для accept

Закрыть Б-LINT (lint rc 0 на HEAD). Советы не блокируют. Рекомендации: вернуть единый путь записи и
`captureSql(label, statement)` — только вместе с переякорением батареи architect'ом; закрыть С-LANE пином коммита.

Чистка: контейнеров и томов `rev109r3*` 0 (`docker ps -a` / `docker volume ls`). Чужие проекты (stend109up*/stend109async*
других судей) не трогались. Основной чекаут H не модифицировался.
