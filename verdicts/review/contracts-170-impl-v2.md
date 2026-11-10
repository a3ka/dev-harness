accept
OBJECT=d4e57579fa6e81e226d54d9f74647d5bd6fecb36
сессия=Rev170ImplV2
СУД: repo=dev-harness; предмет=170; фаза=реализация; роль=reviewer; вызов=2 (scoped исправительный по Б-1/Б-2; бюджет §Быстрый-процесс: один полный + один scoped — исчерпан этим вызовом); модель-план=anthropic/claude-opus-5-5; сессия=Rev170ImplV2; модель-факт=anthropic/claude-opus-5-5; SHA=d4e57579fa6e81e226d54d9f74647d5bd6fecb36; предыдущий=Rev170ImplV1 (FAIL на f87b11904247af32c57f0e3ef149a5a6520c2dc6, `verdicts/review/contracts-170-impl-v1.md`, `.review/2026-11-10-95.md`); исключение=нет
Контракт: frozen/contracts/170/1, блоб контракта e6ac50a0374bebb21193dd67540f48edad6a5ec1. Блоб один и тот же на теге, на f71c4afa8, на OBJECT и на origin/main 46d0bb053. Семья `fixtures/workshop_project/arch_component_170/` на OBJECT и на origin/main — tree bf23244ec805bdd71d570b91317865a64dfd9967 (architect f71c4afa8, PR #670).
Кандидат: `wip/170/implementer` (PR #663), head = OBJECT. Два коммита implementer на f71c4afa8:
- a86f45ecd — реализация. Блоб `make_task.sh` 22a601af0dccc33925973c0261ce4ef6a4ab11cc — тот же, что на f87b119 в вызове 1, то есть перенос побайтовый;
- d4e57579f — исправление Б-1/Б-2. Блоб `make_task.sh` a7401231714dda3aa5eca44b1b5fa4869f28c58e.
--sud: строка трассы (`scripts/models_actual.sh --tsv --bind --all`): `reviewer	anthropic/claude-opus-5-5	allowed	Rev170ImplV2	d4e57579fa6e81e226d54d9f74647d5bd6fecb36`. Проверка `scripts/check_sud_model.sh --verdict reviewer --trace <файл со строкой> --object d4e57579… --session Rev170ImplV2 --root .` вернула `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 170, реализация, вызов 2 (scoped)

## Итог

accept. Блоки Б-1 и Б-2 вызова 1 на OBJECT закрыты. Это подтверждают замороженная семья (25/25) и мой собственный зонд с собственной мерой. Красное-до воспроизвёл сам на a86f45ecd (блоб = f87b119): красные ровно 6 новых клеток. Выхода за зону нет. Находки — `.review/2026-11-10-96.md`. Блоков нет; советы С-5, С-6 и С-2. С-6 — для владельца: в целевом проекте есть отложенный контракт 149 с ключом `Класс задачи:`, которого замороженное определение не покрывает (§3.1).

Прогоны шли в одноразовом клоне `/tmp/dev-harness-verify/review170v2/clone` (`ssh://git@github.com/a3ka/dev-harness.git`, detached HEAD = OBJECT, `git status --short` пуст). Красное-до — в worktree `/tmp/dev-harness-verify/review170v2/pre` на a86f45ecd. Push не делался. Полный `verify_antiplacebo` по заданию не гонялся.

Материализация: запись в чекаут сессии отказана дословно: `запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t75000c1ba/m/.review/2026-11-10-96.md не в null-allowlist (/tmp/dev-harness-verify/**, artifact://)`. Поэтому байты лежат под `/tmp/dev-harness-verify/review170b/verdicts/review/contracts-170-impl-v2.md` и `/tmp/dev-harness-verify/review170b/.review/2026-11-10-96.md`. Обхода не было.

## 1. Область правки (живьём)

```
git show OBJECT:contracts/170-…md | grep ЗОНА
45:ЗОНА implementer: scripts/make_task.sh
git diff --name-only origin/main...OBJECT        (merge-base f71c4afa8)
scripts/make_task.sh
git diff --stat f71c4afa8..OBJECT
 scripts/make_task.sh | 95 +++-  (93+, 2-)
git log --format='%h %an <%ae> | %cn' origin/main..OBJECT
d4e57579 implementer <implementer@dev-harness.local> | implementer
a86f45ec implementer <implementer@dev-harness.local> | implementer
```
Изменённые файлы ⊆ ЗОНЫ implementer. Двухточечный `origin/main..OBJECT` дополнительно показывает `fixtures/workshop_project/mob_ci_143/{matrix_v3.py,osi.md}`. Это коммит 46d0bb053, влитый в main после f71c4afa8 (предмет 143), в OBJECT его нет — к кандидату он не относится. Файлов семьи 170 и контракта implementer не трогал.

Атомарность: исправление сделано отдельным коммитом d4e57579f со ссылкой «170:», в нём только Б-1/Б-2 (+16/−5 в одном файле).

## 2. Красные клетки architect на OBJECT (сырой вывод)

### 2.1 `--repo <дерево OBJECT>`
```
170 required ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 legacy ok rc=0 stderr=''
170 document ok rc=0 stderr=''
170 brief_kind ok rc=0 stderr=''
170 architect_rules ok rc=0 stderr=''
170 critic_rules ok rc=0 stderr=''
170 arbiter_rules ok rc=0 stderr=''
170 implementer_plain ok rc=0 stderr=''
170 adversary_plain ok rc=0 stderr=''
170 reviewer_plain ok rc=0 stderr=''
170 multi_component ok rc=0 stderr=''
170 wrong_project ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../escape'
170 architecture_missing ok rc=1 stderr='ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/ в проекте: /tmp/dev-harness-verify/context-pack-095-arch-170-357148-3746/repo/architecture'
170 brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 implementer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 adversary_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 reviewer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42712 > 40000'
170 class_dot ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_parens ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_semicolon ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_risk_tail ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_upper_c ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 second_malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x' npm_calls=0
RC_REPO=0
```
25 ok из 25. Своя мера: `len(probe.CASES)` = 25, то есть 19 прежних и 6 новых.

### 2.2 `--model` и `--stabs`
`--model`: 25 ok, `RC_MODEL=0`. `--stabs` (строки ` ok rc=` контроля отфильтрованы, полностью в журнале прогона):
```
170 STAB requirement_removed caught @ required
170 STAB rules_omitted caught @ architect_rules
170 STAB rules_leaked caught @ implementer_plain
170 STAB only_first_id caught @ multi_component
170 STAB fixed_id caught @ multi_component
170 STAB map_removed caught @ architect_rules
170 STAB rules_removed caught @ architect_rules
170 STAB backend_only caught @ wrong_project
170 STAB architecture_guard_removed caught @ architecture_missing
170 STAB npm_failure_ignored caught @ brief_failure
170 STAB plain_npm_failure_ignored caught @ implementer_brief_failure
170 STAB exact_class_line caught @ class_dot
170 STAB locale_only_case caught @ class_upper_c
170 STAB validate_during_npm caught @ second_malformed_id
170 STAB brief_outside_budget caught @ brief_over_budget
RC_STABS=0
```
15 caught, 0 ZHIV. Своя мера — подсчёт записей кортежа `mutants` в исходнике `probe.py:256-296`: 15. Из них 3 новых, и все три бьют ровно в Б-1/Б-2: `exact_class_line`, `locale_only_case`, `validate_during_npm`. Стабы к ветвям привязаны architect-ом по коду модели (Н-39). Стабы мутируют модель, поэтому удостоверяют различающую силу клеток, а не код OBJECT. Код OBJECT удостоверяют §2.1 и §3.

### 2.3 Красное-до — подтвердил сам, а не только оркестратор
Блоб `scripts/make_task.sh` на a86f45ecd (22a601af) совпадает с f87b119. Прогон `--repo /tmp/dev-harness-verify/review170v2/pre` (a86f45ecd), только не-ok строки:
```
170 class_dot KRASNO rc=0 stderr=''
170 class_parens KRASNO rc=0 stderr=''
170 class_semicolon KRASNO rc=0 stderr=''
170 class_risk_tail KRASNO rc=0 stderr=''
170 class_upper_c KRASNO rc=0 stderr=''
170 second_malformed_id KRASNO rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x' npm_calls=1
RC_PRE=1
```
Красны ровно 6 клеток (19 прежних — ok), и это та шестёрка, которую назвал оркестратор. На OBJECT они зелёные (§2.1). Значит, исправление d4e57579f и есть причина перехода красное → зелёное.

## 3. Мой scoped-зонд

### 3.1 Б-1 — реальные строки класса (`/tmp/dev-harness-verify/review170v2/class_measure.py`)
Мера: по каждому `.md` дерева берётся первая строка `^КЛАСС ЗАДАЧИ:`. Её значение классифицируется первым словом из букв (Python, unicode, `lower()`), независимо от grep. Затем предикат OBJECT, извлечённый из `make_task.sh:887` побайтово (`grep -c` по исходнику → 1), прогоняется через `grep -Eq` по всему файлу под `LC_ALL=C.UTF-8` и `LC_ALL=C`.
```
== dev-harness@OBJECT: files with class line = 39
  class-word='документный' own_code=False files=1 pred_match[C.UTF-8]=0 pred_match[C]=0
  class-word='кодовый' own_code=True files=35 pred_match[C.UTF-8]=35 pred_match[C]=35
  class-word='смешанный' own_code=False files=3 pred_match[C.UTF-8]=0 pred_match[C]=0
  forms[кодовый]: ['КОДОВЫЙ (CI-инфрастру', …, 'КОДОВЫЙ — контракт, к', 'КОДОВЫЙ. id/CONTRACT/', 'КОДОВЫЙ. КЛАСС РИСКА:']
  forms[смешанный]: ['смешанный (кодовый отка', 'смешанный (контракт + к']
  mismatches(own vs pred, or multi-class-line): 0
== Complior-back@059815e: files with class line = 24
  class-word='кодовый' own_code=True files=23 pred_match[C.UTF-8]=23 pred_match[C]=23
  class-word='смешанный' own_code=False files=1 pred_match[C.UTF-8]=0 pred_match[C]=0
  forms[кодовый]: ['КОДОВЫЙ (Kind донорск', …, 'КОДОВЫЙ; один вертика', 'КОДОВЫЙ; слайс «регис']
  mismatches(own vs pred, or multi-class-line): 0
== Complior-back@origin/main: files with class line = 24        (43cae0a)
  class-word='кодовый' own_code=True files=23 pred_match[C.UTF-8]=23 pred_match[C]=23
  class-word='смешанный' own_code=False files=1 pred_match[C.UTF-8]=0 pred_match[C]=0
  mismatches(own vs pred, or multi-class-line): 0
```
Итог по строкам с ключом `КЛАСС ЗАДАЧИ:`: в харнессе 35/35 (у вызова 1 было 0/35), в Complior-back 23/23. Документный и смешанный, в том числе `смешанный (кодовый отказ…)` с «кодовый» в середине строки, — 0. Файлов с двумя разными строками класса нет, поэтому ложного срабатывания по второй строке тоже нет.

Сверка с числом вызова 1 для Complior-back (своя мера против меры ревьюера 1). Мера ревьюера 1, `git grep -l -iE '^КЛАСС ЗАДАЧИ: *кодовый' 059815e`, даёт 24 файла в `.harness/contracts` и 1 в `.harness/verdicts`, всего 25. Моя мера (ключ `КЛАСС ЗАДАЧИ:` с учётом регистра) даёт 23. Разница — один контракт `149-source-trace-gate.md:3`: `Класс задачи: КОДОВЫЙ. Направление: бэкенд. …`. Его ключ записан строчными буквами, и `-i` ревьюера 1 его захватывал. Поиск вариантов ключа (`git grep -i -P '^…класс\s+задачи\s*:'` минус точный `КЛАСС ЗАДАЧИ:`):
```
Complior-back 059815e и origin/main: 149 «Класс задачи: КОДОВЫЙ.»; 158 «Класс задачи: ДОКУМЕНТНЫЙ (doc-контракт)»
dev-harness OBJECT: 070, 071, 072, 078, 080 «Класс задачи: КОДОВЫЙ …»; 074 «Класс задачи: СМЕШАННЫЙ — …»
```
Исполнение на OBJECT (мир семьи, `class_line='Класс задачи: КОДОВЫЙ. Направление: бэкенд. Предмет: tools/check'`, без флага):
```
C.UTF-8 rc= 0 stdout_bytes= 1865 brief_in_pack= False stderr1=
C rc= 0 stdout_bytes= 1871 brief_in_pack= False stderr1=
```
В Complior-back есть `architecture/` (`git ls-tree 059815e architecture` → есть). Контракт 149 по HANDOFF проекта отложен («146/149/150/151 — прежние отложенные»), то есть может быть выдан. Для него OBJECT отдаст кодовое задание без брифа и без отказа. Класс находки — **С-6, совет, адресаты architect/owner, не блок**. Основание: замороженное определение §Предмет — «Кодовый предмет — отдельная строка `КЛАСС ЗАДАЧИ: кодовый`». Ключ в нём назван буквально заглавными, и строка `Класс задачи: …` под определение не подпадает. Значит, нарушенного замороженного обязательства нет, а распознавание иного написания ключа было бы расширением определения задним числом. Б-1 вызова 1 был о хвостах значения при буквальном ключе, причём первой такой формой была строка самого контракта 170. Эта часть закрыта полностью: 35/35 и 23/23. Два решения, каждое в одну правку, — за владельцем:
- нормализовать ключ в проектном контракте 149 (и, для единообразия, в 070…080 харнесса);
- в следующем freeze расширить определение до `(КЛАСС|Класс) (ЗАДАЧИ|задачи):` с клеткой на байт-копию строки 149.

Источник Complior-back. Клон `ssh://git@github.com/a3ka/Complior-back.git` отказан (`ERROR: Repository not found`), поэтому замер шёл read-only через `git show <ref>:` по существующему клону `/tmp/dev-harness-verify/rev168v2-1794281347`, на ref 059815e (база вызова 1) и origin/main 43cae0a.

### 3.2 Б-1 и Б-2 — исполнение публичного CLI OBJECT (`own_probe_v2.py`, мир — `probe.world(class_line=…)` семьи, оракул мой)
```
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: документальный': rc=0 npm_calls=0 stdout_bytes=1871 stderr1=''
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: ДОКУМЕНТНЫЙ (профиль architecture)': rc=0 …
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: смешанный (кодовый отказ + документ)': rc=0 …
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: СМЕШАННЫЙ; шаг 1 — инвентарь': rc=0 …
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: некодовый': rc=0 …
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: кодовыйX': rc=0 …
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: кодовый_слайс': rc=0 …
ok  NEG[C.UTF-8] 'КЛАСС ЗАДАЧИ: кодовые': rc=0 …
ok  NEG[C.UTF-8] 'Примечание: КЛАСС ЗАДАЧИ: кодовый': rc=0 …
ok  NEG[C.UTF-8] '> КЛАСС ЗАДАЧИ: кодовый': rc=0 …
ok  NEG[C] … (те же 10 форм): все rc=0, stderr1=''
ok  POS[C.UTF-8|C|en_US.UTF-8] 'КЛАСС ЗАДАЧИ: кодовый.' / 'КОДОВЫЙ — контракт, красная батарея' / 'КОДОВЫЙ (механизм проекта: HTTP-сценарии)' / 'КОДОВЫЙ. КЛАСС РИСКА: обычный' / 'КОДОВЫЙ; слайс «регистрация»' / ':\tкодовый' / ': кодовый':
    все 21: rc=1 npm_calls=0 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
ok  B2[architect] 'api.identity,../x': rc=1 npm_calls=0 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x'
ok  B2[implementer] 'api.identity,../x': rc=1 npm_calls=0 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x'
ok  B2[architect] 'api.identity,worker.events,bad/x': rc=1 npm_calls=0 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: bad/x'
ok  B2[implementer] 'api.identity,worker.events,bad/x': rc=1 npm_calls=0 …
ok  B2[architect] 'api.identity,-x': rc=1 npm_calls=0 … 'неконформный id: -x'
ok  B2[implementer] 'api.identity,-x': rc=1 npm_calls=0 …
ok  B2[architect] 'api.identity,a..b': rc=1 npm_calls=0 … 'неконформный id: a..b'
ok  B2[implementer] 'api.identity,a..b': rc=1 npm_calls=0 …
ok  B2[architect] 'api.identity, x': rc=1 npm_calls=0 … 'неконформный id:  x'
ok  B2[implementer] 'api.identity, x': rc=1 npm_calls=0 …
ok  B2[architect] 'worker.events,api.identity,.hidden': rc=1 npm_calls=0 … 'неконформный id: .hidden'
ok  B2[implementer] 'worker.events,api.identity,.hidden': rc=1 npm_calls=0 …
ok  B2-control two ids: rc=0 npm_calls=2 stdout_bytes=2118 stderr1=''
BAD=0
RC_OWN=0
```
Что показывает зонд:
- **Б-1.** Ни один негатив не требует флага ни в одной локали: документный, смешанный, «кодовый» в середине строки или слова, буква или `_` после значения. Все реальные формы с хвостом требуют флаг под `C`, `C.UTF-8` и `en_US.UTF-8`. Дефект `-i` под `LC_ALL=C` из вызова 1 устранён: в предикате теперь две явные формы регистра.
- **Б-2.** На `api.identity,../x` npm не вызван ни разу (`npm_calls=0`). То же для плохого ID на 2-й и 3-й позиции, для обеих групп ролей. Контроль `npm_calls=2` доказывает, что счётчик живой.

### 3.3 Регресс соседнего потребителя `make_task` (дёшево, по затронутой строке)
```
bash fixtures/_krasnye_095.sh → «ИТОГ стаб-пак 095: rc=0»; «ИТОГ 095: rc=0»; RC_095=0
ls -d architecture (корень харнесса) → нет
```
В харнессе нет `architecture/`, поэтому расширенный предикат не меняет выдачу для его собственных кодовых контрактов. Ветка `elif` начинается с `[ -d "$_arch_dir" ]`.

## 4. Обязательства в объёме повтора

| обязательство (frozen 170/1) | итог | доказательство |
|---|---|---|
| ARCH_COMPONENT_NET: task + кодовый предмет (строка класса в выбранном контракте) + architecture/, без флага → rc 1 | ok | §2.1 required, class_*; §3.1 35/35 и 23/23; §3.2 POS 21/21 |
| не-кодовый (документный/смешанный) предмет — без нового отказа | ok | §2.1 document; §3.1 0 совпадений на 1+3+1 файлах; §3.2 NEG 20/20 |
| неконформный список → `ОТКАЗ: ARCH_COMPONENT_ID:` до запуска npm | ok | §2.1 second_malformed_id npm_calls=0; §3.2 B2 12/12 npm_calls=0 |
| остальные обязательства (принятые вызовом 1) — не регрессировали | ok | §2.1: 19 прежних клеток ok |

## 5. Проверка не подогнана; норма; ПРОВОДКА

- Подгонки нет: в `origin/main...OBJECT` implementer не менял ни `contracts/`, ни `fixtures/`. Новые клетки — коммит architect f71c4afa8, в его же зоне. В диффе d4e57579f нет ни одного литерала из `CLASS_LINES`/`IDS`/`npm_stub`: правка — общая грамматика предиката и порядок проверки.
- Предикат реализации побайтово совпадает с предикатом `MODEL_BODY` (`probe.py`). Модель исправил architect, implementer привёл код к ней. Это не подгонка под оракул: мой зонд §3 ловит те же свойства на формах, которых в семье нет (`—`, `\t`, `.hidden`, позиция 3, `en_US.UTF-8`, все негативы).
- Нормативные документы (roles/, AGENTS.md, contracts/) не тронуты.
- ПРОВОДКА: guard тот же `red_arch_component_170.sh`. CI-шаг — коммит orchestrator-зоны a793cc936 (wip/170/orchestrator), PR после слияния реализации. До него `check_provodka` красный. Это блок done (Н-1), accept реализации он не блокирует.

## 6. Паразитная сложность (050) — по артефактам диффа d4e57579f

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| отдельный цикл проверки ID (`make_task.sh:847-854`) | §Предмет: «ARCH_COMPONENT_ID … до запуска npm» | явное (`_arch_rest`/`_arch_id`), без побочных эффектов | 1 | интерфейс не вырос: ни флагов, ни rc, ни env | клетка second_malformed_id | ESSENTIAL. Повтор трёх строк разбора с циклом npm — совет С-5 (более простая форма — разбор в массив один раз), не блок |
| предикат класса (`:887`), изменён | §Предмет: кодовый предмет — строка класса; ЗАЩИЩАЕТ п.1 | нет | 1 | одна строка, интерфейс не меняется | клетки class_* | ESSENTIAL (точная строка не проходит class_*) |

## 7. Стандарты / режим проекта

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` харнесса не объявляет ни `docs/ARCHITECTURE.md`, ни `docs/CODING-STANDARDS.md`, файлов нет (замер вызова 1; дифф повтора их не касается). Режим 996: `sourceCanon` не объявлен.

## Находки (подробно — `.review/2026-11-10-96.md`)

- **Б-1 (вызов 1) — ЗАКРЫТ** на OBJECT (§2.1, §3.1, §3.2).
- **Б-2 (вызов 1) — ЗАКРЫТ** на OBJECT (§2.1, §3.2).
- **С-5 (совет, implementer; 050).** Разбор списка ID продублирован в двух циклах (`:847-850`, `:861-864`). Не блок.
- **С-6 (совет, architect/owner; достижимо, но вне замороженного определения).** Строка класса с ключом строчными `Класс задачи: КОДОВЫЙ.` (Complior-back `149-source-trace-gate.md:3`, контракт отложен, `architecture/` в проекте есть) на OBJECT даёт rc 0 и пак без брифа (§3.1). Определение §Предмет называет ключ `КЛАСС ЗАДАЧИ:` буквально, поэтому это не блок. Решение — нормализовать ключ в контракте 149 либо расширить определение в следующем freeze клеткой на байт-копию.
- **С-2 (совет, перенос из вызова 1).** Сообщение a86f45ecd заявляет «manifest-выдачу», которой нет. Вне scoped-повтора, не блок.
- **С-1, С-3, С-4, О-1 (вызов 1)** по заданию вне объёма повтора. С-1 закрыт architect-ом новыми клетками (§2.1, §2.2).
- **Н-1 (orchestrator; блок done, не accept).** CI-проводка 170 — отдельный коммит orchestrator-зоны.
