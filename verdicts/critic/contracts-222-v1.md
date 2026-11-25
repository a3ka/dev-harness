FAIL
OBJECT=d8b663ea45b023c82e402f5d1826d15cab943f22
СУД: репо=dev-harness; предмет=222; роль=critic; вызов=1 (полный); фаза=v1; модель-план=zai/glm-5.3 (критики на GLM, слово владельца); модель-факт=zai/glm-5.3; предыдущий=нет; класс риска=рисковый (заявленный архитектором — подтверждаю: ложный допуск модели-факта материализует неподтверждённое судейское доказательство)

Заявленные архитектором числа воспроизведены все (сырые строки ниже). FAIL — три блокирующих находки: неклассифицированный CI-потребитель двери (семья 198) и два живых мутанта сравнения (подстрока selector, дефис привязки). Классификация мест и красная батарея в остальном сильные: семь атак критика пять пойманы, green-полюс двусторонности подтверждён.

## Сырые прогоны (станция, TMPDIR=/tmp/dev-harness-verify/scratch-crit222)

- `bash scripts/check_sdacha.sh "$PWD" contracts/222-sudja-ljubaja-model.md --run` → rc 0, вывод `СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=0)` — совпадает с заявленным.
- `bash scripts/pre_critic.sh contracts/222-sudja-ljubaja-model.md` → rc 0, `КРИТИК: дверь зелёная`.
- `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --repo .` → rc 1, `SUBJEKT 222: KLETKI 64 KRASNYH 22`. Красные (22): spawn-{critic,adversary,reviewer,arbiter}-other-family, verdict-{…4…}-per-call, gate-{…4…}-per-call, spawn-manual-fallback, spawn-effort, verdict-effort, verdict-manual-fallback, verdict-same-model-as-author, spawn-unconfigured (rc верный, причина «модель не тира роли» вместо «модель не объявлена»), verdict-per-call-wrong-fact (rc 2 вместо 1), verdict-unconfigured-assignment (причина), fork-consultant-arbiter-same-model, fork-witness-author-same-model. Совпадает с SDACHA дословно.
- `… --model` → rc 0, `MODEL 222: KLETKI 64 KRASNYH 0`.
- `… --stabs` → rc 0, `STABY 222: STABS 25 ZHIVYH 0` (все 25 строк `KRASNYJ`).
- `… --catalog` → rc 0, `KLETKI=64 STABS=25 SVJAZI=39`.
- `… --sintaksis` → rc 0.
- `bash scripts/check_precision_gate.sh . contracts/222-sudja-ljubaja-model.md` → rc 0 (`OK`).
- `python3 fixtures/workshop_project/lyubaja_model_222/catalog.py --frozen` и `--overlaps` → OVERLAPS=118, каждый номер имеет ПЕРЕСЕЧЕНИЕ-строку контракта; одноранговые пересечения 099/104/166/186 объявлены явно сверх механики.
- `grep -n $'\t222' registry/plan.tsv` → пусто (rc 1). Дословно: строки плана 222 в registry/plan.tsv main нет, owner-PR #1351 в очереди — по заданию НЕ блок.
- Н-458 в NABLIUDENIA.md дерева OBJECT нет — контракт сам объявляет это в КОНТЕКСТ и не выдаёт отсутствие записи за отсутствие боли. Слова владельца 24.11 ~18:53/~18:56 UTC приведены в КОНТЕКСТ дословно.
- Дельта OBJECT: 10 файлов +922, все внутри ЗОНА architect (contracts/222 + fixtures/workshop_project/lyubaja_model_222/); roles/, AGENTS.md, .omp/ не тронуты — как заявлено.

## Карта классов

К-01: чисто — bash scripts/check_sdacha.sh "$PWD" contracts/222-sudja-ljubaja-model.md --run rc 0 (двери=10 карта=17/17 дельта=0) и bash scripts/pre_critic.sh contracts/222-sudja-ljubaja-model.md rc 0, допустимость отказа по отсутствию plan.tsv строки 222 задана предметом
К-02: блок — семья frozen 198 не классифицирована в «Существующее» (Блок 1)
К-03: блок — действующие обязательства 198/1 о двери спавна инвертируются без объявления (Блок 1)
К-04: блок — файлы fixtures/workshop_project/modeli_tolko_v_reestre_198/ потребуют правки без ЗОНЫ и ПЕРЕСЕЧЕНИЯ (Блок 1)
К-05: чисто — пункты приёмки 1–7 несут команды с rc (режимы --repo --model --stabs --sintaksis --catalog, pre_critic, check_sdacha, npm run gen:harness -- --check)
К-06: чисто — клетки spawn-no-config spawn-broken-config verdict-missing-trace требуют rc 2 и ловят его, NOT_IMPLEMENTED пути дают rc 2
К-07: чисто — bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model rc 0 (64/0) на настоящих node git jq этой станции, референс не двойник
К-08: блок — живые мутанты A6 (подстрока selector) и A7 (дефис привязки объекта) проходят все 64 клетки (Блоки 2–3)
К-09: чисто — клетки CASES покрывают batch и flat четыре роли-судьи восемь рабочих ролей per-call primary auto-fallback bare/full effort session OBJECT вторую строку
К-10: чисто — наблюдаемые эффекты суть точные байты journal candidates.tsv точные байты --tsv --bind и захваченный argv --model стаба omp
К-11: чисто — ожидания в замороженном dataclass Case родительской памяти, fork-референс читается из git-объекта 8b52fade7 по fork_policy.json с drift-отказом
К-12: чисто — резолвер roles.ts (readAgentModels resolveModelRef resolveRoleModel), JSON.parse, node --check, bash -n, pinned shellcheck через validate_std
К-13: н/п — секреты не входят в предмет, батарея не делает сетевых и модельных вызовов
К-14: блок — честная запись с суффикс-различием и дефис-привязкой не отличима от подделки (Блоки 2–3), зелёный полюс bare/full и одинаковой модели автора зелён в --model rc 0
К-15: чисто — bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --catalog rc 0 KLETKI=64 STABS=25 SVJAZI=39 из вывода, --repo KRASNYH 22 совпадает с SDACHA
К-16: чисто — класс риска рисковый подтверждён по смыслу предмета, модель угроз по свойствам с ловцами в НЕ ЗАЩИЩАЕТ, check_threat_model rc 0
К-17: н/п — харнесс без sourceCanon, новых операций и схем не вводится

## Блоки

БЛОКИРУЕТ contracts/222-sudja-ljubaja-model.md:22–59 — «Полный список ниже — классификация мест» пропускает действующего CI-потребителя двери: семью frozen 198/1 `fixtures/workshop_project/modeli_tolko_v_reestre_198/` (шаг `check:modeli-reistra-198-family-selftest`, registry/ci-steps.tsv:316, .github/workflows/ci.yml:278). В таблице «Существующее» есть 104, 173, fork_route — семьи 198 нет; grep «198» по контракту находит только резолвер roles.ts (:26, :63), не семью.
ОБЯЗАТЕЛЬСТВО: И1 (contracts/222-sudja-ljubaja-model.md:71) — запасная per-call и модель другого тира/семейства на `--spawn` дают rc 0, «--spawn проверяет объявленность, но не равенство основной». Семья 198 требует противоположного на тех же входах: fixtures/workshop_project/modeli_tolko_v_reestre_198/probe.py:532–543 `door_spawn_fallback_refused` (фолбэк тира → rc 1 «не тира роли», docstring: «обязательство 104: только primary»), :547–568 `door_spawn_foreign_refused` (primary другого судьи → rc 1), :642–658 `door_stale_primary` (переставленная модель, остающаяся в models → rc 1). Мир семьи копирует ПРОДАКШН scripts/check_sud_model.sh (probe.py:134–135), режим --model гоняет его в CI.
СОСТОЯНИЕ: дерево после реализации 222 (клетки spawn-manual-fallback и spawn-{роль}-other-family обязаны позеленеть) — достижимое и обязательное, не синтетика.
НАБЛЮДЕНИЕ: в одноразовом клоне OBJECT с единственной правкой спавн-ноги scripts/check_sud_model.sh (объявленность в конфиге вместо равенства основной, bash -n ok) `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --model` → rc 1: `CELL door_spawn_fallback_refused КРАСНА … rc=0`, `CELL door_spawn_foreign_refused КРАСНА … rc=0`, `CELL door_stale_primary КРАСНА … rc=0`, `CELLS=28 FAILURES=3`; baseline без правки — FAILURES=0 rc 0. CI main краснеет сразу после ленда 222.
ОБХОД: классифицировать семью 198 в «Существующее» с миграцией ровно трёх клеток на ожидания 222 (объявленные fallback/чужая/устаревшая → rc 0, отказ остаётся на необъявленной и вне алфавита) и завести ЗОНА/ПЕРЕСЕЧЕНИЕ implementer для fixtures/workshop_project/modeli_tolko_v_reestre_198/ — либо явно объявить остаток с ловцом. Молчание оставляет исполнителя перед выбором «красный CI или правка вне зон».
ПРОИСХОЖДЕНИЕ: полный вызов (первый, не из дельты автора). КЛАСС: К-02/К-03/К-04.

БЛОКИРУЕТ contracts/222-sudja-ljubaja-model.md:79 — объявленная норма «effort и route являются частью selector, а не сравниваются по подстроке» не имеет различающей клетки.
ОБЯЗАТЕЛЬСТВО: та же строка 79 «Аргументы и поля сравниваются буквально, кроме уже принятой 173 эквивалентности одного bare/full имени» + И2 (:73): факт≠назначение — отказ до append.
СОСТОЯНИЕ: дверь, чья сверка сравнивает подстроку (`same(a,b) = a===b || a.includes(b) || b.includes(a)`), принимает факт, отличающийся от назначения усечением/расширением суффикса effort, и материализует вердикт на неверном факте. Источник входа наблюдаемый и явно утверждённый: реестр уже содержит пару, различающуюся только суффиксом (config/agent_models.json:14–15 «gpt-sol» / «gpt-sol-xhigh»), 222 сам вводит per-call назначение и пару FACT/EFFORT в собственной батарее; оркестратор переносит назначение из запроса, факт приходит трассой — та же дверь, тот же протокол.
НАБЛЮДЕНИЕ: мутация krit-A6-sravnenie-po-podstrobe (замена операции сравнения в model/check_sud_model.ts, синтаксис проверен) проходит ВСЕ 64 клетки: `MUTACIJA krit-A6-sravnenie-po-podstrobe: KRASNO=0 (ZHIV)`. Батарея не отличает честный компаратор от подстрочного.
ОБХОД: двусторонняя пара — красная клетка verdict/gate с назначением, несущим суффикс (EFFORT='other-vendor/other-family-9:xhigh'), и фактом без суффикса (FACT) → rc 1 «вердикт не материализуется»; зелёный полюс уже есть (verdict-effort: совпадение selector вместе с суффиксом → rc 0).
ПРОИСХОЖДЕНИЕ: полный вызов (первый). КЛАСС: К-08/К-14.

БЛОКИРУЕТ contracts/222-sudja-ljubaja-model.md:73 — И2 «чужие session/OBJECT … — отказ до append» не имеет различающей клетки для документированного значения «-».
ОБЯЗАТЕЛЬСТВО: И2 (:73) и заявленное сохранение сверки «session/OBJECT и каждая строка — СВЕРКА остаётся» (таблица :30, scripts/check_sud_model.sh:232–247); frozen 104/2 Решение 2 документирует «-» как продукционное значение пятого поля (сессия без OBJECT= в тексте задания), граница входов 222 (:79) объявляет «OBJECT либо `-`».
СОСТОЯНИЕ: дверь, принимающая «-» за совпадение объекта (`if (o !== object && o !== '-')`), материализует вердикт по трассе непривязанной сессии. Источник входа наблюдаемый: models_actual.sh --bind печатает «-» именно для сессий без OBJECT — замер 104/2 Решение 2.
НАБЛЮДЕНИЕ: мутация krit-A7-object-defis-prinyat проходит все клетки: `MUTACIJA krit-A7-object-defis-prinyat: KRASNO=0 (ZHIV)`.
ОБХОД: клетка verdict/gate со строкой трассы, у которой пятое поле «-» при переданном --object → rc 1 «трасса не об объекте суда»; зелёный полюс есть (trace-binding с реальным OBJECT).
ПРОИСХОЖДЕНИЕ: полный вызов (первый). КЛАСС: К-08/К-14.

## Атаки мутациями критика (сырой вывод, одноразовый прогон против референса)

- `MUTACIJA krit-A1-spawn-bez-obiavlennosti: KRASNO=1 spawn-unconfigured` — поймана.
- `MUTACIJA krit-A2-fakt-dostatochno-vpisan: KRASNO=4 verdict-fact-not-assigned verdict-per-call-wrong-fact verdict-second-row-mismatch gate-wrong-fact` — «пропуск любой вписанной модели маскирует сверку факта» пойман.
- `MUTACIJA krit-A3-denied-fallback-ne-sveryaetsya: KRASNO=1 verdict-automatic-fallback` — поймана.
- `MUTACIJA krit-A4-neobiavlennyi-override-prinyat: KRASNO=1 verdict-unconfigured-assignment` — поймана.
- `MUTACIJA krit-A5-gate-ignoriruet-otkaz-dveri: KRASNO=3 gate-foreign-session gate-foreign-object gate-wrong-fact` — поймана (отказ до append).
- `MUTACIJA krit-A6-sravnenie-po-podstrobe: KRASNO=0 (ZHIV)` — живой, Блок 2.
- `MUTACIJA krit-A7-object-defis-prinyat: KRASNO=0 (ZHIV)` — живой, Блок 3.

Проверено и не является дырой: удаление проверки пустых полей трассы неотличимо по построению — пустые факт/сеанс/объект/статус ловятся алфавитами selector/session/hex и списком allowed|denied, отдельная клетка не нужна.

## Красное ДО и путь позеленения (по тексту контракта)

22 красные --repo разложены контрактом точно: спавн-нога (12 клеток: 4 other-family, manual-fallback, effort, unconfigured-причина) — снять равенство основной, проверять объявленность резолвером, расширить алфавит `:effort/@route`; verdict-нога (8: 4 per-call, effort, manual-fallback, same-model-as-author, per-call-wrong-fact, unconfigured-assignment) — аргумент `--assigned-model` у check_sud_model --verdict, ожидание = override ?? назначение роли, необъявленный override → rc 2 «назначенная модель не объявлена»; judge_gate (4 per-call) — хвост `--assigned-model` после тройки --sud, отказ до append сохраняется; fork_route (2) — снять модельные прокси по fork_policy.json от базового объекта 8b52fade7. Сверка факта/сеанса/объекта/каждой строки не ослабляется: отказные клетки зелёны сейчас и обязаны остаться зелёными (контроль --model и --stabs). Frontier А/Б/В: выбор А обоснован — Б мигрирует всех потребителей ради одного запрета, В воспроизводит второй источник простоя; отклонения достаточны.

## НЕ ЗАЩИЩАЕТ (остатки с ловцом)

- Конечность батареи: и после закрытия Блоков 2–3 остаются иные релаксации сравнения/привязки. Ловец — adversary рисковой реализации (объявлен приёмкой 7) и reviewer на одном OBJECT.
- Пин байтов stdout production двери («СУДЬЯ СВОЕЙ МОДЕЛИ: …», zasev_trassy_209 judge-fact) и однофайловость двери (миры семей копируют только scripts/check_sud_model.sh). Ловец — CI шаг 209 и check_sdacha 222.
- Происхождение переданного --assigned-model и подлинность доверенной зоны JSONL — граница 028/104, ловец оркестратор и trace-протокол (заявлено контрактом, проверять нечем).
- Идентичность актора не по модели: запрет самосуда остаётся cognitive-only. Ловец — независимый reviewer и доверенная история сессий.

## Советы

1. zasev_trassy_209 probe.py (клетка judge-fact) пинит побайтно успешную диагностику production двери — реализации следует сохранить сообщение «СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт … материализуется»; контракт об этом молчит, решение осталось исполнителю.
2. Дверь обязана остаться однофайльной bash: двуфайловый .sh+.ts референс в мирах, копирующих только .sh, даёт `Cannot find module` и 10 красных клеток 198 (наблюдено в клоне). Стоит назвать это ограничение в контракте явно.
3. roles/consultant.md:270–272 «топовые модели — только по слову владельца» остаётся действующим: совместимо с конфигом как единственным источником (слово владельца = запись в конфиг), но строку стоит упомянуть в «Существующее», чтобы не выглядела вторым списком.
4. Затравка consultant/draft-222-sudja-ljubaja-model.md в дереве OBJECT отсутствует — сохранена внутри contracts/222 первым коммитом 3f9b1de8b (13 строк); SHA ветки 25a120a2b/d18238991 не предки OBJECT (та же работа перебазирована как 3f9b1de8b/d8b663ea4). Действия не требует.
5. Форма: строки плана 222 в registry/plan.tsv нет — дословный именованный отказ допустим по заданию, план не чинится пачкой; Н-458 в NABLIUDENIA.md OBJECT отсутствует и честно объявлена контрактом.
