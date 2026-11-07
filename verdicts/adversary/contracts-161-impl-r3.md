FAIL
OBJECT=c8d151dacc34590d67dd6547a572d3208945cb3a
КЛАСС=КОДОВЫЙ, РИСКОВЫЙ
СУД: repo=dev-harness; предмет=161; фаза=реализация; роль=adversary; вызов=2/2; сессия=Adversary161Terra2; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; предыдущий=verdicts/adversary/contracts-161-impl-r2.md

## Scoped-повтор: PATH-подмена `git` вновь склеивает внешний state

БЛОКИРУЕТ `contracts/161-revizija-mekhanizmov-proektnaja-raskladka.md:15-16` —
после исправления хеш берётся доверенным `sha256sum`, но вход в этот хеш — всё
ещё недоверенный результат `git` из вызывающего `PATH`. Поэтому два разных
проекта получают один ключ внешнего state и второй `spawn_agent` принимает
манифест первого, хотя второй пакет не готовил.

ОБЯЗАТЕЛЬСТВО: профиль, контракты и контекст обоих входов определяются
собственным git-проектом целевого корня; манифест во внешнем state принадлежит
этому проекту и `spawn_agent` без подготовленного манифеста данного проекта
отказывает до branch/worktree.

СОСТОЯНИЕ: два валидных изолированных проекта с разными common `.git`, разными
bare-origin и одинаковым номером `761` используют одну внешнюю базу `TMPDIR`.
Первый проект подготовил пакет, второй — нет, но у обоих есть легитимный mint.
Перед системным `git` в `PATH` расположен исполняемый wrapper: только для
`git … rev-parse --git-common-dir` он возвращает один существующий каталог
`FORGED_COMMON`, все остальные вызовы передаёт `/usr/bin/git`. Это достижимая
форма окружения: обе двери проверяют лишь доступность `git` через `command -v`
и далее многократно вызывают незафиксированное имя `git`.

НАБЛЮДЕНИЕ: реальная функция атаки из архитектурной батареи
`no_manifest_for_other_project(poisoned=True)` была запущена с указанным
wrapper и настоящими `scripts/make_task.sh`/`scripts/spawn_agent.sh` кандидата.
Первый пакет завершился успешно; второй реальный spawn тоже завершился успешно
и создал ветку и worktree, хотя собственного манифеста не имел:

```text
$ python3 /tmp/dev-harness-verify/Adversary161Terra2/git_path_collision_probe.py
STATE_KEY_COLLISION: second project accepted first manifest: WORKTREE=/tmp/fixture-161-collision-…/external-state/dev-harness-worktrees/99ff0b42/wip-761-architect
BRANCH=wip/761/architect
STATE_KEY_COLLISION: second branch created
STATE_KEY_COLLISION: second worktree created
git_path_collision_probe_rc=1
```

Причина в коде: `scripts/make_task.sh:28` и `scripts/spawn_agent.sh:78`
принимают `git` из `PATH`; `_git_common_dir` в обоих файлах получает через него
`rev-parse --git-common-dir`, а `_project_state_prepare` передаёт подменённую
строку доверенному SHA-256. Доверенность вычислителя не делает доверенным его
вход. Текущая батарея 161 подменяет только `sha256sum`; её `--model` и
`--stabs` не строят эту различающую пару с подменённым `git`, поэтому остаются
зелёными против дефектной реализации.

Закрывающее свойство: общий `.git`, из которого строится ключ внешнего state,
должен быть получен доверенным механизмом либо значение должно быть проверяемо
связано с фактическим целевым git-проектом; подмена `git` из `PATH` не может
дать успешный пакет или spawn, а два разных проекта не могут разделить ключ.
Красная клетка должна запускать настоящие обе двери с описанным selective
wrapper и требовать отказа второго spawn без branch/worktree.

## Контроли и обязательные классы заглушек

Положительный контроль честного кандидата и архитектурные нейтрализации:

```text
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh --model
CONTROL: honest product green
rc=0

$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh --stabs
CONTROL: honest product green
STAB_CAUGHT: optional-skipped
STAB_CAUGHT: foreign-make
STAB_CAUGHT: foreign-write
STAB_CAUGHT: missing-spawn
STAB_CAUGHT: collision-spawn
STAB_CAUGHT: tmpdir-write
STAB_CAUGHT: hash-ignored
rc=0
```

Тем самым прогнаны: пустой/отсутствующий манифест, нейтрализация подготовки,
чужой ответ, запись в main, зашитая константа SHA-256 и отказ `sha256sum` с
кодом 127. Новый контрпример — другой явно заданный scoped-риск: подмена
инструмента `git` из `PATH`; он даёт зелёный выпуск дефектной ветки и потому
блокирует по `roles/critic.md` §«Быстрый-процесс»/§«Порог».

Scoped-регресс кандидата:

```text
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh
rc=0

$ bash fixtures/_krasnye_095.sh .
ИТОГ 095: rc=0

$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0

$ bash fixtures/_krasnye_103.sh /tmp/dev-harness-verify/Adversary161Terra2/candidate
ИТОГ 103: rc=0
```

Прогоны сделаны в одноразовом SSH-клоне
`/tmp/dev-harness-verify/Adversary161Terra2/candidate` на разрешённой ветке
`origin/wip/161/implementer-r3` (HEAD `6a68860434560bc085a3e591e03bb0b6ecef2ab8`);
по заданию blobs предметных `scripts/make_task.sh`, `scripts/spawn_agent.sh` и
`probe.py` идентичны OBJECT. Реализация и проверка не изменялись; временный
attack probe расположен вне репозитория.
