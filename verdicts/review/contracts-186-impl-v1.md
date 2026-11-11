FAIL
OBJECT=61b2b2bf8cdde8199cd2b7ea23650ea83beea20a
КЛАСС=рисковый
СУД: repo=a3ka/dev-harness; предмет=186; фаза=реализация; роль=reviewer; вызов=1/2; модель-план=anthropic/claude-opus-5-5; сессия=Rev186v1 (харнесс-сессия c907157c); модель-факт=anthropic/claude-opus-5-5; судимый PR=#803 wip/186/orchestrator 9209e817fa9b71275073fab58b47231c62187fd3; контракт=frozen/contracts/186/1 (commit da955f36c8c5f74261a7eb2e42b9e3e6d9866dad); адверсарий=verdicts/adversary/contracts-186-impl-v2.md (accept); предыдущий=нет

# Вердикт reviewer — 186 «хранитель архитектуры», реализация, вызов 1/2

**FAIL, два блока.** Находки в reslop-формате: `.review/2026-11-11-86.md` в клоне `/tmp/dev-harness-verify/Rev186v1/repo`, `status: ready`.

- **Б-1:** дверь L1 сливает L2 и L3 PR, когда checkout проекта не стоит на head PR.
- **Б-2:** клетка к5 батареи 074 переписана в тавтологию. Коммит architect f50c17e2 лежит вне зоны 186/1.

Советов три (С-1…С-3), наблюдений три (Н-1…Н-3). Класс риска подтверждаю: **рисковый**, повышать некуда.

Клон: `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev186v1/repo`, свой `.git`. Деревья:

| дерево | что |
|---|---|
| `obj` | OBJECT |
| `pr` | 9209e817 |
| `main` | origin/main 1971b19a |

## Кандидат

```
$ git rev-parse origin/wip/186/implementer origin/wip/186/orchestrator origin/main
61b2b2bf8cdde8199cd2b7ea23650ea83beea20a
9209e817fa9b71275073fab58b47231c62187fd3
1971b19ab482dc462b71dfd9f0ec238fdb544640
$ git diff --stat 61b2b2bf origin/wip/186/orchestrator -- <все 19 путей предмета: .omp/agents/architecture-steward.md .omp/agents/orchestrator.md .omp/config.yml config/agent_models.json fixtures/dver_bugfiks_080/… fixtures/ops_server/… fixtures/workshop_project/architecture_steward_186 ops/server roles/architecture-steward.md roles/orchestrator.md scripts/architecture_review.py scripts/check_architecture_pin.sh scripts/findings_status.py scripts/merge_architecture_pr.sh>
(пусто) rc=0
$ git diff --stat frozen/contracts/186/1 origin/wip/186/orchestrator -- contracts/186-hranitel-arhitektury.md
(пусто) rc=0
$ git merge-base origin/main origin/wip/186/orchestrator
2f8e06fd…   # за ним на main ещё 7 коммитов: только HANDOFF и verdicts, ни одного пути предмета
```

От OBJECT PR-tip отличается одним коммитом проводки CI (9209e817) и базой main.

## 1. Область правки и зоны

Источник зон — frozen-блоб `git show frozen/contracts/186/1^{commit}:contracts/186-hranitel-arhitektury.md`.

```
2a624f9c implementer  .omp/agents/architecture-steward.md .omp/config.yml config/agent_models.json roles/architecture-steward.md   — ЗОНА implementer ✓
8d1cc4d6 implementer  scripts/architecture_review.py scripts/findings_status.py                                                  — ✓
278dc6db implementer  scripts/check_architecture_pin.sh scripts/merge_architecture_pr.sh                                          — ✓
0750f161 implementer  ops/server/README.md ops/server/install.sh ops/server/root/orch-peak ops/server/root/systemd/orch-architecture.timer — ✓
8bba1e02 implementer  .omp/agents/orchestrator.md roles/orchestrator.md                                                           — ✓ (+ПЕРЕСЕЧЕНИЯ 010…100)
d922d9e1 architect    fixtures/workshop_project/architecture_steward_186/probe.py                                                — ✓
f50c17e2 architect    fixtures/ops_server/red_server_obvjazka_074.sh                                                              — ВНЕ зоны 186/1 (есть в ЗОНА architect 074/2) → Б-2
a9253a4c architect    fixtures/dver_bugfiks_080/red_dver_bugfiks_080.sh                                                            — ВНЕ зоны 186/1 (есть в ЗОНА architect 080/4) → Н-1
83e4bfcf architect    fixtures/workshop_project/architecture_steward_186/door_probe.py                                            — ✓
a0218165 architect    fixtures/workshop_project/architecture_steward_186/door_control.py                                          — ✓
f05ea9e7 implementer  scripts/merge_architecture_pr.sh                                                                           — ✓
9209e817 orchestrator .github/workflows/ci.yml registry/ci-steps.tsv registry/ci-zamery.tsv                                      — ЗОНА orchestrator ✓
```

`check_zones.sh` проверяет по объединению всех замороженных зон автора (`:1581`), поэтому оба architect-коммита мимо 186 он пропустит. Полный `check_zones` я не запускал — так требует ПРИЁМКА-СУДЬИ v2.

Атомарность: двенадцать коммитов, каждый ссылается на 186, identity авторов разведены. Контракт и вердикты в диффе PR не меняются. Implementer фикстур не трогал. Клетки двери (83e4bfcf) появились раньше правки двери (f05ea9e7).

## 2. Предмет против §Предмет 1–6

**Б-1. Дверь L1 сливает L2/L3 при чужом checkout.**

Обязательство — `frozen/contracts/186/1`:
- §Предмет 4: «запускает в корне проекта `npm run check -- --base governance/baseline/approved.json --report` и механически выводит L1 из `baseline PASS`», «Ни L2, ни L3 автор не сливает», «без записи владельца отказ `L3_OWNER_APPROVAL_REQUIRED`»;
- §Модель угроз (строка 150): «дверь с проверкой Git head, GitHub accept/CI, baselineStatus и отрицательной полярности L2/L3».

Фрагмент: `scripts/merge_architecture_pr.sh:206-208` запускает `npm run check` с `cwd=project`. Ни одного вызова `git` в скрипте нет: равенство HEAD и `headRefOid` не проверяется, грязное дерево тоже. Роль оркестратора не требует перейти на head PR. При этом штатный checkout станции стоит на `main`.

Вход: production-дверь в Git-мире `door_probe.world()`, fake `gh`/`npm` взяты из самой батареи. Зонд: `scratch/head_bypass.py`, одноразовый, лежит вне дерева.

```
l3_without_owner pr_head:       checkout_HEAD=0cf0e51d82bc PR_head=0cf0e51d82bc rc=1 out='L3_OWNER_APPROVAL_REQUIRED' merged=False main_parents=0 main:current.json={"moduleBoundaries": {"api": ["identity"]}, "resources": {"identity": "owner"}}
l3_without_owner checkout_main: checkout_HEAD=2418fb8dc5d1 PR_head=0cf0e51d82bc rc=0 out='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 0cf0e51d…' merged=True main_parents=2 main:current.json={… "resources": {"identity": "public"}}
l3_without_owner dirty_revert:  checkout_HEAD=0cf0e51d82bc PR_head=0cf0e51d82bc rc=0 out='СЛИТО: …' merged=True main_parents=2 main:current.json={… "resources": {"identity": "public"}}
l2_without_owner pr_head:       rc=1 out='L2_OWNER_APPROVAL_REQUIRED' merged=False
l2_without_owner checkout_main: rc=0 out='СЛИТО: …' merged=True main:current.json={"moduleBoundaries": {"api": ["identity", "new-api"]}, …}
l2_without_owner dirty_revert:  rc=0 out='СЛИТО: …' merged=True
```

Защищённую секцию `resources` дверь слила как L1, без записи владельца. Батарея этого не видит по двум причинам: `door_probe.world()` всегда оставляет проект на `pr-42`, а toy-эталон `door_control.py` повторяет ту же слепую зону.

Починка:
- implementer: перед `npm run check` проверить, что `git rev-parse HEAD` == `headRefOid` и `git status --porcelain` пуст. Иначе — именованный отказ без merge, как `PRODUCT_PR_HEAD_NOT_CHECKED_OUT` у пина.
- architect: клетки «checkout не на head» и «грязное дерево», мутант к каждой. Привязку делает по коду (Н-39).

**Остальной предмет по пунктам.** Каждый пункт сверен чтением кода и исполнением.

- §1. `findings_status.py` берёт состав среза через `git ls-tree <ref>`. Статусы — пять допустимых. Пустая причина у `отклонена:` или два поля `Статус:` дают просрочку. Вывод: `ПРОСРОЧЕНО: governance/findings/<имя>`, rc 1. Свежий файл не просрочен. Статус читается из рабочего дерева → С-1.
- §2. `architecture_review.py` читает `HEAD:governance/review/<дата>-<Э>.md`. Нет файла или он пуст → `НЕТ ОБЗОРА`. Нет одной из пяти строк-разделов → `НЕПОЛНЫЙ ОБЗОР`. В остальных случаях rc 0, в том числе на пустом срезе.
- §3. Роль поручает Астре проектный генератор REGISTER и проектный CI. Харнесс реестр не хранит.
- §4. Дверь проверяет:
  - ровно один `\bCOMPLIOR-[0-9]+\b` в заголовке;
  - логин автора против логина оператора, только через casefold; пустой автор → rc 2;
  - APPROVED на `commit_id == head` от логина критика, не автора PR, где `accept` — первая строка, одна строка `СУД:` с одним полем `модель-факт=`, оканчивающаяся `; SHA=<head>`;
  - check-runs со всех страниц `--paginate`; `architecture` с `app.slug=github-actions`;
  - baseline: L2/L3 → отказ;
  - затем один вызов `gh pr merge … --merge --match-head-commit <head>`.

  Дыра — Б-1. Модель критика зашита литералом → С-2.
- §4а. `check_architecture_pin.sh` проверяет: `state=MERGED`, двухродительский merge с head вторым родителем, один и тот же ID в обоих заголовках, `HEAD продукта == headRefOid`. Lock читается из коммита head. Отказы: `LOCK_MISSING`, `PIN_MISSING`, `PIN_MISMATCH` (в том числе на arch-head) и идентичность формата 167. Мутант «arch_head допустим» красный (раздел 4).
- §6. Конфигурация после правки:

  ```
  tiers.steward-arch = {model:@gpt-sol, fallback:@gpt-astra}
  roles.architecture-steward = steward-arch
  routing: «приём находок и обзор архитектуры после done этапа и блокирующей находки» → architecture-steward
  roles.critic = apex-sol → tiers.apex-sol.model = @glm   (не тронут)
  tiers.plan                                              (не тронут)
  models.gpt-sol = openai-codex/gpt-6.1-sol               (owner 7bb0ed8d 11:34; дифф 186 models не трогает)
  ```

  `.omp/agents/architecture-steward.md` несёт `model: ["@steward-arch"]`. В `.omp/config.yml` добавлена только строка `steward-arch`. Timer `Unit=orch-peak@architecture.service`, шаблон `ExecStart=/usr/local/sbin/orch-peak %i`.
- Станция. В `orch-peak` три новых arm: `architecture-done`, `architecture-blocker`, `architecture`. Сообщения «НЕ слово владельца». `install.sh` получил `UNITS="$UNITS orch-architecture.timer"`, `enable --now`, счёт 10/10. README и роль оркестратора — потребители сигнала. Роль оркестратора не требует checkout head перед дверью (Б-1).

## 3. Батарея и регресс — сырой вывод, своя мера

На OBJECT:

```
$ bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo . | awk '/^186 /{n++} / ok: /{ok++} /KRASNO/{k++} END{…}'
lines186=61 ok=61 KRASNO=0
$ … --repo . ; echo rc=$?            → rc=0   (61 строка: 21 обязанность/маршрут/сигнал + 35 door + 5 pin)
$ … --model ; echo model rc=$?       → model rc=0
$ … --stabs ; echo stabs rc=$?       → stabs rc=0
$ … --stabs | awk '…'
caught=69 ZHIV=0 STAB=30 door=35 pin=4
```

Счёт клеток двери, своей мерой — разбор AST `door_probe.py`:

```
2f8e06fd CASES 11
2f8e06fd MUTATIONS 11
61b2b2bf CASES 35
61b2b2bf MUTATIONS 35
```

Прирост +24 = шесть входов адверсария v1 + 18 соседей. Это сходится с заявленным.

На дереве PR (9209e817):

```
$ reslop t -- npm run check:ceilings → ok: true, passed: 3, failed: 0; «потолки в порядке»; exit: 0
$ reslop t -- npm run check:gen      → exit: 0
$ bash fixtures/_krasnye_074.sh      → «итог 074: красных клеток=0 стабы=7/7» rc=0
$ bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md → provodka rc=0
  красный контроль на origin/main: «проводка: role-файл не существует: roles/architecture-steward.md» rc=1
$ bash scripts/gen_ci_steps.sh --check --root . → rc=0
$ bash scripts/merge_architecture_pr.sh   → «использование: merge_architecture_pr.sh <корень-CompliorOS-architecture> <номер-PR>» rc=2
$ bash scripts/check_architecture_pin.sh  → «использование: check_architecture_pin.sh …» rc=2
$ bash fixtures/_krasnye_080.sh (PR)   → «стаб-пак: 8/9 поймано, диффпроба 9/9 … честные=31/31» rc=1; «клетка стаб-s1: stab_rc=0 clean_rc=0 (ожидалось РАЗЛИЧИЕ)»
$ bash fixtures/_krasnye_080.sh (main) → тот же вывод, rc=1   → не регрессия
```

Красный контроль батареи 186 на `origin/main`, где реализации нет: `ok=0 KRASNO=37 rc=1`.

**Б-2. Батарея 074: к5 — тавтология.**

Фрагмент: `fixtures/ops_server/red_server_obvjazka_074.sh:143-153`. Пины считаются как `PIN[rel]=hash_of "$OPS_SRC/$rel"` с `OPS_SRC=$REPO_ROOT/ops/server`, а по умолчанию `OPS_ROOT=$REPO_ROOT`. В итоге `cell_k5` сравнивает файл с его же хэшем.

Обязательство — `frozen/contracts/074/2`:
- инв. 1: «равны пинам sha256 (клетка к5) … расхождение с пинами = красное (дрейф станции — слово владельца, не молчаливая правка пинов)»;
- «Пины фиксированы (сняты со станции)»;
- «пересъём и новая пачка пинов, не молчаливая правка (правило: порог не ослабляется ради собственного результата)».

Вход: в `ops/server/root/orch-peak` дописана одна строка без пересъёма станции. Зонд: `scratch/k5_tautology.sh`.

```
== origin/main: _krasnye_074 rc=1
k5: ops/server/root/orch-peak разошёлся с пином станции
  КРАСНО: cell_k5
итог 074: красных клеток=1 стабы=7/7
== 61b2b2bf8cdde8199cd2b7ea23650ea83beea20a: _krasnye_074 rc=0
итог 074: красных клеток=0 стабы=7/7
```

Стоячая санкция №4 (`03ca150d:HANDOFF.md`) разрешает «только значения и строки снимков, клетки и логика побайтно неизменны». Коммит f50c17e2 переписал к2/к3/к5/к5b и симуляцию, а строки `РАЗРЕШИЛ-ВЛАДЕЛЕЦ` не несёт.

Инвентарь из `install.sh` (`units_of`) годится. Неприемлема замена фиксированных пинов живым хэшем. Более простая форма проходит те же строки приёмки:
- фиксированная таблица PIN;
- новые значения для `root/orch-peak` и `root/systemd/orch-architecture.timer` — по санкции №4, если она ещё действует; иначе по слову владельца;
- биекция «ключи PIN == адресаты инвентаря».

## 4. Неподгонка и красное против реализации

Мутанты IMPLEMENTATION, а не toy. Каждый собран в `--shared`-клоне OBJECT и прогнан `--repo .`:

```
MUT status_always_ok:    battery rc=1 KRASNO=1  186 status_cli KRASNO: просрочка без именованной строки и rc 1
MUT review_worktree:     battery rc=1 KRASNO=1  186 review_file KRASNO: непереданный в PR файл выдаётся за коммит обзора
MUT door_bytewise_login: battery rc=1 KRASNO=1  186 door author_casefold KRASNO: rc=0 output=СЛИТО: …
MUT door_no_l3:          battery rc=1 KRASNO=1  186 door l3_without_owner KRASNO: rc=1 output=L2_OWNER_APPROVAL_REQUIRED
MUT door_no_paginate:    battery rc=1 KRASNO=1  186 door paginated_red_run KRASNO: rc=0 output=СЛИТО: …
MUT pin_arch_head:       battery rc=1 KRASNO=1  186 pin pin_arch_head KRASNO: rc=0 output=ПИН ВЕРЕН: …
```

- **`door_control.py` против реализации.** Toy написан независимо: другой разбор страниц (построчный `json.loads` против потока `raw_decode`), литералы `critic` и `zai/glm-5.3`, собственный отказ `CI_FOREIGN_ARCHITECTURE_APP`. Это не копия. Но toy структурно изоморфен двери и унаследовал её слепую зону по checkout (Б-1).
- **Tier-ассерт в `probe.py` (d922d9e1).** Проверяется, что `tier.model == '@gpt-sol'` и что alias разворачивается из `models` того же файла. Литерала версии нет, и слово владельца 11:34 (`gpt-sol = gpt-6.1-sol`) не нарушено.
- **`--repo` не подменяет реализацию.** `honest()` вызывается только в `--model` и `--stabs` (`probe.py:478-492`).

## 5. CI (PR #803, head 9209e817)

```
$ gh pr view 803 --json headRefOid,state → {"headRefOid":"9209e817fa9b71275073fab58b47231c62187fd3","state":"OPEN",…}
$ gh pr checks 803 --repo a3ka/dev-harness ; echo checks rc=$?
antiplacebo ap1..ap5 pass · ci l1..l7 pass · klass pass · legkij pass · obshchij pass · tyazhelyj-itog pass · vorota skipping
checks rc=0          (fail: 0, pending: 0)
$ git diff origin/main..origin/wip/186/orchestrator --stat -- registry .github
 .github/workflows/ci.yml | 12 ++++++------
 registry/ci-steps.tsv    |  1 +
 registry/ci-zamery.tsv   |  1 +
```

В `registry/ci-steps.tsv:307` добавлен шаг:

```
check:hranitel-arhitektury-186-family-selftest	10	… red_architecture_186.sh --repo . && … --stabs && { merge_architecture_pr.sh; [ $? -eq 2 ]; } && { check_architecture_pin.sh; [ $? -eq 2 ]; }
```

В `ci-zamery.tsv` — одна строка `…186…	10	8	0`. В `ci.yml` меняется только сгенерированный блок 083, ключи перераспределены по полосам. Своя мера по множеству ключей:

```
до 150 ключей, после 151; разность = {check:hranitel-arhitektury-186-family-selftest}; вне keys: строк нет
```

Чужие шаги не тронуты. `--model` в шаге нет → С-3.

## Советы (не блокируют) и наблюдения

- **С-1 (implementer).** `findings_status.py:79-81` читает статус из рабочего дерева. Незакоммиченная правка снимает просрочку:

  ```
  ПРОСРОЧЕНО: governance/findings/old.md
  committed-open rc=1
  uncommitted-status rc=0
  Статус:              ← в HEAD статус пуст
  ```

- **С-2 (implementer).** `merge_architecture_pr.sh:54`: `ARCH_CRITIC_MODEL:-zai/glm-5.3` — литерал версии в дубль к `config/agent_models.json`. Смена версии GLM закроет дверь на всех законных accept (fail-closed). Env `ARCH_CRITIC_MODEL` и `ARCH_CRITIC_LOGINS` не читает ни одна строка приёмки.
- **С-3 (orchestrator).** CI-шаг без `--model`. Контракт перечисляет `--model`, `--stabs`, `--repo .`. У `--stabs` (`ok = not ok and rc != 2`) без `--model` нет положительного контроля честного toy.
- **Н-1.** a9253a4c (080) — вне зоны 186/1, внутри 080/4. Батарею не ослабляет (`sandbox_install` и presence-гард). 080 rc 1 одинаков ДО и ПОСЛЕ, стаб s1.
- **Н-2.** Якорь пробы «до назначения мейнтейнер — владелец» в роли хранителя устарел после слова владельца ~20:26.
- **Н-3.** `pulls/N/reviews` читается без `--paginate`: больше 30 review → отказ fail-closed.

## Паразитная сложность (050)

Ответы на пять вопросов (1)–(5) по каждому новому или раздутому артефакту:

- **`roles/architecture-steward.md`** и генерат `.omp/agents/architecture-steward.md`, `.omp/config.yml`.
  - (1) §Предмет 1–6, ПРОВОДКА role.
  - (2) состояния не вводят.
  - (3) роль + генерат: 2 файла, генерацию проверяет `check:gen`.
  - (4) текст.
  - (5) потребители: провод 038 и клетки role/LINES.
  - Итог: **ESSENTIAL**.
- **Тир и маршрут в `config/agent_models.json`.**
  - (1) §6.
  - (2) явное в конфиге.
  - (3) конфиг + генерат.
  - (4) —
  - (5) клетки tier/fallback/routing.
  - Итог: **ESSENTIAL**.
- **`findings_status.py`** (90 строк).
  - (1) §1.
  - (2) только чтение; состояние статуса — рабочее дерево, побочно (С-1).
  - (3) 1 файл.
  - (4) 2 аргумента, rc 0/1/2.
  - (5) клетка status_cli.
  - Итог: **ESSENTIAL**.
- **`architecture_review.py`** (53 строки).
  - (1) §2.
  - (2) нет.
  - (3) 1.
  - (4) 3 аргумента, rc 0/1/2.
  - (5) review_file.
  - Итог: **ESSENTIAL**.
- **`merge_architecture_pr.sh`** (230 строк).
  - (1) §4.
  - (2) сам состояния не держит; читает env `ARCH_REPO`, `ARCH_CRITIC_LOGINS`, `ARCH_CRITIC_MODEL`, и потребителя в приёмке ни у одной нет.
  - (3) дверь + toy + probe = 3 файла.
  - (4) 2 аргумента, rc 0/1/2; работа глубокая.
  - (5) door-клетки и CI usage.
  - Итог: **ESSENTIAL**; два env — ACCIDENTAL-совет С-2. Блока по 050 нет: однозначно более простой формы, проходящей приёмку, нет.
- **`check_architecture_pin.sh`** (125 строк).
  - (1) §4а.
  - (2) env `ARCH_REPO`, `PRODUCT_REPO`; по умолчанию константы контракта.
  - (3) 1 + pin_probe.
  - (4) 4 аргумента, rc 0/1/2.
  - (5) pin-клетки и CI usage.
  - Итог: **ESSENTIAL**.
- **Arms `orch-peak`, `orch-architecture.timer`, строка UNITS в `install.sh`, README.**
  - (1) §6 и станционный интерфейс.
  - (2) систем-юнит, явный.
  - (3) 4 файла + батареи 074/080 (выросло).
  - (4) три подкоманды.
  - (5) клетки done/blocker/schedule.
  - Итог: **ESSENTIAL**.
- **Семья door-клеток** (`door_probe.py`, `door_control.py`, +24 и +24) — одним артефактом.
  - (1) §Приёмка (дверь) и FAIL адверсария v1.
  - (2) tmp-миры.
  - (3) 2 файла.
  - (5) `--repo`, `--stabs`.
  - Итог: **ESSENTIAL**.
- **Правка батареи 074 (f50c17e2).**
  - (1) 186 правки батареи 074 не требует. Требуется только синхронизация инвентаря и значений (санкция №4).
  - (2) живой хэш дерева вместо фиксированной константы.
  - (3) снизилось до 0 — пины больше не правятся, ровно поэтому барьер и пропал.
  - Итог: **ACCIDENTAL и ослабление** → Б-2. Фрагмент, утраченное свойство и более простая форма названы выше.
- **Правка батареи 080 (a9253a4c).**
  - (1) рост инвентаря.
  - (2) нет.
  - (3) снизилось.
  - (5) 080.
  - Итог: **ESSENTIAL** (Н-1).
- **CI-шаг 186.**
  - (1) ПРОВОДКА-ЭНФОРСМЕНТ.
  - (5) CI.
  - Итог: **ESSENTIAL** (С-3 про `--model`).

## ПРОВОДКА (038)

- Role-каналы `roles/architecture-steward.md` и `roles/orchestrator.md` существуют, норма-строки дословные: `check_provodka` rc 0, на main rc 1.
- Guard-ы `scripts/merge_architecture_pr.sh` и `scripts/check_architecture_pin.sh` — барьеры именно этого предмета. В CI их подключает шаг 186: usage rc 2 и батарея.
- Поведенческая норма идёт role-каналом.

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` харнесса не объявляет ни документа архитектуры, ни стандарта кода (`grep 'ARCHITECTURE.md|CODING-STANDARDS' AGENTS.md` пуст).

## Итог

**FAIL** по OBJECT 61b2b2bf8cdde8199cd2b7ea23650ea83beea20a и по составу PR #803 (9209e817).

- Б-1 (implementer + architect): дверь обязана сверять checkout проекта с head PR и чистоту дерева до baseline-классификации; батарее нужны соответствующие клетки и мутанты.
- Б-2 (architect, зона 074): к5 батареи 074 вернуть к фиксированным пинам.

Советы С-1…С-3 и наблюдения Н-1…Н-3 слияние не блокируют. Вызов 2/2 — scoped по дельте Б-1/Б-2.
