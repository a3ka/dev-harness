accept
OBJECT=b1d400da33875adff8551e4098ccb30fda936718
СУД: репо=dev-harness; предмет=217; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev217; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev217 | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl217 — implementer (MiniMax), Architect217c; предыдущие адверсарные: archive/217/adversary-v1-fail-2b624c289a, archive/217/adversary-v2-fail-edaf3d0df2; правило остановки R-0094
КЛАСС=КОДОВЫЙ, риск РИСКОВЫЙ. Контракт frozen/contracts/217/2 (`71a4796f8`). Блоков 0. Советов 2 (С-1, С-2) и наблюдений 2 (Н-1, Н-2), все в `.review/2026-11-25-2171.md`.

# Вердикт reviewer — 217, реализация, вызов 1 (полный)

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 2**
- **С-1 (Main → владелец; отдельный предмет по проводке 083).** `incr_parse` выполняется до `INCR_GIT_ROOT="$ROOT"` (`scripts/check_charter.sh:829` против `:834`). Поэтому base/HEAD берутся из cwd. При cwd ≠ ROOT ранняя ветвь 217 амнистирует окно ROOT: база в этом случае давала rc 1, OBJECT даёт rc 0 (миры H1–H3). Ни один вызов `--incr` в станции не идёт с cwd ≠ ROOT, а контракт сам велит брать источники у lib_incr. Поэтому это не блок.
- **С-2 (architect).** `--independent-mutants` (`probe.py:530-554`) — второй цикл production-мутантов без потребителя в CI и приёмке, вне переписи `--catalog`.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код. Счётные заявления проверены своей мерой, а не повтором чужой команды. Красное предъявлено своими мутантами production в одноразовых мирах.

## 0. ОСТАТКИ контракта (контракт 192) — первыми

В «НЕ ЗАЩИЩАЕТ» frozen/217/2 номеров К-NN нет. Нумерую по порядку пунктов: НЗ-1…НЗ-4, плюс остаток R-0094.

- ОСТАТОК: НЗ-1 (подделка кеша на достижимый валидный SHA) — **не укусил**.
  - Модель доверия кешу дифф не меняет. `scripts/lib_incr.sh` не менялась: `git diff --quiet c38a7cc91 HEAD -- scripts/check_charter.sh scripts/lib_incr.sh` → rc 0, `c38a7cc91 --stat` → только check_charter.sh.
  - На мирах C/D/F база и OBJECT побайтово равны (§3).
  - Соседний класс «кеш честный, но из другого репозитория (cwd ≠ ROOT)» — отдельный совет С-1.
- ОСТАТОК: НЗ-2 (обход без Git / полный rev-list / подмена Trace2 / распознавание фикстуры; ловец — reviewer алгоритма) — **не укусил**. Ветвь `:876-879` состоит из четырёх строк: условие, `incr_finish 0`, `exit 0`, `fi`. Обхода, rev-list и распознавания мира в ней нет. Мой Trace2 на живом дереве (9175 коммитов, cwd = корень клона) насчитал 6 вызовов Git:
  ```
  -C . rev-parse HEAD
  -C . merge-base --is-ancestor b1d400da… b1d400da…
  -C . rev-list --count b1d400da…..b1d400da…
  -C /tmp/dev-harness-verify/rev217-run rev-parse --git-dir
  -C /tmp/dev-harness-verify/rev217-run rev-parse --verify HEAD
  -C /tmp/dev-harness-verify/rev217-run rev-parse --verify --quiet refs/tags/ustav/1
  rc=0 wall=.036055870; кеш: b1d400da33875adff8551e4098ccb30fda936718\n
  ```
- ОСТАТОК: НЗ-3 (внешняя нагрузка) — **не укусил**. Нагрузка станции около 8.4 (uptime). Пустой путь занял 0.028–0.036 с при пределе 2 с. Таймаутов не было.
- ОСТАТОК: НЗ-4 (регрессии публикации/merge вне линейных миров) — **не укусил**.
  - Батарея 210: 342/342/0, стабы 46/60/60/0. Батарея 113: 28 клеток, 0 красных.
  - Мои merge-миры F1/F2 (кеш = второй родитель merge, непустое окно) на базе и OBJECT дают одинаковые rc=1 и байты.
- ОСТАТОК R-0094: сравнение префикса SHA длиной N≥11 (ловец — ревьюер, чтение `scripts/check_charter.sh:876`) — **не укусил**.
  - `sed -n 876p scripts/check_charter.sh | cat -A` → `if [ "${INCR_MODE:-full}" = "incr" ] && [ "$INCR_BASE" = "$INCR_HEAD" ]; then$`. Это полное строковое равенство дословно. Подстрок `${INCR_BASE:0` в check_charter.sh и lib_incr.sh нет (grep, 0 совпадений).
  - Мой мутант m09 `${INCR_BASE:0:11}` = `${INCR_HEAD:0:11}` жив на всех 28 сценариях. Так и ожидалось: класс принят остатком, конечной батареей не закрывается. Production честна.

**НЕ ЗАЩИЩАЕТ** (сводка для владельца):
- сравнение префикса SHA длиной N≥11 (ловец — ревьюер, чтение `scripts/check_charter.sh:876`), R-0094;
- подделку кеша на достижимый SHA (НЗ-1);
- вызов с cwd ≠ ROOT (С-1; вход вне «lib_incr Git-мира», ловец — reviewer);
- shallow-клон на пустом окне: rc 0 вместо прежнего отказа `shallow` (Н-1). Порядок задан И2 и клетками e8/e9/M10.

## 1. Объект и область правки

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t668037b70/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/217/orchestrator-i2 refs/heads/main refs/heads/archive/217/adversary-v1-fail-2b624c289a refs/heads/archive/217/adversary-v2-fail-edaf3d0df2 '+refs/tags/*:refs/tags/*' → rc 0
git switch --detach b1d400da33875adff8551e4098ccb30fda936718; git rev-parse HEAD → b1d400da33875adff8551e4098ccb30fda936718
git log --format='%h %an %cn %s' 930152af8..HEAD →
  b1d400da3 architect architect 217: distinguish prefix collisions and absent charter before empty exit
  b7c5a9807 orchestrator orchestrator orchestrator: 217 CI-шаг check:incr-pustoe-okno-217-family-selftest (вес 70, замер 59 с …)
git diff --name-status 930152af8 HEAD →
  M .github/workflows/ci.yml                                    (orchestrator)
  M fixtures/workshop_project/incr_pustoe_okno_217/SDACHA.md    (architect)
  M fixtures/workshop_project/incr_pustoe_okno_217/model/empty_window.sh
  A fixtures/workshop_project/incr_pustoe_okno_217/prefix10.py
  M fixtures/workshop_project/incr_pustoe_okno_217/probe.py
  A fixtures/workshop_project/incr_pustoe_okno_217/source.json
  M fixtures/workshop_project/incr_pustoe_okno_217/stabs.tsv
  M registry/ci-steps.tsv                                       (orchestrator)
  M registry/ci-zamery.tsv                                      (orchestrator)
git show --stat c38a7cc91 → implementer <implementer@…>, committer owner; scripts/check_charter.sh | 29 +++ ; 1 file changed, 29 insertions(+)
git merge-base --is-ancestor c38a7cc91 930152af8 → rc 0 (реализация в main)
git log 4576309b967a..930152af8 -- scripts/check_charter.sh scripts/lib_incr.sh → c38a7cc91 новее 93faf6a61/4e9635091/54af79383/a25a7d7eb (210): 217 после влива 210 ✓
git diff --stat 'frozen/contracts/217/2^{commit}' HEAD -- contracts/217-incr-pustoe-okno.md → пусто (контракт не менялся)
bash scripts/gen_ci_steps.sh --check → RC_gen=0
```

Итог по зонам:
- orchestrator: ровно 3 CI-файла. Строка `step check:incr-pustoe-okno-217-family-selftest 70 …--repo . && …--model && …--stabs` и замер `70 59 0`. Перестановка лейнов в ci.yml сгенерирована (`--check` rc 0).
- architect: ровно 6 файлов в `fixtures/workshop_project/incr_pustoe_okno_217/`.
- В носителе 930152af8..HEAD не менялись production, контракт, `registry/plan.tsv` и прочие реестры.
- implementer тронул только `scripts/check_charter.sh`, свою зону.
- Committer `c38a7cc91` — owner (ленд владельцем). Автор — implementer, зона судится по автору.
- Перепины соседей: 210 `probe.py` и 113 `red_113.sh` — коммит architect `28dfbff75`. Он входит в frozen-пакет: `merge-base --is-ancestor 28dfbff75 frozen/contracts/217/2^{commit}` → rc 0. Он объявлен строками `ПЕРЕСЕЧЕНИЕ architect` (empty-root-incr / Д/gonka_kesha(а)) и п.5 приёмки. С тех пор файлы не менялись: `git diff --quiet 28dfbff75 HEAD -- …` → rc 0. Значит, соседи зелены по тексту architect, объявленному в контракте v2.

## 2. Проверки не подогнаны под код

- Implementer не трогал ни батарею, ни фикстуры: `c38a7cc91` правит один файл.
- Правки architect в носителе только добавляют. Это 5 новых клеток (w16/w17 prefix10, e10/e11/c9 no-ustav), 3 мутации (M21/M22/M23), 4 строки stabs и режим `--independent-mutants`. Прежние ожидания не ослаблены (`git diff 930152af8 HEAD -- probe.py` прочитан целиком).
- Точку вставки модели перенесли с `INCR_GIT_ROOT="$ROOT"` на после `ustav/1`. Это закрытие К-08 Adv217b («ранний выход ДО ustav/1»). Ожидание e10/e11: rc 2, `NOT_IMPLEMENTED: устав не введён`, кеш не тронут. Так вела себя база 4576309b до 217, это И4/И5. Это не подгонка.

## 3. Свои миры и мутанты production (не клетки батареи)

Скрипты `worlds.sh` (28 сценариев, у каждого мира свой `.git`, даты детерминированы) и `mutants.py` (14 мутантов `scripts/check_charter.sh` OBJECT). Прогон: база `cdeb97887` = `c38a7cc91~1`, OBJECT, каждый мутант. Сравнение построчно: rc, sha256 stdout, stderr, od кеша.

Дифференциал база → OBJECT (`diff res-base res-obj`, изменились только эти строки):
```
A1..A4 (пустое окно: LF / без LF / --incr= / --oracle --incr), D8 (кеш HEAD + 2-я строка), L1 (каталог кеша read-only):
  база rc=0 + ok-строки и сводка; OBJECT rc=0, stderr ровно «incr: check_charter судит X..X (0 коммитов)\n», stdout пуст, кеш «<HEAD>\n» (A2/A4 без LF нормализованы)
H1/H2/H3 (cwd ≠ ROOT, С-1): база rc=1 FAIL AGENTS.md; OBJECT rc=0 только маркер
I1 (shallow, Н-1): база rc=1 «реестр устава … недоступен: shallow»; OBJECT rc=0
```
Без изменений (побайтово): B1/B2 (full fast/oracle с нарушением, rc 1), C1/C2/C3 (непустое окно: rc 1 и кеш не сдвинут, причём C2 без LF так и остаётся без LF; разрешённая правка — rc 0 и кеш HEAD), D1/D2/D3/D7 (мусор / пустой / HEAD+мусор / UPPER: rc 1 «кеш повреждён», кеш не тронут), D4/D5/D6 (неизвестный / не-предок другой ветки / отсутствует: полный прогон, rc 1), E1 (нет ustav/1: rc 2), F1/F2 (соседнее слияние), J1 (объект HEAD удалён), K1/K2 (повреждён объект HEAD / предка). В J1/K1/K2 пустота НЕ зелёная: «полный прогон (база … не предок …)», rc 1.

Мутанты (`KILLED_BY` — сценарии, где мутант расходится с OBJECT):
```
m01_n0_only KILLED_BY: B1 B2 D4 D5 D6 J1 K1 K2      (выход по INCR_N=0 без режима)
m01b_mode_n0 KILLED_BY:                              (incr ∧ N=0 — эквивалент, Н-2)
m02_rawcache_before_validation KILLED_BY: D1 D2 D3 D7 E1 J1 K1 K2
m03_no_mode KILLED_BY: B1 B2                         (выход в full-режиме)
m04_before_ustav KILLED_BY: E1
m05_no_finish KILLED_BY: A2 A4 D8
m06_no_lf KILLED_BY: A1 A2 A3 A4 D8 H1 H2 H3 I1 L1
m07_writes_ancestor KILLED_BY: A1 A2 A3 A4 D8 H1 H2 H3 I1
m08_finish_before_check KILLED_BY: C1 C2 D4 D5 D6 F1 F2   (кеш продвинут при отказе)
m09_prefix11 KILLED_BY:                              (R-0094, остаток)
m10_finish_rc1 KILLED_BY: A2 A4 D8
m11_merge_second_parent KILLED_BY: F1 F2             (игнор окна соседнего слияния)
m12_full_missing_cache KILLED_BY: D6
m13_exit_rc_lost KILLED_BY: A1 A2 A3 A4 D8 H1 H2 H3 I1 L1
```
Из 14 мутантов пойманы 12. Живы m01b (эквивалент, Н-2) и m09 (остаток R-0094).

Гонка: `INCR_HEAD` фиксируется один раз (`lib_incr.sh:124-130`), ранняя ветвь пишет именно его через `incr_finish` (`:196-206`, tmp + mv) и HEAD не перечитывает. Коммит, пришедший после разбора, в кеш не попадает. Это проверено чтением кода, мир гонки не строился. Гонку непустого окна держит клетка 113 `Д/gonka_kesha(a)` после перепина: зелёная.

## 4. Дефекты честной production

- Амнистия непроверенной истории на конформном входе — нет. Валидация кеша (D1–D8), full-fallback (D4–D6), отказы (C1/C2) и merge (F1/F2) побайтово как на базе. Единственная амнистия — вход cwd ≠ ROOT (С-1, недостижим из вызовов станции).
- Потеря rc — нет (m13 ловится; E1 rc 2 сохранён; L1 при недоступном каталоге кеша rc 0, кеш прежний — как база).
- Вывод пустого окна совпадает с И1: stdout пуст, stderr ровно маркер 083, кеш `<HEAD>\n`. То же даёт мой живой прогон (§0) и A1–A4.
- Соседи вне контракта не сломаны (§5).

## 5. Регресс (сырой вывод, rc, числа; одноразовый клон `/tmp/dev-harness-verify/rev217-run` на OBJECT)

```
W --repo .              → KLETKI=41 ZELENYE=41 KRASNYE=0; RC=0 (real 19.1 s)
W --model               → KLETKI=41 ZELENYE=41 KRASNYE=0; RC_model=0
W --stabs               → MUTACII=23 SVJAZI=29 POIMANY=29 ZHIVYH=0; RC=0
W --model --live        → LIVE commits=9175 seconds=0.030 rc=0 bytes=(0, b'', b'incr: check_charter судит b1d400da..b1d400da (0 коммитов)\n'); RC_live=0
W --repo . --live       → LIVE commits=9175 seconds=0.028 rc=0; RC_repolive=0
W --catalog             → KLETKI=41 MUTACII=23 SVJAZI=29; RC_cat=0
W --syntax              → SYNTAX bash=2 python=2 rc=0; RC_syntax=0
W --production-stabs    → MUTACII=8 SVJAZI=10 POIMANY=10 ZHIVYH=0; RC_ps=0
W --independent-mutants → INDEPENDENT prefix10 -> w16-prefix10-denied: POIMAN; INDEPENDENT before-cache -> c9-no-ustav-broken: POIMAN; RC_im=0
210 --repo .            → ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0; RC_210_repo=0 (198:210 empty-root-incr ok rc=0)
210 --model             → ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0; RC_210_model=0
210 --stabs             → ИТОГ 210: MUTACII=46 SVJAZI=60 POIMANY=60 ZHIVYH=0; RC_210_stabs=0
113 red_113.sh          → клеток: 28 · красных: 0; RC_113=0 (ok_КЛЕТКА: Д/gonka_kesha(a): кеш ≤ проверенного объёма; второй --incr == --oracle)
207 --repo .            → KLETKI=50 ZELENYE=50 KRASNYE=0; RC_207=0
200                     → ИТОГ 200 (субъекты дерева): клеток 11, красных 0, зелёных 11; RC_200=0
check_provodka . contracts/217-incr-pustoe-okno.md → RC_provodka=0
shellcheck 0.11.0 -S warning scripts/check_charter.sh: база c38a7cc91~1 → 6 предупреждений (все SC2034), rc 1; OBJECT → 5 (все SC2034), rc 1 — не хуже (ушёл SC2034 INCR_HEAD; остался SC2034 INCR_GIT_ROOT :834 — см. С-1)
bash -n scripts/check_charter.sh → 0; bash -n scripts/lib_incr.sh → 0
```
Чистый клон (урок 211/222): `/tmp/dev-harness-verify/rev217-clean`. Создан через `git init` и `fetch --no-tags` одного OBJECT, origin = `ssh://git@github.com/a3ka/dev-harness.git`. Тегов 0, refs 0, базовая линия `4576309b…` — предок:
```
--repo .  → KLETKI=41 ZELENYE=41 KRASNYE=0; RC_clean_repo=0
--model   → KLETKI=41 ZELENYE=41 KRASNYE=0; RC_clean_model=0
--stabs   → MUTACII=23 SVJAZI=29 POIMANY=29 ZHIVYH=0; RC_clean_stabs=0
git status --short → 0 строк (дерево не записано)
```
Не запускались, по заданию, из изолированной копии: `pre_critic`, `check_sdacha --run`, `fixtures/_krasnye_083.sh`. Их полностью прогоняет оркестратор отдельно.

Счёт своей мерой, а не командой автора:
- `stabs.tsv`: 30 строк без `#`, из них 1 заголовок, значит 29 связей. Различных мутаций 24 − 1 (заголовок) = 23.
- `grep -cE "^\s+Cell\('" probe.py` → 41 клетка каталога. 42-е вхождение `Cell('live'` на `:567` — внутренняя live-проба, не клетка.
- `source.json` census `{"cells": 41, "mutations": 23, "bindings": 29}` совпадает.
- «+29 строк» = `--stat` 29 insertions. Вес и замер `70/59` = `registry/ci-steps.tsv`/`ci-zamery.tsv`. Живая история — 9175 коммитов (`rev-list --count`).

## 6. ПРОВОДКА (038), Н-39, режим проекта

- `ПРОВОДКА: guard=scripts/check_charter.sh` существует. Он подключён строкой CI legkij `check:charter` (`registry/ci-steps.tsv:49`, `--incr tmp/ci-incr/charter.sha`) и библиотечным импортом `.githooks/pre-push:90`. Guard — барьер именно этого предмета.
- `ПРОВОДКА-ЭНФОРСМЕНТ` обоснован честно: чистое ускорение уже подключённого стража, новых поведенческих норм ролей нет.
- Н-39: стабы привязаны architect в `stabs.tsv`/`probe.py`. Контракт несёт инварианты И1–И5 и rc-команды, списка привязок в нём нет ✓.
- 996: `sourceCanon` не объявлен — н/п. Записи сделаны только в одноразовых клонах под `/tmp/dev-harness-verify/`.

## 7. Паразитная сложность (050)

- **Ранняя ветвь `scripts/check_charter.sh:852-879`** (4 строки кода, 24 комментария). (1) И1/И2. (2) Нового состояния нет: читает `INCR_*` lib_incr, пишет кеш штатным `incr_finish`, что видно в маркере и байтах кеша. (3) Меняется 1 файл, число не выросло. (4) Интерфейс не растёт: ни флагов, ни env. (5) Потребители — клетка 083 И0, CI legkij, батарея 217. **ESSENTIAL.**
- **`prefix10.py`** (новый, 74 строки). (1) Полное равенство SHA (И1, «значения SHA не меняют смысл»): мутанты prefix-8/10 К-08 Adv217b не ловятся миром prefix4, нужна настоящая 10-hex коллизия. (2) Временный Git-мир в TMPDIR, seed/salt из `source.json` — явно в выводе `PREFIX10 seed=… salt=…`. (3) При правке свойства меняются вместе probe.py, source.json, stabs.tsv (+1 файл). (4) Один вход `construct(root, base, git, allowed)`, за ним поиск коллизии: модуль глубокий. (5) Потребители — клетки w16/w17 в `--repo/--model/--stabs` CI. **ESSENTIAL.**
- **`source.json`** (новый). (1) Перепись клеток/мутаций/связей и baseline: ловит молчаливое сокращение клеток вместе со строками stabs, которое TSV-покрытие пропускает. (2) Статичен. (3) +1 файл в совместной правке. (4) Интерфейса нет. (5) Потребитель — `bindings()` `SOURCE_CENSUS`. **ESSENTIAL.**
- **`probe.py` +69 строк** (клетки w16/w17/e10/e11/c9, M21–M23). (1) К-08 Adv217b. (2) Только TemporaryDirectory. (3) stabs/source.json. (4) Интерфейс вырос на флаг `--independent-mutants`. (5) У клеток и мутаций потребитель CI есть, у флага — нет. Клетки и мутации **ESSENTIAL**; флаг `--independent-mutants` **ACCIDENTAL — совет С-2**. Фрагмент — `probe.py:530-554`. Отсутствующее свойство — потребитель в CI или приёмке и перепись. Простая форма — строки `MUTATIONS`/`stabs.tsv` под `--production-stabs`.
- **`stabs.tsv` +4 строки** (семья, один артефакт). (1) Н-39. (5) Потребитель — `--stabs` CI. **ESSENTIAL.**
- **CI-строка и замер** (orchestrator). (1) «Батарею 217 подключает orchestrator». (3) Три CI-файла меняются вместе — штатная генерация. (5) Потребитель — CI. **ESSENTIAL.**

СВЕРКА-СТАНДАРТОВ: н/п — `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`grep -c 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` → 0); дифф — bash-guard и фикстуры станции.
СВЕРКА-АРХИТЕКТУРЫ: размещение — ветвь внутри существующего `scripts/check_charter.sh` после дешёвых отказов и до `registry_state`, зона implementer; зависимости — только lib_incr (`incr_finish`), новых нет; писатели — кеш пишет прежний атомарный писатель 083, второго писателя нет; операции — проектной модели 188 у станционного guard нет (контракт: «АРХИТЕКТУРА: н/п»), `bindings.json` н/п; долг не расширен (shellcheck 6→5); уровень diff модели — нет модели, L2/L3 не возникают.

## 8. Остатки

- Принятый остаток R-0094: префикс SHA N≥11. Ловец — reviewer, строка `:876` прочитана, равенство полное.
- С-1 и С-2 — советы в `.review/2026-11-25-2171.md`, merge не блокируют.
- Н-1 (shallow) и Н-2 (эквивалент m01b) — наблюдения.
