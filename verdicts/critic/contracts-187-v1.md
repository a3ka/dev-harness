accept
OBJECT=b840c650ab20fcfdd63470f032205a6d1591f092
СУД: repo=dev-harness; предмет=187; фаза=контракт (187а после согласия автора с блоком вызова 2/2); роль=critic; вызов=3/2 (исправительный по санкции оркестратора №1); модель-план=zai/glm-5.3; сессия=Crit187v3; модель-факт=openai-codex/gpt-5.6-terra; SHA=b840c650ab20fcfdd63470f032205a6d1591f092; предыдущий=verdicts/critic/contracts-187-v1.md; исключение=санкция оркестратора №1 (§Остановка)

# Вердикт критика — контракт 187а, исправительный вызов 3/2

## Рамка, счёт и независимость

Проверен только разрешённый исправительный объём: закрытие единственного блока вызова 2/2 — обязательной CI-проводки батареи 187 — и последствия его семантической дельты. Новый поиск связан именно с этой дельтой: она добавляет `--wiring`, меняет guard в `ПРОВОДКА` и добавляет пять клеток/четыре стаба. Неизменённые поверхности повторно не исследовались.

Отдельный SSH-клон получен из `ssh://git@github.com/a3ka/dev-harness.git`; `git fetch origin wip/187/architect` и `git rev-parse FETCH_HEAD` дали `b840c650ab20fcfdd63470f032205a6d1591f092`, совпадающий с OBJECT. В `origin/main:HANDOFF.md:6-7` проверены одноразовая санкция оркестратора именно на вызов 3/2, этот SHA, предыдущий FAIL и письменное согласие `Arch187R4`.

Модель-план — `zai/glm-5.3`; фактическая модель судьи — `openai-codex/gpt-5.6-terra`, сессия `Crit187v3`. Это не собственная работа автора; назначение critic-tier и допустимый fallback сверены в `config/agent_models.json`.

## Закрытие блока

Предыдущий обход закрыт. В `contracts/187-arhitektura-v-processe.md:16,44,51,135-137` разделены два обязательства: `guard=fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh` — батарея, а `guard=scripts/check_architecture_contract.sh` — самостоятельная прямая дверь. До freeze названы три независимые rc-проверки: `--wiring`, `gen_ci_steps.sh --check` и `check_provodka.sh`.

`fixtures/workshop_project/architecture_process_187/ci_wiring.py:5-25` читает именно `ROOT/registry/ci-steps.tsv`, отбирает реальные `step`-строки и принимает только обе точные команды:

```text
bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .
bash scripts/check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md
```

Поэтому прежняя замена батареи прямой дверью, запуск без `--repo .` и запуск через `python3` больше не удовлетворяют критерию. `workflow_probe.py` добавляет пять живых клеток и четыре привязанных обманных стаба; исходные 25/23 сохранены добавлением, что подтверждают 30/27 в независимом прогоне.

## Выполненные гейты

```text
$ bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/187-arhitektura-v-processe.md
OK
[rc=0]

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 3 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ git diff --stat 1b1370d16..b840c650a
 contracts/187-arhitektura-v-processe.md            | 12 ++++++++++--
 .../architecture_process_187/ci_wiring.py          | 33 ++++++++++++++++++++
 .../red_architecture_process_187.sh                |  4 ++++
 .../architecture_process_187/workflow_probe.py     | 35 ++++++++++++++++++++--
 4 files changed, 79 insertions(+), 5 deletions(-)

$ git diff --check 1b1370d16..b840c650a
[rc=0]
```

## Батарея и стабы

```text
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model
GREEN task-valid: rc=0 expected=0
GREEN task-line-missing: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN task-line-blank: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN task-l3: rc=1 expected=1 reason=ARCH_OWNER
GREEN task-unmapped: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN brief-lock: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN brief-no-local-copy: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN brief-with-rules: rc=0 expected=0 reason=RULES_FROM_PIN_187
GREEN brief-no-rules: rc=0 expected=0 reason=PINNED_BRIEF_187
GREEN freeze-valid: rc=0 expected=0
GREEN freeze-no-line: rc=1 expected=1 reason=ARCH_LINE_MISSING
GREEN freeze-foreign: rc=1 expected=1 reason=ARCH_ZONE
GREEN freeze-unmapped: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
GREEN freeze-draft: rc=1 expected=1 reason=ARCH_DRAFT
GREEN check-valid: rc=0 expected=0
GREEN check-failure: rc=1 expected=1 reason=ARCH_CHECK
GREEN check-not-evaluated: rc=1 expected=1 reason=ARCH_NOT_EVALUATED
GREEN done-valid: rc=0 expected=0
GREEN done-review-missing: rc=1 expected=1 reason=ARCH_REVIEW
GREEN done-ci-missing: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-other-sha: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-red: rc=1 expected=1 reason=ARCH_CI
GREEN done-ci-skipped: rc=1 expected=1 reason=ARCH_CI
GREEN legacy-mob: rc=0 expected=0
GREEN legacy-harness: rc=0 expected=0
GREEN wiring-valid: rc=0 expected=0
GREEN wiring-omitted: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-no-repo: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-python: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-direct-missing: rc=1 expected=1 reason=CI_DIRECT_ARCH_187_MISSING
CELLS=30 STABS=0 FAILURES=0
[rc=0]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs
GREEN task-valid: rc=0 expected=0
STAB structure-dropped caught @ task-valid
STAB obsolete-doc-reintroduced caught @ task-valid
GREEN task-line-missing: rc=1 expected=1 reason=ARCH_LINE_MISSING
STAB task-no-line caught @ task-line-missing
GREEN task-line-blank: rc=1 expected=1 reason=ARCH_LINE_MISSING
STAB task-blank-accepted caught @ task-line-blank
GREEN task-l3: rc=1 expected=1 reason=ARCH_OWNER
STAB task-l3-auto caught @ task-l3
GREEN task-unmapped: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
STAB task-unmapped-path caught @ task-unmapped
GREEN brief-lock: rc=0 expected=0 reason=PINNED_BRIEF_187
STAB brief-from-head caught @ brief-lock
GREEN brief-no-local-copy: rc=0 expected=0 reason=PINNED_BRIEF_187
STAB brief-requires-local-copy caught @ brief-no-local-copy
GREEN brief-with-rules: rc=0 expected=0 reason=RULES_FROM_PIN_187
STAB brief-rules-omitted caught @ brief-with-rules
GREEN brief-no-rules: rc=0 expected=0 reason=PINNED_BRIEF_187
STAB brief-rules-leaked caught @ brief-no-rules
GREEN freeze-valid: rc=0 expected=0
GREEN freeze-no-line: rc=1 expected=1 reason=ARCH_LINE_MISSING
STAB freeze-line-ignored caught @ freeze-no-line
GREEN freeze-foreign: rc=1 expected=1 reason=ARCH_ZONE
STAB zone-foreign caught @ freeze-foreign
GREEN freeze-unmapped: rc=1 expected=1 reason=PATH_WITHOUT_COMPONENT
STAB zone-unmapped caught @ freeze-unmapped
GREEN freeze-draft: rc=1 expected=1 reason=ARCH_DRAFT
STAB draft-operation caught @ freeze-draft
GREEN check-valid: rc=0 expected=0
GREEN check-failure: rc=1 expected=1 reason=ARCH_CHECK
STAB check-not-called caught @ check-failure
GREEN check-not-evaluated: rc=1 expected=1 reason=ARCH_NOT_EVALUATED
STAB check-rc-ignored caught @ check-not-evaluated
GREEN done-valid: rc=0 expected=0
GREEN done-review-missing: rc=1 expected=1 reason=ARCH_REVIEW
STAB reviewer-line-ignored caught @ done-review-missing
GREEN done-ci-missing: rc=1 expected=1 reason=ARCH_CI
STAB ci-not-read caught @ done-ci-missing
GREEN done-ci-other-sha: rc=1 expected=1 reason=ARCH_CI
STAB ci-sha-ignored caught @ done-ci-other-sha
GREEN done-ci-red: rc=1 expected=1 reason=ARCH_CI
STAB ci-conclusion-ignored caught @ done-ci-red
GREEN done-ci-skipped: rc=1 expected=1 reason=ARCH_CI
STAB ci-skipped-green caught @ done-ci-skipped
GREEN legacy-mob: rc=0 expected=0
STAB mob-required caught @ legacy-mob
GREEN legacy-harness: rc=0 expected=0
STAB harness-required caught @ legacy-harness
GREEN wiring-valid: rc=0 expected=0
GREEN wiring-omitted: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
STAB ci-step-omitted caught @ wiring-omitted
GREEN wiring-no-repo: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
STAB ci-step-without-repo caught @ wiring-no-repo
GREEN wiring-python: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
STAB ci-step-python-instead caught @ wiring-python
GREEN wiring-direct-missing: rc=1 expected=1 reason=CI_DIRECT_ARCH_187_MISSING
STAB ci-direct-replaced-by-battery caught @ wiring-direct-missing
CELLS=30 STABS=27 FAILURES=0
[rc=0]
```

## Независимые мутации `--wiring`

В одноразовом клоне были созданы пять минимальных отдельных `registry/ci-steps.tsv`; после проверок они удалены. Сырые результаты реального `ci_wiring.py`:

```text
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring tmp/critic-187-wiring/honest
[rc=0]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring tmp/critic-187-wiring/omitted
CI_BATTERY_187_MISSING_OR_NOT_EXACT
[rc=1]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring tmp/critic-187-wiring/no-repo
CI_BATTERY_187_MISSING_OR_NOT_EXACT
[rc=1]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring tmp/critic-187-wiring/python
CI_BATTERY_187_MISSING_OR_NOT_EXACT
[rc=1]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring tmp/critic-187-wiring/direct
CI_DIRECT_ARCH_187_MISSING
[rc=1]
```

Отдельно удаление существующей предметной операции `if BATTERY not in commands` было временно заменено на `if False and BATTERY not in commands`, затем исходник восстановлен из OBJECT. Сырой относящийся к этой атаке вывод живой батареи:

```text
GREEN wiring-valid: rc=0 expected=0
RED wiring-omitted: rc=0 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT output=''
RED wiring-no-repo: rc=0 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT output=''
RED wiring-python: rc=0 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT output=''
GREEN wiring-direct-missing: rc=1 expected=1 reason=CI_DIRECT_ARCH_187_MISSING
CELLS=30 STABS=0 FAILURES=23
[rc=1; мутация поймана: три новые клетки добавились к 20 ожидаемо красным до реализации]
```

В неизменённом OBJECT живой `--repo .` ожидаемо красен до реализации публичных дверей, но все пять новых клеток зелёные:

```text
GREEN wiring-valid: rc=0 expected=0
GREEN wiring-omitted: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-no-repo: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-python: rc=1 expected=1 reason=CI_BATTERY_187_MISSING_OR_NOT_EXACT
GREEN wiring-direct-missing: rc=1 expected=1 reason=CI_DIRECT_ARCH_187_MISSING
CELLS=30 STABS=0 FAILURES=20
[rc=1; ожидаемо до реализации]
```

Для проверки носителя, а не имени, в копии кандидата временно добавлены обе точные `step`-строки, временный файл прямой двери и сгенерирован workflow. После этого:

```text
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring .
[rc=0]

$ bash scripts/gen_ci_steps.sh --check
[rc=0]

$ bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md
[rc=0]
```

Временные registry/workflow/stub/scratch-изменения затем удалены; `git diff --exit-code -- b840c650ab20fcfdd63470f032205a6d1591f092` вернул rc 0 до материализации этого вердикта.

Предыдущий класс закрыт, а дельта не создаёт доказанного нового нарушения обязательств. Заморозка разрешена.
