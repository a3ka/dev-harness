accept
СУД: repo=dev-harness; предмет=159; фаза=проводка CI (шаг 5, после реализации), кандидат пересобран на combined main; роль=reviewer; вызов=2 (fresh scoped: только зона CI-проводки 159; accept v1 на 9a8ef29e/PR #614 не переносится); сессия=Review159CombinedCi; OBJECT=78eb851af2899c2dec082a83edcb25a9ae7663a7
OBJECT=78eb851af2899c2dec082a83edcb25a9ae7663a7
Контракт: frozen/contracts/159/2 (тег → коммит 1a67dfb2; блоб контракта bb850299fc7e10a7c727283ec9327bd3e8d0c30a — тот же в OBJECT). Кандидат: wip/159/orchestrator = origin/wip/159/orchestrator = OBJECT, PR #616 (`gh pr view 616`: headRefOid = OBJECT, state OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN). Родитель OBJECT — 825ef8587 (combined main: 167 приземлён 0f3660d64, вердикт 159-ci-v1), коммит один, автор `orchestrator <orchestrator@dev-harness.local>`.
--sud: reviewer <трасса> Review159CombinedCi; строки трассы (`scripts/models_actual.sh --tsv --bind --all`, фильтр по полю 4 = Review159CombinedCi; 2 строки): `reviewer	anthropic/claude-opus-5-5	allowed	Review159CombinedCi	78eb851af2899c2dec082a83edcb25a9ae7663a7`; `scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/r159ci2-sud.tsv --object 78eb851af2899c2dec082a83edcb25a9ae7663a7 --session Review159CombinedCi --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 159, проводка CI v2 (кандидат на combined main, PR #616)

## Итог

Блокирующих находок нет. OBJECT 78eb851a — один коммит orchestrator поверх combined main 825ef8587,
где 167 уже приземлён. Коммит трогает ровно три пути ЗОНЫ orchestrator. В `registry/ci-steps.tsv`
он дописывает в хвост 2 строки 159 (комментарий и step), в `registry/ci-zamery.tsv` — 1 строку
замера 159; `.github/workflows/ci.yml` — вывод генератора. Свои меры:

- строка 159: вес 20, команда побайтово равна безфлаговому `W` блоба (строка 36 контракта);
- строка замера `20	8	0` — вывод `scripts/measure_ci_weights.sh --logs` на корпусе из восьми
  наблюдений 20,19,19,20,20,20,19,20 (воспроизведено на синтетическом корпусе из этих чисел);
  инструмент различает корпуса: при 20,19,19,20,19,20,19,19 он даёт 19;
- обе строки 167 (комментарий и step) побайтово равны на 0f3660d64, 825ef8587 и OBJECT, вес 6,
  замер `6	8	0`;
- матрица 93↔93: у реестра 93 step-ключа, в lanes 93 ключа, дублей 0, расхождений множеств 0,
  ключ 159 в l6;
- ручных маркеров конфликта в трёх файлах 0;
- 51/51 в каждом из моих 8 прогонов lane-команды и на раннере PR #616;
- 083 и ПРОВОДКА: красный → зелёный; паритет зелёный и для этого шага недискриминирующий;
- анти-плацебо: мутанты гейта, проводки и отсутствие гейта роняют CI-шаг.

PR #616 CI: run 42523965761 (headSha = OBJECT, event pull_request) — success. Глобальный красный
`check_ci_weights` — чужой долг 118/123, тот же на базе, на OBJECT и на origin/main.

Найдено три наблюдения, все неблокирующие (подробно — §Находки). О-1: сырой корпус автора не
сохранён. О-2: маркеры конфликта в `ci-steps.tsv` чужие барьеры не ловят. О-3: паритет и
ПРОВОДКА не пинят безфлаговость.

Accept относится только к блобам OBJECT 78eb851a. Совет С-1 вердикта v1 закрыт: строка замера
равна выводу инструмента на заявленном корпусе, и `check_ci_weights --migrate` (точное
равенство) зелёный. О-1 v1 закрыт: кандидат пересобран на combined main, слияние с текущим
origin/main чистое.

Все прогоны шли в одноразовых клонах. `/tmp/dev-harness-verify/r159ci2` — SSH-клон origin, HEAD =
OBJECT, push-url=DISABLED, корпус наблюдений. `/tmp/dev-harness-verify/r159ci2-mut` — локальный
клон, push-url=DISABLED, мутанты. Основной worktree не менялся, кроме этого файла. Push не делался.

## 1. Область правки

- `git diff --name-only 825ef8587 OBJECT` → `.github/workflows/ci.yml`, `registry/ci-steps.tsv`,
  `registry/ci-zamery.tsv`. ЗОНА orchestrator блоба (строка 61) объявляет ровно эти 3 пути, в
  зоне 3 из 3. `git log 825ef8587..OBJECT` → один коммит `78eb851a orchestrator`.
- ПЕРЕСЕЧЕНИЕ «только новая строка self-test 159» (ci-steps, строки 110–126 блоба): `git diff -U0`
  → `@@ -294,0 +295,2 @@`. Своя мера (python, байты): ci-steps базы — побайтовый префикс
  ci-steps OBJECT, дописано 2 строки: `# КОНТРАКТ 159: …` и
  `step	check:pustoj-produkt-159-family-selftest	20	bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh`.
- ПЕРЕСЕЧЕНИЕ «только замер новой строки 159» (ci-zamery, строка 127): база — побайтовый префикс,
  дописана 1 строка `check:pustoj-produkt-159-family-selftest	20	8	0`.
- ПЕРЕСЕЧЕНИЕ «только производная материализация генератором» (ci.yml, строки 66–109): изменились
  6 строк `keys:` (l2–l7). Своя мера (разбор блока GENERATED обеих ревизий): у базы 92 ключа, у
  OBJECT 93; добавлен ровно `check:pustoj-produkt-159-family-selftest`, удалений нет, 54 ключа
  сменили lane (LPT). Ключ 167 переехал l7 → l4, его команда — в реестре, а не в ci.yml.
  Побайтовость генерата — §2.
- Баланс, своя мера по весам OBJECT: `l1 756, l2 362, l3 362, l4 362, l5 362, l6 361, l7 361`,
  всего 2926, ceil(2926/7) = 418; максимум 756 — одиночный ключ l1.
- Пробное слияние с текущим origin/main b18efc163 (`git merge-tree --write-tree origin/main OBJECT`)
  прошло чисто, rc 0, дерево 0d10cac4. Diff этого дерева с OBJECT по трём путям зоны пуст;
  отличается только `registry/contracts.tsv` (строка 168 из main). База 825ef8587 — предок
  origin/main.

## 2. Сырой вывод — команды и rc

| Команда (клон, HEAD = OBJECT, если не сказано иное) | rc | Вывод (суть) |
|---|---|---|
| `reslop t -- bash scripts/gen_ci_steps.sh --check` | 0 | `exit: 0` |
| ci.yml базы 825ef8587 при реестре OBJECT: `gen_ci_steps.sh --check` | 1 | `gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра` |
| затем `gen_ci_steps.sh --write`; `git diff --quiet HEAD -- .github/workflows/ci.yml`; `--check` | 0 / 0 / 0 | генерат побайтово равен ci.yml OBJECT |
| реестр без step-строки 159 при ci.yml OBJECT: `gen_ci_steps.sh --check` | 1 | дрейф JOBS |
| `bash scripts/check_provodka.sh . contracts/159-pustoj-produkt-krasnyj.md` — три пути зоны базы 825ef8587 | 1 | `проводка: guard не подключён: fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/` |
| то же — реестр без step-строки 159, ci.yml OBJECT | 1 | то же |
| то же — OBJECT | 0 | вывода нет |
| `reslop t -- bash scripts/verify_ci_parity.sh` — OBJECT; база; реестр OBJECT при ci.yml базы | 0 / 0 / 0 | `workflow-команд: 19 · скриптов в приёмке: 86 · объявленных исключений: 28 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0` |
| `bash scripts/run_ci_lane.sh check:pustoj-produkt-159-family-selftest` ×8 (мой корпус, `/tmp/dev-harness-verify/r159ci2-corpus/run1..8.log`) | 0 ×8 | в каждом `клеток 51, зелёных 51, красных 0; режим derevo` и 51 строка `CASE … ok`; замеры `19,18,18,18,18,18,18,18` |
| `measure_ci_weights.sh --root <корень только со step-строкой 159 OBJECT> --logs <мой корпус>` | 0 | `ok: замеры записаны: 1 ключей, окно 0`; `check:pustoj-produkt-159-family-selftest	18	8	0` |
| то же на корпусе из восьми чисел автора `20,19,19,20,20,20,19,20` (по одной каноничной строке `замер: <ключ> <с>` на лог) | 0 | `check:pustoj-produkt-159-family-selftest	20	8	0` — побайтово строка OBJECT |
| то же, корпус `20,19,19,20,19,20,19,19` (дискриминация) | 0 | `…	19	8	0` |
| то же, 7 наблюдений `20,19,19,20,20,20,19` (поле n) | 0 | `…	20	7	0` |
| `bash scripts/check_ci_weights.sh` — OBJECT / база 825ef8587 / origin/main b18efc163 | 1 / 1 / 1 | одинаково: `ОТКАЗ: нет замера: check:erstinformation-118-family-selftest check:sverka-maketa-123-family-selftest` |
| `scripts/models_actual.sh --tsv --bind --all` (фильтр Review159CombinedCi) | 2 | 2 строки трассы моей сессии; rc 2 — чужой `NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: Arbiter079Б1` |
| `scripts/check_sud_model.sh --verdict reviewer … --session Review159CombinedCi` | 0 | `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется` |

CI PR #616: `gh pr view 616 --json statusCheckRollup` — klass, legkij, obshchij, ap1–ap5, l1–l7 и
tyazhelyj-itog SUCCESS, vorota SKIPPED. `gh run view 42523965761`: `conclusion success`, `event
pull_request`, `headBranch wip/159/orchestrator`, `headSha 78eb851a…`.
Лог job l6 128863345382 (`gh api …/jobs/128863345382/logs`, 3025 строк):
- `HEAD is now at 78eb851a`;
- lane-команда несёт `check:pustoj-produkt-159-family-selftest`;
- `+ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh` — побайтово
  команда реестра;
- 51 строка `CASE … ok` (своя мера — python по диапазону 2089–2142: ok 51, всего CASE 51);
- `клеток 51, зелёных 51, красных 0; режим derevo`;
- `замер: check:pustoj-produkt-159-family-selftest 24`;
- `lane: отказ` 0, `##[error]` 0.

Лог job l4 128863345444: `HEAD is now at 78eb851a`,
`+ bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo && … --stabs && bash -n scripts/zamok_predmeta.sh`,
`замер: check:obryv-167-family-selftest 6`, `lane: отказ` 0, `##[error]` 0.

## 3. Проверки не переписаны

`git diff --stat 1cc2c088b OBJECT -- contracts/159-pustoj-produkt-krasnyj.md fixtures/workshop_project/pustoj_produkt_159/ scripts/check_pustoj_produkt.sh`, плюс четыре `probe.py`
147/148/149/151, плюс `fixtures/workshop_project/obryv_167/` и `scripts/zamok_predmeta.sh` →
пусто. CI исполняет ту же реализацию и ту же батарею, которую принял `contracts-159-impl-v2.md`
(OBJECT 1cc2c088). Батарея и гейт 167 тоже не тронуты. Блоб контракта в OBJECT равен блобу тега
(bb850299). Автор OBJECT — orchestrator. Файлов проверок и фикстур он не менял.

## 4. Красное предъявлено (свои прогоны)

| Барьер | Красное | Зелёное |
|---|---|---|
| ПРОВОДКА guard `red_pustoj_produkt_159.sh` (038 г3) | три пути зоны базы 825ef8587: `проводка: guard не подключён: …red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/`, rc 1; то же при реестре без step-строки 159 | OBJECT rc 0 |
| генератор JOBS (083) | ci.yml базы при реестре OBJECT — дрейф, rc 1; реестр без строки 159 при ci.yml OBJECT — дрейф, rc 1 | `--write` → байты = OBJECT; `--check` rc 0 |
| паритет (020/083) | красного для этого шага нет. Зелёный на базе, на OBJECT, на реестре OBJECT с ci.yml базы и на трёх мутантах домена lanes (О-3). Для этого шага барьер недискриминирующий: его роль — не сломаться | rc 0, `расхождений: 0` |
| анти-плацебо шага CI: гейт | мутант `scripts/check_pustoj_produkt.sh:156` (`'PUSTOJ_PRODUKT: KATALOG_PUST'` → `'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'`): `run_ci_lane.sh check:pustoj-produkt-159-family-selftest` rc 1, `клеток 51, зелёных 45, красных 6`. Красные: `s-gate-raven-etalonu/b1-pustoj-katalog`, `s-gate-pishet-trassu` и четыре `W-<батарея>/b1-pustoj-katalog` `KRASNO GATE_NE_PERVYM_DEISTVIEM`; затем `lane: отказ ключа check:pustoj-produkt-159-family-selftest (rc=1)` | OBJECT rc 0 ×8, 51/51 |
| анти-плацебо шага CI: проводка | мутант `fixtures/workshop_project/vkladki_tabov_148/probe.py:943` (`if rc_gejta != 0:` → `if False:`, rc гейта выброшен): rc 1, `клеток 51, зелёных 44, красных 7`. Красные: шесть `W-vkladki_tabov_148/<вход>` `KRASNO KLETKI_POSLE_OTKAZA после причины гейта выведено ещё 38 строк(и), первая 'CASE chestnyj-vkladki ok'` и `W-path-bash-vkladki_tabov_148 KRASNO KONTROL_NEVALIDEN KLETKI_POSLE_OTKAZA`; замер 327 с, `lane: отказ ключа …` | OBJECT rc 0 ×8 |
| анти-плацебо шага CI: гейта нет | `mv scripts/check_pustoj_produkt.sh …off`: rc 1, `клеток 27, зелёных 0, красных 27`: 3 `SUBJECT_ABSENT` (гейт) и 24 `GATE_NE_VYZVAN записей трассы 0` (своя мера — счёт причин по логу); это форма п. 1 контракта: 27 клеток, 3 SUBJECT_ABSENT. Замер 13 с, `lane: отказ ключа …` | OBJECT rc 0 ×8, 51/51 |

Вес 114, мутанты `check_ci_weights.sh` (клон мутантов, к OBJECT временно дописаны две чужие строки
замера 118/123 с весами реестра 58/0 — только чтобы изолировать предмет от чужого долга):

| Мутант | rc | Вывод |
|---|---|---|
| OBJECT + чужие 118/123 | 0 | `ok: веса по замеру: 99 ключей` |
| `--migrate` (точное равенство замера и реестра) | 0 | `ok: веса по замеру (миграция): 99 ключей` |
| нет строки замера 159 | 1 | `ОТКАЗ: нет замера: check:pustoj-produkt-159-family-selftest` |
| замер 159 = 6 при реестре 20 | 1 | `ОТКАЗ: вес не по замеру: check:pustoj-produkt-159-family-selftest (реестр 20, замер 6)` |
| реестр 159 = 61 при замере 20 | 1 | `… (реестр 61, замер 20)` |
| реестр 167 = 19 при замере 6 | 1 | `ОТКАЗ: вес не по замеру: check:obryv-167-family-selftest (реестр 19, замер 6)` |
| замер 167 = 1 при реестре 6 | 1 | `… (реестр 6, замер 1)` |
| маркеры конфликта 159/167 в `ci-zamery.tsv` | 1 | `ОТКАЗ: TSV замеров вне грамматики, строка 97: <<<<<<< HEAD` |
| маркеры конфликта 159/167 в `ci-steps.tsv` | 0 | `ok: веса по замеру: 99 ключей` — см. О-2 |

После каждого мутанта шло `git checkout HEAD -- …` (и обратный `mv`). Итоговый `git status --short`
клона мутантов: только `?? .log/` — сырые логи reslop.

Guard — барьер именно этого предмета, а не любой скрипт дерева. `red_pustoj_produkt_159.sh` —
батарея 159: она гоняет живой `scripts/check_pustoj_produkt.sh` и четыре `--repo`-ветви
147/148/149/151. По мутантам выше CI-шаг краснеет и от поломки гейта, и от поломки проводки.
ПРОВОДКА контракта несёт guard-канал и строку ПРОВОДКА-ЭНФОРСМЕНТ. Её обоснование судили critic и
impl-вердикты; дифф её не трогает; `check_provodka` на OBJECT rc 0.

## 5. Атомарность

Задача одна (CI-проводка 159), коммит один, сообщение ссылается на предмет («orchestrator 159:
проводка CI — шаг check:pustoj-produkt-159-family-selftest … ЗОНА orchestrator контракта 159»).
Строки 167 в коммите есть только как неизменённый контекст: побайтовая мера в §1 и §7.

## 6. Норма не тронута

В диффе нет AGENTS.md, roles/, contracts/, decisions/, config/ (§1: 3 пути, все в ЗОНЕ orchestrator).

## 7. Заявленное = сделанное (своя мера)

- «шаг … вес 20» и команда — поле 3 = `20`; поле 4 побайтово равно `W` строки 36 блоба (без флагов
  и хвостовых пробелов) и строке задания HANDOFF.md:52
  (`step\tcheck:pustoj-produkt-159-family-selftest\t20\tbash …/red_pustoj_produkt_159.sh`).
  Контракт вес не замораживает.
- «8 наблюдений 20, 19, 19, 20, 20, 20, 19, 20 с; медиана 20; ceil = 20» — арифметика верна:
  сортировка 19,19,19,20,20,20,20,20 → (20+20+1)//2 = 20. Восемь логов с этими числами
  `measure_ci_weights.sh --logs` превращает ровно в `check:pustoj-produkt-159-family-selftest	20	8	0`,
  то есть в строку OBJECT; другой корпус дал 19 (§2). Сырой корпус автора не сохранён (О-1).
- «строка замера 20/8/0 — вывод инструмента (совпадает с весом реестра)» — подтверждено и
  инструментом, и `check_ci_weights --migrate` rc 0.
- «г2 гварда 114: расхождение 0 с ≤ 3×» — против корпуса автора 0. Против моего корпуса (18) и
  раннера PR #616 (24) — в пределах 3×.
- «167 не тронут, вес 6» — две строки 167 в ci-steps (sha256-префикс `2da282ff654994e7`) и строка
  замера `check:obryv-167-family-selftest	6	8	0` одинаковы на 0f3660d64 (ленд 167), 825ef8587 и
  OBJECT. На PR #616 шаг 167 исполнился (l4, замер 6).
- «lane l6» — подтверждено (§1 и лог l6).
- «ci.yml перегенерирован gen_ci_steps.sh --write» — подтверждено побайтовой регенерацией (§2).
- «матрица 93↔93» — 93 step-ключа реестра = 93 ключа lanes, множества равны, дублей 0.
- «без ручного разрешения конфликта» — маркеров `<<<<<<<`/`=======`/`>>>>>>>`/`|||||||` в трёх
  файлах 0 (своя мера, regex по строкам). Реестры базы — побайтовые префиксы реестров OBJECT, так
  что в хвосте чужих строк нет правок.
- «51/51» — в 8 моих прогонах и на раннере PR #616.

## Находки

- [ ] **О-1 (наблюдение, не блок; класс — воспроизводимость замера 114).** Фрагмент:
  `registry/ci-zamery.tsv:98` `check:pustoj-produkt-159-family-selftest	20	8	0` и комментарий
  реестра «20, 19, 19, 20, 20, 20, 19, 20 с». Сырые логи корпуса автора не сохранены: каталог
  `/tmp/c159-zamery-corpus/{logs,err}` создан в 20:46, а коммит — в 20:55; оба подкаталога пусты.
  Восемь чисел поэтому проверяемы только как заявленные. Я проверил, что инструмент превращает их
  ровно в строку OBJECT, и что вес 20 проходит г2 против независимых наблюдений: мой корпус дал 18
  (`18	8	0`), раннер PR #616 — 24. Почему не блок: контракт вес не замораживает, вес 20 —
  строка задания HANDOFF.md:52, г2 гварда 114 для ключа 159 зелёный. Замена строки замера на
  `18	8	0` (мой корпус) или на `24	8	0` (раннер) при реестре 20 даёт `check_ci_weights.sh`
  rc 0 (`ok: веса по замеру: 99 ключей`, чужие 118/123 досыпаны); `--migrate` в обоих случаях
  rc 1 (`реестр 20, замер 18` / `замер 24`). Значит, любая из наблюдённых форм проходит
  постоянный гвард, а точное равенство держится только на корпусе автора. Совет оркестратору —
  хранить корпус, из которого записана строка замера, до суда.
- [ ] **О-2 (наблюдение вне 159; класс — чужой барьер 083/114, атрибуция).** В `registry/ci-steps.tsv`
  маркеры конфликта (обёртка двух хвостовых пар 167/159 в `<<<<<<< HEAD … ======= … >>>>>>>`)
  не ловят ни `gen_ci_steps.sh --check` (rc 0), ни `check_ci_weights.sh` (rc 0), ни
  `verify_ci_parity.sh` (rc 0), ни `run_ci_lane.sh` (ключ 167 зелёный). Строки маркеров эти
  инструменты молча пропускают как не-`step`. В `ci-zamery.tsv` такие маркеры ловит
  `check_ci_weights` (грамматика TSV), но этот гвард к CI не подключён: `check_ci_weights` нет ни
  в package.json, ни в registry/ci-steps.tsv, ни в .github/, ни в .githooks/. Поэтому «нет ручных
  маркеров» на OBJECT установлено только моей мерой (§7), не барьером. Механизмы 083/114 — чужая
  зона; не правил.
- [ ] **О-3 (наблюдение; класс — дискриминирующая сила барьеров для этого шага).** Паритет
  (020/083) на домене lanes не различает ничего: подмена ключа 159 в ci.yml несуществующим,
  команда 159 `npm run <отсутствующий скрипт>` и команда `W --stabs` — везде `расхождений: 0`,
  rc 0. `check_provodka` при `W --stabs` тоже rc 0. Безфлаговость команды 159 (строка 52 блоба)
  сейчас держит только суд: на OBJECT она подтверждена побайтово (§7). Расхождения в OBJECT нет;
  требования механического пина безфлаговости контракт не замораживает.
- Атрибуция глобального красного `check_ci_weights`. Ключи без замера —
  `check:erstinformation-118-family-selftest` (реестр 58) и `check:sverka-maketa-123-family-selftest`
  (реестр 0). `git log -S` по `registry/ci-zamery.tsv` для обоих пуст: строк замера не было ни в
  одной ревизии. Отказ дословно одинаков на базе 825ef8587, на OBJECT и на origin/main b18efc163.
  К 159 и 167 он не относится: с временно досыпанными чужими строками OBJECT зелёный (99 ключей).
  Долг чужой (118/123), не чинил.
- Место для находок: роль велит класть их в `.review/YYYY-MM-DD-NN.md`, но задание этого вызова
  разрешает запись только в `verdicts/review/`, поэтому чекбоксы О-1…О-3 записаны здесь.

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| step-строка 159 + комментарий в `ci-steps.tsv` | строка 52 блоба «CI гоняет безфлаговый W»; ПРОВОДКА guard (038 г3); §Незаполненные «подключение CI-шага … `check_provodka` rc 0» | нового нет, строка реестра явная | 3 (реестр, замер, ci.yml через генератор) — как у каждой проводки; дифф число не увеличил | новых флагов и env нет | lane l6 PR #616; `check_provodka` (без строки rc 1, §4); дубля нет | ESSENTIAL |
| строка `ci-zamery.tsv` | ПЕРЕСЕЧЕНИЕ 114 «только замер новой строки 159»; г1 покрытия 114 | явная строка TSV | то же | — | `check_ci_weights` г1/г2 (мутанты §4) | ESSENTIAL |
| перегенерированный JOBS в `ci.yml` | 083 (генерация из реестра) | нет, детерминирован | — | — | `gen_ci_steps --check`, `check:gen-ci-steps-coherence` | ESSENTIAL |

Новых скриптов, функций, флагов, читаемых env, файлов и каталогов состояния дифф не вводит.

## Прочее

- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` и
  `docs/CODING-STANDARDS.md` (`grep -c 'ARCHITECTURE\|CODING-STANDARDS\|sourceCanon' AGENTS.md` = 0).
  Сверять не с чем, к этому диффу не применимо.
- Режим проекта 996 (sourceCanon) и мобильный экран к диффу не применимы.
- Чужие lanes и батареи, которые генератор переразложил, локально не гонял (задание scoped). На
  PR #616 они все SUCCESS.
