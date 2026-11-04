FAIL
OBJECT=1598db13f58f0c28c83281a9cf702fdbf3a491cc
СУД: repo=dev-harness; предмет=155; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=1/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit155; модель-факт=openai-codex/gpt-6-sol (workstation); SHA=1598db13f58f0c28c83281a9cf702fdbf3a491cc; предыдущий=нет; исключение=нет. Автор Arch155 — zai/glm-5.3; семейства различны, независимость есть. Фактический платный trace/session-id сверяет оркестратор до материализации.

## Блокирующие классы

БЛОКИРУЕТ contracts/155-dopusk-pamyati-zamok.md:34,146 — эталон FIFO сравнивает остаток с заявкой головы, но не даёт ей преимущественного права старта; a04 проверяет только нехватку для головы.
ОБЯЗАТЕЛЬСТВО: «младший не перепрыгивает живую голову» (И-4; модель угроз).
КЛАСС ПРИЧИНЫ: неверный предикат очередности в критерии и эталоне.
СОСТОЯНИЕ: старшая живая запись seq=1 ждёт 4 GiB до будущего deadline; остаток 5 GiB; младший запрашивает 4 GiB до следующего poll старшего.
НАБЛЮДЕНИЕ: эталон даёт младшему rc 0 `DOPUSK: PUSCHEM`, оставляя старшую запись на месте; `W --model` тем не менее 22/22 rc 0.
ОБХОД: реализация с предикатом эталона проходит все 22 клетки, но младший стартует прежде живой головы.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при живой старшей записи поздний запрос не стартует раньше обслуживания/истечения старшего; красный случай проверяет этот порядок, когда остатка хватает голове, а не только когда его не хватает.

БЛОКИРУЕТ contracts/155-dopusk-pamyati-zamok.md:34,146 — после удачного ожидания эталон оставляет свою запись в очереди, а a03 судит только rc/строку, не послесостояние.
ОБЯЗАТЕЛЬСТВО: «своя запись убирается при любом исходе» (строка 146).
КЛАСС ПРИЧИНЫ: ветка успешного выхода из poll возвращается без удаления записи; отсутствует красный послесостоянийный случай.
СОСТОЯНИЕ: остаток 2 GiB → агент с заявкой 4 GiB встал в очередь → остаток стал 8 GiB до deadline.
НАБЛЮДЕНИЕ: rc 0 `DOPUSK: PUSCHEM ... (ochered)` и оставшийся `0000000001-...` с будущим deadline; последующие запросы видят фиктивную живую голову.
ОБХОД: копия эталона в поставленной двери зелена по `W`, несмотря на оставление записи после успешного ожидания.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: на успешном выходе из ожидания своя запись исчезает под мьютексом; красная клетка проверяет очередь после rc 0.

БЛОКИРУЕТ contracts/155-dopusk-pamyati-zamok.md:38,45,51 — c01 и p03 принимают `-p OOMPolicy=continue` в комментарии; p03 запускает собственный systemd-run, а не действующий scope поставленного `orch-loop`.
ОБЯЗАТЕЛЬСТВО: именно поставленный `orch-loop` передаёт `OOMPolicy=continue` вместе с MemoryMax/MemorySwapMax=0 (И-8).
КЛАСС ПРИЧИНЫ: текстовый литерал и независимая демонстрация вместо исполняемой команды субъекта.
СОСТОЯНИЕ: в поставленном файле действующий `SCOPE=(systemd-run --user --scope -q -p "MemoryMax=$MEM_MAX" -p MemorySwapMax=0)`; строкой выше — инертный `# -p OOMPolicy=continue`; обе двери поставлены из моделей.
НАБЛЮДЕНИЕ: безфлаговый `W` rc 0, c01/c02 OK, 22/22; исполняемый SCOPE без OOMPolicy. Падение отдельного процесса может по-прежнему остановить scope (исходный дефект).
ОБХОД: комментарий удовлетворяет всем литеральным проверкам, в том числе p03, без установки флага в юнит.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: доказать действующий аргумент при реальном запуске SCOPE поставленного `orch-loop`, с негативным случаем «флаг только в комментарии».

БЛОКИРУЕТ contracts/155-dopusk-pamyati-zamok.md:31,51,159 — p02 проверяет строки файла `spawn-guard.ts`, а не выполнение хука; вставка одного инертного комментария перед маркером 140 удовлетворяет всем её проверкам при отсутствии вызова допуска.
ОБЯЗАТЕЛЬСТВО: алфавит 104 → допуск 155 → замок 140 на gated `tool_call('task')`; отказ/поломка допуска блокирует спавн без занятия замка; каталог cgroup берётся из собственного `/proc/self/cgroup` (И-1/И-2).
КЛАСС ПРИЧИНЫ: проверка интеграции по grep вместо наблюдения точечного поведения; `W` вовсе не включает хук в три носителя.
СОСТОЯНИЕ: прежний хук 140, перед `// [ZAMOK140] начало блока вызова двери` добавлен только комментарий `// [DOPUSK155] /proc/self/cgroup dopusk_pamyati.sh (inert comment)`.
НАБЛЮДЕНИЕ: все пять фактических предикатов p02 истинны; исходный хук не содержит вызова `dopusk_pamyati.sh`. [INFERENCE] Такой хук пропустит gated-task мимо допуска при остальных поставленных носителях.
ОБХОД: p02 и `W` могут быть зелёными при неподключённой двери, тогда как замороженная 140/1 предъявляла поведенческие станционные случаи через обработчик tool_call и негативный m01 для собственного блока.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: поведенческий станционный случай вызывает обработчик `tool_call('task')` и различает порядок алфавита, блок на rc1/rc2 допуска без START замка, собственный cgroup и инертный блок.

БЛОКИРУЕТ contracts/155-dopusk-pamyati-zamok.md:39,41-51 — обязательный профиль гигиены 041 объявлен, но ни один пункт приёмки не называет команду с требуемым rc для его батареи; `W`, станционная команда и перечисленные гейты не вызывают `run_battery.sh dopusk_pamyati`.
ОБЯЗАТЕЛЬСТВО: профиль новой парсящей двери существует и проходит четыре класса гигиены (И-9; норма 041).
КЛАСС ПРИЧИНЫ: отсутствует обязательное доказательство, не преждевременное требование реализовать профиль до заморозки.
СОСТОЯНИЕ: будущая поставленная дверь без профиля при зелёных 22/22; в текущем кандидате профиль отсутствует как и положено до реализации.
НАБЛЮДЕНИЕ: отдельная штатная команда `bash fixtures/parsing_hygiene_battery/run_battery.sh dopusk_pamyati` возвращает rc 2 `NOT_IMPLEMENTED: профиль не найден`; её rc не участвует в названной приёмке 155.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: назвать исполняемую команду с обязательным rc 0 для профиля новой двери, чтобы отсутствие/красный профиль не позволяло объявить done.

## Сырой вывод негативных образцов

Команды запускаются в изолированном архиве OBJECT, с отдельными временными мирами. `git init/fetch` добавляли историю только в архиве ради гейтов; основной чекаут не менялся. Все дочерние процессы дождались выхода; временные копии удалены.

`python3 /tmp/dev-harness-verify/Crit155/queue_counterexample.py` → rc 0:
```
CASE: older live entry queued for 4GiB, budget 5GiB, newcomer requests 4GiB
command: bash /tmp/dev-harness-verify/Crit155/repo/fixtures/workshop_project/dopusk_pamyati_155/model/dopusk_pamyati.sh --sudit --sostojanie /tmp/critic155-queue-ughlob4y/sost --cgroup /tmp/critic155-queue-ughlob4y/cg --timeout 1 /tmp/critic155-queue-ughlob4y/event.json
rc: 0 stdout: DOPUSK: PUSCHEM gated=1 zajavka=4294967296 stderr:
older_entry_still_waiting: True
```
`python3 /tmp/dev-harness-verify/Crit155/queue_cleanup_counterexample.py` → rc 0:
```
CASE: waiting door enqueued at 2GiB remaining; budget becomes 8GiB before deadline
rc: 0 stdout: DOPUSK: PUSCHEM gated=1 zajavka=4294967296 (ochered) stderr:
remaining_records_after_success: ['0000000001-1633643-30034']
```
`python3 /tmp/dev-harness-verify/Crit155/unit_counterexample.py` → rc 0, безфлаговый `W` во временной копии с двумя моделями-дверями и инертным флагом в юните:
```
COMMAND: bash fixtures/workshop_project/dopusk_pamyati_155/red_dopusk_pamyati_155.sh
CANDIDATE_SCOPE: SCOPE=(systemd-run --user --scope -q -p "MemoryMax=$MEM_MAX" -p MemorySwapMax=0)
KLETKA a01-dostatok-pusk OK
KLETKA a02-nekhvatka-ochered-tajmaut OK
KLETKA a03-svobodilos-v-ozhidanii OK
KLETKA a04-fifo-starshij-vperedi OK
KLETKA a05-istekshaya-ne-golodaet OK
KLETKA a06-bez-potolka-pusk OK
KLETKA a07-schetchiki-nedostupny OK
KLETKA a08-batch-zayavka OK
KLETKA a09-postoronnie-propusk OK
KLETKA a10-current-vyshe-potolka OK
KLETKA b01-pogib-avto-snyatie OK
KLETKA b02-pogib-osvobodit OK
KLETKA b03-roditel-dispose-ne-snimaet OK
KLETKA b04-vozrast-ne-smert OK
KLETKA b04b-broshen-vetka-e-140 OK
KLETKA b05-yield-do-vyhoda-sudya OK
KLETKA b06-pogibshij-avtor-sudya-net OK
KLETKA b07-oom-ne-put OK
KLETKA b08-sessionid-pid-v-zapisi OK
KLETKA b09-uchet-pogib OK
KLETKA c01-oompolicy-v-yunte OK
KLETKA c02-potolki-sohraneny OK
ZELENO: клеток 22, zelenyh 22
rc: 0
```
`python3 /tmp/dev-harness-verify/Crit155/guard_counterexample.py` → rc 0:
```
p02_string_predicates: [True, True, True, True, True]
actual_runtime_dopusk_call: False (only the inserted comment mentions dopusk_pamyati.sh)
```

## Штатные измерения

- `bash fixtures/workshop_project/dopusk_pamyati_155/red_dopusk_pamyati_155.sh`: rc 1, `KRASNO: клеток 22, красных 16` (a01–a10 SUBJECT_ABSENT, b01/b02/b06/b08/b09, c01). Та же команда `--model`: rc 0, `ZELENO: клеток 22, zelenyh 22`; `--stabs`: rc 0, 14 строк `STAB d01`–`d14: kletok 1, pojmannyh 1`, `SUBJEKT_SVJAZI 14, zhivyh 0`; `--oracle-tamper`: rc 0, `ORACLE_TAMPER_PROVERENO nositelej=3`.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh`: rc 1, `KLETKI 66 KRASNYH 3` (u01/w20/w21). Модель дельты 155 в позиции `scripts/zamok_predmeta.sh` дала те же rc 1, 66/3, без дополнительных красных. Прочитан `frozen/contracts/140/1`.
- `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit155/repo contracts/155-dopusk-pamyati-zamok.md`: rc 0 `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit155/repo contracts/155-dopusk-pamyati-zamok.md`: rc 0 `OK`; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit155/repo contracts/155-dopusk-pamyati-zamok.md`: rc 0 `OK`; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit155/repo contracts/155-dopusk-pamyati-zamok.md`: rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 7 буллет(ов))`.
- `bash scripts/check_ceilings.sh`: rc 1, единственное нарушение — чужая заглушка `contracts/156-agent-fon-zakrytie.md (86 байт): нет раздела «Незаполненные требования:»`; контракт 155 не красный. `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit155/repo contracts/155-dopusk-pamyati-zamok.md`: rc 1 `проводка: guard не подключён`, ожидаемо до проводки оркестратором. `bash fixtures/parsing_hygiene_battery/run_battery.sh dopusk_pamyati`: rc 2 `NOT_IMPLEMENTED: профиль не найден`, ожидаемо до реализации.
- `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit155/repo`: полный прогон завершился за 624.85 с, вывод без FAIL: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 43972 · проверено по зонам: 10438`. Асинхронный результат не показал отдельный код возврата, потому зелёный rc 0 не утверждается.

## Не проверено

Живой omp-спавн и собственный cgroup на станции, действительное systemd OOM и предел блокирующего tool_call; p03 на реальной станции не запускался (OOM-проба неуместна до реализации). Дверь 155 пока не поставлена. Платный trace фактической модели и session-id доступен оркестратору, а не этой сессии; здесь наблюдались только `Crit155` и workstation `openai-codex/gpt-6-sol`.
