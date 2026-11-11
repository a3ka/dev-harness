accept
OBJECT=1c3a9c5c881e3e93c51f8f1ff5136ba6819e7682
КЛАСС=рисковый
СУД: repo=a3ka/dev-harness; предмет=186; фаза=реализация; роль=reviewer; вызов=2/2 (scoped по дельте Б-1/Б-2); модель-план=anthropic/claude-opus-5-5; сессия=Rev186v2 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; судимый PR=#803 wip/186/orchestrator 8c7b3aab7482f4e9b90b1111b9f0332970aa2d87; контракт=frozen/contracts/186/1; адверсарий=verdicts/adversary/contracts-186-impl-v2.md (accept, OBJECT 61b2b2bf8); предыдущий=verdicts/review/contracts-186-impl-v1.md (FAIL, OBJECT 61b2b2bf8cdde8199cd2b7ea23650ea83beea20a)

# Вердикт reviewer — 186 «хранитель архитектуры», реализация, вызов 2/2

**accept.** Оба блока вызова 1 закрыты:
- **Б-1:** дверь сверяет HEAD с `headRefOid` и чистоту дерева до `npm run check`. Мутанты реализации краснеют.
- **Б-2:** клетка к5 батареи 074 снова судит по фиксированной таблице литералов. Дрейф, лишний и убранный юнит краснеют.

Новых блоков нет. Советов пять: С-1…С-3 перенесены из v1 и открыты, С-4 и С-5 новые. Наблюдений два. Все в reslop-файле `.review/2026-11-11-87.md` клона `/tmp/dev-harness-verify/Rev186v2/repo`, `status: ready`, в коммит не входит.

Это scoped-повтор по ПРИЁМКЕ-СУДЬИ v2. Полный `check_zones.sh` не запускался. Неизменённые поверхности (§1–3, §4а, §6, станция) повторно не исследовались: дельта их не трогает (см. §0).

Клон: `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev186v2/repo`, свой `.git`. Деревья — worktree этого клона:

| дерево | что |
|---|---|
| `w/obj` | OBJECT |
| `w/pr` | 8c7b3aab |
| `w/main` | origin/main 0a4e9c49 |
| `w/prefix` | ef6cb947 — дверь до правки Б-1 |
| `w/mut*`, `w/m074*` | мутанты |

## 0. Кандидат и дельта

```
$ git rev-parse origin/wip/186/implementer origin/wip/186/orchestrator origin/main
1c3a9c5c881e3e93c51f8f1ff5136ba6819e7682
8c7b3aab7482f4e9b90b1111b9f0332970aa2d87
0a4e9c490acb7c01d6d32b55b4d8f787e34959a8
$ git fetch origin 61b2b2bf8cdde8199cd2b7ea23650ea83beea20a     # прежний OBJECT после перебазирования ветки недостижим, взят по SHA
$ git log --format='%h %an' 61b2b2bf8..1c3a9c5c8
1c3a9c5c architect
8177d235 implementer
ef6cb947 implementer
13ba7311 architect
$ git range-diff 61b2b2bf8~12..61b2b2bf8 1c3a9c5c8~14..1c3a9c5c8
 2..11: 1546ccb4 … d7f23c4a  =  (без изменений)
 -:  -------- > 11:  13ba7311 186 Б-1: клетки двери …
12:  61b2b2bf = 12:  ef6cb947 186: дверь L1 по красным клеткам адверсария (вызов 1) …
 -:  -------- > 13:  8177d235 186 Б-1: дверь L1 сверяет checkout с head PR …
 -:  -------- > 14:  1c3a9c5c 074 Б-2 (186): к5 — фиксированная таблица PIN-литералов …
$ git diff --stat 61b2b2bf8 1c3a9c5c8
 fixtures/ops_server/red_server_obvjazka_074.sh     | 66 ++++++++++++-----
 .../architecture_steward_186/door_control.py       | 15 ++++
 .../architecture_steward_186/door_probe.py         | 84 ++++++++++++++++++++--
 scripts/merge_architecture_pr.sh                   | 24 ++++++-
```

ef6cb947 — тот же патч, что 61b2b2bf. Ветку перебазировали так, что клетки architect (13ba7311) стоят до правки двери.

Своя мера по всем путям предмета: PR 8c7b3aab совпадает с OBJECT.

```
$ git diff --exit-code --stat 1c3a9c5c8 origin/wip/186/orchestrator -- scripts/merge_architecture_pr.sh scripts/check_architecture_pin.sh fixtures/workshop_project/architecture_steward_186 fixtures/ops_server/red_server_obvjazka_074.sh
subject4 diff rc=0
$ git diff --exit-code --stat 1c3a9c5c8 origin/wip/186/orchestrator -- <все 15 путей предмета + contracts/186-hranitel-arhitektury.md>
all-subject diff rc=0
$ git diff 9209e817 origin/wip/186/orchestrator -- registry/ci-steps.tsv registry/ci-zamery.tsv
(пусто)       # шаг CI тот же, что в v1
```

## 1. Б-1 закрыт — дверь судит то дерево, которое принято

Правка двери (`scripts/merge_architecture_pr.sh:220-224`) стоит после CI и до `npm run check`:

```
head = call(['git', 'rev-parse', 'HEAD'], project).strip()
if head != sha:
    refuse('CHECKOUT_NOT_AT_PR_HEAD')
if call(['git', 'status', '--porcelain'], project).strip():
    refuse('CHECKOUT_DIRTY')
```

`call()` при rc≠0 git даёт `broken()`, то есть rc 2.

Батарея на OBJECT, своя мера (awk по строкам `186 `):

```
$ bash …/red_architecture_186.sh --repo . ; rc=0
lines186=72 ok=72 KRASNO=0 door=46 pin=5
$ … --model                                  → model lines186=72 ok=72 KRASNO=0, model rc=0
$ … --stabs                                  → total=71 caught=71 ZHIV=0, stabs rc=0
  186 door skip_head_checkout caught: rc=0 output=
  186 door skip_dirty caught: rc=0 output=
AST door_probe.py: 61b2b2bf8 CASES 35 MUTATIONS 35 → 1c3a9c5c8 CASES 46 MUTATIONS 37   (+11 клеток, +2 стаба — сходится с заявленным)
```

Строки клеток Б-1 на OBJECT:

```
186 door checkout_main_l1 ok: rc=1 output=CHECKOUT_NOT_AT_PR_HEAD
186 door checkout_main_l2 ok: rc=1 output=CHECKOUT_NOT_AT_PR_HEAD
186 door checkout_main_l3 ok: rc=1 output=CHECKOUT_NOT_AT_PR_HEAD
186 door dirty_untracked_l1 ok: rc=1 output=CHECKOUT_DIRTY
186 door dirty_modified_l1 ok: rc=1 output=CHECKOUT_DIRTY
186 door dirty_baseline_swap_l3 ok: rc=1 output=CHECKOUT_DIRTY
186 door dirty_reverted_l1 ok: rc=0 output=СЛИТО: … head a266d7c0…
186 door detached_head_l1 ok: rc=0 output=СЛИТО: …
186 door other_branch_at_head ok: rc=0 output=СЛИТО: …
186 door no_git ok: rc=2 output= DOOR_INFRA_ERROR: git rev-parse HEAD: fatal: not a git repository (or any of the parent directories): .git
186 door shallow_clone ok: rc=2 output= DOOR_INFRA_ERROR: gh pr merge 42 … : fatal: invalid reference: main   ← rc 2 от fake-gh, не от двери → С-5
```

**Красное до правки — дверь ef6cb947, клетки 13ba7311:**

```
$ (w/prefix) bash …/red_architecture_186.sh --repo .
186 door checkout_main_l1 KRASNO: rc=0 output=СЛИТО: …
186 door checkout_main_l2 KRASNO: rc=0 output=СЛИТО: …
186 door checkout_main_l3 KRASNO: rc=0 output=СЛИТО: …
186 door dirty_untracked_l1 KRASNO: rc=0 output=СЛИТО: …
186 door dirty_modified_l1 KRASNO: rc=2 output= DOOR_INFRA_ERROR: gh pr merge … error: Your local
186 door dirty_baseline_swap_l3 KRASNO: rc=0 output=СЛИТО: …
battery@ef6cb947 rc=1
```

**Мои мутанты реализации на OBJECT.** Каждый собран в отдельном worktree, якорь заменён на `if False:`.

```
-if head != sha:                                            (mut1)
-if call(['git', 'status', '--porcelain'], project).strip(): (mut2)
== mut1
186 door checkout_main_l1 KRASNO: rc=0 output=СЛИТО: …
186 door checkout_main_l2 KRASNO: rc=0 output=СЛИТО: …
186 door checkout_main_l3 KRASNO: rc=0 output=СЛИТО: …
battery rc=1
== mut2
186 door dirty_untracked_l1 KRASNO: rc=0 output=СЛИТО: …
186 door dirty_modified_l1 KRASNO: rc=2 output= DOOR_INFRA_ERROR: gh pr merge … error: Your local changes …
186 door dirty_baseline_swap_l3 KRASNO: rc=0 output=СЛИТО: …
battery rc=1
```

**Расширение — production-дверь OBJECT против состояний, которых нет в батарее.** Зонд `scratch/door_extra.py` строит `door_probe.world()` и меняет checkout:

```
gitignored_file_committed_gitignore: porcelain=[] rc=0 out='СЛИТО: … head 43579ddb…' merged=True main:current.json={… "identity": "owner"}
info_exclude_file:                   porcelain=[] rc=0 out='СЛИТО: …' merged=True  {… "owner"}
linked_worktree_at_head:             porcelain=[] rc=0 out='СЛИТО: …' merged=True  {… "owner"}
intent_to_add:                       porcelain=[A new.md] rc=1 out='CHECKOUT_DIRTY' merged=False
staged_only:                         porcelain=[M  architecture/description.md] rc=1 out='CHECKOUT_DIRTY' merged=False
unmerged_conflict:                   porcelain=[AA architecture/description.md] rc=1 out='CHECKOUT_DIRTY' merged=False
submodule_drift:                     porcelain=[M vendor/sub] rc=1 out='CHECKOUT_DIRTY' merged=False
untracked_with_showUntracked_no:     porcelain=[] rc=0 out='СЛИТО: …' merged=True                               → С-4
skip_worktree_baseline_swap_l3:      porcelain=[] rc=0 out='СЛИТО: …' merged=True main:current.json={… "identity": "public"} → С-4
assume_unchanged_baseline_swap_l3:   porcelain=[] rc=0 out='СЛИТО: …' merged=True main:current.json={… "identity": "public"} → С-4
```

Законные состояния сливаются, загрязнённые получают отказ. Это игнорируемый файл (`.gitignore` и `info/exclude`), linked worktree на head, иная ветка на том же sha, detached. Отказ получают intent-to-add, staged, unmerged и дрейф submodule. Сделанное совпадает с заявленным в 8177d235.

Обход флагами индекса (`skip-worktree`/`assume-unchanged`) и `status.showUntrackedFiles=no` — это **С-4, не блок**:
- вектору нужно право записи в станционный checkout;
- с таким правом дверь обходится и без него: `gh` станции;
- §Модель угроз «НЕ ЗАЩИЩАЕТ» выносит права оператора и GitHub ruleset за пределы двери.

Нарушенного замороженного обязательства я не доказал. Для сравнения, Б-1 вызова 1 достигался штатным состоянием станции (checkout на `main`) без всякого умысла.

## 2. Б-2 закрыт — к5 больше не тавтология

```
$ git log -1 --format=%B 1c3a9c5c8 | grep -c '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'
1
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: fixtures/ops_server/red_server_obvjazka_074.sh — восстановление фиксированной таблицы PIN и клетки-биекции k5/k3 (Б-2 ревьюера 186); слово владельца 2026-11-11 ~17:55 UTC через консультанта
```

Само слово владельца я видел только в записи оркестратора в HANDOFF main, строки 4–5: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ … слово 17:55». Первоисточник слова консультанта мне недоступен [INFERENCE: принимаю по записи HANDOFF].

**Граница диффа.** `git show 1c3a9c5c8 -- fixtures/ops_server/red_server_obvjazka_074.sh` — 47+/19−, один файл. Затронуто:
- заголовок к5 (комментарий);
- комментарий блока инвентаря;
- `declare -A PIN=( …10 литералов… )` вместо живого `PIN["$rel"]="$(hash_of …)"`;
- комментарий над SNAP;
- `cell_k3`: `for rel in "${!PIN[@]}"` → `for rel in $RECIPIENTS`;
- `cell_k5`: биекция №1 «RECIPIENTS ⊆ ключи PIN» и «ключи PIN ⊆ RECIPIENTS», сверка с литералами, текст отказа.

Прочие клетки 074 (к1, к2, к4, к5b, к6, стабы, симуляция) коммит не трогает. Граница равна строке РАЗРЕШИЛ: «таблица PIN и клетки-биекции k5/k3». Зона: путь `fixtures/ops_server/` входит в `ЗОНА architect` `frozen/contracts/074/2`, строка 250.

**PIN — литералы, своя мера** (`scratch/pins.py`, разбор блока `declare -A PIN=(`):

```
main keys 9 obj keys 10
CHANGED  root/orch-peak main=6b4f2261c100 obj=5f2a1f443352
NEW      root/systemd/orch-architecture.timer main=None obj=12a4e6cb60ac
same     root/systemd/orch-ctx.timer · orch-peak-reenable.service · orch-peak-reenable.timer · orch-peak-start.timer · orch-peak-stop.timer · orch-peak-warn.timer · orch-peak@.service · user/orch-loop   (8 шт. байт-в-байт)
-- OBJECT table vs own sha256 of ops/server at OBJECT and at 61b2b2bf8
1c3a9c5c8 mismatch= []
61b2b2bf8 mismatch= []
$ git diff --stat 61b2b2bf8 1c3a9c5c8 -- ops/server   → (пусто) rc=0
```

Батарея и мои мутации субъекта (`scratch/mutate_074.py`):

```
$ (w/obj) bash fixtures/_krasnye_074.sh   → итог 074: красных клеток=0 стабы=7/7   074 rc=0
$ (w/pr)  bash fixtures/_krasnye_074.sh   → итог 074: красных клеток=0 стабы=7/7   074 PR rc=0
== m074a (OBJECT, дрейф строки root/orch-peak):  M ops/server/root/orch-peak
k5: ops/server/root/orch-peak разошёлся с фиксированным пином репо (пересъём — явный коммит, не молчаливая правка)
  КРАСНО: cell_k5
итог 074: красных клеток=1 стабы=7/7   074 rc=1
== m074a_pr (PR 8c7b3aab, тот же дрейф): тот же вывод, 074 rc=1
== m074b (новый юнит orch-extra.timer в install.sh без пина):  M ops/server/install.sh ?? ops/server/root/systemd/orch-extra.timer
  КРАСНО: cell_k2
k5: ops/server/root/systemd/orch-extra.timer в инвентаре install.sh без пина в фиксированной таблице (пересъём — явный коммит)
  КРАСНО: cell_k5
итог 074: красных клеток=2 стабы=7/7   074 rc=1
== m074c (убран orch-architecture.timer из install.sh и файл, ключ висит):  M ops/server/install.sh  D …/orch-architecture.timer
  КРАСНО: cell_k2
k5: пин root/systemd/orch-architecture.timer вне инвентаря install.sh — висящий ключ фиксированной таблицы
  КРАСНО: cell_k5
итог 074: красных клеток=2 стабы=7/7   074 rc=1
== m074old (прежний OBJECT 61b2b2bf8, тот же дрейф) — контраст тавтологии
итог 074: красных клеток=0 стабы=7/7   074 old-OBJECT drift rc=0
```

Дрейф, который на 61b2b2bf8 оставался зелёным, на OBJECT и на tip PR красен с именованной причиной. Свойство инв. 1 `frozen/contracts/074/2` («расхождение с пинами = красное») восстановлено. Более простая форма, названная в v1 (таблица + биекция), — ровно та, что реализована.

## 3. Регресс на дельту (PR 8c7b3aab)

```
$ reslop t -- npm run check:ceilings → ok: true, passed: 3, failed: 0; «потолки в порядке»; exit: 0
$ reslop t -- npm run check:gen      → exit: 0
$ bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md → provodka rc=0
$ bash scripts/gen_ci_steps.sh --check --root .                         → gen_ci_steps rc=0
$ bash scripts/merge_architecture_pr.sh   → «использование: merge_architecture_pr.sh <корень-CompliorOS-architecture> <номер-PR>»  door usage rc=2
$ bash scripts/check_architecture_pin.sh  → «использование: check_architecture_pin.sh <корень-CompliorOS-architecture> <№ архитектурного PR> <корень-Complior-back> <№ продуктового PR>»  pin usage rc=2
$ (w/pr) red_architecture_186.sh --repo . → PR repo lines186=72 ok=72 KRASNO=0 rc=0; --model KRASNO=0 rc=0; --stabs caught=71 ZHIV=0 rc=0
$ bash fixtures/_krasnye_080.sh
== pr 8c7b3aab   клетка стаб-s1: stab_rc=0 clean_rc=0 (ожидалось РАЗЛИЧИЕ) · стаб-пак: 8/9 поймано, диффпроба 9/9 · итог 080-батареи: предъявлений стабы 8/9 + дифф 9/9 + честные 31/31 · 080 rc=1
== main 0a4e9c49 тот же вывод, 080 rc=1        → одинаково ДО/ПОСЛЕ, не регресс (стаб s1 вне предмета)
```

**Зоны дельты.** Источник — frozen-блоб 186/1, строки 51–56, плюс `ЗОНА architect` 074/2 и РАЗРЕШИЛ.

```
13ba7311 architect   door_control.py door_probe.py (fixtures/workshop_project/architecture_steward_186/)   — ЗОНА architect 186/1 ✓
ef6cb947 implementer scripts/merge_architecture_pr.sh                                                     — ЗОНА implementer 186/1 ✓
8177d235 implementer scripts/merge_architecture_pr.sh                                                     — ✓
1c3a9c5c architect   fixtures/ops_server/red_server_obvjazka_074.sh                                       — ЗОНА architect 074/2 + РАЗРЕШИЛ-ВЛАДЕЛЕЦ ✓
8c7b3aab orchestrator .github/workflows/ci.yml registry/ci-steps.tsv registry/ci-zamery.tsv               — ЗОНА orchestrator 186/1 ✓ (не изменён с v1)
```

Identity авторов разведены, у коммитов author = committer.

Неподгонка: implementer файлов проверок не трогал. Architect не трогал реализацию. Клетки (13ba7311) идут раньше правки двери (8177d235) и красны против неё до правки (§1).

## 4. CI PR #803 и вторая сеть

```
$ gh pr view 803 --json headRefOid,state → {"headRefOid":"8c7b3aab7482f4e9b90b1111b9f0332970aa2d87","state":"OPEN","mergeable":"UNKNOWN","baseRefName":"main"}
$ gh pr checks 803 --repo a3ka/dev-harness ; checks rc=0
antiplacebo ap1..ap5 pass · ci l1..l7 pass (шаг 186 — полоса l3, pass 11m15s) · klass pass · legkij pass · obshchij pass · tyazhelyj-itog pass · vorota skipping
fail: 0, pending: 0
```

Вторая сеть по §Предмет:
- **§4.** Порядок двери: ID → автор≠сливающий → accept на head → CI → **checkout head + чистота** → baseline L1/L2/L3 → один `gh pr merge --match-head-commit`. Каждый отказ до merge — именованный rc 1 или rc 2. «Ни L2, ни L3 автор не сливает»: клетки `l2_without_owner`/`l3_without_owner`/`checkout_main_l2/l3` зелёные, мутант mut1 их снимает.
- **§1–3, §4а, §6.** Дельта эти файлы не трогает (§0, `git diff --stat 61b2b2bf8 1c3a9c5c8` — четыре пути).
- **§Модель угроз «проверка Git head».** Теперь исполнена буквально.

## 5. Советы и наблюдения

Подробно с чекбоксами — в `.review/2026-11-11-87.md`.

- **С-1 (implementer, из v1) — открыт.** `findings_status.py` не менялся.
- **С-2 (implementer, из v1) — открыт.** Литерал теперь на `merge_architecture_pr.sh:62`. Совпадает с `config/agent_models.json` на main и OBJECT: `apex-sol → @glm → zai/glm-5.3`.
- **С-3 (orchestrator, из v1) — открыт.** В шаге `ci-steps.tsv:307` нет `--model`.
- **С-4 (implementer + architect, новый).** Проверку чистоты обходят флаги индекса и `status.showUntrackedFiles=no` (сырой вывод в §1). Не блок: вектор требует права записи станции, которые контракт выносит за дверь. Прочная форма — `npm run check` в одноразовом `git worktree add --detach <headRefOid>`.
- **С-5 (architect + implementer, новый).** Клетка `shallow_clone` — плацебо. rc 2 даёт `FAKE_GH` (`git switch -q main`), а не дверь: дверь вызвала `gh pr merge`, клетка зелёная и на ef6cb947. Комментарии `merge_architecture_pr.sh:30-31`, `:218-219` («мелкий клон — rc 2») для двери ложны. Поведение двери при этом безопасно: судится дерево head. Обязательства на мелкий клон в 186/1 нет.
- **Н-1.** `roles/orchestrator.md:404` не велит переводить checkout на head перед дверью, в отличие от `:406` для пина. Дверь откажет fail-closed. Правка норма-строки — v+1.
- **Н-2.** Удалённая `wip/186/reviewer` (443c7c8c) не предок `origin/main`. Новая ветка от `origin/main` не даёт fast-forward — решает оркестратор.

## Паразитная сложность (050) — по артефактам дельты

- **Сверка checkout в двери (+2 проверки, `merge_architecture_pr.sh:220-224`).**
  - (1) §4 и §Модель угроз «проверка Git head»; Б-1.
  - (2) состояния не вводит; читает git checkout, отказ именован в stdout.
  - (3) дверь + toy + probe = 3, как в v1, не выросло.
  - (4) интерфейс не изменился: 2 аргумента, rc 0/1/2, новых env/флагов нет.
  - (5) клетки `checkout_*`/`dirty_*`.
  - Итог: **ESSENTIAL**.
- **Семья клеток Б-1** (`door_probe.py` +11 входов, `door_control.py` +5 строк, стабы `skip_head_checkout`/`skip_dirty`) — одним артефактом.
  - (1) Б-1.
  - (2) tmp-миры.
  - (3) 2 файла.
  - (5) `--repo`/`--model`/`--stabs` и CI l3.
  - Итог: **ESSENTIAL**. Исключение — клетка `shallow_clone`: ACCIDENTAL, без различающей силы, совет С-5. Блоком не является: утраченного свойства нет, поведение двери безопасно.
- **Таблица PIN + биекция в 074** (1c3a9c5c8).
  - (1) инв. 1 074/2, фиксированные пины.
  - (2) явные литералы в файле.
  - (3) пересъём пина — 1 файл (таблица); это и есть требуемая явность.
  - (4) интерфейс батареи не менялся.
  - (5) `_krasnye_074.sh`.
  - Итог: **ESSENTIAL**. Форма ровно та, что названа в v1 как более простая.

## ПРОВОДКА (038)

`check_provodka.sh . contracts/186-hranitel-arhitektury.md` → rc 0 на PR. Guard-ы двери и пина подключены шагом `check:hranitel-arhitektury-186-family-selftest`: батарея `--repo .`, `--stabs` и usage rc 2. Шаг прошёл в полосе l3. Role-каналы с v1 не менялись.

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` харнесса не объявляет ни документа архитектуры, ни стандарта кода (`grep 'ARCHITECTURE\.md|CODING-STANDARDS' AGENTS.md` на OBJECT пуст).

## Итог

**accept** по OBJECT 1c3a9c5c881e3e93c51f8f1ff5136ba6819e7682 и по составу PR #803 (8c7b3aab: на всех путях предмета совпадает с OBJECT, CI зелёный).

Б-1 и Б-2 закрыты исполнением, с красным до правки и красными мутантами после неё. С-1…С-5 и Н-1…Н-2 слияние не блокируют.

Что проверено и чем:
- батарея 186 в трёх режимах на OBJECT и PR, счёт — awk и AST;
- 2 мутанта реализации двери и прогон клеток против двери до правки (ef6cb947);
- 10 состояний checkout вне батареи (`scratch/door_extra.py`);
- 4 мутанта субъекта 074 и контраст на прежнем OBJECT;
- сравнение PIN-таблиц main/OBJECT и собственный sha256 по `ops/server`;
- регресс-гейты (ceilings, gen, provodka, gen_ci_steps, usage, 080 ДО/ПОСЛЕ);
- зоны коммитов дельты по frozen-блобам, CI #803.
