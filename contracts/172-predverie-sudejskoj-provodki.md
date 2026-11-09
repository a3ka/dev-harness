# Контракт 172 — преддверие судейской проводки

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — подготовка Git/станции перед судьёй; полномочия судьи, права доступа и политика безопасности не меняются.
КОНТЕКСТ: слово владельца 09.11 ~11:14 UTC: 170 остановлен до согласования архитектуры, преддверие 172 идёт сразу; ~13:45 добавлены ff-main, судейские ветки и пустые archive-worktree. Измерения станции: backend 11:25 (неопубликованный авторский OBJECT); 12:56/13:00 (manifest и state перед спавном), 13:29 (main/вердикты/archive). Это один отказ: судья получает объект до готовности проводки станции.

## Существующее

- Дверь `scripts/pre_critic.sh` судит контракт **до критика**, но не публикует OBJECT, не проверяет state/manifests и не синхронизирует main; не менять его прежние ноги. Дверь `scripts/zamok_predmeta.sh` берёт `--sostojanie` из живого ctx сессии, не из окружения; `scripts/check_no_leak.sh --check <абс-корень>` уже является детектором утечки и вызывается перед судом по `roles/orchestrator.md` и 024. Использовать их, а не второй замок или второй детектор.
- Маршрут `scripts/gitw` — обязательный для fetch/push по 045, `scripts/land_agent.sh` сохраняет автора при переносе, `scripts/gc_agent_branches.sh` убирает слитые wip с worktree, **не** доказывая отсутствие worktree у `archive/*`. Ни одна из этих дверей не подменяет ff-подготовку main или границу судейского вердикта.
- Семьи `contracts/024-*`, `contracts/045-*`, `contracts/165-*`, `contracts/167-*` и `fixtures/check_judge_gate/` закрепляют детектор, обмен, материализацию и frozen acceptance; 172 не переписывает их семантику. `registry/plan.tsv:100` содержит 172; у `wip/172/architect` исходно только bootstrap d7110da68; открытые PR станции #631/#630 и остальные из текущего списка не несут реализации 172. Эти пути/PR непригодны как готовое преддверие.

## Предмет

Публичная дверь `bash scripts/pre_judge.sh <prepare|sync-main|verdict|archive> --repo R [--branch B --sostojanie S --timeout T | --file V]` работает с локальным main-чекаутом R и origin-remote. `prepare` перед **каждым** спавном судьи требует `B=wip/<N>/<автор>` с локальным tip, в точности равным опубликованному `origin/B`; выводит `OBJECT=<полный tip origin/B>`, никогда не подменяет tip `HEAD` или локальным ahead. Отсутствующая/устаревшая публикация даёт rc 1 `VETKA_NE_OPUBLIKOVANA` и готовую команду `bash scripts/gitw push origin B` без автоматического push. `S` обязателен: абсолютный каталог состояния, переданный вызывающим из живого профильного ctx (как у zamok_predmeta); разрешённый путь строго вне realpath R; внутри checkout — rc 1 `SOSTOJANIE_V_CHECKOUT`. Скрипт не угадывает путь из cwd/окружения. Перед rc 0 он ждёт удаления `.omp/context/*.tsv` уборщиком (с конечным `--timeout`, не удаляет за уборщика) и вызывает действующий `scripts/check_no_leak.sh --check R` с проверкой rc: по истечении срока rc 1 `MANIFESTY_NE_UBRANY`, по красному детектору rc 1 `CHECK_NO_LEAK_KRASEN`. Печатает `SOSTOJANIE=<канонический S>` для задания судьи.

`sync-main` вызывается после fetch через `gitw` на чистом main; допускает равенство либо `git merge --ff-only origin/main` при ancestor(main, origin/main), с наблюдаемым обновлением checkout. При дивергенции или локальном ahead — rc 1 `MAIN_NE_FAST_FORWARD`, main и коммиты не меняются; stderr содержит **готовую команду** сохранить локальный tip в `wip/<N>/<author|judge>-main-saved` и только затем вернуть main к `origin/main` (без автосброса и auto-merge). `verdict --file V` требует judge branch `wip/<N>/<critic|adversary|reviewer|arbiter>`; staged либо уже committed вердикт на main даёт rc 1 `VERDIKT_V_MAIN`, любой иной не-судейский ref — rc 1 `NE_SUDJSKAJA_VETKA`. В `archive` любая запись `git worktree list --porcelain` с `branch refs/heads/archive/*` даёт rc 1 `ARCHIVE_WORKTREE` с сохранением worktree; без таких записей rc 0. Эти операции вызываются перед судом через роль orchestrator, а вердикт переносится прежним каналом после проверки; ни прямого коммита в main, ни удаления чужих refs/worktree.

Конформные входы: отдельный временный Git-репозиторий с bare origin, main, опубликованной или ahead авторской веткой, действительным внешним S, реальными staged/committed файлами и реальным `git worktree`; внешняя зависимость детектора отвечает по независимо созданному флагу. Валидный контрпример не зависит от конкретных имён/OID/пути и расходится на одном из этих входов, не на битом Git или отсутствующей утилите. Сбой Git/отсутствие детектора — rc 2 `NOT_IMPLEMENTED`, не фиктивный зелёный. Проза роли про источник S — cognitive-only: остаточный риск неверной подмены вызывающим; ловец — сверка стенограммы задания судьи с живым ctx оркестратором/ревьюером.

## Приёмка

- Дано: bootstrap без двери; когда `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo`; тогда rc 1, самостоятельные красные имена каждой клетки (не только первая ошибка). После реализации та же команда → rc 0: `published`, `prepare_no_state`, `missing_origin`, `stale_origin`, `state_inside`, `manifest_wait`, `leak_reject`, `ff_sync`, `nonff_sync`, `judge_verdict`, `verdict_no_file`, `nonjudge_verdict`, `staged_main_verdict`, `committed_main_verdict`, `archive_free`, `archive_attached` — по отдельности `ok`; отрицательные входы именованно отказывают, положительные показывают реальный tip/ff/ветку.
- Дано: честная контрольная дверь на тех же независимых Git-входах; когда `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --model`; тогда rc 0. Дано: обманные исполняемые варианты; когда `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --stabs`; тогда rc 0, каждый `STAB ... caught`, ни одного `ZHIV`; адреса вариант→вход содержатся только в коде.
- Дано: `main` и `origin/main` разошлись; когда `bash scripts/pre_judge.sh sync-main --repo R`; тогда rc 1 `MAIN_NE_FAST_FORWARD`, локальный tip не меняется и в stderr готова команда сохранения и возврата. Дано: `origin/main` — потомок main; та же команда → rc 0, рабочий checkout содержит файл из опубликованного потомка и main tip равен origin/main.
- Дано: published author B, внешний S, manifests убраны, `check_no_leak --check R` rc 0; когда `bash scripts/pre_judge.sh prepare --repo R --branch B --sostojanie S --timeout 1`; тогда rc 0 и точные `OBJECT=<origin/B>` и `SOSTOJANIE=<realpath S>`. Дано: незаконченная публикация, внутренний S, оставленный manifest или детектор rc≠0; та же команда на каждом отдельном входе → rc 1 и названная выше своя причина. Дано: published author B, опущен только `--sostojanie`; та же команда без `--sostojanie` → rc 1 `NE_POLNYJ_VHOD`, даже если внешнее состояние существует.
- Дано: staged/committed verdict на main либо attached archive worktree; когда `bash scripts/pre_judge.sh verdict --repo R --file V` либо `bash scripts/pre_judge.sh archive --repo R`; тогда rc 1 со своей причиной и без мутации; judge branch и archive без worktree на тех же входах → rc 0. Дано: staged verdict на `wip/172/implementer`; команда verdict с `--file V` → rc 1 `NE_SUDJSKAJA_VETKA`. Дано: staged verdict на judge branch с опущенным `--file`; команда verdict без `--file` → rc 1 `NE_POLNYJ_VHOD`.
- До критика: `bash scripts/pre_critic.sh --repo . contracts/172-predverie-sudejskoj-provodki.md` → rc 0. Перед done: `bash scripts/check_provodka.sh . contracts/172-predverie-sudejskoj-provodki.md` → rc 0; при проектном `harness.project.json` также `bash scripts/check_project_sources.sh --stage done` → rc 0.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/172-predverie-sudejskoj-provodki.md fixtures/dver_pered_kritikom/predverie_172/
ЗОНА implementer: scripts/pre_judge.sh roles/orchestrator.md .omp/agents/orchestrator.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 012 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 024 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 045 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 072 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 074 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 094 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 099 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 104 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 124 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 140 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 166 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 167 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 998 только новый шаг.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 002 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 003 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 005 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 010 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 166 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 167 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 998 только генерация нового шага.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 172.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 172.
После ленда оркестратор записывает собственную строку `step` 172 в `registry/ci-steps.tsv`, её замер в `registry/ci-zamery.tsv` и генерирует `.github/workflows/ci.yml` через `gen_ci_steps.sh --write`, затем `--check` rc 0; команда строки — `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo`. До подключения CI guard-канала done невозможен.
ПРЕДПОСЫЛКИ:
- setting Существующий CI харнесса уже предоставляет Python 3, git и bash; временные Git-деревья фикстуры создаются под TMPDIR; новых secrets, variables и environments нет.

ПРОВОДКА:
- role=roles/orchestrator.md «0. Перед каждым спавном судьи: `bash scripts/pre_judge.sh prepare --repo <root> --branch wip/<N>/<автор> --sostojanie <путь из живого ctx> --timeout 30`; после fetch: `bash scripts/pre_judge.sh sync-main --repo <root>`; перед материализацией вердикта: `bash scripts/pre_judge.sh verdict --repo <root> --file <вердикт>`; при ротации: `bash scripts/pre_judge.sh archive --repo <root>`; отказ — стоп, не имитация готовности (172).»
- guard=scripts/pre_judge.sh
