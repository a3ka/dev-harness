# Контракт 105 — лаунчер передаёт политику установки в сессию проекта (П-107а)

КОНТЕКСТ: слово владельца `docs/owner/2026-10-15-suzhenie-dopuska-pilota.md` (репетиция входа агента в `a3ka/Complior-mob`, П-107 «работает в харнесе, не работает в проекте»); разведка `history://ArchitectComplierMobRepeat2` и запись А-918 (NABLIUDENIA_ARCHITECT.md): `workshop` в режиме проекта исполняет `exec omp --profile dev …` без `-e`/`--config` (workshop:1104-1105), а роли кладёт в `$HOME/.omp/agent/agents` (workshop:869) — omp под `--profile dev` читает `~/.omp/profiles/dev/agent/…` (omp://config-usage.md «Profiles»), и ни харнесные `.omp/extensions/*.ts` (path-guard 025, будущий spawn-guard 104), ни `.omp/config.yml` (always-ask 002, deny-паттерны 025, modelRoles, isolation 067), ни роли в сессию ПРОЕКТА не попадают. Шесть контрактов лаунчера (054/055/058/060/070 + probe) судили баннеры и env, не argv `exec omp`. Зависимости от ленда 103/104 — нет. Номер 105 минтован dual-control (тег `id/CONTRACT/105`, строка `registry/contracts.tsv`).

## Существующее

- `workshop:442-489` — разбор argv: `--plan/--models/-r/--check-metering/--probe/--config/--yolo/--fable`; `:484` — именованный отказ на `--approval-mode*|--approvals*|--yolo*|--dangerously-skip-permissions*` (форма `die "флаг $1 затирает политику подтверждений …"`, контракт 002, держит `scripts/check_approval.sh`); `:485` `-*) break` — все прочие флаги уходят в omp хвостом `"$@"`.
- `workshop:522-534` — оверлей `--models`: разворачивается `gen-harness.ts --resolve-overlay` в `$ZONE/models-overlay.yml`, передаётся omp как `OVERLAY=(--config <файл>)`.
- `workshop:864-873` — роли: `AGENTS="$HOME/.omp/agent/agents"` после подмены `HOME=$PSTATE/home` (055 М1), `gen-harness.ts --into "$AGENTS"` + `--check`; `:822-823` — N2-гард цепочек (058) канонизирует `$PSTATE/home/.omp/profiles/$PROFILE/agent` и `$PSTATE/home/.omp/agent/agents`.
- `workshop:1040-1046` — проба: `workshop PROBE OK` + `PROMPT:`, выход ДО exec; `:1104-1105` — `cd "$PROJECT"; exec omp --profile "$PROFILE" --model "$LIVE_MODEL" "${OVERLAY[@]}" "${RESUME_ARGS[@]}" "${YOLO_ARGS[@]}" --append-system-prompt … --tools … "$@"`. Дев-вход (`:592-601`) делает `cd "$HERE"` — там `.omp/` установки грузится как проектный слой omp сам; в режиме проекта cwd — проект.
- `.omp/extensions/*.ts` установки — 5 файлов на HEAD (`ls .omp/extensions/*.ts | wc -l` = 5: exit-marker, gate-draft, path-guard, rc-prefix, startup-digest); `.omp/config.yml` — политика (bash.patterns deny 025, tools.approvalMode always-ask 002, modelRoles, task.isolation 067, retry.fallbackChains); `roles/*.md` — 9 ролей, `.omp/agents/*.md` — их порождение.
- omp 18.3.1 (`omp --help`): `--config=<value>` «Load an extra config.yml-style overlay for this run (repeatable)»; `-e, --extension=<value>` «can be used multiple times»; `--hook=<value>` — тот же путь загрузки; `--no-extensions` «Disable extension discovery (explicit -e paths still work)». omp://settings.md:103-105: поздний `--config` перекрывает ранний; CLI-оверлеи выше проектных `<cwd>/.omp/config.yml` и глобальных настроек. omp://extension-loading.md: явные `-e/--hook` грузятся после авто-обнаруженных `<cwd>/.omp/extensions` и `<agentDir>/extensions`; дедупликация по абсолютному пути. omp://config-usage.md «Profiles»: под `--profile <name>` каждый пользовательский путь `~/.omp/agent/…` резолвится в `~/.omp/profiles/<name>/agent/…`; «Named profiles ignore PI_CODING_AGENT_DIR».
- Прецедент клеток на стаб-omp: `fixtures/workshop_project/red_samodostatochnost_repo_060.sh:135-144,306-336` (к7/к8 — стаб в PATH пишет своё окружение), `red_github_token_070.sh:109-121` (стаб + env-дамп ребёнка); раннеры с `--model`: `fixtures/_krasnye_095.sh`, `_krasnye_098.sh`; стаб-пак-матрица: `fixtures/zashchita_main_104/battery_stubs.sh`.

## Предмет

`workshop` в режиме проекта передаёт omp политику установки ЯВНО, аргументами exec: по одному `-e <абс. путь>` на каждый `$HERE/.omp/extensions/*.ts` установки; `--config $HERE/.omp/config.yml` раньше оверлея `--models` (если он задан); роли — в каталог агента профиля `$HOME/.omp/profiles/dev/agent/agents` (тот, что omp резолвит под `--profile dev`); флаги хвоста, снимающие эту политику (`--no-extensions`, `--extension <x>`, `--extension=<x>`, `-e <x>`, `--hook <x>`, `--hook=<x>`), — именованный отказ rc 1 на разборе argv, до любого вызова omp, той же формы, что `--approval-mode` (002); `--probe` печатает строки `EXT:`/`CONFIG:`/`AGENTS:` из тех же массивов, что идут в exec (один код пробы и живого режима; проба omp не зовёт).

Один наблюдаемый результат: argv и окружение ФАКТИЧЕСКОГО `exec omp` (стаб-omp в PATH) несут три слоя политики установки; `bash fixtures/_krasnye_105.sh` → rc 0.

## НЕ предмет

- Собственные `<проект>/.omp/extensions/*`, `<проект>/.omp/config.yml`, `AGENTS.md` проекта — их грузит omp сам (cwd-слой); доверие к расширениям проекта (глушить ли их `--no-extensions` от имени установки) — отдельный вопрос владельца, здесь не решается (061: один отказ — один контракт).
- `.omp/models.yml` установки (провайдеры/baseUrl прокси учёта) в сессии проекта — отдельный класс, не трогается (кандидат Н-записи оркестратора).
- Дев-вход (`workshop` без проекта): cwd = установка, слои грузятся проектным путём omp; код отказа флагов на разборе argv общий для обоих входов (одна `case`-ветка), но клетки 105 судят только режим проекта.
- Позиционная дыра `-*) break` (workshop:485): `workshop <репо> --чужой-флаг --no-extensions` — первый незнакомый флаг обрывает разбор, и запретный флаг за ним уходит в omp. Та же дыра у `--approval-mode` (002) сегодня; закрывается одной правкой на оба класса отдельным контрактом, не здесь. Клетка И-4 судит запретный флаг ПЕРВЫМ токеном хвоста — форма 002 дословно.
- Порядок загрузки расширений между собой (порядок `-e`) — клетки судят множество.
- Семантика самих расширений/конфига в сессии проекта (что делает path-guard при cwd=проект, Н-85-allowlist и т.п.) — П-107/П-111.
- `scripts/check_approval.sh`, `scripts/verify_antiplacebo.sh`, `scripts/profile_resolver.sh`, `scripts/gen-harness.ts` — не правятся.

## Frontier (по коду workshop и omp 18.3.1)

Ось A — доставка расширений установки в сессию проекта.
- A1 (выбор): по одному `-e <абс. файл>` на каждый `$HERE/.omp/extensions/*.ts`. Argv exec = список пробы = `ls`-замер владельца; ничего не объявленного (`.js`, подкаталоги, `README.md`) не грузится; дедуп по абсолютному пути безвреден.
- A2: один `-e $HERE/.omp/extensions` (каталог). omp сканирует уровень: `*.ts`, `*.js`, `*/index.{ts,js}`, `*/package.json#omp.extensions` без gitignore — грузит незаявленное; argv не показывает, что загружено. Отклонено.
- A3: копия расширений в `~/.omp/profiles/dev/agent/extensions` (авто-обнаружение). Второй источник истины, дрейф копии от установки, нечем судить без диска. Отклонено.
- A4: `extensions:` в порождённом оверлее `--config`. Тот же эффект, что A1, но список спрятан в файле — проба и клетка судили бы файл, не argv. Отклонено.

Ось B — доставка `.omp/config.yml` установки.
- B1 (выбор): `--config $HERE/.omp/config.yml` CLI-оверлеем. По omp://settings.md:103-105 оверлей ВЫШЕ проектного `<cwd>/.omp/config.yml`: политика установки (always-ask, deny-паттерны) перекрывает конфиг проекта — ровно то, что требует допуск пилота; оверлей `--models` идёт ПОЗЖЕ и перекрывает modelRoles политики — та же семантика, что у дев-входа (оверлей > проектный слой).
- B2: копия в `~/.omp/profiles/dev/agent/config.yml` (глобальные настройки). Ниже проектного слоя: проект мог бы снять always-ask своим `.omp/config.yml`. Отклонено.
- B3: `PI_CONFIG_FILES` env. Тот же порядок (до `--config`), но невидим в argv/пробе и наследуется потомками. Отклонено.

Ось C — роли.
- C1 (выбор): `$HOME/.omp/profiles/dev/agent/agents` — путь, который omp резолвит под `--profile dev` (замер: `PI_CODING_AGENT_DIR=…/.omp/profiles/dev/agent`, `$HOME/.omp/agent` в dev-сессии отсутствует). N2-цепочка `$PSTATE/home/.omp/profiles/$PROFILE/agent` уже канонизируется (workshop:822).
- C2: `<проект>/.omp/agents`. Файлы в дереве проекта — Граница-7 контракта 054 («ни одна ветка не создаёт файлы за проект»). Отклонено.
- C3: `PI_CODING_AGENT_DIR`. Игнорируется именованным профилем (omp://config-usage.md). Отклонено.

Ось D — пользовательские флаги, снимающие политику.
- D1 (выбор): именованный отказ на разборе argv, форма 002 (`die "флаг $1 …"`), до любого вызова omp — дешёвая проверка на дешёвом этапе; клапана владельца нет (нет слова).
- D2: молча вырезать флаг. Пользователь не узнаёт, что его намерение отвергнуто. Отклонено.
- D3: пропустить (пользователь знает, что делает). Снимает весь замок одним словом — тот же аргумент, что в 002. Отклонено.

Ось E — проба.
- E1 (выбор): строки `EXT:`/`CONFIG:`/`AGENTS:` печатаются из тех же массивов/переменных, что подставляются в exec (один код); клетка И-5 судит конгруэнтность пробы и argv стаб-omp на одном HOME.
- E2: отдельный вывод «что бы передали». Второе вычисление — класс А-918 (проба доказывает не exec). Отклонено.

## Решения

1. Список расширений — `"$HERE"/.omp/extensions/*.ts` (glob установки, только регулярные файлы `*.ts`, абсолютные пути); каждому — пара `-e <путь>` в argv exec. Пустой список допустим (ноль пар).
2. Политика — пара `--config "$HERE/.omp/config.yml"` в argv exec; при `--models` пара оверлея `"${OVERLAY[@]}"` стоит ПОЗЖЕ пары политики.
3. `AGENTS="$HOME/.omp/profiles/$PROFILE/agent/agents"` (PROFILE=dev, workshop:99) после подмены HOME (055 М1); `gen-harness.ts --into/--check` без изменений; N2-цепочка на этот же путь; `$HOME/.omp/agent/agents` лаунчер не создаёт.
4. Отказ флагов — одна `case`-ветка разбора argv рядом с `--approval-mode*` (workshop:484): `--no-extensions|--extension|--extension=*|-e|--hook|--hook=*) die "флаг $1 затирает политику расширений установки …"`; стоит ДО `-*) break`. Посторонние флаги хвоста по-прежнему уходят в omp.
5. Строки stdout `EXT: <путь>` (по одной на расширение, в порядке списка), `CONFIG: <путь политики>`, `AGENTS: <путь каталога ролей>` печатаются безусловно (и в пробе, и в живом режиме — как `WORKFLOW:/STATE:/METERING:`), из тех же массивов, что идут в exec; проба omp не вызывает (сегодняшняя граница 054 §Демаркация сохраняется).
6. Порядок в exec: `--profile "$PROFILE" --model "$LIVE_MODEL" --config <политика> -e … "${OVERLAY[@]}" "${RESUME_ARGS[@]}" "${YOLO_ARGS[@]}" --append-system-prompt … --tools … "$@"`.

## Инварианты

Мир клеток (`fixtures/workshop_project/_mir_105.sh`): субъект копируется в игрушечную УСТАНОВКУ `$INSTALL` (своя `.omp/extensions/` с N случайных `*.ts`, N ∈ 2..5, приманки `notes.js` и `README.md`; копия `.omp/config.yml`; симлинки `scripts/ roles/ config/ AGENTS.md .omp/agents` на корень); toy-репо профиля 054/058 с собственным `.omp/extensions/evil.ts`; стаб-omp в PATH пишет argv, env и счётчик вызовов. Оракулы (N, пути, состав `roles/`) — в памяти клетки до вызова субъекта.

- И-1 (`red_ext_ustanovki_105.sh`). Дано: установка с N `*.ts`, репо с `evil.ts`; когда: `bash $INSTALL/workshop <репо>` (живой, стаб-omp); тогда: rc 0, стаб запущен ровно 1 раз, в argv ровно N самостоятельных токенов `-e`, множество их значений = множество абсолютных путей `$INSTALL/.omp/extensions/*.ts`, ни один токен не содержит `evil.ts`, токена `--no-extensions` нет. Негатив (в той же клетке): `evil.ts` проекта в argv → красно.
- И-2 (`red_config_do_overlay_105.sh`). Дано: оверлей со случайным литеральным id модели; когда: живой запуск с `--models <оверлей>`; тогда: rc 0, `--config` встречается ровно 2 раза, первое значение = `$INSTALL/.omp/config.yml`, второе — файл, несущий этот id. Парный: без `--models` — ровно 1 `--config` = политика.
- И-3 (`red_roli_v_profil_105.sh`). Дано: живой запуск; когда: стаб-omp получил окружение; тогда: rc 0, в stdout ровно одна строка `AGENTS: <P>`, `P = <HOME ребёнка>/.omp/profiles/dev/agent/agents` (HOME — из env-дампа стаба), `ls P` = состав `roles/` установки (9 имён на HEAD), `<HOME ребёнка>/.omp/agent/agents` не существует.
- И-4 (`red_otkaz_flagov_105.sh`). Дано: шесть форм запретного флага первым токеном хвоста (`--no-extensions`; `--extension <x>`; `--extension=<x>`; `-e <x>`; `--hook <x>`; `--hook=<x>`); когда: живой запуск; тогда: rc 1, в stderr строка, начинающаяся `ОТКАЗ: флаг <токен> `, счётчик стаба = 0 (ни `--version`, ни exec). Парный позитив: `--toy-flag-<случайное>` → rc 0, токен в argv стаба.
- И-5 (`red_proba_odin_kod_105.sh`). Дано: один HOME на оба прогона; когда: `--probe`, затем живой запуск; тогда: проба rc 0 при счётчике стаба 0, stdout пробы несёт ≥1 `EXT:`, ровно 1 `CONFIG:`, ровно 1 `AGENTS:`; множество `EXT:` = множество значений `-e` живого argv; `CONFIG:` = первое значение `--config` живого argv; `AGENTS:` пробы = `AGENTS:` живого режима.

## Демаркация контрпримеров

Конформные входы: установка с любым числом регулярных `*.ts` в `.omp/extensions/` (включая ноль), любые имена; проект с любым содержимым `<проект>/.omp/`; оверлей `--models` — YAML-отображение с литеральными id либо `@семейство` из `config/agent_models.json`; хвост — любые токены, первый из которых судится И-4. Значения (N, имена `*.ts`, id модели, посторонний флаг) случайны на прогон — стаб с зашитым списком установки HEAD клетку не проходит. Валидный контрпример = инвариантность к значениям ∧ расхождение честного и стаба на конформном входе. Что не судится: порядок `-e`, содержимое `.ts`, поведение omp после exec.

## Модель угроз

ЗАЩИЩАЕТ: от сессии проекта без политики установки (три слоя — расширения, конфиг, роли — наблюдаемы в argv/окружении фактического exec, не в баннере); от снятия политики первым флагом хвоста (шесть форм, отказ до любого вызова omp); от перекрытия политики установки конфигом проекта (CLI-оверлей выше проектного слоя); от пробы, доказывающей не то, что исполняется (конгруэнтность на одном HOME).
НЕ ЗАЩИЩАЕТ: от расширений самого проекта (`<cwd>/.omp/extensions` грузит omp — вопрос доверия, вне предмета); от запретного флага за посторонним флагом (позиционная дыра `-*) break`, общая с 002 — отдельный контракт); от подмены `$HERE/.omp/*` на диске установки (целостность установки — 016/018); от поведения загруженных расширений при cwd=проект (П-107/П-111).

## Приёмка (сценарии; грамматика 050)

1. Дано: дерево ДО реализации (`workshop` HEAD `c9ae1f55e`); когда: `bash fixtures/_krasnye_105.sh`; тогда: rc 1 — стаб-пак `7/7 … 28/28` rc 0, пять клеток rc 1, каждая со своей строкой `105 И-N КРАСНО: …` (И-1 «флагов -e в argv 0», И-2 «--config в argv 1 раз», И-3 «строк AGENTS: в stdout 0», И-4 ««--no-extensions»: rc=0», И-5 «проба не печатает ни одной строки EXT:»), `клеток просмотрено: 5`. (Прогнано этой пачкой.)
2. Дано: честная модель `fixtures/workshop_project/model_105/workshop.sh`; когда: `bash fixtures/_krasnye_105.sh --model`; тогда: rc 0 — 5/5 клеток зелёны, стаб-пак 7/7 + 28/28. (Прогнано этой пачкой.)
3. Дано: честная реализация в `workshop`; когда: `bash fixtures/_krasnye_105.sh`; тогда: rc 0 — 5/5 клеток зелёны, 7/7 + 28/28. Негативные пары живут внутри клеток (И-1 `evil.ts`; И-2 без `--models`; И-3 каталог вне профиля; И-4 посторонний флаг; И-5 счётчик пробы). (Проверено архитектором на одноразовом патче копии `workshop` в скратче — 5/5 зелёны; патч не часть пачки.)
4. Правило: каждый мутант стаб-пака красен ровно на своей клетке и зелен на четырёх остальных; команда `bash fixtures/workshop_project/battery_stubs_105.sh`; rc 0, вывод `мутантов 7, поймано на своей клетке 7` и `честных входов мутантов 28, зелёных 28`. (Прогнано.)
5. Живая проба (класс 4, ловец — adversary/reviewer круга implementer): из корня установки `./workshop --probe <клон проекта>` печатает ровно `ls .omp/extensions/*.ts | wc -l` (= 5 на HEAD) строк `EXT:` с абсолютными путями установки, `CONFIG: <установка>/.omp/config.yml`, `AGENTS: …/.omp/profiles/dev/agent/agents`; живой `./workshop <клон проекта>` с реальным omp: в сессии `bash` с относительным редиректом (`printf x > t.txt`) отвергается стражем/deny-паттерном (путь `.omp/config.yml` + `path-guard.ts` дошли), ростер `task`-агентов несёт 9 ролей установки. cognitive-only до прогона; остаточный риск — расхождение стаб-omp и реального omp в разборе `-e`/`--config` (ловец: эта проба).
6. Регрессии: `bash fixtures/_krasnye_054.sh`, `_krasnye_055.sh`, `_krasnye_058.sh`, `_krasnye_059.sh`, `_krasnye_060.sh`, `_krasnye_070.sh` → rc 0 до и после реализации (семьи лаунчера не меняют семантику); `bash scripts/check_approval.sh` → rc 0 (ветка 002 не тронута).

Замер: `ls fixtures/workshop_project/red_*_105.sh | wc -l` = 5; `grep -c ':red_' fixtures/workshop_project/battery_stubs_105.sh` = 7 (строки матрицы MUTANTS); `ls .omp/extensions/*.ts | wc -l` = 5; `ls roles | wc -l` = 9.

## Зоны (check_zones)

ЗОНА architect: contracts/105-lanuncher-politika-proekta.md fixtures/workshop_project/ fixtures/_krasnye_105.sh NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: workshop
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: NABLIUDENIA.md HANDOFF.md

Зона implementer раздаётся ПОСЛЕ заморозки (прецедент 070): ЗОНА-строка заявляет исполнителя precision-гейту 043 заранее. Дельта implementer — Решения 1–6: одна `case`-ветка на разборе argv, два массива политики, путь `AGENTS`, три строки баннера, один порядок exec (одноразовый патч архитектора — 12 строк, не носитель).

ПЕРЕСЕЧЕНИЕ implementer: workshop — 028 implementer-зона: формула дев-зоны ПОТРЕБЛЯЕТСЯ, не правится; канонический guard 028 не переступается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 030 implementer-зона (инвентарь/гонки спавна): новых процессов 105 не спавнит; `--tools` не меняется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 010 architect-зона (топология orchestrator/architect, историческая заявка; прецедент 055/058/070)
ПЕРЕСЕЧЕНИЕ implementer: workshop — 002 architect-зона (политика подтверждений, frozen): ветка `--approval-mode*` (:484) и `YOLO_ARGS` не правятся; новая `case`-ветка 105 стоит рядом, `scripts/check_approval.sh` остаётся зелёным
ПЕРЕСЕЧЕНИЕ implementer: workshop — 054 implementer-зона (заморожена frozen/contracts/054/1): probe-граница (omp в пробе не зовётся), P1..P9/W2-семантики, промпт И-9 не правятся; дельта — три строки баннера и путь ролей; судятся клетками 054
ПЕРЕСЕЧЕНИЕ implementer: workshop — 055 implementer-зона (заморожена frozen/contracts/055/1): подмена HOME М1, PSTATE, лок М2, метеринг М3 без дельт; каталог ролей остаётся ВНУТРИ `$PSTATE/home`
ПЕРЕСЕЧЕНИЕ implementer: workshop — 058 architect-зона (шаринг agent.db, landed): N2-цепочка :823 переводится на новый путь ролей (:822 уже канонизирует `profiles/$PROFILE/agent`); шаг AGENTDB не трогается, батарея 058 зелёная
ПЕРЕСЕЧЕНИЕ implementer: workshop — 059 (landed): сверка путей профиля не затрагивается
ПЕРЕСЕЧЕНИЕ implementer: workshop — 060 (landed): HARNESS_WORKFLOW_ROOT/TOOLS_ROOT-экспорты и блок R1-R3 не затрагиваются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 070 implementer-зона (landed): шаг GITHUB и его баннер не трогаются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 054 implementer-зона каталога (заморожена): новые файлы семьи (`_mir_105.sh`, `model_105/`, `battery_stubs_105.sh`, пять `red_*_105.sh`); файлы 054 не правятся
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 055 implementer-зона каталога (заморожена): `red_izoljacija_projectid.sh`, `_verify_055_r3.sh` не правятся
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 057 implementer-зона (заморожена): `red_profil_dva_sloja.sh` не правится
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 058 architect-зона семьи: `red_sharing_agentdb.sh` не правится; в маркер `.probe-only` дописан абзац 105 (прецедент 070)
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 059 architect-зона семьи: `red_sverka_puti_profylja.sh` не правится
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 060 architect-зона семьи: `red_samodostatochnost_repo_060.sh` не правится; батарея 105 батареи соседей не зовёт
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/ — 070 architect-зона семьи: `red_github_token_070.sh` не правится; `.probe-only` — дописка абзаца
ПЕРЕСЕЧЕНИЕ architect: fixtures/_krasnye_105.sh — 058 architect-зона раннера: новый отдельный раннер, `_krasnye_054/055/058/059/060/070` не правятся
ПЕРЕСЕЧЕНИЕ architect: NABLIUDENIA_ARCHITECT.md — 015 implementer-зона двойного владения (landed-миграция заголовков); 105 владеет путём как записью воркфлоу-наблюдений (прецедент 037/065/066/069/070)
ПЕРЕСЕЧЕНИЕ architect: NABLIUDENIA_ARCHITECT.md — 070 architect-зона (запись наблюдений): дописка А-919/А-920, прежние записи не правятся

РАБОТА НЕ РАЗДАЁТСЯ: scripts/verify_antiplacebo.sh (030/044 — семья probe-only 034 вне case_*-глоба :585) registry/contracts.tsv (dual-control 023/031; минт 105 стоит) .omp/ (005/002 frozen — политика потребляется, не правится) scripts/profile_resolver.sh scripts/gen-harness.ts scripts/check_approval.sh fixtures/_krasnye_054.sh fixtures/_krasnye_055.sh fixtures/_krasnye_058.sh fixtures/_krasnye_059.sh fixtures/_krasnye_060.sh fixtures/_krasnye_070.sh (раннеры соседей) .github/workflows/ci.yml package.json (подключение guard — реализационной пачкой ПОСЛЕ ленда, прецедент 104; до этого в пачке не правятся)

## Остаточный риск

- Стаб-omp судит argv, не загрузку: расхождение разбора `-e`/`--config` между стабом и omp 18.3.1 ловится только живой пробой (приёмка 5).
- Позиционная дыра `-*) break` (общая с 002) — названа в НЕ предмет; ловец — adversary, адрес — отдельный контракт.
- Пустой список расширений (установка без `.omp/extensions/*.ts`) проходит И-1 с N=0 — клетки 105 гоняют N ≥ 2; на HEAD N=5. Ноль расширений в установке — не дефект лаунчера, а состояние установки (016/018).
- Оверлей политики выше проектного `.omp/config.yml`: проект, которому нужна СВОЯ настройка поверх установки, её не получит — осознанная цена допуска пилота; снятие — слово владельца.

## Незаполненные требования:
нет

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/_krasnye_105.sh

ПРОВОДКА-ЭНФОРСМЕНТ: предмет 105 — механизм лаунчера (argv/окружение exec), не поведенческая норма ролей; канал один — guard `fixtures/_krasnye_105.sh` (агрегатор клеток `fixtures/workshop_project/red_*_105.sh` + стаб-пак `battery_stubs_105.sh`; семья probe-only 034: файлы вне case_*-глоба шарда verify_antiplacebo, scripts/verify_antiplacebo.sh:585; ключ семьи — маркер `fixtures/workshop_project/.probe-only`). Раннер красен ДО реализации (пять клеток «предмет отсутствует») и зеленеет вместе с ней; до ленда предъявляется судьями каждого круга локально; подключение в CI (прямой ci-шаг `bash fixtures/_krasnye_105.sh` после шага семьи 070 + ключ package.json) — РЕАЛИЗАЦИОННОЙ пачкой ПОСЛЕ ленда предмета (прецедент 074/093/098/104: преждевременный шаг держал CI черновика красным). Норм-строк ролей контракт не вводит.

## Замечания по применимости норм

- 041: нового парсера чужого ввода нет — отказ флагов есть литеральное сравнение токена с замкнутым алфавитом шести форм в `case`; `§Модель угроз` приведена по свойству.
- 050 (грамматика приёмки): каждая строка — сценарий с rc либо правило с командой; каждому зелёному — парный негатив внутри клетки.
- 050 (вертикальный срез): норма → клетки → правка `workshop` → guard → суд одной пачкой; живая проба выделена именем (приёмка 5).
- 061 (один отказ — один контракт): позиционная дыра `-*) break` и `.omp/models.yml` названы и вынесены, не правятся здесь.
- Н-39/Н-62: привязка мутантов к клеткам — в коде `battery_stubs_105.sh`/`model_105/workshop.sh`; контракт пары не повторяет.
- А-418: честная модель написана по тексту контракта (интерфейс вызова workshop, предмет 105 и только он), не по каркасу `workshop`.
