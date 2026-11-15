accept
OBJECT=dd516ddc3ceee79e6865a3ba122265867d04188d
СУД: repo=dev-harness; предмет=190; фаза=реализация; роль=reviewer; вызов=4 (scoped, одноразовый по слову владельца); модель-план=anthropic/claude-opus-5-5; сессия=Rev190Scoped4; SHA=dd516ddc3ceee79e6865a3ba122265867d04188d; контракт=frozen/contracts/190/1; предыдущий=verdicts/review/contracts-190-impl-v3.md (FAIL, Б-1; текст /tmp/dev-harness-verify/verdict-190-impl-v3.md); исключение=слово владельца 2026-11-15 ~10:45 UTC через консультанта (4-й scoped-вызов reviewer по 190 на head PR #907 после исправления Б-1)
КЛАСС=обычный

# Вердикт reviewer — 190, реализация, вызов 4 (scoped)

**accept.** Б-1 вердикта v3 закрыт по существу. Шаг `check:zamer-svyazki-190-family-selftest` теперь в точности та простая форма, которую предписывал v3: без `git archive` и без чтения объектов git. В strip-дереве безфлаговый суд идёт по настоящей реализации. Канон документа он берёт из пинованной кодовой копии `_zamorozka`, а её блоб равен `docs/190` того же HEAD. Дельта — одна строка в зоне orchestrator, одним коммитом. frozen 190 не ослаблен. CI на OBJECT зелёный в первой попытке, все 17 job. Блоков нет. Accept v2 сюда не переносится, это отдельное суждение по OBJECT.

## Кандидат и область (А-350)

Одноразовый SSH-клон `/tmp/dev-harness-verify/Rev190Scoped4/repo` со своим `.git` (push не делался, общий checkout не тронут):

```
$ git rev-parse pr907 origin/wip/190/architect origin/wip/190/orchestrator
dd516ddc3ceee79e6865a3ba122265867d04188d  (×3)
$ git log --format='%H %P | %an <%ae> | %cn | %s' -1 dd516ddc3c
dd516ddc… 05807e003e… | orchestrator <orchestrator@dev-harness.local> | orchestrator | 190: ci-steps zamer-svyazki selftest — простая форма без git archive docs (Б-1)
$ git log 05807e003e..dd516ddc3c → ровно 1 коммит (orchestrator/orchestrator)
$ git diff --stat 05807e003e dd516ddc3c → registry/ci-steps.tsv | 2 +-  (1 файл, 1+/1−)
$ git diff --name-only 05807e003e dd516ddc3c -- contracts frozen .github registry/ci-zamery.tsv | wc -l → 0
$ git diff --stat frozen/contracts/190/1 dd516ddc3c -- contracts/190-zamer-svyazki.md → пусто, rc=0 (frozen/contracts/190/1 = bd8b3e6a66)
$ gh pr view 907 → headRefName=wip/190/orchestrator headRefOid=dd516ddc… state=OPEN mergeable=MERGEABLE base=main
```

Дельта целиком:

```
@@ -309 +309 @@
-step  check:zamer-svyazki-190-family-selftest  4  bash …/red_zamer_svyazki_190.sh --stabs && bash -n scripts/zamer_svyazki.sh && T=$(mktemp -d) && trap 'rm -rf "$T"' EXIT && git archive HEAD fixtures/workshop_project/zamer_svyazki_190 scripts/zamer_svyazki.sh scripts/zamer_svyazki.py docs/190-zamer-svyazki.md | tar -x -C "$T" && bash "$T"/…/red_zamer_svyazki_190.sh
+step  check:zamer-svyazki-190-family-selftest  4  bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh --stabs && bash -n scripts/zamer_svyazki.sh && bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
```

**Зона и атомарность.** Путь `registry/ci-steps.tsv` относится к ЗОНЕ orchestrator по frozen 190:71. Автор и коммиттер — `orchestrator`. Коммит один, сообщение ссылается на 190 и Б-1. Норма не тронута: diff по contracts и frozen пуст.

## (1) Б-1 закрыт по существу — своя мера

Норма — frozen 087 (`contracts/087-ci-b-klassy-izmenenij-hesh-koda.md`):
- `:178` — «тяжёлые шаги исполняются на дереве без учётных путей»;
- `:185` — «чтение учётного содержимого тяжёлым шагом через объекты git (`git show HEAD:<учётный путь>`) в обход strip — ловец ревьюер»;
- `:249` — «правка фикстуры, не расширение U».

Команда шага на OBJECT не содержит ни одного обращения к git. Учётные байты в неё не попадают.

Strip я выполнил в своём клоне на OBJECT:

```
$ git checkout --detach dd516ddc3c && H=$(bash scripts/ci_klass.sh hash HEAD)
H=02e01f71ec38dd6a2342cd9bad736a8b0fee491f76738db8236da1975756699a
$ bash scripts/ci_klass.sh strip "$H"
strip: удалено учётных путей 2272, кодовое дерево H=02e01f71…699a   rc=0
$ find docs -type f | wc -l → 0 ; ls -d docs → No such file or directory (каталог подрезан)
остались: scripts/zamer_svyazki.sh, scripts/zamer_svyazki.py, fixtures/…/_zamorozka/190-zamer-svyazki.md
git status --porcelain | wc -l → 2272 ; … -- fixtures/…/zamer_svyazki_190 scripts/zamer_svyazki.* | wc -l → 0
```

H из клона совпадает с H в CI: лог l3 `:1704` даёт `strip: удалено учётных путей 2272, кодовое дерево H=02e01f71…699a`, а tyazhelyj-itog выгрузил артефакт `tyazhelyj-02e01f71…699a`. Значит, судимое дерево в CI — дерево OBJECT.

Путь суда в strip-дереве прослежен по коду на OBJECT:
- `probe.py:53` задаёт `TOOLS = HERE.parents[2]`, то есть корень checkout.
- `probe.py:789-806`: без флага `subj = TOOLS/scripts/zamer_svyazki.sh`, `doc_root = TOOLS`. Субъект — настоящая реализация HEAD, не стаб и не модель.
- `probe.py:392-404` (`_fajly_pod_docs`): если `docs/` не каталог, возвращается `[]`. Сразу после strip каталога нет.
- `probe.py:406-442` (`kanon_istochnik`): живого файла нет, остатка нет, поэтому читается `_zamorozka`. В источнике значится «замороженная копия … кодовый артефакт в H».
- `probe.py:377-390,684,720`: `_git` вызывается только в temp-мирах клеток `kanon-strip*` и никогда по `TOOLS`. В `scripts/zamer_svyazki.sh` и `scripts/zamer_svyazki.py` вызовов `git` или `subprocess` нет: grep пуст, rc=1.

Копия равна документу того же HEAD и запинована:

```
$ git rev-parse dd516ddc3c:docs/190-zamer-svyazki.md dd516ddc3c:fixtures/…/_zamorozka/190-zamer-svyazki.md
413dfc67e4db5d0911bb76747b18907dc78ba453
413dfc67e4db5d0911bb76747b18907dc78ba453
$ sha256sum …/_zamorozka/190-zamer-svyazki.md → 1b9abae7…f465 = source.json piny["_zamorozka/190-zamer-svyazki.md"] (check_pins, probe.py:487-494)
```

Исход тяжёлого шага теперь зависит только от H. Контрпример v3 — M/M′ с одним H, правка только `docs/190` — эту форму больше не различает. Strip удаляет `docs/` в обоих деревьях, обе стороны читают один и тот же блоб `_zamorozka` из H, а команда шага объекты git не читает. [INFERENCE: вывод сделан по коду и равенству H; зонд M′ на новой форме я не исполнял, потому что батарею по заданию не запускаю.]

Сырой CI, job l3 132661935655, checkout `ref: dd516ddc…` (`:38`), `HEAD is now at dd516ddc 190: … (Б-1)` (`:1696`):

```
:2448 + bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh --stabs && bash -n scripts/zamer_svyazki.sh && bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
:2503 ИТОГ 190: клеток 34, зелёных 34, красных 0; СВЯЗИ 19, поймано 19, жив 0      (--stabs)
:2537 GREEN kanon-drift-kopii
:2538 ИТОГ 190: клеток 34, зелёных 34, красных 0; СВЯЗИ 0, поймано 0, жив 0        (без флага, strip-дерево)
:2540 замер: check:zamer-svyazki-190-family-selftest 2
```

Заявление ведущего «docs/ пуст (0), --stabs 34/34 и СВЯЗИ 19/19, bash -n rc 0, без флага 34/34» сверено другой мерой: собственный strip и подсчёт файлов в клоне плюс сырой лог CI на OBJECT. Повтором команды ведущего это не делалось. Расхождений нет. Батарею сам я не запускал: это запрещено заданием. 34/34 и 19/19 взяты из сырого лога CI на этом SHA.

**Красное.** Новых барьеров дельта не вводит, она только убирает обходную ветвь. Красность того же суда против сломанной реализации видна в том же логе: стабы `caught` 19/19 (`:2503`, например `:2502 STAB stab_vyzov_slesh_strog.py caught @ forma-vyzova`). Strip-клетки `kanon-strip-podmena`, `kanon-strip-lozhnyj` и `kanon-otsutstvuet` требуют отказа от суда (`probe.py:733-745`). Фикстуры с v3 не менялись: в дельте `fixtures/` нет.

## (2) Сохранность шага и чужих строк

- В новой строке остались `--stabs` и `bash -n scripts/zamer_svyazki.sh`. Вес по-прежнему `4`, ключ тот же.
- Дельта меняет ровно одну строку, `:309`. Строки 157 (`:287`) и 189 (`:308`) не тронуты: в diff один hunk, 1+/1−.
- `.github/workflows/ci.yml` и `registry/ci-zamery.tsv` в дельте не меняются (diff пуст). ci.yml несёт только ключи (`ci.yml:276 keys: … check:zamer-svyazki-190-family-selftest …`), поэтому команда шага в генерат не входит. `ci-zamery.tsv:111 check:zamer-svyazki-190-family-selftest 2 1 0` не изменён.
- Генератор согласован. Job obshchij 132661935562 на OBJECT: `:1954 ok Г1: gen_ci_steps.sh --check rc 0`, `:1957 ok Г3: покрытие: ключи блока == step-ключи реестра`, `:2075 083-батарея: ok=120 FAIL=0`, `:1947 ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31`.

## (3) frozen 190 не ослаблен

- `git diff frozen/contracts/190/1 dd516ddc3c -- contracts/190-zamer-svyazki.md` пуст.
- frozen 190:73 требует, чтобы проводка была «шаг `check:zamer-svyazki-190-family-selftest` (безфлаговый суд батареи)». Шаг теперь и есть безфлаговый суд, без обёртки.
- frozen 190:61 требует, чтобы отсутствие или расхождение документа давало красную клетку. Это держат `dokument-kanon`, `kanon-podmena`, `kanon-otsutstvuet` и `kanon-strip-lozhnyj`. Фикстуры не тронуты.

## (4) Raw CI PR #907 — run 43664863536, job за job

```
run: id=43664863536 event=pull_request head_branch=wip/190/orchestrator head_sha=dd516ddc… run_attempt=1 status=completed conclusion=success pull_requests=[907] created_at=2026-11-15T01:49:14Z
132661881350 klass            success
132661881412 legkij           success
132661882296 vorota           skipped   (только push: frozen 087:140 «vorota — if: github.event_name == 'push'»)
132661935562 obshchij         success   (083-батарея ok=120 FAIL=0)
132661935711 antiplacebo ap1  success
132661935676 antiplacebo ap2  success
132661935608 antiplacebo ap3  success
132661935576 antiplacebo ap4  success
132661935601 antiplacebo ap5  success
132661935581 ci l1            success
132661935611 ci l2            success
132661935655 ci l3            success   (шаг 190)
132661935642 ci l4            success
132661935715 ci l5            success
132661935586 ci l6            success
132661935635 ci l7            success
132667780441 tyazhelyj-itog   success   (артефакт tyazhelyj-02e01f71…699a, ID 14142580948)
```

Красных job на этом SHA нет. Повторная попытка не понадобилась: гонка SIGPIPE 083 (Н-9 из v3) на этом прогоне не проявилась, батарея дала `ok=120 FAIL=0` с первого раза.

## ПРОВОДКА (038)

- `guard=scripts/zamer_svyazki.sh` есть в strip-дереве (кодовый путь).
- Шаг выполняет `bash -n` по guard и затем исполняет его как субъект безфлагового суда прямо из checkout (`TOOLS`), а не из копии, извлечённой из git.
- ПРОВОДКА-ЭНФОРСМЕНТ (frozen 190:240) честен: батарея подключена bash-обёрткой `red_zamer_svyazki_190.sh` (`exec python3 probe.py "$@"`).
- Канал подключён. Дефект источника байтов (Б-1) снят.

## Паразитная сложность (050)

- **Строка `ci-steps.tsv:309`, новая форма.** Ответы на пять вопросов:
  1. Свойство: frozen 190:73, безфлаговый суд, при учёт-независимости 087:178.
  2. Состояние: нового нет. Временный каталог, `trap` и скрытые байты из объектов git удалены.
  3. Вместе меняется 1 файл (ci.yml несёт только ключ). Число не выросло, а уменьшилось.
  4. Интерфейса нет, работа та же.
  5. Потребитель — job `ci` l3. Логику фолбэка `_zamorozka` строка больше не дублирует.

  **ESSENTIAL.** Проще формы, проходящей те же строки приёмки, нет.
- **`kanon_istochnik`, `_fajly_pod_docs`, `_zamorozka` с пином** — дельтой не менялись. Вердикт v3 условно признал их ESSENTIAL, если Б-1 будет исправлен. Условие выполнено: фолбэк в CI живой, `docs/` после strip отсутствует.

## СВЕРКА-СТАНДАРТОВ

Неприменимо:
- `git show dd516ddc3c:AGENTS.md | grep -c -E 'ARCHITECTURE|CODING-STANDARDS|sourceCanon'` → 0;
- `git ls-tree -r --name-only dd516ddc3c -- docs/ARCHITECTURE.md docs/CODING-STANDARDS.md | wc -l` → 0.

sourceCanon не объявлен, мобильного экрана нет.

## Находки (reslop, status: ready)

- [x] **Б-1 (v3) — закрыт.** Доказательства: `ci-steps.tsv:309` без `git archive`; strip на OBJECT даёт `docs/` отсутствует, 0 файлов; H клона = H CI = `02e01f71…699a`; CI l3 даёт 34/34 и 19/19, затем 34/34.
- [ ] **Н-11 (наблюдение, не блок).** В strip-дереве клетка `kanon-drift-kopii` зелена вакуумно (`probe.py:625-626`: живого файла нет). Значит, расхождение живого `docs/190` с `_zamorozka` CI не ловит, его ловит только прогон `--repo .` на дереве с учётными путями. Это свойство прецедента `_zamorozka` по 087 (`ci-steps.tsv` «Учёт-независимость обеспечена замороженными копиями»), а не дефект дельты. Правка одного `docs/190` — класс `uchet`, тяжёлое для неё reuse при любой форме шага.
- [ ] **Н-9 (совет, 083) — остаётся.** Гонка `printf | grep -q` под pipefail в `fixtures/ci_gen_083/red_ci_a_083.sh:1522` (и `:1505`). На этом SHA не проявилась.
- [ ] **Н-8 (наблюдение) — остаётся.** Строки 157 (`:287`) и 189 (`:308`) судятся в своих предметах, эта дельта их не трогает.

## Закрытие

accept применим только к OBJECT `dd516ddc3ceee79e6865a3ba122265867d04188d` и его обязательствам: frozen/contracts/190/1, frozen 087:178/185/249, Б-1 из v3. Любое изменение поведения, критерия или границы риска после этого accept делает его неприменимым.

Предлагаемый путь вердикта — `verdicts/review/contracts-190-impl-v4.md`, коммитить под identity reviewer. Вердикт в общий checkout я не писал, push не делал. Сборку, тесты, линтеры, форматтеры и батарею не запускал. В клоне выполнены только `checkout --detach`, `ci_klass.sh hash` и `ci_klass.sh strip`.

Клон и сырые логи job (`l3.log`, `obshchij.log`, `klass.log`, `itog.log`) лежат в `/tmp/dev-harness-verify/Rev190Scoped4/`. Каталог одноразовый, его можно удалить после коммита вердикта.

Узкая проверка ведущему (по желанию) — в одноразовом клоне на OBJECT после `bash scripts/ci_klass.sh strip $(bash scripts/ci_klass.sh hash HEAD)`: выполнить команду шага `:309` целиком. Ожидается rc 0, `ИТОГ 190: клеток 34, зелёных 34` дважды, `СВЯЗИ 19, поймано 19`.
