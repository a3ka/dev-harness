accept
OBJECT=885040c10e6e2b831d57274b6495b6d866344df9
СУД: репо=dev-harness; предмет=157; роль=reviewer; вызов=2 (scoped); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (метаданные среды сессии Rev157s: «Model: anthropic/claude-opus-5-5»; runtime/model-trace.tsv в дереве OBJECT отсутствует); предыдущие=adversary v4 FAIL, v5 FAIL (archive/157/adversary-v5-fail-d8061c901a), v6 accept (wip/157/adversary-v6); класс риска=рисковый

# Ревью реализации 157 — scoped-вызов 2

Слово владельца (21.11, 23.11): «при accept — scoped reviewer». Это не полный суд. Скоуп:
дельта `0f33bee8a..885040c10`, production-часть на `0f33bee8a` по коду, закрытие блоков
adversary v4 (N≥6) и v5 (самоопределение оракула isolated), регресс.
Прежний accept `verdicts/review/contracts-157-impl-v1.md` (OBJECT `5e2f9d3bb8`) не предок
этого кандидата и на него не распространяется. В дереве OBJECT `verdicts/review/contracts-157-*`
есть только `impl-v1.md`, поэтому этот вердикт — `impl-v2`.

Среда: копия `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t9f3d59a52/m`,
`git rev-parse HEAD` → `885040c10e6e2b831d57274b6495b6d866344df9`.
`TMPDIR=/tmp/dev-harness-verify/scratch-rev157s` (без `/zones/`), `PYTHONDONTWRITEBYTECODE=1`,
`VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck`.

Блокирующих находок нет. Советы — `.review/2026-11-23-153.md` (С-1…С-4).

## 1. Область правки — соответствует

- `git diff --stat 0f33bee8a 885040c10`:
  `.omp/extensions/spawn-guard.ts | 1 +`, `fixtures/workshop_project/spawn_guard_157/probe.py | 152 (+94/−58)`.
  Ровно два файла.
- `git diff --stat 9f73d265a 885040c10` → только `probe.py`.
- `git diff 0f33bee8a 9f73d265a` → одна добавленная строка `spawn-guard.ts:320`
  `// 157: носитель узкого adversary … поведение не меняет`. Это комментарий после закрывающей `}`
  функции `register`. Поведение не меняется: `node --check` rc 0, честный W зелёный.
- Авторы (`git log --format='%h %an|%cn'`):
  - `9f73d265a implementer|implementer` — spawn-guard.ts, ЗОНА implementer;
  - `885040c10 architect|orchestrator` — probe.py, ЗОНА architect. Коммиттер — оркестратор, как
    при cherry-pick: задание объясняет, что штатный commit architect отклонён стражем 018.
- Контракт не менялся: `git diff --quiet 'frozen/contracts/157/1^{commit}' HEAD -- contracts/157-…md`
  → rc 0. `git diff --stat 0f33bee8a 885040c10 -- contracts registry .github` — пусто (0 строк).
- `0c6416bd0` (хук 199) и `0f33bee8a` — оба предки OBJECT (`merge-base --is-ancestor`, обе проверки rc 0).

## 2. Production-часть (spawn-guard.ts на 0f33bee8a) — соответствует, проверено по коду

- `git diff 0c6416bd0 0f33bee8a -- .omp/extensions/spawn-guard.ts` → пусто. Main несёт хук 199 ровно
  в той форме, в какой его перенёс `0c6416bd0`.
- `git diff cf4054e8e 0f33bee8a -- spawn-guard.ts` содержит только дельту 199:
  - шапка `:39-46`;
  - `TaskItem` с `isolated: boolean` (`:188`);
  - `isolated: o.isolated === true` (`:202`).
  Заплата 157 (`stateRoots`, ветвь `/home/.omp/profiles/` → `<P>/state`) не тронута.
- Хук 199 не дублируется и не пропущен.
  - `grep isolated|taskItems|zamok_predmeta` по `.omp/extensions` даёт одно определение `taskItems`
    (`:190`) и одну эмиссию поля (`:202`).
  - Сериализация события одна: `:280` `JSON.stringify({ tasks: taskItems(call.input) })`.
  - Других расширений с этим швом нет.
- Каждое принятое `task` идёт в прежнюю дверь:
  - `judgeTaskInput` (`:116-140`) перебирает `for (const item of items)` (`:125`) весь `input.tasks`
    (`:121`). Ранние `return` — только блоки.
  - После алфавита (`:236-237`) путь ведёт к `spawnSync(bash DOOR_PATH --sudit …)` (`:281`);
    rc 0/1/2 разбираются по контракту.
  - Событие удаляется в `finally` (`:312`); исключение даёт fail-closed `BROKEN` (`:316`).
- Полный нормализованный список, batch любой длины:
  - `taskItems` (`:190-206`) — `for (const item of raw)` (`:196`) с безусловным `out.push`;
  - нет `slice`/`filter`/`break`/потолка; событие передаётся файлом, а не argv.
- `isolated` пронесён строгим булевым (`=== true`) из поля item, не из текста задания.
- N≥9 (остаток, переданный ревьюеру комментарием `probe.py:48-56`) проверен по коду (выше) и своей мерой.
  Драйвер `rev_trials.py` в scratch строит batch через `probe.case()` на тексте OBJECT. Флаги изоляции
  смешанные: каждый третий `true`, прочие отсутствуют. Ожидаемое событие строится в памяти, побайтно:
  ```text
  N9 honest n=9 rc=0 / n=12 rc=0 / n=20 rc=0
  N9 constant-8 n=9 rc=1 / n=12 rc=1 / n=20 rc=1   ('door did not judge every batch item')
  N9 constant-11 n=9 rc=0 / n=12 rc=1 / n=20 rc=1
  N9 constant-19 n=9 rc=0 / n=12 rc=0 / n=20 rc=1
  RC=0 (процесс драйвера)
  ```
  Честный хук передаёт 9/12/20 задач с флагами. Срез `slice(0,k)` краснеет ровно при N>k.

## 3. Закрытие блоков судей — воспроизведено, по одному

`python3 fixtures/workshop_project/spawn_guard_157/probe.py --mutant <имя>` — принятая CLI-форма,
последовательно:

```text
MUTANT n6-constant-five rc=1 KLETKI subject 59 KRASNYH 3   first: project-batch-n6
MUTANT n7-odd-middle rc=1 KLETKI subject 59 KRASNYH 2      first: project-batch-n7
MUTANT n8-even-middle rc=1 KLETKI subject 59 KRASNYH 1     first: project-batch-n8
MUTANT skip-last-six-plus rc=1 KLETKI subject 59 KRASNYH 3 first: project-batch-n6
MUTANT first-only rc=1 KLETKI subject 59 KRASNYH 19        first: project-isolated-batch-second
MUTANT last-only rc=1 KLETKI subject 59 KRASNYH 19         first: project-isolated-batch-first
MUTANT drop-isolated rc=1 KLETKI subject 59 KRASNYH 55     first: station-deny ('door did not judge every batch item')
```

CLI `--mutant` применяет batch-мутанты к эталону `cf4054e8e` по схеме до 199 (`probe.py:479-481`).
Поэтому v4-мутанты отдельно применены к тексту самого OBJECT через `probe.mutation(source, name)`
и `probe.run()` с текущей схемой (`rev_trials.py live`):

```text
TRIAL n6-constant-five rc=1 RED=project-batch-n6,project-batch-n7,project-batch-n8
TRIAL n7-odd-middle rc=1 RED=project-batch-n7,project-batch-n8
TRIAL n8-even-middle rc=1 RED=project-batch-n8
TRIAL skip-last-six-plus rc=1 RED=project-batch-n6,project-batch-n7,project-batch-n8
RC=0 (процесс драйвера)
```

Красные множества совпадают с точными ожиданиями `exact_targets` (`probe.py:531-536`).

Честный OBJECT: `npm run check:spawn-guard-157-family-selftest` → `KLETKI subject 59 KRASNYH 0`, rc 0.

- **v4 (N≥6) закрыт.** Параметрические клетки N=1..8 (`probe.py:417-418`) ловят все четыре
  мутанта v4 и на эталоне, и на OBJECT. N≥9 — по коду и своим контролем (§2).
- **v5 (оракул isolated самоопределяется) закрыт.**
  - `run(..., carries_isolated=True)` (`probe.py:440`) по умолчанию требует поле `isolated` на любом
    субъекте. Ожидание `item.get('isolated') is True` / `ISOLATION_EXPECTED` строится из входа
    (`probe.py:304-312`), не из текста хука.
  - Историческая схема выбирается только явно:
    - `--model` / стабы эталона — `carries_isolated=False` (`:492,515,538`);
    - `--revision` — по полному commit-id из `HISTORICAL_REVISIONS` (`:24-27,486-490`).
    Своей мерой: `git rev-parse cf4054e8e 'cf4054e8e^'` → `cf4054e8e1c7…fc2`, `4cde3040…f338`.
    Совпадают с константами.
  - Литерал `ISOLATED_TYPE` встречается только в якоре мутации (`:217`), не в оракуле: grep
    `ISOLATED_TYPE|in source` → `:75,217`.
  - Прежняя проверка `ISOLATED_TYPE in source` удалена диффом из `run()` и из `--stabs`.
  - Стаб v5 `drop-isolated` дословно удаляет тип и эмиссию одним якорем. Результат: 55 красных.

## 4. Регресс — сырые rc

```text
npm run check:spawn-guard-157-family-selftest            → KLETKI subject 59 KRASNYH 0; RC=0
python3 …/spawn_guard_157/probe.py --stabs               → KLETKI model 59 KRASNYH 0 … KLETKI isolated-control 59 KRASNYH 0 … STABY 47 NEPOIMANNYH 0; RC=0 (229 c)
bash scripts/pre_critic.sh contracts/157-…md             → «КРИТИК: дверь зелёная»; PRE_CRITIC_RC=0
node --check .omp/extensions/spawn-guard.ts              → NODE_CHECK_RC=0
node --check …/spawn_guard_157/driver.mjs                → DRIVER_CHECK_RC=0
python3 -m py_compile …/spawn_guard_157/probe.py         → PYCOMPILE_RC=0 (__pycache__ удалён)
bash -n scripts/zamok_predmeta.sh …/red_odin_agent_140.sh → BASH_N_RC=0
bash fixtures/_krasnye_104.sh (CI :242)                  → «ИТОГ 104: rc=0»; K104_RC=0
bash …/odin_agent_140/red_odin_agent_140.sh --model (CI :283) → MODEL_KLETKI 244 KRASNYH 0; R140_MODEL_RC=0
bash …/odin_agent_140/stancija_odin_agent_140.sh (контракт 157, приёмка 4) → PROB VSEGO 45 KRASNYH 0; ST140_RC=0
```

Счёт своей мерой:

- Клетки `scenarios()`, 59 = 35 + 2 + 22:
  - 35 — первая группа: 7 станционных, 7 проектных, 5 batch по ролям, three/reviewer-first/four/five,
    8 клеток n1..n8, 4 алфавит/чужая форма;
  - 2 — isolated-true и isolated-string;
  - 22 — `ISOLATION_BATCHES`: 10 + 4×3.
- Стабы, 47 = 27 + 10 + 10:
  - 27 `targets`: 7 корневых, 5 batch-skip-role, batch-skip-all, 3 first-only/first-two/reviewer-first,
    5 four-plus, 6 five-plus;
  - 10 `exact_targets`: constant-2..7 и 4 мутанта v4;
  - 10 `isolation_targets`.
  Строк `KLETKI <стаб>` в выводе `--stabs`, без `model` и `isolated-control`, тоже 47.
- `drop-isolated` = 55 = 14 дверных клеток + 39 tuple-клеток + 2 isolated.

Шаг 199 в `registry/ci-steps.tsv` отсутствует: grep `157|140|104|199|spawn` → строки 242, 283, 287;
шага 199 нет. Шаг 157 (`:287`) = `npm run check:…157… && probe.py --stabs`; оба прогнаны выше.

## 5. Неподгонка и интеграция — соответствует

- Стабы — производные `MUTATIONS`/`BATCH_DROPS`/`ISOLATION_MUTATIONS`. Связь стаб→клетки задана кодом
  `probe.py` (Н-39): `targets` ⊆, `exact_targets`/`isolation_targets` — точное равенство.
- Ожидания `drop-isolated` выведены из `scenarios()`, а не перечислены вручную.
- Новый стаб не вырожден: краснеет на 55 из 59 клеток. Четыре зелёные клетки — те, что не доходят
  до двери (алфавит / чужая форма / вне грамматики), и события у них нет.
- Перед изоляционными стабами контроль `run(source, 'isolated-control')` на OBJECT обязан быть зелёным,
  иначе rc 2 (`probe.py:542-544`).
- Оракул isolated не берётся из проверяемого файла (§3).
- Строка-комментарий в spawn-guard.ts поведение не меняет (§1).
- Изменения в шапке probe.py (docstring) соответствуют коду.

## ОСТАТОК (контракт 192)

Контракт 157 не несёт строк `К-NN` с ловцом reviewer: grep `К-\d+|ловец|ОСТАТОК` по контракту → нет совпадений.
Остаток N≥9, переданный ревьюеру комментарием батареи (`probe.py:48-56`), не укусил. Место в диффе:
`spawn-guard.ts:196,280` на `0f33bee8a` и контроль n=9/12/20 (§2).

## СВЕРКА-СТАНДАРТОВ / СВЕРКА-АРХИТЕКТУРЫ

- СВЕРКА-СТАНДАРТОВ: неприменимо. `AGENTS.md` дерева OBJECT не объявляет `docs/ARCHITECTURE.md` /
  `docs/CODING-STANDARDS.md`: grep → нет совпадений, файлов нет.
- СВЕРКА-АРХИТЕКТУРЫ: неприменимо по механизму 188. В дереве OBJECT нет `bindings.json` и
  `tooling/checks/cli.js` (glob → нет).
  - Размещение: production — `.omp/extensions/spawn-guard.ts` (ЗОНА implementer); батарея — ЗОНА architect.
  - Новых зависимостей и писателей нет. Писатель событий — по-прежнему процесс расширения.
  - Долг не расширен. Находок L1/L2/L3 нет.

## ПРОВОДКА (038)

- `guard=fixtures/workshop_project/spawn_guard_157/probe.py` существует и подключён: CI `:287` гонит
  безфлаговый W и `--stabs`. Guard — барьер именно этого предмета.
- `ПРОВОДКА-ЭНФОРСМЕНТ` обоснован чистым энфорсментом пути и корня. Поведенческой нормы 029-класса
  предмет не вводит.

## Паразитная сложность (050) — по артефактам диффа

- **`HISTORICAL_REVISIONS`** (`probe.py:24-27`) и ветвь `rev-parse` в `--revision` (`:486-490`).
  - (1) Требуют приёмка 1 контракта (`--revision cf4054e8e`/`^`) и закрывающее свойство v5: схема
    выбирается не текстом.
  - (2) Состояние явно: две константы полного sha.
  - (3) При правке свойства меняется 1 файл.
  - (4) Интерфейс не вырос.
  - (5) Потребитель — приёмка 1.
  - ESSENTIAL.
- **Параметр `carries_isolated` у `run()` и смена умолчания в `case()`** (`:269,440`).
  - (1) Независимость оракула (блок v5).
  - (2) Состояние явно в аргументах.
  - (3) 1 файл.
  - (4) Один kw-аргумент на прежнюю работу.
  - (5) Потребители — CI `:287`, `--revision`, `--mutant`.
  - ESSENTIAL.
- **Ветвь `drop-isolated`** (`:79,214-237`).
  - (1) Закрывающее свойство v5: удаление поля и типа ловится.
  - (2) Скрытого состояния нет.
  - (3) Выросло: якорь — дословная копия всей `taskItems` (18 строк). Любая правка форматирования
    `taskItems` в хуке требует правки `probe.py`. Отказ при этом громкий: `NOT_IMPLEMENTED` rc 2.
  - (4) Интерфейс не вырос.
  - (5) Потребитель — `--stabs`, CI `:287`.
  - ACCIDENTAL в части размера якоря. Более простая форма: два однострочных якоря `ISOLATED_TYPE` и
    `ISOLATED_SEAM` с проверкой кратности 1 у каждого. Нарушения на достижимом состоянии нет, поэтому
    это совет С-1, не блок.
- **Комментарий `spawn-guard.ts:320`.**
  - (1) Свойства контракта не несёт: носитель вызова по слову владельца.
  - (2) Состояния нет.
  - (3) 1 файл.
  - (4) Интерфейса нет.
  - (5) Потребителя в приёмке нет.
  - ACCIDENTAL, санкционирован владельцем. Совет С-2.

## Блоки

Нет. Ни одного доказанного нарушения обязательства 157 на достижимом состоянии в скоупе.

## НЕ ЗАЩИЩАЕТ

- Восемь форм путей, принятых контрактом остаточным риском (§Модель угроз), не атаковались: вне скоупа.
- Полный поиск по стражу и live-приёмка не проводились (скоуп п. 6).
- Проба и мой контроль судят подложной дверью (`probe.py:276-281`). Работа установленной
  `scripts/zamok_predmeta.sh` на событии с `isolated` подтверждена только моделью 140 и станционной
  командой 140 (синтетический ctx), не живой сессией.
- `node --check` проверяет синтаксис, не статическую типизацию TS.
- Мой контроль N≥9 конечен: n=9/12/20. Отсутствие потолка за этими длинами установлено чтением кода (§2).
- Режим проекта (996) и мобильный экран неприменимы: предмет харнесса, экрана нет.
