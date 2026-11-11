FAIL
OBJECT=a7acb1d38c92aa606e7fb0b565ae67f95eafe864
КЛАСС=обычный
СУД: repo=a3ka/dev-harness; предмет=190; фаза=реализация; роль=reviewer; вызов=1/1; модель-план=anthropic/claude-opus-5-5; сессия=Rev190v1 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; SHA=a7acb1d38c92aa606e7fb0b565ae67f95eafe864; контракт=frozen/contracts/190/1; предыдущий=verdicts/critic/contracts-190-v1.md; исключение=нет

# Вердикт reviewer — 190 «замер связки» (Л6), реализация, вызов 1/1

**FAIL: два блока.** Находки в reslop-формате лежат в `.review/2026-11-11-19.md` клона `/tmp/dev-harness-verify/Rev190v1/repo`, `status: ready`; в коммит файл не входит.

- **Б-1 (инвариант 8).** На битой строке журнала инструмент падает с traceback и rc 1, хотя её надо пропустить. Ломают его три входа: обрыв посреди многобайтового символа, JSON-строка, которая не является объектом, и `message:null`. Код 1 по контракту означает `ПУСТАЯ_ВЫБОРКА`, так что падение выдаёт ложное имя исхода. Состояние достижимо: в живом корне сессий лежит журнал с оборванной последней записью.
- **Б-2 (заявленное ≠ сделанному).** Раздел `docs/190-zamer-svyazki.md` «Сверка с проходом 16» обещает, что одна команда воспроизводит «27 вызовов, 16 FAIL, 11 accept, 22 блока». Замороженный контракт (§Приёмка, «Граница живого среза») объявляет это недостижимым по построению. Моя мера на пине `7c2d206c33b1` даёт 37/16/13/22 при 8 обрывах.

Ещё пять советов (С-1…С-5) и три наблюдения (Н-1…Н-3). Класс риска **обычный** подтверждаю: инструмент только читает, записей в репозиторий и журналы нет (см. §7).

Клон: `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev190v1/repo`, свой `.git`. Деревья (worktree клона): `impl` = OBJECT, `main` = origin/main `88e64e64`, `pin-1cc2fa4baf51`, `pin-7c2d206c33b1`.

## Кандидат

```
$ git rev-parse FETCH_HEAD origin/main        # после git fetch origin wip/190/implementer
a7acb1d38c92aa606e7fb0b565ae67f95eafe864
88e64e64aab7f0f2b2083bcb1b6f90f53eafcdcf
$ git merge-base FETCH_HEAD origin/main
9b57a34d8e00d8e8cfa5d2a78d6be159345b8f72
$ git log -1 --format='author=%an <%ae> committer=%cn' a7acb1d3
author=implementer <implementer@dev-harness.local> committer=implementer
```

## 1. Область правки

```
$ git diff --stat origin/main...a7acb1d3
 docs/190-zamer-svyazki.md |  61 ++++++
 scripts/zamer_svyazki.py  | 484 ++++++++++++++++++++++++++++++++++++++++++++++
 scripts/zamer_svyazki.sh  |  19 ++
 3 files changed, 564 insertions(+)
$ git diff --summary origin/main...a7acb1d3
 create mode 100644 docs/190-zamer-svyazki.md
 create mode 100755 scripts/zamer_svyazki.py
 create mode 100755 scripts/zamer_svyazki.sh
```

Затронуто ровно три файла, все из ЗОНЫ implementer. ПЕРЕСЕЧЕНИЕ соблюдено: `docs/190-zamer-svyazki.md` — новый файл, прочие `docs/` не тронуты. Двухточечный `git diff --stat origin/main a7acb1d3` даёт 7 файлов, но лишние четыре — это продвижение main после 9b57a34d (HANDOFF и вердикты 187/195), а не работа implementer.

## 2. Сырой вывод: батарея, мои прогоны

```
# дерево OBJECT (impl)
$ bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
GREEN mir-a-tablica … GREEN dokument-kanon        (22 строки GREEN)
ИТОГ 190: клеток 22, зелёных 22, красных 0; СВЯЗИ 0, поймано 0, жив 0
rc=0
# дерево origin/main 88e64e64, реализации нет (ls scripts/zamer_svyazki* → No such file)
$ bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
SUBJECT_ABSENT: scripts/zamer_svyazki.* не реализован — все клетки красны
RED mir-a-tablica: SUBJECT_ABSENT … RED dokument-kanon: SUBJECT_ABSENT   (22 строки RED)
ИТОГ 190: клеток 22, зелёных 0, красных 22
rc=1
$ bash …/red_zamer_svyazki_190.sh --model
ИТОГ 190: клеток 22, зелёных 22, красных 0; СВЯЗИ 0, поймано 0, жив 0
rc=0
$ bash …/red_zamer_svyazki_190.sh --stabs
STAB stab_bez_filtra_strok.py caught @ mir-a-tablica
STAB stab_bez_okna.py caught @ okno-seansov
STAB stab_bez_sortirovki.py caught @ mir-a-tablica
STAB stab_bez_stderr.py caught @ stderr-prosmotreno
STAB stab_bloki_nol_bez_metok.py caught @ bloki-metki
STAB stab_hvost_posle_pervoj_pravki.py caught @ odinochnye-hvost
STAB stab_ignor_do.py caught @ okno-do
STAB stab_nol_ne_ustanovlen.py caught @ verdikt-bez-suda
STAB stab_odinochnye_vse_roli.py caught @ odinochnye-hvost
STAB stab_poteral_obryv.py caught @ obryv-schitaetsja
STAB stab_schet_po_fajlam.py caught @ mir-b-bez-obryva
STAB stab_schet_tsitat.py caught @ tsitata-sud
STAB stab_slovoforma_potera.py caught @ forma-slovo-ne-ust
STAB stab_tokeny_ne_toj_roli.py caught @ tokeny-rolevye
STAB stab_vyzov_slesh_strog.py caught @ forma-vyzova
ИТОГ 190: клеток 22, зелёных 22, красных 0; СВЯЗИ 15, поймано 15, жив 0
rc=0
$ bash …/red_zamer_svyazki_190.sh --oracle-tamper
ORACLE_OK
rc=0
$ reslop t -- bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
exit: 0
$ bash -n scripts/zamer_svyazki.sh        → rc=0
$ shellcheck scripts/zamer_svyazki.sh     → error: command not found: shellcheck (rc=127; на станции нет — Н-3)
$ python3 -c "import py_compile; py_compile.compile('scripts/zamer_svyazki.py', cfile='/tmp/…/zs.pyc', doraise=True)"  → rc=0
$ git ls-files -s scripts/zamer_svyazki.sh scripts/zamer_svyazki.py docs/190-zamer-svyazki.md
100644 a6304d27… docs/190-zamer-svyazki.md
100755 f04bf9bd… scripts/zamer_svyazki.py
100755 9662d45d… scripts/zamer_svyazki.sh
```

Счётные утверждения доклада implementer я перемерил своими прогонами: 22/22, red 22 с `SUBJECT_ABSENT`, `--model` 22/22, `--stabs` 15/15/0, `ORACLE_OK`. Всё сходится.

Scoped-регресс барьера и неизменность frozen:

```
$ bash scripts/verify_antiplacebo.sh --scope check_provodka | grep -v '^  ok '
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
rc=0
$ git diff --stat frozen/contracts/190/1 a7acb1d3 -- fixtures/workshop_project/zamer_svyazki_190 contracts/190-zamer-svyazki.md
(пусто) rc=0
$ git diff --stat origin/main...a7acb1d3 -- frozen fixtures contracts roles scripts/check_zones.sh
(пусто) rc=0
```

Первый прогон `verify_antiplacebo --scope check_provodka` дал rc 1 с причиной «`__pycache__/zamer_svyazki.cpython-312.pyc` не классифицирован». Этот `.pyc` создал мой зонд `fence_live.py`: он импортировал модуль через importlib. Я удалил свой артефакт, и повтор дал rc 0. Обёртка самой реализации выставляет `PYTHONDONTWRITEBYTECODE=1` и байткода не пишет.

## 3. Неподгонка проверок под код

- Коммит implementer не трогает ни `fixtures/`, ни контракт, ни frozen (см. §1 и §2).
- Реализация не читает эталон и оракул и не держит веток под входы фикстур. `grep` по `30[1-4]|1cc2fa|7c2d206|mir|orakul|zamer_model|model/|dannye|/home/|harness-sessions` в `scripts/zamer_svyazki.py` находит только комментарии, docstring и имя инструмента `('edit', 'write')` на стр. 294. Литералов миров, номеров 301–304, пинов и путей станции нет.
- Заголовок вывода побайтово совпадает с документом, контрактом и `model/docs`:

```
cols 21
in doc: True in contract: True in model-doc: True
```

- Реализация повторяет эталон построчно (Н-1). Поэтому её равенство с эталоном я мерил отдельно, на живых данных без дрейфа: окно закрыто `--do 2026-11-10T14:57:00Z`, раньше самой ранней сессии, чьи журналы менялись за последние 4 часа:

```
SAME impl [--do 2026-11-10T14:57:00Z] lines=192 просмотрено: записей_журналов=191118 rc=0
SAME impl [--s 2026-11-09T00:00:00Z --do 2026-11-10T14:57:00Z] lines=187 просмотрено: записей_журналов=6949 rc=0
SAME main [--do …] lines=192 … rc=0 ; SAME main [--s … --do …] lines=187 … rc=0
SAME pin-1cc2fa4baf51 [--do …] lines=183 … rc=0 ; SAME pin-1cc2fa4baf51 [--s … --do …] lines=177 … rc=0
SAME pin-7c2d206c33b1 [--do …] lines=189 … rc=0 ; SAME pin-7c2d206c33b1 [--s … --do …] lines=183 … rc=0
```

8/8 побайтово (stdout, stderr и rc). Первый прогон без `--do` дал 6 DIFF из 32. Все они пришлись на открытые окна корня c907157c, куда живые сессии дописывают журналы между двумя прогонами (это дрейф, не расхождение). Повтор с закрытым окном — выше.

## 4. Красное предъявлено: настоящие мутации реализации

Мутанты `scripts/zamer_svyazki.py` гонялись в worktree OBJECT. После прогона файл восстановлен, `git status --porcelain` пуст.

| мутация | rc батареи | красные клетки |
|---|---|---|
| M1 строки вне реестра (убран фильтр строк по реестру) | 1 | 15, в т.ч. `mir-a-tablica` |
| M1b убран фильтр `роль=critic` у СУД-строк HANDOFF | **0** | **0 — выжил** (С-1б) |
| M2 убрано окно `--do` | 1 | 1: `okno-do` |
| M3 обрыв HANDOFF не учитывается | 1 | 14, в т.ч. `obryv-schitaetsja` |
| M4 `не-установлен` → числа | 1 | 16, в т.ч. `verdikt-bez-suda` |
| M5 убран переключатель fence (цитата в блоке-коде) | **0** | **0 — выжил** (С-1а) |
| M6 обратная сортировка | 1 | 1: `mir-a-tablica` |
| M7 убрана строка stderr «просмотрено» | 1 | 1: `stderr-prosmotreno` |

Шесть мутаций из восьми батарея ловит на своей клетке. Две выживают, и это дыры батареи (зона architect, С-1). Реализация на этих путях ведёт себя верно, что я проверил своим мини-миром fence:

```
# 501: вердикт accept, чужая СУД 7/9 в ```text ДО своей учётной 1/2; HANDOFF: fenced СУД 502 3/5 и СУД роль=reviewer 501 2/2
предмет	вызовы	fail	accept	обрывы	исход	блоки
501	1	0	1	0	accept	0
ИТОГО	1	0	1	0	-	0
rc=0
```

## 5. Инварианты 1–8 на входах вне батареи (мой мини-мир)

Мир: реестр 401–404. Вердикты 401 несут `вызов=1 (первый, пояснение)` FAIL с блоком и `вызов=2 (СВЕРХ капа)` accept. 402 — основная серия FAIL 1/2 с блоками, у которых метки частичны, плюс поздняя серия `фаза=контракт (v2)` accept. У 403 вердиктов нет, есть только агенты. У 404 нет ничего. Журналы: Arch403a (read, edit, read+grep), Crit401a, Main (вне алфавита), Arch401b. Ожидание я посчитал руками до прогона.

```
$ bash scripts/zamer_svyazki.sh --repo mini/repo --zhurnaly mini/j
предмет	вызовы	fail	accept	обрывы	исход	блоки	первичные	дельта	узкое	пропущено	повтор	происх_не_уст	классы	классы_не_уст	arch_токены	arch_вызовы	crit_токены	crit_вызовы	одиночные_доля	хвост_доля
401	2	1	1	0	accept	1	0	1	0	0	0	0	К-07:1	0	10	1	1000	1	100.0%	100.0%
402	2	1	1	0	FAIL	2	0	0	0	0	1	1	К-10:1	1	0	0	0	0	0.0%	0.0%
403	0	0	0	0	-	0	0	0	0	0	0	0	-	0	350	3	0	0	66.7%	14.3%
ИТОГО	4	2	2	0	-	3	0	1	0	0	1	1	-	-	360	4	1000	1	75.0%	16.7%
МЕР	среднее_вызовов=1.3	accept_do_vtorogo=1/3	chetyre_plus=0
просмотрено: записей_журналов=5
rc=0
```

Все клетки совпали с ручным счётом:
- `N (пояснение)` без слэша распознаётся;
- поздняя серия не берётся в исход;
- блоки без меток уходят в `не_уст`;
- хвост считается после последней правки;
- Main не входит ни в одну роль;
- 404 строки не получает.

Честные отказы и граница окна:

```
-- --s 2026-12-01T00:00:00Z          → ПУСТАЯ_ВЫБОРКА: в окне нет ни одной записи журналов  rc=1
-- --zhurnaly mini/nope               → НЕТ_ЖУРНАЛОВ: каталог сессий не существует          rc=2
-- registry/contracts.tsv убран       → НЕТ_РЕЕСТРА: registry/contracts.tsv                 rc=2
-- --s 2026-11-10T00:00:00Z           → 403 350/3, 401 arch 0 (сессия 11-09 выпала)          rc=0
-- --s 2026-11-10 (дата без времени)  → ПУСТАЯ_ВЫБОРКА                                       rc=1   ← С-2
```

Битый журнал. К Arch403a дописана одна строка:

```
== truncated  (обрезанная ASCII-строка)       → 403 … 350 3 …; просмотрено: записей_журналов=5   rc=0   (пропуск — верно)
== badutf8    (обрыв посреди «обрыв» в UTF-8)  → Traceback … UnicodeDecodeError: 'utf-8' codec can't decode byte 0xd0 in position 0: unexpected end of data   rc=1
== scalar     ([1,2])                         → Traceback … AttributeError: 'list' object has no attribute 'get'      rc=1
== nullmsg    ({"type":"message","message":null}) → Traceback … AttributeError: 'NoneType' object has no attribute 'get'   rc=1
   (эталон model/zamer_model.py на тех же трёх входах — тот же traceback, rc=1)
```

Живая достижимость (только чтение корня сессий):

```
$ python3 scan_live.py <оба корня sessions>
files=3341 no_trailing_newline=1 invalid_utf8=0 nonjson_lines=1 nondict=0
$ python3 scan_partial.py …/c907157c/…/sessions
partial: 2026-11-10T13-35-21-414Z_01a1c5ab-9f46-710c-8204-05be6410952d Crit175R2.jsonl tail: b'andidate author and scope"},{"type":"toolCall","id":"call_03'
files=3341 with_raw_non_ascii=3341
```

## 6. Живые строки контракта (пины)

```
$ bash scripts/zamer_svyazki.sh --repo pin-1cc2fa4baf51 --zhurnaly …/c907157c/…/sessions --s 2026-11-09T00:00:00Z --predmety '170'
170	4	2	2	0	accept	2	0	0	0	0	0	2	-	2	53129021	544	44828561	459	92.1%	18.2%
ИТОГО	4	2	2	0	-	2	…
просмотрено: записей_журналов=18878   rc=0
$ … --repo pin-7c2d206c33b1 … --predmety '182|185'
182	2	1	1	0	accept	1	…
185	2	1	1	0	accept	2	…
ИТОГО	4	2	2	0	-	3	…   rc=0
```

Строка 170 (4/2/2/0/accept/2) и строки 182 и 185 (ИТОГО 4/2/2, блоки 3) совпадают с контрактом. Строка 170 побайтово равна той, что привёл implementer. Второй корень станции `2a76639b` в этих окнах даёт `ПУСТАЯ_ВЫБОРКА` rc 1: журналов вида `*/*/*.jsonl` в нём нет, это честный отказ.

Проверка утверждения документа о «27 вызовах» (Б-2):

```
$ … --repo pin-7c2d206c33b1 --s 2026-11-09T00:00:00Z --do 2026-11-10T14:57:00Z --predmety '16[2]|17[028]|18[2-8]|185|184'
162 4 1 3 0 accept 1 | 170 4 2 2 0 accept 2 | 172 4 1 3 0 accept 3 | 182 2 1 1 0 accept 1 | 184 8 3 1 4 accept 3
185 2 1 1 0 accept 2 | 186 7 3 1 3 FAIL 6 | 187 4 2 1 1 FAIL 2 | 188 2 2 0 0 FAIL 2
ИТОГО	37	16	13	8	-	22
$ … --repo pin-1cc2fa4baf51 (то же)
ИТОГО	10	4	6	0	-	6
```

## 7. Инструмент только читает

- В `scripts/zamer_svyazki.py` единственный `open(` — это `open(path, encoding='utf-8')`, чтение журнала (стр. 280). Остальные чтения — `read_text`. Нет `'w'`, `write_*`, `mkdir`, `unlink`, `subprocess` и `os.` (grep выше).
- `scripts/zamer_svyazki.sh` делает только `exec python3` с `PYTHONDONTWRITEBYTECODE=1`.
- После всех прогонов `git status --porcelain` в worktree OBJECT пуст. Удалены только мои артефакты `scripts/__pycache__/` (от importlib-зонда) и `.log/` (от reslop).

## 8. Атомарность, норма

Работа — один коммит `a7acb1d3` со ссылкой на предмет 190 под identity implementer. Нормативные документы (`roles/`, `contracts/`, frozen) не тронуты.

## ПРОВОДКА (контракт 038)

- `guard=scripts/zamer_svyazki.sh` существует.
- `bash scripts/check_provodka.sh . contracts/190-zamer-svyazki.md` → «проводка: guard не подключён: scripts/zamer_svyazki.sh не вызывается в .githooks/ или .github/workflows/», rc=1. Ожидаемо: шаг CI заводит оркестратор после реализации. По прецеденту 186 (`registry/ci-steps.tsv:307`) шаг обязан назвать guard буквально (С-5).
- Обоснование ПРОВОДКА-ЭНФОРСМЕНТ («инструмент чтения норм поведения ролей не вводит») честное: поведенческой нормы предмет не вводит.

## Паразитная сложность (контракт 050)

- `scripts/zamer_svyazki.sh`:
  1. точка входа, которую контракт называет по имени, и guard ПРОВОДКИ;
  2. состояния нет, env не читает, только выставляет `PYTHONDONTWRITEBYTECODE=1`, чтобы ничего не писать;
  3. меняется 1 файл;
  4. интерфейс — сквозная передача argv; мелок по построению, этого требует контракт;
  5. потребители — батарея и будущий шаг CI.

  **ESSENTIAL.**
- `scripts/zamer_svyazki.py`:
  1. инварианты 1–8;
  2. состояние явное: argv → stdout/stderr/rc, файлов состояния нет;
  3. правка семантики меры меняет эталон, оракул и реализацию вместе (3 файла). Так устроен контракт, дифф это число не увеличил;
  4. пять флагов — ровно флаги контракта; одно лишнее имя отказа `НЕТ_РЕПО` (rc 2) есть и у эталона;
  5. потребитель — батарея. Грамматику `СУД:` разбирает заново, как и эталон: контракт требует «ту же грамматику», общего модуля не требует.

  **ESSENTIAL.**
- `docs/190-zamer-svyazki.md`:
  1. документ замера требует контракт;
  2. состояния нет;
  3. канон заголовка живёт в 3 местах (реализация, документ, контракт), их держит побайтовая клетка;
  4. неприменимо;
  5. потребитель — клетка `dokument-kanon`.

  **ESSENTIAL.**

ACCIDENTAL-находок нет.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` не объявляет документа архитектуры или стандарта кода. `grep -n 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` пуст (rc 1), `ls docs/ARCHITECTURE.md docs/CODING-STANDARDS.md` → No such file. Режим проекта (sourceCanon, 996) к предмету не относится. Мобильного экрана нет.

## Находки

**Б-1 — БЛОК (implementer; инвариант 8, достижимое состояние).**
- Где: `scripts/zamer_svyazki.py:280-292`. Строка декодируется в `for line in stream` вне `try`. `record.get`/`message.get` вызываются без проверки, что значение — объект.
- Что выходит: не-UTF-8 строка (обрыв внутри многобайтового символа), JSON-строка, которая не является объектом, и `"message":null` дают traceback и rc 1, то есть ложное имя `ПУСТАЯ_ВЫБОРКА`. Инвариант 8 требует пропустить такую строку без падения. Документ заявляет то же самое, но обещание не выполняется.
- Почему это достижимо: оборванный журнал `Crit175R2.jsonl` уже лежит в живом корне, а кириллица в сырых байтах есть во всех 3341 журналах.
- Простая форма, которая проходит те же 22 клетки: читать журнал байтами и звать `json.loads` в `try` (`UnicodeDecodeError` ⊂ `ValueError`); строку, которая не является объектом, и `message`, который не является объектом, пропускать.
- Эталон падает так же, поэтому батарея этого не видит. Правка реализации равенства с оракулом не нарушает.

**Б-2 — БЛОК (implementer; заявленное ≠ сделанному).**
- Где: `docs/190-zamer-svyazki.md`, §«Сверка с проходом 16».
- Что заявлено: одна команда на неназванном «пине до v+1-серий» воспроизводит 27/16/11/22.
- Чему противоречит: замороженной строке контракта «полная строка „27 вызовов“ одной командой на живом дереве недостижима по построению». Моя мера на пине `7c2d206c33b1` даёт 37/16/13/22 при 8 обрывах, на пине `1cc2fa4baf51` — 10/4/6/6.
- Простая форма: заменить абзац границей контракта — живая сверка по строкам 170, 182 и 185, 22 блока по `grep -c '^БЛОКИРУЕТ'`, 27 одной командой недостижимо.

**С-1 — совет (architect, семья 190).** Мутации M5 (fence) и M1b (фильтр `роль=critic` в HANDOFF) переживают батарею. Нужны два мира:
- (а) чужая fenced-цитата СУД стоит в вердикте ДО его учётной строки, и fenced СУД есть в HANDOFF;
- (б) СУД-строка ревьюера в HANDOFF несёт кортеж, которого нет среди вызовов критика.

**С-2 — совет (architect/владелец).** Окно `--s`/`--do` сравнивается строкой, а не секундами. Дата без времени отрезает сутки, смещение `±hh:mm` не учитывается. Эталон ведёт себя так же. Разбирать через `datetime.fromisoformat` либо отказывать rc 2 на ином формате.

**С-3 — вопрос владельцу.** Вердикт `ESCALATE` с учётной СУД-строкой (`contracts-157-v3-eskalacija.md`) считается «обрывом», а контракт этот исход не определяет. Сейчас не наблюдается: 157 стоит `не-установлен`.

**С-4 — совет (implementer).** В документе «первый трёхзначный кластер», а по контракту и коду — «цифровой кластер длины ≥3».

**С-5 — совет (оркестратор).** Шаг `check:zamer-svyazki-190-family-selftest` должен буквально вызывать `scripts/zamer_svyazki.sh` (прецедент 186). Иначе `check_provodka` останется в rc 1.

**Н-1 — наблюдение.** Реализация — построчная перекладка эталона, поэтому равенство с ним не независимо. Независимость дают оракул `dannye/` и мой ручной мини-мир (§5).

**Н-2 — наблюдение.** С `--predmety` журнальные столбцы ИТОГО покрывают весь architect/critic окна, по инварианту 6.

**Н-3 — наблюдение.** shellcheck на станции нет, выполнен только `bash -n`.

## Закрытие

Повторный суд нужен scoped, по Б-1 и Б-2. Достаточно:
- мини-мира битого журнала (badutf8, scalar, nullmsg) → rc 0, строка пропущена;
- текста раздела документа;
- безфлагового прогона батареи 22/22.
