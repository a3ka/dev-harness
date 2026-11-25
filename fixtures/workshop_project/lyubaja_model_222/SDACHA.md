# СДАЧА 222 — свобода назначения, а не свобода подделки факта

База: 8b52fade7975034d7cabece67e46c16a7d1abe3b. Production в этой пачке не меняется. Предмет и классификация — contracts/222-sudja-ljubaja-model.md. Reference — достижимый честный контроль публичных швов, не обязательный текст реализации. Н-39: исполняемый реестр source.json содержит адрес каждой мутации и перечень её собственных входов; контракт эту таблицу не пересказывает.

Исправление Adv222 К-08/К-09 на базе 98994a152290b31c8bbfad09e2cca1f2c5bb2a8d: меняется только эта fixture-семья; контракт и production не меняются. Текущий замер: `--repo .` и `--model` — 83 клетки, 0 красных, rc 0; `--stabs` — 35 стабов, 35 поймано, 0 живых, rc 0; `--catalog` — `KLETKI=83 STABS=35 SVJAZI=64`, rc 0; `--sintaksis` — rc 0. Исходный red-до ниже — исторический замер, не пересчитан на реализации.

Новые клетки 77–83 (порядок `cases()`): verdict-denied-per-call-wrong-fallback, verdict-denied-per-call-fallback, verdict-denied-per-call-different-assignment, verdict-assigned-empty, verdict-assigned-empty-before-root, verdict-assigned-missing-at-end, verdict-assignment-absent. Отрицательный denied/per-call даёт rc 1 «фолбэк вне списка тира»; честный fallback проходит и при назначении самого fallback, и при другом объявленном назначении. Пустой selector в конце и перед --root, а также последний флаг без значения дают rc 2 «назначенная модель пуста», без строки материализации и без verdict-журнала; отсутствие флага сохраняет rc 0. Последний флаг ограничен существующим таймаутом subprocess (40 с): зависание превращается в наблюдаемый rc 124 и красную клетку, не NOT_IMPLEMENTED.

st34/st35 в stabs/ — рецепты материализации копий production из неизменяемого git-объекта базы; каждая замена и native bash syntax проверяются до предъявления. Н-39: привязка к новым входам исполняется source.json, не этой прозой. Адресная проба `PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/lyubaja_model_222/check_adv222.py` предъявляет оба стаба своим новым клеткам и независимо мутирует текущую production в других местах: пустое назначение = отсутствие и continue при denied/per-call. На каждом предъявлении ожидается ровно свой набор красных клеток; честные зелёные полюса входят в полный --repo/--model.

Измерено до реализации (числа из вывода команд листа): `--repo .` — `SUBJEKT 222: KLETKI 76 KRASNYH 29`, rc 1; `--model` — `MODEL 222: KLETKI 76 KRASNYH 0`, rc 0; `--stabs` — `STABY 222: STABS 33 ZHIVYH 0`, rc 0; `--catalog` — `KLETKI=76 STABS=33 SVJAZI=60`, rc 0; `--sintaksis` — rc 0. Перечень KRASNO `--repo .` — наблюдение, не эталон количества красных строк для будущей реализации: двенадцать клеток спавн/verdict/gate по четырём судьям, spawn-manual-fallback, spawn-effort, verdict-effort, verdict-manual-fallback, verdict-same-model-as-author, spawn-unconfigured (причина), verdict-per-call-wrong-fact, verdict-unconfigured-assignment, пять клеток подстроки/суффикса (verdict-effort-fact-truncated, verdict-effort-fact-extended, gate-effort-fact-truncated, spawn-substring-of-declared, verdict-assigned-substring-undeclared), две суффиксные клетки объявления (spawn-suffix-of-declared, verdict-assigned-suffix-undeclared: старая дверь отказывает суффикс селектора как «не тира роли» и не принимает --assigned-model) и два модельных прокси fork_route. Клетки verdict-object-dash, gate-object-dash, verdict-fact-case, gate-fact-case и sosed-198-door-cells зелёны на production: отказ на `-`, буквальный отказ регистра и сверка соседней семьи уже есть, они защищают реализацию от регресса.

Соседняя семья frozen 198: клетка sosed-198-door-cells запускает её неизменённый probe `--model` в копии, где дверь — испытуемая, и допускает красными только door_spawn_fallback_refused, door_spawn_foreign_refused, door_stale_primary. Четвёртая снятая клетка, repo_door_judges (`--repo`), измерена отдельно на reference: красна на «adversary на чужой модели обязан отказывать: rc=0». Все четыре перепиниваются implementer'ом (зона и ПЕРЕСЕЧЕНИЕ в контракте), текст frozen 198 не правится; прочие ожидания 198 reference выдерживает (denied-факт вне fallback тира отказан с «фолбэк вне списка тира»).

Фактические швы: настоящий scripts/check_sud_model.sh и judge_gate.sh (полные байты append); настоящий register/tool_call расширения 104 (без развёрнутого замка 140); настоящие models_actual/roles/gen-harness и fork_route. Лаунчер — настоящий workshop до exec, stub omp только регистрирует argv, мир переиспользует World семьи 209 без её суждений/оракула. Сетевая доступность selector не заявлена. Пин reference fork_policy.json — неизменяемый исходный commit; патч меняет только модельные прокси, все остальные условия берутся из этого исходника, не из испытуемого дерева.

Среда прогона: VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Команды листа наследуют среду. Temp-миры удаляются TemporaryDirectory; наружные state/zone каталоги стенда 209 находятся внутри этих миров. Для native syntax используются настоящий Node, bash -n и штатный validate_std, не самописный разбор shell/TypeScript.

Граница: подлинность доверенной зоны JSONL и происхождение переданного назначения остаются за протоколом 028/104 и оркестратором. Новый CLI-аргумент не удостоверяет сам себя. Модель ≠ актор; удаление модельного fingerprint не выдаётся за новый доказанный механизм личности. Адресное разрешение на role-файлы и строку плана обеспечивает оркестратор/владелец до соответствующей операции; строки РАЗРЕШИЛ в этой пачке не выдуманы. Решение «перепин клеток 198, не v+1 198» вынесено в «Незаполненные требования» контракта с условием отмены по слову владельца.

## Двери

- Honest-control · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model · 0 · 0
- Bound-mutations · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --stabs · 0 · 0
- Native-syntax · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --catalog · 0 · 0
- Addressed-Adv222 · fixtures/workshop_project/lyubaja_model_222/check_adv222.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/222-sudja-ljubaja-model.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: все двери формы перечислены выше; отсутствие plan.tsv не исправляется этой пачкой · - · -
- К-02 · чисто · вход: два дословных слова владельца в КОНТЕКСТ, сохранённая затравка и полная классификация существующего, включая семью 198, zasev_trassy_209 и consultant.md:270–272 · - · -
- К-03 · чисто · вход: catalog.py --frozen прочитал 028/3, 099/1, 104/2, 129/2, 140/5, 166/2, 186/2, 198/1; спавн-сценарии 198 названы заменяемыми, остальные обязательства 198 сохранены клеткой sosed-198-door-cells · - · -
- К-04 · чисто · вход: ЗОНА architect/implementer/orchestrator, актуальные frozen overlaps (в том числе семья 198 для 105 и 198), защищённые role-файлы только по адресному слову владельца · - · -
- К-05 · чисто · вход: каждый пункт приёмки несёт исполняемую команду и rc; новые режимы без неявной подмены субъекта · - · -
- К-06 · чисто · вход: spawn-no-config и spawn-broken-config дают rc 2; отсутствие зависимости/якоря/исходника не засчитывается за красноту · - · -
- К-07 · чисто · вход: --model в среде продукта зелён; новые модели проверяются настоящими CLI/генератором/хуком, а не их двойниками; sosed-198-door-cells гоняет настоящий probe 198 · - · -
- К-08 · чисто · вход: --stabs требует красноты каждого адреса каждой записи source.json; перед предъявлением проверяется native syntax мутанта; подстрока selector (четыре записи), суффиксная и регистровая релаксации компаратора same() (две записи) и дефис привязки (одна запись) предъявлены своим входам · - · -
- К-09 · чисто · вход: batch/flat, четыре роли-судьи, рабочие роли, per-call/primary/automatic fallback, bare/full, effort, session/OBJECT, вторая строка · - · -
- К-10 · чисто · вход: exact byte journal одной verdict-строки либо отсутствие append, exact byte bound TSV, реальный argv --model; строки диагностики не выданы за побайтовый канон вывода · - · -
- К-11 · чисто · вход: immutable Case и ожидаемые литералы в родительской памяти до запуска, reference fork из фиксированного git-объекта · - · -
- К-12 · чисто · вход: readAgentModels/resolveModelRef/resolveRoleModel из настоящего roles.ts, JSON.parse, native node --check, bash -n и pinned shellcheck · - · -
- К-13 · н/п · Секреты не являются входом/выходом предмета; стенд запускается с фиктивными credentials, внешних model/API запросов нет · - · -
- К-14 · чисто · вход: bare/full и effort остаются зелёными, одинаковая модель у автора/судьи и consultant/arbiter остаётся зелёной, отличие факта от назначения (в том числе только суффиксом effort, регистром и привязкой `-`) красно; суффикс объявленного selector'а не объявлен: --spawn rc 1 «модель не объявлена», --assigned-model rc 2 «назначенная модель не объявлена» · - · -
- К-15 · чисто · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --catalog · 0 · 0
- К-16 · чисто · вход: безопасность подлинности судейского факта, explicit доверенная граница назначения/JSONL и сохранённый запрет самосуда · - · -
- К-17 · н/п · Харнесс, без sourceCanon/architecture.lock; новые продуктовые операции/ресурсы/writers/isolationKeys не вводятся · - · -

## Дельта

Исправление по вердикту critic v1. Блок 1 (семья 198) закрыт классификацией в контракте, заявленным механизмом (перепин, зона и ПЕРЕСЕЧЕНИЕ) и клеткой совместимости; блоки 2 и 3 — клетками на реальных входах CLI и адресными стабами. Соседние мутации: подстрока только в объявленности (declared-by-substring), в одну сторону (fact-contains-assigned, assigned-contains-fact) и в обе (same-by-substring); denied на любой объявленной модели (denied-any-declared) ловится только входом соседней семьи. Честные эквивалентные записи остаются зелёными в --model: bare/full (verdict-bare-equivalent) и совпадение суффикса целиком (verdict-effort). Исправление по вердикту critic v2 (блок 4, К-08/К-14): суффиксная и регистровая релаксации компаратора same() закрыты клетками на реальных входах — суффикс объявленного (spawn-suffix-of-declared, verdict-assigned-suffix-undeclared) и регистровое отличие факта (verdict-fact-case и её gate-нога gate-fact-case через judge_gate.sh) — со стабами same-by-suffix и same-by-case; по замеру каждый красится ИМЕННО новыми клетками: endsWith и toLowerCase — ровно две красные, startsWith — пять прежних, includes — семь; зелёный полюс точных совпадений (verdict-primary, verdict-effort, spawn-primary) не менялся, мутация пустой строки остаётся наблюдаемо неотличимой (не дыра).

- К-02 · клетка · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model --case sosed-198-door-cells · 0 · 0
- К-03 · канон/инструмент · fixtures/workshop_project/lyubaja_model_222/catalog.py --frozen · 0 · 0
- К-04 · канон/инструмент · bash scripts/check_precision_gate.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --stabs · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model · 0 · 0
- К-08 · клетка · fixtures/workshop_project/lyubaja_model_222/check_adv222.py · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model · 0 · 0

## Рефлексия

Обнаружен не только Н-270: прежние модельные fingerprint в check_fork_route и текстовые пины critic/arbiter также ограничивают обещанную свободу. Они включены в единую классификацию Н-458 до заморозки, а не оставлены скрытым исключением. Вторая находка круга: сосед по CI — семья 198 — держит те же спавн-ожидания, и её четвёртая клетка живёт в режиме --repo, который reference не покрывает; она вынесена в И5 и приёмку 8, а не в батарею. Это находки предмета, не новые нумерованные процессные записи.
