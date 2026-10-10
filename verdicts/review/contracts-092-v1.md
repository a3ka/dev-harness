FAIL — 092 круг 1: батарея зелёная (17+4, 18/18, 21/21), но живые пробы вне батареи нашли 8 блокирующих: Б-1 заглушка slug `owner/repo` и ORCH_REPO двойного смысла (на живом GitHub ci_wait rc 3 «прогонов нет», ci_diag — CI КРАСНЫЙ), Б-2 ci_wait пишет журнал мимо checkpoint, Б-3 обрывок журнала при позднем отказе записи (И-1), Б-4 `--next` rc 0 без состояния, Б-5 awk -v ломает счёт кругов, Б-6 total_count 0 → rc 3 без ожидания, Б-7 package.json шире «одного ключа», Б-8 мёртвый код профиля 041

# Review 092, круг 1

**Находки (reslop):** `.review/2026-10-10-03.md` — блокирующих 8 (Б-1…Б-8), неблокирующих 7 (Н-1…Н-7).

**Судимое:** контракт `frozen/contracts/092/1` (тег → b6daee0a). Субъект — `wip/092/implementer`
@ `4ac664bb757c41f9a97b99a6fc5d30fd26d4912b` (tip `f9467024`). Батарея — `wip/092/architect` @
`606eb710fd7838c519b3b6b81ce51523bf84443b` (tip `15c4cbe2`). Прочитаны целиком:
`verdicts/critic/contracts-092-v1.md`, `verdicts/arbitration/092-kap-krugov-checkpoint-atomarnost.md`,
`verdicts/adversary/contracts-092-v1.md`, `verdicts/adversary/contracts-092-v2.md`.

Гигиена (Н-39): «стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды».

## Процедура

SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/rev092r1-a7c3/repo`,
`git fetch origin 'refs/heads/wip/092/*' 'refs/tags/frozen/contracts/092/*'`. Worktree `wt`
поставлен на `origin/wip/092/implementer`, батарея наложена так же, как у adversary круга 2:
`git checkout origin/wip/092/architect -- fixtures/orch_state fixtures/_krasnye_092.sh`.
scripts/ субъекта остались свои. Пробы — одноразовые скрипты `probes.sh`, `accept.sh`,
`prof_red.sh` в `/tmp/dev-harness-verify/rev092r1-a7c3/`, вне дерева.

### Тот же контент на tip (сверено живьём)

```text
$ git diff --name-only 4ac664bb..origin/wip/092/implementer | grep -E '<все пути ЗОН 092>' ; echo rc_grep=$?
rc_grep=1                                  # ни одного пути зон 092
$ git diff --name-only 606eb710..origin/wip/092/architect | grep -E '<все пути ЗОН 092>'
.github/workflows/ci.yml
registry/ci-steps.tsv
scripts/handoff_rotate.sh                  # три пути implementer-зоны — пришли мержем main:
.github/workflows/ci.yml arch=22ef91fe… main=22ef91fe…
registry/ci-steps.tsv arch=4fcdf4a9… main=4fcdf4a9…
scripts/handoff_rotate.sh arch=eb2dd15a… main=eb2dd15a…
$ git rev-parse 606eb710:fixtures/orch_state origin/wip/092/architect:fixtures/orch_state
dd83b30f… dd83b30f…   (fixtures/_krasnye_092.sh: 7356eb21… = 7356eb21…)
scripts/orch_checkpoint.sh 4ac=00730b2f tip=00730b2f; orch_status.sh 364feada=364feada;
ci_wait.sh 80b28d52=80b28d52; profiles/orch_state.sh 30a90c38=30a90c38
не-мерж коммиты 4ac664bb..tip вне main: ec102c5d (пустой, diff-tree 0 строк); 606eb710..tip: нет
```

## 1. Область правки — FAIL (Б-7)

Коммиты implementer: `33caf2ef` (7 файлов) и `4ac664bb` (2 файла). Все пути лежат в ЗОНА
implementer. В ci.yml ровно один ключ (`check:orch-state-family-selftest` в l5 после ключа 091,
новых джоб и шардов нет — word-diff). В ci-steps.tsv одна строка после шага 091. В package.json
семантически тоже один ключ:

```text
comment_equal_semantically True
added {'check:orch-state-family-selftest'} removed set() changed []
toplevel_diff []
```

Байтово дельта шире: `_comment` перекодирован в `\u0421\u0438…` (на origin/main `grep -c '\\u04'` = 0,
на субъекте 1), строка `drill:nabludenia-nechitaemo` переотступлена. Контракт для 011/015
разрешает «Дельта — один ключ», так что это превышение → **Б-7**.

## 2. Сырой вывод — мой прогон

```text
$ bash fixtures/_krasnye_092.sh ; echo rc=$?
диффпроба: честный мини-субъект зелён на всех 21 клетках семьи (rc=0)
S1 → red_net_off_local_survives.sh: поймано
S2 → red_net_off_local_survives.sh: поймано
S3 → red_pub_vs_close.sh: поймано
S4 → red_status_derives_not_echo.sh: поймано
S5 → red_ciwait_no_repoll.sh: поймано
S6 → red_restart_no_dup_task.sh: поймано
S7 → red_restart_no_dup_round.sh: поймано
S8 → red_restart_no_dup_publish.sh: поймано
S9 → red_three_fails_three_rounds.sh,red_rounds_count_events_not_files.sh: поймано
S10 → red_three_fails_three_rounds.sh: поймано
S11 → red_three_fails_three_rounds.sh: поймано
S12 → red_checkpoint_atomic_fail.sh: поймано
S13 → red_checkpoint_grammar.sh: поймано
S14 → red_state_outside_tree.sh: поймано
S15 → red_ciwait_net_vs_timeout.sh: поймано
S16 → red_checkpoint_atomic_fail.sh: поймано
S17 → red_pub_state_needs_proof.sh: поймано
S18 → red_pub_done_mismatch_refusal.sh: поймано
стаб-пак 092: 18/18 поймано, диффпроба 21/21
ок red_net_off_local_survives
ок red_restart_continues_subject
ок red_ciwait_no_repoll
ок red_restart_no_dup_task
ок red_restart_no_dup_round
ок red_restart_no_dup_publish
ок red_three_fails_three_rounds
ок red_pub_vs_close
ок red_status_derives_not_echo
ок red_checkpoint_atomic_fail
ок red_checkpoint_grammar
ок red_state_outside_tree
ок red_rounds_count_events_not_files
ок red_ciwait_net_vs_timeout
ок red_pub_state_needs_proof
ок red_status_no_state_refusal
ок red_pub_done_mismatch_refusal
ок case_checkpoint_roundtrip
ок case_status_green
ок case_ciwait_green
ок case_events_idempotent_green
rc=0
```

Счёт своей мерой, другими командами, не через вывод раннера:

```text
$ find fixtures/orch_state -maxdepth 1 -name 'red_*.sh' | wc -l            → 17
$ find fixtures/orch_state/green -name 'case_*.sh' | wc -l                  → 4
$ awk '/^PAK=\(/,/\)$/' battery_stubs.sh | grep -oE "'S[0-9]+ " | sort -u | wc -l  → 18
$ grep -cE "^    'S[0-9]+': \(" battery_stubs.sh   (тела-заплатки)          → 18
```

17 + 4 = 21 — совпадает с «диффпроба 21/21»; 18 PAK-пар = 18 заплаток = «18/18».

Приёмка контракта:

```text
A2 $ bash fixtures/_krasnye_091.sh            → …ок o13  rc=0
A3 $ bash fixtures/parsing_hygiene_battery/run_battery.sh orch_state
БАТАРЕЯ orch_state: класс delimiter-collision      — закрыт (rc 0)
БАТАРЕЯ orch_state: класс regex-injection          — закрыт (rc 0)
БАТАРЕЯ orch_state: класс silent-drop              — закрыт (rc 0)
БАТАРЕЯ orch_state: класс self-application-green   — закрыт (rc 0)
БАТАРЕЯ orch_state: итог 4/4 классов закрыто       rc=0
   (без аргумента профиля раннер rc=1 «использование: … <профиль>» — команда приёмки :104
    названа без аргумента; совет к тексту, не субъекту)
A4 серия init/put/event/status/--next в wt, ORCH_STATE_DIR вне дерева: все rc 0;
   «porcelain не изменился серией»
$ bash scripts/verify_ci_parity.sh → «… расхождений: 0» rc=0
```

## 3. Проверка не переписана под реализацию — PASS

Коммиты implementer (`33caf2ef`, `4ac664bb`) не касаются `fixtures/orch_state/`,
`fixtures/_krasnye_092.sh` и контракта. После заморозки батарею правил architect
(`35c53bb6..606eb710`): `_krasnye_092.sh` (только числа в комментариях), `_toy.sh` (+2 литерала,
+2 клетки в списке), `battery_stubs.sh` (+гвард pub-done в честном теле, +S18, литерал
`'состояние отсутствует'` заменён на тот же текст через `L['O92L_NETSOST']`), +2 новые клетки.
Ослаблений нет, только добавления.

## 4. Красное предъявлено — PASS

```text
=== субъект 33caf2ef (до починки) против батареи 606eb710
КРАСНО: red_status_no_state_refusal — rc=0, ожидался 1         клетка 16 rc=1
КРАСНО: red_pub_done_mismatch_refusal[а] — rc=0, ожидался 1    клетка 17 rc=1
=== тот же 4ac664bb: клетка 16 rc=0, клетка 17 rc=0
=== мутанты РЕАЛЬНОГО тела 4ac664bb
снят гвард put published (И-8):
КРАСНО: red_pub_state_needs_proof[а] — rc=0, ожидался 1        клетка 15 rc=1
composite_write = write_state; append_event (И-1, state первым):
КРАСНО: red_checkpoint_atomic_fail[б] — state.tsv изменился при отказе составной init   клетка 10 rc=1
=== профиль 041 orch_state на мутантах checkpoint
M1 (put режет по ':'): delimiter-collision — ПРОБИТ, итог 3/4, rc=1
M2 (put молча не пишет '-'): delimiter-collision, silent-drop — ПРОБИТ, итог 2/4, rc=1
```

Вывод: И-1 составная атомарность (порядок) и И-8 put published по форме не обойдены. Клетки
10/15 красны на мутантах настоящего тела, на субъекте зелены. Пробы арбитра 1/1б/1в/2/2б
(клетки 10б/10в, 15а–г) проходит сама батарея.

## 5. Атомарность — PASS

`33caf2ef` содержит реализацию и проводку CI одного предмета, `4ac664bb` — починку находок
adversary круга 1. Оба коммита ссылаются на 092. `ec102c5d` пустой (Н-7).

## 6. Норма не тронута — PASS

Коммиты implementer не трогают `roles/`, `AGENTS.md`, `contracts/`. Роль-канал ПРОВОДКИ ждёт
владельца зоны 061 (Н-4).

## 7. Заявленное = сделанное — FAIL (Б-3)

Сообщение `33caf2ef`: «rc!=0 на ЛЮБОЙ ошибке записи — оба файла байт-в-байт прежние». Проба P5
ниже это опровергает: при rc 1 events.tsv меняется. Остальные заявления (ключ в l5, одна строка
ci-steps, 4 класса профиля) совпали с моей мерой.

## Живые пробы вне батареи (сырой вывод `probes.sh`, rc=0)

```text
=== P1: путь API ci_wait в боевой конфигурации (cwd = репо a3ka/dev-harness, ORCH_REPO не задан)
ci_wait rc=0
1791664078.840 /repos/owner/repo/commits/f946702428ec89df4cfdf6af7f1f2702d4e44ee0/check-runs?per_page=100
--- ORCH_REPO=<локальный путь репо> (как задаёт toy):
ci_wait rc=0
1791664078.902 /repos/owner/repo/commits/f946702428ec89df4cfdf6af7f1f2702d4e44ee0/check-runs?per_page=100
=== P1r: живой GitHub, sha = origin/main клона
ci_wait: прогонов CI нет
ci_wait(живой) rc=3
ci_diag: CI КРАСНЫЙ по 92894a7b808c — check-run «ci (l7, check:contract-frozen …» → failure
=== P2: ci_wait пишет events.tsv мимо orch_checkpoint
ci_wait #1 rc=0
ci_wait #2 rc=0
      2 wait-done	092	aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
      2 wait-start	092	aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
--- то же через checkpoint (эталон дедупа):
уже записано
checkpoint rc=0
--- events.tsv только-для-чтения, ci_wait:
…/ci_wait.sh: line 44: …/events.tsv: Permission denied   (×2)
ci_wait rc=0 events до=05ff59b1edbf307b после=05ff59b1edbf307b (события wait-* молча потеряны)
=== P3: total_count 0, затем in_progress, затем success; --attempts 10
ci_wait: прогонов CI нет
ci_wait rc=3 запросов=1
=== P4: orch_status --next
состояние отсутствует
--next (нет состояния) rc=0
состояние отсутствует
без --next (нет состояния) rc=1
состояние вне грамматики: stage
--next (вне грамматики) rc=0
=== P5: И-1 — поздний отказ дозаписи журнала (RLIMIT_FSIZE = размер журнала + 10, SIGXFSZ игнор)
rc=1 stdout='' stderr='запись состояния не удалась'
init: state до=99eba4ecc9d41260 после=99eba4ecc9d41260; events до=1593fcf918a3bf73 после=bcb7802447b58b9f (размер 452 → 462)
--- хвост events.tsv (od):
0000000   x   x … x  \n   2   0
0000020   2   6   -   1   0   -   1   0
--- повтор той же операции без лимита: rc=0
2026-10-102026-10-10T20:28:02Z^Itask-init^Ireviewer-probe^I-$
rc=1 stdout='' stderr='запись состояния не удалась'
pubdone: state до=99eba4ecc9d41260 после=99eba4ecc9d41260; events до=1593fcf918a3bf73 после=bcb7802447b58b9f (размер 452 → 462)
--- повтор без лимита: rc=0
2026-10-102026-10-10T20:28:02Z^Ipub-done^I732^Iaaaa…@refs/$
--- одиночный event (не составной), тот же лимит:
rc=1 stdout='' stderr='запись состояния не удалась'
event: events до=1593fcf918a3bf73 после=bcb7802447b58b9f (размер 452 → 462)
=== P6: ci_wait аргументы
…/ci_wait.sh: line 17: $2: unbound variable
--sha без значения rc=1
ci_wait: нечем проверить: сеть
--interval 0 rc=2
```

Ещё две пробы (команды в wt, ORCH_STATE_DIR в scratch):

```text
=== P8: счёт кругов, task = 'T\x41'
T\x41                                   (get task)
      3 round-fail	T\x41
      1 task-init	T\x41
task: T\x41
кругов: 0
rc=0
=== P9: кандидат = сам origin/main, ORCH_REPO не задан (cwd = репо)
кандидат предок origin/main: rc=0
публикация не доказана: 92894a7b808c04c3bdb5cc25511ec6aed58a6686
put published (ORCH_REPO не задан, cwd=репо) rc=1
опубликовано: нет
удалённое состояние: неизвестно
put published (ORCH_REPO=путь) rc=0
ORCH_REPO=ssh://git@github.com/a3ka/dev-harness.git → опубликовано: нет
```

Почему батарея этого не видит: toy задаёт `ORCH_REPO=<toy-каталог>`, toy-API не сверяет путь
запроса, журнал ci_wait не проверяется на дедуп и писателя, `--next` клетки 9 видит только
наличие состояния. Это пробелы критерия, а не подгонка. Батарея принята владельцем при
заморозке, поэтому находки адресованы реализации: каждая — нарушение буквы инварианта на
конформном входе (Демаркация 019: любые task-id, любые sha, боевой репо).

## ПРОВОДКА (038)

- Guard-канал: `registry/ci-steps.tsv` + ci.yml l5 + package.json → `bash fixtures/_krasnye_092.sh`.
  Это барьер именно этого предмета, проверено (parity rc 0). Подключится только при ленде вместе
  с батареей architect (Н-3).
- Роль-канал (`roles/orchestrator.md`): на origin/main 0 строк. Это зона 061, не implementer
  (Н-4); для done — обязательное условие, иначе Выход-2 никем не исполняется.

## Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| scripts/orch_checkpoint.sh | И-1/2/3/8 | state.tsv/events.tsv, явно через ORCH_STATE_DIR; ORCH_REPO — неявный шов | 1 (+_toy при смене литералов) | 4 подкоманды, 2 env против грамматики, дедупа, атомарности — глубокий | клетки 4–6,10–12,15,17 | ESSENTIAL |
| scripts/orch_status.sh | И-4/И-4а/И-3 | читает; пишет побочный `/tmp/dev-harness-verify/_curl_code_$$` (Н-2) | 2 (дублирует slug/curl с ci_wait) | `--next` + 3 env; slug-логика повторена | клетки 1,2,7,8,9,13,16 | ESSENTIAL; дубль slug и побочный файл — ACCIDENTAL (Н-2, вошёл в Б-1) |
| scripts/ci_wait.sh | И-5 | пишет events.tsv сам (Б-2), побочный файл (Н-2) | 2 (slug/curl ≈ orch_status, ≈ ci_diag) | 4 флага + 3 env | клетки 3,14 | ESSENTIAL; собственный писатель журнала — нарушение (Б-2) |
| profiles/orch_state.sh | 041-профиль (приёмка :104) | временные каталоги | 1 | 4 функции класса; layer_make/repo_make мертвы | приёмка 3 | ESSENTIAL ядро; :8-23,28-29 ACCIDENTAL блокирующее (Б-8: фрагмент, свойства нет, простая форма 4/4 rc 0) |
| ключ check:orch-state-family-selftest (ci-steps/ci.yml/package.json) | ПРОВОДКА guard | нет | 3 (прецедент 058–091) | — | CI l5 | ESSENTIAL |
| побочный `_curl_code_$$` | нет | скрытый файл вне шва | 2 | — | нет | ACCIDENTAL, совет (Н-2: сценарий отказа не исполнен) |

## Особое внимание задания — итог

- **И-1 составные операции (init, pub-done):** порядок «оба tmp до необратимого шага» для
  state соблюдён, клетки 10а/б/в зелены, мутант порядка ловится. Но журнал дописывается на
  месте, поэтому поздний отказ (P5) оставляет events.tsv НЕ байт-в-байт при rc 1 → **Б-3**.
  Застревания 1в нет: повтор после отказа даёт rc 0.
- **И-8 put published:** гвард `pub_proven` — это (а) pub-done текущих task+candidate или
  (б) `merge-base --is-ancestor` к `refs/remotes/origin/main`; на toy верно, клетка 15 и
  мутант это подтверждают. В боевой конфигурации (б) недостижимо: без `ORCH_REPO` git-факт
  не вычисляется, и даже сам origin/main «не доказан» (P9) → входит в **Б-1**.

## Вердикт

**FAIL.** Блокирующие: Б-1, Б-2, Б-3, Б-4, Б-5, Б-6, Б-7, Б-8 — все implementer, маршрут
починки — по норме 050 через оркестратора (`.review/2026-10-10-03.md`, `partial` → `done`).
Неблокирующие: Н-1 (implementer), Н-2 (implementer), Н-3 (оркестратор, ленд), Н-4 (зона 061,
done), Н-5 (оркестратор, done), Н-6 (adversary), Н-7 (implementer). У Б-3 есть оговорка о
толковании слова владельца 2026-10-09: при споре — владельцу, не мне.
