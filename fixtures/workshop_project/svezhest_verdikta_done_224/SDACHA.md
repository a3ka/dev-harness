# СДАЧА 224 — свежесть по кругам

Обещание: порядок круга вместо ancestry между носителями, без снятия frozen/OBJECT. Наблюдение: реальный CLI done, отдельные stdout/stderr, Git-тег и неизменный HEAD. Предпосылки: Git/bash/python3/jq/date/stat, пин shellcheck 0.11.0; TMPDIR существует. Все авторские миры — в собственной копии, .scratch-224; в исходный репозиторий и настоящий origin мира записи нет. Батарея удаляет свои TemporaryDirectory на любом выходе.

Из вывода: KLETKI 32; NOSITELI 13; STABY 11; SVJAZI 19. --repo . rc 1, KRASNYH 14: у каждой роли parallel/late-fail/duplicate/missing/conflict/date-order/name-date-conflict. --model rc 0, KLETKI 32 KRASNYH 0; --stabs rc 0, честные 32 зелёные, STABY 11 SVJAZI 19 ZHIVYH 0. --sintaksis rc 0, SINTAKSIS 14 SHELLCHECK 2; --catalog rc 0. Старые сценарии регрессии зелёны и совпадают с baseline обеими трубами.

Baseline — коммит 5fa6b2c294c2dfd677febb200c73dc27467461e6, предок результата. Миры полностью создаются кодом. Модель содержит только общий round-selector, два вызова вместо двух старых циклов, export NEXT_ID_LIB для source и документированные suppressions уже существующих baseline-предупреждений SC2034/SC2295/SC1010. Ни один новый предикат round-selector не выключен из shellcheck. Production и реестры architect не правит.

Фактические финальные двери (с указанным пином shellcheck, TMPDIR своей копии, SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400): pre_critic rc 0, «КРИТИК: дверь зелёная» (291.44 с); отдельный check_sdacha --run rc 0, «СДАЧА: лист зелёный (двери=13 карта=17/17 дельта=0)» (275.86 с). Полная check_provodka rc 1: «проводка: guard не подключён: fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh не вызывается в .githooks/ или .github/workflows/». Это оставшаяся зона orchestrator, до paid critic/done подключить CI; grammar-проверка не выдана за полную зелёную проводку.

Наблюдение процесса (кандидат для журнала main, без самовольного А-номера в wip): адрес WORKTREE из задания не совпал с выданным runtime изолированным деревом; адрес BRANCH заканчивается architect-a, а то же задание требует именно wip/224/architect для двери 018. Работа осталась в выданной изолированной копии на требуемой дверью ветке; фактический pwd и sha передаются в докладе. Ловец следующей пачки — выдавать единую пару фактического isolated-cwd/guard-совместимой ветки. Общий NABLIUDENIA_ARCHITECT.md в wip не менялся.

## Двери

- Red-do · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo . · 1 · 1
- Model · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --catalog · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/224-svezhest-verdikta-done.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы этого листа, поле ПРОВОДКА guard-каналом и незаполненные требования; строка плана 224 реально есть в данной базе · - · -
- К-02 · чисто · вход: task-architect224 и owner-затравка #1379; Н-465 относится к state-ветке, не выдана за запись main; m2393 п.4 и обязательные три входа m2417 исполнены · - · -
- К-03 · чисто · вход: context.py читает высшие frozen-блобы через git show, в том числе 038/2 и 201/1; меняется только выбор между вердиктами, не связи F/CID/OBJECT и другие ворота · - · -
- К-04 · чисто · вход: контракт и новая семья — architect; scripts/done_contract.sh — implementer; реестры и CI — orchestrator; свои 73 ПЕРЕСЕЧЕНИЕ-строки выведены из frozen-блобов, чужих production-правок нет · - · -
- К-05 · чисто · вход: публичные W --repo/--model/--stabs/--sintaksis/--catalog, consumer, pre_critic/check_sdacha с rc; полная проводка заявлена после подключения orchestrator · - · -
- К-06 · чисто · вход: нет Git/bash/jq/date/stat, carrier hash mismatch, поломка мира или негодный синтаксис — rc 2, не поимка; каждый возврат subject rc вне 0/1 именуется отказом среды · - · -
- К-07 · чисто · вход: --model — полный настоящий done в настоящих Git-мирах с живыми check_provodka/check_consumers, переиспользуется лишь world-constructor 201, не oracle/двойник двери; честный контроль 32/0 · - · -
- К-08 · чисто · вход: MUTATIONS/build.py и source.json — 11 реальных мутантов двери, 19 отдельно исполняемых связей; при дубле оба файла accept, default номера согласован с metadata, CID/F-клетка имеет корректный OBJECT/F и изолирует удалённую связь · - · -
- К-09 · чисто · вход: две роли × параллельный/линейный круг, поздний FAIL, дубли, номер отсутствует, конфликт вызова, инверсия дат, конфликт даты имени; filename-only и нормализуемая первая строка разрешены; station/product-пути и прежние отказные сценарии · - · -
- К-10 · чисто · вход: проверяются rc, stdout, stderr, список done-тегов, peeled target и HEAD; регресс сравнивает полные байты с baseline того же мира; фактическая параллельность подтверждена merge-base в обе стороны до субъекта · - · -
- К-11 · чисто · вход: ожидания, baseline bytes и исходный HEAD сохранены в памяти до кандидата, source.json прочитан/хеши сверены до запуска; дерево субъекта после вызова не является источником ожидаемого порядка · - · -
- К-12 · чисто · вход: реальные Git plumbing, date ISO validation, bash -n, пинованный shellcheck/validate_std, JSON стандартной библиотекой; source.json сгенерирован build.py, не отдельная спецификация грамматики · - · -
- К-13 · н/п · секретов/сетевых свидетельств нет: синтетические identity и кодом созданные Git-миры с локальным bare-origin; нового токена или CI-secret нет · - · -
- К-14 · чисто · вход: параллельный и линейный accept, filename-only без СУД, одинаковое согласованное значение вызова с пояснением, CR/пробелы/case первой строки зелены; независимые legacy-отказы сохраняют байты · - · -
- К-15 · чисто · вход: --catalog печатает 32/11/19; build.py — 13/11/19; --model и --stabs подтверждают клетки/связи другой мерой; context.py печатает 73 декларации, не ручной счёт прозы · - · -
- К-16 · чисто · вход: рисковый допуск done; в НЕ ЗАЩИЩАЕТ названы согласованная ложь metadata, сговор, компрометация инструментов и независимые дефекты смежных дверей с ловцами · - · -
- К-17 · н/п · существующий станционный скрипт; продуктовой архитектурной модели 188 и новых writers/scope_id нет; второй реестр/дверь не создаётся · - · -

## Сырой red-do до реализации

Команда: `TMPDIR=<своя копия>/.scratch-224 bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo .`, rc 1. Ниже stdout без перевода repr stderr в прозу; финальный счёт из вывода.

```text
REPO review-parallel RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: \xd0\xbd\xd0\xb5\xd1\x81\xd0\xba\xd0\xbe\xd0\xbb\xd1\x8c\xd0\xba\xd0\xbe \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82\xd0\xbe\xd0\xb2, \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO review-late-fail RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO review-duplicate RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO review-missing RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO review-conflict RED DIAGNOSIS rc=1 stderr=b'done: \xd0\xbd\xd0\xb5\xd1\x81\xd0\xba\xd0\xbe\xd0\xbb\xd1\x8c\xd0\xba\xd0\xbe \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82\xd0\xbe\xd0\xb2, \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO review-date-order RED DIAGNOSIS rc=1 stderr=b'done: \xd0\xbd\xd0\xb5\xd1\x81\xd0\xba\xd0\xbe\xd0\xbb\xd1\x8c\xd0\xba\xd0\xbe \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82\xd0\xbe\xd0\xb2, \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO review-linear GREEN 
REPO review-equivalent GREEN 
REPO review-no-metadata GREEN 
REPO review-name-date-conflict RED DIAGNOSIS rc=1 stderr=b'done: \xd0\xbd\xd0\xb5\xd1\x81\xd0\xba\xd0\xbe\xd0\xbb\xd1\x8c\xd0\xba\xd0\xbe \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82\xd0\xbe\xd0\xb2, \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO adversary-parallel RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82 \xd0\xb0\xd0\xb4\xd0\xb2\xd0\xb5\xd1\x80\xd1\x81\xd0\xb0\xd1\x80\xd0\xb8\xd1\x8f verdicts/adversary/contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO adversary-late-fail RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-duplicate RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-missing RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-conflict RED DIAGNOSIS rc=1 stderr=b'done: \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82 \xd0\xb0\xd0\xb4\xd0\xb2\xd0\xb5\xd1\x80\xd1\x81\xd0\xb0\xd1\x80\xd0\xb8\xd1\x8f verdicts/adversary/contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO adversary-date-order RED DIAGNOSIS rc=1 stderr=b'done: \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82 \xd0\xb0\xd0\xb4\xd0\xb2\xd0\xb5\xd1\x80\xd1\x81\xd0\xb0\xd1\x80\xd0\xb8\xd1\x8f verdicts/adversary/contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO adversary-linear GREEN 
REPO adversary-equivalent GREEN 
REPO adversary-no-metadata GREEN 
REPO adversary-name-date-conflict RED DIAGNOSIS rc=1 stderr=b'done: \xd1\x81\xd0\xb2\xd0\xb5\xd0\xb6\xd0\xb8\xd0\xb9 \xd0\xb2\xd0\xb5\xd1\x80\xd0\xb4\xd0\xb8\xd0\xba\xd1\x82 \xd0\xb0\xd0\xb4\xd0\xb2\xd0\xb5\xd1\x80\xd1\x81\xd0\xb0\xd1\x80\xd0\xb8\xd1\x8f verdicts/adversary/contracts-777-impl-v3.md \xd0\xbd\xd0\xb5 accept\n'
REPO review-old-object GREEN 
REPO adversary-other-object GREEN 
REPO regression-new-freeze GREEN 
REPO regression-no-object GREEN 
REPO regression-single-fail GREEN 
REPO regression-escalate GREEN 
REPO regression-bad-first GREEN 
REPO regression-no-freeze GREEN 
REPO regression-empty-reason GREEN 
REPO regression-uncommitted GREEN 
REPO regression-product GREEN 
REPO regression-product-not-merged GREEN 
KLETKI 32 KRASNYH 14
```
