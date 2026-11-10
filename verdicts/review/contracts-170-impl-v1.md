FAIL
OBJECT=f87b11904247af32c57f0e3ef149a5a6520c2dc6
сессия=Rev170ImplV1
СУД: repo=dev-harness; предмет=170; фаза=реализация; роль=reviewer; вызов=1 (полный); модель-план=anthropic/claude-opus-5-5; сессия=Rev170ImplV1; модель-факт=anthropic/claude-opus-5-5; SHA=f87b11904247af32c57f0e3ef149a5a6520c2dc6; предыдущий=нет (суд реализации 170 первый); исключение=нет
Контракт: frozen/contracts/170/1. Блоб контракта e6ac50a0374bebb21193dd67540f48edad6a5ec1. Он одинаков на теге, на базе e416e1fe0, на OBJECT и на main 2e35e3d11. Блобы семьи `fixtures/workshop_project/arch_component_170/` (red 3167cad5, probe 181ad378, npm_stub b540bbf5) на тех же четырёх точках тоже равны.
Кандидат: `wip/170/implementer`, PR #663, один коммит на e416e1fe0. Автор и коммиттер — implementer. Блоб `scripts/make_task.sh` на OBJECT — 22a601af0dccc33925973c0261ce4ef6a4ab11cc, tree 0defd50403118cc5e634ddeb6a9c2da61c4e06e2.
--sud: строка трассы (`scripts/models_actual.sh --tsv --bind --all`): `reviewer	anthropic/claude-opus-5-5	allowed	Rev170ImplV1	f87b11904247af32c57f0e3ef149a5a6520c2dc6`. Команда `scripts/check_sud_model.sh --verdict reviewer --trace <файл со строкой> --object f87b1190… --session Rev170ImplV1 --root .` вернула `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 170, реализация, вызов 1

## Итог

FAIL: два блока, оба на достижимых входах. Подробно — в `.review/2026-11-10-95.md`.

- **Б-1.** Предикат кодового предмета `^КЛАСС ЗАДАЧИ: кодовый$` (`scripts/make_task.sh:876`) не узнаёт ни одной реальной строки класса. В целевом проекте Complior-back из 25 кодовых контрактов совпадений 0. В харнессе из 35 — тоже 0, включая сам контракт 170 («КЛАСС ЗАДАЧИ: кодовый.»). Поэтому `ARCH_COMPONENT_NET` в реальном проекте не срабатывает никогда. Кодовое задание проекта с `architecture/` уходит без брифа молча (rc 0). Ровно от этого контракт обязан защищать: §Модель угроз, ЗАЩИЩАЕТ п.1.
- **Б-2.** Неконформный список ID отказывает только после того, как npm уже вызван для ID, стоящих перед плохим. Пример: `api.identity,../x` → 1 вызов npm, затем `ARCH_COMPONENT_ID`. Это нарушает §Предмет: «Неконформный список отказывает `ОТКАЗ: ARCH_COMPONENT_ID:` до запуска npm».

Для обоих блоков проверена более простая форма: она проходит все 19 клеток замороженной семьи и закрывает оба пробела (§4.3). Остальные обязательства выполнены, это подтверждают замеры ниже.

Прогоны шли в одноразовом клоне `/tmp/dev-harness-verify/review170/clone`: `git clone` worktree, detached HEAD = OBJECT, `git status --short` пуст. База для красного и побайтового сравнения — клон `/tmp/dev-harness-verify/review170/base` на e416e1fe0. Push не делался.

Материализация: запись канонического `verdicts/review/contracts-170-impl-v1.md` из судейской сессии отказана дословно: `запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tb5048d327/m/verdicts/review/contracts-170-impl-v1.md не в null-allowlist (/tmp/dev-harness-verify/**, artifact://)`. Байты положены под `/tmp/dev-harness-verify/review170/verdicts/review/contracts-170-impl-v1.md`, обхода не было.

## 1. Область правки

```
git diff --name-only e416e1fe0..f87b11904
scripts/make_task.sh
git log --format='%h %an' e416e1fe0..f87b11904
f87b11904 implementer
```
`ЗОНА implementer: scripts/make_task.sh` — изменённые файлы ⊆ зоны. Дифф: +82/−2, один файл. ПЕРЕСЕЧЕНИЯ:
- 095/103/136/161/165/166/169/996: hunk'и задевают только usage, разбор флага, trap (добавлено удаление `_NPM_ERR_FILE`), новый блок перед `TRACE_MAN` и одну строку `pack_body`;
- карта, manifest, бюджет, трасса, резолвер и state worktree не тронуты — это видно по диффу, а §3.4 D подтверждает побайтово.

## 2. Проверка не подогнана под реализацию

Блобы контракта и семьи на OBJECT равны тегу (см. шапку). В `e416e1fe0..OBJECT` нет коммитов в `contracts/` и `fixtures/`. Реализатор барьера не трогал.

Поиск подгонки. Число совпадений `api\.identity|worker\.events|777|arch-170|ARCH170|npm_stub|SENTINEL|context-pack-095|Complior` в диффе `make_task.sh` равно 0. Захардкоженных ID, путей фикстуры, оракулов и чтения стабов нет. ID проверяется по грамматике, npm берётся из PATH вызывающей стороны.

Подгонка всё же есть, но к модели, а не к оракулу. Блок реализации почти дословно повторяет `MODEL_BODY` из `probe.py:20-44`, и вместе с ним унаследованы оба дефекта: предикат Б-1 и проверка ID внутри цикла npm (Б-2). Отличия реализации от модели: stderr npm уходит в отдельный файл, а не `2>&1` в пак; отказ получает подсказку rc и stderr; перед брифом каждого ID стоит строка `COMPONENT: <id>`; признак задания флага (`ARCH_COMPONENT_SET`) отделён от значения.

## 3. Приёмка на OBJECT (сырой вывод)

### 3.1 `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo`
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
170 architecture_missing ok rc=1 stderr='ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/ в проекте: /tmp/dev-harness-verify/context-pack-095-arch-170-4180581-25896/repo/architecture'
170 brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 implementer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 adversary_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 reviewer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42717 > 40000'
RC=0
```
19 ok из 19. Число клеток проверено своей мерой: `len(probe.CASES)` = 19.

### 3.2 `--model` и `--stabs`
`--model`: те же 19 клеток ok на честной модели, `RC=0`. `--stabs`: снова 19 ok-клеток контроля, затем:
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
170 STAB brief_outside_budget caught @ brief_over_budget
RC=0
```
12 caught, 0 ZHIV. Своя мера — подсчёт кортежа `mutants` в `probe.py:236-264` по исходнику: 12 записей. Стабы мутируют модель, а не реализацию: они удостоверяют различающую силу клеток, но не код OBJECT.

### 3.3 Красное предъявлено — та же семья против базы e416e1fe0
`python3 probe.py --repo /tmp/dev-harness-verify/review170/base`:
```
170 required KRASNO rc=0 stderr=''
170 legacy ok rc=0 stderr=''
170 document ok rc=0 stderr=''
170 brief_kind ok rc=0 stderr=''
170 architect_rules KRASNO rc=1 stderr='usage: make_task.sh --repo R --role ROLE [--kind task|brief] [--contract NNN] [--task-file F] [--model-trace F] [--author-role R2] [--print-context]'
… (critic_rules, arbiter_rules, implementer_plain, adversary_plain, reviewer_plain, multi_component — KRASNO rc=1, тот же usage)
170 wrong_project KRASNO rc=0 stderr=''
… (malformed_id, architecture_missing, brief_failure, implementer_/adversary_/reviewer_brief_failure, brief_over_budget — KRASNO rc=1, тот же usage)
RC=1
```
Красные: `required`, `architect_rules`, `implementer_plain`, `multi_component` — названы критерием. Зелёные: `legacy`, `document`, `brief_kind` — критерий называет их «не краснеют». Совпадает со строкой приёмки.

### 3.4 Мой зонд против OBJECT (одноразовый `/tmp/dev-harness-verify/review170/own_probe.py`, мир — `probe.world()` семьи)
```
A no-flag arch/ class='КЛАСС ЗАДАЧИ: кодовый': rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
A no-flag arch/ class='КЛАСС ЗАДАЧИ: кодовый.': rc=0 stdout_bytes=1803 stderr1=''
A no-flag arch/ class='КЛАСС ЗАДАЧИ: КОДОВЫЙ (реализация)': rc=0 stdout_bytes=1809 stderr1=''
A no-flag arch/ class='КЛАСС ЗАДАЧИ: КОДОВЫЙ; один вертикальный слайс': rc=0 stdout_bytes=1803 stderr1=''
A no-flag arch/ class='КЛАСС ЗАДАЧИ: кодовый. КЛАСС РИСКА: обычный': rc=0 stdout_bytes=1809 stderr1=''
A2 КОДОВЫЙ LC_ALL=C: rc=0 stdout_bytes=1809 stderr1=''
A2 КОДОВЫЙ LC_ALL=C.UTF-8: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_NET: …'
A2 КОДОВЫЙ LC_ALL=en_US.UTF-8: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_NET: …'
B comp='api.identity,../x' npm_calls=1 ['--prefix …/repo/architecture run brief -- --compact --component api.identity']: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x'
B comp='api.identity,bad/x' npm_calls=1 ['… --compact --component api.identity']: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: bad/x'
B comp='api.identity,-x' npm_calls=1 ['… --compact --component api.identity']: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: -x'
B comp='' npm_calls=0 []: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: непустой список id через запятую: '
B comp='a..b' npm_calls=0 []: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: a..b'
B comp='_ok' npm_calls=1 ['… --compact --component _ok']: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_BRIEF_OTKAZ: _ok (npm rc=42): UNKNOWN_COMPONENT'
B2 flag-without-value: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_COMPONENT_ID: требуется значение: список id через запятую'
C empty-stdout: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_BRIEF_OTKAZ: пустой бриф компонента: api.identity'
C stderr-noise: rc=0 stdout_bytes=2072 stderr1=''
   section: 'COMPONENT: api.identity\nBRIEF:--prefix …/repo/architecture run brief -- --compact --with-rules --component api.identity\n' noise_in_pack= False
D legacy byte-compare: same=26 diff=0
E fail: rc=1 stdout_bytes=0 stderr1='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
E ok: rc=0 stdout_bytes=1995 stderr1=''
E leftover tmp files: []
E section: 'COMPONENT: api.identity\n# ARCH-BRIEF:api.identity\nOWN-CONTRACT:api.identity:N\nCOMPONENT: worker.events\n# ARCH-BRIEF:worker.events\nOWN-CONTRACT:worker.events:N\n'
E manifest arch lines: ['trace\t…/arch-170-…/repo/registry/trace.tsv\tmandatory\ttrace']
RC=0
```
Что показывает зонд:
- **D.** Без флага выдача сохранена побайтово: (rc, stdout, stderr) базы e416e1fe0 и OBJECT совпадают в 26 из 26 пар. Пары — 7 ролей × 4 мира: legacy task; document+architecture/ task; code+architecture/ brief; legacy brief. Orchestrator на task исключён.
- **C, E.** Пустой stdout npm даёт отказ. Шум stderr npm в пак не попадает. Временный файл stderr удаляется (TMPDIR пуст). Порядок двух компонент — входной. При rc 17 на втором ID частичного пака нет (stdout 0 байт).
- **A, B.** Это Б-1 и Б-2.

Реальные формы строки класса. Мера — `git grep`, в каждом дереве отдельно:
```
Complior-back (059815e): файлов с ^КЛАСС ЗАДАЧИ: *кодовый (-i) — 25; файлов с ^КЛАСС ЗАДАЧИ: (кодовый|КОДОВЫЙ)$ — 0
dev-harness (OBJECT), contracts/: кодовых строк 35; файлов с ^КЛАСС ЗАДАЧИ: (кодовый|КОДОВЫЙ)$ — 0
```

### 3.5 Регресс других потребителей make_task (OBJECT)
```
bash fixtures/_krasnye_095.sh  → стабы s1..s19 ПОЙМАН; «ИТОГ стаб-пак 095: rc=0»; 17 клеток rc=0; «ИТОГ 095: rc=0»; RC_095=0
bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh → RC_PRAVILA=0
bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model → 5 ok; RC_169=0
bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --repo  → 5 ok; RC_169_repo=0 (против субъекта OBJECT)
```

### 3.6 Гейты
```
bash scripts/pre_critic.sh --repo . contracts/170-arch-component-brief-vhod-zadanija.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
КРИТИК: дверь зелёная
RC_PRECRITIC=0
bash scripts/check_provodka.sh . contracts/170-…md
проводка: guard не подключён: fixtures/workshop_project/arch_component_170/red_arch_component_170.sh не вызывается в .githooks/ или .github/workflows/
rc_provodka=1
grep -c arch_component_170 registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml → 0 / 0 / 0
```
`check_provodka` rc 1 — ожидаемое состояние: по ПРЕДПОСЫЛКАМ шаг CI подключает orchestrator после реализации. Это блок done, а не accept (Н-1). `verify_antiplacebo --scope make_task` — неверный ключ, по заданию дефектом не считается.

## 4. Обязательства контракта — по одному

| обязательство | итог | доказательство |
|---|---|---|
| ARCH_COMPONENT_NET: task + кодовый + architecture/, без флага → rc 1, первая строка, подсказка | **FAIL (Б-1)** на реальных формах; ok на форме фикстуры | §3.1 required; §3.4 A, A2 |
| ARCH_COMPONENT_ID: неконформный список — до запуска npm | **FAIL (Б-2)** для списка, где плохой ID не первый | §3.4 B |
| грамматика ID `[A-Za-z0-9_][A-Za-z0-9._-]*`, без пустой записи, `/`, `..` | ok | §3.4 B (`-x`, `a..b`, `''`, `_ok`), B2 |
| ARCHITECTURE_NET при флаге без architecture/ | ok | §3.1 architecture_missing |
| argv npm по ролям: `--with-rules` architect/critic/arbiter, без — implementer/adversary/reviewer | ok | §3.1 *_rules/*_plain (stub принимает только документированный argv); §3.4 C (argv architect) |
| отказ npm для любого ID → именованный rc 1 без частичного пака (и plain-роль) | ok | §3.1 *_brief_failure; §3.4 E |
| вывод — в пак для своего ID, в порядке входа, не ссылкой | ok | §3.1 multi_component; §3.4 E section |
| MAP STRUCTURE.md / RULES / manifest-строки сохранены | ok | §3.1 (оракул клеток), §3.4 D |
| бюджет 095 включает бриф (`pack_body`) | ok | §3.1 brief_over_budget `42717 > 40000` |
| без architecture/ и без флага — прежняя выдача; document и `--kind brief` без нового отказа | ok | §3.1 legacy/document/brief_kind; §3.4 D 26/26 |
| применимость по каталогу, не по repoId | ok | §3.1 wrong_project |

### 4.3 Более простая форма (одноразовый клон `/tmp/dev-harness-verify/review170/fix`, не коммит)
Две правки в `make_task.sh` OBJECT:
1. предикат `grep -Eiq '^КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'`;
2. перед циклом npm — отдельный цикл проверки всех ID: тот же `case`, тот же `die ARCH_COMPONENT_ID`.

```
python3 probe.py --repo /tmp/dev-harness-verify/review170/fix → 19 ok (required … brief_over_budget), RC_FIX_REPO=0
own_probe A/A2/B против fix:
A … 'КЛАСС ЗАДАЧИ: кодовый.' / 'КОДОВЫЙ (реализация)' / 'КОДОВЫЙ; …' / 'кодовый. КЛАСС РИСКА: обычный' → все rc=1 'ОТКАЗ: ARCH_COMPONENT_NET: …'
A2 КОДОВЫЙ LC_ALL=C / C.UTF-8 / en_US.UTF-8 → все rc=1 ARCH_COMPONENT_NET
B 'api.identity,../x' / ',bad/x' / ',-x' → npm_calls=0, rc=1 ARCH_COMPONENT_ID
RC_FIX_OWN=0
```
Строка `document` (`КЛАСС ЗАДАЧИ: документальный`) при этом остаётся без отказа: клетка document ok.

## 5. Атомарность, норма, ПРОВОДКА

- Один коммит `f87b11904` «170: бриф компонента архитектуры в паке задания (--arch-component)», одна задача, ссылка на предмет есть.
- Нормативные документы (roles/, AGENTS.md, contracts/) не тронуты.
- ПРОВОДКА: guard — `red_arch_component_170.sh`, барьер именно предмета 170. Он исполняет публичный CLI `make_task.sh`, а не произвольный скрипт дерева. Строку ПРОВОДКА-ЭНФОРСМЕНТ принимаю: новой поведенческой нормы роли нет, предмет — чистый CLI сборщика. Барьер в CI не подключён (Н-1).

## 6. Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| флаг `--arch-component` + `ARCH_COMPONENT`/`ARCH_COMPONENT_SET` | §Предмет: публичный вход; пустой список — ARCH_COMPONENT_ID, а не «флага нет» | явное, из argv | 1 | один флаг, новых rc и env нет | все клетки семьи | ESSENTIAL |
| блок перед `TRACE_MAN` (проверки, цикл npm, `ARCH_SEC`) | §Предмет, отказы и порядок | явное (`ARCH_SEC`), в выводе — секция | 1 | интерфейс не растёт | семья 170 | ESSENTIAL (дефекты Б-1/Б-2 — не сложность) |
| два почти одинаковых вызова npm в `if/else` по `_arch_rules` | роль→argv | нет | 1 (обе строки меняются вместе) | дублирование одного вызова | клетки *_rules/*_plain | ACCIDENTAL, совет С-3 |
| временный файл `_NPM_ERR_FILE` + запасной `/dev/null` + удаление в trap | stderr npm не в пак; подсказка в отказе | побочное: временный файл, удаление через trap (§3.4 E: остатков нет) | 1 | 3 переменные ради одной подсказки | приёмка требует только первую строку `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id>` | ACCIDENTAL, совет С-4 (простая `2>/dev/null` проходит те же строки, но теряет диагностику; непроходящего свойства находка не называет — не блок) |
| строка `COMPONENT: <id>` перед брифом | «для своего ID» | нет | 1 | — | косвенно multi_component | ESSENTIAL (атрибуция) |
| строка `=== ARCHITECTURE BRIEF ===` в `pack_body` | бюджет 095 включает бриф | нет | 1 | — | brief_over_budget | ESSENTIAL |

## 7. Стандарты / режим проекта

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` не объявляет документа архитектуры и стандарта кода (`grep -i 'ARCHITECTURE.md|CODING-STANDARDS'` → 0 совпадений), файлов `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` нет. Режим 996: `sourceCanon` в `harness.project.json` не объявлен (`grep -c` → 0), сверка карты не требуется.

## Находки (класс каждой; подробно — `.review/2026-11-10-95.md`)

- **Б-1 (БЛОК, implementer; достижимое состояние).** `scripts/make_task.sh:876`: предикат точной строки не видит реальных строк класса (0/25 в Complior-back, 0/35 в харнессе, сам контракт 170). Под `LC_ALL=C` он не видит и `КОДОВЫЙ`. Защита ЗАЩИЩАЕТ п.1 инертна. Более простая форма — §4.3.
- **Б-2 (БЛОК, implementer).** `scripts/make_task.sh:847-853`: ID проверяется внутри цикла npm, поэтому до `ARCH_COMPONENT_ID` npm успевает вызваться для предшествующих ID. Это нарушает «до запуска npm». Более простая форма: отдельный проверочный цикл до первого npm (§4.3).
- **С-1 (совет, architect → следующий freeze).** В семье нет клетки с байт-копией реальной строки класса (урок 140 в NABLIUDENIA: «миры красных тестов обязаны содержать байт-копии реальных форм»). Нет и клетки «плохой ID не первым». Поэтому оба блока проходят семью зелёными, а `MODEL_BODY` несёт те же дефекты.
- **С-2 (совет, implementer).** Сообщение коммита утверждает: бриф «в manifest-выдачу пака». Строки брифа в manifest нет (§3.4 E). Заявленное ≠ сделанному. Контракт строки manifest для брифа не требует, поэтому это совет, а не блок.
- **С-3 (совет, implementer; 050).** Два вызова npm в `if/else` различаются только `--with-rules`. Хватит одного вызова с `${_arch_rules:+--with-rules}`.
- **С-4 (совет, implementer; 050).** Цепочка `_NPM_ERR_FILE`/`_NPM_ERR_REDIR`/trap ради подсказки в отказе — 3 переменные состояния. Решение оставить — за автором.
- **О-1 (наблюдение, owner).** `--kind brief --arch-component X` флаг молча игнорирует: нет ни отказа, ни брифа. Контракт этот вход не определяет — вопрос владельцу, не FAIL.
- **Н-1 (БЛОК done, orchestrator; accept реализации не блокирует).** Шаг 170 не записан в `registry/ci-steps.tsv`/`ci-zamery.tsv`/`ci.yml`, `check_provodka` rc 1.
