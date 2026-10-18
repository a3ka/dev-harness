FAIL
OBJECT=a92e44c5b78fd97bbe6ad9f470f4dd69de411cb3

Блокер: проверка 997 не наблюдает инвариант 2 контракта — до exec агента должны быть закрыты receipt-fd и lock-fd во всём дереве сессии. Поэтому она принимает два предмета с реальной утечкой дескриптора.

## Воспроизведение

Все изменения были только в одноразовых каталогах `/tmp/dev-harness-verify/adv997/fd-leak/` и `/tmp/dev-harness-verify/adv997/lock-leak/`; исходный клон не менялся.

1. Receipt-утечка. В обеих ветках запуска (`same` и `other`) заменён ровно один фрагмент:
   - `printf "SCOPED\\n" >&3; exec 3>&-; exec "$1"` → `printf "SCOPED\\n" >&3; exec "$1"`;
   - `printf "SCOPED\\n" >&3; exec 3>&-; HOME="$1" exec sudo` → `printf "SCOPED\\n" >&3; HOME="$1" exec sudo`.

   Запуск `python3 /tmp/dev-harness-verify/adv997/fd_leak_probe.py` завершился rc 0. Это копия runtime-пробы 997, в которую для наблюдения добавлено только поле `fd3=os.path.exists('/proc/self/fd/3')` в событие toy-агента; существующие ожидания не менялись. Итог: `997 observed=28 mismatches=0`, а у каждого запущенного агента в обоих uid-путях `agent_fd3: [true, …]`. Скрипт напечатал `FD_LEAK_CONFIRMED`.

2. Lock-утечка. В обеих ветках удалена только завершающая часть редиректа запуска:
   `3>/dev/fd/8 7<&- 8>&- 9>&-; rc=$?` → `3>/dev/fd/8 7<&- 8>&-; rc=$?`.

   `python3 /tmp/dev-harness-verify/adv997/lock_leak_probe.py` также завершился rc 0: `997 observed=28 mismatches=0`; аудит toy-агента показал `agent_fd9: [true, …]` для каждой подтверждённой сессии в обоих uid-путях и напечатал `LOCK_LEAK_CONFIRMED`.

Это не текстовая претензия: в обоих случаях агент реально унаследовал запрещённый fd; обычная матрица проверяет только количество запусков, rc, сообщения и состояния файлов. Ни один сценарий не читает `/proc/self/fd` агента.

## Положительный контроль

`python3 /tmp/dev-harness-verify/adv997/fd_positive_control.py` запустил неизменённый `ops/server/user/orch-loop` через тот же инструментированный backend. Rc 0, `997 observed=28 mismatches=0`; у каждого агента обоих путей `agent_fds: [[false, false], …]` для `(fd3, fd9)`. Значит, аудит различает честный предмет и обе обманки, а не является вечно-красным.

## Соседние барьеры и попытки

- Честный `bash fixtures/ops_server/orch_loop_997/probe.sh`: rc 0, 28 cases и matrix 52 без mismatch.
- Мутант receipt-fd прошёл `OPS_ROOT=/tmp/dev-harness-verify/adv997/fd085 bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast`: rc 0, все четыре клетки зелёные.
- Тот же мутант прошёл `OPS093_ROOT=/tmp/dev-harness-verify/adv997/fd093 bash fixtures/ops_granica/red_limit_otkaz_bez_zapuska.sh`: rc 0. Этот вход намеренно отказывает scope до запуска агента, поэтому fd-утечку не наблюдает.
- На честном дереве `bash fixtures/ops_granica/battery_stubs.sh`: rc 0, 10/10 стабов пойманы; его набор также не содержит аудита fd 3/9 агента.
- Честный `bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast`: rc 0.
- `bash fixtures/ops_server/red_server_obvjazka_074.sh` не является зелёным даже на неизменённом объекте: rc 1 исключительно из `cell_k5b`, `/home/harness/bin/orch-loop разошлась с пином`; собственные клетки 7/7, стабы 7/7 и каналы 6/6 зелёные. Повтор с `CI=1` дал тот же внешний station-pin отказ. Поэтому полного утверждения «997/085/093/074 одновременно зелёны» на этой машине не делаю; этот отказ не вызван и не различает fd-мутант.

Не запускались живые `systemd-run` и 085 m5.

## Frozen и область

`git show 'frozen/contracts/997/1^{commit}:contracts/997-orch-loop-metka-perezapuska.md' | sha256sum` и текущий контракт дали один hash `8c6f84716907142403a69d653b4659db0e7f6d6e83d3b135762f6c7ac5353006`. Diff landed commit по frozen contract и `fixtures/ops_server/orch_loop_997/` пуст. В рабочем клоне после проб нет изменений.

## Требуемая правка автора

В проверку 997 нужен исполняемый fd-census реального toy-агента: на каждом подтверждённом запуске, в same и other uid-пути, он обязан доказать отсутствие fd 3 и fd 9 (и по контракту всех receipt/lock helper fd). В matrix нужны назначенные мутации удаления `exec 3>&-` и `9>&-`, каждая обязана быть поймана на своём сценарии; честная реализация — пройти тот же census.

Вердикт оставлен по требуемому пути `/tmp/dev-harness-verify/adv997/verdict.md`; коммит не создавался, так как задание предписывает оркестратору коммитить verdict под отдельной identity.
