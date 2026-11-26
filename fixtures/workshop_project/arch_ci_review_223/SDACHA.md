# СДАЧА 223 — `.review/**` в служебном хвосте ARCH_CI

Предмет: полный done CLI обходит только непустые дельты корневых `.harness/**` + `.review/**`, сохраняет продуктовую границу, check-run arch и done-тег на HEAD. Тип доказательства — поведение настоящей двери и Git; не статическая подстановка строки. Источник — task-architect223.md и прочитанное письмо back-1190 о done 177/6 на 09f8ba635cd34af657b0376ba8388abbde0ba4dc. Реальный done бэкенда не запускался; backend177-chain воспроизводит топологию и состав путей, не чужие SHA/сеть.

База fetch/switch: f82ff8c9d0d4ba45a53b7aa2e712c552141715f9. Production/CI/реестры/прежние семейства не меняются; зона — контракт 223 и новая семья. Конструктор world201.build переиспользуется без его оракула. Модель — полная дверь базы с одной функцией служебных путей и заменой прежнего case её вызовом; унаследованные SC2034/SC2295/SC1010 отмечены только в reference. Production переносится точечной правкой текущей двери исполнителем после заморозки.

## Счёт и наблюдение

`--catalog`: KLETKI 39 STABY 8 EKVIVALENTY 2 SVJAZI 23. Build: NOSITELI 11; это модель, восемь дефектных и два честных эквивалентных носителя. Независимое наблюдение — фактический --model 39/0, --stabs ZHIVYH 0 при 23 отдельных предъявлениях. Красных адресных связей 14, зелёных 9 (число строк с red/green в сгенерированном stabs.tsv). Единственный редактируемый реестр — MUTATIONS/EQUIVALENTS build.py; source.json и TSV — его производные, хеши и TSV проверяются до субъекта.

Оракул — литералы CASES и снятые ДО вызова значения HEAD/продуктового коммита/ожидаемого SHA*, не повтор классификатора. Каждый мир строится настоящими git commit/merge --no-ff; у backend177-chain четыре служебных merge поверх продукта. API-шлюз отвечает по SHA в URL и журналирует каждый запрос; ожидается ровно один запрос к выбранному SHA*. Никакого git-двойника, извлечения селектора из продукта или вызова модели вместо CLI нет. Проверяются раздельные rc/stdout/stderr, предметная строка с обоими полными SHA, peeled-цель настоящего annotated тега и неизменность HEAD.

Пути rename/delete/mode/symlink/type-change имеют служебные допуски и продуктовые отказы. Есть пробел/Unicode/LF/буквальное `a..b`, каталоговая/корневая/регистровая граница, смесь и негативные состояния API. `.review/a/../../x` вводится через файловую систему: перед субъектом git diff обязан показать `x`; невозможный для Git raw-путь не выдается за конформный вход. Остальные root/depth/octopus/gitlink остаются за неизменной полной семьёй 187.

## Двери

Все команды выполнены последовательно в isolated-копии. TMPDIR=`$PWD/tmp/scratch-arch223`; VALIDATE_STD_SHELLCHECK=`/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`. В строках — ожидаемый и измеренный rc, не статус PASS.

- Model · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --catalog · 0 · 0
- Repo-red-now · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --repo . · 1 · 1
- Context · fixtures/workshop_project/arch_ci_review_223/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/223-arch-ci-review.md · 0 · 0
- Spec · bash scripts/check_spec_ready.sh . contracts/223-arch-ci-review.md · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/223-arch-ci-review.md · 0 · 0
- Threat · bash scripts/check_threat_model.sh . contracts/223-arch-ci-review.md · 0 · 0

Полная проводка до подключения CI — заявленно не подключена, как в 205/224; grammar проверена. Это не разрешение обходить done. Подключение своего шага/замера — зона orchestrator до done.

## Красное предъявление production

Сырой итог `B --repo .`: KLETKI 39 KRASNYH 22, rc 1. Красные по именам:

```text
review-merge
review-nested
both-services
backend177-chain
review-linear
review-space
review-unicode
review-dotdot-name
review-newline
review-delete
review-rename
review-mode
review-symlink
review-type-change
review-missing-run
review-failed-run
review-skipped-run
review-other-sha
review-incomplete-run
review-wrong-name
review-name-space
review-name-parenthesis
```

У последних негативных API-входов (missing/failed/skipped/other/incomplete/wrong-name) rc 1 верен, но запрос идёт к служебному merge, а не к продуктовому предку: красны QUERY_SHA/SHA_DIAGNOSIS. Нельзя засчитать их зелёными только по rc. Положительные review-входы красны RC/QUERY_SHA/SHA_DIAGNOSIS/TAG_TARGET. Продуктовые отказы, `.harness/` и продуктовый HEAD с собственным success уже зелены.

Сырой итог модели: KLETKI 39 KRASNYH 0, rc 0. Стабы: ZHIVYH 0 SVJAZI 23, rc 0; каждая связь отдельно, перед ними полный честный контроль 39/0. SINTAKSIS 11 SHELLCHECK 2, rc 0. Каталог 39/8/2/23, rc 0. Context: ДЕКЛАРАЦИИ 75, rc 0; в том числе высшие frozen 224/1 и 226/1, уже существующие в дереве. 205 не владеет done_contract.sh, его зона — check_provodka.sh. Подготавливаемого 231 в этой базе/ref нет; совместимость объявлена текстом, не вымышленным frozen-тегом.

## Scoped-регрессы

До новой семьи: 224 --repo . → KLETKI 100 KRASNYH 0, rc 0 (163.45 s).
После новой семьи: 187 --repo . → CELLS=111 STABS=0 FAILURES=0, rc 0 (178.75 s); pin-boundary самоконтроль 9/9.
После новой семьи: 201 --repo . → CELLS=62 STABS=0 FAILURES=0, rc 0 (96.41 s).

Production не меняется, результаты этих команд — baseline для исполнителя. Полный повтор 224 после завершения семьи докладывается вместе с SHA сдачи. Новые API-негативы не заменяют прежние 201 JSON/NUL/transport-сценарии.

## Карта классов

- К-01 · чисто · вход: десять дверей листа; grammar, threat и precision измерены rc 0; форма pre_critic/check_sdacha — отдельные итоговые прогоны · - · -
- К-02 · чисто · вход: task-architect223.md целиком, слово «ARCH_CI v2 да», письмо back-1190; sourceCanon не объявлен · - · -
- К-03 · чисто · вход: context.py читает высшие frozen-blobs; 75 объявлений, 187/201 регрессы rc 0, 224 baseline rc 0 · - · -
- К-04 · чисто · вход: только contracts/223-arch-ci-review.md и arch_ci_review_223/; build.py — источник носителей/manifest/TSV, CI — не зона architect · - · -
- К-05 · чисто · вход: приёмка переведена в B-режимы и scoped-команды с rc; нет срока/порога без меры · - · -
- К-06 · чисто · вход: suite требует rc 0/1 и ARCH_CI на отказе, сторонний отказ/синтаксис/таймаут дают NOT_IMPLEMENTED rc 2 · - · -
- К-07 · чисто · вход: --model 39/0 запускает полный done CLI с настоящими Git-объектами и тем же инсталлятором scripts, что --repo · - · -
- К-08 · чисто · вход: --stabs 8 дефектных носителей, 14 красных связей; отдельно 9 зелёных связей эквивалентов, ZHIVYH 0 · - · -
- К-09 · чисто · вход: CASES — граница каталога/корня/регистра, смешение, цепочка, операции Git, отрицательные состояния arch; прежние глубина/root/octopus — семья 187 · - · -
- К-10 · чисто · вход: rc/раздельные трубы, полный SHA в своей ARCH_CI-строке, запрос по SHA и peeled-цель annotated-тега; негативы API до реализации красны даже при верном rc · - · -
- К-11 · чисто · вход: литералы CASES/HEAD/selected/carrier сняты в память до субъекта; ожидаемый результат не лежит внутри мира · - · -
- К-12 · чисто · вход: Git plumbing, jq внутри настоящей двери, bash -n/стандартный shellcheck; source/TSV из одного генератора, побайтная сверка · - · -
- К-13 · н/п · новые секретные входы/сеть не вводятся, токены в батарее не нужны · - · -
- К-14 · чисто · вход: e01 переставляет альтернативы case, e02 — эквивалентный if; служебные допуски парны продуктовым отказам для нестандартных дельт · - · -
- К-15 · чисто · вход: build/catalog и фактические прогоны 39/8/2/23, 11 носителей; 75 пересечений из context.py · - · -
- К-16 · чисто · вход: рисковый класс авторизации приёмки; содержимое служебных каталогов и single-uid компрометация явно вне защиты, ловцы названы · - · -
- К-17 · н/п · станционный механизм без модели продукта/новых writers/isolationKeys, операция архитектуры не объявляется · - · -

## Наблюдение процесса

Кандидат для main-журнала, без самовольного А-номера: путь `.review/a/../../x` нельзя предъявлять как raw Git-путь — это не состояние, которое создаёт обычный Git; файловая запись канонизируется в продуктовый `x`. Цена — отдельный контроль plumbing до субъекта вместо ложной «фикстуры» строкового selector. Класс — конструкция конформного входа; закрыто normalized-escape в настоящем Git-мире. Общий NABLIUDENIA_ARCHITECT.md в wip не меняется; публикация наблюдения принадлежит main.

## Итоговые двери формы

`SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/223-arch-ci-review.md --run` → rc 0, `СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=0)` (180.07 s).

`bash scripts/pre_critic.sh contracts/223-arch-ci-review.md` при тех же TMPDIR/shellcheck/бюджетах → rc 0, `КРИТИК: дверь зелёная` (202.30 s). Прежние два отказа формы листа (буллеты вне машинной секции и python3 как первый токен команды) исправлены формой листа, не ослаблением гейта.

После завершения семьи 224 --repo . повторён: rc 0, KLETKI 100 KRASNYH 0 (193.92 s); результат до/после одинаков. Production ни одной строкой не изменён.

Сухой done-гейт `bash scripts/check_provodka.sh "$PWD" contracts/223-arch-ci-review.md` → rc 1: `проводка: guard не подключён: fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh не вызывается в .githooks/ или .github/workflows/`. Это единственная недостающая проводка, уже выделенная контрактом в зону orchestrator; architect не меняет CI вне выданной зоны. Полный rc 0 обязателен перед done, не заявляется этой сдачей.
