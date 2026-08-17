FAIL

# Ревью пачки шага 5

Проверен диапазон `56ef875~1..1efa9c8` в отдельном чистом клоне. Вердикт — отказ: найдены четыре самостоятельные находки, две из них прямо не исполняют решение арбитража.

## Область правки

Проверены объявленные `scripts/**`, `fixtures/**`, `config/`, `.github/workflows/ci.yml`, `package.json` и записи нормы. Также проверена история именно чувствительных к параллельной работе файлов:

```text
$ git log --format='commit %H%nsubject: %s%n' -p 56ef875~1..HEAD -- package.json .github config
…
commit 56ef875e9ca31051271443599e5b582a80c54f7c
subject: Паритет с CI: гейт, который зеленее CI, — не гейт
@@ package.json
-    "models:actual": "bash scripts/models_actual.sh",
-    "check:antiplacebo": "bash scripts/verify_antiplacebo.sh"
+    "check:antiplacebo": "bash scripts/verify_antiplacebo.sh",
+    "check:ci-parity": "bash scripts/verify_ci_parity.sh"
…
commit be909923e1b20bbf1bd521b4fa88b7c6a18be902
subject: Механизм 4 по вердикту адверсария; повтор воспроизводит и ОКРУЖЕНИЕ
@@ package.json
+    "models:actual": "bash scripts/models_actual.sh",
…
```

Кроме уже восстановленного `models:actual`, иных удалённых функциональных строк в этих трёх путях без предметного изменения в сообщении коммита не найдено. До собственных прогонов клон был чист:

```text
$ git status --short

```

В исходном коммите нет необъявленных отслеживаемых путей: `git diff --name-status 56ef875~1..HEAD` дал только объявленные механизмы, фикстуры, проводку, документы и обязательные вердикты процесса. Временные каталоги, созданные этим ревью, удалены после замеров.

### Находка 1 — несоответствие счётного утверждения дереву

**Класс:** заявление не равно сделанному; область/документация.  
**Файл:** `HANDOFF.md:107–108`.  
**Суть:** документ утверждает 52 фикстуры на чистом чекауте, фактическое число — 68. Это не приблизительная формулировка, а процитированный результат команды.

**Независимая мера и сырой вывод:**

```text
$ git ls-files 'fixtures/**/case_*.sh' | wc -l
68

$ npm run check:antiplacebo
…
барьеров: 11 · фикстур: 68 · предъявлено красным повторным прогоном: 68
check:antiplacebo rc=0
```

Именно несовпадение 52 с 68 делает запись недостоверной. Это повтор прежнего класса дефекта, который сам план называет причиной заведения механизма; поэтому не является редакционной мелочью.

## Проверки, подогнанные под код

История показывает, что изменявшие реализацию также меняли проверочные файлы (`git log --format='%h\t%an\t%s' -- scripts fixtures` содержит, в частности, `ef32e2b parity-fixes2 …` и `5f477f0 IdsFixes2 …`). Само авторство не объявлено отдельным отказом: план разрешает строить барьер и фикстуры одной пачкой. Но ниже предъявлены два случая, в которых собственная фикстура удерживает частную реализацию вместо заявленного предмета.

### Находка 2 — фикстура вложенных запусков проверяет внутренний разбор, хотя арбитр предписал отказать на форме

**Класс:** проверка подогнана под реализацию; несоответствие арбитражу.  
**Файлы:** `fixtures/verify_ci_parity/case_opaque_vlozhennye_zapuski.sh:6–13, 25–37`; `scripts/verify_ci_parity.sh:459–585, 587–647, 720–721`.  
**Суть:** фикстура всегда вкладывает отсутствующий `check:missing`; поэтому нынешняя реализация, извлекающая вложенную команду, краснеет. Она не проверяет обязательный предмет решения: сам `$(...)`, обратная кавычка, `eval`, `sh -c`, heredoc и `xargs` находятся вне объявленного подмножества и должны дать честный код 1 независимо от того, покрыт ли вложенный скрипт.

Контрольное дерево содержит один существующий `check:existing`, а внешняя команда объявлена корректным исключением. По решению арбитража это обязано быть красным «шаг вне разбираемого подмножества». Фактический барьер зелёный:

```text
$ bash scripts/verify_ci_parity.sh ../probe-parity; printf 'status=%s\n' "$?"
  ok   команда «echo "$(npm run check:existing)"» (/home/aka/Documents/dev-harness/tmp/reviewer/probe-parity/.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: внешняя команда намеренно печатает результат вложенного проверочного сценария

workflow-команд: 2 · скриптов в приёмке: 1 · объявленных исключений: 1 · расхождений: 0
status=0
```

### Находка 3 — идентификаторы молча сужают и не разбирают `verdict:`

**Класс:** проверка подогнана под текущую плоскую фикстуру; норма о неразобранном объявлении не соблюдена.  
**Файлы:** `scripts/next_id.sh:243–247`; `scripts/check_ids.sh:150–160`; отсутствует фикстура на неверное или вложенное объявление роли.  
**Суть:** `next_id.sh` читает только оболочечный глоб `roles/*.md`; `check_ids.sh` ищет только `roles/` на `-maxdepth 1` и извлекает любое однострочное `verdict:` регулярным выражением. В отличие от `check_protected.sh`, они не читают фронтматтер целиком, не валидируют значение и не отказывают с названным местом. Поэтому роль с `verdict: verdicts/*/` одновременно скрывает дубликат и получает зелёный результат.

**Сырой прогон:** в подставном git-репозитории есть `roles/newrole.md` с `verdict: verdicts/*/`, два файла `verdicts/glob/001-*.md` и тег `id/VERDICT/001`.

```text
$ bash scripts/check_ids.sh ../probe-unparsed-role; printf 'check-status=%s\n' "$?"; bash scripts/next_id.sh ../probe-unparsed-role VERDICT; printf 'issue-status=%s\n' "$?"
  ok   номера уникальны и согласованы с регистром выдачи
check-status=0
002
issue-status=0
```

Независимо проверена и вложенная роль с корректным `verdict: verdicts/newrole/`, двумя `001` и тегом:

```text
$ bash scripts/check_ids.sh ../probe-ids; printf 'status=%s\n' "$?"
  ok   номера уникальны и согласованы с регистром выдачи
status=0

$ bash scripts/next_id.sh ../probe-ids VERDICT; printf 'status=%s\n' "$?"
grep: /home/aka/Documents/dev-harness/tmp/reviewer/probe-ids/roles/*.md: No such file or directory
NOT_IMPLEMENTED: ни одна роль не объявила verdict: кроме null — VERDICT выдавать некуда
status=2
```

## Соответствие арбитражу

### Вопрос 1: неразобранное объявление

* **`verdict:` для `check_protected.sh` — исполнено.** В `scripts/check_protected.sh:128–159` роль берётся из всех достижимых blob, фронтматтер читается целиком, значения `*`, абсолютный путь, `..`, отсутствие поля и поле вне закрытого фронтматтера перечислены отдельными фикстурами. Общий прогон предъявил все пять красными.
* **`run:` — НЕ исполнено.** Решение требует кода 1 на `$(...)`, обратных кавычках, `eval`, `sh -c`/`bash -c`, heredoc, `xargs` и конвейере в интерпретатор. Вместо этого `verify_ci_parity.sh:587–647,720–721` пытается извлечь и повторно разобрать внутренние команды; находка 2 воспроизводит зелёный результат в запрещённой форме.
* **Шапки барьеров и фикстур — исполнено.** `verify_antiplacebo.sh:117–143` классифицирует всё `scripts/**`; общий прогон предъявил красными неклассифицированный файл, маркер в heredoc и битую ссылку.
* **Тот же принцип не соблюдён в `next_id.sh`/`check_ids.sh`.** Хотя это не отменяет реализации в `check_protected.sh`, общая норма арбитража и AGENTS не допускает молчалого сужения объявления роли; находка 3 это воспроизводит.

### Вопрос 2: порог причины

**НЕ исполнено.** Решение прямо потребовало заменить предмет порога с «осмысленности» на «отсечку отметки», а требование смысла пометить `cognitive-only` с остаточным риском: шесть греческих имён пройдут, их ловит только чтение ревьюером/адверсарием. Вместо этого `scripts/verify_ci_parity.sh:67–80` продолжает обещать «ИСКЛЮЧЕНИЕ … ОСМЫСЛЕННЫМ» и «ПОРОГ ОСМЫСЛЕННОСТИ», утверждает, что причина обязана назвать две вещи, и не содержит ни `cognitive-only`, ни записанного остаточного риска.

**Сырой поиск по норме и реализации:**

```text
$ grep '(cognitive-only|греческ|остаточн|салат)' AGENTS.md scripts/verify_ci_parity.sh config/ci_parity_exceptions.txt plans/005-four-mechanisms.md
AGENTS.md:128:   `cognitive-only` с записанным остаточным риском.
AGENTS.md:149:   предложения и этим исчерпывается, остальное помечается `cognitive-only`.
plans/005-four-mechanisms.md:77:  этим исчерпывается; осмысленность помечена `cognitive-only` с записанным остаточным риском
```

Ни `scripts/verify_ci_parity.sh`, ни рабочий файл исключений записи риска не дают. Это не требование новой фикстуры на «салат»: арбитр как раз запретил такую фикстуру. Это несоответствие формулировки и нормы.

### Вопрос 3: наблюдение фикстуры

**Исполнено.** `verify_antiplacebo.sh:22–49, 267–350` запускает барьер проверяющим через FIFO, строит окружение из закоммиченной шапки и добивает группу `setsid` до повторного прогона. В общем прогоне предъявлены четыре обязательные атаки канала наблюдения: `case_perepisala_uchet`, `case_neobjavlennoe_okruzhenie`, `case_narisovala_vyzovy`, `case_ostavila_potomka`.

### Отклонённая находка `if: false`

**Исполнено, полумеры не осталось.** Коммит `1efa9c8` удаляет `case_if_false_ne_pokryvaet.sh`, `FALSE_LITERALS`, `is_constant_false_if` и фильтр из `collect_runs`; нынешний `collect_runs` на `scripts/verify_ci_parity.sh:423–436` извлекает `run:` без чтения `if:`. Сырой diff:

```text
$ git show --stat --oneline 1efa9c8
1efa9c8 Отклонённая арбитром находка откачена: `if:` — чужой язык, а не наша грамматика
 .../verify_ci_parity/case_if_false_ne_pokryvaet.sh | 51 ------------------
 scripts/verify_ci_parity.sh                        | 63 +++++++---------------
 2 files changed, 19 insertions(+), 95 deletions(-)
```

## Норма против кода

Проверены десять правил `AGENTS.md:127–151`.

| Пункт нормы | Результат | Основание |
|---|---|---|
| 1. правило имеет механизм либо `cognitive-only` с риском | FAIL | Вопрос 2 выше: для смысла причины не записаны ни требуемая метка, ни остаточный риск. |
| 2. нет `PASS`, код 2 — `NOT_IMPLEMENTED` | исполнено | поиск `PASS` в `scripts/` дал только комментарий `next_id.sh:101–102`; обязательные прогоны не дали неоговорённого кода. |
| 3. красное предъявлено | исполнено для имеющихся барьеров | `check:antiplacebo` предъявил 68 повторных красных. |
| 4. счёт считается другой мерой | FAIL | `HANDOFF.md` всё ещё утверждает 52 при независимом `git ls-files … | wc -l` = 68. |
| 5. номер выдаёт механизм | FAIL | находка 3: неразобранная роль выключает и выдачу, и сверку области. |
| 6. каждая команда `run:` есть в приёмке | FAIL | текущий равный набор зелёный, но находка 2 оставляет запрещённый shell-сценарий зелёным вопреки обязательному отказу арбитража. |
| 7. неразобранное объявление — честный код 1 | FAIL | находка 3: `verdict: verdicts/*/` даёт `check_ids=0`, `next_id=0`. |
| 8. наблюдение только в памяти проверяющего/закоммиченном исходнике | исполнено для анти-плацебо | FIFO, объявленное окружение и убийство группы перечислены выше. |
| 9. вердикт — коммит | исполняется этим артефактом | файл создан для отдельного коммита. |
| 10. русский и временное в `./tmp` | исполнено | сообщения и документы русские; все пробы были в `./tmp/reviewer/`. |

## Сырые прогоны

### Рабочий клон

Выполнено последовательно:

```text
$ npm run check:antiplacebo
барьеров: 11 · фикстур: 68 · предъявлено красным повторным прогоном: 68
check:antiplacebo rc=0

$ npm run check:ci-parity
workflow-команд: 8 · скриптов в приёмке: 13 · объявленных исключений: 5 · расхождений: 0
check:ci-parity rc=0

$ npm run check:ids
  ok   номера уникальны и согласованы с регистром выдачи
check:ids rc=0

$ npm run check:protected
область: :(literal)plans/ :(literal)verdicts/adversary/ :(literal)verdicts/arbitration/ :(literal)verdicts/review/ · коммитов пройдено: 46 · существовало: 9 · на HEAD: 9 · исчезло: 0 · с разрешения: 0
check:protected rc=0

$ npm run drill:protected-exception
  ok   явное именное разрешение принято и названо в отчёте
drill:protected-exception rc=0

$ npm run drill:next-id-race
  ok   атомарность выдачи: 001 и 002 — max+1 и max+2 от пустого репозитория, оба с тегами
drill:next-id-race rc=0

$ npm run check:gen
харнес соответствует roles/ (5 ролей)
check:gen rc=0
```

### Чистый клон без `omp`

Создан свежим `git clone`, затем для каждой команды использовано ровно `env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent <команда>`:

```text
$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent check:antiplacebo
барьеров: 11 · фикстур: 68 · предъявлено красным повторным прогоном: 68
clean check:antiplacebo rc=0

$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent check:ci-parity
workflow-команд: 8 · скриптов в приёмке: 13 · объявленных исключений: 5 · расхождений: 0
clean check:ci-parity rc=0

$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent check:ids
  ok   номера уникальны и согласованы с регистром выдачи
clean check:ids rc=0

$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent check:protected
область: :(literal)plans/ :(literal)verdicts/adversary/ :(literal)verdicts/arbitration/ :(literal)verdicts/review/ · коммитов пройдено: 46 · существовало: 9 · на HEAD: 9 · исчезло: 0 · с разрешения: 0
clean check:protected rc=0

$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent drill:protected-exception
  ok   явное именное разрешение принято и названо в отчёте
clean drill:protected-exception rc=0

$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent drill:next-id-race
  ok   атомарность выдачи: 001 и 002 — max+1 и max+2 от пустого репозитория, оба с тегами
clean drill:next-id-race rc=0

$ env -i PATH=/usr/bin:/bin HOME=$HOME npm run --silent check:gen
харнес соответствует roles/ (5 ролей)
clean check:gen rc=0
```

### Вторая мера счёта

```text
$ git ls-files scripts | wc -l
12
$ git ls-files 'fixtures/**/case_*.sh' | wc -l
68
$ grep 'Коды возврата:' scripts/*
check_ids.sh, check_no_rewrite.sh, check_protected.sh, drill_next_id_race.sh,
drill_protected_exception.sh, gen-harness.ts, models_actual.sh, next_id.sh,
overlay.sh, verify_antiplacebo.sh, verify_ci_parity.sh
```

Из 12 файлов `scripts/` один (`roles.ts`) явно объявлен `НЕ БАРЬЕР`; следовательно, независимая мера даёт 11 барьеров и 68 фикстур, что совпадает с фактическим прогоном и опровергает запись HANDOFF о 52.
