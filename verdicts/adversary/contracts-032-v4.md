# FAIL — adversary 032, круг 4: суд доверенного якоря

Предмет судился в disposable-клоне `/tmp/dev-harness-verify/adv-032-k4/repo` на HEAD `b725ef42e151bfc6fd36d7fb64c17c795e9e5a1c` (заявленный `b725ef4`). Живой пункт по границе арбитра не использован как блокер: этот FAIL относится только к доверенному git-якорю корня 1.

## Блокер S-elf-git-first: shebang — не аутентификация бинарника

`resolveGitAbsolute()` перебирает унаследованный `PATH`, принимает первый regular executable `git` и отбрасывает только файл, первые два байта которого равны `#!` (`isShellScript()`). Поэтому подставной нативный ELF без shebang проходит `statSync().isFile()`, x-бит и фильтр, кэшируется как `GIT_PATH`, а `gitOracle()` затем вызывает именно его абсолютным путём. Абсолютность строки пути не делает исполняемый файл доверенным.

Исполнен disposable probe `node ../anchor-elf-first-probe.mjs .omp/extensions/path-guard.ts`. Он создаёт forged-кандидат `wip-101-aa/.git` с единственным содержимым `not a gitfile\n`; это не Git worktree. Перед `/usr/bin` он кладёт скомпилированный C ELF `git` (без shebang), который печатает существующий `/tmp` и завершается rc 0. Результат:

```json
{
  "cli": {
    "rc": 0,
    "out": "{\"worktree\":\"/tmp/adv032-anchor-elf-…/wip-101-aa\"}",
    "err": ""
  },
  "factory": { "rc": 0, "out": "pass", "err": "" },
  "forgedDotGit": "not a gitfile",
  "fakeGit": "ELF executable without shebang"
}
```

То есть неверная реализация проходит обе обязательные поверхности: CLI ложно возвращает pin вместо `null`, а factory (`register()` → `session_start` с assignment → `tool_call write` в forged-кандидате) возвращает `pass` вместо `block`. Это исполненный вариант класса k3 fake-git-first; текущая п4о/п4п строит только shell-фейк, поэтому зелёная против этой неверной реализации.

## Блокер S-cache-path-replace: кэширует имя, а не проверенный объект

Дополнительно исполнена прямо требовавшаяся новая атака подмены кэша между загрузкой и вызовом: `node ../anchor-cache-probe.mjs .omp/extensions/path-guard.ts /usr/bin/git`.

1. До import модуля `PATH` начинается с `bin/git`, который является symlink на настоящий `/usr/bin/git`, поэтому `GIT_PATH` кэшируется как допустимый абсолютный pathname `bin/git`.
2. После завершения module initialization, но до первого `extractPin()`/`gitOracle()`, symlink удаляется и по тому же пути ставится скомпилированный ELF, печатающий `/tmp` с rc 0.
3. Factory получает assignment на forged-кандидат с `.git = not a gitfile\n` и пытается write внутри него.

Фактический результат:

```json
{"decision":"pass","cachePathReplaced":true,"forgedDotGit":"not a gitfile"}
```

Следовательно, проверка `isFile+x` и shebang сделана лишь для объекта, находившегося по pathname при загрузке. Последующий `spawnSync(GIT_PATH, …)` повторно разрешает тот же pathname и исполняет уже другой объект. Это исполненный TOCTOU/подменный обход, а не повторно названный риск: прежняя граница допускает его предъявление только при исполненном обходе, который здесь получен.

## Позитивные контроли и прочие новые проверки якоря

Проба `node ../anchor-path-probe.mjs .omp/extensions/path-guard.ts /usr/bin/git` создала честный linked worktree и дала:

```json
{
  "unreadableFirst": {
    "rc": 0,
    "out": "{\"worktree\":\"/tmp/adv032-anchor-path-…/repo/wip-101-aa\"}",
    "err": ""
  },
  "shebangFakeFirst": {
    "rc": 0,
    "out": "{\"worktree\":\"/tmp/adv032-anchor-path-…/repo/wip-101-aa\"}",
    "err": ""
  },
  "noGit": {
    "rc": 2,
    "out": "",
    "err": "NOT_IMPLEMENTED: git отсутствует — git-оракул не может судить .git-форму (spawn ENOENT; PATH без git)"
  }
}
```

* Нечитаемый первый каталог `PATH` не вызывает fail-open: резолвер продолжает поиск и принимает честный `/usr/bin/git`.
* Shebang fake-git-first не ломает честный linked worktree: фильтр действительно его пропускает и находит настоящий Git дальше в PATH.
* Пустой кэш / PATH без git остаётся fail-closed: CLI rc 2 с `NOT_IMPLEMENTED`.
* `od -An -tx1 -N4 /usr/bin/git` дал `7f 45 4c 46`: настоящий Git на этой машине — ELF, не `#!`. Следовательно, положительные контроли не вечнокрасные именно из-за shebang-фильтра; проблема в том, что тот же признак принимают и произвольные злонамеренные ELF.

## Обязательные прогоны

В clone выполнено:

```text
bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .
→ rc 0; ИТОГ 032: ветвей 33, красных 0, зелёных 33

bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .
→ rc 0; ИТОГ 032: ветвей 33, красных 0, зелёных 33

bash fixtures/check_runner_hygiene/red_pin_allowlist.sh .
→ rc 0

bash fixtures/check_runner_hygiene/red_granica_nepin_pipe_tee.sh .
→ rc 0

bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh .
→ rc 0

bash scripts/verify_antiplacebo.sh . --scope check_runner_hygiene
→ rc 0; барьеров: 1 · фикстур: 40 · предъявлено красным повторным прогоном: 40

git diff --exit-code frozen/contracts/032/1 HEAD -- contracts/032-*.md
→ rc 0
```

Таким образом все классы k1–k3, пять B1-форм, multiline, канон, CRLF, lone-CR и shell fake-git-first проходят текущую 33-веточную приёмку; позитивные контроли подтверждают, что это не вечно-красный набор. Но оба неверных варианта якоря выше также проходят, поскольку приёмка не строит ни ELF fake-git-first, ни подмену pathname кэша после загрузки.

Требуемая стенограмма детектора в disposable-клоне:

```text
bash scripts/check_no_leak.sh --check /tmp/dev-harness-verify/adv-032-k4/repo
→ rc 1
ОТКАЗ: снимок отсутствует (/tmp/dev-harness-leak/4d025253/porcelain) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)
```

Это ожидаемый fail-closed без pre-spawn snapshot, не зелёный результат и не предмет данного FAIL.

## Маршрут

**FAIL: S-elf-git-first и S-cache-path-replace.** Не передавать предмет reviewer 032 и не объявлять финал корня 1 done. Автору нужно сделать происхождение исполняемого оракула действительно доверенным, а не выводить доверие из `isFile+x` и отсутствия shebang в контролируемом PATH; сохранённый путь также не должен быть подменяемым между проверкой и исполнением. Приёмка обязана добавить оба red-сценария через CLI и factory: (1) forged `.git` при первом в PATH ELF fake-git ожидает `null`/`block`; (2) первоначально честный cache pathname, заменённый после import перед первым oracle call, также ожидает `null`/`block`. Честный ELF `/usr/bin/git`, CRLF/CR/канон и отсутствие git должны остаться положительными/fail-closed контролями.

Живой omp-пункт по решению арбитра остаётся за владельцем и этим вердиктом не повышен до блокера.
