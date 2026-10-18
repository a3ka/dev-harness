FAIL
OBJECT=b2232780be1a87a21c8810f88879c181d0361a14

FAIL круга 1 закрыт для конкретных fd 3 (receipt) и 9 (lock), но не для другого
намеренно добавленного helper-fd. Также `lock_transition` не наблюдает отпускание
singleton lock между сессиями. Ниже — команды и сырой вывод.

## Положительный контроль

```text
cd /tmp/dev-harness-verify/adversary997r2/clone && bash fixtures/ops_server/orch_loop_997/probe.sh
...
997 observed=32 mismatches=0
...
MUTANT receipt_fd_leak caught=1 ... "errors": ["RECEIPT_FD"] ...
MUTANT lock_fd_leak caught=1 ... "errors": ["LOCK_FD"] ...
997 observed=60 mismatches=0
# rc=0
```

Первый итог — 32 запуска SUBJECT в `same` и `other` uid-путях. Второй — matrix:
32 запуска честной модели и 28 назначенных мутантов. В частности:

```text
SUBJECT {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "lock_transition", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
```

Таким образом положительный контроль не вечно-красный.

## Повтор мутаций круга 1

`fd_leak_probe.py` удаляет `exec 3>&-` в обеих uid-ветках и вызывает новую
`probe.py --cases`:

```text
SUBJECT {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["RECEIPT_FD"], ...}
SUBJECT {"case": "marker_removed", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["RECEIPT_FD"], ...}
997 observed=32 mismatches=24
FD_LEAK_CAUGHT
# wrapper rc=0: helper ожидает, что каноническая проба будет rc=1
```

`lock_leak_probe.py` удаляет `9>&-` в обеих uid-ветках:

```text
SUBJECT {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["LOCK_FD"], ...}
SUBJECT {"case": "marker_removed", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["LOCK_FD"], ...}
997 observed=32 mismatches=24
LOCK_LEAK_CAUGHT
# wrapper rc=0
```

Сырые полные terminal-выводы этих двух запусков: `artifact://600` и
`artifact://601` в стенограмме. Значит исходная находка закрыта в её точной
форме.

## Дефект 1: другой helper-fd проходит

В обеих uid-ветках внесена ровно эта мутация:

```text
3>/dev/fd/8 7<&- 8>&- 9>&-; rc=$?
→
3>/dev/fd/8 6</dev/null 7<&- 8>&- 9>&-; rc=$?
```

Это передаёт обычный fd 6 launcher'у, scope-shell и агенту. Каноническая проба
приняла плохой предмет во всех 32 входах, включая обе идентичности:

```text
=== regular_fd6_leak: rc=0 expected=1 ===
SUBJECT {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
...
SUBJECT {"case": "marker_removed", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
...
997 observed=32 mismatches=0
regular_fd6_leak: ESCAPED
```

Одноразовый audit-клон `probe.py` (файл в судимом репо не менялся) прямо прочитал
fd-table настоящего toy-агента:

```text
python3 /tmp/dev-harness-verify/adversary997r2/fd6_audit.py
SUBJECT {"case": "clean_exit", "identity": "same", "rc": 0, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": [], "agent_fd6": ["/dev/null"]}
997 observed=1 mismatches=0
FD6_LEAK_CONFIRMED
# rc=0
```

Причина: census отвергает fd 3, fd 9, pipe inode и 7/8, но принимает любой fd,
бывший при `scope_call` (`held - launch_fds`). Поэтому fd 6 не даёт ни одного
error. Это нарушает инв. 2: перед exec агента закрываются receipt, lock и
вспомогательные fd.

## Дефект 2: lock отпускается в переходе

Мутация добавляет одну строку между `reap_session` и restart-логикой:

```text
exec 9>&-
```

Она снимает singleton lock после session 1 до запуска session 2. Сценарий
`lock_transition` ставит blocking waiter при живой первой сессии, однако проверяет
лишь то, что waiter получил lock когда-нибудь к окончанию всего запуска. Мутант
прошёл:

```text
=== lock_released_between_sessions: rc=0 expected=1 ===
SUBJECT {"case": "lock_transition", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
997 observed=1 mismatches=0
lock_released_between_sessions: ESCAPED
```

Следовательно нейтрализация ровно lock-transition свойства не делает красным его
назначенный сценарий.

## Другие новые обманки

Дубликат receipt-pipe на fd 4 пойман по pipe inode, не только номеру 3:

```text
=== receipt_dup_fd4: rc=1 expected=1 ===
SUBJECT {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
997 observed=32 mismatches=24
receipt_dup_fd4: CAUGHT
```

И ограниченный по времени read ошибочно отвергает реально задержанный receipt;
`delayed_receipt` это ловит:

```text
=== receipt_read_timeout: rc=1 expected=1 ===
SUBJECT {"case": "delayed_receipt", "identity": "same", "rc": 1, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": ["EXIT_STATUS", "TRUTHFUL_SCOPE"], "output": "... cat: write error: Broken pipe\\n... запуск в scope не подтверждён ..."}
997 observed=1 mismatches=1
receipt_read_timeout: CAUGHT
```

Полный сырой вывод четырёх новых опытов сохранён в
`/tmp/dev-harness-verify/adversary997r2/new-deceptions/*.out`; terminal output —
`artifact://620`.

## Соседние барьеры

На честном OBJECT:

```text
bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast
итог 085 fast: красных=0
# rc=0

bash fixtures/ops_granica/red_limit_otkaz_bez_zapuska.sh
ЗЕЛЁНО(093-2): отказ scope → именованный отказ rc 1, воркшоп не исполнен (И-5)
# rc=0

bash fixtures/ops_server/red_server_obvjazka_074.sh
k5b: станция /home/harness/bin/orch-loop разошлась с пином
КРАСНО: cell_k5b
честная часть: 7/7 зелёная
стаб-пак: 7/7 поймано, диффпроба: 7/7
к1b-каналы: честные 6/6, ленивые пойманы 6/6
итог 074: красных клеток=1 стабы=7/7
# rc=1
```

074 красен только уже существующим station-pin `cell_k5b`; собственные честные
клетки, стабы и каналы зелёны. На fd6-мутанте 085 и 093 также зелёные:

```text
=== 085 fd6 mutation: rc=0 ===
итог 085 fast: красных=0
=== 093 fd6 mutation: rc=0 ===
ЗЕЛЁНО(093-2): отказ scope → именованный отказ rc 1, воркшоп не исполнен (И-5)
```

## Frozen и зона

Frozen-текст контракта неизменен:

```text
8c6f84716907142403a69d653b4659db0e7f6d6e83d3b135762f6c7ac5353006  -
8c6f84716907142403a69d653b4659db0e7f6d6e83d3b135762f6c7ac5353006  contracts/997-orch-loop-metka-perezapuska.md
```

Diff с frozen commit показывает ожидаемую реализационную дельту в
`fixtures/ops_server/orch_loop_997/backend.py` (+43) и `probe.py` (+81); contract
blob не менялся, но эта проба обновлена данным кругом.

`bash scripts/check_zones.sh .` напечатал:

```text
FAIL строка ЗОНА вне объявленной грамматики в contracts/055-izoljacija-sostojanija-po-projectid.md: «ЗОНА architect (до-заморозочная батарея по ДЕЙСТВУЮЩЕЙ заморозке каталога):» — у автора «architect (до-заморозочная батарея по ДЕЙСТВУЮЩЕЙ заморозке каталога)» не назван ни один путь
```

Это чужая историческая зона 055, не 997. Обёртка запустила долгую проверку фоном
и предварительно сообщила rc 0 несмотря на этот FAIL, поэтому не утверждаю rc зоны.
Полный вывод: `artifact://670` в стенограмме.

## Требуемая правка

1. Census должен отвергать любой созданный/переданный helper-fd, включая regular
   fd с не-pipe target; нужен назначенный мутант `6</dev/null` и положительный
   контроль.
2. `lock_transition` должен наблюдать момент владения: waiter не может получить
   lock до второго agent_start либо окончательного выхода цикла. Мутант `exec 9>&-`
   между `reap_session` и restart обязан быть красным именно здесь.
