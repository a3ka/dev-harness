ПРЕДМЕТ: n-151-ci-marshrut-bez-sekreta
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: Контракт 151 (ветка wip/151/architect, дельта Arch151y afe421f9731498aeea2f600df4430fca823d07f6) требует
  исполнять красную батарею отдачи на РЕАЛЬНОМ jest-expo продукта (`W --stabs --runtime R`, R = клон приватного
  a3ka/Complior-mob с node_modules); в харнесс-CI (публичный a3ka/dev-harness, чистый чекаут, secrets=0) продукта
  нет. Автор объявил в ПРЕДПОСЫЛКАХ `secret COMPLIOR_MOB_READ_TOKEN` (read-only токен на приватный продукт,
  checkout по SHA-пину + npm ci) — это блокирует `check_predposylki.sh --freeze` и требует санкции владельца на
  выдачу токена. Варианты: (А) завести секрет (выделенный fine-grained read-only PAT на Complior-mob в публичном
  репо: риск утечки в логи/форк-PR; решение владельца); (Б) БЕЗ секрета: продуктовый режим батареи исполняется в CI
  ПРОДУКТОВОГО репо (Complior-mob, PR реализации): job продукта делает checkout ПУБЛИЧНОГО a3ka/dev-harness по
  SHA-пину и запускает `red_gespraech_otdacha_151.sh --stabs --runtime "$GITHUB_WORKSPACE"`; харнесс-CI батарею 151 не
  гоняет (честно в НЕ ЗАЩИЩАЕТ); (В) вендорить в fixtures минимальный снимок продукта (jest-пресет + нужные файлы) —
  размер/дрейф, нарушает «реальный субъект». РЕКОМЕНДАЦИЯ оркестратора: (Б) — секрета нет, доступ к приватному
  репо не расширяется, продуктовый CI уже исполняет продукт; цена — изменение workflow Complior-mob (зона
  продуктового CI, контракт 143/122 лекало) и то, что harness-CI не видит дрейф батареи 151.
РЕКОМЕНДАЦИЯ: вариант Б при явной продуктовой проводке в существующем jobs.quality и внешней оговорке 994; обязательны --stabs И --repo, полный принятый H-пин и отсутствие маскировки отказов. А — только при отдельном решении владельца о новом доступе; В не сохраняет требование реальной среды продукта.

РЕШЕНИЕ: Б

Модель-факт: фактическая модель сессии — openai-codex/gpt-6-astra; config/agent_models.json разрешает tiers.consultant.model=@gpt-astra именно в этот id. Арбитражного файла по этому предмету в проверенном verdicts/arbitration нет. Это инженерная рекомендация по существующим механизмам 123/143/994, не разрешение владельца на секрет или изменение merge-policy. Сохранена обязательная шапка роли; поле РЕШЕНИЕ следует за ней.

## 1. Проверено по дереву, а не по отчёту

Основной срез харнесса: afe421f9731498aeea2f600df4430fca823d07f6 из указанного architect-worktree. Живой GitHub main продукта на момент чтения: 6240f6306c55213fdcb4c508b480eefbb75d2c62. Его .github/workflows/mobile.yml получен через GitHub Contents API с ref=этот SHA: blob d97142d71a865844d194f1d0bf1f5b191384b97f, SHA256 файла 6137aa571ace1147ae1a29884c98008620c3b329eebf83617b5a971d57d0405e. Копия для проверки — /tmp/dev-harness-verify/Consult151c/product-mobile.yml. Старый /home/harness/projects/Complior-mob имеет ещё монолитный android-e2e; его НЕ использую как доказательство текущего main.

| Предмет | Selftest в CI харнесса | Реальная продуктовая среда / CI |
|---|---|---|
| 145 | registry/ci-steps.tsv:137: check:faden-dvizok-145-family-selftest, red_faden_dvizok_145.sh --stabs | В product main есть три faden test-файла. jobs.quality исполняет npm ci и npm test. Контракт 145 прямо разделяет численную батарею и живой TSX/jest-expo; --live-component — отдельная приёмка, не вся harness-матрица в product CI. |
| 143 | registry/ci-steps.tsv:139: check:mob-ci-razdelenie-143-family-selftest, red_mob_ci_143.sh --stabs | Субъект — реальный mobile.yml + selector/aggregate/карта. В main уже есть select-screens, quality, build-apk, пять legacy экранных задач и два агрегата. Сам red_mob_ci_143.sh в product workflow не вызывается; исполняется поставленный DAG. |
| 147 | Строки selftest 147 в проверенном реестре НЕТ; контракт обещает будущую проводку, это не доказательство уже подключённого шага. | В main экрана ещё нет. Открытый PR #146, d5c9f740fe4cd23e1f5f2ac37139bf08fba9b52b: quality/npm test; e2e-gespraech-vhod; публичный checkout .harness147 по 75edd4ecb3d4fad0a30bcdc840da339f7c161dbd. Продуктовые канон/экранный job не равны harness-selftest. |
| 149 | Строки selftest 149 в проверенном реестре НЕТ; наличие раздела ПРОВОДКА в контракте не означает живой шаг. | Открытый PR #148, 814242d77ace2244ed2392697bba1e9c792bfce3: quality/npm test; e2e-gespraech-tekst; checkout .harness149 по d01c9414ef792ea1382750c825759ab51a418ff4. В product main этого job ещё нет. |

Пауза 147/148/149 сохраняется. Прочитаны головы PR, но их CI не запускался и успешность живых runs этой консультацией не удостоверяется. Номера контрактов и PR не смешивать: контракт 147 — PR #146; контракт 149 — PR #148; PR #149 — демо.

Прецедент публичного checkout уже есть в принятом main, не является проектированием нового канала доступа:
- quality: actions/checkout@v7, repository=a3ka/dev-harness, ref=b9b4c66f3d84dc8aa7eb7c8e83b466e807817416, path=.harness, persist-credentials=false; отдельные .harness117/.harness117b.
- e2e-splash: .harness123 с ref=5d98a1cd745ce08eeb21b89f8e05750c4e769a0e; затем python3 .harness123/scripts/sverka_maketa.py. Контракт 123 описывает именно продуктовый энфорсмент и отдельно автономный selftest харнесса.
- .harness/project-layer.json продукта содержит projectId=Complior-mob. Recursive tree main показывает только этот файл и .gitkeep в workflow-каталогах: .harness/ci.json и .harness/harness.project.json там НЕТ. Поэтому 122 — лекало предполёта/предпосылок, а НЕ основание объявлять mobile.yml уже сгенерированным или мигрировать продукт на генератор в 151. registry/ci-steps.tsv по 122/083 — источник CI самого харнесса, не реестр чужого workflow.

## 2. Достижимость Б и собственный smoke

probe.py:main выбирает runtime = --runtime, иначе --repo, иначе MOB_151_RUNTIME. Абсолютный GITHUB_WORKSPACE продукта годится непосредственно: переносить весь продукт рядом с харнессом не требуется.

Что читается из R:
1. mobile/node_modules/.bin/jest — обязательный установленный раннер.
2. docs/ux/04_Gespraech_D24/motion/haptics.json — проверяются SHA256 оригинального дизайнерского файла и равенство извлечённых строк оракулу харнесса. Для --stabs файл тоже обязателен.
3. mobile/jest.config.js, mobile/jest.setup.ts, mobile/package.json — копируются в одноразовый temp-root; его node_modules — symlink на R/mobile/node_modules. Не копируются весь src, babel/tsconfig/metro и произвольные относительные зависимости setup/config. В прочитанной реальной среде jest.config.js использует preset=jest-expo, jest.setup.ts задаёт кадровые часы без внешних относительных импортов. Неиспользуемый @pilot/runtime alias не доказывает пригодность будущих импортов за пределами модуля.
4. --repo дополнительно читает mobile/src/lib/otdacha/index.ts, копирует его каталог (без *.test.* и __tests__) в temp/src/lib/otdacha; проверяет package.json/package-lock.json, Expo bundledNativeModules.json и установленный expo-haptics/package.json. Модуль должен быть самодостаточным в своей зоне; окружение всего приложения песочница не переносит.
5. --stabs судит модель и мутанты ИЗ H, а не реализацию продукта. Он читает Expo bundledNativeModules.json для dependency-stab, но не требует уже поставленного продуктового модуля или реального установленного expo-haptics для этой синтетической проверки metadata. Поэтому один --stabs НЕ является приёмкой реализации; обязателен --repo того же workspace.

Собственный запуск (из R/mobile, то есть с таким же default working-directory, как у продукта):

```text
R=/tmp/dev-harness-verify/Impl147e/mob
GITHUB_WORKSPACE=/tmp/dev-harness-verify/Impl147e/mob PYTHONDONTWRITEBYTECODE=1 bash /tmp/dev-harness-worktrees/c907157c/wip-151-architect/fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh --stabs --runtime /tmp/dev-harness-verify/Impl147e/mob
rc=0
18 строк STAB ... KRASEN
SVJAZI 18 CASE 765
wall=27.95 s
```

Вызов передал абсолютное значение GITHUB_WORKSPACE как аргумент; shell-разворачивание переменной в GitHub не является отдельным механизмом пробы. Это реальный Jest-прогон батареи из внешнего H с runtime продукта, без эмулятора, нативной сборки, npm install и записи в checkout. Temp-песочницы создаёт/убирает сама проба. Это НЕ успешный --repo будущей реализации, НЕ полный quality-job и НЕ доказательство исполнения GitHub workflow. Разбор сопоставлений стабов остаётся у architect по коду (Н-39); новые привязки этим текстом не задаются.

## 3. Почему не А и не В; граница воли владельца

gh repo view независимо подтвердил: a3ka/dev-harness PUBLIC, a3ka/Complior-mob PRIVATE. Отсутствие нового секрета и отказ freeze уже сообщены Arch151y; не повторял эти проверки, чтобы не выдавать подтверждение известного отказа за новую работу.

А не означает, что любой fork-PR автоматически получает PAT. GitHub на обычном pull_request из fork НЕ передаёт repository secrets (кроме ограниченного GITHUB_TOKEN). Поэтому А одновременно имеет две разные проблемы:
- честный fork-PR не получит приватный R и не сможет выполнить заявленную обязательную батарею;
- попытка обойти это через pull_request_target/привилегированный запуск кода PR создаст канал к секрету И к уже скачанному приватному исходнику. Даже read-only PAT защищает от записи, не от чтения/эксфильтрации. Маскирование токена не маскирует исходники, произвольные преобразования данных, логи и артефакты. SHA-пин R не делает код проверяемого PR доверенным.

В текущем harness ci.yml события push/main и pull_request, checkout читает head.sha PR. Новый доступ в этом контуре — именно ВОЛЯ/ДОСТУП ВЛАДЕЛЬЦА; консультант его не санкционирует. Б не требует такого решения: приватный код остаётся в уже существующем CI приватного продукта; публичный H читается штатным checkout без нового PAT. Б не отменяет существующие риски self-hosted/исполнения кода PR и не меняет required checks. Если интеграции понадобится изменение защищённых путей/прав, его разрешение оформляется отдельно; обход защиты не разрешён.

Источник поведения fork secrets и риска pull_request_target: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows (разделы Workflows in forked repositories и pull_request_target; прочитаны).

В может стать отдельной автономной модельной проверкой, но не заменяет обещанный реальный jest-expo R; поддерживаемый снимок пресета/SDK вводит второй источник среды и дрейф. В рамках данного вопроса не рекомендую.

## 4. Дословные правки contracts/151-gespraech-otdacha.md

Ниже — предложение владельцу предмета; файлы контракта, батареи и workflows мной НЕ изменены.

### 4.1. Заменить поле ПРЕДПОСЫЛКИ целиком

```text
ПРЕДПОСЫЛКИ:
- setting продукт: Expo SDK 57, Node по .node-version продукта, Python 3.12, установленный jest-expo и зависимости mobile/node_modules после npm ci --no-audit --no-fund в mobile; дизайнерская копия docs/ux/04_Gespraech_D24/motion/haptics.json принадлежит тому же checkout продукта. expo-haptics добавляет implementer совместимой Expo-установкой с lockfile; --repo судит реализацию, package.json, lockfile и установленную зависимость этого checkout.
- setting CI продукта: существующая задача quality в a3ka/Complior-mob/.github/workflows/mobile.yml получает отдельный checkout публичного a3ka/dev-harness в .harness151 по полному 40-hex SHA принятой ревизии с батареей 151; persist-credentials: false. Общие H-пины и чужие пробы не меняются. R = абсолютный GITHUB_WORKSPACE продукта, не каталог .harness151 и не произвольный workspace станции. Новых секретов, variables, environments, прав репозитория и required checks нет; COMPLIOR_MOB_READ_TOKEN не нужен и не заводится.
- setting порядок product quality: после существующих setup-python/setup-node и npm ci, до копирований workspace и выноса файлов для lint — checkout .harness151, затем из корня продукта W --model --runtime R, W --stabs --runtime R и W --repo R; W здесь = bash .harness151/fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh. Все три команды обязательны в PR реализации и последующих запусках workflow, без continue-on-error, условного пропуска или подавления rc. После успешных проб .harness151 выносится из workspace до остальных копирований и structure/lint, по существующему продуктовому правилу выноса H. Песочница читает реальные jest.config.js/jest.setup.ts/node_modules R, но не переносит остальной src приложения; модуль и его карта остаются внутри mobile/src/lib/otdacha/.
- setting CI харнесса: батарея 151 не включается в registry/ci-steps.tsv и .github/workflows/ci.yml, приватный продукт туда не скачивается. Проводка оформляется существующим исключением внешнего CI контракта 994; это не подтверждение успешного product CI. До заморозки architect предъявляет локальные --model/--stabs на реальном R; после реализации orchestrator предъявляет продуктовый SHA, H-пин и живой результат всех трёх команд quality. До этого продуктовая проводка не считается исполненной.
- setting границы CI: 151 добавляет шаги существующего quality, не новую job и не экранного работника; карта mobile/ci-screens.json, selector, aggregate, jobs/needs, эмуляторы и APK не меняются. Предполёт продуктовой дельты выполняется по 122 с явным working-directory корня продукта для проб; full-workflow --contract проверяет секреты всех jobs, поэтому существующий PILOT_DEMO_CODE остаётся объявлением продуктового контекста, а не новым секретом 151 в публичном харнессе.
- setting пауза: перед любым подключением перечитать registry/pauzy.tsv; до снятия строк 147/148/149 экранные зоны read-only. Изменение только CI-проводки независимого модуля не разрешает подключать его к экранам и не решает открытые вопросы владельцу о системных флагах и границе done.
```

Почему нет `- secret PILOT_DEMO_CODE` вместо удалённого секрета: workflow-wide preflight 122 действительно видит старый секрет e2e-pilot, но добавление его в harness-контракт с freeze против origin харнесса создало бы новый ложный блокер. Существующий секрет продукта декларируется/проверяется в продуктовом контексте; не предоставляется quality/151. Для локальной консультации полный предполёт не запускался (он не равен трём Jest-командам и может затронуть запрещённые в задании нативные этапы).

### 4.2. Заменить ПРОВОДКА и её первый ЭНФОРСМЕНТ-абзац

```text
ПРОВОДКА:
- guard=fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh
ПРОВОДКА-ЭНФОРСМЕНТ: Общий CI dev-harness не получает зависимость от внешнего checkout. Предметный энфорсмент — три обязательных запуска W --model --runtime R, W --stabs --runtime R и W --repo R в существующем quality CI a3ka/Complior-mob, R = абсолютный GITHUB_WORKSPACE продукта; H — отдельный полный SHA-пин принятой батареи 151. --model/--stabs судят контроль и обманки в настоящей Jest-среде, --repo судит поставленный модуль и зависимость; один --stabs не является зеленью реализации. Orchestrator подключает продуктовые шаги после реализации и предъявляет живой результат по продуктовой голове и H-пину; ненулевой rc любого запуска краснит quality и существующий required-агрегат. Новой нормы ролей или устава нет. Оговорка внешнего CI по 994 освобождает только от локальной harness-step и не удостоверяет внешнее исполнение.
```

Первое предложение ЭНФОРСМЕНТ — ТОЧНАЯ поддерживаемая фраза 994. scripts/check_provodka.sh:542–594 сравнивает фрагменты по `.`/`;` с закрытым перечнем: произвольное «запускается в продукте» не сработает. Никакого изменения check_provodka, фиктивной external-строки TSV или stub-step не требуется.

### 4.3. Добавить в НЕ ЗАЩИЩАЕТ, сохранив существующий пункт

```text
- дрейф батареи 151 на новых коммитах dev-harness до обновления принятого H-пина в CI продукта: harness-CI эту батарею не исполняет, а продукт продолжает судиться закреплённой ревизией. Ловец — architect на реальном R при изменении батареи и product quality при адресном перепине; автоматического межрепозиторного запуска и синхронизации H нет. Публикация новой батареи без такого прогона не считается доказанной зеленью.
- наличие и успешность внешней CI-проводки одной лишь зеленью check_provodka.sh: исключение 994 проверяет существование guard и форму оговорки, не GitHub run. Ловец — просмотр продуктового diff и живой quality по точным product SHA/H SHA с успешными --model/--stabs/--repo без маскировки отказов. Подлинность GitHub-раннера, всего npm dependency supply chain и изоляция от злонамеренного кода общего uid не доказываются Jest-песочницей 151.
```

Существующий пункт про JS-realm, физический эффект, флаги OS, earcons и открытое слово владельца оставить без изменения. Выбор Б не закрывает ни одну из этих границ.

### 4.4. Зона orchestrator: убрать неиспользуемые пути, назвать продуктовый root

Удалить существующую строку `ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml` и ВСЕ непосредственно относящиеся к ней строки `ПЕРЕСЕЧЕНИЕ orchestrator:` для этих трёх путей. Не добавлять «внешнюю» строку в TSV и не материализовывать ci.yml ради 151.

Вместо них:

```text
ЗОНА orchestrator: .github/workflows/mobile.yml
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 143 только checkout и шаги батареи 151 в существующем quality с адресным выносом собственного .harness151 до копирований/structure/lint; набор jobs, карта, selector, aggregate, needs и тела экранных работников не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 995 отдельный H-пин 151; общий .harness, его пин, cmp и пробы 995, приватный код e2e-pilot и изоляция раннера не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 999 пробы навигации и их H-пин не меняются; только добавление шагов 151 в quality.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 108 пробы Start и экранный работник не меняются; только добавление шагов 151 в quality.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 111 пробы first-run и их порядок не меняются; только добавление шагов 151 в quality.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 117 пины .harness117/.harness117b, пробы и экранный работник не меняются; .harness151 выносится до копирования их disposable R.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 118 same-job Jest, checker, пробы, H-пин и экранный работник не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 123 checkout .harness123, сверка кадров, её размещение и пороги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 135 тело экранной приёмки, H-пин и работа с кадрами не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 141 экранные повторы и восстановление не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 107 существующие шаги своего предмета не меняются; только добавление шагов 151 в quality.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 991 репетиция и её гейты не меняются; только добавление шагов 151 в quality.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 147 пауза сохраняется, экранные шаги/канон/пин не меняются; добавляется только CI независимого модуля 151.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 148 пауза сохраняется, экранные шаги/канон/пин не меняются; добавляется только CI независимого модуля 151.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/mobile.yml — 149 пауза сохраняется, экранные шаги/канон/пин не меняются; добавляется только CI независимого модуля 151.

Корень зоны orchestrator .github/workflows/mobile.yml — a3ka/Complior-mob, НЕ a3ka/dev-harness. Зона исполняется отдельным продуктовым PR по project_workflow-контексту Complior-mob; контракт/свидетельства остаются в назначенных workflowPaths, установка харнесса не становится местом записи продуктового state. При интеграции перечень пересечений сверяется с union действующих заморозок продукта; разрешение защищённого пути оформляется его штатной процедурой. Существующие зоны architect и implementer 151 остаются без изменения.
```

Это РЕАЛЬНОЕ расширение продуктовой CI-зоны, а не только изменение текста ПРЕДПОСЫЛКИ. Его должен получить исполнитель продуктового PR; консультант этот PR не делает. Новый job `haptics-151` не предлагается: инвентарный инвариант 143 требует jobs == служебные + работники карты, а 151 не экран. Шаг внутри quality сохраняет действующий DAG и наследует существующий required-агрегат через quality.

### 4.5. Согласовать «Порядок» и приёмку, иначе контракт останется противоречивым

Заменить весь абзац, начинающийся `Порядок: architect — W красен`, следующим:

```text
Порядок: architect — W красен, W --model и --stabs зелены на реальном Jest-пресете R → critic → freeze → implementer — только зона модуля/зависимости, W --repo R зелён → orchestrator подключает три обязательных запуска батареи в существующем quality продуктового CI через отдельный опубликованный SHA-пин H → независимый суд. До подключения все три режима предъявляются на локальном R, но зелень CI не заявляется. CI харнесса не скачивает продукт и батарею 151 не запускает. Продуктовый PR реализации проверяет собственный checkout как R, не старый product main. Принятый H-пин обязан содержать батарею 151; локальный неопубликованный SHA ветки и изменяемое имя ветки не являются окончательной проводкой. Зоны экранов 147/148/149 на паузе, их подключение не входит в done первой поставки и вопросы владельца о толковании флагов и объёме done остаются открытыми.
```

В п.4 «Приёмка» сохранить команды остальных гейтов; заменить фразу от `bash scripts/check_provodka.sh ... до CI-строки` до конца предложения:

```text
bash scripts/check_provodka.sh . contracts/151-gespraech-otdacha.md → rc 0 при существующем guard и точной внешней оговорке 994; результат не свидетельствует о запуске CI продукта. Проводка считается исполненной только после продуктового diff с отдельным полным H-пином и живого quality на PR реализации: W --model --runtime R → rc 0, CASE 765 GREEN 765 RED 0; W --stabs --runtime R → rc 0, SVJAZI 18 CASE 765; W --repo R → rc 0, CASE 765 GREEN 765 RED 0. Product SHA, H SHA и run URL обязательны в свидетельстве интеграции; отсутствие или пропуск любого запуска не является зеленью 151.
```

765/18 здесь сохранены из текущей исполняемой батареи; это числа приёмки этой версии, НЕ новая таблица stab→ветвь. При адресной правке батареи architect обновляет числа из кода и собственного прогона.

## 5. Точная форма продуктовой дельты и остаток

Требуемый продуктовый diff — только .github/workflows/mobile.yml: в quality сразу после существующего npm ci добавить checkout публичного H в .harness151 с persist-credentials=false и буквальным полным SHA принятой опубликованной поставки; затем шаг с working-directory: ${{ github.workspace }} и телом:

```bash
set -euo pipefail
W="$GITHUB_WORKSPACE/.harness151/fixtures/workshop_project/gespraech_otdacha_151/red_gespraech_otdacha_151.sh"
bash "$W" --model --runtime "$GITHUB_WORKSPACE"
bash "$W" --stabs --runtime "$GITHUB_WORKSPACE"
bash "$W" --repo "$GITHUB_WORKSPACE"
mv "$GITHUB_WORKSPACE/.harness151" "$RUNNER_TEMP/harness151-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"
```

Вынос сразу после проб нужен не только для lint: существующие старые пробы сначала копируют весь workspace в disposable R. Не стоит разносить новый checkout по этим копиям и затем чинить чужие structure-гейты. После падения пробы quality уже красный, никакого `|| true`/skip не требуется. Шаг не является native-build или e2e. Выбор окончательного H SHA — факт принятия и публикации будущей пачки, его нельзя честно подменить сегодняшним неопубликованным afe421f9 из отчёта.

Остаток до поставки Б: продуктовый workflow ещё НЕ изменён, опубликованный окончательный H-пин не выбран, --repo реализации и живой GitHub quality не доказаны этой консультацией. Это обязанности реализации/интеграции, а не основание вернуть инженерный выбор владельцу за новым PAT. Открытые вопросы владельцу о флагах и done независимы от CI-маршрута и сохраняются. Ни эмулятор, ни native build, ни общепроектный test/lint/format не запускались; checkout-файлы не правились, коммита нет по read-only заданию. Доставка файла в main — оркестратор.

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git show afe421f9731498aeea2f600df4430fca823d07f6:contracts/151-gespraech-otdacha.md
RC: 0
ВЫВОД-SHA256: c44fb07e376b51bf63d272f4f0e823a0ada0fd0d850eee73b8b7391ca910572e
КОМАНДА: git show afe421f9731498aeea2f600df4430fca823d07f6:fixtures/workshop_project/gespraech_otdacha_151/probe.py
RC: 0
ВЫВОД-SHA256: b654c88476fa0452d0d4da099091b209e15959010e08daffe6f8715583cf7ab3
КОМАНДА: git show afe421f9731498aeea2f600df4430fca823d07f6:registry/ci-steps.tsv
RC: 0
ВЫВОД-SHA256: 532bb36ddd19ad9896506f263bffdc9eaa2e35805839067ffce1b8ae09f663ae
КОМАНДА: git show afe421f9731498aeea2f600df4430fca823d07f6:scripts/check_provodka.sh
RC: 0
ВЫВОД-SHA256: 0e947d70d0e6293b4fbdc48096788aa8a8ffc662ebe50484d4ba3583b489dab8

Команды исполнены мной в указанном architect-root в очищенной среде PATH=/usr/bin, LC_ALL=C.UTF-8, GIT_CONFIG_GLOBAL=/dev/null, GIT_CONFIG_SYSTEM=/dev/null, GIT_OPTIONAL_LOCKS=0; git с core.hooksPath на пустой временный каталог ВНЕ дерева. SHA256 рассчитан от объединённого stdout+stderr с удалёнными хвостовыми LF. verify_consultant.sh не запускался на checkout: он пишет .v029-config-scan в проверяемый root, что нарушило бы read-only ограничение задания. GitHub/API и Jest smoke приведены отдельно, не под видом разрешённых readonly-команд блока 029.
