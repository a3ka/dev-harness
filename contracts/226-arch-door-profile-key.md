# Контракт 226 — Л10: профиль включает дверь архитектуры без имени проекта

КЛАСС ЗАДАЧИ: кодовый (контракт и красная батарея; production — implementer после заморозки).
КЛАСС РИСКА: рисковый — безопасность процесса: политика включает/выключает архитектурный страж проекта; неверное чтение не вправе означать выключение.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — станционные двери, продуктовую модель не меняем.
КОНТЕКСТ: R-0103 и R-0102 владельца через консультанта, задание task-architect226.md; consultant/ARH-RAB-plan.md Л10: после done 203 включать архитектуру ключом профиля, остальной Ш-5 не брать. База 5b8ae0cdca9429d9d651c19d2775016e57ce271f. Номер id/CONTRACT/226 и строка плана уже выданы. sourceCanon не вводится.
СДАЧА: fixtures/workshop_project/arch_door_profile_key_226/SDACHA.md

## Существующее

- `scripts/check_architecture_contract.sh`, arch187_scope: единственный селектор pinned-режима четырёх дверей; сейчас сравнивает repoId с литералом, затем проверяет существование architecture.lock.json. В этом же файле уже работают выгрузка точного пина, зависимости 203, членство id, причины брифа, locate, зоны, snapshot и check --base. Их не переписываем.
- `scripts/make_task.sh` уже различает источник pinned/legacy и кодовый класс; arch187_check_text идёт до требования флага. frozen 170/1 сохраняет локальную architecture/ и npm-бриф без пина; frozen 187/3 — полный SHA40 и отказы до ARCH_COMPONENT_NET; done 203/1 — зависимости/членство/полная причина. frozen 188/2 требует полного содержимого брифа, не конкретного repoId.
- `scripts/check_architecture_pin.sh` уже судит реальные merge/PR-head и lock из head-коммита, не рабочий lock. Единственный продуктовый fallback — PRODUCT_REPO=a3ka/Complior-back; ARCH_REPO и формат lock 167 не предмет этого номера. Frozen 186/2 сохраняет проверки принятого head, workItem и merge-пина.
- `scripts/profile_resolver.sh` — существующие SCHEMA_LEVELS, валидация и merged с origin; библиотечный profile_get читает сырой repo-слой и на битый JSON выдаёт default. Поэтому как в `scripts/check_sdacha.sh` (193 BUDZHET-KONFIG) чтению profile_get обязательно предшествует успешный полный resolver. Б-4 pack.maxBytes — прецедент repo-only ключа. Второго профиля/резолвера не создаём. М-0 (184) оставляет неизвестные ИМЕНА предупреждениями, но известные неверные значения — отказами; это сохраняется.
- `freeze_contract.sh`, `done_contract.sh`, make_task и публичная архитектурная дверь потребляют arch187_scope. Его ошибку необходимо отличать от честной неприменимости во всех этих местах. pre_critic уже вызывает публичную дверь; отдельного читателя ключа ему не надо. 996 сохраняет проектные workflowPaths и fail-closed.
- Миры `architecture_process_187/probe.py` переиспользуются 203 и прочими 187-пробами; `architecture_steward_186/pin_probe.py` — реальные Git/PR-миры пина. После снятия литерала они обязаны ЯВНО объявлять прежнюю включённую политику. Меняются только входные профили этих двух строителей, не ожидания, не судящие предикаты и не frozen-тексты. Проба 203 и pin186 остаются потребителями.
- Поиск contracts/registry/fixtures/scripts и refs/PR не дал второй реализации hooks.archBrief; найденные 170/184/186/187/188/193/203/996 решают смежные части, но не конфигурируемое включение. Живой census высших frozen и его команды — context.py этой семьи; frozen-зоны, а не устаревшие номера строк, определяют пересечения.

Обещание — политика из профиля причинно меняет применимость двери и адрес продуктового PR. Наблюдение — настоящий make_task/resolver/check_architecture_contract/freeze/done/check_architecture_pin, rc, раздельные трубы, отсутствие частичного пака/тегов/изменения HEAD; журнал argv сетевого шва отдельно доказывает источник productRepo. Статика доказывает только отсутствие исполняемого литерала. Совместимость frozen: меняется исключительно селектор 187 и источник PRODUCT_REPO 186; остальные названные обязательства сохраняются регрессом, миграция входов явная.

## Frontier

1. **Выбрано: repo-only `hooks.archBrief`: false либо строка `owner/repo`.** Одна величина одновременно включает дверь и задаёт продуктовый repo; нельзя объявить enabled=true без адреса. Имя из Ш-5, чтение/валидация существующим resolver и profile_get, как 193. Боль измерена кодом: два литерала ядра не дают другому repoId включить тот же механизм. Нет ключа — выключено; ошибка чтения/значения — не отсутствие.
2. Отклонён список repoId: профиль уже принадлежит одному repo; список дублирует идентичность и всё равно не задаёт owner для pin-команды. Сохраняет необходимость второго адресного ключа.
3. Отклонён объект `{enabled, productRepo}`: две независимые координаты допускают противоречивое/неполное состояние и требуют лишних правил без дополнительного результата Л10. Bool true без адреса столь же недостаточен. Автовключение по одному lock отклонено: затравка прямо задаёт отсутствие ключа как выключение.

Профиль бэкенда живёт в **его** `harness.project.json`, не в станции. Выбран отдельный PR бэкенда: добавить `"hooks":{"archBrief":"a3ka/Complior-back"}` до переключения установки станции на реализацию 226. Старый М-0 resolver допускает этот ключ предупреждением, поэтому порядок выполним без переходного fallback. Оркестратор проводит этот PR через проектный маршрут, фиксирует sha/зелёную пробу backend и только затем объявляет cutover выполненным. В этой пачке другой репозиторий не пишется. Никакой автоматической догадки по repoId, origin, имени каталога или PRODUCT_REPO env.

## Предмет

Один результат: игрушечный проект с иным repoId и полным пином включает существующую архитектурную дверь своим профилем; без --arch-component кодовый task получает rc 1 ARCH_COMPONENT_NET, а pin-команда запрашивает productRepo из того же профиля. Architect сдаёт страницу, исполняемый честный контроль, красные миры и адресные обманки; production не меняет. Остальные ключи Ш-5, модель архитектуры, иной формат lock, авторизация записи профиля и новые сети/установщики не входят.

## Инварианты

1. Репо-слой `harness.project.json`: необязательный `hooks` — объект; известный лист `hooks.archBrief` — ровно JSON false либо строка полного `owner/repo`. В каждой половине первый символ ASCII `[A-Za-z0-9]`, остальные `[A-Za-z0-9_.-]`; половины непустые, ровно один `/`, конец значения точный. Нет trim/casefold, NUL/CR/LF/пробелы вне алфавита. Искусственного лимита длины нет. null, true, числа, массивы, объекты и строка false не означают выключение. SCHEMA_LEVELS и проверка значений существующего resolver — единый источник грамматики; потребители её не переизобретают.
2. Проверенное отсутствие листа в корректном repo-профиле и явный false выключают pinned-дверь, даже при lock: это разрешённая политика Frontier, не автоопределение включения по lock. Отсутствующий файл профиля при lock — rc 1 `ARCH_PROFILE_MISSING: harness.project.json`; без lock — прежняя неприменимость. Повреждённый repo-профиль, недоступный/повреждённый объявленный слой — rc 1 `ARCH_PROFILE` на публичной архитектурной двери с причиной resolver. Наличие известного листа в project defaults — rc 1 `ARCH_PROFILE_LAYER: hooks.archBrief`, независимо от значения и наличия repo-листа: неправильный слой не участвует в слиянии и не выключает страж. Значение вне грамматики — прежний `profile ОТКАЗ: ... hooks.archBrief: ...`. У всех отказов stdout пуст, пак/теги/HEAD не меняются. Библиотечный scope возвращает 0 (включено), 1 (проверенная неприменимость), 2 (ошибка профиля); все потребители сохраняют различение ошибки и неприменимости. Неизвестные ИМЕНА остаются предупреждениями М-0, не попадают в merged; известный лист в неправильном слое — ошибка размещения, не неизвестное имя.

Таблица состояний: «архитектура есть» означает существование файла `architecture.lock.json`, ровно признак 187/203; содержимое lock судят прежние пиновые проверки, нового признака нет. «Выключено» ниже относится только к pinned-двери; локальная legacy architecture/ и обязательный профиль make_task сохраняют собственные отказы.

| Файл repo-профиля | Lock (архитектура) | Лист | Слой | Поведение pinned-двери |
| --- | --- | --- | --- | --- |
| Нет | Нет / есть | Неизвестен | Неизвестен | Без lock: rc 0 ARCH_187A_SKIP; с lock: rc 1 ARCH_PROFILE_MISSING |
| Есть, resolver успешен | Нет / есть | Нет или false / owner/repo | Только repo, defaults без этого листа | Нет/false: выключено при любом lock; строка: включено при lock, иначе прежний legacy |
| Есть, повреждён или объявленный слой недоступен/повреждён; либо есть лист в defaults | Нет / есть | Неизвестен / любое значение | Неизвестный / неправильный, в том числе два объявления | rc 1 ARCH_PROFILE / ARCH_PROFILE_LAYER, не выключение |

3. Валидная строка и существующий lock включают pinned-режим независимо от repoId. Отсутствующий lock сохраняет legacy-переключатель 187/170, а не вводит новую обязанность пина. Локальная architecture/ по-прежнему делает кодовый флаг обязательным по 170 даже при выключенной pinned-двери. Документный класс без флага не становится кодовым. Грамматика pin/строки/членство/зоны и их порядок до ARCH_COMPONENT_NET остаются прежними.
4. `check_architecture_pin.sh` — явная операция проверки, а не skip-дверь: требует валидный включённый hooks.archBrief; отсутствие листа/false в корректном профиле — rc 1 `ARCH_PROFILE_REQUIRED: hooks.archBrief`, до gh; неизвестность профиля не отменяет отказы инварианта 2. Адрес продуктового PR — полное неизменённое значение листа; PRODUCT_REPO env больше не источник/override. Архитектурный repo/COMPLIOR workItem/формат lock и все проверки 186 остаются прежними. Ни HEAD, ни файлы продукта, ни refs команда не меняет.
5. Исполняемые строки scripts/check_architecture_*.sh не несут Complior-back (в том числе usage); комментарии могут описывать историю. Backend с ключом получает те же бриф/отказы и pin-проверки, что до cutover. Смена ключа строка → false → та же строка на одном мире даёт отказ флага → пак → отказ флага; адресные pin-пробы различают разные owner/repo и регистр, не только enabled.

## Батарея и демаркация

Семья `fixtures/workshop_project/arch_door_profile_key_226/`: probe.py, build.py, model/, stabs/, source.json, обёртка, context.py, SDACHA.md. build.py генерирует носители из именованной базы; source.json хранит sha256 и исполняемые связи; catalog сверяет их с кодом. Ожидания — литералы в памяти ДО субъекта; чтение результата после него не меняет ожидания. Стабы к ветвям привязывает architect по коду, НЕ проза контракта.

Конформный положительный мир — реальные Git-объекты, валидный профиль/слой 996 с repo-only политикой, полный pin, доступный offline CLI по пину и валидная строка/зоны 203; имена repoId/owner/repo, SHA, каталоги и длины не привязаны к одному продукту. Контрпример валиден при инвариантности к этим значениям и расхождении на таком входе. Негативные входы вне грамматики предъявлены отдельно и ожидают именованный отказ, а не засчитываются как зелёные конформные миры. Ошибка среды/носителя/синтаксиса — rc 2, не пойманная обманка. HTTP-метаданные offline-фикстуры не судят policy: отдельно наблюдается реальный argv gh; Git/merge/head/lock настоящий.

Приёмка конечной батареи проверяет отсутствие/false, иной и backend repoId, минимальные и длинные/смешанного регистра значения, нули/типы/подстроки/NUL/LF, бриф с флагом, документный и legacy-миры, причинную смену ключа, malformed на публичных дверях, запрет env-override и отсутствие литерала. Обе стороны предикатов имеют честные положительные и отрицательные входы. Недоказуемая полнота произвольной реализации не обещана.

## Приёмочный критерий

Обозначение W ниже раскрывается в полную команду `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh`.

- Дано дерево до реализации; когда `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo .`; тогда rc 1, именованные RED применимости/грамматики/пина/литерала/неизвестности профиля/ошибки слоя. Дано реализация; та же команда — rc 0, KLETKI 56, KRASNYH 0.
- Правило честного контроля: `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model` → rc 0, KLETKI 56, KRASNYH 0; профиль без листа при lock и false остаются выключенными, owner/repo включён; без профиля и без lock — ARCH_187A_SKIP, с lock — ARCH_PROFILE_MISSING; повреждение профиля/слоя — ARCH_PROFILE, defaults-лист и два объявления — ARCH_PROFILE_LAYER. Отказные миры судят пустой stdout, отсутствие тегов и изменений HEAD.
- Правило различимости: `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --stabs` → rc 0, STABY 18, SVJAZI 25, ZHIVYH 0; каждая связь исполнена отдельно после честного контроля.
- Правило формы: `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --sintaksis` → rc 0 (bash -n всех shell-носителей, Python compile, настоящий пинованный shellcheck; inherited-диагностики полной базы сравниваются по code/message/source-line, новые запрещены, wrapper чистый); `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --catalog` → rc 0 (носители и связи целы).
- Правило совместимости до заморозки: `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --regression` → rc 0 на честном контроле: полные прежние батарея 203 и pin186 с явно мигрированными входами. После реализации: `bash fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh --repo .` → rc 0 и `python3 fixtures/workshop_project/architecture_steward_186/pin_probe.py --repo .` → rc 0; ожидания не ослаблены.
- Правило формы перед судом: `bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md` → rc 0; `bash scripts/check_sdacha.sh . contracts/226-arch-door-profile-key.md --run` → rc 0. `python3 fixtures/workshop_project/arch_door_profile_key_226/context.py` → rc 0, пустой выборки нет.
- Дано CI-проводка orchestrator; когда `bash scripts/check_provodka.sh . contracts/226-arch-door-profile-key.md` и `bash scripts/gen_ci_steps.sh --check`; тогда rc 0. Свой step `check:arch-door-profile-key-226-family-selftest` исполняет W --repo ., --stabs, --sintaksis после реализации; до неё --model, --stabs, --sintaksis. Реальный замер — в ci-zamery.tsv.
- Дано отдельный PR профиля backend в его main и установка станции с 226; когда W-мир backend-equivalent и проектный make_task без --arch-component; тогда rc 1 ARCH_COMPONENT_NET. Коммит профиля и живая проектная команда/rc фиксируются orchestrator до done; без доставки ключа backend cutover не завершён (cognitive-only порядок межрепозиторной доставки; ловец reviewer и orchestrator, риск преждевременной установки).

## Модель угроз

ЗАЩИЩАЕТ:
- От молчаливого исключения иного repoId из архитектурных ворот: один профильный селектор вместо сравнения имени; реальные no-flag/brief-миры и смена значения.
- От превращения неизвестности профиля или ошибки размещения известной политики в выключение: resolver до profile_get, fail-closed при lock без файла профиля, раздельные исходы scope, публичные отказные миры и пустой stdout.
- От адресации product PR литералом или чужим env: профильное значение и отдельное наблюдение argv на реальном pin CLI; сохранённые проверки merge/head/lock.

НЕ ЗАЩИЩАЕТ:
- От санкционированного удаления/false листа в корректном профиле, опечатки неизвестного ИМЕНИ или отсутствующего lock: первое — разрешённая политика Frontier, второе остаётся предупреждением М-0, третье — прежняя граница 187; ловцы — code review профиля проекта и его CI. Удаление файла при lock и известный лист в project defaults не входят в эту границу.
- От подмены доверенной установки, Git/Node/PATH или одновременной перезаписи профиля между validation/read: прежняя single-uid/TOCTOU граница 996; ловцы — изоляция станции и reviewer. Новый механизм атомарного профиля не обещан.
- От дефекта содержания брифа/самой модели и старых inherited shellcheck-диагностик вне дельты: ловцы — 188, модель check --base, CI и reviewer; 226 не переписывает модель и чужие скрипты ради lint.

## Зоны

ЗОНА architect: contracts/226-arch-door-profile-key.md fixtures/workshop_project/arch_door_profile_key_226/
ЗОНА implementer: scripts/check_architecture_contract.sh scripts/check_architecture_pin.sh scripts/profile_resolver.sh scripts/make_task.sh scripts/freeze_contract.sh scripts/done_contract.sh fixtures/workshop_project/architecture_process_187/probe.py fixtures/workshop_project/architecture_steward_186/pin_probe.py
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

## Пересечения

ПЕРЕСЕЧЕНИЕ architect: contracts/226-arch-door-profile-key.md — 993 новый контракт станции, не backend.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/arch_door_profile_key_226/ — 054 новая подсемья, старые файлы сохранены.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/arch_door_profile_key_226/ — 055 новая подсемья, старые файлы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_process_187/probe.py — 054 только явный профиль входа, ожидания сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_process_187/probe.py — 055 только явный профиль входа, ожидания сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_process_187/probe.py — 105 только явный профиль входа, ожидания сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_process_187/probe.py — 187 только явный профиль входа, ожидания сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_process_187/probe.py — 201 только явный профиль входа, ожидания сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_steward_186/pin_probe.py — 054 только профиль входа, проверки пина сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_steward_186/pin_probe.py — 055 только профиль входа, проверки пина сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_steward_186/pin_probe.py — 105 только профиль входа, проверки пина сохранены.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/architecture_steward_186/pin_probe.py — 186 только профиль входа, проверки пина сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_architecture_contract.sh — 187 только селектор по ключу; pin/locate/check/brief сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_architecture_contract.sh — 203 только селектор по ключу; зависимости/членство/причина сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_architecture_pin.sh — 186 только источник productRepo, прежние проверки merge/head/lock сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 038 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 094 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 168 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 184 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 187 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 201 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 224 только различение ошибки scope, порядок вердиктов сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 992 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 996 только различение ошибки scope, workflowPaths сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 013 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 027 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 036 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 038 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 043 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 060 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 078 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 084 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 122 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 154 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 187 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 193 только различение ошибки scope, сдаточный лист сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 992 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 996 только различение ошибки scope, workflowPaths сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только различение ошибки scope, карты/пак/манифест сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 103 только различение ошибки scope, workflowPaths сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 136 только различение ошибки scope, трассы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 161 только различение ошибки scope, состояние worktree сохранено.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 166 только различение ошибки scope, назначение модели сохранено.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 168 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 169 только различение ошибки scope, явная трасса сохранена.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 170 только различение ошибки scope, legacy/npm/порядок брифа сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 184 только различение ошибки scope, прочие двери сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 187 только различение ошибки scope, pinned-грамматика и отказы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 203 только различение ошибки scope, полный бриф/членство/кап сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 996 только различение ошибки scope, workflowPaths сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 054 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 055 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 057 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 059 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 094 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 095 только repo-only hooks.archBrief, contextPack сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 097 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 112 только repo-only hooks.archBrief, прочие ключи сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 184 только repo-only hooks.archBrief, предупреждения М-0 сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 992 только repo-only hooks.archBrief, fail-closed сохранён.
ПЕРЕСЕЧЕНИЕ implementer: scripts/profile_resolver.sh — 996 только repo-only hooks.archBrief, sourceCanon/пути сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только step 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 226.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 226.

## Проводка

ПРЕДПОСЫЛКИ:
- setting Существующие bash, python3, git, jq, node, tar, cmp и пин shellcheck 0.11.0; батарея offline, новых secrets/variables/environments нет.
- setting Профиль backend меняется отдельным PR проекта ДО установки переключённых дверей; станционный профиль этого ключа не получает.

ПРОВОДКА:
- guard=scripts/check_architecture_contract.sh
- guard=scripts/check_architecture_pin.sh

ПРОВОДКА-ЭНФОРСМЕНТ: конфигурация существующих стражей, новой поведенческой нормы роли нет. Orchestrator подключает свою батарею к CI и межрепозиторную доставку; production реализует только перечисленные швы и миграцию входов, комментарии селектора обновляются вместе с ним.

## Незаполненные требования:
нет
