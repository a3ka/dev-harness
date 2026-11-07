accept

СУД: repo=dev-harness; предмет=143; фаза=контракт v3 (mob-ci-razdelenie), scoped-исправительный после FAIL 3/5; роль=critic; вызов=4/5 (исправительный в пределах общего капа 5; FAIL 3/5 инженерные формулировки конечны и не оспорены — арбитраж не требовался); модель-план=zai/glm-5.3; сессия=Crit143V3Glm4; модель-факт=zai/glm-5.3; SHA=ff10153acd3a5f7d295df73c74a236854612edbc; предыдущий=FAIL verdicts/critic/contracts-143-v3-fail.md (вызов 3/5, origin/main 38ab6c33); исключение=нет; scoped=закрытие блоков Б-1 (:317) и Б-2 (:315/:316) вызова 3 + последствия дельты 5c985871..ff10153a. Независимость: фактический автор OBJECT — architect (architect@dev-harness.local; gpt-6-sol по трейсу вызова 3), судья glm — пара автор/судья независима. Запись СУД в HANDOFF — ближайшей партией (учётная задержка названа оркестратором; консультант 2026-11-07 ~13:00: «учёт СУД одной партией — не причина держать суд»).

## Дельта и область

OBJECT `ff10153acd3a5f7d295df73c74a236854612edbc` (родитель `5c985871`, один коммит; merge-base с origin/main = `8b8fadea`). `git diff --name-status 5c985871 ff10153a` — ровно 2 пути: `contracts/143-mob-ci-razdelenie.md` + `fixtures/workshop_project/mob_ci_143/matrix_v3.py`, оба в ЗОНА architect (`:166`); `git diff --name-only 8b8fadea..OBJECT` — те же 11 путей, что проверены вызовом 3; frozen-барьеры, scripts/, .github/ не тронуты. Тело коммита несёт строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: правка счётных чисел приёмки v3 (`:324`/`:326`) после красных клеток parent=failure / дубль владельца flow / дубль порта, слово владельца 2026-11-05 ~13:55 UTC («если ты все перепроверил и здесь надо "да", то ок»), объём — та же v3; консультант подтвердил строку 2026-11-07 ~13:15.

Текст контракта: `git diff --word-diff 5c985871 ff10153a` — ровно три счётных замены на двух строках: `13/13`→`16/16` (`:324`), `8`→`11` обманных субъектов и `9`→`12` адресных привязок (`:326`). Иной текст не изменён; инварианты `:315`–`:317`, КЛАСС РИСКА (`:3`), модель угроз v3 (`:332`–`:333`) не тронуты.

Кодовый дельта `matrix_v3.py`: новая `duplicate_matrix_case` (schedule-карта, два экрана на одном `flows[]` либо одном `avd_port`, честный селектор обязан rc 1), расширение `evidence_case(parent_failure=True)` (`needs.e2e-screen.result='failure'` при полных действительных child-result, честный агрегат обязан rc 1 `AGREGAT_OTKAZ: MATRIX_PARENT_OTKAZ`), три клетки (`selector-duplicate-flow`, `selector-duplicate-port`, `child-parent-failure`) и три стаба (`selector-no-flow`, `selector-no-port`, `aggregate-no-parent`) на строковых якорях тех же ветвей с rc 2 `ORACLE_TAMPERED` при дрейфе якоря; счётчик стабов `len(STUBS)+2/+3` → `+5/+6`.

## Закрытие блоков вызова 3/5 — воспроизведение мутантов (сырой вывод)

Мутанты вызова 3 воспроизведены в одноразовых копиях (`/tmp/dev-harness-verify/Crit143V3Glm4/attack/mutC2`, `mutC3`; guard-строки удалены, sha-пин в `source.json:.piny` копии пересчитан — тот же метод, что в вызове 3):

Б-1 (`:317`, MATRIX_PARENT_OTKAZ) — мутант mutC2 (ветка `if (needs["e2e-screen"]?.result !== …) otkaz("MATRIX_PARENT_OTKAZ")` удалена из `model/mobile/scripts/ci-aggregate.cjs:80`):
```
$ bash attack/mutC2/red_mob_ci_143.sh --model
КЛЕТКА child-parent-failure КРАСНА: MATRIX_PARENT_NOT_FAIL_CLOSED: CHILD_EVIDENCE_OK
клеток 16, зелёных 15, красных 1
клеток 80, зелёных 80, красных 0
RC=1
```
В вызове 3 тот же мутант давал 13/13 rc 0; теперь различающее красное есть, и стаб `aggregate-no-parent @ child-parent-failure КРАСЕН: MATRIX_PARENT_NOT_FAIL_CLOSED: CHILD_EVIDENCE_OK` ловит его же в --stabs. Честная сторона клетки зелена на OBJECT (отказ при parent=failure наблюдаем). Класс закрыт.

Б-2 (`:315`/`:316`, уникальность владельца flow и порта) — мутант mutC3 (schedule-ветвь `poFlow.has(flow)` → INVENTAR_KARTY и `MATRIX_PORT_KOLLIZIJA` удалены из `model/mobile/scripts/select-ci-screens.cjs`):
```
$ bash attack/mutC3/red_mob_ci_143.sh --model
КЛЕТКА selector-duplicate-flow КРАСНА: MATRIX_DUPLICATE_FLOW:
КЛЕТКА selector-duplicate-port КРАСНА: MATRIX_DUPLICATE_PORT:
клеток 16, зелёных 14, красных 2
клеток 80, зелёных 80, красных 0
RC=1
```
В вызове 3 тот же мутант давал 13/13 rc 0; теперь обе клетки красны, стабы `selector-no-flow @ selector-duplicate-flow КРАСЕН` и `selector-no-port @ selector-duplicate-port КРАСЕН` ловят те же удаления в --stabs. Честный селектор отвергает оба повтора (клетки зелены на OBJECT). Класс закрыт.

## Исполняемые проверки — сырой вывод

Клон `/tmp/dev-harness-verify/Crit143V3Glm4/repo` (SSH origin, свой .git), detached OBJECT.

```
$ bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md   # rc 0
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
КРИТИК: дверь зелёная
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model      # rc 0
КЛЕТКА legacy ЗЕЛЕНА … КЛЕТКА selector-duplicates ЗЕЛЕНА
КЛЕТКА selector-duplicate-flow ЗЕЛЕНА
КЛЕТКА selector-duplicate-port ЗЕЛЕНА
КЛЕТКА child-ok ЗЕЛЕНА … КЛЕТКА child-wrong-digest ЗЕЛЕНА
КЛЕТКА child-parent-failure ЗЕЛЕНА
КЛЕТКА empty-matrix ЗЕЛЕНА
клеток 16, зелёных 16, красных 0
клеток 80, зелёных 80, красных 0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs     # rc 0
клеток 16, зелёных 16, красных 0
СТАБ legacy-rewritten @ legacy КРАСЕН: LEGACY_JOB_CHANGED
СТАБ matrix-hardcoded @ matrix КРАСЕН: MATRIX_DAG
СТАБ matrix-fixed-host @ allocator КРАСЕН: MATRIX_ALLOCATOR
СТАБ aggregate-no-child @ evidence КРАСЕН: MATRIX_NEEDS_AGGREGATE_android-e2e
СТАБ no-digest @ apk КРАСЕН: MATRIX_APK_OR_SECRET
СТАБ secret-leak @ apk КРАСЕН: MATRIX_APK_OR_SECRET
СТАБ selector-fixed @ selector-growth КРАСЕН: MATRIX_NOT_FROM_MAP
СТАБ aggregate-echo @ child-missing КРАСЕН: CHILD_NOT_FAIL_CLOSED
СТАБ aggregate-echo @ child-wrong-digest КРАСЕН: CHILD_NOT_FAIL_CLOSED
СТАБ selector-no-flow @ selector-duplicate-flow КРАСЕН: MATRIX_DUPLICATE_FLOW:
СТАБ selector-no-port @ selector-duplicate-port КРАСЕН: MATRIX_DUPLICATE_PORT:
СТАБ aggregate-no-parent @ child-parent-failure КРАСЕН: MATRIX_PARENT_NOT_FAIL_CLOSED: CHILD_EVIDENCE_OK
стабов 11, привязок 12, живых 0
клеток 80, зелёных 80, красных 0
стабов 62, привязок 78, непойманных 0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /home/harness/projects/Complior-mob   # rc 1
КЛЕТКА legacy ЗЕЛЕНА
КЛЕТКА matrix КРАСНА: MATRIX_DAG … КЛЕТКА empty-matrix КРАСНА: MATRIX_EMPTY_AGGREGATE
клеток 10, зелёных 1, красных 9
клеток 79, зелёных 78, красных 1
КЛЕТКА i03-vyhody-selektora: выходы […] ≠ канон […] (нет выхода работнику: ['matrix']) КРАСНА
```

Неослабление прежней батареи: все 13 прежних клеток присутствуют поимённо и зелены на честной модели (16 = 13 + 3 новых), все 8 прежних субъектов/9 привязок красны в --stabs теми же именами и причинами, v2 80/80 и legacy 62/78 неизменны; продуктовый --repo прогноз дословно совпадает с вызовом 3 (10 клеток, 9 красных, i03 красна). v2-батарея зелена и под обоими мутантами (80/80) — непреднамеренных сцепок дельта не внесла; `probe.py`, `source.json:.stab_vhod`, `connected_v3.py` дельтой не тронуты.

## Механические сверки — полным списком (расхождений нет)

1. `:324` «v3 16/16» — наблюдено «клеток 16, зелёных 16, красных 0» (--model).
2. `:324` «v2 80/80» — наблюдено «клеток 80, зелёных 80» (--model).
3. `:326` «v3 16/16» — наблюдено (--stabs).
4. `:326` «11 обманных субъектов» — наблюдено «стабов 11» (11 строк СТАБ: 8 прежних + 3 новых).
5. `:326` «12 адресных привязок» — наблюдено «привязок 12» (9 прежних + 3).
6. `:326` «затем v2 80/80 и 62 legacy-стаба» — наблюдено «стабов 62, привязок 78, непойманных 0».
7. `:325` продуктовый прогноз (rc 1, MATRIX_DAG/MATRIX_OUTPUT_ABSENT/CHILD_NOT_AGGREGATED, 79 клеток, i03 красна) — наблюден дословно, дельтой не менялся.
8. РАЗРЕШИЛ-ВЛАДЕЛЕЦ называет `:324`/`:326` и те же три красных повода — фактическая правка ровно в этом объёме (word-diff: только три числа).
9. pre_critic rc 0 `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4` — наблюдено.

## Советы (не блокируют)

1. СОВЕТ contracts/143-mob-ci-razdelenie.md:325 (C2 вызова 3, не закрыт) — перечислены три красные клетки продуктового прогона, фактических красных девять (MATRIX_ALLOCATOR, MATRIX_NEEDS_AGGREGATE_android-e2e, MATRIX_APK_OR_SECRET, CHILD_NOT_FAIL_CLOSED ×2, MATRIX_EMPTY_AGGREGATE); строка дельтой не менялась, минимальный прогноз верен; уточнить перечень при следующей правке текста.
2. СОВЕТ fixtures/workshop_project/mob_ci_143/matrix_v3.py:169-175 (C1 вызова 3, не закрыт) — клетка matrix по-прежнему не проверяет статически job-level `if:`-границу `needs.select-screens.outputs.matrix != ''` в model/matrix-v3.yml; наблюдаемое нарушение лежит в объявленной границе НЕ ЗАЩИЩАЕТ (`:333`), остаётся советом.
3. СОВЕТ (C3 вызова 3) — перечень «прежних пяти классов» Critic143V3Scoped так и не материализован в репозитории; это оркестраторская задача, не авторская, на данный вердикт не влияет.
4. СОВЕТ fixtures/workshop_project/mob_ci_143/matrix_v3.py:307 — клетка child-parent-failure исполняется только в --model (`if not args.repo`), тогда как child-missing/child-wrong-digest судят и продукт; послерезрезной parent-статус продукта остаётся на живом CI (`:327`), обязательством не заявлен — паритет по усмотрению автора.
5. СОВЕТ fixtures/workshop_project/mob_ci_143/matrix_v3.py:129 — у стабов selector-no-flow/selector-no-port причина обрезана до пустой строки (`MATRIX_DUPLICATE_FLOW: `): мутант пишет принятие в stdout, excerpt берётся из stderr; косметика, КРАСЕН корректен.

## Вывод

Оба блокирующих класса вызова 3/5 закрыты различающим красным: мутанты вызова 3 (удаление ветки MATRIX_PARENT_OTKAZ из агрегата и проверок уникальности flow/порта из селектора), проходившие обе батареи rc 0, теперь дают rc 1 поимёнными клетками; честные субъекты те же входы отвергают. Дельта текста — ровно три счётных числа, заявленных строкой РАЗРЕШИЛ-ВЛАДЕЛЕЦ по слову владельца; все числа приёмки совпадают с живым census; прежние 13 клеток/8 стабов не ослаблены; замороженные поверхности не тронуты. Открытых блокирующих классов нет. Замечания — советы, едут с accept.
