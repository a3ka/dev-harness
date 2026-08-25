accept

# Ревьюер — контракт 011, полный финальный гейт, HEAD `aea7c05`

## Вердикт

**accept.** Единственная прежняя блокирующая находка — атрибуция трёх предметных
коммитов с фактическим `%an=orchestrator` — закрыта строго по решению арбитра
`verdicts/arbitration/contract-011-spaseno-v3.md`: в замороженном 011/3 есть
`ЗОНА orchestrator` с четырьмя путями и отдельная `СПАСЕНО orchestrator` с теми
же тремя полными хешами. Новых дефектов области правки, заморозки, проводки или
регрессий не найдено.

Гигиену раннера не пересуждал: предыдущий финальный круг прогнал все её 13
зелёных ветвей на этой же продуктовой версии; после него менялись только
атрибуция/вердикты/перезаморозка (`eca1df7`, `c566664`, `81c27dd`, `e79f727`,
`14b544c`, `aea7c05`) и не менялись `scripts/verify_antiplacebo.sh`,
`scripts/check_runner_hygiene.sh` или `fixtures/check_runner_hygiene/`.
Полный повторный anti-placebo-регресс ниже заново предъявил 33 красных барьера.

## 1. Область правки и атрибуция — пройдены

Независимая история (не `check_zones`) по всем путям предмета и актам спора:

```text
$ git log --no-merges --format='%h %an %s' frozen/contracts/011/1..HEAD -- <все пути предмета 011>
aea7c05 critic critic: переименовать contracts-011-v4.md -> v3.md под грамматику freeze_contract.sh (версия вердикта = номер будущей заморозки, не порядковый номер круга; текст вердикта не меняется
14b544c critic critic: удалить прежний FAIL contracts-011-v3 перед чистым переименованием accept
e79f727 arbiter arbitration: contract-011-spaseno-v3 - заголовок под грамматику freeze_contract.sh (маркер (контракт 011)); суть решения не меняется
81c27dd critic critic: accept contract 011 arbitration compliance v4
c566664 architect NABLIUDENIA_ARCHITECT: А-16 (замер check_zones до заморозки не наблюдаем — метод пробного тега), А-17 (РАЗРЕШИЛ-ВЛАДЕЛЕЦ отсутствовал в чек-листе v+1 уставного документа) — наблюдения вызова исполнения contract-011-spaseno-v3
eca1df7 architect 011 v+1: исполнение РЕШЕНИЯ арбитра (contract-011-spaseno-v3, вариант В) — ЗОНА orchestrator (NABLIUDENIA.md HANDOFF.md roles/ .omp/); СПАСЕНО-строка: автор = фактический %an=orchestrator, те же три хеша; «легализованы» в §История правок приведена к факту (держится тройками СПАСЕНО при объявленной ЗОНА orchestrator); check_zones.sh побайтово не тронут (заморозка 008)
f1c8d5c arbiter arbiter: РЕШЕНИЕ по СПАСЕНО-строке 153 контракта 011 — вариант (В): ЗОНА orchestrator + СПАСЕНО orchestrator; (А) краснит грамматику (замер), (Б) оставляет обход открытым; оба БЛОКа критика v3 подтверждены
f5b2f67 critic critic: FAIL contract 011 SPASENO v3 exactness
689f09e architect 011 СПАСЕНО-2 (v+1, третий за сессию): легализация 7b98b07/8e4b5d1/092314c — предметные коммиты architect ошибочно под именем orchestrator (баг git-identity Н-56, корень закрыт 0318157); содержимое проверено ревьюером (verdicts/review/contracts-011.md); решение владельца 2026-08-25
bf181d8 orchestrator NABLIUDENIA: Н-56 обновлена - корневой фикс сделан (0318157), легализация - следующий шаг
0318157 orchestrator roles: architect/orchestrator - git identity per-commit правило (Н-56 корень)
d195d5c orchestrator NABLIUDENIA: Н-56 — правка git identity (Н-55) сломала атрибуцию architect-субагента
e9ff347 reviewer review: FAIL contract 011 final gate
6a34bd1 orchestrator NABLIUDENIA: Н-55 дополнена — contention (Н-48), не модель/предмет, главная причина грайндов
8bd8a8f orchestrator omp: task.maxRuntimeMs=45мин + hub в инвентаре orchestrator (Н-55)
a3858f8 implementer 011: TOCTOU race в scratch (находка 1 адверсария, круг 2)
092314c orchestrator NABLIUDENIA_ARCHITECT: А-14 (die не сверен с ПРИЧИНОЙ — одна буква, 3 часа), А-15 (lock не разводит checker'ы по корню; «прогон оставлен» ложно)
8e4b5d1 orchestrator 011: причина ветви sostav — континуальная подстрока (вызов не наблюдался)
b87b7df orchestrator NABLIUDENIA: Н-54 — тайм-бокс не сработал даже на Sonnet, hub cancel физически недоступен
7b98b07 orchestrator 011: семантическое усиление sostav + ветвь tocou (находки 1-2 адверсария, круг 2)
a63888a adversary adversary: contracts 011 round 2 verdict
d0471c6 implementer 011: защита от in-tree VERIFY_ANTIPLACEBO_SCRATCH (находка 1 адверсария, круг 1)
fdee3c0 architect 011: закрытие находок 1-2 адверсария (круг 1) — ветви scratchexpl и sostav, +2 фикстуры, эталон отказывает на in-tree scratch
4181a1d adversary adversary: verdict contract 011
a59abe2 critic critic: accept contract 011 zone expansion v3
59ca44f architect NABLIUDENIA_ARCHITECT: А-12 — литеральный блок задания разошёлся с именем решения (В2/Б2)
88f11c9 architect 011 §Зоны (v+1): ЗОНА-строки расширены паттерном каталогов (Б2)
57c9130 orchestrator NABLIUDENIA: Н-53 — check_zones судит процессные артефакты как предметные
7eec44d architect NABLIUDENIA_ARCHITECT: А-11 — pi-uu-grep 17.1.5 молча не матчит BRE-интервалы (\{40\}→0 на любом входе); literal-приёмка правки СПАСЕНО врала нулём, счёт снят ERE+python3 (две меры согласны); кандидат-механизм в 013/поток A
4b94dbf architect 011 СПАСЕНО: дополнение строки четвёртым хешем a534e4b (вариант А)
5d05ba9 architect 011 СПАСЕНО (v+1): carve-out трёх операционных коммитов оркестратора — вариант А
a534e4b architect HANDOFF: оверлей-лог — сессия на anthropic/claude-sonnet-5 (config/models-claude.yml)
320d67f architect NABLIUDENIA: Н-52 (правило «сырое наверх») + роль orchestrator + скорректирована Н-51
a396a7f implementer 011 implementer: гигиена раннера + маркер приёмки судьи v2 + аннотация 010
a2aaf5e architect HANDOFF: зафиксирован выбор Б (011-bis следующий) + Н-51 с замером glm
4a73d71 architect NABLIUDENIA: Н-51 (10ч грайнда без тайм-бокса, $32 на glm) + роль orchestrator (тайм-бокс делегирования, cognitive-only)
SUBJECT_HISTORY_EXIT_RC=0
```

Полный `--name-status` того же диапазона проверен отдельно. Существенный для
прежнего FAIL результат — не пересказ: `7b98b07` меняет барьер и четыре
фикстурных пути, `8e4b5d1` — барьер, `092314c` —
`NABLIUDENIA_ARCHITECT.md`; все три имеют `AUTHOR orchestrator`. Остальные семь
коммитов `orchestrator` меняют исключительно `NABLIUDENIA.md`, `roles/` или
`.omp/`; четыре прежних коммита с `%an=architect` также поимённо спасены. Акты
арбитра меняют только `verdicts/arbitration/contract-011*.md`; акты критика,
адверсария и ревьюера — только собственные вердикты. Это соответствует
заявленным границам и предписанию арбитра, а не добавляет новую работу роли.

Сырой вывод механизма теперь показывает именно три ранее невидимых хеша:

```text
$ bash scripts/check_zones.sh
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: adversary → verdicts/adversary/ 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → contracts/011-prijomka-sudi-i-gigiiena-rannera.md 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → fixtures/check_runner_hygiene/ 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → fixtures/check_zones/ 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → .github/workflows/ci.yml 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → NABLIUDENIA_ARCHITECT.md 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → package.json 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: architect → scripts/check_runner_hygiene.sh 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: critic → verdicts/critic/ 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: implementer → AGENTS.md 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: implementer → contracts/010-topologija-orkestrator-arhitektor.md 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: implementer → scripts/verify_antiplacebo.sh 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: orchestrator → HANDOFF.md 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: orchestrator → NABLIUDENIA.md 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: orchestrator → .omp/ 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: orchestrator → roles/ 011
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — зона: reviewer → verdicts/review/ 011
  ok   контракт 011: коммит 092314c7 (orchestrator) — СПАСЕНО, из суда зон выведен
  ok   контракт 011: коммит 8e4b5d1a (orchestrator) — СПАСЕНО, из суда зон выведен
  ok   контракт 011: коммит 7b98b07f (orchestrator) — СПАСЕНО, из суда зон выведен
  ok   контракт 011: коммит a534e4b6 (architect) — СПАСЕНО, из суда зон выведен
  ok   контракт 011: коммит 320d67f5 (architect) — СПАСЕНО, из суда зон выведен
  ok   контракт 011: коммит a2aaf5ee (architect) — СПАСЕНО, из суда зон выведен
  ok   контракт 011: коммит 4a73d71d (architect) — СПАСЕНО, из суда зон выведен

замороженных контрактов: 10 · объявленных авторов: 6 · коммитов в диапазонах: 237 · проверено по зонам: 160
CHECK_ZONES_EXIT_RC=0
```

## 2. Заморозка и устав — пройдены

```text
$ bash scripts/check_contract_frozen.sh
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — заморожен v3, блоб совпадает побайтово, вердикты v1..v3 разрешают
планов и контрактов на HEAD: 14 · черновиков: 3 · заморожено: 11 · реестр: full
CHECK_CONTRACT_FROZEN_EXIT_RC=0

$ sha256sum HEAD и frozen/contracts/011/3
HEAD_SHA256  097b4c03dba8bb6f4da331e7cb2326a615b59c60926864a35c48452fba9d02e6  contracts/011-prijomka-sudi-i-gigiiena-rannera.md
FROZEN_SHA256 097b4c03dba8bb6f4da331e7cb2326a615b59c60926864a35c48452fba9d02e6  -
FROZEN_011_3_BYTE_COMPARE_EXIT_RC=0

$ npm run check:charter
npm notice run dev-harness@0.0.0 check:charter
npm notice run bash scripts/check_charter.sh
  ok   уставной документ изменён с разрешения владельца: contracts/011-prijomka-sudi-i-gigiiena-rannera.md в eca1df72
  ok   уставной документ изменён с разрешения владельца: contracts/011-prijomka-sudi-i-gigiiena-rannera.md в 689f09eb
  ok   уставной документ изменён с разрешения владельца: contracts/011-prijomka-sudi-i-gigiiena-rannera.md в 88f11c92
  ok   уставной документ изменён с разрешения владельца: contracts/011-prijomka-sudi-i-gigiiena-rannera.md в 4b94dbf5
  ok   уставной документ изменён с разрешения владельца: contracts/011-prijomka-sudi-i-gigiiena-rannera.md в 5d05ba9f
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — уставной с frozen/contracts/011/1, коммитов в диапазоне 38, изменений без разрешения нет

уставных документов: 13 · изменений в них: 37 · с разрешения: 37
CHECK_CHARTER_EXIT_RC=0
```

## 3. Полные регрессии anti-placebo — пройдены

Это именно оба полных набора своей зоны (`--scope` выбирает барьер, но каждый
запуск исполняет все его фикстуры и повторно предъявляет красный):

```text
$ bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 33 · предъявлено красным повторным прогоном: 33
VERIFY_HYGIENE_EXIT_RC=0

$ bash scripts/verify_antiplacebo.sh --scope check_zones
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_zones/case_avtor_s_tabuljaciej.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «табуляцию»
  ok   check_zones/case_kommit_vne_zony.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_konec_diapazona_done.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_ni_zon_ni_otkaza.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «ни зон, ни отказа от раздачи»
  ok   check_zones/case_otkaz_bez_prichiny.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «причина пуста»
  ok   check_zones/case_put_s_kavychkami.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «кавычку»
  ok   check_zones/case_reestr_nedostupen.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «реестр заморозок»
  ok   check_zones/case_spaseno_ne_nazvannyj_hash.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_spaseno_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «СПАСЕНО вне объявленной грамматики»
  ok   check_zones/case_zona_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вне объявленной грамматики»
  ok   check_zones/case_zones_critic_v_others.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_zony_drugogo_kontrakta.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»

барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
VERIFY_ZONES_EXIT_RC=0
```

## 4. Проводка — пройдена

```text
$ npm run check:ci-parity
npm notice run dev-harness@0.0.0 check:ci-parity
npm notice run bash scripts/verify_ci_parity.sh
workflow-команд: 22 · скриптов в приёмке: 34 · объявленных исключений: 12 · расхождений: 0
CHECK_CI_PARITY_EXIT_RC=0

$ bash scripts/check_scoped_run.sh
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)
  ok   (ц) нерезолвимый base → полный прогон, RC=0
  ok   (ч) doc-only → RC=0, 0 барьеров
  ok   (ц2) пустой base → полный прогон, RC=0
  ok   (ц3) нерезолвимый ненулевой SHA → полный прогон, RC=0
  ok   (ч2) не-README нулевая выборка → RC=0, 0 барьеров
  ok   (ci) ci.yml: ИСПОЛНЯЕМАЯ run-строка гонит анти-плацебо scoped (--changed github.event.before)
check_scoped_run: ветви «all» зелены
CHECK_SCOPED_RUN_EXIT_RC=0
```

Проверены и прочитаны целиком: текущий контракт 011, прежний reviewer-FAIL и
арбитраж `contract-011-spaseno-v3`. Норма 011 не менялась молча: v+1 имеет
владельческое разрешение, заморожена как `/3` и разрешена accept-вердиктом
критика v3. Атрибуционный обход, который прежний reviewer-FAIL зафиксировал,
ныне не скрыт: все три хеша печатаются `СПАСЕНО` при действующей зоне
orchestrator.
