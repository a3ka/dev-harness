FAIL

# Reviewer — контракт 997, реализация, круг 1

OBJECT a92e44c5b78fd97bbe6ad9f470f4dd69de411cb3 (land-merge; ^1 = d67c32a4, ^2 = d8e36fae = head PR#106).
Frozen: `frozen/contracts/997/1`. Блоб контракта 9886ed45 одинаков на теге и на OBJECT. Каталог
`fixtures/ops_server/orch_loop_997/` на OBJECT не отличается от тега (`git diff --stat` пуст).
Находки (reslop, status: ready): `/tmp/dev-harness-verify/rev997/.review/2026-10-18-07.md`.
Блокируют пять находок: Б-1…Б-5. Советов два: С-1, С-2.

## Находки и их классы

| ID | Класс | Суть |
|---|---|---|
| Б-1 | проверка переписана под код + нарушено принятое требование (инв. 3, «м5/р2 сохраняются») + 050 ACCIDENTAL | В субъекте снимочная строка `( while sleep 5; do` заменена на eval-форму. Ожидание р2 (`SNAP_LOOP`) и FIXSIM в 085 переписаны под неё. Своя мера на немигрированном снимке: OBJECT rc=1 «пропала строка снимка 27». Есть форма, сохраняющая р2 и проходящая пробу/093/085 fast (E). |
| Б-2 | нарушено принятое требование (инв. 5 «Lock держится … во время перехода»), воспроизведение | Пара `exec 9>&-` и переоткрытие (orch-loop:63-65) освобождает lock на каждом `exec "$0"`. Если lock ждёт другой процесс, цикл после рестарта отказывает сам себе: loop_rc=1, агентов 1, «ОТКАЗ: orch-loop уже запущен». |
| Б-3 | 050 ACCIDENTAL (фрагмент + отсутствующее свойство + прогнанная простая форма) | Таймаут чтения 1 с с kill relay (:274-278), fd 8 открыт в родителе, настройка канала продублирована в двух ветвях (:256-259 = :264-267). Форма модели (EOF-чтение, coproc один раз), вариант F: 28/0, 093-2/3/4/7 rc 0, 085 fast 0 красных. |
| Б-4 | заявленное ≠ сделанному (README «актуальная семантика», инв. 4) | В README несуществующий шов `ORCH_LOOP_LOCK`, ложь про р2 и про `/dev/fd` (замер: reopen, не dup). В коде комментарии про `$()`, fd 4, «ресурсный предел не создан», «scope создан». В 085 остался TODO и «985». |
| Б-5 | не выполнена строка приёмки (battery 093 гасит своих и изолирует HOME) | battery_stubs.sh не изолирует HOME и не гасит своих. После прогона battery живы `toy-agent-sleeper 300` и `sleep 300` (ppid 1). |
| С-1 | совет | Если lock не открывается, payload говорит «уже запущен». |
| С-2 | совет | 1ef049db сводит две правки 997. |

## 1. Область правки

`git diff --name-only a92e44c5b^1 a92e44c5b` даёт 8 путей: `.github/workflows/ci.yml`, `fixtures/ops_granica/battery_stubs.sh`,
`fixtures/ops_granica/red_limit_otkaz_bez_zapuska.sh`, `fixtures/ops_server/red_cikl_perezapuska_085.sh`,
`fixtures/ops_server/red_server_obvjazka_074.sh`, `ops/server/README.md`, `ops/server/user/orch-loop`,
`registry/ci-steps.tsv`.

Распределение по автору коммита (`git show --stat`):

- implementer (bfd1e08f, 1ef049db): 6 путей, все в ЗОНЕ implementer;
- orchestrator (c77e2557): ci.yml, в своей зоне;
- architect (d8e36fae): только 074, однострочная смена PIN `user/orch-loop`. Правка вне ЗОН
  контракта, но по стоячей санкции №4. Прецедент: docs/owner/2026-10-14-razblokirovka-093-v4-l4-l5.md:49.

Путей вне зон, кроме 074 по санкции, нет. По существу (не по зоне) в Б-1 названа ПРАВКА р2 и FIXSIM
внутри 085: она выходит за ПЕРЕСЕЧЕНИЕ «миграция диагноза».

## 2. Предмет реализован или только оттестирован

- Подтверждение идёт каналом: coproc-pipe, `SCOPED\n` на fd 3 до exec, сравнение буквальное.
  `.scoped`/RAN в production нет (grep).
- Ложный отказ Н-304 исчез. `--cases` (sweep W + Landlock) даёт marker_removed и removed_crash* rc 0,
  starts 2. Красное ДО предъявлено своей мерой: `probe.py --cases --subject <до-997>` даёт
  «997 observed=28 mismatches=28», rc 1, в marker_removed RESTART_COUNT.
- Singleton: flock -n до self-update (lock_before_update rc 1, ноль installer). Но lock не
  держится в переходе (Б-2).
- Инв. 2, fd перед exec агента. Своя fd-перепись агента (`alt/fdcensus.sh`, same и other):
  `0,1,2` плюс наследие моего вызывающего (5, 37), побайтно как у до-997. Fd 3/7/8/9 у агента нет.

## 3. Не переписаны ли проверки под код

- 085 р2 переписан: Б-1.
- 085: ORDER до и после совпадает (md5 d0822189…), 34 клетки. Стабов 40 до и 40 после (своя
  мера: `grep -c "^  ('s[0-9][0-9]'"`). CI l5: «зелено:» 34, «итог 085: красных=0, стабы=40/40,
  диффпроба=32/32».
- Мёртвого `while false` в OBJECT нет: grep пуст.
- battery s7: якорь `exec sudo -nu "$2" "$3"` встречается 1 раз. Своя мера (`alt/s7s1.sh`):
  клетка 3 на s7 даёт rc 1 «КРАСНО: сессия запущена МИМО двери uid — sudo -nu не вызван…», то
  есть ловит ЕГО ветвь. Честный вариант rc 0.
- s1: клетка 2 rc 1 «orch-loop rc=0 при отказе scope … БЕЗ ПОТОЛКА».
- red_limit: литерал И-5 «запуск в scope не подтверждён» совпадает с payload инв. 4.
- Пин 074: `sha256sum ops/server/user/orch-loop` = b1ad5c2232b4bf81e3d10523fb89bfd8b1a1a30d41ac5c39539a4c14eeb9fb4c = PIN (074:115).
- Изоляция battery: Б-5.

## 4. Сырой вывод и rc (мои прогоны в клоне, если не сказано «CI»)

- `bash fixtures/ops_server/orch_loop_997/probe.sh --cases` → rc 0, «997 observed=28 mismatches=0».
  Свой подсчёт: строк SUBJECT 28, с непустыми errors 0.
- `… --matrix` → rc 0, «997 observed=52 mismatches=0». Свой подсчёт: HONEST 28 без ошибок,
  MUTANT 24, `caught=1` 24 из 24 (в том числе pgid_receipt, outside_receipt, lock_receipt по
  обоим uid).
- `bash scripts/run_ci_lane.sh check:orch-loop-997` → rc 0 (оба «observed» нулевые).
- `bash scripts/gen_ci_steps.sh --check` → rc 0.
- `bash scripts/check_provodka.sh "$PWD" contracts/997-orch-loop-metka-perezapuska.md` → rc 0.
- `bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka` → rc 0, «барьеров:
  2 · фикстур: 54 · предъявлено красным повторным прогоном: 54».
- `scope_select --changed a92e44c5b^1` → «0 задетых», MODE needs-full. Ни один frozen-барьер
  `scripts/check_*` и ни один case_* в диффе не тронуты.
- `bash fixtures/_krasnye_074.sh` → rc 1, «итог 074: красных клеток=1 стабы=7/7». Красная клетка
  — только cell_k5b: «станция /home/harness/bin/orch-loop разошлась с пином», станция abab6385…
  Это ожидаемо до поставки консультантом. В CI k5b пропускается, l7 зелёный.
- `bash fixtures/ops_server/red_cikl_perezapuska_085.sh fast` → rc 0, «итог 085 fast:
  красных=0».
- Полный прогон 085 (м5 — живой systemd-run) на станции запрещён контрактом. Беру CI main
  f0c13535b, job 117784076146: «итог 085: красных=0, стабы=40/40, диффпроба=32/32».
- 093:
  - CI job 117784075988: «ЗЕЛЁНО(093-bat): 10/10», «red_limit_otkaz_bez_zapuska.sh: rc=0»,
    «ИТОГ 093: rc=0».
  - Локально с частным HOME: `battery_stubs.sh` rc 0, 10/10, но с сиротами (Б-5).
    `red_limit…` rc 0.
- CI main f0c13535b (содержит a92e44c5b): 12/12 job success. PR#106 MERGED, head d8e36fae,
  statusCheckRollup 12×SUCCESS. Job l7 117784076269: probe «observed=28 mismatches=0» и
  «observed=52 mismatches=0».

## 5. README и код

Не согласованы, см. Б-4: README:69, :78-83, :159-161.

## 6. ПРОВОДКА и ci-step

- Канал `guard=fixtures/ops_server/orch_loop_997/probe.sh` существует. Это барьер именно этого
  предмета: `--subject` по умолчанию указывает на `ops/server/user/orch-loop` (probe.py:318).
- Строка registry совпадает с замороженной дословно. Шаг материализован в ci.yml l7 и исполнен в
  CI (лог l7).
- ПРОВОДКА-ЭНФОРСМЕНТ (guard-only) обоснован честно: поведенческой нормы и правки roles нет.
  diff не трогает roles, docs и contracts.

## 7. Атомарность и норма

- bfd1e08f — сквош одной задачи 997 со ссылкой.
- 1ef049db сводит две правки 997 (С-2).
- Нормативные документы не тронуты.

## 050 — по артефактам диффа

Пять вопросов в порядке (1) свойство, (2) состояние, (3) совместные правки, (4) глубина, (5) потребитель.

- **orch-loop singleton :50-65.**
  - (1) инв. 5;
  - (2) inode lock, явный в fd 9 и payload;
  - (3) orch-loop + README, проба пинует путь;
  - (4) новых env нет, но close/reopen на :63-64 лишний и ломает инв. 5;
  - (5) probe duplicate*/lock_*.
  - Итог: ESSENTIAL, кроме :63-64 (Б-2).
- **Строка eval наблюдателя :159-166.**
  - (1) инв. 3 требует другой формы;
  - (2) нет;
  - (3) тащит за собой правку 085 в двух местах (SNAP_LOOP и FIXSIM), то есть +2 совместные правки;
  - (4) —;
  - (5) только проба.
  - Итог: ACCIDENTAL (Б-1).
- **Канал :249-278.**
  - (1) инв. 2;
  - (2) fd 7/8 и relay-процесс cat; fd 8 живёт в родителе неявно;
  - (3) две копии настройки, рост 0→2;
  - (4) скрытая константа 1 с;
  - (5) probe.
  - Итог: ядро ESSENTIAL, таймаут и копия ACCIDENTAL (Б-3).
- **Payload «scope подтверждён…».** ESSENTIAL (инв. 4), потребитель — проба.
- **085 SNAP_LOOP и WATCH_OPEN_HONEST.**
  - (1) нет: контракт велит сохранять р2;
  - (3) +2 места.
  - Итог: ACCIDENTAL (Б-1).
- **085 LIT_REFUSE093.** ESSENTIAL (миграция инв. 4). Шапка с TODO — ACCIDENTAL-текст (Б-4).
- **red_limit, литерал И-5.** ESSENTIAL (ПЕРЕСЕЧЕНИЕ), потребитель — 093-2.
- **battery s1/s7, якоря.** ESSENTIAL (ПЕРЕСЕЧЕНИЕ), потребитель — battery 10/10.
- **README.** Раздел требуется контрактом (ESSENTIAL), содержание ложно (Б-4).
- **registry, строка check:orch-loop-997.** ESSENTIAL (ПРОВОДКА), потребитель — lane l7.
- **ci.yml.** Производная, ESSENTIAL; `gen_ci_steps --check` rc 0.
- **074 PIN.** ESSENTIAL (санкция №4), потребитель — check:ops-server-family-selftest.

Новых env, флагов и state-каталогов, кроме канонического lock, дифф не вводит.
