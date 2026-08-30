FAIL

# Финальная перепроверка контракта 016

Проверен HEAD `244e97f` относительно `frozen/contracts/016/1` (постоянный v3 —
`frozen/contracts/016/3` на `181cfb5`). CI зелёный на HEAD — входной факт, не мой
полный прогон. Вердикт FAIL по R016-1 и R016-2 ниже: `land_agent.sh` не отказывает до
merge, когда переданный worktree не содержит HEAD приземляемой ветки; его фикстуры срезов
2–4 созданы и затем менялись тем же implementer, что создал механизм, и конкретно не
судят этот контрактный вход.

## Сверка §Предмет → реализующий коммит

| Пункт §Предмет | Реализующий коммит(ы) | Факт в дереве |
|---|---|---|
| Срез 1: `check_staged` (зоны staged, control-символ, пустое/необъявленное), общая `lib_zones`, `check_hooks`, `.githooks/pre-commit`, `/out*.txt`-маски и проводка CI | `5e37f9b`; identity-канарейка — `61fac16`; CI-parity — `bf7c456`; закрытия поведения — `2681d06`, `926e5fd`, `8aa2c6c` | Все названные предметные файлы есть; `check_staged` импортирует `lib_zones`; `.githooks/pre-commit` и npm-проводка существуют; `npm run check:hooks` и `npm run check:ci-parity` зелёные. Пробы и scoped-предъявления ниже содержат красные повторы причин. |
| Срез 2: `spawn_agent.sh`: `wip/<NNN>/<автор>` от main, внешний worktree, точный stdout, откат | `6285e36`; его зелёно-красная fixture-доработка — `e6ad945` | Скрипт существует; ручной toy-прогон напечатал ровно `WORKTREE=` и `BRANCH=`, затем worktree и ветка удалены. Scoped `spawn_agent` зелёный. |
| Срез 3: `land_agent.sh`: предмет в HEAD worktree, грязный main, identity, merge `--no-ff`, frozen, push, снос | `136f1a5`; исправления барьеров — `0071e8d`, `61fac16`, `2681d06`; результат-пины решения первого арбитража — `51294ab` | Код и восемь контрактных case существуют, scoped зелёный, но R016-1 доказывает, что обязательный И-8 реализован неполно: script проверяет только `WT_HEAD != main`, а не `WT_HEAD == tip` заданной `--branch`. |
| Срез 4: `gc_agent_branches.sh`: снос слитых, сохранение/список зависших, OID и `python3 lstat` sweep | `6285e36`; исправление — `0071e8d`; result-pin OID — `51294ab`; fixture-доработка — `e6ad945` | Скрипт существует; два case scoped-предъявляют исчезновение и смену OID красным. |

Таким образом реализации, а не только барьеры или фикстуры, прослеживаются для каждого
среза. Это не устраняет R016-1: наличие реализующего коммита не равно выполнению И-8.

## Область, норма и независимость проверок

`git diff --name-status frozen/contracts/016/1..HEAD` дал 45 файлов. Их состав —
реализация в implementer-зоне (`scripts/`, `.githooks/`, `package.json`, CI, маски,
`fixtures/{spawn_agent,land_agent,gc_agent_branches}`), architect-зона (`fixtures/check_*`,
`NABLIUDENIA_ARCHITECT.md`), critic/adversary/arbitration verdicts и orchestrator-зона.
Две уставные правки `roles/architect.md` и `.omp/agents/architect.md` — точные два пути,
добавленные разрешённой зоной v3 (`0881295`); это не молчаливое изменение нормы.

Счёт фикстур независимой командой контракта: **23**.

История авторства не даёт независимой проверки срезов 2–4: `136f1a5` —
`implementer/implementer` — одновременно добавил `scripts/land_agent.sh` и все
`fixtures/{spawn_agent,land_agent,gc_agent_branches}`; `e6ad945` тем же
`implementer/implementer` затем изменил эти fixtures. В частности,
`fixtures/land_agent/case_priyomka_bez_vetki.sh` проверяет только случай
`WT_HEAD == main`. Он не проверяет требование И-8 о предмете именно в HEAD переданного
worktree и потому не ловит R016-1. Пробы среза 1 независимы по авторству: изменения
механизма — implementer, новые красные cases — architect (`265c3f7`, `07e0bd9`,
`ae2b257`).

## Находки

### R016-1 — FAIL, класс: неполное контрактное предъявление И-8 / частичная мутация до отказа

И-8 требует: приёмка исполняется **в worktree**, а предмет обязан быть в его HEAD; иначе
приземление отказывает. `scripts/land_agent.sh` сопоставляет `WT_HEAD` только с `main`.
Он не сопоставляет `WT_HEAD` с `tip_sha` ветки из `--branch`.

Собственная репродукция в `/tmp` создала target `wip/001/implementer` с коммитом
`300e011`, иной worktree `wip/002/critic` с HEAD `b6d1520`, и вызвала:

```text
$ bash /tmp/reviewer016-i8-repro.sh
ОТКАЗ: ветка wip/001/implementer пережила приземление — И-4 не держится
rc=1
```

До этого отказа script успел исполнить merge target-ветки в main: отказ И-4 случился
лишь потому, что реальный worktree target-ветки оставался вычеканным и не был передан
`--worktree`. Значит, на запрещённом И-8 входе нет требуемого отказа **до merge**:
`main` уже мутирован, хотя HEAD переданного worktree был другим коммитом. Проверка
`WT_HEAD != main` ловит только частный случай пустой ветки; она не доказывает отношение
`WT_HEAD == tip_sha` и не удостоверяет, что приземляемый предмет находился в worktree.

### R016-2 — FAIL, класс: проверка подогнана автором реализации / нет красного для R016-1

`git show --name-status 136f1a5` и `e6ad945` подтверждают одного автора реализации и
fixture-слоя срезов 2–4. Это не только процессный риск: R016-1 проходит их зелёную
модель. В scoped `land_agent` есть красный `case_priyomka_bez_vetki` с причиной
«HEAD worktree не отличается от main», но нет случая `WT_HEAD != main && WT_HEAD != tip`
с требованием отказа до merge. Следовательно, красное предъявление для полного барьера
И-8 отсутствует, а существующее зелёное не доказывает контракт.

## Что прогнано (дословный сырой вывод)

Все прогоны ниже сделаны на HEAD `244e97f`; scratch — только literal `/tmp` и после
прогонов удален.

```text
$ bash fixtures/check_staged/probe_check_staged_krasnyj.sh
rc=0
ok: стаб честной формы — все пять case: зелёный контроль + красное повтором
ok: стаб зоны-слеп пойман на входе case_vne_zon
ok: стаб грамматика-слеп пойман на входе case_imja_control_simvol
ok: стаб всё-красно пойман на зелёном контроле
ok: стаб канарейка-слеп пойман на входе case_imja_fake_python3_exit_1
ok: судья зелёный на живом дереве (staged пуст, всё в зоне либо автор не объявлен)

$ bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh
rc=0
ok: стаб честной формы — все семь case: зелёный контроль + красное повтором
ok: стаб хук-декой пойман на входе case_huk_ne_vedet_k_sude
ok: стаб установщик-декой пойман на входе case_bez_ustanovshhika
ok: стаб проба-слеп пойман на входе case_inert_heredoc_hook
ok: стаб ф1-декой пойман на входе case_huk_sniffer_toy
ok: стаб ф2-фикс-декой пойман на входе case_huk_forged_output
ok: механизм установки хука цел на живом дереве

$ bash scripts/verify_antiplacebo.sh . --scope check_staged
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_staged/case_imja_control_simvol_bez_python3.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «python3 отсутствует»
  ok   check_staged/case_imja_control_simvol.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «control-символ»
  ok   check_staged/case_imja_fake_python3_exit_0.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «канарейка не подтверждена»
  ok   check_staged/case_imja_fake_python3_exit_1.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «канарейка не подтверждена»
  ok   check_staged/case_vne_zon.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вне зоны:»

барьеров: 1 · фикстур: 5 · предъявлено красным повторным прогоном: 5

$ bash scripts/verify_antiplacebo.sh . --scope check_hooks
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_hooks/case_bez_huka.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «механизм установки без хука»
  ok   check_hooks/case_bez_ustanovshhika.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «нет механизма установки»
  ok   check_hooks/case_huk_forged_output.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не упомянут»
  ok   check_hooks/case_huk_kommentarij_vmesto_zapuska.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «хук не ведёт к судье»
  ok   check_hooks/case_huk_ne_vedet_k_sude.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «хук не ведёт к судье»
  ok   check_hooks/case_huk_sniffer_toy.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «поведенческая проба связи — чистый staged отклонён»
  ok   check_hooks/case_inert_heredoc_hook.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «поведенческая проба связи — pre-commit вернул rc=0»

барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7

$ bash scripts/verify_antiplacebo.sh . --scope spawn_agent
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   spawn_agent/case_bez_identichnosti.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «HEAD не main»

барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1

$ bash scripts/verify_antiplacebo.sh . --scope land_agent
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   land_agent/case_gryaznyj_main.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «главное дерево загрязнено мимо worktree»
  ok   land_agent/case_identity_rasscheplena.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «identity расщеплена»
  ok   land_agent/case_imja_podstroka_reestra.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «имя вне реестра ролей»
  ok   land_agent/case_imja_vne_reestra.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «имя вне реестра ролей»
  ok   land_agent/case_kommit_mimo_merge.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не несёт коммитов относительно main»
  ok   land_agent/case_merzh_ne_orkestrator.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не несёт коммитов относительно main»
  ok   land_agent/case_priyomka_bez_vetki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «HEAD worktree не отличается от main»
  ok   land_agent/case_vetka_perezhila.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «главное дерево загрязнено мимо worktree»

барьеров: 1 · фикстур: 8 · предъявлено красным повторным прогоном: 8

$ bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   gc_agent_branches/case_zavisshaja_peredvinuta.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «цель заявленной зависшей сменена»
  ok   gc_agent_branches/case_zavisshaja_snesena.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «заявленная зависшая ветка не наблюдается»

барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2

$ bash scripts/verify_antiplacebo.sh . --scope check_zones
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_zones/case_avtor_s_tabuljaciej.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «табуляцию»
  ok   check_zones/case_kommit_vne_zony.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_konec_diapazona_done.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_ni_zon_ni_otkaza.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «ни зон, ни отказа от раздачи»
  ok   check_zones/case_otkaz_bez_prichiny.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «причина пуста»
  ok   check_zones/case_protsessnye_vne_suda.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_put_s_kavychkami.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «кавычку»
  ok   check_zones/case_reestr_nedostupen.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «реестр заморозок»
  ok   check_zones/case_spaseno_ne_nazvannyj_hash.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_spaseno_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «СПАСЕНО вне объявленной грамматики»
  ok   check_zones/case_zona_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вне объявленной грамматики»
  ok   check_zones/case_zones_critic_v_others.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_zony_drugogo_kontrakta.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»

барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13

$ bash scripts/verify_antiplacebo.sh . --scope check_contract_frozen
rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_contract_frozen/case_imja_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «объявление вне грамматики»
  ok   check_contract_frozen/case_izmenjon_bez_zamorozki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «изменён без новой заморозки»
  ok   check_contract_frozen/case_legkij_teg_rukoj.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «лёгкий (объект»
  ok   check_contract_frozen/case_reestr_nedostupen.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «реестр заморозок»
  ok   check_contract_frozen/case_teg_rukoj_bez_verdikta.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «без вердикта критика»
  ok   check_contract_frozen/case_verdikt_ne_accept.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «поверх вердикта, который её не разрешил»

барьеров: 1 · фикстур: 6 · предъявлено красным повторным прогоном: 6

$ ! grep -rnE '\\bgit\\b[^|<>]*[[:space:]](commit|merge)[[:space:]]' scripts/ | grep -vE ':[0-9]+:[[:space:]]*#' | grep -v merge-base | grep -vE 'user\\.(name|email)=|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)' | grep .
rc=0
stdout пуст

$ ! grep -rnE '\\bgit\\b[^|<>]*[[:space:]](commit|merge)[[:space:]]' scripts/ | grep -vE ':[0-9]+:[[:space:]]*#' | grep -v merge-base | grep -vE 'user\\.(name|email)=|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)' | grep .
# cwd=/tmp/reviewer016-canary.U6ffMq, scripts/bypass.sh содержит git commit без identity
rc=1
scripts/bypass.sh:2:git commit -m 'without identity'

$ npm run check:hooks
rc=0
npm notice run dev-harness@0.0.0 check:hooks
npm notice run bash scripts/check_hooks.sh
ok: механизм установки хука цел (.githooks/pre-commit → scripts/check_staged.sh; package.json → core.hooksPath)

$ npm run check:ci-parity
rc=0
npm notice run dev-harness@0.0.0 check:ci-parity
npm notice run bash scripts/verify_ci_parity.sh
  ok   скрипт «gen:harness» не в CI — объявленное исключение: команда записи: порождает .omp/agents/ из roles/, в CI прогонять запись неправильно — для сверки есть check:gen
  ok   скрипт «workshop» не в CI — объявленное исключение: интерактивный лаунчер: поднимает сессию роли в терминале, в CI вести её некому — для сверки слоя есть check:overlay и check:gen
  ok   скрипт «check:metering» не в CI — объявленное исключение: требует подставного upstream и сети: фикстуры поднимают stub_upstream на свободном порту и посылают вызовы через живой процесс, в CI прокси не поднимается
  ok   скрипт «check:metering:cold» не в CI — объявленное исключение: требует подставного upstream и живой работник workshop: фикстура убивает прокси по pid-файлу и стартует workshop --check-metering, в CI pid-файла и подъёма нет
  ok   скрипт «check:metering:live» не в CI — объявленное исключение: требует живой omp: фикстура посылает uuid-вызов через живой канал и сверяет коррелятор в calls.jsonl, в CI omp не поднимается
  ok   скрипт «overlay» не в CI — объявленное исключение: команда записи: накладывает слой поверх omp, в CI прогонять запись неправильно — для сверки есть check:overlay и check:gen
  ok   скрипт «check:overlay» не в CI — объявленное исключение: предмет локальный: сверяет sha256 бинаря omp 185 МБ с пином, в CI бинаря и пина нет — прогон вернул бы NOT_IMPLEMENTED
  ok   скрипт «models:actual» не в CI — объявленное исключение: требует трейс последней сессии в .zones/dev/, в CI трейса нет — прогон вернул бы NOT_IMPLEMENTED
  ok   скрипт «next:id» не в CI — объявленное исключение: команда выдачи: печатает следующий номер артефакта в stdout, в CI прогонять неправильно — для проверки уникальности есть check:ids
  ok   скрипт «hooks:install» не в CI — объявленное исключение: команда записи: ставит core.hooksPath в локальный git config, в CI прогонять запись неправильно — для сверки механизма есть check:hooks
  ok   скрипт «check:staged» не в CI — объявленное исключение: предмет — staged живого коммиттера: на чистом CI-чекауте staged пуст по построению, rc=0 тавтологией; для сверки механизма есть check:hooks, для раннерных инвариантов — scoped-прогон фикстур check_staged
  ok   скрипт «spawn:agent» не в CI — объявленное исключение: команда записи: создаёт ветку wip/<NNN>/<автор> и worktree вне стерегомого дерева, в CI прогонять запись неправильно — для сверки изоляции есть fixtures/spawn_agent/case_*
  ok   скрипт «land:agent» не в CI — объявленное исключение: команда записи: мерджит --no-ff в main с identity оркестратора и мутирует коммитера, в CI прогонять запись неправильно — для сверки приземления есть fixtures/land_agent/case_*
  ok   скрипт «gc:agent-branches» не в CI — объявленное исключение: команда записи: сносит слитые wip/* ветки и связанные worktree, в CI прогонять запись неправильно — для сверки механизма GC есть fixtures/gc_agent_branches/case_*
  ok   скрипт «freeze:contract» не в CI — объявленное исключение: команда записи: создаёт тег заморозки, в CI прогонять запись неправильно — для сверки есть check:contract-frozen
  ok   скрипт «check:skills-live» не в CI — объявленное исключение: предмет локальный: требует бинаря omp (sha256 по пину), в CI бинаря и пина нет — прогон вернул бы NOT_IMPLEMENTED; для структуры есть check:skills
  ok   скрипт «check:ci-gate» не в CI — объявленное исключение: гейт судит ЖИВОЙ прогон CI по запушенному HEAD: внутри CI текущий прогон не завершён (круг), исполняется вручную перед вызовом судей

workflow-команд: 27 · скриптов в приёмке: 44 · объявленных исключений: 17 · расхождений: 0

$ git config --local user.name
rc=1
stdout пуст

$ find fixtures/check_staged fixtures/check_hooks fixtures/spawn_agent fixtures/land_agent fixtures/gc_agent_branches -maxdepth 1 -name 'case_*.sh' | wc -l
rc=0
23

$ bash /home/aka/Documents/dev-harness/scripts/spawn_agent.sh --author implementer
# cwd=/tmp/reviewer016-spawn.U9Ph1v (toy main)
rc=0
WORKTREE=/tmp/dev-harness-worktrees/0e4d678a/wip-001-implementer
BRANCH=wip/001/implementer
# Затем: git worktree remove --force …; git branch -D wip/001/implementer; rm -rf toy — rc=0.
```

## Таймлайн

1. Прочитаны frozen-предмет, три critic verdicts, оба арбитража, четыре круга adversary
   (финальный accept `244e97f`) и релевантный HANDOFF.
2. Сверены границы v3 и история авторов механизма/fixtures; измерен факт дерева (23).
3. Выполнены две полные пробы, семь scoped-прогонов, зелёная и красная канарейки И-5,
   `check:hooks`, CI-parity, проверка отсутствия локальной identity и toy spawn с откатом.
4. Отдельный toy `/tmp` воспроизвёл R016-1. Scratch удален. Поэтому `done/contracts/016/1`
   ставить нельзя до механического отказа до merge на `WT_HEAD != tip_sha` и независимого
   зелёно-красного предъявления этого входа.
