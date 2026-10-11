FAIL — 092, круг 5. Б-9 закрыт в двух частях из трёх. Ворот origin/main и противоречивой строки больше нет: проверено живьём на головах PR #81 и #66. Оба запроса (check-runs и jobs/<id>) идут через шов ORCH_GH_API: это видно в логе моего мока, реальный эндпоинт при пробе был закрыт. Третья часть И-5 не выполнена: «причина» не печатается. ci_wait выводит только шаг. На origin/main блок «Причина из лога», который был на 0798b496, на 56ff7dac пропал. Батарея: 18/18 и 21/21, rc 0. Parity: rc 0.

# Review 092, круг 5 (последний на сессию)

**Находки (reslop):** `.review/2026-10-11-04.md`. Блокирует одна: Б-9c. Новых неблокирующих две:
Н-17 и Н-18. Закрыты Б-9a, Б-9b и Н-15.

**Что судилось.** Контракт `frozen/contracts/092/1` → `b6daee0a`. Субъект: `wip/092/implementer`
@ `56ff7dacb249b0a60bb9c34bf696fe6dd1b6b35b`, родитель `0798b4962cafdc08c7b1185c14afa9d66eab5691`
(его судил круг 4). Блоб `scripts/ci_wait.sh` = `0b8ecf78`. Батарея: `wip/092/architect` @
`15c4cbe2`, `fixtures/orch_state` = `dd83b30f`, `_krasnye_092.sh` = `7356eb21`. Эти блобы те же,
что в кругах 1–4.

## Процедура

Клонировал по SSH `ssh://git@github.com/a3ka/dev-harness.git` в
`/tmp/dev-harness-verify/rev092v5-PreliminaryConstrictor`. Worktree `wt` = `origin/wip/092/implementer`,
поверх него `git checkout origin/wip/092/architect -- fixtures/orch_state fixtures/_krasnye_092.sh`.
Worktree `wt0` = `0798b496`, это состояние «до». Пробы лежат вне дерева:
`…/rev092v5-PreliminaryConstrictor-probes/`. Toy-API (`stub.py`) я написал сам, у implementer не
брал. Режимы: `fail`, `fail_jobs500`, `fail_noid`; лог путей пишется в файл. `ORCH_STATE_DIR`
во всех пробах указывал в каталог проб, так что общее состояние пробы не трогали.

## 1. Область правки: PASS

```text
$ git diff --name-only 0798b496..56ff7dac
scripts/ci_wait.sh
$ git diff --stat 0798b496 56ff7dac -- fixtures contracts roles frozen AGENTS.md registry .github package.json | wc -l
0
```

`scripts/ci_wait.sh` входит в ЗОНУ implementer 092 (контракт, строка 80).

## 2. Сырой вывод (мой прогон, wt с наложенной батареей)

```text
$ bash fixtures/_krasnye_092.sh 2>&1 | grep -vE '^ок '; echo rc_krasnye=${PIPESTATUS[0]}
диффпроба: честный мини-субъект зелён на всех 21 клетках семьи (rc=0)
S1 → red_net_off_local_survives.sh: поймано
… (S2…S17 — каждая строка «поймано»)
S18 → red_pub_done_mismatch_refusal.sh: поймано
стаб-пак 092: 18/18 поймано, диффпроба 21/21
rc_krasnye=0
$ bash fixtures/_krasnye_092.sh 2>&1 | grep -cE '^ок '
21
$ bash scripts/verify_ci_parity.sh | tail -1
workflow-команд: 12 · скриптов в приёмке: 72 · объявленных исключений: 24 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
rc_parity=0
```

Пересчитал своей мерой, другими командами: `find fixtures/orch_state -maxdepth 1 -name 'red_*.sh' | wc -l`
даёт 17, `find fixtures/orch_state/green -name 'case_*.sh' | wc -l` даёт 4,
`grep -cE "^    'S[0-9]+': \(" fixtures/orch_state/battery_stubs.sh` даёт 18. Итого 17 + 4 = 21
клетка и 18 заплаток, совпадает с выводом батареи.

## Живые пробы

### Красные головы PR не на main (не те, что брал implementer: 84/83/79/78)

Перед пробой сверил состояние CI: у ad3ede5b (#81) 2 прогона completed/failure и 10
completed/success; у 4f6a0a8c (#66) 7 completed/failure и 5 completed/success. Оба sha НЕ являются
предками origin/main (`merge-base --is-ancestor` → нет).

```text
--- ci_wait --sha ad3ede5b22a436eecc8bc1a1ba186d6b2df96565 --attempts 1
ci_wait: CI КРАСНЫЙ — check-run «ci (l3, check:zones check:consumers-window-family-selftest check:hooks check:skills check:scoped-...» → failure
Упавшие шаги:
  ✗ шаг 11: Lane l3
rc=1
--- ci_wait --sha 4f6a0a8c9a90cc7428a8bdaf8d8c32765a581ebe --attempts 1
ci_wait: CI КРАСНЫЙ — check-run «ci (l4, check:protected check:document check:merge-gate-family-selftest check:v-polete-nichego-08...» → failure
Упавшие шаги:
  ✗ шаг 20: Сам-тесты батареи 083 (генератор + исполнение + инкрементальность)
rc=1
```

Видны имя, conclusion и шаг. Строки «НЕ на origin/main» нет, противоречивых строк нет (п. 4 задания).
**Причины нет.** Лог той же джобы с тем же токеном отдаётся, и фильтр ci_diag:89-90 даёт:

```text
job=114108454583
  FAIL коммит вне зоны: orchestrator 8f1c25f0 registry/contracts.tsv — дверь минта 031: дельта манифеста не только-добавление …
##[error]Process completed with exit code 1.
```

### Регрессия «причины» на origin/main 8587b82c (CI: 1 completed/failure, 11 success)

```text
##### wt0 (0798b496) --sha 8587b82c…
  ✗ шаг 11: Lane l7
Причина из лога (FAIL/ошибки, последние строки):
…
  FAIL contracts/094-prinyatie-i-publikatsiya-kandidata.md изменён без новой заморозки: на HEAD блоб ee74f92e…
##[error]Process completed with exit code 1.
rc=1
##### wt (56ff7dac) --sha 8587b82c…
ci_wait: CI КРАСНЫЙ — check-run «ci (l7, check:contract-frozen … check:door-b...» → failure
Упавшие шаги:
  ✗ шаг 11: Lane l7
rc=1
```

### Шов ORCH_GH_API, мой мок (`seam.sh`; `HTTPS_PROXY=http://127.0.0.1:9`, реальный api.github.com недостижим)

```text
=== mode=fail sha=ad3ede5b ORCH_GH_API=http://127.0.0.1:38001
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
Упавшие шаги:
  ✗ шаг 7: TOY-STEP seam alpha
  ✗ шаг 9: TOY-STEP seam beta
rc=1
запросы к toy-API:
  /repos/a3ka/dev-harness/commits/ad3ede5b22a436eecc8bc1a1ba186d6b2df96565/check-runs?per_page=100
  /repos/a3ka/dev-harness/actions/jobs/777001
=== mode=fail sha=01234567 (не из репо) — тот же вывод, те же два пути, rc=1
=== mode=fail_jobs500 sha=ad3ede5b / 01234567
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
rc=1   (оба пути в логе мока)
=== mode=fail_noid sha=ad3ede5b / 01234567
ci_wait: CI КРАСНЫЙ — check-run «ci (l9, TOY seam-probe)» → failure
rc=1   (в логе мока только check-runs)
```

Оба запроса прошли через шов, шаги взяты из мока. Пропущенный шаг (`skipped`) отфильтрован, как
и должно быть. Ворот по sha нет. Запроса `/logs` нет ни в одном режиме, хотя мок умеет на него
отвечать.

## 3. Проверку под реализацию не переписывали: PASS

Коммит не трогает `fixtures/`, контракт и роль (п. 1). Батарея наложена с architect в тех же
блобах, что в кругах 1–4.

## 4. Красное предъявлено

- Б-9a (ворота): PASS. Красное было в круге 4 на 0798b496: 3645d0c3 → «НЕ на origin/main». Сейчас
  на 56ff7dac зелёное на двух других не-main головах и на sha вне репо.
- Б-9b (шов): PASS. Красное было в круге 4: ci_diag уходил в живой GitHub. Сейчас оба пути видны в
  логе мока.
- Б-9c (причина): красное на 56ff7dac. На main-sha 0798b496 причину печатал, 56ff7dac — нет.
- Батарея по-прежнему судит rc, а не текст stderr, поэтому Б-9 ею не ловится. Это пробел
  критерия, а не подгонка (как и в кругах 3–4).

## 5. Атомарность: PASS

Один коммит `56ff7dac`, автор `implementer <implementer@dev-harness.local>`, родитель `0798b496`,
заголовок «092 implementer: починка Б-9 (шаг+причина через шов ORCH_GH_API)».

## 6. Норма не тронута: PASS

`roles/`, `AGENTS.md`, `contracts/`, `frozen/` не тронуты (п. 1).

## 7. Заявленное = сделанное: FAIL (Б-9c)

| заявление 56ff7dac | моя мера | итог |
|---|---|---|
| делегат ci_diag убран, ворот origin/main нет | живые #81, #66 и sha вне репо — «НЕ на origin/main» нет | да |
| второй запрос идёт через тот же шов ORCH_GH_API | мой мок: в логе check-runs и jobs/777001, шаги из мока | да |
| формат «Упавшие шаги: ✗ шаг N: имя» (ci_diag:79-83) | вывод совпадает построчно с форматом ci_diag:81-83 | да |
| «шаг+причина» (заголовок коммита, И-5) | причины нет ни на одной пробе; на main она была до коммита | **нет** |
| «свой rc не перебивает rc 1» | rc 1 во всех режимах мока, включая jobs 500 и отсутствие id | да |
| батарея 18/18 + 21/21, parity rc 0 | мой прогон плюс подсчёт find/grep | да |

## Семантический суд (027): ID / фрагмент / источник / противоречие

- **ID:** И-5 (контракт 092, строка 71): «rc 0/1/2/3 (1 печатает упавший шаг + причину, формат
  ci_diag)». Р6 (строка 60): «1 красный (упавший шаг + причина)».
- **Фрагмент:** `scripts/ci_wait.sh:261-282` @ `0b8ecf78`. Блок делает один запрос к
  `/actions/jobs/<id>` и печатает только `conclusion=="failure"`-шаги. Запроса `…/logs` и
  печати причины нет.
- **Источник:** формат ci_diag: `scripts/ci_diag.sh:85-92` на main, заголовок «Причина из лога
  (FAIL/ошибки, последние строки):» + фильтр 89-90, а при отсутствии лога строка-заглушка 92.
  Круги 2–4 этого же суда понимали «причину» именно так (v3 §7, v4 §Б-9).
- **Противоречие:** живая проба ad3ede5b печатает шаг без причины, хотя лог доступен и содержит
  `FAIL коммит вне зоны … дверь минта 031`. На origin/main причина пропала по сравнению с 0798b496.

## ПРОВОДКА (038)

Guard-канал не менялся: `check:orch-state-family-selftest` → `bash fixtures/_krasnye_092.sh`,
parity rc 0. Роль-канал по-прежнему за зоной 061 (Н-4).

## Паразитная сложность (050): артефакты диффа 56ff7dac

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| 4-е поле `cid` в TAB-протоколе python→shell (`:179-187`, `:203`) | И-5 «шаг» требует id джобы | явное: `JOBID`, видно в stdout python | 1 | интерфейс не вырос (флагов/env нет) | живая проба Б-9; повторяет ci_diag:77 (`\(.id)`), но в ЗОНЕ и без чужого кода | ESSENTIAL |
| блок второго запроса `jobs/<id>` (`:261-282`) | И-5 «шаг + причина, формат ci_diag» | временный файл, удаляется; новых env нет, шов прежний | 1 (раньше 2: ci_wait + ci_diag вне ЗОНЫ, теперь меньше) | глубже прежнего делегата: та же область определения, что у ci_wait | повторяет логику ci_diag:81-83 на python вместо jq. Это допустимо: jq в ci_wait не используется, а ci_diag вне ЗОНЫ | ESSENTIAL, но неполно (Б-9c) |

## Вердикт

**FAIL.** Блокирует одна находка:

- **Б-9c** — нарушен И-5: «rc 1 печатает упавший шаг + ПРИЧИНУ, формат ci_diag». ci_wait печатает
  только шаг. Причины из лога нет ни на голове PR (ad3ede5b, лог доступен, причина — `FAIL коммит
  вне зоны … дверь минта 031`), ни на origin/main, где 0798b496 её печатал. Это регрессия. Простая
  форма в ЗОНЕ (её называл ещё v4): третий запрос через тот же шов
  `${ORCH_GH_API}/repos/${REPO_SLUG}/actions/jobs/${JOBID}/logs` (`curl -fsSL`), фильтр
  ci_diag:89-90, печать ci_diag:88-90, а без лога — заглушка ci_diag:92. Это около 8 строк в блоке
  `:261-282`.

Закрыты: **Б-9a** (ворота origin/main и противоречивая строка), **Б-9b** (шов ORCH_GH_API для обоих
запросов), **Н-15** (двойная строка «CI КРАСНЫЙ»). Б-1…Б-8, Б-10 и Б-11 закрыты в кругах 2–4, на
56ff7dac они не тронуты: блоки вне `:128`, `:179-206` и `:246-282` не менялись, батарея зелёная.

Маршрут: implementer через оркестратора по норме 050 (`.review/2026-10-11-04.md`, `partial` →
`done`). Это круг 5 из 5 на сессию. По условию круга 092 остаётся `status: partial` до следующей
сессии или до слова владельца. Итоговый accept для ленда этим вердиктом НЕ выдан.

### Неблокирующие: класс и влияние на done

| № | суть | класс | блокирует done? |
|---|---|---|---|
| Н-3 | батарея только на ветке architect, ленд — сборкой обеих | оркестратор (ленд) | нет — условие ленда |
| Н-4 | роль-канал roles/orchestrator.md не подключён | оркестратор / зона 061 | нет — условие ПРОВОДКИ вне субъекта |
| Н-5 | счёт клеток в тексте | оркестратор (done) | нет |
| Н-6 | дубли «ок» в выводе adversary v1 | adversary | нет |
| Н-7…Н-14 | советы круга 2–3 | implementer | нет |
| Н-15 | двойная строка «CI КРАСНЫЙ» | implementer | закрыт (56ff7dac) |
| Н-16 | CI PR #80 красный (на 56ff7dac: l7 failure, остальные в момент пробы in_progress) | оркестратор | нет — к сведению |
| Н-17 | комментарий `:258-260` обещает диагностику при неудаче jobs-запроса, кода нет | implementer | нет — совет; заглушка ci_diag:92 при починке Б-9c закроет |
| Н-18 | опечатка `ORCH_G_API` в комментарии `:257` | implementer | нет — мелочь |

Done блокирует только Б-9c.
