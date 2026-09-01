accept

# Контрольный эксперимент — контракт 018, срез 1

Проверен HEAD `e5ca82c` в одноразовом клоне `/tmp/adv018-3932596`; основной
чекаут не переключался. Контрпример найден: отказ `git diff --cached --name-only
-z` маскируется процессной подстановкой `mapfile` как пустое staged-множество.
Следовательно, зонированный author с живой `wip/<NNN>/<author>`, который
стаджит путь вне своей ветки, получает rc 0 вместо обязательного именованного
rc 1, если вызов `git diff` завершается ошибкой.

## Находка F-1 — ошибка чтения staged принимается за пустой вход

**Слабая реализация.** В копии `scripts/check_staged.sh` построен минимальный
страж с тем же правилом ветки и строкой:

```bash
mapfile -d '' staged < <(git -C "$ROOT" diff --cached --name-only -z 2>/dev/null)
```

Он прошёл все пять замороженных `case_vetka_*` (таблица ниже). В этой
конструкции, как и в `e5ca82c`, код завершения процесса внутри `< <(...)` не
становится кодом `mapfile`; пустой stdout неотличим от разрешённого пустого
staged-ввода.

**Вход.** Подставной репозиторий из `fixtures/check_staged/_repo.sh`:
`implementer` объявлен зонированным, жива `wip/018/implementer`, HEAD остаётся
на `main`, staged `scripts/b.sh`. Это красный вход И-1 (рабочий на main).
В начале `PATH` помещён `git`, который делегирует все команды `/usr/bin/git`,
кроме `git -C <repo> diff --cached --name-only -z`; для последней он печатает
`git: simulated unavailable diff` и завершает работу кодом 127.

**Команда и результат слабой реализации.**

```text
$ bash control_fake_git.sh
нечего судить: staged пуст
barrier_rc=0
```

Команда завершилась rc 0. Тот же результат воспроизведён с командой `git diff`,
завершающейся rc 1:

```text
$ bash control_git_failure.sh "$PWD/fakegit1"
нечего судить: staged пуст
barrier_rc=0
```

Команда завершилась rc 0. Следовательно, это не легальный пустой вход: staged
путь существует, но судья не прочитал его и выдал сообщение, предназначенное
только для нуля путей.

**Применимость к предмету.** Тот же эксперимент до подмены слабой реализации
воспроизведён на исходном `e5ca82c` с rc 127 и теми же двумя строками вывода.
Дефект находится в существующей строке чтения staged, а не в одном лишь
контрольном минимальном стражe.

**Отличие от закрытых классов.** Это не Р1 (main), Р2 (точная чужая wip), Р3
(detached), Р4 (подстрока компонента) и не ЗЗ (произвольный NNN): во всех этих
случаях `git diff` исправен и они уже предъявлены пятью fixture. Здесь
проверяемая ветвь не получает собственного содержательного ввода из-за ошибки
инструмента; результат «staged пуст» отвечает на другой вопрос. Это также не
закрытый класс подмены `python3`: его канарейка проверяет stdout и rc, тогда как
для `git diff` такой fail-closed контроля нет.

## Контрольные эксперименты

| Контроль | Вход и команда | rc | Наблюдаемые строки |
|---|---|---:|---|
| Позитивный: исходная реализация | Пять отдельных `bash scripts/verify_antiplacebo.sh . --scope check_staged/case_vetka_{rabochij_na_main,chuzhaja_wip,detached,pohozhaja_wip,sudja_i_vladelec}` | 0 каждый | Каждый: `ok ... зелёный контроль есть, повторный прогон красный кодом 1 — «вне своей ветки wip/»` |
| Слабая реализация | Те же пять отдельных scoped-команд | 0 каждый | Те же пять строк `ok ... «вне своей ветки wip/»` |
| Отказ выглядит пустым | `bash control_fake_git.sh` (поддельный `git diff` rc 127) | 0 | `нечего судить: staged пуст`; `barrier_rc=0` |
| Отказ выглядит пустым | `bash control_git_failure.sh "$PWD/fakegit1"` (поддельный `git diff` rc 1) | 0 | `нечего судить: staged пуст`; `barrier_rc=0` |
| Подменённый `python3`, exit 0 | `bash control_python_canary.sh "$PWD/fakepy0"` | 0 у harness; barrier 1 | `ОТКАЗ: судья не может исполнить проверку control-символов — канарейка не подтверждена...`; `barrier_rc=1` |
| Подменённый `python3`, exit 1 | `bash control_python_canary.sh "$PWD/fakepy1"` | 0 у harness; barrier 1 | Та же строка канарейки; `barrier_rc=1` |
| Пустой вход | `bash control_empty_staged.sh` (жива `wip/018/implementer`, staged отсутствует) | 0 | `нечего судить: staged пуст`; `barrier_rc=0` — это предусмотренное контрактом разрешение, не находка |
| Зашитый NNN | В клоне matcher `wip/*` заменён на `wip/018/*`; `bash scripts/verify_antiplacebo.sh . --scope check_staged/case_vetka_detached` | 1 | `FAIL ... нет положительного контроля` — ЗЗ корректно ловит этот закрытый класс |
| Нейтрализация | В клоне восстановлен `scripts/check_staged.sh` из `e5ca82c^`; `bash scripts/verify_antiplacebo.sh . --scope check_staged` | 1 | Пять строк `FAIL check_staged/case_vetka_...: барьер остался зелёным ...` |

## Scoped-регресс исходного `e5ca82c`

| Команда | rc | Результат |
|---|---:|---|
| `--scope check_staged` | 0 | 10/10 fixture, красное предъявлено повторным прогоном |
| `--scope check_zones` | 0 | 13/13 fixture, красное предъявлено повторным прогоном |
| `--scope land_agent` | 0 | 9/9 fixture, красное предъявлено повторным прогоном |
| `--scope gc_agent_branches` | 0 | 2/2 fixture, красное предъявлено повторным прогоном |
| `git diff --exit-code frozen/contracts/018/1..e5ca82c -- contracts/ fixtures/check_staged/` | 0 | вывода нет: замороженные контракт и fixture неизменны |

Требуемая правка — fail-closed различать успешный пустой `git diff` и ошибку его
выполнения до ветви `staged пуст`; эту правку выполняет автор предмета.


## Круг 2

**Итог: FAIL.** Правка F-1 закрыта: PATH-первый `git`-двойник, который
делегирует всё кроме `git -C <красный-репозиторий> diff --cached --name-only
-z`, при rc 127 и при rc 1 теперь даёт обязательный отказ до ветви пустого
staged. При успешном пустом staged через тот же PATH-двойник сохранён rc 0.

### Контроль F-1 на `84fae04`

Команда `bash /tmp/adv018k2-f1.sh` в одноразовом клоне
`/tmp/adv018k2-84fae04` построила профиль И-1: author `implementer`, жива
`wip/018/implementer`, HEAD `main`, в индексе `scripts/b.sh`. Дословный
результат:

```text
F-1 fake-git-diff rc=127: barrier_rc=1
ОТКАЗ: staged не прочитан (git diff --cached --name-only -z завершился кодом 127)
F-1 fake-git-diff rc=1: barrier_rc=1
ОТКАЗ: staged не прочитан (git diff --cached --name-only -z завершился кодом 1)
empty staged through same PATH-first fake git: barrier_rc=0
нечего судить: staged пуст
```

Это положительный контроль: сам PATH-двойник не объявляется нарушением, а
отказ чтения staged не маскируется успешным пустым входом.

### Находка F-2 — staged-удаление вне зоны не предъявлено красным

В одноразовом клоне `/tmp/adv018k2-delete-filter` построена слабая реализация:
единственная семантическая подмена чтения staged — к реальной команде добавлен
`--diff-filter=AM`:

```bash
git -C "$ROOT" diff --cached --name-only -z --diff-filter=AM \
  2>/dev/null > "$staged_tmp"
```

Она намеренно не читает D-записи, хотя предмет судит staged-пути без
исключения типа изменения. Полный прогон
`bash scripts/verify_antiplacebo.sh . --scope check_staged` на этой слабой
реализации завершился rc 0: 11/11 fixture предъявлены красным повторным
прогоном, включая `case_staged_ne_prochitan`.

Контрпример воспроизведён командой `bash /tmp/adv018k2-deletion.sh`. В
подставном репозитории author `implementer` не имеет живой wip-ветки; файл
`offzone.txt` вне зоны сначала закоммичен, затем удалён и удаление добавлено в
индекс. Честный барьер и слабая реализация на одном и том же входе дали:

```text
honest checker: barrier_rc=1
ОТКАЗ: вне зоны: offzone.txt
weak --diff-filter=AM checker: barrier_rc=0
нечего судить: staged пуст
```

Следовательно, усиленная пачка допускает реализацию, которая отвечает только
за добавления и модификации, но не делает предмет для staged-удалений. Это
новый класс относительно F-1 и Р1–Р4/ЗЗ/python3: здесь `git diff` успешно
прочитан, но из его ответа исключён судимый тип изменения. Нужна отдельная
красная фикстура с положительным контролем и staged D-путём вне зоны; после
неё `--diff-filter=AM` обязан перестать проходить 11/11.

### Испробованные формы, не ставшие дополнительной находкой

| Форма | Слабая подмена / вход | Результат пачки |
|---|---|---|
| Отказ, выглядящий пустым; инструмент в PATH | PATH-первый `git`, `diff --cached --name-only -z` возвращает 127 и отдельно 1 | F-1 закрыта: оба rc 1 с `staged не прочитан`; успешный пустой вход rc 0 |
| Пустой вход | Тот же PATH-двойник делегирует чтение легального репозитория с пустым индексом | rc 0 `нечего судить: staged пуст`, положительный контроль |
| Счёт только первого staged-пути | После `mapfile` оставлен только `staged[0]` при непустом массиве | rc 1 у пачки: `case_imja_control_simvol` ловит второй staged-путь; 10/11 |
| Зашитый NNN | Своя ветка признана только как `wip/018/*/<author>` | rc 1 у пачки: ЗЗ в `case_vetka_detached` теряет положительный контроль; 10/11 |
| Нейтрализация стража ветки | Перед проверкой принудительно `has_own_wip=0` | rc 1 у пачки: ровно пять `case_vetka_*` красных не предъявлены, шесть остальных проходят; 6/11 |

### Scoped-прогоны честного `84fae04`

| Команда | rc | Наблюдение |
|---|---:|---|
| `bash scripts/verify_antiplacebo.sh . --scope check_staged/case_staged_ne_prochitan` | 0 | 1/1, причина `staged не прочитан` |
| `bash scripts/verify_antiplacebo.sh . --scope check_staged` | 0 | 11/11 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope check_zones` | 0 | 13/13 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope land_agent` | 0 | 9/9 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches` | 0 | 2/2 fixture |
| `git diff --exit-code frozen/contracts/018/1..84fae04 -- contracts/` | 0 | вывода нет |

## Круг 3

**Итог: FAIL.** Мера F-2 на `29116ba` работает: слабое чтение только
`A`/`M` больше не проходит целевой case. Однако пачка из 12 fixture всё ещё
допускает иной фильтр типов изменения: он читает добавления, модификации,
удаления и rename, но исключает staged type-change (`T`). Тем самым
`check_staged` отвечает не на staged-множество целиком, хотя предмет требует
судить staged-пути без исключения типа изменения.

### Подтверждение закрытия F-2

В одноразовом клоне `/tmp/adv018k3-29116ba` на точном `29116ba` единственной
семантической подменой `scripts/check_staged.sh` было:

```bash
git -C "$ROOT" diff --cached --name-only -z --diff-filter=AM \
  2>/dev/null > "$staged_tmp"
```

Команда и дословный результат:

```text
$ bash scripts/verify_antiplacebo.sh . --scope check_staged/case_staged_udalenie_vne_zony
SCOPED: барьеров 1 из выборки — не для приёмки
  FAIL check_staged/case_staged_udalenie_vne_zony.sh: барьер остался зелёным на обманном дереве — красное не предъявлено

барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 0
```

Команда завершилась rc 1. Это требуемое закрытие: `D offzone.txt` не может
быть выдан за разрешённый пустой staged-ввод.

### Новая находка F-3 — type-change вне зоны исключён из staged-чтения

**Слабая реализация.** В той же одноразовой копии чтение staged заменено на:

```bash
git -C "$ROOT" diff --cached --name-only -z --diff-filter=AMDR \
  2>/dev/null > "$staged_tmp"
```

Она не повторяет F-2: `D` уже включён. Она исключает класс `T`, который
`git diff --cached --name-status` выдаёт при замене обычного файла символьной
ссылкой. Фильтрация успешна (не F-1), но ответ относится лишь к части
staged-множества.

**Наблюдаемый вход и позитивный контроль.** Подставной репозиторий из
`fixtures/check_staged/_repo.sh`: `implementer` зонирован только на `scripts/`;
`offzone.txt` сначала добавлен и закоммичен, затем заменён символьной ссылкой и
стаджирован. Фактический staged status и результаты честного барьера с
`29116ba` и слабой копии:

```text
$ bash tmp/type_change_repro.sh
cached status: T	offzone.txt
honest checker: barrier_rc=1
ОТКАЗ: вне зоны: offzone.txt
weak --diff-filter=AMDR checker: barrier_rc=0
нечего судить: staged пуст
```

Скрипт воспроизведения завершился rc 0, так как различие `1` у честного и `0`
у слабого барьера является его ожидаемым результатом. Честная минимальная
реализация тем самым является положительным контролем; слабая реализация не
делает предмет на том же осмысленном входе.

Полный scoped-прогон этой слабой реализации:

```text
$ bash scripts/verify_antiplacebo.sh . --scope check_staged
барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
```

Команда завершилась rc 0. Все двенадцать перечисленных runner-ом fixture
получили `ok`, включая F-1, F-2 и пять веточных case. Следовательно, это новый
контрпример, проходящий всю текущую пачку.

### Испробованные формы

| Форма | Реализация / вход | Результат |
|---|---|---|
| Исключение D из staged | `--diff-filter=AM`; staged-удаление `offzone.txt` вне зоны | F-2 закрыта: целевой scoped rc 1, «красное не предъявлено» |
| Правильный ответ на неполное множество | `--diff-filter=AMDR`; staged `T offzone.txt` вне зоны | F-3: полный scoped `check_staged` rc 0 (12/12), честный барьер rc 1, слабый rc 0 |
| Нейтрализация стража ветки | В отдельной копии `if [ "$has_own_wip" -eq 1 ]` заменён на `if false` | `case_vetka_rabochij_na_main` rc 1: «барьер остался зелёным … красное не предъявлено» |
| Отказ `git diff`, инструмент мимо PATH | Замороженный F-1 case в штатном scoped-прогоне | Закрытый, не новый класс: `case_staged_ne_prochitan` предъявлен красным причиной `staged не прочитан` |
| Пустой staged и подмена/отсутствие `python3` | Зелёные и красные контроли штатной пачки | Закрытые, не новые классы: все соответствующие fixture `ok` |

### Приёмка-судьи v2 на исходном `29116ba`

| Команда | rc | Наблюдение |
|---|---:|---|
| `bash scripts/verify_antiplacebo.sh . --scope check_staged/case_staged_udalenie_vne_zony` | 0 | 1/1, красное предъявлено `вне зоны: offzone.txt` |
| `bash scripts/verify_antiplacebo.sh . --scope check_staged` | 0 | 12/12 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope check_zones` | 0 | 13/13 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope land_agent` | 0 | 9/9 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches` | 0 | 2/2 fixture |
| `git diff --exit-code frozen/contracts/018/1..29116ba -- contracts/` | 0 | вывода нет |

Для закрытия F-3 нужна отдельная fixture с положительным контролем и
staged `T`-путём вне зоны; после неё фильтр `--diff-filter=AMDR` обязан давать
rc 1 «красное не предъявлено».


## Круг 4

**Итог: FAIL.** Серия F-2/F-3 закрыта: слабые чтения staged с `--diff-filter=AM`, `--diff-filter=AMDR` и `--diff-filter=AMT` все дают scoped rc 1 на `6203cd4`. Однако финальная пачка из 16 fixture допускает новую слабую реализацию вне форм `--diff-filter`: она проверяет зону только у первого пути staged-множества (грамматику имени проверяет у всех). Полный `--scope check_staged` у этой реализации зелёный 16/16, но вход «первый путь в зоне, второй вне зоны» получает rc 0.

### Три меры закрытия F-2/F-3

Каждая подмена сделана единственной заменой чтения staged в отдельном одноразовом клоне точного `6203cd4`; запускалась команда `bash scripts/verify_antiplacebo.sh . --scope check_staged`.

| Слабое чтение | rc | Дословные строки отказа |
|---|---:|---|
| `--diff-filter=AM` | 1 | `FAIL check_staged/case_staged_sentr_D.sh: барьер остался зелёным на обманном дереве — красное не предъявлено`; `FAIL check_staged/case_staged_sentr_R.sh: барьер остался зелёным на обманном дереве — красное не предъявлено`; `FAIL check_staged/case_staged_tipy_vne_zony.sh: повторный прогон покраснел, но не назвал причину «вне зоны: offzone_T.link»` |
| `--diff-filter=AMDR` | 1 | `FAIL check_staged/case_staged_tipy_vne_zony.sh: повторный прогон покраснел, но не назвал причину «вне зоны: offzone_T.link»` |
| `--diff-filter=AMT` | 1 | `FAIL check_staged/case_staged_sentr_D.sh: барьер остался зелёным на обманном дереве — красное не предъявлено`; `FAIL check_staged/case_staged_sentr_R.sh: барьер остался зелёным на обманном дереве — красное не предъявлено` |

Следовательно, все три меры дали обязательный scoped rc 1: `AM` предъявил 13/16 красных, `AMDR` — 15/16, `AMT` — 14/16.

### Новая находка — зона судится только у первого staged-пути

**Слабая реализация.** В отдельной копии `scripts/check_staged.sh` после успешных проверки identity, чтения полного staged-множества, проверки стража ветки и канарейки `python3` сохранён исходный цикл грамматики всех путей. Семантическая порча в нём одна: после проверки имени второго и следующих путей выполняется `continue` до `zones_match_path`; зонная проверка работает только на первом пути списка. Это не форма `--diff-filter` и не повтор F-1/F-2/F-3: `git diff` читает полный успешный вывод без фильтра, но слабая реализация применяет зонный вопрос к одному элементу вместо всего staged-множества.

**Полный scoped-прогон.** На этой копии команда `bash scripts/verify_antiplacebo.sh . --scope check_staged` завершилась rc 0: `барьеров: 1 · фикстур: 16 · предъявлено красным повторным прогоном: 16`. Позитивные контроли также прошли; в частности, грамматика control-символа всё ещё применяется ко всем путям, поэтому двухпутевой `case_imja_control_simvol` остаётся красным на втором пути.

**Наблюдающий вход.** Через `fixtures/check_staged/_repo.sh` создан репозиторий с замороженной зоной `implementer: scripts/`. В индекс добавлены два пути: `scripts/a_safe.sh` (первый в выводе `git diff --cached --name-only -z`, в зоне) и `zz_offzone.txt` (второй, вне зоны). На одном и том же входе дословный результат:

```text
WEAK:
scripts/
ok: staged в зоне автора implementer (2 путь/путей)
HONEST:
scripts/
ОТКАЗ: вне зоны: zz_offzone.txt
rc weak=0 honest=1
```

Тем самым слабая копия проходит все 16 существующих fixture, но не соблюдает инвариант «staged-множество целиком». Нужна fixture с положительным контролем и минимум двумя staged-путями, где лексически первый принадлежит зоне, а следующий находится вне зоны; она должна требовать `вне зоны:` второго пути.

### Scoped-прогоны честного `6203cd4`

| Команда | rc | Наблюдение |
|---|---:|---|
| `bash scripts/verify_antiplacebo.sh . --scope check_staged` | 0 | 16/16 fixture, красное предъявлено повторным прогоном |
| `bash scripts/verify_antiplacebo.sh . --scope check_zones` | 0 | 13/13 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope check_scope_select` | 0 | 24/24 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope land_agent` | 0 | 9/9 fixture |
| `bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches` | 0 | 2/2 fixture |
| `git diff --exit-code frozen/contracts/018/1..6203cd4 -- contracts/` | 0 | вывода нет |


## Круг 5 (класс-замыкающий)

**Итог: accept.** На `29c0ee3` четыре прежних костюма больше не проходят scoped-пачку: F-1 закрыт fail-closed чтением staged, фильтры типов предъявлены сентинелями и тождеством в совокупности, K-подобные сужения — тождеством `judged == staged`. Внутригранных нет.

Все мутации сделаны только в одноразовых клонах `/tmp/adv018k5-*`; изменялся только их `scripts/check_staged.sh`. Фикстуры и контракт не менялись. Позитивный контроль честного `29c0ee3`: `--scope check_staged` завершился rc 0, 18/18.

### Повтор костюмов

| Костюм слабой копии | rc scoped | Поймавшие фикстуры | Распределение |
|---|---:|---|---|
| F-1: чтение staged через process substitution без наблюдения rc; PATH-первый `git diff` | 1 | `case_staged_ne_prochitan` | Scoped-фикстура с rc 127 дала `красное не предъявлено`. Отдельный тот же профиль с двойником rc 127 и rc 1: честный `29c0ee3` дал barrier rc 1 в обоих случаях, слабая копия — rc 0 в обоих. |
| F-2: `--diff-filter=AM` | 1 | `case_staged_sentr_D`, `case_staged_sentr_R`, `case_staged_tipy_vne_zony`, `case_staged_tozhdestvo_judged` | D/R/T-сентинели; identity-фикстура обнаружила недобор D. |
| F-3: `--diff-filter=AMDR` | 1 | `case_staged_tipy_vne_zony` | T-сентинель. |
| F-3: `--diff-filter=AMT` | 1 | `case_staged_sentr_D`, `case_staged_sentr_R`, `case_staged_tozhdestvo_judged` | D/R-сентинели; identity-фикстура обнаружила недобор D. |
| F-4: судить только первый staged-путь (печать остаётся со-локализованной с судом) | 1 | `case_staged_tozhdestvo_judged`, `case_staged_vtoroj_vne_zony` (также `case_imja_control_simvol`) | K=1 ловится тождеством и вторым вне-зонным путём. |

Тем самым у фильтров есть сентинельное покрытие всех типов A/D/M/R/T и identity-покрытие тех фильтров, которые отбрасывают D; для AMDR единственный отброшенный T представлен T-сентинелем, поскольку identity-вход состоит из A/D/M. K-подобное сужение ловится тождеством.

### Граница standard-A и внутригранные попытки

Расцеплённый свидетель (печатать всё staged, но судить подмножество) не предъявлялся как внутригранный: по standard-A `67fb3b1` он вне границы.

Проверены внутригранные формы, в каждой печать `judged:` остаётся ровно у фактически судимых путей:

| Форма | Результат scoped `check_staged` | Наблюдение |
|---|---:|---|
| K=1: остановка judging-loop после первого пути | 1 | `case_staged_tozhdestvo_judged` и `case_staged_vtoroj_vne_zony` красные. |
| K=2: остановка judging-loop после двух путей | 1 | `case_staged_tozhdestvo_judged` красная: нет положительного контроля после нетождества. |
| Типовое подмножество `AMDR` | 1 | T-сентинель красный. |
| Типовое подмножество `AMT` | 1 | D/R-сентинели и тождество красные. |

Ни одна из внутригранных форм не прошла 18/18; внутригранных нет.

### Scoped-прогоны честного `29c0ee3`

| Команда | rc | Наблюдение |
|---|---:|---|
| `bash scripts/verify_antiplacebo.sh . --scope check_staged` | 0 | 18/18 |
| `bash scripts/verify_antiplacebo.sh . --scope check_zones` | 0 | 13/13 |
| `bash scripts/verify_antiplacebo.sh . --scope check_scope_select` | 0 | 24/24 |
| `bash scripts/verify_antiplacebo.sh . --scope land_agent` | 0 | 9/9 |
| `bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches` | 0 | 2/2 |
| `git diff --exit-code frozen/contracts/018/1..29c0ee3 -- contracts/` | 0 | вывода нет |
