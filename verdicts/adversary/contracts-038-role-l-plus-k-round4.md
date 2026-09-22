# Adversary 038 — L+K implementation still accepts malformed or swapped role channels

**Verdict: FAIL.** Судимый HEAD: `cd3142731a6ff1e47af59be7359a2dc11ac851c7` (`cd31427`). Предмет суда — реализация решения арбитража `verdicts/arbitration/038-role-validacija-podhod.md` в `scripts/check_provodka.sh`: `role_component_ok` и arm `role)`. Сам метод Л+К не переоткрывается; ниже — два дефекта именно его исполнения. Предмет и `fixtures/check_provodka/` не менялись.

## Б1 — каноническая цель и файл нормы не связаны атомарно

Живое воспроизведение: [`contracts-038-role-toctou.repro.sh`](contracts-038-role-toctou.repro.sh).

```bash
bash verdicts/adversary/contracts-038-role-toctou.repro.sh
```

Вывод на судимом HEAD:

```text
honest-flat-alias: rc=0
swap-after-canonicalization: rc=0
REPRODUCED: K approved roles/good.md, then grep accepted policies/evil.md.
```

Сценарий начинает с легитимного `roles/alias.md -> good.md`; норма находится в
`roles/good.md`, и положительный контроль зелёный. Для обманной ветви `-f` и К
видят тот же легитимный плоский target. Сразу после настоящего
`/usr/bin/readlink -f` оболочка-планировщик атомарно меняет `alias.md` на
`../policies/evil.md`, а её stdout остаётся подлинным результатом readlink:
`$ROOT/roles/good.md`. Затем неизменённый `grep -Fxq -- "$norm" "$ROOT/$path"`
повторно раскрывает путь и зелёнит norm из `policies/evil.md`; в `good.md` этой
нормы нет.

Это не подмена ответа `readlink`: оболочка делает детерминированно наблюдаемым
TOCTOU-окно между предписанными арбитром К и г4. Канон удовлетворён только для
одного объекта, а норма проверена уже для другого. Исполнение должно связать
проверенный канонический объект и чтение нормы (либо повторно сверить канон после
чтения и отказать при расхождении); текущий порядок `[-f] → readlink -f → grep
по исходному пути` этого не делает.

## Б2 — role-строка принимается вне грамматики

Живое воспроизведение: [`contracts-038-role-parser-laxity.repro.sh`](contracts-038-role-parser-laxity.repro.sh).

```bash
bash verdicts/adversary/contracts-038-role-parser-laxity.repro.sh
```

Вывод на судимом HEAD:

```text
honest-minimal: rc=0
arbitrary-text-around-norm-accepted: rc=0
nested-quotes-accepted: rc=0
REPRODUCED: malformed role declarations passed as green.
```

Контракт требует ровно `role=roles/<роль>.md «<норма-строка>»`, а вложенная пара
`«…»` внутри нормы прямо запрещена (§Инварианты 1). В обманной ветви A строка
содержит произвольный `NOT-GRAMMAR` между целью и первой кавычкой и
`TRAILING-GARBAGE` после последней:

```text
- role=roles/valid.md NOT-GRAMMAR «Honest role norm.» TRAILING-GARBAGE
```

Код назначает `path="${rest%% *}"` и передаёт весь остаток в `extract_quoted`,
поэтому оба фрагмента молча выпадают, а строка зелёная. В ветви B запрещённая
вложенная пара также зелёная:

```text
- role=roles/valid.md «Outer «embedded» tail»
```

`extract_quoted` берёт outermost first/last pair, а `grep` находит полученную
склеенную строку в файле. Л+К тогда честно проверяют уже извлечённый путь, но не
саму обязательную грамматику поля. Реализация обязана до Л+К разобрать role-строку
целиком: единственный разделитель после цели, одна внешняя пара «…», без текста
вне неё и без внутренних `«`/`»`.

## Контроли и закрытые направления

Обязательный реальный контроль зелёный:

```bash
bash scripts/check_provodka.sh . contracts/038-provodka-done-gejt.md
# rc=0
```

Он проверяет три реальные `role=`-строки самого контракта, не только toy.
Оба repro также начинают с честного минимального role-канала `rc=0`.

Очная регрессия судимого дерева зелёная:

```text
EXPECT_RC=0 bash fixtures/_krasnye_038.sh
итог: 31 файлов, расхождений 0 (режим ожидания rc=0)

bash scripts/verify_antiplacebo.sh --scope check_provodka
барьеров: 1 · фикстур: 14 · предъявлено красным повторным прогоном: 14
```

Дополнительный живой контроль —
[`contracts-038-role-controls.repro.sh`](contracts-038-role-controls.repro.sh):
многохоповый symlink к плоскому role-файлу зелёный; такая же цепь в policy
красная; hardlink с плоским путём в `roles/` зелёный согласно предписанной
формуле пути; каталог `roles/directory.md` красный по `[-f]`; tab и full-width
slash в однокомпонентном имени зелёные; ASCII-пробел не становится молчаливым
зелёным; `readlink` с `exit 127` красный fail-closed.

**Счёт найденных обходов: 2.**
