FAIL
OBJECT=59b3886b4955949c46fc93e9ef9d3658ead5c022
Критик, круг 1, контракт 997 (Н-304), класс КОДОВЫЙ. Ветка wip/997/architect, клон ssh://git@github.com/a3ka/dev-harness.git → /tmp/dev-harness-verify/critic997r1/dh, checkout 59b3886b.
По правилу кругов (docs/owner/2026-10-18-tri-slota.md §3): ниже ПОЛНЫЙ список блокеров. Все три одного класса. Чинить их надо обобщённо, точечные правки класс не закроют (см. «Класс и обобщённая починка»).

## Решает ли конструкция боль Н-304

Да, если реализовать честно. Анонимный pipe + `SCOPED\n` изнутри scope до exec + отказ без подтверждения + flock на `$HOME/.local/state/...` + общий EARLY_MAX: это правильный выбор. Ложных отказов и ложных разрешений на конформном входе в самой конструкции я не нашёл. Честная production-реализация по контракту (моя, mut/subj/honest) зелена на всех сценариях пробы, включая мои усиленные варианты (ниже).
Дефект в другом месте: ПРИЁМОЧНЫЙ КРИТЕРИЙ слабее предмета. Три реализации, которые предмет НЕ делают, проходят `probe.sh --cases` с rc 0 на всех 9 сценариях.

## Блокеры

БЛОКИРУЕТ contracts/997-orch-loop-metka-perezapuska.md:50 (и :36, :55) — критерий утверждает: «`removed_crash` … не используется exit-code как свидетель scope». Ни один сценарий пробы этого не доказывает. Агент в пробе завершается только с rc 0/7/143 (fixtures/ops_server/orch_loop_997/backend.py, ветки `removed_crash`/`bounded`/`finish`). Фейковый systemd-run при отказе даёт rc 1 (backend.py, `scope_refused`/`second_refused`). Эвристика «rc 1 ⇒ scope не создан» поэтому неотличима от канала подтверждения. В MUTANTS (probe.py) мутанта «свидетель = rc» нет.
ОБХОД: production `ops/server/user/orch-loop` БЕЗ канала подтверждения. Убрать `: >"$1"`, вместо `if [ ! -e "$RAN" ]` написать `if [ "$rc" -eq 1 ]`, сменить две строки журнала на payload контракта, добавить flock. Получается `probe.sh --cases` → rc 0, 9/9 (сырой вывод R2). Предмет не сделан. Сессия omp, отработавшая в scope и завершившаяся с rc 1 (обычная ошибка процесса), получает тот же ложный «запуск в scope не подтверждён», цикл останавливается, станция стоит. Это ровно класс Н-304. Наблюдение: тот же субъект при rc агента 1 → loop rc 1, запусков 1, ложный отказ (R3).

БЛОКИРУЕТ contracts/997-orch-loop-metka-perezapuska.md:50 (против :5, :25, :36) — в предмете сказано: «факт запуска в scope хранится вне удаляемого файлового имени». Перенос файла Frontier явно отклонил (:25). При этом проба удаляет ТОЛЬКО буквальное имя `$ORCH_MARK.scoped` (backend.py, ветка `omp`: `legacy = Path(str(mark) + '.scoped')` … `legacy.unlink()`). Мутант `named_receipt` тоже привязан к этому одному имени.
ОБХОД: до-997 orch-loop с одной заменой `RAN="$MARK.scoped"` → `RAN="$MARK.ran"`, плюс payload и flock (отклонённый вариант Frontier :25). Получается `probe.sh --cases` → rc 0, 9/9 (R2). Предмет не сделан: свидетель по-прежнему файл в /tmp/dev-harness-verify, и удаляется он так же, как удалили `.scoped` в Н-304. Если удалять все побочные файлы MARK, кроме исключённых моделью угроз MARK/GO/PGID, этот субъект даёт loop rc 1, ложный отказ, запусков 1 (R3). Честный субъект на том же входе зелен.

БЛОКИРУЕТ contracts/997-orch-loop-metka-perezapuska.md:53 (против :39 «Швы MARK/LOG не меняют ключ блокировки», :28 «lock-inode вне verify, без unlink») — `duplicate` запускает второй цикл с ИДЕНТИЧНОЙ средой (probe.py `run_case`: один `env` на оба `launch()`). Поэтому годится любой ключ блокировки, производный от швов. Путь/ключ lock критерий не наблюдает. Требование владельца (§1: «отсутствие второго экземпляра») доказательства не получает.
ОБХОД: `exec 9>>"$MARK.lock" && flock -n 9` (lock в /tmp/dev-harness-verify рядом с меткой, ключ от шва ORCH_MARK). Получается `probe.sh --cases` → rc 0, 9/9 (R2). Предмет не сделан. Второй цикл, запущенный с другим ORCH_MARK (ops.env против env-переопределения), стартует второго агента при живом первом: second_rc «still-running», агентов 2 (R3). При удалении файла из /tmp/dev-harness-verify (механизм Н-304) новый inode также пускает второй экземпляр. Честный субъект с lock в `$HOME/.local/state/dev-harness/orch-loop.lock` на том же входе отказывает (R3).

## Класс и обобщённая починка

У всех трёх блокеров один класс: проба закрепляет ОДИН экземпляр дефекта (rc 7, одно имя файла, одна и та же среда). Свойство, которое объявляет предмет, она не проверяет. Независимость не варьируется по тому измерению, от которого предмет себя объявляет независимым. Починка, не точечная:
1. Для каждого заявленного свойства независимости проба варьирует вход по этому измерению. Rc агента включает 1 (то же значение, что у отказа systemd-run) и 137. Удаляется всё, что субъект мог создать вне явно исключённого моделью угроз (MARK/GO/PGID/lock): все побочные файлы MARK, а не одно имя. Второй цикл в `duplicate` идёт с другими ORCH_MARK/ORCH_LOG. Ключ lock проверяется чёрным ящиком: проба сама держит `flock` на `$HOME/.local/state/dev-harness/orch-loop.lock` и требует отказа с payload. При свободном lock на том же пути проба требует старта.
2. Каждая из трёх форм обхода (`rc_witness`, `renamed_file`, `mark_lock`) входит в MUTANTS probe.py со своей наблюдаемой причиной, иначе `--matrix` не докажет, что усиление ловит. Правило различимости :55 уже требует ровно этого.
Позитивный контроль уже измерен: честная реализация по инвариантам 1–6 зелена на всех трёх усиленных входах (R3).

## Сырой вывод

R0. Гейты на 59b3886b (клон):
```
$ bash scripts/check_precision_gate.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md
OK                                   rc=0
$ bash scripts/check_threat_model.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))   rc=0
$ bash scripts/check_provodka.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md   rc=0
$ bash scripts/check_consumers.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md  rc=0
```

R1. Проба автора, `--matrix` rc 0 (13/13), `--cases` на дереве без реализации rc 1 (9/9 mismatches, как заявлено :46/:48):
```
HONEST marker_removed/removed_crash/scope_refused/second_refused/duplicate/bounded/clean_exit errors=[] (7/7)
MUTANT named_receipt caught=1 ... MUTANT stale_receipt caught=1 (6/6)
997 observed=13 mismatches=0                                  rc=0
SUBJECT marker_removed same rc=1 starts=1 errors=[EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE] ... (9 строк, все с ошибками)
997 observed=9 mismatches=9                                   rc=1
```

R2. Обходы через `python3 probe.py --cases --subject <файл>`. Субъекты собраны из до-997 orch-loop скриптом /tmp/dev-harness-verify/critic997r1/mut/mk.py в mut/subj/:
```
### honest   (pipe-receipt, lock в $HOME/.local/state, fd lock закрыт в наблюдателе) 997 observed=9 mismatches=0 rc=0
### rcwit    (нет канала; if [ "$rc" -eq 1 ] → отказ)                                  997 observed=9 mismatches=0 rc=0
### renamed  (RAN="$MARK.ran")                                                         997 observed=9 mismatches=0 rc=0
### marklock (pipe-receipt, exec 9>>"$MARK.lock")                                       997 observed=9 mismatches=0 rc=0
### leakfd   (наблюдатель держит fd lock → самоблокировка на exec "$0")                997 observed=9 mismatches=5 rc=1   (проба ловит — не находка)
```
Диф rcwit против до-997 (выдержка): `-if [ ! -e "$RAN" ]; then` / `+if [ "$rc" -eq 1 ]; then`; `sh -c 'exec "$4" --yolo -- "$5"'` (без `: >"$1"`).
Диф renamed: `-RAN="$MARK.scoped"` / `+RAN="$MARK.ran"` (+ payload, + flock).

R3. Те же субъекты на одноразовой копии пробы с тремя расширениями только для наблюдения (/tmp/dev-harness-verify/critic997r1/mut/harm.py → harm/): rc агента в removed_crash задаётся параметром; удаляются все побочные файлы MARK, кроме .go/.pgid/.lock; в duplicate второй цикл идёт с другим ORCH_MARK/ORCH_LOG:
```
### honest removed_crash CRITIC_CRASH_RC=1        rc=0 starts=2 errors=[]
### honest marker_removed generalized-deletion   rc=0 starts=2 errors=[]
### honest duplicate CRITIC_DUP_MARK=1           rc=0 second_rc=1 starts=1 errors=[]
### rcwit removed_crash CRITIC_CRASH_RC=1        rc=1 starts=1 errors=[EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE]
   "сессия #1: запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)"   ← ложный отказ отработавшего scope
### renamed removed_crash CRITIC_CRASH_RC=7      rc=1 starts=1 errors=[EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE]
### renamed marker_removed generalized-deletion rc=1 starts=1 errors=[EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE]
### marklock duplicate CRITIC_DUP_MARK=1         rc=0 second_rc="still-running" starts=2 errors=[DUPLICATE]
```

R4. Потребители с честным кандидатом (cand/ = клон + mut/subj/honest как ops/server/user/orch-loop) против базы 59b3886b:
```
red_cikl_perezapuska_085.sh  база: итог 085: красных=0, стабы=40/40, диффпроба=32/32  rc=0
                             кандидат: красных=4 — р2 «пропала строка снимка 36: done ) &»; м4/м6 — нет строки «ресурсный предел не создан» (миграция в зоне);
                             м5 «живая сессия не найдена: потомки цикла без «^omp --profile» (журнал заглушки sudo: …, записей: 2)»   rc=1
093 по клеткам под ОДНИМ HOME (fakehome): battery_stubs rc=1 (9/10, s1-якорь RAN — миграция в зоне); red_limit_otkaz rc=1 (диагноз — в зоне);
   red_agent_uid_stancija_nedostupna rc=1 «субъект не дошёл до границы сессии»; red_net_osirotevshih_detej rc=1; red_kredit rc=0
   держатель lock: «HOLDER pid=1773999 fd=9 cmd=bash /tmp/dev-harness-verify/ops-granica-bat-TpHAHt/s6/ops/server/user/orch-loop» ppid=1, ребёнок «sleep 300»
те же две клетки на свежем HOME: ЗЕЛЁНО(093-3) rc=0; ЗЕЛЁНО(093-7) rc=0. На базе 59b3886b обе rc=0.
```

R5. Глубина процесса при подстановке команды (bash, без &): `x="$(sleep 2 3>&1 1>&4 4>&-)"` → sleep — ВНУК цикла (промежуточный bash-подпроцесс); тот же вызов без `$(…)` → прямой ребёнок.

## Советы (accept не отменяют, автор закрывает по усмотрению)

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:37 + :56 — цена высокая, раунд. Форма «запуск через shell command-substitution» прямо разрешена (:37) и показана в model.sh:28. При ней bash держит промежуточный подпроцесс, и агент становится внуком цикла (R5). Последствия: (а) клетка 085 м5 (живой systemd-run на станции) краснеет, «живая сессия не найдена» (R4); (б) строки наблюдателя `pkill -TERM -P "$loop_pid" -f '^omp --profile'` (orch-loop:163–165, их держит снимок р2) перестают что-либо находить. При этом :56 разрешает менять тесты «только для новой диагностики/мутации удалённого RAN», а ПЕРЕСЕЧЕНИЕ 085 — только «миграция диагноза». Исполнитель зажат: стоп или молчаливое расширение. Решите заранее одно из двух. Либо запретить промежуточный процесс: systemd-run остаётся прямым ребёнком, read-end канала держит заранее открытый fd/coproc, подтверждение читается после возврата. Либо явно разрешить перенос поиска м5 на уровень глубже в ПЕРЕСЕЧЕНИИ 085.

СОВЕТ fixtures/ops_server/orch_loop_997/model.sh:24 — `) 9>&- & watcher=$!`. Если перенести эту форму в production, меняется строка снимка `  done ) &`, и 085 р2 краснеет (R4). Закрывать fd lock стоит внутри тела наблюдателя отдельной строкой (вставка подпоследовательность р2 не ломает). Это стоит назвать в контракте.

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:39 + ЗОНА implementer (battery_stubs.sh) — ключ lock = HOME. Семья 093 гоняет все клетки под одним HOME (CI: `HOME=/var/lib/ci093-agent`, run-ops093-ci.sh:61). Стаб s6 battery_stubs оставляет сироту-цикл (ppid 1, `sleep 300`), который держит lock HOME. Клетки 3 и 7 (ВНЕ зоны) после этого краснеют (R4). Ожидаемо красный CI-ключ check:granica-ispolneniya-093-family-selftest, если battery не гасит своих сирот. Battery в зоне, поэтому назовите это в ПЕРЕСЕЧЕНИИ battery_stubs. Клетки 2/3/7 HOME не задают. Их локальный прогон на станции пишет и берёт `/home/harness/.local/state/dev-harness/orch-loop.lock`, а сирота s6 может держать живой lock станции до 300 с, когда цикл остановлен на пик. Стоит потребовать изоляции HOME или назвать это в модели угроз.

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:39 — «до изменения состояния рестарта/наблюдателя/сессии» не наблюдается ни одним сценарием. Lock после `rm -f "$MARK" "$GO"` (orch-loop:78) или после self-update `install.sh user` (orch-loop:56–66) пробу проходит. Второй ручной запуск в окне GRACE при этом стирает MARK первого, и рестарт молча отменяется. Нужен вариант duplicate с MARK, поставленным до второго запуска, и проверкой, что MARK/GO пережили отказ.

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:44 + :56 — :44 обещает «systemd-run и systemctl всегда подменены. Станция не участвует». Это верно для probe.sh, но не для 085 из того же критерия (:56): м5 вызывает ЖИВОЙ `systemd-run --user --scope`, где он доступен (red_cikl_perezapuska_085.sh `m5_probe`/`cell_m5`). Стоит назвать это явно, чтобы судьи не нарушали запрет «не запускать реальный systemd-run» по незнанию. Со мной так и вышло, см. раскрытие ниже.

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:68/:138 (cognitive-only) — проброс fd 3 НАСТОЯЩИМ systemd-run --scope проба не проверяет (там шим). Остаточный риск: если какой-то systemd закрывает чужие fd, каждый запуск получит ложный отказ. [Наблюдено попутно] живая 085 м5 с честным кандидатом записала 2 вызова sudo-заглушки, то есть первая сессия подтверждена через настоящий `systemd-run --user --scope` этого хоста. Стоит явно внести «ложного scope-отказа нет» в шаг 3 поставки (там это уже частично есть) и пометить как cognitive-only. Ветка self-update (`ORCH_SELF_UPDATED=1 exec "$installed"`) не исполняется пробой (ORCH_SELF_UPDATE=0). Наследование fd lock в ней идёт так же, как в `exec "$0"`, это [ИНФЕРЕНЦИЯ].

СОВЕТ fixtures/ops_server/orch_loop_997/model.sh:28–33 — fd 4 (дубликат stdout) утекает в агента: `4>&-` на запуске нет. Безвредно, но в production стоит закрыть, раз инвариант 2 перечисляет закрываемые fd.

Проверено и находок нет: «установка на станцию» вынесена в §Поставка ПОСЛЕ done (:138–) и явно НЕ считается выполненной контрактом. ЗОНЫ/ПЕРЕСЕЧЕНИЯ проходят check_precision_gate (rc 0). ПРОВОДКА: check_provodka rc 0, строка CI-step названа. Модель угроз: check_threat_model rc 0, граница сформулирована по свойствам и MARK/GO/PGID исключены честно. И-5/093 не ослаблены: инварианты 1/2, мутант `fallback` пойман. Привязка мутантов к ветвям — в коде (probe.py MUTANTS), не в прозе. Самоблокировку через унаследованный fd lock проба ловит детерминированно (leakfd, R2).

## Раскрытие отступлений от ограничений

- Регресс-прогоны `bash fixtures/ops_server/red_cikl_perezapuska_085.sh`, названные в критерии :56 (дважды: база и кандидат, одноразовые копии), исполнили клетку м5. Она вызвала ЖИВОЙ `systemd-run --user --scope -p MemoryMax=64M -p MemorySwapMax=0` с игрушечной нагрузкой python в скратче 085 (HOME/MARK в `$W`). omp, живой orch-loop (PID 1471517) и /tmp/dev-harness-verify/orch-restart* не затронуты. Что м5 живая, я узнал из её текста уже после прогона.
- Свой осиротевший тестовый цикл (PID 1773999 + `sleep 300`, из battery s6 под моим fakehome) погашен `kill`. Это не станционный процесс.
- Основной чекаут не тронут, push не делался, вердикт не закоммичен (по заданию, страж Н-85).
