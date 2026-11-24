# Контракт 217 — пустое окно `check_charter.sh --incr` завершается за O(1), v2

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: рисковый — безопасность стража устава: ускорение не вправе амнистировать непроверенную историю; реализация проходит adversary → reviewer.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — ремонт существующего станционного guard, проектной модели 188 нет.
КОНТЕКСТ: слово владельца 23.11 ~22:30 «таймаут не поднимать» и owner-затравка 217; номер выдан id/CONTRACT/217, строка registry/plan.tsv уже существует. Этот текст заменяет затравку, заморозку выполняет orchestrator после critic.
КОНТЕКСТ: contracts/210-charter-tekst-do-tega.md — обязательная предшествующая реализация; перед работой implementer читать её высший frozen-блоб и уже влитый scripts/check_charter.sh.
СДАЧА: fixtures/workshop_project/incr_pustoe_okno_217/SDACHA.md

## Боль и обещание

По измерению станции 23.11 клетка 083 И0/check_charter занимает 56–60 с из неизменяемых 60 с: #1296/#1314/#1322 краснеют в obshchij, диагностика стоила ≈3 ч. Маркер режима уже печатается: причина не в распознавании --incr, а в последующей разведке всех документов и истории. Затравка фиксирует 188–189 документов и git log по старым frozen-тегам. Таймаут не поднимать и клетку 083 не переписывать.

Один результат: валидное пустое incr-окно завершается до построения области устава, без обхода документов/тегов/истории. Наблюдения: точные байты маркера, rc 0, кеш HEAD, отсутствие предметной разведки в настоящем Git Trace2 и ≤2 с в истории 5000 коммитов и на реальной истории станции (при авторской пробе 9034 коммита). Непустое окно, разрешения, сообщения и счётчики сохраняются. Затронуты 083 (общая грамматика/кеш), 113 (fast/oracle), 019/022/046/065/992 (суд и fail-closed); обязательства не ослабляются.

## Существующее

База авторской пачки — main `4576309b967a22818cd7c2ed0738333dd014ca80`. Поиск выполнен по contracts/, registry/plan.tsv, scripts/, fixtures/, локальным wip и GitHub PR; `W --context` воспроизводит canonical zones_load и чтение `git show frozen/contracts/<NNN>/<vmax>^{commit}:<путь>`.

- scripts/lib_incr.sh (083/3, commit 70f8011dee645a86512448eabd8d2589cd5712ae) уже валидирует базу, различает incr/full, печатает маркер с короткими SHA и пишет зафиксированный INCR_HEAD через incr_finish. Собственный формат кеша/его писатель не нужен. Кеш отсутствует — полный прогон; неизвестный объект и существующий не-предок — полный прогон с именованным маркером; мусорная/пустая строка — именованный rc 1.
- scripts/check_charter.sh вызывает incr_parse, но после него строит пары документов, читает ls-tree, теги, per-document since и общий git log даже при base=HEAD. Ранний выход нужен перед этой разведкой; переносить/дублировать razreshil и is_charter_path не нужно. CHARTER_LIB остаётся библиотечным возвратом до CLI, .githooks/pre-push импортирует то же кольцо.
- 113/1 (45c541701e6091c2f4a25d506daef5bb98558989) уже несёт fast и oracle и семью fixtures/charter_fast_113/. Ускорение полного режима не входит; непустая incr-ветвь сохраняет per-document since и прежний полный выход. 992/2 (aff50503e90a44bcd308e357595da1f1e07fde86) защищает ошибки чтения области/истории/дельты: не подменять их нулём.
- 207/1 (f3693b9d9e59ad1bbabb17ae1b36bd85d26446d7) — прецедент ускорения incr без изменения полного режима. Его сложный execve-нормализатор для четырёх видов суда здесь не копируется: пустой путь проверяется стандартным Git Trace2 JSON плюс секундным пределом. 200/1 (97eb6ed852f408136e95c6a7929ae9c28567dfb1) ремонтирует другое окно, check_contract_frozen: его код не подходит и не меняется.
- 210 — НЕ завершённый носитель: живой PR #1327 OPEN, head wip/210/orchestrator-r11 `569206545b5679cec61e7d86625e3bf1921aa83f`; он меняет check_charter (NUL-транспорт путей, charter_diff_paths, fast/oracle), pre-push и свою батарею. Высший frozen/210/1 = 95aeaf386ec9b28022139d4f2ca893526cac4a25, зона implementer: scripts/check_charter.sh .githooks/pre-push. Реализация 217 — ТОЛЬКО ПОСЛЕ влива 210, добавлением ранней ветви, без отката его механизма. Батарея 217 не переносит старое тело в production: модель — короткая вставка; фиксированная до-217 дверь служит только оракулом на линейных мирах без публикации frozen-текста.
- fixtures/ci_gen_083/red_ci_a_083.sh:1496–1505 уже требует rc 0, маркер `(0 коммитов)` и кеш HEAD под timeout 60; остаётся побайтово прежней. Носителя 217 среди открытых PR при сверке нет; wip/217/architect — только эта пачка.
- Семья fixtures/workshop_project/charter_tekst_do_tega_210/ даёт используемый интерфейс red_*.sh/probe.py/model/stabs.tsv/SDACHA. Сверка union также обнаружила широкие префиксы fixtures/workshop_project/ (054/055/105) и contracts/ (993): новый подкаталог и только контракт 217 не меняют их прежние семьи.

## Решение

Выбрано сравнение валидированных INCR_BASE и INCR_HEAD, а не доверие одному INCR_N=0: пустое множество коммитов при доказанной предковости эквивалентно равенству двух коммитов. Ошибка счётчика или full-режим с начальным N=0 не являются пустым окном. Источники base/head и маркер остаются lib_incr, не читаются повторно.

Выбрано существующее поведение неизвестного кеша 083: полный прогон для отсутствующего/неизвестного/стороннего SHA, именованный отказ для повреждённой строки. Новый отказ вместо полного прогона сломал бы 083; новая аутентификация кеша — другой предмет. Ветка допуска требует одновременно INCR_MODE=incr и base=head после успешного incr_parse.

Альтернативы отвергнуты: поднять timeout запрещено владельцем; выйти по одному N=0 амнистирует full; оставить цикл и лишь урезать git log не убирает зависимость от числа документов. Достаточна ранняя ветвь с incr_finish 0 и exit 0. lib_incr заявлена в зоне для совместимости, но без необходимости не меняется.

## Инварианты

- И1. Успешно разобранный --incr с базой-предком, равной зафиксированному HEAD, немедленно вызывает существующий атомарный писатель incr_finish 0 и возвращает rc 0 до перечисления документов и тегов и до git log. stdout пуст; stderr ровно `incr: check_charter судит <base:8>..<head:8> (0 коммитов)` + LF. Это прежний маркер 083, не новый текст. Писатель нормализует кеш до ровно `<полный HEAD>\n` без повторного чтения HEAD: как из HEAD с LF, так и из принимаемого lib_incr HEAD без LF. Наблюдается cache_bytes, не mtime/inode. Строгий предок HEAD означает непустое окно и остаётся в И3.
- И2. Пустой путь O(1) по числу исторических коммитов и уставных документов; замер CLI, без конструирования мира, ≤2 с. На пустом пути нет git ls-tree/log/for-each-ref; число вызовов Git не растёт при переходе от маленькой истории к 5000 коммитам. Сами проверки валидности кеша сохраняются. Формы --incr FILE, --incr=FILE и --oracle --incr FILE имеют тот же пустой исход.
- И3. При base≠head incr не пропускает суд: правка устава без РАЗРЕШИЛ даёт rc 1 и прежний диагноз; с разрешением — rc 0. Судится ровно окно, для поздно замороженного документа since остаётся первой заморозкой, черновые изменения не становятся нарушением. Полные stdout/stderr, счётчики и порядок строк непустой ветви — прежние. При rc 0 кеш продвигается до проверенного HEAD, при отказе не меняется.
- И4. Отсутствующий кеш, неизвестный объект и существующий не-предок HEAD идут в прежний полный прогон с именованным маркером; на полном прогоне нарушение даёт rc 1, чистая история rc 0 с сеянием HEAD. Пустая/битая строка даёт прежние «кеш повреждён» и «отказ по кешу», rc 1 без записи кеша. Ни full, ни ошибка разбора не получают пустой fast-path.
- И5. Без --incr default-fast и --oracle дают побайтово прежние rc/stdout/stderr, решения, области, разрешения, per-document since и сообщения. Грамматика разрешений, grandfather-пары, первый родитель merge, кольцо pre-push и механизм публикации 210 не меняются. CHARTER_LIB не исполняет раннюю CLI-ветвь.

## Проверяемый шов и приёмка

W — `bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh`. --repo ROOT исполняет production-файлы выбранного дерева; --model добавляет только model/empty_window.sh в фиксированную до-217 дверь; --stabs мутирует её операции. Н-39: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Привязки и их число — stabs.tsv/probe.py, не список в контракте.

Оракул непустых/full-сценариев — реальные байты pinned production с базы выше, снятые в память ДО субъекта; отдельно проверяется ожидаемый смысловой rc конструктора мира. Пустой оракул — буквальный маркер 083, пустой stdout, rc 0 и ровно HEAD + LF в кеше, заданные до вызова. Неканонический вход HEAD без LF требует наблюдаемой нормализации; заранее канонический HEAD с LF и строгий предок HEAD служат соседними честными контролями. Миры — настоящие отдельные Git-репозитории с собственными .git, не GIT_DIR/GIT_WORK_TREE на основной чекаут. Trace2 — настоящий Git, не PATH-двойник. Истории и каждый мир удаляются в finally.

1. Дано production до реализации; когда `W --repo .`; тогда rc 1, краснота пустых окон именована, историческое предъявление сохранено в SDACHA. После реализации та же команда даёт rc 0, KRASNYE=0. Отрицательные subject-rc 1 по нарушениям считаются зелёными клетками только при точном совпадении выхода и кеша.
2. Дано честная модель; когда `W --model`; тогда rc 0, все клетки зелены: пустая история с длинным прошлым противопоставлена непустому окну, HEAD без LF нормализуется как HEAD с LF, строгий предок без LF проходит непустой суд, правка без разрешения — разрешённой, черновая правка до поздней заморозки — правке после неё, каждый full-fallback — чистой истории, corrupted-cache — валидной базе, fast/oracle — обеим полярностям устава. Когда `W --stabs`; тогда rc 0, ZHIVYH=0; перед каждым предъявлением честный контроль зелёный, поломка якоря/инструмента не считается поимкой.
3. Дано реальная история станции; когда `W --model --live` до реализации либо `W --repo . --live` после; тогда rc 0, CLI ≤2 с, маркер/кеш точны. Проба клонирует историю под TMPDIR и не записывает в исходное дерево; цена clone не входит в замер CLI.
4. Правило формы: `W --syntax`, `W --catalog`, `bash scripts/pre_critic.sh contracts/217-incr-pustoe-okno.md`, `bash scripts/check_sdacha.sh . contracts/217-incr-pustoe-okno.md --run`, `bash scripts/check_provodka.sh . contracts/217-incr-pustoe-okno.md` — каждый rc 0; лист ≤900 с. --syntax запускает bash -n + закреплённый shellcheck через validate_std, Python compile без pycache. Счёт клеток/мутаций/привязок вычисляется --catalog и проверяется против TSV.
5. Правило совместимости на реализации ПОСЛЕ 210: `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo .` — rc 0 после перепина клетки `empty-root-incr` под И1 217: stdout пуст, stderr ровно `incr: check_charter судит <base:8>..<head:8> (0 коммитов)` + LF; `bash fixtures/charter_fast_113/red_113.sh` — rc 0 после перепина клетки `Д/gonka_kesha(а)` под И1/И2 217: на пустом окне история не читается, клетка гонки применима только к непустому окну и сохраняет охрану И3а 113. `bash fixtures/_krasnye_083.sh` — не хуже базы: ok=117 FAIL=3, те же красные клетки `И0/check_charter`, `И0/check_zones`, `И0б/check_zones` (красны по умыслу до частей Г и И 083), а не rc 0. Перепины — только по ПЕРЕСЕЧЕНИЕ ниже; остальные клетки и тексты семей, marker и timeout 60 клетки И0 остаются побайтово прежними. Полнота чужих барьеров не выводится из зелени модели 217.

## Не входит

Повышение timeout; редактирование клетки 083; ускорение полного прохода; PR-окно check_charter/check_contract_frozen; другие incr-чеки; очистка /tmp других семей; новые CI-шаги/реестры руками architect; аутентификация уже доверенного кеша. Не заводить новые предметы в этой пачке.

## Модель угроз

ЗАЩИЩАЕТ:
- От продолжения дорогого суда при пустом окне: полные потоки, кеш, реальная длинная история, секундный предел и Trace2-наблюдение запретных Git-операций независимы от сообщения субъекта.
- От амнистии непустого окна и full-fallback: до-базовое нарушение отделено от внутриоконного; поздняя заморозка, разрешённая/запрещённая правка и неизвестные кеши имеют различающие парные входы и полный побайтовый оракул.
- От ложной поимки на сломанной среде: отсутствующие Git/исходник/исторический объект/трасса/валидатор и неоднозначный якорь дают rc 2 NOT_IMPLEMENTED; предметный двухсекундный таймаут пустой ветви — rc 1 батареи, поскольку это сам измеряемый отказ.

НЕ ЗАЩИЩАЕТ:
- От подделки кеша на уже достижимый и синтаксически валидный SHA, включая текущий HEAD: доверительная модель 083 не удостоверяет прошлый прогон, 217 её не расширяет; ловцы существующие CI-писатели кеша, reviewer/adversary. Страницы cached-прошлого намеренно не пересуживаются.
- От произвольного обхода документов без Git, полного `rev-list HEAD` (кроме действующего секундного предела), подавления/подмены Trace2, распознавания фикстуры и сговора при общем uid: инварианты сохраняются, но конечная батарея не доказывает универсального отсутствия вычисления; ловцы reviewer алгоритма и независимый adversary реализации. Trace2-протокол не переизобретается: JSON разбирается стандартной библиотекой.
- От произвольной внешней нагрузки и отказов железа: секундный предел не ослабляется, инфраструктурную причину устанавливает reviewer; штатная клетка 083 с timeout 60 остаётся действующим CI-ловцом.
- От регрессий публикации/merge вне линейных миров 217: ловцы обязательная production-батарея 210, прежние семьи 113/083 и reviewer. Модель 217 не является разрешением переносить старую production-дверь поверх 210.

Конформный вход — поддерживаемый lib_incr Git-мир с зафиксированным HEAD, штатными путями/первыми заморозками и кешем-предком (включая HEAD с LF и без LF) либо явно объявленным отсутствием/повреждением/непредковостью. Пустое окно — только валидированный base=HEAD; строгий предок пустого окна не образует независимо от LF. Значения SHA, имён и текстов не меняют смысл; валидный контрпример требует расхождения на таком входе, а не сломанного Git/оракула. Производные значения не перечитываются с диска субъекта как истина.

## Зоны и порядок

ЗОНА architect: contracts/217-incr-pustoe-okno.md fixtures/workshop_project/incr_pustoe_okno_217/ fixtures/workshop_project/charter_tekst_do_tega_210/probe.py fixtures/charter_fast_113/red_113.sh
ЗОНА implementer: scripts/check_charter.sh scripts/lib_incr.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ architect: contracts/217-incr-pustoe-okno.md — 993 только станционный контракт 217 внутри широкого contracts/, продуктовый 993 не меняется
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/incr_pustoe_okno_217/ — 054 только новый подкаталог, прежняя проектная семья не меняется
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/incr_pustoe_okno_217/ — 055 только новый подкаталог, прежняя изоляционная семья не меняется
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/charter_tekst_do_tega_210/probe.py — 210 только перепин клетки empty-root-incr под 217 И1/И2 добавлением нового ожидания; остальное побайтово
ПЕРЕСЕЧЕНИЕ architect: fixtures/charter_fast_113/red_113.sh — 113 только перепин клетки Д/gonka_kesha(а) под 217 И1/И2 добавлением нового ожидания; остальное побайтово
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 019 только пустая CLI-ветвь после валидации кеша; is_charter_path и первый родитель merge неизменны
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 022 только пустая CLI-ветвь; CHARTER_LIB и импорт кольца pre-push неизменны
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 065 только ранний выход incr; разрешительная грамматика и grandfather-пары не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 083 пустой incr не строит область; lib_incr, маркер и судьба непустого окна сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/lib_incr.sh — 083 формат, fallback, маркер и атомарный писатель сохраняются; без необходимости библиотеку не править
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 084 только ранний выход; правила изменения ROADMAP не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 086 только ранний выход; прежние отказы и разрешения сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 113 только пустой incr, полный fast/oracle и непустой per-document суд неизменны
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 210 реализация 217 после влива 210; NUL-транспорт, charter_diff_paths и допуск публикации не откатывать
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 992 пустой выход только после успешного разбора; ошибки непустого/full-суда не превращать в ноль

046 в высшем frozen-блобе не владеет check_charter, 200 владеет check_contract_frozen, 207 — check_zones: фактической коллизии этих scripts с зоной 217 нет. Норма гигиены 046 сохраняется без правки. CI-пути ниже принадлежат только orchestrator: новая строка своей батареи, её замер и производная генерация, чужие шаги не меняются.

ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только генерация self-test 217
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только генерация self-test 217

Порядок: architect (контракт + батарея) → critic → freeze → ленд реализации 210 → implementer 217 → orchestrator (своя CI-строка и замер, gen_ci_steps.sh --write/--check) → adversary → reviewer → done. Architect не пишет реестры/workflow и не делает push.

ПРЕДПОСЫЛКИ:
- setting станционные bash, Git с Trace2 и fast-import, Python 3, обычные утилиты используемых production-скриптов; закреплённый shellcheck по ops/server/validators.tsv, VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck; TMPDIR=/tmp/dev-harness-verify/scratch-arch217 вне /zones/; новых secrets/variables/environments нет

ПРОВОДКА:
- guard=scripts/check_charter.sh

ПРОВОДКА-ЭНФОРСМЕНТ: чистое ускорение уже подключённого стража устава; scripts/check_charter.sh вызывается существующими CI и staged-кольцом. Новых норм ролей нет. Батарею 217 подключает orchestrator при носителе, не architect.

## Незаполненные требования:
нет
