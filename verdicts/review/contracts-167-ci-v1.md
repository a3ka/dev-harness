accept
СУД: repo=dev-harness; предмет=167; фаза=проводка CI (шаг 5, после реализации); роль=reviewer; вызов=1 (scoped: только зона CI-проводки 167); сессия=Review167CiWeight; OBJECT=8f2884b0c3500c8141a3f18a39fa7da3fdc5a70c
OBJECT=8f2884b0c3500c8141a3f18a39fa7da3fdc5a70c
Контракт: frozen/contracts/167/2 (тег → коммит 587b04f7; блоб контракта 795c9fb5 тот же в OBJECT). Кандидат: wip/167/orchestrator = origin/wip/167/orchestrator = OBJECT, PR #612, `gh pr view 612 --json headRefOid` = OBJECT, mergeable=MERGEABLE. `git log c0c6bf59d..OBJECT` — 2 коммита (415c156f9 «проводка CI … вес 0», 8f2884b0c «вес 0 → 6»), оба автора `orchestrator <orchestrator@dev-harness.local>`; база c0c6bf59d — предок main a8017112a.
--sud: reviewer <трасса> Review167CiWeight; строка трассы (`scripts/models_actual.sh --tsv --bind --all`, фильтр по полю 4 = Review167CiWeight): `reviewer	anthropic/claude-opus-5-5	allowed	Review167CiWeight	8f2884b0c3500c8141a3f18a39fa7da3fdc5a70c`; `scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/r167ci-sud.tsv --object 8f2884b0c3500c8141a3f18a39fa7da3fdc5a70c --session Review167CiWeight --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 167, проводка CI v1

## Итог

Блокирующих находок нет. Шаг `check:obryv-167-family-selftest` добавлен одной строкой реестра с
командой `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo && bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --stabs && bash -n scripts/zamok_predmeta.sh`.
Вес 6 и строка замера `6	8	0` воспроизведены моими восемью каноничными прогонами через
`measure_ci_weights.sh --logs`: получилась побайтово та же строка. Шаг стоит в lane l7. Блок JOBS
в ci.yml побайтово равен выводу генератора. На PR #612 шаг реально исполнился и дал `замер: … 6`.
Guard-канал ПРОВОДКИ красный без шага и зелёный на OBJECT. Если сломать дверь или хук, шаг CI
краснеет (анти-плацебо). Глобальный красный `check_ci_weights` был и до 167: на базе и на main
отказ тот же, по ключам 118 и 123. Найдено два совета (С-1, С-2), ниже.

Accept относится только к блобам OBJECT 8f2884b0. Новая редакция кандидата его не наследует.

Все прогоны шли в одноразовом клоне `/tmp/dev-harness-verify/r167ci` (клон основного репо,
push-url=DISABLED, HEAD = OBJECT). Основной worktree не менялся. Этот файл закоммичен в ветке
клона от main a8017112 под именем reviewer и перенесён в main основного репо fast-forward. Push не
делался.

## 1. Область правки

- `git diff --name-only c0c6bf59d OBJECT` → `.github/workflows/ci.yml`, `registry/ci-steps.tsv`,
  `registry/ci-zamery.tsv`. Строка зоны замороженного блоба, строка 36:
  `ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml`.
  В зоне 3 пути из 3. Автор обоих коммитов — orchestrator.
- ПЕРЕСЕЧЕНИЕ «только строка 167» (ci-steps): `git diff -U0` → `@@ -292,0 +293,2 @@`. Добавлены
  ровно 2 строки: комментарий `# КОНТРАКТ 167: …` и `step	check:obryv-167-family-selftest	6	…`.
  Чужих строк дифф не трогает.
- ПЕРЕСЕЧЕНИЕ «только замер 167» (ci-zamery): `@@ -96,0 +97 @@`, добавлена одна строка
  `check:obryv-167-family-selftest	6	8	0`.
- ПЕРЕСЕЧЕНИЕ «только шаг 167» (ci.yml): изменились 6 строк `keys:`, потому что генератор (LPT)
  переразложил ключи. Своя мера (python, разбор блока GENERATED): у базы 91 ключ, у OBJECT 92,
  дублей 0/0. Добавлен ровно `['check:obryv-167-family-selftest']`, удалений `[]`. Все 92
  step-ключа реестра есть в lanes. Ключ 167 стоит в lane `l7`.
- Баланс из сообщения коммита «756 ≤ ceil(2906/7)+756». Своя мера (сумма весов реестра по lanes):
  `l1 756, l2 359, l3 359, l4 358, l5 358, l6 358, l7 358`, всего 2906, максимум 756.
  ceil(2906/7) = 416, 756 ≤ 1172. Сходится.

## 2. Сырой вывод — команды и rc (клон, HEAD = OBJECT, если не сказано иное)

| Команда | rc | Вывод (суть) |
|---|---|---|
| `reslop t -- bash scripts/gen_ci_steps.sh --check` | 0 | `exit: 0` |
| ci.yml базы c0c6bf59d при реестре OBJECT: `gen_ci_steps.sh --check` | 1 | `gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра` |
| затем `gen_ci_steps.sh --write`; `git diff --stat HEAD -- .github/workflows/ci.yml` | 0 | diff пуст: сгенерированный файл побайтово равен ci.yml OBJECT |
| `bash scripts/verify_ci_parity.sh` | 0 | `workflow-команд: 19 · скриптов в приёмке: 86 · объявленных исключений: 28 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0` |
| `reslop t -- bash scripts/check_provodka.sh . contracts/167-…md` | 0 | `exit: 0` |
| `bash scripts/run_ci_lane.sh check:obryv-167-family-selftest` ×8 (корпус) | 0 ×8 | в каждом прогоне 50 строк: 30 `… ok`, 16 `STAB … caught`, 0 `STAB_ZHIV`, 0 `KRASNO`; замеры `6,6,8,6,6,6,6,8` |
| `bash scripts/measure_ci_weights.sh --root <корень с единственной step-строкой 167 OBJECT> --logs <корпус 8 логов> --out /tmp/…/r167ci-zamer.tsv` | 0 | `ok: замеры записаны: 1 ключей, окно 0`; строка `check:obryv-167-family-selftest	6	8	0` побайтово равна строке OBJECT |
| `bash scripts/check_ci_weights.sh` — OBJECT / база c0c6bf59d / 415c156f9 / main a8017112a | 1 / 1 / 1 / 1 | на всех четырёх деревьях одно и то же: `ОТКАЗ: нет замера: check:erstinformation-118-family-selftest check:sverka-maketa-123-family-selftest` |
| `bash scripts/check_sud_model.sh --verdict reviewer …` | 0 | см. строку `--sud` |

Почему 8 прогонов идут через `--root` с одной строкой: при полном корне `measure_ci_weights --logs`
отвечает rc 2 `ОТКАЗ: мало данных: check:approval (0 < 5); …`. Корпус несёт только ключ 167,
а мера требует ≥5 наблюдений каждого ключа реестра. Медиана моего корпуса — (6+6+1)//2 = 6
(`median_ceil`). Корпус автора `5,5,5,5,6,6,6,6` даёт (5+6+1)//2 = 6, то есть тот же вес. Сам
корпус автора в дереве не сохранён, его не воспроизводил. Сошёлся вес, а не наблюдения.

Лог CI PR #612: run 42514310502 (event pull_request, headSha = OBJECT, conclusion success), job l7
128833925485, `gh api repos/a3ka/dev-harness/actions/jobs/128833925485/logs`. В логе есть:
`HEAD is now at 8f2884b0`; `Run bash scripts/run_ci_lane.sh … check:precision-battery check:obryv-167-family-selftest check:measure-probe`;
`+ bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo && bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --stabs && bash -n scripts/zamok_predmeta.sh`,
что побайтово равно команде реестра. Дальше идут 9 `CASE … ok`, `CHECKED 9 CASES; FAILURES 0`,
6 `MERGE … ok` (--repo); снова 9 CASE и 6 MERGE ok плюс 16 строк `STAB … caught` (--stabs);
`STAB_ZHIV` нет; в конце `замер: check:obryv-167-family-selftest 6`. По
`gh pr view 612 --json statusCheckRollup` все 17 проверок — SUCCESS (klass, legkij, obshchij,
ap1–ap5, l1–l7, tyazhelyj-itog), кроме `vorota`, у которой SKIPPED.

## 3. Проверки не переписаны

Дифф кандидата не содержит ни одного файла `fixtures/`, `scripts/`, `contracts/`, `roles/`,
`decisions/` или `AGENTS.md`: `git diff --name-only c0c6bf59d OBJECT -- …` пуст. Своя мера:
`git diff --stat frozen/contracts/167/2^{commit} OBJECT -- contracts/167-…md fixtures/workshop_project/obryv_167/`
пуст. `git diff --stat 4deeb63f OBJECT -- fixtures/workshop_project/obryv_167/ scripts/zamok_predmeta.sh .githooks/pre-push roles/orchestrator.md`
тоже пуст, то есть в CI идёт ровно та реализация, которую принял вердикт `contracts-167-impl-v3.md`.

## 4. Красное предъявлено (своими прогонами)

| Барьер | Красное | Зелёное |
|---|---|---|
| ПРОВОДКА guard `scripts/zamok_predmeta.sh` (038 г3) | база c0c6bf59d: `проводка: guard не подключён: scripts/zamok_predmeta.sh не вызывается в .githooks/ или .github/workflows/`, rc 1. Мутант OBJECT без `&& bash -n scripts/zamok_predmeta.sh` (реестр + `--write`): тот же отказ, rc 1. Это подтверждает фразу комментария «без этой строки check_provodka краснеет» | OBJECT rc 0 |
| генератор JOBS (083) | ci.yml базы при реестре OBJECT: дрейф, rc 1 (§2) | `--write` → байты = OBJECT; `--check` rc 0 |
| вес 114 ключа 167 (OBJECT плюс две временные чужие строки замера 118/123 с весами реестра) | замер 167 = 1: `ОТКАЗ: вес не по замеру: … (реестр 6, замер 1)`, rc 1. Реестр 167 = 0, то есть вес первого коммита 415c156f9 при честном замере 6: `(реестр 0, замер 6)`, rc 1. Реестр 167 = 19: `(реестр 19, замер 6)`, rc 1. Без строки замера 167: `ОТКАЗ: нет замера: check:obryv-167-family-selftest`, rc 1 | строки OBJECT: `ok: веса по замеру: 98 ключей`, rc 0 |
| анти-плацебо шага CI: дверь | мутант `scripts/zamok_predmeta.sh` (`prichina='obryv_bez_verdikta'` → `'verdikt_zakommiten'`): `run_ci_lane.sh check:obryv-167-family-selftest` rc 1, `CHECKED 9 CASES; FAILURES 5` (interrupted, verdict_wrong_author/path/object/session KRASNO) | OBJECT: rc 0 ×8 |
| анти-плацебо шага CI: хук | мутант `.githooks/pre-push` (`merge_main_verdict "$c" "$rref"; mv=$?` → `mv=1`): `run_ci_lane.sh …` rc 1, `MERGE overlap/registry_drop/partial/other_ref KRASNO rc=0 expected=1` | OBJECT: rc 0 ×8 |

Все мутанты сняты через `git checkout HEAD -- …`. После снятия `git status --short` показывает
только `?? .log/`, это сырой лог reslop.

Guard — барьер именно этого предмета, а не любой скрипт дерева. `probe.py:11,193` в режиме
`--repo` гоняет `ROOT/scripts/zamok_predmeta.sh`, а `merge_probe.py:10` гоняет
`ROOT/.githooks/pre-push`. Мутанты выше показывают, что CI-шаг краснеет от поломки каждой из двух
дверей. Звено `bash -n scripts/zamok_predmeta.sh` проверяет только синтаксис. Его роль —
текстовая третья локация для 038 г3, и комментарий реестра называет это честно; барьером служат
`--repo`/`--stabs`. Канал role=roles/orchestrator.md (две строки ПРОВОДКИ) лежит в зоне
implementer и уже судим в impl-v3; `check_provodka` rc 0 на OBJECT.

## 5. Атомарность

Задача одна (CI-проводка 167), коммитов два, оба ссылаются на предмет: 415c156f9 добавляет шаг с
весом 0, 8f2884b0c исправляет вес 0 → 6 и комментарий реестра. Чужих задач в коммитах нет. Второй
коммит исправляет первый внутри той же зоны, это не связка задач.

## 6. Норма не тронута

В диффе нет нормативных документов (AGENTS.md, roles/, contracts/, decisions/), §3.

## 7. Заявленное = сделанное (своя мера)

- «вес 6 — ceil медианы … корпус 8 наблюдений» — мой корпус из 8 прогонов дал вес 6 и строку
  `6	8	0`, побайтово равную OBJECT (§2). CI-наблюдение на раннере — 6.
- «строку записал сам scripts/measure_ci_weights.sh --logs» — тот же инструмент на моём корпусе
  дал ту же строку. Прогон автора не наблюдал.
- «контракт 167 строку CI не замораживает» — подтверждено. Секция §Зоны и проводка
  замороженного блоба (строки 132–145) несёт только ПРЕДПОСЫЛКИ и ПРОВОДКА (2 role, 2 guard).
  Ни строки `step`, ни веса там нет. Значит, прежнее «вес — по замороженной строке» было неверно,
  и снято оно по делу.
- «ключ переехал в lane l7; баланс 756 ≤ ceil(2906/7)+756» — подтверждено (§1).
- «ci.yml перегенерирован gen_ci_steps.sh --write» — подтверждено побайтовой регенерацией (§2).
- «9 клеток CASE + 6 клеток MERGE» — подтверждено: 9 CASE и 6 MERGE в выводе каждого режима.
- «15 стабов — 9 CASE + 6 MERGE» — не сходится ни в одной единице счёта, см. С-1.

## Находки

- [ ] **С-1 (совет, не блок; класс — точность счётного утверждения в комментарии).** Фрагмент:
  `registry/ci-steps.tsv:293` «15 стабов — 9 CASE + 6 MERGE». Своя мера (`probe.py:206-214`,
  `merge_probe.py:133-153`, лог CI #612 job l7). Различных стабов 9 CASE + 3 MERGE (`forbid_all`,
  `allow_all`, `no_ref`), всего 12. Пар стаб×клетка, то есть строк `STAB … caught`, 10 CASE
  (`ignore_all_starts` ловится на двух клетках) + 6 MERGE, всего 16. Число 15 получается только
  сложением разных единиц. Почему не блок: у комментария нет машинного потребителя, команда, вес
  и поведение шага от него не зависят. Честная форма «12 стабов (9 CASE + 3 MERGE), 16 улик
  STAB caught» проходит те же строки приёмки.
- [ ] **С-2 (совет, не блок; класс — воспроизводимость замера).** Корпус логов автора, из
  которого получены «5,5,5,5,6,6,6,6», в дереве не сохранён. Комментарий реестра описывает другой
  набор: float-времена «5.685..5.948 с» из первого коммита. Строку `6	8	0` перепроверить можно
  только новым корпусом, как сделано здесь: вес сошёлся, наблюдения нет (`6,6,8,6,6,6,6,8`).
  Почему не блок: правило 114 судит вес, а вес воспроизводится. Конвенция хранения корпуса
  локальных замеров — вопрос оркестратора и владельца, вне 167.
- Атрибуция глобального красного `check_ci_weights`. Ключи без замера —
  `check:erstinformation-118-family-selftest` (step добавлен abef4ed18, owner, 2026-10-23) и
  `check:sverka-maketa-123-family-selftest` (585403c5a, owner, 2026-10-22). Строк замера у них нет
  ни в одной ревизии (`git log -S` по ci-zamery пуст). Отказ одинаков на базе, на 415c156f9, на
  OBJECT и на main. К ключам 167 отказ не относится: с временно досыпанными чужими строками
  OBJECT зелёный (98 ключей). Гвард к CI не подключён: `check_ci_weights` не найден ни в
  `package.json`, ни в `registry/ci-steps.tsv`, ни в `.github/workflows/ci.yml`, ни в
  `.githooks/`. Чужие строки не правил.
- Место для находок: роль велит класть их в `.review/YYYY-MM-DD-NN.md`, но задание этого вызова
  разрешает запись только в `verdicts/review/`, поэтому чекбоксы С-1 и С-2 записаны здесь.

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| step-строка 167 + комментарий в `ci-steps.tsv` | ПРОВОДКА guard ×2 (038 г3); приёмка `W --repo`/`W --stabs` | нового нет, строка реестра явная | 3 (реестр, замер, ci.yml через генератор), как у каждой проводки; дифф это число не увеличил | новых флагов и env нет | lane l7 PR #612; `check_provodka`; дубля нет | ESSENTIAL |
| звено `bash -n scripts/zamok_predmeta.sh` | 038 г3: guard виден в третьей локации | нет | 0 дополнительных | синтаксис-only, работы почти нет | `check_provodka`: без звена rc 1 (§4). Более простой формы, проходящей г3, нет: имя guard обязано стоять в CI-команде | ESSENTIAL |
| строка `ci-zamery.tsv` `6	8	0` | ПЕРЕСЕЧЕНИЕ 114 «только замер 167»; г1/г2 114 | явная строка TSV | то же | — | `check_ci_weights` г1/г2 (мутанты §4) | ESSENTIAL |
| перегенерированный JOBS в `ci.yml` | 083 (генерация из реестра) | нет, детерминирован | — | — | `gen_ci_steps --check`, `verify_ci_parity` | ESSENTIAL |

Новых скриптов, функций, флагов, читаемых env, файлов и каталогов состояния дифф не вводит.

## Прочее

- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` и
  `docs/CODING-STANDARDS.md` (grep `ARCHITECTURE|CODING-STANDARDS|sourceCanon` по `AGENTS.md`
  совпадений не дал). Сверять не с чем, к этому диффу строка не применима.
- Режим проекта 996 (sourceCanon) и мобильный экран к диффу не применимы.
- Наблюдение вне 167. `scripts/models_actual.sh --tsv --bind --all` завершился rc 2:
  `NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: Arbiter079Б1`. Это чужая сессия с
  кириллицей в id. Строки до неё напечатаны, моя строка трассы среди них есть. Вопрос
  оркестратору: `--all` падает целиком из-за одной чужой сессии.
- Чужие lanes l1–l6 и батареи, которые генератор переразложил, в этом вызове не гонял (задание
  scoped). На PR #612 все они SUCCESS.
