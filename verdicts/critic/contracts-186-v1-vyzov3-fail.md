FAIL
OBJECT=53978b2917397ab70077936bd8c7e03733c431ef
СУД: repo=dev-harness; предмет=186; фаза=контракт; роль=critic; вызов=3/2 (исправительный по санкции оркестратора); модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=zai/glm-5.3; SHA=53978b2917397ab70077936bd8c7e03733c431ef; предыдущий=verdicts/critic/contracts-186-v1-vyzov2-fail.md; исключение=санкция оркестратора

## Блокирующая находка

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:142-143 — оба guard-канала поля `ПРОВОДКА` передают объясняющий текст в значение `guard=`, поэтому живой `check_provodka.sh` ищет не заявленные скрипты, а путь с литеральными ` «…»`.
ОБЯЗАТЕЛЬСТВО: после реализации каждый канал `ПРОВОДКА` существует и подключён; по заданию исправительного вызова `check_provodka.sh` обязан стать зелёным на копии с реализованными заглушками.
СОСТОЯНИЕ: в отдельной копии были созданы именно `scripts/merge_architecture_pr.sh` и `scripts/check_architecture_pin.sh`, роль-файлы с дословными нормами двух role-каналов, а workflow с обоими literal basenames. Контракт и сам `check_provodka.sh` скопированы без изменения.
НАБЛЮДЕНИЕ: в обработчике guard-канала `scripts/check_provodka.sh:577-594` выполняется `guard="$rest"`, без извлечения текста в `«…»`. Поэтому команда ниже вернула rc=1 уже на первом существующем нормальном guard-файле:
```text
$ bash tmp/critic186_provodka_model/scripts/check_provodka.sh tmp/critic186_provodka_model contracts/186-hranitel-arhitektury.md
проводка: guard-файл не существует: scripts/merge_architecture_pr.sh «Дверь проверяет accept критика на head, иное семейство относительно Sol автора, CI head, baseline PASS, COMPLIOR-<NNN>, автор ≠ сливающий; L2/L3 без акта владельца отказывает; L1 сливает с --match-head-commit.»
[rc=1]
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: каждый guard-канал имеет синтаксис, из которого текущий валидатор однозначно получает путь реализуемого guard-файла и затем подтверждает его подключение; на модели с этими двумя файлами и подключением `check_provodka.sh` возвращает rc=0.

## Область исправительного вызова

Проверена дельта `f1f6157697d2425fd710fc4ce19a896ad62629c4..53978b2917397ab70077936bd8c7e03733c431ef`: post-merge pin-клетки, четыре их мутации, граница записи в продукт и последствия добавления pin-проводки. Прежние закрытые классы и ветви L1 повторно атакованы только через изменившуюся общую батарею. Новый блок — следствие добавленных строк guard-проводки; неизменённые поверхности заново не исследовались.

## Прогоны

```text
$ bash scripts/pre_critic.sh contracts/186-hranitel-arhitektury.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/186-hranitel-arhitektury.md
OK
[rc=0]

$ bash scripts/check_ceilings.sh
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/186-hranitel-arhitektury.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md
проводка: role-файл не существует: roles/architecture-steward.md
[rc=1 — ожидаемо до реализации]

$ bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo .
186 role KRASNO: нет роли
186 intake KRASNO: нет роли
186 status KRASNO: нет роли
186 l1 KRASNO: нет роли
186 l2 KRASNO: нет роли
186 l3 KRASNO: нет роли
186 register KRASNO: нет роли
186 register_ci KRASNO: нет роли
186 code_debt KRASNO: нет роли
186 review KRASNO: нет роли
186 review_check KRASNO: нет роли
186 status_cli KRASNO: нет исполняемой проверки статусов
186 review_file KRASNO: нет исполняемой проверки обзора
186 routing KRASNO: неверный routing
186 tier KRASNO: неверный tier
186 fallback KRASNO: неверный fallback
186 critic_family KRASNO: неверный critic_family
186 generated KRASNO: нет модели Sol в агенте
186 done KRASNO: нет потребителя события
186 blocker KRASNO: нет потребителя события
186 schedule KRASNO: нет страховочного timer
186 door l1_merge KRASNO: merge door missing
186 door no_accept KRASNO: merge door missing
186 door accept_other_head KRASNO: merge door missing
186 door accept_author KRASNO: merge door missing
186 door accept_same_family KRASNO: merge door missing
186 door ci_red KRASNO: merge door missing
186 door ci_architecture_missing KRASNO: merge door missing
186 door l2_without_owner KRASNO: merge door missing
186 door l3_without_owner KRASNO: merge door missing
186 door no_complior KRASNO: merge door missing
186 door author_merger KRASNO: merge door missing
186 pin pin_merged KRASNO: post-merge pin checker missing
186 pin lock_missing KRASNO: post-merge pin checker missing
186 pin pin_missing KRASNO: post-merge pin checker missing
186 pin pin_wrong KRASNO: post-merge pin checker missing
186 pin pin_arch_head KRASNO: post-merge pin checker missing
[rc=1 — ожидаемо до реализации]
```

## Атаки

```text
$ bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --model
186 role ok: роль зарегистрирована
186 intake ok: Находки
186 status ok: Статусы
186 l1 ok: L1
186 l2 ok: L2
186 l3 ok: L3
186 register ok: Реестр
186 register_ci ok: CI реестра
186 code_debt ok: Граница полномочий
186 review ok: Обзор
186 review_check ok: Контроль обзора
186 status_cli ok: старый/свежий/разобранный/неконформный статус
186 review_file ok: пропущенный/незакоммиченный/неполный/полный обзор
186 routing ok: routing
186 tier ok: tier
186 fallback ok: fallback
186 critic_family ok: critic_family
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
186 door l1_merge ok: rc=0 output= 
186 door no_accept ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_other_head ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_author ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_same_family ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door ci_red ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door ci_architecture_missing ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door l2_without_owner ok: rc=1 output=L2_OWNER_APPROVAL_REQUIRED 
186 door l3_without_owner ok: rc=1 output=L3_OWNER_APPROVAL_REQUIRED 
186 door no_complior ok: rc=1 output=NO_COMPLIOR_ID 
186 door author_merger ok: rc=1 output=AUTHOR_IS_MERGER 
186 pin pin_merged ok: rc=0 output= 
186 pin lock_missing ok: rc=1 output=ARCHITECTURE_LOCK_MISSING 
186 pin pin_missing ok: rc=1 output=ARCHITECTURE_PIN_MISSING 
186 pin pin_wrong ok: rc=1 output=ARCHITECTURE_PIN_MISMATCH 
186 pin pin_arch_head ok: rc=1 output=ARCHITECTURE_PIN_MISMATCH 
[rc=0]

$ bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --stabs
186 STAB no_frontmatter caught @ role: нет frontmatter
186 STAB calendar_only caught @ done: action architecture-done rc=2
186 STAB blocker_missing caught @ blocker: action architecture-blocker rc=2
186 STAB humans_only caught @ intake: нет обязанности Находки
186 STAB silent_overdue caught @ status_cli: просрочка без именованной строки и rc 1
186 STAB invalid_status caught @ status_cli: неконформный статус скрывает просрочку
186 STAB review_without_file caught @ review: нет обязанности Обзор
186 STAB silent_missing_review caught @ review_file: нет отчёта оркестратору при пропуске done
186 STAB uncommitted_review caught @ review_file: непереданный в PR файл выдаётся за коммит обзора
186 STAB incomplete_review caught @ review_file: пустое содержание выдаётся за обзор
186 STAB no_register_ci_task caught @ register_ci: нет обязанности CI реестра
186 STAB l1_not_pr caught @ l1: нет обязанности L1
186 STAB l1_self_merge caught @ l1: нет обязанности L1
186 STAB l1_same_commit caught @ l1: нет обязанности L1
186 STAB l2_self_merge caught @ l2: нет обязанности L2
186 STAB l3_self_merge caught @ l3: нет обязанности L3
186 STAB l3_no_recommendation caught @ l3: нет обязанности L3
186 STAB writes_code_or_judges caught @ code_debt: нет обязанности Граница полномочий
186 STAB no_roadmap_priority caught @ register: нет обязанности Реестр
186 STAB plan_astra caught @ tier: неверный tier
186 STAB wrong_fallback caught @ fallback: неверный fallback
186 STAB no_role_map caught @ routing: неверный routing
186 STAB critic_sol caught @ critic_family: неверный critic_family
186 STAB route_statistics caught @ routing: неверный routing
186 STAB timer_start caught @ schedule: timer не диспатчит architecture
186 STAB stale_generated caught @ generated: генерация расходится rc=1
186 STAB no_timer caught @ schedule: нет страховочного timer
186 door skip_accept caught: rc=0 output= 
186 door skip_head caught: rc=0 output= 
186 door skip_author caught: rc=0 output= 
186 door skip_family caught: rc=0 output= 
186 door skip_ci caught: rc=0 output= 
186 door skip_architecture_ci caught: rc=0 output= 
186 door skip_baseline caught: rc=0 output= 
186 door skip_l3 caught: rc=1 output=L2_OWNER_APPROVAL_REQUIRED 
186 door skip_id caught: rc=0 output= 
186 door skip_merger caught: rc=0 output= 
186 door skip_head_pin caught: rc=0 output= 
186 pin skip_pin_check caught: rc=0 output= 
186 pin skip_pin_field caught: rc=0 output= 
186 pin compare_arch_head caught: rc=0 output= 
186 pin accept_any_sha caught: rc=0 output= 
[rc=0]
```
