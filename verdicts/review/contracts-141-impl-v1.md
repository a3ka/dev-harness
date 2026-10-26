accept
OBJECT=33beed4ca3ac5bc77cef628ce874b2f1f5c1d277

СУД: repo=Complior-mob (+dev-harness); предмет=141; фаза=реализация; роль=reviewer; вызов=1/2; модель-план=anthropic/claude-opus-5-5; сессия=Rev141 (01a177ee-2a48-75af-86f8-4e9d5af0e8c0); модель-факт=anthropic/claude-opus-5-5; SHA=33beed4ca3ac5bc77cef628ce874b2f1f5c1d277; предыдущий=нет; исключение=нет; независимость: автор — implementer (коммит `implementer <implementer@dev-harness.local>`), судья — reviewer, иная роль и сессия

СВЕРКА-СТАНДАРТОВ: харнесс AGENTS.md §правило 1 «правило без механизма» — соответствует (guard = батарея 141, красна на базе 25/41); §правило 2 «скрипт не печатает PASS — rc» — соответствует (тела выходят `exit "$rc"`/`exit 1`, PASS не печатают; батарея судит rc); §правило 3 «красная против обманной заглушки» — соответствует (база 20a0acb7 rc 1, 25 KRASNO; `--stabs` 47/61, живых 0; пять своих мутаций — все красны); §правило 4 «другой мерой» — соответствует (свои measure.py/replay.py, см. ниже); §правило 6 «каждая команда run: имеет пункт в приёмке» — соответствует по телам (replay 22 входа), но канал ПРОВОДКА ещё не подключён в CI харнесса — расхождение: `.github/workflows/ci.yml`/`registry/ci-steps.tsv` харнесса не вызывают `red_obryv_adb_diagnostika_141.sh` (check_provodka rc 1), зона orchestrator в окне freeze..done, СОВЕТ С5; §правило 11 (РАЗРЕШИЛ) — соответствует (строка в первой колонке тела коммита, побайтово = слову владельца 26.10 в HANDOFF.md:5); §правило 16 «по-русски» — соответствует (маркеры ДИАГНОСТИКА/ПОВТОР/ОТКАЗ). Продукт STRUCTURE.md §2 (`.github/workflows/ # mobile.yml: quality и android-e2e`) — соответствует (правка внутри job android-e2e, имена/оболочка job неизменны); STRUCTURE.md §7 (артефакты; секреты/ПД недопустимы; maestro-out — runtime output) — соответствует (диагностика читает runtime-каталоги, tracked-файлов не добавляет; в лог идёт хвост emulator-лога с публичным adb-ключом раннера — не секрет, СОВЕТ С3); STRUCTURE.md §1/§4/§5/§6 — не касается (код приложения, маршруты, API, дизайн-система дифф не трогает); корневой AGENTS.md «Данные и окружение: секреты не кладутся» — соответствует (PILOT_DEMO_CODE в шаг 995 не передаётся, env шага не добавлен); корневой AGENTS.md «обязательные проверки quality и android-e2e» — соответствует (имена job и оболочка равны базе); mobile/AGENTS.md (Expo SDK, `npx expo install`, CNG `android/`/`ios/`) — не касается: дифф — CI-обвязка, ни Expo API, ни пакетов, ни нативных каталогов.

перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код

## БЛОКИРУЕТ

нет. Файл `.review/2026-10-26-01.md` не заводится (блокеров нет).

## СОВЕТ

- **С1 (класс: fail-open вспомогательных команд, носитель — модель 141, не implementer).** Функции `boot135`/`boot118` вызываются в контексте `if ! bootN`, а `run_priemkaN` — под `set +e`; bash в обоих контекстах гасит errexit внутри функции. Отказы `adb shell settings put global …` (135/118) и `cp .harness118/scripts/sverka_maketa.py .harness123/scripts/` (118) больше не краснят шаг: replay2 — база `rc=1 validators=0`, OBJECT `rc=0 validators=1 proverka=1` (сценарии SC_SETTINGS_FAIL, SC_NO_SVERKA). Для `cp` это означало бы сверку прежним раннером `.harness123` вместо раннера пина 118. Состояние сейчас недостижимо: пин `.harness118@5dbcb549` несёт файл (в живом прогоне cp прошёл), поэтому не блок. Тело побайтово равно модели, implementer отклониться не вправе. Для архитектора v+1: `|| return 1` на cp/settings внутри функций.
- **С2 (класс: взаимодействие с 139, перекрёстный шаг).** Если шаг повтором спасён, строки сигнатур из его диагностики остаются в логе job ВНЕ эха (живой run 40316137237, строки лога 3429–3432: `device offline`, `DeviceServerDiedException`). Любой последующий продуктовый провал того же job (`Check rehearsal evidence`, proverka 118 и т.д.) даст 139 повод на `gh run rerun --failed`, хотя упало не по инфраструктуре. Вред ограничен: один rerun (страж `run_attempt == 1`), красный итог сохраняется. В НЕ ЗАЩИЩАЕТ контракта назван только «смешанный лог» внутри шага, межшаговый случай не назван. Для владельца/архитектора: печатать сигнатуры только при красном итоге шага или сузить 139 до лога упавшего шага.
- **С3 (класс: содержимое лога).** Хвост `emulator-$AVD.log` печатает `androidboot.qemu.adb.pubkey=…`, публичный adb-ключ раннера, и `androidboot.serialno` (живой лог, строки 3434–3473). Это публичный ключ, секрет не утекает, GH-маскировка не нужна. Отмечаю как свойство канала.
- **С4 (класс: потеря пояснений, носитель — модель).** Из тела 118 удалены два блока комментариев базы: обоснование копии манифеста/раннера («проба 117 требует ровно один шаг с литералом пути раннера») и «`--repo` абсолютным путём… развалился бы в rc 127». Поведение не изменилось (нормализация канона их отбрасывает), но защитная мотивация в файле пропала. Совет v+1: вернуть (форма свободна, `pereformat` зелен).
- **С5 (класс: ПРОВОДКА не подключена — зона orchestrator).** `bash scripts/check_provodka.sh <копия харнесса> contracts/141-obryv-adb-diagnostika.md` → rc 1 `проводка: guard не подключён: …red_obryv_adb_diagnostika_141.sh не вызывается в .githooks/ или .github/workflows/`. По контракту это интеграционный коммит оркестратора в окне freeze..done. `done_contract.sh` (шаг 6) отказывает механически, поэтому done без проводки недостижим. Для этого OBJECT не блок, но предусловие done.
- **С6 (класс: известный перепин).** После merge устаревает пин байтов mobile.yml у 139 (инвариант 6), нужен перепин 139/1 → v2 отдельным решением. CI харнесса не покраснеет: 139 подключён в режиме `--stabs` (`registry/ci-steps.tsv:198`), а не против живого продукта.

## Сырые команды, rc, выводы

### 1. Область правки
```
$ git -C mob log -1 --format='%H%nauthor=%an <%ae>%ncommitter=%cn%nparents=%P%n---%n%B' 33beed4c
33beed4ca3ac5bc77cef628ce874b2f1f5c1d277
author=implementer <implementer@dev-harness.local>
committer=implementer
parents=20a0acb72c64f1b42d14c60aa6c79a13aa63489b
---
141: диагностика обрыва adb и один повтор по сигнатуре в шагах 135/118/995 mobile.yml

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: тела шагов 135/1, 118/2, 995/1, 117/2 mobile.yml — в объёме контракта 141 (вывод ошибки обрыва adb в лог + один повтор по канонической сигнатуре), слово владельца 2026-10-26
$ git -C mob diff --stat 20a0acb7..33beed4c
 .github/workflows/mobile.yml | 214 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 158 insertions(+), 56 deletions(-)
```
Зона из frozen-текста (`git show 'frozen/contracts/141/1^{commit}:contracts/141-obryv-adb-diagnostika.md'`, строки 70–75): `ЗОНА implementer: .github/workflows/mobile.yml`; ПЕРЕСЕЧЕНИЕ 135/118/995 разрешают правку тел, ПЕРЕСЕЧЕНИЕ 117 — «шаги 117/123 и пин H НЕ правятся».

Своя мера, разбор YAML и сравнение по шагам (`work/measure.py`, rc 0):
```
sha256 model/mobile.yml b7cd9c518c542e5e8b259f6a4d2d9a9ad64ba8c68d0498afe1f8cd46d5c7a353
workflow+job shell equal (без steps): True
jobs: ['quality', 'android-e2e']
job quality: steps base=19 obj=19
job android-e2e: steps base=26 obj=26
  CHANGED #8 name='Maestro runner для CMP-MOB-001 (через maestro_probe.py → ci-e2e.sh)' ... keys=['name', 'run', 'working-directory'] diffkeys=['run']
  CHANGED #15 name='135 first-run-ekran (...)' ... keys=['name', 'run', 'working-directory'] diffkeys=['run']
  CHANGED #20 name='118 erstinformation (...)' ... keys=['name', 'run', 'working-directory'] diffkeys=['run']
steps total=45 same=42 changed=3
[135 first-run-ekran] ... norm_body_eq_model=True raw_body_eq_model=True lines=85 sig_count=2 povtor_count=1 maestro_probe_calls=0
[118 erstinformation] ... norm_body_eq_model=True raw_body_eq_model=True lines=87 sig_count=2 povtor_count=1 maestro_probe_calls=0
[Maestro runner для CMP-MOB-001] ... norm_body_eq_model=True raw_body_eq_model=True lines=18 sig_count=1 povtor_count=0 maestro_probe_calls=1
OBJECT file == model file bytes: True
```
Итог: 42 из 45 шагов (в т.ч. 117, 123 и все checkout-пины H) по объекту равны базе. У трёх целевых шагов изменён только ключ `run`; ключи ровно `name`/`run`/`working-directory`, без `if`/`continue-on-error`/`env`/`shell`. Оболочка workflow и обоих job (вне steps) равна базе. Файл OBJECT побайтово равен `model/mobile.yml` (sha256 совпадает с пином контракта `b7cd9c518…`). Флаг `mention 'probe.py '` в шаге 995 ложный: это `maestro_probe.py` базы, а не probe.py батареи. Упоминаний батареи/фикстур 141 в телах нет.

### 2. РАЗРЕШИЛ-ВЛАДЕЛЕЦ (`work/razreshil.py`, rc 0)
```
commit lines with РАЗРЕШИЛ: 1
  first-column: True 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: тела шагов 135/1, 118/2, 995/1, 117/2 mobile.yml — в объёме контракта 141 (вывод ошибки обрыва adb в лог + один повтор по канонической сигнатуре), слово владельца 2026-10-26'
HANDOFF quoted lines: 1
  equal to commit line: True
equal to task text: True
```

### 3. Батарея и красное (харнесс main `14a5a0088`, `W=fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh`)
```
$ bash $W --repo /tmp/dev-harness-verify/Rev141/mob        # полный вывод: 41 строка CASE … ok, real 0m11.458s
RC=0
$ bash $W --repo …/mob | cut -d' ' -f1,3- | sort | uniq -c
     41 CASE ok
RC=0
$ bash $W --model | … | uniq -c
     41 CASE ok
RC=0
$ env -u MOB_REPO bash $W | … | uniq -c
SUBJECT_ABSENT: нет субъекта .github/workflows/mobile.yml; зелень без субъекта невозможна
     41 CASE KRASNO (SUBJECT_ABSENT)
RC=1
$ bash $W --stabs | tee work/stabs.out | cut -d' ' -f1,2 | sort -u | cut -d' ' -f1 | uniq -c
     41 CASE
     47 STAB
      1 SVJAZI
      1 zhivykh
RC=0
  (другой разрез того же прогона: 61 STAB KRASEN; stabs.out:103 `SVJAZI 61`, :104 `zhivykh 0`)
$ (копия work/mob-base @ 20a0acb72c64f1b42d14c60aa6c79a13aa63489b) bash $W --repo …/work/mob-base | cut -d' ' -f1,3 | sort | uniq -c
     25 CASE KRASNO
     16 CASE ok
RC=1
```
Красные на базе: все replay 135/118/995, кроме `*-zelenyj`, плюс `struktura-shag135/118/995` (`SKRIPT_RASHOZHDENIE`) и `struktura-signatura135/118/995` (`PODMENA_SIGNATURY: вхождений канона 0, ожидалось 2/2/1`). Зелёные: пять управляющих (шаг ×3, job, workflow), три pereformat, vyrazhenija, четыре derevo, три zelenyj. Показательно: `135-stabil-nedostizhima KRASNO (CHISTYJ: rc=0 (ожидался 1))` на базе — это прежняя дыра «прогнал и забыл».

Свои мутации OBJECT в копиях (`work/mutate.py`, rc 0):
```
m1-continue-on-error-135: rc=1 ok=40 krasno=1   (UPRAVLYAYUSHCHIJ_KLYUCH: shag 135: лишние ключи: continue-on-error)
m2-tretij-progon-118:     rc=1 ok=39 krasno=2   (118-povtor-tozhe-krasen rc=0 ожидался 1; SKRIPT_RASHOZHDENIE строка 82)
m3-995-glotanie-rc:       rc=1 ok=38 krasno=3   (995-diag-signatura / 995-chistyj-proval rc=0 ожидался 1; строка 18)
m4-povtor-bez-boot-135:   rc=1 ok=35 krasno=6   (журнал без второго EMULATOR)
m5-hvost-5-118:           rc=1 ok=39 krasno=2   (нет маркера вывода emulator-лога; строка 57)
z1-chuzhoj-shag-kommentarij: rc=0 ok=41 krasno=0 (чужой шаг не судится — инвариант 9)
```
Канон сигнатур: строка source.json `signatury_regex` = `device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException`, вхождений 2/2/1 (measure.py `sig_count`). Перечень 139 не расширен: `mobile-e2e-retry.yml` в диффе отсутствует (дифф — один файл), канон 141 — это ровно первые четыре альтернативы `signatury_regex` 139.

### 4. Код шагов по существу: свой replay (`work/replay.py`, `bash --noprofile --norc -e`, как `shell: /usr/bin/bash -e {0}` живого лога; свои шимы adb/emulator/python3/avdmanager/sleep/pkill, rc 0)
```
== 135 {} -> rc=0 emulators=1 validators=1 proverka=1 ДИАГНОСТИКА-маркеров=0 ПОВТОР=0
== 135 офлайн→зелень   -> rc=0 emulators=2 validators=2 proverka=1 ДИАГНОСТИКА=3 ПОВТОР=1 (хвост 40 строк, last='emu1 LAST LINE')
== 135 офлайн→DSDE rc4 -> rc=4 emulators=2 validators=2 proverka=0 ДИАГНОСТИКА=6 ПОВТОР=1 (второй хвост — emu2)
== 135 assert rc3      -> rc=3 emulators=1 validators=1 ДИАГНОСТИКА=3 ПОВТОР=0
== 135 INSTALL_FAILED  -> rc=1 emulators=1 validators=1 ДИАГНОСТИКА=3 ПОВТОР=0
== 135 'adb: device emulator-5564 not found' -> rc=0 emulators=2 validators=2 ПОВТОР=1
== 135 get-state offline -> rc=1 validators=0 ОТКАЗ=['ОТКАЗ: эмулятор emulator-5564 не стабилизировался (adb offline)']
== 135 boot_completed≠1 -> rc=1 validators=0 ОТКАЗ=['ОТКАЗ: эмулятор 135 не загрузился за 390 с']
== 135 install fail    -> rc=1 validators=0 ДИАГНОСТИКА=3
(118 — те же девять исходов один в один, ОТКАЗ emulator-5566 / «118 не загрузился»)
== 995 {}              -> rc=0 validators=1
== 995 офлайн rc1      -> rc=1 validators=1 ДИАГНОСТИКА=2 ПОВТОР=0
== 995 assert rc5      -> rc=5 validators=1 ДИАГНОСТИКА=2 ПОВТОР=0
```
Повтор ровно один. Второй красный выходит своим rc (4) без третьего запуска. Исход повтора не глотается: последняя проверка `[ "$rc" -eq 0 ] || exit "$rc"`. `grep … >&2 2>/dev/null || true` по порядку перенаправлений верен: совпадения уходят в stderr, ошибки grep — в /dev/null. `|| true` стоит только на диагностике, на итоговом rc его нет. `bash -n` трёх тел (`work/body-obj-{135,118,995}.sh`) — rc 0/0/0. shellcheck на станции отсутствует (`command -v shellcheck` rc 1), не проверено.

Прежний зелёный путь (`work/replay2.py`): зелёные сценарии 135/118 на базе и на OBJECT дают одинаково `rc=0 emulators=1 validators=1 proverka=1`. Различие только в отказах вспомогательных команд (СОВЕТ С1): `SC_SETTINGS_FAIL` 135/118 и `SC_NO_SVERKA` 118 на базе дают rc=1, на OBJECT rc=0.

Путь `emulator-$AVD.log`: запуск и `tail` идут в одном cwd (`working-directory: ${{ github.workspace }}`, функции cwd не меняют). Живой лог подтверждает: `ДИАГНОСТИКА 118: хвост emulator-ci118-40316137237-1.log`, следом строки qemu.

### 5. Проверки не переписаны под код
```
$ git -C harness diff --stat frozen/contracts/141/1 origin/main -- fixtures/workshop_project/obryv_adb_diagnostika_141 contracts/141-obryv-adb-diagnostika.md
(пусто) DIFFRC=0
$ git -C harness log --format='%h %an %s' -- fixtures/workshop_project/obryv_adb_diagnostika_141 contracts/141-obryv-adb-diagnostika.md
828a0864 architect 141 v1-испр. 2: …
c1eaffc1 architect 141 исправительный: …
c978eeae architect 141 obryv-adb-diagnostika: контракт и батарея …
$ git -C harness log --author=implementer --since=2026-10-25 origin/main  → только 136 v2*; по 141 коммитов implementer в харнессе нет
```

### 6. Живой CI и остатки
```
$ gh run view 40316137237 -R a3ka/Complior-mob --json headSha,conclusion,…
{"conclusion":"success","event":"pull_request","headBranch":"cmp-mob-118/erstinformation-prod","headSha":"33beed4ca3ac5bc77cef628ce874b2f1f5c1d277","jobs":[{"name":"quality","conclusion":"success"},{"name":"android-e2e","conclusion":"success"}]}
run_attempt=1
$ gh api repos/a3ka/Complior-mob/actions/jobs/121550082504/logs | tee work/e2e-40316137237.log | wc -l
3688
```
**В живом прогоне на head сработал путь повтора шага 118:**
```
3422 ##[endgroup]
3424 PRICHINA	E2E_NE_PROSHLA	rc=1
3425 ДИАГНОСТИКА 118: adb devices
3426 List of devices attached
3428 ДИАГНОСТИКА 118: сигнатуры Maestro в mobile/maestro-out-erstinformation
3429 …/commands.json:73: "message" : "Command failed (host:transport:emulator-5566): device offline"
3431 …/logs/maestro.log:10:maestro.android.DeviceServerDiedException: Device server died during 'deviceInfo' on emulator-5566 …
3433 ДИАГНОСТИКА 118: хвост emulator-ci118-40316137237-1.log
… (40 строк qemu, последняя «INFO | Increasing screen off timeout, logcat buffer size to 2M.»)
3474 ПОВТОР: обрыв adb-транспорта эмулятора 118 — перезапуск эмулятора и валидатора
3475–3500 KADR … OK ×16; SHABLON erstinformation OK → шаг зелёный
```
Живьём доказано (один образец): диагностика 118 печатается ПОСЛЕ `##[endgroup]`, то есть вне эха; сигнатуры из maestro-out-erstinformation находятся; хвост emulator-лога печатается из верного пути; повтор с перезапуском эмулятора спас шаг. Первая точка «Живых измерений» контракта: `adb devices` пуст (устройство исчезло целиком, это не `offline`), в хвосте qemu нет ни ошибки, ни краша. Шаги 135 и 995 в этом прогоне прошли с первого раза: runtime-строк `ДИАГНОСТИКА 135/995` нет. Сигнатур только-139 (`emulator: ERROR|INSTALL_FAILED|Timeout waiting for emulator`) в логе нет.

**Живым CI НЕ доказано:** повтор 135, повтор, который тоже красен (итог rc≠0 без третьего прогона), ОТКАЗ стабильности/загрузки в живую, диагностика 995 при красном (в т.ч. судьба `adb devices` в cwd 995), поведение 139 на красном прогоне с диагностикой 141. Всё это показано только replay (батарея и свой).

**Двойной повтор 141×139:** 139 срабатывает только на `conclusion == failure ∧ run_attempt == 1` и ищет сигнатуры в логе job ВНЕ эха. Худший случай для шага 135/118: два прогона в attempt 1 и два в attempt 2, итого четыре старта эмулятора и валидатора. Для 995: внутренний повтор ci-e2e.sh × rerun 139. Серии нет: оба уровня ограничены (шаг — один `if`, 139 — `run_attempt == 1`). Риск ложного rerun 139 — СОВЕТ С2. Тексты `ПОВТОР:`/`ОТКАЗ: … (adb offline)`/`ДИАГНОСТИКА …:` не содержат ни одной альтернативы regex 139 (`adb offline` ≠ `device offline`). Сигнатуру 139 вне эха дают только строки grep из maestro-out и, при случае, хвост emulator-лога.

## Паразитная сложность (контракт 050)

- **Семья функций `boot135`/`boot118`, `diag135`/`diag118`, `run_priemka135`/`run_priemka118` и блок diag-хвоста 995 (один артефакт семьи).** (1) Свойство: инварианты 2–6 (диагностика вне эха, ровно один повтор с перезапуском эмулятора и валидатора, проверка итога стабильности) и инвариант 1: тела построчно равны модели. (2) Состояние: переменная `rc` и файл `emulator-$AVD.log` (перезаписывается при повторе, но первый хвост печатается до повтора). Состояние явное: видно в выводе (маркеры ДИАГНОСТИКА/ПОВТОР/ОТКАЗ) и в rc шага; новых env не читается. (3) Совместная правка: логика boot/стабильности теперь живёт в 117, 135 и 118 шагах mobile.yml и в ci-e2e.sh. Мест загрузки было четыре до диффа (117/135/118 inline + ci-e2e) и осталось четыре; мест ретрая с сигнатурой стало на два больше (135, 118), к ним добавились модель батареи 141 и regex 139. (4) Глубина: интерфейс функций без аргументов, rc 0/≠0, работа за ним — загрузка, стабильность, установка APK. Модуль не мелкий. (5) Потребители: строки приёмки 1–5 контракта (replay 22 входа и struktura). Общий скрипт `mobile/scripts/…` был бы проще, но не проходит приёмку: вариант В требует равенства тел модели построчно, а `ci-e2e.sh` — зона 995. Сложность ESSENTIAL.
