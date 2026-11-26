# Контракт 229 — Г-1…Г-9: профиль политики судей

КЛАСС ЗАДАЧИ: кодовый — контракт и красная батарея; production реализуется после заморозки.
КЛАСС РИСКА: рисковый — безопасность допуска судей и независимость суда; после реализации adversary → reviewer на одном OBJECT.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — станционные двери, продуктовую модель не меняем.
КОНТЕКСТ: R-0114 владельца 25.11: Г-1…Г-9 одним контрактом с judges.policy, включая Г-2/Г-3; R-0102: настройки данными, не литералами. База 78672b79bac88b9c3765b3d9b53cd983d4a13728. Источник: принятый ADR 2026-11-21-plan-fable, полный FABLE-RECOMMENDATIONS-1121.md §(г), Ш-6 и PLAN-V9.md. sourceCanon профиля не объявлен.
КОНТЕКСТ: измеренная боль источника — девять обрывов 20.11, шесть за 46 минут 21.11; замечания к проверке при честном production задерживали приёмку. Обещание: среда и обрыв не становятся содержательным FAIL; предел повторов не исчезает из-за нового имени сессии. Статические клетки доказывают доставку нормы, не поведение LLM; поведенческие — rc настоящих CLI, Git-коммит вердикта, START/RELEASE и файл hook.
СДАЧА: fixtures/workshop_project/judges_policy_229/SDACHA.md

## Предмет

Один вертикальный результат — действующая политика судей берётся из профиля и отличает содержательный суд от невозможности суда. Включены все Г-1…Г-9, без скрытого переноса Г-2/Г-3 в следующий номер. Не вводятся новые модели, второй реестр судей или новая система очереди. Перечень клеток, мутантов и якорей не замораживается: предмет — инварианты и rc-команды.

Порядок: architect сдаёт конструкцию → critic → freeze → implementer меняет перечисленные швы → orchestrator подключает CI и доставляет политику в установку → adversary → reviewer → ленд/done. Production в architect-пачке не меняется. Модель — контроль достижимости отдельных швов, не эталон переноса файлов целиком поверх свежей реализации.

## Существующее

| Правило источника | Уже есть | Дельта станции / граница |
| --- | --- | --- |
| Г-1: среду готовит харнесс | 172 pre_judge prepare фиксирует OBJECT и detached runtime; 206 нормализует verdict-путь, cp/mkdir и даёт норму собственной isolated-копии | setup в фактической копии судьи: HEAD/ветка, JUDGE_SCRATCH, hooks.judgeSetup; готовая СРЕДА в паке make_task. Собственно ключ hook относится к потоку 227; не реализовать второй читатель |
| Г-2: БЛОК-СРЕДЫ | 167 verdict_sessii сверяет коммит, автора, роль, сессию, OBJECT; --osvobodit доказывает отсутствие вердикта | распознавать третий исход с обязательными командой/rc; RELEASE blok_sredy, исключение из D11; не accept и не FAIL |
| Г-3: два автоповтора обрыва | D11/167 исключает obryv_bez_verdikta; норма разрешает один повтор | ограничить до двух по адресу роли/OBJECT и учёту, не holder; текущий механизм фактически допускает неограниченные последовательные обрывы — обнаруживается прямым чтением krugov_suda, не выдумывается прежний механический кап |
| Г-4: бюджет → арбитр | critic §Быстрый-процесс, orchestrator §Бюджет, freeze_contract:475–574, R-0085 из задания — арбитр/SANKCIJA самостоятельно | пределы данными judges.policy; исчерпание выдаёт адресный ARBITRATION_REQUIRED, orchestrator вызывает arbiter без нового разрешения. Shell не притворяется модельным спавном |
| Г-5: тестовая находка не блок | действующий §Порог допускает блок за обязательную модель/проверку; адресные остановки по adversary переданы заданием (R-0074/R-0080), не являются общим разрешением скрывать production-дефект | при testFinding=residual — ОСТАТОК architect; честность production и классификация находки cognitive-only, ловцы reviewer/arbiter; это изменение нормы, не автоматическая перекраска FAIL |
| Г-6: инварианты + rc-команды | check_contract_frozen охраняет текст контракта; 218 выделяет PR-окно; файлы fixtures сами по себе не frozen-текст | убрать обещания замороженного числа клеток/якорей из новых контрактов и нормы architect; ремонт теста без смены смысла не требует v+1 |
| Г-7: adversary по риску | orchestrator §Порядок судей, critic §Реализация, D14/D59 и 211 D64 | использовать risk-only из policy; неизвестный риск остаётся рисковым. Обычная предупреждающая дверь сама по себе не основание рискового класса |
| Г-8: стоячие правила | профиль 054/184/996, config/agent_models.json и 222 — назначение отдельно от сверки факта | judges.policy — данные; нет эффективного ключа — прежний путь; известное неверное значение — fail-closed |
| Г-9: слово не держит очередь | orchestrator:48,420,423 — batch вопросов, свободный слот получает первую незаблокированную строку kontrol | сослаться и убрать противоречивую фразу «blocked слот не освобождает» только в ожидании слова; новый scheduler не вводится |

224 сохраняет выбор свежего review/adversary по номеру и все F/CID/OBJECT: БЛОК-СРЕДЫ никогда не accept для done. 222 сохраняет модель-факт/назначение/session/OBJECT; 230 охраняет неоднозначные имена трассы и запрещённый fallback, не бюджет повторов. 218 не меняется: ремонт fixtures не разрешает менять инварианты frozen-контракта.

Поиск: contracts/, registry/plan.tsv, scripts/, fixtures/workshop_project и refs исследованы; повторной реализации judges.policy нет. Открытые PR при старте: #1437 (227, отчёт зашивок), #1227 (044), #797 (184). R-0085/R-0074/R-0080 как отдельные записи в доступных docs/owner и registry не найдены; их содержание берётся только из задания, недоступная запись не выдаётся за прочитанную. Суд/очередь реальных проектов и операторское переключение тега — вне записи этой копии, но не вне приёмки rollout.

Сверка живых frozen-блобов: `python3 fixtures/workshop_project/judges_policy_229/catalog.py --frozen` читает `git show frozen/contracts/N/vmax^{commit}:contracts/<файл>`, не рабочий текст. Срез: 140/5, 167/2, 172/2, 211/1, 222/1, 224/1, 218/1, 206/1. У 230 нет frozen-тега: только затравка, это не доказательство готовой нормы.

## Frontier

А — выбран: `judges.policy` = строка `station` (раскрывается из config/judges-policy.json установки) либо полный JSON-объект политики. Репо-юнит перекрывает defaults слоя проекта целиком; нет обоих — старый режим без нового капа/порогов. Станционный профиль явно включает station. Значения по умолчанию только в конфиге, R-0102. Один существующий resolver; известный юнит валидируется JSON Schema. Сводка политики передаётся в пак, а не пересказывается числами в ролях.

Б — частичный объект с неявным слиянием отдельных полей — отклонён: неполная смена политики незаметно наследует разрешённый риск и создаёт второй набор умолчаний в потребителях.

В — новые флаги CLI на каждое правило и список исключений SHA — отклонён: дублирует профиль и Ш-3; следующая сессия опять требует разового слова. Снятие отказных предикатов ради 20 кодов отклонено: цель достигается объединением диагнозов формата.

**Сжатие кодов:** исходная мера Fable `otp CODE` — 28 имён/45 литеральных мест. Объединить 12 имён в существующий BITYJ_VHOD, не менять условий отказа: остаётся 16. Отдельно динамические perenos_otkaz добавляют PEREDACHA_NEDOSTOVERNA и PEREDACHA_REMOTE — совокупно 18, а не ложные «16 всех отказов». Дверь сохраняет детальное поле причины/исправляемую строку после общего кода.

Карта код → судьба и частота — source.json (снимок базы), воспроизводимая команда `python3 fixtures/workshop_project/judges_policy_229/catalog.py`. AGENT_NET, IMJA_NET, GRAMMATIKA_IMENI, SUBJECT_NET_V_ZADANII, SUBEKT_DVA_V_ZADANII, GRAMMATIKA_SUBEKTA, PIN_NET, GRAMMATIKA_PINA, RASHOZHDENIE_PINA, OBJECT_OTSTUTSVUET, SUBEKT_DVA_OBJECTA, GRAMMATIKA_OBJECTA → BITYJ_VHOD; остальные имена сохраняются. GRAMMATIKA_OBJECTA в --sudit недостижим: object_iz возвращает только ok/net/dva; неконформный OBJECT попадает в net. GRAMMATIKA_SUBEKTA остаётся достижимым в --osvobodit/--peredat. Недостижимому default не приписывается ложная живая клетка. Каждому достижимому удаляемому диагнозу предъявлен прежний отказный вход и контроль неизменного учёта.

## Инварианты

1. **Г-1.** prepare сохраняет прежние проверки публикации/детектора/OBJECT. Новый `pre_judge.sh setup --repo R --object O --subject N --role ROLE` вызывается в собственной isolated-копии до предметных команд; HEAD=O, ветка ровно wip/N/ROLE. ROLE из critic/adversary/reviewer/arbiter, N три ASCII-цифры, O 40 lowercase hex. Создаётся короткий R/tmp/j (JUDGE_SCRATCH), symlink наружу запрещён. hooks.judgeSetup исполняется argv-массивом в R с JUDGE_SCRATCH/HARNESS_HEAD/HARNESS_CONTRACT/HARNESS_STAGE=judgeSetup. Ненулевой hook даёт rc 2, БЛОК-СРЕДЫ с командой/rc; не частичный готовый блок. make_task включает готовую команду setup и СРЕДА; фактический pwd берётся после клонирования, адрес доставки WORKTREE не подменяет его.
2. **Г-2.** Первая строка вердикта буквально БЛОК-СРЕДЫ; самостоятельные СРЕДА-КОМАНДА: <непустая команда> и СРЕДА-RC: <1…255>. Прежние commit/author/роль/session/OBJECT-проверки сохраняются. Команда не исполняется читателем вердикта: происхождение отказа оценивает судья/reviewer. Такой коммит даёт RELEASE blok_sredy, не тратит D11, не открывает reviewer после adversary, не даёт accept/done. Поддельная/неполная привязка не является доказанным БЛОК-СРЕДЫ; недоступность refs даёт прежний rc 2 без RELEASE. Содержательные FAIL/accept продолжают тратить круг.
3. **Г-3.** При включённой политике исходный запуск + до двух повторов для каждого из blok_sredy/obryv_bez_verdikta по адресу repoId/subjectId/роль/OBJECT. После третьего такого исхода новый запуск запрашивает арбитра, не бесконечный retry. RELEASE соотносится с последним открытым START holder в том же repo/subject ДО фильтра роли/OBJECT; переименование и чужой scope счёт не обнуляют/не расходуют. Существующая SANKCIJA для содержательного повторного суда не отменяется, адрес не расширяется.
4. **Г-4.** criticCalls/reviewerCalls/adversaryCalls — фазовые пределы содержательных вызовов, исходная станционная конфигурация 2/2/2, onExhaustion=arbiter. Обрыв/среда исключаются, а не объявляются accept. Исчерпание возвращает адресное ARBITRATION_REQUIRED; orchestrator создаёт один arbiter-вызов на адрес с позицией автора, не следующий полный critic. freeze не создаёт тег до предусмотренного решения. «К ВЛАДЕЛЬЦУ» — единственный автоматический выход к владельцу; арбитраж сам по себе не accept. Исполнение модельного вызова cognitive-only в orchestrator, ловец журнал task/СУД и reviewer; фикстура доставки нормы не доказывает реальный спавн.
Для явно заданного полного объекта с onExhaustion=stop исчерпание даёт BUDGET_EXHAUSTED без START и без запроса арбитра; станционная строка station использует arbiter. Оба действия — данные профиля, не безусловный литерал в счётчике.
5. **Г-5.** testFinding=residual: доказанный дефект production по инварианту остаётся FAIL, находка только к тесту при честном production — ОСТАТОК с адресом architect. Нельзя механически объявить код честным по зелёной батарее или менять первую строку чужого вердикта. Классификация cognitive-only, ловец содержательный reviewer/arbiter; механическая часть — доставка нормы через role-канал.
6. **Г-6.** Ремонт fixtures без изменения названных инвариантов разрешён без v+1; изменение обещания/порога/границы риска — по прежнему owner/v+1. check_contract_frozen и 218 не ослабляются. Cognitive-only содержание договора проверяет critic; структурная часть — наличие нормы в роли architect.
7. **Г-7.** adversary=risk-only, обычный → reviewer, рисковый/неизвестный → содержательный adversary → reviewer. Предупреждение само по себе не основание риска; подмена класса, обход D64 и самосуд не разрешены. Грамматика риска и модельные назначения не меняются.
8. **Г-8.** Полный объект имеет только criticCalls/reviewerCalls/adversaryCalls (целые ≥1), environmentRetries/interruptionRetries (целые ≥0), onExhaustion (arbiter|stop), adversary (risk-only), testFinding (residual|block), waitingOwner (yield-slot). Все поля обязательны; JSON boolean не integer. station раскрывается из конфигурации установки. null/массив/неполный объект/неизвестное поле известной policy — fail-closed до START; отсутствие эффективного ключа не ошибка. Неизвестные ИМЕНА других ключей сохраняют М-0 предупреждение. Профиль читается через существующий resolver, не raw profile_get с fallback на битом JSON. Объект сливается юнитом. Схема/значения — один конфиг, потребители чисел не дублируют.
9. **Г-9.** waitingOwner=yield-slot: вопрос в общий batch с рекомендованной готовой строкой, слот получает следующую независимую незаблокированную строку kontrol. Живой автор/судья не снимается ради нового: О-1/О-2/О-3 сохраняются. Порядок выбора cognitive-only, ловцы HANDOFF/журнал task/reviewer, не новый scheduler.

## Батарея и демаркация

`fixtures/workshop_project/judges_policy_229/`: probe.py, build.py, catalog.py, policy.json, model/, stabs/, source.json, SDACHA.md, red_judges_policy_229.sh. source.json хранит sha256 носителей, frozen-срез, частоты и карту судьбы кодов; связи определяет код build.py. Стабы к ветвям привязывает architect по коду, НЕ проза контракта.

Конформные миры: настоящий Git, предмет/HEAD/вердикт из коммитов, журналы omp-формы и JSONL START/RELEASE, валидный профиль с настоящим resolver; идентификаторы, пути и SHA не оракул. Ожидания снимаются в память до вызова. Негативные форматные входы отделены от положительных. Валидный контрпример — инвариантность к значениям и расхождение на поддерживаемом входе. Ошибка инструмента/носителя/таймаут — rc 2, не доказательство поимки. Ни Git, ни resolver, ни hook не заменяются двойником.

Структурные role-клетки по Г-1…Г-9 не подменяют живой эффект норм. Модель ролей содержит только канонический раздел для проверки доставки; это не полные роли и не эталон их перезаписи. Канонические строки — policy.json; вставка в роли вместе с удалением противоречащих старых формулировок производится после адресного слова владельца.

## Приёмочный критерий

W означает `bash fixtures/workshop_project/judges_policy_229/red_judges_policy_229.sh`.

- Дано дерево до реализации; `W --repo .` → rc 1 с именованными красными клетками. После реализации та же команда → rc 0, KRASNYH 0. Отсутствующий helper не подменяет все остальные клетки одним общим отказом.
- Честный контроль; `W --model` → rc 0, KRASNYH 0. Обе полярности среды/содержательного суда, повторов, scope и setup различаются собственными эффектами.
- Отдельное предъявление каждой связи; `W --stabs` → rc 0, ZHIVYH 0; синтаксически неисполнимый носитель не считается пойманным. `W --catalog` → rc 0, непустой уникальный каталог и совпадение хешей/связей.
- Форма; `W --sintaksis` → rc 0: Python ast, bash -n, настоящий pinned shellcheck обёртки; полный inherited bash baseline не переписывается ради старых lint-диагнозов.
- Мера бюджета кодов; `W --model --case code-budget` → rc 0, литеральных otp-кодов ≤20; после реализации `W --repo . --case code-budget` → rc 0. Динамические коды перечислены отдельно catalog.py, защиты передачи сохранены.
- Грамматика формы до суда; `bash scripts/pre_critic.sh contracts/229-g1-g9-judges-policy.md` → rc 0; `bash scripts/check_sdacha.sh . contracts/229-g1-g9-judges-policy.md --run` → rc 0.
- После реализации сохранить соседей: `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .` → rc 0; `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .` → rc 0; `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo .` → rc 0. Перепинить только диагнозы формата в 140/профиле parsing_hygiene, без смены rc и защит. 218/224/222 остаются зелёными в своих действующих командах, их носители не переписываются этим предметом.
- Проводка orchestrator: CI check:judges-policy-229-family-selftest до реализации выполняет --model/--stabs/--sintaksis; после — --repo ./--stabs/--sintaksis. `bash scripts/gen_ci_steps.sh --check` и `bash scripts/check_provodka.sh . contracts/229-g1-g9-judges-policy.md` → rc 0 после подключения.
- Rollout до done: orchestrator предъявляет три последовательных настоящих суда одноразового проекта с setup и нулём RELEASE obryv_bez_verdikta на вспомогательной операции; отдельно БЛОК-СРЕДЫ → ремонт → автоматический повтор, исчерпание → ровно один task arbiter, тестовый ОСТАТОК при честном коде и production-FAIL, обычный/рисковый порядок, пропуск ожидающего owner предмета. Фактические СУД/START/RELEASE/task-трассы и команды/rc прикладываются к review. Это живая поведенческая приёмка cognitive-only норм, не выдаётся за уже исполненную локальной статикой.

## Модель угроз

ЗАЩИЩАЕТ:
- От превращения доказанного отказа среды в расход содержательного круга: Git-привязка, отдельная причина RELEASE, адресный счёт повторов и негативные CLI-миры.
- От бесконечных технических повторов под новыми именами и от расходования чужого scope: сопоставление START/RELEASE до фильтрации роли/OBJECT.
- От снятия условий отказа ради численной цели: объединение только диагнозов, сохранение rc/учёта/условий, явный census динамических кодов.
- От второго источника чисел политики и от пропуска известного неверного значения: один конфиг/JSON Schema, существующий resolver, причинные клетки политики.

НЕ ЗАЩИЩАЕТ:
- От ложного описания судьёй команды среды или ложной декларации честности production: содержание не выводится из формата; ловцы reviewer/arbiter, реальные трассы и production-контрпример.
- От непослушания LLM норме Г-4/Г-5/Г-6/Г-7/Г-9: cognitive-only, ловцы журнал task/СУД, critic/reviewer и rollout; статический зелёный не считается поведенческим доказательством.
- От подмены установки/Git/PATH/схемы одним uid и одновременной перезаписи источников: прежняя граница станции; ловцы isolated и review. Чужие каталоги записи не разрешаются.
- От дефектов модели-факта/фолбэка 230 и порядка свежести 224: эти ловцы сохраняются, политика бюджета их не заменяет.

## Зоны

ЗОНА architect: contracts/229-g1-g9-judges-policy.md fixtures/workshop_project/judges_policy_229/
ЗОНА implementer: scripts/zamok_predmeta.sh scripts/pre_judge.sh scripts/make_task.sh scripts/freeze_contract.sh scripts/profile_resolver.sh scripts/judges_policy.py config/judges-policy.json harness.project.json roles/critic.md roles/adversary.md roles/reviewer.md roles/architect.md roles/orchestrator.md .omp/agents/critic.md .omp/agents/adversary.md .omp/agents/reviewer.md .omp/agents/architect.md .omp/agents/orchestrator.md fixtures/workshop_project/odin_agent_140/ fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

## Пересечения

Файл замка — один поток на всю длину плана; 140/167/211/208 уже в базе. Общие make_task/profile_resolver/freeze — после 226 и соответствующего ключа 227, без перезаписи чужой дельты. У 224 и 218 нет пересечения production-путей замка: их выбор свежести/PR-окна сохраняется. У 222 общие роли, но check_sud_model/judge_gate/назначения не меняются; у 230 только смежная модельная сверка, ни один её production-путь не заявлен в зоне 229.

ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 только слияние диагнозов формата, policy и Г-2/Г-3; условия изоляции/сдачи/атомарности сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 167 расширение причины RELEASE и числа технических повторов; доказательство коммита/refs сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 211 класс риска D64 не меняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 208 только D11 среды/повторов; предковость/публикация/кодовая граница D9 и адрес SANKCIJA сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 140 новый setup не меняет prepare OBJECT/runtime.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 172 новый setup; прежние режимы/отказы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_judge.sh — 206 setup в собственной копии, нормализация verdict-пути сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 222 только политика кругов/Г-5, назначение моделей сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 222 только политика кругов/очереди, назначение и факт модели сохраняются.
ПЕРЕСЕЧЕНИЕ architect: contracts/229-g1-g9-judges-policy.md — 993 новый контракт станции.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/judges_policy_229/ — 054 новая семья.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/judges_policy_229/ — 055 новая семья.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/adversary.md — 002 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/adversary.md — 003 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/adversary.md — 005 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/adversary.md — 010 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/adversary.md — 011 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 002 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 003 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 005 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 010 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 011 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 016 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 050 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/critic.md — 002 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/critic.md — 003 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/critic.md — 005 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/critic.md — 010 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/critic.md — 011 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 002 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 003 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 005 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 010 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 011 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 215 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 002 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 003 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 005 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 010 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 011 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 050 только производная нормы 229.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh — 041 только новые диагнозы формата; полярности сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/odin_agent_140/ — 105 только перепин объединённых диагнозов.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/odin_agent_140/ — 140 только перепин объединённых диагнозов.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 005 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 008 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 011 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 015 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 002 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 003 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 005 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 008 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 010 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 011 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 015 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 016 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 037 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 038 только Г-6 через role-канал.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 041 только Г-6, гигиена парсинга сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 050 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 066 только Г-6.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 005 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 008 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 011 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 015 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 041 только политика 229; гигиена сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 043 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 005 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 008 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 011 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 015 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только политика 229, маршрут форка сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только политика 229, минт не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только политика 229 через role-канал.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 215 только политика 229.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 005 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 008 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 011 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 015 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 027 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 038 только Г-2/Г-5 через role-канал.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 050 только Г-2/Г-5.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только шаг 229.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 229.

## Проводка

ПРЕДПОСЫЛКИ:
- setting bash, git, python3/jsonschema, jq, shellcheck 0.11.0; новых secrets/variables/environments нет. Ключ hooks.judgeSetup потока 227 должен быть доступен до интеграции Г-1; общий файл меняется одним потоком.
- setting Правка role-канала и производных только после адресного слова владельца; переход установки проектов на тег проводит orchestrator, не эта копия.

ПРОВОДКА:
- guard=fixtures/workshop_project/judges_policy_229/red_judges_policy_229.sh
- role=roles/critic.md «При judges.policy.testFinding=residual замечание только к тесту при честном production-коде — ОСТАТОК в очередь architect, не FAIL; нарушение инварианта контракта на production остаётся блокирующим. Оценка честности cognitive-only, ловец reviewer.»
- role=roles/orchestrator.md «При ARBITRATION_REQUIRED созови arbiter автоматически с открытыми блоками и позицией автора; accept и ещё один critic из запроса арбитража не следуют. Владельцу только К ВЛАДЕЛЬЦУ; повторный запрос одного адреса не порождает второго арбитра.»

ПРОВОДКА-ЭНФОРСМЕНТ: роли — канал поведения; существующий замок — механика счёта и формата, батарея — приёмка. Чистый guard не выдаётся за замену роли. Все канонические строки для прочих ролей берутся из policy.json; новые числа в роли не добавляются.

## Вопросы владельцу

Адресное разрешение на правку roles/critic.md, roles/adversary.md, roles/reviewer.md, roles/architect.md, roles/orchestrator.md и их производных: внести Г-1…Г-9, убрать противоречащие старые нормы (платный обрыв как следующий круг, ровно один повтор, тестовая находка как самостоятельный блок, blocked-слот ожидания слова). Рекомендация — разрешить в рамках принятого плана Fable; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ этой пачкой не сочиняется.

Граница остаточного риска: автоматический формат БЛОК-СРЕДЫ не доказывает правду команды и честность production; предложен действующий содержательный reviewer/arbiter, а не самописный семантический оракул. Дробление Г-1…Г-9 не предлагается; общий файл замка и role-канал последовательно в одном номере.

## Незаполненные требования:
- Адресное слово на role-канал и живая приёмка rollout не получены/не исполнены architect-пачкой; до реализации/установки их предъявляет orchestrator. Это не разрешение заморозить конфликтующие нормы молча.
