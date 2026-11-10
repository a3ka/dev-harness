FAIL
OBJECT=1b1370d16015005ce23278c03035233fcfbe2ad6
СУД: repo=dev-harness; предмет=187; фаза=контракт (187а: двери и скрипты после разреза 187/188); роль=critic; вызов=2/2; модель-план=zai/glm-5.3; сессия=Crit187v2; модель-факт=openai-codex/gpt-5.6-terra; SHA=1b1370d16015005ce23278c03035233fcfbe2ad6; предыдущий=verdicts/critic/contracts-187-v1-krug1-fail.md; исключение=нет

# Вердикт критика — контракт 187а, исправительный вызов 2/2

## Граница, счёт и прежняя причина

Объект подтверждён в отдельном SSH-клоне: `git fetch origin wip/187/architect` и `git rev-parse FETCH_HEAD` дали `1b1370d16015005ce23278c03035233fcfbe2ad6`. На актуальном `origin/main` есть законная запись суда 2/2 с тем же SHA; её предыдущий вердикт — `verdicts/critic/contracts-187-v1-krug1-fail.md`.

Предыдущий блок не повторён. Владелец разрезал предмет: контракт на :5, :10 и :15 ограничивает 187а механическими дверями, а авторство строки задания и ролевой поток находок прямо относит к 188. Поэтому отсутствие role-каналов implementer/orchestrator более не является обязательством 187а и не оценивается этим вердиктом.

Набор артефактов полон: предмет, rc-приёмка, модель угроз, класс риска и шесть `ЗОНА`-строк закоммичены. Обычный класс риска соответствует предмету: изменяются process-двери, не права/роли БД, авторизация, деньги, ПД/health или юридически значимые действия. Форма модели угроз прошла. Из 65 строк `ПЕРЕСЕЧЕНИЕ` три — собственные новые пути architect, остальные 62 — пересечения с frozen; выборочно сверены живые блобы `frozen/contracts/170/1`, `083/1`, `114/1` и `996/2`: они действительно держат соответственно `scripts/make_task.sh`, CI registry/workflow и process-двери. `check_precision_gate` также прошёл на полном union frozen-зон.

## Блокирующая находка

БЛОКИРУЕТ contracts/187-arhitektura-v-processe.md:38,127-129 — обязательная CI-проводка красной батареи 187 не имеет механизма, который отличает её отсутствие от честного подключения; вместо требуемого guard батареи в `ПРОВОДКА` объявлен другой файл `scripts/check_architecture_contract.sh`.
ОБЯЗАТЕЛЬСТВО: contracts/187-arhitektura-v-processe.md:38 требует, чтобы CI вызывал именно `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`; задание суда отдельно закрепляет guard `red_architecture_process_187.sh` и bash-вызов, не Python-пробу.
КЛАСС ПРИЧИНЫ: критерий проводки проверяет иной механизм и потому ложно достаточен для обязательного CI-вызова батареи.
СОСТОЯНИЕ: после реализации все четыре двери работают; CI/`registry/ci-steps.tsv` содержит прямой вызов `scripts/check_architecture_contract.sh`, но шаг `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .` отсутствует (либо заменён запуском без `--repo .`). Это достижимо штатной операцией подключения CI-шага, которую выполняет orchestrator в своей зоне :60.
НАБЛЮДЕНИЕ: на :127-129 единственный guard — `scripts/check_architecture_contract.sh`. `scripts/check_provodka.sh:369-458,577-595` проверяет существование и подключение только имени объявленного guard; он не читает строку приёмки :38 и не проверяет точную команду батареи. `workflow_probe.py:225-242` в режиме `--repo` запускает двери непосредственно в toy-repo и не читает CI workflow/registry. Следовательно, описанное удаление/замена уже объявленной предметной операции — CI-вызова батареи из :38 — оставляет зелёными `red_architecture_process_187.sh --repo .` (двери вызваны самим probe) и `check_provodka` (подключён объявленный иной guard).
ОБХОД: `ci-step-omitted`: сохранить прямой CI-вызов `bash scripts/check_architecture_contract.sh --repo . …`, но удалить из registry/workflow `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`. Источник входа — поддерживаемый CI/registry шаг; источник ошибочного механизма — замена требуемой на :38 операции на уже объявленный на :128 guard. Наблюдаемое нарушение — CI больше не исполняет 25-клеточную батарею на реальных дверях, хотя все названные сейчас критерии могут быть зелёными.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: до freeze существует rc-гейт, который на реальном CI-носителе принимает только точный bash-вызов батареи с `--repo .` и отличает его отсутствие, Python/модельный запуск и вызов без `--repo .`; прямой вызов `check_architecture_contract.sh` проверяется отдельно и не может заменить батарею.

## Выполненные прогоны

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
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

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
CELLS=25 STABS=0 FAILURES=0
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
CELLS=25 STABS=23 FAILURES=0
[rc=0]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .
RED task-valid: rc=0 expected=0 output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED task-line-missing: rc=0 expected=1 reason=ARCH_LINE_MISSING output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED task-line-blank: rc=0 expected=1 reason=ARCH_LINE_MISSING output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED task-l3: rc=0 expected=1 reason=ARCH_OWNER output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED task-unmapped: rc=0 expected=1 reason=PATH_WITHOUT_COMPONENT output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED brief-lock: rc=0 expected=0 reason=PINNED_BRIEF_187 output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED brief-no-local-copy: rc=1 expected=0 reason=PINNED_BRIEF_187 output='ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/ в проекте: /tmp/workflow-187-ogdi6u0t/brief-no-local-copy/architecture\n'
RED brief-with-rules: rc=0 expected=0 reason=RULES_FROM_PIN_187 output='=== make_task contract=777 role=architect kind=task ===\n=== TRACE ===\nTRACE: role=architect model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --with-rules --component api.identity\n\nWRONG_LOCAL_BRI'
RED brief-no-rules: rc=0 expected=0 reason=PINNED_BRIEF_187 output='=== make_task contract=777 role=implementer kind=task ===\n=== TRACE ===\nTRACE: role=implementer model=zai/glm-5.3 fallback=allowed\n=== MAP ===\nMAP: STRUCTURE.md :: project structure\n=== RULES ===\n=== REUSE ===\n=== ARCHITECTURE BRIEF ===\nCOMPONENT: api.identity\n\n> brief\n> node cli.js brief --compact --component api.identity\n\nWRONG_LOCAL_BRIEF_187\n=='
GREEN freeze-valid: rc=0 expected=0
RED freeze-no-line: rc=0 expected=1 reason=ARCH_LINE_MISSING output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → 9e5583629186a311428173803d95f490e0d92b50\n  ok   реестр записан: 777 → 9e55836'
RED freeze-foreign: rc=0 expected=1 reason=ARCH_ZONE output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → 619f292906a065a184ebdb13cf595fd315f018ca\n  ok   реестр записан: 777 → 619f292'
RED freeze-unmapped: rc=0 expected=1 reason=PATH_WITHOUT_COMPONENT output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → 66ed35efd07ad149cd4d8d3bade9c1a627eca323\n  ok   реестр записан: 777 → 66ed35e'
RED freeze-draft: rc=0 expected=1 reason=ARCH_DRAFT output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → ef7c96fb538a2bf92a1139f99c19e740b892c491\n  ok   реестр записан: 777 → ef7c96f'
GREEN check-valid: rc=0 expected=0
RED check-failure: rc=0 expected=1 reason=ARCH_CHECK output='КРИТИК: дверь зелёная\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n'
RED check-not-evaluated: rc=0 expected=1 reason=ARCH_NOT_EVALUATED output='КРИТИК: дверь зелёная\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n'
GREEN done-valid: rc=0 expected=0
RED done-review-missing: rc=0 expected=1 reason=ARCH_REVIEW output=''
RED done-ci-missing: rc=0 expected=1 reason=ARCH_CI output=''
RED done-ci-other-sha: rc=0 expected=1 reason=ARCH_CI output=''
RED done-ci-red: rc=0 expected=1 reason=ARCH_CI output=''
RED done-ci-skipped: rc=0 expected=1 reason=ARCH_CI output=''
GREEN legacy-mob: rc=0 expected=0
GREEN legacy-harness: rc=0 expected=0
CELLS=25 STABS=0 FAILURES=20
[rc=1; ожидаемо до реализации]

$ bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md
проводка: guard-файл не существует: scripts/check_architecture_contract.sh
[rc=1; ожидаемо до реализации]
```

`--stabs` поймал все 23 объявленных стаба, но он не содержит `ci-step-omitted`; это и есть наблюдаемая непокрытая мутация выше. До реализации живой `--repo .` ожидаемо красен 20 клетками, поэтому этот красный не является отдельной находкой.

## Совместимость с frozen 170

```text
$ bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model
170 required ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 legacy ok rc=0 stderr=''
170 document ok rc=0 stderr=''
170 brief_kind ok rc=0 stderr=''
170 architect_rules ok rc=0 stderr=''
170 critic_rules ok rc=0 stderr=''
170 arbiter_rules ok rc=0 stderr=''
170 implementer_plain ok rc=0 stderr=''
170 adversary_plain ok rc=0 stderr=''
170 reviewer_plain ok rc=0 stderr=''
170 multi_component ok rc=0 stderr=''
170 wrong_project ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id'
170 architecture_missing ok rc=1 stderr='ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/'
170 brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events'
170 implementer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events'
170 adversary_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events'
170 reviewer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events'
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42688 > 40000'
170 class_dot ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_parens ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_semicolon ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_risk_tail ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_upper_c ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 second_malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id' npm_calls=0
[rc=0]

$ bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo .
170 required ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 legacy ok rc=0 stderr=''
170 document ok rc=0 stderr=''
170 brief_kind ok rc=0 stderr=''
170 architect_rules ok rc=0 stderr=''
170 critic_rules ok rc=0 stderr=''
170 arbiter_rules ok rc=0 stderr=''
170 implementer_plain ok rc=0 stderr=''
170 adversary_plain ok rc=0 stderr=''
170 reviewer_plain ok rc=0 stderr=''
170 multi_component ok rc=0 stderr=''
170 wrong_project ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../escape'
170 architecture_missing ok rc=1 stderr='ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/ в проекте: /tmp/dev-harness-verify/context-pack-095-arch-170-432058-10451/repo/architecture'
170 brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 implementer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 adversary_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 reviewer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42712 > 40000'
170 class_dot ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_parens ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_semicolon ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_risk_tail ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_upper_c ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 second_malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x' npm_calls=0
[rc=0]
```

170 remains green before the separately sanctioned v+1. The contract names the lock-vs-local-architecture conflict and requires that v+1 before done, as required by the owner; that dependency is not this freeze blocker.
