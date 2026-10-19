accept
OBJECT=64768e1653643dad186b18e5634f748166631241

Круг 3: дефекты adversary круга 2 воспроизведённо закрыты. Нового обхода
принятых требований 997 не найдено. Запуски были только в одноразовом клоне
`/tmp/dev-harness-verify/adversary997r3/clone` на указанном OBJECT.

## Положительный контроль предмета

Команда:

```text
bash fixtures/ops_server/orch_loop_997/probe.sh --cases
# rc=0
```

Сырой итог (все 34 строки SUBJECT — без ошибок):

```text
SUBJECT {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "removed_crash", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "removed_crash_1", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "removed_crash_137", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "scope_refused", "identity": "same", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 1, "errors": []}
SUBJECT {"case": "scope_refused_137", "identity": "same", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 1, "errors": []}
SUBJECT {"case": "second_refused", "identity": "same", "rc": 1, "second_rc": null, "starts": 1, "scope_calls": 2, "errors": []}
SUBJECT {"case": "duplicate", "identity": "same", "rc": 0, "second_rc": 1, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "duplicate_mark", "identity": "same", "rc": 0, "second_rc": 1, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "duplicate_log", "identity": "same", "rc": 0, "second_rc": 1, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "lock_held", "identity": "same", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 0, "errors": []}
SUBJECT {"case": "lock_before_update", "identity": "same", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 0, "errors": []}
SUBJECT {"case": "bounded", "identity": "same", "rc": 3, "second_rc": null, "starts": 3, "scope_calls": 3, "errors": []}
SUBJECT {"case": "clean_exit", "identity": "same", "rc": 0, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "lock_transition", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "delayed_receipt", "identity": "same", "rc": 0, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "lock_after_death", "identity": "same", "rc": -9, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "marker_removed", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "removed_crash", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "removed_crash_1", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "removed_crash_137", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "scope_refused", "identity": "other", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 1, "errors": []}
SUBJECT {"case": "scope_refused_137", "identity": "other", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 1, "errors": []}
SUBJECT {"case": "second_refused", "identity": "other", "rc": 1, "second_rc": null, "starts": 1, "scope_calls": 2, "errors": []}
SUBJECT {"case": "duplicate", "identity": "other", "rc": 0, "second_rc": 1, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "duplicate_mark", "identity": "other", "rc": 0, "second_rc": 1, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "duplicate_log", "identity": "other", "rc": 0, "second_rc": 1, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "lock_held", "identity": "other", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 0, "errors": []}
SUBJECT {"case": "lock_before_update", "identity": "other", "rc": 1, "second_rc": null, "starts": 0, "scope_calls": 0, "errors": []}
SUBJECT {"case": "bounded", "identity": "other", "rc": 3, "second_rc": null, "starts": 3, "scope_calls": 3, "errors": []}
SUBJECT {"case": "clean_exit", "identity": "other", "rc": 0, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "lock_transition", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": []}
SUBJECT {"case": "delayed_receipt", "identity": "other", "rc": 0, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": []}
SUBJECT {"case": "lock_after_death", "identity": "other", "rc": -9, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": []}
997 observed=34 mismatches=0
```

Это положительный контроль: корректная реализация проходит и для same, и для
other uid; следовательно матрица не является вечно-красной.

## Повтор мутаций круга 2 и новые обманки того же класса

Команда:

```text
bash fixtures/ops_server/orch_loop_997/probe.sh --matrix
# rc=0
```

Сырой итог матрицы:

```text
997 observed=85 mismatches=0
```

В эти 85 исполнений входят 34 зелёных запуска честной модели (17 сценариев ×
2 identity) и 51 назначенная обманка; каждая строка мутанта имеет `caught=1`.
Полный сырой stdout: `/tmp/dev-harness-verify/adversary997r3/matrix.out`.
Ниже — сырые строки именно новых и закрывающих мутаций.

```text
MUTANT receipt_fd_leak caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT receipt_fd_leak caught=1 {"case": "marker_removed", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT lock_fd_leak caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT lock_fd_leak caught=1 {"case": "marker_removed", "identity": "other", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT lock_released_between caught=1 {"case": "lock_transition", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["LOCK_TRANSITION"], ...}
MUTANT orphan_watcher_lock caught=1 {"case": "lock_after_death", "identity": "same", "rc": -9, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": ["LOCK_AFTER_DEATH"], ...}
MUTANT read_timeout caught=1 {"case": "delayed_receipt", "identity": "same", "rc": 1, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": ["EXIT_STATUS", "TRUTHFUL_SCOPE"], ...}
MUTANT fd3_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 1, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": ["EXIT_STATUS", "RESTART_COUNT", "TRUTHFUL_SCOPE"], ...}
MUTANT fd4_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD"], ...}
MUTANT fd5_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD"], ...}
MUTANT fd6_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD"], ...}
MUTANT fd7_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD"], ...}
MUTANT fd8_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD"], ...}
MUTANT fd9_devnull caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT fd4_pipe caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT fd5_pipe caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT fd6_pipe caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT fd7_pipe caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT fd8_pipe caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "RECEIPT_FD"], ...}
MUTANT fd9_pipe caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD", "RECEIPT_FD"], ...}
MUTANT fd3_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 1, "second_rc": null, "starts": 1, "scope_calls": 1, "errors": ["EXIT_STATUS", "RESTART_COUNT", "TRUTHFUL_SCOPE"], ...}
MUTANT fd4_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT fd5_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT fd6_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT fd7_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT fd8_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
MUTANT fd9_lock caught=1 {"case": "marker_removed", "identity": "same", "rc": 0, "second_rc": null, "starts": 2, "scope_calls": 2, "errors": ["HELPER_FD", "LOCK_FD"], ...}
```

Итог по завершённому перечню: `fd3..fd9` проверены для `/dev/null`, pipe и
lock-file (для `fd3_pipe` это тождественное переназначение и корректно
исключено самой генерацией); закрытый census ловит всякий fd выше 2 вне
зависимости от номера и цели. `exec 9>&-` между reap и restart теперь ловится
именно `lock_transition`; осиротевший watcher с lock после смерти родителя —
`lock_after_death`; receipt с задержкой — `delayed_receipt`.

## Соседние барьеры

```text
$ bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast
085: субъект /tmp/dev-harness-verify/adversary997r3/clone @ 64768e16
085: orch-loop 30d83712, orch-peak 6b4f2261; режим fast
клетки:
  зелено: р0 — 5/5 снимков cikl_085/ == пинам в памяти
  зелено: л1 — «ранний, выход» → сессий 2, rc 0
  зелено: п1 — журнал сменился за отсрочку — маркера нет
  зелено: м1 — сессия под systemd-run --user --scope: MemoryMax=32G, MemorySwapMax=0, команда после «--» кончается парой «workshop MSG»; заглушка sudo: вызовов «-nu orchagent workshop --yolo -- MSG» 1 из 1, XDG_RUNTIME_DIR=/run/user/1004 (запусков сессии: 1)
итог 085 fast: красных=0
# rc=0

$ HOME=/tmp/dev-harness-verify/adversary997r3/home093 bash fixtures/ops_granica/red_limit_otkaz_bez_zapuska.sh
ЗЕЛЁНО(093-2): отказ scope → именованный отказ rc 1, воркшоп не исполнен (И-5)
# rc=0

$ bash fixtures/ops_server/red_server_obvjazka_074.sh
честная часть (субъект /tmp/dev-harness-verify/adversary997r3/clone/ops/server/install.sh):
k5b: станция /home/harness/bin/orch-loop разошлась с пином
  КРАСНО: cell_k5b
  k1b: субъект отказался на испорченной записи (interposer испортил записей: 1)
честная часть: 7/7 зелёная
стаб-пак: 7/7 поймано, диффпроба: 7/7
к1b-каналы: честные 6/6, ленивые пойманы 6/6
итог 074: красных клеток=1 стабы=7/7
# rc=1
```

074 красен только по известной живой station-pin клетке `k5b`; его честные
клетки, семь стабов и шесть каналов зелёны. Это не обход предмета 997.

## Frozen и зона

```text
$ git rev-parse HEAD && git diff --exit-code frozen/contracts/997/1 HEAD -- contracts/997-orch-loop-metka-perezapuska.md
64768e1653643dad186b18e5634f748166631241
# rc=0

$ bash scripts/verify_antiplacebo.sh --scope check_zones
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 38 · предъявлено красным повторным прогоном: 38
# rc=0
```

Прямой `check_zones.sh .` предъявил уже существующий, чужой 055-дефект
грамматики (`ЗОНА architect (до-заморозочная батарея по ДЕЙСТВУЮЩЕЙ
заморозке каталога):` без путей), поэтому завершился неуспешно. Это не дельта
997 и не названный обход его принятых требований. Контракт 997 от frozen не
менялся, что показано `git diff --exit-code` выше.
