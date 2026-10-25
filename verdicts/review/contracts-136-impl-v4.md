accept
OBJECT=6bf8c232d549157bd2b0041708e502a0fd5e6bbf

# Ревью реализации 136 v2 — круг 5 (SCOPED; слово владельца 2026-10-25 ~15:45) — PR #339, `wip/136/implementer-v2`

Судья: Rev136e (reviewer; модель anthropic/claude-opus — семейство Anthropic). Implementer — implementer-glm (GLM);
architect — по заданию его семейство. Совпадения семейства судьи с авторами нет; трасса семейств в задании иного не показывает.
Задание: `/tmp/dev-harness-verify/orch/task-rev136e.md`. Норма — frozen `frozen/contracts/136/2^{commit}`, текст читал из
основного чекаута, только чтение. Предыдущий круг: Rev136d FAIL на OBJECT `dba6589fc`, один блокер R136d-B1
(`verify_ci_parity.sh:210-211`: путь реестра читался своим jq).

Клоны: SSH `ssh://git@github.com/a3ka/dev-harness.git`, у каждого свой `.git`; GIT_DIR/GIT_WORK_TREE/GIT_SSH_COMMAND не использовал.
- `/tmp/dev-harness-verify/Rev136e` — OBJECT: мутации и вердикт.
- `/tmp/dev-harness-verify/Rev136e-br2` — OBJECT, чистый: CI-ключи и правило 7.
- `/tmp/dev-harness-verify/Rev136e-red` — OBJECT: показ красного.
- `/tmp/dev-harness-verify/Rev136e-main` — `origin/main` = `370658e9`.

Дерево «до» (`dba6589fc`) получено так: `git fetch origin dba6589fc…` в клон, затем `git archive` в
`/tmp/dev-harness-verify/Rev136e-t/before/{scripts,config}`. Дерево «после» — так же из OBJECT в `…/Rev136e-t/after/`.
Скрипты замеров лежат в `/tmp/dev-harness-verify/Rev136e-t/*.sh`.

Детектор утечек перед спавном: `bash scripts/check_no_leak.sh --check /home/harness/dev-harness`.
- Первый прогон: rc 1, «основной чекаут мутировал во время сверки» (параллельные записи других агентов).
- Повтор: rc 0, «основной чекаут чист».

Блокеров: **0**. Советов: 5 (R136e-S1…S5).

перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код

## Вердикт по пунктам задания 1–5

| # | Пункт | Статус | Основание (замеры ниже) |
|---|---|---|---|
| 1 | R136d-B1 закрыт; путь реестра во всех трёх скриптах берётся только из единого резолвера | **OK** | В воротах `verify_ci_parity.sh:222-233` путь реестра идёт только из `project_paths_resolve "$ROOT_ABS"` → `.registry`; собственного jq `.workflowPaths.registry` и конкатенации `$ROOT/<…>` нет (замер 0, grep). В двери (`connect_project.sh:241-247`) и в `make_task.sh:69-73,159-161` — тот же резолвер. Своего jq пути реестра нет ни в одном из трёх скриптов. Репро до/после — 4 честных подключения и матрица 9×6 = 54 мира на каждое дерево (замер 1а/1б), плюс ловушка корневого `config/` (1в). Обход R136d-B1 на «до» был воспроизводим: `nowf Pempty-Hfull` и `nowf Pabs-Hfull` давали rc 0 по непрофильному `.harness/registry`. На «после» эти же миры дают rc 1 и rc 2 с профильным путём. Честный connect без `workflowPaths` даёт rc 0, было rc 2. Значения `../outside`, symlink наружу, абсолютный путь, `""` и отсутствие ключа во всех 6 комбинациях дают rc 1 `parity ОТКАЗ: profil-ne-razreshaetsja`. Обхода не нашёл. |
| 2 | cmp реализации с моделью; ослаблений нет | **OK** | `cmp` модель↔`scripts/` для `connect_project.sh`, `make_task.sh`, `verify_ci_parity.sh` = 0/0/0. Совпадает и копия модели в клоне ветки, и в `origin/main` (`4b5ed323`, architect v3.2). R136d-S1 закрыт моделью: `make_task.sh` побайтно равен `dba6589fc` и модели. Дифф ветки — только 3 файла зоны (замер 0). |
| 3 | Регресс по сырому выводу | **OK** | 136 plain — 87/87 rc 0; `--model` — 87/87 rc 0; `--stabs` — 45/87/0 rc 0. 125 plain и `--model` — 70/70 rc 0. Мутанты m01–m12 и n01–n07 — все 19 красные (rc 1) на настоящих `scripts/*` OBJECT; привязки frozen п.3 соблюдены (m06→a28, m07→a30, m08→a31, m09→d6, m10→d7, n01→a47, n02→a49, n03→a50, n04→d9, n05→d10, n07→a48; n06→d8). `pre_critic.sh contracts/136-…` — rc 0. Красное показано: ворота `dba6589fc` на месте реализации красят ровно f1–f8 (замер 3в). Счёт второй мерой (`jq` по `source.json`) совпадает с выводом раннера. |
| 4 | Ключи CI вокруг трёх скриптов; правило 7 | **OK** | Все rc 0: 095 (ветка и main), 103, 112 63/63 (ветка = main, множества КЛЕТКА-строк stderr совпадают), 996 `examined=111 mismatches=0`, 125 70/70, antiplacebo `verify_ci_parity` 26/26, `pre_critic` 2/2, `profile_resolver` 10/10, ворота на корне харнесса — расхождений 0. Правило 7: в 11 парах из 11 rc ветки равен rc main; `izoljacija_projectid` даёт rc 1 на обеих сторонах (предсуществующее). CI PR #339 на head `6bf8c232`: 16 pass / 1 skipping. |
| 5 | Проверки не переписаны под код | **OK** | `git diff origin/main...HEAD` (от merge-base `bd53c013`) — ровно `scripts/connect_project.sh`, `scripts/make_task.sh`, `scripts/verify_ci_parity.sh`. В `fixtures contracts registry roles .omp verdicts scripts/next_id.sh scripts/profile_resolver.sh workshop` — 0 файлов. Все 5 коммитов ветки — автор `implementer <implementer@dev-harness.local>`, каждый в зоне. Фикстуры, модели и стабы оси F внесены architect'ом в main (`4b5ed323`), не веткой. Двухточечный `git diff origin/main..HEAD` показывает 22 файла — это дрейф main после merge-base (owner-коммиты «Быстрый процесс», HANDOFF, `config/agent_models.json`), а не правки ветки; `git merge-tree origin/main HEAD` проходит чисто, rc 0. |

## Блокеры

Нет. Ни одного состояния дерева, при котором критерий выполнен, а предмет не сделан, я не нашёл. Проверены: ось
`workflowPaths.registry` (9 значений), место исключений (профильный реестр / `.harness/registry` / оба / нигде / корневой `config/`)
и наполнение профильного списка (пусто, как сеет дверь / заполнен / файла нет).

## Советы (не блокируют, обхода не называю)

| ID | Место | Суть |
|---|---|---|
| R136e-S1 | `scripts/verify_ci_parity.sh:172` (= модель, cmp 0) | `ROOT_ABS="$(cd "$ROOT" && pwd -P)"` вычисляется до выбора режима и под `set -e`. Поэтому несуществующий корень даёт безымянный rc 1 (`cd: …: No such file or directory`); раньше было rc 2 `NOT_IMPLEMENTED: нет …/.github — сверять не с чем` (замер 1г). Код остаётся ненулевым, обхода нет. Но rc 1 значит «расхождение», а здесь «нечем проверить». `ROOT_ABS` нужен только в проектной ветке; перенос внутрь `case .harness/*` вернул бы семантику 020. Править модель (architect) и реализацию вместе. |
| R136e-S2 | `scripts/verify_ci_parity.sh:227-232` | Отказы `profil-bez-registry` и `registry-vne-kornja` недостижимы. `project_paths_resolve` отдаёт `.registry` только вида `$REPO_ABS/…` (`next_id.sh:358,410,478`) или падает, и тогда срабатывает `profil-ne-razreshaetsja`. Это тот же класс, что R136d-S4 у двери: защитные ветви, интерфейс не растёт. Совет по 050. |
| R136e-S3 | `fixtures/workshop_project/sessii_136/red_sessii_136.sh:120` (батарея, architect) | `MIR_BASE="$(mktemp -d "${TMPDIR:-/tmp}/…")"` не проверяет rc. При несуществующем `TMPDIR` mktemp падает, `MIR_BASE` пустой, и миры строятся от `/` (`/w-a1-p6-hvost`, `/bin-bez-jq/…`) — замер 3а. Без прав на `/` это шум и мусорные исходы клеток; с правами — запись в корень ФС. Закрывается `|| exit 2`. |
| R136e-S4 | сообщение коммита `6bf8c232` | Ссылается на «модель v3.2 4c400102». Такого объекта нет ни в origin, ни в основном чекауте (`fatal: Not a valid object name`); модель v3.2 — это `4b5ed323` (architect, main). На суть не влияет (cmp с моделью main = 0), но ссылка в истории ведёт в пустоту. |
| R136e-S5 | хранение мутантов | Исходных каталогов `/tmp/dev-harness-verify/Critic136v2/mutants`, `Critic136v2b/mutants` и `/tmp/dev-harness-verify/Adv136/scratch/real-mutants` на станции нет (`No such file or directory`). Мутантов я поднял из дельт, которые сохранил Rev136d (`/tmp/dev-harness-verify/Rev136d-t/mut/<имя>/delta.patch`). Для следующих судей источник стоит хранить в keep-каталоге или в фикстурах. |

## Паразитная сложность (050) — артефакты диффа `dba6589fc → 6bf8c232` (+24/−2, один файл)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| `NEXT_ID_LIB source` + `project_paths_resolve` в проектной ветке ворот (`verify_ci_parity.sh:222-233`) | И-8 «исключения ТОЛЬКО из `<workflowPaths.registry>/ci_parity_exceptions.txt`»; ПЕРЕСЕЧЕНИЕ «103 профильные пути — единственный источник» | нового нет; путь виден в выводе (rc 2 называет профильный путь, отказ называет корень) | число файлов, меняющихся вместе для правила пути реестра, УМЕНЬШИЛОСЬ: было 2 (ворота со своим jq + резолвер), стало 1 (резолвер) | аргументы, env и коды прежние; добавлен один класс отказа rc 1 `profil-ne-razreshaetsja` | клетки f1–f8, стабы s43–s45; дубль логики `next_id.sh` удалён | ESSENTIAL |
| `SELF_DIR`, `ROOT_ABS` (`:171-172`) | нужны резолверу: сиблинг `next_id.sh` и канонический корень | нет | 1 | 2 строки | f-клетки | ESSENTIAL; размещение — совет S1 |
| `profil-bez-registry`, `registry-vne-kornja` (`:227-232`) | защитные ветви | нет | 1 | 4 строки, недостижимы | потребителя нет | совет S2 |

## ПРОВОДКА

Guard `fixtures/workshop_project/sessii_136/red_sessii_136.sh` существует и судит три скрипта предмета. Теперь он различает R136d-B1:
- ось F (f1–f8) и стабы s43 «свой jq», s44 «без резолвера», s45 «резолвер молча» — непойманных 0;
- ворота `dba6589fc` на месте реализации красят ровно f1–f8 (замер 3в).

Step- и role-строки — frozen NOT_RUN (их делает интеграционный коммит оркестратора); в диффе implementer им не место.

## Стенограмма замеров (сырой вывод, rc)

**0. Объект, область, модель** (клон `Rev136e`, cwd = клон)
```text
$ git rev-parse HEAD origin/main FETCH_HEAD
6bf8c232d549157bd2b0041708e502a0fd5e6bbf
370658e9fff1301eb4276e7d275f090c0c266b34
6bf8c232d549157bd2b0041708e502a0fd5e6bbf
$ git merge-base --is-ancestor origin/main HEAD; echo anc=$?
anc=1                                   (main ушёл вперёд после merge-base)
$ git merge-base origin/main HEAD → bd53c013 (HANDOFF: чекпойнт 16:00 UTC 25.10 …); git log mb..origin/main | wc -l → 4
$ git diff --stat origin/main...HEAD
 scripts/connect_project.sh  | 167 ++++++++++++++++++++++++++++++++++++++++++--
 scripts/make_task.sh        |  38 +++++++++-
 scripts/verify_ci_parity.sh |  65 +++++++++++++++++
 3 files changed, 261 insertions(+), 9 deletions(-)
$ git diff --stat origin/main...HEAD -- fixtures contracts registry scripts/next_id.sh scripts/profile_resolver.sh .omp/extensions workshop roles verdicts
(пусто) other_rc=0
$ git diff --stat bd53c013 origin/main -- scripts/{connect_project,make_task,verify_ci_parity,next_id}.sh fixtures/workshop_project/sessii_136 fixtures/workshop_project/sessii_125
(пусто)
$ git merge-tree --write-tree origin/main HEAD → 5defaecb…  mt_rc=0
$ gh pr view 339 --json files → scripts/connect_project.sh +160 -7 | scripts/make_task.sh +36 -2 | scripts/verify_ci_parity.sh +65 -0
$ git log --format='%h %an <%ae>' --name-only origin/main..HEAD
6bf8c232 implementer <implementer@dev-harness.local>  scripts/verify_ci_parity.sh
3ff02301 implementer <implementer@dev-harness.local>  scripts/connect_project.sh
a7730496 implementer <implementer@dev-harness.local>  scripts/connect_project.sh scripts/verify_ci_parity.sh
55c9cc80 implementer <implementer@dev-harness.local>  scripts/make_task.sh
0893960a implementer <implementer@dev-harness.local>  scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh
$ git show 6bf8c232 --stat → scripts/verify_ci_parity.sh | 26 ++++++++++++++++++++++++-- (24 insertions, 2 deletions)
  - _wp_reg="$(jq -r '.workflowPaths.registry // ".harness/registry"' "$ROOT/harness.project.json" 2>/dev/null)"
  - EXCEPTIONS="$ROOT/$_wp_reg/ci_parity_exceptions.txt" ;;
  + SELF_DIR=…; ROOT_ABS="$(cd "$ROOT" && pwd -P)"
  + NEXT_ID_LIB=1 source "$SELF_DIR/next_id.sh" || { … net-rezolvera-putej … exit 1; }
  + PPR_JSON="$(project_paths_resolve "$ROOT_ABS")" || { … profil-ne-razreshaetsja … exit 1; }
  + REG_ABS="$(printf '%s' "$PPR_JSON" | jq -r '.registry')"; [ -n "$REG_ABS" ] || … profil-bez-registry; case "$REG_ABS" in "$ROOT_ABS"/*) …; *) registry-vne-kornja
  + EXCEPTIONS="$REG_ABS/ci_parity_exceptions.txt" ;;
$ for f in connect_project.sh make_task.sh verify_ci_parity.sh; do cmp fixtures/workshop_project/sessii_136/model/$f scripts/$f; done
connect_project.sh cmp_rc=0
make_task.sh cmp_rc=0
verify_ci_parity.sh cmp_rc=0
$ cmp Rev136e-main/fixtures/…/model/$f Rev136e-br2/scripts/$f   (модель в origin/main)
connect_project.sh main-model cmp_rc=0 / make_task.sh main-model cmp_rc=0 / verify_ci_parity.sh main-model cmp_rc=0
$ sha256sum before/scripts/X after/scripts/X   (dba6589fc vs OBJECT)
connect_project.sh, make_task.sh, next_id.sh, profile_resolver.sh — совпадают; verify_ci_parity.sh: ed464594… → 4984bb54…
$ grep -nE 'workflowPaths|\.registry|harness/registry|project_paths_resolve|REG_REL|REG_ABS' scripts/{connect_project,make_task,verify_ci_parity}.sh
connect_project.sh: 181 mkdir -p .harness/… (каркас), 210-211 дефолты workflowPaths в СОЗДАВАЕМОМ профиле (без профиля),
                    241 PPR_JSON="$(project_paths_resolve "$KOREN_ABS")", 243 REG_ABS=…'.registry', 245 REG_REL=…, 255-257 trace по REG_REL
make_task.sh:       69 _PC_JSON="$(project_paths_resolve "$REPO_ABS")", 73 WP_R=…'.registry', 159-161 ранний мягкий резолв → TRACE
verify_ci_parity.sh: 224 PPR_JSON="$(project_paths_resolve "$ROOT_ABS")", 226 REG_ABS=…'.registry', 233 EXCEPTIONS="$REG_ABS/…"
(прочие совпадения — комментарии; jq `.workflowPaths.registry` в коде — ни одного)
$ bash -c 'set -euo pipefail; ROOT=/x …; NEXT_ID_LIB=1 source scripts/next_id.sh; echo …'   (побочные эффекты source в воротах)
ROOT=/x GH=g PKG=p EXC=e RUN=r fails=0 SELF_DIR=s ROOT_ABS=ra / opts_same / PPR_JSON, REG_ABS не затёрты
```

**1а. Честное подключение двери → ворота** (`bash /tmp/dev-harness-verify/Rev136e-t/repro_gate.sh <дерево> <метка>`, часть A).
Clean-мир: CI `npm run build`, приёмка `build`, подложек нет. Установка — дверь, `next_id.sh` и `profile_resolver.sh` дерева,
настоящие `path-guard.ts` и `config/agent_models.json`, двойник workshop с rc 7. После этого в CI подставлен `npm run dev`
(`+mismatch`): посеянный дверью пустой перечень обязан дать rc 1.
```text
##### before (dba6589fc)
nowf      door rc=7 seeded=[./registry/ci_parity_exceptions.txt ] resolver.registry=A-nowf/proj/toy-proj/registry
          gate rc=2 :: NOT_IMPLEMENTED: нет <W>/A-nowf/proj/toy-proj/.harness/registry/ci_parity_exceptions.txt — выйти из правила молча нельзя
          +mismatch gate rc=2 :: NOT_IMPLEMENTED: нет <W>/A-nowf/proj/toy-proj/.harness/registry/ci_parity_exceptions.txt …
std       door rc=7 seeded=[./.harness/registry/ci_parity_exceptions.txt ]   gate rc=0 · +mismatch rc=1 (FAIL ×2)
custom    door rc=7 seeded=[./.harness/records/ci_parity_exceptions.txt ]    gate rc=0 · +mismatch rc=1
noprofile door rc=7 seeded=[./.harness/registry/ci_parity_exceptions.txt ]   gate rc=0 · +mismatch rc=1
##### after (OBJECT)
nowf      door rc=7 seeded=[./registry/ci_parity_exceptions.txt ] resolver.registry=A-nowf/proj/toy-proj/registry
          gate rc=0 :: workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 0 · matrix-ключей: 0 …
          +mismatch gate rc=1 ::   FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлен…|  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением
std       door rc=7 seeded=[./.harness/registry/ci_parity_exceptions.txt ]   gate rc=0 · +mismatch rc=1
custom    door rc=7 seeded=[./.harness/records/ci_parity_exceptions.txt ]    gate rc=0 · +mismatch rc=1
noprofile door rc=7 seeded=[./.harness/registry/ci_parity_exceptions.txt ]   gate rc=0 · +mismatch rc=1
RC=0 (оба прогона)
```
`door.err` честного nowf-подключения пуст. Посеянный `registry/ci_parity_exceptions.txt` — 0 байт.

**1б. Матрица ворот: ось `workflowPaths.registry` × место исключений × список в профиле** (тот же скрипт, часть B).
- Мир: CI `npm run dev`, приёмка `build`, двери нет.
- P — профильный реестр, то есть место, куда указывает значение оси; H — `.harness/registry`.
- full — 2 объявления с причинами; empty — пустой файл, как сеет дверь; abs — файла нет.
- 9 значений × 6 комбинаций = 54 мира на каждое дерево (`ls -d gate/{before,after}/B-* | wc -l` → 54 и 54).
- Значения: nowf — профиль без `workflowPaths`; std — `.harness/registry`; custom — `.harness/records`; symin —
  `.harness/reglink` → `records`; nokey — `workflowPaths` без `registry`; empty — `""`; dotdot — `../outside`; symout —
  `.harness/reglink` → каталог вне репо; absolute — абсолютный путь вне репо.

Ниже свёртка без потери rc; полные строки — в выводе прогонов.
```text
значение   комбинация      before (dba6589fc)                                   after (OBJECT)
nowf       Pfull-Habs      rc=2 нет …/.harness/registry/…                       rc=0 ok ×2 (объявленных исключений: 2)
nowf       Pfull-Hfull     rc=0 ok ×2                                           rc=0 ok ×2
nowf       Pempty-Hfull    rc=0 ok ×2   ← ОБХОД R136d-B1                        rc=1 FAIL ×2 (объявленных исключений: 0)
nowf       Pempty-Habs     rc=2 нет …/.harness/registry/…                       rc=1 FAIL ×2
nowf       Pabs-Hfull      rc=0 ok ×2   ← ОБХОД (профильного перечня нет)        rc=2 нет <W>/B-nowf-Pabs-Hfull/proj/toy-proj/registry/ci_parity_exceptions.txt
nowf       Pabs-Habs       rc=2 нет …/.harness/registry/…                       rc=2 нет …/toy-proj/registry/ci_parity_exceptions.txt
std (P≡H)  Pfull-Habs/Pfull-Hfull/Pabs-Hfull rc=0; Pempty-* rc=1; Pabs-Habs rc=2 (нет …/.harness/registry/…)      — то же на обоих деревьях
custom     Pfull-* rc=0; Pempty-* rc=1; Pabs-* rc=2 (нет …/.harness/records/…)                                    — то же на обоих деревьях
symin      Pfull-* rc=0; Pempty-* rc=1; Pabs-* rc=2 (нет …/.harness/reglink/…)                                    — то же на обоих деревьях
nokey      Pfull-*,Pabs-Hfull rc=0; Pempty-* rc=1; Pabs-Habs rc=2               все 6: rc=1 parity ОТКАЗ: profil-ne-razreshaetsja: <W>/B-nokey-…/proj/toy-proj
empty ""   все 6: rc=2 нет <W>/…/toy-proj//ci_parity_exceptions.txt               все 6: rc=1 parity ОТКАЗ: profil-ne-razreshaetsja
dotdot     Pfull-* rc=0 (исключения ВНЕ репо); Pempty-* rc=1; Pabs-* rc=2 (…/toy-proj/../outside/…)   все 6: rc=1 parity ОТКАЗ: profil-ne-razreshaetsja
symout     Pfull-* rc=0 (сквозь symlink ВНЕ репо); Pempty-* rc=1; Pabs-* rc=2       все 6: rc=1 parity ОТКАЗ: profil-ne-razreshaetsja
absolute   все 6: rc=2 нет <W>/…/toy-proj/<W>/…/outside/ci_parity_exceptions.txt   все 6: rc=1 parity ОТКАЗ: profil-ne-razreshaetsja
RC=0 (оба прогона)
```
Итог по OBJECT:
- Законные значения (nowf, std, custom, symin): заполненный профильный перечень даёт rc 0; пустой — rc 1, даже когда
  `.harness/registry` заполнен; отсутствующий — rc 2 с именем профильного пути.
- Значения вне репо и неразрешимые (nokey, empty, dotdot, symout, absolute): rc 1 `profil-ne-razreshaetsja` при любом
  размещении исключений.
- Поведение ворот совпадает с дверью и `make_task` (тот же резолвер; nokey согласован с R136d-S4).

**1в. Корневая ловушка `config/ci_parity_exceptions.txt` в проектном режиме** (`bash /tmp/dev-harness-verify/Rev136e-t/repro_cfgtrap.sh`)
```text
before nowf   profile-list=absent config/=full  gate rc=2 :: NOT_IMPLEMENTED: нет <W>/nowf-absent/toy-proj/.harness/registry/ci_parity_exceptions.txt
before nowf   profile-list=empty  config/=full  gate rc=2 :: NOT_IMPLEMENTED: нет <W>/nowf-empty/toy-proj/.harness/registry/ci_parity_exceptions.txt
before custom profile-list=absent config/=full  gate rc=2 :: NOT_IMPLEMENTED: нет <W>/custom-absent/toy-proj/.harness/records/ci_parity_exceptions.txt
before custom profile-list=empty  config/=full  gate rc=1 :: FAIL ×2 · объявленных исключений: 0
after  nowf   profile-list=absent config/=full  gate rc=2 :: NOT_IMPLEMENTED: нет <W>/nowf-absent/toy-proj/registry/ci_parity_exceptions.txt
after  nowf   profile-list=empty  config/=full  gate rc=1 :: FAIL ×2 · объявленных исключений: 0
after  custom profile-list=absent config/=full  gate rc=2 :: NOT_IMPLEMENTED: нет <W>/custom-absent/toy-proj/.harness/records/ci_parity_exceptions.txt
after  custom profile-list=empty  config/=full  gate rc=1 :: FAIL ×2 · объявленных исключений: 0
```
Корневой `config/` в проектном режиме игнорируется (И-8); при отсутствующем файле в имени стоит профильный путь.

**1г. Несуществующий корень (совет S1)**
```text
$ bash after/scripts/verify_ci_parity.sh /tmp/dev-harness-verify/Rev136e-t/net-takogo
…/verify_ci_parity.sh: line 172: cd: /tmp/dev-harness-verify/Rev136e-t/net-takogo: No such file or directory     after_rc=1
$ bash before/scripts/verify_ci_parity.sh /tmp/dev-harness-verify/Rev136e-t/net-takogo
NOT_IMPLEMENTED: нет /tmp/dev-harness-verify/Rev136e-t/net-takogo/.github — сверять не с чем                         before_rc=2
```

**3а. Неудачный первый прогон — не засчитан.** Первый plain-прогон я запустил с `TMPDIR=…/s136p`, которого ещё не было.
Вывод:
- `mktemp: failed to create directory via template ‘/tmp/dev-harness-verify/Rev136e-t/s136p/sessii-136-mir.XXXXXXXX’: No such file or directory`;
- затем `mkdir: cannot create directory ‘/w-a1-p6-hvost’: Permission denied`;
- затем ~94 тыс. строк `ln: failed to create symbolic link '/bin-bez-jq/…'`.

Прогон я оборвал (RC=143); это совет R136e-S3. Обрывал командой `pkill -f 'sessii_136/red_sessii_136.sh'`, и этот паттерн мог
задеть одновременные прогоны батареи 136 у других агентов около 15:3x UTC. Сообщить через `agent://Main` не удалось:
guard запретил (Н-85). Если чей-то прогон тогда оборвался — причина во мне, а не в дефекте.

**3б. Регресс — сырой вывод.** Клон `Rev136e`, узкий `TMPDIR` на каждый замер, по одному в переднем плане.
```text
$ env TMPDIR=/tmp/dev-harness-verify/Rev136e-t/s136p bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
sessii_136: клеток 87, зелёных 87, красных 0
RC=0
$ env TMPDIR=/tmp/dev-harness-verify/Rev136e-t/s136m bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model
sessii_136: клеток 87, зелёных 87, красных 0
RC=0
$ env TMPDIR=/tmp/dev-harness-verify/Rev136e-t/s136s bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --stabs
sessii_136 --stabs: стабов 45, привязок 87, непойманных 0
RC=0
$ env TMPDIR=/tmp/dev-harness-verify/Rev136e-t/s125p bash fixtures/workshop_project/sessii_125/red_sessii_125.sh
ЗЕЛЕНО a01-chestnaya … ЗЕЛЕНО c22-zhizn-imya   (70 строк ЗЕЛЕНО, ни одной КРАСНО)
s125 red: зелёных 70, красных 0
RC=0
$ env TMPDIR=/tmp/dev-harness-verify/Rev136e-t/s125m bash fixtures/workshop_project/sessii_125/red_sessii_125.sh --model
(70 строк ЗЕЛЕНО)
s125 model: зелёных 70, красных 0
RC=0
$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md          (Rev136e-br2, относительный путь)
КРИТИК: дверь зелёная   ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2     rc=0
```
Вторая мера счёта — свой `jq` по `source.json`, а не вывод раннера:
- `kletki=87 privjazki=87 stab_keys=45 osi=73 vne_osi=14`; 73+14 = 87 = клеток;
- каталогов `stabs/*/` — 45;
- семьи клеток: a=48 b=5 c=10 d=14 e=2 f=8, в сумме 87.

С раннером совпадает. Счёт frozen-текста (69/54/37) исторический; v3.2 по заданию несёт 87/87/45.

Правило 8: `node .omp/extensions/path-guard.ts --extract-pin 'текст без пары'` → `{"worktree":null}` rc 0. Дифф `path-guard.ts`
на ветке — 0 строк.

Мутанты (`bash /tmp/dev-harness-verify/Rev136e-t/mut_run.sh <префикс>`). Источник дельт и процедура:
- Исходных каталогов критиков на станции нет (совет S5). Дельту каждого мутанта взял из
  `/tmp/dev-harness-verify/Rev136d-t/mut/<имя>/delta.patch`.
- Дельта накладывается `patch` на настоящий `scripts/<f>` OBJECT. Хвостовой `\n` нормализуется: у `connect_project.sh` его нет,
  и без нормализации m01–m06 в первой попытке дали `1 out of 1 hunk FAILED` с пометкой «НЕ ПРОГНАН» — та попытка не засчитана.
- Затем plain-раннер на клоне, после каждого мутанта — `git checkout -- scripts/<f>`. Итог `status: []`, клон чист.
```text
m01-noroot                connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 81, красных 6 | a25 a26 a28 a29 a47 a48
m02-root-in-msg           connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 81, красных 6 | a25 a26 a28 a29 a47 a48
m03-root-after-separator  connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 81, красных 6 | a25 a26 a28 a29 a47 a48
m04-foreign-root          connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 81, красных 6 | a25 a26 a28 a29 a47 a48
m05-duplicate-root        connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 81, красных 6 | a25 a26 a28 a29 a47 a48
m06-taskfile-noroot       connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | a28
m07-no-final-oracle       connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 84, красных 3 | a30 a49 a50
m08-node-fallback         connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | a31
m09-exact-layer-only      verify_ci_parity.sh patch_rc=0 CHANGED rc=1 клеток 87, зелёных 80, красных 7 | d6 d9 d10 d11 d12 d13 d14
m10-parity-jq-fallback    verify_ci_parity.sh patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | d7
m11-allow-duplicate       connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 83, красных 4 | a10 a19 a21 a43
m12-append-root-to-msg    connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 82, красных 5 | a25 a26 a28 a47 a48
n01-brief-extra-root      connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 85, красных 2 | a47 a48
n02-taskfile-skip-oracle  connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | a49
n03-empty-guard-fallback  connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | a50
n04-check-wrong-layer     verify_ci_parity.sh patch_rc=0 CHANGED rc=1 клеток 87, зелёных 85, красных 2 | d9 d11
n05-nested-layer-harness  verify_ci_parity.sh patch_rc=0 CHANGED rc=1 клеток 87, зелёных 84, красных 3 | d10 d11 d12
n06-broken-profile-accepted verify_ci_parity.sh patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | d8
n07-empty-next-selected   connect_project.sh  patch_rc=0 CHANGED rc=1 клеток 87, зелёных 86, красных 1 | a48
status: []
```
19 из 19 красные. Наборы содержат привязки frozen п.3: s26–s30 → m06→a28, m07→a30, m08→a31, m09→d6, m10→d7; s31–s36 → n01→a47,
n02→a49, n03→a50, n04→d9, n05→d10, n07→a48.

**3в. Красное показано для нового барьера** (`bash /tmp/dev-harness-verify/Rev136e-t/red_before.sh`). Клон `Rev136e-red`
@OBJECT: на место `scripts/verify_ci_parity.sh` поставлены ворота `dba6589fc` со своим jq, прогнан plain-раннер, затем `git checkout`.
```text
before-gate rc=1 sessii_136: клеток 87, зелёных 79, красных 8 | красные: f1-vorota-profile-reestr f2-vorota-podmena-v-neprofilnom f3-vorota-reg-dotdot f4-vorota-reg-symlink f5-vorota-reg-absoljut f6-vorota-reg-bez-kljucha f7-vorota-reg-pustoj f8-vorota-iskljuchenij-net
status: []
RC=0
```
Краснеет ровно ось F и ничего больше. На OBJECT те же 8 клеток зелёные (3б).

**4. CI-ключи** (`bash /tmp/dev-harness-verify/Rev136e-t/cikeys.sh br|main <метки>`; ветка — клон `Rev136e-br2` @OBJECT, чистый;
свой `TMPDIR` на каждый ключ)
```text
br   ap-verify_ci_parity        rc=0 | барьеров: 1 · фикстур: 26 · предъявлено красным повторным прогоном: 26
br   ap-pre_critic              rc=0 | барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
br   ap-profile_resolver        rc=0 | барьеров: 1 · фикстур: 10 · предъявлено красным повторным прогоном: 10
br   pre_critic-136             rc=0 | КРИТИК: дверь зелёная   ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
br   verify_ci_parity-root      rc=0 | workflow-команд: 19 · скриптов в приёмке: 85 · объявленных исключений: 28 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
br   project-paths-103          rc=0 | — red_standart_polnyj_nabor.sh: rc=0 ИТОГ 103: rc=0
br   rezhim-996                 rc=0 | freeze-head-plan-preserved: rc=0  996: examined=111 mutants=0 mismatches=0     (npm run --silent check:rezhim-996-family-selftest)
br   context-pack-095           rc=0 | — red_zony_iz_frozen_blobs.sh: rc=0 ИТОГ 095: rc=0
main context-pack-095           rc=0 | — red_zony_iz_frozen_blobs.sh: rc=0 ИТОГ 095: rc=0
br   podkljuchenie-112          rc=0 | ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0     (stderr КЛЕТКА-строк 24)
main podkljuchenie-112          rc=0 | ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0     (stderr КЛЕТКА-строк 24)
$ diff <(grep -o 'КЛЕТКА [^:]*' br-112.err | sort) <(grep -o 'КЛЕТКА [^:]*' main-112.err | sort) → diff_rc=0
sessii-proektov-125 — замер 3б (70/70 plain и --model)
```
Сторону main для 095 и 112 мерил на `51de0a96`. От `370658e9` он отличается только `HANDOFF.md` и `registry/contracts.tsv`
(`git diff --stat 370658e9 51de0a96`), на эти ключи это не влияет.

Правило 7 (`bash /tmp/dev-harness-verify/Rev136e-t/rule7.sh`; ветка = `Rev136e-br2` @OBJECT, main = `Rev136e-main` @`370658e9`;
свой `TMPDIR` на каждый прогон)
```text
profil_dva_sloja             branch_rc=0 main_rc=0 SAME | СВЕРКА: m7
izoljacija_projectid         branch_rc=1 main_rc=1 SAME | обе stderr: «055-батарея: диффпроба c12 — стаб без ручки упал / стаб-пак: поймано 7 из 13» (предсуществующе)
sharing_agentdb              branch_rc=0 main_rc=0 SAME | честная часть: 16/16 зелёная; предъявлений: стабы 9/9 …
config_do_overlay_105        branch_rc=0 main_rc=0 SAME
ext_ustanovki_105            branch_rc=0 main_rc=0 SAME
otkaz_flagov_105             branch_rc=0 main_rc=0 SAME
proba_odin_kod_105           branch_rc=0 main_rc=0 SAME
roli_v_profil_105            branch_rc=0 main_rc=0 SAME
samodostatochnost_repo_060   branch_rc=0 main_rc=0 SAME | 060: стерегомое дерево харнесса: не тронуто
github_token_070             branch_rc=0 main_rc=0 SAME | честная часть: 7/7 зелёная …
sverka_puti_profylja         branch_rc=0 main_rc=0 SAME | обе stderr: «стаб-пак 9/9 пойман, диффпроба ошибок 0, честные 24/24 зелёные»
$ git -C Rev136e-br2 status --porcelain → (пусто)
```
CI PR #339 (`gh pr checks 339 --repo a3ka/dev-harness`, head `6bf8c232…`): 16 pass, 1 skipping (`vorota`). Среди pass:
- ap5 `verify_ci_parity`;
- l4 `podkljuchenie-112`;
- l6 `project-paths-103`;
- l7 `rezhim-996`, `context-pack-095`.

`check:wait-guard-128-family-selftest` локально не гонял: по заданию это предсуществующее.

## Числа своей мерой

| Что | Число |
|---|---|
| Клеток 136 | 87 — раннер; `jq '.kletki|length'` = 87; osi 73 + vne_osi 14 = 87 |
| Стабов / привязок | 45 / 87 — раннер `--stabs`; `jq` даёт `stab_vhod` 45 ключей, `[.stab_vhod[]|length]|add` = 87; каталогов `stabs/*/` 45 |
| Клеток 125 | 70 (plain и `--model`) |
| Мутанты | 19, красных 19 |
| Миры репро ворот | 4 честных подключения + 54 матрицы на каждое дерево (до/после) + 4 мира ловушки `config/` на каждое дерево |
| Значения оси `workflowPaths.registry` | 9 |
| Правило 7 | 11 пар, совпало 11 |
| CI-ключи | 10 на ветке + 2 сравнения на main |
| Файлы диффа | 3, все в зоне |

## Итог

R136d-B1 закрыт. Ворота паритета берут путь реестра только из `project_paths_resolve`, как дверь и `make_task`; свой jq пути
реестра и конкатенации `$ROOT/<…>` в трёх скриптах зоны больше нет.

На законном профиле без `workflowPaths`:
- честное подключение даёт rc 0, было rc 2;
- исключения, подложенные в непрофильный `.harness/registry` при пустом профильном перечне, дают rc 1, было rc 0 (обход);
- значения вне репо и неразрешимые дают именованный rc 1 `profil-ne-razreshaetsja` при любом размещении исключений.

Реализация побайтно равна модели v3.2. Батарея 136 (87/87, 45/87/0), мир 125 (70/70), 19 мутантов, CI-ключи и правило 7 зелёные
или совпадают с main. Новый барьер на старых воротах красит ровно ось F. Дифф — только зона implementer.

Принято (accept). Советы S1–S5 не блокируют.
