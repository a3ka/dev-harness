FAIL

Обнаружен зелёный обход предмета: проверка удостоверяет содержимое блока extension-операции, но не её маршрут `path + method`.

## Блокирующий репро

В одноразовом клоне OBJECT после единственной злонамеренной строки сразу после
`A_TEXT=merge_openapi()` в `tests/tools/generate_derived.py`:

```python
A_TEXT=A_TEXT.replace(
    '  /partner/v1/onboarding-applications:\n',
    '  /partner/v1/onboarding-applications-relocated:\n',
    1,
)
```

я запустил штатный writer, затем штатный `node tests/tools/gen-contracts.js`, ещё раз writer для штатного `FILES.sha256`, и удалил только self-created `evidence/` до последнего пересчёта inventory. Источник extension не менялся. Он по-прежнему задаёт:

```yaml
/partner/v1/onboarding-applications:
  post:
    operationId: createPartnerOnboarding
```

В опубликованном контракте первоначальный путь отсутствует, а операция `createPartnerOnboarding` доступна по ложному `/partner/v1/onboarding-applications-relocated`. Это не косметика: маршрут является частью импортируемой OpenAPI-операции; импорт перестаёт быть семантически равным pinned extension.

Несмотря на это, ошибочное дерево прошло все заявленные product barriers:

| Команда | Наблюдение |
|---|---|
| `python3 tests/tools/generate_derived.py --check` | rc=0 |
| `node tests/tools/gen-contracts.js --check` | rc=0 |
| `python3 tests/spec-3.15/validate_import_315.py` | rc=0, `failures=[]` |
| `python3 tests/spec-3.14/validate_contract_v3_9.py` | rc=0 |
| `NODE_PATH=/tmp/dev-harness-verify/Impl119/back/node_modules bash /home/harness/dev-harness/fixtures/workshop_project/import315_119/import315_oracle.sh .` | rc=0, `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product` |

Причина: п.9a `validate_import_315.py` сравнивает `operation_block()` только после строки `operationId`, поэтому path и HTTP method вне сравнения. `operation-index` пересобирается из уже ложного published и потому согласован с ним; `gen-contracts` и независимая JSON-проекция оракула также проверяют только согласованность с тем же ложным published. Пин хранит hash неизменённого source extension, но не его проекцию в published.

Исправление за автором: в независимой проверке `tests/spec-3.15/validate_import_315.py` после разрешённой денормализации построить для source extension и published отображение `operationId -> (path, method)` и требовать точного равенства для всех extension operations (либо сравнивать path-item/method-object структурно). Добавить отдельную клетку батареи, которая переносит ровно `createPartnerOnboarding` на иной path при неизменном `operationId`, блоке, счётах и source hash; ожидаемая named-причина — например `extension-op-iskazhena`.

## Контроли и другие обманные стабы

Позитивный контроль честного OBJECT с доступным npm-деревом прошёл: product oracle rc=0 с той же строкой `IMPORT315_OK`; `generate_derived.py --check`, `gen-contracts.js --check`, spec-3.15 и spec-3.14 lanes дали rc=0. Модель батареи прошла rc=0: `34` клеток, `34` зелёных, `0` красных.

Проверил закрытие прежнего обхода содержимого блока: подмена в writer `x-permission: partner:onboarding:create` на `mobility:cases:read` при неизменном source даёт rc=0 у обоих generator checks, но spec-3.15 валидатор rc=1 с `extension-op-iskazhena`, а oracle rc=1 с `validator-kreven`. Значит поблочная проверка ловит тело операции, но не её координаты.

Проверил стаб-оракулы: `stab_vsegda_zelenyj.sh` и `stab_vsegda_krasnyj.sh` на `red_import315_119.sh --model` дают rc=1; always-green даёт `1` зелёную и `33` красных клетки. Неизвестная клетка даёт rc=2.

## Неблокирующий дефект батареи/окружения

Без доступного `yaml` (точный вызов `env -u NODE_PATH PYTHONDONTWRITEBYTECODE=1 bash .../import315_oracle.sh .` в чистом одноразовом клоне) oracle вернул rc=1 с `gencontracts-rashozhdenie`, хотя `node tests/tools/gen-contracts.js --check` не может загрузить `yaml`. Это отказ по ложному диагнозу зависимости, а не расхождение schemas. Он не меняет FAIL выше и не является блокером реализации при доступном npm-дереве. Батарее следует до проверок/probe-clones явно проверить npm dependency resolution и вернуть named `NEEDS_ENV` с rc=2, либо обеспечить `NODE_PATH` для клонов; не сводить `MODULE_NOT_FOUND` к продуктовой причине.

## Зона

`git diff --name-only a227f9bbcb62a48451e33bab28ac40dd2fc74d8f..OBJECT` содержит только `FILES.sha256`, обе разрешённые `app/schemas/*`, разрешённый `tests/spec-3.14/validate_contract_v3_9.py`, `tests/spec-3.15/validate_import_315.py`, `tests/tools/generate_derived.py` и `docs/contracts/*`. Выхода за v2-зону в наблюдаемой дельте нет.
