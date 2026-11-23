accept
OBJECT=b83edfaacf6368d69f809e08f229ecadd475f503
СУД: репо=dev-harness; предмет=206; роль=reviewer; вызов=2 (узкий); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev206b | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущие=verdicts/review/contracts-206-impl-v1.md (FAIL, архив archive/206/reviewer-v1-fail-696a4c00ca), adversary FAIL ×3; класс риска=рисковый
КЛАСС=КОДОВЫЙ (+ нормы ролей). Adversary-accept не получен; остаток принят словом владельца 23.11. Закрытие блоков Б-1/Б-2 и `sweep.py --check` закреплены ниже моими собственными прогонами.
Контракт: contracts/206-sreda-sudji.md. Блоб на HEAD = блоб `frozen/contracts/206/1` = `7b89189a2825e7a32618e643cc67b9abb09599bc`.
Находки: блоков 0. Советов 2 (С-8, С-9) — `.review/2026-11-23-155.md`.

# Вердикт reviewer — 206, реализация, вызов 2 (узкий scoped-повтор)

## Итог

**accept.** Б-1 и Б-2 вызова 1 закрыты: каждый мутант, воспроизведённый мной по одному на копии реального файла, красит `--repo <мутант>` rc 1 именно своими клетками. Честный `--repo .` зелёный на 2226/2226.

Советы С-1…С-4 закрыты. С-1/С-2 закрыты по названным трём записям. В двух соседних записях остался тот же класс — это советы С-8/С-9, блоком они не являются: решение либо то же, либо строже, pass-дыры нет.

Весь регресс п. 5 зелёный, включая `pre_critic` и `check_sdacha --run`. Production (`path-guard.ts`, `pre_judge.sh`, `roles/*`, `.omp/agents/*`) и frozen-текст контракта с прежнего OBJECT не менялись.

## Носитель (ПЕРЕСБОРКА)

```
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/206/orchestrator-r2 ; git switch --detach b83edfaac… ; git rev-parse HEAD → b83edfaacf6368d69f809e08f229ecadd475f503
git diff --stat 066ced02a b83edfaac -- fixtures/workshop_project/sreda_sudji_206 .omp/extensions/path-guard.ts scripts/pre_judge.sh roles .omp/agents   → пусто, rc 0
git diff --stat 2d7e8b6b4e 066ced02a → только sreda_sudji_206/{SDACHA.md,matrix.py,probe.py,review_delta.py(new),stabs.tsv,sweep.py}: 6 files +203 −128
git diff --stat 2d7e8b6b4e 99c2a8e85 → те же 6 + ci.yml, ci-steps.tsv, ci-zamery.tsv: 9 files +211 −136
```

Содержательный diff побайтно равен tip Arch206g. Носитель на main `d4d4c5c09`. `main` origin уже `045629ead` — это вне скоупа, п. 8: пересборка — оркестратор.

## ОСТАТОК (контракт 192)

Строки НЕ ЗАЩИЩАЕТ контракта нумерую по порядку: НЗ-1…НЗ-5.

- ОСТАТОК: НЗ-1 (компрометация старта/интерпретатора/бинарника, гонка uid; ловец reviewer) — не укусил. Дельта вызова 2 production не трогает: `git diff 066ced02a b83edfaac -- .omp/extensions/path-guard.ts scripts/pre_judge.sh` пуст.
- ОСТАТОК: НЗ-5 (формы shell вне грамматики cp/mkdir; ловец adversary/reviewer) — укусил вне грамматики, без изменений с вызова 1 (С-5 там же). Место — `path-guard.ts:450-451`, в этой дельте не тронуто. Принятая граница арбитража `5a7f571e10`, не блок.
- НЗ-2, НЗ-3, НЗ-4 — ловец не reviewer: живая тройка и orchestrator. NOT_RUN, LIVE_JUDGES_NOT_RUN.

## 1. Область правки

`git diff --stat d4d4c5c09 b83edfaac` → 19 files +1476 −234: вся реализация 206 плюс батарея и CI. Зоны по коммитам (`%an|%cn`; committer orchestrator — это cherry-pick пересборки):

| Коммит | Автор | Файлы |
|---|---|---|
| `424885387` | implementer | `.omp/extensions/path-guard.ts`, `scripts/pre_judge.sh` |
| `6a56559c4` | implementer | `roles/{adversary,critic,reviewer}.md`, `.omp/agents/{adversary,critic,reviewer}.md` |
| `b9935681d`, `211ddc37f`, `07a804180`, `8eaaddab5`, `f550ba210` | architect | только `fixtures/workshop_project/sreda_sudji_206/**` |
| `b83edfaac` | orchestrator | `.github/workflows/ci.yml`, `registry/ci-steps.tsv`, `registry/ci-zamery.tsv` |

Превышения нет. CI-дифф к main — одна строка `step check:sreda-sudji-206-family-selftest 220 …--repo . && --model && --stabs` и одна строка замера `220 217 0`. `gen_ci_steps.sh --check` → rc 0.

Вес — это LPT-балансировка (секунды замера), не таймаут. Моя сумма ног: 33.1 + 26.4 + 162.9 = 222.4 с при параллельной лёгкой нагрузке. С весом 220 сходится в пределах шума.

## 2. Б-1 — закрыт (воспроизвёл сам)

**Мутант.** Одна замена в копии реального `path-guard.ts:1111` (кратность якоря 1): `if (!isWriteCommand(cmd)) return { decision: 'pass' };` → `if (false) return { decision: 'pass' };`.

```
bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo .scratch-rev206b/mutB1
  guard-quoted-greater-stderr-null: KRASEN  expected=(0, b'{"decision":"pass"}\n', b'')  actual=(0, b'{"decision":"block","reason":"запись вне пина запрещена — Н-85: путь /dev/null …')
  KLETKI=2226 ZELENYE=2225 KRASNYE=1        rc=1
```

**Честный guard.** Та же клетка (`grep -n 'a > b' notes.md 2>/dev/null`, cwd своей копии) зелёная в `--repo .` (2226/2226). Соседняя `guard-quoted-greater-stderr-merge` (`2>&1`, cwd копии) зелёная и на мутанте. Причина по коду: `&1` разрешается внутри своей копии. SDACHA это оговаривает — это честный контроль, а не ложное требование.

**Запись `EQUIVALENTS`.** Удалена: `git diff 2d7e8b6b4e 066ced02a -- …/sweep.py`.

**Стаб.** `quoted-read-stderr-is-write` с якорем ровно этой строки в `probe.MUTATIONS` → `--stabs`: `quoted-read-stderr-is-write: guard-quoted-greater-stderr-null: POIMAN`.

**sweep.** `sweep.py --check`: `ca72ade2ebeb` отсутствует среди EKVIVALENT/ZHIV/AVARIA, то есть POIMAN (81 + 27 + 4 = 112).

## 3. Б-2 — закрыт (воспроизвёл сам)

**Мутант.** `scripts/pre_judge.sh:376` `realpath -m -- "$vcandidate"` → `realpath -mL -- "$vcandidate"` (кратность 1).

```
bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo .scratch-rev206b/mutB2
  verdict/{abs,rel}/{plain,double,dot,existing}/dir-symlink-dotdot/outside: KRASEN  (8 строк)
  KLETKI=2226 ZELENYE=2218 KRASNYE=8        rc=1
```

Красные ровно 8 внешних `dir-symlink-dotdot`. Все 8 внутренних (`m206dlink-in/../x.md`, ссылка внутри repo → `copy/verdicts`, физически `copy/x.md`) зелёные и на мутанте — это допущенный честный внутренний контроль. В честном `--repo .` все 16 зелёные.

Мир (`matrix.py:83-84`): `m206dlink-out → other`. Значит, `m206dlink-out/../x.md` физически лежит в sandbox вне repo, а логически — в `copy/x.md`. Различение порядка «symlink раньше `..`» наблюдаемо.

**Стаб.** `verdict-logical-before-physical` (`probe.py`, селектор `('verdict',) + VERDICT_SYMLINK_DOTDOT`) → `--stabs`: `verdict/rel/plain/dir-symlink-dotdot/outside: POIMAN SELEKTOR neg=8 ctl=8 krasnyh=8:POIMAN`.

## 4. Советы С-1…С-4 и `review_delta.py`

**С-1/С-2 — закрыты по названным записям.** Записи `sweep.py:126-127` (`!path.startsWith('/')`), `:128-129` (`slash<=0`), `:132-133` и `:136-137` (`canonicalWt!==null continue` if-false/del-continue) теперь честно говорят «ловца нет» с обоснованием. Эквивалентность проверена мной по коду и исполнением — 4 записи, мутант одной заменой в копии реального файла, вход через `guard_driver.mjs`:

| Запись | Вход | Честный | Мутант | Вывод |
|---|---|---|---|---|
| `!path.startsWith('/')` if-false (`:1072`) | `write verdict.md`, пин и без пина | block «относительный путь записи запрещён…» + HINT | block «запись вне пина…» / «…непиннованной сессии…» + HINT | решение то же, диагноз 025 подменён — С-8 |
| `canonicalWt!==null continue` if-false (`:1127`) | bash `echo x > local://note.md`, пин | pass | block «внутренний URI непиннованной сессии…» | строже, «ловца нет» верно |
| `slash <= 0` if-false (`:150`) | по коду `realAncestorWithin:133-153` | `/nonexist206` → false → block | `probe.slice(0,-1)` на `''` — бесконечный цикл | pass невозможен, запись верна |
| `isAllowedURI(resolved)` if-false (`:993`) | bash `echo x > note.md`, `cwd: local://dir`, пин | pass | block «запись вне пина… local://dir/note.md» | строже. Названный ловец «025/030» на мутанте: `red_pin_allowlist`/`red_granica_nepin_pipe_tee`/`red_strazh_vectora_utechki` rc 0/0/0 — С-9 |

Канал подтверждён: `red_pin_allowlist.sh <мутант canonicalWt→pass if-false>` → rc 1, то есть батарея действительно судит корень мутанта.

**С-3 — закрыт.** Своя мера (python-импорт):
- `len(TS_PREDICATES)=33`, `len(SH_PREDICATES)=14`;
- `Counter(build_mutants по файлу)` = path-guard.ts 89, pre_judge.sh 23, всего 112;
- `EQUIVALENTS` = 27 (TS 26 + SH 1), все ключи соответствуют мутантам.

`SDACHA.md:84-85` теперь пишет «33 предиката TS и 14 SH … порождают 89 и 23 мутанта» — совпадает.

**С-4 — закрыт.** `sweep.py:453` `return 1 if unexplained or stale else 0`.

```
python3 fixtures/workshop_project/sreda_sudji_206/review_delta.py stale
  MUTANTOV=1 POIMANY=1 ZHIVYH=0 EKVIVALENTOV=0 AVARII=0   (честный пустой список)
  MUTANTOV=1 POIMANY=1 …  EKVIVALENT_POIMAN (запись устарела): (path-guard.ts, "if (!isWriteCommand(cmd)) …", 'if-false')
  DELTA_STALE honest_rc=0 stale_rc=1        rc=0
```

**`review_delta.py` — не подгонка.** Код (43 строки):
- `block1`/`block2` сужают `probe.MUTATIONS` до одной записи и вызывают неизменённый `probe.main()` `--stabs`. Тот же честный контроль, мир селекторов и сравнение полных (rc, stdout, stderr).
- `stale` сужает `sweep.build_mutants` до реального `ca72ade2ebeb` и вызывает неизменённый `sweep.run(check=True)` дважды: с пустым списком и с внесённой устаревшей записью.
- Judge, исход и классификатор не подменяются. Неуникальность имени или id — громкий `RuntimeError`, а не тихая зелень.

```
review_delta.py block1 → quoted-read-stderr-is-write: guard-quoted-greater-stderr-null: POIMAN; OBMANOK=1 POIMANY=1 ZHIVYH=0  rc=0
review_delta.py block2 → verdict-logical-before-physical: …: POIMAN SELEKTOR neg=8 ctl=8 krasnyh=8:POIMAN; OBMANOK=1 POIMANY=1 ZHIVYH=0  rc=0
```

## 5. Регресс (по одному, cwd = копия, `TMPDIR=$PWD/.scratch-rev206b`)

| Команда | rc | Итог / своя мера |
|---|---|---|
| `bash …/red_sreda_sudji_206.sh --repo .` | 0 | `KLETKI=2226 ZELENYE=2226 KRASNYE=0`. Своя мера: строк `: ZELEN` = 2226, `verdict/` = 64. 33.1 с |
| `bash …/red_sreda_sudji_206.sh --model` | 0 | `KLETKI=2226 ZELENYE=2226 KRASNYE=0`. Своя мера: 2226 строк `: ZELEN`. 26.4 с |
| `bash …/red_sreda_sudji_206.sh --stabs` | 0 | `OBMANOK=45 POIMANY=45 ZHIVYH=0`. Своя мера: 45 строк POIMAN, 18 строк SELEKTOR, ни одной с `neg=0`/`ctl=0`. 162.9 с |
| `python3 …/catalog.py --check` | 0 | `STABS=45 NORM_CONSUMERS=3`. Своя мера: строки `stabs.tsv` (45) == `[(name, cell, path)]` из `probe.MUTATIONS` по порядку — True |
| `python3 …/sweep.py --check --verbose` | 0 | `MUTANTOV=112 POIMANY=81 ZHIVYH=27 EKVIVALENTOV=27 AVARII=4 SEKUND=201.6`; NEOBYASNENNYJ и EKVIVALENT_POIMAN нет |
| `python3 …/live_control.py` | 0 | `OBSERVER_CONTROLS=21 KRASNYE=0; LIVE_JUDGES_NOT_RUN` |
| `bash fixtures/path_guard/red_own_copy_paket_b.sh .` | 0 | ветвей 13, красных 0, зелёных 13 |
| `bash fixtures/path_guard/red_extract_pin_actual_066.sh .` | 0 | ветвей 15, красных 0, зелёных 15 |
| `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo` | 0 | своя мера: строк ` ok ` = 16 |
| `node scripts/gen-harness.ts --check` | 0 | харнес соответствует roles/ (13 ролей) |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash scripts/pre_critic.sh contracts/206-sreda-sudji.md` | 0 | `КРИТИК: дверь зелёная`, real 8m17.0s |
| `bash scripts/check_sdacha.sh "$PWD" contracts/206-sreda-sudji.md --run` | 0 | `СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3)`, real 6m13.5s (≤ 900 с) |
| `bash scripts/validate_std.sh bash …/red_sreda_sudji_206.sh` (shellcheck 0.11.0) | 0 | — |

**Четыре аварии `sweep`** — те же id, что в вызове 1: `a51b17655525`, `c94b42a9f7c4`, `4a2cd4104ea5`, `48c5a6d2b0b5`. Там они разобраны поштучно: ложного pass нет. Production не менялся, повтор не требуется.

**Объём клеток своей мерой.**
- Вердиктных строк 64 = 2 × 4 × 4 × 2. Прежние 48 + 16 `dir-symlink-dotdot`.
- Guard-статика: +2 (`guard-quoted-greater-stderr-{null,merge}`).
- Итог 2208 + 18 = 2226 — сходится с `KLETKI` и со своей мерой строк.

## 6. Неподгонка

- **Стабы.** `stabs.tsv` — побайтовая производная `probe.MUTATIONS`: `catalog.py --check` rc 0 и моя сверка выше. Дельта `stabs.tsv`: +2 −0. Прежние 43 не тронуты.
- **Клетки.** Новые клетки не вырождены:
  - Б-1-клетка краснеет только на своём мутанте;
  - селектор Б-2 — neg 8 / ctl 8, обе стороны непусты;
  - внутренний контроль `dir-symlink-dotdot/inside` удерживает мутанты, которые отвергают любое «ссылка + `..`».
- **Ожидания.** Удалённых или ослабленных ожиданий в дельте `matrix.py`/`probe.py` нет: только добавления и расширение `elif form in (…)`.
- **Production.** Implementer-коммиты фикстур не трогали. Architect-коммиты production не трогали.

## ПРОВОДКА (038)

Каналы не менялись с вызова 1:
- role-канал — три `roles/*.md` с NORM, `NORM_CONSUMERS=3`, `gen-harness --check` rc 0;
- guard-канал — `red_sreda_sudji_206.sh`, барьер этого предмета, подключён строкой `registry/ci-steps.tsv` `check:sreda-sudji-206-family-selftest`.

`pre_critic` нога «проводка красна» → ok.

## Паразитная сложность (050) — артефакты дельты

Пять вопросов: (1) свойство; (2) состояние; (3) совместные правки; (4) глубина; (5) потребитель.

- **`review_delta.py` (новый, 43 строки).**
  - (1) Адресный контроль закрытия Б-1/Б-2/С-4 в строках Дельты SDACHA (К-11, К-07) в бюджете листа ≤ 900 с. Полный повтор `--stabs` в Дельте дал 912.4 с, rc 1 (замер SDACHA).
  - (2) Постоянного состояния нет. Подмена module-глобалов в процессе видна в коде; вывод — `DELTA_STALE honest_rc/stale_rc`.
  - (3) Имена стабов и sweep-id захардкожены. Их правка требует правки `review_delta.py` — плюс 1 файл, но дрейф даёт громкий `RuntimeError`.
  - (4) Один позиционный аргумент из 3 значений, вся работа — в существующих `probe`/`sweep`.
  - (5) Три строки Дельты SDACHA, в CI не входит, грамматику не повторяет.
  - Более простая форма — флаг `--only` в `probe`/`sweep`: это та же сложность, перенесённая в интерфейс двух модулей. ESSENTIAL.
- **`sweep.py` `or stale` (1 строка).** (1) С-4 / норма `--check`; (2)–(5) — без нового интерфейса, потребитель — дверь `--sweep`. ESSENTIAL.
- **`matrix.py` форма `dir-symlink-dotdot` (данные оси) и две guard-клетки `probe.py`.** (1) Б-2/инв. 6 и Б-1/инв. 1; новых функций и флагов нет, только данные. ESSENTIAL.
- **Два стаба `MUTATIONS` + 2 строки `stabs.tsv`.** Производная, `catalog.py --check`. ESSENTIAL.
- **CI вес 220 + замер 217.** (1) Замер трёх ног. ESSENTIAL.

## СВЕРКА-СТАНДАРТОВ

н/п — `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (как в вызове 1).

## СВЕРКА-АРХИТЕКТУРЫ

- **Размещение.** Дельта вызова 2 — только семья `fixtures/workshop_project/sreda_sudji_206/**` и три CI-файла.
- **Писатели и операции.** Новых писателей состояния нет: `review_delta.py` пишет только scratch через существующие `probe`/`sweep`. Операции guard не расширены, production не менялся.
- **`bindings.json`.** Для harness не объявлен (SDACHA К-17 н/п).
- **Долг.** Не расширен.
- **Уровень diff модели.** Изменений `model/` нет (н/п). Решение владельца L2/L3 не требуется.

## Что вердикт НЕ ЗАЩИЩАЕТ

- Живую тройку судов после рестарта (инв. 7), ТЕГ 4, рестарт проектов — не исполнялись, LIVE_JUDGES_NOT_RUN. Ловец — оркестратор после accept.
- **Полноту батареи по произвольным комбинациям.** Проверено:
  - 112 автомутантов `sweep`;
  - 2 мутанта блоков в `--repo`;
  - 3 мутанта поштучно (`!path.startsWith`, `canonicalWt continue`, `isAllowedURI(resolved)`);
  - адресные `review_delta`.

  Иные мутации не исполнялись. Аварии `sweep` поштучно не переразбирались: ссылаюсь на вызов 1, production не менялся.
- Ловец 030 (`red_kanal_qa_report_issue.sh`) на мутантах не измерен: корень аргументом не принимается.
- Конфликт CI-реестров и носителя с новым main `045629ead` — вне скоупа (оркестратор).
- Советы вызова 1 С-5…С-7 в этом вызове не переоценивались.

## Сырые команды

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t4244d3083/m
export TMPDIR=$PWD/.scratch-rev206b VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck
python3 .scratch-rev206b/mut.py . .scratch-rev206b/mutB1 .omp/extensions/path-guard.ts "if (!isWriteCommand(cmd)) return { decision: 'pass' };" "if (false) return { decision: 'pass' };"   # ANCHOR_COUNT=1
python3 .scratch-rev206b/mut.py . .scratch-rev206b/mutB2 scripts/pre_judge.sh 'realpath -m -- "$vcandidate"' 'realpath -mL -- "$vcandidate"'   # ANCHOR_COUNT=1
node fixtures/workshop_project/sreda_sudji_206/guard_driver.mjs file://<honest|mutant>/.omp/extensions/path-guard.ts <inputs.json>   # С-8/С-9 и записи С-1
bash fixtures/check_runner_hygiene/red_{pin_allowlist,granica_nepin_pipe_tee,strazh_vectora_utechki}.sh <мутант isAllowedURI>   # rc 0/0/0
```

Мутанты собраны копией `.omp/extensions`, `scripts`, `roles` и семьи 206 с одной заменой; каждый удалён сразу после прогона. Временный `mut.py`, входы, `.scratch-rev206b` и `.scratch-206` удалены до коммита вердикта.
