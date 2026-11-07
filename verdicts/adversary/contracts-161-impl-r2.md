FAIL
OBJECT=b97b64e124cde4e890c1d973314d0fa10e49fe6d
КЛАСС=КОДОВЫЙ, РИСКОВЫЙ
СУД: repo=dev-harness; предмет=161; фаза=реализация; роль=adversary; вызов=1/2; сессия=Adversary161Terra; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra

## Блокирующая находка: незащищённая идентичность внешнего state

БЛОКИРУЕТ `contracts/161-revizija-mekhanizmov-proektnaja-raskladka.md:15-16` —
внешний манифест обязан принадлежать собственному git-проекту целевого корня и
находиться вне основного checkout и его `.git`; кандидат вычисляет его каталог
из неаутентифицированных `TMPDIR` и результата `sha256sum` из `PATH`.

ОБЯЗАТЕЛЬСТВО: `make_task` из project-worktree оставляет main неизменным,
`spawn_agent` до создания worktree читает именно манифест данного проекта;
внешний state не расположен в main или `.git`.

СОСТОЯНИЕ: два валидных изолированных проекта с разными bare-origin и
одинаковым номером `761`; первый подготовил пакет, второй — нет, но имеет
санкционированный локальный и origin mint. В `PATH` перед первым системным
каталогом находится исполняемый `sha256sum`, который для любого входа печатает
один корректно оформленный хеш из 64 нулей и завершает rc 0. Это достижимая
подмена окружения: обе двери сами принимают `PATH`, предварительный
`command -v sha256sum` её принимает, а `project_state_dir` в
`scripts/make_task.sh:232-238` и `scripts/spawn_agent.sh:129-135` без проверки
доверяет результату.

НАБЛЮДЕНИЕ: первый реальный `make_task` вернул rc 0, после чего реальный
`spawn_agent` второго проекта, не готовившего своего манифеста, тоже вернул rc
0 и создал `wip/761/architect`:

```text
$ PATH=/tmp/dev-harness-verify/Adversary161Terra/fakebin:$PATH \
  python3 /tmp/dev-harness-verify/Adversary161Terra/hash_collision_probe.py
first_make_task_rc=0
second_spawn_rc=0
WORKTREE=/tmp/adversary-161-hash-collision-…/dev-harness-project-state/00000000/wip-761-architect
BRANCH=wip/761/architect
```

Манифест первого проекта был принят вторым: это выпуск агента без
подготовленного манифеста его собственного проекта. Это не коллизия SHA-256, а
ошибка механизма доверия к утилите из вызывающего `PATH`; обычная батарея не
строит два проекта с принудительно совпавшим ключом.

Независимый вариант той же причины не требует подмены инструмента. При
`TMPDIR=<project-main>` настоящий `make_task` из отдельного worktree записывает
внешнее state внутри живого main и успешно завершает:

```text
$ python3 /tmp/dev-harness-verify/Adversary161Terra/tmpdir_escape_probe.py
make_task_rc=0
main_changed=True
manifest_paths=dev-harness-project-state/4e40f4b09f5214f6/context/761.tsv
```

Следовательно, произвольный `TMPDIR` способен прямо нарушить запрет записи в
основной checkout. Закрывающее свойство: база state и её ключ должны быть
проверяемо привязаны к целевому проекту, уникальны между разными common `.git`
и канонически вне всех его checkout/.git; неприемлемый `TMPDIR`, поддельный или
неисполняемый хеш не могут давать успешный пакет либо разрешать spawn. Красная
батарея должна предъявить обе различающие пары: два проекта при одинаковом
ключе и `TMPDIR`, разрешающийся в main (включая symlink).

## Контроли и атаки проверки

Положительный контроль кандидата:

```text
$ bash fixtures/workshop_project/proektnaja-raskladka_161/red_proektnaja_raskladka_161.sh
rc=0

$ bash fixtures/workshop_project/proektnaja-raskladka_161/red_proektnaja_raskladka_161.sh --model
CONTROL: honest product green
rc=0
```

Архитекторские четыре нейтрализации пойманы на своих входах:

```text
$ bash fixtures/workshop_project/proektnaja-raskladka_161/red_proektnaja_raskladka_161.sh --stabs
CONTROL: honest product green
STAB_CAUGHT: optional-skipped: CONTEXT_FOREIGN: missing exact REUSE: docs/reuse.md
STAB_CAUGHT: foreign-make: CONTEXT_FOREIGN: make_task
STAB_CAUGHT: foreign-write: FOREIGN_DIRTY: make_task changed foreign project
STAB_CAUGHT: missing-spawn: MANIFEST_MISSING:
rc=0
```

Пробованы обязательные классы: нейтрализация и пустой вход пойманы четырьмя
стабами; отсутствующий `sha256sum`, возвращающий rc 127, не дал ложной зелени
(`SPAWN_REFUSED`, затем `CONTROL_INVALID`, rc 1). Но зашитая константа в том же
инструменте дала зелень и на модели, и на стабах:

```text
$ PATH=/tmp/dev-harness-verify/Adversary161Terra/fakebin:$PATH bash fixtures/workshop_project/proektnaja-raskladka_161/red_proektnaja_raskladka_161.sh --model
CONTROL: honest product green
rc=0

$ PATH=/tmp/dev-harness-verify/Adversary161Terra/fakebin:$PATH bash fixtures/workshop_project/proektnaja-raskladka_161/red_proektnaja_raskladka_161.sh --stabs
CONTROL: honest product green
STAB_CAUGHT: optional-skipped: CONTEXT_FOREIGN: missing exact REUSE: docs/reuse.md
STAB_CAUGHT: foreign-make: CONTEXT_FOREIGN: make_task
STAB_CAUGHT: foreign-write: FOREIGN_DIRTY: make_task changed foreign project
STAB_CAUGHT: missing-spawn: MANIFEST_MISSING:
rc=0
```

Это также случай «правильный ответ не на тот вопрос»: батарея сверяет, что
make/spawn согласны на одном пути, но не различает, принадлежит ли этот путь
проекту, когда вычислитель ключа подменён.

## Scoped-регресс и неизменность

```text
$ bash fixtures/_krasnye_095.sh .
ИТОГ стаб-пак 095: rc=0
ИТОГ 095: rc=0

$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0

$ bash fixtures/_krasnye_103.sh /tmp/dev-harness-verify/Adversary161Terra/candidate
ИТОГ стаб-пак 103: rc=0
ИТОГ 103: rc=0

$ git diff --exit-code 761e2fad..b97b64e124cde4e890c1d973314d0fa10e49fe6d -- fixtures/context_pack_095 fixtures/project_paths_103 scripts/zamok_predmeta.sh
frozen_barrier_diff_rc=0
```

Объект был судим в одноразовом SSH-клоне
`/tmp/dev-harness-verify/Adversary161Terra/candidate`; временные атакующие
артефакты остаются вне репозитория. Правок предмета и проверки не вносилось.
