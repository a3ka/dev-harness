accept

OBJECT=76ce5c30b8ef7c4aeac24ed1f847cc51bf821d6c (tip локальной wip/161/implementer)
НОСИТЕЛЬ=origin wip/161/implementer-r6 tip f5d4895555047fd54e67999789ae2460e7ea0a4a (PR #587, линейно на main a6da17801). Своя мера равенства — `git rev-parse <sha>:<путь>` вместо `diff --stat` оркестратора: scripts/make_task.sh=19fb4f134edf, scripts/spawn_agent.sh=d79bb774393f, fixtures/workshop_project/proektnaja_raskladka_161=d28b70047f9b, одинаково в 76ce5c30b, f5d48955 и HEAD клона. Вне этих путей дельта 76ce5c30b→f5d48955 — только HANDOFF.md, registry/contracts.tsv и вердикты (verdicts/adversary/…-r4, verdicts/critic/…-159-v1, verdicts/review/contracts-161-impl.md), то есть перенос на main.
КЛАСС=КОДОВЫЙ, РИСКОВЫЙ
СУД: repo=dev-harness (frozen/contracts/161/1 → 6d6f4fcdc); предмет=161; фаза=реализация; роль=reviewer; круг=5; вызов=2 (scoped: Р161-1 + регрессы); модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; сессия=Reviewer161Opus2; предыдущий=verdicts/review/contracts-161-impl.md (FAIL, Р161-1)
НЕЗАВИСИМОСТЬ: автор реализации — implementer (MiniMax-M3), клетки — architect, судья — Anthropic, вне семейства автора.
ПИН: `cd /tmp/dev-harness-worktrees/c907157c/wip-161-reviewer; pwd; git rev-parse --show-toplevel` → `/tmp/dev-harness-worktrees/c907157c/wip-161-reviewer` / `/tmp/dev-harness-worktrees/c907157c/wip-161-reviewer`.
Испытания: одноразовый клон /tmp/dev-harness-verify/Reviewer161Opus2/clone (ssh://git@github.com/a3ka/dev-harness.git, ветка wip/161/implementer-r6). OBJECT подтянут в клон fetch'ем из выданного WORKTREE (на origin его нет). GIT_DIR/GIT_WORK_TREE на основной чекаут не использовались. Базовые деревья 847674bf3 и 3782c619d — одноразовые worktree клона, удалены после прогона.

## Вердикт

accept. Блокирующих находок нет. Р161-1 закрыт на моём воспроизведении: 16 вариантов, обе двери. Прежние свойства 161 и регрессы затронутых frozen-батарей зелёные, область правки чистая, красное воспроизведено на обеих базах. Советы С-9…С-12 (ниже и в блоке «Находки») не блокируют. Статус прежних С-1…С-8 — в конце.

## 1. Р161-1 — своё воспроизведение (одноразовая проба /tmp/dev-harness-verify/Reviewer161Opus2/probe.sh)

Мир пробы собран своим bash, не через World из probe.py: main + bare-origin + draft-worktree (wip/759/architect, черновик 761 только там), валидный профиль. Вход — безопасная база `TMPDIR=$WORK/ext` вне проекта. Сначала честный make_task готовит подлинный манифест, затем компонент пути заменяется ссылкой на `main/docs/trap` (checkout) или `main/.git/trap` (.git). Для spawn делается настоящий mint (тег + строка реестра на origin), подлинный манифест кладётся через ссылку. Своя мера: rc, байты stdout, полный отпечаток main с `.git` (путь, тип, sha256 или цель ссылки, `find | sort`), `git status --porcelain --ignored`, `branch --list`, `worktree list --porcelain` до и после двери.

```text
### OBJECT (скрипты 76ce5c30b == f5d48955)
make-state-checkout      rc=1 stdout=0B main_tree=same status=same branches=same worktrees=same  ОТКАЗ: TMPDIR_INSIDE_MAIN: каталог манифеста внутри checkout проекта или его .git: …
make-state-gitdir        rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
make-key-checkout        rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
make-key-gitdir          rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
make-context-checkout    rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
make-context-gitdir      rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
make-file-checkout       rc=0 stdout=1315B main_tree=same status=same   (ссылка-файл удалена как ссылка, запись — обычным файлом во внешнем context)
make-file-gitdir         rc=0 stdout=1315B main_tree=same status=same
make-dangling-checkout   rc=1 stdout=0B same same same same  ОТКАЗ: STATE_PATH_UNRESOLVABLE: каталог манифеста неразрешим: …
make-state-link-outside  rc=0 stdout=1315B main_tree=same               (ссылка на безопасный внешний каталог — без перестраховки)
spawn-state-checkout     rc=1 stdout=0B main_tree=same status=same branches=same worktrees=same  TMPDIR_INSIDE_MAIN
spawn-state-gitdir       rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
spawn-key-checkout       rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
spawn-key-gitdir         rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
spawn-context-checkout   rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
spawn-context-gitdir     rc=1 stdout=0B same same same same  TMPDIR_INSIDE_MAIN
spawn-file-checkout      rc=1 stdout=0B same same same same  ОТКАЗ: MANIFEST_LINK_UNSAFE: файл манифеста — символьная ссылка: …
spawn-file-gitdir        rc=1 stdout=0B same same same same  MANIFEST_LINK_UNSAFE
spawn-dangling-checkout  rc=1 stdout=0B same same same same  STATE_PATH_UNRESOLVABLE
spawn-state-link-outside rc=0 stdout=135B branches=CHANGED worktrees=CHANGED  (только wip/761/architect и .git/worktrees/wip-761-architect — штатный spawn)
honest-spawn             rc=0 stdout=135B branches=CHANGED worktrees=CHANGED  (то же — штатный spawn)

### база 3782c619 (прежний OBJECT-носитель r5) — та же проба
make-{state,key,context,file}-checkout  rc=0 stdout=1315B status=CHANGED[?? docs/trap/]  напр. "> F ./docs/trap/ab472aa520395b47/context/761.tsv"
make-{state,key,context,file}-gitdir    rc=0 stdout=1315B main_tree=CHANGED  напр. "> F ./.git/trap/f2584adf41bdbcd6/context/761.tsv"
spawn-{state,key,context,file}-{checkout,gitdir}  rc=0 stdout=135B branches=CHANGED worktrees=CHANGED  (манифест прочитан через ссылку, ветка и worktree созданы)
make-dangling-checkout  rc=1 (mkdir: File exists)   spawn-dangling-checkout rc=1 «нет манифеста make_task: 761»
```

Итог по закрывающему свойству Р161-1. Все шесть сочетаний «компонент (`dev-harness-project-state` | `<KEY>` | `context`) × цель (checkout | `.git` main)» дают rc 1 `TMPDIR_INSIDE_MAIN` на обеих дверях, stdout пуст, отпечаток main с `.git`, HEAD/индекс/status, ветки и worktree не меняются. На 3782c619 те же 12 вариантов пишут в main/.git (make) или создают ветку и worktree через ссылку (spawn). Сверх задания проверен четвёртый элемент пути — сам файл `<NNN>.tsv` как ссылка. На 3782c619 он тоже пишет в main и спавнит. На OBJECT make удаляет ссылку как ссылку (`rm -f`) и пишет обычный файл, spawn отказывает `MANIFEST_LINK_UNSAFE`. Механизм в коде: `_state_path_canonical` (make_task.sh:347-368, spawn_agent.sh:224-245) разрешает каждый существующий компонент через `cd && pwd -P`, затем `_state_base_is_safe` проверяет итоговый путь (make_task.sh:415-420, spawn_agent.sh:292-297). Проверка стоит до HEALTH/записи/stdout в make (вызов :439) и до i15_gate, тега, ветки и worktree в spawn (:317).

## 2. Прежние свойства 161 и регрессы (свой прогон в клоне, HEAD f5d48955)

```text
$ bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh
mode=bare    rc=0 secs=18 out=0 err=0
mode=--model rc=0 secs=3  err: CONTROL: honest product green
mode=--stabs rc=0 secs=24
  CONTROL: honest product green
  STAB_CAUGHT: optional-skipped: CONTEXT_FOREIGN: missing exact REUSE: docs/reuse.md
  STAB_CAUGHT: foreign-make: CONTEXT_FOREIGN: make_task
  STAB_CAUGHT: foreign-write: FOREIGN_DIRTY: make_task changed foreign project
  STAB_CAUGHT: missing-spawn: MANIFEST_MISSING:
  STAB_CAUGHT: collision-spawn: STATE_KEY_COLLISION: second project accepted first manifest
  STAB_CAUGHT: git-path-spawn: GIT_PATH_COLLISION: second project accepted first manifest
  STAB_CAUGHT: tmpdir-write: STATE_SAFE_MAIN_DIRTY: issued packet wrote into checkout
  STAB_CAUGHT: hash-ignored: HASH_TOOL_UNUSABLE: packet issued with failing hash tool
  STAB_CAUGHT: symlink-bypass: STATE_SAFE_MAIN_DIRTY: issued packet wrote into checkout
```

Bare зелёный, а он включает клетки TMPDIR→main/symlink/.git, PATH-sha256 и PATH-git коллизий, HASH_TOOL_UNUSABLE, LAYER_FOREIGN/CONTEXT_FOREIGN и восемь новых STATE_LINK. Значит, свойства TMPDIR/PATH git/sha256 и LAYER_FOREIGN закрытием не ослаблены.

```text
fixtures/_krasnye_095.sh .                                  rc=0  «ИТОГ 095: rc=0»; строк «— …: rc=0» 17, rc≠0 — 0
fixtures/workshop_project/sessii_136/red_sessii_136.sh      rc=0  «sessii_136: клеток 87, зелёных 87, красных 0»
fixtures/_krasnye_103.sh <клон>                              rc=0  «ИТОГ 103: rc=0»; строк «: rc=0» 14, rc≠0 — 0
fixtures/spawn_agent/red_gejt_javnogo_nomera.sh             rc=0
fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh   rc=0
fixtures/spawn_agent/red_gejt_stroka_frozen_sha.sh          rc=0
fixtures/context_pack_095/red_dver_spawn_manifest.sh        rc=0   (legacy-поток 095: <repo>/.omp/context читается spawn)
fixtures/project_paths_103/red_spawn_reestr_proekta.sh      rc=0
```

CI PR #587 (`gh pr checks 587 --repo a3ka/dev-harness`, rc=0; headRefOid f5d48955…): pass у ap1–ap5, l1–l7, klass, legkij, obshchij, tyazhelyj-itog — 16 из 16 исполненных; vorota — skipping.

## 3. Область правки

`git log --format='%h %an' --name-only 847674bf3..76ce5c30b` (своя мера — по OBJECT; по носителю `a6da1780..f5d48955` тот же набор):

```text
76ce5c30 implementer  scripts/make_task.sh scripts/spawn_agent.sh
788c374a architect    …/proektnaja_raskladka_161/SPEC.md …/probe.py
7cb4392c architect    …/SPEC.md …/probe.py
3782c619 implementer  scripts/make_task.sh scripts/spawn_agent.sh
61b0f26e architect    …/SPEC.md …/probe.py
0d7e23dc implementer  scripts/make_task.sh scripts/spawn_agent.sh
0a480a30 architect    …/probe.py
151d4688 architect    …/SPEC.md
c20d3379 architect    …/SPEC.md …/probe.py
d2422c70 implementer  scripts/make_task.sh scripts/spawn_agent.sh
6e583df6 implementer  scripts/make_task.sh scripts/spawn_agent.sh
bed6aeec architect    …/probe.py
```

`git diff --name-only 847674bf3 76ce5c30b` — ровно четыре пути: два скрипта (ЗОНА implementer) и SPEC.md/probe.py (ЗОНА architect). Чужих путей нет, нормативные документы не тронуты. Атомарность: этот круг — три коммита, у каждого номер предмета и один шаг. Клетки architect (7cb4392c 21:26, 788c374a 21:30) раньше реализации (76ce5c30 21:45). Implementer фикстуры не трогал, так что проверка под код не подогнана.

## 4. Проверка не переписана под реализацию

`git diff 3782c619d 788c374aa -- fixtures/` только добавляет: `state_symlink_must_not_enter_main` (восемь bare-вариантов: make/spawn × state-checkout, state-gitdir, key-checkout, context-gitdir), стаб `symlink-bypass` и абзац SPEC. Единственная правка существующего — `safe_state_stays_outside_main` теперь передаёт `--stub-invoke` своё имя мутанта (`mutant`), а не захардкоженное `tmpdir-write`. Это обобщение для второго стаба на той же клетке, не ослабление: tmpdir-write по-прежнему ловится той же причиной (см. п. 2). Стаб привязан к ветви `stub_invoke` кода architect (Н-39). Счёт своей мерой: grep `^STAB_CAUGHT: ` по stderr `--stabs` даёт 9 (8 прежних + symlink-bypass), `STAB_ZHIV` — 0.

## 5. Красное — тот же барьер (fixture HEAD клона) с `--repo` на базовые деревья

```text
red base=847674bf (до реализации)  bare rc=1  --model rc=0  --stabs rc=1
  bare: MANIFEST_MAIN_ONLY: no unique external manifest before spawn
        PROFILE_PATH_MISSING: absent optional row accepted
        TMPDIR_INSIDE_MAIN: checkout|symlink|gitdir: package not refused before output
        HASH_TOOL_UNUSABLE: packet issued with failing hash tool
        затем Traceback … RuntimeError: NOT_IMPLEMENTED: cannot prepare valid external manifest: rc=0 … files=[]  (см. С-12)
  --model: CONTROL: honest product expected red: MANIFEST_MAIN_ONLY, PROFILE_PATH_MISSING
  --stabs: 4 STAB_CAUGHT, затем «STAB_ZHIV: collision-spawn: []» (прежний С-2)
red base=3782c619 (r5)  bare rc=1  --model rc=0  --stabs rc=0
  bare — строк STATE_LINK_ 20 = 8 UNSAFE + 8 MAIN_DIRTY + 4 SPAWNED, различных вариантов 8:
        STATE_LINK_UNSAFE / STATE_LINK_MAIN_DIRTY: make-{state-checkout,state-gitdir,key-checkout,context-gitdir}
        STATE_LINK_UNSAFE / STATE_LINK_MAIN_DIRTY / STATE_LINK_SPAWNED: spawn-{state-checkout,state-gitdir,key-checkout,context-gitdir}
  --model: CONTROL: honest product green
```

Новый барьер красный против кода, который он закрывает (3782c619), и зелёный на OBJECT. Моя независимая проба (п. 1) даёт то же разделение и дополнительно покрывает key-gitdir, context-checkout, файл-ссылку и висячую ссылку.

## ПРОВОДКА (контракт 038)

guard=`fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh` — барьер именно этого предмета: он исполняет настоящие make_task/spawn_agent. `bash scripts/check_provodka.sh . contracts/161-…md` в клоне → «проводка: guard не подключён: … не вызывается в .githooks/ или .github/workflows/», rc=1. Без изменений с прошлого круга: подключение — интеграционный коммит оркестратора вне зон 161 (прежний С-3), это блок done, не реализации. ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: поведенческой нормы 029-класса в предмете нет.

## Паразитная сложность (контракт 050) — по добавленному в 3782c619→76ce5c30b

- `_state_path_canonical` (по 24 строки в make_task.sh:347-368 и spawn_agent.sh:224-245). (1) п. 2 «манифест вне основного checkout и его .git» на итоговом пути — закрывающее свойство Р161-1. (2) Нового состояния нет: чистая функция, результат в `PROJECT_STATE_CONTEXT_CANON`, отказы `STATE_PATH_UNRESOLVABLE`/`TMPDIR_INSIDE_MAIN` именованы в stderr. (3) Два файла, как у всего state-блока, дубль вырос на 24 строки (прежний С-5). (4) Один аргумент, rc 0/1 — узкий интерфейс, работа скрыта. (5) Потребители — восемь STATE_LINK-клеток bare и моя проба. Проще — `cd "$ctx" && pwd -P` после `mkdir -p` — не проходит: `mkdir -p` прошёл бы по ссылке и создал каталоги внутри main до проверки (STATE_LINK_MAIN_DIRTY). `realpath -m` из PATH возвращает вопрос доверия к PATH-инструменту, который закрыт клетками PATH-git/sha256. ESSENTIAL.
- Канонизация до mkdir в `_project_state_prepare` (обе двери). (1) То же свойство. Отказ до первого побочного эффекта, stdout пуст. (5) STATE_LINK_UNSAFE/MAIN_DIRTY/SPAWNED. ESSENTIAL.
- Повторная канонизация после `mkdir -p` (make_task.sh:835-838). (1) Буквально её требовала формулировка закрывающего свойства Р161-1 («после создания и канонизации»). Но при последовательном входе она не различает: существующий префикс уже разрешён, `mkdir -p` создаёт только литеральный хвост без ссылок. Различие возможно лишь при гонке, а тогда `mkdir -p` уже создал каталоги по подменённой ссылке до повторной проверки. (5) Ни клетки, ни строки приёмки нет. ACCIDENTAL, совет С-9, не блок: вредного состояния не вводит, и её вызвала формулировка прошлого вердикта.
- `rm -f` + `set -C` (noclobber) перед записью (make_task.sh:844-846). `rm -f` ESSENTIAL: файл `<NNN>.tsv` как ссылка в main на 3782c619 пишет в main (моя проба make-file-*), на OBJECT — нет. `set -C` различает только при гонке после `rm -f`, потребителя нет. Стоит одно слово, состояния не вводит. Входит в С-9.
- `MANIFEST_LINK_UNSAFE` (spawn_agent.sh:344-347). (1) «spawn не читает манифест через ссылку», п. 2 «находит именно манифест этого проекта». (2) Явно: отказ с путём. (5) Моя проба spawn-file-* (3782c619 — спавн через ссылку, OBJECT — отказ). Клетки в батарее нет — С-11. ESSENTIAL.
- Глобалы `PROJECT_STATE_CONTEXT`, `PROJECT_STATE_CONTEXT_CANON` и запасная ветвь `${PROJECT_STATE_CONTEXT_CANON:-$PROJECT_STATE_DIR/context}` (spawn_agent.sh:343). `PROJECT_STATE_CONTEXT` читается только внутри `_project_state_prepare`, хватило бы local. Запасная ветвь недостижима: при сбое prepare spawn выходит (:317-318), CANON всегда непуст. Достижимой она прочитала бы неканонический путь, то есть ровно то, что закрывает Р161-1. ACCIDENTAL, совет С-10. Мёртвая ветвь, не дефект поведения.
- Клетки architect `state_symlink_must_not_enter_main` и стаб `symlink-bypass`. (1) Классы Р161-1. (5) bare и `--stabs`. ESSENTIAL. Неполнота покрытия — С-11, обработка предпосылки — С-12.

## СВЕРКА-СТАНДАРТОВ

СВЕРКА-СТАНДАРТОВ: не применяется. AGENTS.md dev-harness не объявляет документ архитектуры и стандарт кода (grep `ARCHITECTURE\.md|CODING-STANDARDS\.md` по AGENTS.md пуст; в harness.project.json это optional-строки профиля без файлов — прежний С-1). sourceCanon не объявлен (в пакете `sourceCanon: null`), поэтому сверка 996 не применяется.

## Счётные утверждения своей мерой

- «Блобы трёх путей между 76ce5c30b и r6 идентичны» (оркестратор, `diff --stat`) — сверено `rev-parse` трёх коммитов, совпадает.
- «CI 16/16 зелёный» — `gh pr checks 587`: 16 pass + vorota skipping, совпадает.
- «8 вариантов STATE_LINK» — в исходнике генератор 2 двери × 4 пары = 8. На 3782c619 — 8 различных вариантов, 20 строк (8+8+4), совпадает.
- 136 «87/87», 095 и 103 — числа из собственного вывода (выше).

## Статус прежних советов

С-1 (станционный Н-301, профиль), С-2 (стабы на 847674bf), С-3 (подключение guard), С-4 (асимметрия hash-клетки), С-6 (граница маркера LAYER_FOREIGN), С-7 (закрытый список каталогов) — без изменений, по-прежнему не блокируют. С-5 — дубль вырос на `_state_path_canonical` (×2), путь манифеста по-прежнему не назван в «нет манифеста make_task». С-8 — шапка spawn_agent теперь перечисляет TMPDIR_UNAVAILABLE, TMPDIR_INSIDE_MAIN, STATE_PATH_UNRESOLVABLE, MANIFEST_LINK_UNSAFE и HASH_TOOL_UNUSABLE; шапка make_task — четыре своих отказа. В этой части закрыт.

## Находки (reslop; status: ready; для переноса в .review/)

```yaml
status: ready
subject: 161 — revizija-mekhanizmov-proektnaja-raskladka (161a), суд реализации, круг 5
object: 76ce5c30b8ef7c4aeac24ed1f847cc51bf821d6c (носитель origin wip/161/implementer-r6 f5d4895555047fd54e67999789ae2460e7ea0a4a, PR #587; блобы make_task.sh=19fb4f134edf, spawn_agent.sh=d79bb774393f, каталог батареи=d28b70047f9b совпадают)
verdict: verdicts/review/contracts-161-impl-v2.md (accept)
reviewer: reviewer (сессия Reviewer161Opus2; anthropic/claude-opus-5-5; вызов 2, scoped)
```

### Блоки

- [x] **Р161-1** (из verdicts/review/contracts-161-impl.md) — закрыт в 76ce5c30b. Своё воспроизведение: 12/12 вариантов «компонент × цель» на обеих дверях дают rc 1 `TMPDIR_INSIDE_MAIN`, stdout пуст, main/.git, ветки и worktree неизменны. На 3782c619 те же 12 красные. Клетки architect STATE_LINK_* зелёные на OBJECT и красные на 3782c619.

### Советы (не блокируют)

- [ ] **С-9 (implementer).** Повторная канонизация после `mkdir -p` и `set -C` в make_task.sh:835-838,845 различают только гонку, и закрывают её лишь наполовину: при подмене ссылки между prepare и `mkdir -p` каталоги в main уже созданы до повторной проверки. Убрать, либо назвать в «НЕ ЗАЩИЩАЕТ» следующей версии, что параллельный подменяющий актор вне модели. Формулировку «после создания» в закрывающем свойстве Р161-1 считать переопределением судьи.
- [ ] **С-10 (implementer).** spawn_agent.sh:343: запасная ветвь `:-$PROJECT_STATE_DIR/context` недостижима (prepare при сбое выходит на :317-318) и, будь она достижимой, читала бы неканонический путь. `PROJECT_STATE_CONTEXT` нужен только внутри prepare — его хватит как local. Обе двери.
- [ ] **С-11 (architect).** Батарея покрывает 4 из 6 сочетаний «компонент × цель» (нет key-gitdir и context-checkout) и не покрывает файл `<NNN>.tsv` как ссылку. Этот вход на 3782c619 пишет в main (make) и спавнит (spawn), а на OBJECT закрыт `rm -f` и `MANIFEST_LINK_UNSAFE`. Регресс этих двух строк батарея сейчас не поймает. Вход — тот же `state_symlink_must_not_enter_main` с компонентом `file`.
- [ ] **С-12 (architect).** `state_symlink_must_not_enter_main` при недоступной предпосылке бросает непойманный `RuntimeError`. Python завершается rc 1 с traceback, хотя SPEC требует rc 2 `NOT_IMPLEMENTED`, и оставшиеся варианты не исполняются (на 847674bf bare обрывается на первом). После слияния база недостижима, поэтому это совет.

  Позиция автора: — (заполняет оркестратор)
