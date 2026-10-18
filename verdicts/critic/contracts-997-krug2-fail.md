FAIL
OBJECT=19eaea97ad814d739be43bb29f441cca78de5259
Критик, круг 2, контракт 997 (Н-304), класс КОДОВЫЙ. Клон ssh://git@github.com/a3ka/dev-harness.git → /tmp/dev-harness-verify/critic997r2/clone, checkout 19eaea97 (wip/997/architect). Вердикт круга 1 прочитан из 4ebcfe44:verdicts/critic/contracts-997-krug1-fail.md.

АРБИТР: arbiter — созываю сам: это второй `FAIL` по причине класса Б2 круга 1 («файловый свидетель под другим именем/в другом каталоге проходит пробу»). Предмет спора: закрывает ли свип «все новые файлы частного дерева, кроме MARK/GO/PGID/lock» свойство из ЗАЩИЩАЕТ :63 «независимо от его имени/каталога», если файловый свидетель в защищённом имени (`$MARK.pgid`) или вне частного дерева проходит `probe.sh --cases` 28/28. Если нет — надо решить, какой механизм доказывает это свойство: изоляция записи субъекта или свип без исключений в сценариях removed_crash*. Это инженерный спор, не вопрос воли владельца.
Раскрытие: исключение «MARK/GO/PGID/lock» из свипа предложил я сам, в обобщённой починке круга 1 (п.1). Автор его выполнил. Обход 1 ниже проходит именно через это исключение, обход 2 — мимо него. Это мой недосмотр в круге 1. Блокирует находка потому, что свойство из принятого требования осталось недоказанным, а не потому, что автор нарушил мою формулировку.

## Итог по трём вопросам задания

(1) Закрыты ли Б1–Б3 ОБОБЩЁННО.
- Б1 (rc-признак scope) — да. Rc агента 1/137 (removed_crash_1/_137) совпадает с rc отказа launcher 1/137 (scope_refused/_137). Поэтому никакой оракул по rc эти две стороны не разделяет, сама конструкция это исключает. В отказ добавлен stdout `SCOPED`, так что stdout-свидетель тоже пойман. Мой rcwit круга 1 красный (R2: removed_crash_1 и scope_refused_137, оба uid).
- Б3 (lock по шву) — да. `lock_held` держит flock проверяющего на каноническом пути и проверяет ключ чёрным ящиком: ключ, производный от любого шва, не проходит. Отдельно варьируются MARK, LOG и оба вместе. Мой marklock красный, 8/28 (R2).
- Б2 (файловая метка под другим именем) — нет, закрыт частично. Конкретное имя `.ran` теперь ловится (renamed красный, 14/28), но сам класс не закрыт. Свип покрывает только частное дерево `/tmp/orch997-*` без защищённого набора (backend.py:76–85), и файловый свидетель вне этого множества проходит (блокер ниже).

(2) Неизменённая honest-реализация критика (subj/honest круга 1, sha256 5efef05d…). Она красная ЧЕСТНО на 2/28: `lock_before_update` same/other, причина LOCK_STATE. Вывод показывает, что installer вызывался ДО singleton-отказа: «ОТКАЗ: цикл из репо не установлен…», затем «расхождение с репо:», затем «ОТКАЗ: orch-loop уже запущен». В моей реализации lock стоял после self-update (orch-loop:56–72), а это нарушение инв.5 в нынешней редакции. После переноса одной строки lock сразу за `cd "$REPO"` (subj/honest2) результат — 28/28, rc 0. На копии пробы с удалением `.pgid` (R4) тоже 28/28 на обоих uid. Ложных красных у честной реализации нет.

(3) Обход есть. Это ровно ложный отказ «запуск в scope не подтверждён» у отработавшего scope, класс Н-304: блокер ниже.

## Блокер

БЛОКИРУЕТ contracts/997-orch-loop-metka-perezapuska.md:50 (против :5 «факт запуска в scope хранится вне удаляемого файлового имени», :63 «при unlink файлового свидетеля независимо от его имени/каталога», :36 «токен не берётся из … файла», :25 отклонённый «перенос .scoped в state-dir») — критерий `marker_removed`/`removed_crash*` удаляет только новые файлы частного дерева пробы, кроме MARK/GO/PGID/lock (fixtures/ops_server/orch_loop_997/backend.py:76–85; :71 контракта). Свойство «независимо от имени/каталога» поэтому не наблюдается. Файловый свидетель, лежащий в любом пути, который переживает свип, неотличим от анонимного канала. Б2 круга 1 повторяется классом, а не экземпляром.
ОБХОД: production `ops/server/user/orch-loop` = до-997 файл RAN. Правки только такие: lock перед self-update, `) 9>&- &` у наблюдателя, payload инв.4, и одна строка — путь свидетеля.
  (а) subj/outwit: `RAN="/tmp/dev-harness-verify/critic997r2/w/orch-$loop_pid.scoped"`. Это любой каталог вне частного дерева пробы, в production естественно взять `$XDG_RUNTIME_DIR`, который orch-loop:184 ставит в `/run/user/$(id -u)`. Получается `probe.py --cases --subject outwit` → `997 observed=28 mismatches=0`, rc 0 (R3). Это отклонённый Frontier :25 буквально.
  (б) subj/pgidwit: `RAN="$PGID"`, то есть `$MARK.pgid`, имя из защищённого набора свипа. Same-uid путь создаёт его изнутри scope (`: >"$1"`, как раньше RAN), other-uid путь уже пишет туда pgid изнутри scope (orch-loop:225). Результат: `--cases` → 28/28, rc 0 (R3).
  Предмет при этом не сделан. В обоих субъектах факт запуска хранится в удаляемом файловом имени. В Н-304 удалили соседа MARK `orch-restart.scoped`, а `orch-restart.pgid` лежит в том же каталоге и создаётся в тот же момент. На копии пробы, где свип удаляет и `.pgid` (R4), pgidwit даёт loop rc 1, один агент и строку «сессия #1: запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)» на 12/28: marker_removed, removed_crash, removed_crash_1, removed_crash_137, second_refused, bounded, оба uid. Это ложный отказ при отработавшем scope, станция стоит. honest2 на том же входе зелёный, 28/28. Для outwit механизм тот же, что у до-997: удаление свидетеля приводит к отказу. Сам до-997 на marker_removed/removed_crash* красный (R1), outwit отличается от него только путём (диф R3). [INFERENCE: живое удаление вне частного дерева я не исполнял, чтобы не писать в /run/user станции.]

Обобщённая починка (по §3 решения 18.10). Мой вариант не обязателен, но свойство обязано наблюдаться:
1. Для субъекта не должно остаться записываемого пути, который переживает свип. Вариант: запуск субъекта в mount-namespace (unshare/bwrap), где вне частного дерева всё только для чтения, и тогда запись свидетеля вне дерева — ошибка, видимая как отказ. Если изоляция недоступна, это rc 2 «недоступный вход», а не green.
2. В сценариях, где семантика MARK/GO/PGID для перехода не нужна (removed_crash, removed_crash_1, removed_crash_137, где MARK нет, а агент выходит сам), удалять и защищённый набор, включая `$MARK.pgid`. Это измерено: удаление `.pgid` во всех свип-сценариях оставляет honest2 зелёным на обоих uid (R4), ложных красных у честной реализации нет. Содержимое канонического lock в этих сценариях стоит обнулять тем же правилом: удалять inode запрещает :28, а лежать там receipt может.
3. Мутанты `pgid_receipt` и `outside_receipt` (или их обобщение) — в MUTANTS probe.py со своей причиной, иначе `--matrix` не докажет, что усиление ловит.

## Советы (accept не отменяют)

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:37 — инв.3 «`$(…)` вокруг запуска не допускается / systemd-run — прямой ребёнок цикла» пробой 997 не наблюдается. Моя honest/honest2 построена на `receipt="$(… systemd-run …)"` и проходит 28/28. Ловит это только 085 м5, а она по :57 идёт в CI/на изолированном хосте. Дёшево исправить так: backend пишет `os.getppid()` в событие `scope_call`, проба сравнивает его с pid цикла (`exec "$0"` pid не меняет).

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:39/:54 — оценка инварианта lock_before_update, который сделан из моего совета круга 1. Перенос правильный. Вред назван: второй ручной запуск, пока идёт GRACE, стирает MARK первого или переустанавливает цикл. Различимость измерена: мутанты late_lock и late_update_lock пойманы по LOCK_STATE, честная реализация с lock после self-update честно красная, а перенос одной строки делает её зелёной. Остаток: заглушка installer выходит с rc 1 (probe.py, `install.sh` stub), поэтому успешный `ORCH_SELF_UPDATED=1 exec "$installed"` под удерживаемым lock не исполняется ни одним сценарием. «Собственный exec не принимается за конкурента» доказано только для перехода `exec "$0"` (marker_removed). На станции self-update после git pull идёт на каждом переходе, поэтому стоит добавить случай с успешной установкой: заглушка копирует кандидата и выходит с rc 0, ожидается один агент и rc 0.

СОВЕТ contracts/997-orch-loop-metka-perezapuska.md:71 — фраза «Эти входы — не разрешение субъекту хранить в них receipt» верна, но держится только прозой. После починки блокера её стоит связать с механизмом (п.1–2 выше).

## Гейты (R0)

```
check_precision_gate.sh <клон> contracts/997-…md   OK                                                rc=0
check_threat_model.sh                              секция валидна (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 3)        rc=0
check_provodka.sh                                                                                    rc=0
check_consumers.sh                                                                                   rc=0
check_zones.sh                                     замороженных контрактов: 102 · проверено по зонам: 2993  rc=0
```

## Сырой вывод

R1. Проба автора на 19eaea97:
```
python3 probe.py --matrix          → 997 observed=46 mismatches=0  rc=0   (HONEST 28/28 errors=[]; MUTANT 18/18 caught=1)
python3 probe.py --cases (до-997)  → 997 observed=28 mismatches=28 rc=1   (marker_removed/removed_crash*: RESTART_COUNT,EXIT_STATUS,TRUTHFUL_SCOPE; duplicate*: DUPLICATE; lock_*: LOCK_PATH,LOCK_STATE; clean_exit: TRUTHFUL_SCOPE)
```

R2. Субъекты круга 1 без изменений (`probe.py --cases --subject /tmp/dev-harness-verify/critic997r2/subj/<s>`):
```
honest   observed=28 mismatches=2  rc=1   lock_before_update same/other ['LOCK_STATE']
rcwit    observed=28 mismatches=6  rc=1   removed_crash_1 [EXIT_STATUS,RESTART_COUNT,TRUTHFUL_SCOPE]; scope_refused_137 rc 137 calls 3 [REFUSAL]; lock_before_update
renamed  observed=28 mismatches=14 rc=1   marker_removed/removed_crash*/second_refused/bounded …
marklock observed=28 mismatches=8  rc=1   duplicate/duplicate_mark second_rc=still-running starts 2 [DUPLICATE]; lock_held/lock_before_update [LOCK_PATH,LOCK_STATE,…]
leakfd   observed=28 mismatches=14 rc=1
```

R3. Субъекты круга 2 (/tmp/dev-harness-verify/critic997r2/mk2.py и правка outwit), проба автора без изменений:
```
honest2  observed=28 mismatches=0 rc=0
pgidwit  observed=28 mismatches=0 rc=0
outwit   observed=28 mismatches=0 rc=0
```
Диф outwit против до-997 ops/server/user/orch-loop (полный):
```
49a50  > mkdir -p "$HOME/.local/state/dev-harness" && exec 9>>"$HOME/.local/state/dev-harness/orch-loop.lock" && flock -n 9 || { log "ОТКАЗ: orch-loop уже запущен"; exit 1; }
166c167 <   done ) &   >   done ) 9>&- &
195c196 < RAN="$MARK.scoped"; …   > RAN="/tmp/dev-harness-verify/critic997r2/w/orch-$loop_pid.scoped"; PGID="$MARK.pgid"; rm -f "$RAN" "$PGID"
231c232 < ресурсный предел не создан …   > запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)
236a238 > log "сессия #$n: scope подтверждён (канал запуска); файловая метка не используется"
```
У pgidwit вместо строки 195: `PGID="$MARK.pgid"; RAN="$PGID"; rm -f "$PGID"`; у other-uid убран `&& : >"$1"`; убран `rm -f "$RAN"` после подтверждения (reap_session продолжает читать pgid).

R4. Одноразовая копия пробы /tmp/dev-harness-verify/critic997r2/harm/. Единственная правка — `'.pgid'` убран из `protected` (backend.py:76):
```
honest2  observed=28 mismatches=0  rc=0
pgidwit  observed=28 mismatches=12 rc=1   marker_removed, removed_crash, removed_crash_1, removed_crash_137, second_refused, bounded × same/other: rc 1 starts 1 calls 1
         "сессия #1: запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)"
```

## Раскрытие

- Живой systemd-run не вызывался: 085/093 в этом круге не прогонялись, пробы 997 работают только с PATH-заглушками. Основной чекаут не тронут, push не делался, вердикт не закоммичен (коммит делает оркестратор).
- Временные каталоги `/tmp/orch997-*` после проб: 0, процессов проб не осталось (pgrep пуст). Свидетель outwit жил только в /tmp/dev-harness-verify/critic997r2/w/ и удалён самим субъектом.
