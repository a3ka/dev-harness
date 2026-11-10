accept
OBJECT=3161fc9dde44e2531ed826a79af86dede2f6a85c
СУД: repo=dev-harness+Complior-mob (PR #164, head 51ec88ac99b602afdae5564f9c2acf1b387253c1); предмет=143 mob-ci-razdelenie v3/v4; фаза=суд реализации перед слиянием; роль=reviewer; вызов=2 (scoped, исправительный: закрытие Б-1/Б-2); модель-план=anthropic/claude-opus-5-5; сессия=Rev143v2 (c907157c); модель-факт=anthropic/claude-opus-5-5; кандидат implementer=3161fc9dde44e2531ed826a79af86dede2f6a85c (зеркало); батарея architect=ef943c768e5ed8b03eda4d0da469bdf5f03b4679 (wip/143/architect, PR dev-harness#532); контракт=frozen/contracts/143/4 → 8fd88388f973fc6d398a636898745d2b844afeaf; предыдущий=verdicts/review/contracts-143-impl-v3.md (FAIL, OBJECT 1673a516c); адверсарий=verdicts/adversary/contracts-143-impl-v5.md (accept)

# Вердикт ревьюера — 143, реализация v3/v4, вызов 2 (scoped)

Рамка вызова: закрыты ли Б-1 (`ADB_SERVER_PORT` никто не читает) и Б-2 (четыре флага sweep без потребителя) из `contracts-143-impl-v3.md`. Проверены также область правки, приёмка на собранном дереве, красное по новым барьерам, неизменность контракта и проводка. Остальное принято вызовом 1 и здесь не пересуживается.

Клон одноразовый, со своим `.git`, origin `ssh://git@github.com/a3ka/dev-harness.git`: `/tmp/dev-harness-verify/Rev143v2/repo`. Worktree `../arch` = ef943c768 (батарея), `../impl` = 3161fc9dd (OBJECT). Мутанты лежат в одноразовых копиях `../mut-old`, `../mut-p1`, `../mut-var`. Продукт читался только через `gh api` и только на чтение.

Итог: **accept**. Б-1 закрыт, Б-2 закрыт, новых блоков нет. Советов 2 (С-2 из вызова 1 подтверждён и уточнён, С-4 новый), наблюдений 3.

## 0. Объект и неизменность контракта

```
$ git rev-parse origin/main origin/wip/143/architect origin/wip/143/implementer origin/wip/143/reviewer
b61315f90fe86bcbf81d5a4d02afa602dade73f2
ef943c768e5ed8b03eda4d0da469bdf5f03b4679
3161fc9dde44e2531ed826a79af86dede2f6a85c
ea82c69c60898aacffdf00e97f76389604203a61
$ for r in origin/main origin/wip/143/architect origin/wip/143/implementer; do git diff --quiet 'frozen/contracts/143/4^{commit}' $r -- contracts/143-mob-ci-razdelenie.md; echo "$r rc=$?"; done
origin/main rc=0
origin/wip/143/architect rc=0
origin/wip/143/implementer rc=0
$ git rev-parse 'frozen/contracts/143/4^{commit}'
8fd88388f973fc6d398a636898745d2b844afeaf
$ reslop t -- bash scripts/check_contract_frozen.sh        # на ../arch (ef943c768)
ok: true / passed: 170 / failed: 0
  ok   contracts/143-mob-ci-razdelenie.md — заморожен v4, блоб совпадает побайтово, вердикты v1..v4 разрешают
планов и контрактов на HEAD: 170 · черновиков: 9 · заморожено: 161 · реестр: full
exit: 0
```

## 1. Область правки

### implementer: ровно две строки в двух файлах своей зоны

```
$ git log --format='%h %an <%ae> %ad %s' --date=iso 3b6365ebe..origin/wip/143/implementer
3161fc9d implementer <implementer@dev-harness.local> 2026-11-10 17:14:04 +0000 143: свой adb-сервер — ANDROID_ADB_SERVER_PORT=AVD_PORT+20000 (B-1 ревьюера)
$ git diff --numstat 3b6365ebe 3161fc9dd
1	1	.github/workflows/mobile.yml
1	1	STRUCTURE.md
$ git diff -U0 3b6365ebe 3161fc9dd
-          export ADB_SERVER_PORT="$((AVD_PORT + 1))"
+          export ANDROID_ADB_SERVER_PORT="$((AVD_PORT + 20000))"
-| `mobile/scripts/run-ci-screen.cjs` | один child универсального работника: свой AVD/ADB-порт, один APK … |
+| `mobile/scripts/run-ci-screen.cjs` | один child универсального работника: свой эмулятор на консольном порту `AVD_PORT` (порт эмулятора), один APK … ; отдельный adb-сервер скриптом не настраивается — его порт задаёт job `e2e-screen` экспортом `ANDROID_ADB_SERVER_PORT` |
```

Оба пути входят в ЗОНУ implementer контракта 143. Батарею и фикстуры implementer не трогал.

В job `e2e-screen` зеркало отличается от собранного эталона (`model_workflow()` = v2 + `matrix-v3.yml`) только двумя `working-directory: ${{ github.workspace }}` (шаги 3 и 4), как и в вызове 1. Тело `run` шага 4 совпадает с эталоном побайтно (моя мера: сравнение YAML-словарей по шагам).

### Зеркало == продукт PR #164 (сверка блобов через `gh api`)

```
EQ .github/workflows/mobile.yml e9bc5cdc9586139603712e7f7e2251082c26f557
EQ STRUCTURE.md 02b43c589bf432eabf57f939d2e01a8dd326e2a6
EQ mobile/ci-screens.json 03b9e68b6c6a0b33bbfb2597d51adb2803dde82b
EQ mobile/scripts/select-ci-screens.cjs 9c6a0de74e957c763e8fa1b83c88684287b2c87d
EQ mobile/scripts/ci-aggregate.cjs 1c019218655e447eb31f6885db7ac3605de70527
EQ mobile/scripts/run-ci-screen.cjs c0682214b4c87dcffa8d937555d828de298adad5
EQ mobile/structure-policy.json acf0f2aecff33eb2e313913ba9b66bf6a914ccf4
$ gh pr view 164 -R a3ka/Complior-mob --json headRefOid,state,mergeable,baseRefName
51ec88ac99b602afdae5564f9c2acf1b387253c1	OPEN	MERGEABLE	main
$ gh api repos/a3ka/Complior-mob/compare/ac0943d7…...51ec88ac…
ahead 1 behind 0; files: .github/workflows/mobile.yml +1 -1; STRUCTURE.md +1 -1; 51ec88ac99 implementer 143: свой adb-сервер — ANDROID_ADB_SERVER_PORT=AVD_PORT+20000 (B-1 ревьюера)
```

### architect: только `fixtures/workshop_project/mob_ci_143/`

```
$ git log --format='%h %an <%ae> %ad %s' --date=iso origin/main..origin/wip/143/architect
ef943c76 architect <architect@dev-harness.local> 2026-11-10 17:07:57 +0000 143: isolate child adb server with real environment and independent port
9bf4d497 architect <architect@dev-harness.local> 2026-11-10 14:36:46 +0000 143: enumerate workflow root controls and permission leaves from YAML
493717ff architect <architect@dev-harness.local> 2026-11-10 11:11:07 +0000 143: workflow trigger/top-level key mutation sweep (Adv143v4)
$ git log --format= --name-only b61315f9..ef943c76 | sort -u
fixtures/workshop_project/mob_ci_143/matrix_v3.py
fixtures/workshop_project/mob_ci_143/model/matrix-v3.yml
fixtures/workshop_project/mob_ci_143/osi.md
fixtures/workshop_project/mob_ci_143/source.json
fixtures/workshop_project/mob_ci_143/workflow_mutation_sweep.py
fixtures/workshop_project/mob_ci_143/workflow_sweep_v3.py
$ git diff --stat 1673a516c 9bf4d497 -- fixtures/workshop_project/mob_ci_143/    # перебазирование не изменило прежний OBJECT
(пусто, rc 0)
$ git diff --stat 1673a516c ef943c76 -- fixtures/workshop_project/mob_ci_143/
 matrix_v3.py | 38 +++++-  model/matrix-v3.yml | 2 +-  osi.md | 23 +++--  source.json | 2 +-  workflow_mutation_sweep.py | 42 +++------
 5 files changed, 61 insertions(+), 46 deletions(-)
$ sha256sum model/matrix-v3.yml model/mobile/scripts/run-ci-screen.cjs <impl>/mobile/scripts/run-ci-screen.cjs
c643e55187188b21ce141a39b7039705cb6882faee36260ca174a0146a201f06  model/matrix-v3.yml     # = source.json:v3_piny
4b76ed1103e873e6de61d2032fd89c004d036142960afa4a385670d3ee70f9ff  model/mobile/scripts/run-ci-screen.cjs   # = пин = зеркало
4b76ed1103e873e6de61d2032fd89c004d036142960afa4a385670d3ee70f9ff  <impl>/mobile/scripts/run-ci-screen.cjs
```

Нормативные документы (contracts/, roles/, AGENTS.md) не правились ни одной из веток.

```
$ git merge-tree --write-tree origin/main origin/wip/143/architect   # rc 0, без конфликтов
58d18a1d8d3a36fc50bc8d4c4f436fcad95997a5
```

### Зоны (своя мера: авторы коммитов и пути против ЗОНА-строк frozen 143/4)

```
contracts/143-mob-ci-razdelenie.md:165  ЗОНА architect: contracts/143-mob-ci-razdelenie.md fixtures/workshop_project/mob_ci_143/
contracts/143-mob-ci-razdelenie.md:166  ЗОНА implementer: .github/workflows/mobile.yml … mobile/scripts/run-ci-screen.cjs mobile/structure-policy.json STRUCTURE.md
contracts/143-mob-ci-razdelenie.md:169  ЗОНА reviewer: verdicts/review/
```

Коммит implementer 3161fc9d (автор `implementer`) меняет 2 пути, оба из его ЗОНЫ. Коммиты architect 493717ff/9bf4d497/ef943c76 (автор `architect`) меняют 6 путей, все под `fixtures/workshop_project/mob_ci_143/`. Этот вердикт лежит в `verdicts/review/` под identity `reviewer`.

```
$ reslop t -- bash scripts/check_zones.sh /tmp/dev-harness-verify/Rev143v2/arch      # скрипт ветки ef943c768, теги frozen/* все (fetch --tags)
ok: true
passed: 97
failed: 0
замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 52585 · проверено по зонам: 13951
exit: 0
$ reslop t -- bash scripts/check_zones.sh /tmp/dev-harness-verify/Rev143v2/impl      # зеркало 3161fc9dd
ok: true
passed: 97
failed: 0
замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 51706 · проверено по зонам: 13550
exit: 0
```

## 2. Б-1 — закрыт (проверено исполнением)

### 2.1. Эталон и клетка проверяют действие, а не подстроку

- `model/matrix-v3.yml:42`: `export ANDROID_ADB_SERVER_PORT="$((AVD_PORT + 20000))"`.
- Клетка `allocator` (`matrix_v3.py:596-607`) требует, чтобы ровно эта строка была отдельной строкой `run` (`adb_server in launch.splitlines()`). Прежняя проверка подстроки `'ADB_SERVER_PORT=' in launch` удалена.
- Добавлены два адресных стаба, каждый привязан к двум клеткам (`matrix_v3.py:961-988`). Подмена выполняется с якорем: если правильная строка встречается не ровно один раз — `ORACLE_TAMPERED`, rc 2.

### 2.2. Переменная действует: adb станции её читает, старое имя игнорирует

```
$ ANDROID_ADB_SERVER_PORT=25599 adb start-server            # /home/harness/Android/Sdk/platform-tools/adb, 1.0.41 / 37.0.1-15733141
* daemon not running; starting now at tcp:25599
* daemon started successfully
rc=0
$ ADB_SERVER_PORT=25597 adb start-server
rc=0
$ ss -ltn (5037/25597/25599)
['127.0.0.1:25599', '127.0.0.1:5037']                        # 25597 не открыт: старое имя мёртвое, сервер ушёл на общий 5037
$ ANDROID_ADB_SERVER_PORT=70000 adb devices
adb: $ANDROID_ADB_SERVER_PORT must be a positive number less than 65535: got "70000"
rc=1
$ ANDROID_ADB_SERVER_PORT=25599 adb kill-server
rc=0
['127.0.0.1:5037']                                           # убран только свой сервер, общий 5037 не тронут
```

То, что эмулятор читает `ANDROID_ADB_SERVER_PORT`, установлено в вызове 1 (`strings libandroid-emu-shared.so`). Здесь не перепроверялось.

### 2.3. Порты не пересекаются (моя мера — перечисление)

```
AVD_PORT допустимые эмулятором (чётные 5554..5584 вне legacy): 11 5554 .. 5584
ANDROID_ADB_SERVER_PORT: 25554 .. 25584 уникальных 11
пересечение с 5037/legacy console+adb: []
пересечение с console/adb любых children: []
# все числовые порты вне комментариев в mobile.yml зеркала:
{2048: [605, 827, 1085, 1260] (hw.ramSize, не порт), 5562: [593], 5564: [815], 5566: [1073], 5568: [1247], 20000: [1530]}
```

Legacy-jobs используют консоли 5560..5568 (5560 — pilot через `.harness`), их ADB-порты 5561..5569 и общий сервер 5037 (`adb start-server`). Сервер child `AVD_PORT+20000` в пределах диапазона эмулятора (5554..5584) не совпадает ни с одним из этих портов, ни с консольным или ADB-портом другого child, ни с сервером другого child: `AVD_PORT` уникальны, это проверяет `MATRIX_PORT_KOLLIZIJA`. Выход за пределы этого диапазона — совет С-2 ниже.

### 2.4. Красное: оба мутанта из задания и третий краснеют на продуктовой копии

Каждый мутант — полная копия OBJECT, в которой отличается одна строка 1530 (`diff -r` показал ровно одну строку):

```
== mut-old   (export ADB_SERVER_PORT="$((AVD_PORT + 1))" — байт прежнего кандидата 3b6365ebe)
КЛЕТКА allocator КРАСНА: MATRIX_ALLOCATOR
КЛЕТКА workflow-e2e-screen-run-step-4 КРАСНА: WORKFLOW_CONTROL_workflow-e2e-screen-run-step-4
клеток 396, зелёных 394, красных 2
клеток 79, зелёных 79, красных 0
rc=1
== mut-p1    (export ANDROID_ADB_SERVER_PORT="$((AVD_PORT + 1))" — порт ADB самого эмулятора)
КЛЕТКА allocator КРАСНА: MATRIX_ALLOCATOR
КЛЕТКА workflow-e2e-screen-run-step-4 КРАСНА: WORKFLOW_CONTROL_workflow-e2e-screen-run-step-4
клеток 396, зелёных 394, красных 2
клеток 79, зелёных 79, красных 0
rc=1
== mut-var   (export ADB_SERVER_PORT="$((AVD_PORT + 20000))" — верный порт, мёртвое имя)
КЛЕТКА allocator КРАСНА: MATRIX_ALLOCATOR
КЛЕТКА workflow-e2e-screen-run-step-4 КРАСНА: WORKFLOW_CONTROL_workflow-e2e-screen-run-step-4
клеток 396, зелёных 394, красных 2
клеток 79, зелёных 79, красных 0
rc=1
$ python3 workflow_mutation_sweep.py --repo <mut-old> --verify-dir …/sweep-old
HONEST_CONTROL_RED: workflow-e2e-screen-run-step-4
RC=2
$ python3 workflow_mutation_sweep.py --repo <mut-p1>  →  HONEST_CONTROL_RED: workflow-e2e-screen-run-step-4, rc=2
$ python3 workflow_mutation_sweep.py --repo <mut-var> →  HONEST_CONTROL_RED: workflow-e2e-screen-run-step-4, rc=2
$ bash red_mob_ci_143.sh --stabs (повтор)  →  «клеток 397/397 | стабов 408, привязок 417, живых 0 | клеток 80/80 | стабов 62, привязок 78, непойманных 0», rc 0
$ bash red_mob_ci_143.sh --model  ×3 подряд  →  «клеток 397, зелёных 397, красных 0 | клеток 80, зелёных 80, красных 0», rc 0/0/0
```

Красное есть и в `--stabs` на модели (CI-шаг, §4): `adb-variable-ignored @ allocator КРАСЕН: MATRIX_ALLOCATOR`, `@ workflow-e2e-screen-run-step-4 КРАСЕН: WORKFLOW_CONTROL_…`, `adb-port-emulator @ allocator КРАСЕН: MATRIX_ALLOCATOR`, `@ workflow-e2e-screen-run-step-4 КРАСЕН: WORKFLOW_CONTROL_…`.

### 2.5. Документ продукта больше не утверждает неверного

`STRUCTURE.md:209` теперь сообщает, что runner собственный adb-сервер не настраивает, а порт задаёт job экспортом `ANDROID_ADB_SERVER_PORT`. Это соответствует `run-ci-screen.cjs`: переменную он не читает и наследует окружение job при вызовах `adb`/`emulator`. Расхождение СВЕРКИ-СТАНДАРТОВ из вызова 1 снято.

Формулировка инварианта контракта «свой AVD_HOME/ADB_SERVER_PORT» (frozen 143/4, дельта-И-2) не менялась. Я читаю её по цели — собственный adb-сервер child. Закрытие выполнено действующей переменной, а не правкой прозы. Это соответствует условию закрытия Б-1 из вызова 1.

## 3. Б-2 — закрыт

```
$ git diff 1673a516c ef943c76 -- …/workflow_mutation_sweep.py     # удалены --top-only, --save-cell, --save-dir, --save-conforming-dir и обе ветви записи во внешний каталог
$ python3 workflow_mutation_sweep.py --repo <impl> --top-only
usage: workflow_mutation_sweep.py [-h] (--repo REPO | --model) [--verify-dir VERIFY_DIR]
workflow_mutation_sweep.py: error: unrecognized arguments: --top-only
RC=2
```

Побочная запись во внешний каталог (`--save-conforming-dir`, `--save-cell`) удалена целиком. Интерфейс сократился с 6 флагов до 3 (`--repo | --model`, `--verify-dir`).

## 4. Приёмка на собранном дереве — мои прогоны (батарея ef943c768)

```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Rev143v2/impl; echo RC=$?
… (396 строк «КЛЕТКА … ЗЕЛЕНА»)
клеток 396, зелёных 396, красных 0
клеток 79, зелёных 79, красных 0
RC=0
# своя мера (второй прогон, счёт по строкам): КЛЕТКА ЗЕЛЕНА строк 396 ; уникальных имён 396 ; не-ЗЕЛЕНА строк 0
# legacy 79 = source.json kletki 80 минус i06 под --v3 (как в вызове 1; source.json изменён только в v3_piny)

$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model; echo RC=$?
клеток 397, зелёных 397, красных 0
клеток 80, зелёных 80, красных 0
RC=0                                    # своя мера: КЛЕТКА ЗЕЛЕНА 397

$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs; echo RC=$?
клеток 397, зелёных 397, красных 0
стабов 408, привязок 417, живых 0
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
RC=0
# своя мера по сырому выводу: СТАБ-строк 417 ; уникальных стабов 408 ; уникальных пар стаб@клетка 417 ; КЛЕТКА ЗЕЛЕНА 397 ; STAB_ZHIV 0

$ python3 fixtures/workshop_project/mob_ci_143/workflow_mutation_sweep.py --repo /tmp/dev-harness-verify/Rev143v2/impl --verify-dir /tmp/dev-harness-verify/Rev143v2/sweep; echo RC=$?
ПОЛЕ	КЛЕТКА	МУТАНТ
root.concurrency	workflow-root-concurrency	КРАСЕН rc 1
… (316 строк; среди них e2e-screen.run.4	workflow-e2e-screen-run-step-4	КРАСЕН rc 1)
полей 316, мутантов 316, поймано 316, живых 0
RC=0
# своя мера: КРАСЕН-строк 316 ; уникальных клеток 316 ; уникальных полей 316

$ python3 fixtures/workshop_project/mob_ci_143/workflow_mutation_sweep.py --model --verify-dir …/sweep-model; echo RC=$?
полей 308, мутантов 308, поймано 308, живых 0
RC=0
# своя мера: КРАСЕН-строк 308 ; уникальных клеток 308
```

Все счётные утверждения задания и `osi.md` сошлись с моей мерой: 396/396 и 79/79; `--model` 397/397 и 80/80; `--stabs` 408/417/0 и 62/78/0; sweep 316/316 на зеркале и 308/308 на `--model`. По сравнению с вызовом 1 добавились 2 стаба и 4 привязки (406→408, 413→417), что равно двум новым adb-стабам по двум клеткам каждый. Формула счёта в `matrix_v3.py:1235-1237` по-прежнему держится на ручных константах (25→27, 32→36). Совет С-1 вызова 1 остаётся в силе, напечатанное число совпало с моей мерой.

### Проводка (контракт 038)

```
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Rev143v2/arch contracts/143-mob-ci-razdelenie.md; echo rc=$?
rc=0
registry/ci-steps.tsv:139  step	check:mob-ci-razdelenie-143-family-selftest	35	bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
registry/ci-zamery.tsv:86  check:mob-ci-razdelenie-143-family-selftest	35	1	0
.github/workflows/ci.yml:284  keys: … check:mob-ci-razdelenie-143-family-selftest …
```

Новые adb-стабы исполняются внутри `matrix_v3.py --stabs`, который вызывает этот CI-шаг. Значит, барьер Б-1 подключён к CI самого предмета. Комментарий `registry/ci-steps.tsv:138` («71 клетка / 52 стаба / 68 привязок») по-прежнему устарел — это совет С-3 вызова 1, адресат orchestrator, вне диффа.

## 5. Проверка не подогнана под код

- Implementer не трогал файлов батареи (§1). Architect не трогал продукт.
- Новая клетка строже прежней: подстрока заменена точной строкой. Три мутанта, проходившие или способные пройти старую клетку, теперь красные (§2.4). Ни одна существующая клетка или стаб не ослаблены: в диффе `matrix_v3.py` только ужесточение `allocator`, блок новых стабов и константы счёта.

## 6. Паразитная сложность (контракт 050) — по артефактам диффа вызова 2

| Артефакт | (1) свойство контракта | (2) состояние, явность | (3) файлов на правку свойства | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| строка `export ANDROID_ADB_SERVER_PORT=…+20000` (модель + продукт) | дельта-И-2: свой adb-сервер child | env шага, видно в YAML | модель + продукт + `STRUCTURE.md` (3; было столько же) | — | adb/emulator child (§2.2) | ESSENTIAL |
| `allocator`: точная строка вместо подстроки | дельта-И-2 по действию | нет | 1 (+ модель) | интерфейс не вырос | CI `--stabs`, `--repo` | ESSENTIAL |
| стабы `adb-variable-ignored`/`adb-port-emulator` (одна семья) | Н-39: красное на различимом входе по Б-1 | нет; якорь `ORACLE_TAMPERED` rc 2 | 1 | 2 подмены × 2 клетки | CI `--stabs` | ESSENTIAL |
| удаление 4 флагов sweep | — (снятие ACCIDENTAL Б-2) | убрана побочная запись во внешний каталог | 1 | интерфейс 6→3 флага | — | снято |
| флаг `--model` sweep (`workflow_mutation_sweep.py:23-27`) | честный контроль sweep на собранном эталоне до продукта (форма `--model`, прецедент 139/141 в контракте; сценарий «дано модель… `V --model`») | нет нового состояния; явный взаимоисключающий режим | 1 (+ `osi.md`) | 1 флаг на независимый от продукта контроль: глубокий | строка приёмки задания architect `/tmp/dev-harness-verify/orch/task-143-architect-b1.md` п. 4 (`workflow_mutation_sweep.py --model`); шага CI нет | ESSENTIAL: более простая форма `--repo fixtures/…/mob_ci_143/model` не проходит — `HONEST_CONTROL_RED: workflow-root-jobs`, rc 2 (в каталоге модели лежит v2-база без v3-наложения) |

## 7. СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта объявляет стандартом структуры `STRUCTURE.md` и `mobile/structure-policy.json`. `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` в продукте на 51ec88ac отсутствуют (`gh api …/contents` → Not Found).

СВЕРКА-СТАНДАРТОВ: STRUCTURE.md §7.1 CI-наборы экранов (строка `run-ci-screen.cjs`, `STRUCTURE.md:209`) — соответствует (расхождение вызова 1 снято, §2.5); STRUCTURE.md §дерево `mobile/scripts/` — соответствует (дифф не меняет состав); `structure-policy.json` — дифф не затрагивает.

## 8. Находки

### Блоки
Нет.

### Советы
- [ ] **С-2 (architect; совет вызова 1 подтверждён и уточнён).** Селектор (`select-ci-screens.cjs:416-418`) и runner (`run-ci-screen.cjs:15`) принимают любой чётный `avd_port` в диапазоне 1024..65534, кроме legacy. Гарантия непересечения из §2.3 держится только при `AVD_PORT` 5554..5584. По чтению кода предиката, вне этого диапазона есть два контрпримера:
  1. Две записи карты `avd_port: 5574` и `avd_port: 25574` обе проходят селектор. Тогда консоль эмулятора одного child (25574) совпадает с adb-сервером другого (5574+20000).
  2. `avd_port: 45536` проходит селектор, но даёт `ANDROID_ADB_SERVER_PORT=65536`, и adb откажет (исполнено на значении 70000: `must be a positive number less than 65535`, rc 1).

  Пока ни один новый экран не записан. Названного обязательства на диапазон нет, поэтому это совет, не блок. Вероятное лекарство — сузить предикат до 5554..5584 в модели, клетке и продукте.
- [ ] **С-4 (architect; новый класс вне рамки Б-1, по условию задания — принятый остаточный риск).** Maestro станции не читает `ANDROID_ADB_SERVER_PORT`:
  - в `maestro-cli-2.11.0.jar` и `maestro-client.jar` 0 вхождений строки `ANDROID_ADB_SERVER_PORT`;
  - `dadb-2.0.0.jar`: `AdbServer.createDadb$default`/`listDadbs$default` → `sipush 5037`, `Dadb$Companion.list` → `sipush 5555`, `getenv` нет (javap).

  Шаг `maestro --device emulator-<port> test` (`run-ci-screen.cjs:37`) поэтому ходит через общий сервер 5037 или напрямую к adbd эмулятора, а не через сервер child. Значит, изоляция adb-сервера child распространяется на вызовы `adb`/`emulator` runner-а, но не на Maestro. Два сервера (свой и 5037) одновременно видят один эмулятор. [INFERENCE] Вызывает ли это сигнатуру `device offline` на живом KVM, не установлено: путь `e2e-screen` вживую не исполнялся (`skipping` в checks PR #164, матрица пуста). Первый прогон нового экрана (147/148) — место наблюдения.

### Наблюдения
- [ ] **Н-1 (orchestrator).** Live CI PR #164 на 51ec88ac в момент суда: (`gh pr checks 164`, 17:49 UTC) `select-screens`/`quality`/`build-apk`/`e2e-splash`/`e2e-first-run`/`e2e-erstinformation`/`e2e-pilot` pass, `e2e-start` pending, `e2e-screen` skipping. Суд вынесен по собранному дереву. Слияние mob#164 — по зелёному required `android-e2e` на этом head.
- [ ] **Н-2 (orchestrator).** Н-1 вызова 1 остаётся в силе: `wip/143/implementer` — зеркало продукта в корне харнесса, в main харнесса его не сливать. Реализация попадает только в продукт (PR #164), в main — батарея (PR #532) и вердикты.
- [ ] **Н-3 (architect).** Сообщение коммита `ef943c76` называет только adb-изоляцию, хотя тот же коммит закрывает и Б-2 (удаление флагов sweep, `--model`). Оба изменения — правки одного предмета по одному вердикту, поэтому это не нарушение атомарности, но история читается неполно.

## 9. Итог

**accept** для OBJECT 3161fc9dd (= продукт PR #164 head 51ec88ac по блобам) вместе с батареей ef943c768 (PR dev-harness#532).

- Б-1 закрыт исполнением: adb читает новую переменную; три мутанта (старое имя, порт эмулятора, верный порт с мёртвым именем) краснеют адресно; порты 25554..25584 не пересекаются ни с одним портом job-ов матрицы.
- Б-2 закрыт: четыре флага удалены, добавленный `--model` — ESSENTIAL.
- Приёмка 396/79, 397/80, 408/417/0 + 62/78/0, sweep 316 и 308 подтверждены моей мерой.
- Контракт не менялся, проводка цела, область правки в пределах зон.

Accept привязан к этим двум SHA. Любое изменение поведения, критерия или заявленной границы риска делает его неприменимым.
