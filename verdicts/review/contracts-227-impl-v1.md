FAIL
OBJECT=ce363c746bc1c5f95eac16db1e53978e474942e3
СУД: репо=dev-harness; предмет=227; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev227; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Impl227 — implementer (MiniMax), Architect227/227b; критик: archive/227/critic-v2-accept-f3dbb5c28c (frozen/contracts/227/1 = d60966ce6); класс риска обычный (read-only отчёт), адверсарий не требуется

# Reviewer 227 — Ш-5ф: отчёт об остатке зашивок проектов в ядре, реализация, вызов 1

**БЛОКИРУЕТ: Б-1** — К-08, живой мутант production: снятая literal-магия pathspec. Батарея (зона architect) его не ловит.

**СОВЕТ: 1** — С-1, orchestrator: CI-селфтест без `--sintaksis`.

Находки лежат в `.review/2026-11-26-2271.md` (`status: ready`).

Честная production сама по себе корректна. Дефектов на конформном входе я не нашёл, все отказы измерения дают rc 2 и не притворяются нулём. FAIL стоит только потому, что задание прямо говорит: «живой мутант = блок (К-08)». Пустое место — в батарее. Без него следующая правка `report_zashivki.sh` может незаметно перейти на glob-пути, и при метасимволах в include/exclude получится ложный ноль или лишние строки.

Перепроверил всё: область правки, сырой вывод, не переписаны ли проверки под код.

## Область правки

`git diff --name-status 283bbeae4 ce363c746`:

```
M	.github/workflows/ci.yml
A	config/zashivki.json
M	registry/ci-steps.tsv
M	registry/ci-zamery.tsv
A	scripts/report_zashivki.sh
```

`git log --format='%h %an <%ae> %s' 283bbeae4..HEAD`:

```
ce363c746 orchestrator <orchestrator@dev-harness.local> orchestrator: 227 CI report-step report:zashivki-227 + selftest check:zashivki-otchet-227-family-selftest
56401930c implementer <implementer@dev-harness.local> 227: отчёт об остатке зашивок — scripts/report_zashivki.sh + config/zashivki.json
```

- Implementer `56401930c` (committer orchestrator, перенос на i2-базу) меняет ровно `config/zashivki.json` и `scripts/report_zashivki.sh`, +168 строк. `git diff --stat 140dea188 56401930c -- <оба файла>` пуст: это побайтно тот же Impl227, что `archive/227/implementer-140dea1885`.
- Orchestrator `ce363c746` меняет ровно тройку CI: `ci.yml` 14 строк, `ci-steps.tsv` +2, `ci-zamery.tsv` +2.
- Обе зоны совпадают с `ЗОНА implementer` и `ЗОНА orchestrator` контракта. Атомарность соблюдена: две задачи — два коммита, оба ссылаются на 227.
- `ci.yml`: `git diff -U0` даёт 7 хунков, строки 272–284. Все они внутри `# BEGIN/END GENERATED CI JOBS (083)` (строки 270/285). Ключей в `keys:` было 130, стало 132; добавлены оба новых, ни один не потерян. `gen_ci_steps.sh --check` rc 0.
- Контракт, батарея, роли, AGENTS.md и вердикты не менялись. Заморозка `frozen/contracts/227/1` (= `d60966ce6`, critic accept) — предок HEAD, `merge-base --is-ancestor` rc 0. `git diff --stat d60966ce6 HEAD -- contracts/227-sh5f-zashivki-otchet.md fixtures/workshop_project/zashivki_otchet_227 roles AGENTS.md verdicts` пуст.

## Проверки не переписаны под код

- Батарея заморожена до реализации: `d60966ce6` — предок `56401930c`. После заморозки файлы `fixtures/workshop_project/zashivki_otchet_227/` не менялись (diff пуст). Implementer и orchestrator батарею не трогали.
- Production `config/zashivki.json` побайтно равен канону `model/config/zashivki.json` (`diff` rc 0). Клетка `default-config` сравнивает его с каноном структурно.
- Оракул — литеральные записи в `probe.py:cases()`, они снимаются до субъекта. Ожидание по baseline берётся из конфига мира, а не из вывода субъекта. Сравнение — полный `json.dumps(sort_keys=True)`, плюс отдельно rc, stderr и снимок файлов/index/HEAD (`probe.py` `world_test`).
- Тестовых хуков в production нет: `grep 'environ|getenv|ZASHIVKI_…=|${…:-|TEST|DEBUG|FIXTURE|stab'` по `scripts/report_zashivki.sh` даёт 0 совпадений. Скрипт не читает env и не принимает аргументов (argc≠0 → rc 2).

## Регресс

Всё ниже — в чистом клоне с origin (`git clone ssh://git@github.com/a3ka/dev-harness.git --branch wip/227/orchestrator-i2` → `tmp/c227`, HEAD `ce363c746bc1c5f95eac16db1e53978e474942e3`). `TMPDIR=$PWD/tmp/scratch-rev227`, shellcheck — пин 0.11.0. Команды шли по одной. `W=bash fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh`.

| Команда | rc | Сырой итог |
|---|---|---|
| `W --repo .` | 0 | все 29 клеток GREEN, включая `ci-wiring`, `ci-measurement`, `ci-generator`; `KLETKI 29 KRASNYH 0` (2.3 с) |
| `W --model` | 0 | `KLETKI 29 KRASNYH 0` |
| `W --stabs` | 0 | 29 GREEN контроля, каждая связь `CAUGHT`; `STABY 32 EKVIVALENTY 4 ZHIVYH 0` |
| `W --sintaksis` | 0 | `SINTAKSIS_OK` |
| `W --catalog` | 0 | `KLETKI 29 STABY 32 EKVIVALENTY 4 SVJAZI 40` |
| `python3 -B …/context.py` | 0 | `ДЕКЛАРАЦИИ 65`, 50 ИСТОЧНИК/ЗОНА + ПЕРЕСЕЧЕНИЯ |
| `bash scripts/report_zashivki.sh` | 0 | stdout 14626 байт, один JSON: `lines=89 files=20 matches=89 baseline={'lines': 89, 'files': 20, 'commit': '6565542c1'}`, stderr `''` |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash scripts/check_provodka.sh . contracts/227-sh5f-zashivki-otchet.md` | 0 | — |
| `bash scripts/check_sdacha.sh . contracts/227-sh5f-zashivki-otchet.md --run` | 0 | `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)`, 113.5 с |
| `bash scripts/pre_critic.sh contracts/227-sh5f-zashivki-otchet.md` (последовательно) | 0 | пять `ok`, `сдаточный лист`, `КРИТИК: дверь зелёная`, 105.9 с |
| `bash scripts/validate_std.sh json …/config.schema.json config/zashivki.json` | 0 | production-конфиг соответствует схеме семьи |
| `bash scripts/validate_std.sh bash scripts/report_zashivki.sh` и `bash -n` | 0 / 0 | — |
| `W --repo <worktree 283bbeae4>` (красное до 227) | 1 | `SUBJECT_ABSENT: scripts/report_zashivki.sh` |
| `W --repo <worktree 56401930c>` (production без CI) | 1 | `ci-wiring RED CI_REPORT_STEP_ABSENT_OR_NONCANON`, `ci-measurement RED CI_MEASUREMENT_ABSENT_OR_WEIGHT_DRIFT`, `KLETKI 29 KRASNYH 2` |

Наблюдение среды, не находка: первый прогон `pre_critic` шёл параллельно с моим прогоном мутантов в соседнем клоне и дал rc 1 (`строка 15: фактический rc=2 ≠ заявленного 0: … --sintaksis`). Последовательный повтор без нагрузки дал rc 0, `check_sdacha --run` отдельно — тоже rc 0. [INFERENCE] Вероятная причина — бюджет времени двери под нагрузкой CPU. Засчитан последовательный прогон.

Счёт сверил своей мерой (другая команда, не `--catalog`):

- Независимый `git grep` литералами задания на OBJECT: `git grep -n -I -E -e '<pattern>' -- scripts .omp/extensions .githooks ':(exclude)scripts/proxy' | wc -l` = **89**, `git grep -l … | wc -l` = **20**. Совпадает с отчётом и с базой.
- Отчёт сам себя не считает. В 20 путях нет ни `scripts/report_zashivki.sh`, ни `config/zashivki.json`: конфиг лежит вне include, а в скрипте нет литералов (см. ниже). Остаток от новых файлов не вырос.
- `find stabs -name 's*' -type d | wc -l` = 32, `-name 'e*'` = 4. Связи по каталогу: 32 красных стаба + s01 и s28 по 2 клетки = 34 красных связи; e01, e02 по 1 и e03, e04 по 2 = 6 зелёных; итого **40**. Клеток 25 сценариев `cases()` + 4 META = **29**. `source.json` содержит ключи `files` и `links`.

## Отказ ≠ ложный ноль (К-08 вызова 1), руками

Production `scripts/report_zashivki.sh` на OBJECT в одноразовом клоне `tmp/m227`. Своя обвязка `tmp/scratch-rev227/{run.py,cfgvariants.py}` отдельно снимает rc, длину stdout и stderr.

```
(a) PATH без git (только bash/python3/dirname):
rc=2 stdout_bytes=0 stderr="NOT_IMPLEMENTED: ZASHIVKI_REPORT: git недоступен: [Errno 2] No such file or directory: 'git'\n"
(б) git в PATH c rc 128:
rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: git grep rc=128: boom\n'
(в) config-is-directory  rc=2 stdout_bytes=0 stderr="NOT_IMPLEMENTED: ZASHIVKI_REPORT: конфиг не прочитан: [Errno 21] Is a directory: …"
    config-absent        rc=2 stdout_bytes=0 stderr="NOT_IMPLEMENTED: ZASHIVKI_REPORT: конфиг не прочитан: [Errno 2] …"
    broken-json          rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: конфиг не разобран: Expecting value: line 1 column 12 (char 11)\n'
    json-array           rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: конфиг не объект JSON: config/zashivki.json\n'
    non-utf8             rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: конфиг не разобран: …'
    missing-pattern      rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: в конфиге нет непустого образца pattern\n'
    missing-include      rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: в конфиге нет списка путей include\n'
    missing-exclude      rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: в конфиге нет списка путей exclude\n'
    missing-baseline     rc=2 stdout_bytes=0 stderr='NOT_IMPLEMENTED: ZASHIVKI_REPORT: в конфиге нет объекта baseline\n'
    include-empty        rc=2 stdout_bytes=0 …нет списка путей include
    include-dotdot       rc=2 stdout_bytes=0 …содержит путь вне корня: '../x'
    include-abs          rc=2 stdout_bytes=0 …содержит не-относительный путь: '/etc'
    pattern-bad-ERE      rc=2 stdout_bytes=0 stderr="NOT_IMPLEMENTED: ZASHIVKI_REPORT: git grep rc=128: fatal: -e option, '(unclosed': Unmatched ( or \\(\n"
(г) удалены 3 строки проверки rc git grep (`if result.returncode not in (0, 1):` / `detail = …` / `refuse(…)`), мутант R8:
    W --repo → rc 1, KLETKI 29 KRASNYH 1: git-failure RED MEASUREMENT_ERROR_RC rc=0,MEASUREMENT_ERROR_DIAGNOSIS,MEASUREMENT_ERROR_REPORT b'{"lines": 0, "files": 0, "matches": [], …}\n'
Честный ноль при РАБОТАЮЩЕМ git:
    honest-empty-residue rc=0 stdout_bytes=103 JSON lines=0 files=0 matches=0 baseline={89,20,6565542c1} stderr=''
    include-missing-dir  rc=0 stdout_bytes=103 JSON lines=0 files=0 matches=0 stderr=''
Применение значений (инв. 5):
    exclude-empty    rc=0 lines=89 files=20 (в scripts/proxy совпадений нет: git grep -c … -- scripts/proxy rc 1)
    baseline-changed rc=0 lines=89 files=20 baseline={'lines': 1, 'files': 1, 'commit': 'x'}
restored: clean
```

Каждый отказ даёт rc 2, stderr начинается с `NOT_IMPLEMENTED:`, stdout пуст. Ложного отчёта нет ни в одном случае. Честный пустой остаток даёт rc 0 и нулевой JSON.

## Не дверь

- `registry/ci-steps.tsv`: строка `step	report:zashivki-227	10	bash scripts/report_zashivki.sh` ровно одна (`grep -c` = 1). Команда буквально канон инв. 6: без `|| true`, без обёртки, без порога.
- `registry/ci-zamery.tsv`: `report:zashivki-227	10	2	0`, вес 10 совпадает со steps.
- В production нет `! git grep`, enforce-флага, сравнения с baseline и выхода по остатку. Мой мутант R11 (`exit 1` сверх базы) ловит `above-baseline`; стаб s24/s25 тоже.
- rc 2 при отказе измерения допустим. Инв. 4 его прямо предписывает: «Это операционная ошибка, не отказ по наличию зашивок», а «НЕ ЗАЩИЩАЕТ» последним пунктом требует «rc 2/NOT_IMPLEMENTED … ловец — оператор/CI, не молчаливый ноль». Красный CI-шаг при сломанном Git или конфиге — именно та видимость, ради которой предмет существует. Блокировки по остатку это не создаёт: на любом конформном остатке rc 0, что проверено клетками `nonempty`/`empty`/`above-baseline`/`above-file-baseline` и моими прогонами.

## R-0102

- `git grep -c -E 'Complior|a3ka|\.harness|scripts/proxy' -- scripts/report_zashivki.sh` → rc 1, 0 совпадений. В скрипте литерален только путь `config/zashivki.json` (`CONFIG`, :49), а инв. 1 его как раз предписывает.
- pattern, include, exclude и baseline приходят из `config/zashivki.json`. Его соответствие `config.schema.json` подтвердил `validate_std json` (rc 0).
- В CI-команде литералов нет.

## Свои мутанты и дефекты честной production

Мутанты сделаны НЕ из `stabs.tsv`/`MUTATIONS`. Каждый — одна правка копии production в `tmp/m227` (`tmp/scratch-rev227/mutate.py`, якорь ровно один, `bash -n` rc 0). Батарея неизменённая, `W --repo .` гонялась по одному, после каждого мутанта копия восстанавливалась (`restored: clean`).

| Мутант | Правка | `W --repo` | Красные клетки |
|---|---|---|---|
| R1 pattern литералом | `pattern = 'Complior-…'` | rc 1, KRASNYH 20 | самоподсчёт литерала + `changed-pattern` |
| R2 pattern скрыт hex | `bytes.fromhex(…)` без литерала | rc 1, KRASNYH 1 | `changed-pattern` |
| R3 include/exclude зашиты | склейкой строк, без литерала | rc 1, KRASNYH 5 | `changed-include/-exclude`, `no-excludes`, `literal-paths/-excludes` |
| R4 `-I` убран | | rc 1, KRASNYH 1 | `binary` (rc 2: вывод «Binary file …» не разобран) |
| R5 lines = число файлов | `'lines': len({paths})` | rc 1, KRASNYH 3 | `nonempty`, `same-content`, `above-baseline` |
| R6 порядок по тексту | `matches.sort(key=text)` | rc 1, KRASNYH 1 | `nonempty` |
| R7 baseline перезаписан | `{**base, 'lines': len(matches)}` | rc 1, KRASNYH 22 | все с baseline |
| R8 нет проверки rc git grep | 3 строки удалены | rc 1, KRASNYH 1 | `git-failure` |
| **R9 literal-магия снята** | `':(top)'`, `':(exclude,top)'` | **rc 0, KRASNYH 0 — ЖИВОЙ** | — → **Б-1** |
| R10 пишет конфиг | `path.write_text(…)` | rc 1, KRASNYH 23 | `SUBJECT_MUTATED_INPUT` |
| R11 exit 1 сверх базы | | rc 1, KRASNYH 1 | `above-baseline` |
| R12 корень = cwd | `Path.cwd()` | rc 0, KRASNYH 0 | эквивалент на публичном CLI (см. ниже) |
| R13 болтовня в stderr | | rc 1, KRASNYH 22 | `STDERR` |

**Б-1 (К-08, инв. 2).** R9 не зависит от значений, и на конформном входе он расходится с честной production. Контракт явно допускает «literal-пути могут содержать … метасимволы». Настоящие Git-миры (`tmp/scratch-rev227/r9demo.py`, честный против R9):

```
include-class     honest rc=0 lines=1 [('other[X]/a.sh', 1)]
include-class     R9     rc=0 lines=1 [('other[X]/a.sh', 1)]
exclude-question  honest rc=0 lines=1 [('scripts/ab.sh', 1)]
exclude-question  R9     rc=0 lines=0 []
include-star      honest rc=0 lines=1 [('ext*/a.sh', 1)]
include-star      R9     rc=0 lines=2 [('ext*/a.sh', 1), ('extras/a.sh', 1)]
```

Exclude `scripts/a?.sh` у R9 даёт ложный ноль, include `ext*` — лишнюю строку. Клетки `literal-paths`/`literal-excludes` (`probe.py:88–91`) построены на `[*]`: этот glob-класс совпадает только с буквальным `*`, так что на соседях `otherX`/`aX.sh` glob и literal неразличимы. В `MUTATIONS` нет стаба «literal → glob». Production (`scripts/report_zashivki.sh:107–108`) честна. Чинит architect в своей зоне; простая форма — в `.review/2026-11-26-2271.md`.

**R12 не контрпример.** Публичный CLI — ровно `bash scripts/report_zashivki.sh`, путь относительный. Поэтому каталог расположения скрипта совпадает с cwd. На этом шве R12 эквивалентен; другие формы вызова контракт не обещает.

Дефектов честной production на конформном входе не нашёл:

- `git grep -z -n -I -E` с `core.quotepath=false` — пути с TAB/LF/`:`/Unicode разбираются по NUL (клетка `unicode-path` зелёная). Несколько совпадений на строке дают одну запись. Порядок — порядок Git.
- Dirty читается из рабочей копии, untracked не входит (клетки зелёные).
- `GIT_CONFIG_GLOBAL/SYSTEM=/dev/null` и `unset GIT_DIR…` делают измерение герметичным: чужой `grep.column`/`color` не сломает разбор `-z`. Если на станции владелец каталога другой (safe.directory в глобальном конфиге), git вернёт rc 128 и отчёт откажет rc 2 — это fail-closed, ложного нуля нет. CI PR #1441, по заданию, зелёный — сам я его не проверял, вывод не использую.
- Модель против production по предметным пунктам: argv git grep тот же (`top` в pathspec ничего не меняет, потому что cwd=root). Production чтение конфига ведёт байтами, проверяет типы, абсолютные пути, `..` и NUL — схема семьи их запрещает; отказ отдаёт rc 2 с префиксом. Модель на тех же отказах даёт rc 2 через KeyError/ValueError. Логика не расходится. Доп. проверки production (argc, `python3`) соответствуют инв. 1 и 4.

## Остатки

- ОСТАТОК: НЗ-1 (строк НЕ ЗАЩИЩАЕТ без К-номера, нумерую по порядку) «от наличия зашивок или немонотонного долга» (ловец reviewer) — не укусил. Отчёт 89/20 = база, в диффе нет порога/отказа (R11 ловится).
- ОСТАТОК: НЗ-2 «семантические зашивки вне configured ERE/области или сознательное изменение конфига ради сокрытия долга» (ловец reviewer полного diff/config) — не укусил. `config/zashivki.json` побайтно равен канону модели (pattern, 3 include, exclude `scripts/proxy`, база 89/20/6565542c1), область не сужена. В `scripts/proxy` совпадений 0, так что исключение долга не прячет. Новые файлы остаток не увеличили.
- ОСТАТОК: НЗ-3 «компрометация Git/PATH/установки» (ловцы isolated/CI и независимый reviewer) — не укусил. Production очищает `GIT_*` и не читает env. Подмена git в PATH даёт rc 2, а не отчёт (проверено (б)).
- ОСТАТОК: НЗ-4 «неконформный JSON/ERE, не-UTF-8, отказ FS/инструмента» (ловец оператор/CI) — не укусил. Все варианты (в) и битый ERE дают rc 2/`NOT_IMPLEMENTED`, stdout пуст.

## Норма 050 (паразитная сложность)

- `scripts/report_zashivki.sh` (новый, 162 строки):
  - (1) инв. 1–5; грамматика 083 требует bash-фасад;
  - (2) состояния нет — читает конфиг, пишет только stdout/stderr; очистка `GIT_*` видна в шапке;
  - (3) смена области/образца/базы — один файл (конфиг), число совместно меняемых мест 1;
  - (4) интерфейс — 0 аргументов, rc 0/2, env не читает; за ним валидация конфига, `git grep` и разбор `-z`. Модуль глубокий;
  - (5) потребители — CI `report:zashivki-227` и `W --repo`.
  - ESSENTIAL. Доп. валидации (`..`/абсолютные/NUL/argc/python3) отражают границы конформного входа и инв. 4. Более простая модельная форма даёт тот же rc 2 через исключения — разница стилевая, не ACCIDENTAL-блок.
- `config/zashivki.json` (новый):
  - (1) инв. 1, Frontier А;
  - (2) явные данные;
  - (3) 1 файл;
  - (4) н/п;
  - (5) скрипт и клетка `default-config`.
  - ESSENTIAL.
- Строки CI (`ci-steps.tsv` +2, `ci-zamery.tsv` +2, генерируемый `ci.yml`):
  - (1) инв. 6, ПРОВОДКА;
  - (2) состояния нет;
  - (3) стандартная тройка 083/114, без роста;
  - (4) н/п;
  - (5) потребитель — CI, `gen_ci_steps --check` rc 0.
  - ESSENTIAL. Отсутствие `--sintaksis` в селфтесте — С-1.

## Сверки

- СВЕРКА-АРХИТЕКТУРЫ: н/п. Контракт: «АРХИТЕКТУРА: н/п — станционный отчёт без продуктовой модели 188». `bindings.json`, новых писателей, операций и диффа модели нет. Писатель только stdout. Долг не расширен: остаток 89/20 = база.
- СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`grep -c` = 0). `validate_std bash` по production rc 0.
- Режим проекта 996: sourceCanon не объявлен («Нового sourceCanon нет»), сверка карты н/п. Мобильного экрана нет.
- ПРОВОДКА (038): guard `fixtures/workshop_project/zashivki_otchet_227/red_zashivki_otchet_227.sh` существует и подключён шагом `check:zashivki-otchet-227-family-selftest` (`--repo . && --model && --stabs && --catalog`). `check_provodka` rc 0. Guard — барьер именно этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: чистый read-only отчёт, поведенческой нормы роли нет.
- Класс риска «обычный» подтверждаю. Отчёт ничего не пишет (снимки файлов/index/HEAD до и после равны; R10 ловится), не трогает авторизацию, двери и права. Повышать класс оснований нет.
