FAIL

# Адверсарий 032, круг 1 — суд реализации WORKTREE-pinning

Предмет: frozen/032/1 (`d0e63cc`), реализация `ca40b87` в `.omp/extensions/path-guard.ts`, предъявленный HEAD `7b3b6f3` в свежем клоне `/tmp/dev-harness-verify/adv-032/repo`. Контракт прочитан целиком. Заморозка не дрейфовала: `git diff --exit-code d0e63cc HEAD -- contracts/032-*.md` → rc 0; SHA-256 frozen-блоба и рабочего `contracts/032-spawn-pinning-worktree.md` одинаковы: `19b255a4ad4760b3a30fce3aa576b0b77bd3b37e42d03417dcaf23ddcafe7d82`.

## Блокер А1 — проверка принимает ложный «живой linked worktree»

`isLiveLinkedWorktree()` считает валидным `.git`-файл, в котором корректная строка `gitdir:` стоит лишь где-то внутри мусорного многострочного содержимого. Причина — `/^gitdir:\s*(.+?)\s*$/m`: флаг `m` позволяет `^` и `$` совпасть с внутренней строкой. Это не содержимое *строкой формата* `gitdir: <путь>`, которое требует М1, а поддельный файл с мусорным заголовком/хвостом.

Исполненный обход не менял предмет или приёмку. Одноразовый `/tmp/dev-harness-verify/adv-032/extract-bypass-probe.mjs` создал настоящий git-репозиторий и реальный linked worktree `wip-101-aa`, затем отдельный каталог-кандидат `wip-111-aa` с `.git`:

```text
not-a-gitdir-header
gitdir: <существующий gitdir настоящего linked worktree>
trailer
```

Задание было канонической spawn-формы:

```text
032: WORKTREE=<кандидат>/wip-111-aa, BRANCH=wip/111/aa.
```

Команда:

```text
node /tmp/dev-harness-verify/adv-032/extract-bypass-probe.mjs /tmp/dev-harness-verify/adv-032/repo/.omp/extensions/path-guard.ts
```

дала rc 1 именно потому, что оракул ожидал безопасный отказ, но получил:

```json
{"cli":{"worktree":"/tmp/adv032-vzspaC/wip-111-aa"},"factoryDecision":"pass","spoof":"/tmp/adv032-vzspaC/wip-111-aa"}
```

То есть новый CLI ошибочно извлёк пин. Затем тот же зонд импортировал default-export, вызвал `register()` напрямую, передал `session_start` с этой единственной user-записью и `tool_call write` в каталог-кандидат. Фабрика вернула `undefined`, то есть разрешила запись (`factoryDecision: "pass"`). Это проверяет реальный factory-путь, а не только CLI.

М1 требует для `.git` «его содержимое — строка формата `gitdir: <путь>`» и fail-closed/null при нарушении любого условия. В данном входе кандидат не является подтверждённым linked worktree по этому правилу, однако сессия получает его как assignment pin и может писать туда. Следовательно, это обход реализации, который существующая приёмка не ловит.

### Почему текущая приёмка зелёная, хотя реализация неверна

Положительный контроль существует и исполнен: `bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .` → rc 0, все 20 ветвей зелёные. Именно на этой зелёной реализации приведённый ложный `.git` проходит и CLI, и factory. Значит это не вечнокрасный тест и не отказ среды, а различитель отсутствует: п4б проверяет только полностью мусорное содержимое `.git`, но не «мусор + внутренняя правдоподобная `gitdir:`-строка».

Закрытие за автором: проверять весь файл `.git` как единственную допустимую строку (без multiline-поиска внутренней строки) и добавить отдельный отрицательный вход в `red_pin_spawn_zadanie.sh`: `.git` с произвольной строкой до/после существующего `gitdir:` обязан дать null/block. Новый вход обязан быть проведён и через factory, так как именно там ложный пин превращается в разрешённую запись.

## Обязательные прогоны

- `bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .` → rc 0: 20/20 зелёных (п0–п15, включая п4а/п4б/п4в/п7б).
- `bash fixtures/check_runner_hygiene/red_pin_allowlist.sh . && bash fixtures/check_runner_hygiene/red_granica_nepin_pipe_tee.sh . && bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh .` → rc 0. Первый выводит зелёный контроль 025; вся цепочка завершилась rc 0.
- `bash scripts/verify_antiplacebo.sh . --scope check_runner_hygiene` → rc 0: 1 барьер, 40 фикстур, 40 повторных красных предъявлений.
- `git diff --exit-code d0e63cc HEAD -- contracts/032-*.md` → rc 0.

Проверены и не дали отдельного обхода: исправленная форма п9 (две user-записи, а не paragraph-last), per-session изоляция п11, самостоятельные `session_branch`/`session_tree` п12, приоритеты event/env/assignment п13–п15, `..` в обеих allowlist-ветвях и пустой вход `--extract-pin ''`. Последний намеренно даёт rc 2 (`FAIL: нужен --extract-pin <text>`), а не ложный JSON-успех. При отсутствии программ в PATH `env PATH=/nonexistent /bin/bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .` дал rc 2, `NOT_IMPLEMENTED: нет git`; отсутствие инструмента не было засчитано успехом.

Живой spawn/write-прогон намеренно не дублировался: по заданию его ведёт оркестратор параллельно.

## Детектор 024 — стенограмма

В клоне нет снимка, поэтому обязательная fail-closed сверка была исполнена и дала ожидаемый отказ, а не ложный зелёный:

```text
check_no_leak --check /tmp/dev-harness-verify/adv-032/repo → rc=1
ОТКАЗ: снимок отсутствует (/tmp/dev-harness-leak/cb30d1c1/porcelain) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)
```

Отдельный `bash fixtures/check_judge_gate/red_stenogrammy_sudej_024.sh` также дал rc 1 из-за ранее существующих вердиктов без стенограммы (первый перечисленный — `verdicts/adversary/contracts-020-k1.md`). Это состояние исторического дерева, не основание данного FAIL и не правилось.

## Итог

Приёмка доказывает обычные заявленные 20 сценариев и имеет положительный контроль, но пропускает конкретную ложную реализацию критерия «.git — строка формата gitdir». Реальный текущий subject проходит весь предъявленный набор, одновременно извлекая и применяя этот ложный пин через прямую фабрику. Поэтому verdict — **FAIL, А1 malformed-gitdir multiline bypass**.
