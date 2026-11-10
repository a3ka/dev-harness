accept
OBJECT=525e1a2e923e70277a7c39565545fb68ade6e1ea
СУД: repo=dev-harness; предмет=185; фаза=реализация (перед слиянием PR #730); роль=reviewer; вызов=1/1; сессия=Rev185v1 (харнесс-сессия c907157c); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; автор=implementer minimax/MiniMax-M3; контракт=frozen/contracts/185/1 (commit b95f2abf); совместимость=frozen/contracts/172/2; предыдущий=verdicts/critic/contracts-185-v1.md

# Вердикт reviewer — 185 «pre_judge prepare: детектор харнесса судит корень проекта», реализация, вызов 1/1

## Итог

Реализация допускается к слиянию. Дифф — один файл в зоне implementer. Детектор утечки теперь всегда
берётся из каталога установки. Локальный `$R/scripts/check_no_leak.sh` не выбирается ни при каком
состоянии файлов проекта. Если детектора установки нет, ответ — rc 2 с точной причиной из контракта.
Красный детектор, как и раньше, даёт rc 1 `CHECK_NO_LEAK_KRASEN`. Батарея 185 и регресс 172 v2 зелёные
на OBJECT и на слиянии OBJECT с текущим main. Против хотфикса #708 батарея 185 красная. Каждое
счётное заявление автора я проверил отдельной командой.

Два замечания ниже не блокируют слияние реализации. Р-1 блокирует `done 185`. Его закрывают
orchestrator и architect, не implementer.

## Чем проверял (сырой вывод сокращён до значимых строк, коды возврата — полностью)

Объект и база:
```
git fetch origin wip/185/implementer → FETCH_HEAD 525e1a2e923e70277a7c39565545fb68ade6e1ea (== OBJECT)
merge-base(OBJECT, origin/main f0812e9a) = 4d02a7e7a72ca8efc744ba13330329d8bb0a2ec7
git diff 4d02a7e7a..525e1a2e9 --stat → scripts/pre_judge.sh | 20 ++++++++++----------; 1 file changed, 10 insertions(+), 10 deletions(-)
git log 4d02a7e7..525e1a2e9 → 525e1a2e implementer «185: pre_judge prepare — детектор установки всегда, локальный не участвует»
```
Тестовое дерево: detached `origin/main` + `merge 525e1a2e9` (d8a818b3); `git diff --stat origin/main HEAD` → только `scripts/pre_judge.sh`.

1. Батарея 185 на слитом дереве:
```
probe.py --repo   → clean ZELENO rc=0 | dirty ZELENO rc=1 | local_fake ZELENO rc=1 | missing_harness ZELENO rc=2 | missing_harness_local_fake ZELENO rc=2 ; rc=0
probe.py --model  → те же 5 клеток ZELENO ; rc=0
probe.py --stabs  → 7 пар control ZELENO / mutant KRASNO; STAB no_call, ignore_rc, copy_in_project, wrong_root, red_as_green, missing_as_green, fallback_to_local — caught; ZHIV нет ; rc=0
probe.py (без аргументов) → 5 клеток ZELENO ; rc=0
```
2. То же на чистом OBJECT (`git checkout --detach 525e1a2e9`): `--repo` 5/5 ZELENO, rc=0. В `--stabs` 7 строк `caught`, rc=0.
3. Красный прогон: `git restore --source=4d02a7e7 -- scripts/pre_judge.sh`, это хотфикс #708. `probe.py --repo` → rc=1:
```
185 clean ZELENO rc=0
185 dirty ZELENO rc=1
185 local_fake KRASNO rc=0 stdout='OBJECT=…'            ← ложный допуск локального «exit 0»
185 missing_harness KRASNO rc=2 stderr='NOT_IMPLEMENTED: нет детектора утечки: scripts/check_no_leak.sh'
185 missing_harness_local_fake KRASNO rc=0 stdout='OBJECT=…'
```
4. Регресс 172 v2 на слитом дереве: `bash fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.sh`. Скрипт игнорирует argv и сам гонит `--repo`, `--model` и `--stabs`, поэтому вызывал его трижды; каждый раз rc=0. Обе прогонки дают 16/16 `ok`. Стабов поймано 14, в том числе `prefer_local` и `ignore_leak_rc` «on leak_reject with local fake».
5. Фикстура 172 **v1** (`git restore --source=frozen/contracts/172/1`) на реализации: `red_predverie_172.py --repo` → rc=1, KRASNO **только** у `published`, остальные 15 `ok`. Это совпадает с правилом контракта 185 и с заявлением автора.
6. `bash scripts/pre_critic.sh contracts/185-pre-judge-proektnyj-rezhim.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1`, «КРИТИК: дверь зелёная», rc=0.
7. `bash scripts/check_provodka.sh . contracts/185-pre-judge-proektnyj-rezhim.md` → rc=0 на слитом дереве и на OBJECT.
8. `bash scripts/check_project_sources.sh --repo . --contract contracts/185-pre-judge-proektnyj-rezhim.md --stage done` → rc=0 на слитом дереве и на OBJECT (HEAD=525e1a2e9).
9. Зоны, scoped, без полного `check_zones.sh`: `source scripts/lib_zones.sh; zones_load .` → rc=0.
   - Строки `implementer	scripts/pre_judge.sh	172` и `implementer	scripts/pre_judge.sh	185` найдены.
   - `zones_match_path … implementer scripts/pre_judge.sh` → rc=0.
   - В `zones_violations` одна запись, контракт 055 (`no_paths`). Она к 185 отношения не имеет и была до диффа.

## Проверки роли

1. **Область правки.** Изменён один файл, `scripts/pre_judge.sh`, в нём один ханк `@@ -239,16 +239,16 @@` внутри `if [ "$MODE" = 'prepare' ]`. Режимы sync-main, verdict и archive, проверки публикации, состояния и манифестов не тронуты. Пересечение с 172 укладывается в объявленную границу «только маршрут детектора внутри prepare». — соответствует.
2. **Сырой вывод.** Выше; все прогоны мои, вывод автора не переиспользовал.
3. **Проверки не подогнаны.** `git log` по `fixtures/workshop_project/pre_judge_leak_185` и `fixtures/dver_pered_kritikom/predverie_172` показывает только architect: 26d3416a, 92ac5c53, fc1960b5 и ранее. Implementer эти файлы не трогал. `git diff frozen/contracts/185/1 HEAD` по контракту и фикстуре 185 пуст. Стабы мутируют независимую модель `NEW`, а не предмет. Клетка `--repo` гоняет живой `scripts/pre_judge.sh` как отдельный процесс из независимого Git-дерева установки. — соответствует.
4. **Красное предъявлено.** На хотфиксе #708 батарея 185 даёт rc=1: KRASNO у local_fake, missing_harness и missing_harness_local_fake (п. 3). — соответствует.
5. **Атомарность.** Один коммит implementer со ссылкой на 185 и на frozen/contracts/185/1. — соответствует.
6. **Норма не тронута.** `roles/`, `AGENTS.md`, `contracts/` и фикстуры в диффе отсутствуют. — соответствует.
7. **Заявленное = сделанное (своей мерой).**
   - «5 клеток ZELENO» — подтверждено, 5 строк.
   - «7 стабов пойманы» — подтверждено: `grep -c caught` = 7 на OBJECT, 7 имён на слитом дереве.
   - «172 v2 16/16» — подтверждено, 16 строк `ok` на прогон `--repo`.
   - «172 v1: красна ровно published» — подтверждено, одна KRASNO.
   - «rc 2 NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh» — подтверждено точной строкой stderr.
   - Живую проверку на одноразовой копии Complior-back я **не воспроизводил**: по заданию клонирую только dev-harness. Эту строку считаю непроверенной; приёмка контракта её не требует.

## Мутации и формы вызова вне батареи (throwaway `smoke.py`, удалён)

Пробу 185 вызывают только по абсолютному пути. Я прогнал десять других форм вызова. Во всех случаях проект грязный (tracked-файл изменён после снимка) и в нём лежит локальный `scripts/check_no_leak.sh` с `exit 0`. Исключения — строки 8 и 9 (self-режим).

| # | форма вызова | реализация 525e1a2e9 | хотфикс #708 |
|---|---|---|---|
| 1 | `bash scripts/pre_judge.sh` из корня установки (форма `roles/orchestrator.md`) | rc=1 CHECK_NO_LEAK_KRASEN | rc=0 OBJECT (ложный допуск) |
| 2 | `bash pre_judge.sh` из `<установка>/scripts` | rc=1 | rc=0 |
| 3 | через симлинк на **каталог** установки | rc=1 (`pwd -P` канонизирует) | rc=0 |
| 4 | через симлинк на **файл** в третьем каталоге без детектора | rc=2 NOT_IMPLEMENTED (fail-closed) | rc=0 |
| 5 | через симлинк на файл, лежащий **в `$R/scripts/`** рядом с фейком; вызов из проекта | rc=0 OBJECT | rc=0 |
| 6 | `bash pre_judge.sh` при cwd=`$R/scripts`, установка в `$PATH` | rc=1 | rc=0 |
| 7 | абсолютный путь установки при cwd=`$R` | rc=1 | rc=0 |
| 8 | self-режим, `--repo` = корень установки, чисто | rc=0 OBJECT | rc=0 OBJECT |
| 9 | self-режим, установка грязная | rc=1 CHECK_NO_LEAK_KRASEN | rc=1 |
| 10 | `--repo` через симлинк на проект | rc=1 | rc=0 |

Почему не срабатывают подмены. Все `cd` в `pre_judge.sh` выполняются в подоболочках (строки 113, 122, 248), поэтому `BASH_SOURCE` при относительном вызове не уезжает в `$R`. Поиск по `$PATH` и cwd детектор не подменяют. В source-режиме `BASH_SOURCE[0]` указывает на сам файл.

Self-режим даёт прежний результат (8, 9).

## Находки

- [ ] **Р-1 (класс: остаточный риск CI; блок для `done 185`, не для слияния реализации; адресат — orchestrator + architect).**
  - **Что требует контракт.** Фрагмент контракта 185, §Зоны: «Команда шага — `python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --repo`; она совпадает с приёмкой».
  - **Почему шаг нельзя завести.** Грамматика `scripts/gen_ci_steps.sh:108-121` принимает только `"npm run "*` и `"bash "*`. Всё прочее она отклоняет: «команда вне грамматики». Bash-обёртки у батареи 185 нет.
  - **Что измерено.** Шаг CI `check:pre_judge-172-family-selftest` из `registry/ci-steps.tsv:296` гоняет `red_predverie_172.sh`. На хотфиксе #708 его `--repo` даёт **rc=0** (16/16 ok). Значит, ни один шаг CI не краснеет при откате предмета к «локальный детектор при наличии»; 172 v2 ловит `prefer_local` только на модели. Пока шага 185 нет, свойство 185 защищено в CI ничем.
  - **Как закрыть.** Bash-обёртка батареи 185 в зоне architect, по образцу `red_predverie_172.sh`, плюс строка `ci-steps` от orchestrator. Это расходится с буквой «команда шага = python3 …», поэтому нужна санкция v+1 либо npm-ключ. Выбор формы — за ними.
- [ ] **Р-2 (класс: совет; не блокирует).**
  - **Фрагмент.** `scripts/pre_judge.sh:248` `HARNESS_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"` канонизирует **каталог** вызванного пути, а не симлинк на файл. Сообщение коммита «каталог самого pre_judge.sh, канонизирован pwd -P» точно только для каталогов.
  - **Наблюдение.** Строка 5 таблицы: если дверь вызвать через файловый симлинк, лежащий в `$R/scripts/`, выбирается проектный фейк, rc=0. Для этого оркестратор должен исполнять путь внутри проекта, то есть точку входа, которой управляет проект. Это подмена установки, а контракт относит её к «НЕ ЗАЩИЩАЕТ». Хотфикс #708 вёл себя так же.
  - **Вне файлов проекта** файловый симлинк срабатывает fail-closed: rc=2 (строка 4). Достижимого в штатной проводке ложного зелёного я не нашёл. Симлинков на `pre_judge.sh` харнесс в проекты не кладёт; проверял поиском по `ln -s|symlink_to`.
  - **Чем закрыть, если owner захочет.** `readlink -f "${BASH_SOURCE[0]}"` закрывает и этот случай. Это вне замороженного обязательства.

## Паразитная сложность (контракт 050)

- **Ветвь `HARNESS_SCRIPTS=… || skip "нет каталога скриптов харнесса"`** (`scripts/pre_judge.sh:248-249`).
  1. Свойство — «отсутствие установочного детектора → rc 2, не зелёный».
  2. Новое состояние: локальная переменная `HARNESS_SCRIPTS`, явная, видна в коде и в stderr отказа.
  3. Файлов, меняющихся вместе: 1, как и было.
  4. Интерфейс двери не вырос: argv, rc, env прежние, ветвей на одну меньше — fallback к `$R` снят.
  5. Потребитель — клетки `missing_harness*` батареи 185. Форма повторяет независимую модель `NEW` из `probe.py`. Это совпадение формы, грамматика в дереве не дублируется.

  Без `|| skip` при пустом каталоге `DETECTOR` стал бы `/check_no_leak.sh`, и итог зависел бы от корня ФС. Вердикт: **ESSENTIAL**.
- **Удалённая ветвь `if [ ! -f "$DETECTOR" ]; then DETECTOR=<установка>`.** Это уменьшение кода; находки нет.

## ПРОВОДКА (контракт 038)

- **Существует ли guard.** `guard=scripts/pre_judge.sh` есть в дереве. Это барьер именно этого предмета: в нём живёт выбор детектора в prepare.
- **Подключение.** В CI guard подключён через шаг 172: `check:pre_judge-172-family-selftest`. Своего шага у батареи 185 нет, см. Р-1.
- **Нормы роли.** `ПРОВОДКА-ЭНФОРСМЕНТ` обоснован честно: меняется только выбор существующего детектора внутри существующей двери. Новой поведенческой нормы роли нет, `roles/orchestrator.md:360` не менялся. — соответствует.

## Режим проекта (контракт 996)

У дерева есть `harness.project.json`. Gate `check_project_sources.sh --stage done` даёт rc=0 на HEAD=OBJECT 525e1a2e9, п. 8.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`. Поиск `ARCHITECTURE\.md|CODING-STANDARDS|стандарт кода` в `AGENTS.md` пуст.

## Мобильный экран

Неприменимо — дифф без мобильного экрана.
