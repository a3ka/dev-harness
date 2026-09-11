FAIL

# Адверсарий: контракт 024, круг 1

Судимая база: `main` `dca83fbfd1f414ffc5f251226aaa3e082addb6ae`. Предмет и проверки не менялись. Каждый контрпример запускался в отдельной одноразовой копии этого коммита под `/tmp/adv024-*`; основной checkout менялся только этим файлом. Состояния ниже именованы как `S-*`.

## Блокер 1 — отказ `git status` превращается в зелёную сверку

**Обход — `S-git-status-1`.** Между снимком и сверкой в основной checkout добавлен `S-git-status-failure.txt`. В `PATH` перед настоящим `git` помещён отдельный контрольный `git`: все команды, нужные для канонизации/`rev-parse`, передаются `/usr/bin/git`, но `git -C <root> status …` завершает работу с `rc=1`. Это ровно отказ источника манифеста, который по `do_snapshot`/`do_check` должен дать именованный отказ, а не содержательный пустой манифест.

В `/tmp/adv024-status-fail`:

```text
PATH=/tmp/adv024-status-fail-bin:/usr/bin TMPDIR=/tmp/adv024-status-fail-snaps \
  /usr/bin/bash scripts/check_no_leak.sh --snapshot /tmp/adv024-status-fail    # rc=0
printf 'leak-after-status-failure\n' > S-git-status-failure.txt
PATH=/tmp/adv024-status-fail-bin:/usr/bin TMPDIR=/tmp/adv024-status-fail-snaps \
  /usr/bin/bash scripts/check_no_leak.sh --check /tmp/adv024-status-fail       # rc=0
# stdout: основной чекаут чист
```

Причина в коде: `emit_manifest` читает `git status` через process substitution, а `manifest` возвращает статус `sort`; отказ producer не попадает ни в `m="$(manifest …)"`, ни в `cur="$(manifest …)"`. Следовательно, после сбоя `status` снимок и текущий манифест оба пусты, а реальная новая запись проходит. Это отказ, выглядящий успехом, и прямое нарушение основного свойства детектора.

## Блокер 2 — отсутствующие `sha256sum` и `cut` (rc 127) дают «чисто»

**Обход — `S-no-sha256sum`.** В отдельном `/tmp/adv024-no-sha` `PATH` содержит `git`, `sort`, `comm`, `mkdir`, `cat`, но намеренно не содержит `sha256sum` и `cut`. До снимка `.githooks/pre-push` уже изменён; после снимка в него дописана новая строка. Так проверяется именно новая утечка в уже грязном tracked-пути, а не появление самого пути.

```text
PATH=/tmp/adv024-no-sha-bin TMPDIR=/tmp/adv024-no-sha-snaps \
  /usr/bin/bash scripts/check_no_leak.sh --snapshot /tmp/adv024-no-sha          # rc=0
# stderr: sha256sum: command not found; cut: command not found
printf 'post-snapshot-leak\n' >> .githooks/pre-push
PATH=/tmp/adv024-no-sha-bin TMPDIR=/tmp/adv024-no-sha-snaps \
  /usr/bin/bash scripts/check_no_leak.sh --check /tmp/adv024-no-sha             # rc=0
# stderr: sha256sum: command not found; cut: command not found
# stdout: основной чекаут чист
```

`sha256sum`-ошибка сводится к постоянному отпечатку `ERR`; отказ вычисления пути снимка также не прерывает скрипт без `set -e`. Для одной и той же уже-грязной записи ` M:ERR` дельта пуста. Контракт обещает `rc=2` для непригодного окружения, но проверяет только наличие `git`; отсутствие обязательных утилит не fail-closed. Это независимый контрпример класса «инструмент мимо PATH / rc 127 выглядит успехом».

## Блокер 3 — ветвь B можно сделать формально зелёной без защиты судьи

**Обход — `S-B-norma-without-hook`.** В отдельном `/tmp/adv024-branch-b` добавлена ровно одна запрошенная строка нормы в `roles/orchestrator.md`; никакой исполнимый путь спавна и ни одна проверка не менялись. Все предъявленные зелёные критерии стали зелёными на живом `check_no_leak.sh`:

```text
bash fixtures/check_judge_gate/red_norma_stroka_024.sh                            # rc=0
# норма-строка 024 приземлена дословно (grep -F, побайтово)
bash fixtures/check_judge_gate/red_detektor_utechek.sh                            # rc=0, 14/14 ворот
bash fixtures/check_judge_gate/canary_zhivoj_024.sh /tmp/adv024-branch-b          # rc=0
bash scripts/verify_antiplacebo.sh . --scope check_judge_gate                     # rc=0, 3/3
```

Но поиск `check_no_leak` в фактическом пути спавна `scripts/spawn_agent.sh` дал пустой результат: до судьи не выполняются ни `--snapshot`, ни `--check`, а значит утечка main перед заданием судьи не останавливает спавн. Одна строка, проверяемая `grep -F`, является документальной декларацией, не исполнимой связкой. Состояние удовлетворяет существующим проверкам, но судья реально не защищён. Сам контракт называет остаток «аудитом стенограмм», однако это не превращает критерий «перед каждым спавном судьи» в исполнимое свойство.

На исходном `dca83fb` ветвь B даже не приземлена: `bash fixtures/check_judge_gate/red_norma_stroka_024.sh` вернул `rc=1` с «норма-строка 024 не приземлена». Это ожидаемое до done состояние, но не устраняет приведённый зелёный контрпример после буквального приземления.

## Дополнительные обходы манифеста — совет

Все четыре состояния ниже дали `rc=0` и stdout `основной чекаут чист` на настоящем детекторе. Они подтверждают, что манифест хранит только `XY` и разыменованные байты, а не полное состояние файловой системы:

| Состояние (отдельный клон) | Действие после снимка | Фактический результат | Класс |
|---|---|---|---|
| `S-symlink-equal-target` (`/tmp/adv024-symlink`) | неотслеживаемая ссылка `link: payload-A` заменена на `link: payload-B`; оба target содержат одинаковые байты | `readlink …/link` = `payload-B`; `--check` → `rc=0` | совет: ссылка — другой объект/путь, но `sha256sum` разыменовывает её |
| `S-chmod-untracked` (`/tmp/adv024-chmod`) | у старого неотслеживаемого `tool` режим `0644 → 0755` | `stat` = `755`; `--check` → `rc=0` | совет |
| `S-empty-directory-after-snapshot` (`/tmp/adv024-empty-dir`) | создан пустой каталог | `stat` = `directory`; `--check` → `rc=0` | совет |
| `S-xattr-untracked` (`/tmp/adv024-xattr`) | у старого неотслеживаемого файла задан `user.adv024=changed` | `setfattr` успешен; `--check` → `rc=0` | совет |

Также исполнены `S-mtime-untracked` (`touch -d '2030-01-02 03:04:05 UTC'`) и `S-hardlink-topology` (второй файл заменён hard link на первый с теми же байтами); оба дали `rc=0`. Это не основания данного FAIL: точный контракт говорит о sha256 содержимого, но не называет эти слепые зоны в Демаркации, хотя обещает манифест состояния дерева. Для symlink следует хешировать payload ссылки (`readlink`), а при расширении предмета — тип/режим и явно решить, входят ли каталоги/xattr/link topology.

`S-ignored-path` отдельно дал `rc=0` после создания `.env.adv024`; это **не находка**, потому что ignored-пути честно исключены Демаркацией 024 и адресованы 025.

## Снимок и параллельность — совет с воспроизводимым обходом

Удаление снимка проверено как положительный контроль fail-closed: после `rm -rf /tmp/adv024-snapshot-substitute-snaps/dev-harness-leak` `--check` вернул `rc=1` и «снимок отсутствует».

Но в `S-parallel-last-wins` (`/tmp/adv024-parallel`) две независимые церемонии одного root делят один предсказуемый файл `${TMPDIR}/dev-harness-leak/<hash8>/porcelain`:

```text
# сессия A
TMPDIR=/tmp/adv024-parallel-snaps bash scripts/check_no_leak.sh --snapshot /tmp/adv024-parallel  # rc=0
printf 'leak-from-A\n' > S-parallel-A-leak.txt
# сессия B того же root (последний снимок заменяет A)
TMPDIR=/tmp/adv024-parallel-snaps bash scripts/check_no_leak.sh --snapshot /tmp/adv024-parallel  # rc=0
# A сверяет свою пачку
TMPDIR=/tmp/adv024-parallel-snaps bash scripts/check_no_leak.sh --check /tmp/adv024-parallel     # rc=0, «основной чекаут чист»
```

То же получается в `S-storage-rebase` (`/tmp/adv024-snapshot-substitute`), если после записи `S-storage-forged-snapshot.txt` подменить базу повторным `--snapshot`: `--check` вернул `rc=0`. Root-строка защищает только чужой корень/hash8-коллизию (ворота 13 это ловят), не свежесть, владельца пачки или целостность текущей базы. Это явно документированная семантика «последний выигрывает», поэтому класс — совет, а не дополнительное основание FAIL; при параллельных пачках требуется изоляция снимка/nonce либо запрет конкурирующих церемоний.

## Контрольные эксперименты и не-регресс

На неизменённом живом механизме в отдельном `/tmp/adv024-baseline`:

```text
bash fixtures/check_judge_gate/red_detektor_utechek.sh                            # rc=0, 14/14
bash fixtures/check_judge_gate/red_detektor_utechek.sh                            # rc=0, повтор с новыми случайными toy-входами, 14/14
bash fixtures/check_judge_gate/probe_slabyh_detektora.sh                          # rc=0
bash fixtures/check_judge_gate/canary_zhivoj_024.sh /tmp/adv024-baseline          # rc=0
bash scripts/verify_antiplacebo.sh . --scope check_judge_gate                     # rc=0, 3/3
 git diff --exit-code frozen/contracts/024/1 -- contracts/024-detektor-utechek-osnovnogo-chekauta.md  # rc=0
```

`probe_slabyh_detektora.sh` дал зелёный честной минимальной форме на всех 14 воротах, поймал 13 поставленных слабых форм по имени ворот и причине и отверг `exit 1` без диагностики. Следовательно, red/проба не являются вечно-красным шумом; найденные блокеры лежат за их входным пространством.

## Требуемое исправление

1. Перестроить `manifest` без process substitution, которая теряет rc `git status`; статус и отсутствие **каждой** обязательной утилиты (`git`, `sha256sum`, `cut`, `sort`, `comm`) должны давать именованный fail-closed `rc=2` до решения «чисто».
2. Добавить в red-прогон контрпримеры `S-git-status-1` и `S-no-sha256sum`, включая уже-грязный tracked-путь.
3. Сделать ветвь B исполнимой: обернуть реальный путь каждого судейского спавна снимком/сверкой и проверять это исполнением, а не только наличием строки в роли.
4. После правки повторить два red-прогона, probe, live canary, scoped `check_judge_gate`, ветвь B и frozen-diff.
