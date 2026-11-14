accept

# Суд реализации: интеграционный пакет А v2 (предмет 095 и весь diff пакета), вызов 1

- OBJECT: `434b9979ccc3bc80fe63e78b90311a3fc72d2a92` (ветка `wip/int-095/orchestrator`, PR https://github.com/a3ka/dev-harness/pull/946, tree `bfd48b6b8b3aaf5949608d09a0b7b46e562e1d9c`)
- База: `085a118d1362303152deef2bbabb570796f076ab` (origin/main). Объём суда — весь diff `085a118d..434b9979`: 24 файла, +1092/−232, 26 не-merge коммитов, 18 merge.
- Судья: роль reviewer, сессия `ReviewPaketAV2`. Фактическая модель — `anthropic/claude-opus-5-5`: так записано в строке Model системной шапки этой сессии. Пятиколоночную трассу `--sud` снимет родитель из этой сессии; здесь она не подменяется.
- Мандат: Р3 (один reviewer Opus), Н4 роадмапа v2 и слово владельца «ну все, тогда делай». Вызов первый и полный. Прежняя попытка отказала `KLASS_RISKA_NET` ещё до спавна.
- Находки: файл `.review/2026-11-14-99.md` (status: ready) лежит в WT непроиндексированным. Pre-commit `check_staged.sh` отказал ему под identity reviewer: «ОТКАЗ: вне зоны: .review/2026-11-14-99.md» — zones_load даёт reviewer только `verdicts/review/`. Хуки я не обходил. Полный текст находок повторён в §8 этого вердикта. Блокирующих нет. Советов 6 (С-1…С-6), наблюдений 6 (Н-1…Н-6).

## 1. Вердикт кратко

Пакет делает обещанное, и на достижимых входах я не нашёл доказанного нарушения его объявленного обещания. Главное:

- runtime-трасса закрыта от отказов: устаревшее свидетельство не остаётся, fallback помечается `denied`;
- фактическая модель не подменяется конфигурацией: project fallback 136/169, место манифеста, `spawn_agent`, `connect_project` и `models_actual` не тронуты;
- граница длинного inline-контракта 187 и длинного ответа 029 исправлена, есть красное до исправления;
- бюджет WORK явный, GOAL/RULES/MAP не усекаются, обязательный источник отказывает;
- текст 095 побайтно совпадает с frozen 1.

Слабые места — советы, не блок: шум `TRACE_NOT_READY`, разная политика выбора события в архиве и в строке orchestrator, нет клетки для runtime-связки, ветвь ПАУЗА без клетки.

## 2. Что проверено и что нет

Проверено (своей мерой, см. §3):
- Предусловия: `PAKET-A-V2-REVIEW-PRECONDITIONS.json` ready=true, OBJECT совпадает с локальным HEAD, с remote-веткой и с `headRefOid` PR, detector_rc=0. Мой подсчёт check-runs по `checks[]` — 16 success и 1 skipped (`vorota`) из 17, все на head_sha OBJECT (Н-3).
- 8ac8e709→OBJECT: меняется ровно один путь, `registry/risk-legacy.tsv`. Owner-коммит `02e654e1`: author=committer=`owner <owner@dev-harness.local>`, родитель 085a118d, тоже один путь.
- Зоны: каждый путь diff я сверил с ЗОНА-строками высших frozen-тегов 011/3, 028/3, 029/2, 095/1, 136/2, 187/1, 998/1. Выхода за зону нет, `registry/risk-legacy.tsv` подписан владельцем. Все 18 merge чистые: `git diff-tree --cc` даёт 0 строк у каждого.
- Атомарность: каждый не-merge коммит относится к одному предмету (011 ops, 029, 187, 136, 095, 998, owner). Связок разных предметов в одном коммите нет.
- Неподгонка: критерии 095 (`36b74b58`, architect, 21:47) появились раньше реализации (`40bd6ca9`, implementer, 22:26). Implementer ни в одном коммите не трогал фикстуры. Поздние правки architect (`cccc4764`, `7f36b5fe`) ведут к базовой семантике (Н-5).
- Frozen-текст 095: `git rev-parse` на базе, на OBJECT и на `frozen/contracts/095/1` даёт один blob `ccf4b28a917516745bef0ab7bab5e6405a8d19d0`.
- Счётные утверждения своей мерой: «19 клеток, 31 стаб» — 19 файлов `red_*.sh` по `ls-tree` и 31 id стабов в `battery_stubs.sh` (на базе 16/19). «11 проверок Н2 rc0» — 11 записей в `result.json`, у всех rc=0. Роль `roles/orchestrator.md` — 73186 байт при потолке 73728.
- Поведение: батарея 095 (своя real/model и своё красное на make_task базы), 029 (OBJECT и барьер базы), 187 (частично, Н-2), `session-trace.ts` синтетическим pi/ctx, `prepare_model_trace` на синтетической зоне, потолок строки остатка WORK.
- Н3: `result.json` и `session.evidence.json`. Brief на пробе шёл с `--model-trace "$HARNESS_MODEL_TRACE"`, файл трассы содержал `orchestrator openai-codex/gpt-6.1-terra allowed`, задание собрано с тем же флагом, `land_agent` дал `LANDED main=b1327d63…`, следующий scout принят. b6752d31 и b1327d63 в R отсутствуют (`cat-file -e` → нет), в кодовую голову не попали.

Не проверено или проверено частично:
- Полная семья 187 локально: окружение исчерпало inode на tmpfs `/tmp` (Н-2). Полное свидетельство — CI l7 на OBJECT.
- Семьи 136 и 169, `check_contract_frozen`, `check_charter`, `check_ceilings` и `gen:harness --check` я не повторял. Это Н2 на 8ac8e709, а код с тех пор не менялся (своя мера: diff 8ac..OBJECT — один путь реестра). На OBJECT их покрывает CI.
- Проектный режим runtime-трассы не исполнялся — ни в Н3, ни мной (С-4).
- 129 (старый долг omp 18.18.8, Р8) и 185 (Р9) вне пакета, не судились. spec_ready/provodka 095 красны ещё на main и в CI 095 не входят.
- Живые серверные сессии и production я не трогал.

## 3. Сырой вывод собственных проверок

Скрипт: `/tmp/dev-harness-verify/rv095-scoped/run.sh` (одноразовый). Клон: `git clone --no-hardlinks` из R в `/tmp/dev-harness-verify/rv095-scoped/clone`, свой `.git`, `checkout --detach OBJECT`, по завершении удалён. Логи: `/tmp/dev-harness-verify/rv095-scoped/logs/`.

```
C0 HEAD=434b9979ccc3bc80fe63e78b90311a3fc72d2a92 gitdir=/tmp/dev-harness-verify/rv095-scoped/clone/.git status=[0]
C0 diff 8ac..OBJ: registry/risk-legacy.tsv
C0 grep=/usr/bin/grep grep (GNU grep) 3.12-modified
c1-095-real rc=0 t=48s :: ИТОГ стаб-пак 095: rc=0 ИТОГ 095: rc=0
c1-095-model rc=0 t=8s :: ИТОГ стаб-пак 095: rc=0 ИТОГ 095: rc=0
C1 stubs-caught=31
C1 cells-green=19
c2-095-base-subject rc=1 t=35s :: КРАСНО: karta: нет брифа rc=1: ОТКАЗ: брифинг: контракт без предмета: …/contracts/534-h1.md КРАСНО: bez-plana: нет предмета/не тот приоритет: WORK: 710 :: черновик: tools/check-x.py — барьер y. КРАСНО: i6: arbiter не собрался по черновику до заморозки (rc=1, вывод: ОТКАЗ: контракт не заморожен: 777) ИТОГ 095: rc=1
C2 red-cells: — red_naznachennaja_specializacija.sh: rc=1 — red_orch_brief_bounded_work.sh: rc=1 — red_orch_brief_karta_legacy.sh: rc=1 — red_orch_brief_rabota_bez_plana.sh: rc=1 — red_rezhim_do_zamorozki.sh: rc=1
c3-029-deko-obj rc=0 t=1s ::
c3-029-lozh-obj rc=0 t=2s ::
c3-029-deko-base rc=1 t=0s ::
c3-029-lozh-base rc=1 t=0s ::
c4-187-obj rc=1 t=12s ::            (авария окружения ENOSPC/inode, см. Н-2; 14/14 GREEN до неё)
c4-187-pre-c9a rc=1 t=11s ::        (RED brief-inline-line-missing: rc=0 expected=1, затем та же авария)
c5-session-trace rc=0 t=0s ::
S1 ready start: rows=[implementer	minimax/MiniMax-M3	allowed | orchestrator	openai-codex/gpt-6.1-terra	allowed] messages=0 kinds=
S2 3 tool_call same model: rows=[implementer	minimax/MiniMax-M3	allowed | orchestrator	openai-codex/gpt-6.1-terra	allowed] messages=0 kinds=
S3 live model changed, journal lags, 5 tool_call: rows=[implementer	minimax/MiniMax-M3	allowed] messages=5 kinds=nextTurn
S3b before_agent_start while lagging: rows=[implementer	minimax/MiniMax-M3	allowed] messages=6 kinds=nextTurn
S4 journal caught up, 2 tool_call: rows=[implementer	minimax/MiniMax-M3	allowed | orchestrator	anthropic/claude-opus-5-5	allowed] messages=6 kinds=nextTurn
S5 retry fallback: rows=[implementer	minimax/MiniMax-M3	allowed | orchestrator	zai/glm-5.3	denied] messages=6 kinds=nextTurn
S6 subagent session file: rows=[implementer	minimax/MiniMax-M3	allowed | orchestrator	zai/glm-5.3	denied] messages=6 kinds=nextTurn
C6 models_actual --tsv:
implementer	minimax/MiniMax-M3	allowed
implementer	zai/glm-5.3	denied
C6 models_actual rc=0
C6 archive:
implementer	minimax/MiniMax-M3	allowed
C6 empty-zone stdout=[TRACE_ARCHIVE_NOT_READY: ] file-bytes=0
C7 remainder-bytes=115
DONE
```

Причины красного в C3 против барьера базы, дословно из логов:
- deko: «ОТКАЗ: длинный честный ответ обязан проходить … барьер вернул rc 1, ожидался 0. Вывод: нет блока ОСНОВАНИЕ-ДЕРЕВО в ответе … просмотрено 0 команд» (ответ 172979 байт);
- lozh: «ОТКАЗ: отказ обязан называть класс расхождения … в выводе нет «расхождение rc». Вывод: нет блока ОСНОВАНИЕ-ДЕРЕВО …» (ответ 171779 байт).

Повтор семьи 187 (`run2.sh`, свежий клон): `c4b-187-obj rc=1 GREEN=14 RED=0`, затем `RuntimeError: fatal: cannot update the ref 'refs/heads/main': unable to append to '.git/logs/refs/heads/main': No space left on device`. `df -i /tmp`: `1048576 1037377 11199 99%`.

## 4. Пункты «особенно проверь»

1. **session-trace.ts и смена модели.** Ложного свидетельства нет. Если live-модель расходится с последним `model_change`, строка orchestrator удаляется, а не остаётся старой (C5 S3), и бриф отказывает закрыто: `свидетельство не той роли`. После выравнивания журнала строка восстанавливается (S4). Retry-fallback записывается как `denied` (S5). Файл сессии субагента трассу не трогает (S6). Цикла нет: `deliverAs:'nextTurn'` без `triggerTurn` ход не запускает (omp://extensions.md:334). Шум есть: N неготовых `tool_call` дают N сообщений (S3: 5 вызовов → 5 сообщений) — **С-1**. Остаточный риск с advisor — **Н-6** [INFERENCE].
2. **Runtime против конфигурации, fallback 136/169, манифест.** `make_task.sh` переменную `HARNESS_MODEL_TRACE` не читает (`grep -c` → 0), ENV-приоритета нет. Блок разбора трассы 136/169 (`make_task.sh:319-355`) не менялся, кроме комментария И-20 и физического имени роли. `spawn_agent.sh`, `connect_project.sh`, `models_actual.sh`, `lib_plan.sh`, `pre_judge.sh`, `land_agent.sh` против базы не менялись (`git diff --quiet` → UNCHANGED). Пути манифеста и `_PACK_FROM_WORKTREE` возвращены к базе коммитом `b42c7018`. Широкий cutover 169/161 в пакет не попал. Из конфигурации менялись только модель тира consultant (Р4, `c1459bad`) и `task.structured/maxRuntimeMs`: 0 означает «без ограничения» (omp://tools/task.md:209).
3. **Граница длинного inline-контракта (187) и profile-отказы.** `arch187_code_subject -` читает stdin целиком, `grep` без `-q`, вывод в /dev/null. На GNU grep 3.12 в этом окружении конвейер `printf 300 КБ | grep >/dev/null` даёт rc 0, а `grep -q` — 141. Без `c9a6096a` клетка inline-контракта RED (C4). Отсутствие `check_architecture_contract.sh` теперь даёт именованный rc 2 (`ni`) вместо тихого пропуска гейта. Ответ locate разбирается как JSON целиком, при отсутствии или незнакомом status — `ARCH_LOCATE_GRAMMAR`. Обязательный источник отказывает с `(PROFILE_PATH_MISSING)`, как на базе. Клетки bounded и bez-plana требуют rc 1 и пустой stdout. 029: дочитывающий grep прошёл на OBJECT и красный на базе по правильной причине (C3).
4. **Бюджет и GOAL/RULES.** Урезается только WORK, и урезание видно явно: строка `WORK: за бюджетом брифа: N строк…` и счётчик `WORK: опущено: закрытых N, вне плана M`. Порог строк 39800 плюс строка остатка ≤115 байт (C7) не выводят вклейку за 40000. Сверх 40000 по-прежнему отказ «режь задачу». GOAL/MAP/RULES клетка bounded сверяет побайтно на толстом мире: 80 предметов по 1650 байт, кап испытан, `shown + omitted = 81`. Отсутствие обязательного источника не прячется: отказ происходит до бюджета.
5. **Область, атомарность, авторы, неподгонка, frozen-текст, полный цикл** — см. §2. Полный цикл Н3 настоящий (brief → make_task → spawn → коммит рабочего author=committer=implementer → приём по Git → `land_agent` LANDED → следующая выдача → приём). Это проба на 8ac8e709 в одноразовом клоне, не production. Отличие от OBJECT — одна строка реестра.

## 5. Пункты роли

1. Область правки: внутри зон авторов (§2). Превышений нет.
2. Сырой вывод: Н2 — 11 логов с rc; Н3 — session.jsonl и evidence; RED 095 — два лога; свои — §3.
3. Подгонки проверок нет (§2, Н-5).
4. Красное предъявлено: 095 — `PAKET-A-095-RED-real.log` на `36b74b58` и моё C2 (те же 5 клеток красные против make_task базы); 029 — C3; 187 inline — C4 pre-c9a. Для `session-trace.ts`/`prepare_model_trace` барьера в дереве нет — С-4.
5. Атомарность соблюдена.
6. Норма молча не тронута. Текст 095 равен frozen 1. Нормы `roles/orchestrator.md` правились по 011 ops, план DIAGNOZ-PLAN п.1.2 (`4d774709`…`66aaf002`), и одной фразой по Р7 (`6cf7d675`). Литерал шага 0 приведён к ПРОВОДКЕ frozen 169/1 (Н-4).
7. Заявленное равно сделанному: числа 19/31/11/73186, «один путь 8ac→434» и «17 check-runs» проверены своей мерой. Уточнение по последнему: 16 success + 1 skipped (Н-3).

Расхождение кода с буквой frozen 095/1 (И-12, WORK «по каждому контракту») санкционировано Р6 и в блок не идёт (Н-1).

ПРОВОДКА 095 (038): guard `fixtures/_krasnye_095.sh` подключён — `registry/ci-steps.tsv:240`, шард l4 `ci.yml:278`. Role-канал `roles/orchestrator.md` вызывает `make_task --kind brief/--kind task` с явной трассой.

Режим проекта (996): `sourceCanon: null` (пак) — сверка с картой не применяется.

СВЕРКА-СТАНДАРТОВ: неприменимо. `AGENTS.md` харнесса не объявляет документ архитектуры и стандарт кода: `grep -n -i 'ARCHITECTURE.md|CODING-STANDARDS|стандарт кода' AGENTS.md` → 0 совпадений.

## 6. Паразитная сложность (050) — по артефактам диффа

| Артефакт | (1) свойство | (2) состояние, явность | (3) совместные правки | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| `.omp/extensions/session-trace.ts` (новый) | runtime-свидетельство ведущей сессии, не конфиг (план 1.1, Р7) | файл `runtime/model-trace.tsv` и `process.env.HARNESS_MODEL_TRACE`; неготовность видна сообщением, но шумно (С-1) | 1 файл + роль; не выросло | интерфейс — 3 события, работа скрыта; глубокий | make_task через роль; живой Н3; клетки нет (С-4) | ESSENTIAL |
| `workshop: prepare_model_trace` | архив фактических запусков ролей для `--model-trace` | `HARNESS_MODEL_TRACE` (export), runtime-файл; отказ пишет пустой файл, префикс в stdout (С-3) | workshop + session-trace держат одну политику выбора — расходятся (С-2) | 0 аргументов, 1 env; глубокий | роль/make_task; повторяет `models_actual --tsv` фильтром, без своей грамматики | ESSENTIAL |
| `make_task: LOGICAL_ROLE`, implementer-glm | одна назначенная специализация (И-20 v2, Р6) | переменная, видна в TRACE/скилах | 2 case-алфавита (ROLE, AUTHOR_ROLE) + клетка; рост на 1 | интерфейс не вырос | клетка specializacija | ESSENTIAL |
| `make_task: _brief_subject` | носители Предмет/Обещание/H1, 480 символов | нет | функция + честная модель dover.sh (по построению) | 1 аргумент; глубокий | клетки karta/bez-plana | ESSENTIAL |
| `make_task: WORK по плану + lib_plan` | ограниченный WORK по статусу 084 | счётчики выводятся строкой | переиспользует lib_plan (без копии статуса); setup 136 +1 строка | без новых флагов | клетки bounded/karta/bez-plana | ESSENTIAL |
| `make_task: ветвь ПАУЗА` | «пауза сохраняет статус» (только v2 И-17) | читает `pauzy.tsv` (существующий реестр) | код + модель | +0 интерфейса | клетки нет (С-5) | ESSENTIAL по v2, не наблюдаема |
| `make_task: бюджетный цикл WORK` | кап 40000 без потери GOAL/RULES | явная строка остатка | тот же `pack_body` (второй раскладки нет) | без флагов | клетка bounded | ESSENTIAL |
| `make_task: _arch187_scope/_arch187_code`, `ni` без библиотеки | источник брифа ≠ кодовый гейт (187/1) | две переменные, отказы именованы | общая грамматика класса в одном месте (копия make_task удалена) | интерфейс тот же | семья 187 (CI l7) | ESSENTIAL |
| `check_architecture_contract.sh`: `ARCH187_CLASS_RE`, режим `-`, `arch187_locate`/`ARCH187_LOCATE_COMPS`, `arch187_component_set` | JSON locate целиком, набор компонентов, stdin без SIGPIPE | глобальная переменная результата (обоснована: подоболочка теряет отказ) | одна грамматика на все двери | +1 режим аргумента `-` | семья 187 | ESSENTIAL |
| `verify_consultant.sh` гейт блока | длинный ответ не теряется (029) | нет | 1 строка | — | клетки deko/lozh вход 5/14 | ESSENTIAL |
| `.omp/config.yml` `task.structured/maxRuntimeMs`, consultant→Sol; `agent_models.json` | yield у задач (план 0.2), Р4 | явная конфигурация | генерат из реестра | — | генератор (`gen:harness --check` Н2) | ESSENTIAL |
| `roles/orchestrator.md` (+ генерат) | 011 ops, явная трасса задачному CLI (Р7) | норма-текст | роль + генерат, 73186/73728 | — | charter/ceilings Н2 | ESSENTIAL |
| `registry/risk-legacy.tsv` +1 | класс legacy 095 по слову владельца | реестр | 1 строка | — | дверь суда (KLASS_RISKA) | ESSENTIAL |
| Семьи клеток: context_pack_095 (+3, 2 переписаны, модель, стабы), verify_consultant (+примитивы, 2 входа), workflow_probe 187, setup 136 | критерии И-6/16/17/19/20 v2, 029, 187, 136 | миры в /tmp/dev-harness-verify, оракул в памяти | модель 095 повторяет логику субъекта (честная модель по норме) | — | CI-шаги l4/l7/ap4/l3 | ESSENTIAL |

ACCIDENTAL-находок с тремя частями (фрагмент, отсутствующее свойство, более простая форма, проходящая те же строки приёмки) нет: у ветви ПАУЗА свойство есть в v2 И-17, недостаёт только наблюдения клеткой (С-5).

## 7. Ссылки на сырые доказательства

- Предусловия: `/tmp/dev-harness-verify/consultant/PAKET-A-V2-REVIEW-PRECONDITIONS.json`
- Н2: `/tmp/dev-harness-verify/consultant/paket-a-v2-checks/8ac8e709e44ba290e94c10d4285e7c9dee839b34/result.json` и 11 логов рядом
- Н3: `/tmp/dev-harness-verify/paket-a-v2-local-cycle-1114b-stand/evidence/{result.json,session.evidence.json,session.jsonl}`
- RED 095: `/tmp/dev-harness-verify/consultant/PAKET-A-095-RED{.json,-real.log,-model.log}` (head 36b74b58)
- Свои: `/tmp/dev-harness-verify/rv095-scoped/logs/*.log`
- Консультация Fable `FABLE-N4-ROUTE-ANSWER-2026-11-14.md` прочитана как контекст; моё заключение от неё не зависит.

## 8. Находки (полная копия `.review/2026-11-14-99.md`, status: ready)

### Блок

Нет.

### Советы

- [ ] **С-1 (orchestrator, зона 011 `.omp/`; не блок).** `.omp/extensions/session-trace.ts:58-68`. Пока трасса не готова, `refresh` вызывается на каждом `tool_call` и каждый раз отправляет `sendMessage(TRACE_NOT_READY…, {deliverAs:'nextTurn'})`. Замер C5: 5 `tool_call` дали 5 сообщений, `before_agent_start` добавил шестое. Ложного свидетельства и цикла нет. Но при долгом расхождении на следующий ход накопится N одинаковых сообщений. Проще так: отправлять сообщение только при переходе состояния.
- [ ] **С-2 (implementer, зона 028 `workshop`; не блок).** `workshop:243`. Фильтр `awk … !seen[$1]++` оставляет для каждой роли ПЕРВОЕ событие `model_change` новейшей сессии и отбрасывает более позднее `denied` той же сессии. Замер C6: `models_actual --tsv` выдал allowed и denied, в архиве остался только allowed. Строка orchestrator в session-trace берёт ПОСЛЕДНЕЕ событие, так что в одном TSV две политики. Не блок: правила выбора события нет ни в frozen, ни в объявленном объёме, модель не выдумана. Входы достижимы (≥22 событий fallback=true в журналах зоны). Рекомендация: последнее событие новейшей сессии роли.
- [ ] **С-3 (implementer, зона 028; косметика).** `workshop:246`: префикс `TRACE_ARCHIVE_NOT_READY: ` идёт в stdout, причина — в stderr (C6).
- [ ] **С-4 (architect следующей редакции 011/028; не блок).** Нет регрессионной клетки для `session-trace.ts`/`prepare_model_trace`. Проектный путь (`workshop:832`, `:996-1001`, `:1324`) не исполнялся — [INFERENCE] по коду. Прецедент — `fixtures/zashchita_main_104/_mir.sh`.
- [ ] **С-5 (architect 095 v2; не блок).** Префикс `ПАУЗА: ` (`scripts/make_task.sh:901-905`, модель `dover.sh:304`) не проверяет ни одна из 19 клеток. Свойство записано только в v2 И-17 (А-377).
- [ ] **С-6 (architect 095 v2; к сведению).** Комментарии `make_task.sh` ссылаются на И-17…И-20, которых нет в frozen 095/1 (blob ccf4b28a). Они есть только в v2 `2f2f28c1`/`7f36b5fe`.

### Наблюдения

- [ ] **Н-1 (owner/станция, долг Р6).** Код расходится с буквой frozen 095/1 строка 75 / И-12 («WORK по каждому contracts/NNN-*.md»). Расхождение санкционировано Р6; соответствие frozen1 не объявлять.
- [ ] **Н-2 (окружение).** Семья 187 у меня: 14/14 GREEN до ENOSPC (inode tmpfs 99%). Полная — CI l7. Своё красное без `c9a6096a` — `brief-inline-line-missing` RED.
- [ ] **Н-3.** CI 43600564246: 17 completed = 16 success + 1 skipped (`vorota`).
- [ ] **Н-4.** Литерал шага 0 «отказ — стоп» возвращён по ПРОВОДКЕ frozen 169/1:146 и подчинён правилу владельца 2026-11-12. Давний долг: `grep -c 'make_task --kind brief' roles/orchestrator.md` = 0 и на базе, и на OBJECT.
- [ ] **Н-5.** Поздние правки критериев architect (`cccc4764`, `7f36b5fe`) ведут к базовой семантике; implementer фикстур не трогал.
- [ ] **Н-6 ([INFERENCE]).** Если `tool_call` от advisor несёт его модель в `ctx.models.current()`, трасса уйдёт в неготовность (закрыто, шум С-1). Не проверено.
