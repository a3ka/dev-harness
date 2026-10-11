ПРЕДМЕТ: n272-fd2180af-079-grandfather
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: CI lane legkij (check:charter) красен на PR#65, ветка wip/087/implementer контракта
087, живьём подтверждено через gh api jobs logs эндпоинт GitHub, run 38110427036, job
114384657679:
FAIL уставной документ изменён без разрешения владельца: contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
в fd2180af - тело коммита обязано нести строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ:
contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md <причина> в первой колонке.
РЕКОМЕНДАЦИЯ: Вариант — точечная grandfather-пара fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69/contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
при прямой санкции владельца в новом коммите с обоснованием, без переписывания merge
и без расширения грамматики razreshil(). Альтернатива при отсутствии санкции —
сохранить запрет и блокировку приземления. Это рекомендация, не разрешение и не
исполнение; одна эта пара НЕ обеспечивает зелёный check:charter — в том же живом
логе есть отдельный отказ по ROADMAP.md в fd2180af, не покрытый предметом этой
записи. Для зелёного legkij ОБА пары нужны вместе: первая для contracts/079 и
вторая для ROADMAP.md того же SHA; одна любая из них оставляет второй путь
красным. Вторая пара разобрана отдельной секцией ниже под той же логикой, что
первая, и того же класса — воля-владельца/риск; см. также
n272-fd2180af-079-grandfather-klass-v1.md «Расширение класса на вторую пару
того же SHA».

## Живая инженерная сверка

Запись forks/n272-fd2180af-079-grandfather.md и оба шаблона n269 прочитаны целиком
в собственном SSH-клоне. Независимыми readonly-прогонами установлено:

- (а) Запрошенный `git diff origin/main fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 -- contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md`
  дал пустой вывод, rc 0. `git rev-parse origin/main` вернул
  19efb35c5573a2f9ec179039925a0689a21421b3; закреплённый diff с этим SHA также пуст.
  Содержимое пути побайтово совпадает с наблюдавшимся origin/main.
- (б) `git log -1 --format='%H %P' fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69`
  дал rc 0 и строку:
  `fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 e04e3177e2c3b9dd63afe67bdac37cfd7994d27d 19efb35c5573a2f9ec179039925a0689a21421b3`.
  Родителей ровно два, оба совпадают с записью; второй — наблюдавшийся origin/main.
  Относительно первого родителя путь изменён (пять hunks, SHA вывода 8f0e6ef2…);
  относительно второго — нет. Это импорт main-содержимого, а не отсутствие дельты
  к первому родителю, по которой guard и судит merge.
- (в) Живой `gh api repos/a3ka/dev-harness/actions/runs/38110427036/jobs --jq '.jobs[] | select(.name=="legkij")'`
  дал rc 0: job 114384657679, head_sha fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69,
  head_branch wip/087/implementer, status completed, conclusion failure; шаг 8
  «Лёгкое задание (устав, зоны, ids, protected, грамматика 015)» завершился failure.
  Сам jobs-ответ не называет упавший ключ. Поэтому дополнительно исполнен
  `gh api repos/a3ka/dev-harness/actions/jobs/114384657679/logs`, rc 0. Лог содержит:
  `incr: check_charter судит 19efb35c..fd2180af (5 коммитов)`;
  в 04:04:59.2359174Z — FAIL по contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
  в fd2180af, без строки разрешения владельца;
  в 04:05:06.5758428Z — `lane: отказ ключа check:charter (rc=1)`.
  Существенная граница вывода: в 04:04:55.6588889Z тот же лог содержит FAIL по
  ROADMAP.md в fd2180af. Свидетельство по contracts/079 не разрешает этот другой путь
  и не обещает зелёный CI после внесения одной пары.
- (г) Живой `git show origin/main:scripts/check_charter.sh`, rc 0, и закреплённый
  `git show 19efb35c5573a2f9ec179039925a0689a21421b3:scripts/check_charter.sh`, rc 0,
  предъявили пары 15/16 (2c01b1ed, ROADMAP.md и contracts/082) и 17/18
  (6609f708, 797a3129, ROADMAP.md), затем 19–23; последняя — 41f80d3b/contracts/094.
  Те же пары присутствуют в исполняемом case razreshil(), не только в комментарии.
  Подсчёт подстроки fd2180af во всём выводе `git show origin/main:scripts/check_charter.sh`
  дал 0 вхождений: предлагаемая пара ещё НЕ внесена. Пары 24/25 в наблюдавшемся
  файле также отсутствуют; «26-я» — будущая нумерация кандидата из записи, а не
  установленный факт о текущем аллоулисте. Его закреплённый SHA256 вывода 7523d167…
  совпадает с числом в обоих прочитанных свидетельствах n269.

## Живая инженерная сверка — вторая пара того же SHA (ROADMAP.md)

Парность требует тех же самых доказательств, что и первая пара, против того же
SHA fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69, против того же пина origin/main
19efb35c5573a2f9ec179039925a0689a21421b3, против того же лога задания
114384657679 на run 38110427036. Независимыми readonly-прогонами в том же клоне
установлено:

- (д) Запрошенный `git diff 19efb35c5573a2f9ec179039925a0689a21421b3 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 -- ROADMAP.md`
  дал пустой вывод, rc 0. Содержимое ROADMAP.md в fd2180af побайтово совпадает
  с наблюдавшимся origin/main. SHA256 вывода e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  — канонический SHA256 пустой строки. Это в точности тот же класс, что и пункт
  (а) для contracts/079: 3-way merge принёс уже main-идентичное содержимое, новой
  строки guard не видит.
- (е) `git rev-parse fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^1 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^2`
  дал rc 0 и ровно два SHA: e04e3177e2c3b9dd63afe67bdac37cfd7994d27d (первый
  родитель — wip/087/implementer до sync-merge) и 19efb35c5573a2f9ec179039925a0689a21421b3
  (второй родитель — наблюдавшийся origin/main на момент пуша).
  `git diff fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^1 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 -- ROADMAP.md`
  НЕ пуст — 40592 байта вывода, SHA256 3f488ad017ebde787a1c6b7ee20ecb2999e087e43c3c2789efb37c162b20e8f9.
  Это та же картина, что для contracts/079 в пункте (б): относительно первого
  родителя дельта есть, относительно второго — нет; guard судит merge по дельте
  ко второму родителю (origin/main на момент пуша).
- (ж) Живой `gh api repos/a3ka/dev-harness/actions/jobs/114384657679/logs`, rc 0,
  содержит на 04:04:55.6588889Z — FAIL уставной документ изменён без разрешения
  владельца: ROADMAP.md в fd2180af, без строки разрешения владельца. Этот FAIL
  идёт РАНЬШЕ FAIL по contracts/079 на 04:04:59.2359174Z (пункт (в)) и закрывается
  тем же `lane: отказ ключа check:charter (rc=1)` на 04:05:06.5758428Z. Один
  источник лога, две независимые строки FAIL по двум разным путям того же SHA;
  guard выходит из проверки на первом провале, поэтому даже зелёная fix-пара
  только для contracts/079 не перекроет срабатывание на ROADMAP.md.
- (з) Живой `git show origin/main:scripts/check_charter.sh`, rc 0, и закреплённый
  `git show 19efb35c5573a2f9ec179039925a0689a21421b3:scripts/check_charter.sh`,
  rc 0, показал 0 вхождений подстроки fd2180af — предлагаемая вторая пара ещё
  НЕ внесена в наблюдаемый аллоулист. Закреплённый SHA256 вывода тот же
  7523d1671f5856ceb4f05bc5c9af4cb34cebcbb735290392db64fe6e4193dd81, что и в
  пункте (г); основание по guard не сдвинулось.

Вывод по второй паре: та же логика, что по первой. Путь байтово main-идентичен,
родители те же, лог фиксирует тот же класс отказа guard; добавление одной только
пары для contracts/079 оставит ROADMAP.md всё ещё красным.

## Дословный кандидат из записи форка

```
  fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69  contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
  26-я: sync-merge wip/087/implementer от 2026-10-11 (эта сессия) - необходим для
  устранения GitHub PR mergeable_state=CONFLICTING (0 check-suites на push, PR-CI не
  триггерился вовсе); merge принёс байтово main-идентичное contracts/079-*.md через 3-way
  merge, сам merge не менял строки вручную; грамматику razreshil() не менять, допущение -
  только для этой пары; слово владельца и дата подставляются при коммите.
```

Парная кандидатура для той же логики и того же SHA, не упомянутая явно в записи
форка, но ТОГО ЖЕ класса — воля-владельца/риск — и покрытая тем же живым логом
на 04:04:55.6588889Z; для зелёного legkij ОБА пары нужны вместе, одна любая
оставляет второй путь красным:

```
  fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69  ROADMAP.md
  26-я: sync-merge wip/087/implementer от 2026-10-11 (эта сессия) - необходим для
  устранения GitHub PR mergeable_state=CONFLICTING (0 check-suites на push, PR-CI не
  триггерился вовсе); merge принёс байтово main-идентичное ROADMAP.md через 3-way
  merge, сам merge не менял строки вручную; грамматику razreshil() не менять, допущение -
  только для этой пары; парность с одновременной 26-й для contracts/079 того же SHA
  обязательна (одна эта пара тоже не даёт зелёный legkij); слово владельца и дата
  подставляются при коммите.
```

Это цитата кандидата, не состоявшееся слово владельца. Предшествующая история
CONFLICTING/нулевых check-suites здесь не проверялась: источник этого утверждения —
запись форка. Равенство результата main не доказывает способ ручного редактирования
при merge; проверены результат и два родителя. Если владелец санкционирует вариант,
одного комментария недостаточно: действующее допущение — точная пара в case
razreshil(), без разрешения всех путей данного SHA. Сам guard мною не изменён.

## Исполненное основание

Корень: /tmp/dev-harness-verify/consultant-n272-20261011, созданный командой
`git clone ssh://git@github.com/a3ka/dev-harness.git`. Fork-коммит b17c8ce2 отсутствовал
в origin; после SSH-клонирования он импортирован readonly-fetch из основного
чекаута в refs/remotes/assignment/main, ветка consultant/n272 создана от b17c8ce2.
Это не локальный path-clone; основной чекаут не изменялся, команды в его cwd не
исполнялись. Проверяемый origin/main остался 19efb35c5573a2f9ec179039925a0689a21421b3.

Команды троек исполнены в cwd корня через `env -i PATH=/usr/bin LC_ALL=C.UTF-8
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_OPTIONAL_LOCKS=0 git
-c core.hooksPath=<пустой каталог вне дерева> …`. Объединённые stdout+stderr захвачены
через `$( )`, rc взят сразу после вызова; хвостовые LF отброшены, SHA256 получен
через `printf '%s' "$out" | sha256sum`. В тройках только закреплённые SHA и команды
readonly-белого списка; gh API — отдельное живое свидетельство, не команда барьера.
Для родителей в тройке использован отдельно исполненный rev-parse: парсер барьера
не разбирает shell-кавычки вокруг формата с пробелом.

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git diff 19efb35c5573a2f9ec179039925a0689a21421b3 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
RC: 0
ВЫВОД-SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
КОМАНДА: git rev-parse fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^1 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^2
RC: 0
ВЫВОД-SHA256: 19bbd2086c4c8d6316f04c960fe2c5dae59fc8774af655d35a72ca242923b12c
КОМАНДА: git diff fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^1 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
RC: 0
ВЫВОД-SHA256: 8f0e6ef272cfc03a129c7c4a7a056ef0c7112f1519d8dbd1c7047975c71c80f1
КОМАНДА: git show 19efb35c5573a2f9ec179039925a0689a21421b3:scripts/check_charter.sh
RC: 0
ВЫВОД-SHA256: 7523d1671f5856ceb4f05bc5c9af4cb34cebcbb735290392db64fe6e4193dd81
КОМАНДА: git diff 19efb35c5573a2f9ec179039925a0689a21421b3 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 ROADMAP.md
RC: 0
ВЫВОД-SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
КОМАНДА: git diff fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69^1 fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 ROADMAP.md
RC: 0
ВЫВОД-SHA256: 3f488ad017ebde787a1c6b7ee20ecb2999e087e43c3c2789efb37c162b20e8f9
