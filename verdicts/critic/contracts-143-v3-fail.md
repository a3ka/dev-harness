FAIL

СУД: repo=dev-harness; предмет=143; фаза=контракт v3 (mob-ci-razdelenie); роль=critic; вызов=3/5 (2/2 базового бюджета фазы + данный сверхбазовый по слову владельца 2026-11-06 ~16:54 UTC «да» на A1, независимый GLM-суд; запись СУД в HANDOFF «ЧЕКПОЙНТ 07.11 ~12:30 UTC», main=9f467fe6); модель-план=zai/glm-5.3; сессия=Critic143V3Glm; модель-факт=zai/glm-5.3; SHA=5c9858716c33b8e38e3387e8b9dc9f0562723406; предыдущий=Critic143V3Repair accept на 436bf7b8 (Sol, не материализован — история, не accept); исключение=GLM-мораторий снят словом владельца 2026-11-06; scoped=закрытие ранее названных классов и последствия дельты v2→v3 и интеграции. Независимость: фактический автор OBJECT — architect (openai-codex/gpt-6-sol по трейсу HANDOFF:87), судья glm — пары автор/судья не совпадают.

## Дельта и область

OBJECT `5c9858716c33b8e38e3387e8b9dc9f0562723406` (родитель `725f932dc`, два коммита поверх `8b8fadea` — предка origin/main). `git diff --name-only 8b8fadea..OBJECT` — ровно 11 путей: `contracts/143-mob-ci-razdelenie.md` + 10 файлов `fixtures/workshop_project/mob_ci_143/` (matrix_v3.py, connected_v3.py, model/matrix-v3.yml, model/mobile/scripts/{ci-aggregate,select-ci-screens,run-ci-screen}.cjs, probe.py, red_mob_ci_143.sh, source.json, stabs/stab_i_child_bez_podpisi.py) — все в ЗОНА architect (`:166`), вне зоны ноль; frozen-барьеры, scripts/, .github/ не тронуты. Дерево OBJECT `36c207872b7399e3d6a1ab21b82d33c6f9fb63f8` совпадает с записанным в HANDOFF:85; равенство `merge-tree(origin/main, 436bf7b8)` в моём клоне непроверяемо — объекта 436bf7b8 нет ни в клоне, ни на origin, это сверка оркестратора.

Область суда: закрытие материализованных классов (v2 krug1 `contracts-143-v2-krug1-fail.md`, v2 scoped `contracts-143-v2-scoped-fail.md`, арбитраж `contracts-143-v2-kritik-budget.md` Б1–Б2, условия v2d-accept `contracts-143-v2.md`), дельта v2→v3 и её интеграция. «Прежние пять классов» Critic143V3Scoped (OBJECT 0205e323) в репозитории НЕ материализованы (ни вердикт-файла, ни перечня в HANDOFF; счёт только по журналу зомка, HANDOFF:86) — суд вёден по материализованным источникам; совет 3 ниже.

Механические сверки контракта — полным списком (расхождений нет): «v3 13/13 и v2 80/80» — наблюдено; «8 обманных субъектов/9 адресных привязок … затем v2 80/80 и 62 legacy-стаба» — наблюдено («стабов 8, привязок 9, живых 0» + «стабов 62, привязок 78, непойманных 0»); продуктовый прогноз `:325` (rc 1, MATRIX_DAG/MATRIX_OUTPUT_ABSENT/CHILD_NOT_AGGREGATED, 79 клеток, i03 красна «нет выхода работнику: ['matrix']») — наблюдено дословно; pre_critic rc 0 `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4`; порча `source.json:v3_piny` → rc 2 `ORACLE_TAMPERED` — наблюдено; ЗОНА implementer дополнена `run-ci-screen.cjs` (`:166`); КЛАСС РИСКА (`:3`, «ложная зелень required + health-домен») и модель угроз v3 (`:332–333`) на месте; i06 в --repo заменена (79 клеток против 80 на --model) ровно как заявлено.

## Исполняемые проверки — сырой вывод

Клон `/tmp/dev-harness-verify/Crit143V3Glm/repo` (SSH origin, свой .git), detached OBJECT; атаки — в одноразовых копиях `/tmp/dev-harness-verify/Crit143V3Glm/attack/`.

```
$ bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md   # rc 0
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
КРИТИК: дверь зелёная
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model      # rc 0
клеток 13, зелёных 13, красных 0
клеток 80, зелёных 80, красных 0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs     # rc 0
клеток 13, зелёных 13, красных 0
СТАБ legacy-rewritten @ legacy КРАСЕН: LEGACY_JOB_CHANGED
СТАБ matrix-hardcoded @ matrix КРАСЕН: MATRIX_DAG
СТАБ matrix-fixed-host @ allocator КРАСЕН: MATRIX_ALLOCATOR
СТАБ aggregate-no-child @ evidence КРАСЕН: MATRIX_NEEDS_AGGREGATE_android-e2e
СТАБ no-digest @ apk КРАСЕН: MATRIX_APK_OR_SECRET
СТАБ secret-leak @ apk КРАСЕН: MATRIX_APK_OR_SECRET
СТАБ selector-fixed @ selector-growth КРАСЕН: MATRIX_NOT_FROM_MAP
СТАБ aggregate-echo @ child-missing КРАСЕН: CHILD_NOT_FAIL_CLOSED
СТАБ aggregate-echo @ child-wrong-digest КРАСЕН: CHILD_NOT_FAIL_CLOSED
стабов 8, привязок 9, живых 0
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /home/harness/projects/Complior-mob   # rc 1
КЛЕТКА legacy ЗЕЛЕНА
КЛЕТКА matrix КРАСНА: MATRIX_DAG
КЛЕТКА allocator КРАСНА: MATRIX_ALLOCATOR
КЛЕТКА evidence КРАСНА: MATRIX_NEEDS_AGGREGATE_android-e2e
КЛЕТКА apk КРАСНА: MATRIX_APK_OR_SECRET
КЛЕТКА selector КРАСНА: MATRIX_OUTPUT_ABSENT
КЛЕТКА child-ok КРАСНА: CHILD_NOT_AGGREGATED
КЛЕТКА child-missing КРАСНА: CHILD_NOT_FAIL_CLOSED
КЛЕТКА child-wrong-digest КРАСНА: CHILD_NOT_FAIL_CLOSED
КЛЕТКА empty-matrix КРАСНА: MATRIX_EMPTY_AGGREGATE
клеток 10, зелёных 1, красных 9
клеток 79, зелёных 78, красных 1
КЛЕТКА i03-vyhody-selektora: выходы ['e2e-erstinformation', 'e2e-first-run', 'e2e-pilot', 'e2e-splash', 'e2e-start', 'selection'] ≠ канон ['e2e-erstinformation', 'e2e-first-run', 'e2e-pilot', 'e2e-splash', 'e2e-start', 'matrix', 'selection'] (нет выхода работнику: ['matrix']) КРАСНА
```

Порча оракула (копия фикстур, sha в v3_piny заменён):
```
$ bash .../attack/tamper/red_mob_ci_143.sh --model          # rc 2
ORACLE_TAMPERED: model/matrix-v3.yml
```

Зависимый регресс закрытых классов v2d на кандидате v3 (копии model/, стабы батареи):
```
$ .../red_mob_ci_143.sh --repo attack/mut-podpis            # stab_i_child_bez_podpisi → rc 1
КЛЕТКА i09-podpis-child-flows: policy_change не поднят (False; prichiny ['COMMON_CHANGE']): … КРАСНА   [дословно как в v2d]
$ .../red_mob_ci_143.sh --repo attack/mut-vladenie          # stab_i_child_rezhet_vybor → rc 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/splash-child-proba.yaml: rc=1 VYBOR_OTKAZ: INVENTAR_KARTY: … КРАСНА
```

Регресс соседей (живые команды, каждый rc 0):
```
$ bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs
SVJAZI 69
zhivykh 0
$ bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs
SVJAZI 60
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
SVJAZI 66
zhivykh 0
```

## Блокирующие находки

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:317 — названный отказ инварианта 3 «`needs.e2e-screen != success` при выбранных child — отказ» не имеет различающего красного свидетельства: удаление ровно этой ветви из модельного `ci-aggregate.cjs` (строка `if (needs["e2e-screen"]?.result !== …) otkaz("MATRIX_PARENT_OTKAZ")`) оставляет ОБЕ батареи полностью зелёными.
ОБЯЗАТЕЛЬСТВО: инвариант 3 (`:317`) перечисляет отказы агрегата; три из четырёх (legacy needs, пустая selection, отсутствующий/чужой child result) доказаны красными клетками/стабами, четвёртый (родительский статус) реализован в модели, но никакая клетка его не проверяет — критерий «краснеют на обманном» для этого поля обязательства не выполнен. Тот же класс, что блок 2 Arb143v2 (named-обязательство без красного доказательства; конечное новое поле дельты, не требование бесконечной полноты).
СОСТОЯНИЕ: вход «выбранные дети + полный действительный evidence + needs.e2e-screen.result ≠ success» — воспроизводимый путь от поддерживаемых операций: отмена прогона после публикации evidence (upload стоит под `if: always()`), падение любого шага после upload; родственный вход (result='skipped' при пустом выборе) конструируется самой батареей в empty_case. Ошибочный механизм — удаление уже имеющейся предметной операции дельты (ветка MATRIX_PARENT_OTKAZ в ci-aggregate.cjs:80).
НАБЛЮДЕНИЕ (сырой вывод; мутант в attack/mutC2, пин пересчитан):
```
$ bash attack/mutC2/red_mob_ci_143.sh --model    → клеток 13, зелёных 13, красных 0; клеток 80, зелёных 80 RC=0
$ bash attack/mutC2/red_mob_ci_143.sh --stabs    → стабов 8, привязок 9, живых 0; 80/80; 62/78 RC=0
$ python3 attack/parent_fail_probe.py            # parent=failure + оба result.json
HONEST rc=1 stdout='AGREGAT_OTKAZ: MATRIX_PARENT_OTKAZ'
MUTANT_C2 rc=0 stdout='CHILD_EVIDENCE_OK'
DIVERGENCE_CONFIRMED
```
Закрывающее свойство (не единственная реализация): негативная ветка приёмки на входе «выбранные дети + parent ≠ success» даёт rc 1 именованного отказа у честного агрегата, и субъект, игнорирующий родительский статус, красен (по образцу child-missing/child-wrong-digest: третья ветка evidence_case либо адресный стаб).

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:315 — названная уникальность «владелец flow уникальны» (инвариант 1) и «уникальный порт вне legacy…» (инвариант 2, `:316`) не имеет различающего красного: клетка selector-duplicates кормит селектор ТОЛЬКО повторами id и pack, а приёмка (`:324`) обещает лишь «повторы id/pack отвергает». Удаление обеих проверок из модельного селектора (schedule-ветвь poFlow → INVENTAR_KARTY и MATRIX_PORT_KOLLIZIJA) оставляет обе батареи зелёными.
ОБЯЗАТЕЛЬСТВО: инварианты 1–2 (`:315–316`) заявляют уникальность владельца flow и порта для новых экранов; оба механизма реализованы в селекторе дельты (poFlow-ветвь razberiKartu, fail MATRIX_PORT_KOLLIZIJA) — их молчаливое удаление неразличимо приёмкой.
СОСТОЯНИЕ: карта с двумя e2e-screen, владеющими одним flow (либо одним avd_port), режим schedule — поддерживаемый вход ночной mobile-regression-signal; карты доставляются PR («Новая запись карты и pack/flow доставляются одним PR», `:318`). Ошибочный механизм — удаление уже имеющихся предметных операций дельты.
НАБЛЮДЕНИЕ (сырой вывод; python3 attack/uniq_probe.py, мутант в attack/mutC3, пин пересчитан):
```
A_HONEST_DUP_FLOW rc=1 stderr='VYBOR_OTKAZ: INVENTAR_KARTY: map head: head'
B_HONEST_DUP_PORT rc=1 stderr='VYBOR_OTKAZ: MATRIX_PORT_KOLLIZIJA'
C_MUTANT_DUP_FLOW rc=0
C_MUTANT_DUP_PORT rc=0
HONEST_REFUSES=True MUTANT_ACCEPTS=True
$ bash attack/mutC3/red_mob_ci_143.sh --model    → клеток 13, зелёных 13, красных 0; клеток 80, зелёных 80 RC=0
```
Закрывающее свойство: duplicate_case дополняется повтором владельца flow и повтором avd_port — честный селектор отвергает оба, субъект без соответствующей проверки красен; расположение проверок — решение архитектора.

## Советы (не блокируют)

1. Статическая if-граница пустой матрицы: удаление job-level `if:` из e2e-screen (model/matrix-v3.yml) проходит всю батарею rc 0 (замер attack/mutC1: 13/13 + 80/80). Наблюдаемое нарушение механизма skip лежит в объявленной границе НЕ ЗАЩИЩАЕТ v3 (`:333`, «настоящую GitHub интерпретацию fromJSON/skip — живой CI/adversary»), поэтому совет: дополнить клетку matrix статической проверкой присутствия `if`-границы `needs.select-screens.outputs.matrix != ''` (проводка, не GitHub-семантика).
2. `:325` перечисляет три красные клетки продуктового прогона, фактических красных девять (ещё MATRIX_ALLOCATOR, MATRIX_NEEDS_AGGREGATE_android-e2e, MATRIX_APK_OR_SECRET, CHILD_NOT_FAIL_CLOSED ×2, MATRIX_EMPTY_AGGREGATE) — формулировка неточна как перечень, минимальный прогноз верен; уточнить перечень при следующей правке текста.
3. «Прежние пять классов» Critic143V3Scoped не материализованы в репозитории — оркестратору приложить их перечень в задание следующего (исправительного) вызова, чтобы scoped-проверка закрытия была проверяемой по файлу, а не по журналу зомка.

## Вывод

Дельта v2→v3 механически точна (все счётные утверждения подтверждены живыми прогонами), замороженные поверхности не тронуты, классы v2d (i08/i09) закрыты и держатся под дельтой, соседи зелёные. Но два названных поля обязательств новой дельты — родительский отказ агрегата (`:317`) и уникальность владельца flow/порта (`:315–316`) — предъявлены механизмом без различающего красного: обманные субъекты проходят обе батареи rc 0. Это тот же класс, что Arb143v2 блок 2, закрываемый адресной клеткой/стабом до accept. FAIL до закрытия обоих классов; арбитраж не требуется — инженерные формулировки конечны и не оспорены.
