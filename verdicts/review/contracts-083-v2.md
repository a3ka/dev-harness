FAIL

Б-1..Б-3 круга 1 и Н-213 закрыты своей мерой: красное есть на каждый откат.

Новые блокирующие находки:
- Б-1: save-шаги кеша стоят во всех 7 lane. Ключ занимает lane со старой базой, и зелёный чек кеш не продвигает. Живьём PR #49: check_ids/protected 49591053..HEAD, окно 2 → 3.
- Б-2: `incr_finish` пишет HEAD на конце прогона, а не HEAD судимого окна. Коммит, пришедший во время прогона, incr не судит никогда.
- Б-3: `config/ci_parity_exceptions.txt` правлен вне ЗОНА 083.
- Б-4: А3 rc 1/2, ленд сделан до двух тёплых прогонов.

Детали — `.review/2026-10-07-07.md`.

# Reviewer 083, круг 2 (гейт перед слиянием)

- **Предмет:** `frozen/contracts/083/3`.
- **Судимый tip:** `wip/083/integration-2` = `7c8fad4f4d0509f5154cdc8ebd1315da42a9688f`. В main он слит как `41a9917`.
- **Диапазон круга:** `6aa38a58..7c8fad4f`.
- **Клон:** `/tmp/dev-harness-verify/rev083k2/repo`, рабочее дерево tip — `/tmp/dev-harness-verify/rev083k2/tip`.
- **Находки:** `.review/2026-10-07-07.md` (reslop, `status: ready`).

| артефакт | блоб @7c8fad4 |
|---|---|
| `scripts/lib_incr.sh` | `dac5c3095d33` |
| `scripts/verify_ci_parity.sh` | `9bc482a88050` (режим 100644) |
| `scripts/gen_ci_steps.sh` | `46c55edf4472` |
| `scripts/run_ci_lane.sh` | `2653063bad3b` |

Вердикт связан с tip 7c8fad4. Новая редакция принятия не наследует.

## 1. Область правки

Своя мера — `git log --name-only 6aa38a5..7c8fad4`: 12 коммитов, из них 5 содержательных и 7 orchestrator (3 пустых «тёплый прогон», 3 мержа, 0 файлов).

| коммит | автор | файлы | зона |
|---|---|---|---|
| a9f9c27 | implementer-gen | ci.yml, verify_ci_parity.sh, **config/ci_parity_exceptions.txt** | первые два — в зоне; третий **вне всех ЗОНА 083/3** → Б-3 |
| b58907f | implementer-incr | lib_incr.sh, check_charter.sh | в зоне |
| 97b7c15 | architect | _krasnye_083.sh, .probe-only, red_ci_a_083.sh | в зоне architect |
| 05f41c6 | implementer | lib_incr.sh | в зоне (Н-4: имя автора) |
| 7c8fad4 | architect | docs/owner/2026-10-05-a3-pr-vs-push-analiz.md, _krasnye_083.sh, .probe-only, red_ci_a_083.sh | в зоне architect (v3) |

Нормативные документы не тронуты. Контракт, `roles/` и `AGENTS.md` в диапазоне не менялись. Дополнение в `docs/owner/…analiz.md`:
- анализ корня Н-213;
- выбор границы А3 по определению v+1;
- предмет Д2 вне 083.
Критерий А3 не меняется: порог 720 сохранён.

Проверка под реализацию не переписана. Implementer не трогал файлы батареи, architect не трогал субъект.

## 2. Сырой вывод — свои прогоны

**А1 на tip 7c8fad4** — `bash fixtures/_krasnye_083.sh`:
```
083-батарея: ok=97 FAIL=0 (до реализации части Г и И красны по умыслу)
rc=0
```
Своя мера (`red_mut.sh`, `grep -c '^  ok '` / `'^  FAIL '` по выводу): ok=97 FAIL=0, rc 0.
На main 2e23370 та же батарея: ok=97 FAIL=0, rc=0.

**Красное по каждому фиксу** (`red_mut.sh`, откат одного файла на копии tip):

| откат | rc | ok | FAIL | красные клетки |
|---|---|---|---|---|
| — (честный tip) | 0 | 97 | 0 | — |
| lib_incr.sh ← 05f41c6^ (без `mkdir -p`) | 1 | 93 | 4 | И4-5 ×4 (charter/zones/ids/protected) |
| lib_incr.sh ← b58907f^ (без (в′)) | 1 | 77 | 20 | И4-3/И4-4 линия+объект ×4 чека (16) + И4-5 ×4 |
| lib_incr.sh + check_charter.sh ← b58907f^ (pre-parse круга 1) | 1 | 81 | 16 | И4-3/И4-4 zones/ids/protected (12) + И4-5 ×4 |
| ci.yml ← a9f9c27^ (save только push) | 1 | 93 | 4 | Г10-pr ×4 |

Строка 4 — точно дерево круга 1. Новые клетки ловят ровно обход, найденный в круге 1: (в′) только в charter.

**Б-2 круга 1 живьём** (`b2_live.sh`, tip):
- сторонняя линия: `commit-tree -p HEAD~5`, merge-base rc 1;
- посторонний объект `1234…5678`: rc 128.

Результаты:
```
check_zones/SIDE     rc=0 cache_after=7c8fad4f :: incr: check_zones полный прогон (база 94fcdd85 не предок HEAD 7c8fad4f — кеш сторонней линии)
check_zones/OBJ      rc=0 cache_after=7c8fad4f :: incr: check_zones полный прогон (база 12345678 не предок HEAD 7c8fad4f — кеш сторонней линии)
check_ids/SIDE       rc=0 cache_after=7c8fad4f :: … (база 94fcdd85 …)
check_ids/OBJ        rc=0 cache_after=7c8fad4f :: … (база 12345678 …)
check_protected/SIDE rc=0 cache_after=7c8fad4f :: … (база 94fcdd85 …)
check_protected/OBJ  rc=0 cache_after=7c8fad4f :: … (база 12345678 …)
```
Попутно: кеш с пустой первой строкой дал `ОТКАЗ: кеш повреждён … первая строка не sha`, rc 1 у всех трёх. Это ветвь (в).

**Б-3 круга 1** (`b3_probe.sh`, копия tip). Базовая сверка: «расхождений: 0», rc 0. Каждая проба — отдельный шаг в ci.yml:
- `bash scripts/check_no_rewrite.sh --probe-arg` → FAIL, «расхождений: 1», rc 1;
- `bash scripts/check_no_rewrite.sh "${{ github.sha }}"` → FAIL, rc 1;
- `bash scripts/run_ci_lane.sh ${{ matrix.keys }} --x` → FAIL, rc 1;
- `bash scripts/run_ci_lane.sh` → FAIL, rc 1.

**Генератор и паритет на main** (`reslop t -- …`):
- `gen_ci_steps.sh --check` → exit 0;
- `verify_ci_parity.sh` → «расхождений: 0», exit 0.

**А2.** Полный режим `check_charter`, скрипты круга 1 (6aa38a5) против круга 2 (7c8fad4) на одном дереве — см. §3.

**А3** (`GH_REPO=a3ka/dev-harness bash fixtures/ci_gen_083/timing_083.sh wip/083/integration-2 720 <граница>`):
```
(без границы)  timing_083 НАРУШЕНИЕ: самая долгая lane-джоба ci = 811 с (> 720): ci (l1, check:charter)   rc=1
37535574021    … = 811 с (> 720) …                                                                       rc=1
37538840321    timing_083 НАРУШЕНИЕ: самая долгая lane-джоба ci = 789 с (> 720): ci (l1, check:charter)   rc=1
37552402176    timing_083 ОТКАЗ: после границы 37552402176 завершённых прогонов — 0 (< 2): мало данных   rc=2
```
→ Б-4.

## 3. А2 — полный режим не изменён кругом 2

Круг 2 менял в чек-скриптах только `check_charter.sh` (удалён pre-parse) и `lib_incr.sh` (ветвь `--incr` и `incr_finish`; без `--incr` функция — no-op).

Дифференциал (`a2_charter.sh`): `check_charter.sh` + `lib_incr.sh` из 6aa38a5 против 7c8fad4. Оба запускаются без аргументов на одном дереве tip.

```
diff_verdicts_083 r1_charter.txt r2_charter.txt → «вердиктов=260, rc=0 — совпали», rc 0
cmp r1 r2 → bytes identical (42 610 Б)
своя мера grep -c: ok=260 FAIL=0; строка rc=0 в обоих
```
Полный режим (г) `check_charter` после круга 2 побайтово равен кругу 1. Круг 1 сверил его с базой 5bfc85c4 (А2 круга 1).
zones/ids/protected в круге 2 не менялись. `lib_incr.sh` без `--incr` даёт `incr_parse` → INCR_CACHE пуст → return, `incr_finish` → no-op.

## 4. ПРОВОДКА (038)

- 083: `guard=fixtures/_krasnye_083.sh`. Подключение — прямой шаг `ci.yml` `run: bash fixtures/_krasnye_083.sh` в джобе `ci` (каждая lane, Н-5).
  - Ключ `check:ci-family-selftest` = `bash fixtures/_krasnye_083.sh` (package.json:80).
  - `check_provodka.sh <tip> contracts/083-…md` → rc 0; на main → rc 0.
  - В CI шаг исполняется: лог l1 рана 37552402176 — «083-батарея: ok=97 FAIL=0».
  - Guard — барьер именно этого предмета: батарея `ci_gen_083`, клетки Г/И по субъектам 083.
- 082: `guard=fixtures/verify_antiplacebo/red_watchdog_082.sh`. Подключение — `registry/ci-steps.tsv:26`
  `step check:watchdog-082-family-selftest 20 bash fixtures/verify_antiplacebo/red_watchdog_082.sh`, ключ в lane l6 блока
  JOBS. Исполняется: лог l6 рана 37552402176 — «+ bash fixtures/verify_antiplacebo/red_watchdog_082.sh / red_watchdog_082: все
  фазы зелёные».
  - Механическая мера на tip 7c8fad4: `check_provodka.sh . contracts/082-…md` → **rc 1** «guard не подключён: … не вызывается в
    .githooks/ или .github/workflows/». Перенос шагов в реестр сломал машинную проводку 082.
  - На main после cad5be8 (третья локация `registry/ci-steps.tsv` в `guard_is_wired`, вне зон 083, слово владельца
    2026-10-07) → rc 0. Закрыто чужим коммитом (Н-1).

## 5. Находки

Подробно — `.review/2026-10-07-07.md`.

| ID | класс | зона | суть |
|---|---|---|---|
| Б-1 | блокирующая (этикет §Зоны, Остаточный риск v+1) | implementer-gen (+ architect клетка) | save ×4 в каждой из 7 lane. Неизменяемый ключ занимает первая закончившая lane со старой базой. Живьём PR #49: ids/protected база 49591053 стоит, окно 2 → 3; zones в следующем ране — так же |
| Б-2 | блокирующая (инв. 6(а), Модель угроз) | implementer-incr (+ architect клетка) | `incr_finish` пишет `rev-parse HEAD` на конце прогона. Демо: окно fa5f854a..96c60d73, коммит во время прогона 9606415f → кеш = 9606415f, коммит не судится |
| Б-3 | блокирующая (правило 1, область) | implementer-gen / architect v4 или владелец | `config/ci_parity_exceptions.txt` вне ЗОНА 083/3 |
| Б-4 | блокирующая (А3, процесс) | orchestrator | А3 rc 1 (789–811 с) / rc 2 (после границы v+1 0 прогонов); ленд до приёмки |
| Н-1 | неблокирующая | — | ПРОВОДКА 082 красна на tip, закрыта cad5be8 по слову владельца |
| Н-2 | неблокирующая | implementer-gen | режим verify_ci_parity.sh 755 → 644 |
| Н-3 | совет (атомарность) | implementer-gen | Б-1 и Б-3 одним коммитом a9f9c27 |
| Н-4 | совет | orchestrator | 05f41c6 под именем `implementer`, не `implementer-incr` |
| Н-5 | совет (С-2 круга 1) | implementer-gen | батарея 083 и сам-тесты антиплацебо ×7 lane |
| Н-6 | совет | implementer-incr | `incr_finish` молчит на каждом отказе записи — класс Н-213 открыт |

## 6. Паразитная сложность (050) — артефакты диффа круга 2

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| PR-save ×4 в ci.yml | §Зоны v+1 (save на pull_request, PR-scoped key) | записи actions/cache, ключ явный | 1 (ci.yml) + Г10 | 8 save-шагов × 7 lane при 4 исполняемых | Г10, А3 | ESSENTIAL по свойству; размножение по lane — дефект (Б-1). Простая форма — `contains(matrix.keys,…)` |
| запись `команда:` в ci_parity_exceptions | инв. 3 (правило 6 без ослабления) для статического шага check_no_rewrite | явная строка | 1 | — | verify_ci_parity | ESSENTIAL; путь вне зоны (Б-3) |
| сужение 5-й формы verify_ci_parity | инв. 3 | нет | 1 | интерфейс сузился, −24 строки | gate-шаг check:ci-parity | ESSENTIAL, сложность уменьшилась |
| (в′) в `incr_parse` | инв. 6 (в′), единый источник | INCR_MODE/INCR_CACHE, маркер stderr | 2 → 1 (pre-parse удалён) | библиотека углубилась | И4-3/И4-4 ×4 | ESSENTIAL, сложность уменьшилась |
| `mkdir -p` в `incr_finish` | инв. 6(б) на CI-пути §Зоны | каталог tmp/ci-incr | 1 | — | И4-5 ×4, А3 | ESSENTIAL |
| клетки Г10 + Г-С3..Г-С7 | этикет §Зоны (restore всегда, save push+PR) | нет | батарея | одна функция-оракул, 5 стабов с диффпробами | А1, CI-шаг | ESSENTIAL; дыра: не судит, КАКАЯ lane сохраняет (Б-1) |
| клетки И4-3/И4-4 ×3 чека, И4-5 ×4, стаб И-С6 | инв. 6 (в′)/(б) у всех четырёх чеков (инв. 7) | нет | батарея | семья — один артефакт | А1 | ESSENTIAL |
| пустые коммиты orchestrator ×3 | нет свойства — триггер CI | нет | 0 | — | — | вне кода, не судится 050 |

## 7. Что нужно до следующего круга

1. Б-1: условие lane на каждый save-шаг, клетка Г10 «save чека X только в lane с ключом X».
2. Б-2: HEAD окна фиксируется в `incr_parse`, `incr_finish` пишет его, окна чеков — `..$INCR_HEAD`. Плюс клетка сдвига HEAD.
3. Б-3: ЗОНА-строка (architect v4) либо РАЗРЕШИЛ-ВЛАДЕЛЕЦ на `config/ci_parity_exceptions.txt`.
4. Б-4: граница 37552402176 (либо новая, названная ДО прогона), ≥ 2 линейных прогона ветки `wip/083/…`, `timing_083.sh` rc 0.

— reviewer, 2026-10-07.
