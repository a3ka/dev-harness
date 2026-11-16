FAIL
OBJECT=cde1eb8b0e803abb0c08280710b8c1c407851279
КЛАСС=doc/role (КЛАСС РИСКА: обычный — подтверждён; меняются только тексты 8 ролей и производные .omp/agents; права/роли БД, авторизация, деньги, ПД/health, согласия не затронуты; адверсарий по классу не нужен)
СУД: repo=dev-harness; предмет=188; фаза=реализация (v2); роль=reviewer; вызов=1 (полный, на новый OBJECT); модель-план=anthropic/claude-opus-5-5 (тир audit); сессия=Rev188V2; модель-факт=anthropic/claude-opus-5-5; автор=implementer (1adddb10af), носитель=orchestrator (merge cde1eb8b0e); контракт=frozen/contracts/188/2 (commit 857d7b11dd); PR #994 (wip/int-188/implementer); предыдущий=verdicts/review/contracts-188-impl-v1.md (accept, OBJECT 3e2dff82a7)

# Вердикт reviewer — 188 v2 «нормы ролей по архитектуре», реализация, вызов 1

Находки: `.review/2026-11-16-01.md`.

| Класс | Находка | Чья зона |
|---|---|---|
| Блок | Б-1: guard 188 не подключён на OBJECT, `check_provodka` rc 1 | orchestrator |
| Совет | С-1: вход без аргумента даёт ложно-красное, rc 1 | architect |
| Наблюдение | Н-1: PR #771 открыт и конфликтует с v2 | orchestrator |
| Наблюдение | Н-2: размеры ролей в «Существующем» устарели | — |

К части implementer (коммит 1adddb10af) находок нет. FAIL держится только на Б-1: на кандидате не выполнена строка приёмки замороженного контракта и п.(6) задания.

Клон: `/tmp/dev-harness-verify/Rev188V2` (единственный источник — `ssh://git@github.com/a3ka/dev-harness.git`), checkout OBJECT. Деревья: `obj` = OBJECT, `base` = `origin/main` b3b7ff81ade178aa9a15443e0e8969c2dd34bf6a (worktree `.git/wt-base`).

## Кандидат и подлинность

```
$ git rev-parse HEAD origin/main origin/wip/188/implementer-int1116
cde1eb8b0e803abb0c08280710b8c1c407851279
b3b7ff81ade178aa9a15443e0e8969c2dd34bf6a
cde1eb8b0e803abb0c08280710b8c1c407851279
$ gh pr view 994 … → headRefOid cde1eb8b0e…, base main, OPEN, MERGEABLE, commits [1adddb10af, cde1eb8b0e]
$ git log -1 --format='%an <%ae> / %cn <%ce>%n%P' cde1eb8b
orchestrator <orchestrator@dev-harness.local> / orchestrator <orchestrator@dev-harness.local>
b3b7ff81ade178aa9a15443e0e8969c2dd34bf6a 1adddb10afc7170c11c8e138f49835c9d00cc8fb
$ git show --format='%an <%ae> / %cn <%ce>' 1adddb10af → implementer <implementer@dev-harness.local> / implementer <implementer@dev-harness.local>
$ patch-id: diff 48aa70efaa..1adddb10af = 5ed184d131a01f6d24929099d2361b3c8f007ca2
            diff b3b7ff81..cde1eb8b     = 5ed184d131a01f6d24929099d2361b3c8f007ca2
$ git merge-base --is-ancestor 'frozen/contracts/188/2^{commit}' cde1eb8b → 0
$ git merge-base --is-ancestor done/contracts/186/1 cde1eb8b → 0
$ git diff --stat 'frozen/contracts/188/2^{commit}' HEAD -- fixtures/workshop_project/roles_architecture_188 contracts/188-roli-po-arhitekture.md
(пусто) rc=0
$ git ls-tree origin/main fixtures/workshop_project/roles_architecture_188 ≡ ls-tree frozen 188/2 (блобы .probe-only 91d69fd1, norms.tsv 081bd7e9, probe.py 1b107239, red_…sh ee965e54)
```

Интеграционный merge не добавил ничего сверх коммита implementer: patch-id совпадают. Батарея, оракул и контракт на OBJECT побайтно равны тегу 188/2. Требование ПЕРЕСЕЧЕНИЯ «роль 188 вливать после 186» выполнено: `done/contracts/186/1` — предок OBJECT.

## 1. Область правки

```
$ git diff --numstat b3b7ff81 cde1eb8b
8 0 .omp/agents/adversary.md      8 0 roles/adversary.md
6 0 .omp/agents/arbiter.md        6 0 roles/arbiter.md
8 0 .omp/agents/architect.md      8 0 roles/architect.md
8 0 .omp/agents/critic.md         8 0 roles/critic.md
12 0 .omp/agents/implementer-glm.md  12 0 roles/implementer-glm.md
12 0 .omp/agents/implementer.md   12 0 roles/implementer.md
12 0 .omp/agents/orchestrator.md  12 0 roles/orchestrator.md
8 0 .omp/agents/reviewer.md       8 0 roles/reviewer.md
```

16 путей, +148/−0. Все они входят в `ЗОНА implementer` frozen 188/2 (16 путей, включая `roles/implementer-glm.md` и `.omp/agents/implementer-glm.md` из дельты v+1). Пути ветки и main от merge-base 48aa70efaa в `roles/` и `.omp/` не пересекаются: `git diff --name-only 48aa70efaa b3b7ff81 | grep -E '^(roles|\.omp)/'` → rc 1, пусто.

Своя мера (`Rev188V2-tools/mymeasure.py`). Для каждого из 8 файлов роли база является префиксом OBJECT, а добавленный хвост побайтно равен ожидаемому: пустая строка, `## Архитектура 188`, маркер, литералы каналов ПРОВОДКИ в их порядке. Правок вне секции нет, все строки ПЕРЕСЕЧЕНИЕ (002…100, 186, 187, 998) соблюдены.

```
PROVODKA_ROLE_CHANNELS=21
NORMS_ROWS=13
PROVODKA_NOT_IN_NORMS=0 []
FILE roles/adversary.md base_is_prefix=True added_exact=True added_lines=8 headers=1 hidden=False
FILE roles/arbiter.md base_is_prefix=True added_exact=True added_lines=6 headers=1 hidden=False
FILE roles/architect.md base_is_prefix=True added_exact=True added_lines=8 headers=1 hidden=False
FILE roles/critic.md base_is_prefix=True added_exact=True added_lines=8 headers=1 hidden=False
FILE roles/implementer-glm.md base_is_prefix=True added_exact=True added_lines=12 headers=1 hidden=False
FILE roles/implementer.md base_is_prefix=True added_exact=True added_lines=12 headers=1 hidden=False
FILE roles/orchestrator.md base_is_prefix=True added_exact=True added_lines=12 headers=1 hidden=False
FILE roles/reviewer.md base_is_prefix=True added_exact=True added_lines=8 headers=1 hidden=False
COORDS=21 OK=21
PAIR b3b7ff81ad body_equal=True fm_diff=[('role: implementer', 'role: implementer-glm')]
PAIR cde1eb8b0e body_equal=True fm_diff=[('role: implementer', 'role: implementer-glm')]
```

21 литеральная координата и клетка пары вместе дают 22, что совпадает с контрактом. Маркер в glm-файле — `roles/implementer.md`, то есть базового файла, как предписывает раздел «Адресный v+1». Frontmatter пары расходится только полем `role:`.

## 2. Сырой вывод — приёмка исполнением на OBJECT

```
$ bash …/red_roles_architecture_188.sh --repo .
GREEN architect/finding … GREEN orchestrator/steward, GREEN implementer-glm/pair (22 строки GREEN)
CELLS=22 GREEN=22
rc=0
$ … --model
CELLS=22 HONEST=22 RED_NEGATIVES=22 HTML_NEGATIVES=22 FENCE_NEGATIVES=22
rc=0
$ … --stabs
STAB wrong-role caught @ critic/finding
STAB html-comment-multiline caught @ architect/cells
STAB html-comment-inline caught @ critic/sixth
STAB fenced-code caught @ implementer/engine
STAB typo caught @ implementer/engine
STAB optional-section caught @ orchestrator/linked
STAB prose caught @ reviewer/verdict
STAB glm-norm-only-implementer caught @ implementer-glm/engine
STAB glm-byte-divergence caught @ implementer-glm/pair
STAB glm-html-comment caught @ implementer-glm/engine
STAB glm-fenced-code caught @ implementer-glm/engine
STAB glm-optional-section caught @ implementer-glm/engine
STAB repo-html-comment caught @ architect/cells
STABS=13 CAUGHT=13
rc=0
$ … (без аргумента)
(вывода нет) rc_noarg=1          ← С-1
$ npm run gen:harness → «сгенерировано: 13 ролей, обновлено файлов: 0» rc=0; git status --porcelain → 0 строк
$ npm run check:gen → «харнес соответствует roles/ (13 ролей)» rc=0
$ bash scripts/check_ceilings.sh
  ok   персоны: 13 файл(ов), потолок 81920 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 175 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
$ python3 fixtures/pravila_modelei_998/probe.py --case role_pair_glm
CASE role_pair_glm: ok — пара implementer-glm=task-glm (@glm/@sonnet) на месте   rc=0
$ bash fixtures/pravila_modelei_998/probe.sh → census matrix: исполнено 67, расхождений 0   rc=0
$ bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo . → … pin_arch_head ok   rc=0
$ bash scripts/check_provodka.sh . contracts/188-roli-po-arhitekture.md
проводка: guard не подключён: fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh не вызывается в .githooks/ или .github/workflows/
rc=1                              ← Б-1
```

Размеры в байтах (`git cat-file -s`, OBJECT / base): architect 48122/47196, critic 42208/41231, implementer 11997/10451, implementer-glm 12001/10455, adversary 8848/7921, reviewer 16575/15643, arbiter 9499/9016, orchestrator **75261**/73612. Максимум по всем 13 ролям — 75261, это ниже ROLE_CEILING 81920 (`scripts/check_ceilings.sh:30 PERSONA_LIMIT=81920`) и ниже «жира» 90000 из фикстур 071. Самый большой производный файл, `.omp/agents/orchestrator.md`, весит 75604.

## 3. Проверки не подогнаны под код

Implementer не трогал `fixtures/` и контракт: блобы семьи 188 на OBJECT, на main и в теге 188/2 одинаковы (см. «Кандидат»). Клетки по сравнению с тегом не ослаблены, потому что совпадают побайтно. Стабы красные: 13 из 13 пойманы, `ZHIV` нет.

## 4. Красное предъявлено — своя мера, другими командами

Батарея на роли main, вызванная из OBJECT, ведёт себя по контракту: rc 1, `CELLS=22 GREEN=1`.

```
$ bash …/red_roles_architecture_188.sh --repo .git/wt-base
RED architect/finding … RED orchestrator/steward (21 RED)
GREEN implementer-glm/pair
CELLS=22 GREEN=1
rc=1
```

Удаление каждого из 21 литерала по одному в копии ролей OBJECT (`Rev188V2-tools/del22.py`). Кроме того, проверено состояние «без вставки в пару»: glm-файл взят из базы.

```
DEL architect/finding            rc=1 reds=['architect/finding'] CELLS=22 GREEN=21 EXACT
DEL critic/finding               rc=1 reds=['critic/finding'] CELLS=22 GREEN=21 EXACT
DEL implementer/finding          rc=1 reds=['implementer/finding', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL implementer-glm/finding      rc=1 reds=['implementer-glm/finding', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL adversary/finding            rc=1 reds=['adversary/finding'] CELLS=22 GREEN=21 EXACT
DEL reviewer/finding             rc=1 reds=['reviewer/finding'] CELLS=22 GREEN=21 EXACT
DEL architect/cells              rc=1 reds=['architect/cells'] CELLS=22 GREEN=21 EXACT
DEL critic/sixth                 rc=1 reds=['critic/sixth'] CELLS=22 GREEN=21 EXACT
DEL implementer/placement        rc=1 reds=['implementer/placement', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL implementer-glm/placement    rc=1 reds=['implementer-glm/placement', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL implementer/engine           rc=1 reds=['implementer/engine', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL implementer-glm/engine       rc=1 reds=['implementer-glm/engine', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL implementer/bindings         rc=1 reds=['implementer/bindings', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL implementer-glm/bindings     rc=1 reds=['implementer-glm/bindings', 'implementer-glm/pair'] CELLS=22 GREEN=20 EXACT
DEL adversary/stubs              rc=1 reds=['adversary/stubs'] CELLS=22 GREEN=21 EXACT
DEL reviewer/verdict             rc=1 reds=['reviewer/verdict'] CELLS=22 GREEN=21 EXACT
DEL arbiter/decision             rc=1 reds=['arbiter/decision'] CELLS=22 GREEN=21 EXACT
DEL orchestrator/task            rc=1 reds=['orchestrator/task'] CELLS=22 GREEN=21 EXACT
DEL orchestrator/linked          rc=1 reds=['orchestrator/linked'] CELLS=22 GREEN=21 EXACT
DEL orchestrator/merge           rc=1 reds=['orchestrator/merge'] CELLS=22 GREEN=21 EXACT
DEL orchestrator/steward         rc=1 reds=['orchestrator/steward'] CELLS=22 GREEN=21 EXACT
DELETIONS=21 EXACT=21
NO_GLM_INSERT rc=1 reds=['implementer-glm/finding', 'implementer-glm/placement', 'implementer-glm/engine', 'implementer-glm/bindings', 'implementer-glm/pair'] CELLS=22 GREEN=17
```

Каждое удаление краснит свою координату. Для пары implementer добавляется клетка пары: тело расходится байтом, что ожидаемо по 998. Соседи зелёные. Состояние PR #771, где нет вставки в пару, воспроизведено точно по контракту: `CELLS=22 GREEN=17`, красные 4 glm-координаты и клетка пары.

## 5. Атомарность

Предмет 188 несёт один коммит implementer, 1adddb10af: 16 путей, ссылка на `frozen/contracts/188/2`, identity implementer. Носитель несёт один merge-коммит orchestrator, содержимое которого по patch-id равно реализации. Связок нет.

## 6. Норма не тронута молча

Правились только роли, и только дописыванием норм самого предмета по его замороженному контракту. Чужие нормы, AGENTS.md и контракты не изменены.

## 7. Регресс ПРОВОДКИ

`Rev188V2-tools/provall.sh` прогоняет `check_provodka` по каждому контракту с блоком `ПРОВОДКА:`, base против obj:

```
CONTRACTS=137 SAME=137 CHANGED=0
RED_OBJ (и base=1): 061, 078, 084, 094, 095, 097, 098, 116, 148, 150, 152, 154, 165, 168, 184, 188 — все красны и до OBJECT
```

Регресса нет. Контракт 188 красный на обеих сторонах по одной причине — Б-1.

## Б-1 (блок) — guard 188 не подключён

Своей мерой установлено, что 21 role-канал на OBJECT исправен, а не хватает только подключения guard. В копии OBJECT `.git/wt-wired` добавлена строка шага из `origin/wip/188/orchestrator` (коммит v1 0b5a387d) и выполнена регенерация:

```
step	check:roles-architecture-188-family-selftest	4	bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo . && bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --stabs
$ bash scripts/gen_ci_steps.sh --write → rc 0 (ci.yml 12 ±, ci-steps.tsv +1)
$ bash scripts/check_provodka.sh . contracts/188-roli-po-arhitekture.md → rc=0
$ bash scripts/gen_ci_steps.sh --check → rc=0
замер в v1: check:roles-architecture-188-family-selftest	4	8	0   (origin/wip/188/orchestrator:registry/ci-zamery.tsv)
```

В PR #994 этих изменений нет, на main тоже. Если слить #994 в текущем виде, нормы 188 попадут в роли без барьера в CI, а значит свойство guard из ПРОВОДКИ 188 не будет доставлено. Исправление — коммит orchestrator в его ЗОНЕ 188/2: `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml` через `gen_ci_steps.sh --write`, коммит ложится на носитель #994. Повторный суд — scoped, по дельте проводки на новом SHA: `check_provodka` rc 0, `gen_ci_steps --check` rc 0, роли не изменились.

## Паразитная сложность (050)

- **Восемь блоков «## Архитектура 188» (одна семья, включая пару glm).** (1) Требует их ПРОВОДКА 188/2: 21 role-канал и пин 998 role_pair_glm. (2) Новое состояние не вводится, только текст. (3) При следующей правке того же свойства меняются `norms.tsv`, ПРОВОДКА, роль и для implementer ещё пара. Пара добавлена пином 998, а не диффом сверх нужного. (4) Интерфейса нет. (5) Потребители — `check_provodka`, батарея 188 и проба 998. Грамматику блоки не повторяют. Итог: ESSENTIAL, форма с одним абзацем отвергнута frontier (б).
- **Регенерация `.omp/agents/*.md` (8 файлов).** (1) `check:gen`. (2) Вывод производный, сверяется `--check`. (3)–(5) Механическое зеркало `roles/`. Итог: ESSENTIAL.

## Смысл норм

Литералы v2 побайтно равны `norms.tsv` и ПРОВОДКЕ 188/2 (`PROVODKA_NOT_IN_NORMS=0`, `COORDS=21 OK=21`). 13 строк оракула не изменились с v1, где их смысл сверен с планом и SPEC (verdicts/review/contracts-188-impl-v1.md §«Смысл норм»). Новое в v2 — побайтная копия четырёх строк implementer в паре. Её смысл тождествен, и это требование пина 998, а не новая норма.

## Сверки

СВЕРКА-СТАНДАРТОВ: неприменимо — `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md`; дифф — только тексты ролей.
СВЕРКА-АРХИТЕКТУРЫ: неприменимо — предмет doc/role станции, не кодовый предмет проекта с моделью архитектуры; размещения, зависимостей, писателей, операций, `bindings.json`, долга и diff модели в диффе нет; L2/L3 не затронуты.
ПРОВОДКА: 21 role-канал на месте и побайтно совпадает (rc 0 в копии с подключённым guard). Guard — батарея именно 188 (`red_roles_architecture_188.sh`), но на OBJECT она **не подключена**, см. Б-1. ПРОВОДКА-ЭНФОРСМЕНТ честно ограничивает guard наличием строк, а поведенческие нормы проведены role-каналами.
Мобильный экран: неприменимо.
Состояние CI PR #994 (для сведения, не гейт): klass, legkij, obshchij, ap1–ap5, l2–l4, l6, l7 — SUCCESS; vorota — SKIPPED; l1 и l5 — IN_PROGRESS. Шага 188 среди проверок нет.

## Итог

FAIL по OBJECT cde1eb8b0e803abb0c08280710b8c1c407851279 из-за Б-1: guard ПРОВОДКИ 188 не подключён, `check_provodka` rc 1. Это зона orchestrator. Работа implementer (1adddb10af) по пп.(1)–(5) задания проверена своей мерой и находок не имеет. С-1, Н-1 и Н-2 слияние не блокируют. Повтор — scoped по дельте проводки.
