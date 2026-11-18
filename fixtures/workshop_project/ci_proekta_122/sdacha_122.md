# СДАЧА 122 v6 — ROOT записи заморозки / PROJECT_ROOT предпосылок

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-122-v5.md

Предыдущий accept: Crit122V5c, OBJECT ae1e592529e1d2a34cbca8055ea912233a33d21c. Предмет этой дельты — слово владельца 2026-11-18 ~21:58 UTC и задание `/tmp/dev-harness-verify/task-122-architect-v6.md`; основание `/tmp/dev-harness-verify/Cons149Pred/otvet.md` прочитано целиком. Прежние Г1–Г3/v5/205 не ослабляются. Production-скрипты не изменены: implementer получает их только после freeze.

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

- К-01 · чисто · вход: STABS в roots_probe.py исполняет привязку мутанта к наблюдаемому входу, контракт несёт инварианты и rc-команды, не пары стаб/ветвь · - · -
- К-02 · чисто · вход: слово владельца в задании v6 и Cons149Pred/otvet.md; ROOT записи не меняется, secret в 149 не заменяется · - · -
- К-03 · чисто · вход: только зона architect контракта 122; production и резолверы не изменены, контекст не даёт произвольному пути статус identity · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- К-05 · чисто · вход: приёмка v6 — model/stabs/repo с rc; прежние числа 74 относятся к сохранённой когорте, ROOTS122 печатает собственные итоги · - · -
- К-06 · чисто · вход: gh-error проверяет ненулевой rc настоящего Г3 на fixture-инвентаре; gh полностью без секретных значений; прежняя средовая python-yaml-nedostupen не изменена · - · -
- К-07 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-09 · чисто · вход: раздельные projectId/origin/subject-blob/нет-контекста/неоднозначность, отсутствующий секрет и ошибка gh проверяются независимо · - · -
- К-10 · чисто · вход: snapshot обоих деревьев до вызова, тег указывает на исходный HEAD станции, реестр содержит её tag-object, verdict/contract сравниваются байтами · - · -
- К-11 · чисто · вход: ожидания CASES и snapshots живут в памяти до вызова; в --repo настоящий freeze/git/Г3/резолвер, не модельная достройка; журнал gh фиксирует фактический -R · - · -
- К-12 · чисто · вход: project_workflow.schema.json + стандартный jsonschema; профили/пути — настоящие profile_resolver/project_workflow, факты git — plumbing · - · -
- К-13 · чисто · вход: fixture-gh отдаёт только имена по origin; отсутствующий секрет при одноимённом секрете станции красен, продуктовый PILOT_DEMO_CODE не читается/не копируется · - · -
- К-14 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-15 · чисто · вход: корни 10/10/0 в модели; STABS=8 CAUGHT=8 с отдельным честным контролем каждого предъявления; прежняя когорта печатает собственные 74 результата · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры 188 отсутствуют, предмет — механизм харнесса · - · -

## Дельта

- К-01 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r12 · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-10 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-11 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . · 1 · 1
- К-12 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0

## Граница доказательства

Миры одноразовые. В корневых клетках изолированы только чужие spec-preflight и doc-classifier, как в существующей freeze-батарее; эти двери не доказаны данной дельтой. Реальный gh/продукт/сеть не вызываются. Доказана согласованность subject-bound project_workflow с эффективным профилем и origin, а не доверенность поставщика контекста; этот остаток и конкурентная смена репо после сверки названы в контракте с ловцом. Модельная схема требует установленный Python jsonschema. Прежние env-интерфейсы Г1–Г3 и 74 клетки сохранены; новые --stabs относятся только к адресной дельте корней, прежние стабы запускаются прежним env-интерфейсом.

## Сырые замеры v6

`bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md`: rc 0, последняя строка «КРИТИК: дверь зелёная». `bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run`: rc 0, «двери=10 карта=17/17 дельта=8». `--model`: rc 0, 74/74/0 и ROOTS122 TOTAL=10 GREEN=10 RED=0. `--stabs`: rc 0, ROOTS122 STABS=8 CAUGHT=8. `--repo .`: rc 1, прежние 74/54/20 и ROOTS122 TOTAL=10 GREEN=1 RED=9; однорепозиторная клетка mono уже зелена до реализации, девять адресных предъявлений разделения корней честно красны. Проверка модели угроз: rc 0, ЗАЩИЩАЕТ 11, НЕ ЗАЩИЩАЕТ 8; грамматика ПРОВОДКА: rc 0. Реальные проверки продукта/GitHub не запускались.

