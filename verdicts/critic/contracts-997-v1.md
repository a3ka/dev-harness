accept
OBJECT=444e86f97814c9063f4557556bc51a6087a34fb2
Критик, круг 3, контракт 997 (Н-304), класс КОДОВЫЙ. Проход один, перечень закрытый: К1–К4 арбитража bdd63e08f:verdicts/arbitration/contracts-997-outside-witness-v1.md. Клон ssh://git@github.com/a3ka/dev-harness.git лежит в /tmp/dev-harness-verify/critic997r3/clone, checkout 444e86f9 (wip/997/architect). Диф 19eaea97..444e86f9 затрагивает только зону architect: contracts/997-orch-loop-metka-perezapuska.md, fixtures/ops_server/orch_loop_997/backend.py, probe.py. Субъекты критика из /tmp/dev-harness-verify/critic997r2/subj/ не менялись: mtime 13:55/13:59 (раньше арбитража), sha256 honest2 52f72cec…, pgidwit 9acde7e3…, outwit 8543a797… одинаковы до и после прогонов.

Все четыре пункта К1–К4 выполнены, и это доказано прогонами (R1–R5). Блокирующих находок нет. Есть одна измеренная остаточная дыра вне перечня (С1). Её форму предписал сам П1 («beneath /dev — только WRITE_FILE»), поэтому по капу 3 она идёт СОВЕТОМ.

## К1 — неизменённые субъекты критика на новой пробе: выполнено
- honest2: `--cases`, rc 0, `997 observed=28 mismatches=0` (R1).
- pgidwit: rc 1, mismatches=12. Красные ровно сценарии свипа × same/other: marker_removed, removed_crash, removed_crash_1, removed_crash_137, second_refused, bounded. Везде rc 1, starts 1, и в выводе ложный отказ «запуск в scope не подтверждён…» (R1). Это класс Н-304, как и предсказал арбитр.
- outwit: rc 1, mismatches=20. Везде starts 0, `Permission denied` на свидетеле вне W (EACCES от Landlock) и отказ (R1).

## К2 — `--matrix`: выполнено
`probe.py --matrix` → rc 0, `997 observed=52 mismatches=0`. Это 28 HONEST + 18 прежних мутантов + 3 новых × 2 uid (R2). Каждый новый мутант пойман по назначенной причине на назначенном входе обоих uid. В errors нет ни SETUP_, ни TIMEOUT, ни INVALID_TOOL_CALL. Условие засчёта `valid` в probe.py исключает эти три класса явно.
- pgid_receipt / removed_crash_1: RESTART_COUNT (+EXIT_STATUS, TRUTHFUL_SCOPE), same и other.
- outside_receipt / marker_removed: RESTART_COUNT, starts 0, «cannot create /tmp/orch997-outside-*/receipt: Permission denied», same и other.
- lock_receipt / marker_removed: RESTART_COUNT, same и other.
OUT лежит в одноразовом `orch997-outside-*`, который проба создаёт и удаляет (`tempfile.TemporaryDirectory`), а не в общем /tmp. После прогонов `/tmp/orch997-*` = 0.

## К3 — по коду и по инъекции: выполнено
- Кортеж W один: backend.py:17 `WRITABLE = (root/'home', root/'volatile-state', root/'tmp', control)`. Landlock берёт его в `for path in (*WRITABLE, Path('/dev'))` (confine_writes), свип — в `for directory in WRITABLE if directory != control`. Свип идёт по W∖control, как требует П2. Каталог MARK — `volatile-state` (probe.py `ORCH_MARK=state/'restart'`), частный TMPDIR — `root/tmp`, и он передан субъекту (П3). XDG_RUNTIME_DIR не перенаправлен.
- В свипе нет исключений по имени: `protected = {str(lock)}`. Пропускаются только baseline-объекты, то есть существовавшие до запуска (П2). В W это одни каталоги. Lock перед свипом обнуляется: `if lock.exists(): os.truncate(lock, 0)`. Канарейки (`$MARK.scoped`, unrelated-receipt, HOME, tmp) лежат внутри W.
- Handled-маска сверена с UAPI: WRITE_FILE=1<<1, биты 4..12 (REMOVE_DIR … MAKE_SYM), REFER=1<<13 при ABI≥2, TRUNCATE=1<<14 при ABI≥3. До restrict_self стоит PR_SET_NO_NEW_PRIVS (38). Код возврата каждой ступени проверяется.
- Отказ Landlock даёт rc 2, а не продолжение работы (R3). Это измерено инъекцией в одноразовых копиях пробы:
  - ENOSYS на create_ruleset: `--matrix` → rc 2, `NOT_IMPLEMENTED: Landlock unavailable: [Errno 38] Landlock ABI unavailable`; `--cases` honest2 → тоже rc 2.
  - ENOSYS на restrict_self: `--matrix` → rc 2, `… Landlock restrict_self`.
  - Тихий no-op (`confine_writes` сразу `return`): `--matrix` → rc 1, mismatches=2, и это ровно `outside_receipt caught=0` на same и other. Значит, зелёная матрица сама доказывает, что ограничение включено, как заявил арбитр.
  Путь отказа: шим пишет событие `landlock_unavailable` и выходит с rc 2, run_case поднимает OSError, main даёт `NOT_IMPLEMENTED` и rc 2.

## К4 — текст, гейты, до-997: выполнено
- :50 совпадает с текстом П5 дословно: «во всём пространстве записи scope-команды W (HOME, каталог MARK, частный TMPDIR); вне W … Landlock; … без исключений по имени, у канонического lock сохраняется inode и обнуляется содержимое».
- :71 (Конформный вход): исключение «кроме MARK/GO/PGID» удалено. Описаны единый кортеж W, /dev только с WRITE_FILE, свип W∖control и обнуление lock. Есть фраза «Landlock недоступен → rc 2 (NOT_IMPLEMENTED), не пропуск».
- НЕ ЗАЩИЩАЕТ, буллет MARK/GO/PGID: дописано «последствия в их собственной семантике (приказ рестарта, reaping); подтверждение scope обязано переживать их удаление».
- Критерий `--matrix` (:56) называет `pgid_receipt`, `outside_receipt`, `lock_receipt`. :63 не тронута.
- Гейты на клоне (R4): check_precision_gate rc 0 (`OK`); check_threat_model rc 0 (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 3); check_provodka rc 0; check_consumers rc 0.
- До-997 субъект (`--cases` по умолчанию, ops/server/user/orch-loop, на ветке не тронут): rc 1, mismatches=28 (R1).

## Советы (accept не отменяют; вне К1–К4)

СОВЕТ fixtures/ops_server/orch_loop_997/backend.py (confine_writes, правило `Path('/dev')` → WRITE_FILE) и contracts/997-orch-loop-metka-perezapuska.md:50/:63/:71. Измерен свидетель вне W, который переживает свип. Он идёт через то самое право WRITE_FILE под /dev, которое предписал П1. Цикл стоит вне scope и не ограничен, поэтому он заранее создаёт `/dev/shm/<имя>`. In-scope команда делает `printf SCOPED >>"$F"`: append требует только WRITE_FILE, TRUNCATE для этого не нужен. Затем цикл проверяет содержимое. Субъект /tmp/dev-harness-verify/critic997r3/devshm_subject (honest-модель плюс эти три строки, devshm.py) даёт `--cases` → rc 0, 28/28 (R5). Свойство :63 «независимо от имени/каталога» поэтому для /dev/shm не наблюдается, а :50 «вне W проба запрещает … запись» точно лишь вместе с оговоркой :71 про /dev. Блокером не ставлю. Форму права задал пункт арбитража П1, а не выбор автора. Вектор новый и не входит в К1–К4, и кап 3 относит такое к советам. Дешёвое закрытие [INFERENCE: не измерено]: вместо `beneath /dev` дать WRITE_FILE только конкретным устройствам (/dev/null, /dev/tty, /dev/pts). Anon-pipe `/dev/fd/8` раскрывается в pipefs, а Landlock на неё не распространяется. Ещё нужен мутант `devshm_receipt` на marker_removed с причиной RESTART_COUNT. Если владелец считает, что этот вектор входит в Н-304, решение за ним.

## Сырой вывод

R1. Субъекты на 444e86f9 (`python3 probe.py --cases --subject …`; логи в /tmp/dev-harness-verify/critic997r3/*.log):
```
honest2: 997 observed=28 mismatches=0 rc=0
pgidwit: 997 observed=28 mismatches=12 rc=1
  marker_removed|removed_crash|removed_crash_1|removed_crash_137 × same/other: rc=1 starts=1 ['EXIT_STATUS','RESTART_COUNT','TRUTHFUL_SCOPE'] FALSE_REFUSAL
  second_refused × same/other: rc=1 starts=1 ['REFUSAL','TRUTHFUL_SCOPE'] FALSE_REFUSAL
  bounded × same/other: rc=1 starts=1 ['BOUND','EXIT_STATUS','TRUTHFUL_SCOPE'] FALSE_REFUSAL
outwit: 997 observed=28 mismatches=20 rc=1   (все 20: starts=0, «Permission denied», ложный отказ; зелёные только scope_refused*, lock_held, lock_before_update)
pre997 (default subject): 997 observed=28 mismatches=28 rc=1
```

R2. `python3 probe.py --matrix`:
```
997 observed=52 mismatches=0  rc=0
MUTANT pgid_receipt caught=1 {"case":"removed_crash_1","identity":"same","rc":1,"starts":1,"errors":["EXIT_STATUS","RESTART_COUNT","TRUTHFUL_SCOPE"]}
MUTANT pgid_receipt caught=1 {"case":"removed_crash_1","identity":"other","rc":1,"starts":1,"errors":["EXIT_STATUS","RESTART_COUNT","TRUTHFUL_SCOPE"]}
MUTANT outside_receipt caught=1 {"case":"marker_removed","identity":"same","rc":1,"starts":0,"errors":["EXIT_STATUS","RESTART_COUNT","TRUTHFUL_SCOPE"]} … cannot create /tmp/orch997-outside-mbze0mou/receipt: Permission denied
MUTANT outside_receipt caught=1 {"case":"marker_removed","identity":"other","rc":1,"starts":0,"errors":["EXIT_STATUS","RESTART_COUNT","TRUTHFUL_SCOPE"]} … Permission denied
MUTANT lock_receipt caught=1 {"case":"marker_removed","identity":"same","rc":1,"starts":1,"errors":["EXIT_STATUS","RESTART_COUNT","TRUTHFUL_SCOPE"]}
MUTANT lock_receipt caught=1 {"case":"marker_removed","identity":"other","rc":1,"starts":1,"errors":["EXIT_STATUS","RESTART_COUNT","TRUTHFUL_SCOPE"]}
```

R3. Инъекции (inject.py; копии /tmp/dev-harness-verify/critic997r3/inj-*/, правка ровно одной строки backend.py):
```
inj-enosys   (create=99444)       --matrix:         NOT_IMPLEMENTED: Landlock unavailable: [Errno 38] Landlock ABI unavailable rc=2
inj-enosys                         --cases honest2:  NOT_IMPLEMENTED: Landlock unavailable: [Errno 38] Landlock ABI unavailable rc=2
inj-restrictfail (restrict=99446)  --matrix:         NOT_IMPLEMENTED: Landlock unavailable: [Errno 38] Landlock restrict_self rc=2
inj-noop     (confine_writes: return) --matrix:      997 observed=52 mismatches=2 rc=1
  MUTANT outside_receipt caught=0 {"case":"marker_removed","identity":"same","rc":0,"starts":2,"errors":[]}
  MUTANT outside_receipt caught=0 {"case":"marker_removed","identity":"other","rc":0,"starts":2,"errors":[]}
```

R4. Гейты (`bash scripts/<g>.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md` в клоне):
```
check_precision_gate rc=0 :: OK
check_threat_model   rc=0 :: модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))
check_provodka       rc=0
check_consumers      rc=0
```

R5. Свидетель-append под /dev (совет С1):
```
python3 devshm.py && probe.py --cases --subject devshm_subject → 997 observed=28 mismatches=0 rc=0
правка honest-модели: export CRIT_F="/dev/shm/critic997r3-$$-$n"; : >"$CRIT_F"   (цикл, вне scope)
                      'printf SCOPED >>"$CRIT_F"; …'                            (scope-команда)
                      devshm="$(cat "$CRIT_F")"; rm -f "$CRIT_F"; if [ "$devshm" != SCOPED ]   (проверка)
остаток в /dev/shm после прогона: 0
```

## Раскрытие
- Живой systemd-run, 085 и 093 не запускались, scoped-регресс шёл только по барьеру 997, полный прогон за CI. Основной чекаут не тронут, push не делался. Вердикт не закоммичен: коммит делает оркестратор под identity critic.
- После прогонов: `/tmp/orch997-*` = 0, процессов проб нет, /tmp/dev-harness-verify/critic997r2/w пуст, `git status` клона чист.
- Одноразовые доказательства оставлены для проверки: run.sh, summ.py, inject.py, devshm.py, devshm_subject, inj-*/ и *.log в /tmp/dev-harness-verify/critic997r3/.
- Риск CI (Landlock на ubuntu-latest) остаётся таким, как его записал арбитр. С этого хоста он не измерим.
