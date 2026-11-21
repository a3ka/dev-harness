# СДАЧА 187 — Б-5: stderr и его время жизни

Исправительный fixture-пакет: `/tmp/dev-harness-verify/task-b5c-architect.md`.
Субъект ДО ремонта: `d23d301ddd5a023caa7eb3a2a7afcf65da7320e0`.
Двери и frozen-контракты не менялись. Живой repo сейчас обязан быть
красным ровно на TERM/INT группе; строка repo ниже явно заявляет rc 1.
После интеграции реализации её меняют на rc 0 с новым живым замером.
Зелёный исполняемый контроль не выдаётся за замер будущей реализации.

## Существующее

`probe.py:world` создаёт независимые Git-миры; `workflow_probe.py:architecture`
публикует toy CLI в коммите A, закрепляет его lock и двигает HEAD на B.
Новые случаи используют тот же CLI и конфигурацию `brief-response.json`
В ЗАКРЕПЛЁННОМ дереве, а не подмену node или самой двери.
Публичные швы: `make_task` для именованного отказа и импортируемый
`arch187_brief` для побайтового stdout и cleanup. При роли implementer
toy-контракт получает собственный frozen-тег, как существующая no-rules-клетка.
`brief_stderr.py` хранит входы, ожидаемые байты и привязки стабов.
Оракул снят до субъекта; после вызова читается только наблюдаемый TMPDIR.
Исходные клетки 187 не утверждали проглатывание stderr: удалять нечего.

## Двери

- battery-model · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-model model · 0 · 0
- battery-stabs · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-stabs stabs · 0 · 0
- battery-repo-before-signal-repair · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-repo repo · 1 · 1
- wiring · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-wiring wiring · 0 · 0
- signal-base-and-honest-control · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-controls signals-base signals-control · 0 · 0

`census_b5.py` исполняет тот же bash-runner, сохраняет сырой stdout/stderr
в TMPDIR (по умолчанию системный tmp), печатает фактический rc каждого режима
и возвращает ненулевой код при любом ненулевом режиме, не маскируя красное.
Рабочий TMPDIR этой сдачи — `$PWD/.scratch-b5c`, в коммит не включается.
`pre_critic` по заданию не требуется.

## Карта классов

- К-01 · чисто · вход: пять дверей листа и карта К-01…К-17; исправительный маршрут Rev187B5 без нового critic · - · -
- К-02 · чисто · вход: один блок Б-1 — время жизни stderr при сигнале группе; прежние rc и диагностика сохранены · - · -
- К-03 · чисто · вход: существующий library-шов brief_stderr и command substitution вызывающего; настоящий bash/node · - · -
- К-04 · чисто · вход: изменяется только семья architecture_process_187; контракт и дверь не меняются · - · -
- К-05 · чисто · вход: живой OBJECT красен ровно на двух новых клетках; база a4f87d04a1 и честный контроль зелены · - · -
- К-06 · чисто · вход: модель пишет stderr и ready-маркер до сигнала; ожидание ограничено, отсутствие ready красное · - · -
- К-07 · чисто · вход: ожидания NEIGHBOR и пустого scratch в памяти до субъекта; после выхода судится эффект в двух каталогах · - · -
- К-08 · чисто · вход: исполняемые S1/S2/S4 привязаны в brief_signals.STABS; S3 — brief_stderr.STABS к plain-отказу · - · -
- К-09 · чисто · вход: TERM/INT группе, TERM только родителю, нормальные rc 0/1, чужой сосед; с управляемой моделью и без · - · -
- К-10 · чисто · вход: прежнее точное равенство stderr оставлено; прежние brief-stderr клетки зелены на OBJECT · - · -
- К-11 · чисто · вход: cleanup не требует имени/способа аллокации; сосед сравнивается с независимой константой · - · -
- К-12 · чисто · вход: сигналы доставляет os.killpg реальной группе новой сессии; без разбора bash своими предикатами · - · -
- К-13 · н/п · секретов, сети и внешнего API в новых клетках нет · - · -
- К-14 · чисто · вход: та же клетка зелена на настоящей базе без capture и на честном контроле с capture; сосед остаётся · - · -
- К-15 · чисто · вход: model rc 0 CELLS=82, stabs rc 0 STABS=110 ZHIV=0; repo rc 1 FAILURES=2, прежние 78 зелены · - · -
- К-16 · чисто · вход: stderr не переживает группу; более узкий сигнал родителю остаётся зелёной охраной · - · -
- К-17 · н/п · sourceCanon, модель продукта и его pin не меняются · - · -

## Дельта

Блок Rev187B5 закрывается клетками, а не изменением обязательства.
Привязки стабов находятся в коде, не frozen-прозе; реализацию делает implementer.

## Census и клетки

### После реализации

На базе `8cc43759830eb16c82b729e4156dd15965673fc3` живой
`fixtures/workshop_project/architecture_process_187/census_b5.py sdacha-repo repo`
→ rc 0, `CELLS=78 STABS=0 FAILURES=0`,
`CENSUS sdacha-repo --repo rc=0`.
Сырые stdout/stderr — `$TMPDIR/sdacha-repo-repo.stdout` и `.stderr`.

Отдельный прямой `red_architecture_process_187.sh --repo .` → rc 0,
`CELLS=78 STABS=0 FAILURES=0`. Повторные режимы через
`census_b5.py post-implementation model stabs wiring`:
`CENSUS post-implementation --model rc=0`,
`CELLS=78 STABS=0 FAILURES=0`;
`CENSUS post-implementation --stabs rc=0`,
`CELLS=78 STABS=105 FAILURES=0`;
`CENSUS post-implementation --wiring rc=0`, вывод самой двери пустой.
Сырые логи — `$TMPDIR/post-implementation-{model,stabs,wiring}.{stdout,stderr}`.

Проверка обновлённого листа:
`bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`.
Независимая мера `wc -l` сырых stdout: sdacha-repo-repo=80,
post-implementation-model=80, post-implementation-stabs=185.
За вычетом selfcheck и summary — 78 клеток; разность 185−80 — 105 стабов.

Рефлексия обновления: красный rc ДО нельзя оставлять текущей дверью
после совместной поставки; история отделена от действующей строки repo.
Общий журнал не менялся: эта пачка ограничена листом, журнал пишется в main.

### Исторический замер ДО реализации

Исходное задание: `/tmp/dev-harness-verify/task-b5-architect.md`;
база ДО: `94b2edff9072abaca3a5c2a848e08fa90de9869e`.
Все замеры до таблицы ниже относятся к этому красному предъявлению;
текущая строка двери repo выше требует rc 0 после ремонта.

Неизменённая семья на базе: `--repo` rc 0, CELLS=67 STABS=0 FAILURES=0;
`--model` rc 0, CELLS=67 STABS=0 FAILURES=0; `--stabs` rc 0,
CELLS=67 STABS=93 FAILURES=0; `--wiring` rc 0, вывод пуст.
Исходный `--repo` — сырой tool-вывод; прочие исходные логи — `before-*`.

После добавления клеток на ТОЙ ЖЕ двери: `--model` rc 0,
CELLS=78 STABS=0 FAILURES=0; `--stabs` rc 0,
CELLS=78 STABS=105 FAILURES=0; LIVE/ZHIV=0; `--wiring` rc 0.
Живой `--repo` до реализации: rc 1, CELLS=78 STABS=0 FAILURES=7,
красны ровно семь диагностических/static-клеток из таблицы; все прежние зелёные.
Итоговые сырые логи — `sdacha-model-model.stdout`,
`sdacha-stabs-stabs.stdout`, `sdacha-repo-repo.stdout`,
`sdacha-wiring-wiring.stdout` и одноимённые `.stderr` в TMPDIR.
`bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`.
Независимая мера `wc -l` логов: before-model=69, before-stabs=162,
sdacha-model=80, sdacha-stabs=185, sdacha-repo=80.
За вычетом selfcheck и summary это 67/78 клеток;
разности stab/model дают 93 и 105 предъявлений соответственно.

| Клетка | rc субъекта ДО | До реализации | После реализации (живой замер на базе выше) |
| --- | --- | --- | --- |
| brief-stderr-plain | 1 | красная: нет ARCH_BRIEF_STDERR | зелёная, rc 1 |
| brief-stderr-rules | 1 | красная: нет ARCH_BRIEF_STDERR | зелёная, rc 1 |
| brief-stderr-empty | 1 | красная: нет пояснения пустого stderr | зелёная, rc 1 |
| brief-stderr-leading-blank | 1 | красная: нет первой непустой строки | зелёная, rc 1 |
| brief-empty-output-noisy | 1 | красная: rc модели 0, но stdout пуст | зелёная, rc 1 |
| brief-empty-output-quiet | 1 | красная: rc модели 0, оба канала пусты | зелёная, rc 1 |
| brief-success-noisy | 0 | зелёная: stdout=BODY, stderr пуст | зелёная, rc 0 |
| brief-success-quiet | 0 | зелёная: stdout=BODY, stderr пуст | зелёная, rc 0 |
| brief-cleanup-failure | 1 | зелёная: TMPDIR пуст | зелёная, rc 1 |
| brief-cleanup-success | 0 | зелёная: TMPDIR пуст | зелёная, rc 0 |
| brief-stderr-fable-static | 1 | красная: brief в /dev/null | зелёная, rc 0 |

## Развилки и заменяемые обязательства

Задание требует красноты cleanup на базе, но база вообще не создаёт
stderr-scratch: TMPDIR пуст и после отказа, и после успеха. Краснить такую
реализацию за отсутствие утечки было бы ложью. Эти клетки оставлены
зелёными регресс-стражами; S6 отдельно создаёт утечку и ловится.
Для полноты условия «rc≠0 ИЛИ пустой stdout» добавлены две адресные клетки.

Поиск `2>/dev/null|stderr` в contracts/187-arhitektura-v-processe.md
не даёт строк. Явного frozen-обещания глотать stderr в 187 нет.
В contracts/170-arch-component-brief-vhod-zadanija.md:28 объявлена первая
строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events`; при переносе этой формы
на pinned-ветвь она заменяется предшествующей строкой ARCH_BRIEF_STDERR
по ADR. Локальный npm-путь 170 остаётся прежним. Строки 170:15,27
(ARCH_COMPONENT_NET/ARCHITECTURE_NET) не относятся к изменению и сохранены.

В fixtures/workshop_project/arch_component_170/probe.py:174–186 первая
строка stderr сравнивается для brief_failure, implementer_brief_failure,
adversary_brief_failure, reviewer_brief_failure; эта семья не правилась.
Её npm_stub.py:25–27 выдаёт отказ npm, не pinned node CLI.
Контракты и версию 170 эта поставка не замораживает.

## Рефлексия процесса

Новый риск конструкции: требование красноты cleanup против базы без
аллокации ведёт к ложному красному. Закрыто независимой cleanup-клеткой
и утечкой S6, а не добавлением искусственного дефекта в базу.
Общий журнал в wip не менялся: его разрешено пополнять только в main.

## Исторический ремонт предпосылки 154 Б-1

Предыдущая версия миров freeze подставляла собственный toy/boundary154
в приватные копии CLI и передавала пустой журнал. Это не доказательство
прохождения новых предметов через публичный счёт 154; нижеследующие
замеры относятся только к исторической конструкции.

Исходный замер автора 0f972e149b9eff8f8da63ebed340fcc20e477e4e
на BASE 154 после ремонта: `red_architecture_process_187.sh --repo .` →
rc 0, `CELLS=61 STABS=0 FAILURES=0`; `--model` → rc 0 с тем же итогом;
`--stabs` → rc 0, `CELLS=61 STABS=75 FAILURES=0`; `--wiring .` → rc 0,
вывод пустой. Это историческое свидетельство исходной сдачи, не новый
интеграционный прогон на строгой реализации 154 Б-1.

Подлинная пересдача Arch187Fixture: код workflow_probe.py побайтово
совпадает с исходной дельтой (blob e125189047681bd53033f8718b28e0a7368f4881).
На одноразовом дереве сдачи 57b9bb19f4: `--model` → rc 0,
`CELLS=61 STABS=0 FAILURES=0`; `--stabs` → rc 0,
`CELLS=61 STABS=75 FAILURES=0`; `--wiring .` → rc 0, вывод пустой.
Интеграционная предпосылка: в базе a9a602bc389edd03156cc4f937849b86562b5621
нет реализации 154 и canonical boundary SHA в обоих CLI. Живой `--repo`
на строгой реализации 154 Б-1 здесь не предъявлен; нужен её точный носитель.

## Узкая интеграционная проба с опубликованным seed 154

Это дополнительный замер Arch187Seed, не пересмотр frozen-контракта,
не свидетельство авторства 154 и не done 187.

Субъект: точный опубликованный seed реализации 154
`042c48cd2dab054654596dcf93f19f0907edcc6f`, а не последующая голова
ветки. В отдельный `.git` внутри собственной изолированной копии получен
командой `bash "$OWN/scripts/gitw" -C "$TEST" fetch --no-tags origin
042c48cd2dab054654596dcf93f19f0907edcc6f`, rc 0;
origin = `ssh://git@github.com/a3ka/dev-harness.git`.
Снимок всего seed извлечён через `git archive`; поверх положена только
семья `fixtures/workshop_project/architecture_process_187/` из принятого
локального `434ec5549a1177475c9e73153eb863282f4383a3`.
Попытка получить также этот fixture-коммит с origin дала `not our ref`;
поэтому источник fixture — предоставленный локальный объект, не
несуществующая публикация. Повторная загрузка одного seed 154 успешна.

`OWN=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t938eed683/m`;
`TEST=$OWN/.scratch-187-seed-shw9nLaC`.
Тестовый снимок записан отдельным корневым коммитом architect
`8db61ed3dd743a5892d82acc0ea4dc211beff38d` (tree
`f41f123c471ab957d5df8324db7bdd391f244a46`), без родителей:
`git rev-list --count HEAD` в TEST → `1`. Чужая история не включена в
сдаваемую ветку.

Доказательство байтов субъекта ДО единственного запуска:

• `HEAD:scripts` и `042c48cd2dab054654596dcf93f19f0907edcc6f:scripts`
  в TEST → один tree `ff08f98b97a7069fac4c7d8ac7de39c24d7d2914`;
  `git diff --exit-code 042c48cd2dab054654596dcf93f19f0907edcc6f -- scripts`
  → rc 0, вывод пустой. Совпадает вся директория scripts, не только
  два файла предполагаемого шва.
• `scripts/zamok_predmeta.sh` → blob
  `cc88f40037f3f7e907e1a28e7a289ab0014b0e48`;
  `scripts/freeze_contract.sh` → blob
  `8d79c4cbf7008178da058ec267c7c0485ee16cc3`.
• `HEAD:fixtures/workshop_project/architecture_process_187` в TEST и
  тот же путь принятого 434ec554 → tree
  `cdd855f6e9ceb0eb708025e48fc3b99bfd5b53de`;
  `workflow_probe.py` → принятый blob
  `e125189047681bd53033f8718b28e0a7368f4881`.
• Разница собранного snapshot с seed — только лист sdacha_187.md
  (17 строк diff, 13 добавленных и 4 удалённых); код дверей и батареи
  не исправлялся. Перед и после прогона
  `git diff --exit-code HEAD -- scripts fixtures/workshop_project/architecture_process_187`
  → rc 0.

Единственный живой запуск:
`TMPDIR="$TEST" bash "$TEST/fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh" --repo "$TEST"`
→ rc 0, 64.85 s, `CELLS=61 STABS=0 FAILURES=0`.
Самоконтроль диагностики отдельно: `GREEN pin-diagnostic-boundary-selfcheck 9/9`.
Ниже отдельные результаты наблюдавшихся ветвей; все перечисленные
клетки GREEN, фактический rc совпал с ожидаемым:

| Клетки | Фактический rc / причина |
|---|---|
| task-valid | 0 |
| task-line-missing, task-line-blank, brief-inline-line-missing | 1 / ARCH_LINE_MISSING |
| task-l3 | 1 / ARCH_OWNER |
| task-unmapped | 1 / PATH_WITHOUT_COMPONENT |
| task-foreign | 1 / ARCH_ZONE |
| task-locate-json-malformed, task-locate-status-missing, task-locate-status-unknown | 1 / ARCH_LOCATE_GRAMMAR |
| brief-lock, brief-no-local-copy, brief-document-no-local, brief-no-rules | 0 / PINNED_BRIEF_187 |
| brief-with-rules | 0 / RULES_FROM_PIN_187 |
| freeze-valid | 0 |
| freeze-no-line | 1 / ARCH_LINE_MISSING |
| freeze-foreign | 1 / ARCH_ZONE |
| freeze-unmapped | 1 / PATH_WITHOUT_COMPONENT |
| freeze-draft, freeze-draft-marker, freeze-draft-schema | 1 / ARCH_DRAFT |
| check-valid, check-green-latency-unresolved | 0 |
| check-failure, check-digest-mismatch, check-rc1-real-gate | 1 / ARCH_CHECK |
| check-not-evaluated | 1 / ARCH_NOT_EVALUATED |
| check-rc2-real-gate, check-rc0-gate-lie | 2 / ARCH_NOT_EVALUATED |
| done-valid | 0 |
| done-ci-missing, done-ci-other-sha, done-ci-red, done-ci-skipped, done-ci-head-ahead | 1 / ARCH_CI |
| legacy-mob, legacy-harness, wiring-valid | 0 |
| wiring-omitted, wiring-no-repo, wiring-python | 1 / CI_BATTERY_187_MISSING_OR_NOT_EXACT |
| wiring-direct-missing | 1 / CI_DIRECT_ARCH_187_MISSING |
| zone-container-file, zone-outside-runtime | 0 |
| zone-container-escape | 1 / ARCH_ZONE |
| path-unplaced-absent, zone-outside-false-refused, path-area-without-component | 1 / PATH_WITHOUT_COMPONENT |
| path-unresolved-zero-absent | 0 / вне модели: scripts/ci-helper.sh |
| path-unresolved-zero-present | 0 / вне модели: provenance.json |
| zone-outside-snapshot-failed, zone-outside-snapshot-missing | 2 / ARCH_NOT_EVALUATED |
| pin-symbolic-head, pin-symbolic-branch, pin-short-sha, pin-unresolvable-sha, pin-head-noflag | 1 / ARCH_PIN |
| applicability-lock-no-dir, applicability-dir-no-lock | 1 / ARCH_COMPONENT_NET |

Поведенческих расхождений с ожиданиями принятой батареи не обнаружено.
По отношению к историческому голому прогону выше пять прежних красных
pin/applicability-клеток зелёные на данном seed; повторного прогона старого
дерева здесь не было. `--model`, `--stabs` и отдельный `--wiring` этой
пачкой не повторялись: результаты 61/61, 75/75 и rc 0 выше принадлежат
Arch187Fixture; wiring-клетки внутри единственного `--repo` исполнены.

После прогона refs TEST: только
`refs/heads/seed-snapshot 8db61ed3dd743a5892d82acc0ea4dc211beff38d`,
тегов нет. Frozen/done-теги 187 не создавались, публикации/push не было,
доставочный WORKTREE не использовался. История seed 154 остаётся только
в экспериментальном `.git` как источник байтов, не как авторская поставка.
Санкционированный v+1 170 и законное место реализации по-прежнему
блокируют done 187; этот зелёный замер их не заменяет.

## Ремонт state нового toy-предмета 777 (Arch187ToyState)

Основание: CI #1152, job 135986462228 — честные freeze-клетки получают
SCHET_NEIZVESTEN без состояния. Исключение проектов из счёта не применяется.
Мир теперь записывает независимый `*-state154/uchet.jsonl` вне продуктового
репозитория: один START critic для subjectId=777, repoId из basename origin
без `.git` (не из профильного repoId), OBJECT существующего baseline.
START записывается до accept; author-date коммита accept равна времени START
с секундной точностью Git, поэтому это не до-журнальная история и не засев.
Публичный freeze получает этот state четвёртым аргументом. Подмена canonical
boundary, приватные копии CLI, искусственный старый тег и пустой ledger удалены.
ARCH_* ожидания, отрицательные клетки и привязки стабов не меняются.

Пачка подготовлена без прогонов по заданию; новые rc не предъявляются.
Исторический зелёный seed выше не является проверкой этой дельты.
Приёмка ведущей сессией на собранном кандидате с реализацией 154:

• `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`
• `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`
• `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs`
• `bash scripts/check_sdacha.sh . contracts/187-arhitektura-v-processe.md --run`


## Исправление FAIL Rev187B5

Б-1: «файл захвата stderr брифа остаётся, когда сигнал доходит до всей группы процессов. Место: scripts/check_architecture_contract.sh:504 (mktemp внутри функции) и :512-515 (rm только при нормальном возврате). Вызов идёт в $(...) из scripts/make_task.sh:1070, а EXIT-ловушка make_task.sh:565 этого файла не знает. Обязательство из тела PR: «удаляется ВСЕГДА»; в задании: «в т. ч. при сигнале». Проба: `GROUPKILL=1 bash .scratch-rev187b5/signal_probe.sh scripts/check_architecture_contract.sh object-timeout-group TERM` → caller_rc=124, leftover=[tmp.OHk5oKEG1g] с текстом 'slow-model-first'; файл на месте и через 22 с после конца модели. С INT то же. База a4f87d04a1 → leftover=[]. Если TERM получает только родитель, утечки нет: подоболочка доживает до конца модели и убирает файл. Закрывающее свойство: файл не переживает TERM/INT, доставленный группе, пока работает CLI модели; клетка красная на OBJECT. Более простые формы уже есть в дереве: файл выделяет вызывающий и убирает своя EXIT-ловушка, как _NPM_ERR_FILE (make_task.sh:1051, :565), либо файл лежит под ARCH187_MODEL_TMP.»

Обещание: файл захвата stderr не переживает TERM/INT группе во время CLI.
Наблюдение: после естественного выхода вызывающего TMPDIR не содержит
ничего, кроме побайтно неизменного чужого `tmp.neighbor-187`; управляемое
ARCH187_MODEL_TMP тоже убрано. Ожидание не берётся из дерева субъекта.
Borrowed-модель лежит вне TMPDIR и не принадлежит cleanup двери.
Сигнал отправляется после маркера CLI, который следует за записью stderr.
Клетка воспроизводит вложенный `$(arch187_brief ...)` публичного вызывающего.
Проверяются оба режима владения моделью; имя capture не предписывается.
Frozen-обязательства и перечень заменяемых обязательств выше не менялись.

| Клетка | OBJECT: rc вызывающего / оценка | Честный исполняемый контроль: rc / оценка |
| --- | --- | --- |
| brief-signal-group-term | -15 / RED, файл остался в обоих режимах | -15 / GREEN, leftover=[] |
| brief-signal-group-int | -2 / RED, файл остался в обоих режимах | -2 / GREEN, leftover=[] |
| brief-signal-parent-term | -15 / GREEN, leftover=[] | -15 / GREEN, leftover=[] |
| brief-cleanup-neighbor | 0 / GREEN, neighbor=True | 0 / GREEN, neighbor=True |
| brief-cleanup-failure | 1 / GREEN, прежняя охрана | прежняя model-клетка: 1 / GREEN |
| brief-cleanup-success | 0 / GREEN, прежняя охрана | прежняя model-клетка: 0 / GREEN |
| brief-stderr-* | 1 / GREEN, ровно одна строка ARCH_BRIEF_STDERR | прежние model-клетки: 1 / GREEN |

Последняя колонка — контроль `signals-control`/`--model`, НЕ live-прогон
после реализации. После интеграции закрывающее требование: `--repo .` rc 0,
`CELLS=82 STABS=0 FAILURES=0`; здесь будущий результат не заявлен измеренным.

Команда воспроизведения и дифференциального контроля:
`fixtures/workshop_project/architecture_process_187/census_b5.py b5c signals signals-base signals-control`.
Её сырой итог: `CENSUS b5c --signals rc=1`,
`CENSUS b5c --signals-base rc=0`, `CENSUS b5c --signals-control rc=0`.
`signals-base` извлекает только настоящий library-файл из `a4f87d04a1`;
остальной контур и входы идентичны. Сырые отдельные наблюдения:

```text
RED brief-signal-group-term: mode=borrowed ready=True caller_rc=-15 leftover=['tmp.wA2aKB1AwH'] neighbor=True stdout=b'' stderr=b'' | mode=managed ready=True caller_rc=-15 leftover=['tmp.pcGBhWMTyS'] neighbor=True stdout=b'' stderr=b''
RED brief-signal-group-int: mode=borrowed ready=True caller_rc=-2 leftover=['tmp.rZY6yGavsD'] neighbor=True stdout=b'' stderr=b'' | mode=managed ready=True caller_rc=-2 leftover=['tmp.HkeFknjE4L'] neighbor=True stdout=b'' stderr=b''
GREEN brief-signal-parent-term: mode=borrowed ready=True caller_rc=-15 leftover=[] neighbor=True stdout=b'' stderr=b'' | mode=managed ready=True caller_rc=-15 leftover=[] neighbor=True stdout=b'' stderr=b''
```

Текущая семья: 78 → 82 клетки; 105 → 110 стабов. Независимая мера
`wc -l .scratch-b5c/b5c-{model,stabs,repo}.stdout` → 84, 194, 84;
за вычетом selfcheck/summary — 82 клетки, разность 194−84 — 110 стабов.
`census_b5.py b5c model stabs repo wiring` дал соответственно rc 0, 0, 1, 0.
В repo красны ТОЛЬКО group-term и group-int, `FAILURES=2`;
в stabs все предъявления caught, ZHIV=0.
Логи: `$TMPDIR/b5c-{model,stabs,repo,wiring,signals,signals-base,signals-control}.{stdout,stderr}`.

S1 исполняет normal-only cleanup отдельно на TERM и INT; S2 снимает
EXIT-cleanup при INT, оставляя честный TERM; S3 теряет прочитанную причину
и ловится прежним точным stderr-предикатом; S4 удаляет `tmp.*` и ловится
исчезновением чужого соседа. Честный контроль с точечным cleanup зелён.

Рефлексия процесса: Node наследует тип модуля родительского package.json;
первая версия toy использовала require в ESM и не достигала ready. Исправлено
на стандартный ESM import до предъявления; отсутствие ready остаётся красным.
Общий А-журнал в wip не менялся: запись разрешена только в main.

Требуемая проверка обновлённого листа:
`TMPDIR="$PWD/.scratch-b5c" bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0, `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)`.
Она повторно исполнила все пять дверей, включая оба режима контроля;
repo здесь намеренно заявлен как красное предъявление ДО ремонта.

