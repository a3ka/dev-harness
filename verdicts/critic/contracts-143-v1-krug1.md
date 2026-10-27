FAIL
OBJECT=83b2fe0f21b9d8037e2b56cc02af9f207b89082f
СУД: repo=dev-harness; предмет=143; фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=не предоставлена судье; модель-факт=openai-codex/gpt-6-sol (workstation); SHA=83b2fe0f21b9d8037e2b56cc02af9f207b89082f; предыдущий=нет (Critic143a не судил ввиду неверного SHA); исключение=нет; независимость: автор Architect143 zai/glm-5.3, судья Sol.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:48 — ложная достаточность проверки digest ДО установки. В одноразовой копии модели все пять работников заменили `if [ "$got" != "$ZHELANYJ_DIGEST" ]; then` на `if false && [ "$got" != "$ZHELANYJ_DIGEST" ]; then`: `W --repo` вернул 63/63. Y11 ищет текст `APK_DIGEST_RASKHOZHDENIE`, но не исполняет worker с повреждённым APK. Закрывающее свойство: отрицательная поведенческая клетка доказывает остановку работника ДО установки неверного APK, не присутствие маркера в YAML.
ОБХОД: чужой APK устанавливается, worker успехом сообщает данные сборки, required-агрегат видит success, а батарея печатает `bypass-apk-digest-on-worker: rc=0 / клеток 63, зелёных 63, красных 0`.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:52,136 — скрытая общая выборка 995 осталась при зелёной модели. Эталонный `e2e-pilot` вызывает H-пин `66052cdf…`/`maestro_probe.py --repo`; `git show 66052cdfd134ab0958421a961caef219694a54df:fixtures/workshop_project/pilot_995/maestro_probe.py` показывает в строках 82–83 `(a.repo / 'mobile/.maestro').rglob('*')`; живой `mobile/scripts/ci-e2e.sh:168-169` исполняет `maestro test .maestro`. F01/F02 проверяют JSON-карту P, не этот исполняемый путь. Зона implementer 143 не содержит `maestro_probe.py`; черновик 995 v5 меняет текст, а не H/код. Закрывающее свойство: до cutover назначить владельца, зону, H-пин исполняемого фиксированного P и красный свидетель по реально исполняемым native testcase.
ОБХОД: четыре эталонных файла скопированы, retry удалён, `W --repo` 63/63, но e2e-pilot продолжает исполнять First-Run/Splash/Start даже когда их экранные workers не выбраны. Исходный общий красный остаётся; `W --model` действительно rc0 63/63 ×3 с этим wildcard.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:49,112-114 — модель DAG не передаёт агрегату требуемые данные и код. У пяти workers есть шаг «Идентичность прогона работника», пишущий `$GITHUB_OUTPUT`, но у этого шага нет `id:`, у самих workers нет job-level `outputs`; `toJSON(needs)` агрегата получает пустые worker outputs, и модельный `ci-aggregate.cjs:72-75` краснеет на каждом выбранном worker. У обоих агрегирующих jobs нет checkout, хотя они запускают `node mobile/scripts/ci-aggregate.cjs`. На чистом раннере файла нет; старый код из предыдущего workspace на общем self-hosted возможен [INFERENCE: платформенное состояние]. Прямой локальный вызов модели с success worker и пустыми outputs возвращает rc1 `AGREGAT_OTKAZ: APK_DIGEST_RASKHOZHDENIE — e2e-start: нет ≠ aaaaa…`. Закрывающее свойство: id и job outputs всех workers, checkout текущего дерева в агрегатах, красные клетки на отсутствие outputs/checkout до freeze. Честно объявленный остаток «живой GitHub DAG пока не доказан» не оправдывает структурно неисполнимый эталон для побайтового переноса.
ОБХОД: `W --model`/`W --repo` 63/63, но реальный selected worker всегда даёт missing digest либо агрегатор вообще не находит свой скрипт, поэтому предмет (работающий required) не выполнен.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:47 — обязательная PR concurrency `mobile-pr-N` с отменой не судится ни одной клеткой. В модели поменяли `cancel-in-progress: ${{ github.event_name == 'pull_request' }}` → `cancel-in-progress: false`; W на копии вернул 63/63. Закрывающее свойство: отдельная красная проверка PR-group/cancel и непересечения ночной/dispatch-группы.
ОБХОД: устаревший PR-run не отменяется и делит общий пул с новым, несмотря на И-3, а барьер зелён (`disable-pr-cancellation: rc=0 / 63/63`).

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:81,148 — frozen 123 объявлен «БЕЗ изменений», но его обязательная команда placement стала невыполнимой. `git show 'frozen/contracts/123/2^{commit}:contracts/123-mob-sverka-maketa.md'`, критерий 6: шаг 123 именно в `job android-e2e` ПОСЛЕ шага 117 и ДО upload. Новый `android-e2e` — агрегат без шага 123, шаг перенесён в `e2e-splash`. Перенос порядка внутри другого job не выполняет frozen-критерий; среди восьми v+1 черновиков миграции 123 нет. Закрывающее свойство: названная адресная миграция placement/команды 123 с владельцем либо явное решение полномочной роли о прежнем критерии, не декларация «без изменений».
ОБЯЗАТЕЛЬСТВО: frozen 123/2 критерий 6 и И-7 контракта 143 одновременно претендуют на действующую сверку 123 при cutover.
СОСТОЯНИЕ: продукт с честным новым DAG, 123 внутри e2e-splash, frozen 123/2 не переснят.
НАБЛЮДЕНИЕ: чтение `jobs.android-e2e.steps` больше не находит «123 сверка кадров с макетом»; команда placement-критерия 123 красна. Класс причины — пропущенный потребитель/несовместимые приёмочные критерии.

## СОВЕТ

СОВЕТ contracts/143-mob-ci-razdelenie.md:129 — у восьми draft v+1 строки diff контекста/удаления совпали с названными frozen-блобами; 117-v5 закономерно опирается на 117/3, поскольку 117-v4 ещё идёт. Перед подписью повторить сравнение 117-v5 поверх принятой v4.

## Факт и сырой вывод исполненных атак

`git diff --stat origin/main..HEAD` → `49 files +5508 -0`; `git rev-parse HEAD` → `83b2fe0f21b9d8037e2b56cc02af9f207b89082f`. Предмет HEAD, ЗОНА-строки и исполнители есть, класс риска health указан.

`bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh` → rc1 `клеток 63, зелёных 0, красных 63 — SUBJECT_ABSENT` (все 63 поимённо). `... --model` ×3 → rc0 `клеток 63, зелёных 63, красных 0` каждый. `... --stabs` → rc0 `клеток 63, зелёных 63, красных 0 / стабов 27, привязок 42, непойманных 0`. `... --repo /tmp/dev-harness-verify/Critic143b/mob` (checkout c617f6fb236d11574df75fb09ae41870bf8c29d6) → rc1 `клеток 63, зелёных 3, красных 60` (зелёные y04/y05/y06).

`python3 mutations.py` (пять независимых изменённых копий model/, каждая запущена `bash red_mob_ci_143.sh --repo <копия>`; script после прогона удалён):
```
remove-aggregate-always: rc=1
клеток 63, зелёных 62, красных 1
КЛЕТКА y03-agregat-if-always: if агрегата "github.event_name == 'pull_request' && (github.event_name == 'pull_request' || github.event_name == 'push' || github.event_name == 'merge_group')" КРАСНА
remove-aggregate-worker: rc=1
клеток 63, зелёных 62, красных 1
КЛЕТКА y02-agregat-needs: needs агрегата ['select-screens', 'quality', 'build-apk', 'e2e-splash', 'e2e-first-run', 'e2e-erstinformation', 'e2e-pilot'] КРАСНА
remove-cron: rc=1
клеток 63, зелёных 62, красных 1
КЛЕТКА y09-sobytija-i-net-139: нет schedule/dispatch КРАСНА
disable-pr-cancellation: rc=0
клеток 63, зелёных 63, красных 0
bypass-apk-digest-on-worker: rc=0
клеток 63, зелёных 63, красных 0
```
`python3 wiring.py` (PyYAML по модели; script после прогона удалён):
```
e2e-splash: checkout=True job_outputs=[] identity_step_ids=[None]
e2e-first-run: checkout=True job_outputs=[] identity_step_ids=[None]
e2e-erstinformation: checkout=True job_outputs=[] identity_step_ids=[None]
e2e-start: checkout=True job_outputs=[] identity_step_ids=[None]
e2e-pilot: checkout=True job_outputs=[] identity_step_ids=[None]
android-e2e: checkout=False job_outputs=[] identity_step_ids=[]
mobile-regression-signal: checkout=False job_outputs=[] identity_step_ids=[]
```
`node repo/fixtures/workshop_project/mob_ci_143/model/mobile/scripts/ci-aggregate.cjs --needs needs-missing.json` (одноразовый локальный JSON: пять workers, выбран e2e-start success с пустыми outputs, остальные skipped) → rc1 `AGREGAT_OTKAZ: APK_DIGEST_RASKHOZHDENIE — e2e-start: нет ≠ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`. JSON удалён.

`python3 pins.py` (каждый из девяти пинов портился отдельным newline во временной копии, `W --model`, восстанавливался; script удалён):
```
model/.github/workflows/mobile.yml: rc=2 ORACLE_TAMPERED: пин: sha256 model/.github/workflows/mobile.yml
model/mobile/ci-screens.json: rc=2 ORACLE_TAMPERED: пин: sha256 model/mobile/ci-screens.json
model/mobile/scripts/select-ci-screens.cjs: rc=2 ORACLE_TAMPERED: пин: sha256 model/mobile/scripts/select-ci-screens.cjs
model/mobile/scripts/ci-aggregate.cjs: rc=2 ORACLE_TAMPERED: пин: sha256 model/mobile/scripts/ci-aggregate.cjs
nositeli/mobile-124.yml: rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/mobile-124.yml
nositeli/api/pull-124.json: rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/pull-124.json
nositeli/api/pull-124-files.json: rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/pull-124-files.json
nositeli/api/pull-124-files-stranitsa.json: rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/pull-124-files-stranitsa.json
nositeli/api/run-40426209738-jobs.json: rc=2 ORACLE_TAMPERED: пин: sha256 nositeli/api/run-40426209738-jobs.json
```

Живые носители: `cmp nositeli/mobile-124.yml mob/.github/workflows/mobile.yml` → rc0, обе sha256 `f45c68230eb83b12c8aa81173da4b9d46608b966acfef7da7ba6178d21087421`; `gh api repos/a3ka/Complior-mob/pulls/124` → head c617f6fb…, changed_files=37, base c3235fbc… (снимок совпал). Живые `pulls/124/files?per_page=100` после нормализации и snapshot: одинаковый sha `95986f45793f12c630f109b75d38b09102eb2b48f93d30537134a7ca80ee6ca4`; неполная страница `/files?per_page=2&page=1` (полный JSON) одинаковый sha `d7afcb1cb65f189929ca1d835b2634223ff694e9023d8431ba3d9316e96be2c3`; `actions/runs/40426209738/jobs?per_page=100` после нормализации одинаковый sha `b6291b08b155e769785451cfe4234a01b3596aba30464727cb2fbd6aa3df2d4b`.

Живые `.maestro` #124: восемь публичных файлов (семь flows + config), pilot.yaml приватный; future 138/116 не в #124. Frozen-теги: 111/4, 116/3, 117/3, 118/2, 138/1, 139/2 (заголовок v3), 141/1, 995/4. Проверка `python3 drafts.py` на `git show frozen/contracts/<N>/<v>^{commit}:contracts/<N>-*.md` → 8/8 черновиков: removed/context совпали без mismatch. Поиск `^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в дереве drafts → no matches. По source.json: 63 клетки (S25/A16/Y18/F4), 27 стабов, 42 привязки, 9 пинов и 8 drafts.

`bash scripts/pre_critic.sh --repo <клон> contracts/143-mob-ci-razdelenie.md` → rc0 `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh <клон> contracts/143-mob-ci-razdelenie.md` → rc0 `OK`; `check_spec_ready.sh <клон> contracts/143-mob-ci-razdelenie.md` → rc0 `OK`; `check_ceilings.sh <клон> contracts/143-mob-ci-razdelenie.md` → rc0 `потолки в порядке`; `check_threat_model.sh <клон> contracts/143-mob-ci-razdelenie.md` → rc0 `ЗАЩИЩАЕТ 9, НЕ ЗАЩИЩАЕТ 7`. `bash scripts/check_zones.sh <клон> contracts/143-mob-ci-razdelenie.md` → финал `замороженных контрактов: 140 · объявленных авторов: 5 · коммитов в диапазонах: 33823 · проверено по зонам: 7140`; ни одной строки FAIL, процесс завершился (полный лог `artifact://3465`; rc непосредственно в фоне не напечатан). Первый синхронный запуск был ограничен 120 сек и прерван; это финал второго запуска с timeout=3600.

`bash scripts/check_provodka.sh <клон> contracts/143-mob-ci-razdelenie.md` → rc1 `проводка: guard не подключён: fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh не вызывается в .githooks/ или .github/workflows/`; в одноразовой копии с добавленным workflow-step `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs` → rc0, без вывода. Отложенная проводка объявлена §ПРОВОДКА, не отдельный блокер до интеграции.

Соседи: `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs` → rc0 `SVJAZI 60 / zhivykh 0`; `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` → rc0 `SVJAZI 60`; `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs` → rc0 `SVJAZI 61 / zhivykh 0`. Запрещённые workflow, gh run, раннеры и эмуляторы НЕ запускались. Живой DAG платформы честно оставлен в §НЕ ЗАЩИЩАЕТ, но уже видимые обходы и противоречия до реализации запрещают freeze.
