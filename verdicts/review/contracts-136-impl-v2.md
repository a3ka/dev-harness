FAIL
OBJECT=70e9a830d7b6f444cc6d7496765d6b35aeebf426

# Ревью реализации 136 v2 (круг 3, последний по капу) — PR #339, ветка `wip/136/implementer-v2`

Судья: Rev136c (reviewer, семейство anthropic; автор реализации — implementer). Клон: `/tmp/dev-harness-verify/Rev136c/repo`
(SSH-клон, `fetch origin wip/136/implementer-v2`, checkout OBJECT; база для «до» — worktree `/tmp/dev-harness-verify/Rev136c/base`
на `origin/main` 04f3c665; объект адверсария 4a6559296 взят `git fetch` из его клона, только чтение). Все прогоны батарей —
копии раннеров с заменой ТОЛЬКО корней миров на `/tmp/dev-harness-verify/Rev136c/scratch/runs/<прогон>/` (`scratch/prep.py`),
по одному, в переднем плане. Текст судимых обязательств — только frozen `frozen/contracts/136/2^{commit}` = 522f21ce.

Число блокеров: **1** (R136c-B1). Советов: 4 (R136c-S1…S4).

## Основание

Исправление B2 адверсария сделано на пути реестра, который дверь вычисляет СВОИМ разбором профиля
(`connect_project.sh:88`: `jq -r '.workflowPaths.registry // ".harness/registry"' harness.project.json`), а читает трассу
`make_task` по пути ЕДИНОГО `project_paths_resolve` (frozen И-6: «`<workflowPaths.registry>/trace.tsv` (путь — из ЕДИНОГО
`project_paths_resolve`)»). На профиле, который 996 принимает законно (`repo:workflowPaths:optional` в `profile_resolver.sh:47`;
`next_id.sh` FALLBACK-NO-WORKFLOW → `registry=$REPO/registry`), эти два пути РАЗНЫЕ. Дверь сверяет и сеет
`.harness/registry/trace.tsv`, exec'ит сессию (rc 7), а бриф берёт подложенный `registry/trace.tsv` с `evil-model`. Это ровно
исход B2 адверсария (`evil-model` в `make_task --kind brief` после зелёной двери) в другом состоянии профиля. Батарея 77/77
зелёная, а свойство модели угроз «рассогласование trace.tsv ↔ конфиг исключено по построению (v2)» не выполнено. Модель
`model/connect_project.sh` несёт тот же дефект (cmp с реализацией = 0), поэтому батарея его не различает.

## Таблица находок

| ID | Класс | Место | Обязательство frozen 136/2 | Названный ОБХОД (критерий выполнен, предмет не сделан) |
|---|---|---|---|---|
| **R136c-B1** | **БЛОКЕР** (дефект двери; батарея и модель его не различают) | `scripts/connect_project.sh:88` (`REG_REL` своим `jq`), то же в `model/connect_project.sh:89` | И-6 (путь трассы — из ЕДИНОГО `project_paths_resolve`); Модель угроз: «от подмены трассы … рассогласование trace.tsv ↔ конфиг исключено по построению (v2)»; ПЕРЕСЕЧЕНИЕ implementer «103 профильные пути — единственный источник» | Проект несёт `harness.project.json` БЕЗ `workflowPaths` (только `schemaVersion/repoId/language/git/contextPack/projectLayer` — профиль, который `profile_resolver` принимает) и закоммиченный `registry/trace.tsv` = `orchestrator<TAB>evil-model<TAB>allowed`. Дверь на OBJECT: сверяет/сеет `.harness/registry/trace.tsv` из конфига, отказов нет, **rc 7, exec двойника**, argv `[--yolo, <корень>, --, MSG]`. Затем настоящий `scripts/make_task.sh --role orchestrator --kind brief` без `--model-trace`: **rc 0, `TRACE: role=orchestrator model=evil-model fallback=allowed`**. Батарея при этом 77/77, `--model` 77/77, `--stabs` 41/64/0 (замеры 3–4). Более простая форма того же свойства: дверь берёт каталог реестра тем же `project_paths_resolve`, что и `make_task` (готовый образец в дереве — `scripts/done_wave.sh:117-124`: `PPR_JSON=$(project_paths_resolve "$ROOT") \|\| die …; REG_ABS=$(… jq -r .registry)`), после сева профиля, с отказом при сбое резолвера; на мире батареи (`.harness/records` объявлен в профиле) путь совпадает, так что строки приёмки остаются выполнимы [INFERENCE: не прогонялось]. |
| R136c-S1 | совет | `scripts/verify_ci_parity.sh:210` | И-8 «исключения ТОЛЬКО из `<workflowPaths.registry>/ci_parity_exceptions.txt`» | Тот же второй разбор `workflowPaths.registry` своим `jq` (не резолвер, без канонизации). На профиле без `workflowPaths` гейт и дверь читают `.harness/registry/`, а эффективный 996-реестр — `registry/`; `registry: "../x"` читает перечень вне репо. Обхода безопасности не называю: перечень исключений — объявление самого проекта. |
| R136c-S2 | совет | `scripts/make_task.sh:158-163` (мягкий ранний резолв) | И-6 | Проба (замер 9): профиль объявляет `ci.workflow`, файла нет → мягкий резолв падает → дефолт трассы не применяется → «нет свидетельства модели». Fail-closed, не обход; у модели исход тот же отказ (строгий резолв до placeholder). Ранний мягкий/поздний строгий — одна функция `project_paths_resolve`, плейсхолдер только ослабляет вход резолвера, поэтому принятый ранним вызовом путь строгий тоже примет; пробы dotdot/symlink/битый профиль/трасса вне реестра → отказ, явный флаг первичен. |
| R136c-S3 | совет | `scripts/verify_ci_parity.sh:200-208` | И-8 | Канонизация `_kanon_h` берёт `pwd -P` самого `.harness`; если `.harness` — symlink-каталог вне репо, слой «под .harness/» проходит. Не прогонялось; клетки d12–d14 этого состояния не несут. |
| R136c-S4 | совет (наследие Rev136-S2/S3/S4) | дверь | NOT_RUN v2 | env-швы `S136_PSTATE_BASE`/`S136_WORKSHOP`, константа `wip-136-demo`, грамматика `subagent-pin.sh` — вне v2 по frozen NOT_RUN. |

## Замеры (команда → сырой вывод)

**1. Область правки** (`git diff --stat origin/main...70e9a830d`):
```text
 scripts/connect_project.sh  | 143 +++++++++++++++++++++++++++++++++++++++++---
 scripts/make_task.sh        |  38 +++++++++++-
 scripts/verify_ci_parity.sh |  43 +++++++++++++
 3 files changed, 215 insertions(+), 9 deletions(-)
$ git diff --name-only origin/main...70e9a830d -- fixtures .omp contracts registry roles workshop scripts/next_id.sh scripts/profile_resolver.sh scripts/check_zones.sh | wc -l
0
$ git log --format='%h %an %s' origin/main..HEAD --name-only
70e9a830 implementer 136 v2-исправление по вердикту адверсария keep136adv (B1/B2): канонизация profilePath и сверка trace.tsv
  scripts/connect_project.sh scripts/verify_ci_parity.sh
6beab588 implementer implementer 136 v2b: регресс 095 i9/i15 — ранний project_paths_resolve сделан толерантным
  scripts/make_task.sh
43f90700 implementer implementer 136 v2: дверь сессии проекта — argv И-4, fail-closed страж/трасса, слой паритета по профилю
  scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh
```
Правило 8: `git diff --stat origin/main HEAD -- .omp/extensions/path-guard.ts …` пуст (rc 0);
`node .omp/extensions/path-guard.ts --extract-pin 'текст без пары; WORKTREE пусто'` → `{"worktree":null}`.

**2. Репро адверсария до/после** (`scratch/attack.sh old|new`; old = скрипты 4a6559296, new = scripts OBJECT; миры `scratch/attacks/`):
```text
### subject=old sha256: 7d223c423b7f 0a6ca29a8968 4aca6c8bcf22
B2 evil     door_rc=7 exec=yes trace_unchanged=yes err=<> | make_task_rc=0 TRACE: role=orchestrator model=evil-model fallback=allowed
B2 dubl     door_rc=7 exec=yes trace_unchanged=yes err=<> | make_task_rc=0 TRACE: role=orchestrator model=second-model fallback=allowed
B2 readonly door_rc=7 exec=yes trace_unchanged=yes err=<> | make_task_rc=0 TRACE: role=orchestrator model=evil-model fallback=allowed
B1 dotdot   parity_rc=0 out=<  ok   команда «npm run dev» … объявленное исключение … ok   скрипт «build» не в CI — объявленное исключение …>
B1 symlink  parity_rc=0 out=<  ok   команда «npm run dev» … объявленное исключение … ok   скрипт «build» не в CI — объявленное исключение …>
### subject=new sha256: 1d91bb196492 0a6ca29a8968 ed464594240c
B2 evil     door_rc=1 exec=no trace_unchanged=yes err=<connect ОТКАЗ: trassa-rashozhdenie: .harness/records/trace.tsv ≠ конфигу установки …/sb/config/agent_models.json > | make_task_rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
B2 dubl     door_rc=1 exec=no trace_unchanged=yes err=<connect ОТКАЗ: trassa-rashozhdenie: … > | make_task_rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
B2 readonly door_rc=1 exec=no trace_unchanged=yes err=<connect ОТКАЗ: trassa-rashozhdenie: … > | make_task_rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
B1 dotdot   parity_rc=2 out=<NOT_IMPLEMENTED: объявленный слой вне .harness/: …/toy-proj/.harness/../../outside-layer.json >
B1 symlink  parity_rc=2 out=<NOT_IMPLEMENTED: объявленный слой вне .harness/: …/toy-proj/.harness/layer-link.json >
```
(make_task_rc=1 на new: дверь отказала на шаге трассы, ДО сева `.harness/project-layer.json`, поэтому резолвер профиля
падает и мягкий дефолт трассы не применяется. Суть исправления — отказ двери до exec при неизменном файле; сессия
через дверь в этом состоянии не поднимается.)

**3. Обход R136c-B1 на OBJECT** (тот же `scratch/attack.sh new`, блок X; на old исход тот же):
```text
=== X (Rev136c): профиль без workflowPaths (996 FALLBACK-NO-WORKFLOW) + подложенный registry/trace.tsv
X door_rc=7 exec=yes err=<>
X door-seeded .harness/registry/trace.tsv=<orchestrator|anthropic/claude-sonnet-5-5|allowed > planted registry/trace.tsv=<orchestrator|evil-model|allowed >
X resolver registry=/tmp/dev-harness-verify/Rev136c/scratch/attacks/fakehome/x-new/seed/toy-proj/registry
X make_task --kind brief (без --model-trace) rc=0 TRACE: role=orchestrator model=evil-model fallback=allowed
X dver argv (NUL): [--yolo] [/tmp/dev-harness-verify/Rev136c/scratch/attacks/fakehome/x-new/seed/toy-proj] [--]
```
Независимая проба только make_task (`scratch/mkt_probe.sh`, свой мир): `profile-without-workflowPaths rc=0 TRACE: role=orchestrator model=evil-model fallback=allowed`.
Покрытие батареей: `grep 'del(.workflowPaths|FALLBACK|registry/trace' fixtures/workshop_project/sessii_136` — клетки с профилем без
`workflowPaths` нет; мир батареи всегда объявляет `registry: ".harness/records"` в `harness.project.json`.

**4. Батарея 136 на реальных scripts** (копии раннера, `scratch/prep.py`, свои миры):
```text
$ bash scratch/run136-plain.sh            → sessii_136: клеток 77, зелёных 77, красных 0   RC=0
$ bash scratch/run136-model.sh --model    → sessii_136: клеток 77, зелёных 77, красных 0   RC=0
$ bash scratch/run136-stabs.sh --stabs    → sessii_136 --stabs: стабов 41, привязок 64, непойманных 0   RC=0
```
Вторая мера (jq, своя): `.kletki|length`=77; `.stab_vhod|keys|length`=41; `[.stab_vhod|to_entries[]|.value|length]|add`=64;
`ls -d stabs/*/ | wc -l`=41; `.osi|length`=63; `.vne_osi|length`=14 (63+14=77).
`cmp scripts/connect_project.sh model/…` → 0 (sha256 1d91bb19… оба); `cmp scripts/verify_ci_parity.sh model/…` → 0 (ed464594… оба);
`make_task.sh` ≠ модели (diff 84 строки: мягкий ранний резолв + строгий на старом месте против поднятого строгого у модели).

**5. Мир 125** (`scratch/run125-*.sh`):
```text
$ bash scratch/run125-p125.sh          → s125 red: зелёных 70, красных 0     RC=0
$ bash scratch/run125-m125.sh --model  → s125 model: зелёных 70, красных 0   RC=0
```
`pre_critic`: `bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md` → rc=0 «КРИТИК: дверь зелёная».

**6. «Проверка не подогнана»** (`scratch/battery_diff.sh`, frozen/136/2=522f21ce → origin/main; 56e0f1dc в origin не опубликован —
база взята по тегу frozen 136/2, от которого critic-v2-accept судил 69/37/54):
```text
== коммиты по батарее frozen/contracts/136/2^{commit}..origin/main
8ffa2c06 architect 136 v2-усиление батареи по вердикту адверсария (keep136adv, B1/B2): +8 клеток, +
old: cells=69 stabs=37 binds=54 osi=55 vne=14
new: cells=77 stabs=41 binds=64 osi=63 vne=14
removed cells: []
removed stabs: []
removed binds: []
added cells: [c10-kontrol-trassa-ravna c6-trassa-podmena-modeli c7-trassa-dubl-strok c8-trassa-lishnjaja-stroka c9-trassa-readonly d12-sloi-dotdot-vyhod d13-sloi-symlink-naruzhu d14-kontrol-symlink-vnutri ]
added stabs: [s38-parity-prefiks-tolko s39-dver-trassa-molcha-prinimaet s40-dver-trassa-perezapisyvaet s41-dver-trassa-dopisyvaet ]
changed old-cell definitions in source.json:      (пусто)
== старые стабы: изменённые файлы                 (нет изменённых/удалённых)
```
Раннер: удалённые некомментарные строки — только прежняя строка `ORDER=` (заменена надмножеством); прочее — добавленные
`k_c6…k_c10`, `k_d12…k_d14` и их ветви `run_cell`. Модели: +trassa-rashozhdenie в двери, +канонизация слоя в паритете —
это ровно свойства вердикта адверсария, обе ветви на старых 69 клетках зелёные; автор батареи — architect, не implementer;
implementer фикстур не касался (замер 1).

**7. Мутанты на НАСТОЯЩИХ scripts** (`scratch/mut_prep.py`: дельта мутанта к модели frozen 136/2 → `patch` на `scripts/*` OBJECT; `scratch/mut_run.sh`: plain-раннер с подменой одного субъекта):
```text
m01-noroot: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
m02-root-in-msg: base=frozen/contracts/136/2^{commit} delta_lines=3 patch_rc=0 applied=True
m03-root-after-separator: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
m04-foreign-root: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
m05-duplicate-root: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
m06-taskfile-noroot: base=frozen/contracts/136/2^{commit} delta_lines=1 patch_rc=0 applied=True
m07-no-final-oracle: base=frozen/contracts/136/2^{commit} delta_lines=6 patch_rc=0 applied=True
m08-node-fallback: base=frozen/contracts/136/2^{commit} delta_lines=3 patch_rc=0 applied=True
m09-exact-layer-only: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
m10-parity-jq-fallback: base=frozen/contracts/136/2^{commit} delta_lines=3 patch_rc=0 applied=True
m11-allow-duplicate: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
m12-append-root-to-msg: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
n01-brief-extra-root: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
n02-taskfile-skip-oracle: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
n03-empty-guard-fallback: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
n04-check-wrong-layer: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
n05-nested-layer-harness: base=frozen/contracts/136/2^{commit} delta_lines=1 patch_rc=0 applied=True
n06-broken-profile-accepted: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
n07-empty-next-selected: base=frozen/contracts/136/2^{commit} delta_lines=2 patch_rc=0 applied=True
---
m01-noroot                     rc=1 | sessii_136: клеток 77, зелёных 71, красных 6 | красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv a47-brief-struktura a48-pustoj-next-brief
m02-root-in-msg                rc=1 | sessii_136: клеток 77, зелёных 71, красных 6 | красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv a47-brief-struktura a48-pustoj-next-brief
m03-root-after-separator       rc=1 | sessii_136: клеток 77, зелёных 71, красных 6 | красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv a47-brief-struktura a48-pustoj-next-brief
m04-foreign-root               rc=1 | sessii_136: клеток 77, зелёных 71, красных 6 | красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv a47-brief-struktura a48-pustoj-next-brief
m05-duplicate-root             rc=1 | sessii_136: клеток 77, зелёных 71, красных 6 | красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv a47-brief-struktura a48-pustoj-next-brief
m06-taskfile-noroot            rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: a28-taskfile-argv
m07-no-final-oracle            rc=1 | sessii_136: клеток 77, зелёных 74, красных 3 | красные: a30-finalnyj-orakul a49-cr-para-v-taskfile a50-strazh-nulevoj-fajl
m08-node-fallback              rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: a31-net-node
m09-exact-layer-only           rc=1 | sessii_136: клеток 77, зелёных 70, красных 7 | красные: d6-sloi-drugoe-imja d9-sloi-drugoe-imja-poterjan d10-sloi-vlozhennoe-imja d11-sloi-vlozhennoe-poterjan d12-sloi-dotdot-vyhod d13-sloi-symlink-naruzhu d
m10-parity-jq-fallback         rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: d7-bez-jq
m11-allow-duplicate            rc=1 | sessii_136: клеток 77, зелёных 73, красных 4 | красные: a10-pin-duplicate a19-pin-inline-mixed a21-pin-taskfile-duplicate a43-pin-taskfile-inline-mixed
m12-append-root-to-msg         rc=1 | sessii_136: клеток 77, зелёных 72, красных 5 | красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a47-brief-struktura a48-pustoj-next-brief
n01-brief-extra-root           rc=1 | sessii_136: клеток 77, зелёных 75, красных 2 | красные: a47-brief-struktura a48-pustoj-next-brief
n02-taskfile-skip-oracle       rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: a49-cr-para-v-taskfile
n03-empty-guard-fallback       rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: a50-strazh-nulevoj-fajl
n04-check-wrong-layer          rc=1 | sessii_136: клеток 77, зелёных 75, красных 2 | красные: d9-sloi-drugoe-imja-poterjan d11-sloi-vlozhennoe-poterjan
n05-nested-layer-harness       rc=1 | sessii_136: клеток 77, зелёных 74, красных 3 | красные: d10-sloi-vlozhennoe-imja d11-sloi-vlozhennoe-poterjan d12-sloi-dotdot-vyhod
n06-broken-profile-accepted    rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: d8-profil-bit
n07-empty-next-selected        rc=1 | sessii_136: клеток 77, зелёных 76, красных 1 | красные: a48-pustoj-next-brief
```

**8. Регресс** (`scratch/regress.sh a` на OBJECT; `scratch/baseline_all.sh` на origin/main для rc≠0):
```text
ci-parity                                    rc=0 t=1s | workflow-команд: 19 · скриптов в приёмке: 85 · объявленных исключений: 28 · matrix-ключей: 47 · …
pre_critic-136                               rc=0 t=11s | КРИТИК: дверь зелёная
red_profil_dva_sloja                         rc=0 t=32s | 054-батарея зелёная
red_profil_dva_sloja--model                  rc=1 t=0s | ОТКАЗ: нет AGENTS.md мастерской: --model
red_izoljacija_projectid                     rc=1 t=31s | стаб-пак: поймано 7 из 13
red_izoljacija_projectid--model              rc=1 t=31s | стаб-пак: поймано 7 из 13
red_sharing_agentdb                          rc=0 t=77s | честная часть: 16/16 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 16/16
red_sharing_agentdb--model                   rc=1 t=0s | ОТКАЗ: предмет отсутствует: --model/workshop (шаг шаринга agent.db — контракт 058)
red_config_do_overlay_105                    rc=0 t=5s | 105 И-2: установка несёт 0 расширений; клетка зелёная
red_config_do_overlay_105--model             rc=0 t=5s | 105 И-2: установка несёт 0 расширений; клетка зелёная
red_ext_ustanovki_105                        rc=0 t=3s | 105 И-1: установка несёт 0 расширений; клетка зелёная
red_ext_ustanovki_105--model                 rc=0 t=2s | 105 И-1: установка несёт 0 расширений; клетка зелёная
red_otkaz_flagov_105                         rc=0 t=3s | 105 И-4: установка несёт 0 расширений; шесть форм запретного флага + один посторонний;
red_otkaz_flagov_105--model                  rc=0 t=2s | 105 И-4: установка несёт 0 расширений; шесть форм запретного флага + один посторонний;
red_proba_odin_kod_105                       rc=0 t=5s | 105 И-5: установка несёт 0 расширений; клетка зелёная
red_proba_odin_kod_105--model                rc=0 t=5s | 105 И-5: установка несёт 0 расширений; клетка зелёная
red_roli_v_profil_105                        rc=0 t=2s | 105 И-3: установка несёт 0 расширений; клетка зелёная
red_roli_v_profil_105--model                 rc=0 t=3s | 105 И-3: установка несёт 0 расширений; клетка зелёная
red_samodostatochnost_repo_060               rc=0 t=3s | 060: стерегомое дерево харнесса: не тронуто
red_samodostatochnost_repo_060--model        rc=1 t=0s | ОТКАЗ: корень харнесса не открывается: --model
red_github_token_070                         rc=0 t=10s | честная часть: 7/7 зелёная; предъявлений: стабы 7/7 + дифф 7/7 + честные 7/7
red_github_token_070--model                  rc=1 t=0s | 070-батарея ОТКАЗ: probe toy-мира упал rc=2 — мир батареи сломан, не предмет
red_sverka_puti_profylja                     rc=0 t=10s | итог 059-батареи: стаб-пак 9/9 пойман, диффпроба ошибок 0, честные 24/24 зелёные
red_sverka_puti_profylja--model              rc=1 t=0s | 059-батарея ОТКАЗ: нет резолвера: --model/scripts/profile_resolver.sh
--- база origin/main 04f3c665 (тот же rc):
base-izoljacija_projectid                    rc=1 | стаб-пак: поймано 7 из 13
base-izoljacija_projectid--model             rc=1 | стаб-пак: поймано 7 из 13
base-profil_dva_sloja--model                 rc=1 | ОТКАЗ: нет AGENTS.md мастерской: --model
base-sharing_agentdb--model                  rc=1 | ОТКАЗ: предмет отсутствует: --model/workshop (шаг шаринга agent.db — контракт 058)
base-samodostatochnost_repo_060--model       rc=1 | ОТКАЗ: корень харнесса не открывается: --model
base-github_token_070--model                 rc=1 | 070-батарея ОТКАЗ: probe toy-мира упал rc=2 — мир батареи сломан, не предмет
base-sverka_puti_profylja--model             rc=1 | 059-батарея ОТКАЗ: нет резолвера: --model/scripts/profile_resolver.sh
```
Ключи `--model` батарей лаунчера, где rc 1, принимают `--model` за путь (`ОТКАЗ: …: --model`) одинаково на main и OBJECT — правило 7 «тот же rc» выполнено. `check:context-pack-095`, `check:project-paths-103`, `check:rezhim-996`, `check:podkljuchenie-112`, antiplacebo `verify_ci_parity` — своим прогоном НЕ ЗАПУСКАЛИСЬ (стоп по блокеру/бюджету).

**9. make_task: ранний мягкий / поздний строгий резолв** (`scratch/mkt_probe.sh`, свои миры, настоящий `scripts/make_task.sh`):
```text
control-registry-trace             rc=0 TRACE: role=orchestrator model=ok-model fallback=allowed
registry-dotdot-out                rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
registry-symlink-out               rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
profile-broken                     rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
no-ci-placeholder                  rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
trace-outside-registry             rc=1 ОТКАЗ: нет свидетельства модели: orchestrator
explicit-flag-wins                 rc=0 TRACE: role=orchestrator model=flag-model fallback=allowed
profile-without-workflowPaths      rc=0 TRACE: role=orchestrator model=evil-model fallback=allowed
```

## Чек-лист (1)–(7)

| # | Пункт | Статус | Основание |
|---|---|---|---|
| 1 | Область правки и неизменность чужого | **OK** | 3 файла зоны implementer; фикстуры/страж/`path-guard.ts`/контракт/реестр/`next_id.sh`/`profile_resolver.sh`/`workshop` — 0 файлов (замер 1). Атомарность: 3 коммита implementer одного предмета 136, каждый со ссылкой на причину (реализация / регресс 095 / B1-B2 адверсария). |
| 2 | Репро адверсария B1/B2 до → после | **OK** | 4a6559296: B2 rc 7 + exec + `TRACE … evil-model`; B1 rc 0 (оба). OBJECT: B2 → `trassa-rashozhdenie` rc 1, exec нет, файл байт в байт (`cmp`); B1 → rc 2 с именем объявленного пути (замер 2). |
| 3 | Вся батарея на реальных scripts | **OK** | 77/77 plain, 77/77 `--model`, 41/64/0 `--stabs`; 125 — 70/70 plain и `--model`; `pre_critic` rc 0 (замеры 4–5). |
| 4 | Проверка не подогнана; модели честны; реализация = модели | **OK с оговоркой → B1** | removed=[] по клеткам/стабам/привязкам, 69/37/54 ⊂ 77/41/64, определения старых клеток не изменены, старые стабы не тронуты (замер 6). Модели двери/паритета = реализации побайтно — и поэтому модель НЕСЁТ дефект B1 (второй разбор `workflowPaths.registry`), батарея его не различает. make_task: мягкий/строгий резолв обхода не дал (замер 9, R136c-S2). |
| 5 | Регресс CI-ключей | **частично** | Свои прогоны: `check:ci-parity` rc 0; правило 7 — 11 батарей лаунчера без ключа и с `--model`: rc на OBJECT = rc на origin/main во всех 22 парах (замер 8). 095/103/996/112 своим прогоном НЕ ЗАПУСКАЛИСЬ: стоп по найденному блокеру и бюджету (по заданию — CI объекта зелёный, 16 pass; это чужой замер, не мой). |
| 6 | Мутанты m01–m12/n01–n07 на реальной реализации | **OK** | дельта каждого мутанта к модели frozen 136/2 (1–6 строк) наложена `patch` на НАСТОЯЩИЙ `scripts/*` OBJECT (все 19 — patch rc 0), plain-раннер: все 19 rc 1 (замер 7). |
| 7 | Прежние находки закрыты | **OK** | Rev136-B1 (хвост `$KOREN`): дописывания нет, финал `exec "$WORKSHOP_BIN" --yolo "$KOREN" -- "$MSG"` (`connect_project.sh:299`), NUL-argv в X: `[--yolo] [<корень>] [--] MSG`; a25/a26/a28/a29/a47 зелёные, m02/m12/n01 их красят. Отступления: (а) оракул — только `node path-guard.ts --extract-pin` на целом MSG, нет стража/node → `strazh-net` (a27/a31; m07/m08/n03 красны); (б) трасса — из `config/agent_models.json`, `jq -er` без условия наличия файла → `trassa-net-konfiga` (b3–b5); (в) режим паритета — по объявленному `projectLayer.profilePath` с канонизацией (d4–d14; m09/m10/n04–n06 красны). |

## ПРОВОДКА

guard `fixtures/workshop_project/sessii_136/red_sessii_136.sh` существует, судит именно три скрипта предмета и зелёный на OBJECT
во всех трёх режимах; step-строки `sessii_136` в `registry/ci-steps.tsv` нет и role-строки в `roles/orchestrator.md` нет —
frozen NOT_RUN «интеграционные коммиты — оркестратор за реализацией», в diff implementer им не место. Поведенческая норма идёт
role-каналом — по тексту ПРОВОДКИ, не судится здесь.

## Паразитная сложность (050) — по артефактам диффа

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| флаг `--task-file F` двери | И-4 | явное (аргумент) | 1 | +1 флаг, выбор MSG | a28, a34–a46 | ESSENTIAL |
| сканер токенов + `PIN_CHUZHOJ`/`PIN_DUBL` | И-1 | нет, счётчики | 2 (regex дублирует `path-guard.ts`) | глубокий | a8–a24, a34–a46; финальный судья — настоящий страж | ESSENTIAL (цена суда до exec) |
| `strazh-net` | И-6/В-5 | нет | 1 | 2 строки | a27, a31, a50 | ESSENTIAL |
| `trassa-net-konfiga` + `trassa-rashozhdenie` | И-6 | файл `trace.tsv` под `REG_REL` — виден по пути | **2: дверь (`jq` по профилю) и `project_paths_resolve` (make_task) обязаны меняться вместе — второй разбор пути реестра** | мелкий: свой мини-резолвер | b3–b5, c6–c10; дублирует логику `next_id.sh:project_paths_resolve` | **ACCIDENTAL** — фрагмент `connect_project.sh:88`, отсутствующее свойство «путь трассы двери = путь make_task», простая форма `project_paths_resolve` (как `done_wave.sh:117-124`) → R136c-B1 |
| сев `ci_parity_exceptions.txt` | И-8 | файл, виден | 1 | 1 строка | c3/d1 | ESSENTIAL |
| `$PSTATE/bin/subagent-pin.sh` | И-3/В-2 | файл под `$PSTATE` | 1 | генерируемый | a6 | ESSENTIAL (наследие модели) |
| env `S136_PSTATE_BASE`, `S136_WORKSHOP` | швы батареи | неявное (env) | 2 (дверь + батарея) | интерфейс растёт ради тестов | только батарея | совет (наследие, Rev136-S2/S4) |
| предикат режима + канонизация слоя (паритет) | И-8 | нет | 1 | глубокий | d4–d14 | ESSENTIAL; `_wp_reg` вторым `jq` — R136c-S1 |
| мягкий ранний `project_paths_resolve` (make_task) | И-6 дефолт трассы | нет | 1 (два вызова одной функции) | +6 строк | c1–c5, 095 i9/i15 | ESSENTIAL (более простая форма «один вызов» роняет 095 i9/i15 — замер implementer, мной не перемерен) |
| бриф без фильтра ролей | И-7 | нет | 1 | 1 условие | c2, c4 | ESSENTIAL |

## Промежуточный доклад (25-я минута)

Область правки чистая, B1/B2 адверсария закрыты (замер 2), батарея 77/77·77/77·41/64/0 и 125 70/70 зелёные на реальных
scripts; найден обход X (R136c-B1) — бриф принимает подложенную трассу при профиле без `workflowPaths`; дальше — мутанты и
правило 7.

## Что нужно для закрытия (не проектирую — называю)

R136c-B1: путь реестра, где дверь сеет и сверяет трассу, обязан совпадать с путём, откуда `make_task` её читает (И-6), во всех
профилях, которые принимает 996 — в том числе без `workflowPaths`; и батарея должна нести клетку с таким профилем и подложенным
`registry/trace.tsv` (зона architect). Кап кругов исчерпан: дальнейший маршрут — решение оркестратора/владельца.
