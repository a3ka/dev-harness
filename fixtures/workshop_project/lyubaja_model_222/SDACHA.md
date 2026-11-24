# СДАЧА 222 — свобода назначения, а не свобода подделки факта

База: 8b52fade7975034d7cabece67e46c16a7d1abe3b. Затравка сохранена первым коммитом 25a120a2b; production в этой пачке не меняется. Предмет и классификация — contracts/222-sudja-ljubaja-model.md. Reference — достижимый честный контроль публичных швов, не обязательный текст реализации. Н-39: исполняемый реестр source.json содержит адрес каждой мутации и перечень её собственных входов; контракт эту таблицу не пересказывает.

Измерено до реализации: исходная батарея 59 клеток, --repo rc 1 (20 красных), --model rc 0. После добавления прямых launcher/fork-предъявлений reference — 64 клетки, --model rc 0; --stabs: 25 изменений, живых 0, rc 0; --catalog: KLETKI=64 STABS=25 SVJAZI=39, rc 0. Историческая мера 59 не объявляется текущим census. Окончательный --repo исполняется отдельно; его перечень KRASNO — наблюдение, не эталон количества красных строк для будущей реализации.

Окончательный production-прогон: `SUBJEKT 222: KLETKI 64 KRASNYH 22`, rc 1 (два дополнительных отказа — модельные прокси fork_route; остальные — неподдержанное явное назначение и запрет спавна вне тира). Reference в --stabs: `MODEL 222: KLETKI 64 KRASNYH 0`, `STABY 222: STABS 25 ZHIVYH 0`, rc 0. Native-syntax и catalog — rc 0. Требуемый standalone `pre_critic.sh contracts/222-sudja-ljubaja-model.md` — rc 0; standalone `check_sdacha.sh <корень> contracts/222-sudja-ljubaja-model.md --run` — rc 0, `СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=0)`. Исключение по отсутствующей строке плана не потребовалось.

Фактические швы: настоящий scripts/check_sud_model.sh и judge_gate.sh (полные байты append); настоящий register/tool_call расширения 104 (без развёрнутого замка 140); настоящие models_actual/roles/gen-harness и fork_route. Лаунчер — настоящий workshop до exec, stub omp только регистрирует argv, мир переиспользует World семьи 209 без её суждений/оракула. Сетевая доступность selector не заявлена. Пин reference fork_policy.json — неизменяемый исходный commit; патч меняет только модельные прокси, все остальные условия берутся из этого исходника, не из испытуемого дерева.

Среда прогона: TMPDIR=/tmp/dev-harness-verify/scratch-arch222; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Команды листа наследуют среду. Temp-миры удаляются TemporaryDirectory; наружные state/zone каталоги стенда 209 находятся внутри этих миров. Для native syntax используются настоящий Node, bash -n и штатный validate_std, не самописный разбор shell/TypeScript.

Граница: подлинность доверенной зоны JSONL и происхождение переданного назначения остаются за протоколом 028/104 и оркестратором. Новый CLI-аргумент не удостоверяет сам себя. Модель ≠ актор; удаление модельного fingerprint не выдаётся за новый доказанный механизм личности. Адресное разрешение на role-файлы и строку плана обеспечивает оркестратор/владелец до соответствующей операции; строки РАЗРЕШИЛ в этой пачке не выдуманы.

## Двери

- Honest-control · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --model · 0 · 0
- Bound-mutations · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --stabs · 0 · 0
- Native-syntax · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --catalog · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/222-sudja-ljubaja-model.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/222-sudja-ljubaja-model.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: все двери формы перечислены выше; отсутствие plan.tsv не исправляется этой пачкой · - · -
- К-02 · чисто · вход: два дословных слова владельца в КОНТЕКСТ, сохранённая затравка и полная классификация существующего · - · -
- К-03 · чисто · вход: catalog.py --frozen прочитал 028/3, 099/1, 104/2, 129/2, 140/5, 166/2, 186/2; совместимость и заменяемые модельные прокси указаны явно · - · -
- К-04 · чисто · вход: ЗОНА architect/implementer/orchestrator, actual frozen overlaps, защищённые role-файлы только по адресному слову владельца · - · -
- К-05 · чисто · вход: каждый пункт приёмки несёт исполняемую команду и rc; новые режимы без неявной подмены субъекта · - · -
- К-06 · чисто · вход: spawn-no-config и spawn-broken-config дают rc 2; отсутствие зависимости/якоря/исходника не засчитывается за красноту · - · -
- К-07 · чисто · вход: --model в среде продукта зелён; новые модели проверяются настоящими CLI/генератором/хуком, а не их двойниками · - · -
- К-08 · чисто · вход: --stabs требует красноты каждого адреса каждой записи source.json; перед предъявлением проверяется native syntax мутанта · - · -
- К-09 · чисто · вход: batch/flat, четыре роли-судьи, рабочие роли, per-call/primary/automatic fallback, bare/full, effort, session/OBJECT, вторая строка · - · -
- К-10 · чисто · вход: exact byte journal одной verdict-строки либо отсутствие append, exact byte bound TSV, реальный argv --model; строки диагностики не выданы за побайтовый канон вывода · - · -
- К-11 · чисто · вход: immutable Case и ожидаемые литералы в родительской памяти до запуска, reference fork из фиксированного git-объекта · - · -
- К-12 · чисто · вход: readAgentModels/resolveModelRef/resolveRoleModel из настоящего roles.ts, JSON.parse, native node --check, bash -n и pinned shellcheck · - · -
- К-13 · н/п · Секреты не являются входом/выходом предмета; стенд запускается с фиктивными credentials, внешних model/API запросов нет · - · -
- К-14 · чисто · вход: bare/full и effort остаются зелёными, одинаковая модель у автора/судьи и consultant/arbiter остаётся зелёной, отличие факта от назначения красно · - · -
- К-15 · чисто · bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --catalog · 0 · 0
- К-16 · чисто · вход: безопасность подлинности судейского факта, explicit доверенная граница назначения/JSONL и сохранённый запрет самосуда · - · -
- К-17 · н/п · Харнесс, без sourceCanon/architecture.lock; новые продуктовые операции/ресурсы/writers/isolationKeys не вводятся · - · -

## Дельта

Первый полный вызов; предыдущего вердикта 222 нет. Исправительные классы не заявлены.

## Рефлексия

Обнаружен не только Н-270: прежние модельные fingerprint в check_fork_route и текстовые пины critic/arbiter также ограничивают обещанную свободу. Они включены в единую классификацию Н-458 до заморозки, а не оставлены скрытым исключением. Это находка предмета, не новая нумерованная процессная запись. Нового подтверждённого дефекта регламента/инструмента для А-журнала не заявлено; общая нумерация А-записей в wip не меняется.
