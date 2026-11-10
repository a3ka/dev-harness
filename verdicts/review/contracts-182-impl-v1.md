FAIL
OBJECT=6670235d60fde22c65577f3c8bd70aab60a5ccfa
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался — frozen 182/1)
СУД: repo=dev-harness; предмет=182; фаза=реализация (перед слиянием PR #726); роль=reviewer; вызов=1/1; сессия=Rev182v1 (харнесс-сессия c907157c); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; автор=implementer minimax/MiniMax-M3; контракт=frozen/contracts/182/1 (tag d3bb84c0, commit 9681a6cb); кандидат слияния=origin/wip/182/orchestrator 1bb6c94c1b68bbc9b12a1ff298d3c3b26c6797f9; предыдущий=verdicts/critic/contracts-182-v1.md

# Вердикт reviewer — 182 «Срез «где мы по плану» после перезапуска», реализация, вызов 1/1

## Итог

Реализация **не допускается** к слиянию. Блокирует одна находка, Р-1.

`scripts/orch_plan_slice.sh` нарушает frozen-инварианты 1 и 4 контракта 182. Если на origin/main в
ROADMAP нет generated-блока, CLI сверяет план с любыми таблицами файла и печатает зелёный срез
с rc 0. Если блок есть, CLI всё равно принимает строку таблицы, стоящей ДО маркера BEGIN. Контракт
в этих случаях требует именованного отказа. Закрывается двумя строками; более простая форма
проходит все строки приёмки (доказано ниже, п. 11).

Остальное в порядке:

- область правки в зоне;
- норма роли совпадает с ПРОВОДКОЙ дословно;
- проверки не подогнаны под код;
- батарея 9/9 и 4/4;
- живой срез по origin/main сходится с моей независимой мерой: 108 строк, 0 расхождений;
- мутации «локальный HANDOFF/план», «HEAD ≠ origin/main», «локальный тег», «тег вне истории» —
  срез корректен.

Находки — ниже, разделом «Находки», в формате чекбоксов. Отдельного `.review/` файла нет: задание
велит держать находки в тексте вердикта, а ЗОНА reviewer контракта 182 — только `verdicts/review/`.

## Объект и кандидат

```
git fetch origin wip/182/implementer wip/182/orchestrator
origin/wip/182/implementer   = 6670235d60fde22c65577f3c8bd70aab60a5ccfa   (== OBJECT)
origin/wip/182/orchestrator  = 1bb6c94c1b68bbc9b12a1ff298d3c3b26c6797f9   (PR #726)
origin/main                  = 18544ce846d21104467fac92a60f82c1bdeef730
merge-base(main, OBJECT)     = 74da59357e806604c26dc0cdefdb44d606272e22
git log main..OBJECT:
  6670235d implementer 182: норма роли — срез плана после успешного brief (roles/orchestrator.md)
  b9079781 implementer 182: CLI-срез плана из опубликованного origin/main (scripts/orch_plan_slice.sh)
git log main..PR:
  1bb6c94c orchestrator 182: регенерация .omp/agents/orchestrator.md после нормы роли (npm run gen:harness)
  2e1a56fb orchestrator 182: шаг CI check:plan-restart-182-family-selftest (вес 4) - проводка guard-канала
  3fc12ef9 implementer  (== 6670235d по range-diff «=»)
  61dd0a73 implementer  (== b9079781 по range-diff «=»)
blob scripts/orch_plan_slice.sh: OBJECT == PR == be649424f28c
blob roles/orchestrator.md:      OBJECT == PR == 7e30197fe05e
git diff --numstat 74da5935 OBJECT: 3 0 roles/orchestrator.md ; 206 0 scripts/orch_plan_slice.sh
```

## Чем проверял (свои прогоны; вывод сокращён до значимых строк, rc — полностью)

1. `bash -n scripts/orch_plan_slice.sh` → rc=0.
2. Батарея на OBJECT (`impl/`):
   - `red_plan_restart_182.sh --repo .` → GREEN published/frozen/pause/done/roadmap/no-stale/local-isolation/structural/source-mismatch, `CELLS=9 GREEN=9`, rc=0;
   - `--stabs` → `STAB handoff caught: no-stale`, `STAB stale caught: no-stale`, `STAB local caught: local-isolation`, `STAB no-roadmap caught: roadmap`, `STABS=4 CAUGHT=4`, ZHIV нет, rc=0;
   - `--model` → `CELLS=9 GREEN=9`, rc=0.
3. Красное на пустом дереве (origin/main 18544ce8, CLI нет): `--repo .` → 9× `RED …: rc=127 … orch_plan_slice.sh: No such file or directory`, `CELLS=9 GREEN=0`, rc=1.
4. На кандидате PR 1bb6c94c: `--repo .` → `CELLS=9 GREEN=9`, rc=0.
5. `bash scripts/check_provodka.sh . contracts/182-plan-posle-perezapuska.md`:
   - PR → rc=0;
   - OBJECT → rc=1 «guard не подключён: scripts/orch_plan_slice.sh не вызывается в .githooks/ или .github/workflows/»;
   - main → rc=1 «guard-файл не существует».

   Норма-строка `grep -c` дословно: `roles/orchestrator.md:1`, `.omp/agents/orchestrator.md:1` (PR).
6. `bash scripts/check_ceilings.sh .`:
   - OBJECT → rc=1 «FAIL персона ./roles/orchestrator.md: 61713 байт > потолка 61440» (база 74da5935 до #743);
   - PR → rc=0 (`PERSONA_LIMIT=73728`, 61713 байт);
   - main → rc=0.
7. `node scripts/gen-harness.ts --check` (= `npm run gen:harness -- --check` / `check:gen`):
   - PR → «харнес соответствует roles/ (12 ролей)», rc=0;
   - OBJECT → «FAIL расходится с roles/orchestrator.md: orchestrator.md», rc=1.

   Регенерация 1bb6c94c — необходимая и достаточная.
8. Прочие гейты:
   - `bash scripts/gen_ci_steps.sh --check` (PR) → rc=0.
   - Множество ключей `keys:` в ci.yml до/после 2e1a56fb отличается ровно одной строкой `> check:plan-restart-182-family-selftest`. Остальные правки ci.yml — перераскладка lane генератором; чужие шаги не добавлены и не убраны.
   - `bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` → rc=0 на OBJECT и на PR (frozen 095 не тронут).
   - `bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md` (PR) → `PREDPOSYLKI_OK … settings=2`, «КРИТИК: дверь зелёная», rc=0.
   - `bash scripts/check_project_sources.sh --repo . --contract contracts/182-plan-posle-perezapuska.md --stage done` → rc=0 на HEAD=6670235d и на HEAD=1bb6c94c.
9. Зоны (scoped, без полного `check_zones.sh`), команды `source scripts/lib_zones.sh; zones_load <PR>; zones_match_path`:
   ```
   OK 61dd0a73 implementer  scripts/orch_plan_slice.sh  ← scripts/orch_plan_slice.sh
   OK 3fc12ef9 implementer  roles/orchestrator.md       ← roles/orchestrator.md
   OK 2e1a56fb orchestrator .github/workflows/ci.yml, registry/ci-steps.tsv, registry/ci-zamery.tsv
   OK 1bb6c94c orchestrator .omp/agents/orchestrator.md ← .omp/
   OUT_OF_ZONE=0
   ```
10. Живой срез (приёмка, строка 4): `bash scripts/orch_plan_slice.sh --repo <клон>` → rc=0, `PLAN_SNAPSHOT: origin/main=18544ce846d21104467fac92a60f82c1bdeef730`, далее строки `PLAN:`.

    **Своя мера:** `git fetch --tags` + `git tag --merged origin/main` — другой механизм, чем `ls-remote`+`rev-list` у CLI — и `pauzy.tsv` с origin/main. Пересчитал статусы по приоритету done > ПАУЗА > frozen > черновик → `rows 108 mismatch 0`. `git show origin/main:registry/plan.tsv | grep -vc '^id'` = 108. Строк «ЖДЁТ» нет.
11. Собственные миры-мутации (throwaway `mut.py`, `mutants.sh`, вне репозитория). Субъект — OBJECT; stdout печатаю целиком; при rc=1 stdout пуст во всех случаях.

    | # | мир | rc | результат |
    |---|---|---|---|
    | A | локальный неопубликованный коммит меняет plan/pauzy; HEAD 72e09fdc ≠ origin/main 2bd2e484; локальный annotated done-тег | 0 | SNAPSHOT = origin/main; опубликованные этапы; ПАУЗА из origin; done нет — **верно** |
    | B | опубликованный done-тег на коммите вне истории origin/main | 0 | 203 остаётся «черновик» — **верно** |
    | C | опубликованные annotated frozen 201 + done 202 (202 в паузе) | 0 | 201 frozen, 202 done (done > ПАУЗА) — **верно** |
    | D | нет pauzy.tsv на origin/main | 1 | `PLAN_SOURCE_UNAVAILABLE` — верно |
    | **E** | **ROADMAP без маркеров generated-блока, таблица совпадает** | **0** | **зелёный полный срез — нарушение И-1/И-4 (Р-1)** |
    | **F** | **строка 203 только в таблице ДО `BEGIN`, в блоке её нет** | **0** | **203 принят — нарушение И-1 (Р-1)** |
    | G | числовой id не в contracts.tsv | 1 | `PLAN_ROADMAP_RASHOZHDENIE: нет строки ROADMAP/registry` |
    | H | строка plan.tsv из 5 полей | 1 | то же сообщение (см. Р-3) |
    | I | лишняя строка 204 в блоке | 0 | принято (см. Р-4) |
    | J | дубль 201 в блоке с другим этапом | 1 | `PLAN_ROADMAP_RASHOZHDENIE: …: 201` |
    | K | remote недоступен | 1 | `PLAN_SOURCE_UNAVAILABLE: не читаются опубликованные теги` |
    | L | порядок строк блока ≠ порядок plan | 0 | принято (см. Р-4) |
    | M | нет origin/main | 1 | `PLAN_SOURCE_UNAVAILABLE` |

    Мутанты субъекта против батареи `--repo`:

    | мутант | rc | красные клетки |
    |---|---|---|
    | источники из рабочего дерева вместо `git show` | 1 | frozen, local-isolation, structural |
    | локальные теги (`for-each-ref`) вместо `ls-remote` | 1 | frozen, structural |
    | приоритет: пауза не учитывается | 1 | pause, structural |
    | без проверки расхождения | 1 | source-mismatch |
    | **снимок = HEAD вместо origin/main** | **0** | **нет — батарея не ловит (Р-2)** |

    Тот же HEAD-мутант в моём мире A → rc=1 (расхождение по локальному коммиту). Реализация здесь корректна, дыра — в батарее.

    **Более простая форма для Р-1.** Требовать ровно одну строку `<!-- BEGIN GENERATED PLAN -->` и одну `<!-- END … -->` (иначе `die "PLAN_ROADMAP_RASHOZHDENIE: …"`) и разбирать только строки внутри блока. Результаты:
    - батарея `--repo` → `CELLS=9 GREEN=9`, rc=0;
    - живой origin/main → 108 строк `PLAN:`;
    - миры E и F → rc=1 `PLAN_ROADMAP_RASHOZHDENIE`;
    - остальные миры — без изменений.

## Проверки роли

1. **Область правки.** OBJECT — два файла в ЗОНЕ implementer. `roles/orchestrator.md` — ровно +3 строки (пустая, норма-строка, пустая) после п.0 (`@@ -17,6 +17,9 @@`). П.0 «отказ — стоп, не имитация брефа» и пп.1–2 не изменены. Чужие нормы роли (010/026/…/100) не тронуты. Строки orchestrator в PR — в его зоне (п. 9). — соответствует.
2. **Сырой вывод.** Выше; все прогоны мои, вывод автора не переиспользовал. — соответствует.
3. **Проверки не подогнаны.**
   - `git log` по `fixtures/workshop_project/plan_restart_182/` и контракту показывает только architect: 04752031, 1e2cf79b, 395fe3b6.
   - `git diff --quiet frozen/contracts/182/1 PR -- <фикстуры+контракт>` → rc=0, после заморозки не менялись.
   - Implementer фикстур не касался.
   - — соответствует.
4. **Красное предъявлено.** Пустое дерево → `GREEN=0`, rc=1 (п. 3). Мои мутанты субъекта краснеют в 4 из 5 (п. 11). Гейты проводки, потолка и gen:harness краснеют на OBJECT без PR-обвязки и зеленеют на PR (пп. 5–7). — соответствует, с дырой Р-2.
5. **Атомарность.** Два коммита implementer, каждый со ссылкой «182:» на свой файл. Два коммита orchestrator. — соответствует.
6. **Норма не тронута молча.** Правка `roles/orchestrator.md` — объявленный role-канал ПРОВОДКИ 182 с ПЕРЕСЕЧЕНИЯМИ 095/010/…/100 «только briefing-срез». Текст нормы совпадает с ПРОВОДКОЙ байт-в-байт (п. 5). — соответствует.
7. **Заявленное = сделанное.**
   - «206 строк» — `numstat` 206 ✓;
   - «+3 строки» — `numstat` 3 0 ✓;
   - «вес 4» — строка ci-steps `…	4	…` и ci-zamery `…	4	8	0` ✓;
   - «STABS=4 CAUGHT=4» и «CELLS=9 GREEN=9» — подтверждены своими прогонами;
   - живой срез — 108 строк, сверено независимым механизмом (п. 10) ✓.

## Находки

- [ ] **Р-1 (класс: нарушение frozen-инварианта + ACCIDENTAL-ветвь 050; БЛОКИРУЕТ слияние; адресат — implementer).**
  - **Фрагмент.** `scripts/orch_plan_slice.sh:91-98`. Комментарий «без маркеров — все строки файла» и `if (seen && !inblock) next`: строки до `BEGIN` разбираются всегда (`seen=0`); при отсутствии маркеров разбирается весь файл.
  - **Нарушенное обязательство.**
    - frozen 182/1 §Инварианты 1: «Поля id/пара/этап/трек/зависит должны совпасть с одноимённой строкой **generated-блока** ROADMAP … расхождение — rc 1 … ни одной вводящей в заблуждение строки stdout»;
    - §Инварианты 4: «Структурные ошибки — именованный отказ, не зелёный пустой срез»;
    - §Существующее: «Расхождение TSV и ROADMAP — отказ, не догадка».
  - **Наблюдение.** Мир E: ROADMAP без блока → rc=0 и полный срез. Мир F: id есть только в таблице до `BEGIN` → rc=0, строка принята. Это противоречит и собственному комментарию строки 91: «При наличии маркеров … берётся ОН».
  - **Достижимость.**
    - Блок охраняет только `check_plan.sh` в `.githooks/pre-commit`; в `registry/ci-steps.tsv` его нет (grep `check_plan` пуст).
    - В свежем клоне `core.hooksPath` не задан (`git config --get core.hooksPath` → rc=1 в моём клоне).
    - Значит, опубликованный origin/main с удалённым или сдвинутым блоком достижим. CLI на нём даст зелёный срез вместо отказа.
  - **Свойство, которого нет.** Отказ при отсутствии или неединственности generated-блока.
  - **Более простая форма.** Две проверки `grep -cFx` маркеров = 1 и разбор только внутри блока, без ветви «без маркеров». Проходит все строки приёмки (п. 11: батарея 9/9, живые 108 строк) и закрывает E/F.
- [ ] **Р-2 (класс: дыра батареи; совет, не блокирует реализацию; адресат — architect).** Мир `probe.py` строит HEAD == origin/main (локальные правки не закоммичены), поэтому мутант «снимок = HEAD» проходит `--repo` 9/9 (п. 11). Задание и И-1 требуют именно origin/main; реализация здесь верна (мир A), но барьер свойство не держит. Закрывается локальным коммитом поверх origin/main в `world()`. Это правка фикстуры — нужна v+1 по правилам заморозки.
- [ ] **Р-3 (класс: совет; адресат — implementer, вместе с Р-1).**
  - Строка plan.tsv не из шести полей (`:170`) и числовой id без записи в реестре (`:176`) дают одно и то же сообщение `PLAN_ROADMAP_RASHOZHDENIE: нет строки ROADMAP/registry`. Причина отказа не названа.
  - При любом отказе awk строка `:204` печатает в stderr вторую, обобщённую строку «plan.tsv расходится с generated-блоком ROADMAP» — даже когда причина в реестре.
  - rc и пустой stdout верны.
- [ ] **Р-4 (класс: совет; вне буквы И-1).** Лишняя строка в блоке ROADMAP (мир I) и иной порядок строк (мир L) не дают отказа. И-1 сверяет только строки плана с одноимёнными строками блока, поэтому это не FAIL. Но §Существующее называет блок «производным порядком из того же TSV». Решать владельцу или architect.
- [ ] **Р-5 (класс: информация для оркестратора; не находка против implementer).** OBJECT отдельно, на базе 74da5935, красен по `check_ceilings` (61713 > 61440), `check_provodka` (guard не подключён) и `gen:harness --check`. Все три зелёны только на PR #726 1bb6c94c. Сливать допустимо лишь через PR #726, не веткой `wip/182/implementer`.

## Паразитная сложность (контракт 050)

- **`scripts/orch_plan_slice.sh` (новый, 206 строк).**
  1. Свойство: И-1..И-4, guard ПРОВОДКИ.
  2. Состояние явное: снятый `sha` печатается в первой строке; источники — блобы этого SHA; теги — `ls-remote`. Побочных файлов нет (только process substitution). Env не читает, а снимает `GIT_*`.
  3. Совместных правок: 1 файл, плюс батарея architect.
  4. Глубина: интерфейс — `--repo` и rc 0/1/2. Лишнее: `--repo=`, вызов без `--repo` (корень скрипта), `-h` — сверх входа И-1, мелкое расширение (совет).
  5. Потребитель — CI-шаг `check:plan-restart-182-family-selftest` и роль. Грамматику plan.tsv/блока ROADMAP скрипт повторяет awk-разбором рядом с `scripts/lib_plan.sh` (084, «единый разбор»). Более простая форма через `p84_check_block` не проходит приёмку: мир батареи не несёт строку `P84_RM_TITLE` в блоке. Поэтому совет, не блок.

  → ESSENTIAL, кроме ветви ниже.
- **Ветвь «ROADMAP без маркеров / строки до BEGIN» (`:91-98`).** Свойства контракта не обслуживает (И-1 называет только generated-блок), потребителя в приёмке нет; более простая форма проходит те же строки. → **ACCIDENTAL, блок (Р-1)**.
- **`roles/orchestrator.md` +3.**
  1. Свойство: role-канал ПРОВОДКИ, И-3.
  2. Состояния не вводит.
  3. Вместе меняется 1 производный файл `.omp/agents/orchestrator.md` (генератор).
  4. Интерфейс не растёт.
  5. Потребитель — `check_provodka` г4 и `check:gen`.

  → ESSENTIAL.
- **CI-строка `registry/ci-steps.tsv`/`ci-zamery.tsv` + перегенерированный ci.yml (orchestrator).**
  1. Свойство: подключение guard (`check_provodka` OBJECT rc=1 → PR rc=0).
  2. Состояния не вводит.
  3. 3 файла через генератор — как у каждого шага.
  4. Интерфейс не растёт.
  5. Потребитель — CI.

  → ESSENTIAL.
- **`.omp/agents/orchestrator.md` +3.** Производный артефакт `gen-harness`, без него `check:gen` rc=1 (п. 7). → ESSENTIAL.

## ПРОВОДКА (контракт 038)

- **guard.** `guard=scripts/orch_plan_slice.sh` существует и является барьером именно этого предмета: сам CLI-срез. Подключён в CI шагом 182 (батарея `--repo .` вызывает именно его), `check_provodka` rc=0 на PR.
- **role.** `role=roles/orchestrator.md «…»` — строка присутствует дословно. Поведенческая норма (порядок «brief → срез → HANDOFF», запрет обхода брифа, запрет ЖДЁТ без живого подтверждения) идёт role-каналом, как требует 029-класс.
- **ПРОВОДКА-ЭНФОРСМЕНТ.** Обоснование честное: guard доказывает происхождение и формат. Формат guard пока доказывает не полностью — см. Р-1.

— соответствует, кроме Р-1.

## Режим проекта (контракт 996)

`harness.project.json` есть. Gate `check_project_sources.sh --stage done` → rc=0 на HEAD=6670235d (OBJECT) и HEAD=1bb6c94c (кандидат). sourceCanon-сверка зелёная на текущих SHA.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`. `grep -cE 'ARCHITECTURE\.md|CODING-STANDARDS|стандарт кода' AGENTS.md` → 0.

## Мобильный экран

Неприменимо — дифф без мобильного экрана.

## Что нужно для accept

Р-1 закрыт коммитом implementer в `scripts/orch_plan_slice.sh`: отказ `PLAN_ROADMAP_RASHOZHDENIE` при неединственном или отсутствующем generated-блоке; разбор только внутри блока. После этого — scoped-повтор суда на новом SHA. Повторить: батарея `--repo`/`--stabs`, миры E/F, живой срез. Р-2..Р-4 — советы, слияние не держат.
