FAIL

# Адверсарий 054 — консолидация кругов 1–2

Судится реализация фикс-раунда `445b386`, слитая в `5d00146`. Проверка
выполнена в одноразовом SSH-клоне от этого HEAD; контракт и проверка не
менялись. Первый круг нашёл шесть обходов. Они действительно закрыты, но
круг 2 нашёл два новых исполнимых класса обхода. Поэтому гейт принимать
нельзя.

## Позитивный контроль, батарея и frozen

В клоне наблюдалось:

```text
$ bash fixtures/_krasnye_054.sh
стаб-пак: просмотрено 15, поймано 15
054-батарея зелёная: все клетки к1-к14 + b1-b6 пройдены
054-батарея зелёная
итог 054: rc=0

$ bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver
БАТАРЕЯ profile_resolver: итог 4/4 классов закрыто
```

То есть набор не вечно-красный: все 15 обманных стабов пойманы на своих
клетках, а честные Rust/TypeScript клетки проходят. Команда

```sh
git rev-parse --verify frozen/contracts/054/1 && \
git diff --exit-code frozen/contracts/054/1 -- contracts/054-profil-dva-sloja-launcher-proekta.md
```

вернула `53dbc719e8305d48cc48ca01b15dec2327da52da` и `rc=0`: frozen-предмет
не изменён.

## Шесть обходов круга 1 — закрыты живым исполнением

Независимый repro построил заново toy-репо и слой для каждого случая,
вызвал именно субъект, и получил ровно требуемый именованный отказ:

| Вектор первого круга | Наблюдение на `5d00146` |
|---|---|
| nested unknown в `defaults.workflowPaths.unseen` | `rc=1`, `неизвестный ключ project: defaults.workflowPaths.unseen` (P4) |
| `commands.test: ""` | `rc=1`, `значение вне алфавита: commands.test: пусто` (P6) |
| `projectLayer.profilePath: "../escaped.json"` | `rc=1`, `корень слоя проекта не задан/недоступен` (P2) |
| AGENTS-файл только с заголовком правил | `rc=1`, `FAIL секции правил нет` (G1) |
| global-only `receive.denyCurrentBranch=refuse`, без local | `rc=1`, `ожидается 'refuse'` (W2) |
| `config/harness_pin.json = {"version":7}` | `rc=1`, `значение вне алфавита: version: <number>` (P6) |

Следовательно, конкретные шесть контрмоделей первого круга больше не
проходят и соответствующие b1–b6 клетки батареи не декоративны.

## Новые векторы, которые не дали обхода

Проверены и отклонены:

- `registry/link.json`, являющийся symlink за пределы корня слоя: `rc=1`, P2;
- обфусцированный выход `registry/../../outside.json`: `rc=1`, P2;
- подстановка `receive.denyCurrentBranch=refuse` через
  `GIT_CONFIG_COUNT/GIT_CONFIG_KEY_0/GIT_CONFIG_VALUE_0` при пустом local:
  `rc=1`, W2;
- переменная `LAYER_ROOT=/nonexistent` не переопределяет
  `HARNESS_PROJECT_LAYER_ROOT`: честный `workshop --probe` дал `rc=0`.

Это подтверждает, что `readlink -f` закрывает проверенные формы выхода из
корня и `git config --local` не принимает Git command/global-env конфиг.

## Новый обход 1 — нестроковые JSON-значения проходят как строки (P6)

И-4 требует конкретные непустые **строки** и литеральный
`schemaVersion = 1`; это не только требование непустого представления после
`jq -r`. Однако резолвер проверяет несколько полей через `jq -r` и
`[ -n "$v" ]`, после чего число, boolean или строка-заменитель становятся
допустимы. Исполненные контрмодели все дали `rc=0`:

1. repo `projectLayer.version: 7` и слой `version: 7`;
2. repo `projectLayer.profilePath: 7`, при существующем файле слоя
   `<LAYER_ROOT>/7`;
3. слой `projectId: 7`, `workspaceId: true`;
4. repo `ci.workflow: 7`, `git.canonicalRemote: true`;
5. repo `barriers.mandatory: "not-array"`;
6. оба `schemaVersion: "1"`.

Первый случай возвращает успешно собранный профиль, в котором
`projectLayer.value.version` уже превращён в строку `"7"`; шестой возвращает
`schemaVersion.value: "1"`. Это именно неправильное принятие значений,
а не иной отказ. Оно нарушает И-3/И-4 и позволяет субъекту подменить
типизированный профиль, который контракт требует отклонять P6.

Причина наблюдаема в `scripts/profile_resolver.sh`: обязательные
`version/projectId/workspaceId`, `ci.workflow`, `canonicalRemote` и pin
берутся `jq -r` без type-gate; `profilePath` до построения пути тоже не
проверяется как строка; `check_barrier_array` молча пропускает не-array;
`schemaVersion` сравнивается с текстом `"1"`.

## Новый обход 2 — `GIT_DIR` перенаправляет local 4.3 на чужой git-dir (W2)

Создано честное project-repo с удалённой local-настройкой 4.3 и отдельный
bare git-dir. В его `config`, созданном через `git config --file`, выставлено
`receive.denyCurrentBranch=refuse`. Затем выполнено:

```sh
HARNESS_PROJECT_LAYER_ROOT=<честный-слой> GIT_DIR=<чужой-git-dir> \
  bash workshop --probe <проект-без-local-4.3>
```

Наблюдён результат:

```text
workshop PROBE OK: <проект-без-local-4.3>
PROMPT: <...>/session-prompt-orchestrator.md
```

то есть `rc=0` там, где должно быть `rc=1` с W2. `git -C "$PROJECT"
config --local --get ...` ограничивает scope конфигурации, но не привязывает
Git к репозиторию: унаследованный `GIT_DIR` меняет именно git-dir, из которого
читается этот «local» config. Поэтому local-проверка стала проверкой
контролируемого окружением чужого git-dir, а не `<проект>/.git/config`.

## Вердикт

**FAIL.** Шесть старых обходов закрыты, но нужны авторские правки и новые
различающие клетки как минимум для строгих JSON-типов/форм всех полей И-4
и для `GIT_DIR`-подмены local-конфига. До этого `rc=0` в двух новых классах
контрмоделей противоречит контракту. Этот вердикт не меняет frozen-контракт.
