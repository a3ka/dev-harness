accept
OBJECT=5be0647b5d90c5bd29242ce6e8a63e891cb1cad2
СУД: repo=dev-harness; предмет=187; фаза=реализация (scoped-исправление ремонта двери 187а, только Д3/Б-1/Б-2); роль=reviewer; вызов=2/2; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии; оркестратор сверяет по трассе); сессия=Rev187DoorC; SHA=5be0647b5d90c5bd29242ce6e8a63e891cb1cad2; контракт=frozen/contracts/187/1 (тег 514df4b1 → коммит 52d3a3a1); предыдущий=FAIL contracts-187-impl-v3 (вызов 1/1, OBJECT bd99c4b1d8, Б-1+Б-2); исключение=нет (санкция исправительного вызова по roles/critic.md §Остановка — HANDOFF 3b9ba7b822, предок origin/wip/011/orchestrator, строки «САНКЦИЯ ИСПРАВИТЕЛЬНОГО ВЫЗОВА» и «СУД (ДО ВЫЗОВА)» на месте)

ИТОГ: Б-1 и Б-2 закрыты. Последствия дельты для Д1/Д2/Д4 и для frozen 187/1 :27–29, :37, :41 не ослабляют ничего. Блоков нет. Четыре новых совета (С-6…С-9), два наблюдения для оркестратора.
Основание scoped-поиска (roles/critic.md §Контракт): проверял только дельту bd99c4b1d8..5be0647b5d — новый канал признака (snapshot), новый rc 2 двери (ARCH187_REFUSAL_RC) и переделку клеток Д3. Неизменённые поверхности заново не исследовал. Исключение — мутанты M1/M2/M4 прежнего вердикта, их повторил как регресс.

ИДЕНТИФИКАЦИЯ ДЕРЕВА. Одноразовый SSH-клон /tmp/rev187doorC-345160-1794764250 со своим .git (ssh://git@github.com/a3ka/dev-harness.git):
  git rev-parse FETCH_HEAD origin/wip/187/implementer → 5be0647b5d90c5bd29242ce6e8a63e891cb1cad2 (оба)
  git diff --stat bd99c4b1d8 5be0647b5d → ровно 2 файла: fixtures/workshop_project/architecture_process_187/workflow_probe.py | 268, scripts/check_architecture_contract.sh | 220 (369+/119−)
  bd99c4b1d8..5be0647b5d — два коммита:
    f80b7257f1, parent bd99c4b1d8, author/committer architect/architect, трогает только workflow_probe.py
    5be0647b5d, parent f80b7257f1, author/committer implementer/implementer, трогает только scripts/check_architecture_contract.sh
  git diff --quiet frozen/contracts/187/1 5be0647b5d -- contracts/187-arhitektura-v-processe.md → rc 0 (текст 187 не менялся)

══ (1) Б-1 ЗАКРЫТ — замер на настоящем пине 907e9e80 (только чтение) ══
Модель: /home/harness/dev-harness-projects/complior-back/wt/wip-136-demo/tmp/architecture-007-20261113. HEAD 907e9e808738276c1a81b1e6d15a0c13a4aee68f, porcelain=0 до замера и после. Скрипт: /tmp/dev-harness-verify/rev187doorC-pin.sh.
  Сырой locate tests/auth/login.test.js (rc=0):
    "status": "DECLARED", "matches": [{"module": "module.tests", "components": [], "specification": "tests/module.js", "explicit": false, "matched": "tests/"}]   ← поля outsideProductRuntime в матче нет
  Сырой snapshot --out <mktemp в /tmp/dev-harness-verify> → rc=0
    modules=76 boolean=76
    true=module.app.seeds,module.server.infrastructure.migrations,module.server.infrastructure.deployment,module.server.infrastructure.billing,module.evals,module.tests
    {"id":"module.tests","outsideProductRuntime":true}
    Файл удалён (removed=yes).
  Источник boolean: model.js:25 пина задаёт каждому модулю outsideProductRuntime: false по умолчанию, поэтому значение без boolean на пине недостижимо.
  Отказ snapshot: --out в путь под обычным файлом (ENOTDIR, внутри verify-каталога; /proc не трогал) → bad-out-rc=1 {"status":"FAIL","scope":"ARCHITECTURE_TOOL_INPUT","findings":[{"code":"EEXIST",…  ← та же форма, что у toy
  Дверь OBJECT на пине (библиотечный режим, источник из клона, hash-object 21c9c06a = блоб OBJECT):
    zone=[server/infrastructure/email/worker.js] rc=0
    zone=[… tests/auth/login.test.js] rc=0 refusal=[]          ← боль 181 снята
    zone=[… tests/] rc=0
    zone=[… server/infrastructure/migrations/x.js] rc=0        ← migrations: true на пине
    zone=[… provenance.json] rc=0 stderr=[вне модели: provenance.json]   (Д4 прежний)
    zone=[… server/newdir/x.js] rc=1 PATH_WITHOUT_COMPONENT: путь server/newdir/x.js не размещён однозначно в закреплённой модели (несколько претендентов)
    zone=[… tests/a.js tests/b.js server/infrastructure/migrations/y.js] rc=0
    locate tests/auth/login.test.js → kind=outside; locate server/infrastructure/migrations/x.js → kind=outside
    Выгрузки идут в /tmp/tmp.* (mktemp по умолчанию: вне дерева продукта и вне клона модели). Число /tmp/tmp.* до и после прогона: before=4139 after=4139, то есть выгрузки удалены. Porcelain пина после прогона = 0.
  Тексты контрактов бэкенда (origin/main 2038b39ce4, без fetch; /tmp/dev-harness-verify/rev187doorC-multi.sh). Shim поверх node считает вызовы snapshot:
    contract-режим:
      180 rc=1 ARCH_ZONE … api.transport (snapshot-calls=0)
      181 rc=1 ARCH_DRAFT … (snapshot-calls=1, locate-calls=12)
      183 rc=1 ARCH_ZONE … api.loader (snapshot-calls=0)
      185 rc=1 ARCH_DRAFT … (snapshot-calls=1, locate-calls=32)
      snapfile-after=[] у всех.
    task-режим (путь make_task):
      181 rc=0 OK, stderr «вне модели: FILES.sha256»
      185 rc=0 OK, stderr «вне модели: provenance.json … FILES.sha256»
    На door-v1 181 и 185 отказывали PATH_WITHOUT_COMPONENT на tests/**. Теперь зоны проходят, выгрузка берётся один раз на прогон, ARCH_ZONE за чужой компонент сохранён (180, 183).

══ (2) Б-2 ЗАКРЫТ — toy конформен, клетки различают ══
Toy-locate против настоящего CLI байт-в-байт (/tmp/dev-harness-verify/rev187doorC-conform.py: TOY_CLI из блоба OBJECT, тот же node):
    tests/auth/login.test.js: real rc=0 toy rc=0 bytes-equal=True
    tests/auth/:              real rc=0 toy rc=0 bytes-equal=True
    tests/:                   real rc=0 toy rc=0 bytes-equal=True
    real match keys ['module','components','specification','explicit','matched'] = TESTS_MATCH = OPS_MATCH
    trait fields inside TOY_CLI text: []    (outsideProductRuntime и emptyComponentsReason в шаблоне toy-CLI не встречаются)
    Toy snapshot: {format, model:{logicalModules:[{id, outsideProductRuntime}]}}. Это подмножество настоящего: top-ключи настоящего — changeScenarios, format, model, systemModel. Дверь читает только .model.logicalModules[].id и .outsideProductRuntime. format совпадает: complioros-architecture-baseline/1.
Батарея своей мерой (клон, OBJECT):
    --repo .: CELLS=54 STABS=0  FAILURES=0 rc=0
    --model:  CELLS=54 STABS=0  FAILURES=0 rc=0
    --stabs:  CELLS=54 STABS=56 FAILURES=0 rc=0
Красное (f80b7257f1: новые клетки + дверь bd99), --repo .: CELLS=54 FAILURES=3 rc=1. Красные клетки:
    RED zone-outside-runtime: rc=1 expected=0 … ОТКАЗ: PATH_WITHOUT_COMPONENT: путь tests/auth/login.js размещён моделью, но к…
    RED zone-outside-snapshot-failed: rc=1 expected=2 reason=ARCH_NOT_EVALUATED
    RED zone-outside-snapshot-missing: rc=1 expected=2 reason=ARCH_NOT_EVALUATED
Мутанты двери OBJECT. Каждый — одна литеральная замена с assert count==1, после каждого git checkout файла; итоговый status '' HEAD 5be0647b5d. Скрипт /tmp/dev-harness-verify/rev187doorC-mut.py.
    D3-snapshot-fail-open (ошибка выгрузки → outside): RED zone-outside-snapshot-failed rc=0 expected=2 (FAILURES=1)
    D3-missing-guessed-componentless: RED zone-outside-snapshot-missing rc=1 expected=2 (FAILURES=1)
    D3-false-as-outside: RED zone-outside-false-refused rc=0 expected=1 (FAILURES=1)
    D3-true-as-componentless: RED zone-outside-runtime rc=1 expected=0 (FAILURES=1)
    D3-exit-rc-flattened (exit 1 вместо RC): RED snapshot-failed, snapshot-missing rc=1 expected=2 (FAILURES=2)
    D3-tests-prefix-skip (пропуск по префиксу tests/ до locate): RED snapshot-failed, snapshot-missing rc=0 expected=2 (FAILURES=2)
        → удаление noflag-клетки и стаба префикса различения не теряет: префиксную догадку ловят клетки snapshot.
    D3-old-locate-read (признак из матча locate, дверь bd99): RED runtime, snapshot-failed, snapshot-missing (FAILURES=3)
    D3-absent-as-outside: FAILURES=0 → С-6
    D3-snapshot-unparsed-accepted: FAILURES=0 → С-7
Пары клетка ↔ стаб (STABS блоба OBJECT, привязаны к ветвям кода):
    outside-locate-flag-read → zone-outside-runtime
    outside-empty-green → zone-outside-false-refused
    outside-snapshot-error-green → zone-outside-snapshot-failed
    outside-snapshot-missing-guessed → zone-outside-snapshot-missing
  У каждой клетки Д3 есть свой стаб, и ветвь, которую клетка различает, подтверждена мутантом настоящей двери (список выше).
Батарея main не ослаблена (/tmp/dev-harness-verify/rev187doorC-cases.py: сегменты CASES/STABS из блобов через ast):
    origin/main 61b095f186: CASES-entries=39 STABS-entries=42
    bd99c4b1d8:             CASES-entries=52 STABS-entries=53
    OBJECT:                 CASES-entries=53 STABS-entries=55
    Записи считаются сегментами исходника. В CASES один сегмент — *-расширение, в STABS один сегмент — **-генератор на 2 стаба (workflow_probe.py:203–205, status missing/unknown). Отсюда у раннера CELLS=54 и STABS=56.
    origin/main → OBJECT: ни одна запись main не удалена и не изменена.
    bd99 → OBJECT:
      удалены ровно клетка zone-outside-noflag-refused и стаб outside-by-tests-prefix (мнимое различение, заявлено);
      добавлены клетки zone-outside-snapshot-failed, zone-outside-snapshot-missing;
      добавлены стабы outside-locate-flag-read, outside-snapshot-error-green, outside-snapshot-missing-guessed.

══ (3) ПОСЛЕДСТВИЯ ДЕЛЬТЫ ══
Д1/Д2/Д4. Мутанты прежнего вердикта на OBJECT дают те же красные:
    M1-zero-as-area: RED path-unresolved-zero-absent, path-unresolved-zero-present (FAILURES=2)
    M2-gate-ignored: RED check-rc0-gate-lie rc=0 expected=2 (FAILURES=1)
    M4-boundary-skip: RED zone-container-escape rc=0 expected=1 (FAILURES=1)
  Hunk exit "${ARCH187_REFUSAL_RC:-1}" стоит только в ветви model_only=0. Канал --model-only (pre_critic.sh:289) дельтой не тронут.
frozen 187/1:
  :29 «неразмещённый — PATH_WITHOUT_COMPONENT, чужой — ARCH_ZONE»: сохранено. Пин: newdir → PATH_WITHOUT_COMPONENT; 180 → ARCH_ZONE api.transport; 183 → ARCH_ZONE api.loader. Ветвь false → прежний отказ (D3-false-as-outside красный).
  :37 «конформная грамматика CLI»: теперь выполнено, toy-locate байт-в-байт настоящему.
  :27, :41: Д1-ветви и pre_critic не тронуты (M2 красный, model-only без изменений).
  ARCH_LOCATE_GRAMMAR: ветви ''/не-JSON/без status/неизвестный status/неконформный id в arch187_locate дельтой не тронуты (хунк @@-289 начинается после них).
Библиотечные вызывающие на rc 2 не зеленеют: make_task.sh:991 и freeze_contract.sh:282 делают die по любому ненулевому возврату arch187_check_text, а он возвращает только 0/1. ARCH_NOT_EVALUATED для них остаётся отказом.

══ (4) ЗОНЫ ══
  frozen 187/1 :62 — ЗОНА architect: contracts/187-arhitektura-v-processe.md fixtures/workshop_project/architecture_process_187/
  frozen 187/1 :63 — ЗОНА implementer: scripts/make_task.sh scripts/freeze_contract.sh scripts/pre_critic.sh scripts/done_contract.sh scripts/check_architecture_contract.sh
  f80b7257f1 (architect) трогает только workflow_probe.py внутри зоны architect. 5be0647b5d (implementer) трогает только check_architecture_contract.sh внутри зоны implementer. Везде author==committer. Атомарность: две задачи — два коммита, оба ссылаются на Б-1/Б-2 вердикта door-v1.

══ CI ══
  gh run list --branch wip/int-187/implementer → 43735506905 ci pull_request success, headSha a648e59e94. 17 jobs, ни одного не-success/skipped.
  a648e59e94 = merge (parents 468fd71b6b, 5be0647b5d). git diff --stat 5be0647b5d a648e59e94 -- scripts/check_architecture_contract.sh fixtures/workshop_project/architecture_process_187/ → пусто: дверь и клетки на носителе равны OBJECT.
  Сам OBJECT: run 43733067039 (wip/187/implementer, headSha 5be0647b5d) failure. Красный job — legkij: «FAIL contracts/140-odin-agent-na-predmet.md изменён без новой заморозки … нет verdicts/critic/contracts-140-v3.md», lane check:contract-frozen rc=1. Это предмет 140 на базе ветки; оба его файла входят в diff OBJECT→a648. К 187 отношения не имеет (Н-2).

══ БЛОКИ ══
нет.

══ СОВЕТЫ (не блокируют; С-1…С-5 прежнего вердикта остаются открытыми советами) ══
С-6 [Д3, ветвь absent без клетки]: scripts/check_architecture_contract.sh @OBJECT, arch187_locate, ветвь `absent)`: модуль в выгрузке есть, boolean нет → ARCH_NOT_EVALUATED rc 2. Мутант D3-absent-as-outside (absent → outside, то есть пропуск) оставляет батарею зелёной: FAILURES=0. На пине состояние недостижимо: model.js:25 даёт boolean по умолчанию, 76/76 boolean. Поэтому по §Порог это совет. Если нужна защита: клетка с модулем без признака и парный стаб «absent → пропуск».
С-7 [Д3, ветвь неразобранной выгрузки без клетки]: проверка `jq -e '(.model.logicalModules | type) == "array"'` в arch187_snapshot_export. Мутант D3-snapshot-unparsed-accepted (`if false`) оставляет батарею зелёной: FAILURES=0. С настоящим CLI недостижимо: snapshotCommand пишет createBaseline целиком, а при throw rc≠0. Совет.
С-8 [050, кэш отказа выгрузки]: в arch187_snapshot_export есть ветвь `failed)`, глобалы ARCH187_SNAPSHOT_STATE и ARCH187_SNAPSHOT_REFUSAL и ветвь «ARCH187_MODEL_DIR пуст».
  Ветвь «MODEL_DIR пуст» недостижима: arch187_locate раньше делает `[ -n "${ARCH187_MODEL_DIR:-}" ] || return 1`.
  Кэш отказа недостижим: после not-evaluated arch187_zones сразу делает return 1, а arch187_check_text вызывает arch187_snapshot_drop. Других вызывающих arch187_locate/arch187_zones в дереве нет (grep).
  Ни одно замороженное свойство кэш отказа не требует: отказ сам завершает прогон, «один раз на прогон» выполняется и без кэша.
  Более простая форма: кэш только по непустому ARCH187_SNAPSHOT_FILE, отказ сразу в ARCH187_REFUSAL/RC, без STATE/REFUSAL-глобалов (numstat 6+/31−). Проверена в клоне (/tmp/dev-harness-verify/rev187doorC-simpler.py): --repo . CELLS=54 FAILURES=0 rc 0, --stabs CELLS=54 STABS=56 FAILURES=0 rc 0.
  Почему совет, а не блок: достижимого состояния нет и названное обязательство не нарушено (§Порог). Это то же прочтение 050, что в contracts-187-impl-v1 С4 и door-v1 С-4.
С-9 [050, ARCH187_REFUSAL_RC]: rc двери держится на глобале. Значение "1" ставится в 7 местах (:335, :625, :656, :681, :698, :712, :784), значение 2 — в 7 местах (export ×5, locate ×2). Следующий именованный отказ без такой строки унаследует rc 2 предыдущего вызова locate. Сейчас этого нет: каждый вызов locate/zones/check_text начинает с "1", а мутант exit-rc-flattened красный ×2. Совет: выставлять rc в одной точке (в ветвях not-evaluated) и не сбрасывать его по месту каждого отказа.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050) по артефактам дельты, ответы (1)–(5):
  • arch187_snapshot_export:
      (1) Б-1, ADR Д3, frozen :23/:29 «каждый продуктовый путь»;
      (2) временный файл вне деревьев, явно назван и удаляется (замер tmp.* 4139=4139); плюс глобалы TMP/FILE/STATE/REFUSAL — побочным эффектом;
      (3) 1 файл;
      (4) интерфейс 0/1 + 4 глобала шире работы (С-8);
      (5) клетки runtime/false-refused/snapshot-failed;
      ESSENTIAL, кэш отказа ACCIDENTAL (С-8, совет).
  • arch187_module_trait:
      (1) признак Д3;
      (2) состояния нет, stdout;
      (3) 1;
      (4) 1 аргумент → 4 значения;
      (5) клетки runtime/false-refused/snapshot-missing;
      ESSENTIAL (значение absent без клетки — С-6).
  • arch187_snapshot_drop и вызов из arch187_cleanup и arch187_check_text:
      (1) «mktemp удаляется» из постановки Б-1;
      (2) явно;
      (3) 1;
      (4) —;
      (5) замер snapfile-after=[] и tmp.* без прироста;
      ESSENTIAL.
  • второй аргумент arch187_locate (need 0|1):
      (1) «каталог — только граница», выгрузка без нужды не берётся;
      (2) явный аргумент;
      (3) 1;
      (4) +1 аргумент;
      (5) клетки, которая различает этот аргумент, нет. Эффект виден в замере: 180/183 snapshot-calls=0.
      Отсутствие ACCIDENTAL не доказано: более простую форму не прогонял. Не находка.
  • ARCH187_REFUSAL_RC + exit "${ARCH187_REFUSAL_RC:-1}":
      (1) постановка Б-1 «ARCH_NOT_EVALUATED rc 2»;
      (2) глобал, виден в коде возврата;
      (3) 1 файл, 14 присваиваний;
      (4) —;
      (5) клетки snapshot-failed/missing, мутант exit-rc-flattened красный;
      ESSENTIAL, форма — С-9.
  • SNAPSHOT_MODULES, snapshot_export(), файл snapshot-model, ветвь toy `snapshot`:
      (1) Б-2;
      (2) константы и файл toy-дерева, явно;
      (3) один файл fixture, единый источник для toy и честного контроля;
      (4) —;
      (5) --model/--stabs/--repo в CI;
      ESSENTIAL.

СВЕРКА-АРХИТЕКТУРЫ: дверь 187а сверена с закреплённым пином 907e9e80 бэкенда замером (раздел 1). Признак outsideProductRuntime берётся из выгрузки snapshot того же CLI, матч locate признака не несёт — это подтверждено сырым выводом.
СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md / docs/CODING-STANDARDS.md (сверено на bd99 в door-v1; дельта AGENTS.md не трогает — diff --stat показывает 2 файла). Сверять не с чем.
ПРОВОДКА: guard=red_architecture_process_187.sh и guard=scripts/check_architecture_contract.sh (frozen :135–136). Оба в объекте и оба — барьер именно этого предмета: новые клетки Д3 вызывают публичную дверь (action 'door'/'freeze'), мутанты настоящей двери их краснят.

НАБЛЮДЕНИЯ ДЛЯ ОРКЕСТРАТОРА (не находки по OBJECT):
  Н-1: после снятия боли tests/** контракты бэкенда 181 и 185 в contract-режиме (freeze) упираются в следующее правило: ARCH_DRAFT «предмет не объявляет операцию со схемами входа/выхода». arch187_operations дельтой не тронута, в task-режиме (make_task) оба проходят rc 0. Если ждут freeze 181/185 — это следующий барьер, не дефект двери.
  Н-2: CI собственного PR OBJECT (run 43733067039) красный по предмету 140 (legkij, check:contract-frozen). Зелёный носитель — a648e59e94 (PR #961), дверь и клетки на нём равны OBJECT.

НЕ ПРОВЕРЯЛ (вне разрешённого узкого прогона):
  fixtures/workshop_project/arch_component_170/red_arch_component_170.sh;
  прочие батареи;
  check_zones.sh — зоны сверены по diff-tree и ЗОНА-строкам;
  независимость по трассе — модель-факт по контексту сессии.

МАТЕРИАЛЫ: /tmp/dev-harness-verify/
  rev187doorC-pin.sh, rev187doorC-snapshape.sh, rev187doorC-multi.sh, rev187doorC-conform.py, rev187doorC-cases.py, rev187doorC-mut.py, rev187doorC-simpler.py;
  этот текст: verdict-187-door-v2.md.
Клон /tmp/rev187doorC-345160-1794764250 не удалён: rm отклонён охраной «Н-85/А-122: путь … не в null-allowlist (/tmp/dev-harness-verify/**, artifact://)». Последний git status клона перед попыткой удаления: '' (вывод rev187doorC-simpler.py). Удалить должен оркестратор, как и прежний /tmp/rev187doorB-345160-1794754690.
Push не делал, в общий checkout не писал.
