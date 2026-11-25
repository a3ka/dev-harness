# Контракт 221 — штатный project-минт строки реестра без ручного hooksPath

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: рисковый — права/безопасность: запись в исключительную dual-control зону реестра контрактов проекта, исполнение commit-стража и identity.

КОНТЕКСТ: задание `/tmp/dev-harness-verify/task-architect221.md`, затравка `/tmp/dev-harness-verify/consultant/draft-221-mint-line-proekt.md`, письма `inbox-back-1200-mint-line-door031.txt` и `inbox-back-1210-mint-line-ok-pr1033.txt` того же каталога consultant. Измеренная боль Н-456 — два ручных внешних hooksPath при минте бэкенда (PR #799/#1033). В базе `8b52fade7975034d7cabece67e46c16a7d1abe3b` записи Н-456 и строки плана 221 ещё нет; письма и задание — доступные первичные свидетельства, не выдуманная запись журнала. Открытый owner-PR #1350 несёт затравку и план; иных открытых PR с решением этого предмета поиск `gh pr list --repo a3ka/dev-harness` не выявил. Нового sourceCanon нет.

## Существующее

- scripts/mint_line.sh:123–140 проверяет исполняемость effective pre-commit, используя core.hooksPath либо git-dir/hooks. Содержимое хука НЕ проверяет. Строка 224 УЖЕ передаёт все четыре GIT_AUTHOR/GIT_COMMITTER имени/email явно как orchestrator. Поэтому неточно считать текущую identity коммита чтением из .git/config: реальный второй отказ — запрет file-config в живом страже, который env не отменяет.
- scripts/check_staged.sh:203–267, frozen 080/4 инвариант 18: наличие любого user.name/user.email в общем config (даже пустого) даёт rc 1 независимо от effective identity. Обход через -c identity не исправляет причину. Предмет сохраняет этот запрет: перед project-минтом удаляет только запрещённые локальные ключи, а не отключает проверку. Чужой/пустой config проходит именно после нормализации, не в загрязнённом состоянии.
- frozen 068/1 (`cc4904ccf22fecd62e23d4f1827977fdf0fd0e84`) инварианты 3–7: провенанс тега, повтор, main, чистота, штатный hook и точечный откат. frozen 031/4 (`dc550fdaaeb1bfa9733a90a9da97f2f75948f0ed`) сохраняет дверь ADD; 221 не меняет её и не расширяет права на реестр. Единственная project-дельта к 068 — источник обязательного хука и нормализация file-identity; станционный маршрут остаётся прежним.
- scripts/next_id.sh:333–450 — единый project_paths_resolve, без профиля корневая раскладка, с профилем workflowPaths из profile_resolver, без своего JSON-разбора. scripts/mint_line.sh:190–201 УЖЕ пишет в профильный реестр. scripts/reserve_project_contract.sh:54–75,94–151 валидирует профиль, выдаёт/публикует annotated id-тег на origin проекта через gitw и сверяет tag-object; строку не минтит, хуков не устанавливает.
- scripts/connect_project.sh:203–244 создаёт профиль/слой и использует тот же резолвер; установки pre-commit/core.hooksPath там нет. 125/996/992 дают проектный контекст и fail-closed, 140 ограничивает место исполнения; это не установщики хука для disposable клона.
- scripts/accept_task_commit.sh:218–225 использует адресную identity при cherry-pick; scripts/push_product.sh:91–96 требует профиль и публикует продуктовый маршрут, но не создаёт mint-коммит. Ни один не заменяет 068/031. scripts/lib_zones.sh — единый читатель frozen-зон, не второй судья минта.
- `fixtures/mint_line/red_mint_line_068.sh` — прежние реальные Git-миры станции; семейства workshop_project 207/208/211/212 — прецеденты model/stabs/source.json/SDACHA. Семья 221 использует настоящий git и настоящий check_staged из дерева, а не двойник судьи.

## Frontier и выбор

Выбран А: только project-вызов mint_line создаёт одноразовый исполняемый pre-commit, вызывающий sibling `scripts/check_staged.sh` установки инструментов с явным корнем проекта; назначает его process-local git-конфигом (без постоянного изменения core.hooksPath), удаляет временный каталог на выходе. Сохраняет существующую явную env-identity orchestrator. После чистого main/git/profile-префлайта нормализует запрещённые локальные user.name и user.email штатным git config --local --unset-all: отсутствие ключа — допустимо, иная ошибка удаления — именованный rc 1 без минта. Это необходимая часть identity-боли, а не ослабление 080. Нормализация постоянна и не восстанавливает запрещённую identity после коммита; другие ключи и установленные хуки не меняются. Она может сохраниться при последующем отказе провенанса/хука; атомарность реестра от этого не меняется.

Отклонено Б — установка хука/connect_project: одноразовые клоны не проходят connect_project повторно, появится постоянный версионный дрейф и изменение чужой конфигурации установки вместо локальной операции минта.
Отклонено В — только -c user.name/email или env: env уже есть, а 080 читает непосредственно файл; это не устраняет отказ. Выключение 080 или чтение identity из file-config — отклонено как ослабление frozen-защиты.
Отклонено Г — временно скрывать и затем восстанавливать запрещённые ключи: возвращает нарушение 080 и добавляет гонку восстановления общего config. Нормализация удаляет причину, а не прячет её от судьи.

## Предмет и порядок

Один результат: `bash scripts/mint_line.sh --nnn N --root R` в чистом main-клоне проекта без установленного хука создаёт один registry-only коммит под orchestrator сквозь живую дверь 031 без ручного hooksPath. Architect сдаёт эту страницу, red-батарею, честную модель, адресные стабы и лист. Implementer после заморозки меняет только mint_line. Orchestrator подключает семейство к CI: до реализации --model/--stabs/--sintaksis, после — --repo . / --stabs / --sintaksis; суд реализации adversary → reviewer. Публикация результата по-прежнему отдельным gitw/push_product, не предметом mint_line.

## Инварианты

1. Признак project-маршрута — harness.project.json в R; путь реестра и валидация профиля — существующий project_paths_resolve. Никаких новых CLI-флагов, собственного резолвера или нового механизма тега/реестра. Номера и строка — прежняя грамматика 068/031: 1–3 ASCII-цифры → NNN, `NNN → <40 lowercase hex>` с U+2192 и sha annotated tag-object.
2. Project-хук обязателен для самого commit, независимо от отсутствующего .git/hooks/pre-commit или core.hooksPath=/dev/null в клоне; он исполняет живой check_staged установки инструментов на R. Не допускаются --no-verify, подавление rc судьи, пустой хук или вывод вместо исполнения. Постоянные core.hooksPath и файлы имеющихся хуков не меняются; одноразовый хук удаляется на выходе.
3. После project-префлайта удаляются ВСЕ локальные user.name/email, включая пустые и многозначные. Остальная конфигурация сохраняет ключи/значения. Commit сохраняет существующие явные author=committer=orchestrator и email orchestrator@dev-harness.local, невзирая на чужие GIT_* вызывающего. Сам check_staged и его безусловный запрет загрязнения не меняются. Неудавшееся удаление не разрешает commit.
4. Успех — rc 0, один новый прямой main-коммит и только профильный contracts.tsv; байты реестра — исходные плюс одна точная строка с tag-object, индекс/дерево чисты. Stdout ровно `MINTED nnn=<NNN> sha=<tag-object> commit=<HEAD>\n`; stderr — реальный вывод двери, включая judged-строку по профильному пути. Теги/origin не изменяются, push не происходит.
5. Если check_staged отказывает, mint_line возвращает rc 1 с причиной двери, восстанавливает только путь реестра из HEAD; HEAD, staged, рабочий реестр прежние. Повтор в HEAD — прежний ранний rc 1 «повторный минт». Не-репозиторий — rc 2 NOT_IMPLEMENTED; неизвестный --no-verify — прежний rc 1 с именем неизвестного аргумента и usage. Проверки тега/сети/main/чистоты 068 не удаляются.
6. Без профиля всё поведение 068/031 прежнее: полные stdout/stderr bytes, rc, HEAD/registry/index и config/хуки равны сохранённому станционному канону на том же Git-мире. Нет project-нормализации/автохука в station-ветви. Байт-паритет — поведенческий, не требование одинакового текста scripts/mint_line.sh.

## Приёмка

Публичный шов согласован заданием: CLI mint_line и наблюдаемые Git-эффекты. Ожидания/носители/пред-состояние читаются в память до субъекта. Реестр после вызова — наблюдение, не источник ожиданий; HEAD и созданный commit проверяются plumbing отдельно от текста stdout. Носители source.json проверяются sha256. Реестр связей стабов — build.py → source.json, не пары в прозе контракта.

- Дано до-предметное дерево; когда `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo .`; тогда rc 1 с именованными красными project-клетками отсутствующего штатного прохода. Дано реализация; та же команда — rc 0, не менее 16 клеток, красных 0.
- Правило честного контроля; `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --model` — rc 0. Миры: нет хука; чужие, пустые, email-only и многозначные file-ключи, иные [user]-ключи вне запрещённых на корневой раскладке; чужая env-identity; отключённый hooksPath; настоящий отказ двери; повтор; неизвестный --no-verify; не-репозиторий. После каждого project-вызова, успешного и отказного, остатка одноразового хука нет; иные ключи конфигурации сохранены с теми же значениями, а в мире с иными [user]-ключами сам .git/config отличается от исходного только удалёнными user.name/user.email. Station-миры — проход через хук, отсутствующий хук, чужой config, повтор, отказ живой двери — сравниваются побайтно с каноном базы.
- Правило различимости; `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --stabs` — rc 0, честный контроль зелён, не менее 11 копий и 14 адресных предъявлений, ZHIVYH 0. Каждая связь исполнена отдельно, не суммарный зачёт стаба по другой связи. Негодный синтаксис/носитель — rc 2, не пойманная обманка.
- Правило формы; `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --sintaksis` — rc 0: bash -n всех shell-носителей, пинованный validate_std bash на модели и обёртке, Python compile пробы/генератора. Нет инструмента/пина — rc 2.
- Правило допуска; `bash scripts/pre_critic.sh contracts/221-mint-line-proekt.md` и `bash scripts/check_sdacha.sh . contracts/221-mint-line-proekt.md --run` — rc 0. Отсутствие строки плана 221 в данной базе — внешняя owner-PR #1350 предпосылка, не право architect менять plan.tsv.
- Правило проводки done; `bash scripts/check_provodka.sh . contracts/221-mint-line-proekt.md` и `bash scripts/gen_ci_steps.sh --check` — rc 0 после подключения своей батареи orchestrator.

Конформные миры — доступные Git-репозитории с main, корректным профилем/слоем 996 и существующими workflow-каталогами, annotated id-тегом и local bare-origin. Контрпример валиден на объявленном шве при инвариантности к номеру, sha и пути; отсутствие/неконформность CLI предъявляются отдельными отказными сценариями. Проектные корректные раскладки корневая, .harness и .workflow/book остаются зелёными. Нет требования зелёного --repo до реализации.

## Модель угроз

ЗАЩИЩАЕТ:
- От необходимости устанавливать клоновый hook вручную для этой операции, зависимости commit-identity от чужого контекста и обхода живого rc страже: собственный временный хук, нормализация запрещённого file-config и явная identity; настоящий Git-коммит, наблюдение обеих труб и эффекта.
- От распространения project-изменения на станцию и тихого успеха после отказа двери: дифференциальный станционный канон и точечный откат реестра.

НЕ ЗАЩИЩАЕТ:
- От компрометации установки инструментов, PATH/git, single-uid identity-forgery или авторитета: прежние 016/023/031 границы; ловцы — изоляция станции, CI и reviewer. Ручной git commit --no-verify вне mint_line — прежний остаток 068, CI check:zones.
- От независимого дефекта профильного пути внутри самой 031: check_staged.sh:780/793 читает HEAD/origin registry/contracts.tsv литерально даже при ином workflowPaths.registry. В живой пробе remote-only повтор с .harness-реестром был ошибочно пропущен самим судьёй; это не скрывается как закрытый 221 отказ. Клетка отказа использует конформный project с корневым registry, где судья реально красен. Исправление пути — отдельный предмет оркестратору, не расширение 221; ловец — адресная remote-only project-проба следующего предмета.
- От конкурентной записи в общий git-config при нормализации или недоступности FS/сети: новых транзакций/замков 221 не вводит; запрет 080 остаётся живым ловцом повторного загрязнения до коммита, операционные сбои — именованный отказ, повтор оркестратором после устранения причины.
- От остатка собственного скратча живой двери: check_staged/lib_zones оставляет lib_zones.<hash>.* (каталог и маркер .active) в TMPDIR после каждого вызова двери, включая честную модель; это дефект станционного инструмента, не одноразового хука 221, и клетка остатка хука именно эти имена не судит. Ловец — адресная проба lib_zones отдельным предметом оркестратору.

## Зоны и проводка

ЗОНА architect: contracts/221-mint-line-proekt.md fixtures/workshop_project/mint_line_proekt_221/
ЗОНА implementer: scripts/mint_line.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/mint_line.sh — 068 architect-зона по frozen/contracts/068/1: только project-ветвь временного хука и нормализация file-identity, станционный канон/068 атомарность и провенанс сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 свой шаг 221.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 свой замер 221.

031/4 не владеет mint_line; check_staged и прочие его implementer-пути не раздаются 221. 080/4 не изменяется: судья по-прежнему отвергает ПРИСУТСТВУЮЩИЕ ключи. Пересечения CI скопированы по существующему прецеденту 212 и проверяются precision-гейтом; чужие шаги не меняются.

ПРЕДПОСЫЛКИ:
- setting Существующие git/bash/python3/jq, пин shellcheck и установка инструментов с sibling check_staged; новых secrets/variables/environments нет.
- setting Строку плана 221 добавляет owner-PR #1350; CI-шаг и замер подключает orchestrator.

ПРОВОДКА:
- guard=fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh

ПРОВОДКА-ЭНФОРСМЕНТ: механическое изменение клиента существующей двери, новой поведенческой нормы роли нет. CI-шаг check:mint-line-proekt-221-family-selftest включает указанные режимы батареи; провенанс и права по-прежнему судит настоящая дверь 031 каждого commit. Установщики/роли не правятся.
СДАЧА: fixtures/workshop_project/mint_line_proekt_221/SDACHA.md

## Незаполненные требования:
нет
