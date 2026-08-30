FAIL

# Адверсарий 016 — второй перегон суда исправлений раунда 2

Проверен HEAD `f655245` в `/home/aka/Documents/dev-harness`. Прежний `FAIL`
`e344421` сохранён в истории; этот файл — новый самостоятельный прогон после
`926e5fd` (scripts) и `07e0bd9` (кейсы/пробы/стабы).

## Таймлайн и исходные находки раунда 2

1. **`fake-python3-exit-1`: закрыта на своём исходном входе.** В новом
   `/tmp/adversary016_round2_replay.sh` собран замороженный toy-репозиторий с
   control-символом в staged-пути внутри зоны и `PATH`, в котором `python3`
   является `exit 1` стабом. `scripts/check_staged.sh` вернул `rc=1` с
   именованной причиной `канарейка не подтверждена`.
2. **`inert-heredoc-hook`: закрыта на своём исходном входе.** В новом toy
   механизме `pre-commit` содержит только heredoc с
   `scripts/check_staged.sh` и `exit 0`. `scripts/check_hooks.sh` вернул
   `rc=1` с именованной причиной `поведенческая проба связи`.
3. Положительные контроли не вечно-красные: перед новой python-атакой честный
   системный `python3` вернул `rc=1` с `имя с control-символом` на том же
   staged-пути; честный минимальный hook-механизм вернул `rc=0` от
   `scripts/check_hooks.sh`.

Следовательно, две **конкретные** находки раунда 2 закрыты, но исправления
по-прежнему обходятся новыми неверными реализациями ниже.

## Новые проходящие неверные реализации

### `python3-canary-input-split` — обход само-канарейки

**Прогон:** `bash /tmp/adversary016_round2_replay.sh`

Подменённый исполняемый `python3` читает stdin и воспроизводит ровно оба
открытых в коде канарейочных ответа: для `a\nb` печатает `1` и выходит `0`,
для `clean` печатает `0` и выходит `1`. Для любого иного ввода он лжёт
`0`/`1`, то есть объявляет чистым реальный staged-путь с переносом строки.
Аргумент `-c` у канарейки и главного цикла одинаков; разделителем служит
публичный фиксированный payload самой канарейки.

Результат прогона:

```text
BYPASS python3-canary-input-split checker_rc=0 (staged control name accepted)
```

Это неправильная реализация: имя с control-символом внутри `scripts/`
принято зелёным, хотя честный положительный контроль на идентичном входе
красный. Само-канарейка проверяет два известных примера, но не удостоверяет
исполнительный инструмент на проверяемом payload.

### `hook-toy-environment-sniffer` — ложная связь, честная только в toy пробы

**Прогон:** `bash /tmp/adversary016_round2_replay.sh`

Подменённый `pre-commit` ищет предсказуемый рабочий каталог
`/tmp/check-hooks-toy.*`. Только там он печатает поддельную именованную
причину `имя с control-символом` и выходит `1`; в любом обычном каталоге он
не запускает судью и выходит `0`. Неисполняемая строка после `exit 0`
содержит `scripts/check_staged.sh` лишь для текстовой ветви.

```text
BYPASS hook-toy-environment-sniffer checker_rc=0 real-staged-hook_rc=0
```

`check_hooks.sh` принял механизм (`rc=0`), хотя тот же хук в toy-репозитории
с реально staged control-именем вернул `rc=0`. Поведенческая проба доверяет
предсказуемой среде и не доказывает связь за её пределами.

### `hook-forged-judge-output` — именованный rc≠0 без вызова судьи

**Прогон:** `bash /tmp/adversary016_round2_replay.sh`

Другой `pre-commit` всегда печатает `ОТКАЗ: имя с control-символом: forged
constant response` и выходит `1`; до неисполняемой строки с
`scripts/check_staged.sh` он не доходит. Проверка приняла его:

```text
BYPASS hook-forged-judge-output checker_rc=0 no-judge-invocation
```

Это не судья и не рабочая связь: хук гарантированно блокирует также чистые
коммиты, а требуемая строка вывода может быть сконструирована обёрткой.
Текущая проба проверяет лишь `rc≠0` и совпадение с открытым шаблоном текста,
не происхождение отказа от скопированного судьи.

## Что прогнано на живом дереве

Все команды ниже завершились `rc=0` на `f655245`:

```text
bash scripts/verify_antiplacebo.sh . --scope check_staged             # 5/5
bash scripts/verify_antiplacebo.sh . --scope check_hooks              # 5/5
bash scripts/verify_antiplacebo.sh . --scope spawn_agent              # 1/1
bash scripts/verify_antiplacebo.sh . --scope land_agent               # 8/8
bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches        # 2/2
bash scripts/verify_antiplacebo.sh . --scope check_zones              # 13/13
bash scripts/verify_antiplacebo.sh . --scope check_contract_frozen    # 6/6
bash fixtures/check_staged/probe_check_staged_krasnyj.sh
bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh
```

Scoped `check_staged` подтвердил также старые входы PATH без `python3`,
control-имя и обе формы `fake_python3_exit_{0,1}`; scoped `check_hooks`
подтвердил комментарий-хук и `inert_heredoc_hook`. Пробы подтвердили честные
стабы и поимённо поймали `канарейка-слеп` и `проба-слеп`.

## Вердикт

**FAIL.** Первичные две находки закрыты только против их известных форм.
Новые запуски предъявляют три неверные реализации, которые проходят текущую
проверку: `python3-canary-input-split`, `hook-toy-environment-sniffer` и
`hook-forged-judge-output`.
