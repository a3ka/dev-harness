FAIL

# Адверсарий 016 — суд исправлений

Проверен HEAD `b7ee5c5` в `/home/aka/Documents/dev-harness`. Три исходные
находки закрыты: каждый прежний вход теперь получает `rc=1` с именованной
причиной. Однако две новые проходящие неверные реализации остаются: судья
staged-путей доверяет подменённому `python3`, а судья хука считает текст в
heredoc исполняемой связью. Поэтому приёмка не закрыта.

## Исходная находка 1 — `registry-substring`: закрыта

Свой заново собранный вход из первого круга: в реестре замороженного
контракта только `implementer`, а единственный коммит диапазона имеет
`author == committer == imple`. Выполнено:

```text
$ bash /tmp/adversary016_original_repros.sh
ok registry-substring rc=1
```

`land_agent.sh` отказал именно с `имя вне реестра ролей`. Это проверяет
прежнюю уязвимую пару `imple` / `implementer`; приземления и удаления ветки
не произошло.

Дополнительные попытки обойти `grep -qxF` также закрыты: коммиттер без
ведущего пробела против реестра ` implementer`, без хвостового пробела против
`implementer ` и decomposed `e\u0301` против composed `é` получили `rc=1`
с той же именованной причиной. Пустое имя не дошло до барьера: Git отверг
создание коммита с `rc=128` (`empty ident`).

```text
$ bash /tmp/adversary016_registry_edges.sh
ok leading-space rc=1
ok trailing-space rc=1
ok unicode-normalization rc=1
$ bash /tmp/adversary016_empty_name.sh
ok empty-name rejected by git rc=128
```

Новая фикстура также предъявляет положительный контроль до порчи и красный
повтором: `land_agent/case_imja_podstroka_reestra.sh` зелёная в scoped
прогоне ниже.

## Исходная находка 2 — `missing-python-control-name`: закрыта, но есть новая обходная ветвь

Свой прежний вход — staged имя `scripts/valid\ncontrol` внутри зоны при PATH
без `python3` — теперь получает `rc=1` и `python3 отсутствует`:

```text
$ bash /tmp/adversary016_original_repros.sh
ok missing-python-control-name rc=1
```

Новая фикстура `case_imja_control_simvol_bez_python3.sh` в scoped прогоне
также предъявляет зелёный пустой staged до порчи и красный повтором.

### Новая находка — `fake-python3-exit-1`

**Проходящий стаб.** В toy-репозитории сначала честный системный `python3`
ловит тот же staged-путь с control-символом (`rc=1`, `имя с
control-символом`). Затем в изолированном PATH вместо Python поставлен
исполняемый кодовый стаб:

```sh
#!/bin/sh
exit 1
```

`command -v python3` проходит. Вызов `printf '%s' "$f" | python3 -c ...`
возвращает 1; текущий `if` трактует это как «control-символа нет», хотя код
проверки не исполнялся. Путь находится в зоне, и барьер неверно зелёный:

```text
$ bash /tmp/adversary016_fixed_bypasses.sh
ok fake-python3-zero rc=1
BYPASS fake-python3-exit-1 checker_rc=0
```

Для требуемой попытки с 0-rc стабом тот же прогон корректно красный
(`ok fake-python3-zero rc=1`): он ложно сигнализирует найденный control-символ,
но не открывает проход. Обход открывает именно отказ инструмента с `rc=1`,
который неотличим от предусмотренного текущей программой ответа «чистое имя».
Это снова нарушает И-2: судья объявляет «нарушений нет», не выполнив
грамматическую проверку.

## Исходная находка 3 — `inert-comment-hook`: закрыта, но есть новая обходная ветвь

Свой прежний no-op hook с единственным литералом в строке комментария теперь
получает `rc=1` и `комментарий не считается связью`:

```text
$ bash /tmp/adversary016_original_repros.sh
ok inert-comment-hook rc=1
```

Новая `case_huk_kommentarij_vmesto_zapuska.sh` предъявляет этот же красный
повтор после положительного контроля в scoped прогоне.

### Новая находка — `inert-heredoc-hook`

**Положительный контроль и проходящий стаб.** Сначала полный честный механизм
из `fixtures/check_hooks/_mehanizm.sh` успешно прошёл `check_hooks.sh`. Затем
`.githooks/pre-commit` заменён исполняемым кодовым стабом:

```bash
#!/usr/bin/env bash
: <<'JUDGE_TEXT'
scripts/check_staged.sh
JUDGE_TEXT
exit 0
```

Сам `scripts/check_staged.sh` одновременно заменён исполняемым `exit 97`.
Запуск этого pre-commit вернул `rc=0`, то есть судья реально не запускается.
Но `awk` увидел литерал в не-комментарной строке тела heredoc и
`check_hooks.sh` тоже вернул `rc=0`:

```text
$ bash /tmp/adversary016_fixed_bypasses.sh
BYPASS inert-heredoc-hook checker_rc=0 hook_rc=0
```

Следовательно, условие «не комментарий» не доказывает исполняемую связь:
та же ложная связь может быть строковой переменной, аргументом no-op или
данными heredoc. Это прямой обход Q6: no-op pre-commit принимается как
механизм, хотя staged-судья не запускается.

## Что прогнано на живом дереве

Все команды ниже завершились `rc=0` на HEAD `b7ee5c5`:

```text
bash scripts/verify_antiplacebo.sh . --scope check_staged             # 3/3
bash scripts/verify_antiplacebo.sh . --scope check_hooks              # 4/4
bash scripts/verify_antiplacebo.sh . --scope spawn_agent              # 1/1
bash scripts/verify_antiplacebo.sh . --scope land_agent               # 8/8
bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches        # 2/2
bash scripts/verify_antiplacebo.sh . --scope check_zones              # 13/13
bash scripts/verify_antiplacebo.sh . --scope check_contract_frozen    # 6/6

bash fixtures/check_staged/probe_check_staged_krasnyj.sh
bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh
```

Обе пробы подтвердили честные стабы, поимённо поймали свои декои и затем
прошли на живом дереве. Их зелёный результат не ловит две новые формы,
описанные выше.

Вердикт: **FAIL**. Для закрытия нужны fail-closed протокол результата
проверки control-символов (отдельный успешный код для «чисто», все сбои
инструмента — отказ) и проверка реального исполняемого вызова staged-судьи,
а не поиск литерала на не-комментарной строке.
