FAIL
OBJECT=f1f6157697d2425fd710fc4ce19a896ad62629c4
СУД: repo=dev-harness; предмет=186; фаза=контракт; роль=critic; вызов=2/2; модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=zai/glm-5.3; SHA=f1f6157697d2425fd710fc4ce19a896ad62629c4; предыдущий=verdicts/critic/contracts-186-v1-krug1-fail.md; исключение=нет

## Блокирующие находки

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:21,35 — приёмка L1 не доказывает названное обязательство после слияния закрепить принятый архитектурный коммит в `architecture.lock.json` продуктового PR.
ОБЯЗАТЕЛЬСТВО: после L1-слияния продуктовый PR закрепляет коммит в `architecture.lock.json`; каждый пункт готовности обязан иметь rc-команду, отличающую это состояние от отсутствия операции.
СОСТОЯНИЕ: документированная честная L1-сценарий из строки 35 проходит `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --model`.
НАБЛЮДЕНИЕ: в этой честной ветви `fixtures/workshop_project/architecture_steward_186/door_probe.py` создаёт PR/toy Git и проверяет только rc двери, argv `gh pr merge --match-head-commit` и двухродительский merge; `door_control.py` также не создаёт и не проверяет `architecture.lock.json`. Живой `--model` дал `186 door l1_merge ok: rc=0`, поэтому текущая единственная команда готовности становится зелёной без фиксации коммита в lock-файле.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при честном L1-пути приёмочная rc-команда подтверждает, что последующий продуктовый PR закрепил именно принятый head в `architecture.lock.json`; отсутствие файла, отсутствие пина или иной SHA делает отдельную красную клетку.

## Область исправительного вызова

По `git diff e8317879..f1f61576` семантическая дельта закрывает четыре класса круга 1 и добавляет дверь L1. Поэтому во втором вызове проверены прежние четыре класса и новые условия двери, включая пересечение с 188, а неизменённые поверхности заново не исследовались.

Проверенные закрытия круга 1:

- `bash scripts/check_ceilings.sh` вернул rc 0: в контракте есть `## Незаполненные требования:` с телом `нет`.
- Мутация `critic_sol` поймана независимой клеткой `critic_family`.
- Мутация `route_statistics` поймана клеткой `routing`.
- Мутация `timer_start` поймана клеткой `schedule`.

Проверены последствия новой двери: класс риска назван как `рисковый` с основанием «авторизация/безопасность`; граница с 188 совпадает с owner-источником `docs/owner/2026-11-10-arhitektura-v-processe.md` (186 владеет только потребителем событий, очередью, контролем обзора и командой L1; остальные строки ролей остаются 188). В `## Модель угроз` явно названы ограничение toy/fake-CLI и необходимость станционной трассы `check_sud_model.sh`; контракт не выдаёт toy за готовую живую дверь. Вопрос доверенного носителя GitHub accept оставлен внешней предпосылкой, а не выдан за доказательство фактической модели.

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
[rc=0]
```
