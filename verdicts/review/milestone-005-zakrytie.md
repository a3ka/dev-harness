accept

# Ревью: финальное закрытие контракта 005 (прокси учёта)

Судимый HEAD: `03bb572ec714a2f0ed8653c3a54646cdd0a095f9`.

Решение о способе прогона: выполнена **полная** анти-плацебо пачка, а не
точечная имитация `ap_run`: новые фикстуры зависят от канала вызова проверяющего,
который создаёт именно `verify_antiplacebo.sh`. Это единственный вариант, который
одновременно подтверждает их положительный контроль и красный повтор без доверия
к самодельной обёртке. Прогон был один, последовательный, с `timeout 2400`.

## 1. Область, атомарность и норма

Сырой вывод проверки вершины и самого коммита:

```text
$ git rev-parse HEAD
03bb572ec714a2f0ed8653c3a54646cdd0a095f9

$ git show --stat --oneline --no-renames 03bb572
03bb572 005 к1/к2: рантайм-энфорсмент builtins-only по РЕШЕНИЮ арбитра f175567
 fixtures/check_metering/case_k1_codegen_import.sh | 35 +++++++++
 fixtures/check_metering/case_k2_computed_spawn.sh | 37 ++++++++++
 scripts/check_metering.sh                         | 88 +++++++++++++++--------
 3 files changed, 132 insertions(+), 28 deletions(-)
```

`03bb572` — один атомарный коммит предмета, его родитель — решение арбитра:

```text
03bb572ec714a2f0ed8653c3a54646cdd0a095f9 f1755675e37f2d2303f737085c45aa3f01d83a38 architect 005 к1/к2: рантайм-энфорсмент builtins-only по РЕШЕНИЮ арбитра f175567
f1755675e37f2d2303f737085c45aa3f01d83a38 4a45e613e65606f0cfde2e458b6fe3b47ce9fee7 arbiter arbitration: grep vs runtime enforcement for builtins-only (005 к1/к2)
```

Следовательно, область `03bb572` ровно мандатна: барьер и две новые
контрольные фикстуры; нормативный документ этим коммитом не менялся.

## 2. Арбитражный пункт 1: три точки запуска под обоими флагами

Сырой поиск в судимом барьере:

```text
177|readonly PROXY_NODE_FLAGS="--disallow-code-generation-from-strings --permission --allow-fs-read=/ --allow-fs-write=/ --allow-net"
192|      exec node $PROXY_NODE_FLAGS "$PROXY" --config "$cfg"
724|  timeout "$CLI_MAX" node $PROXY_NODE_FLAGS "$PROXY" --config "$cfg" --verify-appendonly >/dev/null 2>&1
738|  timeout "$CLI_MAX" node $PROXY_NODE_FLAGS "$PROXY" --config "$cfg" --rebuild-budget >/dev/null 2>&1
```

Отдельный поиск `allow-child-process` дал только объясняющий комментарий
`--permission без --allow-child-process`; флага разрешения в argv нет. Добавленный
`--allow-net` совместим с Node 26, а разрешения чтения/записи охватывают `/`.
Пункт выполнен.

## 3. Арбитражные пункты 2–3: живой runtime-enforcement и неослабленный grep

`_assert_enforcement` читает cmdline именно живого pid, а не строку источника:

```text
989|_assert_enforcement() {
995|  pid="$(proxy_up "$cfg" "$w/proxy.pid")" || { rm -rf "$w"; bad "$who: прокси не встал для сверки энфорсмента"; return 1; }
996|  cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null)"
999|    *--disallow-code-generation-from-strings*) ;;
1003|    *--permission*) ;;
1033|  _assert_enforcement к1 || return 1
1065|  _assert_enforcement к2 || return 1
```

Сравнение `eab8806..03bb572` не удаляет ни одной grep-проверки (к1/к2);
добавлены только `node:vm|runInThisContext` в к1 и вызовы
`_assert_enforcement`. Сырой фрагмент diff:

```diff
 grep -qE "getBuiltinModule" "$src" && bad_forms="${bad_forms}getBuiltinModule; "
+grep -qE "node:vm|runInThisContext" "$src" && bad_forms="${bad_forms}node:vm; "
@@
+  _assert_enforcement к1 || return 1
@@
+  _assert_enforcement к2 || return 1
```

Существующие контрактные красные контроли не менялись: вывод
`git diff --name-status eab8806 03bb572 -- fixtures/check_metering/case_k1_vendor_import.sh fixtures/check_metering/case_k2_vneshnii_protsess.sh fixtures/check_metering/case_l_i_ieee754.sh fixtures/check_metering/case_e_rebuild_konstanta.sh`
пуст. Их исходники по-прежнему вносят соответственно
`import type __vendorProbe from "lodash";` и
`execSync("curl", ["--version"])`, то есть дефекты именно к1/к2.
Пункты выполнены.

## 4. Арбитражный пункт 4: новые красные фикстуры не тавтологичны

`case_k1_codegen_import` в свежем временном дереве вводит именно обход
статического поиска:

```text
const __probeK1 = Function("return " + "im" + "port('node:os')")
void __probeK1
```

Он не меняет барьер и умирает от предметного `--disallow-code-generation-from-strings`
до старта прокси. `case_k2_computed_spawn` также вводит именно семантический
обход grep:

```text
const __probeK2 = process["getBuiltin" + "Module"]("node:" + "child_" + "process")
__probeK2["exec" + "FileSync"]("/bin/echo", ["probe"])
```

Он получает модуль вычисляемо, а краснеет от запрета процесса без
`--allow-child-process` при healthz. Обе фикстуры сперва запускают неизменённую
копию честного прокси, затем меняют только копию продукта; это не падение
фикстуры от самой себя.

Сырой результат полного независимого раннера предъявил зелёный контроль и
красный повтор коду 1 с предметной причиной:

```text
ok   check_metering/case_k1_codegen_import.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «погиб на старте»
ok   check_metering/case_k2_computed_spawn.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «healthz не ответил»
ok   check_metering/case_k1_vendor_import.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «к1: загрузка модулей вне статического node:-import»
ok   check_metering/case_k2_vneshnii_protsess.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «к2: child_process / внешние процессы в»
```

Следовательно, Н-37 выполнена: каждый новый барьер различает исправную и
сломанную реализации по своему предмету.

## 5. Li — рандомизированы и вход, и тариф

Вместо фиксированного `ti_i=1000000000` функция теперь принимает оба значения:

```text
1247|  _li_check_vector() {  # <номер> <tokensIn> <тариф-строка>
1248|    local n="$1" ti="$2" rate="$3" exp dbl usd_str line_i ri tmpv
1278|  pair1="$(node -e '...t=BigInt(100000000+Math.floor(Math.random()*1900000000));r=B+BigInt(Math.floor(Math.random()*100000)*2)...')"
1279|  pair2="$(node -e '...t=BigInt(100000000+Math.floor(Math.random()*1900000000));r=B+BigInt(Math.floor(Math.random()*100000)*2)...')"
1281|  _li_check_vector 1 "$ti1" "$rate1" || return 1
1282|  _li_check_vector 2 "$ti2" "$rate2" || return 1
```

Генераторы продолжают до условия `exp(BigInt) != dbl(double)`, поэтому вход
не только случаен, но и различает предмет. Полный раннер предъявил красный
контроль IEEE754:

```text
ok   check_metering/case_l_i_ieee754.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «int64 не сохранён»
```

## Собственные прогоны и независимый счёт

Честный барьер был отдельно запущен напрямую:

```text
ok   к1: только статические node:-импорты в /home/aka/Documents/dev-harness/scripts/proxy/metering_proxy.ts
ok   к2: child_process и внешних процессов в /home/aka/Documents/dev-harness/scripts/proxy/metering_proxy.ts нет
ok   л.i: два вектора >2^53 (ti=1304975862/9007199254936775, ti=656575963/9500000000015085) точны и отличимы от double
барьер зелёный: 15 ветвей пройдены
check_metering_rc=0
```

Полная пачка завершилась так:

```text
барьеров: 22 · фикстур: 172 · предъявлено красным повторным прогоном: 172
check_antiplacebo_rc=0
```

Её численное утверждение перепроверено другой мерой, не повтором команды
пачки:

```text
$ python3 -c "import glob; print(len(glob.glob('fixtures/**/case_*.sh', recursive=True)))"
172
```

## Итог

`accept`. На судимом HEAD все пять пунктов решения `f175567` выполнены;
контрактные grep-контроли сохранены, новые runtime-контроли предъявлены красным,
а честный барьер зелёный. Находок классов область/подгонка проверки/отсутствие
красноты/неатомарность/тихая правка нормы нет.
