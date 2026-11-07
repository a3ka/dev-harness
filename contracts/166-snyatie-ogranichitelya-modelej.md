# Контракт 166 — свобода выбора модели каждого агента

КЛАСС ЗАДАЧИ: смешанный (кодовый отказ `make_task`, нормы ролей и устава).
КЛАСС РИСКА: обычный — выбор модели сам по себе не меняет права/роли БД, авторизацию, деньги, ПД/health или юридически значимое действие; суд реализации по действующему маршруту reviewer. Если роль судит отдельный рисковый предмет, риск того предмета остаётся рисковым.
КОНТЕКСТ: дословное слово владельца 2026-11-07: «я бы вообще просто убрал ограничения/механизм, который нас ограничивает в выборе модели для любого из агентов. То есть не просто решать вопрос критики, а вообще убрать этот ограничитель». Дополнение: «я бы оставил пока и архитектора и критика на сол. они могут нормально работать, когда начинают в новом контексте». Предыдущее разрешение 2026-11-06 «я разрешаю это навсегда, когда экономим лимиты моделей других семейств» было условным; нынешнее шире и снимает условие. Номер уже выдан `id/CONTRACT/166` и записан в `registry/contracts.tsv`; вторично не минтить.
КОНТЕКСТ: `contracts/095-profil-i-vhod-agenta-contextpack.md` — историческая заморозка протокола трассы, TASK и запрета семейства; менять frozen-текст нельзя, действующую несовместимую часть заменяет этот контракт.
КОНТЕКСТ: `contracts/104-uzkij-doverennyj-gejt-sudi.md` — сверка назначения роли с фактической моделью судьи; остаётся.
КОНТЕКСТ: `contracts/136-dovodka-sessij-proektov.md` — проектная трасса и toy-копии make_task; остаются, меняется только унаследованный запрет семейства.

## Существующее

- Сборщик `scripts/make_task.sh` (строки 127–180) парсит `--model-trace` (роль TAB модель TAB allowed|denied), проверяет наличие строки автора и судьи, затем `_t95_family` отвергает совпадение для critic/reviewer до сборки пака. На живой toy-фикстуре исходный critic Sol→Sol и reviewer glm-4.7→glm-5.3 дают rc 1 `ОТКАЗ: судья на модели автора`; это именно предмет изменения, не подмена роли или отсутствующая трасса.
- Батарея `fixtures/context_pack_095/model/dover.sh`, `red_revjer_poluchaet_vydannoe.sh`, `battery_stubs.sh` содержит прежний запрет и мутант s17; она нужна для TASK/trace/заморозки и сохраняется с обновлённым ожиданием. `fixtures/workshop_project/sessii_136/model/make_task.sh` и `stabs/s6-zadacha-filtr-vezde/make_task.sh`, `stabs/s7-zadacha-trassa-net/make_task.sh` — копии отказа, не новое правило; случай c4 проверяет карту и трассу, а не различие семейств. Не потерять другие порчи s6/s7.
- Дверь `scripts/check_sud_model.sh` сравнивает назначенную в `config/agent_models.json` модель судьи с фактическим спавном и bind-трассой; она НЕ сравнивает с моделью автора. Она остаётся неизменной: владелец выбирает модель одной строкой реестра, проверка удерживает выбранную модель. `overlay` проверяет поддержку картинок у ролей с кадрами, это возможность инструмента, не запрет семейства автора. Если фактически любой из этих механизмов блокирует выбранную владельцем модель при сохранённых требованиях роли, передать именованный конфликт оркестратору, а не снимать страж молча.
- Нормативный старый запрет: `AGENTS.md` §Модели ролей/§Суд реализации; `roles/critic.md` §Быстрый-процесс/§Модель, `critic-sol.md`, `reviewer.md`, `adversary.md`, `arbiter.md`, `orchestrator.md`; `config/agent_models.json` routing.constraint и `tiers.*.why`; `decisions/005-kritik-na-top-chuzogo-semeistva.md` (статус замены, историческое решение оставить читаемым). `roles/consultant.md` содержит историческое объяснение кросс-семейного выбора — переписать лишь если читается как действующий обязательный выбор. `scripts/check_project_connection.sh` «семейства» обозначает семейства команд npm/node/python3, `scripts/check_fork_route.sh` «независимость подписи» — авторство форка, `scripts/lib_plan.sh` «локаль-независимость» — парсинг диапазонов: ни один не судит модель; оставить. Фикстуры `fixtures/check_decisions/` и `fixtures/pravila_modelei_998/seed/` — синтетические/исторические входы, не настройки живых ролей; их красные проверки не удалять.
- Реестр `registry/plan.tsv` не несёт действующего маршрута Sol→Sol; в HANDOFF и forks прежний слот 166 был условным исключением экономии лимитов, а не этим полным снятием. Сверены `git branch --list '*095*' '*104*' '*136*' '*166*'` (локально только текущая 166) и `gh pr list --repo a3ka/dev-harness --state open --limit 100` (открытых PR по 095/104/136/166 нет); действующий отказ остаётся в HEAD. Решение 005 сохраняет происхождение, но его статус требует обновления. Н-270: `agent:task` вместо судейской роли даёт чужой тир — это по-прежнему отказ 104; Н-315: менять роль после отказа task вместо исправления причины недопустимо; Н-62: наблюдение без связанного механизма не чинит рецидив. А-100: красный прогон без честной модели может обещать недостижимое зелёное.

## Предмет и граница

Один результат: роль можно назначить любой доступной для её функциональных обязанностей моделью, независимо от модели, провайдера и семейства автора или другого судьи. Включая Sol-архитектора и Sol-критика в отдельных свежих контекстах, тот же модельный ID и разные версии одного семейства. Снять семейный запрет в `make_task` и в активных текстах без условных исключений, специальных Sol→Sol-флагов и смены назначений ролей ради прохождения запрета. Судья не судит собственный коммит/текст, работа идёт с отдельной зафиксированной кандидатурой; отдельные контексты, фактическая трасса роли, TASK-байты, бюджет судов, аутентичность вердикта и порядок adversary/reviewer сохраняются.

Вне предмета: новые версии назначенных моделей и фолбеков, смена тира роли по умолчанию, ослабление `check_sud_model` (совпадение назначения с фактом), images-условия для кадров, права записи, переписывание исторических вердиктов, замороженных контрактов и owner-документов. Удалять только ограничение **выбора модели относительно модели автора/других судей** и его устаревшие активные объяснения. Не путать отсутствие свидетеля автора с совпадением моделей: авторский свидетель по протоколу 095 остаётся обязательным для critic/reviewer даже при совпадении.

## Проверяемый шов и критерий

`python3 fixtures/workshop_project/model_choice_166/probe.py` вызывает публичный CLI `scripts/make_task.sh --repo R --contract 777 --role critic|reviewer --model-trace T [--task-file F]` на disposable toy-репо с действительным профилем/заморозкой 095. Конформные входы: те же TSV/role/task/profiles грамматики 095, роли critic/reviewer из закрытого алфавита, модель — непробельное строковое значение, fallback=allowed|denied. Валидное возражение о совпадении требует отказа именно на КОНФОРМНОМ входе, инвариантного к значениям конкретных моделей, а не отсутствия файла/роли/заморозки. Положительное сравнение структурно: rc 0, отдельная TRACE-строка назначенной роли/модели/fallback, TASK sha256 и исходные байты из памяти проверяющего; отрицательное: rc 1 и точная причина, без выдачи. После субъекта task-файл не изменён. Ожидания снимаются в память ДО запуска; модель проб не служит источником факта о работе настоящего субъекта.

- Дано текущее дерево; когда `python3 fixtures/workshop_project/model_choice_166/probe.py --repo .`; тогда rc 1: самостоятельные входы critic Sol→Sol и reviewer glm→glm отвергнуты `ОТКАЗ: судья на модели автора` (это красное ДО правки). После реализации тот же прогон rc 0: оба входа и разносемейный контроль выдают собственную модель судьи; отсутствие автора/судьи и reviewer без TASK дают свои прежние rc 1 причины. Отказ на одной клетке не засчитывает другую.
- Дано честная модель будущего поведения; когда `python3 fixtures/workshop_project/model_choice_166/probe.py --model`; тогда rc 0 с зелёными положительными и именованными отрицательными проверками. Когда `python3 fixtures/workshop_project/model_choice_166/probe.py --stabs`; тогда rc 0 при обнаружении независимых порч; невыявленная порча/невалидный честный контроль возвращает не 0. Адресное соответствие мутаций и входов существует только в КОДЕ `probe.py`.
- Дано реализация; когда `bash fixtures/context_pack_095/red_revjer_poluchaet_vydannoe.sh` и `bash fixtures/context_pack_095/battery_stubs.sh`, затем scoped батарея 136 (`bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model` и `bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --stabs`), тогда rc 0 без переустановки прежнего отказа; TASK, frozen, след трассы, исключения проекта и порчи s6/s7 сохраняются.
- Дано выбранная владельцем модель судьи на реальном role-tier; когда `bash scripts/check_sud_model.sh --spawn critic <назначенная-модель> --root .` и существующая связанная `--verdict`-проверка, тогда rc 0 при совпадении с назначением; несовпадение с назначением rc 1, даже если семья автора другая. Дано роль с кадрами без images; когда действующий overlay-гейт, тогда прежний отказ. Эти две проверки не мигрируют.
- Дано обновлённые норма и fixtures; когда `npm run gen:harness` и `npm run gen:harness -- --check` (сверить реальный CLI), затем `bash scripts/pre_critic.sh --repo . contracts/166-snyatie-ogranichitelya-modelej.md`; тогда rc 0 для генератора и двери. CI шаг 166 исполняет оба режима модели и обновлённые 095/136 и есть в проводке; новые модельные назначения не навязываются.

## Модель угроз

ЗАЩИЩАЕТ:
- Предотвращает ложный отказ честного judge-пака только из-за совпадения фактического семейства или ID модели с автором.
- Сохраняет след конкретной модели судьи и свидетеля автора, выдачу фактически переданного задания и отказ при отсутствии их свидетельств.
- Различает выбор модели роли владельцем и подмену выбранной модели во время спавна/суда.
НЕ ЗАЩИЩАЕТ:
- Принципиальную беспристрастность одной модели в двух отдельных контекстах; ловец — critic/reviewer по существу вердикта и живому кандидату, остаточный риск принят владельцем 2026-11-07.
- Утечку общего контекста между агентами и самостоятельный суд своего текста; ловец — изоляция сессии и предметная проверка ролей, не семья модели.
- Подмену конфигурации реестра назначений владельца или фальшивую трассу запуска; это отдельные границы 104/136, не предмет снятия семейного запрета.

## Зоны и проводка

ЗОНА architect: contracts/166-snyatie-ogranichitelya-modelej.md
ЗОНА architect: fixtures/workshop_project/model_choice_166/
ЗОНА implementer: scripts/make_task.sh
ЗОНА implementer: fixtures/context_pack_095/
ЗОНА implementer: fixtures/workshop_project/sessii_136/
ЗОНА implementer: AGENTS.md
ЗОНА implementer: roles/critic.md roles/critic-sol.md roles/reviewer.md roles/adversary.md roles/arbiter.md roles/orchestrator.md roles/consultant.md
ЗОНА implementer: config/agent_models.json decisions/005-kritik-na-top-chuzogo-semeistva.md
ЗОНА implementer: .omp/agents/ .omp/config.yml
ЗОНА critic: verdicts/critic/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: fixtures/context_pack_095/ — 095 только снятие семейного отказа; TASK и прочие клетки сохраняются
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/sessii_136/ — 136 только снятие семейного отказа в копиях; другие порчи сохраняются
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 002 только снятие семейного отказа по слову владельца
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 010 только снятие семейного отказа по слову владельца
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 027 только снятие семейного отказа по слову владельца
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 028 только снятие семейного отказа по слову владельца
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 041 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 043 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 027 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 038 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 050 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 002 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только отмена сравнения моделей с автором
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 002 только вывод изменённых текстов ролей генератором
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 003 только вывод изменённых текстов ролей генератором
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 005 только вывод изменённых текстов ролей генератором
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/ — 010 только вывод изменённых текстов ролей генератором
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 005 только результат генератора 166 без смены выбранных моделей
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 010 только результат генератора 166 без смены выбранных моделей
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 166
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 166
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 166


ПРЕДПОСЫЛКИ:
- setting существующий CI харнесса исполняет Python 3, git, bash, jq и 095/136 пробы без новых secrets, variables, environments; новый CI step регистрируется оркестратором в `registry/ci-steps.tsv` и `registry/ci-zamery.tsv` через `gen_ci_steps.sh --write`, затем `--check` rc 0.
- setting реестр `config/agent_models.json` назначает модель в контролируемом владельцем месте; реальные записи `models_actual.sh` доступны для связанной проверки 104, не генерируются батареей 166.

ПРОВОДКА:
role=roles/critic.md «Модель судьи выбирается назначением роли, без сравнения семейства и модели с автором; судья не судит собственную работу»
role=roles/orchestrator.md «Выбирай модель роли по реестру и сверяй фактическую трассу; совпадение модели с автором не причина отказа»
charter=AGENTS.md §Модели ролей «Судьи допускаются на назначенных моделях независимо от семейства и модели автора»
guard=scripts/make_task.sh
ПРОВОДКА-ЭНФОРСМЕНТ: guard удаляет только отказ на совпадении, а обязательный авторский и судейский след оставляет на CLI; выбор роли владельцем не подменяется.

Изменяющий `AGENTS.md` implementer-коммит несёт ДОСЛОВНО отдельной строкой в первой колонке тела:
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md снятие требования независимости семейств моделей судей и авторов — слово владельца 2026-11-07 «вообще убрать этот ограничитель» (выбор модели любого агента свободен)

Порядок: модель и красное на исходном дереве → pre_critic → critic → freeze → implementer (механизм, норма, 095/136 и генерация одним вертикальным срезом) → CI → reviewer → done. Замороженный контракт 095 не переписывать. Роль и устав меняются тем же implementer, что меняет отказ; при исправлении запущенного круга судьи его текст остаётся неизменным до завершения этого круга. До done сухая `bash scripts/check_provodka.sh . contracts/166-snyatie-ogranichitelya-modelej.md` и, при наличии project-профиля, `bash scripts/check_project_sources.sh --stage done` должны дать rc 0. Проверка участков CI — ответственность orchestrator, push через gitw после принятия ветки, а не из architect-клона.

## Незаполненные требования:
нет
