# СДАЧА 231 — формы done из закоммиченного конфига (R-0162)

ПРЕДМЕТ: три исторических представления done из config/done_forms.json; исправление единственного блока Crit231 К-04/К-07 — самостоятельная установка регресса 224. Production scripts/done_contract.sh не меняется. До freeze 231 orchestrator оформляет адресные v+1 224/201 и их freeze.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-231-v1.md

## Обещание и наблюдение

Полный CLI, настоящий Git, rc и раздельные трубы, annotated done на исходном HEAD; отказ без тега и изменения HEAD. Ожидания и HEAD снимаются до субъекта; конфиг/схема — из installation HEAD, отдельно от author HEAD/index/worktree/env. Новые формы задаются только конфигом, JSON Schema проверяет настоящий validate_std json. Оракул старых клеток 224 не меняется.

База исправления 4ad679feda7bd00e8884ee77a6d74a62d6db4285. Source-базис двери 568f0ea63271e3461b574105cba8faec7563a8fd сохранён. Scratch, TMPDIR и origin-клон — только внутри своей копии. Независимый TMPDIR — вложенный пустой Git-репозиторий без HEAD: Git не может подняться к HEAD родителя, записи вне копии не нужны.

## Адресная дельта frozen

v+1 224 делегирует формы/сверку вызова конфигу 231; v+1 201 делегирует литералы ПРОДУКТ тому же источнику (уже в базе). В этом исправлении 201 не меняется: его установщик не задействован, production-регресс отдельно запускается прежней командой.

review-conflict: было rc 1 VERDICT_ROUND_CONFLICT → стало rc 1 VERDICT_ROUND_DUPLICATE (ключ 3000000000).

adversary-conflict: было rc 1 VERDICT_ROUND_CONFLICT → стало rc 1 VERDICT_ROUND_DUPLICATE (ключ 3000000000).

Третья дельта 224: общий install после прежнего копирования scripts/ и bash -n создаёт свой Git, копирует config/done_forms.json, config/done_forms.schema.json, ops/server/validators.tsv и коммитит HEAD. Остальные scripts/ и все старые клетки/ожидания неизменны. Черновик 224 дополнен отдельным коммитом; строку слова владельца оформляет orchestrator, не architect.

## Дельта

Единственный блок К-04/К-07 закрыт способом канон/инструмент: обе батареи используют общий настоящий install 224 и прежний suite 224 без адаптера install_policy. Конфиг читается из HEAD собственной установки. Снятие/граница не применены: обещание сохраняется полностью. Новый оракул не написан — install224.py вызывает прежний suite на честных historic186 и соседнем historic129, сохраняя его проверки rc/труб/тега/HEAD.

Мутация критика — точный прежний scripts-only installer, генерируемый в stabs/scripts-only/install.py. Адресная связь задана install224.LINKS, включена build.py в прежние source.json/stabs.tsv и выполняется независимо. Она предъявляется только независимому TMPDIR, где дефект наблюдаем; checkout-клетка — честный эквивалентный режим. Прежние 97 клеток/24 стаба/68 связей сохранены; добавлены две клетки среды и один стаб/одна связь. Каждый режим отдельно вызывает оба исторических входа. Значения SHA/идентификаторов не становятся оракулом.

- К-04 · канон/инструмент · python3 -B fixtures/workshop_project/done_round_compat_231/install224.py --case install224-checkout · 0 · 0
- К-07 · канон/инструмент · python3 -B fixtures/workshop_project/done_round_compat_231/install224.py --case install224-independent · 0 · 0
- К-07 · канон/инструмент · python3 -B fixtures/workshop_project/done_round_compat_231/install224.py --case install224-independent --scripts-only · 1 · 1

## Измерения исправления

До правки install: install224-independent rc 1, historic186 и historic129 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n', RED RC,TAG_TARGET,STDERR. Внутри checkout оба входа RAW 0, rc 0 — случайная родительская установка.

После правки install: оба режима rc 0, historic186 и historic129 RAW 0 b'' b'', GREEN. Прежний scripts-only installer в независимом TMPDIR rc 1, оба входа RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'. Команды — строки дельты; результаты получены до полного origin-прогона.

Генератор: NOSITELI 26 STABY 25 SVJAZI 69. Census 97→99 клеток, 24→25 стабов, 68→69 связей; независимая мера — прежний AST-каталог плюс install224.CASES, файлы стабов и строки TSV. Полные прогоны выполняет acceptance.py по одной, включая reference и production 224 в ОБОИХ TMPDIR, регрессы 201/187/193, pre_critic, check_sdacha --run, precision и spec. Сырые stdout/stderr/results.json сохраняются в tmp/acceptance231 внутри origin-клона.

B = bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh. До реализации B --repo . намеренно красен: прежние 56 клеток совместимости (старые имена, независимый вызов, конфиг/точка). Две новые клетки установщика проверяют честную установку и не добавляют production-отказов. Регресс production 224 до реализации красен ровно review-conflict/adversary-conflict; reference должен быть зелён независимо от TMPDIR.

## Двери

- Sintaksis · bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh --catalog · 0 · 0
- Schema · bash scripts/validate_std.sh json config/done_forms.schema.json config/done_forms.json · 0 · 0
- Context · fixtures/workshop_project/done_round_compat_231/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/231-sovmestimost-doski-224.md · 0 · 0
- Consumer · bash scripts/check_spec_ready.sh . contracts/231-sovmestimost-doski-224.md · 0 · 0
- Precritic · bash scripts/pre_critic.sh contracts/231-sovmestimost-doski-224.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы, pinned shellcheck и validate_std json · - · -
- К-02 · чисто · вход: task-architect231c.md и предшествующие задания, R-0162, отдельный коммит frozen 224 · - · -
- К-03 · чисто · вход: переход v+1 224/201 до freeze 231, слово владельца оформляет orchestrator · - · -
- К-04 · чисто · вход: контракт 231 разрешает ровно установщик и две клетки 224, context.py высшие frozen · - · -
- К-05 · чисто · вход: B --model/--repo, rc/трубы/tag/HEAD; legacy/215/227 без переименований · - · -
- К-06 · чисто · вход: ошибка среды/таймаут/синтаксис rc 2 NOT_IMPLEMENTED, не предметная поимка · - · -
- К-07 · чисто · вход: install224.py оба TMPDIR, общий install и настоящий suite 224, historic186/historic129 · - · -
- К-08 · чисто · вход: B --stabs, scripts-only только на independent-клетке, прежние адресные связи сохранены · - · -
- К-09 · чисто · вход: review/adversary, оба направления конфликта, numeric 2/10/100, два режима TMPDIR · - · -
- К-10 · чисто · вход: committed installation HEAD против index/worktree/author/env, ожидания до субъекта · - · -
- К-11 · чисто · вход: source.json хеширует носители, TSV из кода, прежний suite хранит ожидания до двери · - · -
- К-12 · чисто · вход: bash -n, pinned shellcheck, compile Python, JSON Schema через validate_std · - · -
- К-13 · н/п · новых credentials и внешней сети в оракуле нет · - · -
- К-14 · чисто · вход: station без/с точкой, owner/repo., filename-only, equal-call, JSON-equivalent, checkout TMPDIR · - · -
- К-15 · чисто · вход: --catalog, AST/FS/TSV census, прежние 97/24/68 сохранены · - · -
- К-16 · чисто · вход: границы и ловцы сохранены, обещание регресса не сужено · - · -
- К-17 · н/п · продуктовая модель 188 не объявлена, новых операций/writer/scope_id нет · - · -

## Наблюдение процесса

Кандидат записи main-журнала без самовольного номера: при новом installation HEAD старый установщик scripts-only случайно зеленеет внутри checkout, читая чужой HEAD; явная изоляция TMPDIR пустым Git-контейнером делает дефект наблюдаемым без записи вне копии. Цена — один исправительный круг Crit231; источник — verdicts/critic/contracts-231-v1.md; класс — конструкция регрессионной установки. Закрыто общим install и адресной scripts-only мутацией на historic186/historic129 в независимом TMPDIR. NABLIUDENIA_ARCHITECT.md в wip не меняется; запись в main — orchestrator.
