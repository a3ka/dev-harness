accept
OBJECT=615c0697ce9fcc9105a60303b48a32784d2175a0
СУД: репо=dev-harness; предмет=087; фаза=реализация; роль=reviewer; вызов=1 (единственный повтор обрыва Rev087a по 167, не исправительный вызов 2); сессия=Rev087b; модель-план=openai-codex/gpt-6.1-sol; модель-факт=openai-codex/gpt-6.1-sol; автор=Architect087a/Architect087b, другие сессии architect; предыдущий reviewer=нет финального вердикта; адверсарий=FAIL 95f17e97ab41af3a90854edb7d39787f1aefa7ea → ремонт 615c0697ce9fcc9105a60303b48a32784d2175a0 → accept aa9c0c83afc01021262b8f0459fd93db763ce9d3.

БЛОКИРУЕТ: нет.
СОВЕТ: С-1 (К-09, наблюдаемость дополнительных альтернатив), `.review/2026-11-27-0871.md`, status: ready.

## Предмет, независимость и границы суда

Судится только ремонт К10-исп в `fixtures/ci_b_087/red_ci_b_087.sh` и непосредственно зависимый регресс. Это не принятие всей старой реализации 087 заново, не новая атака на неизменённые клетки и не изменение frozen-критерия. Назначение Sol взято из явного задания до вызова, не из исторической строки TRACE095 reviewerOpus. Назначенный автор Architect087b — другая сессия; одинаковая модель не означает самосуд (166). Основание повторного reviewer-вызова и запись перед спавном `1577dc888` предъявлены ведущей в задании; не выдаю их за самостоятельно выполненный prepare. Свою формальную пятиколоночную trace не создавал: ведущая получает её после завершения этой сессии.

Полностью прочитаны `roles/reviewer.md`, `roles/critic.md §Быстрый-процесс`, AGENTS.md, выданные pack/task-rev087b-sol и оригинальный task-rev087. SHA256 выданного task проверен собственной командой:

```text
437e940890d449478f9d5c468e19f751fd7871c7b4b2276b5b8c62891f79f059  /tmp/dev-harness-verify/task-rev087b-sol.md
[exit=0]
```

Прочитаны именно полные блобы настоящих adversary-вердиктов из `origin/archive/087/adversary-v1-fail-95f17e97a` и `origin/archive/087/adversary-v1-accept-aa9c0c83`, а не пересказ автора. Первый отказ: безусловное снятие PR-события у runner-hygiene не соответствует реальной lane. Второй вердикт относится к данному OBJECT и закрывает этот класс; его совет о двух ненаблюдаемых альтернативах сохранён, а не скрыт.

## Остаток frozen — проверен до исполняемых проб

В `frozen/contracts/087/1` у строки «чтение учётного содержимого через git show HEAD:<учётный путь> — ловец ревьюер» нет К-ID. ОСТАТОК: К-ID отсутствует в frozen 087/1 — не укусил: дельта `red_ci_b_087.sh:564–573` только выбирает окружение запуска по ключу; чтение git-объектов или получение учётного содержимого не добавляется. Старые `k10_tree` и `k10_cmd` неизменны. Новое чтение ROADMAP существует исключительно в явно предъявленном одноразовом sentinel, не в кандидате. Остальные исключения frozen (доверенный автор workflow, внешняя среда и история, одна страница API) этой дельтой не изменяются; расширения разрешённого риска нет.

## Scope, история, атомарность и frozen

`git log -3 --format=fuller OBJECT` показывает отдельные предметные коммиты:

```text
615c0697ce9fcc9105a60303b48a32784d2175a0  architect-b
    fix(087): mirror lane event predicate by key class
e5a6dbca6cdcb428065361818d3eb7515530d1bb  architect
    087: исполнять К10-исп без PR-события внешней джобы
006b258dfb68413a88157f4cd4fcc8be9d7fd552  Merge pull request #1451
[exit=0]
```

Собственный `git diff e5a6dbca6cdcb428065361818d3eb7515530d1bb OBJECT` содержит ровно один hunk в одном файле: комментарий и запуск в К10-исп, +9/−2. Полный предметный diff от merge-base `006b258dfb68413a88157f4cd4fcc8be9d7fd552` до OBJECT: тот же файл, +9/−1. Это не ошибочная цифра +11/−2 из старого задания. Текущий origin/main уже ушёл учётными правками HANDOFF/ROADMAP/plan; двухточечный diff назад показывает и эти обратные изменения, поэтому границу предмета устанавливал по истории и merge-base, не приписывал их автору 087.

`K10_KEYS`, `k10_tree`, `k10_cmd`, остальные клетки, модель, стаб-пак, production, workflow, реестр и нормативный текст не изменены. Файл принадлежит живой ЗОНЕ architect из настоящего frozen 087/1. История честно показывает правку самого оракула архитектором; именно она — объявленный предмет ремонта по предыдущему FAIL, а не скрытая подгонка production. Критерий и стабы не ослаблены.

Сверка frozen, rc 0, diff пуст. Собственная сверка blob-id:

```text
$ git rev-parse frozen/contracts/087/1:contracts/087-ci-b-klassy-izmenenij-hesh-koda.md HEAD:contracts/087-ci-b-klassy-izmenenij-hesh-koda.md
ef4108a5b5bfaed5344de00189c70210e11b5d37
ef4108a5b5bfaed5344de00189c70210e11b5d37
[exit=0]
```

## Семантика дельты и своя мера покрытия

`case "$k"`, не `case "$cmd"`, дословно зеркалит `scripts/run_ci_lane.sh:87–95`: `*-family-selftest|check:document|drill:contract-change` снимает только `GITHUB_EVENT_NAME`; ветвь `*` выполняет обычный `bash -c`. `GITHUB_ACTIONS` и `CI` не снимаются. Отказ команды сохраняется через `if !`, попадает в `bad` с именем ключа и возвращает rc 1. Обоим семейным ключам сохранено нужное поведение, runner-hygiene больше не теряет PR-событие.

Другая мера, а не перепечатка итога автора: собственный Python-разбор объявления `K10_KEYS` с fnmatch по классу и подсчёт строк вызова `stab`:

```text
K10_KEYS cardinality= 3
check:pokrytie-079-family-selftest => unset-event
check:ops-server-family-selftest => unset-event
check:runner-hygiene => preserve-event
unreachable literal alternatives= ['check:document', 'drill:contract-change']
declared stab calls= 31
[exit=0]
```

С-1 — совет, не блок: две дополнительные литеральные альтернативы в текущем составе не исполняются. Они соответствуют реальной lane, а не противоречат ей; нарушения обязательства исполнения трёх назначенных ключей не найдено. Новая семья наблюдателей не требуется для принятия этой дельты.

## Независимое исполнение: зелёное и красное

Все записи, canonical SSH-клоны с собственными `.git`, журналы и scratch — только внутри собственной копии:

```text
ROOT=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tf1fac6a94/m
S=$ROOT/tmp/scratch-rev087b
OBJ=$ROOT/tmp/repro-object
SUB=$ROOT/tmp/repro218
MAIN=$ROOT/tmp/repro-main
```

Клоны получены через `git clone --no-checkout ssh://git@github.com/a3ka/dev-harness.git`; затем закреплены соответственно OBJECT, `eae9136de96f01cd833b4df39107275298335d55` и исторический main `006b258dfb68413a88157f4cd4fcc8be9d7fd552`. Это тот же main-контроль, что в подлинном adversary-вердикте, а не плавающая вершина. Runtime/PROJECT из пака не использованы для записи. `GIT_DIR/GIT_WORK_TREE` на основной репозиторий не применялись.

Один последовательный прогон, без повторного запуска проверок:

```text
env TMPDIR=$S VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck reslop t -- bash $S/review-run.sh
LOAD: 16
 16:10:50 up 17 days,  1:13, 13 users,  load average: 1.29, 1.39, 1.23
[exit=0; wall=250.36s]
```

Здесь `$S` — указанный выше реальный абсолютный путь; TMPDIR явно передан внешнему процессу и унаследован его потомками, не рассчитывал на export из другого busy-shell. Нагрузка ниже 1.5×nproc, тяжёлые проверки последовательны. Полный сырой stdout/stderr: `$ROOT/.log/2026-11-27-bash-01.raw.log`; точные argv/cwd/rc записаны там. Отдельные stdout и rc: `$S/<label>.log`, `$S/<label>.rc`; runner — `$S/review-run.sh`, точные байты sentinel — `$S/sentinel.patch`. Эти временные доказательства сохранены, не включены в коммит.

В cwd SUB выполнены настоящие `bash scripts/ci_klass.sh hash HEAD` и `bash scripts/ci_klass.sh strip <полученный H>`, без подмены классификатора:

```text
HASH218=0f4c0120b0b710be52d38403432731c5da108c9eaa8c333ce8a1e0c67de24f80
strip: удалено учётных путей 2626, кодовое дерево H=0f4c0120b0b710be52d38403432731c5da108c9eaa8c333ce8a1e0c67de24f80
RESULT[strip218] rc=0 expected=0
```

Каждый вызов батареи: `env GITHUB_EVENT_NAME=pull_request GITHUB_ACTIONS=true CI=true bash "$OBJ/fixtures/_krasnye_087.sh" <SUB|MAIN>`. Настоящая lane из cwd соответствующего субъекта: тот же env, `bash scripts/run_ci_lane.sh check:runner-hygiene`.

Сырой существенный вывод, не пересказ:

```text
  ok   К10-исп три ключа без учётных путей
ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)
RESULT[clean218] rc=0 expected=0
check_runner_hygiene: ветви «all» зелены
замер: check:runner-hygiene 36
RESULT[lane-clean218] rc=0 expected=0
```

После shebang `SUB/scripts/check_runner_hygiene.sh` однократно вставлены точные байты из подлинного adversary-вердикта (применение patch rc 0):

```bash
if [ "${GITHUB_EVENT_NAME:-}" = pull_request ]; then cat ROADMAP.md >/dev/null || exit 1; fi
```

Это демонстрация передачи события и отказа на stripped-дереве, не утверждение о существующем дефекте production:

```text
КРАСНО: К10-исп три ключа без учётных путей: на дереве без учётных путей (strip И-7) отказ — чтение учётного пути: check:runner-hygiene
ИТОГ 087: клеток ok=109 КРАСНО=1; стаб-пак: поймано 31/31 (subject)
RESULT[sentinel218] rc=1 expected=1
cat: ROADMAP.md: No such file or directory
замер: check:runner-hygiene 1
lane: отказ ключа check:runner-hygiene (rc=1)
RESULT[lane-sentinel218] rc=1 expected=1
```

Чистый main-контроль, без предварительного strip (К10-исп сам строит stripped-копию):

```text
  ok   К10-исп три ключа без учётных путей
ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)
RESULT[cleanmain] rc=0 expected=0
check_runner_hygiene: ветви «all» зелены
замер: check:runner-hygiene 35
RESULT[lane-cleanmain] rc=0 expected=0
```

Отдельная собственная мера B2d: `$S/count-observations.py` считает наблюдаемые строки клеток и стабов, не читает итоговые счётчики батареи и не повторяет её алгоритм:

```text
clean218: independent_line_count green_cells=110 red_cells=0 caught_stabs=31 red_stabs=0
sentinel218: independent_line_count green_cells=109 red_cells=1 caught_stabs=31 red_stabs=0
cleanmain: independent_line_count green_cells=110 red_cells=0 caught_stabs=31 red_stabs=0
[exit=0]
```

Красное предъявлено самостоятельно, не принято только по чужому зелёному отчёту. Предметных расхождений клетка↔lane нет. Дополнительная новая мутация не нужна: исходный класс ошибки различим sentinel и чистым 218; неизменённые поверхности заново не атаковал. Сообщения `Killed setsid sleep 30` в сыром stderr относятся к штатным пробам runner-hygiene; их не скрывал и проверку ради подтверждения не перезапускал.

## Адресный регресс и текущий CI на OBJECT

В конце того же прогона, cwd OBJ:

```text
COMMAND[gen-check]: bash scripts/gen_ci_steps.sh --check
RESULT[gen-check] rc=0 expected=0
# вывод пуст
COMMAND[parity]: bash scripts/verify_ci_parity.sh
workflow-команд: 19 · скриптов в приёмке: 86 · объявленных исключений: 28 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
RESULT[parity] rc=0 expected=0
COMMAND[ci-object]: gh pr view 1452 --json headRefOid,state,statusCheckRollup
RESULT[ci-object] rc=0 expected=0
COMMAND[ci-checks]: gh pr checks 1452
RESULT[ci-checks] rc=0 expected=0
```

Полные JSON и check-строки сохранены в `$S/ci-object.log`, `$S/ci-checks.log`. Существенные сырые строки:

```text
klass              pass       12s    https://github.com/a3ka/dev-harness/actions/runs/45962904936/job/140384677214
legkij             pass       1m57s  https://github.com/a3ka/dev-harness/actions/runs/45962904936/job/140384677582
obshchij           pass       4m20s  https://github.com/a3ka/dev-harness/actions/runs/45962904936/job/140384766951
tyazhelyj-itog     pass       4s     https://github.com/a3ka/dev-harness/actions/runs/45962904936/job/140398004409
vorota             skipping   0      https://github.com/a3ka/dev-harness/actions/runs/45962904936/job/140384679613
```

Своя обработка полученного JSON, без повторного запроса CI:

```text
headRefOid=615c0697ce9fcc9105a60303b48a32784d2175a0
state=OPEN
conclusions={'SUCCESS': 16, 'SKIPPED': 1}
non-success=[('vorota', 'COMPLETED', 'SKIPPED')]
all_completed=True
[exit=0]
```

Матрицы ci/antiplacebo зелёные; единственный skipped — push-only vorota в PR, не скрытая неисполненная тяжёлая проверка. CI привязан к данному OBJECT, не к SHA прошлого FAIL. Полный repo-wide регресс не запускался: не предмет этого scoped-суда.

## ПРОВОДКА, 050, архитектура и стандарт

ПРОВОДКА: frozen guard `fixtures/_krasnye_087.sh` существует, вызывает именно батарею 087; его предметный запуск подключён в obshchij (`.github/workflows/ci.yml:214–215`). К10-исп — предметная проверка учёт-независимости тяжёлых команд, не произвольный вызов дерева. Guard-only обоснован в frozen как чистый энфорсмент механизма CI/ворот; поведенческая role-норма этой дельтой не вводится. sourceCanon в выданном project-контексте null, gate сверки с внешним каноном неприменим.

050 — артефакт: расширенное ветвление К10-исп (одна семья, не новый скрипт/API). (1) И-7/И-8 frozen требуют честного исполнения на дереве без U; ремонт требует согласовать среду с lane, иначе чистые семейные проверки и sentinel различаются неверно. (2) Новое постоянное состояние отсутствует; используется уже передаваемый ключ и существующая env-переменная, снятие локально для дочерней команды, именованный отказ виден в выводе. (3) Для изменения той же политики согласуются два существующих файла — lane и её независимый наблюдатель; этот набор существовал до ремонта, новых файлов связности нет. (4) Новых аргументов, флагов, rc и читаемых env не вводится; ветвь скрывает реальную работу трёх команд, а не раздувает интерфейс. (5) Потребитель — приёмка А4/guard obshchij; повторяется узкий предикат lane намеренно в независимом оракуле, не создаётся второй production-классификатор. ESSENTIAL: более простое безусловное снятие события — документированный прежний ложный зелёный; безусловное сохранение нарушает чистый PR-контроль семейных ключей. Ненаблюдаемые литеральные альтернативы — только совет С-1, не доказанный блок ACCIDENTAL.

СВЕРКА-АРХИТЕКТУРЫ: размещение — существующая probe-only семья fixtures/ci_b_087; зависимости — существующие bash/env и команды реестра, новых нет; писатели — выбор env не пишет production/state; операции — прежнее построение stripped-копии и выполнение команд, изменён только предметный выбор окружения; bindings.json не вводится и не затрагивается, tooling/модель архитектуры на OBJECT отсутствуют; расширения архитектурного долга не найдено; diff модели отсутствует, L2/L3 не возникает. Основания для finding new по 188 не обнаружено.

СВЕРКА-СТАНДАРТОВ: AGENTS.md §«Воркфлоу майлстоуна» (неизменность нормы, красное доказательство и последовательность adversary→reviewer) — соответствует; AGENTS.md §«Правила, каждое из которых уже стоило времени», п.2–4 (rc, красное, другая мера) и п.8–9 (источник истины и сохраняемый вердикт) — соответствует. AGENTS.md не объявляет для этого репозитория отдельные docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md; такие пути отсутствуют на OBJECT, стандарт стороннего backend сюда не приписывается. Слой логики и форма модуля сохранены: оракул выбирает окружение, production не перенесён в fixture; ошибки не подавлены, данные/реестр не изменены.

## Итог

Предыдущий блок К-08/К-10 закрыт на точном кандидате, честный stripped218 и main зелёные, sentinel красен одновременно в клетке и lane с правильным именем ключа, зависимый регресс и CI зелёные. Единственная находка — неблокирующий С-1 в указанном reslop-файле. Код, норма, критерий и стабы судьёй не изменены; в сдачу входят только этот вердикт и .review. При изменении поведения/критерия/границы риска после этого OBJECT данное accept не переносится на новый кандидат.
