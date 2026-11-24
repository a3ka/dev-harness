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
