FAIL
OBJECT=bdf34324e4350cded242ae97941c00f1bfc46332
СУД: repo=dev-harness; предмет=152; фаза=контракт (+красная батарея), scoped по микро-дельте Arch152f (`git diff 88b573156 bdf34324e`, 6 файлов) по блоку класса 5 домена D вердикта Crit152c, самоописанию и зависимому регрессу; роль=critic; вызов=5/5 (ДОПОЛНИТЕЛЬНЫЙ по слову владельца 2026-11-02 ~10:55 UTC, форк n-152-vyzov-kritika-5, взамен ОБОРВАННОГО без вердикта вызова 4 Crit152d); модель-план=anthropic/claude-opus-5-5; сессия=Crit152e; модель-факт=anthropic/claude-opus-5-5; SHA=bdf34324e4350cded242ae97941c00f1bfc46332; предыдущие=verdicts/critic/contracts-152-v1-fail.md (FAIL, Sol), contracts-152-v1b-fail.md (FAIL, Opus), verdicts/arbitration/contracts-152-arbitraz.md (Arb152c), contracts-152-v1c-fail.md (FAIL, вызов 3, Opus, OBJECT 0f0e1e696); исключение=нет (РАЗРЕШИЛ-ВЛАДЕЛЕЦ в задании; СУД-запись ДО вызова — HANDOFF main 8467a408e).
ОСТАНОВКА: FAIL пятого вызова — по слову владельца стоп и решение владельца; шестого вызова нет. Арбитр этим вердиктом НЕ созывается (арбитраж по предмету уже был, §Остановка). FAIL не только по самоописанию, поэтому форк консультанту по правилу 31.10 не применяется.

## Итог в трёх строках

- Блок Crit152c закрыт для двух его примеров: md1 (запрос до scope) и md3 (scope без `--unit`) на bdf34324e краснеют своими D-клетками на полном `W --repo` (`KRASNO: клеток 41, красных 4`: d01/d04/d06/d10). Честная модель зелёная: 41/41 и D10 120/120. Семь мутантов арбитража красны своими клетками. Зависимый регресс не ослаблен.
- Остался один блокирующий класс внутри того же свойства (привязка по ВРЕМЕНИ). Дельта заменила `exec "$@"` у двойника systemd-run на `"$@"`. Теперь двойник держит канал подтверждения SCOPED (fd 3) открытым до возврата scope. В мире D «scope подтверждён» совпадает с «scope вернулся», и субъект, читающий Result после подтверждения, но ДО возврата scope, проходит 41/41.
- Самоописание: расхождений текста с живыми числами нет (полный список ниже).

## БЛОКИРУЕТ (один класс)

БЛОКИРУЕТ fixtures/workshop_project/oom_zamki_152/probe.py:471-486 (двойник systemd-run дельты: `"$@"` / `rc=$?` / запись `returned-unit` / `exit "$rc"` вместо `exec "$@"`); contracts/152-oom-sessii-i-zamki.md:45, :60, :192, :199. Класс 5 (литерал 085 при Result=oom-kill), привязка ответа Result по ВРЕМЕНИ.
ОБЯЗАТЕЛЬСТВО: И-9 (:45) «orch-loop читает `systemctl --user show "$SESSION_UNIT" …` после возврата scope»; приёмка 5 (:60) «D10 наблюдает вызов Result после возврата scope под именем SESSION_UNIT»; демаркация (:192) «ответ Result привязан к `--unit` только после возврата scope». Закрывающее свойство Crit152c: «… и только после возврата этого scope; запрос до возврата scope … не даёт `oom-kill` — и на каждой oom-kill-координате … такой субъект краснеет». Арбитраж Arb152c, §Классы 4 и 5: «После возврата подтверждённого scope должен быть наблюдаем запрос Result именно SESSION_UNIT».
КЛАСС ПРИЧИНЫ: мир D не отличает «scope подтверждён (SCOPED)» от «scope вернулся». Настоящий `systemd-run --scope` исполняет команду через exec: fd 3 канала подтверждения живёт только в scope-команде, и та закрывает его (`exec 3>&-`) ДО exec агента, поэтому EOF канала приходит при СТАРТЕ сессии. Двойник дельты запускает команду дочерним процессом и сам держит унаследованный fd 3 (`3>/dev/fd/8` из orch-loop) до своего выхода. EOF канала (`wait "$receipt_pid"` в orch-loop) наступает только ПОСЛЕ возврата scope и после записи `returned-unit`. Вдобавок агент мира завершается за миллисекунды, так что любое чтение «после старта» почти наверняка попадает уже после возврата.
СОСТОЯНИЕ: конформный D-вход любой oom-kill-координаты, например d01 (oom-kill, rc 143, боль 12:01), d06, D10 `('ok','oom-kill',0,False,False)`. Субъект md5c-query-after-receipt-before-wait делает две правки модели orch-loop. Первая: same-user запуск scope уходит в фон (`… 9>&- &` / `scope_pid=$!`); канал SCOPED, хвост `"$AGENT_CMD" "$MSG"` и `--unit="$SESSION_UNIT"` не меняются. Вторая: блок факта OOM стоит сразу за `scoped=1`, то есть после подтверждения SCOPED, а уже за ним `wait "$scope_pid"; rc=$?`. На станции такой запрос попадает в ЖИВОЙ scope: сессия длится часы, Result ещё не `oom-kill`, литерал 085 после настоящего oom-kill не пишется никогда. Это ровно класс 5 и боль 31.10. ПЕРЕСЕЧЕНИЕ implementer orch-loop — 074 (contracts:71: «новые строки чтения факта до веток выхода не трогают форму запуска и наблюдателя») запрещает фоновый запуск только ТЕКСТОМ. Это когнитивный запрет для ревьюера, а не красная клетка. Приёмка 5 обещает именно механическое наблюдение «вызов Result после возврата scope», и мир его не держит. Остатку D (:180: «вне rc …, других Result, долгих цепочек повторных сессий, физической доступности факта юнита после GC») и остатку арбитража этот вход не принадлежит.
ОБХОД: `bash fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh --repo /tmp/dev-harness-verify/Crit152e/trees/md5c` → `ZELENO: клеток 41, зелёных 41`, rc=0, real 2m22.8s, `pgrep -fc '[q]emu-system'` → 0. Сырой лог — /tmp/dev-harness-verify/Crit152e/mut/md5c-full.log. sha256 мутантного orch-loop — 0becc89f67dede588d3109a497824368f24e257d8bf1d95ff47a47c6d7da6074; `diff -r model trees/md5c` — только ops/server/user/orch-loop.
НАБЛЮДЕНИЕ:
- Механизм проверен прямой пробой /tmp/dev-harness-verify/Crit152e/mut/fd3_probe.sh. Scope-команда пишет SCOPED, закрывает fd 3 и работает 2 с. Результат: `delta: receipt=SCOPED receipt_eof_after=2.00s scope_return_after=2.01s` против `exec: receipt=SCOPED receipt_eof_after=0.00s scope_return_after=2.00s`.
- По клеткам: `python3 mut/run_mut.py md5c-query-after-receipt-before-wait d01-fakt-oom-rc143 d04-fakt-oom-rc137 d06-fakt-oom-rc0 d02-rc137-result-success`, три повтора → все `GREEN`. `python3 mut/run_mut.py md5c-query-after-receipt-before-wait d10-polnyj-domen-result d07-scope-path-marker-v-dejstvii d09-storozh-ne-ustanovlen`, два повтора → `d10 … GREEN (19.4s)` / `GREEN (19.1s)`, d07/d09 `GREEN`.
- Тот же класс без канала, с фиксированной задержкой: md5-query-while-running (scope в фоне, `sleep 0.2`, запрос, `wait`) → d01/d04/d06/d02/d03/d05 `GREEN`, `d10-polnyj-domen-result -> GREEN (43.7s)`. Здесь причина — мгновенный агент мира.
- Контроль: md5b (scope в фоне, запрос сразу, без задержки и без ожидания канала) → d01/d04/d06 `RED` («OOM_RESULT_NEDOSTUPEN (rc=?)»). Двойник верно отказывает, пока scope реально не вернулся. Дыра — в синхронизации мира, а не в проверке имени.
- Свойство достижимо без изменения честного исхода. Одноразовая проба /tmp/dev-harness-verify/Crit152e/mut/achievable.py только демонстрирует это и не предписывает способ: двойник отпускает свой fd 3 после запуска команды, агент мира живёт 1 с. Тогда `honest d10-polnyj-domen-result -> GREEN (139.5s)`, d07/d09 `GREEN`, d01/d02/d04/d05/d06 `GREEN`, а md5c `RED: D 1/120 координата=('ok','oom-kill',0,False,False): rc=0 OOM=0 NED=1` и d01/d04/d06 `RED`. md1/md3/md5b при этом остаются `RED`. md5 (`sleep 0.2`) в той же пробе → d01/d04/d06 `RED`, `d10 RED: D 1/120 … NED=1`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: в мире D подтверждение запуска scope (SCOPED по каналу fd 3/7/8) наблюдаемо отделено от возврата scope, как у настоящего `systemd-run --scope`. Двойник не удерживает переданный scope-команде дескриптор канала дольше, чем сама команда. Сессия агента мира длится дольше, чем путь orch-loop от подтверждения до чтения Result. Тогда субъект, читающий Result после SCOPED, но до возврата scope (в фоне или по задержке), краснеет на каждой oom-kill-координате (d01/d04/d06/D10). Честная модель при этом остаётся зелёной на всех 120 комбинациях и на 41/41, md1/md3 остаются красными. Способ (exec-семантика, закрытие fd 3 в двойнике после fork, отметка старта/возврата в trace, длительность агента) — за автором.

## САМООПИСАНИЕ (полный список «число/утверждение в тексте → живое значение»)

Расхождений: 0.

Пункты Crit152c:
- п.1, contracts:192 — было «отсутствие собственного журнала и гонка остаются отдельными C-клетками», стало «гонка покрыта c09, отсутствие собственного журнала отдельной C-клеткой не проверяется». Живое значение: C-код дельтой не тронут (`git diff 88b573156 bdf34324e --stat`: probe.py изменён только в MirLoop, строки 469-510); все десять C-клеток пишут журнал holder (подтверждено Crit152c; код C не менялся). Текст теперь честен. Закрыто ПРАВКОЙ ТЕКСТА — по оговорке консультанта.
- п.2, contracts:205 — было «148 замороженных, 9799 проверенных по зонам», стало «число … меняется с основой и коммитом; живые числа — в отчёте на SHA». Застывшего числа в тексте нет. Мой прогон на OBJECT: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41844 · проверено по зонам: 10009`, rc 0; совпадает с числами отчёта автора (148/5/41844/10009).
- И-3 / Порядок п.2 (:39, :204, :210). Противоречие снято: Порядок п.2 требует «по поведенческому канону модели, НО не побайтово для дефекта А-940 … реализация обязана передать в `zhurnal` исходные argv и выполнить И-3»; :204 называет дефект А-940. Живое значение: `_jadro.sh:65-72` пишет `printf '%q ' "$@"` внутри функции `zhurnal`, то есть собственные аргументы функции (`scope`/`stanca`), — дефект описан верно. Оракул батареи поле argv не пинит (`zhurnal_soderzhit`: `r[2] == imja`; d07: `'\tscope\t%s\t' % imja`), поэтому реализация с исправленным argv не краснеет. А-940 на main — NABLIUDENIA_ARCHITECT.md:8745 `ОТКРЫТО`.

Сверено и совпало:
- 41 клетка, A 15 / B 4 / C 10 / D 10 / E 2 (:56-:58, :60, :162, :199-:202; osi.md:1) → `@kletka` в probe.py 41; строк таблицы osi.md 41 (A 15, B 4, C 10, D 10, E 2); каждый режим печатает `клеток 41`.
- Без реализации красных 33 (:56, :162, :202): 19 A/B SUBJECT_ABSENT + C01/C02/C07/C08/C09/C10 + D01/D02/D05/D06/D07/D08/D09/D10, C03/e02 зелёные → `W` без флага: `KRASNO: клеток 41, красных 33`, rc 1, поимённо тот же список (зелёные c03–c06, d03, d04, e02, e01).
- check_zones (:205, без застывшего числа) → `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41844 · проверено по зонам: 10009`, rc 0.
- 27 стабов / 27 связей / `STAB s01…s27` / `SUBJEKT_SVJAZI 27, живых 0` (:58, :175, :200, :203) → `ls stabs/s*.py` 27; `jq '.stab_vhod|length'` 27; `jq '[.stab_vhod[]|length]|add'` 27; s26 → d01-fakt-oom-rc143, s27 → d04-fakt-oom-rc137 (source.json); прогон --stabs: `STAB s01.py … s27.py: kletok 1, pojmannyh 1` (27 строк, включая s26/s27), `SUBJEKT_SVJAZI 27, живых 0`, `ZELENO: клеток 41, зелёных 41`, rc 0.
- C10 = 2976 = 62×4×3×2×2 (:41, :57, :192, :199) → probe.py:1013 `expected_count = 62 * 4 * 3 * 2 * 2`; D10 = 120 = 6×5×2×2 (:45, :57, :192, :199) → probe.py:1198 `if count != 120`; A15 = 140 + 14 (:57, :181, :192, :199) → ZAPRESHCHENNYE 17+3 = 20, RAZRESHENNYE 2, FORMY_RESHETKI 7; d08 = 40 (:48, :57, :192, :199) → IMENA_DVOJNIKOV 20 × (755, 644).
- 19 имён + `_jadro.sh` = 20 файлов (:37, :48, :203; osi.md:5) → IMENA_DVOJNIKOV 20, IMENA_NAST 19; каталог model/…/dvojniki 20 файлов.
- 23 носителя (:59, :175, :201, :203; osi.md:5-6) → `jq '.nositeli|length'` 23; `W --oracle-tamper` → `ORACLE_TAMPER_PROVERENO nositelej=23`, rc 0.
- «четыре носителя» (модель угроз :166; probe.py:18) — без изменений.
- :200 «7/7 красных своей клеткой C10/D10/d08/A15; md1 и md3 красны своей D-клеткой, полный D10 остаётся зелёным на честной модели» → мои прогоны (раздел «Перемер блока»): 7/7 RED, md1/md3 RED d01/d04/d06/d10, честный D10 зелёный.
- :18 адрес `(:316)` → ops/server/user/orch-loop:316 на OBJECT: `[ "$rc" -eq 137 ] && [ "$scoped" -eq 1 ] && log "… OOM: omp убит потолком памяти (MemoryMax=$MEM_MAX, rc=137)"`.
- :199 «1035.16 с относилась к прошлому OBJECT» — время, не счётное утверждение о SHA; мои замеры: --model 2m22.4s, --seed 7 2m25.8s, --repo model 2m26.7s, --stabs 2m48.2s.
- Модель угроз ЗАЩИЩАЕТ 7 / НЕ ЗАЩИЩАЕТ 11 — числом в тексте не заявлено; check_threat_model rc 0.
- osi.md:49 (строка d10) — «systemd-run подтверждает `--unit` и возвращает scope прежде, чем systemctl отдаёт Result этому юниту». Совпадает с кодом по имени и по факту возврата двойника. Именно эта формулировка («подтверждает … и возвращает») в мире не различима — см. БЛОКИРУЕТ, это не счётное расхождение.

## СОВЕТ (не блокирует)

СОВЕТ probe.py:471-505 (привязка по имени при повторном запуске) — двойник отвечает для ИМЕНИ юнита после возврата ЛЮБОГО scope с этим `--unit`, а не именно scope сессии. Субъекты с лишним «пробным» scope под SESSION_UNIT проходят D10:
- mp1-preflight-unit-session-unbound: `systemd-run --user --scope -q --unit="$SESSION_UNIT" -- true` перед coproc, сама сессия без `--unit` → d01/d02/d03/d04/d05/d06 `GREEN`, `d10 -> GREEN (19.3s)`;
- mp2-preflight-then-query-before-scope: пробный scope и запрос ДО настоящего scope с `--unit` → те же клетки `GREEN`, `d10 -> GREEN (19.2s)`.

Буквально свойство Crit152c («юнит, который двойник systemd-run действительно запустил под этим --unit … после возврата этого scope») здесь соблюдено: пробный scope запущен и вернулся. Конструкция — две противоестественные правки (второй запуск под именем сессии), поэтому это СОВЕТ, а не блок. Закрыть можно дёшево: Result отдаётся только для запуска, несущего команду агента (хвост `"$AGENT_CMD" "$MSG"`), либо повторный запуск под тем же `--unit` в одной сессии ведёт к отказу.

СОВЕТ probe.py:473-481 (точность, не дыра) — двойник распознаёт только `--unit=X`. Честная форма `--unit X` либо `--unit="${SESSION_UNIT%.scope}"` (systemd-run --scope сам добавляет `.scope`) на станции правильна, а в мире краснеет: hp1-launch-without-suffix → d01/d04/d06 `RED` («OOM_RESULT_NEDOSTUPEN»). Форма закреплена моделью и И-9; ограничение стоит назвать в демаркации D.

СОВЕТ probe.py:1186-1191 — md4-unit-no-suffix (SESSION_UNIT без `.scope` с обеих сторон; на станции запрос ушёл бы к `<имя>.service`) зелен на d01–d06 и пойман только trace-проверкой D10 (`D 1/120 … запроса Result к SESSION_UNIT нет`). Это верно, но держится одной клеткой.

СОВЕТ (процесс) — отчёт автора про check_zones на итоговом SHA помечен самим автором `[INFERENCE] rc0 … канал фонового результата не напечатал отдельного exit code`, а текст :205 говорит «check_zones rc 0 на кандидате». Мой прогон закрывает это наблюдением: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41844 · проверено по зонам: 10009`, rc 0 — утверждение :205 верно.

## Перемер блока Crit152c исполнением (сырые итоги)

Мутанты накладываются на материализованную копию модели (`probe.mir_subjekta`, stub=ZAMENA) либо на деревья вне клона, только в /tmp/dev-harness-verify/Crit152e/{mut,trees}; дерево автора не правилось. Перед каждым прогоном с B-клетками `pgrep -fc '[q]emu-system'` → 0.
- md1-query-before-scope (дерево Crit152c/mtree-md1, sha256 orch-loop e539644a…; `diff -r` с текущей model — только перенос блока): `W --repo /tmp/dev-harness-verify/Crit152c/mtree-md1` → `KRASNO: клеток 41, красных 4` (d01 «факт oom-kill при rc=143 не дал литерал 085 … OOM_RESULT_NEDOSTUPEN (rc=?)», d04, d06, d10 `D 1/120 координата=('ok','oom-kill',0,False,False): rc=0 OOM=0 NED=1`), rc 1, real 2m2.4s. Лог: Crit152e/mut/md1-full.log.
- md3-unit-not-bound (Crit152e/trees/md3-unit-not-bound, sha256 orch-loop 86df7000…, одна замена `"${SCOPE[@]}" --unit="$SESSION_UNIT" -- sh -c` → `"${SCOPE[@]}" -- sh -c`): `W --repo …` → `KRASNO: клеток 41, красных 4` (d01, d04, d06, d10 `D 1/120 … NED=1`), rc 1, real 2m3.95s. Лог: Crit152e/mut/md3-full.log.
- По клеткам (`python3 mut/run_mut.py <m> d01 d04 d06 d02 d03 d05`): honest — все GREEN; md1, md3 — d01/d04/d06 RED, d02/d03/d05 GREEN; md5b — d01/d04/d06 RED; md5, md5c, mp1, mp2 — все GREEN (см. БЛОКИРУЕТ/СОВЕТ); md4 — все GREEN, d10 RED; hp1 — d01/d04/d06 RED.
- Арбитраж 7/7 (деревья Crit152c/trees; `diff -r` с текущей model — только собственная вставка каждого; модель между 0f0e1e696 и bdf34324e не менялась, `git diff --stat 0f0e1e696 88b573156 -- fixtures/workshop_project/oom_zamki_152` пуст, дельта model/ не трогает), `python3 mut/run_tree.py`:
  - m1-parent-age c10 → `RED: C 482/2976 координата=(10.5, 'sigterm', None, False, 'sudit')`;
  - m1b-parent-dispose c10 → `RED: C 3/2976 координата=(0.5, 'dispose', None, False, 'sudit')`;
  - m2-fallback-rc137 d10 → `RED: D 69/120 координата=('empty', '', 137, False, False): rc=137 OOM=1 NED=1`;
  - m3a-fact-only-no-marker d10 → `RED: D 3/120 координата=('ok', 'oom-kill', 0, True, False)`;
  - m3b-stop-before-fact d10 → `RED: D 2/120 координата=('ok', 'oom-kill', 0, False, True)`;
  - m5-install-noexec → d08 `RED: установленный двойник _jadro.sh отсутствует, не исполним или отличается`, d07 `RED: emulator: настоящий fake-файл исполнен внутри scope`;
  - m6b-refuse-but-run-builds → a15 `RED: A 57/140 gradle proba: gradle/bare: конечный fake-файл исполнился`, a05 `RED`.

## Зависимый регресс — не ослаблен

- Дельта меняет строки контракта только в :45, :58, :60, :175, :192, :199-:200, :203-:205, :210 (`git diff -U0 88b573156 bdf34324e -- contracts/…`). Строки сужения и остатка (:26, :35, :162, :178), И-1 с `qemu-system-x86` (:37), §Приёмка 6 (:61), НЕ ЗАЩИЩАЕТ 140 (:182), флейк b01 (:188) и Порядок п.1/п.3 (:209, :211) не изменены.
- Сужение до PATH + явный файл двойника (слово владельца 01.11 ~21:00): Frontier :26 и НЕ ЗАЩИЩАЕТ :178 дословно прежние. Остаток назван без «только злонамеренный обход» («могут быть обычные случайные запуски, а не только злонамеренный обход»). Абсолютный путь, ./gradlew, sh -c/env/exec, вложенный bash и изменённый PATH — остаток, не блок.
- `qemu-system-x86` в И-1 (:37); a13 зелёная в --model/--seed 7/--repo model, без субъекта красна SUBJECT_ABSENT; e02 зелёная во всех режимах модели и без флага.
- §Приёмка 6: `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, последние строки `CASE w20-limit-harness-tri-ok ok`, `CASE w21-limit-back-tri-ok ok`, `CASE w22-limit-back-chetyre ok`, real 5.1s. Остаток «безфлаговый и --stabs 140 красны по лимитам u01/w20/w21» (:182) сохранён.
- Побочный эффект дельты на 997: канал SCOPED в мире D теперь закрывается при возврате scope, а не при старте — см. БЛОКИРУЕТ. Клеток канала подтверждения в батарее нет (`grep 'не подтверждён\|SCOPED\|receipt' probe.py` → 0 строк), и иных регрессов честной модели это не дало (41/41 во всех режимах).

## Сырые команды и rc (последовательно; гейты — строго по одному)

Первое действие — полное чтение /tmp/dev-harness-verify/orch/task-critic152e.md. `git -C /home/harness/dev-harness cat-file -t bdf34324e4350cded242ae97941c00f1bfc46332` → `commit`. Клон: `git clone /home/harness/dev-harness /tmp/dev-harness-verify/Crit152e/repo` + `fetch … wip/152/architect` + `checkout bdf34324e…`; main = 342186cf02d6949980ea93dd15e1a52fcdc8a524, wip/152/architect = OBJECT. Основной чекаут не трогался, GIT_DIR/GIT_WORK_TREE не ставились, push не было. Эмуляторы, Android и нативные сборки не запускались; работали только игрушечные двойники батареи. Чужие qemu не трогались: их не было, `pgrep -af '[q]emu-system'` → пусто, rc 1.
- `W` (без флага) → `KRASNO: клеток 41, красных 33`, rc 1, real 2.8s.
- `W --model` → `ZELENO: клеток 41, зелёных 41`, rc 0, real 2m22.4s.
- `W --model --seed 7` → `ZELENO: клеток 41, зелёных 41`, rc 0, real 2m25.8s.
- `W --repo fixtures/workshop_project/oom_zamki_152/model` → `ZELENO: клеток 41, зелёных 41`, rc 0, real 2m26.7s.
- `W --stabs` → 27 строк `STAB sNN.py: kletok 1, pojmannyh 1` (s01…s27), `SUBJEKT_SVJAZI 27, живых 0`, `ZELENO: клеток 41, зелёных 41`, rc 0, real 2m48.2s (`pgrep -fc '[q]emu-system'` до и после → 0). Лог: Crit152e/mut/stabs.log.
- `W --oracle-tamper` → `ORACLE_TAMPER_PROVERENO nositelej=23`, rc 0.
- `bash scripts/pre_critic.sh contracts/152-oom-sessii-i-zamki.md` → `ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3` / `КРИТИК: дверь зелёная`, rc 0 (TMPDIR=/tmp/dev-harness-verify/Crit152e/tmp).
- `bash scripts/check_ceilings.sh <клон>` → `потолки в порядке`, rc 0.
- `bash scripts/check_precision_gate.sh <клон> contracts/152-oom-sessii-i-zamki.md` → `OK`, rc 0.
- `bash scripts/check_threat_model.sh <клон> contracts/152-…` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 7 буллет(ов), НЕ ЗАЩИЩАЕТ 11 буллет(ов))`, rc 0.
- `bash scripts/check_provodka.sh <клон> contracts/152-…` → `проводка: guard не подключён: fixtures/workshop_project/oom_zamki_152/red_oom_zamki_152.sh не вызывается в .githooks/ или .github/workflows/`, rc 1. Это ОЖИДАЕМО: норма 038, ЗОНА orchestrator в окне freeze..done.
- `bash scripts/check_charter.sh <клон>` → `уставных документов: 148 · изменений в них: 379 · с разрешения: 379`, rc 0.
- `bash scripts/check_zones.sh <клон>` (полный режим, без --incr) → `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41844 · проверено по зонам: 10009`, rc 0, real 6m56.0s; лог Crit152e/mut/check_zones.log.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0.

## Независимость и счёт

Автор дельты — architect Arch152f на openai-codex/gpt-6-sol (отчёт /tmp/dev-harness-verify/Arch152f/report.md; коммит bdf34324e под identity architect). Судья — anthropic/claude-opus-5-5: семейства разные, судья своей работы не судит. Счёт critic по 152: 1 (Crit152, Sol), 2 (Crit152b, Opus), 3 (Crit152c, Opus), 4 (Crit152d, оборван без вердикта, засчитан), 5 (этот, Crit152e). Вызов 5 из 5 — предел исчерпан. СУД-запись ДО вызова есть в HANDOFF main (8467a408e, строка «152 вызов 5 из 5 — Crit152e, модель-план anthropic/claude-opus-5-5, OBJECT bdf34324e…»). Сырые прогоны Crit152d в приёмку не засчитывались: все числа здесь мои.

## НЕ проверено этим судом

- Живая станция: настоящий systemd-run/systemctl, Result реального oom-kill, GC юнита, kernel-факт cgroup. Не запускались по запрету задания. Exec-семантика настоящего `systemd-run --scope` взята из документированного поведения и из модели 997 (комментарий orch-loop: «systemd-run --scope (exec) → sh …»), а не из живого прогона на станции [INFERENCE для станции].
- md5c, md5, mp1, mp2 на полном `W --repo` — только md5c (41/41). md5/mp1/mp2 гонялись по клеткам d01–d06 и d10.
- achievable.py — одноразовая демонстрация достижимости свойства (подмена двойника в памяти). Это не предложение реализации и не прогон штатной батареи.
- Перебор мутантов не исчерпывающий: искались привязка по имени (md3, md4, hp1, mp1), по времени и порядку (md1, md5, md5b, md5c, mp2). Новых классов вне блока не открывал (запрет задания).
- Батарея 140 без флага и с --stabs не гонялась (остаток :182, не приёмка).
