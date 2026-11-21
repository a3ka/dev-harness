# СДАЧА 187 — Б-3: ARCH_REVIEW предупреждает, ARCH_CI сохраняет отказ

Основание: `docs/owner/adr/2026-11-21-plan-fable.md`, решение 2–3.
Задание: `/tmp/dev-harness-verify/task-b3-architect.md`.
База: `01df50efe70fdb860e84cdb06440c6998fff3bfc`.
Это авторская поставка клеток для одного PR Б-3, не новая версия контракта
и не исправительный круг critic. Frozen-тексты и публичная дверь не менялись.
Ниже до раздела «Исторический ремонт» — актуальный лист; последующие
разделы сохраняют исторические замеры, не результаты Б-3.

## Существующее

`workflow_probe.py` уже задаёт CASES/STABS и вызывает настоящую публичную
дверь; `probe.py` создаёт независимые Git-миры с reviewer ACCEPT;
`prepare` добавляет OBJECT, frozen-тег и внешний CI-ответ на конечный SHA.
Эти механизмы переиспользованы. Наблюдение Б-3 — отдельный stderr, rc
и настоящий done-тег с проверкой его целевого SHA, не общий stdout+stderr.
Модель теперь также создаёт Git-тег в своём toy-мире; это не доказательство
реализации двери, а честный контроль пригодности клеток.

## Двери

- battery-model · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- battery-repo-before-implementation · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . · 1 · 1
- wiring · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring . · 0 · 0

Строка repo отражает намеренно КРАСНОЕ предъявление до реализации:
на неизменённой двери красны только новые warns-клетки. После реализации
Б-3 тот же режим должен дать rc 0; при сборке общего PR строка repo
обновляется на фактический зелёный результат. `pre_critic` не требуется:
контракт неизменен, маршрут ADR — один reviewer общего PR.

## Карта классов

- К-01 · чисто · вход: форма листа — четыре предметные двери, все К-01…К-17; предсудебный critic не назначается по ADR Б-3 · - · -
- К-02 · чисто · вход: ADR плана Fable, решения 2–3: ARCH_REVIEW понижен, ARCH_CI и frozen-тексты неизменны · - · -
- К-03 · чисто · вход: повторно использованы миры probe.py, prepare и live; посторонние семьи и реализация 154 не менялись · - · -
- К-04 · чисто · вход: только workflow_probe.py и sdacha_187.md внутри выданной architect-зоны · - · -
- К-05 · чисто · вход: --repo на базе зелён 61/61; после замены красны ровно новые warns-клетки, остальные 60 зелёные · - · -
- К-06 · чисто · вход: существующие Git/Python/bash и среда живой двери; ни зависимости, ни rc инфраструктуры не менялись · - · -
- К-07 · чисто · вход: done_observed общий для модели, стабов и live; ожидаемый HEAD и признак warning сняты до вызова субъекта · - · -
- К-08 · чисто · вход: --stabs rc 0, CELLS=67 STABS=93 FAILURES=0; пары стаб–клетка находятся только в STABS · - · -
- К-09 · чисто · вход: два конформных reviewer ACCEPT без самостоятельной строки — inline-упоминание и заголовок с текстом ниже; исходная самостоятельная непустая строка — парный контроль · - · -
- К-10 · чисто · вход: молчаливый rc 0 и прежний отказ пойманы отдельно на обеих review-warns-клетках; stdout вместо stderr, утрата вердикта/выхода и отсутствие тега также пойманы · - · -
- К-11 · чисто · вход: ожидаемые rc/предупреждение из CASES и входа мира, конечный HEAD сохранён до вызова; после вызова читается только наблюдаемый Git-эффект · - · -
- К-12 · чисто · вход: CI_VARIATIONS порождает warn-пары; REVIEW и DONE_TAG — единые адреса, формат документа не парсится новым гардом · - · -
- К-13 · н/п · секретов, токенов или внешнего API в новых клетках нет · - · -
- К-14 · чисто · вход: модель зелена на inline-упоминании и heading-форме с предупреждением, на самостоятельной строке без предупреждения; все исходные CI-отказы зелены · - · -
- К-15 · чисто · вход: вывод --model CELLS=67 STABS=0 FAILURES=0; --stabs CELLS=67 STABS=93 FAILURES=0; --repo CELLS=67 STABS=0 FAILURES=7 · - · -
- К-16 · чисто · вход: ARCH_CI судится и со строкой reviewer, и после ARCH_REVIEW-предупреждения; при отказе done-тег отсутствует; содержательная архитектурная оценка не расширялась · - · -
- К-17 · н/п · sourceCanon не вводится; архитектурная модель продукта и её pin не меняются · - · -

## Дельта

Новых блоков critic эта пачка не закрывает: отдельный маршрут владельца Б-3.
Клетка прежнего ARCH_REVIEW-отказа и её старый стаб удалены.
Новые review-warns-клетки не являются переименованным rc прежнего отказа:
они наблюдают rc 0, конечный done-тег и первую строку stderr с префиксом
`ПРЕДУПРЕЖДЕНИЕ: ARCH_REVIEW:`, именем вердикта и выходом
«напиши самостоятельную строку `СВЕРКА-АРХИТЕКТУРЫ: <вывод>`».
Контроль `done-valid` наблюдает тег и отсутствие предупреждения.
Каждая исходная CI-клетка сохранена; добавлена её warns-пара, где первым
идёт предупреждение, затем ARCH_CI-отказ и тег не создаётся.
Стабы привязаны по коду, не в прозе frozen-контракта (Н-39).

## Замер Б-3

Корень прогона — собственная изолированная копия
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t291b4aff6/m`.
`TMPDIR` — `$PWD/.scratch-b3a`, сырой stdout сохранён там в
`before-repo.log`, `after-model.log`, `after-stabs.log`, `after-repo.log`.
Логи scratch не входят в поставку; полный вывод также в tool-трассе вызова.
Публичная дверь на обоих живых прогонах — неизменённая с базы.

| Режим | До замены клеток | После замены клеток, до реализации двери |
| --- | --- | --- |
| --repo . | rc 0; CELLS=61 STABS=0 FAILURES=0 | rc 1; CELLS=67 STABS=0 FAILURES=7 |
| --model | этой пачкой до замены не запускался | rc 0; CELLS=67 STABS=0 FAILURES=0 |
| --stabs | этой пачкой до замены не запускался | rc 0; CELLS=67 STABS=93 FAILURES=0 |
| --wiring . | до замены не запускался | rc 0; вывод пуст |

Красные клетки живой двери (полный перечень):
`done-review-missing-warns`, `done-review-heading-warns`,
`done-ci-missing-warns`, `done-ci-other-sha-warns`, `done-ci-red-warns`,
`done-ci-skipped-warns`, `done-ci-head-ahead-warns`.
У двух review-warns фактический rc 1 вместо 0; у пяти CI-warns rc 1,
но причина — прежний ARCH_REVIEW вместо предупреждения и ARCH_CI.
Исходные пять CI-клеток дают rc 1 / ARCH_CI; `done-valid` даёт rc 0,
тег на конечном HEAD, без предупреждения. Самоконтроль pin — 9/9.
Это ожидаемое красное предъявление предмета, не отказ среды.

`bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`.
Независимый пересчёт строк логов и данных CASES/STABS → rc 0:
BEFORE_GREEN=61, AFTER_GREEN=60, AFTER_RED=7, CASES=67, STABS=93,
CAUGHT=93; красное множество в точности равно новым warns-клеткам,
все привязки STABS ссылаются на существующие CASES.

## Заменённые frozen-обязательства для описания общего PR

`contracts/187-arhitektura-v-processe.md:41,52` — ARCH_REVIEW больше
не отказ. `contracts/201-done-dver-soderzhatelnaja-sverka.md:34,331` —
неизменность ARCH_REVIEW заменена ADR. Упоминание пары свидетельств
в `contracts/201-done-dver-soderzhatelnaja-sverka.md:22` — исторический
инвентарь, не дополнительный отказ. ARCH_CI во всех этих местах сохранён.
Frozen-документы этой поставкой не редактируются.

## Рефлексия процесса

Нового дефекта процесса, мешающего следующей пачке, не обнаружено.
Журнал NABLIUDENIA_ARCHITECT.md в wip не менялся: по роли его записи
допускаются только коммитом main. Известное разделение probe.py /
workflow_probe.py учтено чтением фактического entrypoint, не номерами
строк старого задания; клетки и модель здесь живут в workflow_probe.py.

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

