FAIL

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
