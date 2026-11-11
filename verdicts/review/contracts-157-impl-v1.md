accept
OBJECT=5e2f9d3bb848e565bfe96794f7746cc518905915
КЛАСС=рисковый (frozen 157/1, строка 3: «КЛАСС РИСКА: рисковый — безопасность предметных замков и допуска агентов»)
СУД: вызов 1/1; модель-план=anthropic/claude-opus-5-5; session-id=Rev157v1; модель-факт=anthropic/claude-opus-5-5; предыдущий=verdicts/adversary/contracts-157-impl-v4.md

# Ревью реализации 157 — страж спавна: проектные сессии

Предмет: `contracts/157-spawn-guard-proektnye-sessii.md` (`frozen/contracts/157/1` → `bb344b215f73`).
Кандидат: tip `wip/157/architect` = `5e2f9d3bb848e565bfe96794f7746cc518905915` (поверх
`9e8388b31`, база ветви `ba7bed37` = merge-base с origin/main). Реализация — owner-заплата
`cf4054e8e` в `.omp/extensions/spawn-guard.ts`, на OBJECT не менялась.
Клон: `/tmp/dev-harness-verify/Rev157v1/repo`; свидетельства: `/tmp/dev-harness-verify/Rev157v1/ev/`,
собственный контроль: `/tmp/dev-harness-verify/Rev157v1/ctl/{control.py,driver.mjs,mutants.py}`.

Блокирующих находок нет. Три СОВЕТА (ниже) и одно наблюдение.

## 1. Область правки — соответствует

- `git diff --stat 9e8388b31 5e2f9d3bb` → только `fixtures/workshop_project/spawn_guard_157/probe.py | 63 (+62/−1)`.
- Вся ветвь `ba7bed37..5e2f9d3b` (3 коммита, все `architect <architect@dev-harness.local>`, каждый с префиксом
  `157` и ссылкой на круг адверсария) → `driver.mjs` (+2/−2) и `probe.py` (+192/−9); обе — ЗОНА architect.
- `git diff --quiet 'frozen/contracts/157/1^{commit}' HEAD -- contracts/157-…md` → rc 0 (контракт байт-в-байт frozen).
- `git diff --quiet cf4054e8e HEAD -- .omp/extensions/spawn-guard.ts` → rc 0; `git diff --quiet origin/main HEAD -- .omp/extensions/spawn-guard.ts` → rc 0.
  `.omp/extensions/*`, `registry/`, `.github/` в ветви не тронуты.

## 2. Реализация по сути (остаточный класс N≥9) — соответствует

Прочитан `.omp/extensions/spawn-guard.ts` целиком (303 строки, sha совпадает с `cf4054e8e`).

- Суд алфавита `judgeTaskInput` (`:107-129`): `items = input.tasks` целиком (`:112`) либо `[input]`;
  перебор `for (const item of items)` (`:116`) без длины/индекса/среза. Ранние `return` — только
  блоки (`:122,:125,:126`): «первый плохой элемент заражает весь batch»; пропуск — только после полного
  перебора (`:128`).
- Событие двери `taskItems` (`:175-190`): `raw = input.tasks` целиком; `for (const item of raw)` (`:181`)
  с безусловным `out.push` — нет `slice`, `filter`, `break`, константы-потолка. Сериализуется всё:
  `JSON.stringify({ tasks: taskItems(call.input) })` (`:264`), передаётся файлом, не argv (нет предела ARG_MAX).
- Все `slice` файла — не по batch: `sessionFile.slice(0, z|h)` (`:158,:165`, корни 157) и
  `Math.random().toString(36).slice(2)` (`:255`, имя файла события).
- Нормализация обеих функций одна (`'tasks' in input`); не-массив `tasks` бросает в `judgeTaskInput`
  до `taskItems` → fail-closed `BROKEN` (`:300`), расхождения форм нет.

Собственный контроль (оракул — ожидаемое событие строится в памяти `control.py` ДО запуска хука, свой
driver и своя дверь, сверка побайтно + порядок + argv `--sostojanie` + удаление события):

```
$ python3 /tmp/dev-harness-verify/Rev157v1/ctl/control.py <repo>/.omp/extensions/spawn-guard.ts
CTL project-n9-allow OK … CTL project-n64-allow OK, project-n10-deny OK, project-n10-broken OK
CTL station-n9-allow OK … CTL station-n64-allow OK, station-n10-deny OK, station-n10-broken OK
CTL project-n10-reviewer-first OK, CTL project-n9-sparse-fields OK
CTL n12-{task,foreign,noagent,null,agent-array,agent-case,agent-space,string-item}-at-{0,8,11} OK (24)
CTL tasks-null OK, tasks-string OK, tasks-object OK, input-null OK, input-string OK, input-number OK,
    input-array OK, flat-one OK, tasks-empty-door-deny OK
CTL_KLETKI 49 KRASNYH 0
ctl_rc=0
```

Граничные входы (исход на реальном хуке, дверь НЕ вызвана для всех отказов): `tasks: null|"…"|{…}`,
`input: null|"…"|7`, элемент `null`/строка, `agent` массивом → `ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)`;
`agent` отсутствует / `"task"` → `ОТКАЗ: спавн без явного agent`; `"Architect"`, `" architect"`,
`"stranger"` → `ОТКАЗ: тип агента вне алфавита` — на позициях 0, 8, 11 из 12. Смешанный batch
проектная+станционная раскладка, reviewer-first N=10 — дверь получила все 10 в порядке входа.

Красное моего контроля (`mutants.py`, мутанты реального хука):

| мутант (одна строка хука) | W 157 (35 клеток) | мой контроль (49) |
|---|---|---|
| `constant-8`: `for (const item of raw.slice(0, 8))` | 0 красных | 16 красных (все N≥9, rc 1) |
| `skip-index8-n9plus`: фильтр индекса 8 при N≥9 | 0 красных | 16 красных (rc 1) |
| `no-iteration`: `raw.slice(0, 1)` | 16 красных, параметрические n2..n8 | 16 красных |
| `no-door-call`: `return undefined` перед `mkdirSync` | 31 красная, n1..n8 | 18 красных |
| `judge-first-only`: `items.slice(0, 1)` в суде алфавита | 0 красных | 16 красных (позиции 8, 11) |

Вывод: класс N≥9 W не различает (как и объявлено автором — граница 8), но реальный перебор не несёт
ни одной вшитой длины, и контроль N=9..12,64 зелен на реальном хуке и красен на обоих N≥9-мутантах.
Остаточный класс закрыт чтением реализации + исполнением; блока нет.

## 3. Сырой вывод (свои прогоны на OBJECT; логи `ev/*.log`)

```
python3 fixtures/workshop_project/spawn_guard_157/probe.py               rc=0  KLETKI subject 35 KRASNYH 0
… --model                                                                rc=0  KLETKI model 35 KRASNYH 0
… --stabs                                                                rc=0  STABY 37 NEPOIMANNYH 0   (86.6 с)
… --mutant n6-constant-five                                              rc=1  KLETKI subject 35 KRASNYH 3
      RED: project-batch-n6, project-batch-n7, project-batch-n8 — ('…', 'door did not judge every batch item')
… --revision cf4054e8e^                                                  rc=1  KLETKI subject 35 KRASNYH 23
      23/23 красных с причиной «файл сессии вне грамматики», все — project-*; 0 станционных
… --revision cf4054e8e                                                   rc=0  KLETKI subject 35 KRASNYH 0
reslop t -- npm run check:ceilings                                       exit 0  «потолки в порядке» (3 passed)
reslop t -- npm run check:gen                                            exit 0  «харнес соответствует roles/ (12 ролей)»
reslop t -- bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh   exit 0  PROB VSEGO 15 KRASNYH 0
reslop t -- bash fixtures/_krasnye_104.sh                                exit 0  39 passed, t104-m1..m17 пойманы
```

Счёт своей мерой (не повтором команды автора):
- клетки: `len(probe.scenarios())` = 35, уникальных по (раскладка, профиль, хвост, состояние, исход, роли) — 33;
- стабы: в `--stabs` 38 строк `KLETKI` = 1 контроль `model` + 37 стабов; по коду 15 `BATCH_DROPS` + 6 `constant-k`
  + 16 прочих целей = 37. Заявленное автором «35/37/STABY 37/красны ровно N=6,7,8» — подтверждено.
- точные цели `--stabs` против моего счёта: `constant-2` 9 красных = клетки длины >2 (three, four, five, n3..n8) ✓;
  `constant-7` 1 = n8 ✓; `n7-odd-middle` 2 = n7,n8 ✓.

## 4. Неподгонка проверок — соответствует

- Оракул: `case()` строит `tasks`, `expected_event` (`json.dumps(... separators=(',', ':'))`), ожидаемый
  argv и снимки состояния ДО `subprocess.run`; ответ driver сравнивается с вычисленным `expected`, событие —
  `event_log.read_bytes() == expected_event`. Вывод реализации ожиданием не служит.
- Параметрическая клетка не вакуумна: удаление вызова двери → n1..n8 красны; удаление перебора → n2..n8 красны
  (n1 честно зелёна — один элемент); таблица выше.
- Стабы привязаны кодом: `targets`/`exact_targets` в `probe.py` вычисляются из `scenarios()` (длины ролей),
  не из вывода; `exact_targets` требует равенства множеств (`fails != observed` → `STAB_ZHIV`, rc 1).
- Реализация не трогала проверки: `cf4054e8e` (owner) меняет только `.omp/extensions/spawn-guard.ts`
  (14 строк); фикстуры 157 — только коммиты architect (`bb344b21`, `8b741e83`, `9e8388b3`, `5e2f9d3b`).
- Красное предъявлено: `--revision cf4054e8e^` rc 1 (23), `--mutant n6-constant-five` rc 1 (3), `--stabs` — 37 стабов красны.

## 5. Принятые остаточные классы — не блок

Восемь форм §Модель угроз (вкл. `project-zones-in-p`) и duplicate-only batch (арбитраж: СОВЕТ) не
атаковались как блок. Новых форм пути, расходящихся на конформных клетках, не найдено.

## Находки

- [ ] **СОВЕТ-1 (заявленное ≠ сделанное, вне границы правки architect).** `contracts/157-…md:34-36` (frozen)
  несёт числа `KLETKI subject 18 KRASNYH 7`, `KLETKI subject 18 KRASNYH 0`, `KLETKI model 18 KRASNYH 0`,
  «шесть обманных вариантов», «на семи проектных клетках». На OBJECT измерено: 35 клеток, родитель — 23
  красных (все проектные, причина «вне грамматики»), 37 стабов. На freeze-коммите `bb344b21` клеток было 18
  (свой подсчёт по `scenarios()` frozen-блоба); рост — добавления по FAIL адверсария вызовов 1–4.
  Семантика строк (rc, «проектные красны вне грамматики», «KRASNYH 0», каждый стаб красен) соблюдена; CI по
  контракту подключает безфлаговый `W` по rc. Не блок (прецедент `verdicts/critic/contracts-104-v1.md:68`);
  оркестратору: в `registry/ci-zamery.tsv` вписывать измеренные 35/37, а не числа контракта; правка чисел
  контракта — только через перезаморозку по слову владельца.
- [ ] **СОВЕТ-2 (паразитная сложность, ACCIDENTAL, не блок).** `probe.py` `scenarios()`: `project-batch-three` ≡
  `project-batch-n3` и `project-batch-four` ≡ `project-batch-n4` — побайтно одинаковые сценарии (раскладка,
  профиль, хвост, состояние, исход `deny`, роли), различие только в метке (свой счёт: 35 клеток / 33 уникальных).
  Свойства, которое требует дубль, контракт не называет; более простая форма — снять две строки и направить
  `batch-first-two` и `BATCH_GE4_CELLS` на `n3`/`n4`. Не блок: дубль не вводит состояния и не ослабляет
  различение (обе копии краснеют на одних мутантах).
- [ ] **СОВЕТ-3 (покрытие слоя 104 внутри batch).** Мутант `judge-first-only` (суд алфавита только первого
  элемента batch) W 157 не различает (35/0). Его ловит замороженная регрессия 104: в одноразовом рабочем
  дереве с этим мутантом `bash fixtures/_krasnye_104.sh` → exit 1, `КРАСНО: red_huk_task_spavna: провалено
  фабричным драйвером (rc=1)`. Инвариант 2 («перед дверью неверный agent отказывается по 104») поэтому
  защищён связкой приёмки 157 п.4; реальный хук судит каждый элемент (мой контроль, позиции 8 и 11).
- Наблюдение (не находка): `tasks: []` доходит до двери с `{"tasks":[]}`, исход решает дверь (контроль
  `tasks-empty-door-deny`); задач для потери нет. Ветвь `:244` (нет ctx и нет двери → пропуск) — совместимость
  с frozen 104, вне предмета 157.

## Пять вопросов (контракт 050), по артефактам ветви

- **Параметрическая клетка `project-batch-n1..n8` (+`PARAM_BATCH_ROLES`, `PARAM_MAX_N`).** (1) инв. 2 «каждое
  принятое task зовёт дверь» — полный список в событии; (2) состояния нет, длины видны в метке клетки;
  (3) класс правится в одной строке `PARAM_BATCH_ROLES`, число файлов не выросло; (4) интерфейс `W` не изменён
  (флагов/env не добавлено); (5) потребитель — приёмка п.2/3 и будущий CI-шаг безфлагового `W`. ESSENTIAL.
- **Семья стабов `constant-2..7`, `n6/n7/n8`, `skip-last-six-plus` + ветвь `exact_targets`.** (1) приёмка п.2
  «каждый стаб красен собственной различимой клеткой»; (2) без состояния; (3) один файл; (4) интерфейс прежний
  (`--stabs`, `--mutant`), выросла скрытая работа; (5) потребитель — `W --stabs`. ESSENTIAL.
- **Семья `BATCH_DROPS` (four/five-plus) и `BATCH_CELLS`, `driver.mjs` (вход задачи JSON вместо роли).**
  (1) инв. 2 для batch; (2) без состояния, вход виден в argv driver; (3) один-два файла; (4) интерфейс driver
  не вырос (тот же позиционный аргумент, теперь JSON); (5) потребитель — `W`, `W --stabs`. ESSENTIAL, кроме
  дубль-клеток (СОВЕТ-2).

## ПРОВОДКА (038)

`guard=fixtures/workshop_project/spawn_guard_157/probe.py` существует и является барьером именно предмета:
грузит поставленный хук и исполняет его `tool_call`. Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно:
предмет — механизм (вывод корня и вызов двери), не поведенческая норма роли. CI-шаг подключает оркестратор
после ленда (порядок контракта), на этом суде не требуется.

## Атомарность

Три коммита ветви — по одному на круг адверсария, все с префиксом `157`, все в зоне architect. Норма не тронута.

СВЕРКА-СТАНДАРТОВ: неприменимо — `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` /
`docs/CODING-STANDARDS.md` (grep по `AGENTS.md` → rc 1, совпадений нет).

Режим проекта (996), мобильный экран: неприменимо — предмет харнесса, не проект; экрана нет.
