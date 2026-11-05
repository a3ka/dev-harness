# Контракт 164 — судимый класс риска

КЛАСС ЗАДАЧИ: кодовый (дверь приёмки заключения судьи и красные исполняемые предъявления). КЛАСС РИСКА: рисковый — основание «ПД/health-данные»: ошибочное понижение класса предмета 163 лишало required android-e2e health-продукта независимого adversary (§Существующее, verdicts/critic/contracts-163-v1-fail.md:14–18). ТРЕК: ПОЛНЫЙ.

КОНТЕКСТ: 04.11 критик 163 на закоммиченном кандидате нашёл `обычный` при неизменном required health-CI и ранее признанном `рисковый` frozen 143/2. Исправление 163 до freeze произошло только по содержательному суду; дверь `zamok_predmeta.sh` читала авторскую строку и различала грамматику, но не предъявляла независимого суждения о классе. Следовательно, пропуск/ошибка судьи или изменение контракта после суда может отменить обязательную adversary-ногу без явного отказа. Норма роли critic уже требует проверить основание и понижение, механика пока не связывает принятый вердикт с действующим контрактом.

## Существующее

- `roles/critic.md:244–249` требует семантической проверки риска по предмету, списка оснований и блокирующей находки на занижение; `:30` требует adversary перед reviewer для рискового. Сам суд существует — здесь не вводится классификатор по ключевым словам или второй судья. `verdicts/critic/contracts-163-v1-fail.md:14–18` и `contracts/143-mob-ci-razdelenie.md:3` — наблюдаемый прецедент верного исправления.
- `scripts/zamok_predmeta.sh:165–202,492–509` строго читает все `contracts/<NNN>-*.md` (в проекте — `.harness/contracts/`) и отказывает на неоднозначном авторском классе, затем при `рисковый` требует завершённого adversary. Это правильная грамматика и порядок после квалификации; замена этого парсера / снятие его отказов НЕ входит в предмет.
- `scripts/freeze_contract.sh:258–304` уже требует закоммиченный контракт, `accept` в вердикте нужной версии на HEAD, но не связывает CLASS из заключения критика с OBJECT/блобом принятого контракта. `scripts/pre_critic.sh`, `check_spec_ready.sh` стоят до суда и НЕ могут сами подтвердить содержание будущего заключения. `fixtures/workshop_project/odin_agent_140/` уже держит многоконтрактную неоднозначность и порядок adversary/reviewer; его клетки сохраняются.

## Предмет

Единый результат: новая дверь `scripts/check_judged_risk.sh --repo R --contract <C> --verdict <V>` принимает **только** вердикт `accept`, в котором критик отдельной строкой `СУД-КЛАССА-РИСКА: обычный|рисковый` зафиксировал собственное решение, совпадающее с единственным объявленным классом C. Заключение относится к конкретному `OBJECT=<40 hex>` кандидата: blob `OBJECT:C` побайтово тождествен `HEAD:C`; сам `HEAD:V` совпадает с файлом V на диске. Для кода договора новые заключения без метки красны: автор не получает route «обычный» по умолчанию. Отказ не меняет refs, учёт и замки. Каждая причина — самостоятельная строка stdout/stderr, rc 1; rc 2 только при невозможности проверки инструментами/репо.

Дверь ставится между `accept` и записью frozen-тега в `freeze_contract.sh` и до выбора reviewer-маршрута в `zamok_predmeta.sh`: второй потребитель читает только вердикт актуального frozen-договора, иначе риск исходного author declaration по-прежнему самодостаточен. Критик получает требование явной строки в задаче через `make_task.sh`; к существующим вердиктам без строки дверь не применяется ретроактивно: активируется для **нового контракта 164 и следующих НОВЫХ предметов, впервые выданных механизмом после `id/CONTRACT/164`**, а не по лексическому номеру (legacy 991, v+1 143 и проекты с собственной нумерацией не превращаются в новые). Источник активации — история выдачи id-тега/реестра, не опциональная строка автора; для проектного репо без этой истории до отдельного согласования активации остаётся действующая дверь 140. Для уже активированного предмета `v+1` не снимает обязательство. Две станции потребления используют один интерфейс проверки, не копируют парсер. Готовность включает сохранение прежнего положительного и отрицательного порядка 140.

Замкнутый алфавит нового поля: ровно одна физическая строка `^СУД-КЛАССА-РИСКА: (обычный|рисковый)$`; без пробелов/суффикса/дублирования/blockquote/кодовой цитаты. `OBJECT` ровно одна строка `^OBJECT=[0-9a-f]{40}$`; декларированный CLASS читается по существующей грамматике 140 (возможен после «КЛАСС ЗАДАЧИ: …» на той же строке, терминатор blank/точка/запятая/точка с запятой/EOL). Строки в цитатах не являются метаданными. Несовершаемое сравнение untrusted-untrusted — побайтовый литерал или git blob id, не regex/glob из значения пользователя; пути C/V — относительные штатные пути, не содержат `..`, NUL, LF и не выходят из R; V принадлежит тому же NNN и текущей версии. Проверяющий берёт действующий HEAD и не принимает ссылку на посторонний OBJECT или незакоммиченные свидетельства.

Frontier до выбора: (A) лексический risk-classifier — быстро, но не умеет установить, что перенесённые lane 163 сохраняют угрозу 143; (B) авторская декларация + вывод critic на словах — существующее состояние, 163 пойман, но отсутствие следа допускает тихий downgrade после суда; (C) явное заключение critic, привязанное к OBJECT, + проверка до freeze/reviewer — выбран. Независимое семантическое решение остаётся за critic, механика судит наличие, авторство носителя зоной critic, привязку и противоречие. [INFERENCE] Поле снижает потерю уже состоявшегося суда, но не делает неверное человеческое решение истинным. Семантика «какой класс верен» не выводится из текста механически.

## Приёмочный критерий

`W = python3 fixtures/workshop_project/sudimyy_klass_riska_164/probe.py`. Конформные входы: читаемый git-репозиторий R, C/V внутри него по указанной грамматике, тип кодовый, вердикт зафиксирован коммитом после кандидата, HEAD содержит оба файла; значения основания и содержимого предмета не ограничены. Валидный контрпример сохраняет эту грамматику и отличается на одном из объявленных инвариантов. Батарея фиксирует ожидаемые rc и именованные причины в памяти до вызова субъекта; входы не являются оракулом после вызова. Каждый обманный алгоритм и его отличающий вход связаны непосредственно в `probe.py` (`STABS`), не прозой.

1. Дано: честные обычный и рисковый контракты, а также побайтовая копия этого 164 в отдельном git-мире с `accept`/OBJECT. Когда `W --model`. Тогда rc 0, `контроль зелёный; клеток 15` (самоприменение + самостоятельные красные ветви). Когда `W --stabs`, тогда rc 0, `стабов 5, непойманных 0`, со строкой свидетельства расхождения каждого стаба на своей клетке.
2. Дано: нынешняя ветка ДО реализации двери. Когда `W --repo`, тогда rc 1, `SUBJECT_ABSENT` вместо принятия честных входов; после реализации той же командой rc 0 при всех 15 отдельных клетках. Красные клетки: downgrade обычный↔рисковый (`RISK_CLASS_MISMATCH`), отсутствие/дубль/цитата/кодовая цитата поля или FAIL (`JUDGMENT_MISSING`), битый или дублированный OBJECT (`JUDGMENT_OBJECT_INVALID`), новая версия контракта после суда (`JUDGMENT_STALE`), декларация только в цитате или дубль (`RISK_DECLARATION_INVALID`). Парность: оба честных класса rc 0; каждое красное состояние rc 1 со своей причиной. `W --repo` не подменяется `--model` при freeze.
3. Дано: одноразовые git-миры с честным legacy 001 без новой метки и с newly issued 164/165: honest-risk, missing-164, mismatch, post-accept, missing-165 — каждый отдельным прогоном настоящего freeze. Когда `python3 fixtures/workshop_project/sudimyy_klass_riska_164/freeze_probe.py`, тогда до реализации rc 1: четыре отдельных `FREEZE_BYPASS` с именами клеток (сейчас незаконные frozen-теги появляются), honest-risk rc 0 с тегом, legacy rc 0; после реализации rc 0: честные legacy/honest-risk rc 0 с тегом, четыре красных rc 1 по своим причинам и без нового тега. Дано: настоящая дверь 140 с замком и журналом yield, принятый ordinary/risky, downgraded ordinary при судимом risky, no-judgment. Когда `python3 fixtures/workshop_project/sudimyy_klass_riska_164/lock_probe.py`, тогда до реализации rc 1 `REVIEWER_BYPASS: downgraded, no-judgment` при двух честных контролях; после реализации rc 0 `reviewer route: 4/4`, два отказа до записи в учёт. Дополнительный existing маршрут «после завершённого adversary reviewer rc 0» судится без изменения `python3 fixtures/workshop_project/odin_agent_140/probe.py` (сохранить его полярность).
4. Дано: настоящий контракт 164 с принятой критиком версией V. Когда `bash scripts/check_judged_risk.sh --repo . --contract contracts/164-sudimyy-klass-riska.md --verdict V` и затем freeze, тогда rc 0 обоих; отсутствие поля в verdict критика краснит freeze без тега. В действующем дереве до появления V проверка не выдаётся за зелёную.
5. Когда `bash scripts/pre_critic.sh contracts/164-sudimyy-klass-riska.md`, `bash scripts/check_precision_gate.sh . contracts/164-sudimyy-klass-riska.md`, `bash scripts/check_spec_ready.sh . contracts/164-sudimyy-klass-riska.md`, `bash scripts/check_threat_model.sh . contracts/164-sudimyy-klass-riska.md`, тогда каждый rc 0. `bash scripts/check_provodka.sh . contracts/164-sudimyy-klass-riska.md` до подключения новой двери — rc 1 с названным отсутствующим потребителем, до done rc 0. В CI харнесса подключаются три команды `probe.py --repo`, `freeze_probe.py`, `lock_probe.py` из этой директории и соответствующие замеры.

## Модель угроз

ЗАЩИЩАЕТ:
- Авторскую строку `обычный`, расходящуюся с независимо зафиксированным `рисковый`, и принятый без решения класса вердикт; порядок adversary/reviewer остаётся воротами 140.
- Подмену второго решения цитатой, дублем, несвязанным OBJECT или изменением blob после судейства; непроверяемая история — именованный отказ.
НЕ ЗАЩИЩАЕТ:
- Ошибку независимого critic, ошибочное основание в обоих источниках или сговор судьи и автора: механика не притворяется семантическим risk-classifier; ловец — adversary/reviewer по фактическим последствиям предмета и owner при конфликте frozen-обязательств.
- Старые, ещё активные предметы и независимые проектные реестры, не содержащие события выдачи 164: их existing critic+140 остаются действующими, до отдельной санкции массового cutover они не переписываются.

ПРЕДПОСЫЛКИ:
- setting Существующие GitHub Actions CI харнесса запускают Python 3 и git; новые secrets, variables, environments и права не требуются.

## Зоны и проводка

ЗОНА architect: contracts/164-sudimyy-klass-riska.md
ЗОНА architect: fixtures/workshop_project/sudimyy_klass_riska_164/
ЗОНА implementer: scripts/check_judged_risk.sh scripts/freeze_contract.sh scripts/zamok_predmeta.sh scripts/make_task.sh
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 031 добавляется только проверка класса после accept, прежние двери остаются на месте.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 многоконтрактность и adversary-порядок сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только адресная строка новых critic-задач.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 добавляется только step 164; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 добавляется только строка 164.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 добавляется только замер 164.
ПРОВОДКА:
- guard=fixtures/workshop_project/sudimyy_klass_riska_164/probe.py
ПРОВОДКА-ЭНФОРСМЕНТ: новый чисто механический guard-канал `check_judged_risk.sh` сопоставляет два уже сформированных решения и привязывает их к принятому blob; семантическое обязательство существующей роли critic не меняется.

## Незаполненные требования:
нет
