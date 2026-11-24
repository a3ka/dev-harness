# СДАЧА 217 — пустое incr-окно

Первая авторская пачка; предыдущего вердикта по 217 нет. Production не менялась.
База и побайтовый исторический оракул: 4576309b967a22818cd7c2ed0738333dd014ca80.
Режим --model вставляет только model/empty_window.sh, а не переносит старую дверь
в production. Для всех прогонов TMPDIR=/tmp/dev-harness-verify/scratch-arch217,
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
- К-07 · чисто · вход: настоящие Git fast-import, clone, commit, tag и Bash CLI, по одному собственному .git на мир, абсолютный cwd мира; эталон 5000 коммитов и реальные 9034 коммита исполнились на станции · - · -
- К-08 · чисто · вход: MUTATIONS и stabs.tsv изменяют исполняемые операции модели/библиотеки; --stabs требует честный контроль и ожидаемый rc мутанта, неподходящий rc не считается поимкой · - · -
- К-09 · чисто · вход: --incr FILE и --incr=FILE, пустое и непустое окно, oracle-incr, поздняя заморозка, нарушение до кеша, отсутствующий/битый/пустой/неизвестный/сторонний кеш и обе полярности полного fast/oracle · - · -
- К-10 · чисто · вход: сравниваются отдельные полные stdout/stderr bytes, rc и байты кеша; Trace2 снимает реальные Git-операции, измеряется стена CLI без времени построения мира · - · -
- К-11 · чисто · вход: pinned source загружен из Git до субъекта, исторический результат и смысловой rc мира сняты в память до субъекта; эталон не перечитывается из контролируемых им файлов · - · -
- К-12 · чисто · вход: Trace2 JSON разбирает stdlib json, факты истории даёт Git plumbing, Bash проверяют bash -n и pinned shellcheck через validate_std; формат устава не разбирается новым парсером · - · -
- К-13 · н/п · секретов нет, миры содержат только синтетический публичный текст и известные git-объекты · - · -
- К-14 · чисто · вход: перед каждой мутацией та же клетка на честной модели зелена; неизвестному/стороннему кешу противопоставлен чистый полный прогон, запрещённой правке разрешённая, поздней frozen-правке черновая, full-режиму настоящий пустой incr · - · -
- К-15 · чисто · вход: --catalog пересчитывает клетки, словарь мутаций и TSV-привязки, seed сверяет --count истории; числа предъявлены сырым выводом, не получены из маркера субъекта · - · -
- К-16 · чисто · вход: рисковый страж, ранний выход только после успешной валидации, неизвестность не превращается в чисто; достижимый поддельный кеш и произвольные обходы Trace2 названы остаточным риском с reviewer/adversary · - · -
- К-17 · н/п · проектной архитектурной модели 188 нет, существующий станционный guard сохраняет публичный CLI · - · -

## Измерения

Сырой --repo на базе: rc 1, HISTORY commits=1 documents=3;
HISTORY commits=5000 documents=26; KLETKI=25 ZELENYE=20 KRASNYE=5.
Красные e1–e5: EMPTY_DISCOVERY и лишний полный вывод после верного маркера.
e1: 0.059 с, Git=19; e2: 0.535 с, Git=65; e3: 0.526 с, Git=65;
e4: 0.065 с, Git=20; e5: 0.060 с, Git=20. Все непустые/full-клетки зелены.
Это не утверждение таймаута синтетического мира: он красен по разведке, а не
случайной нагрузке. Измеренные владельцем 56–60 с не воспроизводились заново.

Сырой --model: rc 0, KLETKI=25 ZELENYE=25 KRASNYE=0.
e1–e5: 0.022/0.023/0.025/0.022/0.022 с, Git=3, discovery=0.
--model --live: rc 0, LIVE commits=9034 seconds=0.020 rc=0,
stdout пуст, stderr ровно маркер `(0 коммитов)` с base=head=4576309b,
кеш полный HEAD+LF. Клон живой истории удалён пробой.

Сырой --stabs: rc 0, MUTACII=14 SVJAZI=17 POIMANY=17 ZHIVYH=0.
SLOW_EMPTY: CLI rc 124 за 2.003 с, EMPTY_BUDGET_EXCEEDED;
честный контроль 0.022 с. --syntax: rc 0, SYNTAX bash=2 python=1 rc=0.
Начальный --stabs нашёл неоднозначный якорь incr_finish (rc 2); исправлена
локализация мутаций на короткий model-блок. Такой rc не был засчитан поимкой.

pre_critic: rc 0, «КРИТИК: дверь зелёная», 50.14 с.
check_sdacha --run: rc 0, «СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=0)»,
41.36 с, в пределах 900 с. Этим прогоном исполнены все двери выше, включая
полный check_provodka, источники --stage done и закреплённый shellcheck.

## Дельта

Первичный предмет, блоков прошлого критика нет. Перечень место → клетка →
адресная мутация выведен --catalog; исполняемые привязки живут только в TSV.

| Место | Клетка | Мутация |
|---|---|---|
| ранний выход | e2 | NO_SHORTCUT |
| предикат пустоты | w1, w6 | ALL_WINDOWS |
| допуск только incr | f1 | FULL_TOO |
| кеш пустого окна | e1 | CACHE_CORRUPT |
| писатель непустого окна | w2 | NO_FINISH |
| rc пустого окна | e1 | FAIL_EMPTY |
| разведка документов | e2 | DOCUMENT_WALK |
| обход истории | e2 | TAG_LOG |
| маркер | e1 | NO_MARKER |
| число коммитов | e1 | WRONG_COUNT |
| отказ разбора | c7, c8 | INVALID_CLEAN |
| полный fallback | c3, c5 | UNKNOWN_CLEAN |
| отсутствие кеша | c1 | MISSING_CLEAN |
| секундный предел | e1 | SLOW_EMPTY |

## Рефлексия для orchestrator

Полная инструкция стартапа требует читать наибольший номер контракта: в этом
репо это сторонний мобильный 999, не активный станционный 217; чтение чужого
предмета не помогает следующей пачке. Журнал А-NN — только main и вне зоны
этого задания, поэтому номер и запись здесь не создаются; это наблюдение
передано через лист, не молчаливая правка нормы.
