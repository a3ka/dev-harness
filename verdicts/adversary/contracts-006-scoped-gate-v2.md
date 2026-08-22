FAIL

Повторный адверсарий-круг контракта 006 против HEAD `f386fcd`.

## Прежние четыре обхода закрыты

Все команды запускались на текущем предмете; для прогона раннера до и после был выполнен требуемый `pkill -9 -f 'verify_antiplacebo|check_scop|metering_proxy|check_metering' 2>/dev/null || true`.

1. `bash tmp/adversary-006/setup-sourced-barrier.sh tmp/adversary-006/sourced-barrier` вернул базу `03e43b94c32e2ad82b2cfffe06a2d6fe8a0a666d`; затем
   ```sh
   bash scripts/scope_select.sh tmp/adversary-006/sourced-barrier --changed 03e43b94c32e2ad82b2cfffe06a2d6fe8a0a666d
   ```
   вывел `MODE: full` (и `SCOPED: не для приёмки`).
2. `bash tmp/adversary-006/setup-dynamic-source.sh tmp/adversary-006/dynamic-source` вернул базу `0d555f1bf772b52eb65adad29afb6ecbc8fe152a`; затем аналогичный `--changed` вывел `MODE: full`.
3. `bash tmp/adversary-006/setup-passive-key.sh tmp/adversary-006/passive-key && bash scripts/scope_select.sh tmp/adversary-006/passive-key --scope lib_x` завершился кодом `1` и вывел `неизвестный ключ lib_x`.
4. `bash tmp/adversary-006/setup-home-leak.sh tmp/adversary-006/home-leak && bash scripts/verify_antiplacebo.sh tmp/adversary-006/home-leak` завершился кодом `1`. Существенный вывод: `FAIL b/case_b.sh: барьер остался зелёным на обманном дереве — красное не предъявлено`; значит HOME a не протёк в b.

Также прямой статический граф `a → b → c` закрыт: после `bash tmp/adversary-006/setup-source-chain.sh tmp/adversary-006/source-chain` (база `ca240cd14dc6cdb32ba5996d19d6d0797afa1fec`) команда `scope_select.sh ... --changed ...` вывела `MODE: full`.

## Новый обход 1 — изменённая шапка/коды ошибочно сужаются

**Вид:** дыра консервативного отображения и новая непокрытая граница `check_scope_select`.

**Нарушенный инвариант:** §2 требует сужать только когда не менялись роль, коды и шапка. Реализация сравнивает лишь `header_role`: `bb`; изменение объявленного кода возврата не замечает.

**Воспроизведение:**
```sh
base=$(bash tmp/adversary-006/setup-header-change.sh tmp/adversary-006/header-change)
bash scripts/scope_select.sh tmp/adversary-006/header-change --changed "$base"
```

`setup-header-change.sh` меняет в непрерывной шапке `b.sh` объявление `1 — violation` на `2 — changed contract`. Фактический вывод (код 0):
```text
SCOPED: не для приёмки
MODE: scoped
KEY: b
```

Это должно быть `MODE: full`, так как изменена часть контракта барьера.

**Барьер остаётся зелёным на сломанном предмете:**
```sh
bash scripts/check_scope_select.sh .
```
завершился 0, включая строки `ok (м)`, `ok (н)`, `ok (о)` и финал `ветви «all» зелены`.

**Минимальный фикс:** для модификации `scripts/*.sh` сравнивать полный первый непрерывный блок шапки из `BASE:path` и `HEAD:path` (или как минимум точный набор объявленных кодов вместе с ролью); любое различие даёт `full`. Добавить ветвь приёмки с изменением только кода в `Коды возврата:`.

## Новый обход 2 — source-граф недоаппроксимирован

**Вид:** дыра source-графа в новых ветвях м/н.

**Нарушенный инвариант:** §2 запрещает сужение, если изменённый барьер сорсится другим eligible-барьером, и при динамическом `source`. Реализация проверяет `has_dynamic_source` только у изменённого барьера, а `source_args` читает лишь однострочные инструкции, начинающиеся с `source`/`.`. Поэтому eligible `a`, реально сорсящий `b`, остаётся вне выбора при правке `b`.

**Воспроизведение A (цель через переменную с `dirname`):**
```sh
base=$(bash tmp/adversary-006/setup-source-variable.sh tmp/adversary-006/source-variable)
bash scripts/scope_select.sh tmp/adversary-006/source-variable --changed "$base"
```
`a.sh` содержит:
```sh
dir="$(dirname "$0")"
target="$dir/b.sh"
. "$target"
```
Фактический вывод (код 0):
```text
SCOPED: не для приёмки
MODE: scoped
KEY: b
```

**Воспроизведение B (многострочный source):**
```sh
base=$(bash tmp/adversary-006/setup-source-multiline.sh tmp/adversary-006/source-multiline)
bash scripts/scope_select.sh tmp/adversary-006/source-multiline --changed "$base"
```
`a.sh` содержит работающий Bash source:
```sh
. \
  "$(dirname "$0")/b.sh"
```
Фактический вывод снова (код 0):
```text
SCOPED: не для приёмки
MODE: scoped
KEY: b
```

В обоих случаях правильный ответ — `MODE: full`: выполнение a меняется от b, но a не будет прогнан.

**Барьер остаётся зелёным на сломанном предмете:** тот же `bash scripts/check_scope_select.sh .` завершился 0. Его м покрывает только однострочный прямой source, а н — dynamic source лишь в самом изменённом `b`.

**Минимальный фикс:** fail-closed разбирать source во всех eligible-барьерах, а не только в изменённом. Любая конструкция source, которую анализатор не способен доказать как однострочный статический путь, должна переводить changed-выбор в `full`; в частности continuation, переменная и source в составной shell-конструкции. Добавить отдельные пробы: `a` source `b` через переменную и через `\\`-continuation.

## Новый обход 3 — path traversal в case превращает scoped-прогон в зелёные ноль фикстур

**Вид:** пустой вход и неправильный case-фильтр в интеграции раннера.

**Нарушенный инвариант:** §3 требует неизвестный case отвергать кодом 1; case-фильтр обязан прогнать именно выбранный case. `scope_select` принимает произвольный хвост после `key/` как путь `fixtures/$key/$case.sh`, поэтому `../..` разрешается вне fixtures. `verify_antiplacebo` затем выбирает только непосредственные `case_*.sh`, не находит совпадения и не считает пустой отфильтрованный набор ошибкой.

**Воспроизведение:**
```sh
bash tmp/adversary-006/setup-case-traversal.sh tmp/adversary-006/case-traversal
cp scripts/scope_select.sh tmp/adversary-006/case-traversal/scripts/scope_select.sh
chmod +x tmp/adversary-006/case-traversal/scripts/scope_select.sh
bash scripts/scope_select.sh tmp/adversary-006/case-traversal --scope b/../../scripts/b
bash scripts/verify_antiplacebo.sh tmp/adversary-006/case-traversal --scope b/../../scripts/b
```

Первый вызов ошибочно принимает несуществующий case (код 0):
```text
SCOPED: не для приёмки
MODE: scoped
KEY: b/../../scripts/b
```

Второй вызов тоже возвращает 0 и объявляет успех без запуска обязательной фикстуры:
```text
SCOPED: барьеров 1 из выборки — не для приёмки

барьеров: 1 · фикстур: 0 · предъявлено красным повторным прогоном: 0
```

**Барьер остаётся зелёным на сломанном предмете:**
```sh
bash scripts/check_scoped_run.sh .
```
завершился 0, включая `ok (case)` и `ok (изол)`. Его case-ветвь проверяет лишь нормальное имя `case_b_1` и отсутствующее плоское имя, но не путь, ведущий за `fixtures/<key>/`, и не инвариант «после фильтра остался хотя бы один case».

**Минимальный фикс:** в `scope_select` принимать case только как имя непосредственного `case_*.sh` без `/`, `.` или `..`, после канонической проверки пути. В `verify_antiplacebo` после case-фильтра обязательно вызвать `bad` при нуле case для выбранного ключа, даже если селектор скомпрометирован. Добавить приёмочные сценарии `b/../../scripts/b` и существующего не-`case_*.sh`.

## Положительные контроли барьеров

После всех прямых проб выполнены точечные барьеры (не полный `verify_antiplacebo`):

```sh
bash scripts/check_scope_select.sh .
bash scripts/check_scoped_run.sh .
```

Оба завершились кодом 0. Второй выдал все ожидаемые `ok` для л, м1, м2, м3, н, case и изол. Это подтверждает, что выявленные обходы — ложнозелёные пробелы проверки, а не вечно-красный или неработающий барьер.
