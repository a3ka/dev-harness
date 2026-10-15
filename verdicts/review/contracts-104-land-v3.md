FAIL

# Review PR#97 `wip/104/implementer2`, контракт 104 «узкий доверенный гейт судьи» (land-v3, круг 3, фокус: топология)

Находки с чекбоксами — в `.review/2026-10-15-09.md` (prev: `.review/2026-10-15-07.md`). Вердикт круга 2:
`verdicts/review/contracts-104-land-v2.md` (FAIL: Рв97-12, Рв97-13).

МОДЕЛЬ судьи: `anthropic/claude-opus-5-5` (reviewer, тир audit).

**Субъект.** PR#97, голова `b442d7ac10b1bae6e9d0611065a327458ba2e4ea`, OPEN, `mergeable: MERGEABLE`,
`mergeStateStatus: UNSTABLE`. Merge-base с origin/main (`8c3f34ca`) — `b2589a34`. Позади main на 3 коммита
оркестратора (HANDOFF, два форка n283), конфликтов нет.

```
$ git log --format='%h P:%p A:%an %s' --first-parent origin/main..b442d7ac
b442d7ac P:821127c2 b2589a34 A:orchestrator 104 orchestrator: sync-merge latest origin/main …
821127c2 P:a4fab6fa 868d386f A:orchestrator 104 orchestrator: sync-merge latest origin/main …
a4fab6fa P:4790d0da          A:orchestrator 104 orchestrator: sync-merge origin/main (Н-287-топология) …   ← ОДИН родитель
4790d0da P:8cd920aa          A:orchestrator 104: nudge CI …
8cd920aa P:4117f3d4          A:architect    104 architect: А-917 …
4117f3d4 P:355653fe          A:architect    104 architect: Рв97-3 / A104-1 …
355653fe P:e906e707          A:orchestrator 104 orchestrator: честная identity …
e906e707 P:59f26b53          A:implementer  104 implementer: потолок персоны orchestrator …
59f26b53 P:ed837823          A:implementer  104 implementer: узкий доверенный гейт судьи …
ed837823 P:452f682b          A:architect    104: fixtures/zashchita_main_104 …
452f682b P:60d82e94          A:architect    104: точечный перенос contracts/104-*.md …   ← коммит тега frozen/contracts/104/1
```

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/rev104r3-22766/repo`. Worktree: `../tip` (b442d7ac),
`../mainwt` (origin/main), `../sim-r3`, `../sim-alt`. Скрипты: `../sim_registry.sh` (ленд `merge --no-ff` в origin/main,
затем замена `104 → 73a85203…` коммитом `orchestrator freeze: registry 104 → …`, затем полный `check_zones.sh`)
и `../alt_topo.sh` (альтернативная топология, см. §3). Основной чекаут я не трогал, push не делал.

## Содержание не изменилось с круга 2

`git patch-id --stable` (круг 2 → круг 3):
```
8e6ca35a 0a65ac67131a | 452f682b 0a65ac67131a
f98b3683 aaffebaefc40 | ed837823 aaffebaefc40
9e58e5b4 d4ac439e2276 | 59f26b53 d4ac439e2276
0d6b0964 0016d3d4aab7 | e906e707 0016d3d4aab7
be0d6d9e 5b079d719088 | 355653fe 5b079d719088
12e8c5a6 046082d376e9 | 4117f3d4 046082d376e9
b170759e 8f8194d59e2d | 8cd920aa 9ba088820878   (разница — одна пустая строка контекста NABLIUDENIA, следствие базы)
```
Набор файлов `git diff origin/main...b442d7ac` (32 файла) совпадает с набором круга 2 `git diff 2664189b 53f27c96`
(`diff` пуст). Блобы равны всем, кроме `NABLIUDENIA_ARCHITECT.md`: по заголовкам `### А-` прибавилась только запись main А-918.
Блоб контракта на голове равен блобу тега, `e4b1e185`.

## 1. Ancestry к тегу (Рв97-12) — ЗАКРЫТ

```
$ git merge-base --is-ancestor $(git rev-parse 'frozen/contracts/104/1^{commit}') b442d7ac   → rc=0   (тег-коммит 452f682b)
```
Цену круга 2 проверил той же симуляцией, что и тогда (`sim_registry.sh b442d7ac sim-r3`):
```
merge: чисто
-104 → 8f93d58db254d580d3794c3f9fbe0ca9cf2d2d45
+104 → 73a85203c8b4e5241ed943654ee2c07081434b18
предикат check_zones:1167 (тег-коммит предок C) rc=0
```
FAIL-строки на коммите реестровой замены нет. В круге 2 на голове 53f27c96 было
`FAIL коммит вне зоны: orchestrator 001cce85 registry/contracts.tsv — дверь минта 031 …`. Остальные FAIL этого
прогона разобраны в §3.

## 2. PR mergeable (Рв97-13) — ЗАКРЫТ

```
$ gh pr view 97 --json mergeable,mergeStateStatus,headRefOid
{"headRefOid":"b442d7ac…","mergeStateStatus":"UNSTABLE","mergeable":"MERGEABLE"}
$ git merge-tree --write-tree --name-only origin/main origin/wip/104/implementer2   → 7c276023…, rc=0
```
`UNSTABLE` значит, что CI красен. Разбор CI — в §4.

## 3. Строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ для ROADMAP.md в принесённых диапазонах — формально PASS, найдено два дефекта

Уставные пути, изменённые синк-коммитами относительно первого родителя (AGENTS.md, ROADMAP.md, contracts/*, roles/*):
`a4fab6fa: ROADMAP.md`, `821127c2: —`, `b442d7ac: ROADMAP.md`.

| синк | что принёс в ROADMAP.md | строка в теле синка | дословно? |
|---|---|---|---|
| a4fab6fa | 013ab88d (owner), +2 строки, дельта побайтно = 013ab88d | есть | **нет** (Рв97-20) |
| 821127c2 | 013ab88d повторно (второго родителя у a4fab6fa нет), дельта к 1-му родителю пуста | не нужна | — |
| b442d7ac | ac880507 (owner), +1 строка | есть | да (`diff` → rc 0) |

CI l1, шаг `check_charter.sh` на этой голове: `ok … ROADMAP.md в a4fab6fa`, `ok … ROADMAP.md в b442d7ac`,
`ok … ROADMAP.md в b0c39a58`, `ok contracts/104-… — уставной с frozen/contracts/104/1, коммитов в диапазоне 81`,
`уставных документов: 95 · изменений в них: 212 · с разрешения: 212`. Рв97-14 закрыт.

**Рв97-19 — a4fab6fa не merge-коммит.** Задание называет его merge-коммитом, форк n283 п.(3) — «admin merge-коммит».
По факту у него один родитель:
```
$ git rev-list --parents -n1 a4fab6fa | wc -w        → 2   (сам + 4790d0da)
$ git rev-list --parents -n1 821127c2 | wc -w        → 3
$ git log -1 --format='%P' 9ce6e7ba                    → 4790d0da… d9966520…
trees: 9ce6e7ba=52828481… a4fab6fa=52828481…;  тела равны (разница — одна завершающая пустая строка), timestamp 17:14:06 у обоих
```
Был настоящий merge `9ce6e7ba` ветки с main `d9966520` (конфликт NABLIUDENIA_ARCHITECT.md разрешён). На ветку ушла
его копия без второго родителя. Перебор first-parent main показывает, что дерево a4fab6fa ровно равно
`merge-tree 4790d0da d9966520` после разрешения конфликта. Значит, 48 файлов main (+4471/−20: вердикты судей,
`.review/`, HANDOFF, `docs/owner/`, `fixtures/ops_server/`, `ops/server/`, ROADMAP.md) записаны в историю как
собственная правка orchestrator.

Цену измерил своей мерой, полным `check_zones.sh` (не `--incr`):
```
origin/main (голый)        : FAIL 7ed4a89c docs/owner/… ; FAIL 868d386f docs/owner/…                         RC=1
ленд b442d7ac + реестр     : те же два + FAIL a4fab6fa × {ROADMAP.md, docs/owner/2026-10-15-suzhenie-dopuska-pilota.md,
                             fixtures/ops_server/cikl_085/slijanie.orch-peak, fixtures/ops_server/red_cikl_perezapuska_085.sh,
                             fixtures/ops_server/red_server_obvjazka_074.sh, ops/server/root/orch-peak} (каждый ×2)   RC=1
ленд 3aaa445a + реестр     : ровно базовые 7ed4a89c, 868d386f — a4fab6fa-строк 0                                 RC=1
```
`3aaa445a` построен `alt_topo.sh` через `git commit-tree`: те же три синк-коммита, те же деревья, авторы, даты и
тела, но первый с родителями `4790d0da d9966520` («дерево альтернативы == дерево b442d7ac»). Значит, п.(3) форка n283
вызван этой веткой, а не внешним долгом. Ни rescue-пара в check_zones, ни расширение merge-семантики не нужны:
второй родитель сам отдаёт зоны владельцам. Это решение не консультантского уровня, а перестройка трёх коммитов.

**Рв97-20 — «перенесённая» строка владельца не дословна.** Тело a4fab6fa: «Перенос строки владельца из 013ab88dc
(первоисточник) в тело этого merge-коммита». Общий префикс со строкой 013ab88d — 474 символа, до «…после старта;
изоляция ». Дальше:
```
013ab88d (A: owner): …изоляция судьи, два независимых суда, нативный прогон, доказательства и защита main не ослабляются; ориентир старта 19–20.10; слово владельца 2026-10-15.
a4fab6fa (A: orchestrator): …изоляция раннера station-complior до Э8.
$ git grep -n 'station-complior до Э8' b442d7ac      → пусто
$ git log --all -S'station-complior до Э8'             → пусто
$ git log --all --grep='station-complior до Э8'        → a4fab6fa 9ce6e7ba 84688018 (все orchestrator; 84688018 — sync-merge 103)
```
Дельта ROADMAP.md побайтно равна дельте 013ab88d, поэтому по существу разрешение покрыто. Но под меткой
`РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в историю уходит текст, которого владелец не писал. А оговорка владельца «…не ослабляются» в
этой копии потеряна. История не переписывается, поэтому чинить нужно до ленда. Для 103 (`84688018`) — тот же класс,
вне мандата этого вердикта.

## 4. Батарея 104 и CI

`reslop t -- bash fixtures/_krasnye_104.sh` (в `../tip`) → `ok: true, passed: 39, failed: 0`, exit 0. Сырой лог:
```
стаб-пак: 17/17 поймано
ЗЕЛЕНО ×6 (red_huk_alfavit_ustanovki, red_huk_bez_ustanovochnogo_konfiga, red_huk_task_spavna,
           red_judge_gate_svidetelstvo_sudi, red_sud_model_dver_spavna, red_sud_model_materializatsija)
клеток просмотрено: 6
ИТОГ 104: rc=0
```
Своя мера счёта: `progon t104-m` строк — 17, уникальных `t104-m*` — 17, `red_*.sh` — 6.

CI run 38777167169 (headSha b442d7ac, pull_request): antiplacebo ap1–ap5 — pass, ci l1–l7 — fail. Разобрал логи
каждого job (`gh api …/jobs/<id>/logs`):
- l1, l2, l4, l5, l6, l7 — `_krasnye_083.sh`: `FAIL И0б/check_zones … rc=1: incr: check_zones судит 821127c2..b442d7ac`.
  Причина — `FAIL коммит вне зоны: orchestrator 7ed4a89c docs/owner/…`, то есть n283 п.(1)+(2), долг main.
  Шаг charter в l1 зелёный.
- l3 — `check_zones.sh --incr`: `7ed4a89c`, `868d386f` (main) и шесть путей `a4fab6fa` (Рв97-19).
- Строка `FAIL строка ЗОНА вне объявленной грамматики в contracts/055-…` — самотест грамматики, как и в круге 2, к 104 не относится.

FAIL, которые 104 вносит своим содержанием, CI не показывает. FAIL от топологии ветки — только `a4fab6fa`.

## 5. Атомарность / область

Содержательные коммиты прежние, 1:1 по patch-id. Новые коммиты круга — три синка orchestrator, все без 104-содержания:
дифф PR не изменился. Пустой `4790d0da` по-прежнему в ленте (Рв97-18).

## ПРОВОДКА (038)

Не менялась с круга 2: guard `fixtures/_krasnye_104.sh` подключается после ленда (Рв97-7). Role-канал
`roles/orchestrator.md` — blob равен кругу 2.

## Паразитная сложность (050) — артефакты круга 3

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| синк `a4fab6fa` (один родитель) | свежесть к main + разрешение конфликта NABLIUDENIA (Рв97-13) | скрытое: принадлежность 48 файлов main переходит orchestrator, видно только в check_zones | вырос: п.(3) форка n283 предлагает новую rescue-пару или ветвь check_zones | — | CI l3 краснеет | **ACCIDENTAL, блок**: фрагмент — родители a4fab6fa; отсутствующее свойство — принадлежность принесённого второму родителю; более простая форма — тот же коммит с родителем `d9966520` (`9ce6e7ba`, уже существовал), проходит те же строки (ленд-симуляция = база main) |
| синки `821127c2`, `b442d7ac` (настоящие merge) | свежесть к main | явное (2 родителя) | 0 | — | PR MERGEABLE | ESSENTIAL |

## Итог

| находка | класс | блок |
|---|---|---|
| Рв97-12 | ancestry к frozen/contracts/104/1: rc 0; реестровая замена после ленда без FAIL | закрыт [x] |
| Рв97-13 | PR MERGEABLE, merge-tree чист | закрыт [x] |
| Рв97-14 | l1 check:charter зелёный (b0c39a58 — пара 32) | закрыт [x] |
| Рв97-19 | топология: a4fab6fa — копия merge 9ce6e7ba без второго родителя; +6 путей check_zones FAIL после ленда, вызванных веткой; форк n283 п.(3) диагностирует это неверно | **да** |
| Рв97-20 | провенанс слова владельца: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в a4fab6fa не дословна 013ab88d (хвост подменён, оговорка «не ослабляются» потеряна) | **да** |
| Рв97-15 | session/object не первой строки (S1ST) | нет (совет) |
| Рв97-16 | номер А-917 / тело b170759e→8cd920aa | нет |
| Рв97-17 | frozen «13» против живых 17 | нет |
| Рв97-18 | пустой nudge 4790d0da | нет |
| Рв97-7 | ПРОВОДКА после ленда | нет (до done) |
| n283 п.(1)+(2) | 7ed4a89c/868d386f на main красят check_zones и 083-И0б во всех lane | внешний долг, не 104 |

Фокус круга достигнут: Рв97-12 и Рв97-13 закрыты, каждый своей мерой. FAIL ставлю из-за двух новых дефектов
самого исправления. Оба лежат в одном коммите `a4fab6fa` и закрываются одной механической перестройкой: первый синк
записать с родителями `4790d0da d9966520` (как уже было в `9ce6e7ba`) и строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ROADMAP.md`,
скопированной из 013ab88d байт-в-байт; `821127c2` и `b442d7ac` переподвесить на него без изменения деревьев. После
этого нужны свежий CI, сверка patch-id содержательных коммитов и снятие п.(3) из форка n283. Даже тогда PR CI
не позеленеет, пока не снят долг main n283 п.(1)+(2).
