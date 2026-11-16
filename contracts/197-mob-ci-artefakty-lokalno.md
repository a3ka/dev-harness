# Контракт 197 — CI моба пишет и читает артефакты локально

КЛАСС ЗАДАЧИ: смешанный (контракт + красная батарея харнесса; реализация — PR в продукте Complior-mob).
КЛАСС РИСКА: обычный — транспорт доказательств CI внутри станции, без прав БД/авторизации/денег/ПД и согласий; основание по закрытому перечню отсутствует.

КОНТЕКСТ: боль Н-443 — квота хранилища артефактов GitHub Actions Complior-mob исчерпана («Failed to CreateArtifact: Artifact storage quota has been hit», run 43752095485): mobile.yml стоит ЦЕЛИКОМ, mob#172 (141 v3) и mob#173 (148 v5) красны транспортом, не кодом. Слово владельца 2026-11-16 ~09:25 UTC (через консультанта): «да, все это должно быть частью локально CI» — артефакты хранятся локально на станции, на GitHub не загружаются, бюджет GitHub не поднимается. Интерфейс общий с предметом 196 (ops/server: корни и владельцы, чтение группой harness, очистка таймером) и с бэкендом (его ci.yml — его предмет).

## Предмет

Один наблюдаемый результат: все артефакты прогона моба (APK сборки, selection.json, доказательства экранов, child-evidence, маркер полной регрессии) идут локальным транспортом `/var/lib/ci-artifacts/Complior-mob/${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}/<имя>/`: ни один шаг `mobile.yml` не обращается к хранилищу артефактов GitHub Actions (`actions/upload-artifact`, `actions/download-artifact`, `gh run download`), грамматика пути живёт в одном скрипте-каноне, вызванном npm-lane; квота GitHub не расходуется — мобильный CI перестаёт краснеть по квоте. `mobile-cloud-e2e.yml` (облачный раннер) — ВНЕ предмета.

## Существующее

- Живое дерево (замер grep этой пачки по `origin/main` fda1fc871960b8061d8e6f6d12f2cc38f5834cee, последний fetch клона станции 2026-11-12; локальный чекаут старее — 934917b от 2026-11-04): 9 шагов `actions/upload-artifact@v7` (select-screens selection.json; build-apk APK; доказательства e2e-splash/first-run/erstinformation/start/pilot; child-evidence e2e-screen; маркер mobile-regression-signal), 3 шага `actions/download-artifact@v7` (APK в e2e-screen; child-evidence в android-e2e и mobile-regression-signal), 5 команд `gh run download` (APK у пяти работников; job-level `actions: read` существует ради них). На чекауте 934917b: 8 upload / 0 download-artifact / 5 gh run download.
- `fixtures/workshop_project/mob_ci_143/` (frozen 143/4, CI-проводка `check:mob-ci-razdelenie-143-family-selftest --stabs`): probe.py `sud_apk` требует литерал `"IMJA_ARTEFAKTA": "${{ needs.build-apk.outputs.artifact_name }}"` и `APK_DIGEST_RASKHOZHDENIE` у работников; `sud_derevo` держит замкнутый алфавит действий build-apk (checkout/setup-node/upload-artifact); matrix_v3.py (`CHILD_UPLOAD_ABSENT`, `CHILD_DOWNLOAD_ABSENT_*`) и connected_v3.py (`APK_DOWNLOAD_EDGE`, `CHILD_UPLOAD_EDGE`, `AGGREGATE_DOWNLOAD_EDGE`) пинуют upload/download-artifact шаги и их with-поля. Лекало `model/screen-job.template.yml` и placement-клетка 189/1 `k06-shag-posle-upload` несут upload-шаг.
- `fixtures/workshop_project/obryv_adb_diagnostika_141/` (frozen 141/3): судит ТРИ скриптовых шага (sha256-пины `mobile/scripts/ci-*.sh`), ключи job и needs-ребро; артефактные шаги не пинуют («чужой шаг свободен», инвариант 5) — grep этой пачки совпадений не нашёл.
- `fixtures/workshop_project/vkladki_tabov_148/` (frozen 148/5), `mob_sverka_123` (123/3), `vkhod_117` (117/5), `first_run_ekran_135`, `mission_116`, `rehearsal_991` (991/3), `e2e_avtoperezapusk_139` (139/3): пинов артефактных шагов mobile.yml нет (замер grep этой пачки) — шаги 123/117/135/118/995/version-gate и retry-файл не меняются.
- `scripts/verify_ci_parity.sh` + frozen 163/1: каждая `run:`-команда `.github/**` обязана быть `npm run <NAME>` либо исключением; храповик долга (до 2026-11-18, `.harness/registry/ci_parity_debt.txt` продукта) запрещает НОВЫЕ исключения — сырые `cp`-шаги в workflow растили бы долг.
- `fixtures/workshop_project/obryv_zamer_150/` (кандидат 150, НЕ заморожен): z03/z05 требуют у работников upload-artifact с `if-no-files-found: ignore` и согласования with.path/--out.
- Прецедент формы батареи: `mob_ci_143`, `obryv_adb_diagnostika_141` (режимы --model/--stabs/--repo, SUBJECT_ABSENT, пины sha256, канон побайтово, мутации стабов кодом, привязки в source.json).
- Серверная обвязка станции — `ops/server/README.md` (инвентарь таймеров; корень и очистка артефактов — предмет 196, его окно).

### Замороженные нормы, задеваемые предметом (доклад оркестратору; строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ владельца эта пачка НЕ пишет)

1. **143 v+1 обязателен в окне ленда 197**: после замены артефактных шагов `red_mob_ci_143.sh --repo <продукт>` краснеет на честном дереве (клетки CHILD_UPLOAD_*/CHILD_DOWNLOAD_*/APK_DOWNLOAD_EDGE/AGGREGATE_DOWNLOAD_EDGE; алфавит build-apk; IMJA_ARTEFAKTA gh-форма). В пакет 143 v+1 входит и лекало screen-job.template.yml с placement-клеткой 189/1 (k06) — самостоятельная заявка 189 v+1.
2. **150 (кандидат, не заморожен)**: доработать под lane-форму до своей заморозки (z03/z05 пинуют upload-artifact у работников).
3. **163 v+1 не нужен** при lane-форме (новых исключений паритета нет — lanes `ci:artefakt-*` и есть целевая форма E); проверка `verify_ci_parity.sh` после ленда — в приёмке оркестратора.
4. 141/3, 148/5, 117/5, 123/3, 111/5, 116/3, 991/3, 139/3 — не затронуты (замер выше).

## Frontier (решения конструкции)

| Вариант | Судьба |
|---|---|
| сырые shell-шаги `cp` в mobile.yml | отклонён: каждая run-команда обязана быть npm-lane/исключением паритета (163), новые исключения запрещены |
| composite action `.github/actions/*` | отклонён: паритет разбирает и composite runs.steps (область `.github/**`) — те же требования, вторая конвенция |
| единый скрипт-канон + npm-lanes (`npm run ci:artefakt-zapis|chtenie -- …`) | выбран: грамматика пути в ОДНОМ файле (байтовый пин), workflow несёт только закрытую форму вызова, паритет чист |
| имя артефакта вычисляет workflow (run_id/attempt в тексте шага) | отклонён: run-контекст строит скрипт из собственных env; workflow не строит путей (d01) |
| читатель APK ищет в собственной попытке | отклонён: выборочный повтор работника теряет сборку — нарушена семантика И-4 frozen 143; читатель берёт пару run_id/run_attempt из outputs сборки |

## Решение и инварианты

1. **И-1 канал GitHub закрыт.** В `mobile.yml` нет шагов `uses: actions/upload-artifact@*`/`actions/download-artifact@*` и run-команд `gh run download`/`gh api …/artifacts` (клетки a01–a03, именованные причины с job/шагом).
2. **И-2 грамматика пути — один источник.** Путь `<koren>/<run_id>-<run_attempt>/<имя>/` строит ТОЛЬКО скрипт-канон `mobile/scripts/ci-artefakty.cjs` (байтовый пин, клетка e01); литерал корня в workflow не встречается (d01). Вызовы — однострочные `npm run ci:artefakt-zapis -- --imja M --chto P` / `npm run ci:artefakt-chtenie -- (--imja M | --shablon G) --kuda D [--run-id R --run-attempt T]` из замкнутого набора ключей (b01/c01); значения lanes в package.json — канон (e02). Корень по умолчанию `/var/lib/ci-artifacts/Complior-mob`; env `CI_ARTEFAKTY_KOREN` (переопределение для replay батареи и станции) workflow НЕ задаёт.
3. **И-3 писатель — собственный run-контекст.** Шаг-писатель не передаёт `--run-id/--run-attempt` (b03); скрипт берёт `GITHUB_RUN_ID`/`GITHUB_RUN_ATTEMPT`, оба обязаны быть числовыми (r05); записи попыток лежат в разных каталогах (r09).
4. **И-4 APK — продюсерская попытка.** `build-apk` публикует output `run_attempt` (рядом с `apk_sha256`/`artifact_name`/`run_id`); читатели APK передают пару `--run-id/--run-attempt` из `needs.build-apk.outputs` — оба или ни один (c01: `NEPOLNAJA_IDENTIFIKACIJA_RUNA`); имя артефакта по-прежнему из outputs сборки (литерал env `IMJA_ARTEFAKTA` сохранён), digest сверяется до установки — сборка переживает выборочный повтор работника (r02), семантика И-4 frozen 143 сохранена.
5. **И-5 замыкание и fail-closed.** Каждый читаемый `--imja`/`--shablon` структурно совпадает с каким-то писателем того же workflow (c02: разрешение цепочек env→needs→steps и matrix-классов); чтение отсутствующего имени/шаблона/каталога run'а — именованный отказ rc 2, не пустой успех (r02/r07).
6. **И-6 алфавит имени и страж корня.** Имя `[A-Za-z0-9][A-Za-z0-9._-]*` без `/`, не `.`/`..`; шаблон того же алфавита с `*`; источники/назначения — относительные пути без сегмента `..` (d02); скрипт после сборки пути сверяет префикс корня — побег невозможен даже при пропуске алфавита (r03/r04).
7. **И-7 семантика переноса сохранена.** `<имя>/` — всегда каталог: файл кладётся внутрь под своим именем, каталог — содержимым (семантика upload/download-artifact); шаблонный сбор кладёт каждого ребёнка отдельным каталогом (эквивалент `merge-multiple: false`, r07); `if-no-files-found: error` эквивалентен отказу `ISTOCHNIK_OTSTUTSTVUET` (r08).

## Приёмочный критерий

`W` = `bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh` (из корня харнесса). Конформный вход: YAML workflow и package.json читаемы (схема GitHub Actions/npm); `--repo` указывает дерево Complior-mob. Валидный контрпример: структурно конформный вход, расходящийся на заявленном инварианте (замена/удаление артефактного шага, скрипта, lane) при неизменных независимых ожиданиях батареи. Клетки и именованные причины — `osi.md`; счёт клеткам/стабам печатает сам прогон.

### Красное сейчас (замеры этой пачки)

1. Сценарий: дано дерево харнесса; когда `W`; тогда rc 1 `SUBJECT_ABSENT`, клеток 21, зелёных 0, красных 21 поимённо (реализация — правка продукта).
2. Сценарий: дано живое дерево `/home/harness/projects/Complior-mob` (чекаут 934917b); когда `W --repo /home/harness/projects/Complior-mob`; тогда rc 1, клеток 21, зелёных 8, красных 13: `UPLOAD_ARTIFAKT_OSTALSJA: build-apk…`, `GH_KANAL_V_RUN: e2e-erstinformation…`, `SKRIPT_NET` (9 replay-клеток), `LINEJA_FORMA`.

### Модель и стабы

3. Правило: `W --model`; ожидание rc 0, клеток 21, зелёных 21 (модель выведена из живого `origin/main` fda1fc8 заменой ТОЛЬКО артефактного транспорта; пины sha256 трёх файлов модели в `source.json`, рассинхрон → rc 2 `ORACLE_TAMPERED`).
4. Правило: `W --stabs`; ожидание rc 0: честный контроль зелёен ДО мутаций, стабов 8, непойманных 0; каждая мутация копии модели кодом (`stabs/*.py`, привязки `source.json:.stab_vhod`) проявляется в выводе прогоняемой копии как `CASE <клетка> KRASNO: <именованная причина>` своей ветви. Негативная пара: удаление любого стаб-файла или чистки привязки делает `--stabs` красным (rc 1) с именем пропущенного стаба.
5. Сценарий: дано дерево модели как псевдо-репо; когда `W --repo <каталог модели>`; тогда rc 0, 21/21 (командная совместимость режимов).

### После реализации (PR в продукте)

6. Сценарий: дано дерево продукта после ленда; когда `W --repo <дерево продукта>`; тогда rc 0, 21/21. Правило-пара: подмена байтов `mobile/scripts/ci-artefakty.cjs` при прежнем workflow → rc 1 `SKRIPT_PIN_RASHOZHDENIE`; удаление скрипта → rc 1 `SKRIPT_NET`; удаление lane из package.json → rc 1 `LINEJA_FORMA`.
7. Правило: `bash scripts/verify_ci_parity.sh <дерево продукта>` не сообщает НОВЫХ расхождений против состояния до PR (lanes — целевая форма; файл долга не растёт).
8. Сценарий: дано мобильный CI на PR продукта; когда GitHub Actions исполняет `mobile.yml`; тогда conclusion success без `Failed to CreateArtifact` (живой ловец; перезапуск mob#172/#173 — шаг оркестратора, не этой пачки).
9. Правило: `bash scripts/pre_critic.sh --repo . contracts/197-mob-ci-artefakty-lokalno.md` → rc 0; до freeze `bash scripts/check_provodka.sh . contracts/197-mob-ci-artefakty-lokalno.md` — именованный rc 1 (строка батареи ещё не подключена), до done rc 0 (проводку подключает оркестратор).

## Модель угроз

ЗАЩИЩАЕТ:
- от возврата к квоте GitHub: закрытие канала upload/download/gh run download статически (a01–a03), включая «один забытый шаг»;
- от транспорта мимо канона: сырые пути и посторонние команды у писателей (b01/d01/d02), байтовый пин скрипта (e01), замкнутые lanes (e02);
- от потери сборки при повторе и от чтения чужой попытки: продюсерская пара run_id/run_attempt (И-4), fail-closed чтение (r02/r07);
- от слияния попыток и побега за корень: числовые контексты, изоляция каталогов (r05/r09), алфавит имени и страж префикса (r03/r04, d02).

НЕ ЗАЩИЩАЕТ:
- физическое владение/права корня и очистку каталогов run'ов — предмет 196; ловец — живой прогон CI после ленда;
- поведение GitHub вне артефактного слоя (needs/агрегат/матрица/порядок шагов) — предметы 143/141/148, батарея целостность DAG не судит;
- `mobile-cloud-e2e.yml` (облачный раннер, 2 upload-шага по замеру) — вне предмета;
- снятие неиспользуемого `actions: read` у пяти работников — гигиена permissions, отдельное решение владельца;
- ретенцию доказательств после очистки таймером 196 — наблюдаемо только живой станцией.

## Зоны и проводка

ЗОНА architect: contracts/197-mob-ci-artefakty-lokalno.md fixtures/workshop_project/mob_ci_artifacts_local_197/
ЗОНА implementer: .github/workflows/mobile.yml package.json mobile/scripts/ci-artefakty.cjs
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 141 три скриптовых вызова ci-first-run-135.sh/ci-erstinformation-118.sh/ci-pilot-995.sh и управляющие ключи их job не меняются; шаги 117/123/135/118/995/version-gate дословно
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 148 шаги экрана e2e-vkladki (после ребейса mob#173) не меняются; артефактный шаг этого экрана — по канону 197
ПЕРЕСЕЧЕНИЕ implementer: package.json — 163 добавляются только два ключа ci:artefakt-*, существующие скрипты не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 151 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ implementer: package.json — 011 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ implementer: package.json — 015 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 добавление только строки/шага 197; чужие строки и шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 добавление только строки/шага 197; чужие строки и шаги не меняются
Репозиторий implementer — продукт Complior-mob; порт скрипта-канона байт-в-байт (пин e01), lanes — значения канона (e02). Живые правки продукта — после окна 196 (корень/права/таймер) либо по согласованному исключению оркестратора.

ПРЕДПОСЫЛКИ:
- setting корень `/var/lib/ci-artifacts/Complior-mob` создан, владелец `harness`, группа `harness` читает и пишет, очистка таймером — предмет 196 (окно 196 до ленда 197-реализации);
- setting раннер `station-complior` исполняется от пользователя группы `harness` (права записи в корень);
- setting на станции python3+PyYAML и node для батареи и replay; новых секретов, permissions, variables, environments репозитория НЕ требуется (contents: read достаточно).

ПРОВОДКА:
- guard=fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh

ПРОВОДКА-ЭНФОРСМЕНТ: проверка — чистый enforcement (статический разбор workflow + lanes + байтовый пин скрипта-канона + replay скрипта в замкнутой песочнице); `--stabs` в CI станции до ленда, `--repo <дерево продукта>` после; строку своей батареи подключает оркестратор (`gen_ci_steps.sh --write`, `--check` rc 0), чужие строки не меняются.

## Незаполненные требования:
нет
