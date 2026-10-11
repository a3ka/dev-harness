FAIL — 092 круг 3. Б-7 и Б-10 закрыты, это подтверждено живьём. Инъекция `--interval` воспроизведена красной на 123833c6 своими payload, на 7fcee777 те же payload дают 0 файлов. Б-9 закрыт наполовину: имя check-run теперь полное, но упавший шаг и причину ci_wait по-прежнему не печатает (И-5, вторая половина находки круга 2). Новый блокер Б-11: заявленная починка pending-ветки — мёртвый код, case `pending)` не совпадает с `pending\t<имя>`. Батарея 18/18 и 21/21, rc 0; parity 0; 041 4/4.

# Review 092, круг 3

**Находки (reslop):** `.review/2026-10-11-02.md`. Блокирующих 2 (Б-9 остаток, Б-11),
неблокирующих новых 2 (Н-13, Н-14). Закрыты Б-7 и Б-10.

**Судимое:** контракт `frozen/contracts/092/1` (тег → `b6daee0a`; `git diff --stat` тега против
origin/main по файлу контракта пуст). Субъект — `wip/092/implementer` @
`7fcee7778d6fa2f02048062f84e07debeb9e06dc`, родитель `123833c62cffbfa54ec68190a5ca0399e7619731`
(его я судил в круге 2). Батарея — `wip/092/architect` @ `15c4cbe2`: `fixtures/orch_state` = `dd83b30f`,
`_krasnye_092.sh` = `7356eb21`, те же деревья, что в кругах 1–2. Отправная точка — сообщение
коммита 7fcee777. Каждое его заявление ниже сверено своей мерой.

## Процедура

SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/rev092v3-cff`.
Worktree `wt` стоит на `origin/wip/092/implementer`, поверх наложен `git checkout
origin/wip/092/architect -- fixtures/orch_state fixtures/_krasnye_092.sh`. Для красного «до» —
worktree `wt0` на `123833c6`. Пробы — одноразовые `probes.sh` и `stub_api.py` (toy-API: логирует
путь, отдаёт ответы по очереди) в `/tmp/dev-harness-verify/rev092v3-cff-probes/`, вне дерева.

## 1. Область правки: PASS

```text
$ git diff --name-only 123833c6..7fcee777
package.json
scripts/ci_wait.sh
$ git diff --stat 123833c6..7fcee777
 package.json       |  2 +-
 scripts/ci_wait.sh | 23 ++++++++++++++++++-----
$ git diff --stat 123833c6..7fcee777 -- fixtures contracts roles AGENTS.md frozen .github registry
(пусто)
```

## 2. Сырой вывод: мой прогон (wt, батарея наложена)

```text
$ bash fixtures/_krasnye_092.sh ; echo rc=$?
диффпроба: честный мини-субъект зелён на всех 21 клетках семьи (rc=0)
S1 → red_net_off_local_survives.sh: поймано
… (S2…S17 — поймано, все строки)
S18 → red_pub_done_mismatch_refusal.sh: поймано
стаб-пак 092: 18/18 поймано, диффпроба 21/21
ок red_net_off_local_survives
… (17 red_* + 4 case_* — все «ок»)
ок case_events_idempotent_green
rc=0

$ bash scripts/verify_ci_parity.sh
workflow-команд: 12 · скриптов в приёмке: 72 · объявленных исключений: 24 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
rc_parity=0

$ bash fixtures/parsing_hygiene_battery/run_battery.sh orch_state
БАТАРЕЯ orch_state: итог 4/4 классов закрыто
rc_bat=0
```

Счёт своей мерой, другими командами:

```text
$ find fixtures/orch_state -maxdepth 1 -name 'red_*.sh' | wc -l          → 17
$ find fixtures/orch_state/green -name 'case_*.sh' | wc -l                → 4
$ grep -cE "^    'S[0-9]+': \(" fixtures/orch_state/battery_stubs.sh     → 18
```

17 + 4 = 21 = «диффпроба 21/21»; 18 заплаток = «18/18». В сообщении коммита написано
«все 21 клетки зелёные (18/18 + 21/21)», это совпадает.

## Живые пробы (сырой вывод `probes.sh`, probes_rc=0)

```text
=== Б-10: инъекция через --interval (свои payload), без сети: шов на 127.0.0.1:9
payload#1 rc=2 stderr=ci_wait: --interval должен быть положительным числом: __import__('os').system('touch /tmp/d
payload#2 rc=2 stderr=ci_wait: --interval должен быть положительным числом: 1'); __import__('os').system('touch /
payload#3 rc=2 stderr=ci_wait: --interval должен быть положительным числом: 1"); __import__('os').system('touch /
payload#4 rc=2 stderr=ci_wait: --interval должен быть положительным числом: 1'+str(__import__('os').system('touch
payload#5 rc=2 stderr=ci_wait: --interval должен быть положительным числом: $(touch /tmp/dev-harness-verify/rev09
payload#6 rc=2 stderr=ci_wait: --interval должен быть положительным числом: `touch /tmp/dev-harness-verify/rev092
payload#7 rc=2 stderr=ci_wait: --interval должен быть положительным числом: 1; touch /tmp/dev-harness-verify/rev0
payload#8 rc=2 stderr=ci_wait: --interval должен быть положительным числом: -c|
payload#9 rc=2 stderr=ci_wait: --interval должен быть положительным числом: 1')|__import__('os').system('touch /t
pwned-файлов: 0
--- граница грамматики float (не инъекция): что принимает валидация
  '0.3'  валидация=принят  sleep: спит
  '0.5'  валидация=принят  sleep: спит
  '1'    валидация=принят  sleep: спит
  '0'    валидация=отказ  sleep: sleep rc=0
  '-1'   валидация=отказ  sleep: sleep rc=1
  'nan'  валидация=отказ  sleep: sleep rc=1
  'inf'  валидация=принят  sleep: спит
  '1e999' валидация=принят  sleep: спит
  '1_0'  валидация=принят  sleep: sleep rc=1
  ' 2 '  валидация=принят  sleep: sleep rc=1
  '0x1'  валидация=отказ  sleep: спит
=== Б-9 fail: имя с пробелами
ci_wait: CI КРАСНЫЙ — check-run «ci (l7, check:contract-frozen check:x)» → failure
rc=1 запросов=1
=== Б-9 fail: имя с TAB внутри
ci_wait: CI КРАСНЫЙ — check-run «ci» → (l7, x)^Ifailure
rc=1
=== Б-9 fail: пустое имя / имя с переводом строки
ci_wait: CI КРАСНЫЙ — check-run «ci» → 
rc=1
=== Б-9 pending: in_progress на каждый запрос, --attempts 2, БЕЗ --timeout (MSG pending-ветки доходит до вывода)
ci_wait: неизвестно
rc=3 запросов=2
--- что печатает python-оценка и матчит ли её case-шаблон 'pending)'
case: pending) НЕ совпал → ветка *) «неизвестно»
=== ок-путь (регрессии нет)
rc=0
```

(Строки `уже записано` от дедупа wait-start/wait-done опущены.)

Красное «до» для Б-10: wt0 = 123833c6, мои payload, шов 127.0.0.1:9:

```text
ci_wait: --interval должен быть положительным числом: __import__('os').system('touch …/pwned_a')
123833c6 payload#1 rc=2
ci_wait: нечем проверить: сеть
123833c6 payload#2 rc=2
ci_wait: нечем проверить: сеть
123833c6 payload#3 rc=2
pwned_b
pwned_d
```

На 123833c6 payload `1'); …` и `1'+str(…)+'` проходят валидацию и выполняются: появляются
файлы pwned_b и pwned_d. На 7fcee777 те же payload получают отказ, файлов 0. Проба различает
красное и зелёное, и она не повторяет пробу implementer (у того был `import os; os.system`
через `;`).

Живой GitHub (токен из окружения, sha b02952a7, ORCH_REPO = wt):

```text
--- ci_wait 7fcee777
ci_wait: CI КРАСНЫЙ — check-run «ci (l7, check:contract-frozen check:samodostatochnost-family-selftest check:approval check:door-b...» → failure
rc=1
--- ci_diag тот же sha
ci_diag: CI КРАСНЫЙ по b02952a787ef — check-run «ci (l7, … check:door-b...» → failure
Упавшие шаги:
  ✗ шаг 11: Lane l7
Причина из лога (FAIL/ошибки, последние строки):
(…строки лога…)
--- pending на 123833c6 (тот же стаб in_progress, --attempts 2)
ci_wait: неизвестно
rc=3
```

Б-7, хвост package.json:

```text
origin/main   } \n } \n   5630
123833c6      } \n }      5702
7fcee777      } \n } \n   5703
$ git diff origin/main 7fcee777 -- package.json
-    "check:watchdog-082-family-selftest": "bash fixtures/verify_antiplacebo/red_watchdog_082.sh"
+    "check:watchdog-082-family-selftest": "bash fixtures/verify_antiplacebo/red_watchdog_082.sh",
+    "check:orch-state-family-selftest": "bash fixtures/_krasnye_092.sh"
```

Ни одной строки `\ No newline at end of file`. 5703 − 5630 = 73 = строка ключа с `\n` (72) + запятая.

## 3. Проверка не переписана под реализацию: PASS

Коммит не касается `fixtures/` (diff --stat пуст, п. 1). Батарея ветки implementer — подмножество
архитекторской: `git diff --stat origin/wip/092/architect origin/wip/092/implementer --
fixtures/orch_state fixtures/_krasnye_092.sh` → `25 files changed, 2082 deletions(-)`, только
удаления. На ветке implementer батареи нет, она накладывается с architect.

## 4. Красное предъявлено: PASS для Б-10 и Б-7, НЕТ для Б-11

Б-10 — красное на 123833c6, зелёное на 7fcee777 (выше). Б-7 — байтовая сверка трёх ревизий.
Б-9 (имя) — красное круга 2 (`«ci» → (l7,`), зелёное сейчас. Для pending-ветки implementer
красного не предъявил, а живая проба показывает, что ветка не исполняется вовсе (Б-11).
Новых клеток коммит не вводит. Батарея проверяет rc, а не текст сообщения, поэтому ни Б-9, ни
Б-11 батарея не ловит. Это пробел критерия, а не подгонка.

## 5. Атомарность: PASS

Один коммит `7fcee777` (author `implementer <implementer@dev-harness.local>`, родитель `123833c6`),
заголовок «092 implementer: починка остатков круга 2 (Б-7/Б-9/Б-10)».

## 6. Норма не тронута: PASS

`roles/`, `AGENTS.md`, `contracts/`, `frozen/` коммит не трогает (п. 1).

## 7. Заявленное = сделанное: FAIL (Б-9, Б-11)

| заявление 7fcee777 | моя мера | итог |
|---|---|---|
| Б-7 вернуть EOF-`\n`, только ключ | хвост `}\n}\n`, 5703 = 5630 + 73, нет `\ No newline` | да |
| Б-10 sys.argv, аргумент не исполняется | 9 своих payload: rc 2, 0 файлов; на 123833c6 два из них создают файлы | да |
| Б-10 аудит смежных файлов зоны | 5 вызовов python в зоне, ни в одном исходнике нет `$` (см. ниже) | да |
| Б-9 rc 1: полное имя | toy и живой GitHub — полное имя, `→ failure` | да |
| Б-9 исправлен целиком (И-5 «шаг + причина») | ci_wait на b02952a7 печатает одну строку, ci_diag — шаг 11 + причину | **нет** |
| Б-9 pending-ветка «больше не режет имя» | ветка недостижима: `pending)` ≠ `pending\t…` → «неизвестно» | **нет** (Б-11) |
| батарея 18/18 + 21/21, parity 0 | мой прогон + счёт find/grep | да |

Аудит Б-10 своей мерой. Вызовы python в зоне (`grep '(python3|PYBIN).*(-c "|<<)'` по ci_wait,
orch_status, orch_checkpoint и профилю 041) — 5 мест: ci_wait:75 (`sys.argv[1]`), ci_wait:155
(`sys.argv[1]` = путь tmp), orch_status:116 (`os.environ` REPO/CAND), orch_status:162
(`sys.argv[1]` = путь tmp), orch_checkpoint:68 (`"$PYBIN" - … <<'PYEOF'`, heredoc в кавычках —
без подстановки). `grep '\$'` по телам python-исходников ci_wait:155-181 и orch_status:116-171
даёт совпадения только на строках shell-вызова (116, 162, 171, 181), внутри исходника `$` нет.
Интерполяции внешнего ввода в python-исходник нет. Пробой исполнения проверен только ci_wait.

## ПРОВОДКА (038)

Guard-канал не менялся (`check:orch-state-family-selftest` → `bash fixtures/_krasnye_092.sh`,
parity rc 0). Роль-канал — по-прежнему за зоной 061 (Н-4), ленд — сборкой обеих веток (Н-3).

## Паразитная сложность (050): артефакты диффа 7fcee777

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| ci_wait валидация `--interval` через `python3 -c … sys.argv[1]` | И-5 «ненулевой интервал» | процесс python, аргумент — данные | 1 | интерфейс прежний | клетки 3/14 (0.3/0.5); проба Б-10 | ESSENTIAL свойство. Грамматика float шире sleep — совет (Н-13) |
| TAB-протокол `fail\t<имя>\t<concl>` / `pending\t<имя>` + `IFS=$'\t' read` | И-5 rc 1 «формат ci_diag» | нет | 1 (python-печать и case-разбор в одном файле) | — | живой rc 1; повтор грамматики ci_diag:73, но имя не последним полем (Н-14) | ESSENTIAL для fail. pending-часть — мёртвый код (Б-11) |
| package.json: EOF-`\n` | 011/015 «дельта — один ключ» | нет | 1 | — | parity | закрыто (Б-7) |

## Вердикт

**FAIL.** Блокирующие:

- **Б-9 (остаток)** — И-5 «rc 1 печатает упавший шаг + причину, формат ci_diag». Имя check-run
  исправлено, шаг и причина отсутствуют (живое b02952a7: ci_wait — одна строка, ci_diag —
  `✗ шаг 11: Lane l7` + лог). Более простая форма: на rc 1 вызвать `scripts/ci_diag.sh "$SHA"`.
- **Б-11** — §7 + И-5 rc 3. Заявленная починка pending-ветки недостижима (`ci_wait.sh:200`
  `pending)` против `print('pending\t' + nm)` на `:176`). Исход in_progress до конца попыток
  печатает `ci_wait: неизвестно`. Дефект был и на 123833c6, но 7fcee777 объявил его закрытым.
  Тот же класс — `parse_err)` на `:205`. Починка: `pending*)` / `parse_err*)`.

Оба блокера — implementer, маршрут по норме 050 через оркестратора (`.review/2026-10-11-02.md`,
`partial` → `done`). Это продолжение итеративного цикла: Б-9 — недоделанная половина находки
круга 2, Б-11 — ложное заявление в самой починке. Спора и арбитражного тупика нет.

Закрыты: **Б-7**, **Б-10** (security-класс, проба своими payload, красное на 123833c6).
Неблокирующие: Н-3 (оркестратор, ленд), Н-4 (зона 061), Н-5 (оркестратор), Н-6 (adversary),
Н-7…Н-12 (implementer, коммит их не трогает), новые Н-13 (грамматика `--interval`: `inf` висит
дольше `--timeout`, `1_0` даёт опрос без интервала) и Н-14 (TAB или перевод строки в имени
check-run, имя не последним полем). Ни одна Н-находка done не блокирует.
