accept
OBJECT bba6e4b1867a3e8281ecef3435d905e7b99de044 проверен в одноразовом локальном клоне; HEAD совпадает.

A-1. Честное дерево: `validate_import_315.py` rc=0 (`failures=[]`, 233=163+70); `generate_derived.py --check` rc=0; `gen-contracts.js --check` rc=0; spec-3.14 rc=0 PASS_STATIC. Два последовательных запуска оракула architect `import315_oracle.sh` дали rc=0 и `IMPORT315_OK operations=233 schemas=566 consumers_confirmed=53 consumers_total=123 new_consumers=70 tables=29 known_issues=14 pin=product`. После удаления собственного вывода одиночного запуска spec-3.14 рабочее дерево не содержит `evidence/` (только симлинк `node_modules`).

A-2. Writer-side мутации в отдельных локальных клонах: инъекция делалась сразу после `A_TEXT=merge_openapi()`, затем штатно `generate_derived.py`, `gen-contracts.js`, `generate_derived.py`. Для b1 (security перед getSession), b2 (delete без operationId в `/v1/session`), b3 (servers в extension path item) и b4 (корневой security=[]) валидатор rc=1 с `document-ne-sliyanie`, оракул rc=1 с собственной причиной `dokument-ne-sliyanie`.

A-3. Тем же writer-side способом m1/m2 (перенос path/смена метода extension), m3/m4 (перенос path/смена метода ядра) и extension `x-permission` дали у валидатора rc=1 `document-ne-sliyanie`, у оракула rc=1 `dokument-ne-sliyanie`.

A-4. `red_import315_119.sh --model`: rc=0, 46/46 зелёных. Стабы «всегда зелёный» и «всегда красный»: rc=1; неизвестная клетка: rc=2; d37 в модели подтвердил NEEDS_ENV rc=2; `LC_ALL=C` k-model rc=0. Контрмодель без STRUKTURA-315 дала на d35/d36/d40–d46 ожидаемую слепоту (каждая клетка rc=1 батареи с фактом rc=0 IMPORT315_OK); без ADDITIV-315 — ту же слепоту d13.

A-5. Grep удалённых `operation_routes|PATH_ITEM_RE|METHOD_ITEM_RE|OPERATION_ID_AT_LEVEL_RE` в валидаторе и `route_diff|MARSHRUT-` в оракуле: оба rc=1, совпадений нет.

A-6. Дельта OBJECT^..OBJECT содержит только `tests/spec-3.15/validate_import_315.py` и `FILES.sha256`; автор коммита `implementer`, тема «119 круг 4». sha256 валидатора `fef12b82c9080d18268f54fa400d7ca99a877a595aff17b0abc782323cae50f7` совпадает со строкой FILES.sha256.

A-7. Новый контур — одна функция `merged_document`, одна рекурсивная диагностика `first_difference` и один вызов сравнения; второго структурного способа сравнения тех же данных не найдено.
