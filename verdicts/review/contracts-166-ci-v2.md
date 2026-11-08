accept
СУД: repo=dev-harness; предмет=166; фаза=проводка CI (шаг 5, после реализации); роль=reviewer; вызов=1 (scoped: только изменённые барьеры CI 166); OBJECT=a0916a76adc834da37681c410264692e883b137c
Контракт: frozen/contracts/166/2 (тег 2fc4f8ac → коммит 8cd1a1cd; блоб контракта bc82672f — тот же в OBJECT). Кандидат: wip/166/orchestrator, PR #607, `gh pr view 607 --json headRefOid` = OBJECT, mergeable=MERGEABLE. Родитель OBJECT 7dc408e2 — предок origin/main da0ba1fd; `git log origin/main..OBJECT` — ровно 1 коммит.
--sud: reviewer <трасса> Review166CiV2; строка трассы (`scripts/models_actual.sh --tsv --bind --all`): `reviewer	anthropic/claude-opus-5-5	allowed	Review166CiV2	a0916a76adc834da37681c410264692e883b137c`; `scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/r166ci-sud.tsv --object a0916a76adc834da37681c410264692e883b137c --session Review166CiV2 --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 166, проводка CI v2

## Итог

Блокирующих находок нет. Шаг `check:make_task-166-family-selftest` добавлен ровно той строкой,
что заморожена в контракте. Он стоит в lane l5 и на PR #607 реально исполнился с выводом батареи
166. Блок JOBS в ci.yml побайтово совпадает с выводом генератора. Guard-канал ПРОВОДКИ
(`scripts/make_task.sh`) на родителе красный, на OBJECT зелёный. Замороженные барьеры
(контракт, `probe.py`, `red_model_choice_166.sh`) не тронуты. Одна находка-совет: С-1, ниже.

Accept относится только к блобам OBJECT a0916a76. Новая редакция кандидата его не наследует.

Все прогоны — в одноразовом ssh-клоне `/tmp/dev-harness-verify/r166ci`
(`git clone ssh://git@github.com/a3ka/dev-harness.git`, push-url=DISABLED, HEAD = OBJECT).
Основной worktree не менялся. Этот файл закоммичен в отдельном worktree клона от origin/main и
перенесён в main fast-forward.

## 1. Область правки

- `git diff --name-only OBJECT~1 OBJECT` → `.github/workflows/ci.yml`, `registry/ci-steps.tsv`,
  `registry/ci-zamery.tsv`. Своя мера: строка зоны из замороженного блоба
  (`git show frozen/contracts/166/2:… | grep '^ЗОНА orchestrator:'`) →
  `ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml`.
  3 из 3 путей в зоне. Автор `orchestrator <orchestrator@dev-harness.local>`.
  Полный `scripts/check_zones.sh` по всему дереву не гонял (задание ограничено изменёнными
  барьерами); зону сверил своей мерой выше.
- ПЕРЕСЕЧЕНИЕ «только строка 166»: в `ci-steps.tsv` +2 строки (комментарий `# КОНТРАКТ 166…`
  и `step	check:make_task-166-family-selftest	10	bash fixtures/workshop_project/model_choice_166/red_model_choice_166.sh`).
  Step-строка побайтово равна замороженной строке контракта §Зоны и проводка.
- ПЕРЕСЕЧЕНИЕ «только замер 166»: в `ci-zamery.tsv` +1 строка `check:make_task-166-family-selftest	10	8	0`.
- ПЕРЕСЕЧЕНИЕ «только шаг 166» в ci.yml: изменены 6 строк `keys:` в матрице lanes, потому что
  генератор переразложил ключи по весам. Своя мера: в клоне вернул ci.yml родителя и выполнил
  `bash scripts/gen_ci_steps.sh --write` (rc 0); `git diff --stat a0916a76 -- .github/workflows/ci.yml`
  дал пустой вывод, то есть файл побайтово равен OBJECT. Ключи lanes, своя мера
  (`grep keys: | tr ' ' '\n' | sort`): родитель 137 ключей, OBJECT 138, дублей 0/0. `diff`
  множеств даёт ровно одну строку `> check:make_task-166-family-selftest`. Все 91 step-ключ реестра
  есть в lanes (остальные 47 ключей lanes — matrix-ключи antiplacebo).

## 2. Сырой вывод — команды и rc (клон, HEAD = OBJECT)

| Команда | rc | Вывод (суть) |
|---|---|---|
| `reslop t -- bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `reslop t -- bash scripts/verify_ci_parity.sh` | 0 | `ok: true passed: 29 failed: 0`; `matrix-ключей: 47 · расхождений: 0` |
| `reslop t -- bash scripts/check_provodka.sh . contracts/166-snyatie-ogranichitelya-modelej.md` | 0 | — |
| `reslop t -- bash scripts/run_ci_lane.sh check:make_task-166-family-selftest` | 0 | 21 строка `OK`, 3 `stub …: CAUGHT`, `замер: check:make_task-166-family-selftest 5` |
| `bash fixtures/workshop_project/model_choice_166/red_model_choice_166.sh` ×8 (bash `time`) | 0 ×8 | real 4.570/4.572/4.542/4.543/4.544/4.564/4.506/4.568 с; 21 `OK` в каждом прогоне |
| `bash scripts/check_ci_weights.sh` | 1 | `ОТКАЗ: нет замера: check:erstinformation-118-family-selftest check:sverka-maketa-123-family-selftest`. На родителе 7dc408e2 тот же отказ (rc 1); ключа 166 в списке нет; гвард не подключён к CI (`grep check_ci_weights package.json registry/ci-steps.tsv .github/workflows/ci.yml` — пусто). К 166 не относится. |
| то же после временной досыпки двух чужих строк (коммит в клоне, затем `reset --hard OBJECT`) | 0 | `ok: веса по замеру: 97 ключей` |
| `bash scripts/check_sud_model.sh --verdict reviewer …` (основной репо, только чтение) | 0 | см. строку `--sud` |

Лог CI PR #607 (run 42493506617, job l5 128770760843, `gh api repos/a3ka/dev-harness/actions/jobs/128770760843/logs`):
`HEAD is now at a0916a76`; `Run bash scripts/run_ci_lane.sh … check:make_task-166-family-selftest …`;
21 строка `166 …: OK`, `166 stub missing_author: CAUGHT`, `166 stub forged_trace: CAUGHT`,
`166 stub reviewer_blocked: CAUGHT`, `замер: check:make_task-166-family-selftest 6`. Все 17 проверок
PR (`gh pr view 607 --json statusCheckRollup`) — SUCCESS, кроме `vorota`, у которой SKIPPED.

## 3. Проверки не переписаны

В диффе нет ни одного файла `fixtures/`, `scripts/` или `contracts/`. Своя мера:
`git diff --stat frozen/contracts/166/2^{commit} OBJECT -- contracts/166-snyatie-ogranichitelya-modelej.md fixtures/workshop_project/model_choice_166/`
дал пустой вывод. Блоб контракта bc82672f совпадает в теге и в OBJECT. Барьеры, которые идут в CI,
те же, что заморожены.

## 4. Красное предъявлено (своими прогонами)

| Барьер | Красное | Зелёное |
|---|---|---|
| ПРОВОДКА guard `scripts/make_task.sh` | дерево родителя 7dc408e2: `проводка: guard не подключён: scripts/make_task.sh не вызывается в .githooks/ или .github/workflows/`, rc 1 | OBJECT rc 0. Каждый носитель слова `make_task` по отдельности тоже даёт rc 0: только ci.yml OBJECT — rc 0, только ci-steps.tsv OBJECT — rc 0 |
| генератор JOBS | ci.yml родителя при реестре OBJECT: `gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра`, rc 1 | после `--write`: `--check` rc 0, байты = OBJECT |
| вес 114 ключа 166 | мутант строки замера `…166…	3	8	0`: `ОТКАЗ: вес не по замеру: check:make_task-166-family-selftest (реестр 10, замер 3)`, rc 1 | строка OBJECT `10	8	0`: rc 0 (97 ключей) |

Guard — это сам механизм предмета: `probe.py:111` в режиме `--repo` вызывает
`<root>/scripts/make_task.sh`, а шаг CI исполняет `--repo`, `--model` и `--stabs` одним прогоном.
Барьер принадлежит предмету 166, а не любому скрипту дерева. Ключ содержит слово `make_task` по
прямому требованию замороженной строки контракта («Ключ `make_task` стоит в некомментарийной строке
для guard-канала 038»).

## 5. Атомарность

Один коммит a0916a76. Ссылка на предмет «orchestrator 166: проводка CI…». Других задач в коммите
нет.

## 6. Норма не тронута

Нормативные документы (AGENTS.md, roles/, contracts/, decisions/) в диффе отсутствуют.

## 7. Заявленное = сделанное (своя мера)

- «шаг … (вес 10)» — равен реестру и замороженной строке.
- «8 наблюдений 4..5 с, медиана 5 с». Своя мера: 8 прогонов bash `time` дали 4.506–4.572 с,
  медиана 4.55 с. Целочисленный таймер lane дал 5 с локально и 6 с на раннере CI. С заявлением
  согласуется.
- «ci.yml перегенерирован gen_ci_steps.sh --write» — подтверждено побайтовой регенерацией (§1).
- PR body «check_provodka red→green; runner и gen_ci_steps --check зелёные» — подтверждено (§4, §2).

## Находки

- **С-1 (совет, не блок; класс — точность записи замера 114).** Фрагмент:
  `registry/ci-zamery.tsv:96` `check:make_task-166-family-selftest	10	8	0`. По грамматике 114
  второе поле — это `ceil(медиана)` наблюдений (`scripts/measure_ci_weights.sh:19,203`). У восьми
  заявленных наблюдений 4..5 с это 5, а записано 10, то есть вес реестра. Строка с n=8 выдаёт вес
  за замер. Почему не блок: так же записаны все 17 строк с окном 0 (135…161, в том числе коммиты
  owner). Честная форма `…	5	8	0` проходит те же строки приёмки: `check_ci_weights` г2,
  max(10,5)=10 ≤ 3·5. Предмет 166 этого не меняет. Решение о конвенции локальных строк замера —
  за оркестратором и владельцем, вне 166.
- Место для находок: роль велит класть их в `.review/YYYY-MM-DD-NN.md`. Задание этого вызова
  разрешает запись только в `verdicts/review/`, поэтому совет С-1 записан здесь.

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| step-строка 166 + комментарий в `ci-steps.tsv` | §Зоны и проводка: замороженная CI-строка; ПРОВОДКА guard | нет нового; строка реестра явная | 3 (реестр, замер, ci.yml через генератор): столько же, сколько у каждой проводки, дифф число не увеличил | интерфейс не вырос: ни новых флагов, ни env | строка приёмки «CI шаг 166 запускает…»; lane l5; дубля нет | ESSENTIAL |
| строка `ci-zamery.tsv` | ПЕРЕСЕЧЕНИЕ 114 «только замер 166»; г1 покрытия 114 | явная строка TSV | то же | — | `check_ci_weights` г1/г2 | ESSENTIAL (значение — совет С-1) |
| перегенерированный JOBS в `ci.yml` | 083 И-1 (генерация из реестра) | нет; детерминирован | — | — | `gen_ci_steps --check`, `verify_ci_parity` | ESSENTIAL |

Новых скриптов, функций, флагов, читаемых env и каталогов состояния дифф не вводит.

## Прочее

- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` и
  `docs/CODING-STANDARDS.md` (`grep ARCHITECTURE|CODING-STANDARDS AGENTS.md` — нет совпадений).
  Сверять не с чем, к этому диффу не применимо.
- Режим проекта 996, sourceCanon и мобильный экран к диффу не применимы.
- Батареи 095 и 136 (их шаги context-pack-095 в l3, sessii-136 в l2) в этом вызове не гонял, по
  заданию «только изменённые барьеры». Их lanes на PR #607 — SUCCESS.
