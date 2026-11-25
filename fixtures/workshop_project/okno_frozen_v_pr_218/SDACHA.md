# СДАЧА 218 — собственное окно PR

База: source.json/baseline, main a32c577f292a2e925417d78a85cdb00abf25fae3.
Production, workflow, реестры и соседние frozen-семьи не изменяются этой пачкой.
Лист исполняет rc-стабильные двери конструкции; --repo до реализации красен,
не маскируется ожидаемым зелёным. SourceCanon не объявлен.

## Двери

- честная-модель · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- синтаксис · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --sintaksis · 0 · 0
- каталог · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/218-okno-frozen-v-pr.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/218-okno-frozen-v-pr.md · 0 · 0
- проводка-форма · bash scripts/check_provodka.sh --grammar . contracts/218-okno-frozen-v-pr.md · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа и незаполненные требования нет, полный check_sdacha/pre_critic до вызова critic · - · -
- К-02 · чисто · вход: затравка 218, task-architect218.md, дословная воля 23.11, HANDOFF/ROADMAP и §Существующее; sourceCanon отсутствует · - · -
- К-03 · чисто · вход: высшие frozen 200/207/195/083/210/217/992/071 прочитаны context.py; non-PR legacy сверяется с pinned-базой; внешние регрессы обязательны реализации · - · -
- К-04 · чисто · вход: только contracts/218 и новая семья; CI, production и реестры отданы именованным исполнителям · - · -
- К-05 · чисто · вход: раздел Приёмочный критерий, каждая дверь имеет команду и rc · - · -
- К-06 · чисто · вход: настоящий Git/Python/Bash; отказ среды, якоря, синтаксиса и timeout дают NOT_IMPLEMENTED rc 2; старый CLI без --pr отдельно назван красным интерфейсом · - · -
- К-07 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --model · 0 · 0
- К-08 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --stabs · 0 · 0
- К-09 · чисто · вход: event/explicit, owner update, поздний тег, own commit/revert/side/evil merge, неполная/чужая основа, push full/oracle/incr и PR cache=HEAD · - · -
- К-10 · чисто · вход: CLI rc и предметная причина, реальные HEAD/status/cache и Trace2; legacy полный stdout/stderr; PR не объявляется доказанным только по маркеру · - · -
- К-11 · чисто · вход: ожидания/пин/исходный кеш и DAG снимаются до вызова, вне каталога subject/scripts; Git-пути/объекты задаются конструктором, не выводом субъекта · - · -
- К-12 · чисто · вход: Git plumbing для DAG/блобов, stdlib JSON для Trace2, bash -n и validate_std для Bash; формат устава берётся существующими библиотечными функциями · - · -
- К-13 · н/п · секретов и реальных авторских данных нет; synthetic разрешения только внутри временных Git-миров · - · -
- К-14 · чисто · вход: late-tag/own-frozen, owner-update/own-charter/allowed, empty cache non-PR/PR cache own-violation, полный origin/отсутствующий и подменённый · - · -
- К-15 · чисто · bash fixtures/workshop_project/okno_frozen_v_pr_218/red_okno_frozen_v_pr_218.sh --catalog · 0 · 0
- К-16 · чисто · вход: рисковый класс, раздел Модель угроз с доверенной средой и отдельными ловцами неизвестного вычисления/внешних дверей · - · -
- К-17 · н/п · станционный guard, проектной архитектурной модели 188 нет · - · -

## Дельта

Первый вызов конструкции 218; предыдущего critic-вердикта/блоков нет.

## Наблюдавшиеся измерения

--model: rc 0, KLETKI=53 ZELENYE=53 KRASNYE=0.
--stabs: rc 0, STABY=12 SVJAZI=24 POIMANY=24 ZHIVYH=0.
--sintaksis: rc 0, SYNTAX rc=0.
Каталог: CELLS=53 MUTATIONS=12 BINDINGS=24; source.json совпадает.

Полный pre_critic: rc 0, «КРИТИК: дверь зелёная».
Отдельный check_sdacha --run: rc 0,
«СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=0)».
Последовательный общий вызов этих двух дверей занял 222.16 с.
Независимый census (конструктор Cell, отдельный JSON-пересчёт файлов):
cells=53, stabs=12, bindings=24, NONPR=8.

Production ДО реализации: rc 1, KLETKI=53 ZELENYE=8 KRASNYE=45,
21.38 с. Красны все PR-клетки ниже; non-PR клетки зелёные.
На собственных отказных входах старый суд уже может отказать, но он ещё
не несёт PR-режим/ограниченный обход. Это отдельно отмечено PR_MODE и
UNBOUNDED_HISTORY, а не выдаётся за снятое нарушение.

```
frozen-clean
frozen-late-tag
frozen-neighbor-before
frozen-neighbor-after
frozen-owner-update
frozen-owner-update-allowed
frozen-draft
frozen-long-main
frozen-missing-base
frozen-shallow
frozen-forged-base
frozen-no-origin
frozen-unrelated
frozen-own-frozen
frozen-retroactive-frozen
frozen-delete-frozen
frozen-verdict-fail
charter-clean
charter-late-tag
charter-neighbor-before
charter-neighbor-after
charter-owner-update
charter-owner-update-allowed
charter-draft
charter-long-main
charter-missing-base
charter-shallow
charter-forged-base
charter-no-origin
charter-unrelated
charter-own-frozen
charter-retroactive-frozen
charter-delete-frozen
charter-own-charter
charter-reverted-charter
charter-evil-merge
charter-side-charter
frozen-main-merges-1284
charter-explicit-owner
frozen-explicit-late-tag
charter-pr-oracle
charter-pr-cache-head
charter-pr-cache-green
frozen-renamed-values
charter-renamed-values
```

На late-tag/neighbor-after старый frozen-guard даёт rc 1 по чужому 702,
на main-merges-1284 — rc 1 по расширенному v+1-окну, на owner-update
старый charter — rc 1 по принесённому main AGENTS.md. PR cache=HEAD
ошибочно даёт rc 0 при собственной правке. Явный --pr ещё отсутствует:
оба старых CLI дают rc 2 и конкретный Bash «cd: --: invalid option»;
батарея именует только этот известный отсутствующий интерфейс красным,
остальной rc 2/NOT_IMPLEMENTED остаётся отказом среды.

## Граница и рефлексия

Вне PR поведение не заменяется reference. После реализации выполняются
старые семьи 200/207/217/210/083/992 и check_charter; контракт не объявляет
закрытыми Д4 и локальное pre-push копирование frozen-текста.

Задание на внешний scratch противоречит изоляции; применена прямо заданная
поправка $PWD/tmp/scratch-arch218. Все новые миры — внутри копии, удаляются
TemporaryDirectory/finally, production/исходный чекаут не перестраиваются.
Старые семьи, снимающие TMPDIR через env -i, не включены в авторский лист:
их запуск — в разрешённой среде orchestrator на реализации, не скрытый
запуск в чужом /tmp. Журнал А-NN пишется только в main; wip его не меняет.
