# СДАЧА 223 — `.review/**` в служебном хвосте ARCH_CI

Предмет: полный done CLI обходит только непустые дельты корневых `.harness/**` + `.review/**`, сохраняет продуктовую границу, check-run arch и done-тег на HEAD. Тип доказательства — поведение настоящей двери и Git, не статическая подстановка строки. Production/CI/реестры/прежние семьи не меняются. Шов, обещание и frozen-обязательства — §Предмет контракта; correction не добавляет нового отказа.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-223-v1.md

База исправления: 862ed947bd9a760d33e84b074b51bd42f405c4fd (авторская пачка 7ad42a6cf380cac99e8ebc1074ffd39e7acdf5f1 плюс закоммиченный FAIL Crit223, вызов 1). Прочитаны полный вердикт, исходное задание и дельта-пакет task-architect223b.md. Ровно один блок К-08: потеря условия непустоты дельты. Снятие обещания и граница неприемлемы: это сохранённое поведение frozen 187/3. Git plumbing задаёт канон миров, но само по себе не доказывает эффект CLI; поэтому способ закрытия — клетка на существующем шве, не новый guard/парсер.

## Двери

Команды исполняются последовательно; TMPDIR находится внутри своей копии. VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck; SDACHA_TIMEOUT_SEK=1200; SDACHA_BUDZHET_SEK=2400. Поля — ожидаемый и измеренный rc; сырые результаты — §Замер исправления.

- Model · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --catalog · 0 · 0
- Repo-after-implementation · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --repo . · 0 · 0
- Context · fixtures/workshop_project/arch_ci_review_223/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/223-arch-ci-review.md · 0 · 0
- Spec · bash scripts/check_spec_ready.sh . contracts/223-arch-ci-review.md · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/223-arch-ci-review.md · 0 · 0
- Threat · bash scripts/check_threat_model.sh . contracts/223-arch-ci-review.md · 0 · 0

## Дельта

- К-08 · клетка · fixtures/workshop_project/arch_ci_review_223/empty223.py · 0 · 0
- К-01 · канон/инструмент · bash fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh --catalog · 0 · 0

## Блок → клетка → стаб

К-08 → empty-first-parent-success → s09-critic-empty-predicate: дословная мутация критика `[ "$_a187_npaths" -eq 0 ] || [ "$_a187_only" -ne 1 ]` → `[ "$_a187_only" -ne 1 ]`. У двухродительского merge дерево первого родителя; success только на p1. Честная дверь запрашивает HEAD, отказывает ARCH_CI rc 1 без тега; мутант запрашивает p1, допускает rc 0 и ставит тег. empty223.py воспроизводит сценарий вердикта, сравнивает байты мутации с сгенерированным s09 и предъявляет честный/ложный носители тому же публичному CLI.

К-08 → empty-first-head-success → тот же s09 (соседняя мутация s10-empty-is-service): положительный контроль с success на HEAD. Проверка SHA не позволяет спрятать дефект за совпавшим rc 0. s10 считает пустую дельту служебной через начальный счётчик 1 вместо 0; обе клетки различают эту ошибку. e03-empty-guard-equivalent меняет порядок дизъюнктов и использует `<1` вместо `==0`: обе пустые клетки и непустые review/harness/product/both-controls зелены.

К-08 → empty-first-parent-success, empty-second-review, empty-second-harness → s11-empty-by-second-diff: сравнение с p2 вместо p1. Для двух последних дерево merge равно p2, но отлично от p1, дельта p1 непуста и служебна: честный запрос идёт к продуктовому p1. Парный empty-second-product остаётся продуктовым отказом. Непустые both-services/harness-merge из прежней батареи сохранены.

К-08 → octopus-empty, octopus-service, octopus-mixed → s12-octopus-third-ignored: `np > 2` заменён на `np > 3`. Во всех трёх мирах ровно три настоящих родителя; success имеется и на HEAD, и на p1, но честная дверь отказывает до API. e04-octopus-guard-equivalent (`np >= 3`) остаётся зелёным на всех трёх и двухродительском harness-контроле.

## Новые предикаты и честные эквиваленты

Предикаты конструктора подтверждают настоящие родительские SHA, пустоту/непустоту дельты p1 и отдельную пустоту p2 через Git. Это предпосылки конформности, ошибка даёт NOT_IMPLEMENTED rc 2, не поимку стаба. Ожидания остаются литералами до субъекта. Проверка octopus требует rc 1, отсутствие API/тега, точную именованную причину с обоими SHA, пустой stdout и неизменный HEAD; s12 красит её каждым из трёх миров, e04 на тех же мирах зелён. Для непустоты и выбора родителя используются прежние предикаты RC/QUERY_SHA/SHA_DIAGNOSIS/TAG, не второй оракул; s09/s10/s11 и e03 дают парные красные/зелёные предъявления. Новых существенных обещаний или дверей сверх К-08 нет.

## Счёт и наблюдение

Единственный реестр адресных связей — MUTATIONS/EQUIVALENTS в build.py; source.json и stabs.tsv генерируются из него, хеши/TSV проверяются до субъекта. Счёт исправления: KLETKI 47 STABY 12 EKVIVALENTY 4 SVJAZI 43; NOSITELI 17. Прежние 39 клеток и 23 связи сохранены, добавлены 8 клеток и 20 связей. Красных связей 24, зелёных 19; независимая мера — строки red/green сгенерированного TSV и --catalog/фактический --stabs. Только добавления в probe.py относительно OBJECT_БАЗЫ; прежние носители неизменны.

Истина — литералы CASES и снятые до вызова SHA/байты. Конструктор world201.build используется без его оракула. Новые пустые/октопус-миры созданы настоящим git commit-tree, tree == p1 или tree == p2 проверены до CLI; остальные миры — настоящие commit/merge --no-ff. API-шлюз адресован по SHA, Git не подменяется. Полные rc/раздельные трубы, единственный ожидаемый SHA-запрос (либо отсутствие API у octopus), оба SHA в своей строке ARCH_CI, annotated done-тег на HEAD, отсутствие тега при отказе и неизменный HEAD проверяются независимо.

## Замер исправления

Дословный мутант критика до расширения батареи: `B --repo <origin-клон с мутантом>` → rc 0, `KLETKI 39 KRASNYH 0`. После расширения тот же неизменённый носитель → rc 1, `KLETKI 47 KRASNYH 2`:

```text
REPO empty-first-parent-success RED RC,QUERY_SHA,SHA_DIAGNOSIS,TAG_ON_REFUSAL rc=0
REPO empty-first-head-success RED QUERY_SHA,SHA_DIAGNOSIS rc=0
```

Точное удаление предиката выполнено в scratch-клоне; production своей копии не менялась. Исходная команда Python из вердикта прочитана; её a/b воспроизведены побайтно в build.py и empty223.py (индивидуальные правки выполняются edit, не Python -c).

Чистый SSH-origin-клон `tmp/origin-223b` закреплён на 862ed947bd9a760d33e84b074b51bd42f405c4fd; теги получены с origin. Production восстановлена из неизменной своей копии после отдельного предъявления мутанта. В клон перенесены только контракт и семейство 223; все команды ниже выполнены по одной. TMPDIR=`<клон>/tmp/scratch-arch223b`.

| Команда | Сырой rc | Наблюдение | Секунды |
|---|---:|---|---:|
| 224 --repo . до переноса исправления | 0 | KLETKI 100 KRASNYH 0 | 117.37 |
| B --model | 0 | KLETKI 47 KRASNYH 0 | 44.36 |
| B --stabs | 0 | CONTROL 47/0; ZHIVYH 0 SVJAZI 43 | 89.81 |
| B --sintaksis | 0 | SINTAKSIS 17 SHELLCHECK 2 | 1.17 |
| B --catalog | 0 | KLETKI 47 STABY 12 EKVIVALENTY 4 SVJAZI 43 | 0.05 |
| B --repo . | 1 | KLETKI 47 KRASNYH 23, предметный red до реализации | 30.26 |
| python3 -B fixtures/workshop_project/arch_ci_review_223/empty223.py | 0 | honest-empty RED 0; mutant-empty RED 1 | 2.00 |
| python3 -B fixtures/workshop_project/arch_ci_review_223/context.py | 0 | ДЕКЛАРАЦИИ 75 | 0.85 |
| bash scripts/pre_critic.sh contracts/223-arch-ci-review.md | 0 | КРИТИК: дверь зелёная | 219.11 |
| bash scripts/check_sdacha.sh . contracts/223-arch-ci-review.md --run | 0 | двери=10 карта=17/17 дельта=1 | 235.04 |
| bash scripts/check_precision_gate.sh . contracts/223-arch-ci-review.md | 0 | OK | 23.72 |
| 224 --repo . после исправления | 0 | KLETKI 100 KRASNYH 0 | 152.24 |
| 187 --repo . | 0 | CELLS=111 STABS=0 FAILURES=0; pin-boundary 9/9 | 150.01 |
| 201 --repo . | 0 | CELLS=62 STABS=0 FAILURES=0 | 75.92 |

Имена 224/187/201 раскрыты полными командами в приёмке контракта; budgets для формы — 1200/2400, как в задании. Сырые stdout/stderr и rc сохранены в `tmp/evidence-223b/` своей копии (не часть поставки). Независимая мера `cut -f3 fixtures/workshop_project/arch_ci_review_223/stabs.tsv | sort | uniq -c` дала `19 green`, `24 red`. `git diff --numstat 862ed947bd9a760d33e84b074b51bd42f405c4fd -- fixtures/workshop_project/arch_ci_review_223/probe.py` дал `59 0`: только добавления. Прежние клетки/связи не ослаблены.

## Красное production до реализации

Прежние красные review-merge/review-nested/both-services/backend177-chain/review-linear, review-space/unicode/dotdot-name/newline/delete/rename/mode/symlink/type-change, review-missing-run/failed-run/skipped-run/other-sha/incomplete-run/wrong-name/name-space/name-parenthesis остаются предметным красным. Новая empty-second-review имеет ту же ещё не реализованную review-классификацию. API-негативы красны SHA-запросом даже при верном rc 1; одного rc недостаточно. Остальные новые пустые/harness/product/octopus-клетки уже зелены на production и сохраняют 187. Полный rc 0 ожидается только после implementer; старый reference не переносится поверх production.

## Карта классов

- К-01 · чисто · вход: десять дверей формы, отдельная исполняемая дельта; pre_critic/check_sdacha/precision — итоговые scoped-прогоны · - · -
- К-02 · чисто · вход: исходное задание, дельта-пакет, полный FAIL Crit223, слово «ARCH_CI v2 да» и письмо back-1190; sourceCanon не объявлен · - · -
- К-03 · чисто · вход: context.py читает высшие frozen-блобы, 187/3 и 201/1 сохранены; scoped 224/187/201 включены · - · -
- К-04 · чисто · вход: зона — контракт 223 и arch_ci_review_223/, production/CI/прежние семьи неизменны · - · -
- К-05 · чисто · вход: приёмка — B-режимы, empty223.py и scoped-команды с rc; новый смысл не добавлен · - · -
- К-06 · чисто · вход: исключение/синтаксис/таймаут/сторонний отказ дают NOT_IMPLEMENTED rc 2, не поимку · - · -
- К-07 · чисто · вход: --model и полный CONTROL перед --stabs; empty223.py предъявляет честный контроль до мутанта · - · -
- К-08 · чисто · вход: адресные s09/s10/s11/s12 на настоящих пустых/p2/octopus-мирах плюс e03/e04; точный мутант до 39/0, после 47/2 · - · -
- К-09 · чисто · вход: прежние 39 клеток сохранены; добавлены 8 по К-08; root/depth/gitlink защищает неизменная 187 · - · -
- К-10 · чисто · вход: rc, трубы, SHA-запрос/отсутствие API у octopus, оба SHA, annotated-тег и HEAD; empty HEAD-success ловит ложный выбор даже при совпавшем rc · - · -
- К-11 · чисто · вход: литералы CASES, HEAD/selected/carrier сняты в память до субъекта; файл ожиданий внутри мира не перечитывается · - · -
- К-12 · чисто · вход: настоящий Git plumbing, jq двери, bash -n и стандартный shellcheck, manifest/TSV из единого build.py · - · -
- К-13 · н/п · секретные входы и сеть не вводятся; токены батарее не нужны · - · -
- К-14 · чисто · вход: e01/e02 сохранены; e03/e04 на тех же пустых/непустых/octopus-входах, парные продуктовые отказы и служебные допуски · - · -
- К-15 · чисто · вход: build/catalog/TSV и фактический --stabs проверяют 47/12/4/43, носителей 17; нулевая выборка запрещена · - · -
- К-16 · чисто · вход: класс рисковый — авторизация приёмки; содержимое служебных каталогов и single-uid компрометация вне защиты, ловцы названы в контракте · - · -
- К-17 · н/п · станционный механизм, модель продукта и новые writers/isolationKeys не объявляются · - · -

## Наблюдение процесса

Кандидат для main-журнала, без А-номера и без записи общего журнала в wip: прежние 39 миров и три scoped-регресса не различали удаление уже существующего условия непустоты. Цена — один исправительный круг. Класс — конструкция: список путей без элемента не эквивалентен списку служебных путей. Закрыто прямым commit-tree-миром и парным HEAD-success с проверкой SHA, а не усилением прозы или новым guard. Предыдущее наблюдение о каноническом `.review/a/../../x` сохраняется в normalized-escape; новых процессных обязательств не вводится.

## Проводка

Полный check_provodka до CI-подключения остаётся rc 1: guard семьи не подключён. Это прежний явно распределённый этап orchestrator до done, не блок исправления К-08 и не разрешение обходить done. Grammar проверяется отдельно; чужой CI вне зоны architect.

## Исправление Adv223 К-01 — собственная заморозка

База: 704a67d726dc10eb9e4eaa1c980a6199adba2d47. Полный FAIL Adv223 вызов 1 прочитан из origin/archive/223/adversary-v1-fail-3deff003a:verdicts/adversary/contracts-223-impl-v1.md. Только второй блок К-01 входит в эту пачку; К-04 (CI) принадлежит orchestrator. Контракт заморожен и не меняется.

К-01 → канон/инструмент: context.py исключает SUBJECT из выбора высших frozen-блобов ДО census зон. Другие номера, выбор высшей версии и прежние 75 деклараций не меняются. Имена собственных путей и подписи получают тот же SUBJECT, не новые литералы. Repo-дверь листа приведена к уже выполненному этапу «После реализации» frozen-контракта; историческое красное до реализации выше остаётся историей, не текущим ожидаемым rc.

Клетка context_freeze.py включена в --catalog, поскольку --repo/--model испытывают done CLI, а не census. До вызова субъекта она снимает 75 точных строк из frozen/contracts/223/1 и высшие чужие frozen-блобы в память; строит настоящий Git-репозиторий с этими текстами. На состояниях без своего тега, с 223/1 и дополнительно с 223/999 CLI обязан дать rc 0, те же 75 строк и ни одного собственного ИСТОЧНИК. Файлы мира после CLI не являются оракулом.

Адресные стабы по коду context_freeze.py: self-included удаляет пропуск SUBJECT; only-first-self-excluded исключает лишь версию 1, оставляя собственную 999. Оба предъявлены миру со своими тегами и требуют предметный rc 1 CONTRACT_OVERLAPS_INCOMPLETE с собственной декларацией. Честная эквивалентная запись SUBJECT == n остаётся зелёной с теми же 75 строками. Счёт дополнительной клетки: 3 состояния, 2 стаба, 1 эквивалент; прежние 47/12/4/43 остаются неизменны. Изменение probe.py — только добавление вызова в --catalog.

Рефлексия для main-журнала без А-номера: предусловие «до freeze» было неявно встроено в census чужих контрактов. Цена — красная обязательная сдача уже после реализации; закрыто исключением своего номера и настоящим переходом состояния без тега → frozen → высшая frozen-версия, не самопересечением в frozen-тексте. Общий журнал в wip не меняется.

## Замер Architect223c

Чистый SSH-origin-клон `tmp/origin-223c` закреплён на OBJECT_БАЗЫ; frozen/contracts/223/1 и 228/1 присутствуют. Перенесена только семья 223. Команды выполнены последовательно с заданными shellcheck/TMPDIR/1200/2400. Сырые трубы и rc: `tmp/evidence-223c/` своей копии, не часть поставки.

| Команда | Сырой rc | Наблюдение |
|---|---:|---|
| context.py до правки | 1 | CONTRACT_OVERLAPS_INCOMPLETE, собственная декларация |
| context_freeze.py до правки | 1 | before-freeze зелён; own-frozen красен |
| context.py после правки | 0 | ДЕКЛАРАЦИИ 75 |
| B --model | 0 | KLETKI 47 KRASNYH 0 |
| B --stabs | 0 | ZHIVYH 0 SVJAZI 43 |
| B --sintaksis | 0 | SINTAKSIS 17 SHELLCHECK 2 |
| B --catalog | 0 | прежние 47/12/4/43; CONTEXT 3/2/1, ZHIVYH 0 |
| B --repo . | 0 | KLETKI 47 KRASNYH 0 |
| check_precision_gate.sh | 0 | OK |
| check_sdacha.sh --run | 0 | двери=10 карта=17/17 дельта=2, строка 18 зелена |
| pre_critic.sh | 0 | КРИТИК: дверь зелёная |
| 224 --repo . | 0 | KLETKI 100 KRASNYH 0 |
| 187 --repo . | 0 | CELLS=111 STABS=0 FAILURES=0 |
| 201 --repo . | 0 | CELLS=62 STABS=0 FAILURES=0 |

К-01 → канон/инструмент → context.py / B --catalog / check_sdacha --run / pre_critic → rc 0. В новом catalog три состояния честного CLI дали rc 0 и тот же точный набор из 75 строк; self-included и only-first-self-excluded дали rc 1 с собственной декларацией; literal-equality-equivalent дал rc 0. Прежние клетки/стабы и frozen-контракт не менялись.

## Отдельно orchestrator — сравнение 22x

В чистом main-клоне на bcd1de3876bbf13fd6612fd1d3b1df1516a2b94c с полными origin-тегами найдены context.py семейств 223/224/226/227/228. 224 тоже включает собственный номер в census (специальное условие done_contract.sh), но только выводит объявления и не сверяет их с контрактом; его context.py дал rc 0. 227 исключает совпадающие роли и не требует самопересечения, context.py rc 0. 226 явно пропускает номер 226; 228 использует zones_load и исключает совпадающие роли вне REQUIRED (228 туда не входит). Для 226/228 здесь только сверка кода, не отдельный check_sdacha. Идентичный отказ после собственной заморозки для них не установлен.

Требуемые однократные `check_sdacha --run` на main: 224 rc 1 до запуска команд — строка 15 листа, ряд `nine-ten-late-fail` вне машинной секции; 227 rc 1 — строка 18, replay_critic.py фактически rc 2 вместо 0. Это красные листы, но не отказ census после собственного frozen. Чужие семьи не правились и повторным прогоном не подгонялись.
