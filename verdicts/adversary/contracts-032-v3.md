# FAIL — adversary 032, круг 3: git-оракул

Предмет судился в disposable-клоне `/tmp/dev-harness-verify/adv-032-k3/repo`, HEAD `2777def`. Корень 1 **не закрыт**: git-оракул fail-open, если первым в унаследованном `PATH` стоит поддельный `git`.

Граница арбитра соблюдена: красный живой пункт «команда 1 succeeded» не требовался и не использовался как блокер этого круга. Он остаётся предметом omp-транспорта/слова владельца. Этот FAIL независим от него и относится только к оракулу корня 1.

## Блокер S-path-fake-git-first

`gitOracle()` в `.omp/extensions/path-guard.ts` строит новый `env`, но копирует в него `process.env.PATH`, затем вызывает голое имя:

```ts
spawnSync('git', ['-C', p, 'rev-parse', '--absolute-git-dir'], { env, ... })
```

Следовательно, санирование `GIT_DIR`-семейства не аутентифицирует сам оракул. Поддельный исполняемый `git`, расположенный первым в `PATH`, печатает существующий каталог и завершает работу с rc 0. Единственные проверки после spawn — rc 0, непустой stdout и `statSync(stdout)`, поэтому поддельный ответ принимается за verdict Git.

Выполнен disposable probe:

```text
node /tmp/dev-harness-verify/adv-032-k3/oracle-adversary.mjs .
```

Он создаёт каталог `.../forged/wip-101-aa` с регулярным `.git`, содержащим ровно `not a gitfile\n`; такой кандидат не является Git worktree. Затем кладёт в отдельный `fake-bin/git` скрипт `printf '<существующий tmp-dir>\n'; exit 0` и запускает subject с `PATH=fake-bin:$PATH`.

Фактический результат:

```json
"fakeGitFirstOnMalformedDotGit": {
  "cli": {
    "rc": 0,
    "out": "{\"worktree\":\"/tmp/adv032-oracle-…/forged/wip-101-aa\"}",
    "err": ""
  },
  "factory": "pass"
}
```

То есть обход проходит обе обязательные поверхности: CLI возвращает ложный pin вместо `null`, а настоящий factory seam (`register()` → `session_start` с assignment → `tool_call write` внутри forged-кандидата) возвращает `pass` вместо `block`. Это именно требуемый класс «инструмент мимо PATH», а не отсутствие инструмента: существующий, злонамеренный executable подменяет ответ оракула. Нынешний п4н проверяет только `PATH` без `git`; он не различает честный Git и false-success Git, поэтому вся приёмка остаётся зелёной против этой неправильной реализации.

Маршрут за автором: Git должен разрешаться из доверенного абсолютного пути, независимого от входного `PATH` (или быть эквивалентно аутентифицирован до вызова); нужно добавить в red-приёмку fake-git-first с malformed `.git` через **CLI и factory**, ожидая соответственно `null` и `block`. Пока это не сделано, ACCEPT невозможен.

## Позитивный контроль и остальные атаки

Проба построила честный toy-репозиторий с настоящим linked worktree. Без инъекции CLI вернул его non-null pin, а с одновременно поданными `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE`, `GIT_OBJECT_DIRECTORY`, `GIT_ALTERNATE_OBJECT_DIRECTORIES`, `GIT_CEILING_DIRECTORIES`, `GIT_CONFIG_GLOBAL` и `GIT_CONFIG_SYSTEM` — тот же non-null pin. Это подтверждает, что перечисленные снятые/перезаписанные переменные не сломали честный путь.

Дополнительно в forged-кандидат подавались выжившие `GIT_COMMON_DIR` и `GIT_CONFIG_COUNT/GIT_CONFIG_KEY_0/GIT_CONFIG_VALUE_0` вместе с перечисленной инъекцией. При настоящем Git результат был `{"worktree":null}`: этой проверенной env-инъекции bypass не найден.

Кандидат, чьё имя пути действительно содержит перевод строки, вернул `{"worktree":null}`: token grammar не позволяет переносу строки войти в значение `WORKTREE`.

Симлинк-кандидат на настоящий linked worktree был принят CLI как pin, но фабрика затем заблокировала write через тот же символьный путь, потому что `judge()` канонизирует pin в physical path, а `pathAllowed()` сравнивает его с лексическим alias-путём. Это fail-closed несовпадение положительного alias-ввода, а не найденный fail-open и не блокер при явно незафиксированной норме симлинк-путей.

TOCTOU между предварительным `statSync(<candidate>/.git)` и `spawnSync()` намеренно не исполнялся на живой ФС. Подмена `.git` до spawn сама по себе не обманывает доверенный Git: Git читает состояние на момент spawn. Однако нет устойчивого дескриптора/постаутентификационной привязки, поэтому локальный конкурент, способный подменять путь после успешного Git-verdict до следующего `judge()`, остаётся отдельным post-validation race-классом; это оценка риска, не воспроизведённый блокер данного круга.

Сетевого mount в disposable среде нет (`findmnt -n -o FSTYPE,SOURCE -T /tmp` → `tmpfs tmpfs`), поэтому живой сетевой путь не симулировался. Оракул обращается с монтированным путём как с обычным POSIX-путём; отдельного сетевого транспорта он не открывает.

## Обязательные прогоны

```text
bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .
→ rc 0; ИТОГ 032: ветвей 30, красных 0, зелёных 30

bash fixtures/check_runner_hygiene/red_pin_allowlist.sh .
bash fixtures/check_runner_hygiene/red_granica_nepin_pipe_tee.sh .
bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh .
→ все rc 0

bash scripts/verify_antiplacebo.sh . --scope check_runner_hygiene
→ rc 0; барьеров: 1 · фикстур: 40 · предъявлено красным повторным прогоном: 40

git diff --exit-code frozen/contracts/032/1 HEAD -- contracts/032-*.md
→ rc 0
```

Позитивный контроль тем самым зелёный: набор не вечно-красный и прежние B1/A1 формы, канон, CRLF и lone-CR проходят в текущей 30-веточной приемке. Именно поэтому fake-git-first — дефект проверки/реализации, а не шум.

Требуемая стенограмма детектора на disposable-клоне:

```text
bash scripts/check_no_leak.sh --check /tmp/dev-harness-verify/adv-032-k3/repo
→ rc 1
ОТКАЗ: снимок отсутствует (/tmp/dev-harness-leak/50bde143/porcelain) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)
```

Это ожидаемый fail-closed для нового абсолютного корня без pre-spawn snapshot; не засчитано как зелёный результат.

## Итог

**FAIL: S-path-fake-git-first.** Не передавать предмет reviewer 032 и не объявлять финал корня 1 done, пока не закрыт обход и не предъявлена обновлённая приёмка против fake-git-first. Живой omp-пункт по решению арбитра не добавлен к этому вердикту как блокер и остаётся за владельцем.
