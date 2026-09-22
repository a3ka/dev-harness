# Adversary 038 — sourced execution bypasses environ guard

**Verdict: FAIL.**

Судимый HEAD: `9de033cfe2c0e28d71f203854193ef4d045179a4`.

## Новый обход внутри границы

Один корневой дефект имеет два живых вектора: гард предполагает, что текст
`check_provodka.sh` исполняется как отдельный bash-скрипт, но не проверяет это
свойство. При `source` первая исполняемая строка гарда действительно выполняется;
нет подмены файла, `/proc`, ядра, `/usr/bin/bash`, `/usr/bin/env` или
`/usr/bin/tr`, и нет кода, прекращающего исполнение до этой строки. Поэтому это
не исключение из §«Граница модели угроз» арбитражного решения.

1. При неканоническом `environ` гард делает re-exec с `"$0"`. В sourced-вызове
   `$0` принадлежит вызывающему, а не subject. В repro он указывает на
   независимый launcher с `exit 0`; красный контракт становится зелёным.
2. В bash-подоболочке `$$` остаётся PID родительского shell. Его
   `/proc/$$/environ` каноничен, тогда как определённая в текущей подоболочке
   функция `grep() { return 0; }` уже активна и в `/proc/$$/environ` не видна.
   Сравнение ошибочно пропускает re-exec, и sourced subject принимает
   отсутствующую role-норму.

Это именно нейтрализация проверяемого барьера: оба direct controls на тех же
красных входах возвращают `1`; каждый sourced-вектор возвращает `0`.

Живой repro закоммичен рядом:

```bash
bash verdicts/adversary/contracts-038-sourced-execution-environ-guard.repro.sh
```

Сырой вывод:

```text
direct-canonical-red-control: rc=1
direct-hostile-red-control: rc=1
source-reexec-red-input: rc=0
subshell-source-forged-grep: rc=0
REPRODUCED: sourced execution redirects re-exec through caller-controlled $0 and hides a forged function behind parent $$ environ.
```

## Положительные и прежние контроли

Реальный положительный контроль обязателен и зелёный:

```bash
bash scripts/check_provodka.sh . contracts/038-provodka-done-gejt.md
# rc=0; stdout/stderr пусты
```

Все пять старых adversary-repro инвертированы: каждый сохраняет свой честный
контроль `rc=0`, затем останавливается на первом прежнем «accepted» с полученным
`rc=1` вместо старого ожидаемого `0`. Полные выводы:

```text
$ bash verdicts/adversary/contracts-038-role-parser-laxity.repro.sh
honest-minimal: rc=0
FAIL arbitrary-text-around-norm-accepted: rc=1, expected 0
проводка: строка вне грамматики: - role=roles/valid.md NOT-GRAMMAR «Honest role norm.» TRAILING-GARBAGE

$ bash verdicts/adversary/contracts-038-role-toctou.repro.sh
honest-flat-alias: rc=0
FAIL swap-after-canonicalization: rc=1, expected 0
проводка: норма-строка не найдена в role-файле: roles/alias.md

$ bash verdicts/adversary/contracts-038-postk5-bypasses.repro.sh
honest-charter: rc=0
role-trailing-garbage-rejected: rc=1
role-nested-quotes-rejected: rc=1
charter-trailing-garbage-rejected: rc=1
charter-nested-quotes-rejected: rc=1
FAIL role-canonical-target-replaced-accepted: rc=1, expected 0
проводка: норма-строка не найдена в role-файле: roles/honest.md

$ bash verdicts/adversary/contracts-038-forged-readlink.repro.sh
honest-role: rc=0
honest-role-hardlink: rc=0
honest-charter: rc=0
FAIL forged-role-canonicality-accepted: rc=1, expected 0
проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/alias.md (резолв: /tmp/adversary038-forged-tools.869L9M/tree/policies/outside-role.md)

$ bash verdicts/adversary/contracts-038-exported-functions.repro.sh
honest-role: rc=0
honest-charter: rc=0
FAIL exported-readlink-role-canonicality: rc=1, expected 0
проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/alias.md (резолв: /tmp/adversary038-exported-functions.0eZXqa/tree/policies/outside-role.md)
```

Арбитражная hostile-environment battery также зелёная на обычном процессе:

```text
OK   honest-role: rc=0
OK   honest-charter: rc=0
OK   exported-readlink: rc=1
OK   exported-grep: rc=1
OK   exported-awk: rc=1
OK   exported-exit: rc=1
OK   exported-exec-plus-grep: rc=1
OK   exported-unset-compgen-grep: rc=1
OK   total-shadowing: rc=1
OK   exact-clean-replay-red: rc=1
OK   green-under-attack: rc=0
OK   skip-under-attack: rc=2
BATTERY: 0 failures
```

`EXPECT_RC=0 bash fixtures/_krasnye_038.sh` завершился `rc=0`: 31 файлов,
расхождений 0. `bash scripts/verify_antiplacebo.sh --scope check_provodka`
завершился `rc=0`: 27 фикстур предъявлены красным повторным прогоном.
