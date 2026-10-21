FAIL

Обнаружен обход приёмки: оракул, `tests/spec-3.15/validate_import_315.py` и `tests/tools/generate_derived.py --check` не доказывают, что опубликованные новые операции семантически равны pinned `platform-extension.yaml`.

В одноразовом клоне я внёс единственную злонамеренную строку после `A_TEXT=merge_openapi()` в `tests/tools/generate_derived.py`:

```python
A_TEXT=A_TEXT.replace('x-permission: partner:onboarding:create','x-permission: mobility:cases:read',1)
```

После штатного writer-а источник extension остался неизменным и pinned, но опубликованная `createPartnerOnboarding` получила `x-permission=mobility:cases:read` вместо source `partner:onboarding:create`. Это искажение авторизации новой операции, а не косметический дрейф. Прямой разбор YAML дал соответственно:

```
partner:onboarding:create
mobility:cases:read
```

Несмотря на дефект, на мутированном дереве зелёные:

* `python3 tests/tools/generate_derived.py --check` — rc 0, `Derived files: 675 (расхождений: 0)`;
* `python3 tests/spec-3.15/validate_import_315.py --out /tmp/dev-harness-verify/Adv119/validator-mutated` — rc 0, `PASS_STATIC … операций 233 … consumers 123 … failures=[]`;
* `bash /home/harness/dev-harness/fixtures/workshop_project/import315_119/import315_oracle.sh .` — rc 0, `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product` (oracle also emits existing `comm: … not in sorted order` diagnostics).

Таким образом, `--check` проверяет согласованность outputs с тем же дефектным writer-ом, а validator/oracle проверяют IDs, количества, базовые блоки, consumers, pinned bytes самого source extension и поведение на переименованном operationId, но не семантическое сохранение extension path/method-объектов в published. Это ровно оставляет возможной подмену extension при всех объявленных зелёных барьерах. Требуется независимая проверка: распарсить source extension и published и для каждого extension `path + method` требовать структурное равенство operation object (либо явно определить и проверить минимальное допустимое преобразование YAML anchors), а не только сохранность operationId/count.

Позитивные контроли исходного HEAD `d10612a3eff5c729653f0fe746e09486980ad83a`: oracle rc 0 (`IMPORT315_OK …`), `generate_derived.py --check` rc 0 и validator spec-3.15 rc 0 (`failures=[]`). Зона соблюдена: `git diff --name-only 0ed762b8cb..HEAD` содержит только `docs/`, `tests/tools/`, `tests/spec-3.15/`, `structure-policy.json`, `FILES.sha256`; app/server/migrations не изменены.

Оценка заявок выхода из зоны:

1. **app/schemas — обоснована и обязательна до интеграции.** `app/schemas/source.json` всё ещё содержит SHA `3357412c…e58324`/API 5.8.4, тогда как active published имеет SHA `0cb42f7b…638990a` после импорта. `gen-contracts.js --check` сравнивает оба производных с generated document/source hash. В этом клоне запуск дал rc 1 прежде сравнения из-за отсутствующего npm dependency `yaml`; однако несовпадение входного SHA и логика check доказывают [INFERENCE] красный результат на CI после `npm ci`. Сам факт зависимости не снимает необходимость пересборки.
2. **tests/spec-3.14 — обоснована и уже фактически красная.** `python3 tests/spec-3.14/validate_contract_v3_9.py` дал rc 1: `FAIL_STATIC`, 2137 checks; первый отказ `current_exact_version`, далее 3.15 operations. `run_backend_ci.py` включает этот validator в обязательный package lane через `@contract-validator`, поэтому полный CI остаётся красным и без app/schemas. Это не остаток, который можно закрыть `known-failures`: файл должен остаться пустым.

Следствие: исходная реализация не меняет базовые CAS/If-Match/ReasonCode/consumers и правильно держит base 5.8.4, но приёмочный барьер неполон; кроме того, две заявки выхода из зоны корректно фиксируют реальную незелёность интеграционного CI. Вердикт не является правкой предмета.

Файл: `/tmp/dev-harness-verify/Adv119/verdict.md`.
