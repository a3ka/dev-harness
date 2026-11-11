accept
OBJECT=8255f4cf770d92bbda43f9201f84ebf51fb1477d
КЛАСС=обычный
СУД: repo=a3ka/dev-harness; предмет=190; фаза=реализация; роль=reviewer; вызов=2 (scoped-исправительный); модель-план=anthropic/claude-opus-5-5; сессия=Rev190v2 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; SHA=8255f4cf770d92bbda43f9201f84ebf51fb1477d; контракт=frozen/contracts/190/1; предыдущий=verdicts/review/contracts-190-impl-v1.md; исключение=нет

# Вердикт reviewer — 190 «замер связки» (Л6), реализация, вызов 2 (scoped-исправительный)

**accept.** Блоки Б-1 и Б-2 вызова 1 закрыты исполнением. Новых блоков дельта не породила.

Находки в reslop-формате лежат в `.review/2026-11-11-20.md` клона `/tmp/dev-harness-verify/Rev190v2/repo`, `status: ready`. В коммит файл не входит.

Что в находках:
- советы С-6…С-8 — все про недостижимые на живых данных входы;
- наблюдения Н-4…Н-7;
- статус советов вызова 1: С-1 и С-4 закрыты, С-2 оставлен сознательно, С-3 и С-5 без изменений.

Scope — только дельта `a7acb1d38..8255f4cf7`. «Чисто» вызова 1 вне Б-1/Б-2 остаётся в силе.

**Клон.** `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev190v2/repo`, свой `.git`.
- Первый checkout упал с ENOSPC: на `/` оставалось 500M, место освобождали чужие процессы. Я повторил `git restore`/`git reset --hard` в своём клоне, после чего `git status --short | wc -l` → 0.
- Worktree клона:
  - `impl` — OBJECT с одноразовым наложением `git checkout origin/wip/190/architect -- fixtures/workshop_project/zamer_svyazki_190/`, без коммита;
  - `implbare` — OBJECT без наложения;
  - `v1` — a7acb1d38 с тем же наложением;
  - `main` — origin/main 86bb62e7 с тем же наложением;
  - `pin1` — `1cc2fa4baf51`;
  - `pin7` — `7c2d206c33b1`.
- Живые журналы станции только читались.

## Кандидат и область правки

```
$ git rev-parse origin/wip/190/implementer origin/wip/190/architect origin/main
8255f4cf770d92bbda43f9201f84ebf51fb1477d
5d5e3a4d4e580d903cf1978adcaebb1714a041a9
86bb62e75d965d5c742751642a4b5e46061764f9
$ git merge-base --is-ancestor a7acb1d38 8255f4cf7 && echo anc-ok
anc-ok
$ git log --format='%h %an <%ae> %s' a7acb1d38..8255f4cf7
8255f4cf implementer <implementer@dev-harness.local> 190 fix: неконсистентная строка журнала пропускается без падения (Б-1) + документ против замороженного контракта (Б-2, С-4)
$ git diff --stat a7acb1d38 8255f4cf7
 docs/190-zamer-svyazki.md | 59 ++++++++++++++++++++++++++++++++++++-----------
 scripts/zamer_svyazki.py  | 27 +++++++++++++++++++-----
 scripts/zamer_svyazki.sh  |  2 +-
 3 files changed, 67 insertions(+), 21 deletions(-)
$ git diff --stat frozen/contracts/190/1 HEAD -- contracts/190-zamer-svyazki.md          (в impl)
(пусто) rc=0
$ git diff --stat frozen/contracts/190/1 origin/wip/190/architect -- contracts/190-zamer-svyazki.md
(пусто) rc=0
```

Дельта — ровно три файла ЗОНЫ implementer, один коммит под identity implementer со ссылкой на предмет. Фикстуры, контракт и нормы не тронуты.

## 1. Б-1 закрыт исполнением на моём мини-мире

**Чистый мир.** Реестр 401/402, два вердикта 401 с учётными СУД (FAIL с блоком, accept). Журналы `Arch401a` (6 строк с кириллицей, правка, мульти-вызов, user-запись) и `Crit401a` (2 записи).

**Битый мир.** Тот же, но в `Arch401a` вставлена одна битая строка. Итоговая проба кладёт все битые строки сразу в оба журнала и добавляет последней строкой обрыв посреди кириллицы без `\n` — так выглядит живой случай `Crit175R2.jsonl`.

Сравнение — `(rc, stdout, stderr)` побайтово против чистого мира. Зонд `mini/probe.py` (одноразовый, вне дерева).

```
$ python3 mini/probe.py wt/impl/scripts/zamer_svyazki.sh mini/w-impl
== clean rc=0
предмет	вызовы	fail	accept	обрывы	исход	блоки	…
401	2	1	1	0	accept	1	1	0	0	0	0	0	К-03:1	0	1000	4	1500	2	75.0%	70.0%
ИТОГО	2	1	1	0	-	1	1	0	0	0	0	0	-	-	1000	4	1500	2	75.0%	70.0%
МЕР	среднее_вызовов=2.0	accept_do_vtorogo=1/1	chetyre_plus=0
просмотрено: записей_журналов=6
BROKEN utf8-cut-mid         rc=0 EQUAL
BROKEN list                 rc=0 EQUAL        ([1,2])
BROKEN int                  rc=0 EQUAL        (42)
BROKEN string               rc=0 EQUAL        ("текст")
BROKEN null                 rc=0 EQUAL
BROKEN message-null         rc=0 EQUAL
BROKEN message-list         rc=0 EQUAL        ("message":[1,2])
BROKEN message-str          rc=0 EQUAL
BROKEN usage-null           rc=0 EQUAL
BROKEN tokens-str-abc       rc=0 EQUAL
BROKEN tokens-list          rc=0 EQUAL
BROKEN tokens-nan           rc=0 EQUAL
BROKEN content-str          rc=0 EQUAL
BROKEN content-dict         rc=0 EQUAL
BROKEN content-null         rc=0 EQUAL
BROKEN empty                rc=0 EQUAL
BROKEN spaces               rc=0 EQUAL
BROKEN bom-nonmessage       rc=0 EQUAL
BROKEN bom-only             rc=0 EQUAL
BROKEN lone-cont-bytes      rc=0 EQUAL
BROKEN nul-bytes            rc=0 EQUAL
BROKEN ALL+tail-no-NL       rc=0 EQUAL
CRLF   whole-journal-crlf   rc=0 EQUAL
AMBIG  tokens-null          rc=0 DIFF | 401 … 1000	5	1500	2	60.0%	70.0%
AMBIG  tokens-str-num       rc=0 DIFF | 401 … 6000	5	1500	2	60.0%	11.7%
AMBIG  tokens-bool          rc=0 DIFF | 401 … 1001	5	1500	2	60.0%	69.9%
AMBIG  tokens-float         rc=0 DIFF | 401 … 1012	5	1500	2	60.0%	69.2%
AMBIG  bom-assistant        rc=0 DIFF | 401 … 1777	5	1500	2	80.0%	39.4%
CRASH  tokens-1e400         rc=1 DIFF | OverflowError: cannot convert float infinity to integer
CRASH  tokens-Infinity      rc=1 DIFF | OverflowError: cannot convert float infinity to integer
CRASH  deep-nesting         rc=1 DIFF | RecursionError: maximum recursion depth exceeded while decoding a JSON array from a unicode string
```

Тот же зонд против v1 (a7acb1d38) различает до и после. Падают 13 классов из 21 (`utf8-cut-mid`, `list`, `int`, `string`, `null`, `message-null/-list/-str`, `tokens-str-abc/-list/-nan`, `content-null`, `lone-cont-bytes`), ещё 2 (`content-str/-dict`) дают неверный счёт, падает и сумма:

```
BROKEN utf8-cut-mid  rc=1 DIFF | UnicodeDecodeError: 'utf-8' codec can't decode byte 0xd0 in position 428: invalid continuation byte
BROKEN list          rc=1 DIFF | AttributeError: 'list' object has no attribute 'get'
BROKEN message-null  rc=1 DIFF | AttributeError: 'NoneType' object has no attribute 'get'
BROKEN content-null  rc=1 DIFF | TypeError: 'NoneType' object is not iterable
BROKEN content-str   rc=0 DIFF | 401 … 1007	5	1500	2	60.0%	69.5%
BROKEN ALL+tail-no-NL rc=1 DIFF … UnicodeDecodeError: 'utf-8' codec can't decode byte 0xd0 in position 672
```

Итог по Б-1:
- Все классы задания дают rc 0, вывод равен чистому миру, stderr `просмотрено: записей_журналов=6` прежний. Это обрыв посреди кириллицы, `[1,2]`, `42`, `"текст"`, `"message":null`, `"message":[1,2]`, `totalTokens` нечисловой строкой, `content` не списком, пустая строка, BOM, `\r\n`.
- Блок закрыт.

Что осталось за пределами блока (полный разбор записи, как просило задание):
- **AMBIG.** `totalTokens: null`/`"5000"`/`true`/`12.9` считаются вызовом. Эталон и v1 ведут себя так же. Для `null` это согласуется с инвариантом 6: вызов — запись с `usage`. Формулировка документа шире кода (С-7).
- **BOM + валидная запись.** Теперь учитывается (Н-5).
- **CRASH.** Три валидных JSON-входа: `1e400`, `Infinity`, вложенность 10⁵. Они по-прежнему дают traceback rc 1 (С-6).

Достижимость. Перепись живого корня c907157c, только чтение, зонд `mini/scan_live.py`:

```
content:list=240646
files=3350
has_Infinity_or_NaN_token_text=1309      (слова в тексте сообщений, не числа)
lines=850477
no_trailing_nl=1
nonjson=1
totalTokens:int=240646
```

На живых данных нет ни одного входа классов AMBIG/CRASH: не-int `totalTokens` 0, recursion 0, BOM 0, CRLF 0, не-объектов 0. Порог достижимого состояния не пройден. Поэтому это советы, а не блоки.

Чтение файлов дерева. Зонд `mini/repo_bytes.py`:

```
main: files=671 invalid_utf8=0 []
pin1: files=632 invalid_utf8=0 []
pin7: files=654 invalid_utf8=0 []
impl: files=668 invalid_utf8=0 []
bad-verdict rc=1 UnicodeDecodeError: 'utf-8' codec can't decode byte 0xd0 in position 5: invalid continuation byte
bad-handoff rc=1 UnicodeDecodeError: …
bad-registry rc=1 UnicodeDecodeError: …
```

Это вне инварианта 8, который говорит о строках журнала. Поведение было и до дельты, эталон такой же, на деревьях недостижимо → Н-4, вопрос владельцу.

## 2. Б-2 закрыт: документ против замороженного контракта

Раздел §«Сверка с проходом 16» (`docs/190-zamer-svyazki.md`):
- открывается границей живого среза почти дословно по контракту (§Приёмка «Граница живого среза»);
- заменяет «27 вызовов одной командой» живой сверкой по строкам 170/182/185 и числами пинов с названной командой.

Обещаний сверх контракта нет. Из прежнего текста убрано «средний контекст 117 тыс. совпадает»: документ теперь прямо говорит, что `totalTokens` ≠ input+cacheRead.

Перемер командой, живые журналы c907157c, только чтение:

```
$ bash wt/impl/scripts/zamer_svyazki.sh --repo wt/pin1 --zhurnaly <c907157c>/sessions --s 2026-11-09T00:00:00Z --predmety '170'
170	4	2	2	0	accept	2	0	0	0	0	0	2	-	2	53129021	544	44828561	459	92.1%	18.2%
просмотрено: записей_журналов=19562   rc=0
$ … --repo wt/pin7 … --predmety '182|185'
182	2	1	1	0	accept	1	…
185	2	1	1	0	accept	2	…
ИТОГО	4	2	2	0	-	3	…   rc=0
$ … --repo wt/pin1 --s 2026-11-09T00:00:00Z --do 2026-11-10T14:57:00Z --predmety '16[2]|17[028]|18[2-8]|185|184'
ИТОГО	10	4	6	0	-	6	0	0	0	0	0	6	-	-	194146066	2059	92356981	1185	92.1%	11.0%   rc=0
$ … --repo wt/pin7 (та же команда)
ИТОГО	37	16	13	8	-	22	0	0	0	0	0	22	-	-	194146066	2059	92356981	1185	92.1%	11.0%   rc=0
```

Совпадения с документом:
- строка 170 — `4 2 2 0 accept 2`, совпадает с контрактом и документом;
- 182/185 и их ИТОГО 4/2/2/3 совпадают;
- пины: 10/4/6/0/6 и 37/16/13/8/22 — точно числа документа;
- 92.1% и 11.0% «в ИТОГО обеих пинов» — точно.

Своя мера, другой командой (B2d):

```
# 16 FAIL / 22 блока: head+grep по файлам контракта на pin7
files=28 FAIL=16 blocks_in_FAIL=22
# 37 кортежей: grep первой СУД вердиктов + СУД роль=critic HANDOFF → perl (предмет|серия|номер) → sort -u
unique_tuples=37 main_series=21
```

Заголовок 21 столбца. Хэши строк — контракт, документ, эталон документа и первая строка вывода инструмента:

```
contract b5f70dbf6d926d7e99e5a56edf4c8d1efe05b74b7c6b35dbba351e7badc1cfad
doc      b5f70dbf6d926d7e99e5a56edf4c8d1efe05b74b7c6b35dbba351e7badc1cfad
modeldoc b5f70dbf6d926d7e99e5a56edf4c8d1efe05b74b7c6b35dbba351e7badc1cfad
tool     b5f70dbf6d926d7e99e5a56edf4c8d1efe05b74b7c6b35dbba351e7badc1cfad
cols=21 (строка в документе одна)
```

Документ ≠ эталон документа architect дословно (`diff` rc 1). Расхождения — уточнения implementer, проверенные по коду:
- `--s` включительно, `--do` исключительно, добавление `Z`;
- имя `НЕТ_РЕПО`;
- `-` для исхода без основной серии;
- выделенная пара «170 / 182|185».

Новых мер и обещаний вне контракта нет; утверждение «любого вида» шире кода — С-6/С-7. С-4 закрыт: «цифровой кластер длины ≥3».

## 3. Регресс дельты

Батарея (impl = OBJECT + наложение семьи architect):

```
$ bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
GREEN mir-a-tablica … GREEN bitaja-stroka-utf8 … GREEN bitaja-stroka-ne-obekt … GREEN bitaja-stroka-message
… GREEN bitaja-stroka-chistyj-mir … GREEN tsitata-do-uchetnoj … GREEN handoff-tolko-critic … GREEN dokument-kanon   (28 строк GREEN)
ИТОГ 190: клеток 28, зелёных 28, красных 0; СВЯЗИ 0, поймано 0, жив 0
rc=0
$ … --model
ИТОГ 190: клеток 28, зелёных 28, красных 0; СВЯЗИ 0, поймано 0, жив 0
rc=0
$ … --stabs
STAB stab_bajty_tekstom.py caught @ bitaja-stroka-utf8
STAB stab_bez_fences.py caught @ tsitata-do-uchetnoj
STAB stab_bez_filtra_strok.py caught @ mir-a-tablica
STAB stab_bez_okna.py caught @ okno-seansov
STAB stab_bez_roli.py caught @ handoff-tolko-critic
STAB stab_bez_sortirovki.py caught @ mir-a-tablica
STAB stab_bez_stderr.py caught @ stderr-prosmotreno
STAB stab_bloki_nol_bez_metok.py caught @ bloki-metki
STAB stab_hvost_posle_pervoj_pravki.py caught @ odinochnye-hvost
STAB stab_ignor_do.py caught @ okno-do
STAB stab_nol_ne_ustanovlen.py caught @ verdikt-bez-suda
STAB stab_odinochnye_vse_roli.py caught @ odinochnye-hvost
STAB stab_poteral_obryv.py caught @ obryv-schitaetsja
STAB stab_propuskaet_fajl.py caught @ bitaja-stroka-message
STAB stab_schet_po_fajlam.py caught @ mir-b-bez-obryva
STAB stab_schet_tsitat.py caught @ tsitata-sud
STAB stab_slovoforma_potera.py caught @ forma-slovo-ne-ust
STAB stab_tokeny_ne_toj_roli.py caught @ tokeny-rolevye
STAB stab_vyzov_slesh_strog.py caught @ forma-vyzova
ИТОГ 190: клеток 28, зелёных 28, красных 0; СВЯЗИ 19, поймано 19, жив 0
rc=0
$ … --oracle-tamper
ORACLE_OK
rc=0
$ reslop t -- bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
exit: 0
```

Красное до:

```
# main (origin/main 86bb62e7 + наложение семьи; ls scripts/zamer_svyazki* → No such file or directory)
SUBJECT_ABSENT: scripts/zamer_svyazki.* не реализован — все клетки красны
ИТОГ 190: клеток 28, зелёных 0, красных 28
rc=1            (строк «RED …: SUBJECT_ABSENT» — 28)
# v1 (a7acb1d38 + наложение семьи) — заявление implementer «красны ровно три» подтверждено
RED bitaja-stroka-utf8: rc=1 stderr='…UnicodeDecodeError: 'utf-8' codec can't decode byte 0xd1 in position 73: invalid continuation byte\n'
RED bitaja-stroka-ne-obekt: rc=1 stderr='…AttributeError: 'list' object has no attribute 'get'\n'
RED bitaja-stroka-message: rc=1 stderr="…AttributeError: 'NoneType' object has no attribute 'get'\n"
ИТОГ 190: клеток 28, зелёных 25, красных 3; СВЯЗИ 0, поймано 0, жив 0
rc=1
# implbare (OBJECT без наложения, своя семья кончика)
ИТОГ 190: клеток 22, зелёных 22, красных 0; СВЯЗИ 0, поймано 0, жив 0
rc=0
```

Мутанты реализации. Файл `scripts/zamer_svyazki.py` в impl, зонды `mini/mutate.py` и `mini/mutate_c1.py`, после каждого — восстановление:

```
M1 текстом (без байтов)              rc=1 ИТОГ 190: клеток 28, зелёных 27, красных 1; … | RED bitaja-stroka-utf8
M2 без isinstance(record, dict)      rc=1 ИТОГ 190: клеток 28, зелёных 27, красных 1; … | RED bitaja-stroka-ne-obekt
M3 без isinstance(message, dict)     rc=1 ИТОГ 190: клеток 28, зелёных 27, красных 1; … | RED bitaja-stroka-message
M4 без try вокруг int(totalTokens)   rc=1 ИТОГ 190: клеток 28, зелёных 27, красных 1; … | RED bitaja-stroka-message
M5 без проверки content-список       rc=0 ИТОГ 190: клеток 28, зелёных 28, красных 0; … | нет красных — ВЫЖИЛ   (С-8)
restored: True
M5(v1) без переключателя fence             rc=1 … | RED tsitata-do-uchetnoj
M1b(v1) без фильтра роль=critic (HANDOFF)  rc=1 … | RED handoff-tolko-critic
restored: True
$ git status --porcelain | grep -v ' fixtures/'     → пусто (rc=1): кроме наложения дерево чистое
```

С-1 вызова 1 закрыт: оба прежних выживших теперь краснят, стабы `stab_bez_fences`/`stab_bez_roli` пойманы.

Синтаксис, режимы файлов, живая строка:

```
$ bash -n scripts/zamer_svyazki.sh                                   → bash -n rc=0
$ python3 -c "import py_compile; py_compile.compile('scripts/zamer_svyazki.py', cfile='…/mini/zs.pyc', doraise=True)"  → py_compile rc=0
$ git ls-files -s scripts/zamer_svyazki.sh scripts/zamer_svyazki.py docs/190-zamer-svyazki.md
100644 413dfc67… docs/190-zamer-svyazki.md
100755 1d1c9879… scripts/zamer_svyazki.py
100755 5072a39d… scripts/zamer_svyazki.sh
```

Строка 170 (`--predmety '170'`, пин 1cc2fa4baf51) = `170 4 2 2 0 accept 2 … 53129021 544 44828561 459 92.1% 18.2%`. Это побайтово та же строка, что в вердикте вызова 1.

Равенство v1 и OBJECT на живых данных при закрытом окне (stdout+stderr+rc):

```
SAME v1/impl pin1 [--s 2026-11-09T00:00:00Z --do 2026-11-10T14:57:00Z] lines=177 просмотрено: записей_журналов=6949 rc=0
SAME v1/impl pin7 [--s 2026-11-09T00:00:00Z --do 2026-11-10T14:57:00Z] lines=183 просмотрено: записей_журналов=6949 rc=0
SAME v1/impl pin1 [--do 2026-11-10T14:57:00Z] lines=183 просмотрено: записей_журналов=191118 rc=0
SAME v1/impl pin7 [--do 2026-11-10T14:57:00Z] lines=189 просмотрено: записей_журналов=191118 rc=0
```

Счёт просмотренного дельтой не изменён (те же 6949 и 191118).

Инструмент только читает. `grep 'open\(|write|mkdir|unlink|rmtree|subprocess|import os|os\.|rename|touch'` по `scripts/zamer_svyazki.{py,sh}` находит:
- единственный `open(path, 'rb')` (стр. 288);
- слово `write` в докстринге и в кортеже имён инструментов `('edit', 'write')` (стр. 309).

Обёртка — `PYTHONDONTWRITEBYTECODE=1 exec python3 …`. Мой артефакт `.log/` от reslop удалён.

## Атомарность, норма, неподгонка

- Дельта — один коммит `8255f4cf` (author/committer implementer) со ссылкой на предмет 190.
- `fixtures/`, `contracts/`, `frozen/`, `roles/` коммит не трогает: diff --stat — 3 файла зоны.
- Красные клетки и стабы написал architect (`5d5e3a4d`, author architect), а не автор реализации. Проверка под код не подогнана.
- Правка `measure_agent` повторяет правку эталона `model/zamer_model.py:244-268` (Н-1 вызова 1: равенство с эталоном не независимо). Независимость дают оракул семьи и мой мини-мир §1.

## ПРОВОДКА (контракт 038)

Дельта проводку не трогает. guard `scripts/zamer_svyazki.sh` существует. Подключение шага CI — у оркестратора (С-5 вызова 1, без изменений). Обоснование ПРОВОДКА-ЭНФОРСМЕНТ по-прежнему честное.

## Паразитная сложность (контракт 050)

- **`measure_agent`: четыре новые ветви-пропуска** (не-объект записи, не-объект `message`, `try` вокруг `int(totalTokens)`, `content` не список) и чтение байтами.
  1. Инвариант 8 и таблица rc: rc 1 только `ПУСТАЯ_ВЫБОРКА`.
  2. Нового состояния нет: строка либо даёт вклад, либо пропущена, счёт просмотренного прежний.
  3. Число файлов, меняющихся вместе, не выросло: реализация + эталон + оракул, как и было.
  4. Интерфейс не изменился (флаги, rc, env те же), работа выросла — модуль глубже.
  5. Потребители — клетки `bitaja-stroka-*` и мутанты M1–M4. Каждая ветвь, кроме `content`, держится своей клеткой (С-8). Без этой ветви `content:null` даёт traceback v1. Более простой формы, которая проходит те же строки, нет.

  **ESSENTIAL.**
- **`docs/190-zamer-svyazki.md`, §«Сверка с проходом 16» и абзац инварианта 8.**
  1. Документ замера, граница живого среза, приёмка пинов.
  2. Состояния нет.
  3. Канон заголовка — по-прежнему 3 места под побайтовой клеткой; числа пинов — команда в тексте.
  4. Неприменимо.
  5. Потребители — `dokument-kanon` и суд.

  **ESSENTIAL.**
- **Шапки `scripts/zamer_svyazki.{sh,py}`** (одна строка «28 клеток»). Состояния нет, потребителя нет, это комментарий. Вне счёта; точность — Н-7.

ACCIDENTAL-находок нет.

## СВЕРКА-СТАНДАРТОВ

Неприменимо:
- `grep -n 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` → пусто, rc=1;
- `ls docs/ARCHITECTURE.md docs/CODING-STANDARDS.md` → No such file or directory.

`AGENTS.md` документа архитектуры и стандарта кода не объявляет. sourceCanon (996) к предмету не относится, мобильного экрана нет.

## Находки (все — не блок)

- **С-6 — совет (implementer + architect; недостижимо).** Обещание «любого вида … без падения» шире кода.
  - Где: `scripts/zamer_svyazki.py:301-304` и `:290-293`.
  - Что выходит: `totalTokens` `1e400`/`Infinity` → `OverflowError`, вложенность 10⁵ → `RecursionError`, оба rc 1 с traceback.
  - Почему не блок: на живых данных 0 таких входов.
  - Простая форма: расширить `except` (`OverflowError`, `RecursionError`) либо сузить формулировку; клетка — у architect.
- **С-7 — совет (implementer + architect; недостижимо).** Утверждение «вложенное поле не нужного типа … таблица равна миру без неё» неверно для `totalTokens` `null`/`"5000"`/`true`/`12.9`: такая запись учитывается как вызов. По инварианту 6 это согласовано, расходится формулировка.
- **С-8 — совет (architect, семья 190).** Ветвь «`content` — список» не держится ни одной клеткой: мутант M5 выживает, 28/28.
- **Н-4 — вопрос владельцу.** Невалидный UTF-8 в файлах дерева → traceback rc 1. Вне инварианта 8, было и до дельты, на деревьях 0.
- **Н-5.** BOM + валидная запись теперь учитывается. Это верно.
- **Н-6 — оркестратору/architect.** Числа §Приёмка замороженного контракта (22/22, СВЯЗИ 15) против семьи architect (28/28, 19/19) — надмножество. Сверку нужно согласовать при слиянии семьи.
- **Н-7.** Шапка «28 клеток» верна только после слияния семьи architect: на кончике implementer 22.
- **Советы вызова 1.**
  - С-1 — закрыт;
  - С-2 — оставлен сознательно (кап; формат дат контракт не определяет);
  - С-3 — вопрос владельцу, без изменений;
  - С-4 — закрыт;
  - С-5 — оркестратору, без изменений.

## Закрытие

accept применим к OBJECT `8255f4cf770d92bbda43f9201f84ebf51fb1477d` при семье `wip/190/architect` `5d5e3a4d4e580d903cf1978adcaebb1714a041a9`.

Если поведение, критерий или граница риска изменятся после этого accept, он к изменённому кандидату не применяется. Если С-6 закроют расширением `except` (OverflowError/RecursionError), это изменение поведения: нужен scoped-повтор по §1 этим же мини-миром.
