FAIL
OBJECT=5aa24116427089282883f0b68cb2a509fd29a3cd
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался — frozen 182/2)
СУД: repo=dev-harness; предмет=182; фаза=реализация v2 (контракт ЗАМОРОЖЕН `frozen/contracts/182/2`; блоб контракта на origin/main == frozen: `git diff frozen/contracts/182/2 origin/main -- contracts/182-plan-posle-perezapuska.md` пуст); роль=reviewer; вызов=1 (полный); последний судья; сессия=Rev182 (харнесс-сессия c907157c); модель-план=config/agent_models.json reviewer → audit → @opus → anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (рантайм сессии; `bash scripts/models_actual.sh --tsv --bind --session c907157c` → `NOT_IMPLEMENTED: сессия не найдена: c907157c`, rc 2 — по трассе не сверено); автор=implementer (Impl182); предыдущие=нет; находки=`.review/2026-11-18-104.md`

# Вердикт reviewer — 182 v2 «срез плана в проектном режиме», реализация, вызов 1

## Итог

**FAIL — три блока, все с простой формой, которая проходит те же строки приёмки.**

- **Рв182-1.** Правка роли разрушила норма-строку ПРОВОДКИ (038). `check_provodka` на OBJECT красен, на main зелёный, поэтому `done_contract.sh` не поставит `done/contracts/182/2`.
- **Рв182-2.** Проектный режим отказывает при недоступном origin (ls-remote) без обязательного префикса И-7 и без названного выхода.
- **Рв182-3.** Профиль с хвостовым `/` в `workflowPaths.registry` резолвер 996 принимает. Срез на нём даёт ложный отказ «нет `ops/ledger2//plan.tsv`», хотя план опубликован (И-6, «правдив» И-7).

Всё остальное подтверждено своими прогонами:

- батарея 35/35, `--model` 35/35, стабы 17/17;
- на чистом main красное: 15/35, rc 1;
- станционный режим побайтно равен v1 на живом харнессе;
- живые проектные клоны дают правдивый отказ;
- соседи 095/996/125 зелёные;
- gen/ci/charter зелёные.

## Объект и судимое дерево

```
клон: /tmp/dev-harness-verify/Rev182/repo (git clone ssh://git@github.com/a3ka/dev-harness.git; свой .git)
git fetch origin main wip/182/implementer + теги
origin/main                = 90c4aa63c34247878d02fdd6827b5ee11a7eb9b3
origin/wip/182/implementer = 5aa24116427089282883f0b68cb2a509fd29a3cd (== OBJECT)
git rev-parse 5aa2411642^  = 90c4aa63c34247878d02fdd6827b5ee11a7eb9b3 (один коммит поверх main)
author/committer = implementer <implementer@dev-harness.local> / implementer <implementer@dev-harness.local>
git show 5aa2411642 --stat:
 .omp/agents/orchestrator.md |   2 +-
 roles/orchestrator.md       |   2 +-
 scripts/orch_plan_slice.sh  | 117 ++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 109 insertions(+), 12 deletions(-)
git hash-object (рабочее дерево на OBJECT) == git rev-parse 5aa2411642:<f>:
 scripts/orch_plan_slice.sh  a1610b1cb8b9cde7fe9bc65a64d00162737a7ff4
 roles/orchestrator.md       a8b913fbdf485b9b8a16201a92b7a7c09569a95f
 .omp/agents/orchestrator.md dc4c282e51438f5a3a9d73b4a73e444136da7fa0
git log origin/main..5aa2411642 -- fixtures/ contracts/ | wc -l → 0
```

Судимое дерево — ровно origin/main и три файла OBJECT; дифф `origin/main..OBJECT` содержит только эти три пути.

## Прогоны (сырые; гейты — `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL`)

### Батарея на OBJECT

`bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .`:

- 35 строк GREEN: published … outside-generated-block, proj-published … proj-alt-structural;
- `CELLS=35 GREEN=35`, **RC=0**.

`--model`:

- `CELLS=35 GREEN=35`, **RC=0**.

`--stabs`:

- 35 GREEN, затем STAB-строки:
  - `STAB handoff caught: no-stale`
  - `STAB stale caught: no-stale`
  - `STAB local caught: local-isolation`
  - `STAB no-roadmap caught: roadmap`
  - `STAB head caught: published`
  - `STAB no-project-mode caught: proj-structural`
  - `STAB root-decoy caught: proj-no-decoy`
  - `STAB local-profile-plan caught: proj-local-isolation`
  - `STAB pauzy-required caught: proj-pauzy-optional`
  - `STAB silent-empty caught: proj-no-plan-named`
  - `STAB station-fallback caught: proj-no-plan-named`
  - `STAB project-no-crosscheck caught: proj-mismatch`
  - `STAB resolver-fallback caught: proj-broken-profile`
  - `STAB legacy-fallback caught: proj-sync-marker`
  - `STAB registry-hardcode caught: proj-alt-structural`
  - `STAB vague-refusal caught: proj-no-plan-named`
  - `STAB no-exit caught: proj-no-plan-exit`
- `STABS=17 CAUGHT=17`, **RC=0**.

### Красное на чистом main (HEAD=90c4aa63c3)

`--repo .`:

- 11 станционных клеток зелёные. Проектных зелёных четыре: proj-published, proj-local-isolation, proj-alt-published, proj-alt-local-isolation.
- 20 RED: proj-done, proj-frozen, proj-pause, proj-draft, proj-no-decoy ×2, proj-structural, proj-pauzy-optional, proj-no-pauzy-structural, proj-no-plan-named, proj-no-plan-exit, proj-mismatch, proj-broken-profile, proj-sync-marker, proj-alt-done, proj-alt-frozen, proj-alt-pause, proj-alt-draft, proj-alt-no-decoy, proj-alt-structural.
  - Пример: `RED proj-no-plan-named: rc=0 stdout='PLAN_SNAPSHOT: origin/main=b257b5af…\nPLAN: 147 | ROADMAP=3/'` — станционный читатель печатает приманку.
- `CELLS=35 GREEN=15`, **RC=1**. Это ровно парное отрицательное приёмки v2.

### Гейты и соседи на OBJECT

```
bash -n scripts/orch_plan_slice.sh                                   → RC=0
node scripts/gen-harness.ts --check   «харнес соответствует roles/ (13 ролей)» → RC=0
bash scripts/gen_ci_steps.sh --check                                 → RC=0
bash scripts/check_charter.sh  «уставных документов: 180 · изменений в них: 525 · с разрешения: 525» → RC=0
bash scripts/check_ceilings.sh .  «потолки в порядке»                → RC=0
bash scripts/check_project_sources.sh --repo . --contract contracts/182-plan-posle-perezapuska.md --stage done → RC=0 (HEAD=5aa2411642)
bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md  «КРИТИК: дверь зелёная» → RC=0
bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh        → RC=0
bash fixtures/workshop_project/rezhim_996/probe.sh  «996: examined=111 mutants=0 mismatches=0» → RC=0
bash fixtures/workshop_project/sessii_125/red_sessii_125.sh  «s125 red: зелёных 70, красных 0» → RC=0
bash scripts/check_plan.sh                                           → RC=0
bash scripts/check_provodka.sh . contracts/182-plan-posle-perezapuska.md
     «проводка: норма-строка не найдена в role-файле: roles/orchestrator.md» → RC=1   ← Рв182-1
  тот же вызов на чистом main (HEAD=90c4aa63c3)                     → RC=0
bash scripts/ci_preflight.sh --repo $PWD
     OBJECT: «preflight ОТКАЗ: shag-upal: klass/step (rc=1): bash: line 1: : No such file or directory» RC=1
     main:   то же сообщение байт в байт, RC=1   (остаток implementer «до и после одинаково» — подтверждён)
```

### Живой срез

- **Харнесс-как-проект.** Клон: `harness.project.json` опубликован, `state: "."`.
  - `bash scripts/orch_plan_slice.sh --repo <клон>` → RC=0: `PLAN_SNAPSHOT: origin/main=90c4aa63c34247878d02fdd6827b5ee11a7eb9b3` и 123 строки PLAN.
  - Строка 182: `PLAN: 182 | ROADMAP=3/до V-2 | STATUS=done | NEXT=закрыто`. Причина — тег `done/contracts/182/1`; это инвариант 2, не дефект.
- **Станционная неразличимость.** v1-скрипт (`git show origin/main:scripts/orch_plan_slice.sh`) и OBJECT на том же клоне:
  - оба RC=0;
  - stdout IDENTICAL, sha256 `015564d44a36847eca87b1bf63f5a661ff672ef7f3ef82578bdd96abfe1d020a` у обоих.
- **Проекты станции** (только чтение; `git status --porcelain` до и после — 0 строк):
  - `--repo /home/harness/projects/Complior-mob` → rc=1, stdout пуст, stderr: `PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=4182557eb9d4e1651f8d14233b5a224af50fab36): нет .harness/registry/plan.tsv на origin/main=4182557e…; станционный корневой реестр не подменяет; выход: план проекта заводит владелец коммитом в .harness/registry/plan.tsv (996)`.
  - `--repo /home/harness/projects/Complior-back` → rc=1, тот же вид, origin/main=5f5f24931fb7d3923d226beebbd36c3e5589d976.

  Боль v2 закрыта по форме: вместо безликого станционного отказа — правдивый отказ с выходом.

### Мои миры (независимая замена номеров/путей/текстов, И-4 v1)

Throwaway-скрипт `/tmp/dev-harness-verify/Rev182/edge.py` (вне репо). Устройство мира:

- свои номера 501/502/503;
- реестр `ops/ledger2`, state `meta`;
- этапы «релиз-А/релиз-Б», пауза «когда вернётся заказчик»;
- bare-origin, теги done/501 и frozen/502.

Субъект — OBJECT:

```
PASS A-custom-paths            rc=0, stdout == независимый оракул (4 строки)
PASS A2-no-pauzy               rc=0, 503 = черновик
FAIL B-ls-remote-fail-has-project-prefix  rc=1 stdout='' stderr='PLAN_SOURCE_UNAVAILABLE: не читаются опубликованные теги origin в /tmp/dev-harness-verify/Rev182/tmpocwl15bl/W'   ← Рв182-2
PASS B-ls-remote-fail-named-rc1-empty
FAIL C-trailing-slash          rc=1 stdout='' stderr='PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=cb81299d…): нет ops/ledger2//plan.tsv на origin/main=cb81299d…; станционный корневой реестр не подменяет; выход: план проекта заводит владелец коммитом в ops/le…'   ← Рв182-3
PASS D-no-contracts            rc=1, префикс И-7, «нет ops/ledger2/contracts.tsv … выход: реестр выдачи проекта заводит владелец …»
PASS E-roadmap-no-block        rc=1, stdout пуст, PLAN_ROADMAP_RASHOZHDENIE: generated-блок ROADMAP отсутствует или повреждён …
PASS F-no-roadmap              rc=1, префикс И-7, «нет meta/ROADMAP.md … выход: ROADMAP проекта заводит владелец …»
PASS G-state-dot               rc=0 (state ".", registry "registry")
PASS H-ambient-layer-root      rc=0 (ambient HARNESS_PROJECT_LAYER_ROOT указывает в чужой каталог)
PASS I-relative-repo           rc=0 (--repo W из cwd)
EDGE=11 PASS=9
```

### Простая форма проходит те же строки

Scratch, не коммитится: `git archive 5aa2411642` → `/tmp/dev-harness-verify/Rev182/fix`. На него наложены три правки:

- оговорка роли перенесена на следующую строку того же абзаца;
- `reg_rel="${reg_rel%/}"; road_rel="${road_rel%/}"`;
- в проектном режиме ls-remote-отказ идёт через `$prefix` и `выход: восстановить доступ к origin (fetch)`; станционная ветка байт в байт как v1.

Прогоны:

```
node scripts/gen-harness.ts → «обновлено файлов: 1»; --check → RC=0
check_provodka . contracts/182-… → RC=0
red_plan_restart_182.sh --repo <fix> → CELLS=35 GREEN=35 RC=0
--stabs → STABS=17 CAUGHT=17 RC=0
edge.py <fix>/scripts/orch_plan_slice.sh → EDGE=11 PASS=11
```

## Обязательства (по одному)

- **И-5 (маркер — опубликованный блоб).**
  - `:101-104` — `git cat-file -e "$sha:harness.project.json"`. Резолвер и jq подключаются только внутри `if [ "$mode" = "project" ]` (`:114-164`).
  - Станционная ветка `:177-186` — сообщения v1 дословно; в живом сравнении v1↔v2 sha256 равны.
  - **Соответствует.**
- **И-6 (единый резолвер, один вызов, относительная форма).**
  - `:123-129` — `NEXT_ID_LIB=1 . next_id.sh`, один вызов `project_paths_resolve "$repo_abs"`; `rel_inside` даёт форму внутри R. Корневая раскладка в проектном режиме не читается: клетки proj-no-decoy, proj-alt-* и мой мир A.
  - Живой корень без маркера → `выход: синхронизировать корень` (proj-sync-marker).
  - **Расхождение — Рв182-3:** путь, разрешённый профилем с хвостовым `/`, не нормализован.
- **И-7 (правдивый именованный отказ).**
  - Отказы «нет плана», «профиль не разрешается», «живой корень без маркера», а также мои D и F несут полный префикс и выход.
  - **Расхождение — Рв182-2:** ls-remote-отказ в проектном режиме (`:241-243`) идёт без префикса и выхода. Ложный отказ Рв182-3 нарушает «правдив».
- **И-8 (паузы опциональны).** `:176`: `|| pauzy_blob=""`. Клетки proj-pauzy-optional и proj-no-pauzy-structural, мой мир A2. **Соответствует.**
- **И-9 (сверки на профильных источниках).**
  - Сверка с generated-блоком `<roadmap>` (proj-mismatch, мой мир E).
  - Теги — через `ls-remote` origin проекта и предков снятого SHA (`:241-266`, код v1).
  - Реестр — `contracts_rel` профиля (`:299`).
  - **Соответствует.**
- **Станционная неразличимость.** 11 клеток v1 зелёные. На живом харнессе вывод v1 и v2 побайтно равен. **Соответствует.**
- **Роль.**
  - Добавленный текст дословно равен оговорке ЗОНЫ v2, плюс точка; v1-часть строки сохранена.
  - **Расхождение — Рв182-1:** норма-строка ПРОВОДКИ (`role=` контракта) перестала существовать отдельной строкой. `check_provodka` проверяет её через `grep -Fx` (`scripts/check_provodka.sh:692`).

## Проверки роли

1. **Область правки.**
   - `scripts/orch_plan_slice.sh` и `roles/orchestrator.md` — ЗОНА implementer 182.
   - `.omp/agents/` — ЗОНА implementer в `frozen/contracts/002/7` (contracts/002-approval-mode-steward.md:67) и `frozen/contracts/003/6` (contracts/003-skills-metta-adaptacija.md:102). Это последние версии: `git tag -l` даёт 002/1..7 и 003/1..6.
   - `.omp/agents/orchestrator.md` — чистая регенерация: `gen-harness --check` RC=0.
   - В `roles/orchestrator.md` изменена одна строка — строка 182 (`git diff --word-diff`: только вставка `{+В проектном режиме … из HANDOFF.+}`). Нормы ПЕРЕСЕЧЕНИЙ 095/010/…/100 не тронуты.
   - `scripts/check_zones.sh` на OBJECT во втором чистом ssh-клоне `/tmp/dev-harness-verify/Rev182/zones` (detached HEAD=5aa2411642, HEAD не переключался) → **zones RC=0** (948 с).
   - **Соответствует.**
2. **Сырой вывод** — выше, всё из своих прогонов. — соответствует.
3. **Проверки не подогнаны.**
   - `git log origin/main..OBJECT -- fixtures/ contracts/` пуст.
   - Литералов мира в субъекте нет: grep `Complior|toy|ledger|vneshne|premote|\.harness|30[1-4]|14[78]` даёт попадания только в комментариях `:35-38`.
   - Мои миры с чужими путями и номерами зелёные (A, A2, D–I).
   - — соответствует.
4. **Красное предъявлено.** Main → 15/35, rc 1; OBJECT → 35/35. Мои находки красны на OBJECT и зелёные на простой форме. — соответствует.
5. **Атомарность.** Один коммит, сообщение «182 v2: …». — соответствует.
6. **Норма не тронута молча.** Правка роли санкционирована ЗОНОЙ v2, но сломала канал ПРОВОДКИ — Рв182-1.
7. **Заявленное = сделанное.**
   - «+109/−12, 3 файла» — `--stat` ✓.
   - «20 красных → 35/35» — моя мера: 15 GREEN + 20 RED на main; 35 GREEN на OBJECT ✓.
   - «ci_preflight одинаково до/после» ✓.
   - «строка 182 = done» ✓.
   - Своя мера числа клеток: 35 строк GREEN, но уникальных имён 34 — `proj-no-decoy` печатается дважды (мир с паузами и мир без пауз). Это батарея architect, не реализация; см. С-2.

## Паразитная сложность (050) — артефакты диффа

- **Детектор режима `mode` (`:101-104`).**
  1. Свойство: И-5.
  2. Состояние: одна переменная; видна через формат отказа.
  3. Совместных правок: 1 файл.
  4. Интерфейс не вырос: тот же `--repo`, rc 0/1/2, новых флагов нет.
  5. Потребители — клетки proj-*.

  → **ESSENTIAL.**
- **Проектный блок резолвера (`:114-164`: source next_id.sh, вызов, jq, `rel_inside`).**
  1. Свойство: И-6.
  2. Состояние: локальные `reg_rel` и `road_rel`, наружу видны только в путях сообщений.
  3. Совместных правок: 1 файл; грамматику профиля не повторяет — она у резолвера.
  4. Интерфейс: читает ambient только через `HARNESS_PROJECT_LAYER_ROOT`, и тот принудительно равен R (`:129`).
  5. Потребители: proj-alt-*, proj-broken-profile.

  → **ESSENTIAL.** Ветви `reg_rel = "."`/пусто (`:152-153`, `:158-162`) и фолбэк `${road_rel:-ROADMAP.md}` (`:163`) недостижимы: резолвер отклоняет registry, равный корню (`next_id.sh:444-448`, требуется `"$REPO_ABS"/*`), а roadmap всегда `<state>/ROADMAP.md`. Это ACCIDENTAL, совет С-1.
- **Проектные сообщения отказа (`:170-176`).**
  1. Свойство: И-7.
  2. Состояние: stderr.
  3. Совместных правок: 1 файл.
  4. Интерфейс не вырос.
  5. Потребители: proj-no-plan-*, мои D и F.

  → **ESSENTIAL.**

## ПРОВОДКА (038)

- **guard.** `scripts/orch_plan_slice.sh` — барьер именно этого предмета; шаг CI `registry/ci-steps.tsv:303` неизменен.
- **role.** Канал **разорван**: `check_provodka` RC=1 на OBJECT при RC=0 на main. См. Рв182-1.

## СВЕРКА-СТАНДАРТОВ:

Неприменимо: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (grep пуст).

## СВЕРКА-АРХИТЕКТУРЫ:

- **Размещение:** `scripts/` — как в v1.
- **Зависимости:** новая — `scripts/next_id.sh` (`project_paths_resolve`). Это единый резолвер 996, второй не введён.
- **Писатели:** новых нет, срез только читает.
- **Операции:** git show / cat-file / ls-remote / rev-list — только чтение.
- **`bindings.json` и модель 188:** в харнессе отсутствуют (`tooling/checks/cli.js` нет; `git ls-files` даёт `bindings.json` только в фикстуре 119). Уровень diff модели неприменим, долг не расширен.

## Режим проекта (996)

sourceCanon не объявлен (`harness.project.json` на origin/main без `sourceCanon`). `check_project_sources --stage done` RC=0 на текущем HEAD=OBJECT 5aa2411642.

## ОСТАТОК (192)

В контракте 182 нет строк К-NN с ловцом reviewer (`grep -c 'К-[0-9]'` → 0). «НЕ ЗАЩИЩАЕТ» v2:

- отсутствие плана — не укусило: проекты станции дают правдивый отказ;
- задержка fetch — не укусило: CLI по-прежнему снимает SHA локального remote-tracking ref.

## Мобильный экран

Неприменимо.

## Развилки

- **Рв182-1 — толкование «вставка в строку 182».** Если оркестратор или architect читают её как обязательно ту же физическую строку, контракт v2 противоречит собственному ПРОВОДКА `role=` (038) и `done_contract.sh` шагу 6 — тогда ESCALATE к арбитру/владельцу, не FAIL. Я выбрал FAIL: есть форма, которая выполняет обе буквы. Оговорка идёт следующей строкой того же абзаца (мягкий перенос markdown), v1-строка остаётся целой строкой, оговорка — в строке/пункте 182 роли. Проверено: provodka RC=0, gen --check RC=0, батарея 35/35.
- **Рв182-2.** И-7 перечисляет выходы для трёх причин. Отказ ls-remote в перечне не назван, но вводный оборот И-7 касается любого отказа проектного режима. Сама реализация так его и читает: префикс у неё получили и неперечисленные «нет ROADMAP» и «нет contracts.tsv». Оставлен блоком.
- **Имя файла вердикта.** Задание называло `verdicts/review/contracts-182-impl-v1.md`, но этот путь занят историческим FAIL-вердиктом v1 (f027f615, OBJECT 6670235d). Перезаписывать его не стал и взял `contracts-182-v2-impl-v1.md`.

## Что не проверено

- Первый прогон `check_zones.sh` в основном клоне загрязнён: пока он шёл, я переключал HEAD. Он дал RC=0, но я его не засчитываю. Засчитан чистый повтор во втором клоне — RC=0, см. «Проверки роли» п. 1.
- Модель-факт по трассе: `models_actual.sh --session c907157c` → «сессия не найдена».
- Ленд в CI (полный workflow) не гонял; `ci_preflight` падает одинаково на main и OBJECT.

## Применимость

Вердикт привязан к OBJECT `5aa2411642` и блобам:

- `scripts/orch_plan_slice.sh` = `a1610b1c`;
- `roles/orchestrator.md` = `a8b913fb`;
- `.omp/agents/orchestrator.md` = `dc4c282e`.
