accept
OBJECT=d80e9a8d1eeb1ef680a95c691068fc9755222a92
КЛАСС=кодовый; риск=обычный (подтверждён: правки касаются аргументов `check --base`, токена DRAFT в строке операции, SHA check-run и цели done-тега; права, авторизация, деньги и ПД не меняются)
СУД: repo=dev-harness; предмет=187 (187а: двери и скрипты архитектуры в процессе станции); фаза=реализация; роль=reviewer; вызов=2/2 (scoped-исправительный после FAIL Р187-Б1/Б2/Б3); модель-план=anthropic/claude-opus-5-5; сессия=Rev187v2; модель-факт=anthropic/claude-opus-5-5; OBJECT=d80e9a8d1eeb1ef680a95c691068fc9755222a92; предыдущий=verdicts/review/contracts-187-impl-v1.md; исключение=нет

# Вердикт ревьюера — 187а, суд реализации, вызов 2/2 (scoped-исправительный)

Контракт: `frozen/contracts/187/1` → `52d3a3a15c4abef583aab071f9fac552a81ee04c`. `git diff frozen/contracts/187/1 OBJECT -- contracts/187-arhitektura-v-processe.md` — 0 строк.
Кандидат: `origin/wip/187/implementer` = `d80e9a8d1eeb1ef680a95c691068fc9755222a92` (`git rev-parse` в одноразовом SSH-клоне `/tmp/dev-harness-verify/Rev187v2/repo` совпал с OBJECT). PR-дерево: `origin/wip/187/orchestrator` = `d2454ce4bfea289ad1232c5d4f13a0e7dba62c1d`. `origin/main` = `0e8e94888612d56796ee74f4f5bbe3e84cc0449a`, merge-base OBJECT ↔ main = `b801505f` (коммит architect с красными клетками `Arch187Cells5`).
Прежний OBJECT `834745ed88fbc39d019b02bd068ad8cf5fa71cca` получен `git fetch origin <sha>`. Шесть прежних коммитов перенесены cherry-pick без изменения по существу. `git patch-id --stable` диффа каждого из пяти файлов (прежний OBJECT против своей базы и `5afc55e4` против `origin/main`) совпал для 4 файлов. У `pre_critic.sh` совпали строки диффа, отличается только контекст хунка: main ушёл на `90c6ea66` (гейт трека 158).
Независимость: все 9 коммитов OBJECT — `user.name=implementer` (MiniMax-M3 по паку), судья — Anthropic Opus.

## Итог

accept. Р187-Б1, Р187-Б2 и Р187-Б3 закрыты. Каждый блок закреплён моим мутантом: на прежнем OBJECT он проходит, на правке отказывает (§2). Новых блоков в трёх правках нет. Пять советов и три наблюдения вынесены в `.review/2026-11-11-99.md`. Батарея 187 на OBJECT даёт `CELLS=34 FAILURES=0` rc 0, на прежнем OBJECT — ровно 5 красных клеток из задания. `--model` 34/34, `--stabs` 33/33 caught. Регресса в затронутых frozen-батареях нет.

## Находки (класс)

- Блок — нет.
- Совет С-1 (`done_contract.sh:330`): цель done-тега берётся из унаследованного env `_a187_sha` у предметов вне ветки 187а. Регресс внесён `d80e9a8d1`, достижим только намеренной подстановкой env. Поэтому совет; починка в одну строку проверена.
- Совет С-2 (`check_architecture_contract.sh:218-235`): rc 1 модели при ошибке входа инструмента получает маркер `ARCH_NOT_EVALUATED`, а не `ARCH_CHECK`. Отказ сохраняется. По 050 ACCIDENTAL не доказан: простая форма теряет отказ на P6.
- Совет С-3 (`:398,409`): мёртвые альтернативы `DRAFT|draft` в `case "$schema"`.
- Совет С-4 (`:64`): снимок только в раскладке 2.5.x. При пине 2.4.x — закрытый отказ.
- Совет С-5: `curl --max-time` попутно в коммите Б2 (атомарность).
- Наблюдения Н-1 (локаль `C.UTF-8`), Н-2 (digest из lock, а не из независимой переменной), Н-3 (блобы PR = OBJECT).

## 1. Область правки

```
$ git diff --stat origin/main...d80e9a8d1
 scripts/check_architecture_contract.sh | 520 +++++++++++++++++++++++++++++++++
 scripts/done_contract.sh               |  92 +++++-
 scripts/freeze_contract.sh             |  23 ++
 scripts/make_task.sh                   |  76 ++++-
 scripts/pre_critic.sh                  |  18 ++
 5 files changed, 717 insertions(+), 12 deletions(-)
$ git diff --stat 5afc55e4 d80e9a8d1          # только три новых коммита
 scripts/check_architecture_contract.sh | 90 +++++++++++++++++++++++++++-------
 scripts/done_contract.sh               | 24 ++++++---
 2 files changed, 90 insertions(+), 24 deletions(-)
449f4695c implementer | 187a: check --base против утверждённого снимка (digest из lock)   scripts/check_architecture_contract.sh | 54+ 6-
d9fa1ad13 implementer | 187a: DRAFT — токен в любом месте строки операции                 scripts/check_architecture_contract.sh | 18+ 12-
d80e9a8d1 implementer | 187a: done сверяет check-run arch на том же SHA, что и тег        scripts/done_contract.sh               | 18+ 6-
$ git log --format='%an' origin/main..d80e9a8d1 | sort | uniq -c   →   9 implementer
$ git log origin/main..d80e9a8d1 -- fixtures contracts roles AGENTS.md   →   (пусто)
$ wc -l scripts/check_architecture_contract.sh   →   520
PR d2454ce4b: блобы 5 скриптов зоны == OBJECT (same ×5); сверх — ci.yml, registry/ci-steps.tsv (+2), registry/ci-zamery.tsv (+2), HANDOFF.md
```

Зона соблюдена: 5 файлов implementer, три новые правки — только в двух из них. Фикстуры, контракт и нормы автор реализации не трогал. Фикстуру после v1 менял только `architect` (`b801505f`, `workflow_probe.py` +101/−4: 4 клетки и 6 стабов). Атомарность: одна правка — один блок. Исключение — `--max-time` в коммите Б2 (С-5).

## 2. Закрытие трёх блоков — мои мутанты (одноразовый `mut187v2.py`, публичные двери, один мир на мутант)

```
$ python3 mut187v2.py <obj=d80e9a8d1>                       $ python3 mut187v2.py <old=834745ed8>
F1 (DRAFT) marker:        rc=1 ARCH_DRAFT tag=-             rc=0 tag=frozen/contracts/777/1
F2 вход schema.draft:     rc=1 ARCH_DRAFT tag=-             rc=0 tag=frozen/contracts/777/1
F3 выход schema.Draft:    rc=1 ARCH_DRAFT tag=-             rc=0 tag=frozen/contracts/777/1
F4 …; статус DRAFT:       rc=1 ARCH_DRAFT tag=-             rc=1 ARCH_DRAFT tag=-
F5 … — draft (em-dash):   rc=1 ARCH_DRAFT tag=-             rc=0 tag=frozen/contracts/777/1
P1 (=M8) lenient CLI (голый --base зелёный), digest lock ≠ снимок пина:
                          rc=1 ARCH_CHECK                   rc=0 ARCH_187A_OK
P2 lenient CLI, lock без snapshotDigest:
                          rc=1 ARCH_NOT_EVALUATED («в architecture.lock.json нет snapshotDigest…»)   rc=0 ARCH_187A_OK
P9 контроль (валидный мир): rc=0 ARCH_187A_OK               rc=1 ARCH_CHECK (rc=1)
D1 (=M9) HEAD впереди origin/main, зелёный arch только на старом SHA:
                          rc=1 ARCH_CI tag=-                rc=0 tag=done/contracts/777/1 tag_on_HEAD=True
D2 зелёный arch на HEAD, origin/main отстал:
                          rc=0 tag on HEAD                  rc=1 ARCH_CI
D3 контроль:              rc=0 tag_on_HEAD=True             rc=0 tag_on_HEAD=True
```

Р187-Б1 закрыт. Дверь зовёт `check --base governance/baseline/approved.json --base-digest <lock.snapshotDigest>`. Свой digest она не считает: подмена digest снимком B даёт `ARCH_CHECK` (клетка `check-digest-mismatch`, мой P1). Без digest в lock — `ARCH_NOT_EVALUATED` (P2).
Р187-Б3 закрыт. Токен `draft` ловится на границе слова в любом поле строки операции (F1–F5).
Р187-Б2 закрыт. SHA для check-run и цель тега — один и тот же `HEAD` (D1, D3). Отставший `origin/main` больше не участвует: D2 на прежнем OBJECT отказывал ложно, теперь проходит честно.

## 3. Отсутствие новых блоков в правках

**ARCH_NOT_EVALUATED вместо ARCH_CHECK при ошибке входа: отказ не ослаблен.** Любой rc ≠ 0 `arch187_model_check` даёт `exit 1` двери (`:513-517`), а `pre_critic.sh` отказывает при любом rc ≠ 0 двери.

```
P3 настоящий красный (scope MODEL) rc1:          rc=1 ARCH_CHECK
P4 красный + ENOENT в stderr, stdout не пуст:    rc=1 ARCH_CHECK          (эвристика «не запустился» не перехватывает настоящий красный)
P5 ARCHITECTURE_TOOL_INPUT rc1:                  rc=1 ARCH_NOT_EVALUATED  (прежний OBJECT: rc=1 ARCH_CHECK)
P6 rc0 + ARCHITECTURE_TOOL_INPUT в выводе:       rc=1 ARCH_NOT_EVALUATED  (прежний OBJECT: rc=0 — правка строже)
P7 Cannot find module, stdout пуст:              rc=1 ARCH_NOT_EVALUATED
P8 снимка нет в закреплённом дереве:             rc=1 ARCH_NOT_EVALUATED
```

**Граница слова DRAFT: ложных срабатываний нет.** Ответ двери совпал с оракулом `re.search(r'(?<!\w)draft(?!\w)', line, re.I)` на всех 12 входах:

```
F6 identity.draft_v2  py=0 rc=0 tag=frozen   F7 schema.draftset   py=0 rc=0   F8 schema.идdraftи  py=0 rc=0
F9 schema.redraft     py=0 rc=0              F10 schema.draft2    py=0 rc=0   F11 schema.черновикdraft py=0 rc=0
F12 schema.draftовый  py=0 rc=0
```

**`LC_ALL=C.UTF-8` (Н-1).** GNU grep 3.11, станция:

```
идdraftи C=1 C.UTF-8=0 | schema.черновикdraft C=1 C.UTF-8=0 | draftовый C=1 C.UTF-8=0 | x.draft C=1 C.UTF-8=1
$ locale -a → C.utf8 ;  ci.yml: runs-on: ubuntu-24.04 (×7)
```

Без локали — только лишний отказ (fail-closed). Ложного зелёного нет.

**SHA=HEAD в done согласован с соседними дверьми.** `freeze_contract` судит `HEAD:<контракт>` (`freeze_contract.sh` §4а `g cat-file -p "HEAD:$TARGET"`). Нога `pre_critic` судит модель по пину, а не по SHA продукта. Done теперь сверяет check-run и ставит тег на один и тот же `HEAD`.

**`curl --max-time 30`: таймаут не маскирует отказ.** T1 — настоящий curl через «чёрную дыру» HTTPS-прокси:

```
T1 real curl, black-hole proxy: rc=1 secs=30.5 tag=- line=ARCH_CI: успешного check-run arch на финальном SHA 69734c00… нет (curl rc=28)
```

**Найдено попутно: С-1 (совет).** Цель тега управляется env у предметов вне ветки 187а:

```
OBJECT : E1 harness world, env _a187_sha=<root>: rc=0 tag=done/contracts/777/1 tag_on_HEAD=False tag_on_env_sha=True
         E2 backend doc subject, env _a187_sha=<root>: rc=0 … tag_on_HEAD=False tag_on_env_sha=True
old    : E1/E2 rc=0 tag_on_HEAD=True tag_on_env_sha=False
main   : E1/E2 rc=0 tag_on_HEAD=True tag_on_env_sha=False
```

Почему совет, а не блок: производителя переменной в дереве нет (`grep _a187_sha` по дереву PR → только `scripts/done_contract.sh`). Состояние достижимо только намеренной подстановкой env. Ветку 187а (backend-кодовый предмет) это не затрагивает: там переменная присваивается до использования.

**Проверка более простой формы.** Worktree `simp`, не закоммичено. Изменения: убраны ветви С-2; добавлено `_a187_sha=""` до блока 187а; одна строка `git tag … "${_a187_sha:-HEAD}"`.

```
$ red_architecture_process_187.sh --repo <simp>   → CELLS=34 STABS=0 FAILURES=0  RC_SIMP=0
P5 rc=1 ARCH_CHECK | P6 rc=0 ARCH_187A_OK (простая форма теряет отказ) | P7 rc=1 ARCH_CHECK | P8 rc=1 ARCH_CHECK
D1 rc=1 ARCH_CI tag=- | E1/E2 rc=0 tag_on_HEAD=True tag_on_env_sha=False
```

## 4. Батарея 187 и регресс (последовательно, `timeout`)

```
$ bash …/red_architecture_process_187.sh --repo <obj d80e9a8d1>
GREEN ×34 (task-*, brief-*, freeze-* вкл. freeze-draft-marker/-schema, check-valid/-failure/-not-evaluated/-digest-mismatch, done-* вкл. done-ci-head-ahead, legacy-mob/-harness, wiring-*)
CELLS=34 STABS=0 FAILURES=0
RC_OBJ=0
$ … --repo <old 834745ed8>
RED freeze-draft-marker: rc=0 expected=1 … заморожено … frozen/contracts/777/1
RED freeze-draft-schema: rc=0 expected=1 …
RED check-valid: rc=1 expected=0 … ARCH_CHECK: check --base модели красный (rc=1)
RED check-not-evaluated: rc=1 expected=1 reason=ARCH_NOT_EVALUATED … ARCH_CHECK … (rc=1)
RED done-ci-head-ahead: rc=0 expected=1 reason=ARCH_CI
CELLS=34 STABS=0 FAILURES=5
RC_OLD=1
$ … --model   → CELLS=34 STABS=0 FAILURES=0   RC_MODEL=0
$ … --stabs | awk → CELLS=34 STABS=33 FAILURES=0 / STAB_LINES=33 CAUGHT=33 ZHIV=0   RC_STABS=0
```

Своя мера. Строки `GREEN` на OBJECT — 34 (`grep -c`). Красных на прежнем OBJECT — 5, имена совпали с заданием. Строки `STAB … caught` посчитаны awk: 33.

```
OBJECT d80e9a8d1                                         | base origin/main 0e8e94888
verify_antiplacebo.sh --scope freeze_contract pre_critic done_contract
  барьеров: 3 · фикстур: 18 · предъявлено красным: 18 RC=0 | 3 · 18 · 18 RC=0
red_arch_component_170.sh --model   RC=0 (последняя: «170 second_malformed_id ok rc=1 … npm_calls=0») | RC=0 (та же)
red_arch_component_170.sh --repo .  RC=0 («… неконформный id: ../x' npm_calls=0»)                  | RC=0 (та же)
  frozen 170/1: git diff frozen/contracts/170/1 origin/main -- contracts/170* → пусто; OBJECT…main по 170 → 0 строк
freeze_contract/fail_closed_992.py  cases=25 observations=25 failures=0 RC=0 | то же RC=0
rezhim_996/probe.sh                 996: examined=111 mutants=0 mismatches=0 RC=0 | то же RC=0
izveshchenie_168/red_izveshchenie_168.sh  STATION_DONE_WRITER_CREATED_TAG RC=1 | то же RC=1 (красная-до, как в v1)
```

PR-дерево `d2454ce4b`:

```
$ bash …/red_architecture_process_187.sh --wiring .     RC_WIRING=0
$ bash scripts/gen_ci_steps.sh --check                  RC_GEN=0
$ bash scripts/check_provodka.sh . contracts/187-…      RC_PROV=0
$ bash scripts/check_ceilings.sh .                      потолки в порядке  RC_CEIL=0
$ bash scripts/check_precision_gate.sh . contracts/187-… OK  RC_PREC=0
$ bash scripts/check_architecture_contract.sh --repo . contracts/187-…
ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)   RC_DOOR=0
$ bash scripts/pre_critic.sh contracts/187-…            КРИТИК: дверь зелёная  RC_PRECRITIC=0
$ bash …/red_architecture_process_187.sh --repo .       CELLS=34 STABS=0 FAILURES=0  RC_PR_REPO=0
```

## 5. Норма, подгонка, НЕ БАРЬЕР

Нормативные документы (`roles/`, `AGENTS.md`, `contracts/`) в диффе OBJECT отсутствуют. Подгонки проверки под код нет. Клетки Р187-Б1/Б2/Б3 написал architect (`b801505f`) по находкам v1 до правки. Реализация подстроилась под грамматику реального CLI, а не наоборот: путь снимка в фикстуре (`SNAPSHOT`) и в двери (`ARCH187_SNAPSHOT`) совпадает с `run-arch.js` бэкенда 167 (раскладка 2.5.x). Различающую силу правок я проверил своими мутантами вне фикстуры (F3–F5, F6–F12, P1–P8, D1–D2, T1, E1–E2).

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (grep по `AGENTS.md` на OBJECT пуст).

## Паразитная сложность (050) — по артефактам трёх правок

- `ARCH187_SNAPSHOT` (константа, `:64`) + `arch187_snapshot_digest` (`:95-98`): (1) 187/1 §Предмет «против утверждённого снимка». (2) Читает `snapshotDigest` из lock; отсутствие видно в выводе (`ARCH_NOT_EVALUATED: … нет snapshotDigest`). (3) Свойство живёт в одном файле, число файлов не выросло. (4) Новых флагов и env нет. (5) Потребители — клетки `check-valid`, `check-digest-mismatch`, стабы `check-base-without-snapshot`, `check-digest-omitted`, `check-digest-self-computed`. ESSENTIAL. Одна раскладка вместо двух — С-4.
- Ветви классификации в `arch187_model_check` (`:218-235`) + временный `errf`: (1) свойства 187/1 нет, контракт отображает rc 1 в `ARCH_CHECK`. (2) Состояние — временный файл stderr, удаляется. (3) 1 файл. (4) Интерфейс не вырос. (5) Клетки-потребителя нет, но простая форма теряет отказ на P6. Совет С-2: ACCIDENTAL не доказан.
- `arch187_draft_token` (`:370-373`): (1) 187/1 «не DRAFT, иначе `ARCH_DRAFT`». (2) Читает локаль `LC_ALL=C.UTF-8` явно, в коде. (3) Заменил две разнородные проверки одной, число мест правки сократилось. (4) Интерфейс — строка → rc. (5) Потребители — клетки `freeze-draft`, `freeze-draft-marker`, `freeze-draft-schema`, стабы `draft-spaced-token-only`, `draft-schemas-ignored`. ESSENTIAL. Остаток — мёртвые альтернативы `case` (С-3).
- `done_contract.sh` `_a187_sha=HEAD` + `_a187_tag_target` и вторая ветвь `git tag` (`:223`, `:330-339`): (1) 187/1 «check-run `arch` … по ЭТОМУ SHA», а тег done — на тот же SHA. (2) Состояние — переменная оболочки, не обнулённая до блока: читается из env (С-1). (3) 1 файл. (4) Две почти одинаковые ветви вместо одной (`${_a187_sha:-HEAD}`). (5) Потребители — `done-ci-head-ahead`, стаб `ci-sha-from-origin-ref`. Свойство ESSENTIAL. Форма раздута, а env-утечка — ACCIDENTAL: С-1 называет фрагмент, отсутствующее свойство («тег на HEAD у не-187 предметов») и более простую форму, прошедшую те же 34 клетки. Блоком не считаю: состояние достижимо только намеренной подстановкой env, производителя в дереве нет (§3).
- `curl --max-time 30`: (1) не свойство 187/1, а совет С5 вызова 1. (2) Состояния нет. (5) Потребителя-клетки нет; T1 доказывает отказ, а не зелень. Сложности почти не добавляет; атомарность — С-5.

## Что дальше

Для слияния PR #782 блоков нет. Советы С-1…С-5 — `.review/2026-11-11-99.md` (status: ready), раздаёт оркестратор по норме 050. С-1 разумно закрыть одной строкой до done 187а, но на этот accept это не влияет. Done 187а по-прежнему ждёт v+1 170 (условие контракта, HANDOFF).
