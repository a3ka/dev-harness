FAIL

# Адверсарий 016 — приёмка зелёная, предмет пробит

Проверен HEAD `7751352` в `/home/aka/Documents/dev-harness`. Найдены три
проходящих неверных состояния. Первое — прямое нарушение И-9 в
`land_agent.sh`; два остальных показывают, что `check_staged.sh` и
`check_hooks.sh` считают отказ/декларацию успехом. Поэтому зелёный scoped
набор не является достаточной приёмкой пачки.

## Находка 1 — `registry-substring`: имя вне реестра проходит приземление

**Вход.** В `/tmp/adversary016-registry.*` собран toy-репозиторий штатным
`fixtures/land_agent/_repo.sh`: единственная ЗОНА замороженного контракта
объявляет только `implementer`. Создана `wip/001/imple`, в её диапазоне
один коммит с парой `author == committer == imple`. `imple` не является
автором ЗОНА-строки; это только подстрока `implementer`.

**Почему неверно.** И-9 требует точного членства committer в реестре ролей
и отказа до merge: «имя вне реестра ролей». Здесь агент самообъявился
необъявленным именем и был приземлён.

**Почему проходит.** В `scripts/land_agent.sh` членство проверяется
шаблоном shell:

```sh
case "$author_set" in
  *$'\n'"$cn"$'\n'*|*"$cn"*) ;;
```

Вторая альтернатива — не сравнение строк, а подстрочный матч. Для `cn=imple`
она совпадает с `implementer`.

**Прогон (rc=0, то есть проходящий стаб).**

```text
$ bash /tmp/adversary016_registry_substring.sh
registry=implementer: scripts/
committer=imple
Deleted branch wip/001/imple (was d7f9d0d).
LANDED main=3ff4d8a2bba3577915e1ad76ae05607c86ae65be branch=wip/001/imple
```

Это не именованная граница cognitive-only: она прямо противоречит
наблюдаемой сцепке+реестру И-9 и её rc-команде `--scope land_agent`.
Существующая `case_imja_vne_reestra.sh` пробует имя, не являющееся
подстрокой реестра, поэтому этот вход не покрывает.

## Находка 2 — `missing-python-control-name`: отказ инструмента выглядит успехом

**Вход.** В `/tmp/adversary016-python.*` штатным
`fixtures/check_staged/_repo.sh` создан toy-репозиторий с локальным
`user.name=implementer` и замороженной зоной `scripts/`. В индекс добавлен
`$'scripts/valid\ncontrol.sh'`: control-символ находится *внутри* разрешённой
зоны. Затем `check_staged.sh` исполнен с `PATH`, где есть все нужные ему
утилиты и `git`, но заведомо нет `python3`.

**Почему неверно.** И-2 требует отказа для control-символа в имени
независимо от зоны. Отсутствие инструмента не является чистым staged-входом
и не может означать, что нарушения не найдены.

**Почему проходит.** Внутри `if` отказ `python3` (127) трактуется как
ложный результат грамматической проверки, после чего путь успешно проходит
`zones_match_path`; `set -o pipefail` лишь делает условие ложным, но не
переводит скрипт в fail-closed.

**Прогон (rc=0, то есть проходящий стаб).**

```text
$ bash /tmp/adversary016_missing_python.sh
rc=0
stdout:
scripts/
ok: staged в зоне автора implementer (1 путь/путей)
stderr:
.../scripts/check_staged.sh: line 104: python3: command not found
```

`case_imja_control_simvol.sh` проверяет тот же смысловой вход только в
окружении с установленным `python3`; сценария «судья не может выполнить
свою проверку» нет.

## Находка 3 — `inert-comment-hook`: текст в комментарии принимается за механизм

**Вход.** В `/tmp/adversary016-hook.*` штатный
`fixtures/check_hooks/_mehanizm.sh` создаёт полный toy-механизм. Затем
`.githooks/pre-commit` заменён исполняемым no-op:

```bash
#!/usr/bin/env bash
# scripts/check_staged.sh
exit 0
```

`package.json` всё ещё назначает `.githooks`, а файл судьи существует.

**Почему неверно.** Реально установленный pre-commit никогда не запускает
судью staged-множества. Это ровно отсутствие требуемой связи
`.githooks/pre-commit → scripts/check_staged.sh`, а не объявленный
cognitive-only предел неустановленного хука.

**Почему проходит.** `check_hooks.sh` ищет не исполняемый вызов, а любую
подстроку `scripts/check_staged.sh` через `grep`; комментарий удовлетворяет
этому условию.

**Прогон (rc=0, то есть проходящий стаб).**

```text
$ bash /tmp/adversary016_inert_hook.sh
ok: механизм установки хука цел (.githooks/pre-commit → scripts/check_staged.sh; package.json → core.hooksPath)
hook runtime: rc=0
```

Существующая `case_huk_ne_vedet_k_sude.sh` удаляет/меняет строку ссылки;
она не отличает комментарий от запускаемого пути.

## Положительный контроль

Честный минимальный случай landing с точным зарегистрированным
`implementer` выполнен отдельно, а не выведен из красных проб:

```text
$ bash /tmp/adversary016_land_positive.sh
Deleted branch wip/001/implementer (was 953a7d8).
LANDED main=084a5c381db3daeaac9d6e56277a0166ec911ec0 branch=wip/001/implementer
```

Он завершился rc=0. Следовательно, находка 1 не является шумом от
вечно-красного `land_agent`.

## Таймлайн и живые прогоны

1. Прочитаны контракт 016, реализации `check_staged`, `check_hooks`,
   `lib_zones`, `spawn_agent`, `land_agent`, `gc_agent_branches`, и
   каркасы/кейсы затронутых фикстур.
2. Исполнены три изолированных стуба выше; каждый использует код из HEAD,
   не меняет дерево предмета и даёт rc=0 при неверном состоянии.
3. Scoped приёмка на живом дереве всё же зелёная (rc=0):

```text
bash scripts/verify_antiplacebo.sh . --scope check_staged             # 2/2
bash scripts/verify_antiplacebo.sh . --scope check_hooks              # 3/3
bash scripts/verify_antiplacebo.sh . --scope spawn_agent              # 1/1
bash scripts/verify_antiplacebo.sh . --scope land_agent               # 7/7
bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches        # 2/2
bash scripts/verify_antiplacebo.sh . --scope check_zones              # 13/13
bash scripts/verify_antiplacebo.sh . --scope check_contract_frozen    # 6/6
```

4. Frozen-неизменность объявленно frozen-барьеров проверена:

```text
$ git diff --name-status frozen/contracts/016/2 HEAD -- \
    scripts/check_zones.sh scripts/check_contract_frozen.sh
# вывода нет
```

5. И-9 конфиг-условие живого дерева также соблюдено:

```text
$ git config --local --get user.name
# вывода нет; проверка пустоты завершилась rc=0
```

Вердикт: **FAIL**. Автору нужно сделать проверку реестра точным
сравнением строк, обработать невозможность `python3` fail-closed и
проверять хук как исполняемую связь с судьёй, а не присутствие литерала.
