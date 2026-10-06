FAIL

Б-1 PR-событие не сохраняет кеш (этикет §Зоны 083/3, А3 на PR недостижим); Б-2 (в′) И-6 только в check_charter, мимо lib_incr.sh (инв. 6); Б-3 правило 6 verify_ci_parity ослаблено «5-й формой» (инв. 3); А3 rc=1 (792 с > 720).

# Reviewer 083, круг 1 (гейт перед слиянием)

- **Предмет:** `frozen/contracts/083/3`. Тег-объект `9a30db60`, коммит `70f8011d`.
- **Судимый tip:** `origin/wip/083/integration-2` = `6aa38a58a18d99a9f549e3bb93b7c72e334320b0`. Сверено `git ls-remote`. PR#36.
- **Клон:** `/tmp/dev-harness-verify/rev083/` — одноразовый клон `ssh://git@github.com/a3ka/dev-harness.git`.
- **Находки:** `.review/2026-10-06-01.md` (reslop, `status: ready`).
- **Путь вердикта:** `verdicts/review/` — каталог, объявленный в `roles/reviewer.md` (`verdict: verdicts/review/`).
  Его читает `done_contract.sh:73` (`verdicts/review/contracts-<NNN>-*.md`). Путь `verdicts/reviewer/…` из задания
  гейт done не видит.

| артефакт | блоб frozen/083/3 | блоб `6aa38a58` |
|---|---|---|
| `contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md` | `b00f9318acd5` | `b00f9318acd5` |
| `fixtures/_krasnye_083.sh` | `b87263d4d577` | `b87263d4d577` |
| `fixtures/ci_gen_083/red_ci_a_083.sh` | `ff8d88ffc445` | `ff8d88ffc445` |
| `fixtures/ci_gen_083/timing_083.sh` | `dc3c87c336ac` | `dc3c87c336ac` |
| `fixtures/ci_gen_083/diff_verdicts_083.sh` | `c9749d422040` | `c9749d422040` |
| `scripts/gen_ci_steps.sh` | — | `46c55edf4472` |
| `scripts/run_ci_lane.sh` | — | `2653063bad3b` |
| `registry/ci-steps.tsv` | — | `47b8583fb7cf` |
| `.github/workflows/ci.yml` | `3b6efbca269a` | `197243bec268` |
| `package.json` | `00807aa2aeac` | `ffef191eb4ae` |
| `scripts/verify_ci_parity.sh` | `5e82c885b7d8` | `0027c794672e` |
| `scripts/lib_incr.sh` | — | `c92f1e16c167` |
| `scripts/check_charter.sh` | `a03290b692e0` | `1dc83fbe83cc` |
| `scripts/check_zones.sh` | `f16fc524cbc7` | `6e7292910616` |
| `scripts/check_ids.sh` | `d578db60721d` | `958e51c9fc93` |
| `scripts/check_protected.sh` | `3903b3e880b6` | `fb34cae291d5` |

Вердикт связан с этими блобами. Новая редакция принятия не наследует.

## 1. Область правки — в границах

База ветки — `5bfc85c4`, `frozen/contracts/083/3` — её предок. Своя мера:

- `git rev-list --count 5bfc85c4..6aa38a58` = **17**: 16 implementer + 1 orchestrator. В задании сказано «15+1», это расхождение счёта.
- Авторы (`git log --format=%an | sort | uniq -c`): implementer ×3, implementer-gen ×8, implementer-incr ×4,
  implementer-incr2 ×1, orchestrator ×1.
- Merge-коммитов нет.

| коммит | автор | файлы |
|---|---|---|
| `6dfbf5fe` | implementer | ci.yml, package.json, ci-steps.tsv, gen_ci_steps.sh, run_ci_lane.sh, verify_ci_parity.sh |
| `6d1cd576` | implementer | 4× do_*_083.txt, check_{charter,ids,protected,zones}.sh, lib_incr.sh |
| `1bccd748` | implementer-gen | ci.yml, ci-steps.tsv |
| `b632a201` | implementer | do_check_charter_083.txt, check_protected.sh |
| `be779ce5` | implementer-gen | ci.yml, package.json, ci-steps.tsv, verify_ci_parity.sh |
| `f00a6607` | implementer-gen | ci.yml |
| `09f0e042` | implementer-gen | gen_ci_steps.sh |
| `9cd64a53` | implementer-incr | check_charter.sh |
| `a63cdec4` | implementer-gen | verify_ci_parity.sh |
| `0ec55cc7` | implementer-gen | ci.yml, gen_ci_steps.sh |
| `61753d22` | implementer-gen | ci.yml, ci-steps.tsv |
| `cbf9a010` | implementer-incr | lib_incr.sh |
| `ce2f0da0` | implementer-incr | lib_incr.sh |
| `9c032c3b` | implementer-gen | gen_ci_steps.sh, run_ci_lane.sh |
| `d4527e49` | implementer-incr2 | check_charter.sh |
| `e6c338e3` | implementer-incr | check_{charter,ids,protected,zones}.sh |
| `6aa38a58` | orchestrator | пусто (пустой коммит) |

Все 15 затронутых путей лежат в двух ЗОНА implementer 083. Каждая пачка держится своей строки:
gen-коммиты — первая строка, incr-коммиты — вторая. Смешанных коммитов нет.

Architect-зона не тронута. `git diff --stat frozen/contracts/083/3..6aa38a58 --` по всем семи путям ЗОНА architect
(контракт, `_krasnye_083.sh`, `red_ci_a_083.sh`, `diff_verdicts_083.sh`, `timing_083.sh`, `.probe-only`,
`docs/owner/2026-10-05-a3-pr-vs-push-analiz.md`) → **пусто**.

Тот же дифф по всему каталогу `fixtures/ci_gen_083/` непуст: 4 файла `do_check_*_083.txt` (+405).
Это эталоны А2 в ЗОНА implementer (строка 403). Ожидание задания «ПУСТО» для `fixtures/ci_gen_083/` целиком
неточно, для architect-путей — выполнено. Проверка под код не переписана.

## 2. Сырой вывод — свои прогоны

**А1** — `bash fixtures/_krasnye_083.sh` на `6aa38a58`, клон `c`:
```
083-батарея: ok=53 FAIL=0 (до реализации части Г и И красны по умыслу)
rc=0
```
Своя мера по логу: `grep -c '^  ok '` = 53, `grep -c '^  FAIL '` = 0.

**ПРОВОДКА-скоуп** — `bash scripts/verify_antiplacebo.sh --scope check_zones check_charter check_ids check_protected land_agent` на `6aa38a58`:
```
барьеров: 5 · фикстур: 99 · предъявлено красным повторным прогоном: 99
rc=0
```
Своя мера:
- в логе 99 строк `  ok `, 0 строк `FAIL`;
- по барьерам: check_zones 38, check_protected 28, check_charter 13, check_ids 11, land_agent 9;
- на диске `ls fixtures/{…}/case_*.sh | wc -l` = 99.

**Генератор/паритет** на HEAD: `bash scripts/gen_ci_steps.sh --check` → rc 0; `bash scripts/verify_ci_parity.sh` → `расхождений: 0`, rc 0.

**ПРОВОДКА 038:**
- guard `fixtures/_krasnye_083.sh` подключён шагом `ci.yml:257` `run: bash fixtures/_krasnye_083.sh`;
- ключ `check:ci-family-selftest` есть в `package.json:80`;
- в CI шаг реально исполняется: логи l3/l4/l7 рана `37521374063` — `083-батарея: ok=53 FAIL=0`;
- guard — барьер именно этого предмета.

## 3. А2 — живой дифференциал полных режимов (своя мера)

Рецепт контракта, вывод в `/tmp/dev-harness-verify/rev083/a2/posle_check_<k>_083.txt`:

| чек | `diff_verdicts_083.sh do_ posle` | расхождение | база `5bfc85c4` против HEAD |
|---|---|---|---|
| ids | rc 0 (1 вердикт) | — | rc 0 |
| zones | rc 1 | только-ПОСЛЕ: 4 строки «работа не раздаётся» контрактов 084–087 | rc 0 (81 вердикт), байтово отличается только счётчиком коммитов в итоговой строке |
| protected | rc 1 | переносы/удаления verdicts/critic/083-v2/v3 и verdicts/consultant/083-* | rc 0 (73 вердикта), отличается только счётчиком «коммитов пройдено» |
| charter | rc 1 | после нормализации счётчиков «коммитов в диапазоне N» только-ДО пусто, только-ПОСЛЕ — 15 строк новой истории (контракты 083–087, разрешённые правки 2c01b1ed/8f57f6d6/0b478cff/…) | см. ниже |

Все rc=1 у `do_ → posle` вызваны дрейфом истории между снимком и HEAD. Реализация тут ни при чём:
полный режим (г) против базы `5bfc85c4` равен по множеству вердиктов и rc.
Строки charter содержат счётчик коммитов HEAD. Поэтому дословный рецепт А2 краснеет на любом новом коммите
(совет С-5 architect). База против HEAD для charter: `diff_verdicts_083.sh` rc 1, но только из-за счётчика: каждая строка «коммитов в диапазоне N» на HEAD больше ровно на 17 (коммиты ветки); после нормализации счётчика 260 вердиктов совпали, diff пуст, rc 0 = rc 0. Полный режим charter реализацией не изменён.

## 4. А3 — тайминг (свежий результат, как просил оркестратор)

Раны ветки (`gh run list --branch wip/083/integration-2`):

| ран | head | итог | l1 (check:charter) |
|---|---|---|---|
| `37501183008` | dce05c89 | failure | 17:08:14→17:18:36 |
| `37507776172` | a340bdab | failure (l4) | 17:59:14→18:09:47 |
| `37514488068` | e6c338e3 | попытка 1 failure (l1, см. Н-2), попытка 2 success | 19:29:39→19:42:51 = **792 с** |
| `37521374063` | 6aa38a58 | success | 19:45:47→19:58:08 = **741 с**, кеш не найден |

```
$ bash fixtures/ci_gen_083/timing_083.sh wip/083/integration-2
timing_083 НАРУШЕНИЕ: самая долгая lane-джоба ci = 792 с (> 720): ci (l1, check:charter)
rc=1
$ bash fixtures/ci_gen_083/timing_083.sh wip/083/integration-2 720 37514488068
timing_083 ОТКАЗ: после границы 37514488068 завершённых прогонов — 1 (< 2): мало данных (НЕ зелёное; …)
rc=2
```

**А3 не выполнена:** rc≠0, лендинг заблокирован буквой контракта. Граничный run-id оркестратор ДО прогона
не назначил, судья его не выбирает. Даже при границе `37514488068` свежий ран `37521374063` холодный,
и 741 с > 720. Причина — Б-1: PR-раны кеш не сохраняют, «прогрев» пустым коммитом невозможен.
Своя мера:
- `gh cache list` — ни одной записи `ci-incr-*`;
- лог l3 рана `37521374063`: «Cache not found for input keys» по всем 4 ключам.

## 5. Блокирующие находки (подробно — `.review/2026-10-06-01.md`)

- **Б-1** (implementer-gen, этикет §Зоны 083/3 `:427-433`, §Остаточный риск v+1):
  - `ci.yml:224-243` сохраняет кеш только при `if: github.event_name == 'push'`;
  - PR-scoped save `ci-incr-<check>-pr-<N>-<sha>` отсутствует;
  - реализация следует тексту frozen 083/**1** (`:370` «save только на push-событиях»), который заменён в /2 и /3.
- **Б-2** (implementer-incr, инв. 6 (в′)):
  - `lib_incr.sh incr_parse` по-прежнему отказывает «не предок» rc 1;
  - (в′) реализован пре-разбором только в `check_charter.sh:295-352`. Это второй разборщик грамматики,
    тело продублировано для `--incr` и `--incr=`;
  - мера (кеш = `f8e1f3d3` main — `git merge-base --is-ancestor f8e1f3d3 HEAD` rc 1, объект есть — и посторонний `1234567890abcdef…`, объекта нет; HEAD `6aa38a58`, `bash scripts/check_<k>.sh --incr <кеш>`):
    ```
    incr: check_zones ОТКАЗ: кеш …/zones.sha — sha f8e1f3d3 не предок HEAD 6aa38a58          rc=1
    incr: check_zones ОТКАЗ: кеш …/zones.sha — sha 12345678 не предок HEAD 6aa38a58          rc=1
    incr: check_ids ОТКАЗ: кеш …/ids.sha — sha f8e1f3d3 не предок HEAD 6aa38a58              rc=1
    incr: check_ids ОТКАЗ: кеш …/ids.sha — sha 12345678 не предок HEAD 6aa38a58              rc=1
    incr: check_protected ОТКАЗ: кеш …/protected.sha — sha f8e1f3d3 не предок HEAD 6aa38a58  rc=1
    incr: check_protected ОТКАЗ: кеш …/protected.sha — sha 12345678 не предок HEAD 6aa38a58  rc=1
    incr: check_charter полный прогон (база f8e1f3d3 не предок HEAD 6aa38a58 — кеш сторонней линии)  rc=0
    incr: check_charter полный прогон (база 12345678 не предок HEAD 6aa38a58 — кеш сторонней линии)  rc=0, кеш=6aa38a58
    ```
    3 из 4 чеков на обоих классах входа (в′) дают прежний отказ «не предок»; кеш у них не тронут (содержимое после прогона = входной sha); у charter после второго входа кеш = 6aa38a58
- **Б-3** (implementer-gen, инв. 3 «правило 6 … без ослабления»):
  - `verify_ci_parity.sh:1128-1153` («5-я форма») засчитывает любую команду `<значение скрипта> <что угодно>`;
  - шаг `run: bash scripts/check_no_rewrite.sh --probe-arg` на базе `5bfc85c4` даёт FAIL, rc 1, а на HEAD — `расхождений: 0`, rc 0.

Не блокируют: Н-1 (А3), Н-2 (зелёный CI e6c338e только с повтора; гонка id-тега), С-1…С-5.

## 6. Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `gen_ci_steps.sh` | инв. 1, 4, 5 | ci.yml между маркерами, явно в аргументах `--check/--write/--root` | реестр+ci.yml+генератор, как задумано | интерфейс из контракта, работа LPT/резолв/запись за ним — глубокий | Г1/Г8, CI через батарею | ESSENTIAL |
| `run_ci_lane.sh` | инв. 2 | нет | 1 | узкий интерфейс; мёртвые `STEP_WEIGHT`, лишние строки awk, обещанный и не существующий done.log (С-3) | lane-шаг ci.yml, Г9 | ESSENTIAL (мусор — совет) |
| `registry/ci-steps.tsv` | инв. 1 | реестр, явный | 1 | — | генератор, раннер, паритет | ESSENTIAL |
| `lib_incr.sh` | инв. 6 | кеш-файл, путь в аргументе, маркер в stderr | 1 + 4 чека | глубокий, но без (в′) (Б-2) | клетки И*, реестровые команды | ESSENTIAL |
| пре-разбор (в′) в `check_charter.sh:295-352` | (в′) инв. 6 — есть, но место запрещено | скрытое: `_FOREIGN_CACHE` подменяет `INCR_CACHE` после разбора | вырос: правка грамматики теперь требует 2 файла | интерфейс дублирует библиотеку | И4-3/И4-4 | **ACCIDENTAL, блокирует** (Б-2: фрагмент, отсутствующее свойство «все четыре чека/один источник», простая форма — (в′) в `incr_parse`) |
| no-op-стабы ×4 в чеках | дриллы, копирующие барьер без библиотеки | нет | 5 файлов при смене API | — | дриллы вне зоны | ACCIDENTAL, совет (С-4: простой формы внутри зоны не видно) |
| «5-я форма» `verify_ci_parity.sh` | инв. 3 требует покрыть 2 команды (`check_no_rewrite` с `${{}}`, `run_ci_lane.sh`) | нет | 1 | обобщение шире свойства | паритет | **ACCIDENTAL, блокирует** (Б-3: фрагмент, ослабление правила 6, простая форма — только `$VAR`-аргументы или точный спецслучай) |
| `$RUN/registry.tsv` в паритете | нет | файл без читателя | — | — | нет | ACCIDENTAL, совет (С-3) |
| save/restore ×4 в ci.yml | этикет §Зоны | кеш actions/cache | 1 | — | А3 | ESSENTIAL, но неполный (Б-1) |
| батарея и антиплацебо-самотест в каждой lane | ПРОВОДКА 038 требует один шаг | нет | 1 | ×7 исполнение | CI | ACCIDENTAL, совет (С-2) |
| `do_check_*_083.txt` | А2 | эталон, явный | 1 | — | А2 | ESSENTIAL |

## 7. Атомарность, нормы

- Коммиты по задачам, почти все со ссылкой «083». Исключение — `ce2f0da0`: без номера, только путь `scripts/lib_incr.sh`. Это совет.
- Нормативные документы в диффе не тронуты. `roles/`, `AGENTS.md`, контракты не правились.

## 8. Что нужно до следующего круга

1. Б-1: PR-save с PR-scoped ключом.
2. Б-2: (в′) в `lib_incr.sh`, пре-разбор из `check_charter.sh` убрать.
3. Б-3: сузить «5-ю форму».
4. После этого: два тёплых рана после границы, которую оркестратор назовёт ДО прогона, и `timing_083.sh … <граница>` → rc 0.
5. Architect (С-1): клетки (в′) на zones/ids/protected и клетка PR-save. Это не блокирует 083, но без них Б-1/Б-2 батарея не ловит.

— reviewer, 2026-10-06.
