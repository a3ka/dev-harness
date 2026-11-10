accept
OBJECT=1673a516c4a2d2244a170f6cf13e8d7068c222d1
СУД: repo=dev-harness+Complior-mob; предмет=143; фаза=реализация; роль=adversary; вызов=5/5 по санкции владельца 2026-11-10 ~16:17 UTC; модель-план=openai-codex/gpt-5.6-terra; сессия=Adv143v5; модель-факт=openai-codex/gpt-5.6-terra; кандидат=3b6365ebea316f97d9f165c810fdfabd7f5433cd; предыдущий=verdicts/adversary/contracts-143-impl-v4.md.

Проверен только санкционированный scoped-класс закрытия вызова 4: top-level `permissions`, его листья и связанные top-level управляющие поля `.github/workflows/mobile.yml` (`on`, `concurrency`, `env`, `defaults`, `name`). `wip/143/architect` разрешился в OBJECT, implementer — в `3b6365ebea316f97d9f165c810fdfabd7f5433cd`.

## Позитивный контроль

```text
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143v5/implementer
rc=0
клеток 396, зелёных 396, красных 0
клеток 79, зелёных 79, красных 0

$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
rc=0
стабов 406, привязок 413, живых 0
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
```

## Мутации и сырой вывод

Сначала исполнен независимый sweep полного набора корневых и job/step controls:

```text
$ python3 fixtures/workshop_project/mob_ci_143/workflow_mutation_sweep.py --repo /tmp/dev-harness-verify/Adv143v5/implementer
root.concurrency	workflow-root-concurrency	КРАСЕН rc 1
root.defaults	workflow-root-defaults	КРАСЕН rc 1
root.env	workflow-root-env	КРАСЕН rc 1
root.name	workflow-root-name	КРАСЕН rc 1
root.on	workflow-root-on	КРАСЕН rc 1
root.permissions	workflow-root-permissions	КРАСЕН rc 1
root.permissions.actions	workflow-root-permissions-actions	КРАСЕН rc 1
root.permissions.attestations	workflow-root-permissions-attestations	КРАСЕН rc 1
root.permissions.checks	workflow-root-permissions-checks	КРАСЕН rc 1
root.permissions.contents	workflow-root-permissions-contents	КРАСЕН rc 1
root.permissions.deployments	workflow-root-permissions-deployments	КРАСЕН rc 1
root.permissions.discussions	workflow-root-permissions-discussions	КРАСЕН rc 1
root.permissions.id-token	workflow-root-permissions-id-token	КРАСЕН rc 1
root.permissions.issues	workflow-root-permissions-issues	КРАСЕН rc 1
root.permissions.models	workflow-root-permissions-models	КРАСЕН rc 1
root.permissions.packages	workflow-root-permissions-packages	КРАСЕН rc 1
root.permissions.pages	workflow-root-permissions-pages	КРАСЕН rc 1
root.permissions.pull-requests	workflow-root-permissions-pull-requests	КРАСЕН rc 1
root.permissions.repository-projects	workflow-root-permissions-repository-projects	КРАСЕН rc 1
root.permissions.security-events	workflow-root-permissions-security-events	КРАСЕН rc 1
root.permissions.statuses	workflow-root-permissions-statuses	КРАСЕН rc 1
полей 316, мутантов 316, поймано 316, живых 0
```

Ручные независимые копии кандидата проверили именно отказ вызова 4 и варианты нейтрализации. Все команды ниже завершились rc=1, то есть мутант пойман; только `permissions`/его листья менялись.

```text
$ python3 .../matrix_v3.py --repo mut-contents-write --workflow-cell workflow-root-permissions-contents
КЛЕТКА workflow-root-permissions-contents КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions-contents

$ python3 .../matrix_v3.py --repo mut-contents-none --workflow-cell workflow-root-permissions-contents
КЛЕТКА workflow-root-permissions-contents КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions-contents

$ python3 .../matrix_v3.py --repo mut-contents-delete --workflow-cell workflow-root-permissions-contents
КЛЕТКА workflow-root-permissions-contents КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions-contents

$ python3 .../matrix_v3.py --repo mut-permissions-delete --workflow-cell workflow-root-permissions
КЛЕТКА workflow-root-permissions КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions

$ python3 .../matrix_v3.py --repo mut-permission-wrong-leaf --workflow-cell workflow-root-permissions-contents
КЛЕТКА workflow-root-permissions-contents КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions-contents
```

Полный wrapper на опасном `permissions.contents: read → write` тоже красен, не только выбранная клетка:

```text
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143v5/mut-contents-write
rc=1
КЛЕТКА legacy КРАСНА: LEGACY_JOB_CHANGED
КЛЕТКА workflow-root-permissions КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions
КЛЕТКА workflow-root-permissions-contents КРАСНА: WORKFLOW_CONTROL_workflow-root-permissions-contents
клеток 396, зелёных 393, красных 3
клеток 79, зелёных 79, красных 0
```

Отдельные required adversarial controls также fail-closed:

```text
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh
rc=1
MATRIX_SUBJECT_ABSENT
клеток 80, зелёных 0, красных 80 — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)

$ dirname(){ /usr/bin/dirname "$@"; }; export -f dirname; PATH=/nonexistent /bin/bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model
rc=2
NOT_IMPLEMENTED: нет python3
```

Итог: нет зелёной обманной заглушки в санкционированном классе. Предыдущий обход `permissions.contents: read → write` закрыт именованной клеткой, а sweep дополнительно перечисляет и ловит сам root `permissions`, каждый из 14 permission-scope leaves и заданные top-level controls. Блокирующих находок нет.
