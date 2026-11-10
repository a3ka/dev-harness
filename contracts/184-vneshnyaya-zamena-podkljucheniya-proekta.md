# Контракт 184 — подключение Complior-back и Complior-mob по А10

КЛАСС ЗАДАЧИ: смешанный — механика подключения dev-harness и отдельная миграция ссылок в двух продуктовых репозиториях; продуктовый runtime вне предмета.
КЛАСС РИСКА: обычный — положение профиля и ссылки рабочего инструмента; права, авторизация, деньги, ПД, согласия и юридические действия не меняются. Потеря sourceCanon или проверок CI недопустима независимо от класса.
КОНТЕКСТ: слово владельца 2026-11-10 ~18:17 UTC, `/home/harness/consultant/plan-doc.md` А10, Б22, С4, С11; проектные 054/996/161/168; `docs/owner/2026-11-10-plan-i-pravila-arhitektury.md` после публикации owner-PR #719. А1–А15: без брифа продуктового модуля `АРХИТЕКТУРА:` неприменима (меняется инструмент, не бизнес-модуль); A15 миграции БД не объявлены и не допускаются; критик отвечает шестым вопросом о соответствии А10, ревьюер предъявляет `СВЕРКА-АРХИТЕКТУРЫ:`.

## Существующее

- Резолвер `scripts/profile_resolver.sh:152-202` открывает FD корневого `harness.project.json` и проверяет реальный inode до чтения; перенос обязан сохранить fd-boundary 054, замкнутую грамматику и origin значений. `scripts/connect_project.sh:180-248` создаёт `.harness/{contracts,verdicts,registry,fixtures}` и `.harness/project-layer.json`, но профиль создаёт в корне. **Обнаруженное несовпадение:** `scripts/gen_project_workflow.sh:113-122` уже читает `.harness/harness.project.json`, однако требует там `projectId`; репо-профиль 054 несёт `repoId`, а `projectId` поставляет отдельный project-layer (поле `projectId` не входит в алфавит репо-слоя 054). Просто перенести root JSON внутрь `.harness/` недостаточно: generator отвергнет честный проект `profil-rashozhdenie`; дублировать JSON с другим алфавитом запрещено. `project_workflow.sh` и `next_id.sh` получают профильный workflowPaths; 996 оставляет state и реестр внутри корня проекта, а 161 требует собственный projectId и манифест перед spawn.
- Прямые проверки корневого профиля ещё есть в `scripts/check_project_standard.sh`, `check_staged.sh`, `check_zones.sh`, `done_contract.sh`, `done_wave.sh`, `gitw`, `lib_zones.sh`, `make_task.sh`, `next_id.sh`, `pre_critic.sh`, `push_product.sh`, `spawn_agent.sh`, `verify_ci_parity.sh`; отдельно `connect_project.sh` его пишет. Их нельзя оставить на legacy-fallback: иначе проект с переехавшим профилем получает корневые registry/contracts или теряет sourceCanon-gate. Профиль слоя `.harness/project-layer.json` уже остаётся рядом с workflow-state; резервирование тегов и проверка origin 996 не заменяются.
- Замер read-only: `git grep -n -i 'harness' -- . ':!.harness'` в `/home/harness/projects/Complior-back` находит ссылки в `.github/workflows/ci.yml` (строки 4–8, 37, 44–60 и др.), `.gitignore:12`, `.review/`, `server/src/auth/{adapter,delivery}.js`, `tests/tools/{check_context_budget,check_harness_fixtures,ci_scope,generate_module_map}.py`, `harness.project.json`; доменное имя `harness` в `app/harness`, API и тестах НЕ является ссылкой на каталог инструмента. Такой же вызов в Complior-mob находит `.github/workflows/mobile.yml` (checkout под `.harness`, `.harness117` и проч.; вызовы батарей), `README.md:4`, `STRUCTURE.md:24,28`, `mobile/{ci-screens.json,structure-policy.json}`, `harness.project.json`. Точный счёт нельзя брать по слову `harness`: есть продуктовый Agent Harness и его API; проверяется путь `.harness/` либо имя `harness.project.json` как самостоятельный токен. Живая проверка текущего backend вне `.harness/` даёт 220 строк-ссылок, включая историческую `.review/`; это объём миграции, не заявление о возможности её переписать в этой зоне.
- Backend `.harness/contracts/168-product-harness-cutover.md:15-25,72` (frozen/168/2) требует после внешней замены удалить и `.harness/`, и профиль из HEAD; первое буквально противоречит А10. Frozen 054 И-1 требует корневой профиль и фиксирует P1; frozen 122 Г1 фиксирует отдельный JSON с `projectId` без resolver; 996 требует профильные пути внутри R, но не отдельный origin; 161 сохраняет внешний state манифеста. До отдельных owner/v+1 168, 054 и 122 эти противоречия не обходить «зелёным» подключением. Предыдущий вариант 184 (`dad18f49f`, git-sidecar с отдельным origin) отклонён решением А10; архив в `archive/184/variant-a-dad18f49f`, не источник новых обязанностей.

## Frontier и решение

1. **Репо-профиль `.harness/harness.project.json`, существующий слой `.harness/project-layer.json` и прежние workflowPaths внутри R — выбранная конструкция А10.** Один версионированный git-проект сохраняет identity, sourceCanon, реестр и архив; проектный код/CI/конфиги/документы не импортируют вспомогательный каталог. Резолвер переоткрывает новый путь тем же fd-boundary; генератор CI сравнивает manifest projectId с effective projectId от этого резолвера вместо второго несовместимого разбора JSON; потребители переходят на единое место определения профиля, bootstrap переносит файл без потери JSON-значений. Два репо-профиля/старый root fallback не принимаются как успешная миграция. Корень продукта остаётся самостоятельным без станционного origin.
2. Оболочка подключения станции с динамическим указателем на профиль и неизменным корневым файлом отклонена: прямые потребители выше обходят оболочку, а продуктовый корневой JSON всё ещё ссылается на `.harness/`. Sidecar с отдельным origin и overlay второго checkout также отклонены словом владельца: история workflow должна остаться в продукте.

## Инварианты

1. Dev-harness использует ровно один репо-профиль продукта `.harness/harness.project.json` и прежний project-layer; root `harness.project.json` в продукте и одновременные root+internal profile — отказ `profil` без fallback. Подмена identity, symlink на внешний профиль, потеря sourceCanon или несоответствие workflowPaths — именованный отказ до записи. На допустимом переносе effective repoId, projectId, sourceCanon (все sources/priority/gate), canonicalRemote, CI, commands, contextPack и пять workflowPaths побайтно те же; `project_workflow`, `make_task`, `spawn_agent`, `reserve_project_contract`, `freeze_contract`, `done_contract`, `check_zones` работают на собственном repo и собственном origin, а не на установке и не на чужом repo. `gen_project_workflow.sh --write` принимает ci.json с тем же projectId из effective project-layer, отвергает чужой projectId до записи CI и не читает дублирующий JSON-корень.
2. В отслеживаемых файлах продукта вне `.harness/` не встречаются самостоятельные ссылки `.harness/` и `harness.project.json` (проверить CI, корень, документы, конфиги, исходники и вложенные пути, не только top-level). Только содержимое `.harness/` и git-служебный `.git/` исключаются; `.review/` не исключается автоматически — исторические документы должны быть переведены без удаления свидетельств. Слово `harness` в бизнес-домене, `.harness117/` и обычный тестовый helper `harness.js` не равны `.harness/`. Ссылки в продуктовых CI на инструменты H переводятся на независимые продуктовые копии/задекларированные внешние батареи в отдельном продуктовом контракте; удаление проверок вместо переноса — не выполнение А10.
3. Миграция продукта — перенос root JSON внутрь `.harness/` с сохранением истории и всех ссылок; существующий `.harness/` остаётся HEAD/архивом. Работа backend 168 не объявляется done, пока её frozen-текст и реальные product CI-зависимости противоречат А10. Mob-контракты/пины батарей не переписываются этим харнесс-контрактом; отдельные продуктовые зоны получают собственную приёмку до cutover.
4. Конформный вход red-пробы — локальный git-проект со своим `.git`, отслеживаемыми ASCII/UTF-8 файлами, валидным JSON профиля по грамматике 054/996 и существующими путями; валидный контрпример = неизменность вердикта при замене названий, repoId и содержимого без появления служебной ссылки ∧ расходящийся rc/именованная причина на таком входе. Ожидания снимаются как литералы в памяти до вызова кандидата, match для ссылки — точный токен пути, не подстрока `harness` где-либо. Битый JSON, произвольная грамматика и отсутствие git не служат красным свидетельством.

## Приёмка

- Дано: локальный честный мир с внутренним профилем и ссылкой внутри `.harness/`; когда `python3 fixtures/workshop_project/external_connection_184/probe.py --model`; тогда rc 0, каждая клетка `CELL ... ok`, в том числе generator-good и generator-wrong-id. Дано: отдельные конформные миры со ссылками в CI/README/config/.gitignore/вложенном коде, с root profile и подменённым repoId; та же команда → rc 0 как честный оракул их отказов `ssylka`/`profil`.
- Дано: до-предметная станция; когда `python3 fixtures/workshop_project/external_connection_184/probe.py --repo /home/harness/projects/Complior-back`; тогда rc 1, именованные `CELL ... RED`, `PRODUCT_REF_COUNT` ненулевой и `PRODUCT_ROOT_PROFILE`; та же команда с `/home/harness/projects/Complior-mob` → rc 1. Дано: реализация плюс мигрированные продуктовые checkout; те же команды → rc 0, `PRODUCT_REF_COUNT 0`, ни root profile, ни красных клеток; `.harness/contracts`, `.harness/verdicts`, registry/state и history остаются на своём origin.
- Дано: обманные реализации; когда `python3 fixtures/workshop_project/external_connection_184/probe.py --stabs`; тогда rc 0 и каждая строка `STAB ... caught`; вход привязан к каждому стабу в коде батареи, общий case не засчитывается. Дано: добавлена одна ссылка за пределами каталога инструмента; когда `bash scripts/check_project_connection.sh --repo <toy-git>`; тогда rc 1 с причиной `ssylka`, тогда как тот же toy до мутации → rc 0; с чужим repoId → rc 1 `profil`. Генератор на ci.json с projectId собственного слоя → rc 0 и CI без `.harness/`, на чужом projectId → rc 1 `profil-rashozhdenie` без записи.
- Дано: кандидат на суд; когда `bash scripts/check_precision_gate.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md` и затем `bash scripts/pre_critic.sh contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md` (ПОСЛЕДОВАТЕЛЬНО); тогда оба rc 0. Перед done: `bash scripts/check_provodka.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md` → rc 0 после подключения пробы 184 в CI; `bash scripts/check_project_sources.sh --repo <product-root> --contract .harness/contracts/<product-NNN>.md --stage done` на продукте с sourceCanon → rc 0, без скрытого пропуска.

## Модель угроз

ЗАЩИЩАЕТ:
- От product CI/исходника/документа с живым путём `.harness/` защищает проверка git-файлов с отдельным предъявлением каждого класса; от silent-root fallback — проверка профиля до операций и собственного origin.
- От подмены файла вне R защищает существующая граница FD/inode резолвера 054; перенос местоположения не ослабляет её.

НЕ ЗАЩИЩАЕТ:
- Смысл устаревших названий «harness» без ссылки на путь (это может быть бизнес-модуль); ловец — ревьюер на дельте продукта.
- Семантику продуктового CI после переноса батарей 168 и моба; ловец — их собственные red-пробы/CI на продуктовых HEAD и product reviewer.

## Границы и исполнители

ЗОНА architect: contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md fixtures/workshop_project/external_connection_184/
ЗОНА implementer: scripts/profile_resolver.sh scripts/connect_project.sh scripts/check_project_connection.sh scripts/check_project_standard.sh scripts/check_staged.sh scripts/check_zones.sh scripts/done_contract.sh scripts/done_wave.sh scripts/gen_project_workflow.sh scripts/gitw scripts/lib_zones.sh scripts/make_task.sh scripts/next_id.sh scripts/pre_critic.sh scripts/push_product.sh scripts/spawn_agent.sh scripts/verify_ci_parity.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/gen_project_workflow.sh — 122 сравнение projectId c effective layer через резолвер, формат и состав CI без изменения.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 002 сохраняет прежние зоны; меняется лишь обнаружение проектного профиля.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 003 сохраняет прежние зоны; меняется лишь обнаружение проектного профиля.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 047 сохраняет прежние зоны; меняется лишь обнаружение проектного профиля.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 184, остальные jobs неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 184, чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 184, чужие замеры неизменны.
ПРЕДПОСЫЛКИ:
- setting CI dev-harness имеет Python 3, git и bash для 184; новых secrets, variables и environments нет.
- setting правки CI Complior-back/Complior-mob и отмена противоречия frozen backend 168/054 требуют отдельных продуктовых/owner-v+1 маршрутов, не входят в зону этого коммита architect.

## Проводка

ПРОВОДКА:
- guard=fixtures/workshop_project/external_connection_184/probe.py
ПРОВОДКА-ЭНФОРСМЕНТ: исполняемая батарея 184 подключается отдельным шагом CI харнесса; она вызывает настоящий `scripts/check_project_connection.sh` на disposable checkout и судит placement и ссылки, не заменяя поведенческой нормы роли.

## Незаполненные требования:
нет
