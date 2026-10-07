ACCEPT

Три блокера круга 3 закрыты. Каждый проверен своей мерой в своём одноразовом клоне.
- **Б-2r** (`scripts/lib_incr.sh`). `incr_parse` фиксирует `INCR_HEAD` один раз, до ветвления. `incr_finish` пишет только его.
- **Б-5** (клетка И15). Откат `lib_incr.sh` к `origin/main` краснит И15 в ветвях (б) и (в′). Откат к `c419a22^` краснит её во всех трёх ветвях.
- **Б-6.** Блока CACHE SAVE в генераторе нет. В ci.yml 8 статических save-шагов, Г10 их по-прежнему сторожит.

Выхода за зону нет, норма не тронута. Новых блокирующих нет. Неблокирующие — в §Приложение.

# Reviewer 083, круг 4 (гейт перед слиянием)

- **Предмет:** `frozen/contracts/083/3`. Блоб контракта `b00f9318` на теге и на tip одинаков. `sha1sum` файла `45594f4a` — тот же, что в круге 3.
- **Судимые коммиты:**
  - `c5cbfd4353fd98649f8ba6ce5b6958b1004a23f6` (`origin/wip/083/implementer`);
  - `6e11f2f7d44d2830c24b95111dffe29e036a510d` (`origin/wip/083/architect`).
  - Обе ветки от `24fb8e5`, по одному коммиту каждая. База слияния — `origin/main` `2c931910`.
- **Клон:** `/tmp/dev-harness-verify/rev083k4-1791388658/repo`, из `ssh://git@github.com/a3ka/dev-harness.git`.
  - `merge --no-ff` implementer → `2139409922e0`, затем architect → `2986b2c8`. Identity reviewer, конфликтов нет.
  - Пробы одноразовые, вне дерева: `/tmp/dev-harness-verify/rev083k4-1791388658/{a1,mut,run_muts,b6,live1,unborn,race_real}.sh`, `edit_ci.py`.
- **База:** `verdicts/review/contracts-083-v3.md` (FAIL @ aab55cc).

| артефакт на tip слияния | блоб |
|---|---|
| `scripts/lib_incr.sh` | `c8c14209` |
| `scripts/gen_ci_steps.sh` | `27cd2a3b` |
| `.github/workflows/ci.yml` | `ff843a3e` |
| `fixtures/ci_gen_083/red_ci_a_083.sh` | `ced49560` |
| `fixtures/_krasnye_083.sh` | `05ecf912` |
| `fixtures/ci_gen_083/.probe-only` | `75adf720` |

Вердикт связан с этими блобами. Новая редакция принятия не наследует.

## 1. Область правки

Своя мера: `git show --stat c5cbfd4 6e11f2f` и `git diff --stat origin/main <tip слияния>` (6 файлов, +217/−161).

| коммит | автор / коммиттер | файлы | ЗОНА 083/3 |
|---|---|---|---|
| c5cbfd4 | implementer / implementer | `.github/workflows/ci.yml`, `scripts/gen_ci_steps.sh`, `scripts/lib_incr.sh` | implementer (:402-403) |
| 6e11f2f | architect / architect | `fixtures/_krasnye_083.sh`, `fixtures/ci_gen_083/.probe-only`, `fixtures/ci_gen_083/red_ci_a_083.sh` | architect (:401) |

- Выхода за зону нет.
- Implementer не трогал проверки: `git diff --stat origin/main origin/wip/083/implementer -- fixtures` пуст.
- Architect не трогал субъект: `git diff --stat origin/main origin/wip/083/architect -- scripts .github registry` пуст.
- `bash scripts/check_zones.sh` на tip слияния → rc 0, «проверено по зонам: 1878».

## 2. А1 — живой прогон

`bash a1.sh <клон>`: `bash fixtures/_krasnye_083.sh`, своя мера `grep -c '^  ok '` / `'^  FAIL '`. Прогнано дважды, оба раза одинаково.

```
tree=/tmp/dev-harness-verify/rev083k4-1791388658/repo rc=0 ok=107 FAIL=0
083-батарея: ok=107 FAIL=0 (до реализации части Г и И красны по умыслу)
  ok   И15: сдвиг HEAD между incr_parse и incr_finish — кеш = HEAD старта во всех ветвях, стаб «finish пишет HEAD конца» пойман; (а) кеш = HEAD старта 234433dc, коммит гонки ee77f4e6 — в следующем окне; (б) кеш = HEAD старта 234433dc, коммит гонки ee77f4e6 — в следующем окне; (в′) кеш = HEAD старта 234433dc, коммит гонки ee77f4e6 — в следующем окне
```

107 = 106 круга 3 + И15. Заявление оркестратора (107/0) совпало со своей мерой.

## 3. Красное — откат каждого фикса отдельно

`run_muts.sh`: копия tip (`cp -a`), один откат, затем батарея. Пять мутантов параллельно, каждый в своём каталоге.

| мутант | rc | ok | FAIL | красные клетки |
|---|---|---|---|---|
| — честный tip | 0 | 107 | 0 | — |
| M1 `lib_incr.sh` ← `origin/main` (форма aab55cc: откат Б-2r) | 1 | 106 | 1 | **И15, ветви б и в′**: «(б) кеш = коммит гонки ddcdf626, ждали HEAD старта 164a7124 — коммит, пришедший во время прогона, не судится никогда». (а) зелена — так и должно быть: её закрыл круг 3 |
| M2 `lib_incr.sh` ← `c419a22^` (до Б-2 круга 2) | 1 | 106 | 1 | **И15, ветви а б в′**: кеш = коммит гонки во всех трёх |
| M4 ci.yml: push-save zones → подстрочный `contains(matrix.keys, 'check:zones')` | 1 | 106 | 1 | Г10-push/zones: «сохраняет path tmp/ci-incr/zones.sha в lane l6 без ключа check:zones» |
| M5 ci.yml: удалён pr-save protected | 1 | 106 | 1 | Г10-pr/protected: «в lane l4 (ключ check:protected) нет save-шага» |
| M7 gen + ci.yml ← `origin/main` (полный откат Б-6) | 0 | 107 | 0 | нет — ожидаемо |

- Б-5 закрыт буквально по требованию круга 3 §7 п.2: «красна против `c419a22^` (все три ветви) и против aab55cc (б/в′)». Это M2 и M1.
- Стаб «finish пишет HEAD конца» пойман на честном tip во всех ветвях. Его поимка — условие зелени И15 (`race_stub`). Поэтому клетка не зеленеет на драйвере, который гонку не различает.
- M7 зелёный. Б-6 — упрощение по 050, поведение не меняется, барьер не требовался. Б-6 судится отсутствием блока и равенством генератора форме до CACHE-блока (§4). Семантику save-шагов сторожит Г10 (M4, M5) независимо от генерации.

## 4. Б-2r и Б-6 — своей мерой

**Б-2r.**
- `lib_incr.sh:124-130`: `head` читается и `INCR_HEAD="$head"` ставится сразу после «без `--incr` → return», до проверки `[ ! -f "$INCR_CACHE" ]`.
- `incr_finish` (:197-211) пишет только `INCR_HEAD`. Ветвь `else rev-parse HEAD` удалена; на пустом `INCR_HEAD` — no-op.
- Драйвер И15 повторяет протокол чеков: `incr_parse` из cwd = корень, затем `INCR_GIT_ROOT=<корень>`, затем `incr_finish`. Порядок сверен по `check_protected.sh:183-188,632`.
- Сквозь реальный чек (`race_real.sh <rev>`): копия tip, `lib_incr.sh` из `<rev>`, `bash scripts/check_ids.sh --incr tmp/ci-incr/ids.sha` в фоне (ветвь (б)), через 2 с коммит `late`, затем `wait`:
  ```
  lib@HEAD check_ids rc=0 | incr: check_ids полный прогон (кеш отсутствует) | старт=87cadb4e late=0109c946 кеш=87cadb4e → кеш = HEAD старта
  lib@origin/main check_ids rc=0 | incr: check_ids полный прогон (кеш отсутствует) | старт=59c6d7f0 late=f5d07c13 кеш=f5d07c13 → КЕШ = late (не судим)
  ```
  Ветвь (в′) — `race_real.sh <rev> в′`, кеш = sha сторонней линии:
  ```
  (в′) lib@HEAD check_ids rc=0 | incr: check_ids полный прогон (база 15500ee0 не предок HEAD 4029ede9 — кеш сторонней линии) | старт=4029ede9 late=68f91472 кеш=4029ede9 → кеш = HEAD старта
  (в′) lib@origin/main check_ids rc=0 | incr: check_ids полный прогон (база 95058671 не предок HEAD df8049f1 — кеш сторонней линии) | старт=df8049f1 late=0a6eec9a кеш=0a6eec9a → КЕШ = late (не судим)
  ```
  Тот же дефект и тот же фикс, что в И15, но на настоящем чеке, а не только на драйвере батареи.

**Б-6** (`b6.sh`, сырой вывод сжат построчно):
```
-- CACHE-идентификаторы в генераторе (код, без комментариев):
rc_grep=1 (1 = нет в коде)
-- маркеры GENERATED в ci.yml: SHARDS :44/:55, JOBS :102/:117 — CACHE-маркеров нет
-- save-шаги в ci.yml: 8   (:241…:276, токенное условие, push/pull_request × 4 чека)
-- python argv генератора: ciyml, jb, je, jg, sb, se, sg = sys.argv[1:8]
gen --check rc=0
gen --write rc=0 ; diff-после-write пуст? да ; check-после-write rc=0
write×2 save=8 BEGIN=2
parity rc=0  (… расхождений: 0)
provodka rc=0
```
- `git diff 7c8fad4 <tip> -- scripts/gen_ci_steps.sh` — +14/−0, только строки комментария. Код генератора побайтово равен форме до CACHE-блока; это простая форма `static050.sh` круга 3.
- Вред `endless.sh` круга 3 (16 save-шагов после `--write`) снят: двойной `--write` даёт 8 save и 2 BEGIN.

## 4a. Живой прогон четырёх чеков в incr-режиме

`live1.sh <чек>`: копия tip, `rm -rf tmp/ci-incr`, команда шага из реестра `bash scripts/check_<c>.sh --incr tmp/ci-incr/<c>.sha`. Сначала ветвь (б), затем повтор — ветвь (а), 0 коммитов.
```
ids (б) rc=0 кеш==HEAD:да | incr: check_ids полный прогон (кеш отсутствует)
ids (а) rc=0 | incr: check_ids судит 2986b2c8..2986b2c8 (0 коммитов)
protected (б) rc=0 кеш==HEAD:да | incr: check_protected полный прогон (кеш отсутствует)
protected (а) rc=0 | incr: check_protected судит 2986b2c8..2986b2c8 (0 коммитов)
zones (б) rc=0 кеш==HEAD:да | incr: check_zones полный прогон (кеш отсутствует)
zones (а) rc=0 | incr: check_zones судит 2986b2c8..2986b2c8 (0 коммитов)
charter (б) rc=0 кеш==HEAD:да | incr: check_charter полный прогон (кеш отсутствует)
charter (а) rc=0 | incr: check_charter судит 2986b2c8..2986b2c8 (0 коммитов)
```

charter — тем же рецептом из `live4.sh`, четыре чека подряд. Все четыре чека: (б) засевает кеш HEAD старта, (а) следом судит пустое окно, rc 0.

## 5. ПРОВОДКА (038) и норма

- `bash scripts/check_provodka.sh . contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md` → rc 0.
- Guard `fixtures/_krasnye_083.sh` — барьер этого предмета. И15 добавлена в семью ci_gen_083 и запускается этим guard. Подключение прямым шагом `run: bash fixtures/_krasnye_083.sh` в ci.yml не тронуто.
- Норма не тронута:
  - `git diff --stat origin/main <tip> -- AGENTS.md roles contracts frozen docs/norms` пуст;
  - блоб контракта на `frozen/contracts/083/3` и на tip одинаков (`b00f9318`);
  - `git log aab55cc..origin/main` по 083-путям пуст.
- Н-39: привязка стаба И15 к ветвям лежит в коде батареи (`red_ci_a_083.sh`, шапка о стабах и `race_stub`), не в прозе контракта. Контракт в круге 4 не правился.

## 6. Паразитная сложность (050) — артефакты диффа круга 4

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `lib_incr.sh`: фиксация `INCR_HEAD` до ветвления, `incr_finish` без `else` (+34/−27, в основном комментарий) | НЕ ЗАЩИЩАЕТ :188 — окно от HEAD старта во всех ветвях И-6 | `INCR_HEAD` явный (объявлен в шапке :23), один источник вместо двух | 1, не выросло | интерфейс тот же, ветвей меньше — модуль глубже | И15 (M1/M2 красны), CI-шаг `_krasnye_083.sh` | ESSENTIAL |
| `gen_ci_steps.sh`: снят CACHE SAVE (−135, +14 комментария) | контракт :83-90, «оба блока» | снят неявный режим `CACHE_MARKERS_PRESENT` | правка save снова в 1 файле (ci.yml), было 2 | интерфейс сжат: 2 пары маркеров, argv python 7 вместо 11 | Г1/Г3/Г8 (`gen --check`), Г10 | ESSENTIAL (упрощение, закрывает ACCIDENTAL круга 3) |
| ci.yml: 8 save-шагов статикой, комментарий перенесён над ними | §Зоны :432-433, save — только lane-владелец | нет | 1 | — | Г10 ×8 (M4/M5 красны) | ESSENTIAL |
| `red_ci_a_083.sh` И15: `race_toy`/`race_input`/`race_drive`/`race_window_ok`/`race_marker_ok`/`race_subject`/`race_stub` (+134), семья одним артефактом | критерий 4 «красное предъявлено» на фикс Б-2/Б-2r; НЕ ЗАЩИЩАЕТ :188 | toy в `$SCRATCH`; коды драйвера 90/91/92 попадают в причину | 1 (батарея) | одна клетка, причина по каждой ветви. Переиспользованы `side_line_sha`, `input_class`, `cache_written_ok` | А1, CI-шаг; M1/M2 | ESSENTIAL. `race_window_ok` повторяет разбор строки окна, но держит свой контракт клетки: префиксы sha и «ровно одна строка». Совет, не находка |
| `.probe-only`, `_krasnye_083.sh`: строки об И15 | учёт клеток семьи | — | — | — | — | не код |

ACCIDENTAL-находок нет.

— reviewer, 2026-10-07.

---

# Приложение — находки (reslop)

Путь `.review/` вне ЗОНА reviewer — прецедент `500ce56`, как в круге 3.

```
---
status: ready
subject: contracts/083 (frozen/contracts/083/3), круг 4 — c5cbfd4 (implementer), 6e11f2f (architect); слияние в клоне reviewer 2986b2c8 поверх origin/main 2c93191
verdict: verdicts/review/contracts-083-v4.md (ACCEPT, круг 4)
reviewer: reviewer
prev: verdicts/review/contracts-083-v3.md
---
```

## Закрыто (своей мерой)

- [x] **Б-2r** — `INCR_HEAD` до ветвления, `incr_finish` без `else`. И15 зелёная во всех ветвях. M1 (форма aab55cc) → И15 красна в б и в′.
- [x] **Б-5** — клетка И15 и стаб «finish пишет HEAD конца». M2 (`c419a22^`) → красны а, б, в′. M1 → красны б, в′.
- [x] **Б-6** — CACHE SAVE вне генератора. Код gen равен форме 7c8fad4 (+14 строк комментария). 8 save-шагов статикой, Г10 их сторожит (M4/M5). `--write` идемпотентен, `--check` rc 0.
- [x] **Н-1, часть 1** (круг 3) — осиротевший комментарий о save-шагах перенесён над ними.

## Неблокирующие

- [ ] **Н-1, часть 2** (implementer). В комментарии ci.yml у шага батареи 083 сказано «Прямой шаг ВНЕ матрицы». Это неверно: шаг стоит в матричной джобе `ci` и исполняется ×7 lane (перенос Н-5 круга 2).
- [ ] **Н-2** (атомарность, совет, повтор). c5cbfd4 снова несёт два фикса одним коммитом: Б-2r (`lib_incr.sh`) и Б-6 (gen + ci.yml). Файлы раздельны и откатываются по путям, поэтому это не отказ. Совет круга 3 не учтён.
- [ ] **Н-7** (implementer, совет). Фиксация HEAD до ветвления сменила исход ветви (б) на репо без коммитов (`unborn.sh`, `origin/main` против tip):
  - было — `полный прогон (кеш отсутствует)`, `INCR_RC=0`;
  - стало — `ОТКАЗ: не удалось прочитать HEAD в .`, `INCR_RC=1`.
  - Вне входов контракта: :131 требует вызова из корня судимого дерева, все входы И4 с историей. Отказ громкий, не тихий. Назвать в комментарии или принять как есть.
- [ ] **Н-8** (implementer, совет). Комментарии `gen_ci_steps.sh:55-68` и комментарий над save-шагами ci.yml несут историю правок («круг 4 implementer», «rev 4»). Комментарий генератора к тому же описывает содержимое ci.yml и устареет при следующей правке save-шагов: второй файл, который обязан меняться вместе.
- [ ] **Н-3** (перенос). А-374: исключительность Г10 по точному `with.path` открыта. Текущий ci.yml конформен.
- [ ] **Н-4** (перенос). Б-3 круга 2 — `forks/083-ci-parity-exceptions-zona.md`, ОТВЕЧЕНО: нет.
- [ ] **Н-5** (перенос, оркестратор). А3 и живое подтверждение lane-владения save — на приёмочных ранах после границы.
- [ ] **Н-6** (перенос). `incr_finish` молчит на отказе записи (mktemp/mv → `return 0`).
