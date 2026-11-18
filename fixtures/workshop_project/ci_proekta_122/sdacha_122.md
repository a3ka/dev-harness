# СДАЧА 122 v6 — конечный ремонт по Arb122V1

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-122-v6.md

Предыдущий FAIL: Crit122V6b, OBJECT 87986725f1b78c60477b08f47458fd5b8f764b3d. Арбитраж: verdicts/arbitration/122-granica-svyazi-predmeta-s-proektom.md, resolved, прочитан целиком. Исправительный вход: `/tmp/dev-harness-verify/task-122-architect-v6fix2.md`. База ремонта f33f1b0c9dbfa30f25eaea19592afb9f8dbbe1dd. Один обход: выбор ROOT отключал сверку существующей HEAD-декларации. Production-скрипты, схема identity, Г1–Г3/v5/205 и остаточная граница не меняются. Ни санкция нового суда, ни accept/freeze этим листом не заявляются.

## Двери

- pre_critic · bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/122-ci-proekta.md · 0 · 0
- precision-gate · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/122-ci-proekta.md · 0 · 0
- threat-model · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- батарея model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- батарея stabs v6 · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- батарея repo honest-red · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . · 1 · 1
- корни model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- корни repo honest-red · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r12 · 1 · 1

## Карта классов

- К-01 · чисто · вход: STABS в roots_probe.py исполняет привязки к наблюдаемым входам; контракт несёт инварианты и rc-команды, не пары стаб/ветвь · - · -
- К-02 · чисто · вход: наличие/единственность/валидность HEAD-декларации и буквальная сверка тройки больше не зависят от неравенства корней; station-explicit и station-implicit сохраняют внешнюю декларацию и валидный профиль станции · - · -
- К-03 · чисто · вход: $defs.identity и буквальное сравнение не изменены; произвольные непустые identity по 054, только зона architect 122 · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- К-05 · чисто · вход: приёмка v6 — model/stabs/repo с rc; прежние 74 относятся к сохранённой когорте, ROOTS122 печатает отдельные итоги · - · -
- К-06 · чисто · вход: gh-error и station-unresolved различают отказ настоящего Г3 и отсутствие неявного контекста; оба fail-closed · - · -
- К-07 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-09 · чисто · вход: общий JSON-канон, identity-dot/identity-json и буквальные project/repo mismatch сохранены; новые mono с собственной декларацией не запрещены · - · -
- К-10 · чисто · вход: station-explicit/station-implicit до ремонта дали rc 0, gh и запись; после — rc 1 project-workflow-rashozhdenie, журнал gh пуст и snapshots всех затронутых деревьев неизменны · - · -
- К-11 · чисто · вход: декларация читается из HEAD до subject/profile/origin сверок для любого выбранного корня; неявный контекст не заменяет независимое объявление · - · -
- К-12 · чисто · вход: стандартный jsonschema с прежней схемой, штатные profile_resolver/project_workflow, git plumbing; второго резолвера/формата нет · - · -
- К-13 · чисто · вход: fixture-gh несёт только имена по origin; секрет станции не удовлетворяет внешнюю декларацию, живые значения не читаются/не копируются · - · -
- К-14 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-15 · чисто · вход: AST словарей roots_probe.py независимо от исполнения даёт CASES=27 STABS=18; ROOTS122 TOTAL=27 и STABS=18; прежние 74 результата печатаются отдельно · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- К-17 · н/п · механизм харнесса, бриф архитектуры 188 не заявлен · - · -

## Дельта

- К-02 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-11 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0

## Доказательства конечного ремонта

Все пять блоков предыдущей карты — проявления одного обхода. Способ канон/инструмент: прежняя HEAD-декларация и прежний JSON-канон применяются независимо от выбора корня; переносится область применения существующего буквального сравнения, новый источник полномочий не вводится. Клетка нужна, поскольку формат/статическое сравнение сами по себе не наблюдают gh и запись git.

Мутация критика — внешний предмет мира missing-secret при выборе станции явным контекстом (`station-explicit`). Соседняя — отсутствие аргумента контекста при разрешимом собственном профиле ROOT (`station-implicit`). В обоих мирах профиль/origin/subject станции настоящие; внешний HEAD-блоб сохранён, внешний secret отсутствует, у станции он есть. `station-unresolved` отдельно опускает аргумент при неразрешимом ROOT; это не прежний `no-context`, где явно передан отсутствующий файл.

Новый предикат применения сверки на ROOT краснится возвратом старого условия: адресные station-binding-unchecked и implicit-binding-unchecked воспроизводят ошибочные rc 0/gh/запись на соответствующих входах. Честные эквиваленты — mono-declared и mono-declared-explicit с совпадающей тройкой (собственная декларация не запрет), project-secret и station-writes с внешним проектом. Ветка допустимого отсутствия объявления краснится mono-declaration-required на mono-explicit, честные mono/mono-explicit остаются зелёными. mono-binding-rejected различает ложный отказ при наличии собственной корректной декларации. Повтор/невалидность объявления проверяются и для внешнего корня прежними клетками, и для ROOT новыми station-binding-duplicate/station-binding-invalid; ранее обе новые клетки проходили ошибочно. Все привязки исполняются только в STABS, не в контракте.

Красное ДО изменения модели: `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12` → сырой rc 1, ROOTS122 TOTAL=27 GREEN=23 RED=4. Поимённо красны station-explicit, station-implicit, station-binding-duplicate, station-binding-invalid: субъект rc 0, нет причины project-workflow-rashozhdenie, вызван gh, изменены HEAD/теги/реестр. Остальные клетки зелены, включая честные mono-контроли. Это первое предъявление новых клеток до правки модели, не повтор известного critic-скрипта.

ПОСЛЕ изменения модели та же команда → сырой rc 0, ROOTS122 TOTAL=27 GREEN=27 RED=0. Оба выбора станции и повтор/невалидность дают субъектом rc 1 project-workflow-rashozhdenie до gh/записей; station-unresolved — rc 1 project-workflow-otsutstvuet. Негативы проверяют причину, пустой журнал gh и равенство snapshots в памяти. Mono без объявления с прежним CLI/явным контекстом и mono с собственной декларацией в обеих формах — субъект rc 0. `--stabs` → сырой rc 0, ROOTS122 STABS=18 CAUGHT=18; для каждого предъявления честный контроль валиден. AST-подсчёт → CASES=27, STABS=18, независимо от итогов раннера.

## Исторические замеры (не результаты нынешнего ремонта)

До этого ремонта на 87986725f1: полный model → rc 0, 74/74/0 и ROOTS122 19/19/0; stabs → rc 0, 14/14. Repo → rc 1, 74/54/20 и ROOTS122 19/1/18. Прежний check_sdacha → rc 0, двери=10 карта=17/17 дельта=11. Более ранний ремонт по Crit122V6 наблюдал foreign-project ошибочно rc 0 и identity-dot ошибочно rc 1; он остаётся историей, а не новой дельтой настоящего FAIL. Предшествующий accept v5: Crit122V5c, ae1e592529e1d2a34cbca8055ea912233a33d21c.

## Граница доказательства и развилки

Миры одноразовые; изолированы только несвязанные spec-preflight/doc-classifier по существующему прецеденту. `--repo` использует настоящий freeze/git/Г3/резолвер, без достройки модельной ногой; honest-red до реализации не устраняется production-правкой в этой пачке. Живые gh/GitHub/продукт/CI — NOT_RUN. Резолверы, общий JSON-канон, алфавит identity, Г1–Г3/v5/205 и остаточный риск происхождения/гонки сохранены. Проверка доказывает согласованность, не авторство источника. Контракт 149 и secret PILOT_DEMO_CODE не изменены. Новых дверей/обязательств сверх арбитража нет. Ресурс следующего узкого critic-вызова/accept/freeze остаётся оркестратору по арбитражу, здесь не присваивается. Записи общего журнала вне зоны этой пачки не делаются.

## Сырые замеры текущего кандидата

Полный `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model` → сырой rc 0: сохранённая когорта 74/74/0 и ROOTS122 TOTAL=27 GREEN=27 RED=0. Полный `--repo .` → сырой rc 1, honest-red: сохранённая когорта 74/54/20 и ROOTS122 TOTAL=27 GREEN=4 RED=23; зелёные корневые клетки — mono, mono-explicit, mono-declared, mono-declared-explicit. В production станционный обход по-прежнему наблюдаем и именованно красен; реализующая нога в эту пачку не подложена.

`bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md` → сырой rc 0, ЗАЩИЩАЕТ 11 / НЕ ЗАЩИЩАЕТ 8 буллетов. `bash scripts/check_provodka.sh --grammar . contracts/122-ci-proekta.md` → сырой rc 0.

`bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md` → rc 0, «КРИТИК: дверь зелёная». Финальный `bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run` → rc 0, «СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=5)»; проверены заявленные rc всех дверей, включая отдельный repo-r12 honest-red.
