accept
СУД: repo=dev-harness; предмет=159; фаза=проводка CI (шаг 5, после реализации); роль=reviewer; вызов=1 (scoped: только зона CI-проводки 159); сессия=Review159CiWiring; OBJECT=9a8ef29ebbea595a778646f5c95208731c5dde8a
OBJECT=9a8ef29ebbea595a778646f5c95208731c5dde8a
Контракт: frozen/contracts/159/2 (тег → коммит 1a67dfb2; блоб контракта bb850299 тот же в OBJECT). Кандидат: wip/159/orchestrator = origin/wip/159/orchestrator = OBJECT, PR #614, `gh pr view 614 --json headRefOid` = OBJECT, mergeable=MERGEABLE (против origin/main 71c676a35). Родитель OBJECT — a8017112a (`land: wip/159/architect`), коммит один, автор `orchestrator <orchestrator@dev-harness.local>`.
--sud: reviewer <трасса> Review159CiWiring; строка трассы (`scripts/models_actual.sh --tsv --bind --all`, фильтр по полю 4 = Review159CiWiring): `reviewer	anthropic/claude-opus-5-5	allowed	Review159CiWiring	9a8ef29ebbea595a778646f5c95208731c5dde8a`; `scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/r159ci-sud.tsv --object 9a8ef29ebbea595a778646f5c95208731c5dde8a --session Review159CiWiring --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 159, проводка CI v1

## Итог

Блокирующих находок нет. Шаг `check:pustoj-produkt-159-family-selftest` добавлен одной строкой
реестра (плюс комментарий) с командой `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh`.
Это побайтово безфлаговый `W` замороженного блоба (строка 36), как велит строка 52 «CI после
ленда реализации гоняет безфлаговый `W`». Вес 20 — из строки задания HANDOFF.md:52; контракт
вес не замораживает. Вес проходит г2 гварда 114 против каждого наблюдения: моих восьми (медиана
18), заявленных автором (19) и наблюдения раннера PR #614 (24). Ключ сгенерирован в lane l6, блок
JOBS ci.yml побайтово равен выводу генератора. На PR #614 (все 17 проверок SUCCESS, `vorota`
SKIPPED) шаг исполнился: `клеток 51, зелёных 51, красных 0; режим derevo`. ПРОВОДКА и
генератор 083 красные без шага и зелёные на OBJECT. Если сломать гейт или проводку, шаг CI
краснеет (анти-плацебо). Глобальный красный `check_ci_weights` — чужой долг 118/123: на базе, на
OBJECT и на main отказ один и тот же. Найден один совет (С-1) и одно наблюдение по ленду (О-1).

Accept относится только к блобам OBJECT 9a8ef29e. Новая редакция кандидата его не наследует,
в том числе дерево слияния с текущим main (см. О-1).

Все прогоны шли в одноразовых клонах `/tmp/dev-harness-verify/r159ci` (HEAD = OBJECT, наблюдения)
и `/tmp/dev-harness-verify/r159ci-mut` (мутанты), оба с push-url=DISABLED. Основной worktree не
менялся. Этот файл закоммичен в клоне от main 0f3660d6 под именем reviewer и перенесён в main
основного репо fast-forward. Push не делался.

## 1. Область правки

- `git diff --name-only a8017112a OBJECT` → `.github/workflows/ci.yml`, `registry/ci-steps.tsv`,
  `registry/ci-zamery.tsv`. Строка зоны замороженного блоба, строка 61:
  `ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml`.
  В зоне 3 пути из 3. Автор коммита — orchestrator.
- ПЕРЕСЕЧЕНИЕ «только новая строка self-test 159» (ci-steps): `git diff -U0` → `@@ -292,0 +293,2 @@`.
  Добавлены ровно 2 строки: комментарий `# КОНТРАКТ 159: …` и
  `step	check:pustoj-produkt-159-family-selftest	20	bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh`.
  Чужих строк дифф не трогает.
- ПЕРЕСЕЧЕНИЕ «только замер новой строки 159» (ci-zamery): `@@ -96,0 +97 @@`, добавлена одна строка
  `check:pustoj-produkt-159-family-selftest	20	8	0` (значение — С-1).
- ПЕРЕСЕЧЕНИЕ «только производная материализация генератором» (ci.yml): изменились 6 строк `keys:`
  (l2–l7), потому что генератор (LPT) переразложил ключи. Своя мера (python, разбор блока
  GENERATED и реестра обеих ревизий): у базы 91 ключ, у OBJECT 92, дублей 0/0; добавлен ровно
  `['check:pustoj-produkt-159-family-selftest']`, удалений `[]`, 49 ключей сменили lane. Все 92
  step-ключа реестра есть в lanes, lane-ключей вне реестра нет. Ключ 159 стоит в lane `l6`.
- Баланс, своя мера (сумма весов реестра по lanes OBJECT): `l1 756, l2 361, l3 361, l4 361,
  l5 361, l6 360, l7 360`, всего 2920, максимум 756 (одиночный ключ l1), ceil(2920/7) = 418.
- Дифф не содержит ни одного файла `fixtures/`, `scripts/`, `contracts/`, `roles/`, `decisions/`,
  `config/`, `.githooks/`, `package.json`, `AGENTS.md` (`git diff --name-only a8017112a OBJECT -- …` → 0 строк).

## 2. Сырой вывод — команды и rc (клон, HEAD = OBJECT, если не сказано иное)

| Команда | rc | Вывод (суть) |
|---|---|---|
| `reslop t -- bash scripts/gen_ci_steps.sh --check` | 0 | `exit: 0` |
| ci.yml базы a8017112a при реестре OBJECT: `gen_ci_steps.sh --check` | 1 | `gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра` |
| затем `gen_ci_steps.sh --write`; `git diff --stat HEAD -- .github/workflows/ci.yml`; `--check` | 0 / — / 0 | diff пуст: сгенерированный файл побайтово равен ci.yml OBJECT |
| `bash scripts/verify_ci_parity.sh` — OBJECT / база a8017112a / реестр OBJECT при ci.yml базы | 0 / 0 / 0 | `workflow-команд: 19 · скриптов в приёмке: 86 · объявленных исключений: 28 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0` на всех трёх |
| `bash scripts/check_provodka.sh . contracts/159-pustoj-produkt-krasnyj.md` — база a8017112a | 1 | `проводка: guard не подключён: fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/` |
| то же — OBJECT | 0 | вывода нет |
| `bash scripts/run_ci_lane.sh check:pustoj-produkt-159-family-selftest` ×8 (корпус) | 0 ×8 | в каждом прогоне `клеток 51, зелёных 51, красных 0; режим derevo`, 51 строка `CASE … ok`; замеры `18,17,18,18,18,18,18,18` |
| `bash scripts/measure_ci_weights.sh --root <корень с единственной step-строкой 159 OBJECT> --logs <корпус 8 логов> --out /tmp/…/r159ci-zamer.tsv` | 0 | `ok: замеры записаны: 1 ключей, окно 0`; строка `check:pustoj-produkt-159-family-selftest	18	8	0` |
| то же с полным корнем | 2 | `ОТКАЗ: мало данных: check:approval (0 < 5); …` — корпус несёт только ключ 159 |
| `bash scripts/check_ci_weights.sh` — OBJECT / база a8017112a / main 0f3660d6 | 1 / 1 / 1 | на всех трёх деревьях одно и то же: `ОТКАЗ: нет замера: check:erstinformation-118-family-selftest check:sverka-maketa-123-family-selftest` |
| `bash scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/r159ci-sud.tsv --object OBJECT --session Review159CiWiring --root .` | 0 | `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется` |

Лог CI PR #614: run 42516403444 (workflow ci, event pull_request, headSha = OBJECT, conclusion
success), job l6 128840309333, `gh api repos/a3ka/dev-harness/actions/jobs/128840309333/logs`.
В логе есть: `HEAD is now at 9a8ef29e`; `Run bash scripts/run_ci_lane.sh check:orch-loop-997 … check:proektnaja-raskladka-161-stabs-family-selftest check:pustoj-produkt-159-family-selftest check:declared-path-family-selftest …`;
`+ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh`, что побайтово
равно команде реестра. Дальше 51 строка `CASE … ok` (своя мера: `grep -c -E 'CASE \S+ ok\s*$'`
по диапазону шага = 51), `клеток 51, зелёных 51, красных 0; режим derevo`,
`замер: check:pustoj-produkt-159-family-selftest 24`. Строк `lane: отказ` и `##[error]` в логе
джобы нет. По `gh pr view 614 --json statusCheckRollup` все 17 проверок — SUCCESS (klass, legkij,
obshchij, ap1–ap5, l1–l7, tyazhelyj-itog), кроме `vorota`, у которой SKIPPED.

## 3. Проверки не переписаны

Своя мера: `git diff --stat 1cc2c088b OBJECT -- contracts/159-pustoj-produkt-krasnyj.md fixtures/workshop_project/pustoj_produkt_159/ scripts/check_pustoj_produkt.sh fixtures/workshop_project/{gespraech_vhod_147,gespraech_tekst_149,vkladki_tabov_148,gespraech_otdacha_151}/probe.py`
пуст: в CI идёт ровно та реализация и та батарея, которую принял `contracts-159-impl-v2.md`
(OBJECT 1cc2c088). Блоб контракта в OBJECT = блоб замороженного тега (bb850299).

## 4. Красное предъявлено (своими прогонами)

| Барьер | Красное | Зелёное |
|---|---|---|
| ПРОВОДКА guard `red_pustoj_produkt_159.sh` (038 г3) | база a8017112a: `проводка: guard не подключён: …red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/`, rc 1 | OBJECT rc 0 |
| генератор JOBS (083) | ci.yml базы при реестре OBJECT: дрейф, rc 1 (§2) | `--write` → байты = OBJECT; `--check` rc 0 |
| паритет (020/083) | красного для этого шага нет: у ключа 159 нет npm-скрипта и записи `config/ci_parity_exceptions.txt`, паритет зелён на базе, на OBJECT и на реестре OBJECT с устаревшим ci.yml (§2). Для этого шага барьер недискриминирующий, его роль — не сломаться | rc 0, расхождений 0 |
| вес 114 ключа 159 (OBJECT плюс две временные чужие строки замера 118/123 с весами реестра 58/0) | замер 6 при реестре 20: `ОТКАЗ: вес не по замеру: … (реестр 20, замер 6)`, rc 1. Реестр 61 при замере 20: `(реестр 61, замер 20)`, rc 1. Без строки замера 159: `ОТКАЗ: нет замера: check:pustoj-produkt-159-family-selftest`, rc 1. `--migrate` при замере 19: `ОТКАЗ: вес не по замеру (миграция): … (реестр 20, замер 19)`, rc 1 | строки OBJECT: `ok: веса по замеру: 98 ключей`, rc 0; замер 19 (честный ceil медианы автора) и 7 (граница 3×) — тоже rc 0 |
| анти-плацебо шага CI: гейт | мутант `scripts/check_pustoj_produkt.sh:156` (`KATALOG_PUST` → `KATALOG_OTSUTSTVUET`): `run_ci_lane.sh check:pustoj-produkt-159-family-selftest` rc 1, `клеток 51, зелёных 45, красных 6`: `s-gate-raven-etalonu/b1-pustoj-katalog`, `s-gate-pishet-trassu` и четыре `W-<батарея>/b1-pustoj-katalog` `KRASNO GATE_NE_PERVYM_DEISTVIEM`; `lane: отказ ключа … (rc=1)` | OBJECT rc 0 ×8 |
| анти-плацебо шага CI: проводка | мутант `fixtures/workshop_project/vkladki_tabov_148/probe.py:943` (`if rc_gejta != 0:` → `if False:`, rc гейта выброшен): `run_ci_lane.sh …` rc 1, `клеток 51, зелёных 44, красных 7`: шесть `W-vkladki_tabov_148/<вход>` `KRASNO KLETKI_POSLE_OTKAZA после причины гейта выведено ещё 38 строк(и), первая 'CASE chestnyj-vkladki ok'` и `W-path-bash-vkladki_tabov_148 KRASNO KONTROL_NEVALIDEN KLETKI_POSLE_OTKAZA`; замер 319 с (собственные клетки 148 исполнились) | OBJECT rc 0 ×8 |
| анти-плацебо шага CI: гейт отсутствует | `mv scripts/check_pustoj_produkt.sh …off`: `run_ci_lane.sh …` rc 1, `клеток 27, зелёных 0, красных 27`: 3 `SUBJECT_ABSENT` (гейт) и 24 `GATE_NE_VYZVAN записей трассы 0` — это и есть распределение красного ДО п. 1 контракта (27 клеток) | OBJECT rc 0 ×8, 51/51 |

Все мутанты сняты через `git checkout HEAD -- …` / обратный `mv`; после снятия `git status --short`
мутационного клона пуст.

Guard — барьер именно этого предмета, а не любой скрипт дерева: `red_pustoj_produkt_159.sh` —
батарея 159, она гоняет живой `scripts/check_pustoj_produkt.sh` и четыре `--repo`-ветви
147/148/149/151; мутанты выше показывают, что CI-шаг краснеет от поломки гейта и от поломки
проводки. ПРОВОДКА контракта несёт только guard-канал и строку ПРОВОДКА-ЭНФОРСМЕНТ; её
обоснование судили critic и impl-вердикты, дифф её не трогает; `check_provodka` rc 0 на OBJECT.

## 5. Атомарность

Задача одна (CI-проводка 159), коммит один, сообщение ссылается на предмет («orchestrator 159:
проводка CI — шаг check:pustoj-produkt-159-family-selftest»). Чужих задач в коммите нет.

## 6. Норма не тронута

В диффе нет нормативных документов (AGENTS.md, roles/, contracts/, decisions/), §1.

## 7. Заявленное = сделанное (своя мера)

- «шаг … безфлаговый W» — команда реестра побайтово равна `W` строки 36 блоба (`od -c` поля 4:
  `…red_pustoj_produkt_159.sh\n`, без флагов и хвостовых пробелов) и строке HANDOFF.md:52.
- «вес 20 — по строке задания оркестратора» — подтверждено: HANDOFF.md:52 несёт
  `step\tcheck:pustoj-produkt-159-family-selftest\t20\t…`. Контракт 159 вес не замораживает
  (grep `вес|check:pustoj` по блобу: совпадений-весов нет). «г2 гварда 114: расхождение ≤ 3×» —
  подтверждено против трёх наблюдений: 20/18 (мой корпус), 20/19 (корпус автора), 24/20 (раннер).
- «51 клетка» — подтверждено: 51 в каждом из моих 8 прогонов и на раннере PR #614.
- «8 наблюдений 18, 18, 19, 19, 19, 19, 19, 19 с; медиана 19 с, ceil(медианы) = 19 с» — арифметика
  верна (`median_ceil` = (19+19+1)//2 = 19). Сам корпус автора в дереве не сохранён, его не
  воспроизводил; мой корпус дал `18,17,18,18,18,18,18,18` и вес 18. Сошёлся порядок, а не
  наблюдения.
- «lane l6» — подтверждено (§1).
- «ci.yml перегенерирован gen_ci_steps.sh --write» — подтверждено побайтовой регенерацией (§2).
- Строка замера `20	8	0` — не то, что пишет `measure_ci_weights.sh` ни на корпусе автора (19),
  ни на моём (18), см. С-1.

## Находки

- [ ] **С-1 (совет, не блок; класс — точность записи замера 114).** Фрагмент:
  `registry/ci-zamery.tsv:97` `check:pustoj-produkt-159-family-selftest	20	8	0`. По грамматике 114
  второе поле — `ceil(медиана)` наблюдений (`scripts/measure_ci_weights.sh`, «Правило веса»).
  Заявленный корпус автора даёт 19, мой — 18 (строку `18	8	0` записал сам инструмент), а записан
  вес реестра 20: строка с n=8 выдаёт вес задания за замер. Комментарий реестра при этом честен
  («ceil(медианы) = 19 с; вес 20 — по строке задания»). Почему не блок: тот же приём уже принят
  советом С-1 вердикта `contracts-166-ci-v2.md` (строка 166 `10	8	0`), г2 постоянного гварда
  зелёный, и честная форма `…	19	8	0` проходит те же строки приёмки (мой прогон: rc 0, 98 ключей);
  отказ дала бы только `--migrate` (точное равенство), который к этой правке не применяется.
  Конвенция «замер — вывод инструмента или вес реестра» — вопрос оркестратора и владельца; в 167
  оркестратор уже записал вывод инструмента (`6	8	0`).
- [ ] **О-1 (наблюдение по ленду, не дефект OBJECT; класс — применимость accept).** OBJECT
  ответвлён от a8017112a, а локальный main основного репо = 0f3660d6 (`land: wip/167/orchestrator`,
  ещё не на origin: origin/main = 71c676a35). Пробное слияние `git merge --no-ff 9a8ef29eb` на
  0f3660d6 в мутационном клоне: `CONFLICT (content)` в `registry/ci-steps.tsv`,
  `registry/ci-zamery.tsv` и `.github/workflows/ci.yml` (обе стороны дописали хвост реестра и
  переразложили JOBS); слияние снято `git merge --abort`. GitHub показывает MERGEABLE только
  потому, что 167 CI ещё не на origin/main. Значит, ленд 159 после 167 даёт новое дерево:
  разрешение реестров плюс `gen_ci_steps.sh --write`. Accept этого вердикта к нему не переходит
  сам; несемантичность разрешения (две чужие строки рядом, JOBS = вывод генератора, 93 ключа)
  оркестратор обязан доказать на итоговом дереве, иначе предъявить его судье заново.
- Атрибуция глобального красного `check_ci_weights`. Ключи без замера —
  `check:erstinformation-118-family-selftest` и `check:sverka-maketa-123-family-selftest`;
  `git log -S` по `registry/ci-zamery.tsv` для обоих пуст (строк замера не было ни в одной
  ревизии). Отказ одинаков на базе, на OBJECT и на main 0f3660d6. К ключу 159 отказ не относится:
  с временно досыпанными чужими строками OBJECT зелёный (98 ключей). Гвард к CI не подключён:
  `check_ci_weights` не найден ни в `package.json`, ни в `registry/ci-steps.tsv`, ни в
  `.github/workflows/`, ни в `.githooks/`. Чужие строки не правил.
- Место для находок: роль велит класть их в `.review/YYYY-MM-DD-NN.md`, но задание этого вызова
  разрешает запись только в `verdicts/review/`, поэтому чекбоксы С-1 и О-1 записаны здесь.

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| step-строка 159 + комментарий в `ci-steps.tsv` | строка 52 блоба «CI гоняет безфлаговый W»; ПРОВОДКА guard (038 г3); §Незаполненные «подключение CI-шага … `check_provodka` rc 0» | нового нет, строка реестра явная | 3 (реестр, замер, ci.yml через генератор), как у каждой проводки; дифф число не увеличил | новых флагов и env нет | lane l6 PR #614; `check_provodka` (без строки rc 1, §4); дубля нет | ESSENTIAL |
| строка `ci-zamery.tsv` | ПЕРЕСЕЧЕНИЕ 114 «только замер новой строки 159»; г1 покрытия 114 | явная строка TSV | то же | — | `check_ci_weights` г1/г2 (мутанты §4) | ESSENTIAL (значение — совет С-1) |
| перегенерированный JOBS в `ci.yml` | 083 (генерация из реестра) | нет, детерминирован | — | — | `gen_ci_steps --check` | ESSENTIAL |

Новых скриптов, функций, флагов, читаемых env, файлов и каталогов состояния дифф не вводит.

## Прочее

- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` и
  `docs/CODING-STANDARDS.md` (grep `ARCHITECTURE|CODING-STANDARDS|sourceCanon` по `AGENTS.md` —
  0 совпадений). Сверять не с чем, к этому диффу строка не применима.
- Режим проекта 996 (sourceCanon) и мобильный экран к диффу не применимы.
- Замер раннера 24 с против локальных 17–19 с: вес 20 ниже наблюдения CI, но в пределах г2 (24 ≤ 60).
- Наблюдение вне 159 (повтор с 167). `scripts/models_actual.sh --tsv --bind --all` завершился rc 2:
  `NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: Arbiter079Б1`; строки до неё напечатаны,
  моя строка трассы среди них есть.
- Чужие lanes и батареи, которые генератор переразложил, в этом вызове не гонял (задание scoped).
  На PR #614 все они SUCCESS.
