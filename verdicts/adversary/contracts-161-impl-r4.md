accept
OBJECT=1301af07d5d013b661aae3f5bf5f05f64995c4f5
КЛАСС=КОДОВЫЙ, РИСКОВЫЙ
СУД: repo=dev-harness; предмет=161; фаза=реализация; роль=adversary; вызов=3/3 (scoped по слову владельца 2026-11-07 «Б»); сессия=Adversary161Terra3; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; автор=implementer (MiniMax-M3); предыдущий=verdicts/adversary/contracts-161-impl-r3.md

## Scoped-повтор: закрытие PATH-подмены `git`

Проверен ровно класс находки r3 и зависимые пути получения/исполнения `git`.
В OBJECT все вызовы `git` в `scripts/make_task.sh` и
`scripts/spawn_agent.sh` идут через `GIT_BIN`, выбранный только из
`/usr/bin → /bin → /usr/local/bin`; результат `git` из вызывающего PATH не
используется для ключа state. Оба скрипта также до записи выбирают этот путь,
а при отсутствии доверенного исполняемого файла дают `NOT_IMPLEMENTED`.

Зелёной обманной заглушки не найдено. Наблюдаемые атаки:

- повторена атака r3: селективный wrapper `git` в PATH подменяет только
  `rev-parse --git-common-dir` на общий каталог первого проекта. Реальная
  батарея выполнила обе двери; второй проект без собственного манифеста
  отказал до ветки/worktree. В `--stabs` это различающая клетка
  `STAB_CAUGHT: git-path-spawn: GIT_PATH_COLLISION`;
- подставлен ложный `sha256sum`, завершающийся 127: пакет не выдан
  (`STAB_CAUGHT: hash-ignored: HASH_TOOL_UNUSABLE`);
- проверены GIT-переменные на раздельной паре действительных проектов с общей
  внешней базой: `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`,
  `GIT_CONFIG_GLOBAL` с `core.worktree` чужого проекта и
  `GIT_CONFIG_COUNT/core.worktree`. В каждом случае второй `spawn_agent`
  вернул rc=1 `нет манифеста make_task: 761`, ветка не создана;
- `GIT_EXEC_PATH` с ложным `git-worktree` не перехватил
  `/usr/bin/git … worktree list --porcelain`: команда вернула rc=0 и настоящий
  список worktree. Следовательно, скрытый путь этого подкомандного вызова не
  обходит закреплённый бинарник;
- пустой вход (отсутствующий манифест) и нейтрализации подготовки, коллизии,
  чужой записи и размещения state пойманы собственной различающей клеткой.

Это покрывает требуемые классы: отказ 127, зашитая коллизия ключа,
инструмент перед PATH, пустой манифест, ответ чужого проекта и точечные
нейтрализации. Все атаки запускают настоящие `make_task.sh`/`spawn_agent.sh`,
а не подменённый предмет.

## Контроли и scoped-регресс

Положительный контроль честной реализации:

```text
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh --model
CONTROL: honest product green
rc=0
```

Основная красная батарея и её восемь обманных заглушек:

```text
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh
rc=0
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh --stabs
CONTROL: honest product green
STAB_CAUGHT: optional-skipped
STAB_CAUGHT: foreign-make
STAB_CAUGHT: foreign-write
STAB_CAUGHT: missing-spawn
STAB_CAUGHT: collision-spawn
STAB_CAUGHT: git-path-spawn
STAB_CAUGHT: tmpdir-write
STAB_CAUGHT: hash-ignored
rc=0
```

Scoped-регресс затронутых frozen-барьеров:

```text
$ bash fixtures/_krasnye_095.sh .
ИТОГ 095: rc=0
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0
$ bash fixtures/_krasnye_103.sh /tmp/dev-harness-verify/Adversary161Terra3/candidate
ИТОГ 103: rc=0
$ git diff --exit-code HEAD^ HEAD -- contracts fixtures/workshop_project/proektnaja_raskladka_161 fixtures/context_pack_095 fixtures/workshop_project/sessii_136 fixtures/project_paths_103
frozen_barrier_diff=clean
```

Испытания сделаны в разрешённом одноразовом SSH-клоне
`/tmp/dev-harness-verify/Adversary161Terra3/candidate` ветки
`origin/wip/161/implementer-r5`, HEAD
`3782c619d94092f77e8baa0e1b1b97218c7390bb`. Его blobs предмета совпали с
OBJECT: `make_task.sh=bef551ccead0696bd9f902e7aa15776725b57f6d`,
`spawn_agent.sh=cd3846b329b7f4cae859ed2a25cc5b8794819b7f`.
