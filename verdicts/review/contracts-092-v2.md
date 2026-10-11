FAIL — 092 круг 2: из 8 блокеров круга 1 закрыты 7 (Б-1…Б-6, Б-8, все подтверждены живьём, а на f9467024 воспроизведены красными). Б-7 закрыт не до конца: package.json потерял завершающий `\n`. Появились два новых блокирующих: Б-9 (ci_wait rc 1 режет имя check-run по пробелу и не печатает шаг и причину, И-5) и Б-10 (`--interval` подставляется в `python3 -c`, исполнение аргумента, регрессия самого 123833c6). Батарея зелёная: 18/18, 21/21, rc 0; parity 0; 041 4/4.

# Review 092, круг 2

**Находки (reslop):** `.review/2026-10-11-01.md`. Блокирующих 3 (Б-7 остаток, Б-9, Б-10), неблокирующих 10
(Н-3…Н-12; Н-1, Н-2 закрыты).

**Судимое:** контракт `frozen/contracts/092/1` (тег → `b6daee0a`, сверено `git rev-parse`). Субъект —
`wip/092/implementer` @ `123833c62cffbfa54ec68190a5ca0399e7619731`, один коммит поверх `f9467024`
(мерж main из круга 1). Батарея — `wip/092/architect` @ `15c4cbe2`: `fixtures/orch_state` = `dd83b30f`,
`_krasnye_092.sh` = `7356eb21`, то есть те же деревья, что в круге 1. Отправная точка — сообщение
коммита 123833c6. Каждое его заявление ниже сверено своей мерой.

## Процедура

SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/static-monkey-092v2`,
`git fetch origin 'refs/heads/wip/092/*' 'refs/tags/frozen/contracts/092/*'`. Worktree `wt` стоит на
`origin/wip/092/implementer`, на нём `git checkout origin/wip/092/architect -- fixtures/orch_state
fixtures/_krasnye_092.sh`. Для красного «до» — worktree `wt0` на `f9467024` с тем же наложением.
Пробы — одноразовые `probes.sh` и `stub_api.py` (toy-API, логирует путь и отдаёт ответы по
очереди) в `/tmp/dev-harness-verify/sm092v2-probes/`, вне дерева.

## 1. Область правки: PASS по путям, FAIL по байтам package.json (Б-7)

```text
$ git diff --name-only f9467024..123833c6
fixtures/parsing_hygiene_battery/profiles/orch_state.sh
package.json
scripts/ci_wait.sh
scripts/orch_checkpoint.sh
scripts/orch_status.sh
$ git rev-list --count f9467024..123833c6        → 1
```

Все 5 путей лежат в ЗОНЕ implementer092. ci.yml и ci-steps.tsv коммит не трогает.

```text
$ git diff -U0 origin/main 123833c6 -- package.json
@@ -81 +81,2 @@
-    "check:watchdog-082-family-selftest": "bash fixtures/verify_antiplacebo/red_watchdog_082.sh"
+    "check:watchdog-082-family-selftest": "bash fixtures/verify_antiplacebo/red_watchdog_082.sh",
+    "check:orch-state-family-selftest": "bash fixtures/_krasnye_092.sh"
@@ -83 +84 @@
-}
+}
\ No newline at end of file
== origin/main  хвост: }  \n  }  \n   5630 байт   (\u04-эскейпов: 0)
== f9467024     хвост: }  \n  }  \n   6287 байт
== 123833c6     хвост:    }  \n  }    5702 байт   (\u04-эскейпов: 0)
scripts: 71 → 72 ключа
```

Кириллица `_comment` и строка 57 (`drill:…` без отступа, как на main) совпадают с main байт-в-байт.
Лишний остаток — снятый завершающий `\n`: 5702 − 5630 = 72 = строка ключа (71+\n) + запятая − EOF-`\n`.
Заявление «дельта — ровно одна новая строка ключа» не выполнено → **Б-7 (остаток)**.

## 2. Сырой вывод: мой прогон

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

$ bash scripts/verify_ci_parity.sh ; echo rc_parity=$?
…
workflow-команд: 12 · скриптов в приёмке: 72 · объявленных исключений: 24 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
rc_parity=0

$ bash fixtures/parsing_hygiene_battery/run_battery.sh orch_state ; echo rc_bat=$?
БАТАРЕЯ orch_state: класс delimiter-collision      — закрыт (rc 0)
БАТАРЕЯ orch_state: класс regex-injection          — закрыт (rc 0)
БАТАРЕЯ orch_state: класс silent-drop              — закрыт (rc 0)
БАТАРЕЯ orch_state: класс self-application-green   — закрыт (rc 0)
БАТАРЕЯ orch_state: итог 4/4 классов закрыто
rc_bat=0
```

Счёт своей мерой, другими командами (wt, круг 2):

```text
$ find fixtures/orch_state -maxdepth 1 -name 'red_*.sh' | wc -l          → 17
$ find fixtures/orch_state/green -name 'case_*.sh' | wc -l                → 4
$ grep -cE "^    'S[0-9]+': \(" fixtures/orch_state/battery_stubs.sh     → 18
```

17 + 4 = 21 = «диффпроба 21/21»; 18 заплаток = «18/18».

## 3. Проверка не переписана под реализацию: PASS

```text
$ git diff --stat f9467024..123833c6 -- fixtures/orch_state fixtures/_krasnye_092.sh contracts/ roles/ AGENTS.md frozen/
(пусто)
```

## 4. Красное предъявлено: PASS для починок

Новых клеток коммит не вводит. Каждую починку доказывает пара прогонов одних и тех же проб:
красный на `f9467024`, зелёный на `123833c6`. Ниже выдержка ключевых строк для `wt0`
(f9467024, батарея наложена):

```text
Б-1a  /repos/owner/repo/commits/b02952a7…/check-runs     (и из cwd=wt, и из cwd=/tmp)
Б-1b  ci_wait(живой) rc=3    ci_diag rc=1    ci_wait(.env) rc=3
      put pub_state published (кандидат=origin/main, без pub-done) rc=1
Б-2   2 wait-done / 2 wait-start на один sha; read-only журнал: ci_wait rc=0 запросов=1
Б-3   init/pubdone/event: rc=1, events до≠после (размер 555 → 565)
Б-4   --next (нет состояния) rc=0; --next (вне грамматики) rc=0
Б-5   T\x41: кругов: 0; a\tb: кругов: 0
Б-6   [0, in_progress, success] --attempts 10: rc=3 запросов=1
Н-1   --sha без значения rc=1; --interval 0 rc=3
```

## Живые пробы на субъекте 123833c6 (сырой вывод `probes.sh`, cwd = wt, probes_rc=0)

```text
=== Б-1a: путь API, ORCH_REPO не задан, cwd=wt (.git — файл worktree), toy-API
ci_wait rc=0
/repos/a3ka/dev-harness/commits/b02952a787ef52047d54b729dcd77b174583d811/check-runs?per_page=100
--- тот же вызов из чужого cwd (/tmp), ORCH_REPO не задан
ci_wait rc=0
/repos/a3ka/dev-harness/commits/b02952a787ef52047d54b729dcd77b174583d811/check-runs?per_page=100
=== Б-1b: ЖИВОЙ GitHub, sha=origin/main=b02952a787ef52047d54b729dcd77b174583d811, ORCH_REPO не задан, токен из окружения
ci_wait: CI КРАСНЫЙ — check-run «ci» → (l7,
ci_wait(живой) rc=1
--- ci_diag на том же sha
ci_diag: CI КРАСНЫЙ по b02952a787ef — check-run «ci (l7, check:contract-frozen check:samodostatochnost-family-selftest check:approval check:door-b...» → failure
Упавшие шаги:
  ✗ шаг 11: Lane l7
Причина из лога (FAIL/ошибки, последние строки):
ci_diag rc=1
--- токен ТОЛЬКО из .env (GITHUB_TOKEN снят; .env подложен в корень дерева скрипта)
ci_wait: CI КРАСНЫЙ — check-run «ci» → (l7,
ci_wait(.env) rc=1
--- orch_status живой: candidate=origin/main, ORCH_REPO не задан
init rc=0
put candidate rc=0
put pub_state published (кандидат=origin/main, без pub-done) rc=0
task: rev092v2
stage: draft
candidate: b02952a787ef52047d54b729dcd77b174583d811
last_proven: -
waiting: none
next_step: -
pub_state: published
кругов: 0
опубликовано: да
закрытие: завершено
CI: ci (l7, check:contract-frozen check:samodostatochnost-family-selftest check:approval check:door-b... → failure
orch_status rc=0
--- отрицательная сторона И-8: кандидат НЕ предок origin/main → published отказ
публикация не доказана: 123833c62cffbfa54ec68190a5ca0399e7619731
put published (123833c6 не в main) rc=1
=== Б-2: ci_wait пишет журнал только через checkpoint
ci_wait #1 rc=0
уже записано
уже записано
ci_wait #2 rc=0
      1 task-init	rev092v2	probe
      1 wait-done	rev092v2	b02952a787ef52047d54b729dcd77b174583d811
      1 wait-start	rev092v2	b02952a787ef52047d54b729dcd77b174583d811
--- events.tsv только-для-чтения
запись состояния не удалась
ci_wait rc=1 events до=a07bbd99f6b4cfb0 после=a07bbd99f6b4cfb0 запросов=0
=== Б-3: поздний отказ записи (RLIMIT_FSIZE = размер журнала + 10, SIGXFSZ игнор)
init: rc=1 stdout='' stderr='запись состояния не удалась'
init: state до=aec581d42cae1bea после=aec581d42cae1bea; events до=8193964cf44bfae9 после=8193964cf44bfae9 (размер 555 → 555)
init: остатков .tmp: 0
--- повтор без лимита:
rc=0
2026-10-11T00:26:53Z^Iround-fail^Iseedtask^Ir6@b02952a787ef52047d54b729dcd77b174583d811$
2026-10-11T00:26:53Z^Itask-init^Irev-probe^I-$
pubdone: rc=1 stdout='' stderr='запись состояния не удалась'
pubdone: state до=4a7ea2aefc79fc32 после=4a7ea2aefc79fc32; events до=8193964cf44bfae9 после=8193964cf44bfae9 (размер 555 → 555)
pubdone: остатков .tmp: 0
--- повтор без лимита:
rc=0
published
event: rc=1 stdout='' stderr='запись состояния не удалась'
event: state до=aec581d42cae1bea после=aec581d42cae1bea; events до=3cd9ab4820834821 после=3cd9ab4820834821 (размер 555 → 555)
event: остатков .tmp: 0
--- граммматика ts всех строк журнала после серии:
строк вне грамматики ts: 0 из 7
=== Б-3x: events.tsv нечитаем, но записываем (chmod 200)
Traceback (most recent call last):
  File "<stdin>", line 248, in <module>
  File "<stdin>", line 90, in triple_exists
  File "<stdin>", line 79, in read_events
PermissionError: [Errno 13] Permission denied: '/tmp/dev-harness-verify/sm092v2-probes/st/events.tsv'
event rc=1
строк до=7 после=7
=== Б-4: orch_status --next
состояние отсутствует
--next (нет состояния) rc=1
состояние отсутствует
без --next (нет состояния) rc=1
состояние вне грамматики: stage
--next (вне грамматики) rc=1
do-it
--next (норма) rc=0
=== Б-5: task = 'T\x41' + 3 round-fail
init rc=0
T\x41
      3 round-fail	T\x41
      1 task-init	T\x41
task: T\x41
кругов: 3
предел: арбитр
--- ещё: task = 'a\tb' (бэкслеш-t, печатный)
task: a\tb
кругов: 3
предел: арбитр
=== Б-6: toy-API [0 прогонов, in_progress, success], --attempts 10
ci_wait rc=0 запросов=3
--- только 0 прогонов, --attempts 3
ci_wait: прогонов CI нет
ci_wait rc=3 запросов=3
=== Н-1: аргументы ci_wait
ci_wait: --sha требует значение
--sha без значения rc=2
ci_wait: --interval должен быть положительным числом: 0
--interval 0 rc=2
ci_wait: CI КРАСНЫЙ — check-run «ci» → (l7,
--interval с кавычкой rc=1 pwned=ДА
=== Н-2: побочный файл
_curl_code файлов в шве: 0
исполняемых ссылок _curl_code: 0
=== porcelain wt после проб
(конец)
```

Ещё одна проба на 123833c6 (живой GitHub, `ORCH_STATE_DIR` в scratch):

```text
$ git show f9467024:scripts/ci_wait.sh | grep -n КРАСНЫЙ
117:        RC=1; MSG="CI КРАСНЫЙ — check-run «$(echo "$EVAL" | awk '{print $2}')» → $(echo "$EVAL" | awk '{print $3}')"; …
$ GITHUB_TOKEN=bogus ci_wait --sha <origin/main> --interval 1 --attempts 2
ci_wait: прогонов CI нет
bogus-token rc=3
$ ci_wait --sha 0000000000000000000000000000000000000000 --interval 1 --attempts 2
ci_wait: прогонов CI нет
несуществующий sha rc=3
$ ORCH_STATE_DIR=/nonexistent-ro/x ci_wait --sha <origin/main>
запись состояния не удалась
state dir unwritable rc=1
```

### Сверка задания, по пунктам

- **Б-1** — slug настоящий (`a3ka/dev-harness`), живой статус настоящий: rc 1 у ci_wait равен
  rc 1 у ci_diag, а не rc 3 «прогонов нет». **Закрыт.** Сообщение при rc 1 искажено: это
  отдельная находка → **Б-9**.
- **Б-3** — RLIMIT_FSIZE на init, pub-done и event: state.tsv и events.tsv по sha256 ДО=ПОСЛЕ.
  **Закрыт.** Порядок rename «журнал, затем состояние» выполняется после того, как оба tmp
  записаны и закрыты. Это ориентир арбитра В4 (`092-kap-krugov-checkpoint-atomarnost.md:143-146`):
  расхождение двух rename возможно только при крахе станции, а это вне Модели угроз.
- **Б-5** — `T\x41` + 3 round-fail дают «кругов: 3», «предел: арбитр». **Закрыт.**
- **Б-7** — word-diff показывает ключ, запятую и снятый EOF-`\n`. **Не закрыт до конца.**
- **Н-1 / Н-2** — подтверждены живьём. Починка Н-1 внесла **Б-10**.

## 5. Атомарность: PASS

Один коммит `123833c6` (author `implementer <implementer@dev-harness.local>`, родитель `f9467024`),
заголовок «092 implementer: починка 8 блокеров (Б-1…Б-8) по обзору 092/1». Пустой ec102c5d
остаётся в истории ветки (Н-7, не заявлялся).

## 6. Норма не тронута: PASS

Коммит не касается `roles/`, `AGENTS.md`, `contracts/`, `frozen/` (diff --stat пуст, см. п. 3).

## 7. Заявленное = сделанное: FAIL (Б-7)

| заявление 123833c6 | моя мера | итог |
|---|---|---|
| Б-1 slug из remote, ORCH_REPO по умолчанию, .env | toy-путь `a3ka/dev-harness` из двух cwd; живой rc 1 = ci_diag; .env-only rc 1 | да |
| Б-2 только через checkpoint, без `\|\| true` | 1+1 тройки; read-only → rc 1, журнал прежний | да |
| Б-3 tmp+rename, оба байт-в-байт | sha256 ДО=ПОСЛЕ ×3 операции, 0 tmp | да |
| Б-4 `--next` → rc 1 | rc 1 / rc 1 / норма rc 0 | да |
| Б-5 ENVIRON, `T\x41` 3/3 + арбитр | 3 + «предел: арбитр» (и `a\tb`) | да |
| Б-6 total 0 — ожидание | rc 0 за 3 запроса; одни нули — 3 запроса, rc 3 | да |
| Б-7 «ровно одна новая строка ключа» | + снятый EOF-`\n` (5630 → 5702, `\ No newline at end of file`) | **нет** |
| Б-8 удалены, 4/4 | 0 упоминаний; 4/4 rc 0 | да |
| Н-1 rc 2 | rc 2 / rc 2 | да |
| Н-2 побочный файл удалён | 0 исполняемых ссылок, 0 файлов | да |

## ПРОВОДКА (038)

Guard-канал остался без изменений с круга 1 (`check:orch-state-family-selftest` → `bash
fixtures/_krasnye_092.sh`, parity rc 0). Роль-канал по-прежнему за зоной 061 (Н-4), ленд — сборкой
обеих веток (Н-3).

## Паразитная сложность (050): артефакты диффа 123833c6

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| `slug_for_repo`/`resolve_token`/умолчание ORCH_REPO (ci_wait, orch_status; умолчание и в checkpoint) | И-4/И-5/И-8(б)/И-9, Б-1 | env ORCH_REPO/GITHUB_TOKEN, `.env` — явно | 3 (было 2), регекс — копия ci_diag:45 | мелкие функции без собственных флагов | клетки 1–3,7–9,13–15; повтор грамматики ci_diag | ESSENTIAL свойство; тройной дубль — совет (Н-11) |
| `atomic_append_event`/`composite_write` tmp+rename, `events_writable`, `read_events_bytes` | И-1 (В4) | `.events.tsv.tmp` в шве, явно | 1 | интерфейс не вырос | клетки 10–12,16; проба Б-3 | ESSENTIAL; глотание OSError в `read_events_bytes` — совет (Н-10) |
| ci_wait `record_event` через checkpoint | И-1 единственный писатель | нет нового | 1 | — | клетки 3,14; проба Б-2 | ESSENTIAL; rc 1 при отказе записи — совет (Н-9) |
| ci_wait ветка `no_runs` → ожидание | И-5 | нет | 1 | — | проба Б-6 | ESSENTIAL; не-200 → «нет прогонов» — совет (Н-8) |
| ci_wait валидация `--interval` через `python3 -c "…'$2'…"` | И-5 «ненулевой интервал» | порождает интерпретатор, исполняет аргумент | 1 | процесс python ради сравнения числа | клетки 3/14 (0.3/0.5) | **ACCIDENTAL, блок (Б-10)**: фрагмент назван, свойства «исполнить аргумент» нет, bash-регекс проходит те же клетки |
| ci_wait валидация `--attempts`, флаги «требует значение» | Н-1 | нет | 1 | — | проба Н-1 | ESSENTIAL (мелочь Н-12) |
| профиль 041: удалены `layer_make`/`repo_make` | — (удаление) | — | 1 | — | приёмка :104 4/4 | закрыто (Б-8) |

## Вердикт

**FAIL.** Блокирующие: **Б-7** (остаток — EOF-`\n` package.json), **Б-9** (ci_wait rc 1: имя
check-run режется по пробелу, шаг и причина не печатаются, И-5), **Б-10** (исполнение аргумента
`--interval`, Р6/041/050). Все три — implementer, маршрут по норме 050 через оркестратора
(`.review/2026-10-11-01.md`, `partial` → `done`). Закрыты: Б-1, Б-2, Б-3, Б-4, Б-5, Б-6, Б-8, Н-1, Н-2.
Неблокирующие: Н-3 (оркестратор, ленд), Н-4 (зона 061, done), Н-5 (оркестратор, done),
Н-6 (adversary), Н-7…Н-12 (implementer). Б-9 существовал уже в круге 1 (f9467024:117), но круг 1
его не увидел: живой путь тогда упирался в Б-1. Это упущение ревью, а не новая мера: И-5 был
заморожен с этой формулировкой.
