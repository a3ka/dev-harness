accept
OBJECT=5bf44a09d3a631d9a6ba145dcf0a95fe6a48bea8
КЛАСС=кодовый; риск=обычный (инструмент проверки; frozen 189/1) — дельта трогает только проверку числа аргументов обёртки и раздел README «Валидаторы»; права/роли, авторизация, деньги, ПД, юридически значимые действия не затронуты; адверсарий не вызывался по классу
СУД: repo=dev-harness; предмет=189; фаза=реализация (tip `wip/189/implementer`); роль=reviewer; вызов=2 (scoped-исправительный, по дельте Б-1); модель-план=anthropic/claude-opus-5-5; сессия=Rev189v2 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; автор=implementer (`implementer <implementer@dev-harness.local>`); контракт=frozen/contracts/189/1; фикстуры прогона=`wip/189/architect` 8cf52447ad8fc40f47bf511e0fc3d2b57897bf09 (наложены без коммита); предыдущий=verdicts/review/contracts-189-impl-v1.md

# Вердикт reviewer — 189 «стандартные валидаторы и канон», реализация, вызов 2 (scoped)

Итог: **accept**. Блок Б-1 вызова 1 закрыт, это подтверждено исполнением. Новых блоков нет. С-1 закрыт попутно. Новый совет С-7 касается кода, который был до дельты. Советы С-2…С-6 и наблюдения Н-1…Н-3 из v1 сознательно не закрывались. Ни один из них не нарушает обязательство на достижимом состоянии, поэтому блоком они не являются.

Все проверки прогнаны в одноразовом клоне `/tmp/dev-harness-verify/Rev189v2/repo`. Для них сделаны worktree:
- `impl` = OBJECT;
- `old` = 660d4c77b, кандидат вызова 1;
- `mainwt` = origin/main 88e64e64.

В каждый worktree наложено `git checkout 8cf52447 -- fixtures/workshop_project/standartnye_validatory_189/` без коммита: изменены 4 файла (model/validate_std.sh, probe.py, stabs.tsv, новый стаб).

Живая установка не делалась. HOME песочный, `/tmp/dev-harness-verify/Rev189v2/home`. Настоящие бинари брались только из `HOME=/home/harness`, движок json — через `PYTHONUSERBASE` станции.

## Кандидат

- `git rev-parse origin/wip/189/implementer` → `5bf44a09d3a631d9a6ba145dcf0a95fe6a48bea8`, совпадает с OBJECT. Родитель — `660d4c77b5b5…`, кандидат v1. Автор — `implementer <implementer@dev-harness.local>`.
- `git rev-parse origin/wip/189/architect` → `8cf52447ad8fc40f47bf511e0fc3d2b57897bf09`.
- `git diff --stat frozen/contracts/189/1 5bf44a09d -- fixtures/workshop_project/standartnye_validatory_189 contracts` → пусто. Реализатор фикстуры и контракт не трогал.

## 1. Область правки дельты

`git diff --stat 660d4c77b 5bf44a09d`:
```
 ops/server/README.md    |  6 ++++++
 scripts/validate_std.sh | 27 ++++++++++++++++++++-------
 2 files changed, 26 insertions(+), 7 deletions(-)
```
- `git diff --quiet 660d4c77b 5bf44a09d -- scripts/check_canon_fragment.py scripts/validate_std_json.py ops/server/install.sh ops/server/validators.tsv fixtures contracts roles registry .github AGENTS.md` → rc 0. Значит, `install.sh` и канон-CLI не менялись, норма не тронута.
- README: hunk `@@ -131,6 +131,12 @@` лежит внутри раздела `## Валидаторы (контракт 189 …)`. По `grep -n '^## '` раздел начинается на строке 74, следующий раздел — на 148. Изменение — только 6 добавленных строк, удалений нет.
- Атомарность: один коммит со ссылкой на предмет и Б-1. С-1 (переписанный комментарий) относится к тому же файлу и тому же предмету.

## 2. Б-1 закрыт исполнением

Прогон `args.sh` (одноразовый) на `impl` и `old`, `HOME=/home/harness`, движок станции. Пути `fixtures/…/matrix/` сокращены до `M/`.

| вызов | OBJECT | v1 (660d4c77) |
|---|---|---|
| `bash M/chestnyj_skript.sh M/sintaksis.sh` (пример Б-1) | **rc 2** `NOT_IMPLEMENTED: режим bash (…): ожидается аргументов ровно 1, получено 2` | rc 0 |
| `json M/shema.json M/dokument.json M/dokument_narushenie.json` (пример Б-1) | **rc 2** `NOT_IMPLEMENTED: режим json … ровно 2, получено 3` | rc 0 |
| `workflow` (0 аргументов) | rc 2 `NOT_IMPLEMENTED … получено 0` | rc 2 |
| `workflow M/mut_bez_runs_on.yml` (1) | rc 1 (находка actionlint) | rc 1 |
| `workflow M/mut_bez_runs_on.yml M/honest.yml` (2) | **rc 2** `… получено 2` | rc 1 |
| `workflow honest mut broken` (3) | **rc 2** `… получено 3` | rc 1 |
| `bash` (0) | rc 2 `… получено 0` | rc 2 |
| `bash M/chestnyj_skript.sh` (1) | rc 0 | rc 0 |
| `bash chestnyj shellcheck_nahodka` (2) | **rc 2** | rc 0 |
| `bash chestnyj chestnyj sintaksis` (3) | **rc 2** `… получено 3` | rc 0 |
| `json` (0) / `json shema` (1) | rc 2 / rc 2 | rc 2 / rc 2 |
| `json shema dokument` (2) | rc 0 | rc 0 |
| `json shema dokument dokument` (3) / (4) | **rc 2** / **rc 2** | rc 0 / rc 0 |
| `workflow ''` / `bash ''` | rc 2 `… имя файла пусто` | rc 2 |
| `json '' dokument` / `json shema ''` / `json '' ''` | rc 2 `… имя файла пусто` (все три) | rc 2 |
| `bash M/chestnyj_skript.sh ''` | **rc 2** `… получено 2` | rc 0 |
| `json shema dokument ''` | **rc 2** `… получено 3` | rc 0 |
| без аргументов / `''` / `netrezhim x` / `WORKFLOW …` / `--help` | rc 2 `NOT_IMPLEMENTED: режим неизвестен: …` (все) | rc 2 |
| glob `bash M/*.sh` (3 файла) | **rc 2** `… получено 3` | rc 0 |

Штатные вызовы дают те же rc, что в v1:
- `bash chestnyj_skript.sh` → 0;
- `bash shellcheck_nahodka.sh` → 1;
- `bash sintaksis.sh` → 2 `SYNTAX: bash -n rc=2`;
- `workflow honest.yml` → 1 (настоящий actionlint, граница Н-3 из v1);
- `workflow mut_bez_runs_on.yml` → 1;
- `json shema dokument` → 0;
- `json shema dokument_narushenie` → 1 `JSON_INVALID:/mode 'netrezhim' is not one of […]`;
- `json shema dok_ne_razbor` → 2 `JSON_UNPARSEABLE`.

Без движка (`PYTHONUSERBASE` не задан) `json shema dokument` → rc 2 `ENGINE_MISSING: jsonschema` в обоих деревьях. Это именованный отказ, как в v1.

**Класс шире примера.** `grep -n '\$#\|\${1\|\$@\|\$\*' scripts/validate_std.sh` находит такие места:
- `:82-83` — `mode="${1:-}"; shift`;
- `:87`, `:95`, `:109` — `proverka_argumentov <режим> "$#" <1|1|2>` первой строкой каждой ветки;
- `:88`, `:96`, `:110` — проверки на пустоту;
- `:91`, `:98`, `:105`, `:112` — использование `$1`/`$2` только после обеих проверок;
- `:27`, `:34`, `:43`, `:53` — аргументы собственных функций, а не CLI.

Ветка `*)` отказывает целиком. Мест, где позиционный аргумент CLI используется без точной сверки числа, нет. Оба Python-входа и раньше проверяли число точно: `validate_std_json.py:67` `len(sys.argv) != 3`, `check_canon_fragment.py:91` `len(sys.argv) != 4`. Исполнением: `check_canon_fragment.py … canon.yml extra` → rc 2 `NOT_IMPLEMENTED`.

**С-1 закрыт.** Пиннованный shellcheck 0.11.0 (`--version` → `version: 0.11.0`):
- `scripts/validate_std.sh` на OBJECT → rc 0;
- на v1 → rc 1 `SC1073`/`SC1072` в `:9`;
- `validate_std.sh bash scripts/validate_std.sh` → rc 0, на v1 было rc 1;
- `bash -n scripts/validate_std.sh` → rc 0.

## 3. Регресс дельты — батарея, своя мера

Батарея прогонялась через одноразовый `bat.sh`: `bash …/red_standartnye_validatory_189.sh <режим>`, затем лог подсчитан отдельной командой `grep -c '^189 [^ ]* ok'` и `sort -u` по ID клеток.

| дерево | режим | rc | ИТОГ | своя мера |
|---|---|---|---|---|
| OBJECT, песочный HOME | `--repo .` | 0 | `KLETKI=58 ZELENYE=58 KRASNYE=0` | ok=58, distinct=58 |
| OBJECT, `HOME=/home/harness` | `--repo .` | 0 | `KLETKI=58 ZELENYE=58 KRASNYE=0` | distinct=58; z01: `actionlint: sha установленного == пин`, `shellcheck: sha установленного == пин` |
| OBJECT | `--model` | 0 | `KLETKI=58 ZELENYE=58 KRASNYE=0` | ok=58 |
| OBJECT | `--stabs` | 0 | `OBMANOK=15 POIMANY=15 ZHIVYH=0` | 15 строк данных в `stabs.tsv`, 15 файлов в `stabs/`, 15 строк `POIMAN`; `stab_lishnie_argumenty.sh POIMAN` (на v36: `KRASNO rc=0 []`) |
| origin/main 88e64e64 | `--repo .` | 1 | `KLETKI=58 ZELENYE=0 KRASNYE=58` | ok=0, distinct=58 |
| v1 660d4c77 | `--repo .` | 1 | `KLETKI=58 ZELENYE=55 KRASNYE=3` | красные ровно v35, v36, v37 (`KRASNO rc=0 []`) |

Через `reslop t -- bash …red_….sh --repo .` на OBJECT → `exit: 0`.

Строки новых клеток на OBJECT:
```
189 v35-workflow-lishnij-argument ok rc=2 ['NOT_IMPLEMENTED: режим workflow (validate_std.sh workflow <файл>): ожидается аргументов ровно 1, получено 2']
189 v36-bash-lishnij-argument ok rc=2 ['NOT_IMPLEMENTED: режим bash (validate_std.sh bash <файл>): ожидается аргументов ровно 1, получено 2']
189 v37-json-lishnij-argument ok rc=2 ['NOT_IMPLEMENTED: режим json (validate_std.sh json <схема> <документ>): ожидается аргументов ровно 2, получено 3']
189 v38-workflow-bez-fajla ok rc=2 [… получено 0]
189 v39-bash-bez-fajla ok rc=2 [… получено 0]
189 v40-json-malo-argumentov ok rc=2 [… получено 1]
```

**Мутации реализации.** Одноразовый `mut.py`: копия дерева OBJECT, одна правка `scripts/validate_std.sh`, прогон `--repo .`.

| мутант | правка | итог батареи | красные клетки |
|---|---|---|---|
| M-wf-old | в `workflow)` вернуть `[ -n "${1:-}" ] \|\| otkaz2 …` | rc 1, 57/58 | v35 (`rc=0 []`) |
| M-bash-old | то же в `bash)` | rc 1, 57/58 | v36 (`rc=0 []`) |
| M-json-old | в `json)` вернуть `[ "$#" -lt 2 ] \|\| …` | rc 1, 57/58 | v37 (`rc=0 []`) |
| M-ge | `-eq` → `-ge` в `proverka_argumentov` | rc 1, 55/58 | v35, v36, v37 |
| M-noname | rc 2, но маркер `ARGC:` вместо `NOT_IMPLEMENTED` | rc 1, 52/58 | v35–v40 |
| M-text | иная формулировка с тем же именем: `NOT_IMPLEMENTED: wrong argc for $1 -- want $3 got $2` | rc 0, 58/58 | — |

Каждый режим краснеет на своей клетке. Клетка судит rc и имя отказа, но не текст сообщения (M-text зелёный, M-noname красный).

**Канон-CLI** (`check_canon_fragment.py` дельтой не менялся). Прогон `canon.sh` по 11 входам матрицы и отказным путям дал те же rc и пути, что в v1:
```
honest rc=0 | ekvivalent rc=0
mut_bez_runs_on rc=1 CANON_DIFF: runs-on | mut_scalar_runs_on rc=1 CANON_DIFF: runs-on
mut_nesushchestvujushhij_sha rc=1 CANON_DIFF: steps[0].uses | mut_shag_posle_upload rc=1 CANON_DIFF: steps[4]
mut_if_vsegda_lozh rc=1 CANON_DIFF: steps[2].if | mut_sha256_fixture rc=1 CANON_DIFF: container.image
mut_teg_vmesto_sha rc=1 CANON_DIFF: steps[0].uses | mut_opetchatka_vyrazhenija rc=1 CANON_DIFF: steps[2].env.BASE
mut_working_directory rc=1 CANON_DIFF: steps[2].working-directory | broken rc=2 CANON_UNPARSEABLE
job=nope rc=2 CANON_JOB_MISSING | kanon_spisok rc=2 CANON_FRAGMENT | /nonexist rc=2 CANON_ABSENT | python3 -S rc=2 CANON_ENV: нет pyyaml
```

## 4. Неподгонка

- Код реализации не читает `model/`, `probe.py` или клетки. `grep 'fixtures|model/|matrix|standartnye|probe|v3[5-9]|v40|lishn|chestnyj|sintaksis|dokument|shema|honest' scripts/validate_std.sh` находит совпадения только в шапке-комментарии «НЕ БАРЬЕР … guard=…» (`:2-6`). Ветвей под имена входов нет.
- Форма отличается от честной модели architect. Модель использует инлайн `if [ "$#" -ne 1 ] || [ -z … ]` с прежним текстом. Реализация — функция `proverka_argumentov` с режимом и числами в сообщении. Коммит architect по времени раньше (20:38), но копии нет.
- Текст сообщения не подогнан под клетку: мутант M-text с другой формулировкой остаётся 58/58 (§3).
- Фикстуры реализатор не трогал: дерево OBJECT побайтно равно тегу freeze, а фикстуры architect наложены мной только для прогона.

## 5. Норма

В дельте нет `roles/`, `contracts/`, `AGENTS.md`, `registry/` (§1, `git diff --quiet` → rc 0).

## Находки

### Блок

Нет. **Б-1 вызова 1 — закрыт** (§2, §3).

### Советы (не блок)

- [ ] **С-7 (implementer; код был до дельты, правкой не порождён).** Имя файла, похожее на опцию, уходит в валидатор как опция.
  - На OBJECT: `HOME=/home/harness validate_std.sh workflow -version` → **rc 0**, при этом файл не проверен: actionlint печатает версию. На v1 то же, rc 0.
  - `validate_std.sh bash --version` → rc 2, потому что `bash -n` отказывает раньше.
  - Тот же класс «skip→зелёный» (ЗАЩИЩАЕТ-2), но достижим только при явном аргументе с ведущим `-`. Glob по путям `dir/*.yml` его не порождает. Дельта Б-1 этот код не меняла, а по п. 4 задания новых блоков вне дельты не заводится.
  - Простая форма: отказ `NOT_IMPLEMENTED` на `$1` с ведущим `-` или передача `./$1` для относительных путей. Нужна клетка у architect.
- С-2…С-6 из v1 остаются открытыми советами (сознательный кап). Дельта их не затронула: `validate_std_json.py`, `install.sh` и `validators.tsv` не менялись, а дубль пинов в README (С-3) новыми строками не расширен.

### Наблюдения

- **Н-4 (к сведению).** Сообщение отказа реализации богаче требования клетки: в нём есть режим и числа «ожидается/получено». README (`ops/server/README.md:134-138`) обещает «имя режима и ожидаемое число», и это исполнено: в выводе есть `режим bash`, `ровно 1`. Клетки v35–v40 это не закрепляют. Если строка README станет нормой, нужна клетка на текст.
- Н-1…Н-3 из v1 в силе без изменений.

## Паразитная сложность (контракт 050) — артефакты дельты

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `proverka_argumentov()` (`scripts/validate_std.sh:33-36`) | инв. 3: «неизвестные аргументы → rc 2 `NOT_IMPLEMENTED:` с использованием»; ЗАЩИЩАЕТ-2 | нет; явное: rc 2 и маркер в stderr | 1 | 4 позиционных параметра против одной проверки — функция мелкая. Взамен один шаблон сообщения на три режима с режимом и числами, их обещает README | клетки v35–v40 | ESSENTIAL по свойству. Инлайн-форма модели проходит те же клетки, но без чисел в сообщении. Сложность почти та же (функция + 3 вызова против 3 инлайн-проверок), поэтому находкой не считаю |
| проверка пустоты в каждой ветке (`:88`, `:96`, `:110`) | инв. 3, «пустое имя → rc 2» | нет | 1 | три строки | v1-вызовы с `''` | ESSENTIAL (была и до дельты, стала отдельной строкой) |
| README `:134-138` | инв. 5 «раздел инвентаря»: интерфейс обёртки | — | 1 (+скрипт при смене правила) | — | оператор | ESSENTIAL |

## Сверки

- ПРОВОДКА: guard `fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh` — барьер именно этого предмета. На main 0/58, на v1 55/58 (красны ровно v35–v37), на OBJECT 58/58. Новый стаб пойман на v36. CI-шаг — зона orchestrator, дельта его не трогает.
- СВЕРКА-СТАНДАРТОВ: неприменимо. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`, как и в v1.
- sourceCanon / режим проекта: не объявлены, это собственный репо харнесса.

## Итог

**accept** OBJECT `5bf44a09d3a631d9a6ba145dcf0a95fe6a48bea8`. Б-1 закрыт: точная сверка `$#` во всех трёх режимах, а класс «позиционный аргумент без сверки числа» пуст по grep и исполнению. Регресс дельты:
- батарея `--repo` 58/58, `--model` 58/58, `--stabs` 15/15;
- на main красная 58/58, на v1 красны v35–v37;
- мутанты краснят клетку своего режима;
- канон-матрица — как в v1.

Область соблюдена: 2 файла, README только в разделе «Валидаторы», `install.sh` не менялся. Неподгонка подтверждена мутантом с иной формулировкой. Accept применим только к этому OBJECT. Фикстуры architect `8cf52447` — отдельный кандидат, и их приземление вместе с реализацией — забота оркестратора.
