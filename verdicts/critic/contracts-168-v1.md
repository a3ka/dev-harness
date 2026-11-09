accept
OBJECT=6cd386d3e3e341cce7a3b94066b8ca3ee22def0f

СУД: repo=dev-harness; предмет=168; фаза=freeze(до); роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit168; модель-факт=zai/glm-5.3; SHA=6cd386d3e3e341cce7a3b94066b8ca3ee22def0f; предыдущий=нет; исключение=нет

Клон: ssh://git@github.com/a3ka/dev-harness.git → /tmp/dev-harness-verify/Crit168/c168crit1794197890/repo, checkout detached 6cd386d3e. `git diff 6cd386d3e 068f5da4a -- contracts/168* fixtures/workshop_project/izveshchenie_168` пуст (0 байт) — дерево контракта и батареи на OBJECT идентично origin/main после влития ленда.

## Набор артефактов

Полн: предмет есть (§Предмет и граница), критерий готовности с rc-командами есть (§Приёмочный критерий), исполнители названы (ЗОНА-строки implementer/architect/critic/reviewer/orchestrator + Порядок), ЗОНА-строки читаются check_zones-грамматикой (precision-гейт 043 парсит и зелёный). Разбирал по существу.

## Обязательные прогоны (сырой вывод)

`bash scripts/pre_critic.sh --repo . contracts/168-izveshchenie-proektov-o-mekhanizmakh.md`:
```
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
RC=0
```

`bash fixtures/workshop_project/izveshchenie_168/red_izveshchenie_168.sh` (до реализации, ожидаемо красный):
```
BRIEF_NOTICES_MISSING: rc=0 stderr= rows=[] expected=['NOTICE\t1\t2026-11-08\t161\t…']
BRIEF_ACK_WRONG: rc=0 …
BRIEF_ACK_LATEST_WRONG: rc=0 …
BRIEF_ACK_INVALID_ACCEPTED: rc=0 stderr=
BRIEF_PROJECT_ISOLATION_WRONG: rc=0 …
LAND_WRITER_NOT_GATED: rc=0 stderr=
LAND_WRITER_MUTATED_MAIN
DONE_WRITER_NOT_GATED: rc=0 stderr=
DONE_WRITER_CREATED_TAG
STATION_LAND_WRITER_NOT_GATED: rc=0 stderr=
STATION_LAND_WRITER_MUTATED_MAIN
STATION_DONE_WRITER_NOT_GATED: rc=0 stderr=
STATION_DONE_WRITER_CREATED_TAG
RC=1
```
Обе ветви предмета красны на ПУБЛИЧНОМ шве: бриф — настоящий `make_task --kind brief` (5 клеток), писатели — `land_project.sh`/`done_contract.sh` проекта и `land_agent.sh`/`done_contract.sh` станции (8 клеток; контроль побочного эффекта и тега включён).

`python3 fixtures/workshop_project/izveshchenie_168/probe.py --model`:
```
BRIEF pending ok / BRIEF acknowledged ok / BRIEF isolated ok / BRIEF third project ok /
BRIEF malformed ack ok / LAND covered ok / LAND missing ok / DONE missing ok / LAND unrelated ok
MODEL_RC=0
```

`python3 …/probe.py --stabs`:
```
STAB empty_brief caught: brief
STAB all_old caught: brief
STAB all_projects caught: brief
STAB last_only caught: brief
STAB ack_zero_default caught: brief
STAB truncated caught: brief
STAB allow_missing caught: land
STAB done_only caught: land
STAB land_only caught: done
STABS_RC=0
```
Н-39: привязка стаб→ветвь — КОДОМ probe.py, не прозой: `stabs()` (probe.py:93-107) несёт отдельный вход-кортеж на каждого мутанта, ветви — в `model()` (probe.py:33-54); живой прогон различил всех 9. Проза контракта имён обманок не предписывает (критерий, строка 39) — соответствует.

Механические гейты норм: `check_precision_gate.sh . contracts/168-…` → `OK` rc 0 (зона-коллизии против union живых заморозок, live-прогон по норме 043; выборочная сверка: implementer-владельцы scripts/make_task.sh в union — 095/103/136/161/166/996, все тем же автором implementer, что заявляет 168, коллизии авторов нет). `check_threat_model.sh` → «секция валидна (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 2)» rc 0. `check_provodka.sh` → rc 1 «guard не подключён: … не вызывается в .githooks/ или .github/workflows/» — ожидаемо и запланировано самим контрактом (строка 40: CI-строка фиксируется orchestrator ПОСЛЕ ленда реализации, rc 0 требуется «перед done»); прецедент 083 допускает подключение реализационной пачкой.

## Мои мутации против красной батареи (одноразовый клон, затем `git checkout -- scripts/`)

Мутант A — «ослабь проверку полного NOTICE»: обманный стаб `make_task` печатает секцию NOTICES с УСЕЧЁННЫМИ строками `NOTICE<TAB>record_id` (полные поля не выдаёт), ack-семантика честная. Патчер: /tmp/dev-harness-verify/Crit168/c168crit1794197890/mutantA2.py (вставка после REPO_ABS + печать в хвосте: штатный EXIT-trap make_task:498 перетирает trap-вариант — поэтому хвост). Сырой вывод `probe.py --repo`:
```
BRIEF_ACK_LATEST_WRONG ok
BRIEF_NOTICES_MISSING: rc=0 stderr= rows=['NOTICE\t1', 'NOTICE\t2'] expected=['NOTICE\t1\t2026-11-08\t161\tscripts/make_task.sh,scripts/spawn_agent.sh\t…']
BRIEF_ACK_WRONG: rc=0 stderr= rows=['NOTICE\t2'] expected=['NOTICE\t2\t2026-11-08\t166\t…']
BRIEF_PROJECT_ISOLATION_WRONG: rc=0 stderr= rows=['NOTICE\t3'] expected=['NOTICE\t3\t…167\t…']
(писатели — красны, реализация отсутствует)
MUTANT_A2_RC=1
```
ПОЙМАН: три клетки брифа красны именно усечением (ack-контроль зелёный — изоляция атаки точная). Полная строка внутри секции — работающее требование.

Мутант B — «удали побочный эффект» (снятие свойства «HEAD/индекс неизменны при отказе»): обманный стаб `land_agent` станции даёт ПРАВИЛЬНЫЙ отказ rc 1 `MECHANISM_NOTICE_MISSING:scripts/spawn_agent.sh` и ПРАВИЛЬНО пропускает при наличии записи (падает в штатный поток, позитивная пара зелёная), НО перед отказом делает пустой коммит в main. Патчер: mutantB.py (вставка после `g()` в land_agent.sh). Сырой вывод `probe.py --repo`:
```
STATION_LAND_WRITER_NOT_GATED — исчез (отказ верный: rc 1 + сообщение)
STATION_LAND_WRITER_MUTATED_MAIN   ← КРАСНА: snapshot ловит побочный эффект
STATION_LAND_RECORDED_REFUSED — отсутствует (запись уважена, ленд прошёл rc 0)
(бриф/остальные писатели — красны, реализация отсутствует)
MUTANT_B_RC=1
```
ПОЙМАН клеткой побочного эффекта при зелёных остальных станционных клетках.

Дополнительно проверен обман «писатель отказывает ВСЕГДА» (blanket refusal): для land_agent ловится собственной позитивной парой батареи (STATION_LAND_RECORDED_REFUSED), для land_project/done_contract — замороженными соседями (063 клетка к8 зелёный ленд; 038 green_D6/D10/G — тег done ставится; 016 case_vetka_perezhila — rc 0), т.е. CI-побег нет. См. совет 1.

## Семена и «Существующее»

- seed.tsv: три отдельные записи 1/2/3, контракт 161/166/167, record_id возрастают, полей шесть, TAB-разделение — заголовок совпадает с грамматикой контракта дословно.
- correct_invocation сверены с живыми источниками: 161 — дословно контракта 161:15 (`make_task … --kind task; spawn_agent --root … --nnn … --author architect`); 167 — дословно usage zamok_predmeta.sh:23 (`--osvobodit --sostojание D --zhurnaly D --repo R <NNN> <holder>`); 166 — публичный CLI make_task (`--role critic … --kind task`) существует.
- affected_scripts совпадают с зонами implementer соответствующих контрактов (161: make_task+spawn_agent; 166: make_task; 167: zamok_predmeta).
- Независимость записей: наличие строки 161 не закрывает изменение 166 — проверено клеткой 'LAND missing' модели (журнал 166/167 не покрывает spawn_agent) и 'BRIEF third project'; ожидания сняты в память до вызова субъекта (`records()` до `real_world`) — по коду.
- «Существующее»: make_task `--kind brief` реально формирует TRACE/MAP/RULES/REUSE/WORK/HEALTH (наблюдалось сырым stdout); project_paths_resolve в next_id.sh (17 вхождений), profile_resolver.sh и check_merge_gate.sh существуют; registry/contracts.tsv — «N → sha»; ci-steps.tsv — источник CI-шагов; World-генератор 161 импортируется батареей 168 напрямую. Памятка m1033 в репозитории ОТСУТСТВЕТ (grep по клону и основному чекауту — только упоминание в самом контракте:18); сверять семена мог только по контрактам и git-истории, новых фактов о её содержимом не выдумываю.

## Механические расхождения — полный список (слово владельца 2026-10-31)

1. seed.tsv:2 — дата записи 161 = 2026-11-08; по git последнее изменение механизмов 161 (make_task.sh/spawn_agent.sh контрактом 161) — 2026-11-07 21:45, ленд implementer-r7 — 2026-11-07 22:52; записей 166/167 даты совпадают (2026-11-08 01:03 / 03:27+). Т.к. бриф-клетки сверяют станционный журнал с seed.tsv байт-в-байт, реализация перенесёт дату семени в append-only production-реестр, где её нельзя переписать. Если семантика m1033 — «дата изменения механизма», запись 1 должна быть 2026-11-07; если иная — она в контракте не названа и неверифицируема.
2. contracts/168…:11 — «PR … не обнаружен»: на момент суда тот же поиск выдаёт и PR #620 «168: черновик контракта (извещение проектов) и красные пробы» (MERGED 2026-11-09) — это PR доставки самого предмета, не конкурирующее prior art; расхождение по букве, отсутствие дубликата предмета подтверждено.

Прочие числовые/механические утверждения (колонки реестра, зоны, ПЕРЕСЕЧЕНИЕ-списки, CLI-подписи, счёт команд red-скрипта «три независимые», клетки 5+8) сверены и расхождений не имеют.

## Находки

СОВЕТ contracts/168-…:38 — обещанные «парные положительные входы… rc 0» на публичном шве предъявлены батареей лишь для station land_agent с записью (STATION_LAND_RECORDED); позитивные пары land_project/done_contract и вход «с неиспользуемым скриптом» живут только в --model ('LAND covered'/'LAND unrelated'). Blanket-refuse ловят замороженные соседи (проверено: 063 к8, 038 D6/D10/G, 016 vetka_perezhila), но собственная батарея различия не несёт; перебор-отказ на неиспользуемом скрипте за пределами --model не ловит ни одна клетка (соседи-игрушки меняют scripts/* без usage-манифеста и ловят лишь тотальный перебор). По §Порог это специально добавленный запрет/новая ветвь — совет, не блок: одна клетка «изменён неиспользуемый скрипт → писатель rc 0» закрыла бы обещание локально.

СОВЕТ contracts/168-…:18 + seed.tsv:2 — дата записи 161 (см. расхождение 1): закрыть одной строкой seed.tsv (2026-11-07) либо назвать в контракте семантику даты m1033, сделав её проверяемой; реестр append-only, задним числом не исправить.

СОВЕТ contracts/168-…:17 — грамматика журнала (неполная/лишняя колонка, дубль ключа, обрыв строки без завершающего LF, TAB/CR/LF в полях, «дата календарно валидна») объявлена именованными отказами парсера, но не имеет ни одной красной клетки (батарея/модель/стабы подают только валидный журнал). Пункт предмета без доказывающей команды; одна клетка с малформированным журналом (ожидание именованного отказа, не тихого пропуска) закрыла бы.

СОВЕТ contracts/168-…:11 — уточнить PR-утверждение (см. расхождение 2): поиск на суде находит собственный PR #620 предмета.

СОВЕТ (к сведению, дефекта нет) — check_provodka rc 1 на момент суда ожидаем: подключение guard-строки назначено orchestrator после ленда реализации, rc 0 требуется «перед done» (строка 40).

## Пять вопросов

1. Критерий слабее предмета? Нет: единственный результат предмета (бриф перечисляет непринятые изменения используемых механизмов; выпуск без записи не проходит land/done) покрыт 13 красными клетками на публичном шве, контроль зелёный, мои два мутанта пойманы, стабы 9/9 различимы.
2. «Готово», недоказуемое командой? Каждый пункт приёмки имеет rc-команду; исключение — грамматика парсера (:17) и часть позитивных пар (:38) — советы выше.
3. Решение, молча оставленное исполнителю? Расположение станции для проектного скрипта определено («расположением установленного слоя, не произвольным аргументом»), байты production-реестра pinned батареей через seed; дата записи 161 — совет 2.
4. Границы исполнения? Все пути реализации названы в ЗОНА-строках (реестры, next_id, 4 писателя — implementer; CI-носители — orchestrator); механическая сверка с чужими заморозками зелёная (precision-гейт, живой прогон); необходимых путей вне зон не нашёл (profile_resolver/check_merge_gate используются как есть, не правятся).
5. Противоречие норме AGENTS.md? Нет: КЛАСС РИСКА строка с основанием (:3, обычный обоснован — доступа/денег/ПД/юр. действий нет), модель угроз по форме 041 и адекватна границе, ПРОВОДКА по грамматике 038 (гейт парсит), Н-39 соблюдён, красное-до-реализации заявлено и наблюдено, «Незаполненные требования: нет».

Известный факт процесса (строка registry/plan.tsv для 168 отсутствует) — не находка критика, дело владельца; freeze откажет на нём сам.
