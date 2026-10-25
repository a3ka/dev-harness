FAIL
OBJECT=dba6589fc51a15b77bdd8c1f49673f374e65e3f2

# Ревью реализации 136 v2 — круг 4 (SCOPED, единственный по разрешению владельца) — PR #339, `wip/136/implementer-v2`

Судья: Rev136d (reviewer; модель anthropic/claude-opus — семейство Anthropic; implementer — GLM; трасса архитектора
(Architect136e/f) в `orch/brief_trace.tsv` пуста — совпадение семейств по трассе установить нечем, с implementer не совпадает).
Задание: `/tmp/dev-harness-verify/orch/task-rev136d.md`. Норма — только frozen `frozen/contracts/136/2^{commit}` = `522f21ce`.
Клоны (SSH `ssh://git@github.com/a3ka/dev-harness.git`, свой `.git`): `/tmp/dev-harness-verify/Rev136d` (OBJECT, мутации),
`/tmp/dev-harness-verify/Rev136d-br2` (OBJECT, чистый — правило 7 и CI-ключи), `/tmp/dev-harness-verify/Rev136d-main`
(`origin/main` = `08b4e3a9`). «До» (`70e9a830d`, в origin его нет — ветка пересобрана) — `git archive 70e9a830d scripts` из
основного чекаута (только чтение) в `/tmp/dev-harness-verify/Rev136d-t/old/scripts`. Скрипты замеров — `/tmp/dev-harness-verify/Rev136d-t/*.sh|*.py`.

Блокеров: **1** (R136d-B1). Советов: 5 (R136d-S1…S5).

## Блокер

| ID | Класс | Место | Обязательство | Названный ОБХОД (критерий выполнен, предмет не сделан) |
|---|---|---|---|---|
| **R136d-B1** | **БЛОКЕР** — R136c-B1 закрыт в двери, но НЕ «во ВСЕХ трёх скриптах»: гейт паритета берёт путь реестра своим `jq` | `scripts/verify_ci_parity.sh:210-211` (`_wp_reg="$(jq -r '.workflowPaths.registry // ".harness/registry"' …)"`; `EXCEPTIONS="$ROOT/$_wp_reg/ci_parity_exceptions.txt"`); побайтно то же в `fixtures/workshop_project/sessii_136/model/verify_ci_parity.sh` (cmp 0) | frozen 136/2 И-8: «Проектный режим: исключения ТОЛЬКО из `<workflowPaths.registry>/ci_parity_exceptions.txt` (файл сеет дверь ПУСТЫМ ПО ФАКТУ профиля …)»; ПЕРЕСЕЧЕНИЕ implementer «103 профильные пути — единственный источник»; п.1 задания (путь реестра ТОЛЬКО из `project_paths_resolve` во всех трёх скриптах) | Профиль подключённого проекта БЕЗ `workflowPaths` (законный 996-вход оси E — тот же, на котором батарея держит e1/e2): `project_paths_resolve` → `.registry = $REPO/registry`; дверь OBJECT сеет туда `trace.tsv` и ПУСТОЙ `ci_parity_exceptions.txt`, `make_task` читает трассу оттуда же. Гейт паритета читает `.harness/registry/ci_parity_exceptions.txt` — файл, который ни дверь, ни резолвер, ни `make_task` реестром не считают. Замер (п.1б): (а) честное подключение → гейт rc 2 «нет `.harness/registry/ci_parity_exceptions.txt`» при посеянном профильном файле — боль П10 (пре-фриз красен) не снята; (б) исключения, объявленные в профильном `registry/ci_parity_exceptions.txt`, гейт не видит — rc 2; (в) профильный перечень пуст (как сеет дверь), исключения лежат в непрофильном `.harness/registry/` → гейт **rc 0 «объявленное исключение»**, тогда как по профильному источнику он обязан дать rc 1 FAIL. Батарея 79/79·79/79·42/66/0 зелёная на этом дереве: клеток гейта на мире `nowf` нет (`mk_mir … nowf` — только e1/e2, обе — дверь). Так же гейт идёт за `registry: "../outside"` / symlink / абсолютный путь вне репо (`$ROOT/../outside/…`), которые резолвер отвергает «workflowPaths вне репо», а дверь — `profil-ne-razreshaetsja`. Более простая форма, читающая профильный файл (замер п.1в, 5 строк вместо 2: `project_paths_resolve "$ROOT_ABS"` → `.registry`), на состоянии (в) даёт rc 1. |

Маршрут закрытия (называю, не проектирую): модель гейта и `scripts/verify_ci_parity.sh` — путь реестра из того же
`project_paths_resolve`, что у двери/`make_task`; батарея — клетка гейта на мире `nowf` (профильный перечень vs непрофильный
`.harness/registry`) и стаб «гейт своим jq». Модель = реализации побайтно, поэтому без правки модели/батареи (architect) реализацию
не сдвинуть — это не вина implementer относительно модели, но предмет 136 на этом дереве не сделан.

Почему блокер, а не совет (у Rev136c это R136c-S1, «обхода безопасности не называю»): в этом круге п.1 задания прямо ставит
«свой jq пути реестра» в трёх скриптах критерием закрытия R136c-B1, а ОБХОД назван состоянием дерева и измерен: на OBJECT
гейт зеленеет по исключениям из файла вне профильного реестра, а на профильном — краснеет rc 2 при честном посеве двери.
Это ровно класс R136c-B1 («дверь сеет одно место, потребитель читает другое»), перенесённый с трассы на перечень исключений.

## Вердикт по пунктам задания 1–5

| # | Пункт | Статус | Основание (замер ниже) |
|---|---|---|---|
| 1 | R136c-B1 закрыт реализацией во ВСЕХ трёх скриптах | **FAIL → R136d-B1** | Дверь: собственного `jq` пути реестра нет, путь — `project_paths_resolve` после каркаса (`connect_project.sh:238-247`); репро до/после по 8 значениям оси — замер 1а: до (`70e9a830d`) `nowf` → rc 7 + exec + `TRACE … evil-model`; после → rc 1 `trassa-rashozhdenie` до exec, подложка байт в байт, `.harness/registry/trace.tsv` не создан. `make_task.sh`: путь трассы — тот же `project_paths_resolve` (ранний мягкий + поздний строгий), своего `jq` пути реестра нет. **`verify_ci_parity.sh:210-211` — свой `jq` пути реестра с дефолтом `.harness/registry`** — замер 1б (ОБХОД), 1в (более простая форма). |
| 2 | cmp реализации к модели; не ослаблена ли проверка | **OK** | `cmp model/connect_project.sh scripts/connect_project.sh` → 0; `cmp model/verify_ci_parity.sh …` → 0; `make_task.sh` ≠ модели (ранний мягкий/поздний строгий резолв, коммит `c8f75b10`, совет S1). Диф двери к `70e9a830d` (замер 2): удалены только свой `jq` (`REG_REL=…// ".harness/registry"`) и старое место блока трассы/посева; блок трассы перенесён побайтно (тот же `-s`/сравнение/`trassa-rashozhdenie`/посев/сев перечня) ПОСЛЕ каркаса, до последнего стража и финального оракула; добавлены резолвер и 4 именованных отказа. Проверка не ослаблена. |
| 3 | Регресс (а)–(е) из сырого вывода | **OK** | 136 plain 79/79 rc 0; `--model` 79/79 rc 0; `--stabs` 42/66/0 rc 0 (первый прогон rc 2 — флейк общих путей, совет S2); 125 plain 70/70 rc 0, `--model` 70/70 rc 0; мутанты m01–m12, n01–n07 — 19/19 КРАСНЫЕ rc 1 на реальных `scripts/*` (наборы красных клеток ⊇ frozen п.7); `pre_critic.sh contracts/136-…` rc 0. |
| 4 | Ключи CI вокруг трёх скриптов; правило 7 | **OK** | 095 rc 0 (повтор; первый rc 1 под параллельной нагрузкой — i1, отдельно rc 0 и на main, и на ветке), 103 rc 0, 112 63/63 rc 0 (= main), 996 rc 0, 125 70/70, `sverka_puti_profylja` = main; antiplacebo `--scope verify_ci_parity` 26/26, `pre_critic` 2/2, `profile_resolver` 10/10 rc 0; `verify_ci_parity.sh` на корне rc 0. Правило 7: 11 батарей лаунчера — rc ветки = rc main во всех 11 (`izoljacija_projectid` rc 1 на обеих — предсуществующе). |
| 5 | Проверки не переписаны под код; объём | **OK** | `git diff origin/main..HEAD --stat` — ровно 3 файла зоны implementer; fixtures/модели/контракты/registry/`path-guard.ts`/`workshop`/`next_id.sh`/`profile_resolver.sh` — 0 файлов; 4 коммита автора `implementer`, каждый в зоне и со ссылкой на причину. Правило 8: `--extract-pin 'текст без пары'` → `{"worktree":null}`. Расширения объёма нет. |

## Советы (не блокируют)

| ID | Место | Суть |
|---|---|---|
| R136d-S1 | `scripts/make_task.sh:137-163,230-263` vs `model/make_task.sh` | Не-комментарийное расхождение с моделью: ранний вызов резолвера мягкий (`2>/dev/null || _PP_JSON=""`), строгий — на старом месте. Исходы — те же именованные отказы («нет свидетельства модели» / «workflowPaths вне репо»), обхода нет (тот же класс, что R136c-S2). Модель стоит синхронизировать архитектору, чтобы граница implementer «diff = точки модели» была буквальной. |
| R136d-S2 | `red_sessii_136.sh` (`mk_mir`: `/tmp/dev-harness-verify/sessii-136-*`, `/tmp/dev-harness-fakehome-136/*`) | Миры — фиксированные пути вне `TMPDIR`: первый `--stabs` дал rc 2 «модель не зелёная» (`error: bad tree object HEAD`, 10 клеток), повтор 42/66/0 rc 0; `--model` печатал `rm: cannot remove …/.git`. Параллельные прогоны делят миры. Аналогично агрегат 095 дал rc 1 (i1) при параллельной нагрузке, повтор rc 0. |
| R136d-S3 | `make_task.sh` дефолт трассы | Когда дверь отказывает `trassa-rashozhdenie` (подложка закоммичена), `make_task --kind brief` без `--model-trace` всё равно печатает `TRACE … evil-model` (замер 1а, new/custom и new/nowf; так же было до правки — old/custom). И-6 не требует от `make_task` сверки с конфигом — вне 136 v2, но модель угроз «рассогласование исключено по построению» держится только на двери. |
| R136d-S4 | `connect_project.sh:244-246` | Отказы `profil-bez-registry` и `registry-vne-kornja` недостижимы: `project_paths_resolve` всегда отдаёт `$REPO_ABS/…` (`next_id.sh:358,410,478`) или падает (→ `profil-ne-razreshaetsja`). 050: ACCIDENTAL-кандидат, но более простая форма не прогонялась — совет. Смена поведения: профиль с `workflowPaths` без ключа `registry` — до правки дверь сеяла `.harness/registry`, теперь rc 1 `profil-ne-razreshaetsja` (резолвер: «профиль без workflowPaths.registry»; `make_task` на нём тоже отказывает — согласовано, клетки нет). |
| R136d-S5 | `connect_project.sh` порядок | Сверка трассы теперь ПОСЛЕ каркаса: при `trassa-rashozhdenie` дверь уже записала `.harness/.env`, профиль/слой/HANDOFF (раньше отказ трассы шёл до каркаса). Отказ по-прежнему до exec, подложка не тронута (e1, замер 1а); И-5 досоздание допускает. R136c-S3 (`.harness` как symlink-каталог) не перемерялся — наследие. |

## Паразитная сложность (050) — по артефактам диффа к `70e9a830d`

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| блок `project_paths_resolve` в двери (+`net-rezolvera-putej`, `profil-ne-razreshaetsja`) | И-6 «путь трассы — из ЕДИНОГО резолвера» | нет нового (путь виден в отказе) | 1 (резолвер общий с `make_task`) — число «меняются вместе» УМЕНЬШИЛОСЬ с 2 до 1 | 6 строк, интерфейс не растёт | e1, e2, b-/c-клетки; дубля нет | ESSENTIAL |
| `profil-bez-registry`, `registry-vne-kornja` | защитные ветви | нет | 1 | 2 строки, недостижимы | потребителя нет | совет S4 |
| `_wp_reg` в гейте паритета (не менялся этим диффом, но в зоне предмета) | И-8 | нет | **2: гейт и `project_paths_resolve` обязаны меняться вместе** | — | дублирует логику `next_id.sh:project_paths_resolve` с ДРУГИМ дефолтом | ACCIDENTAL и некорректный → R136d-B1 (фрагмент `verify_ci_parity.sh:210-211`, отсутствующее свойство «перечень = профильный реестр резолвера», более простая форма проходит те же строки — замер 1в) |

## ПРОВОДКА

guard `fixtures/workshop_project/sessii_136/red_sessii_136.sh` существует и судит три скрипта предмета; зелёный на OBJECT во всех
трёх режимах; но клетки гейта паритета на профиле оси E нет — поэтому guard не различает R136d-B1. step-строка и role-строка —
frozen NOT_RUN (интеграционный коммит оркестратора), в diff implementer им не место.

## Стенограмма замеров (сырой вывод, rc)

**0. Объект и область.**
```text
$ git rev-parse HEAD origin/main          (клон /tmp/dev-harness-verify/Rev136d)
dba6589fc51a15b77bdd8c1f49673f374e65e3f2
08b4e3a90187d5fd9a175b616db2f283184057db
$ git merge-base --is-ancestor origin/main HEAD; echo ancestor_rc=$?
ancestor_rc=0
$ git diff origin/main..HEAD --stat
 scripts/connect_project.sh  | 167 ++++++++++++++++++++++++++++++++++++++++++--
 scripts/make_task.sh        |  38 +++++++++-
 scripts/verify_ci_parity.sh |  43 ++++++++++++
 3 files changed, 239 insertions(+), 9 deletions(-)
$ git log --format='%h %an <%ae>' --name-only origin/main..HEAD
dba6589f implementer <implementer@dev-harness.local>  scripts/connect_project.sh
eabf648b implementer <implementer@dev-harness.local>  scripts/connect_project.sh scripts/verify_ci_parity.sh
c8f75b10 implementer <implementer@dev-harness.local>  scripts/make_task.sh
56fe70c1 implementer <implementer@dev-harness.local>  scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh
$ git diff --stat origin/main..HEAD -- .omp/extensions/path-guard.ts workshop scripts/next_id.sh scripts/profile_resolver.sh fixtures contracts registry
(пусто) diffrc=0
$ node .omp/extensions/path-guard.ts --extract-pin 'текст без пары'
{"worktree":null} rc=0
$ for f in connect_project.sh make_task.sh verify_ci_parity.sh; do cmp model/$f scripts/$f; done
connect_project.sh cmp_rc=0
fixtures/workshop_project/sessii_136/model/make_task.sh scripts/make_task.sh differ: char 8153, line 138   make_task.sh cmp_rc=1
verify_ci_parity.sh cmp_rc=0
$ grep -n '_wp_reg' scripts/verify_ci_parity.sh
210:      _wp_reg="$(jq -r '.workflowPaths.registry // ".harness/registry"' "$ROOT/harness.project.json" 2>/dev/null)"
211:      EXCEPTIONS="$ROOT/$_wp_reg/ci_parity_exceptions.txt" ;;
```

**1а. Репро R136c-B1 по оси `workflowPaths.registry`** (`bash /tmp/dev-harness-verify/Rev136d-t/repro_b1.sh <дерево> <метка>`;
мир: toy-git, слой `.harness/project-layer.json`, подложка `orchestrator\tevil-model\tallowed` закоммичена в место, указанное
колонкой planted; установка — дверь+`next_id.sh`+`profile_resolver.sh` дерева, настоящий страж, конфиг с моделью
`anthropic/claude-sonnet-5-5`, двойник workshop rc 7). Значения: default = `workflowPaths` без ключа `registry`; custom =
`.harness/records`; dotdot = `../outside`; symlink = `.harness/reglink` → каталог вне репо; absolute = абсолютный путь вне
репо; empty = `""`; nowf = профиль без `workflowPaths` (ось E); noprofile = профиля нет (LEGACY, дверь создаёт свой).
```text
=== old/<значение> (70e9a830d)                                   | === new/<значение> (OBJECT)
default  : door rc=1 trassa-rashozhdenie .harness/registry        | door rc=1 profil-ne-razreshaetsja (resolver: профиль без workflowPaths.registry)
custom   : door rc=1 trassa-rashozhdenie .harness/records         | door rc=1 trassa-rashozhdenie .harness/records; evil_file=same; exec=no
dotdot   : door rc=7 exec=yes (сеял proj/outside/ вне репо)       | door rc=1 profil-ne-razreshaetsja (resolver: workflowPaths вне репо)
symlink  : door rc=1 trassa-rashozhdenie .harness/reglink         | door rc=1 profil-ne-razreshaetsja (вне репо)
absolute : door rc=1 trassa-rashozhdenie <abs>/outside            | door rc=1 profil-ne-razreshaetsja (вне репо)
empty    : door rc=7 exec=yes; line 116: /ci_parity_exceptions.txt: Permission denied | door rc=1 profil-ne-razreshaetsja (значение вне алфавита: пусто)
nowf     : door rc=7 exec=yes; evil_file=same; .harness/registry/trace.tsv=present:anthropic/claude-sonnet-5-5;
           make_task rc=0 TRACE: role=orchestrator model=evil-model fallback=allowed
                                                                  | door rc=1 exec=no err_last=connect ОТКАЗ: trassa-rashozhdenie: registry/trace.tsv ≠ конфигу установки …
                                                                  |   planted=registry/trace.tsv evil_file=same .harness/registry/trace.tsv=absent
noprofile: door rc=7 exec=yes; make_task TRACE …claude-sonnet-5-5 | door rc=7 exec=yes; .harness/registry/trace.tsv=present:anthropic/claude-sonnet-5-5;
                                                                  |   make_task rc=0 TRACE: role=orchestrator model=anthropic/claude-sonnet-5-5
```
(полные строки — вывод прогонов `repro_b1.sh … old` и `… new`, оба RC=0; дверь «после» ни в одном значении не exec'ит при
подложке/неразрешимом профиле и не трогает подложенный файл.) Итог: R136c-B1 в ДВЕРИ закрыт по всем 8 значениям оси.

**1б. ОБХОД R136d-B1** (`bash /tmp/dev-harness-verify/Rev136d-t/repro_parity.sh /tmp/dev-harness-verify/Rev136d`; профиль без `workflowPaths`, конфиг установки дерева):
```text
--- шаг 1: честное подключение (профиль без workflowPaths)
door rc=7
seeded by door: ./registry/ci_parity_exceptions.txt ./registry/trace.tsv
project_paths_resolve .registry = /tmp/dev-harness-verify/Rev136d-t/parity/proj/toy-proj/registry
make_task brief TRACE: TRACE: role=orchestrator model=anthropic/claude-sonnet-5-5 fallback=allowed
parity rc=2 :: NOT_IMPLEMENTED: нет /tmp/dev-harness-verify/Rev136d-t/parity/proj/toy-proj/.harness/registry/ci_parity_exceptions.txt — выйти из правила молча нельзя; положите файл и запишите в нём причины
--- шаг 2: проект объявляет исключения в ПРОФИЛЬНОМ (эффективном) реестре registry/
parity rc=2 :: NOT_IMPLEMENTED: нет …/toy-proj/.harness/registry/ci_parity_exceptions.txt — выйти из правила молча нельзя; …
--- шаг 3: профильный перечень ПУСТ (как сеет дверь), исключения — в НЕпрофильном .harness/registry/
parity rc=0 ::   ok   команда «npm run dev» (.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: …   ok   скрипт «build» не в CI — объявленное исключение: …
make_task/door effective registry still: /tmp/dev-harness-verify/Rev136d-t/parity/proj/toy-proj/registry
RC=0
$ bash /tmp/dev-harness-verify/Rev136d-main/scripts/verify_ci_parity.sh …/parity/proj/toy-proj      (origin/main, для сравнения)
NOT_IMPLEMENTED: нет …/toy-proj/config/ci_parity_exceptions.txt — …   main rc=2
```
Значения оси для гейта OBJECT (замер 1а, колонка parity): dotdot → читает `…/toy-proj/../outside/ci_parity_exceptions.txt`;
symlink → `…/.harness/reglink/…` (вне репо); absolute → `$ROOT//<abs>/…`; nowf → `.harness/registry/…` ≠ резолверу `registry/`.

**1в. Более простая форма** (`/tmp/dev-harness-verify/Rev136d-t/simple_form.py` → клон `/tmp/dev-harness-verify/Rev136d-sf`,
`verify_ci_parity.sh:210-211` заменены на `project_paths_resolve "$ROOT_ABS"` → `.registry`, отказ резолвера — rc 2 именованный):
```text
$ bash simple/verify_ci_parity.sh <состояние шага 3>
  FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением
simple rc=1            (OBJECT на том же состоянии: object rc=0)
$ TMPDIR=… bash fixtures/workshop_project/sessii_136/red_sessii_136.sh        (Rev136d-sf, plain)
sessii_136: клеток 79, зелёных 79, красных 0
RC=0
$ bash scripts/verify_antiplacebo.sh --scope verify_ci_parity                  (Rev136d-sf)
барьеров: 1 · фикстур: 26 · предъявлено красным повторным прогоном: 26   ap RC=0
$ bash scripts/verify_ci_parity.sh                                             (Rev136d-sf, корень харнесса)
… расхождений: 0   root RC=0
```
(`--model`/`--stabs` раннер берёт гейт из `model/` без сиблинга `next_id.sh` — модели понадобится та же копия сиблинга, что
`mkt_dir` делает для `make_task`; это правка батареи, не довод против формы.)

**2. Диф двери 70e9a830d → OBJECT** (`git -C /home/harness/dev-harness diff 70e9a830d dba6589f -- scripts/`, чтение):
```text
 scripts/connect_project.sh | 84 +++++++++++++++++++++++++++++-----------------
 1 file changed, 54 insertions(+), 30 deletions(-)
- REG_REL="$(jq -r '.workflowPaths.registry // ".harness/registry"' harness.project.json 2>/dev/null || printf '.harness/registry')"
- mkdir -p "$REG_REL"   … (блок TRASSA/-s/сравнение/trassa-rashozhdenie/посев/сев перечня — удалён здесь)
+ NEXT_ID_LIB=1 source "$HERE/scripts/next_id.sh" || { … net-rezolvera-putej … exit 1; }
+ KOREN_ABS="$(cd "$KOREN" && pwd -P)"
+ PPR_JSON="$(project_paths_resolve "$KOREN_ABS")" || otkaz "profil-ne-razreshaetsja: $KOREN_ABS"
+ REG_ABS=…'.registry'; [ -n "$REG_ABS" ] || otkaz "profil-bez-registry…"; REG_REL="${REG_ABS#"$KOREN_ABS"/}"
+ [ "$REG_ABS" != "$REG_REL" ] || otkaz "registry-vne-kornja: $REG_ABS"; mkdir -p "$REG_REL"
+ (тот же блок TRASSA … trassa-rashozhdenie … посев; тот же сев ci_parity_exceptions.txt) — после каркаса, до стража секретов
$ sha256sum old/scripts/{make_task,verify_ci_parity,next_id,profile_resolver}.sh == scripts/… OBJECT   (совпадают побайтно)
```

**3. Регресс.**
```text
$ TMPDIR=…/s136p bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 79, зелёных 79, красных 0          RC=0
$ TMPDIR=…/s136m bash … --model
rm: cannot remove '/tmp/dev-harness-fakehome-136/a1-p6-hvost/seed/toy-proj/.git': Directory not empty
sessii_136: клеток 79, зелёных 79, красных 0          RC=0
$ TMPDIR=…/s136s bash … --stabs                        (первый прогон)
error: bad tree object HEAD
cat: /tmp/dev-harness-fakehome-136/a8/seed/toy-proj/.harness/NEXT_TASK.md: No such file or directory   (…ещё 4 такие строки)
модель не зелёная, стабы не гоняются: a1-p6-hvost a3-p3-pin-v-soobshchenii a4-p3-zapis a6-p11-subagent-pin a8-pin-block a9-pin-inline a20-pin-delimiters a34-pin-taskfile-block a44-pin-taskfile-delimiters c1-p17-map
RC=2
$ TMPDIR=…/s136s bash … --stabs                        (повтор, без параллельных прогонов 136)
sessii_136 --stabs: стабов 42, привязок 66, непойманных 0      RC=0
$ TMPDIR=…/s125p bash fixtures/workshop_project/sessii_125/red_sessii_125.sh
… (70 строк ЗЕЛЕНО a01…c22) s125 red: зелёных 70, красных 0     RC=0
$ TMPDIR=…/s125m bash … --model
s125 model: зелёных 70, красных 0     RC=0
$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md      (Rev136d-br2)
КРИТИК: дверь зелёная   ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2     rc=0
```
Мутанты: дельта каждого мутанта критиков (`Critic136v2/mutants`, `Critic136v2b/mutants`) к его базе (модель `c87f566f`, 1–6
строк) наложена `patch` на НАСТОЯЩИЙ `scripts/*` OBJECT (`mut_prep.py`: 19/19 patch_rc=0, changed_vs_OBJECT=True), plain-раннер
на клоне (`mut_run.sh`; после каждого — `git checkout -- scripts/<f>`, итоговый `git status --porcelain` пуст):
```text
m01-noroot               rc=1 зелёных 73, красных 6 | a25 a26 a28 a29 a47 a48
m02-root-in-msg          rc=1 зелёных 73, красных 6 | a25 a26 a28 a29 a47 a48
m03-root-after-separator rc=1 зелёных 73, красных 6 | a25 a26 a28 a29 a47 a48
m04-foreign-root         rc=1 зелёных 73, красных 6 | a25 a26 a28 a29 a47 a48
m05-duplicate-root       rc=1 зелёных 73, красных 6 | a25 a26 a28 a29 a47 a48
m06-taskfile-noroot      rc=1 зелёных 78, красных 1 | a28
m07-no-final-oracle      rc=1 зелёных 76, красных 3 | a30 a49 a50
m08-node-fallback        rc=1 зелёных 78, красных 1 | a31
m09-exact-layer-only     rc=1 зелёных 72, красных 7 | d6 d9 d10 d11 d12 d13 d14
m10-parity-jq-fallback   rc=1 зелёных 78, красных 1 | d7
m11-allow-duplicate      rc=1 зелёных 75, красных 4 | a10 a19 a21 a43
m12-append-root-to-msg   rc=1 зелёных 74, красных 5 | a25 a26 a28 a47 a48
n01-brief-extra-root     rc=1 зелёных 77, красных 2 | a47 a48
n02-taskfile-skip-oracle rc=1 зелёных 78, красных 1 | a49
n03-empty-guard-fallback rc=1 зелёных 78, красных 1 | a50
n04-check-wrong-layer    rc=1 зелёных 77, красных 2 | d9 d11
n05-nested-layer-harness rc=1 зелёных 76, красных 3 | d10 d11 d12
n06-broken-profile-accepted rc=1 зелёных 78, красных 1 | d8
n07-empty-next-selected  rc=1 зелёных 78, красных 1 | a48
```
19/19 красные; наборы совпадают с frozen п.7 (m09 и n05 добавочно красят клетки d12–d14 достройки).

**4. CI-ключи (Rev136d-br2, свой `TMPDIR` на ключ) и правило 7 (Rev136d-br2 vs Rev136d-main).**
```text
br2 context-pack-095        rc=1 | ИТОГ 095: rc=1 КРАСНО: i1: правила проекта не в паке   (параллельно шли правило 7 и мутанты)
    red_pravila_proekta_ne_harsa.sh отдельно: main rc=0, br2 rc=0
br2 095 repeat              rc=0 | ИТОГ 095: rc=0
br2 project-paths-103       rc=0 | ИТОГ 103: rc=0
br2 podkljuchenie-112       rc=0 | ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0   (stderr КЛЕТКА-строк 24 — столько же на main)
main 112                    rc=0 | ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0
br2 rezhim-996              rc=0 | 996: examined=111 mutants=0 mismatches=0
br2 ap-verify_ci_parity     rc=0 | барьеров: 1 · фикстур: 26 · предъявлено красным повторным прогоном: 26
br2 ap-pre_critic           rc=0 | барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
br2 ap-profile_resolver     rc=0 | барьеров: 1 · фикстур: 10 · предъявлено красным повторным прогоном: 10
br2 verify_ci_parity-root   rc=0 | workflow-команд: 19 · скриптов в приёмке: 85 · объявленных исключений: 28 · matrix-ключей: 47 · …
profil_dva_sloja             branch_rc=0 main_rc=0 SAME
izoljacija_projectid         branch_rc=1 main_rc=1 SAME
sharing_agentdb              branch_rc=0 main_rc=0 SAME
config_do_overlay_105        branch_rc=0 main_rc=0 SAME
ext_ustanovki_105            branch_rc=0 main_rc=0 SAME
otkaz_flagov_105             branch_rc=0 main_rc=0 SAME
proba_odin_kod_105           branch_rc=0 main_rc=0 SAME
roli_v_profil_105            branch_rc=0 main_rc=0 SAME
samodostatochnost_repo_060   branch_rc=0 main_rc=0 SAME
github_token_070             branch_rc=0 main_rc=0 SAME
sverka_puti_profylja         branch_rc=0 main_rc=0 SAME
```
`check:wait-guard-128-family-selftest` не гонялся (по заданию — предсуществующее, не находка).

## Числа своей мерой

Клеток 136 — 79 (раннер), стабов/привязок 42/66 (раннер `--stabs`); 125 — 70; мутантов 19, красных 19; значений оси реестра 8,
дверь «после» без exec на подложке/неразрешимом профиле — 7 из 7 (8-е, noprofile, — законный посев, exec rc 7); правило 7 —
11 пар, совпало 11; CI-ключей 9 + повтор 095 + 112 на main; файлов диффа — 3, все в зоне.

## Итог

Дверь и `make_task` R136c-B1 закрыли (путь трассы — единый `project_paths_resolve`, репро по всей оси: до rc 7 + evil-model,
после rc 1 `trassa-rashozhdenie` до exec, файл цел, `.harness/registry/trace.tsv` нет). Третий скрипт зоны — гейт паритета —
по-прежнему разбирает `workflowPaths.registry` своим `jq` с дефолтом `.harness/registry`. На том же законном профиле оси E
он читает перечень исключений не из файла, который посеяла дверь: при честном подключении краснеет rc 2, а с исключениями в
непрофильном `.harness/registry/` зеленеет rc 0. Батарея этого не различает (замер 1б), более простая форма проходит те же
строки приёмки (замер 1в). FAIL по R136d-B1; остальное (пункты 2–5) — OK.
