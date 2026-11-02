FAIL
OBJECT=0f0e1e69619bba53fd2e987828c34265ddb67117
СУД: repo=dev-harness; предмет=152; фаза=контракт (+красная батарея), scoped по дельте Arch152e по РЕШЕНИЮ арбитража Arb152c и зависимому регрессу; роль=critic; вызов=3 (дополнительный, исключение=слово владельца 2026-11-02: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/152-*.md — один дополнительный scoped-вызов критика (вызов 3) только по дельте architect по РЕШЕНИЮ арбитража contracts-152-arbitraz.md и зависимому регрессу; при FAIL — стоп и решение владельца (слово владельца 2026-11-02)»); модель-план=anthropic/claude-opus-5-5; сессия=Crit152c; модель-факт=anthropic/claude-opus-5-5; SHA=0f0e1e69619bba53fd2e987828c34265ddb67117; предыдущие=verdicts/critic/contracts-152-v1-fail.md (FAIL, Sol), verdicts/critic/contracts-152-v1b-fail.md (FAIL, Opus), verdicts/arbitration/contracts-152-arbitraz.md (РЕШЕНИЕ, Arb152c, Astra)
ОСТАНОВКА: FAIL третьего вызова — по слову владельца стоп и решение владельца; четвёртого вызова нет. Арбитр этим вердиктом НЕ созывается (арбитраж по предмету уже был; §Остановка).

## БЛОКИРУЕТ (один класс)

БЛОКИРУЕТ contracts/152-oom-sessii-i-zamki.md:45,60,192; fixtures/workshop_project/oom_zamki_152/probe.py:471-500,530-535,1154-1196 — класс 5 (литерал 085 при Result=oom-kill), закрывающее свойство арбитража для D: «После возврата подтверждённого scope должен быть наблюдаем запрос Result именно SESSION_UNIT до решения о дальнейшем ходе цикла» (verdicts/arbitration/contracts-152-arbitraz.md, §Классы 4 и 5). D-мир не связывает ответ Result с запущенным scope ни по ВРЕМЕНИ, ни по ИМЕНИ: двойник `systemd-run` (probe.py:471-480) разбирает только `--setenv`/`--` и делает `exec "$@"` — `--unit` игнорирует, факт возврата scope не фиксирует; двойник `systemctl` (probe.py:482-500) отвечает заданным Result на любой `show` в любой момент; trace `queries.tsv` хранит только `"$3"\t"$4"` (имя и свойство), без порядка относительно запуска/возврата scope; D10 (probe.py:1176-1183) проверяет лишь наличие строки `<expected_unit>\t--property=Result`.
ОБЯЗАТЕЛЬСТВО: И-9 (:45) — «orch-loop читает `systemctl --user show "$SESSION_UNIT" …` после возврата scope, ПЕРЕД ветвями маркера/rc/STOP»; Frontier «OOM-факт orch-loop» (:31); приёмка 5 (:60) «D10 наблюдает вызов Result до всех MARK/STOP/rc-выходов»; предмет — «orch-loop пишет литерал 085 по факту oom-kill юнита при любом rc».
СОСТОЯНИЕ: конформный D-вход любой координаты с Result=oom-kill, например D10 `('ok','oom-kill',143,False,False)` и d01 (oom-kill, rc 143 — сама боль 12:01). На станции запрос Result ДО запуска scope (или к имени, под которым scope не запускался) читает несуществующий/чужой юнит — `oom-kill` не виден никогда, литерал 085 не пишется: ровно класс 5 и боль 31.10.
ОБХОД: мутант md1-query-before-scope — блок факта OOM (model orch-loop :323-332) перенесён без изменений сразу за строку `SESSION_UNIT="orch-session-$loop_pid-$n.scope"` (до запуска scope), `$rc`→`${rc:-?}`. `bash fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh --repo /tmp/dev-harness-verify/Crit152c/mtree-md1` → `ZELENO: клеток 41, зелёных 41`, rc=0 (сырой лог /tmp/dev-harness-verify/Crit152c/mut/md1-full.log; sha256 мутантного orch-loop e539644a7e40defd730adb4172f80ad65e9f14ad1eec815cdf95e4be683ae1e8). Тот же класс, второй пример (по имени): md3-unit-not-bound — из запуска same-user ветви убран `--unit="$SESSION_UNIT"` (scope получает имя systemd, Result читается у SESSION_UNIT): `python3 mut/run_mut.py md3-unit-not-bound d01-fakt-oom-rc143 d02-rc137-result-success d04-fakt-oom-rc137 d06-fakt-oom-rc0` → `MUT md3-unit-not-bound CELL d01-fakt-oom-rc143 -> GREEN (1.2s)`, `… d02-rc137-result-success -> GREEN (1.2s)`, `… d04-fakt-oom-rc137 -> GREEN (1.2s)`, `… d06-fakt-oom-rc0 -> GREEN (1.2s)`; `python3 mut/run_mut.py md3-unit-not-bound d10-polnyj-domen-result d07-scope-path-marker-v-dejstvii` → `d10 -> GREEN (103.3s)`, `d07 -> GREEN (4.8s)` (cell-level, полный W для md3 не гонялся).
НАБЛЮДЕНИЕ: md1 по клеткам — `python3 mut/run_mut.py md1-query-before-scope d01-fakt-oom-rc143 d02-rc137-result-success d03-rc143-bez-fakta d04-fakt-oom-rc137 d05-net-systemctl-degradacija d06-fakt-oom-rc0 d09-storozh-ne-ustanovlen` → все семь `-> GREEN`, rc=0; `python3 mut/run_mut.py md1-query-before-scope d10-polnyj-domen-result d07-scope-path-marker-v-dejstvii` → `MUT md1-query-before-scope CELL d10-polnyj-domen-result -> GREEN (100.6s)`, `… d07-scope-path-marker-v-dejstvii -> GREEN (4.7s)`, rc=0; полный W --repo 41/41. Мутант вне остатка арбитража (не PATH/прямой путь/GC): все координаты внутри конечного домена D; «НЕ ЗАЩИЩАЕТ» D контракта (:180) порядок запроса относительно возврата scope не называет; пункт 3 НЕ ЗАЩИЩАЕТ арбитража («реальные systemd GC/LoadState и порядок получения факта на станции») говорит о поведении НАСТОЯЩЕГО systemd, а положение запроса в коде цикла относительно запуска scope наблюдаемо в игрушечном мире и прямо названо закрывающим свойством того же арбитража.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: в мире D ответ Result у двойника systemctl доступен только для юнита, реально запущенного двойником systemd-run под этим именем (`--unit`), и только после возврата этого scope; запрос до возврата scope или к имени, под которым scope не запускался, не даёт `oom-kill` — и на каждой oom-kill-координате D10 (и d01/d04/d06) такой субъект краснеет; честная модель остаётся зелёной на всём домене (120). Способ (метка возврата в двойнике systemd-run, упорядоченный trace, привязка к `--unit`) — за автором.

## САМООПИСАНИЕ (полный список «число/утверждение в тексте → живое значение»)

Расхождения (2):
1. contracts/152-oom-sessii-i-zamki.md:192 «отсутствие собственного журнала и гонка остаются отдельными C-клетками» → живое: гонка — c09; клетки с ОТСУТСТВУЮЩИМ собственным журналом нет ни одной: все десять C-клеток пишут журнал holder (`grep -n "zhurnal(" probe.py` → 857, 874, 888, 906, 923, 937, 951, 966, 981, 1017 — c01…c10). Попутно net_fajla→pogib ловит только c09 (СОВЕТ 2).
2. contracts/152-oom-sessii-i-zamki.md:205 «check_zones rc 0 на кандидате до коммита (148 замороженных, 9799 проверенных по зонам)» → на судимом OBJECT: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41368 · проверено по зонам: 9819`, rc 0. Текст сам помечает число как «до коммита» (не ложь), но на SHA суда оно иное — 9819 (так и в отчёте автора «после коммита»).

Сверено и совпало (текст → живое):
- клеток 41, A 15 / B 4 / C 10 / D 10 / E 2 (контракт :56-:58, :60, :162, :199-:202; osi.md:1) → KLETKI 41 {A:15,B:4,C:10,D:10,E:2}; строк таблицы osi.md 41 с тем же разбиением; имена osi.md = имена кода (разность ∅ в обе стороны).
- без реализации красных 33 = 19 A/B SUBJECT_ABSENT + C01/C02/C07/C08/C09/C10 + D01/D02/D05/D06/D07/D08/D09/D10; C03/e02 зелёны (:56, :162, :202) → живой `KRASNO: клеток 41, красных 33`, поимённо тот же список.
- `W --model`, `--seed 7`, `--repo model` → 41/41 (:57, :199) → 41/41 каждый, rc 0.
- C10 = 2976 = 62×4×3×2×2 (:41, :57, :192, :199) → `expected_count = 62*4*3*2*2` = 2976; D10 = 120 = 6×5×2×2 (:45, :57, :192) → 120; A15 = 140 запретов (20 векторов × 7 форм) + 14 разрешений (2 × 7) (:57, :181, :192, :199) → ZAPRESHCHENNYE 20, RAZRESHENNYE 2, FORMY_RESHETKI 7; d08 = 40 (20 файлов × 2 режима) (:48, :57, :192, :199) → IMENA_DVOJNIKOV 20 × (755, 644).
- 19 имён двойников + ядро = 20 файлов (:37, :48) → IMENA_NAST 19, IMENA_DVOJNIKOV 20; git-режим всех 20 файлов модели 100755.
- 23 пина = 20 + замок + orch-loop + installer (:59, :175, :201, :203; osi.md:5-6) → source.json:.nositeli 23; `ORACLE_TAMPER_PROVERENO nositelej=23`.
- стабов 25, связей 25, `kletok 1, pojmannyh 1` каждый (:58, :175, :200, :203) → файлов stabs/s*.py 25, stab_vhod 25 ключей / 25 связей, каждая — одна клетка, все связанные клетки существуют; прогон — раздел «Сырые команды».
- носителей четыре (контракт «Модель угроз», probe.py:18) → nositeli_modeli/mir_subjekta: двойники, замок, orch-loop, install.
- s04 привязан только к b03 (osi.md:54; stabs/s04.py:1-2) → source.json `"s04.py": ["b03-odin-jivoj-propusk"]`.
- d07 исполняет emulator/gradle/clang/expo run:android (:60) → probe.py:1222-1223 те же четыре.
- первые координаты мутантов арбитража в отчёте автора (C 482, C 3, D 69, D 3, D 2, noexec, A 57) и s24 «A 78» → мои прогоны: те же.
- адрес :316 (§Существующее, OOM-литерал 085 при `rc -eq 137` в ops/server/user/orch-loop) → строка 316 на OBJECT: `[ "$rc" -eq 137 ] && [ "$scoped" -eq 1 ] && log "… OOM: omp убит потолком памяти …"`.
- ЗОНА-строк 3 (architect, implementer, orchestrator) — числом в тексте не заявлено; ПЕРЕСЕЧЕНИЕ-строк 83 — числом не заявлено.
- модель угроз: ЗАЩИЩАЕТ 7 / НЕ ЗАЩИЩАЕТ 11 буллетов — числом в тексте не заявлено (check_threat_model rc 0).
- «Полный четырёхрежимный контроль … 1035.16 с» (:199) — замер автора, не перемерялся как сумма; мои отдельные прогоны: --model 246.6 с, --seed 7 320 с, --repo model 297 с, --stabs 340 с (под нагрузкой станции load≈15–26).

## СОВЕТ (не блокирует; вне перечня арбитража, вне зависимого регресса либо вкус)

СОВЕТ fixtures/workshop_project/oom_zamki_152/probe.py:1001-1067 (C10) — возраст РОДИТЕЛЬСКОГО журнала не ось домена: родительский файл пишется заново на каждой координате (mtime=now). Мутант mc1-parent-journal-age (`pogib`, если у родителя есть session_exit И родительский журнал старше 1 мин): `python3 mut/run_mut.py mc1-parent-journal-age c10-polnyj-domen-sobstvennogo-zhurnala` → `GREEN (149.2s)`; c01/c03/c05 → GREEN. Домен C арбитража родительский возраст не включает (триггер вне домена — по арбитражу не доказательство неполноты перебора), поэтому не блок; но ПОПРАВКА арбитра «не от родителя/возраста журнала» дёшево закрывается осью mtime родителя.
СОВЕТ contracts/152-oom-sessii-i-zamki.md:192, :61 — отсутствующий собственный журнал (net_fajla) отдельной клеткой не покрыт (САМООПИСАНИЕ 1). Мутант mn1-net-fajla-pogib (net_fajla→pogib): c01–c08 и c10 → GREEN (`c10 … GREEN (161.0s)`), красен ТОЛЬКО попутно на c09 (`гонка авто-снятия: PUSCHEM 2, START 2`). Приёмка 6 относит неизменность поставленного замка к C03–C06/C10 — ветвь net_fajla («как было», И-5/И-8) там прямо не судится.
СОВЕТ probe.py:1351-1365 (e01-gigiena-mirov) — клетка ничего не утверждает: после гашения подделок `r = run(['pgrep','-af',NONCE])` без проверки, функция всегда возвращает None. Не из дельты.
СОВЕТ probe.py:1457-1486 (--stabs) — при красном контроле печатается `KRASNO: клеток 41, красных 2; стабы не гонялись`, хотя строки `STAB s01…s25: kletok 1, pojmannyh 1` уже напечатаны (мой первый прогон --stabs при двух живых CI-эмуляторах). Сообщение ложно по смыслу; не из дельты.
СОВЕТ probe.py:1266-1305 (d08) — исполнение после установки идёт по КОПИИ установленного каталога (MirStorozh → shutil.copytree), а не по пути `installed/<имя>`; копия сохраняет байты и режим, но «исполнение установленной поставки» буквально — сам установленный путь.
СОВЕТ probe.py:483-487, 521-527 (D, режим missing) — trace запроса снимается `command_not_found_handle` только при голом `systemctl` из PATH; реализация с `timeout 5 systemctl …` или `command -v systemctl ||` честна по И-10, но покраснеет «запроса Result к SESSION_UNIT нет». Форма команды закреплена текстом И-9 (:45) — ограничение стоит назвать явно.
СОВЕТ probe.py:1215-1250 (d07) — мир задаёт ORCH_DVOJNIKI явно; умолчание orch-loop `${OPS_SERVER_BIN_DST:-$HOME/bin}/dvojniki-strogo` против места установки installer'а не исполняется (расхождение дало бы громкий fail-closed d09 на станции, не дыру).
СОВЕТ contracts/152-oom-sessii-i-zamki.md:39, :210 — И-3 (argv printf %q) и Порядок 2 «двойники байт-в-байт» противоречат друг другу, пока модель несёт дефект А-940 (`scope ` вместо argv): implementer, копирующий модель байт-в-байт, нарушит И-3. Дефект зарегистрирован (NABLIUDENIA_ARCHITECT.md А-940 на main), не скрыто принят; маршрут — за оркестратором.
СОВЕТ contracts/152-oom-sessii-i-zamki.md:182 — НЕ ЗАЩИЩАЕТ (батарея 140) говорит «его неизменность проверяет W --repo, c03–c06», приёмка 6 (:61) — «C03–C06/C10».
СОВЕТ (процесс) — СУД-строка этого вызова (предмет=152; вызов=3) в HANDOFF.md основного чекаута не найдена (поиск `СУД:.*152` по HANDOFF.md — 0 строк); основание вызова — слово владельца в задании и fork n-152-vyzov-kritika-3 (свидетельство консультанта 4467f5e24). Счёт critic по 152: 1 (Crit152, Sol), 2 (Crit152b, Opus), 3 (Crit152c, Opus) ≤ 5. Независимость: автор дельты — architect на openai-codex/gpt-6-sol (отчёт Arch152e; коммит 0f0e1e696 `architect`), судья — anthropic/claude-opus-5-5; семейства разные.

## Что судилось и как

Первое действие — полное чтение /tmp/dev-harness-verify/orch/task-critic152c.md. `git -C /home/harness/dev-harness cat-file -t 0f0e1e69619bba53fd2e987828c34265ddb67117` → `commit`; `rev-parse wip/152/architect` = OBJECT; main = 4467f5e24d441b66cf1cf01892e7853c73034d60. Клон `git clone /home/harness/dev-harness /tmp/dev-harness-verify/Crit152c/repo` + `fetch … wip/152/architect` + `checkout 0f0e1e696…` → HEAD = OBJECT. Основной чекаут не трогался, GIT_DIR/GIT_WORK_TREE не ставились, push нет. Мутанты — только копии модели вне клона (/tmp/dev-harness-verify/Crit152c/{mut,trees,mtree-md1}). Настоящие gradle/clang/expo/emulator, Android, нативные сборки не запускались; только игрушечные двойники батареи.

Предмет суда — `git diff 1dc776399..0f0e1e696` (14 файлов: контракт + 13 в fixtures/workshop_project/oom_zamki_152/) против перечня арбитража (прочитан целиком с main:verdicts/arbitration/contracts-152-arbitraz.md) и зависимый регресс. Новых классов вне перечня не открывал; найденное вне перечня — СОВЕТ.

## Сырые команды и rc (последовательно; гейты — строго по одному)

- `bash fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh --model` → `ZELENO: клеток 41, зелёных 41`, rc 0, real 4m6.6s.
- `… --model --seed 7` → `ZELENO: клеток 41, зелёных 41`, rc 0, wall 320s.
- `… --repo fixtures/workshop_project/oom_zamki_152/model` → `ZELENO: клеток 41, зелёных 41`, rc 0, wall 297s.
- `… --oracle-tamper` → `ORACLE_TAMPER_PROVERENO nositelej=23`, rc 0.
- `…` (без флага) → `KRASNO: клеток 41, красных 33`, rc 1: a01–a15, b01–b04 `SUBJECT_ABSENT` (19); c01, c02, c07, c08, c09, c10 (6); d01, d02, d05, d06, d10, d07, d08, d09 (8); зелёные c03–c06, d03, d04, e02, e01 (8).
- `… --stabs` (1-й прогон, при ДВУХ живых CI-эмуляторах станции `/opt/android-sdk/emulator/qemu/linux-x86_64/qemu-system-x86_64-headless -avd ci-41367454203-1 …` и `… -avd ci135-41367454203-1 …`, `pgrep -af '[q]emu-system'`) → контроль: `KLETKA b01-nol-jivyh-propusk KRASNO: … на станции 2 живых qemu-system`, `KLETKA b03-odin-jivoj-propusk KRASNO: … 3 живых`; `STAB s01.py … s25.py: kletok 1, pojmannyh 1`; `KRASNO: клеток 41, красных 2; стабы не гонялись`, rc 1, wall 364s — флейк окружения, названный в НЕ ЗАЩИЩАЕТ :188 («чужие qemu-процессы станции в момент прогона клетки b01»), не дефект дельты. Зеркало матрицы (`mut/run_stabs.py`, та же материализация mir_subjekta и те же связи source.json) в это окно: 23/23 не-B стабов `CAUGHT` собственной клеткой (s20 → C 482, s21 → D 3, s22 → D 2, s23/s25 → d08, s24 → A 78), s03 на b02 CAUGHT `rc 0 ≠ 1`.
- `… --stabs` (2-й прогон, `pgrep -fc '[q]emu-system'` → 0 до и после) → `STAB s01.py … s25.py: kletok 1, pojmannyh 1` (25 строк), `SUBJEKT_SVJAZI 25, живых 0`, `ZELENO: клеток 41, зелёных 41`, rc 0, wall 340s.
- `bash scripts/pre_critic.sh contracts/152-oom-sessii-i-zamki.md` → `КРИТИК: дверь зелёная`, rc 0.
- `bash scripts/check_ceilings.sh <клон>` → `потолки в порядке`, rc 0.
- `bash scripts/check_precision_gate.sh <клон> contracts/152-oom-sessii-i-zamki.md` → `OK`, rc 0 (TMPDIR=/tmp/dev-harness-verify/Crit152c/tmp).
- `bash scripts/check_threat_model.sh <клон> contracts/152-…` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 7 буллет(ов), НЕ ЗАЩИЩАЕТ 11 буллет(ов))`, rc 0.
- `bash scripts/check_provodka.sh <клон> contracts/152-…` → `проводка: guard не подключён: fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh не вызывается в .githooks/ или .github/workflows/`, rc 1 — ОЖИДАЕМО (норма 038, ЗОНА orchestrator в окне freeze..done).
- `bash scripts/check_zones.sh <клон>` (полный режим, без --incr) → `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41368 · проверено по зонам: 9819`, rc 0, real 10m2.9s.
- `bash scripts/check_charter.sh <клон>` → `уставных документов: 148 · изменений в них: 377 · с разрешения: 377`, rc 0.

## Перечень арбитража — что закрыто (проверено исполнением)

Мутанты арбитража перенесены на ТЕКУЩУЮ модель (`mut/rebase_trees.py`: копия model/ + собственная вставка каждого мутанта Crit152b, diff каждого дерева против модели — только эта вставка) и судились штатно через `subjekt_iz_argumenta(tree,'repo')` (`mut/run_tree.py`):
- m1-parent-age → `c10 -> RED: C 482/2976 координата=(10.5, 'sigterm', None, False, 'sudit'): исход=(0, ('pogib',), ('Holder', 'Next'), 'Next') marker=RABOCHIJ_ZHIV`.
- m1b-parent-dispose → `c10 -> RED: C 3/2976 координата=(0.5, 'dispose', None, False, 'sudit')`.
- m2-fallback-rc137 → `d10 -> RED: D 69/120 координата=('empty', '', 137, False, False): rc=137 OOM=1 NED=1`.
- m3a-fact-only-no-marker → `d10 -> RED: D 3/120 координата=('ok', 'oom-kill', 0, True, False): rc=3 OOM=0 NED=0`.
- m3b-stop-before-fact → `d10 -> RED: D 2/120 координата=('ok', 'oom-kill', 0, False, True): rc=0 OOM=0 NED=0`.
- m5-install-noexec → `d08 -> RED: установленный двойник _jadro.sh отсутствует, не исполним или отличается`; d07 → `RED: emulator: настоящий fake-файл исполнен внутри scope`.
- m6b-refuse-but-run-builds → `a15 -> RED: A 57/140 gradle proba: gradle/bare: конечный fake-файл исполнился`; a05 → RED.
Итого 7/7 красны СВОИМИ клетками; первые координаты совпали с отчётом автора (C 482, C 3, D 69, D 3, D 2, noexec, A 57). Honest-контроль (`--model`, seed 7, `--repo model`) зелёный на полных доменах (C10 2976, D10 120, A15 140+14, d08 40 — счётчики кода `expected_count`/`count != 120` и прохождение без отказа).

Остальные пункты перечня: декоративный sleep c03 убран (diff probe.py); ПОПРАВКА арбитра — оракул C10 (probe.py:1030-1062): pogib только при собственном exit без yield, broshen ручным --osvobodit при k≥60 без exit, инвариантность исхода (rc, RELEASE, START, holder) к четырём состояниям родителя; самоописание М6 исправлено (osi.md:1 «41 клетка (A 15 / B 4 / C 10 / D 10 / E 2)» = 41 строка таблицы, строка a10 возвращена; probe.py:18 «четыре носителя»); s04 приведён к source.json (b03); НЕ ЗАЩИЩАЕТ :178 называет измеренный остаток (прямой fake clang++, вложенный bash -c/exec, смена PATH) без «только злонамеренный» («могут быть обычные случайные запуски, а не только злонамеренный обход»); И-3 argv-дефект отмечен в «Сдаче» :204 как зарегистрированный — на main есть NABLIUDENIA_ARCHITECT.md `А-940 … ОТКРЫТО` (`git grep -c 'А-940' main -- NABLIUDENIA_ARCHITECT.md` → 1); «Сдача» больше не выдаёт безфлаговую 140 за приёмку 6.

## Зависимый регресс — не ослаблен

- Владельческое сужение (forks/n-152-blok2-granitsa-zapreta-v-scope.md:21, вариант А) исполнено по слову: Frontier :26 и НЕ ЗАЩИЩАЕТ :178 — PATH + явный файл двойника; абсолютный путь, ./gradlew, sh -c/env/exec, изменённый PATH — остаток; правило станции 31.10 безусловно организационно (:8, :26, :35, :162, :178, Порядок :209 и п.3).
- qemu-system-x86 в списке И-1 (:37), a13 зелёна на модели, красна SUBJECT_ABSENT без субъекта; e02 зелёная демаркация (`KLETKA e02-prjamoj-put-vne-ohvata OK` во всех режимах модели).
- §Приёмка 6 (:61) сохранена: CI-контроль 140 — `--model`; безфлаговый и --stabs 140 по лимитам u01/w20/w21 названы в НЕ ЗАЩИЩАЕТ (:182). Батарею 140 сам не гонял (НЕ проверено).
- Клетки 152 — игрушечные миры (tempfile-миры, двойники systemd-run/systemctl в PATH мира, fake-файлы). Исключение, существовавшее до дельты и названное в НЕ ЗАЩИЩАЕТ: B-клетки считают ВСЕ живые qemu станции (pgrep) — см. «НЕ проверено».
- ЗОНЫ/ПЕРЕСЕЧЕНИЯ: 3 ЗОНА-строки, 83 ПЕРЕСЕЧЕНИЕ-строки; precision-gate 043 rc 0, check_zones rc 0. ПРОВОДКА: `guard=fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh`, check_provodka rc 1 ожидаемо (038).

## Собственные мутанты ВНУТРИ доменов (сырые итоги)

- md1-query-before-scope (D): полный `W --repo /tmp/dev-harness-verify/Crit152c/mtree-md1` → `ZELENO: клеток 41, зелёных 41`, rc 0 — ЖИВ → БЛОКИРУЕТ.
- md3-unit-not-bound (D): d01, d02, d04, d06, d07, d10 → GREEN (cell-level) — ЖИВ, тот же класс.
- mc1-parent-journal-age (C): c01, c03, c05, c10 → GREEN — ЖИВ, триггер вне домена → СОВЕТ.
- mn1-net-fajla-pogib (C): c01–c08, c10 → GREEN, c09 → RED `PUSCHEM 2, START 2` — пойман попутно.

## НЕ проверено этим судом

- Живая станция: установка двойников, kernel-факт cgroup в настоящем scope, Result настоящего oom-kill, systemd GC/LoadState — не запускались (запрет задания; игрушечные двойники only).
- Батарея 140 (`odin_agent_140/red_odin_agent_140.sh --model`, приёмка 6) — не гонялась; сверен только текст :61, :182.
- md3-unit-not-bound — только на клетках d01, d02, d04, d06, d07, d10 (полный W --repo для md3 не гонялся); полный W --repo — для md1.
- Сумма «1035.16 с» четырёх режимов автора не перемерялась одним прогоном (мои режимы гонялись по отдельности при load average 15–26).
- B-клетки считают ВСЕ живые qemu станции (pgrep): в окне суда CI-раннер держал два настоящих эмулятора; итог --stabs взят из прогона при нуле живых qemu.
- Мутанты — не исчерпание: искались внутри доменов C/D/A/I арбитража; домены A и поставки (I) собственных выживших мутантов не дали (m5, m6b, s23–s25 красны), отдельного перебора всех форм A сверх решётки не делал.

## Итог

FAIL: один блокирующий класс (D: Result не привязан к запущенному scope по времени/имени — md1 зелёный 41/41 на `W --repo`), два пункта САМООПИСАНИЯ, советы. Перечень арбитража в остальном закрыт исполнением: семь мутантов арбитража красны своими клетками, честный контроль зелёный, ПОПРАВКА арбитра в оракуле C10 соблюдена, зависимый регресс (сужение владельца, qemu-system-x86, e02, приёмка 6, правило станции, ЗОНЫ, ПРОВОДКА) не ослаблен. По слову владельца: FAIL третьего вызова — стоп и решение владельца; четвёртого вызова нет. FAIL не только по самоописанию — форк консультанту по правилу 31.10 не применим.
