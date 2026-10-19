accept
OBJECT=64768e1653643dad186b18e5634f748166631241

# Reviewer — контракт 997, реализация, круг 3 (последний по капу)

- **OBJECT:** 64768e16, land `wip/997/implementer`.
- **Коммиты 997 этого круга** (`git log b2232780..64768e16`, автор по `%an`):
  - implementer e5e6b24d (Рс2-1/2/3);
  - architect bcdff984 (проба);
  - architect 2fe1de47 (PIN 074).
  - Остальные коммиты диапазона относятся к 998/999, forks и owner. 997 они не касаются.
- **Frozen:** `frozen/contracts/997/1` → d67c32a4. `git diff --quiet frozen/contracts/997/1 OBJECT -- contracts/997-…md` → блоб контракта неизменен.
- **Блокирующих находок нет.** Р2-1, Р2-2 и Р2-3 закрыты, каждая проверена своей мерой. Советов шесть (С3-1…С3-6), они не блокируют. Отдельный findings.md не нужен, потому что вердикт не FAIL.
- **Клон и репро:** `/tmp/dev-harness-verify/reviewer997r3/` (clone/, alt/, logs/, subj/). В рабочее дерево я не заходил.

## Закрытие круга 2 (своей мерой)

| ID | Статус | Своя мера |
|---|---|---|
| Р2-1 | **закрыт** | см. ниже по пунктам |
| Р2-2 | **закрыт** | `alt/killscope.sh`, `alt/battery.sh` (честный и noop-мутант) |
| Р2-3 | **закрыт** | `git show e5e6b24d`: строка 90 приведена к одному аргументу `"$tag"` при формате с одним `%s` |

### Р2-1, по пунктам

- **Причина `exec 9>&-` в наблюдателе.** Теперь в тексте указана причина «осиротевший наблюдатель после SIGKILL держит lock бессрочно». Места: orch-loop:56-63, :164-168 и README:83-88. Своя мера:
  - `alt/subjmut.py nowatchclose`: субъект OBJECT без этой строки на `probe.py --case lock_after_death` → rc=1, `errors: ["LOCK_AFTER_DEATH"]`;
  - `alt/lockfree.sh`, честный OBJECT, SIGKILL цикла через 0,3 / 2 / 7 с после старта агента: lock освобождается через **4,680 / 2,970 / 0,003 с**.
  - Утверждение «в пределах 5 с» верно.
- **Relay.** Строка `exec 9>&-` в coproc теперь названа «гигиеной». Это честно: в круге 2 r2_nocatclose прошёл 32/0, наблюдаемого свойства у строки нет.
- **dup или reopen.** Текст теперь говорит «НОВОЕ открытие … НЕ `dup(2)` … O_NONBLOCK не разделяется» (orch-loop:244-250, :270; README:171-176). Своя мера, `fdsem.py` прогнан мной: «bash 3>/dev/fd/8 shares O_NONBLOCK: False | bash 4>&8 (dup) shares: True». Текст совпадает с замером.
- **EPIPE.** grep `EPIPE` по orch-loop и README → пусто. Новый текст: «закрываем write-end, чтобы cat получил EOF». Замер подтверждает: после закрытия одного write-end запись другим «OK (no EPIPE)».
- **Ссылка на несуществующий файл.** grep `tests/alt|devfd` по README и orch-loop → пусто. Ссылки в README на файлы вида `` `*.sh|py|md|tsv` `` сводятся к `install.sh`, и он существует.
- **«Немедленно».** Теперь в тексте: «в пределах 5 с; нормальный выход — мгновенно». Своя мера `alt/lockfree.sh exit`: штатный выход агента rc 0 при задержке 0,5 и 7 с → lock свободен через **0,002 / 0,002 с**. Единственное оставшееся «немедленно» — README:193 «rc 1 немедленно, без повторов». Это дословно инв. 1 контракта.

### Р2-2

- **`alt/killscope.sh`.** Функция вынута из OBJECT дословно, приманки — мои дети с ppid ≠ 1. Результат:
  - `own` (`OPS093_ROOT=$SCRATCH/s6`) — **УБИТ**;
  - `name` (argv `toy-agent-sleeper`, без маркера) — ЖИВ;
  - `other` (другой SCRATCH) — ЖИВ;
  - `prefix` (`${SCRATCH}Z/s6`) — ЖИВ;
  - `exact` (`$SCRATCH` без `/`) — ЖИВ.
  - Вывод: гасятся только свои процессы, отбор по окружению, чужие не трогаются.
- **`alt/battery.sh`, честный OBJECT** (частные HOME/TMPDIR): rc=0, «ЗЕЛЁНО(093-bat): 10/10». Процессов с TMPDIR этого прогона после выхода 0, через 3 с тоже 0.
- **Красное предъявлено.** Тот же прогон с `kill_own_orphans() { return 0; …` (одноразовый файл в клоне, после прогона удалён) даёт rc=0, 10/10, но **выживших 2**, и через 3 с тоже 2:
  - `sleep 300` с ppid=1;
  - `toy-agent-sleeper 300`;
  - у обоих `OPS093_ROOT=/tmp/dev-harness-verify/ops-granica-bat-seMJU0/s6`.
  - Значит, оба вида сирот несут маркер, и честное гашение не вакуумно. Сирот погасил я сам по TMPDIR моего прогона.
- **Где вызывается гашение.** grep `kill_own_orphans` показывает вызовы до и после каждой из клеток s1…s10 (у s8 после пары 5/6) и в `trap … EXIT` (:37).

## 1. Область правки (зоны по frozen)

- **implementer e5e6b24d** меняет orch-loop, README, 085 и battery_stubs. Все четыре файла в ЗОНЕ implementer. Battery и 085 правятся в пределах целей ПЕРЕСЕЧЕНИЙ:
  - battery: гашение своих сирот и откат printf;
  - 085: только комментарии (снимок, SNAP_LOOP и FIXSIM не тронуты).
  - `git diff frozen OBJECT -- 085 red_limit` содержит только литерал И-5 и комментарии.
- **architect bcdff984** меняет `fixtures/ops_server/orch_loop_997/{backend,probe}.py`. Это ЗОНА architect.
- **architect 2fe1de47** меняет PIN 074 `user/orch-loop` на 30d83712…. Это совпадает с моим `sha256sum ops/server/user/orch-loop` на OBJECT. Правка вне ЗОН, но по стоячей санкции №4 (`docs/owner/2026-10-14-razblokirovka-093-v4-l4-l5.md:49`); прецедент принят в круге 2.
- `git diff --name-only b2232780 OBJECT -- scripts fixtures/case_*` → 0 строк, frozen-барьеры не тронуты. `registry/ci-steps.tsv`, `ci.yml`, roles и contracts в этом круге не менялись.

## 2. Сырой вывод (мои прогоны, клон на OBJECT, частные HOME/TMPDIR)

- **`bash scripts/run_ci_lane.sh check:orch-loop-997`** → `LANE_RC=0`, «997 observed=34 mismatches=0», «997 observed=85 mismatches=0» (лог: `logs/lane997.log`). Своя мера подсчёта (python по лог-строкам):
  - SUBJECT 34 = 17 кейсов × 2 uid, все `errors: []`;
  - HONEST 34, все `errors: []`;
  - MUTANT: 51 прогон, 46 имён, непойманных нет;
  - 34 + 51 = 85. Это совпадает с заявлением architect «34/0, 85/0».
- **`bash scripts/gen_ci_steps.sh --check`** → `GEN_RC=0`.
- **`bash scripts/check_provodka.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md`** → `PROV_RC=0`.
- **`bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka`** → `AP_RC=0`, «барьеров: 2 · фикстур: 54 · предъявлено красным повторным прогоном: 54».
- **`bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast`** → `R085_RC=0`, «итог 085 fast: красных=0».
- **`bash fixtures/ops_granica/red_limit_otkaz_bez_zapuska.sh`** → `R093_RC=0`, «ЗЕЛЁНО(093-2)».
- **CI main на OBJECT**, run 39178713142: success, 12/12 jobs. Из логов job (`gh api …/jobs/<id>/logs`):
  - l7: «997 observed=34 mismatches=0», «997 observed=85 mismatches=0», «итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0», «итог 074: красных клеток=0 стабы=7/7»;
  - l4: «ЗЕЛЁНО(093-bat): 10/10», «ИТОГ 093: rc=0»;
  - l5: «итог 085: красных=0, стабы=40/40, диффпроба=32/32», «итог 080-батареи: … честные 31/31».
- **Локально не запускал** `_krasnye_072`/`_krasnye_080`, полный 085 (м5) и root-дверь 093. Причины те же, что в круге 2: `_toy.sh` трогает живой `/tmp/dev-harness-verify/orch-restart`, а м5 и root по контракту только CI. Вместо них — CI выше.

## 3. Не переписаны ли проверки под код

- Implementer пробу 997 не трогал. В 085 менял только комментарии (С-5 круга 2 закрыт сокращением), в red_limit — без изменений в этом круге.
- **Проба изменена architect-ом (bcdff984)**, и только в сторону усиления:
  - census `held - launch_fds or held & {7,8}` заменён на закрытый перечень `held - {0,1,2}`;
  - `lock_transition` теперь наблюдает lock во время прогона;
  - новые клетка `lock_after_death`, задержка receipt на границе systemd-run (шим `cat` удалён, С-3 закрыт) и 23 мутанта.
  - Прежние клетки и мутанты на месте: все 23 старых имени присутствуют, все пойманы.
- **Красное на субъекте, а не только на model.sh** (`alt/subjmut.py`, мутации OBJECT-субъекта):
  - fd6 → `--case marker_removed` rc=1, `HELPER_FD`;
  - `exec 9>&-` перед reap_session → `--case lock_transition` rc=1, `LOCK_TRANSITION`;
  - без закрытия в наблюдателе → `--case lock_after_death` rc=1, `LOCK_AFTER_DEATH`.
  - Обе дыры адверсария круга 2 и С-2 ревьюера закрыты пробой.

## 4. ПРОВОДКА

- `guard=fixtures/ops_server/orch_loop_997/probe.sh` существует и является барьером этого предмета: `--subject` по умолчанию указывает на `ops/server/user/orch-loop`.
- Строка `step check:orch-loop-997 30 …` присутствует, lane l7 исполнен в CI.
- ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: roles и нормы не тронуты.

## 5. Атомарность и норма

- e5e6b24d закрывает три находки одного круга одного предмета одним коммитом. Это одна задача со ссылкой на 997.
- bcdff984 и 2fe1de47 — отдельные коммиты.
- Нормативные документы диффом 997 не тронуты.

## 050 — артефакты этого круга

Пять вопросов в порядке (1) свойство, (2) состояние, (3) совместные правки, (4) глубина, (5) потребитель.

- **battery `kill_own_orphans` (переписана).**
  - (1) строка приёмки «Battery 093 гасит собственные процессы»;
  - (2) маркер `OPS093_ROOT=$SCRATCH/` в environ, выводится из явного SCRATCH;
  - (3) 1 файл; было 3 ветви, стала 1;
  - (4) новых env, флагов и rc нет;
  - (5) l4 `check:granica-ispolneniya-093-family-selftest`.
  - **ESSENTIAL.** Остаток — неиспользуемый счётчик `killed` (С3-4).
- **battery `trap 'kill_own_orphans; rm -rf'` и вызовы после клеток.** (1) та же строка «до следующей клетки» и после последней. **ESSENTIAL.**
- **orch-loop и README.** Только комментарии, кода не добавлено. Новых артефактов нет.
- **probe: `AGENT_FD_ALLOWLIST`.**
  - (1) инв. 2 «вспомогательные fd закрываются»;
  - (2) константа;
  - (4) упрощает census: убран `launch_fds`.
  - **ESSENTIAL.**
- **probe: генерируемые `fd{3..9}_{devnull,pipe,lock}`, одна семья.**
  - (1) инв. 2;
  - (2) программная таблица, явная;
  - (5) lane l7.
  - **ESSENTIAL.**
- **probe: клетка `lock_after_death` и environ-гашение по TOY_ROOT.**
  - (1) инв. 3 «Lock-fd наблюдатель закрывает ВНУТРИ тела» получает наблюдаемое следствие;
  - (5) l7, мутант `orphan_watcher_lock`.
  - **ESSENTIAL.**
- **backend: fd-3 interceptor в шиме systemd-run.**
  - (1) инв. 2/3 «читается после возврата», relay-независимо;
  - (2) fork-helper и gate-файл в control, явные;
  - (3) удалён шим `cat`, число файлов не выросло.
  - **ESSENTIAL.**
- **PIN 074.** ESSENTIAL (санкция №4), потребитель — `check:ops-server-family-selftest`.

## Советы (не блокируют; круг 3 — только принятые требования)

- [ ] **С3-1.** README:70-73 приписывает мутанты `wrong_home_lock`, `mark_lock`, `log_lock` «батарее 074».
  - Мера: `grep -rl wrong_home_lock fixtures scripts ops` → только `fixtures/ops_server/orch_loop_997/probe.py` и сам README. Это мутанты пробы 997.
  - Ошибка внесена правкой по совету С-4 круга 2. К механизму lock она не относится, поэтому остаётся советом того же класса.
- [ ] **С3-2.** battery_stubs.sh:66-68 ссылается на «образец `probe.py:365-370`». После bcdff984 environ-фильтр TOY_ROOT стоит на probe.py:453 и :468, а на :363-371 теперь census.
  - Там же неточно сказано «(с завершающим `\0`)»: маркер ищется подстрокой записи environ, NUL в нём нет. Без `\0` и нужен, чтобы совпадало `…/s6`.
- [ ] **С3-3.** orch-loop:56-57, :61: незаконченная фраза «Закрытие / # fd 9 закрывается ВНУТРИ». «На каждой итерации lock снимается» — точнее «на первой итерации»: на следующих `exec 9>&-` ничего не делает. Граница «≤ 5 с» верна (своя мера выше).
- [ ] **С3-4.** battery_stubs.sh:74/79: счётчик `killed` вычисляется и нигде не читается. Это уже было отмечено в круге 2. Безопасно удалить, на свойство не влияет.
- [ ] **С3-5 (перенос С-1).** Если lock не открылся, ошибка `exec 9>>` остаётся без именованного payload, и `flock -n 9` отвечает «уже запущен», хотя второго экземпляра нет.
- [ ] **С3-6.** `--case` у probe.py исполняет только uid `same`; оба uid проходят только `--cases` и `--matrix`. Это не дефект: lane гоняет полный прогон. Для будущих судей стоит упомянуть в `--help`.

## Гигиена

- Все пробы шли в одноразовом клоне и в `/tmp/dev-harness-verify/reviewer997r3/`.
- noop-мутант battery удалён.
- Сироты noop-прогона погашены по маркеру TMPDIR моего прогона.
- `alt/leftover.py`: процессов с `reviewer997r3` в environ/argv нет, кроме самой переписи. `pgrep -fa 'orch997-|reviewer997r3/subj'` → пусто.
- Живые orch-loop/sleep станции и файлы orch-restart*, orch-session-*, _orch_trace*, consultant-* не трогались.
- Коммитов и пушей нет.
