FAIL
OBJECT=56f4b03adba065a2eb152978699f39d7ad3df994
СУД: repo=dev-harness; предмет=167; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Review167V2; модель-факт=anthropic/claude-opus-5-5; OBJECT=56f4b03adba065a2eb152978699f39d7ad3df994
Контракт: frozen/contracts/167/2 (тег 98beba5f → коммит 587b04f7, предок origin/main 7dc408e2). Кандидат: wip/167/implementer, PR #606, headRefOid = OBJECT (`gh pr view 606`). База: origin/main = merge-base = 7dc408e241879fa3952ac3effc7d8efa32221c49.
--sud: reviewer <трасса> Review167V2; строка трассы (`scripts/models_actual.sh --tsv --bind --all`): `reviewer	anthropic/claude-opus-5-5	allowed	Review167V2	56f4b03adba065a2eb152978699f39d7ad3df994`; `scripts/check_sud_model.sh --verdict reviewer --trace <эта строка> --object 56f4b03a… --session Review167V2 --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0.

# Вердикт reviewer — 167, реализация, вызов 1 (полный)

## Итог

FAIL по двум блокирующим находкам в зоне implementer:

- **Р167-Б1.** Узкое исключение pre-push пропускает merge main→wip при пересечении путей, если на
  стороне main путь переименован. Исход зависит от `diff.renames` пользователя.
- **Р167-Б2.** Тихая правка чужой нормы владельца в `roles/orchestrator.md:367`, вне ПЕРЕСЕЧЕНИЯ.

Остальное по механизму принимаемо. D11 и `--osvobodit` отвечают §Предмет п.2. Барьер не тронут.
Красное на базе предъявлено. Норма-строки ПРОВОДКА стоят байт в байт. Генератор чист. CI на OBJECT
зелёный. Четыре пункта уровня контракта/владельца (В-1…В-4) и один done-блок вне зоны implementer
(БЛОК-DONE-1) реализацию не блокируют, но названы.

FAIL относится к блобам OBJECT 56f4b03a. Исправленная редакция судится заново по новому OBJECT.

Прогоны — в одноразовом клоне `/tmp/dev-harness-verify/r167v2` (собственный `.git`, HEAD = OBJECT).
Красное — в клоне `/tmp/dev-harness-verify/r167v2-base` (HEAD = 7dc408e2). SSH-хостов в станции не
настроено (`ssh://` → «No SSH hosts are configured»), поэтому клоны локальные под `/tmp/dev-harness-verify/`.
GIT_DIR/GIT_WORK_TREE на основной репозиторий не направлялись; push не делался.

## 1. Область правки (своя мера)

`git log --format='%h %an %s' 7dc408e2..56f4b03a` — 7 коммитов, все `implementer`, все с префиксом `167:`:
```
56f4b03ad implementer 167: .omp/agents — регенерация вывода изменённого текста roles/orchestrator.md
299b94436 implementer 167: раздел --osvobodit стоит перед своей дверью, а не после хелпера
821181fbf implementer 167: NOT_IMPLEMENTED по судейским refs отпускает мьютекс решения
ba796900f implementer 167: батарея 140 — клетка s06 на настоящем вердикте; b05 на реальной причине release
573c15d32 implementer 167: норма orchestrator — синхронизация ветки PR с main и оборванный судья
e154a770b implementer 167: pre-push — узкое исключение для полного merge живого origin/main в ветку PR
15b6e81fe implementer 167: D11 считает учтённое судейство; причина освобождения судьи — по вердикту
```
`git diff --shortstat 7dc408e2 56f4b03a` → `5 files changed, 245 insertions(+), 12 deletions(-)`.
`git diff --name-only … | grep -cvxE '<5 путей ЗОНЫ implementer>'` → 0 путей вне зоны.

Атомарность соблюдена: один срез на коммит (D11/osvobodit; pre-push; роль; батарея 140; два
уточнения osvobodit; генерация).

Внутри зоны — превышение ПЕРЕСЕЧЕНИЯ: см. Р167-Б2.

## 2. Барьер не переписан под реализацию

- `git diff --stat 98beba5f 56f4b03a -- contracts/167-…md fixtures/workshop_project/obryv_167/` → пусто, rc=0.
- `git log 7dc408e2..56f4b03a -- fixtures/workshop_project/obryv_167 contracts/` → пусто.

Замороженный барьер (тег frozen/contracts/167/2) инвариантен на OBJECT.

`fixtures/workshop_project/odin_agent_140/probe.py` изменён только в разрешённых ПЕРЕСЕЧЕНИЕМ местах:
- `release(…, prichina='yield')` — параметр с прежним умолчанием, прочие вызовы не меняются;
- хелпер `_verdikt_sudyi`, вызванный только в s06;
- в b05 — `mir.release('141', 'Critic141', 'obryv_bez_verdikta')`.

## 3. Сырой вывод (своя мера)

`bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo` на OBJECT:
```
CASE interrupted ok
CASE verdict ok
CASE verdict_no_receipt ok
CASE reviewer_verdict ok
CASE remote_unavailable ok
CASE verdict_wrong_author ok
CASE verdict_wrong_path ok
CASE verdict_wrong_object ok
CASE verdict_wrong_session ok
CHECKED 9 CASES; FAILURES 0
MERGE separate ok
MERGE registry ok
MERGE overlap ok
MERGE registry_drop ok
MERGE partial ok
MERGE other_ref ok
rc=0
```
`--model` на OBJECT: те же 15 строк ok, rc=0.

`--stabs` на OBJECT, rc=0. Своя мера: `grep -cE '^STAB .* caught'` = 16, `grep -c STAB_ZHIV` = 0.
Пойманы:
- `ignore_all_starts` (verdict, interrupted), `yield_is_verdict`, `always_block`, `no_retry_limit`;
- `skip_remote_check`;
- `no_author_check`/`broader_path`/`no_object_check`/`no_session_check` — на своих клетках wrong_author/path/object/session;
- `forbid_all` (separate, registry), `allow_all` (overlap, registry_drop, partial);
- `no_ref` (other_ref).

**Красное на базе 7dc408e2** (`--repo`), rc=1:
```
CASE interrupted KRASNO ACCOUNTING: RELEASE=[{… 'prichina': 'yield' …}], expected=obryv_bez_verdikta
CASE verdict KRASNO … expected=verdikt_zakommiten; committed verdict blocks repetition: rc=0 … PUSCHEM Critic167Again
CASE verdict_no_receipt ok
CASE reviewer_verdict KRASNO …
CASE remote_unavailable KRASNO REMOTE_NOT_CLOSED rc=0 stderr=
CASE verdict_wrong_author|path|object|session KRASNO … 'prichina': 'yield' … expected=obryv_bez_verdikta
CHECKED 9 CASES; FAILURES 8
MERGE separate KRASNO rc=1 expected=0 stderr=ОТКАЗ: pre-push: merge main в ветку запрещён … приносит историю main …
MERGE registry KRASNO rc=1 expected=0 stderr=ОТКАЗ: pre-push: merge main в ветку запрещён …
MERGE overlap ok / registry_drop ok / partial ok / other_ref ok
rc=1
```
Это совпадает с первой строкой приёмки: `CASE interrupted KRASNO` с RELEASE `yield`,
`MERGE separate/registry KRASNO` с причиной «merge main в ветку запрещён».

Прочие гейты:
- `npm run -s gen:harness -- --check` → `харнес соответствует roles/ (12 ролей)`, rc=0.
- `bash scripts/pre_critic.sh --repo . contracts/167-…md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2`, `КРИТИК: дверь зелёная`, rc=0.
- `bash scripts/check_provodka.sh . contracts/167-…md` → `проводка: guard не подключён: scripts/zamok_predmeta.sh не вызывается в .githooks/ или .github/workflows/`, rc=1. Это БЛОК-DONE-1, вне зоны implementer.
- Норма-строки ПРОВОДКА (python, построчное равенство, без обрезки):
  - `roles/orchestrator.md`: точных совпадений 1 и 1 (830 и 450 символов);
  - `.omp/agents/orchestrator.md`: 1 и 1.
- CI PR #606 на OBJECT (`gh pr checks 606`) — pass: antiplacebo ap1–ap5, ci l1–l7 (в l3 — `check:odin-agent-140-family-selftest`), klass, legkij, obshchij, tyazhelyj-itog; vorota — skipping. Батарею 140 сам не гонял: прогоны ограничены заданием.

## 4. Атаки своей мерой (одноразовые скрипты, удалены после прогона)

### 4.1 Переименование на стороне main (→ Р167-Б1)

Мир:
- toy-репо с `file://` origin;
- на ветке `wip/167/architect` правка строки в `shared.txt`;
- на живом main — `git mv shared.txt moved.txt`;
- полный `git merge --no-ff main` (rc 0, без конфликта) и настоящий `.githooks/pre-push` OBJECT.

```
rename: main delta (diff.renames=True): ['moved.txt']
rename: branch delta: ['shared.txt']
rename: pre-push rc 0 stderr:
rename: main delta (diff.renames=False): ['moved.txt', 'shared.txt']
rename: branch delta: ['shared.txt']
rename: pre-push rc 1 stderr: ОТКАЗ: pre-push: merge main в ветку запрещён … приносит историю main …
```
Путь `shared.txt` изменён обеими сторонами: main его удалил, ветка правила. Это пересечение по
путям, §Предмет п.1 требует отказа. С умолчанием git (`diff.renames=true`) хук пропускает merge,
с `diff.renames=false` — отказывает. Один и тот же коммит получает разный исход по
пользовательскому конфигу.

Проверка более простой формы: `--no-renames` в четырёх вызовах `git diff --name-only`
(pre-push:215,216,271,272) на копии в клоне дал:
- `red_obryv_167.sh --repo` — 15/15 ok, rc=0;
- rename-атака — rc 1 при обоих значениях `diff.renames`.

Правка откатана, `git status` клона чист.

### 4.2 Живой реестр против грамматики (→ В-3)

Своя мера по `registry/contracts.tsv` OBJECT:
- 176 строк, вне `^[0-9]{3} → [0-9a-f]{40}$` — 0;
- дубли ключей: `032` (строки 31, 32: a6c8abb6… / 9f0ee662…) и `035` (строки 35, 36: 0e030017… / 2a5a2f46…).

Мир: живой реестр как база; main дописал `168 → b…`, ветка — `169 → c…`; конфликт разрешён
объединением всех строк. Результат: `pre-push rc 1 … merge main в ветку запрещён`.
`merge_167_razreshen` отказывает на дубле ключа в одной стороне (pre-push:243) — так же поступает
замороженная модель `merge_policy.py` (`DUPLICATE_REGISTRY_KEY`).

### 4.3 Вердикты в живых конвенциях репозитория (→ В-1, В-2)

Мир — тот же, что в клетках `probe.py` (`Mir` 140, `file://` origin). Судья завершён, вердикт
`FAIL` закоммичен, затем явный `--osvobodit` и повтор того же OBJECT:
```
control critic frozen-shape: prichina=verdikt_zakommiten | repeat rc=1 OBJECT_UZHE_SUZHEN
critic-sol committed as critic (roles/critic-sol.md:147): prichina=obryv_bez_verdikta | repeat rc=0 PUSCHEM (sudja/critic-sol)
critic krug-name contracts-141-krug1-fail.md: prichina=obryv_bez_verdikta | repeat rc=0 PUSCHEM (sudja/critic)
reviewer impl-name contracts-141-impl-v1.md: prichina=obryv_bez_verdikta | repeat rc=0 PUSCHEM (sudja/reviewer)
```
Реализация буквально следует замороженным гейтам: автор = роль, путь `contracts-<N>-v*`. Её
функция `verdict_sessii` текстуально совпадает с `NEW_FUNCTION` контрольной модели `probe.py`.
Поэтому это пункты к контракту и владельцу, а не FAIL реализации.

## 5. Семантика D11 и `--osvobodit` против §Предмет п.2

- `subekt_suzhen_sudej_obj` (zamok_predmeta.sh:245–257) ведёт состояние по holder. START роли/OBJECT → `open`;
  собственный RELEASE `obryv_bez_verdikta` → `interrupted`; иной RELEASE → `judged`. Круг состоялся, если
  есть holder не в `interrupted`. Это даёт:
  - один release — один повтор;
  - новый START снова учитывается;
  - START без release не даёт бесплатной попытки.
- Проверка D11 вынесена из-под `if [ -d zanyat ]` (zamok_predmeta.sh:478–486) и исполняется при снятом замке.
  Блоки `SUDJA_ZHIV`/`ZAMOK_BROSHEN` не тронуты.
- `osvobodit` (zamok_predmeta.sh:638–661):
  - причина судьи — только по `verdict_sessii`;
  - `ls-remote` или `fetch` не прошли → `NOT_IMPLEMENTED`, мьютекс отпущен, RELEASE не пишется, `zanyat` цел;
  - `ZAMOK_ZHIV` живого holder стоит раньше и не изменён.
- RELEASE пишет только `osvobodit` (grep `RELEASE` по файлу: единственный писатель — :663). Других
  путей записи `obryv_bez_verdikta` нет.

## 6. Узкое исключение pre-push против §Предмет п.1

Ограничения на месте:
- ref `refs/heads/wip/[0-9]{3}/*`; `wip/int-*` не проходит;
- второй родитель = живой `LIVE_MAIN` из `ls-remote`;
- первый родитель не предок main;
- раздельные дельты → `merge-tree` rc 0 и дерево результата = автослиянию (злой merge и `-s ours` отказывают);
- реестровое пересечение → объединение L∪R без перезаписи, без лишних ключей, прочие пути = автослиянию.

Общее кольцо charter и не-PR refs не тронуты: вызов вставлен до прежней логики и при отказе
исключения отдаёт управление ей без изменений.

Дефект: определение «пересечения по путям» зависит от детекции переименований (Р167-Б1).

## 7. Паразитная сложность (050)

| артефакт | (1) свойство контракта | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| `merge_167_razreshen` (pre-push) | п.1, механическая часть | нового нет; читает глобальный `LIVE_MAIN` (неявный вход, существующая конвенция хука) | хук + роль + модель `merge_policy.py` = 3 (новое свойство) | 2 аргумента, rc 0/1; работа скрыта целиком | `merge_probe --repo`, CI; повтор грамматики модели ожидаем | ESSENTIAL; три почти одинаковых цикла чтения L/R/M — совет С-1 |
| `reg_167_stroka` | п.1, грамматика строки | нет | 1 | 1 аргумент → rc | тот же | ESSENTIAL |
| `verdict_sessii` | п.2, истинность по коммиту | нет | 1 | 4 аргумента → rc | `probe.py` клетки verdict/wrong_* | ESSENTIAL |
| D11 `jq reduce` | п.2, учёт круга | нет | 1 | прежний интерфейс | клетки interrupted/verdict | ESSENTIAL; первый `jq any(START)` избыточен (reduce без START даёт `{}` → rc 1) — совет С-2 |
| ветвь судьи в `osvobodit` (ls-remote + fetch) | п.2, синхронизация refs до классификации | **побочное:** `fetch --prune` меняет `refs/remotes/origin/*` вызывающего REPO, в выводе не видно | 1 | CLI прежний; новый rc 2 | remote_unavailable | ESSENTIAL; побочный эффект — замечание С-3 |
| `probe.py` 140: `_verdikt_sudyi`, `release(prichina)` | ПЕРЕСЕЧЕНИЕ s06/b05 | нет | 1 | — | батарея 140 (CI l3) | ESSENTIAL |
| раздел роли + генерат | ПРОВОДКА role ×2 | нет | 2 (источник + генерат), как у всех ролей | — | check_provodka, gen:harness --check | ESSENTIAL |

Блокирующих ACCIDENTAL нет.

## 8. ПРОВОДКА (038)

- Оба role-канала существуют и подключены текстом — §3.
- `guard=.githooks/pre-push` — исполняемая дверь, подключена через `.githooks`.
- `guard=scripts/zamok_predmeta.sh` — субъект, а не барьер (его заголовок: «НЕ БАРЬЕР: субъект»).
  В `.githooks/` и `.github/workflows/` он не вызывается, `check_provodka` rc=1. Барьер предмета
  `red_obryv_167.sh` в `registry/ci-steps.tsv`, `registry/ci-zamery.tsv` и `.github/workflows/ci.yml`
  отсутствует (`grep -c obryv_167` = 0, 0, 0). Это БЛОК-DONE-1.

Поведенческие нормы идут role-каналами.

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` dev-harness не объявляет документа архитектуры и
стандарта кода: `grep -cE 'ARCHITECTURE|CODING-STANDARDS|стандарт кода' AGENTS.md` = 0.
Режим проекта 996 не объявлен (sourceCanon нет), сверка источников не требуется.

## Находки

status: ready

- [ ] **Р167-Б1 (БЛОК, implementer, `.githooks/pre-push:215–216`, а также :271–272).**
  - Фрагмент: `mapfile -t d1 < <(git -C "$ROOT" diff --name-only "$base" "$p1")`, то же для d2, cm, cm2.
  - Без `--no-renames` `git diff` сводит переименование в один новый путь, и удалённый на main путь
    выпадает из дельты.
  - Отсутствующее свойство: §Предмет п.1 «только если изменения main с момента merge-base НЕ
    пересекаются по путям … любые другие пересечения … или неопределённость — отказ»; Модель угроз
    «Merge, который игнорирует чужой путь main».
  - Контрпример (§4.1) — конформный вход: полный merge живого origin/main на разрешённом ref, без
    `-s ours`. Хук rc 0 при `diff.renames=true` (умолчание git) и rc 1 при `false`.
  - Более простая форма, проходящая те же строки приёмки: `git diff --no-renames --name-only` в
    четырёх вызовах. На копии: W `--repo` 15/15 ok, rc 0; атака отказывает при обоих значениях.
  - Регрессию закрепить нечем в зоне implementer: барьер — зона architect. Довод достаточен для
    исправления; клетку rename architect может добавить в v+1.
- [ ] **Р167-Б2 (БЛОК, implementer; область правки / норма тронута молча).**
  - `roles/orchestrator.md:367` (и генерат `.omp/agents/orchestrator.md:370`): в норме ПАУЗЫ
    «кто/когда согласовал, условие возврата» заменено на «условия возврата».
  - Норма внесена владельцем: `git blame` → 88500cac, author owner. Она не входит в 167.
  - ПЕРЕСЕЧЕНИЯ роли разрешают только «добавляется только норма 167; прежние нормы сохраняются» и
    «140 только норма судьи и PR-синхронизации; чужие нормы неизменны».
  - В сообщении 573c15d3 правка не названа. Ни один контракт или скрипт её не требует:
    `grep 'услови[ея] возврата'` по contracts/scripts/fixtures/registry — 0.
  - Закрытие: вернуть «условие возврата» в источнике и перегенерировать `.omp/agents/orchestrator.md`.
- [ ] **БЛОК-DONE-1 (контракт / orchestrator, НЕ блок реализации).**
  - `check_provodka.sh . contracts/167-…md` → rc 1 «guard не подключён: scripts/zamok_predmeta.sh».
  - Шага 167 нет в `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml`.
  - До done нужны:
    - интеграционный коммит orchestrator со шагом `red_obryv_167.sh` (`--repo`, `--model`, `--stabs`);
    - либо guard-строка, называющая барьер, а не субъект, через v+1. Добавление шага с вызовом
      `red_obryv_167.sh` само по себе `guard_is_wired` для `zamok_predmeta` не удовлетворит.
- [ ] **В-1 (вопрос владельцу / контракт v+1, не FAIL реализации): critic-sol.**
  - Гейт «author коммита совпадает с ролью» буквально сравнивает `%an` с `critic-sol`.
  - Роль `roles/critic-sol.md:147` предписывает коммитить под `user.name=critic`. Своя мера: все 42
    вердикта с `роль=critic-sol` в СУД закоммичены автором `critic`.
  - Следствие (§4.3): закоммиченный FAIL/accept critic-sol после `--osvobodit` получает
    `obryv_bez_verdikta` и бесплатный повтор. Это ровно угроза «Дубликат оплаченного суда».
  - Замороженная модель ведёт себя так же.
  - Решение: в v+1 назвать identity critic-sol (`critic`) либо сменить identity роли.
- [ ] **В-2 (вопрос владельцу / контракт v+1, не FAIL реализации): имена и форма вердиктов.**
  - Замороженный путь `verdicts/<роль>/contracts-<N>-v*` и самостоятельная строка `OBJECT=` не
    покрывают живые конвенции. Своя мера по именам:
    - `verdicts/review/contracts-NNN-impl-vN.md` — 99;
    - `verdicts/adversary/contracts-NNN-impl-vN.md` — 89;
    - `verdicts/critic/contracts-NNN-krugN-fail.md` — 115.
  - Пример: вердикт ревьюера 166 (`contracts-166-impl-v1.md`) несёт OBJECT только внутри строки
    СУД.
  - §4.3: такие вердикты после `--osvobodit` классифицируются как оборванные, и повтор разрешается.
    Сам этот вердикт назван по заданию `contracts-167-impl-v2.md` и под гейт тоже не попадает.
    Самостоятельные `OBJECT=` и `сессия=` в нём проставлены.
  - Решение: либо норма имени и формы вердикта в ролях судей, либо расширение гейта в v+1.
- [ ] **В-3 (вопрос владельцу / контракт v+1): реестровое исключение мёртво на живом реестре.**
  - В `registry/contracts.tsv` два дубля ключей с разными значениями: 032 и 035, обе пары от
    2026-09-20 (8b3aa2bb, owner).
  - Контракт велит отказывать на совпавших ключах, поэтому любой merge с пересечением по реестру
    в этом репозитории отказывает (§4.2). Работает только ветвь «раздельные дельты».
  - Отказ fail-closed и безопасен, но цель владельца «вливать … готовую работу» для реестрового
    случая не достигается. Нужно решение: чистка дублей владельцем или уточнение правила.
- [ ] **В-4 (architect, совет к барьеру).**
  - В `merge_probe.py` режим `--model` вставляет условие модели сразу после `p1="${parents[1]}"`, то
    есть до проверки реализации `merge_167_razreshen`.
  - На дереве кандидата `--model` разрешает merge, если разрешает модель ИЛИ реализация. Как
    независимый эталон отрицательных клеток он не чист.
  - На OBJECT это исход не меняет: реализация на этих клетках отказывает, а мера — `--repo`.
- [ ] **С-1 (совет).** Три копии цикла чтения реестра L/R/M (pre-push:239–262) — одна функция с
  `local -n`.
- [ ] **С-2 (совет).** Первый `jq … any(START)` в `subekt_suzhen_sudej_obj` повторяет
  работу reduce: второй проход по учёту без нового свойства.
- [ ] **С-3 (замечание).** `osvobodit` судьи делает `fetch --prune origin` в `--repo` вызывающего,
  то есть мутирует его remote-tracking refs. Этого требует контракт (синхронизация до
  классификации), но в выводе двери побочный эффект не назван.
