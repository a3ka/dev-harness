# Контракт 228 — Ш-3: решения владельца — данные, не SHA в дверях

КЛАСС ЗАДАЧИ: кодовый — контракт, reference и красная батарея; production после заморозки пишет implementer.
КЛАСС РИСКА: рисковый — авторизация/безопасность: расширение исключения или самоамнистия снимает уставную защиту; adversary → reviewer.
ПРОДУКТ: станция
АРХИТЕКТУРА: не применимо — станционные двери, продуктовой модели 188 нет.
КОНТЕКСТ: R-0114 (25.11), дословно: «План Fable добиваем: станция берёт новыми номерами по мере освобождения слотов, тремя потоками — (1) Ш-5 по ключам + Ш-5ф сразу в режиме отчёта, (2) Ш-3 owner-overrides, (3) Г-1…Г-9 одним контрактом с judges.policy; затем Ш-7 до возврата объёма под предел и Ш-8 замер. Л10 и текущие задачи станции — первыми».
КОНТЕКСТ: R-0102: «хардкодить ничего не надо, все надо выносить в конфиги». Задание task-architect228.md; in-repo источники: docs/owner/adr/2026-11-21-plan-fable.md §в/Ш-3/Б-6 и docs/owner/adr/2026-11-21-plan-v9.md §1/4. SourceCanon не объявлен; номер и строка реестра уже выданы.
КОНТЕКСТ: обещание — перенос прежних решений без изменения их области; наблюдение — rc и обе трубы настоящих CLI, API читателя, реальные commit/tag объекты и буквальная таблица решений базы. Frozen 065/083/200/207/210/217/218/992/071 сохраняют грамматики разрешений, окна, кеши, публикацию и fail-closed. Меняется место хранения исторических исключений, не разрешённый риск.
СДАЧА: fixtures/workshop_project/owner_overrides_228/SDACHA.md

## Предмет

Один результат: исторические SHA-исключения и существующие конечные owner-предикаты четырёх дверей читаются из registry/owner-overrides.tsv общей библиотекой scripts/lib_owner.sh. Следующее разовое решение этого класса требует строки данных, не новой ветви case в коде двери. Переносится также Б-6 check_zones. Все прежние области (SHA, путь/префикс, автор и вид освобождения) сохраняются, включая различие grandfather_pair и остальных разрешений charter.

## Существующее

База main 78672b79bac88b9c3765b3d9b53cd983d4a13728. Дерево, не ожидаемый список задания, даёт 237 вхождений SHA40: check_charter — 166, check_zones — 53, check_protected — 18, check_contract_frozen — 0. Команда: git grep -o -E '\b[0-9a-f]{40}\b' по этим четырём путям, затем wc -l. Независимая мера context.py считает совпадения и исполняемый текст отдельно. Число 237 включает комментарии, повторения и Git-константу пустого дерева; это НЕ число разрешений. Исполняемых вхождений соответственно 90/36/10/0.

Ожидаемые в задании check_no_leak/check_staged не содержат SHA40-исключений: у первого sanity SHA256, у второго нет SHA40. Поэтому фактические четыре потребителя — check_charter, check_zones, check_protected, check_contract_frozen (у последнего переносится конечный предикат пропуска contracts/148/4). Подмена sanity-хеша разрешением владельца была бы дефектом. check_no_leak не правится: 031/044/056 и Б-7 — другая семантика снимка, не готовый читатель owner-решений.

- check_charter экспортирует grandfather_pair, razreshil, is_charter_path, charter_diff_paths и charter_frozen_publication. Grandfather и дополнительные 116/117-цепочки имеют разные потребители: frozen/предстоящее v+1 пропускает чужую дельту только для grandfather_pair. Объединять их в один широкополосный allow нельзя. Грамматика первой колонки, точного пути (включая кавычки), непустой причины и того же коммита уже реализована; 065 переносит исходные строки в merge, не синтезирует их.
- check_zones содержит отдельно mint-исключения только orchestrator + registry/contracts.tsv и process-исключения: точные пути, существующий prefix fixtures/dokazatelstva_098/* и исторические whole-commit допущения. Реальная широкая область этих последних не сужается молча до путей из комментария. Пропуск версии 148/4 в REPLACE сохраняет прочие условия tag/ancestor/old-side/vmax.
- check_protected содержит grandfather удаления, ALLOW-ARTIFACT-DELETE, ALLOW-UNPARSED-ROLE и настоящий Git merge-tree оракул 042. Переносятся статические SHA-пары удаления; текстовые грамматики и перенос артефакта не меняются.
- check_contract_frozen не несёт SHA-списка, но уже имеет owner-допущение пропуска версии 148/4. Сохраняются accept каждой версии, annotated tag, совпадение блобов, предстоящее v+1, hold/CI-согласованность и импорт charter-предикатов.
- 083/3 — единый lib_incr; 207/1 — один суд окна зон; 217/2 — раннее пустое окно; 210/1 — освобождение публикации frozen по живому origin. 218/1 уже заморожен, реализация окна PR ещё в полёте: при ленде 228 интегрируется поверх неё, не заменяет её старым reference. Reference — свидетельство достижимости, не инструкция откатить production к базе.
- Полный список текущих высших frozen и их ЗОНА/ПЕРЕСЕЧЕНИЕ печатает context.py именно через git show frozen/contracts/N/vmax^{commit}:contracts/… и канонический zones_load. 992 запрещает молчаливую чистоту на ошибке чтения; 071/2 охраняет main-предполёт, здесь не меняется. 042/046/083 защищают check_protected и тоже входят в сверку.
- Поиск owner_override/lib_owner/owner-overrides в scripts, fixtures, contracts и registry/plan.tsv не нашёл готового читателя; найденная затравка 228 — этот предмет, не реализация. Реестр TSV и библиотеки lib_registry/lib_zones — существующий стиль. Открытые PR при старте: #1436 (227), #1227 (044), #797 (184); реализации 228 нет. Локальные wip/архивы 218 — работа окна, не дублировать. Маркеров РАЗРЕШИЛ-ВЛАДЕЛЕЦ в scripts/.githooks — 12 файлов; это мера исходного состояния, не обещание переписать всех их потребителей данным контрактом.

## Frontier

1. Два поля door/sha: отвергнуто. Теряются путь, actor и вид освобождения; grandfather_pair становится самоамнистией всех путей SHA.
2. Произвольный shell/YAML-предикат или eval строки: отвергнуто. Данные превращаются в исполняемый код, авторитет и грамматика расходятся между дверями.
3. Выбрано: закрытый TSV с конечными ключами существующих исключений, точными SHA и явной областью. Один валидирующий читатель, полная проверка файла до ответа; новые способы обхода не вводятся. Историческое основание сохраняется в pinned baseline/исходных комментариях; R-0114 в строках означает санкцию ПЕРЕНОСА, не выдуманный номер старого слова владельца.

## Инварианты

И1. UTF-8-имя файла registry/owner-overrides.tsv содержит ASCII-данные без заголовка/комментариев. Запись — ровно шесть непустых TAB-полей, один завершающий LF: ключ, sha, scope, actor, основание, срок. LF/TAB/NUL/CR/пробел не являются байтами поля. Пустой либо отсутствующий файл означает отсутствие исключений; прочая ошибка чтения — отказ, не пустой файл.

И2. Замкнутые ключи: check_charter/grandfather, check_charter/permit, check_protected/delete, check_zones/mint, check_zones/process, check_zones/skip-version, check_contract_frozen/skip-version. SHA — ровно 40 lowercase hex; только skip-version допускает '-' вместо SHA; переносимый предикат имеет буквальный scope contracts/148/4. Короткий SHA, uppercase, дополненный SHA не нормализуются. Scope — буквальный относительный путь из ASCII [A-Za-z0-9._/-], без пустых/dot/dotdot-компонентов; terminal '/*' означает префикс каталога, '*' — whole-commit область, уже существующая на базе. Actor — '*' либо непустой [A-Za-z0-9._-]+. Основание — R- и четыре ASCII-цифры. Срок — never либо канонический Gregorian YYYY-MM-DD, включительно; истёкший не применяется. Новых без-SHA разовых разрешений класса риска нет.

И3. scripts/lib_owner.sh экспортирует owner_override_has <ключ> <sha> [путь] [автор], ROOT — судимый репозиторий. Первые два аргумента дают точное членство; потребитель решения ОБЯЗАН передавать scope-контекст пути и требуемого автора. Для API rc 0 — совпадение, 1 — нет разрешения, 2 — невалидный источник/аргумент. Читатель валидирует ВЕСЬ файл, включая хвост после совпадения; неизвестный ключ, дубликат первых четырёх полей, битая строка, NUL, CRLF, пробелы и неверная грамматика дают rc 2 и самостоятельную строку OWNER_OVERRIDES_INVALID: registry/owner-overrides.tsv:<строка|argument>: <причина>. Все четыре CLI переводят невалидный источник в rc 1 с этим местом, до применения исключения. Положительный матч не скрывает позднюю ошибку. Библиотечный import определяет функции, не запускает CLI/чтение чужого ROOT.

И4. Ни eval, ни regex/glob из данных. SHA/ключ/actor и точный путь сравниваются буквально; prefix-область реализуется буквальным префиксом с границей '/', не общим glob. Терминатор каждого структурного значения — собственное поле/конец записи. Префикс SHA не равен SHA, соседний каталог не равен prefix-области. Новые данные могут меняться без правки кода, но только санкционированной процедурой И5.

И5. registry/owner-overrides.tsv — уставной источник полномочия. Его добавление, изменение, удаление, переименование и merge-дельта требуют строки существующей грамматики РАЗРЕШИЛ-ВЛАДЕЛЕЦ: registry/owner-overrides.tsv <непустая причина> в теле ТОГО ЖЕ коммита; разрешение другого пути не годится. Все пути staged и истории используют is_charter_path, единственный источник. Ни grandfather/permit из самого TSV, ни frozen-publication, ни '*.whole-commit' допущение не разрешают собственный carrier этого файла. Одной строки данных о самом carrier недостаточно. Подлинность текста при общем uid — прежний cognitive-only остаток правила 11, не новая криптографическая подпись.

И6. Все перенесённые строки и ответы базы снимаются ДО реализации: baseline.json содержит буквальную матрицу 148 строк/586 ответов и sha256 исходных дверей; historical.json — неизменяемые rc и sha256 обеих труб настоящих CLI на 133 исторических SHA × четыре двери. Обязательная приёмка проверяет reference↔baseline на закоммиченном reproducibility.json: 78 воспроизводимых SHA, четыре измеренных исключения с причиной, complete=false. Значения reference восстановлены из сохранённого свидетельства точного равенства, а не выдаются за отдельно сохранённые actual-трубы; provenance и хеш исходного equality-log явны. JSON Schema, хеши, покрытие, полный перечень unreproducible и все пары ответов проверяются до субъекта; подмена/усечение/ослабление снимка и рост исключений дают rc 2 HISTORICAL_ORACLE_TOOL_FAILURE, несовпадение ответов — rc 1. Живого пересъёма 133 SHA в --model нет. В ручном --historical каждый сохранённый ответ перепроверяется дважды на неизменённом pinned-baseline с восстановлением мира/кеша, затем сверяется reference (либо --repo R); timeout/SIGPIPE check_zones записывается как unreproducible с причиной и complete=false, не скрывается. Ожидания снимаются в память до субъекта, ручной прогон их не перезаписывает. Дверь с SHA вне файла получает прежний отказ, не wildcard/старый hardcoded fallback. Исполняемых SHA40 в четырёх дверях после cutover нет; пустое Git-дерево вычисляется plumbing. Исторические комментарии разрешены.

И7. На валидном источнике, помимо переноса исключений, прежние решения и текст диагностики сохраняются. Старые текстовые разрешения RAZRESHIL/ALLOW продолжают действовать своей замороженной грамматикой. Не меняются история, состав и порядок судей, frozen/PR/full/oracle/incr-окна, кеши, защищённые артефакты, Git-провенанс. --repo не патчит выбранные четыре production-двери. Режим продукта через новый профиль и всеобщая замена остальных потребителей строки-маркера в этой station-пачке не обещаются.

## Батарея и демаркация

W = bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh.

Швы заданы заданием: API scripts/lib_owner.sh и четыре настоящих CLI. Модель строится адресными дельтами на pinned-предке внутри scratch; ни один production-файл не пишется. Git-миры создаются настоящими init/commit-tree/update-ref/annotated tag, без двойника git. baseline.json хранит литеральные ответы старых case-предикатов. Обязательный --model проверяет живые API/CLI миры, исторический закоммиченный снимок и клетки historical_checks.py/historical_snapshot_checks.py, не переснимает baseline по историческим SHA. Отдельный ручной historical.py --historical использует настоящие SHA, объектную базу по alternates и refs.json только с реальными тегами предков; HEAD — исторический SHA, incr-кеш — его первый parent. Origin не подделывается. Из-за env-i TMPDIR задаётся внутри временных копий зависимостей lib_registry/lib_zones/next_id исключительно для внутреннего scratch; тела четырёх выбранных --repo-дверей не меняются. Матрица удостоверяет области исключения; equality-log и снимок — ранее измеренный полный rc/stdout/stderr-паритет 78 SHA, не происхождение отдельно сохранённых actual-труб.

Конформный вход — обычный Git с читаемыми объектами/тегами и описанным TSV; отрицательные грамматики явно неконформны и обязаны отказать. Ожидания/байты реестра/HEAD снимаются до вызова, не перечитываются из мира субъекта как истина. Валидный контрпример инвариантен к значениям SHA/пути/actor и расходится на конформном входе. Исторический CLI, законно отказавший на иных старых обязательствах, не доказывает применение исключения: для этого есть отдельная буквальная матрица и живые allow/deny Git-миры каждой двери. Битый инструмент, синтаксис/якорь или таймаут — NOT_IMPLEMENTED rc 2, не поимка.

Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Единственный реестр адресных связей — stabs/mutations.json; каждая связь предъявляется отдельно после честного контроля. Census и свидетельства — source.json/SDACHA, не второй замороженный перечень клеток.

## Приёмочный критерий

- Дано production до реализации; когда W --repo .; тогда rc 1 с именованными красными. После реализации та же команда — rc 0, KRASNYE=0. До-реализационный список и числа — сдаточный лист, не инвариант количества клеток.
- Дано честный reference; когда W --model; тогда rc 0. Есть парные listed/not-listed, область/сосед, actor/чужой, срок/истечение, отсутствующий/пустой/битый файл, честная строка/неполный хвост, разрешённая/неразрешённая правка источника, allow/deny каждого реального CLI.
- Дано CLI-миры check_zones/process (точный путь и префикс) и check_zones/mint с actor равным автору коммита, чужим и '*'; когда W --model; тогда rc 0: равный/'*' допускаются, чужой отвергается rc 1 «коммит вне зоны:»; передача литерала вместо автора красит W --model и W --repo на той же реализации.
- Дано легитимный grandfather для дельты AGENTS.md; когда W --model проверяет читаемый файл, затем реальные EACCES (chmod 000), EISDIR и ELOOP; тогда читаемый контроль допускается, API ошибки даёт rc 2, check_charter — rc 1 с самостоятельной OWNER_OVERRIDES_INVALID до применения исключения. Ненаблюдаемый EACCES под root — именованный «ОКРУЖЕНИЕ: root» rc 2 батареи, не зелёная клетка; EISDIR/ELOOP не обходятся root.
- Правило различимости; W --stabs — rc 0, ZHIVYH=0; W --catalog — rc 0 с непустыми клетками, строками миграции и связями. Ошибка среды не засчитывается краснотой предмета. W --sintaksis — rc 0: Python ast, Bash bash -n и pinned shellcheck через validate_std; модельные двери проходят bash -n.
- Правило полной миграции; W --model — rc 0, HISTORICAL_SNAPSHOT complete=false REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312 MISMATCHES=0. Схема/хеши/покрытие и паритет снимка обязательны; подмена, усечение и рост исключений дают rc 2. Оракулы на реализации не переснимаются. Ручная, НЕ обязательная и НЕ CI-команда: W --historical (или python3 fixtures/workshop_project/owner_overrides_228/historical.py --historical --repo .); rc 0 — ни одного расхождения на воспроизведённых, rc 1 — расхождение, rc 2 — инструмент недоступен. complete=false допустим при таймауте/SIGPIPE check_zones или ограничении времени; напечатаны воспроизведённые/исключённые SHA, причины и расхождения; отчёт только в scratch. Ограничение --seconds 1..2400, по умолчанию 2400 секунд.
- Правило гигиены парсинга; W --parsing — rc 0: настоящий runner fixtures/parsing_hygiene_battery/run_battery.sh с профилем этой семьи проверяет delimiter/regex/silent-drop/self-application. Честный source реестра модели зелён до freeze.
- Правило допуска; bash scripts/pre_critic.sh contracts/228-sh3-owner-overrides.md и bash scripts/check_sdacha.sh . contracts/228-sh3-owner-overrides.md --run — каждый rc 0. python3 fixtures/workshop_project/owner_overrides_228/context.py — rc 0, непустые frozen-происхождения и пересечения.
- Правило регресса после cutover, без ослабления прежних клеток: bash fixtures/workshop_project/okno_zamorozki_200/red_okno_zamorozki_200.sh --repo .; bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --repo .; bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh --repo .; bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo .; bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --repo . — каждый rc 0 после ленда реализации 218; bash scripts/verify_antiplacebo.sh --scope check_charter check_protected check_zones и python3 fixtures/freeze_contract/fail_closed_992.py — каждый rc 0. fixtures/_krasnye_083.sh — не хуже базы по множеству красных, согласно действующей приёмке 217/218. Чужие frozen-тексты не переписываются ради новых данных.
- Правило проводки; orchestrator подключает свой self-test и замер, bash scripts/gen_ci_steps.sh --write и --check — каждый rc 0. До done bash scripts/check_provodka.sh . contracts/228-sh3-owner-overrides.md — rc 0 после подключения CI; до него проверяется --grammar, отсутствие CI-строки не объявляется done.

## Модель угроз

ЗАЩИЩАЕТ:
- От расширения прежней индульгенции на чужой SHA, путь, автора или вид освобождения: точная многомерная область, буквальная матрица всех прежних записей и настоящий CLI-дифференциал.
- От тихого допуска битого источника и раннего успешного совпадения: полный разбор до решения, закрытый алфавит, адрес ошибки и отрицательные хвосты после совпавшей записи.
- От самоамнистии источника полномочий: отдельная уставная проверка его carrier, включая добавление/удаление, без использования решений из проверяемого файла для собственного допуска.

НЕ ЗАЩИЩАЕТ:
- От подделки самой строки владельца при общем uid, компрометации Git/PATH/установки или памяти проверяющего: прежняя доверенная среда; ловцы правило 11, изоляция, origin/CI и независимые adversary/reviewer.
- От семантически неверного нового owner-решения с формально верной санкцией: авторитет остаётся владельцу, содержание проверяет независимый суд; TSV не криптографическая подпись и не автоматическое согласие.
- От новых классов исключений вне закрытых ключей и продуктовой профильной интеграции: отдельные предметы Ш-3/Ш-5 по измеренной боли; данная пачка не разрешает О-1…О-3 и не меняет runtime/судейский регламент.
- Живой пересъём исторического CLI-паритета по всем 133 SHA не входит в обязательную приёмку: baseline check_zones нестабилен (наследуемый SIGPIPE/timeout 60 с под нагрузкой); паритет на невоспроизведённых SHA не доказывается; ловцы — reviewer (полный diff production), литеральная матрица 148/586, живые API/CLI миры, ручной --historical перед ленд-ревью. Остаточный риск cognitive-only (AGENTS правило 1); решение о границе — оркестратор, task-architect228c.md; пересмотр — консультант/владелец.

## Зоны и порядок

ЗОНА architect: contracts/228-sh3-owner-overrides.md fixtures/workshop_project/owner_overrides_228/
ЗОНА implementer: scripts/lib_owner.sh registry/owner-overrides.tsv scripts/check_charter.sh scripts/check_zones.sh scripts/check_protected.sh scripts/check_contract_frozen.sh
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

ПЕРЕСЕЧЕНИЕ architect: contracts/228-sh3-owner-overrides.md — 993 только новый контракт станции 228
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/owner_overrides_228/ — 054 только новая семья 228
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/owner_overrides_228/ — 055 только новая семья 228
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 065 перенос списков; грамматика и merge-санкции прежние
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 083 только источник исключений; incr-кеш прежний
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 210 источник исключений; публикационный предикат прежний
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 217 валидный источник не меняет пустое окно
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 218 интеграция поверх реализации PR-окна, без её отката
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 992 битый источник не становится чистым
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_contract_frozen.sh — 200 только источник исключений; окно и v+1 прежние
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_contract_frozen.sh — 218 интеграция поверх реализации PR-окна, без её отката
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_protected.sh — 042 только список исключений; настоящий merge-tree прежний
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_protected.sh — 046 только список исключений; герметичность прежняя
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_protected.sh — 083 только источник исключений; incr-кеш прежний
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 002 только источник исторических исключений
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 003 только источник исторических исключений
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 031 только источник mint-исключений; форма/провенанс прежние
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 047 только источник исторических исключений
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 083 только источник исключений; incr-кеш прежний
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_zones.sh — 207 один суд окна и прежние решения сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только свой шаг 228; main-предполёт не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 200 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 207 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 210 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 217 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 218 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 200 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 207 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 210 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 217 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 218 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только свой шаг 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только свой замер 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 200 только свой замер 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 207 только свой замер 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 210 только свой замер 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 217 только свой замер 228
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 218 только свой замер 228

scripts/lib_owner.sh и registry/owner-overrides.tsv — новые пути, пересечений высших frozen нет; context.py удостоверяет каждый существующий путь. Неизменяемые check_no_leak и check_staged не становятся зоной этой пачки. При ленде 218 раньше 228 — перенос только адресной дельты, последующий регресс 218 обязателен.

РАБОТА РАЗДАЁТСЯ: implementer
Порядок: architect → critic → freeze → implementer → orchestrator (CI) → adversary → reviewer → land/done. Architect не меняет production, CI и реестры; журнал А-NN пишется только в main, не в wip.

ПРЕДПОСЫЛКИ:
- setting Git с commit-tree/annotated tags, Bash, Python 3 с jsonschema (JSON Schema Draft 2020-12) и штатные утилиты; pinned shellcheck 0.11.0 через VALIDATE_STD_SHELLCHECK; scratch/TMPDIR только внутри собственной копии.
- setting Полная база объектов и тегов pinned-предка для исторического дифференциала; никакие secrets, variables, environments и новые внешние сервисы не требуются.
- setting CI-строку и её замер подключает orchestrator; чужие шаги и frozen-тексты сохраняются.

ПРОВОДКА:
- guard=fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh

ПРОВОДКА-ЭНФОРСМЕНТ: перенос данных существующих стражей, не новая норма роли. Self-test 228 до реализации вызывает --model/--stabs/--sintaksis/--catalog/--parsing, после также --repo .; исторический снимок проверяется внутри --model, живой --historical — только ручная команда перед ленд-ревью, НЕ CI и НЕ обязательная дверь. Полный done-гейт после CI-подключения.

## Незаполненные требования:
нет
