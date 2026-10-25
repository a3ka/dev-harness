# Контракт 139 — e2e-avtoperezapusk: авто-повтор флейка android-e2e в CI Complior-mob

КЛАСС ЗАДАЧИ: КОДОВЫЙ (CI-инфраструктура продукта, красная батарея). КЛАСС РИСКА: обычный. Номер выдан механизмом (тег `id/CONTRACT/139`, строка реестра на origin/main `9a083ee821`). ВЕРСИЯ: v2 (исправительный проход по вердикту критика круг 1/2: блокеры «исполняемые ветви workflow вне наблюдаемого батареей шага» и «pipefail + ранний grep -q на большом потоке» закрыты классами — замкнутая структура workflow `struktura-zamknutost` и входы оси «размер/форма лога × положение сигнатуры»; совет (а) — остаток нарезки В перенесён в §НЕ ЗАЩИЩАЕТ с ловцом).

## Воля владельца (источники)

- Слово владельца 2026-10-25 (через консультанта) + поправка 15:45: «упавший android-e2e перезапускается ОДИН раз автоматически, без серий из сессии; шаги frozen 995/108/111/117/135 и их текст НЕ трогать; форма — отдельный workflow на `workflow_run [mobile] completed`, `gh run rerun --failed`, `permissions: actions: write`, `runs-on: [self-hosted, linux, x64, complior]`; повтор НЕ любого красного android-e2e, а ТОЛЬКО при инфраструктурных сигнатурах сбоя эмулятора».
- Боль: Н-407 (шаг 135 мигает `E2E_NE_PROSHLA` на обрыве adb после готовности эмулятора; 5 из 8 попыток android-e2e PR #122; повторы делались сериями `rerun_until3.sh` из сессии вручную, ~50 мин раннера на серию).
КОНТЕКСТ: новое — Н-407 остаётся ОТКРЫТЫМ («очередь автономности: повтор запуска эмулятора и Maestro при device offline»); 139 закрывает повтор на уровне CI-оркестрации, не правя шаг 135.
КОНТЕКСТ: Н-409 (коллизия Gradle-кэша двух раннеров, `Timeout waiting to lock journal cache`) — отдельный класс сбоя, у консультанта (раздельный `GRADLE_USER_HOME`); в сигнатуры повтора 139 не входит.

## Существующее

- Продукт Complior-mob origin/main `1e9bcc59a2` (merge PR #121; NEWER заданного в задании `8f338d885` — дерево есть истина): `.github/workflows/mobile.yml` — job `quality` на `[self-hosted, linux, x64, complior]`, job `android-e2e` на `[self-hosted, linux, x64, kvm, complior]`; шаги 995/108/111/117/123/135 дословно заморожены проводками своих контрактов.
- Канон сигнатур обрыва adb-транспорта УЖЕ живёт в CI продукта: замороженный шаг 117 main mobile.yml:385 (`device offline|device .* not found|DeviceServerDiedException`) и шаг 116 ветки PR #122 (живой лог 40198243018:2097: `device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException`); правило шага 117: «Провал assert/assertVisible (rc≠0 без сигнатуры) — НЕ повторяется». 139 наследует этот канон дословно и добавляет три альтернативы из поправки владельца (`INSTALL_FAILED`, `emulator: ERROR`, `Timeout waiting for emulator`).
- Н-407-флейки зафиксированы на PR #124: «e2e зелёный с 4-й попытки» — история attempt-ов run `40198247993` (id used в сценариях батареи).
- Батарея 135 — прецедент движка (`red_*.sh` → `probe.py`, режимы `--model`/`--stabs`, счёт SVJAZI, оракул source.json); frozen `frozen/contracts/117/2` и `frozen/contracts/135/1` держат зону `.github/workflows/mobile.yml` за экранами — потому батарея 139 пинит БАЙТЫ mobile.yml целиком (не только шаги).

## Нарезка (frontier)

- **А. Правка шага 135 в mobile.yml** (повтор внутри шага, как у 117) — отклонено: слово владельца «шаги frozen … и их текст НЕ трогать»; байты mobile.yml запинены инвариантом.
- **Б. Отдельный workflow `mobile-e2e-retry.yml` на `workflow_run` (выбран):** фильтр `conclusion=failure ∧ run_attempt==1 ∧ упал job android-e2e ∧ сигнатура в логе job-а ВНЕ эха скрипта`; `gh run rerun --failed` (только failed jobs); `permissions: {actions: write, contents: read}`; `runs-on: [self-hosted, linux, x64, complior]`; без checkout, без secrets.
- **В. Состав сигнатур (выбран):** 4 дословных альтернативы шагов 116/117 + 3 из поправки владельца. `gradle … lock` НЕ входит: коллизия двух живых прогонов на общем кэше (Н-409), повтор добавляет прогон в ту же коллизию; лечение — раздельный `GRADLE_USER_HOME` (предмет станции). Смешанный лог (провал проверки + сигнатура вне эха) — повтор: сигнатура свидетельствует об обрыве транспорта в этом прогоне, ровно один повтор с attempt-гейтом.
- **Г. Вырезка эха скрипта до grep** (`sed '/##\[group\]Run /,/##\[endgroup\]/d'`) — обязательна: эхо содержит сигнатуры в каждом логе (живой свидетель выше); без вырезки фильтр вырождается в «повторять любой красный».
- **Д. Суд батареи = статика YAML + поведенческий replay (выбран)** вместо cmp байтов файла: реализация вправе варьировать комментарии/формат, пока держит инварианты; replay исполняет скрипт шага в чистом окружении с подложным gh (закрытый алфавит команд), оракул — последовательность вызовов gh + stdout + rc.
- **Е. Замкнутая структура workflow (v2, блокер 1 критика):** батарея судит не только первый шаг, а ВСЮ структуру: ровно один job `retry`, ровно один исполняемый шаг `run:`; ключи верха `{name,on,permissions,jobs}`, job `{if,runs-on,timeout-minutes,steps}`, шаг `{name,env,run}` — всё вне алфавита именованный отказ (`ZAMKNUTOST`); триггеры только `workflow_run` (workflow_dispatch/schedule/push/pull_request* — отказ); `timeout-minutes ≤ 10`; якоря/алиасы/merge-ключи/`!!`-теги/`defaults` — отказ. Без checkout и без `uses:` (рекомендация — принятый канон модели).
- **Ж. Канон вызова и формы лога (v2, блокер 2 критика):** литерал `gh run rerun` — ровно один в теле шага И в файле, слово `rerun` — ровно один раз в файле, вызов дословно `gh run rerun --failed "$RUN_ID"`; скрытые пути (оболочка `-c`/`eval`/`xargs`/подстановка `$(…)`/`curl|wget`) вне алфавита скрипта; ИСПРАВЛЕНИЕ МОДЕЛИ: `grep -q` читает файл (не конец пайпа), `sed` без `q` — класс «pipefail + ранний выход потребителя пайпа» закрыт и в JID-выборке (`sed -n '1p'` вместо `head -n 1`); входы оси «размер/форма лога × положение сигнатуры» (101/20001/200001/2000000 строк × начало/середина/конец; одна строка 10 МБ; CRLF; без финального `\n`; NUL/не-UTF-8; пустой) — длинные логи генерируются во время прогона, в репо не хранятся.

## Предмет и граница

Один наблюдаемый результат: **упавший android-e2e прогона `mobile` перезапускается РОВНО ОДИН раз автоматически — отдельным workflow `.github/workflows/mobile-e2e-retry.yml` — только при инфраструктурной сигнатуре сбоя эмулятора в логе job-а вне эха скрипта; mobile.yml и шаги frozen не меняются (пин байтов); красная батарея харнесса доказывает все классы входов до реализации.**

Вне предмета: правка шагов/mobile.yml (вариант А), повтор внутри шага 135, Gradle-блокировка (Н-409), `mobile-cloud-e2e`, серии «пока не зелёное», второй и далее повторы.

## Инварианты

1. Триггер: `on.workflow_run.{workflows: [mobile], types: [completed]}`; job `if:` несёт три условия (`name == 'mobile'`, `conclusion == 'failure'`, `run_attempt == 1`) И те же три стража повторены телом скрипта — поведение судится прогоном, не только выражением.
2. Ровно один вызов `gh run rerun`, обязательно с `--failed` и `"$RUN_ID"`; циклов `while`/`until`/`for` в скрипте нет; серия невозможна: после rerun событие `completed` придёт с `run_attempt == 2` и будет отброшено стражем. Канон литералов (v2): `gh run rerun` — ровно один в теле шага И в файле; слово `rerun` — ровно один раз в файле целиком; скрытые пути повтора (оболочка `-c`, `eval`, `xargs`, подстановка `$(gh run rerun …)`, `curl`/`wget` на api-путь `/rerun`) — вне алфавита скрипта, именованные отказы `SKRITYJ_VYZOV`/`SETEVOJ_VYZOV`.
3. Сигнатуры — единая строка (source.json `signatury_regex`, workflow несёт её побайтово, судит вход `struktura-signatury`): `device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException|INSTALL_FAILED|emulator: ERROR|Timeout waiting for emulator`; grep только по логу с вырезанным эхом шага.
4. Права ровно `{actions: write, contents: read}` (токен — `${{ github.token }}`); обращений к `secrets` и литеральных токенов в файле нет. Fork-PR не повторяется: android-e2e падает `PILOT_DEMO_CODE_ABSENT` — вне списка сигнатур.
5. `runs-on: [self-hosted, linux, x64, complior]` (GitHub-hosted заблокированы бюджетом, слово владельца 25.10); `timeout-minutes ≤ 10`.
6. `mobile.yml` не тронут: байты = пин sha256 `31c400e7…` (снят с origin/main `1e9bcc59a2`); живой безфлаговый прогон на дереве с правленым mobile.yml — rc 1 `MOBILE_YML_IZMENEN`.
7. Оракул — source.json в памяти ДО вызова субъекта; носители (копия mobile.yml, живой фрагмент лога) — пины sha256, рассинхрон — rc 2 `ORACLE_TAMPERED`; закрытые алфавиты: `${{ }}`-выражения, jq-фильтр `gh api`, команды подложного gh.
8. Замкнутая структура (v2, блокер 1): ровно один job `retry` и ровно один исполняемый шаг `run:` — любой дополнительный job/шаг/`uses:`/скриптовый путь, способный повторить прогон, отвергается статикой до replay (именованный `ZAMKNUTOST`); ключи верха `{name,on,permissions,jobs}`, job `{if,runs-on,timeout-minutes,steps}`, шаг `{name,env,run}`; триггеры только `workflow_run`; `timeout-minutes ≤ 10`; якоря/алиасы/merge-ключи/`!!`-теги/`defaults` — отказ.
9. Класс pipefail (v2, блокер 2): в скрипте шага НЕТ ранних потребителей пайпа — `grep -q` читает файл (не конец пайпа), `sed` без `q` (в т.ч. выборка первого job-id через `sed -n '1p'`, не `head -n 1`); на логе 2000000 строк с сигнатурой в первой строке модель даёт POVTOR (замер входа `dlinnyj-log-nachalo-2000000`), обманный стаб раннего `grep -q` красен (SIGPIPE → ложный SKIP).

## Приёмочный критерий

Обозначения: `W` = `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh`; `P` = `python3 fixtures/workshop_project/e2e_avtoperezapusk_139/probe.py`.
1. Дано: нет `--repo`/`MOB_REPO` и субъекта; когда: `W`; тогда: rc 1, `SUBJECT_ABSENT` + 40 строк `CASE <вход> KRASNO (SUBJECT_ABSENT)` (замер: 40).
2. Дано: модель workflow; когда: `W --model`; тогда: rc 0, 40/40 `CASE <вход> ok` = 30 replay + 9 struktura + 1 derevo, время ≤ 60 с (замер: 40, ~8 с).
3. Дано: модель и 32 обманных стабов (мутации кода, связи `stab_vhod`); когда: `W --stabs`; тогда: rc 0, контроль 40/40, 36 строк `STAB <стаб> <вход> KRASEN`, финал `SVJAZI 36`, живых 0 (замер: 32 стаба / 36 связей). Негатив: прохождение стабом своего входа — rc 1 `STAB_ZHIV: N`; правка носителя — rc 2 `ORACLE_TAMPERED` (замер смоока: rc 2).
4. Исходы входов (полная таблица осей — `osi.md` к пачке; кратко): POVTOR — 7 входов инфра-сигнатур + `upali-oba` + 10 входов класса «размер/форма лога» (длинные логи 101…2000000 строк × положение сигнатуры: 6, строка 10 МБ, CRLF, без финального `\n`, NUL/не-UTF-8) + `mnogo-jobov-20000`; SKIP — `chistyj-proval`, `nizhe-poroga`, `skript-eho-signatury`, `dlinnyj-eho-200001` (эхо + длинный лог без сигнатуры), `pustoj-log`, `attempt-2-ofline`, `conclusion-success`/`-cancelled`, `upal-quality-tolko`, `gradle-lock`, `fork-pr-bez-sekreta`; структурные входы — триггер/права/раннер/if/rerun/секреты/алфавит/канон сигнатур/ЗАМКНУТОСТЬ; красный вход дерева `pravka-mobile-yml` → `MOBILE_YML_IZMENEN`. Свидетели критика: деревья extra-step/extra-job — `W --repo` rc 1 с именованной `ZAMKNUTOST` (замер смоока: оба rc 1).
5. Дано: продукт с реализацией (после accept и freeze); когда: `W --repo <корень продукта>`; тогда: rc 0. Живой CI продукта после merge в main: первый реальный infra-флейк получает ровно один `rerun --failed`, чистые провалы не повторяются — наблюдение оркестратора, вне батареи (платформа: `workflow_run` исполняется из default branch).

## Зоны и исполнители

ЗОНА architect: contracts/139-e2e-avtoperezapusk.md fixtures/workshop_project/e2e_avtoperezapusk_139/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА implementer: .github/workflows/mobile-e2e-retry.yml (репо Complior-mob)
Соседние зоны: `.github/workflows/mobile.yml` — зона экранов 117/118/135 (сверено по `frozen/contracts/135/1^{commit}`); файл 139 новый, mobile.yml не правит (пин байтов, инвариант 6), пересечение зон пусто.
Проводка self-test батареи в CI харнесса кладёт ОРКЕСТРАТОР интеграционным коммитом (образец 132/135). Работа implementer раздаётся после accept критика и freeze v1.

ПРЕДПОСЫЛКИ:
- setting `gh` CLI в PATH раннеров с меткой `complior` (workflow его вызывает; отсутствие даст именованный `command not found` на первом живом запуске — ловец живым прогоном).
- setting политика репозитория GitHub не запрещает повышение `actions: write` per-workflow (сейчас ограничений нет — остаточный риск ниже, ловец живым прогоном).
- setting платформа: `workflow_run` исполняется из default branch — workflow начнёт действовать только после merge в main продукта; в PR-ветке событие не приходит (батарея это не судит, платформенное ограничение).

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh

ПРОВОДКА-ЭНФОРСМЕНТ: норма владельца «один автоматический повтор android-e2e, только по инфраструктурным сигнатурам эмулятора, без серий из сессии, без правки frozen шагов» получает механический гейт: батарея красна по 40 входам (19 POVTOR: 7 сигнатур + upali-oba + 10 форм лога + mnogo-jobov; 11 SKIP; 9 структурных осей включая ЗАМКНУТОСТЬ; вход правки mobile.yml), 32 обманных стаба / 36 связей; self-test CI харнесса `bash …/red_e2e_avtoperezapusk_139.sh --stabs`, после ленда — безфлаговый red-режим с `--repo`. Подключение self-test в CI — ОРКЕСТРАТОР интеграционным коммитом (совет б критика, образец 135): точная строка в `registry/ci-steps.tsv` — `step	check:e2e-avtoperezapusk-139-family-selftest	21	bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` (после строк контракта 135); чистая пачка архитектора даёт `check_provodka` rc 1 «guard не подключён» — это ожидаемо до интеграционного коммита. Продуктовая приёмка — живой прогон workflow после merge (реальный флейк → ровно один `rerun --failed`; чистый провал → нет повтора).

## Модель угроз

Субъект — файл workflow продукта. Батарея: статический разбор YAML (pyyaml 6.0.1 — та же версия, что пин шага 117 в mobile.yml) + исполнение скрипта шага в чистом окружении с подложным gh; оракул source.json в памяти, носители — sha256; имена-оси судятся литеральным равенством, не подстрокой.

ЗАЩИЩАЕТ:
- от зелени без реализации: безфлаговый режим без субъекта — rc 1 `SUBJECT_ABSENT` с перечнем 40 входов;
- от повтора «чего попало»: 7 входов сигнатур → POVTOR; входы без сигнатуры (E2E_NE_PROSHLA, NIZHE_POROGA, gradle-lock, fork-секрет, quality-only, пустой лог) → SKIP; связь `s-bez-signaturnogo-filtra` — chistyj-proval и gradle-lock;
- от эха скрипта (сигнатуры в КАЖДОМ логе): вход `skript-eho-signatury` на живом фрагменте run 40198243018 + связь `s-bez-eho-zaschity`; эхо + длинный лог без сигнатуры — вход `dlinnyj-eho-200001`;
- от петли и серий: страж attempt (вход `attempt-2-ofline`, связь `s-bez-attempt-guard`), ровно один rerun с `--failed` (связи `s-polnyj-rerun`, `s-dva-rerun`), запрет циклов while/until/for в скрипте (связь `s-cikl-for`);
- от лишних прав/секретов/чужого раннера/чужого триггера: структурные входы + связи `s-shirokie-prava`, `s-sekret-v-tekste`, `s-runner-ubuntu`, `s-chuzhoj-trigger`; алфавит `${{ }}` закрыт (связь `s-vyrazhenie-vne-alfavita`), права ровно `actions: write + contents: read`;
- от реакции на чужой job/workflow: jq-фильтр `android-e2e` из закрытого алфавита (подложный gh отвергает чужой фильтр `FILTER_VNE_ALFAVITA`), вход `upal-quality-tolko` + связь `s-bez-jobs-filtra`; множественные failed-job записи — вход `mnogo-jobov-20000`;
- от ИСПОЛНИМЫХ ВЕТВЕЙ ВНЕ НАБЛЮДАЕМОГО ШАГА (v2, блокер 1): замкнутая структура — вход `struktura-zamknutost` + связи `s-dop-shag-run`, `s-dop-shag-uses`, `s-dop-job-ubuntu`, `s-dop-job-selfhosted`, `s-dopolnitelnyj-trigger`, `s-jakor-merge`, `s-defaults-run-shell`; свидетели критика (extra-step/extra-job) отвергаются `--repo` rc 1 с именованной `ZAMKNUTOST`;
- от СКРЫТЫХ ПУТЕЙ ПОВТОРА (v2): канон литералов + запрет оболочки -c/eval/xargs/подстановки/curl — связи `s-env-podmena`, `s-svertyvanie-dva-rerun`, `s-skrytyj-bash-c`, `s-skrytyj-eval`, `s-skrytyj-xargs`, `s-skrytyj-podstanovka`, `s-setevoj-curl`;
- от ЛОЖНОГО SKIP НА ДЛИННЫХ ЛОГАХ (v2, блокер 2): входы класса «размер/форма лога × положение сигнатуры» (до 2000000 строк, строка 10 МБ, CRLF, без `\n`, NUL/не-UTF-8) — POVTOR на честной модели, связи `s-rannij-grep-q` (SIGPIPE) и `s-rannij-head` (141);
- от правки frozen-шагов: пин байтов mobile.yml — rc 1 `MOBILE_YML_IZMENEN` (вход `pravka-mobile-yml`).

НЕ ЗАЩИЩАЕТ:
- реальное исполнение gh/GitHub API живьём: подложный gh моделирует ответы API; ловец — живой прогон после merge (первый реальный флейк: ровно один rerun в истории run-а);
- наличие gh на раннере и политику прав репозитория — ПРЕДПОСЫЛКИ, ловец живой прогон (именованный отказ виден в логе job-а `retry`);
- платформенное ограничение default-branch: до merge в main продукта workflow не действует; ловец —merge и живой прогон;
- одновременные повторы двух РАЗНЫХ упавших прогонов допустимы (attempt-гейт — на прогон; два раннера станции); серия «пока не зелёное» исключена инвариантом 2;
- содержательную истинность самой идеи «сигнатура = инфраструктура»: смешанный лог (провал + сигнатура вне эха) повторится один раз — осознанный выбор нарезки В; ловец — история прогонов (не более одного rerun на run).
- сигнатуру в УСПЕШНОМ предыдущем шаге при последующем падении только на `E2E_NE_PROSHLA` (сырой замер критика: prior-successful-step-signature → POVTOR): нарезка В читает сигнатуру вне эха как свидетельство обрыва транспорта в прогоне — различие успешного/упавшего шага-носителя батарея не делает; ловец — история прогонов (не более одного rerun на run); ужесточение — только по новому слову владельца;

## Демаркация

Конформные входы (грамматика батареи): события workflow_run с полями name/conclusion/run_attempt + jobs API (name/conclusion/id, ЛЮБОЕ число записей) + текст лога ЛЮБОЙ длины и формы (до 2000000 строк и выше, одна строка 10 МБ, CRLF, без финального `\n`, NUL/не-UTF-8 байты, пустой); файл workflow с алфавитом выражений `{github.token, workflow_run.id, workflow_run.conclusion, workflow_run.run_attempt}`, jq-фильтром канона и командами gh `{api …/jobs, api …/logs, run rerun --failed}`; структура — замкнутые алфавиты ключей (верх/job/шаг) и триггеров. Валидный контрпример = инвариантность к значениям ∧ расхождение на конформном входе: conclusion success/cancelled; run_attempt 2; лог без сигнатур (E2E_NE_PROSHLA, NIZHE_POROGA, gradle-lock, PILOT_DEMO_CODE_ABSENT, пустой); сигнатура только в эхе шага (в т.ч. эхо + 200001 строка); упал quality; права шире; ubuntu-latest; триггер чужого workflow; доп. триггер workflow_dispatch; два rerun (в теле, в свёртке `>-`, в env-подмене); доп. шаг run/uses; доп. job (ubuntu-latest и self-hosted); якоря/алиасы/merge-ключи/теги; defaults; secrets; выражение вне алфавита; цикл; скрытые вызовы (оболочка -c/eval/xargs/подстановка/curl); ранний выход потребителя пайпа (grep -q в конце пайпа, head) на длинных входах; правка mobile.yml. Неконформны: события иных типов, иные API-пути — батареей не судятся (закрытый алфавит подложного gh). Свёртка блок-скаляров `|`/`>`/`>-` сама по себе НЕ контрпример: проверки канона идут по разобранному значению и сырым литералам — укрывание невозможно, краснота предъявляется через второй вызов в свёртке (s-svertyvanie-dva-rerun).

## Незаполненные требования:
нет

## Сдача

- Батарея (замеры прогонов этой пачки v2, числа из вывода): `W` → rc 1 `SUBJECT_ABSENT` + 40 KRASNO; `W --model` → rc 0, 40/40 ok (~8 с); `W --stabs` → rc 0, контроль 40/40, 36 строк STAB … KRASEN, `SVJAZI 36`, живых 0 (~16 с); порча носителя → rc 2 `ORACLE_TAMPERED`; `W --repo` на чистом дереве-модели → rc 0; на дереве с правленым mobile.yml → rc 1 `MOBILE_YML_IZMENEN`; свидетели критика extra-step/extra-job → rc 1 `ZAMKNUTOST` (оба); модель на логе 200001 строка с ранней сигнатурой → POVTOR/RERUN (вход dlinnyj-log-nachalo-200001), стаб раннего grep -q на нём красен (SIGPIPE → ложный SKIP).
- Вторая мера (source.json): kejsy 40 (replay 30, struktura 9, derevo 1), stab_vhod 32, связей 36, носителей 2 (пины sha256), сигнатур 7; полная таблица осей — osi.md к пачке.
- Дальше: критик (Быстрый процесс: один полный круг) → freeze v1 → implementer (workflow в репо продукта) → живой прогон после merge; проводка self-test — оркестратор.
