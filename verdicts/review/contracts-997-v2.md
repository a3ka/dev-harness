FAIL
OBJECT=b2232780be1a87a21c8810f88879c181d0361a14

# Reviewer — контракт 997, реализация, круг 2

- **OBJECT:** b2232780 — land-merge.
  - ^1 = 6c6a5132.
  - ^2 = e3b231b2.
  - merge-base efdf9614.
  - `git merge-tree --write-tree ^1 ^2` = дерево OBJECT 7113e5f6, то есть мерж чистый, своих правок не вносит.
- **Frozen:** `frozen/contracts/997/1` → d67c32a4.
  - Блоб контракта на OBJECT совпадает с тегом.
  - `fixtures/ops_server/orch_loop_997/` отличается от тега: это коммит architect e36d6c03 в зоне architect, см. §3.
- **Находки** (reslop, status: ready): `/tmp/dev-harness-verify/reviewer997r2/findings.md`.
  - Блокируют три: Р2-1, Р2-2, Р2-3.
  - Советов пять: С-1…С-5.

## Находки и классы

| ID | Класс | Суть |
|---|---|---|
| Р2-1 | принятая находка Б-4 не закрыта (заявленное ≠ сделанному, «раздел заменяется актуальной семантикой») | Причина `exec 9>&-` в наблюдателе и в relay названа ложно (orch-loop:57-59, :161-164, :251-253; README:80-83). Мутанты без этих строк проходят transition и `--cases` 32/0. Настоящая роль строки — осиротевший наблюдатель после SIGKILL держит lock бессрочно (`alt/orphan.sh`). Тот же класс: «dup» вместо reopen (:240-241, :260-261; замер O_NONBLOCK — reopen), «EPIPE» (:273; замер — нет EPIPE), README:165 ссылается на несуществующий `tests/alt/devfd.py`, README:90 «после гибели … немедленно» (замер: lock держится до 5 с). |
| Р2-2 | не выполнена строка приёмки «Battery 093 гасит собственные процессы»; принятая Б-5 не закрыта | После battery (rc 0, 10/10, toy-agent-sleeper 0/0) жива собственная сирота `sleep 300`, ppid 1, `OPS093_ROOT=…ops-granica-bat-…/s6`. Ветви :70 и :78 мертвы (`pgrep -x` по comm=`sleep`). Ветвь :73 убивает toy-agent-sleeper ВСЕГО uid: приманка вне SCRATCH убита (`alt/killscope.sh`). Гашение стоит только до клеток, после последней клетки его нет. |
| Р2-3 | превышение области ПЕРЕСЕЧЕНИЯ battery_stubs + дефект | battery_stubs.sh:90 — лишний аргумент `"$rc"` к формату с одним `%s`. printf печатает фантомную строку «✗ 2: …». |
| С-1 | совет (перенос из круга 1) | Если lock не открывается, payload говорит «уже запущен». |
| С-2 | совет архитектору | Проба не наблюдает закрытие fd 9 в наблюдателе, relay и pkill (три мутанта 32/0). |
| С-3 | совет архитектору | `delayed_receipt` вакуумна для relay, отличного от `cat`: PATH-шим cat. |
| С-4 | совет | README:70-71: опечатка «лида»; cell_k5 пинует sha файла, а не lock-путь. |
| С-5 | совет | 085:248-252, :332-336 — комментарии об отсутствии миграции. |

## Закрытие Б-1…Б-5 круга 1 (своей мерой)

- **Б-1 — закрыт.**
  - `alt/r2check.sh`: subseq побайтно = 085:1140, сверено diff'ом; снимок не мигрирован.
  - Результаты:
    - pre997: 65 строк, rc=0;
    - r1: «пропала строка снимка 27: ( while sleep 5; do», rc=1;
    - **OBJECT: 65 строк, rc=0**.
  - `git diff frozen/contracts/997/1 HEAD -- 085`: только литерал И-5 и комментарии, SNAP_LOOP/FIXSIM не подменяются.
  - `cikl_085/` не тронут.
- **Б-2 — закрыт.**
  - `alt/transition.sh`:
    - r1: loop_rc=1, agent_starts=1, «ОТКАЗ: orch-loop уже запущен»;
    - **OBJECT: loop_rc=0, agent_starts=2**.
  - Свидетель: `[ /dev/fd/9 -ef "$LOCKF" ]` — inode, не env.
- **Б-3 — закрыт.**
  - grep `read -t|timeout|kill -0 relay|.scoped|RAN=` по orch-loop → rc 1.
  - coproc один (:254); `exec 8>&-`, чтение до EOF, `wait`.
- **Б-4 — НЕ закрыт** (Р2-1).
  - Исправлено: `ORCH_LOOP_LOCK`, «ресурсный предел не создан», `$()`, TODO и «985» в 085 убраны (grep пуст).
  - Не исправлено: ложь в Р2-1.
- **Б-5 — НЕ закрыт** (Р2-2).
  - HOME клеток изолирован (`cell_home`).
  - `pgrep -fc toy-agent-sleeper` до/после = 0/0, через 3 с = 0.
  - Но собственная сирота `sleep 300` пережила battery.

## 1. Область правки

`git diff --name-only 6c6a5132 b2232780` даёт 7 путей. Распределение по автору (`git show -s --format='%an <%ae>'`):

- **implementer f40daeb0:**
  - пути: orch-loop, README, 085, battery_stubs;
  - все в ЗОНЕ implementer;
  - по содержанию — Р2-3 (выход за цель ПЕРЕСЕЧЕНИЯ battery).
- **architect e36d6c03:** backend.py, probe.py — ЗОНА architect.
- **architect e3b231b2:** 074 PIN → 22150b8d… = `sha256sum ops/server/user/orch-loop` (моя мера). Вне ЗОН, по стоячей санкции №4, прецедент `docs/owner/2026-10-14-razblokirovka-093-v4-l4-l5.md:49`.
- **orchestrator b2232780:** чистый merge, без собственных правок.

`registry/ci-steps.tsv` и `ci.yml` в этом круге не менялись. Норма, roles, contracts и scripts в диффе 997 не тронуты.

## 2. Сырой вывод и rc (мои прогоны в клоне)

Логи лежат в `/tmp/dev-harness-verify/reviewer997r2/logs/`.

**Проба 997:**

- `bash fixtures/ops_server/orch_loop_997/probe.sh --cases` → rc=0, «997 observed=32 mismatches=0».
  - Своя мера (`alt/count.py`): 32 строки SUBJECT, 16 кейсов × 2 uid, с ошибками 0.
- `… --matrix` → rc=0, «observed=60 mismatches=0».
  - Своя мера: HONEST 32, без ошибок 32.
  - MUTANT 28: 23 имени, `caught=1` 28/28. Среди них `receipt_fd_leak` и `lock_fd_leak` пойманы на обоих uid.

**Проба 997 на других субъектах:**

| Субъект | `probe.py --cases --subject` |
|---|---|
| pre997 | rc=1, 32/32 mismatches; в marker_removed RESTART_COUNT — красное ДО |
| r1 | rc=1, mismatches=4: ровно `lock_transition` и `delayed_receipt` на same и other — новые клетки предъявлены красными |
| r2_nowatchclose | rc=0, 32/0 |
| r2_nocatclose | rc=0, 32/0 |
| r2_nopkill | rc=0, 32/0 |

Строки трёх последних субъектов пробой не наблюдаются (С-2).

**Scoped-регресс и CI-шаги:**

- `bash scripts/run_ci_lane.sh check:orch-loop-997` → rc=0 (observed=32/0 и 60/0).
- `bash scripts/gen_ci_steps.sh --check` → rc=0.
- `bash scripts/check_provodka.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md` → rc=0.
- `bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka` → rc=0, «барьеров: 2 · фикстур: 54 · предъявлено красным повторным прогоном: 54».
- `scope_select.sh --changed 6c6a5132` → «0 задетых», MODE needs-full, rc=2.
  - `git diff --name-only 6c6a5132 HEAD -- scripts/ fixtures/case_*` пуст: frozen-барьеры диффом 997 не тронуты.
  - Изменения scripts/ после тега (check_protected, check_provodka) принадлежат 994/owner (`git log`), не 997.

**Соседние батареи:**

- `bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast` → rc=0, «итог 085 fast: красных=0».
- `bash fixtures/ops_granica/red_limit_otkaz_bez_zapuska.sh` с частным HOME → rc=0, «ЗЕЛЁНО(093-2)».
- `bash fixtures/_krasnye_074.sh` → rc=1, «красных клеток=1 стабы=7/7».
  - Единственная красная клетка — cell_k5b: «станция /home/harness/bin/orch-loop разошлась с пином». Это ожидаемо до поставки консультантом.
- `battery_stubs.sh` с частным HOME/TMPDIR → rc=0, «ЗЕЛЁНО(093-bat): 10/10». Плюс сирота (Р2-2).

**Не запускал локально:**

- `_krasnye_072`/`_krasnye_080`: `fixtures/orch_restart/_toy.sh:14-16` при пустом шве делает `rm -f` по живому `/tmp/dev-harness-verify/orch-restart`, а задание запрещает его трогать.
- Полный 085 (м5 — живой systemd-run) и root-дверь 093 по контракту только CI.
- Вместо этого CI main на OBJECT, run 39172953209, 12/12 success:
  - l7 117809712270: «observed=32 mismatches=0», «observed=60 mismatches=0», «итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0», «итог 074: красных клеток=0 стабы=7/7»;
  - l5 117809712613: «итог 085: красных=0, стабы=40/40, диффпроба=32/32», «итог 080-батареи: … честные 31/31»;
  - l4 117809712700: «ЗЕЛЁНО(093-bat): 10/10», «ИТОГ 093: rc=0».

## 3. Не переписаны ли проверки под код

- **085.** Возвращён к замороженному снимку (Б-1). Ожидание р2 и FIXSIM в этом круге больше не подменяются.
- **Проба 997.** Изменена после freeze коммитом **architect** (e36d6c03), а не автором реализации.
  - Дифф к тегу только аддитивный:
    - клетки `lock_transition` и `delayed_receipt`;
    - fd-перепись агента: RECEIPT_FD, LOCK_FD, HELPER_FD;
    - мутанты `receipt_fd_leak` и `lock_fd_leak`;
    - шим `cat`.
  - Прежние проверки не удалены. Единственное исключение — SETUP_NO_DELETION не требуется для двух новых клеток, которые ничего не удаляют.
  - Новые клетки красные на r1 (моя мера выше), мутанты пойманы.
  - Ослабления нет. Привязка `delayed_receipt` к `cat` — С-3.
- **battery s1.** Якорь мигрирован под новый текст отказа. Стаб пойман, CI 10/10.
- **red_limit.** Только литерал И-5.

## 4. ПРОВОДКА

- Канал `guard=fixtures/ops_server/orch_loop_997/probe.sh` существует. Это барьер именно этого предмета: `--subject` по умолчанию = `ops/server/user/orch-loop`.
- Строка registry совпадает с замороженной, lane l7 исполнен в CI.
- ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: roles и нормы не тронуты.

## 5. Атомарность и норма

- f40daeb0 закрывает пять находок круга 1 одного предмета и fd-утечку адверсария одним коммитом. Это одна задача (круг 1 по 997) со ссылкой на предмет, не связка разных задач. Отказа нет, решение то же, что для С-2 круга 1.
- e36d6c03 и e3b231b2 — отдельные коммиты.
- Нормативные документы не тронуты.

## 050 — артефакты этого круга

Пять вопросов в порядке (1) свойство, (2) состояние, (3) совместные правки, (4) глубина, (5) потребитель.

- **orch-loop:64, `[ /dev/fd/9 -ef "$LOCKF" ] || exec 9>>`.**
  - (1) инв. 5 «lock держится во время перехода»;
  - (2) OFD fd 9, явное;
  - (3) 1 файл плюс README;
  - (4) новых env и флагов нет;
  - (5) probe `lock_transition`, красная на r1.
  - Итог: **ESSENTIAL**.
- **orch-loop:166, `exec 9>&-` в наблюдателе.**
  - (1) инв. 3 дословно;
  - (2) нет;
  - (3) 1 файл;
  - (5) потребителя в пробе нет (С-2), функция наблюдается только `alt/orphan.sh`.
  - Итог: **ESSENTIAL**, обоснование в тексте ложно (Р2-1).
- **orch-loop:254-283, coproc один раз и EOF-чтение.**
  - (1) инв. 2/3;
  - (2) fd 7/8 и receipt_pid, явные;
  - (3) копий настройки было 2, стало 1;
  - (4) скрытой константы времени больше нет;
  - (5) probe `delayed_receipt`.
  - Итог: **ESSENTIAL**. `exec 9>&-` внутри coproc наблюдаемого свойства не имеет (r2_nocatclose 32/0, relay не переживает EOF), но совпадает с честной моделью `model.sh:28` — терплю, текст ложен (Р2-1).
- **orch-loop:289/:295, `pkill -P "$watcher"`.**
  - (1) инв. 5 «после выхода новый запуск разрешён»;
  - (5) без строки ожидатель ждёт 4,99 с (`alt/transition.sh`), проба не видит (С-2).
  - Итог: **ESSENTIAL**.
- **battery `cell_home`.**
  - (1) строка приёмки «изолирует HOME клеток»;
  - (2) `$SCRATCH/homes/<tag>`, явное.
  - Итог: **ESSENTIAL**.
- **battery `kill_own_orphans`.**
  - (1) строка «гасит собственные процессы»;
  - (2) состояние неявное: весь uid, а не прогон;
  - (4) три ветви, из них две мёртвые, неиспользуемый счётчик.
  - Итог: **ACCIDENTAL** в мёртвых ветвях. Главное — функция не выполняет свойство (Р2-2). Более простая форма — отбор по `OPS093_ROOT=$SCRATCH/` в environ, образец `probe.py:369`.
- **probe/backend: две клетки, fd-перепись, два мутанта, шим cat.**
  - (1) инв. 2/3/5 (Б-2/Б-3 круга 1, fd-утечка адверсария);
  - (5) lane l7.
  - Итог: **ESSENTIAL**; шим cat — С-3.
- **074 PIN.** ESSENTIAL (санкция №4), потребитель — `check:ops-server-family-selftest`.

Новых читаемых env, флагов и state-каталогов дифф круга не вводит.

## Гигиена

- Все пробы шли в одноразовом клоне и в `/tmp/dev-harness-verify/reviewer997r2/`, с частными HOME/TMPDIR.
- Своя сирота battery `sleep 300` (pid 3736398) погашена.
- После проб процессов с путями reviewer997r2, orch997- и ops-granica нет, `pgrep -fc toy-agent-sleeper` = 0.
- Живые orch-loop/sleep станции и файлы orch-restart*, orch-session-*, _orch_trace*, consultant-* не трогались.
- Коммитов и пушей нет.
