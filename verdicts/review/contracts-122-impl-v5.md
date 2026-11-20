accept
OBJECT=f284fc8f07ad4e2e0c39a3a58edfe3d654bb78ad
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА 122 — по контракту; адверсарий предшествовал: FAIL по scoped, закрыт словом владельца 18:43)

Ревьюер Rev122Narrow, роль reviewer. Фактическая модель — anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev122Narrow` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev122Narrow	f284fc8f07…`).

Предмет: реализация 122 «CI проекта» по frozen/contracts/122/6 (commit b167a73682). Вызов один и узкий, по слову владельца («122 да», 2026-11-20 10:19; scoped — 18:43). Полный круг 122 не повторялся.

- Находки: `.review/2026-11-20-121.md` (reslop, status: ready).
- Связка с блобами: `scripts/freeze_contract.sh` 8915780f91adcb1b749c57a31f6b50657ff049cf, `scripts/ci_preflight.sh` 7c6230229e0464ff1035dbaa04b5fc818a12d453 (оба равны блобам 92947346d9, принятого Rev122V7). Батарея: `roots_probe.py` 5653408aae4300a358ecee867251fcff3722ca85, `roots_model.py` 6eaee5c3c3162334a61b27e7e1fc5b7e5210ae07. Новая редакция любого из них этот accept не наследует.

## Итог

Блокирующих находок по OBJECT нет.

Единственный блок Adv122Narrow — scoped `verify_antiplacebo` для ci_preflight. Он неприменим к 122 по слову владельца 18:43.

Условие ленда Л-3: OBJECT лендится только вместе с листом architect 5fd0cf7108. Без него приёмка v6 п.4 (`check_sdacha --run`, `pre_critic`) на OBJECT красна. На кандидате «OBJECT + лист 5fd0cf7108» обе зелёные — я перепроверил это сам.

Советы:
- С-3 (architect) — две сверки §v6 без сторожа в батарее; мутанты m6/m7 выжили.
- С-4 — копия схемы контекста в коде.

## Пункты роли

1. **Область — соответствует.**
   - `git diff --name-only origin/main...HEAD` (merge-base b1234ec2e2): `.review/2026-11-19-122.md`, `scripts/ci_preflight.sh`, `scripts/freeze_contract.sh`, `verdicts/review/contracts-122-impl-v3.md`.
   - Три implementer-коммита трогают только `scripts/ci_preflight.sh` и `scripts/freeze_contract.sh`. Оба пути ⊆ `ЗОНА implementer:` (frozen 122/6, строка 82).
   - 0cb543a03d — reviewer (свой вердикт).
   - Author = committer у всех пяти коммитов диапазона: implementer×3, reviewer×1, orchestrator×2 merge.
   - Merge 2d0c5bfb32 и f284fc8f07: `git show --remerge-diff` пуст, `git show --cc` — 0 строк. Собственных разрешений конфликтов нет.
2. **Сырой вывод** — ниже, у каждого прогона указан rc.
3. **Неподгонка.**
   - `git diff --exit-code origin/main...HEAD -- fixtures/ contracts/` rc 0.
   - `git diff --exit-code frozen/contracts/122/6 HEAD -- contracts/122-ci-proekta.md` rc 0.
   - Батарея и лист в OBJECT — ровно main.
   - Счёт 43/36 принят владельцем. Не находка.
4. **Красное предъявлено.**
   - Б-1 и Б-2 пойманы.
   - Три собственные мутации из задания пойманы: подмена origin/canonicalRemote — m3; молчаливая перезапись повтора — Б-2; инвентарь из чужого репо — m4. Ещё m5 пойман.
   - Две дополнительные мутации (m6, m7) батарея НЕ ловит → С-3. Своими входами показано, что OBJECT эти обязательства исполняет.
5. **Атомарность.**
   - 20f3ad23b4 — Г2 v+1 вместе с ногой v6. Это две задачи порядка «v+1 до done» и «v6» в одном коммите. Принято прежними судами, коммит не новый — замечание без блока.
   - e056cf4ba9 и 92947346d9 — по одной задаче.
6. **Норма не тронута.** Дифф не касается `contracts/`, `roles/`, `AGENTS.md`.
7. **Заявленное = сделанному, своей мерой.**
   - Импорт словарей `roots_probe`: CASES 43 (уникальных 43), STABS 36, целей 29, все цели ⊆ CASES.
   - Отдельный прямой вызов `roots_probe.py --repo . --stabs`, `grep -c ПОЙМАН` = 36.
   - Раннер: 74/74 и 43/43.
   - Заявки Impl122Verify2 и Adv122Narrow (74/74, 43/43, 36/36; Б-1 GREEN=42 RED=1; Б-2 GREEN=39 RED=4) совпали с моими числами.
   - Блобы `roots_probe.py` и `roots_model.py` совпали с заявленными.

## Сырой вывод (копия /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t240e6291d/m, HEAD = OBJECT)

```
$ git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/122/implementer-pub; git rev-parse FETCH_HEAD
f284fc8f07ad4e2e0c39a3a58edfe3d654bb78ad
$ git switch --detach f284fc8f07…; git rev-parse HEAD
f284fc8f07ad4e2e0c39a3a58edfe3d654bb78ad
$ git fetch ssh://…/dev-harness.git refs/heads/main → b3394d0c9b (= refs/remotes/origin/main); merge-base с OBJECT b1234ec2e2
$ git diff --stat b1234ec2e2 origin/main -- scripts/freeze_contract.sh scripts/ci_preflight.sh scripts/check_predposylki.sh fixtures/workshop_project/ci_proekta_122 contracts/122-ci-proekta.md → пусто
$ git merge-tree --write-tree --name-only origin/main HEAD → 7d26fab2cb, rc 0 (без конфликтов)

$ bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model          rc=0
ИТОГ 122 (model): клеток 74, зелёных 74, красных 0
ROOTS122 TOTAL=43 GREEN=43 RED=0
$ … --repo .                                                                            rc=0
ИТОГ 122 (red): клеток 74, зелёных 74, красных 0
ROOTS122 TOTAL=43 GREEN=43 RED=0
$ … --repo . --stabs                                                                    rc=0
ROOTS122 STABS=36 CAUGHT=36
$ … --model --cell r12 → ROOTS122 TOTAL=43 GREEN=43 RED=0 rc=0
$ … --repo . --cell r12 → ROOTS122 TOTAL=43 GREEN=43 RED=0 rc=0
$ … --model --cell r13 → ROOTS122 TOTAL=10 GREEN=10 RED=0 rc=0
$ … --repo . --cell r13 → ROOTS122 TOTAL=10 GREEN=10 RED=0 rc=0
$ python3 $B/roots_probe.py --model --case <c> (приёмка v6 п.5/п.6), каждая rc=0 ЗЕЛЁНАЯ:
  foreign-project rc=1 · foreign-identity rc=1 · identity-dot rc=0 · identity-json rc=0 ·
  identity-project-mismatch rc=1 · identity-repo-mismatch rc=1 · station-explicit rc=1 ·
  station-implicit rc=1 · station-unresolved rc=1 · station-binding-duplicate rc=1 ·
  station-binding-invalid rc=1 · mono rc=0 · mono-explicit rc=0 · mono-declared rc=0 · mono-declared-explicit rc=0
  (rc субъекта; клетка зелёная, TOTAL=1 GREEN=1 RED=0 у каждой)
$ python3 -c 'import roots_probe; len(...)' → CASES 43 unique 43 · STABS 36 cells_targeted 29 all_targets_in_CASES True
$ python3 $B/roots_probe.py --repo . --stabs | grep -c ПОЙМАН → 36   (rc 0)

$ bash scripts/verify_antiplacebo.sh --scope freeze_contract                            rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 15 · предъявлено красным повторным прогоном: 15
  (scope ci_preflight не гонялся — слово владельца 18:43: к 122 неприменим)

$ for p in freeze_contract.sh ci_preflight.sh check_predposylki.sh profile_resolver.sh: blob OBJECT = blob 92947346d9
  freeze_contract 8915780f91 = 8915780f91 · ci_preflight 7c6230229e = 7c6230229e · check_predposylki f28c468c31 (= main) · profile_resolver 4494f1492a (= main)
$ git diff b1234ec2e2 HEAD -- scripts/ci_preflight.sh scripts/freeze_contract.sh | grep '^+' | grep -E 'ci122|PILOT_DEMO|fixture122|roots122|toy|731|dev-harness-verify|CI_PROEKTA_122'
  → одна строка: docstring `freeze_contract.sh:701` (ссылка на путь схемы); имён/значений батареи в логике нет
$ … | grep -E '^\+.*\b(shift|set --)\b' → пусто (rc 1): позиционные не сдвигаются
```

### Мутации (клон `git clone --no-hardlinks <копия>` на OBJECT; одна правка, assert count==1; `red_ci_proekta_122.sh --repo <клон>` полностью)

```
b1  freeze_contract.sh:796  `if root_remote and … != root_remote:` → `if False:`        rc=1
    ROOTS122 mono-origin-mismatch: rc=0 КРАСНАЯ rc=0 want=1; нет причины project-workflow-rashozhdenie; …; gh вызван до валидации контекста
    ИТОГ 122 (red): клеток 74, зелёных 74, красных 0 · ROOTS122 TOTAL=43 GREEN=42 RED=1
b2  freeze_contract.sh:82-83 гард повтора --project-workflow удалён                       rc=1
    cli-repeat-valid / -missing-first / -invalid-first: rc=0 КРАСНАЯ want=1 …; cli-repeat-missing-last: rc=1 КРАСНАЯ нет причины project-workflow-neodnoznachen
    ROOTS122 TOTAL=43 GREEN=39 RED=4
m3  freeze_contract.sh:772 (явный контекст: canonicalRemote ≠ живой origin проекта) → `if False:`   rc=1
    ROOTS122 wrong-origin: rc=1 КРАСНАЯ нет причины project-workflow-rashozhdenie; gh вызван до валидации контекста
    ROOTS122 mono-origin-mismatch-explicit: rc=0 КРАСНАЯ rc=0 want=1; …
    ROOTS122 TOTAL=43 GREEN=41 RED=2
m4  freeze_contract.sh:845 гейт Г3 читает "$ROOT" вместо "$PROJECT_ROOT" (инвентарь чужого репо)   rc=1
    project-secret / missing-secret / gh-error / station-writes / identity-dot / identity-json КРАСНЫЕ — «инвентарь не из project origin: [['secret','list','-R','…/station-origin.git']]»
    ROOTS122 TOTAL=43 GREEN=37 RED=6
m5  freeze_contract.sh:807 внешний корень без объявления → `elif False:`                   rc=1
    ROOTS122 binding-missing: rc=0 КРАСНАЯ rc=0 want=1; …   ROOTS122 TOTAL=43 GREEN=42 RED=1
m6  freeze_contract.sh:770 canonicalRemote контекста ≠ профилю → `if False:`              rc=0   ← ВЫЖИЛ (С-3)
    ИТОГ 122 (red): клеток 74, зелёных 74, красных 0 · ROOTS122 TOTAL=43 GREEN=43 RED=0
m7  freeze_contract.sh:758 subject.origin ≠ origin станции → `if False:`                 rc=0   ← ВЫЖИЛ (С-3)
    ИТОГ 122 (red): клеток 74, зелёных 74, красных 0 · ROOTS122 TOTAL=43 GREEN=43 RED=0
```
Строки «ОТКАЗ: …» в выводе мутантов печатал испытуемый freeze внутри миров батареи — это результат испытания, а не отказ механизма.

### Свои входы на выживших (каркас `world(…, 'project-secret')` батареи, настоящий freeze дерева; меняется один названный вход)

```
$ python3 /tmp/dev-harness-verify/reviewer122n-1717276/my_probe.py <копия> <mut-m6> <mut-m7>    rc=0
MY control repo=m: freeze_rc=0 gh=1 tag_rc=0 otkaz=[]
MY my-subject-origin repo=m: freeze_rc=1 gh=0 tag_rc=128 otkaz=['ОТКАЗ: project-workflow-rashozhdenie: subject.origin — не origin станции']
MY my-profile-canonical repo=m: freeze_rc=1 gh=0 tag_rc=128 otkaz=['ОТКАЗ: project-workflow-rashozhdenie: canonicalRemote не совпадает с профилем']
MY control repo=mut-m6: freeze_rc=0 gh=1 tag_rc=0 otkaz=[]
MY my-subject-origin repo=mut-m6: freeze_rc=1 gh=0 tag_rc=128 otkaz=['ОТКАЗ: project-workflow-rashozhdenie: subject.origin — не origin станции']
MY my-profile-canonical repo=mut-m6: freeze_rc=0 gh=1 tag_rc=0 otkaz=[]
MY control repo=mut-m7: freeze_rc=0 gh=1 tag_rc=0 otkaz=[]
MY my-subject-origin repo=mut-m7: freeze_rc=0 gh=1 tag_rc=0 otkaz=[]
MY my-profile-canonical repo=mut-m7: freeze_rc=1 gh=0 tag_rc=128 otkaz=['ОТКАЗ: project-workflow-rashozhdenie: canonicalRemote не совпадает с профилем']
```

### Лист (приёмка v6 п.4) — перепроверено, решение: нужно

```
OBJECT:
$ bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run                      rc=1
ОТКАЗ: строка 18: фактический rc=0 ≠ заявленного 1: bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r12
$ bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md                         rc=1
ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 18: фактический rc=0 ≠ заявленного 1: … --repo . --cell r12

Кандидат /tmp/dev-harness-verify/reviewer122n-1717276/cand = OBJECT + `git checkout 5fd0cf7108 -- sdacha_122.md`
(5fd0cf7108 из /home/harness/odelix/122-sheet.jiRVI7/repo wip/122/architect; author=committer architect; один файл;
 база блоба 171a74f9c5 = блоб OBJECT), скретч-коммит 199e3439e9 (не публикуется):
$ bash scripts/check_sdacha.sh . contracts/122-ci-proekta.md --run                      rc=0
СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=7)
$ bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md                         rc=0
КРИТИК: дверь зелёная
```
«ОТКАЗ» check_sdacha и pre_critic на OBJECT задание заранее назвало известным красным вне зоны. Я прочитал его как результат испытания листа, а не как отказ механизма, блокирующий мою работу. Суд продолжен.

## Находки (полный список; детали — .review/2026-11-20-121.md)

- **Л-3 — УСЛОВИЕ ЛЕНДА.**
  - Класс: лист сдачи architect не догнал реализацию.
  - Место: `fixtures/workshop_project/ci_proekta_122/sdacha_122.md:16,18` ждут rc 1, факт rc 0.
  - Адресат: оркестратор/architect.
  - Ленд OBJECT — только вместе с 5fd0cf7108: без него приёмка v6 п.4 красна (вывод выше), с ним — зелёна.
- **С-3 — СОВЕТ.**
  - Класс: сверка реализации без сторожа в батарее (Н-39).
  - Места: `scripts/freeze_contract.sh:758-759` (subject.origin) и `:770-771` (canonicalRemote ↔ профиль).
  - Мутанты m6/m7 живы против батареи: 74/74, 43/43. Мои входы ловят оба; OBJECT отказывает верно.
  - Адресат: architect. Новые клетки меняют счёт ROOTS122.
- **С-4 — СОВЕТ.**
  - Класс: 050, дублирование грамматики.
  - Место: `scripts/freeze_contract.sh:700-731` — схема `project_workflow.schema.json` повторена в коде. Сверки дрейфа нет.
  - ESSENTIAL при нынешней фабрике миров: в `--repo`-мирах копируется только scripts/.
- Блок Adv122Narrow (scoped ci_preflight) — неприменим по слову владельца 18:43. Не находка.
- Счёт 43/36 против 37/22 — принят владельцем. Не находка.
- Атомарность 20f3ad23b4 (Г2 v+1 и нога v6 в одном коммите) — замечание. Коммит принят прежними судами, OBJECT не меняет.

ОСТАТОК (контракт 192; строки НЕ ЗАЩИЩАЕТ с ловцом «ревью кода/судьи реализации»):
- ОСТАТОК: contracts/122-ci-proekta.md:126 «злонамеренный субъект, распознающий пробы батареи» — не укусил.
  - Добавленные строки диффа не ссылаются на имена и значения батареи. Единственное совпадение — docstring `freeze_contract.sh:701`.
  - Мои входы иной формы (`my-subject-origin`, `my-profile-canonical`) дали на OBJECT честный отказ.
- ОСТАТОК: :175 «ложь уполномоченного поставщика контекста / конкурентная смена репозитория после сверки» — не укусил.
  - Сверки `:752-773` и `:795-798` читают живой `git remote get-url origin`, тем же способом, каким Г3 строит `-R`.
  - Окно между сверкой и gh — в объявленной границе. Дифф его не расширил: блоб freeze = 92947346d9.
- ОСТАТОК: :123 «GHA-семантика вне алфавита, ловец — ревью workflow и судьи реализации» — не укусил в пределах узкого вызова.
  - `ci_preflight.sh` (блоб 7c6230229e = 92947346d9) судим только батареей: 74/74, клетки p9/p10/p11 гоняют настоящий субъект.
  - Отказ `vyrazhenie-ne-podderzhano` присутствует (`refuse_expression`).

СВЕРКА-СТАНДАРТОВ: AGENTS.md харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` — н/п. По внутренним конвенциям файла: отказы идут через существующие `die` и `refuse(reason, detail)` одной строкой ОТКАЗ. Новых причин вне алфавита §v6 (otsutstvuet/neodnoznachen/rashozhdenie) нет.

СВЕРКА-АРХИТЕКТУРЫ:
- Размещение — нога 6г-0 существующего `scripts/freeze_contract.sh` и Г2 в `scripts/ci_preflight.sh`, оба в зоне implementer.
- Зависимости — git, штатные `profile_resolver.sh`/`project_workflow.sh`, `check_predposylki.sh` от установленного скрипта. Новых нет.
- Писатели — без изменений: ROOT пишет тег, реестр и коммит. Каждый отказ v6 срабатывает до gh и записей. Атомарность наблюдают клетки батареи и мои входы (tag_rc=128).
- Операции — новых нет.
- `bindings.json` — у механизма харнесса отсутствует.
- Долг не расширен.
- Уровень diff модели — L0: `roots_model.py` несёт те же сверки (`:138` subject.origin, `:151-153` canonicalRemote ↔ профиль/origin), реализация с ними совпадает. Расхождения модели и работы нет, поэтому `finding new` не требуется (и `tooling/checks/cli.js` в дереве нет).
- Пробел С-3 — в охране (STABS/CASES), а не в модели.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по артефактам диффа:
- (а) Хвост CLI `--project-workflow` с отказом на повтор (`freeze_contract.sh:57-87`):
  1. свойство — §v6 «транспорт контекста; несколько — neodnoznachen»;
  2. состояние — одна переменная `PROJECT_WORKFLOW`, видна в причинах отказа;
  3. совместно меняемых файлов — 1;
  4. интерфейс — один флаг, rc 1;
  5. потребитель — клетки cli-repeat-*, ambiguous-context, no-context.
  ESSENTIAL.
- (б) Сверка контекста 6г-0 (`:577-818`, python heredoc):
  1. свойство — §v6 «декларация HEAD, subject/project, профиль, origin до gh»;
  2. состояние — `PROJECT_ROOT`, в выводе отказов;
  3. совместно меняемых — 2 (код и схема, С-4);
  4. интерфейс не вырос — тот же rc и три причины;
  5. потребитель — r12/r13 ROOTS122.
  ESSENTIAL. Дубль схемы — С-4.
- (в) Сверка живого origin в неявной ветви (`:795-798`): принята Rev122V7 (Б-1), блоб тот же. ESSENTIAL.
- (г) Вычисляемый алфавит Г2 (`ci_preflight.sh`: `first_expression`/`substitute`/`refuse_expression`):
  1. свойство — v+1 «`${{ github.workspace }}` и vyrazhenie-ne-podderzhano»;
  2. состояние — нет, чистые функции;
  3. совместно меняемых — 1;
  4. интерфейс не вырос, только новые причины;
  5. потребитель — p9/p10/p11.
  ESSENTIAL. Глубина не исследовалась сверх батареи: вызов узкий.

ПРОВОДКА (038): §Граница и порядок v6 — «новых CI/role-каналов нет». Дифф не трогает roles/, реестр шагов и `.github/` — соответствует.

## Не проверено

- Полный CI. PR #1158 на этом head зелёный по заданию; сам не смотрел.
- Новый полный поиск по 122.
- Глубокий разбор Г2 (`ci_preflight.sh`) сверх батареи 74/74.
- `check_provodka` (полный, не `--grammar`), `check_precision_gate`, `check_threat_model` отдельно. `--grammar`, precision-gate и threat-model входят в двери листа: на кандидате с 5fd0cf7108 `check_sdacha --run` rc 0, двери=11.
- `verify_antiplacebo --scope ci_preflight` — неприменим по слову владельца 18:43.
- Ленд-дерево (OBJECT + 5fd0cf7108 + текущий main b3394d0c9b) целиком не собиралось. Сделано: `merge-tree` чист, пути 122 на main после b1234ec2e2 не менялись.

## Исправленные ошибки своих команд

- Первый `bash` отклонён Н-85: относительная запись без cwd. Повторён с абсолютным cwd до любых действий.
- `git fetch origin main` — «'origin' does not appear to be a git repository»: у копии нет remote origin. Заменено на `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/main`, FETCH_HEAD = b3394d0c9b = локальный refs/remotes/origin/main.
- `git show $(git log … -- .review/2026-11-19-121.md):…` — пустая подстановка (файла Rev122V6 в истории нет). Не используется как довод.
