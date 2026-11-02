FAIL
OBJECT=832dab55dbb4e88af20041ff12d403ff4f4cbd24
СУД: repo=dev-harness; предмет=154; фаза=контракт (+красная батарея); роль=critic; вызов=3/5 (исправительный по санкции HANDOFF.md:1, фазовый бюджет предыдущих двух вызовов исчерпан); модель-план=openai-codex/gpt-6-sol; сессия=Crit154c; модель-факт=openai-codex/gpt-6-sol; SHA=832dab55dbb4e88af20041ff12d403ff4f4cbd24; предыдущий=FAIL (verdicts/critic/contracts-154-v1b-fail.md, OBJECT 869174290, вызов 2; первоначальный FAIL — contracts-154-v1-fail.md, вызов 1); исключение=нет.

Счёт и независимость: запись ДО вызова — HANDOFF.md:1 в основном репозитории, main e5b6decb7 по заданию оркестратора. Автор исправительной дельты — Arch154c/Arch154d, zai/glm-5.3; первая версия — Sol, но назначение Sol на этот суд — адресное слово владельца 2026-11-02, названное в HANDOFF.md:1. Модель-факт этого вызова openai-codex/gpt-6-sol; дельту GLM не судит сам себя. Предмет — commit (`git cat-file -t 832dab55dbb4e88af20041ff12d403ff4f4cbd24` → `commit`); клон `Crit154c/repo` на OBJECT, одноразовый `Crit154c/mut` для эталона и атак. В основной чекаут и репозиторий автора ничего не записано, push нет. Набор артефактов полный: предмет, критерий с командами/rc, исполнители и ЗОНА, модель угроз 4/5, КЛАСС РИСКА «рисковый — деньги» присутствуют.

**Итог:** прежние Б1–Б7 закрыты на названных путях, С1–С10 исправлены; новый класс Б8 — ложная достаточность приёмки: все живые испытания ограничены одним номером предмета. Честная установка 49/49, 206/206 и 7/7, но обманная установка получает те же зелёные и разрешает шестой платный вызов другого, действительно существующего предмета. Один класс БЛОКИРУЕТ; найденное расхождение САМООПИСАНИЕ и советы сами по себе не причина FAIL.

## Замеры (корень `repo` — OBJECT; корень `mut` — одноразовая честная вставка mk_impl; rc выводятся терминалом)

```
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh               # repo → rc=1 CELLS=49 GREEN=10, RED 39
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --model       # repo → rc=0 CELLS=52 GREEN=52
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain      # repo → rc=1 CELLS=206 GREEN=82
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain-model # repo → rc=0 CELLS=210 GREEN=210
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --stabs       # repo → rc=0 SVJAZI=19 CAUGHT=19 LIVE=0
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --live        # repo → rc=1 CELLS=7 GREEN=3; RED live-new-tag-door, live-new-tag-freeze, live-new-notag-door, live-no-granica-door
$ python3 /tmp/dev-harness-verify/Arch154b/mk_impl.py /tmp/dev-harness-verify/Crit154c/mut # → installed model patch into …/mut/scripts
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh               # mut → rc=0 CELLS=49 GREEN=49
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain      # mut → rc=0 CELLS=206 GREEN=206
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --live        # mut → rc=0 CELLS=7 GREEN=7
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh                     # repo и mut → rc=1 KLETKI 66 KRASNYH 3, ровно u01/w20/w21
$ bash fixtures/plan_084/red_plan_084.sh                                                   # repo → rc=0, 59/59; mut → rc=1, 53/59 (шесть красных до обещанной миграции)
$ bash fixtures/check_precision_gate/red_14_freeze_refuses_red_precision.sh                # repo и mut → rc=0 case_14: freeze-time backstop refuses
$ bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh               # mut → rc=0 «ветви «all» зелены»
$ bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md                         # rc=0 «КРИТИК: дверь зелёная»
$ bash scripts/check_ceilings.sh                                                            # rc=0 «потолки в порядке»; «148 черновик(ов) судится»
$ bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md             # rc=0 OK
$ bash scripts/check_threat_model.sh . contracts/154-schet-vyzovov-kritika.md               # rc=0 «ЗАЩИЩАЕТ 4 … НЕ ЗАЩИЩАЕТ 5»
$ bash scripts/check_provodka.sh . contracts/154-schet-vyzovov-kritika.md                   # rc=1 «guard не подключён» (ожидаемо до CI-проводки)
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit154c/zone-cache/cache .   # rc=0 «замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42091 · проверено по зонам: 10018» (386.23 с, гейты запускались последовательно)
$ python3 fixtures/workshop_project/schet_vyzovov_154/model/budget.py --sostojanie /tmp/dev-harness-verify/Crit154b/livecopy --repo /tmp/dev-harness-verify/Crit154b/mainclone --subject 152 --phase spawn # rc=1 «KAP_VYZOVOV_KRITIKA: … 5/5»
$ python3 …/model/budget.py --sostojanie …/livecopy --repo …/mainclone --subject 001 --phase spawn # rc=3 (старый)
$ python3 …/model/budget.py --sostojanie …/livecopy --repo …/mainclone --subject 148 --phase spawn|freeze # оба rc=1 «SCHET_NEIZVESTEN: история критика старше журнала, записи-засева нет»
$ python3 …/model/budget.py --sostojanie …/livecopy --repo …/mainclone --subject 154 --phase spawn # rc=0
```

Стабы действительно исполнены, а не объявлены прозой. Сырые строки `--stabs` (последняя — дословный итог):
```
STAB_CAUGHT five-identical: five-identical: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
STAB_CAUGHT arbitration-sixth: arbitration-sixth: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
STAB_CAUGHT renamed-object: renamed-object: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
STAB_CAUGHT aborted-counts: aborted-counts: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
STAB_CAUGHT five-plus-accept: five-plus-accept: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
STAB_CAUGHT freeze-side-effect: freeze-side-effect: declined freeze changed frozen tag or registry
STAB_CAUGHT unreadable-ledger: unreadable-ledger: expected SCHET_NEIZVESTEN, actual rc 2:
STAB_CAUGHT contradictory-ledger: contradictory-ledger: expected SCHET_RASHOZHDENIE, actual rc 0:
STAB_CAUGHT freeze-failopen: freeze-failopen: expected SCHET_NEIZVESTEN, actual rc 0:
STAB_CAUGHT no-repoid: no-repoid: expected rc 0, actual 1: ОТКАЗ: KAP_VYZOVOV_KRITIKA: предмет 001: 5/5 до спавна
STAB_CAUGHT no-subject: no-subject: expected rc 0, actual 1: ОТКАЗ: KAP_VYZOVOV_KRITIKA: предмет 001: 5/5 до спавна
STAB_CAUGHT all-judges: all-judges: expected rc 0, actual 1: ОТКАЗ: KAP_VYZOVOV_KRITIKA: предмет 001: 5/5 до спавна
STAB_CAUGHT spawn-no-rashozhdenie: spawn-no-rashozhdenie: expected SCHET_RASHOZHDENIE, actual rc 0:
STAB_CAUGHT freeze-arb-owner: freeze-arb-owner: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
STAB_CAUGHT freeze-second-counter: freeze-second-counter: expected rc 0, actual 1: … ОТКАЗ: SCHET154: отказ бюджета
STAB_CAUGHT novelty-ignored: novelty-ignored: expected rc 0, actual 1: … KAP_VYZOVOV_KRITIKA
STAB_CAUGHT novelty-all-old: novelty-all-old: expected KAP_VYZOVOV_KRITIKA, actual rc 1: применяется
STAB_CAUGHT novelty-reversed: novelty-reversed: expected rc 0, actual 1: … KAP_VYZOVOV_KRITIKA
STAB_CAUGHT object-compressed: object-compressed: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
SVJAZI=19 CAUGHT=19 LIVE=0
```
Многоточия в трёх строках выше сокращают **только** вложенный вывод freeze-писателя, не выход батареи; полные несокращённые выводы были получены терминалом в этом суде, это не заявление о дополнительных атаках.

## БЛОКИРУЕТ

**Б8. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:35, :49 (И-1: точная пара `(repoId,subjectId)`, кап у всех новых предметов; приёмка установленных scripts); fixtures/workshop_project/schet_vyzovov_154/probe.py:26, :353–362, :459, :545, :627.** Класс причины — конечный домен фиксирует только `SUBJECT=001`/`contracts/001-x.md`; новые клетки оси OBJECT и `--live` тоже все для 001. Посторонний subjectId=099 существует лишь как ЧУЖАЯ строка ledger, а не как судимый предмет. Это не повтор Б7: ось повтора OBJECT закрыта, но ось **активного номера** отсутствует.
ОБХОД: в установленной честной вставке в `scripts/zamok_predmeta.sh` обернул вызов бюджетной функции условием `if [ "$sv" = 001 ]; then …; fi`; в `scripts/freeze_contract.sh` аналогично `if [ "$NNN" = 001 ]; then …; fi` (одноразовый скрипт `/tmp/dev-harness-verify/Crit154c/subject_attack.py`, не правка модели/контракта). На 001 всё подлинно работает; другие новые предметы получают `b154=0` без проверки. Батарея не отличает эту реализацию от честной:
```
$ python3 /tmp/dev-harness-verify/Crit154c/subject_attack.py /tmp/dev-harness-verify/Crit154c/mut
scripts/zamok_predmeta.sh guarded only for subject 001
scripts/freeze_contract.sh guarded only for subject 001
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh
GREEN freeze-second-counter-catcher
CELLS=49 GREEN=49                                             # rc=0
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain
GREEN domain-object-vse-odinakovye-freeze-6
CELLS=206 GREEN=206                                           # rc=0
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --live
GREEN live-old-door-shestoj
GREEN live-old-freeze-klapan
GREEN live-old-freeze-kap
GREEN live-new-tag-door
GREEN live-new-tag-freeze
GREEN live-new-notag-door
GREEN live-no-granica-door
CELLS=7 GREEN=7                                               # rc=0
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --model
GREEN old-freeze-kap
CELLS=52 GREEN=52                                             # rc=0
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --stabs
STAB_CAUGHT object-compressed: object-compressed: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
SVJAZI=19 CAUGHT=19 LIVE=0                                 # rc=0
$ python3 /tmp/dev-harness-verify/Crit154c/cross_subject_repro.py /tmp/dev-harness-verify/Crit154c/mut
subject=152 committed=1 previousCriticSTART=5 spawnRC= 0 stderr=
criticSTART-after= 6
```
СОСТОЯНИЕ: отдельный toy git с закоммиченным `contracts/152-x.md` и корректной строкой КЛАСС РИСКА, рабочим START+yield, пятью critic START по `(repo-origin,152)`, pin OBJECT совпадает с tip ветки рабочего `wip/152/architect`; команда `--sudit` запускается на настоящем установленном `scripts/zamok_predmeta.sh`. Номер 152 реально выдан после границы: `git merge-base --is-ancestor id/CONTRACT/152 5ca237e4e` не предок. В мире toy отсутствующий тег означает «новый» по И-5, вход допустим. Замок создаёт шестую строку START; это платный допуск вне cap.
НАБЛЮДЕНИЕ: честная вставка, тот же сценарий после переустановки mk_impl:
```
$ python3 /tmp/dev-harness-verify/Arch154c/protocol.py /tmp/dev-harness-verify/Crit154c/mut none
installed model patch into /tmp/dev-harness-verify/Crit154c/mut/scripts
protocol ready: none
$ python3 /tmp/dev-harness-verify/Crit154c/cross_subject_repro.py /tmp/dev-harness-verify/Crit154c/mut
subject=152 committed=1 previousCriticSTART=5 spawnRC= 1 stderr= ОТКАЗ: KAP_VYZOVOV_KRITIKA: предмет 152: 5/5 до спавна
criticSTART-after= 5
```
ОБЯЗАТЕЛЬСТВО: И-1 :35 и `roles/critic.md` §Счёт (любой новый предмет, все платные вызовы), предмет :4 и ЗАЩИЩАЕТ :188 («для новых предметов, на двери и при freeze»). ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка установленной реализации проверяет независимость порога от активного номера (и ключа репозитория), то есть наряду с 001 ещё доступный иной номер в обеих фазах; фикстурная условная реализация `if subject == 001` даёт RED собственной клеткой, честная — зелёная. Способ выбора номеров/миров за автором, не требуется отдельный конкретный алгоритм.

## Закрытие предыдущего суда и самоописание

- Б1: `W`/`--domain` на безреализационном OBJECT rc 1, на честной вставке rc 0 только при 49/49 и 206/206. Б2: потребители названы в :13, миграция и зоны в :50, :57–:76; 084 **нельзя** считать «без правки», сам замер 59/59→53/59 это подтвердил. Будущий rc=0 после миграции — обязательство implementer, а не замер этого суда. Б3: модель/домен и 19 стабов исполняют шесть именованных прежних ветвей. Б4: 148 на копии ledger даёт `SCHET_NEIZVESTEN` на обеих фазах без засева. Б5: 001 старый (rc 3), 154 новый (rc 0); старая §6в на live-old-* зелёная.
- Б6: `W --live` 3/7 без установки, 7/7 на вставке; мутант «тег значит старый» реально проверен на `mut` → rc 1 `CELLS=7 GREEN=4`, RED `live-new-tag-door`, `live-new-tag-freeze`, `live-no-granica-door`; мутант «обратный порядок merge-base» → rc 1 `CELLS=7 GREEN=4`, RED три `live-old-*` (ложный отказ законному старому предмету). Б7: `object-compressed` на вставке в `--domain` → rc 1 `CELLS=206 GREEN=201`, RED `domain-object-posle-aborted-{spawn-5,freeze-6}` и `domain-object-vse-odinakovye-{spawn-5,spawn-6,freeze-6}`; после возврата модели снова 206/206. Оракул `count` не зависит от OBJECT.
- С1: :13/:50 078 теперь 1 красная, 22 зелёных, 31 пропущено, 55 строк «КРАСНОЕ 078:», 22 «ЗЕЛЁНАЯ» (измерено). С2: :50 084 теперь явно правится, 59/0→59/6 измерено. С3: probe.py:434–448 после успешного freeze сравнивает тег и реестр со снимками до. С4: `freeze-failopen` назначает st154 до условия, `--stabs` ловит rc 0 на `freeze-no-state` вместо прежнего unbound. С5: источник 22=19+2+1, пересчёт `DOMAIN` подтверждён. С6: `oracle` теперь учитывает n/фазу/источник/историю/новизну/исходы старого предмета. С7–С8: 5ca237e4e не в main, вишня 451626c74 не эквивалент — сравнением всех доступных 163 `id/CONTRACT/*` тегов несовпадение **ровно 138** (граничный критерий сохранён); снимок pack проверен `git verify-pack -v` → два commit-объекта 5ca237e4e и 71839ea96. С9: `budget.py:119–124` сообщает только `doZhurnala >= 1`, не мнимую сверку числа файлов. С10: :27 и комментарий к OLD_CASES больше не утверждают физическую недостижимость границы; `--live` переносит её снимком. Старые адреса Crit154b `probe.py:376/:379` после правки уже не адреса вызова оракула/субъекта: `oracle` начинается :367, вычисление `expected` :427, вызов gate/freeze :429–434. Это изменение адресов исходного вердикта, а не ошибка нового текста контракта.

**САМООПИСАНИЕ contracts/154-schet-vyzovov-kritika.md:27** — счётное утверждение «по всем 162 тегам `id/CONTRACT/*`» → на OBJECT в клоне теперь **163 тега** (`python3` + `git tag -l id/CONTRACT/*`), один дополнительный номер добавился в основной истории после замера автора. Классификация 138 остаётся единственным несовпадением. Полный перечень расхождений чисел/адресов самого текущего контракта: **это единственное** по проверенным живым источникам; 49/52/206/210, 19/19, 7/7, 136+8+22+12+16+12+4, 19+2+1, 66/3, 59/6, 55/22, две commit-записи, ЗОНА 3 и ПЕРЕСЕЧЕНИЕ implementer 19 соответствуют. Историческое «9908 проверок зон» содержится в отчёте прежнего суда/автора, **не в контракте**: нынешний запуск дал 10018 при 148 замороженных контрактах (дрейф 110 проверок, коммитов в диапазонах сейчас 42091). Не маскировать это под второй дефект текста. Самоописание не является единственным основанием FAIL, поэтому правило форка консультанту по единственному самоописанию здесь не применяется.

**СОВЕТ contracts/154-schet-vyzovov-kritika.md:40, :196–:198** — владелец должен явно выбрать границу для засева: уполномоченный оркестратор может вписать `doZhurnala=1` при ≥4 до-журнальных verdict предмета 148; модель считает START+1, хотя реальных платных вызовов больше. Проверка числа старых файлов теперь прямо объявлена вне границы, это не новый блок внутри неё и не «ручная порча журнала». До accept следующего кандидата передать владельцу решение о расширении границы; этот FAIL имеет самостоятельное Б8. Отдельно проектный `workflowPaths.verdicts` исключён явно :198 — ранее Н2, решение о покрытии проектного счёта за владельцем.

**СОВЕТ contracts/154-schet-vyzovov-kritika.md:57, :73–:76** — frozen 084/1 ЗОНА architect содержит отдельные файлы `fixtures/plan_084/*`; 154 даёт ЗОНА implementer `fixtures/plan_084/`, но не ПЕРЕСЕЧЕНИЕ с 084. Грамматика 043 сравнивает пути буквально, precision rc 0, check_zones rc 0; формального механического отказа нет, можно назвать пересечение для ясности. С frozen 008/2 аналогично каталог `fixtures/check_check_contract_ready/` и отдельный `_doc027.py` в 154; 027 уже назван. Не подменять совет блоком.

## Не проверено

Полный перенос потребителей после работы implementer (его ещё нет), весь `fixtures/freeze_contract/`, нативный станционный путь `spawn-guard.ts → task`, Android и нативные сборки. На одноразовом toy действительный `zamok_predmeta.sh --sudit` проверен; livecopy использована только для read-only вызовов эталона бюджета. `W --domain-model` на атаке Б8 специально повторно не гонялся: режим `domain-model` использует копию baseline+MODEL, а атака меняет только установленные scripts; его 210/210 замерены на исходном OBJECT. СУД-модель-факт указана по данному запуску; трассировку факта/независимости оркестратор обязан сверить до материализации вердикта на main.
