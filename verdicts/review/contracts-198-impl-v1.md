FAIL
OBJECT=4161233cd32a2970fd2dd7f21519a065d62f7bb0

# Review 198 — реализация, вызов 1 (последний судья)

СУД: repo=dev-harness; предмет=198; фаза=реализация (контракт ЗАМОРОЖЕН `frozen/contracts/198/1`, дифф контракта от тега до origin/main и до OBJECT пуст); роль=reviewer; вызов=1 (полный); модель-план=config/agent_models.json reviewer → audit → anthropic/claude-opus-5-5; сессия=Rev198; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev198` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev198	4161233cd32a2970fd2dd7f21519a065d62f7bb0`, rc 0; дверь `check_sud_model.sh --verdict reviewer --trace … --object 4161233c… --session Rev198 --root .` → «СУДЬЯ СВОЕЙ МОДЕЛИ», rc 0); OBJECT=4161233cd32a2970fd2dd7f21519a065d62f7bb0 (tip `wip/198/architect`, `Arch198Fix1`); реализация=`Impl198` aa0f0027f319ffababbaf0761d6af953636d4dd1 (`wip/198/implementer`, на origin НЕ опубликована — читалась из основного чекаута `git archive`); предыдущие=`Adv198` accept (`wip/198/adversary-impl1` 07de5b18); исключение=нет. СУД-запись оркестратора найдена: HANDOFF ведущей сессии, строка 4 (`предмет=198; … роль=reviewer`), SHA совпадает.

Находки reslop — `.review/2026-11-17-102.md` (status: ready).

## Дерево

Клон `/tmp/dev-harness-verify/Rev198/repo` (origin `ssh://git@github.com/a3ka/dev-harness.git`), ветка `wip/198/reviewer-impl1` от origin/main `34566df929`. Судимое дерево = origin/main + 4 файла `aa0f0027f3` (`git -C /home/harness/dev-harness archive aa0f0027f3 <4 файла> | tar -x`) + `probe.py` из OBJECT (`git checkout origin/wip/198/architect -- …/probe.py`). База реализации `628312d6f1` — предок origin/main; `git diff --stat 628312d6f1 34566df929 -- <4 файла> fixtures/…_198/` пуст — наложение ничего не затирает. Blob по `git hash-object` = blob источника:

```
scripts/roles.ts                 8b9e56a779d82e424e92c7e498529bc4b3056655 == aa0f0027f3
scripts/check_sud_model.sh       f016be12710d85d9ca5714cd3f23f657e0d855d0 == aa0f0027f3
workshop                         f8af66b3078abbd7f46b3c4337071c37db91da73 == aa0f0027f3
scripts/check_project_session.sh 2b8cae0cedb4d49c3227e9e6185c95873c09d961 == aa0f0027f3
…_198/probe.py                   fa37c3d337742978f10ca8eac45c2d59ea22df1e == 4161233cd3
```

Красные контроли — отдельными копиями `cp -a` того же клона (`red-main` = чистый origin/main; `red-noprobefix` = реализация без ремонта probe.py), не worktree.

## 1. Область правки — соответствует

- `git show --name-only aa0f0027f3` → ровно `scripts/check_project_session.sh scripts/check_sud_model.sh scripts/roles.ts workshop` = ЗОНА implementer (контракт :184). Автор и коммиттер — `implementer/implementer@dev-harness.local`. `check_charter`, фикстуры, контракт не тронуты.
- `git show --name-only 4161233cd3` → только `fixtures/workshop_project/modeli_tolko_v_reestre_198/probe.py` (ЗОНА architect). Автор/коммиттер `architect`.
- `workshop`: дифф — блок `--fable` (источник LIVE_MODEL) и комментарий флага `--fable` (:521–522); прочих блоков нет (ПЕРЕСЕЧЕНИЯ 002…996 соблюдены). Текст промпта режима (`printf '\n\n# РЕЖИМ КОНСУЛЬТАНТА (--fable)…`) и `TOOLS="read,grep,glob,bash,web_search,task,todo"` не изменены.
- `check_project_session.sh`: одна строка, литерал `ZAGOLOVOK_PRAVIL`; перечень полей/порядок/rc не тронуты.

## 2. Сырой вывод — перепрогнано мной на судимом дереве

Гейты без ambient `GIT_AUTHOR_*/GIT_COMMITTER_*` (`env -u …`).

```
bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --repo .
  … 17 строк CELL … OK (repo_door_judges ×6), уникальных имён 12
  REPO_CELLS=12 FAILURES=0                       rc 0
… --model
  32 строки CELL … OK, уникальных имён 28 (пересчитаны по выводу вручную)
  CELLS=28 FAILURES=0                            rc 0
… --stabs
  17 строк «STAB … ПОЙМАН (клетка …)»
  STABS=17 CAUGHT=17                             rc 0
bash fixtures/_krasnye_104.sh <корень>   → «клеток просмотрено: 6», «ИТОГ 104: rc=0»   rc 0
bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo <корень> → 19 строк «173 … ZELENO»   rc 0
bash scripts/gen_ci_steps.sh --check                                           rc 0
bash scripts/check_charter.sh → «уставных документов: 180 · изменений в них: 521 · с разрешения: 521»   rc 0
bash -n scripts/check_sud_model.sh / workshop / scripts/check_project_session.sh   rc 0 / 0 / 0
```

Красное по построению:

```
red-main (чистый origin/main, probe.py main):  --model  CELLS=28 FAILURES=28 rc 1
                                               --repo . REPO_CELLS=12 FAILURES=23 rc 1
red-main + probe.py OBJECT:                    --model  CELLS=28 FAILURES=27 rc 1   (door_* все OK)
red-noprobefix (реализация, probe.py main):    --model  CELLS=28 FAILURES=1  rc 1   (door_spawn_foreign_refused: «rc=0 stderr=''»)
```

28/28 на чистом main против 27 в замере контракта — разница ровно клетка `door_spawn_foreign_refused`, красная и без реализации: реестр сменён owner-PR #1000 (critic и adversary оба `openai-codex/gpt-6.1-terra`, живой резолв ниже). Это подтверждает основание ремонта `Arch198Fix1`.

## 3. Р1–Р4 по тексту и живьём

- **Р1** `resolveRoleModel(am, role)` (roles.ts:302–319): роль → тир → модель/фолбек/autoFallback; `@семейство` разбирает только существующий `resolveModelRef` (через `resolveTierModel`, roles.ts:278, второго разбора нет). CLI `--resolve-model <роль> [--root <кат>]` (`resolveModelCli`, :345) печатает `тир\tмодель\tфолбек|-\ttrue|false`. Отказы: ROLE_UNKNOWN/TIER_MISSING/ALIAS_UNRESOLVED/MODEL_EMPTY → rc 1, REGISTRY_MISSING/REGISTRY_INVALID → rc 2 (`RoleModelError.rc`). Молчаливого дефолта нет. Чтения `process.env`/`ppid` в roles.ts нет (grep пуст). CLI живёт только при прямом запуске (`isDirectRun`, :453, realpath) — импорт генератором его не включает; других прямых запусков `node …roles.ts` в дереве, кроме workshop/двери/батареи, нет (grep).
  Живьём: critic `apex-sol	openai-codex/gpt-6.1-terra	zai/glm-5.3	true`; adversary `advisor	openai-codex/gpt-6.1-terra	openai-codex/gpt-6.1-sol	false`; reviewer `audit	anthropic/claude-opus-5-5	openai-codex/gpt-6.1-sol	false`; arbiter `plan	openai-codex/gpt-6-astra	anthropic/claude-fable-5-2	true`; consultant `consultant	openai-codex/gpt-6.1-sol	openai-codex/gpt-6-astra	false`; все rc 0. `nosuch` → `ОТКАЗ: ROLE_UNKNOWN` rc 1; `--root` несуществующий → `ОТКАЗ: REGISTRY_MISSING` rc 2; без роли / голый вызов → usage rc 2.
- **Р2** дверь: строка `jq` в файле двери не встречается вовсе (grep пуст; проверка наличия jq заменена проверкой node), имя файла реестра — только в комментариях (:8, :36); ожидание = `cut -f1/2/3` одной TSV-строки резолвера (:184–205); `tsv_rc≠0` или пустой ответ → rc 2 (`set -uo pipefail` без `-e` — rc захватывается, не теряется). `tier/expected/fbexpected` присваиваются безусловно из TSV — env-источника нет. Живьём: `--spawn critic openai-codex/gpt-6.1-terra` rc 0; `--spawn critic zai/glm-5.3` (фолбек на спавне) rc 1 «модель не тира роли»; `--spawn critic anthropic/claude-opus-5-5` rc 1; `--spawn critic gpt-6.1-terra` (без префикса, 173) rc 0; `--frontmatter critic` rc 0; реестр без роли → «ОТКАЗ: ROLE_UNKNOWN…» + «резолвер назначений отказал…» rc 2.
- **Р3** `workshop --fable` (:637–652): `FABLE_MODEL="$(node "$HERE/scripts/roles.ts" --resolve-model consultant --root "$HERE")" || die …`; `LIVE_MODEL="$(… | cut -f2)"`; пустое → `die`. Оба `die` стоят до `exec omp` (:669). Писатели LIVE_MODEL в файле — только :230 (`session_model`, путь не-fable) и :644; между :644 и exec переприсваивания нет (`prepare_model_trace` его не пишет). Env-приоритета нет. Значений реестра (`"fable"`, иды) в блоке нет.
- **Р4** `ZAGOLOVOK_PRAVIL = "## Правила, каждое из которых уже стоило времени"` == `AGENTS.md:216` == `gen-harness.ts:187` (сверено `sed -n`).

## 4. Проверка не подогнана под код

- Implementer фикстур/батареи не трогал (п.1). Единственная правка проверки после freeze — `4161233cd3` architect'ом, по коду (Н-39): клетка `door_spawn_foreign_refused` берёт «чужую» модель вычислением из реестра мира (`primary_of` судей ≠ critic, вне `{primary, fallback}` критика; в мире — reviewer), при пустом множестве — именованная КРАСНАЯ «реестр изменился: нет чужой модели», не rc 0.
- Ремонт не ослабляет клетку: требование «rc 1 и 'не тира роли'» прежнее; прежний литерал роли adversary после #1000 стал СОБСТВЕННОЙ моделью критика, и клетка требовала отвергнуть назначенную модель вопреки 104 (модель, разделяемая ролями, принимается). Красная без реализации (red-main: rc 0 на «чужой», т.е. собственной) — клетка падала не из-за кода реализации. Стаб `decoy_door_always_ok.sh` ловится именно этой клеткой (`--stabs` выше). Адверсарий отдельно показал красную «реестр изменился» при совпадении всех primary.
- Стабы привязаны кодом `STAB_BIND` probe.py; счёт 17/17 — вывод `--stabs` (выше).

## 5. Остатки

Нумерация К-NN — по порядку пунктов «НЕ ЗАЩИЩАЕТ» контракта 198 (номеров контракт не несёт); ниже — пункты с ловцом reviewer, проверены первыми.

ОСТАТОК: К-05 — не укусил: маскировка имени реестра/значений в коде шва — в диффе двери (`scripts/check_sud_model.sh:184–205`) и блока `--fable` (`workshop:637–652`) нет ни чтения файлов, ни конкатенаций/глобов имени: единственный источник — вызов `roles.ts --resolve-model`.
ОСТАТОК: К-06 — не укусил: env-ЗНАЧЕНИЕ приоритетом над резолвером (N6) — источники присваивания: дверь `tsv`/`tier`/`expected`/`fbexpected` (:190–205) безусловно из вывода резолвера; workshop `FABLE_MODEL`/`LIVE_MODEL` (:642–644) безусловно из резолвера, `${…:-}`-подстановок нет; roles.ts `process.env` не читает.
ОСТАТОК: К-09 — не укусил (проводка в процессе): в main сегодня шаг 198 только `--stabs` (`registry/ci-steps.tsv:316`); `--model` и `--repo .` обязан внести носитель с CI вместе с реализацией (зона orchestrator) — совет С-3.

Литеральный id тира: резолвер пропускает `tiers.<t>.model` без `@` как есть (проверено: тир `{"model":"p/literal"}` → `lit	p/literal	-	false` rc 0); прежняя дверь отказывала такому тиру rc 2. Это прямо предписано Р1 контракта («литеральный id тира (без `@`) проходит как есть»), 104 такого отказа обязательством не несёт (104:10 описывает цепочку, не запрет литерала), 104/173 зелёны — не блок, не остаток; наблюдение Н-2 (клетки, пинящей литерал, нет).

## 6. Соседи

```
fixtures/pravila_modelei_998/probe.sh            «census matrix: исполнено 67, расхождений 0»  rc 0
architecture_steward_186 --repo . / --model      rc 0 / rc 0
node scripts/gen-harness.ts --check              «харнес соответствует roles/ (13 ролей)»        rc 0
fixtures/workshop_project/sessii_125/red_sessii_125.sh  «зелёных 70, красных 0»                  rc 0
fixtures/_krasnye_098.sh <корень>                РЕАЛИЗАЦИЯ: 17 клеток rc=1, «ИТОГ 098: rc=1»   rc 1
                                                 red-main:   «ИТОГ 098: rc=0»                    rc 0
```

## Блок

**Рв198-1 (регрессия замороженного guard 098; доказано).** С реализацией 198 guard контракта 098 (`fixtures/_krasnye_098.sh`, ПРОВОДКА 098 `guard=`, frozen `098/1`) из зелёного на origin/main (`ИТОГ 098: rc=0`) становится красным на всех 17 клетках (`ИТОГ 098: rc=1`; стаб-пак rc 0). Причина — дифф 198: дверь теперь зовёт `node "$SELF_DIR/roles.ts"` (`scripts/check_sud_model.sh:190`), а мир 098 ставит принятой стороне только `judge_gate.sh check_ci_gate.sh accept_publish.sh check_sud_model.sh` (`fixtures/dokazatelstva_098/_mir.sh:251`) без `roles.ts`. Сырой вывод клетки `red_polnyj_zhurnal_shtatno.sh`:

```
Error: Cannot find module '/tmp/dev-harness-verify/dokazatelstva-098-polnyj-247436-13244/prinyato/scripts/roles.ts'
ОТКАЗ: резолвер назначений отказал для роли critic (fail-closed, Н-270)
КРАСНО: polnyj-zhurnal: писатель отказал (строки не записаны)
RC_CELL=1
```

Более простая форма, проходящая обе приёмки, измерена: тот же прогон с доставкой `roles.ts` в `prinyato/scripts/` (экспортированная обёртка `cp` в оболочке прогона, файлы не правились) → 17 клеток rc=0, `ИТОГ 098: rc=0`; батарея 198 при этом не затрагивается. Шаг 098 в `registry/ci-steps.tsv` не подключён (подключение — после ленда 098), поэтому CI этого не поймает: ловит только суд. Производственный путь (`judge_gate.sh` → соседний `check_sud_model.sh` → соседний `roles.ts`) не сломан — сломан замороженный барьер 098, он перестаёт что-либо свидетельствовать.

Корень — контрактный: перечень потребителей двери в «Существующее 5/8» и ПЕРЕСЕЧЕНИЯ 198 (099/104/173) не называют мир 098, который копирует дверь поштучно. Ремонт — вне зон 198 (`fixtures/dokazatelstva_098/_mir.sh` — зона 098), решение маршрута за оркестратором (Развилка 1): правка мира 098 (добавить `roles.ts` к установке субъектов и, при желании, к `_d98_missing`) её владельцем до ленда 198 либо v+1 198 с ПЕРЕСЕЧЕНИЕМ 098. Реализация 198 сама по себе при этом не меняется.

## Советы (не блокируют) — в `.review/2026-11-17-102.md`

- С-1 (implementer 198, следующая правка roles.ts): тир со значением `null`/не-объект (`"tiers":{"t":null}`) → неименованный `TypeError` node (`roles.ts:313 spec.model`), rc 1 без имени отказа; дверь всё равно fail-closed rc 2. Вход неконформен по демаркации 198 — не блок; простая форма — `typeof spec !== 'object' || spec === null` → TIER_MISSING.
- С-2 (architect 198 v+1): `fallback: 5` даёт MODEL_EMPTY «не объявлена» — имя отказа неточно для не-строки; косметика.
- С-3 (orchestrator, носитель CI): добавить `--model` и `--repo .` шагами 198 (ПРОВОДКА-ЭНФОРСМЕНТ, РЕШЕНИЕ 5 арбитража 198-1); сегодня только `--stabs`.

## Наблюдения

- Н-1: замер контракта «на main `--model` 28/27» сегодня 28/28 с probe.py main и 28/27 с probe.py OBJECT — расхождение объяснено #1000, не дефект.
- Н-2: литеральный тир пропускается по Р1; клетки, пинящей это поведение, в батарее 198 нет.
- Н-3: ветка `wip/198/implementer` на origin отсутствует (`git ls-remote` — только architect/critic-v1/critic-v2); реализация судима по blob из основного чекаута, blob сверены.

## Паразитная сложность (050)

- `RoleModelError`/`RoleModelRefusal`/`RoleModel` (roles.ts:234–262): (1) Р1 именованные отказы с rc 1/2; (2) состояние — нет, имя и rc явны в выводе `ОТКАЗ: <код>`; (3) правка свойства — 1 файл; (4) интерфейс 6 кодов ⇔ 6 отказов контракта — глубина соответствует; (5) потребитель — клетки resolver_* и дверь. ESSENTIAL.
- `resolveRoleModel` + `resolveTierModel`: (1) Р1; (2) нет; (3) 1 файл, разбор `@` переиспользует `resolveModelRef`; (4) 2 аргумента → весь резолв; (5) CLI/дверь/workshop, повтора грамматики нет. ESSENTIAL.
- `readAgentModels(root)` (:324): (1) Р1 `--root` + REGISTRY_MISSING/INVALID rc 2; (2) нет; (3) рядом живёт `agentModels()` (ленивый, терпимый к отсутствию — `null`), семантики противоположны (терпимость нужна фикстурам анти-плацебо, fail-closed — резолверу), путь `config/agent_models.json` теперь назван в двух функциях одного модуля; (4) мелкий, но оправдан; (5) потребитель — CLI. ESSENTIAL (более простая форма через `agentModels()` не даёт REGISTRY_MISSING и `--root`).
- `resolveModelCli` + `isDirectRun`: (1) Р1 CLI; (2) нет; (3) 1 файл; (4) argv → rc; `isDirectRun` нужен, т.к. roles.ts импортируется генератором; (5) дверь, workshop, батарея. ESSENTIAL.
- Дверь `check_sud_model.sh`: jq и пять веток отказа заменены одним вызовом (`git diff --numstat` +30/−53) — сложность уменьшилась. Новая зависимость двери от соседнего `roles.ts` — источник Рв198-1.
- workshop `FABLE_MODEL`: промежуточная переменная ради `|| die` до `cut` — явная, локальная. ESSENTIAL.

## ПРОВОДКА (038)

`guard=fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh` существует, исполняет предмет (резолвер/дверь/шов/опечатку), не чужой скрипт; подключён в CI (`ci-steps.tsv:316`, `--stabs`). Норма механизма, не поведенческая роль-норма — guard-only с ПРОВОДКА-ЭНФОРСМЕНТ обоснован. `--model`/`--repo .` в CI — С-3.

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` dev-harness не объявляет документ архитектуры и стандарт кода (`grep -n 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` пуст).
СВЕРКА-АРХИТЕКТУРЫ: не применимо — модели архитектуры 188 (`tooling/checks/cli.js`, `bindings.json`) в дереве нет; размещение — резолвер в существующем модуле `scripts/roles.ts` (единый разбор), новые зависимости: дверь → roles.ts (node) — именно она дала Рв198-1; писатели/операции не добавлены; diff модели — нет.

## Развилки

1. Маршрут ремонта Рв198-1 — вне зон 198. Консервативно: FAIL до зелёного `_krasnye_098` на судимом дереве; форма ремонта (правка мира 098 владельцем 098 или v+1 198 с ПЕРЕСЕЧЕНИЕМ) — решение оркестратора. Повторный суд — scoped: `_krasnye_098` + батарея 198 (`--repo . / --model / --stabs`) на новом OBJECT.

## Не проверено

- Живой `workshop --fable` на станции (exec omp) не запускался; путь отказа и exec стаб-omp проверены клеткой `repo_seam_fable_failclosed_resolver` (OK выше).
- Удалённый CI не запускался; полный набор шагов `ci-steps.tsv` не прогонялся — только перечисленные соседи двери/roles.ts/check_project_session.
