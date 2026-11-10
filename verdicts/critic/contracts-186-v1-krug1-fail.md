FAIL
OBJECT=5472529f9c2c5471865dc055ab0fa986034e5254
СУД: repo=dev-harness; предмет=186; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=zai/glm-5.3; SHA=5472529f9c2c5471865dc055ab0fa986034e5254; предыдущий=нет; исключение=нет

## Блокирующие находки

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:139 — незамороженный кандидат не несёт обязательный раздел `## Незаполненные требования:` и не проходит действующий потолочный guard.
ОБЯЗАТЕЛЬСТВО: каждый незамороженный `contracts/NNN-*.md` обязан иметь этот раздел с телом ровно `нет` либо непустым списком `- …`.
СОСТОЯНИЕ: `scripts/check_ceilings.sh` судит 186 как черновик.
НАБЛЮДЕНИЕ: команда дала rc 1 и следующий сырой вывод:
```text
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  FAIL контракт /tmp/dev-harness-verify/Crit186v2/repo/contracts/186-hranitel-arhitektury.md (36877 байт): нет раздела «Незаполненные требования:»
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
превышений/нарушений: 1
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: на исправленном кандидате `bash scripts/check_ceilings.sh` возвращает rc 0; раздел перечисляет остающиеся требования либо дословно `нет`.

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:22,33 — приёмка не отличает обязательного независимого GLM-судью дельт хранителя от того же Sol-tier, что у хранителя.
ОБЯЗАТЕЛЬСТВО: хранитель назначен на Sol, а суд его дельт остаётся в другом семействе (GLM); назначения остальных ролей не меняются.
СОСТОЯНИЕ: вход — поддерживаемая операция реализации `config/agent_models.json` с последующей генерацией агентов. Ошибочный механизм — замена существующего `roles.critic: "apex-sol"` на `roles.critic: "steward-arch"`, то есть тот же Sol-tier, что введён для `architecture-steward`.
НАБЛЮДЕНИЕ: одноразовая мутация этой привязки в честном toy перед `npm run gen:harness` оставила все 20 клеток `--model` зелёными (сырой вывод приведён в разделе «Атаки»).
ОБХОД: изменить только существующую привязку `roles.critic` на `steward-arch`; хранитель и критик получают Sol, но `python3 fixtures/workshop_project/architecture_steward_186/probe.py --model` возвращает rc 0.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: замена critic-tier на tier хранителя делает независимую клетку модели красной; GLM-назначение судьи остаётся зелёным.

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:22,33 — клетка `routing` принимает произвольное правило со словом «архитектур…», хотя предмет требует связать с хранителем именно приём и обзор архитектуры.
ОБЯЗАТЕЛЬСТВО: `routing.rules` привязывает приём и обзор архитектуры к `architecture-steward`.
СОСТОЯНИЕ: вход — поддерживаемая конфигурационная операция `routing.rules`; ошибочный механизм — замена планируемой записи `обзор архитектуры после done этапа и блокирующей находки` на существующую конфигурационную запись с тем же получателем, но без приёма, обзора или событий.
НАБЛЮДЕНИЕ: одноразовая замена class на `архитектурная статистика` оставила все 20 клеток `--model` зелёными (сырой вывод приведён в разделе «Атаки»); текущий оракул проверяет только получателя и подстроку `архитектур`.
ОБХОД: такая запись не маршрутизирует ни приём находок, ни обзор после `done`/blocker, но проходит `routing` и весь `--model` с rc 0.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: правило, не связывающее роль с приёмом и обзором после `done` либо блокирующей находки, делает клетку `routing` красной.

БЛОКИРУЕТ contracts/186-hranitel-arhitektury.md:15,28 — клетка `schedule` не проверяет, что установленный weekly timer реально диспатчит страховочное действие `architecture`.
ОБЯЗАТЕЛЬСТВО: timer — только страховочный путь обзора; `done` и blocker остаются первичными сигналами.
СОСТОЯНИЕ: systemd `Unit=` — рабочий вход поддерживаемой станции. Ошибочный механизм — замена существующего действия таймера `orch-peak@architecture.service` на `orch-peak@start.service`; ручной вызов `architecture` при этом продолжает работать, но timer обзора не запускает.
НАБЛЮДЕНИЕ: одноразовая мутация `Unit=` оставила все 20 клеток `--model`, включая `schedule`, зелёными (сырой вывод приведён в разделе «Атаки»); оракул проверяет лишь существование файла/имя в installer и затем вызывает action напрямую.
ОБХОД: systemd запускает `start`, а не страховочный `architecture`, но `python3 fixtures/workshop_project/architecture_steward_186/probe.py --model` возвращает rc 0.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: смена timer-dispatch с `architecture` на другое действие делает `schedule` красной при сохранении прямого action-обработчика.

## Учёт, объект и области

`git rev-parse HEAD` после `git fetch origin wip/186/architect wip/012/orchestrator` и detached checkout вернул:
```text
5472529f9c2c5471865dc055ab0fa986034e5254
```

Предварительная запись СУД подтверждена опубликованным коммитом `74c698073e0809462c97aa214ad813feef63b5d8` до вызова:
```text
СУД: repo=dev-harness; предмет=186; фаза=контракт (переписан по Fable-11 §8, хранитель на Sol, пункты 10–12/14 восстановленных решений); роль=critic; вызов=1/2 (прежний вызов Crit186v1 на текст 3035fa462 оборван/освобождён obryv_bez_verdikta по слову консультанта ~19:47, круг не тратился); модель-план=zai/glm-5.3; сессия=ожидается; SHA=5472529f9c2c5471865dc055ab0fa986034e5254; предыдущий=нет (вердикт на 3035fa462 не материализован); исключение=нет
```

Точная дельта `c43111d2981cbed9163b150e24f28192fa31dab8..5472529f9c2c5471865dc055ab0fa986034e5254` содержит только:
```text
M	contracts/186-hranitel-arhitektury.md
M	fixtures/workshop_project/architecture_steward_186/probe.py
```

Scoped-проверка зон, не полный запуск, завершилась rc 0:
```text
incr: check_zones судит c43111d2..5472529f (2 коммита)
…
замороженных контрактов: 165 · объявленных авторов: 5 · коммитов в диапазонах: 328 · проверено по зонам: 328
```

## Прогоны кандидата

```text
$ bash scripts/pre_critic.sh contracts/186-hranitel-arhitektury.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/186-hranitel-arhitektury.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md
проводка: role-файл не существует: roles/architecture-steward.md
[rc=1 — ожидаемо до реализации]

$ bash scripts/check_precision_gate.sh . contracts/186-hranitel-arhitektury.md
OK
[rc=0]

$ python3 fixtures/workshop_project/architecture_steward_186/probe.py --model
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
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
[rc=0]

$ python3 fixtures/workshop_project/architecture_steward_186/probe.py --repo .
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
186 generated KRASNO: нет модели Sol в агенте
186 done KRASNO: нет потребителя события
186 blocker KRASNO: нет потребителя события
186 schedule KRASNO: нет страховочного timer
[rc=1 — ожидаемо до реализации]
```

## Атаки

Архитекторские 24 стаба после восстановления исходного fixture:
```text
$ python3 fixtures/workshop_project/architecture_steward_186/probe.py --stabs
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
186 STAB stale_generated caught @ generated: генерация расходится rc=1
186 STAB no_timer caught @ schedule: нет страховочного timer
[rc=0]
```

Одноразовая мутация прежнего обхода L1: в созданной role вместо обеих L1-обязанностей оставлена строка `L1: исправляй L1 без проверки.`; после прогона исходник восстановлен.
```text
$ python3 .tmp_critic_l1_mutation.py apply && python3 fixtures/workshop_project/architecture_steward_186/probe.py --model
186 role ok: роль зарегистрирована
186 intake ok: Находки
186 status ok: Статусы
186 l1 KRASNO: нет обязанности L1
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
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
[rc=1]
```

Одноразовая мутация `roles.critic = steward-arch`; после прогона исходник восстановлен.
```text
$ python3 .tmp_critic_family_mutation.py apply && python3 fixtures/workshop_project/architecture_steward_186/probe.py --model
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
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
[rc=0]
```

Одноразовая мутация route class в `архитектурная статистика`; после прогона исходник восстановлен.
```text
$ python3 .tmp_critic_routing_mutation.py apply && python3 fixtures/workshop_project/architecture_steward_186/probe.py --model
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
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
[rc=0]
```

Одноразовая мутация Unit таймера в `orch-peak@start.service`; после прогона исходник восстановлен.
```text
$ python3 .tmp_critic_schedule_mutation.py apply && python3 fixtures/workshop_project/architecture_steward_186/probe.py --model
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
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
[rc=0]
```

Все одноразовые файлы мутаций удалены; перед записью этого вердикта `git diff --exit-code` вернул rc 0.
