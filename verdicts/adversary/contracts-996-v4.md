accept
OBJECT=1c25b7e9f0527083b5ab35258782df3d1ca4226c

# Адверсарий контракта 996, круг 4

Проверен tip реализации `3ea6705b0` после указанного OBJECT. Нового блокирующего обхода оси не найдено.

## Атаки на state и единый resolver

В одноразовом мире внешний `HARNESS_PROJECT_LAYER_ROOT` передаёт профиль со всеми `workflowPaths` из defaults. Это проверяет именно внешнее env-переопределение, не только локальный repo-layer. Ущербные состояния были: `state=../outside`, абсолютный state и symlink наружу. В каждом оба публичных входа отказали без выдачи пути наружу. Позитивные контроли — внутренний symlink и сегмент с буквами `v1..2` — зелёные. Отдельная подмена `jq`, возвращающая 127, тоже не превращена в успех и не печатает JSON.

Сырая команда и rc:
```text
$ python3 /tmp/dev-harness-verify/Adv996r4/env_override_attack.py
…
env-dotdot-segment: project_workflow_rc=1 make_task_rc=1 make_task_leak=False
env-absolute: project_workflow_rc=1 make_task_rc=1 make_task_leak=False
env-symlink-outside: project_workflow_rc=1 make_task_rc=1 make_task_leak=False
env-symlink-inside: project_workflow_rc=0 make_task_rc=0 make_task_leak=False
env-dotdot-substring-control: project_workflow_rc=0 make_task_rc=0 make_task_leak=False
fake-jq-127: project_workflow_rc=1 make_task_rc=1 json_stdout=False
env_override_attack: PASS
RC=0
```

Тем самым не воспроизведены оба прежних обхода: `make_task` получает пути только из `project_paths_resolve`, а сегмент `..` отвергается до нормализации. Контроли доказывают, что это не заглушка «всегда отказать» и не ошибочный подстрочный запрет `v1..2`.

## Нейтрализация и обманные реализации

Матрица связана с реальными дверями. В ней проверены нейтрализации `make-task-own-paths`, `guard-four-keys-only` и `dotdot-substring`: каждая дала ожидаемый красный результат на своём входе; положительные product-сценарии остаются зелёными. Это ловит соответственно собственную конкатенацию вместо resolver, отключение state-гардов и неверный лексический гард. Полная scoped-проверка также покрывает отказ-команду, константный/корневой расчёт, пустые/отсутствующие поля и ответ не на тот вопрос через `make-task-drift`.

Сырые команды и rc:
```text
$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=110 mutants=0 mismatches=0
RC=0

$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=110 mutants=75 mismatches=0
RC=0
```

## Регрессии toy-миров и замороженная граница

Сырые команды и rc:
```text
$ bash fixtures/_krasnye_058.sh
…
честная часть: 16/16 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 16/16
итог 058: rc=0
RC=0

$ bash fixtures/_krasnye_060.sh
060: честных клеток 17, зелёных 17, красных: нет
060: стабов 15, поймано 15, ускользнуло: нет
060: диффпробы стабов без ручек: нет
060: стерегомое дерево харнесса: не тронуто
итог 060: rc=0
RC=0

$ git diff --exit-code 1c25b7e9f0527083b5ab35258782df3d1ca4226c..HEAD -- frozen/contracts/996
RC=0
```

Вердикт относится только к запрошенной оси: state в `make_task`, сегментный `..` и регрессии `next_id.sh`/`project_paths_resolve`. Нормативный гейт этим verdict не закрывается.
