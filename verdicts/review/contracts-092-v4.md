FAIL — 092 круг 4. Б-11 закрыт: красное на 7fcee777 («неизвестно»), зелёное на 0798b496 («ещё идёт: <имя>», «parse_err»), проверено своим toy-API. Б-9 закрыт только для sha на origin/main. В основном сценарии ci_wait (красная голова PR, ещё не на main) делегат ci_diag падает на своих воротах и печатает «НЕ на origin/main — не запушен, CI по нему не гонялся» вместо шага и причины (И-5). Делегат к тому же обходит шов ORCH_GH_API. Батарея 18/18 и 21/21, rc 0; parity 0; 041 4/4.

# Review 092, круг 4

**Находки (reslop):** `.review/2026-10-11-03.md`. Блокирующий 1 (Б-9, остаток).
Неблокирующих новых 2 (Н-15, Н-16). Закрыт Б-11.

**Судимое:** контракт `frozen/contracts/092/1` → `b6daee0a`. Субъект — `wip/092/implementer` @
`0798b4962cafdc08c7b1185c14afa9d66eab5691`, родитель `7fcee7778d6fa2f02048062f84e07debeb9e06dc`
(его я судил в круге 3). Батарея — `wip/092/architect` @ `15c4cbe2`, `fixtures/orch_state` = `dd83b30f`,
`_krasnye_092.sh` = `7356eb21`, те же деревья, что в кругах 1–3. Отправная точка — сообщение
коммита 0798b496 («Б-9 шаг+причина, Б-11 glob-матч»).

## Процедура

SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/onlyraccoon-092v4`.
Worktree `wt` = `origin/wip/092/implementer`, поверх него `git checkout origin/wip/092/architect --
fixtures/orch_state fixtures/_krasnye_092.sh`. Worktree `wt0` = `7fcee777` (красное «до»). Пробы
лежат вне дерева: `/tmp/dev-harness-verify/onlyraccoon-092v4-probes/`. Toy-API (`stub.py`)
написан мной, не взят у implementer: HTTP-сервер на свободном порту, режим из argv, лог путей
запросов. Режимы: in_progress на каждый запрос, queued, HTML 502, JSON-массив, `check_runs`
строкой, fail.

## 1. Область правки: PASS

```text
$ git diff --stat 7fcee777..0798b496
 scripts/ci_wait.sh | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)
$ git diff --stat 7fcee777 0798b496 -- fixtures contracts roles frozen AGENTS.md registry .github package.json
(пусто)
```

`scripts/ci_wait.sh` входит в ЗОНУ implementer 092.

## 2. Сырой вывод: мой прогон (wt, батарея наложена)

```text
$ bash fixtures/_krasnye_092.sh ; echo rc_krasnye=$?
диффпроба: честный мини-субъект зелён на всех 21 клетках семьи (rc=0)
S1 → red_net_off_local_survives.sh: поймано
… (S2…S17 — поймано, все строки)
S18 → red_pub_done_mismatch_refusal.sh: поймано
стаб-пак 092: 18/18 поймано, диффпроба 21/21
ок red_net_off_local_survives
… (17 red_* + 4 case_* — все «ок»)
ок case_events_idempotent_green
rc_krasnye=0

$ bash scripts/verify_ci_parity.sh
workflow-команд: 12 · скриптов в приёмке: 72 · объявленных исключений: 24 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
rc_parity=0

$ bash fixtures/parsing_hygiene_battery/run_battery.sh orch_state
БАТАРЕЯ orch_state: итог 4/4 классов закрыто
rc_bat=0
```

Счёт своей мерой, другими командами: `find fixtures/orch_state -maxdepth 1 -name 'red_*.sh' | wc -l`
→ 17; `find fixtures/orch_state/green -name 'case_*.sh' | wc -l` → 4; `grep -cE "^    'S[0-9]+': \("
fixtures/orch_state/battery_stubs.sh` → 18. Итого 17 + 4 = 21 и 18 заплаток — совпадает с выводом.

## Живые пробы

### Б-11 и parse_err — свой toy-API (`probes.sh`, интервал 0.2, sha-заглушка `0123…4567`)

```text
##### 7fcee777
=== Б-11 pending: in_progress на каждый запрос, --attempts 3, без --timeout
ci_wait: неизвестно
rc=3 запросов=3
=== Б-11 pending: queued (другой status), --attempts 2
ci_wait: неизвестно
rc=3 запросов=2
=== parse_err: не JSON (HTML 502)
ci_wait: неизвестно
rc=3 запросов=2
=== parse_err: JSON-массив
ci_wait: неизвестно
rc=3 запросов=2
=== parse_err: check_runs — строка
ci_wait: неизвестно
rc=3 запросов=2
##### 0798b496
=== Б-11 pending: in_progress на каждый запрос, --attempts 3, без --timeout
ci_wait: ещё идёт: ci (l7, check:a check:b)
rc=3 запросов=3
=== Б-11 pending: queued (другой status), --attempts 2
ci_wait: ещё идёт: build matrix · shard 3
rc=3 запросов=2
=== Б-11 pending + --timeout 1 (ветка таймаута перебивает MSG)
ci_wait: таймаут
rc=3 запросов=6
=== parse_err: не JSON (HTML 502)
ci_wait: parse_err
rc=3 запросов=2
=== parse_err: JSON-массив
ci_wait: parse_err
rc=3 запросов=2
=== parse_err: check_runs — строка
ci_wait: parse_err
rc=3 запросов=2
=== fail через toy-API, sha не из репо (ci_diag на rc 1)
ci_wait: CI КРАСНЫЙ — check-run «ci (l7, x y)» → failure
ci_diag: коммит не разрешается: 0123456789abcdef0123456789abcdef01234567
rc=1 запросов=1
```

Строки `уже записано` (дедуп wait-start/wait-done) отфильтрованы.

### Б-9 — живой GitHub (токен из окружения, `live.sh`, `live_pr.sh`)

origin/main bb2757e0 (CI completed/failure) — шаг и причина на месте:

```text
--- ci_wait 0798b496 --sha origin/main --attempts 1
ci_wait: CI КРАСНЫЙ — check-run «ci (l7, check:contract-frozen … check:door-b...» → failure
ci_diag: CI КРАСНЫЙ по bb2757e0cdab — check-run «ci (l7, … check:door-b...» → failure
Упавшие шаги:
  ✗ шаг 11: Lane l7
Причина из лога (FAIL/ошибки, последние строки):
(…строки лога…)
  FAIL contracts/094-prinyatie-i-publikatsiya-kandidata.md изменён без новой заморозки: …
##[error]Process completed with exit code 1.
rc=1
--- ci_diag тот же sha
ci_diag: CI КРАСНЫЙ по bb2757e0cdab — … (тот же блок, построчно совпадает с хвостом выше)
rc=1
```

Головы открытых PR. Ни одна не на main; у красных CI действительно завершился:

```text
3645d0c3 на_main=нет total=12 bad=completed/failure
c44a056c на_main=нет total=12 bad=completed/failure,completed/failure
ad3ede5b на_main=нет total=12 bad=completed/failure,completed/failure
0798b496 на_main=нет total=12 bad=completed/failure,in_progress/null,…
15c4cbe2 на_main=нет total=12 bad=completed/failure,…
e289d7a5 на_main=нет total=12 bad=completed/failure,…
--- ci_wait 0798b496 --sha 3645d0c385b88c27bfd7f047cd8febd98eeac7a1 --attempts 1
ci_wait: CI КРАСНЫЙ — check-run «ci (l1, check:charter)» → failure
ci_diag: 3645d0c385b8 НЕ на origin/main — не запушен, CI по нему не гонялся (push/fetch)
rc=1
--- ci_diag тот же sha
ci_diag: 3645d0c385b8 НЕ на origin/main — не запушен, CI по нему не гонялся (push/fetch)
rc=3
```

Шов `ORCH_GH_API` на rc 1 (`seam.sh`). Toy-API отдаёт fail `«ci (l7, x y)»`, sha = origin/main:

```text
ci_wait: CI КРАСНЫЙ — check-run «ci (l7, x y)» → failure
ci_diag: CI КРАСНЫЙ по bb2757e0cdab — check-run «ci (l7, check:contract-frozen …
Упавшие шаги:
  ✗ шаг 11: Lane l7
(…живой лог GitHub…)
rc=1 запросов_к_toy=1
```

ci_diag игнорирует переопределённый эндпоинт: идёт в api.github.com и печатает другой прогон.

## 3. Проверка не переписана под реализацию: PASS

Коммит не касается `fixtures/`, контракта и роли (п. 1). Батарея накладывается с architect в том
же виде (`dd83b30f`/`7356eb21`), что в кругах 1–3.

## 4. Красное предъявлено

- Б-11 (pending и parse_err): PASS. Красное на 7fcee777 («неизвестно»), зелёное на 0798b496,
  проверено своим toy-API на 5 входах.
- Б-9 на main-sha: PASS. В круге 3 на b02952a7 была одна строка, сейчас на bb2757e0 есть шаг
  и причина.
- Б-9 на sha кандидата (не на main): красный и сейчас (выше).
- Батарея по-прежнему проверяет rc, а не текст, поэтому ни Б-9, ни Б-11 ею не ловятся. Это
  пробел критерия, не подгонка.

## 5. Атомарность: PASS

Один коммит `0798b496`, author `implementer <implementer@dev-harness.local>`, родитель
`7fcee777`, заголовок «092 implementer: починка остатков круга 3 (Б-9 шаг+причина, Б-11 glob-матч)».

## 6. Норма не тронута: PASS

`roles/`, `AGENTS.md`, `contracts/`, `frozen/` не тронуты (п. 1).

## 7. Заявленное = сделанное: FAIL (Б-9)

| заявление 0798b496 | моя мера | итог |
|---|---|---|
| Б-11 `pending*)` — ветка достижима | свой toy-API, in_progress/queued: «ещё идёт: <полное имя>», на 7fcee777 «неизвестно» | да |
| Б-11 `parse_err*)` — тот же фикс | HTML 502, JSON-массив, `check_runs` строкой → «parse_err», на 7fcee777 «неизвестно» | да |
| Б-9 rc 1 печатает шаг + причину (И-5) | origin/main — да; красная голова PR 3645d0c3 — «НЕ на origin/main — не запушен» | **только main** |
| «свой rc не перебивает rc 1» | rc 1 во всех трёх rc-1 пробах, в том числе когда ci_diag ответил rc 2/3 | да |
| батарея 18/18 + 21/21 | мой прогон + счёт find/grep | да |

## ПРОВОДКА (038)

Guard-канал не менялся (`check:orch-state-family-selftest` → `bash fixtures/_krasnye_092.sh`,
parity rc 0). Роль-канал по-прежнему за зоной 061 (Н-4).

## Паразитная сложность (050): артефакты диффа 0798b496

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| `pending*)` / `parse_err*)` | И-5 rc 3 различает «ещё идёт» и таймаут; §7 | нет | 1 | интерфейс прежний | проба Б-11; батарея текст не судит | ESSENTIAL |
| вызов `ci_diag.sh "$SHA"` на rc 1 (`:241-243`) | И-5 «rc 1 — шаг + причина, формат ci_diag» | скрытое: второй процесс читает своё дерево (remote, `refs/remotes/origin/main`, `.env`) и зашитый api.github.com, в обход `ORCH_REPO`/`ORCH_GH_API` | 2 (ci_wait + чужой ci_diag вне ЗОНЫ: правка ворот ci_diag теперь меняет поведение ci_wait) | мелкий: делегат с другой областью определения | повтор ci_diag целиком, включая его ворота | свойство ESSENTIAL, форма не проходит основной сценарий → Б-9 |

## Вердикт

**FAIL.** Блокирующий один:

- **Б-9 (остаток)** — И-5 «rc 1 печатает упавший шаг + причину, формат ci_diag». На sha, ещё не
  слитом в origin/main, ci_wait вместо шага и причины печатает ложное «CI по нему не гонялся»
  (живое: голова PR #84 3645d0c3, CI completed/failure). Ожидание CI кандидата — основной
  сценарий ci_wait по роль-норме 092. Тот же делегат обходит шов `ORCH_GH_API`: при подменном
  эндпоинте в отчёт попадает другой прогон. Форму «вызвать ci_diag», которую я предложил в v3,
  я не сверил с воротами ci_diag:53-57 — это ошибка круга 3, моя. Простая форма в ЗОНЕ:
  id check-run уже разобран → `GET $ORCH_GH_API/repos/<slug>/actions/jobs/<id>` (шаги
  `conclusion=="failure"`) и `…/jobs/<id>/logs` (фильтр ci_diag:89-90), печать в формате
  ci_diag:79-92, без ворот по origin/main.

Маршрут — implementer через оркестратора по норме 050 (`.review/2026-10-11-03.md`, `partial` →
`done`). Это продолжение итеративного цикла (Н-38): спора и арбитражного тупика нет.

Закрыт: **Б-11** (pending и parse_err, красное на 7fcee777).

### Неблокирующие советы v1…v4: класс и влияние на done

| № | суть | класс | блокирует done? |
|---|---|---|---|
| Н-1 | `--sha` без значения / `--interval 0` → rc 2 | implementer | нет — закрыт (v2) |
| Н-2 | HTTP-код через побочный файл | implementer | нет — закрыт (v2) |
| Н-3 | батарея только на ветке architect; ленд — сборкой обеих | оркестратор (ленд) | нет — условие ленда |
| Н-4 | роль-канал roles/orchestrator.md не подключён | оркестратор / зона 061 | нет — условие ПРОВОДКИ вне субъекта |
| Н-5 | 15/17 в тексте против 17/18 в батарее | оркестратор (done) | нет — счёт брать из вывода |
| Н-6 | дубли «ок» в сыром выводе adversary v1 | adversary | нет — гигиена свидетельства |
| Н-7 | пустой коммит ec102c5d в истории | implementer | нет — шум |
| Н-8 | не-200 разбирается как total_count 0 → rc 3 вместо 2 | implementer | нет — совет |
| Н-9 | отказ checkpoint → rc 1 («красный») | implementer | нет — совет |
| Н-10 | traceback при нечитаемом журнале; хрупкий `read_events_bytes` | implementer | нет — совет |
| Н-11 | 3 копии slug/token/ORCH_REPO | implementer | нет — простая форма вне ЗОНЫ |
| Н-12 | printf без аргумента; `000000` | implementer | нет — мелочь |
| Н-13 | `float()` шире `sleep` (`inf`, `1_0`) | implementer | нет — совет |
| Н-14 | имя check-run средним полем TAB-протокола | implementer | нет — экзотика |
| Н-15 | двойная строка «CI КРАСНЫЙ» на rc 1 | implementer | нет — уйдёт с починкой Б-9 |
| Н-16 | CI самого PR #80 красный (l3/l4/l7, ap2…ap5) | оркестратор | нет — к сведению; [INFERENCE] Н-3 + красный main |

Ни одна Н-находка done не блокирует. Done блокирует только Б-9.
