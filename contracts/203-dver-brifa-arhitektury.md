# Контракт 203 — дверь закреплённого брифа архитектуры: зависимости пина, причина отказа из ответа модели, id «АРХИТЕКТУРА:» по пину, кап pack.maxBytes

КЛАСС ЗАДАЧИ: КОДОВЫЙ (контракт + красная батарея; реализация — implementer по красным клеткам).
КЛАСС РИСКА: обычный — сборка контекста задания и гейт заморозки контрактов получают новые ОТКАЗНЫЕ ветки; права/роли БД, авторизация, безопасность продукта, деньги, ПД/health и согласия, юридически значимые действия не меняются. Проверка п.3 (гейт freeze ПО id архитектурных элементов) НЕ решает допуска: она только отказывает строкам с id, которых нет в закреплённой модели, либо пропускает их прежним порядком — ложный PASS равен статус-кво до 203 и ловится клетками/ревьюером, ложный REFUSE заметен на первой заморозке и в регрессе 187.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — ремонт станционных дверей make_task/freeze/check_architecture_contract; проектной модели станция не несёт.
КОНТЕКСТ: Н-454 (NABLIUDENIA.md); слово владельца R-0071 через консультанта m2345 — объём ПЕРЕПИСАН: ровно четыре пункта (зависимости выгрузки пина; причина отказа целиком из ответа модели; id строки «АРХИТЕКТУРА:» только элементы модели по пину; кап 40000 снят в пользу pack.maxBytes), старый объём 20.11 (видимый stderr + ARCH_BRIEF_BUDGET при капе 40000) этим контрактом заменён; задание оркестратора /tmp/dev-harness-verify/task-architect203.md — источник раздачи, не зависимость прогона. Упаковка крупного брифа вне пака — отдельный v+1 170, в 203 не входит.
СДАЧА: fixtures/workshop_project/dver_brifa_203/SDACHA.md

## Существующее

Сверено по коду на базе e767f5132c2c2d40064d7bf374ea9aaa152b1b89 (origin/main на старте пачки) и по frozen-блобам живьём (`git show frozen/contracts/<N>/<v>^{commit}:<файл>`).

1. **Выгрузка пина живёт в одном шве** — `scripts/check_architecture_contract.sh:173–232` (`arch187_model_prepare`): pin-грамматика → клон (ARCHITECTURE_ROOT либо `.clone` из lock) → `git archive <pin> | tar -x -C $tmp` (строки 214–218) → проверка `tooling/checks/cli.js`. `git archive` НЕ несёт node_modules, и все вызовы CLI (`:305` snapshot, `:384` locate, `:519–521` brief, `:574` check) падают «Error: Cannot find module 'acorn'» (замер консультанта по Н-454: rc 0 вернулся только с симлинком node_modules из установленного клона). Дорабатывается этот шов; второй сборщик модели не заводится.
2. **Причина отказа brief глотается** — `arch187_brief` (`scripts/check_architecture_contract.sh:509–542`): stderr модели снимается в файл, в отказ печатается ПЕРВАЯ непустая строка (`:536–537`). Настоящий CLI модели при отказе печатает stderr МНОГОСТРОЧНЫЙ JSON-отчёт `{status:"FAIL", scope:"ARCHITECTURE_TOOL_INPUT", findings:[{code,message}]}` (`tooling/checks/cli.js:540–556` пина; генератор — `main()`), первая строка — «{». Замер на базе: make_task с отказывающим брифом печатает `ARCH_BRIEF_STDERR: {` и `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id> (закреплённая модель не отдала бриф)` — код и сообщение модели теряются. Заодно модель сама отвечает членство: `tooling/checks/brief.js:12–16` пина бросает `UNKNOWN_ARCHITECTURE_ELEMENT` с сообщением «Unknown architecture element: <id>» для id вне `model.elements`.
3. **Строка «АРХИТЕКТУРА:» судится только грамматикой** — `arch187_line` (`scripts/check_architecture_contract.sh:626–678`): уровень L1|L2|L3, алфавит id, дубли, L3→владелец; членства в модели НЕТ. Потребители строки: `arch187_check_text` (`:864–878`) ← `scripts/make_task.sh:1039` (задание) и `scripts/freeze_contract.sh:315` (заморозка), публичная дверь `:946–952`. Замер по выгрузке snapshot клона модели на станции (HEAD 954ad4c1, снимок 7; 71 элемент, 22 `resource.*` — РЕСУРСЫ, не элементы): в конформных строках контрактов бэкенда /home/harness/projects/Complior-back/.harness/contracts не-элементы: 175 `contract.public-http`; 179 `resource.authentication`; 180 `api.notifications`,`resource.mission`,`resource.notifications`,`resource.command-journal`,`resource.resource-registry`; 181 `resource.identity` — 8 по клоно-снимку в 4 контрактах (слово владельца «8 в 5» — по пину бэкенда; точный перечень по пину даёт сама модель в прогонах двери, не этот текст). Все они сегодня проходят гейт заморозки.
4. **Кап пака уже эффективный, не 40000** — `scripts/make_task.sh:576–589`: `MAX` читается ОДНИМ вызовом profile_resolver из `.pack.value.maxBytes` (умолчание 40000 только для профиля без ключа), проверка pack_body — `:1170–1171` `[ "$VK" -le "$MAX" ] || die "режь задачу: $VK > $MAX"`. Форму и диапазон [40000,1000000] судит резолвер (`scripts/profile_resolver.sh:901–930`). Пришло Б-4 22.11 (коммит 737679184) — ПОСЛЕ замера Н-454(б). Замер этой пачки на автономном мире: pack.maxBytes=260000 + бриф 91 445 байт → rc 0, пак 93 255 байт, `BUDGET: vklejka=92909/260000`; pack.maxBytes=60000 → rc 1 `режь задачу: 92909 > 60000`; профиль без ключа → rc 1 `режь задачу: 92909 > 40000` (frozen 170/1:29 ожидает именно это). Настройку `pack.maxBytes` несёт профиль проекта (Complior-back `harness.project.json`: `"pack": {"maxBytes": 260000}` — прочитано по факту); в самом репозитории модели ключа нет (git grep по пину пуст). Ветки ARCH_BRIEF_BUDGET в production НЕТ (grep по scripts/ — 0) — она была обещана только черновиком 203 и этим контрактом НЕ вводится.
5. **Frozen-соседи по швам** (живьём по тегам): 170/1 `272e756d8` — inline-бриф каждого запуска в contextPack, порядок входных ID, роли `--with-rules`, сценарий over-budget `режь задачу: … > 40000`; 187/3 `ac91200c8` — pin-грамматика, locate/зоны, snapshot-признак, check --base, семантика arch187_brief/stderr потреблена батареей `brief_stderr.py` ПОБАЙТНО (префикс `ARCH_BRIEF_STDERR: `, первая непустая строка для не-JSON stderr, константа «(stderr модели пуст)», строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id> (закреплённая модель не отдала бриф)`); 188/2 `857d7b11d` — роли читают полный бриф (схемы/инварианты/writers/isolationKeys); 189/1 `b8d02f499` — валидаторы/канон, не сборка брифа; 185/1 `b95f2abf6` — pre_judge проекта (разблокируется починкой 187а-шва, не текстом 203); 186/2 `1b515ada8` — хранитель архитектуры, merge_architecture_pr/check_architecture_pin, make_task не владеет; 196/1 `c0ec72e34` — CI-артефакты ops. Открытых PR на scripts/make_task.sh и scripts/check_architecture_contract.sh нет (gh pr list a3ka/dev-harness, 2026-11-25).
6. **Батареи-соседи** (не дублируются): `fixtures/workshop_project/architecture_process_187/` (дверь целиком, stderr-батарея brief_stderr.py, сигналы brief_signals.py), `fixtures/workshop_project/arch_component_170/` (npm-ветвь 170). Новая семья `fixtures/workshop_project/dver_brifa_203/` судит ТОЛЬКО четыре предмета 203 и переиспользует world/put/git из 187 (как черновик).

## Frontier-выборы

Спорное место (1) — установка зависимостей выгрузки пина:
- **ВЫБРАНО: симлинк `$tmp/node_modules → node_modules установленного клона при побайтовом равенстве `package-lock.json` выгрузки и клона.** Боль: Н-454 — «Cannot find module 'acorn'» на каждом вызове CLI пина; измерение консультанта: с симлинком rc 0. Офлайн, мгновенно, lock-равенство — сильнейшее доступное без сети свидетельство совпадения набора модулей; клон — доверенная предпосылка станции (как и verify-pin).
- Отклонено: `npm ci --ignore-scripts` в выгрузке — сеть/кеш в двери (CI и станция герметичны по PATH, батарея обязана быть офлайн), десятки секунд на каждый прогон двери, исполнение дерева пакетов npm из PATH вызывающего.
- Отклонено: `NODE_PATH` — прямо отклонён владельцем (R-0071: «без NODE_PATH»).

Спорное место (3) — источник множества элементов:
- **ВЫБРАНО: запрос к CLI модели ПО ПИНУ — краткий `brief --compact --component <id>` для каждого id строки (stdout отбрасывается).** Боль: 8 не-элементов проходят гейт заморозки. Членство определяет САМА модель (`brief.js:12–16` пина: ровно `model.elements`), второй парсер/список не заводится; rc 0 — элемент, ответ с кодом `UNKNOWN_ARCHITECTURE_ELEMENT` — положительный вердикт «не элемент».
- Отклонено: чтение lock/реестра файла — измерено: `architecture.lock.json` (7 ключей: format/repository/commit/snapshot/snapshotDigest/status/workItem) и `harness.project.json` элементов НЕ несут; файл-список — второй источник, расходящийся с моделью молча.
- Отклонено: разбор `.model.elements` из `snapshot --out` — выгрузка 187-battery toy-модели несёт только `model.logicalModules` (замер `snapshot_export`): требование элементов сломало бы замороженную батарею 187; членство по brief не зависит от формы snapshot.
- НЕДОСТУПНОСТЬ модели (клон/pin/зависимости) — fail-closed именованными отказами ШОНА (`ARCH_PIN`, `ARCH_BRIEF_DEPS`), не молчаливый пропуск (правило 7 AGENTS); ответ модели без кода членства гейт не сужает — ловец в «НЕ ЗАЩИЩАЕТ».

## Предмет и инварианты

Готово означает один наблюдаемый результат: make_task собирает пак с полным закреплённым брифом в границах pack.maxBytes, а отказы двери несут причину из ответа модели; неизвестный архитектурный id не проходит ни строку «АРХИТЕКТУРА:», ни флаг.

1. **Зависимости выгрузки пина ставит сама дверь** (`arch187_model_prepare`). Если выгрузка пина несёт `package-lock.json`: при побайтовом несовпадении с `package-lock.json` установленного клона (включая его отсутствие — `cmp -s` даёт rc≠0), либо при отсутствии в клоне `node_modules`, либо когда пакетный манифест выгрузки объявляет runtime-зависимости без lock — rc 1 `ОТКАЗ: ARCH_BRIEF_DEPS: <факт>; npm ci на закреплённом пине`, выгрузка удаляется, ни один вызов CLI не исполняется. При равенстве lock и наличии `node_modules` дверь подключает их выгрузке сама (симлинк на абсолютный путь `node_modules` клона); cleanup удаляет только свою выгрузку — донор не трогается. Дерево без lock и без runtime-зависимостей исполняется как прежде, без заимствования чужих node_modules. Сеть дверь не использует.
2. **Причина отказа brief — целиком из ответа модели (код + сообщение).** При rc≠0 CLI или пустом stdout брифа stderr модели разбирается ЦЕЛИКОМ: ответ вида JSON-объект с непустым `findings[0].code` даёт строку причины `<code>: <message>` (CR/LF/TAB нормализуются в пробел, в одну строку, без обрезки — id в конце сообщения не срезается); вне грамматики — прежняя первая непустая строка stderr, пустой stderr — прежняя константа. Форма строки `ARCH_BRIEF_STDERR: <причина>` и строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: <id> (закреплённая модель не отдала бриф)` побайтово сохранены (потребитель — замороженная батарея 187 brief_stderr.py).
3. **id строки «АРХИТЕКТУРА:» — только элементы модели ПО ПИНУ.** После грамматики строки и развёртки выгрузки каждый id списка проверяется кратким brief из ВЫГРУЗКИ пина: rc 0 — известен; ответ модели с кодом `UNKNOWN_ARCHITECTURE_ELEMENT` — rc 1 `ОТКАЗ: UNKNOWN_ARCHITECTURE_ELEMENT: <id>` (сам id — в строке отказа), до зон и до вопроса о флаге; тег заморозки не ставится. Недоступность модели отказывает именованно раньше (`ARCH_PIN`/`ARCH_BRIEF_DEPS`). Гейт действует на make_task (задание), freeze_contract (заморозка) и публичную дверь; L3-ветка владельца не ослабляется. Флаг `--arch-component` отдельной предпроверки не получает: неизвестный id флага отказывает тем же кодом модели через инвариант 2 (проходит в stderr make_task).
4. **Кап пака — эффективный `pack.maxBytes`, ветки 40000 нет.** Читатель уже подключён (`make_task.sh:576–589`, один вызов profile_resolver): превышение — rc 1 `ОТКАЗ: режь задачу: <VK> > <MAX>` с тем лимитом; профиль без ключа сохраняет умолчание 40000 (frozen 170/1:29). Бриф >40000 и ≤ pack.maxBytes собирается полностью; NEW production-ветки для капа 203 не вводит, `ARCH_BRIEF_BUDGET` не заводится.

Демаркация: конформный вход — прежние профиль/класс/пин 187, алфавит id, npm package-lock.json, ответы CLI в грамматике пина; валидный контрпример = инвариантность к значениям (SHA, имена каталогов, длины брифов, тексты причин) при расхождении на конформном входе. Ожидания снимаются в память ДО вызова субъекта; диск субъекта после него не источник ожидания. Стабы к ветвям привязывает architect по коду в stabs.py, не проза этого текста.

## Приёмочный критерий

- Дано автономный мир с закреплённой моделью-заглушкой, строка задания «АРХИТЕКТУРА: L1 api.auth,resource.identity», `resource.identity` не элемент модели; когда `bash scripts/make_task.sh --repo <мир> --role architect --kind task --contract 777 --task-file <задание> --model-trace <трасса> --arch-component api.auth`; тогда rc 1, stderr несёт `UNKNOWN_ARCHITECTURE_ELEMENT` и `resource.identity`.
- Дано тот же мир, флаг называет неизвестный модели id; когда та же команда с `--arch-component resource.identity`; тогда rc 1, stderr несёт `UNKNOWN_ARCHITECTURE_ELEMENT` и `resource.identity` (код и сообщение из ответа модели).
- Дано мир-контракт со строкой «АРХИТЕКТУРА: L1 api.auth,resource.identity», коммит на HEAD, вердикт критика accept; когда `bash scripts/freeze_contract.sh .harness/contracts/777-work.md 'toy reason' <мир> <state>`; тогда rc 1, stderr несёт `UNKNOWN_ARCHITECTURE_ELEMENT` и `resource.identity`, тег `frozen/contracts/777/*` не ставится. Дано строка только из элементов модели по пину; тогда этот гейт проходится (заморозка не отказывает причиной членства).
- Правило: `bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --model` → rc 0; `--stabs` → rc 0 (все адресные предъявления пойманы, ZHIVYH=0); `--sintaksis` → rc 0.
- Дано поставленная реализация; когда `bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --repo .`; тогда rc 0. До реализации та же команда — rc 1, именованные красные клетки зависимостей, причины и членства (13 красных из 21; клетки капа и dependency-free — зелёный контроль), ошибка среды — rc 2, не доказательство дефекта.
- Правило регресса: `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` → rc 0; `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo .` → rc 0; `bash scripts/pre_critic.sh --repo . contracts/203-dver-brifa-arhitektury.md` → rc 0; `bash scripts/check_sdacha.sh . contracts/203-dver-brifa-arhitektury.md --run` → rc 0.
- Дано реализация и CI-проводка orchestrator; когда `bash scripts/gen_ci_steps.sh --check`; тогда rc 0; шаг `check:dver-brifa-203-family-selftest` запускает `bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --repo .`; замер команды — в ci-zamery.

## Модель угроз

ЗАЩИЩАЕТ:
- От исполнения закреплённого CLI без зависимостей либо с чужим/несовпадающим набором: lock выгрузки сравнивается с клоном побайтово до первого вызова CLI, отказ именован с рекомендацией.
- От потери причины отказа: строка ARCH_BRIEF_STDERR несёт код и сообщение модели целиком, не «{»; частичный пак при отказе не выдаётся.
- От прохождения неизвестного архитектурного id через строку «АРХИТЕКТУРА:» (задание, заморозка, публичная дверь) и через флаг: членство отвечает модель по пину своим кодом.
- От возврата капа 40000 для проектов с pack.maxBytes и от реинтродукции ветки ARCH_BRIEF_BUDGET: клетки капа краснеют на обеих мутациях.

НЕ ЗАЩИЩАЕТ:
- От повреждённого/злонамеренного node_modules клона при совпавшем lock: равенство файла не доказывает npm ci; установленый клон — доверенная предпосылка, ловец — verify-pin/CI проекта и reviewer.
- От молчания модели без кода членства (иной код, пустой ответ): гейт членства не сужает; ловец — реальный CLI всегда отвечает кодом, ревьюер реализации.
- От семантической неполноты самого брифа модели: 188 и reviewer по пину; 203 сохраняет весь stdout.
- От слишком малого pack.maxBytes в профиле проекта: отказ по тому лимиту передаёт решение оркестратору; смена значения — owner-слой профиля.

ПРЕДПОСЫЛКИ:
- setting bash, python3, git, jq, node, tar, cmp доступны станции и CI; новая батарея не требует сети и настроек репозитория.
- setting ARCHITECTURE_ROOT поставляет установленный клон модели (npm ci выполнен вне двери); станция запускает дверь в среде без NODE_PATH.

## Зоны и исполнители

ЗОНА architect: contracts/203-dver-brifa-arhitektury.md fixtures/workshop_project/dver_brifa_203/
ЗОНА implementer: scripts/check_architecture_contract.sh scripts/make_task.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

РАБОТА РАЗДАЁТСЯ: implementer получает красные клетки и эталонные якоря fixtures/workshop_project/dver_brifa_203/model.py (BASE e767f5132) как ориентир семантики, не как обязательный текст; судят клетки, не совпадение текста.

## Пересечения

ПЕРЕСЕЧЕНИЕ implementer: scripts/check_architecture_contract.sh — 187 только шов зависимостей/причины/членства; pin-грамматика, locate, зоны, snapshot-признак, check --base и rc-семантика двери не ослабляются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 170 только диагностика pinned brief (причина в stderr); inline/порядок/роли/legacy npm сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 187 только вызов arch187_brief; прочие ворота сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 103 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 136 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 161 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 166 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 168 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 169 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 184 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 996 только диагностика pinned brief; прежние карты, манифест и трассы сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только новая строка self-test 203 и её замер/генерат; чужие шаги сохранены.

(Перечень выведен из замороженных деревьев прогоном `python3 fixtures/workshop_project/dver_brifa_203/overlaps.py` на базе пачки: FROZEN=192, OVERLAPS=74; строки implementer для двух главных швов несут точные границы.)

## Проводка

ПРОВОДКА:
- guard=scripts/check_architecture_contract.sh
ПРОВОДКА-ЭНФОРСМЕНТ: чистый энфорсмент существующего шва 187 — новых поведенческих норм для ролей нет; self-test подключает orchestrator после реализации в окне freeze..done, чужие CI-строки не меняются.

## Незаполненные требования:
нет
