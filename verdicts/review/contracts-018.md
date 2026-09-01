accept

# Контракт 018 — круг reviewer 1

Проверка выполнена в одноразовом клоне `/tmp/rev018-review-39681` от `f3f12bb`.
Основной checkout при прогонах не переключался. Ниже приведены наблюдённые команды,
их коды и результаты.

## 1. Зоны и атомарность

`git show --stat --oneline` и `git show -s --format='%h %an <%ae>%nparents: %P'`
дали по одному родителю у каждого коммита и следующий перечень затронутых файлов:

| sha | author | файл(ы) из `--stat` | результат зоны |
|---|---|---|---|
| e5ca82c | implementer | `scripts/check_staged.sh` | implementer |
| 754913b | adversary | `verdicts/adversary/contracts-018.md` | adversary |
| 8e4b392 | architect | `fixtures/check_staged/case_staged_ne_prochitan.sh` | architect |
| 84fae04 | implementer | `scripts/check_staged.sh` | implementer |
| eaafada | adversary | `verdicts/adversary/contracts-018.md` | adversary |
| 29116ba | architect | `fixtures/check_staged/case_staged_udalenie_vne_zony.sh` | architect |
| da5af96 | adversary | `verdicts/adversary/contracts-018.md` | adversary |
| 34ad335 | architect | `fixtures/check_staged/case_staged_tipy_vne_zony.sh`; `fixtures/check_staged/case_staged_udalenie_vne_zony.sh` | architect |
| b0708ea | architect | `fixtures/check_staged/case_staged_sentr_{A,D,M,R}.sh`; `fixtures/check_staged/case_staged_tipy_vne_zony.sh`; `NABLIUDENIA_ARCHITECT.md` | architect |
| 6203cd4 | Alex K (владелец) | `workshop` | вне предмета; не судится |
| c0764ab | adversary | `verdicts/adversary/contracts-018.md` | adversary |
| dcb7b97 | architect | `fixtures/check_staged/case_staged_{vtoroj_vne_zony,tozhdestvo_judged}.sh` | architect |
| 29c0ee3 | implementer | `scripts/check_staged.sh` | implementer |
| f3f12bb | adversary | `verdicts/adversary/contracts-018.md` | adversary |

Во всех зонированных строках файл находится в зоне из задания; `6203cd4` содержит
только обозначенную правку `workshop` владельца. Реализующий код (`e5ca82c`, `84fae04`,
`29c0ee3`) и новые фикстуры имеют разных авторов (`implementer` и `architect`).

## 2. Заморозка

```text
$ git diff --exit-code frozen/contracts/018/1..HEAD -- contracts/
frozen-contracts-rc=0
```

Вывод diff пуст, rc 0.

## 3. Срез → код

| Срез / инвариант | Наблюдённая реализация |
|---|---|
| §Предмет, срез 1: ветвь после «не судится» и до суда путей | `scripts/check_staged.sh:140-175`: `my_count == 0` печатает «не судится» и выходит до стража; затем `for-each-ref refs/heads/wip/` сравнивает последний компонент с `author`; `symbolic-ref --short HEAD`; собственная ветка определена как `wip/*` и последний компонент равен `author`; detached получает `detached HEAD`; не-своя живая wip даёт rc 1 с дословным `вне своей ветки wip/`. |
| Молчание без живой собственной wip | `has_own_wip=0`; блок `symbolic-ref` не исполняется. |
| Identity-каскад | `scripts/check_staged.sh:76-109`: сначала `git var GIT_AUTHOR_IDENT`, затем `$GIT_AUTHOR_NAME`; пустая identity получает именованный fail-closed. Из трёх реализующих коммитов только `e5ca82c`, `84fae04`, `29c0ee3` изменяют боевой файл; их `--stat` не содержит данного участка. |
| Усиление 84fae04 | `scripts/check_staged.sh:116-123`: rc `git diff --cached --name-only -z` сохраняется до проверки пустого массива; rc не 0 печатает `staged не прочитан` и возвращает 1. |
| Усиление 29c0ee3, свидетель реализации | `scripts/check_staged.sh:231-237`: `printf 'judged: %s\n' "$f"` расположен непосредственно перед `zones_match_path` в той же итерации. Это код в боевом файле, не фикстура. |
| Срез 2 | `contracts/018-vetka-na-agenta.md:61-75` относит `roles/orchestrator.md` к норме и каналу владельца; путей `roles/` в зонах этого предмета нет. |
| Срез 3 | `contracts/018-vetka-na-agenta.md:77-82` задаёт процедуру поверх готовых `land_agent`/`gc_agent_branches` 016 и прямо говорит, что нового кода не вводит. |

Следовательно, кодовая приёмка среза 1 не смешана со срезами 2 и 3.

## 4. Сырые scoped-прогоны

Все команды ниже выполнены в клоне из заголовка. Наблюдённый stdout:

| команда | rc | сырой итог |
|---|---:|---|
| `--scope check_staged/case_vetka_chuzhaja_wip` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_staged/case_vetka_detached` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_staged/case_vetka_pohozhaja_wip` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_staged/case_vetka_rabochij_na_main` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_staged/case_vetka_sudja_i_vladelec` | 0 | `барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1` |
| `--scope check_staged/case_staged_ne_prochitan` | 0 | `ok ... повторный прогон красный кодом 1 — «staged не прочитан»` |
| `--scope check_staged/case_staged_vtoroj_vne_zony` | 0 | `ok ... повторный прогон красный кодом 1 — «вне зоны: zz_offzone.txt»` |
| `--scope check_staged/case_staged_tozhdestvo_judged` | 0 | `ok ... повторный прогон красный кодом 1 — «вне зоны: zz_mid_off.txt»` |
| `--scope check_staged` | 0 | `барьеров: 1 · фикстур: 18 · предъявлено красным повторным прогоном: 18` |
| `--scope check_zones` | 0 | `барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13` |
| `--scope check_scope_select` | 0 | `барьеров: 1 · фикстур: 24 · предъявлено красным повторным прогоном: 24` |
| `--scope land_agent` | 0 | `барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9` |
| `--scope gc_agent_branches` | 0 | `барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2` |

Живое дерево клона:

```text
$ env GIT_AUTHOR_NAME=reviewer GIT_AUTHOR_EMAIL=reviewer@dev-harness.local bash scripts/check_staged.sh .
нечего судить: staged пуст
check_staged-live rc=0

$ env GIT_AUTHOR_NAME=reviewer GIT_AUTHOR_EMAIL=reviewer@dev-harness.local bash scripts/check_staged.sh . 2>&1 | sed -n '/^judged:/p' | wc -l
0
```

## 5. Реализованность предмета

`e5ca82c`, `84fae04` и `29c0ee3` содержат изменения именно
`scripts/check_staged.sh`: соответственно страж среза 1, fail-closed чтение и
со-локализованный `judged`-свидетель. Срез 2 является нормой владельца, а
срез 3 — процедурой над инструментами 016, как установлено в разделе 3.

## 6. Вердикт adversary и дерево

`verdicts/adversary/contracts-018.md` начинается строкой `accept`.
В нём имеются последовательные разделы `Круг 2`, `Круг 3`, `Круг 4`,
`Круг 5 (класс-замыкающий)`; круг 5 фиксирует `accept`, F-1 fail-closed,
F-2/F-3 покрытие A/M/D/R/T и F-4/K-подмножество. Его таблица слабых копий
указывает scoped rc 1 для F-1, AM, AMDR, AMT и K=1. Это согласуется с
наблюдённым деревом: fail-closed находится в строках 116-123, A/M/D/R/T
фикстуры — в `case_staged_tipy_vne_zony.sh` и `case_staged_sentr_{A,M,D,R}.sh`,
а K-вход и `judged`-тождество — в двух файлах коммита `dcb7b97`.
Расцеплённый свидетель в файле назван вне границы standard-A `67fb3b1`; в
проверенной реализации печать со-локализована с зонным вызовом.

## 7. Независимость фикстур от реализации

Шапка `case_staged_ne_prochitan.sh` задаёт PATH-первый git-двойник, который
делегирует остальные команды и возвращает 127 только для staged-чтения
красного репозитория; зелёный контроль использует тот же двойник и пустой
staged. `case_staged_tipy_vne_zony.sh` создаёт отдельные однотиповые A/M/D/T/R
вне-зонные входы; `case_staged_sentr_{A,M,D,R}.sh` являются отдельными
сентинелями. `case_staged_vtoroj_vne_zony.sh` задаёт K=1-вход: первый путь в
зоне, второй вне зоны. `case_staged_tozhdestvo_judged.sh` снимает staged-оракул
до вызова барьера и структурно сравнивает его с якорными строками `^judged: `;
его красный вход имеет A/D/M и вне-зонный D в середине.

Шапки двух последних файлов содержат один и тот же дословный контракт печати:
`judged: <путь>` непосредственно перед `zones_match_path` в той же итерации;
наблюдённый код в `scripts/check_staged.sh:234-235` выдаёт этот формат.
Scoped-вывод из раздела 4 предъявляет красный повторный прогон для каждого
нового барьера, а не только зелёное честное поведение.
