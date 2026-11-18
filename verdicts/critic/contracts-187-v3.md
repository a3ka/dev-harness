accept

OBJECT=c2bdf5a74e74cc0a91c0e486392a68af26dc288e
СУД: repo=dev-harness; предмет=187; фаза=контракт v3, узкое исполнение Arb187V1 и зависимый регресс; роль=critic; вызов=1/2 по отдельному счёту ADR, ровно один по санкции Cons187Sign; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit187V6; модель-факт=openai-codex/gpt-6.1-terra, allowed; SHA=c2bdf5a74e74cc0a91c0e486392a68af26dc288e; предыдущий=Crit187V5 FAIL + Arb187V1 resolved; исключение=санкция Cons187Sign.

## Основание и граница

Проверено исполнение решения Arb187V1 по К-10, а не весь контракт. По `workflow_probe.py:529-570,1433-1454,1475-1483` ожидание снимается из lock до вызова; один предикат применяется к модельному, стабовому и живому выводу. За неконформным pin принимается конец вывода либо LF, за неразрешимым — фиксированное продолжение с допустимым путём. Честные эквивалентные формы и соседи прежней суффиксной подмены проверены ниже; `--stabs` сохраняет прежние различители и ловит четыре новые адресные подмены. Привязки — в коде, не в прозе контракта (Н-39). `pin-unresolvable-sha` имеет отдельную форму и не является различающим входом воспроизведённой мутации.

Связь поиска с дельтой: проверены новый предикат границы и его вызовы, соседние окончания и честные формы, а также зависимые стабы. Иные поверхности без основания не пересуждались. Предсудебные двери и сдаточный лист по заданию не повторялись. Живую дверь не запускал; факт общего пути установлен чтением кода, а не выдаётся за самостоятельный live-прогон.

## Команды и наблюдения

Рабочий каталог `/tmp/dev-harness-verify/Crit187V6/repo`, исходный HEAD — OBJECT. `git fetch --tags origin` rc 0. Модель установлена из `/home/harness/dev-harness`:

```text
$ bash scripts/models_actual.sh --tsv --bind --session Crit187V6 | cut -f1-3
critic	openai-codex/gpt-6.1-terra	allowed
critic	openai-codex/gpt-6.1-terra	allowed
```

```text
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model
GREEN pin-diagnostic-boundary-selfcheck 9/9
... 61 GREEN клетка ...
CELLS=61 STABS=0 FAILURES=0
rc=0
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs
GREEN pin-diagnostic-boundary-selfcheck 9/9
... 61 GREEN клетка и 75 STAB caught ...
STAB pin-suffix-forged-head caught @ pin-symbolic-head
STAB pin-suffix-forged-branch caught @ pin-symbolic-branch
STAB pin-suffix-forged-short caught @ pin-short-sha
STAB pin-suffix-forged-noflag caught @ pin-head-noflag
CELLS=61 STABS=75 FAILURES=0
rc=0
```

Многоточие обозначает опущенный вывод; полный сырой вывод обеих команд сохранён в трассе сессии, не является дословной частью этого фрагмента. Прежние `pin-bare-reason`, `pin-diagnostic-swapped`, `pin-value-lost` и `pin-value-forged` также напечатаны как caught.

Дословная мутация Crit187V5, только в памяти процесса:

```sh
env PYTHONDONTWRITEBYTECODE=1 python3 -c 'import sys; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as w; original=w.verdict; exec("def mutant(*a, **k):\n r,o=original(*a,**k)\n if a[3] == \"task\" and k.get(\"variation\", \u0022\u0022) in (\"pin-head\", \"pin-branch\", \"pin-short\", \"pin-head-noflag\") and r == 1 and \"закреплённый pin не полный\" in o: o += \"-wrong\"\n return r,o"); w.verdict=mutant; sys.argv=["workflow_probe.py","--model"]; sys.exit(w.main())'
```

Сырой вывод (rc 1):

```text
GREEN pin-diagnostic-boundary-selfcheck 9/9
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
RED pin-symbolic-head: rc=1 expected=1 reason=ARCH_PIN output='ARCH_PIN: закреплённый pin не полный 40-hex SHA: HEAD-wrong'
RED pin-symbolic-branch: rc=1 expected=1 reason=ARCH_PIN output='ARCH_PIN: закреплённый pin не полный 40-hex SHA: main-wrong'
RED pin-short-sha: rc=1 expected=1 reason=ARCH_PIN output='ARCH_PIN: закреплённый pin не полный 40-hex SHA: bfadace9481a-wrong'
GREEN pin-unresolvable-sha: rc=1 expected=1 reason=ARCH_PIN
RED pin-head-noflag: rc=1 expected=1 reason=ARCH_PIN output='ARCH_PIN: закреплённый pin не полный 40-hex SHA: HEAD-wrong'
GREEN applicability-lock-no-dir: rc=1 expected=1 reason=ARCH_COMPONENT_NET
GREEN applicability-dir-no-lock: rc=1 expected=1 reason=ARCH_COMPONENT_NET
CELLS=61 STABS=0 FAILURES=4
```

Дополнительный адресный контроль предиката, не подмена живой двери:

```sh
env PYTHONDONTWRITEBYTECODE=1 python3 -c 'import sys; sys.path.insert(0,"fixtures/workshop_project/architecture_process_187"); import workflow_probe as w; e=w.pin_expectation("pin-head","HEAD"); d=w.ARCH_PIN_PREFIX+w.PIN_NONCONFORMING_DIAG.format(pin="HEAD"); cases=[("без LF",d,True),("с LF и префиксом","ОТКАЗ: "+d+"\n",True),("суффикс digit",d+"9",False),("суффикс текст",d+" extra",False),("суффикс slash",d+"/other",False)]; p="e"*40; u=w.pin_expectation("pin-unresolvable",p); t="ОТКАЗ: "+w.ARCH_PIN_PREFIX+w.PIN_UNRESOLVABLE_DIAG.format(pin=p); cases += [("путь клона",t+": /tmp/clone\n",True),("подмена неразрешимого",t.replace(p,p+"9")+": /tmp/clone\n",False)]; results=[(name,w.pin_diagnostic_matched(out,u if name in ("путь клона","подмена неразрешимого") else e),wanted) for name,out,wanted in cases]; [print(f"{n}: actual={v} expected={want}") for n,v,want in results]; sys.exit(any(v!=want for _,v,want in results))'
```

Сырой вывод, rc 0:

```text
без LF: actual=True expected=True
с LF и префиксом: actual=True expected=True
суффикс digit: actual=False expected=False
суффикс текст: actual=False expected=False
суффикс slash: actual=False expected=False
путь клона: actual=True expected=True
подмена неразрешимого: actual=False expected=False
```

## Карта классов

К-01: н/п — без изменений с Crit187V5; двери по заданию не повторялись.
К-02: чисто — вход: санкция Cons187Sign, решение Arb187V1 и дельта e9c70d2706..OBJECT.
К-03: н/п — без изменений с Crit187V5 в узкой дельте.
К-04: чисто — вход: дельта contracts/187-arhitektura-v-processe.md и fixtures/workshop_project/architecture_process_187/.
К-05: н/п — без изменений с Crit187V5, кроме числа стабов.
К-06: н/п — без изменений с Crit187V5 в отказах среды.
К-07: чисто — вход: workflow_probe.py:1433-1454,1475-1483, единый предикат модели, стабов и live.
К-08: чисто — `red_architecture_process_187.sh --stabs`, rc 0, 75 пойманных стабов.
К-09: н/п — без изменений с Crit187V5 в объявленной области входов.
К-10: чисто — вход: воспроизведённая мутация Crit187V5 rc 1, четыре красные клетки; ожидание из lock до вызова.
К-11: чисто — вход: workflow_probe.py:538-544,1433-1439, ожидание из входного lock.
К-12: н/п — без изменений с Crit187V5 в грамматике pin.
К-13: н/п — секреты не затронуты дельтой.
К-14: чисто — вход: адресные формы без LF, с LF и префиксом, с путём клона и соседние суффиксы; rc 0.
К-15: чисто — `--model` CELLS=61, `--stabs` STABS=75, оба rc 0; контракт изменяет число стабов на 75.
К-16: н/п — без изменений с Crit187V5 в границе риска.
К-17: н/п — без изменений с Crit187V5 в архитектурной модели.
