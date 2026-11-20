# СДАЧА 187 — лист v4b для узкого critic-вызова по повторному К-10 (форма контракта 193)

Лист судит форму и согласованность: двери и команды ниже прогнаны этой
пачкой на изолированной копии кандидата; смысл судит критик. Происхождение
пачки — задание orchestrator /tmp/dev-harness-verify/task-187-architect-fix-v3b.md
(исполнение решения арбитража Arb187V1 по повторному К-10 вердикта
Crit187V5, resolved). Обязательства контракта этой пачкой НЕ меняются и НЕ
ослабляются: правка — граница окончания значения pin в предикате батареи,
суффиксные стабы, число стабов контракта по факту живого прогона и этот
лист.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-187-v3.md

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md · 0 · 0
- battery-model · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- battery-repo-bare · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . · 1 · 1
- provodka · bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md · 0 · 0
- ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- threat-model · bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md · 0 · 0
- К-02 · чисто · вход: задание orchestrator task-187-architect-fix-v3b.md (исполнение решения Arb187V1, без нового слова владельца): дельта пачки — workflow_probe.py, этот лист и число стабов контракта (63→75 по факту живого прогона); текст обязательств не тронут · - · -
- К-03 · чисто · bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model · 0 · 0
- К-04 · чисто · вход: файлы пачки лежат в ЗОНА architect contracts/187-arhitektura-v-processe.md и fixtures/workshop_project/architecture_process_187/; зоны судит precision-gate внутри pre_critic · - · -
- К-05 · чисто · вход: приёмочное свойство различает честную диагностику и подмену окончания значения — честный контроль зелен (Замеры 1-2, 4), подмена красна при сохранённых rc и причине (Замер 3, стабы Замера 2) · - · -
- К-06 · чисто · вход: канон rc 2 прежний — NOT_IMPLEMENTED-ветви дверей пачкой не менялись; батарея требует python3 и git станции · - · -
- К-07 · чисто · вход: единый предикат pin_diagnostic_matched судит --model, --stabs и живую дверь одним кодом (main); самоконтроль pin-diagnostic-boundary-selfcheck несёт формы живой двери (префикс «ОТКАЗ: », перевод строки, путь клона) · - · -
- К-08 · чисто · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- К-09 · чисто · вход: демаркация прежняя v3/v4 (конформный pin — полный 40-hex SHA; символьный/сокращённый/неразрешимый/безфлаговый — клетка каждая); v4b добавляет различение ПОЛНОГО значения с границей окончания, грамматику pin не меняя · - · -
- К-10 · чисто · вход: мутация критика Crit187V5 (суффикс «-wrong» к диагностике) после правки красна ровно на четырёх неконформных клетках при честных rc и причине (Замер 3); прежние различители К-10 — голый ARCH_PIN, перепутанные причины, утрата pin, префиксная подмена — сохранены и пойманы (Замер 2) · - · -
- К-11 · чисто · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- К-12 · чисто · вход: граница окончания и формы диагноза выводятся из тех же констант-шаблонов (partition по «{pin}»), самописного переизобретения грамматики нет · - · -
- К-13 · н/п · секреты не предмет: батарея без секретов · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелёны — самоконтроль 9/9 принимает диагностику без перевода строки и с переводом публичной двери, с внешним префиксом «ОТКАЗ: » и путём клона после фиксированного текста неразрешимой ветви; pin-unresolvable-sha зелена на живой двери (Замер 4) · - · -
- К-15 · чисто · вход: числа листа и контракта из вывода команд Замеров — клетки 61 (без изменений), стабы 75 (71 прежний + 4 суффиксных); строка 47 контракта несёт 75 по факту живого прогона · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md · 0 · 0
- К-17 · н/п · sourceCanon не объявлен для станционного предмета; предмет — исполнение решения арбитража Arb187V1 · - · -

## Дельта

Закрытие повторного К-10 (суффиксная подмена значения, Arb187V1 — «исправить
клеткой»): критерий вхождения подстроки заменён предикатом
pin_diagnostic_matched — различается ПОЛНОЕ значение входного pin в
диагностике, включая границу окончания. За концом значения в честном
сообщении идёт граница формы: фиксированное продолжение диагноза
(неразрешимая ветвь, после которого живой двери разрешён путь клона), конец
вывода либо перевод строки публичной двери; байт значения (дефис и другие)
границей не является — «…SHA: HEAD» внутри «…SHA: HEAD-wrong» более не
проходит. Ожидание — тройка (полный диагноз, голова формы, значение) из
lock мира, снятая в память до вызова субъекта; различение неконформной и
неразрешимой причин, rc 1 и пустой stdout отказа не изменились; символьный
pin не нормализуется в разрешившийся SHA. Предикат один для --model,
--stabs и живой двери; самоконтроль pin-diagnostic-boundary-selfcheck
принимает честные формы живой двери и отказывает подменам окончания
(дефис, продолжение hex-цифрой). Суффиксная подмена — четыре адресных
стаба pin-suffix-forged-head/-branch/-short/-noflag, привязка в STABS по
коду (Н-39), каждый пойман своей клеткой; префиксный pin-value-forged
сохранён. Красное-до — мутация критика Crit187V5 дословно на дереве без
правки rc 0 (Замер 3); зелёное-после — Замеры 1-2; живой путь — Замер 4.
Числа: клетки 61 (без изменений), стабы 71→75.

- К-10 · клетка · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0

## Замеры пачки (числа из вывода команд)

1. `--model` → rc 0: «GREEN pin-diagnostic-boundary-selfcheck 9/9»,
   «CELLS=61 STABS=0 FAILURES=0».
2. `--stabs` → rc 0: «CELLS=61 STABS=75 FAILURES=0»; все 75 стабов пойманы
   («STAB … caught @ …»), включая 4 новых суффиксных
   (pin-suffix-forged-head/-branch/-short/-noflag); непойманных нет.
3. Мутация критика (команда из вердикта Crit187V5 дословно, подмена только
   в памяти процесса, файлы не меняются): на дереве без правки
   (e9c70d2706) → rc 0, «CELLS=61 STABS=0 FAILURES=0» — красное-до
   воспроизведено; на кандидате v4b → rc 1, красны ровно четыре
   неконформные клетки (pin-symbolic-head, pin-symbolic-branch,
   pin-short-sha, pin-head-noflag) с output='ARCH_PIN: закреплённый pin не
   полный 40-hex SHA: <pin>-wrong', «FAILURES=4»; pin-unresolvable-sha
   зелена.
4. Живой голый прогон (дверь пачкой не менялась): `--repo .` → rc 1,
   красных ровно 5 прежних (pin-symbolic-head, pin-symbolic-branch,
   pin-short-sha, pin-head-noflag, applicability-lock-no-dir) — известное
   красное до ремонта implementer 187а, не новый дефект; pin-unresolvable-
   sha зелена на живой двери с прежней диагностикой и путём клона;
   самоконтроль 9/9 и на живом пути.
5. Сосед 170 (пачкой не менялся): red_arch_component_170.sh --model →
   rc 0 — замороженная батарея соседа переживает v4b.
6. provodka → rc 0 «PROVODKA_RC=0»; ceilings → rc 0 «потолки в порядке»;
   threat_model → rc 0 «модель угроз: секция валидна» (двери листа).

## Остаточный риск и ловцы

Как назвал арбитр Arb187V1 (готовая строка, не новая санкция риска);
открытый К-10 остаточным риском не принимается — обязательство сохранено,
ремонт конечен:

> НЕ ЗАЩИЩАЕТ: различение точного pin в диагностике не доказывает
> истинность содержимого закреплённой архитектурной модели и не исключает
> сознательный обход проектного CI; ловцы — reviewer реализации по
> источнику модели и публичной двери, предметный CI по поставленной
> батарее, adversary в предусмотренном рисковом реализационном суде.
> Подмена значения pin в обязательном отказе в этот остаток не входит.

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

- `HEAD:scripts` и `042c48cd2dab054654596dcf93f19f0907edcc6f:scripts`
  в TEST → один tree `ff08f98b97a7069fac4c7d8ac7de39c24d7d2914`;
  `git diff --exit-code 042c48cd2dab054654596dcf93f19f0907edcc6f -- scripts`
  → rc 0, вывод пустой. Совпадает вся директория scripts, не только
  два файла предполагаемого шва.
- `scripts/zamok_predmeta.sh` → blob
  `cc88f40037f3f7e907e1a28e7a289ab0014b0e48`;
  `scripts/freeze_contract.sh` → blob
  `8d79c4cbf7008178da058ec267c7c0485ee16cc3`.
- `HEAD:fixtures/workshop_project/architecture_process_187` в TEST и
  тот же путь принятого 434ec554 → tree
  `cdd855f6e9ceb0eb708025e48fc3b99bfd5b53de`;
  `workflow_probe.py` → принятый blob
  `e125189047681bd53033f8718b28e0a7368f4881`.
- Разница собранного snapshot с seed — только лист sdacha_187.md
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
| done-review-missing | 1 / ARCH_REVIEW |
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

- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`
- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`
- `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs`
- `bash scripts/check_sdacha.sh . contracts/187-arhitektura-v-processe.md --run`

