accept
OBJECT=09ce787991f6cea9453d52762ab2ee558ca254f5

# Критик 109 — круг 3 (последний по капу; рамка — арбитраж `verdicts/arbitration/contracts-109-cep-zhivogo-fakta-v1.md`)

Предмет: закоммиченный `contracts/109-cmp-bck-004-stend-evidence.md` и названная им батарея `fixtures/workshop_project/stend_109/probe.py` на `origin/wip/109/architect` @ `09ce7879` (HEAD клона = OBJECT, автор коммита `architect`). Набор полный: предмет, критерий с командами, исполнители, `ЗОНА`/`ПЕРЕСЕЧЕНИЕ`, ПРОВОДКА. Контракт, батарею и роль критика не правил. Complior-back получен по ssh с первой попытки и выставлен на B `9d960a0543eb36696b1d767bf208416e774f0a32`; `npm --prefix backend ci` → rc 0 (142 пакета; предупреждение EBADENGINE node 26 vs 24 — как в кругах 1–2).

Судил ВНУТРИ рамки арбитража: accept = нет обхода внутри К1–К6 и нет регресса закрытий кругов 1–2. Все замеры — на ТЕХ ЖЕ деревьях критика кругов 1–2 (`/tmp/dev-harness-verify/Critic109r2/evidence.tar.gz` распакован в `/tmp/dev-harness-verify/Critic109r3/`; в tar нет `node_modules` — скопированы из `back/backend/node_modules` после `npm ci`, иначе по К5 всё даёт rc 2).

## Итог

Обходов внутри К1–К6 не найдено; регресса кругов 1–2 нет. Блокирующих находок нет → `accept`. Два измеренных обхода/дефекта ВНЕ перечня и две диагностические неточности идут советами (ниже), как велит арбитраж («любые новые мутанты вне К1–К5 — совет»).

## Перечень К1–К6 поимённо

| пункт | статус | чем доказано |
|---|---|---|
| К1 — `HARNESS_TUPLE_GUARD` читает sink | **ВЫПОЛНЕН** | `probe.py` `harness_fact`: файлы сопоставляются наблюдениям по порядку создания (`new = [n for n in cur if n not in prev]`, ровно 1 новый на запись), из JSON файла сверяются `mode`, шесть осей (`leaf_match`), `input_hashes` = sha256 входов; return — дополнительная сверка; append-only (прежние файлы неизменны). Дерево `sink-decoy` → rc 1, `HARNESS_TUPLE_GUARD=False` «запись 0: mode из файла None≠'FIXTURE_5_8_2'; ось http_request из файла ≠ наблюдению; …». Мутант `harness_sink_decoy` на модели → REJECTED_EXACT; оверлей байт-в-байт равен файлу дерева критика. |
| К2 — `DRILL_EVIDENCE_GUARD` исполняет точку входа поставки | **ВЫПОЛНЕН** | `drill_entry_command` берёт `scripts['drill:evidence']` из `backend/package.json`; `drill_fact` исполняет ЭТУ команду (`/bin/sh -c`, cwd = disposable-копия `backend/`), три прогона (без входа → NOT_RUN + цели; два различимых входа → sha256 полей, измеренные RPO/RTO/measured_at из входа), sink читается из `DIR/drill-evidence.json` самой команды; команда без коллектора → False; скрипт отсутствует → None + контроль `DRILL_MEASUREMENTS_ABSENT`. Деревья `drill-unwired` → rc 1 контролем `DRILL_MEASUREMENTS_ABSENT`; `br2-same` (мёртвый файл) → rc 1 фактом «status=None≠'MEASURED'». Мутант `drill_unwired` → REJECTED_EXACT; оверлей (package.json + тест) байт-в-байт равен дереву критика. |
| К3 — три режима в живом факте | **ВЫПОЛНЕН** | `HARNESS_OBS` — три наблюдения `FIXTURE_5_8_2`/`SYNTHETIC`/`RUNTIME`; `mode` — седьмое поле из файла. Дерево `mode-collapse` → rc 1 «mode из файла 'RUNTIME'≠'FIXTURE_5_8_2'; … ≠'SYNTHETIC'». Мутант `harness_mode_collapse` → REJECTED_EXACT, байт-в-байт. `harness_no_mode_label` остался. |
| К4 — сентинел внутри сериализуемой оси | **ВЫПОЛНЕН** | сентинелы `tok_SENTINEL_A1` (header), `sentinel-two@example.com` (body), `tok_SENTINEL_B2` (header); `leaf_match`: поле присутствует, непусто, сентинела нет; прочие — exact; `[REDACTED]` не навязан. Дерево `scrubber-identity` → rc 1 «ось http_request из файла ≠ наблюдению; scrubber: tok_SENTINEL_A1 в interaction-….json». Мутант `harness_scrubber_identity` → REJECTED_EXACT, байт-в-байт. |
| К5 — NEEDS_ENV не зелен | **ВЫПОЛНЕН** | `control_green = not base_fired and not facts_red and not facts_none`; полный прогон: факт None → rc 2 `UNMEASURABLE: NEEDS_ENV: факты не измерены: …`; `--case` — rc 2 `NEEDS_ENV: <граница>`. Измерено: копия модели без `node_modules` — полный rc 2, `--case compose_delete` rc 2; B — полный rc 1 контролем (строка 1 не изменилась), `--case compose_delete` на B rc 2 (как написано в :49). |
| К6 — текст контракта | **ВЫПОЛНЕН** | :45 правило Ц одним абзацем в §Приёмочный критерий и в докстринге батареи (единый источник: имя `drill:evidence`, грамматика CLI, режимы, сентинел); :91 «ПО СОДЕРЖИМОМУ СОХРАНЁННЫХ ФАЙЛОВ», :96 «ИСПОЛНЯТЬСЯ КОМАНДОЙ ПОСТАВКИ»; :48–49 и §Замер :144–146 — 29 кейсов, три прогона, деревья критика красны; :122–130 раздел «Закрытие обходов круга 2» формы БN → клетки (та же форма, что образец круга 1; пары стаб↔ветвь — в коде `CASES`, Н-39). `check_provodka.sh` rc 0, `check_precision_gate.sh` rc 0 `OK`, `check_threat_model.sh` rc 0 (8/4), `pre_critic.sh` rc 0. |

Регресс кругов 1–2: нет — `br1-same` rc 1 (`COMPOSE_EGRESS_OPEN` + `EGRESS_GUARD=False` «document-worker→default»), `br2-same` rc 1 (`DRILL_EVIDENCE_GUARD=False`), `br3-same` rc 1 (`HARNESS_TUPLE_GUARD=False` «recordInteraction is not a function»), `old-exact` rc 1 (два контроля + два факта). Честная модель круга 2 (`control-model`, без единого изменения кода предмета) → rc 0, пять фактов True, 29/29 REJECTED_EXACT, три прогона подряд стабильны — прогноз З-1 арбитража подтверждён.

## Советы (НЕ блокируют; обходы вне перечня К1–К6 либо диагностика)

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:48 — rc 0 не требует «все 29 REJECTED_EXACT»: `main()` возвращает 0 при `blocked_by_red_control > 0`, если контроль зелен. Мутант `harness_scrubber_identity` ищет ДОСЛОВНО тело `scrubSecrets` модели и при ином написании возвращает `None` → кейс `BLOCKED_BY_RED_CONTROL` на ЗЕЛЁНОМ контроле (ложный диагноз, правило 7 AGENTS).
Обход: нет — предмет сделан честно, это «гейт зеленее текста», а не обход предмета (живой К4-факт на таком дереве всё равно ловит identity-scrubber).
Конкретное дерево: `adv-scrubber-other` = control-model, в `scrubSecrets` строка `out.split(String(s)).join('[REDACTED]')` → `out.replaceAll(String(s), '[REDACTED]')`. Полная батарея → rc 0, `control_green=true`, 28 rejected / **1 blocked** / 0 not_rejected (`harness_scrubber_identity → BLOCKED_BY_RED_CONTROL`). Для сравнения `harness_sink_decoy`/`harness_mode_collapse` при отсутствии своей строки дают NOOP → rc 2 — поведение трёх мутантов одного класса несогласовано.
Простейшая форма фикса: при зелёном контроле любой кейс не-REJECTED_EXACT (в т.ч. `applied: False`) → rc ≠ 0 (`NOOP_MUTATION`/rc 2), чтобы rc совпал с текстом :48; либо сделать дельту `scrubber_identity` устойчивой к форме (замена всего тела функции по сигнатуре).

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:36 — инвариант 4 «`wx`-создание» на живом слое не измеряется: структурная клетка ищет литерал `'wx'` где угодно в коде, а живой факт пишет три файла с разными именами и перезаписи не провоцирует. Арбитраж К1 прямо оставил «`wx` — как на OBJECT», поэтому вне перечня — совет.
Обход: `'w'` в реальном пути `recordInteraction`, `'wx'` остаётся в `saveRun` (мёртв для факта).
Конкретное дерево: `adv-w-live` = control-model, единственная дельта `fs.openSync(dir + '/' + name, 'wx')` → `'w'` в `recordInteraction`. Полная батарея → rc 0, пять фактов True, 29/29 (`harness_overwrite` всё равно REJECTED_EXACT, т.к. заменяет оба `'wx'`). Строка 5 («повторный прогон не меняет существующие каталоги evidence») добирает это живьём на станде — поэтому совет.
Простейшая форма фикса: в `harness_fact` четвёртый вызов с тем же именем файла (или предсоздать файл с именем первой записи) → ожидать исключение `EEXIST`, а не перезапись.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:49 — «на красной базе `BLOCKED_BY_RED_CONTROL`» для кейсов с целью-фактом не держится: `run_case` для `DRILL_EVIDENCE_GUARD`/`HARNESS_TUPLE_GUARD` при уже красном факте даёт `NOT_REJECTED` (измерено на `sink-decoy`, `mode-collapse`, `br3-same`: четыре harness-кейса `NOT_REJECTED`, `--case` на таком дереве вернёт rc 1, не 0). Дерево и так красно — не обход; но диагноз ложный (правило 7): мутант не «не отвергнут», а неприменим на красном факте. Фикс — `target in base_facts_red → BLOCKED_BY_RED_CONTROL`.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:49 — флаг `--model`, названный в брифе круга, батареей не поддерживается (`probe.py --model` → rc 2 «required: --repo»); если он где-то обещан — убрать упоминание, батарея права.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:38 — проверка «команда указывает на коллектор» — подстрока basename в тексте команды; `node scripts/other.js --out X # drill-measure.js` проходит структурно. Обход предмета из этого не выходит: исполняется именно команда, и sink читается из её вывода — что бы ни писало evidence, оно и есть коллектор; а мутант `drill_dead_file` бьёт первого кандидата по алфавиту и при лишнем кандидате даст NOT_REJECTED/NOOP. Уточнение формы, не блок.

## Сырые команды и rc

Каталог H: `/tmp/dev-harness-verify/Critic109r3/h`; D: `/tmp/dev-harness-verify/Critic109r3`.

- `git clone --branch wip/109/architect ssh://git@github.com/a3ka/dev-harness.git D/h` → rc 0; `git rev-parse HEAD` → `09ce787991f6cea9453d52762ab2ee558ca254f5`.
- `git show origin/main:verdicts/arbitration/contracts-109-cep-zhivogo-fakta-v1.md` → rc 0 (прочитан целиком); `git show origin/main:verdicts/critic/contracts-109-krug1-fail.md origin/main:verdicts/critic/contracts-109-krug2-fail.md` → rc 0.
- `git clone ssh://git@github.com/a3ka/Complior-back.git D/back` → rc 0 (с первой попытки); `git checkout 9d960a05…` → rc 0; `npm --prefix backend ci --no-audit --no-fund` → rc 0.
- `tar -xzf /tmp/dev-harness-verify/Critic109r2/evidence.tar.gz -C D` → rc 0 (деревья control-model, sink-decoy, drill-unwired, mode-collapse, scrubber-identity, br1-same, br2-same, br3-same, old-exact); `cp -r back/backend/node_modules <дерево>/backend/node_modules` для каждого.
- `python3 fixtures/workshop_project/stend_109/probe.py` (без флагов) → rc 2 «the following arguments are required: --repo»; `--model` → rc 2 то же.
- `python3 h/…/probe.py --repo back --out out-B` → **rc 1**: `control_red` = ровно `COMPOSE_MISSING, DRILL_MEASUREMENTS_ABSENT, HARNESS_INTEGRATION_TEST_MISSING, HARNESS_MISSING`; blocked `TEST_INTEGRATION_NOT_WIRED`; `ROOT_SERVER_PRESENT`/`RUNNER_DAMAGE_GUARD` true (повреждённый файл rc 1 «SHA256 013_… не совпадает с манифестом»; пропуск rc 1); три живых факта None с границей; 29 кейсов: 1 REJECTED_EXACT / 28 BLOCKED.
- `python3 h/…/probe.py --repo control-model --out out-control` → **rc 0**: `control_green=true`, 5 фактов True, 29/29 REJECTED_EXACT, 0/0.
- `python3 run_trees.py sink-decoy drill-unwired mode-collapse scrubber-identity br1-same br2-same br3-same old-exact` → rc 0; вложенные полные прогоны — все **rc 1** с причинами, приведёнными в таблице (логи `out-<дерево>.log`, отчёты `out-<дерево>/raw.json`).
- `python3 check_lines.py` → rc 0 (лог `check_lines.log`): `--matrix` на модели rc 0, 29 строк REJECTED_EXACT; каждый из 29 `--case` rc 0 и REJECTED_EXACT; `--case nonexistent` rc 2 `109 UNMEASURABLE: EMPTY_SELECTION`; три полных прогона подряд rc 0; `k5-nodeps` полный rc 2 `UNMEASURABLE: NEEDS_ENV: факты не измерены: RUNNER_DAMAGE_GUARD`, `--case compose_delete` rc 2; B `--case compose_delete` rc 2 NEEDS_ENV (три границы); байт-в-байт: `harness_sink_decoy`, `harness_mode_collapse`, `harness_scrubber_identity`, `drill_unwired` (оба файла), `drill_dead_file` — оверлей мутанта на control-model == файл дерева критика; `compose_egress_unused_net`/`harness_tuple_decoy` против `br1-same`/`br3-same` — расхождение ожидаемо (деревья круга 1 на другой базе; байт-в-байт для них не заявлялся и в П4 не входят; оба дерева красны).
- `python3 advice_trees.py` → rc 0 (лог `advice_trees.log`): `adv-scrubber-other` rc 0 / 28 rej / 1 blocked; `adv-w-live` rc 0 / 29 rej.
- `bash scripts/check_provodka.sh D/h contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, пустой вывод.
- `bash scripts/pre_critic.sh contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, «КРИТИК: дверь зелёная».
- `bash scripts/check_precision_gate.sh D/h contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, `OK`.
- `bash scripts/check_threat_model.sh D/h contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, 8/4 буллета.

Project-wide suites/линтеры не запускались; контейнеры и PG18 не поднимались (строки 4–5 — за adversary/reviewer, как записано в арбитраже). Основной чекаут `/home/harness/dev-harness` не открывался; push не делался; клоны `D/h` и `D/back` удалены после записи вердикта, деревья и логи доказательств оставлены в D.

## Доставка

Вердикт для коммита в `verdicts/critic/contracts-109-v3.md` на ветке предмета под `-c user.name=critic -c user.email=critic@dev-harness.local` — оркестратору (сессия непиннованная, запрет записи в основной чекаут). Первая строка — `accept`.
