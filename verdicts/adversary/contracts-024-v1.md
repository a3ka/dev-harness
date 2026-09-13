FAIL

# Адверсарий: контракт 024, круг 4

Судимая база: `main` `0f7e056c1741f51d650899bc8aad32528c6cfb64`.
Проверены заявленные фиксы `3bd1880` и `1dd718e`: они действительно пинят
`git`, `sha256sum`, `sort`, `comm`, `mkdir`, `mktemp`, `stat`, `chmod`, `mv`,
`cat`, `head`, `grep`, `rm`, а затем и `tail` через
`PATH="$TRUSTED_PATH" command -v`; verify-строка стала обязательной.

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза
контракта; контракт несёт инварианты + rc-команды». Все атаки выполнены только
в одноразовом клоне и toy-репозиториях под
`/tmp/dev-harness-verify/adv024k4-eskKVe/`; основной checkout не мутировался
этими атаками.

## Все пять контрпримеров к2+к3 закрыты

Прямой повтор против текущего `scripts/check_no_leak.sh` дал именно rc 1 с
именованной причиной, а не rc 0 «основной чекаут чист»:

| Контрпример | Результат текущего детектора |
|---|---|
| `S-path-forged-sha256` | rc 1, назван `S-path-forged-sha256` |
| `S-external-snapshot-symlink` | rc 1, `ОТКАЗ: снимок — симлинк` |
| `S-path-fake-git-clean` | rc 1, назван `S-path-fake-git-clean` |
| `S-path-fake-comm-clean` | rc 1, назван `S-path-fake-comm-clean` |
| `S-mv-replace-no-verify` | rc 1, `verify-строка отсутствует` |

Это воспроизводилось скриптом
`/tmp/dev-harness-verify/adv024k4-eskKVe/replay_024.sh` (прямой вывод:
`ok S-path-forged-sha256`, `ok S-external-snapshot-symlink`,
`ok S-path-fake-git-clean`, `ok S-path-fake-comm-clean`,
`ok S-mv-replace-no-verify`). Кроме того,
`bash fixtures/check_judge_gate/red_path_fake_utilit_024.sh` дал rc 0:
честный контроль и все 15 ветвей параметризованной PATH-подмены не получили
ложного «чисто»; закрыты в том числе git/sort/comm/head/tail/cat/grep/stat и
no-verify.

## Блокер 1 — `S-bashenv-command-function`: `BASH_ENV` подменяет builtin `command` до TRUSTED_PATH-резолва

Пин реализован выражениями вида:

```bash
GIT="$(PATH="$TRUSTED_PATH" command -v git)"
```

Но `BASH_ENV` исполняется bash до тела `check_no_leak.sh` и может определить
функцию shell с именем `command`. Присваивание `PATH=...` не обходит функцию:
она подменяет именно поиск пиннутого абсолютного пути. Это не третий экземпляр
PATH-подмены: ложный бинарь не найден через порядок `PATH`; инъекция стартовой
среды заменяет shell builtin, которым реализован сам пин.

Атака: BASH_ENV содержал:

```bash
command() {
  if [ "$1" = -v ] && [ "$2" = git ]; then
    printf '%s\n' /tmp/dev-harness-verify/adv024k4-eskKVe/bebe/bin/git
  else
    builtin command "$@"
  fi
}
```

`bebe/bin/git` — фейк `exit 0`. После снимка toy-репозитория добавлен
untracked `leak`. С тем же `BASH_ENV`:

```text
BASH_ENV=... TMPDIR=... bash scripts/check_no_leak.sh --check .../toy
основной чекаут чист
# rc=0
```

Функция вернула путь фейка и для предварительной проверки `command -v git`, и
для supposedly trusted lookup. Фейк возвращал rc 0 для `rev-parse` и `status`,
поэтому оба манифеста пусты; действительный `leak` на диске не назван.

**Позитивный контроль той же формы.** С тем же snapshot и тем же toy, но
`env -u BASH_ENV`, текущий бинарь дал:

```text
ОТКАЗ: основной чекаут загрязнён: leak
# rc=1
```

Следовательно, это не общее повреждение входа, а обход через стартовую среду
bash. Детектор обязан запускаться в санитизированной shell-среде либо до
резолва сбрасывать/запрещать импортируемые функции и `BASH_ENV`; одного
`PATH="$TRUSTED_PATH" command -v` недостаточно.

## Блокер 2 — `S-git-dir-work-tree-injection`: `GIT_DIR`/`GIT_WORK_TREE` перенаправляют все пиннутые git-вызовы в чистой соседний репозиторий

Абсолютный `$GIT` не гарантирует, что Git исследует `$CANON`. Скрипт не очищает
`GIT_DIR` и `GIT_WORK_TREE`. Созданы два честных репозитория: `victim` (аргумент
детектора) и чистый `clean`. На snapshot и check окружение было:

```text
GIT_DIR=.../clean/.git
GIT_WORK_TREE=.../clean
TMPDIR=.../snap
```

`git -C .../victim rev-parse --git-dir` при этом проходит, но `git status`
получает porcelain чистого `clean`; после snapshot в `victim` добавлен
`S-git-dir-work-tree-injection`. Проверка дала:

```text
основной чекаут чист
# rc=0
```

То есть `$CANON` определяет ключ snapshot, но не репозиторий, который фактически
исследуют все `$GIT -C "$CANON" ...` вызовы. Это отдельный класс семантики Git/
окружения, не PATH-подмена.

**Позитивный контроль той же формы.** На ровно том же snapshot и victim, но с
`env -u GIT_DIR -u GIT_WORK_TREE`, результат:

```text
ОТКАЗ: основной чекаут загрязнён: S-git-dir-work-tree-injection
# rc=1
```

Детектор обязан изолировать git-вызовы от `GIT_DIR`, `GIT_WORK_TREE` (а также
проверить прочие переменные, меняющие семантику Git) или явно запускать Git с
санитизированным окружением. Пин пути к исполняемому файлу не изолирует Git от
его входного окружения.

## Приёмочные наблюдения

- `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` → rc 0.
- `bash scripts/check_contract_frozen.sh` → rc 0.
- `bash fixtures/check_judge_gate/probe_slabyh_detektora.sh` → rc 0 (18 ворот,
  честная форма и плацебо-проверка зелёные).
- `bash fixtures/check_judge_gate/red_path_fake_utilit_024.sh` → rc 0.
- Требуемая команда
  `git -C /home/aka/Documents/dev-harness diff --exit-code frozen/contracts/024/2..HEAD -- fixtures/check_judge_gate/`
  **не прошла: rc 1**, выводит изменения
  `fixtures/check_judge_gate/red_detektor_utechek.sh` и
  `fixtures/check_judge_gate/red_path_fake_utilit_024.sh` (407 additions,
  24 deletions). Это зафиксированное состояние судимой базы; адверсарий
  замороженные фикстуры не правил.

Вердикт `FAIL` обусловлен двумя воспроизводимыми ложными rc 0 с независимыми
положительными контролями. Не применять кап «ПОВТОР КЛАССА: PATH-подмена,
экземпляр 3»: обе находки обходят PATH-пин без третьей подмены утилиты через
PATH.
