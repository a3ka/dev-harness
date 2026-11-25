# СДАЧА 218 — собственное окно PR

База reference: source.json/baseline, main a32c577f292a2e925417d78a85cdb00abf25fae3.
База исправительного круга: dcc6f2a9c5c5aac1af358b19a53846645ca2ec3f.
Production, workflow, реестры и соседние frozen-семьи не изменяются.
--repo до реализации красен; SourceCanon не объявлен.

## Двери

- честная-модель · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- синтаксис · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --sintaksis · 0 · 0
- каталог · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/218-okno-frozen-v-pr.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- проводка-форма · bash scripts/check_provodka.sh --grammar . contracts/218-okno-frozen-v-pr.md · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа и незаполненные требования нет, полный check_sdacha/pre_critic до вызова critic · - · -
- К-02 · чисто · вход: затравка 218, дословная воля 23.11 и §Существующее; sourceCanon отсутствует; исправительный дельта-пакет task-architect218b.md · - · -
- К-03 · чисто · вход: высшие frozen 200/207/195/083/210/217/992/071 прочитаны context.py; non-PR legacy сверяется с pinned-базой; внешние регрессы обязательны реализации · - · -
- К-04 · чисто · вход: только contracts/218 и новая семья; CI, production и реестры отданы именованным исполнителям · - · -
- К-05 · чисто · вход: раздел Приёмочный критерий, каждая дверь имеет команду и rc · - · -
- К-06 · чисто · вход: настоящий Git/Python/Bash; отказ среды, якоря, синтаксиса и timeout дают NOT_IMPLEMENTED rc 2; старый CLI без --pr отдельно назван красным интерфейсом · - · -
- К-07 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- К-09 · чисто · вход: event/explicit, owner update, поздний тег, own commit/revert/side/evil merge, неполная/чужая/множественная основа, парная единственная база, push full/oracle/incr и PR cache=HEAD · - · -
- К-10 · чисто · вход: CLI rc и предметная причина, реальные HEAD/status/cache и Trace2; legacy полный stdout/stderr; PR не объявляется доказанным только по маркеру · - · -
- К-11 · чисто · вход: ожидания/пин/исходный кеш и DAG снимаются до вызова, вне каталога subject/scripts; Git-пути/объекты задаются конструктором, не выводом субъекта · - · -
- К-12 · чисто · вход: Git plumbing для DAG/блобов, stdlib JSON для Trace2, bash -n и validate_std для Bash; TSV-каталог сверяется побайтно с каноном из единственного реестра stabs/*.json · - · -
- К-13 · н/п · секретов и реальных авторских данных нет; synthetic разрешения только внутри временных Git-миров · - · -
- К-14 · чисто · вход: frozen-revert/разрешённый v+1/новая v2/code-revert, criss-cross/unique-base, late-tag/own-frozen, owner-update/own-charter/allowed, empty cache non-PR/PR cache own-violation · - · -
- К-15 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- К-16 · чисто · вход: рисковый класс, раздел Модель угроз с доверенной средой и отдельными ловцами неизвестного вычисления/внешних дверей · - · -
- К-17 · н/п · станционный guard, проектной архитектурной модели 188 нет · - · -

## Дельта

- К-07 · клетка · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model --cell frozen-frozen-revert · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model --cell charter-ambiguous-base · 0 · 0

Источник блоков: закоммиченный вердикт Crit218 вызов 1,
51c34b2ff3e6cdcd73e8492197058fd2927d4085:verdicts/critic/contracts-218-v1.md
(archive/218/critic-v1-fail-51c34b2ff3). Самого пути в HEAD переданной базы нет;
зеркало вердикта в чужую зону автор не добавляет.

Б-1 / К-07 — клетка: существующий суд v+1 обязан выполняться также при
конечных равных блобах, если pr_changes содержит собственных носителей.
Изменён только reference model_sources, production не исправлялся.
От снятия/границы отказано: это ослабило бы И3/И4; канонического guard с
этим исправлением на переданной базе нет. Новый проверяющий алгоритм не
добавлен: используются прежние rc/диагноз, Git-миры и прежний observe.
Мутация s14 возвращает прежнюю развилку; s15 вводит такую же амнистию
в charter. Каждая красна на frozen-revert и соседнем carrier-main-first-revert.
Честные эквивалентные по допустимости записи: разрешённые носители v+1
с accept v2, опубликованная v2 и revert только кода остаются зелёными
для ОБОИХ CLI. Никакого общего запрета revert нет.

Б-2 / К-08, К-09 — клетка: criss-cross main=(A,B), PR=(B,A) и его
собственный потомок. До субъекта настоящий git merge-base --all обязан
дать ровно множество {A,B}; парный unique-base — ровно {B}.
Существующий предикат И2 не менялся; s13 удаляет только --all и красен
на обеих формах для каждого CLI. Снятие/граница ослабили бы И2; Git
служит каноном DAG, но без поведенческого мира не доказывает отказ CLI.
Дополнительного разбора Git-форматов или новых дверей нет.

Совет критика: carrier-main-first и carrier-main-first-revert проверяют
первого родителя main/вершину стека и второго — цепочку носителя через
настоящий rev-list --parents. Импорт main зелён, собственная правка
frozen с revert во втором родителе красна для обоих CLI.

stabs/*.json остаётся единственным исполняемым реестром Н-39.
Запрошенный stabs.tsv — побайтовый производный каталог этих привязок,
проверяемый существующей --catalog, не второй писатель ожиданий.
Новый предикат каталога использует каноническое сравнение без разбора TSV;
допустимость представления задаёт генерация из JSON, а не ручной парсер.
Прежние 12 стабов / 24 связи и все прежние клетки сохранены.

## Наблюдавшиеся измерения

ДО исправления, из вердикта Crit218 (не повторный прогон):
--repo rc 1: KLETKI=53 ZELENYE=8 KRASNYE=45.
--model rc 0: KLETKI=53 ZELENYE=53 KRASNYE=0.
--stabs rc 0: STABY=12 SVJAZI=24 POIMANY=24 ZHIVYH=0.

ПОСЛЕ исправления, живые последовательные прогоны Architect218b:
--repo rc 1: KLETKI=71 ZELENYE=8 KRASNYE=63 (27.83 с).
--model rc 0: KLETKI=71 ZELENYE=71 KRASNYE=0 (24.56 с).
--stabs rc 0: STABY=15 SVJAZI=32 POIMANY=32 ZHIVYH=0 (22.16 с).
--sintaksis rc 0: SYNTAX rc=0, пинованный shellcheck 0.11.0.

Каталог: rc 0, CELLS=71 MUTATIONS=15 BINDINGS=32.
Независимый census: cells=71 stabs=15 bindings=32 nonPR=8 TSV_rows=32.
Просмотренный diff probe.py от dcc6f2a9c: прежние ожидания и observe не
удалены и не ослаблены; TMPDIR явно закреплён внутри копии.

Последовательно после ремонта:
pre_critic rc 0, «КРИТИК: дверь зелёная» (222.10 с).
check_sdacha --run rc 0,
«СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=3)» (228.10 с).
Прогоны листа повторно исполнили модель, стабы, синтаксис и каталог
после добавления TSV-каталога и закрепления TMPDIR.
check_zones отдельно не запускался: суд зон остаётся оркестратору.

Production ДО реализации: красны все PR-клетки ниже; прежние восемь
non-PR клеток остаются зелёными. Отказные subject-rc 1 без режима PR или
с неограниченным обходом не выдаются за выполненный контракт.

```
frozen-clean
frozen-late-tag
frozen-neighbor-before
frozen-neighbor-after
frozen-owner-update
frozen-owner-update-allowed
frozen-draft
frozen-long-main
frozen-frozen-revert-allowed
frozen-frozen-revert-refrozen
frozen-code-revert
frozen-unique-base
frozen-carrier-main-first
frozen-missing-base
frozen-shallow
frozen-forged-base
frozen-no-origin
frozen-unrelated
frozen-ambiguous-base
frozen-ambiguous-base-descendant
frozen-own-frozen
frozen-retroactive-frozen
frozen-delete-frozen
frozen-verdict-fail
frozen-frozen-revert
frozen-carrier-main-first-revert
charter-clean
charter-late-tag
charter-neighbor-before
charter-neighbor-after
charter-owner-update
charter-owner-update-allowed
charter-draft
charter-long-main
charter-frozen-revert-allowed
charter-frozen-revert-refrozen
charter-code-revert
charter-unique-base
charter-carrier-main-first
charter-missing-base
charter-shallow
charter-forged-base
charter-no-origin
charter-unrelated
charter-ambiguous-base
charter-ambiguous-base-descendant
charter-own-frozen
charter-retroactive-frozen
charter-delete-frozen
charter-frozen-revert
charter-carrier-main-first-revert
charter-own-charter
charter-reverted-charter
charter-evil-merge
charter-side-charter
frozen-main-merges-1284
charter-explicit-owner
frozen-explicit-late-tag
charter-pr-oracle
charter-pr-cache-head
charter-pr-cache-green
frozen-renamed-values
charter-renamed-values
```

На новых frozen-revert/carrier-main-first-revert старый frozen-guard
даёт rc 0; на неоднозначной базе оба старых CLI дают rc 0.
На собственных отказах charter уже может отказать, но нет PR-окна;
на чистом carrier-main-first он отказывает за импортированный AGENTS.md.
Явный --pr старым CLI не поддержан: известный «cd: --: invalid option»
именуется PR_INTERFACE_ABSENT; прочие ошибки среды по-прежнему rc 2.

## Граница и рефлексия

Вне PR поведение не заменяется reference. После реализации выполняются
старые семьи 200/207/217/210/083/992 и check_charter; контракт не объявляет
закрытыми Д4 и локальное pre-push копирование frozen-текста.
Все миры и TMPDIR дочерних процессов закреплены внутри собственной копии,
вне subject-клона; TemporaryDirectory удаляет миры. Журнал А-NN пишется
только в main, wip его не меняет. Процессное наблюдение для оркестратора:
вердикт передан доступным архивным коммитом, но отсутствует по своему пути
в базе ремонта; механическую ссылку листа на HEAD нельзя честно заявить.
