FAIL
OBJECT=bd99c4b1d8e5563fba624f021e165a92d2ecf2b5
СУД: repo=dev-harness; предмет=187; фаза=реализация (узкий ремонт двери 187а); роль=reviewer; вызов=1/1; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии; оркестратор сверяет по трассе); сессия=Rev187DoorB; SHA=bd99c4b1d8e5563fba624f021e165a92d2ecf2b5; контракт=frozen/contracts/187/1 (тег 514df4b1 → коммит 52d3a3a1); предыдущий=нет по этому ремонту; исключение=слово владельца ~13:00 UTC через консультанта (ADR origin/main docs/owner/adr/2026-11-15-dver-187a-produktovye-puti.md)

ИТОГ: ремонт закрывает Д1, Д2 и Д4. Д3 НЕ закрыт на настоящем закреплённом пине 907e9e80. Клетки Д3 зелёные только потому, что toy-CLI батареи кладёт в ответ locate поле, которого настоящий CLI не выдаёт. Два блока (Б-1, Б-2), пять советов (С-1…С-5).

ИДЕНТИФИКАЦИЯ ДЕРЕВА (А-350), одноразовый SSH-клон /tmp/rev187doorB-345160-1794754690 со своим .git:
  git rev-parse FETCH_HEAD origin/wip/187/implementer → bd99c4b1d8e5563fba624f021e165a92d2ecf2b5 (оба)
  git diff --quiet eb136a2664 bd99c4b1d8 → rc 0 (дерево bd99 = дерево eb136a; tree 8382f54a)
  git cat-file -p bd99c4b1d8: parent eb136a2664, parent f50aa6b58b (merge 'origin/wip/187/implementer')
  git diff --quiet frozen/contracts/187/1 bd99c4b1d8 -- contracts/187-arhitektura-v-processe.md → rc 0 (текст 187 после заморозки не менялся)
  gh run view 43725631880 → {conclusion: success, headSha: bd99c4b1d8…, headBranch: wip/187/implementer, event: pull_request}

══ БЛОКИ ══

Б-1 [функциональный дефект: Д3 не закрыт; обязательство ADR Д3 «пути модулей с outsideProductRuntime: true не судятся», frozen 187/1 :23/:29 «каждый продуктовый путь»]
  Фрагмент: scripts/check_architecture_contract.sh @bd99 :295–299 (arch187_locate):
    outside="$(printf '%s' "$out" | jq -r '(.matches[0].outsideProductRuntime // false) | tostring' …)"
  Дверь ищет признак в ответе locate. У закреплённого CLI этого поля в матче нет. Модель 907e9e80 (/home/harness/dev-harness-projects/complior-back/wt/wip-136-demo/tmp/architecture-007-20261113, HEAD 907e9e808738…, porcelain 0) строит матч в tooling/checks/workflow.js:66–72 ровно из полей {module, components, specification, explicit, matched}. Признак есть только в определении модуля: products/back/tests/module.js:5 `outsideProductRuntime: true`. В вывод locate он не попадает.
  Сырой ответ настоящего locate (node tooling/checks/cli.js locate --path tests/auth/login.test.js, rc=0):
    "status": "DECLARED", "matches": [{"module": "module.tests", "components": [], "specification": "tests/module.js", "explicit": false, "matched": "tests/"}]   ← поля outsideProductRuntime нет
  Замер двери OBJECT на настоящем пине (/tmp/dev-harness-verify/rev187doorB-d3.sh, ARCH187_LIB=1, исходник двери — из клона на bd99, hash-object 004b62f0 = blob bd99):
    locate tests/auth/login.test.js rc=1 kind=componentless refusal=[PATH_WITHOUT_COMPONENT: путь tests/auth/login.test.js размещён моделью, но компонент не назван]
    zone=[server/infrastructure/email/worker.js tests/auth/login.test.js] rc=1 refusal=[PATH_WITHOUT_COMPONENT: путь tests/auth/login.test.js …]
    zone=[… server/infrastructure/migrations/x.js] rc=1 PATH_WITHOUT_COMPONENT (у migrations/module.js:5 тоже outsideProductRuntime: true)
  Тексты бэкенда, origin/main 7db5f008, без fetch (/tmp/dev-harness-verify/rev187doorB-multi.sh):
    181 [код] rc=1 PATH_WITHOUT_COMPONENT: путь tests/auth/grant-writers.js размещён моделью, но компонент не назван
    185 [код] rc=1 PATH_WITHOUT_COMPONENT: путь tests/architecture/bindings.json размещён моделью, но компонент не назван | stderr: вне модели: provenance.json
  На настоящем пине ветвь kind=outside недостижима. Боль 181, которую называет сама клетка, осталась. 185 проходит Д4 и падает на tests/**.
  Что вернуть: дверь берёт outsideProductRuntime модуля матча из закреплённой модели по конформному каналу, а не из ответа locate. Канал выбирают architect и implementer; я его не проектирую.

Б-2 [клетка на неконформной грамматике CLI: нарушение frozen 187/1 :37 «конформная грамматика CLI»; различение по Н-39 мнимое]
  Фрагмент: fixtures/workshop_project/architecture_process_187/workflow_probe.py @bd99 — OUTSIDE_TESTS_MATCH = {'module': 'module.tests', 'components': [], 'outsideProductRuntime': True, 'emptyComponentsReason': …}, OPS_MATCH = {… 'outsideProductRuntime': False …}. Через TOY_CLI ('__OUTSIDE_TESTS_MATCH__', '__OPS_MATCH__') они попадают в ответ toy-locate.
  Toy-CLI выдаёт в матче locate поля, которых закреплённый CLI не выдаёт (workflow.js:66–72). Клетка zone-outside-runtime зелёная на вымышленной форме ответа, её защитная пара zone-outside-false-refused судит вымышленное поле. Сообщение коммита fdc95c4c утверждает: «locate tests/** -> module.tests, components [], у module.tests outsideProductRuntime: true». Это верно о модуле, но не об ответе locate, который читает дверь. Батарея --repo . даёт CELLS=53 FAILURES=0, а реальный дефект Д3 при этом остаётся (Б-1). Это подгонка входа клетки под код, а не замер поведения пина.
  Что вернуть: вход клеток Д3 повторяет настоящий канал признака байт-в-байт, как у CONTAINER_*: там форма ответа совпала с моим замером настоящего пина.
  Владельцы: architect (fixture) и implementer (дверь, Б-1). Б-1 и Б-2 закрываются вместе.

══ ЧТО ПРОВЕРЕНО И ПРОШЛО ══

(1) Правила Д1/Д2/Д4 и инварианты frozen 187/1 :27–29, :41
  Д1, настоящий пин (/tmp/dev-harness-verify/rev187doorB-d1.sh, digest лока бэкенда 4bb2d163…):
    "  ok   check --base: rc 0, requiredModelGate PASS; вне вердикта модели (unresolved): latency.command-acceptance, latency.first-agent-event, latency.agent-completion"
    model_check rc=0 refusal=[]
  Ветви: rc 1 → ARCH_CHECK, rc 2 → ARCH_NOT_EVALUATED, gate != PASS при rc 0 → ARCH_NOT_EVALUATED, exit двери равен rc функции ("exit \"$rc\""). Ветви «вход не принят», «инструмент не запустился», «нет snapshotDigest» в диффе не тронуты (диф 174c68f6..eb136a: hunks @@-297 и @@-329 меняют только хвост после этих ветвей).
  Вызывающие: pre_critic.sh:289–292 любой ненулевой rc → refuse; freeze_contract.sh:282 и make_task.sh:991 зовут arch187_check_text, а не model_check. Выход 2 вместо 1 никого не зеленит.
  Д2, настоящий пин: zone=[server/infrastructure/email/worker.js] rc=0. Мутант M4 (граница каталога снята) → RED zone-container-escape rc=0 expected=1.
  Д4, настоящий пин: zone=[… provenance.json] rc=0, stderr «вне модели: provenance.json»; zone=[… server/newdir/x.js] rc=1 PATH_WITHOUT_COMPONENT (несколько претендентов).
  ARCH_ZONE за чужой компонент сохранён: 180 → ARCH_ZONE … api.transport, 183 → ARCH_ZONE … api.loader. Цикл сверки declared в arch187_zones не тронут.
  ARCH_LOCATE_GRAMMAR сохранён: ветви '' / неизвестный status / не-JSON в arch187_locate не тронуты. Неизвестный ARCH187_LOCATE_KIND → return 1 с ARCH_PIN.
  Пропуска по префиксу пути в двери нет: Д4 решает пустота .matches (jq '.matches | length' = "0"). Д3 решает поле ответа, но к Б-1 это поле недостижимо.
  Реальный locate: DECLARED ⇔ matches.length === 1 (workflow.js:87). Значит, чтение matches[0] в DECLARED не теряет других матчей; это не находка.

(2) Батарея своей мерой (тот же клон, узкий прогон)
  bd99 --model:  CELLS=53 STABS=0 FAILURES=0, rc=0
  bd99 --stabs:  CELLS=53 STABS=54 FAILURES=0, rc=0
  bd99 --repo .: CELLS=53 STABS=0 FAILURES=0, rc=0
  Красное, 174c68f676 (клетки architect + дверь до ремонта) --repo .: CELLS=53 FAILURES=7, rc=1. Красные клетки: check-green-latency-unresolved, check-rc2-real-gate, check-rc0-gate-lie, zone-container-file, zone-outside-runtime, path-unresolved-zero-absent, path-unresolved-zero-present.
  База main dd63fc0c12 --stabs: CELLS=40 STABS=43 FAILURES=0. Прирост +13 клеток (4 Д1, 3 Д2, 3 Д3, 3 Д4), +11 стабов.
  Батарея main не ослаблена: строки CASES/STABS базы, sed+grep+sort+comm, old-not-in-new: 0 (79 строк базы, 103 строки OBJECT, разница 24 = 13+11). Отображение check-rc сохранено: 'check-1'→'1', 'check-2'→'2', прочее → '0'.
  Мутанты двери (по одной строке sed, файл восстанавливался после каждого; /tmp/dev-harness-verify/rev187doorB-mut.sh):
    M1 unresolved-none→unresolved-area: RED path-unresolved-zero-absent, path-unresolved-zero-present (FAILURES=2)
    M2 gate-check снят: RED check-rc0-gate-lie rc=0 expected=2 (FAILURES=1)
    M3 outside-флаг не читается (if true): RED zone-outside-false-refused, zone-outside-noflag-refused (FAILURES=2)
    M4 граница каталога снята: RED zone-container-escape (FAILURES=1)
  Клетки различают ветви кода. Различение клеток Д3 мнимое относительно пина (Б-2).

(3) Зоны и авторство (Н-71)
  git diff --name-only dd63fc0c12 eb136a2664 → fixtures/workshop_project/architecture_process_187/workflow_probe.py, scripts/check_architecture_contract.sh. Оба пути в frozen 187/1 :62/:63, в зонах architect и implementer соответственно.
  Авторство (author/committer): 1f35ecb9, cfaaa9ee, fdc95c4c, 174c68f6 — architect/architect; eb136a26 — implementer/implementer (только scripts/check_architecture_contract.sh); bd99c4b1 (merge) — implementer/implementer. Везде author==committer.
  git diff --name-only origin/main bd99 дополнительно показывает 7 файлов docs/owner/adr/**. Это сдвиг main (#953), ветка их не несёт.

(5) Смешения с отложенной v+1 нет. 13 новых клеток: check-green-latency-unresolved, check-rc2-real-gate, check-rc1-real-gate, check-rc0-gate-lie, zone-container-file, zone-container-escape, path-unplaced-absent, zone-outside-runtime, zone-outside-false-refused, zone-outside-noflag-refused, path-unresolved-zero-absent, path-unresolved-zero-present, path-area-without-component. Клеток legacy-refused, cutover или precritic-проб v+1 среди них нет. Константы DUAL_*/AMBIG_* помечены «принесено минимально из v+1», но служат входами клеток этого ремонта (path-unplaced-absent, path-area-without-component).

══ СОВЕТЫ (не блокируют) ══

С-1 [Д1, fail-open вне достижимого]: в arch187_model_check gate="" при отсутствующем или нестроковом requiredModelGate, а при rc 0 это даёт зелёный. Комментарий там же говорит «rc одному не доверяют». С закреплённым CLI недостижимо: cli.js:263–305 всегда выдаёт requiredModelGate, rc 0 ⇔ PASS вне --strict. Совет: при rc 0 требовать gate == "PASS" явно.
С-2 [верность toy]: для прочих файлов внутри CONTAINER_PREFIX toy отвечает UNRESOLVED с нулём матчей. Настоящий locate по hint-префиксу даёт DECLARED module.email []. Сейчас от этого не зависит ни одна клетка.
С-3 [атомарность и состав]: OBJECT — merge с f50aa6b58b. Диапазон origin/main..bd99 несёт 7 коммитов, а не заявленные 5: лишние cd07d3a9 «187a v3…» и f50aa6b5 «187 fix2…» не являются предками main, их собственные диффы трогают make_task/pre_critic/freeze/done. Дерево совпадает с eb136a. land_project.sh:81 делает merge --no-ff, так что оба коммита войдут в историю main. Зоны 187 они не нарушают. Совет: сажать дерево eb136a2664 (ветка wip/187/implementer-door-1115) без этого merge.
С-4 [050]: TOY_CLI собирается 20 вызовами .replace() по плейсхолдерам с assert на импорте. Проще одна инъекция JSON-таблицы ответов locate (const T=__TABLE__), строки приёмки те же.
С-5 [след]: ветвь outside в arch187_zones пропускает путь молча (continue без строки), а Д4 печатает «вне модели». Правило владельца строку для Д3 не требует.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефакту — ответы на вопросы (1)–(5):
  • ARCH187_LOCATE_KIND (новый глобал, 5 значений): (1) различение классов Д3/Д4; (2) состояние явное, задокументировано в шапке arch187_locate; (3) правка свойства затрагивает 1 файл; (4) интерфейс по образцу ARCH187_REFUSAL/ARCH187_LOCATE_COMPS, глубина приемлема; (5) потребитель — arch187_zones, клетки Д3/Д4 — ESSENTIAL.
  • arch187_model_check, gate/unresolved: (1) Д1 :27/:41; (2) unresolved только печатается; (3) 1 файл; (4) интерфейс прежний, rc 0/1/2; (5) клетки Д1 — ESSENTIAL.
  • exit "$rc" двери: (1) Д1 «exit = rc функции»; (2) нет нового состояния; (3) 1 файл; (4) —; (5) check-rc2-real-gate — ESSENTIAL.
  • arch187_zones, перестройка каталог/путь: (1) Д2/Д4; (2) нет нового состояния; (3) 1 файл; (4) интерфейс прежний; (5) клетки Д2/Д4 — ESSENTIAL.
  • Семья toy-констант и TOY_CLI-шаблон, CHECK_RC_TOKENS, action 'door', помощники locate_answer/union_components/line_components/parent_dir: (1) клетки 13 входов; (2) состояние в константах, явное; (3) одно свойство — fixture плюс toy вместе, рост в пределах одного файла; (4) см. С-4; (5) потребитель — --model/--stabs/--repo в CI — ESSENTIAL, форма шаблона ACCIDENTAL (С-4, совет).

СВЕРКА-АРХИТЕКТУРЫ: не применима к харнессу по существу; дверь 187а сверена с закреплённым пином 907e9e80 бэкенда замером (Б-1).
СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md / docs/CODING-STANDARDS.md (grep 'ARCHITECTURE\.md|CODING-STANDARDS' AGENTS.md @bd99 → нет совпадений) — сверять не с чем.
ПРОВОДКА: guard=red_architecture_process_187.sh и guard=scripts/check_architecture_contract.sh (frozen :135–136) — оба в объекте; барьер именно этого предмета (клетки --repo зовут публичную дверь, action 'door' → bash scripts/check_architecture_contract.sh --repo).

НЕ ПРОВЕРЯЛ: fixtures/workshop_project/arch_component_170/red_arch_component_170.sh и check_architecture_contract.sh --repo . contracts/187-…md (заявлено ведущим как rc 0; мною не запускались — вне разрешённого узкого прогона).

МАТЕРИАЛЫ (только чтение, кроме клона): /tmp/dev-harness-verify/rev187doorB-d1.sh, rev187doorB-d3.sh, rev187doorB-multi.sh, rev187doorB-mut.sh. Клон /tmp/rev187doorB-345160-1794754690 удалить не удалось: rm отклонён охраной Н-85/А-122 (путь вне null-allowlist). Его нужно удалить оркестратору. Push не делал, в общий checkout не писал.
