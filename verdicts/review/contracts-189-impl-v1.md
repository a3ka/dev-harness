FAIL
OBJECT=660d4c77b5b537c000ad9bbaf5e2729ebb44e6a4
КЛАСС=кодовый; риск=обычный — подтверждён: дифф затрагивает только валидаторы workflow/bash/json, канон-инструмент и установку с пином; права/роли БД, авторизация, деньги, ПД/согласия, юридически значимые действия не затронуты; адверсарий не вызывался по классу
СУД: repo=dev-harness; предмет=189; фаза=реализация (tip `wip/189/implementer`); роль=reviewer; вызов=1/1; модель-план=anthropic/claude-opus-5-5; сессия=Rev189v1 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; автор=implementer (`implementer <implementer@dev-harness.local>`); контракт=frozen/contracts/189/1 (commit b8d02f49); предыдущий=verdicts/critic/contracts-189-v1.md

# Вердикт reviewer — 189 «Л4: стандартные валидаторы и канон», реализация, вызов 1/1

Итог: **FAIL**, одна блокирующая находка Б-1. Дальше — шесть советов (С-1…С-6) и три наблюдения (Н-1…Н-3).
Все проверки ниже прогнаны в одноразовом клоне `/tmp/dev-harness-verify/Rev189v1/repo`. Для двух деревьев сделаны отдельные worktree: `impl` (= OBJECT) и `mainwt` (= origin/main `88e64e64`). Живая установка шла только в песочницах `HOME=/tmp/dev-harness-verify/Rev189v1/home{,2,3}`.

## Кандидат и подлинность

- `git fetch origin wip/189/implementer` → `FETCH_HEAD=660d4c77b5b537c000ad9bbaf5e2729ebb44e6a4`. Это совпадает с OBJECT.
- Коммит один: `660d4c77 implementer 189: стандартные валидаторы и канон (контракт 189, инварианты 1–5)`, автор `implementer <implementer@dev-harness.local>`. Он лежит поверх `d5d782f3`, и это merge-base с origin/main.
- После merge-base main ушёл вперёд на 11 коммитов (HANDOFF, критики 195/991, owner). Ни один из них не трогает файлы предмета. `git merge-tree --write-tree origin/main 660d4c77` → `dc3a886a` без конфликтов, к main добавляются ровно 6 файлов зоны.
- Замороженный предмет не изменён: `git diff --stat frozen/contracts/189/1 660d4c77 -- contracts/189-… fixtures/workshop_project/standartnye_validatory_189` → 0 строк. В семье на теге 45 файлов.

## 1. Область правки

`git diff --stat d5d782f3 660d4c77`:
```
 ops/server/README.md            |  68 +++++
 ops/server/install.sh           | 157 ++++++++++++-
 ops/server/validators.tsv       |   8 +
 scripts/check_canon_fragment.py | 110 +++++
 scripts/validate_std.sh         | 105 +++++
 scripts/validate_std_json.py    |  98 +++++
 6 files changed, 545 insertions(+), 1 deletion(-)
```
- Все 6 путей входят в `ЗОНА implementer`. По путям `fixtures roles contracts registry scripts/check_zones.sh .github` diff пуст (0 файлов).
- `ops/server/README.md`: только добавлен раздел «## Валидаторы (контракт 189 …)», 68 строк, удалений 0. Соответствует ПЕРЕСЕЧЕНИЮ.
- `ops/server/install.sh`: добавлены шапка режима, переменные `VALIDATORS_*` и функции `validator_archive_url`, `validator_pin_fields`, `validator_pin_nfields`, `install_validators`, `check_validators`. Ветка `validators)` в `case` новая. В `verify` добавлены две строки: `check_validators || rc=1`. Единственное удаление — строка `usage`, в неё дописан `|validators`.
  - **Сверка пинов в `verify`.** ПЕРЕСЕЧЕНИЕ-строки 074/081/090/093/186 говорят «только новый режим validators». Инвариант 5 того же замороженного контракта прямо требует: «`install.sh verify` дополнительно сверяет пины ↔ установленное». Значит, добавка в `verify` — исполнение инварианта, а не выход из зоны. Противоречие формулировок — см. Н-1.
  - Проверено, что добавка аддитивна: прежние 10 сверок, строка `сверка: 10/10` и их rc не тронуты. На станции без установки валидаторов добавка печатает «не установлены» и rc не меняет (сырой вывод в §7).
  - Регресс барьеров install.sh: rc на OBJECT совпадает с чистым main (§7).

## 2. Сырой вывод — приёмка прогнана мной

Батарея на OBJECT, песочный HOME без установки валидаторов: `bash fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh --repo .` → rc 0.
```
189 k01-chestnaja ok rc=0 []
189 k03-bez-runs-on ok rc=1 ["CANON_DIFF: runs-on: нет у субъекта, канон: [...]"]
189 v05-podmena-binarija ok rc=2 ['VALIDATOR_PIN: actionlint фактический 48c770f9… ≠ пин 93dcf544…']
189 v31-pin-nechitaem ok rc=2 ['VALIDATOR_PINS: файл пинов не читается: …']
189 v34-json-stroki-pina-net ok rc=2 ['ENGINE_MISSING: jsonschema (нет строки пина: …)']
189 z01-edinnyj-istochnik ok LIVE_PREDPOSYLKA: станция без установки валидаторов (…/zones/dev/.local/state/dev-harness/validators) — живая сверка отложена, не пропуск зелёным
ИТОГ 189: rc=0 KLETKI=52 ZELENYE=52 KRASNYE=0
```
Подсчёт своей мерой, по `tee`-логу через `grep`: `ok=52 krasno=0 distinct=52`.

z01 по-живому: `PYTHONUSERBASE=<user-site jsonschema> HOME=/home/harness bash …red_….sh --repo .` → rc 0.
```
189 z01-edinnyj-istochnik ok actionlint: sha установленного == пин
189 z01-edinnyj-istochnik ok shellcheck: sha установленного == пин
ИТОГ 189: rc=0 KLETKI=52 ZELENYE=52 KRASNYE=0
```
`sha256sum /home/harness/.local/state/dev-harness/validators/*/*/*` → `c872d6db…4cd4 …/actionlint/1.7.12/actionlint`, `4da528dd…a55b …/shellcheck/0.11.0/shellcheck`. Это совпадает с `ops/server/validators.tsv`. LIVE_PREDPOSYLKA появляется только при песочном HOME. Это именованная отсрочка, а не зелёный пропуск: на станции с установкой z01 сверяет реально.

Остальные режимы:
- `--model` → rc 0, `ИТОГ 189: rc=0 KLETKI=52 ZELENYE=52 KRASNYE=0`.
- `--stabs` → rc 0, `ИТОГ 189: rc=0 OBMANOK=14 POIMANY=14 ZHIVYH=0`. В `stabs.tsv` 14 строк данных, в `stabs/` 14 файлов.

Статика:
- `bash -n scripts/validate_std.sh` → 0; `bash -n ops/server/install.sh` → 0.
- `python3 -m py_compile scripts/validate_std_json.py scripts/check_canon_fragment.py` → 0.
- shellcheck 0.11.0 (пиннованный бинарь станции):
  - на `scripts/validate_std.sh` → rc 1, `SC1073/SC1072` (см. С-1);
  - на `ops/server/install.sh` четыре note `SC2015×2 SC2016×2`. Тот же набор на main (`-f gcc | sort | uniq -c`), то есть новых находок дифф не добавил.

Канон-CLI, матрица Д§3.2. Каждая строка — отдельная команда `python3 scripts/check_canon_fragment.py matrix/<вход>.yml runtime-r0 matrix/canon.yml`:
```
honest rc=0 | ekvivalent rc=0
mut_bez_runs_on rc=1 CANON_DIFF: runs-on | mut_scalar_runs_on rc=1 CANON_DIFF: runs-on
mut_nesushchestvujushhij_sha rc=1 CANON_DIFF: steps[0].uses | mut_shag_posle_upload rc=1 CANON_DIFF: steps[4]
mut_if_vsegda_lozh rc=1 CANON_DIFF: steps[2].if | mut_sha256_fixture rc=1 CANON_DIFF: container.image
mut_teg_vmesto_sha rc=1 CANON_DIFF: steps[0].uses | mut_opetchatka_vyrazhenija rc=1 CANON_DIFF: steps[2].env.BASE
mut_working_directory rc=1 CANON_DIFF: steps[2].working-directory | broken rc=2 CANON_UNPARSEABLE: workflow
job=nope rc=2 CANON_JOB_MISSING | kanon_spisok rc=2 CANON_FRAGMENT | /nonexist rc=2 CANON_ABSENT | python3 -S rc=2 CANON_ENV: нет pyyaml
```
Девять путей мутаций дословно совпадают с перечнем приёмочного критерия.

Обёртка на настоящих бинарях и при их отсутствии. В PATH нет ни `actionlint`, ни `shellcheck` (`command -v | wc -l` → 0).
- Отказ при отсутствии, песочный HOME без установки:
  - `validate_std.sh workflow honest.yml` → rc 2 `VALIDATOR_MISSING: actionlint`;
  - `bash chestnyj_skript.sh` → rc 2 `VALIDATOR_MISSING: shellcheck`;
  - `bash sintaksis.sh` → rc 2 `SYNTAX: bash -n rc=2: …`.

  Отсутствие инструмента даёт именованный отказ, а не rc 0.
- Настоящие бинари, `HOME=/home/harness`:
  - `bash chestnyj_skript.sh` → 0;
  - `bash shellcheck_nahodka.sh` → 1;
  - `workflow mut_bez_runs_on.yml` → 1;
  - `workflow honest.yml` → 1 (`label "complior-back" is unknown`) — это граница НЕ ЗАЩИЩАЕТ, см. Н-3.
- json, движок станции:
  - `shema.json dokument.json` → 0;
  - `dokument_narushenie.json` → 1 `JSON_INVALID:/mode …`;
  - `dok_ne_razbor.json` → 2 `JSON_UNPARSEABLE`;
  - пин `jsonschema 4.25.0` через `VALIDATE_STD_PINS` → 2 `ENGINE_VERSION: jsonschema 4.26.0 ≠ пин 4.25.0`;
  - `netrezhim x` → 2 `NOT_IMPLEMENTED`;
  - `json shema.json` без документа → 2 `NOT_IMPLEMENTED`.

Установка (инвариант 5), песочницы:
- `HOME=…/home bash ops/server/install.sh validators` → rc 0, `установлен: actionlint 1.7.12 → …`, `установлен: shellcheck 0.11.0 → …`. Повторный запуск → rc 0, вывод тот же: установка идемпотентна. Бинари `755`, sha совпадают с пинами.
- Подменённый архив: actionlint из официального архива, байт по смещению 1000 изменён, архив пересобран; shellcheck честный. `HOME=…/home2 OPS_SERVER_VALIDATORS_ARCHIVES=<bad> … validators` → rc 1:
  ```
  ОТКАЗ: VALIDATOR_PIN: actionlint: фактический f4e5616b… ≠ пин c872d6db…
  ОТКАЗ: валидаторы не установлены (расхождение с пином)
  ```
  После этого `ls …/home2/.local/state/dev-harness/validators` → `No such file or directory`. Каталог не создан, и честный shellcheck тоже не поставлен: сверка идёт до установки и по принципу «всё или ничего».
- Честные архивы офлайн (`OPS_SERVER_VALIDATORS_ARCHIVES`) → rc 0.
- Порча установленного shellcheck: байт 0x5a по смещению 500, sha стал `0189985e…`.
  - `install.sh verify` → rc 1 со строкой `ОТКАЗ: расхождение …/shellcheck/0.11.0/shellcheck (sha256 0189985e… ≠ пин 4da528dd…)`.
  - Обёртка на этом доме → rc 2 `VALIDATOR_PIN: shellcheck фактический 0189985e… ≠ пин 4da528dd…`.

Происхождение пинов — своя мера: я сам скачал официальные архивы по URL из `validator_archive_url`.
- Архивы: `sha256sum` → `8aca8db96f1b…a3d8 actionlint_1.7.12_linux_amd64.tar.gz` (совпадает с усечённым пином А§3.3 `8aca8db9…a3d8`) и `b7af85e4…e6f6 shellcheck-v0.11.0.linux.x86_64.tar.gz`.
- Распакованные бинари: `c872d6db…4cd4` и `4da528dd…a55b`, то есть пины в `validators.tsv` совпадают с реальными бинарями.

## 3. Проверки не подогнаны под код

- Фикстуры, семья 189 и контракт на OBJECT побайтно равны тегу `frozen/contracts/189/1`. Реализатор их не трогал.
- В коде реализации поиск по `fixtures|model/|matrix|standartnye|runtime-r0|complior|batareja`, по литералам пинов и по версиям нашёл совпадения только в шапках-комментариях «НЕ БАРЬЕР … guard=…». Других совпадений нет: под входы фикстур нет особых ветвей, пины не зашиты вне `validators.tsv`. В `install.sh` зашиты только URL-схемы релизов.
- Скрипты не копируют `model/scripts/`: diff с моделью — 75/86/135 строк при длине файлов 105/98/110.

## 4. Красное предъявлено — своей мерой

На чистом main: `bash …/red_standartnye_validatory_189.sh --repo .` в `mainwt` → rc 1, `ИТОГ 189: rc=1 KLETKI=52 ZELENYE=0 KRASNYE=52`. Мой подсчёт: `ok=0 krasno=52 distinct=52`. Каждая клетка красна именем отсутствующего субъекта: `can't open file …check_canon_fragment.py`, `scripts/validate_std.sh: No such file`, `SUBJECT_ABSENT: ops/server/validators.tsv`.

Мутации реализации я делал сам (одноразовый `mut.sh`). Каждая мутация — копия дерева OBJECT, одна точечная правка и прогон `--repo .`:

| мутант | правка | итог | красные клетки |
|---|---|---|---|
| M1 без сверки пина | `[ "$fakt" = "$pin" ] \|\| otkaz2 …` → `true` | rc 1, 48/52 | v05 v19 v21 v27 (rc 0) |
| M2 runs-on не сверяется | `continue` на ключе `runs-on` в `first_difference` | rc 1, 50/52 | k03 k04 (rc 0) |
| M3 канон подстрокой | `first_difference` → подстрока текста канона в тексте workflow | rc 1, 41/52 | k01 k02 (ложный отказ), k03–k11 (нет пути) |
| M4 движок без версии | `if fakt != pin` → `if False` | rc 1, 50/52 | v16 v29 |
| M5 bash без `bash -n` | `bash -n` снят | rc 1, 51/52 | v09 (rc 0) |
| M6 пропуск инструмента | `… \|\| otkaz2 VALIDATOR_MISSING` → `\|\| exit 0` | rc 1, 49/52 | v06 v11 v22 |
| M7 пин только для шва | дом/PATH возвращают бинарь без сверки sha | rc 1, 49/52 | v19 v21 v27 (rc 0) |

Каждый барьер краснеет на своей клетке.

## 5. Атомарность

Один коммит implementer со ссылкой на предмет и инварианты 1–5. Чужие задачи не примешаны.

## 6. Норма не тронута молча

В диффе нет `roles/`, `contracts/`, `AGENTS.md`, `registry/`. Нормативные документы не правились.

## 7. Регресс затронутых барьеров (scoped)

Полный `check_zones.sh` не запускался.

| барьер | OBJECT | чистый main |
|---|---|---|
| `bash fixtures/_krasnye_074.sh` | rc 0 `итог 074: красных клеток=0 стабы=7/7` | — |
| `bash fixtures/_krasnye_080.sh` | rc 1 `стабы=8/9 дифф=9/9 честные=31/31` (`клетка стаб-s1: stab_rc=0 clean_rc=0`) | rc 1, та же строка |
| `bash fixtures/_krasnye_090.sh` | rc 1 `КЛЕТКА-ОТКАЗ(090): герметичность нарушена: …` | rc 1, та же клетка |
| `red_architecture_186.sh --repo .` | rc 0 | — |

Красные 080 и 090 уже есть на main: это среда станции, предмет их не вносит.

`install.sh verify`, тот же HOME, main против OBJECT. Строки отказа одинаковые (`/usr/local/sbin/orch-peak`, `~/bin/orch-loop (нет файла)`, `orch-architecture.timer (нет файла)` — расхождения станции, они не от 189), rc 1 в обоих деревьях. OBJECT добавляет одну строку:
- `валидаторы: не установлены (…) — сверка пинов не выполнялась` — без установки, rc не меняется;
- `валидаторы: пины совпали с установленным (…)` — с установкой.

## Находки

### Блок

- [ ] **Б-1. Лишние аргументы обёртки молча отбрасываются → ложная зелень по непроверенному файлу.**
  - Обязательство: инвариант 3 контракта 189 — «Неизвестный режим/аргументы → rc 2 `NOT_IMPLEMENTED:` с использованием»; ЗАЩИЩАЕТ-2 — «от молчаливого пропуска проверки … никогда skip-к-зелёному».
  - Фрагмент: `scripts/validate_std.sh`:
    - режимы `workflow` и `bash` проверяют только `[ -n "${1:-}" ]` и дальше работают с `"$1"`;
    - режим `json` проверяет `[ "$#" -lt 2 ]` и передаёт дальше только `"$1" "$2"`.

    Аргументы сверх этих молча теряются. Сам `validate_std_json.py` при `len(sys.argv) != 3` отказывает правильно, но обёртка лишний аргумент до него не доносит.
  - Наблюдение, исполнением на OBJECT:
    - `HOME=/home/harness bash scripts/validate_std.sh bash matrix/chestnyj_skript.sh matrix/sintaksis.sh` → **rc 0**, хотя `bash -n matrix/sintaksis.sh` → rc 2;
    - `bash scripts/validate_std.sh json shema.json dokument.json dokument_narushenie.json` → **rc 0**.

    Вызов по glob вида `validate_std.sh bash scripts/*.sh` проверит один первый файл и отчитается зелёным.
  - Простая форма, которая проходит те же строки приёмки: `[ "$#" -eq 1 ] && [ -n "$1" ]` для `workflow`/`bash` и `[ "$#" -ne 2 ] || …` для `json`, иначе `NOT_IMPLEMENTED`. Проверено на копии дерева: `--repo .` → `ИТОГ 189: rc=0 KLETKI=52 ZELENYE=52 KRASNYE=0`, а тот же вызов с лишним файлом → rc 2 `NOT_IMPLEMENTED: validate_std.sh bash <файл>`.
  - Батарея этот вход не закрывает: у честной модели `model/scripts/validate_std.sh` тот же дефект, с пинами мира у неё тоже rc 0. Это не снимает обязательство инварианта 3 с реализации. Architect'у (совет к семье): добавить клетку «лишний аргумент → rc 2 `NOT_IMPLEMENTED`» и стаб без этой проверки.
  - Кому: implementer (`scripts/validate_std.sh`).

### Советы (не блок)

- [ ] **С-1. Обёртку нельзя проанализировать её же shellcheck.** Комментарий `scripts/validate_std.sh:9` начинается с `# shellcheck, json — …`, и shellcheck 0.11.0 читает его как директиву: `SC1073 Couldn't parse this shellcheck directive` и `SC1072`, после чего файл не анализируется. В итоге `validate_std.sh bash scripts/validate_std.sh` → rc 1. С перефразированным комментарием (`ShellCheck, json`) rc 0, других находок нет. Обязательства контракта на чистоту скриптов нет, поэтому это совет. Кому: implementer.
- [ ] **С-2. Неверная схема json.** `validate_std_json.py` не вызывает `Draft202012Validator.check_schema`.
  - `{"type": 5}` → traceback, rc 1 без `JSON_INVALID:`: по rc это неотличимо от нарушения документа.
  - `{"additionalProperties":"no"}` → rc 0.

  Контракт выводит качество схемы за границу (НЕ ЗАЩИЩАЕТ-2), и грамматики для невалидной схемы на freeze не было, поэтому это не FAIL. Более простая форма: `check_schema` → именованный rc 2. Кому: implementer/architect.
- [ ] **С-3. README повторяет sha256-пины из `validators.tsv`.** Таблица в разделе «Валидаторы» — вторая копия единого источника. При следующей смене пина вместе меняются два файла, и проверки, что они совпадают, нет. Для инвентаря достаточно инструментов и версий со ссылкой на `validators.tsv`. Кому: implementer.
- [ ] **С-4. Права каталогов установки.** `install_validators` создаёт каталоги через `mkdir -p` с umask процесса. На станции и в моей песочнице `umask 0000`, поэтому `…/validators/<инструмент>/<версия>` получили `777`, а бинари `755`. Обёртка сверяет sha перед каждым запуском, а захват каталога — граница НЕ ЗАЩИЩАЕТ-3, так что это не блок. Явное `mkdir -m 755` убрало бы окно подмены между сверкой и `exec`. Кому: implementer.
- [ ] **С-5. Нет интерпретатора json.** При отсутствующем интерпретаторе `VALIDATE_STD_PYTHON=/nonexistent/python validate_std.sh json …` → rc 127 без имени. Отказ fail-closed, но без именованного маркера. Кому: implementer.
- [ ] **С-6. `validator_pin_fields`.** Три подпроцесса `cut` и повторный `read` там, где хватает одного `IFS=$'\t' read -r a b c <<<"$line"`. Мелкая ACCIDENTAL-сложность, см. §050.

### Наблюдения (не дефект реализации)

- **Н-1 (architect, редакция контракта).** ПЕРЕСЕЧЕНИЕ-строки `ops/server/install.sh` говорят «только новый режим `validators`», а инвариант 5 требует, чтобы `verify` дополнительно сверял пины. Реализация следует инварианту и меняет существующие сверки только аддитивно (§1, §7). Формулировку ПЕРЕСЕЧЕНИЯ стоит выровнять в следующей редакции.
- **Н-2.** `ops/server/user/orch-loop` при `ORCH_SELF_UPDATE=1` трактует rc≠0 `install.sh verify` как дрейф и советует владельцу `sudo bash … install.sh root`. Для дрейфа валидаторов это неверное средство: нужен `install.sh validators`. Файл вне зоны 189, поведение задано инвариантом 5. Это повод для заметки оркестратору, а не находка.
- **Н-3.** Настоящий `actionlint` 1.7.12 даёт rc 1 на `matrix/honest.yml` (`label "complior-back" is unknown`), двойник батареи — rc 0. Это заявленная граница НЕ ЗАЩИЩАЕТ-1/-4 (полнота actionlint, поведение вне измеренного контракта rc). Обёртка пробрасывает rc буквально, как и требует инвариант 1. Это не дефект.

## Паразитная сложность (контракт 050)

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `scripts/validate_std.sh` | инв. 1–2 | явное: env-швы `VALIDATE_STD_*`, rc и маркеры в stderr | 1 (+tsv при смене пина) | 3 режима и 4 env против резолва, пин-сверки и проброса rc — глубокий | строки приёмки, v01–v31 | ESSENTIAL |
| `scripts/validate_std_json.py` | инв. 2–3 | явное: env `VALIDATE_STD_PINS`, маркеры | 1 | 2 аргумента против пин-файла, версии и валидации | v12–v16, v23–v25, v28–v34 | ESSENTIAL |
| `scripts/check_canon_fragment.py` | инв. 4 | нет | 1 | 3 аргумента против разбора и обхода с путём | k01–k17 | ESSENTIAL |
| `ops/server/validators.tsv` | инв. 2, 5 | данные | 1 (README повторяет → 2, С-3) | — | обёртка, движок, установщик, z01 | ESSENTIAL; дубль в README ACCIDENTAL (совет С-3) |
| `install.sh validators` + `install_validators`/`check_validators` | инв. 5 | явное: env `OPS_SERVER_VALIDATORS_DEST`/`_ARCHIVES`, вывод «установлен:»/«ОТКАЗ:» | 1 | 1 режим против сверки до установки и атомарной записи | строка приёмки «Правило (установка)» | ESSENTIAL |
| `OPS_SERVER_VALIDATORS_ARCHIVES` | инв. 5, приёмка «артефакт с sha ≠ пину» без сети | явное | 1 | шов | моя проверка подмены (§2) | ESSENTIAL |
| `validator_pin_fields` | формат строки | нет | 1 | лишние подпроцессы | install_validators | ACCIDENTAL, совет С-6 (простая форма названа, блок не требуется) |
| README §«Валидаторы» | инв. 5 «раздел инвентаря» | — | 1 (+tsv) | — | строка приёмки | ESSENTIAL (кроме дубля пинов, С-3) |

## Сверки

- ПРОВОДКА: `guard=fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh` существует. Это барьер именно этого предмета: на main красный 52/52, на OBJECT зелёный, мутанты M1–M7 краснеют. ПРОВОДКА-ЭНФОРСМЕНТ обоснован: новой поведенческой нормы нет. CI-шаг `--stabs` — зона orchestrator после freeze, в этот дифф не входит.
- СВЕРКА-СТАНДАРТОВ: неприменимо. `AGENTS.md` харнесса не объявляет документы архитектуры и стандарта кода: `grep ARCHITECTURE.md|CODING-STANDARDS AGENTS.md` → совпадений нет.
- sourceCanon / режим проекта: не объявлены, это собственный репо харнесса.

## Итог

**FAIL** по Б-1: инвариант 3 и ЗАЩИЩАЕТ-2. Лишний аргумент обёртки молча отбрасывается, и вызов с несколькими файлами даёт rc 0 по непроверенному файлу. Простая форма (точная проверка `$#`) сохраняет все 52 клетки зелёными.

Остальное подтверждено исполнением:
- область правки;
- батарея: red на main, green на OBJECT, `--model`, `--stabs` 14/14;
- канон-матрица 11 входов с точными путями;
- пин-дисциплина и честный отказ при отсутствии инструментов;
- установка: подмена → rc 1 без установки, идемпотентность, verify;
- происхождение пинов из официальных архивов;
- регресс барьеров install.sh, равный main.

Повторный суд нужен по дельте Б-1 (scoped: `scripts/validate_std.sh`, батарея `--repo .`, вход с лишним аргументом).
