accept

# Reviewer 070: круг 1 — реализация шага GitHub-токена (Б-2, read-only ODELIX_GITHUB_TOKEN)

Предмет: `frozen/contracts/070/1` (tag-object `474d1add149d67bd692557f63f3aef8523f45919` → `602bc2c`),
`contracts/070-github-chtenie-ro-token-v-sessiju.md`. Судимый HEAD: `00ab79c` (= origin/main).
Пачка реализации: `5372e97` + `a5411d1` + `81a0855` (implementer), `5f8a251` (architect, журнал А-313),
land-merge'и `63231eb` / `822c939` / `7df178c` / `dcd6f57`.
Клон суда: `/tmp/dev-harness-verify/rev070` (SSH-клон origin). Своя мера — одноразовые копии
`git archive <ref>` в `_repro/` этого клона: `mut.sh` (мутанты workshop → раннер 070) и `edges.sh`
(функция `load_github_token` на граничных входах в toy-доме), `n2.sh` (порядок баннера при отказе P8). После прогонов `_repro/` удалён.
Предмет, батарея и скрипты в клоне не правились. Живой `~/.config/odelix/github.env` не читался.

| артефакт | блоб frozen/070/1 | блоб HEAD |
|---|---|---|
| `contracts/070-github-chtenie-ro-token-v-sessiju.md` | `b0c222ac6de4` | `b0c222ac6de4` |
| `fixtures/workshop_project/red_github_token_070.sh` | `40393af82fb4` | `40393af82fb4` |
| `fixtures/_krasnye_070.sh` | `852a620c78c5` | `852a620c78c5` |
| `fixtures/workshop_project/.probe-only` | `f837c4f98518` | `f837c4f98518` |
| `workshop` | `c544bc782716` | `590a6a1ece8f` |
| `scripts/check_github_token_070.sh` | нет | `bc78ef594560` |
| `.github/workflows/ci.yml` | `5a5c65aa8130` | `4a9e7445e82b` |
| `package.json` | `cea9a7303ec8` | `679b1b6b51ae` |

Вердикт связан с этими блобами. Новая редакция любого из них принятия не наследует.

## Стенограмма спавна и моя сверка

- Оркестратор: «CI ЗЕЛЁНЫЙ 00ab79c 6/6 (4б пройден); детектор rc 0 «основной чекаут чист»;
  HEAD = origin/main 0/0». Детектор не перепрогонял (основной чекаут — не моя зона).
- CI сверил сам: `gh run list --commit 00ab79c…` → run `36893289927` success; `gh run view --json jobs`
  → `ci` + ap1…ap5, все 6 success; шаг «Сам-тесты GitHub-чтения (контракт 070)» — success.

## Итог

Реализация исполняет инварианты 1–6 и строки приёмки А2–А5. Все восемь пунктов задания зелёные
моими прогонами. Батарея краснеет на до-реализационном дереве (г0) и на 8 из 8 моих мутантов. Эти
мутанты — не стабы батареи, а правки самого workshop. Проводка 038 зелёная. Она краснеет г1 на
frozen-дереве и г2 при снятом ci-шаге. Frozen-поле не тронуто. Дифф workshop только добавляет
строки: 55 вставок, 0 удалений, 3 ханка ровно в точках ПЕРЕСЕЧЕНИЕ. Соседние батареи 054/058/059/060
зелёные. Батарея 055 красная одинаково на HEAD, `602bc2c`, `2bbe8a2` и `4d6407e`, то есть 070 тут ни
при чём (Н-5). Блокеров нет. Пять находок ниже не блокируют. По каждой назван класс и причина.

## Пункты приёмки — сырой вывод и rc

Прогоны в корне клона `/tmp/dev-harness-verify/rev070`, HEAD `00ab79c`.

### (1) Раннер семьи

```text
$ bash fixtures/_krasnye_070.sh; echo "RC=$?"
стаб-пак: 7/7 поймано, диффпроба 7/7 — различимость жива (Н-39)
честная часть: 7/7 зелёная; предъявлений: стабы 7/7 + дифф 7/7 + честные 7/7
итог 070: rc=0
RC=0
```

Счёт «7/7» сверен СВОЕЙ мерой, по коду батареи, а не по её выводу:
- различных ручек `STUB_*`, кроме служебных `STUB_ENV`/`STUB_TREE`: 7
  (PRINT_VALUE, WRITE_FILE, SILENT, OVERWRITE, REQUIRE, NO_EXPORT, NO_MODE);
- определений `check_c*()` + `diff_c*()`: 14 (= 7 + 7);
- строк `hcell к*`: 7.

### (2) Проводка

```text
$ bash scripts/check_provodka.sh . contracts/070-github-chtenie-ro-token-v-sessiju.md; echo "RC=$?"
RC=0
```

Красное предъявлено мной (копии `git archive` в `_repro/`):
```text
frozen/070/1-дерево:   проводка: guard-файл не существует: scripts/check_github_token_070.sh   PROVODKA@frozen RC=1
HEAD без ci-шага:     проводка: guard не подключён: scripts/check_github_token_070.sh не вызывается в .githooks/ или .github/workflows/   PROVODKA@no-ci-step RC=1
```

### (3) CI-паритет

```text
$ bash scripts/verify_ci_parity.sh .; echo "RC=$?"
…
workflow-команд: 52 · скриптов в приёмке: 64 · объявленных исключений: 23 · matrix-ключей: 45 · анти-плацебо-запусков: 2 · расхождений: 0
RC=0
```

### (4) Наблюдения

```text
$ bash scripts/check_nabludenia.sh; echo "RC=$?"
RC=0
```

### (5) Frozen-поле неизменно

```text
$ git diff --exit-code frozen/contracts/070/1 HEAD -- contracts/070-github-chtenie-ro-token-v-sessiju.md fixtures/workshop_project/red_github_token_070.sh fixtures/_krasnye_070.sh; echo "RC=$?"
RC=0          (вывод пуст)
```

Блобы совпадают побайтно (таблица выше). `.probe-only` тоже не менялся. `roles/`, `AGENTS.md` и
`contracts/` после заморозки не тронуты: `git diff --quiet frozen/contracts/070/1 HEAD -- roles/ AGENTS.md contracts/` → rc 0.

### (6) Дифф реализации — только зона

```text
$ git diff --stat frozen/contracts/070/1 HEAD -- workshop .github/workflows/ci.yml package.json scripts/check_github_token_070.sh
 .github/workflows/ci.yml          | 21 +++++++++++++++
 package.json                      |  1 +
 scripts/check_github_token_070.sh | 20 ++++++++++++++
 workshop                          | 55 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 97 insertions(+)
RC=0
$ git diff --numstat …  →  21 0 / 1 0 / 20 0 / 55 0        (удалений 0)
$ git diff -U0 frozen/contracts/070/1 HEAD -- workshop | grep '^@@'
@@ -138,0 +139,53 @@ bootstrap_env() {
@@ -513,0 +567 @@ if [ -z "$PROJECT" ]; then
@@ -581,0 +636 @@ bootstrap_env
```

Все коммиты окна `frozen/contracts/070/1..HEAD` (без merge), автор и файлы:

| коммит | автор | файлы | зона 070 |
|---|---|---|---|
| 5372e97 | implementer | `.github/workflows/ci.yml` `package.json` `scripts/check_github_token_070.sh` `workshop` | ЗОНА implementer, все 4 |
| a5411d1 | implementer | `scripts/check_github_token_070.sh` (шапка `НЕ БАРЬЕР:`) | ЗОНА implementer |
| 81a0855 | implementer | `package.json` (ключ = значение ci-шага, правило 6) | ЗОНА implementer |
| 5f8a251 | architect | `NABLIUDENIA_ARCHITECT.md` (одна строка, адрес А-313) | ЗОНА architect |
| 251ad53 / 719b920 | orchestrator | `registry/contracts.tsv` (минт) / `HANDOFF.md` | вне суда зон |

Общая мера зон:
```text
$ bash scripts/check_zones.sh .
замороженных контрактов: 69 · объявленных авторов: 2 · коммитов в диапазонах: 3294 · проверено по зонам: 1537
RC=0
```

Implementer не трогал ни одного файла `fixtures/` и контракта, поэтому проверка под код не
переписывалась (пункт 3 роли). Атомарность: в 5372e97 один предмет. a5411d1 и 81a0855 — по одной
правке на гейт: классификатор verify_antiplacebo и правило 6 паритета. У каждого коммита в теме
стоит «070». Норма в задаче о механизме не тронута: `roles/`/`AGENTS.md` без дельты. Строка
журнала architect (5f8a251) относится к наблюдению, не к норме.

### (7) Ключ пакета

```text
$ npm run -s check:github-token-family-selftest; echo "RC=$?"
стаб-пак: 7/7 поймано, диффпроба 7/7 — различимость жива (Н-39)
честная часть: 7/7 зелёная; предъявлений: стабы 7/7 + дифф 7/7 + честные 7/7
итог 070: rc=0
RC=0
```

### (8) `load_github_token` против §Инварианты и ПЕРЕСЕЧЕНИЕ — чтение кода + своя мера

Код: `workshop:154-190`. Вызовы: дев `workshop:567`, проект `workshop:636`.

| требование | код | своя мера |
|---|---|---|
| оба входа зовут шаг ДО подмены HOME | дев: `:565 load_env → :566 bootstrap_env → :567 load_github_token → :569 export HOME="$ZONE"`; проект: `:634-636`, подмена `:762 export HOME="$PSTATE/home"` | M3 (вызов перенесён за `:762`) → г0 «предмет отсутствует», rc 1; M1 (снят вызов `:567`) → к7 красная, rc 1 |
| И-6 непустой внешний env побеждает файл | `:158-162` ранний `return` при `-n "${ODELIX_GITHUB_TOKEN:-}"` | edges `ext_wins` → var=ext, mode=read; M4 (`if false`) → к4 красная |
| пустой внешний = не задан | тот же `:-` | edges `ext_empty` → берётся файл (read); `ext_empty_nf` → offline, var unset |
| И-5 offline = unset, не пусто | `:186 unset ODELIX_GITHUB_TOKEN` | edges `nofile`/`empty_val`/`empty_quoted` → mode=offline, var unset, в `env` 0 строк; M2 (`export …=""`) → к3 красная |
| И-5 не фатально | ветвь offline без `die`/`exit` | M8 (`exit 3` после offline-строки) → к3+к6 красные |
| И-1 экспорт в env ребёнка | `:179-180 export` | edges `plain` → в `env` 1 строка; к2/к7 зелёные |
| И-4 баннер только режим | `printf 'GITHUB: read\n'` / `'GITHUB: offline\n'`, значение не печатается | M5 (значение в stderr) → к1+к2 красные |
| И-3 нуль копий | шаг пишет только env | M6 (дописывание в `$HERE/.env`) → к5 красная |
| И-2 только чтение | write-маршрутов нет; значение передаётся как есть | чтение кода |
| грамматика KEY=VALUE, разрез по первому «=», срез кавычек | `:165-176` | edges `dquote`/`squote` → `abc`; `eq_in_value` → `a=b`; `comment`/`other_keys` → `abc` |
| ПЕРЕСЕЧЕНИЕ 054: блок рядом с load_env/bootstrap_env (:580-581, :512-514) | ханки `-513,0 +567` / `-581,0 +636` + функция после `bootstrap_env()` | numstat 55/0 |
| 054/055/058 семантики не тронуты | 0 удалённых строк в workshop | батареи — раздел (и) |
| баннер рядом с METERING (:836) | баннер печатается из самой функции в точке вызова, не у METERING | Н-2 (не блокирует) |

Сырой вывод мутантов (`_repro/mut.sh`: копия `git archive HEAD`, perl-правка workshop, раннер копии):
```text
m0_frozen (дерево 602bc2c)  ОТКАЗ: предмет отсутствует: …/m0_frozen/workshop на probe с токеном в доме не печатает строку `GITHUB: read` …  итог 070: rc=1
m00_head (HEAD без правки)   честная часть: 7/7 зелёная …  итог 070: rc=0
M1_dev_no_call       070-батарея: честная клетка к7 красная · честная часть: 6 из 7 · итог 070: rc=1
M2_offline_empty     070-батарея: честная клетка к3 красная · 6 из 7 · rc=1
M3_after_home        ОТКАЗ: предмет отсутствует … · rc=1
M4_no_ext_priority   070-батарея: честная клетка к4 красная · 6 из 7 · rc=1
M5_stderr_leak       к1 красная, к2 красная · 5 из 7 · rc=1
M6_file_copy         к5 красная · 6 из 7 · rc=1
M7_ext_no_mode       к4 красная · 6 из 7 · rc=1
M8_fatal_offline     к3 красная, к6 красная · 5 из 7 · rc=1
```
Guard проводит красное: на копии M1 `bash scripts/check_github_token_070.sh` дал «честная клетка
к7 красная … итог 070: rc=1», `GUARD@M1 RC=1`.

Сырой вывод `edges.sh`. Функция извлечена из HEAD workshop, toy-дом. var — значение побайтно (`od -c`):
```text
plain                  banner=GITHUB: read     mode=read     var=set:[ a b c]           inEnv=1
dquote                 banner=GITHUB: read     mode=read     var=set:[ a b c]           inEnv=1
squote                 banner=GITHUB: read     mode=read     var=set:[ a b c]           inEnv=1
eq_in_value            banner=GITHUB: read     mode=read     var=set:[ a = b]           inEnv=1
comment                banner=GITHUB: read     mode=read     var=set:[ a b c]           inEnv=1
other_keys             banner=GITHUB: read     mode=read     var=set:[ a b c]           inEnv=1
no_newline             banner=GITHUB: offline  mode=offline  var=unset                  inEnv=0
crlf                   banner=GITHUB: read     mode=read     var=set:[ a b c \r]        inEnv=1
empty_val              banner=GITHUB: offline  mode=offline  var=unset                  inEnv=0
empty_quoted           banner=GITHUB: offline  mode=offline  var=unset                  inEnv=0
nofile                 banner=GITHUB: offline  mode=offline  var=unset                  inEnv=0
ext_wins               banner=GITHUB: read     mode=read     var=set:[ e x t]           inEnv=1
ext_empty              banner=GITHUB: read     mode=read     var=set:[ f i l e]         inEnv=1
ext_empty_nf           banner=GITHUB: offline  mode=offline  var=unset                  inEnv=0
dup_lines              banner=GITHUB: read     mode=read     var=set:[ o n e]           inEnv=1
```

### (и) Scoped-регресс соседних барьеров (Н-48: workshop общий с 054/055/058/059/060)

```text
bash fixtures/_krasnye_054.sh → 054-батарея зелёная · итог 054: rc=0
bash fixtures/_krasnye_055.sh → 055-батарея: диффпроба c12 — стаб без ручки упал · стаб-пак: поймано 7 из 13 · итог 055: rc=1   (раннер сам выходит 0 — последняя строка echo)
bash fixtures/_krasnye_058.sh → честная часть: 16/16 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 16/16 · итог 058: rc=0
bash fixtures/_krasnye_059.sh → стаб-пак 9/9 пойман, диффпроба ошибок 0, честные 24/24 зелёные · итог 059: rc=0
bash fixtures/_krasnye_060.sh → 060: стерегомое дерево харнесса: не тронуто · итог 060: rc=0
```
Батарея 055 даёт тот же вывод (`cd: /tmp/tmp.*/repo-p1: No such file or directory`, c12, 7 из 13)
на копиях `602bc2c` (frozen 070, до реализации), `2bbe8a2` и `4d6407e`. На `4d6407e` ревьюер 060
видел 13/13. Значит, 070 эту красноту не вносит, а различие — в окружении машины (Н-5).

Анти-плацебо матрица: локальный `bash scripts/verify_antiplacebo.sh --changed frozen/contracts/070/1` я
запускал, но остановил незавершённым (более 15 мин), поэтому итог НЕ заявляю (прерван мной, rc 143 через 341 с). В хвосте прерванного вывода есть строка
`FAIL check_merge_gate.sh: нет фикстур — ожидается fixtures/check_merge_gate/case_*.sh`. Файл не входит
в дифф 070, а фикстуры гейта слияния лежат в `fixtures/check_judge_gate/` (063). Строка к 070 не относится,
записываю её как наблюдение для оркестратора: в CI шарды зелёные. Классификатор
scripts/ (новый файл `check_github_token_070.sh`, класс «п» по шапке `НЕ БАРЬЕР:`) и шарды ap1…ap5
покрыты CI run 36893289927 на `00ab79c`: все 5 success (`gh run view --json jobs`). Это CI, не моя мера.

## ПРОВОДКА-каналы (контракт 038)

- Канал один: `guard=scripts/check_github_token_070.sh`. Он существует (блоб `bc78ef594560`) и подключён
  прямым шагом `run: bash scripts/check_github_token_070.sh` после шага 060 (`.github/workflows/ci.yml`).
  Шаг зелёный в run 36893289927. Ключ `check:github-token-family-selftest` дословно равен значению шага.
- Guard — барьер именно этого предмета, а не любой скрипт дерева. Он делает `exec` в
  `fixtures/_krasnye_070.sh`, и rc проходит насквозь: мутант M1 → guard rc 1. Шапка `НЕ БАРЬЕР:` —
  классификация verify_antiplacebo (класс «п»), а не отказ от роли барьера. Фактический барьер —
  батарея probe-only семьи 034 вне `case_*`-глоба, как заявлено в ПРОВОДКА-ЭНФОРСМЕНТ.
- ПРОВОДКА-ЭНФОРСМЕНТ честен: предмет — механизм лаунчера, а не поведенческая норма роли
  (029-класс), поэтому role-канал не требуется.

## Паразитная сложность (контракт 050)

- **`load_github_token` (workshop:139-191, 53 строки, из них ~17 кода).**
  - (1) Свойство: И-1, И-3..И-6. Существующие функции его не покрывают: `load_env` читает только
    `$1/.env`, `bootstrap_env` пишет копию в `.env` (запрет И-3). Править их нельзя по
    ПЕРЕСЕЧЕНИЕ 054.
  - (2) Состояние явное: env `ODELIX_GITHUB_TOKEN`/`HARNESS_GITHUB_MODE` + строка stdout `GITHUB:`.
  - (3) Связка правки: workshop + батарея 070. Числа связки дифф не вырастил.
  - (4) Глубина: интерфейс — 0 аргументов, читает `HOME` и `ODELIX_GITHUB_TOKEN`; работа — разбор,
    приоритет, режим, баннер. Модуль глубокий.
  - (5) Потребители: к1..к7, ci-шаг. Цикл KEY=VALUE повторяет грамматику `load_env`/`bootstrap_env`
    третьей копией. Срез кавычек сделан другой формой: parameter expansion вместо `sed` (Н-4).
  - **ESSENTIAL.**
- **`scripts/check_github_token_070.sh` (20 строк, чистый `exec`-делегат).**
  - (1) Свойство: ПРОВОДКА frozen 070 называет именно этот путь guard. Более простая форма
    `guard=fixtures/_krasnye_070.sh` (конвенция 058/059/060) НЕ проходит строку (2) приёмки против
    замороженного текста.
  - (2) Состояния нет.
  - (3) Связка — 1 файл.
  - (4) Модуль мелкий: интерфейс = интерфейс раннера.
  - (5) Потребители — ci-шаг, ключ пакета, check_provodka г1/г2.
  - **ESSENTIAL относительно frozen-текста.** Вторая конвенция заложена контрактом, не реализацией.
    Это уже открыто в журнале как А-313 (адрес — гигиена заданий orchestrator). Implementer тут не
    виноват.
- **ci-шаг «Сам-тесты GitHub-чтения (контракт 070)» (21 строка, из них 2 — `name`/`run`).**
  - (1) Подключение guard-канала по ПРОВОДКА.
  - (2) Состояния нет.
  - (3) Одна строка `run`.
  - (4) Неприменимо.
  - (5) Потребитель — CI. Форма шагов 058/059/060 повторена без новой джобы и шард-ключа.
  - **ESSENTIAL.**
- **Ключ `check:github-token-family-selftest` (package.json, 1 строка).**
  - (1) Правило 6 verify_ci_parity, четвёртая форма.
  - (2)–(4) Неприменимо.
  - (5) Потребитель — паритет-гейт.
  - **ESSENTIAL.**

## Находки (формат reslop)

Отдельный файл `.review/` не заводился — прецедент `contracts-058-v1.md`…`contracts-060-v1.md`:
задание разрешает коммит одного вердикт-файла. Чекбоксы находок лежат здесь.

---
status: ready
---

- [ ] **Н-1 — последняя строка без перевода строки молча теряется: дом с токеном даёт `GITHUB: offline`.**
  - Класс: дефект вне положительной области демаркации (унаследован от грамматики bootstrap_env).
    Не блокирует. Вопрос владельцу.
  - Фрагмент: `workshop:167` `while IFS='=' read -r k v; do … done < "$gh_home"`. `read` возвращает
    ≠0 на незавершённой последней строке, и цикл её не обрабатывает.
  - Наблюдение (edges `no_newline`): файл `ODELIX_GITHUB_TOKEN=abc` без `\n` → `GITHUB: offline`,
    var unset.
  - Почему не блокирует: демаркация 070 определяет конформность «по грамматике bootstrap_env».
    `bootstrap_env:129` и `load_env:112` имеют тот же цикл и то же поведение. Деградация явная
    (баннер offline), то есть ровно то, что стережёт И-5.
  - Риск реальный: файл, записанный `printf '…=%s' "$tok" > github.env` или редактором без
    финального `\n`, оставит живую сессию offline при наличии токена.
  - Владельцу (живой файл я не читал): `tail -c1 ~/.config/odelix/github.env | wc -l` → `1` значит
    перевод строки есть.
  - Более простая форма (строки приёмки проходят так же):
    `while IFS='=' read -r k v || [ -n "$k" ]; do`.
- [ ] **Н-2 — баннер `GITHUB:` печатается в точке шага, а не «рядом с METERING (:836)», как говорит
  ПЕРЕСЕЧЕНИЕ 054.**
  - Класс: расхождение прозы ПЕРЕСЕЧЕНИЕ и кода в сторону МЕНЬШЕЙ дельты. Не блокирует.
  - Код: `printf 'GITHUB: …'` внутри `load_github_token`, вызов на `workshop:636`. Строка METERING —
    `workshop:891`.
  - Следствие (своя мера `_repro/n2.sh`: toy-проект без `.env`, токен в toy-доме): probe rc 1, вывод
    `3:GITHUB: read` → `4:profile ОТКАЗ: нет .env проекта: …` (P8, И-13 054 после `:636`). Строка
    `GITHUB:` печатается до отказа. Так же ведут себя
    `WORKFLOW:`/`TOOLS:` (прецедент Н-2 вердикта 060).
  - Почему не блокирует: ПЕРЕСЕЧЕНИЕ задаёт верхнюю границу дельты в чужой зоне, а реализация её не
    превысила (у METERING нет ни одной строки). Семейство grep -Fx-стабильных probe-видимых строк
    соблюдено (к1/к3/к6). Батареи 054/058 зелёные.
  - Более простая форма: исправить прозу ПЕРЕСЕЧЕНИЕ при следующей редакции контракта. Код менять
    не нужно.
- [ ] **Н-3 — номера строк в комментарии функции устарели в момент вставки.**
  - Класс: совет.
  - `workshop:143` «проектный (строка 580) и дев (строка 513)» и `workshop:152` «ДО подмены HOME
    (строки 515/707)». Фактически вызовы на 636/567, подмена на 569/762. Это номера frozen-дерева
    до вставки 53 строк.
  - Более простая форма: ссылаться на имена (`load_env "$PROJECT"`, `export HOME="$PSTATE/home"`),
    а не на номера.
- [ ] **Н-4 — срез кавычек реализован второй формой грамматики. CRLF даёт непустой битый токен в
  режиме read.**
  - Класс: совет.
  - `workshop:172` `v="${v%\"}"; v="${v#\"}"; v="${v%\'}"; v="${v#\'}"` вместо `sed` соседей
    (`:115`, `:133`). Поведение совпадает на `"x"`, `'x'`, `""`. Расходится на вложенных `"'x'"`:
    здесь `x`, у соседей `'x'`. Контракт обещал «вторая конвенция не строится».
  - Edges `crlf`: значение `abc\r` экспортируется, режим read. Вход вне конформной грамматики,
    соседи ведут себя так же.
  - Более простая форма: тот же `sed`, что у `bootstrap_env`.
- [ ] **Н-5 — батарея 055 красная в окружении суда независимо от 070. Раннер 055 маскирует rc.**
  - Класс: наблюдение вне предмета, для оркестратора.
  - Вывод одинаковый на HEAD, `602bc2c`, `2bbe8a2`, `4d6407e`: «диффпроба c12 — стаб без ручки
    упал · поймано 7 из 13», плюс `cd: /tmp/tmp.*/repo-p1: No such file or directory`
    (`red_izoljacija_projectid.sh:466`).
  - На `4d6407e` вердикт 060 зафиксировал 13/13 + 17/17. Значит, причина в окружении, а не в
    коде 070.
  - `fixtures/_krasnye_055.sh` заканчивается `echo "итог 055: rc=$?"` и выходит 0 при красной
    батарее. CI 055 напрямую не гоняет (ci.yml шаги 058/059/060/070).
  - К 070 не относится. Предмет 070 эту строку не правил (РАБОТА НЕ РАЗДАЁТСЯ: раннеры соседей).
