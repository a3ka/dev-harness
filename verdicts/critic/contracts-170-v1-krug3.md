accept

СУД: repo=dev-harness; предмет=170; фаза=контракт; роль=critic; вызов=3/5; модель-план=zai/glm-5.3 (роли critic → тир apex-sol, config/agent_models.json); сессия=Critic170RoundThree; модель-факт=zai/glm-5.3; SHA=ea11324960d96e659dae3c4fe28304e77697f92c; предыдущий=FAIL 857c20958 (v2: повтор класса круга 1 — клетка brief_failure не видит отказ npm в plain-ветви, мутация A2b жива 16/16 зелёных); исключение=решение владельца 2026-11-09 ~18:54 UTC «да» (через консультанта; санкция влита в HANDOFF коммитом c0ffb436a/merge 1ae8d9aed): один исправительный вызов, scoped только на правку A2b; фазовый бюджет 2/2 исчерпан кругом 2

Независимость: автор правки ea1132496 — architect, openai-codex/gpt-6-sol (тот же автор, что кругов 1–2; трасса /tmp/dev-harness-verify/orch/trace-architect-170.tsv); судья — zai/glm-5.3 по назначению роли (critic → apex-sol); совпадения моделей нет, судья собственную работу не судит. Предвызовной строки СУД для предмета=170 в HANDOFF.md нет вновь (третий вызов подряд) — счёт и независимость восстановлены этим вердиктом (СОВЕТ 2).

Область суда: только закрытие класса v2 (именованный `ОТКАЗ: ARCH_BRIEF_OTKAZ:` rc 1 без выдачи частичного пака для implementer/adversary/reviewer) и последствия дельты e22d76d7e→ea1132496. Дельта — ровно два файла батареи: npm_stub.py (notice отказа перенесён в stderr) и probe.py (2>&1 в обеих ветвях вызова npm, три клетки implementer/adversary/reviewer_brief_failure, стаб plain_npm_failure_ignored, якорь fixed_id дополнен 2>&1); контракт строкой не менялся (diff e22d76d7e..ea1132496 по contracts/ пуст), перечитывать прозу вне класса оснований нет. Набор артефактов полон.

## Проверено живьём (одноразовый клон на SHA, команды и rc)

- `git -C <клон> rev-parse HEAD` → `ea11324960d96e659dae3c4fe28304e77697f92c` — кандидат равен OBJECT.
- `bash scripts/pre_critic.sh contracts/170-arch-component-brief-vhod-zadanija.md` → rc 0 (PREDPOSYLKI_OK).
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` → rc 0, честный контроль 19/19 ok; три новые клетки дают в точности форму строки 28: rc=1, пустой stdout, `ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events`.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` → rc 0, 12/12 caught, без ZHIV, включая `plain_npm_failure_ignored @ implementer_brief_failure`; классы кругов 1–2 держатся: `architecture_guard_removed`, `npm_failure_ignored`, `brief_outside_budget` пойманы.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo` → rc 1, до реализации красны 16 клеток (required, все *_rules и *_plain, multi_component, wrong_project, malformed_id, architecture_missing, все четыре *_brief_failure, brief_over_budget), `legacy`, `document`, `brief_kind` зелёные — строка 25 контракта (до реализации красная). Это не дефект архитектора: implementer по ЗОНЕ scripts/make_task.sh ещё не работал.
- Регрессии дельты: `bash fixtures/context_pack_095/red_pravila_proekta_ne_harsa.sh` → rc 0; `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model` → rc 0.

## Мои мутации и наблюдения (склатч /tmp/dev-harness-verify/critic170r3-attack.py и critic170r3b-h1h2.py, отличны от стабов архитектора; сырой вывод в трейсе сессии)

1. M1 — повтор A2b круга 2 (plain-ветвь `|| die "ARCH_BRIEF_OTKAZ: $_arch_id"` → `|| :`), ПОЛНАЯ батарея: `MUTANT A2b replay: red cells -> ['adversary_brief_failure', 'implementer_brief_failure', 'reviewer_brief_failure']` — тот же мутант, что в v2 проходил 16/16 зелёных. Класс круга 2 закрыт.
2. M2 — порядок управления / частичный пак: каждый бриф печатается в stdout немедленно (первый ID успевает выйти до отказа на втором): `red cells -> ['adversary_brief_failure', 'brief_failure', 'brief_over_budget', 'implementer_brief_failure', 'reviewer_brief_failure']`. Условие «пустой stdout (в том числе без первого брифа)» — нагруженное.
3. M3 — пак И отказ (stdout непустой + rc 1 + именованный stderr): три plain-клетки красны — «никогда частичного пака» проверяется отдельно от rc/stderr, а не только ими. `brief_failure` зелёна: мутация только plain-ветви, код проверки у всех четырёх клеток общий.
4. M4 — неверное имя: отказ называет api.identity вместо падающего worker.events — три plain-клетки красны (`stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity'`, клетка требует worker.events). Имя падающего ID проверяется.
5. H1b — честная модель, сырой сценарий по трём plain-ролям (стаб на PATH, FAIL_ID=worker.events, список api.identity,worker.events): `SCEN implementer|adversary|reviewer rc=1 out_bytes=0 stderr_first='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events'`.
6. H2b — маршрутизация клетки (стаб логирует argv): при implementer_brief_failure субъект вызывает npm дважды, оба раза `run brief -- --compact --component api.identity|worker.events` БЕЗ `--with-rules`, в порядке списка — клетка упражняет именно plain-ветвь, а не зеркалит rules-клетку.
7. H3 — дисперсия стаба (notice отказа возвращён в stdout, форма круга 1): честный контроль 19/19 зелёный; A2b-мутант красен во всех трёх plain-клетках — различающая сила не зависит от размещения notice (stdout или stderr).
8. H4 — честная модель без 2>&1: `implementer_brief_failure KRASNO rc=1 stderr='npm notice: brief command failed\nОТКАЗ: …'` — первая строка stderr под полицией: утечка npm краснит клетку, молчаливое протекание невозможно.

Класс круга 2 закрыт доказанно: отказ npm в plain-ветви упражняется тремя клетками и стабом; частичный пак и имя падающего ID краснятся живыми мутациями; честная модель зелёна во всех сценариях, включая мои собственные.

## Советы (едут с accept, отвечать не обязан)

СОВЕТ contracts/170-arch-component-brief-vhod-zadanija.md:28 — «Дано … npm, который на втором выдаёт непустой stdout и rc 17»: стаб на OBJECT печатает notice отказа в stderr (субъект объединяет потоки 2>&1). Живьём (H3/H4) различающая сила сохранена в обоих размещения и усилена полицией первой строки stderr; при следующей правке контракта уточнить формулировку до «непустой вывод npm (stdout или stderr) и rc 17».
СОВЕТ (адресат оркестратор, повтор кругов 1–2) — предвызывной строки СУД для предмета=170 в HANDOFF.md нет и к вызову 3/5; при любом следующем вызове запись до вызова обязательна (§Счёт).

Вердикт: accept — класс круга 2 (ARCH_BRIEF_OTKAZ для implementer/adversary/reviewer без частичного пака) закрыт тремя именованными клетками и стабом plain_npm_failure_ignored; повтор A2b мёртв (M1), порядок контроля и честность клеток доказаны мутациями M2–M4 и наблюдениями H1b–H4; заморозка разрешена.
