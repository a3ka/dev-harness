# Контракт 223 — ARCH_CI v2: `.review/**` в служебном хвосте SHA*

СТАТУС: ЧЕРНОВИК — до критика и заморозки.
КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: рисковый — авторизация приёмки: продуктовая дельта не должна получать done без успешного arch; adversary → reviewer.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — станционный механизм; продуктовая модель 188 не объявлена.
КОНТЕКСТ: слово владельца 2026-11-24 «ARCH_CI v2 да»; письмо consultant/inbox-back-1190-done177-arch-ci-review-path.txt; contracts/187-arhitektura-v-processe.md; contracts/201-done-dver-soderzhatelnaja-sverka.md; contracts/224-svezhest-verdikta-done.md. SourceCanon не объявлен.
СДАЧА: fixtures/workshop_project/arch_ci_review_223/SDACHA.md

## Боль

Бэкенд done 177/6 на main 09f8ba635cd34af657b0376ba8388abbde0ba4dc отказал rc 1: `ARCH_CI: HEAD=09f8ba635cd34af657b0376ba8388abbde0ba4dc; SHA*=09f8ba635cd34af657b0376ba8388abbde0ba4dc; успешного check-run arch нет (curl rc=0)`. PR #1031 добавил штатный `.review/2026-11-24-06.md` со `status: ready`. Служебная цепочка прежде доходила до продуктового c635a010, но `.review/` остановил подъём; последующие служебные PR #1033/#1034/#1036 не помогли. Письмо прочитано; это исходное измерение владельца проекта, не утверждение о заново выполненном done бэкенда.

## Предмет

Один результат: настоящая дверь `bash scripts/done_contract.sh <контракт> <причина> [корень]` считает служебными пути двух корневых каталогов `.harness/**` и `.review/**` при выборе продуктового SHA*. Список задаётся одной функцией/константой, не литералами проектов в нескольких потребителях. Расширяется только набор путей существующего подъёма, новая дверь или система вердиктов не вводится.

Обещание — перескочить служебный review-merge, не перескочить продуктовую дельту. Наблюдение — полный rc/обе трубы CLI, единственный SHA-адресованный запрос check-runs, оба полных SHA в предметной строке ARCH_CI, настоящий annotated done-тег на исходном HEAD. Frozen-обязательства 187/3 и 201/1 о продуктовом SHA, первом родителе, имени/status/conclusion run сохраняются с добавлением `.review/`; 038/2 и 224/1 о выборе вердикта, frozen/CID/OBJECT и остальных ногах не меняются.

Порядок: architect сдаёт контракт/reference/клетки/стабы/лист → critic → freeze → implementer точечно правит текущую дверь → orchestrator подключает свой CI-шаг/замер → adversary → reviewer → land → done. Модель — доказательство достижимости, не разрешение заменить текущую дверь старой копией. Исполнение done бэкенда и изменение его вердиктов вне этой пачки.

## Существующее

База после fetch/switch: f82ff8c9d0d4ba45a53b7aa2e712c552141715f9. Номер уже выдан id/CONTRACT/223; registry/plan.tsv несёт 223 с источником a42a71cc049c822e17bcf61240dee7603e5112bc, повторный mint не нужен.

- `scripts/done_contract.sh` ARCH_CI :468–607 уже обходит обычные и двухродительские merge по первому родителю; дельта — `git diff --no-renames --ignore-submodules=none --name-only -z <p1> <SHA*>`. Непустой полный список должен целиком принадлежать служебным каталогам. Сейчас единственная ветвь `.harness/*` на :532; надо расширить именно её. NUL-разделитель, обе стороны rename, gitlink, предел 50, root/octopus, API и место done-тега уже решены и не переизобретаются.
- `fixtures/workshop_project/architecture_process_187/ci_ancestor.py` несёт реальные Git-цепочки, merge-дельты и SHA-адресованный API; прежняя батарея 187 защищает алгоритм подъёма. Семья 201 `dver_probe.py` строит корректные backend-профили, F/OBJECT/review и настоящие Git-миры. 223 переиспользует только её конструктор, не модель/оракул 201. Новые ожидания — литералы CASES до запуска двери.
- Семья 224 уже сохраняет независимый выбор кругов и прежние frozen/CID/OBJECT; регресс --repo . до изменения: 100 клеток, KRASNYH 0. Семья 227 задаёт форму wrapper/probe/build/model/stabs/source/SDACHA. Изменения этих семейств не нужны.
- Контракты 187/201 охраняют ARCH_CI; 205 меняет профиль проводки, не список путей SHA*. Контекстный `context.py` читает каждый высший frozen-блоб через git show, выводит commit и действительные ЗОНА; все найденные пересечения ниже. Подготавливаемый 231 (имена вердиктов, тот же done_contract.sh) пока отсутствует в базе и локальных wip-ref; пересечение объявлено отдельно, смысл 231 не заменяется.
- Поиск scripts/, fixtures/, contracts/, plan.tsv и wip не нашёл иной реализации 223. Открытые PR на момент чтения: #1442 (218), #1439 (226), #1227 (044), #797 (184); они не расширяют служебные пути. Поэтому дорабатывается существующий классификатор ARCH_CI, не второй механизм. Активные затравки/документы не считаются заморозками; дерево новее старого первого раздела HANDOFF.

## Инварианты

1. Служебный путь — Git-путь, начинающийся побайтно с `.harness/` либо `.review/` от корня дерева. Граница каталога обязательна: `.reviewx/`, `review/`, `.review`-файл, `.REVIEW/`, вложенный `docs/.review/` — продуктовые. Регистр не складывается. Пробелы, Unicode, перевод строки и буквальное `a..b` внутри имени не меняют классификацию.
2. Для merge с двумя родителями берётся полный NUL-разделённый список дельты итогового дерева относительно ПЕРВОГО родителя. Если он непуст и каждый путь служебный — подъём продолжается к первому родителю; смесь `.harness/**` и `.review/**` допустима. Любой иной путь, в том числе смесь служебных с продуктовым, останавливает подъём на этом merge. Обычный коммит использует то же правило. Второй родитель не выбирает SHA*; равенство итогового дерева второму родителю не делает непустую дельту первого родителя пустой.
3. Rename проверяется по обеим сторонам: внутри служебных каталогов допустим, продукт→служебный и служебный→продукт останавливают подъём. Удаление, mode-only, symlink и type-change судятся по изменённому Git-пути, не по существованию файла/разыменованной цели. Симлинк `.review/link` остаётся служебным даже с продуктовой целью; `src/link` не становится служебным.
4. Канон имён — реальные пути Git, не вымышленные строки. Git не хранит `.`/`..` как компоненты; запись через файловую систему `.review/a/../../x` даёт дельту `x`, которая продуктовая. Приёмка проверяет это plumbing-ом до субъекта. Лексическую нормализацию сырых имён дверь не добавляет.
5. Пустая дельта НЕ служебная: SHA* не поднимается; success только на первом родителе не заменяет success на HEAD. Octopus (>2 родителей) с пустой, служебной либо смешанной дельтой отказывает ARCH_CI до API, даже при success на HEAD. Это наследие frozen/contracts/187/3, не новое поведение: база 862ed947b, `scripts/done_contract.sh:507–511,526–537`. Root, предел 50 служебных переходов и отказ на 51-м и учёт merge в глубине сохраняют существующую семантику 187. На выбранном SHA* нужен прежний completed/success check-run с допустимым именем arch; отсутствующий, failure, skipped, незавершённый, чужой SHA и `archive` не принимаются. Поддержка имён `arch …`, `arch (…)` и прежнее правило head_sha 201 не ослабляются и не ужесточаются. Новая функция не меняет API-парсинг, транспорт, scope/profile или ARCH_REVIEW.
6. Мир формы done 177/6: продуктовый предок с success, review-only PR #1031 и последующие служебные merge #1033/#1034/#1036 → запрос к продуктовому SHA*, rc 0, done-тег на HEAD. Та же форма с продуктовой дельтой → запрос к самому merge, без success на нём rc 1 ARCH_CI. Реальные SHA мира случайны и не сравниваются с именами из письма.
7. Отказ не создаёт done-тега и не двигает HEAD. Заморозка/OBJECT/влитость, свежий reviewer/adversary, риск, причины, профиль, consumers, проводка и остальные двери остаются прежними. Ни один новый bypass или литерал проекта не вводится.

## Приёмочный критерий

B = `bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh`. Шов — заданный публичный CLI настоящего done_contract.sh. До субъекта ожидания rc/SHA/тега и байты носителя находятся в памяти проверяющего; Git и API-шлюз настоящие/адресованные, Git не подменяется. Истина результата не перечитывается из ожидаемого файла в мире субъекта.

Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Реестр адресных связей — MUTATIONS/EQUIVALENTS в build.py; source.json/stabs.tsv генерируются из него и проверяются по хешам/побайтно. Каждая связь исполняется отдельно. Ошибка инструмента/мира/синтаксиса либо отказ НЕ ARCH_CI — rc 2 NOT_IMPLEMENTED, не поимка стаба.

- Честная модель: `B --model` → rc 0, все клетки зелены, включая парные продуктовые отказы и служебные допуски для каждого нестандартного вида дельты.
- Непустота и родители: `B --model` → rc 0; пустой двухродительский merge запрашивает HEAD (success только на p1 → rc 1 ARCH_CI без тега; success на HEAD → rc 0); пустота относительно p2 не отменяет классификацию непустой дельты p1; octopus любой из трёх дельт → rc 1 ARCH_CI без запроса и тега. `B --stabs` → rc 0 различает мутацию критика и соседние мутации отдельно; непустые служебные допуски остаются зелеными.
- Различимость: `B --stabs` → rc 0, ZHIVYH 0; перед мутациями честный контроль зелён; каждая красная связь красна своим входом, честные эквиваленты остаются зелеными.
- Форма: `B --sintaksis` → rc 0 (bash -n всех носителей, стандартный shellcheck модели/обёртки, compile Python без pycache); `B --catalog` → rc 0, непустой каталог; `python3 -B fixtures/workshop_project/arch_ci_review_223/context.py` → rc 0, реальные frozen-источники и все объявления присутствуют.
- Допуск: `bash scripts/pre_critic.sh contracts/223-arch-ci-review.md`, `SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh . contracts/223-arch-ci-review.md --run`, `bash scripts/check_precision_gate.sh . contracts/223-arch-ci-review.md` → каждый rc 0.
- Регресс: `bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo .`, `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .` → прежние результаты; фактические baseline-отказы не выдаются за дефект 223, сырой замер — в листе. После реализации сравнить с этим baseline, не менять чужие семьи под новый код.
- Потребитель: `bash scripts/check_spec_ready.sh . contracts/223-arch-ci-review.md` → rc 0. До done orchestrator: `bash scripts/check_provodka.sh . contracts/223-arch-ci-review.md` и `bash scripts/gen_ci_steps.sh --check` → rc 0 после подключения собственного CI-шага.

### Красное сейчас — до реализации

`B --repo .` → rc 1 с именами красных служебных review-входов в листе; служебный `.harness/` и продуктовые границы уже зелены. Краснота — расхождение полной живой двери с инвариантами, не отдельного суррогатного selector.

### После реализации

`B --repo .` → rc 0, KRASNYH 0; все прочие режимы и scoped-регрессы сохраняют результаты. Конформный контрпример — реальная Git-история/профиль с доступными F/OBJECT/вердиктами и дельтами по инвариантам. Он инвариантен к SHA, содержимому/именам файлов в пределах классификации и пути корня; отсутствие runtime/объектов не является контрпримером. Конечная батарея не доказывает произвольные программы или сеть.

ПОТРЕБИТЕЛЬ scripts/check_spec_ready.sh: bash scripts/check_spec_ready.sh . contracts/223-arch-ci-review.md
замер: `cat scripts/consumers.d/*.tsv | wc -l` = 6 census scripts/consumers.d/*.tsv

## Модель угроз

ЗАЩИЩАЕТ:
- От остановки SHA* на штатной служебной review-дельте, включая merge/цепочку: два корневых каталога и запрос к продуктовому предку.
- От пропуска продуктовой дельты по префиксу, регистру, смешению или неполному списку rename: точная каталоговая граница, полный список и парные отказы.
- От принятия отсутствующего/чужого/красного arch после подъёма: существующая проверка run остаётся обязательной, отдельные негативные миры.

НЕ ЗАЩИЩАЕТ:
- От семантически продуктового содержимого внутри разрешённых служебных каталогов: классификация по Git-пути; остаточный риск прежний, ловцы независимые reviewer/adversary и владельцы каталогов.
- От компрометации Git/PATH/установки, согласованно лживого check-run или подмены памяти одной uid: доверенная среда и изоляция; ловцы origin, CI и независимый суд, новой аутентификации API нет.
- От независимых дефектов других done-ног/архитектуры/профиля: ловцы прежние семьи 038/187/201/205/224/992/996 и reviewer полного diff; 223 их не заменяет.

## Зоны

ЗОНА architect: contracts/223-arch-ci-review.md fixtures/workshop_project/arch_ci_review_223/
ЗОНА implementer: scripts/done_contract.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

Подготавливаемый 231 пересекает scripts/done_contract.sh: 223 меняет только служебный классификатор SHA*, 231 — имена вердиктов. Слияние точечными правками текущего файла, без копирования reference поверх чужой реализации; совместимость — обе батареи после ленда 231. Frozen-пересечения 205/224 объявляются по фактическим высшим тегам, не по предположению задания.

## Пересечения

ПЕРЕСЕЧЕНИЕ architect: contracts/223-arch-ci-review.md — 993 новая семья 223
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/arch_ci_review_223/ — 054 новая семья 223
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/arch_ci_review_223/ — 055 новая семья 223
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 038 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 094 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 168 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 184 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 187 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 201 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 224 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 226 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 992 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 996 только пути SHA*, остальные гейты сохранены
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только CI 223, чужие шаги без изменений
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только CI 223, чужие шаги без изменений

## Предпосылки

ПРЕДПОСЫЛКИ:
- setting Git/bash/python3/jq/date/stat и пинованный shellcheck доступны; новые secrets/variables/environments и настройки GitHub не требуются.
- setting Свой шаг check:arch-ci-review-223-family-selftest и замер подключает orchestrator: до реализации --model/--stabs/--sintaksis, после также --repo .; чужие строки не меняются.

ПРОВОДКА:
- guard=fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh

ПРОВОДКА-ЭНФОРСМЕНТ: только расширение классификатора существующей двери, новой поведенческой нормы роли нет; CI-подключение выполняет orchestrator до done.

## Незаполненные требования:
нет
