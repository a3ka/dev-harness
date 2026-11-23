# Контракт 206 — Г-1: среда изолированного судьи

КЛАСС ЗАДАЧИ: кодовый (+ нормы ролей).
КЛАСС РИСКА: рисковый — безопасность записи и путей: path-guard и граница вердикта pre_judge. После реализации adversary, затем reviewer на одном OBJECT.
ТЕГ: 4 — обновление ролей и расширения требует перезапуска проектов после поставки.
СДАЧА: fixtures/workshop_project/sreda_sudji_206/SDACHA.md

КОНТЕКСТ: owner-затравка 206 и задание станции /tmp/dev-harness-verify/task-arch206.md — план v9, слот С2, Г-1; источник области входов и измеренной боли.
КОНТЕКСТ: contracts/025-sreda-cwd-rc.md — G1 свободного чтения, G2/G3 границы записи; этот предмет меняет классификацию источника cp как чтения, не открывает новые каталоги.
КОНТЕКСТ: contracts/032-spawn-pinning-worktree.md — существующая грамматика пина и git-оракул; не меняются.
КОНТЕКСТ: contracts/037-samodostatochnyj-cwd-i-priemnik-task.md — М1 распознавания владельца изолированной копии; все условия сохраняются.
КОНТЕКСТ: contracts/172-predverie-sudejskoj-provodki.md — граница verdict, коды и первая строка отказа; сохраняются.
КОНТЕКСТ: fixtures/path_guard/red_own_copy_paket_b.sh — существующий адрес-доставки/своя-копия и положительный контроль записи в собственный пин; не отменяются.

## Существующее

Сверено на базе db56f44d1012854b6098a7076fccdae0855badeb. HANDOFF хранит историческое состояние 19.11; актуальная база и номера 206–208 установлены деревом, не этим состоянием.

- `.omp/extensions/path-guard.ts` уже имеет публичный judge-CLI и реальную factory tool_call. `sessionCwd` допускает свою копию при валидном HOME, .git-каталоге, единственном worktree, отсутствии .git-предков и точном owner.json.id/sessionName. Пакет Б уже различает место записи и адрес доставки — новый транспорт пина не нужен.
- `extractFileOperands` считает все аргументы cp записью: источник живого state запрещается даже при разрешённой цели. `extractExtraWriteOperands` знает mkdir, но имя исполняемого файла сравнивает без basename. Оба дают вспомогательный отказ либо незамеченную опасную цель.
- `scripts/pre_judge.sh verdict` уже принимает вердикт в отдельном репозитории на судейской ветке, в том числе закоммиченный. Detached runtime не является местом записи вердикта; менять это ограничение не требуется. Отказы VERDIKT_VNE_REPO и NE_SUDJSKAJA_VETKA не дают формы продолжения в своей копии.
- `roles/critic.md`, `roles/adversary.md`, `roles/reviewer.md` — потребители новой нормы; производные `.omp/agents/<роль>.md` материализует существующий `scripts/gen-harness.ts`, не ручная правка.
- Батареи 025/032/037/066 и `predverie_172` сохраняются. Замок и его учёт RELEASE уже различают verdikt_zakommiten/obryv_bez_verdikta; новый писатель учёта не вводится. Модель 206 строится дельтой над настоящими файлами указанной базы, не двойником Node/git.

## Предмет и граница доказательства

Один результат: critic/adversary/reviewer выполняет вспомогательные файловые операции и сдаёт вердикт в своей изолированной копии, не прекращая суд из-за исправимой формы операции и не ослабляя границ записи.

Боль задания: 9 обрывов 20.11, 6 обрывов 21.11 за 46 минут; станция — 5 из 14 запусков. Это переданный исходный замер, не повторный замер автора. Поддерживаемые пути получения входов — mkdir scratch, чтение источника cp, запись/коммит вердикта после изолированного спавна, отказ при перепутанном runtime/delivery cwd.

Статика доказывает наличие одной канонической нормы в ролях; вызовы настоящих guard/pre_judge и реальные git-коммиты доказывают локальный эффект. Следование модели норме доказывается отдельно живыми тремя судами после реализации и рестарта; зелёная модель не объявляет эту приёмку исполненной.

## Инварианты

1. В своей М1-копии проходят write/edit с абсолютным path, mkdir -p с абсолютной целью либо относительной целью и абсолютным cwd копии, чтение текста с `>` внутри кавычек, cp из читаемого state в собственный scratch. Источник cp — чтение; все его цели по-прежнему проверяются общим pathAllowed. Собственная scratch-allowlist 025 сохраняется.
2. Запись вне разрешённых копии/пина/scratch, в живой state, чужой WORKTREE, через symlink наружу или `..`, от чужого/пустого owner, а также относительная mkdir без cwd — отказ. Явный конфликт фактического дерева с event/env-пином остаётся refuse. Операнды литеральных cp/mkdir после `--`, включая имена с ведущим `-`, не исключаются из суда записи: последняя цель cp и каждая цель mkdir проверяются. Никакого allow-all для судей, HOME, /tmp или всех wip не вводится.
3. Предметная операция определяется независимо от размещения бинарника: cp и /bin/cp; mkdir и /bin/mkdir имеют одинаковый суд цели. Квалифицированное имя не превращает запись в чтение. Грамматика предмета: простая команда cp с литеральными источниками и последней целью, флагами -a/-r/-R/-p/-x/--, либо mkdir с -p/-- и литеральными целями; до `--` — флаги, после него все токены — операнды. Одинарные/двойные кавычки допускают пробел и LF в пути. Пустая команда не пишет; односимвольный путь не теряется; NUL в команде даёт block, а не молчаливый pass.
4. Каждый block/refuse guard сохраняет существующий диагноз и добавляет отдельной строкой каноническую подсказку формы из model/build.py HINT. pre_judge сохраняет rc и первую строку отказа; VERDIKT_VNE_REPO получает форму repo/file собственной копии, NE_SUDJSKAJA_VETKA — форму судейской ветки своей копии. Указание формы не является разрешением сменить цель на чужую или обойти страж.
5. Три роли несут одну и ту же норму, побайтово NORM из model/build.py (канон нормы ниже). Пак задания согласован: WORKTREE — адрес доставки, запись — pwd своей копии; verdict-коммит — на wip/<NNN>/<роль>, runtime остаётся только читаемым объектом суда. Формальная проверка роли не доказывает следование агента этой норме. Настоящая запись в явно назначенный собственный пин остаётся разрешённой по frozen-пакету Б; чужой пин — это НЕ такой назначенный путь.
6. pre_judge verdict по-прежнему отказывает вердикту вне repo, авторской ветке, detached HEAD и вердикту staged/committed в main. Граница файла проверяется после нормализации абсолютного пути или относительного от repo, включая `..` и symlink каталогов/файла; выход наружу в любой форме даёт rc 1 VERDIKT_VNE_REPO с канонической подсказкой. Честный внутренний относительный путь и реальные коммиты critic/adversary/reviewer в собственной копии проходят. Никакой автоматической правки веток/main и снятия охраны state нет.
7. В живом одноразовом проекте после рестарта проходят подряд critic, adversary, reviewer на одном общем назначенном 40-hex OBJECT, переданном наблюдателю через `--object`. Поле object каждого из трёх START равно именно этому OBJECT; разные либо общий чужой OBJECT дают rc 1 OBJECT_NE_SOVPADAET. Все три START имеют разные holder и завершаются RELEASE verdikt_zakommiten; RELEASE obryv_bez_verdikta после T0 отсутствует. Ноль судов и незавершённый суд не считаются зеленью. Учёт не фабрикуется батареей.

Конформный контрпример = достижимый вход названной операции ∧ дефект не зависит от конкретного значения токена/пути ∧ расхождение на этом входе. Произвольная shell-программа не становится предметом полной shell-песочницы. Привязки мутаций к различающим входам — только MUTATIONS в probe.py; stabs.tsv — производный каталог.

## Канон нормы и порядок реализации

Implementer переносит в три роли NORM из model/build.py отдельной самостоятельной строкой, заменяя противоречащие указания о записи вердикта непосредственно в основной репозиторий. Первая реализационная дельта — guard/pre_judge; затем норма ролей и `node scripts/gen-harness.ts`. Отказ исправляется переформулированием той же операции внутри той же разрешённой области; не новым маршрутом, не чужим клоном и не подавлением ошибки. Неисправимый отказ сохраняется как диагноз среды в вердикте, а не выдаётся за продуктовый FAIL/accept. Получение канала записи вердикта при полностью неисправной среде — оркестратору, не разрешение обойти страж.

Норма не отменяет frozen 045 STOP при подлинном нарушении границы; она отделяет переформулирование допустимой операции от смены маршрута. Критик и ревьюер сверяют это различие по живому трейсу.

## Приёмочный критерий

R — корень проверяемого dev-harness; раннер находится в H, где доступен immutable BASE модели. Все одноразовые миры создаются внутри собственной .scratch-206, настоящий HOME миров не совпадает с scratch-allowlist миров.

- Дано база без реализации; `bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo .` → rc 1 с поимённой краснотой cp/формы подсказок/норм ролей. Это red-before, не машинная дверь готовности реализации.
- Дано честная модель; `bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model` → rc 0, KRASNYE=0. Дано C после реализации; тот же раннер `--repo R` → rc 0. Каждая охранная отрицательная ветвь судится своим полным rc/stdout/stderr, а не общим ненулём.
- Дано адресные мутации настоящих файлов модели; `bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs` → rc 0, ZHIVYH=0. Отсутствующий/неуникальный якорь, rc2 или авария Node/git — NOT_IMPLEMENTED rc2, не поимка. Каждая новая мутация критика становится адресной записью кода, даже если уже поймана другой проверкой.
- Правило формы: `bash scripts/check_sdacha.sh . contracts/206-sreda-sudji.md --run` → rc 0; `bash scripts/pre_critic.sh contracts/206-sreda-sudji.md` → rc 0 до сдачи критику. Отдельные двери формы перечислены в сдаточном листе.
- Правило регресса после C: `bash fixtures/path_guard/red_own_copy_paket_b.sh R` → rc 0; `bash fixtures/path_guard/red_extract_pin_actual_066.sh R` → rc 0; `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo` → rc 0. Новые подсказки добавляются после существующих строк; режимы prepare/sync-main/archive и предмет 185 сохраняются.
- Дано три настоящих последовательных суда в одноразовом проекте на общем назначенном OBJECT, T0 записан до первого START, T — корень его внешнего состояния; `python3 fixtures/workshop_project/sreda_sudji_206/live.py --ledger "$T/s/uchet.jsonl" --since "$T0" --repo-id "$RID" --subject "$N" --object "$OBJECT"` → rc 0, SUDA=3 OBRYVOV=0 VERDIKTOV=3. Пустой учёт/неполная тройка → rc 1 TRI_SUDA_NE_PREDJAVLENY; чужой/разный OBJECT → rc 1 OBJECT_NE_SOVPADAET; RELEASE с обрывом → rc 1 OBRYV_BEZ_VERDIKTA; непарный/непоследовательный RELEASE → rc 1 VERDIKT_NE_PODTVERZHDEN. Недоступный журнал → rc 2 NOT_IMPLEMENTED; невалидный журнал (включая JSON не-объект, битый JSON и BOM) → rc 2 NOT_IMPLEMENTED: NEVALIDNYJ_ZHURNAL. Контроли наблюдателя: `python3 fixtures/workshop_project/sreda_sudji_206/live_control.py` → rc 0. Источник учёта — только настоящий zamok_predmeta проекта; моделируемые git-коммиты батареи не выдаются за эти суды.
- Правило поставки: оркестратор подключает только строку `step` собственной батареи `bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo .` и её замер; `bash scripts/gen_ci_steps.sh --write` и `bash scripts/gen_ci_steps.sh --check` → rc 0. Поставка ТЕГ 4, рестарт проектов и live-приёмка обязательны до done. Model/stabs — инструменты проверки конструкции, не подмена repo-приёмки в CI.

ПРЕДПОСЫЛКИ:
- setting Node >=26, Python3, bash, git, GNU realpath, jq и shellcheck доступны на станции/CI; новых secrets/variables/environments и настроек GitHub нет
- setting оркестратор материализует свою CI-строку через scripts/gen_ci_steps.sh, обновляет роли существующим генератором и исполняет ТЕГ 4 с перезапуском проектов до живой тройки

## Модель угроз

ЗАЩИЩАЕТ:
- от обрыва из-за классификации чтения cp как записи, потери абсолютного имени бинарника и отсутствия формы продолжения — реальные публичные CLI и factory guard, настоящий pre_judge и коммиты git;
- от ослабления границы записи в копии/state/чужом дереве — отдельные охранные предъявления owner, symlink, parent, чужой WORKTREE и live-state;
- от пусто-зелёного результата live — ровно три разных START нужных ролей на одном назначенном OBJECT, парные последовательные RELEASE и отсутствие обрыва;
- от плацебо проверки — полный rc/stdout/stderr побайтово, оракулы в памяти до вызова, честный контроль до мутаций, единственность адресных замен и отказ на инфраструктурной аварии.
НЕ ЗАЩИЩАЕТ:
- от компрометации старта/интерпретатора/бинарника, непрозрачного произвольного кода и гонки общего uid — граница 032, ловец reviewer/живая станционная проба;
- от ложного tool-level deny другого слоя, в частности bash.patterns .omp/config.yml: расширение этой зоны требует отдельного предмета; ловец живая тройка и orchestrator по первому реальному диагнозу, done при красной тройке запрещён;
- от доказательства поведения модели одной статикой роли или только локальными фикстурами — ловец обязательные три настоящих суда после рестарта; до C этот результат NOT_RUN;
- от недоступности всех разрешённых каналов вердикта одновременно — ловец orchestrator по диагнозу среды; норма не даёт нового права записи вне копии;
- от всех форм shell за пределами объявленной грамматики cp/mkdir — прежняя граница 025, ловец adversary/reviewer; сохранность остальных frozen-клеток обязательна.

## Зоны

ЗОНА architect: contracts/206-sreda-sudji.md fixtures/workshop_project/sreda_sudji_206/
ЗОНА implementer: .omp/extensions/path-guard.ts scripts/pre_judge.sh roles/critic.md roles/adversary.md roles/reviewer.md .omp/agents/critic.md .omp/agents/adversary.md .omp/agents/reviewer.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

Производные три .omp/agents-файла добавлены по причине генерации ролей, а не расширения предмета. Исходники production и роли architect этой пачкой не меняет. Следующие объявления сняты из zones_load высших живых заморозок базы; одинаковый исполнитель не освобождается от сохранения чужих обязательств.

ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/path-guard.ts — 025 только классификация cp и подсказка; остальные границы сохранены
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/path-guard.ts — 030 только подсказка; QA URI не меняется
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/path-guard.ts — 032 только операции cp/mkdir и подсказка; pin/git-оракул не меняется
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/path-guard.ts — 037 только операции cp/mkdir и подсказка; все условия М1 сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .omp/extensions/path-guard.ts — 066 только среда судьи 206; источники actual и грамматика пина сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 140 только подсказки и граница файла verdict; OBJECT/runtime не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 172 только подсказки и нормализация границы файла verdict; коды и остальные режимы сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 185 только подсказки и граница файла verdict; доверенный детектор не меняется
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только среда изолированного судьи
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 041 только среда изолированного судьи
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 043 только среда изолированного судьи
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 027 только среда изолированного судьи
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 038 только среда изолированного судьи
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 050 только среда изолированного судьи
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 050 только производная материализация нормы среды судьи 206 генератором scripts/gen-harness.ts
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только собственная строка батареи 206
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только собственный замер батареи 206

ПРОВОДКА:
- role=roles/critic.md «В изолированном суде WORKTREE задания — адрес доставки, место записи — собственная копия pwd; scratch создавай внутри неё абсолютным путём либо с абсолютным cwd bash. Вердикт пиши и коммить в собственной копии на wip/<NNN>/<роль>, не в detached runtime-checkout и не в основном чекауте; перед коммитом вызови pre_judge.sh verdict --repo <своя-копия> --file <абсолют-вердикта>. При Н-85 используй подсказку только для переформулирования той же операции в той же разрешённой копии; не меняй цель на чужой WORKTREE или живой state и не обходи страж. Если допустимая форма вновь отказана, сохрани диагноз в вердикте среды и передай его оркестратору, а не завершай суд без вердикта.»
- role=roles/adversary.md «В изолированном суде WORKTREE задания — адрес доставки, место записи — собственная копия pwd; scratch создавай внутри неё абсолютным путём либо с абсолютным cwd bash. Вердикт пиши и коммить в собственной копии на wip/<NNN>/<роль>, не в detached runtime-checkout и не в основном чекауте; перед коммитом вызови pre_judge.sh verdict --repo <своя-копия> --file <абсолют-вердикта>. При Н-85 используй подсказку только для переформулирования той же операции в той же разрешённой копии; не меняй цель на чужой WORKTREE или живой state и не обходи страж. Если допустимая форма вновь отказана, сохрани диагноз в вердикте среды и передай его оркестратору, а не завершай суд без вердикта.»
- role=roles/reviewer.md «В изолированном суде WORKTREE задания — адрес доставки, место записи — собственная копия pwd; scratch создавай внутри неё абсолютным путём либо с абсолютным cwd bash. Вердикт пиши и коммить в собственной копии на wip/<NNN>/<роль>, не в detached runtime-checkout и не в основном чекауте; перед коммитом вызови pre_judge.sh verdict --repo <своя-копия> --file <абсолют-вердикта>. При Н-85 используй подсказку только для переформулирования той же операции в той же разрешённой копии; не меняй цель на чужой WORKTREE или живой state и не обходи страж. Если допустимая форма вновь отказана, сохрани диагноз в вердикте среды и передай его оркестратору, а не завершай суд без вердикта.»
- guard=fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh

ПРОВОДКА-ЭНФОРСМЕНТ: поведение — role-каналы выше; guard загружается omp на tool_call. CI-батарею repo подключает оркестратор в собственной строке; статический лист и модель не объявляют канал уже внедрённым до реализации. Для done нужен полный check_provodka, не только --grammar.

## Незаполненные требования:
- Нет неописанных требований конструкции. Реализация production, производные роли, CI-проводка, ТЕГ 4 и живые три суда — обязательная следующая стадия implementer/orchestrator, не выполнены автором красной батареи.
