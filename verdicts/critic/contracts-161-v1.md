accept

# Критик 161a — одноразовый scoped-вызов 7/7 (исполнение разрешения владельца, не новый круг)

СУД: repo=dev-harness; предмет=161; фаза=контракт; роль=critic; вызов=7/7; модель-план=zai/glm-5.3; сессия=Critic161GlmV7; модель-факт=zai/glm-5.3 (workstation; оркестратор свяжет по --bind); SHA=baa080c24dacdd0b863d8bc0d70215289f91a5ce; предыдущий=FAIL 6/6 (verdicts/critic/contracts-161-v3.md на eec120d6, модель-факт zai/glm-5.3, check_sud_model rc0); исключение=мораторий-исключение владельца 2026-11-07 (~00:41 UTC, подтверждено ~01:30 UTC) ровно на этот вызов; 8-й вызов не разрешён.

## Учёт счёта (обязателен по заданию)

Пять оплаченных вызовов: v1 FAIL Sol (contracts-161-v1-fail.md); v2 accept Sol (contracts-161-v2.md); Critic161Pinned; Critic161XhighPinned; Critic161BareRetry accept 5/5 на OBJECT 2c7abb6e — исчерпан, НЕ материализован (check_sud_model rc1 Н-270). Шестой — FAIL (contracts-161-v3.md, main, OBJECT eec120d6). Седьмой — этот вызов по прямому слову владельца. Итого 7/7; FAIL/ESCALATE здесь = стоп и доклад, не новый круг.

Независимость: автор кандидата — openai-codex/gpt-6-sol (трейс продюсера, 6-й суд); судья — zai/glm-5.3; семейства различны (glm≠gpt). Мораторий-исключение покрывает ровно этот вызов.

## Предмет и дельта

Кандидат: origin/wip/161/architect = baa080c24 (сверено rev-parse в одноразовом SSH-клоне ssh://git@github.com/a3ka/dev-harness.git, ветка judge-161). Дельта от 6-го суда: `git diff --stat eec120d6..baa080c24` = РОВНО fixtures/workshop_project/proektnaja_raskladka_161/probe.py +58/−1, других файлов нет. Ветка vs main: 4 файла (контракт, SPEC.md, probe.py, red_proektnaja_raskladka_161.sh), scripts/ не тронуты — зона implementer чиста.

## Три проявления 6-го FAIL — закрыты кодом и живьём

(а) foreign-снимок ДО вызова — probe.py:94-116: foreign_snapshot() = main HEAD/индекс/status + draft HEAD/status/index + SHA256-обход всех файлов main И draft (байты, не только git-статус); снимок берётся до обеих клеток конфликта (foreign_before), сравнивается после make_task и после spawn (FOREIGN_DIRTY обеими клетками). Строчные привязки задания сверены с файлом — совпадают дословно.
(б) пустой stdout при LAYER_FOREIGN от make_task — probe.py:233-234: check(not mt_conflict.stdout, 'LAYER_FOREIGN: make_task issued partial pack').
(в) неизменность множества веток и worktree при LAYER_FOREIGN от spawn_agent — probe.py:239-241 (branches_before/worktrees_before до вызова), 257-264 (три проверки: нет ветки wip/761/critic, список веток неизменен, список worktree неизменен).
Н-39 соблюдён: стабы привязаны к ветвям кодом probe.py (foreign-write/foreign-make/missing-spawn в stub_invoke), контракт несёт инварианты + rc-правила.

## Требуемая таблица доказательств (живые прогоны в клоне на OBJECT)

1. Честный bare W → rc 1, РОВНО два класса: 'MANIFEST_MAIN_ONLY: no unique external manifest before spawn' + 'PROFILE_PATH_MISSING: absent optional row accepted'.
2. W --model → rc 0: 'CONTROL: honest product expected red: MANIFEST_MAIN_ONLY, PROFILE_PATH_MISSING'.
3. W --stabs → rc 0, ЧЕТЫРЕ подмены пойманы: STAB_CAUGHT optional-skipped (CONTEXT_FOREIGN: missing exact REUSE: docs/reuse.md); foreign-make (CONTEXT_FOREIGN: make_task); foreign-write (FOREIGN_DIRTY: make_task changed foreign project) — новая четвёртая подмена; missing-spawn (MANIFEST_MISSING:). Контроль foreign-make до cutover дополнительно ждёт +1 FOREIGN_DIRTY (манифест мутанта пишется в foreign.draft) — пойман.
4. Атака A (дословная из 6-го суда, зона implementer, scratch-клон: инъекция в make_task.sh перед блоком манифеста записи x в $HARNESS_PROJECT_LAYER_ROOT/.omp/cache-161a): bare → rc 1, честные два класса + 'FOREIGN_DIRTY: make_task changed foreign project'; --model → rc 1 'CONTROL_INVALID: honest product outcome is neither post-cutover green nor the measured two-class pre-cutover red'. Требование «+= FOREIGN_DIRTY, CONTROL_INVALID» выполнено.
5. Частичная выдача при отказе (мутация scratch-P: make_task на конфликтном слое печатает 'MAP: docs/map.md :: Complior-mob-source' в stdout, затем отказ rc1 LAYER_FOREIGN): bare → rc 1 с третьим классом 'LAYER_FOREIGN: make_task issued partial pack'. Обнаружение доказано.
6. Создание ветки/worktree до отказа (мутация scratch-S: spawn на конфликтном слое ДО отказа выполняет git worktree add -b wip/761/critic, затем rc1 LAYER_FOREIGN; внешний манифест размещён перенаправлением make_task в $TMPDIR/ext-state-161 — та же мутация B 6-го суда, чтобы клетка external-ветви исполнилась): bare → rc 1, ровно три новых строки 'LAYER_FOREIGN: spawn created branch on refusal' / 'LAYER_FOREIGN: spawn changed branches on refusal' / 'LAYER_FOREIGN: spawn created worktree on refusal'; ложных FOREIGN_DIRTY/MAIN_DIRTY нет. Обнаружение доказано.

Повторно НЕ гонялись (ADVICE §4, код путей не изменён дельтой): атаки B/C 6-го суда, check_threat_model/check_ceilings (текст контракта не менялся), check_provoka (rc1 «guard не подключён» — ожидаемый до-реализационный класс). Гейты, затронутые дельтой (case-семья), прогнаны заново на baa080c24: pre_critic rc 0 «КРИТИК: дверь зелёная»; check_precision_gate rc 0 OK; check_spec_ready rc 0 OK.

## Отдельный вопрос (Астра §2): полный check_zones rc1 до frozen/161/1

Точный сырой отказ (живой прогон в клоне на OBJECT: env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 bash scripts/check_zones.sh) → rc 1; отказ РОВНО по трём коммитам × два окна: 'FAIL коммит вне зоны: architect 3157dc61|0bb025e2|eec120d6 contracts/161-revizija-mekhanizmov-proektnaja-raskladka.md — зона автора (объединение всех замороженных): …'; итоговая строка «замороженных контрактов: 152 · объявленных авторов: 5 · коммитов в диапазонах: 46660 · проверено по зонам: 11284». Дельта-коммит baa080c2 (только probe.py) в отказ НЕ входит — fixtures/workshop_project/ уже в союзе зон architect. Draft-признание (023 iv) закрыто по ancestry, а не по отсутствию тега: id/CONTRACT/161 жив на origin (fd10828b → 15e32aa0 «160 (architect): черновик двери в main; локальный»), но 15e32aa0 НЕ предок ни одного коммита кандидата и не предок main (merge-base --is-ancestor — NO всюду); рука А (тег на самом судимом коммите) тоже неприменима.

Юридическая обязательность двери — НЕТ блокировки переноса: freeze_contract.sh не вызывает check_zones (чтение кода); land_agent.sh не гоняет полный барьер (только реестр ролей через lib_zones — committer в множестве авторов ЗОНА-строк); CI-ключ check_zones (шард ap3) = verify_antiplacebo --scope check_zones = case-фикстуры в toy-репо, НЕ полный барьер по живому дереву; .githooks check_zones не зовут; «ЗОНА critic: verdicts/critic/» заморожена с контракта 011 — перенос вердикта от заморозки 161 не зависит. Механической блокировки «дверь требует freeze, freeze требует ту же дверь» НЕТ: заморозка не требует check_zones, перенос не требует полного check_zones.

«После freeze само пройдёт» — ДОКАЗАНО живьём для ЭТОГО кандидата (одноразовый клон scratch-F161): после-ленд дерево = main 70fd1008 + merge baa080c24 (файлы кандидата побайтово идентичны — blob-сверка всех 4 файлов; b99c667b — предок кандидата, main после него 161-файлов не менял) + критик-вердикт accept (verdicts/critic/contracts-161-v1.md, user.name=critic) → реальный запуск scripts/freeze_contract.sh: все гейты зелёные, «кап кругов: 4 кругов, заморозка словом владельца» (причина несёт РАЗРЕШИЛ-ВЛАДЕЛЕЦ:, арбитражного файла с титулом «(контракт 161)» в дереве нет) → stdout v1, тег frozen/contracts/161/1 → a8634e9b на коммите вердикта df8e3a9b, реестр перезаписан REPLACE-строкой и самозакоммичен под orchestrator (adcf1add). Повторный полный check_zones на этом дереве → rc 0, FAIL-строк ноль («замороженных контрактов: 153 · коммитов в диапазонах: 47581 · проверено по зонам: 11612»). Интеграционно: батарея на после-ленд дереве воспроизводит честный красный дословно (bare rc1 два класса; --model rc0).

Названные условия двери для оркестратора (наблюдены, не блокируют кандидата): (1) accept-вердикт обязан лежать на HEAD замораживаемого дерева под СЛОТОМ ВЕРСИИ — verdicts/critic/contracts-161-v1.md (v=vmax+1=1; существующие v1-fail/v2/v3 слот не занимают — имя с другим суффиксом freeze не прочитает); (2) кап кругов = 4 (FAIL,accept,FAIL,accept по глобу v*.md) ≥ 3 → причина заморозки обязана нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» либо нужен арбитраж с титулом «(контракт 161)».

## Вердикт

Блокирующая находка 6-го суда (клетка конфликта contracts/161-…md:26 обещала механические доказательства, которых модель не несла) закрыта ровно обещанным свойством: все три проявления реализованы в probe.py на названных строках и доказаны живыми атаками (A — FOREIGN_DIRTY + CONTROL_INVALID; частичная выдача — поймана; ветка/worktree до отказа — пойманы тремя именованными классами), честная таблица сходится (bare ровно 2 класса, --model rc0, --stabs rc0 с четырьмя подменами). Вопрос Астры §2 закрыт с доказательством: до frozen/161/1 полный check_zones честно красен ровно тремя коммитами по пути контракта, переносу вердикта/заморозке/ленду он не препятствует, после заморозки — rc 0, доказано живым прогоном. Противоречий нормам нет. Вердикт: accept.

## Советы (едут с accept, отвечать не обязан)

СОВЕТ (перенос из 6-го суда, актуальность сохранена): contracts/161-…md:16 — механизм размещения внешнего манифеста (куда пишет make_task и как spawn его находит) в контракте не назван; связан сквозным доказательством, но реализатору стоит назвать его в реализационном решении явно.
СОВЕТ (новый, оркестратору): при материализации этого accept — имя файла ровно verdicts/critic/contracts-161-v1.md (слот версии), иначе freeze откажет «заморозка v1 без вердикта критика»; причина заморозки — со строкой «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:».

## Гигиена сессии

Все прогоны — одноразовые клоны /tmp/dev-harness-verify/{critic161-v7-repo,scratch-A161,scratch-P161,scratch-S161,scratch-F161}; push в origin НЕ выполнялся (clone/fetch/ls-remote — только чтение); основное дерево и его .git не тронуты; verify_antiplacebo над живым деревом не запускался; verdicts/critic/contracts-161-v3.md не тронут — вердикт 7/7 целиком в этом отчёте сессии, материализует оркестратор. Минуты не указаны; блокеров не было.
