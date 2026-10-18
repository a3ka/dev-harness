РЕШЕНИЕ
OBJECT=19eaea97ad814d739be43bb29f441cca78de5259
Арбитр, контракт 997 (Н-304), класс КОДОВЫЙ. Созван критиком строкой `АРБИТР:` в круге 2 (ea80b913f) по правилу 15: второй FAIL по одной причине. Читал первоисточники: контракт и fixtures/ops_server/orch_loop_997/ на SHA (клон /tmp/dev-harness-verify/arb997/clone), вердикты 4ebcfe446 (круг 1) и ea80b913f (круг 2), субъекты критика /tmp/dev-harness-verify/critic997r2/subj/ (без изменений). Каждый спорный пункт ниже решён прогоном. Ход эксперимента — одноразовая копия пробы /tmp/dev-harness-verify/arb997/exp/.

## Решение по пунктам

### (б) Свидетель под защищённым именем (`$MARK.pgid`, pgidwit) — критик прав
Исключение MARK/GO/PGID по имени в свипе (backend.py:76–77) не нужно ни одному сценарию. Оно лишь открывает три файловых имени, в которых можно хранить receipt. Измерено (R2): свип без исключений по имени оставляет честную модель зелёной (28/28, все 18 мутантов пойманы) и честную production-реализацию критика honest2 тоже (28/28). Причина по коду. В момент свипа (старт агента) MARK и GO в честном потоке не существуют. Цикл удаляет их в начале сессии; MARK ставит агент уже после свипа, GO ставит наблюдатель после MARK. PGID нужен только для reap_session (`[ -s "$PGID" ] || return 0`, orch-loop:124), подтверждение scope от него не зависит. Значит, файл с одним из этих имён, существующий в момент свипа, создан самим субъектом при этом запуске и является кандидатом в свидетели. Канонический lock — единственное исключение. Его inode сохраняется (:28 «без unlink»), содержимое обнуляется: иначе lock-inode становится тем же защищённым именем (R3, мутант lock_receipt проходит исходную пробу).

Предложение критика удалять `.pgid` только в removed_crash* отклонено. Единое правило проще, и прогоном показано, что ложных красных оно не даёт ни в одном сценарии.

Толкование НЕ ЗАЩИЩАЕТ «От удаления MARK/GO/PGID: другие свидетели/класс отказа»: речь о последствиях в ИХ СОБСТВЕННОЙ семантике (потерянный приказ рестарта, недобитые сироты). Подтверждение scope обязано переживать их удаление. Это и есть :25 «MARK/GO/PGID и их семантика не объединяются с ним» и :36 «токен не берётся из … файла».

### (а) Свидетель вне частного дерева (outwit, `$XDG_RUNTIME_DIR`/любой абсолютный путь) — критик прав по сути, его средство неисполнимо, закрытие другое
Свойство :63 «независимо от имени/каталога» на выходе пробы не наблюдается: outwit 28/28 зелёный на исходной пробе. Подтверждено и моим мутантом outside_receipt: исходная проба его не ловит (R3).

Перечень каталогов (HOME, XDG_RUNTIME_DIR, TMPDIR, /tmp, …) как закрытие — НЕВЕРНО, по трём измеренным причинам:
1. Перечень открыт по построению: следующий обход — /dev/shm, /var/tmp, любой жёсткий путь.
2. production принудительно возвращает XDG_RUNTIME_DIR к `/run/user/$(id -u)`, если тот отличается (orch-loop:186–187). Перенаправить его средой проба не может.
3. Свип общих каталогов (/tmp, /run/user/UID) на станции опасен: там живут файлы живой сессии.

Средство критика (mount-namespace, unshare/bwrap) на станции недоступно. Замер: `unshare -Urm …` → «write failed /proc/self/uid_map: Operation not permitted»; `kernel.apparmor_restrict_unprivileged_userns = 1`; bwrap не установлен.

Правильное закрытие — ограничить, где in-scope код вообще может писать, а свип сделать ровно этим пространством. Инструмент — Landlock. Он непривилегированный, без userns: `landlock` есть в /sys/kernel/security/lsm станции, ядро 6.8. Шим systemd-run (доверенный, по «Конформному входу» исполняет команду только после создания scope) перед exec scope-команды накладывает Landlock-ограничение. Все права на создание, запись, удаление и переименование разрешены только под W = {HOME, каталог MARK (`volatile-state`), частный TMPDIR, control}; запись в char-устройства /dev разрешена. Всё прочее in-scope коду недоступно для записи. Свип удаляет все новые объекты W∖control. Тогда «независимо от имени/каталога» закрыто по построению:
- вне W свидетель не создаётся (EACCES), и субъект краснеет на любом сценарии;
- внутри W новое удаляется без исключений по имени.

Измерено (R2): outwit 20/28 красный, loop rc 1, ноль агентов. pgidwit 12/28 красный, ложный отказ «сессия #1: запуск в scope не подтверждён…» — класс Н-304. honest2 28/28 зелёный, честная модель 28/28. Мутанты pgid_receipt, outside_receipt и lock_receipt исходная проба пропускает, а пробу с правкой они не проходят (R3).

Если Landlock тихо не применился, мутант outside_receipt проходит, и `--matrix` даёт rc 1. Значит, зелёная матрица сама доказывает, что ограничение включено. Недоступность Landlock — rc 2 (недоступный вход), не green.

### Нужна ли v+1 контракта
Да. Нужна текстовая правка в зоне architect; свойство :63 и инварианты 1–6 не меняются. Ложной стала прозa :71 «кроме MARK/GO/PGID и единственного канонического lock», и не определено пространство из :50 «во всех частных writable-каталогах». Production, README, 085/093 и зона implementer не меняются: честная реализация уже удовлетворяет ограничению (honest2 зелёная). Это правка пробы, а не новое требование к субъекту.

### Достижимо ли малой правкой
Да. В эксперименте backend.py +40/−3 строки (ctypes-Landlock, свип без имён, обнуление lock), probe.py +3 строки (частный TMPDIR). Живой systemd-run не нужен. Остаточного риска (cognitive-only) по этому пункту нет.

## Пункты правки для architect (обязательны)

П1. backend.py, ветка `systemd-run`, после `scope_created`, перед `os.execvp`: применить Landlock к процессу scope-команды (наследуется её потомками). Handled = WRITE_FILE, REMOVE_DIR, REMOVE_FILE, MAKE_CHAR/DIR/REG/SOCK/FIFO/BLOCK/SYM, плюс REFER при ABI≥2 и TRUNCATE при ABI≥3. Разрешение всех handled-прав — beneath home, volatile-state, частного TMPDIR и control; beneath /dev — только WRITE_FILE. Перед restrict_self — `PR_SET_NO_NEW_PRIVS`. Любой отказ syscall (ABI<1, ошибка ruleset/rule/restrict) — событие и путь к rc 2 всей пробы (NOT_IMPLEMENTED/недоступный вход), не тихое продолжение.

П2. backend.py, свип: перечень W задаётся ОДНИМ кортежем, общим для Landlock (П1) и свипа. Свип обходит W∖control (не весь root: LOG/STOP/входы пишет цикл ВНЕ scope, и в W их нет). Удаляется каждый объект не из baseline, без исключений по имени. `protected` = {канонический lock}; его inode сохраняется, содержимое перед свипом обнуляется (`os.truncate(lock, 0)`). Канарейки остаются, все внутри W.

П3. probe.py: в env субъекта добавить `TMPDIR=<root>/tmp` (каталог создаётся до baseline). XDG_RUNTIME_DIR НЕ перенаправлять: production его нормализует (orch-loop:186), и ограничение П1 закрывает его без перенаправления.

П4. probe.py MUTANTS: добавить со своими причинами на назначенных входах обоих путей:
`pgid_receipt` → removed_crash_1 'RESTART_COUNT';
`outside_receipt` (in-scope `: >"$OUT"`, где OUT — абсолютный путь вне root; проверка по `-e`) → marker_removed 'RESTART_COUNT';
`lock_receipt` (in-scope дописывает SCOPED в канонический lock; проверка по содержимому) → marker_removed 'RESTART_COUNT'.
Пример форм — /tmp/dev-harness-verify/arb997/exp/mut.py. `go_receipt` не обязателен: исходная проба уже ловит его семантикой GO (R3). Мутант outside_receipt обязан писать в одноразовый каталог, созданный пробой вне root и удаляемый ею, а не в общий /tmp.

П5. Контракт, текст:
- :50 — вместо «во всех частных writable-каталогах, кроме явно сохранённых объектов модели угроз» написать: «во всём пространстве записи scope-команды W (HOME, каталог MARK, частный TMPDIR); вне W проба запрещает scope-команде запись механизмом Landlock; удаляется каждый новый объект W без исключений по имени, у канонического lock сохраняется inode и обнуляется содержимое».
- :71 — исключение «кроме MARK/GO/PGID» удалить, описать то же самое; добавить: «Landlock недоступен → rc 2».
- НЕ ЗАЩИЩАЕТ, буллет MARK/GO/PGID — дописать: «последствия в их собственной семантике (приказ рестарта, reaping); подтверждение scope обязано переживать их удаление».
- Приёмочный критерий `--matrix` — назвать три новых мутанта.
:63, Frontier и инварианты не трогать.

П6. Прогнать гейты (precision/threat_model/provodka/consumers), `probe.sh --matrix` → rc 0, `probe.sh --cases` на до-997 → rc 1.

## Круг 3 критика — ЗАКРЫТЫЙ перечень (только это; FAIL после арбитра → к владельцу)

К1. Неизменённые субъекты критика на новой пробе: honest2 → `--cases` rc 0 (28/28); pgidwit → rc 1 с ложным отказом или RESTART_COUNT на сценариях свипа; outwit → rc 1.
К2. `--matrix` rc 0, и в ней пойманы pgid_receipt, outside_receipt, lock_receipt по назначенной причине, без SETUP_/TIMEOUT/INVALID_TOOL_CALL.
К3. По коду: в П1 и П2 один и тот же кортеж W. В свипе нет исключений по имени, кроме lock-inode (с обнулением). Отказ Landlock ведёт к rc 2, а не к продолжению.
К4. Текст :50/:71/НЕ ЗАЩИЩАЕТ согласован с П5; гейты rc 0; до-997 субъект красный.

ВНЕ перечня, блокером круга 3 не является (совет допустим):
- метаданные выживших объектов (xattr/mtime/mode у baseline-каталогов и lock-inode) — не класс Н-304 (unlink имени);
- «обратный» свидетель (отсутствие файла) — даёт ложное подтверждение, а не ложный отказ;
- запись в control через TOY_*-переменные — не конформный вход: «инвариантно к замене путей»;
- проброс fd настоящим systemd-run — уже cognitive-only по контракту;
- глубина `$(…)`/getppid — совет круга 2, его ловит 085 м5 в CI.

## Риск, который проверяется только в CI
[INFERENCE] Landlock на `ubuntu-latest` (ci.yml:32/97) с высокой вероятностью включён: в Ubuntu 24.04 он в списке LSM, на станции включён (замерено). С этого хоста CI не измерить. Первый прогон lane `check:orch-loop-997` и есть замер. Если там rc 2 по недоступности Landlock — К ВЛАДЕЛЬЦУ (выбор CI-хоста). Ослаблять пробу или пропускать lane нельзя.

## Счёт по сторонам
По существу оба пункта — критику. Средство для (а) выбрано не его (namespace), а Landlock, по замеру недоступности userns на станции. Автор конструкции не проиграл в выборе канала: pipe-конструкция подтверждена зелёной honest2.

## Сырой вывод

R1. Среда станции:
```
/sys/kernel/security/lsm: lockdown,capability,landlock,yama,apparmor
kernel.unprivileged_userns_clone = 1 ; kernel.apparmor_restrict_unprivileged_userns = 1
unshare -Urm sh -c 'mount -o remount,bind,ro /tmp' → unshare: write failed /proc/self/uid_map: Operation not permitted
command -v bwrap → (нет); strace 6.8 есть
```

R2. Одноразовая копия /tmp/dev-harness-verify/arb997/exp (Landlock в шиме, свип = W без имён, lock обнуляется, TMPDIR в дереве):
```
python3 probe.py --matrix                         → 997 observed=46 mismatches=0   (HONEST 28/28, MUTANT 18/18 caught=1)
--cases --subject critic997r2/subj/honest2        → 997 observed=28 mismatches=0
--cases --subject critic997r2/subj/pgidwit        → 997 observed=28 mismatches=12  marker_removed/removed_crash*/second_refused/bounded × same/other: rc 1 starts 1 [EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE]
--cases --subject critic997r2/subj/outwit         → 997 observed=28 mismatches=20  rc 1 starts 0 (свидетель вне W не создаётся)
```
Регресса уловов прежних кругов нет (та же копия): critic997r1 honest → mismatches=2 (lock_before_update ×2 [LOCK_STATE], как в круге 2); renamed → 14; rcwit → 6 (removed_crash_1, scope_refused_137 [REFUSAL], lock_before_update); marklock → 8 (duplicate/duplicate_mark [DUPLICATE], lock_held/lock_before_update).
Промежуточный замер — свип по всему root при Landlock: honest2 SETUP_NO_DELETION, потому что агент не может удалить LOG вне W. Поэтому свип обязан равняться W (П2), а не root.

R3. Новые формы (exp/mut.py) на исходной пробе (orig) и на копии с правкой (exp), входы marker_removed / removed_crash_1 / clean_exit × same/other:
```
orig pgid_receipt    rc 0 starts 2 []   (все 6)         exp pgid_receipt    marker_removed/removed_crash_1: rc 1 starts 1 [EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE]
orig outside_receipt rc 0 starts 2 []   (все 6)         exp outside_receipt rc 1 starts 0 (все 6)
orig lock_receipt    rc 0 starts 2 []   (все 6)         exp lock_receipt    marker_removed/removed_crash_1: rc 1 starts 1 [RESTART_COUNT,…]
orig go_receipt      rc 3 [EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE] — исходная проба уже ловит семантикой GO
```
Наблюдение без объяснения: exp lock_receipt на clean_exit тоже красный (rc 1, starts 1). Свип там не идёт, причину я не устанавливал. На решение это не влияет: мутант пойман на назначенном входе.

## Раскрытие
- Живой systemd-run, 085 и 093 не запускались. Пробы 997 работают только с PATH-заглушками во временных `orch997-*`.
- Основной чекаут не тронут, push не делался. Вердикт не закоммичен: по заданию он лежит в /tmp. Роль требует коммита под `user.name=arbiter`, но задание это исключает, так что коммитит оркестратор. Авторство: arbiter.
- Одноразовые файлы: /tmp/dev-harness-verify/arb997/exp/ (patch.py, mut.py, копия пробы) и /tmp/dev-harness-verify/arb997/w/ (свидетели outside_receipt исходного прогона) — это доказательства для круга 3, оставлены.
