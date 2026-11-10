FAIL
OBJECT=083d2487e7739690e0094cc938eabeb705247db8
СУД: repo=dev-harness; предмет=187; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit187v1; модель-факт=openai-codex/gpt-5.6-terra (разрешённый autoFallback @gpt-terra); SHA=083d2487e7739690e0094cc938eabeb705247db8; предыдущий=нет; исключение=нет.

# Вердикт критика — контракт 187 «В4+В5 — архитектура в процессе станции», полный вызов 1

## Предмет, независимость и полнота набора

Объект подтверждён в отдельном одноразовом SSH-клоне: `git rev-parse HEAD` дал `083d2487e7739690e0094cc938eabeb705247db8` (rc 0), ровно OBJECT задания. Автор объекта — `architect <architect@dev-harness.local>`; собственную работу судья не судит. План модели критика — `zai/glm-5.3`, фактическая модель этой сессии — `openai-codex/gpt-5.6-terra`, разрешённый `autoFallback` tier `apex-sol` (`config/agent_models.json:59-63`).

Набор не неполон: закоммичены предмет, rc-критерии, модель угроз, класс риска и шесть `ЗОНА`-строк. Scoped-проверка вместо запрещённого заданием полного `check_zones.sh` подтвердила, что дельта автора содержит только его контракт и новую семью фикстур; `check_precision_gate.sh` вернул rc 0 и тем самым проверил каждую пару новой зоны с union чужих frozen-зон. Контракт верно оставляет изменение `STRUCTURE.md` вне 187: для снятия обязательства 170 потребуется отдельно санкционированный v+1 170 (`contracts/187-arhitektura-v-processe.md:12`).

```text
$ git diff --name-status 083d2487e7739690e0094cc938eabeb705247db8^ 083d2487e7739690e0094cc938eabeb705247db8
M	contracts/187-arhitektura-v-processe.md
A	fixtures/workshop_project/architecture_process_187/.probe-only
A	fixtures/workshop_project/architecture_process_187/probe.py
A	fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh
[rc=0]
```

## Блокирующие находки

БЛОКИРУЕТ contracts/187-arhitektura-v-processe.md:27,57,168-174 — обязательный канал подачи архитектурных расхождений и вызова хранителя не раздан и не проведён. Единственная строка о поведении ролей на :27 называет только architect/critic/adversary/reviewer; :57 не даёт implementer и orchestrator файлов `roles/implementer.md`/`roles/orchestrator.md`, а ПРОВОДКА на :168-174 перечисляет те же четыре роли. Более того, все четыре объявленных `role=`-строки не содержат обязательной quoted нормы, поэтому после подключения guard они не проходят грамматику `check_provodka.sh`.
ОБЯЗАТЕЛЬСТВО: слово владельца/консультанта 2026-11-10 ~19:45 в задании 187 требует провести в roles/implementer.md, roles/critic.md, roles/adversary.md, roles/reviewer.md и roles/architect.md норму: увидев расхождение с архитектурой, агент создаёт файл в `governance/findings/` с полями «модуль, что увидел, что в модели, предлагаемая правка, уровень, автор/статус», не обходит расхождение кодом и не заглушает его. В `roles/orchestrator.md` обязательна норма вызвать хранителя 186 после `done` последнего предмета Э-этапа и при блокирующей находке. Обе нормы должны идти role-каналом ПРОВОДКИ.
КЛАСС ПРИЧИНЫ: обязательное поведенческое решение оставлено без исполнителей, зон и проверяемого канала нормы.
СОСТОЯНИЕ: implementer либо один из судей обнаруживает в поддерживаемой реализации код/модельное расхождение; либо `done` завершает последний предмет Э-этапа, либо появляется блокирующая находка. Все три ситуации — прямые события процесса, который вводит контракт.
НАБЛЮДЕНИЕ: поиск по шести текущим role-файлам не нашёл `governance/findings`, правила «не обходить»/«не заглушать» или вызов хранителя. В контракте нет ни одного `role=roles/implementer.md` или `role=roles/orchestrator.md`; :170-173 содержат голые пути без `«норма-строка»`, хотя `scripts/check_provodka.sh:603-651` требует цитату и её побайтовое наличие в role-файле. Текущий живой прогон остановился раньше на ожидаемо ещё не подключённом красном guard (сырой вывод ниже), поэтому не может легализовать отсутствующие следующие каналы.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: контракт раздаёт implementer-у зону обоих недостающих role-файлов и проводит шесть валидных `role=`-каналов с literal-нормами; пять норм обязывают создать полную находку и не обходить/не заглушать расхождение, норма orchestrator-а вызывает хранителя 186 в обоих названных событиях. После реализации все шесть norm-строк существуют в целевых ролях и `bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md` возвращает rc 0.

## Выполненные прогоны

```text
$ bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/187-arhitektura-v-processe.md
OK
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md
проводка: guard не подключён: fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh не вызывается в .githooks/ или .github/workflows/
[rc=1; ожидаемо до реализации]

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 167 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model
GREEN valid: rc=0 expected=0
GREEN missing: rc=1 expected=1 reason=ARCH_DECLARATION
GREEN blank: rc=1 expected=1 reason=ARCH_DECLARATION
GREEN foreign-zone: rc=1 expected=1 reason=ARCH_ZONE
GREEN draft: rc=1 expected=1 reason=ARCH_DRAFT
GREEN check-good: rc=0 expected=0
GREEN check-red: rc=1 expected=1 reason=ARCH_CHECK
GREEN review-good: rc=0 expected=0
GREEN review-missing: rc=1 expected=1 reason=ARCH_REVIEW
GREEN mobile: rc=0 expected=0
GREEN harness: rc=0 expected=0
CELLS=11 GREEN=11
[rc=0]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs
GREEN valid: rc=0 expected=0
GREEN missing: rc=1 expected=1 reason=ARCH_DECLARATION
GREEN blank: rc=1 expected=1 reason=ARCH_DECLARATION
GREEN foreign-zone: rc=1 expected=1 reason=ARCH_ZONE
GREEN draft: rc=1 expected=1 reason=ARCH_DRAFT
GREEN check-good: rc=0 expected=0
GREEN check-red: rc=1 expected=1 reason=ARCH_CHECK
GREEN review-good: rc=0 expected=0
GREEN review-missing: rc=1 expected=1 reason=ARCH_REVIEW
GREEN mobile: rc=0 expected=0
GREEN harness: rc=0 expected=0
STAB missing-line caught @ missing
STAB placeholder-line caught @ blank
STAB foreign-zone caught @ foreign-zone
STAB draft-operation caught @ draft
STAB check-not-called caught @ check-red
STAB check-rc-ignored caught @ check-red
STAB reviewer-absent caught @ review-missing
STAB mobile-required caught @ mobile
STAB harness-required caught @ harness
STABS=9 CAUGHT=9
[rc=0]

$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .
GREEN valid: rc=0 expected=0
RED missing: rc=0 expected=1 reason=ARCH_DECLARATION output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → 54a2c0f59f37961ab2987148a7bbfc2ab4f36da3\n  ok   реестр записан: 777 → 54a2c0f59f37961ab2987148a7bbfc2ab4f36da3\n'
RED blank: rc=0 expected=1 reason=ARCH_DECLARATION output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → cdd3f78e1535ac381ccb4520a098fcbc4eb86d8b\n  ok   реестр записан: 777 → cdd3f78e1535ac381ccb4520a098fcbc4eb86d8b\n'
RED foreign-zone: rc=0 expected=1 reason=ARCH_ZONE output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → 4e456a2c3ed2e3cd0997c1a657e5fe910dbbaacc\n  ok   реестр записан: 777 → 4e456a2c3ed2e3cd0997c1a657e5fe910dbbaacc\n'
RED draft: rc=0 expected=1 reason=ARCH_DRAFT output='v1\n  ok   план не заведён: проверка «вне плана» не применяется\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n  ok   заморожено: .harness/contracts/777-work.md → frozen/contracts/777/1 («toy reason»)\n  ok   реестр закоммичен: 777 → 804f6810dbf14fa0f16eb6d50a6ff45bf4745ff4\n  ok   реестр записан: 777 → 804f6810dbf14fa0f16eb6d50a6ff45bf4745ff4\n'
GREEN check-good: rc=0 expected=0
RED check-red: rc=0 expected=1 reason=ARCH_CHECK output='КРИТИК: дверь зелёная\n  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0\n'
GREEN review-good: rc=0 expected=0
RED review-missing: rc=0 expected=1 reason=ARCH_REVIEW output=''
GREEN mobile: rc=0 expected=0
GREEN harness: rc=0 expected=0
CELLS=11 GREEN=0
[rc=1; ожидаемо до реализации]

$ bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --all
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
170 architecture_missing ok rc=1 stderr='ОТКАЗ: ARCHITECTURE_NET: нет каталога architecture/ в проекте: /tmp/dev-harness-verify/context-pack-095-arch-170-1338848-28227/repo/architecture'
170 brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 implementer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 adversary_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 reviewer_brief_failure ok rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events (npm rc=17): npm notice: brief command failed'
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42717 > 40000'
170 class_dot ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_parens ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_semicolon ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_risk_tail ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 class_upper_c ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)'
170 second_malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id: ../x' npm_calls=0
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
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42693 > 40000'
170 class_dot ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_parens ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_semicolon ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_risk_tail ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_upper_c ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 second_malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id' npm_calls=0
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
170 brief_over_budget ok rc=1 stderr='ОТКАЗ: режь задачу: 42693 > 40000'
170 class_dot ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_parens ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_semicolon ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_risk_tail ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 class_upper_c ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component'
170 second_malformed_id ok rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id' npm_calls=0
170 required KRASNO rc=0 stderr=''
170 STAB requirement_removed caught @ required
170 architect_rules KRASNO rc=0 stderr=''
170 STAB rules_omitted caught @ architect_rules
170 implementer_plain KRASNO rc=0 stderr=''
170 STAB rules_leaked caught @ implementer_plain
170 multi_component KRASNO rc=0 stderr=''
170 STAB only_first_id caught @ multi_component
170 multi_component KRASNO rc=0 stderr=''
170 STAB fixed_id caught @ multi_component
170 architect_rules KRASNO rc=0 stderr=''
170 STAB map_removed caught @ architect_rules
170 architect_rules KRASNO rc=0 stderr=''
170 STAB rules_removed caught @ architect_rules
170 wrong_project KRASNO rc=0 stderr=''
170 STAB backend_only caught @ wrong_project
170 architecture_missing KRASNO rc=0 stderr=''
170 STAB architecture_guard_removed caught @ architecture_missing
170 brief_failure KRASNO rc=0 stderr=''
170 STAB npm_failure_ignored caught @ brief_failure
170 implementer_brief_failure KRASNO rc=0 stderr=''
170 STAB plain_npm_failure_ignored caught @ implementer_brief_failure
170 class_dot KRASNO rc=0 stderr=''
170 STAB exact_class_line caught @ class_dot
170 class_upper_c KRASNO rc=0 stderr=''
170 STAB locale_only_case caught @ class_upper_c
170 second_malformed_id KRASNO rc=1 stderr='ОТКАЗ: ARCH_COMPONENT_ID: неконформный id' npm_calls=1
170 STAB validate_during_npm caught @ second_malformed_id
170 brief_over_budget KRASNO rc=0 stderr=''
170 STAB brief_outside_budget caught @ brief_over_budget
[rc=0]
```

Вердикт: FAIL — одна блокирующая причина: обязательный поток «агентская находка → хранитель» отсутствует в тексте, зонах и валидной ПРОВОДКЕ. Зелёные pre_critic, precision, модель угроз, модельная батарея 187, девять стабов и регресс 170 не заменяют отсутствующую норму ролей; красные `check_provodka` и `--repo .` соответствуют стадии до реализации.
