# СДАЧА 122 v6 — ROOT записи заморозки / PROJECT_ROOT предпосылок

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-122-v5.md

Предыдущий accept: Crit122V5c, OBJECT ae1e592529e1d2a34cbca8055ea912233a33d21c. Исправительный вход: `/tmp/dev-harness-verify/task-122-architect-v6fix.md`, вердикт Crit122V6 на ad8a7c763e прочитан целиком. Основание v6 — слово владельца 2026-11-18 ~21:58 UTC. Прежние Г1–Г3/v5/205 не ослабляются. Production-скрипты не изменены: implementer получает их после freeze. Ремонт закрывает только независимую связь предмета с проектом и совместимость identity с 054.

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
- К-02 · чисто · вход: независимый источник — декларация ПРОЕКТ-ПРЕДПОСЫЛОК из HEAD-блоба TARGET; foreign-project и foreign-identity отказывают до gh/записей; ROOT записи и secret в 149 не меняются · - · -
- К-03 · чисто · вход: identity из общего $defs.identity схемы — любые непустые строки по 054 И-4; только зона architect 122, production и резолверы не изменены · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- К-05 · чисто · вход: приёмка v6 — model/stabs/repo с rc; прежние 74 относятся к сохранённой когорте, ROOTS122 печатает собственные итоги · - · -
- К-06 · чисто · вход: gh-error проверяет ненулевой rc настоящего Г3 на fixture-инвентаре без значений секретов; прежняя средовая python-yaml-nedostupen не изменена · - · -
- К-07 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-09 · чисто · вход: identity-dot и identity-json принимаются настоящим резолвером и моделью; project/repo mismatch отвергаются буквальным сравнением; чужой реальный проект с честным профилем/origin не заменяет декларацию HEAD · - · -
- К-10 · чисто · вход: snapshot всех затронутых деревьев до вызова, тег на исходном HEAD станции, реестр с её tag-object, verdict/contract сравниваются байтами; отказ контекста происходит до gh · - · -
- К-11 · чисто · вход: CASES и snapshots живут в памяти; HEAD-декларация независима от контекста; --repo вызывает настоящий freeze/git/Г3/резолвер, не модельную достройку · - · -
- К-12 · чисто · вход: project_workflow.schema.json — единый источник грамматики identity контекста и HEAD-декларации; стандартный jsonschema, штатные profile_resolver/project_workflow, git plumbing · - · -
- К-13 · чисто · вход: fixture-gh отдаёт только имена по origin; одноимённый секрет у чужого проекта не скрывает отсутствие секрета у объявленного; живой PILOT_DEMO_CODE не читается/не копируется · - · -
- К-14 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-15 · чисто · вход: словари CASES/STABS содержат 19/14 записей (подсчёт AST); прежняя когорта печатает собственные 74 результата; каждое адресное предъявление имеет честный контроль · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- К-17 · н/п · предмет — механизм харнесса, инструменты и бриф архитектуры 188 не заявлены · - · -

## Дельта

- К-01 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-02 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-03 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r12 · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-10 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-11 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-12 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0

## Доказательства исправительного круга

Блок 1: способ канон/инструмент — используется уже выбранный HEAD-блоб предмета, а не новое доверенное поле контекста. Мутация критика — другой реальный проект с собственным профилем/origin и одноимённым секретом; соседняя — другой identity при том же origin. Отдельно проверены отсутствие/повтор/невалидность декларации. Проверка числа записей, JSON-канона и буквального совпадения имеет адресные мутанты в коде; честные project-secret/station-writes и identity-json остаются зелёными. Расширения границы риска нет.

Блок 2: способ канон/инструмент — общий $defs.identity задаёт type=string/minLength=1, как И-4 контракта 054; нормализации/regexp нет. Честные identity-dot (оба поля с точками) и identity-json (кириллица, кавычки, LF/tab, обратная косая, regexp/glob-метасимволы) разрешаются настоящим резолвером; отрицательные project/repo mismatch проверяют буквальное равенство. Возврат старого regexp краснится адресным стабом; привязка — только в коде.

Красное ДО ремонта модели/схемы: `python3 fixtures/workshop_project/ci_proekta_122/roots_probe.py --model --case foreign-project` → rc 1 клетки, субъект ошибочно rc 0, вызвал gh и изменил HEAD/тег/реестр. `--case identity-dot` → rc 1 клетки: штатный profile_resolver rc 0, субъект rc 1 project-workflow-rashozhdenie. Это воспроизведение на новых регрессионных входах до изменения модели, не повтор проверки critic-скрипта.

## Граница доказательства

Миры одноразовые. В корневых клетках изолированы только чужие spec-preflight и doc-classifier по существующему freeze-прецеденту; эти двери не доказываются данной дельтой. Реальный gh/продукт/сеть не вызываются. Источник связи независим от переданного контекста — HEAD-блоб предмета; доверенность поставщика и конкурентная смена репо после сверки остаются ровно прежней границей контракта, не изменённой этим ремонтом. Новая модельная схема требует Python jsonschema. Прежние env-интерфейсы Г1–Г3 и 74 клетки сохранены; --stabs относится к адресной дельте корней, прежние стабы запускаются прежним env-интерфейсом. Контракт 149 не менялся; перед его внешней заморозкой декларация связи должна присутствовать в его HEAD согласно v6, с сохранением - secret PILOT_DEMO_CODE.

## Сырые замеры ремонта v6

`bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md` → rc 0, «КРИТИК: дверь зелёная». Полный `--model` → rc 0: прежние 74/74/0 и ROOTS122 TOTAL=19 GREEN=19 RED=0; foreign-project/foreign-identity отказывают субъектом rc 1, identity-dot/identity-json принимаются субъектом и штатным резолвером rc 0. `--stabs` → rc 0, ROOTS122 STABS=14 CAUGHT=14; каждый честный контроль валиден. Подсчёт AST независимо от исполнения → CASES=19, STABS=14. `check_threat_model` → rc 0 (11/8 буллетов), `check_provodka --grammar` → rc 0. Голый `--repo .` предъявлялся до реализации и дал rc 1; production не менялся.

Итоговый `bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run` → rc 0, «двери=10 карта=17/17 дельта=11». Итоговый `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo .` → rc 1 (honest-red), сохранённая когорта 74/54/20 и ROOTS122 TOTAL=19 GREEN=1 RED=18; единственная зелёная корневая клетка до реализации — mono.
