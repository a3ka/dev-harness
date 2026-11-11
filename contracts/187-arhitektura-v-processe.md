# Контракт 187а — двери и скрипты архитектуры в процессе станции

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — меняются двери процесса, не права/роли БД, авторизация, деньги, ПД/health-данные и согласия или юридически значимые действия.
ВЕРСИЯ: v2 (v+1 замороженного 187/1 по слову владельца 2026-11-11 ~13:05 UTC через консультанта, ADOPTION Fable 16 §2): дверь 187а на настоящей модели архитектуры.
КОНТЕКСТ: docs/owner/2026-11-10-plan-i-pravila-arhitektury.md §Восстановлено из решений 2026-11-08…10, пункты 1–9; /home/harness/consultant/spec11/ARCH-IN-WORKFLOW-SPEC.md §4–§8 (источник проектирования, не runtime-зависимость); NABLIUDENIA.md Н-442. 187а — только механические двери. Роли и подача находок — отдельный предмет 188 «187б: роли по архитектуре».

## Существующее

- Frozen 170 уже требует `scripts/make_task.sh --arch-component` и brief из **локального** `R/architecture/`; зелёная батарея `fixtures/workshop_project/arch_component_170/red_arch_component_170.sh` обязана пережить cutover. `STRUCTURE.md` приходит из contextPack 095 и остаётся. После 167 локальная копия архитектуры бэкенда удаляется: переход к закреплённому коммиту lock требует адресного v+1 170 с разрешением владельца. До него не выдавать несовместимый cutover 187а за done. Ранее поддержанные роли с brief с правилами/без сохраняются.
- 095/103/161a уже проводят `make_task`, project contextPack, `--repo` и разделение проектных/инструментальных задач. 996 разрешает профильные `workflowPaths`; признак backend — эффективный `repoId=Complior-back`, не наличие `.harness` (также есть у mob). В backend `architecture.lock.json` закрепляет точный коммит отдельного `CompliorOS-architecture`; читать модель из verify-pin клона, не из HEAD и не из локальной `architecture/`. `STRUCTURE.md` остаётся; `docs/ARCHITECTURE.md` исключается из backend contextPack. Миграция проектного профиля — предпосылка, не скрытая правка проекта.
- `scripts/freeze_contract.sh`, `scripts/pre_critic.sh`, `scripts/done_contract.sh` уже ведут frozen/critic/done, но не связывают область с компонентами модели, результат `check --base`, check-run `arch` на финальном SHA и строку вердикта. 167 проекта держит движок, `bindings.json`, pin и CI: харнесс не запускает движок в done. 186 ведёт хранителя. 188 отдельно проводит нормы ролей, включая автора строки задания и вызов хранителя.
- 187/1 заморожен и реализован (PR #782, accept ревьюера вызов 2/2 — `verdicts/review/contracts-187-impl-v2.md`); done ожидает v+1 170. На настоящей модели дверь не бывает зелёной (консультант Fable 16, ARCH-INTEGRATION §1.1): развёрнутое `git archive`-дерево без зависимостей, многострочный JSON `locate`, ложный красный по подстроке `NOT_EVALUATED` в зелёном ответе rc 0.
- Критик 170 v2 вызов 6 (`verdicts/critic/contracts-170-v2.md`) воспроизвёл пять расхождений двери с реальностью: (1) список компонентов строки не режется по запятым — `ARCH_ZONE` на конформной строке `a,b`; (2) применимость `ARCH_COMPONENT_NET` у `make_task` решает локальный каталог `architecture/`, а не lock; (3) имена отказов `ARCH_PIN` вместо `ARCHITECTURE_NET`; (4) бриф через `node cli.js` вместо `npm --prefix`; (5) символьный pin `HEAD` разрешается дверью. Ревью 187-impl-v1 (`verdicts/review/contracts-187-impl-v1.md`) понёс С1 (toy-грамматика батареи ≠ реальный CLI), С2 (неразмещённый путь получает `ARCH_ZONE` по эвристике диска), С3 (обязательность `ОПЕРАЦИЯ:` у каждого кодового), С4 (поле `.clone` в lock).
- Настоящая модель (клон `CompliorOS-architecture`, HEAD `954ad4c`, пин снимка №4 `bfc3f45996fa9ec1db3b7ba79158071cb9e89d63`) — измерено на станции 2026-11-11: `npm ci --ignore-scripts` в развёрнутом дереве ставит 89 пакетов по package-lock; `node tooling/checks/cli.js check --base governance/baseline/approved.json --base-digest 28858bc8743c411485f50aa86db470f6dfd0032a1daa16664f5f7d5ec26c5200` → rc 0, `requiredModelGate: PASS`, поле `status: NOT_EVALUATED` (про доказательства реализации, не вердикт); `locate --path server/src/auth/delivery.js` → rc 0, многострочный JSON, `matches[0].components = ["api.auth"]` (каталог `server/src/auth/` — тот же компонент); `npm --prefix <дерево> run brief -- --compact --component api.auth` → rc 0. Пакетные скрипты `brief`/`check`/`locate` объявлены в package.json пина.

## Позиция автора после вызова 2/2 и v2

СОГЛАСЕН с единственным блоком `verdicts/critic/contracts-187-v1.md`: прямой CI-вызов `check_architecture_contract.sh` не доказывает выполнение батареи. Guard в ПРОВОДКЕ — bash-обёртка батареи, дверь `check_architecture_contract.sh` — отдельный guard и отдельный шаг. До freeze явный rc-гейт `--wiring .` сверяет **два независимых** точных `step`-вызова в реальном `registry/ci-steps.tsv`; `gen_ci_steps.sh --check` сверяет generated workflow с registry. Ролевой поток остаётся 188.

v2 (слово владельца 2026-11-11 ~13:05 UTC через консультанта, ADOPTION Fable 16 §2 «v+1 187»): пять расхождений критика 170 и С1–С4 ревью закрываются этим контрактом; решения architect по снятиям и границам — раздел «Снятия и границы v2»; источник зависимостей закреплённого дерева — `npm ci --ignore-scripts` в развёрнутом дереве (измерено на станции), отказ — именованный `ARCH_DEPS` rc 2.


## Предмет, вход и порядок (v2)

Применимость — как в v1: кодовый предмет проекта `repoId=Complior-back` в профильных `workflowPaths.contracts` при наличии `architecture.lock.json`. Харнесс, mob, документальные задачи и контракты модулей отдельного репозитория архитектуры нового отказа не получают. Отсутствие локальной `R/architecture/` после 167 НЕ переводит backend в legacy.

Строка класса. В режиме 187а контракт предмета несёт самостоятельную строку `КЛАСС ЗАДАЧИ:`; её отсутствие — именованный отказ `ARCH_CLASS_MISSING` rc 1 на всех четырёх дверях (`make_task` — по черновику контракта, `freeze_contract`/`pre_critic`/`done_contract` — по контракту предмета). Значение опознаётся существующей грамматикой кодового (`кодовый|КОДОВЫЙ` в начале значения до разделителя); не-кодовое значение (документный, смешанный и пр.) дверь не вооружает — это `ARCH_187A_SKIP`, не отказ. Молчаливый пропуск бесклассового контракта (факт А§1) устранён.

Пин. `architecture.lock.json` — формат 167 (`format/repository/commit/snapshot/status/snapshotDigest/workItem`). `.commit` — ровно 40 строчных hex. Отсутствие значения, пустой lock или символьный pin (`HEAD`, именованная ссылка, любой не-hex) — `ARCHITECTURE_NET` («нет закреплённого коммита» / «lock не указывает на коммит архитектуры»); корректный 40-hex, не разрешающийся в клоне, — `ARCH_PIN` («коммит … не разрешается в клоне модели»). Клон модели — только env `ARCHITECTURE_ROOT` (verify-pin клон проектного CI); его отсутствие или недоступность — `ARCHITECTURE_NET` («нет репозитория архитектуры ARCHITECTURE_ROOT»). Поле `.clone` из lock дверь не читает. Имена отказов — грамматика 170 v2, единый источник для обеих семей.

Дерево модели и зависимости. Дверь материализует дерево закреплённого коммита (`git archive` пина) во временный каталог. Если в развёрнутом дереве есть `package-lock.json` и нет `node_modules` — дверь исполняет `npm ci --ignore-scripts` в ЭТОМ дереве; отсутствие npm или отказ `npm ci` — именованный отказ `ARCH_DEPS` («зависимости модели недоступны») с rc 2 двери в любом режиме — НЕ `ARCH_NOT_EVALUATED` и не зелёный результат. `node_modules` в самом дереве используется как есть (npm ci не повторяется). Дерево без `package-lock.json` считается свободным от зависимостей (миры фикстур до cutover). Решение architect по ADOPTION §2 «Особое»: `npm ci --ignore-scripts` — детерминирован package-lock'ом, не исполняет скрипты пакета, измерен на станции.

Размещение путей. Для каждого продуктового пути `ЗОНА implementer:` дверь зовёт `locate --path <путь>` в развёрнутом дереве. Ответ реального CLI — многострочный JSON; компоненты пути — объединение `matches[].components` всех матчей. Ответ с rc ≠ 0 или с пустым списком компонентов — путь неразмещён: `PATH_WITHOUT_COMPONENT`. Существование файла в продукте БОЛЬШЕ НЕ УЧАСТВУЕТ (снятие эвристики диска по С2): неразмещённый путь — всегда `PATH_WITHOUT_COMPONENT`, существует он на диске или нет. Пересечение компонентов пути с компонентами строки `АРХИТЕКТУРА:` пусто — `ARCH_ZONE` («путь … отнесён моделью к компоненту <comp>»); список строки режется по запятым, сверяются ВСЕ компоненты (двухкомпонентная строка конформна, расхождение (1) критика 170). Граница компонента: пересечение компонентов каталога пути с компонентами самого файла пусто — `ARCH_ZONE`. Ответ не-JSON (голый id компонента первой строкой) принимается как единственный компонент — совместимость миров фикстур 170/187-1 до их cutover; канон настоящего CLI — JSON.

Бриф. `make_task --arch-component` получает бриф пакетным скриптом закреплённого дерева: `npm --prefix <дерево> run brief -- --compact [--with-rules] --component <id>` (грамматика 170 v2, расхождение (4)); `--with-rules` — ровно architect/critic/arbiter. Прямой вызов `node cli.js brief` интерфейсом двери не является. Отказ npm или пустой stdout — `ARCH_BRIEF_OTKAZ`. Требование флага `--arch-component` для кодового задания в режиме 187а решает lock, а не локальный каталог (расхождение (2) критика 170): кодовое задание режима 187а без флага — `ARCH_COMPONENT_NET` rc 1, независимо от наличия `R/architecture/`.

`check --base`. Дверь зовёт `node tooling/checks/cli.js check --base governance/baseline/approved.json --base-digest <lock.snapshotDigest>` в развёрнутом дереве (снимок — раскладка 2.5.x; digest — из lock, дверь свой не считает). Вердикт — по rc команды и именованным полям ворот: rc 0 — зелено; rc 1 — `ARCH_CHECK`; rc 2 — `ARCH_NOT_EVALUATED`; ошибка входа инструмента (`ARCHITECTURE_TOOL_INPUT`, `MISSING_OPTION_VALUE`, `UNSUPPORTED_OPTION`) или не запустившийся node — `ARCH_NOT_EVALUATED` rc 2. Поле `status: NOT_EVALUATED` в теле ЗЕЛЁНОГО ответа (rc 0, `requiredModelGate: PASS`) — про доказательства реализации, не вердикт: подстрочный поиск `NOT_EVALUATED` в выводе check запрещён (ложный красный на утверждённом снимке — факт А§1.1(2)).

`pre_critic` зовёт дверь в ПОЛНОМ режиме — строка, зоны, операции, check — а не `--model-only`: отказ по строке, зонам и операциям наступает до платного суда (критерий (3) ADOPTION).

Операции. Судятся только ОБЪЯВЛЕННЫЕ строки `ОПЕРАЦИЯ: <id>; вход <схема>; выход <схема>`: грамматика схем и не-DRAFT (токен `draft` на границе слова в любом поле строки) — как в 187/1. Кодовый предмет БЕЗ строки `ОПЕРАЦИЯ:` не отказывает (снятие обязательности по С3: инфраструктурные и рефакторинговые предметы); разрешение операций и обязательств в закреплённой модели — отдельный предмет (Л5), не эта дверь.

Двери в целом: `make_task` судит задание и черновик контракта (класс, строка, зоны) и собирает бриф из пина; `freeze_contract` судит HEAD-блоб контракта (класс, строка, зоны, операции) до записи тега; `pre_critic` — полный режим двери до суда; `done_contract` — свидетельство `СВЕРКА-АРХИТЕКТУРЫ:` ревьюера и успешный check-run `arch` на HEAD (как в 187/1). `ARCH_187A_SKIP` остаётся только для не-кодовых значений класса и проектов вне режима 187а. Отказы атомарны: тег не создаётся, реестр не меняется.

ИСТОЧНИК: `путь@sha256 §раздел` модели пока нельзя честно предъявить: `sourceCanon` не включает модель, `module.js` не несёт разделов. ОСТАТОЧНЫЙ РИСК (cognitive-only): человек неверно интерпретирует поле модели; ловец — critic и reviewer предмета 188 по exact pin и diff, не ложная ссылка на `module.js`.

## Снятия и границы v2 (решения architect: С1–С4 ревью 187-impl-v1, расхождения (1)–(5) критика 170 v2)

- С3 «`ОПЕРАЦИЯ:` у каждого кодового» — СНЯТО: судятся только объявленные строки; носитель — клетка `operation-optional` (rc 0 на контракте без `ОПЕРАЦИЯ:`, красна на текущей реализации) и стаб `operation-required`.
- С4 поле `.clone` в lock — СНЯТО: клон модели только `ARCHITECTURE_ROOT`; носитель — клетка `model-root-unset`, стаб `root-unset-old-name`.
- С2 эвристика «файл есть в продукте» — СНЯТО: неразмещённый путь всегда `PATH_WITHOUT_COMPONENT`; носители — клетка `path-unplaced-product`, стаб `zone-disk-heuristic`; старая клетка `freeze-foreign` переведена с эвристики на честное размещение чужим компонентом (toy-locate обеих грамматик отвечает `api.billing` для `app/billing/**`).
- Ложный красный по подстроке `NOT_EVALUATED` — КАНОН: вердикт по rc и именованным полям ворот (`requiredModelGate`); носители — клетка `check-green-status-field`, стаб `check-not-evaluated-substring`.
- С1 toy-грамматика — КАНОН: toy-модель батареи приведена к реальному CLI (многострочный JSON `locate` c `matches[].components`, полный JSON-ответ `check` с `status: NOT_EVALUATED` на зелёном, пакетный запуск брифа, `package-lock`-семантика зависимостей); носители — клетки `locate-json-conform`, `locate-json-foreign`, `zone-comma-list`, `brief-npm-doorway`, `deps-door-refusal`, живая клетка `live-real-pin`.
- Расхождения критика 170 v2 — КАНОН/ГРАНИЦА: список по запятым — клетка `zone-comma-list`, стаб `zone-comma-unsplit`; применимость `ARCH_COMPONENT_NET` по lock — клетка `component-required-no-local`, стаб `applicability-local-dir`; имена `ARCHITECTURE_NET`/`ARCH_PIN` — клетки `pin-lock-empty`, `pin-symbolic`, `model-root-unset`, стабы `pin-net-old-name`, `root-unset-old-name`, `pin-symbolic-resolved`; бриф через `npm --prefix` — клетка `brief-npm-doorway`, стаб `brief-node-direct`; символьный pin — клетка `pin-symbolic`.
- Класс и полный режим — ГРАНИЦА: `ARCH_CLASS_MISSING` (клетки `freeze-class-missing`, `precritic-class-missing`, стабы `class-missing-skip`, `precritic-class-skip`); полный режим `pre_critic` (клетки `precritic-full-zone`, `precritic-line-missing`, `precritic-draft`, стаб `precritic-model-only` в трёх формах).

## Приёмочный критерий

Батарея — та же обёртка `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh`: 52 клетки, 50 стабов; счётные числа — из вывода самой батареи, не из этого текста.

- Дано: автономные toy-миры двух грамматик (legacy: locate голым id; realshape: многострочный JSON реального CLI, бриф пакетным скриптом, package-lock-семантика) со своими `.git`, закреплённый коммит A и отличный HEAD B; когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`; тогда rc 0, каждая из 52 клеток сообщает свой rc и причину. Валидный контрпример сохраняет инвариантность к значениям и расходится на конформном входе.
- Дано: те же входы; когда тот же скрипт `--stabs`; тогда rc 0, 50 обманных стабов пойманы каждый собственной различающей клеткой; отсутствие клетки/непойманный стаб → rc 1.
- Дано: ТЕКУЩАЯ реализация (до правок implementer по этому контракту); когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`; тогда rc 1 и красны РОВНО 18 новых клеток: `locate-json-conform`, `locate-json-foreign`, `zone-comma-list`, `path-unplaced-product`, `check-green-status-field`, `brief-npm-doorway`, `pin-symbolic`, `pin-lock-empty`, `model-root-unset`, `deps-door-refusal`, `precritic-full-zone`, `precritic-line-missing`, `precritic-draft`, `freeze-class-missing`, `precritic-class-missing`, `operation-optional`, `component-required-no-local`, `live-real-pin`; старые 34 клетки зелёные.
- Дано: реализация по этому контракту; когда та же команда `--repo .`; тогда rc 0: все клетки зелёные, `live-real-pin` при отсутствии env — именованный SKIP-вывод (не зелёный, не отказ).
- Дано: настоящая модель доступна — локальный клон `CompliorOS-architecture` (без секретов) в env `ARCH187_REAL_ROOT`; когда `--repo .` (клетка `live-real-pin` исполняется: дверь на мире с lock `{commit: bfc3f45996fa9ec1db3b7ba79158071cb9e89d63, snapshotDigest: 28858bc8743c411485f50aa86db470f6dfd0032a1daa16664f5f7d5ec26c5200}` и конформным контрактом `АРХИТЕКТУРА: L1 api.auth`, `ЗОНА implementer: server/src/auth/delivery.js`); тогда после реализации rc 0 с `ARCH_187A_OK` в stdout; до реализации — красна; env задан, но клон не разрешает пин → rc 2 `LIVE_PREDPOSYLKA`.
- Дано: закреплённое дерево с `package-lock.json`, без `node_modules`, сломанный npm на PATH; когда дверь судит конформный контракт; тогда rc 2 с именем `ARCH_DEPS` («зависимости модели недоступны») — не `ARCH_NOT_EVALUATED`, не rc 0.
- Дано: кодовый контракт режима 187а без строки `КЛАСС ЗАДАЧИ:`; когда `freeze_contract.sh` или `pre_critic.sh` судит его; тогда rc 1 `ARCH_CLASS_MISSING`, frozen-тег не создан; на ТЕКУЩЕЙ реализации rc 0 (тихий пропуск) — клетка красна.
- Дано: кодовый контракт режима 187а без строки `ОПЕРАЦИЯ:` (обязательность снята); когда `freeze_contract.sh`; тогда rc 0; на ТЕКУЩЕЙ реализации rc 1 `ARCH_DRAFT` — клетка `operation-optional` красна.
- Дано: backend toy без строки задания, с пустой строкой, L3, немаппленным или чужим путём; когда `make_task` собирает пак; тогда rc 1 (`ARCH_LINE_MISSING`/`ARCH_OWNER`/`PATH_WITHOUT_COMPONENT`/`ARCH_ZONE`), пак не создан; для валидного задания rc 0, brief из A не из B, `--with-rules` ровно architect/critic/arbiter, `STRUCTURE.md` есть, `docs/ARCHITECTURE.md` нет. На mob и harness архитектурной строки не требуют.
- Дано: закреплённая модель `check --base` возвращает 1 или 2/`NOT_EVALUATED`; когда `pre_critic.sh` вызывает `check_architecture_contract.sh`; тогда rc 1 (`ARCH_CHECK` либо `ARCH_NOT_EVALUATED`); rc 0 модели с зелёными прочими ногами — rc 0.
- Дано: reviewer без самостоятельной `СВЕРКА-АРХИТЕКТУРЫ:` либо чужой/отсутствующий/красный/skipped check-run `arch` на финальном SHA; когда `done_contract.sh`; тогда rc 1 (`ARCH_REVIEW`/`ARCH_CI`), done-тег отсутствует; при свидетельстве и зелёном run на точном SHA — rc 0.
- Дано: frozen 170 до санкции v+1; когда `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` и `--repo .`; тогда прежние rc (гарантии frozen 170/1 не тронуты).
- Дано: чистый клон ветки без локального клона модели; когда `--repo .`; тогда rc 1 красных клеток либо rc 2 `LIVE_PREDPOSYLKA` — НЕ rc 0 и не вакуум: каждая красная клетка печатает свой rc и причину.
- Дано: исправленный черновик; когда `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md`, затем `bash scripts/check_precision_gate.sh . contracts/187-arhitektura-v-processe.md`, затем `bash scripts/check_ceilings.sh .`, затем `bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md`; тогда каждый rc 0. До freeze после подключения CI orchestrator: `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring .` и `bash scripts/gen_ci_steps.sh --check` и `bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md` (на копии дерева с пустыми guard-файлами) → каждый rc 0; точный `step` в registry исполняет `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, другой `step` отдельно вызывает `bash scripts/check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md` — обе строки без изменений против 187/1.

## Модель угроз

ЗАЩИЩАЕТ:
- От заморозки вне объявленных компонентов и DRAFT, от ложного зелёного rc 2 модели.
- От done по зелёному чужого SHA или без свидетельства reviewer.
- От подмены CI-батареи прямым вызовом двери защищает `--wiring` по реальным `step`-строкам registry, с независимым `gen_ci_steps.sh --check` по generated workflow.
- От ложного зелёного и ложного красного на НАСТОЯЩЕЙ модели: подстрочный вердикт по `NOT_EVALUATED`, чтение первой строки JSON `locate`, список строки без реза по запятым, символьный pin `HEAD`, тихий пропуск бесклассового контракта, режим `--model-only` на `pre_critic` — у каждого именованный отказ и своя клетка.
- От немоты двери без зависимостей закреплённого дерева: именованный `ARCH_DEPS` rc 2, fail-closed, никогда не зелёный.
НЕ ЗАЩИЩАЕТ:
- От ложной модели/сознательного обхода project CI; движок и суд проекта владеют этим свойством.
- От человеческой ссылки на модель как `ИСТОЧНИК:` до совместимой поддержки sourceCanon.
- Живая клетка `live-real-pin` требует локальный клон архитектуры и npm с сетью для `npm ci --ignore-scripts`: их отсутствие даёт именованный `ARCH_DEPS`/`LIVE_PREDPOSYLKA`, НЕ зелёный; свойство «модель зелёная на утверждённом снимке» доказывается только при их наличии.
- От отсутствия схем и инвариантов у операций в самой модели (26 DRAFT, 22 без схем) — это хранитель (186) и Астра, не дверь; разрешение операций в модели — предмет Л5.

ПРЕДПОСЫЛКИ:
- setting Проектный CI предоставляет check-run `arch` на точном backend SHA и закреплённый clone из `architecture.lock.json`; секреты/variables/environments не вводятся предметом 187а.
- setting Проектный профиль исключает `docs/ARCHITECTURE.md` из backend contextPack; отдельная проектная миграция и v+1 170 согласуются до done.
- setting Живая клетка: локальный клон `CompliorOS-architecture` с коммитом снимка №4 `bfc3f45996fa9ec1db3b7ba79158071cb9e89d63` в env `ARCH187_REAL_ROOT` и npm с сетью для `npm ci --ignore-scripts`; без них — именованный пропуск (`SKIP`) либо отказ (`LIVE_PREDPOSYLKA`/`ARCH_DEPS`), не зелёный; секретов не требуется.

## Зоны и проводка

ЗОНА architect: contracts/187-arhitektura-v-processe.md fixtures/workshop_project/architecture_process_187/
ЗОНА implementer: scripts/make_task.sh scripts/freeze_contract.sh scripts/pre_critic.sh scripts/done_contract.sh scripts/check_architecture_contract.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новый шаг 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 187; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 187; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ architect: contracts/187-arhitektura-v-processe.md — 993 только собственный новый контракт 187; чужой текст не меняется.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/architecture_process_187/ — 054 только новая семья 187; чужие fixture не меняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/architecture_process_187/ — 055 только новая семья 187; чужие fixture не меняются.

ПРОВОДКА:
- guard=fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh
- guard=scripts/check_architecture_contract.sh
ПРОВОДКА-ЭНФОРСМЕНТ: двери судят byte-структуру строки, класс предмета, путь/компонент, check-rc, pin, зависимости закреплённого дерева и check-run; содержательную архитектурную оценку получают от отдельных предметов 188 и Л5.

## Незаполненные требования:
нет
