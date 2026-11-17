accept
OBJECT=187775fc90f6468d50ff94b95376942498b99e00

# Review 198 — реализация, вызов 2 (скоупный исправительный, закрытие Рв198-1)

СУД: repo=dev-harness; предмет=198; фаза=реализация (контракт ЗАМОРОЖЕН `frozen/contracts/198/1`); роль=reviewer; вызов=2 (скоупный по блоку Рв198-1; СУД-запись оркестратора — HANDOFF state-WT `wip-011-orchestrator/HANDOFF.md:8`, `предмет=198 … вызов=2 … OBJECT=187775fc90…`); модель-план=config/agent_models.json reviewer → @opus; сессия=Rev198b; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev198b` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev198b	187775fc90f6468d50ff94b95376942498b99e00`, rc 0; дверь `bash scripts/check_sud_model.sh --verdict reviewer --trace <эта строка> --object 187775fc90… --session Rev198b --root .` → «СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется», rc 0); предыдущие=Rev198 FAIL (`90576b4465`, `verdicts/review/contracts-198-impl-v1.md`, OBJECT `4161233cd3`), Adv198 ACCEPT (`07de5b18`).

Повестка конечная (задание оркестратора): (1) Рв198-1 закрыт; (2) регресс батареи 198 и соседей на дереве main; (3) область правки `187775fc90`. Р1–Р4 не перепроверялись (приняты вызовом 1), другие предметы не судились.

## Дерево

Клон `/tmp/dev-harness-verify/Rev198b/repo` (origin `ssh://git@github.com/a3ka/dev-harness.git`, собственный `.git`), `git fetch origin main wip/198/architect`: origin/main = `90c4aa63c34247878d02fdd6827b5ee11a7eb9b3`, `origin/wip/198/architect` = OBJECT. Судимое дерево = origin/main + `git checkout origin/wip/198/architect -- fixtures/dokazatelstva_098/_mir.sh`.

- Реализация 198 уже в main: blob двери `scripts/check_sud_model.sh` на main = `f016be12710d…` == blob `aa0f0027f3` (вызов 1); `git diff --stat 34566df929 origin/main` по 4 файлам implementer + probe.py = ровно ремонт 198 (roles.ts +157, дверь 83, workshop 16, check_project_session 2, probe.py 16).
- `git diff --stat origin/main origin/wip/198/architect -- fixtures/dokazatelstva_098/` → только `_mir.sh | 5 +++++`: мир 098 на main байт-в-байт тот, что в `4161233cd3`; наложение ничего иного не затирает.
- Красные контроли — отдельные копии `cp -a` клона (не worktree): `red-noimpl` (судимое дерево, 4 файла implementer откачены `git checkout 34566df929 -- scripts/roles.ts scripts/check_sud_model.sh workshop scripts/check_project_session.sh`, blob двери `f0f1234f…`); `red-oldmir` (чистый origin/main, `_mir.sh` blob `bd211155…`); `red-noroles` (судимое дерево, `rm scripts/roles.ts`).

## 1. Рв198-1 — закрыт

ПРОИСХОЖДЕНИЕ: Rev198 вызов 1, блок Рв198-1. КЛАСС: регрессия замороженного guard 098. ОБЯЗАТЕЛЬСТВО: ПРОВОДКА 098 `guard=fixtures/_krasnye_098.sh` (frozen `098/1`: «rc 0 ⟺ все клетки зелёные ∧ стаб-пак пойман», замер 17 клеток) остаётся зелёным с реализацией 198. СОСТОЯНИЕ: закрыт. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: мир 098 ставит принятой стороне соседний `roles.ts` из того же каталога субъектов, что и дверь, — дверь 198 разрешает модель живым резолвером; отсутствие `roles.ts` по-прежнему красит клетки fail-closed.

НАБЛЮДЕНИЕ (гейты без ambient `GIT_AUTHOR_*/GIT_COMMITTER_*`, `env -u …`; `ls fixtures/dokazatelstva_098/red_*.sh | wc -l` = 17):

```
судимое дерево (main + _mir.sh OBJECT)   bash fixtures/_krasnye_098.sh <корень>
  стаб-пак: s1…s21 «ПОЙМАН», «ИТОГ стаб-пак 098: rc=0»
  17 строк «— red_*.sh: rc=0» (пересчитаны по выводу поимённо), «СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется» в каждой писательской клетке
  «ИТОГ 098: rc=0»                                                                    rc 0
red-oldmir (main, _mir.sh main)           17 × «rc=1», каждая: «Error: Cannot find module '…/prinyato/scripts/roles.ts'»
                                          + «ОТКАЗ: резолвер назначений отказал для роли critic (fail-closed, Н-270)»; стаб-пак rc 0
  «ИТОГ 098: rc=1»                                                                    rc 1   (блок воспроизведён)
red-noimpl (без реализации, _mir.sh OBJECT) стаб-пак 21/21, 17 × «rc=0», «ИТОГ 098: rc=0»       rc 0
red-noroles (реализация, _mir.sh OBJECT, roles.ts удалён)
                                          17 × «rc=1», та же причина MODULE_NOT_FOUND + «ОТКАЗ: резолвер назначений отказал…»; стаб-пак rc 0
  «ИТОГ 098: rc=1»                                                                    rc 1
```

Правка не маскирует отсутствие `roles.ts`:
- `git diff 4161233cd3 187775fc90` — +5 строк, ноль удалений: `if [ -f "$sd/roles.ts" ]; then cp "$sd/roles.ts" "$W/prinyato/scripts/" || d98_ni "установка резолвера назначений"; fi` после копирования четырёх субъектов (`_mir.sh:253–257`). Источник — тот же `$sd` (`_d98_sdir` = `${D98_SUBJECTS_DIR:-<корень>/scripts}`), что и у двери; заглушки, генерации, подмены содержимого нет; ошибка копирования → `d98_ni` rc 2, не молчание.
- Отсутствие файла в каталоге субъектов не подкладывает ничего: `red-noroles` — 17 красных именем резолвера (fail-closed двери, Н-270), не зелёный.
- Клетки, ожидания, раннер, стаб-пак 098 не тронуты (`git show 187775fc90 --stat` → `fixtures/dokazatelstva_098/_mir.sh | 5 +++++`, 1 файл). Стаб-пак 098 подставляет `D98_SUBJECTS_DIR` = копию честных jq-моделей `fixtures/dokazatelstva_098/model/` (`battery_stubs.sh:92`), где `roles.ts` нет (каталог: `accept_publish.sh check_ci_gate.sh check_sud_model.sh judge_gate.sh`), — ветвь `if` там не исполняется, поимки 21/21 прежние во всех четырёх прогонах.
- Без реализации (дверь `34566df929`, jq) скопированный `roles.ts` дверью не читается; 098 зелёный — правка мира от реализации не зависит.

## 2. Регресс батареи 198 и соседей — на судимом дереве

```
red_modeli_reestra_198.sh --repo .   17 строк CELL … OK, уникальных имён 12 (repo_door_judges ×6)   REPO_CELLS=12 FAILURES=0   rc 0
red_modeli_reestra_198.sh --model    33 строки CELL … OK; уникальных 28 (повторы: door_verdict_fallback_flow ×3,
                                     resolver_autofallback_toggle ×3, resolver_fallback_swap ×2 → 33−5)   CELLS=28 FAILURES=0   rc 0
red_modeli_reestra_198.sh --stabs    17 строк «STAB … ПОЙМАН (клетка …)»                       STABS=17 CAUGHT=17         rc 0
fixtures/_krasnye_104.sh <корень>    стаб-пак «17/17 поймано», 6 клеток ЗЕЛЕНО, «клеток просмотрено: 6», «ИТОГ 104: rc=0»   rc 0
sud_model_173 --repo <корень>        19 строк «173 … ZELENO»                                                                 rc 0
architecture_steward_186 --repo .    все строки «ok» (role…schedule, door, pin)                                              rc 0
architecture_steward_186 --model     все строки «ok»                                                                         rc 0
python3 fixtures/freeze_contract/fail_closed_992.py --model   «cases=25 observations=25 failures=0»                          rc 0
bash scripts/gen_ci_steps.sh --check                                                                                         rc 0
bash scripts/check_charter.sh        «уставных документов: 180 · изменений в них: 525 · с разрешения: 525»; 098 и 198 — «изменений без разрешения нет»   rc 0
```

Счёт 12/28/17 пересчитан мной по выводу поимённо (не по итоговой строке раннера).

## 3. Область правки `187775fc90`

- `git show 187775fc90 --stat` → ровно `fixtures/dokazatelstva_098/_mir.sh | 5 +++++`; родитель `4161233cd3`; author = committer = `architect <architect@dev-harness.local>`.
- Зона — живьём по замороженному блобу: `git show 'frozen/contracts/098/1^{commit}:contracts/098-proizvodstvennye-dokazatelstva-do-publikacii.md'` (тег 098 единственный — `frozen/contracts/098/1`, `ff51125845`), строка 99: `ЗОНА architect: contracts/098-… fixtures/dokazatelstva_098/ fixtures/_krasnye_098.sh NABLIUDENIA_ARCHITECT.md`. Файл — внутри `fixtures/dokazatelstva_098/` зоны architect; ПЕРЕСЕЧЕНИЯ 098 касаются только implementer-скриптов и NABLIUDENIA — не нарушены. Зона автора в `check_zones.sh` — объединение по всем замороженным контрактам (`check_zones.sh:1051`).
- Контракты не тронуты: `git diff --stat frozen/contracts/198/1 origin/wip/198/architect -- contracts/198-…` пуст; `contracts/098-…` между `frozen/contracts/098/1` и OBJECT не менялся (дельта `fixtures/_krasnye_098.sh` от тега — история main до 198, OBJECT её не трогает: `git diff --stat origin/main origin/wip/198/architect` по этому файлу пуст).
- `bash scripts/check_zones.sh` на detached-копии OBJECT (`/tmp/dev-harness-verify/Rev198b/zones`, HEAD `187775fc90`, без ambient `GIT_*`): «замороженных контрактов: 180 · объявленных авторов: 5 · коммитов в диапазонах: 64325 · проверено по зонам: 20556», ни одной строки «вне зоны», rc 0 (1155 с).

Выхода за зону нет.

## Остатки (контракт 192)

Скоупный вызов: остатки К-05/К-06/К-09 судились вызовом 1 (не укусили); дифф `187775fc90` не трогает дверь, `workshop` и `roles.ts`, поэтому их суждение не меняется.
ОСТАТОК: К-05 — не укусил: в диффе вызова 2 (`fixtures/dokazatelstva_098/_mir.sh:253–257`) нет кода шва; файл реестра читается только установочным `cp` конфига (прежний, `_mir.sh:260`), не дверью.
ОСТАТОК: К-06 — не укусил: дифф вызова 2 не вводит env-значений модели; `D98_SUBJECTS_DIR` — прежний источник каталога субъектов 098, не модели.
ОСТАТОК: К-09 — не укусил (проводка в процессе): шаг 198 на main теперь `--repo . && --stabs` (`registry/ci-steps.tsv:316`); `--model` шагом не подключён — прежний совет С-3 остаётся советом (не блок, вне повестки).

## Паразитная сложность (050)

- Ветвь `if [ -f "$sd/roles.ts" ]` в `_d98_podgotovka` (`_mir.sh:255–257`): (1) свойство — ПРОВОДКА 098 «guard зелёный ⟺ субъекты рабочие» при двери 198, зовущей соседний резолвер; (2) состояние — нет; файл берётся из явного `$sd`, ошибка — `d98_ni` с именем; (3) правка того же свойства — 1 файл (не выросло); (4) интерфейс не расширен (флагов/env нет); (5) потребитель — все 17 клеток 098 через `_d98_podgotovka`. Более простая форма — безусловный `cp` — сломала бы стаб-пак ([INFERENCE] по коду `battery_stubs.sh:92–94` и `_mir.sh:256`, не измерено): каталог моделей `fixtures/dokazatelstva_098/model/` `roles.ts` не несёт, `cp` дал бы `d98_ni` rc 2 и «поимку пустую» (А-398). ESSENTIAL.

## ПРОВОДКА (038)

Guard 098 `fixtures/_krasnye_098.sh` существует, исполняет предмет 098 (писатели/дверь), зелёный на судимом дереве. В CI шаг 098 не подключён (ПРОВОДКА-ЭНФОРСМЕНТ 098: «guard подключается в CI ТОЛЬКО ПОСЛЕ landing предмета») — регрессию такого рода ловит только суд; это не новость вызова 2.

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` dev-harness не объявляет документ архитектуры и стандарт кода (как в вызове 1; дифф вызова 2 — фикстура).
СВЕРКА-АРХИТЕКТУРЫ: не применимо — модели архитектуры 188 (`tooling/checks/cli.js`, `bindings.json`) в дереве dev-harness нет; размещение — мир 098 в своём каталоге фикстур; новых зависимостей продакшн-кода нет (зависимость двери → `roles.ts` введена реализацией 198 и судилась в вызове 1); писатели/операции не добавлены; diff модели — нет.

## Блоки

Нет.

## Советы

Новых нет. Советы С-1…С-3 вызова 1 (`.review/2026-11-17-102.md`) остаются советами, не блоками. Файл `.review/` для этого вызова не заводится: находок нет.

## Наблюдения

- Н-1: `_d98_missing` (`_mir.sh:40–47`) `roles.ts` не перечисляет — при отсутствии резолвера клетки красны именем резолвера («Cannot find module … ОТКАЗ: резолвер назначений отказал…»), а не фразой «предмет отсутствует». `roles.ts` не субъект 098 (субъекты — `judge_gate/check_ci_gate/accept_publish` + дверь по 104), отказ именованный и fail-closed — не находка.
- Н-2: `fail_closed_992.py --model` печатает `cases=25` при замере контракта 992 «24» — рост батареи после заморозки 992, вне повестки; rc 0, failures=0.

## Развилки

Нет: повестка конечна, по каждому пункту есть измерение.

## Не проверено

- Р1–Р4 реализации повторно не судились (приняты вызовом 1; блобы реализации в main совпадают с судимыми тогда).
- Удалённый CI не запускался; полный набор шагов `registry/ci-steps.tsv` не прогонялся — только перечисленные в повестке.
- Живой `workshop --fable` на станции не запускался (как в вызове 1).
