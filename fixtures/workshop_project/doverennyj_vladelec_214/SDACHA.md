# СДАЧА 214 — доверенный владелец риска

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-214-v1.md

Исправительный круг Architect214b, OBJECT базы 7c0dd5088082a0cfd6405dac7c03c4a95fc3b4ae. Закрывается только К-03. Путь А: frozen 211, его модель, b37, st56 и остальные клетки не меняются. Production и чужие семьи вне зоны architect; из зоны implementer удалена семья 211. Источник решения — доверенный runtime --repo либо существующая удостоверенная передача D35–D39; метаданные решения закреплены commit. Это конструкция/ред-тесты, не production-реализация.

Обещание и наблюдение прежние: полный настоящий --sudit, rc и обе трубы bytes, ledger при отказе, точный OBJECT единственного START. Ожидания — литералы в памяти до субъекта. Шесть входов арбитража сохранены: arb1/arb2 и arb3/arb4 намеренно одинаковые входы против одного субъекта; arb5/arb6 без грязного legacy. Все исходные 31 клетка и 19 связей сохранены без изменения ожиданий.

КЛЕТКИ: 36. СТАБЫ: 16. СВЯЗИ: 24. НОСИТЕЛИ: 17; с bash-обёрткой: 18. Источник мутаций/связей — build.py; manifest sha256 и канонический TSV проверяются до субъекта. Числа даёт генератор, независимые меры — catalog и фактические model/stabs.

## Двери

TMPDIR=$PWD/tmp/scratch-arch214; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Таблица задаёт ожидаемые rc; фактические результаты передаются отдельно в докладе. Production-red не маскируется зелёным selftest. pre_critic/check_sdacha вызываются отдельно без рекурсии.

- Model · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --catalog · 0 · 0
- Context · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --context · 0 · 0
- Regression · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --regress · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/214-vybor-vladelca-risk-repo.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/214-vybor-vladelca-risk-repo.md · 0 · 0
- Threat · bash scripts/check_threat_model.sh . contracts/214-vybor-vladelca-risk-repo.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/214-vybor-vladelca-risk-repo.md · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/214-vybor-vladelca-risk-repo.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы и отдельные pre_critic/check_sdacha; production red отдельно · - · -
- К-02 · чисто · вход: системный источник из слова владельца и §1/§4 арбитража 211; новых предметов нет · - · -
- К-03 · чисто · вход: путь А; неизменённые 211 59/0 и 208 35/0 на модели и production; новая неизвестность D52 записана в ledger без изменения прежней тихой stderr · - · -
- К-04 · чисто · вход: architect только контракт/семья 214; implementer только zamok_predmeta.sh; context/precision сверяют пересечения · - · -
- К-05 · чисто · вход: rc-команды контракта; после реализации repo обязан быть зелёным, неизвестный источник — именованный отказ · - · -
- К-06 · чисто · вход: git/jq/bash preflight, исключения и таймаут — rc 2; bash -n носителей до мутаций · - · -
- К-07 · чисто · вход: исходные 31 клетка плюс пять D52-контролей; обычный isolated, committed-legacy-safe, reviewer после adversary, внешний продукт · - · -
- К-08 · чисто · вход: адресные 16 стабов, 24 связи; старые 12/19 сохранены, новая миграция-b37 и потеря ledger различимы отдельно · - · -
- К-09 · чисто · вход: происхождение refs/pin/legacy/profile и движение HEAD; D52 safe/risk/no-legacy/trusted-safe и исходная b37 · - · -
- К-10 · чисто · вход: полный rc/обе трубы bytes, START OBJECT, ledger на отказе; warn сверяется структурным кортежем t/repoId/subjectId/kod/object · - · -
- К-11 · чисто · вход: литеральные кортежи ожидаемого до sudit; эталон файлов 211 из Git-объекта до запуска, а не с диска субъекта · - · -
- К-12 · чисто · вход: настоящий Git и штатный profile/class resolver, существующая JSON Schema передачи, bash -n/shellcheck, compile в памяти · - · -
- К-13 · н/п · новых секретов и сетевого доверия в батарее нет · - · -
- К-14 · чисто · вход: одинаковая тихая stderr при авторском ordinary/risky и при честном committed ordinary; старая диагностика без legacy остаётся stderr · - · -
- К-15 · чисто · вход: build 17/16/24, model 36/0, регресс 208 35/0 и 211 59/0 на каждом из трёх субъектов, 76 файлов оракула неизменны · - · -
- К-16 · чисто · вход: manual --repo не удостоверяет себя; автор может выбрать только расположение новой D52-диагностики, не класс/владельца/обязательную запись warn · - · -
- К-17 · н/п · станционная дверь, продуктовой модели/новых writers/scope_id нет · - · -

## Дельта

- К-03 · канон/инструмент · bash fixtures/workshop_project/doverennyj_vladelec_214/red_doverennyj_vladelec_214.sh --regress · 0 · 0

Способ — канон/инструмент: неизменённая батарея 211 запускается как есть на модели 214 и production; штатный klass_riska повторно используется для наблюдения прежней трубы, второго парсера класса/профиля нет. Новые клетки различают разделение результата допуска и диагностики, не переписывают frozen-обязательство. Адресный контрпример критика (исходная b37) и соседний (risky вместо ordinary в авторском legacy) требуют пустую stderr; новое неизвестное доверенное состояние при этом требует warn в ledger. Нет owner-строки, нового v+1 211 или полномочия на его правку.

Соответствие блок → клетка → стаб задаётся build.py, не текстом контракта. К-03: frozen211-b37 (прямой вызов исходной b37) и d52-compat-safe → s13-migration-b37-required; d52-compat-safe → s14-drop-d52-warning-ledger и s15-diagnostic-becomes-class; d52-no-legacy → s16-silence-all-d52. d52-compat-risk — честная эквивалентная запись: старый определённый risky также тих, но неизвестность доверенного источника остаётся в ledger. d52-trusted-safe — честный committed ordinary против ложного dirty risky автора: ни stderr, ни warn не появляются.

Новый запрещающий предикат и пары: сохранение прежней трубы — s13 красен / ordinary и risky зелены; обязательность warn неизвестного доверенного класса — s14 и s15 красны / committed ordinary зелён; сохранение прежней stderr, когда старый класс также неизвестен — s16 красен / определённый risky зелён. Ветви за пределами D52 защищены исходными клетками arb1…arb6/unknown-legacy и прежними стабами. --regress дополнительно сверяет пути и Git blob-хеши всех 76 исходных файлов семьи/контракта 211 с BASE, до субъекта и после каждого запуска. Молча править b37/st56 нельзя даже при последующем зелёном запуске.

probe.py относительно OBJECT базы содержит только добавления: пять новых имён/клеток и их диспетчер, ни одной смены прежнего ожидания. build.py добавляет четыре стаба и пять связей; исходные адресные связи не убраны. context.py снимает только уже исключённую из implementer-зоны семью 211.

## Сырые результаты

Первый контроль исправления в своей копии: генератор CARRIERS 17 STABS 16 LINKS 24, rc 0; --model KLETKI 36 KRASNYH 0, rc 0. --regress rc 0: 208 35/0 и 211 59/0 на базе, production и модели, каждый раз FROZEN211_UNCHANGED 76. Полная последовательность и проверки формы в чистом origin-клоне передаются в итоговом докладе, не объявляются выполненными этой строкой.

## Наблюдение процесса

Кандидат для общего main-журнала, без А-номера и без записи вне зоны: неразличённые «класс для допуска» и «труба диагностики» сделали прежний ремонт ложной миграцией frozen-оракула. Цена — блок К-03 и исправительный круг; источник — Crit214 вызов 1. Закрыто разделением значения и наблюдения, исходной b37 и неизменённым регрессом 211 на новой модели. Общий журнал дописывает интеграционный владелец на main.
