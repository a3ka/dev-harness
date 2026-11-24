# СДАЧА 217 — пустое incr-окно

Исправительный круг по Crit217: archive/217/critic-v1-fail-c0a10c2ca0,
verdicts/critic/contracts-217-v1.md; OBJECT=3ca9ae82d6449f193e6048bd21aa276b5c687019.
Один блок К-08/К-09/К-10: удаление incr_finish 0 пустой ветви не различалось.
Production не менялась. Исторический оракул: 4576309b967a22818cd7c2ed0738333dd014ca80.
Режим --model вставляет только model/empty_window.sh, а не переносит старую дверь
в production. Для текущих прогонов TMPDIR=/tmp/dev-harness-verify/scratch-arch217b,
VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck.
Двери ниже заявляют ожидаемые rc; check_sdacha исполняет их и сверяет оба поля.

## Двери

- честная-модель · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --stabs · 0 · 0
- реальная-история · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model --live · 0 · 0
- синтаксис · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --syntax · 0 · 0
- реестр-ветвей · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --catalog · 0 · 0
- реализация-Б1-Б2 · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . · 0 · 0
- production-мутации-Б1-Б2 · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo . --production-stabs · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/217-incr-pustoe-okno.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- идентификаторы · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- проводка · bash scripts/check_provodka.sh . contracts/217-incr-pustoe-okno.md · 0 · 0
- источники-done · bash scripts/check_project_sources.sh --repo . --contract contracts/217-incr-pustoe-okno.md --stage done · 0 · 0
- генератор-CI · bash scripts/gen_ci_steps.sh --check · 0 · 0
- совместимость-210-v2 · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo . · 0 · 0
- совместимость-113-v2 · bash fixtures/charter_fast_113/red_113.sh · 0 · 0
- совместимость-083-база · bash fixtures/_krasnye_083.sh · 1 · 1

## Карта классов

- К-01 · чисто · вход: двери формы перечислены выше, pre_critic вызывает штатный check_sdacha с разрывом рекурсии SDACHA_OKRUG, guard уже подключён · - · -
- К-02 · чисто · вход: задание task-architect217.md, полная затравка 217, слово владельца о неизменном timeout; пустой fast-path, 5000 коммитов, живая история и порядок после 210 названы · - · -
- К-03 · чисто · вход: 019 первый родитель, 022 библиотечное кольцо, 046 гигиена, 065 грамматика/пары, 083 fallback/кеш/маркер, 113 fast/oracle, 992 fail-closed и незавершённый 210 сохраняются; чужие семьи обязательны на production после реализации · - · -
- К-04 · чисто · вход: --context использует canonical zones_load и живые высшие frozen-блобы, объявлены production и широкие префиксы 054/055/993; architect пишет только 217 и свою новую семью, CI оставлен orchestrator · - · -
- К-05 · чисто · вход: каждый пункт приёмки несёт rc-команды, --repo меняет ожидаемый rc только между до/после реализации; лист не использует нестабильный red-before как дверь · - · -
- К-06 · чисто · вход: отсутствующий исходник/пин/Git/трасса/валидатор и неоднозначный якорь дают NOT_IMPLEMENTED rc 2; двухсекундный timeout пустого CLI есть сам предмет, поэтому RED rc 1, не инфраструктурная поимка · - · -
- К-07 · чисто · вход: настоящие Git fast-import, clone, commit, tag и Bash CLI, по одному собственному .git на мир, абсолютный cwd мира; эталон 5000 коммитов и реальные 9035 коммитов исполнились на станции · - · -
- К-08 · чисто · вход: NO_FINISH_EMPTY удаляет именно incr_finish 0 пустого model-блока; e6/e7 различают отсутствие LF, прежний NO_FINISH по-прежнему ловится w2; --stabs требует честный контроль и ожидаемый rc мутанта · - · -
- К-09 · чисто · вход: новые e6/e7 начинают с HEAD без LF, e1–e5 с HEAD+LF; w9 начинает со строгого предка без LF и не является пустым окном; прежние непустые/full/ошибочные входы сохранены · - · -
- К-10 · чисто · вход: сравниваются отдельные полные stdout/stderr bytes, rc и cache_bytes, не mtime/inode; e6/e7 требуют изменения HEAD без LF в HEAD+LF; ожидание задано до субъекта, существующий байтовый компаратор не менялся · - · -
- К-11 · чисто · вход: pinned source загружен из Git до субъекта, исторический результат и смысловой rc мира сняты в память до субъекта; эталон не перечитывается из контролируемых им файлов · - · -
- К-12 · чисто · вход: Trace2 JSON разбирает stdlib json, факты истории даёт Git plumbing, Bash проверяют bash -n и pinned shellcheck через validate_std; формат устава не разбирается новым парсером · - · -
- К-13 · н/п · секретов нет, миры содержат только синтетический публичный текст и известные git-объекты · - · -
- К-14 · чисто · вход: перед каждой мутацией та же клетка на честной модели зелена; неизвестному/стороннему кешу противопоставлен чистый полный прогон, запрещённой правке разрешённая, поздней frozen-правке черновая, full-режиму настоящий пустой incr · - · -
- К-15 · чисто · вход: --catalog пересчитывает клетки, словарь мутаций и TSV-привязки, seed сверяет --count истории; числа предъявлены сырым выводом, не получены из маркера субъекта · - · -
- К-16 · чисто · вход: рисковый страж, ранний выход только после успешной валидации, неизвестность не превращается в чисто; достижимый поддельный кеш и произвольные обходы Trace2 названы остаточным риском с reviewer/adversary · - · -
- К-17 · н/п · проектной архитектурной модели 188 нет, существующий станционный guard сохраняет публичный CLI · - · -

## Измерения

Сырой --repo на OBJECT до реализации: rc 1.
HISTORY commits=1 documents=3; HISTORY commits=5000 documents=26.
KLETKI=28 ZELENYE=21 KRASNYE=7; красны e1–e7 по BYTES/EMPTY_DISCOVERY.
Новые e6/e7: 0.064/0.636 с, Git=19/89; w9 зелёная.
Это не утверждение таймаута синтетического мира: он красен по разведке.
Измеренные владельцем 56–60 с не воспроизводились заново.

Сырой --model: rc 0, KLETKI=28 ZELENYE=28 KRASNYE=0.
e6/e7: 0.020/0.020 с, Git=3, discovery=0; w9 зелёная.
--model --live: rc 0, LIVE commits=9035 seconds=0.022 rc=0,
stdout пуст, stderr ровно маркер `(0 коммитов)` с base=head=3ca9ae82,
кеш полный HEAD+LF. Клон живой истории удалён пробой.

--catalog: rc 0, KLETKI=28 MUTACII=15 SVJAZI=19.
Независимый счёт TSV: прежние 17 связей + 2 связи NO_FINISH_EMPTY;
прежние 25 клеток + e6/e7/w9, прежние 14 мутаций + NO_FINISH_EMPTY.
Сырой --stabs: rc 0, MUTACII=15 SVJAZI=19 POIMANY=19 ZHIVYH=0.
NO_FINISH_EMPTY на e6: honest rc=0 GREEN, mutant rc=0 RED,
`CACHE expected=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca\n' actual=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca'`.
NO_FINISH_EMPTY на e7: honest rc=0 GREEN, mutant rc=0 RED,
`CACHE expected=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae\n' actual=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae'`.
NO_FINISH остаётся POIMAN на w2. --syntax: rc 0, SYNTAX bash=2 python=1 rc=0.

Воспроизведение блока на старом OBJECT: отдельный clone с собственным .git,
HEAD=3ca9ae82d6449f193e6048bd21aa276b5c687019; перенесены только новые probe.py/TSV,
из прежнего model/empty_window.sh удалена ровно строка `incr_finish 0`.
Команда `bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model`:
rc 1, KLETKI=28 ZELENYE=26 KRASNYE=2; только e6/e7 RED по CACHE.
e1–e5 и непустой w9 остаются GREEN: мутант локализован на пустом писателе,
а не на общем incr_finish непустой ветви.

Текущие двери: pre_critic rc 0, «КРИТИК: дверь зелёная», 89.88 с;
check_sdacha --run rc 0, «СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)»,
76.19 с, в пределах 900 с. Выполнены все двери листа, включая check_provodka,
источники --stage done и закреплённый shellcheck.

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --model --cell e6-empty-no-lf · 0 · 0

Один блок, три класса. Способ — клетка: снятие требования писателя или граница
на поддерживаемом кеше ослабили бы И1; канон/инструмент уже используется
(настоящий Git/lib_incr и существующее точное сравнение байтов), но ему недоставало
различающего входа. Новый проверяющий предикат не вводится: меняется вход мира.
Мутация критика и соседняя oracle/5000-ветвь различаются на e6/e7; честные
HEAD+LF (e1–e5), HEAD без LF (e6/e7) и строгий предок без LF (w9) зелены.

| Место | Клетка | Стаб / доказательство |
|---|---|---|
| И1, приёмка, конформные входы контракта | e6/e7 | NO_FINISH_EMPTY |
| World: кеш HEAD без LF | e6/e7 | NO_FINISH_EMPTY; точные байты до/после |
| World: строгий предок без LF | w9 | честный непустой контроль, полный pinned oracle |
| model-блок: incr_finish 0 | e6/e7 | адресное удаление, две TSV-привязки |
| общий писатель непустого окна | w2 | прежний NO_FINISH, без ослабления |
| совет о полном rev-list HEAD | НЕ ЗАЩИЩАЕТ | граница наблюдения; reviewer алгоритма/adversary |

Совет о rev-list закрыт одной строкой остаточного риска, как допускает задание:
O(1)-обязательство не снято, новым самописным анализом Trace2 батарея не расширена.
Новых дверей формы или обязательств сверх блока нет; прежние привязки сохранены.

## Рефлексия для orchestrator

Полная инструкция стартапа требует читать наибольший номер контракта: в этом
репо это сторонний мобильный 999, не активный станционный 217; чтение чужого
предмета не помогает следующей пачке. Журнал А-NN — только main и вне зоны
этого задания, поэтому номер и запись здесь не создаются; это наблюдение
передано через лист, не молчаливая правка нормы.

В исправительном круге предыдущий вердикт доступен только в archive-ref,
не в HEAD исходной базы. Поле ПРЕДЫДУЩИЙ ВЕРДИКТ механически принимает только
HEAD-путь; поэтому archive/OBJECT указан выше прозой, а все три класса блока
перечислены исполняемой дельтой. Перенос вердикта в main — вне зоны architect;
оркестратору следует материализовать его перед своим судейским маршрутом.
Новая А-NN запись в wip не создавалась.

## Усиление по Adv217: Б-1 / Б-2

Источник: archive/217/adversary-v1-fail-c8f67ded81,
verdicts/adversary/contracts-217-impl-v1.md, OBJECT
e8d73695036e153de6e8f0ec87cf42c660415783 (Impl217).
Контракт frozen/contracts/217/1 и production не меняются; прежние клетки,
ожидания, предел 2 с и привязки сохранены. TMPDIR текущей пачки:
/tmp/dev-harness-verify/scratch-arch217d; shellcheck — закреплённый путь выше.

| Блок | Способ | Клетки и адресные стабы | Честный контроль |
|---|---|---|---|
| Б-1, И2 | клетка, настоящий Trace2 | e8-empty-origin / e9-empty-origin-oracle: M10_AFTER_REGISTRY переносит тот же исполняемый блок после registry-цикла | Impl217 и модель: for-each-ref=0, ls-remote=0; мутант: 2/2, rc 0, RED по EMPTY_REGISTRY_DISCOVERY |
| Б-2, И3, равные деревья | клетка, pinned bytes | w10-edit-revert-denied: M13_TREE_EQUAL / M17_TREE_OBJECT_EQUAL | без разрешения rc 1, кеш прежний; w13-edit-revert-allowed rc 0, кеш HEAD |
| Б-2, И3, нулевой no-merges | клетка, Git plumbing | w11-merge-only-denied: M14_NO_MERGES | окно ровно один merge, no-merges=0; без разрешения rc 1, w14-merge-only-allowed rc 0 |
| Б-2, И3, короткий SHA | клетка, Git hash-object | w12-prefix4-denied: M04B_PREFIX4 | разные SHA с общими первыми 4 hex, доказанная предковость; без разрешения rc 1, w15-prefix4-allowed rc 0 |

Прежние миры удаляют origin в World.__init__ (прежние строки probe.py:164–166).
Без origin registry_state возвращает full до for-each-ref / ls-remote, поэтому
перенос после цикла был невидим. Новые e8/e9 после прежнего конструктора добавляют
origin на настоящий локальный bare-remote со всеми тегами: отсутствующий remote,
сеть и двойник Git не используются. Обе операции считаются из настоящих Trace2
start.argv; исходное EMPTY_DISCOVERY остаётся неизменным.

Коллизия строится подбором: 512 чистых коммитов-предков через fast-import,
затем кандидаты одного изменяющего AGENTS.md потомка до совпадения с одним из
предков. Предел суммарно 20 000 проб; сохраняется только выигравший объект,
его SHA независимо подтверждает Git hash-object. В измерении запрещённого мира:
548 проб, 0.926 с; base=36bc4fea1f0606c55a9b7b4f8f356f4708c5d8a8,
head=36bc786e019be76a3d4719ae28c542ff5795f1e3. Разрешённый сосед:
530 проб, 0.544 с. Мир с совпадением 8 hex не строится.

Все новые непустые миры используют прежний полный побайтовый pinned-оракул,
снятый в память до субъекта, и независимый смысловой rc. Правка + откат
сохраняет tree(base)=tree(head), но не равенство коммитов. Для merge второй
родитель уже предок базы, поэтому единственный новый коммит действительно merge.
Проверяется не общий итог батареи, а каждая TSV-привязка отдельно; каждый стаб
получает честный контроль и ожидаемый subject rc 0 перед признанием поимки.

Режим --production-stabs --repo ROOT исполняет только новые адресные мутации
реальных исходников ROOT, а не модели. Те же операции и stabs.tsv используются
обоими режимами; production-файлы ROOT не записываются, меняется частный мир.
Контракт не содержит привязок: их источник — код MUTATIONS и stabs.tsv (Н-39).

Сырые измерения текущей пачки:
--repo .: rc 0; KLETKI=36 ZELENYE=36 KRASNYE=0.
--model: rc 0; KLETKI=36 ZELENYE=36 KRASNYE=0.
--stabs: rc 0; MUTACII=20 SVJAZI=25 POIMANY=25 ZHIVYH=0.
--repo . --production-stabs: rc 0; MUTACII=5 SVJAZI=6 POIMANY=6 ZHIVYH=0.
--model --live: rc 0; LIVE commits=9075 seconds=0.069, subject rc=0.
--syntax: rc 0; SYNTAX bash=2 python=1 rc=0.
--catalog: rc 0; KLETKI=36 MUTACII=20 SVJAZI=25.

Это добавление 8 клеток, 5 мутаций, 6 привязок к прежним 28/15/19;
новые клетки: e8/e9/w10/w11/w12/w13/w14/w15.
Поимки — число привязок, не число уникальных мутаций.
Независимый пересчёт: AST списка Cell / AST словаря MUTATIONS / TSV-строки;
команда приведена в докладе, каталог вычисляется существующим --catalog.

## Остатки после усиления — НЕ ЗАЩИЩАЕТ

О-1…О-5 — см. полный вердикт Adv217 по ссылке выше. Подделка кеша и полный
rev-list в пределах секундного бюджета остаются прежней границей (О-1/О-2);
cwd != ROOT — вне этой пачки (О-4). О-3 (shallow, missing-remote, нечитаемое
дерево, заморозка вне предков) и О-5 (конфликт п.5 с 210/113/083) —
решение за v2/арбитром, не за новыми клетками. Чужие семьи не менялись.

Рефлексия: фиксированный SHA как единственная цель коллизии потребовал бы
случайного ожидания; выбор среди настоящих предков уменьшает пробы, сохраняя
тот же наблюдаемый отказ M04b. Новых дефектов процесса сверх уже записанной
выше недоступности archive-вердикта на HEAD не установлено; журнал А-NN
в чужой зоне/main из этой wip-ветки не изменялся.

Финальные двери этой пачки: check_sdacha --run rc 0,
«СДАЧА: лист зелёный (двери=17 карта=17/17 дельта=3)»;
pre_critic rc 0, «КРИТИК: дверь зелёная». Оба прогона последовательны,
суммарное время 179.72 с. Первый прогон обеих дверей имел rc 1 из-за
моих строк «- --repo …» вне машинной секции листа; исправлен только формат
новых строк измерений, критерии и production не менялись.

## 217 v2 — п.5, перепин соседних клеток

210 empty-root-incr: для production ожидание теперь rc 0, пустой stdout,
stderr — только маркер пустого окна + LF, кеш HEAD + LF. Прежний оракул
EmptyWorld.expected сохранён для --model/--stabs; их источник явно несёт
reader-model.sh. Остальные клетки и мутационные привязки 210 не меняются.

113 Д/gonka_kesha(а): после штатного сеяния кеша добавляется чистый коммит
без правок файлов. Кеш становится строгим предком HEAD начала гонки:
окно непусто, чтение истории запускает прежний gonka-bin/git. Затем прежние
проверки требуют маркер гонки, дочерний HEAD конца, кеш не новее HEAD начала
и совпадение второго incr с oracle. И3а 113 охраняется на непустом окне;
несостоявшаяся гонка по-прежнему красна, пропуска/молчаливого зелёного нет.
Ветвь (б), gonka-bin/git, s10 и все остальные клетки побайтово прежние.

083 — не rc 0: база ok=117 FAIL=3, красны только И0/check_charter,
И0/check_zones, И0б/check_zones по умыслу до частей Г и И 083.
Строки дверей выше отражают новый п.5; остальные обязательства не меняются.

Рефлексия: входная remote-ветка wip/217/architect-d уже отсутствовала
(fetch rc 128); точный заданный объект 1d3fd398714c055ae4485cf94d58160194f9e087
доступен локально и выбран без замены базы. Общий журнал А-NN из wip
не изменялся: это процессное наблюдение передаётся orchestrator этим листом.
