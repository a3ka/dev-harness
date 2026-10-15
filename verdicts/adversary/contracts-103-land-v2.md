FAIL

# Вердикт adversary: контракт 103, круг 2 (v2)

Проверен текущий `origin/wip/103/implementer2`:
`dc094da152445b8bb4029fbba316c9e95ed02333` (`git ls-remote` выполнен до
клонирования). Предмет и проверка не изменялись. Моя роль — исполнение
обманных реализаций против батареи, а не оценка текста/плана; семейство роли
`adversary` отлично от `implementer`.

## Перепроверка закрытий A103-1 и A103-2 — закрыты

На текущем tip оба штатных контура зелёные:

```text
bash fixtures/_krasnye_103.sh         # rc=0
bash fixtures/_krasnye_103.sh --model # rc=0
```

В обоих прогонах `battery_stubs.sh` поймал все 21/21 своих мутаций, а 11
клеток получили rc=0. В частности, `red_standart_etalon.sh` на текущем tip
предъявил закрытия прошлой версии:

```text
— i4а/prioritet: rc=0, отказов нет
— i4а/pustoj-repo: rc=2, NOT_IMPLEMENTED
```

То есть конфликт `--layer-root R` с враждебным
`HARNESS_PROJECT_LAYER_ROOT` больше не проходит при ошибочном приоритете, а
пустое `--repo` классифицируется как «нечем проверить», а не как shell error.

Также пройдены соседние и контрактные smoke-пути:

```text
bash fixtures/_krasnye_095.sh                                  # rc=0
bash fixtures/_krasnye_072.sh                                  # rc=0
bash scripts/pre_critic.sh contracts/103-profilnye-puti-vmesto-harness-layout.md # rc=0
# КРИТИК: дверь зелёная
```

Проверка запрета зашитых путей из §Приёмка дала пустой вывод и rc=1, как
требует pipe-приёмка (внутренний `grep` не нашёл запрещённых литералов).

## BLOCKS — A103-3: три стандартные клетки не отличают root-only от эффективного профиля

### Обманная реализация

Я скопировал `scripts/check_project_standard.sh` во временный файл и заменил
ровно поведение `eff()`: он читает
`.workflowPaths.*` и `.commands.*` только из `R/harness.project.json`, но
намеренно игнорирует `defaults` в найденном проектном слое. Остальные
проверки (git, каталогов, lockfile, AGENTS, контекстной карты, env и pin)
остались эквивалентны субъекту.

Это неверная реализация Frontier И-4: контракт требует **эффективные**
`workflowPaths` и `commands` (repo, иначе defaults слоя). Она правдоподобна:
субъект всё ещё находит и проверяет `projectLayer.profilePath`, но берёт
значения не из того источника.

### Батарея пропустила мутант

Каждая из трёх клеток стандарта была запущена отдельно с этим мутантом через
`PP103_STANDARD`; все завершились зелёным:

```text
PP103_STANDARD=.../check_project_standard_root_only.sh \
  bash fixtures/project_paths_103/red_standart_etalon.sh
# rc=0
# i4а/etalon, prioritet, sloj-vne, sloj-vne-cli — все rc=0

PP103_STANDARD=.../check_project_standard_root_only.sh \
  bash fixtures/project_paths_103/red_standart_narushenija.sh
# rc=0; все 16 предъявлений названы

PP103_STANDARD=.../check_project_standard_root_only.sh \
  bash fixtures/project_paths_103/red_standart_polnyj_nabor.sh
# rc=0; komandy-true, env-example, harness-pin названы
```

Следовательно, три клетки используют миры, где проверяемые эффективные
значения дублируются в корневом профиле. Они ловят снятие отдельных условий,
но не вопрос об источнике этих значений.

### Разделяющий defaults-only позитивный контроль

Построен живой Complior-мир из `_t103_complior`, затем из его
`harness.project.json` удалены `workflowPaths`, `commands` и `contextPack`.
Их значения перенесены в `defaults` проектного слоя
`.harness/registry/harness-project.json`. Корневые обязательные ключи
`schemaVersion=1`, `repoId`, `language`, `projectLayer` сохранены; все
каталоги и остальные условия эталона остаются годными.

Это допустимый случай контракта: значения должны получаться только как
эффективные defaults слоя. Результаты:

```text
bash defaults_only_control.sh scripts/check_project_standard.sh 0
# A103-3 defaults-only: rc=0 as expected

bash defaults_only_control.sh fixtures/project_paths_103/model/check_project_standard.sh 0
# A103-3 defaults-only: rc=0 as expected

bash defaults_only_control.sh check_project_standard_root_only.sh 1
# A103-3 defaults-only: rc=1 as expected
```

У мутанта rc=1 именно с `ОТКАЗ: стандарт: profil: нет workflowPaths.*`.
Честная модель и реальный субъект на идентичном мире зелёные. Поэтому это
дефект проверки, не ложный отказ либо свойство реализации.

### Необходимое закрытие

В зоне architect добавить defaults-only зелёный сценарий для
`check_project_standard`: корень содержит только обязательные корневые
ключи, а все `workflowPaths`, `commands` и `contextPack.rows` существуют
только в defaults найденного слоя. Сценарий должен требовать rc=0 и отсутствия
`ОТКАЗ: стандарт:`. В `battery_stubs.sh` привязать к нему root-only стаб,
который отключает fallback `eff()`; этот стаб обязан дать rc=1 с причиной
`profil`.

До этого чистая батарея 103 не доказывает соблюдение слоя effective profile
для стандарта, поэтому вердикт — **FAIL**.
