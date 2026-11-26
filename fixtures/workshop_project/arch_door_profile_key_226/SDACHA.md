# СДАЧА 226 — профильная дверь архитектуры

Обещание: hooks.archBrief вместо селектора имени и адреса продукта; неизвестность профиля не выключает страж. Наблюдение: настоящий CLI на Git/Node/профильных мирах, раздельные stdout/stderr, HEAD/refs/файлы и argv gh. Ожидания литеральны и в памяти до субъекта. Production, реестры, CI и чужие фикстуры не меняются; overlay существует только в model/. База генерации 5b8ae0cdca9429d9d651c19d2775016e57ce271f, база исправления cbce7ecc43a2749164e972dc2ef911cc02ca3176.

Frontier сохранён: отсутствие ЛИСТА в корректном repo-профиле, даже при lock, и false — выключение; owner/repo при lock — включение. Это сохраняет отсутствие автовключения по lock и переключатель 187/203. Нет ФАЙЛА при lock — ARCH_PROFILE_MISSING; повреждение/недоступность профиля или объявленного слоя — ARCH_PROFILE; известный лист в defaults (включая false или конфликт с repo) — ARCH_PROFILE_LAYER. Неизвестные имена остаются предупреждениями М-0. Backend-ключ доставляет orchestrator отдельным PR проекта до установки 226.

КЛЕТКИ: 954 (было 933). МУТАЦИИ: 61 (было 47). СВЯЗИ: 79 (было 63). Носители: 69 (8 честных, 61 изменённый); shell с обёрткой: 68. Меры: CASES/probe.py, MUTATIONS/build.py, source.json с sha256 и исполняемый catalog. Все прежние клетки, ожидания, носители и связи сохранены. Публичный слой: 131 уникальный сырой вход после устранения дублей, отдельно от внутренней сетки 862. База ремонта Arb226b: 8bfeab16bc227f05ed1ebe46043bcf122f8a66b5; меняется только батарея, frozen-контракт и production неизменны.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-226-v1.md

Историческое Red-до: до production-реализации W --repo . давала rc 1, KLETKI 56 KRASNYH 45 на OBJECT=1ab6f19bda3ac01d15f0e9adce9f24e542400da2; свидетельство — verdicts/critic/contracts-226-v1.md §«Доказательства». Текущая честная production на c41a1aa3fa362ec233c511924e22fec3ecb5229e с расширенной батареей: W --repo . → rc 0, KLETKI 71 KRASNYH 0.

## Двери

- Repo-posle · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo . · 0 · 0
- Model · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --catalog · 0 · 0
- Regression · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --regression · 0 · 0
- Context · fixtures/workshop_project/arch_door_profile_key_226/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/226-arch-door-profile-key.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа, кодовый предмет, рисковый процессный страж; production после freeze · - · -
- К-02 · чисто · вход: R-0103/R-0102, Л10; Б-1 закрыт различением файла и листа, таблица состояний контракта · - · -
- К-03 · чисто · вход: 203/1 187/3 170/1 188/2 186/2 193/3 184/1 996/2; прежние ожидания 203/pin186 не меняются · - · -
- К-04 · чисто · вход: context.py по высшим frozen, точные зоны без расширения implementer, отдельный backend PR · - · -
- К-05 · чисто · вход: W --model; JSON судит существующий resolver, metadata HTTP отдельно от argv · - · -
- К-06 · чисто · вход: ошибки среды/носителя rc 2; INVALID_MUTANT не засчитывает infra-отказ · - · -
- К-07 · чисто · вход: настоящий make_task и pin CLI, реальные pin/HEAD/merge; полный контроль и grid на реальном jq · - · -
- К-08 · чисто · вход: W --stabs, 61 мутант и 79 отдельных связей; все прежние связи сохранены; управление наблюдается публично · - · -
- К-09 · чисто · вход: независимый посимвольный оракул A/B; внутренняя сетка 862 и отдельный неусловный публичный слой 131 уникального входа · - · -
- К-10 · чисто · вход: rc/именованная причина в stderr, пустой stdout отказа, HEAD/refs; layer-freeze/done и layer-door · - · -
- К-11 · чисто · вход: CASES и ожидаемые значения в памяти до субъекта; gh-calls только наблюдение, хеши носителей до запуска · - · -
- К-12 · чисто · вход: настоящий jq/resolver, git, node, bash -n и пин shellcheck, без двойника валидатора · - · -
- К-13 · н/п · новых секретов/сетевых разрешений нет, батарея offline · - · -
- К-14 · чисто · вход: other-absent/backend-absent при lock, explicit-false/backend-false, enabled/no-pin, minimal/mixed/long, unknown-sibling и unknown-layer-sibling · - · -
- К-15 · чисто · вход: catalog 954/61/79, carriers 69, PUBLIC_UNIQUE_INPUTS 131; отдельные model/stabs и regression 203/pin186 · - · -
- К-16 · чисто · вход: неизвестность профиля и ошибочный слой отказывают до пака/тегов; честное отсутствие листа не стало автовключением; key-toggle и argv сохранились · - · -
- К-17 · н/п · станционный конфигурационный предмет не меняет продуктовую модель/writers/isolationKeys · - · -

## Дельта

- К-02 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell missing-profile-door · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell layer-conflict · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell malformed-profile-door · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model · 0 · 0
- К-01 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --catalog · 0 · 0
- К-08 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo . · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --stabs · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo . · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell public-control-cr · 0 · 0
- К-16 · клетка · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell public-duplicate-hooks-last-cr · 0 · 0

## Закрытие Б-1 по классу

Способ — канон/инструмент: расширение существующего resolver и общего arch187_profile/scope, не второй форматный валидатор. Мутация критика «нет файла = выключено» и соседний мир «без файла и без lock» различены. Ошибочный слой проверен на owner/repo, false и двух объявлениях, через make_task/публичную дверь/freeze/done. Повреждение проверено на repo JSON, project JSON и отсутствующем объявленном слое. Новых судящих предикатов нет: judge/HEAD/TAG/M0_WARNING/INVALID_MUTANT не менялись; новые клетки используют их прежний оракул. Новых обещаний вне Б-1 нет.

Адресные стабы и связи живут только в build.py/source.json: st18 — missing-profile-door, st19 — layer-cannot-enable/conflict/false, st20 — malformed-profile-door/missing-layer-door/malformed-layer-door. Честные противоположности: missing-profile-no-lock; корректный repo без листа и false; owner/repo; неизвестный defaults.hooks.futureHook. Все проверены полным --model и до мутантов в --stabs.

## Закрытие Б-2 Adv226 по классу

Способ — клетка: отдельные отрицательные литералы и rc 1 с предметной причиной `значение вне алфавита`; новые положительные контроли проверяют полный merged hooks с неизменённым значением. Все ожидания в CASES до запуска resolver; judge не менялся. Два мутанта вердикта воспроизводятся дословно на настоящем profile_resolver.sh в одноразовых Git-клонах; симметричные изменения проверяют начало второй половины, точный конец и внутренний пробел. Привязки исполняются кодом build.py/source.json, не этим текстом. Эталонный regex уже соответствует контракту, его не меняем.

Полные контроли `owner/repo`, `o_w-n.e/r_e-p.o`, `0wner/9repo` остаются зелёными: точный конец против конечных SP/TAB/LF; буква/цифра в начале против _/-/. в каждой половине; разрешённая внутренняя пунктуация против внутренних пробелов. Двери и обязательства сверх грамматики Б-2 не добавлены.

## Наблюдаемые результаты первого исправления (исторические)

W --repo . на OBJECT с расширением: rc 1, KLETKI 56 KRASNYH 45. Прежние 35 красных сохранены; добавились layer-cannot-enable и missing-profile-door, missing-layer-door, malformed-profile-door, malformed-layer-door, layer-conflict, layer-false, layer-door, layer-freeze, layer-done. missing-profile-no-lock и unknown-layer-sibling зелены.

W --model: rc 0, KLETKI 56 KRASNYH 0 (65.95 с). W --stabs: rc 0, SVJAZI 25 ZHIVYH 0 (156.05 с). W --sintaksis: rc 0, SINTAKSIS 25 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30. W --catalog: rc 0, KLETKI 56 STABY 18 SVJAZI 25. context.py: rc 0, FROZEN 199 BLOBS 199 OVERLAPS 123 MISSING 0. W --regression: rc 0, CELLS=21 FAILURES=0, pin186 5/5; ожидания не ослаблены (47.46 с).

## Процесс

Пишется только собственная isolated-копия; WORKTREE — адрес доставки. Общий NABLIUDENIA_ARCHITECT.md в wip не правится, номера А вручную не выдаются. Процессное наблюдение для main: заданная база cbce7ecc4 предшествует отдельному коммиту вердикта 1747cff791; gate дельты требует вердикт именно в HEAD, не только доступный git object. Проверка сдачи поэтому требует сборки кандидата с уже закоммиченным Crit226, без копирования/переавторства его файла в architect-зону. Источник: check_sdacha.sh:293. Риск — ложная краснота формы, не дефект продукта; ловец — корректный verification-base оркестратора.

## Формальные двери исправления

В сетевом клоне `tmp/clean226b` внутри своей копии HEAD=1747cff791e39043b0742ad85076bf9a4529e526 (предыдущий вердикт уже закоммичен); поверх скопированы только контракт и семья кандидата, production совпадает с OBJECT. Единственный remote — канонический origin. Прогоны последовательные, TMPDIR внутри клона, VALIDATE_STD_SHELLCHECK задан, SDACHA_TIMEOUT_SEK=600 / SDACHA_BUDZHET_SEK=2400.

`bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md` → rc 0, `КРИТИК: дверь зелёная` (314.74 с). Затем отдельный `bash scripts/check_sdacha.sh . contracts/226-arch-door-profile-key.md --run` → rc 0, `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)` (363.96 с). Таймаутов не было. Эти прогоны повторно исполнили полный model/stabs/регресс и три адресных дельта-команды; изменённые lists/counts сверены исполняемым catalog. Временные клон и драйвер не входят в сдачу.


## Прогоны Б-2 Adv226

На базе c41a1aa3fa362ec233c511924e22fec3ecb5229e с дельтой только этой семьи, последовательно, TMPDIR внутри isolated-копии:

Исторический W --repo .: rc 0, `KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0`.
Исторический W --model: rc 0, `KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0`.
Исторический W --stabs: rc 0, `KLETKI 71 KRASNYH 0 SVJAZI 32 ZHIVYH 0`; каждая новая связь CAUGHT.
Исторический W --sintaksis: rc 0, `SINTAKSIS 31 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30`.
Исторический W --catalog: rc 0, `KLETKI 71 STABY 24 SVJAZI 32`.
Исторические check_sdacha/pre_critic были зелёными ДО последней записи этого раздела. На закоммиченном fc525aad2 оба rc 1 (Adv226b, подтверждено Arb226): маркированные ряды вне машинной секции. Их прежний rc 0 не относится к окончательному блобу. [INFERENCE] Расхождение копии и чистого клона объясняется правкой листа после проверки, а не свойствами клона.
Исторический gen_ci_steps --check: rc 0; CI вне зоны architect.

Два отдельных сетевых Git-клона канонического origin внутри собственной `tmp/`, каждый detached на c41a1aa3fa362ec233c511924e22fec3ecb5229e. В каждом изменена только строка jq-предиката resolver дословно из Б-2:

```text
завершающий пробел: W --repo <клон> rc=1
RED bad-trailing-space RC,DIAGNOSIS,PARTIAL_OUTPUT (resolver rc=0, stderr пуст)
KLETKI 71 KRASNYH 1 SVJAZI 0 ZHIVYH 0

первый символ владельца _: W --repo <другой-клон> rc=1
RED bad-owner-underscore RC,DIAGNOSIS,PARTIAL_OUTPUT (resolver rc=0, stderr пуст)
KLETKI 71 KRASNYH 1 SVJAZI 0 ZHIVYH 0
```

Процессная рефлексия: новых дефектов регламента или инструмента в этом круге не обнаружено. Общий журнал А не меняется в wip; предыдущие наблюдения сохранены выше. Frozen-контракт с исходными счётчиками не переписывался по заданию; текущие измеренные счётчики находятся в catalog и этом листе.

## Исполнение Arb226

К-01 — канон/инструмент: машинные двери имеют четыре поля, дельта — пять полей с полным argv; старые полезные дельты сохранены, исторические логи — немаркированные абзацы. Лист не вызывает сам себя. Окончательные check_sdacha --run и pre_critic выполняются после коммита в чистом origin-клоне на точном SHA; их сырые rc передаются докладом, после проверки лист не дописывается.

К-08/09 — канон/инструмент с адресными клетками: конечная сетка порождается в существующих CASES. Независимый оракул grammar_accepts проверяет точный JSON false, один slash, непустые половины, ASCII A в начале и B далее; ожидания вычислены до субъекта. Все оси раскрыты независимо на валидном основании, включая NUL, односторонние SP/TAB/CR/LF, Unicode-буквы/цифры и длины 1024 каждой половины. Стабильные имена несут ось, позицию и код символа.

Внутреннее исполнение jq: один реальный мир и native bash xtrace снимают фактически исполненные argv валидатора/merged; вся прежняя пакетная сетка сохранена. Это внутренний субъект, НЕ оракул и НЕ публичный отказ: jq stdout `false\n` не считается пустым stdout resolver. Ошибки извлечения/исполнения шва — rc 2. Независимый A/B-оракул и ожидания вычисляются до субъекта. Публичный CLI: отдельный неусловный слой на всех представителях Arb226b, новый процесс resolver для каждого уникального сырого входа; только идентичный вход в одном носителе переиспользует уже снятое наблюдение. Для отрицательных входов проверяются rc ровно 1, строго пустой stdout и точная строка предметной причины в stderr; для положительных — JSON, точные тип/значение/origin, M-0 и исключение неизвестного sibling. HEAD/refs/профиль не меняются. Старые двери, слой и pin остаются интеграционными.

Новые мутации и адресные связи задаёт только build.py/source.json: дословный FALSE/False, каждая позиция casefold, тип/число вместо false, trim, первые знаки обеих половин, slash в каждой середине, Unicode-классы в каждой позиции, пустые половины, начало/точный конец, лимит длины и изменение регистра merged. Предыдущие 24 мутации не менялись.

НЕ ЗАЩИЩАЕТ: конечная пакетная сетка и публичные представители разделений не доказывают отсутствие произвольной ошибки на непредставленном значении, сочетании осей или длине, в том числе адресного обхода входа в валидацию только на таком значении; production обязана соблюдать весь инвариант 1. Ловцы — reviewer (полный diff, достижимость валидатора, независимость оракула, соответствие всех отказных каналов) и CI (неусловное исполнение публичных свидетелей и адресных стабов на предъявленном SHA).

Процессная рефлексия этого вызова: подтверждён измеренный Arb226 дефект «проверил → дописал отчёт → сдал другие байты»; подпорка — коммит до чистого прогона и запрет последующей правки листа. Общий журнал А не пишется в wip по действующей норме.

## Исполнение Arb226b / Б-1 Adv226c

Способ — канон/инструмент + клетка. Первая техника — настоящий публичный resolver, стандартный JSON-парсер для last-key-wins и прежний независимый A/B-оракул; одним внутренним jq нельзя доказать достижимость и отказные каналы, поэтому нужна клетка публичного результата. Адресные замены и связи определяет только build.py/source.json; новые guard-носители не зависят от извлечения jq. Сохранены все прежние 47 мутаций и 63 связи. У каждого нового проверяющего предиката есть адресный мутант; честные противоположности — корректный/отсутствующий/false лист, пустой hooks, M-0, оба порядка дубликатов, разрешённая пунктуация и буквальная эквивалентная запись предиката/guard. Эквивалентность судится результатом CLI, а не строкой xtrace. rc 2 с подлинной предметной причиной — неверный код продукта, не корректный отказ; инфраструктурные 126/127 и rc 2 без предметной причины не засчитываются пойманным стабом.

Публичные оси и позиции перечислены данными source.json/public: тип 9; false/нормализация 10; разделитель 11; ASCII 24 (6 позиций × 4 знака); границы 20 с настоящим CR; Unicode 17; длины 3; внешний hooks 9; сырые дубликаты 4. Дополнительно сохранены прежние resolver-свидетели, неизвестный sibling, mixed/long и адресные aliases управления. Число 131 — объединение сырых входов, не сумма пересекающихся осей.

Census читает все актуальные высшие frozen-блобы. Для непредкового frozen печатает точные пересечения, tag и commit с причиной «поздний frozen: не предок носителя»; ретроактивное дополнение frozen-контракта не требуется. Предковые пересечения по-прежнему обязаны быть объявлены, пустая выборка красна. Теги не удаляются.

Сдача проверяется после фиксации SHA в чистом origin-клоне; сырые rc, полный CI-замер и CR/эквивалентный контроль передаются отдельным итогом без дописывания этих байтов после прогона. Вес 240 — LPT, не timeout. Процессная рефлексия: публичность свидетельства должна быть видна в машинном каталоге; иначе зелёный внутренний предикат маскирует непроверенную достижимость.
