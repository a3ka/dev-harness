FAIL
OBJECT=834745ed88fbc39d019b02bd068ad8cf5fa71cca
КЛАСС=кодовый; риск=обычный (подтверждён: двери процесса — байт-структура строки, путь/компонент, check-rc, pin, check-run; права/авторизация/деньги/ПД не меняются)
СУД: repo=dev-harness; предмет=187 (187а: двери и скрипты архитектуры в процессе станции); фаза=реализация; роль=reviewer; вызов=1/1; модель-план=anthropic/claude-opus-5-5; сессия=Rev187v1; модель-факт=anthropic/claude-opus-5-5; OBJECT=834745ed88fbc39d019b02bd068ad8cf5fa71cca; предыдущий=verdicts/critic/contracts-187-v1.md; исключение=нет

# Вердикт ревьюера — 187а, суд реализации, вызов 1/1

Контракт: `frozen/contracts/187/1` (тег `514df4b1` → коммит `52d3a3a1`); `contracts/187-arhitektura-v-processe.md` на OBJECT побайтно равен замороженному (`git diff 52d3a3a1:… OBJECT:…` — 0 строк).
Кандидат: `origin/wip/187/implementer` = `834745ed88fbc39d019b02bd068ad8cf5fa71cca` (`git rev-parse` в одноразовом SSH-клоне совпал с OBJECT). PR-дерево: `origin/wip/187/orchestrator` = `7c4c180fcbd9a63a169456969a0c8b3b1b6c48c8` (те же 6 коммитов cherry-pick + коммит проводки CI). База: `origin/main` = `2c50cbee91b38b2cc6fe147da151c16b252ed74a`; merge-base OBJECT ↔ main = `ab2eefb4` (main ушёл на 29 коммитов, из них в `scripts/` только новый `orch_plan_slice.sh` — пересечения с диффом нет).
Независимость: все 6 коммитов OBJECT — `user.name=implementer` (MiniMax-M3 по паку); судья — Anthropic Opus, другое семейство.

## Итог

FAIL. Три блокирующие находки: Р187-Б1 (`check --base` без утверждённого снимка), Р187-Б2 (done сверяет check-run не того SHA, на который ставит тег), Р187-Б3 (ARCH_DRAFT пропускает операцию, явно помеченную DRAFT). Каждая находка закреплена воспроизводимым прогоном ниже. Батарея 187 зелёная 30/30, стабы 27/27, регресса в затронутых frozen-батареях нет. Но обе части зелёного — проверки на toy-модели, которая все три дефекта не различает (см. С1).

## Находки (reslop; status: ready)

---
status: ready
---

- [ ] **Р187-Б1 — БЛОК (обязательство pre_critic «против утверждённого снимка»).** Фрагмент: `scripts/check_architecture_contract.sh:187` — `node tooling/checks/cli.js check --base 2>/dev/null`. У `--base` нет операнда, `--base-digest` не передаётся, утверждённый снимок дверь не называет вовсе. Источник: контракт 187/1 §Предмет, абзац pre_critic: «запускает `check --base` закреплённой модели против утверждённого снимка». Бэкенд-контракт 167 (`/home/harness/projects/Complior-back/.harness/contracts/167-architecture-pin-hard-gate.md:17`) задаёт форму `check --base ... --base-digest ...`, его lock несёт `snapshotDigest`. Наблюдение: живой CLI модели бэкенда (`architecture/checks/cli.js` 2.4.2 из `origin/main` Complior-back, выгружен `git archive`, после `npm ci`) на `check --base` без значения выходит rc 1 с `MISSING_OPTION_VALUE: A value is required for --base`. Со значением (`--base baseline/approved.json`) — rc 2 `NOT_EVALUATED`. Мой toy-мутант M8 (модель требует операнд у `--base`) на OBJECT даёт `pre_critic.sh` rc 1 с `ARCH_CHECK: check --base модели красный (rc=1)`. Значит, ошибку входа инструмента дверь выдаёт судье за «модель красная», и для любого реального backend-предмета нога pre_critic красна всегда. Более простая форма, проходящая те же строки приёмки: передать снимок и digest (`--base <снимок> --base-digest <snapshotDigest из lock>`). Toy-CLI фикстуры аргументы игнорирует: прогон этой формы дал 30/30, а M8 стал зелёным (см. ниже).
- [ ] **Р187-Б2 — БЛОК (обязательство done «по ЭТОМУ SHA»; модель угроз «от done по зелёному чужого SHA»).** Фрагмент: `scripts/done_contract.sh:220-221` берёт SHA из `refs/remotes/origin/main` (без fetch), к `HEAD` переходит только при его отсутствии. Тег ставится на `HEAD` (`done_contract.sh:324`). Наблюдение, мутант M9: toy-backend после push получает локальный коммит, правящий `app/identity/model.js`; успешный check-run `arch` есть только на старом `origin/main`. Итог: `done_contract.sh` rc 0, тег `done/contracts/777/1` стоит на `HEAD` (`tag_on_HEAD=True`), хотя у этого SHA check-run `arch` нет (`checked_sha_is_old=True`). Тот же исход даёт отставший tracking-ref. Оракул фикстуры (`workflow_probe.py`, ветка `done`) сверяет с `git rev-parse HEAD`: реализация расходится с ним на непредъявленном входе. Более простая форма, проходящая те же строки: судить check-run по SHA, который получает тег (`HEAD`), либо отказывать `ARCH_CI` при `HEAD ≠ origin/main`. Прогон формы «SHA = HEAD» дал 30/30, а M9 — rc 1 `ARCH_CI` без тега (см. ниже).
- [ ] **Р187-Б3 — БЛОК (обязательство freeze «операция … не DRAFT, иначе ARCH_DRAFT»; модель угроз «от заморозки … DRAFT»).** Фрагмент: `scripts/check_architecture_contract.sh:327` (`draft|*.draft` по id) и `:333` (`*" DRAFT "*`, только токен в пробелах). Наблюдение (мутанты на OBJECT, `freeze_contract.sh` публичной дверью): M1 `ОПЕРАЦИЯ: identity.lookup (DRAFT); вход schema.query; выход schema.record` → rc 0, создан тег `frozen/contracts/777/1`. M2 `вход schema.draft` → rc 0, создан тег `frozen/contracts/777/1`. Контроль M3 (`identity.draft`, литерал клетки `freeze-draft`) → rc 1 `ARCH_DRAFT`. Дверь проходит клетку и при этом принимает операцию, явно помеченную DRAFT, — та самая мутация «проходит клетку, принимает DRAFT». Более простая форма: токен `draft` без учёта регистра на границе слова в id и обеих схемах. Прогон этой формы дал 30/30, M1 и M2 стали красными `ARCH_DRAFT` (см. ниже).

Советы и маршрут к architect (не блокируют этот дифф сами по себе, но достижимы при cutover 167):

- [ ] **С1 — фикстура (architect, v+1): «конформная грамматика CLI» toy-модели с реальным CLI не совпадает.** Приёмка 187/1 утверждает конформность, наблюдение её опровергает. (а) Реальный `locate --path app/application/session/x.js` печатает многострочный JSON (`{"scope":…,"status":"DECLARED","matches":[{"components":["api.identity"]…}]}`, rc 0). `arch187_locate` (`check_architecture_contract.sh:160`) берёт первую строку. Мутант M7 (toy-locate печатает JSON той же формы) → freeze rc 1 `ARCH_ZONE: путь app/identity/model.js отнесён моделью к компоненту {`. (б) Реальный CLI требует npm-зависимостей (`acorn`, `metaschema`, `ajv`, `yaml`). Дерево из `git archive` (`:122`) их не содержит: мой `git archive`-экспорт дал `MODULE_NOT_FOUND`, rc 1 на `locate` и `check`. (в) Реальный `locate server/src/auth/x.js` отвечает `DECLARED`, а не `PATH_WITHOUT_COMPONENT`, как ждёт спецификация В2. [INFERENCE] Грамматика закреплённого `CompliorOS-architecture/tooling/checks/cli.js` в станции не наблюдалась (клона нет). Наблюдён CLI локальной копии бэкенда и текст бэкенд-167. Пока toy не повторяет реальный вывод, зелёное 30/30 не доказывает работу дверей на закреплённой модели.
- [ ] **С2 — маркер (implementer + architect).** `check_architecture_contract.sh:296`: путь, который модель не разместила, но который существует в продукте, получает `ARCH_ZONE`, хотя контракт §Предмет говорит «неразмещённый путь — `PATH_WITHOUT_COMPONENT`». M4 (существующий `server/src/auth/x.js`) → `ARCH_ZONE … размещён в продукте, но модель не относит его к заявленному компоненту`. M5 (тот же путь, файла нет) → `PATH_WITHOUT_COMPONENT`. Отказ остаётся отказом, но причина неверна. Эвристика «существует на диске» подогнана под клетку `freeze-foreign`: toy-locate не умеет вернуть чужой компонент, и честная реализация была бы на ней красной. Корень — фикстура.
- [ ] **С3 — новое требование вне контракта.** `check_architecture_contract.sh:361`: backend-кодовый контракт без строки `ОПЕРАЦИЯ:` получает отказ `ARCH_DRAFT: предмет не объявляет операцию` (M6 → rc 1). Контракт говорит о «требуемой операции», но не обязывает каждый кодовый предмет объявлять операцию (рефакторинг, инфраструктура). Грамматику строки задаёт фикстура architect; обязательность — решение реализации. Вопрос к architect/владельцу.
- [ ] **С4 — паразитная сложность.** `check_architecture_contract.sh:98` читает из `architecture.lock.json` поле `.clone`, которого нет ни в 187/1, ни в формате lock бэкенд-167 (`format/repository/commit/snapshot/status/snapshotDigest/workItem`). Потребителя в строках приёмки нет: ACCIDENTAL. Более простая форма — только `ARCHITECTURE_ROOT`, проходит те же 30 клеток.
- [ ] **С5 — устойчивость done.** `done_contract.sh:239`: `curl` без `--max-time`, так что зависший API вешает done. `per_page=100` без пагинации отказывает закрыто. Достаточно ЛЮБОГО успешного `arch` на SHA: перезапуск, ставший красным после зелёного, не учитывается. Оракул фикстуры судит последний run (`arch_runs[-1]`).
- [ ] **С6 — покрытие полного режима двери.** CLI без `--model-only` (строка + зоны + операции + check) ни одна клетка не исполняет. CI-шаг `check:architecture-door-187` на корне харнесса всегда печатает `ARCH_187A_SKIP` и rc 0: у харнесса нет backend-профиля, так что как барьер этот шаг ничего не ловит. Он требуется самим контрактом (ПРОВОДКА/приёмка), это не дефект реализации. Моя ручная проверка M10 (полный режим, DRAFT) → rc 1 `ARCH_DRAFT`, ветка работает. Сужение id: `*..*` (`:236`) отвергает конформный по грамматике 187/1 id вида `a..b`.

## Что проверено и чем (сырой вывод)

**1. Область правки.** `git diff --stat origin/main...OBJECT`: ровно 5 файлов ЗОНЫ implementer (`check_architecture_contract.sh` +466 новый, `done_contract.sh` +78, `freeze_contract.sh` +23, `make_task.sh` +76/−11, `pre_critic.sh` +18). Сверх диффа реализации PR-дерево `origin/main...orchestrator` меняет только `registry/ci-steps.tsv` (+2 строки 187), `registry/ci-zamery.tsv` (+2 строки 187) и `.github/workflows/ci.yml` (перегенерированный блок lane, `gen_ci_steps.sh --check` rc 0) — всё это ЗОНА orchestrator. Чужие нормы и ветви не тронуты. В `make_task.sh` прежняя npm-ветка 170 перенесена под `else` без изменения байтов вызова. Остальные двери вооружаются только при `arch187_scope` (repoId=Complior-back и `architecture.lock.json`) и кодовом классе, иначе путь не меняется: legacy-mob/legacy-harness зелёные, 170 25/25 до и после.
**2. Подгонка проверок.** `git log -- fixtures/workshop_project/architecture_process_187` — только `architect` (4 коммита). `git diff 52d3a3a1 OBJECT -- fixtures/…187 contracts/187…` пуст. Фикстуры и контракт реализацией не менялись. Обратная подгонка (реализации под toy) есть — см. С2, Б3.
**3. Атомарность.** 6 коммитов `187a: …` по одному на дверь плюс шов и укрепление. Последний коммит (`834745ed`) возвращает фразу `замораживается только` к main (нетто-дифф по этой строке 0) и меняет `--repo "$REPO_ARG"` на `--repo "$BASE"` в pre_critic.
**4. Норма.** Нормативные документы (`roles/`, `AGENTS.md`, `contracts/`) в диффе отсутствуют.
**5. НЕ БАРЬЕР.** Шапка (`:45`) — первый непрерывный блок комментариев. `classify` в `verify_antiplacebo.sh:164-166` даёт `p`: строки «Коды возврата:» нет, «ВОЗВРАТЫ ДВЕРИ» маркером не является. Основание совпадает с прецедентами субъекта батареи (`dovodka_ui.sh`, `check_pustoj_produkt.sh`, `check_precision_gate.sh`, `check_no_leak.sh`): красное покрытие идёт семьёй 187 через публичные двери. Принимаю, с оговоркой С6.
**6. СВЕРКА-СТАНДАРТОВ:** не применимо — `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`grep` пуст).
**7. Свои счёты (мера своей командой).** `wc -l scripts/check_architecture_contract.sh` = 466 (заявлено 466). Строки `GREEN` батареи на OBJECT посчитаны awk: 30. Строки `STAB … caught` — 27, `ZHIV` — 0. Заявление задания `CELLS=30 GREEN=30` по формату неверно: скрипт печатает `CELLS=30 STABS=0 FAILURES=0`, поля `GREEN=` в выводе нет. По существу заявление подтверждено.

```
$ bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo <obj=834745ed>
GREEN task-valid … GREEN wiring-direct-missing   (30 строк GREEN)
CELLS=30 STABS=0 FAILURES=0
RC=0
$ … --repo <base=origin/main 2c50cbee>
RED ×20 (task-*, brief-*, freeze-no-line/foreign/unmapped/draft, check-failure/not-evaluated, done-review-missing, done-ci-*), GREEN ×10
CELLS=30 STABS=0 FAILURES=20
RC=1
$ … --model                → CELLS=30 STABS=0 FAILURES=0   RC_MODEL=0
$ … --stabs | awk          → CELLS=30 STABS=27 FAILURES=0 / STAB_LINES=27 CAUGHT=27 ZHIV=0 GREEN_CELLS=30   RC_STABS=0
PR-дерево 7c4c180f:
$ … --wiring .             RC_WIRING=0
$ bash scripts/gen_ci_steps.sh --check            RC_GEN=0
$ bash scripts/check_provodka.sh . contracts/187-arhitektura-v-processe.md   RC_PROV=0
$ bash scripts/check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md
ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)   RC_DOOR=0
$ bash scripts/check_precision_gate.sh . contracts/187-…   OK  RC_PREC=0
$ bash scripts/check_ceilings.sh .                         потолки в порядке  RC_CEIL=0
$ bash scripts/pre_critic.sh contracts/187-…               КРИТИК: дверь зелёная  RC_PRECRITIC=0
```

Регресс frozen-батарей, затронутых 5 скриптами (`grep -rlE 'make_task\.sh|freeze_contract\.sh|pre_critic\.sh|done_contract\.sh|check_architecture_contract'` по `fixtures/`), последовательно, `timeout 900`, OBJECT против `origin/main`:

```
verify_antiplacebo.sh --scope freeze_contract pre_critic done_contract
  OBJECT: барьеров: 3 · фикстур: 18 · предъявлено красным повторным прогоном: 18  RC=0
  base:   барьеров: 3 · фикстур: 18 · предъявлено красным повторным прогоном: 18  RC=0
red_arch_component_170.sh --model (OBJECT)   RC_MODEL=0
red_arch_component_170.sh --repo  OBJECT: 25 ok RC=0 | base: 25 ok RC=0
_krasnye_095.sh                            OBJECT rc=0 «ИТОГ 095: rc=0» | base rc=0 «ИТОГ 095: rc=0»
_krasnye_103.sh                            OBJECT rc=0 «ИТОГ 103: rc=0» | base rc=0 «ИТОГ 103: rc=0»
_krasnye_038.sh                            OBJECT rc=1 «итог: 37 файлов, расхождений 37 (режим ожидания rc=1)» | base rc=1 «итог: 37 файлов, расхождений 37 (режим ожидания rc=1)»
_krasnye_072.sh                            OBJECT rc=0 «итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0» | base rc=0 «итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0»
_krasnye_060.sh                            OBJECT rc=0 «итог 060: rc=0» | base rc=0 «итог 060: rc=0»
red_model_choice_166.sh                    OBJECT rc=0 | base rc=0
red_proektnaja_raskladka_161.sh            OBJECT rc=0 | base rc=0
red_proektnaja_raskladka_161.sh --stabs    OBJECT rc=0 | base rc=0
red_predverie_172.sh                       OBJECT rc=0 | base rc=0
red_sessii_136.sh                          OBJECT rc=0 «клеток 87, зелёных 87» | base rc=0 «клеток 87, зелёных 87»
red_sessii_125.sh                          OBJECT rc=0 «зелёных 70, красных 0» | base rc=0 «зелёных 70, красных 0»
red_dovodka_ui_133.sh                      OBJECT rc=0 «клеток 34, сошлось 34» | base rc=0 «клеток 34, сошлось 34»
rezhim_996/probe.sh                        OBJECT rc=0 «examined=111 mismatches=0» | base rc=0 «examined=111 mismatches=0»
red_schet_vyzovov_154.sh                   OBJECT rc=1 «CELLS=35 GREEN=6» (красная-до, предмет не реализован) | base rc=1 «CELLS=35 GREEN=6» (красная-до, предмет не реализован)
red_izveshchenie_168.sh                    OBJECT rc=1 «STATION_DONE_WRITER_CREATED_TAG» (красная-до) | base rc=1 «STATION_DONE_WRITER_CREATED_TAG» (красная-до)
red_model_trace_169.sh                     OBJECT rc=0 | base rc=0
red_ekrannyj_nabor_158.sh                  OBJECT rc=2 «NOT_IMPLEMENTED: батарея … не построена» | base rc=2 «NOT_IMPLEMENTED: батарея … не построена»
red_arch_component_170.sh --model  OBJECT: 25 ok RC=0 | base: 25 ok RC=0
ИТОГ: 17/17 строк совпали побайтно по rc и последней строке; зелёное до — зелёное после, красное до (038-ожидание, 154, 168, 158) — то же после.
```

Мутанты рецензента (одноразовый `mut187.py`: toy-миры через `probe.world` и `workflow_probe.architecture/prepare` фикстуры, дерево субъекта = OBJECT, публичные двери):

```
M1 freeze «ОПЕРАЦИЯ: identity.lookup (DRAFT); …»: (0, ['v1'], 'frozen/contracts/777/1')
M2 freeze «вход schema.draft»: (0, ['v1'], 'frozen/contracts/777/1')
M3 freeze control identity.draft: (1, ['ОТКАЗ: ARCH_DRAFT: операция identity.draft не имеет утверждённой схемы (DRAFT)'], '')
M4 freeze existing unplaced server/src/auth/x.js: (1, ['ОТКАЗ: ARCH_ZONE: путь server/src/auth/x.js размещён в продукте, но модель не относит его к заявленному компоненту'], '')
M5 freeze non-existing unplaced server/src/auth/x.js: (1, ['ОТКАЗ: PATH_WITHOUT_COMPONENT: путь server/src/auth/x.js не размещён ни в модели, ни в продукте'], '')
M6 freeze without ОПЕРАЦИЯ line: (1, ['ОТКАЗ: ARCH_DRAFT: предмет не объявляет операцию со схемами входа/выхода'], '')
M7 freeze, locate prints JSON (real-CLI shape): (1, ['ОТКАЗ: ARCH_ZONE: путь app/identity/model.js отнесён моделью к компоненту {, а строка «АРХИТЕКТУРА:» называет api.identity'], '')
M8 pre_critic, check needs --base <snapshot>: (1, ['ОТКАЗ: дверь архитектуры 187а красна: ARCH_CHECK: check --base модели красный (rc=1)'])
M9 done, green arch only on origin/main, HEAD ahead: (0, [], 'tag=done/contracts/777/1', 'tag_on_HEAD=True', 'checked_sha_is_old=True')
M10 door CLI full mode, draft: (1, 'ARCH_DRAFT: операция identity.draft не имеет утверждённой схемы (DRAFT)')
```

Проверка «более простой формы» (одноразовый worktree на OBJECT, НЕ закоммичено, НЕ предлагается как патч — только доказательство, что строки приёмки её пропускают): `check --base baseline/approved.json`; токен `draft` регистронезависимо на границе слова в строке операции; SHA check-run = `HEAD`. Дифф 2 файла, +6/−2.

```
$ red_architecture_process_187.sh --repo <fix> | grep -c '^GREEN'   → 30   RC_FIX=0
M1 … (1, ['ОТКАЗ: ARCH_DRAFT: операция identity.lookup (DRAFT) помечена DRAFT'], '')
M2 … (1, ['ОТКАЗ: ARCH_DRAFT: операция identity.lookup помечена DRAFT'], '')
M8 … (0, ['  ok   дверь архитектуры 187а: ARCH_187A_OK: архитектура сходится с закреплённой моделью'])
M9 … (1, ['ARCH_CI: успешного check-run arch на финальном SHA b83ab3cb… нет (curl rc=0)'], 'tag=', 'tag_on_HEAD=False', …)
```

Реальный CLI (копия `Complior-back@origin/main:architecture`, `git archive` во временный каталог):

```
$ node checks/cli.js locate --path app/application/session/x.js   (до npm ci)
Error: Cannot find module 'acorn' … RC_LOCATE=1
$ node checks/cli.js check --base   (до npm ci)
Error: Cannot find module 'acorn' … RC_CHECK=1
$ npm ci --ignore-scripts → added 89 packages
$ node checks/cli.js locate --path app/application/session/x.js
{ "scope": "DECLARED_PLACEMENT_ONLY", "path": "app/application/session/x.js", "status": "DECLARED",
  "matches": [ { "module": "module.app.application.session", "components": [ "api.identity" ], … } ], … }
RC_LOCATE=0
$ node checks/cli.js locate --path server/src/auth/x.js → "status": "DECLARED" … RC_LOCATE2=0
$ node checks/cli.js check --base
{ "status": "FAIL", "scope": "ARCHITECTURE_TOOL_INPUT", "findings": [ { "code": "MISSING_OPTION_VALUE", "message": "A value is required for --base" } ], … }
RC_CHECK_NOVAL=1
$ node checks/cli.js check --base baseline/approved.json → "status": "NOT_EVALUATED" … RC_CHECK_VAL=2
$ node checks/cli.js brief --compact --component api.identity → "# api.identity" … RC_BRIEF=0
```

## Паразитная сложность (050) — по артефактам диффа

- `scripts/check_architecture_contract.sh` (новый): (1) ПРОВОДКА `guard=scripts/check_architecture_contract.sh` и общий шов четырёх дверей. (2) Состояние — временное дерево модели (`ARCH187_MODEL_TMP`, глобальная переменная; очистку вызывают импортёры и ловушка `make_task`), читает env `ARCHITECTURE_ROOT` и `ARCH187_LIB`. В выводе состояние не видно, но оно зачищается. (3) Правку свойства «грамматика строки/зон» вносят в 1 файл вместо 4: число файлов диффом уменьшено. (4) Интерфейс: `--repo`, `--model-only`, позиционный контракт, rc 0/1/2. Глубина достаточная. (5) Потребители — CI-шаг `check:architecture-door-187` и три двери. Грамматику соседей не повторяет. Вердикт: ESSENTIAL. Исключения: поле `.clone` (С4, ACCIDENTAL) и эвристика существования (С2).
- `scripts/make_task.sh` (+76/−11): (1) строка `АРХИТЕКТУРА:`, зоны, бриф из пина. (2) Новое состояние `_A187_FILE` и дерево модели, оба в ловушке EXIT. (3)–(5) Прежняя ветка 170 сохранена байтово под `else`; потребители — клетки `task-*`/`brief-*`. ESSENTIAL.
- `scripts/freeze_contract.sh` (+23), `scripts/pre_critic.sh` (+18): (1) нога freeze и нога pre_critic. (2) Временный файл с текстом контракта удаляется. (3)–(5) Логика в шве, двери только вызывают его; потребители — клетки `freeze-*`/`check-*`. ESSENTIAL.
- `scripts/done_contract.sh` (+78): (1) `ARCH_REVIEW`/`ARCH_CI`. (2) Читает env `GITHUB_TOKEN`/`GH_TOKEN`/`GITHUB_REPOSITORY` и сеть (`curl`) — состояние неявное. Отказ закрытый, но см. Б2 и С5. (5) Потребители — клетки `done-*`. ESSENTIAL. Фолбэк `GITHUB_REPOSITORY:-unknown/unknown` отказывает закрыто, это совет, не блок.
- CI-строки orchestrator (2 в `ci-steps.tsv`, 2 в `ci-zamery.tsv`, перегенерированный `ci.yml`): (1) приёмка 187/1 (`--wiring`). Шаг `check:architecture-door-187` на корне харнесса всегда `SKIP` (С6), но его требует контракт. ESSENTIAL по контракту.

## Что нужно для accept

Закрыть Р187-Б1, Р187-Б2, Р187-Б3 в зоне implementer, не трогая фикстуру. Каждой правке предъявить мутант из этого вердикта (M8, M9, M1/M2), который до правки зелёный, а после правки красный. Батарея 187 `--repo` должна остаться 30/30, 170 — 25/25. С1/С2/С3 — вопрос architect (v+1 фикстуры 187: toy-locate с JSON-выводом и чужим компонентом, `check` с обязательным операндом снимка) и владельцу (обязательность `ОПЕРАЦИЯ:`). Повторный суд — по новому OBJECT.
