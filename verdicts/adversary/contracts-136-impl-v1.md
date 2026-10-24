FAIL
OBJECT=4a6559296aa3d716e6cdf0db6bb154eca570c33f

Основание: два исполнимых обхода на настоящих `scripts/` дают успешный исход там, где frozen 136/2 требует fail-closed. Оба обхода проходят действующую 69-клеточную батарею на реализации; следовательно, это дефекты предмета/проверки, а не дефекты заглушек.

## Блокирующие находки

| ID | Норма frozen 136/2 | Названный обход и состояние | Наблюдаемый результат |
|---|---|---|---|
| B1 | И-8: проектный режим допускается только когда ОБЪЯВЛЕННЫЙ `projectLayer.profilePath` ПОД `.harness/`; потеря объявленного слоя должна давать именованный rc 2, а не другой режим. | В `harness.project.json` задать `profilePath=.harness/../../outside-layer.json`, положить слой вне корня; либо задать `.harness/layer-link.json`, где этот путь — symlink на файл вне репозитория. Корневая `workflowPaths.registry` остаётся `.harness/records`, её полный файл исключений достаточен для паритета. | Настоящий `scripts/verify_ci_parity.sh` возвращает **rc 0** в обоих состояниях. Он проверяет лишь строковый префикс `.harness/*` и `-f`, не канонизирует путь и не отвергает symlink/`..`. Это объявляет внешний слой проектным и даёт ему проектный режим, вопреки предикату И-8. `red_sessii_136.sh` на реальной реализации остаётся 69/69 зелёным: клеток на эту границу нет. |
| B2 | И-6: источник trace — только конфиг установки `$HERE/config/agent_models.json`, не константа и не env; модель угроз прямо требует исключить рассогласование `trace.tsv ↔ конфиг` построением. | До входа двери создать непустой `<workflowPaths.registry>/trace.tsv`, например `orchestrator<TAB>evil-model<TAB>allowed`; вариант с двумя строками `first-model`/`second-model` и вариант read-only файла дают тот же результат. | Настоящая `scripts/connect_project.sh` не сверяет существующий trace с конфигом, запускает workshop (**rc 7**, двойник вызван) и сохраняет подложное содержимое. Затем настоящая `scripts/make_task.sh --kind brief` принимает его и печатает `TRACE: role=orchestrator model=evil-model fallback=allowed` (**rc 0**). Действующая 69-клеточная батарея также зелёная: она проверяет только посев отсутствующей/битой трассы, не существующую подменённую трассу. |

## Обязательные мутации на реальных scripts

`connect_project.sh` и `verify_ci_parity.sh` объекта побайтно совпадают с честными моделями (`cmp` rc 0), поэтому дельты m01–m12/n01–n07 были перенесены на копии **настоящего** субъекта, а остальные два субъекта раннер брал из настоящего дерева. Каждая копия запускалась отдельным миром plain-режима `red_sessii_136.sh`; ожидаемый и фактический красный rc — 1.

```text
$ python3 /tmp/dev-harness-verify/Adv136/scratch/run_real_mutants.py
m01-noroot: rc=1; sessii_136: клеток 69, зелёных 63, красных 6
m02-root-in-msg: rc=1; sessii_136: клеток 69, зелёных 63, красных 6
m03-root-after-separator: rc=1; sessii_136: клеток 69, зелёных 63, красных 6
m04-foreign-root: rc=1; sessii_136: клеток 69, зелёных 63, красных 6
m05-duplicate-root: rc=1; sessii_136: клеток 69, зелёных 63, красных 6
m06-taskfile-noroot: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
m07-no-final-oracle: rc=1; sessii_136: клеток 69, зелёных 66, красных 3
m08-node-fallback: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
m09-exact-layer-only: rc=1; sessii_136: клеток 69, зелёных 65, красных 4
m10-parity-jq-fallback: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
m11-allow-duplicate: rc=1; sessii_136: клеток 69, зелёных 65, красных 4
m12-append-root-to-msg: rc=1; sessii_136: клеток 69, зелёных 64, красных 5
n01-brief-extra-root: rc=1; sessii_136: клеток 69, зелёных 67, красных 2
n02-taskfile-skip-oracle: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
n03-empty-guard-fallback: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
n04-check-wrong-layer: rc=1; sessii_136: клеток 69, зелёных 67, красных 2
n05-nested-layer-harness: rc=1; sessii_136: клеток 69, зелёных 67, красных 2
n06-broken-profile-accepted: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
n07-empty-next-selected: rc=1; sessii_136: клеток 69, зелёных 68, красных 1
```

Итог класса m01–m12/n01–n07: 19/19 красные; это положительный контроль различающей способности существующих клеток, не закрывающий B1/B2.

## Новые атаки на настоящее поведение

```text
$ python3 /tmp/dev-harness-verify/Adv136/scratch/attack_profile_path.py
dotdot: rc=0
  ok   команда «npm run dev» (.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: команда релизного CI проекта, приёмкой пакета не является совсем
  ok   скрипт «build» не в CI — объявленное исключение: скрипт сборки тоя вне CI проекта, объявлён по причине проверки

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 2 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 0
symlink: rc=0
  ok   команда «npm run dev» (.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: команда релизного CI проекта, приёмкой пакета не является совсем
  ok   скрипт «build» не в CI — объявленное исключение: скрипт сборки тоя вне CI проекта, объявлён по причине проверки

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 2 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 0

$ env TMPDIR=/tmp/dev-harness-verify/Adv136/scratch/tmp bash scratch/attack_trace.sh
TRACE evil rc=7 exec=yes content=<orchestrator\tevil-model\tallowed>
TRACE duplicate rc=7 exec=yes content=<orchestrator\tfirst-model\tallowed
orchestrator\tsecond-model\tallowed>
TRACE readonly rc=7 exec=yes content=<orchestrator\tevil-model\tallowed>
MAKE_TASK readonly rc=0 trace=TRACE: role=orchestrator model=evil-model fallback=allowed

$ env TMPDIR=/tmp/dev-harness-verify/Adv136/scratch/tmp bash scratch/attack_pins.sh
PIN nul rc=1 exec=no err=<... warning: command substitution: ignored null byte in input|connect ОТКАЗ: PIN_CHUZHOJ: задание несёт чужую либо половинную декларацию пина|>
PIN cr rc=1 exec=no err=<connect ОТКАЗ: PIN_CHUZHOJ: итоговый текст не извлекается в пин двери|>
PIN unicode rc=7 exec=yes err=<>
PIN newline rc=1 exec=no err=<connect ОТКАЗ: PIN_CHUZHOJ: задание несёт чужую либо половинную декларацию пина|>
```

NUL, CR и newline с чужой ASCII-парой отказаны до exec. Полноширокие Unicode-разделители не являются разделителями грамматики 032/066; запуск в этом случае не предъявляется блокером. Проба FIFO-TOCTOU между чтением task-file и exec не завершилась за 180 секунд (раннерская FIFO-подстановка); наблюдаемого обхода из неё не заявляю.

## Положительные контроли и регресс

```text
$ env TMPDIR=... bash scratch/run136-model2.sh --model
sessii_136: клеток 69, зелёных 69, красных 0
rc=0

$ env TMPDIR=... bash scratch/run136-stabs.sh --stabs
sessii_136 --stabs: стабов 37, привязок 54, непойманных 0
rc=0

$ env TMPDIR=... bash scratch/run136-impl.sh
sessii_136: клеток 69, зелёных 69, красных 0
rc=0

$ env TMPDIR=... bash scratch/run125-plain125.sh
s125 red: зелёных 70, красных 0
rc=0

$ env TMPDIR=... bash scratch/run125-model125.sh --model
s125 model: зелёных 70, красных 0
rc=0

$ env TMPDIR=... bash scratch/ci095/fixtures/_krasnye_095.sh repo
ИТОГ стаб-пак 095: rc=0
ИТОГ 095: rc=0

$ env TMPDIR=... bash scratch/ci103/fixtures/_krasnye_103.sh repo
ИТОГ стаб-пак 103: rc=0
ИТОГ 103: rc=0

$ npm run check:rezhim-996-family-selftest
996: examined=111 mutants=0 mismatches=0
rc=0

$ npm run check:podkljuchenie-112-family-selftest
ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0

$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
rc=0
```

## Зона

```text
$ git diff --stat origin/main...4a6559296aa3d716e6cdf0db6bb154eca570c33f
 scripts/connect_project.sh  | 135 +++++++++++++++++++++++++++++++++++++++++---
 scripts/make_task.sh        |  38 ++++++++++++-
 scripts/verify_ci_parity.sh |  26 +++++++++
 3 files changed, 190 insertions(+), 9 deletions(-)

$ git diff --name-only origin/main...4a6559296aa3d716e6cdf0db6bb154eca570c33f
scripts/connect_project.sh
scripts/make_task.sh
scripts/verify_ci_parity.sh
```

Зона implementer соблюдена: только три разрешённых скрипта; path-guard и frozen-барьеры не затронуты.
