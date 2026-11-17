КЛАСС ЗАДАЧИ: кодовый (контракт + красная батарея; реализация — implementer после заморозки). КЛАСС РИСКА: рисковый — гейт приёмки done: ошибка двери выдаёт done-тег предмету с невлитой реализацией или без независимых судей (основание — класс «авторизация» закрытого перечня слова владельца 2026-10-24: дверь решает, кому поставлен тег приёмки).

# Контракт 201 — done-дверь: содержательная сверка (привязка accept к последней заморозке, влитость внешней реализации, адверсарий рисковым, имя check-run arch)

КОНТЕКСТ: слово владельца 2026-11-17 «делай все согласно рекоммендаций» п.10 (через консультанта, SLOVO 14:49:51Z); задание /tmp/dev-harness-verify/orch/task-201-architect.md; данные /tmp/dev-harness-verify/consultant/VerifyDone-1117-raw.json, VERIFY-done-content-1117.md §«Дефект done-двери», ARCHCOL-projects-1117.md §5; норма судей и класса риска — roles/orchestrator.md §«Порядок судей и класс риска»; грамматика двери — frozen 038/2 §Инварианты 4; 187а — frozen 187/2.

## Слово владельца

2026-11-17 «делай все согласно рекоммендаций», п.10 (дословно, через консультанта): «НОВЫЙ ПРЕДМЕТ станции (следом или вместе с 9, по зонам): ремонт done-двери — (а) accept ревьюера на объект с реализацией ПОСЛЕДНЕЙ заморозки, (б) внешняя реализация влита в продукт, (в) рисковым — accept адверсария на тот же объект; (г) имя check-run arch: дверь ищет буквально «arch», в CI бэкенда «arch (пин внешней архитектуры, model fitness + code-ratchet)». Доказательства — VERIFY-done-content-1117.md §«Дефект done-двери», ARCHCOL-projects-1117.md. До ремонта ЛЮБОЙ done — только после содержательной сверки (roles/orchestrator.md:38): дверь пропускала 141/157/163/991/999 при невлитой реализации.»

## Данные

- Сырой замер консультанта 2026-11-17: `/tmp/dev-harness-verify/consultant/VerifyDone-1117-raw.json` (3641 строка: три репо — dev-harness/Complior-back/Complior-mob; для каждого предмета frozen/done-теги и rc одноразового прогона `done_contract.sh`); разбор: `VERIFY-done-content-1117.md` §«Дефект done-двери»; имя check-run: `ARCHCOL-projects-1117.md` §5.
- Пять ложных зелёных двери (rc 0 при содержательной неготовности; все — исполненные G-прогоны консультанта): **141** (выбран impl-v1-accept/F141/1, продуктовая реализация mob#172 OPEN, в main нет трёх требуемых файлов), **157** (рисковый; последний адверсарий — FAIL), **163** (принят только этап A, продуктовые PR OPEN), **991** (freeze-accept F991/2 при последней /3), **999** (v4-accept F999/1 при последней /2).
- Честные кейсы, которые ремонт ОБЯЗАН не запереть: **129, 186** (свежий post-freeze accept; 186 — рисковый с same-OBJECT adverse-accept Adv186Narrow 4448dd15), **190** (done поставлен тем же маршрутом); «фактически закрыты, повторный тег не нужен» — 080/091/118/125/133/153 (не_door-кейсы).

## Существующее

Сверка по дереву (main 174be3b4 + реестровая строка 201):

- Писатель `scripts/done_contract.sh` (339 строк): env-гигиена; `project_paths_resolve` (996); NNN-грамматика; закоммиченность контракта на HEAD; выбор свежего вердикта ревьюера ПО КОММИТ-ИСТОРИИ ФАЙЛОВ (строки 118–175 — ancestry МЕЖДУ коммитами вердиктов; latest-frozen, OBJECT реализации и product main в выборе НЕ участвуют — измеренный дефект); 187а-блок (177–256: строка СВЕРКА-АРХИТЕКТУРЫ + check-run arch на HEAD; jq-предикат имени `.name == "arch"` — буквальный, строка 245); source-gate 996; ПРОВОДКА (`check_provodka.sh`); ПОТРЕБИТЕЛИ (`check_consumers.sh`, окно frozen..HEAD); клапан v>1 (`РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`); тег `done/<dir>/<NNN>/<v>`.
- Замороженные обязательства на эту дверь (зона implementer включает `scripts/done_contract.sh`): **038/2** (§Инварианты 4: шаги 1–8, именованные причины ДОСЛОВНО, клапан ровно двух состояний), **094/2** (done — потребитель журнала published, сам объект не судит), **168/1** (`project_mechanism_notices` до первого Git-изменения; в дереве ЕЩЁ НЕ реализован — места не занимать), **184/1** (профиль — только через резолвер), **187/2** (ARCH_REVIEW/ARCH_CI: «чужой SHA, отсутствующий, красный, skipped → ARCH_CI»; «парные корректные входы rc 0»), **992/2** (перечень версий — именованный отказ), **996/2** (профильные пути).
- Грамматика класса риска уже вычисляется теми же литералами: `scripts/zamok_predmeta.sh:204–243 klass_riska` (строка класса в тексте → `registry/risk-legacy.tsv` по blob → отказ при неопределённости). Реестр — 5 строк (991/999/095/129 обыччный, 998 рисковый). Норма классов — roles/orchestrator.md §«Порядок судей и класс риска»: «нет поля (старый frozen) — класс из registry/risk-legacy.tsv; нет записи — рисковый».
- OBJECT-строка вердиктов — действующая конвенция: первая строка `accept|FAIL|ESCALATE`, следующая — `OBJECT=<40 hex>`; свежие вердикты (186/187/190/195) несут её все; по всем 409 review-файлам — 160 (старые до конвенции). Строка `СУД: repo=…` — свободная форма, дверью не парсится (замер: «repo=Complior-mob (+dev-harness)», «repo=dev-harness (контракт …) + Complior-mob» — не машиночитаема).
- Живую дверь гоняют батареи: `architecture_process_187` (done-клетки; toy-мир сегодня БЕЗ тега заморозки — дооснащается, см. ПЕРЕСЕЧЕНИЕ architect; базлайн: CELLS=54 FAILURES=0), `rezhim_996` (клетки done-*-preserved — их отказы срабатывают ДО новых проверок; базлайн матрицы: examined=111 mismatches=1 — ранее существующий пропуск mutant skip-committed, не предмета 201), `izveshchenie_168` (done-клетка ждёт нереализованный гейт 168). Семья 038 (`fixtures/done_contract/*`, `fixtures/check_consumers/*`) ездит по TOY-писателю, живую дверь не зовёт.
- Машиночитного профиля продуктов у станции НЕТ: harness.project.json станции — repoId=dev-harness; structured-источника «какой продукт у контракта станции» в дереве нет (продукты названы только env-умолчаниями `scripts/check_architecture_pin.sh:38–39`, `scripts/merge_architecture_pr.sh:69`). Отсюда — строка `ПРОДУКТ:` в контракте (§Предмет 2) и открытый вопрос 2.
- Прецедент CURL-API двери: `done_contract.sh:235–250` (check-runs; `GITHUB_TOKEN`/`GH_TOKEN`, `--max-time 30`) — тот же приём переиспользуется для compare.
- Форма вердикта/миры: `fixtures/workshop_project/architecture_process_187/{probe,workflow_probe}.py` — канон одноразовых миров с toy-профилем, ПРОВОДКА-guard и шимом curl (`ARCH187_CURL_RESPONSE` + bin-dir в PATH).

## Предмет — инварианты

Все правки — только `scripts/done_contract.sh` (зона implementer). Новые проверки — шаг **6б**, ПОСЛЕ ПОТРЕБИТЕЛЕЙ (6а), ДО клапана (7); (г) — внутри существующего 187а-блока. Порядок внутри 6б: (а) → (б) → (в).

0. **НЕ СЛАБИТЬ.** Все существующие отказы (шаг 5 вердикт, 187а ARCH_REVIEW/ARCH_CI, source-gate, ПРОВОДКА, ПОТРЕБИТЕЛИ, клапан v>1, перечень версий 992, env-гигиена, NNN-грамматика, закоммиченность) сохраняют условия, дословные фразы и порядок до шага 6а включительно. Новые отказы — новые имена; ни одна существующая фраза не перекодируется; клапан не расширяется.

1. **(а) Привязка accept к ПОСЛЕДНЕЙ заморозке.**
   - `vmax` = максимум по тегам `refs/tags/frozen/contracts/<NNN>/*` (перечисление — как 992: ошибка перечисления → именованный отказ, версия не угадывается). Тегов нет → rc 1: `done: нет заморозки frozen/contracts/<NNN>/* — привязка accept к последней версии невозможна`.
   - `F` = peeled-коммит тега `frozen/contracts/<NNN>/<vmax>`.
   - OBJECT-грамматика: в свежем accept-вердикте обязана быть строка `OBJECT=<40 маленьких hex>` (anchored `^OBJECT=[0-9a-f]{40}$`, первая от начала файла). Нет или не по грамматике → rc 1: `done: вердикт <отн-путь> без строки OBJECT=<40 hex> — объект реализации не назван`.
   - Свежесть привязки: коммит свежего accept-вердикта (`freshest_cid`, уже вычислен дверью) — равен или потомок `F` (`git merge-base --is-ancestor F freshest_cid`, равенство проходит). Иначе rc 1: `done: accept ревьюера <отн-путь> предшествует последней заморозке <тег> — accept старой версии не открывает done новой`.
   - Достижимость F или OBJECT в текущем main НЕ требуется (решение консультанта по шести «закрытым фактом»: равенство blob — доказательство покрытия текста; дверь не отказывает из-за недостижимости).

2. **(б) Влитость реализации.**
   - Эффективный repoId корня — через существующий резолвер профиля (`profile_resolver.sh --repo`, канал чтения тот же, что у arch187_scope); ошибка резолвера → именованный rc 1 (fail-closed).
   - **Режим продукта** (repoId ≠ `dev-harness`; дверь работает в репо продукта):
     - OBJECT не разрешается коммитом в корне → rc 1: `done: OBJECT <sha> отсутствует в репо продукта — реализация не влита`;
     - OBJECT не равен и не предок HEAD → rc 1: `done: OBJECT <sha> не предок HEAD — реализация не влита в main продукта` (SHA ⊆ main на момент done — дверь работает на влитом main, норма roles/orchestrator.md «merge сам → done»).
   - **Режим станции** (repoId = `dev-harness`):
     - OBJECT разрешается локально → внешняя проверка НЕ выполняется (посадка станции — land-маршрут и ПОТРЕБИТЕЛИ);
     - OBJECT вне репо (внешняя реализация): в контракте на HEAD обязана быть ровно одна строка `ПРОДУКТ: <owner>/<repo>` (owner/repo — алфавит `[A-Za-z0-9_.-]+`, без пробелов, без переиспользования байта-разделителя). Нет строки → rc 1: `done: OBJECT <sha> вне репо контракта, а строки ПРОДУКТ: в контракте нет — влитость в продукт не проверяется`; вне грамматики → rc 1: `done: строка ПРОДУКТ: вне грамматики: <строка>`; более одной с разными значениями → rc 1: `done: строка ПРОДУКТ: неоднозначна: <значения>`;
     - проверка влитости — GitHub compare API приёмом 187а (curl `-sS --max-time 30`, заголовок Accept, Authorization по `GITHUB_TOKEN`/`GH_TOKEN` при наличии): `GET /repos/<owner>/<repo>/compare/main...<OBJECT>`; `jq -r .status` ∈ {`identical`,`behind`} → влито; {`ahead`,`diverged`} → rc 1: `done: OBJECT <sha> не в main продукта <owner>/<repo> — реализация не влита`; ответ недоступен (curl rc≠0, не JSON, поля status нет, 404) → rc 1: `done: влитость в main продукта <owner>/<repo> не проверена: <причина>` — fail-closed, не пропуск.
   - Сравнение OBJECT ревьюера и адверсария — литеральное равенство 40-hex строк (§3).

3. **(в) Адверсарий рисковым.**
   - Класс предмета — по ЗАМОРОЖЕННОМУ тексту последней заморозки (blob тега vmax по пути контракта): все вхождения грамматики zamok (строка класса со значением рисковый либо обычный; терминатор значения — тот же класс символов, что `zamok_predmeta.sh:215`) обязаны соглашаться; расхождение → rc 1: `done: класс риска контракта неоднозначен — судьи не определены`. Строки нет → реестр `<registry>/risk-legacy.tsv` на HEAD (lookup по blob замороженного текста, `awk -F'\t'` литерально, как zamok D30); нет записи → **рисковый** (норма orchestrator: «нет записи — рисковый»).
   - Рисковым требуется свежий (по коммит-истории, тем же алгоритмом, что у review) вердикт адверсария `<verdicts>/adversary/contracts-<NNN>-*.md`: первой строкой accept (грамматика шага 5) и строкой `OBJECT=`, литерально равной OBJECT ревьюера. Отказы: файлов нет → rc 1 `done: предмет рисковый, accept адверсария не найден: <dir>/contracts-<NNN>-*.md`; свежий не accept → rc 1 `done: свежий вердикт адверсария <файл> не accept`; без OBJECT-строки → rc 1 `done: вердикт адверсария <файл> без строки OBJECT=<40 hex> — объект не назван`; другой объект → rc 1 `done: accept адверсария <файл> на объект <X>, ревьюера — на <Y>: требуется тот же объект`.

4. **(г) Имя check-run arch** — внутри 187а-блока; прочие условия неизменны (conclusion success, head_sha == HEAD, status completed; фраза ARCH_CI заморожена 187/2):
   - предикат имени: `.name == "arch"` ИЛИ `.name` начинается с `arch ` (пробел) ИЛИ с `arch (`. `archive`, `architecture…`, `march`, `arche` — НЕ принимаются.

## Красная батарея — `fixtures/workshop_project/done_dver_soderzhatelnaja_201/`

Раннер `red_done_dver_201.sh [--repo <корень> | --model | --stabs]` (канон 187: CELLS/STABS/FAILURES; голый прогон — против живой двери из корня репо). Миры — одноразовые git-репозитории с toy-профилем станции (`repoId=dev-harness`, корневые workflowPaths) / продукта (`repoId=Complior-mob`) / бэкенда (`repoId=Complior-back` + `architecture.lock.json`), по строительным приёмам `architecture_process_187/probe.py`: ПРОВОДКА guard + workflow, `registry/contracts.tsv` `777 → <blob>`, bare-origin. Для (б)/(г) — шим `curl` в PATH: compare/check-runs подаются из JSON-файлов ВНЕ мира (`DONE201_COMPARE`, `DONE201_CHECKRUNS`), мир своего curl не содержит. Оракул — в памяти раннера (правило 8), никогда в мире.

Клетки (28; каждая — одиночная мутация честного мира; зелёная обязана закончиться тегом `done/contracts/777/1`, красная — rc 1 с дословной причиной и БЕЗ тега):

- (а): `a-verdict-posle-zamorozki` rc0; `a-ravenstvo-frozen-verdikt` rc0 (тег заморозки == коммиту вердикта); `a-accept-staroj-versii` rc1 «предшествует последней заморозке» (вердикт закоммичен ДО тега vmax); `a-net-zamorozki` rc1 «нет заморозки»; `a-verdikt-bez-object` rc1 «без строки OBJECT=».
- (б): `b-produkt-vlito` rc0 (repoId=Complior-mob, OBJECT — предок HEAD); `b-produkt-object-mimo-main` rc1 «не предок HEAD» (коммит невлитой боковой ветки); `b-produkt-object-otsutstvuet` rc1 «отсутствует в репо продукта»; `b-vneshnij-produkt-vlit` rc0 (станция, OBJECT вне репо, `ПРОДУКТ:` + compare behind); `b-vneshnij-ne-vlit` rc1 «не в main продукта» (compare ahead); `b-vneshnij-bez-stroki` rc1 «строки ПРОДУКТ: … нет»; `b-vneshnij-stroka-krivaja` rc1 «вне грамматики» (без слэша); `b-vneshnij-api-nedostupen` rc1 «не проверена» (404).
- (в): `v-riskovyi-sopostavimyj-object` rc0; `v-riskovyi-bez-adversarii` rc1 «accept адверсария не найден»; `v-riskovyi-drugoj-object` rc1 «на объект …, ревьюера — на …»; `v-riskovyi-svezhij-fail` rc1 «не accept» (свежий FAIL поверх старого accept); `v-adversarii-bez-object` rc1 «без строки OBJECT=»; `v-obychnyj-bez-adversarii` rc0 (контроль ложных отказов); `v-default-riskovyi-bez-zapisi` rc1 (нет строки и записи — рисковый: боль 111/123); `v-legacy-obychnyj` rc0 (запись risk-legacy по blob → обычный: класс 129); `v-klass-neodnoznachen` rc1 «неоднозначен».
- (г): `g-arch-tochno-imja` rc0; `g-arch-v-skobkah` rc0 («arch (пин внешней архитектуры, model fitness + code-ratchet)» — боль, красна сегодня); `g-arch-s-probelom` rc0 («arch fitness»); `g-archive` rc1 ARCH_CI; `g-architecture` rc1 ARCH_CI; `g-march` rc1 ARCH_CI.

Стабы-двойники (привязка КОДОМ: мутант оракула запускается на клетке своего пункта; «жив» = не пойман):

- стаб `s-a-prinimaet-ljubuju-versiju` (пропуск свежести F⊆CID) @ `a-accept-staroj-versii`;
- стаб `s-a-object-ne-nuzhen` (пропуск OBJECT-грамматики вердикта) @ `a-verdikt-bez-object`;
- стаб `s-b-vlitost-ne-proverjaetsja` (пропуск (б) целиком) @ `b-produkt-object-mimo-main`;
- стаб `s-b-api-vsegda-vlito` (любой ответ compare → влито, включая 404) @ `b-vneshnij-ne-vlit`;
- стаб `s-v-adversarij-ne-trebuetsja` (пропуск (в)) @ `v-riskovyi-bez-adversarii`;
- стаб `s-v-object-adversarija-ignoriruetsja` (любой OBJECT адверсария принимается) @ `v-riskovyi-drugoj-object`;
- стаб `s-g-arch-kak-podstroka` (имя — подстрока «arch» где угодно) @ `g-archive`;
- стаб `s-g-arch-tolko-literalno` (нынешнее поведение двери: только == «arch») @ `g-arch-v-skobkah` — фиксирует сегодняшний дефект (г) как обман.

## Модель угроз

ЗАЩИЩАЕТ:
- accept-вердикт, предшествующий последней заморозке, не открывает done новой версии (классы 141/991/999/109);
- рисковый предмет не получает done без свежего accept адверсария НА ТОМ ЖЕ OBJECT (классы 157/111/123/995);
- в режиме продукта done не ставится на OBJECT вне main продукта (141-в-продукте, 163-финал);
- для внешней (станция→продукт) реализации done требует машиночитное объявление продукта и влитость OBJECT в main продукта через API (999-класс);
- имя check-run «arch (…)» принимается; «archive»/«architecture…»/«march»/«arche» — нет.

НЕ ЗАЩИЩАЕТ:
- 163-класс СЕГОДНЯ: свежий post-freeze accept на ЛОКАЛЬНОМ (станционном) OBJECT при невлитой продуктовой части — дверь не видит продукт без внешнего OBJECT; ловец — содержательная сверка оркестратора (roles/orchestrator.md:38) и открытый вопрос 2;
- семантика вердикта (этап A вместо всего предмета), правдивость строки СВЕРКА-АРХИТЕКТУРЫ — судят ревьюер/предмет 188;
- история PR (дверь проверяет конечное состояние SHA ⊆ main, не «кто мержил»);
- продукты вне GitHub и приватные продукты без токена в среде — честный отказ «не проверена» (fail-closed), не обход;
- достигнемость F/OBJECT в переписанной истории — не проверяется (см. §Предмет 1);
- класс риска ПО ЗАГОЛОВКУ вердикта или СУД-строке — источник только замороженный текст + risk-legacy.

## Замеры (числа из вывода, 2026-11-17)

- Raw-замер: 22 предмета; rc0 при неготовности — 5 (141/157/163/991/999); «фактически закрыты» — 6.
- Предикат (а) на живой станции (`merge-base --is-ancestor F <коммит-вердикта>`): НЕТ — 141/991/999/109/117/139 (accept старой версии); ДА — 129/157/163/186/190.
- Предикат (в) на живой станции (класс → same-OBJECT adverse-accept): 157 — рисковый, adverse-accept НЕТ (последний FAIL 9e8388b31) → красный; 186 — рисковый, Adv186Narrow accept 4448dd15 == ревьюер 4448dd15 → зелёный; 111/123 — нет строки класса и записи → рисковый, contracts-<NNN>-adversary accept нет → красный; 995 — рисковый, adverse FAIL → красный; 117/129/132/139/141/163/991/999 — обычный → проверки нет.
- (г): живой зелёный check-run бэкенда на main 250a45f4 — имя «arch (пин внешней архитектуры, model fitness + code-ratchet)» (ARCHCOL §5); дверь требует буквальное «arch» (`done_contract.sh:245`).
- Базлайны соседних батарей (до предмета): 187 `--repo .` — CELLS=54 FAILURES=0 rc0; 996 `--matrix` — examined=111 mismatches=1 (mutant skip-committed / done-committed-preserved, существует ДО предмета 201).
- Голый прогон батареи 201 против текущего дерева — в сдаточном листе (SDACHA.md), ожидание: rc1, красны клетки всех четырёх пунктов.

## Приёмка (команды и rc)

- Дано: текущее дерево (дверь ещё не несёт шаг 6б и предикат (г)); когда `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh`; тогда rc 1, FAILURES = 17 (число — из вывода раннера, копия в SDACHA.md), красны клетки всех четырёх пунктов, тегов done/contracts/777/* в мирах нет. Когда та же команда с `--model`; тогда rc 0 (CELLS=28 FAILURES=0). Когда с `--stabs`; тогда rc 0 (STABS=8, каждый caught).
- Дано: реализация implementer в дереве; когда `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .`; тогда rc 0 (FAILURES=0), зелёные клетки заканчиваются тегом done/contracts/777/1.
- Дано: дооснащенные миры 187 (ПЕРЕСЕЧЕНИЕ architect); когда `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`, затем с `--model`, затем с `--stabs`; тогда каждый rc 0 (CELLS=54). Когда `PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/rezhim_996/probe.py --matrix`; тогда не хуже базлайна: examined=111, mismatches ≤ 1 (единственный ранее существующий skip-committed).
- Дано: исправленный черновик, окружение без ambient GIT_AUTHOR_*/GIT_COMMITTER_*; когда `bash scripts/pre_critic.sh --repo . contracts/201-done-dver-soderzhatelnaja-sverka.md`, затем `bash scripts/check_spec_ready.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md`, затем `bash scripts/check_precision_gate.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md`, затем `bash scripts/check_threat_model.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md`, затем `bash scripts/check_ceilings.sh .`; тогда каждый rc 0. До freeze после подключения CI orchestrator: `bash scripts/gen_ci_steps.sh --write` затем `--check` rc 0 и `bash scripts/check_provodka.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md` rc 0 (шаг и замер — зона orchestrator, контракт своих строк в реестр не пишет).

## Зоны и пересечения

ЗОНА architect: contracts/201-done-dver-soderzhatelnaja-sverka.md fixtures/workshop_project/done_dver_soderzhatelnaja_201/ fixtures/workshop_project/architecture_process_187/probe.py fixtures/workshop_project/architecture_process_187/workflow_probe.py
ЗОНА implementer: scripts/done_contract.sh
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 159 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 166 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 167 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 169 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 170 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 172 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 173 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 174 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 175 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 182 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 185 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 186 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 189 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 190 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 191 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 192 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 195 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 196 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 197 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 199 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только сгенерированный шаг 201; чужие шаги сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 159 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 166 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 167 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 169 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 170 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 172 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 173 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 174 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 175 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 182 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 185 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 186 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 189 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 190 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 191 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 192 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 195 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 196 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 197 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 199 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка шага 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 159 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 166 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 167 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 169 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 170 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 172 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 173 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 174 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 175 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 182 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 185 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 186 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 189 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 190 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 191 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 192 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 195 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 196 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 197 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 199 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только строка замера 201; чужие строки сохранены.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 038 замороженные обязательства v2 сохраняются: шаги 1–8, дословные причины и клапан ровно двух состояний не тронуты; новые отказы — шаг 6б после ПОТРЕБИТЕЛЕЙ, до клапана.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 094 замороженные обязательства v2 сохраняются: done остаётся потребителем журнала published, объект не судит.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 168 замороженные обязательства v1 сохраняются: место вызова project_mechanism_notices до первого Git-изменения не занимается (гейт ещё не реализован в дереве).
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 184 замороженные обязательства v1 сохраняются: чтение профиля — только через существующий резолвер.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 187 замороженные обязательства v2 сохраняются: условия ARCH_REVIEW/ARCH_CI неизменны, меняется только предикат ИМЕНИ check-run (г).
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 992 замороженные обязательства v2 сохраняются: перечень версий — именованный отказ, версия не угадывается.
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 996 замороженные обязательства v2 сохраняются: новые чтения путей — только через project_paths_resolve.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/architecture_process_187/probe.py — 187 замороженные обязательства сохраняются: только строка класса риска в toy-контракте; клетки, вариации и STABS не меняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/architecture_process_187/workflow_probe.py — 187 замороженные обязательства сохраняются: только дооснащение миров done-клеток (тег заморозки на коммите сценария, OBJECT-строка вердикта вторым рядом); клетки, вариации и STABS не меняются.

## ПРОВОДКА

ПРОВОДКА:
- guard=fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh
- guard=scripts/done_contract.sh
ПРОВОДКА-ЭНФОРСМЕНТ: предмет 201 — чистый энфорсмент содержательной сверки done-двери (механика двери, замкнутые алфавиты, литеральные сравнения); поведенческой нормы для ролей не вводит — судей зовёт оркестратор по действующей норме roles/orchestrator.md §«Порядок судей и класс риска».

## Сдача и предпосылки

СДАЧА: fixtures/workshop_project/done_dver_soderzhatelnaja_201/SDACHA.md

ПРЕДПОСЫЛКИ:
- setting нет secrets/variables/environments репозитория: compare-API в клетках — шим curl; живой прогон двери — те же GITHUB_TOKEN/GH_TOKEN, что у 187а
- setting CI: шаг и замер батареи подключает orchestrator (gen_ci_steps.sh --write/--check, норма 038-CI); CI-раннер предоставляет bash, git, python3; ручных прав workflow нет

## Открытые вопросы владельцу

1. **117/139** (предложенные консультантом done/2 «со строкой РАЗРЕШИЛ»): их свежие in-main accept-вердикты ПРЕДШЕСТВУЮТ последней заморозке — repaired-дверь по п.10(а) их откажет, и клапан v>1 этого не отпирает (клапан — ровно два состояния, 038/2). Маршрут: свежий accept-вердикт после заморозки (судья) — либо слово владельца об исключении/расширении клапана (тогда v+1 предмета 038).
2. **163-класс**: «влито в продукт» для station→продукт предметов с ЛОКАЛЬНЫМ OBJECT — нужен выбор: (i) норма «OBJECT вердикта внешнего предмета обязан быть SHA продукта» (ловит 163 сразу, требует строки `ПРОДУКТ:` в тех контрактах v+1) — рекомендую; (ii) остаётся оркестраторской содержательной сверкой (как сегодня).
3. Продукты вне GitHub и отсутствие токена у двери — сейчас честный отказ «не проверена»; нужен ли локальный git-fallback — на слове владельца.

## Незаполненные требования:
нет
