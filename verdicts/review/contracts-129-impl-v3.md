FAIL
OBJECT=20c352f82bf1539d5dfca932bc68718dc2cb2033
СУД: repo=dev-harness; предмет=129; фаза=реализация (правка наблюдателя батареи, круг 2); роль=reviewer; вызов=1 (полный); модель=anthropic/claude-opus-5-5 (тир audit); сессия=Rev129V1; SHA=20c352f82b; предыдущий=verdicts/review/contracts-129-impl-v2.md (accept, OBJECT 2974de91, другой предмет правки — fallback-route.ts); исключение=нет.

Резюме. Правка в целом верная. Диагноз подтверждён: старый наблюдатель на omp 18.18.8 даёт 4 красные клетки «нет результата ребёнка Child129», потому что omp отдаёт id `Child129-2`. Новый наблюдатель зелёный на субъекте, на честной модели и на всех 13 парах стабов. Красная пара `--ext ''` — та же, что в контракте. Отрицательные случаи `--parser` красят пять наивных наблюдателей и шесть моих мутантов.

Блокирует один дефект — Б-1. Адаптер требует атрибуты `id` и `agent`, которые наблюдатель не читает. Если omp переименует `id`, батарея остановится с rc 2. Это противоречит принципу владельца «id omp не используется вовсе». Есть более простая форма, `('status',)`, и она проходит те же строки. Находки в формате reslop: `.review/2026-11-16-01.md` (status: ready).

КЛАСС РИСКА: обычный. Взят из `registry/risk-legacy.tsv` main, строка 6: blob 6a23c8a8 = контракт на frozen/contracts/129/2 и на OBJECT. Правка затрагивает только наблюдателя стенда, маршрутизацию моделей она не меняет. Класс подтверждаю, повышать не нужно.

## Находки

- **Б-1 — блок (ACCIDENTAL по 050 + принцип владельца).**
  - Где: `battery.py:176` `TASK_RESULT_NEED = ('id', 'agent', 'status')` и docstring `:185-186`.
  - Чего нет: ни одно свойство не требует, чтобы `id`/`agent` были на месте. frozen 129/2, стр. 43, называет только `status=…` и yield `{"marker","model"}`. Ни один случай `--parser` их не требует. Слово владельца: id omp не используется вовсе.
  - Что видно: `<task-result name="Child129-2" agent=… status="completed">` с M129 в теле → `('rc2', 'формат omp изменился: id')`.
  - Более простая форма: `('status',)`. Проверено мутантом: `--parser` rc 0 «parser=15 red=0 stub_checks=13 caught=13», субъект rc 0 «cells=6 red=0».
- **С-1 — совет.** Словарь статусов (`st.startswith`) и отрисовка yield как JSON (`"model":`, `"marker":`) читаются в `judge` (`:234-241`), а не в адаптере. Если omp их поменяет, получится rc 1 FAIL против субъекта, а не rc 2. Зонд: `status="done"` → «ребёнок done, ожидался completed»; yield в форме YAML → «ребёнок завершил на модели ?». Ошибка уходит в красное. Строки старые, стр. 43 контракта такое чтение разрешает.
- **С-2 — совет.** s7-cikl в c5 краснеет по причине «нет результата с маркером M129»: omp снимает его по soft request budget, ребёнок успевает сделать 757 ходов, статус `cancelled`, `(no output)`. Ветвь `max_child_turns` живьём ни одним стабом не покрашена. По мутанту `max_child_turns=0` видно, что ветвь живая.
- Н-1 — наблюдение. База в задании (72a7d349a8) не совпадает с фактическим родителем OBJECT (032150c1). Область правки считана от merge-base. Слияние с origin/main 3e1e5941 проходит без конфликтов.
- Н-2 — наблюдение. Миры `/tmp/p129-*` моих прогонов с KEEP остались: guard Н-85 не дал их удалить.

## Проверки по одной

1. **Область правки — чисто.** `git diff 032150c1 20c352f8 --stat` → 3 файла: `battery.py` +257/−, `stub_provider.py` 47, `stubs/s7_cikl.ts` 5. Всё внутри ЗОНЫ architect (`git show frozen/contracts/129/2^{commit}:contracts/129-fallback-subagent.md | grep ЗОНА` → `contracts/129-fallback-subagent.md fixtures/workshop_project/fallback_subagent_129/`). `git diff --stat 032150c1 HEAD -- contracts .omp` → пусто, `source.json` и `model/` тоже не тронуты. Контракт на OBJECT совпадает с тегом: blob 6a23c8a8.
2. **Сырой вывод — ниже.** Все прогоны мои, сделаны независимо от свидетельств architect.
3. **Проверки не подогнаны.**
   - Клеток по-прежнему 6, в тех же именах. Ожидания (`expect`, `world`, `max_child_turns=2`) не менялись, менялся только текст задания ребёнка: «Yield the marker.» → «M129 yield.».
   - Своя мера по `source.json`: stubs=11, pairs=13 — совпадает с замороженными строками.
   - `parser_cases`: 15 случаев, привязок к убиваемым стабам 13, наивных стабов 5.
   - Мои мутанты реального кода (не стабы architect) все красные:
     - без отказа «маркер вне блока» → red=1 (pr14);
     - без «task-result без пары» → red=1 (pr13);
     - дубликат → первый → red=2 (pr10, pr11);
     - связь по префиксу id → red=10, включая группы id-form/id-fail;
     - маркер подстрокой `129` → red=6;
     - без проверки обязательных полей → падение, rc 1.
4. **Красное предъявлено.**
   - Старый наблюдатель (032150c1) на том же субъекте: rc 1 «cells=6 red=4», 4× «нет результата ребёнка Child129». В мире c2 видно `<task-result id="Child129-2" …>`.
   - `--ext ''` → rc 1 «cells=6 red=2» (c2, c6) — как в строке 1 контракта.
   - Старый s7 (с setTimeout) на новом наблюдателе в c5 → rc 0 ok: ребёнок делает 1 ход, ход из таймера на 18.18.8 теряется. Правка стаба нужна, чтобы стаб вернул свой дефект, а не чтобы он «всегда проходил»: новый s7 красен, 3/3 прогона.
5. **Атомарность.** Два коммита architect, оба по предмету 129. Второй переписывает первый, который нарушал принцип (грамматика `Child129(?:-\d+)?`). Сужу итог. Отдельной задачи, примешанной к коммитам, нет.
6. **Норма не тронута.** Контракт и нормативные файлы в диффе отсутствуют.
7. **Заявленное равно сделанному.**
   - cells=6, stubs=11, pairs=13, parser=15, stub_checks=13 — пересчитал своей мерой (python по `source.json` и `parser_cases`), всё совпадает.
   - «Найден живой дефект c4»: подтверждаю по коду. Сосед получает `mk` по флагу sib, поэтому дубликат на честной c4 больше не возникает. Сам c4 зелёный.
   - Заявление «PATH без omp rc 2» подтверждено.

**Принцип владельца (п. 2 задания).**
- Grep по каталогу находит `Child129`/`-2`/регэкспы id только в трёх местах: имя задачи (`CHILD` в `task_step`), тестовые транскрипты `--parser` и наивные стабы (`stub_po_id`, `stub_po_prefiksu_id`, `stub_molchit_na_formate`). На пути суда (`resolve_child` → `judge`) id не читается.
- Формат тега разбирается в одном месте, `read_task_results`. Есть два исключения: С-1 и Б-1 (обязательные `id`/`agent`).
- Нераспознанный формат → `OmpFormatChanged` → rc 2 «ФОРМАТ ИЗМЕНЁН <клетка>: формат omp изменился: <поле>» (`:425-427`).

**stub_provider.py (п. 5 задания).** Маркер запрашивающего задаётся флагом sib: в сообщениях запроса есть SIB129 → SIB129, иначе M129. Форма 429/1310 сохранена: статус, `code 1310`, тело z.ai, заголовки `retry-after-ms: 31561000`/`retry-after`. Маркер добавлен только в хвост последней скобки сообщения. `fallback-route.ts` и стабы читают из `errorMessage` только `retry-after-ms=(\d+)`. Семантика клеток подтверждена живьём: `--ext ''` даёт ту же пару c2/c6, что в контракте, а все 13 пар краснеют по ожидаемым причинам.

**Синхронный s7 (п. 5 задания).** «Всегда проходит» не получается: s7 красен в c5, 3/3 прогона (757 ходов ребёнка). Оговорка о причине — в С-2.

## Сырой вывод (клон /tmp/dev-harness-verify/Rev129V1, HEAD 20c352f8, `omp --version` → omp/18.18.8, `which omp` → /home/harness/.local/bin/omp)

```
=== battery.py
ok c1-zhivoj-perehod
ok c2-sosed-cooldown
ok c3-zdorovyj-primary
ok c4-validacija-soseda
ok c5-vse-ischerpany
ok c6-zapasnaja-validacija
cells=6 red=0
rc=0
=== battery.py --model
(те же 6 строк ok)
cells=6 red=0
rc=0
=== battery.py --stabs
caught s1-bez-cepochki in c1-zhivoj-perehod: ребёнок failed (exit 1), ожидался completed: … [stub129 M129] …
caught s2-tolko-sessija in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s2-tolko-sessija in c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: …
caught s3-na-ljuboj-oshibke in c4-validacija-soseda: ребёнок завершил на модели gpt-sol, ожидалась glm
caught s4-tot-zhe-provajder in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s5-ta-zhe-model in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s6-vsegda in c3-zdorovyj-primary: ребёнок завершил на модели gpt-sol, ожидалась glm
caught s7-cikl in c5-vse-ischerpany: нет результата с маркером M129
caught s8-lokalnoe-sostojanie in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s9-oba-ischerpany in c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: …
caught s10-fb-ne-v-cooldown in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
caught s10-fb-ne-v-cooldown in c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: …
caught s11-krome-ischerpannoj-zapasnoj in c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: …
stubs=11 pairs=13 uncaught=0
rc=0
=== battery.py --ext ''
ok c1-zhivoj-perehod
FAIL c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed: <output> [stub-zai/glm] 429 [1310][Weekly/Monthly Limit Exhausted. …][stub129 M129] …
ok c3-zdorovyj-primary
ok c4-validacija-soseda
ok c5-vse-ischerpany
FAIL c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed: <output> [stub-zai/glm] 429 [1310]…
cells=6 red=2
rc=1
=== battery.py --subject /nonexistent
NOT_IMPLEMENTED: у субъекта /nonexistent нет config/agent_models.json
rc=2
=== PATH без omp (env PATH=/usr/bin:/bin)
NOT_IMPLEMENTED: нет omp в PATH — стенд без реального omp не судит
rc=2
=== battery.py --parser
ok pr1 … ok pr15 (15 строк ok)
parser=15 red=0 stub_checks=13 caught=13
rc=0
=== СТАРЫЙ наблюдатель 032150c1 (worktree) --subject <клон OBJECT>
ok c1-zhivoj-perehod
FAIL c2-sosed-cooldown: нет результата ребёнка Child129 в выводе родителя
ok c3-zdorovyj-primary
FAIL c4-validacija-soseda: нет результата ребёнка Child129 в выводе родителя
FAIL c5-vse-ischerpany: нет результата ребёнка Child129 в выводе родителя
FAIL c6-zapasnaja-validacija: нет результата ребёнка Child129 в выводе родителя
cells=6 red=4
rc=1
(мир c2: <task-result id="Sib129" … status="failed (exit 1)"> / <task-result id="Child129-2" … status="completed">)
=== новый наблюдатель, СТАРЫЙ s7 (setTimeout), c5
ok c5-vse-ischerpany
cells=1 red=0
rc=0          (ходов ребёнка по requests.jsonl: 1)
=== новый s7, c5, ×3 (P129_KEEP=1)
FAIL c5-vse-ischerpany: нет результата с маркером M129   rc=1  (×3)
child_turns=757 sib_turns=1524/1522/1524; оба task-result status="cancelled",
<abort-reason>Soft request budget exceeded (755 requests; budget 500)</abort-reason>, (no output)
=== мутанты реального кода, --parser (mut.py)
m1_no_outside_marker_refusal rc=1  FAIL pr14 …                       parser=15 red=1
m2_no_unpaired_refusal       rc=1  FAIL pr13 …                       parser=15 red=1
m3_dup_takes_first           rc=1  FAIL pr10, pr11                   parser=15 red=2
m4_link_by_id_prefix         rc=1  FAIL pr3,pr6,pr7,pr8,pr9,pr12,pr13,pr14 + группы id-form,id-fail   red=10
m5_no_missing_field_refusal  rc=1  (падение KeyError на pr12)
m6_marker_substring          rc=1  FAIL pr4,pr5,pr6,pr7,pr8,pr15   red=6
=== мутанты mut2.py (живые)
max_child_turns=0, --model --cells c5 → FAIL c5-vse-ischerpany: ребёнок отправил 1 ходов при пределе 0 (цикл смены моделей)  rc=1
TASK_RESULT_NEED=('status',), --parser → parser=15 red=0 stub_checks=13 caught=13  rc=0
TASK_RESULT_NEED=('status',), субъект  → cells=6 red=0  rc=0
=== зонд дрейфа формата (drift.py), ожидание ok-клетки
status-renamed-value(done)   -> 'ребёнок done, ожидался completed: <output> { "marker": "M129", "model": "fam-f" } </output>'
yield-rendered-yaml          -> 'ребёнок завершил на модели ?, ожидалась fam-f'
id-attr-dropped              -> ('rc2', 'формат omp изменился: id')
id-attr-renamed(name)        -> ('rc2', 'формат omp изменился: id')
attrs-single-quoted          -> ('rc2', 'формат omp изменился: id')
honest-18.18.8               -> None
=== своя мера счётчиков
stubs 11 pairs 13 / parser_cases 15 kills 13 naive_stubs 5 / cells 6
```

## Паразитная сложность (050), по артефактам диффа

- **`read_task_results` + `OmpFormatChanged` + отказ rc 2 в `run_cells`.**
  - (1) Требование — слово владельца 2026-11-16: формат читается одним адаптером, при сбое отказ rc 2. Стр. 43 контракта: результат берётся из `<task-result … status=…>`.
  - (2) Состояние явное: исключение и строка «ФОРМАТ ИЗМЕНЁН …».
  - (3) Новое свойство формата меняется в 1 месте, а не в 2 (было `RESULT_RE` + `judge`).
  - (4) Интерфейс узкий: транскрипт → список (status, body).
  - (5) Потребители — `judge` и `--parser`. ESSENTIAL, кроме `TASK_RESULT_NEED` ⊃ id/agent → Б-1 (ACCIDENTAL, блок).
- **`resolve_child`.**
  - (1) Требование — связь по маркеру (слово владельца).
  - (2) Состояния нет.
  - (3) 1 место.
  - (4) Глубокий модуль: 0/1/много.
  - (5) Потребитель — `judge`. ESSENTIAL.
- **Режим `--parser` (семья: `parser_cases`, `run_parser_tests`, `_outcome`, `_tr`, тела-образцы).**
  - (1) Требование — отрицательные клетки владельца (сосед / дубликат / без маркера / формат).
  - (2) Каталоги временные и удаляются. Вывод явный: «parser=N red stub_checks caught».
  - (3) Новый случай — правка 1 файла.
  - (4) Один флаг, rc 0/1.
  - (5) Потребители — задание судье и архитектор. В строках приёмки frozen 129/2 и в CI его нет: требование пришло словом владельца после заморозки. ESSENTIAL по слову владельца. Совет оркестратору: дописать строку приёмки, если в следующей редакции этот режим должен стать барьером.
- **Наивные стабы наблюдателя (`NAIVE_STUBS`, `_blocks`, `_stub_krajnij`).**
  - (1) Требование — Н-39: привязка к клеткам через код.
  - (2) Состояния нет.
  - (3) 1 файл.
  - (4) Сигнатура та же, что у `resolve_child`.
  - (5) Потребитель — `--parser`. `_blocks` переиспользует константы адаптера, грамматика не дублируется. ESSENTIAL.
- **Параметр `judge(link_fn=None)`.**
  - (1) Нужен, чтобы подставлять стабы (Н-39).
  - (2) Явный аргумент.
  - (4) Расширяет интерфейс на 1 необязательный аргумент.
  - (5) Потребитель — `_outcome`. ESSENTIAL (более простой формы подстановки без глобального патча нет).
- **`stub_provider.err_body` + `mk`.**
  - (1) Требование — чтобы маркер умершего ребёнка доходил до наблюдателя.
  - (2) Маркер выводится явно из флага sib (из `plan.json`).
  - (3) 3 константы свернулись в 1 функцию: −.
  - (4) Мелкий модуль, но равный старому по объёму.
  - (5) Потребитель — стенд. ESSENTIAL.
- **`s7_cikl.ts`, синхронная посылка.**
  - (1) Нужна, чтобы дефект стаба s7 был наблюдаем (source.json).
  - (2) Нового состояния нет.
  - (3) 1 файл.
  - (5) Потребитель — `--stabs`. ESSENTIAL: без правки s7 UNCAUGHT, доказано прогоном старого s7.

## ПРОВОДКА (038)

Канал контракта — role-строка orchestrator «батарея прогоняется на станции с omp до land, вызов и rc строкой в задание судьи». Канал соблюдён: строка в задании есть, мой независимый прогон приведён выше. Guard — сама батарея, барьер этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ (CI без omp) — как в контракте, дифф её не меняет.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` / `docs/CODING-STANDARDS.md` (grep по AGENTS.md пуст, файлов в дереве нет).

## Что нужно для accept

Закрыть Б-1. Затем повторный scoped-вызов по дельте: `battery.py --parser` rc 0, субъект rc 0 «cells=6 red=0», `--stabs` rc 0 «stubs=11 pairs=13 uncaught=0», `--ext ''` rc 1 «cells=6 red=2». С-1 и С-2 — на усмотрение architect.
