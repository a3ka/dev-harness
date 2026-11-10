FAIL
OBJECT=1673a516c4a2d2244a170f6cf13e8d7068c222d1
СУД: repo=dev-harness+Complior-mob (PR #164, head ac0943d7140c0959db022e5984aff4ca334bceda); предмет=143 mob-ci-razdelenie v3/v4; фаза=суд реализации перед слиянием; роль=reviewer; вызов=1 (полный, цикл v3/v4); модель-план=anthropic/claude-opus-5-5 (`config/agent_models.json`: reviewer→audit→@opus); сессия=Rev143v1 (c907157c); модель-факт=anthropic/claude-opus-5-5; кандидат implementer=3b6365ebea316f97d9f165c810fdfabd7f5433cd; контракт=frozen/contracts/143/4 → 8fd88388f973fc6d398a636898745d2b844afeaf; предыдущий=нет (в этом цикле; прошлые циклы: contracts-143-impl-v1 FAIL, -impl-v2 accept, -mech-v2 accept); адверсарий=verdicts/adversary/contracts-143-impl-v5.md accept (Adv143v5).

# Вердикт ревьюера — 143, реализация v3/v4 (вызов 1)

Находки: `.review/2026-11-10-99.md` (status: ready). Блоков 2 (Б-1 — нарушение обязательства дельта-И-2; Б-2 — ACCIDENTAL по 050), советов 3, наблюдений 3.

Файл назван `contracts-143-impl-v3.md`, а не `-impl-v1.md`, как было в задании. Имя `-impl-v1.md` в main занято вердиктом Rev143 от 2026-10-30 (Н-3).

Клон одноразовый, со своим `.git`, origin `ssh://git@github.com/a3ka/dev-harness.git`: `/tmp/dev-harness-verify/Rev143v1/repo`. Worktree `../arch` = OBJECT, `../impl` = tip implementer. Продукт читается из `/home/harness/projects/Complior-mob` только на чтение.

## 0. Объект

```
$ git rev-parse origin/wip/143/architect origin/wip/143/implementer origin/wip/143/adversary
1673a516c4a2d2244a170f6cf13e8d7068c222d1
3b6365ebea316f97d9f165c810fdfabd7f5433cd
2ebfd8a552ff230562801e6686a60e785c975899
$ for r in origin/main origin/wip/143/architect origin/wip/143/implementer; do git diff --quiet 'frozen/contracts/143/4^{commit}' $r -- contracts/143-mob-ci-razdelenie.md; echo $r rc=$?; done
origin/main: rc=0
origin/wip/143/architect: rc=0
origin/wip/143/implementer: rc=0
```

## 1. Область правки ⊆ зоны (моя мера: имена файлов диффа и авторы)

```
ЗОНА architect: contracts/143-mob-ci-razdelenie.md fixtures/workshop_project/mob_ci_143/
ЗОНА implementer: .github/workflows/mobile.yml .github/workflows/mobile-e2e-retry.yml mobile/ci-screens.json mobile/scripts/select-ci-screens.cjs mobile/scripts/ci-aggregate.cjs mobile/scripts/run-ci-screen.cjs mobile/structure-policy.json STRUCTURE.md

$ git log --format='%h %an <%ae> %s' d984092f..origin/wip/143/implementer
3b6365eb implementer <implementer@dev-harness.local> 143: агрегат не отказывает на опущенном пустом job-output matrix
2d75cf25 implementer <implementer@dev-harness.local> 143: синхронизировать зеркало продукта с tip fabf146 (4 working-directory в .github/workflows/mobile.yml)
b6440e56 implementer <implementer@dev-harness.local> 143 v3: универсальный матричный работник новых экранов (e2e-screen) + матричные ветви селектора и агрегата
$ git diff --stat d984092f origin/wip/143/implementer
 .github/workflows/mobile.yml         | 1633 ++++++++++
 STRUCTURE.md                         |  251 ++++++
 mobile/ci-screens.json               |  106 +++
 mobile/scripts/ci-aggregate.cjs      |  134 +++
 mobile/scripts/run-ci-screen.cjs     |   60 ++
 mobile/scripts/select-ci-screens.cjs |  444 +++++++++
 mobile/structure-policy.json         |   33 +
 7 files changed, 2661 insertions(+)

$ git log --format='%h %an %ad %s' --date=iso d984092f..origin/wip/143/architect
1673a516 architect 2026-11-10 14:36:46 +0000 143: enumerate workflow root controls and permission leaves from YAML
b3c4c8bc architect 2026-11-10 11:11:07 +0000 143: workflow trigger/top-level key mutation sweep (Adv143v4)
$ git diff --stat d984092f origin/wip/143/architect
 fixtures/workshop_project/mob_ci_143/matrix_v3.py  |  48 ++---
 .../mob_ci_143/workflow_mutation_sweep.py          |  48 ++++-
 .../mob_ci_143/workflow_sweep_v3.py                | 237 ++++++++++++++++++++-
 3 files changed, 293 insertions(+), 40 deletions(-)
```

Все пути implementer входят в ЗОНУ implementer, все пути architect — в ЗОНУ architect. Implementer батарею и фикстуры не трогал. Норм (contracts/, roles/, AGENTS.md) не трогал никто.

Зеркало == продукт PR #164, побайтно по блобам:

```
EQ .github/workflows/mobile.yml prod=71ffcf06dd30… mirror=71ffcf06dd30…
EQ .github/workflows/mobile-e2e-retry.yml prod=ABSENT mirror=ABSENT
EQ mobile/ci-screens.json prod=03b9e68b6c6a… mirror=03b9e68b6c6a…
EQ mobile/scripts/select-ci-screens.cjs prod=9c6a0de74e95… mirror=9c6a0de74e95…
EQ mobile/scripts/ci-aggregate.cjs prod=1c0192186554… mirror=1c0192186554…
EQ mobile/scripts/run-ci-screen.cjs prod=c0682214b4c8… mirror=c0682214b4c8…
EQ mobile/structure-policy.json prod=acf0f2aecff3… mirror=acf0f2aecff3…
EQ STRUCTURE.md prod=909bbedeadab… mirror=909bbedeadab…
$ git diff --stat 575f16a1 ac0943d7   # дифф PR #164 продукта к его базе
 7 files changed, 239 insertions(+), 16 deletions(-)   # те же 7 путей зоны, ничего вне
$ gh pr view 164 -R a3ka/Complior-mob --json headRefOid,state,mergeable,statusCheckRollup
head=ac0943d7… state=OPEN mergeable=MERGEABLE; select-screens/quality/build-apk/e2e-splash/e2e-first-run/e2e-erstinformation/e2e-start/e2e-pilot/android-e2e SUCCESS; e2e-screen SKIPPED; mobile-regression-signal SKIPPED
```

Утверждения в коммитах implementer проверены своей мерой. sha256 `ci-aggregate.cjs` на зеркале и в модели одинаковый: `e486e353…8fec6`. Так же совпадают `select-ci-screens.cjs` (`335b4d26…`) и `run-ci-screen.cjs` (`4b76ed11…`). Job `e2e-screen` отличается от `model/matrix-v3.yml` ровно двумя `working-directory: ${{ github.workspace }}`, как заявлено в 2d75cf25.

`check_zones.sh`: см. §6.

## 2. Приёмка на собранном дереве — мой прогон

```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Rev143v1/impl; echo RC=$?
… (396 строк «КЛЕТКА … ЗЕЛЕНА»)
клеток 396, зелёных 396, красных 0
клеток 79, зелёных 79, красных 0
RC=0
$ … | sort | uniq -c | awk '{print $1, $NF}' | sort | uniq -c      # своя мера: уникальные имена клеток
    396 1 ЗЕЛЕНА
$ python3 -c "…len(source.json['kletki'])"                     # 80, минус i06 под --v3 (probe.py:2908) = 79
list 80

$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs; echo RC=$?
стабов 406, привязок 413, живых 0
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
RC=0
# своя мера по сырому выводу (artifact прогона):
СТАБ-строк: 413 ; уникальных стабов: 406 ; уникальных пар стаб@клетка: 413 ; КЛЕТКА ЗЕЛЕНА: 397 ; STAB_ZHIV: 0
$ ls stabs/stab_*.py | wc -l ; python3 -c "…stab_vhod"     # legacy
62
62 78

$ python3 fixtures/workshop_project/mob_ci_143/workflow_mutation_sweep.py --repo /tmp/dev-harness-verify/Rev143v1/impl --verify-dir /tmp/dev-harness-verify/Rev143v1/sweep; echo RC=$?
ПОЛЕ	КЛЕТКА	МУТАНТ
root.concurrency	workflow-root-concurrency	КРАСЕН rc 1
… (316 строк)
полей 316, мутантов 316, поймано 316, живых 0
RC=0
# своя мера: КРАСЕН-строк 316, уникальных клеток 316
```

Все ожидания задания совпали с моими прогонами: 396/396 и 79/79; 406/413/0, 80/80, 62/78/0; 316/316.

## 3. Проверка не подогнана под код; красное предъявлено

- Implementer не менял файлов батареи (§1). Оба коммита architect лежат в его зоне и были сделаны после Adv143v4 по его находке. Они добавляют клетки и ничего не ослабляют: в `matrix_v3.py` (+22/−26 по `git diff --numstat`) удалена только ручная таблица-комментарий «181 rows», её заменил механический перечень `root_controls`; ещё 4 строки — импорт `root_controls` и формула счёта стабов (С-1).
- Каждый новый барьер имеет красное: 316 мутантов sweep, каждый `КРАСЕН rc 1` против своей полной копии кандидата; в `--stabs` 406 обманных субъектов пойманы, живых 0.

## 4. Атомарность и нормы

У implementer три коммита, у architect два. Каждый ссылается на 143, и связок с чужими предметами нет. Нормативные документы не правились. `check_contract_frozen.sh` по 143: `ok … заморожен v4, блоб совпадает побайтово, вердикты v1..v4 разрешают` на main, на OBJECT и на tip implementer. На обоих tip rc 1 только по `contracts/175-…`: база старше заморозки 175 (Н-2). На main rc 0. Обе ветки сливаются в main без конфликтов: `git merge-tree --write-tree origin/main <tip>` → rc 0.

## 5. ПРОВОДКА (контракт 038)

```
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Rev143v1/repo contracts/143-mob-ci-razdelenie.md; echo rc=$?
rc=0
registry/ci-steps.tsv:139  step	check:mob-ci-razdelenie-143-family-selftest	35	bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
registry/ci-zamery.tsv:86  check:mob-ci-razdelenie-143-family-selftest	35	1	0
.github/workflows/ci.yml:284  lane l7 … check:mob-ci-razdelenie-143-family-selftest …
```

guard=`fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh` — это барьер именно этого предмета, и он подключён шагом CI. Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована: батарея — чистый энфорсмент И-1…И-15. Замечание к комментарию ci-steps — совет С-3.

## 6. check_zones

```
$ reslop t -- bash scripts/check_zones.sh /tmp/dev-harness-verify/Rev143v1/arch     # скрипт из main 5d64169a/87b48c61, теги frozen/* все (fetch --tags)
ok: true
passed: 97
failed: 0
замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 51654 · проверено по зонам: 13502
exit: 0
$ reslop t -- bash scripts/check_zones.sh /tmp/dev-harness-verify/Rev143v1/impl
ok: true
passed: 97
failed: 0
замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 51680 · проверено по зонам: 13525
exit: 0
```

## 7. Б-1 — сырой вывод (нарушение «свой AVD_HOME/ADB_SERVER_PORT», дельта-инвариант 2)

```
$ git -C /home/harness/projects/Complior-mob grep -n 'ADB_SERVER_PORT' ac0943d7
ac0943d7:.github/workflows/mobile.yml:1530:          export ADB_SERVER_PORT="$((AVD_PORT + 1))"
$ strings /home/harness/Android/Sdk/platform-tools/adb | grep -n 'SERVER_PORT'
3381:ANDROID_ADB_SERVER_PORT
7324:$ANDROID_ADB_SERVER_PORT must be a positive number less than 65535: got "%s"
$ adb version
Android Debug Bridge version 1.0.41 / Version 37.0.1-15733141
$ strings /home/harness/Android/Sdk/emulator/lib64/libandroid-emu-shared.so | grep ADB_SERVER_PORT | sort -u
ANDROID_ADB_SERVER_PORT
$ adb help | sed -n '/environment variables/,$p'
 $ADB_TRACE … $ADB_VENDOR_KEYS … $ANDROID_SERIAL … $ANDROID_LOG_TAGS … $ADB_LOCAL_TRANSPORT_MAX_PORT max emulator scan port (default 5585, 16 emus) … $ADB_MDNS_AUTO_CONNECT
$ for j in /home/harness/.maestro/lib/*.jar; do unzip -p "$j" | strings | grep -m1 -q ADB_SERVER_PORT && echo "HIT $j"; done; echo scan-done
scan-done          # Maestro не читает ни ADB_SERVER_PORT, ни ANDROID_ADB_SERVER_PORT
$ emulator -help-port
  note that <port> must be an *even* integer between 5554 and 5584 included.
  <port>+1 must also be free and will be reserved for ADB. if any of these ports is already used, the emulator will fail to start.
```

Батарея приколачивает мёртвую переменную. Копия зеркала, где отличается одна строка (`export ADB_SERVER_PORT=` → `export ANDROID_ADB_SERVER_PORT=`):

```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Rev143v1/mut-adb | grep -v ' ЗЕЛЕНА$'; echo rc=${PIPESTATUS[0]}
КЛЕТКА workflow-e2e-screen-run-step-4 КРАСНА: WORKFLOW_CONTROL_workflow-e2e-screen-run-step-4
клеток 396, зелёных 395, красных 1
клеток 79, зелёных 79, красных 0
rc=1
```

Источник — эталон architect `model/matrix-v3.yml:42`, байт в байт. Клетка `allocator` (`matrix_v3.py:601-603`) проверяет подстроку `'ADB_SERVER_PORT=' in launch`. Implementer повторил канон. Исправить дефект в его зоне нельзя, нужна правка модели и клетки. Дальше живой CI `e2e-screen` = SKIPPED (матрица пуста), то есть путь child в CI не исполнялся. Обязательство не выполнено по сути: adb-сервер у всех children общий (5037) и общий с legacy-jobs. `STRUCTURE.md:209` («свой AVD/ADB-порт») утверждает неверное.

## 8. Паразитная сложность (контракт 050) — по артефактам диффа

| Артефакт | (1) свойство контракта | (2) состояние, явность | (3) файлов на правку свойства | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `mobile/scripts/run-ci-screen.cjs` (новый) | дельта-И-2/И-3/И-4: child — свой AVD, APK digest, один повтор по adb-сигнатуре, result.json | AVD_HOME, `mobile/screen-evidence/<id>/result.json` — в аргументах/env и артефакте | модель + продукт (2, побайтно) | 4 флага + 6 env → boot/install/retry/evidence: глубокий | шаг `Run selected screen` `e2e-screen` | ESSENTIAL |
| job `e2e-screen` в `mobile.yml` | дельта-И-2 (strategy.matrix из `select-screens.outputs.matrix`) | `ADB_SERVER_PORT` — мёртвое состояние (Б-1) | модель + продукт | — | агрегаты `needs` | ESSENTIAL; дефект — Б-1 |
| матричная ветвь `ci-aggregate.cjs` (+46) | дельта-И-3 (точное множество id, identity, родитель) | `--evidence <dir>` явно | модель + продукт | один новый флаг на ~20 отказов: глубокий | шаги `Verify selected children` обоих агрегатов | ESSENTIAL |
| `matrix` в `select-ci-screens.cjs` (+34) | дельта-И-1 (matrix из той же selection, повторы id/pack/flow/port) | `selection.json.matrix` + `GITHUB_OUTPUT matrix=` (один писатель) | модель + продукт | интерфейс не вырос (поле карты `avd_port`) | `select-screens.outputs.matrix` | ESSENTIAL |
| `screen-evidence` в `structure-policy.json`/`STRUCTURE.md` | AGENTS.md продукта: STRUCTURE — место кода; generated-деревья | нет | 2 (политика + документ) | — | `quality` (`check-structure.cjs`) | ESSENTIAL |
| `workflow_sweep_v3.py` `root_controls/root_match/root_name/mutate_root` (+237) | ЗАЩИЩАЕТ v4 (Adv143v4: корневые управляющие поля, permissions) | нет, чистые функции | 1 | перечень из YAML, без ручного списка путей | `matrix_v3.py --stabs` (CI), sweep | ESSENTIAL |
| флаги sweep `--top-only/--save-cell/--save-dir/--save-conforming-dir` | нет | `--save-*` пишет во внешний каталог, побочно | 1 | +4 флага без новой функции приёмки: мелко | нет (git grep: 0) | **ACCIDENTAL — Б-2** |
| счёт стабов в `matrix_v3.py` (константы 25/32, `extension_count=8`) | отчёт «стабов N, привязок M» | ручные константы | 1 + каждая новая группа стабов | — | вывод `--stabs` | ACCIDENTAL, совет С-1 (нет фрагмента ложного числа: моя мера совпала) |

## 9. СВЕРКА-СТАНДАРТОВ

AGENTS.md продукта объявляет стандартом структуры `STRUCTURE.md` (+ `mobile/structure-policy.json`). Документов `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` в продукте нет: `git ls-tree` ac0943d7 пуст по этим путям.

СВЕРКА-СТАНДАРТОВ: STRUCTURE.md §дерево `mobile/scripts/` — соответствует (новый `run-ci-screen.cjs` внесён); STRUCTURE.md §generated/runtime output — соответствует (`screen-evidence/` внесён и в `STRUCTURE.md`, и в `structure-policy.json:generatedTrees`); STRUCTURE.md §7.1 CI-наборы экранов — расхождение: `STRUCTURE.md:209`, «свой AVD/ADB-порт» у `run-ci-screen.cjs` не выполняется (Б-1); STRUCTURE.md §7.1 правило подключения нового экрана («пачка + запись карты») — соответствует `select-ci-screens.cjs`/`mobile.yml`.

## 10. Итог

FAIL. Причины:

- **Б-1.** Воспроизводимое нарушение названного обязательства «свой AVD_HOME/ADB_SERVER_PORT» (дельта-инвариант 2): переменную не читают ни adb, ни эмулятор. Батарея приколачивает её в модели. Закрывают architect (модель + клетка `allocator` по действию) и implementer (продукт + `STRUCTURE.md`) либо слово владельца о снятии обязательства.
- **Б-2.** ACCIDENTAL по 050: четыре флага sweep без потребителя. Закрывает architect.

Остальное проверено и подтверждено моей мерой: зоны, зеркало == PR #164, приёмка 396/79, стабы 406/413 и 62/78, sweep 316, неизменность контракта, проводка.

Это FAIL не наследует accept адверсария v5. Его рамка была scoped: top-level permissions/controls. Б-1 и Б-2 лежат вне её.
