FAIL
АРБИТР: claude-fable-5

# Контракт 006: adversary, круг 3 (cap)

Проверен HEAD `ac750a2`. Найдены два новых, исполняемо подтверждённых обхода одного предмета — консервативного source-графа селектора. Поэтому порог «доказуемо-статичного source» и способ его реализации должны быть решены арбитром.

## Новый обход 1: `source` после `;` не попадает в граф

**Вид.** Барьер `a` действительно исполняет барьер `b`, но инструкция source находится не в начале логической строки. `source_arg_lines` извлекает только строку, начинающуюся с `source` или `.`, поэтому зависимости `a → b` нет в графе.

**Нарушенный инвариант (§2).** Если изменённый barrier `b` source-ится другим eligible-barrier `a`, сужение запрещено: нужен `MODE: full`, чтобы не недобрать `a`.

**Команда (из корня репозитория).**

```bash
base="$(bash tmp/adversary-006/setup-inline-source-v3.sh tmp/adversary-006/inline-source-v3)"
bash tmp/adversary-006/inline-source-v3/scripts/a.sh; printf 'a_rc=%s\n' "$?"
bash scripts/scope_select.sh "$PWD/tmp/adversary-006/inline-source-v3" --changed "$base"; printf 'selector_rc=%s\n' "$?"
```

**Фактический вывод.**

```text
b sourced
a_rc=0
SCOPED: не для приёмки
MODE: scoped
KEY: b
selector_rc=0
```

`a.sh` содержит именно `:; . "$(dirname "$0")/b.sh"`; запуск доказывает, что был исполнен `b.sh`, а селектор всё же выбрал только `b`.

**Минимальный фикс.** Source-анализ обязан fail-closed распознавать `.`/`source` не только в начале строки. Не пытаясь парсить весь Bash, безопасный минимум — считать динамикой (и возвращать full) каждую логическую строку, содержащую разделитель/командную конструкцию и потенциальный `.` или `source`, пока она не доказана безопасным разбором. Добавить к `check_scope_select.sh` сценарий с `:; . "$(dirname "$0")/b.sh"`, правкой `b` и ожиданием `MODE: full`.

## Новый обход 2: source барьера через символьную ссылку

**Вид.** `a` source-ит `scripts/link.sh`, где `link.sh -> b.sh`. Basename source-аргумента литеральный, но он не равен ключу реального файла. `is_static_source` принимает `link.sh`; сравнение basename с ключом `b` не видит зависимость. Это прямо проверяет требуемый случай символьной ссылки.

**Нарушенный инвариант (§2).** Та же зависимость `a → b` должна сделать изменение `b` полным прогоном, независимо от имени пути, через который shell достиг `b`.

**Команда (из корня репозитория).**

```bash
base="$(bash tmp/adversary-006/setup-symlink-source-v3.sh tmp/adversary-006/symlink-source-v3)"
bash tmp/adversary-006/symlink-source-v3/scripts/a.sh; printf 'a_rc=%s\n' "$?"
bash scripts/scope_select.sh "$PWD/tmp/adversary-006/symlink-source-v3" --changed "$base"; printf 'selector_rc=%s\n' "$?"
```

**Фактический вывод.**

```text
b sourced through symlink
a_rc=0
SCOPED: не для приёмки
MODE: scoped
KEY: b
selector_rc=0
```

**Минимальный фикс.** При проверяемом статичном source канонизировать путь (`readlink -f`/эквивалент в пределах `scripts/`) и сравнивать реальный target с ключами; неразрешимая ссылка, ссылка вне `scripts/` или любая неоднозначность — `MODE: full`. Добавить fixture `link.sh -> b.sh` с `a` source `link.sh`, правкой `b` и ожиданием full.

## Барьеры зелёные на сломанном предмете

До и независимо от обеих репродукций исполнены реальные барьеры против текущего `scripts/scope_select.sh` и `scripts/verify_antiplacebo.sh`:

```bash
bash scripts/check_scope_select.sh .
bash scripts/check_scoped_run.sh .
```

Оба вернули `0`: первый напечатал все ветви `а б в г д е ж з и к л м н о п р т` зелёными, второй — `л м1 м2 м3 н case изол` зелёными. Следовательно, это false-green приёмки, а не шумная вечно-красная проба: непосредственно нарушенный предмет остался зелёным на обоих барьерах.

## Прежние обходы: закрыты

Точечный прогон `bash tmp/adversary-006/verify-closed-v3.sh` на текущем селекторе дал:

```text
sourced rc=0 ... MODE: full
dynamic rc=0 ... MODE: full
variable rc=0 ... MODE: full
multiline rc=0 ... MODE: full
header rc=0 ... MODE: full
passive rc=1 неизвестный ключ lib_x
case-traversal rc=1 неизвестный case b/../../scripts/a — ожидается case_*
```

Это подтверждает закрытие source-chain/sourced, dynamic, source-variable, source-multiline, header-change, non-barrier и case-traversal. Изоляция HOME отдельно проверена `bash scripts/check_scoped_run.sh . изол`: `0`, с выводом `HOME изолирован per-fixture`.

Все стенды и воспроизводители оставлены только в `tmp/adversary-006/`; предмет и барьеры не менялись.
