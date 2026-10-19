FAIL
OBJECT=75eb586db0c929cef9c8eeb8d1c814ca73d9b2c1

# Адверсарий контракта 996, круг 3

## Блокирующая находка 1 — `make_task` обходит единый `project_paths_resolve` для `workflowPaths.state`

**Обход.** Контракт требует, чтобы рабочие артефакты state находились только в проекте, а `project_workflow` отказывался до записей на `..`, абсолютном пути либо symlink-побеге. `scripts/next_id.sh:404–415` реализует этот отказ для `state`; `scripts/make_task.sh:64–75` и штатная ветвь `:221–223` вместо этого заново читают merged profile и конкатенируют `$REPO_ABS/$STATE`, не вызывая `project_paths_resolve` и не проверяя state.

Состояние дерева обхода: в корректном disposable project из product probe профиль содержит только `workflowPaths.state = "../outside-state"`; для штатной ветви make_task добавлен законный contextPack, frozen-тег и model trace. Это не отказ «всех дверей»: настоящий resolver честно отказывает, но оба публичный и штатный входы `make_task` зелёные и выдают startup за пределами R.

Сырая команда и свидетельство:
```text
$ python3 /tmp/dev-harness-verify/Adv996r3/state_escape_repro.py; printf 'RC=%s\n' $?
project_workflow_rc=1
make_task_context_rc=0
make_task_task_rc=0
context_has_outside_startup=True
task_has_outside_startup=True
task_stderr=
RC=0
```

`make_task --print-context` возвращает, в частности, `.../project/../outside-state/HANDOFF.md`, `NABLIUDENIA.md` и `ROADMAP.md`. Штатный `--kind task` печатает тот же наружный startup-контекст. Следовательно роль может направить HANDOFF/NABLIUDENIA*/ROADMAP/forks не в state проекта, хотя предмет не выполнен.

Проверка не ловит нейтрализацию обязательного state-guard: `print-context-escape` и `workshop-print-context-escape` меняют только `workflowPaths.registry` на внешний symlink; ни одна клетка не задаёт `state=../…` и не сопоставляет rc/output `make_task` с отказом `project_workflow`.

## Блокирующая находка 2 — единый resolver принимает лексический `..` в четырёх workflowPaths

**Обход.** Тот же контракт предписывает отказ на `..` для всех объявленных workflowPaths. Однако `project_paths_resolve` проверяет для contracts/verdicts/registry/fixtures лишь realpath-вложенность (`scripts/next_id.sh:388–400`). Поэтому существующий внутренний путь `normalizer/../.harness/ledger` проходит, а JSON возвращает его с буквальным `..`. В отличие от state, лексический guard отсутствует также в дублирующей ветви make_task.

Сырая команда и свидетельство:
```text
$ python3 /tmp/dev-harness-verify/Adv996r3/path_traversal_repro.py; printf 'RC=%s\n' $?
project_workflow_rc=0
project_workflow_registry_has_dotdot=True
make_task_context_rc=0
make_task_registry_has_dotdot=True
RC=0
```

Это правильный realpath, но ответ не на объявленный вопрос: требование — запретить сам вход `..`, а реализация отвечает лишь «после нормализации всё ещё внутри». Клетка `paths-escape` проверяет только `../outside`, поэтому стабильный контрпример внутри R остаётся зелёным.

## Обязательные классы входов sourceCanon

Проверены реальные двери на отдельных мирах. Внешний symlink, каталог и FIFO закрываются source-gate; `..`, абсолютный и пустой path закрываются resolver; честный внутренний regular file остаётся зелёным. Внутренний symlink на regular file принимается (целевой файл внутри R), что соответствует текущему явному `-f`+`readlink -f` дизайну, поэтому отдельной находкой не объявляется.

```text
$ python3 /tmp/dev-harness-verify/Adv996r3/source_inputs_repro.py; printf 'RC=%s\n' $?
symlink-outside: resolver=0 gate=1
 directory: resolver=0 gate=1
traversal: resolver=1 gate=1
absolute: resolver=1 gate=1
empty: resolver=1 gate=1
fifo: resolver=0 gate=1
symlink-inside: resolver=0 gate=0
RC=0
```

## Позитивный контроль и ложная зелень проверки

Точная зарегистрированная CI-команда — `npm run check:rezhim-996-family-selftest` (`registry/ci-steps.tsv:129`); она вызывает `probe.sh` без аргументов. Сам `probe.py --cases` не является CLI этой батареи и возвращает argparse rc=2. На OBJECT зарегистрированная product-проба и матрица зелёные, хотя оба обхода выше существуют:

```text
$ bash fixtures/workshop_project/rezhim_996/probe.sh; printf 'RC=%s\n' $?
996: examined=97 mutants=0 mismatches=0
RC=0

$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix; printf 'RC=%s\n' $?
996: examined=97 mutants=71 mismatches=0
RC=0

$ bash scripts/verify_ci_parity.sh; printf 'RC=%s\n' $?
workflow-команд: 19 · скриптов в приёмке: 73 · объявленных исключений: 27 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
RC=0
```

Позитивный контроль тем самым не вечно-красный: 97 честных product сценариев проходят. Но модельные мутанты 71/71 не покрывают две реальные ветви, и зелёная батарея не опровергает предъявленные обходы.

## Совет автору

Сделать `project_paths_resolve` единственным расчётом и для обоих режимов `make_task`; передавать в JSON только его канонические значения. Для каждого workflowPaths ключа закрыть лексический `..` до `readlink -f`, как уже закрыт `state`. Добавить product red-cells для `state=../outside-state` в `make_task --print-context` и штатном `--kind task`, а также для внутреннего `normalizer/../…`; у каждой — честный profile без `..` как позитивный контроль.
