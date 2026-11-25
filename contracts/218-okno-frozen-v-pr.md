# Контракт 218 — окно PR-проверок заморозки и устава

КЛАСС ЗАДАЧИ: кодовый — контракт и красная батарея; production пишет implementer после заморозки.
КЛАСС РИСКА: рисковый — авторизация/безопасность: сужение суда frozen-контрактов и устава не вправе амнистировать собственную правку; adversary → reviewer.
ПРОДУКТ: станция
АРХИТЕКТУРА: не применимо — ремонт станционного guard, продуктовой модели 188 нет.
КОНТЕКСТ: слово владельца 23.11 (~22:30 UTC), дословно: «083 и окно check_charter в PR: поднимаю приоритет — как блокеры старого (206, 148): станция берёт «--incr при пустом окне без полного прохода» и «окно check_charter/contract-frozen в PR» следующими после текущих предметов».
КОНТЕКСТ: owner-затравка 218 и task-architect218.md; номер id/CONTRACT/218 и registry/contracts.tsv уже существуют. SourceCanon не объявлен. R-0102: «хардкодить ничего не надо, все надо выносить в конфиги»; размеры миров/сроки проб — source.json, не производственные ограничения окна.
СДАЧА: fixtures/workshop_project/okno_frozen_v_pr_218/SDACHA.md

## Боль и предмет

Измерения затравки: #1284 цепляет merge-коммиты main через first-parent окно frozen/148/5..HEAD; #1306 снят до влива 205 и после publish frozen/205/1 судится за старый черновик 205. Цена 23.11 — ≈15 пересборок носителей и ≈10 повторных CI за сутки. Owner-PR 24.11: 15 закрытых при 5 влитых; update-branch принёс неразрешённые уставные коммиты main и чужой check:charter краснит PR. Это факты переданного замера, не повторно выполненный сбор статистики.

Один результат: check_contract_frozen и check_charter в pull_request судят собственную историю PR относительно main, а не незатронутые frozen-пути старой базы или внесённые main-коммиты. Наблюдаются rc/причина настоящего CLI, неизменность HEAD/индекса/кеша и реальная Git Trace2 зависимость обхода от собственного окна. За пределами PR прежние полные потоки, решения и incr-семантика сохраняются.

## Существующее

База пачки main a32c577f292a2e925417d78a85cdb00abf25fae3. Дерево уже содержит реализации 210 и 217, несмотря на старое HANDOFF, где 210 ещё ждёт ленда. Прочитаны действующие scripts/check_contract_frozen.sh, scripts/check_charter.sh, scripts/lib_incr.sh, окно scripts/check_zones.sh и проводка legkij в .github/workflows/ci.yml.

- check_contract_frozen сравнивает каждый HEAD-план/контракт с высшим frozen и проверяет все версии/accept. При расхождении работает прежняя конъюнкция предстоящего v+1: accept следующей версии, разрешение каждого носителя текста, равенство локальному hold либо консистентность CI-дельты. 200/1 (97eb6ed852f408136e95c6a7929ae9c28567dfb1) уже убирает merge с пустым p1-diff, но НЕ отделяет main от PR. Это механизм для повторного использования, не замена его правил.
- check_charter уже экспортирует is_charter_path, charter_diff_paths, razreshil и charter_frozen_publication. 210/1 (95aeaf386ec9b28022139d4f2ca893526cac4a25) удостоверяет публикацию frozen через настоящий origin; NUL-транспорт имён, грамматика разрешений и grandfather-пары сохраняются. Библиотечный CHARTER_LIB не должен запускать PR-CLI.
- lib_incr — единственная грамматика/писатель кеша 083/3 (70f8011dee645a86512448eabd8d2589cd5712ae). 217/2 (71a4796f83236014d2261dce93bbdcb5967be018) ускоряет валидное base=HEAD до разведки. PR нельзя принимать по восстановленному кешу HEAD: иначе собственное непроверенное изменение исчезнет. Вне PR 083/217 не меняются.
- 207/1 (f3693b9d9e59ad1bbabb17ae1b36bd85d26446d7) — прецедент одного суда данных окна, а НЕ готовый PR-селектор: его окно — кеш..HEAD. Его execve-нормализатор не копируется; здесь стандартный Trace2 плюс поведенческие Git-миры.
- 195/1 (464e9e4d8514dc50626c531d37b68049b812da51) атрибутирует писателей по frozen-зонам, не устанавливает границу PR. 071/2 (063ee7e2ef9c1fcdb3c0402cbe14fa85365b0f2f) охраняет отправку main; предполёт и доказанный код-хеш Д4 этим контрактом не меняются. 992/2 (aff50503e90a44bcd308e357595da1f1e07fde86) запрещает превращать непрочитанную область/историю/дельту в чистое окно.
- legkij уже делает checkout именно github.event.pull_request.head.sha || github.sha, fetch-depth: 0 и fetch-tags: true. Проверки вызываются через run_ci_lane и registry/ci-steps.tsv: check:charter с --incr, check:contract-frozen, check:nabludenia; менять nabludenia/остальные incr-проверки не требуется. Новый PR-режим выбирается событием и явным аргументом, не именем wip.
- gh pr list --repo a3ka/dev-harness при старте: #1407, #1314, #1302, #1284, #1227, #797; готового исправления 218 нет. #1284 — носитель измеренной боли, #1302 — state/диагноз, остальные про другие предметы; переиспользовать как реализацию PR-окна нельзя. Локальные wip 200/207/195/210 — прежние механизмы; только wip/218/architect относится к этой пачке. Н-191 описывает ложный sync-merge charter-FAIL, Н-213 — судьбу incr-кеша, Н-448 — каскад красного main на остальные PR. Современные замеры из затравки не выдаются за отсутствующие записи main-журнала.
- Каркас новой семьи повторяет probe.py/model/stabs/SDACHA/source.json соседей 217 и 200, а не создаёт второй производственный guard. context.py читает высшие живые frozen-блобы через git show и печатает реальные зоны; 195/207 пересекаются только CI-проводкой, 071 — workflow. Производственные check_consumers/check_zones/gitw/pre-push не входят в реализацию 218.

## Frontier

1. first-parent от frozen/кеша или отказ от всех merge: отвергнуто. Первое сохраняет #1284 и суд main, второе пропускает evil merge и собственную боковую ветку; rebase/owner/* не решаются именем ветки.
2. Только net-diff merge-base..HEAD: отвергнуто. Собственная правка с последующим revert либо изменение до update-branch исчезает из финальной дельты; обычный merge-base..HEAD включает и main-предков, внесённых синхронизацией.
3. Выбрано: зафиксировать настоящий PR HEAD и удостоверенный origin/main; судимое множество = ancestors(HEAD) минус ancestors(main). Merge-base — единственное доказанное общее основание, не заменяемое пользовательским SHA; множественный merge-base и неизвестность дают отказ. Новая дельта merge — пути, результат которых отличается от КАЖДОГО родителя (Git combined diff); внесённое исключительно main не является новой правкой PR, а все не-main боковые коммиты всё равно остаются в множестве. Это закрывает измеренные миры без переписывания 200/210 и без отказа от суда собственных коммитов.

## Инварианты

И1. Оба CLI принимают --pr и выбирают тот же режим при GITHUB_EVENT_NAME=pull_request. Имя owner/*, wip/* или detached HEAD не меняет решения. Push/локальный вызов без --pr сохраняют прежний режим, включая --oracle/--incr и CHARTER_LIB. CI передаёт доверенное событие; HEAD — head PR, не синтетический merge-ref.

И2. До сужения однократно фиксируются HEAD, refs/remotes/origin/main и единственная merge-base. Origin/main должен буквально совпадать SHA с refs/heads/main живого настроенного origin (ls-remote); произвольного аргумента --base нет. Shallow — rc 1 PR_WINDOW_SHALLOW; отсутствующий origin/main — PR_WINDOW_BASE_MISSING; несоответствие живому origin — PR_WINDOW_BASE_UNTRUSTED; недоступный origin — PR_WINDOW_ORIGIN_UNAVAILABLE; несвязанность/неоднозначность — PR_WINDOW_BASE_UNRELATED/PR_WINDOW_BASE_AMBIGUOUS. Ошибки чтения истории/дельты/области — именованный отказ rc 1, никогда пустое зелёное. Подмена самого настроенного origin вне доверенной CI-среды не удостоверяется этой проверкой.

И3. История PR = все достижимые из зафиксированного HEAD коммиты, недостижимые из main, включая не-main боковые коммиты. Это не first-parent и не список только последних коммитов. Обычный коммит сравнивается с его родителем; новый эффект merge — combined-дельта ко всем родителям. Own evil merge судится; импорт main не судится как собственная правка. Собственное нарушение до update-branch и собственная правка с revert не амнистируются. Вне PR первый-родитель суд 019/200 сохраняется.

И4. Frozen-область PR — затронутые собственной историей plans/contracts, артефакты затронутых critic-вердиктов и заморозок, чей коммит-основание сам принадлежит собственному окну. Нетронутый старый черновик на отстающей ветке не сверяется с поздним тегом соседнего main. Собственная правка frozen без новой заморозки/действующего предстоящего v+1 — rc 1 с прежней причиной; все версии, аннотированность, accept, hold/CI-консистентность и разрешения в собственной области сохраняются. Носители предстоящего v+1 выбираются из собственного окна, не из импортированной main-истории. Собственная правка/удаление не исчезает из области только из-за отсутствия пути на HEAD.

И5. Устав судится теми же библиотечными предикатами, с прежней per-document первой заморозкой и разрешением того же коммита. Owner-PR + update-branch поверх main с неразрешённым уставным коммитом — rc 0, если собственных нарушений нет. Та же ветка с собственной правкой устава без РАЗРЕШИЛ — rc 1 «без разрешения владельца»; парная разрешённая собственная правка — rc 0. Наличие разрешения на одном пути не оправдывает другой. Освобождение 210 не расширяется и не заменяется всеобщей merge-амнистией.

И6. Влив соседнего PR/публикация его тега не краснит прежний HEAD второго PR, если второй не менял соответствующий артефакт; пересборка второго не требуется для этих двух проверок. Без frozen-правок суд зависит от собственных коммитов/их дельты, а не от числа исторических main-коммитов: O(коммитов ветки) по предметному обходу. Метаданные реестра/проверка предковости — отдельная необходимая разведка, не повторный суд истории. Неограниченный git log/rev-list истории для PR запрещён. Параметризованные размеры миров/срок пробы читаются из source.json; производственного лимита окна нет.

И7. PR проверяет всё собственное окно независимо от восстановленного --incr-кеша, в том числе cache=HEAD; PR не продвигает и не перезаписывает этот кеш как доказательство полного исторического суда. Fast/oracle в PR дают одинаковые решения. Вне PR пустое окно 217, full-fallback 083, кеш/маркеры/потоки остаются прежними. Проверка не меняет HEAD, индекс и отслеживаемые файлы. PR stderr несёт самостоятельную строку `pr: <имя-чека> main=<SHA> base=<SHA> head=<SHA>`; stdout пуст. Это свидетельство выбора режима, не самостоятельный оракул границы.

## Батарея и демаркация

W = `bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh`. Настоящие Git-миры строятся commit-tree/read-tree/update-index, с отдельным bare origin и настоящим ls-remote. Два состояния соседнего PR сохраняют тот же HEAD; owner update-branch — настоящий двухродительский DAG. SHA, индексы/кеш и ожидания снимаются в память до субъекта. --repo не патчит выбранный production. --model — вставки только в отдельные копии pinned-базы, не предписание перенести старые файлы поверх актуальных production.

Конформный вход — обычный Git-репозиторий с реальными frozen/ustav, PR-head, поддержанными путями и единственной общей базой с настроенным origin/main; отсутствие/подмена основы, shallow и нарушения — явно отказные входы. Значения номеров, SHA и содержимого не меняют критерий; альтернативный номер проверяется отдельно. Валидный контрпример = инвариантность к значениям и расхождение на конформном входе, не сломанный инструмент. Батарея не читает ожидания с диска субъекта после его вызова. Для non-PR полный rc/stdout/stderr сравниваются с pinned production, выполненным до субъекта на том же мире.

Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Единственный исполняемый реестр привязок — stabs/*.json; census source.json сверяется с кодом. Каждый адрес предъявляется отдельно после своего честного контроля. Ошибка инструмента/якоря/синтаксиса/таймаут — rc 2 NOT_IMPLEMENTED, не поимка. Отсутствующий --pr в до-реализационной двери — именованный красный PR_INTERFACE_ABSENT, не ошибка мира.

## Приёмочный критерий

- Дано production до реализации; когда `W --repo .`; тогда rc 1 с именованными красными; исторический список — SDACHA. После реализации та же команда — rc 0, KRASNYE=0. Отказные subject-rc 1 являются зелёной клеткой лишь при своей причине и сохранении состояния.
- Дано reference-кандидат; когда `W --model`; тогда rc 0, все клетки каталога зелёные. Поздний тег противопоставлен собственной frozen-правке; импорт main — собственному evil merge/боковой правке/revert; отсутствие основы — полноценному origin; разрешение — отказу без него; PR cache=HEAD — сохранённому non-PR пустому окну.
- Правило различимости; `W --stabs` — rc 0, ZHIVYH=0 и непустые STABY/SVJAZI; все предъявления выполняются отдельно. `W --sintaksis` и `W --catalog` — каждый rc 0. Bash проверяется bash -n и пинованным shellcheck через validate_std, Python — compile без pycache; факты DAG/блобов — настоящим Git, Trace2 — стандартным JSON.
- Правило допуска; `bash scripts/pre_critic.sh contracts/218-okno-frozen-v-pr.md` и `bash scripts/check_sdacha.sh . contracts/218-okno-frozen-v-pr.md --run` — каждый rc 0. `python3 fixtures/workshop_project/okno_frozen_v_pr_218/context.py` — rc 0 и непустые frozen-зоны; только origin в чистом клоне, pinned-база — предок кандидата.
- Правило регресса после реализации, без переписывания соседних клеток: `bash fixtures/workshop_project/okno_zamorozki_200/red_okno_zamorozki_200.sh --repo .`; `bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --repo .`; `bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo .`; `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo .`; `bash scripts/verify_antiplacebo.sh --scope check_charter`; `python3 fixtures/freeze_contract/fail_closed_992.py` — каждый rc 0. `bash fixtures/_krasnye_083.sh` — прежняя приёмка 217: НЕ ХУЖЕ БАЗЫ (множество красных не расширяется; И0/check_charter и И0б/check_charter зелёные), таймауты не поднимать. Эти non-PR прогоны идут без PR-event; новые PR-клетки их не заменяют.
- Правило проводки; orchestrator подключает только свой self-test 218 и замер, сохраняет head-PR checkout/event и push-режим существующих проверок; `bash scripts/gen_ci_steps.sh --write`, `bash scripts/gen_ci_steps.sh --check` — rc 0. До done `bash scripts/check_provodka.sh . contracts/218-okno-frozen-v-pr.md` — rc 0 после подключения; до него grammar/pre_critic зелёные, отсутствие CI-строки не выдаётся за done.

## Не входит

Перестройка rebuild/ленд-поездов и Д4 (код-хеш merge-результата после соседнего ленда), локальный pre-push при копировании уже влитого frozen-текста, изменение запрета merge main→wip 167, окно других чеков/проектов, ускорение полного прохода/раннеров, изменение frozen-текстов 200/207/195/083/210/217/992/071 и ручные grandfather-пары. Эти соседние причины пересборок не выдаются за закрытые 218: ловцы существующие 071/210/Д4 и отдельный маршрут по измеренной боли.

## Модель угроз

ЗАЩИЩАЕТ:
- От суда чужого main и поздних тегов на PR: настоящие отстающие/синхронизированные DAG и scope затронутости, парный влив соседа без смены PR-head.
- От амнистии собственной истории: собственные frozen/уставные правки, revert, боковой коммит и evil merge остаются в суде; кеш HEAD не является основанием сужения.
- От ложной чистоты при неизвестной/подменённой основе: live origin, локальный main-ref, shallow и предковость проверяются до обхода; именованные отказы не заменяются нулём.

НЕ ЗАЩИЩАЕТ:
- От подмены настроенного origin/CI-event/PATH, сговора при общем uid или распознавания фикстуры: доверенная среда прежняя; ловцы существующие CI/изоляция и независимые adversary/reviewer.
- От доказательства универсальной асимптотики произвольного кода: Trace2 видит доверенные Git-процессы, не ручное чтение objects/libgit2; И6 сохраняется, ловец reviewer алгоритма и adversary реализации.
- От независимых дефектов публикации, main-предполёта и Д4: ловцы прежние семьи 200/210/217/083/992/071 и интеграционный reviewer. Reference не разрешает откат новых механизмов актуального production.

## Зоны и порядок

ЗОНА architect: contracts/218-okno-frozen-v-pr.md fixtures/workshop_project/okno_frozen_v_pr_218/
ЗОНА implementer: scripts/check_contract_frozen.sh scripts/check_charter.sh scripts/lib_incr.sh scripts/lib_pr_window.sh
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Сверка высших frozen-блобов — context.py; ниже чужие авторы union и пересечения названных предшественников. Общая дельта CI — только свой шаг/event/замер 218; чужие шаги сохраняются.

ПЕРЕСЕЧЕНИЕ architect: contracts/218-okno-frozen-v-pr.md — 993 только станционный контракт 218
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/okno_frozen_v_pr_218/ — 054 только новая семья 218
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/okno_frozen_v_pr_218/ — 055 только новая семья 218
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_contract_frozen.sh — 200 только PR-отбор; non-PR окно и условия v+1 сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 065 только PR-окно; грамматика и grandfather-пары сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 083 только PR-окно; non-PR кеш/маркер прежние
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 210 только PR-окно; публикационный предикат и NUL сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 217 только PR-окно; non-PR пустой выход прежний
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 992 ошибки не превращаются в чистое окно
ПЕРЕСЕЧЕНИЕ implementer: scripts/lib_incr.sh — 083 только разделение PR/full; без необходимости библиотеку не менять
ПЕРЕСЕЧЕНИЕ implementer: scripts/lib_incr.sh — 217 non-PR пустой выход прежний
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только своя CI-дельта 218; предполёт main не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 195 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 200 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 207 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 210 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 217 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только своя CI-дельта 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 195 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 200 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 207 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 210 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 217 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только свой self-test 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только свой замер 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 195 только свой замер 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 200 только свой замер 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 207 только свой замер 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 210 только свой замер 218
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 217 только свой замер 218

195/207 не владеют production-файлами 218, 071 владеет workflow, 992 — check_charter; подтверждает context.py. scripts/lib_pr_window.sh — единственный новый production-путь. Model остаётся reference. Architect не пишет production/CI/реестры.

РАБОТА РАЗДАЁТСЯ: implementer
Порядок: architect → critic → freeze → implementer → orchestrator (CI) → adversary → reviewer → land/done. Reference не предписание переносить старый production побайтно.

ПРЕДПОСЫЛКИ:
- setting Git с Trace2/combined diff, bash, Python 3, штатные утилиты production и пинованный shellcheck через VALIDATE_STD_SHELLCHECK; scratch/TMPDIR внутри собственной копии.
- setting CI checkout PR-head, полная история/теги и доступный origin/main; новых secrets, variables, environments и внешних сервисов нет.

ПРОВОДКА:
- guard=fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh

ПРОВОДКА-ЭНФОРСМЕНТ: чистый ремонт области существующих стражей, новой нормы роли нет. Orchestrator подключает свой self-test/замер: до реализации --model/--stabs/--sintaksis, после также --repo .; полный done-гейт — после CI-подключения.

## Незаполненные требования:
нет
