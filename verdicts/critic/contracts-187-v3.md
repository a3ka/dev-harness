FAIL

OBJECT=461b8757bbbb28f4b326e7dd10e17ecacb74c0b1
СУД: repo=dev-harness; предмет=187; фаза=контракт v3, узкое закрытие К-10 и зависимый регресс; роль=critic; вызов=один дополнительный 1/1 по слову владельца 2026-11-18 ~18:10 UTC, батч №3 №7, прежний счёт сохраняется; модель-план=config/agent_models.json (critic, apex-sol); сессия=Crit187V5; модель-факт=openai-codex/gpt-6.1-terra (models_actual --bind: allowed); SHA=461b8757bbbb28f4b326e7dd10e17ecacb74c0b1; предыдущий=Crit187V4 FAIL, archive/187/crit187v4-verdict; исключение=слово владельца на один узкий вызов.

## Блок

БЛОКИРУЕТ contracts/187-arhitektura-v-processe.md:33,51; fixtures/workshop_project/architecture_process_187/workflow_probe.py:1046,1328 — проверка подстроки не отличает входной pin от другого значения с тем же началом.
ОБЯЗАТЕЛЬСТВО: отказ по неконформному pin содержит диагностику «закреплённый pin не полный 40-hex SHA: <pin>» с конкретным входным значением; приёмка различает честную и подменённую диагностику.
СОСТОЯНИЕ: явно заявленные и присутствующие в CASES входы `HEAD`, имя ветки, сокращённый SHA и `HEAD` без флага. Исходная операция в `verdict` возвращает `PIN_NONCONFORMING_DIAG.format(pin=pin)`. В памяти процесса заменён результат этой операции добавлением `-wrong` к диагностике; например, при lock `HEAD` выдаётся `ARCH_PIN: закреплённый pin не полный 40-hex SHA: HEAD-wrong` вместо сообщения о `HEAD`.
НАБЛЮДЕНИЕ: `required_pin_diagnostic not in output` принимает прежнее значение как префикс подменённого. Все четыре затронутые клетки и вся батарея зелёны, rc 0; привязанный стаб `pin-value-forged` проверяет лишь добавление префикса `wrong-` и не обнаруживает эту соседнюю подмену.
ОБХОД: диагностировать `HEAD-wrong` вместо входного `HEAD`, сохранив остальной отказ; `--model` сообщает `CELLS=61 STABS=0 FAILURES=0`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: различать полное значение входного pin в диагностике, включая границу его окончания, и неправильное значение, оставляя честную допустимую диагностику зелёной; свойство действует также на публичной двери.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-10

Арбитр: повторная причина К-10 — достаточно ли приёмка связывает диагностику с точным входным pin; назначить решение конечной границы, автоматический следующий вызов не назначается.

Связь поиска с дельтой: кандидат добавил проверку `required_pin_diagnostic in output` и стаб с префиксной подменой; проверена соседняя суффиксная подмена того же существующего возврата на заявленных входах. Это не новая область исследования.

Команда мутации (только память процесса, файлы не менялись):

```sh
python3 -c 'import sys; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as w; original=w.verdict; exec("def mutant(*a, **k):\n r,o=original(*a,**k)\n if a[3] == \"task\" and k.get(\"variation\", \u0022\u0022) in (\"pin-head\", \"pin-branch\", \"pin-short\", \"pin-head-noflag\") and r == 1 and \"закреплённый pin не полный\" in o: o += \"-wrong\"\n return r,o"); w.verdict=mutant; sys.argv=["workflow_probe.py","--model"]; sys.exit(w.main())'
```

Сырой вывод, rc 0:

```text
GREEN task-valid: rc=0 expected=0
GREEN task-line-missing: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN task-line-blank: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN task-l3: rc=1 expected=1 reason=ARCH_OWNER
GREEN task-unmapped: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN task-foreign: rc=1 expected=1 reason=ARCH_ZONE
GREEN task-locate-json-malformed: rc=1 expected=1 reason=ARCH_LOCATE_GRAMMAR
GREEN task-locate-status-missing: rc=1 expected=1 reason=ARCH_LOCATE_GRAMMAR
GREEN task-locate-status-unknown: rc=1 expected=1 reason=ARCH_LOCATE_GRAMMAR
GREEN brief-lock: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN brief-no-local-copy: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN brief-inline-line-missing: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN brief-document-no-local: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN brief-with-rules: rc=0 expected=0 reason=RULES_FROM_PIN_187
GREEN brief-no-rules: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN freeze-valid: rc=0 expected=0
GREEN freeze-no-line: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN freeze-foreign: rc=1 expected=1 reason=ARCH_ZONE
GREEN freeze-unmapped: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN freeze-draft: rc=1 expected=1 reason=ARCH_DRAFT
GREEN freeze-draft-marker: rc=1 expected=1 reason=ARCH_DRAFT
GREEN freeze-draft-schema: rc=1 expected=1 reason=ARCH_DRAFT
GREEN check-valid: rc=0 expected=0
GREEN check-failure: rc=1 expected=1 reason=ARCH_CHECK
GREEN check-not-evaluated: rc=1 expected=1 reason=ARCH_NOT_EVALUATED
GREEN check-digest-mismatch: rc=1 expected=1 reason=ARCH_CHECK
GREEN done-valid: rc=0 expected=0
GREEN done-review-missing: rc=1 expected=1 reason=ARCH_REVIEW
GREEN done-ci-missing: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-other-sha: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-red: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-skipped: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-head-ahead: rc=1 expected=1 reason=ARCH_CI
GREEN legacy-mob: rc=0 expected=0
GREEN legacy-harness: rc=0 expected=0
GREEN wiring-valid: rc=0 expected=0
GREEN wiring-omitted: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-no-repo: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-python: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-direct-missing: rc=1 expected=1 reason=CI_DIRECT_ARCH_187_MISSING
GREEN check-green-latency-unresolved: rc=0 expected=0
GREEN check-rc2-real-gate: rc=2 expected=2 reason=ARCH_NOT_EVALUATED
GREEN check-rc1-real-gate: rc=1 expected=1 reason=ARCH_CHECK
GREEN check-rc0-gate-lie: rc=2 expected=2 reason=ARCH_NOT_EVALUATED
GREEN zone-container-file: rc=0 expected=0
GREEN zone-container-escape: rc=1 expected=1 reason=ARCH_ZONE
GREEN path-unplaced-absent: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN zone-outside-runtime: rc=0 expected=0
GREEN zone-outside-false-refused: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN path-unresolved-zero-absent: rc=0 expected=0 reason=вне модели: scripts/ci-helper.sh
GREEN path-unresolved-zero-present: rc=0 expected=0 reason=вне модели: provenance.json
GREEN path-area-without-component: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN zone-outside-snapshot-failed: rc=2 expected=2 reason=ARCH_NOT_EVALUATED
GREEN zone-outside-snapshot-missing: rc=2 expected=2 reason=ARCH_NOT_EVALUATED
GREEN pin-symbolic-head: rc=1 expected=1 reason=ARCH_PIN
GREEN pin-symbolic-branch: rc=1 expected=1 reason=ARCH_PIN
GREEN pin-short-sha: rc=1 expected=1 reason=ARCH_PIN
GREEN pin-unresolvable-sha: rc=1 expected=1 reason=ARCH_PIN
GREEN pin-head-noflag: rc=1 expected=1 reason=ARCH_PIN
GREEN applicability-lock-no-dir: rc=1 expected=1 reason=ARCH_COMPONENT_NET
GREEN applicability-dir-no-lock: rc=1 expected=1 reason=ARCH_COMPONENT_NET
CELLS=61 STABS=0 FAILURES=0
```

## Зависимый регресс

Выполнено в `/tmp/dev-harness-verify/Crit187V5/repo` на OBJECT. Сырые заключительные строки батарей (полный вывод находится в трассе сессии):

```text
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model
CELLS=61 STABS=0 FAILURES=0
rc=0
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs
CELLS=61 STABS=71 FAILURES=0
rc=0
$ bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md
PROVODKA_RC=0
$ bash scripts/check_ceilings.sh .
  ok   персоны: 13 файл(ов), потолок 81920 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 182 черновик(ов) судится, замороженные — по тегам
потолки в порядке
CEILINGS_RC=0
$ bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))
THREAT_RC=0
```

Восемь новых стабов привязаны в коде `workflow_probe.py:337-344` и пойманы своими клетками в `--stabs`; Н-39 не требует прозы контракта. Путь первым токеном в строке коммита `9d0bb077`, причина непуста; `git diff c8241548..461b8757` не меняет текст контракта и ограничен батареей и сдаточным листом. `pre_critic` и сдаточный лист по заданию не повторялись.

## Карта классов

К-01: н/п — без изменений с вызова Crit187V4; двери по заданию не повторялись.
К-02: чисто — вход: слово владельца батч №3 №7 и дельта c8241548..461b8757.
К-03: н/п — без изменений с вызова Crit187V4.
К-04: чисто — вход: дельта только в fixtures/workshop_project/architecture_process_187/, зона architect.
К-05: н/п — текст контракта не изменён с вызова Crit187V4.
К-06: н/п — без изменений с вызова Crit187V4.
К-07: чисто — вход: workflow_probe.py:1314-1330, один предикат на модельном и живом пути.
К-08: чисто — `red_architecture_process_187.sh --stabs`, rc 0, 71 стаб.
К-09: н/п — без изменений с вызова Crit187V4; новые ветви входов не объявлены.
К-10: блок — подмена суффикса конкретного pin проходит проверку.
К-11: н/п — без изменений с вызова Crit187V4 в источнике lock.
К-12: н/п — без изменений с вызова Crit187V4 в грамматике pin.
К-13: н/п — секреты не затронуты.
К-14: чисто — `red_architecture_process_187.sh --model`, rc 0, честные pin-клетки зелёны.
К-15: чисто — `--model` CELLS=61, `--stabs` STABS=71, rc 0.
К-16: чисто — `bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md`, rc 0.
К-17: н/п — sourceCanon не объявлен для этого станционного предмета; без изменений с Crit187V4.
