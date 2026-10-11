accept

# Review 092, круг 6: блокер Б-9c закрыт, принято

Б-9c закрыт. При rc 1 и непустом JOBID ci_wait делает третий запрос через тот же шов ORCH_GH_API —
`…/actions/jobs/<id>/logs` — и печатает причину. Её вывод побайтово совпадает с ci_diag.sh:85-93
на main. Если лог не отдан, печатается дословно заглушка ci_diag:92. Если rc≠1 или JOBID пуст,
блок не исполняется. Дифф круга — один коммит, один файл. Батарея 18/18 и 21/21, rc 0. Parity rc 0.

**Находки (reslop):** `.review/2026-10-11-05.md` (`status: ready`). Блокирующих нет. Новые
неблокирующие: Н-19 (совет) и Н-20 (к сведению). Н-18 осталась открытой.

**Что судилось.** Контракт: тег `frozen/contracts/092/1` → `b6daee0a`, блоб
`contracts/092-vozobnovlyaemoe-sostoyanie-zadachi.md` = `f9b2704d`. Субъект: `wip/092/implementer`
@ `67ba6a26ad6cb1710acba6fe298dbd2291f12662`, родитель `56ff7dacb249b0a60bb9c34bf696fe6dd1b6b35b`
(его судил круг 5). Блоб `scripts/ci_wait.sh` = `ab1a69db`. Батарея: `wip/092/architect` @
`15c4cbe2`, `fixtures/orch_state` = `dd83b30f`, `_krasnye_092.sh` = `7356eb21` — те же, что в
кругах 1–5. Принятие относится только к этим блобам. Новая редакция `scripts/ci_wait.sh` его не
наследует.

Предмет круга — только Б-9c. Б-1…Б-11 и Н-* закрыты в кругах 1–5, Б-9a, Б-9b и Н-15 — в круге 5.
Здесь они не пересуживаются: дельта 56ff7dac..67ba6a26 их не трогает (п. 1).

## Процедура

Клонировал по SSH `ssh://git@github.com/a3ka/dev-harness.git` в
`/tmp/dev-harness-verify/reviewer092r6-k7q31`. Worktree `wt` = 67ba6a26, поверх него
`git checkout origin/wip/092/architect -- fixtures/orch_state fixtures/_krasnye_092.sh`. Worktree
`wt0` = 56ff7dac, это «до». Пробы лежат вне дерева: `…/reviewer092r6-k7q31-probes/`. Toy-API
(`stub.py`) я написал сам. Его режимы: `fail`, `fail_logs403`, `fail_logs404`, `fail_logsempty`,
`fail_jobs500`, `fail_both`, `fail_noid`, `ok`, `pending`. Каждый запрос мок пишет в лог путей.
Во всех пробах с моком задано `HTTPS_PROXY=http://127.0.0.1:9`, так что живой api.github.com
недостижим. `ORCH_STATE_DIR` указывает в каталог проб.

## 1. Область правки: PASS

```text
$ git diff --stat 56ff7dacb249b0a60bb9c34bf696fe6dd1b6b35b 67ba6a26ad6cb1710acba6fe298dbd2291f12662
 scripts/ci_wait.sh | 13 +++++++++++++
 1 file changed, 13 insertions(+)
```

Все 13 строк добавлены (`:282-294`), ни одна существующая строка не изменена. `scripts/ci_wait.sh`
входит в ЗОНУ implementer 092.

## 2. Сырой вывод (мой прогон)

### Мок через шов ORCH_GH_API (`seam.sh`; `wt` — субъект, `wt0` — «до»)

```text
=== tree=wt mode=fail ORCH_GH_API=http://127.0.0.1:38601
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
Упавшие шаги:
  ✗ шаг 7: TOY-STEP seam alpha
  ✗ шаг 9: TOY-STEP seam beta
Причина из лога (FAIL/ошибки, последние строки):
  FAIL TOY-REASON коммит вне зоны: seam-probe
some Error: TOY broken pipe
TOY расхождение parity 3
cat: x: No such file or directory
##[error]Process completed with exit code 1.
rc=1
запросы к toy-API:
  /repos/a3ka/dev-harness/commits/ad3ede5b…/check-runs?per_page=100
  /repos/a3ka/dev-harness/actions/jobs/777001
  /repos/a3ka/dev-harness/actions/jobs/777001/logs
=== tree=wt mode=fail_logs403 | fail_logs404 | fail_logsempty   (вывод одинаков)
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
Упавшие шаги:
  ✗ шаг 7: TOY-STEP seam alpha
  ✗ шаг 9: TOY-STEP seam beta
(лог джоба не отдан — токену нужен scope actions:read; упавшие шаги выше уже называют место)
rc=1      (в логе мока те же три пути)
=== tree=wt mode=fail_jobs500
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
Причина из лога (FAIL/ошибки, последние строки):
  … (те же 5 строк) …
rc=1      (три пути)
=== tree=wt mode=fail_noid
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
rc=1      (в логе мока только check-runs)
=== tree=wt mode=ok        rc=0   (только check-runs)
=== tree=wt mode=pending   ci_wait: ещё идёт: ci (l9, TOY)   rc=3   (только check-runs)
=== tree=wt0 mode=fail / fail_logs* : шаги без причины и без заглушки, rc=1, в логе мока 2 пути (нет /logs)
```

В stub-логе есть строки, которые фильтр обязан отбросить: `##[group]…`, `ok  check:zones`,
`  ok   cell-1 passes` и «плоская строка без маркера». Все четыре отброшены.

### rc≠1 через сеть (`fmt.sh`)

```text
$ ORCH_GH_API=http://127.0.0.1:9 bash wt/scripts/ci_wait.sh --sha ad3ede5b… --attempts 1
ci_wait: нечем проверить: сеть
rc=2
```

Ни «Причины», ни заглушки нет.

### jobs 500 + logs 404 вместе (`both.sh`, Н-19)

```text
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
(лог джоба не отдан — токену нужен scope actions:read; упавшие шаги выше уже называют место)
rc=1
```

### Побайтовая сверка с ci_diag.sh:85-93 на origin/main (`fmt.sh`)

Строки 85-93 из `git show origin/main:scripts/ci_diag.sh` исполнялись как есть. `curl` был
подменён шимом, который отдаёт то же тело лога, что и мок.

```text
--- diff ci_diag:85-93 (main) vs ci_wait@67ba6a26, режим fail:
diff_rc=0
cmp_rc=0
6                                   (строк вывода: заголовок + 5)
--- diff заглушки ci_diag:92 vs ci_wait (logs404):
diff_rc=0
--- diff фильтр/печать ci_diag:87-93 vs ci_wait:288-294 (снят ведущий отступ, $log→$LOG_OUT):
diff_rc=0
```

### Живой GitHub (`live.sh`, токен из `.env` основного репо; эти sha не в origin/main)

```text
ad3ede5b… не предок origin/main
##### wt --sha ad3ede5b…   (PR #81)
ci_wait: CI КРАСНЫЙ — check-run «ci (l3, …» → failure
Упавшие шаги:
  ✗ шаг 11: Lane l3
Причина из лога (FAIL/ошибки, последние строки):
(node:2151) [DEP0169] DeprecationWarning: … prone to errors …
workflow-команд: 12 · … · расхождений: 0
  FAIL строка ЗОНА вне объявленной грамматики в contracts/055-… — … не назван ни один путь
  FAIL коммит вне зоны: orchestrator 8f1c25f0 registry/contracts.tsv — дверь минта 031: … (×21)
##[error]Process completed with exit code 1.
rc=1
##### wt0 --sha ad3ede5b…   → только «✗ шаг 11: Lane l3», rc=1
4f6a0a8c… не предок origin/main
##### wt --sha 4f6a0a8c…   (PR #66)
  ✗ шаг 20: Сам-тесты батареи 083 (генератор + исполнение + инкрементальность)
Причина из лога (FAIL/ошибки, последние строки):
  FAIL коммит вне зоны: orchestrator 9bee0e5e / 8ce382ae registry/contracts.tsv — … (×23)
083-батарея: ok=105 FAIL=2 (до реализации части Г и И красны по умыслу)
##[error]Process completed with exit code 1.
rc=1
##### wt0 --sha 4f6a0a8c…   → только шаг, rc=1
```

Посчитал строки причины своей мерой. #81: 1 + 1 + 1 + 21 + 1 = 25. #66: 23 + 1 + 1 = 25. Обе равны
`tail -25`, обрезка работает. В пробе #81 v5 называл причину «дверь минта 031» — она
напечатана.

### Батарея и parity (wt + наложенная батарея architect)

```text
$ bash fixtures/_krasnye_092.sh 2>&1 | grep -vE '^ок '; echo rc_krasnye=${PIPESTATUS[0]}
диффпроба: честный мини-субъект зелён на всех 21 клетках семьи (rc=0)
S1 → red_net_off_local_survives.sh: поймано
… (S2…S17 — каждая строка «поймано»)
S18 → red_pub_done_mismatch_refusal.sh: поймано
стаб-пак 092: 18/18 поймано, диффпроба 21/21
rc_krasnye=0
$ bash scripts/verify_ci_parity.sh 2>&1 | tail -1
workflow-команд: 12 · скриптов в приёмке: 72 · объявленных исключений: 24 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
rc_parity=0
```

Пересчитал своей мерой, другими командами: `grep -cE '^ок '` по выводу батареи даёт 21;
`find fixtures/orch_state -maxdepth 1 -name 'red_*.sh' | wc -l` даёт 17;
`find fixtures/orch_state/green -name 'case_*.sh' | wc -l` даёт 4;
`grep -cE "^    'S[0-9]+': \(" fixtures/orch_state/battery_stubs.sh` даёт 18. Итого 17 + 4 = 21
клетка и 18 заплаток, совпадает с выводом батареи.

## 3. Проверку под реализацию не переписывали: PASS

`fixtures/`, контракт и роль коммит не трогает (п. 1). Батарея наложена с architect в тех же
блобах, что в кругах 1–5.

## 4. Красное предъявлено: PASS

На 56ff7dac (`wt0`) причины нет ни в моке `fail`, ни на живых #81 и #66, и запроса `/logs` в логе
мока тоже нет. На 67ba6a26 на тех же входах причина есть. Батарея судит rc, а не текст stderr,
поэтому Б-9c ею не ловится. Это пробел критерия, а не подгонка — так же было в кругах 3–5.
Красное/зелёное здесь — пары проб `wt0`/`wt`.

## 5. Атомарность: PASS

Один коммит `67ba6a26`, автор `implementer <implementer@dev-harness.local>`, родитель `56ff7dac`.
Заголовок: «092 implementer: Б-9c — третий запрос .../logs через ORCH_GH_API, причина из лога
(формат ci_diag:85-92)».

## 6. Норма не тронута: PASS

`roles/`, `AGENTS.md`, `contracts/`, `frozen/` не тронуты (п. 1).

## 7. Заявленное = сделанное: PASS

| заявление 67ba6a26 | моя мера | итог |
|---|---|---|
| третий запрос `…/jobs/<id>/logs` | лог мока: третий путь `/actions/jobs/777001/logs` | да |
| через ORCH_GH_API | мок на 127.0.0.1, живой GitHub закрыт прокси, причина взята из тела мока (`TOY-REASON`) | да |
| формат ci_diag:85-92 | `cmp` вывода ci_diag:85-93 (main) против ci_wait на одном теле лога — rc 0; заглушка — `diff` rc 0 | да |
| заглушка при отсутствии лога | 403, 404, пустое тело 200, jobs 500 + logs 404 — во всех случаях заглушка, rc 1 | да |
| rc 1 не перебивается | rc 1 во всех режимах с отказом | да |

## Семантический суд (027)

- **ID:** И-5 (контракт 092, строка 71): «rc 0/1/2/3 (1 печатает упавший шаг + причину, формат
  ci_diag)». Р6 (строка 60): «1 красный (упавший шаг + причина)».
- **Фрагмент:** `scripts/ci_wait.sh:282-294` @ `ab1a69db`. `:286` — путь через шов, `:287` — `curl
  -fsSL -m 40` с `AUTH_HDR`, `:288-291` — заголовок, фильтр и `tail -25`, `:292-293` — заглушка.
  Гард — `:261` (`[ "$RC" = 1 ] && [ -n "$JOBID" ]`).
- **Источник:** `scripts/ci_diag.sh:85-92` на origin/main 501b82f4.
- **Сверка:** текст строк фильтра и печати совпадает, если снять отступ и заменить `$log` на
  `$LOG_OUT` (`diff` rc 0). Совпадают regex `grep -aE`, исключение `grep -avE '^\S+…ok…'`, `sed -E`
  срезки метки времени и `tail -25`. Совпадает и вывод на одном теле лога (`cmp` rc 0).
  Расходятся только URL (`${ORCH_GH_API}` вместо зашитого `https://api.github.com`, как требует
  шов) и заголовок авторизации (`AUTH_HDR`, пуст без токена, вместо безусловного Bearer). Оба
  расхождения — требование шва и прецедент ci_wait, к печати они не относятся.
- **Противоречие:** нет. И-5 выполнен: печатаются упавший шаг и причина в формате ci_diag.

## ПРОВОДКА (038)

Guard-канал не менялся: `check:orch-state-family-selftest` → `bash fixtures/_krasnye_092.sh`,
parity rc 0. Роль-канал по-прежнему за зоной 061 (Н-4, перенесена).

## Паразитная сложность (050): артефакт диффа 67ba6a26

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| блок третьего запроса `…/logs` (`:282-294`) | И-5 «шаг + причина, формат ci_diag» | новых env и флагов нет, шов прежний (`ORCH_GH_API`, `REPO_SLUG`, `JOBID`). `LOG_OUT` — локальная переменная, временного файла нет, всё видно в stderr | 1 (`ci_wait.sh`). При смене формата причины меняется и ci_diag.sh — так было и до диффа, число не выросло | интерфейс не вырос (аргументы, rc, env прежние), функциональность выросла на печать причины, модуль стал глубже | строки приёмки И-5/Р6 и живые пробы. Повторяет 6 строк ci_diag:87-92. Это допустимо: ci_diag вне ЗОНЫ, у него свои ворота origin/main (Б-9a), а делегат уже был отвергнут в круге 3. Простейшей формы, которая проходит И-5 и не требует правки чужого файла, нет | ESSENTIAL |

## Вердикт

**accept.** Б-9c закрыт, блокирующих находок нет.

| № | суть | класс | блокирует? |
|---|---|---|---|
| Б-9c | причина из лога при rc 1 (И-5) | implementer | закрыт (67ba6a26) |
| Н-17 | диагностика при неудаче jobs-запроса | implementer | закрыт частично: jobs 500 → причина или заглушка; без JOBID молчит, как ci_diag — совет |
| Н-18 | опечатка `ORCH_G_API` в комментарии `:257` | implementer | нет — мелочь |
| Н-19 | заглушка «шаги выше» печатается, даже когда шагов выше нет (jobs 500 + logs 404) | implementer | нет — текст дословно из ci_diag:92, это требуемый формат |
| Н-20 | фильтр ci_diag пропускает шум (`DeprecationWarning … errors`) | оркестратор, к сведению | нет — свойство источника формата |
| Н-3 | батарея лежит только на ветке architect | оркестратор (ленд) | нет — условие ленда: собрать вместе с `wip/092/architect` |
| Н-4 | роль-канал roles/orchestrator.md не подключён | оркестратор / зона 061 | нет |
| Н-5, Н-6, Н-7…Н-14, Н-16 | перенесены из кругов 2–5 | см. v5 | нет |

Маршрут: оркестратор. Ленд — объединением `wip/092/implementer` @ 67ba6a26 и `wip/092/architect` @
15c4cbe2 (Н-3). `.review/2026-10-11-04.md` (Б-9c) → `done`. Неблокирующие лежат в
`.review/2026-10-11-05.md`.
