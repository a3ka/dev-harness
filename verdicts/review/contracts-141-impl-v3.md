accept
OBJECT=0fb618036812cdcc68bd07ad49f38c2de51e1a5c
КЛАСС=кодовый (КЛАСС РИСКА: обычный — подтверждаю, не повышаю: только CI-обвязка mob, без прав/денег/ПД/согласий; секрет 995 читается тем же предыдущим шагом, тела его не касаются)
СУД: repo=Complior-mob (+dev-harness); предмет=141; фаза=реализация v3; роль=reviewer; вызов=1/1; модель-план=anthropic/claude-opus-5-5; сессия=Rev141v3 (01a1d067-275b-710d-b40a-1394ee8f5855); модель-факт=anthropic/claude-opus-5-5; предыдущий=verdicts/critic/contracts-141-v3.md (ветка wip/141/critic-v3 @ 72af8c04, accept OBJECT=fa8393d8); исключение=нет

Судимая реализация — ПРОДУКТОВЫЙ коммит `3cccaa23286383af61d4ef6b76344de3795ac9cf` (a3ka/Complior-mob, ветка `wip/141/implementer-v3`, PR #171, родитель = origin/main продукта `9442ea4bb65ae7cdeba601cf34855c9504f38b0c`). `OBJECT=` выше — зеркальный пустой коммит харнесса `0fb61803` (`origin/wip/141/implementer`; `git diff --stat origin/main 0fb61803` пуст; автор зеркала — `orchestrator`, не implementer, — расхождение с текстом задания, на суд не влияет).
Контракт: `frozen/contracts/141/3` → коммит `c31903d0d774c9a8278f886c389a92e4385a0204`, блоб `contracts/141-obryv-adb-diagnostika.md` = `300c3e8e2ad62342d1956f2d35865d14de2031e2` — тот же блоб на `origin/wip/141/architect` @ `fa8393d8fc5075df278b639cd993931442bd04ca`; `git diff --stat c31903d0d fa8393d8f` = только `verdicts/critic/contracts-141-v3.md` (батарея на теге и на fa8393 побайтово одна). Все прогоны батареи ниже — из дерева fa8393.

СВЕРКА-СТАНДАРТОВ: Complior-mob STRUCTURE.md §дерево (строка 47 `scripts/ — CI, генерация, проверка структуры; не runtime`) — соответствует (три новых файла — CI-скрипты в `mobile/scripts/`; `check-structure.cjs` их не отвергает: 17 отказов до и 17 после, тот же перечень). STRUCTURE.md §7.1 «CI-наборы экранов» — расхождение: STRUCTURE.md:203-210 (таблица файлов экранного CI-набора) не перечисляет `mobile/scripts/ci-first-run-135.sh`, `ci-erstinformation-118.sh`, `ci-pilot-995.sh`; правка STRUCTURE.md вне ЗОНЫ implementer замороженного блоба — совет С2, не блок. docs/CODING-STANDARDS.md §1 (область `mobile/src`, CI-job'ы не дублирует) — дифф кода `mobile/src` не касается, соответствует. §14 «Ветки, коммиты, PR» — соответствует (ветка `wip/141/implementer-v3` = `wip/NNN/<слог>`; первая строка коммита `141 v3: …`; один PR). §16 чеклист «`npm run lint` зелёный» — предсуществующий красный `check-structure` (17 строк `mobile/e2e-*/…`, `kompozicija.stand-in.sh`) одинаков до/после; ESLint/typecheck/jest — дифф не содержит ни одного js/ts/json-пути (numstat ниже), не затронуты. Харнесс AGENTS.md «скрипт не печатает PASS — rc» — соответствует (скрипты завершаются `exit "$rc"`/`exit 1`).

перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код

## БЛОКИРУЕТ (объект 3cccaa232)

нет.

## НАХОДКИ ВНЕ ОБЪЕКТА — эскалация оркестратору

- **Ф1 (класс: дыра guard против замороженного инварианта 1; зона architect, не implementer).** Инвариант 1 v3: «SHA256 применяется ко ВСЕМ байтам скрипта (включая комментарии)». Батарея читает скрипты субъекта в текстовом режиме с универсальными переводами строк: `probe.py:1484` `(Path(repo) / path).read_text(encoding='utf-8')`, затем пин считает от перекодированного текста `probe.py:666` `sha256_bytes(script.encode('utf-8'))`, а replay пишет в песочницу тот же нормализованный текст `probe.py:588` `script.write_text(script_text, …)`. Следствие: CRLF-версия любого из трёх скриптов (другие байты: у 995 sha256 `8527488408de…` против пина `b10dd3719899…`) проходит `--repo` зелёной 46/46 — мои мутации `pin-135-crlf`, `pin-118-crlf`, `pin-995-crlf`: `rc=0 red=0` (ожидался `SKRIPT_PIN_RASHOZHDENIE`). При этом настоящий bash такой скрипт исполняет иначе модели: `bash ci-pilot-995.crlf.sh` → `line 1: set: -^M: invalid option` (errexit не включается). Объект суда этим НЕ затронут: байты трёх скриптов продукта равны модели (сырые `sha256sum` с диска и `cmp`, ниже; `\r` в файлах — 0). Это охрана ПОСЛЕ merge (`--repo` по живому продукту): нужна правка батареи (чтение `read_bytes()` и пин от сырых байт) в зоне architect по процедуре оркестратора; формулировка инварианта 1 при этом не меняется. Простейшая форма, проходящая те же строки приёмки: `b = (Path(repo)/path).read_bytes(); pin = sha256_bytes(b); text = b.decode('utf-8')` (как уже сделано для модели в `probe.py:1402`).

## СОВЕТ

- **С1 (класс: заявленное ≠ сделанному, текст коммита).** Тело коммита 3cccaa232: «тела перенесены без изменения байтов». Своей мерой (`equiv.py`, ниже): 135 и 118 — да (тело `run:` main == файл скрипта, 3821/4062 байт); 995 — нет: три `${{ github.* }}` заменены на `$GITHUB_WORKSPACE`/`${GITHUB_RUN_ID}`/`${GITHUB_RUN_ATTEMPT}`, и `$GITHUB_WORKSPACE` в трёх аргументах взят в кавычки (1144 → 1150 байт). Это форма эталона модели, разрешённая контрактом («с заменой только GitHub Actions `${{ github.workspace }}`/`${{ github.run_id }}`/`${{ github.run_attempt }}` на shell-переменные»), смысл эквивалентен (ниже, п. 3), но фраза коммита неточна. Не блок.
- **С2 (класс: документ структуры, вне зоны implementer).** STRUCTURE.md §7.1 перечисляет файлы экранного CI-набора и строку `mobile.yml` «пять legacy jobs (явные, без изменений)»; после PR тела трёх legacy-работ живут в трёх новых `mobile/scripts/ci-*.sh`, которых в таблице нет. Дописать строку — задачей, меняющей STRUCTURE.md (не этот PR, ЗОНА implementer — 4 пути).
- **С3 (класс: проводка режима `--repo`, зона orchestrator).** В CI харнесса батарея проведена только `--stabs` (`registry/ci-steps.tsv:147 step check:obryv-adb-141-family-selftest … --stabs`); ПРОВОДКА-ЭНФОРСМЕНТ контракта называет «`--repo` после внедрения» — после merge PR #171 это строка оркестратора; до исправления Ф1 она не ловит CRLF.
- **С4 (класс: непроверенное).** Живого прогона CI продукта для 3cccaa232 нет (раннеры недоступны, очередь) — исполнение на эмуляторе, размещение stderr вне эха и поведение `bash mobile/scripts/…` на self-hosted раннере НЕ ПРОВЕРЕНО живым запуском; не блок по заданию.

## 1. Область правки

```
$ git -C mob show -s --format='%H%n%an <%ae>%n%cn <%ce>%n%P' 3cccaa232
3cccaa23286383af61d4ef6b76344de3795ac9cf
implementer <implementer@dev-harness.local>
implementer <implementer@dev-harness.local>
9442ea4bb65ae7cdeba601cf34855c9504f38b0c
$ git -C mob rev-list --count origin/main..3cccaa232
1
$ git -C mob diff --stat origin/main...3cccaa232
 .github/workflows/mobile.yml             | 215 +------------------------------
 mobile/scripts/ci-erstinformation-118.sh |  94 ++++++++++++++
 mobile/scripts/ci-first-run-135.sh       |  92 +++++++++++++
 mobile/scripts/ci-pilot-995.sh           |  23 ++++
 4 files changed, 212 insertions(+), 212 deletions(-)
 create mode 100755 mobile/scripts/ci-erstinformation-118.sh
 create mode 100755 mobile/scripts/ci-first-run-135.sh
 create mode 100755 mobile/scripts/ci-pilot-995.sh
$ git -C mob diff --numstat origin/main...3cccaa232
3	212	.github/workflows/mobile.yml
94	0	mobile/scripts/ci-erstinformation-118.sh
92	0	mobile/scripts/ci-first-run-135.sh
23	0	mobile/scripts/ci-pilot-995.sh
```
Блоб, строка ЗОНЫ: `ЗОНА implementer: .github/workflows/mobile.yml mobile/scripts/ci-first-run-135.sh mobile/scripts/ci-erstinformation-118.sh mobile/scripts/ci-pilot-995.sh` — 4 пути диффа = 4 пути зоны.

`git diff -U0` mobile.yml — ровно три ханка, каждый заменяет `run: |` + тело своего шага одной строкой (`working-directory` и `name` шагов вне ханков):
```
@@ -811,93 +811 @@ jobs:      +        run: bash mobile/scripts/ci-first-run-135.sh
@@ -1069,95 +977 @@ jobs:     +        run: bash mobile/scripts/ci-erstinformation-118.sh
@@ -1439,24 +1253 @@ jobs:     +        run: bash mobile/scripts/ci-pilot-995.sh
$ … | grep -c '^-[^-]'
212
```
Своя мера структурой (`equiv.py`: pyyaml-разбор base и head; в обоих три `run` заменены меткой, остальное сравнено как дерево):
```
JOBS base 11 head 11
STEP 135: base hits=[('e2e-first-run', 6)] head hits=[('e2e-first-run', 6)]
  keys base=['name', 'run', 'working-directory'] head=['name', 'run', 'working-directory'] env_base=None env_head=None
STEP 118: base hits=[('e2e-erstinformation', 10)] head hits=[('e2e-erstinformation', 10)]
  keys base=['name', 'run', 'working-directory'] head=['name', 'run', 'working-directory'] env_base=None env_head=None
STEP 995: base hits=[('e2e-pilot', 7)] head hits=[('e2e-pilot', 7)]
  keys base=['name', 'run', 'working-directory'] head=['name', 'run', 'working-directory'] env_base=None env_head=None
WORKFLOW minus three run values structurally equal: True
JOB e2e-first-run: keys=['if', 'needs', 'outputs', 'permissions', 'runs-on', 'steps', 'timeout-minutes'] if="needs.select-screens.outputs['e2e-first-run'] == 'true'" needs=['select-screens', 'build-apk'] runs-on=['self-hosted', 'linux', 'x64', 'kvm', 'complior'] timeout=40 coe=None
JOB e2e-erstinformation: … if="needs.select-screens.outputs['e2e-erstinformation'] == 'true'" needs=['select-screens', 'build-apk'] … timeout=40 coe=None
JOB e2e-pilot: … if="needs.select-screens.outputs['e2e-pilot'] == 'true'" needs=['select-screens', 'build-apk'] … timeout=40 coe=None
JOB android-e2e: keys=['if', 'needs', 'runs-on', 'steps', 'timeout-minutes'] if="always() && (github.event_name == 'pull_request' || github.event_name == 'push' || github.event_name == 'merge_group')" needs=[… 9 работ …] runs-on=['self-hosted', 'linux', 'x64', 'complior'] timeout=5 coe=None
```
Вывод: кроме трёх значений `run`, ни один job/шаг/ключ/permissions/env/defaults/concurrency/on не тронут; управляющие ключи трёх работ и агрегата `android-e2e` неизменны (равенство деревьев).

## 2. Сырой вывод батареи (дерево харнесса fa8393, мой прогон)

```
$ bash …/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Rev141v3/mob   (HEAD=3cccaa232)
CASE 135-oflin-povtor-spas ok … CASE derevo-rebro-pusto ok      (46 строк)
real 0m19.382s
RC_REPO=0            grep -c ' ok$' → 46
$ bash …red_obryv_adb_diagnostika_141.sh                          (без субъекта)
RC_NOFLAG=1          grep -c 'KRASNO (SUBJECT_ABSENT)' → 46
$ bash …red_obryv_adb_diagnostika_141.sh --model
RC_MODEL=0           grep -c '^CASE .* ok$' → 46
$ bash …red_obryv_adb_diagnostika_141.sh --stabs
SVJAZI 71
zhivykh 0
RC_STABS=0           CASE ok → 46; '^STAB .* KRASEN' → 71; уникальных стабов → 56
$ python3 …/repo_control.py
CONTROL_REPO_GREEN rc=0 cases=46
CONTROL_DIAG118_REPLAY_RED CHISTYJ: нет маркера вывода: "maestro.android.DeviceServerDiedException: Device server died during 'deviceInfo' on emulator-5566"
CONTROL_DIAG118_REPLAY_RED ACTIONS: нет маркера вывода: "maestro.android.DeviceServerDiedException: Device server died during 'deviceInfo' on emulator-5566"
CONTROL_PIN_RED rc=1 SKRIPT_PIN_RASHOZHDENIE
CONTROL_CALL_RED rc=1 VYZOV_SKRIPTA
RC_CONTROL=0
$ bash …red_obryv_adb_diagnostika_141.sh --repo <worktree origin/main продукта 9442ea4b>   (КРАСНОЕ до правки)
      9 KRASNO (SKRIPT_118_NET
     13 KRASNO (SKRIPT_135_NET
      4 KRASNO (SKRIPT_995_NET
      3 KRASNO (VYZOV_SKRIPTA
RC_MAIN=1            ok → 17, KRASNO → 29
```
Заявления implementer, перепроверенные ДРУГОЙ мерой: 46/46 — `grep -c` по выводу, плюс базовый прогон моего харнесса мутаций на минимальном дереве (`BASELINE minimal-tree rc=0 ok=46 red=0`); sha256 — `sha256sum` по сырым байтам и `cmp` с моделью (не через probe); «11 jobs» — pyyaml (`JOBS base 11 head 11`); `+3/−212` — numstat.
```
$ sha256sum mob/mobile/scripts/ci-*.sh
e79c415d8317908ac81b08dc5ef93e66bdce3414c4462ee80fc63a4ff40d08d9  ci-erstinformation-118.sh   (пин source.json: e79c415d…08d9)
5b4c61ecf827d8685d1b70a38d2a52e8f27d4e407299a9c2057e8e345ffbcb5c  ci-first-run-135.sh        (пин: 5b4c61ec…cb5c)
b10dd371989996b0e1a81663a268a053f5e54b2b8debb375f817f6d66acd995f  ci-pilot-995.sh            (пин: b10dd371…995f)
$ cmp model/mobile/scripts/<f> mob/mobile/scripts/<f>   → identical ×3
$ bash -n <f> → rc=0 ×3;  grep -c $'\r' → 0 ×3;  вхождений канона сигнатуры → 2/2/1;  '${{' → 0 ×3
```

### Свои мутации продукта (`mutate.py`: свежая минимальная копия mobile.yml + 3 скрипта на каждую, суд `--repo`)
```
BASELINE minimal-tree rc=0 ok=46 red=0
MUT pin-135-comment / pin-118-comment / pin-995-comment: rc=1 red=1 -> HIT   (CASE struktura-shag995 KRASNO (SKRIPT_PIN_RASHOZHDENIE: 995))
MUT pin-135-space / pin-118-space / pin-995-space:       rc=1 red=1 -> HIT
MUT pin-135-crlf / pin-118-crlf / pin-995-crlf:          rc=0 red=0 -> MISS  (Ф1)
MUT skript-135-udalen: rc=1 red=14 -> HIT   skript-118-udalen: rc=1 red=11 -> HIT   skript-995-udalen: rc=1 red=6 -> HIT  (CASE 995-diag-signatura KRASNO (SKRIPT_995_NET))
MUT beh-135-bez-povtora: rc=1 red=6 -> HIT  (CASE 135-oflin-povtor-spas KRASNO (CHISTYJ: нет маркера вывода: 'ПОВТОР: обрыв adb-транспорта эмулятора 135'))
MUT beh-995-bez-diag:    rc=1 red=3 -> HIT  (CASE 995-diag-signatura KRASNO (CHISTYJ: записи: ['PROBA995 rc=1'] (ожидались ['PROBA995 rc=1', 'ADB_DEVICES'])))
MUT call-{135,118,995}-{sh,dot-slash,bash-x,abs,or-true,echo,semicolon-exit0}: 21/21 rc=1 -> HIT
    (CASE struktura-shag135 KRASNO (VYZOV_SKRIPTA: shag 135: строка 1: 'bash -x mobile/scripts/ci-first-run-135.sh' ≠ 'bash mobile/scripts/ci-first-run-135.sh'))
    (CASE struktura-shag995 KRASNO (VYZOV_SKRIPTA: shag 995: строка 1: 'bash $GITHUB_WORKSPACE/mobile/scripts/ci-pilot-995.sh' ≠ 'bash mobile/scripts/ci-pilot-995.sh'))
MUT call-135-calls-118: rc=1 red=12 -> HIT
MUT call-135-blok-kommentarij (zelenyj kontrol): rc=0 red=0 -> HIT   (run: | + комментарий + пустая строка + вызов — зелено, как требует инв. 2)
MUT shag-135-pereimenovan: rc=1 red=15 -> HIT  shag-118: red=12 -> HIT  shag-995: red=8 -> HIT  (CASE 995-diag-signatura KRASNO (SHAG_995_NET))
MUT shag-{135,118,995}-{if-false,continue-on-error}: 6/6 rc=1 red=1 -> HIT  (CASE struktura-upravlenie-shag135 KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: shag 135: лишние ключи: if))
MUT job-{e2e-first-run,e2e-erstinformation,e2e-pilot,android-e2e}-{continue-on-error,if-false}: 8/8 rc=1 red=1 -> HIT
    (CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-pilot: лишние ключи: continue-on-error))
MUT job-android-e2e-if-always-and-false: rc=1 red=1 -> HIT  (CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: if='${{ always() && false }}' (канон 143 (модель): …)))
MUT workflow-defaults-shell-sh: rc=1 red=1 -> HIT  (CASE struktura-upravlenie-workflow KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: workflow: defaults={'run': {'shell': 'sh', 'working-directory': 'mobile'}} …))
MUTATIONS total=56 miss=3
RC_MUT=1
```
53/56 красны своим именованным входом; 3 промаха — один класс (CRLF), Ф1. Поведенческие правки скриптов красны собственным replay-входом, не только пином (инв. 3).

## 3. Поведение: эквивалентность выноса

```
STEP 135: base body exprs: []  base-body-after-3-substitutions == head script bytes: True (len 3821 vs 3821); без подстановки: True
STEP 118: base body exprs: []  … True (len 4062 vs 4062); без подстановки: True
STEP 995: base body exprs: ['${{ github.run_attempt }}', '${{ github.run_id }}', '${{ github.workspace }}']
  base-body-after-3-substitutions == head script bytes: False (len 1144 vs 1150)
    -  --repo $GITHUB_WORKSPACE \                    +  --repo "$GITHUB_WORKSPACE" \
    -  --apk $GITHUB_WORKSPACE/mobile/…/app-release.apk \   +  --apk "$GITHUB_WORKSPACE"/mobile/…/app-release.apk \
    -  --out $GITHUB_WORKSPACE/mobile/maestro-out     +  --out "$GITHUB_WORKSPACE"/mobile/maestro-out
$ git diff origin/main...HEAD -- mobile.yml | grep '^-' | grep -o '${{[^}]*}}' | sort | uniq -c
      1 ${{ github.run_attempt }}
      1 ${{ github.run_id }}
      3 ${{ github.workspace }}
```
- В удалённых строках нет ни одного `${{ secrets.* / env.* / matrix.* / steps.* / needs.* / inputs.* / vars.* }}` (grep → 0): ничего, что Actions подставлял бы только в `run:`-тело, в скрипт не теряется. Шаги не имеют `env:` ни до, ни после (`env_base=None env_head=None`); прочие переменные тел (`ANDROID_HOME`, `ANDROID_AVD_HOME`, `GITHUB_RUN_ID`, `GITHUB_RUN_ATTEMPT`) — переменные окружения процесса, дочерний `bash` их наследует; 135/118 уже на main читали `${GITHUB_RUN_ID}`/`${GITHUB_RUN_ATTEMPT}` из окружения.
- `github.workspace` ≡ `$GITHUB_WORKSPACE`, `github.run_id` ≡ `$GITHUB_RUN_ID`, `github.run_attempt` ≡ `$GITHUB_RUN_ATTEMPT` на job без `container:` (у `e2e-pilot` ключа `container` нет — pyyaml) [INFERENCE по документации GitHub Actions; живым прогоном не проверено, С4]. Кавычки вокруг `$GITHUB_WORKSPACE` эквивалентны текстовой подстановке для пути без пробелов/глобов и строже при их наличии. Путь кода `/tmp/impl995-pilot-private-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}/code` совпадает с путём, который пишет предыдущий шаг через `${{ github.run_id }}-${{ github.run_attempt }}`.
- Оболочка: workflow `defaults` = `{'run': {'working-directory': 'mobile'}}` без `shell` → шаг исполняется `bash -e {0}`; у трёх шагов `working-directory: ${{ github.workspace }}` сохранён, относительный путь `mobile/scripts/…` разрешается от корня checkout. Скрипты начинают с `set -euo pipefail` (135/118) и `set -e` (995) — те же режимы, что тела имели внутри `bash -e`; pipefail внешняя оболочка не давала и раньше (shell не задан), у 995 конвейеров нет. Код возврата `bash <скрипт>` — последний оператор шага, `-e` передаёт его шагу без изменения. `$0`/`BASH_SOURCE`/`dirname` в скриптах не используются (grep rc=1).

## 4. Неподгонка

- Пины sha256 — из `source.json` architect (`git log origin/main..fa8393 -- fixtures/workshop_project/obryv_adb_diagnostika_141/` — только author `architect`: a561f36f, 9e3d9e09, fa8393d8); пин модели = пин продукта = сырые байты модельных файлов (`sha256sum model/mobile/scripts/*` совпадает с `nositeli`). Скрипт продукта подогнан к эталону, не наоборот.
- Батарея implementer'ом не менялась: продуктовый коммит харнесс не трогает; зеркальный `0fb61803` — пустой (diff к origin/main пуст).

## 5. Гейты продукта

```
$ (head 3cccaa232) node mobile/scripts/check-structure.cjs   → 17 строк «file outside allowed location/type», RC_STRUCT_HEAD=1
$ (main 9442ea4b)  node mobile/scripts/check-structure.cjs   → те же 17 строк, RC_STRUCT_MAIN=1
```
Предсуществующий красный, число и перечень отказов совпадают; новых отказов от `mobile/scripts/ci-*.sh` нет. ESLint/typecheck/jest — путей js/ts/json в диффе нет (numstat), не запускались.
Режим проекта (996/1): `sourceCanon` продукта объявлен (gate `python3 mobile/scripts/check-context-sources.py`); контракт 141 — харнесс-родной (не в `.harness/contracts` продукта), строк `ИСТОЧНИК:` нет (`grep -c` → 0), продуктовый gate на нём: `CITATIONS FAIL: контракт не содержит ИСТОЧНИК:` rc 1 — к харнесс-родному контракту не применим. Гейт приёмки контракта: `bash scripts/check_project_sources.sh --repo . --contract contracts/141-obryv-adb-diagnostika.md --stage done` → RC_PROJSRC=0 (дерево fa8393 = дерево тега).

## 6. Класс риска и шестой вопрос (норма не тронута молча)

Риск — обычный, не повышаю (CI-обвязка; секреты, права, деньги, ПД не затронуты; поведение тел байт-равно, 995 — эквивалентные подстановки). Нормативных документов дифф не касается: ни продуктовых (`AGENTS.md`, `STRUCTURE.md`, `docs/`), ни харнесса (зеркало пустое).

## ПРОВОДКА (038)

`guard=fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh` — существует, это барьер именно предмета 141 (батарея его фикстуры, красна на main продукта 29/46, зелена на объекте 46/46); подключён `registry/ci-steps.tsv:147` (`--stabs`); `bash scripts/check_provodka.sh . contracts/141-obryv-adb-diagnostika.md` → RC_PROVODKA=0. Норма механизменная (CI-диагностика), guard-only со строкой ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно; оговорка — Ф1 и С3.

## Паразитная сложность (050)

- `mobile/scripts/ci-first-run-135.sh` / `ci-erstinformation-118.sh` / `ci-pilot-995.sh` (семья одним артефактом): (1) «Решение и инварианты» v3 + инв. 1/3 требуют именно эти три файла; (2) нового состояния нет — читают явно `GITHUB_WORKSPACE`/`GITHUB_RUN_ID`/`GITHUB_RUN_ATTEMPT` из окружения, как до выноса читали 135/118; (3) правка поведения одного шага = скрипт продукта + модельный скрипт + пин `source.json` — три файла, как в v2 (тело mobile.yml + model/mobile.yml + пин); число не выросло; (4) интерфейс — 0 аргументов, 3 env, коды возврата прежние; вся работа тел скрыта за ним — глубокий модуль; (5) потребители — шаги `mobile.yml` и `--repo` батареи; логику не дублирует: тела перенесены, а не скопированы (mobile.yml −212). ESSENTIAL.
- `.github/workflows/mobile.yml` (три строки `run: bash mobile/scripts/…`): (1) инв. 2; (2) состояния нет; (3) не растёт; (4) интерфейс — одна команда; (5) потребитель — Actions и `struktura-shagN`. ESSENTIAL.

## Чем проверено (артефакты ревьюера, вне коммита)

`/tmp/dev-harness-verify/Rev141v3/equiv.py` (своя мера эквивалентности и равенства деревьев), `/tmp/dev-harness-verify/Rev141v3/mutate.py` (56 мутаций), логи `logs/{repo,noflag,model,stabs,control,repo-main,mutate}.txt` — лежат вне клонов в /tmp/dev-harness-verify/Rev141v3/ (клоны удалены после bundle); выдержки выше — дословный вывод.
